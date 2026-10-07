#include "jester.qh"

// ================
//  SMALL PRESENT
// ================

#ifdef SVQC
Turret present_pickturret(int ptype)
{
	RandomSelection_Init();
	switch(ptype)
	{
		default:
		case 0:
		case 1:
		{
			FOREACH(Turrets, it.impulse == ptype && !(it.spawnflags & TUR_FLAG_NOJESTER),
			{
				RandomSelection_AddEnt(it, 1, 1);
			});
			break;
		}
		case 2:
		{
			// unlike the others, big presents can pick any level turret
			FOREACH(Turrets, it.impulse >= 2 && !(it.spawnflags & TUR_FLAG_NOJESTER),
			{
				RandomSelection_AddEnt(it, 1, 1);
			});
			break;
		}
	}

	return RandomSelection_chosen_ent;
}

void present_explode(entity actor, int ptype)
{
	RandomSelection_Init();
	RandomSelection_AddFloat(PRESENT_TURRET, 75, 1);
	RandomSelection_AddFloat(PRESENT_FUEL, 15, 1);
	RandomSelection_AddFloat(PRESENT_EQUIPMENT, 5, 1);
	RandomSelection_AddFloat(PRESENT_SHAMBLER, 5, 1);

	switch(RandomSelection_chosen_float)
	{
		case PRESENT_TURRET:
		{
			// reapply the unit cost
			Turret tur = present_pickturret(ptype);
			if(tur == TUR_Null)
				break; // wtf

			// TODO: decouple buildtool version and use it here!
			entity turret = spawn();
			turret.classname = "turret";
			setorigin(turret, actor.origin); // TODO: safe location?
			turret.angles = '0 1 0' * actor.angles_y;
			turret.realowner = actor.realowner;
			turret.clipgroup = (actor.clipgroup) ? actor.clipgroup : CLIPGROUP_TDTURRET;
			turret.tur_units = actor.tur_units;
			//turret.candrag = true; // :)
			turret.attack_finished = time + 3;
			if(!turret_initialize(turret, tur))
			{
				delete(turret);
				break;
			}
			// restore the cost
			if(td_ent)
				td_ent.tur_units += turret.tur_units;
			turret.tur_level = actor.tur_level;
			turret_levelstats(turret);
			break;
		}
		case PRESENT_FUEL:
		{
			td_DropFuel(actor, 20 * (actor.tur_level + 1), NULL, true);
			break;
		}
		case PRESENT_EQUIPMENT:
		{
			td_DropItem(actor);
			break;
		}
		case PRESENT_SHAMBLER:
		{
			// can't use td_spawnmonster directly, we don't want to affect counts!
			// TODO: shouldn't need to worry about that...
			Monster mon = MON_SHAMBLER;
			entity monster = spawn();
			//monster.category = CATEGORY_MONSTER;
			monster.clipgroup = CLIPGROUP_TD;
			monster.damage_mod = 1 + ((actor.tur_level + 1) / 5);

			spawnmonster(monster, actor.origin + '0 0 24', '0 1 0' * actor.angles_y, mon);
			break;
		}
	}

	Send_Effect(EFFECT_PRESENT_OPEN, (actor.absmin + actor.absmax) * 0.5, '0 0 0', 1);

	switch(ptype)
	{
		default:
		case 0: _sound(actor, CH_TRIGGER_SINGLE, "turrets/present_cheaper.wav", 1, ATTN_NORM); break;
		case 1: _sound(actor, CH_TRIGGER_SINGLE, "turrets/present_moderate.wav", 1, ATTN_NORM); break;
		case 2: _sound(actor, CH_TRIGGER_SINGLE, "turrets/present_expensive.wav", 1, ATTN_NORM); break;
	}
}

METHOD(JesterPresents, tr_death, void(JesterPresents this, entity actor))
{
	present_explode(actor, this.impulse);
}
METHOD(JesterPresents, tr_think, void(JesterPresents this, entity actor))
{
	if(gametype == GAMETYPE_TD && td_phase == TD_PHASE_BUILD)
		actor.jump_flag = true; // reused field

	// we were spawned during build phase, explode!
	if(gametype == GAMETYPE_TD && td_phase == TD_PHASE_COMBAT && actor.jump_flag)
	{
		actor.health = 0;
		Killed(actor, actor, actor, DEATH_GENERIC.m_id);
		return;
	}
}
METHOD(JesterPresents, tr_setup, void(JesterPresents this, entity actor))
{
	// does nothing on its own
	actor.damage_flags = TFL_DMG_YES;
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	actor.firecheck_flags = TFL_FIRECHECK_NO;
	actor.shoot_flags = TFL_SHOOT_NO;
	actor.target_select_flags = TFL_TARGETSELECT_NO;
	actor.target_validate_flags = actor.target_select_flags;
}
#endif // SVQC
#ifdef CSQC
METHOD(JesterPresents, tr_getinfo, vector(JesterPresents this, entity actor, vector pos))
{
	// chances don't scale with levels!
	string text;
	pos.y += 16;
	text = "^9Turret^7 chance: ^975%";
	sui_drawcolortext(pos, '16 16 0', text, 1, 0);

	pos.y += 16;
	text = "^5Fuel^7 chance: ^515%";
	sui_drawcolortext(pos, '16 16 0', text, 1, 0);

	pos.y += 16;
	text = "^2Equipment^7 chance: ^25%";
	sui_drawcolortext(pos, '16 16 0', text, 1, 0);

	pos.y += 16;
	text = "^1Shambler^7 chance: ^15%";
	sui_drawcolortext(pos, '16 16 0', text, 1, 0);

	return pos;
}
#endif // CSQC

// ===============
//  SMALL PRESENT
// ===============

#ifdef SVQC
METHOD(JesterSmallPresent, tr_precache, void(JesterSmallPresent thistur))
{
	precache_sound("turrets/present_cheaper.wav");
}
#endif // SVQC

// ================
//  DELUXE PRESENT
// ================

#ifdef SVQC
METHOD(JesterDeluxePresent, tr_precache, void(JesterDeluxePresent thistur))
{
	precache_sound("turrets/present_moderate.wav");
}
#endif // SVQC

// ================
//  DELUXE PRESENT
// ================

#ifdef SVQC
METHOD(JesterExtravagantPresent, tr_precache, void(JesterExtravagantPresent thistur))
{
	precache_sound("turrets/present_expensive.wav");
}
#endif // SVQC

// =================
//  JACK IN THE BOX
// =================

#ifdef SVQC
const int JACKBOX_ANIM_IDLE = 0;
const int JACKBOX_ANIM_SHOOT = 1;

.float animflag;

void jackbox_setnoanim(entity this)
{
	turrets_setframe(this, JACKBOX_ANIM_IDLE, false);
	this.animflag = this.frame;
}

bool jackbox_firecheck(entity this)
{
	if (this.animflag == JACKBOX_ANIM_SHOOT)
		return false;
	return turret_firecheck(this);
}

void jackbox_hit(entity this, entity toucher)
{
	float damage = this.shot_dmg;
	float pforce = this.shot_force;

	// also push enemy away
	if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

		vector dir = normalize(toucher.origin - this.origin);
		toucher.velocity = dir * (pforce * pushforce);
		toucher.velocity_z = (125 * pushforce);
	}

	_sound(toucher, CH_SHOTS, "turrets/jackbox_hit.wav", 1, ATTN_NORM);

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);
}

METHOD(JesterJackBox, tr_precache, void(JesterJackBox this))
{
	precache_sound("turrets/jackbox_hit.wav");
	precache_sound("enviro/pinhead/pinfire.wav");
}
METHOD(JesterJackBox, tr_attack, void(JesterJackBox this, entity actor))
{
	defer(actor, 1.5, jackbox_setnoanim);
	turrets_setframe(actor, JACKBOX_ANIM_SHOOT, false);
	actor.animflag = actor.frame;

	_sound(actor, CH_WEAPON_SINGLE, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);

	if(actor.enemy)
		jackbox_hit(actor, actor.enemy);
}
METHOD(JesterJackBox, tr_setup, void(JesterJackBox this, entity actor))
{
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	//actor.shoot_flags = TFL_SHOOT_CLEARTARGET;

	turrets_setframe(actor, JACKBOX_ANIM_IDLE, false);

	actor.turret_firecheckfunc = jackbox_firecheck;

	actor.view_ofs = '0 0 16';
}
#endif // SVQC
#ifdef CSQC
METHOD(JesterJackBox, tr_drawselected, void(JesterJackBox this, entity actor))
{
	float myrange = this.target_range;
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 16';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ==============
//  PARTY POPPER
// ==============

#ifdef SVQC
bool popper_firecheck(entity this)
{
	if (this.animflag == POPPER_ANIM_ATTACKA
		|| this.animflag == POPPER_ANIM_ATTACKB
		|| this.animflag == POPPER_ANIM_ATTACKC)
		return false;
	return turret_firecheck(this);
}

void popper_setnoanim(entity this)
{
	turrets_setframe(this, POPPER_ANIM_IDLE, false);
	this.animflag = this.frame;
}

void popper_poison_explode(entity this)
{
	float mydmg = (this.dmg) ? this.dmg : 100;
	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, this.enemy);

	this.origin = this.origin - 8 * normalize(this.velocity);

	Send_Effect(EFFECT_TE_POISONBIG, this.origin, '0 0 0', 1);

	if(this.noise && this.noise != "")
		_sound(this, CH_SHOTS, this.noise, 1, ATTN_NORM);

	delete(this);
}

void popper_poison_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	if(toucher.takedamage)
	{
		float mydmg = (this.dmg) ? this.dmg : 50;
		float damg = mydmg + random() * (mydmg * 0.2);

		if(Resist_Explosions(toucher))
			damg *= 0.5;	// mostly immune
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	this.enemy = toucher;
	setthink(this, popper_poison_explode);
	this.nextthink = time;
	settouch(this, func_null);
}

void popper_poison_fire(entity actor)
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_poison_fire.wav", 1, ATTN_NORM);

	float damage = 30 * turret_getpower(actor.tur_level, 0.2);

	entity missile = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	settouch(missile, popper_poison_touch);
	missile.dmg = damage;
	missile.projectiledeathtype = DEATH_TRAP.m_id;
	missile.velocity = actor.tur_shotdir_updated * 250;
	missile.noise = "turrets/popper_poison_impact.wav";

	CSQCProjectile(missile, true, PROJECTILE_POPPER_POISON, true);
}

void popper_fireball_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = ((this.dmg) ? this.dmg : 20);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
	
	_sound(this, CH_SHOTS, "weapons/r_exp3b.wav", 1, ATTN_NORM);

	// our explosions are pretty big, try not to blow ourselves up!
	entity ignore = (toucher) ? toucher : this.owner;

	T_RadiusDamage(this, this.owner, this.dmg * 1.2, this.projectiledeathtype, ignore); // tonedown
	te_explosion2(this.origin, 230, 5);

	delete(this);
}

void popper_fireball_fire(entity actor)
{
	if(random() > 0.5)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_fireball_fire1.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_fireball_fire2.wav", 1, ATTN_NORM);

	float damage = 22 * turret_getpower(actor.tur_level, 0.2);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 300;
	newmis.dmg = damage;
	settouch(newmis, popper_fireball_touch);	

	CSQCProjectile(newmis, true, PROJECTILE_LAVABALL, true);
}

void popper_striker_fire(entity actor)
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_striker_fire.wav", 1, ATTN_NORM);

	float damage = 40 * turret_getpower(actor.tur_level, 0.2);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.classname = "wizard_spike"; // FIXME
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 1800;
	newmis.dmg = damage;	

	CSQCProjectile(newmis, true, PROJECTILE_POPPER_STRIKER, true);
}

void popper_djinn_fire(entity actor)
{
	if(random() > 0.5)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_djinn_fire1.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_djinn_fire2.wav", 1, ATTN_NORM);

	float damage = bound(10, random() * 60, 60) * turret_getpower(actor.tur_level, 0.2);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.classname = "wizard_spike"; // FIXME
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 600;
	newmis.dmg = damage;	

	CSQCProjectile(newmis, true, PROJECTILE_POPPER_DJINN, true);
}

void popper_arrow_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = ((this.dmg) ? this.dmg : 9);
		if(toucher.resist_nails != 0)
			damg = Resist_Damage(toucher, IT_NAILS, damg);
		Resist_Nails(toucher, this.origin);

		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		float r = random();
		if(r < 0.33)
			_sound(this, CH_SHOTS, "turrets/popper_arrow_hit1.wav", 1, ATTN_NORM);
		else if(r < 0.33)
			_sound(this, CH_SHOTS, "turrets/popper_arrow_hit2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_SHOTS, "turrets/popper_arrow_hit3.wav", 1, ATTN_NORM);
	}
	else
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_SHOTS, "turrets/popper_arrow_impact1.wav", 1, ATTN_NORM);
		else if(r < 0.33)
			_sound(this, CH_SHOTS, "turrets/popper_arrow_impact2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_SHOTS, "turrets/popper_arrow_impact3.wav", 1, ATTN_NORM);
	}

	te_spike(this.origin);

	delete(this);
}

void popper_arrow_fire(entity actor)
{
	float r = random();
	if(r < 0.33)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_arrow_fire1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_arrow_fire2.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_arrow_fire3.wav", 1, ATTN_NORM);

	float damage = 16 * turret_getpower(actor.tur_level, 0.2);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 360;
	newmis.dmg = damage;
	settouch(newmis, popper_arrow_touch);

	CSQCProjectile(newmis, true, PROJECTILE_POPPER_ARROW, true);
}

void popper_magic_fire(entity actor)
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/popper_magic_fire.wav", 1, ATTN_NORM);

	float damage = 15 * turret_getpower(actor.tur_level, 0.2);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.classname = "wizard_spike"; // FIXME
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 300;
	newmis.dmg = damage;	

	CSQCProjectile(newmis, true, PROJECTILE_POPPER_MAGIC, true);
}

METHOD(JesterPartyPopper, tr_precache, void(JesterPartyPopper this))
{
	precache_sound("turrets/popper_poison_fire.wav");
	precache_sound("turrets/popper_poison_impact.wav");

	precache_sound("turrets/popper_fireball_fire1.wav");
	precache_sound("turrets/popper_fireball_fire2.wav");
	precache_sound("weapons/r_exp3b.wav");

	precache_sound("turrets/popper_striker_fire.wav");

	precache_sound("turrets/popper_djinn_fire1.wav");
	precache_sound("turrets/popper_djinn_fire2.wav");

	precache_sound("turrets/popper_arrow_fire1.wav");
	precache_sound("turrets/popper_arrow_fire2.wav");
	precache_sound("turrets/popper_arrow_fire3.wav");
	precache_sound("turrets/popper_arrow_impact1.wav");
	precache_sound("turrets/popper_arrow_impact2.wav");
	precache_sound("turrets/popper_arrow_impact3.wav");
	precache_sound("turrets/popper_arrow_hit1.wav");
	precache_sound("turrets/popper_arrow_hit2.wav");
	precache_sound("turrets/popper_arrow_hit3.wav");

	precache_sound("turrets/popper_magic_fire.wav");
}
METHOD(JesterPartyPopper, tr_attack, void(JesterPartyPopper this, entity actor))
{
	defer(actor, 2, popper_setnoanim);

	int anim;
	float r = random();
	if(r < 0.33)
		anim = POPPER_ANIM_ATTACKA;
	else if(r < 0.66)
		anim = POPPER_ANIM_ATTACKB;
	else
		anim = POPPER_ANIM_ATTACKC;

	turrets_setframe(actor, anim, false);
	actor.animflag = actor.frame;

	r = random();
	if(r < 0.16)
		popper_poison_fire(actor);
	else if(r < 0.32)
		popper_striker_fire(actor);
	else if(r < 0.48)
		popper_djinn_fire(actor);
	else if(r < 0.64)
		popper_arrow_fire(actor);
	else if(r < 0.80)
		popper_magic_fire(actor);
	else
		popper_fireball_fire(actor);
}
METHOD(JesterPartyPopper, tr_setup, void(JesterPartyPopper this, entity actor))
{
	actor.view_ofs = '0 0 64'; // for line of sight checks

	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
	//actor.turret_firecheckfunc = popper_firecheck;
}
#endif // SVQC
#ifdef CSQC
METHOD(JesterPartyPopper, tr_getinfo, vector(JesterPartyPopper this, entity actor, vector pos))
{
	string text;

	pos.y += 16;
	text = "^7Damage: ^3???";
	sui_drawcolortext(pos, '16 16 0', text, 1, 0);

	return pos;
}
METHOD(JesterPartyPopper, tr_drawselected, void(JesterPartyPopper this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);

	vector org = actor.origin + '0 0 64';
	makevectors(actor.angles);

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC
