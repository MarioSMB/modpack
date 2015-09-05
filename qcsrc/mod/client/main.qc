REGISTER_MUTATOR(mutator_mod, cvar("g_mod"));

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString) {
    ret_string = strcat(ret_string, ":mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsPrettyString) {
    ret_string = strcat(ret_string, ", Mod");
}
