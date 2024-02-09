#include "goroth.qh"

#ifdef SVQC
const int anim_goroth_stand = 0; //'0 19 0';
const int anim_goroth_walk = 20; //'20 31 0';
const int anim_goroth_smash = 32; //'32 58 0';
const int anim_goroth_magic = 59; //'59 84 0';
const int anim_goroth_death = 85; //'85 106 0';
const int anim_goroth_ball = 107; //'107 126 0';

.float gortaunt_timer;
void gor_run1(entity this);

vector GorRotatePointYaw(entity this, vector point, float ang)
{
	point *= this.scale;
	vector vec = '0 1 0' * this.angles_y;
	makevectors(vec);
	vec = point;
	float vecx = vec.x * v_forward.x - vec.y * v_forward.y;
	float vecy = vec.x * v_forward.y + vec.y * v_forward.x;
	vec.x = vecx;
	vec.y = vecy;
	
	return vec;
}

// "modified" from boss.qc
void gor_run(entity this)
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

void GorothTaunt(entity this)
{
	float r = random();
	
	if(r < 0.33)
	{
		_sound(this, CH_VOICE, "goroth/gortaunt1.wav", 1, ATTN_NORM);
		this.gortaunt_timer = time + 5;
	}
	if(r >= 0.33 && r < 0.66)
	{
		_sound(this, CH_VOICE, "goroth/gortaunt2.wav", 1, ATTN_NORM);
		this.gortaunt_timer = time + 10;
	}
	if(r >= 0.66)
	{
		_sound(this, CH_VOICE, "goroth/gortaunt3.wav", 1, ATTN_NORM);
		this.gortaunt_timer = time + 7;
	}
}

void gor_stand1(entity this);
void gor_stand20(entity this) { set_animofs(this, anim_goroth_stand, 20, gor_stand1); ai_stand(this); }
void gor_stand19(entity this) { set_animofs(this, anim_goroth_stand, 19, gor_stand20); ai_stand(this); }
void gor_stand18(entity this) { set_animofs(this, anim_goroth_stand, 18, gor_stand19); ai_stand(this); }
void gor_stand17(entity this) { set_animofs(this, anim_goroth_stand, 17, gor_stand18); ai_stand(this); }
void gor_stand16(entity this) { set_animofs(this, anim_goroth_stand, 16, gor_stand17); ai_stand(this); }
void gor_stand15(entity this) { set_animofs(this, anim_goroth_stand, 15, gor_stand16); ai_stand(this); }
void gor_stand14(entity this) { set_animofs(this, anim_goroth_stand, 14, gor_stand15); ai_stand(this); }
void gor_stand13(entity this) { set_animofs(this, anim_goroth_stand, 13, gor_stand14); ai_stand(this); }
void gor_stand12(entity this) { set_animofs(this, anim_goroth_stand, 12, gor_stand13); ai_stand(this); }
void gor_stand11(entity this) { set_animofs(this, anim_goroth_stand, 11, gor_stand12); ai_stand(this); }
void gor_stand10(entity this) { set_animofs(this, anim_goroth_stand, 10, gor_stand11); ai_stand(this); }
void gor_stand9(entity this) { set_animofs(this, anim_goroth_stand, 9, gor_stand10); ai_stand(this); }
void gor_stand8(entity this) { set_animofs(this, anim_goroth_stand, 8, gor_stand9); ai_stand(this); }
void gor_stand7(entity this) { set_animofs(this, anim_goroth_stand, 7, gor_stand8); ai_stand(this); }
void gor_stand6(entity this) { set_animofs(this, anim_goroth_stand, 6, gor_stand7); ai_stand(this); }
void gor_stand5(entity this) { set_animofs(this, anim_goroth_stand, 5, gor_stand6); ai_stand(this); }
void gor_stand4(entity this) { set_animofs(this, anim_goroth_stand, 4, gor_stand5); ai_stand(this); }
void gor_stand3(entity this) { set_animofs(this, anim_goroth_stand, 3, gor_stand4); ai_stand(this); }
void gor_stand2(entity this) { set_animofs(this, anim_goroth_stand, 2, gor_stand3); ai_stand(this); }
void gor_stand1(entity this) { set_animofs(this, anim_goroth_stand, 1, gor_stand2); ai_stand(this); }

void gor_walk1(entity this);
void gor_walk12(entity this) { set_animofs(this, anim_goroth_walk, 12, gor_walk1); ai_walk(this, 16); }
void gor_walk11(entity this) { set_animofs(this, anim_goroth_walk, 11, gor_walk12); ai_walk(this, 16); }
void gor_walk10(entity this) { set_animofs(this, anim_goroth_walk, 10, gor_walk11); ai_walk(this, 16); }
void gor_walk9(entity this) { set_animofs(this, anim_goroth_walk, 9, gor_walk10); ai_walk(this, 16); }
void gor_walk8(entity this) { set_animofs(this, anim_goroth_walk, 8, gor_walk9); ai_walk(this, 16); }
void gor_walk7(entity this) { set_animofs(this, anim_goroth_walk, 7, gor_walk8); ai_walk(this, 16); }
void gor_walk6(entity this) { set_animofs(this, anim_goroth_walk, 6, gor_walk7); ai_walk(this, 16); }
void gor_walk5(entity this) { set_animofs(this, anim_goroth_walk, 5, gor_walk6); ai_walk(this, 16); }
void gor_walk4(entity this) { set_animofs(this, anim_goroth_walk, 4, gor_walk5); ai_walk(this, 16); }
void gor_walk3(entity this) { set_animofs(this, anim_goroth_walk, 3, gor_walk4); ai_walk(this, 16); }
void gor_walk2(entity this) { set_animofs(this, anim_goroth_walk, 2, gor_walk3); ai_walk(this, 16); }
void gor_walk1(entity this) { set_animofs(this, anim_goroth_walk, 1, gor_walk2); ai_walk(this, 16); }

void gor_run12(entity this)
{
	set_animofs(this, anim_goroth_walk, 12, gor_run1);
	if(time > this.gortaunt_timer)
		GorothTaunt(this);

	ai_run(this, 40);
}
void gor_run11(entity this) { set_animofs(this, anim_goroth_walk, 11, gor_run12); gor_run(this); }
void gor_run10(entity this) { set_animofs(this, anim_goroth_walk, 10, gor_run11); gor_run(this); }
void gor_run9(entity this) { set_animofs(this, anim_goroth_walk, 9, gor_run10); gor_run(this); }
void gor_run8(entity this) { set_animofs(this, anim_goroth_walk, 8, gor_run9); gor_run(this); }
void gor_run7(entity this) { set_animofs(this, anim_goroth_walk, 7, gor_run8); gor_run(this); }
void gor_run6(entity this) { set_animofs(this, anim_goroth_walk, 6, gor_run7); gor_run(this); }
void gor_run5(entity this) { set_animofs(this, anim_goroth_walk, 5, gor_run6); gor_run(this); }
void gor_run4(entity this) { set_animofs(this, anim_goroth_walk, 4, gor_run5); gor_run(this); }
void gor_run3(entity this) { set_animofs(this, anim_goroth_walk, 3, gor_run4); gor_run(this); }
void gor_run2(entity this) { set_animofs(this, anim_goroth_walk, 2, gor_run3); gor_run(this); }
void gor_run1(entity this) { set_animofs(this, anim_goroth_walk, 1, gor_run2); gor_run(this); }

/*
=================================
SMASH ATTACK
---------------------------------
Goroth raises his right fist high in the air and then punches the ground hard,
causing a shockwave of explosions to emanate from all around his position.
=================================
*/
void GorothLavaSplash(entity this, vector lavapos)
{
	vector vec = GorRotatePointYaw(this, lavapos, this.angles_y);		
	vec = this.origin + vec;
	float posz = -1;
	while(posz <= 1)
	{
		float posx = -1;
		while(posx <= 1)
		{
			float posy = -1;
			while(posy <= 1)
			{
				vector dir;
				dir.x = posx;
				dir.y = posy;
				dir.z = posz;
				dir = normalize(dir);
				particle(vec + dir * 8, dir * 32, 232, 50);
				posy += 1;
			}
			posx += 1;
		}
		posz += 1;
	}
}

void GorothSmashBoom(entity this)
{
	this.gortaunt_timer -= 1;
	this.nextthink = time + 0.1;
	if(this.gortaunt_timer > 0)
		setthink(this, GorothSmashBoom);
	else
		setthink(this, SUB_Remove);
	
	T_RadiusDamage(this, this.owner, 60, DEATH_MONSTER_GOROTH.m_id, this.owner);
	
	// Explosions occur as the missile travels
	float r = random() * 2 - 1;
	
	makevectors(this.angles);
	
	entity expl = spawn();
	expl.origin = this.origin + r * 32 * v_right;	
	set_movetype(expl, MOVETYPE_TOSS);
	expl.velocity = '0 0 200';
	expl.avelocity_x = random()*600;
	expl.avelocity_y = random()*600;
	expl.avelocity_z = random()*600;
	settouch(expl, func_null);
	_setmodel(expl, "progs/s_explod.spr");
	setsize(expl, '0 0 0', '0 0 0');
	expl.solid = SOLID_NOT;
	expl.nextthink = time;
	setthink(expl, s_explode1);
	te_explosion(this.origin);

	traceline(this.origin, this.origin - '0 0 48', true, this);
	if(trace_fraction == 1)
	{
		delete(this);
		return;
	}
}

void GorothSmashMissile(entity this, vector dir, float rmv_t)
{
	entity gmis = spawn();
	gmis.owner = this;
	gmis.solid = SOLID_NOT;
	gmis.projectiledeathtype = DEATH_MONSTER_GOROTH.m_id;
	set_movetype(gmis, MOVETYPE_FLY);
	gmis.effects = EF_DIMLIGHT;
	setsize(gmis, '0 0 0', '0 0 0');
	makevectors(this.angles);
	vector org = this.origin + v_forward * (256 * this.scale) - '0 0 32';
	setorigin(gmis, org);
	gmis.velocity = dir * 500;
	gmis.angles = vectoangles(gmis.velocity);
	gmis.gortaunt_timer = rmv_t;
	gmis.nextthink = time;
	setthink(gmis, GorothSmashBoom);
}

void gor_smash27(entity this) { set_animofs(this, anim_goroth_smash, 27, gor_run1); }
void gor_smash26(entity this) { set_animofs(this, anim_goroth_smash, 26, gor_smash27); }
void gor_smash25(entity this) { set_animofs(this, anim_goroth_smash, 25, gor_smash26); }
void gor_smash24(entity this) { set_animofs(this, anim_goroth_smash, 24, gor_smash25); }
void gor_smash23(entity this) { set_animofs(this, anim_goroth_smash, 23, gor_smash24); }
void gor_smash22(entity this) { set_animofs(this, anim_goroth_smash, 22, gor_smash23); }
void gor_smash21(entity this) { set_animofs(this, anim_goroth_smash, 21, gor_smash22); }
void gor_smash20(entity this) { set_animofs(this, anim_goroth_smash, 20, gor_smash21); }
void gor_smash19(entity this) { set_animofs(this, anim_goroth_smash, 19, gor_smash20); }
void gor_smash18(entity this) { set_animofs(this, anim_goroth_smash, 18, gor_smash19); }
void gor_smash17(entity this) { set_animofs(this, anim_goroth_smash, 17, gor_smash18); }
void gor_smash16(entity this)
{
	set_animofs(this, anim_goroth_smash, 16, gor_smash17);
	this.enemy.punchangle_x = -2;
	T_RadiusDamage(this, this, 400 * this.scale, DEATH_MONSTER_GOROTH.m_id, this);
	
	GorothLavaSplash(this, '454 18 -40');
	
	float ang = 0;
	while(ang <= 315)
	{
		vector vec = this.v_angle;
		vec.y += (ang * this.scale);
		makevectors(vec);
		GorothSmashMissile(this, v_forward, 31);
		ang += 45;
	}
}
void gor_smash15(entity this) { set_animofs(this, anim_goroth_smash, 15, gor_smash16); }
void gor_smash14(entity this) { set_animofs(this, anim_goroth_smash, 14, gor_smash15); }
void gor_smash13(entity this) { set_animofs(this, anim_goroth_smash, 13, gor_smash14); }
void gor_smash12(entity this) { set_animofs(this, anim_goroth_smash, 12, gor_smash13); ai_charge(this, 2); }
void gor_smash11(entity this) { set_animofs(this, anim_goroth_smash, 11, gor_smash12); ai_charge(this, 2); }
void gor_smash10(entity this) { set_animofs(this, anim_goroth_smash, 10, gor_smash11); ai_charge(this, 2); }
void gor_smash9(entity this) { set_animofs(this, anim_goroth_smash, 9, gor_smash10); ai_charge(this, 2); }
void gor_smash8(entity this) { set_animofs(this, anim_goroth_smash, 8, gor_smash9); ai_charge(this, 2); }
void gor_smash7(entity this) { set_animofs(this, anim_goroth_smash, 7, gor_smash8); ai_charge(this, 2); }
void gor_smash6(entity this) { set_animofs(this, anim_goroth_smash, 6, gor_smash7); ai_charge(this, 2); }
void gor_smash5(entity this) { set_animofs(this, anim_goroth_smash, 5, gor_smash6); ai_charge(this, 2); }
void gor_smash4(entity this) { set_animofs(this, anim_goroth_smash, 4, gor_smash5); ai_charge(this, 2); }
void gor_smash3(entity this) { set_animofs(this, anim_goroth_smash, 3, gor_smash4); ai_charge(this, 2); }
void gor_smash2(entity this) { set_animofs(this, anim_goroth_smash, 2, gor_smash3); ai_charge(this, 2); }
void gor_smash1(entity this)
{
	set_animofs(this, anim_goroth_smash, 1, gor_smash2);
	if(time > this.gortaunt_timer)
	{
		_sound(this, CH_VOICE, "goroth/gorsmash.wav", 1, ATTN_NORM);
		this.gortaunt_timer = time + 4;
	}
	ai_charge(this, 2);
}

/*
=======================
MAGIC
-----------------------
Goroth summons 3 molten rock pillars from the ground on the target's position,
all of which proceed to explode after a few seconds. Upon finishing, Goroth slams
both fists on the ground, causing a shockwave of explosions in a straight line
directly in front of him.
=======================
*/
void GorothRockExplode(entity this)
{
	te_explosion(this.origin);

	//T_RadiusDamage (this, this.owner, 100, this.owner);
	BecomeExplosion(this);
}

void gorrock10(entity this) { set_anim(this, 5, GorothRockExplode); T_RadiusDamage(this, this.owner, 50, DEATH_MONSTER_GOROTH.m_id, this.owner); }
void gorrock9(entity this) { set_anim(this, 5, gorrock10); T_RadiusDamage(this, this.owner, 50, DEATH_MONSTER_GOROTH.m_id, this.owner); }
void gorrock8(entity this) { set_anim(this, 5, gorrock9); T_RadiusDamage(this, this.owner, 50, DEATH_MONSTER_GOROTH.m_id, this.owner); }
void gorrock7(entity this) { set_anim(this, 5, gorrock8); T_RadiusDamage(this, this.owner, 50, DEATH_MONSTER_GOROTH.m_id, this.owner); }
void gorrock6(entity this) { set_anim(this, 5, gorrock7); T_RadiusDamage(this, this.owner, 50, DEATH_MONSTER_GOROTH.m_id, this.owner); }
void gorrock5(entity this) { set_anim(this, 4, gorrock6); T_RadiusDamage(this, this.owner, 50, DEATH_MONSTER_GOROTH.m_id, this.owner); }
void gorrock4(entity this) { set_anim(this, 3, gorrock5); }
void gorrock3(entity this) { set_anim(this, 2, gorrock4); }
void gorrock2(entity this) { set_anim(this, 1, gorrock3); }
void gorrock1(entity this) { set_anim(this, 0, gorrock2); _sound(this, CH_VOICE, "goroth/gorrock.wav", 1, ATTN_NORM); }

void GorothRock(entity this)
{
	entity rock = spawn();
	set_movetype(rock, MOVETYPE_NONE);
	rock.solid = SOLID_NOT;
	_setmodel(rock, "progs/gorrock.mdl");
	rock.scale = this.scale;
	rock.owner = this;
	setsize(rock, '-48 -48 -24' * rock.scale, '48 48 192' * rock.scale);
	vector org = this.enemy.origin - '0 0 2048';
	traceline(this.enemy.origin, org, 1, this.enemy);
	org = trace_endpos;
	setorigin(rock, org);
	
	rock.nextthink = time + 1;
	setthink(rock, gorrock1);
}

void gor_magic26(entity this) { set_animofs(this, anim_goroth_magic, 26, gor_run1); }
void gor_magic25(entity this) { set_animofs(this, anim_goroth_magic, 25, gor_magic26); }
void gor_magic24(entity this) { set_animofs(this, anim_goroth_magic, 24, gor_magic25); }
void gor_magic23(entity this) { set_animofs(this, anim_goroth_magic, 23, gor_magic24); }
void gor_magic22(entity this) { set_animofs(this, anim_goroth_magic, 22, gor_magic23); }
void gor_magic21(entity this)
{
	set_animofs(this, anim_goroth_magic, 21, gor_magic22);
	this.enemy.punchangle_x = -2;
	T_RadiusDamage(this, this, 400, DEATH_MONSTER_GOROTH.m_id, this);
		
	GorothLavaSplash(this, '454 0 -40');
		
	float ang = -15;
	while(ang <= 15)
	{
		vector vec = qc_aim(this, 500);
		vec.y += ang;
		//makevectors(vec);
		GorothSmashMissile(this, vec, 31);
		ang += 5;
	}
}
void gor_magic20(entity this) { set_animofs(this, anim_goroth_magic, 20, gor_magic21); ai_charge(this, 2); }
void gor_magic19(entity this) { set_animofs(this, anim_goroth_magic, 19, gor_magic20); ai_charge(this, 2); }
void gor_magic18(entity this) { set_animofs(this, anim_goroth_magic, 18, gor_magic19); ai_charge(this, 2); }
void gor_magic17(entity this) { set_animofs(this, anim_goroth_magic, 17, gor_magic18); ai_charge(this, 2); }
void gor_magic16(entity this) { set_animofs(this, anim_goroth_magic, 16, gor_magic17); GorothRock(this); }
void gor_magic15(entity this) { set_animofs(this, anim_goroth_magic, 15, gor_magic16); }
void gor_magic14(entity this) { set_animofs(this, anim_goroth_magic, 14, gor_magic15); GorothRock(this); }
void gor_magic13(entity this) { set_animofs(this, anim_goroth_magic, 13, gor_magic14); }
void gor_magic12(entity this) { set_animofs(this, anim_goroth_magic, 12, gor_magic13); GorothRock(this); }
void gor_magic11(entity this) { set_animofs(this, anim_goroth_magic, 11, gor_magic12); }
void gor_magic10(entity this) { set_animofs(this, anim_goroth_magic, 10, gor_magic11); }
void gor_magic9(entity this) { set_animofs(this, anim_goroth_magic, 9, gor_magic10); }
void gor_magic8(entity this) { set_animofs(this, anim_goroth_magic, 8, gor_magic9); }
void gor_magic7(entity this) { set_animofs(this, anim_goroth_magic, 7, gor_magic8); }
void gor_magic6(entity this) { set_animofs(this, anim_goroth_magic, 6, gor_magic7); }
void gor_magic5(entity this) { set_animofs(this, anim_goroth_magic, 5, gor_magic6); }
void gor_magic4(entity this) { set_animofs(this, anim_goroth_magic, 4, gor_magic5); }
void gor_magic3(entity this) { set_animofs(this, anim_goroth_magic, 3, gor_magic4); }
void gor_magic2(entity this) { set_animofs(this, anim_goroth_magic, 2, gor_magic3); }
void gor_magic1(entity this)
{
	set_animofs(this, anim_goroth_magic, 1, gor_magic2);
	if(time > this.gortaunt_timer)
	{
		_sound(this, CH_VOICE, "goroth/gormagic.wav", 1, ATTN_NORM);
		this.gortaunt_timer = time + 5;
	}
}

/*
==========================
BALL
--------------------------
Goroth throws a spicy meatball and taunts the target.
==========================
*/
void gor_ball20(entity this) { set_animofs(this, anim_goroth_ball, 20, gor_run1); }
void gor_ball19(entity this) { set_animofs(this, anim_goroth_ball, 19, gor_ball20); }
void gor_ball18(entity this) { set_animofs(this, anim_goroth_ball, 18, gor_ball19); }
void gor_ball17(entity this) { set_animofs(this, anim_goroth_ball, 17, gor_ball18); }
void gor_ball16(entity this) { set_animofs(this, anim_goroth_ball, 16, gor_ball17); }
void gor_ball15(entity this) { set_animofs(this, anim_goroth_ball, 15, gor_ball16); ai_face(this);}
void gor_ball14(entity this) { set_animofs(this, anim_goroth_ball, 14, gor_ball15); ai_face(this);}
void gor_ball13(entity this)
{
	set_animofs(this, anim_goroth_ball, 13, gor_ball14);
	if(time > this.gortaunt_timer)
		GorothTaunt(this);
	ai_face(this);
}
void gor_ball12(entity this) { set_animofs(this, anim_goroth_ball, 12, gor_ball13); ai_face(this);}
void gor_ball11(entity this) { set_animofs(this, anim_goroth_ball, 11, gor_ball12); ai_face(this);}
void gor_ball10(entity this) { set_animofs(this, anim_goroth_ball, 10, gor_ball11); ai_face(this);}
void gor_ball9(entity this) { set_animofs(this, anim_goroth_ball, 9, gor_ball10); ai_face(this);}
void gor_ball8(entity this) { set_animofs(this, anim_goroth_ball, 8, gor_ball9); ai_face(this);}
void gor_ball7(entity this) { set_animofs(this, anim_goroth_ball, 7, gor_ball8); ai_face(this);}
void gor_ball6(entity this)
{
	set_animofs(this, anim_goroth_ball, 6, gor_ball7);
	ai_face(this);

	vector org = GorRotatePointYaw(this, '466 118 286',this.angles_y);
	org += this.origin;
	vector vec = normalize (this.enemy.origin - org);

	entity newmis = launch_spike(this, org, vec);
	newmis.projectiledeathtype = DEATH_MONSTER_GOROTH.m_id;
	_setmodel(newmis, "progs/gorball.mdl");
	newmis.scale = this.scale;
	newmis.avelocity = '200 100 300';
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec * (666 * newmis.scale);
	settouch(newmis, T_MissileTouch); // rocket explosion
	newmis.effects = EF_DIMLIGHT;
	_sound(this, CH_WEAPON_SINGLE, "boss1/throw.wav", 1, ATTN_NORM);
}
void gor_ball5(entity this) { set_animofs(this, anim_goroth_ball, 5, gor_ball6); ai_face(this); }
void gor_ball4(entity this) { set_animofs(this, anim_goroth_ball, 4, gor_ball5); GorothLavaSplash(this, '-88 87 430'); ai_face(this); }
void gor_ball3(entity this) { set_animofs(this, anim_goroth_ball, 3, gor_ball4); ai_face(this); }
void gor_ball2(entity this) { set_animofs(this, anim_goroth_ball, 2, gor_ball3); ai_face(this); }
void gor_ball1(entity this)
{
	set_animofs(this, anim_goroth_ball, 1, gor_ball2);
	if(time > this.gortaunt_timer)
	{
		_sound(this, CH_VOICE, "goroth/gorsmash.wav", 1, ATTN_NORM);
		this.gortaunt_timer = time + 4;
	}
}

// ATTACK =======================================================================
void GorothAttack(entity this)
{
	float r = random();
	
	if(r < 0.33)
		gor_magic1(this);
	else if(r < 0.66)
		gor_smash1(this);
	else
		gor_ball1(this);
}

// DAMAGE =======================================================================
void gor_pain(entity this, entity attacker, float damage, int deathtype)
{
	//GorothTaunt(this);
}

void gor_gib(entity this)
{
	// throw tons of meat chunks
	_sound(this, CHAN_BODY, "boss2/pop2.wav", 1, ATTN_NORM);
	vector oldo = this.origin;

	float posz = 0; // was -48
	while(posz <= 256)
	{
		float posx = 0; // was -96
		while(posx <= 512)
		{
			float posy = 0; // was -96
			while(posy <= 96)
			{
				this.origin_x = oldo.x + (posx * this.scale);
				this.origin_y = oldo.y + (posy * this.scale);
				this.origin_z = oldo.z + (posz * this.scale);

				float r = random();
				if(r < 0.3)				
					ThrowGib(this, "progs/gib1.mdl", -100);
				else if(r < 0.6)
					ThrowGib(this, "progs/gib2.mdl", -100);
				else
					ThrowGib(this, "progs/gib3.mdl", -100);
				posy += 48;
			}
			posx += 128;
		}
		posz += 128;
	}
	te_lavasplash(this.origin - '320 0 256');
	delete(this);
}

void gor_death21(entity this) { set_animofs(this, anim_goroth_death, 21, gor_gib); }
void gor_death20(entity this) { set_animofs(this, anim_goroth_death, 20, gor_death21); }
void gor_death19(entity this) { set_animofs(this, anim_goroth_death, 19, gor_death20); }
void gor_death18(entity this) { set_animofs(this, anim_goroth_death, 18, gor_death19); }
void gor_death17(entity this) { set_animofs(this, anim_goroth_death, 17, gor_death18); }
void gor_death16(entity this) { set_animofs(this, anim_goroth_death, 16, gor_death17); }
void gor_death15(entity this) { set_animofs(this, anim_goroth_death, 15, gor_death16); }
void gor_death14(entity this) { set_animofs(this, anim_goroth_death, 14, gor_death15); }
void gor_death13(entity this) { set_animofs(this, anim_goroth_death, 13, gor_death14); }
void gor_death12(entity this) { set_animofs(this, anim_goroth_death, 12, gor_death13); }
void gor_death11(entity this) { set_animofs(this, anim_goroth_death, 11, gor_death12); }
void gor_death10(entity this) { set_animofs(this, anim_goroth_death, 10, gor_death11); }
void gor_death9(entity this) { set_animofs(this, anim_goroth_death, 9, gor_death10); }
void gor_death8(entity this) { set_animofs(this, anim_goroth_death, 8, gor_death9); }
void gor_death7(entity this) { set_animofs(this, anim_goroth_death, 7, gor_death8); }
void gor_death6(entity this) { set_animofs(this, anim_goroth_death, 6, gor_death7); }
void gor_death5(entity this) { set_animofs(this, anim_goroth_death, 5, gor_death6); }
void gor_death4(entity this) { set_animofs(this, anim_goroth_death, 4, gor_death5); }
void gor_death3(entity this) { set_animofs(this, anim_goroth_death, 3, gor_death4); }
void gor_death2(entity this) { set_animofs(this, anim_goroth_death, 2, gor_death3); }
void gor_death1(entity this) { set_animofs(this, anim_goroth_death, 1, gor_death2); _sound(this, CH_VOICE, "goroth/gordie.wav", 1, ATTN_NORM); this.solid = SOLID_NOT; }

void gor_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -150)
	{
		gor_gib(this);
		return;
	}

	gor_death1(this);
}

void gor_wake(entity this, entity actor, entity trigger)
{
	_sound(this, CH_VOICE, "goroth/gorwake.wav", 1, ATTN_NORM);
	this.gortaunt_timer = time + 10;
	this.enemy = actor;
}

spawnfunc(monster_goroth) { monster_start(this, true, MON_GOROTH); }
#endif // SVQC

#ifdef SVQC
METHOD(Goroth, mr_setup, bool(Goroth this, entity actor))
{
    TC(Goroth, this);

	precache_model("progs/gorball.mdl");
	precache_model("progs/gorrock.mdl");
	
	precache_sound2("boss2/pop2.wav");
	precache_sound("weapons/rocket1i.wav");
	precache_sound("boss1/throw.wav");
	
	precache_sound("goroth/gorwake.wav");
	precache_sound("goroth/gortaunt1.wav");
	precache_sound("goroth/gortaunt2.wav");
	precache_sound("goroth/gortaunt3.wav");
	precache_sound("goroth/gordie.wav");
	precache_sound("goroth/gorsmash.wav");
	precache_sound("goroth/gormagic.wav");
	precache_sound("goroth/gorrock.wav");

    actor.health = 2000;
    if(horde_ent || actor.charmed)
    	actor.scale = 0.18;
    else if(!actor.scale)
    	actor.scale = 0.75;

	actor.th_stand = gor_stand1;
	actor.th_walk = gor_walk1;
	actor.th_run = gor_run1;
	actor.th_die = gor_die;
	actor.th_melee = GorothAttack;
	actor.th_missile = GorothAttack;
	actor.th_pain = gor_pain;
	actor.use = gor_wake;

	setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);

    return true;
}
#endif
