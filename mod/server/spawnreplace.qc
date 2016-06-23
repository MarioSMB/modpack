MUTATOR_HOOKFUNCTION(mutator_mod, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);
	string myvar = strcat("sv_spawnreplace_", ent.classname);
	if(cvar_type(myvar) & CVAR_TYPEFLAG_EXISTS)
	{
		string thecvar = cvar_string(myvar);
		if(thecvar == "")
			return true; // empty string means remove?
		else
			ent.classname = strzone(thecvar); // NOTE: zoned, but never unzoned
	}
}
