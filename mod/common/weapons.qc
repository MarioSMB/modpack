#ifndef MENUQC
REGISTER_MUTATOR(weapon_models, true);
#endif

#ifdef SVQC

AUTOCVAR(sv_weapons_modeloverride, string, "", _("Custom directory for weapon models, set to something like myserver, end result will look like 'models/weapons_myserver/weapon.md3'"));
AUTOCVAR(sv_weapons_sounddir, string, "", _("Custom directory for weapon sounds, set to something like myserver, end result will look like 'sound/weapons_myserver/weapon.wav'"));

MUTATOR_HOOKFUNCTION(weapon_models, Ent_Init, CBC_ORDER_LAST)
{
	WriteString(MSG_ONE, autocvar_sv_weapons_modeloverride);
}

MUTATOR_HOOKFUNCTION(weapon_models, WeaponSound)
{
	if(autocvar_sv_weapons_sounddir != "" && autocvar_sv_weapons_sounddir != "default")
	{
		string thesnd = sprintf("weapons_%s/%s", autocvar_sv_weapons_sounddir, M_ARGV(0, string));

		if (Sound_Exists(thesnd)) { M_ARGV(1, string) = thesnd; }
	}
}

#elif defined(CSQC)

string sv_weapons_modeloverride;

AUTOCVAR_SAVE(cl_weaponmodel_force,                    bool,   false,      _("Don't allow server to override weapon models"));

MUTATOR_HOOKFUNCTION(weapon_models, Ent_Init, CBC_ORDER_LAST)
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
}

#endif

#ifndef MENUQC
MUTATOR_HOOKFUNCTION(weapon_models, WeaponModel)
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
		string themdl = sprintf("models/weapons_%s/%s", override, M_ARGV(0, string));
		if(fexists(themdl))
			M_ARGV(1, string) = themdl;
	}
}
#endif
