REGISTER_MUTATOR(mutator_mod, true);

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
