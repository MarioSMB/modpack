#include "horde.qh"

#include "triggers/teleporters.qh"

/*
================
HordeGetPlayersAlive

added Aug31 2021
Returns a float for the number of living players
================
*/
int HordeGetPlayersAlive()
{
	int playercount = 0;
	FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0,
	{
		playercount += 1;
	});
	
	return playercount;
}

/*
================
HordeGetMonstersAlive

added Oct28 2021
Manually counts all living monsters
================
*/
int HordeGetMonstersAlive()
{
	int monstercount = 0;
	FOREACH_ENTITY_STRING(category, "monster",
	{
		if(it.health > 0 && !(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
			monstercount += 1;
	});
	
	return monstercount;
}
/*
================
HordeFindTarget

added Aug31 2021
Returns a random living player
================
*/
entity HordeFindTarget()
{
	if(HordeGetPlayersAlive() == 0)
		return NULL;

	RandomSelection_Init();
	FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !it.deadflag && !(it.flags & FL_NOTARGET),
	{
		RandomSelection_AddEnt(it, 1, 1);
	});
	return RandomSelection_chosen_ent;
}


/*QUAKED info_monster_start START_OFF
if targeted, it will toggle between on or off, like lights 
*/
const int SKIP_BLOCK_CHECK = BIT(1);
void monster_start_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & START_OFF)
		this.spawnflags &= ~START_OFF;
	else
		this.spawnflags |= START_OFF;
}

spawnfunc(info_monster_start)
{
	if(!MP_MG) { delete(this); return; }
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-80 -80 0', '80 80 128');
}

spawnfunc(info_monster_start_ranged) // used for ogres and enforcers
{
	if(!MP_MG) { delete(this); return; }
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-44 -44 0', '44 44 128');
}

spawnfunc(info_monster_start_flying) // used exclusively for scrags (wizards)
{
	if(!MP_MG) { delete(this); return; }
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-80 -80 0', '80 80 128');
}

spawnfunc(info_monster_start_boss) // used for shalraths and shamblers
{
	if(!MP_MG) { delete(this); return; }
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-44 -44 0', '44 44 128');
}

// ENTITY
spawnfunc(info_horde_ammo)
{
	if(!MP_MG) { delete(this); return; }
	//this.wait = false;
	setthink(this, SpawnAmmo);
	this.nextthink = time + HORDE_START_DELAY + random() * 3;
}

// ENTITY
spawnfunc(info_horde_item)
{
	if(!MP_MG) { delete(this); return; }
	this.wait = false;
}

const int KEY_FIRST = BIT(0);
const int KEY_SECOND = BIT(1);
const int KEY_THIRD = BIT(2);
const int KEY_FOURTH_PLUS = BIT(3);

// ENTITY
spawnfunc(info_horde_key)
{
	if(!MP_MG) { delete(this); return; }
	this.wait = false;
}
//============================================================================
void PrecacheMonsters()
{
	// zombies
	precache_model("progs/zombie.mdl");
	precache_model("progs/h_zombie.mdl");
	precache_model("progs/zom_gib.mdl");

	precache_sound("zombie/z_idle.wav");
	precache_sound("zombie/z_idle1.wav");
	precache_sound("zombie/z_shot1.wav");
	precache_sound("zombie/z_gib.wav");
	precache_sound("zombie/z_pain.wav");
	precache_sound("zombie/z_pain1.wav");
	precache_sound("zombie/z_fall.wav");
	precache_sound("zombie/z_miss.wav");
	precache_sound("zombie/z_hit.wav");
	precache_sound("zombie/idle_w2.wav");	

	
	// ammo
	precache_model("maps/b_shell1.bsp");
	precache_model("maps/b_shell0.bsp");
	precache_model("maps/b_nail1.bsp");
	precache_model("maps/b_nail0.bsp");
	precache_model("maps/b_rock1.bsp");
	precache_model("maps/b_rock0.bsp");
	precache_model("maps/b_batt1.bsp");
	precache_model("maps/b_batt0.bsp");
	
	// items
	precache_model("maps/b_bh10.bsp"); // rotten health
	precache_sound("items/r_item1.wav");
	precache_model("maps/b_bh25.bsp"); // regular health
	precache_sound("items/health1.wav");
	precache_model("progs/armor.mdl"); // regular armor
	
	// quad damage
	precache_model("progs/quaddama.mdl");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");
	
	// pentagram (invulnerability)
	precache_model("progs/invulner.mdl");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");
	
	// precache keys
	if(world.worldtype == WORLDTYPE_MEDIEVAL || world.worldtype == WORLDTYPE_HUB)
	{
		precache_sound("misc/medkey.wav");
		precache_model("progs/w_g_key.mdl"); // gold key
		precache_model("progs/w_s_key.mdl"); // silver key
	}
	if(world.worldtype == WORLDTYPE_METAL)
	{
		precache_sound("misc/runekey.wav");
		precache_model("progs/m_g_key.mdl");
		precache_model("progs/m_s_key.mdl");
	}
	if(world.worldtype == WORLDTYPE_BASE)
	{
		precache_sound2("misc/basekey.wav");
		precache_model2("progs/b_g_key.mdl");
		precache_model2("progs/b_s_key.mdl");
	}
}
// =================================================================
void GibMonster(entity this)
{
	T_Damage(this, NULL, NULL, 4000, DEATH_GENERIC.m_id);
}
// =================================================================
/*
================
SpawnMonster
================
*/
spawnfunc(monster_zombie);
void zombie_stand1(entity this);
void zombie_walk1(entity this);
void zombie_run1(entity this);
void zombie_pain(entity this, entity attacker, float damage, int deathtype);
void zombie_die(entity this, entity inflictor, entity attacker, int deathtype);
void zombie_missile(entity this);
void monster_use(entity this, entity actor, entity trigger);
entity SpawnMonster(entity this, Monster mon, vector org, vector temp_angles)
{
	if(!mon || mon == MON_Null || (mon.spawnflags & MONSTER_TYPE_DECOY))
		return NULL;
	entity monster = new(monster);
	monster.monsterdef = mon;
	monster.spawnfunc_checked = true;
	monster.angles = temp_angles; 
	monster.solid = SOLID_SLIDEBOX;
	set_movetype(monster, MOVETYPE_STEP);
	//monster.target = "horde_manager";
	monster.flags = FL_MONSTER;
	//monster.alpha = 1; // only set monster alpha after they're a corpse

	if(mon.spawnflags & MONSTER_TYPE_SWIM) { monster.flags |= FL_SWIM; }
	if(mon.spawnflags & MONSTER_TYPE_FLY) { monster.flags |= FL_FLY; }

	if(!(monster.flags & FL_SWIM))
	{
		IL_PUSH(g_damagedbycontents, monster);
		monster.damagedbycontents	= true;
	}

	// perform enemy-type specific loading
	setmodel(monster, mon.m_model);
	setsize(monster, mon.m_mins, mon.m_maxs);
	org.z += -mon.m_mins.z; // offset based on size
	// TODO: zombie logic too messy to work with mr_setup for now!
	if(mon == MON_ZOMBIE)
	{
		monster.classname = "monster_zombie";
		//org += '0 0 32';
		monster.health = 60;
		monster.th_stand = zombie_stand1;
		monster.th_walk = zombie_walk1;
		monster.th_run = zombie_run1;
		monster.th_pain = zombie_pain;
		monster.th_die = zombie_die;
		monster.th_missile = zombie_missile;
		monster.target = string_null; // don't target anything!
	}
	mon.mr_setup(mon, monster);

	// finish the shared settings
	setorigin(monster, org + '0 0 1');

	setcefc(monster, monster_customize);
	
	if(!(mon.spawnflags & MONSTER_TYPE_FLY))
		droptofloor(monster);
	
	tracebox(monster.origin, monster.mins, monster.maxs, monster.origin, MOVE_NOMONSTERS, monster);
	if(trace_startsolid)
		LOG_DEBUG("Monster in wall at ", vtos(monster.origin), "\n");
	
	monster.category = CATEGORY_MONSTER;
	monster.takedamage = DAMAGE_AIM;
	monster.ideal_yaw = monster.angles * '0 1 0';
	if(!monster.yaw_speed)
		monster.yaw_speed = 20;
	monster.view_ofs = '0 0 25';
	monster.use = monster_use;

	monster.enemy = HordeFindTarget(); // find a random living player
	//monster.enemy = find (NULL, classname, "player");
	setthink(monster, FoundTarget);
		
	//monster.nextthink = monster.nextthink + 0.1;
	monster.nextthink = time + 0.1;
	
	spawn_tdeath_fast(monster.origin, monster);
	//spawn_tfog(monster.origin);
	
	monster.owner = this;
	if(!(mon.spawnflags & MONSTER_TYPE_UNDEAD)) // don't count zombies toward total goal
		monsters_total += 1;

	return monster;
}

void horde_ammo_touch(entity this, entity toucher)
{
	// early exit touch if not a player or not alive
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	
	// if the player was using their best weapon, change up to the new one if better		
	int best_weapon = W_BestWeapon(toucher, 0);
	
	// if player is at max ammo for ammo's type, return
	if(((this.weapon == 1) && (toucher.ammo_shells >= 100)) || // shotgun
		((this.weapon == 2) && (toucher.ammo_nails >= 200)) || // nailgun
		((this.weapon == 3) && (toucher.ammo_rockets >= 100)) || // rockets
		((this.weapon == 4) && (toucher.ammo_cells >= 100))) // cells
		return;
		
	SendItemPickup(toucher, this.items, this.aflag);
	
	// ammo touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	// change to a better weapon if appropriate
	if(toucher.weaponentity.m_weapon.m_id == best_weapon)
		W_SwitchWeapon(toucher, W_BestWeapon(toucher, 0));

	// loop through all players and give ammo
	entity temp_player = find(NULL, classname, "player");
	while(temp_player)
	{
		if(temp_player.health > 0) // only give ammo to living players
		{
			if(this.weapon == 1) // shotgun
				temp_player.ammo_shells += this.aflag;
			else if(this.weapon == 2) // spikes
				temp_player.ammo_nails += this.aflag;
			else if(this.weapon == 3) // rockets
				temp_player.ammo_rockets += this.aflag;
			else if(this.weapon == 4) // cells
				temp_player.ammo_cells += this.aflag;

			// temp swap and set bounds
			bound_other_ammo(temp_player);
			
			// temp swap again and set current ammo
			W_SetCurrentAmmo(temp_player);
		}
		temp_player = find(temp_player, classname, "player");
	}
	
	// remove
	this.model = string_null;
	this.solid = SOLID_NOT;
	// AY dec06 2021
	//this.owner.wait = false; The Old Way
	setthink(this.owner, SpawnAmmo);
	this.owner.nextthink = time + HORDE_AMMO_RESPAWN_DELAY;
	// end AY
	delete(this);
}

void horde_health_touch(entity this, entity toucher)
{	
	if(!IS_PLAYER(toucher))
		return;
	
	if(!T_Heal(toucher, this.healamount, 0))
		return;
	
	// NOTE: disabling spammy message as you already know from the HUD that you got it!
	//sprint(toucher, sprintf("You receive %d health\n", this.healamount));
	
	// health touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	
	this.model = string_null;
	this.solid = SOLID_NOT;
	this.owner.wait = false;
	delete(this);
}

void horde_armor_touch(entity this, entity toucher)
{
	float type = 0.3, value = 100;
	int bit = IT_ARMOR1;
	
	if(toucher.health <= 0)
		return;
	if(!IS_PLAYER(toucher))
		return;

	if(this.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
		bit = IT_ARMOR1;
	}
	if(this.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
		bit = IT_ARMOR2;
	}
	if(this.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
		bit = IT_ARMOR3;
	}
	if(toucher.armortype * toucher.armorvalue >= type * value)
		return;
		
	toucher.armortype = type;
	toucher.armorvalue = value;
	toucher.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
	toucher.items |= bit;

	this.solid = SOLID_NOT;
	this.model = string_null;
	// NOTE: disabling spammy message as you already know from the HUD that you got it!
	//sprint(toucher, "You got armor\n");
// armor touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.owner.wait = false;
	delete(this);
}

void horde_print_keys()
{
	LOG_DEBUGF("%d silver keys : %d gold keys", keys_silver, keys_gold);
}

void horde_set_keys(entity temp_player)
{
	// player has just respawned, reset their keys based on global key values
	if(keys_silver > 0)
		temp_player.items |= IT_KEY1;
	
	if(keys_gold > 0)
		temp_player.items |= IT_KEY2;
}
	

void horde_key_give_all(int key_item)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.items |= key_item;
	});

	horde_print_keys();
}

void horde_key_remove_all(int key_item)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.items &= ~key_item;
	});

	horde_print_keys();
}

void horde_key_give(int key_item)
{
	if(key_item & IT_KEY1)
	{
		keys_silver++;
		if(keys_silver == 1)
			horde_key_give_all(IT_KEY1);
	}
	else if(key_item & IT_KEY2)
	{
		keys_gold++;
		if(keys_gold == 1)
			horde_key_give_all(IT_KEY2);
	}
	horde_print_keys();
}

void horde_key_spend(float key_item)
{
	if(key_item & IT_KEY1)
	{
		keys_silver--;
		if(keys_silver == 0)
			horde_key_remove_all(IT_KEY1);
	}
	else if(key_item & IT_KEY2)
	{
		keys_gold--;
		if(keys_gold == 0)
			horde_key_remove_all(IT_KEY2);
	}
	horde_print_keys();
}

void horde_key_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

	string keyname = (this.netname != "") ? this.netname : "key";
	Send_Notification(NOTIF_ALL_EXCEPT, toucher, MSG_MULTI, ITEM_KEY_GOT, toucher.netname, keyname);
	Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_KEY_GOT_SELF, keyname);
	
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	
	horde_key_give(this.items);
	
	// find the horde manager and trigger the next wave
	if(key_spawned)
	{
		//LOG_DEBUG("key triggers next wave");
		horde_ent.wait = true;
		setthink(horde_ent, Countdown);
		horde_ent.nextthink = time;
	}
	//else
		//LOG_DEBUG("key shouldn't trigger next wave!");
	delete(this);
}

void SpawnAmmo(entity this)
{
	vector pos = this.origin;
	entity item = spawn();
	
	// roll a d4, a 1 means big ammo.
	bool is_big = ((random() * 4) <= 1); 
	
	if(is_big)
		pos = pos - '16 16 0';
	else
		pos = pos - '12 12 0';
	
	// NEW: roll a d20, 1-8 is shells, 9-14 is spikes, 14-17 is rockets, 18-20 is cells
	// OLD: roll a d12, 1-5 is shells, 6-10 is spikes, 11 is rockets, 12 is cells
	/*
		ITEM		New %		Old %
		shells		40%			41.66%
		spikes		30%			33.33%
		rockets		20%			8.33 %
		cells		10%			8.33 %
	*/
	float r = random() * 20;
	if(r <= 7) // shells
	{
		item.classname = "item_shells";
		if(is_big)
		{
			_setmodel(item, "maps/b_shell1.bsp");
			item.aflag = 40;
		}
		else
		{
			_setmodel(item, "maps/b_shell0.bsp");
			item.aflag = 20;
		}
		item.weapon = 1;
		item.items = IT_SHELLS;
		item.netname = "shells";
	}
	else if(r <= 14) // spikes
	{
		item.classname = "item_spikes";
		if(is_big)
		{
			_setmodel(item, "maps/b_nail1.bsp");
			item.aflag = 50;
		}
		else
		{
			_setmodel(item, "maps/b_nail0.bsp");
			item.aflag = 25;
		}
		item.weapon = 2;
		item.items = IT_NAILS;
		item.netname = "nails";
	}
	else if(r <= 17) // rockets
	{
		item.classname = "item_rockets";
		if(is_big)
		{
			_setmodel(item, "maps/b_rock1.bsp");
			item.aflag = 10;
		}
		else
		{
			_setmodel(item, "maps/b_rock0.bsp");
			item.aflag = 5;
		}
		item.weapon = 3;
		item.items = IT_ROCKETS;
		item.netname = "rockets";
	}
	else // cells
	{
		item.classname = "item_cells";
		if(is_big)
		{
			_setmodel(item, "maps/b_batt1.bsp");
			item.aflag = 12;
		}
		else
		{
			_setmodel(item, "maps/b_batt0.bsp");
			item.aflag = 6;
		}
		item.weapon = 4;
		item.items = IT_CELLS;
		item.netname = "cells";
	}
	setorigin (item, pos + '0 0 1');
	setsize(item, '0 0 0', '32 32 56');
	item.owner = this;
	this.wait = true;
	set_movetype(item, MOVETYPE_TOSS);
	item.solid = SOLID_TRIGGER;
	item.flags = FL_ITEM;
	settouch(item, horde_ammo_touch);
	
	spawn_tfog_silent(pos + '0 0 8'); // added aug30
}

void SpawnItem(entity this)
{
	entity item = spawn();
	
	vector pos = this.origin; // set to origin, then offset as needed

	float r = random() * 6; 
	if(r < 3) // rotten health
	{
		item.classname = "item_health";
		settouch(item, horde_health_touch);
		_setmodel(item, "maps/b_bh10.bsp");
		item.noise = "items/r_item1.wav";
		item.healamount = 15;
		item.healtype = 0;
		setsize(item, '0 0 0', '32 32 56');
		//pos = pos - '16 16 0';
	}
	if(r < 5) // regular health
	{
		item.classname = "item_health";
		settouch(item, horde_health_touch);
		_setmodel(item, "maps/b_bh25.bsp");
		item.noise = "items/health1.wav";
		item.healamount = 25;
		item.healtype = 1;
		setsize(item, '0 0 0', '32 32 56');
		pos = pos - '16 16 0';
	}
	else // armor
	{
		item.classname = "item_armor1";
		settouch(item, horde_armor_touch);
		item.armortype = 0.3;
		item.armorvalue = 100;
		_setmodel(item, "progs/armor.mdl");
		item.skin = 0;
		setsize(item, '-16 -16 0', '16 16 56');
	}

	setorigin(item, pos + '0 0 1');
	item.owner = this;
	this.wait = true;	
	set_movetype(item, MOVETYPE_TOSS);
	item.solid = SOLID_TRIGGER;
	item.flags = FL_ITEM;
	//item.think = PlaceItem;
	//item.nextthink = time + 0.1;
	spawn_tfog_silent(pos + '0 0 8'); // added aug30
}

/* Spawn Key
A key should spawn after every boss wave.

*/
void SpawnKey(entity this, bool is_gold)
{
	entity item = spawn();
	
	if(is_gold)
	{
		item.items = IT_KEY2;
		
		// set model and sound based on worldtype
		if(world.worldtype == WORLDTYPE_METAL)
		{
			item.netname = "gold runekey";
			item.noise = "misc/runekey.wav";
			_setmodel(item, "progs/m_g_key.mdl");
			centerprint_all("Gold runekey appears!");
		}
		else if(world.worldtype == WORLDTYPE_BASE)
		{
			item.netname = "gold keycard";
			item.noise = "misc/basekey.wav";
			_setmodel(item, "progs/b_g_key.mdl");
			centerprint_all("Gold keycard appears!");
		}
		else // assume medieval
		{
			item.netname = "gold key";
			item.noise = "misc/medkey.wav";
			_setmodel(item, "progs/w_g_key.mdl");
			centerprint_all("Gold key appears!");
		}
	}
	else
	{
		item.items = IT_KEY1;
		
		// set model and sound based on worldtype
		if(world.worldtype == WORLDTYPE_METAL)
		{
			item.netname = "silver runekey";
			item.noise = "misc/runekey.wav";
			_setmodel(item, "progs/m_s_key.mdl");
			centerprint_all("Silver runekey appears!");
		}
		else if(world.worldtype == WORLDTYPE_BASE)
		{
			item.netname = "silver keycard";
			item.noise = "misc/basekey.wav";
			_setmodel(item, "progs/b_s_key.mdl");
			centerprint_all("Silver keycard appears!");
		}
		else // assume medieval
		{
			item.netname = "silver key";
			item.noise = "misc/medkey.wav";
			_setmodel(item, "progs/w_s_key.mdl");
			centerprint_all("Silver key appears!");
		}

	}
	//item.noise = "misc/medkey.wav";
	setsize(item, '-16 -16 -25', '16 16 32');
	settouch(item, horde_key_touch);
	//item.think = PlaceItem;
	//item.nextthink = time + 0.2;
	item.target = "horde_manager"; // when used, retrigger the horde manager
	item.flags = FL_ITEM;		// make extra wide
	//item.flags = item.flags & FL_NOBOTS; // AY 11 Nov 2021 so bots can't get keys
	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_TOSS);
	setorigin(item, this.origin + '0 0 32');
	item.velocity = '0 0 255';
	
	// AY Feb22, 2022, rune keys shouldn't have light effects on them
	if(world.worldtype != WORLDTYPE_METAL)
		item.effects = EF_BRIGHTLIGHT;
	
	//dprint("     spawned key\n");
	spawn_tfog(item.origin);
	key_spawned = 1;
}

void SpawnGoldKey(entity this)
{
	SpawnKey(this, true);
}
	
void SpawnSilverKey(entity this)
{
	SpawnKey(this, false);
}

// Function get a key given the current wave
// Wave 3 should return a key with spawnflag "KEY_FIRST"
// Wave 6 should return a key with spawnflag "KEY_SECOND"
// Wave 9 should return a key with spawnflag "KEY_THIRD"
// Wave 9+ should return a key with spawnflag "KEY_FOURTH_PLUS"
// If a key with the correct spawnflag isn't found, return any key
void GetKey(entity this)
{
	entity t = find(NULL, classname, "info_horde_key");
	entity l = t; // save ref for later
	
	// check if any keys exist
	if(!t)
	{
		LOG_DEBUG("ERROR: No info_horde_key!");
		// continue as if player got the key
		setthink(this, Countdown);
		this.nextthink = time + 4;
		return;
	}
	
	while(t)
	{
		if(this.wave <= 3) // looking for KEY_FIRST
		{
			if(t.spawnflags & KEY_FIRST)
			{
				setthink(t, SpawnSilverKey);
				t.nextthink = time;
				return;
			}
		}
		else if(this.wave <= 6) // looking for KEY_SECOND
		{
			if(t.spawnflags & KEY_SECOND)
			{
				setthink(t, SpawnSilverKey);
				t.nextthink = time;
				return;
			}
		}
		else if(this.wave <= 9) // looking for KEY_THIRD
		{
			if(t.spawnflags & KEY_THIRD)
			{
				setthink(t, SpawnGoldKey);
				t.nextthink = time;
				return;
			}
		}
		else // looking for KEY_FOURTH_PLUS
		{
			// check next key
			if(t.spawnflags & KEY_FOURTH_PLUS)
			{
				setthink(t, SpawnSilverKey);
				t.nextthink = time;
				return;
			}
		}
		t = find(t, classname, "info_horde_key");
	}
	
	// didn't find key with matching spawnflag, return any key
	LOG_DEBUG("didn't find key with matching spawnflag. Return last: ", l.classname);
	
	if(this.wave == 9)
		setthink(l, SpawnGoldKey);
	else
		setthink(l, SpawnSilverKey);
	l.nextthink = time;
}

vector Horde_GetOffset(int number)
{
	switch(number)
	{
		case 0: return '40 0 0';
		case 1: return '0 -40 0';
		case 2: return '0 40 0';
		case 3: return '-40 0 0';
		case 4: return '40 40 0';
		case 5: return '40 -40 0';
		case 6: return '-40 40 0';
		case 7: return '-40 -40 0';
	}
	return '0 0 0';
}

//============================================================================
/* 
SpawnSquad2

Yoder FEB02 2022
*/
void SpawnSquad2(entity this, string name, vector org, vector temp_angles)
{
	if(!name || name == "")
	{
		LOG_DEBUG("ERROR: empty squad name!");
		return;
	}
	int monstercount = 0;
	int argc = tokenize_console(name);
	for(int j = 0; j < argc; ++j)
	{
		int spawncount = stof(argv(j));
		if(spawncount == 0)
			continue; // not a number
		string next = argv(j + 1);
		Monster mon = Monster_from_name(next);
		if(mon == MON_Null)
		{
			LOG_DEBUG("ERROR: invalid squad monster name ", next);
			j += 1;
			continue; // continue though just incase it was a misnamed monster
		}
		for(int moncnt = 0; moncnt < spawncount; ++moncnt)
		{
			SpawnMonster(this, mon, org + Horde_GetOffset(monstercount), temp_angles);
			monstercount += 1; // for offsets
		}
		j += 1; // skip the next token
	}
	
	spawn_tfog(org);
}

/*
HordeFindSpawnpoint

Yoder February 2nd 2022
*/
const int HORDE_SQUAD_TYPE_NORMAL = 0;
const int HORDE_SQUAD_TYPE_RANGED = 1;
const int HORDE_SQUAD_TYPE_FLYING = 2;
const int HORDE_SQUAD_TYPE_BOSS = 3;

const int HORDE_SQUAD_CAT_ERROR = -1;
const int HORDE_SQUAD_CAT_FODDER = 0;
const int HORDE_SQUAD_CAT_ELITE = 1;
const int HORDE_SQUAD_CAT_BOSS = 2;

entity HordeFindSpawnpoint(float squad_type)
{
	int spawnpoint = 0;
	int loopcount = 0;
	string squad_class;
	
	if(squad_type == HORDE_SQUAD_TYPE_BOSS)
		squad_class = "info_monster_start_boss";
	else if(squad_type == HORDE_SQUAD_TYPE_FLYING)
		squad_class = "info_monster_start_flying";
	else if(squad_type == HORDE_SQUAD_TYPE_RANGED)
		squad_class = "info_monster_start_ranged";
	else
		squad_class = "info_monster_start";
	
	// STEP 1: count all spawns of spawn type
	int temp_spawncount = 0;
	int temp_spawncount_valid = 0; // how many of the spawn points are valid

	// count the spawnpoints for squad_class
	entity t = find(NULL, classname, squad_class);
	while (t)
	{
		temp_spawncount += 1;
		if(time > t.wait && !(t.spawnflags & START_OFF) && !CheckBlockedSpawn(t))
			temp_spawncount_valid += 1;
		t = find(t, classname, squad_class);
	}
	
	// verify against 0 valid spawns
	if(temp_spawncount_valid <= 0)
	{
		if(squad_type == HORDE_SQUAD_TYPE_NORMAL)
		{
			LOG_DEBUG("HordeFindSpawnPoint: FOUND 0 Valid spawns");
			return NULL; // already on fallback option, oops
		}
		else
		{
			squad_type = HORDE_SQUAD_TYPE_NORMAL;
			squad_class = "info_monster_start";
			t = NULL;
			loopcount = 1;
		}
	}
	
	// count again, but for Normal spawn points?
	if(loopcount)
	{
		temp_spawncount = 0;
		temp_spawncount_valid = 0;
		
		t = find(NULL, classname, squad_class);
		while(t)
		{
			temp_spawncount += 1;
			if(time > t.wait && !(t.spawnflags & START_OFF) && !CheckBlockedSpawn(t))
				temp_spawncount_valid += 1;
			t = find(t, classname, squad_class);
		}
	}
	
	// verify against 0 valid spawns
	if(temp_spawncount_valid <= 0)
	{
		LOG_DEBUG("HordeFindSpawnPoint: FOUND 0 Valid spawns after recheck");
		return NULL; // already on fallback option, oops
	}
	
	// pick random spawncount
	loopcount = 0;
	float randomspawn = temp_spawncount * random();
	LOG_DEBUGF("randomspawn: %d | whole count: %d | valid count: %d", randomspawn, randomspawn, temp_spawncount, temp_spawncount_valid);
	t = find(NULL, classname, squad_class);
	while(t)
	{
		spawnpoint += 1;
		if(spawnpoint >= randomspawn)
		{
			if(!(t.spawnflags & START_OFF) && (time > t.wait) && (!(CheckBlockedSpawn(t))))
			{
				LOG_DEBUG("picked spawnpoint: ", ftos(spawnpoint));
				return t;
			}
		}
		t = find(t, classname, squad_class);
		
		if(!t)
		{
			if(loopcount)
				LOG_DEBUG("something has gone horribly wrong!");
			else
			{
				loopcount = 1;
				
				t = find(t, classname, squad_class);
				spawnpoint = 0;
				randomspawn = 0; // allow any valid spawn
			}
		}
	}
	return NULL;
}

entity Horde_GetSquadEntity(entity this, int spawntype)
{
	RandomSelection_Init();
	IL_EACH(g_squads, it.spawnflags & spawntype,
	{
		if(autocvar_skill < 3 && (it.spawnflags & HORDE_HARD))
			continue;
		if(autocvar_skill > 1 && (it.spawnflags & HORDE_EASY))
			continue;
		if((it.spawnflags & HORDE_FINALBOSS) && this.wave != 9)
			continue;
		if((it.spawnflags & HORDE_ARMY) && !this.army)
			continue;
		if(!(it.spawnflags & HORDE_ARMY) && this.army)
			continue;
		// final boss will be given priority over other boss spawns
		float prio = (it.spawnflags & HORDE_FINALBOSS) ? 2 : 1;
		RandomSelection_AddEnt(it, 1, prio);
	});
	return RandomSelection_chosen_ent;
}

/*
SpawnWave2

Instead of finding a spawn point and then spawning a squad,
decide a squad, and then find a spawn point.
Yoder February 2nd 2022
*/
void SpawnWave2(entity this)
{
	int squad_type = 0;
	string squad_name = string_null; // specific squad name
	int squad_cat = 0;
	entity squad = NULL;
	
	//STEP 1: determine what kind of monster is getting spawned
	if(this.fodder > 0)
	{
		squad = Horde_GetSquadEntity(this, HORDE_FODDER);
		squad_cat = HORDE_SQUAD_CAT_FODDER;
	}
	else if(this.elites > 0)
	{
		squad = Horde_GetSquadEntity(this, HORDE_ELITE);
		squad_cat = HORDE_SQUAD_CAT_ELITE;
	}
	else if(this.bosses > 0)
	{
		squad = Horde_GetSquadEntity(this, HORDE_BOSS);
		squad_cat = HORDE_SQUAD_CAT_BOSS;
	}

	if(!squad)
	{
		LOG_INFO("ERROR: unable to find a squad!");
		squad_cat = HORDE_SQUAD_CAT_ERROR;
	}
	else
	{
		squad_name = squad.netname;
		squad_type = squad.cnt;
	}

	//STEP 2: find a spawn point for the squad
	entity t = HordeFindSpawnpoint(squad_type);
	//LOG_DEBUG("spawnpoint found was: ", t.classname);
	if(t && (squad_cat != HORDE_SQUAD_CAT_ERROR))
	{
		t.wait = time + SPAWN_RESET_TIME; // block spawnpoint from reuse for a duration
		
		SUB_UseTargets(t, NULL, NULL);
		
		// set angles, just in case
		if(!t.angles)
			t.angles = '0 0 0';
		
		SpawnSquad2(this, squad_name, t.origin, t.angles);
		
		if(squad_cat == HORDE_SQUAD_CAT_FODDER)
			this.fodder--;
		else if(squad_cat == HORDE_SQUAD_CAT_ELITE)
			this.elites--;
		else if(squad_cat == HORDE_SQUAD_CAT_BOSS)
			this.bosses--;
		
		if((this.fodder + this.elites + this.bosses) <= 0) // max spawns hit
		{
			LOG_DEBUG("wave spawn completed!");
			this.wait = false;
			setthink(this, Wavecheck);
			this.nextthink = time + 30;
		}
		else
		{
			// normal spawnwave wait time
			setthink(this, SpawnWave2);
			this.nextthink = time + 1 + random() + 1;
		}
	}
	else
	{
		LOG_DEBUG("no valid spawns, wait a moment");
		setthink(this, SpawnWave2);
		this.nextthink = time + 1;
	}
}

/* SpawnWavePrep
called once at the countdown starts
determines the number of squads by type
also spawns ammo and items
*/
bool SpawnWavePrep(entity this)
{
	// Reset Key Spawn
	key_spawned = false;
	int playercount = HordeGetPlayersAlive();
	
	// Respawn dead players!
	if(playercount < 1)
	{
		LOG_DEBUG("WARNING: Last player died at round end, don't start new round!");
		return 0;
	}
	
	// Items
	FOREACH_ENTITY_CLASS("info_horde_item", !it.wait,
	{
		setthink(it, SpawnItem);
		it.nextthink = time + random() * 2;
	});

	this.wave++;
	LOG_DEBUG("wave ", ftos(this.wave));
	
	// See spreadsheet for notes on squad scaling
	
	// AY FEB07 scaling start wave based on difficulty
	int temp_wave;
	if(autocvar_skill >= 3)
		temp_wave = this.wave + 6;
	else if(autocvar_skill >= 2)
		temp_wave = this.wave + 3;
	else
		temp_wave = this.wave;
	
	// Determine if Army wave
	if((temp_wave + 2) % 3 == 0)
		this.army = true;
	else
		this.army = false;
	
	// player scalar
	float playerscalar;
	if(playercount >= 4)
		playerscalar = 2;
	else if(playercount >= 3)
		playerscalar = 1.5;
	else if(playercount >= 2)
		playerscalar = 1.25;
	else
		playerscalar = 1;
	
	// Boss Count
	if((temp_wave % 3) == 0)
	{
		this.bosses = floor((temp_wave+1)/4);
	}
	else if((autocvar_skill > 1) && (!this.army) && (temp_wave > 9))
	{
		//AY feb07, some extra spice
		this.bosses = floor((temp_wave+1)/8);
	}
	
	// Elite Count
	this.elites = ceil((temp_wave - 1)/3) - floor(this.bosses/2);
	this.elites = floor(this.elites * playerscalar);
	
	// Fodder Count
	this.fodder = (temp_wave + 2) - (this.bosses * 2 + this.elites);
	this.fodder = floor(this.fodder * playerscalar);
	
	// Trigger map entities
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		if(it.use)
			it.use(it, NULL, NULL);
	});

	this.wait = true;
	return 1;
}

void horde_squad_setup(entity this)
{
	if(!MP_MG) { delete(this); return; }

	if(this.spawnflags & HORDE_FINALBOSS)
		this.spawnflags |= HORDE_BOSS; // ensure also marked as boss

	if(!this.netname || this.netname == "")
		objerror(this, "horde_squad missing netname");

	IL_PUSH(g_squads, this);
}

/*QUAKED info_horde_squad FODDER ARMY ELITE BOSS FINALBOSS
horde squad data for monster spawn selection
multiple of the same type can be created to randomly select between them
*/
spawnfunc(info_horde_squad)
{
	this.cnt = HORDE_SQUAD_TYPE_NORMAL;
	horde_squad_setup(this);
}
spawnfunc(info_horde_squad_ranged)
{
	this.cnt = HORDE_SQUAD_TYPE_RANGED;
	horde_squad_setup(this);
}
spawnfunc(info_horde_squad_flying)
{
	this.cnt = HORDE_SQUAD_TYPE_FLYING;
	horde_squad_setup(this);
}
spawnfunc(info_horde_squad_boss)
{
	this.cnt = HORDE_SQUAD_TYPE_BOSS;
	horde_squad_setup(this);
}

void Countdown4(entity this)
{
	if((this.wave % 3) == 0)
		//centerprint_all("Boss wave!");
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_BEGIN_BOSSWAVE);
	else
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_BEGIN);
		//centerprint_all("Fight!");
	SpawnWave2(this);
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
}
void Countdown3(entity this)
{
	//centerprint_all("1");
	Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_ROUNDSTART, 1, this.wave);
	setthink(this, Countdown4);
	this.nextthink = time + 1;
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
}
void Countdown2(entity this)
{
	//centerprint_all("2");
	Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_ROUNDSTART, 2, this.wave);
	setthink(this, Countdown3);
	this.nextthink = time + 1;
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
}
void Countdown(entity this)
{
	if(!SpawnWavePrep(this))
		return;
	
	//centerprint_all("3");
	Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_ROUNDSTART, 3, this.wave);
	setthink(this, Countdown2);
	this.nextthink = time + 1;
	
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
}

void RespawnAllPlayers()
{
	FOREACH_CLIENT(IS_PLAYER(it) && it.deadflag != DEAD_NO,
	{
		horde_respawn_teammate(it);
	});
}

/*
When each enemy spawned by the horde manager dies, they trigger this.owner.use, which is wavecheck.
Wavecheck sees if all spawned monsters are dead, so it can determine if it needs to start a new wave.
*/
void Wavecheck(entity this)
{
	if(this.wait) // still in the process of spawning monsters, don't wavecheck
		return;
		
	setthink(this, Wavecheck);
	this.nextthink = time + 10;

	LOG_DEBUGF("\n===============\nchecking kills: %d of %d", monsters_killed, monsters_total);

	// debug checking last monster position
	if(monsters_killed + 3 >= monsters_total)
	{
		entity t = find(NULL, category, CATEGORY_MONSTER);
		while(t)
		{
			if(t.health > 0)
				LOG_DEBUGF("Position of monster: %s : %v", t.classname, t.origin);
			else
				t.category = string_null;
			t = find(t, category, CATEGORY_MONSTER);
		}
	}
	
	// Early exit for kill count
	if((this.wave % 3 == 0) || (this.wave < 3)) // Be exact?
	{
		LOG_DEBUG("check monsters killed as boss wave");
		if(HordeGetMonstersAlive() > 0) // testing the new way
			return;
		//if(monsters_killed < monsters_total) 
		//	return;
	}
	else
	{
		LOG_DEBUG("check monsters killed as any other wave");
		if(HordeGetMonstersAlive() > 5)
			return;
		//if(monsters_killed < (monsters_total -5)) 
		//	return;
	}
	
	// Made it this far, means wave completed successfully
	LOG_DEBUG("wavecheck looks good! Respawning players");
	RespawnAllPlayers();
	
	this.wait = 1;
	setthink(this, Countdown);
	
	if((this.wave % 3) == 0) // it was a boss wave
	{
		if(!key_spawned) // key was already spawned, don't spawn another yet!
			GetKey(this);

		this.nextthink = time + 20; // in case the players are slow to find the key
	}
	else
	{
		this.nextthink = time;
	}
	LOG_DEBUG("wavecheck now completed.");
}

void Wavecheck_use(entity this, entity actor, entity trigger)
{
	Wavecheck(this);
}

void Horde_SpawnSquadEntity(int spawntype, int spawncat, string list)
{
	entity squad = new(horde_squad);
	squad.netname = list;
	squad.cnt = spawncat;
	squad.spawnflags = spawntype;
	horde_squad_setup(squad);
}

void Horde_SetupSquads()
{
	// if map entities are found they are preferred
	// otherwise spawn in any that are missing to fill in any gaps
	bool found = false;

	// army wave setup

	found = false;
	IL_EACH(g_squads, (it.spawnflags & HORDE_ARMY) && (it.spawnflags & HORDE_FODDER), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "3 grunt");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "2 grunt");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "2 grunt 1 dog");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "2 dog");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 dog");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_RANGED, "1 enforcer");
	}

	found = false;
	IL_EACH(g_squads, (it.spawnflags & HORDE_ARMY) && (it.spawnflags & HORDE_ELITE), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "2 enforcer");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 ogre");
		if(MP_HIPNOTIC)
		{
			Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 scourge");
		}
		if(MP_ROGUE)
		{
			Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 sword");
		}
		if(MP_IMPEL)
		{
			Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 lenforcer");
		}
	}

	// no bosses spawn during army waves


	// non-army wave setup

	found = false;
	IL_EACH(g_squads, !(it.spawnflags & HORDE_ARMY) && (it.spawnflags & HORDE_FODDER), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "2 knight");
		Horde_SpawnSquadEntity(HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "2 zombie");
		Horde_SpawnSquadEntity(HORDE_FODDER, HORDE_SQUAD_TYPE_FLYING, "1 wizard");
		if(MP_HIPNOTIC)
		{
			Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "1 gremlin");
		}
	}

	found = false;
	IL_EACH(g_squads, !(it.spawnflags & HORDE_ARMY) && (it.spawnflags & HORDE_ELITE), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 hknight");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 hknight");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 knight 1 hknight");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 ogre");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_FLYING, "3 wizard");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_FLYING, "2 wizard");
		if(MP_ROGUE)
		{
			Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 wrath");
		}
		if(MP_IMPEL)
		{
			Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 dknight");
			Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_HARD, HORDE_SQUAD_TYPE_NORMAL, "2 knight 1 dknight");
			Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_HARD, HORDE_SQUAD_TYPE_FLYING, "2 grenling");
		}
	}

	found = false;
	IL_EACH(g_squads, (it.spawnflags & HORDE_BOSS) && !(it.spawnflags & HORDE_FINALBOSS), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "1 shambler");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_NORMAL, "2 demon");
		Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 demon");
		Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_HARD, HORDE_SQUAD_TYPE_NORMAL, "2 shambler");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "1 shalrath");
		if(MP_ROGUE)
		{
			Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "2 wrath");
			Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_HARD, HORDE_SQUAD_TYPE_BOSS, "1 overlord");
		}
		if(MP_IMPEL)
		{
			Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_HARD, HORDE_SQUAD_TYPE_BOSS, "1 juggernaut");
			Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_FLYING, "2 grenling");
		}
	}
}

// setup horde rules
void SetHorde(entity this)
{
	setthink(this, Countdown);
	this.nextthink = time + 1;

	Horde_SetupSquads();
}

// define entity 
spawnfunc(horde_manager)
{
	if(!MP_MG) { delete(this); return; }
	// AY, Dec06 2021, auto set horde cvar
	if(!autocvar_horde && !deathmatch)
		cvar_set("horde", "1");
	// end AY
	
	precache_sound("misc/talk.wav");
	PrecacheMonsters();
	
	horde_ent = this; // set global reference to the horde manager
	
	if(!this.target || this.target == "")
		this.target = "horde_event"; // default name

	this.targetname = "horde_manager";
	setthink(this, SetHorde);
	this.nextthink = time + HORDE_START_DELAY;
	this.use = Wavecheck_use;
	
	this.wait = 1; // waiting before next wave?
	this.delay = 9; // max number of  squads to spawn in a wave
	this.wave = 0;
	
	//if(!horde)
	//	horde = 1; // in case CVAR isn't already set
}

void PowerupFade(entity this)
{
	if(this.alpha > 0)
	{
		this.alpha = this.alpha - 0.25 * frametime;
		this.nextthink = time; // think next frame
	}
	else
		delete(this);
}

void horde_powerup_think(entity this)
{
	if(this.velocity_z < 0)
	{
		LOG_DEBUG("WARNING: Powerup fell out of world. Remove");
		delete(this);
	}
	else
	{
		this.alpha = 1;
		setthink(this, PowerupFade);
		this.nextthink = time;
	}
}

void horde_spawn_powerup(entity this)
{
	if(!powerup_chance)
		powerup_chance = DEFAULT_POWERUP_CHANCE;
	
	if(random() < powerup_chance) // "if(1)" to guarantee powerup drop
	{
		LOG_DEBUG("powerup chance was: ", ftos(powerup_chance));
		
		powerup_chance = DEFAULT_POWERUP_CHANCE;
		
		entity powerup = spawn();
		setorigin(powerup, this.origin + '0 0 0');

		//setsize(powerup, '-16 -16 -24', '16 16 32');
		powerup.flags = FL_ITEM;
		powerup.solid = SOLID_TRIGGER;
		set_movetype(powerup, MOVETYPE_BOUNCE);
		powerup.velocity = '0 0 300';
		
		//powerup.velocity_x = crandom() * 64;
		//powerup.velocity_y = crandom() * 64;
		settouch(powerup, powerup_touch);
		setthink(powerup, horde_powerup_think);
		powerup.nextthink = time + 10;
		
		if(random() < 0.25) // spawn pentagram (invulnerability)
		{
			powerup.noise = "items/protect.wav";
			_setmodel(powerup, "progs/invulner.mdl");
			powerup.netname = "Pentagram of Protection";
			powerup.powerups = POWERUP_INVULNERABILITY;
			powerup.classname = "item_artifact_invulnerability";
		}
		else // spawn quad damage
		{
			powerup.noise = "items/damage.wav";
			_setmodel(powerup, "progs/quaddama.mdl");
			powerup.netname = "Quad Damage";
			powerup.powerups = POWERUP_QUAD;
			powerup.classname = "item_artifact_super_damage";
		}
		//powerup.effects = EF_DIMLIGHT;
		
		setsize(powerup, '-12 -12 -12', '12 12 12');
	}
	else
		powerup_chance = powerup_chance + POWERUP_CHANCE_GAIN;
}

// remote wavecheck
// this is to trigger a wavecheck from outside of horde mode
void remote_wavecheck(entity this)
{
	if(!horde_ent || (intermission_running))
	{
		LOG_DEBUG("no wavecheck.", ((!horde_ent) ? " no horde ent found." : ""), ((intermission_running) ? " intermission running." : ""));
		return;
	}
	LOG_DEBUG("remote wavecheck from: ", this.classname);
	horde_ent.use(horde_ent, NULL, NULL);
}

/* CheckBlockedSpawn
AY Feb24, 2022
Checks the horde spawn against all living players
Returns true/false if spawn is blocked.
*/
bool CheckBlockedSpawn(entity spawnpoint)
{
	if(spawnpoint.spawnflags & SKIP_BLOCK_CHECK)
		return false;

	FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && it.deadflag == DEAD_NO,
	{
		vector p_mins = it.origin + it.mins;
		vector p_maxs = it.origin + it.maxs;
		vector s_mins = spawnpoint.origin + spawnpoint.mins;
		vector s_maxs = spawnpoint.origin + spawnpoint.maxs;
				
		if(((p_maxs.x > s_mins.x) && (p_mins.x < s_maxs.x)) &&
			((p_maxs.y > s_mins.y) && (p_mins.y < s_maxs.y)) &&
			((p_maxs.y > s_mins.y) && (p_mins.y < s_maxs.y)))
		{
			//LOG_DEBUG("player blocking spawn");
			return true;
		}
	});
	return false;
}
