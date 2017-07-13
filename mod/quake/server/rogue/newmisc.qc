// Miscellaneous items used in the Rogue XPACK


/*QUAKED light_lantern (0 .5 0) (-10 -10 -20) (10 10 20)
Light-emitting lantern.
Default light value is 200
Default style is 0
*/
spawnfunc(light_lantern)
{
	if(!MP_ROGUE) { delete(this); return; }

	precache_model("progs/lantern.mdl");
	_setmodel(this, "progs/lantern.mdl");
	makestatic(this);
}

/*QUAKED light_candle (0 .5 0) (-4 -4 -10) (4 4 10)
Candle
Default light value is 200
Default style is 0
*/
spawnfunc(light_candle)
{
	if(!MP_ROGUE) { delete(this); return; }

	precache_model("progs/candle.mdl");
	_setmodel(this, "progs/candle.mdl");
	makestatic(this);
}

// ==========================================
// rubble generator
// ==========================================
void rubble_touch(entity this, entity toucher)
{
	if(IS_PLAYER(toucher) || (toucher.flags & FL_MONSTER))
	if(vdist(this.velocity, >, 0))
		T_Damage(toucher, this, this, 10);
}

void rubble_throw(entity this)
{
	entity rubble = find ( NULL, targetname, this.target );
	vector throw = normalize ( rubble.origin - this.origin );
	throw.x = throw.x + (random() * 0.2) - 0.1;
	throw.y = throw.y + (random() * 0.2) - 0.1;
	throw.z = throw.z + (random() * 0.2) - 0.1;
	
	rubble = new(rubble);
	rubble.owner = this;
	set_movetype(rubble, MOVETYPE_BOUNCE);
	rubble.solid = SOLID_BBOX;
	rubble.velocity = throw * 300;
	_setmodel(rubble, "progs/rubble.mdl");
	setsize(rubble, '-16 -16 -16', '16 16 16');
	setorigin(rubble, this.origin);
	settouch(rubble, rubble_touch);
	
	setthink(rubble, SUB_Remove);
	rubble.nextthink = time + 30;
	
	if (this.spawnflags & 1)
		rubble.skin = 1;
	else
		rubble.skin = 0;

	setthink(this, rubble_throw);
	this.nextthink = time + this.delay;
}

void rogue_rubble_use(entity this, entity actor, entity trigger)
{
	if(this.wait == 0)
	{
		setthink(this, rubble_throw);
		this.nextthink = time + this.delay;
		this.wait = 1;
	}
	else
	{
		if(getthink(this))
			this.nextthink = time - 1;
		this.wait = 0;
	}
}

/*QUAKED rubble_generator (1 1 0) (-8 -8 -8) (8 8 8) LavaRock Active
Rubble Generator - cave colored rock chunks flung at the target. Triggering the generator will turn it off and on.

LavaRock - a lava rock texture, based on rich's pumice
Active - start the generator immediately.

delay - time between rubble pieces (Default 5 sec)
*/
spawnfunc(rubble_generator)
{
	if(!MP_ROGUE) { delete(this); return; }

	precache_model("progs/rubble.mdl");
	
	if(!this.target)
		objerror(this, "rubble_generator has no target!");
		
	if(!this.delay)
		this.delay = 5;
	
	this.solid = SOLID_NOT;
	this.use = rogue_rubble_use;

	if(this.spawnflags & 2)
		rogue_rubble_use(this, NULL, NULL);		
}
