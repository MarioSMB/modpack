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
		{
			RandomSelection_Init();
			FOREACH_WORD(thecvar, true,
			{
				RandomSelection_AddString(it, 1, 1);
			});
			string thestring = RandomSelection_chosen_string;
			ent.classname = strzone(thestring); // NOTE: zoned, but never unzoned
		}
	}
}
