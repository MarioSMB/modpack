#include "volkerh.qh"

#ifdef SVQC
const int anim_volkerh_hover = 0; //'0 29 0';
const int anim_volkerh_fly = 30; //'30 49 0';
const int anim_volkerh_magica = 50; //'50 78 0';
const int anim_volkerh_magicb = 79; //'79 98 0';
const int anim_volkerh_magicc = 99; //'99 133 0';
const int anim_volkerh_death = 134; //'85 159 0';

.float volmis_t;
.float voltaunt_timer;
void vol_run1(entity this);

vector VolRotatePointYaw(entity this, vector point, float ang)
{
	point *= this.scale;
	vector vec = '0 1 0' * this.angles_y;
	makevectors(vec);
	vec = point;
	float posx = vec.x * v_forward.x - vec_y * v_forward_y;
	float posy = vec.x * v_forward.y + vec.y * v_forward.x;
	vec.x = posx;
	vec.y = posy;
	
	return vec;
}

// copied from boss.qc
void vol_face(entity this)
{
// go for another player if multi player
	if(this.enemy.health <= 0 || random() < 0.02)
	{
		this.enemy = find(this.enemy, classname, "player");
		if(!this.enemy)
			this.enemy = find(this.enemy, classname, "player");
	}
	ai_face(this);
}

// Volkerh special functions
void VolkerhTaunt(entity this)
{
	if(this.voltaunt_timer > time) 
		return;

	float r = random();
	
	if(r < 0.33)
	{
		_sound(this, CH_VOICE, "volkerh/voltaunt1.wav", 1, ATTN_NORM);
		this.voltaunt_timer = time + 12;
	}
	if(r >= 0.33 && r < 0.66)
	{
		_sound(this, CH_VOICE, "volkerh/voltaunt2.wav", 1, ATTN_NORM);
		this.voltaunt_timer = time + 8;
	}
	if(r >= 0.66)
	{
		_sound(this, CH_VOICE, "volkerh/voltaunt3.wav", 1, ATTN_NORM);
		this.voltaunt_timer = time + 8;
	}
}

void VolkerhBloodFist(entity this, vector bloodpos, float bloodsz)
{
	vector vec = VolRotatePointYaw(this, bloodpos, this.angles_y);		
	vec = this.origin + vec;
	if(bloodsz > 0)
	{
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
					particle(vec + dir * 8, dir * 32, 73, 100 * bloodsz);
					posy += 1;
				}
				posx += 1;
			}
			posz += 1;
		}
	}
	else
		particle(vec, '0 0 -32', 73, 100);
}

// Animations

void vol_stand1(entity this);
void vol_stand30(entity this) { set_animofs(this, anim_volkerh_hover, 30, vol_stand1); ai_stand(this); }
void vol_stand29(entity this) { set_animofs(this, anim_volkerh_hover, 29, vol_stand30); ai_stand(this); }
void vol_stand28(entity this) { set_animofs(this, anim_volkerh_hover, 28, vol_stand29); ai_stand(this); }
void vol_stand27(entity this) { set_animofs(this, anim_volkerh_hover, 27, vol_stand28); ai_stand(this); }
void vol_stand26(entity this) { set_animofs(this, anim_volkerh_hover, 26, vol_stand27); ai_stand(this); }
void vol_stand25(entity this) { set_animofs(this, anim_volkerh_hover, 25, vol_stand26); ai_stand(this); }
void vol_stand24(entity this) { set_animofs(this, anim_volkerh_hover, 24, vol_stand25); ai_stand(this); }
void vol_stand23(entity this) { set_animofs(this, anim_volkerh_hover, 23, vol_stand24); ai_stand(this); }
void vol_stand22(entity this) { set_animofs(this, anim_volkerh_hover, 22, vol_stand23); ai_stand(this); }
void vol_stand21(entity this) { set_animofs(this, anim_volkerh_hover, 21, vol_stand22); ai_stand(this); }
void vol_stand20(entity this) { set_animofs(this, anim_volkerh_hover, 20, vol_stand21); ai_stand(this); }
void vol_stand19(entity this) { set_animofs(this, anim_volkerh_hover, 19, vol_stand20); ai_stand(this); }
void vol_stand18(entity this) { set_animofs(this, anim_volkerh_hover, 18, vol_stand19); ai_stand(this); }
void vol_stand17(entity this) { set_animofs(this, anim_volkerh_hover, 17, vol_stand18); ai_stand(this); }
void vol_stand16(entity this) { set_animofs(this, anim_volkerh_hover, 16, vol_stand17); ai_stand(this); }
void vol_stand15(entity this) { set_animofs(this, anim_volkerh_hover, 15, vol_stand16); ai_stand(this); }
void vol_stand14(entity this) { set_animofs(this, anim_volkerh_hover, 14, vol_stand15); ai_stand(this); }
void vol_stand13(entity this) { set_animofs(this, anim_volkerh_hover, 13, vol_stand14); ai_stand(this); }
void vol_stand12(entity this) { set_animofs(this, anim_volkerh_hover, 12, vol_stand13); ai_stand(this); }
void vol_stand11(entity this) { set_animofs(this, anim_volkerh_hover, 11, vol_stand12); ai_stand(this); }
void vol_stand10(entity this) { set_animofs(this, anim_volkerh_hover, 10, vol_stand11); ai_stand(this); }
void vol_stand9(entity this) { set_animofs(this, anim_volkerh_hover, 9,	 vol_stand10); ai_stand(this); }
void vol_stand8(entity this) { set_animofs(this, anim_volkerh_hover, 8,	 vol_stand9); ai_stand(this); }
void vol_stand7(entity this) { set_animofs(this, anim_volkerh_hover, 7,	 vol_stand8); ai_stand(this); }
void vol_stand6(entity this) { set_animofs(this, anim_volkerh_hover, 6,	 vol_stand7); ai_stand(this); }
void vol_stand5(entity this) { set_animofs(this, anim_volkerh_hover, 5,	 vol_stand6); ai_stand(this); }
void vol_stand4(entity this) { set_animofs(this, anim_volkerh_hover, 4,	 vol_stand5); ai_stand(this); }
void vol_stand3(entity this) { set_animofs(this, anim_volkerh_hover, 3,	 vol_stand4); ai_stand(this); }
void vol_stand2(entity this) { set_animofs(this, anim_volkerh_hover, 2,	 vol_stand3); ai_stand(this); }
void vol_stand1(entity this) { set_animofs(this, anim_volkerh_hover, 1,	 vol_stand2); ai_stand(this); }

void vol_walk1(entity this);
void vol_walk20(entity this) { set_animofs(this, anim_volkerh_fly, 20, vol_walk1); ai_walk(this, 3); }
void vol_walk19(entity this) { set_animofs(this, anim_volkerh_fly, 19, vol_walk20); ai_walk(this, 3); }
void vol_walk18(entity this) { set_animofs(this, anim_volkerh_fly, 18, vol_walk19); ai_walk(this, 3); }
void vol_walk17(entity this) { set_animofs(this, anim_volkerh_fly, 17, vol_walk18); ai_walk(this, 3); }
void vol_walk16(entity this) { set_animofs(this, anim_volkerh_fly, 16, vol_walk17); ai_walk(this, 3); }
void vol_walk15(entity this) { set_animofs(this, anim_volkerh_fly, 15, vol_walk16); ai_walk(this, 3); }
void vol_walk14(entity this) { set_animofs(this, anim_volkerh_fly, 14, vol_walk15); ai_walk(this, 3); }
void vol_walk13(entity this) { set_animofs(this, anim_volkerh_fly, 13, vol_walk14); ai_walk(this, 3); }
void vol_walk12(entity this) { set_animofs(this, anim_volkerh_fly, 12, vol_walk13); ai_walk(this, 3); }
void vol_walk11(entity this) { set_animofs(this, anim_volkerh_fly, 11, vol_walk12); ai_walk(this, 3); }
void vol_walk10(entity this) { set_animofs(this, anim_volkerh_fly, 10, vol_walk11); ai_walk(this, 3); }
void vol_walk9(entity this) { set_animofs(this, anim_volkerh_fly, 9, vol_walk10); ai_walk(this, 3); }
void vol_walk8(entity this) { set_animofs(this, anim_volkerh_fly, 8, vol_walk9); ai_walk(this, 3); }
void vol_walk7(entity this) { set_animofs(this, anim_volkerh_fly, 7, vol_walk8); ai_walk(this, 3); }
void vol_walk6(entity this) { set_animofs(this, anim_volkerh_fly, 6, vol_walk7); ai_walk(this, 3); }
void vol_walk5(entity this) { set_animofs(this, anim_volkerh_fly, 5, vol_walk6); ai_walk(this, 3); }
void vol_walk4(entity this) { set_animofs(this, anim_volkerh_fly, 4, vol_walk5); ai_walk(this, 3); }
void vol_walk3(entity this) { set_animofs(this, anim_volkerh_fly, 3, vol_walk4); ai_walk(this, 3); }
void vol_walk2(entity this) { set_animofs(this, anim_volkerh_fly, 2, vol_walk3); ai_walk(this, 3); }
void vol_walk1(entity this) { set_animofs(this, anim_volkerh_fly, 1, vol_walk2); ai_walk(this, 3); }

void vol_run20(entity this)
{
	set_animofs(this, anim_volkerh_fly, 20, vol_run1);
	if(time > this.voltaunt_timer)
		VolkerhTaunt(this);
	ai_run(this, 7);
}
void vol_run19(entity this) { set_animofs(this, anim_volkerh_fly, 19, vol_run20); ai_run(this, 7); }
void vol_run18(entity this) { set_animofs(this, anim_volkerh_fly, 18, vol_run19); ai_run(this, 7); }
void vol_run17(entity this) { set_animofs(this, anim_volkerh_fly, 17, vol_run18); ai_run(this, 7); }
void vol_run16(entity this) { set_animofs(this, anim_volkerh_fly, 16, vol_run17); ai_run(this, 7); }
void vol_run15(entity this) { set_animofs(this, anim_volkerh_fly, 15, vol_run16); ai_run(this, 7); }
void vol_run14(entity this) { set_animofs(this, anim_volkerh_fly, 14, vol_run15); ai_run(this, 7); }
void vol_run13(entity this) { set_animofs(this, anim_volkerh_fly, 13, vol_run14); ai_run(this, 7); }
void vol_run12(entity this) { set_animofs(this, anim_volkerh_fly, 12, vol_run13); ai_run(this, 7); }
void vol_run11(entity this) { set_animofs(this, anim_volkerh_fly, 11, vol_run12); ai_run(this, 7); }
void vol_run10(entity this) { set_animofs(this, anim_volkerh_fly, 10, vol_run11); ai_run(this, 7); }
void vol_run9(entity this) { set_animofs(this, anim_volkerh_fly, 9, vol_run10); ai_run(this, 7); }
void vol_run8(entity this) { set_animofs(this, anim_volkerh_fly, 8, vol_run9); ai_run(this, 7); }
void vol_run7(entity this) { set_animofs(this, anim_volkerh_fly, 7, vol_run8); ai_run(this, 7); }
void vol_run6(entity this) { set_animofs(this, anim_volkerh_fly, 6, vol_run7); ai_run(this, 7); }
void vol_run5(entity this) { set_animofs(this, anim_volkerh_fly, 5, vol_run6); ai_run(this, 7); }
void vol_run4(entity this) { set_animofs(this, anim_volkerh_fly, 4, vol_run5); ai_run(this, 7); }
void vol_run3(entity this) { set_animofs(this, anim_volkerh_fly, 3, vol_run4); ai_run(this, 7); }
void vol_run2(entity this) { set_animofs(this, anim_volkerh_fly, 2, vol_run3); ai_run(this, 7); }
void vol_run1(entity this) { set_animofs(this, anim_volkerh_fly, 1, vol_run2); ai_run(this, 7); }

/*
=============================
MAGIC A - MISSILE
-----------------------------
Volkerh charges up some blood magic and launches dark explosive energy at his victim.
=============================
*/
void VolMisTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.health)
	{
		SpawnBlood(this.origin, this.velocity*0.2, 50, toucher);
		T_Damage(toucher, this, this, 80, DEATH_MONSTER_VOLKERH.m_id);
	}
	T_RadiusDamage(this, this.owner, 80, DEATH_MONSTER_VOLKERH.m_id, toucher);
	_sound(this, CH_WEAPON_SINGLE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	te_explosion(this.origin);

	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/s_explod.spr");
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	s_explode1(this);
}

void VolMisFly(entity this)
{
	particle(this.origin, '0 0 0', 220, 100);
	this.nextthink = time + 0.1;
	setthink(this, VolMisFly);
}

void VolkerhMissile(entity this)
{
	//org = VolRotatePointYaw('187 3 208',this.angles_y);
	vector org = VolRotatePointYaw(this, '243 4 270', this.angles_y);
	org += this.origin;
	
	// lead the player on hard mode
	vector vec;
	float t;
	if(autocvar_skill > 0)
	{
		t = vlen(this.enemy.origin - org) / 666;
		vec = this.enemy.velocity;
		vec.z = 0;
		vec = this.enemy.origin + t * vec;		
	}
	else
	{
		vec = this.enemy.origin;
	}
	vec = normalize((vec + '0 0 10') - org);
	
	this.effects |= EF_MUZZLEFLASH;	
	entity missile = spawn();
	missile.owner = this;
	_setmodel(missile, "progs/volball.mdl");
	missile.scale = this.scale;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setsize (missile, '0 0 0', '0 0 0');
	missile.origin = org;
	missile.velocity = vec * (666 * missile.scale);
	missile.avelocity = '300 300 300';
	missile.enemy = this.enemy;
	settouch(missile, VolMisTouch);
	missile.nextthink = time + 0.1;
	setthink(missile, VolMisFly);
	_sound(this, CH_WEAPON_SINGLE, "blob/death1.wav", 1, ATTN_NORM);
}

void vol_magica29(entity this) { set_animofs(this, anim_volkerh_magica, 29, vol_run1); }
void vol_magica28(entity this) { set_animofs(this, anim_volkerh_magica, 28, vol_magica29); }
void vol_magica27(entity this) { set_animofs(this, anim_volkerh_magica, 27, vol_magica28); }
void vol_magica26(entity this) { set_animofs(this, anim_volkerh_magica, 26, vol_magica27); }
void vol_magica25(entity this) { set_animofs(this, anim_volkerh_magica, 25, vol_magica26); }
void vol_magica24(entity this) { set_animofs(this, anim_volkerh_magica, 24, vol_magica25); }
void vol_magica23(entity this) { set_animofs(this, anim_volkerh_magica, 23, vol_magica24); }
void vol_magica22(entity this) { set_animofs(this, anim_volkerh_magica, 22, vol_magica23); }
void vol_magica21(entity this) { set_animofs(this, anim_volkerh_magica, 21, vol_magica22); }
// Attack frame
void vol_magica20(entity this)
{
	set_animofs(this, anim_volkerh_magica, 20, vol_magica21);
	//vec = VolRotatePointYaw('187 3 208',this.angles_y);		
	vector vec = VolRotatePointYaw(this, '243 4 270',this.angles_y);	
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
				particle(vec + dir * 8, dir * 32, 220, 100);
				posy += 1;
			}
			posx += 1;
		}
		posz += 1;
	}
	VolkerhMissile(this);
	vol_face(this);
}
void vol_magica19(entity this) { set_animofs(this, anim_volkerh_magica, 19, vol_magica20); vol_face(this); }
void vol_magica18(entity this) { set_animofs(this, anim_volkerh_magica, 18, vol_magica19); vol_face(this); }
void vol_magica17(entity this) { set_animofs(this, anim_volkerh_magica, 17, vol_magica18); vol_face(this); }
void vol_magica16(entity this) { set_animofs(this, anim_volkerh_magica, 16, vol_magica17); vol_face(this); }
// Clench fist
void vol_magica15(entity this)
{
	set_animofs(this, anim_volkerh_magica, 15, vol_magica16);
	//VolkerhBloodFist(this, '-51 -137 428', 1);
	VolkerhBloodFist(this, '-66 -178 556', 1);
	vol_face(this);
}
void vol_magica14(entity this)
{
	set_animofs(this, anim_volkerh_magica, 14, vol_magica15);
	//VolkerhBloodFist(this, '-48 -131 442', 0);
	VolkerhBloodFist(this, '-62 -170 575', 0);
	vol_face(this);
}
void vol_magica13(entity this)
{
	set_animofs(this, anim_volkerh_magica, 13, vol_magica14);
	//VolkerhBloodFist(this, '-49 -125 453', 0);
	VolkerhBloodFist(this, '-64 -163 588', 0);
	vol_face(this);
}
void vol_magica12(entity this)
{
	set_animofs(this, anim_volkerh_magica, 12, vol_magica13);
	//VolkerhBloodFist(this, '-49 -124 446', 0);
	VolkerhBloodFist(this, '-64 -161 579', 0);
	vol_face(this);
}
void vol_magica11(entity this)
{
	set_animofs(this, anim_volkerh_magica, 11, vol_magica12);
	//VolkerhBloodFist(this, '-44 -132 427', 0);
	VolkerhBloodFist(this, '-57 -177 555', 0);
	vol_face(this);
}
void vol_magica10(entity this)
{
	set_animofs(this, anim_volkerh_magica, 10, vol_magica11);
	//VolkerhBloodFist(this, '-34 -138 394', 0);
	VolkerhBloodFist(this, '-44 -179 512', 0);
	vol_face(this);
}
void vol_magica9(entity this)
{
	set_animofs(this, anim_volkerh_magica, 9, vol_magica10);
	//VolkerhBloodFist(this, '-30 -147 354', 0);
	VolkerhBloodFist(this, '-39 -188 460', 0);
	vol_face(this);
}
void vol_magica8(entity this)
{
	set_animofs(this, anim_volkerh_magica, 8, vol_magica9);
	//VolkerhBloodFist(this, '-30 -146 305', 0);
	VolkerhBloodFist(this, '-39 -187 397', 0);
	vol_face(this);
}
void vol_magica7(entity this)
{
	set_animofs(this, anim_volkerh_magica, 7, vol_magica8);
	//VolkerhBloodFist(this, '-29 -145 260', 0);
	VolkerhBloodFist(this, '-38 -186 338', 0);
	vol_face(this);
}
void vol_magica6(entity this)
{
	set_animofs(this, anim_volkerh_magica, 6, vol_magica7);
	//VolkerhBloodFist(this, '-30 -140 225', 0);
	VolkerhBloodFist(this, '-39 -182 296', 0);
	vol_face(this);
}
void vol_magica5(entity this) { set_animofs(this, anim_volkerh_magica, 5, vol_magica6); vol_face(this); }
void vol_magica4(entity this) { set_animofs(this, anim_volkerh_magica, 4, vol_magica5); vol_face(this); }
void vol_magica3(entity this) { set_animofs(this, anim_volkerh_magica, 3, vol_magica4); vol_face(this); }
void vol_magica2(entity this) { set_animofs(this, anim_volkerh_magica, 2, vol_magica3); vol_face(this); }
void vol_magica1(entity this)
{
	set_animofs(this, anim_volkerh_magica, 1, vol_magica2);
	if(time > this.voltaunt_timer)
	{
		_sound(this, CH_VOICE, "volkerh/volmag1.wav", 1, ATTN_NORM);
		this.voltaunt_timer = time + 4;
	}
	vol_face(this);
}

/*
==============================
MAGIC B - LIGHTNING
------------------------------
Volkerh clasps his hands together and shoots a bolt of lightning.
==============================
*/
void VolkerhLightning(entity this)
{
	this.effects |= EF_MUZZLEFLASH;

	vol_face(this);

	//org = VolRotatePointYaw('229 0 246',this.angles_y);
	vector org = VolRotatePointYaw(this, '297 0 320', this.angles_y);
	org += this.origin;

	vector dir = normalize((this.enemy.origin + '0 0 16') - org);

	traceline(org, org + dir * 4000, true, this);

	SendCSQCLightningBeam(org, trace_endpos);

	LightningDamage(org, trace_endpos, this, 30, DEATH_MONSTER_VOLKERH.m_id);
}

// Attack End
void vol_magicb20(entity this) { set_animofs(this, anim_volkerh_magicb, 20, vol_run1); }
void vol_magicb19(entity this) { set_animofs(this, anim_volkerh_magicb, 19, vol_magicb20); }
void vol_magicb18(entity this) { set_animofs(this, anim_volkerh_magicb, 18, vol_magicb19); }
void vol_magicb17(entity this) { set_animofs(this, anim_volkerh_magicb, 17, vol_magicb18); }
void vol_magicb16(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 16, vol_magicb17);
	VolkerhLightning(this);
}
void vol_magicb15(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 15, vol_magicb16);
	VolkerhLightning(this);
}
// Attack Start
void vol_magicb14(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 14, vol_magicb15);
	VolkerhLightning(this);
	_sound(this, CH_WEAPON_SINGLE, "shambler/sboom.wav", 1, ATTN_NORM);
}
void vol_magicb13(entity this) { set_animofs(this, anim_volkerh_magicb, 13, vol_magicb14); vol_face(this); }
void vol_magicb12(entity this) { set_animofs(this, anim_volkerh_magicb, 12, vol_magicb13); vol_face(this); }
void vol_magicb11(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 11, vol_magicb12);
	// VolkerhBloodFist(this, '108 0 285', 1);
	// VolkerhBloodFist(this, '116 0 303', 1);
	VolkerhBloodFist(this, '140 0 371', 1);
	VolkerhBloodFist(this, '151 0 394', 1);
	vol_face(this);
}
void vol_magicb10(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 10, vol_magicb11);
	// VolkerhBloodFist(this, '88 -7 281', 0);
	// VolkerhBloodFist(this, '88 5 283', 0);
	VolkerhBloodFist(this, '114 -9 365', 0);
	VolkerhBloodFist(this, '114 7 368', 0);
	vol_face(this);
}
void vol_magicb9(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 9, vol_magicb10);
	// VolkerhBloodFist(this, '80 -19 277', 0);
	// VolkerhBloodFist(this, '79 10 271', 0);
	VolkerhBloodFist(this, '104 -25 360', 0);
	VolkerhBloodFist(this, '103 13 352', 0);
	vol_face(this);
}
void vol_magicb8(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 8, vol_magicb9);
	// VolkerhBloodFist(this, '61 -33 265', 0);
	// VolkerhBloodFist(this, '63 26 266', 0);
	VolkerhBloodFist(this, '79 -43 345', 0);
	VolkerhBloodFist(this, '82 34 346', 0);
	vol_face(this);
}
void vol_magicb7(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 7, vol_magicb8);
	// VolkerhBloodFist(this, '33 -48 245', 0);
	// VolkerhBloodFist(this, '34 43 256', 0);
	VolkerhBloodFist(this, '43 -62 319', 0);
	VolkerhBloodFist(this, '44 56 333', 0);
	vol_face(this);
}
void vol_magicb6(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 6, vol_magicb7);
	// VolkerhBloodFist(this, '0 -61 247', 0);
	// VolkerhBloodFist(this, '10 58 256', 0);
	VolkerhBloodFist(this, '0 -79 321', 0);
	VolkerhBloodFist(this, '13 75 333', 0);
	vol_face(this);
}
void vol_magicb5(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 5, vol_magicb6);
	// VolkerhBloodFist(this, '-2 -76 240', 0);
	// VolkerhBloodFist(this, '3 74 252', 0);
	VolkerhBloodFist(this, '-3 -99 312', 0);
	VolkerhBloodFist(this, '4 96 328', 0);
	vol_face(this);
}
void vol_magicb4(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 4, vol_magicb5);
	// VolkerhBloodFist(this, '-2 -90 225', 0);
	// VolkerhBloodFist(this, '3 91 239', 0);
	VolkerhBloodFist(this, '-3 -117 296', 0);
	VolkerhBloodFist(this, '4 118 311', 0);
	vol_face(this);
}
void vol_magicb3(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 3, vol_magicb4);
	// VolkerhBloodFist(this, '-2 -100 206', 0);
	// VolkerhBloodFist(this, '2 106 222', 0);
	VolkerhBloodFist(this, '-2 -100 206', 0);
	VolkerhBloodFist(this, '2 106 222', 0);
	vol_face(this);
}
void vol_magicb2(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 2, vol_magicb3);
	// VolkerhBloodFist(this, '-3 -111 189', 0);
	// VolkerhBloodFist(this, '3 116 216', 0);
	VolkerhBloodFist(this, '-4 -144 246', 0);
	VolkerhBloodFist(this, '4 150 281', 0);
	vol_face(this);
}
void vol_magicb1(entity this)
{
	set_animofs(this, anim_volkerh_magicb, 1, vol_magicb2);
	if(time > this.voltaunt_timer)
	{
		_sound(this, CH_VOICE, "volkerh/volmag2.wav", 1, ATTN_NORM);
		this.voltaunt_timer = time + 4;
	}
	// VolkerhBloodFist(this, '7 -116 186', 0);
	// VolkerhBloodFist(this, '1 129 202', 0);
	VolkerhBloodFist(this, '9 -150 242', 0);
	VolkerhBloodFist(this, '1 168 267', 0);
	vol_face(this);
}

/*
======================
MAGIC C
----------------------
Volkerh raises his hands and blood fountains rise up,
damaging the target and knocking them into the air.
======================
*/

void VolSpireTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	
	vector dir = '0 0 1';
	
	if(toucher.health)
	{
		T_Damage(toucher, this, this.owner, 30, DEATH_MONSTER_VOLKERH.m_id);
		toucher.velocity += dir * 333;
		UNSET_ONGROUND(toucher);
		particle(toucher.origin, toucher.velocity, 73, 100);
	}
	settouch(this, func_null);
}

void volspire16(entity this) { delete(this); }
void volspire15(entity this) { set_anim(this, 14, volspire16); }
void volspire14(entity this) { set_anim(this, 13, volspire15); }
void volspire13(entity this) { set_anim(this, 12, volspire14); }
void volspire12(entity this) { set_anim(this, 11, volspire13); }
void volspire11(entity this) { set_anim(this, 10, volspire12); }
void volspire10(entity this) { set_anim(this, 9, volspire11); }
void volspire9(entity this) { set_anim(this, 8, volspire10); }
void volspire8(entity this) { set_anim(this, 7, volspire9); }
void volspire7(entity this) { set_anim(this, 6, volspire8); }
void volspire6(entity this) { set_anim(this, 5, volspire7); }
void volspire5(entity this) { set_anim(this, 4, volspire6); }
void volspire4(entity this) { set_anim(this, 3, volspire5); settouch(this, VolSpireTouch); }
void volspire3(entity this) { set_anim(this, 2, volspire4); }
void volspire2(entity this) { set_anim(this, 1, volspire3); }
void volspire1(entity this) { set_anim(this, 0, volspire2); }

void VolkerhBloodspire(entity this)
{
	entity spire = spawn();
	set_movetype(spire, MOVETYPE_NONE);
	spire.solid = SOLID_TRIGGER;
	_setmodel(spire, "progs/volspire.mdl");
	spire.scale = this.scale;
	spire.owner = this;
	setsize(spire, '-32 -32 -32' * spire.scale, '32 32 256' * spire.scale);
	setorigin(spire, this.enemy.origin);
	particle(spire.origin + '0 0 24', '0 0 0', 73, 100);
	_sound(spire, CH_WEAPON_SINGLE, "player/inlava.wav", 1, ATTN_NORM);
	spire.nextthink = time;
	setthink(spire, volspire1);
}

void vol_magicc35(entity this) { set_animofs(this, anim_volkerh_magicc, 35, vol_run1); }
void vol_magicc34(entity this) { set_animofs(this, anim_volkerh_magicc, 34, vol_magicc35); }
void vol_magicc33(entity this) { set_animofs(this, anim_volkerh_magicc, 33, vol_magicc34); }
void vol_magicc32(entity this) { set_animofs(this, anim_volkerh_magicc, 32, vol_magicc33); }
void vol_magicc31(entity this) { set_animofs(this, anim_volkerh_magicc, 31, vol_magicc32); }
void vol_magicc30(entity this) { set_animofs(this, anim_volkerh_magicc, 30, vol_magicc31); }
void vol_magicc29(entity this) { set_animofs(this, anim_volkerh_magicc, 29, vol_magicc30); }
void vol_magicc28(entity this) { set_animofs(this, anim_volkerh_magicc, 28, vol_magicc29); }
void vol_magicc27(entity this) { set_animofs(this, anim_volkerh_magicc, 27, vol_magicc28); }
void vol_magicc26(entity this) { set_animofs(this, anim_volkerh_magicc, 26, vol_magicc27); }
void vol_magicc25(entity this) { set_animofs(this, anim_volkerh_magicc, 25, vol_magicc26); VolkerhBloodspire(this); }
void vol_magicc24(entity this) { set_animofs(this, anim_volkerh_magicc, 24, vol_magicc25); }
void vol_magicc23(entity this) { set_animofs(this, anim_volkerh_magicc, 23, vol_magicc24); VolkerhBloodspire(this); }
void vol_magicc22(entity this) { set_animofs(this, anim_volkerh_magicc, 22, vol_magicc23); }
void vol_magicc21(entity this) { set_animofs(this, anim_volkerh_magicc, 21, vol_magicc22); VolkerhBloodspire(this); }
void vol_magicc20(entity this) { set_animofs(this, anim_volkerh_magicc, 20, vol_magicc21); }
void vol_magicc19(entity this) { set_animofs(this, anim_volkerh_magicc, 19, vol_magicc20); VolkerhBloodspire(this); }
void vol_magicc18(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 18, vol_magicc19);
	VolkerhBloodFist(this, '48 -283 465', 0.5);
	VolkerhBloodFist(this, '48 277 472', 0.5);
}
void vol_magicc17(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 17, vol_magicc18);
	VolkerhBloodFist(this, '130 -139 410', 0);
	VolkerhBloodFist(this, '126 137 407', 0);
}
void vol_magicc16(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 16, vol_magicc17);
	VolkerhBloodFist(this, '178 -44 346', 0);
	VolkerhBloodFist(this, '174 48 335', 0);
}
void vol_magicc15(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 15, vol_magicc16);
	VolkerhBloodFist(this, '166 -39 285', 0);
	VolkerhBloodFist(this, '172 38 280', 0);
}
void vol_magicc14(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 14, vol_magicc15);
	VolkerhBloodFist(this, '164 -35 226', 0);
	VolkerhBloodFist(this, '168 27 220', 0);
}
void vol_magicc13(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 13, vol_magicc14);
	VolkerhBloodFist(this, '148 -38 178', 0);
	VolkerhBloodFist(this, '151 29 174', 0);
}
void vol_magicc12(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 12, vol_magicc13);
	VolkerhBloodFist(this, '125 -42 143', 0);
	VolkerhBloodFist(this, '133 34 143', 0);
}
void vol_magicc11(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 11, vol_magicc12);
	VolkerhBloodFist(this, '96 -44 126', 0);
	VolkerhBloodFist(this, '101 42 126', 0);
}
void vol_magicc10(entity this) { set_animofs(this, anim_volkerh_magicc, 10, vol_magicc11); }
void vol_magicc9(entity this) { set_animofs(this, anim_volkerh_magicc, 9, vol_magicc10); }
void vol_magicc8(entity this) { set_animofs(this, anim_volkerh_magicc, 8, vol_magicc9); }
void vol_magicc7(entity this) { set_animofs(this, anim_volkerh_magicc, 7, vol_magicc8); }
void vol_magicc6(entity this) { set_animofs(this, anim_volkerh_magicc, 6, vol_magicc7); }
void vol_magicc5(entity this) { set_animofs(this, anim_volkerh_magicc, 5, vol_magicc6); }
void vol_magicc4(entity this) { set_animofs(this, anim_volkerh_magicc, 4, vol_magicc5); }
void vol_magicc3(entity this) { set_animofs(this, anim_volkerh_magicc, 3, vol_magicc4); }
void vol_magicc2(entity this) { set_animofs(this, anim_volkerh_magicc, 2, vol_magicc3); }
void vol_magicc1(entity this)
{
	set_animofs(this, anim_volkerh_magicc, 1, vol_magicc2);
	if(time > this.voltaunt_timer)
	{
		_sound(this, CH_VOICE, "volkerh/volmag3.wav", 1, ATTN_NORM);
		this.voltaunt_timer = time + 5.5;
	}
}

// ATTACK =======================================================================
void VolkerhAttack(entity this)
{
	float r = random();
	
	if(r < 0.33)
		vol_magicc1(this);
	else if(r < 0.66)
		vol_magicb1(this);
	else
		vol_magica1(this);
}

// DAMAGE =======================================================================
void vol_pain(entity this, entity attacker, float damage, int deathtype)
{
	// no action?
}

void vol_gib(entity this)
{
	// throw tons of meat chunks
	_sound(this, CHAN_BODY, "boss2/pop2.wav", 1, ATTN_NORM);
	
	vector oldo = this.origin;

	float posz = 78; // was 0
	while(posz <= 390)
	{
		float posx = 0; // was -62
		while(posx <= 62)
		{
			float posy = 0; // was -62
			while(posy <= 62)
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
				posy += 31;
			}
			posx += 31;
		}
		posz += 78;
	}
	delete(this);
}

void vol_death26(entity this) { set_animofs(this, anim_volkerh_death, 26, vol_gib); }
void vol_death25(entity this) { set_animofs(this, anim_volkerh_death, 25, vol_death26); }
void vol_death24(entity this) { set_animofs(this, anim_volkerh_death, 24, vol_death25); }
void vol_death23(entity this) { set_animofs(this, anim_volkerh_death, 23, vol_death24); }
void vol_death22(entity this)
{
	set_animofs(this, anim_volkerh_death, 22, vol_death23);
	VolkerhBloodFist(this, '143 0 373', 1);
	VolkerhBloodFist(this, '87 0 299', 1);
}
void vol_death21(entity this) { set_animofs(this, anim_volkerh_death, 21, vol_death22); }
void vol_death20(entity this) { set_animofs(this, anim_volkerh_death, 20, vol_death21); }
void vol_death19(entity this) { set_animofs(this, anim_volkerh_death, 19, vol_death20); }
void vol_death18(entity this) { set_animofs(this, anim_volkerh_death, 18, vol_death19); }
void vol_death17(entity this) { set_animofs(this, anim_volkerh_death, 17, vol_death18); }
void vol_death16(entity this) { set_animofs(this, anim_volkerh_death, 16, vol_death17); }
void vol_death15(entity this) { set_animofs(this, anim_volkerh_death, 15, vol_death16); }
void vol_death14(entity this) { set_animofs(this, anim_volkerh_death, 14, vol_death15); }
void vol_death13(entity this) { set_animofs(this, anim_volkerh_death, 13, vol_death14); }
void vol_death12(entity this) { set_animofs(this, anim_volkerh_death, 12, vol_death13); }
void vol_death11(entity this) { set_animofs(this, anim_volkerh_death, 11, vol_death12); }
void vol_death10(entity this) { set_animofs(this, anim_volkerh_death, 10, vol_death11); }
void vol_death9(entity this) { set_animofs(this, anim_volkerh_death, 9, vol_death10); }
void vol_death8(entity this) { set_animofs(this, anim_volkerh_death, 8, vol_death9); }
void vol_death7(entity this) { set_animofs(this, anim_volkerh_death, 7, vol_death8); }
void vol_death6(entity this) { set_animofs(this, anim_volkerh_death, 6, vol_death7); }
void vol_death5(entity this) { set_animofs(this, anim_volkerh_death, 5, vol_death6); }
void vol_death4(entity this) { set_animofs(this, anim_volkerh_death, 4, vol_death5); }
void vol_death3(entity this) { set_animofs(this, anim_volkerh_death, 3, vol_death4); }
void vol_death2(entity this) { set_animofs(this, anim_volkerh_death, 2, vol_death3); }
void vol_death1(entity this, entity inflictor, entity attacker, int deathtype) { set_animofs(this, anim_volkerh_death, 1, vol_death2); _sound(this, CH_VOICE, "volkerh/voldie.wav", 1, ATTN_NORM); this.solid = SOLID_NOT; }

void vol_wake(entity this, entity actor, entity trigger)
{
	_sound(this, CH_VOICE, "volkerh/volwake.wav", 1, ATTN_NORM);
	this.voltaunt_timer = time + 12;
	this.enemy = actor;
}

spawnfunc(monster_volkerh) { monster_start(this, true, MON_VOLKERH); }
#endif // SVQC

#ifdef SVQC
METHOD(Volkerh, mr_setup, bool(Volkerh this, entity actor))
{
    TC(Volkerh, this);

	precache_model("progs/volball.mdl");
	precache_model("progs/volspire.mdl");
	
	precache_sound2("blob/death1.wav");
	precache_sound("shambler/sboom.wav");
	precache_sound("player/inlava.wav");
	precache_sound2("boss2/pop2.wav");
	
	precache_sound("volkerh/volwake.wav");
	precache_sound("volkerh/voltaunt1.wav");
	precache_sound("volkerh/voltaunt2.wav");
	precache_sound("volkerh/voltaunt3.wav");
	precache_sound("volkerh/volmag1.wav");
	precache_sound("volkerh/volmag2.wav");
	precache_sound("volkerh/volmag3.wav");
	precache_sound("volkerh/voldie.wav");

    actor.health = 3000;
    if(horde_ent || actor.charmed)
    	actor.scale = 0.2;
    else
    	actor.scale = 0.75;

	actor.th_stand = vol_stand1;
	actor.th_walk = vol_walk1;
	actor.th_run = vol_run1;
	actor.th_die = vol_death1;
	//actor.th_melee = VolkerhAttack;
	actor.th_missile = VolkerhAttack;
	actor.th_pain = vol_pain;
	actor.use = vol_wake;

	setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);

    return true;
}
#endif
