#include "swarmer.qh"

#ifdef SVQC
.float idle_finished;

void swarmer_transparency(entity this)
{
	if(autocvar_skill < 2)
		return;
	if(!this.enemy)
		return;

	float dist = vlen(this.origin - this.enemy.origin) - 100;
	if(dist == 0)
		dist = 1; // div0 prevention
	this.alpha = 1.0 - (0.8 * sqrt(dist / 300.0));
	if(this.alpha == 0)
		this.alpha = -1; // because engine
}

void swarmer_stand1(entity this);
void swarmer_stand15(entity this) { set_anim(this, 14, swarmer_stand1); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand14(entity this) { set_anim(this, 13, swarmer_stand15); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand13(entity this) { set_anim(this, 12, swarmer_stand14); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand12(entity this) { set_anim(this, 11, swarmer_stand13); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand11(entity this) { set_anim(this, 10, swarmer_stand12); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand10(entity this) { set_anim(this, 9, swarmer_stand11); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand9(entity this) { set_anim(this, 8, swarmer_stand10); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand8(entity this) { set_anim(this, 7, swarmer_stand9); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand7(entity this) { set_anim(this, 6, swarmer_stand8); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand6(entity this) { set_anim(this, 5, swarmer_stand7); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand5(entity this) { set_anim(this, 4, swarmer_stand6); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand4(entity this) { set_anim(this, 3, swarmer_stand5); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand3(entity this) { set_anim(this, 2, swarmer_stand4); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand2(entity this) { set_anim(this, 1, swarmer_stand3); swarmer_transparency(this); ai_stand(this); }
void swarmer_stand1(entity this) { set_anim(this, 0, swarmer_stand2); swarmer_transparency(this); ai_stand(this); }

void swarmer_footStep(entity this)
{
	float rSnd = random() * 5;
	if(rSnd < 1)
		_sound(this, CH_VOICE, "swarmer/footstep1.wav", 1, ATTN_NORM);
	else if(rSnd < 2)
		_sound(this, CH_VOICE, "swarmer/footstep2.wav", 1, ATTN_NORM);
	else if(rSnd < 3)
		_sound(this, CH_VOICE, "swarmer/footstep3.wav", 1, ATTN_NORM);
	else if((rSnd < 4))
		_sound(this, CH_VOICE, "swarmer/footstep4.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "swarmer/footstep5.wav", 1, ATTN_NORM);
}

void swarmer_walk1(entity this);
void swarmer_walk18(entity this)
{
	set_anim(this, 32, swarmer_walk1);

	ai_walk(this, 8);

	float rSnd = random() * 4;
	if(rSnd < 1) 
		_sound(this, CH_VOICE, "swarmer/idle1.wav", 0.4, 3.5);
	else if(rSnd < 2)
		_sound(this, CH_VOICE, "swarmer/idle2.wav", 0.4, 3.5);
	else if(rSnd < 3)
		_sound(this, CH_VOICE, "swarmer/idle3.wav", 0.4, 3.5);
	else
		_sound(this, CH_VOICE, "swarmer/idle4.wav", 0.4, 3.5);
}
void swarmer_walk17(entity this) { set_anim(this, 31, swarmer_walk18); swarmer_transparency(this); ai_walk(this, 3); }
void swarmer_walk16(entity this) { set_anim(this, 30, swarmer_walk17); swarmer_transparency(this); ai_walk(this, 7); }
void swarmer_walk15(entity this) { set_anim(this, 29, swarmer_walk16); swarmer_transparency(this); ai_walk(this, 6); }
void swarmer_walk14(entity this) { set_anim(this, 28, swarmer_walk15); swarmer_transparency(this); ai_walk(this, 4); }
void swarmer_walk13(entity this) { set_anim(this, 27, swarmer_walk14); swarmer_transparency(this); ai_walk(this, 2); }
void swarmer_walk12(entity this) { set_anim(this, 26, swarmer_walk13); swarmer_transparency(this); ai_walk(this, 0); }
void swarmer_walk11(entity this) { set_anim(this, 25, swarmer_walk12); swarmer_transparency(this); ai_walk(this, 0); }
void swarmer_walk10(entity this) { set_anim(this, 24, swarmer_walk11); swarmer_transparency(this); ai_walk(this, 0); }
void swarmer_walk9(entity this) { set_anim(this, 23, swarmer_walk10); swarmer_transparency(this); ai_walk(this, 2); }
void swarmer_walk8(entity this) { set_anim(this, 22, swarmer_walk9); swarmer_transparency(this); ai_walk(this, 4); }
void swarmer_walk7(entity this) { set_anim(this, 21, swarmer_walk8); swarmer_transparency(this); ai_walk(this, 4); }
void swarmer_walk6(entity this) { set_anim(this, 20, swarmer_walk7); swarmer_transparency(this); ai_walk(this, 3); }
void swarmer_walk5(entity this) { set_anim(this, 19, swarmer_walk6); swarmer_transparency(this); ai_walk(this, 2); }
void swarmer_walk4(entity this) { set_anim(this, 18, swarmer_walk5); swarmer_transparency(this); ai_walk(this, 1); }
void swarmer_walk3(entity this) { set_anim(this, 17, swarmer_walk4); swarmer_transparency(this); ai_walk(this, 0); }
void swarmer_walk2(entity this) { set_anim(this, 16, swarmer_walk3); swarmer_transparency(this); ai_walk(this, 1); }
void swarmer_walk1(entity this) { set_anim(this, 15, swarmer_walk2); swarmer_transparency(this); ai_walk(this, 1); }

void ai_swarmer_run(entity this, float step)
{
	if(!this.enemy)
		return;

	vector prev_org = this.origin;
	ai_run(this, step);
	if(this.origin == prev_org)
		return;

	vector _origin = this.origin;
	float eYaw = vectoyaw(this.enemy.origin - this.origin);

	if(this.enemy_visible)
	{
		vector enemy_range2D = vec2(this.origin) - vec2(this.enemy.origin);
		if(vdist(enemy_range2D, <, 512))
		{
			if(vdist(enemy_range2D, <, 192))
				this.frame += 8;
			
			int loopStep = 12;
			int _count = floor(128 / loopStep);

			while(_count > 0)
			{
				_count -= 1;

				if(!t_walkmove(this, eYaw, loopStep))
					_count = -666;
				
			}

			setorigin(this, _origin);
			if(_count != -666)
			{
				this.ideal_yaw = eYaw + crandom();
				changeyaw(this);
				t_walkmove(this, eYaw, step);
				return;
			}
		}
	}

	t_movetogoal(this, 1);
	t_walkmove(this, this.angles_y, step - 1); // walkmove2
	vector vec = '0 0 0';
	vec.y = this.ideal_yaw;
	makevectors(vec);
	vec = (this.origin + (v_forward * 32));
	this.ideal_yaw = this.ideal_yaw + crandom();

	if(this.origin == _origin)
	{
		if(this.enemy_range <= RANGE_MELEE)
		{
			this.ideal_yaw = eYaw;
			changeyaw(this);
		}
		else
		{
			this.ideal_yaw = (random() * 360);
			changeyaw(this);
		}
	}
	
}

void swarmer_run1(entity this);
void swarmer_run8(entity this)
{
	set_anim(this, 40, swarmer_run1);
	swarmer_transparency(this);
	ai_swarmer_run(this, 24);
	if(time > this.idle_finished)
	{
		float rSnd = random() * 4;
		if(rSnd < 1)
			_sound(this, CH_VOICE, "swarmer/idle5.wav", 0.4, 3.5);
		else if(rSnd < 2)
			_sound(this, CH_VOICE, "swarmer/idle6.wav", 0.4, 3.5);
		else if(rSnd < 3)
			_sound(this, CH_VOICE, "swarmer/idle7.wav", 0.4, 3.5);
		else
			_sound(this, CH_VOICE, "swarmer/idle8.wav", 0.4, 3.5);

		this.idle_finished = (time + 6) + (random() * 2);
	}
}
void swarmer_run7(entity this) { set_anim(this, 39, swarmer_run8); swarmer_transparency(this); ai_swarmer_run(this, 24); }
void swarmer_run6(entity this) { set_anim(this, 38, swarmer_run7); swarmer_transparency(this); ai_swarmer_run(this, 24); swarmer_footStep(this); }
void swarmer_run5(entity this) { set_anim(this, 37, swarmer_run6); swarmer_transparency(this); ai_swarmer_run(this, 24); }
void swarmer_run4(entity this) { set_anim(this, 36, swarmer_run5); swarmer_transparency(this); ai_swarmer_run(this, 24); }
void swarmer_run3(entity this) { set_anim(this, 35, swarmer_run4); swarmer_transparency(this); ai_swarmer_run(this, 24); }
void swarmer_run2(entity this) { set_anim(this, 34, swarmer_run3); swarmer_transparency(this); ai_swarmer_run(this, 24); swarmer_footStep(this); }
void swarmer_run1(entity this) { set_anim(this, 33, swarmer_run2); swarmer_transparency(this); ai_swarmer_run(this, 24);/*genHeal(this, 1, 0);*/}

void swarmer_meleeAttack(entity this)
{
	if(!this.enemy) 
		return;
	
	vector delta = this.enemy.origin - this.origin;
	float dist = vlen(delta);
	dist = (dist - this.enemy.maxs_x) - this.maxs_x;
	if(dist > 24)
		return;
	
	float rSnd = random() * 4;

	if(rSnd < 1)
		_sound(this, CH_WEAPON_SINGLE, "swarmer/punch1.wav", 1, ATTN_NORM);
	else if(rSnd < 2)
		_sound(this, CH_WEAPON_SINGLE, "swarmer/punch2.wav", 1, ATTN_NORM);
	else if(rSnd < 3)
		_sound(this, CH_WEAPON_SINGLE, "swarmer/punch3.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "swarmer/punch4.wav", 1, ATTN_NORM);

	T_Damage(this.enemy, this, this, 4, DEATH_MONSTER_SWARMER.m_id);
}

void ai_swarmer_charge(entity this, float step)
{
	ai_face(this);
	//walkmove_robust(this.angles_y, step, 10);
	t_walkmove(this, this.angles_y, step); // walkmove2
}

void swarmer_atkl8(entity this) { set_anim(this, 56, swarmer_run1); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkl7(entity this) { set_anim(this, 55, swarmer_atkl8); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkl6(entity this) { set_anim(this, 54, swarmer_atkl7); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkl5(entity this) { set_anim(this, 53, swarmer_atkl6); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkl4(entity this) { set_anim(this, 52, swarmer_atkl5); swarmer_transparency(this); ai_swarmer_charge(this, 24); swarmer_meleeAttack(this); }
void swarmer_atkl3(entity this) { set_anim(this, 51, swarmer_atkl4); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkl2(entity this) { set_anim(this, 50, swarmer_atkl3); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkl1(entity this) { set_anim(this, 49, swarmer_atkl2); swarmer_transparency(this); ai_swarmer_charge(this, 24); }

void swarmer_atkr8(entity this) { set_anim(this, 64, swarmer_run1); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkr7(entity this) { set_anim(this, 63, swarmer_atkr8); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkr6(entity this) { set_anim(this, 62, swarmer_atkr7); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkr5(entity this) { set_anim(this, 61, swarmer_atkr6); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkr4(entity this) { set_anim(this, 60, swarmer_atkr5); swarmer_transparency(this); ai_swarmer_charge(this, 24); swarmer_meleeAttack(this); }
void swarmer_atkr3(entity this) { set_anim(this, 59, swarmer_atkr4); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkr2(entity this) { set_anim(this, 58, swarmer_atkr3); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkr1(entity this) { set_anim(this, 57, swarmer_atkr2); swarmer_transparency(this); ai_swarmer_charge(this, 24); }

void swarmer_atkm8(entity this) { set_anim(this, 72, swarmer_run1); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkm7(entity this) { set_anim(this, 71, swarmer_atkm8); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkm6(entity this) { set_anim(this, 70, swarmer_atkm7); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkm5(entity this) { set_anim(this, 69, swarmer_atkm6); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkm4(entity this) { set_anim(this, 68, swarmer_atkm5); swarmer_transparency(this); ai_swarmer_charge(this, 24); swarmer_meleeAttack(this); }
void swarmer_atkm3(entity this) { set_anim(this, 67, swarmer_atkm4); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkm2(entity this) { set_anim(this, 66, swarmer_atkm3); swarmer_transparency(this); ai_swarmer_charge(this, 24); }
void swarmer_atkm1(entity this) { set_anim(this, 65, swarmer_atkm2); swarmer_transparency(this); ai_swarmer_charge(this, 24); }

void swarmer_melee(entity this)
{
	float r = random() * 7;

	if(r < 1) 
		_sound(this, CH_VOICE, "swarmer/attack1.wav", 1, ATTN_NORM);
	else if(r < 2)
		_sound(this, CH_VOICE, "swarmer/attack2.wav", 1, ATTN_NORM);
	else if(r < 3)
		_sound(this, CH_VOICE, "swarmer/attack3.wav", 1, ATTN_NORM);
	else if(r < 4)
		_sound(this, CH_VOICE, "swarmer/attack4.wav", 1, ATTN_NORM);
	else if(r < 5)
		_sound(this, CH_VOICE, "swarmer/attack5.wav", 1, ATTN_NORM);
	else if(r < 6)
		_sound(this, CH_VOICE, "swarmer/attack6.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "swarmer/attack7.wav", 1, ATTN_NORM);
		
	if(random() < 0.75)
	{
		if(this.state)
			swarmer_atkl1(this);
		else
			swarmer_atkr1(this);

		this.state = (this.state) ? 0 : 1;
	}
	else
		swarmer_atkm1(this);
} 

//===========================================================================

void swarmer_pain(entity this, entity attacker, float damage, int deathtype)
{
	// no effect on the little guy
}

//===========================================================================

void swarmer_deathA11(entity this) { set_anim(this, 83, swarmer_deathA11); CorpseThink(this); }
void swarmer_deathA10(entity this) { set_anim(this, 82, swarmer_deathA11); }
void swarmer_deathA9(entity this) { set_anim(this, 81, swarmer_deathA10); ai_pain(this, 2); }
void swarmer_deathA8(entity this) { set_anim(this, 80, swarmer_deathA9); ai_pain(this, 1); }
void swarmer_deathA7(entity this) { set_anim(this, 79, swarmer_deathA8); ai_pain(this, 1); }
void swarmer_deathA6(entity this) { set_anim(this, 78, swarmer_deathA7); ai_pain(this, 2); }
void swarmer_deathA5(entity this) { set_anim(this, 77, swarmer_deathA6); ai_pain(this, 1); }
void swarmer_deathA4(entity this) { set_anim(this, 76, swarmer_deathA5); ai_pain(this, 3); }
void swarmer_deathA3(entity this) { set_anim(this, 75, swarmer_deathA4); ai_pain(this, 5); }
void swarmer_deathA2(entity this) { set_anim(this, 74, swarmer_deathA3); ai_pain(this, 8); }
void swarmer_deathA1(entity this) { set_anim(this, 73, swarmer_deathA2); }

void swarmer_deathB9(entity this) { set_anim(this, 92, swarmer_deathB9); CorpseThink(this); }
void swarmer_deathB8(entity this) { set_anim(this, 91, swarmer_deathB9); }
void swarmer_deathB7(entity this) { set_anim(this, 90, swarmer_deathB8); }
void swarmer_deathB6(entity this) { set_anim(this, 89, swarmer_deathB7); }
void swarmer_deathB5(entity this) { set_anim(this, 88, swarmer_deathB6); ai_pain(this, 4); }
void swarmer_deathB4(entity this) { set_anim(this, 87, swarmer_deathB5); ai_pain(this, 8); }
void swarmer_deathB3(entity this) { set_anim(this, 86, swarmer_deathB4); ai_pain(this, 16 + random() * 8); }
void swarmer_deathB2(entity this) { set_anim(this, 85, swarmer_deathB3); ai_pain(this, 16 + random() * 8); }
void swarmer_deathB1(entity this) { set_anim(this, 84, swarmer_deathB2); ai_pain(this, 16 + random() * 8); }

void swarmer_deathC11(entity this) { set_anim(this, 103, swarmer_deathC11); CorpseThink(this); }
void swarmer_deathC10(entity this) { set_anim(this, 102, swarmer_deathC11); t_walkmove(this, this.angles_y + 90, 6); }
void swarmer_deathC9(entity this) { set_anim(this, 101, swarmer_deathC10); t_walkmove(this, this.angles_y + 90, 2); }
void swarmer_deathC8(entity this) { set_anim(this, 100, swarmer_deathC9); }
void swarmer_deathC7(entity this) { set_anim(this, 99, swarmer_deathC8); }
void swarmer_deathC6(entity this) { set_anim(this, 98, swarmer_deathC7); }
void swarmer_deathC5(entity this) { set_anim(this, 97, swarmer_deathC6); }
void swarmer_deathC4(entity this) { set_anim(this, 96, swarmer_deathC5); }
void swarmer_deathC3(entity this) { set_anim(this, 95, swarmer_deathC4); this.takedamage = DAMAGE_NO; }
void swarmer_deathC2(entity this) { set_anim(this, 94, swarmer_deathC3); }
void swarmer_deathC1(entity this) { set_anim(this, 93, swarmer_deathC2); }

void swarmer_deathD10(entity this) { set_anim(this, 113, swarmer_deathD10); CorpseThink(this); }
void swarmer_deathD9(entity this) { set_anim(this, 112, swarmer_deathD10); }
void swarmer_deathD8(entity this) { set_anim(this, 111, swarmer_deathD9); }
void swarmer_deathD7(entity this) { set_anim(this, 110, swarmer_deathD8); }
void swarmer_deathD6(entity this) { set_anim(this, 109, swarmer_deathD7); ai_forward(this, 4); }
void swarmer_deathD5(entity this) { set_anim(this, 108, swarmer_deathD6); ai_forward(this, 8); }
void swarmer_deathD4(entity this) { set_anim(this, 107, swarmer_deathD5); ai_forward(this, 14); }
void swarmer_deathD3(entity this) { set_anim(this, 106, swarmer_deathD4); ai_swarmer_charge(this, 16); }
void swarmer_deathD2(entity this) { set_anim(this, 105, swarmer_deathD3); ai_swarmer_charge(this, 20); }
void swarmer_deathD1(entity this) { set_anim(this, 104, swarmer_deathD2); ai_swarmer_charge(this, 24); }

void GibBloodBath(entity this, float bloodsize);
void swarmer_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			ThrowGib(this, inflictor, "progs/gibs/gibhead_swarmer.mdl", this.health);
			GibBloodBath(this, 1);
			ThrowGib(this, inflictor, "progs/gibs/gib_gen_1.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gibs/gib_gen_2.mdl", this.health);
			if(random() > 0.5)
				ThrowGib(this, inflictor, "progs/gibs/gib_gen_3.mdl", this.health);
			else
				ThrowGib(this, inflictor, "progs/gibs/gib_gen_4.mdl", this.health);

			if(random() > 0.5)
				ThrowGib(this, inflictor, "progs/gibs/gib_gen_5.mdl", this.health);
			else
				ThrowGib(this, inflictor, "progs/gibs/gib_gen_6.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	if(autocvar_skill >= 2)
		this.alpha = 1.0;

	this.solid = SOLID_TRIGGER;
	setorigin(this, this.origin); // relink

// regular death
	float r = random();
	if(r < 0.33)
		_sound(this, CH_VOICE, "swarmer/death1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_VOICE, "swarmer/death2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "swarmer/death3.wav", 1, ATTN_NORM);

	r = random();
	if(r <= 0.25)
		setthink(this, swarmer_deathA1);
	else if(r <= 0.5)
		setthink(this, swarmer_deathB1);
	else if(r <= 0.75)
		setthink(this, swarmer_deathC1);
	else
		setthink(this, swarmer_deathD1);
	this.nextthink = time;
}

/*QUAKED monster_swarmer (1 0 0) (-16 -16 -24) (16 16 32) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Swarmer, 10 health points.

Flags:
"ambush" only wake up on seeing the player, not another monster getting angry

"Triggered"	will not spawn until triggered - triggering again will wake him up. Set 'count' to make this a multi-use spawner.
"NoTfog" 	supress teleport glitter when spawned with 'triggered'
"NoTelefrag" will silently fail to spawn if doing so would telefrag an existing monster. will try again automatically 2x/second until it succeeds.
"Instawake" spawn angry at activator

Keys:
"target" entity to trigger when killed
"targetname" entity name
"movedir" set to a velocity to make the monster jump on awakening
*/
/*FGD
@PointClass base(Monster) size(-16 -16 -24, 16 16 32) model({ "path": ":progs/swarmer_qbj.mdl", "skin": skin }) = monster_swarmer : "Swarmer" []
*/
spawnfunc(monster_swarmer) { monster_start(this, true, MON_SWARMER); }
#endif // SVQC

#ifdef SVQC
METHOD(Swarmer, mr_setup, bool(Swarmer this, entity actor))
{
	TC(Swarmer, this);

	precache_model("progs/zom_gib.mdl");
	precache_model("progs/gibs/gibhead_swarmer.mdl");
	precache_model("progs/gibs/gib_gen_1.mdl");
	precache_model("progs/gibs/gib_gen_2.mdl");
	precache_model("progs/gibs/gib_gen_3.mdl");
	precache_model("progs/gibs/gib_gen_4.mdl");
	precache_model("progs/gibs/gib_gen_5.mdl");
	precache_model("progs/gibs/gib_gen_6.mdl");

	precache_sound("swarmer/sight1.wav");
	precache_sound("swarmer/sight2.wav");
	precache_sound("swarmer/sight3.wav");
	precache_sound("swarmer/idle1.wav");
	precache_sound("swarmer/idle2.wav");
	precache_sound("swarmer/idle3.wav");
	precache_sound("swarmer/idle4.wav");
	precache_sound("swarmer/idle5.wav");
	precache_sound("swarmer/idle6.wav");
	precache_sound("swarmer/idle7.wav");
	precache_sound("swarmer/idle8.wav");
	precache_sound("swarmer/footstep1.wav");
	precache_sound("swarmer/footstep2.wav");
	precache_sound("swarmer/footstep3.wav");
	precache_sound("swarmer/footstep4.wav");
	precache_sound("swarmer/footstep5.wav");
	precache_sound("swarmer/attack1.wav");
	precache_sound("swarmer/attack2.wav");
	precache_sound("swarmer/attack3.wav");
	precache_sound("swarmer/attack4.wav");
	precache_sound("swarmer/attack5.wav");
	precache_sound("swarmer/attack6.wav");
	precache_sound("swarmer/attack7.wav");
	precache_sound("swarmer/punch1.wav");
	precache_sound("swarmer/punch2.wav");
	precache_sound("swarmer/punch3.wav");
	precache_sound("swarmer/punch4.wav");
	precache_sound("swarmer/death1.wav");
	precache_sound("swarmer/death2.wav");
	precache_sound("swarmer/death3.wav");
	precache_sound("zombie/z_gib.wav");

	actor.steptype = FS_TYPEMEDIUM;

	actor.health = 10;
	actor.gibhealth = -40;
	actor.th_stand = swarmer_stand1;
	actor.th_walk = swarmer_walk1;
	actor.th_run = swarmer_run1;
	actor.th_pain = swarmer_pain;
	actor.th_die = swarmer_die;
	actor.th_melee = swarmer_melee;

	if(autocvar_skill >= 2)
		actor.alpha = 0.2;

	return true;
}
METHOD(Swarmer, mr_sight, bool(Swarmer this, entity actor))
{
	TC(Swarmer, this);

	float r = random();
	if(r < 0.33)
		_sound(actor, CH_VOICE, "swarmer/sight1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(actor, CH_VOICE, "swarmer/sight1.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "swarmer/sight1.wav", 1, ATTN_NORM);

	return true;
}
#endif
