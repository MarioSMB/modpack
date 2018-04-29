//FEATURE: Options to replace any entity on maps

MUTATOR_HOOKFUNCTION(mutator_mod, SetModname)
{
	IL_EACH(g_spawn_queue, true,
	{
		entity ent = it;
		string myvar = strcat("sv_spawnreplace_", ent.__spawnfunc_classname);
		if(!(cvar_type(myvar) & CVAR_TYPEFLAG_EXISTS))
			continue;
		string thecvar = cvar_string(myvar);
		if(thecvar == "")
		{
			delete(it); // just attempt to remove it
			continue;
		}
		else
		{
			RandomSelection_Init();
			FOREACH_WORD(thecvar, true,
			{
				RandomSelection_AddString(it, 1, 1);
			});
			string thestring = RandomSelection_chosen_string;

			string myfunc = strcat("spawnfunc_", thestring);
			if(!isfunction(myfunc))
				continue; // no good, just allow?

			entity e = new(mock);
			__spawnfunc_expecting = true;
			__spawnfunc_expect = e; 
			callfunction(myfunc);
			void(entity) f = e.__spawnfunc_constructor; 
			delete(e); 
			ent.__spawnfunc_classname = strzone(thestring); // NOTE: zoned, but never unzoned
			ent.__spawnfunc_constructor = f;
		}
	});
}
