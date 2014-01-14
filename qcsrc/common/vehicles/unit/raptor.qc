#ifdef REGISTER_VEHICLE
REGISTER_VEHICLE(
/* VEH_##id   */ RAPTOR,
/* function   */ v_raptor,
/* spawnflags */ VHF_DMGSHAKE | VHF_DMGROLL,
/* mins,maxs  */ '-80 -80 0', '80 80 70',
/* model	  */ "models/vehicles/raptor.dpm",
/* head_model */ "",
/* hud_model  */ "models/vehicles/raptor_cockpit.dpm",
/* tags	   	  */ "", "tag_hud", "tag_camera",
/* netname	  */ "raptor",
/* fullname   */ _("Raptor")
);
#else

const float RSM_FIRST = 1;
const float RSM_BOMB = 1;
const float RSM_FLARE = 2;
const float RSM_LAST = 2;

#ifdef SVQC
float autocvar_g_vehicle_raptor;

float autocvar_g_vehicle_raptor_respawntime;
float autocvar_g_vehicle_raptor_takeofftime;

float autocvar_g_vehicle_raptor_movestyle;
float autocvar_g_vehicle_raptor_turnspeed;
float autocvar_g_vehicle_raptor_pitchspeed;
float autocvar_g_vehicle_raptor_pitchlimit;

float autocvar_g_vehicle_raptor_speed_forward;
float autocvar_g_vehicle_raptor_speed_strafe;
float autocvar_g_vehicle_raptor_speed_up;
float autocvar_g_vehicle_raptor_speed_down;
float autocvar_g_vehicle_raptor_friction;

float autocvar_g_vehicle_raptor_bomblets;
float autocvar_g_vehicle_raptor_bomblet_alt;
float autocvar_g_vehicle_raptor_bomblet_time;
float autocvar_g_vehicle_raptor_bomblet_damage;
float autocvar_g_vehicle_raptor_bomblet_spread;
float autocvar_g_vehicle_raptor_bomblet_edgedamage;
float autocvar_g_vehicle_raptor_bomblet_radius;
float autocvar_g_vehicle_raptor_bomblet_force;
float autocvar_g_vehicle_raptor_bomblet_explode_delay;
float autocvar_g_vehicle_raptor_bombs_refire;

float autocvar_g_vehicle_raptor_flare_refire;
float autocvar_g_vehicle_raptor_flare_lifetime;
float autocvar_g_vehicle_raptor_flare_chase;
float autocvar_g_vehicle_raptor_flare_range;

float autocvar_g_vehicle_raptor_cannon_turnspeed;
float autocvar_g_vehicle_raptor_cannon_turnlimit;
float autocvar_g_vehicle_raptor_cannon_pitchlimit_up;
float autocvar_g_vehicle_raptor_cannon_pitchlimit_down;

float autocvar_g_vehicle_raptor_cannon_locktarget;
float autocvar_g_vehicle_raptor_cannon_locking_time;
float autocvar_g_vehicle_raptor_cannon_locking_releasetime;
float autocvar_g_vehicle_raptor_cannon_locked_time;
float autocvar_g_vehicle_raptor_cannon_predicttarget;

float autocvar_g_vehicle_raptor_cannon_cost;
float autocvar_g_vehicle_raptor_cannon_damage;
float autocvar_g_vehicle_raptor_cannon_radius;
float autocvar_g_vehicle_raptor_cannon_refire;
float autocvar_g_vehicle_raptor_cannon_speed;
float autocvar_g_vehicle_raptor_cannon_spread;
float autocvar_g_vehicle_raptor_cannon_force;

float autocvar_g_vehicle_raptor_energy;
float autocvar_g_vehicle_raptor_energy_regen;
float autocvar_g_vehicle_raptor_energy_regen_pause;

float autocvar_g_vehicle_raptor_health;
float autocvar_g_vehicle_raptor_health_regen;
float autocvar_g_vehicle_raptor_health_regen_pause;

float autocvar_g_vehicle_raptor_shield;
float autocvar_g_vehicle_raptor_shield_regen;
float autocvar_g_vehicle_raptor_shield_regen_pause;

float autocvar_g_vehicle_raptor_bouncefactor;
float autocvar_g_vehicle_raptor_bouncestop;
vector autocvar_g_vehicle_raptor_bouncepain;

.entity bomb1;
.entity bomb2;

float raptor_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
	return vlen(self.origin - trace_endpos);
}

void raptor_bomblet_boom()
{
	RadiusDamage (self, self.realowner, autocvar_g_vehicle_raptor_bomblet_damage,
									autocvar_g_vehicle_raptor_bomblet_edgedamage,
									autocvar_g_vehicle_raptor_bomblet_radius, world,
									autocvar_g_vehicle_raptor_bomblet_force, DEATH_VH_RAPT_BOMB, world);
	remove(self);
}

void raptor_bomblet_touch()
{
	if(other == self.owner)
		return;

	PROJECTILE_TOUCH;
	self.think = raptor_bomblet_boom;
	self.nextthink = time + random() * autocvar_g_vehicle_raptor_bomblet_explode_delay;
}

void raptor_bomb_burst()
{
	if(self.cnt > time)
	if(autocvar_g_vehicle_raptor_bomblet_alt)
	{
		self.nextthink = time;
		traceline(self.origin, self.origin + (normalize(self.velocity) * autocvar_g_vehicle_raptor_bomblet_alt), MOVE_NORMAL, self);
		if((trace_fraction == 1.0) || (vlen(self.origin - self.owner.origin) < autocvar_g_vehicle_raptor_bomblet_radius))
		{
			UpdateCSQCProjectile(self);
			return;
		}
	}

	entity bomblet;
	float i;

	Damage_DamageInfo(self.origin, 0, 0, 0, '0 0 0', DEATH_VH_RAPT_FRAGMENT, 0, self);

	for(i = 0; i < autocvar_g_vehicle_raptor_bomblets; ++i)
	{
		bomblet = spawn();
		setorigin(bomblet, self.origin);

		bomblet.movetype	= MOVETYPE_TOSS;
		bomblet.touch	   = raptor_bomblet_touch;
		bomblet.think	   = raptor_bomblet_boom;
		bomblet.nextthink   = time + 5;
		bomblet.owner	   = self.owner;
		bomblet.realowner   = self.realowner;
		bomblet.velocity	= normalize(normalize(self.velocity) + (randomvec() * autocvar_g_vehicle_raptor_bomblet_spread)) * vlen(self.velocity);

		PROJECTILE_MAKETRIGGER(bomblet);
		CSQCProjectile(bomblet, TRUE, PROJECTILE_RAPTORBOMBLET, TRUE);
	}

	remove(self);
}

void raptor_bombdrop()
{
	entity bomb_1, bomb_2;

	bomb_1 = spawn();
	bomb_2 = spawn();

	setorigin(bomb_1, gettaginfo(self, gettagindex(self, "bombmount_left")));
	setorigin(bomb_2, gettaginfo(self, gettagindex(self, "bombmount_right")));

	bomb_1.movetype	 = bomb_2.movetype   = MOVETYPE_BOUNCE;
	bomb_1.velocity	 = bomb_2.velocity   = self.velocity;
	bomb_1.touch		= bomb_2.touch	  = raptor_bomb_burst;
	bomb_1.think		= bomb_2.think	  = raptor_bomb_burst;
	bomb_1.cnt		  = bomb_2.cnt		= time + 10;

	if(autocvar_g_vehicle_raptor_bomblet_alt)
		bomb_1.nextthink = bomb_2.nextthink  = time;
	else
		bomb_1.nextthink = bomb_2.nextthink  = time + autocvar_g_vehicle_raptor_bomblet_time;

	bomb_1.owner	 = bomb_2.owner	  = self;
	bomb_1.realowner = bomb_2.realowner  = self.owner;
	bomb_1.solid	 = bomb_2.solid	  = SOLID_BBOX;
	bomb_1.gravity   = bomb_2.gravity	= 1;

	PROJECTILE_MAKETRIGGER(bomb_1);
	PROJECTILE_MAKETRIGGER(bomb_2);

	CSQCProjectile(bomb_1, TRUE, PROJECTILE_RAPTORBOMB, TRUE);
	CSQCProjectile(bomb_2, TRUE, PROJECTILE_RAPTORBOMB, TRUE);
}


void raptor_fire_cannon(entity gun, string tagname)
{
	vehicles_projectile("raptor_cannon_muzzleflash", "weapons/lasergun_fire.wav",
						   gettaginfo(gun, gettagindex(gun, tagname)), normalize(v_forward + randomvec() * autocvar_g_vehicle_raptor_cannon_spread) * autocvar_g_vehicle_raptor_cannon_speed,
						   autocvar_g_vehicle_raptor_cannon_damage, autocvar_g_vehicle_raptor_cannon_radius, autocvar_g_vehicle_raptor_cannon_force,  0,
						   DEATH_VH_RAPT_CANNON, PROJECTILE_RAPTORCANNON, 0, TRUE, TRUE, self.owner);
}

void raptor_land()
{
	float hgt;

	hgt = raptor_altitude(512);
	self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
	self.angles_x *= 0.95;
	self.angles_z *= 0.95;

	if(hgt < 128)
	if(hgt > 0)
		self.frame = (hgt / 128) * 25;

	self.bomb1.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;

	if(hgt < 16)
	{
		self.movetype = MOVETYPE_TOSS;
		self.think	= vehicles_think;
		self.frame	= 0;
	}

	self.nextthink  = time;
	
	CSQCMODEL_AUTOUPDATE();
}

void raptor_exit(float eject)
{
	vector spot;
	self.tur_head.exteriormodeltoclient = world;

	if(self.deadflag == DEAD_NO)
	{
		self.think	  = raptor_land;
		self.nextthink  = time;
	}

	if(!self.owner)
		return;

	makevectors(self.angles);
	if(eject)
	{
		spot = self.origin + v_forward * 100 + '0 0 64';
		spot = vehicles_findgoodexit(spot);
		setorigin(self.owner , spot);
		self.owner.velocity = (v_up + v_forward * 0.25) * 750;
		self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > 2 * autocvar_sv_maxairspeed)
		{
			self.owner.velocity = normalize(self.velocity) * autocvar_sv_maxairspeed * 2;
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 32 + '0 0 64';
			spot = vehicles_findgoodexit(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin - v_forward * 200 + '0 0 64';
			spot = vehicles_findgoodexit(spot);
		}
		self.owner.oldvelocity = self.owner.velocity;
		setorigin(self.owner , spot);
	}

	antilag_clear(self.owner);
	self.owner = world;
}

void raptor_flare_touch()
{
	remove(self);
}

void raptor_flare_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health -= damage;
	if(self.health <= 0)
		remove(self);
}

void raptor_flare_think()
{
	self.nextthink = time + 0.1;
	entity _missile = findchainentity(enemy, self.owner);
	while(_missile)
	{
		if(_missile.flags & FL_PROJECTILE)
		if(vlen(self.origin - _missile.origin) < autocvar_g_vehicle_raptor_flare_range)
		if(random() > autocvar_g_vehicle_raptor_flare_chase)
			_missile.enemy = self;
		_missile = _missile.chain;
	}

	if(self.tur_impacttime < time)
		remove(self);
}

float raptor_frame()
{
	entity player, raptor;
	float ftmp = 0;
	vector df;

	if(intermission_running)
		return 1;

	player = self;
	raptor = self.vehicle;
	self   = raptor;
	
	vehicles_painframe();
	/*
	ftmp = vlen(self.velocity);
	if(ftmp > autocvar_g_vehicle_raptor_speed_forward)
		ftmp = 1;
	else
		ftmp = ftmp / autocvar_g_vehicle_raptor_speed_forward;
	*/

	if(self.sound_nexttime < time)
	{
		self.sound_nexttime = time + 7.955812;
		//sound (self.tur_head, CH_TRIGGER_SINGLE, "vehicles/raptor_fly.wav", 1 - ftmp,   ATTEN_NORM );
		sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", 1, ATTEN_NORM);
		self.wait = ftmp;
	}
	/*
	else if(fabs(ftmp - self.wait) > 0.2)
	{
		sound (self.tur_head, CH_TRIGGER_SINGLE, "", 1 - ftmp,   ATTEN_NORM );
		sound (self, CH_TRIGGER_SINGLE, "", ftmp, ATTEN_NORM);
		self.wait = ftmp;
	}
	*/

	if(raptor.deadflag != DEAD_NO)
	{
		self = player;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
		return 1;
	}
	crosshair_trace(player);

	vector vang;
	vang = raptor.angles;
	df = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
	vang_x *= -1;
	df_x *= -1;
	if(df_x > 180)  df_x -= 360;
	if(df_x < -180) df_x += 360;
	if(df_y > 180)  df_y -= 360;
	if(df_y < -180) df_y += 360;

	ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
	if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
	raptor.avelocity_y = bound(-autocvar_g_vehicle_raptor_turnspeed, ftmp + raptor.avelocity_y * 0.9, autocvar_g_vehicle_raptor_turnspeed);

	// Pitch
	ftmp = 0;
	if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_raptor_pitchlimit) ftmp = 5;
	else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_raptor_pitchlimit) ftmp = -20;

	df_x = bound(-autocvar_g_vehicle_raptor_pitchlimit, df_x , autocvar_g_vehicle_raptor_pitchlimit);
	ftmp = vang_x - bound(-autocvar_g_vehicle_raptor_pitchlimit, df_x + ftmp, autocvar_g_vehicle_raptor_pitchlimit);
	raptor.avelocity_x = bound(-autocvar_g_vehicle_raptor_pitchspeed, ftmp + raptor.avelocity_x * 0.9, autocvar_g_vehicle_raptor_pitchspeed);

	raptor.angles_x = anglemods(raptor.angles_x);
	raptor.angles_y = anglemods(raptor.angles_y);
	raptor.angles_z = anglemods(raptor.angles_z);

	if(autocvar_g_vehicle_raptor_movestyle == 1)
		makevectors('0 1 0' * raptor.angles_y);
	else
		makevectors(player.v_angle);

	df = raptor.velocity * -autocvar_g_vehicle_raptor_friction;

	if(player.movement_x != 0)
	{
		if(player.movement_x > 0)
			df += v_forward  * autocvar_g_vehicle_raptor_speed_forward;
		else if(player.movement_x < 0)
			df -= v_forward  * autocvar_g_vehicle_raptor_speed_forward;
	}

	if(player.movement_y != 0)
	{
		if(player.movement_y < 0)
			df -= v_right * autocvar_g_vehicle_raptor_speed_strafe;
		else if(player.movement_y > 0)
			df += v_right * autocvar_g_vehicle_raptor_speed_strafe;

		raptor.angles_z = bound(-30,raptor.angles_z + (player.movement_y / autocvar_g_vehicle_raptor_speed_strafe),30);
	}
	else
	{
		raptor.angles_z *= 0.95;
		if(raptor.angles_z >= -1 && raptor.angles_z <= -1)
			raptor.angles_z = 0;
	}

	if(player.BUTTON_CROUCH)
		df -=   v_up * autocvar_g_vehicle_raptor_speed_down;
	else if (player.BUTTON_JUMP)
		df +=  v_up * autocvar_g_vehicle_raptor_speed_up;

	raptor.velocity  += df * frametime;
	player.velocity = player.movement  = raptor.velocity;
	setorigin(player, raptor.origin + '0 0 32');
	
	player.vehicle_weapon2mode = raptor.vehicle_weapon2mode;

	vector vf, ad;
	// Target lock & predict
	if(autocvar_g_vehicle_raptor_cannon_locktarget == 2)
	{
		if(raptor.gun1.lock_time < time || raptor.gun1.enemy.deadflag)
			raptor.gun1.enemy = world;

		if(trace_ent)
		if(trace_ent.movetype)
		if(trace_ent.takedamage)
		if(!trace_ent.deadflag)
		{
			if(teamplay)
			{
				if(trace_ent.team != player.team)
				{
					raptor.gun1.enemy = trace_ent;
					raptor.gun1.lock_time = time + 5;
				}
			}
			else
			{
				raptor.gun1.enemy = trace_ent;
				raptor.gun1.lock_time = time + 0.5;
			}
		}

		if(raptor.gun1.enemy)
		{
			float distance, impact_time;

			vf = real_origin(raptor.gun1.enemy);
			UpdateAuxiliaryXhair(player, vf, '1 0 0', 1);
			vector _vel = raptor.gun1.enemy.velocity;
			if(raptor.gun1.enemy.movetype == MOVETYPE_WALK)
				_vel_z *= 0.1;

			if(autocvar_g_vehicle_raptor_cannon_predicttarget)
			{
				ad = vf;
				distance = vlen(ad - player.origin);
				impact_time = distance / autocvar_g_vehicle_raptor_cannon_speed;
				ad = vf + _vel * impact_time;
				trace_endpos = ad;
			}
			else
				trace_endpos = vf;
		}
	}
	else if(autocvar_g_vehicle_raptor_cannon_locktarget == 1)
	{

		vehicles_locktarget((1 / autocvar_g_vehicle_raptor_cannon_locking_time) * frametime,
							 (1 / autocvar_g_vehicle_raptor_cannon_locking_releasetime) * frametime,
							 autocvar_g_vehicle_raptor_cannon_locked_time);

		if(self.lock_target != world)
		if(autocvar_g_vehicle_raptor_cannon_predicttarget)
		if(self.lock_strength == 1)
		{
			float i, distance, impact_time;

			vf = real_origin(raptor.lock_target);
			ad = vf;
			for(i = 0; i < 4; ++i)
			{
				distance = vlen(ad - raptor.origin);
				impact_time = distance / autocvar_g_vehicle_raptor_cannon_speed;
				ad = vf + raptor.lock_target.velocity * impact_time;
			}
			trace_endpos = ad;
		}

		if(self.lock_target)
		{
			if(raptor.lock_strength == 1)
				UpdateAuxiliaryXhair(player, real_origin(raptor.lock_target), '1 0 0', 1);
			else if(self.lock_strength > 0.5)
				UpdateAuxiliaryXhair(player, real_origin(raptor.lock_target), '0 1 0', 1);
			else if(self.lock_strength < 0.5)
				UpdateAuxiliaryXhair(player, real_origin(raptor.lock_target), '0 0 1', 1);
		}
	}


	vehicle_aimturret(raptor, trace_endpos, raptor.gun1, "fire1",
						  autocvar_g_vehicle_raptor_cannon_pitchlimit_down * -1,  autocvar_g_vehicle_raptor_cannon_pitchlimit_up,
						  autocvar_g_vehicle_raptor_cannon_turnlimit * -1,  autocvar_g_vehicle_raptor_cannon_turnlimit,  autocvar_g_vehicle_raptor_cannon_turnspeed);

	vehicle_aimturret(raptor, trace_endpos, raptor.gun2, "fire1",
						  autocvar_g_vehicle_raptor_cannon_pitchlimit_down * -1,  autocvar_g_vehicle_raptor_cannon_pitchlimit_up,
						  autocvar_g_vehicle_raptor_cannon_turnlimit * -1,  autocvar_g_vehicle_raptor_cannon_turnlimit,  autocvar_g_vehicle_raptor_cannon_turnspeed);

	/*
	ad = ad * 0.5;
	v_forward = vf * 0.5;
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, raptor);
	UpdateAuxiliaryXhair(player, trace_endpos, '0 1 0', 0);
	*/

	if(player.BUTTON_ATCK)
	if(raptor.attack_finished_single <= time)
	if(raptor.vehicle_energy > autocvar_g_vehicle_raptor_cannon_cost)
	{
		raptor.misc_bulletcounter += 1;
		raptor.attack_finished_single = time + autocvar_g_vehicle_raptor_cannon_refire;
		if(raptor.misc_bulletcounter <= 2)
			raptor_fire_cannon(self.gun1, "fire1");
		else if(raptor.misc_bulletcounter == 3)
			raptor_fire_cannon(self.gun2, "fire1");
		else
		{
			raptor.attack_finished_single = time + autocvar_g_vehicle_raptor_cannon_refire * 2;
			raptor_fire_cannon(self.gun2, "fire1");
			raptor.misc_bulletcounter = 0;
		}
		raptor.vehicle_energy -= autocvar_g_vehicle_raptor_cannon_cost;
		self.cnt = time;
	}

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(raptor.dmg_time, vehicle_shield, autocvar_g_vehicle_raptor_shield, autocvar_g_vehicle_raptor_shield_regen_pause, autocvar_g_vehicle_raptor_shield_regen, frametime, TRUE);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(raptor.dmg_time, vehicle_health, autocvar_g_vehicle_raptor_health, autocvar_g_vehicle_raptor_health_regen_pause, autocvar_g_vehicle_raptor_health_regen, frametime, FALSE);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(raptor.cnt, vehicle_energy, autocvar_g_vehicle_raptor_energy, autocvar_g_vehicle_raptor_energy_regen_pause, autocvar_g_vehicle_raptor_energy_regen, frametime, FALSE);

	if(raptor.vehicle_weapon2mode == RSM_BOMB)
	{
		if(time > raptor.lip + autocvar_g_vehicle_raptor_bombs_refire)
		if(player.BUTTON_ATCK2)
		{
			raptor_bombdrop();
			raptor.delay = time + autocvar_g_vehicle_raptor_bombs_refire;
			raptor.lip   = time;
		}
	}
	else
	{
		if(time > raptor.lip + autocvar_g_vehicle_raptor_flare_refire)
		if(player.BUTTON_ATCK2)
		{
			float i;
			entity _flare;

			for(i = 0; i < 3; ++i)
			{
			_flare = spawn();
			setmodel(_flare, "models/runematch/rune.mdl");
			_flare.effects = EF_LOWPRECISION | EF_FLAME;
			_flare.scale = 0.5;
			setorigin(_flare, self.origin - '0 0 16');
			_flare.movetype = MOVETYPE_TOSS;
			_flare.gravity = 0.15;
			_flare.velocity = 0.25 * raptor.velocity + (v_forward + randomvec() * 0.25)* -500;
			_flare.think = raptor_flare_think;
			_flare.nextthink = time;
			_flare.owner = raptor;
			_flare.solid = SOLID_CORPSE;
			_flare.takedamage = DAMAGE_YES;
			_flare.event_damage = raptor_flare_damage;
			_flare.health = 20;
			_flare.tur_impacttime = time + autocvar_g_vehicle_raptor_flare_lifetime;
			_flare.touch = raptor_flare_touch;
			}
			raptor.delay = time + autocvar_g_vehicle_raptor_flare_refire;
			raptor.lip   = time;
		}
	}

	raptor.bomb1.alpha = raptor.bomb2.alpha = (time - raptor.lip) / (raptor.delay - raptor.lip);
	player.vehicle_reload2 = bound(0, raptor.bomb1.alpha * 100, 100);

	if(self.bomb1.cnt < time)
	{
		entity _missile = findchainentity(enemy, raptor);
		float _incomming = 0;
		while(_missile)
		{
			if(_missile.flags & FL_PROJECTILE)
			if(MISSILE_IS_TRACKING(_missile))
			if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_raptor_flare_range)
				++_incomming;

			_missile = _missile.chain;
		}

		if(_incomming)
			sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTEN_NONE);

		self.bomb1.cnt = time + 1;
	}


	VEHICLE_UPDATE_PLAYER(player, health, raptor);
	VEHICLE_UPDATE_PLAYER(player, energy, raptor);
	if(self.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(player, shield, raptor);

	player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;

	self = player;
	return 1;
}

float raptor_takeoff()
{
	entity player, raptor;

	player = self;
	raptor = self.vehicle;
	self   = raptor;
	
	self.nextthink = time;
	CSQCMODEL_AUTOUPDATE();
	self.nextthink = 0; // will this work?
	
	if(self.sound_nexttime < time)
	{
		self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
		sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
	}

	// Takeoff sequense
	if(raptor.frame < 25)
	{
		raptor.frame += 25 / (autocvar_g_vehicle_raptor_takeofftime / sys_frametime);
		raptor.velocity_z = min(raptor.velocity_z * 1.5, 256);
		self.bomb1.gun1.avelocity_y = 90 + ((raptor.frame / 25) * 25000);
		self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;

		setorigin(player, raptor.origin + '0 0 32');
	}
	else
		player.PlayerPhysplug = raptor_frame;

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(raptor.dmg_time, vehicle_shield, autocvar_g_vehicle_raptor_shield, autocvar_g_vehicle_raptor_shield_regen_pause, autocvar_g_vehicle_raptor_shield_regen, frametime, TRUE);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(raptor.dmg_time, vehicle_health, autocvar_g_vehicle_raptor_health, autocvar_g_vehicle_raptor_health_regen_pause, autocvar_g_vehicle_raptor_health_regen, frametime, FALSE);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(raptor.cnt, vehicle_energy, autocvar_g_vehicle_raptor_energy, autocvar_g_vehicle_raptor_energy_regen_pause, autocvar_g_vehicle_raptor_energy_regen, frametime, FALSE);


	raptor.bomb1.alpha = raptor.bomb2.alpha = (time - raptor.lip) / (raptor.delay - raptor.lip);
	player.vehicle_reload2 = bound(0, raptor.bomb1.alpha * 100, 100);

	VEHICLE_UPDATE_PLAYER(player, health, raptor);
	VEHICLE_UPDATE_PLAYER(player, energy, raptor);
	if(self.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(player, shield, raptor);

	player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
	self = player;
	return 1;
}

void raptor_blowup()
{
	self.deadflag	= DEAD_DEAD;
	self.vehicle_exit(VHEF_NORMAL);
	RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_VH_RAPT_DEATH, world);

	self.alpha		  = -1;
	self.movetype	   = MOVETYPE_NONE;
	self.effects		= EF_NODRAW;
	self.colormod	   = '0 0 0';
	self.avelocity	  = '0 0 0';
	self.velocity	   = '0 0 0';

	setorigin(self, self.pos1);
	self.touch = func_null;
	self.nextthink = 0;
}

void raptor_diethink()
{
	if(time >= self.wait)
		self.think = raptor_blowup;

	if(random() < 0.05)
	{
		sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}
	self.nextthink = time;
	
	CSQCMODEL_AUTOUPDATE();
}

// If we dont do this ever now and then, the raptors rotors
// stop working, presumably due to angle overflow. cute.
void raptor_rotor_anglefix()
{
	self.gun1.angles_y = anglemods(self.gun1.angles_y);
	self.gun2.angles_y = anglemods(self.gun2.angles_y);
	self.nextthink = time + 15;
}

float raptor_impulse(float _imp)
{
	switch(_imp)
	{
		case 10:
		case 15:
		case 18:
			self.vehicle.vehicle_weapon2mode += 1;
			if(self.vehicle.vehicle_weapon2mode > RSM_LAST)
				self.vehicle.vehicle_weapon2mode = RSM_FIRST;

			CSQCVehicleSetup(self, 0);
			return TRUE;
		case 12:
		case 16:
		case 19:
			self.vehicle.vehicle_weapon2mode -= 1;
			if(self.vehicle.vehicle_weapon2mode < RSM_FIRST)
				self.vehicle.vehicle_weapon2mode = RSM_LAST;

			CSQCVehicleSetup(self, 0);
			return TRUE;

		/*
		case 17: // toss gun, could be used to exit?
			break;
		case 20: // Manual minigun reload?
			break;
		*/
	}
	return FALSE;
}

void spawnfunc_vehicle_raptor()
{
	if(!autocvar_g_vehicle_raptor) { remove(self); return; }
	if(!vehicle_initialize(VEH_RAPTOR, FALSE)) { remove(self); return; }
}

float v_raptor(float req)
{
	switch(req)
	{
		case VR_IMPACT:
		{
			if(autocvar_g_vehicle_raptor_bouncepain)
				vehicles_impact(autocvar_g_vehicle_raptor_bouncepain_x, autocvar_g_vehicle_raptor_bouncepain_y, autocvar_g_vehicle_raptor_bouncepain_z);
				
			return TRUE;
		}
		case VR_ENTER:
		{
			self.vehicle_weapon2mode = RSM_BOMB;
			self.owner.PlayerPhysplug = raptor_takeoff;
			self.movetype	   = MOVETYPE_BOUNCEMISSILE;
			self.solid		  = SOLID_SLIDEBOX;
			self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_raptor_health) * 100;
			self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_raptor_shield) * 100;
			self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
			self.tur_head.exteriormodeltoclient = self.owner;

			self.delay = time + autocvar_g_vehicle_raptor_bombs_refire;
			self.lip   = time;

			if(self.owner.flagcarried)
			   setorigin(self.owner.flagcarried, '-20 0 96');

			CSQCVehicleSetup(self.owner, 0);
			return TRUE;
		}
		case VR_THINK:
		{
			return TRUE;
		}
		case VR_DEATH:
		{
			self.health				= 0;
			self.event_damage		= func_null;
			self.solid				= SOLID_CORPSE;
			self.takedamage			= DAMAGE_NO;
			self.deadflag			= DEAD_DYING;
			self.movetype			= MOVETYPE_BOUNCE;
			self.think				= raptor_diethink;
			self.nextthink			= time;
			self.wait				= time + 5 + (random() * 5);

			pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

			self.velocity_z += 600;

			self.avelocity = '0 0.5 1' * (random() * 400);
			self.avelocity -= '0 0.5 1' * (random() * 400);

			self.colormod = '-0.5 -0.5 -0.5';
			self.touch = raptor_blowup;
			return TRUE;
		}
		case VR_SPAWN:
		{
			if(!self.gun1)
			{
				entity spinner;
				vector ofs;

				//FIXME: Camera is in a bad place in HUD model.
				//setorigin(self.vehicle_viewport, '25 0 5');

				self.vehicles_impulse   = raptor_impulse;

				self.frame = 0;

				self.bomb1 = spawn();
				self.bomb2 = spawn();
				self.gun1  = spawn();
				self.gun2  = spawn();

				setmodel(self.bomb1,"models/vehicles/clusterbomb_folded.md3");
				setmodel(self.bomb2,"models/vehicles/clusterbomb_folded.md3");
				setmodel(self.gun1, "models/vehicles/raptor_gun.dpm");
				setmodel(self.gun2, "models/vehicles/raptor_gun.dpm");
				setmodel(self.tur_head, "models/vehicles/raptor_body.dpm");

				setattachment(self.bomb1, self, "bombmount_left");
				setattachment(self.bomb2, self, "bombmount_right");
				setattachment(self.tur_head, self,"root");

				// FIXMODEL Guns mounts to angled bones
				self.bomb1.angles = self.angles;
				self.angles = '0 0 0';
				// This messes up gun-aim, so work arround it.
				//setattachment(self.gun1, self, "gunmount_left");
				ofs = gettaginfo(self, gettagindex(self, "gunmount_left"));
				ofs -= self.origin;
				setattachment(self.gun1, self, "");
				setorigin(self.gun1, ofs);

				//setattachment(self.gun2, self, "gunmount_right");
				ofs = gettaginfo(self, gettagindex(self, "gunmount_right"));
				ofs -= self.origin;
				setattachment(self.gun2, self, "");
				setorigin(self.gun2, ofs);

				self.angles = self.bomb1.angles;
				self.bomb1.angles = '0 0 0';

				spinner = spawn();
				spinner.owner = self;
				setmodel(spinner,"models/vehicles/spinner.dpm");
				setattachment(spinner, self, "engine_left");
				spinner.movetype = MOVETYPE_NOCLIP;
				spinner.avelocity = '0 90 0';
				self.bomb1.gun1 = spinner;

				spinner = spawn();
				spinner.owner = self;
				setmodel(spinner,"models/vehicles/spinner.dpm");
				setattachment(spinner, self, "engine_right");
				spinner.movetype = MOVETYPE_NOCLIP;
				spinner.avelocity = '0 -90 0';
				self.bomb1.gun2 = spinner;

				// Sigh.
				self.bomb1.think = raptor_rotor_anglefix;
				self.bomb1.nextthink = time;

				self.mass			   = 1 ;
			}

			self.frame		  = 0;
			self.vehicle_health = autocvar_g_vehicle_raptor_health;
			self.vehicle_shield = autocvar_g_vehicle_raptor_shield;
			self.movetype	   = MOVETYPE_TOSS;
			self.solid		  = SOLID_SLIDEBOX;
			self.vehicle_energy = 1;
			
			self.PlayerPhysplug = raptor_frame;

			self.bomb1.gun1.avelocity_y = 90;
			self.bomb1.gun2.avelocity_y = -90;
			
			self.delay = time;

			self.bouncefactor = autocvar_g_vehicle_raptor_bouncefactor;
			self.bouncestop = autocvar_g_vehicle_raptor_bouncestop;
			self.damageforcescale = 0.25;
			self.vehicle_health = autocvar_g_vehicle_raptor_health;
			self.vehicle_shield = autocvar_g_vehicle_raptor_shield;
			return TRUE;
		}
		case VR_SETUP:
		{
			if(autocvar_g_vehicle_raptor_shield)
				self.vehicle_flags |= VHF_HASSHIELD;

			if(autocvar_g_vehicle_raptor_shield_regen)
				self.vehicle_flags |= VHF_SHIELDREGEN;

			if(autocvar_g_vehicle_raptor_health_regen)
				self.vehicle_flags |= VHF_HEALTHREGEN;

			if(autocvar_g_vehicle_raptor_energy_regen)
				self.vehicle_flags |= VHF_ENERGYREGEN;
				
			self.vehicle_exit = raptor_exit;
			self.respawntime = autocvar_g_vehicle_raptor_respawntime;
			self.vehicle_health = autocvar_g_vehicle_raptor_health;
			self.vehicle_shield = autocvar_g_vehicle_raptor_shield;
			self.max_health = self.vehicle_health;
				
			return TRUE;
		}
		case VR_PRECACHE:
		{
			precache_model ("models/vehicles/raptor.dpm");
			precache_model ("models/vehicles/raptor_gun.dpm");
			precache_model ("models/vehicles/spinner.dpm");
			precache_model ("models/vehicles/raptor_cockpit.dpm");
			precache_model ("models/vehicles/clusterbomb_folded.md3");
			precache_model ("models/vehicles/raptor_body.dpm");

			precache_sound ("vehicles/raptor_fly.wav");
			precache_sound ("vehicles/raptor_speed.wav");
			precache_sound ("vehicles/missile_alarm.wav");
		
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
#define raptor_ico  "gfx/vehicles/raptor.tga"
#define raptor_gun  "gfx/vehicles/raptor_guns.tga"
#define raptor_bomb "gfx/vehicles/raptor_bombs.tga"
#define raptor_drop "gfx/vehicles/axh-dropcross.tga"

float v_raptor(float req)
{
	switch(req)
	{
		case VR_HUD:
		{
			if(autocvar_r_letterbox)
				return TRUE;

			vector picsize, hudloc = '0 0 0', pic2size, picloc;
			string raptor_xhair;

			// Fetch health & ammo stats
			HUD_GETVEHICLESTATS

			picsize = draw_getimagesize(hud_bg) * autocvar_cl_vehicles_hudscale;
			hudloc_y = vid_conheight - picsize_y;
			hudloc_x = vid_conwidth * 0.5 - picsize_x * 0.5;

			drawpic(hudloc, hud_bg, picsize, '1 1 1', autocvar_cl_vehicles_hudalpha, DRAWFLAG_NORMAL);

			ammo1   *= 0.01;
			ammo2   *= 0.01;
			shield  *= 0.01;
			vh_health  *= 0.01;
			energy  *= 0.01;
			reload1 = reload2 * 0.01;
			//reload2 *= 0.01;

			pic2size = draw_getimagesize(raptor_ico) * (autocvar_cl_vehicles_hudscale * 0.8);
			picloc = picsize * 0.5 - pic2size * 0.5;
			if(vh_health < 0.25)
				drawpic(hudloc + picloc, raptor_ico, pic2size,  '1 0 0' + '0 1 1' * sin(time * 8),  1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, raptor_ico, pic2size,  '1 1 1' * vh_health  + '1 0 0' * (1 - vh_health),  1, DRAWFLAG_NORMAL);
			drawpic(hudloc + picloc, raptor_bomb, pic2size,  '1 1 1' * reload1 + '1 0 0' * (1 - reload1), 1, DRAWFLAG_NORMAL);
			drawpic(hudloc + picloc, raptor_gun, pic2size, '1 1 1' * energy   + '1 0 0' * (1 - energy),   1, DRAWFLAG_NORMAL);
			drawpic(hudloc + picloc, hud_sh, pic2size,  '1 1 1', shield, DRAWFLAG_NORMAL);

		// Health bar
			picsize = draw_getimagesize(hud_hp_bar) * autocvar_cl_vehicles_hudscale;
			picloc = '69 69 0' * autocvar_cl_vehicles_hudscale;
			drawsetcliparea(hudloc_x + picloc_x + (picsize_x * (1 - vh_health)), 0, vid_conwidth, vid_conheight);
			drawpic(hudloc + picloc, hud_hp_bar, picsize, '1 1 1', 1 , DRAWFLAG_NORMAL);
			drawresetcliparea();
		// ..  and icon
			picsize = draw_getimagesize(hud_hp_ico) * autocvar_cl_vehicles_hudscale;
			picloc = '37 65 0' * autocvar_cl_vehicles_hudscale;
			if(vh_health < 0.25)
			{
				if(alarm1time < time)
				{
					alarm1time = time + 2;
					vehicle_alarm(self, CH_PAIN_SINGLE, "vehicles/alarm.wav");
				}

				drawpic(hudloc + picloc, hud_hp_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			}
			else
			{
				drawpic(hudloc + picloc, hud_hp_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
				if(alarm1time)
				{
					vehicle_alarm(self, CH_PAIN_SINGLE, "misc/null.wav");
					alarm1time = 0;
				}
			}

		// Shield bar
			picsize = draw_getimagesize(hud_sh_bar) * autocvar_cl_vehicles_hudscale;
			picloc = '69 140 0' * autocvar_cl_vehicles_hudscale;
			drawsetcliparea(hudloc_x + picloc_x + (picsize_x * (1 - shield)), 0, vid_conwidth, vid_conheight);
			drawpic(hudloc + picloc, hud_sh_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			drawresetcliparea();
		// ..  and icon
			picloc = '40 136 0' * autocvar_cl_vehicles_hudscale;
			picsize = draw_getimagesize(hud_sh_ico) * autocvar_cl_vehicles_hudscale;
			if(shield < 0.25)
			{
				if(alarm2time < time)
				{
					alarm2time = time + 1;
					vehicle_alarm(self, CH_TRIGGER_SINGLE, "vehicles/alarm_shield.wav");
				}
				drawpic(hudloc + picloc, hud_sh_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			}
			else
			{
				drawpic(hudloc + picloc, hud_sh_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
				if(alarm2time)
				{
					vehicle_alarm(self, CH_TRIGGER_SINGLE, "misc/null.wav");
					alarm2time = 0;
				}
			}

		// Gun bar
			picsize = draw_getimagesize(hud_ammo1_bar) * autocvar_cl_vehicles_hudscale;
			picloc = '450 69 0' * autocvar_cl_vehicles_hudscale;
			drawsetcliparea(hudloc_x + picloc_x, picloc_y, picsize_x * energy, vid_conheight);
			drawpic(hudloc + picloc, hud_ammo1_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			drawresetcliparea();
		// ..  and icon
			picsize = draw_getimagesize(hud_ammo1_ico) * autocvar_cl_vehicles_hudscale;
			picloc = '664 60 0' * autocvar_cl_vehicles_hudscale;
			if(energy < 0.2)
				drawpic(hudloc + picloc, hud_ammo1_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, hud_ammo1_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);

		// Bomb bar
			picsize = draw_getimagesize(hud_ammo2_bar) * autocvar_cl_vehicles_hudscale;
			picloc = '450 140 0' * autocvar_cl_vehicles_hudscale;
			drawsetcliparea(hudloc_x + picloc_x, hudloc_y + picloc_y, picsize_x * reload1, vid_conheight);
			drawpic(hudloc + picloc, hud_ammo2_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			drawresetcliparea();
		// ..  and icon
			pic2size = draw_getimagesize(hud_ammo2_ico) * autocvar_cl_vehicles_hudscale;
			picloc = '664 130 0' * autocvar_cl_vehicles_hudscale;
			if(reload1 != 1)
				drawpic(hudloc + picloc, hud_ammo2_ico, pic2size, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, hud_ammo2_ico, pic2size, '1 1 1', 1, DRAWFLAG_NORMAL);

			if(getstati(STAT_VEHICLESTAT_W2MODE) == RSM_FLARE)
			{
				raptor_xhair =  "gfx/vehicles/axh-bracket.tga";
			}
			else
			{
				raptor_xhair =  "gfx/vehicles/axh-ring.tga";

				// Bombing crosshair
				if(!dropmark)
				{
					dropmark = spawn();
					dropmark.owner = self;
					dropmark.gravity = 1;
				}

				if(reload2 == 100)
				{
					vector where;

					setorigin(dropmark, pmove_org);
					dropmark.velocity = pmove_vel;
					tracetoss(dropmark, self);

					where = project_3d_to_2d(trace_endpos);

					setorigin(dropmark, trace_endpos);
					picsize = draw_getimagesize(raptor_drop) * 0.2;

					if(!(where_z < 0 || where_x < 0 || where_y < 0 || where_x > vid_conwidth || where_y > vid_conheight))
					{
						where_x -= picsize_x * 0.5;
						where_y -= picsize_y * 0.5;
						where_z = 0;
						drawpic(where, raptor_drop, picsize, '0 2 0', 1, DRAWFLAG_ADDITIVE);
					}
					dropmark.cnt = time + 5;
				}
				else
				{
					vector where;
					if(dropmark.cnt > time)
					{
						where = project_3d_to_2d(dropmark.origin);
						picsize = draw_getimagesize(raptor_drop) * 0.25;

						if(!(where_z < 0 || where_x < 0 || where_y < 0 || where_x > vid_conwidth || where_y > vid_conheight))
						{
							where_x -= picsize_x * 0.5;
							where_y -= picsize_y * 0.5;
							where_z = 0;
							drawpic(where, raptor_drop, picsize, '2 0 0', 1, DRAWFLAG_ADDITIVE);
						}
					}
				}
			}

			if (scoreboard_showscores)
				HUD_DrawScoreboard();
			else
			{
				picsize = draw_getimagesize(raptor_xhair);
				picsize_x *= 0.5;
				picsize_y *= 0.5;

				drawpic('0.5 0 0' * (vid_conwidth - picsize_x) + '0 0.5 0' * (vid_conheight - picsize_y), raptor_xhair, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			}
			
			return TRUE;
		}
		case VR_SETUP:
		{
			AuxiliaryXhair[0].axh_image   = "gfx/vehicles/axh-special2.tga";
			AuxiliaryXhair[0].axh_scale   = 0.5;
			
			AuxiliaryXhair[1].axh_image = "gfx/vehicles/axh-bracket.tga";
			AuxiliaryXhair[1].axh_scale = 0.25;
			return TRUE;
		}
		case VR_PRECACHE:
		{
			precache_model ("models/vehicles/raptor.dpm");
			precache_model ("models/vehicles/raptor_gun.dpm");
			precache_model ("models/vehicles/spinner.dpm");
			precache_model ("models/vehicles/raptor_cockpit.dpm");
			precache_model ("models/vehicles/clusterbomb_folded.md3");
			precache_model ("models/vehicles/raptor_body.dpm");
			
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_VEHICLE
