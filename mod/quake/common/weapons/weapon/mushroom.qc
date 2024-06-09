#include "pogo.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
.entity mushroom_targ;

PRECACHE(Mushroom)
{
	precache_model("progs/v_mushroom.mdl");
	precache_model("progs/g_mushroom.mdl");

	precache_sound("items/r_item1.wav");
}

void mushroom_think(entity this)
{
	setthink(this, mushroom_think);
	this.nextthink = time + 0.1;

	if(time > this.wait || this.realowner.mushroom_targ != this)
	{
		delete(this);
		return;
	}

	this.frame += 1;
	if(this.frame > 9)
		this.frame = 0;

	if(time < this.delay)
		return;
	this.delay = time + 1;

	Send_Effect(EFFECT_QCC_MUSHROOM, this.origin, '0 0 0', 1);

	FOREACH_ENTITY_RADIUS(this.origin, 512, IS_MONSTER(it) && it.health > 0 && it.enemy && !it.charmed && !it.is_frozen && !it.elec && it.enemy.classname != this.classname && !wasfreed(it.enemy),
	{
		if(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
			continue;
		if(!checkpvs(this.origin, it))
			continue;
		it.aggro_time = time;
		if(IS_PLAYER(it.enemy))
			it.oldenemy = it.enemy;
		it.enemy = this;
		FoundTarget(it);
	});
}

void mushroom_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	Send_Effect(EFFECT_QCC_MUSHROOM, this.origin, '0 0 0', 1);
	spawn_touchblood(this, 30, inflictor);
	delete(this);
}

void mushroom_setup(entity this)
{
	//set_movetype(this, MOVETYPE_NONE);
	setthink(this, mushroom_think);
	this.nextthink = time + 0.1;
	this.solid = SOLID_TRIGGER;
	this.health = 30;
	this.takedamage = DAMAGE_AIM;
	this.angles = '0 0 0';
	this.monster_attack = true;
	this.delay = time + 0.49; // somewhat sync with animation
	this.th_die = mushroom_die;
}

bool mushroom_heal(entity this, entity toucher)
{	
	if(toucher.tank)
		return false;
	if(toucher.m_transform)
		return false;
	
	if(!T_Heal(toucher, this.healamount, 0))
		return false;
	
	// health touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	particle(this.origin, '0 0 0', 26, 32);
	
	this.model = string_null;
	this.solid = SOLID_NOT;
	delete(this);
	return true;
}

void mushroom_touch(entity this, entity toucher)
{
	if(IS_PLAYER(toucher) && toucher.health > 0 && time > this.cnt)
	{
		if(mushroom_heal(this, toucher))
			return;
	}

	if(toucher && toucher.solid != SOLID_BSP)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	// TODO: anything else?
}

void mushroom_projectile_think(entity this)
{
	this.nextthink = time;
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	if(!IS_ONGROUND(this))
		return;

	mushroom_setup(this);
	this.wait = time + 10;
}

void W_ThrowMushroom(entity this, .entity weaponentity)
{
	sound(this, CH_WEAPON_B, SND_MUSHROOM_THROW, 1, ATTN_NORM);

	entity mushroom = new(mushroom);
	mushroom.realowner = this;
	mushroom.dphitcontentsmask = DPCONTENTS_SOLID;
	set_movetype(mushroom, MOVETYPE_TOSS);
	mushroom.solid = SOLID_TRIGGER;
	mushroom.healamount = 15;
	mushroom.healtype = 0;
	mushroom.noise = "items/r_item1.wav";
	mushroom.cnt = time + 0.33; // prevent picking up health instantly
	setmodel(mushroom, MDL_MUSHROOM);
	//setsize(mushroom, '-8 -8 -16', '8 8 8');
	vector cmin = this.mins, cmax = this.maxs;
	// some basic sanity, but otherwise use player's hitbox to avoid exploits
	cmin.z = -16;
	cmax.z = 32;
	setsize(mushroom, cmin, cmax);
	settouch(mushroom, mushroom_touch);
	setthink(mushroom, mushroom_projectile_think);
	mushroom.wait = time + 3;
	mushroom.nextthink = time;

	vector org = this.origin + (this.view_ofs * 0.75);
	setorigin(mushroom, org);
	mushroom.angles = this.angles;
	mushroom.pos2 = mushroom.angles;
	makevectors(this.v_angle);
	mushroom.velocity = v_forward * 400 + v_up * 64;

	this.mushroom_targ = mushroom;
}

METHOD(Mushroom, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_ThrowMushroom(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Mushroom, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Mushroom, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
