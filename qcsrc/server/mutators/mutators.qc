void mutators_add()
{
	#define CHECK_MUTATOR_ADD(mut_cvar,mut_name,dependence) \
		{ if(cvar(mut_cvar) && dependence) { MUTATOR_ADD(mut_name); } }

	CHECK_MUTATOR_ADD("g_dodging", mutator_dodging, 1);
	CHECK_MUTATOR_ADD("g_spawn_near_teammate", mutator_spawn_near_teammate, teamplay);
	CHECK_MUTATOR_ADD("g_physical_items", mutator_physical_items, 1);
	CHECK_MUTATOR_ADD("g_touchexplode", mutator_touchexplode, 1);
	CHECK_MUTATOR_ADD("g_minstagib", mutator_minstagib, 1);
	CHECK_MUTATOR_ADD("g_invincible_projectiles", mutator_invincibleprojectiles, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_new_toys", mutator_new_toys, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_nix", mutator_nix, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_rocket_flying", mutator_rocketflying, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_vampire", mutator_vampire, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_superspectate", mutator_superspec, 1);
	CHECK_MUTATOR_ADD("g_freeze", mutator_freeze, !g_freezetag && !g_ca);
	CHECK_MUTATOR_ADD("g_pinata", mutator_pinata, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_midair", mutator_midair, 1);
	CHECK_MUTATOR_ADD("g_bloodloss", mutator_bloodloss, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_random_gravity", mutator_random_gravity, 1);
	CHECK_MUTATOR_ADD("g_multijump", mutator_multijump, 1);
	CHECK_MUTATOR_ADD("g_melee_only", mutator_melee_only, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_nades", mutator_nades, 1);
	CHECK_MUTATOR_ADD("g_sandbox", sandbox, 1);
	CHECK_MUTATOR_ADD("g_riflearena", mutator_riflearena, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_campcheck", mutator_campcheck, 1);
	CHECK_MUTATOR_ADD("g_overkill", mutator_overkill, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_za", mutator_zombie_apocalypse, cvar("g_monsters"));
	CHECK_MUTATOR_ADD("g_walljump", mutator_walljump, 1);
	CHECK_MUTATOR_ADD("g_hats", mutator_hats, !cvar("g_overkill"));
	CHECK_MUTATOR_ADD("g_status_effects", mutator_status_effects, !cvar("g_minstagib"));

	#undef CHECK_MUTATOR_ADD
}
