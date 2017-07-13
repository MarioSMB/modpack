#ifdef SVQC

void fire_touch(entity this, entity toucher)
{
	T_Damage(toucher, this, this, 20);
	delete(this);
}

void fire_fly(entity this)
{
	entity fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	set_movetype(fireball, MOVETYPE_TOSS);
	fireball.velocity = '0 0 1000';
	fireball.velocity_x =(random() * 100) - 50;
	fireball.velocity_y =(random() * 100) - 50;
	fireball.velocity_z = this.speed +(random() * 200);
	fireball.classname = "fireball";
	_setmodel(fireball, "progs/lavaball.mdl");
	setsize(fireball, '0 0 0', '0 0 0');
	setorigin(fireball, this.origin);
	fireball.nextthink = time + 5;
	setthink(fireball, SUB_Remove);
	settouch(fireball, fire_touch);
	
	this.nextthink = time +(random() * 5) + 3;
	setthink(this, fire_fly);
}


/*QUAKED misc_fireball(0 .5 .8)(-8 -8 -8)(8 8 8)
Lava Balls
*/

spawnfunc(misc_fireball)
{
	
	precache_model("progs/lavaball.mdl");
	this.classname = "fireball";
	this.nextthink = time +(random() * 5);
	setthink(this, fire_fly);
	if(!this.speed)
		this.speed = 1000;
}

#endif
