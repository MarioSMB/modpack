/* Bullet holes QuickC program
	By Jim Dose'  11/20/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

/*QUAKED wallsprite (0 1 0) (-8 -8 -8) (8 8 8)
Places a sprite on a wall.  Angles should be opposite of face.

"model" sprite to place on wall.  Default is "progs/s_blood1.spr".
*/
spawnfunc(wallsprite)
{
	if(!this.model)
		this.model = "progs/s_blood1.spr";

	precache_model( this.model );
	_setmodel (this, this.model );

	// QuakeEd doesn't save up and down angles properly.
	if(this.angles == '0 -1 0')
		this.angles = '-90 0 0';
	else if(this.angles == '0 -2 0')
		this.angles = '90 0 0';

	// Pull the sprite away from the wall slightly to
	// get rid of z sort errors.
	makevectors(this.angles);
	setorigin(this, this.origin - (v_forward * 0.2));
	makestatic(this);
}

PRECACHE(InitBulletHoles)
{
	if(fexists("progs/s_bullet.spr")) // we can't tell if hipnotic is active this early, so just check if the file exists to silence the warning
		precache_model("progs/s_bullet.spr");

	bulletholes = NULL;
	lastbullet = NULL;
	numbulletholes = 0;
}


void remove_bullethole(entity this)
{
	// There is a possibility that this is not the first bullet
	// in the list, but it doesn't really matter.  All that
	// matters is there is one less bullet.  Just make sure
	// we don't remove the world!
	if(!bulletholes)
		return; // nothing to remove

	entity ent = bulletholes;
	if(ent.classname != "bullethole")
		return; // wtf

	bulletholes = bulletholes.lastvictim;
	delete(ent);
	if(lastbullet == ent)
		lastbullet = NULL;

	numbulletholes -= 1;
}

void placebullethole(vector pos)
{
	entity bullet = spawn();
	bullet.owner = bullet;
	set_movetype(bullet, MOVETYPE_NONE);
	bullet.solid = SOLID_NOT;
	bullet.classname = "bullethole";
	_setmodel( bullet, "progs/s_bullet.spr" );
	setsize (bullet, '0 0 0', '0 0 0');

	vector norm = trace_plane_normal;
	norm.x = 0 - norm.x;
	norm.y = 0 - norm.y;
	bullet.angles = vectoangles(norm);
	makevectors(bullet.angles);
	setorigin(bullet, pos - (v_forward * 0.2));

	setthink(bullet, remove_bullethole);
	bullet.nextthink = time + 300;

	numbulletholes = numbulletholes + 1;
	if(numbulletholes > 10)
		remove_bullethole(bullet);

	if(lastbullet != NULL)
		lastbullet.lastvictim = bullet;
	else
		bulletholes = bullet;
	bullet.lastvictim = NULL;
	lastbullet = bullet;
}
