#ifndef MENUQC
REGISTER_MUTATOR(announcer, true);
#endif

#ifdef SVQC

AUTOCVAR(sv_announcer, string, "", _("Force client announcer to this"));

MUTATOR_HOOKFUNCTION(announcer, Ent_Init, CBC_ORDER_FIRST)
{
	WriteString(MSG_ONE, autocvar_sv_announcer);
	return false;
}

#elif defined(CSQC)

string sv_announcer;

AUTOCVAR_SAVE(cl_announcer_force,                    bool,   false,      _("Don't allow server to override default announcer"));

void Announcer_Precache()
{
	for(int i = 0; i < NOTIF_ANNCE_MAX; ++i)
	{
		entity e = msg_annce_notifs[i];
		if(e.nent_enabled)
			precache_sound(sprintf("announcer/%s/%s.wav", AnnouncerOption(), e.nent_snd));
	}
}

MUTATOR_HOOKFUNCTION(announcer, AnnouncerOption)
{
	if(autocvar_cl_announcer_force || sv_announcer == "" || !sv_announcer || autocvar_cl_announcer != "default")
		return false;

	ret_string = sv_announcer;
	return false;
}

MUTATOR_HOOKFUNCTION(announcer, Ent_Init, CBC_ORDER_FIRST)
{
	sv_announcer = strzone(ReadString());

	if(sv_announcer != "" && sv_announcer) { Announcer_Precache(); }
	return false;
}

#endif
