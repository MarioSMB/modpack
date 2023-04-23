#include "triggers/misc/vine.qh"

void damage(entity attacker, entity victim, float dmg)
{
	if(!victim) return;
	if(victim.invuln_time > time) return;
	if(victim.health <= 0) return;
	
	victim.health -= dmg;
	victim.pain_time = time;
	if(victim.hurt)
		victim.hurt(victim);
	if(victim.health <= 0 && victim.die)
		victim.die(victim);
	
	if(IS_PLAYER(victim))
		victim.invuln_time = time + 0.4;
}

void player_attack(entity this)
{
	makevectors(this.v_angle);
	FOREACH_ENTITY_RADIUS(this.origin + this.view_ofs, 90, it.takedamage && it != this && (!autocvar_g_friendlyfire_virtual || !IS_PLAYER(it)),
	{
		vector dir = normalize(it.origin - this.origin);
		if((v_forward * dir) >= 0.5)
		{
			pointparticles(EFFECT_ENEMY_HIT, it.origin + '0 0 32', -dir, 1);
			float take = 10;
			if(IS_PLAYER(it))
				take = 1;
			damage(this, it, take);
			sound(it, CHAN_AUTO, SND_SWORD2, 0.7, ATTEN_NORM);
		}
	});
}

void player_spin_attack(entity this)
{
	FOREACH_ENTITY_RADIUS(this.origin, 110, true,
	{
		if(it.classname == "misc_vine" && it.solid != SOLID_NOT) // cheap death check
			vine_destroy(it);
		if(it.takedamage && it != this && (!autocvar_g_friendlyfire_virtual || !IS_PLAYER(it)))
		{
			vector dir = normalize(it.origin - this.origin);
			pointparticles(EFFECT_ENEMY_HIT, it.origin + '0 0 32', -dir, 1);
			float take = 10;
			if(IS_PLAYER(it))
				take = 1;
			damage(this, it, take);
		}
	});
}

void player_weapons(entity this)
{
	if(STAT(SWORDPOWER, this) > 1 && time > STAT(ATTACK_FINISHED, this) + 1.5 && !STAT(CHARGED, this))
	{
		STAT(CHARGED, this) = true;
		pointparticles(EFFECT_WEAPON_CHARGED, this.origin + '0 0 64', '0 0 100', 1);
		sound(this, CHAN_AUTO, SND_DING, 0.7, ATTEN_NORM);
	}

	if(PHYS_INPUT_BUTTON_ATCK(this) && STAT(SWORDPOWER, this) > 0)
	{
		if(time + 0.2 > STAT(ATTACK_FINISHED, this) && this.attack_released)
		{
			if(STAT(CHARGED, this))
			{
				this.frame = 7;
				STAT(ATTACK_FINISHED, this) = time + 0.65;
				this.attack_fired = 0;
			}
			else
			{
				sound(this, CHAN_AUTO, SND_SWORD1, 0.8, ATTEN_NORM);
				this.frame = (this.frame == 3) ? 4 : 3;
				STAT(ATTACK_FINISHED, this) = time + 0.35;
				this.attack_fired = 0;
				STAT(CHARGED, this) = false;
			}
		}
		this.attack_released = false;
	}
	else
		this.attack_released = true;

	if(time > STAT(ATTACK_FINISHED, this) - 0.2 && !this.attack_fired && !STAT(CHARGED, this))
	{
		player_attack(this);
		this.attack_fired = 1;
	}
	
	if(STAT(CHARGED, this) && time < STAT(ATTACK_FINISHED, this))
	{
		if(time > STAT(ATTACK_FINISHED, this) - 0.4 && this.attack_fired < 1)
		{
			++this.attack_fired;
			player_spin_attack(this);
			pointparticles(EFFECT_WEAPON_SPIN, this.origin + '0 0 48', '0 0 1', 1);
			sound(this, CHAN_AUTO, SND_SWORD1, 1, ATTEN_NORM);
		}
		if(time > STAT(ATTACK_FINISHED, this) - 0.325 && this.attack_fired < 2)
		{
			++this.attack_fired;
			player_spin_attack(this);
			pointparticles(EFFECT_WEAPON_SPIN, this.origin + '0 0 48', '0 0 1', 1);
			sound(this, CHAN_AUTO, SND_SWORD1, 0.85, ATTEN_NORM);
		}
		if(time > STAT(ATTACK_FINISHED, this) - 0.25 && this.attack_fired < 3)
		{
			++this.attack_fired;
			player_spin_attack(this);
			pointparticles(EFFECT_WEAPON_SPIN, this.origin + '0 0 48', '0 0 1', 1);
			sound(this, CHAN_AUTO, SND_SWORD1, 0.75, ATTEN_NORM);
			
			STAT(CHARGED, this) = false;
		}
	}
}
