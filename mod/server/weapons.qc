string autocvar_sv_weapons_modeloverride;
string autocvar_sv_weapons_sounddir;

MUTATOR_HOOKFUNCTION(mutator_mod, WeaponModel)
{
	if(autocvar_sv_weapons_modeloverride != "" && autocvar_sv_weapons_modeloverride != "default")
	{
		string themdl = sprintf("models/weapons_%s/%s", autocvar_sv_weapons_modeloverride, weapon_model);
		if(fexists(themdl))
			weapon_model_output = themdl;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, WeaponSound)
{
	if(autocvar_sv_weapons_sounddir != "" && autocvar_sv_weapons_sounddir != "default")
	{
		string thesnd = sprintf("weapons_%s/%s", autocvar_sv_weapons_sounddir, weapon_sound);

		if(fexists(strcat("sound/", thesnd, ".ogg"))
		|| fexists(strcat("sound/", thesnd, ".wav"))
		|| fexists(strcat("sound/", thesnd, ".flac"))
		) { weapon_sound_output = strcat(thesnd, ".wav"); }
	}

	return false;
}
