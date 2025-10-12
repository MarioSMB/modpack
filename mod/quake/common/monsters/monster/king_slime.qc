#include "king_slime.qh"

#ifdef SVQC
const int anim_kslime_walk = 0;
const int anim_kslime_run = 11;
const int anim_kslime_jump = 19;
const int anim_kslime_fly = 21;
const int anim_kslime_exp = 25;

const int CLIPGROUP_KING_SLIME = 21; // randomly picked!

void kslime_stand1(entity this) { set_animofs(this, anim_kslime_walk, 1, kslime_stand1); ai_stand(this); }

void kslime_hang1(entity this) { set_animofs(this, anim_kslime_walk, 1, kslime_hang1); ai_stand(this); }

void kslime_walk1(entity this);
void kslime_walk25(entity this) { set_animofs(this, anim_kslime_walk, 25, kslime_walk1); ai_walk(this, 2); }
void kslime_walk24(entity this) { set_animofs(this, anim_kslime_walk, 24, kslime_walk25); ai_walk(this, 2); }
void kslime_walk23(entity this) { set_animofs(this, anim_kslime_walk, 23, kslime_walk24); ai_walk(this, 2); }
void kslime_walk22(entity this) { set_animofs(this, anim_kslime_walk, 22, kslime_walk23); ai_walk(this, 2); }
void kslime_walk21(entity this) { set_animofs(this, anim_kslime_walk, 21, kslime_walk22); ai_walk(this, 2); }
void kslime_walk20(entity this) { set_animofs(this, anim_kslime_walk, 20, kslime_walk21); ai_walk(this, 2); }
void kslime_walk19(entity this) { set_animofs(this, anim_kslime_walk, 19, kslime_walk20); ai_walk(this, 2); }
void kslime_walk18(entity this) { set_animofs(this, anim_kslime_walk, 18, kslime_walk19); ai_walk(this, 2); }
void kslime_walk17(entity this) { set_animofs(this, anim_kslime_walk, 17, kslime_walk18); ai_walk(this, 2); }
void kslime_walk16(entity this) { set_animofs(this, anim_kslime_walk, 16, kslime_walk17); ai_walk(this, 2); }
void kslime_walk15(entity this) { set_animofs(this, anim_kslime_walk, 15, kslime_walk16); ai_walk(this, 2); }
void kslime_walk14(entity this) { set_animofs(this, anim_kslime_walk, 14, kslime_walk15); ai_walk(this, 2); }
void kslime_walk13(entity this) { set_animofs(this, anim_kslime_walk, 13, kslime_walk14); ai_walk(this, 2); }
void kslime_walk12(entity this) { set_animofs(this, anim_kslime_walk, 12, kslime_walk13); ai_walk(this, 2); }
void kslime_walk11(entity this) { set_animofs(this, anim_kslime_walk, 11, kslime_walk12); ai_walk(this, 2); }
void kslime_walk10(entity this) { set_animofs(this, anim_kslime_walk, 10, kslime_walk11); ai_turn(this); }
void kslime_walk9(entity this) { set_animofs(this, anim_kslime_walk, 9, kslime_walk10); ai_turn(this); }
void kslime_walk8(entity this) { set_animofs(this, anim_kslime_walk, 8, kslime_walk9); ai_turn(this); }
void kslime_walk7(entity this) { set_animofs(this, anim_kslime_walk, 7, kslime_walk8); ai_turn(this); }
void kslime_walk6(entity this) { set_animofs(this, anim_kslime_walk, 6, kslime_walk7); ai_turn(this); }
void kslime_walk5(entity this) { set_animofs(this, anim_kslime_walk, 5, kslime_walk6); ai_turn(this); }
void kslime_walk4(entity this) { set_animofs(this, anim_kslime_walk, 4, kslime_walk5); ai_turn(this); }
void kslime_walk3(entity this) { set_animofs(this, anim_kslime_walk, 3, kslime_walk4); ai_turn(this); }
void kslime_walk2(entity this) { set_animofs(this, anim_kslime_walk, 2, kslime_walk3); ai_turn(this); }
void kslime_walk1(entity this) { set_animofs(this, anim_kslime_walk, 1, kslime_walk2); ai_turn(this); }

void kslime_run1(entity this);
void kslime_run25(entity this) { set_animofs(this, anim_kslime_run, 25, kslime_run1); ai_run(this, 2); }
void kslime_run24(entity this) { set_animofs(this, anim_kslime_run, 24, kslime_run25); ai_run(this, 2); }
void kslime_run23(entity this) { set_animofs(this, anim_kslime_run, 23, kslime_run24); ai_run(this, 2); }
void kslime_run22(entity this) { set_animofs(this, anim_kslime_run, 22, kslime_run23); ai_run(this, 2); }
void kslime_run21(entity this) { set_animofs(this, anim_kslime_run, 21, kslime_run22); ai_run(this, 2); }
void kslime_run20(entity this) { set_animofs(this, anim_kslime_run, 20, kslime_run21); ai_run(this, 2); }
void kslime_run19(entity this) { set_animofs(this, anim_kslime_run, 19, kslime_run20); ai_run(this, 2); }
void kslime_run18(entity this) { set_animofs(this, anim_kslime_run, 18, kslime_run19); ai_run(this, 2); }
void kslime_run17(entity this) { set_animofs(this, anim_kslime_run, 17, kslime_run18); ai_run(this, 2); }
void kslime_run16(entity this) { set_animofs(this, anim_kslime_run, 16, kslime_run17); ai_run(this, 2); }
void kslime_run15(entity this) { set_animofs(this, anim_kslime_run, 15, kslime_run16); ai_run(this, 2); }
void kslime_run14(entity this) { set_animofs(this, anim_kslime_run, 14, kslime_run15); ai_run(this, 2); }
void kslime_run13(entity this) { set_animofs(this, anim_kslime_run, 13, kslime_run14); ai_run(this, 2); }
void kslime_run12(entity this) { set_animofs(this, anim_kslime_run, 12, kslime_run13); ai_run(this, 2); }
void kslime_run11(entity this) { set_animofs(this, anim_kslime_run, 11, kslime_run12); ai_run(this, 2); }
void kslime_run10(entity this) { set_animofs(this, anim_kslime_run, 10, kslime_run11); ai_face(this); }
void kslime_run9(entity this) { set_animofs(this, anim_kslime_run, 9, kslime_run10); ai_face(this); }
void kslime_run8(entity this) { set_animofs(this, anim_kslime_run, 8, kslime_run9); ai_face(this); }
void kslime_run7(entity this) { set_animofs(this, anim_kslime_run, 7, kslime_run8); ai_face(this); }
void kslime_run6(entity this) { set_animofs(this, anim_kslime_run, 6, kslime_run7); ai_face(this); }
void kslime_run5(entity this) { set_animofs(this, anim_kslime_run, 5, kslime_run6); ai_face(this); }
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
			set_movetype(this, MOVETYPE_STEP);
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
		set_movetype(this, MOVETYPE_STEP);
		return;
	}
	this.cnt += 1;
	if(this.cnt >= 4)
		kslime_jump5(this);
}
void kslime_fly3(entity this) { set_animofs(this, anim_kslime_fly, 3, kslime_fly4); }
void kslime_fly2(entity this) { set_animofs(this, anim_kslime_fly, 2, kslime_fly3); }
void kslime_fly1(entity this) { set_animofs(this, anim_kslime_fly, 1, kslime_fly2); }

void kslime_jump6(entity this) { set_animofs(this, anim_kslime_jump, 2, kslime_fly1); }
void kslime_jump5(entity this)
{
	set_animofs(this, anim_kslime_jump, 2, kslime_jump6);

	set_movetype(this, MOVETYPE_BOUNCE);
	settouch(this, KingSlime_JumpTouch);
	fixedmakevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	this.velocity = v_forward * 600 + '0 0 200';
	this.velocity_z = this.velocity_z + random()*150;
	UNSET_ONGROUND(this);
	this.cnt = 0;
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
	
	BecomeExplosion(this);
}
void kslime_die1(entity this, entity inflictor, entity attacker, int deathtype) { set_anim(this, anim_kslime_exp, kslime_die2); this.takedamage = DAMAGE_NO; }

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
	this.eoc_summonflag = find_minionspace(org);

	// If the spawn locaiton all clear, spawn something!
	if(this.eoc_summonflag)
	{
		_sound(this, CH_VOICE, "king_slime/mytosis.wav", 1, ATTN_NORM);

		// special "servant" variant of demon eye
		entity pet = minion_spawn(this, org, new(monster), MON_SPAWN);
		pet.velocity = randomvec() * 400;
		pet.velocity_z = 200;
		pet.skin = ((random() > 0.5) ? 0 : 1);
		pet.health = min(pet.health, 40);
	}
}

void kslime_mitosis(entity targ, entity attacker, float damage, int deathtype)
{
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
#endif
