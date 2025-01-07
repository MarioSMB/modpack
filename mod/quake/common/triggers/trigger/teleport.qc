#ifdef SVQC

const int TELEPORT_PLAYER_ONLY = 1;
const int TELEPORT_SILENT = 2;
const int TELEPORT_PUSH = 2;
const int TELEPORT_TRIGGER_FIRST = 4;
const int TELEPORT_NOTRIGGER = 8;
const int TELEPORT_NOFLASH = 16;
const int TELEPORT_MONSTER_ONLY = 32;

void teleport(entity traveler, entity dst, bool tfog, bool nofwd);
void teleport_touch(entity this, entity toucher)
{
	if(this.customflags & CFL_LOCKED)
		return;

	bool ignore_targetname = ((this.spawnflags & IGNORE_TARGETNAME) && IsMGMap());
	if(this.targetname && this.targetname != "" && !ignore_targetname && !(this.spawnflags & TELEPORT_TRIGGER_FIRST) && !(this.spawnflags & TELEPORT_NOTRIGGER))
	{
		if(this.attack_finished < time)
			return; // not fired yet
	}

	if((this.spawnflags & TELEPORT_PLAYER_ONLY) && !IS_PLAYER(toucher))
		return;
	if((this.spawnflags & TELEPORT_MONSTER_ONLY) && !IS_MONSTER(toucher))
		return;

// only teleport living creatures
	if(toucher.health <= 0 || (toucher.solid != SOLID_SLIDEBOX && !STAT(SLIDE_ON, toucher)))
		return;

	entity targ = findunlockedtarget(this, NULL);
	if(!targ)
	{
		objerror(this, "trigger_teleport: couldn't find target");
		return;
	}

	playercount_convert(this, count);
	if(this.count == 0)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		settouch(this, func_null);
		return;
	}
	else if(this.count > 0)
		this.count -= 1;

	teleport(toucher, targ, !(this.spawnflags & TELEPORT_NOFLASH), false);

	if(targ.classname == "misc_teleporttrain")
		return;

	SUB_UseTargets(this, toucher, NULL);
}

/*QUAKED info_teleport_destination(.5 .5 .5)(-8 -8 -8)(8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
spawnfunc(info_teleport_destination)
{
// this does nothing, just serves as a target spot
	this.mangle = this.angles;
	this.angles = '0 0 0';
	this.model = "";
	this.origin = this.origin + '0 0 27';
	if(!this.targetname || this.targetname == "")
		objerror(this, "no targetname");
}

void teleport_use(entity this, entity actor, entity trigger)
{
	this.attack_finished = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
}

void teleport_hum(entity this)
{
	vector o;
	if(this.origin != '0 0 0')
		o = this.origin;
	else
		o = (this.absmin + this.absmax) * 0.5;
	ambientsound(o, "ambience/hum1.wav", 0.5, ATTN_STATIC);
}

void teleport_reactivate(entity this, entity actor, entity trigger)
{
	trigger_reactivate(this, actor, trigger);
	// triggerfirst + nonsilent = delayed ambientsound, so shortcut teleporters don't sound like secrets
	if((this.spawnflags & TELEPORT_TRIGGER_FIRST) && !(this.spawnflags & TELEPORT_SILENT))
		teleport_hum(this);
	
	this.use = teleport_use;
}

void trigger_teleport_delayedsetup(entity this)
{
	// workaround for Ritual and some mappers setting "infinite" nextthink to make a targeted teleporter still touched
	// TODO: generic support for this, currently nextthink is set to 0 way too early for us to catch it
	if(this.targetname && this.targetname != "" && world.model == "maps/ze1end.bsp")
	{
		entity killer = find(NULL, killtarget, this.targetname);
		if(killer)
			this.spawnflags |= IGNORE_TARGETNAME;
	}
}

void trigger_teleport_setup(entity this)
{
	settouch(this, teleport_touch);
	// find the destination 
	if(!this.target || this.target == "")
	{
		objerror(this, "trigger_teleport: no target");
		return;
	}
	this.use = teleport_use;
	this.count = zeroconvertdefault(this.count, -1);
	if(!(this.spawnflags & TELEPORT_SILENT))
	{
		precache_sound("ambience/hum1.wav");
		if (!(this.spawnflags & TELEPORT_TRIGGER_FIRST))
			teleport_hum(this);
	}

	setthink(this, trigger_teleport_delayedsetup);
	this.nextthink = time + 0.1;
}

/*QUAKED trigger_teleport(.5 .5 .5) ? PLAYER_ONLY SILENT CTF_ONLY
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
spawnfunc(trigger_teleport)
{
	InitTrigger(this);
	trigger_teleport_setup(this);	// after inittrigger, so that size/model is set, so the telehum hums in the right place
	if(this.spawnflags & TELEPORT_TRIGGER_FIRST)
		this.use = teleport_reactivate;
}

void effect_teleport_use(entity this, entity actor, entity trigger)
{
	te_teleport(this.origin);

	sound(this, CH_VOICE, SND_TELE1, 1, ATTN_NORM);
}

/*QUAKED effect_teleport (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
 Create a teleport effect when triggered
*/

spawnfunc(effect_teleport)
{
	this.use = effect_teleport_use;
}

// --------------------------------
// info_teleport_target
//
// this entity is handy when activating a big trigger_teleport volume
// to try and teleport something is inconvenient
// --------------------------------

void teleport(entity traveler, entity dst, bool tfog, bool nofwd)
{
	vector vdir = '0 0 0';
	float flash = 3;	// 1 = @org, 2 = @dest, 3 = both
	
	if(dst.classname == "misc_teleporttrain")
	{
		// monsters get pooped out of a teleport train facing their enemy
		if(IS_MONSTER(traveler) && traveler.enemy)
		{
			vdir = vectoangles(traveler.enemy.origin - dst.origin);
		}
		// if the teleball isn't moving, emerge facing the direction you traveled to help orientation
		else if(dst.buddy && dst.buddy.velocity == '0 0 0')
		{
			vdir = vectoangles(dst.origin - traveler.origin);
			nofwd = true;
		}
		// if the teleball is moving, face the direction the teleball is moving
		else 
		{
			vdir = vectoangles(dst.velocity);
		}
		vdir_x = 0;	// null pitch
	}
	else
		vdir = dst.mangle;

	if(tfog)
	{
		if(flash & 1)
			spawn_tfog(traveler.origin); // flash at departure point
		
		if(flash & 2)
		{
			vector torg = dst.origin;
			
			// teleport controller's origin is desired teleport flash location on arrival
			if(IS_PLAYER(traveler))
			{
				makevectors(vdir);
				torg = dst.origin + v_forward * 16;
			}

			spawn_tfog(torg);
		}
	}
	
	spawn_tdeath(dst.origin, traveler);

	setorigin(traveler, dst.origin);
	traveler.angles = vdir;
	if(IS_MONSTER(traveler))
		traveler.ideal_yaw = traveler.angles_y;

	if(IS_PLAYER(traveler))
	{
		//fog_setFromEnt(traveler, dst);
		traveler.fixangle = 1;		// turn this way immediately
		makevectors(vdir);
		if(dst.classname == "info_teleport_destination" ||
			dst.classname == "info_teleport_target" ||
			dst.classname == "misc_teleporttrain" ||
			dst.classname == "info_notnull")
		{
			SUB_UseTargets(dst, traveler, NULL);
		}
		if(nofwd)
		{
			traveler.velocity = '0 0 0';
			traveler.oldvelocity = traveler.velocity;
		}
		else
		{
			traveler.teleport_time = time + 0.7;
			traveler.velocity = v_forward * 300;
			traveler.oldvelocity = traveler.velocity;
		}
	}
	else
	{
		traveler.velocity = '0 0 0';
		traveler.oldvelocity = traveler.velocity;
	}

	UNSET_ONGROUND(traveler);

	BITXOR_ASSIGN(traveler.effects, EF_TELEPORT_BIT);
}

bool teleport_target_check(entity this, entity e);
bool teleport_target_acton(entity this, .string fld)
{
	if(!this.(fld) || this.(fld) == "")
		return false;

	float did = false;
	entity t = find(NULL, targetname, this.(fld));
	while (t)
	{
		if(teleport_target_check(this, t))
		{
			teleport(t, this, !(this.spawnflags & TELEPORT_NOFLASH), !(this.spawnflags & TELEPORT_PUSH));
			t.jump_flag = 0;
			did = true;
		}
		t = find(t, targetname, this.fld);
	}
	return did;
}

bool teleport_target_check(entity this, entity e)
{
	if(this.spawnflags & TELEPORT_PLAYER_ONLY)
		if(!IS_PLAYER(e))
			return false;
	if(this.spawnflags & TELEPORT_MONSTER_ONLY)
		if(!IS_MONSTER(e))
			return false;
	if(e.movetype == MOVETYPE_NOCLIP)
		return false;
	// only teleport living creatures
	if(e.health <= 0 || (e.solid != SOLID_SLIDEBOX && !STAT(SLIDE_ON, e))) // TODO: not a great way to check for "living"
		return false;
	return true;
}

// teleports the activator to this spot
void teleport_target_use(entity this, entity actor, entity trigger)
{
	if(this.customflags & CFL_LOCKED)
		return;
	
	// trigger first
	if(this.spawnflags & 4)
	{
		this.spawnflags &= ~4;
		return;
	}
	
	playercount_convert(this, count);
	if(!this.count) 
	{
		this.use = func_null;
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}
	
	if(this.spawnflags & 8)
	{
		if(teleport_target_acton(this, target) ||
			teleport_target_acton(this, target2) ||
			teleport_target_acton(this, target3) ||
			teleport_target_acton(this, target4))	
		{
			if(this.count > 0)
				this.count -= 1;
		}
	}
	else
	{
		if(!teleport_target_check(this, actor))
			return;

		if(this.count > 0)
			this.count -= 1;

		teleport(actor, this, !(this.spawnflags & TELEPORT_NOFLASH), !(this.spawnflags & TELEPORT_PUSH));
		actor.jump_flag = 0;
	}
}

/*QUAKED info_teleport_target (.5 .75 .25) (-16 -16 -8) (16 16 40) PLAYER_ONLY PUSH TRIGGER_FIRST ACT_ON_TARGETS NOFLASH MONSTER_ONLY
This is a usable destination marker that acts as its own teleporter.  When triggered, the activator is teleported to this spot.

Flags:
PLAYER_ONLY		only players will teleport
PUSH			chuck the player forward like a trigger_teleport does
TRIGGER_FIRST	first use turns it on, and every subsequent use teleports
ACT_ON_TARGETS	teleport its targets intead of firing them and ignore the activator
NOFLASH			don't spawn telefog or make noise
MONSTER_ONLY	only monsters will teleport

Keys:
"fog_color"/"fog_density" set the fog for anyone teleporting here
"count"		remove after this many uses
*/
/*FGD
@PointClass size(-16 -16 -8, 16 16 40) base(Appearflags, Angle, Fog, Trigger) = info_teleport_target : "Triggerable Teleporter destination
This is a usable destination marker that acts as its own teleporter.  When triggered, the activator is teleported to this spot.

If 'Act On Targets' is set, teleports its targets intead of firing them and ignores the activator.

If 'Player only' or 'Monsters only' is checked, this can only be activated by players or monsters respectively.
Set 'Push forward' if you want the teleport-exit forward velocity effect, or 'No teleflash' to plop an entity here silently.

PLAYER_ONLY		only players will teleport
PUSH			chuck the player forward like a trigger_teleport does
TRIGGER_FIRST	first use turns it on, and every subsequent use teleports
NOFLASH			don't spawn telefog or make noise
MONSTER_ONLY	only monsters will teleport" 
[
	spawnflags(flags) = [
		1 : "Player only" : 0
		2 : "Push forward" : 0
		8 : "Act On Targets" : 0
		16 : "No teleflash" : 0
		32 : "Monsters only" : 0
	]
	count(integer) : "Remove after this many uses"
]
*/
spawnfunc(info_teleport_target)
{
	if((!this.targetname || this.targetname == "") && !this.impulse)
	{
		objerror(this, "info_teleport_target: no targetname");
		return;
	}
		
	if((this.spawnflags & 8) && 
		((!this.target || this.target == "") && (!this.target2 || this.target2 == "") && 
		(!this.target3 || this.target3 == "") && (!this.target4 || this.target4 == "")))
	{
		objerror(this, "act_on_targets with no target set");
		return;
	}	
	this.mangle = this.angles;
	this.angles = '0 0 0';
	setorigin(this, this.origin + '0 0 16'); // ???
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	if(!this.count)
		this.count = -1;
	this.use = teleport_target_use;
	//fog_fixKeys(this); // TODO? not sure if we want all the weird fog changing stuff!
}

/*QUAKED trigger_teleport_box (.5 .0 .5) (-8 -8 -8) (8 8 8) PLAYER_ONLY SILENT TRIGGER_FIRST NOTRIGGER
Any object touching this will be transported to the corresponding info_teleport_destination entity.
You must set the "target" field, and create an object with a "targetname" field that matches.
Quoth2-style edict-saving bounding box trigger: define bounds size with 'size' - trigger volume will be centered on the trigger's origin.

Flags:
"player_only" only players will teleport
"silent" no whispering from the slipgate
"trigger_first" won't be touchable until triggered once by something else
"notrigger" default behavior for a teleporter with a targetname is to only teleport what's touching it
	when triggered.  this will preserve ordinary no-targetname behavior (if you're using the teleporter's
	targetname for a killtarget for example)
"noflash" don't spawn tfog or make noise

Keys:
"target" targetname of info_teleport_destination (required)
"targetname" entity name (required)
*/
/*FGD
@PointClass base(Trigger, Teleport, Bounds) = trigger_teleport_box : "Trigger: Teleporter.
Any object touching this will be transported to the corresponding info_teleport_destination entity.

Quoth2-style edict-saving bounding box trigger: define bounds size with 'size' - trigger volume will be centered on the trigger's origin.

The 'Not Triggerable' spawnflag: default behavior for a teleporter with a targetname is to only teleport what's touching it when triggered. this will preserve ordinary no-targetname behavior (if you're using the teleporter's targetname for a killtarget for example)." []
*/
spawnfunc(trigger_teleport_box)
{
	InitTriggerBounds(this);
	trigger_teleport_setup(this);
	if(this.spawnflags & TELEPORT_TRIGGER_FIRST)
		this.use = teleport_reactivate;
}

#endif
