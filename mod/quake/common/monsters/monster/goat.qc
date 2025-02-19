#include "goat.qh"

#ifdef SVQC
// 0 is a dead frame
const int anim_goat_stand = 28;
const int anim_goat_walk = 1;
const int anim_goat_death = 4;
const int anim_goat_jump = 18;
const int anim_goat_ram = 18;

.float idle_finished;

void goat_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		sound(this, CH_VOICE, SND_MON_GOAT_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void goat_stand(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_goat_stand || this.walkframe > 117)
		this.walkframe = anim_goat_stand;

	set_anim(this, this.walkframe, goat_stand);
	ai_stand(this);

	goat_idlesound(this);
}

void goat_moveframe(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_goat_walk || this.walkframe > 16)
		this.walkframe = anim_goat_walk;

	if(time >= this.footstep && IS_ONGROUND(this) && this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.footstep = time + 0.6 * random();
		sound(this, CH_VOICE, SND_MON_GOAT_STEP_RANDOM(), 1, ATTN_NORM);
	}

	goat_idlesound(this);
}

void goat_walk(entity this)
{
	goat_moveframe(this);
	set_anim(this, this.walkframe, goat_walk);

	ai_walk(this, 6);
}

void goat_run(entity this)
{
	goat_moveframe(this);
	set_anim(this, this.walkframe, goat_run);

	ai_run(this, 10);
}

void goat_jump9(entity this) { set_animofs(this, anim_goat_jump, 10, goat_run); }
void goat_jump8(entity this) { set_animofs(this, anim_goat_jump, 9, goat_jump9); }
void goat_jump7(entity this) { set_animofs(this, anim_goat_jump, 8, goat_jump8); }
void goat_jump6(entity this) { set_animofs(this, anim_goat_jump, 7, goat_jump7); }
void goat_jump5(entity this) { set_animofs(this, anim_goat_jump, 6, goat_jump6); }
void goat_jump4(entity this) { set_animofs(this, anim_goat_jump, 5, goat_jump5); }
void goat_jump3(entity this)
{
	set_animofs(this, anim_goat_jump, 4, goat_jump3);
	if(IS_ONGROUND(this))
		setthink(this, goat_jump4);
}
void goat_jump2(entity this)
{
	set_animofs(this, anim_goat_jump, 3, goat_jump3);

	if(random() < 0.5)
		_sound(this, CH_VOICE, "goat/jump1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "goat/jump2.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);
	this.velocity = v_forward * (random() * 200) + v_up * (random() * 200);
	if(random() < 0.333)
		this.velocity_z += (random() * 400);
	UNSET_ONGROUND(this);
}
void goat_jump1(entity this) { set_animofs(this, anim_goat_jump, 2, goat_jump2); }

void goat_melee(entity this)
{
	set_animofs(this, anim_goat_jump, 1, goat_jump1);
	this.ideal_yaw = random() * 180;
	changeyaw(this);
	this.attack_finished = time + 2;
}

.float goat_bash_time;
void goat_bonk(entity this, entity toucher)
{
	if(time < this.goat_bash_time)
		return;
	if(this.velocity == '0 0 0')
		return;

	makevectors(this.angles);
	vector vec = normalize(toucher.origin - this.origin);
	float dot = vec * v_forward;
	if(dot < 0.3)
		return;

	if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

		makevectors(this.angles);
		toucher.velocity = v_forward * (300 * pushforce);
		toucher.velocity_z = (125 * pushforce);
	}

	te_explosion2(toucher.origin, 230, 5);

	float ldmg = 15 + 10*random();
	if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
		ldmg = 120;

	T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_GOAT.m_id);

	_sound(this, CH_VOICE, "player_goat/bonk.wav", 1, ATTN_NORM);

	this.goat_bash_time = time + 0.5;
}

void goat_ram_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;

	if(toucher.takedamage)
		goat_bonk(this, toucher);
}

void goat_ram7(entity this)
{
	set_anim(this, anim_goat_ram, goat_run);
	settouch(this, func_null);
}
void goat_ram6(entity this)
{
	set_anim(this, anim_goat_ram, goat_ram7);
	this.attack_finished = time + 3;
	this.nextthink = time + 1;
	settouch(this, goat_ram_touch);
	ai_face(this);
	UNSET_ONGROUND(this);
	vector vang = this.angles;
	makevectors('0 1 0' * vang.y);
	this.velocity += v_forward * 1200;
	this.velocity_z += 150;
}
void goat_ram5(entity this) { set_anim(this, anim_goat_ram, goat_ram6); ai_face(this); }
void goat_ram4(entity this) { set_anim(this, anim_goat_ram, goat_ram5); ai_face(this); }
void goat_ram3(entity this) { set_anim(this, anim_goat_ram, goat_ram4); ai_face(this); }
void goat_ram2(entity this) { set_anim(this, anim_goat_ram, goat_ram3); ai_face(this); }
void goat_ram1(entity this)
{
	set_anim(this, anim_goat_ram, goat_ram2);
	if(this.enemy.m_champion == CHAMPION_Goat && random() < 0.5)
	{
		goat_melee(this); // just hop around for friend!
		if(random() < 0.5)
			_sound(this, CH_VOICE, "player_goat/death2.wav", 1, ATTN_NORM);
		return;
	}

	ai_face(this);
	sound(this, CH_VOICE, SND_MON_GOAT_RAM_RANDOM(), 1, ATTN_NORM);
}

//===========================================================================

void goat_pain6(entity this) { set_anim(this, anim_goat_stand, goat_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void goat_pain5(entity this) { set_anim(this, anim_goat_stand, goat_pain6); }
void goat_pain4(entity this) { set_anim(this, anim_goat_stand, goat_pain5); this.colormod = '1 0.8 0.8'; }
void goat_pain3(entity this) { set_anim(this, anim_goat_stand, goat_pain4);}
void goat_pain2(entity this) { set_anim(this, anim_goat_stand, goat_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void goat_pain1(entity this) { set_anim(this, anim_goat_stand, goat_pain2); ai_pain(this, 6); }

void goat_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(gettouch(this) == goat_ram_touch)
		return;

	sound(this, CH_VOICE, SND_MON_GOAT_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 1.1;
	this.colormod = '1 0.9 0.9';
	this.scale = 1;

	goat_pain1(this);
}

//===========================================================================

void goat_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void goat_die6(entity this) { set_animofs(this, anim_goat_death, 6, goat_vanish); this.angles_z = 90; this.nextthink = time + 0.7;}
void goat_die5(entity this) { set_animofs(this, anim_goat_death, 5, goat_die6); this.angles_z = 75; }
void goat_die4(entity this) { set_animofs(this, anim_goat_death, 4, goat_die5); this.angles_z = 60; }
void goat_die3(entity this) { set_animofs(this, anim_goat_death, 3, goat_die4); this.angles_z = 45; }
void goat_die2(entity this) { set_animofs(this, anim_goat_death, 2, goat_die3); this.angles_z = 30; }
void goat_die1(entity this) { set_animofs(this, anim_goat_death, 1, goat_die2); this.angles_z = 15; this.solid = SOLID_NOT; }

void goat_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	sound(this, CH_VOICE, SND_MON_GOAT_DEATH_RANDOM(), 1, ATTN_NORM);

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	goat_die1(this);
}

/*QUAKED monster_goat (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_goat) { monster_start(this, true, MON_GOAT); }
#endif // SVQC

#ifdef SVQC
METHOD(MCGoat, mr_setup, bool(MCGoat this, entity actor))
{
    TC(MCGoat, this);

    precache_sound("goat/jump1.wav");
    precache_sound("goat/jump2.wav");
    precache_sound("player_goat/bonk.wav");
    precache_sound("player_goat/death2.wav");

	actor.spawnflags |= SPAWNFLAG_NEARSIGHTED;

	actor.yaw_speed = 90;

	if(random() < 0.15)
	{
		actor.colormap = 255;
		actor.colormap |= BIT(10); // RENDER_COLORMAPPED
	}

    actor.health = 100;
    actor.th_stand = goat_stand;
	actor.th_walk = goat_walk;
	actor.th_run = goat_run;
	actor.th_pain = goat_pain;
	actor.th_die = goat_die;
	actor.th_melee = goat_melee;
	actor.th_missile = goat_ram1;

    return true;
}
#endif
