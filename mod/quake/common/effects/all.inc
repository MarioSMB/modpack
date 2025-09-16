// Global list of effects, networked to CSQC by ID to save bandwidth and to use client particle numbers (allows mismatching effectinfos to some degree)
// Not too concerned about the order of this list, just keep the weapon effects together!

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
#ifdef CSQC
STATIC_INIT(Effect_TR_WIZSPIKE)
{
	registercvar("cl_particle_TR_WIZSPIKE", "smoke trail");

	registercvar("cl_particle_TR_WIZSPIKE_smoke_trailspacing", "1");
	registercvar("cl_particle_TR_WIZSPIKE_smoke_type", "smoke");
	registercvar("cl_particle_TR_WIZSPIKE_smoke_color", "0x433700 0xbba70f");
	registercvar("cl_particle_TR_WIZSPIKE_smoke_tex", "24 32");
	registercvar("cl_particle_TR_WIZSPIKE_smoke_size", "0.1 0.2");
	registercvar("cl_particle_TR_WIZSPIKE_smoke_sizeincrease", "4");
	registercvar("cl_particle_TR_WIZSPIKE_smoke_velocityjitter", "16 16 16");
	registercvar("cl_particle_TR_WIZSPIKE_smoke_rotate", "0 360 0 30");

	registercvar("cl_particle_TR_WIZSPIKE_trail_trailspacing", "2");
	registercvar("cl_particle_TR_WIZSPIKE_trail_type", "static");
	registercvar("cl_particle_TR_WIZSPIKE_trail_color", "0x101010 0x6b6b0f");
	registercvar("cl_particle_TR_WIZSPIKE_trail_tex", "0 8");
	registercvar("cl_particle_TR_WIZSPIKE_trail_size", "1 3");
	registercvar("cl_particle_TR_WIZSPIKE_trail_sizeincrease", "3");
	registercvar("cl_particle_TR_WIZSPIKE_trail_alpha", "16 128 128");
	registercvar("cl_particle_TR_WIZSPIKE_trail_velocityjitter", "16 16 16");
	registercvar("cl_particle_TR_WIZSPIKE_trail_originjitter", "4 4 4");
	registercvar("cl_particle_TR_WIZSPIKE_trail_gravity", "-0.05");
	registercvar("cl_particle_TR_WIZSPIKE_trail_rotate", "0 360 0 30");
}
#endif

EFFECT(1, TR_SLIGHTBLOOD,           "TR_SLIGHTBLOOD")
EFFECT(1, TR_KNIGHTSPIKE,           "TR_KNIGHTSPIKE")
#ifdef CSQC
STATIC_INIT(Effect_TR_KNIGHTSPIKE)
{
	registercvar("cl_particle_TR_KNIGHTSPIKE", "sparks trail flame bubbles");

	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_notunderwater", "1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_trailspacing", "4");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_count", "1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_type", "snow");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_color", "0x7f1707 0xe7ab5f");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_size", "1 1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_sizeincrease", "-1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_gravity", "0");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_time", "0.5 1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_velocityjitter", "16 16 16");
	registercvar("cl_particle_TR_KNIGHTSPIKE_sparks_originjitter", "4 4 4");

	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_notunderwater", "1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_count", "1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_type", "spark");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_color", "0xFFAB57 0xFF0A0A");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_stretchfactor", "0");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_size", "1 2");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_alpha", "64 256 160");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_gravity", "0.3");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_bounce", "1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_airfriction", "0.5");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_gravity", "0.05");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_liquidfriction", "5");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_originjitter", "0 0 0");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_velocityjitter", "50 50 50");
	registercvar("cl_particle_TR_KNIGHTSPIKE_trail_rotate", "0 360 1000 1000");

	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_trailspacing", "3");
	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_type", "static");
	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_color", "0x801010 0xFFA020");
	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_size", "5 1");
	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_alpha", "10 20 15");
	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_velocityjitter", "25 25 25");
	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_airfriction", "3");
	registercvar("cl_particle_TR_KNIGHTSPIKE_flame_liquidfriction", "3");

	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_trailspacing", "9");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_type", "bubble");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_tex", "62 62");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_color", "0x404040 0x808080");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_size", "2 2");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_alpha", "64 256 128");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_gravity", "-0.125");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_bounce", "1.5");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_liquidfriction", "0.25");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_originjitter", "16 16 16");
	registercvar("cl_particle_TR_KNIGHTSPIKE_bubbles_velocityjitter", "96 96 96");
}
#endif
EFFECT(1, TR_VORESPIKE,             "TR_VORESPIKE")
#ifdef CSQC
STATIC_INIT(Effect_TR_VORESPIKE)
{
	registercvar("cl_particle_TR_VORESPIKE", "light trail sparks smoke");

	registercvar("cl_particle_TR_VORESPIKE_light_lightradius", "64");
	registercvar("cl_particle_TR_VORESPIKE_light_lighttime", "0");
	registercvar("cl_particle_TR_VORESPIKE_light_lightcolor", "0.3 0.1 0.2");

	registercvar("cl_particle_TR_VORESPIKE_trail_trailspacing", "1");
	registercvar("cl_particle_TR_VORESPIKE_trail_count", "1");
	registercvar("cl_particle_TR_VORESPIKE_trail_type", "snow");
	registercvar("cl_particle_TR_VORESPIKE_trail_tex", "33 33");
	registercvar("cl_particle_TR_VORESPIKE_trail_color", "0x502030 0x502030");
	registercvar("cl_particle_TR_VORESPIKE_trail_size", "1 2");
	registercvar("cl_particle_TR_VORESPIKE_trail_sizeincrease", "-1");
	registercvar("cl_particle_TR_VORESPIKE_trail_gravity", "0");
	registercvar("cl_particle_TR_VORESPIKE_trail_time", "0.5 2");
	registercvar("cl_particle_TR_VORESPIKE_trail_velocityjitter", "16 16 16");
	registercvar("cl_particle_TR_VORESPIKE_trail_originjitter", "4 4 4");

	registercvar("cl_particle_TR_VORESPIKE_sparks_trailspacing", "1");
	registercvar("cl_particle_TR_VORESPIKE_sparks_type", "spark");
	registercvar("cl_particle_TR_VORESPIKE_sparks_tex", "33 33");
	registercvar("cl_particle_TR_VORESPIKE_sparks_stretchfactor", "0.25");
	registercvar("cl_particle_TR_VORESPIKE_sparks_color", "0x502030 0x502030");
	registercvar("cl_particle_TR_VORESPIKE_sparks_size", "0.5 1.0");
	registercvar("cl_particle_TR_VORESPIKE_sparks_alpha", "192 256 1024");
	registercvar("cl_particle_TR_VORESPIKE_sparks_gravity", "0.05");
	registercvar("cl_particle_TR_VORESPIKE_sparks_originjitter", "8 8 8");
	registercvar("cl_particle_TR_VORESPIKE_sparks_velocityjitter", "56 56 56");

	registercvar("cl_particle_TR_VORESPIKE_smoke_trailspacing", "3");
	registercvar("cl_particle_TR_VORESPIKE_smoke_type", "smoke");
	registercvar("cl_particle_TR_VORESPIKE_smoke_color", "0x502030 0x502030");
	registercvar("cl_particle_TR_VORESPIKE_smoke_size", "5 10");
	registercvar("cl_particle_TR_VORESPIKE_smoke_alpha", "10 20 15");
	registercvar("cl_particle_TR_VORESPIKE_smoke_velocityjitter", "25 25 25");
	registercvar("cl_particle_TR_VORESPIKE_smoke_airfriction", "3");
	registercvar("cl_particle_TR_VORESPIKE_smoke_liquidfriction", "3");
}
#endif

EFFECT(0, TE_KNIGHTSPIKE,           "TE_KNIGHTSPIKE")
#ifdef CSQC
STATIC_INIT(Effect_TE_KNIGHTSPIKE)
{
	registercvar("cl_particle_TE_KNIGHTSPIKE", "decal light sparks boom flame bubbles");

	registercvar("cl_particle_TE_KNIGHTSPIKE_decal_countabsolute", "1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_decal_type", "decal");
	registercvar("cl_particle_TE_KNIGHTSPIKE_decal_tex", "0 8");
	registercvar("cl_particle_TE_KNIGHTSPIKE_decal_size", "3 9");
	registercvar("cl_particle_TE_KNIGHTSPIKE_decal_alpha", "32 96 0");
	registercvar("cl_particle_TE_KNIGHTSPIKE_decal_originjitter", "6 6 6");

	registercvar("cl_particle_TE_KNIGHTSPIKE_light_countabsolute", "1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_light_type", "decal");
	registercvar("cl_particle_TE_KNIGHTSPIKE_light_size", "1 6");
	registercvar("cl_particle_TE_KNIGHTSPIKE_light_alpha", "1024 1024 0");
	registercvar("cl_particle_TE_KNIGHTSPIKE_light_lightradius", "64");
	registercvar("cl_particle_TE_KNIGHTSPIKE_light_lightradiusfade", "64");
	registercvar("cl_particle_TE_KNIGHTSPIKE_light_lightshadow", "0");
	registercvar("cl_particle_TE_KNIGHTSPIKE_light_lightcolor", "1 0.75 0");

	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_tex", "0 8");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_notunderwater", "1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_count", "512");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_type", "alphastatic");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_color", "0x903010 0xFFD030");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_size", "1 6");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_alpha", "0 128 512");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_gravity", "-0.1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_airfriction", "6");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_velocityoffset", "0 0 32");
	registercvar("cl_particle_TE_KNIGHTSPIKE_sparks_velocityjitter", "384 384 384");

	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_tex", "0 8");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_notunderwater", "1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_count", "512");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_type", "static");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_color", "0x903010 0xFFD030");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_size", "0.1 0.2");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_alpha", "0 256 256");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_gravity", "0.1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_airfriction", "6");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_liquidfriction", "12");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_velocityoffset", "0 0 32");
	registercvar("cl_particle_TE_KNIGHTSPIKE_boom_velocityjitter", "162 162 162");

	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_tex", "0 8");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_count", "16");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_type", "smoke");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_color", "0x903010 0xFFD030");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_size", "6 8");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_alpha", "64 128 128");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_gravity", "-0.05");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_liquidfriction", "1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_originjitter", "16 16 16");
	registercvar("cl_particle_TE_KNIGHTSPIKE_flame_velocityjitter", "16 16 16");

	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_underwater", "1");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_count", "64");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_type", "bubble");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_tex", "62 62");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_color", "0x404040 0x808080");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_size", "2 2");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_alpha", "64 256 128");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_gravity", "-0.125");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_bounce", "1.5");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_liquidfriction", "0.25");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_originjitter", "8 8 8");
	registercvar("cl_particle_TE_KNIGHTSPIKE_bubbles_velocityjitter", "64 64 64");
}
#endif

EFFECT(0, TE_WIZSPIKE,           "TE_WIZSPIKE")
#ifdef CSQC
STATIC_INIT(Effect_TE_WIZSPIKE)
{
	registercvar("cl_particle_TE_WIZSPIKE", "flash bubbles");

	registercvar("cl_particle_TE_WIZSPIKE_flash_notunderwater", "1");
	registercvar("cl_particle_TE_WIZSPIKE_flash_count", "8");
	registercvar("cl_particle_TE_WIZSPIKE_flash_type", "static");
	registercvar("cl_particle_TE_WIZSPIKE_flash_tex", "24 32");
	registercvar("cl_particle_TE_WIZSPIKE_flash_color", "0x6fff00 0xfdff00");
	registercvar("cl_particle_TE_WIZSPIKE_flash_alpha", "32 128 256");
	registercvar("cl_particle_TE_WIZSPIKE_flash_originjitter", "8 8 8");
	registercvar("cl_particle_TE_WIZSPIKE_flash_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_WIZSPIKE_flash_size", "6 10");
	registercvar("cl_particle_TE_WIZSPIKE_flash_gravity", "1");
	registercvar("cl_particle_TE_WIZSPIKE_flash_bounce", "1");
	registercvar("cl_particle_TE_WIZSPIKE_flash_sizeincrease", "2");
	registercvar("cl_particle_TE_WIZSPIKE_flash_liquidfriction", "10");
	registercvar("cl_particle_TE_WIZSPIKE_flash_lightradius", "128");
	registercvar("cl_particle_TE_WIZSPIKE_flash_lightradiusfade", "192");
	registercvar("cl_particle_TE_WIZSPIKE_flash_lightcolor", "0.4 1 0");

	registercvar("cl_particle_TE_WIZSPIKE_bubbles_underwater", "1");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_count", "16");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_tex", "24 32");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_blend", "invmod");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_type", "static");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_color", "0x6fff00 0xfdff00");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_alpha", "32 128 128");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_originjitter", "4 4 4");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_velocityoffset", "0 0 20");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_size", ".1 .1");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_bounce", "1");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_sizeincrease", "10");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_liquidfriction", "10");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_lightradius", "128");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_lightradiusfade", "192");
	registercvar("cl_particle_TE_WIZSPIKE_bubbles_lightcolor", "0.4 1 0");
}
#endif

EFFECT(0, RUNE_PUFF_RED,            "spawn_point_red")
EFFECT(0, RUNE_PUFF_BLUE,           "spawn_point_blue")
EFFECT(0, RUNE_CYCLONE,             "respawn_ghost")
EFFECT(0, RUNE_HEAL,                "healing_fx")
EFFECT(0, RUNE_FROST_REGEN,         "ammoregen_fx")
EFFECT(0, RUNE_METEOR_IMPACT,       "rune_meteor_impact")
#ifdef CSQC
STATIC_INIT(Effect_RUNE_METEOR_IMPACT)
{
	registercvar("cl_particle_rune_meteor_impact", "smoke");

	registercvar("cl_particle_rune_meteor_impact_smoke_alpha", "128 256 256");
	registercvar("cl_particle_rune_meteor_impact_smoke_color_max", "1 0.5 0.12");
	registercvar("cl_particle_rune_meteor_impact_smoke_color_min", "0.5 0 0");
	registercvar("cl_particle_rune_meteor_impact_smoke_count", "4");
	registercvar("cl_particle_rune_meteor_impact_smoke_originjitter", "1 1 1");
	registercvar("cl_particle_rune_meteor_impact_smoke_size", "12 12 0");
	registercvar("cl_particle_rune_meteor_impact_smoke_sizeincrease", "32");
	registercvar("cl_particle_rune_meteor_impact_smoke_tex", "48 55 0");
	registercvar("cl_particle_rune_meteor_impact_smoke_type", "smoke");
	registercvar("cl_particle_rune_meteor_impact_smoke_velocityjitter", "16 16 16");
}
#endif

EFFECT(1, TR_METEOR,           "TR_METEOR")
#ifdef CSQC
STATIC_INIT(Effect_TR_METEOR)
{
	registercvar("cl_particle_TR_METEOR", "flame bubbles");

	registercvar("cl_particle_TR_METEOR_flame_trailspacing", "4");
	registercvar("cl_particle_TR_METEOR_flame_type", "static");
	registercvar("cl_particle_TR_METEOR_flame_color", "0x801010 0xFFA020");
	registercvar("cl_particle_TR_METEOR_flame_size", "5 1");
	registercvar("cl_particle_TR_METEOR_flame_alpha", "64 256 256");
	registercvar("cl_particle_TR_METEOR_flame_velocityjitter", "25 25 25");
	registercvar("cl_particle_TR_METEOR_flame_airfriction", "3");
	registercvar("cl_particle_TR_METEOR_flame_liquidfriction", "3");
	registercvar("cl_particle_TR_METEOR_flame_tex", "0 8");

	registercvar("cl_particle_TR_METEOR_bubbles_trailspacing", "9");
	registercvar("cl_particle_TR_METEOR_bubbles_type", "bubble");
	registercvar("cl_particle_TR_METEOR_bubbles_tex", "62 62");
	registercvar("cl_particle_TR_METEOR_bubbles_color", "0x404040 0x808080");
	registercvar("cl_particle_TR_METEOR_bubbles_size", "2 2");
	registercvar("cl_particle_TR_METEOR_bubbles_alpha", "64 256 128");
	registercvar("cl_particle_TR_METEOR_bubbles_gravity", "-0.125");
	registercvar("cl_particle_TR_METEOR_bubbles_bounce", "1.5");
	registercvar("cl_particle_TR_METEOR_bubbles_liquidfriction", "0.25");
	registercvar("cl_particle_TR_METEOR_bubbles_originjitter", "16 16 16");
	registercvar("cl_particle_TR_METEOR_bubbles_velocityjitter", "96 96 96");
	registercvar("cl_particle_TR_METEOR_bubbles_underwater", "1");
}
#endif

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

EFFECT(0, DPP_BURSTSHOCKWAVE1,      "DPP_ITSBURSTSHOCKWAVE1")
#ifdef CSQC
STATIC_INIT(Effect_DPP_BURSTSHOCKWAVE1)
{
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1", "decal sparks ball smoke");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_decal_countabsolute", "1");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_decal_type", "decal");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_decal_tex", "8 15");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_decal_size", "24 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_decal_alpha", "48 96 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_decal_originjitter", "48 48 48");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_count", "32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_type", "spark");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_color", "0x903010 0xFFD030");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_size", "1 1");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_sizeincrease", "2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_stretchfactor", "2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_alpha", "0 256 224");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_gravity", "0.35");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_airfriction", "0.35");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_velocityoffset", "64 64 128");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_sparks_velocityjitter", "128 128 128");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_count", "4");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_type", "smoke");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_color", "0x801010 0xFFA020");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_tex", "0 8");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_size", "16 24");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_sizeincrease", "4");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_alpha", "16 96 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_airfriction", "0.2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_originjitter", "16 16 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_velocityjitter", "32 32 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_ball_rotate", "0 360 15 30");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_count", "16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_type", "smoke");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_color", "0x202020 0x635844");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_tex", "16 23");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_size", "16 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_sizeincrease", "3");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_alpha", "16 96 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_airfriction", "0.2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_originjitter", "8 8 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_velocityjitter", "64 64 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE1_smoke_rotate", "0 360 -15 -30");
}
#endif

EFFECT(0, DPP_BURSTSHOCKWAVE2,      "DPP_ITSBURSTSHOCKWAVE2")
#ifdef CSQC
STATIC_INIT(Effect_DPP_BURSTSHOCKWAVE2)
{
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2", "decal ring sparks ball smoke");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_decal_countabsolute", "1");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_decal_type", "decal");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_decal_tex", "8 15");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_decal_size", "32 48");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_decal_alpha", "48 96 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_decal_originjitter", "48 48 48");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_countabsolute", "1");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_type", "static");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_color", "0x101010 0x79572a");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_tex", "109 109");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_size", "18 21");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_sizeincrease", "80");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_alpha", "175 175 192");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_orientation", "oriented");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_originoffset", "0 0 1");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ring_velocityoffset", "0 0 2");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_count", "48");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_type", "spark");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_color", "0x903010 0xFFD030");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_size", "1 1");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_sizeincrease", "2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_stretchfactor", "2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_alpha", "0 256 224");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_gravity", "0.35");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_airfriction", "0.35");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_velocityoffset", "64 64 128");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_sparks_velocityjitter", "128 128 128");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_count", "8");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_type", "smoke");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_color", "0x801010 0xFFA020");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_tex", "0 8");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_size", "16 24");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_sizeincrease", "4");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_alpha", "16 96 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_airfriction", "0.2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_originjitter", "16 16 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_velocityjitter", "32 32 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_ball_rotate", "0 360 15 30");

	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_count", "32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_type", "smoke");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_color", "0x202020 0x635844");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_tex", "16 23");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_size", "16 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_sizeincrease", "3");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_alpha", "16 96 32");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_airfriction", "0.2");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_originjitter", "8 8 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_velocityjitter", "64 64 16");
	registercvar("cl_particle_DPP_ITSBURSTSHOCKWAVE2_smoke_rotate", "0 360 -15 -30");
}
#endif

EFFECT(0, DPP_BURSTPARTY,           "DPP_ITSPART_BURSTY")
EFFECT(0, DPP_BURSTPARTG,           "DPP_ITSPART_BURSTG")
EFFECT(0, DPP_BURSTPARTR,           "DPP_ITSPART_BURSTR")
EFFECT(0, DPP_BURSTPARTB,           "DPP_ITSPART_BURSTB")
EFFECT(0, DPP_BURSTPARTP,           "DPP_ITSPART_BURSTP")

EFFECT(0, DPP_BURSTPARTW,           "DPP_ITSPART_BURSTW")
#ifdef CSQC
STATIC_INIT(Effect_DPP_BURSTPARTW)
{
	registercvar("cl_particle_DPP_ITSPART_BURSTW", "smoke");

	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_count", "1");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_type", "static");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_color", "0x606060 0xC0C0C0");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_tex", "63 63");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_size", "1 3");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_sizeincrease", "0.5");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_alpha", "128 192 64");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_velocityjitter", "32 32 32");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_velocitymultiplier", "1");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_airfriction", "0.65");
	registercvar("cl_particle_DPP_ITSPART_BURSTW_smoke_rotate", "0 360 45 90");
}
#endif

EFFECT(0, DRILL_TOUCH,              "sparks")

EFFECT(0, TE_PLASMABIG,             "TE_PLASMABIG")
#ifdef CSQC
STATIC_INIT(Effect_TE_PLASMABIG)
{
	registercvar("cl_particle_TE_PLASMABIG", "decal flash ball smoke light burst bubbles");

	registercvar("cl_particle_TE_PLASMABIG_decal_countabsolute", "1");
	registercvar("cl_particle_TE_PLASMABIG_decal_type", "decal");
	registercvar("cl_particle_TE_PLASMABIG_decal_tex", "8 15");
	registercvar("cl_particle_TE_PLASMABIG_decal_size", "32 48");
	registercvar("cl_particle_TE_PLASMABIG_decal_alpha", "64 128 0");
	registercvar("cl_particle_TE_PLASMABIG_decal_originjitter", "48 48 48");

	registercvar("cl_particle_TE_PLASMABIG_flash_lightradius", "5");
	registercvar("cl_particle_TE_PLASMABIG_flash_lightradiusfade", "25");
	registercvar("cl_particle_TE_PLASMABIG_flash_lightcolor", "1 2 8");
	registercvar("cl_particle_TE_PLASMABIG_flash_originoffset", "0 0 16");
	registercvar("cl_particle_TE_PLASMABIG_flash_notunderwater", "1");

	registercvar("cl_particle_TE_PLASMABIG_ball_count", "32");
	registercvar("cl_particle_TE_PLASMABIG_ball_type", "static");
	registercvar("cl_particle_TE_PLASMABIG_ball_color", "0x545470 0x8b8bc1");
	registercvar("cl_particle_TE_PLASMABIG_ball_tex", "63 63");
	registercvar("cl_particle_TE_PLASMABIG_ball_size", "1 4");
	registercvar("cl_particle_TE_PLASMABIG_ball_alpha", "64 128 24");
	registercvar("cl_particle_TE_PLASMABIG_ball_airfriction", "0.25");
	registercvar("cl_particle_TE_PLASMABIG_ball_originjitter", "8 8 8");
	registercvar("cl_particle_TE_PLASMABIG_ball_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_PLASMABIG_ball_rotate", "0 360 15 30");
	registercvar("cl_particle_TE_PLASMABIG_ball_notunderwater", "1");

	registercvar("cl_particle_TE_PLASMABIG_smoke_count", "32");
	registercvar("cl_particle_TE_PLASMABIG_smoke_type", "smoke");
	registercvar("cl_particle_TE_PLASMABIG_smoke_color", "0x545470 0x8b8bc1");
	registercvar("cl_particle_TE_PLASMABIG_smoke_tex", "16 23");
	registercvar("cl_particle_TE_PLASMABIG_smoke_size", "16 24");
	registercvar("cl_particle_TE_PLASMABIG_smoke_sizeincrease", "3");
	registercvar("cl_particle_TE_PLASMABIG_smoke_alpha", "96 160 64");
	registercvar("cl_particle_TE_PLASMABIG_smoke_airfriction", "0.2");
	registercvar("cl_particle_TE_PLASMABIG_smoke_gravity", "-0.02");
	registercvar("cl_particle_TE_PLASMABIG_smoke_originjitter", "16 16 16");
	registercvar("cl_particle_TE_PLASMABIG_smoke_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_PLASMABIG_smoke_rotate", "0 360 -15 -30");
	registercvar("cl_particle_TE_PLASMABIG_smoke_notunderwater", "1");

	registercvar("cl_particle_TE_PLASMABIG_light_lightradius", "5");
	registercvar("cl_particle_TE_PLASMABIG_light_lightradiusfade", "25");
	registercvar("cl_particle_TE_PLASMABIG_light_lightcolor", "1.2 2.3 2.8");
	registercvar("cl_particle_TE_PLASMABIG_light_underwater", "1");

	registercvar("cl_particle_TE_PLASMABIG_burst_count", "24");
	registercvar("cl_particle_TE_PLASMABIG_burst_type", "bubble");
	registercvar("cl_particle_TE_PLASMABIG_burst_color", "0x101010 0xbbb591");
	registercvar("cl_particle_TE_PLASMABIG_burst_tex", "34 37");
	registercvar("cl_particle_TE_PLASMABIG_burst_size", "4 8");
	registercvar("cl_particle_TE_PLASMABIG_burst_sizeincrease", "2");
	registercvar("cl_particle_TE_PLASMABIG_burst_alpha", "128 192 64");
	registercvar("cl_particle_TE_PLASMABIG_burst_liquidfriction", "1");
	registercvar("cl_particle_TE_PLASMABIG_burst_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_PLASMABIG_burst_underwater", "1");

	registercvar("cl_particle_TE_PLASMABIG_bubbles_count", "24");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_type", "bubble");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_color", "0x202020 0x606060");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_tex", "32 34");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_size", "8 12");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_sizeincrease", "2");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_alpha", "16 128 32");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_liquidfriction", "1");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_velocityjitter", "64 64 64");
	registercvar("cl_particle_TE_PLASMABIG_bubbles_underwater", "1");
}
#endif

EFFECT(0, TE_POISONBIG,             "TE_POISONBIG")
#ifdef CSQC
STATIC_INIT(Effect_TE_POISONBIG)
{
	registercvar("cl_particle_TE_POISONBIG", "decal flash ball smoke light burst bubbles");

	registercvar("cl_particle_TE_POISONBIG_decal_countabsolute", "1");
	registercvar("cl_particle_TE_POISONBIG_decal_type", "decal");
	registercvar("cl_particle_TE_POISONBIG_decal_color", "0x730059 0x730059");
	registercvar("cl_particle_TE_POISONBIG_decal_tex", "8 15");
	registercvar("cl_particle_TE_POISONBIG_decal_size", "32 48");
	registercvar("cl_particle_TE_POISONBIG_decal_originjitter", "48 48 48");

	registercvar("cl_particle_TE_POISONBIG_flash_lightradius", "5");
	registercvar("cl_particle_TE_POISONBIG_flash_lightradiusfade", "25");
	registercvar("cl_particle_TE_POISONBIG_flash_lightcolor", "2 8 1");
	registercvar("cl_particle_TE_POISONBIG_flash_originoffset", "0 0 16");
	registercvar("cl_particle_TE_POISONBIG_flash_notunderwater", "1");

	registercvar("cl_particle_TE_POISONBIG_ball_count", "32");
	registercvar("cl_particle_TE_POISONBIG_ball_type", "static");
	registercvar("cl_particle_TE_POISONBIG_ball_color", "0x433700 0xbba70f");
	registercvar("cl_particle_TE_POISONBIG_ball_tex", "63 63");
	registercvar("cl_particle_TE_POISONBIG_ball_size", "1 4");
	registercvar("cl_particle_TE_POISONBIG_ball_alpha", "64 128 24");
	registercvar("cl_particle_TE_POISONBIG_ball_airfriction", "0.25");
	registercvar("cl_particle_TE_POISONBIG_ball_originjitter", "8 8 8");
	registercvar("cl_particle_TE_POISONBIG_ball_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_POISONBIG_ball_rotate", "0 360 15 30");
	registercvar("cl_particle_TE_POISONBIG_ball_notunderwater", "1");

	registercvar("cl_particle_TE_POISONBIG_smoke_count", "32");
	registercvar("cl_particle_TE_POISONBIG_smoke_type", "smoke");
	registercvar("cl_particle_TE_POISONBIG_smoke_color", "0x433700 0xbba70f");
	registercvar("cl_particle_TE_POISONBIG_smoke_tex", "16 23");
	registercvar("cl_particle_TE_POISONBIG_smoke_size", "16 24");
	registercvar("cl_particle_TE_POISONBIG_smoke_sizeincrease", "3");
	registercvar("cl_particle_TE_POISONBIG_smoke_alpha", "96 160 64");
	registercvar("cl_particle_TE_POISONBIG_smoke_airfriction", "0.2");
	registercvar("cl_particle_TE_POISONBIG_smoke_gravity", "-0.02");
	registercvar("cl_particle_TE_POISONBIG_smoke_originjitter", "16 16 16");
	registercvar("cl_particle_TE_POISONBIG_smoke_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_POISONBIG_smoke_rotate", "0 360 -15 -30");
	registercvar("cl_particle_TE_POISONBIG_smoke_notunderwater", "1");

	registercvar("cl_particle_TE_POISONBIG_light_lightradius", "5");
	registercvar("cl_particle_TE_POISONBIG_light_lightradiusfade", "25");
	registercvar("cl_particle_TE_POISONBIG_light_lightcolor", "2.3 2.8 1.2");
	registercvar("cl_particle_TE_POISONBIG_light_underwater", "1");

	registercvar("cl_particle_TE_POISONBIG_burst_count", "24");
	registercvar("cl_particle_TE_POISONBIG_burst_type", "bubble");
	registercvar("cl_particle_TE_POISONBIG_burst_color", "0x433700 0xbba70f");
	registercvar("cl_particle_TE_POISONBIG_burst_tex", "34 37");
	registercvar("cl_particle_TE_POISONBIG_burst_size", "4 8");
	registercvar("cl_particle_TE_POISONBIG_burst_sizeincrease", "2");
	registercvar("cl_particle_TE_POISONBIG_burst_alpha", "128 192 64");
	registercvar("cl_particle_TE_POISONBIG_burst_liquidfriction", "1");
	registercvar("cl_particle_TE_POISONBIG_burst_velocityjitter", "32 32 32");
	registercvar("cl_particle_TE_POISONBIG_burst_underwater", "1");

	registercvar("cl_particle_TE_POISONBIG_bubbles_count", "24");
	registercvar("cl_particle_TE_POISONBIG_bubbles_type", "bubble");
	registercvar("cl_particle_TE_POISONBIG_bubbles_color", "0x433700 0xbba70f");
	registercvar("cl_particle_TE_POISONBIG_bubbles_tex", "32 38");
	registercvar("cl_particle_TE_POISONBIG_bubbles_size", "8 12");
	registercvar("cl_particle_TE_POISONBIG_bubbles_sizeincrease", "2");
	registercvar("cl_particle_TE_POISONBIG_bubbles_alpha", "16 128 32");
	registercvar("cl_particle_TE_POISONBIG_bubbles_liquidfriction", "1");
	registercvar("cl_particle_TE_POISONBIG_bubbles_velocityjitter", "64 64 64");
	registercvar("cl_particle_TE_POISONBIG_bubbles_underwater", "1");
}
#endif

EFFECT(0, TE_BSMOKE,             "TE_BSMOKE")
#ifdef CSQC
STATIC_INIT(Effect_TE_BSMOKE)
{
	registercvar("cl_particle_TE_BSMOKE", "steam flame smoke");

	registercvar("cl_particle_TE_BSMOKE_steam_count", "16");
	registercvar("cl_particle_TE_BSMOKE_steam_type", "smoke");
	registercvar("cl_particle_TE_BSMOKE_steam_color", "0x202020 0x635844");
	registercvar("cl_particle_TE_BSMOKE_steam_tex", "0 8");
	registercvar("cl_particle_TE_BSMOKE_steam_size", "4 16");
	registercvar("cl_particle_TE_BSMOKE_steam_sizeincrease", "2");
	registercvar("cl_particle_TE_BSMOKE_steam_alpha", "48 128 96");
	registercvar("cl_particle_TE_BSMOKE_steam_airfriction", "0.2");
	registercvar("cl_particle_TE_BSMOKE_steam_originjitter", "16 16 32");
	registercvar("cl_particle_TE_BSMOKE_steam_velocityjitter", "16 16 16");
	registercvar("cl_particle_TE_BSMOKE_steam_rotate", "0 360 15 30");
	registercvar("cl_particle_TE_BSMOKE_steam_notunderwater", "1");

	registercvar("cl_particle_TE_BSMOKE_flame_count", "16");
	registercvar("cl_particle_TE_BSMOKE_flame_type", "smoke");
	registercvar("cl_particle_TE_BSMOKE_flame_color", "0x202020 0x635844");
	registercvar("cl_particle_TE_BSMOKE_flame_tex", "16 23");
	registercvar("cl_particle_TE_BSMOKE_flame_size", "4 24");
	registercvar("cl_particle_TE_BSMOKE_flame_sizeincrease", "5");
	registercvar("cl_particle_TE_BSMOKE_flame_alpha", "48 128 64");
	registercvar("cl_particle_TE_BSMOKE_flame_airfriction", "0.2");
	registercvar("cl_particle_TE_BSMOKE_flame_originjitter", "8 8 16");
	registercvar("cl_particle_TE_BSMOKE_flame_velocityjitter", "16 16 8");
	registercvar("cl_particle_TE_BSMOKE_flame_rotate", "0 360 -15 -30");
	registercvar("cl_particle_TE_BSMOKE_flame_notunderwater", "1");

	registercvar("cl_particle_TE_BSMOKE_smoke_count", "32");
	registercvar("cl_particle_TE_BSMOKE_smoke_type", "bubble");
	registercvar("cl_particle_TE_BSMOKE_smoke_color", "0x202020 0x606060");
	registercvar("cl_particle_TE_BSMOKE_smoke_tex", "32 38");
	registercvar("cl_particle_TE_BSMOKE_smoke_size", "8 12");
	registercvar("cl_particle_TE_BSMOKE_smoke_sizeincrease", "3");
	registercvar("cl_particle_TE_BSMOKE_smoke_alpha", "16 128 32");
	registercvar("cl_particle_TE_BSMOKE_smoke_liquidfriction", "1");
	registercvar("cl_particle_TE_BSMOKE_smoke_velocityjitter", "64 64 64");
	registercvar("cl_particle_TE_BSMOKE_smoke_underwater", "1");
}
#endif

EFFECT(0, LAVANAIL_PUFF,            "lavanail_puff")
#ifdef CSQC
STATIC_INIT(Effect_LAVANAIL_PUFF)
{
	registercvar("cl_particle_lavanail_puff", "smoke");
	registercvar("cl_particle_lavanail_puff_smoke_type", "alphastatic");
	registercvar("cl_particle_lavanail_puff_smoke_alpha", "256 256 256");
	registercvar("cl_particle_lavanail_puff_smoke_color", "0x696969 0xffffff");
	registercvar("cl_particle_lavanail_puff_smoke_count", "8");
	registercvar("cl_particle_lavanail_puff_smoke_gravity", "-0.050000");
	registercvar("cl_particle_lavanail_puff_smoke_size", "1 3");
	registercvar("cl_particle_lavanail_puff_smoke_tex", "0 3");
	registercvar("cl_particle_lavanail_puff_smoke_velocityjitter", "16 16 16");
	registercvar("cl_particle_lavanail_puff_smoke_airfriction", "2");
}
#endif

EFFECT(0, SUPERCHICKEN_DIE,         "superchicken_die")
#ifdef CSQC
STATIC_INIT(Effect_SUPERCHICKEN_DIE)
{
	registercvar("cl_particle_superchicken_die", "feathers");
	registercvar("cl_particle_superchicken_die_feathers_type", "smoke");
	registercvar("cl_particle_superchicken_die_feathers_alpha", "256 256 128");
	registercvar("cl_particle_superchicken_die_feathers_color", "0xfffffff 0xffffff");
	registercvar("cl_particle_superchicken_die_feathers_count", "512");
	registercvar("cl_particle_superchicken_die_feathers_gravity", "0.050000");
	registercvar("cl_particle_superchicken_die_feathers_size", "2 6");
	registercvar("cl_particle_superchicken_die_feathers_tex", "41 42");
	registercvar("cl_particle_superchicken_die_feathers_velocityjitter", "300 300 300");
	registercvar("cl_particle_superchicken_die_feathers_airfriction", "2");
	registercvar("cl_particle_superchicken_die_feathers_bounce", "1");
}
#endif

EFFECT(0, CHICKEN_DIE,         "chicken_die")
#ifdef CSQC
STATIC_INIT(Effect_CHICKEN_DIE)
{
	registercvar("cl_particle_chicken_die", "feathers");
	registercvar("cl_particle_chicken_die_feathers_type", "smoke");
	registercvar("cl_particle_chicken_die_feathers_alpha", "256 256 128");
	registercvar("cl_particle_chicken_die_feathers_color", "0xfffffff 0xffffff");
	registercvar("cl_particle_chicken_die_feathers_count", "128");
	registercvar("cl_particle_chicken_die_feathers_gravity", "0.050000");
	registercvar("cl_particle_chicken_die_feathers_size", "2 6");
	registercvar("cl_particle_chicken_die_feathers_tex", "41 42");
	registercvar("cl_particle_chicken_die_feathers_velocityjitter", "150 150 150");
	registercvar("cl_particle_chicken_die_feathers_airfriction", "2");
	registercvar("cl_particle_chicken_die_feathers_bounce", "1");
}
#endif

EFFECT(0, ARMAGON_SHOCKWAVE,         "armagon_shockwave")
#ifdef CSQC
STATIC_INIT(Effect_ARMAGON_SHOCKWAVE)
{
	registercvar("cl_particle_armagon_shockwave", "smoke");
	registercvar("cl_particle_armagon_shockwave_smoke_type", "alphastatic");
	registercvar("cl_particle_armagon_shockwave_smoke_alpha", "256 256 1024");
	registercvar("cl_particle_armagon_shockwave_smoke_color", "0x696969 0xffffff");
	registercvar("cl_particle_armagon_shockwave_smoke_count", "8");
	registercvar("cl_particle_armagon_shockwave_smoke_gravity", "-0.050000");
	registercvar("cl_particle_armagon_shockwave_smoke_size", "4 12");
	registercvar("cl_particle_armagon_shockwave_smoke_tex", "0 3");
	registercvar("cl_particle_armagon_shockwave_smoke_velocityjitter", "16 16 16");
	registercvar("cl_particle_armagon_shockwave_smoke_airfriction", "2");
}
#endif

EFFECT(0, POOP_STINK,               "poop_stink")
#ifdef CSQC
STATIC_INIT(Effect_POOP_STINK)
{
	registercvar("cl_particle_poop_stink", "cloud");
	registercvar("cl_particle_poop_stink_cloud_type", "smoke");
	registercvar("cl_particle_poop_stink_cloud_airfriction", "1");
	registercvar("cl_particle_poop_stink_cloud_alpha", "256 256 128");
	registercvar("cl_particle_poop_stink_cloud_bounce", "1.500000");
	registercvar("cl_particle_poop_stink_cloud_color", "0x00ff00 0x7db843");
	registercvar("cl_particle_poop_stink_cloud_count", "0.5");
	registercvar("cl_particle_poop_stink_cloud_gravity", "-0.010000");
	registercvar("cl_particle_poop_stink_cloud_originjitter", "15 15 20");
	registercvar("cl_particle_poop_stink_cloud_sizeincrease", "10");
	registercvar("cl_particle_poop_stink_cloud_size", "1 1");
	registercvar("cl_particle_poop_stink_cloud_tex", "0 8");
	registercvar("cl_particle_poop_stink_cloud_velocityjitter", "5 5 5");
}
#endif

// effect handled by code
EFFECT(0, NUKE_EXPLODE,             "nuke_explode")
#ifdef CSQC
STATIC_INIT(Effect_NUKE_EXPLODE)
{
	registercvar("cl_particle_nuke_explode", "fire fire2 smoke smoke2 jet1 jet2 jet3 jet4 jet5 bubbles shockwave sparks sparks2 debris");

	registercvar("cl_particle_nuke_explode_fire_type", "static");
	registercvar("cl_particle_nuke_explode_fire_airfriction", "8");
	registercvar("cl_particle_nuke_explode_fire_alpha", "200 256 60");
	registercvar("cl_particle_nuke_explode_fire_bounce", "1.500000");
	registercvar("cl_particle_nuke_explode_fire_color", "0x8f0d00 0xff5a00");
	registercvar("cl_particle_nuke_explode_fire_count", "32");
	registercvar("cl_particle_nuke_explode_fire_gravity", "-0.220000");
	registercvar("cl_particle_nuke_explode_fire_liquidfriction", "8");
	registercvar("cl_particle_nuke_explode_fire_notunderwater", "1");
	registercvar("cl_particle_nuke_explode_fire_originjitter", "8 8 8");
	registercvar("cl_particle_nuke_explode_fire_sizeincrease", "45");
	registercvar("cl_particle_nuke_explode_fire_size", "60 120");
	registercvar("cl_particle_nuke_explode_fire_tex", "48 55");
	registercvar("cl_particle_nuke_explode_fire_velocityjitter", "512 512 768");
	registercvar("cl_particle_nuke_explode_fire_originoffset", "0 0 300");
	registercvar("cl_particle_nuke_explode_fire_delayspawn", "0.6");

	registercvar("cl_particle_nuke_explode_fire2_type", "smoke");
	registercvar("cl_particle_nuke_explode_fire2_airfriction", "19");
	registercvar("cl_particle_nuke_explode_fire2_alpha", "200 256 70");
	registercvar("cl_particle_nuke_explode_fire2_bounce", "2.500000");
	registercvar("cl_particle_nuke_explode_fire2_color", "0xea691b 0xeed05a");
	registercvar("cl_particle_nuke_explode_fire2_count", "14");
	registercvar("cl_particle_nuke_explode_fire2_gravity", "-0.220000");
	registercvar("cl_particle_nuke_explode_fire2_liquidfriction", "19");
	registercvar("cl_particle_nuke_explode_fire2_notunderwater", "1");
	registercvar("cl_particle_nuke_explode_fire2_originjitter", "8 8 8");
	registercvar("cl_particle_nuke_explode_fire2_sizeincrease", "-16");
	registercvar("cl_particle_nuke_explode_fire2_size", "50 110");
	registercvar("cl_particle_nuke_explode_fire2_tex", "48 55");
	registercvar("cl_particle_nuke_explode_fire2_velocityjitter", "912 912 2000");
	registercvar("cl_particle_nuke_explode_fire2_originoffset", "0 0 300");
	registercvar("cl_particle_nuke_explode_fire2_delayspawn", "0.6");

	registercvar("cl_particle_nuke_explode_smoke_type", "alphastatic");
	registercvar("cl_particle_nuke_explode_smoke_airfriction", "5");
	registercvar("cl_particle_nuke_explode_smoke_alpha", "200 450 75");
	registercvar("cl_particle_nuke_explode_smoke_bounce", "2");
	registercvar("cl_particle_nuke_explode_smoke_color", "0x000000 0x111111");
	registercvar("cl_particle_nuke_explode_smoke_count", "32");
	registercvar("cl_particle_nuke_explode_smoke_gravity", "-0.220000");
	registercvar("cl_particle_nuke_explode_smoke_notunderwater", "1");
	registercvar("cl_particle_nuke_explode_smoke_sizeincrease", "44");
	registercvar("cl_particle_nuke_explode_smoke_size", "40 100");
	registercvar("cl_particle_nuke_explode_smoke_tex", "0 8");
	registercvar("cl_particle_nuke_explode_smoke_velocityjitter", "444 444 444");
	registercvar("cl_particle_nuke_explode_smoke_originoffset", "0 0 300");
	registercvar("cl_particle_nuke_explode_smoke_delayspawn", "0.6");

	registercvar("cl_particle_nuke_explode_smoke2_type", "alphastatic");
	registercvar("cl_particle_nuke_explode_smoke2_airfriction", "5");
	registercvar("cl_particle_nuke_explode_smoke2_alpha", "200 450 75");
	registercvar("cl_particle_nuke_explode_smoke2_bounce", "2");
	registercvar("cl_particle_nuke_explode_smoke2_color", "0x696969 0x111111");
	registercvar("cl_particle_nuke_explode_smoke2_count", "32");
	registercvar("cl_particle_nuke_explode_smoke2_sizeincrease", "44");
	registercvar("cl_particle_nuke_explode_smoke2_size", "20 60");
	registercvar("cl_particle_nuke_explode_smoke2_tex", "0 8");
	registercvar("cl_particle_nuke_explode_smoke2_velocityjitter", "444 444 444");
	registercvar("cl_particle_nuke_explode_smoke2_originoffset", "0 0 300");
	registercvar("cl_particle_nuke_explode_smoke2_delayspawn", "0.6");

	registercvar("cl_particle_nuke_explode_jet1_type", "smoke");
	registercvar("cl_particle_nuke_explode_jet1_airfriction", "1.600000");
	registercvar("cl_particle_nuke_explode_jet1_alpha", "50 256 40");
	registercvar("cl_particle_nuke_explode_jet1_bounce", "1.500000");
	registercvar("cl_particle_nuke_explode_jet1_color", "0x8f0d00 0xff5a00");
	registercvar("cl_particle_nuke_explode_jet1_count", "30");
	registercvar("cl_particle_nuke_explode_jet1_gravity", "-0.020000");
	registercvar("cl_particle_nuke_explode_jet1_sizeincrease", "2");
	registercvar("cl_particle_nuke_explode_jet1_size", "8 20");
	registercvar("cl_particle_nuke_explode_jet1_tex", "48 55");
	registercvar("cl_particle_nuke_explode_jet1_velocityjitter", "40 40 800");
	registercvar("cl_particle_nuke_explode_jet1_velocitymultiplier", "30");

	registercvar("cl_particle_nuke_explode_jet2_type", "smoke");
	registercvar("cl_particle_nuke_explode_jet2_airfriction", "1.600000");
	registercvar("cl_particle_nuke_explode_jet2_alpha", "50 256 40");
	registercvar("cl_particle_nuke_explode_jet2_bounce", "1.500000");
	registercvar("cl_particle_nuke_explode_jet2_color", "0x8f0d00 0xff5a00");
	registercvar("cl_particle_nuke_explode_jet2_count", "25");
	registercvar("cl_particle_nuke_explode_jet2_gravity", "-0.020000");
	registercvar("cl_particle_nuke_explode_jet2_sizeincrease", "2");
	registercvar("cl_particle_nuke_explode_jet2_size", "8 20");
	registercvar("cl_particle_nuke_explode_jet2_tex", "48 55");
	registercvar("cl_particle_nuke_explode_jet2_velocityjitter", "40 40 600");
	registercvar("cl_particle_nuke_explode_jet2_velocitymultiplier", "20");

	registercvar("cl_particle_nuke_explode_jet3_type", "smoke");
	registercvar("cl_particle_nuke_explode_jet3_airfriction", "1.300000");
	registercvar("cl_particle_nuke_explode_jet3_alpha", "50 256 40");
	registercvar("cl_particle_nuke_explode_jet3_bounce", "1.500000");
	registercvar("cl_particle_nuke_explode_jet3_color", "0x8f0d00 0xff5a00");
	registercvar("cl_particle_nuke_explode_jet3_count", "15");
	registercvar("cl_particle_nuke_explode_jet3_gravity", "-0.020000");
	registercvar("cl_particle_nuke_explode_jet3_sizeincrease", "4");
	registercvar("cl_particle_nuke_explode_jet3_size", "8 20");
	registercvar("cl_particle_nuke_explode_jet3_tex", "48 55");
	registercvar("cl_particle_nuke_explode_jet3_velocityjitter", "30 30 500");
	registercvar("cl_particle_nuke_explode_jet3_velocitymultiplier", "10");

	registercvar("cl_particle_nuke_explode_jet4_type", "smoke");
	registercvar("cl_particle_nuke_explode_jet4_airfriction", "1.300000");
	registercvar("cl_particle_nuke_explode_jet4_alpha", "50 256 40");
	registercvar("cl_particle_nuke_explode_jet4_bounce", "1.500000");
	registercvar("cl_particle_nuke_explode_jet4_color", "0x8f0d00 0xff5a00");
	registercvar("cl_particle_nuke_explode_jet4_count", "20");
	registercvar("cl_particle_nuke_explode_jet4_gravity", "-0.020000");
	registercvar("cl_particle_nuke_explode_jet4_sizeincrease", "-10");
	registercvar("cl_particle_nuke_explode_jet4_size", "20 30");
	registercvar("cl_particle_nuke_explode_jet4_tex", "48 55");
	registercvar("cl_particle_nuke_explode_jet4_velocityjitter", "10 10 100");
	registercvar("cl_particle_nuke_explode_jet4_velocitymultiplier", "15");

	registercvar("cl_particle_nuke_explode_jet5_type", "alphastatic");
	registercvar("cl_particle_nuke_explode_jet5_airfriction", "1");
	registercvar("cl_particle_nuke_explode_jet5_alpha", "256 512 70");
	registercvar("cl_particle_nuke_explode_jet5_color", "0x000000 0x111111");
	registercvar("cl_particle_nuke_explode_jet5_count", "5");
	registercvar("cl_particle_nuke_explode_jet5_originjitter", "10 10 10");
	registercvar("cl_particle_nuke_explode_jet5_sizeincrease", "20");
	registercvar("cl_particle_nuke_explode_jet5_size", "5 15");
	registercvar("cl_particle_nuke_explode_jet5_tex", "0 8");
	registercvar("cl_particle_nuke_explode_jet5_velocitymultiplier", "5");
	registercvar("cl_particle_nuke_explode_jet5_velocityoffset", "0 0 10");
	registercvar("cl_particle_nuke_explode_jet5_rotate", "-4 4 -16 16");

	registercvar("cl_particle_nuke_explode_bubbles_type", "bubble");
	registercvar("cl_particle_nuke_explode_bubbles_alpha", "128 256 64");
	registercvar("cl_particle_nuke_explode_bubbles_bounce", "1.500000");
	registercvar("cl_particle_nuke_explode_bubbles_color", "0x404040 0x808080");
	registercvar("cl_particle_nuke_explode_bubbles_count", "32");
	registercvar("cl_particle_nuke_explode_bubbles_gravity", "-0.125000");
	registercvar("cl_particle_nuke_explode_bubbles_liquidfriction", "0.250000");
	registercvar("cl_particle_nuke_explode_bubbles_originjitter", "16 16 16");
	registercvar("cl_particle_nuke_explode_bubbles_size", "3 3");
	registercvar("cl_particle_nuke_explode_bubbles_tex", "62 62");
	registercvar("cl_particle_nuke_explode_bubbles_underwater", "1");
	registercvar("cl_particle_nuke_explode_bubbles_velocityjitter", "144 144 144");

	registercvar("cl_particle_nuke_explode_shockwave_airfriction", "0.5");
	registercvar("cl_particle_nuke_explode_shockwave_alpha", "256 512 70");
	registercvar("cl_particle_nuke_explode_shockwave_color", "0x000000 0x696969");
	registercvar("cl_particle_nuke_explode_shockwave_count", "512");
	registercvar("cl_particle_nuke_explode_shockwave_liquidfriction", "6");
	registercvar("cl_particle_nuke_explode_shockwave_size", "20 60 0");
	registercvar("cl_particle_nuke_explode_shockwave_sizeincrease", "40");
	registercvar("cl_particle_nuke_explode_shockwave_tex", "0 8 0");
	registercvar("cl_particle_nuke_explode_shockwave_type", "spark");
	registercvar("cl_particle_nuke_explode_shockwave_velocityjitter", "350 350 48");
	registercvar("cl_particle_nuke_explode_shockwave_delayspawn", "0.4");

	registercvar("cl_particle_nuke_explode_sparks_type", "spark");
	registercvar("cl_particle_nuke_explode_sparks_airfriction", "1");
	registercvar("cl_particle_nuke_explode_sparks_alpha", "644 956 484");
	registercvar("cl_particle_nuke_explode_sparks_bounce", "1.600000");
	registercvar("cl_particle_nuke_explode_sparks_color", "0xffa35b 0xfff2be");
	registercvar("cl_particle_nuke_explode_sparks_count", "16");
	registercvar("cl_particle_nuke_explode_sparks_gravity", "1");
	registercvar("cl_particle_nuke_explode_sparks_liquidfriction", "0.800000");
	registercvar("cl_particle_nuke_explode_sparks_notunderwater", "1");
	registercvar("cl_particle_nuke_explode_sparks_originjitter", "16 16 16");
	registercvar("cl_particle_nuke_explode_sparks_size", "1 0.100000");
	registercvar("cl_particle_nuke_explode_sparks_tex", "40 40");
	registercvar("cl_particle_nuke_explode_sparks_velocityjitter", "424 424 624");
	registercvar("cl_particle_nuke_explode_sparks_velocityoffset", "0 0 80");

	registercvar("cl_particle_nuke_explode_sparks2_airfriction", "1.5");
	registercvar("cl_particle_nuke_explode_sparks2_alpha", "256 256 70");
	registercvar("cl_particle_nuke_explode_sparks2_color_max", "1 0.5 0.12");
	registercvar("cl_particle_nuke_explode_sparks2_color_min", "0.5 0 0");
	registercvar("cl_particle_nuke_explode_sparks2_count", "128");
	registercvar("cl_particle_nuke_explode_sparks2_liquidfriction", "1.5");
	registercvar("cl_particle_nuke_explode_sparks2_size", "4 25 0");
	registercvar("cl_particle_nuke_explode_sparks2_tex", "8 15 0");
	registercvar("cl_particle_nuke_explode_sparks2_type", "static");
	registercvar("cl_particle_nuke_explode_sparks2_velocityjitter", "200 200 3");
	registercvar("cl_particle_nuke_explode_sparks2_originoffset", "0 0 100");
	registercvar("cl_particle_nuke_explode_sparks2_delayspawn", "0.35");

	registercvar("cl_particle_nuke_explode_debris_type", "alphastatic");
	registercvar("cl_particle_nuke_explode_debris_airfriction", "0.500000");
	registercvar("cl_particle_nuke_explode_debris_alpha", "644 956 684");
	registercvar("cl_particle_nuke_explode_debris_bounce", "1.600000");
	registercvar("cl_particle_nuke_explode_debris_color", "0x6a3d25 0xcac5b4");
	registercvar("cl_particle_nuke_explode_debris_count", "22");
	registercvar("cl_particle_nuke_explode_debris_gravity", "1.300000");
	registercvar("cl_particle_nuke_explode_debris_notunderwater", "1");
	registercvar("cl_particle_nuke_explode_debris_rotate", "-180 180 -1000 1000");
	registercvar("cl_particle_nuke_explode_debris_size", "2 6");
	registercvar("cl_particle_nuke_explode_debris_tex", "66 68");
	registercvar("cl_particle_nuke_explode_debris_velocityjitter", "324 324 524");
}
#endif

EFFECT(1, TR_BUBBLES,              "TR_BUBBLES")
#ifdef CSQC
STATIC_INIT(Effect_TR_BUBBLES)
{
	registercvar("cl_particle_TR_BUBBLES", "smoke trail");

	registercvar("cl_particle_TR_BUBBLES_smoke_trailspacing", "12");
	registercvar("cl_particle_TR_BUBBLES_smoke_type", "bubble");
	registercvar("cl_particle_TR_BUBBLES_smoke_color", "0x90d5ff 0x696969");
	registercvar("cl_particle_TR_BUBBLES_smoke_count", "1");
	registercvar("cl_particle_TR_BUBBLES_smoke_tex", "74 74");
	registercvar("cl_particle_TR_BUBBLES_smoke_size", "0.1 0.2");
	registercvar("cl_particle_TR_BUBBLES_smoke_sizeincrease", "4");
	registercvar("cl_particle_TR_BUBBLES_smoke_velocityjitter", "16 16 16");
	registercvar("cl_particle_TR_BUBBLES_smoke_rotate", "0 360 0 30");
	registercvar("cl_particle_TR_BUBBLES_smoke_gravity", "-0.05");
	registercvar("cl_particle_TR_BUBBLES_smoke_underwater", "1");

	registercvar("cl_particle_TR_BUBBLES_trail_trailspacing", "2");
	registercvar("cl_particle_TR_BUBBLES_trail_type", "static");
	registercvar("cl_particle_TR_BUBBLES_trail_color", "^4 ^5");
	registercvar("cl_particle_TR_BUBBLES_trail_tex", "24 31");
	registercvar("cl_particle_TR_BUBBLES_trail_size", "1 3");
	registercvar("cl_particle_TR_BUBBLES_trail_sizeincrease", "3");
	registercvar("cl_particle_TR_BUBBLES_trail_alpha", "16 128 128");
	registercvar("cl_particle_TR_BUBBLES_trail_velocityjitter", "16 16 16");
	registercvar("cl_particle_TR_BUBBLES_trail_originjitter", "2 2 2");
	registercvar("cl_particle_TR_BUBBLES_trail_rotate", "0 360 0 30");
}
#endif

EFFECT(0, STORMCLOUD,              "stormcloud")
#ifdef CSQC
STATIC_INIT(Effect_STORMCLOUD)
{
	registercvar("cl_particle_stormcloud", "zap smoke");

	registercvar("cl_particle_stormcloud_zap_type", "static");
	registercvar("cl_particle_stormcloud_zap_airfriction", "2");
	registercvar("cl_particle_stormcloud_zap_alpha", "256 256 512");
	registercvar("cl_particle_stormcloud_zap_color", "0xDDFDFF 0xFDFDFF");
	registercvar("cl_particle_stormcloud_zap_count", "10");
	registercvar("cl_particle_stormcloud_zap_originjitter", "20 20 20");
	registercvar("cl_particle_stormcloud_zap_rotate", "0 180 -180 180");
	registercvar("cl_particle_stormcloud_zap_sizeincrease", "-5");
	registercvar("cl_particle_stormcloud_zap_size", "0 5");
	registercvar("cl_particle_stormcloud_zap_stretchfactor", "1");
	registercvar("cl_particle_stormcloud_zap_tex", "71 74");
	registercvar("cl_particle_stormcloud_zap_velocitymultiplier", "1");

	registercvar("cl_particle_stormcloud_smoke_type", "smoke");
	registercvar("cl_particle_stormcloud_smoke_alpha", "40 40 350");
	registercvar("cl_particle_stormcloud_smoke_color", "0x80C0FF 0x80C0FF");
	registercvar("cl_particle_stormcloud_smoke_countabsolute", "1");
	registercvar("cl_particle_stormcloud_smoke_sizeincrease", "400");
	registercvar("cl_particle_stormcloud_smoke_size", "4 4");
	registercvar("cl_particle_stormcloud_smoke_tex", "38 38");
	registercvar("cl_particle_stormcloud_smoke_velocitymultiplier", "1");
}
#endif
