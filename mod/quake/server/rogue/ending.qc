// ending.qc
//    code to handle big ending of Xpack.
// ------------------------------------------------

const int anim_actor_axrun1 = 0;
const int anim_actor_axrun2 = 1;
const int anim_actor_axrun3 = 2;
const int anim_actor_axrun4 = 3;
const int anim_actor_axrun5 = 4;
const int anim_actor_axrun6 = 5;

const int anim_actor_rockrun1 = 6;
const int anim_actor_rockrun2 = 7;
const int anim_actor_rockrun3 = 8;
const int anim_actor_rockrun4 = 9;
const int anim_actor_rockrun5 = 10;
const int anim_actor_rockrun6 = 11;

const int anim_actor_stand1 = 12;
const int anim_actor_stand2 = 13;
const int anim_actor_stand3 = 14;
const int anim_actor_stand4 = 15;
const int anim_actor_stand5 = 16;

const int anim_actor_axstnd1 = 17;
const int anim_actor_axstnd2 = 18;
const int anim_actor_axstnd3 = 19;
const int anim_actor_axstnd4 = 20;
const int anim_actor_axstnd5 = 21;
const int anim_actor_axstnd6 = 22;
const int anim_actor_axstnd7 = 23;
const int anim_actor_axstnd8 = 24;
const int anim_actor_axstnd9 = 25;
const int anim_actor_axstnd10 = 26;
const int anim_actor_axstnd11 = 27;
const int anim_actor_axstnd12 = 28;

const int anim_actor_axpain1 = 29;
const int anim_actor_axpain2 = 30;
const int anim_actor_axpain3 = 31;
const int anim_actor_axpain4 = 32;
const int anim_actor_axpain5 = 33;
const int anim_actor_axpain6 = 34;

const int anim_actor_pain1 = 35;
const int anim_actor_pain2 = 36;
const int anim_actor_pain3 = 37;
const int anim_actor_pain4 = 38;
const int anim_actor_pain5 = 39;
const int anim_actor_pain6 = 40;

const int anim_actor_axdeth1 = 41;
const int anim_actor_axdeth2 = 42;
const int anim_actor_axdeth3 = 43;
const int anim_actor_axdeth4 = 44;
const int anim_actor_axdeth5 = 45;
const int anim_actor_axdeth6 = 46;
const int anim_actor_axdeth7 = 47;
const int anim_actor_axdeth8 = 48;
const int anim_actor_axdeth9 = 49;

const int anim_actor_deatha1 = 50;
const int anim_actor_deatha2 = 51;
const int anim_actor_deatha3 = 52;
const int anim_actor_deatha4 = 53;
const int anim_actor_deatha5 = 54;
const int anim_actor_deatha6 = 55;
const int anim_actor_deatha7 = 56;
const int anim_actor_deatha8 = 57;
const int anim_actor_deatha9 = 58;
const int anim_actor_deatha10 = 59;
const int anim_actor_deatha11 = 60;

const int anim_actor_deathb1 = 61;
const int anim_actor_deathb2 = 62;
const int anim_actor_deathb3 = 63;
const int anim_actor_deathb4 = 64;
const int anim_actor_deathb5 = 65;
const int anim_actor_deathb6 = 66;
const int anim_actor_deathb7 = 67;
const int anim_actor_deathb8 = 68;
const int anim_actor_deathb9 = 69;

const int anim_actor_deathc1 = 70;
const int anim_actor_deathc2 = 71;
const int anim_actor_deathc3 = 72;
const int anim_actor_deathc4 = 73;
const int anim_actor_deathc5 = 74;
const int anim_actor_deathc6 = 75;
const int anim_actor_deathc7 = 76;
const int anim_actor_deathc8 = 77;
const int anim_actor_deathc9 = 78;
const int anim_actor_deathc10 = 79;
const int anim_actor_deathc11 = 80;
const int anim_actor_deathc12 = 81;
const int anim_actor_deathc13 = 82;
const int anim_actor_deathc14 = 83;
const int anim_actor_deathc15 = 84;

const int anim_actor_deathd1 = 85;
const int anim_actor_deathd2 = 86;
const int anim_actor_deathd3 = 87;
const int anim_actor_deathd4 = 88;
const int anim_actor_deathd5 = 89;
const int anim_actor_deathd6 = 90;
const int anim_actor_deathd7 = 91;
const int anim_actor_deathd8 = 92;
const int anim_actor_deathd9 = 93;

const int anim_actor_deathe1 = 94;
const int anim_actor_deathe2 = 95;
const int anim_actor_deathe3 = 96;
const int anim_actor_deathe4 = 97;
const int anim_actor_deathe5 = 98;
const int anim_actor_deathe6 = 99;
const int anim_actor_deathe7 = 100;
const int anim_actor_deathe8 = 101;
const int anim_actor_deathe9 = 102;

const int anim_actor_nailatt1 = 103;
const int anim_actor_nailatt2 = 104;

const int anim_actor_light1 = 105;
const int anim_actor_light2 = 106;

const int anim_actor_rockatt1 = 107;
const int anim_actor_rockatt2 = 108;
const int anim_actor_rockatt3 = 109;
const int anim_actor_rockatt4 = 110;
const int anim_actor_rockatt5 = 111;
const int anim_actor_rockatt6 = 112;

const int anim_actor_shotatt1 = 113;
const int anim_actor_shotatt2 = 114;
const int anim_actor_shotatt3 = 115;
const int anim_actor_shotatt4 = 116;
const int anim_actor_shotatt5 = 117;
const int anim_actor_shotatt6 = 118;

const int anim_actor_axatt1 = 119;
const int anim_actor_axatt2 = 120;
const int anim_actor_axatt3 = 121;
const int anim_actor_axatt4 = 122;
const int anim_actor_axatt5 = 123;
const int anim_actor_axatt6 = 124;

const int anim_actor_axattb1 = 125;
const int anim_actor_axattb2 = 126;
const int anim_actor_axattb3 = 127;
const int anim_actor_axattb4 = 128;
const int anim_actor_axattb5 = 129;
const int anim_actor_axattb6 = 130;

const int anim_actor_axattc1 = 131;
const int anim_actor_axattc2 = 132;
const int anim_actor_axattc3 = 133;
const int anim_actor_axattc4 = 134;
const int anim_actor_axattc5 = 135;
const int anim_actor_axattc6 = 136;

const int anim_actor_axattd1 = 137;
const int anim_actor_axattd2 = 138;
const int anim_actor_axattd3 = 139;
const int anim_actor_axattd4 = 140;
const int anim_actor_axattd5 = 141;
const int anim_actor_axattd6 = 142;

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

void time_crash_die(entity this, entity inflictor, entity attacker);
void time_crash_pain(entity this, entity attacker, float damage);

void actor_fire21(entity this) { set_anim(this, anim_actor_stand5, actor_control); this.nextthink = time + 0.15; actorStage = STAGE_TO_POINT2; }
void actor_fire20(entity this) { set_anim(this, anim_actor_stand4, actor_fire21); this.nextthink = time + 0.15; }
void actor_fire19(entity this) { set_anim(this, anim_actor_stand3, actor_fire20); this.nextthink = time + 0.15; }
void actor_fire18(entity this) { set_anim(this, anim_actor_stand2, actor_fire19); this.nextthink = time + 0.15; }
void actor_fire17(entity this) { set_anim(this, anim_actor_stand1, actor_fire18); this.nextthink = time + 0.15; }
void actor_fire16(entity this) { set_anim(this, anim_actor_stand5, actor_fire17); this.nextthink = time + 0.15; }
void actor_fire15(entity this) { set_anim(this, anim_actor_stand4, actor_fire16); this.nextthink = time + 0.15; }
void actor_fire14(entity this) { set_anim(this, anim_actor_stand3, actor_fire15); this.nextthink = time + 0.15; }
void actor_fire13(entity this) { set_anim(this, anim_actor_stand2, actor_fire14); this.nextthink = time + 0.15; }
void actor_fire12(entity this) { set_anim(this, anim_actor_stand1, actor_fire13); this.nextthink = time + 0.15; }
void actor_fire11(entity this) { set_anim(this, anim_actor_stand5, actor_fire12); this.nextthink = time + 0.15; }
void actor_fire10(entity this) { set_anim(this, anim_actor_stand4, actor_fire11); this.nextthink = time + 0.15; }
void actor_fire9(entity this) { set_anim(this, anim_actor_stand3, actor_fire10); this.nextthink = time + 0.15; }
void actor_fire8(entity this) { set_anim(this, anim_actor_stand2, actor_fire9); this.nextthink = time + 0.15; }
void actor_fire7(entity this) { set_anim(this, anim_actor_stand1, actor_fire8); this.nextthink = time + 0.15; }
void actor_fire6(entity this) { set_anim(this, anim_actor_rockatt6, actor_fire7); this.effects=0; this.nextthink = time + 0.15; }
void actor_fire5(entity this)
{
	set_anim(this, anim_actor_rockatt5, actor_fire6);

	this.nextthink = time + 0.15;
	ending_remove_stuff();
	if(theMachine.health > 0)
	{
		setthink(theMachine, time_crash);
		theMachine.nextthink = time + 0.1;
	}
}
void actor_fire4(entity this) { set_anim(this, anim_actor_rockatt4, actor_fire5); this.nextthink = time + 0.15; }
void actor_fire3(entity this) { set_anim(this, anim_actor_rockatt3, actor_fire4); this.nextthink = time + 0.15; }
void actor_fire2(entity this) { set_anim(this, anim_actor_rockatt2, actor_fire3); this.v_angle_x = 0; this.angles_x = 0; this.nextthink = time + 0.15; }
void actor_fire1(entity this)
{
	set_anim(this, anim_actor_rockatt1, actor_fire2);

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
		this.frame = anim_actor_stand1;
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
