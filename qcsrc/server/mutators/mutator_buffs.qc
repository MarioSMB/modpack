vector buffs_MergedColor(float b)
{
    vector c;
	entity e;
    float n = 0;
   
    c = Buff_Color(b);
    
    if(c != '0 0 0')
        return c;

	for(e = Buff_Type_first; e; e = e.enemy)
	{
		if(b & e.items)
		{
            c += Buff_Color(e.items);
            ++n;
        }
	}

    return c * (1/n);
}

float buffs_BuffModel_Customize()
{
	float same_team = (SAME_TEAM(other, self.owner) || (IS_SPEC(other) && SAME_TEAM(other.enemy, self.owner)));
	if(other.alpha <= 0.5 && !same_team)
		return FALSE;
		
	if(other == self.owner || (IS_SPEC(other) && other.enemy == self.owner))
	{
		// somewhat hide the model, but keep the glow
		self.effects = 0;
		self.alpha = -1;
	}
	else
	{
		self.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		self.alpha = 1;
	}
	return TRUE;
}

// buff item
void buff_Ring_Think()
{
    self.nextthink = time;
    self.angles_y = time * 157.1;
    self.alpha = self.owner.alpha;
    self.effects = self.owner.effects - EF_STARDUST;
   
    if(self.owner.team)
        self.effects &= ~EF_ADDITIVE;
    
    setorigin(self, self.owner.origin + '0 0 15');
}

float buff_Waypoint_visible_for_player(entity plr)
{
    if((!self.owner.buff_active && !self.owner.buff_activetime) || plr.buffs)
        return FALSE;

    return WaypointSprite_visible_for_player(plr);
}

void buff_Waypoint_Spawn(entity e)
{
    WaypointSprite_Spawn(Buff_PrettyName(e.buffs), 0, 2048, e, '0 0 40', world, e.team, e, buff_waypoint, TRUE, RADARICON_POWERUP, e.colormod);
    WaypointSprite_UpdateTeamRadar(e.buff_waypoint, RADARICON_POWERUP, Buff_Color(e.buffs));
    e.buff_waypoint.waypointsprite_visible_for_player = buff_Waypoint_visible_for_player;
}

void buff_SetCooldown(float cd)
{
	cd = max(0, cd);

	if(!self.buff_waypoint)
		buff_Waypoint_Spawn(self);

	WaypointSprite_UpdateBuildFinished(self.buff_waypoint, time + cd);
	self.buff_activetime = cd;
	self.buff_active = !cd;
}

void buff_Touch()
{
	if(self.team && DIFF_TEAM(other, self))
		return;
	if(other.frozen)
		return;
	if(other.jb_isprisoned)
		return;
	if(other.vehicle)
		return;
	if(!IS_PLAYER(other))
		return;
	if(!self.buff_active)
		return;
	if(other.buffs)
		return;
		
	self.owner = other;
	self.buff_active = FALSE;
	
	Send_Notification(NOTIF_ONE, other, MSG_MULTI, ITEM_BUFF_GOT, self.buffs);
		
	sound(other, CH_TRIGGER, "misc/shield_respawn.wav", VOL_BASE, ATTN_NORM);
	other.buffs |= (self.buffs);
}

void buff_Think()
{
	if(!gameover)
	if((round_handler_IsActive() && !round_handler_IsRoundStarted()) || time >= game_starttime)
	if(!self.buff_activetime_updated)
	{
		buff_SetCooldown(self.buff_activetime);
		self.buff_activetime_updated = TRUE;
    }

	if(self.buffs != self.oldbuffs)
	{
		self.color = self.colormod = Buff_Color(self.buffs);
		self.enemy.colormod = ((self.team) ? Team_ColorRGB(self.team) + '0.1 0.1 0.1' : self.colormod);

		if(self.buff_waypoint)
		{
			WaypointSprite_Disown(self.buff_waypoint, 1);
			buff_Waypoint_Spawn(self);
		}

		self.oldbuffs = self.buffs;
	}
	
	if(!self.buff_active && !self.buff_activetime)
	if(!self.owner || self.owner.frozen || self.owner.jb_isprisoned || self.owner.deadflag != DEAD_NO || !self.owner.iscreature || !(self.owner.buffs & self.buffs))
	{
		buff_SetCooldown(5 + frametime);
		self.owner = world;
	}
	
	if(self.buff_activetime)
	if(!gameover)
	if((round_handler_IsActive() && !round_handler_IsRoundStarted()) || time >= game_starttime)
	{
		self.buff_activetime = max(0, self.buff_activetime - frametime);

		if(!self.buff_activetime)
		{
			self.buff_active = TRUE;
			sound(self, CH_TRIGGER, "misc/strength_respawn.wav", VOL_BASE, ATTN_NORM); 
		}
	}

	if(!self.buff_active)
	{
		self.alpha = 0.3;
		self.effects &= ~(EF_FULLBRIGHT | EF_ADDITIVE);
		self.pflags = 0;
	}
	else
	{
		self.alpha = 1;
		self.effects |= EF_FULLBRIGHT | EF_ADDITIVE;
		self.light_lev = 220 + 36 * sin(time);
		self.pflags = PFLAGS_FULLDYNAMIC;

		if(self.team && !self.buff_waypoint)
			buff_Waypoint_Spawn(self);
	}
    
	self.nextthink = time;
	self.angles_y = time * 110.1;
}

void buff_Waypoint_Reset()
{
    if(self.buff_waypoint)
        WaypointSprite_Kill(self.buff_waypoint);
    
    if(self.buff_activetime)
        buff_Waypoint_Spawn(self);
}

void buff_Reset()
{
	self.owner = world;
	buff_SetCooldown(5);
	buff_Waypoint_Reset();
	self.buff_activetime_updated = FALSE;
}

void buff_Init(entity ent)
{
	entity oldself = self;
	self = ent;
	if(!self.buffs)
	{
		entity e;
		RandomSelection_Init();
		for(e = Buff_Type_first; e; e = e.enemy)
		{
			RandomSelection_Add(world, e.items, string_null, 1, ((e.count) ? 0.5 : 1)); // if it's already been chosen, give it a lower count
			++e.count;
		}
		self.buffs = RandomSelection_chosen_float;
	}
	
	self.classname = "item_buff";
	self.solid = SOLID_TRIGGER;
	self.flags = FL_ITEM;
	self.think = buff_Think;
	self.touch = buff_Touch;
	self.reset = buff_Reset;
	self.nextthink = time;
	self.scale = 1.5;
	self.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_STARDUST;
	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
	self.gravity = 100;
	self.color = self.colormod = buffs_MergedColor(self.buffs);
	buff_SetCooldown(5);
	self.buff_active = !self.buff_activetime;
	self.pflags = PFLAGS_FULLDYNAMIC;
	
	precache_model("models/buffs/buff.md3");
	setmodel(self, "models/buffs/buff.md3");
	setsize(self, '-15 -15 -40', '15 15 40');
	
	self.enemy = spawn();
	self.enemy.owner = self;
	self.enemy.think = buff_Ring_Think;
	self.enemy.nextthink = time;
	self.enemy.effects = self.effects;
	self.enemy.alpha = self.alpha;
	self.enemy.scale = self.scale * 1.2;
	self.enemy.team = self.team;
	self.enemy.gravity = self.gravity;
	self.enemy.colormod = ((self.team) ? Team_ColorRGB(self.team) + '0.1 0.1 0.1' : self.colormod);

	move_out_of_solid(self);
	droptofloor();

	setmodel(self.enemy, "models/buffs/buff_ring.md3");
	setsize(self.enemy, self.mins, self.maxs);
	setorigin(self.enemy, self.origin + self.maxs * 0.5 * self.scale);
	
	self = oldself;
}

void buff_SpawnReplacement(entity ent, entity old)
{
	setorigin(ent, old.origin);
	ent.angles = old.angles;
	ent.noalign = old.noalign;
	
	buff_Init(ent);
}

// mutator hooks
MUTATOR_HOOKFUNCTION(buffs_PlayerDamage_SplitHealthArmor)
{
	if(frag_target.buffs & BUFF_GUARD)
	{
		vector v = healtharmor_applydamage(50, 0.8, frag_deathtype, frag_damage);
		damage_take = v_x;
		damage_save = v_y;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerDamage_Calculate)
{
	if(frag_attacker.buffs & BUFF_VAMPIRE)
	if(frag_attacker != frag_target)
	if(!frag_target.frozen)
	if(frag_target.takedamage)
	if(!frag_target.jb_isprisoned)
	if(DIFF_TEAM(frag_attacker, frag_target))
	{
		frag_attacker.buff_vampire_lasttarget = frag_target;
		frag_attacker.buff_vampire_lasttarget_time = time + 5;
	}

	if(frag_target.buffs & BUFF_MEDIC)
	if((frag_target.health - frag_damage) <= 0)
	if(!ITEM_DAMAGE_NEEDKILL(frag_deathtype))
	if(frag_attacker)
	if(random() <= 0.4) // 40% chance?
		frag_damage = frag_target.health - 5; // 5 health recovery
		
	if(frag_target.buffs & BUFF_WRATH)
	if(frag_attacker)
	if(!ITEM_DAMAGE_NEEDKILL(frag_deathtype))
	{
		if(frag_attacker == frag_target)
		{
			if(time < frag_target.buff_wrath_damage_time)
				frag_damage *= 0.6;
		}
		else
		{
			if(time < frag_target.buff_wrath_damage_time)
				frag_damage *= 1.1;
			frag_target.buff_wrath_damage_time = time + 3;
		}
	}
		
	if(frag_attacker.buffs & BUFF_WRATH)
		frag_damage *= 0.9;
		
	if(frag_attacker.buffs & BUFF_BASH)
	if(frag_attacker != frag_target)
	if(vlen(frag_force))
	if((get_weaponinfo(DEATH_WEAPONOF(frag_deathtype)).spawnflags & WEP_TYPE_HITSCAN))
	{
		frag_force_x *= 3;
		frag_force_y *= 3;
	}
	else
	{
		frag_force_x *= 2;
		frag_force_y *= 2;
	}
	
	if(frag_target.buffs & BUFF_TENACITY)
	if(frag_target != frag_attacker)
	{
		frag_damage *= 0.7;
		frag_force *= 0.7;
	}
	
	if(frag_attacker.buffs & BUFF_ARC)
	if(frag_target != frag_attacker)
	if(frag_deathtype != DEATH_BUFF_ARC)
	{
		entity head;
		//RadiusDamage (frag_target, frag_attacker, 50, 50, 250, frag_attacker, 0, DEATH_BUFF_ARC, other);

		for(head = findradius(frag_target.origin, 250); head; head = head.chain)
		if(head.takedamage)
		if(head != frag_attacker)
		if(head != frag_target)
		if(head.health > 0)
		if(!head.frozen)
		if(!head.jb_isprisoned)
		if(!head.vehicle)
		if(time >= head.buff_arc_lastzap)
		{
			head.buff_arc_lastzap = time + 1;
			te_csqc_lightningarc(frag_target.origin, head.origin);
			Damage(head, frag_inflictor, frag_attacker, 50, DEATH_BUFF_ARC, head.origin, '0 0 0');
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerSpawn)
{
	self.buffs = BUFF_MEDIC;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerPhysics)
{
	if(self.buffs & BUFF_HASTE)
	{
		self.stat_sv_maxspeed *= 2;
		self.stat_sv_airspeedlimit_nonqw *= 2;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerDies)
{
	self.buffs = 0;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_RemovePlayer)
{
	if(self.buff_model)
	{
		remove(self.buff_model);
		self.buff_model = world;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_OnEntityPreSpawn)
{
	switch(self.classname)
	{
		case "item_strength":
		case "item_invincible":
		{
			entity e = spawn();
			buff_SpawnReplacement(e, self);
			return TRUE;
		}
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_WeaponRate)
{
	if(self.buffs & BUFF_WRATH)
	if(time < self.buff_wrath_damage_time)
		weapon_rate *= 0.7;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerThink)
{
	if(time >= self.buff_vampire_lasttarget_time || self.buff_vampire_lasttarget.deadflag != DEAD_NO) // target has died of our sucking
		self.buff_vampire_lasttarget = world;
		
	if(self.buffs != self.oldbuffs)
	{
		self.oldbuffs = self.buffs;
		if(self.buffs)
		{
			if(!self.buff_model)
			{
				self.buff_model = spawn();
				setmodel(self.buff_model, "models/buffs/buff.md3");
				setsize(self.buff_model, '0 0 -40', '0 0 40');
				self.buff_model.owner = self;
				self.buff_model.pflags = PFLAGS_FULLDYNAMIC;
				self.buff_model.light_lev = 200;
				self.buff_model.customizeentityforclient = buffs_BuffModel_Customize;
			}
			self.buff_model.color = self.buff_model.colormod = buffs_MergedColor(self.buffs);
		}
		else
		{
			remove(self.buff_model);
			self.buff_model = world;
		}
	}
	
	if(self.buff_model)
	{
		setorigin(self.buff_model, self.origin + '0 0 70');
        self.buff_model.angles_y = 200 * time;
	}
	
	if(self.buffs & BUFF_SUPPLY && !(self.items & IT_UNLIMITED_WEAPON_AMMO))
		self.items |= IT_UNLIMITED_WEAPON_AMMO;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_SpectateCopy)
{
	self.buffs = other.buffs;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_VehicleEnter)
{
	vh_vehicle.buffs = vh_player.buffs;
	vh_player.buffs = 0;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_VehicleExit)
{
	vh_player.buffs = vh_vehicle.buffs;
	vh_vehicle.buffs = 0;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerRegen)
{
	if(self.buffs & BUFF_VAMPIRE)
	if(self.buff_vampire_lasttarget)
	if(self.buff_vampire_lasttarget.deadflag == DEAD_NO)
	if(!self.buff_vampire_lasttarget.frozen)
	if(!self.buff_vampire_lasttarget.jb_isprisoned)
	if(time >= self.buff_vampire_lastdamage)
	{
		self.health = min(g_pickup_healthmega_max, self.health + 5);
		self.buff_vampire_lasttarget.health -= 5;
		if(self.buff_vampire_lasttarget.health <= 0)
			Damage(self.buff_vampire_lasttarget, self, self, 1, DEATH_BUFF_VAMPIRE, self.buff_vampire_lasttarget.origin, '0 0 0');
		self.buff_vampire_lastdamage = time + 0.5;
	}
	
	if(self.buffs & BUFF_MEDIC)
	{
		regen_mod_rot = 0.3;
		regen_mod_limit = regen_mod_max = 1.5;
		regen_mod_regen = 2;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Buffs");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Buffs");
	return FALSE;
}

void buffs_Initialize()
{
	precache_model("models/buffs/buff.md3");
	precache_sound("misc/strength_respawn.wav");
	precache_sound("misc/shield_respawn.wav");

	addstat(STAT_BUFFS, AS_INT, buffs);
}

MUTATOR_DEFINITION(mutator_buffs)
{
	MUTATOR_HOOK(PlayerDamage_SplitHealthArmor, buffs_PlayerDamage_SplitHealthArmor, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, buffs_PlayerDamage_Calculate, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, buffs_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPhysics, buffs_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(SpectateCopy, buffs_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleEnter, buffs_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleExit, buffs_VehicleExit, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, buffs_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, buffs_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, buffs_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, buffs_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, buffs_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(WeaponRateFactor, buffs_WeaponRate, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, buffs_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, buffs_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, buffs_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		buffs_Initialize();
	}

	return FALSE;
}
