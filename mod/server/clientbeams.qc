.float stat_wep_vaporizer_primary_refire;
.float stat_wep_vortex_primary_refire;
.float stat_wep_vortex_secondary_refire;

MUTATOR_HOOKFUNCTION(mutator_mod, SetModname)
{
	addstat(STAT_WEP_VAPORIZER_PRIMARY_REFIRE, AS_FLOAT, stat_wep_vaporizer_primary_refire);
	addstat(STAT_WEP_VORTEX_PRIMARY_REFIRE, AS_FLOAT, stat_wep_vortex_primary_refire);
	addstat(STAT_WEP_VORTEX_SECONDARY_REFIRE, AS_FLOAT, stat_wep_vortex_secondary_refire);
	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, PlayerPreThink)
{
	self.stat_wep_vaporizer_primary_refire = WEP_CVAR_PRI(vaporizer, refire);
	self.stat_wep_vortex_primary_refire = WEP_CVAR_PRI(vortex, refire);
	self.stat_wep_vortex_secondary_refire = WEP_CVAR_SEC(vortex, refire);
	return false;
}
