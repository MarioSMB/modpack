AUTOCVAR_SAVE(cl_custommodel, string, "none", "Client model selection, available options: none, pony, goat, monk, nexus, robot");

STATIC_INIT(mod_cpmodels)
{
	registercvar("cl_pony_skin", "0");
	registercvar("cl_sparkle", "0");

	localcmd("\nalias cl_model \"seta cl_custommodel ${* ?}; sendcvar cl_custommodel\"\n");
	if(autocvar_cl_custommodel == "none" || autocvar_cl_custommodel == "0")
		return;

	if((cvar_type("cl_pony") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_pony"))
		cvar_set("cl_custommodel", "pony");
	if((cvar_type("cl_goat") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_goat"))
		cvar_set("cl_custommodel", "goat");
	if((cvar_type("cl_monk") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_monk"))
		cvar_set("cl_custommodel", "monk");
	if((cvar_type("cl_nexus") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_nexus"))
		cvar_set("cl_custommodel", "nexus");
	if((cvar_type("cl_robot") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_robot"))
		cvar_set("cl_custommodel", "robot");
	if((cvar_type("cl_brothersbear") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_brothersbear"))
		cvar_set("cl_custommodel", "bear");
	if((cvar_type("cl_thestars") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_thestars"))
		cvar_set("cl_custommodel", "rosalina");
	if((cvar_type("cl_damnfurries") & CVAR_TYPEFLAG_EXISTS) && cvar("cl_damnfurries"))
		cvar_set("cl_custommodel", "foxy");
}

MUTATOR_HOOKFUNCTION(mutator_mod, ForcePlayermodels_Skip)
{
	entity player = M_ARGV(0, entity);
	if(player.model == "models/player/goat.dpm" || player.model == "models/player/po.dpm" || player.model == "models/player/dipsy.dpm" || player.model == "models/player/laalaa.dpm" || player.model == "models/player/tinkywinky.dpm")
		return true;
	return false;
}
