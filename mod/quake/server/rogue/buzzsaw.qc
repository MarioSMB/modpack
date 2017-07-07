$skin buzzsaw
const int anim_buzzsaw = 0;

const int anim_buzzsaw_bzzrot01 = 1;
const int anim_buzzsaw_bzzrot02 = 2;
const int anim_buzzsaw_bzzrot03 = 3;
const int anim_buzzsaw_bzzrot04 = 4;
const int anim_buzzsaw_bzzrot05 = 5;
const int anim_buzzsaw_bzzrot06 = 6;

void buzzsaw_stand1(entity this)
{
	set_anim(this, anim_buzzsaw, buzzsaw_stand1);

	if(this.pain_finished < time)
	{
		_sound(this, CHAN_VOICE, "buzz/buzz1.wav", 0.2, ATTN_NORM);
		this.pain_finished = time + 1;
	}
	
	this.angles_x = this.angles_x - 60;
	this.avelocity_x = 60;
}

void buzzsaw_fly(entity this)
{
	if(this.pain_finished < time)
	{
		_sound(this, CHAN_VOICE, "buzz/buzz1.wav", 0.2, ATTN_NORM);
		this.pain_finished = time + 1;
	}

	vector dir = this.goalentity.origin - this.origin;
	dir = normalize(dir);
	dir = dir * this.speed;
	setorigin(this, this.origin + dir);
	this.angles_x = this.angles_x - 60;
	this.avelocity_x = 60;
}

void buzzsaw_fly1(entity this) { set_anim(this, anim_buzzsaw_bzzrot01, buzzsaw_fly1); buzzsaw_fly(this); }

void buzzsaw_touch(entity this, entity toucher) 
{
	if(IS_PLAYER(toucher) || IS_MONSTER(toucher))
	{
		if(this.attack_finished < time )
		{
			_sound(this, CHAN_WEAPON, "buzz/buzz.wav", 1, ATTN_NORM);
			this.attack_finished = time + 2;
		}
		T_Damage(toucher, this, this, this.currentammo);

		vector sprayDir = normalize(this.goalentity.origin - this.origin);
		sprayDir = sprayDir * 200;
		SpawnMeatSpray(this, this.origin, sprayDir);
		
		toucher.velocity = sprayDir;
		toucher.velocity_z = 200;
	}
}

void buzzsaw_use(entity this, entity actor, entity trigger)
{
	settouch(this, buzzsaw_touch);
	if(this.target)
	{		
		this.movetarget = find(NULL, targetname, this.target);
		this.goalentity = this.movetarget;
		this.th_stand =  buzzsaw_fly1;
		this.th_walk = buzzsaw_fly1;
		this.th_run = buzzsaw_fly1;
		setthink(this, buzzsaw_fly1);
		this.nextthink = time + 0.1;
	}
	else
	{
		this.nextthink = time + 0.1;
		setthink(this, buzzsaw_stand1);
	}
	this.use = func_null;
}

void buzzsaw_use_think(entity this)
{
	buzzsaw_use(this, NULL, NULL);
}

/*QUAKED buzzsaw (0 .5 .8) (-18 -18 -18) (18 18 18) Vertical
The buzzsaw trap.

currentammo: amount of damage for each contact. (default 10)
speed: speed that it will follow it's path. (default 10)

Use the angle buttons to point the buzzsaw in the direction it
should face.

Place on a monster path if you want it to move.

If it is targeted, it will wait until triggered to activate.

It will not damage players until activated.
*/
spawnfunc(buzzsaw)
{
	if(!MP_ROGUE) { delete(this); return; }

	precache_model("progs/buzzsaw.mdl");

	precache_sound("buzz/buzz.wav");
	precache_sound("buzz/buzz1.wav");
	
	_setmodel(this, "progs/buzzsaw.mdl");

	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_FLY);

	if(this.angles_y == 0 || this.angles_y == 180)
		setsize(this, '-18 0 -18', '18 0 18');
	else if(this.angles_y == 90 || this.angles_y == 270)
		setsize(this, '0 -18 -18', '0 18 18');
	else
		objerror(this, "Buzzsaw: Not at 90 degree angle!");

	setorigin(this, this.origin);
	
	if(!this.speed)
		this.speed = 10;
	if(!this.currentammo)
		this.currentammo = 10;
	
	this.pain_finished = time + random()*2;
	
	if(!this.targetname)
	{
		setthink(this, buzzsaw_use_think);
		this.nextthink = time + 0.2;		
	}
	else
		this.use = buzzsaw_use;
}

