#include "psnball.qh"

#include "fireball.qh"
#include "sstats.qh"
#include "../subs/combat.qh"
#include "../subs/subs.qh"

void homing(entity this)
{
	vector v = normalize(this.goalentity.origin - this.origin);
	this.velocity = normalize(v * 5 + this.velocity) * 120;
	this.angles = vectoangles(this.velocity);
	this.nextthink = time + 0.01;
	if(this.attack_finished < time)
		delete(this);
}

void poison_3(entity this) { set_anim(this, 2, SUB_Remove); }
void poison_2(entity this) { set_anim(this, 1, poison_3); }
void poison_1(entity this) { set_anim(this, 0, poison_2); }

void poisonball_hit(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	_setmodel(this, "progs/poison.spr");
	this.velocity = '0 0 0';
	this.solid = SOLID_NOT;
	poison_1(this);
	
	entity e = findradius(this.origin, 220);
	while(e)
	{
		MagicHit(this, this.enemy, e);
		e = e.chain;
	}
}

void poisonball_go(entity this, float lev)
{
	entity e = launch_projectile(this, 0, 120, spell_range(this, SP_POISONBALL), "progs/w_spike.mdl");
	if(lev > 4)
		settouch(e, poisonball_hit);
	else
		settouch(e, ball_hit);
	e.poidam = ceil(lev * lev * 1.2) + 20;
	setthink(e, homing);
	e.goalentity = this.enemy;
	e.enemy = this;
	e.owner = this;
	e.nextthink = time;
	e.attack_finished = time + 10;
	_sound(this, CH_WEAPON_SINGLE, "spells/pfire.wav", 1, ATTN_NORM);
}
