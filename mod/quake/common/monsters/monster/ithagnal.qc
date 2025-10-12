#include "ithagnal.qh"

#include "vore.qh"
#include "legond.qh"
#include "zombie.qh"

#ifdef SVQC
const int anim_ithagnal_stand = 0; //'0 29 0'
const int anim_ithagnal_walk = 30; //'30 37 0'
const int anim_ithagnal_wallwalk = 38; //'38 45 0'
const int anim_ithagnal_ceilwalk = 46; //'46 53 0'
const int anim_ithagnal_ceilstand = 54; //'54 83 0'
const int anim_ithagnal_voreball = 84; //'84 107 0'
const int anim_ithagnal_vomit = 108; //'108 128 0'
const int anim_ithagnal_teletouch = 129; //'129 138 0'
const int anim_ithagnal_telethrow = 139; //'139 148 0'
const int anim_ithagnal_death = 149; //'149 184 0'

const float ATTN_ITHAGNAL = 0.2;

.vector ith_offset;
.float qccTauntTimer;

vector QCC_RotatePointYaw(vector point, float ang)
{
	vector vec = '0 1 0' * ang;
	makevectors(vec);
	vec = point;
	float dx = vec.x * v_forward.x - vec.y * v_forward.y;
	float dy = vec.x * v_forward.y + vec.y * v_forward.x;
	vec.x = dx;
	vec.y = dy;
	
	return vec;
}

// Ithagnal special functions
void IthagnalTaunt(entity this)
{
	if(this.qccTauntTimer > time) 
		return;

	float r = random();	
	if(r < 0.33)
	{
		_sound(this, CH_VOICE, "ithagnal/ithtaunt1.wav", 1, ATTN_ITHAGNAL);
		this.qccTauntTimer = time + 11;
	}
	if(r >= 0.33 && r < 0.66)
	{
		_sound(this, CH_VOICE, "ithagnal/ithtaunt2.wav", 1, ATTN_ITHAGNAL);
		this.qccTauntTimer = time + 9;
	}
	if(r >= 0.66)
	{
		_sound(this, CH_VOICE, "ithagnal/ithtaunt3.wav", 1, ATTN_ITHAGNAL);
		this.qccTauntTimer = time + 10;
	}
}

void IthagnalStep(entity this)
{
	_sound(this, CH_VOICE, "hknight/hit.wav", 0.7, ATTN_ITHAGNAL);
}

void IthagnalMagicHand(entity this, vector pos, float sz)
{
	float dx, dy, dz;
	pos *= this.scale;
		
	vector vec = QCC_RotatePointYaw(pos, this.angles_y);		
	vec = this.origin + vec;
	if(sz > 0)
	{
		dz = -1;
		while(dz <= 1)
		{
			dx = -1;
			while(dx <= 1)
			{
				dy = -1;
				while(dy <= 1)
				{
					vector dir;
					dir.x = dx;
					dir.y = dy;
					dir.z = dz;
					dir = normalize(dir);
					particle(vec + dir * 8, dir * 32, 155, 100 * sz);
					dy += 1;
				}
				dx += 1;
			}
			dz += 1;
		}
	}
	else
		particle(vec, '0 0 -32', 148, 100);
}

/*================
	MOVEMENT
==================*/
void ith_stand_loop(entity this)
{
	this.nextthink = time + FRAME_TIME;
	setthink(this, ith_stand_loop);
	this.frame = this.walkframe;
	if(this.walkframe < anim_ithagnal_stand + 29) // stand30
		this.walkframe += 1;
	else
	{
		this.walkframe = anim_ithagnal_stand;
		if(random() < 0.2)
			_sound(this, CH_VOICE, "ithagnal/ithidle.wav", 1, ATTN_ITHAGNAL);
	}
	ai_stand(this);
}

void ith_stand(entity this)
{
	this.walkframe = anim_ithagnal_stand;
	ith_stand_loop(this);
}

void ith_walk_loop(entity this)
{
	this.nextthink = time + FRAME_TIME;
	setthink(this, ith_walk_loop);
	this.frame = this.walkframe;
	if(this.walkframe < anim_ithagnal_walk + 7) // walk8
	{
		this.walkframe += 1;
		if(this.walkframe % 2)
			IthagnalStep(this);
	}
	else
	{
		this.walkframe = anim_ithagnal_walk;
		if(random() < 0.2)
			_sound(this, CH_VOICE, "ithagnal/ithidle.wav", 1, ATTN_ITHAGNAL);
	}
	ai_walk(this, 8);
}

void ith_walk(entity this)
{
	this.walkframe = anim_ithagnal_walk;
	ith_walk_loop(this);
}

void ith_run_loop(entity this)
{
	this.nextthink = time + FRAME_TIME;
	setthink(this, ith_run_loop);
	this.frame = this.walkframe;
	if(this.walkframe < anim_ithagnal_walk + 7) // walk8
	{
		this.walkframe += 1;
		if(this.walkframe % 2)
			IthagnalStep(this);
	}
	else
	{
		this.walkframe = anim_ithagnal_walk;
		//IthagnalTaunt(this);
	}
	ai_run(this, 20);
}

void ith_run(entity this)
{
	this.walkframe = anim_ithagnal_walk;
	ith_run_loop(this);
}

/*================
	COMBAT
==================*/
void ith_wake(entity this, entity actor, entity trigger)
{
	_sound(this, CH_VOICE, "ithagnal/ithwake.wav", 1, ATTN_ITHAGNAL);
	this.qccTauntTimer = time + 10;
}

// VORE BARRAGE ======================================================================
// NOTE: references vore code
void ShalMissileTouch(entity this, entity toucher);
void ShalHome(entity this);
void IthMissile(entity this, vector pos)
{
	pos *= this.scale;

	vector org = QCC_RotatePointYaw(pos, this.angles_y);		
	org = this.origin + org;

	vector dir = normalize((this.enemy.origin + '0 0 10') - org);

	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "shalrath/attack2.wav", 1, ATTN_ITHAGNAL);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "vore_ball";
	missile.owner = this;
	missile.clipgroup = this.clipgroup;
	missile.projectiledeathtype = DEATH_MONSTER_ITHAGNAL.m_id;

	missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	//_setmodel(missile, "progs/v_spike.mdl");

	setsize(missile, '0 0 0', '0 0 0');		

	setorigin(missile, org);
	missile.velocity = dir * 200;
	missile.count = time + 7;
	missile.avelocity = '300 300 300';
	missile.nextthink = time;
	setthink(missile, ShalHome);
	missile.enemy = this.enemy;
	settouch(missile, ShalMissileTouch);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, false, PROJECTILE_VORE_SPIKE, true);

	// perform an immediate update (TODO: why doesn't linking it do this anyway?)
	UpdateCSQCProjectile(this);
}

// Ithagnal raises her hand to charge several voreballs, then launches them
void ith_voreball24(entity this) { set_animofs(this, anim_ithagnal_voreball, 24, ith_run); this.attack_finished = time + 1.5; IthagnalTaunt(this); }
void ith_voreball23(entity this) { set_animofs(this, anim_ithagnal_voreball, 23, ith_voreball24); }
void ith_voreball22(entity this) { set_animofs(this, anim_ithagnal_voreball, 22, ith_voreball23); }
void ith_voreball21(entity this) { set_animofs(this, anim_ithagnal_voreball, 21, ith_voreball22); }
void ith_voreball20(entity this) { set_animofs(this, anim_ithagnal_voreball, 20, ith_voreball21); }
void ith_voreball19(entity this) { set_animofs(this, anim_ithagnal_voreball, 19, ith_voreball20); }
void ith_voreball18(entity this) { set_animofs(this, anim_ithagnal_voreball, 18, ith_voreball19); }
void ith_voreball17(entity this) { set_animofs(this, anim_ithagnal_voreball, 17, ith_voreball18); }
void ith_voreball16(entity this) { set_animofs(this, anim_ithagnal_voreball, 16, ith_voreball17); IthagnalMagicHand(this, '357 47 195', 0); }

void ith_voreball_atk1c(entity this) { set_animofs(this, anim_ithagnal_voreball, 15, ith_voreball16); IthagnalMagicHand(this, '330 37 208', 0); IthMissile(this, '330 37 208'); }
void ith_voreball_atk1b(entity this) { set_animofs(this, anim_ithagnal_voreball, 14, ith_voreball_atk1c); IthagnalMagicHand(this, '241 -145 451', 0); IthMissile(this, '241 -145 451'); }
void ith_voreball_atk1a(entity this) { set_animofs(this, anim_ithagnal_voreball, 13, ith_voreball_atk1b); IthagnalMagicHand(this, '-63 -76 741', 0); IthMissile(this, '-63 -76 741'); }

void ith_voreball12(entity this) { set_animofs(this, anim_ithagnal_voreball, 12, ith_voreball_atk1a); IthagnalMagicHand(this, '-56 -76 742', 0); ai_face(this); }
void ith_voreball11(entity this) { set_animofs(this, anim_ithagnal_voreball, 11, ith_voreball12); IthagnalMagicHand(this, '-42 -76 742', 0); ai_face(this); }
void ith_voreball10(entity this) { set_animofs(this, anim_ithagnal_voreball, 10, ith_voreball11); IthagnalMagicHand(this, '-37 -83 745', 0); ai_face(this); }
void ith_voreball9(entity this) { set_animofs(this, anim_ithagnal_voreball, 9, ith_voreball10); IthagnalMagicHand(this, '-18 -83 726', 0); ai_face(this); }
void ith_voreball8(entity this) { set_animofs(this, anim_ithagnal_voreball, 8, ith_voreball9); IthagnalMagicHand(this, '-6 -93 703', 0); ai_face(this); }
void ith_voreball7(entity this) { set_animofs(this, anim_ithagnal_voreball, 7, ith_voreball8); IthagnalMagicHand(this, '0 -98 663', 0); ai_face(this); }
void ith_voreball6(entity this) { set_animofs(this, anim_ithagnal_voreball, 6, ith_voreball7); IthagnalMagicHand(this, '20 -101 634', 0); ai_face(this); }
void ith_voreball5(entity this) { set_animofs(this, anim_ithagnal_voreball, 5, ith_voreball6); IthagnalMagicHand(this, '58 -123 597', 0); ai_face(this); }
void ith_voreball4(entity this) { set_animofs(this, anim_ithagnal_voreball, 4, ith_voreball5); IthagnalMagicHand(this, '94 -139 524', 0); ai_face(this); }
void ith_voreball3(entity this) { set_animofs(this, anim_ithagnal_voreball, 3, ith_voreball4); IthagnalMagicHand(this, '125 -150 452', 0); ai_face(this); }
void ith_voreball2(entity this) { set_animofs(this, anim_ithagnal_voreball, 2, ith_voreball3); IthagnalMagicHand(this, '154 -150 376', 0); ai_face(this); }

void ith_voreball1(entity this)
{
	set_animofs(this, anim_ithagnal_voreball, 1, ith_voreball2);
	IthagnalMagicHand(this, '170 143 304', 0); 
	ai_face(this);
	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "ithagnal/ithball1.wav", 1, ATTN_ITHAGNAL);
	else
		_sound(this, CH_WEAPON_SINGLE, "ithagnal/ithball2.wav", 1, ATTN_ITHAGNAL);
}

// VOMIT ======================================================================
void IthVomitAnim2(entity this)
{
	this.nextthink = time + FRAME_TIME;
	setthink(this, IthVomitAnim2);
	this.walkframe += 1;
	if(this.walkframe < 30)
	{
		this.frame = this.walkframe;
		float ofs = (30 - this.frame) / 30;
		setsize(this, '-80 -80 0' * ofs, '80 80 4' * ofs);
		setorigin(this, this.origin);
	}
	else
		delete(this);
}

void IthVomitAnim1(entity this)
{
	this.nextthink = time + FRAME_TIME;
	setthink(this, IthVomitAnim1);
	this.walkframe -= 1;
	if(this.walkframe < 0)
	{
		setthink(this, IthVomitAnim2);
		this.nextthink = time + 15;
	}
	else
	{
		this.frame = this.walkframe;
		float ofs = (30 - this.frame) / 30;
		setsize(this, '-80 -80 0' * ofs, '80 80 4' * ofs);
		setorigin(this, this.origin);
	}
}

void Ith_AcidPoolTouch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER || toucher.health < 1 || toucher.takedamage == DAMAGE_NO || !Damage_ValidTarget(toucher, this.owner))
		return;
	if(toucher.m_champion == CHAMPION_Sorlag)
		return; // special clause, for obvious reasons
	if(!Damage_ValidTarget(toucher, this.owner))
		return;

	float poisontime = 7;
	float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, toucher);
	if((time + poisontime) > curtime)
		StatusEffects_apply(STATUSEFFECT_Poisoned, toucher, time + poisontime, 0);
}

void IthVomitTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
		
	if(pointcontents(this.origin) < CONTENT_WATER)
	{
		delete(this);
		return;
	}

	particle(this.origin, '0 0 0', 57, 50);
	_sound(this, CH_WEAPON_SINGLE, "blob/land1.wav", 1, ATTN_NORM);

	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 100 * this.owner.scale, this.projectiledeathtype);
		return;
	}

	// create Vomit Pool
	vector vec = this.origin - normalize(this.velocity);
	traceline(vec, vec + normalize(this.velocity) * 16, false, this);
	if(trace_fraction < 1)
	{
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_TRIGGER;
		_setmodel(this, "progs/ithvomit2.mdl");
		setsize(this, '-80 -80 0', '80 80 4');
		setorigin(this, trace_endpos);

		vec = trace_plane_normal;
		this.angles = vectoangles(vec);
		this.angles_x -= 90;
		
		settouch(this, Ith_AcidPoolTouch);
		this.frame = 20;
		this.nextthink = time + 0.1;
		setthink(this, IthVomitAnim1);
	}    
}

void Ith_AcidSpitAnim(entity this)
{
	this.nextthink = time + FRAME_TIME;
	setthink(this, Ith_AcidSpitAnim);
    particle(this.origin, '0 0 0', 57, 10);
    this.walkframe += 1;
    if(this.walkframe < 5)
        this.walkframe = 0;
    this.frame = this.walkframe;
    if(this.velocity == '0 0 0')
        delete(this);
}

void IthVomit(entity this, vector pos)
{
	pos *= this.scale;

	vector org = QCC_RotatePointYaw(pos, this.angles_y);
	org = org + this.origin;
	fixedmakevectors(this.angles);
	
	entity vomit = spawn();
	vomit.flags = FL_PROJECTILE;
	vomit.classname = "acidspit";
	_setmodel(vomit, "progs/ithvomit.mdl");
	vomit.owner = this;
	set_movetype(vomit, MOVETYPE_TOSS);
	vomit.clipgroup = this.clipgroup;
	vomit.projectiledeathtype = DEATH_MONSTER_ITHAGNAL.m_id;
	vomit.solid = SOLID_BBOX;
	vomit.poisonous = true;
	settouch(vomit, IthVomitTouch);

	vomit.velocity = normalize(this.enemy.origin - org);
	vomit.velocity *= 200;
	vomit.velocity_x += crandom() * 200;
	vomit.velocity_y += crandom() * 200;
	vomit.velocity_z = -200;

	vomit.avelocity = '300 300 300';
	vomit.angles = vectoangles(vomit.velocity);	
	setsize(vomit, '0 0 0', '0 0 0');		
	setorigin(vomit, org);

	setthink(vomit, Ith_AcidSpitAnim);
	vomit.nextthink = time + 0.1;

	IL_PUSH(g_projectiles, vomit);
}

// Ithagnal vomits corrosive bile across the floor, don't step in it!
void ith_vomit20(entity this) { set_animofs(this, anim_ithagnal_vomit, 20, ith_run); this.attack_finished = time + 1.5; IthagnalTaunt(this); }
void ith_vomit19(entity this) { set_animofs(this, anim_ithagnal_vomit, 19, ith_vomit20); ai_face(this); }
void ith_vomit18(entity this) { set_animofs(this, anim_ithagnal_vomit, 18, ith_vomit19); ai_face(this); }
void ith_vomit17(entity this) { set_animofs(this, anim_ithagnal_vomit, 17, ith_vomit18); ai_face(this); }
void ith_vomit16(entity this) { set_animofs(this, anim_ithagnal_vomit, 16, ith_vomit17); ai_face(this); }
void ith_vomit15(entity this) { set_animofs(this, anim_ithagnal_vomit, 15, ith_vomit16); ai_face(this); IthVomit(this, '159 0 307'); }
void ith_vomit14(entity this) { set_animofs(this, anim_ithagnal_vomit, 14, ith_vomit15); ai_face(this); }
void ith_vomit13(entity this) { set_animofs(this, anim_ithagnal_vomit, 13, ith_vomit14); ai_face(this); }
void ith_vomit12(entity this) { set_animofs(this, anim_ithagnal_vomit, 12, ith_vomit13); ai_face(this); }
void ith_vomit11(entity this) { set_animofs(this, anim_ithagnal_vomit, 11, ith_vomit12); ai_face(this); }
void ith_vomit10(entity this) { set_animofs(this, anim_ithagnal_vomit, 10, ith_vomit11); ai_face(this); IthVomit(this, '158 0 265'); }
void ith_vomit9(entity this) { set_animofs(this, anim_ithagnal_vomit, 9, ith_vomit10); ai_face(this); }
void ith_vomit8(entity this) { set_animofs(this, anim_ithagnal_vomit, 8, ith_vomit9); ai_face(this); }
void ith_vomit7(entity this) { set_animofs(this, anim_ithagnal_vomit, 7, ith_vomit8); ai_face(this); }
void ith_vomit6(entity this) { set_animofs(this, anim_ithagnal_vomit, 6, ith_vomit7); ai_face(this); IthVomit(this, '155 0 231'); }
void ith_vomit5(entity this) { set_animofs(this, anim_ithagnal_vomit, 5, ith_vomit6); ai_face(this); }
void ith_vomit4(entity this) { set_animofs(this, anim_ithagnal_vomit, 4, ith_vomit5); ai_face(this); }
void ith_vomit3(entity this) { set_animofs(this, anim_ithagnal_vomit, 3, ith_vomit4); ai_face(this); }
void ith_vomit2(entity this) { set_animofs(this, anim_ithagnal_vomit, 2, ith_vomit3); ai_face(this); }
void ith_vomit1(entity this)
{
	set_animofs(this, anim_ithagnal_vomit, 1, ith_vomit2);
	ai_face(this);
	if(random() < 0.5)
		_sound(this, CH_VOICE, "ithagnal/ithvomit1.wav", 1, ATTN_ITHAGNAL);
	else
		_sound(this, CH_VOICE, "ithagnal/ithvomit2.wav", 1, ATTN_ITHAGNAL);
	this.qccTauntTimer = time;
}

// VOMIT ======================================================================
// Ithagnal throws her enemies around her chambers with her mind
void ith_telethrow10(entity this)
{
	set_animofs(this, anim_ithagnal_telethrow, 10, ith_run);
	this.attack_finished = time + 1.5;
	IthagnalTaunt(this);
}
void ith_telethrow9(entity this) { set_animofs(this, anim_ithagnal_telethrow, 9, ith_telethrow10); }
void ith_telethrow8(entity this) { set_animofs(this, anim_ithagnal_telethrow, 8, ith_telethrow9); }
void ith_telethrow7(entity this) { set_animofs(this, anim_ithagnal_telethrow, 7, ith_telethrow8); }
void ith_telethrow6(entity this)
{
	set_animofs(this, anim_ithagnal_telethrow, 6, ith_telethrow7);
	makevectors(this.angles);
	vector org = QCC_RotatePointYaw('360 0 300' * this.scale, this.angles_y);
	org = this.origin + org;
	FOREACH_ENTITY_RADIUS(org, 800, it != this && it.owner != this && (it.flags & FL_PROJECTILE),
	{
		it.velocity = normalize(this.enemy.origin - it.origin) * 800 + v_right * crandom() * 300;
		it.owner = this;
		it.clipgroup = this.clipgroup;
		it.projectiledeathtype = DEATH_MONSTER_ITHAGNAL.m_id;
		it.dmg *= 0.5;
		set_movetype(it, MOVETYPE_FLYMISSILE);
		setorigin(it, it.origin);

		if(it.classname == "grenade")
			settouch(it, T_MissileTouch);
		it.angles = vectoangles(it.velocity);

		UpdateCSQCProjectile(it);
	});
}
void ith_telethrow5(entity this) { set_animofs(this, anim_ithagnal_telethrow, 5, ith_telethrow6); }
void ith_telethrow4(entity this) { set_animofs(this, anim_ithagnal_telethrow, 4, ith_telethrow5); }
void ith_telethrow3(entity this) { set_animofs(this, anim_ithagnal_telethrow, 3, ith_telethrow4); }
void ith_telethrow2(entity this) { set_animofs(this, anim_ithagnal_telethrow, 2, ith_telethrow3); }
void ith_telethrow1(entity this)
{
	set_animofs(this, anim_ithagnal_telethrow, 1, ith_telethrow2);
	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "ithagnal/ithtelet1.wav", 1, ATTN_ITHAGNAL);
	else
		_sound(this, CH_WEAPON_SINGLE, "ithagnal/ithtelet2.wav", 1, ATTN_ITHAGNAL);
}

// Grab our victims and projectiles
void IthagnalGrab(entity this)
{
	vector org = QCC_RotatePointYaw('360 0 300' * this.scale, this.angles_y);
	org = this.origin + org;
	FOREACH_ENTITY_RADIUS(org, 800, it != this && it.owner != this && (it.flags & FL_PROJECTILE),
	{
		it.velocity = '0 0 0';
		set_movetype(it, MOVETYPE_FLYMISSILE);
		setorigin(it, it.origin);
		UpdateCSQCProjectile(it);
	});
}

void ith_teletouch10(entity this)
{
	set_animofs(this, anim_ithagnal_teletouch, 10, ith_run);
	float thr = false;
	vector org = QCC_RotatePointYaw('359 0 300' * this.scale, this.angles_y);
	org = this.origin + org;
	FOREACH_ENTITY_RADIUS(org, 666, it.flags & FL_PROJECTILE,
	{
		thr = true;
		break;
	});

	if(thr)
		setthink(this, ith_telethrow1);
	else
		this.attack_finished = time + 1.5;
}
void ith_teletouch9(entity this) { set_animofs(this, anim_ithagnal_teletouch, 9, ith_teletouch10); ai_face(this); IthagnalGrab(this); }
void ith_teletouch8(entity this) { set_animofs(this, anim_ithagnal_teletouch, 8, ith_teletouch9); ai_face(this); IthagnalGrab(this); }
void ith_teletouch7(entity this) { set_animofs(this, anim_ithagnal_teletouch, 7, ith_teletouch8); ai_face(this); IthagnalGrab(this); }
void ith_teletouch6(entity this) { set_animofs(this, anim_ithagnal_teletouch, 6, ith_teletouch7); ai_face(this); IthagnalGrab(this); }
void ith_teletouch5(entity this) { set_animofs(this, anim_ithagnal_teletouch, 5, ith_teletouch6); ai_face(this); IthagnalGrab(this); }
void ith_teletouch4(entity this) { set_animofs(this, anim_ithagnal_teletouch, 4, ith_teletouch5); ai_face(this); }
void ith_teletouch3(entity this) { set_animofs(this, anim_ithagnal_teletouch, 3, ith_teletouch4); ai_face(this); }
void ith_teletouch2(entity this) { set_animofs(this, anim_ithagnal_teletouch, 2, ith_teletouch3); ai_face(this); }
void ith_teletouch1(entity this)
{
	set_animofs(this, anim_ithagnal_teletouch, 1, ith_teletouch2);
	ai_face(this);
	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "ithagnal/ithteleg1.wav", 1, ATTN_ITHAGNAL);
	else
		_sound(this, CH_WEAPON_SINGLE, "ithagnal/ithteleg2.wav", 1, ATTN_ITHAGNAL);
}

// Delay + randomize attack
void ith_attack(entity this)
{
	// go for another player if multi player
	if(this.enemy.health <= 0 || (coop && random() < 0.02))
		this.enemy = NULL;

	if(!this.enemy)
	{
		RandomSelection_Init();
		if(this.charmed)
		{
			FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
			{
				if(it != this && this.enemy != it && it.health > 0 && !(it.flags & FL_NOTARGET) && !it.charmed)
				{
					traceline(CENTER_OR_VIEWOFS(this), it.origin, true, this);
					if(trace_fraction != 1)
						continue;
					RandomSelection_AddEnt(it, 1, 1);
				}
			});
		}
		else
		{
			FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET),
			{
				// enable for line of sight
				//traceline(this.origin + '0 0 16', it.origin, true, this);
				//if(trace_fraction != 1)
					//continue;
				RandomSelection_AddEnt(it, 1, 1);
			});
		}
			
		this.enemy = RandomSelection_chosen_ent;
	}

	if(this.attack_finished > time)
	{
		if(this.walkframe > anim_ithagnal_walk + 7) // walk8
			this.walkframe = anim_ithagnal_walk;
		ith_run_loop(this);
		return;
	}

	// enemy is right under you! get'em away
	if(vdist(this.enemy.origin - this.origin, <, 64))
	{
		ith_vomit1(this);
		return;
	}

	// enemy is using projectile weapons - throw their shots back at'em
	.entity weaponentity = weaponentities[0]; // WEAPONTODO
	if(autocvar_skill >= 2 && IS_PLAYER(this.enemy) && !(this.enemy.(weaponentity).spawnflags & WEP_FLAG_MELEE))
	{
		if(random() < 0.6)
		{
			ith_teletouch1(this);
			return;
		}
	}

	float r = random();
	if(r < 0.333)
		ith_voreball1(this);
	else if(r < 0.666)
		ith_vomit1(this);
	else if(autocvar_skill >= 2)
		ith_teletouch1(this);
}

void ith_pain(entity this, entity attacker, float damage, int deathtype)
{
	// dummy function, the hitboxes handle damage
}

// called by hitboxes
void ith_hitbox_proc(entity this)
{
	if(this.owner.health < 1 || !this.owner || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	setthink(this, ith_hitbox_proc);
	this.nextthink = time + 0.05;

	// body positioning
	if(!this.ith_offset_x)
	{
		this.angles = this.owner.angles;
		setorigin(this, this.owner.origin);
		return;
	}

	// leg positioning
	vector vec = '0 0 0';
	vec.x = this.ith_offset_x * 208;
	vec.y = this.ith_offset_y * 264;
	vec = QCC_RotatePointYaw(vec, this.owner.angles_y);
	setorigin(this, this.owner.origin + vec);
}

void ith_hitbox_touch(entity this, entity toucher)
{
	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this.owner))
		return;
	
	if(toucher == this.owner || toucher.owner == this.owner)
		return;

	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 0.5; // no spam please
	
	T_Damage(toucher, this, this.owner, 100 * this.owner.scale, DEATH_MONSTER_ITHAGNAL.m_id);
}

void ith_spawn_hitboxes(entity this)
{
	entity ent;
	float dx, dy;

	// legs
	vector ofs = '208 264 0';
	dx = -1;
	while(dx <= 1)
	{
		dy = -1;
		ofs.x = dx * 208;
		while(dy <= 1)
		{
			ent = spawn();
			ent.classname = "monster_hitbox";
			ent.owner = this;
			ent.realowner = this;
			ent.clipgroup = this.clipgroup;
			ent.ith_offset = vec2(dx * this.scale, dy * this.scale);
			ent.takedamage = DAMAGE_AIM;
			ent.solid = SOLID_BBOX;
			setsize(ent, '-50 -50 -24' * this.scale, '50 50 436' * this.scale);
			ofs.y = dy * 264;
			ofs = QCC_RotatePointYaw(ofs, this.angles_y);
			setorigin(ent, this.origin + ofs);
			settouch(ent, ith_hitbox_touch);
			setthink(ent, ith_hitbox_proc);
			ent.nextthink = time + 0.05;
			dy += 2;
		}
		dx += 2;
	}

	// body
	ent = spawn();
	ent.classname = "monster_hitbox";
	ent.owner = this;
	ent.realowner = this;
	ent.clipgroup = this.clipgroup;
	ent.takedamage = DAMAGE_AIM;
	ent.solid = SOLID_BBOX;
	setsize(ent, '-70 -70 135' * this.scale, '70 70 422' * this.scale);
	ent.angles = this.angles;
	setorigin(ent, this.origin);
	setthink(ent, ith_hitbox_proc);
	ent.nextthink = time + 0.05;
}

void ith_head_pop(entity this)
{
	float dx, dy, dz;

	_sound(this, CHAN_BODY, "player/udeath.wav", 1, ATTN_ITHAGNAL);
	vector oldo = this.origin;
	// -60 0 470/524
	dz = 470;
	while(dz <= 524)
	{
		dx = 0;
		while(dx <= -52)
		{
			dy = 0;
			while(dy <= 8)
			{
				vector vec;
				vec.x = dx;
				vec.y = dy;
				vec.z = dz;
				vec = QCC_RotatePointYaw(vec, this.angles_y);
				this.origin = oldo + (vec * this.scale);

				float r = random();
				if(r < 0.3)				
					ThrowGib(this, this, "progs/gib1.mdl", -100);
				else if(r < 0.6)
					ThrowGib(this, this, "progs/gib2.mdl", -100);
				else
					ThrowGib(this, this, "progs/gib3.mdl", -100);
				dy += 8;
			}
			dx += 8;
		}
		dz += 18;
	}
	setorigin(this, oldo);
}

void ith_gib(entity this)
{
	// throw tons of meat chunks	
	float dx, dy, dz;

	_sound(this, CHAN_BODY, "boss2/pop2.wav", 1, ATTN_NORM);	
	vector oldo = this.origin;
	dz = 121;
	while (dz <= 366)
	{
		dx = 0;
		while(dx <= 70)
		{
			dy = 0;
			while(dy <= 96)
			{
				this.origin_x = oldo.x + (dx * this.scale);
				this.origin_y = oldo.y + (dy * this.scale);
				this.origin_z = oldo.z + (dz * this.scale);

				float r = random();
				if(r < 0.3)				
					ThrowGib(this, this, "progs/gib1.mdl", -100);
				else if(r < 0.6)
					ThrowGib(this, this, "progs/gib2.mdl", -100);
				else
					ThrowGib(this, this, "progs/gib3.mdl", -100);
				dy += 32;
			}
			dx += 35;
		}
		dz += 64;
	}
	delete(this);
}

void ith_death_proc(entity this)
{
	this.nextthink = time + FRAME_TIME;
	setthink(this, ith_death_proc);
	this.frame = this.walkframe;
	if(this.frame == anim_ithagnal_death + 2) // death3
	{
		this.solid = SOLID_NOT; // TODO: wasn't it already nonsolid?
		setorigin(this, this.origin);
	}
	// head blows up
	else if(this.frame == anim_ithagnal_death + 25) // death26
		ith_head_pop(this);
	// body blows up
	else if(this.frame == anim_ithagnal_death + 35) // death36
		setthink(this, ith_gib);
	
	this.walkframe += 1;
}

void ith_death(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.walkframe = anim_ithagnal_death;
	_sound(this, CH_VOICE, "ithagnal/ithpain2.wav", 1, ATTN_ITHAGNAL);
	ith_death_proc(this);
}

/*QUAKED monster_ithagnal(1 0 0)(-32 -32 -24)(32 32 48) Ambush
*/
spawnfunc(monster_ithagnal) { monster_start(this, true, MON_ITHAGNAL); }

#endif // SVQC

#ifdef SVQC
METHOD(Ithagnal, mr_setup, bool(Ithagnal this, entity actor))
{
    TC(Ithagnal, this);

	precache_model("progs/v_spike.mdl");
	precache_model("progs/ithvomit.mdl");
	precache_model("progs/ithvomit2.mdl");
	
	precache_sound("boss2/pop2.wav");
	precache_sound("shalrath/attack2.wav");
	precache_sound("hknight/hit.wav");
	
	precache_sound("ithagnal/ithwake.wav");
	precache_sound("ithagnal/ithidle.wav");
	precache_sound("ithagnal/ithtaunt1.wav");
	precache_sound("ithagnal/ithtaunt2.wav");
	precache_sound("ithagnal/ithtaunt3.wav");
	precache_sound("ithagnal/ithdie.wav");
	precache_sound("ithagnal/ithpain1.wav");
	precache_sound("ithagnal/ithpain2.wav");
	precache_sound("ithagnal/ithball1.wav");
	precache_sound("ithagnal/ithball2.wav");
	precache_sound("ithagnal/ithvomit1.wav");
	precache_sound("ithagnal/ithvomit2.wav");
	precache_sound("ithagnal/ithteleg1.wav");
	precache_sound("ithagnal/ithteleg2.wav");
	precache_sound("ithagnal/ithtelet1.wav");
	precache_sound("ithagnal/ithtelet2.wav");

    actor.health = 3000;
    if(horde_ent || actor.charmed)
    	actor.scale = 0.2;
    else
    	actor.scale = 0.75;

    actor.th_stand = ith_stand;
	actor.th_walk = ith_walk;
	actor.th_run = ith_run;
	actor.th_die = ith_death;
	actor.th_pain = ith_pain;
	//actor.th_melee = ith_stomp;
	actor.th_missile = ith_attack;

	actor.solid = SOLID_NOT; // can't be touched normally, uses hitboxes
	ith_spawn_hitboxes(actor);

    return true;
}
#endif
