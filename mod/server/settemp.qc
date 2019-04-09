string autocvar_settemp_for_type_all = "";

void parse_settemp(string thestr)
{
	if(thestr == "")
		return;

	for(string s = thestr; s != ""; s = cdr(s))
	{
		string sa = car(s);
		if(sa == "") continue;
		int p = strstrofs(sa, "=", 0);
		if(p < 0)
			continue;
		string k = substring(sa, 0, p);
		string v = substring(sa, p + 1, -1);
		_MapInfo_Parse_Settemp(mapname, MAPINFO_SETTEMP_ACL_USER, 0, cons(k, v), 1);
	}
}

ACCUMULATE void MapInfo_LoadMapSettings(string s)
{
	parse_settemp(autocvar_settemp_for_type_all);

	string thevar = strcat("settemp_for_type_", MapInfo_LoadedGametype.mdl);
	if(cvar_type(thevar) & CVAR_TYPEFLAG_EXISTS)
	{
		thevar = cvar_string(thevar);
		parse_settemp(thevar);
	}
}
