#include "axe.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
PRECACHE(SolarEruption)
{
	precache_model("progs/g_solareruption.mdl");
	precache_model("progs/v_solareruption.mdl");

	precache_sound("weapons/solareruption_fire.wav");
	precache_sound("weapons/solareruption_impact.wav");

	precache_model("progs/fx/spark1.mdl");
	precache_model("progs/fx/spark2.mdl");
	precache_model("progs/fx/spark3.mdl");
	precache_model("progs/fx/spark4.mdl");
	precache_model("progs/fx/blood1.mdl");
	precache_model("progs/fx/blood2.mdl");
	precache_model("progs/fx/blood3.mdl");
	precache_model("progs/fx/blood4.mdl");

	precache_sound("impact/wrench_impact1.wav");
	precache_sound("impact/wrench_impact2.wav");
	precache_sound("impact/wrench_impact3.wav");
	precache_sound("impact/wrench_impact4.wav");
	precache_sound("impact/wrench_swing.wav");
	precache_sound("impact/wrench_clink.wav");
	//precache_sound("impact/wrench_clank1.wav");
	//precache_sound("impact/wrench_clank2.wav");
	//precache_sound("impact/hit_player1.wav");
	//precache_sound("impact/hit_player2.wav");
	//precache_sound("impact/hit_player3.wav");
	//precache_sound("impact/hit_player4.wav");

	precache_sound("impact/bullet_metal1.wav");
	precache_sound("impact/bullet_metal2.wav");
	precache_sound("impact/bullet_metal3.wav");
	precache_sound("impact/bullet_metal4.wav");

	precache_sound("zombie/z_hit.wav");
}

void player_solareruption10(entity this) { set_animofs(this, anim_player_axatt1, 6, player_run); }
void player_solareruption9(entity this) { set_animofs(this, anim_player_axatt1, 5, player_solareruption10); }
void player_solareruption8(entity this) { set_animofs(this, anim_player_axatt1, 4, player_solareruption9); }
void player_solareruption7(entity this) { set_animofs(this, anim_player_axatt1, 4, player_solareruption8); }
void player_solareruption6(entity this) { set_animofs(this, anim_player_axatt1, 3, player_solareruption7); }
void player_solareruption5(entity this) { set_animofs(this, anim_player_axatt1, 3, player_solareruption6); }
void player_solareruption4(entity this) { set_animofs(this, anim_player_axatt1, 2, player_solareruption5); }
void player_solareruption3(entity this) { set_animofs(this, anim_player_axatt1, 2, player_solareruption4); }
void player_solareruption2(entity this) { set_animofs(this, anim_player_axatt1, 1, player_solareruption3); }
void player_solareruption1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_solareruption2); }

void wep_solareruption_anim_fire(entity this)
{
	//entity actor = this.owner;
	//.entity weaponentity = this.weaponentity_fld;

	if(this.m_frame >= 9)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}
	this.m_frame += 1;

	wep_set_anim(this, this.m_frame, wep_solareruption_anim_fire);
}

void wep_solareruption_anim(entity this)
{
	entity actor = this.owner;
	//.entity weaponentity = this.weaponentity_fld;
	// TODO: berserk?

	//_sound(actor, CH_WEAPON_B, "weapons/solareruption_fire.wav", 1, ATTN_NORM);

	this.m_frame = 1;

	if(IS_PLAYER(actor))
		player_solareruption1(actor);

	wep_set_anim(this, this.m_frame, wep_solareruption_anim_fire);
}

//=============================================================================================

void sound_solareruption_hit_enemy(entity this, float solareruptionhit_volume)
{
	int r = floor(random() * 4);
	if(r == 0)
		_sound(this, CH_SHOTS, "impact/wrench_impact1.wav", solareruptionhit_volume, ATTN_NORM);
	else if(r == 1)
		_sound(this, CH_SHOTS, "impact/wrench_impact2.wav", solareruptionhit_volume, ATTN_NORM);
	else if(r == 2)
		_sound(this, CH_SHOTS, "impact/wrench_impact3.wav", solareruptionhit_volume, ATTN_NORM);
	else
		_sound(this, CH_SHOTS, "impact/wrench_impact4.wav", solareruptionhit_volume, ATTN_NORM);
}
//=============================================================================================
#if 0
void sound_solareruption_hit_player(entity this, float meleehit_volume)
{
	int r = floor(random() * 4);
	if(r == 0)
		_sound(this, CH_SHOTS, "impact/hit_player1.wav", meleehit_volume, ATTN_NORM);
	else if(r == 1)
		_sound(this, CH_SHOTS, "impact/hit_player2.wav", meleehit_volume, ATTN_NORM);
	else if(r == 2)
		_sound(this, CH_SHOTS, "impact/hit_player3.wav", meleehit_volume, ATTN_NORM);
	else
		_sound(this, CH_SHOTS, "impact/hit_player4.wav", meleehit_volume, ATTN_NORM);
}
#endif
//=============================================================================================
// defined elsewhere
void sound_bullet_hit_metal(entity this, float pistolhitmetal_volume);

void sound_solareruption_hit_world(entity this, float solareruptionclank_volume)
{
	_sound(this, CH_SHOTS, "impact/wrench_clink.wav", solareruptionclank_volume, ATTN_NORM);
	//if(random() < 0.5)	sound (this, CHAN_AUTO, "impact/wrench_clank1.wav", solareruptionclank_volume, ATTN_NORM);
	//else			sound (this, CHAN_AUTO, "impact/wrench_clank2.wav", solareruptionclank_volume, ATTN_NORM);
}

void anim_solareruptionfx(entity this)
{
	this.alpha -= 0.1;
	this.frame += 1;

	if(this.frame >= 6)
	{
		delete(this);
		return;
	}

	setthink(this, anim_solareruptionfx);
	this.nextthink = time + 0.05;
}

void FX_SolarEruption(vector org, vector dir, bool is_spark)
{
	entity fx = spawn();
	set_movetype(fx, MOVETYPE_NONE);
	fx.solid = SOLID_NOT;
	fx.classname = "impact";

	fx.angles = vectoangles(dir);

	fx.frame = 0;
	fx.alpha = 1;

	setthink(fx, anim_solareruptionfx);
	fx.nextthink = time + 0.1;

	int r = floor(random() * 4);
	if(is_spark)
	{
		switch(r)
		{
			case 0: _setmodel(fx, "progs/fx/spark1.mdl"); break;
			case 1: _setmodel(fx, "progs/fx/spark2.mdl"); break;
			case 2: _setmodel(fx, "progs/fx/spark3.mdl"); break;
			default: _setmodel(fx, "progs/fx/spark4.mdl"); break;
		}
	}
	else
	{
		switch(r)
		{
			case 0: _setmodel(fx, "progs/fx/blood1.mdl"); break;
			case 1: _setmodel(fx, "progs/fx/blood2.mdl"); break;
			case 2: _setmodel(fx, "progs/fx/blood3.mdl"); break;
			default: _setmodel(fx, "progs/fx/blood4.mdl"); break;
		}
	}
	setsize(fx, '0 0 0', '0 0 0');

	setorigin(fx, org);
}

void DelayedEruptionThink(entity this)
{
	T_RadiusDamage(this, this.enemy, this.dmg, DEATH_EXPLODE.m_id, this.owner);

	// Allow for sound to finish and just remove
	setthink(this, SUB_Remove);
	this.nextthink = time + 4;

	// Play any explosion sounds on temporary entity
	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	_sound(this, CH_SHOTS, "weapons/solareruption_impact.wav", 1, ATTN_NORM);
}

void eruption_delayed(entity targ, entity attacker, float damage)
{
	entity t = new_pure(DelayedExplosion);
	t.nextthink = time;
	setthink(t, DelayedEruptionThink);
	t.enemy = attacker;
	t.owner = targ;
	t.dmg = damage;
	t.solid = SOLID_NOT;
	set_movetype(t, MOVETYPE_NONE);
	setsize(t, '0 0 0', '0 0 0');
	setorigin(t, targ.origin);
}

// enable to debug melee range
//#define SOLARERUPTION_MELEEDEBUG

float autocvar_sv_quake_solareruption_delay = 0.4;
float autocvar_sv_quake_solareruption_time = 0.15;
int autocvar_sv_quake_solareruption_traces = 10;
float autocvar_sv_quake_solareruption_swing_side = 250;
float autocvar_sv_quake_solareruption_swing_up = 30;
float autocvar_sv_quake_solareruption_range = 380;
float autocvar_sv_quake_solareruption_damage = 70;

.float swing_prev;
.entity swing_alreadyhit;
void W_SolarEruption_Think(entity this)
{
	if (!this.cnt) // set start time of melee
	{
		this.cnt = time;
		SuperDamageSound(this.realowner); 
	}

	makevectors(this.realowner.v_angle); // update values for v_* vectors

	float arate = 1;
	if(this.realowner.m_champion && this.realowner.m_champion.qcc_attackrate)
		arate *= this.realowner.m_champion.qcc_attackrate;
	if(STAT(PASSIVES, this.realowner) & PASSIVE_ADRENALIN)
		arate *= 0.8;

	// calculate swing percentage based on time
	float meleetime = autocvar_sv_quake_solareruption_time * arate;
	float swing = bound(0, (this.cnt + meleetime - time) / meleetime, 10);
	float f = ((1 - swing) * autocvar_sv_quake_solareruption_traces);

	// check to see if we can still continue, otherwise give up now
	if (this.realowner.health < 1)
	{
		delete(this);
		return;
	}

	vector melee_path = (v_up    * autocvar_sv_quake_solareruption_swing_up)
	                  + (v_right * autocvar_sv_quake_solareruption_swing_side);
	// if okay, perform the traces needed for this frame
	entity target_victim;
	vector targpos;
	float swing_factor, swing_damage, i;
	for (i = this.swing_prev; i < f; ++i)
	{
		swing_factor = (1 - (i / autocvar_sv_quake_solareruption_traces)) * 2 - 1;

		targpos = this.realowner.origin + this.realowner.view_ofs
			+ (melee_path * swing_factor)
			+ (v_forward * autocvar_sv_quake_solareruption_range);

		traceline_antilag(this.realowner, this.realowner.origin + this.realowner.view_ofs, targpos, false, this.realowner, ((IS_CLIENT(this.realowner)) ? ANTILAG_LATENCY(this.realowner) : 0));

		//Send_Effect(EFFECT_EF_FLAME, trace_endpos, -melee_path, 1);

		// draw lightning beams for debugging
	#ifdef SOLARERUPTION_MELEEDEBUG
		te_lightning2(NULL, targpos, this.realowner.origin + this.realowner.view_ofs + v_forward * 5 - v_up * 5);
		te_customflash(targpos, 40,  2, '1 1 1');
	#endif

		bool is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body");

		float nonplayerdamage = autocvar_sv_quake_solareruption_damage;
		float playerdamage = nonplayerdamage * 0.5;

		if (trace_fraction < 1 // if trace is good, apply the damage and remove this
		&&  trace_ent.takedamage != DAMAGE_NO
		&&  trace_ent != this.swing_alreadyhit
		&&  time >= trace_ent.swing_prev
		&& (is_player || nonplayerdamage))
		{
			target_victim = trace_ent; // so it persists through other calls

			target_victim.swing_prev = time + meleetime; // prevent repeat traces

			if (is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (playerdamage * min(1, swing_factor + 1));
			else
				swing_damage = (nonplayerdamage * min(1, swing_factor + 1));

			if(target_victim.monsterdef.spawnflags & MON_FLAG_METAL)
			{
				FX_SolarEruption(trace_endpos, -melee_path, true);
				sound_bullet_hit_metal(target_victim, 1);
			}

			sound_solareruption_hit_enemy(target_victim, 1);

			float burntime = floor(3 + 2*random());
			// only add more burn time if there isn't already a longer timer running!
			float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, target_victim);
			if((time + burntime) > curtime)
				StatusEffects_apply(STATUSEFFECT_Burning, target_victim, time + burntime, 0);

			if(!this.count)
			{
				this.count = true;
				eruption_delayed(target_victim, this.realowner, swing_damage * 1.5);
			}

			//print(strcat(this.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			T_Damage(target_victim, this.realowner, this.realowner, swing_damage, WEP_SOLARERUPTION.m_id);

			// draw large red flash for debugging
		#ifdef SOLARERUPTION_MELEEDEBUG
			te_customflash(targpos, 200, 2, '15 0 0');
		#endif

			this.swing_alreadyhit = target_victim;
			continue; // move along to next trace
		}

		// we got here, not a valid target but maybe a wall!
		if (trace_fraction < 1 && (!trace_ent || trace_ent.solid == SOLID_BSP))
		{
			_sound(this.realowner, CH_WEAPON_SINGLE, "player/axhit2.wav", 0.2, ATTN_NORM);

			FX_SolarEruption(trace_endpos, -melee_path, true);

			te_gunshot(trace_endpos);
		}
	}

	if (time >= this.cnt + meleetime)
	{
		// melee is finished
		delete(this);
		return;
	}
	else
	{
		// set up next frame
		this.swing_prev = i;
		this.nextthink = time;
	}
}

void W_SolarEruption_Attack(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_A, "weapons/solareruption_fire.wav", VOL_BASE, ATTEN_NORM);

	float arate = 1;
	if(actor.m_champion && actor.m_champion.qcc_attackrate)
		arate *= actor.m_champion.qcc_attackrate;
	if(STAT(PASSIVES, actor) & PASSIVE_ADRENALIN)
		arate *= 0.8;

	entity meleetemp = new_pure(meleetemp);
	meleetemp.realowner = actor;
	setthink(meleetemp, W_SolarEruption_Think);
	meleetemp.nextthink = time + autocvar_sv_quake_solareruption_delay * arate;
	meleetemp.weaponentity_fld = weaponentity;
}

METHOD(SolarEruption, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		wep_solareruption_anim(actor.(weaponentity));
		W_SolarEruption_Attack(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(SolarEruption, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(SolarEruption, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(SolarEruption, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
