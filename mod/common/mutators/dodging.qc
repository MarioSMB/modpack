#ifdef SVQC

.bool cvar_cl_dodging;

REPLICATE(cvar_cl_dodging, bool, "cl_dodging");

ATTRIB(Client, cvar_cl_dodging, bool, this.cvar_cl_dodging);

REGISTER_MUTATOR(mod_dodging, cvar("g_dodging"));

MUTATOR_HOOKFUNCTION(mod_dodging, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	if(!CS(player).cvar_cl_dodging && cvar("g_dodging") >= 2)
		CS(player).cvar_cl_dodging_timeout = 0;
}

#elif defined(CSQC)

STATIC_INIT_LATE(mod_dodging_cvars)
{
	registercvar("cl_dodging", "1");
}

#endif
