REGISTER_MUTATOR(mutator_mod, cvar("g_mod"));

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString) {
    ret_string = strcat(ret_string, ":mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildGameplayTipsString, CBC_ORDER_LAST)
{
    ret_string = strcat(ret_string, "\n\n ^7Running the SMB mod pack\n^3https://github.com/MarioSMB/modpack");
}
