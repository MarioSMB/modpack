#ifdef STATUS_EFFECT
STATUS_EFFECT(BURNING,STAT_TYPE_NEGATIVE,"burning","Burning");
STATUS_EFFECT(DROWNING,STAT_TYPE_NEGATIVE | STAT_TYPE_NOTIMER,"drowning","Drowning");
STATUS_EFFECT(SPAWNSHIELD,STAT_TYPE_POSITIVE,"spawnshield","Spawn shielded");
#else

// unfortunately, these can't be dynamic
// use stats 190-214
const float STAT_STATUSEFFECT_BURNING = 190;
const float STAT_STATUSEFFECT_DROWNING = 191;
const float STAT_STATUSEFFECT_SPAWNSHIELD = 192;

#ifdef SVQC

void ResetStatusEffects(entity ent)
{
	StatusEffect(ent, STATUS_EFFECT_BURNING) = 0;
	StatusEffect(ent, STATUS_EFFECT_DROWNING) = 0;
	StatusEffect(ent, STATUS_EFFECT_SPAWNSHIELD) = time + autocvar_g_spawnshieldtime; // hax
}

void StatusEffects_AddStats()
{
	addstat(STAT_STATUSEFFECT_BURNING, AS_FLOAT, stat_statuseffect_STATUS_EFFECT_BURNING);
	addstat(STAT_STATUSEFFECT_DROWNING, AS_FLOAT, stat_statuseffect_STATUS_EFFECT_DROWNING);
	addstat(STAT_STATUSEFFECT_SPAWNSHIELD, AS_FLOAT, stat_statuseffect_STATUS_EFFECT_SPAWNSHIELD);
}

#endif

#ifdef CSQC

float StatusEffect_Stat(float id)
{
	switch(id)
	{
		case STATUS_EFFECT_BURNING: return STAT_STATUSEFFECT_BURNING;
		case STATUS_EFFECT_DROWNING: return STAT_STATUSEFFECT_DROWNING;
		case STATUS_EFFECT_SPAWNSHIELD: return STAT_STATUSEFFECT_SPAWNSHIELD;
	}
	
	return 0;
}

#endif

void register_status_effect(float id, float type, string shortname, string name)
{
	entity e;
	status_effect_info[id - 1] = e = spawn();
	e.classname = "status_effects_info";
	e.netname = shortname;
	e.message = name;
	e.spawnflags = type;
}
void register_status_effects_done()
{
	dummy_statuseffects_info = spawn();
	dummy_statuseffects_info.classname = "status_effects_info";
	dummy_statuseffects_info.netname = "";
	dummy_statuseffects_info.message = "Unknown";
	dummy_statuseffects_info.spawnflags = 0;
}
entity get_statuseffectinfo(float id)
{
	entity w;
	if(id < STATUS_EFFECT_FIRST || id > STATUS_EFFECT_LAST)
		return dummy_statuseffects_info;
	w = status_effect_info[id - 1];
	if(w)
		return w;
	return dummy_statuseffects_info;
}

#endif