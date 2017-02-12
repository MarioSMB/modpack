REGISTER_MUTATOR(mutator_mod, true);

string mod_translate_clean(string s)
{
	if(ColorTranslateMode & 1)
		return strdecolorize(s);

	if(s == "" || !s)
		return s;

	s = strreplace("^x666", "^1", s);
	s = strreplace("^x667", "^2", s);
	return s;
}

string mod_playername(entity p, bool team_colorize)
{
    if (team_colorize && teamplay && !intermission_running && IS_PLAYER(p))
    {
        string t = Team_ColorCode(p.team);
        return strcat(t, strdecolorize(p.netname));
    }
    else
        return mod_translate_clean(p.netname);
}

STATIC_INIT_LATE(mod_function_overrides)
{
	playername = mod_playername;
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString) {
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsPrettyString) {
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildGameplayTipsString, CBC_ORDER_LAST)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), "\n\n ^7Running the SMB mod pack\n^3https://github.com/MarioSMB/modpack");
}
