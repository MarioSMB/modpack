MUTATOR_HOOKFUNCTION(buffs_PlayerDamage_SplitHealthArmor)
{
	vector v = healtharmor_applydamage(50, 0.8, frag_deathtype, frag_damage);
	damage_take = v_x;
	damage_save = v_y;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerDamage_Calculate)
{
	if(frag_attacker.buffs & BUFF_VAMPIRE)
	if(!frag_target.frozen)
	if(frag_target.takedamage)
	if(!frag_target.jb_isprisoned)
	if(DIFF_TEAM(frag_attacker, frag_target))
	{
		frag_attacker.buff_vampire_lasttarget = frag_target;
		frag_attacker.buff_vampire_lasttarget_time = time + 5;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerSpawn)
{
	self.buffs = 0;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerThink)
{
	if(time >= self.buff_vampire_lasttarget_time)
		self.buff_vampire_lasttarget = world;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_SpectateCopy)
{
	self.buffs = other.buffs;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(buffs_PlayerRegen)
{
	if(self.buffs & BUFF_VAMPIRE)
	if(self.buff_vampire_lasttarget)
	if(time >= self.buff_vampire_lastdamage)
	{
		self.health = max(g_pickup_healthmega_max, self.health + 5);
		Damage(self.buff_vampire_lasttarget, self, self, 5, DEATH_BUFF_VAMPIRE, self.buff_vampire_lasttarget.origin, '0 0 0');
		self.buff_vampire_lastdamage = time + 0.5;
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
	addstat(STAT_BUFFS, AS_INT, buffs);
}

MUTATOR_DEFINITION(mutator_buffs)
{
	MUTATOR_HOOK(PlayerDamage_SplitHealthArmor, buffs_PlayerDamage_SplitHealthArmor, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, buffs_PlayerDamage_Calculate, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, buffs_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(SpectateCopy, buffs_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, buffs_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, buffs_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, buffs_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, buffs_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		buffs_Initialize();
	}

	return FALSE;
}
