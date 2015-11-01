AUTOCVAR(sv_monsters_modeloverride, string, "", _("Custom directory for monster models, set to something like myserver, end result will look like 'models/monsters_myserver/monster.md3'"));

MUTATOR_HOOKFUNCTION(mutator_mod, MonsterModel)
{
	if(autocvar_sv_monsters_modeloverride != "" && autocvar_sv_monsters_modeloverride != "default")
	{
		string themdl = sprintf("models/monsters_%s/%s", autocvar_sv_monsters_modeloverride, monster_model);
		if(fexists(themdl))
			monster_model_output = themdl;
	}

	return false;
}
