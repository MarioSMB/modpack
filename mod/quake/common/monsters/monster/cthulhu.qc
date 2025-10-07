#include "cthulhu.qh"

#ifdef SVQC
const int anim_cthulhu_stand = 0;
const int anim_cthulhu_roar = 14;
const int anim_cthulhu_look = 44;
const int anim_cthulhu_walk = 70;
const int anim_cthulhu_run = 83;
const int anim_cthulhu_smash = 103;
const int anim_cthulhu_magic = 122;
const int anim_cthulhu_paina = 129;
const int anim_cthulhu_painb = 134;
const int anim_cthulhu_death = 144;

const float ATTN_CTHULHU = 0.1; // minimum attenuation, big roars!

const int MON_CTHULHU_ZOID = BIT(1);

.float cthtaunt_timer;
void cth_run1(entity this);

void gug_screen_shake(entity this, float stime, entity eshake);
void cthulhu_screen_shake(entity this, float stime, float rad)
{
	if(this.charmed)
		return;

	FOREACH_ENTITY_RADIUS(this.origin, rad, IS_PLAYER(it) && IS_ONGROUND(it),
	{
		gug_screen_shake(this, stime, it);
	});
}

void cthulhu_footstep(entity this, bool altframe)
{
	monster_footstep(this, altframe);

	cthulhu_screen_shake(this, 0.2, 400);
}

// "modified" from boss.qc
void cth_run(entity this)
{
// go for another player if multi player
	if(this.enemy.health <= 0 || random() < 0.02)
	{
		this.enemy = find(this.enemy, classname, "player");
		if(!this.enemy)
			this.enemy = find(this.enemy, classname, "player");
	}
	ai_run(this, 10);
}

void CthulhuTaunt(entity this)
{
	float r = random();
	
	if(r < 0.33)
	{
		if(this.spawnflags & MON_CTHULHU_ZOID)
			_sound(this, CH_VOICE, "zoidberg/breathe1.wav", 1, ATTN_CTHULHU);
		else
			_sound(this, CH_VOICE, "cthulhu/breathe1.wav", 1, ATTN_CTHULHU);
		this.cthtaunt_timer = time + 5;
	}
	if(r >= 0.33 && r < 0.66)
	{
		if(this.spawnflags & MON_CTHULHU_ZOID)
			_sound(this, CH_VOICE, "zoidberg/breathe2.wav", 1, ATTN_CTHULHU);
		else
			_sound(this, CH_VOICE, "cthulhu/breathe2.wav", 1, ATTN_CTHULHU);
		this.cthtaunt_timer = time + 10;
	}
	if(r >= 0.66)
	{
		if(this.spawnflags & MON_CTHULHU_ZOID)
			_sound(this, CH_VOICE, "zoidberg/breathe3.wav", 1, ATTN_CTHULHU);
		else
			_sound(this, CH_VOICE, "cthulhu/breathe3.wav", 1, ATTN_CTHULHU);
		this.cthtaunt_timer = time + 7;
	}
}

void cth_stand1(entity this);
void cth_stand14(entity this) { set_animofs(this, anim_cthulhu_stand, 14, cth_stand1); ai_stand(this); }
void cth_stand13(entity this) { set_animofs(this, anim_cthulhu_stand, 13, cth_stand14); ai_stand(this); }
void cth_stand12(entity this) { set_animofs(this, anim_cthulhu_stand, 12, cth_stand13); ai_stand(this); }
void cth_stand11(entity this) { set_animofs(this, anim_cthulhu_stand, 11, cth_stand12); ai_stand(this); }
void cth_stand10(entity this) { set_animofs(this, anim_cthulhu_stand, 10, cth_stand11); ai_stand(this); }
void cth_stand9(entity this) { set_animofs(this, anim_cthulhu_stand, 9, cth_stand10); ai_stand(this); }
void cth_stand8(entity this) { set_animofs(this, anim_cthulhu_stand, 8, cth_stand9); ai_stand(this); }
void cth_stand7(entity this) { set_animofs(this, anim_cthulhu_stand, 7, cth_stand8); ai_stand(this); }
void cth_stand6(entity this) { set_animofs(this, anim_cthulhu_stand, 6, cth_stand7); ai_stand(this); }
void cth_stand5(entity this) { set_animofs(this, anim_cthulhu_stand, 5, cth_stand6); ai_stand(this); }
void cth_stand4(entity this) { set_animofs(this, anim_cthulhu_stand, 4, cth_stand5); ai_stand(this); }
void cth_stand3(entity this) { set_animofs(this, anim_cthulhu_stand, 3, cth_stand4); ai_stand(this); }
void cth_stand2(entity this) { set_animofs(this, anim_cthulhu_stand, 2, cth_stand3); ai_stand(this); }
void cth_stand1(entity this) { set_animofs(this, anim_cthulhu_stand, 1, cth_stand2); ai_stand(this); }

void cth_walk1(entity this);
void cth_walk13(entity this) { set_animofs(this, anim_cthulhu_walk, 13, cth_walk1); ai_walk(this, 16); }
void cth_walk12(entity this) { set_animofs(this, anim_cthulhu_walk, 12, cth_walk13); ai_walk(this, 16); }
void cth_walk11(entity this) { set_animofs(this, anim_cthulhu_walk, 11, cth_walk12); ai_walk(this, 16); }
void cth_walk10(entity this) { set_animofs(this, anim_cthulhu_walk, 10, cth_walk11); ai_walk(this, 16); }
void cth_walk9(entity this) { set_animofs(this, anim_cthulhu_walk, 9, cth_walk10); ai_walk(this, 16); }
void cth_walk8(entity this) { set_animofs(this, anim_cthulhu_walk, 8, cth_walk9); ai_walk(this, 16); }
void cth_walk7(entity this) { set_animofs(this, anim_cthulhu_walk, 7, cth_walk8); ai_walk(this, 16); cthulhu_footstep(this, false); }
void cth_walk6(entity this) { set_animofs(this, anim_cthulhu_walk, 6, cth_walk7); ai_walk(this, 16); }
void cth_walk5(entity this) { set_animofs(this, anim_cthulhu_walk, 5, cth_walk6); ai_walk(this, 16); }
void cth_walk4(entity this) { set_animofs(this, anim_cthulhu_walk, 4, cth_walk5); ai_walk(this, 16); }
void cth_walk3(entity this) { set_animofs(this, anim_cthulhu_walk, 3, cth_walk4); ai_walk(this, 16); }
void cth_walk2(entity this) { set_animofs(this, anim_cthulhu_walk, 2, cth_walk3); ai_walk(this, 16); }
void cth_walk1(entity this) { set_animofs(this, anim_cthulhu_walk, 1, cth_walk2); ai_walk(this, 16); cthulhu_footstep(this, false); }

void cth_run20(entity this) { set_animofs(this, anim_cthulhu_run, 20, cth_run1); cth_run(this); cthulhu_footstep(this, false); }
void cth_run19(entity this) { set_animofs(this, anim_cthulhu_run, 19, cth_run20); cth_run(this); }
void cth_run18(entity this) { set_animofs(this, anim_cthulhu_run, 18, cth_run19); cth_run(this); }
void cth_run17(entity this) { set_animofs(this, anim_cthulhu_run, 17, cth_run18); cth_run(this); }
void cth_run16(entity this) { set_animofs(this, anim_cthulhu_run, 16, cth_run17); cth_run(this); }
void cth_run15(entity this) { set_animofs(this, anim_cthulhu_run, 15, cth_run16); cth_run(this); }
void cth_run14(entity this) { set_animofs(this, anim_cthulhu_run, 14, cth_run15); cth_run(this); }
void cth_run13(entity this) { set_animofs(this, anim_cthulhu_run, 13, cth_run14); cth_run(this); }
void cth_run12(entity this) { set_animofs(this, anim_cthulhu_run, 12, cth_run13); cth_run(this); }
void cth_run11(entity this) { set_animofs(this, anim_cthulhu_run, 11, cth_run12); cth_run(this); }
void cth_run10(entity this) { set_animofs(this, anim_cthulhu_run, 10, cth_run11); cth_run(this); cthulhu_footstep(this, false); }
void cth_run9(entity this) { set_animofs(this, anim_cthulhu_run, 9, cth_run10); cth_run(this); }
void cth_run8(entity this) { set_animofs(this, anim_cthulhu_run, 8, cth_run9); cth_run(this); }
void cth_run7(entity this)
{
	set_animofs(this, anim_cthulhu_run, 7, cth_run8);
	if(time > this.cthtaunt_timer)
		CthulhuTaunt(this);

	ai_run(this, 40);
}
void cth_run6(entity this) { set_animofs(this, anim_cthulhu_run, 6, cth_run7); cth_run(this); }
void cth_run5(entity this) { set_animofs(this, anim_cthulhu_run, 5, cth_run6); cth_run(this); }
void cth_run4(entity this) { set_animofs(this, anim_cthulhu_run, 4, cth_run5); cth_run(this); }
void cth_run3(entity this) { set_animofs(this, anim_cthulhu_run, 3, cth_run4); cth_run(this); }
void cth_run2(entity this) { set_animofs(this, anim_cthulhu_run, 2, cth_run3); cth_run(this); }
void cth_run1(entity this) { set_animofs(this, anim_cthulhu_run, 1, cth_run2); cth_run(this); }

void cth_smash19(entity this) { set_animofs(this, anim_cthulhu_smash, 19, cth_run1); }
void cth_smash18(entity this) { set_animofs(this, anim_cthulhu_smash, 18, cth_smash19); }
void cth_smash17(entity this) { set_animofs(this, anim_cthulhu_smash, 17, cth_smash18); }
void cth_smash16(entity this) { set_animofs(this, anim_cthulhu_smash, 16, cth_smash17); }
void cth_smash15(entity this) { set_animofs(this, anim_cthulhu_smash, 15, cth_smash16); }
void cth_smash14(entity this) { set_animofs(this, anim_cthulhu_smash, 14, cth_smash15); }
void cth_smash13(entity this)
{
	set_animofs(this, anim_cthulhu_smash, 13, cth_smash14);
	this.enemy.punchangle_x = -2;
	T_RadiusDamage(this, this, 80 * this.scale, DEATH_MONSTER_CTHULHU.m_id, this);

	cthulhu_screen_shake(this, 0.4, 550);

	_sound(this, CH_VOICE, "cthulhu/stomp.wav", 1, ATTN_CTHULHU);

	float myscale = (this.scale) ? this.scale : 1;
	ai_shockwave(this, '200 0 -34' * myscale, 150, 512, 300, 100, DEATH_MONSTER_CTHULHU.m_id, SND(Null));
}
void cth_smash12(entity this) { set_animofs(this, anim_cthulhu_smash, 12, cth_smash13); ai_charge(this, 2); }
void cth_smash11(entity this) { set_animofs(this, anim_cthulhu_smash, 11, cth_smash12); ai_charge(this, 2); }
void cth_smash10(entity this) { set_animofs(this, anim_cthulhu_smash, 10, cth_smash11); ai_charge(this, 2); }
void cth_smash9(entity this) { set_animofs(this, anim_cthulhu_smash, 9, cth_smash10); ai_charge(this, 2); }
void cth_smash8(entity this) { set_animofs(this, anim_cthulhu_smash, 8, cth_smash9); ai_charge(this, 2); }
void cth_smash7(entity this) { set_animofs(this, anim_cthulhu_smash, 7, cth_smash8); ai_charge(this, 2); }
void cth_smash6(entity this) { set_animofs(this, anim_cthulhu_smash, 6, cth_smash7); ai_charge(this, 2); }
void cth_smash5(entity this) { set_animofs(this, anim_cthulhu_smash, 5, cth_smash6); ai_charge(this, 2); }
void cth_smash4(entity this) { set_animofs(this, anim_cthulhu_smash, 4, cth_smash5); ai_charge(this, 2); }
void cth_smash3(entity this) { set_animofs(this, anim_cthulhu_smash, 3, cth_smash4); ai_charge(this, 2); }
void cth_smash2(entity this) { set_animofs(this, anim_cthulhu_smash, 2, cth_smash3); ai_charge(this, 2); }
void cth_smash1(entity this)
{
	set_animofs(this, anim_cthulhu_smash, 1, cth_smash2);
	if(this.spawnflags & MON_CTHULHU_ZOID)
		_sound(this, CH_VOICE, "zoidberg/stomp.wav", 1, ATTN_CTHULHU);
	else
		_sound(this, CH_VOICE, "cthulhu/smash.wav", 1, ATTN_CTHULHU);
	this.cthtaunt_timer = time + 4;
	ai_charge(this, 2);
}

void cth_tentacle_touch(entity this, entity toucher)
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
	float damg = ((this.dmg) ? this.dmg : 30);
	_sound(this, CH_WEAPON_SINGLE, "cthulhu/tentacle_impact.wav", 1, ATTN_NORM);
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
	else
	{
		vector vel = wall_velocity(this) * 0.2;
		vector org = this.origin + vel * 0.01;
		particle(org, vel * 0.1, 79, damg * 1);
		particle(org, vel * 0.25, 74, damg * 5);
		particle(org, vel * 0.15, 69, damg * 2);
	}

	delete(this);
}

void cthulhu_launch_missile(entity this, entity targ, vector offset)
{
	vector vec, d;

	vector offang = vectoangles(targ.origin - this.origin);	
	makevectors(offang);

	vector org = this.origin + offset.x * v_forward + offset.y * v_right + offset.z * '0 0 1';
	
// lead the player on hard mode
	if(autocvar_skill > 1)
	{
		float t = vlen(targ.origin - org) / 700;
		vec = targ.velocity;
		vec.z = 0;
		d = targ.origin + t * vec;		
	}
	else
	{
		d = targ.origin;
	}
	
	vec = normalize(d - org);

	entity newmis = launch_spike(this, org, vec);
	newmis.projectiledeathtype = DEATH_MONSTER_CTHULHU.m_id;
	newmis.classname = "cthulhu_tentacle";
	_setmodel(newmis, "progs/proj_tentacle.mdl");
	if(this.spawnflags & MON_CTHULHU_ZOID)
		newmis.skin = 1;
	newmis.scale = 0.25;
	newmis.owner = this;
	newmis.dmg = 80;
	newmis.avelocity = '0 0 100';
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec*700;
	newmis.angles = vectoangles(newmis.velocity);
	settouch(newmis, cth_tentacle_touch);
}

void cthulhu_missile(entity this, vector p)
{
	// on high difficulties launch a missile at every player
	if(coop && autocvar_skill >= 1 && !this.charmed)
	{
		FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET),
		{
			if(infront(this, it))
				cthulhu_launch_missile(this, it, p);
		});
	}
	else
		cthulhu_launch_missile(this, this.enemy, p);

	_sound(this, CH_SHOTS, "boss1/throw.wav", 1, ATTN_NORM);
}

void cth_magic7(entity this) { set_animofs(this, anim_cthulhu_magic, 7, cth_run1); }
void cth_magic6(entity this) { set_animofs(this, anim_cthulhu_magic, 6, cth_magic7); cthulhu_missile(this, '100 -100 200'); }
void cth_magic5(entity this) { set_animofs(this, anim_cthulhu_magic, 5, cth_magic6); }
void cth_magic4(entity this) { set_animofs(this, anim_cthulhu_magic, 4, cth_magic5); }
void cth_magic3(entity this) { set_animofs(this, anim_cthulhu_magic, 3, cth_magic4); }
void cth_magic2(entity this) { set_animofs(this, anim_cthulhu_magic, 2, cth_magic3); }
void cth_magic1(entity this) { set_animofs(this, anim_cthulhu_magic, 1, cth_magic2); }

/*
==========================
BALL
--------------------------
Cthulhu throws a spicy meatball.
==========================
*/

// special version of ai_face that accounts for pitch as well
float autocvar_sv_quake_eye_speed = 0.3; // TODO: distance based?
void eye_face(entity this)
{
	if(!this.enemy)
		return;

	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(this.enemy);
	vector ideal = vectoangles(normalize(targorg - myorg));
	if(this.angles == ideal)
		return;

	float angspeed = this.yaw_speed;
	ideal -= this.angles;

	this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

.float eye_lastframe;
void eye_think(entity this)
{
	this.nextthink = time;
	if(time >= this.count || !this.owner || this.owner.health <= 0 || !this.enemy || this.enemy.health <= 0)
	{
		stopsound(this, CH_WEAPON_SINGLE);
		delete(this);
		return;
	}
	if(time < this.cnt)
		return; // not firing yet!
	if(!this.state)
	{
		this.state = 1;
		_sound(this, CH_WEAPON_SINGLE, "cthulhu/laser.wav", 1, 0.4);
	}

	eye_face(this);
	if(time < this.eye_lastframe)
		return;

	this.frame += 1;
	if(this.frame > 19)
		this.frame = 0;
	this.eye_lastframe = time + 0.1; // 10 fps, quake style

	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	vector myorg = CENTER_OR_VIEWOFS(this);

	traceline(myorg, myorg + v_forward * 1500, true, this);

	SendCSQCLightningBeam(myorg, trace_endpos);

	LightningDamage(myorg, trace_endpos, this.owner, 10, DEATH_MONSTER_CTHULHU.m_id);
}

void eye_spawn(entity this)
{
	entity eye = new(cthulhu_eye);
	set_movetype(eye, MOVETYPE_NONE);
	eye.owner = this.owner;
	eye.realowner = this.realowner;
	eye.enemy = this.enemy;
	eye.solid = SOLID_CORPSE;
	setorigin(eye, this.origin);
	//eye.v_angle = this.angles;
	eye.angles = this.angles;
	_setmodel(eye, "progs/cthulhu_eye.mdl");
	setsize(eye, '-32 -32 -32', '32 32 32');
	setthink(eye, eye_think);
	eye.nextthink = time;
	eye.cnt = time + 1;
	eye.count = time + 7.5;
	eye.state = 0; // used for starting sound

	eye.yaw_speed = autocvar_sv_quake_eye_speed;

	delete(this);
}

void eye_remove(entity this, entity toucher)
{
	//te_wizspike(this.origin);
	delete(this);
}

void cthulhu_summoneye(entity this, entity targ)
{
	vector offang = vectoangles(targ.origin - this.origin);	
	makevectors(offang);
	vector offset = randomvec() * 12 + ('0 0 360' * this.scale);

	vector org = this.origin + offset.x * v_forward + offset.y * v_right + offset.z * '0 0 1';

	vector dir = normalize(targ.origin - org);

	// fire a projectile towards the target as a way to find a good location
	entity newmis = spawn();
	newmis.owner = this;
	newmis.realowner = this;
	newmis.enemy = targ;
	setorigin(newmis, org);
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.classname = "eye_projectile";
	newmis.solid = SOLID_CORPSE;
	//_setmodel(newmis, "progs/cthulhu_eye.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.scale = 0.2;
	newmis.velocity = dir * 200;
	newmis.angles = vectoangles(newmis.velocity);
	setthink(newmis, eye_spawn);
	newmis.nextthink = time + 1 + random();
	settouch(newmis, eye_remove); // just delete it if it hits anything?
}

void cthulhu_summoneyes(entity this)
{
	// on high difficulties launch an eyeball at every player
	if(coop && autocvar_skill >= 1 && !this.charmed)
	{
		FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET),
		{
			//if(infront(this, it))
				cthulhu_summoneye(this, it);
		});
	}
	else
		cthulhu_summoneye(this, this.enemy);
}

void cth_ball7(entity this) { set_animofs(this, anim_cthulhu_magic, 7, cth_run1); ai_face(this); }
void cth_ball6(entity this)
{
	set_animofs(this, anim_cthulhu_magic, 6, cth_ball7);
	ai_face(this);

	cthulhu_summoneyes(this);

	_sound(this, CH_WEAPON_SINGLE, "boss1/throw.wav", 1, ATTN_CTHULHU);
}
void cth_ball5(entity this) { set_animofs(this, anim_cthulhu_magic, 5, cth_ball6); ai_face(this); }
void cth_ball4(entity this) { set_animofs(this, anim_cthulhu_magic, 4, cth_ball5); ai_face(this); }
void cth_ball3(entity this) { set_animofs(this, anim_cthulhu_magic, 3, cth_ball4); ai_face(this); }
void cth_ball2(entity this) { set_animofs(this, anim_cthulhu_magic, 2, cth_ball3); ai_face(this); }
void cth_ball1(entity this)
{
	set_animofs(this, anim_cthulhu_magic, 1, cth_ball2);
	this.cthtaunt_timer = time + 4;
}

// ATTACK =======================================================================
void CthulhuAttack(entity this)
{
	this.attack_finished = time + 3;
	if(vdist(this.enemy.origin - this.origin, <=, 400))
	{
		cth_smash1(this);
		return;
	}

	// sometimes don't attack at all!
	if(random() < 0.2)
		cth_ball1(this);
	else if(random() < 0.8)
		cth_magic1(this);
}

// DAMAGE =======================================================================
void cth_paina5(entity this) { set_animofs(this, anim_cthulhu_paina, 5, cth_run1); }
void cth_paina4(entity this) { set_animofs(this, anim_cthulhu_paina, 4, cth_paina5); }
void cth_paina3(entity this) { set_animofs(this, anim_cthulhu_paina, 3, cth_paina4); }
void cth_paina2(entity this) { set_animofs(this, anim_cthulhu_paina, 2, cth_paina3); }
void cth_paina1(entity this) { set_animofs(this, anim_cthulhu_paina, 1, cth_paina2); }

void cth_painb10(entity this) { set_animofs(this, anim_cthulhu_painb, 10, cth_run1); }
void cth_painb9(entity this) { set_animofs(this, anim_cthulhu_painb, 9, cth_painb10); }
void cth_painb8(entity this) { set_animofs(this, anim_cthulhu_painb, 8, cth_painb9); }
void cth_painb7(entity this) { set_animofs(this, anim_cthulhu_painb, 7, cth_painb8); }
void cth_painb6(entity this) { set_animofs(this, anim_cthulhu_painb, 6, cth_painb7); }
void cth_painb5(entity this) { set_animofs(this, anim_cthulhu_painb, 5, cth_painb6); }
void cth_painb4(entity this) { set_animofs(this, anim_cthulhu_painb, 4, cth_painb5); }
void cth_painb3(entity this) { set_animofs(this, anim_cthulhu_painb, 3, cth_painb4); }
void cth_painb2(entity this) { set_animofs(this, anim_cthulhu_painb, 2, cth_painb3); }
void cth_painb1(entity this) { set_animofs(this, anim_cthulhu_painb, 1, cth_painb2); }

void cth_pain(entity this, entity attacker, float damage, int deathtype)
{
	//CthulhuTaunt(this);

	if(this.pain_finished > time)
		return;
	if(random()*200 > damage)
		return;		// didn't flinch

	this.pain_finished = time + 2;
	this.cthtaunt_timer = time + 4;

	if(this.spawnflags & MON_CTHULHU_ZOID)
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_VOICE, "zoidberg/pain1.wav", 1, ATTN_CTHULHU);
		else if(r < 0.66)
			_sound(this, CH_VOICE, "zoidberg/pain2.wav", 1, ATTN_CTHULHU);
		else
			_sound(this, CH_VOICE, "zoidberg/pain3.wav", 1, ATTN_CTHULHU);
	}
	else
		sound(this, CH_VOICE, SND_MON_CTHULHU_PAIN_RANDOM(), 1, ATTN_CTHULHU);

	if(random() < 0.5)
		setthink(this, cth_paina1);
	else
		setthink(this, cth_painb1);
	this.nextthink = time;
}

void cth_gib(entity this, entity inflictor)
{
	// throw tons of meat chunks
	_sound(this, CHAN_BODY, "boss2/pop2.wav", 1, ATTN_CTHULHU);
	vector oldo = this.origin;

	float posz = 0; // was -48
	while(posz <= 256)
	{
		float posx = 0; // was -96
		while(posx <= 256)
		{
			float posy = 0; // was -96
			while(posy <= 96)
			{
				this.origin_x = oldo.x + (posx * this.scale);
				this.origin_y = oldo.y + (posy * this.scale);
				this.origin_z = oldo.z + (posz * this.scale);

				float r = random();
				if(r < 0.3)				
					ThrowGib(this, inflictor, "progs/gib1.mdl", -100);
				else if(r < 0.6)
					ThrowGib(this, inflictor, "progs/gib2.mdl", -100);
				else
					ThrowGib(this, inflictor, "progs/gib3.mdl", -100);
				posy += 48;
			}
			posx += 64;
		}
		posz += 64;
	}
	delete(this);
}

void cth_gibthink(entity this)
{
	cth_gib(this, this);
}

void cth_fadethink(entity this)
{
	_sound(this, CH_VOICE, "cthulhu/fade.wav", 1, ATTN_CTHULHU);
	Send_Effect(EFFECT_CTHULHU_FADE, this.origin, '0 0 0', 1);
	SUB_SetFade(this, time, 3);
}

void cth_death26(entity this)
{
	set_animofs(this, anim_cthulhu_death, 26, cth_fadethink);
	this.nextthink = time + 3;
}
void cth_death25(entity this) { set_animofs(this, anim_cthulhu_death, 25, cth_death26); }
void cth_death24(entity this) { set_animofs(this, anim_cthulhu_death, 24, cth_death25); }
void cth_death23(entity this) { set_animofs(this, anim_cthulhu_death, 23, cth_death24); }
void cth_death22(entity this)
{
	set_animofs(this, anim_cthulhu_death, 22, cth_death23);
	_sound(this, CH_VOICE, "cthulhu/step1.wav", 1, ATTN_CTHULHU);

	cthulhu_screen_shake(this, 0.6, 700);
}
void cth_death21(entity this) { set_animofs(this, anim_cthulhu_death, 21, cth_death22); }
void cth_death20(entity this) { set_animofs(this, anim_cthulhu_death, 20, cth_death21); }
void cth_death19(entity this) { set_animofs(this, anim_cthulhu_death, 19, cth_death20); }
void cth_death18(entity this) { set_animofs(this, anim_cthulhu_death, 18, cth_death19); }
void cth_death17(entity this) { set_animofs(this, anim_cthulhu_death, 17, cth_death18); }
void cth_death16(entity this) { set_animofs(this, anim_cthulhu_death, 16, cth_death17); }
void cth_death15(entity this) { set_animofs(this, anim_cthulhu_death, 15, cth_death16); }
void cth_death14(entity this) { set_animofs(this, anim_cthulhu_death, 14, cth_death15); }
void cth_death13(entity this) { set_animofs(this, anim_cthulhu_death, 13, cth_death14); }
void cth_death12(entity this) { set_animofs(this, anim_cthulhu_death, 12, cth_death13); }
void cth_death11(entity this) { set_animofs(this, anim_cthulhu_death, 11, cth_death12); }
void cth_death10(entity this) { set_animofs(this, anim_cthulhu_death, 10, cth_death11); }
void cth_death9(entity this) { set_animofs(this, anim_cthulhu_death, 9, cth_death10); }
void cth_death8(entity this) { set_animofs(this, anim_cthulhu_death, 8, cth_death9); }
void cth_death7(entity this) { set_animofs(this, anim_cthulhu_death, 7, cth_death8); }
void cth_death6(entity this) { set_animofs(this, anim_cthulhu_death, 6, cth_death7); }
void cth_death5(entity this) { set_animofs(this, anim_cthulhu_death, 5, cth_death6); }
void cth_death4(entity this) { set_animofs(this, anim_cthulhu_death, 4, cth_death5); }
void cth_death3(entity this) { set_animofs(this, anim_cthulhu_death, 3, cth_death4); }
void cth_death2(entity this) { set_animofs(this, anim_cthulhu_death, 2, cth_death3); }
void cth_death1(entity this) { set_animofs(this, anim_cthulhu_death, 1, cth_death2); this.solid = SOLID_NOT; }

void cth_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -150)
	{
		cth_gib(this, inflictor);
		return;
	}

	if(this.spawnflags & MON_CTHULHU_ZOID)
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_VOICE, "zoidberg/die1.wav", 1, ATTN_CTHULHU);
		else if(r < 0.66)
			_sound(this, CH_VOICE, "zoidberg/die2.wav", 1, ATTN_CTHULHU);
		else
			_sound(this, CH_VOICE, "zoidberg/die3.wav", 1, ATTN_CTHULHU);
	}
	else
		sound(this, CH_VOICE, SND_MON_CTHULHU_DEATH_RANDOM(), 1, ATTN_CTHULHU);
	cth_death1(this);
}

void cth_wakeframe(entity this)
{
	this.walkframe += 1;
	this.frame = this.walkframe;
	if(this.walkframe >= 43)
	{
		if(this.enemy)
			cth_run1(this);
		else if(this.movetarget)
			cth_walk1(this);
		else
			cth_stand1(this);
		return;
	}
	if(this.walkframe == anim_cthulhu_roar + 4)
		cthulhu_screen_shake(this, 1, 700);

	this.nextthink = time + 0.1;
}

void cth_wake(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & MON_CTHULHU_ZOID)
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_VOICE, "zoidberg/alert1.wav", 1, ATTN_CTHULHU);
		else if(r < 0.66)
			_sound(this, CH_VOICE, "zoidberg/alert2.wav", 1, ATTN_CTHULHU);
		else
			_sound(this, CH_VOICE, "zoidberg/alert3.wav", 1, ATTN_CTHULHU);
	}
	else
	{
		sound(this, CH_VOICE, SND_MON_CTHULHU_SIGHT_RANDOM(), 1, ATTN_CTHULHU);
	}
	this.cthtaunt_timer = time + 10;
	this.enemy = actor;
	this.use = func_null;

	this.frame = anim_cthulhu_roar;
	this.walkframe = this.frame;
	setthink(this, cth_wakeframe);
	this.nextthink = time;
}

spawnfunc(monster_cthulhu) { monster_start(this, true, MON_CTHULHU); }
#endif // SVQC

#ifdef SVQC
METHOD(Cthulhu, mr_setup, bool(Cthulhu this, entity actor))
{
	TC(Cthulhu, this);

	precache_model("progs/proj_ringshock.mdl");
	precache_model("progs/cthulhu_eye.mdl");
	precache_model("progs/proj_tentacle.mdl");
	
	precache_sound("boss2/pop2.wav");
	precache_sound("weapons/rocket1i.wav");
	precache_sound("boss1/throw.wav");

	precache_sound("cthulhu/breathe1.wav");
	precache_sound("cthulhu/breathe2.wav");
	precache_sound("cthulhu/breathe3.wav");
	precache_sound("cthulhu/stomp.wav");
	precache_sound("cthulhu/smash.wav");
	precache_sound("cthulhu/fade.wav");
	precache_sound("cthulhu/laser.wav");
	precache_sound("cthulhu/tentacle_impact.wav");

	if(random() < 0.15)
		actor.spawnflags |= MON_CTHULHU_ZOID;
	actor.skin = 0;

	if(actor.spawnflags & MON_CTHULHU_ZOID)
	{
		// TODO: zoidy skin doesn't work with colormods for some reason
		if(!actor.charmed)
			actor.skin = 1;
		precache_sound("zoidberg/alert1.wav");
		precache_sound("zoidberg/alert2.wav");
		precache_sound("zoidberg/alert3.wav");
		precache_sound("zoidberg/breathe1.wav");
		precache_sound("zoidberg/breathe2.wav");
		precache_sound("zoidberg/breathe3.wav");
		precache_sound("zoidberg/die1.wav");
		precache_sound("zoidberg/die2.wav");
		precache_sound("zoidberg/die3.wav");
		precache_sound("zoidberg/pain1.wav");
		precache_sound("zoidberg/pain2.wav");
		precache_sound("zoidberg/pain3.wav");
		precache_sound("zoidberg/stomp.wav");
	}

	actor.health = 4000;
	if(horde_ent || actor.charmed)
		actor.scale = 0.5;
	else if(!actor.scale)
		actor.scale = 1;

	actor.th_stand = cth_stand1;
	actor.th_walk = cth_walk1;
	actor.th_run = cth_run1;
	actor.th_die = cth_die;
	actor.th_melee = CthulhuAttack;
	actor.th_missile = CthulhuAttack;
	actor.th_pain = cth_pain;
	actor.use = cth_wake;

	setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);

	// Custom feet sounds
	actor.stepc1 = "cthulhu/step1.wav";
	actor.stepc2 = "cthulhu/step2.wav";
	actor.stepc3 = "cthulhu/step1.wav";
	actor.stepc4 = "cthulhu/step2.wav";
	actor.stepc5 = "cthulhu/step1.wav";
	precache_sound(actor.stepc1);
	precache_sound(actor.stepc2);
	actor.steptype = FS_TYPECUSTOM;

	if(!actor.target || actor.targetname == "")
	if(!horde_ent && !actor.charmed)
		cth_wake(actor, actor.enemy, NULL);

	return true;
}
METHOD(Cthulhu, mr_sight, bool(Cthulhu this, entity actor))
{
	TC(Cthulhu, this);

	if(time <= actor.cthtaunt_timer)
		return true; // too soon!

	if(actor.spawnflags & MON_CTHULHU_ZOID)
	{
		float r = random();
		if(r < 0.33)
			_sound(actor, CH_VOICE, "zoidberg/alert1.wav", 1, ATTN_CTHULHU);
		else if(r < 0.66)
			_sound(actor, CH_VOICE, "zoidberg/alert2.wav", 1, ATTN_CTHULHU);
		else
			_sound(actor, CH_VOICE, "zoidberg/alert3.wav", 1, ATTN_CTHULHU);
	}
	else
		sound(actor, CH_VOICE, SND_MON_CTHULHU_SIGHT_RANDOM(), 1, ATTN_CTHULHU);

	actor.cthtaunt_timer = time + 10;

	return true;
}
#endif
