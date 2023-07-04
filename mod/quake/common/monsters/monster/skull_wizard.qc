#include "skull_wizard.qh"

#include "lost_soul.qh"

/*==============================================================================
SKULL WIZARD (Hexen2 model by Raven Software)
==============================================================================*/

#ifdef SVQC
const int anim_skullwiz_death = 0; //'0 14 0'
const int anim_skullwiz_summon = 15; //'15 44 0'
const int anim_skullwiz_paina = 45; //'45 56 0'
const int anim_skullwiz_transa = 57; //'57 68 0'
const int anim_skullwiz_spella = 69; //'69 84 0'
const int anim_skullwiz_spellb = 85; //'85 99 0'
const int anim_skullwiz_transb = 100; //'100 106 0'
const int anim_skullwiz_stand = 107; //'107 125 0'
const int anim_skullwiz_walk = 126; //'126 149 0'
const int anim_skullwiz_tele = 150; //'150 158 0'

.int bodyphased;
// Skull wizard starting state
const int MONAI_SKULLWSOLID = 1;		// Regular spawn state
const int MONAI_SKULLWINVIS = 2;		// Invisible

const int MON_SKULLWIZ_GUARDIAN = 2;	// Special version guarding the runes
const int MON_SKULLWIZ_MINIONS = 4;

.bool bodystatic; // Prevents skull wizard from teleporting

.int skullwizard_summonflag;
.entity attachment;
.float distance;

.int idlebusy;
const int SKULLW_STAND = 1;
const int SKULLW_WALK = 2;
const int SKULLW_HEIGHT = 96;
const int SKULLW_DISTMIN = 256;
const int SKULLW_DISTMAX = 512;

.entity movelast;

void skullw_stand1(entity this);
void skullw_stand14(entity this) { set_animofs(this, anim_skullwiz_stand, 19, skullw_stand1); ai_stand(this); }
void skullw_stand13(entity this) { set_animofs(this, anim_skullwiz_stand, 17, skullw_stand14); ai_stand(this); }
void skullw_stand12(entity this) { set_animofs(this, anim_skullwiz_stand, 15, skullw_stand13); ai_stand(this); }
void skullw_stand11(entity this) { set_animofs(this, anim_skullwiz_stand, 13, skullw_stand12); ai_stand(this); }
void skullw_stand10(entity this) { set_animofs(this, anim_skullwiz_stand, 11, skullw_stand11); ai_stand(this); }
void skullw_stand9(entity this) { set_animofs(this, anim_skullwiz_stand, 9, skullw_stand10); ai_stand(this); }
void skullw_stand8(entity this) { set_animofs(this, anim_skullwiz_stand, 7, skullw_stand9); ai_stand(this); }
void skullw_stand7(entity this) { set_animofs(this, anim_skullwiz_stand, 5, skullw_stand8); ai_stand(this); }
void skullw_stand6(entity this) { set_animofs(this, anim_skullwiz_stand, 3, skullw_stand7); ai_stand(this); }
void skullw_stand5(entity this) { set_animofs(this, anim_skullwiz_stand, 12, skullw_stand6); ai_stand(this); }
void skullw_stand4(entity this) { set_animofs(this, anim_skullwiz_stand, 14, skullw_stand5); ai_stand(this); }
void skullw_stand3(entity this) { set_animofs(this, anim_skullwiz_stand, 16, skullw_stand4); ai_stand(this); }
void skullw_stand2(entity this) { set_animofs(this, anim_skullwiz_stand, 18, skullw_stand3); ai_stand(this); }
void skullw_stand1(entity this)
{
	set_animofs(this, anim_skullwiz_stand, 1, skullw_stand2);
	this.idlebusy = SKULLW_STAND;
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "skullwiz/idle1.wav" : "skullwiz/idle2.wav"), 1, ATTN_IDLE);
	ai_stand(this);
}

void skullw_walk1(entity this);
void skullw_walk16(entity this) { set_animofs(this, anim_skullwiz_walk, 22, skullw_walk1); ai_walk(this, 3); }
void skullw_walk15(entity this) { set_animofs(this, anim_skullwiz_walk, 20, skullw_walk16); ai_walk(this, 2); }
void skullw_walk14(entity this) { set_animofs(this, anim_skullwiz_walk, 19, skullw_walk15); ai_walk(this, 2); }
void skullw_walk13(entity this) { set_animofs(this, anim_skullwiz_walk, 17, skullw_walk14); ai_walk(this, 4); }
void skullw_walk12(entity this) { set_animofs(this, anim_skullwiz_walk, 16, skullw_walk13); ai_walk(this, 4); }
void skullw_walk11(entity this) { set_animofs(this, anim_skullwiz_walk, 15, skullw_walk12); ai_walk(this, 5); }
void skullw_walk10(entity this) { set_animofs(this, anim_skullwiz_walk, 13, skullw_walk11); ai_walk(this, 5); }
void skullw_walk9(entity this) { set_animofs(this, anim_skullwiz_walk, 12, skullw_walk10); ai_walk(this, 2); }
void skullw_walk8(entity this) { set_animofs(this, anim_skullwiz_walk, 11, skullw_walk9); ai_walk(this, 2); }
void skullw_walk7(entity this) { set_animofs(this, anim_skullwiz_walk, 9, skullw_walk8); ai_walk(this, 2); }
void skullw_walk6(entity this) { set_animofs(this, anim_skullwiz_walk, 8, skullw_walk7); ai_walk(this, 2); }
void skullw_walk5(entity this) { set_animofs(this, anim_skullwiz_walk, 7, skullw_walk6); ai_walk(this, 4); }
void skullw_walk4(entity this) { set_animofs(this, anim_skullwiz_walk, 5, skullw_walk5); ai_walk(this, 4); }
void skullw_walk3(entity this) { set_animofs(this, anim_skullwiz_walk, 4, skullw_walk4); ai_walk(this, 5); }
void skullw_walk2(entity this) { set_animofs(this, anim_skullwiz_walk, 3, skullw_walk3); ai_walk(this, 5); }
void skullw_walk1(entity this)
{
	set_animofs(this, anim_skullwiz_walk, 1, skullw_walk2);
	this.idlebusy = SKULLW_WALK;
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "skullwiz/idle1.wav" : "skullwiz/idle2.wav"), 1, ATTN_IDLE);
	ai_walk(this, 2);
}

//============================================================================
// WALK -> STAND
void skullw_transA4(entity this) { set_animofs(this, anim_skullwiz_transa, 11, skullw_stand1); }
void skullw_transA3(entity this) { set_animofs(this, anim_skullwiz_transa, 9, skullw_transA4); }
void skullw_transA2(entity this) { set_animofs(this, anim_skullwiz_transa, 7, skullw_transA3); }
void skullw_transA1(entity this) { set_animofs(this, anim_skullwiz_transa, 5, skullw_transA2); }

// STAND -> WALK
void skullw_transB3(entity this) { set_animofs(this, anim_skullwiz_transb, 7, skullw_walk1); }
void skullw_transB2(entity this) { set_animofs(this, anim_skullwiz_transb, 5, skullw_transB3); }
void skullw_transB1(entity this) { set_animofs(this, anim_skullwiz_transb, 3, skullw_transB2); }

//----------------------------------------------------------------------
void skullw_stand(entity this)
{
	if(this.idlebusy == SKULLW_WALK)
		skullw_transA1(this);
	else
		skullw_stand1(this);
}

//----------------------------------------------------------------------
void skullw_walk(entity this)
{
	if(this.idlebusy == SKULLW_STAND)
		skullw_transB1(this);
	else
		skullw_walk1(this);
}

void skullw_run1(entity this);
void skullw_run14(entity this) { set_animofs(this, anim_skullwiz_stand, 19, skullw_run1); ai_run(this, 0); }
void skullw_run13(entity this) { set_animofs(this, anim_skullwiz_stand, 17, skullw_run14); ai_run(this, 0); }
void skullw_run12(entity this) { set_animofs(this, anim_skullwiz_stand, 15, skullw_run13); ai_run(this, 0); }
void skullw_run11(entity this) { set_animofs(this, anim_skullwiz_stand, 13, skullw_run12); ai_run(this, 0); }
void skullw_run10(entity this) { set_animofs(this, anim_skullwiz_stand, 11, skullw_run11); ai_face(this); ai_run(this, 0); }
void skullw_run9(entity this) { set_animofs(this, anim_skullwiz_stand, 9, skullw_run10); ai_face(this); ai_run(this, 0); }
void skullw_run8(entity this) { set_animofs(this, anim_skullwiz_stand, 7, skullw_run9); ai_run(this, 0); }
void skullw_run7(entity this) { set_animofs(this, anim_skullwiz_stand, 5, skullw_run8); ai_run(this, 0); }
void skullw_run6(entity this) { set_animofs(this, anim_skullwiz_stand, 3, skullw_run7); ai_face(this); ai_run(this, 0); }
void skullw_run5(entity this) { set_animofs(this, anim_skullwiz_stand, 12, skullw_run6); ai_face(this); ai_run(this, 0); }
void skullw_run4(entity this) { set_animofs(this, anim_skullwiz_stand, 14, skullw_run5); ai_run(this, 0); }
void skullw_run3(entity this) { set_animofs(this, anim_skullwiz_stand, 16, skullw_run4); ai_run(this, 0); }
void skullw_run2(entity this) { set_animofs(this, anim_skullwiz_stand, 18, skullw_run3); ai_face(this); ai_run(this, 0); }
void skullw_run1(entity this)
{
	set_animofs(this, anim_skullwiz_stand, 1, skullw_run2);
	ai_face(this);
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "skullwiz/idle1.wav" : "skullwiz/idle2.wav"), 1, ATTN_IDLE);
	ai_run(this, 0);
}

//============================================================================
// MELEE - Teleportation
//============================================================================
void skullw_tfin5(entity this)
{
	set_animofs(this, anim_skullwiz_tele, 1, skullw_run1); ai_face(this);
	this.bodyphased = MONAI_SKULLWSOLID;
	this.takedamage = DAMAGE_AIM;
}
void skullw_tfin4(entity this) { set_animofs(this, anim_skullwiz_tele, 3, skullw_tfin5); ai_face(this); }
void skullw_tfin3(entity this) { set_animofs(this, anim_skullwiz_tele, 5, skullw_tfin4); ai_face(this); }
void skullw_tfin2(entity this) { set_animofs(this, anim_skullwiz_tele, 7, skullw_tfin3); ai_face(this); }
void skullw_tfin1(entity this)
{
	set_animofs(this, anim_skullwiz_tele, 9, skullw_tfin2);
	this.velocity = '0 0 0';
	// Always phase in facing the enemy
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	this.angles_y = this.ideal_yaw;
	_sound(this, CH_TRIGGER_SINGLE, "skullwiz/blinkin.wav", 1, ATTN_NORM);
}

//----------------------------------------------------------------------
// Find new teleport location
//----------------------------------------------------------------------
void skullw_blink(entity this)
{
	float dist = 0;

	bool blinkfinished = true;
	int blinkcount = 0;
	vector angle_vec = '0 0 0', org = '0 0 0', org_ofs = '0 0 0';
	org_ofs.z = this.height;
	this.oldorigin = this.origin;
	
	// Trace upwards to find ceiling or maximum teleport height
	traceline(this.origin, this.origin+org_ofs, true, this);
	org_ofs = trace_endpos;
	
	// Loop around for possible locations
	while(blinkfinished)
	{
		blinkcount += 1;		// next loop
		angle_vec.y = random() * 360;		// Random direction
		makevectors(angle_vec);				// make vector
		
		// Generate random angle and trace teleport direction
		dist = 256 + (random() * 512);
		org = org_ofs + (v_forward * dist);
		traceline(org_ofs, org, true, this);
		
		// Check distance is far enough away from enemy
		// Move away from any walls (traceline is surface contact)
		dist = vlen(trace_endpos - org_ofs) - 32;
		org = org_ofs + (v_forward * dist);

		// Is the enemy far enough away?
		if(vdist(this.enemy.origin - org, >, 192))
		{
			// Trace down to floor below new point
			traceline(org, org - '0 0 512', true, this);
			org = trace_endpos + this.view_ofs;
			
			// The teleport fuction is working with a radius command
			// and this will ignore walls and just find any position
			// in all directions. This can lead to the skull wizard
			// teleporting behind walls or other parts of the map!
			// This can be prevent in two ways:
			// 1) linesight between skull wizard and player
			// - can leads to less interesting locations (always insight)
			// 2) linesight between new location and old
			// - This allows skull wizard to teleport around corner
			//   and still be within the same area!
			//
			// Trace through monsters and check trace fraction
			traceline(org, this.origin, true, this);
			if(trace_fraction == 1)
				blinkfinished = false;
		}

		// Been looping too long, back to original location
		if(blinkcount > 10)
		{
			blinkfinished = false;
			org = this.origin;
		}
	}
	
	// Move to new location
	this.solid = SOLID_SLIDEBOX;				// Standard monster movement
	setorigin(this, org);						// move to new location
	
	// Test if new location is solid?
	tracebox(this.origin, this.mins, this.maxs, this.origin, MOVE_NOMONSTERS, this);
	if(trace_startsolid)
	{
		this.solid = SOLID_NOT;					// No world interaction yet
		this.effects |= EF_NODRAW;
		setorigin(this, this.oldorigin);		// restore original location
		this.nextthink = time + 1;				// Keep checking
		setthink(this, skullw_blink);
	}
	else
	{
		this.effects &= ~EF_NODRAW;
		skullw_tfin1(this);
	}
}

//----------------------------------------------------------------------
// Cycle around teleport chain lists instead
//----------------------------------------------------------------------
void skullw_waitforlink(entity this)
{
	this.nextthink = time + 0.5 + random();
	setthink(this, skullw_waitforlink);
	setorigin(this, this.movelast.origin);	// move to new location

	// Is the enemy too close or dead?
	if(vdist(this.enemy.origin - this.origin, >, this.movelast.distance)
		|| this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET) || (this.charmed && (IS_PLAYER(this.enemy) || this.charmer == this.enemy)))
	{
		// Move to new location
		this.solid = SOLID_SLIDEBOX;				// Standard monster movement
	
		// Test if new location is solid?
		tracebox(this.origin, this.mins, this.maxs, this.origin, MOVE_NOMONSTERS, this);
		if(trace_startsolid)
		{
			this.solid = SOLID_NOT;					// No world interaction yet
			this.effects |= EF_NODRAW;
		}
		else
		{
			this.effects &= ~EF_NODRAW;
			skullw_tfin1(this);
		}
	}
}

//----------------------------------------------------------------------
void skullw_checkblinklist(entity this)
{
	// Does the blink list exist already?
	if(this.movelast.classname != "info_skullwiz_destination")
	{
		this.movelast = find(NULL, targetname, this.target2);
		// Does the entity chain exist?
		if(this.movelast.classname == "info_skullwiz_destination")
			skullw_waitforlink(this);
		else
		{
			// target2 is not valid, do regular teleport
			this.target2 = "";
			skullw_blink(this);
		}
	}
	else
	{
		// Move forward in chain and try next spawn location
		this.movelast = this.movelast.enemy;
		skullw_waitforlink(this);
	}
}

//----------------------------------------------------------------------
// touch book and phase out
//----------------------------------------------------------------------
void skullw_tele13(entity this)
{
	this.effects |= EF_NODRAW;
	// Check if a chain list has been defined
	if(this.target2 && this.target2 != "")
		skullw_checkblinklist(this);
	else
		skullw_blink(this);
}
void skullw_tele12(entity this) { set_animofs(this, anim_skullwiz_tele, 9, skullw_tele13); }
void skullw_tele11(entity this) { set_animofs(this, anim_skullwiz_tele, 7, skullw_tele12); }
void skullw_tele10(entity this) { set_animofs(this, anim_skullwiz_tele, 5, skullw_tele11); }
void skullw_tele9(entity this) { set_animofs(this, anim_skullwiz_tele, 3, skullw_tele10); }
void skullw_tele8(entity this)
{
	set_animofs(this, anim_skullwiz_tele, 1, skullw_tele9);
	this.takedamage = DAMAGE_NO;	// No damage or impact, phasing out
	this.solid = SOLID_NOT;
	this.bodyphased = MONAI_SKULLWINVIS;
	te_explosion2(this.origin, 100, 1);
	//particle_explode(this.origin, 100, 1, this.part_style, PARTICLE_BURST_SKULLUP);
	_sound(this, CH_VOICE, "skullwiz/blinkout.wav", 1, ATTN_NORM);
}
void skullw_tele6(entity this) { set_animofs(this, anim_skullwiz_spellb, 13, skullw_tele8); }
void skullw_tele4(entity this) { set_animofs(this, anim_skullwiz_spellb, 9, skullw_tele6); }
void skullw_tele3(entity this) { set_animofs(this, anim_skullwiz_spellb, 7, skullw_tele4); }
void skullw_tele2(entity this) { set_animofs(this, anim_skullwiz_spellb, 5, skullw_tele3); }
void skullw_tele1(entity this)
{
	set_animofs(this, anim_skullwiz_spellb, 3, skullw_tele2);
	this.pain_finished = time + 1;				// no pain during teleportation
	if(random() < 0.5)
		_sound(this, CH_VOICE, "skullwiz/blinkspk1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "skullwiz/blinkspk2.wav", 1, ATTN_NORM);
}

//============================================================================
// Rocket Skull Attack (Regular)
//============================================================================
void skullw_guardian(entity this, entity toucher);
void skullw_fire(entity this, vector orgofs)
{
	if(!this.enemy) return;
	if(this.health < 1) return;
	
	this.effects |= EF_MUZZLEFLASH;
	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "skullwiz/skull1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "skullwiz/skull2.wav", 1, ATTN_NORM);

	ai_face(this);
	makevectors (this.angles);
	vector org = this.origin + attack_vector(orgofs);
	vector dir = normalize(this.enemy.origin - org);

	entity newmis = launch_spike(this, org, dir);
	newmis.poisonous = this.poisonous;
	if(newmis.poisonous)
	{
		_setmodel(newmis, "progs/proj_skullwizp.mdl");
		settouch(newmis, skullw_guardian);
	}
	else
	{
		_setmodel(newmis, "progs/proj_skullwiz.mdl");
		settouch(newmis, T_MissileTouch); // rocket explosion
	}
	newmis.avelocity = '0 0 0';
	newmis.dmg = 20;
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = dir * (525 + (autocvar_skill * 75));
	newmis.effects = EF_DIMLIGHT;
	newmis.projectiledeathtype = DEATH_MONSTER_SKULLWIZARD.m_id;
}

void skullw_attack8(entity this) { set_animofs(this, anim_skullwiz_spella, 15, skullw_run1); }
void skullw_attack7(entity this) { set_animofs(this, anim_skullwiz_spella, 13, skullw_attack8); }
void skullw_attack6(entity this) { set_animofs(this, anim_skullwiz_spella, 12, skullw_attack7); skullw_fire(this, '30 0 16'); }
void skullw_attack5(entity this) { set_animofs(this, anim_skullwiz_spella, 11, skullw_attack6); ai_face(this); }
void skullw_attack4(entity this) { set_animofs(this, anim_skullwiz_spella, 10, skullw_attack5); ai_face(this); }
void skullw_attack3(entity this) { set_animofs(this, anim_skullwiz_spella, 7, skullw_attack4); ai_face(this); }
void skullw_attack2(entity this) { set_animofs(this, anim_skullwiz_spella, 5, skullw_attack3); ai_face(this); }
void skullw_attack1(entity this)
{
	set_animofs(this, anim_skullwiz_spella, 3, skullw_attack2);
	_sound(this, CH_VOICE, "skullwiz/attack.wav", 1, ATTN_NORM);
}

//============================================================================
// Poison Skull Attack (Guardians)
//============================================================================
void skullw_poison_touch(entity this, entity toucher)
{
	if(toucher.solid == SOLID_TRIGGER) return;
	if(toucher.classname == this.classname) return;
	if(toucher.health > 0) return;
	if(this.attack_finished > time) return;

	this.attack_finished = time + 1;
	this.modelindex = 0;			// Make sure no model
	this.model = "";
	setthink(this, SUB_Remove);
	this.nextthink = time;
}

//----------------------------------------------------------------------
void skullw_poison_think(entity this)
{
	// Randomly drift upwards and slow down forward movement
	this.velocity_z = this.velocity_z + 10 + (random() * 20);
	this.velocity = this.velocity - (this.velocity * 0.125);
	
	this.frame = this.frame + 1;
	if(this.frame > this.count)
		delete(this);
	else
		this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------
void skullw_guardian(entity this, entity toucher)
{
	// Double check the skull wizard has poisonous flag set
	if(!this.poisonous)
		return;

	// Play explosion sound
	_sound(this, CH_WEAPON_SINGLE, "skullwiz/poison_hit.wav", 1, ATTN_NORM);
	
	// Apply any direct damage and poison effect
	if(toucher.takedamage)
		T_Damage(toucher, this, this.owner, 30, DEATH_MONSTER_SKULLWIZARD.m_id);
	
	int poison_loop = 0;
	vector poison_angles = '0 0 0';
	
	while(poison_loop < 360)
	{
		entity newmis = spawn();
		newmis.classname = "skullwiz_poison";
		set_movetype(newmis, MOVETYPE_FLY);		// Fly, no gravity
		newmis.solid = SOLID_TRIGGER;
		_setmodel(newmis, "progs/s_burst_poison.spr");

		vector org = this.origin;
		org.z += (crandom() * 24);
		setorigin(newmis, org);
		setsize(newmis, '0 0 0', '0 0 0');

		poison_angles_y = poison_loop;
		makevectors(poison_angles);
		vector dir = randomvec() * 50;
		dir += (v_forward * (400 + random() * 50));
		newmis.velocity = dir;
		newmis.count = 6;
		newmis.frame = rint(random()*2);

		// If DP engine active remove particle shadow
		newmis.effects |= EF_NOSHADOW;

		setthink(newmis, skullw_poison_think);
		settouch(newmis, skullw_poison_touch);
		newmis.nextthink = time + 0.1;
		
		poison_loop += rint(random()*15);
	}

	delete(this);
}

//============================================================================
// SUMMON MINION - Purple magic ball
//============================================================================
void skullw_create_attachment(entity this)
{
	// Are the attachments setup yet?
	if(!this.attachment)
	{
		this.attachment = spawn();
		this.attachment.owner = this;
		this.attachment.classname = "attachment";
		this.attachment.mdl = "progs/proj_skullball.mdl";
	}
}

//----------------------------------------------------------------------
void skullw_finish_attachment(entity this)
{
	if(this.attachment)
		_setmodel(this.attachment, "");
}

//----------------------------------------------------------------------
void skullw_remove_attachment(entity this)
{
	if(this.attachment)
	{
		setthink(this.attachment, SUB_Remove);
		this.attachment.nextthink = time + 0.1;
	}
	this.attachment = NULL;
}

//----------------------------------------------------------------------
// Display a purple ball in the hand of the skull wizard
//----------------------------------------------------------------------
void skullw_sumball(entity this, vector orgofs, float dbframe)
{
	// Frame 0 is start of the sequence (move everything into place)
	if(dbframe == 0)
	{
		setorigin(this.attachment, this.pos2);
		_setmodel(this.attachment, this.attachment.mdl);
		setsize(this.attachment, '0 0 0', '0 0 0');
		set_movetype(this.attachment, MOVETYPE_NONE);
		this.attachment.solid = SOLID_NOT;
		this.attachment.skin = 0;
		this.attachment.alpha = 0.85;
	}

	// Generate attachment in hand (left)
	makevectors(this.angles);
	vector org = this.origin + attack_vector(orgofs);
	setorigin(this.attachment, org);
	this.attachment.angles_y = rint(random()*359);
	this.attachment.frame = dbframe;

	// Create particles inside of skull wizard robes floating up
	// once lost soul is spawning, then switch particle location
	if(this.skullwizard_summonflag)
		te_explosion2(this.pos2, 3, 1);
		//particle_explode(this.pos2, 3, 1, this.part_style, PARTICLE_BURST_MINOTAUR);
	// Need to cut down on particles, too much visual noise
	//	else particle_debuff(this.origin, 16, rint(4+random()*4), this.part_style);
}

//----------------------------------------------------------------------
// Raise hand up to the sky and spawn purple particles from body
// Always check if there is space to spawn a lost soul first
// Block monster pain function so that the summons is completed
//----------------------------------------------------------------------
void skullw_summon15(entity this)
{
	set_animofs(this, anim_skullwiz_summon, 29, skullw_run1);
	ai_face(this);
	this.attack_finished = time + (1 + 2*random());
}
void skullw_summon14(entity this) { set_animofs(this, anim_skullwiz_summon, 27, skullw_summon15); ai_face(this); }
void skullw_summon13(entity this)
{
	set_animofs(this, anim_skullwiz_summon, 25, skullw_summon14);
	skullw_finish_attachment(this);
	if(this.skullwizard_summonflag)
		te_explosion2(this.pos1, 15, 2);
		//particle_explode(this.pos1, 15, 2, this.part_style, PARTICLE_BURST_MINOTAUR);
}
void skullw_summon12(entity this) { set_animofs(this, anim_skullwiz_summon, 23, skullw_summon13); skullw_sumball(this, '19 -7 32', 1); }
void skullw_summon11(entity this) { set_animofs(this, anim_skullwiz_summon, 21, skullw_summon12); skullw_sumball(this, '26 -6 30', 3); }
void skullw_summon10(entity this) { set_animofs(this, anim_skullwiz_summon, 19, skullw_summon11); skullw_sumball(this, '26 -5 23', 4); }
void skullw_summon9(entity this) { set_animofs(this, anim_skullwiz_summon, 17, skullw_summon10); skullw_sumball(this, '26 -4 19', 4); }
void skullw_summon8(entity this) { set_animofs(this, anim_skullwiz_summon, 15, skullw_summon9); skullw_sumball(this, '26 -4 16', 4); }
void skullw_summon7(entity this)
{
	set_animofs(this, anim_skullwiz_summon, 13, skullw_summon8);
	// Find out if there is enough space to spawn a lost soul
	// This is really a tricky thing to test for ...
	// * pointcontents only checks against world space
	// * walkmove does not work properly on the lower plane face
	// * touch triggers only work when something touches not inside
	// * findradius will find a lot of entities depending on radius
	
	// Touch trigger version
	//this.aflag = test_minionspace();

	// Findradius version
	makevectors(this.angles);
	this.pos1 = this.origin + this.view_ofs + v_forward*64 + v_up*16;
	this.skullwizard_summonflag = find_minionspace(this.pos1);
	
	// If the spawn locaiton all clear, spawn something!
	if(this.skullwizard_summonflag)
	{
		minion_spawn(this, this.pos1, MON_LOSTSOUL);
		this.pos2 = this.pos1 - '0 0 16';	// Where to spawn particles
		skullw_sumball(this, '26 -4 14', 4);
	}
}
void skullw_summon6(entity this) { set_animofs(this, anim_skullwiz_summon, 11, skullw_summon7); skullw_sumball(this, '26 -4 12', 3); }
void skullw_summon5(entity this) { set_animofs(this, anim_skullwiz_summon, 9, skullw_summon6); skullw_sumball(this, '26 -4 10', 3); }
void skullw_summon4(entity this) { set_animofs(this, anim_skullwiz_summon, 7, skullw_summon5); skullw_sumball(this, '24 -4 9', 2); }
void skullw_summon3(entity this)
{
	set_animofs(this, anim_skullwiz_summon, 5, skullw_summon4);
	ai_face(this);
	skullw_sumball(this, '23 -3 7', 1);
	_sound(this, CHAN_BODY, "skullwiz/summon.wav", 1, ATTN_NORM);
	/* The touch trigger is created early (4 frames) so its gets
	// a chance for a client to touch its bounding box
	// This is a giant trigger area to catch speedy players
	makevectors(this.angles);
	this.pos1 = this.origin + this.view_ofs + v_forward*64 + v_up*16;
	setup_minionspace(this.pos1, '-32 -32 -32', '32 32 32'); */
}
void skullw_summon2(entity this) { set_animofs(this, anim_skullwiz_summon, 3, skullw_summon3); ai_face(this); skullw_sumball(this, '22 -2 6',0); }
void skullw_summon1(entity this) { set_animofs(this, anim_skullwiz_summon, 1, skullw_summon2); ai_face(this); this.pain_finished = time + 2; }

//----------------------------------------------------------------------
// Both type of skull wizards go through the same magic function
//----------------------------------------------------------------------
void skullw_magic(entity this)
{
	// Make sure the attachments are setup ready
	skullw_create_attachment(this);
	
	// Is the target the player or monster?
	if(IS_PLAYER(this.enemy))
	{
		if(this.spawnflags & MON_SKULLWIZ_MINIONS)
		{
			// has the lost soul limit been reached?
			if(query_minionactive(this) > 0)
				skullw_summon1(this);
			else
				skullw_attack1(this);
		}
		// Red Skull wizards attacks with skull rockets
		else
			skullw_attack1(this);
	}
	// Always attack monsters with skull rockets
	else
		skullw_attack1(this);
}
	
//============================================================================
void skullw_phased(entity this)
{ 
	this.nextthink = time + 0.1;	// Keep looking for player
	setthink(this, skullw_phased);		// Keep looping
	if(random() < 0.02) 
		te_explosion2(this.origin, rint(10 + random() * 10), 1);
		//particle_explode(this.origin, rint(10+random()*10), 1, this.part_style, PARTICLE_BURST_SKULLUP);
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "skullwiz/idle1.wav" : "skullwiz/idle2.wav"), 1, ATTN_IDLE);
	ai_stand(this); 					// Keep looking
}

//----------------------------------------------------------------------
void skullw_wakeup(entity this)
{
	// Reset all monster state functions back to default
	this.th_stand = skullw_stand;
	this.th_walk = skullw_walk;
	this.th_run = skullw_run1;
	this.th_missile = skullw_magic;
	this.th_melee = skullw_tele1;

	skullw_tfin1(this);
}

//============================================================================
// Short body recoil (6 frames)
void skullw_painA6(entity this) { set_animofs(this, anim_skullwiz_paina, 12, skullw_run1); }
void skullw_painA5(entity this) { set_animofs(this, anim_skullwiz_paina, 10, skullw_painA6); }
void skullw_painA4(entity this) { set_animofs(this, anim_skullwiz_paina, 8, skullw_painA5); }
void skullw_painA3(entity this) { set_animofs(this, anim_skullwiz_paina, 6, skullw_painA4); }
void skullw_painA2(entity this) { set_animofs(this, anim_skullwiz_paina, 4, skullw_painA3); }
void skullw_painA1(entity this) { set_animofs(this, anim_skullwiz_paina, 2, skullw_painA2); }

// Long expanded out version (10 frames)
void skullw_painB11(entity this) { set_animofs(this, anim_skullwiz_paina, 11, skullw_run1); }
void skullw_painB10(entity this) { set_animofs(this, anim_skullwiz_paina, 10, skullw_painB11); }
void skullw_painB9(entity this) { set_animofs(this, anim_skullwiz_paina, 9, skullw_painB10); }
void skullw_painB8(entity this) { set_animofs(this, anim_skullwiz_paina, 8, skullw_painB9); }
void skullw_painB7(entity this) { set_animofs(this, anim_skullwiz_paina, 7, skullw_painB8); }
void skullw_painB6(entity this) { set_animofs(this, anim_skullwiz_paina, 6, skullw_painB7); }
void skullw_painB5(entity this) { set_animofs(this, anim_skullwiz_paina, 5, skullw_painB6); }
void skullw_painB4(entity this) { set_animofs(this, anim_skullwiz_paina, 4, skullw_painB5); }
void skullw_painB3(entity this) { set_animofs(this, anim_skullwiz_paina, 3, skullw_painB4); }
void skullw_painB1(entity this) { set_animofs(this, anim_skullwiz_paina, 2, skullw_painB3); }

//----------------------------------------------------------------------
void skullw_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health <= 0)
		return;

	// Cannot feel pain when phased out
	if(this.bodyphased == MONAI_SKULLWINVIS)
		return;

	if(random() * 100 > damage)
		return;

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 2;
	skullw_finish_attachment(this);

	float r = random();
	if(r < 0.5)
		_sound(this, CH_VOICE, "skullwiz/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "skullwiz/pain2.wav", 1, ATTN_NORM);

	if(random() < 0.85)
		skullw_painA1(this);
	else
		skullw_painB1(this);
}

void skullw_fadeaway(entity this)
{
	//	sound (this, CHAN_BODY, "skullwiz/fadeaway.wav", 1, ATTN_NORM);
	// Particle burst upwards as robes fade away
	//particle_explode(this.origin, 100, 3, this.part_style, PARTICLE_BURST_SKULLUP);
	te_explosion2(this.origin, 100, 3);
	if(!this.alpha)
		this.alpha = 1;
	setthink(this, MonsterFade2);
	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------
void skullw_explode(entity this)
{
	//particle_explode(this.origin, 100, 3, PARTICLE_BURST_WHITE, PARTICLE_BURST_SKULLUP);
	te_explosion2(this.origin, 100, 3);
	ThrowGib(this, "progs/h_skullwiz.mdl", -1);
	entity gib = ThrowGib(this, "progs/w_skullbook.mdl", -1);
	gib.skin = this.skin;
}

void skullw_death14(entity this)
{
	set_animofs(this, anim_skullwiz_death, 15, skullw_death14);
	// Random timer for robes to fade away
	setthink(this, skullw_fadeaway);
	this.nextthink = time + 8 + random() * 8;
}
void skullw_death13(entity this) { set_animofs(this, anim_skullwiz_death, 14, skullw_death14); }
void skullw_death12(entity this) { set_animofs(this, anim_skullwiz_death, 13, skullw_death13); }
void skullw_death11(entity this) { set_animofs(this, anim_skullwiz_death, 12, skullw_death12); }
void skullw_death10(entity this) { set_animofs(this, anim_skullwiz_death, 11, skullw_death11); }
void skullw_death9(entity this) { set_animofs(this, anim_skullwiz_death, 10, skullw_death10); }
void skullw_death8(entity this) { set_animofs(this, anim_skullwiz_death, 9, skullw_death9); }
void skullw_death7(entity this) { set_animofs(this, anim_skullwiz_death, 8, skullw_death8); }
void skullw_death6(entity this) { set_animofs(this, anim_skullwiz_death, 7, skullw_death7); }
void skullw_death5(entity this) { set_animofs(this, anim_skullwiz_death, 6, skullw_death6); skullw_explode(this); }
void skullw_death4(entity this) { set_animofs(this, anim_skullwiz_death, 5, skullw_death5); ai_face(this); }
void skullw_death3(entity this) { set_animofs(this, anim_skullwiz_death, 4, skullw_death4); ai_face(this); }
void skullw_death2(entity this) { set_animofs(this, anim_skullwiz_death, 3, skullw_death3); ai_face(this); }
void skullw_death1(entity this) { set_animofs(this, anim_skullwiz_death, 2, skullw_death2); ai_face(this); this.solid = SOLID_NOT; }

void skullw_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	// Play fade away/death sound
	_sound(this, CH_VOICE, "skullwiz/death.wav", 1, ATTN_NORM);

	// Pre-check routine to tidy up extra entities
	skullw_remove_attachment(this);

	this.effects &= ~EF_NODRAW;

	// Special death, Instantly vaporize cloak
	// This is really a gib death without the gibs!
	if(this.health < -40)
	{
		// Typical Grenade explosion
		te_explosion(this.origin);
		SpawnExplosion(EXPLODE_MED, this.origin, "weapons/r_exp3b.wav");

		ThrowHead(this, "progs/h_skullwiz.mdl", -1);
		entity gib = ThrowGib(this, "progs/w_skullbook.mdl", -1);
		gib.skin = this.skin;
		return;
	}
	// Regular death, collapse and fade away
	// Large particle explosion upwards
	//particle_explode(this.origin, 100, 3, this.part_style, PARTICLE_BURST_SKULLUP);
	te_explosion2(this.origin, 100, 3);
	skullw_death1(this);
}

/*======================================================================
 SkullWizardCheckAttack (No melee attack)
======================================================================*/
bool SkullWizCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;

	//----------------------------------------------------------------------
	// Teleport away if player too close
	//----------------------------------------------------------------------
	if(this.enemy_range <= RANGE_NEAR && !this.bodystatic)
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	// make sure enemy is stationary (turret)
	//else
		//this.attack_state = AS_MISSILE;

	// see if any entities are in the way of the shot
	entity targ = this.enemy;
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
		
	//----------------------------------------------------------------------
	// Range / missile attack (skull attack)
	//----------------------------------------------------------------------
	// Does the monster have a clear shot to the player?
	// sightline can be blocked by other monsters
	if(!this.enemy_visible) return false;

	this.attack_state = AS_MISSILE;
	this.th_missile(this);
	this.attack_finished = time + 1 + (2 * random());

	return true;
}

//======================================================================
/*QUAKED monster_skullwiz (0.5 0 1) (-16 -16 -24) (16 16 40)
======================================================================*/
spawnfunc(monster_skullwiz) { monster_start(this, true, MON_SKULLWIZARD); }
#endif // SVQC

#ifdef SVQC
METHOD(SkullWizard, mr_setup, bool(SkullWizard this, entity actor))
{
    TC(SkullWizard, this);

    precache_model("progs/w_skullbook.mdl");		// Unique book item
    precache_model("progs/proj_skullwiz.mdl");
    precache_model("progs/proj_skullwizp.mdl");
    precache_model("progs/proj_skullball.mdl");
    precache_model("progs/s_burst_poison.spr");

    precache_sound("skullwiz/idle1.wav");
    precache_sound("skullwiz/idle2.wav");
    precache_sound("skullwiz/pain2.wav");
    precache_sound("skullwiz/pain2.wav");
    precache_sound("skullwiz/death.wav");

	precache_sound("skullwiz/attack.wav");		// fire spell
	precache_sound("skullwiz/skull1.wav");		// Screaming skull attack
	precache_sound("skullwiz/skull2.wav");
	precache_sound("skullwiz/summon.wav");
	precache_sound("skullwiz/poison_hit.wav");	// Guardian Explosion
	precache_sound("weapons/r_exp3b.wav");

	precache_sound("skullwiz/blinkspk1.wav");	// Talk casting blink spell
	precache_sound("skullwiz/blinkspk2.wav");
	precache_sound("skullwiz/blinkout.wav");	// Sound of blink animation
	precache_sound("skullwiz/blinkin.wav");

	if(!actor.bodyphased)
		actor.bodyphased = MONAI_SKULLWSOLID;
	else
		actor.bodyphased = MONAI_SKULLWINVIS;

    actor.health = 120;
	actor.th_pain = skullw_pain;
	actor.th_die = skullw_die;

	if(actor.bodyphased == MONAI_SKULLWINVIS)
	{
		actor.th_stand = skullw_phased;
		actor.th_walk = skullw_phased;
		actor.th_run = skullw_wakeup;
		actor.th_missile = skullw_wakeup;
		actor.th_melee = skullw_wakeup;
	}
	else
	{
		actor.th_stand = skullw_stand;
		actor.th_walk = skullw_walk;
		actor.th_run = skullw_run1;
		actor.th_missile = skullw_magic;
		actor.th_melee = skullw_tele1;
	}

	if(actor.spawnflags & MON_SKULLWIZ_MINIONS)
	{
		actor.health *= 1.5;
		actor.skin = 2;
		if(!actor.minion_maxcount)
			actor.minion_maxcount = 3;
	}
	else if(actor.spawnflags & MON_SKULLWIZ_GUARDIAN)
	{
		actor.health *= 2;
		actor.skin = 3;
		actor.poisonous = true;
	}

	actor.checkattack = SkullWizCheckAttack;

    return true;
}
#endif

#ifdef SVQC
//======================================================================
/*QUAKED info_skullwiz_destination (0.6 0 0.8) (-16 -16 -24) (16 16 40) x
Teleport destination for skull wizard ONLY
-------- KEYS --------
targetname : part of a chain group (required)
target   : next destination in the chain
distance : Minimum distance enemy needs to be before spawning
-------- SPAWNFLAGS --------
-------- NOTES --------
Teleport destination for skull wizard ONLY

======================================================================*/
void info_skullwiz_link(entity this)
{
	// Teleport destination already been linked
	if(this.enemy) return;
	
	// The master entity is the start of the chain
	// the currlink is a link in the chain
	entity master = this;
	bool loopcondition = true;
	entity ent = this;

	while(loopcondition) 
	{
		// Setup next link to master and find next link
		ent.enemy = master;
		entity currlink = find(NULL, targetname, ent.target);
		// reached end of list?
		if(!currlink || currlink == master) 
			loopcondition = false;
		else
		{
			// Move forward in the chain
			ent.enemy = currlink;
			ent = currlink;
		}
	}
}

//----------------------------------------------------------------------
spawnfunc(info_skullwiz_destination)
{
	// All teleportation points need to be part of a chain
	// Otherwise the skull Wizard would have to use findradius
	// which is expensive if lots of entities are around
	if(!this.targetname || this.targetname == "" || !this.target || this.target == "")
	{
		delete(this);
		return;
	}

	this.mangle = this.angles;
	// Setup minimum player spawn distance
	if(this.distance <=0)
		this.distance = 192;
	// Setup if the destination is active or not
	this.state = 0;

	// Check for targetname->target loops
	if(this.targetname == this.target)
	{
		this.enemy = this;
		this.owner = this;
	}
	else
	{
		// Wait for all targets to spawn
		setthink(this, info_skullwiz_link);
		this.nextthink = time + 0.2 + random();
	}
}
#endif
