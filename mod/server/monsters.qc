//FEATURE: Ability to replace monster model paths, to easily load in custom models

AUTOCVAR(sv_monsters_modeloverride, string, "", "Custom directory for monster models, set to something like myserver, end result will look like 'models/monsters_myserver/monster.md3'");

MUTATOR_HOOKFUNCTION(mutator_mod, MonsterModel)
{
	if(autocvar_sv_monsters_modeloverride != "" && autocvar_sv_monsters_modeloverride != "default")
	{
		string themdl = sprintf("models/monsters_%s/%s", autocvar_sv_monsters_modeloverride, M_ARGV(0, string));
		if(fexists(themdl))
			M_ARGV(1, string) = themdl;
	}
}
