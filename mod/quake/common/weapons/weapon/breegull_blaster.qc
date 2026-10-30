#include "breegull_blaster.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
float autocvar_sv_quake_clockwork_time = 7;
float autocvar_sv_quake_clockwork_time_horde = 7;

PRECACHE(BreegullBlaster)
{
	precache_model("progs/g_breegull.mdl");
	precache_model("progs/v_breegull.mdl");
	precache_model("progs/clockwork.mdl");

    precache_sound("weapons/egg0_fire.wav");
    precache_sound("weapons/egg1_fire.wav");
    precache_sound("weapons/egg2_fire.wav");
    precache_sound("weapons/egg3_fire.wav");
    precache_sound("weapons/egg4_fire.wav");
    precache_sound("weapons/egg5_fire.wav");

    precache_sound("weapons/egg0.wav");
    precache_sound("weapons/egg1.wav");
    precache_sound("weapons/egg2.wav");
    precache_sound("weapons/egg3.wav");
    precache_sound("weapons/egg4.wav");
    precache_sound("weapons/egg5.wav");

    precache_sound("misc/clockwork_footstep1.wav");
    precache_sound("misc/clockwork_footstep2.wav");

    precache_sound("drole/r_explode.wav");
}

void Clockwork_Clear(entity this)
{
	// a cleanup function for when the player is reset
	if(this.clockwork)
		delete(this.clockwork);
	this.clockwork = NULL;
}

void Clockwork_Remove(entity this)
{
	cannon_clear(this);
	this.solid = SOLID_SLIDEBOX;
	this.flags &= ~FL_NOTARGET;
	this.takedamage = DAMAGE_AIM;
	set_movetype(this, MOVETYPE_WALK);
	_setmodel(this, get_playermodel(this));
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	settouch(this, player_touch);
	if(this.clockwork)
	{
		.entity weaponentity = this.clockwork.weaponentity_fld;
		ATTACK_FINISHED(this, weaponentity) = time + 1;
		this.scale = this.clockwork.cnt;
		setorigin(this, this.clockwork.origin);
		this.oldorigin = this.origin;
		this.jump_flag = 0;
		this.velocity = this.clockwork.velocity;
		this.oldvelocity = this.velocity;
		this.angles = this.clockwork.angles;
		this.v_angle = this.clockwork.v_angle;
		this.fixangle = true;
		delete(this.clockwork);
	}
	this.clockwork = NULL;
	player_run(this);
}

void Clockwork_ExplodeThink(entity this)
{
	T_RadiusDamage(this, this, 120, WEP_BREEGULLBLASTER.m_id, this);

	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	setthink(this, Clockwork_Remove);
	this.nextthink = time + 1;
}

void Clockwork_Explode(entity this)
{
	if(this.clockwork)
	{
		this.clockwork.active = false;
		this.health = this.clockwork.health;
	}
	else
		this.health = 50; // TODO?
	this.velocity = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	settouch(this, func_null);
	this.solid = SOLID_NOT;
	_setmodel(this, "null");
	setsize(this, '0 0 0', '0 0 0');
	this.takedamage = DAMAGE_NO;
	setthink(this, Clockwork_ExplodeThink);
	this.nextthink = time;
}

void Clockwork_Touch(entity this, entity toucher)
{
	if(toucher.takedamage && Damage_ValidTarget(toucher, this))
	{
		Clockwork_Explode(this);
		return;
	}
	// do nothing for interactions?
}

void Dummy_Think(entity this)
{
	if(!this.active)
		return; // doing cutscene
	if(!this.realowner || this.realowner.clockwork != this)
	{
		delete(this);
		return;
	}

	if(time > this.count || (this.realowner.button0 && !STAT(CANNON, this.realowner) && time > ATTACK_FINISHED(this.realowner, this.weaponentity_fld)))
	{
		Clockwork_Explode(this.realowner);
		return;
	}

	this.walkframe += 1;
	if(this.walkframe >= 5)
		this.walkframe = 0;
	this.frame = anim_player_stand1 + this.walkframe;

	this.nextthink = time + 0.1;
}

void W_BreegullBlaster_ClockworkTouch(entity this, entity toucher)
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

	if(toucher.takedamage)
	{
		// handle as an explosion
		T_MissileTouch(this, toucher);
		return;
	}

	// NOTE: we *could* exclude non-Banjo champions here, but where's the fun in that?!
	if(!this.owner || this.owner.health <= 0 || !IS_PLAYER(this.owner) || STAT(CANNON, this.owner) || this.owner.clockwork || this.owner.tank || this.owner.m_transform || STAT(SLIDE_ON, this.owner) || STAT(SKATING, this.owner))
	{
		delete(this);
		return;
	}

	entity player = this.owner;
	entity dummy = new(dummy);
	setorigin(dummy, player.origin + '0 0 1');
	dummy.angles = player.angles;
	dummy.v_angle = player.v_angle;
	dummy.colormap = player.colormap;
	dummy.dphitcontentsmask = player.dphitcontentsmask;
	dummy.solid = SOLID_BBOX;
	dummy.scale = player.scale;
	dummy.health = player.health;
	_setmodel(dummy, player.model);
	setsize(dummy, player.mins, player.maxs);
	dummy.realowner = player;
	dummy.clipgroup = player.clipgroup;
	dummy.frame = player.frame;
	dummy.cnt = player.scale;
	dummy.active = true;
	dummy.weaponentity_fld = this.weaponentity_fld;
	if(gametype == GAMETYPE_HORDE || deathmatch)
		dummy.count = time + autocvar_sv_quake_clockwork_time_horde; // short duration!
	else
		dummy.count = time + autocvar_sv_quake_clockwork_time; // short duration!
	setthink(dummy, Dummy_Think);
	dummy.nextthink = time + 0.1;
	set_movetype(dummy, MOVETYPE_TOSS);

	player.clockwork = dummy;

	vector org = this.origin + '0 0 8';
	settouch(player, Clockwork_Touch);
	player.oldorigin = org;
	_setmodel(player, "progs/clockwork.mdl");
	setsize(player, '-8 -8 -1', '8 8 8');
	setorigin(player, org);
	player.health = 15;
	player.flags |= FL_NOTARGET;

	delete(this);
}

void W_BreegullBlaster_ClockworkExplode(entity this)
{
	te_tarexplosion(this.origin);
				
	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	_setmodel(exp, "progs/s_explod.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	T_RadiusDamage(this, this.owner, 50, WEP_BREEGULLBLASTER.m_id, this);

	setthink(this, SUB_Remove);
	this.nextthink = time;
}

float W_BreegullBlaster_AttackRate(entity actor, .entity weaponentity)
{
	int eggtype = STAT(BREEGULL_EGGTYPE, actor);
	float attack_delay = 0.5;
	switch(eggtype)
	{
		default:
		case 0:
		{
			attack_delay = 0.5;
			actor.(weaponentity).count += 1;
			if(actor.(weaponentity).count >= 3)
			{
				actor.(weaponentity).count = 0;
				attack_delay = 1;
			}
			break;
		}
		case 1: attack_delay = 1; break;
		case 2: attack_delay = 1.25; break;
		case 3: attack_delay = 1; break;
		case 4: attack_delay = 1; break;
		case 5: attack_delay = 0.25; break;
	}
	return attack_delay;
}

void W_BreegullBlaster_Touch(entity this, entity toucher)
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

	int eggtype = this.skin;
	float damg = ((this.dmg) ? this.dmg : 20);

	switch(eggtype)
	{
		case 0:
		{
			te_wizspike(this.origin);
			//_sound(this, CH_WEAPON_SINGLE, "weapons/grape_impact.wav", 1, ATTN_NORM);
			break;
		}
		case 1:
		{
			if(toucher.takedamage && Damage_ValidTarget(toucher, this.owner))
				StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + 7, 0);
			te_knightspike(this.origin);
			break;
		}
		case 2: break; // handled
		case 3:
		{
			if(toucher.takedamage && Damage_ValidTarget(toucher, this.owner))
				StatusEffects_apply(STATUSEFFECT_Slowness, toucher, time + 7, 0);
			if(StatusEffects_active(STATUSEFFECT_Burning, toucher))
			{
				damg = 100; // extinguish them!
				StatusEffects_remove(STATUSEFFECT_Burning, toucher, STATUSEFFECT_REMOVE_NORMAL);
			}
			__pointparticles(_particleeffectnum("electro_ballexplode"), this.origin, '0 0 0', 1);
			break;
		}
		case 4: break; // handled
		case 5:
		{
			te_spike(this.origin);
			break;
		}
	}

	if(toucher.takedamage)
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

	delete(this);
}

void W_BreegullBlaster_Fire(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	int eggtype = STAT(BREEGULL_EGGTYPE, this);
	vector org = W_Shotorg(this, weaponentity) - '0 0 12';
	vector dir = qc_aim(this, 600);

	entity newmis = launch_spike(this, org, dir);
	newmis.scale = 0.6;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.skin = eggtype;
	newmis.dmg = 30;
	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	newmis.velocity = dir * 600;
	newmis.weaponentity_fld = weaponentity;
	settouch(newmis, W_BreegullBlaster_Touch);
	newmis.projectiledeathtype = WEP_BREEGULLBLASTER.m_id;

	string snd = "";
	switch(eggtype)
	{
		default:
		case 0: snd = "weapons/egg0_fire.wav"; CSQCProjectile(newmis, true, PROJECTILE_EGG_NORMAL, true); break;
		case 1: snd = "weapons/egg1_fire.wav"; newmis.dmg = 20; CSQCProjectile(newmis, true, PROJECTILE_EGG_FIRE, true); break;
		case 2:
		{
			snd = "weapons/egg2_fire.wav";
			newmis.noise = "drole/r_explode.wav";
			settouch(newmis, T_MissileTouch);
			newmis.dmg = 60;
			CSQCProjectile(newmis, true, PROJECTILE_EGG_GRENADE, true);
			break;
		}
		case 3: snd = "weapons/egg3_fire.wav"; newmis.dmg = 20; CSQCProjectile(newmis, true, PROJECTILE_EGG_ICE, true); break;
		case 4:
		{
			snd = "weapons/egg4_fire.wav";
			newmis.noise = "weapons/r_exp3.wav";
			newmis.dmg = 70;
			setsize(newmis, '-8 -8 -8', '8 8 8');
			tracebox(this.origin, newmis.mins, newmis.maxs, org, MOVE_NOMONSTERS, this);
			setorigin(newmis, trace_endpos);
			set_movetype(newmis, MOVETYPE_TOSS);
			newmis.velocity = dir * 400 + v_up * 60;
			setthink(newmis, W_BreegullBlaster_ClockworkExplode);
			settouch(newmis, W_BreegullBlaster_ClockworkTouch);
			CSQCProjectile(newmis, true, PROJECTILE_EGG_CLOCKWORK, true);
			break;
		}
		case 5: snd = "weapons/egg5_fire.wav"; newmis.dmg = 10; CSQCProjectile(newmis, true, PROJECTILE_EGG_GOLD, true); break;
	}

	_sound(this, CH_WEAPON_SINGLE, snd, 1, ATTN_NORM);
}

void W_BreegullBlaster_Select(entity actor, int index)
{
	if(STAT(BREEGULL_EGGTYPE, actor) == index)
		return;

	STAT(BREEGULL_EGGTYPE, actor) = index;

	string snd = "";
	switch(index)
	{
		default:
		case 0: snd = "weapons/egg0.wav"; break;
		case 1: snd = "weapons/egg1.wav"; break;
		case 2: snd = "weapons/egg2.wav"; break;
		case 3: snd = "weapons/egg3.wav"; break;
		case 4: snd = "weapons/egg4.wav"; break;
		case 5: snd = "weapons/egg5.wav"; break;
	}
	_sound(actor, CH_WEAPON_B, snd, 1, ATTN_NORM);
}

METHOD(BreegullBlaster, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(!(fire & 1))
		actor.(weaponentity).count = 0;

	// checking secondary first as a page swap prevents attacking
	if(fire & 2)
	if(!(time < actor.attack2_finished))
	{
		int index = STAT(BREEGULL_EGGTYPE, actor) + 1;
		if(index > 5)
			index = 0;

		W_BreegullBlaster_Select(actor, index);
		
		ATTACK_FINISHED(actor, weaponentity) = max(ATTACK_FINISHED(actor, weaponentity), time + 0.5); // also prevent primary fire during this time
		actor.attack2_finished = time + 0.5; // slight delay between swapping, also prevents fireballs!
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_BreegullBlaster_Fire(actor, weaponentity);
		float attack_delay = W_BreegullBlaster_AttackRate(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, attack_delay);
	}
}
METHOD(BreegullBlaster, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(BreegullBlaster, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(BreegullBlaster, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef SVQC
METHOD(EggSelection, m_select, void(entity actor, int index))
{
	if(index > 5)
		index = 0; // TODO: ignore?

	W_BreegullBlaster_Select(actor, index);
}
#endif
#ifdef CSQC
METHOD(EggSelection, m_condition, bool(RadialMenu this))
{
	entity thiswep = viewmodels[0]; // WEAPONTODO
	Weapon wep = thiswep.activeweapon;

	return (wep == WEP_BREEGULLBLASTER);
}

METHOD(EggSelection, m_getentry, string(int index))
{
	switch(index)
	{
		case 0: return "gfx/quake/egg0";
		case 1: return "gfx/quake/egg1";
		case 2: return "gfx/quake/egg2";
		case 3: return "gfx/quake/egg3";
		case 4: return "gfx/quake/egg4";
		case 5: return "gfx/quake/egg5";
	}
	return string_null;
}
#endif
