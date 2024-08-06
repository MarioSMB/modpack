#include "dragon.qh"

#ifdef SVQC
const int anim_dragon_drgfly01 = 1;
const int anim_dragon_drgslh01 = 20;

const int anim_dragon_drgfix1a = 43;
const int anim_dragon_drgfix1b = 44;
const int anim_dragon_drgfix1c = 45;
const int anim_dragon_drgfix2a = 46;
const int anim_dragon_drgfix2b = 47;
const int anim_dragon_drgfix2c = 48;
const int anim_dragon_drgfix3a = 49;
const int anim_dragon_drgfix3b = 50;
const int anim_dragon_drgfix3c = 51;
const int anim_dragon_drgfix4a = 52;
const int anim_dragon_drgfix4b = 53;
const int anim_dragon_drgfix4c = 54;
const int anim_dragon_drgfix5a = 55;
const int anim_dragon_drgfix5b = 56;
const int anim_dragon_drgfix5c = 57;
const int anim_dragon_drgfix6a = 58;
const int anim_dragon_drgfix6b = 59;
const int anim_dragon_drgfix6c = 60;
const int anim_dragon_drgfix6d = 61;

const int anim_dragon_drgpan1a = 62;
const int anim_dragon_drgpan1b = 63;
const int anim_dragon_drgpan1c = 64;
const int anim_dragon_drgpan2a = 65;
const int anim_dragon_drgpan2b = 66;
const int anim_dragon_drgpan2c = 67;
const int anim_dragon_drgpan3a = 68;
const int anim_dragon_drgpan3b = 69;
const int anim_dragon_drgpan3c = 70;
const int anim_dragon_drgpan4a = 71;
const int anim_dragon_drgpan4b = 72;
const int anim_dragon_drgpan4c = 73;
const int anim_dragon_drgpan5a = 74;
const int anim_dragon_drgpan5b = 75;
const int anim_dragon_drgpan5c = 76;
const int anim_dragon_drgpan6a = 77;
const int anim_dragon_drgpan6b = 78;
const int anim_dragon_drgpan6c = 79;

const int anim_dragon_drgdth01 = 80;

const int DDIE_FALLING = 1;
const int DDIE_STOPPED = 2;
const int DDIE_EXPLODED = 3;

const int DT_ROOM_A = 1;
const int DT_ROOM_B = 2;
const int DT_ROOM_C = 4;

const int FIRE_PLASMA = 1;
const int FIRE_FIREBALL = 2;

// ===================================
// entity fields
// ===================================
.float playerInRoom;
.float playerInTransit;
.float dragonInRoom;
.float dragonInTransit;
.float dragonAttacking;
.float dragonPainSequence;
.vector dragonLastVelocity;

.float dragonDeathState;

// ===================================
// dragon_stop_attack 
// ===================================
void dragon_stop_attack(entity this)
{
	if(this.dragonAttacking == false)
		return;

//	skill ramp?
	this.attack_finished = time + (random() * 2) + 4;
	this.attack_finished = this.attack_finished - autocvar_skill;
	
	this.dragonAttacking = false;
	traceline(this.origin, this.movetarget.origin, true, NULL);

	if(trace_fraction == 1)
		return;
	else
		bprint("Error: Dragon cannot get to next target!\n");
}

// ===================================
// dragon_check_attack 
// ===================================
void dragon_check_attack(entity this)
{
	if(this.dragonAttacking == true)
		return;
	if(!this.th_missile)
		return;
	if(this.attack_finished > time)
		return;
	if(this.enemy.health < 0)
		this.enemy = NULL;
	if(this.enemy.flags & FL_NOTARGET)
		return;
	
	if(this.enemy == NULL)
		FindTarget(this);
	else
	{
		makevectors(this.angles);
		vector vec = normalize(this.enemy.origin - this.origin);
		float dot = vec * v_forward;
//        if(dot > 0.55)
		if(dot > 0.3)
		{
			traceline(this.origin, this.enemy.origin, true, NULL);
			if(trace_fraction == 1)
			{
				if(vdist(this.enemy.origin - this.origin, <, 350))
				{
					this.dragonAttacking = true;
					setthink(this, dragon_melee1);
					return;
				}
				else
				{	
					this.dragonAttacking = true;
					setthink(this, this.th_missile);
				}
			}
//			else
//				bprint ("can't see player!\n");
		}
	}
}

// ===================================
// dragon_move 
// ===================================
void dragon_move(entity this, float dist)
{
	if(this.health < 1)
	{
		delete(this);
		return;
	}
	
	if(this.dragonAttacking == false) // && this.dragonInTransit == false)
		dragon_check_attack(this);

	entity oldEnemy = this.enemy;
	vector moveDir, moveAngles;
	if(this.dragonAttacking == false)
	{
		moveDir = this.movetarget.origin - this.origin;
		moveAngles = vectoangles ( moveDir);
		this.enemy = this.movetarget;
	}
	else
	{
		moveDir = this.enemy.origin - this.origin;
		moveAngles = vectoangles ( moveDir);
	}
	
	float turnOffset = this.angles_y - moveAngles.y;
	if(turnOffset != 0)
	{
		float turnOffset = 180 - this.angles_y;
		float leftTurn = anglemods( moveAngles.y + turnOffset) - 180;
		float rightTurn = 180 - anglemods( moveAngles.y + turnOffset);
		
		if(leftTurn < 0)
			leftTurn = 360;
		else if(rightTurn < 0)
			rightTurn = 360;
	
		this.yaw_speed = 10;
		if(rightTurn < 180)
		{
			if(this.yaw_speed < rightTurn)
				this.angles_y = this.angles_y - this.yaw_speed;
			else
				this.angles_y = moveAngles.y;
	
			if(rightTurn > 5)
			{
				this.angles_z = this.angles_z + 5;
				if(this.angles_z > 30)
					this.angles_z = 30;
			}
			turnOffset = rightTurn;
		}
		else 
		{
			if(this.yaw_speed < rightTurn)
				this.angles_y = this.angles_y + this.yaw_speed;
			else
				this.angles_y = moveAngles.y;
	
			if(leftTurn > 5)
			{
				this.angles_z = this.angles_z - 5;
				if(this.angles_z < -30)
					this.angles_z = -30;
			}
			turnOffset = leftTurn;
		}
	}
	else if(this.angles_z != 0)
	{
		if(this.angles_z < -5)
			this.angles_z = this.angles_z + 5;
		else if(this.angles_z < 5)
			this.angles_z = 0;
		else if(this.angles_z > 5)
			this.angles_z = this.angles_z - 5;
	}

	if(moveDir_z > 5)
		setorigin(this, this.origin + '0 0 5');
	else if(moveDir_z < -5) 
		setorigin(this, this.origin - '0 0 5');


	moveAngles = this.origin;
	t_walkmove(this, this.angles_y, dist);

	if(moveAngles == this.origin)
	{
//        bprint ( "Cannot move smoothly. movetogoal..\n");
		t_movetogoal(this, dist);
	}
	this.enemy = oldEnemy;
}

// ===================================
// movement
// ===================================
void dragon_walk1(entity this);
void dragon_stand1(entity this) { set_anim(this, anim_dragon_drgfly01, dragon_walk1); }

// attack A: start - walk1  stop - walk 5
// ================
void dragon_walk5(entity this);
void dragon_atk_a3(entity this) { set_anim(this, anim_dragon_drgfix1c, dragon_walk5); dragon_move(this, 17); dragon_stop_attack(this); }
void dragon_atk_a2(entity this) { set_anim(this, anim_dragon_drgfix1b, dragon_atk_a3); dragon_move(this, 17); dragon_fireball(this); }
void dragon_atk_a1(entity this) { set_anim(this, anim_dragon_drgfix1a, dragon_atk_a2); dragon_move(this, 17); }

// attack B: start - walk3  stop - walk7
// ================
void dragon_walk7(entity this);
void dragon_atk_b3(entity this) { set_anim(this, anim_dragon_drgfix2c, dragon_walk7); dragon_move(this, 17); dragon_stop_attack(this); }
void dragon_atk_b2(entity this) { set_anim(this, anim_dragon_drgfix2b, dragon_atk_b3); dragon_move(this, 17); dragon_fireball(this); }
void dragon_atk_b1(entity this) { set_anim(this, anim_dragon_drgfix2a, dragon_atk_b2); dragon_move(this, 17); }

// attack C: start - walk5  stop - walk9
// ================
void dragon_walk9(entity this);
void dragon_atk_c3(entity this) { set_anim(this, anim_dragon_drgfix3c, dragon_walk9); dragon_move(this, 17); dragon_stop_attack(this); }
void dragon_atk_c2(entity this) { set_anim(this, anim_dragon_drgfix3b, dragon_atk_c3); dragon_move(this, 17); dragon_fireball(this); }
void dragon_atk_c1(entity this) { set_anim(this, anim_dragon_drgfix3a, dragon_atk_c2); dragon_move(this, 17); }

// attack d: start - walk7  stop - walk11
// ================
void dragon_walk11(entity this);
void dragon_atk_d3(entity this) { set_anim(this, anim_dragon_drgfix4c, dragon_walk11); dragon_move(this, 17); dragon_stop_attack(this); }
void dragon_atk_d2(entity this) { set_anim(this, anim_dragon_drgfix4b, dragon_atk_d3); dragon_move(this, 17); dragon_fireball(this); }
void dragon_atk_d1(entity this) { set_anim(this, anim_dragon_drgfix4a, dragon_atk_d2); dragon_move(this, 17); }

// attack E: start - walk9  stop - walk13
// ================
void dragon_walk13(entity this);
void dragon_atk_e3(entity this) { set_anim(this, anim_dragon_drgfix5c, dragon_walk13); dragon_move(this, 17); dragon_stop_attack(this); }
void dragon_atk_e2(entity this) { set_anim(this, anim_dragon_drgfix5b, dragon_atk_e3); dragon_move(this, 17); dragon_fireball(this); }
void dragon_atk_e1(entity this) { set_anim(this, anim_dragon_drgfix5a, dragon_atk_e2); dragon_move(this, 17); }

// attack F: start - walk11  stop - walk3
// ================
void dragon_walk3(entity this);
void dragon_atk_f4(entity this) { set_anim(this, anim_dragon_drgfix6c, dragon_walk3); dragon_move(this, 17); dragon_stop_attack(this); }
void dragon_atk_f3(entity this) { set_anim(this, anim_dragon_drgfix6c, dragon_atk_f4); dragon_move(this, 17); }
void dragon_atk_f2(entity this) { set_anim(this, anim_dragon_drgfix6b, dragon_atk_f3); dragon_move(this, 17); dragon_fireball(this); }
void dragon_atk_f1(entity this) { set_anim(this, anim_dragon_drgfix6a, dragon_atk_f2); dragon_move(this, 17); }

// ===================================
// dragon walk frames
// ===================================

void dragon_walk13(entity this) { set_animofs(this, anim_dragon_drgfly01, 13, dragon_walk1); 	this.th_missile = func_null; 		dragon_move(this, 17); this.dragonPainSequence = 1; }
void dragon_walk12(entity this) { set_animofs(this, anim_dragon_drgfly01, 12, dragon_walk13); 	this.th_missile = func_null; 		dragon_move(this, 17); }
void dragon_walk11(entity this) { set_animofs(this, anim_dragon_drgfly01, 11, dragon_walk12); 	this.th_missile = dragon_atk_f1; 	dragon_move(this, 17); this.dragonPainSequence = 6; }
void dragon_walk10(entity this) { set_animofs(this, anim_dragon_drgfly01, 10, dragon_walk11); 	this.th_missile = func_null; 		dragon_move(this, 17); }
void dragon_walk9(entity this) { set_animofs(this, anim_dragon_drgfly01, 9, dragon_walk10); 	this.th_missile = dragon_atk_e1; 	dragon_move(this, 17); this.dragonPainSequence = 5; }
void dragon_walk8(entity this) { set_animofs(this, anim_dragon_drgfly01, 8, dragon_walk9); 		this.th_missile = func_null; 		dragon_move(this, 17); }
void dragon_walk7(entity this) { set_animofs(this, anim_dragon_drgfly01, 7, dragon_walk8); 		this.th_missile = dragon_atk_d1; 	dragon_move(this, 17); this.dragonPainSequence = 4; }
void dragon_walk6(entity this) { set_animofs(this, anim_dragon_drgfly01, 6, dragon_walk7); 		this.th_missile = func_null; 		dragon_move(this, 17); }
void dragon_walk5(entity this) { set_animofs(this, anim_dragon_drgfly01, 5, dragon_walk6); 		this.th_missile = dragon_atk_c1; 	dragon_move(this, 17); this.dragonPainSequence = 3; }
void dragon_walk4(entity this) { set_animofs(this, anim_dragon_drgfly01, 4, dragon_walk5); 		this.th_missile = func_null; 		dragon_move(this, 17); }
void dragon_walk3(entity this) { set_animofs(this, anim_dragon_drgfly01, 3, dragon_walk4); 		this.th_missile = dragon_atk_b1; 	dragon_move(this, 17); this.dragonPainSequence = 2; }
void dragon_walk2(entity this) { set_animofs(this, anim_dragon_drgfly01, 2, dragon_walk3); 		this.th_missile = func_null; 		dragon_move(this, 17); }
void dragon_walk1(entity this)
{
	set_anim(this, anim_dragon_drgfly01, dragon_walk2);

	if(this.dragonAttacking)
		dragon_stop_attack(this);
			
	this.th_missile = dragon_atk_a1;
	this.dragonPainSequence = 1;
	dragon_move(this, 17);
	if(random() < 0.2)
		_sound(this, CH_TRIGGER_SINGLE, "dragon/active.wav", 0.6, ATTN_IDLE);
}

// ===================================
// attack
// ===================================

void FireballTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(this.owner.monsterdef == MON_DRAGON)
		T_RadiusDamage(this, this.owner, 90, this.projectiledeathtype, this.owner);
	else
		T_RadiusDamage(this, this.owner, 30, this.projectiledeathtype, NULL);
	
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	te_explosion2(this.origin, 228, 5); // 247

	delete(this);
//	BecomeExplosion();
}

entity launch_fireball(entity this, vector org, vector dir)
{
	this.effects = this.effects | EF_MUZZLEFLASH;
	entity fireball = new(fireball);
	fireball.owner = this;
	set_movetype(fireball, MOVETYPE_FLYMISSILE);
	fireball.solid = SOLID_BBOX;
	fireball.projectiledeathtype = DEATH_MONSTER_DRAGON.m_id;
	fireball.classname = "fireball";
	_setmodel(fireball, "progs/fireball.mdl");
	setorigin(fireball, org);
	setsize(fireball, '0 0 0', '0 0 0');		

	float fireSpeed = random() * 300 + 900;
	fireball.velocity = dir * fireSpeed;
	fireball.avelocity = '0 0 300';
	fireball.angles = vectoangles(fireball.velocity);
	fireball.enemy = this.enemy;
	
	settouch(fireball, FireballTouch);
	fireball.nextthink = time + 6;
	setthink(fireball, SUB_Remove);

	return fireball;
}

// ===========================================
// dragon_fireball
// ===========================================
void dragon_fireball(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, "dragon/attack.wav", 1, ATTN_NORM);

	makevectors(this.angles);
	vector org = this.origin + v_forward*112 + v_up*32;

	int fireCount, fireType;
	if(random() > 0.66)
	{
		fireCount = 1;
		if(autocvar_skill > 1)
			fireCount = 2;
		fireType = FIRE_PLASMA;
	}
	else
	{
		fireType = FIRE_FIREBALL;
		fireCount = random() * autocvar_skill;			// easy 0, med 0-1, hard 0-2	
		fireCount = rint(fireCount) + 1;
	// easy 1, med 1-2, hard 1-3
	}
		
	while (fireCount > 0)
	{
		float distortion = (random() - 0.5) * 0.25;
		vector dir = normalize(this.enemy.origin - org);
		makevectors (dir);
		dir = dir + v_right * distortion;

		if(fireType == FIRE_FIREBALL)
			launch_fireball(this, org, dir);
		else
			launch_plasma(this, org, dir);

		fireCount = fireCount - 1;
	}

}

// ===================================
// melee attacks
// ===================================
void dragon_tail_touch(entity this, entity toucher)
{
	if(!this.enemy)
		return;
	if(!CanDamage(this.enemy, this))
		return;

	ai_charge(this, 10);

	vector delta = this.enemy.origin - this.origin;
	float tailDamage = vlen(delta);
	if(vdist(delta, >, 150))
	{
		return;
	}

	tailDamage = ( random() * 30) + 30;
	T_Damage(this.enemy, this, this, tailDamage, DEATH_MONSTER_DRAGON.m_id);
}

void dragon_tail(entity this)
{
	if(!this.enemy)
		return;
	if(!CanDamage (this.enemy, this))
		return;

	dragon_move(this, 10);
	
	vector dir = this.enemy.origin - this.origin;
	if(vdist(dir, <, 250))
	{
		T_Damage(this.enemy, this, this, 30, DEATH_MONSTER_DRAGON.m_id);
		dir = normalize(dir);
		this.enemy.velocity = dir * 500;
		this.enemy.velocity_z = 350;
	}
	
	dragon_stop_attack(this);
}

void dragon_melee13(entity this) { set_animofs(this, anim_dragon_drgslh01, 13, dragon_walk1); dragon_move(this, 10); }
void dragon_melee12(entity this) { set_animofs(this, anim_dragon_drgslh01, 12, dragon_melee13); dragon_move(this, 10); }
void dragon_melee11(entity this) { set_animofs(this, anim_dragon_drgslh01, 11, dragon_melee12); dragon_move(this, 10); }
void dragon_melee10(entity this) { set_animofs(this, anim_dragon_drgslh01, 10, dragon_melee11); dragon_tail(this); }
void dragon_melee9(entity this) { set_animofs(this, anim_dragon_drgslh01, 9, dragon_melee10); dragon_move(this, 12); }
void dragon_melee8(entity this) { set_animofs(this, anim_dragon_drgslh01, 8, dragon_melee9); dragon_move(this, 12); }
void dragon_melee7(entity this) { set_animofs(this, anim_dragon_drgslh01, 7, dragon_melee8); dragon_move(this, 12); }
void dragon_melee6(entity this) { set_animofs(this, anim_dragon_drgslh01, 6, dragon_melee7); dragon_move(this, 12); }
void dragon_melee5(entity this) { set_animofs(this, anim_dragon_drgslh01, 5, dragon_melee6); dragon_move(this, 12); }
void dragon_melee4(entity this) { set_animofs(this, anim_dragon_drgslh01, 4, dragon_melee5); dragon_move(this, 12); }
void dragon_melee3(entity this) { set_animofs(this, anim_dragon_drgslh01, 3, dragon_melee4); dragon_move(this, 12); }
void dragon_melee2(entity this) { set_animofs(this, anim_dragon_drgslh01, 2, dragon_melee3); dragon_move(this, 12); }
void dragon_melee1(entity this) { set_animofs(this, anim_dragon_drgslh01, 1, dragon_melee2); dragon_move(this, 12); }

// ===================================
// pain
// ===================================
void dragon_painA3(entity this) { set_anim(this, anim_dragon_drgpan1c, dragon_walk5); dragon_move(this, 12); }
void dragon_painA2(entity this) { set_anim(this, anim_dragon_drgpan1b, dragon_painA3); dragon_move(this, 12); }
void dragon_painA1(entity this) { set_anim(this, anim_dragon_drgpan1a, dragon_painA2); dragon_move(this, 12); }

void dragon_painB3(entity this) { set_anim(this, anim_dragon_drgpan2c, dragon_walk7); dragon_move(this, 12); }
void dragon_painB2(entity this) { set_anim(this, anim_dragon_drgpan2b, dragon_painB3); dragon_move(this, 12); }
void dragon_painB1(entity this) { set_anim(this, anim_dragon_drgpan2a, dragon_painB2); dragon_move(this, 12); }

void dragon_painC3(entity this) { set_anim(this, anim_dragon_drgpan3c, dragon_walk9); dragon_move(this, 12); }
void dragon_painC2(entity this) { set_anim(this, anim_dragon_drgpan3b, dragon_painC3); dragon_move(this, 12); }
void dragon_painC1(entity this) { set_anim(this, anim_dragon_drgpan3a, dragon_painC2); dragon_move(this, 12); }

void dragon_painD3(entity this) { set_anim(this, anim_dragon_drgpan4c, dragon_walk11); dragon_move(this, 12); }
void dragon_painD2(entity this) { set_anim(this, anim_dragon_drgpan4b, dragon_painD3); dragon_move(this, 12); }
void dragon_painD1(entity this) { set_anim(this, anim_dragon_drgpan4a, dragon_painD2); dragon_move(this, 12); }

void dragon_painE3(entity this) { set_anim(this, anim_dragon_drgpan5c, dragon_walk13); dragon_move(this, 12); }
void dragon_painE2(entity this) { set_anim(this, anim_dragon_drgpan5b, dragon_painE3); dragon_move(this, 12); }
void dragon_painE1(entity this) { set_anim(this, anim_dragon_drgpan5a, dragon_painE2); dragon_move(this, 12); }

void dragon_painF3(entity this) { set_anim(this, anim_dragon_drgpan6c, dragon_walk2); dragon_move(this, 12); }
void dragon_painF2(entity this) { set_anim(this, anim_dragon_drgpan6b, dragon_painF3); dragon_move(this, 12); }
void dragon_painF1(entity this) { set_anim(this, anim_dragon_drgpan6a, dragon_painF2); dragon_move(this, 12); }

void dragon_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();

	if(r < 0.25)
	{
		dragon_stop_attack(this);

		_sound(this, CH_TRIGGER_SINGLE, "dragon/pain.wav", 1, ATTN_NORM);
		this.pain_finished = time + 2;
		
		if(this.dragonPainSequence == 1)
			setthink(this, dragon_painA1);
		else if(this.dragonPainSequence == 2)
			setthink(this, dragon_painF1);
		else if(this.dragonPainSequence == 3)
			setthink(this, dragon_painE1);
		else if(this.dragonPainSequence == 4)
			setthink(this, dragon_painD1);
		else if(this.dragonPainSequence == 5)
			setthink(this, dragon_painC1);
		else if(this.dragonPainSequence == 6)
			setthink(this, dragon_painB1);
	}
}

// ===================================
// death
// ===================================
void dragon_boom2(entity this)
{
	this.velocity = this.dragonLastVelocity;
	ViolentDeath(this, 15);
	this.target = "dragondoor";
	SUB_UseTargets(this, NULL, NULL);			
	delete(this);
}	

void dragon_boom1(entity this)
{
	if(this.dragonDeathState > DDIE_STOPPED)
//		objerror ( "dragon_boom1");
		return;
		
	this.dragonDeathState = DDIE_EXPLODED;
	ThrowGib(this, this, "progs/drggib01.mdl", -100);
	ThrowGib(this, this, "progs/drggib02.mdl", -100);
	ThrowGib(this, this, "progs/drggib03.mdl", -100);
	_sound(this, CH_PLAYER, "player/tornoff2.wav", 1, ATTN_NONE);
	setthink(this, dragon_boom2);
	this.nextthink = time + 0.1;
}

void dragon_explode(entity this)
{
	if(this.dragonDeathState > DDIE_FALLING)
//		objerror ( "dragon_explode");
		return;

	if(vdist(this.velocity, <, 100) || (this.flags & FL_INWATER))
	{	
		this.dragonDeathState = DDIE_STOPPED;
		dragon_boom1(this);
	}
	else
	{
		makevectors(this.angles);
		this.velocity = this.velocity - 40 * v_up;
		this.dragonLastVelocity = this.velocity;
	}
}

void dragon_squish(entity this, entity toucher)
{
	if(IS_PLAYER(toucher))
	{
		this.classname = "monster_dragon_dead"; // TODO: deathtype support would give us a unique death message here!
		T_Damage(toucher, this, this, 200, DEATH_MONSTER_DRAGON_CRUSH.m_id);
	}
	if(!toucher)
	{
		this.velocity = '0 0 0';
		dragon_explode(this);
	}
}

void dragon_death21(entity this)
{
	set_animofs(this, anim_dragon_drgdth01, 21, dragon_death21);

	ViolentDeath(this, 39);
	this.target = "dragondoor";
	SUB_UseTargets(this, NULL, NULL);			
	delete(this);
}
void dragon_death20(entity this) { set_animofs(this, anim_dragon_drgdth01, 20, dragon_death21); dragon_explode(this); }
void dragon_death19(entity this) { set_animofs(this, anim_dragon_drgdth01, 19, dragon_death20); dragon_explode(this); }
void dragon_death18(entity this) { set_animofs(this, anim_dragon_drgdth01, 18, dragon_death19); dragon_explode(this); }
void dragon_death17(entity this) { set_animofs(this, anim_dragon_drgdth01, 17, dragon_death18); dragon_explode(this); }
void dragon_death16(entity this) { set_animofs(this, anim_dragon_drgdth01, 16, dragon_death17); dragon_explode(this); }
void dragon_death15(entity this) { set_animofs(this, anim_dragon_drgdth01, 15, dragon_death16); dragon_explode(this); }
void dragon_death14(entity this) { set_animofs(this, anim_dragon_drgdth01, 14, dragon_death15); dragon_explode(this); }
void dragon_death13(entity this) { set_animofs(this, anim_dragon_drgdth01, 13, dragon_death14); dragon_explode(this); }
void dragon_death12(entity this) { set_animofs(this, anim_dragon_drgdth01, 12, dragon_death13); dragon_explode(this); }
void dragon_death11(entity this) { set_animofs(this, anim_dragon_drgdth01, 11, dragon_death12); dragon_explode(this); }
void dragon_death10(entity this) { set_animofs(this, anim_dragon_drgdth01, 10, dragon_death11); dragon_explode(this); }
void dragon_death9(entity this) { set_animofs(this, anim_dragon_drgdth01, 9, dragon_death10); dragon_explode(this); }
void dragon_death8(entity this) { set_animofs(this, anim_dragon_drgdth01, 8, dragon_death9); dragon_explode(this); }
void dragon_death7(entity this) { set_animofs(this, anim_dragon_drgdth01, 7, dragon_death8); dragon_explode(this); }
void dragon_death6(entity this) { set_animofs(this, anim_dragon_drgdth01, 6, dragon_death7); dragon_explode(this); }
void dragon_death5(entity this) { set_animofs(this, anim_dragon_drgdth01, 5, dragon_death6); dragon_explode(this); }
void dragon_death4(entity this) { set_animofs(this, anim_dragon_drgdth01, 4, dragon_death5); dragon_explode(this); }
void dragon_death3(entity this) { set_animofs(this, anim_dragon_drgdth01, 3, dragon_death4); dragon_explode(this); }
void dragon_death2(entity this) { set_animofs(this, anim_dragon_drgdth01, 2, dragon_death3); dragon_explode(this); }
void dragon_death1(entity this, entity inflictor, entity attacker, int deathtype)
{
	set_anim(this, anim_dragon_drgdth01, dragon_death2);

	if(this.dragonDeathState > 0)
//		objerror ( "dragon_death1");
		return;
	
	this.dragonDeathState = DDIE_FALLING;	
	this.use = func_null;
	this.gravity = 0.25; // slow fall
	set_movetype(this, MOVETYPE_TOSS);
	makevectors(this.angles);
	this.velocity = 300 * v_forward - 40 * v_up;
	UNSET_ONGROUND(this);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	settouch(this, dragon_squish);

	_sound(this, CH_TRIGGER_SINGLE, "dragon/death.wav", 1, ATTN_NONE);
	this.dragonAttacking = false;
}

// ===================================
// Delayed Activation
// ===================================
void dragon_use(entity this, entity actor, entity trigger)
{
	if(this.health < 1)
	{
		this.use = func_null;
		return;
	}
	
	this.th_stand = dragon_walk1;
	this.th_walk = dragon_walk1;
	setthink(this, dragon_walk1);
	this.nextthink = time + 0.1;
}

// ===================================
// dragon activation code
// ===================================
void dragon_activate(entity this)
{
	if(this.target && this.target != "")
	{
		this.movetarget = find(NULL, targetname, this.target);
		this.goalentity = this.movetarget;
		if(!this.movetarget)
			LOG_DEBUGF("Monster %s can't find target at %v\n", this.classname, this.origin);
	}

	if(this.targetname && this.targetname != "")
		this.use = dragon_use;
	else
		dragon_use(this, NULL, NULL);	
}

/*QUAKED monster_dragon (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
spawnfunc(monster_dragon)
{
	if(deathmatch) { delete(this); return; }
	monster_start(this, true, MON_DRAGON);
}
#endif // SVQC

#ifdef SVQC
METHOD(Dragon, mr_setup, bool(Dragon this, entity actor))
{
	TC(Dragon, this);

	precache_model("progs/fireball.mdl");
	precache_model("progs/drggib01.mdl");
	precache_model("progs/drggib02.mdl");
	precache_model("progs/drggib03.mdl");
	
	precache_sound("dragon/active.wav");
	precache_sound("dragon/attack.wav");
	precache_sound("dragon/pain.wav");
	precache_sound("dragon/death.wav");

	actor.classname = "monster_dragon"; // needed for dying state
	actor.dragonInRoom = DT_ROOM_A;
	actor.dragonInTransit = 0;
	actor.dragonAttacking = false;
	actor.playerInRoom = DT_ROOM_A;
	actor.playerInTransit = 0;

	actor.th_stand = dragon_activate;
	actor.th_walk = dragon_activate;
	actor.th_run = dragon_walk1;
	actor.th_pain = dragon_pain;
	actor.th_die = dragon_death1;
	actor.dragonPainSequence = 1;

	actor.health = 2000 + (500 * autocvar_skill);

	return true;
}
#endif

#ifdef SVQC
// =================================================
// dragon trigger
//-- OBSOLETE!!
// =================================================

/*QUAKED trigger_dragon (.5 .5 .5) ? A B C
Trigger to let dragon know what room you're in.

Set the A,B,C to which room this trigger is at.

Point the trigger towards the room. If the player is going
the direction the trigger points, he is entering the room.
If not, he is leaving.
*/
spawnfunc(trigger_dragon)
{
	delete(this);
}


// =================================================
// dragon corners
// =================================================
void dragon_corner_touch(entity this, entity toucher)
{
	if(toucher.movetarget != this)
		return;
	
	if(toucher.monsterdef != MON_DRAGON)
		return;
	if(toucher.dragonDeathState > 0)
		return;

	toucher.movetarget = find(NULL, targetname, this.target);
	toucher.goalentity = toucher.movetarget;
	toucher.target = this.target;
	
	if(!toucher.movetarget)
		objerror(this, "dragon_corner: no target found");
}

/*QUAKED dragon_corner (0.5 0.3 0) (-16 -16 -16) (16 16 16)
Only for use with monster_dragon. Use only as transitions 
between rooms.
*/
spawnfunc(dragon_corner)
{
	if(!this.targetname || this.targetname == "")
		objerror(this, "dragon_corner: no targetname");

	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_NONE);
	settouch(this, dragon_corner_touch);
	this.modelindex = 0;
	this.model = "";
	setsize(this, '-16 -16 -16', '16 16 16');
}
#endif
