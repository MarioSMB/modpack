// Global list of effects, networked to CSQC by ID to save bandwidth and to use client particle numbers (allows mismatching effectinfos to some degree)

// EFFECT(istrail, EFFECT_NAME,     "effectinfo_string")
//EFFECT(0, MARIO,                    "mario")
// effect handled by code
#ifdef CSQC
STATIC_INIT(Effect_SHOTGUN_WOOSH)
{
	registercvar("cl_particle_shotgun_woosh", "puff");
	registercvar("cl_particle_shotgun_woosh_puff_type", "smoke");
	registercvar("cl_particle_shotgun_woosh_puff_alpha", "32 192 512");
	registercvar("cl_particle_shotgun_woosh_puff_bounce", "0.100000");
	registercvar("cl_particle_shotgun_woosh_puff_color", "0x111111 0x979797");
	registercvar("cl_particle_shotgun_woosh_puff_count", "24");
	registercvar("cl_particle_shotgun_woosh_puff_notunderwater", "1");
	registercvar("cl_particle_shotgun_woosh_puff_originjitter", "8.0 8.0 8.0");
	registercvar("cl_particle_shotgun_woosh_puff_sizeincrease", "14");
	registercvar("cl_particle_shotgun_woosh_puff_size", "1 12");
	registercvar("cl_particle_shotgun_woosh_puff_tex", "0 8");
	registercvar("cl_particle_shotgun_woosh_puff_velocityjitter", "64 64 32");
	registercvar("cl_particle_shotgun_woosh_puff_velocitymultiplier", "1");
}
#endif

#ifdef CSQC
STATIC_INIT(Effect_TR_ROCKET)
{
	registercvar("cl_particle_TR_ROCKET", "smoke puff bubbles sparks");

	registercvar("cl_particle_TR_ROCKET_smoke_type", "smoke");
	registercvar("cl_particle_TR_ROCKET_smoke_alpha", "200 300 200");
	registercvar("cl_particle_TR_ROCKET_smoke_bounce", "1");
	registercvar("cl_particle_TR_ROCKET_smoke_color", "0x000000 0x666666");
	registercvar("cl_particle_TR_ROCKET_smoke_lightcolor", "6 3 1");
	registercvar("cl_particle_TR_ROCKET_smoke_lightradius", "150");
	registercvar("cl_particle_TR_ROCKET_smoke_notunderwater", "1");
	registercvar("cl_particle_TR_ROCKET_smoke_originjitter", "2 2 2");
	registercvar("cl_particle_TR_ROCKET_smoke_rotate", "-180 180 -30 30");
	registercvar("cl_particle_TR_ROCKET_smoke_sizeincrease", "11");
	registercvar("cl_particle_TR_ROCKET_smoke_size", "3 4");
	registercvar("cl_particle_TR_ROCKET_smoke_teamcolor", "2");
	registercvar("cl_particle_TR_ROCKET_smoke_tex", "0 8");
	registercvar("cl_particle_TR_ROCKET_smoke_trailspacing", "10");
	registercvar("cl_particle_TR_ROCKET_smoke_velocityjitter", "3 3 3");
	registercvar("cl_particle_TR_ROCKET_smoke_velocitymultiplier", "-0.020000");

	registercvar("cl_particle_TR_ROCKET_puff_type", "static");
	registercvar("cl_particle_TR_ROCKET_puff_airfriction", "8");
	registercvar("cl_particle_TR_ROCKET_puff_alpha", "100 144 588");
	registercvar("cl_particle_TR_ROCKET_puff_color", "0xffdf72 0x811200");
	registercvar("cl_particle_TR_ROCKET_puff_sizeincrease", "-30");
	registercvar("cl_particle_TR_ROCKET_puff_size", "7 7");
	registercvar("cl_particle_TR_ROCKET_puff_tex", "48 55");
	registercvar("cl_particle_TR_ROCKET_puff_trailspacing", "4");
	registercvar("cl_particle_TR_ROCKET_puff_velocityjitter", "32 32 32");
	registercvar("cl_particle_TR_ROCKET_puff_velocitymultiplier", "-1.500000");

	registercvar("cl_particle_TR_ROCKET_bubbles_type", "bubble");
	registercvar("cl_particle_TR_ROCKET_bubbles_alpha", "256 256 256");
	registercvar("cl_particle_TR_ROCKET_bubbles_bounce", "1.500000");
	registercvar("cl_particle_TR_ROCKET_bubbles_gravity", "-0.125000");
	registercvar("cl_particle_TR_ROCKET_bubbles_liquidfriction", "4");
	registercvar("cl_particle_TR_ROCKET_bubbles_size", "1 2");
	registercvar("cl_particle_TR_ROCKET_bubbles_tex", "62 62");
	registercvar("cl_particle_TR_ROCKET_bubbles_trailspacing", "16");
	registercvar("cl_particle_TR_ROCKET_bubbles_underwater", "1");
	registercvar("cl_particle_TR_ROCKET_bubbles_velocityjitter", "16 16 16");
	registercvar("cl_particle_TR_ROCKET_bubbles_velocitymultiplier", "-0.310000");

	registercvar("cl_particle_TR_ROCKET_sparks_type", "spark");
	registercvar("cl_particle_TR_ROCKET_sparks_airfriction", "5");
	registercvar("cl_particle_TR_ROCKET_sparks_alpha", "444 512 1866");
	registercvar("cl_particle_TR_ROCKET_sparks_bounce", "1");
	registercvar("cl_particle_TR_ROCKET_sparks_color", "0xFFFDD9 0xFFFDD9");
	registercvar("cl_particle_TR_ROCKET_sparks_notunderwater", "1");
	registercvar("cl_particle_TR_ROCKET_sparks_originjitter", "1 1 1");
	registercvar("cl_particle_TR_ROCKET_sparks_size", "0.500000 0.500000");
	registercvar("cl_particle_TR_ROCKET_sparks_stretchfactor", "0.300000");
	registercvar("cl_particle_TR_ROCKET_sparks_tex", "40 40");
	registercvar("cl_particle_TR_ROCKET_sparks_trailspacing", "20");
	registercvar("cl_particle_TR_ROCKET_sparks_velocityjitter", "100 100 100");
	registercvar("cl_particle_TR_ROCKET_sparks_velocitymultiplier", "-0.310000");
}
#endif

#ifdef CSQC
STATIC_INIT(Effect_tr_hagar)
{
	registercvar("cl_particle_tr_hagar", "smoke puff bubbles");

	registercvar("cl_particle_tr_hagar_smoke_type", "smoke");
	registercvar("cl_particle_tr_hagar_smoke_alpha", "300 400 780");
	registercvar("cl_particle_tr_hagar_smoke_bounce", "1");
	registercvar("cl_particle_tr_hagar_smoke_color", "0x101010 0x000000");
	registercvar("cl_particle_tr_hagar_smoke_originjitter", "1 1 1");
	registercvar("cl_particle_tr_hagar_smoke_sizeincrease", "10");
	registercvar("cl_particle_tr_hagar_smoke_size", "3 2");
	registercvar("cl_particle_tr_hagar_smoke_tex", "0 8");
	registercvar("cl_particle_tr_hagar_smoke_trailspacing", "4");
	registercvar("cl_particle_tr_hagar_smoke_velocityjitter", "1 1 1");
	registercvar("cl_particle_tr_hagar_smoke_velocitymultiplier", "-0.020000");

	registercvar("cl_particle_tr_hagar_puff_type", "static");
	registercvar("cl_particle_tr_hagar_puff_airfriction", "8");
	registercvar("cl_particle_tr_hagar_puff_alpha", "100 144 988");
	registercvar("cl_particle_tr_hagar_puff_color", "0xffdf72 0x811200");
	registercvar("cl_particle_tr_hagar_puff_notunderwater", "1");
	registercvar("cl_particle_tr_hagar_puff_sizeincrease", "-15");
	registercvar("cl_particle_tr_hagar_puff_size", "5 2");
	registercvar("cl_particle_tr_hagar_puff_teamcolor", "2");
	registercvar("cl_particle_tr_hagar_puff_tex", "48 55");
	registercvar("cl_particle_tr_hagar_puff_trailspacing", "4");
	registercvar("cl_particle_tr_hagar_puff_velocityjitter", "32 32 32");
	registercvar("cl_particle_tr_hagar_puff_velocitymultiplier", "-1");

	registercvar("cl_particle_tr_hagar_bubbles_type", "bubble");
	registercvar("cl_particle_tr_hagar_bubbles_alpha", "256 256 256");
	registercvar("cl_particle_tr_hagar_bubbles_bounce", "1.500000");
	registercvar("cl_particle_tr_hagar_bubbles_color", "0x404040 0x808080");
	registercvar("cl_particle_tr_hagar_bubbles_gravity", "-0.125000");
	registercvar("cl_particle_tr_hagar_bubbles_liquidfriction", "4");
	registercvar("cl_particle_tr_hagar_bubbles_size", "1 1");
	registercvar("cl_particle_tr_hagar_bubbles_tex", "62 62");
	registercvar("cl_particle_tr_hagar_bubbles_trailspacing", "16");
	registercvar("cl_particle_tr_hagar_bubbles_underwater", "1");
	registercvar("cl_particle_tr_hagar_bubbles_velocityjitter", "16 16 16");
}
#endif

#ifdef CSQC
STATIC_INIT(Effect_TR_GRENADE)
{
	registercvar("cl_particle_TR_GRENADE", "smoke puff bubbles");

	registercvar("cl_particle_TR_GRENADE_smoke_type", "smoke");
	registercvar("cl_particle_TR_GRENADE_smoke_alpha", "300 400 780");
	registercvar("cl_particle_TR_GRENADE_smoke_bounce", "1");
	registercvar("cl_particle_TR_GRENADE_smoke_color", "0x101010 0x000000");
	registercvar("cl_particle_TR_GRENADE_smoke_originjitter", "1 1 1");
	registercvar("cl_particle_TR_GRENADE_smoke_sizeincrease", "10");
	registercvar("cl_particle_TR_GRENADE_smoke_size", "3 2");
	registercvar("cl_particle_TR_GRENADE_smoke_tex", "0 8");
	registercvar("cl_particle_TR_GRENADE_smoke_trailspacing", "4");
	registercvar("cl_particle_TR_GRENADE_smoke_velocityjitter", "1 1 1");
	registercvar("cl_particle_TR_GRENADE_smoke_velocitymultiplier", "-0.020000");

	registercvar("cl_particle_TR_GRENADE_puff_type", "static");
	registercvar("cl_particle_TR_GRENADE_puff_airfriction", "8");
	registercvar("cl_particle_TR_GRENADE_puff_alpha", "100 144 988");
	registercvar("cl_particle_TR_GRENADE_puff_color", "0xffdf72 0x811200");
	registercvar("cl_particle_TR_GRENADE_puff_notunderwater", "1");
	registercvar("cl_particle_TR_GRENADE_puff_sizeincrease", "-15");
	registercvar("cl_particle_TR_GRENADE_puff_size", "5 2");
	registercvar("cl_particle_TR_GRENADE_puff_teamcolor", "2");
	registercvar("cl_particle_TR_GRENADE_puff_tex", "48 55");
	registercvar("cl_particle_TR_GRENADE_puff_trailspacing", "4");
	registercvar("cl_particle_TR_GRENADE_puff_velocityjitter", "32 32 32");
	registercvar("cl_particle_TR_GRENADE_puff_velocitymultiplier", "-1");

	registercvar("cl_particle_TR_GRENADE_bubbles_type", "bubble");
	registercvar("cl_particle_TR_GRENADE_bubbles_alpha", "256 256 256");
	registercvar("cl_particle_TR_GRENADE_bubbles_bounce", "1.500000");
	registercvar("cl_particle_TR_GRENADE_bubbles_color", "0x404040 0x808080");
	registercvar("cl_particle_TR_GRENADE_bubbles_gravity", "-0.125000");
	registercvar("cl_particle_TR_GRENADE_bubbles_liquidfriction", "4");
	registercvar("cl_particle_TR_GRENADE_bubbles_size", "1 1");
	registercvar("cl_particle_TR_GRENADE_bubbles_tex", "62 62");
	registercvar("cl_particle_TR_GRENADE_bubbles_trailspacing", "16");
	registercvar("cl_particle_TR_GRENADE_bubbles_underwater", "1");
	registercvar("cl_particle_TR_GRENADE_bubbles_velocityjitter", "16 16 16");
}
#endif
