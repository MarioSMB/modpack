#ifdef SVQC

const int PLAYER_ONLY = BIT(0);
const int SILENT = BIT(1);
const int CTF_ONLY = BIT(2); // rogue
const int IGNORE_TARGETNAME = BIT(2); // mg

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
	if(toucher == this.owner)
		return;

// frag anyone who teleports in on top of an invincible player
	if(IS_PLAYER(toucher))
	{
		if(toucher.invincible_finished > time)
			this.classname = "teledeath2";
		if(!IS_PLAYER(this.owner))
		{	// other monsters explode themselves
			T_Damage(this.owner, this, this, 50000);
			return;
		}
		
	}

	if(toucher.health)
		T_Damage(toucher, this, this, 50000);
}


entity spawn_tdeath(vector org, entity death_owner)
{
	entity death = spawn();
	death.classname = "teledeath";
	set_movetype(death, MOVETYPE_NONE);
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize(death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
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
