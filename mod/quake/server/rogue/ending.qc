// ending.qc
//    code to handle big ending of Xpack.
// ------------------------------------------------

// copied from player animations
const int anim_actor_stand = 12;
const int anim_actor_rockatt = 107;

entity theActor;
entity theMachine;

int actorStage;

const int STAGE_START = 0;
const int STAGE_TO_POINT1 = 1;
const int STAGE_AT_POINT1 = 2;
const int STAGE_TO_POINT2 = 3;
const int STAGE_AT_POINT2 = 4;
const int STAGE_FIRING = 5;

void spawn_actor(entity this);
void actor_control(entity this);
void move_camera(entity this);
void time_crash(entity this);
void ending_remove_stuff();

void ending_for_coop(entity this)
{
	intermission_exittime = time + 10000000;	// never allow exit
	intermission_running = 1;

	this.model = "";
	this.yaw_speed = 20;
	this.view_ofs = '0 0 0';
	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	setorigin(this, this.origin + '0 0 48');
	
	WriteByte(MSG_ALL, SVC_FINALE);
	WriteString(MSG_ALL, "You have destroyed Quake's\nTemporal Teleporter. His assault\non Time has been defeated.");

	server_reset();
	
	ending_remove_stuff();

	setthink(theMachine, time_crash);
	theMachine.nextthink = time + 0.1;
}

// ------------------------------------------------
// Camera and control functions
// ------------------------------------------------

void xpackEnding(entity this)
{
	server_reset();

	if(coop)
	{
		ending_for_coop(this);
		return;
	}
	
	intermission_exittime = time + 10000000;	// never allow exit
	intermission_running = 1;

	WriteByte(MSG_ALL, SVC_CUTSCENE);
	WriteString(MSG_ALL, "");

	entity cameraview = find(NULL, targetname, "cameraview");
	if(cameraview == NULL)
	{
		ending_for_coop(this);
		return;
	}
	
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	spawn_actor(this);
	move_camera(this);
}

void track_camera(entity this)
{
	vector cameraAngle = theActor.origin - this.origin;
	cameraAngle_z = 0 - cameraAngle_z;
	this.angles = vectoangles(cameraAngle);
	this.v_angle = this.angles;

	setthink(this, track_camera);
	this.nextthink = time + 0.1;
}

void move_camera(entity this)
{
	entity cameraPoint = find(NULL, targetname, "cameraview");
	if(cameraPoint == NULL)
		objerror(this, "Could not find camerapoint!");
	
	this.model = "";
	this.yaw_speed = 20;
	this.view_ofs = '0 0 0';
	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	setorigin(this, cameraPoint.origin);

	vector cameraAngle = theActor.origin - this.origin;
	this.angles = vectoangles(cameraAngle);
	this.v_angle = this.angles;
	
	setthink(this, track_camera);
	this.nextthink = time + 0.05;
}

void ending_remove_stuff()
{
	FOREACH_ENTITY_CLASS("ltrail_start", true,
	{
		delete(it);
	});
	
	entity curEnt = find(NULL, classname, "item_time_core");
	if(curEnt)
	{
	    te_explosion2(curEnt.origin, 230, 5);
		
		setthink(curEnt, SUB_Remove);
		curEnt.nextthink = time + 0.1;
	}
}

// ------------------------------------------------
// actor code
// ------------------------------------------------
void actor_run(entity this)
{
	if(pointcontents(this.origin) == CONTENT_LAVA)
	{
		entity pointOne = find(NULL, targetname, "point1");
		if(pointOne != NULL)
			setorigin(this, pointOne.origin);
	}
	
	if(this.goalentity.targetname == "endpoint1")
	{
		actorStage = STAGE_AT_POINT1;
		setthink(this, actor_control);
		this.nextthink = time + 0.1;
		return;
	}	
	if(this.goalentity.targetname == "endpoint2")
	{
		actorStage = STAGE_AT_POINT2;
		setthink(this, actor_control);
		this.nextthink = time + 0.1;
		return;
	}	
	
	this.frame = this.frame + 1;
	if(this.frame > 11)
		this.frame = 6;
	
	//vector dist = this.goalentity.origin - this.origin;
//	this.ideal_yaw = vectoyaw(dist);
//	ChangeYaw();
		
	movetogoal(this, 15);
	setthink(this, actor_run);
	this.nextthink = time + 0.1;
}

void time_crash_die(entity this, entity inflictor, entity attacker, int deathtype);
void time_crash_pain(entity this, entity attacker, float damage, int deathtype);

void actor_fire21(entity this) { set_animofs(this, anim_actor_stand, 5, actor_control); this.nextthink = time + 0.15; actorStage = STAGE_TO_POINT2; }
void actor_fire20(entity this) { set_animofs(this, anim_actor_stand, 4, actor_fire21); this.nextthink = time + 0.15; }
void actor_fire19(entity this) { set_animofs(this, anim_actor_stand, 3, actor_fire20); this.nextthink = time + 0.15; }
void actor_fire18(entity this) { set_animofs(this, anim_actor_stand, 2, actor_fire19); this.nextthink = time + 0.15; }
void actor_fire17(entity this) { set_animofs(this, anim_actor_stand, 1, actor_fire18); this.nextthink = time + 0.15; }
void actor_fire16(entity this) { set_animofs(this, anim_actor_stand, 5, actor_fire17); this.nextthink = time + 0.15; }
void actor_fire15(entity this) { set_animofs(this, anim_actor_stand, 4, actor_fire16); this.nextthink = time + 0.15; }
void actor_fire14(entity this) { set_animofs(this, anim_actor_stand, 3, actor_fire15); this.nextthink = time + 0.15; }
void actor_fire13(entity this) { set_animofs(this, anim_actor_stand, 2, actor_fire14); this.nextthink = time + 0.15; }
void actor_fire12(entity this) { set_animofs(this, anim_actor_stand, 1, actor_fire13); this.nextthink = time + 0.15; }
void actor_fire11(entity this) { set_animofs(this, anim_actor_stand, 5, actor_fire12); this.nextthink = time + 0.15; }
void actor_fire10(entity this) { set_animofs(this, anim_actor_stand, 4, actor_fire11); this.nextthink = time + 0.15; }
void actor_fire9(entity this) { set_animofs(this, anim_actor_stand, 3, actor_fire10); this.nextthink = time + 0.15; }
void actor_fire8(entity this) { set_animofs(this, anim_actor_stand, 2, actor_fire9); this.nextthink = time + 0.15; }
void actor_fire7(entity this) { set_animofs(this, anim_actor_stand, 1, actor_fire8); this.nextthink = time + 0.15; }
void actor_fire6(entity this) { set_animofs(this, anim_actor_rockatt, 6, actor_fire7); this.effects=0; this.nextthink = time + 0.15; }
void actor_fire5(entity this)
{
	set_animofs(this, anim_actor_rockatt, 5, actor_fire6);

	this.nextthink = time + 0.15;
	ending_remove_stuff();
	if(theMachine.health > 0)
	{
		setthink(theMachine, time_crash);
		theMachine.nextthink = time + 0.1;
	}
}
entity W_FireRocket(entity this);
void actor_fire4(entity this) { set_animofs(this, anim_actor_rockatt, 4, actor_fire5); this.nextthink = time + 0.15; }
void actor_fire3(entity this) { set_animofs(this, anim_actor_rockatt, 3, actor_fire4); this.nextthink = time + 0.15; }
void actor_fire2(entity this) { set_animofs(this, anim_actor_rockatt, 2, actor_fire3); this.v_angle_x = 0; this.angles_x = 0; this.nextthink = time + 0.15; }
void actor_fire1(entity this)
{
	set_animofs(this, anim_actor_rockatt, 1, actor_fire2);

	this.goalentity = theMachine;
	theMachine.th_pain = time_crash_pain;
	theMachine.th_die = time_crash_die;
	theMachine.health = 1;
		
	this.angles = vectoangles(this.goalentity.origin - this.origin);
	this.v_angle = this.angles;
	this.v_angle_x = 0 - this.angles_x;
	this.effects = EF_MUZZLEFLASH; 
	W_FireRocket(this);
	
	// start the end text
	WriteByte(MSG_ALL, SVC_FINALE);

	WriteString(MSG_ALL, "\nFinally, Quake's Temporal Teleporter\nyields to your assault. A high\npitched scream emits from the\ndevastated device as stressed steel\nblasts outward to rock the cavern.\nThe machine is devoured by molten lava.\n\nThe ground shudders as reality shifts\nback to its predestined path.\n\nYou run to enter the charged time pod,\nscrambling in as the chamber closes.\nYour consciousness fades as you realize\nyou have halted Quake's plans for...\n\nThe Dissolution of Eternity.");
}

void actor_teleport(entity this)
{
	spawn_tfog(this.origin);
	this.model = string_null;
	setthink(this, func_null);
	this.nextthink = 0;
}

void actor_control(entity this)
{
	if(actorStage == STAGE_START)
	{
		this.target = "point1";
		this.movetarget = find(NULL, targetname, this.target);
		this.goalentity = this.movetarget;
		if(this.goalentity == NULL)
			objerror(this, "End Sequence point1 placing screwed up!");
		this.frame = 6;
		setthink(this, actor_run);
		this.nextthink = time + 0.1;
		actorStage = STAGE_TO_POINT1;
	}
	else if(actorStage == STAGE_AT_POINT1)
	{
		this.target = "machine";
		this.movetarget = find(NULL, targetname, this.target);
		this.goalentity = this.movetarget;
		if(this.goalentity == NULL)
			objerror(this, "End Sequence machine placing screwed up!");
		actorStage = STAGE_FIRING;
		setthink(this, actor_fire1);
		this.nextthink = time + 0.1;
	}
	else if(actorStage == STAGE_AT_POINT2)
	{
		this.frame = anim_actor_stand;
		setthink(this, actor_teleport);
		this.nextthink = time + 2; 
	}
	else if(actorStage == STAGE_TO_POINT2)
	{
		this.target = "timepod";
		SUB_UseTargets(this, NULL, NULL);
		
		this.target = "point2";
		this.movetarget = find(NULL, targetname, this.target);
		this.goalentity = this.movetarget;
		if(this.goalentity == NULL)
			objerror(this, "End Sequence point2 placing screwed up!");
		this.frame = 6;
		setthink(this, actor_run);
		this.nextthink = time + 0.1;
	}
}

// ==============
// player actor spawn function
// ==============
void spawn_actor(entity this)
{
	theActor = new(actor);
	theActor.owner = this;
	theActor.health = 100;
	theActor.solid = SOLID_SLIDEBOX;
	set_movetype(theActor, MOVETYPE_STEP);
	theActor.frame = this.frame;
	_setmodel(theActor, get_playermodel(this));
	setorigin(theActor, this.origin);
	setsize(theActor, VEC_HULL_MIN, VEC_HULL_MAX);
	theActor.view_ofs = '0 0 22';
	theActor.angles = this.angles;
	theActor.ideal_yaw = theActor.angles * '0 1 0';
	if(!theActor.yaw_speed)
		theActor.yaw_speed = 20;
	theActor.view_ofs = '0 0 25';
	//theActor.flags |= FL_MONSTER; // seriously, why
	actorStage = STAGE_START;
		
	if(pointcontents(theActor.origin) == CONTENT_LAVA)
	{
		entity pointOne = find(NULL, targetname, "point1");
		if(pointOne != NULL)
			setorigin(theActor, pointOne.origin);
	}

	setthink(theActor, actor_control);
	theActor.nextthink = time + 0.1;
}
