#ifdef GAMEQC
REGISTER_MUTATOR(announcer, true);
#endif

#ifdef SVQC

AUTOCVAR(sv_announcer, string, "", "Force client announcer to this");

MUTATOR_HOOKFUNCTION(announcer, Ent_Init, CBC_ORDER_FIRST)
{
	WriteString(MSG_ONE, autocvar_sv_announcer);
}

#elif defined(CSQC)

string sv_announcer;

AUTOCVAR_SAVE(cl_announcer_force,                    bool,   false,      "Don't allow server to override default announcer");

void Announcer_Precache()
{
	FOREACH(Notifications, it.nent_type == MSG_ANNCE, {
		if(it.nent_enabled)
			precache_sound(sprintf("announcer/%s/%s.wav", AnnouncerOption(), it.nent_snd));
	});
}

MUTATOR_HOOKFUNCTION(announcer, AnnouncerOption)
{
	if(autocvar_cl_announcer_force || sv_announcer == "" || !sv_announcer || autocvar_cl_announcer != "default")
		return false;

	M_ARGV(0, string) = sv_announcer;
}

MUTATOR_HOOKFUNCTION(announcer, Ent_Init, CBC_ORDER_FIRST)
{
	sv_announcer = strzone(ReadString());

	if(sv_announcer != "" && sv_announcer) { Announcer_Precache(); }
}

#endif
