REGISTER_MUTATOR(piggyback, cvar("g_piggyback"));

AUTOCVAR_NOREF(g_piggyback, bool, false, _("Enable piggyback mutator (riding teammates)"));
AUTOCVAR(g_piggyback_ride_enemies, bool, false, _("Allow riding enemies"));

.float cvar_cl_nocarry;
.float cvar_cl_noride;

REPLICATE(cvar_cl_nocarry, bool, "cl_nocarry");
REPLICATE(cvar_cl_noride, bool, "cl_noride");

ATTRIB(Client, cvar_cl_nocarry, bool, this.cvar_cl_nocarry);
ATTRIB(Client, cvar_cl_noride, bool, this.cvar_cl_noride);

.entity piggybacker;
.entity pbent;
.entity pbhost;
.float pb_canattach;
//.float pb_attachblock;
.float pb_oldsolid;

#define BROKEN_PBREF(e) ((e).piggybacker && ((e).piggybacker.pbhost != (e) || (e).piggybacker.move_movetype != MOVETYPE_FOLLOW))

void pb_Attach(entity host, entity slave);
void pb_Detach(entity host);

entity pb_TailOf(entity p);
entity pb_RootOf(entity p);

entity pb_TailOf(entity p)
{
	while(p.piggybacker)
		p = p.piggybacker;
	return p;
}

entity pb_RootOf(entity p)
{
	while(p.pbhost)
		p = p.pbhost;
	return p;
}

.float pb_oldmoveflags;
.float pb_oldverticalfly;
void pb_Attach(entity host, entity slave)
{
	entity root = pb_RootOf(host);
	host = pb_TailOf(host);
	
	if(host == slave || root == slave || host == slave.piggybacker || slave == host.piggybacker)
		return;
	
	host.piggybacker = slave;
	set_movetype(slave, MOVETYPE_FOLLOW);
	slave.aiment = host.pbent;
	slave.pbhost = host;
	slave.pb_oldsolid = slave.solid;
	slave.solid = SOLID_CORPSE;
	slave.pb_canattach = 0;

	if(IS_MONSTER(host))
	{
		host.pb_oldmoveflags = host.monster_moveflags;
		host.pb_oldverticalfly = (host.spawnflags & MONSTERFLAG_FLY_VERTICAL);
		host.spawnflags |= MONSTERFLAG_FLY_VERTICAL;
		host.monster_moveflags = MONSTER_MOVE_NOMOVE;
	}
	
	RemoveGrapplingHooks(slave);
	
	Send_Notification(NOTIF_ONE, slave, MSG_CENTER, CENTER_PIGGYBACK_RIDING, (IS_MONSTER(host)) ? host.monster_name : host.netname);
	if(IS_PLAYER(host))
		Send_Notification(NOTIF_ONE, host, MSG_CENTER, CENTER_PIGGYBACK_CARRYING, slave.netname);
}

void pb_Detach(entity host)
{
	entity slave = host.piggybacker;
	
	if(!slave)
		return;
	
	slave.aiment = NULL;
	slave.pbhost = NULL;

	if(IS_MONSTER(host))
	{
		host.monster_moveto = '0 0 0';
		host.monster_moveflags = host.pb_oldmoveflags;
		if(!host.pb_oldverticalfly) { host.spawnflags &= ~MONSTERFLAG_FLY_VERTICAL; }
	}
	
	if(IS_PLAYER(slave))
	{
		// this doesn't happen when we're fixing a broken reference
		
		if(slave.move_movetype == MOVETYPE_FOLLOW) // don't reset if player was killed
			set_movetype(slave, MOVETYPE_WALK);
		slave.velocity = '0 0 0';
		slave.solid = slave.pb_oldsolid;
		
		tracebox(host.origin, slave.mins, slave.maxs, slave.origin, MOVE_NOMONSTERS, slave);
		
		if(trace_fraction < 1)
			setorigin(slave, trace_endpos); // fix player glitching out of the NULL
		slave.oldorigin = slave.origin; // no fall damage!
		
		Kill_Notification(NOTIF_ONE, slave, MSG_CENTER, CPID_PIGGYBACK);
		if(IS_PLAYER(host))
			Kill_Notification(NOTIF_ONE, host, MSG_CENTER, CPID_PIGGYBACK);
	}
	
	host.piggybacker = NULL;
}

void pb_PBEntThink(entity this)
{
	setorigin(this, this.owner.origin + '0 0 0.82' * this.owner.maxs_z);
	this.nextthink = time;
}

void pb_FixPBEnt(entity p)
{
	entity e = new(pb_ent);
	e.owner = p;
	setthink(e, pb_PBEntThink);
	e.nextthink = time;
	p.pbent = e;
}

bool pb_GiveItem(entity to, entity item)
{
	if (item.classname == "droppedweapon")
	{
		item.strength_finished = max(0, item.strength_finished - time);
		item.invincible_finished = max(0, item.invincible_finished - time);
		item.superweapons_finished = max(0, item.superweapons_finished - time);
	}

	entity it = item.itemdef;
	bool gave = (it && it.instanceOfPickup) ? ITEM_HANDLE(Pickup, it, item, to) : Item_GiveTo(item, to);
	if (!gave)
	{
		if (item.classname == "droppedweapon")
		{
			// undo what we did above
			item.strength_finished += time;
			item.invincible_finished += time;
			item.superweapons_finished += time;
		}
		if(!to.pbhost)
			to = to.piggybacker; // increase it later
		return false;
	}

	if (item.classname == "droppedweapon")
	{
		// undo it anyway
		item.strength_finished += time;
		item.invincible_finished += time;
		item.superweapons_finished += time;
	}

	to.last_pickup = time;

	_sound (to, CH_TRIGGER, item.item_pickupsound, VOL_BASE, ATTEN_NORM);
	return true;
}

MUTATOR_HOOKFUNCTION(piggyback, MatchEnd)
{
	FOREACH_CLIENT(IS_PLAYER(it), LAMBDA(pb_Detach(it)));
	IL_EACH(g_monsters, true,
	{
		pb_Detach(it);
	});
	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || game_stopped) { return; }

	entity player = M_ARGV(0, entity);
	
	if(player.pbhost)
	{
		pb_Detach(player.pbhost);
		return true;
	}
	if(player.piggybacker)
	{
		pb_Detach(player);
		return true;
	}

#define LIMBO(v) (IS_DEAD(v) || STAT(FROZEN, v))

	if(!player.cvar_cl_noride)
	if(!player.vehicle && !IS_DEAD(player) && !STAT(FROZEN, player))
	{
		entity head, closest_target = NULL;

		head = WarpZone_FindRadius(player.origin, autocvar_g_vehicles_enter_radius, true);
		while(head)
		{
			if(IS_PLAYER(head) || (IS_MONSTER(head) && ((Monsters_from(head.monsterid)).spawnflags & MON_FLAG_RIDE)))
			if(SAME_TEAM(head, player) || autocvar_g_piggyback_ride_enemies || (IS_MONSTER(head) && head.realowner == player))
			if(head != player)
			if(!head.cvar_cl_nocarry)
			if(!IS_DEAD(head)) // we check for trapped status here, but better to be safe than sorry, considering the madness happening
			if(!head.vehicle)
			if((!LIMBO(head) && !LIMBO(player)) || (LIMBO(head) || LIMBO(player))) // your guess is as good as mine
			{
				if(closest_target)
				{
					if(vlen2(player.origin - head.origin) < vlen2(player.origin - closest_target.origin))
					{ closest_target = head; }
				}
				else { closest_target = head; }
			}
			
			head = head.chain;
		}

		if(closest_target)
		if(IS_BOT_CLIENT(closest_target)) { pb_Attach(player, closest_target); return true; }
		else { pb_Attach(closest_target, player); return true; }
	}

#undef LIMBO
}

MUTATOR_HOOKFUNCTION(piggyback, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(BROKEN_PBREF(player)) { pb_Detach(player); }
	
	if(!player.pbent)
		pb_FixPBEnt(player);

	if(IS_MONSTER(player.pbhost))
	if(CS(player).movement || PHYS_INPUT_BUTTON_JUMP(player) || PHYS_INPUT_BUTTON_CROUCH(player))
	//if(!player.pbhost.enemy) // if player is trying to move, don't override
	{
		float forw, rit, updown = 0;
		vector wishvel = '0 0 0';

		makevectors(player.angles);
		if(PHYS_INPUT_BUTTON_JUMP(player))
			updown = 300;
		else if(PHYS_INPUT_BUTTON_CROUCH(player))
			updown = -300;

		if(CS(player).movement)
		{
			forw = CS(player).movement_x * 500;
			rit = CS(player).movement_y * 500;
			//updown = CS(player).movement_z * 100;
			
			wishvel = v_forward * forw + v_right * rit;
		}
		
		//vector wishvel = normalize(('10 0 0' + v_forward * CS(player).movement_x) + ('0 10 0' + v_right * CS(player).movement_y) + ('0 0 1' * CS(player).movement_z));
		//print(vtos(player.origin), vtos(player.origin + wishvel), "\n");
		player.pbhost.monster_moveto = player.origin + wishvel;
		player.pbhost.monster_moveto_z = v_up_z * updown;
	}
}

MUTATOR_HOOKFUNCTION(piggyback, MonsterMove)
{
	entity mon = M_ARGV(0, entity);

	if(BROKEN_PBREF(mon)) { pb_Detach(mon); }
	
	if(!mon.pbent)
		pb_FixPBEnt(mon);

	if(mon.piggybacker)
	{
		mon.flags |= FL_PICKUPITEMS;
		mon.last_trace = time;
	}
	else
		mon.flags &= ~FL_PICKUPITEMS;
}

MUTATOR_HOOKFUNCTION(piggyback, reset_map_players)
{
	FOREACH_CLIENT(IS_PLAYER(it), LAMBDA(pb_Detach(it)));
}

void pb_RemovePlayer(entity this)
{
	if(this.piggybacker)
	{
		this.piggybacker.pb_canattach = 1;
		pb_Detach(this);
	}
	
	if(this.pbhost)
		pb_Detach(this.pbhost);
	this.pb_canattach = 0;

	if(this.pbent)
	{
		delete(this.pbent);
		this.pbent = NULL;
	}
}

MUTATOR_HOOKFUNCTION(piggyback, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	pb_RemovePlayer(player);
}

MUTATOR_HOOKFUNCTION(piggyback, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	pb_RemovePlayer(player);
}

void pb_PlayerDies(entity this)
{
	if(!this.pbhost && this.pb_canattach)
		this.pb_canattach = 0;
		
	if(this.piggybacker)
	{
		this.piggybacker.pb_canattach = 1;
		pb_Detach(this);
	}
	
	if(this.pbhost)
		pb_Detach(this.pbhost);
	this.pb_canattach = 0;
}

MUTATOR_HOOKFUNCTION(piggyback, MonsterDies)
{
	entity frag_target = M_ARGV(0, entity);

	pb_PlayerDies(frag_target);
}

MUTATOR_HOOKFUNCTION(piggyback, PlayerDies)
{
	entity frag_target = M_ARGV(2, entity);

	pb_PlayerDies(frag_target);
}

MUTATOR_HOOKFUNCTION(piggyback, FixPlayermodel)
{
	entity player = M_ARGV(2, entity);

	if(!player.pbhost) { return false; }

	// this was the nearest hook to the original code
	bool do_crouch = PHYS_INPUT_BUTTON_CROUCH(player);
	if(player.hook_state
	|| player.vehicle
	|| STAT(FROZEN, player)
	) { do_crouch = false; }

	if(!do_crouch && player.crouch)
	{
		tracebox(player.origin, STAT(PL_MIN, player), STAT(PL_MAX, player), player.origin, false, player);
		if (!trace_startsolid || player.pbhost)
		{
			player.crouch = false;
			player.view_ofs = STAT(PL_VIEW_OFS, player);
			setsize (player, STAT(PL_MIN, player), STAT(PL_MAX, player));
		}
	}
}

MUTATOR_HOOKFUNCTION(piggyback, GrappleHookThink)
{
	entity hook_pullentity = M_ARGV(2, entity);

	if(hook_pullentity.pbhost)
	{
		hook_pullentity = pb_RootOf(hook_pullentity);
		M_ARGV(1, int) = 2; // enforce tarzan
	}

	M_ARGV(2, entity) = hook_pullentity;
}

MUTATOR_HOOKFUNCTION(piggyback, BuffModel_Customize)
{
	entity buff = M_ARGV(0, entity);
	entity player = M_ARGV(1, entity);

	if(player.pbhost == buff.owner || buff.owner.piggybacker)
		return true; // don't show to piggybacker's carrier, and don't show if carrier is carrying someone else
}


MUTATOR_HOOKFUNCTION(piggyback, ItemTouch)
{
	entity item = M_ARGV(0, entity);
	entity toucher = M_ARGV(1, entity);

	if(IS_MONSTER(toucher))
	{
		entity p = toucher;
		while(p.piggybacker)
		{
			p = p.piggybacker;
			if(IS_PLAYER(p))
			{
				toucher = p;
				break;
			}
		}

		if(IS_MONSTER(toucher))
			return MUT_ITEMTOUCH_RETURN; // make sure we're not allowing something nasty here
	}

	// give items to all piggybackers
	// if we get here, the above stuff is out of the way

	// we use pb_RootOf here, as magnet buff can give riders items, and it wouldn't be very nice if they hogged them
	entity p = pb_RootOf(toucher);
	if(IS_PLAYER(p))
		toucher = p;
	while(p.piggybacker)
	{
		p = p.piggybacker;
		if(IS_PLAYER(p))
		{
			if(!pb_GiveItem(p, item))
				continue;
		}
	}

	M_ARGV(1, entity) = toucher;

	return MUT_ITEMTOUCH_CONTINUE;
}

MUTATOR_HOOKFUNCTION(piggyback, BuffTouch)
{
	entity buff = M_ARGV(0, entity);
	entity toucher = M_ARGV(1, entity);

	if(IS_MONSTER(toucher))
	if(toucher.piggybacker)
		toucher = toucher.piggybacker;

	if(toucher.buffs)
	if(toucher.buffs == buff.buffs || !toucher.cvar_cl_buffs_autoreplace)
	{
		entity p = toucher;
		while(p.piggybacker)
		{
			p = p.piggybacker;
			if(!p.buffs || (!p.piggybacker && (p.cvar_cl_buffs_autoreplace || p.buffs != buff.buffs)))
			{
				toucher = p;
				break;
			}
		}
	}

	M_ARGV(1, entity) = toucher;
}
