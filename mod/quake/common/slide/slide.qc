#include "slide.qh"

void Slide_Jump(entity this)
{
	traceline(this.origin, this.origin - '0 0 52', true, this);

	if(trace_fraction >= 1)
		return;

	if(IS_JUMP_HELD(this))
		return;

	SET_JUMP_HELD(this);

#ifdef SVQC
//   sound (this, CHAN_BODY, "doors/airdoor2.wav", 1, ATTN_NORM);
	if(this.cvar_cl_quake_model == "goat" && !CHAMPION_Goat.m_condition(CHAMPION_Goat, this))
		_sound(this, CHAN_BODY, CHAMPION_Goat.m_sound_death(), 1, 0.25);
	else
		_sound(this, CHAN_BODY, "bjump1.wav", 1, ATTN_NORM);
#endif

	SET_ONGROUND(this);

	this.velocity += '0 0 300';
}

float slide_anglemod(float v)
{
	while(v >= 360)
		v -= 360;
	while(v < 0)
		v += 360;
	return v;
}

//The "turning" routine for when you're on your hoverboard
void Slide_Turn(entity this)
{
	if(this.velocity == '0 0 0')
		return;

	vector facing = PHYS_WORLD_ANGLES(this);
	vector moving = vectoangles(this.velocity);

//Beginning of the actual routine to "average" two angles.
//THIS particular code finds finds the "inbetween" angle right of
// facing.y and moving.y. Angle math of two floating points I guess.

	moving.y = slide_anglemod(moving.y);
	facing.y = slide_anglemod(facing.y);

#ifdef SVQC
	float tempf = fabs(moving.y - facing.y);
#endif

	if(fabs(moving.y - facing.y) > 180)
	{
		if(moving.y > 180) moving.y = moving.y - 360;
		if(facing.y > 180) facing.y = facing.y - 360;
	}
	moving.y = (moving.y + facing.y) * 0.5;

	moving.y = slide_anglemod(moving.y);

//The angle moving.y is now halfway from what it was to where facing.y is;

	makevectors(moving);

	v_forward.z = -v_forward.z;

	this.velocity = v_forward * vlen(this.velocity);

//turning sound.
	if(!(this.flags & FL_ONGROUND2))
		return;

#ifdef SVQC
	tempf = fabs(tempf);
	if(tempf > 10)
	{
		if((tempf - 9) > 254)
			tempf = 254;

		particle(this.origin-'0 0 30', '0 0 0', 40, tempf - 9);

		tempf = 0.02 * tempf;
		if(tempf > 1)
			tempf = 1;

		_sound(this, CHAN_VOICE, "board4.wav", tempf, ATTN_NORM);
	}
#endif
}

//For landing sounds and perhaps bouncing basically. :)
void CheckSlideGround(entity this)
{
	traceline(this.origin, this.origin - '0 0 45', true, this);

	if(trace_fraction >= 1 && this.flags&FL_ONGROUND2)
		this.flags &= ~FL_ONGROUND2;

	if(trace_fraction < 1 && !(this.flags & FL_ONGROUND2))
	{
#ifdef SVQC
		//a landing
		float r;
#endif

		this.flags |= FL_ONGROUND2;

#ifdef SVQC
		if(this.jump_flag < -1000)
		{
			_sound(this, CHAN_BODY, "bland1.wav", 1, ATTN_NORM);

			if(this.jump_flag > -2000)
				r = rint(((0 - this.jump_flag) * 0.01));
			else
				r = 20;

			makevectors(this.angles);
			while(r > 0)
			{
				particle (this.origin + '0 0 -30' + v_forward*crandom()*20 + v_right*crandom()*20, v_forward*crandom()*20 + v_right*crandom()*20, 8, 40);
				r -= 1;
			}
		}
		if(this.jump_flag < -200)
		{
			r = min(1, (0 - this.jump_flag) * 0.001);

			_sound(this, CHAN_BODY, "bland2.wav", r, ATTN_NORM);
		}
#endif
	}
}

#ifdef SVQC
void Impact(entity attacker, entity targ)
{
	if(vdist(attacker.velocity - targ.velocity, <, 300)) return;
	if(!STAT(SLIDE_ON, attacker)) return;
	if(STAT(SLIDE_ON, targ) && (slideflags & SF_INTERBASHNO)) return;

	float dam = vlen(attacker.velocity - targ.velocity) * 0.09;

	T_Damage(targ, attacker, attacker, dam, DEATH_CRUSH.m_id);

	_sound(attacker, CHAN_AUTO, "bland2.wav", 1, ATTN_NORM);
}
#endif

void slide_PlayerTouch(entity this, entity toucher)
{
#ifdef SVQC
	if(!PHYS_SLIDE(this))
		return;
	if(!toucher || toucher.takedamage != DAMAGE_AIM)
		return;
	if(IS_PLAYER(toucher) && (autocvar_g_friendlyfire_virtual || autocvar_g_friendlyfire <= 0))
		return;

	UNSET_ONGROUND(toucher);

	if(vlen2(this.velocity) > vlen2(toucher.velocity))
		Impact(this, toucher);
	else
		Impact(toucher, this);

	vector tempv = this.velocity;
	this.velocity = toucher.velocity + '0 0 1';
	toucher.velocity = tempv;
#endif
}

void slide_physics(entity this)
{
	UNSET_ONGROUND(this);
	CheckSlideGround(this);

	if(PHYS_INPUT_BUTTON_ATCK(this))
		Slide_Turn(this);

	traceline(this.origin - '0 0 64', this.origin - '0 0 64', MOVE_NOMONSTERS, this);
	//if(cont == CONTENT_WATER || cont == CONTENT_LAVA || cont == CONTENT_SLIME)
	if(trace_dpstartcontents & DPCONTENTS_LIQUIDSMASK)
		this.velocity_z += 16;
}

#ifdef SVQC

void slide_check_time()
{
	if(world.worldtype != WORLDTYPE_SLIDE)
		return;

	if(slide_timelimit && slide_timelimit < time)	//time is over
	{
		mapname = "slstart";
		NextLevel();
	}
}

void Slide_Record()
{
	string week = strftime(true, "%U");
	db_put(ServerProgsDB, strcat(mapname, "/besttime"), ftos(timebest));
	db_put(ServerProgsDB, strcat(mapname, "/besttimeset"), week);
	if(namebest && namebest != "")
		db_put(ServerProgsDB, strcat(mapname, "/bestname"), namebest);
}

void Slide_Switch(entity this)
{
	_setmodel(this, get_playermodel(this));
	this.modelindex_player = this.modelindex;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
}

void Slide_On(entity this)
{
	if(this.tank || STAT(SKATING, this) || STAT(CANNON, this) || this.clockwork)
		return;
	STAT(SLIDE_ON, this) = true;
	if(!deathmatch)
		this.solid = SOLID_TRIGGER;

	Slide_Switch(this);
}

void Slide_Off(entity this)
{
	STAT(SLIDE_ON, this) = false;
	if(!deathmatch)
		this.solid = SOLID_SLIDEBOX;

	Slide_Switch(this);
}

void Slide_Toggle(entity this)
{
	if(!STAT(SLIDE_ON, this))
	{
		Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_SLIDE_ACTIVATE);
		Slide_On(this);
	}
	else
	{
		Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_SLIDE_DEACTIVATE);
		Slide_Off(this);
	}
}

void slide_UpdateStats(entity this)
{
	if(STAT(SLIDE_ON, this))
	{
		STAT(MOVEVARS_WALLFRICTION, this) = 1;

		STAT(MOVEVARS_FRICTION_EDGE, this) = 1;

		STAT(MOVEVARS_FRICTION, this) = 7;
		STAT(MOVEVARS_ACCELERATE, this) = 8;
		STAT(MOVEVARS_MAXSPEED, this) = 400;
		STAT(MOVEVARS_STOPSPEED, this) = 100;
		STAT(MOVEVARS_MAXAIRSPEED, this) = 220;
		STAT(MOVEVARS_AIRACCELERATE, this) = 32;
	}
}

void slide_PutPlayerInServer(entity this)
{
	STAT(SLIDE_ON, this) = false;
	this.slide_points = 0;
}

void Slide_OnThink(entity this)
{
	if(STAT(SLIDE_ON, this))
	{
		if(this.frame != 0)
			this.frame = 0;

		int contents = pointcontents(this.origin);
		if(!(contents == CONTENT_EMPTY))
		{
			if(contents == CONTENT_LAVA)
			{
				Spawn_Board(this);
				Slide_Off(this);
			}
		}
	}

	if(PHYS_INPUT_BUTTON_CROUCH(this) && time > this.board_delay && this.health > 0 && !this.elec && !this.tank && !this.clockwork && !STAT(SKATING, this) && !STAT(CANNON, this))
	{
		Slide_Toggle(this);
		this.board_delay = time + 1;
	}
}

void slide_PlayerDies(entity this)
{
	if(STAT(SLIDE_ON, this))
		Spawn_Board(this);
	Slide_Off(this);
}

void Set_Check(entity this)
{
	int bitflag = 1;
	entity e;
	checkcfg = 1; // initial starting point also counts

	e = find(NULL, classname, "checkpoint");
	while(e)
	{
		bitflag *= 2;
		e.slide_points = bitflag;
		checkcfg |= bitflag;
		e = find(e, classname, "checkpoint");
	}

	e = find(NULL, classname, "checkfield");
	while(e)
	{
		bitflag *= 2;
		e.slide_points = bitflag;
		checkcfg |= bitflag;
		e = find(e, classname, "checkfield");
	}

	float week = stof(strftime(true, "%U"));
	float timebestset = stof(db_get(ServerProgsDB, strcat(mapname, "/besttimeset")));
	if(week == timebestset)
	{
		timebest = stof(db_get(ServerProgsDB, strcat(mapname, "/besttime")));
		strcpy(namebest, db_get(ServerProgsDB, strcat(mapname, "/bestname")));
	}
}

PRECACHE(Slide)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
		return;

	precache_sound("doors/airdoor2.wav");

	precache_sound("bjump1.wav");
	precache_sound("bland1.wav");
	precache_sound("bland2.wav");
	precache_sound("board4.wav");

	precache_model("progs/surfer1.mdl");
	precache_model("progs/board.mdl");
	precache_model("progs/zipper.mdl");

	entity slidecheck = new_pure(slidecheck);
	setthink(slidecheck, Set_Check);
	slidecheck.nextthink = time + 1;

	if(world.model != "maps/slstart.bsp")
		slide_timelimit = autocvar_sv_quake_slide_timelimit;
}

#if 0
void Slide_Push(entity this)
{
	float spd;

	spd = vlen(this.velocity);

	if(spd < 320)
	{
		this.velocity = normalize(this.velocity);
		this.velocity = this.velocity * 320;
	}
}
#endif

bool slide_ImpulseCommands(entity this, int imp)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
		return false;

#if 0
	if(imp == 1 && STAT(SLIDE_ON, this))
	{
		centerprint(this, "Slider Deactivated!");

		Spawn_ABoard(this);

		Slide_Off(this);
		return true;
	}

	if(imp == 100 && !deathmatch && !coop)
	{
		Slide_Toggle(this);
		return true;
	}
#endif

#if 0
	if(imp == 2)
	{
		Slide_Push(this);
		return true;
	}
#endif

	return false;
}

void ZipSparks(entity targ, vector dir, float sparknum)
{
	while(sparknum > 0)
	{
		vector rvec;
		rvec.x = crandom()*targ.maxs_x + targ.origin_x;
		rvec.y = crandom()*targ.maxs_y + targ.origin_y;
		rvec.z = crandom()*targ.maxs_z + targ.origin_z;

		particle(rvec, dir, 232, 70);

		sparknum -= 1;
	}
}

void ZipTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(!STAT(SLIDE_ON, toucher)) return;
	if(toucher.ziptime > time) return;

	toucher.ziptime = time + 0.5;
	
	if(this.max_health > 0 && vdist(toucher.velocity, >, this.max_health))
		return;

	makevectors(this.mangle);

	v_forward_z = 0 - v_forward_z;

	toucher.velocity = toucher.velocity + v_forward * this.health;

	ZipSparks(toucher, v_forward * this.health, 10);

	_sound(this, CHAN_AUTO, "zip.wav", 1, ATTN_NORM);
}

spawnfunc(point_zip)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	if((this.spawnflags & DMONLY) && !deathmatch)
	{
		delete(this);
		return;
	}

	traceline(this.origin, this.origin - '0 0 256', true, this);

	droptofloor(this);

	this.mangle = this.angles;

	this.angles = vectoangles(trace_plane_normal);

	this.angles_z = this.mangle_y + 180;

	settouch(this, ZipTouch);

	precache_sound("zip.wav");
	precache_model("progs/zipper.mdl");

	_setmodel(this, "progs/zipper.mdl");
	setorigin(this, this.origin);

	this.classname = "zipperpoint";

	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_TRIGGER;

	this.skin = 0;

	setsize(this, '-32 -32 -24', '32 32 64');
}

//Makes drippy bits for start point
void StartPointThink(entity this)
{
	particle(this.origin + '0 0 50', '0 0 -7', 40, 50);

	this.nextthink = time + 0.1 + random() * 0.8;
}

void StartTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(toucher.slide_points > 0) return;
	if(toucher.tank) return;
	if(STAT(CANNON, toucher)) return;
	if(STAT(SKATING, toucher)) return;
	if(toucher.clockwork) return;

	if(!STAT(SLIDE_ON, toucher))
		Slide_On(toucher);

	toucher.slide_points = 1;

	toucher.slide_time = time;

	if(this.classname == "startpoint")
	{
		spawn_tfog(this.origin);
		_sound(this, CHAN_AUTO, "go.wav", 1, ATTN_NORM);
	}
	else if(this.classname == "startfield")
	{
		spawn_tfog(toucher.origin);
		_sound(toucher, CHAN_AUTO, "go.wav", 1, ATTN_NORM);
	}

	Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_SLIDE_GO);
}

spawnfunc(point_start)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	droptofloor(this);

	precache_sound("go.wav");

	precache_model("progs/spoint.mdl");
	_setmodel(this, "progs/spoint.mdl");

	this.classname = "startpoint";

	settouch(this, StartTouch);

	setthink(this, StartPointThink);
	this.nextthink = time;

	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_TRIGGER;

	setsize(this, '-16 -16 0', '16 16 56');
}

void GlowOff(entity this);
void GlowOn(entity this)
{
	if(!(this.spawnflags & NOGLOW))
		this.effects |= EF_DIMLIGHT;

	this.skin = 0;
	this.nextthink = time + 1;
	setthink(this, GlowOff);
}

//Turns the glow off from checkpoints and endpoints.
void GlowOff(entity this)
{
	this.skin = 1;
	this.effects &= ~EF_DIMLIGHT;
}

void EndStuff(entity this, entity trigger)
{
	if(STAT(SLIDE_ON, this))
		Spawn_ABoard(this);

	Slide_Off(this);

	this.slide_points = 0;
	this.frags += 5;

	float temptime = max(0, time - this.slide_time);
	bool newrecord = false;
	float oldtime = timebest;

	if(deathmatch)
		bprintf("%s finished in %d seconds\n", this.netname, temptime);

	string oldname = strcat1(namebest);

	if(temptime > 0 && (temptime < timebest || !timebest))
	{
		newrecord = true;

		strcpy(namebest, this.netname);

		timebest = temptime;
		Slide_Record();
		this.frags += 2;
	}

	trigger.attack_finished = time + 0.7; // TODO: this was originally pointing at the player, does nothing?

	if(trigger.classname == "endpoint")
		_sound(trigger, CHAN_AUTO, "buzz.wav", 1, ATTN_NORM);
	else if(trigger.classname == "endfield")
		_sound(this, CHAN_AUTO, "buzz.wav", 1, ATTN_NORM);

	if(newrecord)
	{
		if(oldtime > 0 && oldtime != 999999)
			Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_SLIDE_RECORD_BEAT, oldname, TIME_ENCODE(timebest), TIME_ENCODE(oldtime));
		else
			Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_SLIDE_RECORD_NEW, TIME_ENCODE(timebest));
	}
	else
		Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_SLIDE_FINISHED, ((namebest && namebest != "") ? namebest : "Player"), TIME_ENCODE(temptime), TIME_ENCODE(timebest));
}

void EndPointTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(!toucher.slide_points) return;

	if(toucher.slide_points != checkcfg)
	{
		if(!(slideflags & SF_NOCHECKGIB))
		{
			T_Damage(toucher, this, this, 10000, DEATH_CHECKPOINT.m_id);
			return;
		}

		if(STAT(SLIDE_ON, toucher))
			toucher.velocity = '0 0 0' - toucher.velocity;
		return;
	}

	EndStuff(toucher, this);

	setthink(this, GlowOn);
	this.nextthink = time;
}

spawnfunc(point_end)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	traceline(this.origin, this.origin - '0 0 256', true, this);

	droptofloor(this);

	this.angles = vectoangles(trace_plane_normal);
	this.angles_z = crandom()*180;

	settouch(this, EndPointTouch);

	precache_sound("buzz.wav");
	precache_model("progs/epoint.mdl");

	_setmodel(this, "progs/epoint.mdl");
	setorigin(this, this.origin);

	this.classname = "endpoint";

	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_TRIGGER;

	this.skin = 1;

	setsize(this, '-32 -32 -24', '32 32 64');
}

void CheckPointTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(!(toucher.slide_points & 1)) return;
	if(toucher.slide_points & this.slide_points) return;

	toucher.slide_points |= this.slide_points;

	setthink(this, GlowOn);
	this.nextthink = time;

	_sound(this, CHAN_AUTO, "ding.wav", 1, ATTN_NORM); 

	Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_SLIDE_CHECKPOINT);
}

spawnfunc(point_check)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	traceline(this.origin, this.origin - '0 0 256', true, this);

	droptofloor(this);

	this.angles = vectoangles(trace_plane_normal);
	this.angles_z = crandom()*180;

	precache_sound("ding.wav");
	precache_model("progs/cpoint.mdl");

	_setmodel(this, "progs/cpoint.mdl");

	settouch(this, CheckPointTouch);

	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_TRIGGER;

	this.classname = "checkpoint";

	this.skin = 1;

	setsize(this, '-32 -32 -24', '32 32 64');
}

void ReslideTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(STAT(SLIDE_ON, toucher)) return;
	if(!toucher.slide_points) return;
	if(toucher.health < 1) return;
	if(toucher.tank) return;
	if(STAT(CANNON, toucher)) return;
	if(STAT(SKATING, toucher)) return;
	if(toucher.clockwork) return;

	Slide_On(toucher);

	if(this.classname == "reslidepoint")
		spawn_tfog(this.origin);
	else if(this.classname == "reslidefield")
		spawn_tfog(toucher.origin);
}

spawnfunc(item_reslide)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	traceline(this.origin, this.origin - '0 0 256', true, this);

	droptofloor(this);

	this.angles = vectoangles(trace_plane_normal);
	this.angles_z = crandom()*180;

	precache_model("progs/reslide.mdl");
	_setmodel(this, "progs/reslide.mdl");

	settouch(this, ReslideTouch);

	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_TRIGGER;

	this.classname = "reslidepoint";

	setsize(this, '-20 -20 0', '20 20 56');
}

void BonusTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(!STAT(SLIDE_ON, toucher)) return;

	toucher.frags += 1;

	this.solid = SOLID_NOT;
	this.model = string_null;
	this.nextthink = time + 20;
	setthink(this, SUB_regen);

	Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_SLIDE_BONUS_POINT);

	this.avelocity_x = crandom()*360;
	this.avelocity_y = crandom()*360;
	this.avelocity_z = crandom()*360;

	_sound(toucher, CHAN_ITEM, "whoosh.wav", 1, ATTN_NORM);

	SUB_UseTargets(this, toucher, NULL);

	toucher.effects |= EF_MUZZLEFLASH;
}

spawnfunc(item_bonus)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	settouch(this, BonusTouch);

	precache_sound("whoosh.wav");

	precache_model("progs/bonus2.mdl");
	_setmodel(this, "progs/bonus2.mdl");

	setsize(this, '-16 -16 -24', '16 16 24');

	this.classname = "bonus";

	this.mdl = this.model;
	this.flags = FL_ITEM;
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_FLY);

	this.avelocity_x = crandom()*360;
	this.avelocity_y = crandom()*360;
	this.avelocity_z = crandom()*360;
}

//Makes drippy bits for start point
void ZipFieldThink(entity this)
{
	float rand1 = this.mins_x + random()*this.size_x;
	float rand2 = this.mins_y + random()*this.size_y;
	float rand3 = this.mins_z + random()*this.size_z;

	vector randv = vec3(rand1, rand2, rand3);

	particle(randv, this.v_angle * 10, 232, 50);

	this.nextthink = time + 0.1;
}

void ZipFieldTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(!STAT(SLIDE_ON, toucher)) return;
	if(toucher.ziptime > time) return;

	toucher.ziptime = time + 0.1;

	if(this.max_health > 0 && vdist(toucher.velocity, >, this.max_health))
		return;

	makevectors(this.mangle);

	v_forward.z = -v_forward.z;

	toucher.velocity = toucher.velocity + v_forward * this.health;

	ZipSparks(toucher, v_forward*this.health, 1);

//   sound(toucher, CHAN_AUTO, "zip.wav", 1, ATTN_NORM);
}

spawnfunc(trigger_zip)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	if((this.spawnflags & DMONLY) && !deathmatch)
	{
		delete(this);
		return;
	}

	this.mangle = this.angles;

	makevectors(this.mangle);
	v_forward_z = 0 - v_forward_z;

	this.v_angle = v_forward;

	InitTrigger(this);

	precache_sound("zip.wav");

	this.classname = "zipfield";

	settouch(this, ZipFieldTouch);

	setthink(this, ZipFieldThink);
	this.nextthink = time;
}

void ImpactFieldTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;

	if(vdist(toucher.velocity, <, 400))
		return;

	float dam = vlen(toucher.velocity) * 0.08;

	T_Damage(toucher, this, this, dam, DEATH_TRAP.m_id);

	toucher.velocity = '0 0 0';
}

//field that does dsamage based on player velocity. for spikes and stuff.
spawnfunc(trigger_impact)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	InitTrigger(this);

	this.classname = "impactfield";

	settouch(this, ImpactFieldTouch);
}

void PeaceFieldTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(this.attack_finished > time) return;
	if(toucher.health < 1) return;

	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		ATTACK_FINISHED(toucher, weaponentity) = time + 1.1;
	}

	this.attack_finished = time + 1;
}

//Players can't shoot. For observation booths and MAYBE start areas.
spawnfunc(trigger_peace)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	InitTrigger(this);

	this.classname = "peacefield";

	settouch(this, PeaceFieldTouch);
}

void StartFlash(entity this)
{
	if(this.health)
	{
		_setmodel(this, this.netname);
		this.modelindex = this.lefty;

		this.health = 0;

		this.nextthink = time + 0.5;
	}
	else
	{
		this.modelindex = 0;

		this.health = 1;

		this.nextthink = time + 0.5;
	}
}

spawnfunc(trigger_start)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	precache_sound("go.wav");

	this.netname = this.model;
	this.classname = "startfield";

	settouch(this, StartTouch);

	setthink(this, StartFlash);
	this.nextthink = time;

	_setmodel(this, this.model);

	this.lefty = this.modelindex;

	InitTrigger(this);
}

void EndFieldTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(!toucher.slide_points) return;

	if(toucher.slide_points != checkcfg)
	{
		if(!(slideflags & SF_NOCHECKGIB))
		{
			T_Damage(toucher, this, this, 10000, DEATH_CHECKPOINT.m_id);
			return;
		}

		if(STAT(SLIDE_ON, toucher))
			toucher.velocity = '0 0 0' - toucher.velocity;
		return;
	}

	EndStuff(toucher, this);

//   dummy = find (world, targetname, this.targetname);
	entity dummy = find(NULL, targetname, this.target);

	if(!dummy)
		objerror(this, "You need at least one dummy with the same targetname as this checkpoint trigger's target!");
	while(dummy)
	{
		if(dummy.classname == "enddummy")
		{
			setthink(dummy, GlowOn);
			dummy.nextthink = time;
		}

//      dummy = find (dummy, targetname, this.targetname);
		dummy = find(dummy, targetname, this.target);
	}
}

spawnfunc(trigger_end)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	InitTrigger(this);

	precache_sound("buzz.wav");

	this.classname = "endfield";

	settouch(this, EndFieldTouch);
}

spawnfunc(dummy_end)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	traceline(this.origin, this.origin - '0 0 256', true, this);

	droptofloor(this);

	this.angles = vectoangles(trace_plane_normal);
	this.angles_z = crandom()*180;

	precache_model("progs/epoint.mdl");
	_setmodel(this, "progs/epoint.mdl");

	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;

	this.classname = "enddummy";

	this.skin = 1;
}

void CheckFieldTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(!(toucher.slide_points & 1)) return;
	if(toucher.slide_points & this.slide_points) return;

	toucher.slide_points |= this.slide_points;

//   dummy = find (world, targetname, this.targetname);
	entity dummy = find(NULL, targetname, this.target);

	if(!dummy)
		objerror(this, "You need at least one dummy with the same targetname as this checkpoint trigger!");
	while(dummy)
	{
		if(dummy.classname == "checkdummy")
		{
			setthink(dummy, GlowOn);
			dummy.nextthink = time;
		}

//      dummy = find (dummy, targetname, this.targetname);
		dummy = find(dummy, targetname, this.target);
	}

	_sound(toucher, CHAN_AUTO, "ding.wav", 1, ATTN_NORM); 

	Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_SLIDE_CHECKPOINT);
}

spawnfunc(trigger_check)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	InitTrigger(this);

	precache_sound("ding.wav");

	this.classname = "checkfield";

	settouch(this, CheckFieldTouch);
}

spawnfunc(dummy_check)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	traceline(this.origin, this.origin - '0 0 256', true, this);

	droptofloor(this);

	this.angles = vectoangles(trace_plane_normal);
	this.angles_z = crandom()*180;

	precache_model("progs/cpoint.mdl");
	_setmodel(this, "progs/cpoint.mdl");

	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;

	this.classname = "checkdummy";

	this.skin = 1;
}

void ReslideFlash(entity this)
{
	if(this.health)
	{
		_setmodel(this, this.netname);
		this.modelindex = this.lefty;

		this.health = 0;

		this.nextthink = time + 0.05;
	}
	else
	{
		this.modelindex = 0;

		this.health = 1;

		this.nextthink = time + 0.5 + random();
	}
}

spawnfunc(trigger_reslide)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	this.netname = this.model;
	this.classname = "reslidefield";

	settouch(this, ReslideTouch);

	setthink(this, ReslideFlash);
	this.nextthink = time;

	_setmodel(this, this.model);

	this.lefty = this.modelindex;

	InitTrigger(this);
}

void player_trip15(entity this) { set_animofs(this, anim_player_deathc1, 15, player_run); }
void player_trip14(entity this) { set_animofs(this, anim_player_deathc1, 14, player_trip15); }
void player_trip13(entity this) { set_animofs(this, anim_player_deathc1, 13, player_trip14); }
void player_trip12(entity this) { set_animofs(this, anim_player_deathc1, 12, player_trip13); }
void player_trip11(entity this) { set_animofs(this, anim_player_deathc1, 11, player_trip12); }
void player_trip10(entity this) { set_animofs(this, anim_player_deathc1, 10, player_trip11); }
void player_trip9(entity this) { set_animofs(this, anim_player_deathc1, 9, player_trip10); }
void player_trip8(entity this) { set_animofs(this, anim_player_deathc1, 8, player_trip9); }
void player_trip7(entity this) { set_animofs(this, anim_player_deathc1, 7, player_trip8); }
void player_trip6(entity this) { set_animofs(this, anim_player_deathc1, 6, player_trip7); }
void player_trip5(entity this) { set_animofs(this, anim_player_deathc1, 5, player_trip6); }
void player_trip4(entity this) { set_animofs(this, anim_player_deathc1, 4, player_trip5); }
void player_trip3(entity this) { set_animofs(this, anim_player_deathc1, 3, player_trip4); }
void player_trip2(entity this) { set_animofs(this, anim_player_deathc1, 2, player_trip3); }
void player_trip1(entity this) { set_animofs(this, anim_player_deathc1, 1, player_trip2); }

void TripTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(!STAT(SLIDE_ON, toucher)) return;

	Slide_Off(toucher);

	Spawn_Board(toucher);

	player_trip1(toucher);
}

spawnfunc(trigger_trip)
{
	if(world.worldtype != WORLDTYPE_SLIDE)
	{
		delete(this);
		return;
	}

	InitTrigger(this);

	this.classname = "tripfield";

	settouch(this, TripTouch);
}

//Spawning a board for when you die, or hit lava, or trip.
void Spawn_Board(entity this)
{
	entity board = new(boards);

	set_movetype(board, MOVETYPE_BOUNCE);
	board.solid = SOLID_NOT;
	board.owner = this;

	setorigin(board, this.origin);

	_setmodel(board, "progs/board.mdl");
	setsize(board, '-32 -32 -10', '32 32 10');

	board.angles = this.angles;
	board.avelocity_x = random()*360 - 180;
	board.avelocity_y = random()*360 - 180;
	board.avelocity_z = random()*360 - 180;

	UNSET_ONGROUND(board);

	board.velocity = this.velocity + '0 0 300';

	setthink(board, SUB_Remove);
	board.nextthink = time + 20;
}

void aniboard9(entity this) { set_anim(this, 9, SUB_Remove); particle(this.origin, '0 0 0', 0, 100); }
void aniboard8(entity this) { set_anim(this, 8, aniboard9); }
void aniboard7(entity this) { set_anim(this, 7, aniboard8); }
void aniboard6(entity this) { set_anim(this, 6, aniboard7); }
void aniboard5(entity this) { set_anim(this, 5, aniboard6); }
void aniboard4(entity this) { set_anim(this, 4, aniboard5); }
void aniboard3(entity this) { set_anim(this, 3, aniboard4); }
void aniboard2(entity this) { set_anim(this, 2, aniboard3); }
void aniboard1(entity this) { set_anim(this, 1, aniboard2); }
void aniboard(entity this) { set_anim(this, 0, aniboard1); }

//Spawning a board for when you deactivate it or reach the end.
void Spawn_ABoard(entity this)
{
	entity board = new(board);

	set_movetype(board, MOVETYPE_FLY);
	board.solid = SOLID_NOT;
	board.owner = this;

	setorigin(board, this.origin);

	_setmodel(board, "progs/board.mdl");
	setsize(board, '0 0 0', '0 0 0');

	board.angles = this.angles;

	if(random() > 0.5)
		board.avelocity_y = -360;
	else
		board.avelocity_y = 360;

	UNSET_ONGROUND(board);

	setthink(board, aniboard);
	board.nextthink = time;
}
#endif
