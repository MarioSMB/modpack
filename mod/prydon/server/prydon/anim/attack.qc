#include "attack.qh"

#include "common.qh"
#include "../subs/combat.qh"
#include "../subs/subs.qh"

float attack_animation(entity this)
{
	float b, f;
	
	this.frame = this.frame + 1;
	if(this.misc & MISC_DOUBLEATTACK)
	{
		b = (this.doubleattack - this.throwframes) / this.dblattkscenes;
		f = (this.frame - this.throwframes) - 1;
		f = (f - (floor(f / b) * b)) + 1;
	}
	else
	{
		b = (this.attackframes - this.deathframes) / this.attackscenes;
		f = (this.frame - this.deathframes) - 1;
		f = (f - (floor(f / b) * b)) + 1;
	}
	if(f == 1)
		if(this.noise)
			_sound(this, CH_VOICE, this.noise, 1, ATTN_NORM);


	if(f >= b)
	{
		setthink(this, AnimatePlayer);
		this.nextthink = time + 0.1;
	}

	face(this, 1);
	if(f == this.hitframe)
		if(range_check(this, SP_FIGHT_MELEE, this.enemy))
			return true;
	if(this.owner.spec & SPEC_TWO_HITS)
	{
		if(f == (this.hitframe + 1))
			if(range_check(this, SP_FIGHT_MELEE, this.enemy))
				return true;
	}
	return 0;
}

void attack_selectscene(entity this)
{
	float b;
	if(this.misc & MISC_DOUBLEATTACK)
	{
		b = (this.doubleattack - this.throwframes) / this.dblattkscenes;
		this.frame = this.doubleattack - ((ceil(random() * this.dblattkscenes) * b));
	}
	else
	{
		b = (this.attackframes - this.deathframes) / this.attackscenes;
		this.frame = this.attackframes - ((ceil(random() * this.attackscenes) * b));
	}
}

void attack_frames(entity this)
{
	setthink(this, attack_frames);
	this.nextthink = time + 0.1;
	
	if(attack_animation(this))
		if(Hit(this, this.enemy, SKILL_MELEE))
			_sound(this, CHAN_AUTO, "player/hit.wav", 1, ATTN_NORM);
}

void attack1(entity this)
{
	attack_selectscene(this);
	attack_frames(this);
	this.dbltime = 1;
}

void frenzy_frames(entity this)
{
	setthink(this, frenzy_frames);
	this.nextthink = time + 0.1;
	
	if(attack_animation(this))
	{
		if(Hit(this, this.enemy, SKILL_MELEE))
		{
			_sound(this, CHAN_AUTO, "player/hit.wav", 1, ATTN_NORM);
			this.frenzy_factor = this.frenzy_factor + this.owner.title_x + 1;
			this.frenzy_time = time + 5;
		}
	}
}

void frenzy1(entity this)
{
	attack_selectscene(this);
	frenzy_frames(this);
	this.dbltime = 1;
}

void brawl_frames(entity this)
{
	setthink(this, brawl_frames);
	this.nextthink = time + 0.1;

	if(attack_animation(this))
	{
		entity e = findradius(this.origin, 68);
		while(e)
		{
			if(e.takedamage)
			{
				if(infront(this, e))
				{
					if(!friendly(e, this))
					{
						if(Hit(this, e, SKILL_BRAWL))
						{
							_sound(this, CH_WEAPON_SINGLE, "player/hit.wav", 1, ATTN_NORM);
						}
					}
				}
			}
			e = e.chain;
		}
		// ugly slash sprite
		e = spawn();
		_setmodel(e, "progs/cresent.spr");
		makevectors(this.angles);
		setorigin(e, this.origin + v_forward * 32);
		e.alpha = 0.2;
		e.angles_x = 90;
		e.angles_y = this.angles_y;
		e.angles_z = 0;
		setthink(e, SUB_Remove);
		e.nextthink = time + 0.1;
	}
}

void brawl1(entity this)
{
	attack_selectscene(this);
	brawl_frames(this);
	this.dbltime = 1;
}
