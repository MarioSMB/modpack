AUTOCVAR(sv_weapons_modeloverride, string, "", _("Custom directory for weapon models, set to something like myserver, end result will look like 'models/weapons_myserver/weapon.md3'"));
AUTOCVAR(sv_weapons_sounddir, string, "", _("Custom directory for weapon sounds, set to something like myserver, end result will look like 'sound/weapons_myserver/weapon.wav'"));

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

		if (_Sound_fixpath(thesnd)) { weapon_sound_output = thesnd }
	}

	return false;
}
