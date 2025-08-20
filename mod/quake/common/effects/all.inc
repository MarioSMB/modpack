// Global list of effects, networked to CSQC by ID to save bandwidth and to use client particle numbers (allows mismatching effectinfos to some degree)
// Not too concerned about the order of this list, just keep the weapon effects together!

#ifdef CSQC
// NOTE: this is likely to break in the future as it makes use of a normally unusable flag to register saved cvars!
const int CF_ARCHIVE = BIT(5);
float registercvar_saved(string name, string value, float flags) = #93;

void effect_cvar(string name, string value)
{
	registercvar_saved(strcat("cl_particle_", name), value, 0);
}
#endif

// EFFECT(istrail, EFFECT_NAME,     "effectinfo_string")
EFFECT(0, EXPLOSION_SMALL,          "explosion_small")
EFFECT(0, EXPLOSION_MEDIUM,         "explosion_medium")
EFFECT(0, EXPLOSION_BIG,            "explosion_big")

EFFECT(0, EXPLOSION,                "TE_EXPLOSION")

EFFECT(0, SMOKE_SMALL,              "smoke_small")
EFFECT(0, SMOKE_LARGE,              "smoke_large")

EFFECT(0, SMOKE_RING,               "smoke_ring")

//EFFECT(0, FLAMER,                   "flamethrower")
EFFECT(0, EF_FLAME,                 "EF_FLAME")
EFFECT(0, EF_STARDUST,              "EF_STARDUST")
EFFECT(0, TE_EXPLOSION,             "TE_EXPLOSION")
EFFECT(1, TR_NEXUIZPLASMA,          "TR_NEXUIZPLASMA")
EFFECT(1, TR_CRYLINKPLASMA,         "TR_CRYLINKPLASMA")
EFFECT(1, TR_ROCKET,                "TR_ROCKET")
EFFECT(1, TR_GRENADE,               "TR_GRENADE")
EFFECT(1, TR_BLOOD,                 "TR_BLOOD")
EFFECT(1, TR_WIZSPIKE,              "TR_WIZSPIKE")
EFFECT(1, TR_SLIGHTBLOOD,           "TR_SLIGHTBLOOD")
EFFECT(1, TR_KNIGHTSPIKE,           "TR_KNIGHTSPIKE")
EFFECT(1, TR_VORESPIKE,             "TR_VORESPIKE")

EFFECT(0, RUNE_PUFF_RED,            "spawn_point_red")
EFFECT(0, RUNE_PUFF_BLUE,           "spawn_point_blue")
EFFECT(0, RUNE_CYCLONE,             "respawn_ghost")
EFFECT(0, RUNE_HEAL,                "healing_fx")
EFFECT(0, RUNE_FROST_REGEN,         "ammoregen_fx")
EFFECT(0, RUNE_METEOR_IMPACT,       "laser_impact")

EFFECT(0, MAYO_SMASH,               "iceorglass")
EFFECT(0, BROWN_NOTE,               "smoke_large")

EFFECT(1, QCC_BLOODTRAIL,           "red_pass")
EFFECT(0, QCC_HEALING,              "cherryblossom")
EFFECT(0, QCC_GIB,                  "particlegibs_damage_dissolve")
EFFECT(0, QCC_MUSHROOM,             "spawn_point_yellow")

EFFECT(0, OTAMATONE_FIRE,           "arc_smoke")

EFFECT(0, ELECTRIFY,                "arc_lightning")

EFFECT(0, ENDERMAN,                 "spawn_point_pink")
EFFECT(0, ENDERMAN_ANGRY,           "spawn_point_neutral")
EFFECT(1, GUARDIAN_BEAM,            "nex_beam")

//EFFECT(0, MAGIC_FIRE,               "hagar_explode")

EFFECT(0, LAVANAIL_PUFF,            "lavanail_puff")
#ifdef CSQC
STATIC_INIT(Effect_LAVANAIL_PUFF)
{
	effect_cvar("lavanail_puff", "smoke");
	effect_cvar("lavanail_puff_smoke_type", "alphastatic");
	effect_cvar("lavanail_puff_smoke_alpha", "256 256 256");
	effect_cvar("lavanail_puff_smoke_color", "0x696969 0xffffff");
	effect_cvar("lavanail_puff_smoke_count", "8");
	effect_cvar("lavanail_puff_smoke_gravity", "-0.050000");
	effect_cvar("lavanail_puff_smoke_size", "1 3");
	effect_cvar("lavanail_puff_smoke_tex", "0 3");
	effect_cvar("lavanail_puff_smoke_velocityjitter", "16 16 16");
	effect_cvar("lavanail_puff_smoke_airfriction", "2");
}
#endif

EFFECT(0, SUPERCHICKEN_DIE,         "superchicken_die")
#ifdef CSQC
STATIC_INIT(Effect_SUPERCHICKEN_DIE)
{
	effect_cvar("superchicken_die", "feathers");
	effect_cvar("superchicken_die_feathers_type", "smoke");
	effect_cvar("superchicken_die_feathers_alpha", "256 256 128");
	effect_cvar("superchicken_die_feathers_color", "0xfffffff 0xffffff");
	effect_cvar("superchicken_die_feathers_count", "512");
	effect_cvar("superchicken_die_feathers_gravity", "0.050000");
	effect_cvar("superchicken_die_feathers_size", "2 6");
	effect_cvar("superchicken_die_feathers_tex", "41 42");
	effect_cvar("superchicken_die_feathers_velocityjitter", "300 300 300");
	effect_cvar("superchicken_die_feathers_airfriction", "2");
	effect_cvar("superchicken_die_feathers_bounce", "1");
}
#endif

EFFECT(0, CHICKEN_DIE,         "chicken_die")
#ifdef CSQC
STATIC_INIT(Effect_CHICKEN_DIE)
{
	effect_cvar("chicken_die", "feathers");
	effect_cvar("chicken_die_feathers_type", "smoke");
	effect_cvar("chicken_die_feathers_alpha", "256 256 128");
	effect_cvar("chicken_die_feathers_color", "0xfffffff 0xffffff");
	effect_cvar("chicken_die_feathers_count", "128");
	effect_cvar("chicken_die_feathers_gravity", "0.050000");
	effect_cvar("chicken_die_feathers_size", "2 6");
	effect_cvar("chicken_die_feathers_tex", "41 42");
	effect_cvar("chicken_die_feathers_velocityjitter", "150 150 150");
	effect_cvar("chicken_die_feathers_airfriction", "2");
	effect_cvar("chicken_die_feathers_bounce", "1");
}
#endif

EFFECT(0, ARMAGON_SHOCKWAVE,         "armagon_shockwave")
#ifdef CSQC
STATIC_INIT(Effect_ARMAGON_SHOCKWAVE)
{
	effect_cvar("armagon_shockwave", "smoke");
	effect_cvar("armagon_shockwave_smoke_type", "alphastatic");
	effect_cvar("armagon_shockwave_smoke_alpha", "256 256 1024");
	effect_cvar("armagon_shockwave_smoke_color", "0x696969 0xffffff");
	effect_cvar("armagon_shockwave_smoke_count", "8");
	effect_cvar("armagon_shockwave_smoke_gravity", "-0.050000");
	effect_cvar("armagon_shockwave_smoke_size", "4 12");
	effect_cvar("armagon_shockwave_smoke_tex", "0 3");
	effect_cvar("armagon_shockwave_smoke_velocityjitter", "16 16 16");
	effect_cvar("armagon_shockwave_smoke_airfriction", "2");
}
#endif

EFFECT(0, POOP_STINK,               "poop_stink")
#ifdef CSQC
STATIC_INIT(Effect_POOP_STINK)
{
	effect_cvar("poop_stink", "cloud");
	effect_cvar("poop_stink_cloud_type", "smoke");
	effect_cvar("poop_stink_cloud_airfriction", "1");
	effect_cvar("poop_stink_cloud_alpha", "256 256 128");
	effect_cvar("poop_stink_cloud_bounce", "1.500000");
	effect_cvar("poop_stink_cloud_color", "0x00ff00 0x7db843");
	effect_cvar("poop_stink_cloud_count", "0.5");
	effect_cvar("poop_stink_cloud_gravity", "-0.010000");
	effect_cvar("poop_stink_cloud_originjitter", "15 15 20");
	effect_cvar("poop_stink_cloud_sizeincrease", "10");
	effect_cvar("poop_stink_cloud_size", "1 1");
	effect_cvar("poop_stink_cloud_tex", "0 8");
	effect_cvar("poop_stink_cloud_velocityjitter", "5 5 5");
}
#endif

// effect handled by code
EFFECT(0, NUKE_EXPLODE,             "nuke_explode")
#ifdef CSQC
STATIC_INIT(Effect_NUKE_EXPLODE)
{
	effect_cvar("nuke_explode", "fire fire2 smoke smoke2 jet1 jet2 jet3 jet4 jet5 bubbles shockwave sparks sparks2 debris");

	effect_cvar("nuke_explode_fire_type", "static");
	effect_cvar("nuke_explode_fire_airfriction", "8");
	effect_cvar("nuke_explode_fire_alpha", "200 256 60");
	effect_cvar("nuke_explode_fire_bounce", "1.500000");
	effect_cvar("nuke_explode_fire_color", "0x8f0d00 0xff5a00");
	effect_cvar("nuke_explode_fire_count", "32");
	effect_cvar("nuke_explode_fire_gravity", "-0.220000");
	effect_cvar("nuke_explode_fire_liquidfriction", "8");
	effect_cvar("nuke_explode_fire_notunderwater", "1");
	effect_cvar("nuke_explode_fire_originjitter", "8 8 8");
	effect_cvar("nuke_explode_fire_sizeincrease", "45");
	effect_cvar("nuke_explode_fire_size", "60 120");
	effect_cvar("nuke_explode_fire_tex", "48 55");
	effect_cvar("nuke_explode_fire_velocityjitter", "512 512 768");
	effect_cvar("nuke_explode_fire_originoffset", "0 0 300");
	effect_cvar("nuke_explode_fire_delayspawn", "0.6");

	effect_cvar("nuke_explode_fire2_type", "smoke");
	effect_cvar("nuke_explode_fire2_airfriction", "19");
	effect_cvar("nuke_explode_fire2_alpha", "200 256 70");
	effect_cvar("nuke_explode_fire2_bounce", "2.500000");
	effect_cvar("nuke_explode_fire2_color", "0xea691b 0xeed05a");
	effect_cvar("nuke_explode_fire2_count", "14");
	effect_cvar("nuke_explode_fire2_gravity", "-0.220000");
	effect_cvar("nuke_explode_fire2_liquidfriction", "19");
	effect_cvar("nuke_explode_fire2_notunderwater", "1");
	effect_cvar("nuke_explode_fire2_originjitter", "8 8 8");
	effect_cvar("nuke_explode_fire2_sizeincrease", "-16");
	effect_cvar("nuke_explode_fire2_size", "50 110");
	effect_cvar("nuke_explode_fire2_tex", "48 55");
	effect_cvar("nuke_explode_fire2_velocityjitter", "912 912 2000");
	effect_cvar("nuke_explode_fire2_originoffset", "0 0 300");
	effect_cvar("nuke_explode_fire2_delayspawn", "0.6");

	effect_cvar("nuke_explode_smoke_type", "alphastatic");
	effect_cvar("nuke_explode_smoke_airfriction", "5");
	effect_cvar("nuke_explode_smoke_alpha", "200 450 75");
	effect_cvar("nuke_explode_smoke_bounce", "2");
	effect_cvar("nuke_explode_smoke_color", "0x000000 0x111111");
	effect_cvar("nuke_explode_smoke_count", "32");
	effect_cvar("nuke_explode_smoke_gravity", "-0.220000");
	effect_cvar("nuke_explode_smoke_notunderwater", "1");
	effect_cvar("nuke_explode_smoke_sizeincrease", "44");
	effect_cvar("nuke_explode_smoke_size", "40 100");
	effect_cvar("nuke_explode_smoke_tex", "0 8");
	effect_cvar("nuke_explode_smoke_velocityjitter", "444 444 444");
	effect_cvar("nuke_explode_smoke_originoffset", "0 0 300");
	effect_cvar("nuke_explode_smoke_delayspawn", "0.6");

	effect_cvar("nuke_explode_smoke2_type", "alphastatic");
	effect_cvar("nuke_explode_smoke2_airfriction", "5");
	effect_cvar("nuke_explode_smoke2_alpha", "200 450 75");
	effect_cvar("nuke_explode_smoke2_bounce", "2");
	effect_cvar("nuke_explode_smoke2_color", "0x696969 0x111111");
	effect_cvar("nuke_explode_smoke2_count", "32");
	effect_cvar("nuke_explode_smoke2_sizeincrease", "44");
	effect_cvar("nuke_explode_smoke2_size", "20 60");
	effect_cvar("nuke_explode_smoke2_tex", "0 8");
	effect_cvar("nuke_explode_smoke2_velocityjitter", "444 444 444");
	effect_cvar("nuke_explode_smoke2_originoffset", "0 0 300");
	effect_cvar("nuke_explode_smoke2_delayspawn", "0.6");

	effect_cvar("nuke_explode_jet1_type", "smoke");
	effect_cvar("nuke_explode_jet1_airfriction", "1.600000");
	effect_cvar("nuke_explode_jet1_alpha", "50 256 40");
	effect_cvar("nuke_explode_jet1_bounce", "1.500000");
	effect_cvar("nuke_explode_jet1_color", "0x8f0d00 0xff5a00");
	effect_cvar("nuke_explode_jet1_count", "30");
	effect_cvar("nuke_explode_jet1_gravity", "-0.020000");
	effect_cvar("nuke_explode_jet1_sizeincrease", "2");
	effect_cvar("nuke_explode_jet1_size", "8 20");
	effect_cvar("nuke_explode_jet1_tex", "48 55");
	effect_cvar("nuke_explode_jet1_velocityjitter", "40 40 800");
	effect_cvar("nuke_explode_jet1_velocitymultiplier", "30");

	effect_cvar("nuke_explode_jet2_type", "smoke");
	effect_cvar("nuke_explode_jet2_airfriction", "1.600000");
	effect_cvar("nuke_explode_jet2_alpha", "50 256 40");
	effect_cvar("nuke_explode_jet2_bounce", "1.500000");
	effect_cvar("nuke_explode_jet2_color", "0x8f0d00 0xff5a00");
	effect_cvar("nuke_explode_jet2_count", "25");
	effect_cvar("nuke_explode_jet2_gravity", "-0.020000");
	effect_cvar("nuke_explode_jet2_sizeincrease", "2");
	effect_cvar("nuke_explode_jet2_size", "8 20");
	effect_cvar("nuke_explode_jet2_tex", "48 55");
	effect_cvar("nuke_explode_jet2_velocityjitter", "40 40 600");
	effect_cvar("nuke_explode_jet2_velocitymultiplier", "20");

	effect_cvar("nuke_explode_jet3_type", "smoke");
	effect_cvar("nuke_explode_jet3_airfriction", "1.300000");
	effect_cvar("nuke_explode_jet3_alpha", "50 256 40");
	effect_cvar("nuke_explode_jet3_bounce", "1.500000");
	effect_cvar("nuke_explode_jet3_color", "0x8f0d00 0xff5a00");
	effect_cvar("nuke_explode_jet3_count", "15");
	effect_cvar("nuke_explode_jet3_gravity", "-0.020000");
	effect_cvar("nuke_explode_jet3_sizeincrease", "4");
	effect_cvar("nuke_explode_jet3_size", "8 20");
	effect_cvar("nuke_explode_jet3_tex", "48 55");
	effect_cvar("nuke_explode_jet3_velocityjitter", "30 30 500");
	effect_cvar("nuke_explode_jet3_velocitymultiplier", "10");

	effect_cvar("nuke_explode_jet4_type", "smoke");
	effect_cvar("nuke_explode_jet4_airfriction", "1.300000");
	effect_cvar("nuke_explode_jet4_alpha", "50 256 40");
	effect_cvar("nuke_explode_jet4_bounce", "1.500000");
	effect_cvar("nuke_explode_jet4_color", "0x8f0d00 0xff5a00");
	effect_cvar("nuke_explode_jet4_count", "20");
	effect_cvar("nuke_explode_jet4_gravity", "-0.020000");
	effect_cvar("nuke_explode_jet4_sizeincrease", "-10");
	effect_cvar("nuke_explode_jet4_size", "20 30");
	effect_cvar("nuke_explode_jet4_tex", "48 55");
	effect_cvar("nuke_explode_jet4_velocityjitter", "10 10 100");
	effect_cvar("nuke_explode_jet4_velocitymultiplier", "15");

	effect_cvar("nuke_explode_jet5_type", "alphastatic");
	effect_cvar("nuke_explode_jet5_airfriction", "1");
	effect_cvar("nuke_explode_jet5_alpha", "256 512 70");
	effect_cvar("nuke_explode_jet5_color", "0x000000 0x111111");
	effect_cvar("nuke_explode_jet5_count", "5");
	effect_cvar("nuke_explode_jet5_originjitter", "10 10 10");
	effect_cvar("nuke_explode_jet5_sizeincrease", "20");
	effect_cvar("nuke_explode_jet5_size", "5 15");
	effect_cvar("nuke_explode_jet5_tex", "0 8");
	effect_cvar("nuke_explode_jet5_velocitymultiplier", "5");
	effect_cvar("nuke_explode_jet5_velocityoffset", "0 0 10");
	effect_cvar("nuke_explode_jet5_rotate", "-4 4 -16 16");

	effect_cvar("nuke_explode_bubbles_type", "bubble");
	effect_cvar("nuke_explode_bubbles_alpha", "128 256 64");
	effect_cvar("nuke_explode_bubbles_bounce", "1.500000");
	effect_cvar("nuke_explode_bubbles_color", "0x404040 0x808080");
	effect_cvar("nuke_explode_bubbles_count", "32");
	effect_cvar("nuke_explode_bubbles_gravity", "-0.125000");
	effect_cvar("nuke_explode_bubbles_liquidfriction", "0.250000");
	effect_cvar("nuke_explode_bubbles_originjitter", "16 16 16");
	effect_cvar("nuke_explode_bubbles_size", "3 3");
	effect_cvar("nuke_explode_bubbles_tex", "62 62");
	effect_cvar("nuke_explode_bubbles_underwater", "1");
	effect_cvar("nuke_explode_bubbles_velocityjitter", "144 144 144");

	effect_cvar("nuke_explode_shockwave_airfriction", "0.5");
	effect_cvar("nuke_explode_shockwave_alpha", "256 512 70");
	effect_cvar("nuke_explode_shockwave_color", "0x000000 0x696969");
	effect_cvar("nuke_explode_shockwave_count", "512");
	effect_cvar("nuke_explode_shockwave_liquidfriction", "6");
	effect_cvar("nuke_explode_shockwave_size", "20 60 0");
	effect_cvar("nuke_explode_shockwave_sizeincrease", "40");
	effect_cvar("nuke_explode_shockwave_tex", "0 8 0");
	effect_cvar("nuke_explode_shockwave_type", "spark");
	effect_cvar("nuke_explode_shockwave_velocityjitter", "350 350 48");
	effect_cvar("nuke_explode_shockwave_delayspawn", "0.4");

	effect_cvar("nuke_explode_sparks_type", "spark");
	effect_cvar("nuke_explode_sparks_airfriction", "1");
	effect_cvar("nuke_explode_sparks_alpha", "644 956 484");
	effect_cvar("nuke_explode_sparks_bounce", "1.600000");
	effect_cvar("nuke_explode_sparks_color", "0xffa35b 0xfff2be");
	effect_cvar("nuke_explode_sparks_count", "16");
	effect_cvar("nuke_explode_sparks_gravity", "1");
	effect_cvar("nuke_explode_sparks_liquidfriction", "0.800000");
	effect_cvar("nuke_explode_sparks_notunderwater", "1");
	effect_cvar("nuke_explode_sparks_originjitter", "16 16 16");
	effect_cvar("nuke_explode_sparks_size", "1 0.100000");
	effect_cvar("nuke_explode_sparks_tex", "40 40");
	effect_cvar("nuke_explode_sparks_velocityjitter", "424 424 624");
	effect_cvar("nuke_explode_sparks_velocityoffset", "0 0 80");

	effect_cvar("nuke_explode_sparks2_airfriction", "1.5");
	effect_cvar("nuke_explode_sparks2_alpha", "256 256 70");
	effect_cvar("nuke_explode_sparks2_color_max", "1 0.5 0.12");
	effect_cvar("nuke_explode_sparks2_color_min", "0.5 0 0");
	effect_cvar("nuke_explode_sparks2_count", "128");
	effect_cvar("nuke_explode_sparks2_liquidfriction", "1.5");
	effect_cvar("nuke_explode_sparks2_size", "4 25 0");
	effect_cvar("nuke_explode_sparks2_tex", "8 15 0");
	effect_cvar("nuke_explode_sparks2_type", "static");
	effect_cvar("nuke_explode_sparks2_velocityjitter", "200 200 3");
	effect_cvar("nuke_explode_sparks2_originoffset", "0 0 100");
	effect_cvar("nuke_explode_sparks2_delayspawn", "0.35");

	effect_cvar("nuke_explode_debris_type", "alphastatic");
	effect_cvar("nuke_explode_debris_airfriction", "0.500000");
	effect_cvar("nuke_explode_debris_alpha", "644 956 684");
	effect_cvar("nuke_explode_debris_bounce", "1.600000");
	effect_cvar("nuke_explode_debris_color", "0x6a3d25 0xcac5b4");
	effect_cvar("nuke_explode_debris_count", "22");
	effect_cvar("nuke_explode_debris_gravity", "1.300000");
	effect_cvar("nuke_explode_debris_notunderwater", "1");
	effect_cvar("nuke_explode_debris_rotate", "-180 180 -1000 1000");
	effect_cvar("nuke_explode_debris_size", "2 6");
	effect_cvar("nuke_explode_debris_tex", "66 68");
	effect_cvar("nuke_explode_debris_velocityjitter", "324 324 524");
}
#endif
