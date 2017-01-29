// with any luck, this is done early enough to take effect

STATIC_INIT(fix_weaponpriority)
{
	string curprio = cvar_string("cl_weaponpriority");

	bool have_flak = strhasword(curprio, "flak");
	bool have_axe = strhasword(curprio, "axe");
	bool have_lightsabre = strhasword(curprio, "lightsabre");
	bool have_chainsaw = strhasword(curprio, "chainsaw");
	bool have_uzi = strhasword(curprio, "mac10");

	// to save on rebuilding, only loop through if one of these is indeed missing
	if(!have_flak || !have_axe || !have_lightsabre || !have_chainsaw || !have_uzi)
	{
		string newprio = "";
		FOREACH_WORD(curprio, true,
		{
			newprio = strcat(newprio, it, " ");

			if(it == "hagar" && !have_flak)
				newprio = strcat(newprio, "flak ");
			if(it == "shotgun" && !have_axe)
				newprio = strcat(newprio, "axe ");
			if(it == "blaster" && !have_lightsabre)
				newprio = strcat(newprio, "lightsabre ");
			if(it == "elector" && !have_chainsaw)
				newprio = strcat(newprio, "chainsaw ");
			if(it == "machinegun" && !have_uzi)
				newprio = strcat(newprio, "mac10 ");
		});

		cvar_set("cl_weaponpriority", newprio);
	}
}
