/*==============================================================================

Rubicon 2 code by john fitzgibbons

==============================================================================*/

.float angle2;

/*
===============================================================================
func_laser
===============================================================================
*/

const int LASER_SOLID = 2;
const int LASER_SILENT = 4;
const int LASER_DONTHURTMONSTERS = 8;

.string message2;

void laser_helper_think(entity this)
{
	if(!this.owner || this.owner.classname != "func_laser")
	{
		delete(this);
		return;
	}
	
	if(this.owner.state)
		this.owner.alpha = this.alpha * 0.8 + this.alpha * random() * 0.4;
			
	this.nextthink = time + 0.05;
}

void func_laser_touch(entity this, entity toucher)
{
	if(!this.state || !this.dmg)
		return;

	if(IS_MONSTER(toucher) && (this.spawnflags & LASER_DONTHURTMONSTERS))
		return;

	if(toucher.takedamage && this.attack_finished < time)
	{
		T_Damage(toucher, this, this, this.dmg, DEATH_LASER.m_id);
		this.attack_finished = time + 0.1;
	}

}

void func_laser_use(entity this, entity actor, entity trigger)
{
	if(!this.state)
	{
		if(this.spawnflags & LASER_SOLID)
		{
			this.solid = SOLID_BSP;
			set_movetype(this, MOVETYPE_PUSH);
		}

		_setmodel(this, this.mdl);
		if(!(this.spawnflags & LASER_SILENT))
			_sound(actor, CH_TRIGGER_SINGLE, "misc/laser_on.wav", 1, ATTN_NORM);

		if(IS_PLAYER(actor) && IS_REAL_CLIENT(actor) && this.message != "")
			centerprint(actor, this.message);

		this.state = 1;
	}
	else
	{
		if(this.spawnflags & LASER_SOLID)
		{
			this.solid = SOLID_NOT;
			set_movetype(this, MOVETYPE_NONE);
		}

		_setmodel(this, "");

		if(!(this.spawnflags & LASER_SILENT))
			_sound(actor, CH_TRIGGER_SINGLE, "misc/laseroff.wav", 1, ATTN_NORM);
		
		if(IS_PLAYER(actor) && IS_REAL_CLIENT(actor) && this.message2 != "")
			centerprint(actor, this.message2);

		this.state = 0;
	}
}

/*QUAKED func_laser (0 .5 .8) ? START_OFF LASER_SOLID
A togglable laser, hurts to touch, can be used to block players

START_OFF: Laser starts off.

LASER_SOLID: Laser blocks movement while turned on.

Keys:

"dmg" damage to do on touch. default 1

"alpha" approximate alpha you want the laser drawn at. default 0.5. alpha will vary by 20% of this value.

"message" message to display when activated

"message2" message to display when deactivated

*/

spawnfunc(func_laser)
{
	this.mdl = this.model;
	
	if(this.spawnflags & LASER_SOLID)
	{
		if(this.spawnflags & START_OFF)
		{
			this.solid = SOLID_NOT;
			set_movetype(this, MOVETYPE_NONE);
		}
		else
		{
			this.solid = SOLID_BSP; //so you can shoot between lasers in a single bmodel
			set_movetype(this, MOVETYPE_PUSH);
		}
	}
	else
	{
		this.solid = SOLID_TRIGGER;
		set_movetype(this, MOVETYPE_NONE);
	}

	if(this.spawnflags & START_OFF)
	{
		this.state = 0;
		_setmodel(this, "");
	}
	else
	{
		this.state = 1;
		_setmodel(this, this.model);
	}

	precache_sound("misc/laser_on.wav");
	precache_sound("misc/laseroff.wav");
	
	if(!this.alpha)
		this.alpha = 0.5;
		
	this.flags |= FL_NOTARGET; // monsters won't try to get mad at the laser

	this.dmg = zeroconvertdefault(this.dmg, 1);
		
	this.use = func_laser_use;

	settouch(this, func_laser_touch);

	//spawn a second entity to handle alpha changes, since MOVETYPE_PUSH doesn't support think functions
	entity helper = spawn();
	helper.classname = "laser_helper";
	helper.alpha = this.alpha;
	helper.owner = this;
	helper.nextthink = 0.05;
	setthink(helper, laser_helper_think);
}

/*
===============================================================================
item_circuitboard
===============================================================================
*/

void circuitboard_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	if(!(this.spawnflags & 1))
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_BACKPACK_GOT, this.netname);
	_sound(toucher, CHAN_ITEM, this.noise, 1, ATTN_NORM);
	SUB_UseTargets(this, toucher, toucher);
	delete(this);
}

/*QUAKED item_circuitboard (0 .5 .8) (-16 -16 -24) (16 16 32)
collectible circuit board thing
*/
spawnfunc(item_circuitboard)
{
	if(!this.mdl || this.mdl == "")
		this.mdl = "progs/fromitz.mdl";
	precache_model(this.mdl);
	_setmodel(this, this.mdl);

	if(!this.netname || this.netname == "")
		this.netname = "the 17-centimeter Fromitz board!";
	
	if(!this.noise || this.noise == "")
		this.noise = "misc/basekey.wav";//"items/protect.wav";

	precache_sound(this.noise);

	settouch(this, circuitboard_touch);
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*
===============================================================================
light_fixture1
===============================================================================
*/

/*QUAKED light_fixture1 (0 1 0) (-8 -8 -8) (8 8 24)
wall-mounted light fixture.
Default light value is 300
Default style is 0

Keys:
"angle2" is the angle the model should be facing; set it to face away from the wall
*/
spawnfunc(light_fixture1)
{
	precache_model("progs/fixture1.mdl");
	_setmodel(this, "progs/fixture1.mdl");
	this.angles_y = this.angle2;
}


/*
===============================================================================
light_beacon
===============================================================================
*/

/*QUAKED light_beacon (0 1 0) (-8 -8 -36) (8 8 8) BLINKING
floor-mounted flashing red beacon
Default light value is 300
Default style is 0

Flags:
"Blinking" if you want the beacon to blink (Set style to "16" to match the skin animation.)

Keys:
"angle2" can be used to rotate the model
*/
spawnfunc(light_beacon)
{
	precache_model("progs/beacon.mdl");
	_setmodel(this, "progs/beacon.mdl");
	if(this.spawnflags & 1)
		this.skin = 1;
	this.angles_y = this.angle2;
}

/*
===============================================================================
misc_flag
===============================================================================
*/

/*QUAKED misc_flag (1 0 0) (-8 -8 -8) (8 8 8) NOT_ANIMATED BIG
A hanging banner, gently waving in the wind. Normal dimensions: 64 wide by 144 long.

Flags:
"Not Animated" Banner is not animated.
"Big" Banner is twice as big: 128 wide by 288 long.
*/
spawnfunc(misc_flag)
{
	precache_model("progs/flag.mdl");
	_setmodel(this, "progs/flag.mdl");
	this.frame = (this.spawnflags & 3);
}

/*
===============================================================================
misc_sparks
===============================================================================
*/

const int SPARKS_BLUE = 2;
const int SPARKS_PALE = 4;

void sparks_fade4(entity this) { setthink(this, SUB_Remove);   this.alpha = 0.2; this.nextthink = time + 0.05; }
void sparks_fade3(entity this) { setthink(this, sparks_fade4); this.alpha = 0.4; this.nextthink = time + 0.05; }
void sparks_fade2(entity this) { setthink(this, sparks_fade3); this.alpha = 0.6; this.nextthink = time + 0.05; }
void sparks_fade1(entity this) { setthink(this, sparks_fade2); this.alpha = 0.8; this.nextthink = time + 0.05; }

void sparks_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & START_OFF)
		this.spawnflags &= ~START_OFF;
	else
		this.spawnflags |= START_OFF;
}

void misc_sparks_think(entity this);

void spark_turnofflight(entity this)
{
	SUB_UseTargets(this, NULL, NULL);
	setthink(this, misc_sparks_think);
	this.nextthink = time + (random() + 0.5) * this.wait - 0.15;
}

void spawnsparks(entity this, vector org, float qt, float thecolor, vector vel)
{
	float i = -0.25 * qt + random() * 0.5 * qt;
	while(i < qt)
	{
		entity spark = spawn();
		spark.owner = this;
		spark.solid = SOLID_TRIGGER;
		_setmodel(spark, "progs/spark.mdl");
		setsize(spark, '0 0 0', '0 0 0');
		setorigin(spark, org);
		set_movetype(spark, MOVETYPE_BOUNCE);
		spark.gravity = 0.3;
		spark.velocity_x = vel_x -40 + random() * 80;
		spark.velocity_y = vel_y -40 + random() * 80;
		spark.velocity_z = vel_z -40 + random() * 80;
		spark.avelocity = '3000 3000 3000';
		spark.nextthink = time + 0.5 + 1.5*random();
		setthink(spark, sparks_fade1);
		spark.classname = "spark";

		if(random() < 0.33)
			spark.skin = 0;
		else if(random() < 0.5)
			spark.skin = 1;
		else
			spark.skin = 2;

		if(thecolor == SPARKS_PALE)
			spark.skin = spark.skin + 6;
		else if(thecolor == SPARKS_BLUE)
			spark.skin = spark.skin + 3;

		i += 1;
	}
}

void misc_sparks_think(entity this)
{
	if(this.spawnflags & START_OFF)
	{
		this.nextthink = time + 0.1;
		setthink(this, misc_sparks_think);
	}
	else
	{
		float thecolor = 0;
		if(this.spawnflags & SPARKS_PALE)
			thecolor = SPARKS_PALE;
		else if(this.spawnflags & SPARKS_BLUE)
			thecolor = SPARKS_BLUE;

		//spawnsparks(this, this.origin, this.cnt, thecolor, '0 0 0');
		spawnsparks(this, this.origin, this.cnt, thecolor, this.movedir);

		if(this.sounds == 1)
			_sound(this, CHAN_AUTO, "misc/spark.wav", 1, ATTN_STATIC);

		SUB_UseTargets(this, NULL, NULL);
		this.nextthink = time + 0.1 + random() * 0.1;
		setthink(this, spark_turnofflight);

	}
	
}

/*QUAKED misc_sparks (0 .5 .8) (-8 -8 -8) (8 8 8) START_OFF SPARKS_BLUE SPARKS_PALE
Produces a burst of yellow sparks at random intervals. If targeted, it will toggle between on or off.  If it targets a light, that light will flash allong with each burst of sparks. Note: targeted lights should be set to START_OFF.

SPARKS_BLUE: sparks are blue in color

SPARKS_PALE: sparks are pale yellow in color

Keys:

"wait" is the average delay between bursts (variance is 1/2 wait). Default is 2. 

"cnt" is the average number of sparks in a burst (variance is 1/4 cnt). Default is 15.

"sounds"
0)	no sound
1)	sparks
*/
spawnfunc(misc_sparks)
{
	precache_model("progs/spark.mdl");
	precache_sound("misc/spark.wav");

	if(!this.movedir)
		this.movedir = '0 0 -30';
	if(!this.wait)
		this.wait = 2;
	if(!this.cnt)
		this.cnt = 15;
	
	this.use = sparks_use;
	this.nextthink = time + random() * 0.1;
	setthink(this, misc_sparks_think);
}

/*
===============================================================================
misc_smoke
===============================================================================
*/

.vector movedir2;

void smoke_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(this.dmg > 0 && toucher.takedamage)
	{
		T_Damage(toucher, this, this, this.dmg, this.projectiledeathtype);
		this.dmg = 0;
	}	
	this.velocity = '0 0 0'; //FIXME: can't set velocity in a touch function
	this.movedir = '0 0 0';
	this.movedir2 = '0 0 15';
}

void smoke_rise(entity this)
{
	this.cnt += 1;
	if(this.cnt > 6)
	{
		delete(this);
		return;
	}
	this.frame = this.cnt;
	this.velocity = this.velocity + this.movedir2 - (this.movedir * 0.12);
	this.nextthink = time + 0.1 + random() * 0.05;
	setthink(this, smoke_rise);
}

void smoke_think(entity this)
{
	if(this.spawnflags & START_OFF)
	{
		setthink(this, smoke_think);
		this.nextthink = time + 0.1;
	}
	else
	{
		entity smoke = spawn();
		smoke.owner = this;
		smoke.solid = SOLID_BBOX; //was SOLID_TRIGGER or SOLID_BBOX?
		_setmodel(smoke, "progs/s_smoke.spr");
		setsize(smoke, '0 0 0', '0 0 0');
		setorigin(smoke, this.origin);
		set_movetype(smoke, MOVETYPE_FLY); //MOVETYPE_NOCLIP or MOVETYPE_FLY ?
		smoke.velocity_x = this.movedir_x - 10 + random() * 20;
		smoke.velocity_y = this.movedir_y - 10 + random() * 20;
		smoke.velocity_z = this.movedir_z - 10 + random() * 20;
		smoke.angles_z = random() * 360;
		smoke.nextthink = time + 0.1 + random() * 0.05;
		setthink(smoke, smoke_rise);
		settouch(smoke, smoke_touch);
		smoke.classname = "smoke";
		smoke.dmg = this.dmg;
		smoke.movedir2 = this.movedir2;
		smoke.frame = 0;
		smoke.cnt = 0;
		smoke.alpha = this.alpha;
		smoke.projectiledeathtype = DEATH_STEAM.m_id;
		
		setthink(this, smoke_think);
		this.nextthink = time + this.wait;
	}
}

void smoke_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & START_OFF)
	{
		this.spawnflags &= ~START_OFF;
		if(this.sounds)
			_sound(this, CH_TRIGGER_SINGLE, "misc/airhiss.wav", 1, ATTN_STATIC);
	}
	else
	{
		this.spawnflags |= START_OFF;
		if(this.sounds)
			_sound(this, CH_TRIGGER_SINGLE, "misc/airhiss2.wav", 1, ATTN_STATIC);
	}
}

void smoke_firstthink(entity this)
{
	if(this.sounds && !(this.spawnflags & START_OFF))
		_sound(this, CH_TRIGGER_SINGLE, "misc/airhiss.wav", 1, ATTN_STATIC);

	setthink(this, smoke_think);
	this.nextthink = time;
}

/*QUAKED misc_smoke (0 .5 .8) (-8 -8 -8) (8 8 8) START_OFF
Produces a jet of smoke/steam. If targeted, it will toggle between on or off.

Keys:

"wait" is the delay between puffs. Default is 0.1

"movedir" is a vector representing the initial velocity in X Y Z values.  Default is "0 0 250" (up)

"movedir2" is a vector representing the wind in X Y Z values.  Default is "0 0 0"

"dmg" is the amount of damage each puff gives on contact. Default is 0

"sounds"
0)	no sound
1)	steam hiss
*/
spawnfunc(misc_smoke)
{
	precache_model("progs/s_smoke.spr");
	precache_sound("misc/airhiss.wav");
	precache_sound("misc/airhiss2.wav");
	
	if(!this.dmg)
		this.dmg = 0;
	if(!this.movedir)
		this.movedir = '0 0 250';
	if(!this.movedir2)
		this.movedir2 = '0 0 0';
	if(!this.wait)
		this.wait = 0.1;
						
	this.use = smoke_use;
	this.nextthink = time + 0.5;
	setthink(this, smoke_firstthink);
}


/*
===============================================================================
misc_flame
===============================================================================
*/
const int FLAME_DONTBURN = 2;
const int FLAME_NOSOUND = 4;
const int FLAME_SIMPLELIGHT = 8;

const int FLAME_ST_OFF = 0;
const int FLAME_ST_STOPPING = 1;
const int FLAME_ST_ON = 2;
const int FLAME_ST_STARTING = 3;

const string FLAME_LIGHT_PATTERN =  "klolmolmomlnonkmonqnlmo";

.entity missle;

void flame_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	this.movedir = '0 0 0';

	if(this.dmg > 0 && toucher.health > 0)
	{
		//direct damage
		T_Damage(toucher, this, this.owner, this.dmg, this.projectiledeathtype);
		this.dmg = 0;
	}
}

void flame_fly(entity this)
{
	this.frame = this.frame + 1;
	if(this.frame > 7 || pointcontents(this.origin) != CONTENT_EMPTY)
	{
		if(this.owner.missle == this)
			this.owner.missle = NULL;
		delete(this);
		return;
	}
	
	this.velocity = this.velocity + '0 0 30' - (this.movedir * 0.12);
	this.nextthink = time + 0.1;
}

entity make_flame(entity this, vector org, vector dir)
{
	//remove glow from previous flame
	if(this.missle)
		this.missle.effects = 0;
	
	entity newmis = spawn();
	newmis.owner = this;
	newmis.realowner = this;
	newmis.solid = SOLID_BBOX;
	_setmodel(newmis, "progs/s_flame.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
	set_movetype(newmis, MOVETYPE_FLY);
	//newmis.flags |= FL_PROJECTILE;
	vector variance = '-10 -10 -10' + random() * '20 20 20';
	newmis.movedir = normalize(dir) * 250 + '0 0 -50' + variance;
	newmis.velocity = newmis.movedir;
	float roll = 350 + random() * 20;
	newmis.angles_z = ANGLEMOD(roll);
	newmis.nextthink = time + 0.1;
	setthink(newmis, flame_fly);
	settouch(newmis, flame_touch);
	newmis.classname = "flame";
	newmis.dmg = 5;
	newmis.frame = 0;
	newmis.projectiledeathtype = DEATH_BURNING.m_id;
	
	//add glow to new flame
	this.missle = newmis;
	newmis.effects = EF_DIMLIGHT;

	return newmis;
}

.float burning_finished;
void misc_flame_think(entity this)
{
	if(this.state < FLAME_ST_ON)
	{
		this.nextthink = time + 0.1;
		if(this.state == FLAME_ST_STOPPING)
		{
			if(!(this.spawnflags & FLAME_NOSOUND))
				_sound(this, CH_TRIGGER_SINGLE, "misc/burning2.wav", 1, ATTN_IDLE);

			if(this.style)
				lightstyle(this.style, "a");
		}
		this.state = FLAME_ST_OFF;
		return;
	}

	entity newmis = make_flame(this, this.origin, this.movedir);
	if(!(this.spawnflags & FLAME_SIMPLELIGHT))
		newmis.effects = 0;

	newmis.velocity *= this.speed;
	
	if(this.spawnflags & FLAME_DONTBURN)
		newmis.style = 1;

	newmis.dmg = this.dmg;

	this.nextthink = time + this.wait;

	if(this.state == FLAME_ST_ON && !(this.spawnflags & FLAME_NOSOUND))
	{
		if(time > this.burning_finished)
			_sound(this, CH_TRIGGER_SINGLE, "misc/burning.wav", 1, ATTN_IDLE);
		this.burning_finished = time + 2.1;
	}

	if(this.state == FLAME_ST_STARTING)
	{
		
		this.state = FLAME_ST_ON;

		if(this.style)
			lightstyle(this.style, FLAME_LIGHT_PATTERN);

		if(!(this.spawnflags & FLAME_NOSOUND))
			_sound(this, CH_TRIGGER_SINGLE, "dread/flameon.wav", 1, ATTN_IDLE);

		this.burning_finished = time + 0.5;
	}
}


void misc_flame_use(entity this, entity actor, entity trigger)
{
	if(this.state >= FLAME_ST_ON)
		this.state = FLAME_ST_STOPPING;
	else
		this.state = FLAME_ST_STARTING;
}


void misc_flame_startup(entity this)
{
	if(this.target != "")
	{
		entity e = find(NULL, targetname, this.target);

		if(e.classname == "light") 
			this.style = e.style;

		if(this.style && this.state == FLAME_ST_OFF)
			lightstyle(this.style, "a");
	}
	this.use = misc_flame_use;
	setthink(this, misc_flame_think);
	this.nextthink = time + 0.1;
}

void SetMovedir(entity this);
spawnfunc(misc_flame)
{
	precache_model("progs/s_flame.spr");
	precache_sound("dread/flameon.wav");
	precache_sound("dread/flameoff.wav");
	precache_sound("misc/burning.wav");
	precache_sound("misc/burning2.wav");

	this.dmg = zeroconvertdefault(this.dmg, 2);

	if(!this.speed)
		this.speed = 1;

	SetMovedir(this);

	if(!this.wait)
		this.wait = 0.1;
					
	if(!(this.spawnflags & START_OFF))
		this.state = FLAME_ST_STARTING;
	
	this.nextthink = time + 0.2;
	setthink(this, misc_flame_startup);
}



/*
===============================================================================
misc_splash
===============================================================================
*/

void splash_think(entity this)
{
	float variance = this.cnt;
	vector vec;
	vec.x = this.movedir_x - variance + random() * variance * 2;
	vec.y = this.movedir_y - variance + random() * variance * 2;
	vec.z = this.movedir_z - variance + random() * variance * 2;
	particle(this.origin, vec, this.count, this.volume);
	this.nextthink = time + this.wait;
}

/*QUAKED misc_splash (0 .5 .8) (-8 -8 -8) (8 8 8)
Produces a continuous particle splash for waterfalls

"color" color of particles.  0 through 15, corresponds to a row of the quake palette. (default 0)

"movedir" average movement vector of particles (default 0 0 4)

"wait" time between particle generation cycles.  (default 0.1)

"volume" density of particles. (default 10)
*/
spawnfunc(misc_splash)
{
	if(!this.wait)
		this.wait = 0.1;
	if(!this.movedir)
		this.movedir = '0 0 4';
	if(!this.volume)
		this.volume = 10;

	// TODO: color field is defined as a vector in Xonotic so we need this hack
	this.count = stof(GetField_fullspawndata(this, "color", false));
	
	this.count *= 16;

	// cached to avoid vlen calls every frame
	this.cnt = vlen(this.movedir) / 2;

	this.nextthink = time + this.wait;
	setthink(this, splash_think);
}
