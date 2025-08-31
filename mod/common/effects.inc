// Global list of effects, networked to CSQC by ID to save bandwidth and to use client particle numbers (allows mismatching effectinfos to some degree)

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
//EFFECT(0, MARIO,                    "mario")
// effect handled by code
#ifdef CSQC
STATIC_INIT(Effect_SHOTGUN_WOOSH)
{
	effect_cvar("shotgun_woosh", "puff");
	effect_cvar("shotgun_woosh_puff_type", "smoke");
	effect_cvar("shotgun_woosh_puff_alpha", "32 192 512");
	effect_cvar("shotgun_woosh_puff_bounce", "0.100000");
	effect_cvar("shotgun_woosh_puff_color", "0x111111 0x979797");
	effect_cvar("shotgun_woosh_puff_count", "24");
	effect_cvar("shotgun_woosh_puff_notunderwater", "1");
	effect_cvar("shotgun_woosh_puff_originjitter", "8.0 8.0 8.0");
	effect_cvar("shotgun_woosh_puff_sizeincrease", "14");
	effect_cvar("shotgun_woosh_puff_size", "1 12");
	effect_cvar("shotgun_woosh_puff_tex", "0 8");
	effect_cvar("shotgun_woosh_puff_velocityjitter", "64 64 32");
	effect_cvar("shotgun_woosh_puff_velocitymultiplier", "1");
}
#endif
