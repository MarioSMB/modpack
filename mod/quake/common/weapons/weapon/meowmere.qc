#include "meowmere.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void W_FireMeowmere(entity this, .entity weaponentity);

void player_meowmerea4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); }
void player_meowmerea3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_meowmerea4); }
void player_meowmerea2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_meowmerea3); }
void player_meowmerea1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_meowmerea2); }

void wep_meowmere_sworda3(entity this) { wep_set_anim(this, 3, w_ready); W_FireMeowmere(this.owner, this.weaponentity_fld); }
void wep_meowmere_sworda2(entity this) { wep_set_anim(this, 2, wep_meowmere_sworda3); }
void wep_meowmere_sworda1(entity this) { wep_set_anim(this, 1, wep_meowmere_sworda2); W_Parry_Trigger(this.owner, 0); }

void player_meowmereb4(entity this) { set_animofs(this, anim_player_axattc1, 4, player_run); }
void player_meowmereb3(entity this) { set_animofs(this, anim_player_axattc1, 3, player_meowmereb4); }
void player_meowmereb2(entity this) { set_animofs(this, anim_player_axattc1, 2, player_meowmereb3); }
void player_meowmereb1(entity this) { set_animofs(this, anim_player_axattc1, 1, player_meowmereb2); }

void wep_meowmere_swordb4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_meowmere_swordb3(entity this) { wep_set_anim(this, 7, wep_meowmere_swordb4); W_FireMeowmere(this.owner, this.weaponentity_fld); }
void wep_meowmere_swordb2(entity this) { wep_set_anim(this, 6, wep_meowmere_swordb3); }
void wep_meowmere_swordb1(entity this) { wep_set_anim(this, 5, wep_meowmere_swordb2); W_Parry_Trigger(this.owner, 0); }

.int cat_bouncecnt;

void W_Cat_Touch(entity this, entity toucher)
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
	if(toucher && toucher.solid != SOLID_BSP) // yoder mod, jan 05 2021
	{
		// handled by hack
	}
	else
	{
		this.cat_bouncecnt += 1;
		Send_Effect(EFFECT_MEOWMERE_IMPACT, this.origin, '0 0 0', 1);
		spamsound(this, CH_SHOTS, SND_MEOWMERE_BOUNCE_RANDOM(), VOL_BASE, ATTEN_NORM);

		T_RadiusDamage(this, this.owner, 60, this.projectiledeathtype, toucher);

		if(this.cat_bouncecnt >= 5)
		{
			setthink(this, SUB_Remove);
			this.nextthink = time;
			settouch(this, func_null);
		}
		return;
	}

	//delete(this);
}

.float cat_dmgtime;
void W_Cat_Think(entity this)
{
	if(time > this.count)
	{
		delete(this);
		return;
	}

	// hack to ensure the projectile keeps going even if it hits a target
	this.nextthink = time;

	if(time <= this.cat_dmgtime)
		return; // cooldown to prevent damage spam

	bool hitenemy = false;
	FOREACH_ENTITY_RADIUS(this.origin, this.cnt, it.takedamage && it != this.owner,
	{
		if(it.clipgroup && it.clipgroup == this.clipgroup)
			continue;
		float damg = ((this.dmg) ? this.dmg : 30);
		if(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			damg = 120;
		spawn_touchblood(this, damg, it);
		T_Damage(it, this, this.owner, damg, this.projectiledeathtype);

		this.cat_dmgtime = time + 0.1; // prevent instant death

		Send_Effect(EFFECT_MEOWMERE_GLIMMER, this.origin, '0 0 -20', 1);
		spamsound(this, CH_SHOTS, SND_MEOWMERE_BOUNCE_RANDOM(), VOL_BASE, ATTEN_NORM);

		hitenemy = true;
	});

	if(hitenemy)
	{
		this.cat_bouncecnt += 1;

		if(this.cat_bouncecnt >= 5)
		{
			setthink(this, SUB_Remove);
			this.nextthink = time;
			settouch(this, func_null);
		}
	}
}

void W_Cat_Fire(entity this, vector org, .entity weaponentity)
{
	// assumes v_ angles are setup

	org += v_right * 8;

	entity missile = new(cat);
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	missile.clipgroup = this.clipgroup;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_TRIGGER;
	missile.dphitcontentsmask = DPCONTENTS_SOLID;
	missile.gravity = 0.25;
	missile.projectiledeathtype = WEP_MEOWMERE.m_id;
	missile.cnt = 32; // rough area of effect during travel
	missile.cat_bouncecnt = 0;
	missile.dmg = 50;
	missile.bouncefactor = 1;
	missile.bouncestop = 0.1;

	vector dir = qc_aim(this, 10000);
	missile.velocity = dir * 1000;
	//missile.velocity_z = 200;

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, W_Cat_Touch);

	missile.count = time + 20;
	missile.nextthink = time;
	setthink(missile, W_Cat_Think);

	_setmodel(missile, "progs/proj_cat.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, true, PROJECTILE_CAT, true);
}

void W_FireMeowmere(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 120;
	traceline(source, source + v_forward * arange, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
	{
		W_Cat_Fire(this, source, weaponentity);
		return;
	}
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent && W_Parry(this, trace_ent))
		return;

	W_Cat_Fire(this, source, weaponentity);

	float r = random();
	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		{
			if(trace_ent.monsterdef == MON_JUGGERNAUT) // special case: axe attacks produce unique sound against juggernauts TODO: handle melee attacks in monster pain code
				_sound(this, CH_WEAPON_SINGLE, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
			else if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MON_FLAG_METAL))
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(IS_PLAYER(trace_ent) && trace_ent.armorvalue > 0)
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else
			{
				_sound(trace_ent, CH_SHOTS, "enviro/physics/trcut.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		float damage = 80;
		T_Damage(trace_ent, this, this, damage, WEP_MEOWMERE.m_id);
	}
	else
	{	// hit wall
		if(r < 0.3)
			_sound(this, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

PRECACHE(Meowmere)
{
	precache_model("progs/v_meowmere.mdl");
	precache_model("progs/g_meowmere.mdl");

	precache_model("progs/proj_cat.mdl");

	precache_sound("enviro/physics/trcut.wav");
	precache_sound("enviro/physics/axemet1.wav");
	precache_sound("enviro/physics/axemet2.wav");
	precache_sound("enviro/physics/axemet3.wav");
	precache_sound("monsters/juggers/jbent.wav");
}

METHOD(Meowmere, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_meowmereb1(actor);
		sound(actor, CH_WEAPON_SINGLE, SND_MEOWMERE_SWING, 1, ATTN_NORM);
		wep_meowmere_sworda1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Meowmere, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Meowmere, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Meowmere, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
