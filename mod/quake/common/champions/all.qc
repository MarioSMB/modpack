#include "all.qh"

#ifdef GAMEQC
REPLICATE(cvar_cl_quake_model, string, "cl_quake_model");
#endif

Champions Champion_FromString(string champ)
{
	FOREACH(Champion, it.netname == champ, return it);
	return CHAMPION_Ranger;
}

#ifdef CSQC
STATIC_INIT_LATE(ChampionsFixModel)
{
	if(autocvar_cl_quake_model == "")
	{
		cvar_set("cl_quake_model", (random() < 0.5) ? "katria" : "ranger");
	}
}
#endif
