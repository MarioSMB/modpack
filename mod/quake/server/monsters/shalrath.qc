/*
==============================================================================

SHAL-RATH

==============================================================================
*/
$cd id1/models/shalrath
$origin 0 0 24
$base base
$skin skin
$scale 0.7


const int anim_shal_attack1 = 0;
const int anim_shal_attack2 = 1;
const int anim_shal_attack3 = 2;
const int anim_shal_attack4 = 3;
const int anim_shal_attack5 = 4;
const int anim_shal_attack6 = 5;
const int anim_shal_attack7 = 6;
const int anim_shal_attack8 = 7;
const int anim_shal_attack9 = 8;
const int anim_shal_attack10 = 9;
const int anim_shal_attack11 = 10;

const int anim_shal_pain1 = 11;
const int anim_shal_pain2 = 12;
const int anim_shal_pain3 = 13;
const int anim_shal_pain4 = 14;
const int anim_shal_pain5 = 15;

const int anim_shal_death1 = 16;
const int anim_shal_death2 = 17;
const int anim_shal_death3 = 18;
const int anim_shal_death4 = 19;
const int anim_shal_death5 = 20;
const int anim_shal_death6 = 21;
const int anim_shal_death7 = 22;

const int anim_shal_walk1 = 23;
const int anim_shal_walk2 = 24;
const int anim_shal_walk3 = 25;
const int anim_shal_walk4 = 26;
const int anim_shal_walk5 = 27;
const int anim_shal_walk6 = 28;
const int anim_shal_walk7 = 29;
const int anim_shal_walk8 = 30;
const int anim_shal_walk9 = 31;
const int anim_shal_walk10 = 32;
const int anim_shal_walk11 = 33;
const int anim_shal_walk12 = 34;

void ShalMissile(entity this);

void shal_stand(entity this) { set_anim(this, anim_shal_walk1, shal_stand); ai_stand(this); }

void shal_walk1(entity this);
void shal_walk12(entity this) { set_anim(this, anim_shal_walk1, shal_walk1); ai_walk(this, 5); }
void shal_walk11(entity this) { set_anim(this, anim_shal_walk12, shal_walk12); ai_walk(this, 4); }
void shal_walk10(entity this) { set_anim(this, anim_shal_walk11, shal_walk11); ai_walk(this, 0); }
void shal_walk9(entity this) { set_anim(this, anim_shal_walk10, shal_walk10); ai_walk(this, 5); }
void shal_walk8(entity this) { set_anim(this, anim_shal_walk9, shal_walk9); ai_walk(this, 6); }
void shal_walk7(entity this) { set_anim(this, anim_shal_walk8, shal_walk8); ai_walk(this, 5); }
void shal_walk6(entity this) { set_anim(this, anim_shal_walk7, shal_walk7); ai_walk(this, 0); }
void shal_walk5(entity this) { set_anim(this, anim_shal_walk6, shal_walk6); ai_walk(this, 0); }
void shal_walk4(entity this) { set_anim(this, anim_shal_walk5, shal_walk5); ai_walk(this, 0); }
void shal_walk3(entity this) { set_anim(this, anim_shal_walk4, shal_walk4); ai_walk(this, 0); }
void shal_walk2(entity this) { set_anim(this, anim_shal_walk3, shal_walk3); ai_walk(this, 4); }
void shal_walk1(entity this)
{
	set_anim(this, anim_shal_walk2, shal_walk2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 6);
}

void shal_run1(entity this);
void shal_run12(entity this) { set_anim(this, anim_shal_walk1, shal_run1); ai_run(this, 5); }
void shal_run11(entity this) { set_anim(this, anim_shal_walk12, shal_run12); ai_run(this, 4); }
void shal_run10(entity this) { set_anim(this, anim_shal_walk11, shal_run11); ai_run(this, 0); }
void shal_run9(entity this) { set_anim(this, anim_shal_walk10, shal_run10); ai_run(this, 5); }
void shal_run8(entity this) { set_anim(this, anim_shal_walk9, shal_run9); ai_run(this, 6); }
void shal_run7(entity this) { set_anim(this, anim_shal_walk8, shal_run8); ai_run(this, 5); }
void shal_run6(entity this) { set_anim(this, anim_shal_walk7, shal_run7); ai_run(this, 0); }
void shal_run5(entity this) { set_anim(this, anim_shal_walk6, shal_run6); ai_run(this, 0); }
void shal_run4(entity this) { set_anim(this, anim_shal_walk5, shal_run5); ai_run(this, 0); }
void shal_run3(entity this) { set_anim(this, anim_shal_walk4, shal_run4); ai_run(this, 0); }
void shal_run2(entity this) { set_anim(this, anim_shal_walk3, shal_run3); ai_run(this, 4); }
void shal_run1(entity this)
{
	set_anim(this, anim_shal_walk2, shal_run2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 6);
}

void shal_attack11(entity this) { set_anim(this, anim_shal_attack11, shal_run1); ai_face(this); }
void shal_attack10(entity this) { set_anim(this, anim_shal_attack10, shal_attack11); ai_face(this); }
void shal_attack9(entity this) { set_anim(this, anim_shal_attack9, shal_attack10); ShalMissile(this); }
void shal_attack8(entity this) { set_anim(this, anim_shal_attack8, shal_attack9); ai_face(this); }
void shal_attack7(entity this) { set_anim(this, anim_shal_attack7, shal_attack8); ai_face(this); }
void shal_attack6(entity this) { set_anim(this, anim_shal_attack6, shal_attack7); ai_face(this); }
void shal_attack5(entity this) { set_anim(this, anim_shal_attack5, shal_attack6); ai_face(this); }
void shal_attack4(entity this) { set_anim(this, anim_shal_attack4, shal_attack5); ai_face(this); }
void shal_attack3(entity this) { set_anim(this, anim_shal_attack3, shal_attack4); ai_face(this); }
void shal_attack2(entity this) { set_anim(this, anim_shal_attack2, shal_attack3); ai_face(this); }
void shal_attack1(entity this)
{
	set_anim(this, anim_shal_attack1, shal_attack2);
	_sound(this, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
	ai_face(this);
}

void shal_pain5(entity this) { set_anim(this, anim_shal_pain5, shal_run1); }
void shal_pain4(entity this) { set_anim(this, anim_shal_pain4, shal_pain5); }
void shal_pain3(entity this) { set_anim(this, anim_shal_pain3, shal_pain4); }
void shal_pain2(entity this) { set_anim(this, anim_shal_pain2, shal_pain3); }
void shal_pain1(entity this) { set_anim(this, anim_shal_pain1, shal_pain2); }

void shal_death7(entity this) { set_anim(this, anim_shal_death7, shal_death7); }
void shal_death6(entity this) { set_anim(this, anim_shal_death6, shal_death7); }
void shal_death5(entity this) { set_anim(this, anim_shal_death5, shal_death6); }
void shal_death4(entity this) { set_anim(this, anim_shal_death4, shal_death5); }
void shal_death3(entity this) { set_anim(this, anim_shal_death3, shal_death4); }
void shal_death2(entity this) { set_anim(this, anim_shal_death2, shal_death3); }
void shal_death1(entity this) { set_anim(this, anim_shal_death1, shal_death2); }

void shalrath_pain(entity this, entity attacker, float damage)
{
	if(this.pain_finished > time)
		return;

	_sound(this, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);
	shal_pain1(this);
	this.pain_finished = time + 3;
}

void shalrath_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -90)
	{
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_shal.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

	_sound(this, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	shal_death1(this);
	this.solid = SOLID_NOT;
	// insert death sounds here
}

/*
================
ShalMissile
================
*/
void ShalMissileTouch(entity this, entity toucher);
void ShalHome(entity this);
void ShalMissile(entity this)
{
	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
	float dist = vlen(this.enemy.origin - this.origin);
	float flytime = dist * 0.002;
	if(flytime < 0.1)
		flytime = 0.1;

	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.owner = this;

	missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	_setmodel(missile, "progs/v_spike.mdl");

	setsize(missile, '0 0 0', '0 0 0');		

	missile.origin = this.origin + '0 0 10';
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = flytime + time;
	setthink(missile, ShalHome);
	missile.enemy = this.enemy;
	settouch(missile, ShalMissileTouch);
}

void ShalHome(entity this)
{
	vector vtemp = this.enemy.origin + '0 0 10';
	if(this.enemy.health < 1)
	{
		delete(this);
		return;
	}
	vector dir = normalize(vtemp - this.origin);
	if(skill == 3)
		this.velocity = dir * 350;
	else
		this.velocity = dir * 250;
	this.nextthink = time + 0.2;
	setthink(this, ShalHome);	
}

void ShalMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(toucher.classname == "monster_zombie")
		T_Damage(toucher, this, this, 110);	
	T_RadiusDamage(this, this.owner, 40, NULL);
	_sound(this, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);

	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/s_explod.spr");
	this.solid = SOLID_NOT;
	s_explode1(this);
}

string shalrath_sight(entity this) { return "shalrath/sight.wav"; }
string shalrath_deathmessage(entity this) { return "was exploded by a Vore"; }

//=================================================================

/*QUAKED monster_shalrath(1 0 0)(-32 -32 -24)(32 32 48) Ambush
*/
spawnfunc(monster_shalrath)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model2("progs/shalrath.mdl");
	precache_model2("progs/h_shal.mdl");
	precache_model2("progs/v_spike.mdl");
	
	precache_sound2("shalrath/attack.wav");
	precache_sound2("shalrath/attack2.wav");
	precache_sound2("shalrath/death.wav");
	precache_sound2("shalrath/idle.wav");
	precache_sound2("shalrath/pain.wav");
	precache_sound2("shalrath/sight.wav");
	
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	
	_setmodel(this, "progs/shalrath.mdl");
	setsize(this, VEC_HULL2_MIN, VEC_HULL2_MAX);
	this.health = 400;

	this.th_stand = shal_stand;
	this.th_walk = shal_walk1;
	this.th_run = shal_run1;
	this.th_die = shalrath_die;
	this.th_pain = shalrath_pain;
	this.th_missile = shal_attack1;

	this.sightsound = shalrath_sight;
	this.deathmessage = shalrath_deathmessage;

	setthink(this, walkmonster_start);
	this.nextthink = time + 0.1 + random()*0.1;	

}
