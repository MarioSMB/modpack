#ifdef SVQC

const int PLAYER_ONLY = BIT(0);
const int SILENT = BIT(1);
const int CTF_ONLY = BIT(2); // rogue
const int IGNORE_TARGETNAME = BIT(2); // mg

const int SPAWN_NO_TFRAG = 64;

void spawn_tfog(vector org)
{
	soundat(NULL, org, CH_TRIGGER, SND(TELE_RANDOM()), 1, ATTEN_NORM);
	te_teleport(org);
}

void spawn_tfog_silent(vector org)
{
	te_teleport(org);
}

void tdeath_touch(entity this, entity toucher)
{
	// ithagnal hack
	if(toucher.classname == "monster_hitbox")
		toucher = toucher.owner;

	if(toucher == this.owner)
		return;

	if((autocvar_horde || autocvar_g_friendlyfire_virtual) && IS_PLAYER(toucher))
		return;

	// Check if found a breakable than cannot be broken
	if(ai_foundbreakable(this, toucher, false))
		return;

	// original owner of this teledeath has cleared its bounds, and there's 
	// no more danger of overlapping bboxes, so remove it
	vector padding = '2 2 2';
	if(!boxesoverlap(this.absmin - padding, this.absmax + padding, this.owner.absmin - padding, this.owner.absmax + padding))
	{
		settouch(this, func_null);
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}

// frag anyone who teleports in on top of an invincible player
	if(IS_PLAYER(toucher))
	{
		if(StatusEffects_active(STATUSEFFECT_Invulnerability, toucher))
			this.classname = "teledeath2";
		if(!IS_PLAYER(this.owner))
		{	// other monsters explode themselves
			T_Damage(this.owner, this, this, 50000, DEATH_TELEFRAG.m_id);
			return;
		}
	}

	if(IS_MONSTER(toucher) && (toucher.spawnflags & SPAWN_NO_TFRAG))
		return;

	if(toucher.health)
		T_Damage(toucher, this, this.owner, 50000, DEATH_TELEFRAG.m_id);
}


entity spawn_tdeath(vector org, entity death_owner)
{
	entity death = spawn();
	death.classname = "teledeath";
	set_movetype(death, MOVETYPE_NONE);
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	vector padding = '0.1 0.1 0.1';
	setsize(death, death_owner.mins - padding, death_owner.maxs + padding);
	setorigin(death, org);
	settouch(death, tdeath_touch);
	death.nextthink = time + 0.2;
	setthink(death, SUB_Remove);
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
	return death;
}

// Yoder sept24 2021 horde merge
// a faster version of tdeath to minimize telefragging 
void spawn_tdeath_fast(vector org, entity death_owner)
{
	entity death = spawn_tdeath(org, death_owner);
	death.nextthink = time + 0.01;
}

#endif
