#ifdef SVQC

/*QUAKED wallsprite (0 1 0) (-8 -8 -8) (8 8 8)
Places a sprite on a wall.  Angles should be opposite of face.

"model" sprite to place on wall.  Default is "progs/s_blood1.spr".
*/
spawnfunc(wallsprite)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	if(!this.model)
		this.model = "progs/s_blood1.spr";

	precache_model(this.model);
	_setmodel(this, this.model);

	// QuakeEd doesn't save up and down angles properly.
	if(this.angles == '0 -1 0')
		this.angles = '-90 0 0';
	else if(this.angles == '0 -2 0')
		this.angles = '90 0 0';

	// Pull the sprite away from the wall slightly to
	// get rid of z sort errors.
	makevectors(this.angles);
	setorigin(this, this.origin - (v_forward * 0.2));
	//_makestatic_hidden(this);
}

#endif
