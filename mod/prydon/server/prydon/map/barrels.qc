#include "barrels.qh"

#include "../spells/nova.qh"
#include "../spells/psnball.qh"
#include "../subs/_mod.qh"

void spawngib(entity this, string gibmodel)
{
	entity e = spawn();
	_setmodel(e, gibmodel);
	setthink(e, SUB_Remove);
	e.nextthink = time + 1 + random() * 5;
	
	setorigin(e, (this.absmin + this.absmax) * 0.5);
	setsize(e, '0 0 0', '0 0 0');
	set_movetype(e, MOVETYPE_BOUNCE);
	e.solid = SOLID_NOT;
	e.avelocity_x = random() * 600 - 300;
	e.avelocity_y = random() * 600 - 300;
	e.avelocity_z = random() * 600 - 300;
	e.velocity_x = random() * 300 - 150;
	e.velocity_y = random() * 300 - 150;
	e.velocity_z = random() * 80 + 100;
}

void barrel_poison(entity this)
{
	for(int n = 0; n < 3; n = n + 1)
		spawngib(this, this.bkup_model);
	generictrigger(this, NULL, NULL);
	_sound(this, CHAN_AUTO, this.noise4, 1, ATTN_NORM);
	this.owner = this;
	this.poidam = 30;
	this.enemy = this;
	this.takedamage = DAMAGE_NO;
	poisonball_hit(this, NULL);
}

void barrel_nova(entity this)
{
	for(int n = 0; n < 3; n = n + 1)
		spawngib(this, this.bkup_model);
	generictrigger(this, NULL, NULL);
	_sound(this, CHAN_AUTO, this.noise4, 1, ATTN_NORM);
	this.takedamage = DAMAGE_NO;
	nova_go(this, 0);
	delete(this);
}
void barrel_explode(entity this)
{
	this.tohit = 100;
	for(int n = 0; n < 3; n = n + 1)
		spawngib(this, this.bkup_model);
	generictrigger(this, NULL, NULL);
	_sound(this, CHAN_AUTO, this.noise4, 1, ATTN_NORM);	
	entity e = findradius(this.origin, 110);
	while(e)
	{
		if(e.takedamage)
		{
			if(!friendly(e, this))
			{
				this.fire = 5;
				MagicHit(this, this, e);
			}
		}
		e = e.chain;
	}
	te_explosion(this.origin);

	delete(this);
}

void barrel_die(entity this, float bodydeath)
{
	if(this.altdie)
	{
		setthink(this, this.altdie);
		this.nextthink = time;
		return;
	}
	
	dropallitems(this);
	for(int i = 0; i < 3; i = i + 1)
		spawngib(this, this.bkup_model);
	_sound(this, CHAN_AUTO, this.noise4, 1, ATTN_NORM);
	generictrigger(this, NULL, NULL);
	delete(this);
}

spawnfunc(barrel)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	if(!this.model)
		this.model = "progs/barrel.mdl";
	precache_model(this.model);
	if(!this.noise4)
		this.noise4 = "misc/barrel.wav";
	precache_sound(this.noise4);
	this.effects = EF_SELECTABLE;
	if(!this.bkup_model)
		this.bkup_model = "progs/shrap.mdl";
	precache_model(this.bkup_model);
	_setmodel(this, this.model);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	
	this.classname	= "barrel";
	if(!this.netname)
		this.netname = "barrel";
	this.health = 1;
	this.max_health = 1;
	this.owner = this;
	this.player = this;
	set_movetype(this, MOVETYPE_TOSS);
	this.solid	= SOLID_BBOX;
	if(!this.team)
		this.team = 2;
	this.takedamage = DAMAGE_YES;
	this.flags = 0;
	this.die = barrel_die;
	// first possible trap
	if(this.droprandom)
	{
		if(random() < 0.1)
		{
			float r = random();
			if(r < 0.4)
				this.altdie = barrel_explode;
			else if(r < 0.7)
				this.altdie = barrel_poison;
			else
				this.altdie = barrel_nova;
		}
	}
	this.frags = 1;
	this.dodge = 1;
}

spawnfunc(hitwall)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	if(!this.bkup_model)
		this.bkup_model = "progs/shrap.mdl";
	legacy_fixinv(this);

	precache_model(this.bkup_model);
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	_setmodel(this, this.model);
	if(!this.max_health)
		this.max_health = 1;
	if(!this.health)
		this.health = this.max_health;
	if(!this.team)
		this.team = 2;
	this.takedamage = DAMAGE_YES;
	if(this.spawnflags)
	{
		this.pain = generictrigger;
		this.flags |= FL_GODMODE;
	}
	this.effects = EF_SELECTABLE;
	this.die = barrel_die;	
	this.owner = this;
	this.player = this;
	this.frags = 1;
	this.dodge = 1;
}
