#include "horde.qh"

#include "../common/triggers/teleporters.qh"

void HordeRecord()
{
	float oldscore = top_score;
	float newscore = monsters_killed;

	if(newscore > oldscore)
	{
		top_score = newscore;
		db_put(ServerProgsDB, strcat(mapname, "/topscore/", ftos(horde_skill)), ftos(newscore));
	}
}

/*
============
HORDE random map pick

added Aug31, 2021
============
*/
string HordeRandomMap()
{
#if 0
	//dprint("go with next map in progression\n");
	if(mapname == "horde1")
		return "horde2";
	else if(mapname == "horde2")
		return "horde3";
	else if(mapname == "horde3")
		return "horde4";
	else
		return "horde1";
#endif

	if(have_hordehub)
		return "horde";

	RandomSelection_Init();
	for(int j = 0; j < 7; j++)
	{
		string themap = strcat("horde", ftos(j + 1));
		RandomSelection_AddString(themap, (mapname != themap), 1);
	}
	return RandomSelection_chosen_string;
}

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

void Horde_GiveScore(int score)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.frags += score;
	});

	HordeRecord(); // check record on each kill, update as needed!
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
	FOREACH_ENTITY_STRING(category, CATEGORY_MONSTER,
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

float horde_failed_time = 0;
void horde_StartFrame()
{
	if(!horde_ent || !horde_ent.active)
		return;

	int alivecount = 0, playercount = 0;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		playercount += 1;
		if(it.health > 0)
			alivecount += 1;
	});

	if(horde_failed_time && alivecount <= 0)
	{
		if(time > horde_failed_time)
			horde_respawn_all();
		return;
	}

	// if all players are dead, activate a timer until the match ends
	if(alivecount <= 0 && playercount > 0)
		horde_failed_time = time + 10;
	else
		horde_failed_time = 0; // reset it otherwise!
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
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-80 -80 0', '80 80 128');
}

spawnfunc(info_monster_start_ranged) // used for ogres and enforcers
{
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-44 -44 0', '44 44 128');
}

spawnfunc(info_monster_start_flying) // used exclusively for scrags (wizards)
{
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-80 -80 0', '80 80 128');
}

spawnfunc(info_monster_start_boss) // used for shalraths and shamblers
{
	this.wait = false; // used for checking if this is a valid spawn
	this.use = monster_start_use;
	setorigin(this, this.origin);	
	setsize(this, '-44 -44 0', '44 44 128');
}

// ENTITY
spawnfunc(info_horde_ammo)
{
	//this.wait = false;
	setthink(this, SpawnAmmo);
	this.nextthink = time + HORDE_START_DELAY + random() * 3;
}

// ENTITY
spawnfunc(info_horde_item)
{
	this.wait = false;
}

// SHOP
spawnfunc(info_horde_shop)
{
	shopkeep_spawn(this);
}

const int KEY_FIRST = BIT(0);
const int KEY_SECOND = BIT(1);
const int KEY_THIRD = BIT(2);
const int KEY_FOURTH_PLUS = BIT(3);

// ENTITY
spawnfunc(info_horde_key)
{
	this.wait = false;
}

void qonquer_replace(entity this, Monster mon)
{
	entity ent = spawn();
	setorigin(ent, this.origin);
	ent.spawnfunc_checked = true;
	// since qonquer only supports vanilla monsters, we have a baseline for compatibility
	switch(mon)
	{
		default:
			spawnfunc_info_monster_start(ent);
			break;
		case MON_FIEND:
		case MON_VORE:
		case MON_SHAMBLER:
			spawnfunc_info_monster_start_boss(ent);
			break;
		case MON_OGRE:
		case MON_ENFORCER:
			spawnfunc_info_monster_start_ranged(ent);
			break;
		case MON_SCRAG:
			spawnfunc_info_monster_start_flying(ent);
			break;
	}
}

bool qonquer_monstercompat(entity this, Monster mon)
{
	if(!(this.spawnflags & 8))
		return false;
	if(horde_ent.currentammo)
	{
		qonquer_replace(this, mon);
		return true;
	}
	return false;
}

bool qonquer_ammoreplace(entity this)
{
	if(horde_ent.currentammo)
	{
		entity ent = spawn();
		setorigin(ent, this.origin);
		ent.spawnfunc_checked = true;
		spawnfunc_info_horde_ammo(ent);
		return true;
	}
	return false;
}

bool qonquer_itemreplace(entity this)
{
	if(horde_ent.currentammo)
	{
		entity ent = spawn();
		setorigin(ent, this.origin);
		ent.spawnfunc_checked = true;
		spawnfunc_info_horde_item(ent);
		return true;
	}
	return false;
}
//============================================================================
void PrecacheMonsters()
{
	// ammo
	precache_model("maps/b_shell1.bsp");
	precache_model("maps/b_shell0.bsp");
	precache_model("maps/b_nail1.bsp");
	precache_model("maps/b_nail0.bsp");
	precache_model("maps/b_rock1.bsp");
	precache_model("maps/b_rock0.bsp");
	precache_model("maps/b_batt1.bsp");
	precache_model("maps/b_batt0.bsp");
	precache_model("maps/b_plas1.bsp");
	precache_model("maps/b_plas0.bsp");
	precache_model("maps/b_lnail1.bsp");
	precache_model("maps/b_lnail0.bsp");
	precache_model("maps/b_mrock1.bsp");
	precache_model("maps/b_mrock0.bsp");
	
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

	// fire flower
	precache_model("progs/fireball.mdl");
	precache_sound("items/fireball_fire.wav");

	// horn
	precache_model("progs/horn.mdl");
	precache_sound("hipitems/horn.wav");

	// vsphere
	precache_model("progs/sphere.mdl");
	precache_sound("sphere/sphere.wav");

	// fieldgen
	precache_model("progs/fieldgen.mdl");
	precache_sound("weapons/field/genlev.wav");
	precache_sound("weapons/field/genpulse.wav");
	precache_sound("weapons/field/genhit1.wav");
	precache_sound("weapons/field/genhit2.wav");
	precache_sound("weapons/field/genhit3.wav");
	precache_sound("weapons/field/genactiv.wav");
	precache_sound("weapons/field/genstop.wav");

	// shield
	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");
	precache_sound("shield/pickup.wav");
	precache_sound("shield/hit.wav");
	precache_sound("shield/fadeout.wav");

	// empathy shields
	precache_model("progs/empathy.mdl");
	precache_sound("hipitems/empathy.wav");
	precache_sound("hipitems/empathy2.wav");
	precache_sound("items/suit2.wav");

	// jump boots
	precache_model("progs/jumpblue.mdl");
	precache_sound("items/jboots_got_timed.wav");
	precache_sound("items/jboots_timed.wav");
	precache_sound("items/goomba.wav");

	// sharp shooter
	precache_model("progs/artifact_sharp.mdl");
	precache_sound("items/sharp.wav");
	precache_sound("items/sharp2.wav");
	precache_sound("items/sharp3.wav");

	// revival
	precache_model("progs/revival.mdl");
	precache_sound("items/revival.wav");

	// tank
	precache_model("progs/g_tank.mdl");

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
		precache_sound("misc/basekey.wav");
		precache_model("progs/b_g_key.mdl");
		precache_model("progs/b_s_key.mdl");
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
	//monster.target = "horde_manager";
	monster.flags = FL_MONSTER;
	//monster.alpha = 1; // only set monster alpha after they're a corpse

	if(mon.spawnflags & MONSTER_TYPE_SWIM) { monster.flags |= FL_SWIM; }
	if(mon.spawnflags & MONSTER_TYPE_FLY) { monster.flags |= FL_FLY; }

	if(monster.flags & FL_FLY)
		set_movetype(monster, MOVETYPE_QCENTITY);
	else
		set_movetype(monster, MOVETYPE_STEP);

	if(!(monster.flags & FL_SWIM))
	{
		IL_PUSH(g_damagedbycontents, monster);
		monster.damagedbycontents	= true;
	}

	// perform enemy-type specific loading
	setmodel(monster, mon.m_model);
	setsize(monster, mon.m_mins, mon.m_maxs);
	mon.mr_setup(mon, monster);

	setup_minionsupport(monster);
	monster.health = min(monster.health, 1750); // limit health to avoid sponges

	// finish the shared settings
	org.z += -monster.mins.z; // offset based on size
	setorigin(monster, org + '0 0 1');

	setcefc(monster, monster_customize);
	
	if(!(mon.spawnflags & MONSTER_TYPE_FLY))
		DropToFloor_QC_DelayedInit(monster);
	
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
	monster.max_health = monster.health;

	monster.enemy = HordeFindTarget(); // find a random living player
	//monster.enemy = find (NULL, classname, "player");
	setthink(monster, FoundTarget);
		
	//monster.nextthink = monster.nextthink + 0.1;
	monster.nextthink = time;
	
	spawn_tdeath_fast(monster.origin, monster);
	//spawn_tfog(monster.origin);
	
	monster.owner = this;
	if(!(monster.flags & FL_CLONE) && !(mon.spawnflags & MONSTER_TYPE_UNDEAD)) // don't count zombies toward total goal
		monsters_total += 1;

	return monster;
}

void horde_ammo_refresh(entity this)
{
	this.solid = SOLID_NOT;
	if(this.owner)
	{
		setthink(this.owner, SpawnAmmo);
		this.owner.nextthink = time;
	}
	delete(this);
}

void horde_ammo_touch(entity this, entity toucher)
{
	// early exit touch if not a player or not alive
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	
	// if player is at max ammo for ammo's type, return
	bool pickedup = false;

	if(this.ammo_shells && toucher.ammo_shells < GetAmmoLimit(toucher, IT_SHELLS))
	{
		toucher.ammo_shells += this.ammo_shells;
		SendItemPickup(toucher, this.items, this.ammo_shells);
		pickedup = true;
	}
	if(this.ammo_nails && toucher.ammo_nails < GetAmmoLimit(toucher, IT_NAILS))
	{
		toucher.ammo_nails += this.ammo_nails;
		SendItemPickup(toucher, this.items, this.ammo_nails);
		pickedup = true;
	}
	if(this.ammo_rockets && toucher.ammo_rockets < GetAmmoLimit(toucher, IT_ROCKETS))
	{
		toucher.ammo_rockets += this.ammo_rockets;
		SendItemPickup(toucher, this.items, this.ammo_rockets);
		pickedup = true;
	}
	if(this.ammo_cells && toucher.ammo_cells < GetAmmoLimit(toucher, IT_CELLS))
	{
		toucher.ammo_cells += this.ammo_cells;
		SendItemPickup(toucher, this.items, this.ammo_cells);
		pickedup = true;
	}
	if(this.ammo_lava_nails && toucher.ammo_lava_nails < GetAmmoLimit(toucher, IT_LAVA_NAILS))
	{
		toucher.ammo_lava_nails += this.ammo_lava_nails;
		SendItemPickup(toucher, this.items, this.ammo_lava_nails);
		pickedup = true;
	}
	if(this.ammo_multi_rockets && toucher.ammo_multi_rockets < GetAmmoLimit(toucher, IT_MULTI_ROCKETS))
	{
		toucher.ammo_multi_rockets += this.ammo_multi_rockets;
		SendItemPickup(toucher, this.items, this.ammo_multi_rockets);
		pickedup = true;
	}
	if(this.ammo_plasma && toucher.ammo_plasma < GetAmmoLimit(toucher, IT_PLASMA_AMMO))
	{
		toucher.ammo_plasma += this.ammo_plasma;
		SendItemPickup(toucher, this.items, this.ammo_plasma);
		pickedup = true;
	}

	if(!pickedup)
		return;

	// ammo touch sound
	if(this.noise && this.noise != "")
		_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	if(toucher.cvar_cl_autoswitch)
	{
		for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			Weapon best_weapon = w_getbestweapon(toucher, weaponentity);
			if(toucher.(weaponentity).m_weapon == best_weapon)
				W_SwitchWeapon(toucher, w_getbestweapon(toucher, weaponentity), weaponentity);
			if(autocvar_g_weaponswitch_debug != 1)
				break;
		}
	}

	// loop through all players and give ammo
	FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0,
	{
		it.ammo_shells += this.ammo_shells;
		it.ammo_nails += this.ammo_nails;
		it.ammo_rockets += this.ammo_rockets;
		it.ammo_cells += this.ammo_cells;
		it.ammo_lava_nails += this.ammo_lava_nails;
		it.ammo_multi_rockets += this.ammo_multi_rockets;
		it.ammo_plasma += this.ammo_plasma;

		// temp swap and set bounds
		bound_other_ammo(it);
			
		// temp swap again and set current ammo
		W_SetCurrentAmmo(it);
	});
	
	// remove
	this.solid = SOLID_NOT;
	this.model = string_null;
	// AY dec06 2021
	//this.owner.wait = false; The Old Way
	setthink(this.owner, SpawnAmmo);
	this.owner.nextthink = time + HORDE_AMMO_RESPAWN_DELAY;
	delete(this);
}

void horde_health_touch(entity this, entity toucher)
{	
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.tank)
		return;
	if(toucher.m_transform)
		return;
	if(toucher.m_champion && toucher.m_champion.qcc_health_nopickup && this.healtype != 2)
		return;
	
	if(!T_Heal(toucher, this.healamount, 0))
		return;
	
	// NOTE: disabling spammy message as you already know from the HUD that you got it!
	//sprint(toucher, sprintf("You receive %d health\n", this.healamount));
	
	// health touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	
	this.model = string_null;
	this.solid = SOLID_NOT;
	if(this.owner)
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
	if(toucher.tank)
		return;
	if(toucher.m_transform)
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
		keys_silver += 1;
		if(keys_silver == 1)
			horde_key_give_all(IT_KEY1);
	}
	else if(key_item & IT_KEY2)
	{
		keys_gold += 1;
		if(keys_gold == 1)
			horde_key_give_all(IT_KEY2);
	}
	horde_print_keys();
}

void horde_key_spend(float key_item)
{
	if(key_item & IT_KEY1)
	{
		keys_silver -= 1;
		if(keys_silver == 0)
			horde_key_remove_all(IT_KEY1);
	}
	else if(key_item & IT_KEY2)
	{
		keys_gold -= 1;
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
	
	horde_key_give(this.items);
	
	// find the horde manager and trigger the next wave
#if 0
	if(key_spawned)
	{
		//LOG_DEBUG("key triggers next wave");
		horde_ent.wait = true;
		setthink(horde_ent, Countdown);
		horde_ent.nextthink = time;
	}
	//else
		//LOG_DEBUG("key shouldn't trigger next wave!");
#endif
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
	RandomSelection_Init();
	RandomSelection_AddFloat(IT_SHELLS, 0.4, 1);
	RandomSelection_AddFloat(IT_NAILS, 0.3, 1);
	RandomSelection_AddFloat(IT_ROCKETS, 0.2, 1);
	RandomSelection_AddFloat(IT_CELLS, 0.1, 1);
	RandomSelection_AddFloat(IT_LAVA_NAILS, 0.3, 1);
	RandomSelection_AddFloat(IT_PLASMA_AMMO, 0.1, 1);
	RandomSelection_AddFloat(IT_MULTI_ROCKETS, 0.2, 1);

	switch(RandomSelection_chosen_float)
	{
		case IT_SHELLS:
		{
			item.classname = "item_shells";
			item.noise = "weapons/lock4.wav";
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
			item.ammo_shells = item.aflag;
			item.weapon = 1;
			item.items = IT_SHELLS;
			item.netname = "shells";
			break;
		}
		case IT_NAILS:
		{
			item.classname = "item_spikes";
			item.noise = "weapons/lock4.wav";
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
			item.ammo_nails = item.aflag;
			item.weapon = 2;
			item.items = IT_NAILS;
			item.netname = "nails";
			break;
		}
		case IT_ROCKETS:
		{
			item.classname = "item_rockets";
			item.noise = "weapons/lock4.wav";
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
			item.ammo_rockets = item.aflag;
			item.weapon = 3;
			item.items = IT_ROCKETS;
			item.netname = "rockets";
			break;
		}
		// old code defaulted to cells, so we will too!
		default:
		case IT_CELLS:
		{
			item.classname = "item_cells";
			item.noise = "weapons/lock4.wav";
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
			item.ammo_cells = item.aflag;
			item.weapon = 4;
			item.items = IT_CELLS;
			item.netname = "cells";
			break;
		}
		case IT_PLASMA_AMMO:
		{
			item.classname = "item_plasma";
			item.noise = "weapons/lock4.wav";
			if(is_big)
			{
				_setmodel(item, "maps/b_plas1.bsp");
				item.aflag = 12;
			}
			else
			{
				_setmodel(item, "maps/b_plas0.bsp");
				item.aflag = 6;
			}
			item.ammo_plasma = item.aflag;
			item.weapon = 7;
			item.items = IT_PLASMA_AMMO;
			item.netname = "plasma";
			break;
		}
		case IT_LAVA_NAILS:
		{
			item.classname = "item_lava_spikes";
			item.noise = "weapons/lock4.wav";
			if(is_big)
			{
				_setmodel(item, "maps/b_lnail1.bsp");
				item.aflag = 50;
			}
			else
			{
				_setmodel(item, "maps/b_lnail0.bsp");
				item.aflag = 25;
			}
			item.ammo_lava_nails = item.aflag;
			item.weapon = 5;
			item.items = IT_LAVA_NAILS;
			item.netname = "lava nails";
			break;
		}
		case IT_MULTI_ROCKETS:
		{
			item.classname = "item_multi_rockets";
			item.noise = "weapons/lock4.wav";
			if(is_big)
			{
				_setmodel(item, "maps/b_mrock1.bsp");
				item.aflag = 10;
			}
			else
			{
				_setmodel(item, "maps/b_mrock0.bsp");
				item.aflag = 5;
			}
			item.ammo_multi_rockets = item.aflag;
			item.weapon = 6;
			item.items = IT_MULTI_ROCKETS;
			item.netname = "multi rockets";
			break;
		}
	}
	setorigin (item, pos + '0 0 1');
	setsize(item, '0 0 0', '32 32 56');
	item.owner = this;
	this.wait = true;
	set_movetype(item, MOVETYPE_TOSS);
	item.solid = SOLID_TRIGGER;
	item.flags = FL_ITEM;
	settouch(item, horde_ammo_touch);
	setthink(item, horde_ammo_refresh);
	item.nextthink = time + HORDE_AMMO_RESPAWN_DELAY;
	
	spawn_tfog_silent(pos + '0 0 8'); // added aug30
}

bool health_customize(entity this, entity client);
void SpawnItem(entity this)
{
	entity item = spawn();
	
	vector pos = this.origin; // set to origin, then offset as needed

	float r = random() * 6; 
	if(r < 3) // rotten health
	{
		item.classname = "item_health";
		settouch(item, horde_health_touch);
		setcefc(item, health_customize);
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
		setcefc(item, health_customize);
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
		case 0: return '44 0 0';
		case 1: return '0 -44 0';
		case 2: return '0 44 0';
		case 3: return '-44 0 0';
		case 4: return '44 44 0';
		case 5: return '44 -44 0';
		case 6: return '-44 44 0';
		case 7: return '-44 -44 0';
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

bool horde_squad_allowed(entity this, entity squad, int bosswave, int spawntype, bool allowany)
{
	if(allowany)
		return true;

	if(!(squad.spawnflags & spawntype))
		return false;
	if(autocvar_skill < 3 && (squad.spawnflags & HORDE_HARD))
		return false;
	if(autocvar_skill > 1 && (squad.spawnflags & HORDE_EASY))
		return false;
	if((squad.spawnflags & HORDE_FINALBOSS) && ((this.wave % bosswave) != 0))
		return false;
	if((squad.spawnflags & HORDE_ARMY) && !this.army)
		return false;
	if(!(squad.spawnflags & HORDE_ARMY) && this.army)
		return false;

	return true;
}

entity Horde_GetSquadEntity(entity this, int spawntype)
{
	// finalbosses will spawn every 3 waves on nightmare! 9 otherwise
	int fbosswave = (autocvar_skill == 3) ? 3 : 9;
	bool allowany = (autocvar_skill == 3 && this.wave > 9);
	//bool allowany = false;
	RandomSelection_Init();
	IL_EACH(g_squads, true,
	{
		if(!horde_squad_allowed(this, it, fbosswave, spawntype, allowany))
			continue;
		// final boss will be given priority over other boss spawns
		// TODO: less priority on nightmare?
		int prio = 1;
		if((it.spawnflags & HORDE_FINALBOSS) && !((this.wave % fbosswave) != 0))
			prio = 2;
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
	if(autocvar_skill != 3 && (this.wave % 9) == 0)
		this.bosses = this.count; // use the horde manager's count for final boss count
	else if((temp_wave % 3) == 0)
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
	this.active = true;
	SpawnWave2(this);
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
	shop_opentime = 0;
	shop_setup_weapons();
	shop_setup_passive();
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
	{
		// retry
		setthink(this, Countdown);
		this.nextthink = time + 4;
		return;
	}
	
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
void Caleb_bloodrage_clear(entity this);
void Wavecheck(entity this)
{
	if(this.wait) // still in the process of spawning monsters, don't wavecheck
		return;
		
	setthink(this, Wavecheck);
	this.nextthink = time + 10;

	LOG_DEBUGF("\n===============\nchecking kills: %d of %d", monsters_killed, monsters_total);
	
	// Early exit for kill count
	if((this.wave % 3) == 0 || this.wave < 3) // Be exact?
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

	Horde_GiveScore(10);
	
	if((this.wave % 3) == 0) // it was a boss wave
	{
		if(!key_spawned) // key was already spawned, don't spawn another yet!
			GetKey(this);

		// TODO: generic round over function
		FOREACH_CLIENT(IS_PLAYER(it) && it.m_champion == CHAMPION_Caleb,
		{
			Caleb_bloodrage_clear(this);
		});
		horde_failed_time = 0; // reset the failed timer too
		this.nextthink = time + 20; // in case the players are slow to find the key
		this.active = false;
		shop_opentime = this.nextthink + 4; // give players some time to shop around too! buffer is for the countdown to the new round
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_SHOP_OPEN);
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

spawnfunc(info_horde_shop);
void Horde_SetupSquads()
{
	// if map entities are found they are preferred
	// otherwise spawn in any that are missing to fill in any gaps
	bool found = false;

	// testing option to allow overriding the generated monsters
	if(autocvar_horde_test != "")
	{
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, autocvar_horde_test);
		Horde_SpawnSquadEntity(HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, autocvar_horde_test);
	}

	// army wave setup

	found = false;
	IL_EACH(g_squads, (it.spawnflags & HORDE_ARMY) && (it.spawnflags & HORDE_FODDER), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 dog");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "2 grunt");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "3 grunt");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "2 grunt 1 dog");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "2 dog");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_RANGED, "1 enforcer");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "1 axegrunt");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_NORMAL, "1 gremlin");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_FODDER, HORDE_SQUAD_TYPE_FLYING, "1 jim");
	}

	found = false;
	IL_EACH(g_squads, (it.spawnflags & HORDE_ARMY) && (it.spawnflags & HORDE_ELITE), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "2 enforcer");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 ogre");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 scourge");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 sword");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 lenforcer");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 cook");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 floyd");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 edie");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 bender");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 skaarj");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 dalek");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 arachnofloyd");
		Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 norb");
		if(!Monsters_SeasonLocked())
		{
			Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 elf 1 santa");
			Horde_SpawnSquadEntity(HORDE_ARMY | HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 raindeer 1 santa");
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
	}

	found = false;
	IL_EACH(g_squads, !(it.spawnflags & HORDE_ARMY) && (it.spawnflags & HORDE_ELITE), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 hknight");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 dfury");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_FLYING, "2 wizard");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_FLYING, "1 gargoyle");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_FLYING, "1 octa");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_EASY, HORDE_SQUAD_TYPE_FLYING, "1 gaunt");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_HARD, HORDE_SQUAD_TYPE_NORMAL, "2 knight 1 dknight");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_HARD, HORDE_SQUAD_TYPE_NORMAL, "2 knight 1 justice");
		Horde_SpawnSquadEntity(HORDE_ELITE | HORDE_HARD, HORDE_SQUAD_TYPE_FLYING, "2 grenling");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 hknight");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 dfury");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 knight 1 hknight");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 knight 1 dfury");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 ogre");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_FLYING, "3 wizard");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_FLYING, "2 gargoyle");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_FLYING, "2 gaunt");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_FLYING, "2 octa");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 wrath");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 dknight");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 mutant");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_RANGED, "1 cook");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 bambler");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "2 kangaroo");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 drole");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 skullwiz");
		Horde_SpawnSquadEntity(HORDE_ELITE, HORDE_SQUAD_TYPE_NORMAL, "1 justice");
	}

	found = false;
	IL_EACH(g_squads, (it.spawnflags & HORDE_BOSS) && !(it.spawnflags & HORDE_FINALBOSS), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 demon");
		Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_EASY, HORDE_SQUAD_TYPE_NORMAL, "1 arachnofloyd");
		Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_HARD, HORDE_SQUAD_TYPE_NORMAL, "2 shambler");
		Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_HARD, HORDE_SQUAD_TYPE_NORMAL, "2 minotaur");
		Horde_SpawnSquadEntity(HORDE_BOSS | HORDE_HARD, HORDE_SQUAD_TYPE_BOSS, "1 juggernaut");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "1 shambler");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "1 minotaur");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_NORMAL, "2 demon");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_NORMAL, "1 arachnofloyd");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "1 shalrath");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "2 wrath");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_FLYING, "2 grenling");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_NORMAL, "1 demon 1 mutant");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_NORMAL, "2 grunt 1 arachnofloyd");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_NORMAL, "2 grunt 1 norb");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "2 bambler");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "1 mutant 1 drole");
		Horde_SpawnSquadEntity(HORDE_BOSS, HORDE_SQUAD_TYPE_BOSS, "1 justice 1 hknight");
	}

	found = false;
	IL_EACH(g_squads, (it.spawnflags & HORDE_FINALBOSS), {found = true; break;});
	if(!found)
	{
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 thomas");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 super_chicken");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 guardian");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 legond");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 overlord");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 goroth");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 blud");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 eidolon");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 armagon");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 judicator");
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_BOSS, "1 zerstorer"); // technically flying, but small enough to use regular spawns
		Horde_SpawnSquadEntity(HORDE_FINALBOSS, HORDE_SQUAD_TYPE_FLYING, "1 volkerh");
	}

	entity shop = find(NULL, classname, "info_horde_shop");
	if(!shop)
	{
		entity point = find(NULL, classname, "info_horde_key");
		if(!point)
		{
			LOG_INFO("Unable to place a shopkeep, map is broken!");
			return;
		}
		RandomSelection_Init();
		for(int j = 0; j < 4; ++j)
		{
			vector pos = point.origin + '0 0 16';
			tracebox(pos, '-16 -16 -16', '16 16 16', pos + vec2(randomvec() * 100), MOVE_NOMONSTERS, point);
			RandomSelection_AddVec(trace_endpos, 1, 1);
		}
		shop = new(info_horde_shop);
		shop.spawnfunc_checked = true;
		shop.angles_y = rint(crandom() * 360);
		setorigin(shop, RandomSelection_chosen_vec);
		spawnfunc_info_horde_shop(shop);
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
	if(horde_ent)
	{
		delete(this);
		return;
	}
	// AY, Dec06 2021, auto set horde cvar
	if(!autocvar_horde && !deathmatch)
		cvar_set("horde", "1");
	// end AY
	
	precache_sound("misc/talk.wav");
	PrecacheMonsters();

	have_hordehub = fexists("maps/horde.bsp");
	
	horde_ent = this; // set global reference to the horde manager
	
	if(!this.target || this.target == "")
		this.target = "horde_event"; // default name

	this.targetname = "horde_manager";
	setthink(this, SetHorde);
	this.nextthink = time + HORDE_START_DELAY;
	this.use = Wavecheck_use;

	horde_skill = autocvar_skill;
	top_score = stof(db_get(ServerProgsDB, strcat(mapname, "/topscore/", ftos(horde_skill))));
	
	this.wait = 1; // waiting before next wave?
	this.delay = 9; // max number of  squads to spawn in a wave
	this.wave = 0;

	if(!this.count)
		this.count = 1; // number of final bosses on wave 9
}

// quonquer compatibility
spawnfunc(info_qonquer)
{
	this.currentammo = 1;
	spawnfunc_horde_manager(this);

	entity ent = new(info_horde_key);
	setorigin(ent, this.origin);
	ent.spawnfunc_checked = true;
	spawnfunc_info_horde_key(ent);
	DropToFloor_QC_DelayedInit(ent);
}

.string targetstart;
.string targetend;
void qonquer_fixdoor(entity this)
{
	if(!this.targetname || this.targetname == "")
		return;
	if(!horde_ent.currentammo)
		return;
	// first attempt to fix any doors that trigger at the start
	FOREACH_ENTITY_STRING(targetstart, this.targetname,
	{
		if(it.classname == "info_qonquer_wave")
		{
			this.targetname = "horde_event";
			break;
		}
	});

	// then mark any doors that trigger at the end as key doors
	FOREACH_ENTITY_STRING(targetend, this.targetname,
	{
		if(it.classname == "info_qonquer_wave")
		{
			this.targetname = string_null;
			this.items = IT_KEY1;
			this.wait = -1;
			this.message = string_null;
			break;
		}
	});
}

spawnfunc(info_qonquer_wave)
{
	if(!this.targetstart || this.targetstart == "")
	{
		delete(this);
		return;
	}
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

void horde_setup_powerup(entity this, int powerup)
{
	switch(powerup)
	{
		case POWERUP_INVULNERABILITY:
		{
			this.noise = "items/protect.wav";
			_setmodel(this, "progs/invulner.mdl");
			this.netname = "Pentagram of Protection";
			this.powerups = POWERUP_INVULNERABILITY;
			this.invincible_finished = 5;
			this.classname = "item_artifact_invulnerability";
			break;
		}
		case POWERUP_QUAD:
		{
			this.noise = "items/damage.wav";
			_setmodel(this, "progs/quaddama.mdl");
			this.netname = "Quad Damage";
			this.powerups = POWERUP_QUAD;
			this.super_damage_finished = 5;
			this.classname = "item_artifact_super_damage";
			break;
		}
		case POWERUP_HORN_OF_CONJURING:
		{
			this.noise = "hipitems/horn.wav";
			_setmodel(this, "progs/horn.mdl");
			this.netname = "Horn of Conjuring";
			this.powerups = POWERUP_HORN_OF_CONJURING;
			this.classname = "item_hornofconjuring";
			break;
		}
		case POWERUP_V_SPHERE:
		{
			this.noise = "sphere/sphere.wav";
			_setmodel(this, "progs/sphere.mdl");
			this.netname = "Vengeance Sphere";
			this.powerups = POWERUP_V_SPHERE;
			this.classname = "item_sphere";
			break;
		}
		case POWERUP_FIELDGEN:
		{
			this.noise = "weapons/field/genactiv.wav";
			_setmodel(this, "progs/fieldgen.mdl");
			this.netname = "Force Field Generator";
			this.powerups = POWERUP_FIELDGEN;
			this.field_generator_finished = 15;
			this.classname = "item_artifact_field_generator";
			this.health = 100;
			break;
		}
		case POWERUP_SHIELD:
		{
			this.noise = "shield/pickup.wav";
			_setmodel(this, "progs/shield.mdl");
			this.netname = "Power Shield";
			this.powerups = POWERUP_SHIELD;
			this.shield_finished = 15;
			this.classname = "item_powerup_shield";
			break;
		}
		case POWERUP_EMPATHY_SHIELDS:
		{
			this.noise = "hipitems/empathy.wav";
			_setmodel(this, "progs/empathy.mdl");
			this.netname = "Empathy Shields";
			this.powerups = POWERUP_EMPATHY_SHIELDS;
			this.empathy_finished = 15;
			this.classname = "item_artifact_empathy_shields";
			break;
		}
		case POWERUP_JUMPBOOTS:
		{
			this.noise = "items/jboots_got_timed.wav";
			_setmodel(this, "progs/jumpblue.mdl");
			this.netname = "Jump Boots";
			this.powerups = POWERUP_JUMPBOOTS;
			this.jboots_finished = 30;
			this.classname = "item_jboots";
			break;
		}
		case POWERUP_SHARPSHOOTER:
		{
			this.noise = "items/sharp.wav";
			_setmodel(this, "progs/artifact_sharp.mdl");
			this.netname = "Sharp Shooter";
			this.powerups = POWERUP_SHARPSHOOTER;
			this.sharp_finished = 10;
			this.classname = "item_artifact_sharp_shooter";
			break;
		}
		case POWERUP_REVIVAL:
		{
			this.noise = "items/revival.wav";
			_setmodel(this, "progs/revival.mdl");
			this.netname = "Revival";
			this.powerups = POWERUP_REVIVAL;
			this.classname = "item_revival";
			break;
		}
	}
}

void horde_spawn_tank(entity this);
void horde_spawn_powerup(entity this, entity attacker)
{
	if(!powerup_chance)
		powerup_chance = DEFAULT_POWERUP_CHANCE;

	if(STAT(PASSIVES, attacker) & PASSIVE_LOOTER)
		powerup_chance *= 0.8;
	
	if(random() < powerup_chance) // "if(1)" to guarantee powerup drop
	{
		// if the odds are in our favour, let there be tanks!
		if(random() <= 0.15)
		{
			horde_spawn_tank(this);
			return;
		}
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

		RandomSelection_Init();
		RandomSelection_AddFloat(POWERUP_INVULNERABILITY, 1, 1);
		RandomSelection_AddFloat(POWERUP_QUAD, 1, 1);
		RandomSelection_AddFloat(POWERUP_V_SPHERE, 0.5, 1);
		RandomSelection_AddFloat(POWERUP_HORN_OF_CONJURING, 0.5, 1);
		RandomSelection_AddFloat(POWERUP_FIELDGEN, 0.5, 1);
		RandomSelection_AddFloat(POWERUP_SHIELD, 0.5, 1);
		RandomSelection_AddFloat(POWERUP_EMPATHY_SHIELDS, 0.5, 1);
		RandomSelection_AddFloat(POWERUP_JUMPBOOTS, 0.5, 1);
		RandomSelection_AddFloat(POWERUP_SHARPSHOOTER, 0.5, 1);
		int ndead = 0;
		FOREACH_CLIENT(IS_PLAYER(it) && it.deadflag != DEAD_NO,
		{
			ndead += 1;
		});
		if(ndead > 0)
			RandomSelection_AddFloat(POWERUP_REVIVAL, 2 * ndead, 1);
		horde_setup_powerup(powerup, RandomSelection_chosen_float);
		//powerup.effects = EF_DIMLIGHT;
		
		setsize(powerup, '-12 -12 -12', '12 12 12');
	}
	else
		powerup_chance += POWERUP_CHANCE_GAIN;
}

void tankitem_touch(entity this, entity toucher);
void horde_spawn_tank(entity this)
{
	entity item = spawn();
	setorigin(item, this.origin + '0 0 0');

	//setsize(item, '-16 -16 -24', '16 16 32');
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_BOUNCE);
	item.velocity = '0 0 300';
	
	//item.velocity_x = crandom() * 64;
	//item.velocity_y = crandom() * 64;
	settouch(item, tankitem_touch);
	setthink(item, horde_powerup_think);
	item.nextthink = time + 10;
	//item.effects = EF_DIMLIGHT;

	_setmodel(item, "progs/g_tank.mdl");
	item.netname = "Tank";
	item.classname = "item_tank";
		
	setsize(item, '-12 -12 -12', '12 12 16');
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
