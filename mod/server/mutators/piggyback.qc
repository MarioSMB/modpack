REGISTER_MUTATOR(piggyback, cvar("g_piggyback"));

AUTOCVAR(g_piggyback, bool, false, _("Enable piggyback mutator (riding teammates)"));
AUTOCVAR(g_piggyback_ride_enemies, bool, false, _("Allow riding enemies"));

.float cvar_cl_nocarry;

.entity piggybacker;
.entity pbent;
.entity pbhost;
.float pb_canattach;
//.float pb_attachblock;
.float pb_oldsolid;

#define BROKEN_PBREF(e) ((e).piggybacker && ((e).piggybacker.pbhost != (e) || (e).piggybacker.movetype != MOVETYPE_FOLLOW))

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
	slave.movetype = MOVETYPE_FOLLOW;
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
	
	RemoveGrapplingHook(slave);
	
	Send_Notification(NOTIF_ONE, slave, MSG_CENTER, CENTER_PIGGYBACK_RIDING, (IS_MONSTER(host)) ? host.monster_name : host.netname);
	if(IS_PLAYER(host))
		Send_Notification(NOTIF_ONE, host, MSG_CENTER, CENTER_PIGGYBACK_CARRYING, slave.netname);
}

void pb_Detach(entity host)
{
	entity slave = host.piggybacker;
	
	if(!slave)
		return;
	
	slave.aiment = world;
	slave.pbhost = world;

	if(IS_MONSTER(host))
	{
		host.monster_moveto = '0 0 0';
		host.monster_moveflags = host.pb_oldmoveflags;
		if(!host.pb_oldverticalfly) { host.spawnflags &= ~MONSTERFLAG_FLY_VERTICAL; }
	}
	
	if(IS_PLAYER(slave))
	{
		// this doesn't happen when we're fixing a broken reference
		
		if(slave.movetype == MOVETYPE_FOLLOW) // don't reset if player was killed
			slave.movetype = MOVETYPE_WALK;
		slave.velocity = '0 0 0';
		slave.solid = slave.pb_oldsolid;
		
		tracebox(host.origin, slave.mins, slave.maxs, slave.origin, MOVE_NOMONSTERS, slave);
		
		if(trace_fraction < 1)
			setorigin(slave, trace_endpos); // fix player glitching out of the world
		slave.oldorigin = slave.origin; // no fall damage!
		
		Kill_Notification(NOTIF_ONE, slave, MSG_CENTER_CPID, CPID_PIGGYBACK);
		if(IS_PLAYER(host))
			Kill_Notification(NOTIF_ONE, host, MSG_CENTER_CPID, CPID_PIGGYBACK);
	}
	
	host.piggybacker = world;
}

void pb_PBEntThink()
{
	setorigin(self, self.owner.origin + '0 0 0.82' * self.owner.maxs_z);
	self.nextthink = time;
}

void pb_FixPBEnt(entity p)
{
	entity e = spawn();
	e.owner = p;
	e.classname = "pb_ent";
	e.think = pb_PBEntThink;
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
	entity head;
	FOR_EACH_PLAYER(head) { pb_Detach(head); }
	FOR_EACH_MONSTER(head) { pb_Detach(head); }
	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || gameover) { return false; }
	
	if(self.pbhost)
	{
		pb_Detach(self.pbhost);
		return true;
	}
	if(self.piggybacker)
	{
		pb_Detach(self);
		return true;
	}

#define LIMBO(v) ((v).frozen || (v).deadflag != DEAD_NO)

	if(!self.vehicle && !self.deadflag && !self.frozen)
	{
		entity head, closest_target = world;

		head = WarpZone_FindRadius(self.origin, autocvar_g_vehicles_enter_radius, true);
		while(head)
		{
			if(IS_PLAYER(head) || (IS_MONSTER(head) && ((get_monsterinfo(head.monsterid)).spawnflags & MON_FLAG_RIDE)))
			if(SAME_TEAM(head, self) || autocvar_g_piggyback_ride_enemies || (IS_MONSTER(head) && head.realowner == self))
			if(head != self)
			if(!head.cvar_cl_nocarry)
			if(head.deadflag == DEAD_NO) // we check for trapped status here, but better to be safe than sorry, considering the madness happening
			if(!head.vehicle)
			if((!LIMBO(head) && !LIMBO(self)) || (LIMBO(head) || LIMBO(self))) // your guess is as good as mine
			{
				if(closest_target)
				{
					if(vlen(self.origin - head.origin) < vlen(self.origin - closest_target.origin))
					{ closest_target = head; }
				}
				else { closest_target = head; }
			}
			
			head = head.chain;
		}

		if(closest_target)
		if(IS_BOT_CLIENT(closest_target)) { pb_Attach(self, closest_target); return true; }
		else { pb_Attach(closest_target, self); return true; }
	}

#undef LIMBO

	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, PlayerPreThink)
{
	if(BROKEN_PBREF(self)) { pb_Detach(self); }
	
	if(!self.pbent)
		pb_FixPBEnt(self);

	if(IS_MONSTER(self.pbhost))
	if(self.movement || self.BUTTON_JUMP || self.BUTTON_CROUCH)
	//if(!self.pbhost.enemy) // if player is trying to move, don't override
	{
		float forw, rit, updown = 0;
		vector wishvel = '0 0 0';

		makevectors(self.angles);
		if(self.BUTTON_JUMP)
			updown = 300;
		else if(self.BUTTON_CROUCH)
			updown = -300;

		if(self.movement)
		{
			forw = self.movement_x * 500;
			rit = self.movement_y * 500;
			//updown = self.movement_z * 100;
			
			wishvel = v_forward * forw + v_right * rit;
		}
		
		//vector wishvel = normalize(('10 0 0' + v_forward * self.movement_x) + ('0 10 0' + v_right * self.movement_y) + ('0 0 1' * self.movement_z));
		//print(vtos(self.origin), vtos(self.origin + wishvel), "\n");
		self.pbhost.monster_moveto = self.origin + wishvel;
		self.pbhost.monster_moveto_z = v_up_z * updown;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, MonsterMove)
{
	if(BROKEN_PBREF(self)) { pb_Detach(self); }
	
	if(!self.pbent)
		pb_FixPBEnt(self);

	if(self.piggybacker)
	{
		self.flags |= FL_PICKUPITEMS;
		self.last_trace = time;
	}
	else
		self.flags &= ~FL_PICKUPITEMS;

	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, reset_map_players)
{
	FOR_EACH_PLAYER(self) { pb_Detach(self); }
	return false;
}

void pb_RemovePlayer()
{
	if(self.piggybacker)
	{
		self.piggybacker.pb_canattach = 1;
		pb_Detach(self);
	}
	
	if(self.pbhost)
		pb_Detach(self.pbhost);
	self.pb_canattach = 0;
}

MUTATOR_HOOKFUNCTION(piggyback, MakePlayerObserver)
{
	pb_RemovePlayer();
	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, ClientDisconnect)
{
	pb_RemovePlayer();
	return false;
}

void pb_PlayerDies()
{
	if(!self.pbhost && self.pb_canattach)
		self.pb_canattach = 0;
		
	if(self.piggybacker)
	{
		self.piggybacker.pb_canattach = 1;
		pb_Detach(self);
	}
	
	if(self.pbhost)
		pb_Detach(self.pbhost);
	self.pb_canattach = 0;
}

MUTATOR_HOOKFUNCTION(piggyback, MonsterDies)
{
	pb_PlayerDies();
	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, PlayerDies)
{
	pb_PlayerDies();
	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_nocarry, "cl_nocarry");
	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, FixPlayermodel)
{
	if(!self.pbhost) { return false; }

	// this was the nearest hook to the original code
	bool do_crouch = self.BUTTON_CROUCH;
	if(self.hook_state
	|| self.vehicle
	|| self.frozen
	) { do_crouch = false; }

	// WEAPONTODO: THIS SHIT NEEDS TO GO EVENTUALLY
	// It cannot be predicted by the engine!
	.entity weaponentity = weaponentities[0];
	if((self.weapon == WEP_SHOCKWAVE.m_id || self.weapon == WEP_SHOTGUN.m_id) && self.(weaponentity).wframe == WFRAME_FIRE2 && time < self.(weaponentity).weapon_nextthink)
		do_crouch = false;

	if(!do_crouch && self.crouch)
	{
		tracebox(self.origin, STAT(PL_MIN, self), STAT(PL_MAX, self), self.origin, false, self);
		if (!trace_startsolid || self.pbhost)
		{
			self.crouch = false;
			self.view_ofs = STAT(PL_VIEW_OFS, self);
			setsize (self, STAT(PL_MIN, self), STAT(PL_MAX, self));
		}
	}

	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, GrappleHookThink)
{
	if(hook_pullentity.pbhost)
	{
		hook_pullentity = pb_RootOf(hook_pullentity);
		hook_tarzan = 2; // enforce tarzan
	}
	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, BuffModel_Customize)
{
	if(buff_player.pbhost == self.owner || self.owner.piggybacker)
		return true; // don't show to piggybacker's carrier, and don't show if carrier is carrying someone else
	return false;
}


MUTATOR_HOOKFUNCTION(piggyback, ItemTouch)
{
	if(IS_MONSTER(other))
	{
		entity p = other;
		while(p.piggybacker)
		{
			p = p.piggybacker;
			if(IS_PLAYER(p))
			{
				other = p;
				break;
			}
		}

		if(IS_MONSTER(other))
			return MUT_ITEMTOUCH_RETURN; // make sure we're not allowing something nasty here
	}

	// give items to all piggybackers
	// if we get here, the above stuff is out of the way

	// we use pb_RootOf here, as magnet buff can give riders items, and it wouldn't be very nice if they hogged them
	entity p = pb_RootOf(other);
	if(IS_PLAYER(p))
		other = p;
	while(p.piggybacker)
	{
		p = p.piggybacker;
		if(IS_PLAYER(p))
		{
			if(!pb_GiveItem(p, self))
				continue;
		}
	}

	return false;
}

MUTATOR_HOOKFUNCTION(piggyback, BuffTouch)
{
	if(IS_MONSTER(other))
	if(other.piggybacker)
		other = other.piggybacker;

	if(other.buffs)
	if(other.buffs == self.buffs || !other.cvar_cl_buffs_autoreplace)
	{
		entity p = other;
		while(p.piggybacker)
		{
			p = p.piggybacker;
			if(!p.buffs || (!p.piggybacker && (p.cvar_cl_buffs_autoreplace || p.buffs != self.buffs)))
			{
				other = p;
				break;
			}
		}
	}
	return false;
}
