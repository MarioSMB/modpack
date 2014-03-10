#ifdef STATUS_EFFECT
STATUS_EFFECT(BURNING,STAT_TYPE_NEGATIVE,'1 0.1 0',"burning",_("Burning"));
STATUS_EFFECT(DROWNING,STAT_TYPE_NEGATIVE | STAT_TYPE_NOTIMER,'0 0.5 1',"drowning",_("Drowning"));
STATUS_EFFECT(SPAWNSHIELD,STAT_TYPE_POSITIVE,'0.5 0.5 0.5',"spawnshield",_("Shielded"));
STATUS_EFFECT(COLD,STAT_TYPE_NEGATIVE,'0 0.75 1',"cold",_("Cold"));
#else

// unfortunately, these can't be dynamic
// use stats 180-214
const float STAT_STATUSEFFECT_BURNING = 180;
const float STAT_STATUSEFFECT_DROWNING = 181;
const float STAT_STATUSEFFECT_SPAWNSHIELD = 182;
const float STAT_STATUSEFFECT_COLD = 183;

#ifdef SVQC

void ResetStatusEffects(entity ent)
{
	StatusEffect(ent, STATUS_EFFECT_BURNING) = 0;
	StatusEffect(ent, STATUS_EFFECT_DROWNING) = 0;
	StatusEffect(ent, STATUS_EFFECT_SPAWNSHIELD) = time + autocvar_g_spawnshieldtime; // hax
	StatusEffect(ent, STATUS_EFFECT_COLD) = 0;
}

void StatusEffects_AddStats()
{
	addstat(STAT_STATUSEFFECT_BURNING, AS_FLOAT, stat_STATUS_EFFECT_BURNING);
	addstat(STAT_STATUSEFFECT_DROWNING, AS_FLOAT, stat_STATUS_EFFECT_DROWNING);
	addstat(STAT_STATUSEFFECT_SPAWNSHIELD, AS_FLOAT, stat_STATUS_EFFECT_SPAWNSHIELD);
	addstat(STAT_STATUSEFFECT_COLD, AS_FLOAT, stat_STATUS_EFFECT_COLD);
}

.float StatusEffects_GetStat(float id)
{
	switch(id)
	{
		case STATUS_EFFECT_BURNING: return stat_STATUS_EFFECT_BURNING;
		case STATUS_EFFECT_DROWNING: return stat_STATUS_EFFECT_DROWNING;
		case STATUS_EFFECT_SPAWNSHIELD: return stat_STATUS_EFFECT_SPAWNSHIELD;
		case STATUS_EFFECT_COLD: return stat_STATUS_EFFECT_COLD;
	}
	
	return status_dummy;
}

#endif

float StatusEffect_Stat(float id)
{
	switch(id)
	{
		case STATUS_EFFECT_BURNING: return STAT_STATUSEFFECT_BURNING;
		case STATUS_EFFECT_DROWNING: return STAT_STATUSEFFECT_DROWNING;
		case STATUS_EFFECT_SPAWNSHIELD: return STAT_STATUSEFFECT_SPAWNSHIELD;
		case STATUS_EFFECT_COLD: return STAT_STATUSEFFECT_COLD;
	}
	
	return 0;
}

void register_status_effect(float id, float type, vector clr, string shortname, string name)
{
	entity e;
	status_effect_info[id - 1] = e = spawn();
	e.classname = "status_effects_info";
	e.netname = shortname;
	e.message = name;
	e.spawnflags = type;
	e.colormod = clr;
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