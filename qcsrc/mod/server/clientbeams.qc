.float stat_wep_vaporizer_primary_refire;

MUTATOR_HOOKFUNCTION(mutator_mod, SetModname)
{
	addstat(STAT_WEP_VAPORIZER_PRIMARY_REFIRE, AS_FLOAT, stat_wep_vaporizer_primary_refire);
	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, PlayerPreThink)
{
	self.stat_wep_vaporizer_primary_refire = WEP_CVAR_PRI(vaporizer, refire);
	return false;
}
