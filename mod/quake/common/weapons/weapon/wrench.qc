#include "axe.qh"

#include "../../monsters/_mod.qh"

//=============================================================================================
// multi-hit melee sweeping code by bmFbr, edits by Kebby
//=============================================================================================
/*
	Wrench 
	{0-70}
	v_wrench
	
	0  idle
	1-10  draw > idle
	11-(14)-[26]-30  swing
	31-(34)-[46]-50  swing
	51-(54)-[66]-70  swing
	~~~
	71-80  twirl
	81-101  idle loop
	
	*swing (hit) [skip] > idle
	
	MD3
	v_wrench_gloves
	v_wrench
*/
//=============================================================================================

#ifdef SVQC
PRECACHE(Wrench)
{
	precache_model("progs/g_wrench.mdl");
	precache_model("progs/v_wrench.mdl");

	precache_model("progs/fx/spark1.mdl");
	precache_model("progs/fx/spark2.mdl");
	precache_model("progs/fx/spark3.mdl");
	precache_model("progs/fx/spark4.mdl");
	precache_model("progs/fx/blood1.mdl");
	precache_model("progs/fx/blood2.mdl");
	precache_model("progs/fx/blood3.mdl");
	precache_model("progs/fx/blood4.mdl");

	precache_sound("impact/fist_hit.wav");
	precache_sound("impact/fist_impact1.wav");
	precache_sound("impact/fist_impact2.wav");
	precache_sound("impact/fist_impact3.wav");
	precache_sound("impact/fist_impact4.wav");
	precache_sound("impact/wrench_impact1.wav");
	precache_sound("impact/wrench_impact2.wav");
	precache_sound("impact/wrench_impact3.wav");
	precache_sound("impact/wrench_impact4.wav");
	precache_sound("impact/wrench_swing.wav");
	precache_sound("impact/wrench_clink.wav");
	//precache_sound("impact/wrench_clank1.wav");
	//precache_sound("impact/wrench_clank2.wav");
	precache_sound("impact/hit_player1.wav");
	precache_sound("impact/hit_player2.wav");
	precache_sound("impact/hit_player3.wav");
	precache_sound("impact/hit_player4.wav");

	precache_sound("impact/bullet_metal1.wav");
	precache_sound("impact/bullet_metal2.wav");
	precache_sound("impact/bullet_metal3.wav");
	precache_sound("impact/bullet_metal4.wav");

	precache_sound("zombie/z_hit.wav");
}

void player_wrench6(entity this) { set_animofs(this, anim_player_axatt1, 6, player_run); }
void player_wrench5(entity this) { set_animofs(this, anim_player_axatt1, 5, player_wrench6); }
void player_wrench4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_wrench5); }
void player_wrench3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_wrench4); }
void player_wrench2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_wrench3); }
void player_wrench1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_wrench2); }

void wep_wrench_anim_fire(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if(this.m_frame == 14 || this.m_frame == 34 || this.m_frame == 54)
		W_FireWrench(actor, weaponentity);

	if(this.m_frame == 30 || this.m_frame == 50 || this.m_frame >= 70)
	{
		this.m_frame = 10;
		w_ready(this);
		return;
	}
	this.m_frame += 1;

	wep_set_anim(this, this.m_frame, wep_wrench_anim_fire);
	this.weapon_nextthink = time + 0.05;
}

void wep_wrench_anim(entity this)
{
	entity actor = this.owner;
	//.entity weaponentity = this.weaponentity_fld;
	// TODO: berserk?

	_sound(actor, CH_WEAPON_B, "impact/wrench_swing.wav", 1, ATTN_NORM);

	float r = random();
	if(r < 0.33)
		this.m_frame = 11;
	else if(r < 0.66)
		this.m_frame = 31;
	else
		this.m_frame = 51;

	if(IS_PLAYER(actor))
		player_wrench1(actor);

	wep_set_anim(this, this.m_frame, wep_wrench_anim_fire);
	this.weapon_nextthink = time + 0.05;
}

//=============================================================================================

void sound_wrench_hit_enemy(entity this, float wrenchhit_volume)
{
	int r = floor(random() * 4);
	if(r == 0)
		_sound(this, CH_SHOTS, "impact/wrench_impact1.wav", wrenchhit_volume, ATTN_NORM);
	else if(r == 1)
		_sound(this, CH_SHOTS, "impact/wrench_impact2.wav", wrenchhit_volume, ATTN_NORM);
	else if(r == 2)
		_sound(this, CH_SHOTS, "impact/wrench_impact3.wav", wrenchhit_volume, ATTN_NORM);
	else
		_sound(this, CH_SHOTS, "impact/wrench_impact4.wav", wrenchhit_volume, ATTN_NORM);
}
//=============================================================================================

#if 0
void sound_melee_hit_player(entity this, float meleehit_volume)
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
void sound_bullet_hit_metal(entity this, float pistolhitmetal_volume)
{
	int r = floor(random() * 4);
	if(r == 0)
		_sound(this, CH_SHOTS, "impact/bullet_metal1.wav", pistolhitmetal_volume, ATTN_NORM);
	else if(r == 1)
		_sound(this, CH_SHOTS, "impact/bullet_metal2.wav", pistolhitmetal_volume, ATTN_NORM);
	else if(r == 2)
		_sound(this, CH_SHOTS, "impact/bullet_metal3.wav", pistolhitmetal_volume, ATTN_NORM);
	else
		_sound(this, CH_SHOTS, "impact/bullet_metal4.wav", pistolhitmetal_volume, ATTN_NORM);
}

void sound_wrench_hit_world(entity this, float wrenchclank_volume)
{
	_sound(this, CH_SHOTS, "impact/wrench_clink.wav", wrenchclank_volume, ATTN_NORM);
	//if(random() < 0.5)	sound (this, CHAN_AUTO, "impact/wrench_clank1.wav", wrenchclank_volume, ATTN_NORM);
	//else			sound (this, CHAN_AUTO, "impact/wrench_clank2.wav", wrenchclank_volume, ATTN_NORM);
}

void anim_wrenchfx(entity this)
{
	this.alpha -= 0.1;
	this.frame += 1;

	if(this.frame >= 6)
	{
		delete(this);
		return;
	}

	setthink(this, anim_wrenchfx);
	this.nextthink = time + 0.05;
}

void FX_Wrench(vector org, vector dir, bool is_spark)
{
	entity fx = spawn();
	set_movetype(fx, MOVETYPE_NONE);
	fx.solid = SOLID_NOT;
	fx.classname = "impact";

	fx.angles = vectoangles(dir);

	fx.frame = 0;
	fx.alpha = 1;

	setthink(fx, anim_wrenchfx);
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

void hitwrench(entity this, entity hitent, vector org, vector dir)
{
	if(hitent.takedamage) 
	{		
		hitent.axhitme = 1;

		SpawnBlood(org, dir, 60, hitent);

		FX_Wrench(org, dir, false);

		if(hitent.classname == "monster_zombie") //keep zombies Unbonkable
			T_Damage(hitent, this, this, 59, WEP_WRENCH.m_id);
		else	
			T_Damage(hitent, this, this, 60, WEP_WRENCH.m_id);
		
		//johnfitz -- make clank sound when hitting brushmodels
		if(hitent.solid == SOLID_BSP || hitent.movetype == MOVETYPE_PUSH || hitent.movetype == MOVETYPE_NONE)
			sound_wrench_hit_world(this, 1);
		else if(trace_ent.takedamage)
		{	
			if(trace_ent.monsterdef.spawnflags & MON_FLAG_METAL)
			{
				FX_Wrench(org, dir, true);
				sound_bullet_hit_metal(trace_ent, 1);
			}
			
			sound_wrench_hit_enemy(trace_ent, 1);
					
			if((hitent.move_movetype == MOVETYPE_STEP || hitent.move_movetype == MOVETYPE_WALK) && 
				// don't swat bosses or other non-standard-sized enemies around
				hitent.maxs_x <= 32 && hitent.health > 0 && !(hitent.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
			{
				vector toss = v_forward;
				toss.z = 0;
				toss = normalize(toss) * 200;
				toss.z = 150;
				hitent.origin_z += 1;
				hitent.velocity = toss;
				UNSET_ONGROUND(hitent);
			}	
		}
		//johnfitz

		if(IS_MONSTER(trace_ent))
		{
			//if(trace_ent.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
				//zombie_knockdown(trace_ent);
			
			sound_wrench_hit_enemy(trace_ent, 1);
		}
		else
		{
			_sound(this, CH_WEAPON_SINGLE, "zombie/z_hit.wav", 1, ATTN_IDLE);
			sound_wrench_hit_enemy(trace_ent, 1);
		}
				
		// do knockback with a quad
		if(StatusEffects_active(STATUSEFFECT_Quad, this))
		{
			if((trace_ent.move_movetype == MOVETYPE_STEP || trace_ent.move_movetype == MOVETYPE_WALK) && 
				// don't swat bosses or other non-standard-sized enemies around
				trace_ent.maxs_x <= 32 && trace_ent.health > 0 && !(trace_ent.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
			{
				vector toss = v_forward;
				toss_z = 0;
				toss = normalize(toss) * 800;
				toss_z = 150;
				trace_ent.origin_z += 1;
				trace_ent.velocity = toss;
				UNSET_ONGROUND(trace_ent);
			}
		}
	}
	else
	{	// hit wall
		_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 0.2, ATTN_NORM);
		sound_wrench_hit_world(this, 0.8);
		
		FX_Wrench(org, dir, true);

		te_gunshot(org);
	}
}

void W_FireWrench(entity this, .entity weaponentity)
{
	entity hitent1 = NULL, hitent2 = NULL;
	vector hitpos1 = '0 0 0', hitpos2 = '0 0 0';
	float shortest_hit1 = 1000;
	float shortest_hit2 = 1000;
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	float rscale = 1;
	if(this.m_champion && this.m_champion.qcc_meleerange)
		rscale *= this.m_champion.qcc_meleerange;

	makevectors(this.v_angle);
	vector source = this.origin + this.view_ofs - v_up*0;

	traceline(source, source + v_forward * (60 * rscale) - v_right * (40 * rscale), false, this);
	if(trace_fraction < 1)
	{
		shortest_hit1 = vlen(trace_endpos - source);
		hitent1 = trace_ent;
		hitpos1 = trace_endpos;
 	}

	traceline(source, source + v_forward * (72 * rscale) - v_right * (20 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * (86 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * (72 * rscale) + v_right * (20 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * (60 * rscale) + v_right * (40 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	this.dphitcontentsmask = oldsolid;

	if(shortest_hit1 == 1000 && shortest_hit2 == 1000)
		return;

	this.show_hostile = time + 1; // hit something, so alert monsters
	
	vector dir = v_right * 20 - v_up*5; // direction for blood particles

	if(shortest_hit1 < 1000)
		hitwrench(this, hitent1, hitpos1 - v_forward*4, dir);
	if(shortest_hit2 < 1000 && hitent1 != hitent2)
		hitwrench(this, hitent2, hitpos2 - v_forward*4, dir);
}

METHOD(Wrench, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		wep_wrench_anim(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8);
	}
}
METHOD(Wrench, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Wrench, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Wrench, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
