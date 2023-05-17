#include "meteor.qh"

#include "../subs/combat.qh"
#include "../subs/subs.qh"

void meteor_hit(entity this, entity toucher)
{
	float n = 35 * this.frags * this.frags + 60;
	
	entity e = findradius(this.origin, n);
	while(e)
	{
		if(e.takedamage)
		{
			if(!friendly(e, this))
			{
				this.fire = (n - vlen(e.origin - this.origin) * 0.3) + 5;
				// ugh
				
				MagicHit(this, this.enemy, e);
			}
		}
		e = e.chain;
	}
	te_explosion(this.origin);
	delete(this);
}

void meteor_hitthink(entity this)
{
	meteor_hit(this, NULL);
}

void meteor_go(entity this)
{
	_setmodel(this, "progs/meteor.mdl");
	this.avelocity = (random() *  '3000 0 0' + random() * '0 3000 0' + random() * '0 0 3000') - '1500 1500 1500';
	setsize(this, '0 0 0', '0 0 0');
	this.velocity = this.finalangle;
	set_movetype(this, MOVETYPE_FLY);
	this.solid = SOLID_BBOX;
	settouch(this, meteor_hit);
	setthink(this, meteor_hitthink);
	this.nextthink = this.ac + 2;
	this.enemy = this.owner;
}
