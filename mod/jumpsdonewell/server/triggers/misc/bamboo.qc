#ifdef SVQC

spawnfunc(misc_bamboo);
void bamboo_die_proper(entity this)
{
	setthink(this, spawnfunc_misc_bamboo);
	this.nextthink = time + 20;
	this.modelindex = 0;
	this.takes_damage = false;
	this.solid = SOLID_NOT;
	sound(this, CHAN_AUTO, SND_SWORD2, 0.7, ATTEN_NORM);
	pointparticles(EFFECT_ENEMY_DIE, this.origin + '0 0 32', '0 0 1', 1);
	CSQCMODEL_AUTOUPDATE(this);
}

void bamboo_die(entity this)
{
	this.frame = 2;
	setthink(this, bamboo_die_proper);
	this.nextthink = time + 0.4;
	CSQCMODEL_AUTOUPDATE(this);
}

void bamboo_hurt2(entity this)
{
	this.frame = 1;
	CSQCMODEL_AUTOUPDATE(this);
}

void bamboo_hurt(entity this)
{
	this.frame = 0;
	setthink(this, bamboo_hurt2);
	this.nextthink = time + 0.01;
	CSQCMODEL_AUTOUPDATE(this);
}

spawnfunc(misc_bamboo)
{
	setmodel(this, MDL_BAMBOO2);
	this.solid = SOLID_BBOX;
	setsize(this, '-32 -32 -100', '32 32 225');
	this.takes_damage = true;
	this.die = bamboo_die;
	this.hurt = bamboo_hurt;
	this.health = 30;
	this.frame = 0;
	CSQCMODEL_AUTOINIT(this);
}

#endif
