MUTATOR_HOOKFUNCTION(mod_BuildMutatorsString)
{
    ret_string = strcat(ret_string, ":mod");
    return false;
}

MUTATOR_HOOKFUNCTION(mod_BuildMutatorsPrettyString)
{
    ret_string = strcat(ret_string, ", Mod");
    return false;
}

MUTATOR_DECLARATION(mutator_mod);
MUTATOR_DEFINITION(mutator_mod)
{
    MUTATOR_HOOK(BuildMutatorsString, mod_BuildMutatorsString, CBC_ORDER_ANY);
    MUTATOR_HOOK(BuildMutatorsPrettyString, mod_BuildMutatorsPrettyString, CBC_ORDER_ANY);
    return false;
}

[[accumulate]]
void mutators_add()
{
    MUTATOR_ADD(mutator_mod);
}
