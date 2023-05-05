#include "../../common/monsters/_mod.qh"

void play_sound_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & 1)
	{
		if(this.state == 0)
		{
			this.state = 1;
			_sound(this, this.impulse, this.noise, this.volume, this.speed);
		}
		else
		{
			this.state = 0;
			sound(this, this.impulse, SND_Null, this.volume, this.speed);
		}
	}
	else
		_sound(this, this.impulse, this.noise, this.volume, this.speed);
}

void PlaySoundThink(entity this)
{
	float t = max(this.delay, this.wait * random());
	this.nextthink = time + t;
	play_sound_use(this, NULL, NULL);
}

/*QUAKED play_sound_triggered (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) toggle
play a sound when it is used
"toggle" determines whether sound should be stopped when triggered again
"volume" how loud (1 default full volume)
"noise" sound to play
"impulse" channel on which to play _sound(0-7) (0 automatic is default)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(play_sound_triggered)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	precache_sound(this.noise);
	precache_sound("misc/null.wav");
	if(this.volume == 0)
		this.volume = 1;
	if(this.speed == 0)
		this.speed = 1;
	if(this.speed == -1)
		this.speed = 0;
	if(this.spawnflags & 1)
		if(this.impulse == 0)
			this.impulse = 7;
	this.use = play_sound_use;
}

/*QUAKED play_sound(0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
play a sound on a periodic basis
"volume" how loud (1 default full volume)
"noise" sound to play
"wait" random time between sounds (default 20)
"delay" minimum delay between sounds (default 2)
"impulse" channel on which to play _sound(0-7) (0 automatic is default)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(play_sound)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	spawnfunc_play_sound_triggered(this);
	if(this.wait == 0)
		this.wait = 20;
	if(this.delay == 0)
		this.delay = 2;
	setthink(this, PlaySoundThink);
	float t = max(this.delay, this.wait * random());
	this.nextthink = time + t;
}

/*QUAKED random_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
"wait" random time between strikes (default 20)
"delay" minimum delay between strikes (default 2)
"volume" how loud (1 default full volume)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(random_thunder)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.noise = "ambience/thunder1.wav";
	spawnfunc_play_sound(this);
	this.impulse = 6;
}

/*QUAKED random_thunder_triggered (0.3 0.1 0.6) (-10 -10 -8) (10 10 8) toggle
"toggle" determines whether sound should be stopped when triggered again
"volume" how loud (1 default full volume)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(random_thunder_triggered)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.noise = "ambience/thunder1.wav";
	spawnfunc_play_sound_triggered(this);
	this.impulse = 6;
}

/*QUAKED ambient_humming (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_humming)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/humming.wav");
	ambientsound(this.origin, "ambient/humming.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_rushing (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_rushing)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/rushing.wav");
	ambientsound(this.origin, "ambient/rushing.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_running_water (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_running_water)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/runwater.wav");
	ambientsound(this.origin, "ambient/runwater.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_fan_blowing (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_fan_blowing)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/fanblow.wav");
	ambientsound(this.origin, "ambient/fanblow.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_waterfall (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_waterfall)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/waterfal.wav");
	ambientsound(this.origin, "ambient/waterfal.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_riftpower (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_riftpower)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/riftpowr.wav");
	ambientsound(this.origin, "ambient/riftpowr.wav", this.volume, ATTN_STATIC);
}


/*QUAKED info_command (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
 Stuffs a command into the console to allow map designers
 to set server variables.

 "message" is the command to send to the console.
*/

spawnfunc(info_command)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.message)
		localcmd(strcat("\n", this.message, "\n"));
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
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.use = effect_teleport_use;
}


const int SVC_UPDATEENTITY = 128; // Net.Protocol 0x80
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
