#include "spellbook.qh"

#ifdef SVQC
entity tracetossent;

vector rune_getspot(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector src = W_Shotorg(this, weaponentity);
	vector rmin = '-48 -48 0', rmax = '48 48 4';

	if (!tracetossent)
		tracetossent = new(tracetossent);
	tracetossent.owner = this;
	tracetossent.dphitcontentsmask = DPCONTENTS_SOLID;
	setsize(tracetossent, rmin, rmax);
	setorigin(tracetossent, src);

	tracetossent.velocity = v_forward * 600;
	tracetoss(tracetossent, this);

	if(trace_startsolid || vdist(trace_endpos - src, <, 32))
		return '0 0 0'; // error case

	return trace_endpos;
}
#endif

#ifdef SVQC
PRECACHE(Spellbook)
{
	precache_model("progs/g_book.mdl");
	precache_model("progs/v_book.mdl");

	// sword
	precache_model("progs/spell_sword.mdl");
	precache_model("progs/spell_shield.mdl");
	precache_sound("weapons/sword_swing.wav");

	// frost
	precache_model("progs/ice_expl1.spr");
	precache_sound("weapons/ice_shatter.wav");

	// ice cannon
	precache_model("progs/ice_shard.mdl");
	precache_model("progs/ice_fragment1.mdl");
	precache_model("progs/ice_fragment2.mdl");
	precache_model("progs/ice_fragment3.mdl");
	precache_sound("weapons/ice_cannon_shot.wav");

	// voreling
	precache_model("progs/voreling_rune.spr");
	precache_sound("weapons/summon_vorelings.wav");

	// rune
	precache_model("progs/bone_rune.spr");
	precache_sound("weapons/skel_rune.wav");
	precache_sound("weapons/punch_ice2.wav");

	// curse
	precache_model("progs/skull_pike_1.mdl");
	precache_model("progs/skull_pike_2.mdl");
	precache_model("progs/fire_rune.spr");
	precache_model("progs/quake_flame2.mdl");
	precache_model("progs/skull.mdl");
	precache_sound("weapons/skull_attack.wav");

	// explosion
	precache_sound("weapons/launch_fireball.wav");

	// cyclone
	precache_sound("ambience/windfly.wav");

	precache_model("progs/bone_shard.mdl");
	precache_sound("weapons/rune_cast.wav");
	precache_sound("weapons/page_flip.wav");
}

entity rune_summon(entity this, vector spot, Model rune_model, entity eff, int spell_type)
{
	makevectors(this.v_angle);
	vector src = spot;

	entity rune = new(rune);
	rune.owner = rune.realowner = this;
	rune.solid = SOLID_NOT;
	rune.currentspell = spell_type;
	setmodel(rune, rune_model);
	setsize(rune, '-48 -48 0', '48 48 4');
	rune.pos1 = v_forward;
	rune.pos2 = v_up;
	rune.angles = '90 90 0';
	set_movetype(rune, MOVETYPE_TOSS);
	tracebox(src + '0 0 1', '-48 -48 0', '48 48 4', src - '0 0 2048', MOVE_NOMONSTERS, this);
	setorigin(rune, trace_endpos + '0 0 4'); // offset slightly so it always shows

	sound(this, CH_WEAPON_SINGLE, SND_RUNE_CAST, 1, ATTN_NORM);
	if(eff != EFFECT_Null)
		Send_Effect(eff, rune.origin, '0 0 0', 1);

	IL_PUSH(g_runes, rune);

	return rune;
}

bool rune_checklimit(entity this, int spell_type)
{
	// NOTE: requires the rune to still exist for the entirety of the effect
	// TODO: spell-specific check; vorelings should have a limit too!!
	int runecount = 0;
	IL_EACH(g_runes, it.realowner == this && it.currentspell == spell_type,
	{
		runecount += 1;
	});
	// TODO: spell-specific limits? only 1 heal at a time etc!
	return (runecount < SPELL_RUNE_LIMIT);
}

const int anim_sword_stand = 0; //'0 0 0'
const int anim_sword_runb = 1; //'1 8 0'
const int anim_sword_attackb = 9; //'9 18 0'
const int anim_sword_death = 19; //'19 28 0'
const int anim_sword_deathb = 29; //'29 40 0'

void killsword(entity this)
{
	DropToFloor_QC_DelayedInit(this);
	setthink(this, SUB_Remove);
	this.nextthink = time + 3;
}

void sworddieb11(entity this) { set_animofs(this, anim_sword_deathb, 11, killsword); }
void sworddieb10(entity this)
{
	set_animofs(this, anim_sword_deathb, 10, sworddieb11);
	_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
}
void sworddieb9(entity this) { set_animofs(this, anim_sword_deathb, 9, sworddieb10); }
void sworddieb8(entity this) { set_animofs(this, anim_sword_deathb, 8, sworddieb9); }
void sworddieb7(entity this)
{
	set_animofs(this, anim_sword_deathb, 7, sworddieb8);
	//_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
}
void sworddieb6(entity this) { set_animofs(this, anim_sword_deathb, 6, sworddieb7); }
void sworddieb5(entity this) { set_animofs(this, anim_sword_deathb, 5, sworddieb6); }
void sworddieb4(entity this) { set_animofs(this, anim_sword_deathb, 4, sworddieb5); }
void sworddieb3(entity this) { set_animofs(this, anim_sword_deathb, 3, sworddieb4); }
void sworddieb2(entity this) { set_animofs(this, anim_sword_deathb, 2, sworddieb3); }
void sworddieb1(entity this) { set_animofs(this, anim_sword_deathb, 1, sworddieb2); }

void sworddie10(entity this) { set_animofs(this, anim_sword_death, 10, killsword); }
void sworddie9(entity this)
{
	set_animofs(this, anim_sword_death, 9, sworddie10);
	_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 0.5, ATTN_NORM);
}
void sworddie8(entity this) { set_animofs(this, anim_sword_death, 8, sworddie9); }
void sworddie7(entity this)
{
	set_animofs(this, anim_sword_death, 7, sworddie8);
	//_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
}
void sworddie6(entity this) { set_animofs(this, anim_sword_death, 6, sworddie7); }
void sworddie5(entity this) { set_animofs(this, anim_sword_death, 5, sworddie6); }
void sworddie4(entity this) { set_animofs(this, anim_sword_death, 4, sworddie5); }
void sworddie3(entity this) { set_animofs(this, anim_sword_death, 3, sworddie4); }
void sworddie2(entity this) { set_animofs(this, anim_sword_death, 2, sworddie3); }
void sworddie1(entity this) { set_animofs(this, anim_sword_death, 1, sworddie2); }

void choosesworddeath(entity this)
{
	if(random() < 0.5)
		sworddieb1(this);
	else
		sworddie1(this);
	set_movetype(this, MOVETYPE_TOSS);
}

void animatesword10(entity this) { set_animofs(this, anim_sword_attackb, 10, choosesworddeath); ai_face(this); }
void animatesword9(entity this) { set_animofs(this, anim_sword_attackb, 9, animatesword10); ai_face(this); }
void animatesword8(entity this) { set_animofs(this, anim_sword_attackb, 8, animatesword9); ai_face(this); }
void animatesword7(entity this) { set_animofs(this, anim_sword_attackb, 7, animatesword8); ai_face(this); }
void animatesword6(entity this) { set_animofs(this, anim_sword_attackb, 6, animatesword7); ai_face(this); }
void animatesword5(entity this) { set_animofs(this, anim_sword_attackb, 5, animatesword6); ai_face(this); }
void animatesword4(entity this) { set_animofs(this, anim_sword_attackb, 4, animatesword5); ai_face(this); }
void animatesword3(entity this)
{
	set_animofs(this, anim_sword_attackb, 3, animatesword4);
	ai_face(this);
	_sound(this, CH_WEAPON_SINGLE, "weapons/sword_swing.wav", 1, ATTN_NORM);
}
void animatesword2(entity this) { set_animofs(this, anim_sword_attackb, 2, animatesword3); ai_face(this); }
void animatesword1(entity this)
{
	set_animofs(this, anim_sword_attackb, 1, animatesword2);
	ai_face(this);
	//_sound(this, CH_WEAPON_SINGLE, "weapons/sword_swing.wav", 1, ATTN_NORM);
}

.float swing_prev;
.entity swing_alreadyhit;
void sword_melee_think(entity this)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime;
	entity target_victim;
	vector targpos;

	makevectors(this.realowner.angles); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = 0.15;
	swing = bound(0, (this.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * 10);

	// if okay, perform the traces needed for this frame
	for(i=this.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / 10)) * 2 - 1);

		targpos = (this.realowner.origin + this.realowner.view_ofs
			+ (v_forward * 160)
			+ (v_up * swing_factor * 50)
			+ (v_right * swing_factor * 160));

		traceline(this.realowner.origin + this.realowner.view_ofs, targpos, false, this.realowner);

		// draw lightning beams for debugging
	#if 0
		te_lightning2(NULL, targpos, this.realowner.origin + this.realowner.view_ofs + v_forward * 5 - v_up * 5);
		te_customflash(targpos, 40,  2, '1 1 1');
	#endif

		if((trace_fraction < 1) // if trace is good, apply the damage and remove this
			&& (trace_ent.takedamage != DAMAGE_NO)
			&& (trace_ent != this.swing_alreadyhit))
		{
			target_victim = trace_ent; // so it persists through other calls

			swing_damage = (5 * min(1, swing_factor + 1));

			T_Damage(target_victim, this.owner, this.realowner, 40, WEP_SPELLBOOK.m_id);
			target_victim.axhitme = true;

			// draw large red flash for debugging
		#if 0
			te_customflash(targpos, 200, 2, '15 0 0');
		#endif

			this.swing_alreadyhit = target_victim;
			continue; // move along to next trace
		}
	}

	if(time >= this.cnt + meleetime)
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

void sword_melee_start(entity actor, entity sword, .entity weaponentity)
{
	entity meleetemp = new_pure(meleetemp);
	meleetemp.owner = sword;
	meleetemp.realowner = actor;
	meleetemp.weaponentity_fld = weaponentity;
	setthink(meleetemp, sword_melee_think);
	meleetemp.nextthink = time + 0.5;
}

void shield_remove(entity this)
{
	if(this.realowner.spell_shield == this)
		this.realowner.spell_shield = NULL;
	delete(this);
}

void summon_sword(entity this, vector spot, .entity weaponentity)
{
	entity sword = spawn();
	sword.classname = "sword";
	_setmodel(sword, "progs/spell_sword.mdl");
	setsize(sword, '0 0 0', '0 0 0');
	setorigin(sword, spot);
	sword.solid = SOLID_NOT;
	//set_movetype(sword, MOVETYPE_FLY);
	sword.angles = this.angles;
	SetMovetypeFollow(sword, this);
	//DropToFloor_QC_DelayedInit(sword);
	setthink(sword, animatesword1);
	sword.nextthink = time + 0.1;
	sword.effects = EF_LOWPRECISION | EF_ADDITIVE | EF_NOSHADOW;
	sword.owner = this;
	sword.realowner = this;
	sword.glowmod = '1 1 0';
	sword.colormod = '1 1 0';
	//sword.view_ofs = '0 0 16';
	sword.alpha = 0.5;

	sword_melee_start(this, sword, weaponentity);
}

void summon_shield(entity this, vector spot)
{
	entity shield = spawn();
	shield.classname = "shield";
	_setmodel(shield, "progs/spell_shield.mdl");
	setsize(shield, '0 0 0', '0 0 0');
	setorigin(shield, spot);
	shield.solid = SOLID_CORPSE;
	//set_movetype(shield, MOVETYPE_FLY);
	shield.angles = this.angles;
	SetMovetypeFollow(shield, this);
	setthink(shield, shield_remove);
	shield.nextthink = time + 20;
	shield.effects = EF_ADDITIVE | EF_NOSHADOW;
	shield.owner = this;
	shield.realowner = this;
	shield.glowmod = '1 1 0';
	shield.colormod = '1 1 0';
	//shield.view_ofs = '0 0 16';
	shield.alpha = 0.33;

	this.spell_shield = shield;
}

void W_Spell_Sword(entity this, .entity weaponentity)
{
	if(STAT(MANA, this) < SPELL_COST_SWORD)
		return;
	W_TakeMana(this, SPELL_COST_SWORD);
	vector forward, right, up;
	MAKE_VECTORS(this.angles, forward, right, up);
	vector targ = this.origin + forward * 24;
	__pointparticles(_particleeffectnum("spawn_point_yellow"), targ, '0 0 0', 1);
	ATTACK_FINISHED(this, weaponentity) = time + 0.66;
	summon_sword(this, targ, weaponentity);
	//if(this.spell_shield)
		//this.spell_shield.nextthink = time + 20; // refresh shield every sword attack!

	if(this.spell_shield || STAT(MANA, this) < SPELL_COST_SHIELD)
		return;
	W_TakeMana(this, SPELL_COST_SHIELD);
	targ = this.origin + forward * 16 + right * -48;
	summon_shield(this, targ);
}

/*
================
SpawnChunk
================
*/
void SpawnChunk(vector org, vector vel, float col, float num_parts)
{
	particle(org, vel*0.02, col, num_parts);
}

void draw_ice_frost(entity this)
{
	if(this.velocity == '0 0 0')
	{
		setthink(this, SUB_Remove);
		this.nextthink = this.cnt;
		return;
	}
	
	if(this.cnt < time)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}
	
	SpawnChunk(this.origin, v_up * -400, 10, 8);
	setthink(this, draw_ice_frost);
	this.nextthink = time + 0.05;
}

void ThrowIce(entity this)
{
	int quant = 3;

	while(quant > 0)
	{
		float r = random();		
		entity newmis = spawn();
		newmis.classname = "iceshardsplatter";
		newmis.owner = this;
		newmis.solid = SOLID_NOT;
		if(r > 0.6)
			_setmodel(newmis, "progs/ice_fragment1.mdl");
		else if(r < 0.3)
			_setmodel(newmis, "progs/ice_fragment2.mdl");
		else
			_setmodel(newmis, "progs/ice_fragment3.mdl");

		setsize(newmis, '0 0 0', '0 0 0'); 
		newmis.cnt = time + 4 + (random() * 2);
		setthink(newmis, draw_ice_frost);
		newmis.nextthink = time + 0.05;
		setorigin(newmis, this.origin);
		set_movetype(newmis, MOVETYPE_BOUNCE);
		newmis.angles_x = (random()*360);
		newmis.angles_y = (random()*360);
		newmis.angles_z = (random()*360);				
		newmis.velocity_x = 150 - (random()*300);
		newmis.velocity_y = 150 - (random()*300);
		newmis.velocity_z = 250 - (random()*500);
		newmis.avelocity_x = (random()*40);
		newmis.avelocity_y = (random()*40);
		newmis.avelocity_z = (random()*40);		
		quant -= 1;
	}
}

.float cyclone_timer;
void cyclone_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) && !IS_MONSTER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	if(toucher.monsterdef && ((toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || (toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY) || (toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY)))
		return;
	if(time < toucher.cyclone_timer)
		return;

	toucher.cyclone_timer = time + ((IS_MONSTER(toucher)) ? 1.5 : 0.75);

	if(IS_MONSTER(toucher) && toucher.takedamage)
	{
		T_Damage(toucher, this, this.realowner, 50, this.projectiledeathtype);
		ThrowIce(toucher);
	}
	if(toucher.fly_sound < time)
	{
		toucher.fly_sound = time + 1.5;
		_sound(toucher, CH_TRIGGER, "ambience/windfly.wav", 1, ATTN_NORM);
	}

	UNSET_ONGROUND(toucher);
	if(IS_MONSTER(toucher))
	{
		float pushforce = 100 / vlen(toucher.maxs - toucher.mins);
		toucher.velocity_z += (560 * pushforce);
	}
	else
		toucher.velocity_z += 560;
}

void cyclone_think(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		delete(this.owner);
		return;
	}
	setthink(this, cyclone_think);
	this.nextthink = time + 0.1;

	Send_Effect(EFFECT_RUNE_CYCLONE, this.origin, '0 0 560', 5);
}

void summon_cyclone(entity rune)
{
	entity ent = spawn();
	ent.owner = rune;
	setorigin(ent, rune.origin);
	ent.realowner = rune.realowner; // not setting owner, we want interaction!
	ent.classname = "cyclone";
	ent.solid = SOLID_TRIGGER;
	setsize(ent, '-40 -40 0', '40 40 48');
	settouch(ent, cyclone_touch);
	ent.cnt = time + 6;
	setthink(ent, cyclone_think);
	ent.nextthink = time;
	ent.projectiledeathtype = WEP_SPELLBOOK.m_id;
}

void W_Spell_Frost(entity this, vector spot)
{
	entity rune = rune_summon(this, spot, MDL_RUNE_BONE, EFFECT_RUNE_PUFF_BLUE, SPELL_FROST);
	setthink(rune, summon_cyclone);
	rune.nextthink = time + 1.5;
	rune.colormod = '0 0.5 1';
}

void W_Spell_IceCannon(entity this, .entity weaponentity)
{
	if(STAT(MANA, this) < SPELL_COST_ICECANNON)
		return;

	if(this.fly_sound < time)
	{
		this.fly_sound = time + 1.5;
		_sound(this, CH_WEAPON_SINGLE, "ambience/windfly.wav", 1, ATTN_NORM);
	}

	W_TakeMana(this, SPELL_COST_ICECANNON);
	ATTACK_FINISHED(this, weaponentity) = time + 0.1;

	makevectors(this.v_angle);

	float therange = 300;
	vector org = CENTER_OR_VIEWOFS(this) - '0 0 8';
	vector end = org + v_forward * therange;

	te_particlecube(org - '8 8 8', org + '8 8 8', v_forward * 128, 20, 7, 0, 0.66);

	tracebox(org, '-8 -8 -8', '8 8 8', end, MOVE_NORMAL, this);

	entity targ = trace_ent;

	if(!targ || !targ.takedamage || targ.health <= 0)
		return;
	if(!Damage_ValidTarget(targ, this))
		return;

	T_Damage(targ, this, this, 5, WEP_SPELLBOOK.m_id);
	StatusEffects_apply(STATUSEFFECT_Slowness, targ, time + 3, 0);
	if(!(targ.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(targ.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(targ.maxs - targ.mins);

		targ.velocity = v_forward * (256 * pushforce);
		//targ.velocity_z = (64 * pushforce);
		UNSET_ONGROUND(targ);
	}
}

void summon_vorelings(entity this)
{
	__pointparticles(_particleeffectnum("spawn_event_red"), this.origin, '0 0 0', 1);
	_sound(this, CHAN_AUTO, "weapons/summon_vorelings.wav", 1, ATTN_STATIC);
	vector dir = this.pos1;
	dir.z = 0;
	dir = normalize(dir);

	Monster chosen = MON_VORELING;
	if(this.realowner.spellbook_altfire || random() <= 0.2)
		chosen = MON_GOATLING;

	vector org = this.origin + (this.mins + this.maxs) * 0.5;
	traceline(org, org + '0 0 32', MOVE_NOMONSTERS, this);
	org = trace_endpos; // slight offset to avoid clipping

	for(int j = 0; j < 4; ++j)
	{
		vector offset = '0 0 0';
		switch(j)
		{
			default:
			case 0: offset = '64 0 0'; break;
			case 1: offset = '-64 0 0'; break;
			case 2: offset = '0 64 0'; break;
			case 3: offset = '0 -64 0'; break;
		}

		int oldsolid = this.dphitcontentsmask;
		this.dphitcontentsmask = DPCONTENTS_SOLID;
		tracebox(org, chosen.m_mins, chosen.m_maxs, org + offset, MOVE_NOMONSTERS, this);
		this.dphitcontentsmask = oldsolid;

		entity mon = horn_spawnmonster(trace_endpos, this.realowner, chosen);
		if(!mon)
			continue; // dunno how but just incase!
		mon.angles_y += random() * 359;
		mon.health = 100; // slight buffer since their health ticks down fast
		mon.max_health = mon.health;
		SpawnChunk(mon.origin, this.pos2 * 400, 0, 10);
	}

	// hack to keep the rune around for the duration of the vorelings to keep them from being spammed
	this.effects = EF_NODRAW;
	setthink(this, SUB_Remove);
	this.nextthink = time + 20;
}

entity horn_spawnmonster(vector spawnpos, entity actor, Monster mon);
void W_Spell_Voreling(entity this, vector spot)
{
	entity rune = rune_summon(this, spot, MDL_RUNE_VORELING, EFFECT_RUNE_PUFF_RED, SPELL_VORELING);
	setthink(rune, summon_vorelings);
	rune.nextthink = time + 2;
}

.entity arms_spawned;
.bool attack_held;
void remove_arms(entity this)
{
	IL_EACH(g_arms, it.realowner == this.realowner && it.classname == "arms",
	{
		delete(it);
	});

	this.realowner.arms_spawned = NULL;
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;

	Send_Effect(EFFECT_RUNE_PUFF_RED, this.origin, '0 0 0', 1);
}

bool boner_visible(entity this)
{
	entity player = this.realowner;
	traceline(player.origin + player.view_ofs, this.origin, MOVE_NOMONSTERS, player);

	return (trace_fraction == 1);
}

void arms_angles(entity this)
{
	entity pl = this.realowner;
	if(boner_visible(this))
	{
		makevectors(pl.v_angle);
		vector dir = qc_aim(pl, 1000);
		traceline(pl.origin + pl.view_ofs, pl.origin + pl.view_ofs + dir * 1000, MOVE_NORMAL, pl);
		dir = normalize(trace_endpos - this.origin);
		this.angles = vectoangles(dir);
	}
	else
		this.angles = pl.v_angle;
	// taken from item code
	float bobheight = 7 + 5 * sin((time - this.spawn_time) * 2);
	vector oldorg = this.arms_spawned.origin + this.pos1;
	if(bobheight != this.origin_z - oldorg.z)
		this.origin_z = oldorg.z + bobheight;

	setthink(this, arms_angles);
	if(time > this.cnt)
		setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

void fire_bone_shard(entity this)
{
	IL_EACH(g_arms, it.realowner == this && it.classname == "arms",
	{
		_sound(this, CH_WEAPON_SINGLE, "weapons/punch_ice2.wav", 1, ATTN_NORM);
		makevectors(this.v_angle);
		vector dir = qc_aim(this, 1000);
		if(boner_visible(it))
		{
			traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + dir * 1000, MOVE_NORMAL, this);
			dir = normalize(trace_endpos - it.origin);
		}
		it.velocity = dir * 1000;
		it.angles = vectoangles(dir);
		it.classname = "flying_arm";
		it.owner = this; // for super spikes
		settouch(it, superspike_touch);
		it.nextthink = time + 5;
		setthink(it, SUB_Remove);
		break; // one at a time!
	});
}

void summon_boneshard(entity rune)
{
	entity player = rune.realowner;

	entity arms = spawn();
	arms.classname = "arms";
	arms.realowner = player;
	arms.owner = player;
	arms.arms_spawned = rune; // keep track separately for position updates
	arms.solid = SOLID_CORPSE;
	arms.projectiledeathtype = WEP_SPELLBOOK.m_id;
	arms.cnt = rune.cnt + 1; // just incase the rune itself doesn't remove them!
	set_movetype(arms, MOVETYPE_FLYMISSILE);
	_setmodel(arms, "progs/bone_shard.mdl");			
	setsize(arms, '0 0 0', '0 0 0'); 
	setorigin(arms, rune.origin);
	setthink(arms, arms_angles);
	arms.nextthink = time + 0.1;
	arms.spawn_time = time + (1 * random()); // slight offset so they don't all move at once!

	vector offset;
	offset.x = 64 - (random() * 128);
	offset.y = 64 - (random() * 128);
	offset.z = 16 + (random() * 16);
	arms.pos1 = offset;
	arms.origin = rune.origin + offset;
	arms.angles = player.angles;
	IL_PUSH(g_arms, arms);
}

void arms_think(entity this)
{
	if(time > this.cnt || vdist(this.owner.origin - this.origin, >, 1000))
	{
		remove_arms(this);
		return;
	}
	this.nextthink = time + 0.15;
	setthink(this, arms_think);
	int armcount = 0;
	IL_EACH(g_arms, it.realowner == this.realowner && it.classname == "arms",
	{
		armcount += 1;
	});
	if(armcount < SPELL_BONESHARD_MAXBONES)
		summon_boneshard(this);
}

void summon_arms(entity this)
{
	__pointparticles(_particleeffectnum("spawn_point_blue"), this.origin, '0 0 0', 1);
	_sound(this, CHAN_AUTO, "weapons/skel_rune.wav", 1, ATTN_STATIC);

	setthink(this, arms_think);
	this.nextthink = time + 0.1;
	this.cnt = time + 20;
}

void summon_skeleton_arms(entity this, vector spot)
{
	entity rune = rune_summon(this, spot, MDL_RUNE_BONE, EFFECT_RUNE_PUFF_BLUE, SPELL_BONESHARD);
	setthink(rune, summon_arms);
	rune.nextthink = time + 1;

	this.arms_spawned = rune;
}

void W_Spell_BoneShard(entity this, .entity weaponentity)
{
	if(!this.arms_spawned)
	{
		if(this.attack_held)
			return;
		if(STAT(MANA, this) < SPELL_COST_BONESHARD)
			return;
		vector spot = rune_getspot(this, weaponentity);
		if(spot == '0 0 0')
		{
			// TODO: alert the caster?
			ATTACK_FINISHED(this, weaponentity) = time + 0.2; // slight delay to avoid server spam
			return;
		}
		W_TakeMana(this, SPELL_COST_BONESHARD);
		summon_skeleton_arms(this, spot);
		ATTACK_FINISHED(this, weaponentity) = time + 1.2; // rune spawning delay
	}
	else
	{
		entity rune = this.arms_spawned;
		if(vdist(rune.origin - this.origin, >, 1000))
			return; // need to be close to cast it!
		rune.cnt = time + 20; // reset timer on it with each attack!
		ATTACK_FINISHED(this, weaponentity) = time + 0.05;
		this.attack_held = true;
		fire_bone_shard(this);
	}
}

/*
================
Homing Skull, adapted from ShalMissile
================
*/
void SkullMissileTouch(entity this, entity toucher);
void SkullMissHome(entity this);
void seek_and_fire1(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		return;
	}

	this.enemy = NULL;
	entity head = findradius(this.origin, 800);
	float olddist = 0;
	entity targ = NULL;
	while(head)
	{
		if(head != this && Damage_ValidTarget(head, this.realowner))
		{
			float newdist = vlen2(head.origin - this.origin);
			if((!olddist || newdist <= olddist) && visible(this, head))
			{
				targ = head;			
				this.angles_y = vectoyaw(targ.origin - this.origin);
				olddist = newdist;
			}
		}
		head = head.chain;
	}
	this.enemy = targ;

	setthink(this, seek_and_fire1);
	this.nextthink = time + 2;
	if(!this.enemy)
		return;

	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
	float flytime = 0.1;

	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "weapons/skull_attack.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.owner = this;
	missile.realowner = this.realowner;

	missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	_setmodel(missile, "progs/skull.mdl");
	setsize(missile, '0 0 0', '0 0 0');

	missile.cnt = time + 5;
	missile.origin = this.origin + '0 0 52';
	missile.enemy = this.enemy;
	missile.angles_y = vectoyaw(this.enemy.origin - missile.origin);
	missile.velocity = dir * 600;
	missile.nextthink = flytime + time;
	setthink(missile, SkullMissHome);
	settouch(missile, SkullMissileTouch);
}

void seek_and_fire2(entity this)
{
	if(time > this.cnt)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}

	this.enemy = NULL;
	entity head = findradius(this.origin, 800);			
	while(head)
	{
		if(head != this && Damage_ValidTarget(head, this.realowner))
		{
			if(visible(this, head))
				this.enemy = head;		
		}
		head = head.chain;
	}

	setthink(this, seek_and_fire2);
	this.nextthink = time + 2;

	if(!this.enemy)
		return;

	this.angles_y = vectoyaw(this.enemy.origin - this.origin);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/punch_ice2.wav", 1, ATTN_NORM);

	entity bone_miss = spawn();
	bone_miss.owner = this.realowner;
	bone_miss.realowner = this.realowner;
	set_movetype(bone_miss, MOVETYPE_FLYMISSILE);
	bone_miss.solid = SOLID_BBOX;
	bone_miss.classname = "bone_shard";

// set missile speed	
	vector shard_ang = normalize(this.enemy.origin - this.origin);
	
	bone_miss.velocity = shard_ang * 1000;	
	bone_miss.angles = vectoangles(bone_miss.velocity);

	settouch(bone_miss, superspike_touch);

// set missile duration
	bone_miss.nextthink = time + 5;
	setthink(bone_miss, SUB_Remove);

	_setmodel(bone_miss, "progs/bone_shard.mdl");
	setsize(bone_miss, '0 0 0', '0 0 0');	
	setorigin(bone_miss, this.origin + '0 0 48');
}

void SkullMissHome(entity this)
{
	vector vtemp = this.enemy.origin + '0 0 10';
	
	if(this.enemy.health < 1 || time > this.cnt || vdist(this.enemy.origin - this.origin, <, 10)) // safety net, they can get stuck inside enemies!
	{
		delete(this);
		return;
	}
	
//	ai_face();
	
	vector dir = normalize(vtemp - this.origin);
	this.angles_y = vectoyaw(this.enemy.origin - this.origin);	
//	this.angles = dir;
	this.velocity = dir * 450;
	this.nextthink = time + 0.05;
	setthink(this, SkullMissHome);	
}

void SkullMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher == this.realowner)
		return;		// don't explode on owner

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this.realowner, 110, WEP_SPELLBOOK.m_id);
	T_RadiusDamage(this, this.realowner, 40, WEP_SPELLBOOK.m_id, NULL);
	_sound(this, CH_WEAPON_SINGLE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	te_explosion(this.origin);

	// enable for fast attacks
#if 0
	if(this.owner && this.owner.classname == "skull_post" && this.owner.nextthink > (time + 0.5))
	{
		setthink(this.owner, seek_and_fire1);
		this.owner.nextthink = time + 0.5;
	}
#endif

	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/s_explod.spr");
	this.solid = SOLID_NOT;
	setsize(this, '0 0 0', '0 0 0');
	s_explode1(this);
}

void flame_touch(entity this, entity toucher)
{
	if(!toucher || !toucher.takedamage || toucher == this.realowner)
		return;
	if(this.classname != "groundfire")
		return;
	if(time < toucher.pain_finished)
		return;

	T_Damage(toucher, this, this.realowner, 7, WEP_SPELLBOOK.m_id);
	toucher.pain_finished = time + 0.333;
}

void fire_particles(entity this)
{
	if(this.cnt < time)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time + 0.1;
		return;
	}
	SpawnChunk(this.origin + '0 0 8', v_up * 100, 72, 3);
	SpawnChunk(this.origin + '0 0 8', v_up * 100, 235, 3);
	setthink(this, fire_particles);
	this.nextthink = time + 0.2;
}

void summon_curse(entity this)
{
	__pointparticles(_particleeffectnum("spawn_event_red"), this.origin, '0 0 0', 1);

	int quant = 8;
	while(quant > 0)
	{
		entity flame = spawn();
		flame.classname = "groundfire";
		flame.owner = this;
		flame.realowner = this.realowner;
		flame.projectiledeathtype = WEP_SPELLBOOK.m_id;
		flame.solid = SOLID_TRIGGER;
		_setmodel(flame, "progs/quake_flame2.mdl");
		flame.frame = 0;
		setsize(flame, '0 0 -16', '0 0 0'); 
		flame.cnt = time + 17 + (random() * 2); 
		settouch(flame, flame_touch);
		setthink(flame, fire_particles);
		flame.nextthink = time + 0.05;
		setorigin(flame, this.origin);
		flame.origin_x = flame.origin_x + 64 - (random()*128);
		flame.origin_y = flame.origin_y + 64 - (random()*128);
		flame.origin_z = flame.origin_z + 8 + (random() * 8);
		setorigin(flame, flame.origin);
		set_movetype(flame, MOVETYPE_TOSS);
		quant -= 1;
	}

	entity post = this; // repurpose rune so that we can count it towards the limit
	set_movetype(post, MOVETYPE_TOSS);
	post.realowner = this.realowner;
	post.owner = this.realowner;
	post.classname = "skull_post";
	post.velocity = '0 0 0';
	post.angles = '0 0 0';
	post.avelocity = '0 0 0';
	post.colormod = '0 0 0';
#if 0
	if(random() < 0.5)
	{
#endif
		_setmodel(post, "progs/skull_pike_1.mdl");
		setthink(post, seek_and_fire1);
#if 0
	}
	else
	{
		_setmodel(post, "progs/skull_pike_2.mdl");
		setthink(post, seek_and_fire2);
	}
#endif
	setorigin(post, this.origin);
	post.angles_y = random() * 360;
	post.cnt = time + 20;
	post.solid = SOLID_NOT;
	post.nextthink = time + 0.1;
}

void W_Spell_Curse(entity this, vector spot)
{
	entity rune = rune_summon(this, spot, MDL_RUNE_FIRE, EFFECT_RUNE_PUFF_RED, SPELL_CURSE);
	setthink(rune, summon_curse);
	rune.nextthink = time + 2;
	rune.colormod = '1 0.5 0';
}

void meteor_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = (this.dmg) ? this.dmg : 100;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health > 0 && toucher.takedamage)
		T_Damage(toucher, this, this.realowner, damg, this.projectiledeathtype);

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.realowner, mydmg * 1.2, this.projectiledeathtype, toucher);

//	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	this.origin = this.origin - 8 * normalize(this.velocity);

	//Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	Send_Effect(EFFECT_RUNE_METEOR_IMPACT, this.origin, '0 0 0', 1);

	delete(this);
}

void summon_meteors(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		return;
	}
	this.nextthink = time + 0.1;
	setthink(this, summon_meteors);

	int meteors = floor(random() * 3) + 1; // 1-3 at a time
	for(int j = 0; j < meteors; ++j)
	{
		entity flame = spawn();
		flame.solid = SOLID_BBOX;
		flame.owner = this.realowner;
		flame.realowner = this.realowner;
		flame.projectiledeathtype = WEP_SPELLBOOK.m_id;
		flame.classname = "missile";
		set_movetype(flame, MOVETYPE_FLYMISSILE);
		//setorigin(flame, this.origin);
		//flame.origin_x = flame.origin_x + 96 - (random()*128);
		//flame.origin_y = flame.origin_y + 96 - (random()*128);
		flame.origin = this.origin + randomvec() * 96;
		flame.origin_z = this.origin_z;
		setorigin(flame, flame.origin);
		vector dir = normalize(this.pos1 - this.origin);
		flame.velocity = dir * 500;
		flame.angles = vectoangles(dir);
		setmodel(flame, MDL_LAVABALL);
		setsize(flame, '0 0 0', '0 0 0');
		flame.scale = max(0.25, random());
		flame.dmg = 15 * flame.scale;
		setthink(flame, SUB_Remove);
		flame.nextthink = time + 5;
		settouch(flame, meteor_touch);
		_sound(flame, CH_WEAPON_SINGLE, "weapons/launch_fireball.wav", 0.5, ATTN_NORM);
	}
}

void rune_meteors_risethink(entity this)
{
	if(this.origin_z >= this.pos2_z)
	{
		setorigin(this, this.pos2);
		this.scale = 1.5;
		set_movetype(this, MOVETYPE_NONE);
		summon_meteors(this);
		return;
	}

	setorigin(this, this.origin + '0 0 800' * frametime);

	setthink(this, rune_meteors_risethink);
	this.nextthink = time;
}

void rune_meteors_rise(entity this)
{
	setthink(this, rune_meteors_risethink);
	this.nextthink = time;

	tracebox(this.origin, '-48 -48 0', '48 48 4', this.origin + '0 0 1200', MOVE_NOMONSTERS, this);
	this.pos2 = trace_endpos;
	this.angles = '-90 90 0';
}

void W_Spell_Explosion(entity this, vector spot)
{
	entity rune = rune_summon(this, spot, MDL_RUNE_FIRE, EFFECT_Null, SPELL_EXPLOSION);
	setthink(rune, rune_meteors_rise);
	rune.nextthink = time + 0.33;
	//rune.scale = 1.5;
	rune.cnt = time + 20 + 2; // 2 for the summoning time
	rune.pos1 = rune.origin;
}

void summon_heal(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		return;
	}

	setthink(this, summon_heal);
	this.nextthink = time + 0.1;

	bool didheal = false;

	// TODO: allows boosting health quite high, maybe nerf? going to 100 would make it hard to see any bonus!?
	FOREACH_ENTITY_RADIUS(this.origin, 64, IS_PLAYER(it) && it.health > 0 && it.health < 150 && it.exptime == 0,
	{
		if(deathmatch && it != this.realowner)
			continue;
		if(T_Heal(it, 1, true))
		{
			if(it.health > 150)
				it.health = 150;
			didheal = true;
		}
	});
	if(didheal)
	{
		__pointparticles(_particleeffectnum("healing_fx"), this.origin, '0 0 0', 1);
		//_sound(this, CH_TRIGGER_SINGLE, "items/health1.wav", 1, ATTN_NORM);
	}
	else if(time > this.count)
	{
		// ping effects anyway sometimes to show it's a healing area
		__pointparticles(_particleeffectnum("healing_fx"), this.origin, '0 0 0', 1);
		this.count = time + 0.75;
	}
}

void W_Spell_Serpent(entity this, vector spot)
{
	entity rune = rune_summon(this, spot, MDL_RUNE_BONE, EFFECT_RUNE_PUFF_BLUE, SPELL_SERPENT);
	setthink(rune, summon_heal);
	rune.nextthink = time + 1.5;
	rune.cnt = time + 10 + 1.5; // 2 for the summoning time
	rune.colormod = '1 0.25 0';
}

void W_Spellbook_ClearSpells(entity this)
{
	if(this.spell_shield)
		delete(this.spell_shield);
	this.spell_shield = NULL;

	if(this.arms_spawned)
		remove_arms(this.arms_spawned);
	this.arms_spawned = NULL;
}

void W_FireSpellbook(entity this, .entity weaponentity)
{
	if(STAT(MANA, this) <= 0)
		return; // early out

	vector spot = '0 0 0';
	switch(this.currentspell)
	{
		case SPELL_SWORD:
		{
			W_Spell_Sword(this, weaponentity);
			break;
		}
		case SPELL_FROST:
		{
			if(STAT(MANA, this) < SPELL_COST_FROST)
				return;
			if(!rune_checklimit(this, SPELL_FROST))
				return;
			spot = rune_getspot(this, weaponentity);
			if(spot == '0 0 0')
			{
				// TODO: alert the caster?
				ATTACK_FINISHED(this, weaponentity) = time + 0.2; // slight delay to avoid server spam
				return;
			}
			W_TakeMana(this, SPELL_COST_FROST);
			ATTACK_FINISHED(this, weaponentity) = time + 0.66;
			W_Spell_Frost(this, spot);
			break;
		}	
		case SPELL_ICECANNON:
		{
			W_Spell_IceCannon(this, weaponentity);
			break;
		}	
		case SPELL_VORELING:
		{
			if(STAT(MANA, this) < SPELL_COST_VORELING)
				return;
			if(!rune_checklimit(this, SPELL_VORELING))
				return;
			spot = rune_getspot(this, weaponentity);
			if(spot == '0 0 0')
			{
				// TODO: alert the caster?
				ATTACK_FINISHED(this, weaponentity) = time + 0.2; // slight delay to avoid server spam
				return;
			}
			W_TakeMana(this, SPELL_COST_VORELING);
			ATTACK_FINISHED(this, weaponentity) = time + 0.66;
			W_Spell_Voreling(this, spot);
			break;
		}
		case SPELL_BONESHARD:
		{
			// attack delays handled by the spell itself
			W_Spell_BoneShard(this, weaponentity);
			break;
		}
		case SPELL_CURSE:
		{
			if(STAT(MANA, this) < SPELL_COST_CURSE)
				return;
			if(!rune_checklimit(this, SPELL_CURSE))
				return;
			spot = rune_getspot(this, weaponentity);
			if(spot == '0 0 0')
			{
				// TODO: alert the caster?
				ATTACK_FINISHED(this, weaponentity) = time + 0.2; // slight delay to avoid server spam
				return;
			}
			W_TakeMana(this, SPELL_COST_CURSE);
			ATTACK_FINISHED(this, weaponentity) = time + 0.66;
			W_Spell_Curse(this, spot);
			break;
		}
		case SPELL_EXPLOSION:
		{
			if(STAT(MANA, this) < SPELL_COST_EXPLOSION)
				return;
			if(!rune_checklimit(this, SPELL_EXPLOSION))
				return;
			spot = rune_getspot(this, weaponentity);
			if(spot == '0 0 0')
			{
				// TODO: alert the caster?
				ATTACK_FINISHED(this, weaponentity) = time + 0.2; // slight delay to avoid server spam
				return;
			}
			W_TakeMana(this, SPELL_COST_EXPLOSION);
			ATTACK_FINISHED(this, weaponentity) = time + 0.66;
			W_Spell_Explosion(this, spot);
			break;
		}
		case SPELL_SERPENT:
		{
			if(STAT(MANA, this) < SPELL_COST_SERPENT)
				return;
			if(!rune_checklimit(this, SPELL_SERPENT))
				return;
			spot = rune_getspot(this, weaponentity);
			if(spot == '0 0 0')
			{
				// TODO: alert the caster?
				ATTACK_FINISHED(this, weaponentity) = time + 0.2; // slight delay to avoid server spam
				return;
			}
			W_TakeMana(this, SPELL_COST_SERPENT);
			ATTACK_FINISHED(this, weaponentity) = time + 0.66;
			W_Spell_Serpent(this, spot);
			break;
		}
	}
}

METHOD(Spellbook, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(!(fire & 1))
		actor.attack_held = false;

	// refresh shield while we have spellbook out!
	if(actor.spell_shield)
		actor.spell_shield.nextthink = time + 20;

	if(fire & 2)
	if(!(time < actor.attack2_finished))
	{
		_sound(actor, CH_WEAPON_B, "weapons/page_flip.wav", 1, ATTN_NORM);
		if(PHYS_INPUT_BUTTON_CROUCH(actor))
		{
			actor.(weaponentity).m_frame = 12;
			actor.(weaponentity).swappingspell = -1;
			int nextspell = actor.currentspell - 1;
			if(nextspell < SPELL_FIRST)
				nextspell = SPELL_LAST;
			actor.(weaponentity).skin = nextspell; // update skin first so the animation will show the correct spell!
		}
		else
		{
			actor.(weaponentity).m_frame = 0;
			actor.(weaponentity).swappingspell = 1;
		}
		ATTACK_FINISHED(actor, weaponentity) = max(ATTACK_FINISHED(actor, weaponentity), time + 0.5); // also prevent primary fire during this time
		actor.attack2_finished = time + 0.5; // slight delay between swapping, also prevents fireballs!
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		//player_magic1(actor);
		W_FireSpellbook(actor, weaponentity);
	}
}
METHOD(Spellbook, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Spellbook, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Spellbook, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
