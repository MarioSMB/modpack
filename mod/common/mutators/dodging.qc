#ifdef SVQC

.bool cvar_cl_dodging;

MUTATOR_HOOKFUNCTION(mutator_mod, GetCvars, CBC_ORDER_LAST)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_dodging, "cl_dodging");

	if(!self.cvar_cl_dodging)
		self.cvar_cl_dodging_timeout = 0;

	return false;
}

#elif defined(CSQC)

STATIC_INIT(mod_dodging_cvars)
{
	registercvar("cl_dodging", "0");
}

#endif
