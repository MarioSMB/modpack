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
