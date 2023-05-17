#include "fireball.qh"

#include "sstats.qh"
#include "../subs/combat.qh"
#include "../subs/subs.qh"
#include "sval.qh"

void ball_hit(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(MagicHit(this, this.enemy, toucher))
	{
		if(this.noise)
			_sound(this, CHAN_AUTO, this.noise, 1, ATTN_NORM);
		delete(this);
	}
	else if(!toucher)
	{
		delete(this);
	}
	else
	{
		this.owner = toucher;
		this.velocity = this.dest1;
		this.ltime = this.nextthink;
		setthink(this, fix_velocity);
		this.nextthink = time;
	}
}

void fireball_go(entity this, float lev)
{
	float f = 0, b = 0, ofs = 0, n = 0;

	_sound(this, CH_WEAPON_SINGLE, "spells/fball.wav", 1, ATTN_NORM);

	if(lev >= 6)
	{
		b = 5;
		ofs = -20;
		n = 10;
	}
	else if(lev > 4)
	{
		b = 3;
		ofs = -15;
		n = 15;
	}
	else
		b = 1;
	if(lev == 0)
		f = 4;
	else
		f = (ceil(lev * lev * 1.5) + 7) / b;
	while(b > 0)
	{
		entity e = launch_projectile(this, ofs, 90 + lev * 10, spell_range(this, SP_FIREBALL), "progs/fball.mdl");
		e.effects =  EF_ADDITIVE;
		settouch(e, ball_hit);
		e.fire = f;
		e.enemy = this;
		e.owner = this;
		ofs += n;
		b -= 1;
	}
}
