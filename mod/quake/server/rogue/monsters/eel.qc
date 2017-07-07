$cd /qwork/xpack/models/eel
$origin 0 0 0
$scale .12
$base eelrest3
$skin eelfin

const int anim_eel_eelswim1 = 0;
const int anim_eel_eelswim2 = 1;
const int anim_eel_eelswim3 = 2;
const int anim_eel_eelswim4 = 3;
const int anim_eel_eelswim5 = 4;
const int anim_eel_eelswim6 = 5;

const int anim_eel_eeldth1 = 6;
const int anim_eel_eeldth2 = 7;
const int anim_eel_eeldth3 = 8;
const int anim_eel_eeldth4 = 9;
const int anim_eel_eeldth5 = 10;
const int anim_eel_eeldth6 = 11;
const int anim_eel_eeldth7 = 12;
const int anim_eel_eeldth8 = 13;
const int anim_eel_eeldth9 = 14;
const int anim_eel_eeldth10 = 15;

void eel_pain1(entity this, entity attacker, float damage);

void eel_pitch_change(entity this)
{
	if(pointcontents(this.origin) != CONTENT_WATER)
	{
		WITHSELF(this, builtin_droptofloor());
		T_Damage(this, NULL, NULL, 6);
		return;
	}
	
	if(time < this.delay)
		return;

	if(this.weapon > 10)
		this.weapon = -10;

	if(this.weapon < 0)
		this.angles_x = this.angles_x - 1.5;
	else if(this.weapon > 0)
		this.angles_x = this.angles_x + 1.5;

	this.weapon = this.weapon + 1;
}

void eel_stand1(entity this);
void eel_stand6(entity this) { set_anim(this, anim_eel_eelswim6, eel_stand1); ai_stand(this); eel_pitch_change(this); }
void eel_stand5(entity this) { set_anim(this, anim_eel_eelswim5, eel_stand6); ai_stand(this); eel_pitch_change(this); }
void eel_stand4(entity this) { set_anim(this, anim_eel_eelswim4, eel_stand5); ai_stand(this); eel_pitch_change(this); }
void eel_stand3(entity this) { set_anim(this, anim_eel_eelswim3, eel_stand4); ai_stand(this); eel_pitch_change(this); }
void eel_stand2(entity this) { set_anim(this, anim_eel_eelswim2, eel_stand3); ai_stand(this); eel_pitch_change(this); }
void eel_stand1(entity this) { set_anim(this, anim_eel_eelswim1, eel_stand2); ai_stand(this); eel_pitch_change(this); }

void eel_walk1(entity this);
void eel_walk6(entity this) { set_anim(this, anim_eel_eelswim6, eel_walk1); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk5(entity this) { set_anim(this, anim_eel_eelswim5, eel_walk6); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk4(entity this) { set_anim(this, anim_eel_eelswim4, eel_walk5); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk3(entity this) { set_anim(this, anim_eel_eelswim3, eel_walk4); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk2(entity this) { set_anim(this, anim_eel_eelswim2, eel_walk3); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk1(entity this)
{
	set_anim(this, anim_eel_eelswim1, eel_walk2);

	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "eel/eactive1.wav", 1, ATTN_IDLE);
	ai_walk(this, 6);
	eel_pitch_change(this);
}

void eel_run1(entity this);
void eel_run6(entity this) { set_anim(this, anim_eel_eelswim6, eel_run1); ai_run(this, 10); eel_pitch_change(this); }
void eel_run5(entity this) { set_anim(this, anim_eel_eelswim5, eel_run6); ai_run(this, 10); eel_pitch_change(this); }
void eel_run4(entity this) { set_anim(this, anim_eel_eelswim4, eel_run5); ai_run(this, 10); eel_pitch_change(this); }
void eel_run3(entity this) { set_anim(this, anim_eel_eelswim3, eel_run4); ai_run(this, 10); eel_pitch_change(this); }
void eel_run2(entity this) { set_anim(this, anim_eel_eelswim2, eel_run3); ai_run(this, 10); eel_pitch_change(this); }
void eel_run1(entity this)
{
	set_anim(this, anim_eel_eelswim1, eel_run2);

	if(random() < 0.4)
		_sound(this, CHAN_VOICE, "eel/eactive1.wav", 1, ATTN_IDLE);
	ai_run(this, 10);
	eel_pitch_change(this);
}

void eel_melee(entity this)
{
	bool attackOK = true;

	traceline(this.origin, this.enemy.origin, false, this);

	if(trace_ent != this.enemy)
		attackOK = false;       // don't have a clear shot
	if(trace_inopen && trace_inwater)
		attackOK = false;           // sight line crossed contents

	if(attackOK)
		T_EELZap(this, this, 45);
	this.skin = 0;
	this.effects = 0;
}

void eel_attack12(entity this) { set_anim(this, anim_eel_eelswim6, eel_run1); this.skin=5; eel_melee(this); }
void eel_attack11(entity this) { set_anim(this, anim_eel_eelswim5, eel_attack12); this.effects = EF_BRIGHTLIGHT; this.skin = 4; ai_charge(this, 8); eel_pitch_change(this); }
void eel_attack10(entity this) { set_anim(this, anim_eel_eelswim4, eel_attack11); this.skin = 3; ai_charge(this, 8); eel_pitch_change(this); }
void eel_attack9(entity this) { set_anim(this, anim_eel_eelswim3, eel_attack10); this.skin = 2; ai_charge(this, 8); eel_pitch_change(this); }
void eel_attack8(entity this)
{
	set_anim(this, anim_eel_eelswim2, eel_attack9);

	this.effects = EF_DIMLIGHT;
	this.skin = 1;
	ai_charge(this, 8);
	eel_pitch_change(this);
	_sound(this, CHAN_WEAPON, "eel/eatt1.wav", 1, ATTN_NORM);
}
void eel_attack7(entity this) { set_anim(this, anim_eel_eelswim1, eel_attack8); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack6(entity this) { set_anim(this, anim_eel_eelswim6, eel_attack7); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack5(entity this) { set_anim(this, anim_eel_eelswim5, eel_attack6); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack4(entity this) { set_anim(this, anim_eel_eelswim4, eel_attack5); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack3(entity this) { set_anim(this, anim_eel_eelswim3, eel_attack4); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack2(entity this) { set_anim(this, anim_eel_eelswim2, eel_attack3); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack1(entity this) { set_anim(this, anim_eel_eelswim1, eel_attack2); ai_charge(this, 8); eel_pitch_change(this);}

void eel_death16(entity this) { set_anim(this, anim_eel_eeldth10, eel_death16); this.solid = SOLID_NOT; }
void eel_death15(entity this) { set_anim(this, anim_eel_eeldth9, eel_death16); WITHSELF(this, builtin_droptofloor()); }
void eel_death14(entity this) { set_anim(this, anim_eel_eeldth8, eel_death15); }
void eel_death13(entity this) { set_anim(this, anim_eel_eeldth7, eel_death14); }
void eel_death12(entity this) { set_anim(this, anim_eel_eeldth6, eel_death13); }
void eel_death11(entity this) { set_anim(this, anim_eel_eeldth5, eel_death12); this.flags &= ~FL_SWIM; }
void eel_death10(entity this) { set_anim(this, anim_eel_eeldth4, eel_death11); }
void eel_death9(entity this) { set_anim(this, anim_eel_eeldth3, eel_death10); }
void eel_death8(entity this) { set_anim(this, anim_eel_eeldth2, eel_death9); }
void eel_death7(entity this) { set_anim(this, anim_eel_eeldth1, eel_death8); }
void eel_death6(entity this) { set_anim(this, anim_eel_eeldth2, eel_death7); }
void eel_death5(entity this) { set_anim(this, anim_eel_eeldth3, eel_death6); }
void eel_death4(entity this) { set_anim(this, anim_eel_eeldth4, eel_death5); }
void eel_death3(entity this) { set_anim(this, anim_eel_eeldth3, eel_death4); }
void eel_death2(entity this) { set_anim(this, anim_eel_eeldth2, eel_death3); }
void eel_death1(entity this)
{
	set_anim(this, anim_eel_eeldth1, eel_death2);

	this.skin = 0;
	this.effects = 0;
	_sound(this, CHAN_VOICE, "eel/edie3r.wav", 1, ATTN_NORM);
}

void eel_death(entity this, entity attacker)
{
	this.flags |= FL_SWIM;
	setsize(this, '0 0 0', '0 0 0');
	
//	this.skin = 1;		// change to bloody eel skin!
	if(this.health < -12)
	{
		this.skin = 0;
		this.effects = 0;
		ThrowHead(this, "progs/eelgib.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		return;
	}
	else
		eel_death1(this);
}

void eel_pain7(entity this) { set_anim(this, anim_eel_eeldth1, eel_run1); }
void eel_pain6(entity this) { set_anim(this, anim_eel_eeldth2, eel_pain7); }
void eel_pain5(entity this) { set_anim(this, anim_eel_eeldth3, eel_pain6); }
void eel_pain4(entity this) { set_anim(this, anim_eel_eeldth4, eel_pain5); }
void eel_pain3(entity this) { set_anim(this, anim_eel_eeldth3, eel_pain4); }
void eel_pain2(entity this) { set_anim(this, anim_eel_eeldth2, eel_pain3); }
void eel_pain1(entity this, entity attacker, float damage)
{
	set_anim(this, anim_eel_eeldth1, eel_pain2);

	if(this.pain_finished > time)
		return;
	
	this.pain_finished = time + 1;
	_sound(this, CHAN_VOICE, "eel/epain3.wav", 1, ATTN_NORM); 
	this.skin = 0;
}

string eel_sight(entity this) { return "eel/eelc5.wav"; }
string eel_deathmessage(entity this) { return "was electrified by an Eel"; }

/*QUAKED monster_eel (1 0 0) (-16 -16 -24) (16 16 32) Ambush
*/
spawnfunc(monster_eel)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(deathmatch) { delete(this); return; }

	precache_model ("progs/eel2.mdl");
	precache_model ("progs/eelgib.mdl");
	precache_model ("progs/gib1.mdl");
	
	precache_sound ("eel/edie3r.wav");
	precache_sound ("eel/epain3.wav");
	precache_sound ("eel/eactive1.wav");
	precache_sound ("eel/eatt1.wav");
	precache_sound ("eel/eelc5.wav");
	
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/eel2.mdl");

	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.health = 60;

	this.th_stand = eel_stand1;
	this.th_walk = eel_walk1;
	this.th_run = eel_run1;
	this.th_die = eel_death;
	this.th_pain = eel_pain1;
	this.th_melee = eel_attack1;

	this.sightsound = eel_sight;
	this.deathmessage = eel_deathmessage;

	this.delay = time + random() * 6;
	this.weapon = 0;

	monster_start(this, FL_SWIM);
}
