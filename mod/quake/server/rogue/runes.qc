// Rogue Runes
// Jan'97 by ZOID <zoid@threewave.com>
// Under contract to id software for Rogue Entertainment

.int rune;		// what rune does this guy have?
.float runetime;	// last time we told him he's already got a rune

.float rune1_last_noise_time;
.float rune2_last_noise_time;
.float rune3_last_noise_time;
.float rune4_last_regen_time;

bool runespawn;	// have we spawned runes?
entity rune_spawn_spot; // spawn spot for runes

const int ITEM_RUNE1 = BIT(0);	// Rune of Earth Magic:  Resistance
const int ITEM_RUNE2 = BIT(1);	// Rune of Black Magic:  Strength
const int ITEM_RUNE3 = BIT(2);	// Rune of Hell Magic:   Haste
const int ITEM_RUNE4 = BIT(3);	// Rune of Edler Magic:  Regeneration

//prototypes

void RuneTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) || toucher.health <= 0)
		return;
	
	if(toucher.rune)
	{
		if(toucher.runetime < time)
			centerprint(toucher, "You already have a rune\n");
		toucher.runetime = time + 5;
		return;
	}

	toucher.rune |= this.rune;

	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);

	if(this.rune & ITEM_RUNE1)
		centerprint(toucher, "Earth Magic\n\nRESISTANCE");
	else if(this.rune & ITEM_RUNE2)
		centerprint(toucher, "Black Magic\n\nSTRENGTH");
	else if(this.rune & ITEM_RUNE3)
		centerprint(toucher, "Hell Magic\n\nHASTE");
	else if(this.rune & ITEM_RUNE4)
		centerprint(toucher, "Elder Magic\n\nREGENERATION");
	delete(this);
}

entity RuneSpawnPoint()
{
	while (1)
	{
		rune_spawn_spot = find(rune_spawn_spot, classname, "info_player_deathmatch");

		if(rune_spawn_spot != NULL)
			return rune_spawn_spot;
	}

	return NULL;
}

void RuneRespawn(entity this)
{
	entity spot = RuneSpawnPoint(); // assume success, there *must* be a spawnpoint in the map!
	setorigin(this, spot.origin);
	this.velocity = vec3(-300 + (random() * 600), -300 + (random() * 600), 300);

	this.nextthink = time + 120;
}

void SpawnRune(float r, entity spot)
{
	if(spot == NULL)
		spot = RuneSpawnPoint();

	entity item = spawn();
	
	setorigin(item, spot.origin);
	item.rune = r;
	item.velocity = vec3(-300 + (random() * 600), -300 + (random() * 600), 300);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_TOSS);

	if(r & ITEM_RUNE1) 
		_setmodel(item, "progs/end1.mdl");
	else if(r & ITEM_RUNE2) 
		_setmodel(item, "progs/end2.mdl");
	else if(r & ITEM_RUNE3) 
		_setmodel(item, "progs/end3.mdl");
	else if(r & ITEM_RUNE4) 
		_setmodel(item, "progs/end4.mdl");

	setsize(item, '-16 -16 0', '16 16 56');
	settouch(item, RuneTouch);
	
	item.nextthink = time + 120;	// remove after 2 minutes
	setthink(item, RuneRespawn);
}

// 'this' is player
void DropRune(entity this)
{
	if(this.rune & ITEM_RUNE1) 
		SpawnRune(ITEM_RUNE1, this);
	if(this.rune & ITEM_RUNE2) 
		SpawnRune(ITEM_RUNE2, this);
	if(this.rune & ITEM_RUNE3) 
		SpawnRune(ITEM_RUNE3, this);
	if(this.rune & ITEM_RUNE4) 
		SpawnRune(ITEM_RUNE4, this);
	this.rune = 0;
}

// 'this' isn't player
void DoSpawnRunes(entity this)
{
	delete(this);

	SpawnRune(ITEM_RUNE1, NULL);
	SpawnRune(ITEM_RUNE2, NULL);
	SpawnRune(ITEM_RUNE3, NULL);
	SpawnRune(ITEM_RUNE4, NULL);
}

void SpawnRunes(entity this)
{
	if(!deathmatch || !(cvar("gamecfg") & GAMECFG_ENABLE_RUNES) || runespawn)
		return;

	runespawn = true;
	entity spawner = spawn();
	setthink(spawner, DoSpawnRunes);
	spawner.nextthink = time + 0.1;
}

float RuneApplyEarth(float damage, entity who)
{
	if(!(who.rune & ITEM_RUNE1))
		return damage;

	if(who.rune1_last_noise_time < time)
	{
		_sound(who, CH_TRIGGER_SINGLE, "runes/end1.wav", 1, ATTN_NORM);
		// tune as needed
		who.rune1_last_noise_time = time + 1.0;
	}
	return damage/2;
}

void RuneApplyBlackNoise(entity who)
{
	if(!(who.rune & ITEM_RUNE2))
		return;

	if(who.rune2_last_noise_time < time)
	{
		_sound(who, CH_TRIGGER_SINGLE, "runes/end2.wav", 1, ATTN_NORM);
		// tune as needed
		who.rune2_last_noise_time = time + 1.0;
	}
}

float RuneApplyBlack(float damage, entity who)
{
	if(who.rune & ITEM_RUNE2)
		return damage * 2;
	return damage;
}

float RuneApplyHell(float tvalue, entity who)
{
	if(!(who.rune & ITEM_RUNE3))
		return tvalue;

	if (who.rune3_last_noise_time < time)
	{
		_sound(who, CH_TRIGGER_SINGLE, "runes/end3.wav", 1, ATTN_NORM);
		// tune as needed
		who.rune3_last_noise_time = time + 1.0;
	}
	return (tvalue * 2) / 3;
}

void RuneApplyElder(entity who)
{
	if(!(who.rune & ITEM_RUNE4))
		return;

	if (who.rune4_last_regen_time < time && who.health < 100)
	{
		_sound(who, CH_TRIGGER_SINGLE, "runes/end4.wav", 1, ATTN_NORM);
		who.health = who.health + 5;
		if (who.health > 100)
			who.health = 100;
		who.rune4_last_regen_time = time + 1.0;
	}
}

bool RuneHasElder(entity who)
{
	return (who.rune & ITEM_RUNE4);
}

void RunePrecache()
{
	if(!cvar("deathmatch"))
		return;

	if(cvar("gamecfg") & GAMECFG_ENABLE_RUNES)
	{
		precache_model("progs/end1.mdl");
		precache_model("progs/end2.mdl");
		precache_model("progs/end3.mdl");
		precache_model("progs/end4.mdl");

		precache_sound("runes/end1.wav");
		precache_sound("runes/end2.wav");
		precache_sound("runes/end3.wav");
		precache_sound("runes/end4.wav");
	}
}
