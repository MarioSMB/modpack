#ifdef SVQC

void UpdateCamera(entity this, entity camera)
{
	msg_entity = this;                         // target of message
	WriteByte(MSG_ONE, SVC_UPDATEENTITY|15); // 0x80|1|2|4|8
	WriteByte(MSG_ONE, 64); // 0x40
	WriteEntity(MSG_ONE,camera);
	WriteCoord(MSG_ONE,camera.origin_x);
	WriteCoord(MSG_ONE,camera.origin_y);
	WriteCoord(MSG_ONE,camera.origin_z);
}


//void() effect_finale_think =
//   {
//   this.flags = this.flags - (this.flags & FL_ONGROUND);
//   this.angles = this.mangle;
//   this.v_angle = this.mangle;
//   this.fixangle = true;
//   NezuUpdateCamera(this,this.trigger_field);
//   NezuSetViewPoint(this,this.trigger_field);
//   NezuSetViewAngle(this,this.mangle);
//   this.think = effect_finale_think;
//   this.nextthink = time + 0.05;
//   }


void effect_finale_use(entity this, entity actor, entity trigger)
{
	if(this.state == 1)
		return;

	intermission_exittime = time + 10000000;  // never allow exit
	intermission_running = 1;
	this.state = 1;

	// find the intermission spot
	entity pos = find(NULL, targetname, this.target);
	if(!pos)
		error("no target in finale");

//   WriteByte (MSG_ALL, SVC_FINALE);
	WriteByte(MSG_ALL, SVC_CUTSCENE);
	WriteString(MSG_ALL, "");

	//setup decoy
	if(!(this.spawnflags & 2))
	{
		if(this.spawnflags & 1)
		{
			entity pl = NULL;
			FOREACH_CLIENT(IS_PLAYER(it),
			{
				pl = it;
				break;
			});
			entity targ = find(NULL, targetname, this.mdl);
			become_decoy(targ.target, pl.origin);
		}
		else
		{
			entity targ = find(NULL, targetname, this.mdl);
			become_decoy(targ.target, targ.origin);
		}
	}

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.view_ofs = '0 0 0';
		it.angles = trigger.v_angle = pos.mangle;
		it.mangle = pos.mangle;
		it.fixangle = true;     // turn this way immediately
		it.trigger_field = this;
		it.nextthink = time + 0.5;
		it.takedamage = DAMAGE_NO;
		it.solid = SOLID_NOT;
		set_movetype(it, MOVETYPE_NONE);
		//it.modelindex = 0;
		setmodel(it, MDL_Null);
		setorigin(it, pos.origin);
		it.origin = pos.origin;
		it.oldorigin = pos.origin;
		UpdateCamera(it, it);
		UpdateCamera(it, it.trigger_field);
	});

	// wait for next sequence
		
	if(this.spawnfunction)
	{
		string value = strcat("spawnfunc_", this.spawnfunction);
		if(substring(value, 0, 1) == "_")
			value = strcat("target_spawn_helper", value);
		putentityfieldstring(target_spawn_spawnfunc_field, this, value);

		setthink(this, this.target_spawn_spawnfunc);
		this.nextthink = time + this.wait;
	}
//   intermission_running = 0;
}
/*
 "count" 0 - static camera
		 1 - path camera
		 2 - chase camera
 "distance" distance from chase guy
			(default 100)
 "height" height distance from chase guy
			(default 64)
*/

/*QUAKED effect_finale (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) useplayer nodecoy
 start the finale sequence
 "target" the camera to go to.
 "mdl" if useplayer is specified, this is a
 path corner with target of the next
 path_corner to run to.
 if use player isn't specified this becomes
 the spawn point as well.
 "spawnfunction" next routine to run
 "delay" time to wait until running routine
 useplayer - use the current player as
				 decoy location.
 nodecoy - no decoy, only the camera
*/

spawnfunc(effect_finale)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(deathmatch) { delete(this); return; }

	initialize_field_db();

	setorigin(this, this.origin);
	this.angles = this.mangle;
	this.use = effect_finale_use;
//   setsize(this,'-16 -16 -16','16 16 16');
//   settouch(this, effect_finale_use);
//   InitTrigger ();
	this.state = 0;
}

void info_startendtext_use(entity this, entity actor, entity trigger)
{
	server_reset();

	intermission_running = 1;
	ExitIntermission();
}

/*QUAKED info_startendtext (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
 start the end text
*/

spawnfunc(info_startendtext)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.use = info_startendtext_use;
}

#endif
