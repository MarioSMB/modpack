#include "king_slime.qh"

#ifdef SVQC
const int anim_kslime_walk = 0;
const int anim_kslime_run = 11;
const int anim_kslime_jump = 19;
const int anim_kslime_fly = 21;
const int anim_kslime_exp = 25;

const int CLIPGROUP_KING_SLIME = 22; // randomly picked!

void kslime_stand1(entity this) { set_animofs(this, anim_kslime_walk, 1, kslime_stand1); ai_stand(this); }

void kslime_hang1(entity this) { set_animofs(this, anim_kslime_walk, 1, kslime_hang1); ai_stand(this); }

void kslime_walk1(entity this);
void kslime_walk11(entity this) { set_animofs(this, anim_kslime_walk, 11, kslime_walk1); ai_walk(this, 4); }
void kslime_walk10(entity this) { set_animofs(this, anim_kslime_walk, 10, kslime_walk11); ai_walk(this, 4); }
void kslime_walk9(entity this) { set_animofs(this, anim_kslime_walk, 9, kslime_walk10); ai_walk(this, 4); }
void kslime_walk8(entity this) { set_animofs(this, anim_kslime_walk, 8, kslime_walk9); ai_walk(this, 4); }
void kslime_walk7(entity this) { set_animofs(this, anim_kslime_walk, 7, kslime_walk8); ai_turn(this); }
void kslime_walk6(entity this) { set_animofs(this, anim_kslime_walk, 6, kslime_walk7); ai_turn(this); }
void kslime_walk5(entity this) { set_animofs(this, anim_kslime_walk, 5, kslime_walk6); ai_turn(this); }
void kslime_walk4(entity this) { set_animofs(this, anim_kslime_walk, 4, kslime_walk5); ai_turn(this); }
void kslime_walk3(entity this) { set_animofs(this, anim_kslime_walk, 3, kslime_walk4); ai_turn(this); }
void kslime_walk2(entity this) { set_animofs(this, anim_kslime_walk, 2, kslime_walk3); ai_turn(this); }
void kslime_walk1(entity this) { set_animofs(this, anim_kslime_walk, 1, kslime_walk2); ai_turn(this); }

void kslime_run1(entity this);
void kslime_run8(entity this) { set_animofs(this, anim_kslime_run, 8, kslime_run1); ai_run(this, 4); }
void kslime_run7(entity this) { set_animofs(this, anim_kslime_run, 7, kslime_run8); ai_run(this, 4); }
void kslime_run6(entity this) { set_animofs(this, anim_kslime_run, 6, kslime_run7); ai_run(this, 4); }
void kslime_run5(entity this) { set_animofs(this, anim_kslime_run, 5, kslime_run6); ai_run(this, 4); }
void kslime_run4(entity this) { set_animofs(this, anim_kslime_run, 4, kslime_run5); ai_face(this); }
void kslime_run3(entity this) { set_animofs(this, anim_kslime_run, 3, kslime_run4); ai_face(this); }
void kslime_run2(entity this) { set_animofs(this, anim_kslime_run, 2, kslime_run3); ai_face(this); }
void kslime_run1(entity this) { set_animofs(this, anim_kslime_run, 1, kslime_run2); ai_face(this); }


//============================================================================


void kslime_jump1(entity this);

void KingSlime_JumpTouch(entity this, entity toucher)
{
	if((this.health <= 0 || !this.takedamage))
		return;
	ai_jumpbreakable(this, toucher, 40);			// Damage any breakables
	if(toucher.takedamage && toucher.classname != this.classname)
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 20 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_KING_SLIME.m_id);
			_sound(this, CH_WEAPON_SINGLE, "king_slime/hit.wav", 1, ATTN_NORM);
			this.attack_finished = time + 0.5;
		}
	}
	else
		_sound(this, CH_WEAPON_SINGLE, "king_slime/land.wav", 1, ATTN_NORM);


	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this))
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, kslime_run1);
			//set_movetype(this, MOVETYPE_STEP);
			this.nextthink = time + 0.1;

		}
		return;	// not on ground yet
	}
}

void kslime_jump5(entity this);

void kslime_fly1(entity this);
void kslime_fly4(entity this)
{
	set_animofs(this, anim_kslime_fly, 4, kslime_fly1);
	if(this.exptime != 0)
		return;
	if(IS_ONGROUND(this))
	{
		settouch(this, func_null);
		setthink(this, kslime_run1);
		//set_movetype(this, MOVETYPE_STEP);
	}
}
void kslime_fly3(entity this) { set_animofs(this, anim_kslime_fly, 3, kslime_fly4); }
void kslime_fly2(entity this) { set_animofs(this, anim_kslime_fly, 2, kslime_fly3); }
void kslime_fly1(entity this) { set_animofs(this, anim_kslime_fly, 1, kslime_fly2); }

void kslime_jump6(entity this) { set_animofs(this, anim_kslime_jump, 2, kslime_fly1); }
void kslime_jump5(entity this)
{
	set_animofs(this, anim_kslime_jump, 2, kslime_jump6);

	//set_movetype(this, MOVETYPE_BOUNCE);
	settouch(this, KingSlime_JumpTouch);
	fixedmakevectors(this.angles);
	this.velocity = v_forward * max(500, random() * 1000) + '0 0 300';
	this.velocity_z += random()*150;
	UNSET_ONGROUND(this);
}
void kslime_jump4(entity this) { set_animofs(this, anim_kslime_jump, 1, kslime_jump5); ai_face(this); }
void kslime_jump3(entity this) { set_animofs(this, anim_kslime_jump, 1, kslime_jump4); ai_face(this); }
void kslime_jump2(entity this) { set_animofs(this, anim_kslime_jump, 1, kslime_jump3); ai_face(this); }
void kslime_jump1(entity this) { set_animofs(this, anim_kslime_jump, 1, kslime_jump2); ai_face(this); }



//=============================================================================

void kslime_die2(entity this)
{
	set_anim(this, anim_kslime_exp, kslime_run1);
	T_RadiusDamage(this, this, 250, DEATH_MONSTER_KING_SLIME.m_id, NULL);

	_sound(this, CH_VOICE, "king_slime/death.wav", 1, ATTN_NORM);
	this.origin = this.origin - 8 * normalize(this.velocity);

	ThrowGib(this, this, "progs/king_slime_crown.mdl", -100);

	Send_Effect(EFFECT_EXPLOSION_MEDIUM, this.origin, '0 0 0', 1);
	
	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	_setmodel(exp, "progs/s_explod.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	delete(this);
}
void kslime_die1(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED: break; // let the thing explode!
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}
	
	set_anim(this, anim_kslime_exp, kslime_die2);
	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_NOT;
}

void kslime_mitosis(entity targ, entity attacker, float damage, int deathtype);
void kslime_checknew(entity this)
{
	if(!t_walkmove(this, 0, 0))
	{
		delete(this);
		return;
	}
	
	this.enemy = this.enemy;
	this.th_stand = kslime_stand1;
	this.th_walk = kslime_walk1;
	this.th_run = kslime_run1;
	this.th_missile = kslime_jump1;
	this.th_melee = kslime_jump1;
	this.th_die = kslime_die1;       
	this.origin_z = this.origin_z + 1;      // raise off floor a bit
	DropToFloor_QC_DelayedInit(this);

	if(!t_walkmove(this, 0,0))
	{
		delete(this);
		return;
	}

	this.takedamage = DAMAGE_AIM;
	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.yaw_speed)
		this.yaw_speed = 20;
	this.view_ofs = '0 0 25';
	this.use = monster_use;
	this.flags |= FL_MONSTER;
	this.pausetime = -1;
	this.th_stand(this);
	this.nextthink = this.nextthink + random()*0.5;

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	monsters_total += 1;
}

void kslime_makebaby(entity this)
{
	makevectors(this.angles);
	vector org = CENTER_OR_VIEWOFS(this) + v_up * 16;
	bool ks_summonflag = find_minionspace(org);

	// If the spawn location all clear, spawn something!
	if(ks_summonflag)
	{
		_sound(this, CH_VOICE, "king_slime/mytosis.wav", 1, ATTN_NORM);

		entity pet = minion_spawn(this, org, new(monster), MON_SPAWN);
		pet.velocity = randomvec() * 400;
		pet.velocity_z = 200;
		pet.skin = ((random() > 0.5) ? 0 : 1);
		pet.health = min(pet.health, 40);
	}
}

void kslime_mitosis(entity targ, entity attacker, float damage, int deathtype)
{
	if(time < targ.pain_finished)
		return;
	targ.pain_finished = time; // prevent spam
	if(query_minionactive(targ) <= 0)
		return;

	if(random() > 0.35)
		return;

	kslime_makebaby(targ);
}

/*QUAKED monster_king_slime (1 0 0) (-16 -16 -24) (16 16 24) Ambush
The King
*/
spawnfunc(monster_king_slime) { monster_start(this, true, MON_KING_SLIME); }
#endif // SVQC

#ifdef SVQC
METHOD(KingSlime, mr_setup, bool(KingSlime this, entity actor))
{
    TC(KingSlime, this);

	precache_model("progs/king_slime_crown.mdl");
	precache_sound("king_slime/death.wav");
	precache_sound("king_slime/hit.wav");
	precache_sound("king_slime/land.wav");
	precache_sound("king_slime/sight.wav");

	if(!actor.clipgroup)
		actor.clipgroup = CLIPGROUP_KING_SLIME;

	if(!actor.minion_maxcount)
		actor.minion_maxcount = 5;

    actor.health = 2000;
    actor.th_stand = kslime_stand1;
	actor.th_walk = kslime_walk1;
	actor.th_run = kslime_run1;
	actor.th_missile = kslime_jump1;
	actor.th_melee = kslime_jump1;
	actor.th_die = kslime_die1;

	precache_sound("king_slime/mytosis.wav");
	actor.th_pain = kslime_mitosis;

    return true;
}
METHOD(KingSlime, mr_sight, bool(KingSlime this, entity actor))
{
	TC(KingSlime, this);

	_sound(actor, CH_VOICE, "king_slime/sight.wav", 1, ATTN_NORM);

	return true;
}
#endif
