#ifndef VEHICLE_TANKLL48
#define VEHICLE_TANKLL48
#ifndef MENUQC
int v_tankll48(int);
#endif
REGISTER_VEHICLE_SIMPLE(
/* VEH_##id   */ TANKLL48,
/* spawnflags */ VHF_DMGSHAKE,
/* mins,maxs  */ '-110 -110 2', '110 110 136',
/* model	  */ "models/vehicles/tankll48.iqm",
/* head_model */ "models/vehicles/tankll48_turret.iqm",
/* hud_model  */ "null",
/* tags	   	  */ "tag_turret", "tag_camera", "",
/* netname	  */ "tankll48",
/* fullname   */ _("LL48 Tank")
) {
    this.m_icon = "vehicle_tank";
#ifndef MENUQC
    this.vehicle_func = v_tankll48;
#endif
}
#endif

#ifdef IMPLEMENTATION
#ifdef SVQC

AUTOCVAR(g_vehicle_tankll48, bool, true, _("Enable LL48 Tank vehicle (if allowed by mods)"));
AUTOCVAR(g_vehicle_tankll48_respawntime, float, 45, "");

AUTOCVAR(g_vehicle_tankll48_blowup_radius, float, 500, "");
AUTOCVAR(g_vehicle_tankll48_blowup_coredamage, float, 500, "");
AUTOCVAR(g_vehicle_tankll48_blowup_edgedamage, float, 100, "");
AUTOCVAR(g_vehicle_tankll48_blowup_forceintensity, float, 600, "");

AUTOCVAR(g_vehicle_tankll48_health, int, 800, "");
AUTOCVAR(g_vehicle_tankll48_health_regen, int, 10, "");
AUTOCVAR(g_vehicle_tankll48_health_regen_pause, float, 5, "");

AUTOCVAR(g_vehicle_tankll48_shield, int, 200, "");
AUTOCVAR(g_vehicle_tankll48_shield_regen, int, 25, "");
AUTOCVAR(g_vehicle_tankll48_shield_regen_pause, float, 0.35, "");

AUTOCVAR(g_vehicle_tankll48_energy, int, 100, "");
AUTOCVAR(g_vehicle_tankll48_energy_regen, int, 10, "");
AUTOCVAR(g_vehicle_tankll48_energy_regen_pause, float, 0.25, "");

AUTOCVAR(g_vehicle_tankll48_turret_turnlimit, float, 90, "");
AUTOCVAR(g_vehicle_tankll48_turret_turnspeed, float, 120, "");

AUTOCVAR(g_vehicle_tankll48_gun_pitchlimit_up, float, 30, "");
AUTOCVAR(g_vehicle_tankll48_gun_pitchlimit_down, float, -20, "");
AUTOCVAR(g_vehicle_tankll48_gun_pitchspeed, float, 50, "");

AUTOCVAR(g_vehicle_tankll48_cannon_radius, float, 350, "");
AUTOCVAR(g_vehicle_tankll48_cannon_force, float, 9, "");
AUTOCVAR(g_vehicle_tankll48_cannon_speed, float, 6000, "");
AUTOCVAR(g_vehicle_tankll48_cannon_spread, float, 0, "");
AUTOCVAR(g_vehicle_tankll48_cannon_speedaccel, float, 6500, "");
AUTOCVAR(g_vehicle_tankll48_cannon_speed_up, float, 0, "");
AUTOCVAR(g_vehicle_tankll48_cannon_damage, float, 120, "");
AUTOCVAR(g_vehicle_tankll48_cannon_damage2, float, 150, "");
AUTOCVAR(g_vehicle_tankll48_cannon_edgedamage, float, 50, "");
AUTOCVAR(g_vehicle_tankll48_cannon_pitchlimit_down, float, 60, "");
AUTOCVAR(g_vehicle_tankll48_cannon_pitchlimit_up, float, 60, "");
AUTOCVAR(g_vehicle_tankll48_cannon_turnlimit_in, float, 20, "");
AUTOCVAR(g_vehicle_tankll48_cannon_turnlimit_out, float, 80, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_cost, int, 200, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_max, int, 200, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_regen, int, 40, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_regen_pause, float, 1, "");
AUTOCVAR(g_vehicle_tankll48_cannon_pitchspeed, float, 50, "");
AUTOCVAR(g_vehicle_tankll48_cannon_turnspeed, float, 110, "");
AUTOCVAR(g_vehicle_tankll48_cannon_turnlimit, float, 90, "");

AUTOCVAR(g_vehicle_tankll48_bouncepain, vector, '0 0 0', "");

AUTOCVAR(g_vehicle_tankll48_movement_inertia, float, 0.15, "");
AUTOCVAR(g_vehicle_tankll48_takeofftime, float, 1.5, "");
AUTOCVAR(g_vehicle_tankll48_speed_stop, float, 50, "");
AUTOCVAR(g_vehicle_tankll48_speed_strafe, float, 400, "");
AUTOCVAR(g_vehicle_tankll48_speed_walk, float, 500, "");
AUTOCVAR(g_vehicle_tankll48_springlength, float, 150, "");
AUTOCVAR(g_vehicle_tankll48_springup, float, 20, "");
AUTOCVAR(g_vehicle_tankll48_springblend, float, 0.1, "");
AUTOCVAR(g_vehicle_tankll48_mass, float, 1000, "");
AUTOCVAR(g_vehicle_tankll48_friction, float, 2, "");
AUTOCVAR(g_vehicle_tankll48_tiltlimit, float, 90, "");
AUTOCVAR(g_vehicle_tankll48_turnspeed, float, 90, "");
AUTOCVAR(g_vehicle_tankll48_turnspeed_strafe, float, 300, "");

AUTOCVAR(g_vehicle_tankll48_head_pitchlimit_up, float, 30, "");
AUTOCVAR(g_vehicle_tankll48_head_pitchlimit_down, float, -20, "");
AUTOCVAR(g_vehicle_tankll48_head_pitchspeed, float, 50, "");
AUTOCVAR(g_vehicle_tankll48_head_turnspeed, float, 110, "");
AUTOCVAR(g_vehicle_tankll48_head_turnlimit, float, 90, "");

void crosshair_trace2(entity pl)
{
	traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, pl, ANTILAG_LATENCY(pl));
}

const vector TANKLL48_MIN_HBF = '-105 -105 2';
const vector TANKLL48_MAX_HBF = '105 105 95';

const vector TANKLL48_MIN_HBB = '-60 -60 2';
const vector TANKLL48_MAX_HBB = '60 60 50';

void tankll48_Grenade_Explode2(void)
{
	if(other.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(other))
			if(DIFF_TEAM(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						Send_Notification(NOTIF_ONE, self.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_AIRSHOT);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	RadiusDamage(self, self.realowner, autocvar_g_vehicle_tankll48_cannon_damage,autocvar_g_vehicle_tankll48_cannon_edgedamage, autocvar_g_vehicle_tankll48_cannon_radius, 
		self.realowner.vehicle, world, autocvar_g_vehicle_tankll48_cannon_force, self.projectiledeathtype, other);

	remove(self);
}

void tankll48_Grenade_Touch2(void)
{
	PROJECTILE_TOUCH;
	self.use();
}

void tankll48_fire_cannon(string tagname)
{
	entity gren;

	W_SetupShot_ProjectileSize(self, '-3 -3 -3', '3 3 3', false, 4, W_Sound("grenade_fire"), CH_WEAPON_A, autocvar_g_vehicle_tankll48_cannon_damage);

	gren = spawn();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = true;
	gren.bot_dodgerating = autocvar_g_vehicle_tankll48_cannon_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = WEP_CVAR(mortar, bouncefactor);
	gren.bouncestop = WEP_CVAR(mortar, bouncestop);
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_MORTAR.m_id | HITTYPE_SECONDARY;
	setorigin(gren, gettaginfo(self.gun2, gettagindex(self.gun2, tagname)));
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + WEP_CVAR_SEC(mortar, lifetime);
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = tankll48_Grenade_Explode2;
	gren.touch = tankll48_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = WEP_CVAR_SEC(mortar, health);
	gren.damageforcescale = WEP_CVAR_SEC(mortar, damageforcescale);
	gren.event_damage = func_null;
	gren.damagedbycontents = true;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjVelocity_Explicit(gren, w_shotdir, v_up, autocvar_g_vehicle_tankll48_cannon_speed, autocvar_g_vehicle_tankll48_cannon_speed_up, 0, autocvar_g_vehicle_tankll48_cannon_spread, false);

	gren.angles = vectoangles(gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, true, PROJECTILE_GRENADE, true);

	MUTATOR_CALLHOOK(EditProjectile, self, gren);
}

void tankll48_shlac(entity gun, entity pilot, entity gunmount)
{
   
	if(pilot.BUTTON_ATCK)
	{
		mg_shlac_fire(gun, pilot, gunmount);
	} else {
	vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_mountedgun_shlac_railgun_ammo_max,
										   autocvar_g_mountedgun_shlac_railgun_ammo_regen_pause,
										   autocvar_g_mountedgun_shlac_railgun_ammo_regen, frametime, false);
	}
}

void tankll48_cannon_explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_vehicle_tankll48_cannon_damage, autocvar_g_vehicle_tankll48_cannon_edgedamage, autocvar_g_vehicle_tankll48_cannon_radius, 
					world, world, autocvar_g_vehicle_tankll48_cannon_force, self.projectiledeathtype, other);

	remove (self);
}

void tankll48_cannon_touch()
{
	if(WarpZone_Projectile_Touch())
		if(wasfreed(self))
			return;

	//if(other.solid != SOLID_BSP)
	//	  return;

	tankll48_cannon_explode();
}

void tankll48_cannon_think()
{
	if(self.cnt <= time)
	{
		remove(self);
		return;
	}

	self.cnt = vlen(self.velocity);
	self.wait = self.cnt * sys_frametime;
	self.pos1 = normalize(self.velocity);

	tracebox(self.origin, self.mins, self.maxs, self.origin + self.pos1 * (2 * self.wait), MOVE_NORMAL, self);
	if(IS_PLAYER(trace_ent))
		Damage (trace_ent, self, self.realowner, autocvar_g_vehicle_tankll48_cannon_damage2, self.projectiledeathtype, self.origin, normalize(self.origin - other.origin) * autocvar_g_vehicle_tankll48_cannon_force);

	self.velocity = self.pos1 * (self.cnt + (autocvar_g_vehicle_tankll48_cannon_speedaccel * sys_frametime));

	UpdateCSQCProjectile(self);
	self.nextthink = time;
}

float tankll48_frame()
{
	vector ad, vf;
	entity player, tankll48;
	float ftmp;

	if(intermission_running)
	{
		self.vehicle.velocity = '0 0 0';
		self.vehicle.avelocity = '0 0 0';
		return 1;
	}
		
	player = self;
	tankll48 = self.vehicle;
	self   = tankll48;

	vehicles_painframe();
	
	player.BUTTON_ZOOM      = 0;
	//player.BUTTON_CROUCH    = 0;
	player.switchweapon     = 0;

	ad = gettaginfo(tankll48.gun3, gettagindex(tankll48.gun3, "tag_mgun"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll48);
	
	vf = ad;
	ad = gettaginfo(tankll48.gun2, gettagindex(tankll48.gun2, "tag_cannon"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll48);
	UpdateAuxiliaryXhair(player, trace_endpos, '1 0 0', 1);
	//ad = 0.5 * (ad + vf);
	ad = vf;
	
	crosshair_trace2(player);
	ad = vectoangles(normalize(trace_endpos - ad));
	ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll48.angles), AnglesTransform_FromAngles(ad))) - tankll48.gun3.angles;
	ad = AnglesTransform_Normalize(ad, TRUE);
	
	//Make sure angles are fine
	//if(tankll48.tur_head.angles_y > 180)  tankll48.tur_head.angles_y -= 360; if(tankll48.tur_head.angles_y < -180) tankll48.tur_head.angles_y += 360;
	
 
	//Rotate Turret and stabilizing "gun3" (rotates faster than turret)
	ftmp = autocvar_g_vehicle_tankll48_turret_turnspeed * sys_frametime;    
	ad_y = bound(-ftmp, ad_y, ftmp);
	tankll48.gun3.angles_y = bound(autocvar_g_vehicle_tankll48_turret_turnlimit * -1, tankll48.gun3.angles_y + ad_y, autocvar_g_vehicle_tankll48_turret_turnlimit);
	tankll48.tur_head.angles_y = tankll48.gun3.angles_y;

	/////////////////////////
	//Stuff for actual mgun
	ad = gettaginfo(tankll48.gun1, gettagindex(tankll48.gun1, "tag_mgun"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll48);
	UpdateAuxiliaryXhair(player, trace_endpos, '1 0.25 0', 0);
	
	crosshair_trace2(player);
	ad = vectoangles(normalize(trace_endpos - ad));
	ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll48.angles), AnglesTransform_FromAngles(ad))) - tankll48.gun1.angles;
	ad = AnglesTransform_Normalize(ad, TRUE);
	
	//ftmp = autocvar_g_vehicle_tankll48_gun_turnspeed * sys_frametime;    
	//ad_y = bound(-ftmp, ad_y, ftmp);
	//tankll48.gun1.angles_y = bound(autocvar_g_vehicle_tankll48_gun_turnlimit * -1, tankll48.gun1.angles_y + ad_y, autocvar_g_vehicle_tankll48_gun_turnlimit);

	
	// Pitch head
	ftmp = autocvar_g_vehicle_tankll48_gun_pitchspeed * sys_frametime;    
	ad_x = bound(ftmp * -1, ad_x, ftmp);
	tankll48.gun1.angles_x = bound(autocvar_g_vehicle_tankll48_gun_pitchlimit_down, tankll48.gun1.angles_x + ad_x, autocvar_g_vehicle_tankll48_gun_pitchlimit_up);


	//fixedmakevectors(tankll48.angles);
	makevectors(tankll48.angles + '-2 0 0' * tankll48.angles_x);
	
	movelib_groundalign4point(autocvar_g_vehicle_tankll48_springlength, autocvar_g_vehicle_tankll48_springup, autocvar_g_vehicle_tankll48_springblend, autocvar_g_vehicle_tankll48_tiltlimit);

	if(tankll48.flags & FL_ONGROUND)
	{
		  makevectors(player.v_angle);

		if(vlen(player.movement) == 0)
		{
				if(self.sound_nexttime < time || self.delay != 3)
				{                        
					self.delay = 3;
					self.sound_nexttime = time + 6.0009; //soundlength("machines/generator_loop_pitchdown.ogg");
					//dprint("tankll48_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
					sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
				}                
				movelib_beak_simple(autocvar_g_vehicle_tankll48_speed_stop);
				//tankll48.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
		}
	
		if(player.movement_y != 0)
	 {
		if(tankll48.angles_y > 180)  tankll48.angles_y -= 360;
			if(tankll48.angles_y < -180) tankll48.angles_y += 360;
		tankll48.angles_y = bound(-184,tankll48.angles_y + ((player.movement_y * sys_frametime) / -6.66666),184);	
		
		if(tankll48.angles_y >= -1 && tankll48.angles_y <= -1)
					tankll48.angles_y = 0;	
		
		//Unlike the T27 tank, we do it alittle more complex way so the turret can 
		//be independent somewhat
		float degree_y;
		player.angles_y = player.angles_y + ((player.movement_y * sys_frametime) / -6.66666);
		degree_y = ((player.movement_y * sys_frametime) / -6.66666);
		player.v_angle_y += degree_y;
		
		////player.v_angle_y = tankll48.angles_y; //kiss //T27

		if ((clienttype(player) == CLIENTTYPE_REAL)) {
			msg_entity = player;
			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
			WriteAngle( MSG_ONE, player.v_angle_x);
			WriteAngle( MSG_ONE, player.v_angle_y);
			WriteAngle( MSG_ONE, player.v_angle_z);
		}
		
		////////player.angles_y = player.angles_y + (player.movement_y / -200);
		////////player.fixangle = TRUE;
		
		//////msg_entity = player;
		//////WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
		//////WriteAngle( MSG_ONE, tankll48.angles_x); 
		//////WriteAngle( MSG_ONE, tankll48.angles_y);
		//////WriteAngle( MSG_ONE, tankll48.angles_z);
		if (player.movement_y > 0) {
			self.bomb1.gun1.avelocity_y = 75; //gear
					self.bomb1.gun2.avelocity_y = 90; //wheel
					self.bomb2.gun1.avelocity_y = -75; //gear
					self.bomb2.gun2.avelocity_y = -90; //wheel
		} else {
			self.bomb1.gun1.avelocity_y = -75; //gear
					self.bomb1.gun2.avelocity_y = -90; //wheel
					self.bomb2.gun1.avelocity_y = 75; //gear
					self.bomb2.gun2.avelocity_y = 90; //wheel
		}
	 }
	 
	 if(player.movement_x != 0)
		 {
					if(player.movement_x > 0)
					{
						player.movement_x = 1;
						tankll48.frame = 0;
					}
					else if(player.movement_x < 0)
					{
						player.movement_x = -1;
						tankll48.frame = 1;
					}
			
			self.bomb1.gun1.avelocity_y = 75 * player.movement_x; //gear
					self.bomb1.gun2.avelocity_y = 90 * player.movement_x; //wheel
					self.bomb2.gun1.avelocity_y = 75 * player.movement_x; //gear
					self.bomb2.gun2.avelocity_y = 90 * player.movement_x; //wheel
			
					player.movement_y = 0;
			
			//fixedmakevectors(tankll48.angles);
				makevectors(tankll48.angles + '-2 0 0' * tankll48.angles_x);
	
					movelib_move_simple(normalize(v_forward * player.movement_x),autocvar_g_vehicle_tankll48_speed_walk,autocvar_g_vehicle_tankll48_movement_inertia);

					if(self.sound_nexttime < time || self.delay != 1)
					{                        
						self.delay = 1;
						self.sound_nexttime = time + 3.991; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
						sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
						//dprint("tankll48_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
					}
		  
	 } else {
		//If we are not moving forward or backwards we should stop
		//Otherwise we "drift" while turn buttons are pressed, like on ice
		movelib_beak_simple(autocvar_g_vehicle_tankll48_speed_stop);
	 }
	}
	
	self.angles_x = bound(-autocvar_g_vehicle_tankll48_tiltlimit, self.angles_x, autocvar_g_vehicle_tankll48_tiltlimit);
	self.angles_z = bound(-autocvar_g_vehicle_tankll48_tiltlimit, self.angles_z, autocvar_g_vehicle_tankll48_tiltlimit);

	if(player.BUTTON_JUMP) {
		tankll48.gun2.angles_x = bound(autocvar_g_vehicle_tankll48_cannon_pitchlimit_down, tankll48.gun2.angles_x + (autocvar_g_vehicle_tankll48_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll48_cannon_pitchlimit_up);
	}
	
	if(player.BUTTON_CROUCH ) {
		tankll48.gun2.angles_x = bound(autocvar_g_vehicle_tankll48_cannon_pitchlimit_down, tankll48.gun2.angles_x - (autocvar_g_vehicle_tankll48_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll48_cannon_pitchlimit_up);
	}
	
	player.BUTTON_CROUCH    = 0;
	
	tankll48_shlac(tankll48, player, tankll48.gun1);
	
	if(!forbidWeaponUse(player))
	if(player.BUTTON_ATCK2 && tankll48.vehicle_ammo2 >= autocvar_g_vehicle_tankll48_cannon_ammo_cost && tankll48.tur_head.attack_finished_single <= time)
	{
		tankll48.count = time;
		entity missile = spawn();
		vector v = gettaginfo(tankll48.gun2, gettagindex(tankll48.gun2, "tag_cannon"));
		W_SetupShot_ProjectileSize (player, '-3 -3 -3', '3 3 3', false, 5, W_Sound("campingrifle_fire_morebass"), CH_WEAPON_A, autocvar_g_vehicle_tankll48_cannon_damage);
		tankll48.vehicle_ammo2 -= autocvar_g_vehicle_tankll48_cannon_ammo_cost;
		
		v_forward = normalize(v_forward);
		v += v_forward * 12;
		w_shotorg = v;

		Send_Effect(EFFECT_ROCKET_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);
		PROJECTILE_MAKETRIGGER(missile);

		missile.owner = tankll48;
		missile.realowner = player;
		missile.bot_dodge = TRUE;
		missile.bot_dodgerating = autocvar_g_vehicle_tankll48_cannon_damage * 2;

		missile.takedamage = DAMAGE_NO;
		missile.event_damage = func_null;
		missile.damagedbycontents = TRUE;
		missile.movetype = MOVETYPE_FLY;

		missile.projectiledeathtype = DEATH_VH_SPID_DEATH;
		setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

		setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
		//W_SetupProjectileVelocity(missile, autocvar_g_vehicle_tankll48_cannon_speed, 0);
		//W_SetupProjectileVelocityEx(missile, w_shotdir, v_up, autocvar_g_vehicle_tankll48_cannon_speed, 0, 0, 0, false);
		missile.movetype = MOVETYPE_BOUNCEMISSILE;
		missile.velocity = w_shotdir * autocvar_g_vehicle_tankll48_cannon_speed;
		missile.velocity = W_CalculateProjectileVelocity(missile.realowner.velocity, missile.velocity, true);

		missile.touch = tankll48_cannon_touch;

		missile.think = tankll48_cannon_think;
		missile.cnt = time + 15;
		missile.nextthink = time;
		missile.flags = FL_PROJECTILE;
		missile.pos1 = missile.velocity;
			
		CSQCProjectile(missile, true, PROJECTILE_CANNONBALL, false);
	}
	else
		vehicles_regen(tankll48.count, vehicle_ammo2, autocvar_g_vehicle_tankll48_cannon_ammo_max,
										   autocvar_g_vehicle_tankll48_cannon_ammo_regen_pause,
										   autocvar_g_vehicle_tankll48_cannon_ammo_regen, frametime, false);
	
	
	//tankll48_rocket_do();

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(tankll48.dmg_time, vehicle_shield, autocvar_g_vehicle_tankll48_shield, autocvar_g_vehicle_tankll48_shield_regen_pause, autocvar_g_vehicle_tankll48_shield_regen, frametime, true);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(tankll48.dmg_time, vehicle_health, autocvar_g_vehicle_tankll48_health, autocvar_g_vehicle_tankll48_health_regen_pause, autocvar_g_vehicle_tankll48_health_regen, frametime, false);

	player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
	//player.vehicle_ammo2 = tankll48.tur_head.frame;

	if(tankll48.gun2.cnt <= time)
		player.vehicle_reload2 = 100;
	else
		player.vehicle_reload2 = 100 - ((tankll48.gun2.cnt - time) / tankll48.attack_finished_single) * 100;

	setorigin(player, tankll48.origin + '0 0 1' * VEH_TANKLL48.maxs_z);
	player.velocity = tankll48.velocity;

	VEHICLE_UPDATE_PLAYER(player, health, tankll48);

	if(self.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(player, shield, tankll48);


	//Gun3 is out invisible angle stabilizer/reducer
	//tur_head gets its value from it above, so we act on it here
	//print(sprintf("m1 = %f\n", tankll48.gun3.angles_y));
	if(tankll48.gun3.angles_y > 180)
	{
		//print("here 1\n");
		tankll48.gun3.angles_y = tankll48.gun3.angles_y - 360;
	//print(sprintf("m2 = %f\n", tankll48.gun3.angles_y));
	}
	else if(tankll48.gun3.angles_y < -180)
	{
		//print("here 2\n");
		tankll48.gun3.angles_y = tankll48.gun3.angles_y + 360;
		//print(sprintf("m2 = %f\n", tankll48.gun3.angles_y));
	}

	player.vehicle_ammo1 = (tankll48.vehicle_ammo1 / autocvar_g_vehicle_tankll48_cannon_ammo_max) * 100;
	player.vehicle_ammo2 = (tankll48.vehicle_ammo2 / autocvar_g_vehicle_tankll48_cannon_ammo_max) * 100;

	self = player;
	return 1;    
}

void tankll48_think()
{
	if(self.flags & FL_ONGROUND)
		movelib_beak_simple(autocvar_g_vehicle_tankll48_speed_stop);

	self.nextthink = time;

	CSQCMODEL_AUTOUPDATE();
}

void tankll48_exit(float eject)
{
	vector spot;

	self.think = vehicles_think;
	self.nextthink = time;
	self.frame = 5;
	self.movetype = MOVETYPE_WALK;

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
		if(vlen(self.velocity) > autocvar_g_vehicle_tankll48_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 64';
			spot = vehicles_findgoodexit(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 256 + '0 0 64';
			spot = vehicles_findgoodexit(spot);
		}
		self.owner.oldvelocity = self.owner.velocity;
		setorigin(self.owner , spot);
	}

	antilag_clear(self.owner);
	self.owner = world;
}

void tankll48_headfade()
{
	self.think = tankll48_headfade;
	self.nextthink = self.fade_time;
	self.alpha = 1 - (time - self.fade_time) * self.fade_rate;

	if(self.cnt < time || self.alpha < 0.1)
	{
		if(self.alpha > 0.1)
		{
			sound (self, CH_SHOTS, W_Sound("rocket_impact"), VOL_BASE, ATTEN_NORM);
			Send_Effect(EFFECT_EXPLOSION_BIG, self.origin + '0 0 100', '0 0 0', 1);
		}
		remove(self);
	}
}

void tankll48_blowup()
{
	if(self.cnt > time)
	{
		if(random() < 0.1)
		{
			sound (self, CH_SHOTS, W_Sound("rocket_impact"), VOL_BASE, ATTEN_NORM);
			Send_Effect(EFFECT_EXPLOSION_SMALL, randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
		}
		self.nextthink = time + 0.1;
		return;
	}
	
	entity h, g1, g2, b;
	b = spawn();
	h = spawn();
	g1 = spawn();
	g2 = spawn();

	setmodel(b,  "models/vehicles/tankll48.iqm");
	setmodel(h,  "models/vehicles/tankll48_turret.iqm");
	setmodel(g1, "models/vehicles/tankll48_cannon.iqm");
	setmodel(g2, "models/vehicles/tankt27_gear.iqm");

	setorigin(b, self.origin);
	b.frame         = 11;
	b.angles        = self.angles;
	setsize(b, self.mins, self.maxs);

	setorigin(h, gettaginfo(self, gettagindex(self, "tag_head")));
	h.movetype      = MOVETYPE_BOUNCE;
	h.solid         = SOLID_BBOX;
	h.velocity      = v_up * (500 + random() * 500) + randomvec() * 128;
	h.modelflags    = MF_ROCKET;
	h.effects       = EF_FLAME | EF_LOWPRECISION;
	h.avelocity     = randomvec() * 360;

	h.alpha         = 1;
	h.cnt           = time + (3.5 * random());
	h.fade_rate     = 1 / min(autocvar_g_vehicle_tankll48_respawntime, 10);
	h.fade_time     = time;
	h.think         = tankll48_headfade;
	h.nextthink     = time;

	setorigin(g1, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint01")));
	g1.movetype     = MOVETYPE_TOSS;
	g1.solid        = SOLID_CORPSE;
	g1.velocity     = v_forward * 700 + (randomvec() * 32);
	g1.avelocity    = randomvec() * 180;

	setorigin(g2, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint02")));
	g2.movetype     = MOVETYPE_TOSS;
	g2.solid        = SOLID_CORPSE;
	g2.velocity     = v_forward * 700 + (randomvec() * 32);
	g2.avelocity    = randomvec() * 180;

	h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

	SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_tankll48_respawntime, 1));
	//SUB_SetFade(h,  time, min(autocvar_g_vehicle_tankll48_respawntime, 10));
	SUB_SetFade(g1, time, min(autocvar_g_vehicle_tankll48_respawntime, 10));
	SUB_SetFade(g2, time, min(autocvar_g_vehicle_tankll48_respawntime, 10));

	RadiusDamage (self, self.enemy, 250, 15, 250, world, world, 250, DEATH_VH_SPID_DEATH, world);

	self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = -1;
	self.movetype   = MOVETYPE_NONE;
	self.deadflag   = DEAD_DEAD;
	self.solid      = SOLID_NOT;
	self.tur_head.effects  &= ~EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void spawnfunc_vehicle_tankll48()
{
	if(!autocvar_g_vehicle_tankll48) { remove(self); return; }
	if(!vehicle_initialize(VEH_TANKLL48, false)) { remove(self); return; }
}

float v_tankll48(float req)
{
	switch(req)
	{
		case VR_IMPACT:
		{
			if(autocvar_g_vehicle_tankll48_bouncepain)
				vehicles_impact(autocvar_g_vehicle_tankll48_bouncepain_x, autocvar_g_vehicle_tankll48_bouncepain_y, autocvar_g_vehicle_tankll48_bouncepain_z);
		
			return true;
		}
		case VR_ENTER:
		{
			self.movetype = MOVETYPE_WALK;
			CSQCVehicleSetup(self.owner, 0);
			self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_tankll48_health) * 100;
			self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_tankll48_shield) * 100;

			//self.gun1.colormod = self.gun2.colormod = self.bomb1.gun1.colormod = self.bomb1.gun2.colormod = self.bomb2.gun1.colormod = self.bomb2.gun2.colormod = self.colormod;

			if(self.owner.flagcarried)
			{
				setattachment(self.owner.flagcarried, self.tur_head, "");
				setorigin(self.owner.flagcarried, '-20 0 120');
			}
		
			return true;
		}
		case VR_THINK:
		{
			if(self.flags & FL_ONGROUND)
				movelib_beak_simple(autocvar_g_vehicle_tankll48_speed_stop);
			
			return true;
		}
		case VR_DEATH:
		{
			self.health				= 0;
			self.event_damage		= func_null;
			self.takedamage			= DAMAGE_NO;
			self.touch				= func_null;
			self.cnt				= 3.4 + time + random() * 2;
			self.think				= tankll48_blowup;
			self.nextthink			= time;
			self.deadflag			= DEAD_DYING;
			self.frame				= 5;
			self.tur_head.effects  |= EF_FLAME;
			self.colormod			= self.tur_head.colormod = '-1 -1 -1';
			self.frame				= 10;
			self.movetype			= MOVETYPE_TOSS;
			tankt27_hitbox_die(self.hitboxft);
			tankt27_hitbox_die(self.hitboxbk);
			
			CSQCModel_UnlinkEntity(); // networking the death scene would be a nightmare

			return true;
		}
		case VR_SPAWN:
		{
			if(!self.gun1)
			{
				entity spinner;
			self.bomb1 = spawn();
				self.bomb2 = spawn();
			
			//Turret Rotation stabilizer
			self.gun3 = spawn(); //Will be an angle stabilizer for the rotating turret
			self.gun3.alpha = -1;
			setmodel(self.gun3, "models/vehicles/anglestabilizer.iqm");
			setattachment(self.gun3, self.tur_head, "tag_cannon_pivot");
			
			
				self.gun1               = spawn();
				self.gun2               = spawn();    
				setmodel(self.gun1, "models/mountedguns/shlacgun.iqm");
				setmodel(self.gun2, "models/vehicles/tankll48_cannon.iqm");
				setattachment(self.gun1, self.tur_head, "tag_gunpivot2");
				setattachment(self.gun2, self.tur_head, "tag_cannon_pivot");
				self.gravity            = 2;
				self.mass               = 5000;
				self.gun1.colormod = self.colormod;
				self.gun2.colormod = self.colormod;
			
			spinner = spawn();
				spinner.owner = self;
				setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
				setattachment(spinner, self, "tag_gear_left");
				spinner.movetype = MOVETYPE_NOCLIP;
				spinner.avelocity = '0 90 0';
				spinner.colormod = self.colormod;
				self.bomb1.gun1 = spinner;
			
			spinner = spawn();
				spinner.owner = self;
				setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
				setattachment(spinner, self, "tag_wheel_left");
				spinner.movetype = MOVETYPE_NOCLIP;
				spinner.avelocity = '0 90 0';
				spinner.colormod = self.colormod;
				self.bomb1.gun2 = spinner;
			
			spinner = spawn();
				spinner.owner = self;
				setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
				setattachment(spinner, self, "tag_gear_right");
				spinner.movetype = MOVETYPE_NOCLIP;
				spinner.avelocity = '0 90 0';
				spinner.colormod = self.colormod;
				self.bomb2.gun1 = spinner;
			
			spinner = spawn();
				spinner.owner = self;
				setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
				setattachment(spinner, self, "tag_wheel_right");
				spinner.movetype = MOVETYPE_NOCLIP;
				spinner.avelocity = '0 90 0';
				spinner.colormod = self.colormod;
				self.bomb2.gun2 = spinner;
			
			// Sigh.
				self.bomb1.think = raptor_rotor_anglefix;
				self.bomb1.nextthink = time;
			
			setattachment(self.vehicle_hudmodel, self, "");
				//setattachment(self.vehicle_viewport, self.gun1, "tag_gcamera");
			setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
			
			self.gun1.colormap = self.colormap;
			self.hitboxft = spawn();
				self.hitboxbk = spawn();
			}

			self.frame = 5;
			self.tur_head.frame = 1;
			self.movetype = MOVETYPE_WALK;
			self.solid = SOLID_SLIDEBOX;
			self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = 1;
			self.gun2.colormap = self.bomb1.gun1.colormap = self.bomb1.gun2.colormap = self.bomb2.gun1.colormap = self.bomb2.gun2.colormap = self.colormap;
			self.tur_head.angles = '0 0 0';
			self.vehicle_exit = tankll48_exit;

			self.bomb1.gun1.avelocity_y = 0;
			self.bomb1.gun2.avelocity_y = 0;
			self.bomb2.gun1.avelocity_y = 0;
			self.bomb2.gun2.avelocity_y = 0;

			setorigin(self, self.pos1 + '0 0 128');
			self.angles = self.pos2;
			self.damageforcescale = 0.03;
			self.vehicle_health = autocvar_g_vehicle_tankll48_health;
			self.vehicle_shield = autocvar_g_vehicle_tankll48_shield;
			
			self.PlayerPhysplug = tankll48_frame;

			tankt27_spawn_hitbox(0, self, self.hitboxft, TANKLL48_MIN_HBF, TANKLL48_MAX_HBF, 95, autocvar_g_vehicle_tankll48_health);
			tankt27_spawn_hitbox(1, self, self.hitboxbk, TANKLL48_MIN_HBB, TANKLL48_MAX_HBB, -120, autocvar_g_vehicle_tankll48_health * 0.5);

			return true;
		}
		case VR_SETUP:
		{
			if(autocvar_g_vehicle_tankll48_shield)
				self.vehicle_flags |= VHF_HASSHIELD;

			if(autocvar_g_vehicle_tankll48_shield_regen)
				self.vehicle_flags |= VHF_SHIELDREGEN;

			if(autocvar_g_vehicle_tankll48_health_regen)
				self.vehicle_flags |= VHF_HEALTHREGEN;

			self.respawntime = autocvar_g_vehicle_tankll48_respawntime;
			self.vehicle_health = autocvar_g_vehicle_tankll48_health;
			self.vehicle_shield = autocvar_g_vehicle_tankll48_shield;
			self.max_health = self.vehicle_health;
			//self.pushable = true; // tankll48 can use jumppads

			return true;
		}
		case VR_PRECACHE:
		{
			precache_sound (W_Sound("uzi_fire"));
			precache_sound (W_Sound("lasergun_fire"));
			precache_sound (W_Sound("grenade_fire"));
			//precache_sound (W_Sound("campingrifle_fire"));
			precache_sound (W_Sound("campingrifle_fire_morebass"));
			precache_sound (W_Sound("rocket_impact"));

			precache_model ( "models/vhshield.md3");
			precache_model ( "models/sphere/sphexp.md3");
			precache_model ( "models/vehicles/tankll48.iqm");
			
			precache_model ( "models/vehicles/tankll48_turret.iqm");
			precache_model ( "models/vehicles/tankt27_wheel.iqm");
			precache_model ( "models/vehicles/tankt27_gear.iqm");
			precache_model ( "models/vehicles/tankll48_cannon.iqm");
			precache_model ( "models/vehicles/anglestabilizer.iqm");
			precache_model ( "models/mountedguns/shlacgun.iqm");
			precache_model ( "models/uziflash.md3");

			//precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
			
			precache_sound ( "vehicles/tankll48_die.wav");
			precache_sound ( "machines/generator_loop_pitchdown.ogg");
			precache_sound ( "vehicles/tankll48_jump.wav");
			precache_sound ( "vehicles/tankll48_strafe.wav");
			precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
			precache_sound ( "vehicles/tankll48_land.wav");
			precache_sound ( "object/impact_metal_3.ogg");
			precache_sound ( "object/impact_metal_4.ogg");
			return true;
		}
	}

	return true;
}

#endif // SVQC
#ifdef CSQC
AUTOCVAR_SAVE(cl_vehicle_tankll48_cross_alpha,                    float,   0.7,      "");
AUTOCVAR_SAVE(cl_vehicle_tankll48_cross_size,                     float,   1,        "");

float v_tankll48(float req)
{
	switch(req)
	{
		case VR_HUD:
		{
			Vehicles_drawHUD("vehicle_tank", "vehicle_tank_weapon1", "vehicle_tank_weapon2",
							 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
							 "vehicle_icon_ammo2", autocvar_hud_progressbar_vehicles_ammo2_color,
							 vCROSS_BURST);
			if(!autocvar_r_letterbox)
			if(!scoreboard_showscores)
			if(!autocvar_chase_active)
			{
				// custom crosshair
				vector tmpSize  = draw_getimagesize(vCROSS_TANK2) * autocvar_cl_vehicles_crosshair_size;
				vector tmpPos = '0 0 0';
				tmpPos.x = (vid_conwidth - tmpSize.x) / 2;
				tmpPos.y = (vid_conheight - tmpSize.y) / 2;

				drawpic(tmpPos, vCROSS_TANK2, tmpSize, '0 0 1', autocvar_crosshair_alpha * 0.5, DRAWFLAG_NORMAL);
			}
			return true;
		}
		case VR_SETUP:
		{
			AuxiliaryXhair[0].axh_image = vCROSS_HINT; // gun
			AuxiliaryXhair[1].axh_image = vCROSS_LOCK; // cannon?
			AuxiliaryXhair[2].axh_image = vCROSS_BURST; // cannon?
			return true;
		}
		case VR_PRECACHE:
		{
			return true;
		}
	}

	return true;
}

#endif // CSQC
#endif // REGISTER_VEHICLE
