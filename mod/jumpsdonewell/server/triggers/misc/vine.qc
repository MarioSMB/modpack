#ifdef SVQC

void vine_destroy(entity this)
{
	setmodel(this, MDL_VINE_BROKEN);
	this.solid = SOLID_NOT;
	pointparticles(EFFECT_ENEMY_DIE, this.origin + '0 0 32', '0 0 1', 1);
	sound(this, CHAN_AUTO, SND_SWORD2, 0.7, ATTEN_NORM);
	setthink(this, spawnfunc_misc_vine);
	this.nextthink = time + 20;
	CSQCMODEL_AUTOUPDATE(this);
}

spawnfunc(misc_vine)
{
	setmodel(this, MDL_VINE);
	this.solid = SOLID_BBOX;
	this.angles_y = random() * 360;
	setsize(this, '-32 -32 0', '32 32 128');
	CSQCMODEL_AUTOINIT(this);
}

#endif
