#include "gaunt.qh"

/*==============================================================================
 GAUNT (Originally from Quoth - Kell/Necros/Preach)
 - Big thank you to necros for the his code base for this monster
==============================================================================*/

#ifdef SVQC
const int anim_gaunt_perch = 0;
const int anim_gaunt_launch = 16;
const int anim_gaunt_hover = 24;
const int anim_gaunt_attack = 44;
const int anim_gaunt_swoopStart = 64;
const int anim_gaunt_swoop = 72;
//const int anim_gaunt_drop = 77;
const int anim_gaunt_painA = 82;
const int anim_gaunt_painB = 88;
const int anim_gaunt_deathA = 93;
const int anim_gaunt_deathB = 101;

const int MON_GAUNT_PERCH = 4;		// Start in perched position

.float meleeattack;
.entity attachment;

void gauntwings(entity this)
{
	_sound(this, CHAN_ITEM, "gaunt/wings1.wav", 1, ATTN_IDLE);
}

//============================================================================
// Attachment management (create, finish and delete)
//============================================================================
void gaunt_create_attachment(entity this)
{
	// Are the attachments setup yet?
	if(!this.attachment)
	{
		this.attachment = spawn();
		this.attachment.owner = this;
		this.attachment.classname = "attachment";
		this.attachment.mdl = "progs/mon_gaunt_elec.mdl";
		if(this.poisonous)
			this.attachment.skin = 1;
	}
}

//----------------------------------------------------------------------
void gaunt_finish_attachment(entity this)
{
	if(this.attachment)
	{
		_setmodel(this.attachment, "");
		this.attachment.state = false;
	}
}

//----------------------------------------------------------------------
void gaunt_remove_attachment(entity this)
{
	if(this.attachment)
	{
		setthink(this.attachment, SUB_Remove);
		this.attachment.nextthink = time + 0.1;
	}
	this.attachment = NULL;
}

//----------------------------------------------------------------------
void gaunt_update_attachment(entity this, float elecframe)
{
	if(this.health < 1)
		return;
	if(!this.attachment)
		gaunt_create_attachment(this);
	
	if(elecframe == 0)
	{
		this.attachment.state = true;
		this.pain_finished = time + 1.2;		//don't go into pain whilst firing
		setorigin(this.attachment, this.origin);
		_setmodel(this.attachment, this.attachment.mdl);
		this.attachment.solid = SOLID_NOT;
		setsize(this.attachment, '0 0 0', '0 0 0');
		set_movetype(this.attachment, MOVETYPE_NONE);
		_sound(this, CH_WEAPON_SINGLE, "gaunt/plasma_start.wav", 1, ATTN_NORM);
	}

	ai_face(this);					// Turn towards enemy
	setorigin(this.attachment, this.origin);
	this.attachment.angles = this.angles;
	this.attachment.frame = elecframe;
}

void gaunt_idle1(entity this);
void gaunt_idle20(entity this) { set_animofs(this, anim_gaunt_hover, 20, gaunt_idle1); ai_stand(this); }
void gaunt_idle19(entity this) { set_animofs(this, anim_gaunt_hover, 19, gaunt_idle20); ai_stand(this); }
void gaunt_idle18(entity this) { set_animofs(this, anim_gaunt_hover, 18, gaunt_idle19); ai_stand(this); }
void gaunt_idle17(entity this) { set_animofs(this, anim_gaunt_hover, 17, gaunt_idle18); ai_stand(this); }
void gaunt_idle16(entity this) { set_animofs(this, anim_gaunt_hover, 16, gaunt_idle17); ai_stand(this); }
void gaunt_idle15(entity this) { set_animofs(this, anim_gaunt_hover, 15, gaunt_idle16); gauntwings(this); ai_stand(this); }
void gaunt_idle14(entity this) { set_animofs(this, anim_gaunt_hover, 14, gaunt_idle15); ai_stand(this); }
void gaunt_idle13(entity this) { set_animofs(this, anim_gaunt_hover, 13, gaunt_idle14); ai_stand(this); }
void gaunt_idle12(entity this) { set_animofs(this, anim_gaunt_hover, 12, gaunt_idle13); ai_stand(this); }
void gaunt_idle11(entity this) { set_animofs(this, anim_gaunt_hover, 11, gaunt_idle12); ai_stand(this); }
void gaunt_idle10(entity this) { set_animofs(this, anim_gaunt_hover, 10, gaunt_idle11); ai_stand(this); }
void gaunt_idle9(entity this) { set_animofs(this, anim_gaunt_hover, 9, gaunt_idle10); ai_stand(this); }
void gaunt_idle8(entity this) { set_animofs(this, anim_gaunt_hover, 8, gaunt_idle9); ai_stand(this); }
void gaunt_idle7(entity this) { set_animofs(this, anim_gaunt_hover, 7, gaunt_idle8); ai_stand(this); }
void gaunt_idle6(entity this) { set_animofs(this, anim_gaunt_hover, 6, gaunt_idle7); ai_stand(this); }
void gaunt_idle5(entity this) { set_animofs(this, anim_gaunt_hover, 5, gaunt_idle6); gauntwings(this); ai_stand(this); }
void gaunt_idle4(entity this) { set_animofs(this, anim_gaunt_hover, 4, gaunt_idle5); ai_stand(this); }
void gaunt_idle3(entity this) { set_animofs(this, anim_gaunt_hover, 3, gaunt_idle4); ai_stand(this); }
void gaunt_idle2(entity this) { set_animofs(this, anim_gaunt_hover, 2, gaunt_idle3); ai_stand(this); }
void gaunt_idle1(entity this)
{
	set_animofs(this, anim_gaunt_hover, 1, gaunt_idle2);
	if(random() > 0.8)
	{
		float r = random();
		if(r > 0.66)
			_sound(this, CH_VOICE, "gaunt/idle1.wav", 1, ATTN_IDLE);
		else if(r > 0.33)
			_sound(this, CH_VOICE, "gaunt/idle2.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "gaunt/idle3.wav", 1, ATTN_IDLE);
	}
	ai_stand(this);
}

void gaunt_walk1(entity this);
void gaunt_walk20(entity this) { set_animofs(this, anim_gaunt_hover, 20, gaunt_walk1); ai_walk(this, 8); }
void gaunt_walk19(entity this) { set_animofs(this, anim_gaunt_hover, 19, gaunt_walk20); ai_walk(this, 8); }
void gaunt_walk18(entity this) { set_animofs(this, anim_gaunt_hover, 18, gaunt_walk19); ai_walk(this, 8); }
void gaunt_walk17(entity this) { set_animofs(this, anim_gaunt_hover, 17, gaunt_walk18); ai_walk(this, 8); }
void gaunt_walk16(entity this) { set_animofs(this, anim_gaunt_hover, 16, gaunt_walk17); ai_walk(this, 8); }
void gaunt_walk15(entity this) { set_animofs(this, anim_gaunt_hover, 15, gaunt_walk16); gauntwings(this); ai_walk(this, 8); }
void gaunt_walk14(entity this) { set_animofs(this, anim_gaunt_hover, 14, gaunt_walk15); ai_walk(this, 8); }
void gaunt_walk13(entity this) { set_animofs(this, anim_gaunt_hover, 13, gaunt_walk14); ai_walk(this, 8); }
void gaunt_walk12(entity this) { set_animofs(this, anim_gaunt_hover, 12, gaunt_walk13); ai_walk(this, 8); }
void gaunt_walk11(entity this) { set_animofs(this, anim_gaunt_hover, 11, gaunt_walk12); ai_walk(this, 8); }
void gaunt_walk10(entity this) { set_animofs(this, anim_gaunt_hover, 10, gaunt_walk11); ai_walk(this, 8); }
void gaunt_walk9(entity this) { set_animofs(this, anim_gaunt_hover, 9, gaunt_walk10); ai_walk(this, 8); }
void gaunt_walk8(entity this) { set_animofs(this, anim_gaunt_hover, 8, gaunt_walk9); ai_walk(this, 8); }
void gaunt_walk7(entity this) { set_animofs(this, anim_gaunt_hover, 7, gaunt_walk8); ai_walk(this, 8); }
void gaunt_walk6(entity this) { set_animofs(this, anim_gaunt_hover, 6, gaunt_walk7); ai_walk(this, 8); }
void gaunt_walk5(entity this) { set_animofs(this, anim_gaunt_hover, 5, gaunt_walk6); ai_walk(this, 8); }
void gaunt_walk4(entity this) { set_animofs(this, anim_gaunt_hover, 4, gaunt_walk5); ai_walk(this, 8); }
void gaunt_walk3(entity this) { set_animofs(this, anim_gaunt_hover, 3, gaunt_walk4); gauntwings(this); ai_walk(this, 8); }
void gaunt_walk2(entity this) { set_animofs(this, anim_gaunt_hover, 2, gaunt_walk3); ai_walk(this, 8); }
void gaunt_walk1(entity this)
{
	set_animofs(this, anim_gaunt_hover, 1, gaunt_walk2);
	if(random() > 0.8)
	{
		float r = random();
		if(r > 0.66)
			_sound(this, CH_VOICE, "gaunt/idle1.wav", 1, ATTN_IDLE);
		else if(r > 0.33)
			_sound(this, CH_VOICE, "gaunt/idle2.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "gaunt/idle3.wav", 1, ATTN_IDLE);
	}
	ai_walk(this, 8);
}

void gaunt_run1(entity this);
void gaunt_run20(entity this) { set_animofs(this, anim_gaunt_hover, 20, gaunt_run1); ai_run(this, 8); }
void gaunt_run19(entity this) { set_animofs(this, anim_gaunt_hover, 19, gaunt_run20); ai_run(this, 8); }
void gaunt_run18(entity this) { set_animofs(this, anim_gaunt_hover, 18, gaunt_run19); ai_run(this, 8); }
void gaunt_run17(entity this) { set_animofs(this, anim_gaunt_hover, 17, gaunt_run18); ai_run(this, 8); }
void gaunt_run16(entity this) { set_animofs(this, anim_gaunt_hover, 16, gaunt_run17); ai_run(this, 8); }
void gaunt_run15(entity this) { set_animofs(this, anim_gaunt_hover, 15, gaunt_run16); gauntwings(this); ai_run(this, 8); }
void gaunt_run14(entity this) { set_animofs(this, anim_gaunt_hover, 14, gaunt_run15); ai_run(this, 8); }
void gaunt_run13(entity this) { set_animofs(this, anim_gaunt_hover, 13, gaunt_run14); ai_run(this, 8); }
void gaunt_run12(entity this) { set_animofs(this, anim_gaunt_hover, 12, gaunt_run13); ai_run(this, 8); }
void gaunt_run11(entity this) { set_animofs(this, anim_gaunt_hover, 11, gaunt_run12); ai_run(this, 8); }
void gaunt_run10(entity this) { set_animofs(this, anim_gaunt_hover, 10, gaunt_run11); ai_run(this, 8); }
void gaunt_run9(entity this) { set_animofs(this, anim_gaunt_hover, 9, gaunt_run10); ai_run(this, 8); }
void gaunt_run8(entity this) { set_animofs(this, anim_gaunt_hover, 8, gaunt_run9); ai_run(this, 8); }
void gaunt_run7(entity this) { set_animofs(this, anim_gaunt_hover, 7, gaunt_run8); ai_run(this, 8); }
void gaunt_run6(entity this) { set_animofs(this, anim_gaunt_hover, 6, gaunt_run7); ai_run(this, 8); }
void gaunt_run5(entity this) { set_animofs(this, anim_gaunt_hover, 5, gaunt_run6); gauntwings(this); ai_run(this, 8); }
void gaunt_run4(entity this) { set_animofs(this, anim_gaunt_hover, 4, gaunt_run5); ai_run(this, 8); }
void gaunt_run3(entity this) { set_animofs(this, anim_gaunt_hover, 3, gaunt_run4); ai_run(this, 8); }
void gaunt_run2(entity this) { set_animofs(this, anim_gaunt_hover, 2, gaunt_run3); ai_run(this, 8); }
void gaunt_run1(entity this)
{
	set_animofs(this, anim_gaunt_hover, 1, gaunt_run2);
	if(random() > 0.8)
	{
		float r = random();
		if(r > 0.66)
			_sound(this, CH_VOICE, "gaunt/idle1.wav", 1, ATTN_IDLE);
		else if(r > 0.33)
			_sound(this, CH_VOICE, "gaunt/idle2.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "gaunt/idle3.wav", 1, ATTN_IDLE);
	}
	gaunt_finish_attachment(this);
	// Switch direction of strafing (random duration)
	if(this.meleeattack < time)
	{
		this.meleeattack = time + 4 + (random() + random() + random() * 4);
		this.lefty = rint(1 - this.lefty);
	}
	ai_run(this, 8);
}

//============================================================================
// RANGE - Plasma from arc infront
//============================================================================
void gaunt_plasma(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "gaunt/plasma_fire.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('8 0 -4');
	vector dir = normalize(this.enemy.origin - this.origin);

	entity newmis = launch_plasma(this, org, dir);
	newmis.velocity = v_forward * 500;
	newmis.projectiledeathtype = DEATH_MONSTER_GAUNT.m_id;
	newmis.poisonous = this.poisonous;
	newmis.dmg = 10;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.avelocity = '0 0 0';
	if(this.poisonous)
		_setmodel(newmis, "progs/proj_gaplasmagrn.mdl");
	else
		_setmodel(newmis, "progs/proj_gaplasma.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
}

//----------------------------------------------------------------------
void gaunt_fire20(entity this) { set_animofs(this, anim_gaunt_attack, 20, gaunt_run1); }
void gaunt_fire19(entity this) { set_animofs(this, anim_gaunt_attack, 19, gaunt_fire20); ai_face(this);}
void gaunt_fire18(entity this) { set_animofs(this, anim_gaunt_attack, 18, gaunt_fire19); ai_face(this);}
void gaunt_fire17(entity this) { set_animofs(this, anim_gaunt_attack, 17, gaunt_fire18); }
void gaunt_fire16(entity this) { set_animofs(this, anim_gaunt_attack, 16, gaunt_fire17); }
void gaunt_fire15(entity this) { set_animofs(this, anim_gaunt_attack, 15, gaunt_fire16); gauntwings(this);}
void gaunt_fire14(entity this) { set_animofs(this, anim_gaunt_attack, 14, gaunt_fire15); }
void gaunt_fire13(entity this) { set_animofs(this, anim_gaunt_attack, 13, gaunt_fire14); }
void gaunt_fire12(entity this) { set_animofs(this, anim_gaunt_attack, 12, gaunt_fire13); }
void gaunt_fire11(entity this) { set_animofs(this, anim_gaunt_attack, 11, gaunt_fire12); }
void gaunt_fire10(entity this)
{
	set_animofs(this, anim_gaunt_attack, 10, gaunt_fire11);
	ai_face(this);
	if(autocvar_skill > 1)
		gaunt_plasma(this);
	gaunt_finish_attachment(this);
}
void gaunt_fire9(entity this) { set_animofs(this, anim_gaunt_attack, 9, gaunt_fire10); gaunt_update_attachment(this, 8); }
void gaunt_fire8(entity this) { set_animofs(this, anim_gaunt_attack, 8, gaunt_fire9); gaunt_update_attachment(this, 7); gaunt_plasma(this); }
void gaunt_fire7(entity this) { set_animofs(this, anim_gaunt_attack, 7, gaunt_fire8); gaunt_update_attachment(this, 6); }
void gaunt_fire6(entity this) { set_animofs(this, anim_gaunt_attack, 6, gaunt_fire7); gaunt_update_attachment(this, 5); gaunt_plasma(this); }
void gaunt_fire5(entity this) { set_animofs(this, anim_gaunt_attack, 5, gaunt_fire6); gaunt_update_attachment(this, 4); gauntwings(this); }
void gaunt_fire4(entity this) { set_animofs(this, anim_gaunt_attack, 4, gaunt_fire5); gaunt_update_attachment(this, 3); }
void gaunt_fire3(entity this) { set_animofs(this, anim_gaunt_attack, 3, gaunt_fire4); gaunt_update_attachment(this, 2); }
void gaunt_fire2(entity this) { set_animofs(this, anim_gaunt_attack, 2, gaunt_fire3); gaunt_update_attachment(this, 1); }
void gaunt_fire1(entity this) { set_animofs(this, anim_gaunt_attack, 1, gaunt_fire2); gaunt_update_attachment(this, 0); }

//============================================================================
// PERCH + WAKEUP
//============================================================================
void gaunt_perch1(entity this);
void gaunt_perch16(entity this) { set_animofs(this, anim_gaunt_perch, 16, gaunt_perch1); ai_stand(this); }
void gaunt_perch15(entity this) { set_animofs(this, anim_gaunt_perch, 15, gaunt_perch16); ai_stand(this); }
void gaunt_perch14(entity this) { set_animofs(this, anim_gaunt_perch, 14, gaunt_perch15); ai_stand(this); }
void gaunt_perch13(entity this) { set_animofs(this, anim_gaunt_perch, 13, gaunt_perch14); ai_stand(this); }
void gaunt_perch12(entity this) { set_animofs(this, anim_gaunt_perch, 12, gaunt_perch13); ai_stand(this); }
void gaunt_perch11(entity this) { set_animofs(this, anim_gaunt_perch, 11, gaunt_perch12); ai_stand(this); }
void gaunt_perch10(entity this) { set_animofs(this, anim_gaunt_perch, 10, gaunt_perch11); ai_stand(this); }
void gaunt_perch9(entity this) { set_animofs(this, anim_gaunt_perch, 9, gaunt_perch10); ai_stand(this); }
void gaunt_perch8(entity this) { set_animofs(this, anim_gaunt_perch, 8, gaunt_perch9); ai_stand(this); }
void gaunt_perch7(entity this) { set_animofs(this, anim_gaunt_perch, 7, gaunt_perch8); ai_stand(this); }
void gaunt_perch6(entity this) { set_animofs(this, anim_gaunt_perch, 6, gaunt_perch7); ai_stand(this); }
void gaunt_perch5(entity this) { set_animofs(this, anim_gaunt_perch, 5, gaunt_perch6); ai_stand(this); }
void gaunt_perch4(entity this) { set_animofs(this, anim_gaunt_perch, 4, gaunt_perch5); ai_stand(this); }
void gaunt_perch3(entity this) { set_animofs(this, anim_gaunt_perch, 3, gaunt_perch4); ai_stand(this); }
void gaunt_perch2(entity this) { set_animofs(this, anim_gaunt_perch, 2, gaunt_perch3); ai_stand(this); }
void gaunt_perch1(entity this)
{
	set_animofs(this, anim_gaunt_perch, 1, gaunt_perch2);
	_sound(this, CH_VOICE, "gaunt/sight.wav", 1, ATTN_NORM);
	ai_stand(this);
}

//----------------------------------------------------------------------
// Sightsound and very quick animation while moving forward
void gaunt_wakeup8(entity this) { set_animofs(this, anim_gaunt_launch, 8, gaunt_run1); FoundTarget(this); }
void gaunt_wakeup7(entity this) { set_animofs(this, anim_gaunt_launch, 7, gaunt_wakeup8); ai_forward(this, 4); }
void gaunt_wakeup6(entity this) { set_animofs(this, anim_gaunt_launch, 6, gaunt_wakeup7); gauntwings(this); ai_forward(this, 4); }
void gaunt_wakeup5(entity this) { set_animofs(this, anim_gaunt_launch, 5, gaunt_wakeup6); ai_forward(this, 4); }
void gaunt_wakeup4(entity this) { set_animofs(this, anim_gaunt_launch, 4, gaunt_wakeup5); ai_forward(this, 4); }
void gaunt_wakeup3(entity this) { set_animofs(this, anim_gaunt_launch, 3, gaunt_wakeup4); ai_forward(this, 4); }
void gaunt_wakeup2(entity this) { set_animofs(this, anim_gaunt_launch, 2, gaunt_wakeup3); ai_forward(this, 4); }
void gaunt_wakeup1(entity this)
{
	set_animofs(this, anim_gaunt_launch, 1, gaunt_wakeup2);
	_sound(this, CH_VOICE, "gaunt/sight.wav", 1, ATTN_NORM);
}

//----------------------------------------------------------------------
void gaunt_wakeup(entity this)
{
	// Dead already?
	if(this.health < 1)
		return;

	// No longer need perch spawnflag, remove it
	this.spawnflags &= ~MON_GAUNT_PERCH;

	this.takedamage = DAMAGE_AIM;		// Can receive damage
	this.use = func_null;				// no re-trigger
	
	// Restore all think state functions
	this.th_stand = gaunt_idle1;
	this.th_walk = gaunt_walk1;
	this.th_run = gaunt_run1;
	this.th_missile = gaunt_fire1;

	// Allow gaunt to fly up, no more ground checks
	this.flags |= FL_FLY;
	this.pain_finished = time + 1.5;		// No pain
	this.attack_finished = 1.5 + random();	// No skill adjustment
	gaunt_wakeup1(this);
}

//============================================================================
// Minion Wakeup
//============================================================================
void gaunt_minwake(entity this)
{
	set_animofs(this, anim_gaunt_hover, 1, gaunt_run1);
	// Is the gaunt stuck? cannot move?
	if(pointcontents(this.origin) == CONTENT_SOLID)
	{
		// Time to die!
		this.health = -70;
		Killed(this, this, this, DEATH_CRUSH.m_id);
	}
	else
	{
		// Restore all think state functions
		this.th_stand = gaunt_idle1;
		this.th_walk = gaunt_walk1;
		this.th_run = gaunt_run1;
		this.th_missile = gaunt_fire1;

		FoundTarget(this);
	}
}

//============================================================================
// Long - Swing wing around infront
void gaunt_painA6(entity this) { set_animofs(this, anim_gaunt_painA, 6, gaunt_run1); }
void gaunt_painA5(entity this) { set_animofs(this, anim_gaunt_painA, 5, gaunt_painA6); }
void gaunt_painA4(entity this) { set_animofs(this, anim_gaunt_painA, 4, gaunt_painA5); }
void gaunt_painA3(entity this) { set_animofs(this, anim_gaunt_painA, 3, gaunt_painA4); }
void gaunt_painA2(entity this) { set_animofs(this, anim_gaunt_painA, 2, gaunt_painA3); }
void gaunt_painA1(entity this) { set_animofs(this, anim_gaunt_painA, 1, gaunt_painA2); }

// Short - Knock head backward
void gaunt_painB5(entity this) { set_animofs(this, anim_gaunt_painB, 5, gaunt_run1); }
void gaunt_painB4(entity this) { set_animofs(this, anim_gaunt_painB, 4, gaunt_painB5); }
void gaunt_painB3(entity this) { set_animofs(this, anim_gaunt_painB, 3, gaunt_painB4); }
void gaunt_painB2(entity this) { set_animofs(this, anim_gaunt_painB, 2, gaunt_painB3); }
void gaunt_painB1(entity this) { set_animofs(this, anim_gaunt_painB, 1, gaunt_painB2); }

//----------------------------------------------------------------------
void gaunt_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health <= 0)
		return;
	if(random() * 200 > damage)
		return; // ddin't flinch
	if(this.pain_finished > time)
		return;

	// Check for perching gaunts, need special wakeup
	if(this.spawnflags & MON_GAUNT_PERCH)
		gaunt_wakeup(this);
	else
	{
		this.pain_finished = time + 2;

		// make sure any electricity is hidden
		if(this.attachment)
			gaunt_finish_attachment(this);

		// Any pain animation/sound required?
		_sound(this, CH_VOICE, "gaunt/pain.wav", 1, ATTN_NORM);
		if(random() < 0.4)
			gaunt_painB1(this);
		else
			gaunt_painA1(this);
	}
}

void gaunt_deathA8(entity this) { set_animofs(this, anim_gaunt_deathA, 8, gaunt_deathA8); CorpseThink(this); }
void gaunt_deathA7(entity this) { set_animofs(this, anim_gaunt_deathA, 7, gaunt_deathA8); }
void gaunt_deathA6(entity this) { set_animofs(this, anim_gaunt_deathA, 6, gaunt_deathA7); }
void gaunt_deathA5(entity this) { set_animofs(this, anim_gaunt_deathA, 5, gaunt_deathA6); }
void gaunt_deathA4(entity this) { set_animofs(this, anim_gaunt_deathA, 4, gaunt_deathA5); }
void gaunt_deathA3(entity this) { set_animofs(this, anim_gaunt_deathA, 3, gaunt_deathA4); }
void gaunt_deathA2(entity this) { set_animofs(this, anim_gaunt_deathA, 2, gaunt_deathA3); }
void gaunt_deathA1(entity this) { set_animofs(this, anim_gaunt_deathA, 1, gaunt_deathA2); this.solid = SOLID_NOT; }

void gaunt_deathB8(entity this) { set_animofs(this, anim_gaunt_deathB, 8, gaunt_deathB8); CorpseThink(this); }
void gaunt_deathB7(entity this) { set_animofs(this, anim_gaunt_deathB, 7, gaunt_deathB8); }
void gaunt_deathB6(entity this) { set_animofs(this, anim_gaunt_deathB, 6, gaunt_deathB7); }
void gaunt_deathB5(entity this) { set_animofs(this, anim_gaunt_deathB, 5, gaunt_deathB6); }
void gaunt_deathB4(entity this) { set_animofs(this, anim_gaunt_deathB, 4, gaunt_deathB5); }
void gaunt_deathB3(entity this) { set_animofs(this, anim_gaunt_deathB, 3, gaunt_deathB4); }
void gaunt_deathB2(entity this) { set_animofs(this, anim_gaunt_deathB, 2, gaunt_deathB3); }
void gaunt_deathB1(entity this) { set_animofs(this, anim_gaunt_deathB, 1, gaunt_deathB2); this.solid = SOLID_NOT; }

//----------------------------------------------------------------------
void gaunt_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	bool dogib = (this.spawnflags & MON_GAUNT_PERCH);

	// Make sure any wings sound is silenced
	_sound(this, CHAN_ITEM, "", 1, ATTN_NORM);

	// If creating a Fireball, make it explode!
	if(this.attachment)
	{
		if(this.attachment.state)
		{
			dogib = true;
			SpawnProjectileSmoke(this.origin, 200, 50, 150);
			SpawnProjectileSmoke(this.origin, 200, 50, 150);
			//particle_explode(this.origin-'0 0 16', 50+random()*50, 2, this.lip, PARTICLE_BURST_UPWARD);
			vector partpos = this.origin - '0 0 16';
			if(this.poisonous)
				te_explosion2(partpos, 50, 20);
			else
				te_explosion2(partpos, 225, 10);
			makevectors(this.angles);
			float explef = EXPLODE_PLASMA_BIG;
			if(this.poisonous)
				explef = EXPLODE_POISON_BIG;
			SpawnExplosion(explef, this.origin + v_forward*8, "weapons/r_exp3b.wav");
		}
		// make sure any electricity is hidden
		gaunt_remove_attachment(this);
	}

	if(this.health < -70 || dogib)
	{
		ThrowHead(this, inflictor, "progs/h_gaunt.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}
	
	
	// If not gibbed, then drop to ground
	_sound(this, CH_VOICE, "gaunt/death.wav", 1, ATTN_NORM);
	//this.flags = FL_MONSTER;				// reset all flag conditions
	set_movetype(this, MOVETYPE_TOSS);			// Affected by gravity
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	if(random() < 0.5)
		gaunt_deathA1(this);
	else
		gaunt_deathB1(this);
}

/*======================================================================
 GauntCheckAttack (No melee attack)
======================================================================*/
bool GauntCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
		
	if(!this.enemy_visible)
		return false;

	entity targ = this.enemy;
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot

	//----------------------------------------------------------------------
	// If setup to be a turret, check range attack only
	//----------------------------------------------------------------------
	if(this.movespeed < 0)
	{
		// Keep firing rockets when at range
		this.attack_finished = time + 2 + random();
		this.attack_state = AS_MISSILE;
		return true;
	}
	//----------------------------------------------------------------------
	// Range attack (Fireball)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if(time > this.attack_finished)
	{
		float attack_chance = 0;
		if(this.enemy_range == RANGE_MELEE) attack_chance = 0.9;		// range < 120 map units
		else if(this.enemy_range == RANGE_NEAR) attack_chance = 0.6;	// range < 500 map units
		else if(this.enemy_range == RANGE_MID) attack_chance = 0.2;	// range < 1000 map units
		if(random () < attack_chance)
		{
			if(this.enemy_range != RANGE_MELEE)
				this.attack_finished = time + (2 + random());
			this.attack_state = AS_MISSILE;
			return true;
		}
	}

	if(this.enemy_range >= RANGE_MID)
		this.attack_state = AS_STRAIGHT;
	else
		this.attack_state = AS_SLIDING;

	return true;
}

/*======================================================================
QUAKED monster_gaunt (1 0.2 0) (-16 -16 -24) (16 16 24)
======================================================================*/
spawnfunc(monster_gaunt) { monster_start(this, true, MON_GAUNT); }

// Re-direct all Quoth requests to Gaunt!
spawnfunc(monster_polyp)
{
	if(this.health <= 0)
		this.health = 200;
	this.poisonous = true;
	this.spawnflags |= SPAWNFLAG_NO_CONTENTS_DAMAGE;
	monster_start(this, true, MON_GAUNT);
}
#endif // SVQC

#ifdef SVQC
METHOD(Gaunt, mr_setup, bool(Gaunt this, entity actor))
{
    TC(Gaunt, this);

	precache_model("progs/mon_gaunt_elec.mdl");
	precache_model("progs/proj_gaplasma.mdl");

	precache_sound("gaunt/idle1.wav");
	precache_sound("gaunt/idle2.wav");
	precache_sound("gaunt/idle3.wav");

	precache_sound("gaunt/wings1.wav");
	precache_sound("gaunt/plasma_start.wav");
	precache_sound("gaunt/plasma_fire.wav");

	precache_sound("gaunt/pain.wav");
	precache_sound("gaunt/death.wav");

	precache_sound("weapons/r_exp3b.wav");

	actor.health = 120;
	actor.th_pain = gaunt_pain; 
	actor.th_die = gaunt_die;

	if(actor.flags & FL_CLONE)
		actor.poisonous = true; // clones are always poisonous? TODO: special adjustment for judge spawns

	if(actor.poisonous)
		precache_model("progs/proj_gaplasmagrn.mdl");

	// Perched Gaunt have special idle animation + idle sounds
	if(actor.spawnflags & MON_GAUNT_PERCH)
	{
		actor.th_stand = actor.th_walk = gaunt_perch1;
		actor.th_run = actor.th_missile = gaunt_wakeup;
		actor.flags &= ~FL_FLY; // unset flying type for now!
	}
	//----------------------------------------------------------------------
	// Special spawning minion need to start spinning
	else if(actor.flags & FL_CLONE) // TODO: custom flag
	{
		actor.th_stand = actor.th_walk = actor.th_run = actor.th_missile = gaunt_minwake;
	}
	//----------------------------------------------------------------------
	// Default gaunt setup
	else
	{
		actor.th_stand = gaunt_idle1;
		actor.th_walk = gaunt_walk1;
		actor.th_run = gaunt_run1;
		actor.th_missile = gaunt_fire1;
	}

	actor.checkattack = GauntCheckAttack;

    return true;
}
#endif
