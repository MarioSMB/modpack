REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString) {
    ret_string = strcat(ret_string, ":mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsPrettyString) {
    ret_string = strcat(ret_string, ", Mod");
}

STATIC_INIT_LATE(CustomAssets_precache) {
    FOREACH(Models, true, LAMBDA({
        it.model_precache(it);
    }));
}
