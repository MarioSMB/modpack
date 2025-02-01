REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString) {
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}

// we now show a proper message in the about page
//MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsPrettyString) {
//    M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Mod");
//}

MUTATOR_HOOKFUNCTION(mutator_mod, SetStartItems)
{
    if(start_items & IT_UNLIMITED_AMMO)
        start_ammo_fuel = 0;

    // as a safety precaution incase the team is stupid enough to merge
    // https://gitlab.com/xonotic/xonotic-data.pk3dir/-/commit/ebc9bad866577cdcff64233a15b34a646555fa1d
    // reset the cvar so the next update doesn't CRASH THE SERVER
    if(cvar_type("sv_version") & CVAR_TYPEFLAG_EXISTS)
        cvar_set("sv_version", "");
}
