#include "tortoise.qh"

#ifdef SVQC
const int anim_tortoise_stand = 0;
const int anim_tortoise_walk = 20;
const int anim_tortoise_run = 56;
const int anim_tortoise_leap = 76;
const int anim_tortoise_land = 81;

const int MON_TORTOISE_ICE = BIT(1);


//============================================================================

.float idle_finished;

void Tortoise_JumpTouch(entity this, entity toucher);

void tortoise_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2 + (random() * 2);
		_sound(this, CH_VOICE, "tortoise/idle.wav", 1, ATTN_IDLE);
	}
}

void tortoise_moveframe(entity this, int startframe, int endframe)
{
	this.walkframe += 1;
	if(this.walkframe < startframe || this.walkframe > endframe)
		this.walkframe = startframe;

	tortoise_idlesound(this);
}

void tortoise_stand(entity this)
{
	tortoise_moveframe(this, anim_tortoise_stand, 19);
	set_anim(this, this.walkframe, tortoise_stand);
	//this.nextthink = time + 0.05; // slow animation needs fixing

	ai_stand(this);
}

void tortoise_walk(entity this)
{
	tortoise_moveframe(this, anim_tortoise_walk, 55);
	set_anim(this, this.walkframe, tortoise_walk);
	//this.nextthink = time + 0.05; // slow animation needs fixing

	ai_walk(this, 4);
}

void tortoise_run(entity this)
{
	tortoise_moveframe(this, anim_tortoise_run, 75);
	set_anim(this, this.walkframe, tortoise_run);
	//this.nextthink = time + 0.05; // slow animation needs fixing

	ai_run(this, 6);
}

void tortoise_jump1(entity this);
void tortoise_land7(entity this) { set_animofs(this, anim_tortoise_land, 7, tortoise_run); }
void tortoise_land6(entity this) { set_animofs(this, anim_tortoise_land, 6, tortoise_land7); }
void tortoise_land5(entity this) { set_animofs(this, anim_tortoise_land, 5, tortoise_land6); }
void tortoise_land4(entity this) { set_animofs(this, anim_tortoise_land, 4, tortoise_land5); }
void tortoise_land3(entity this) { set_animofs(this, anim_tortoise_land, 3, tortoise_land4); }
void tortoise_land2(entity this) { set_animofs(this, anim_tortoise_land, 2, tortoise_land3); }
void tortoise_land1(entity this) { set_animofs(this, anim_tortoise_land, 1, tortoise_land2); this.angles_x = 0; }
void tortoise_jump5(entity this)
{
	set_animofs(this, anim_tortoise_leap, 5, tortoise_jump1);
	if(this.exptime != 0)
	{
		this.angles_x = 0;
		return;
	}
	// physics says we're on ground
	if(IS_ONGROUND(this))
	{
		this.angles_x = 0;
		settouch(this, func_null);
		setthink(this, tortoise_land1);
		return;
	}
	// still jumping
	this.nextthink = time;
	this.angles_x -= 360 * sys_frametime;
	setthink(this, tortoise_jump5);
}
void tortoise_jump4(entity this)
{
	set_animofs(this, anim_tortoise_leap, 4, tortoise_jump5);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		return;
	}
	this.angles_x = 0;
	ai_face(this);
	settouch(this, Tortoise_JumpTouch);
	this.origin_z += 1;
	//fixedmakevectors(this.angles);
	vector dir = normalize(this.enemy.origin - this.origin);
	float jspeed = bound(600, vlen(this.enemy.origin - this.origin) * 2, 5000);
	this.velocity = dir * jspeed + '0 0 300';
	UNSET_ONGROUND(this);
}
// if three seconds pass, assume tortoise is stuck and jump again
void tortoise_jump3(entity this) { set_animofs(this, anim_tortoise_leap, 3, tortoise_jump4); ai_face(this); }
void tortoise_jump2(entity this) { set_animofs(this, anim_tortoise_leap, 2, tortoise_jump3); ai_face(this); }
void tortoise_jump1(entity this) { set_animofs(this, anim_tortoise_leap, 1, tortoise_jump2); ai_face(this); }

void tortoise_melee(entity this)
{
	set_anim(this, this.frame, tortoise_run);
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_TORTOISE.m_id, 120, false);
	this.attack_finished = time + 0.5;
}

void tortoise_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 0.2;
	_sound(this, CH_VOICE, "tortoise/hurt.wav", 1, ATTN_NORM);

	if(gettouch(this) == Tortoise_JumpTouch)
		return;
	if(random()*200 > damage)
		return;		// didn't flinch

	setthink(this, tortoise_run);
	this.nextthink = time;
	this.attack_finished = time + 0.5; // slight delay on attacks
}

void tortoise_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "tortoise/death.wav", 1, ATTN_NORM);

	particle(this.origin + (this.absmin + this.absmax) * 0.5, '0 0 0', 73, 70);

	ThrowHead(this, inflictor, "progs/h_tortoise.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
}

/*
==============
CheckTortoiseMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckTortoiseMelee(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		this.attack_state = AS_MELEE;
		return true;
	}
	return false;
}

/*
==============
CheckTortoiseJump

==============
*/
bool CheckTortoiseJump(entity this)
{
	if(this.origin_z + this.mins_z > this.enemy.origin_z + this.enemy.mins_z
		+ 0.75 * this.enemy.size_z)
		return false;
		
	if(this.origin_z + this.maxs_z < this.enemy.origin_z + this.enemy.mins_z
		+ 0.25 * this.enemy.size_z)
		return false;
		
	vector dist = vec2(this.enemy.origin - this.origin);
	
	if(vdist(dist, <, 100))
		return false;
		
	if(vdist(dist, >, 200))
	{
		if(random() < 0.9)
			return false;
	}
		
	return true;
}

bool TortoiseCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckTortoiseMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	if(CheckTortoiseJump(this))
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	return false;
}


//===========================================================================

void Tortoise_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;

	ai_jumpbreakable(this, toucher, 50);				// Damage any breakables

	if(toucher.takedamage && this.attack_finished < time)
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 40 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_TORTOISE.m_id);
			this.attack_finished = time + 0.5;
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this) && this.exptime == 0)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			this.angles_x = 0;
			settouch(this, func_null);
			setthink(this, tortoise_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}
}

/*QUAKED monster_tortoise(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_tortoise) { monster_start(this, true, MON_TORTOISE); }
#endif // SVQC

#ifdef SVQC
METHOD(Tortoise, mr_setup, bool(Tortoise this, entity actor))
{
	TC(Tortoise, this);

	precache_sound("tortoise/death.wav");
	precache_sound("tortoise/idle.wav");
	precache_sound("tortoise/hurt.wav");

	precache_model("progs/bone.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	if(random() < 0.25)
		actor.spawnflags |= MON_TORTOISE_ICE;

	if(actor.spawnflags & MON_TORTOISE_ICE)
		actor.skin = 1;

	actor.health = 350;
	actor.th_stand = tortoise_stand;
	actor.th_walk = tortoise_walk;
	actor.th_run = tortoise_run;
	actor.th_die = tortoise_die;
	actor.th_melee = tortoise_melee;
	actor.th_missile = tortoise_jump1;			// jump attack
	actor.th_pain = tortoise_pain;

	actor.checkattack = TortoiseCheckAttack;

	return true;
}
#endif
