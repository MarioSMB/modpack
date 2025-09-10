#include "boglord.qh"

#ifdef SVQC
const int anim_boglord_stand = 0; //'0 16 0'
const int anim_boglord_walk = 17; //'17 28 0'
const int anim_boglord_run = 29; //'29 34 0'
const int anim_boglord_smash = 35; //'35 46 0'
const int anim_boglord_swingr = 47; //'47 55 0'
const int anim_boglord_swingl = 56; //'47 64 0'
const int anim_boglord_magic = 65; //'65 76 0'
const int anim_boglord_pain = 77; //'77 82 0'
const int anim_boglord_death = 83; //'83 93 0'

const int MON_BOGL_STRONG = BIT(1);

.entity attachment, attachment2, attachment3;
.vector pos3;

void bogl_stand1(entity this);
void bogl_stand17(entity this) { set_animofs(this, anim_boglord_stand, 17, bogl_stand1); ai_stand(this); }
void bogl_stand16(entity this) { set_animofs(this, anim_boglord_stand, 16, bogl_stand17); ai_stand(this); }
void bogl_stand15(entity this) { set_animofs(this, anim_boglord_stand, 15, bogl_stand16); ai_stand(this); }
void bogl_stand14(entity this) { set_animofs(this, anim_boglord_stand, 14, bogl_stand15); ai_stand(this); }
void bogl_stand13(entity this) { set_animofs(this, anim_boglord_stand, 13, bogl_stand14); ai_stand(this); }
void bogl_stand12(entity this) { set_animofs(this, anim_boglord_stand, 12, bogl_stand13); ai_stand(this); }
void bogl_stand11(entity this) { set_animofs(this, anim_boglord_stand, 11, bogl_stand12); ai_stand(this); }
void bogl_stand10(entity this) { set_animofs(this, anim_boglord_stand, 10, bogl_stand11); ai_stand(this); }
void bogl_stand9(entity this) { set_animofs(this, anim_boglord_stand, 9, bogl_stand10); ai_stand(this); }
void bogl_stand8(entity this) { set_animofs(this, anim_boglord_stand, 8, bogl_stand9); ai_stand(this); }
void bogl_stand7(entity this) { set_animofs(this, anim_boglord_stand, 7, bogl_stand8); ai_stand(this); }
void bogl_stand6(entity this) { set_animofs(this, anim_boglord_stand, 6, bogl_stand7); ai_stand(this); }
void bogl_stand5(entity this) { set_animofs(this, anim_boglord_stand, 5, bogl_stand6); ai_stand(this); }
void bogl_stand4(entity this) { set_animofs(this, anim_boglord_stand, 4, bogl_stand5); ai_stand(this); }
void bogl_stand3(entity this) { set_animofs(this, anim_boglord_stand, 3, bogl_stand4); ai_stand(this); }
void bogl_stand2(entity this) { set_animofs(this, anim_boglord_stand, 2, bogl_stand3); ai_stand(this); }
void bogl_stand1(entity this)
{
	set_animofs(this, anim_boglord_stand, 1, bogl_stand2);
	ai_stand(this);
	if(random() < 0.7)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "boglord/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "boglord/idle2.wav", 1, ATTN_IDLE);
	}
}

void bogl_walk1(entity this);
void bogl_walk12(entity this) { set_animofs(this, anim_boglord_walk, 12, bogl_walk1); ai_walk(this, 7); }
void bogl_walk11(entity this) { set_animofs(this, anim_boglord_walk, 11, bogl_walk12); ai_walk(this, 7); }
void bogl_walk10(entity this) { set_animofs(this, anim_boglord_walk, 10, bogl_walk11); ai_walk(this, 9); }
void bogl_walk9(entity this) { set_animofs(this, anim_boglord_walk, 9, bogl_walk10); ai_walk(this, 13); }
void bogl_walk8(entity this) { set_animofs(this, anim_boglord_walk, 8, bogl_walk9); ai_walk(this, 3); }
void bogl_walk7(entity this) { set_animofs(this, anim_boglord_walk, 7, bogl_walk8); ai_walk(this, 8); }
void bogl_walk6(entity this) { set_animofs(this, anim_boglord_walk, 6, bogl_walk7); ai_walk(this, 12); }
void bogl_walk5(entity this) { set_animofs(this, anim_boglord_walk, 5, bogl_walk6); ai_walk(this, 6); }
void bogl_walk4(entity this) { set_animofs(this, anim_boglord_walk, 4, bogl_walk5); ai_walk(this, 5); }
void bogl_walk3(entity this) { set_animofs(this, anim_boglord_walk, 3, bogl_walk4); ai_walk(this, 9); }
void bogl_walk2(entity this) { set_animofs(this, anim_boglord_walk, 2, bogl_walk3); ai_walk(this, 9); }
void bogl_walk1(entity this)
{
	set_animofs(this, anim_boglord_walk, 1, bogl_walk2);
	ai_walk(this, 10);
	if(random() < 0.7)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "boglord/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "boglord/idle2.wav", 1, ATTN_IDLE);
	}
}

void bogl_run1(entity this);
void bogl_run6(entity this) { set_animofs(this, anim_boglord_run, 6, bogl_run1); ai_run(this, 20); }
void bogl_run5(entity this) { set_animofs(this, anim_boglord_run, 5, bogl_run6); ai_run(this, 24); }
void bogl_run4(entity this) { set_animofs(this, anim_boglord_run, 4, bogl_run5); ai_run(this, 20); }
void bogl_run3(entity this) { set_animofs(this, anim_boglord_run, 3, bogl_run4); ai_run(this, 20); }
void bogl_run2(entity this) { set_animofs(this, anim_boglord_run, 2, bogl_run3); ai_run(this, 24); }
void bogl_run1(entity this)
{
	set_animofs(this, anim_boglord_run, 1, bogl_run2);
	ai_run(this, 20);
	if(random() < 0.7)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "boglord/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "boglord/idle2.wav", 1, ATTN_IDLE);
	}
}

//============================================================================
// Attachment management (create, finish and delete)
//============================================================================
void bogl_create_attachment(entity this)
{
	// Are the attachments setup yet?
	if(!this.attachment)
	{
		this.attachment = spawn();
		this.attachment.owner = this;
		this.attachment.classname = "boglord_attachment";
		this.attachment.alpha = 0.85;
	}
	if(!this.attachment2)
	{
		this.attachment2 = spawn();
		this.attachment2.owner = this;
		this.attachment2.classname = "boglord_attachment";
		this.attachment2.alpha = 0.85;
	}

	if(!this.attachment3)
	{
		this.attachment3 = spawn();
		this.attachment3.owner = this;
		this.attachment3.classname = "boglord_attachment";
		this.attachment3.alpha = 1.0;
	}
}

//----------------------------------------------------------------------
void bogl_finish_attachment(entity this)
{
	if(this.attachment)
	{
		setmodel(this.attachment, MDL_Null);
		setsize(this.attachment, '0 0 0', '0 0 0');
	}
	if(this.attachment2)
	{
		setmodel(this.attachment2, MDL_Null);
		setsize(this.attachment2, '0 0 0', '0 0 0');
	}
	if(this.attachment3)
	{
		setmodel(this.attachment3, MDL_Null);
		setsize(this.attachment3, '0 0 0', '0 0 0');
	}
}

//----------------------------------------------------------------------
void bogl_remove_attachment(entity this)
{
	if(this.attachment)
	{
		setthink(this.attachment, SUB_Remove);
		this.attachment.nextthink = time + 0.1;
		this.attachment = NULL;
	}
	if(this.attachment2)
	{
		setthink(this.attachment2, SUB_Remove);
		this.attachment2.nextthink = time + 0.1;
		this.attachment2 = NULL;
	}
	if(this.attachment3)
	{
		setthink(this.attachment3, SUB_Remove);
		this.attachment3.nextthink = time + 0.1;
		this.attachment3 = NULL;
	}
}

void BogLordMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this, 20, this.projectiledeathtype);	
	}

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this, 110, this.projectiledeathtype);	
	T_RadiusDamage(this, this.owner, 30, this.projectiledeathtype, toucher);
	_sound(this, CH_WEAPON_SINGLE, "boglord/slime_explode.wav", 1, ATTN_NORM);

	if(!(this.owner.spawnflags & MON_BOGL_STRONG))
	{
		// Don't spawn gib models at impact (could be solid)
		vector giborg = this.origin - 8*normalize(this.velocity);

		float gibcnt = rint(0.5 + random()*3);
		for(int j = 0; j < gibcnt; ++j)
		{
			entity gib = ThrowGib(this, toucher, "progs/proj_blord1s.mdl", gibcnt);
			setorigin(gib, giborg);
			gib.frame = 9;
		}
	}

	te_explosion(this.origin);

	delete(this);
}

entity bogl_Launch_Missile(entity this, vector org, vector dir, vector avel, float pspeed)
{
	entity newmis = launch_spike(this, org, dir);
	newmis.classname = "boglord_slime";
	settouch(newmis, BogLordMissileTouch);
	newmis.projectiledeathtype = DEATH_MONSTER_BOGLORD.m_id;
	newmis.poisonous = this.poisonous;

	if(this.spawnflags & MON_BOGL_STRONG)
		_setmodel(newmis, "progs/proj_blord2b.mdl");
	else
		_setmodel(newmis, "progs/proj_blord1b.mdl");

	newmis.frame = 7;
	return newmis;
}

//======================================================================
// RANGE ATTACK 1 - overhead SMASH/slime
//======================================================================
void bogl_throwslime(entity this, vector leftofs, vector rightofs)
{
	vector org, btarg, dir, avel;
	
	// Finished with growing balls of slime
	bogl_finish_attachment(this);

	if(!this.enemy || this.health < 1)
		return;

	ai_face(this);
	makevectors(this.angles);
	this.effects |= EF_MUZZLEFLASH;
	float aspeed = 600;

	// Fire left hand off center and at players feet
	org = this.origin + attack_vector(leftofs);
	btarg = this.enemy.origin + v_right * 8 - v_up * 8;
	dir = normalize(btarg - org);
	avel.x = 100 + random() * 200;
	avel.y = 100 + random() * 200;
	avel.z = 100 + random() * 200;
	bogl_Launch_Missile(this, org, dir, avel, aspeed);

	// Fire right hand off center and at players feet
	org = this.origin + attack_vector(rightofs);
	btarg = this.enemy.origin - v_right * 8 - v_up * 8;
	dir = normalize(btarg - org);
	avel.x = 100 + random() * 200;
	avel.y = 100 + random() * 200;
	avel.z = 100 + random() * 200;
	bogl_Launch_Missile(this, org, dir, avel, aspeed);
}

//----------------------------------------------------------------------
void bogl_slimeball(entity this, vector leftofs, vector rightofs, float sbframe, float chfeet)
{
	vector org;
	if(this.health < 1)
		return;

	// Check if attachment has been setup yet
	if(!this.attachment)
		bogl_create_attachment(this);
	
	// Frame 0 is start of the sequence (move everything into place)
	if(sbframe == 0)
	{
		setorigin(this.attachment, this.origin);
		if(this.spawnflags & MON_BOGL_STRONG) 
			_setmodel(this.attachment, "progs/proj_blord2b.mdl");
		else
			_setmodel(this.attachment, "progs/proj_blord1b.mdl");
		setsize(this.attachment, '0 0 0', '0 0 0');
		set_movetype(this.attachment, MOVETYPE_NONE);
		this.attachment.solid = SOLID_NOT;
		
		setorigin(this.attachment2, this.origin);
		if(this.spawnflags & MON_BOGL_STRONG) 
			_setmodel(this.attachment2, "progs/proj_blord2b.mdl");
		else
			_setmodel(this.attachment2, "progs/proj_blord1b.mdl");
		setsize(this.attachment2, '0 0 0', '0 0 0');
		set_movetype(this.attachment2, MOVETYPE_NONE);
		this.attachment2.solid = SOLID_NOT;
	}
	
	// Move+Turn towards enemy and make vector
	ai_charge(this, chfeet);
	makevectors(this.angles);
	
	// Generate attachment in hand (left)
	org = this.origin + attack_vector(leftofs);
	setorigin(this.attachment, org);
	this.attachment.angles_y = rint(random() * 359);
	this.attachment.frame = sbframe;

	// Generate attachment in hand (right)
	org = this.origin + attack_vector(rightofs);
	setorigin(this.attachment2, org);
	this.attachment2.angles_y = rint(random() * 359);
	this.attachment2.frame = sbframe;
}

void bogl_smash12(entity this) { set_animofs(this, anim_boglord_smash, 12, bogl_run1); ai_charge(this, 4); }
void bogl_smash11(entity this) { set_animofs(this, anim_boglord_smash, 11, bogl_smash12); ai_charge(this, 5); }
void bogl_smash10(entity this) { set_animofs(this, anim_boglord_smash, 10, bogl_smash11); ai_charge(this, 0); }
void bogl_smash9(entity this) { set_animofs(this, anim_boglord_smash, 9, bogl_smash10); bogl_throwslime(this, '32 24 108','42 -18 108'); }
void bogl_smash8(entity this) { set_animofs(this, anim_boglord_smash, 8, bogl_smash9); bogl_slimeball(this, '32 24 108','42 -18 108',6,0); }
void bogl_smash7(entity this) { set_animofs(this, anim_boglord_smash, 7, bogl_smash8); bogl_slimeball(this, '-24 20 114','-26 -14 124',5,0); }
void bogl_smash6(entity this) { set_animofs(this, anim_boglord_smash, 6, bogl_smash7); bogl_slimeball(this, '-58 20 109','-62 -17 110',4,1); }
void bogl_smash5(entity this) { set_animofs(this, anim_boglord_smash, 5, bogl_smash6); bogl_slimeball(this, '-58 30 114','-60 -30 114',3,4); }
void bogl_smash4(entity this) { set_animofs(this, anim_boglord_smash, 4, bogl_smash5); bogl_slimeball(this, '-34 48 122','-34 -48 124',2,5); }
void bogl_smash3(entity this) { set_animofs(this, anim_boglord_smash, 3, bogl_smash4); bogl_slimeball(this, '-5 66 102','2 -58 104',1,6); }
void bogl_smash2(entity this) { set_animofs(this, anim_boglord_smash, 2, bogl_smash3); bogl_slimeball(this, '21 70 60','32 -53 64',0,6); }
void bogl_smash1(entity this)
{
	set_animofs(this, anim_boglord_smash, 1, bogl_smash2);
	ai_charge(this, 2);

	float r = random();
	if(r < 0.33)
		_sound(this, CH_VOICE, "boglord/melee1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_VOICE, "boglord/melee2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "boglord/melee3.wav", 1, ATTN_NORM);
}

//============================================================================

entity blord_launch_projectile(entity this, vector org, vector dir, float pspeed)
{
	entity newmis = launch_spike(this, org, dir);
	newmis.classname = "boglord_bolt";
	newmis.projectiledeathtype = DEATH_MONSTER_BOGLORD.m_id;
	newmis.velocity = dir * pspeed;
	newmis.dmg = 20;

	if(this.spawnflags & MON_BOGL_STRONG)
		_setmodel(newmis, "progs/proj_blordbolt2.mdl");
	else
		_setmodel(newmis, "progs/proj_blordbolt1.mdl");

	newmis.angles = vectoangles(newmis.velocity);
	newmis.poisonous = this.poisonous;
	return newmis;
}

//======================================================================
// RANGE ATTACK 2 - Projectile Lightning attack
//======================================================================
void bogl_lightning(entity this)
{
	vector org, dir, vec;
	if(this.health < 1)
		return;
	
	ai_face(this);
	this.effects |= EF_MUZZLEFLASH;

	float aspeed = 700;
	_sound(this, CH_WEAPON_SINGLE, "boglord/bolt_fire.wav", 1, ATTN_NORM);	

	// Aim around player
	makevectors (this.angles);
	org = this.pos3 + randomvec() * 10;
	vec = v_right * (crandom() * (20 + random() * 50));
	dir = normalize((this.enemy.origin + vec) - org);
	blord_launch_projectile(this, org, dir, aspeed);

	org = this.pos3 + randomvec() * 10;
	vec = v_right * (crandom() * (20 + random() * 50));
	dir = normalize((this.enemy.origin + vec) - org);
	blord_launch_projectile(this, org, dir, aspeed);
}

//----------------------------------------------------------------------
void bogl_casting(entity this, vector leftofs, vector rightofs, float sbframe)
{
	if(this.health < 1)
		return;

	// Check if attachment has been setup yet
	if(!this.attachment)
		bogl_create_attachment(this);

	// Frame 0 is start of the sequence (move everything into place)
	if(sbframe == 0)
	{
		setorigin(this.attachment, this.origin);
		if(this.spawnflags & MON_BOGL_STRONG) 
			_setmodel(this.attachment, "progs/proj_blordbeam2.mdl");
		else
			_setmodel(this.attachment, "progs/proj_blordbeam1.mdl");
		setsize(this.attachment, '0 0 0', '0 0 0');
		set_movetype(this.attachment, MOVETYPE_NONE);
		this.attachment.solid = SOLID_NOT;
		this.attachment.frame = 1;

		setorigin(this.attachment2, this.origin);
		if(this.spawnflags & MON_BOGL_STRONG) 
			_setmodel(this.attachment2, "progs/proj_blordbeam2.mdl");
		else
			_setmodel(this.attachment2, "progs/proj_blordbeam1.mdl");
		setsize(this.attachment2, '0 0 0', '0 0 0');
		set_movetype(this.attachment2, MOVETYPE_NONE);
		this.attachment2.solid = SOLID_NOT;
		this.attachment2.frame = 1;

		setorigin(this.attachment3, this.origin);
		if(this.spawnflags & MON_BOGL_STRONG) 
			_setmodel(this.attachment3, "progs/proj_blord2b.mdl");
		else
			_setmodel(this.attachment3, "progs/proj_blord1b.mdl");
		setsize(this.attachment3, '0 0 0', '0 0 0');
		set_movetype(this.attachment3, MOVETYPE_NONE);
		this.attachment3.solid = SOLID_NOT;
	}
	
	// Turn toward enemy
	ai_face(this);
	makevectors(this.angles);

	// Work out each hand position
	this.pos1 = this.origin + attack_vector(leftofs);
	this.pos2 = this.origin + attack_vector(rightofs);
	vector dir = normalize(this.pos2 - this.pos1);
	vector tang = vectoangles(dir);
	// Calculate the mid point between the hands for the orb
	float midpoint = vlen(this.pos2 - this.pos1) * 0.5;
	this.pos3 = this.pos1 + (dir * midpoint);

	// Move beam sections into place along vector
	setorigin(this.attachment, this.pos1 + (dir * 16));
	setorigin(this.attachment2, this.pos2 - (dir * 16));
	this.attachment.angles = this.attachment2.angles = tang;
	
	// Place orb in the center of the electricity
	setorigin(this.attachment3, this.pos3);
	this.attachment3.angles_y = rint(random() * 359);
	this.attachment3.frame = sbframe + 8;
	
	//particle_explode(this.pos1, 5+random()*5, 1, this.part_style, PARTICLE_BURST_LOSTUP);
	//particle_explode(this.pos2, 5+random()*5, 1, this.part_style, PARTICLE_BURST_LOSTUP);

	te_explosion2(this.pos1, 5 + random() * 5, 1);
	te_explosion2(this.pos2, 5 + random() * 5, 1);
}

void bogl_magic12(entity this) { set_animofs(this, anim_boglord_magic, 12, bogl_run1); }
void bogl_magic11(entity this) { set_animofs(this, anim_boglord_magic, 11, bogl_magic12); }
void bogl_magic10(entity this) { set_animofs(this, anim_boglord_magic, 10, bogl_magic11); bogl_lightning(this); }
void bogl_magic9(entity this) { set_animofs(this, anim_boglord_magic, 9, bogl_magic10); bogl_lightning(this); }
void bogl_magic6(entity this)
{
	set_animofs(this, anim_boglord_magic, 6, bogl_magic9);
	bogl_lightning(this);
	// Finished with growing ball of energy
	bogl_finish_attachment(this);
	int peffect = (this.spawnflags & MON_BOGL_STRONG) ? EXPLODE_MED : EXPLODE_POISON_MED;
	SpawnExplosion(peffect, this.pos3, "boglord/slime_explode.wav");
}
void bogl_magic5(entity this) { set_animofs(this, anim_boglord_magic, 5, bogl_magic6); bogl_casting(this, '-3 34 119','19 -15 110', 3); }
void bogl_magic4(entity this) { set_animofs(this, anim_boglord_magic, 4, bogl_magic5); bogl_casting(this, '-28 48 100','6 3 110', 2); }
void bogl_magic3(entity this) { set_animofs(this, anim_boglord_magic, 3, bogl_magic4); bogl_casting(this, '-16 50 95','11 0 108', 1); }
void bogl_magic2(entity this) { set_animofs(this, anim_boglord_magic, 2, bogl_magic3); bogl_casting(this, '0 53 86','21 -10 102', 0); }
void bogl_magic1(entity this)
{
	set_animofs(this, anim_boglord_magic, 1, bogl_magic2);
	ai_face(this);
	this.pain_finished = time + 1;
	_sound(this, CH_WEAPON_SINGLE, "boglord/attack2.wav", 1, ATTN_NORM);
}

void bogl_pain6(entity this) { set_animofs(this, anim_boglord_pain, 6, bogl_run1); }
void bogl_pain5(entity this) { set_animofs(this, anim_boglord_pain, 5, bogl_pain6); }
void bogl_pain4(entity this) { set_animofs(this, anim_boglord_pain, 4, bogl_pain5); }
void bogl_pain3(entity this) { set_animofs(this, anim_boglord_pain, 3, bogl_pain4); }
void bogl_pain2(entity this) { set_animofs(this, anim_boglord_pain, 2, bogl_pain3); }
void bogl_pain1(entity this) { set_animofs(this, anim_boglord_pain, 1, bogl_pain2); }

void bogl_pain(entity this, entity attacker, float damage, int deathtype)
{
	// Finish with all attachments
	bogl_finish_attachment(this);

	if(this.health <= 0)
		return;		// allready dying, don't go into pain frame

	if(random() < 0.5)
		_sound(this, CH_VOICE, "boglord/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "boglord/pain2.wav", 1, ATTN_NORM);

	if(random()*400 > damage)
		return;		// didn't flinch

	if(this.pain_finished > time)
		return;
	this.pain_finished = time + 2;
		
	bogl_pain1(this);
}


//============================================================================

void bogl_death11(entity this) { set_animofs(this, anim_boglord_death, 11, bogl_death11); CorpseThink(this); }
void bogl_death10(entity this) { set_animofs(this, anim_boglord_death, 10, bogl_death11); }
void bogl_death9(entity this) { set_animofs(this, anim_boglord_death, 9, bogl_death10); }
void bogl_death8(entity this) { set_animofs(this, anim_boglord_death, 8, bogl_death9); }
void bogl_death7(entity this) { set_animofs(this, anim_boglord_death, 7, bogl_death8); }
void bogl_death6(entity this) { set_animofs(this, anim_boglord_death, 6, bogl_death7); }
void bogl_death5(entity this) { set_animofs(this, anim_boglord_death, 5, bogl_death6); }
void bogl_death4(entity this) { set_animofs(this, anim_boglord_death, 4, bogl_death5); }
void bogl_death3(entity this) { set_animofs(this, anim_boglord_death, 3, bogl_death4); }
void bogl_death2(entity this) { set_animofs(this, anim_boglord_death, 2, bogl_death3); }
void bogl_death1(entity this) { set_animofs(this, anim_boglord_death, 1, bogl_death2); this.solid = SOLID_NOT; }

void bogl_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	// Finish and remove all attachments
	bogl_finish_attachment(this);
	bogl_remove_attachment(this);

// check for gib
	if(this.health < -60 || this.dmg_take > (this.max_health * 0.6))
	{
		T_RadiusDamage(this, this, this.dmg, DEATH_MONSTER_BOGLORD.m_id, this);
		te_explosion(this.origin);
		SpawnExplosion(EXPLODE_SMALL, this.origin, "weapons/r_exp3b.wav");
		if(this.spawnflags & MON_BOGL_STRONG)
		{
			ThrowHead(this, inflictor, "progs/h_boglordb.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blclaw1b.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blclaw2b.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blfoot1b.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blfoot2b.mdl", this.health);
		}
		else
		{
			ThrowHead(this, inflictor, "progs/h_boglord.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blclaw1.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blclaw2.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blfoot1.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib_blfoot2.mdl", this.health);
		}
		return;
	}

// regular death
	_sound(this, CH_VOICE, "boglord/death1.wav", 1, ATTN_NORM);
	bogl_death1(this);
}

/*======================================================================
 BogLordCheckAttack (Shambler model)
======================================================================*/
bool BogLordCheckAttack(entity this)
{
	float achance;

	if(this.attack_rage > 0)
	{
		if(time > this.attack_finished && this.enemy_visible)
		{
			if(this.attack_rage > random())
			{
				this.attack_state = AS_MELEE;
				this.th_melee(this);
				return true;
			}
			else
				this.attack_state = AS_MISSILE;
			return true;
		}
	}

	if(vdist(this.enemy.origin - this.origin, <, 200) && CanDamage(this.enemy, this))
	{
		// Easy to dodge ball attack, bolts are more difficult
		if(this.spawnflags & MON_BOGL_STRONG)
			achance = random();
		else
		{
			// Easy = 10%, Normal = 20%, Hard = 30%, NM = 40%
			achance = 0.1 + (autocvar_skill * 0.1);
		}
		if(random() < achance)
			this.attack_state = AS_MISSILE;
		else
		{
			this.attack_state = AS_MELEE;
			this.th_melee(this);
		}
		this.attack_finished = time + (1 + 2 * random());
		return true;
	}

	//if(this.enemy_range == RANGE_FAR)
		//return false;
	if(time < this.attack_finished)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vdist(spot1 - spot2, >, 600))
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
	
	// Setup attack chance of using fast bolt attack more often
	// easy=0.0, norm=0.2, hard=0.4, nm=0.6
	// The stronger version is just pure random 50/50
	if(this.spawnflags & MON_BOGL_STRONG)
		achance = random();
	else
	{
		// Easy = 10%, Normal = 20%, Hard = 30%, NM = 40%
		achance = 0.0 + (autocvar_skill * 0.2);
	}
	if(random() < achance)
		this.attack_state = AS_MISSILE;
	else
	{
		this.attack_state = AS_MELEE;
		this.th_melee(this);
	}

	this.attack_finished = time + (1 + 2 * random());
	return true;
}

/*======================================================================
QUAKED monster_boglord (1 0 0) (-32 -32 -24) (32 32 64) Ambush
======================================================================*/
spawnfunc(monster_boglord) { monster_start(this, true, MON_BOGLORD); }
#endif // SVQC

#ifdef SVQC
METHOD(BogLord, mr_setup, bool(BogLord this, entity actor))
{
    TC(BogLord, this);

	precache_model("progs/gib_blclaw1.mdl");
	precache_model("progs/gib_blclaw2.mdl");
	precache_model("progs/gib_blfoot1.mdl");
	precache_model("progs/gib_blfoot2.mdl");

	precache_model("progs/proj_blord1b.mdl");
	precache_model("progs/proj_blord1s.mdl");
	precache_model("progs/proj_blordbolt1.mdl");
	precache_model("progs/proj_blordbeam1.mdl");
	precache_model("progs/proj_blord2b.mdl");
	//precache_model("progs/proj_blord2s.mdl");
	precache_model("progs/proj_blordbolt2.mdl");
	precache_model("progs/proj_blordbeam2.mdl");

	precache_sound("boglord/idle1.wav");
	precache_sound("boglord/idle2.wav");
	precache_sound("boglord/death1.wav");
	precache_sound("boglord/pain1.wav");
	precache_sound("boglord/pain2.wav");

	precache_sound("boglord/melee1.wav");
	precache_sound("boglord/melee2.wav");
	precache_sound("boglord/melee3.wav");
	precache_sound("boglord/bolt_fire.wav");
	precache_sound("boglord/slime_explode.wav");
	precache_sound("weapons/r_exp3b.wav");
	precache_sound("boglord/attack2.wav");
	precache_sound("boglord/slime_explode.wav");
	precache_sound("boglord/slime_miss.wav");
	// Melee attacks no longer used anymore
	// TODO?
	//precache_sound("boglord/smack.wav");

	precache_sound("boglord/thud.wav");
	precache_sound("boglord/bangdoor1.wav");
	precache_sound("boglord/bangdoor2.wav");

	// Special Rage attack mode ( >0 = enabled )
	// Closer to 0 = Lightning attack, Closer to 1 = Ball attack
	// Make sure percentage chance within range of 0-1
	if(actor.attack_rage <= 0)
		actor.attack_rage = 0;
	if(actor.attack_rage >= 1)
		actor.attack_rage = 1;

	if(actor.spawnflags & MON_BOGL_STRONG)
	{
		actor.health = 2000;
		actor.skin = 1;
		actor.poisonous = false;
	}
	else
	{
    	actor.health = 1600;
		actor.skin = 0;
		actor.poisonous = true;
	}

    actor.th_stand = bogl_stand1;
	actor.th_walk = bogl_walk1;
	actor.th_run = bogl_run1;
	actor.th_die = bogl_die;
	actor.th_melee = bogl_smash1;
	actor.th_missile = bogl_magic1;
	actor.th_pain = bogl_pain;

	actor.checkattack = BogLordCheckAttack;

    return true;
}
#endif
