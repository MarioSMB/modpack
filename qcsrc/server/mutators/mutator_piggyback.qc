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
	slave.oldsolid = slave.solid;
	slave.solid = SOLID_CORPSE;
	slave.pb_canattach = 0;
	
	centerprint(slave, sprintf("You are now %s^7's piggybacker!", host.netname));
	centerprint(host, sprintf("%s^7 is now your piggybacker!", slave.netname));
}

void pb_Detach(entity host)
{
	entity slave = host.piggybacker;
	
	if(!slave)
		return;
	
	slave.aiment = world;
	slave.pbhost = world;
	
	if(IS_PLAYER(slave))
	{
		// this doesn't happen when we're fixing a broken reference
		
		if(slave.movetype == MOVETYPE_FOLLOW) // don't reset if player was killed or somehting
			slave.movetype = MOVETYPE_WALK;
		slave.velocity = '0 0 0';
		slave.solid = slave.oldsolid;
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

#define BROKEN_PBREF(e) ((e).piggybacker && ((e).piggybacker.pbhost != (e) || (e).piggybacker.movetype != MOVETYPE_FOLLOW))

MUTATOR_HOOKFUNCTION(pb_MatchEnd)
{
	entity head;
	FOR_EACH_PLAYER(head) { pb_Detach(head); }
	return FALSE;
}

MUTATOR_HOOKFUNCTION(pb_PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || gameover) { return FALSE; }
	
	if(self.pbhost)
	{
		pb_Detach(self.pbhost);
		return TRUE;
	}
	if(self.piggybacker)
	{
		pb_Detach(self);
		return TRUE;
	}

	if(!self.frozen)
	if(self.deadflag == DEAD_NO)
	if(!self.vehicle)
	{
		entity head, closest_target = world;

		head = WarpZone_FindRadius(self.origin, autocvar_g_vehicles_enter_radius, TRUE);
		while(head)
		{
			if(IS_PLAYER(head))
			if(SAME_TEAM(head, self))
			if(head != self)
			if(head.deadflag == DEAD_NO)
			if(!head.vehicle)
			if(!head.frozen)
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

		if(closest_target) { pb_Attach(closest_target, self); return TRUE; }
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(pb_PlayerThink)
{
	if(BROKEN_PBREF(self)) { pb_Detach(self); }
	
	if(!self.pbent)
		pb_FixPBEnt(self);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(pb_ResetMap)
{
	FOR_EACH_PLAYER(self) { pb_Detach(self); }
	return FALSE;
}

MUTATOR_HOOKFUNCTION(pb_RemovePlayer)
{
	if(self.piggybacker)
	{
		self.piggybacker.pb_canattach = 1;
		pb_Detach(self);
	}
	
	if(self.pbhost)
		pb_Detach(self.pbhost);
	self.pb_canattach = 0;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(pb_PlayerDies)
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
	
	return FALSE;
}

MUTATOR_DEFINITION(mutator_piggyback)
{
	MUTATOR_HOOK(MatchEnd, pb_MatchEnd, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, pb_PlayerUseKey, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerPreThink, pb_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, pb_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, pb_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, pb_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, pb_PlayerDies, CBC_ORDER_ANY);

	return FALSE;
}
