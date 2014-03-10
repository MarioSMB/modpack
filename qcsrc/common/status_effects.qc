#ifdef STATUS_EFFECT
STATUS_EFFECT(BURNING, STAT_TYPE_NEGATIVE, stat_effect_burning, '1 0.1 0', "burning", _("Burning"));
STATUS_EFFECT(DROWNING, STAT_TYPE_NEGATIVE | STAT_TYPE_NOTIMER, stat_effect_drowning, '0 0.5 1', "drowning", _("Drowning"));
STATUS_EFFECT(SPAWNSHIELD, STAT_TYPE_POSITIVE, stat_effect_spawnshield, '0.5 0.5 0.5', "spawnshield", _("Shielded"));
STATUS_EFFECT(COLD, STAT_TYPE_NEGATIVE, stat_effect_cold, '0 0.75 1', "cold", _("Cold"));
STATUS_EFFECT(FROZEN, STAT_TYPE_NEGATIVE | STAT_TYPE_NOTIMER, stat_effect_frozen, '0 0.6 1', "frozen", _("Frozen"));
#else

#ifdef SVQC

void ResetStatusEffects(entity ent)
{
	float i;
	for(i = STATUS_EFFECT_FIRST; i <= STATUS_EFFECT_LAST; ++i)
	if(i == STATUS_EFFECT_SPAWNSHIELD)
		StatusEffect(ent, i) = time + autocvar_g_spawnshieldtime; // hax
	else
		StatusEffect(ent, i) = 0;
}

void StatusEffects_AddStats()
{
	float i;
	for(i = STATUS_EFFECT_FIRST; i <= STATUS_EFFECT_LAST; ++i)
		addstat(StatusEffect_IDToStat(i), AS_FLOAT, ((StatusEffectInfo(i)).effect_stat));
}

void ApplyStatusEffect(entity ent, float id, float dur, float dam)
{
	StatusEffect(ent, id) = dur;
	ent.status_effect_damage[id] = dam;
}

#endif

float StatusEffect_IDToStat(float id)
{
	switch(id)
	{
		case STATUS_EFFECT_BURNING: return STAT_STATUS_EFFECT_BURNING;
		case STATUS_EFFECT_DROWNING: return STAT_STATUS_EFFECT_DROWNING;
		case STATUS_EFFECT_SPAWNSHIELD: return STAT_STATUS_EFFECT_SPAWNSHIELD;
		case STATUS_EFFECT_COLD: return STAT_STATUS_EFFECT_COLD;
		case STATUS_EFFECT_FROZEN: return STAT_STATUS_EFFECT_FROZEN;
	}
	
	return 0;
}

void register_status_effect(float id, float type, .float thestat, vector clr, string shortname, string name)
{
	entity e;
	status_effect_info[id - 1] = e = spawn();
	e.classname = "status_effects_info";
	e.netname = shortname;
	e.message = name;
	e.spawnflags = type;
	e.colormod = clr;
	e.effect_stat = thestat;
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