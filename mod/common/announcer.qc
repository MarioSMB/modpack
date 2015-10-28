#ifndef MENUQC
REGISTER_MUTATOR(announcer, true);

#ifdef SVQC

AUTOCVAR(sv_announcer, string, "", _("Force client announcer to this"));

MUTATOR_HOOKFUNCTION(announcer, Ent_Init, CBC_ORDER_LAST)
{
	WriteString(MSG_ENTITY, autocvar_sv_announcer);
	return false;
}

#elif defined(CSQC)

string sv_announcer;

AUTOCVAR_SAVE(cl_announcer_force,                    bool,   false,      _("Don't allow server to override default announcer"));

MUTATOR_HOOKFUNCTION(announcer, AnnouncerOption)
{
	if(autocvar_cl_announcer_force || sv_announcer == "" || autocvar_cl_announcer != "default")
		return false;

	ret_string = sv_announcer;
	return true;
}

MUTATOR_HOOKFUNCTION(announcer, Ent_Init, CBC_ORDER_LAST)
{
	sv_announcer = ReadString();
	return false;
}

#endif

#endif
