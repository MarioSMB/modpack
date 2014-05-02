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
	if(SAME_TEAM(other, self.owner) || (IS_SPEC(other) && SAME_TEAM(other.enemy, self.owner)))
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
	if(frag_attacker != frag_target)
	if(!ITEM_DAMAGE_NEEDKILL(frag_deathtype))
	{
		if(time < frag_target.buff_wrath_damage_time)
			frag_damage *= 1.2;
		frag_target.buff_wrath_damage_time = time + 3;
	}
		
	if(frag_attacker.buffs & BUFF_WRATH)
		frag_damage *= 0.7;

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
