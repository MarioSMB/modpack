#ifdef SVQC

void fire_touch(entity this, entity toucher)
{
	T_Damage(toucher, this, this, 20);
	if(MP_MG && this.noise2 && this.noise2 != "")
		_sound(this, CH_VOICE, this.noise2, 0.8, ATTN_NORM);
	delete(this);
}

void fire_fly(entity this)
{
	entity fireball = new(fireball);
	fireball.spawnfunc_checked = true;
	fireball.solid = SOLID_TRIGGER;
	set_movetype(fireball, MOVETYPE_TOSS);
	if(MP_MG && this.movedir)
	{
		fireball.velocity = this.movedir;
		fireball.velocity_x += crandom() * 20;
		fireball.velocity_y += crandom() * 20;
		fireball.velocity_z += crandom() * 20;
	}
	else
	{
		fireball.velocity = '0 0 1000';
		fireball.velocity_x = (random() * 100) - 50;
		fireball.velocity_y = (random() * 100) - 50;
		fireball.velocity_z = this.speed + (random() * 200);
	}
	setmodel(fireball, MDL_LAVABALL);
	setsize(fireball, '0 0 0', '0 0 0');
	setorigin(fireball, this.origin);
	fireball.nextthink = time + 5;
	setthink(fireball, SUB_Remove);
	settouch(fireball, fire_touch);
	fireball.killstring = " ate a lavaball";

	if(MP_MG && this.noise && this.noise != "")
	{
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1.0, ATTN_NORM);
		fireball.noise2 = this.noise2;
	}
	
	this.nextthink = time + (random() * 5) + 3;
	setthink(this, fire_fly);
}

void fire_use(entity this, entity actor, entity trigger)
{
	fire_fly(this);
}


/*QUAKED misc_fireball(0 .5 .8)(-8 -8 -8)(8 8 8)
Lava Balls
*/

spawnfunc(misc_fireball)
{
	if(MP_MG)
	{
		if(!this.speed)
			this.speed = 1000;
		if(this.noise && this.noise != "")
			precache_sound(this.noise);
		if(this.noise2 && this.noise2 != "")
			precache_sound(this.noise2);
	}
	set_movetype(this, MOVETYPE_NONE); // link to the physics logic
	if(MP_MG && this.targetname && this.targetname != "")
		this.use = fire_use;
	else
	{
		this.nextthink = time + 1 + (random() * 5);
		setthink(this, fire_fly);
	}
	this.killstring = " ate a lavaball";
	if(!this.speed)
		this.speed = 1000;
}

#endif
