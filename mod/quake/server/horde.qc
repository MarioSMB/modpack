#include "horde.qh"

#include "triggers/teleporters.qh"

.float storednextthink;
.void(entity this) storedthink;
void Countdown(entity this);
void Wavecheck(entity this);
void SpawnAmmo(entity this);
.int wave; // what wave of the horde mode we're on
.int fodder; // how many fodder squads to spawn
.int elites; // how many elite squads to spawn
.int bosses; // how many bosses to spawn
.int spawncount; // number of monster spawns
.bool army; // Spawn Army? True/fallse
bool CheckBlockedSpawn(entity spawnpoint);

bool key_spawned; // true/false, determine if key has already been spawned, prevent dupes.

const float SPAWN_RESET_TIME = 5; // amount of time that a spawn point is considered occupied and not valid for use

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
		if(it.health > 0 && it.classname != "monster_zombie")
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
	FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET),
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
	// knight
	precache_model("progs/knight.mdl");
	precache_model("progs/h_knight.mdl");

	precache_sound("knight/kdeath.wav");
	precache_sound("knight/khurt.wav");
	precache_sound("knight/ksight.wav");
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	precache_sound("knight/idle.wav");
	
	// hellknight
	precache_model2("progs/hknight.mdl");
	precache_model2("progs/k_spike.mdl");
	precache_model2("progs/h_hellkn.mdl");

	
	precache_sound2("hknight/attack1.wav");
	precache_sound2("hknight/death1.wav");
	precache_sound2("hknight/pain1.wav");
	precache_sound2("hknight/sight1.wav");
	precache_sound("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound2("hknight/slash1.wav");
	precache_sound2("hknight/idle.wav");
	precache_sound2("hknight/grunt.wav");

	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	
	// dog
	precache_model("progs/h_dog.mdl");
	precache_model("progs/dog.mdl");

	precache_sound("dog/dattack1.wav");
	precache_sound("dog/ddeath.wav");
	precache_sound("dog/dpain1.wav");
	precache_sound("dog/dsight.wav");
	precache_sound("dog/idle.wav");
	
	// demon
	precache_model("progs/demon.mdl");
	precache_model("progs/h_demon.mdl");

	precache_sound("demon/ddeath.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("demon/djump.wav");
	precache_sound("demon/dpain1.wav");
	precache_sound("demon/idle1.wav");
	precache_sound("demon/sight2.wav");
	
	// ogre
	precache_model("progs/ogre.mdl");
	precache_model("progs/h_ogre.mdl");
	precache_model("progs/grenade.mdl");

	precache_sound("ogre/ogdrag.wav");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogidle.wav");
	precache_sound("ogre/ogidle2.wav");
	precache_sound("ogre/ogpain1.wav");
	precache_sound("ogre/ogsawatk.wav");
	precache_sound("ogre/ogwake.wav");
	
	// grunt
	precache_model("progs/soldier.mdl");
	precache_model("progs/h_guard.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_sound("soldier/death1.wav");
	precache_sound("soldier/idle.wav");
	precache_sound("soldier/pain1.wav");
	precache_sound("soldier/pain2.wav");
	precache_sound("soldier/sattck1.wav");
	precache_sound("soldier/sight1.wav");

	precache_sound("player/udeath.wav");		// gib death
	
	// enforcer
	precache_model2("progs/enforcer.mdl");
	precache_model2("progs/h_mega.mdl");
	precache_model2("progs/laser.mdl");

	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("enforcer/idle1.wav");
	precache_sound2("enforcer/pain1.wav");
	precache_sound2("enforcer/pain2.wav");
	precache_sound2("enforcer/sight1.wav");
	precache_sound2("enforcer/sight2.wav");
	precache_sound2("enforcer/sight3.wav");
	precache_sound2("enforcer/sight4.wav");
	
	// shambler
	precache_model("progs/shambler.mdl");
	precache_model("progs/s_light.mdl");
	precache_model("progs/h_shams.mdl");
	precache_model("progs/bolt.mdl");
	
	precache_sound("shambler/sattck1.wav");
	precache_sound("shambler/sboom.wav");
	precache_sound("shambler/sdeath.wav");
	precache_sound("shambler/shurt2.wav");
	precache_sound("shambler/sidle.wav");
	precache_sound("shambler/ssight.wav");
	precache_sound("shambler/melee1.wav");
	precache_sound("shambler/melee2.wav");
	precache_sound("shambler/smack.wav");
	
	// shalrath
	precache_model2("progs/shalrath.mdl");
	precache_model2("progs/h_shal.mdl");
	precache_model2("progs/v_spike.mdl");
	
	precache_sound2("shalrath/attack.wav");
	precache_sound2("shalrath/attack2.wav");
	precache_sound2("shalrath/death.wav");
	precache_sound2("shalrath/idle.wav");
	precache_sound2("shalrath/pain.wav");
	precache_sound2("shalrath/sight.wav");
	
	// wizard
	precache_model("progs/wizard.mdl");
	precache_model("progs/h_wizard.mdl");
	precache_model("progs/w_spike.mdl");

	precache_sound("wizard/hit.wav");		// used by c code
	precache_sound("wizard/wattack.wav");
	precache_sound("wizard/wdeath.wav");
	precache_sound("wizard/widle1.wav");
	precache_sound("wizard/widle2.wav");
	precache_sound("wizard/wpain.wav");
	precache_sound("wizard/wsight.wav");	
	
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
	T_Damage(this, NULL, NULL, 4000);
}
// =================================================================
/*
================
SpawnMonster
================
*/
// TODO: cleaner method of spawning mobs
void knight_stand1(entity this);
void knight_walk1(entity this);
void knight_run1(entity this);
void knight_atk1(entity this);
void knight_pain(entity this, entity attacker, float damage);
void knight_die(entity this, entity inflictor, entity attacker);
void hknight_stand1(entity this);
void hknight_walk1(entity this);
void hknight_run1(entity this);
void hknight_melee(entity this);
void hknight_magicc1(entity this);
void hknight_pain(entity this, entity attacker, float damage);
void hknight_die(entity this, entity inflictor, entity attacker);
void dog_stand1(entity this);
void dog_walk1(entity this);
void dog_run1(entity this);
void dog_pain(entity this, entity attacker, float damage);
void dog_die(entity this, entity inflictor, entity attacker);
void dog_atta1(entity this);
void dog_leap1(entity this);
void demon1_stand1(entity this);
void demon1_walk1(entity this);
void demon1_run1(entity this);
void demon_die(entity this, entity inflictor, entity attacker);
void Demon_MeleeAttack(entity this);
void demon1_jump1(entity this);
void demon1_pain(entity this, entity attacker, float damage);
void ogre_stand1(entity this);
void ogre_walk1(entity this);
void ogre_run1(entity this);
void ogre_die(entity this, entity inflictor, entity attacker);
void ogre_melee(entity this);
void ogre_nail1(entity this);
void ogre_pain(entity this, entity attacker, float damage);
void army_stand1(entity this);
void army_walk1(entity this);
void army_run1(entity this);
void army_atk1(entity this);
void army_pain(entity this, entity attacker, float damage);
void army_die(entity this, entity inflictor, entity attacker);
void enf_stand1(entity this);
void enf_walk1(entity this);
void enf_run1(entity this);
void enf_pain(entity this, entity attacker, float damage);
void enf_die(entity this, entity inflictor, entity attacker);
void enf_atk1(entity this);
void sham_stand1(entity this);
void sham_walk1(entity this);
void sham_run1(entity this);
void sham_die(entity this, entity inflictor, entity attacker);
void sham_melee(entity this);
void sham_magic1(entity this);
void sham_pain(entity this, entity attacker, float damage);
void shal_stand(entity this);
void shal_walk1(entity this);
void shal_run1(entity this);
void shalrath_die(entity this, entity inflictor, entity attacker);
void shalrath_pain(entity this, entity attacker, float damage);
void shal_attack1(entity this);
void wiz_stand1(entity this);
void wiz_walk1(entity this);
void wiz_run1(entity this);
void Wiz_Missile(entity this);
void Wiz_Pain(entity this, entity attacker, float damage);
void wiz_die(entity this, entity inflictor, entity attacker);
void zombie_stand1(entity this);
void zombie_walk1(entity this);
void zombie_run1(entity this);
void zombie_pain(entity this, entity attacker, float damage);
void zombie_die(entity this, entity inflictor, entity attacker);
void zombie_missile(entity this);
void monster_use(entity this, entity actor, entity trigger);
entity SpawnMonster(entity this, string class, vector org, vector temp_angles)
{
	entity monster = spawn();
	
	monster.angles = temp_angles; 
	monster.solid = SOLID_SLIDEBOX;
	set_movetype(monster, MOVETYPE_STEP);
	//monster.target = "horde_manager";
	monster.flags = FL_MONSTER;
	//monster.alpha = 1; // only set monster alpha after they're a corpse

	// perform enemy-type specific loading
	// TODO: missing newer fields
	if(class == "knight")
	{
		_setmodel(monster, "progs/knight.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		org += '0 0 24'; // offset based on size
		monster.classname = "monster_knight";
		monster.health = 75;
		monster.th_stand = knight_stand1;
		monster.th_walk = knight_walk1;
		monster.th_run = knight_run1;
		monster.th_melee = knight_atk1;
		monster.th_pain = knight_pain;
		monster.th_die = knight_die;
	}
	else if(class == "hellknight")
	{
		_setmodel(monster, "progs/hknight.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		org += '0 0 24';
		monster.classname = "monster_hell_knight";
		monster.health = 250;
		monster.th_stand = hknight_stand1;
		monster.th_walk = hknight_walk1;
		monster.th_run = hknight_run1;
		monster.th_melee = hknight_melee;
		monster.th_missile = hknight_magicc1;
		monster.th_pain = hknight_pain;
		monster.th_die = hknight_die;
	}
	else if(class == "dog")
	{
		_setmodel(monster, "progs/dog.mdl");
		setsize(monster, '-32 -32 -24', '32 32 40');
		org += '0 0 24';
		monster.classname = "monster_dog";
		monster.health = 25;
		monster.th_stand = dog_stand1;
		monster.th_walk = dog_walk1;
		monster.th_run = dog_run1;
		monster.th_pain = dog_pain;
		monster.th_die = dog_die;
		monster.th_melee = dog_atta1;
		monster.th_missile = dog_leap1;
	}
	else if(class == "demon")
	{
		_setmodel(monster, "progs/demon.mdl");

		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_demon1";
		monster.health = 300;
		org += '0 0 48';
		monster.th_stand = demon1_stand1;
		monster.th_walk = demon1_walk1;
		monster.th_run = demon1_run1;
		monster.th_die = demon_die;
		monster.th_melee = Demon_MeleeAttack;
		monster.th_missile = demon1_jump1;
		monster.th_pain = demon1_pain;
	}
	else if(class == "ogre")
	{
		_setmodel(monster, "progs/ogre.mdl");
		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_ogre";
		monster.health = 200;
		org += '0 0 32';
		monster.th_stand = ogre_stand1;
		monster.th_walk = ogre_walk1;
		monster.th_run = ogre_run1;
		monster.th_die = ogre_die;
		monster.th_melee = ogre_melee;
		monster.th_missile = ogre_nail1;
		monster.th_pain = ogre_pain;
	}
	else if(class == "grunt")
	{
		_setmodel(monster, "progs/soldier.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		monster.classname = "monster_army";
		monster.health = 30;
		org += '0 0 24';
		monster.th_stand = army_stand1;
		monster.th_walk = army_walk1;
		monster.th_run = army_run1;
		monster.th_missile = army_atk1;
		monster.th_pain = army_pain;
		monster.th_die = army_die;
	}
	else if(class == "enforcer")
	{
		_setmodel(monster, "progs/enforcer.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		monster.classname = "monster_enforcer";
		monster.health = 80;
		org += '0 0 24';
		monster.th_stand = enf_stand1;
		monster.th_walk = enf_walk1;
		monster.th_run = enf_run1;
		monster.th_pain = enf_pain;
		monster.th_die = enf_die;
		monster.th_missile = enf_atk1;
	}
	else if(class == "shambler")
	{
		_setmodel(monster, "progs/shambler.mdl");
		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_shambler";
		monster.health = 600;
		org += '0 0 32';
		monster.th_stand = sham_stand1;
		monster.th_walk = sham_walk1;
		monster.th_run = sham_run1;
		monster.th_die = sham_die;
		monster.th_melee = sham_melee;
		monster.th_missile = sham_magic1;
		monster.th_pain = sham_pain;
	}
	else if(class == "shalrath")
	{
		_setmodel(monster, "progs/shalrath.mdl");
		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_shalrath";
		org += '0 0 32';
		monster.health = 400;
		monster.th_stand = shal_stand;
		monster.th_walk = shal_walk1;
		monster.th_run = shal_run1;
		monster.th_die = shalrath_die;
		monster.th_pain = shalrath_pain;
		monster.th_missile = shal_attack1;
	}
	else if(class == "wizard")
	{
		_setmodel(monster, "progs/wizard.mdl");
		monster.flags |= FL_FLY; // special behavior
		monster.classname = "monster_wizard";
		setsize(monster, VEC_HULL_MIN, VEC_HULL_MAX);
		org += '0 0 32';
		monster.health = 80;
		monster.th_stand = wiz_stand1;
		monster.th_walk = wiz_walk1;
		monster.th_run = wiz_run1;
		monster.th_missile = Wiz_Missile;
		monster.th_pain = Wiz_Pain;
		monster.th_die = wiz_die;
	}
	else if(class == "zombie")
	{
		_setmodel(monster, "progs/zombie.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		monster.classname = "monster_zombie";
		org += '0 0 32';
		monster.health = 60;
		monster.th_stand = zombie_stand1;
		monster.th_walk = zombie_walk1;
		monster.th_run = zombie_run1;
		monster.th_pain = zombie_pain;
		monster.th_die = zombie_die;
		monster.th_missile = zombie_missile;
		monster.target = string_null; // don't target anything!
	}
	else
	{
		LOG_DEBUG("ERROR: No monster provided");
	}
	// finish the shared settings
	setorigin(monster, org + '0 0 1');
	
	if(class != "wizard")
		droptofloor(monster);
	
	if(!t_walkmove(monster, 0, 0))
		LOG_INFO("walkmonster in wall at: ", vtos(monster.origin));
	
	monster.category = CATEGORY_MONSTER;
	monster.takedamage = DAMAGE_AIM;
	monster.ideal_yaw = monster.angles * '0 1 0';
	if(!monster.yaw_speed)
		monster.yaw_speed = 20;
	monster.view_ofs = '0 0 25';
	monster.use = monster_use;
	
	monster.flags |= FL_MONSTER;
	
	monster.enemy = HordeFindTarget(); // find a random living player
	//monster.enemy = find (world, classname, "player");
	setthink(monster, FoundTarget);
		
	//monster.nextthink = monster.nextthink + 0.1;
	monster.nextthink = time + 0.1;
	
	spawn_tdeath_fast(monster.origin, monster);
	//spawn_tfog(monster.origin);
	
	monster.owner = this;
	if(monster.classname != "monster_zombie") // don't count zombies toward total goal
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
		
	sprint(toucher, strcat("You got the ", this.netname, "\n"));
	
	// ammo touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	// change to a better weapon if appropriate
	if(toucher.weapon == best_weapon)
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
	
	sprint(toucher, sprintf("You receive %d health\n", this.healamount));
	
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
	sprint(toucher, "You got armor\n");
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
	
	if(this.netname != "")
		sprint(toucher, sprintf("You got the %s\n", this.netname));
	else
		sprint(toucher, sprintf("You picked up a key\n"));
	
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	
	horde_key_give(this.items);
	
	// find the horde manager and trigger the next wave
	if(key_spawned)
	{
		LOG_DEBUG("key triggers next wave");
		horde_ent.wait = true;
		setthink(horde_ent, Countdown);
		horde_ent.nextthink = time;
	}
	else
		LOG_DEBUG("key shouldn't trigger next wave!");
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


//============================================================================
/* 
SpawnSquad2

Yoder FEB02 2022
*/
void SpawnSquad2(entity this, string name, vector org, vector temp_angles)
{
	if(name == "3 grunts")
	{
		if(autocvar_skill > 0)
		{
			SpawnMonster(this, "grunt", org + '0 -40 0', temp_angles);
			SpawnMonster(this, "grunt", org + '40 40 0', temp_angles);
			SpawnMonster(this, "grunt", org + '-40 40 0', temp_angles);
		}
		else
		{
			SpawnMonster(this, "grunt", org + '-40 0 0', temp_angles);
			SpawnMonster(this, "grunt", org + '40 0 0', temp_angles);
		}
	}
	else if(name == "2 grunts, 1 dog")
	{
		SpawnMonster(this, "dog", org + '44 0 0', temp_angles);
		SpawnMonster(this, "grunt", org + '-40 -40 0', temp_angles);
		SpawnMonster(this, "grunt", org + '-40 40 0', temp_angles);
	}
	else if(name == "2 dogs")
	{
		if(autocvar_skill > 0)
		{
			SpawnMonster(this, "dog", org + '-0 -44 0', temp_angles);
			SpawnMonster(this, "dog", org + '0 44 0', temp_angles);
		}
		else
			SpawnMonster(this, "dog", org + '-0 -44 0', temp_angles);
	}
	else if(name == "1 enforcer")
	{
		SpawnMonster(this, "enforcer", org + '0 0 0', temp_angles);
	}
	else if(name == "2 enforcers")
	{
		if(autocvar_skill > 0)
		{
			SpawnMonster(this, "enforcer", org + '40 0 0', temp_angles);
			SpawnMonster(this, "enforcer", org + '-40 0 0', temp_angles);	
		}
		else
			SpawnMonster(this, "enforcer", org + '0 0 0', temp_angles);
	}
	else if(name == "1 ogre")
	{
		SpawnMonster(this, "ogre", org + '0 0 0', temp_angles);
	}
	else if(name == "2 knights")
	{
		if(autocvar_skill > 0)
		{
			SpawnMonster(this, "knight", org + '40 0 0', temp_angles);
			SpawnMonster(this, "knight", org + '-40 0 0', temp_angles);
		}
		else
		{
			SpawnMonster(this, "knight", org + '40 0 0', temp_angles);
		}
			
	}
	else if(name == "2 zombies")
	{
		SpawnMonster(this, "zombie", org + '40 0 0', temp_angles);
		SpawnMonster(this, "zombie", org + '-40 0 0', temp_angles);
	}
	else if(name == "1 wizard")
		SpawnMonster(this, "wizard", org + '0 0 0', temp_angles);
	else if(name == "2 hellknights")
	{
		if(autocvar_skill > 0)
		{
			SpawnMonster(this, "hellknight", org + '0 40 0', temp_angles);
			SpawnMonster(this, "hellknight", org + '0 -40 0', temp_angles);
		}
		else
			SpawnMonster(this, "hellknight", org + '0 40 0', temp_angles);
	}
	else if(name == "2 knights, 1 hellknight")
	{
		SpawnMonster(this, "hellknight", org + '40 0 0', temp_angles);
		SpawnMonster(this, "knight", org + '-40 40 0', temp_angles);
		SpawnMonster(this, "knight", org + '-40 -40 0', temp_angles);
	}
	else if(name == "3 wizards")
	{
		if(autocvar_skill > 0)
		{
			SpawnMonster(this, "wizard", org + '40 40 40', temp_angles);
			SpawnMonster(this, "wizard", org + '-40 40 40', temp_angles);
			SpawnMonster(this, "wizard", org + '-40 -40 40', temp_angles);
		}
		else
		{
			SpawnMonster(this, "wizard", org + '40 40 40', temp_angles);
			SpawnMonster(this, "wizard", org + '-40 40 40', temp_angles);
		}
	}
	else if(name == "shambler")
		SpawnMonster(this, "shambler", org, temp_angles);
	else if(name == "double demon")
	{
		if(autocvar_skill >= 3 && random() > 0.8)
		{
			// double shambler
			SpawnMonster(this, "shambler", org + '40 40 0', temp_angles);
			SpawnMonster(this, "shambler", org + '-40 -40 0', temp_angles);
		}
		else if(autocvar_skill >= 1)
		{
			SpawnMonster(this, "demon", org + '40 40 0', temp_angles);
			SpawnMonster(this, "demon", org + '-40 -40 0', temp_angles);
		}
		else
			SpawnMonster(this, "demon", org, temp_angles);
	}
	else if(name == "shalrath")
		SpawnMonster(this, "shalrath", org, temp_angles);	
	else
		LOG_DEBUG("ERROR: unrecognized squad name!");
	
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
	float r; // random roll
	int squad_cat = 0;
	
	//STEP 1: determine what kind of monster is getting spawned
	if(this.army)
	{
		if(this.fodder > 0)
		{
			r = random() * 4;
			if(r < 1)
				squad_name = "3 grunts";
			else if(r < 2)
				squad_name = "2 grunts, 1 dog";
			else if(r < 3.5)
				squad_name = "2 dogs";
			else
			{
				squad_name = "1 enforcer";
				squad_type = HORDE_SQUAD_TYPE_RANGED;
			}

			squad_cat = HORDE_SQUAD_CAT_FODDER;
		}
		else if(this.elites > 0)
		{
			squad_type = HORDE_SQUAD_TYPE_RANGED; 
			r = random() * 2;
			if(r < 1.5)
				squad_name = "2 enforcers";
			else
				squad_name = "1 ogre";
			
			squad_cat = HORDE_SQUAD_CAT_ELITE;
		}
		else if(this.bosses > 0)
		{
			LOG_DEBUG("ERROR: should not spawn boss squad in army wave");
			this.bosses = 0;
			squad_cat = HORDE_SQUAD_CAT_ERROR;
		}
	}
	else // NON-ARMY
	{
		if(this.fodder > 0)
		{
			r = random() * 4;
			if(r < 2)
				squad_name = "2 knights";
			else if(r < 3)
				squad_name = "2 zombies";
			else
			{
				squad_name = "1 wizard";
				squad_type = HORDE_SQUAD_TYPE_FLYING;
			}
			
			squad_cat = HORDE_SQUAD_CAT_FODDER;
		}
		else if(this.elites > 0)
		{
			r = random() * 4;
			if(r < 1)
				squad_name = "2 hellknights";
			else if(r < 2)
				squad_name = "2 knights, 1 hellknight";
			else if(r < 3)
			{
				squad_name = "1 ogre";
				squad_type = HORDE_SQUAD_TYPE_RANGED;
			}
			else
			{
				squad_name = "3 wizards";
				squad_type = HORDE_SQUAD_TYPE_FLYING;
			}
			
			squad_cat = HORDE_SQUAD_CAT_ELITE;
		}
		else if(this.bosses > 0)
		{
			squad_type = HORDE_SQUAD_TYPE_BOSS;
			r = random() * 3;
			if(r < 1)
				squad_name = "shambler";
			else if(r < 2.5)
			{
				squad_name = "double demon";
				squad_type = HORDE_SQUAD_TYPE_NORMAL;
			}
			else
				squad_name = "shalrath";
			
			squad_cat = HORDE_SQUAD_CAT_BOSS;
		}
	}

	//STEP 2: find a spawn point for the squad
	entity t = HordeFindSpawnpoint(squad_type);
	LOG_DEBUG("spawnpoint found was: ", t.classname);
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
	entity p = find(NULL, classname, "info_horde_item");
	while (p)
	{
		if(!p.wait)
		{
			setthink(p, SpawnItem);
			p.nextthink = time + random() * 2;
		}
		p = find (p, classname, "info_horde_item");
	}

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
	if(temp_wave % 3 == 0)
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
	p = find(NULL, targetname, this.target);
	while(p)
	{
		if(p.use)
			p.use(p, NULL, NULL);
		p = find(p, targetname, this.target);
	}

	this.wait = true;
	return 1;
}

void Countdown4(entity this)
{
	if((this.wave % 3) == 0)
		centerprint_all("Boss wave!");
	else
		centerprint_all("Fight!");
	SpawnWave2(this);
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
}
void Countdown3(entity this)
{
	centerprint_all("1");
	setthink(this, Countdown4);
	this.nextthink = time + 1;
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
}
void Countdown2(entity this)
{
	centerprint_all("2");
	setthink(this, Countdown3);
	this.nextthink = time + 1;
	_sound(this, CH_INFO, "misc/talk.wav", 1, ATTN_NONE);
}
void Countdown(entity this)
{
	if(!SpawnWavePrep(this))
		return;
	
	centerprint_all("3");
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

// setup horde rules
void SetHorde(entity this)
{
	LOG_DEBUG("TEST: It is September 23, 2021!"); // yoder sanity test
	setthink(this, Countdown);
	this.nextthink = time + 1;
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
