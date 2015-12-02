#ifndef MENUQC
REGISTER_MUTATOR(weapons, true);
#endif

#ifdef SVQC

AUTOCVAR(sv_weapons_modeloverride, string, "", _("Custom directory for weapon models, set to something like myserver, end result will look like 'models/weapons_myserver/weapon.md3'"));
AUTOCVAR(sv_weapons_sounddir, string, "", _("Custom directory for weapon sounds, set to something like myserver, end result will look like 'sound/weapons_myserver/weapon.wav'"));

MUTATOR_HOOKFUNCTION(weapons, Ent_Init, CBC_ORDER_FIRST)
{
	WriteString(MSG_ONE, autocvar_sv_weapons_modeloverride);
	return false;
}

MUTATOR_HOOKFUNCTION(weapons, WeaponSound)
{
	if(autocvar_sv_weapons_sounddir != "" && autocvar_sv_weapons_sounddir != "default")
	{
		string thesnd = sprintf("weapons_%s/%s", autocvar_sv_weapons_sounddir, weapon_sound);

		if (_Sound_fixpath(thesnd)) { weapon_sound_output = thesnd; }
	}

	return false;
}

#elif defined(CSQC)

string sv_weapons_modeloverride;

AUTOCVAR_SAVE(cl_weaponmodel_force,                    bool,   false,      _("Don't allow server to override weapon models"));

MUTATOR_HOOKFUNCTION(weapons, Ent_Init, CBC_ORDER_FIRST)
{
	sv_weapons_modeloverride = strzone(ReadString());
	if(sv_weapons_modeloverride && sv_weapons_modeloverride != "" && sv_weapons_modeloverride != "default")
		FOREACH(Weapons, true, LAMBDA({
			string themdl = sprintf("models/weapons_%s/v_%s.md3", sv_weapons_modeloverride, it.mdl);
			if(fexists(themdl)) { precache_model(themdl); }
			themdl = sprintf("models/weapons_%s/h_%s.iqm", sv_weapons_modeloverride, it.mdl);
			if(fexists(themdl)) { precache_model(themdl); }
			themdl = sprintf("models/weapons_%s/g_%s.md3", sv_weapons_modeloverride, it.mdl);
			if(fexists(themdl)) { precache_model(themdl); }
		}));
	return false;
}

#endif

#ifndef MENUQC
MUTATOR_HOOKFUNCTION(weapons, WeaponModel)
{
	string override;
#ifdef SVQC
	override = autocvar_sv_weapons_modeloverride;
#elif defined(CSQC)
	override = sv_weapons_modeloverride;
	if(!autocvar_cl_weaponmodel_force)
#endif
	if(override != "" && override != "default" && override)
	{
		string themdl = sprintf("models/weapons_%s/%s", override, weapon_model);
		if(fexists(themdl))
			weapon_model_output = themdl;
	}

	return false;
}
#endif
