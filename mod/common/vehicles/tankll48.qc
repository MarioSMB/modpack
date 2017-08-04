#ifndef IMPLEMENTATION
//#include "tankll48.qh"

//#include "tankll48_weapons.qc"

SOUND(TANK_MOVE, "machines/generator_loop_speedup_pitchdown");
SOUND(TANK_IDLE, "machines/generator_loop_pitchdown");
SOUND(TANK_FIRE, W_Sound("campingrifle_fire_morebass"));

MODEL(TANKLL48_CANNON, "models/vehicles/tankll48_cannon.iqm");
MODEL(TANKT27_GEAR, "models/vehicles/tankt27_gear.iqm");
MODEL(TANKT27_WHEEL, "models/vehicles/tankt27_wheel.iqm");

MODEL(MG_SHLACGUN, "models/mountedguns/shlacgun.iqm");

MODEL(TANK_ANGLESTABILIZER, "models/vehicles/anglestabilizer.iqm");

CLASS(TankLL48, Vehicle)
/* spawnflags */ ATTRIB(TankLL48, spawnflags, int, VHF_DMGSHAKE);
/* mins       */ ATTRIB(TankLL48, m_mins, vector, '-110 -110 2');
/* maxs       */ ATTRIB(TankLL48, m_maxs, vector, '110 110 136');
/* view offset*/ ATTRIB(TankLL48, view_ofs, vector, '0 0 150');
/* view dist  */ ATTRIB(TankLL48, height, float, 300);
/* model	  */ ATTRIB(TankLL48, mdl, string, "models/vehicles/tankll48.iqm");
/* model	  */ ATTRIB(TankLL48, model, string, "models/vehicles/tankll48.iqm");
/* head_model */ ATTRIB(TankLL48, head_model, string, "models/vehicles/tankll48_turret.iqm");
/* hud_model  */ ATTRIB(TankLL48, hud_model, string, "null");
/* tags       */ ATTRIB(TankLL48, tag_head, string, "tag_turret");
/* tags       */ ATTRIB(TankLL48, tag_hud, string, "tag_camera");
/* tags       */ ATTRIB(TankLL48, tag_view, string, "");
/* netname    */ ATTRIB(TankLL48, netname, string, "tankll48");
/* fullname   */ ATTRIB(TankLL48, vehicle_name, string, _("LL48 Tank"));
/* icon       */ ATTRIB(TankLL48, m_icon, string, "vehicle_tank");
ENDCLASS(TankLL48)
REGISTER_VEHICLE(TANKLL48, NEW(TankLL48));

int PROJECTILE_CANNONBALL;

STATIC_INIT(CannonballProjectile) { PROJECTILE_CANNONBALL = MOD_PROJECTILES++; }

#endif

#ifdef IMPLEMENTATION

//#include "tankll48_weapons.qc"

#ifdef SVQC

.entity hitboxft, hitboxbk;

AUTOCVAR(g_vehicle_tankll48, bool, false, _("Enable LL48 Tank vehicle (if allowed by mods)"));
AUTOCVAR(g_vehicle_tankll48_respawntime, float, 45, "");

//(g_vehicle_tankll48_blowup_radius, float, 500, "");
//AUTOCVAR(g_vehicle_tankll48_blowup_coredamage, float, 500, "");
//(g_vehicle_tankll48_blowup_edgedamage, float, 100, "");
//AUTOCVAR(g_vehicle_tankll48_blowup_forceintensity, float, 600, "");

AUTOCVAR(g_vehicle_tankll48_health, int, 5000, "");
AUTOCVAR(g_vehicle_tankll48_health_regen, int, 10, "");
AUTOCVAR(g_vehicle_tankll48_health_regen_pause, float, 5, "");

AUTOCVAR(g_vehicle_tankll48_shield, int, 1000, "");
AUTOCVAR(g_vehicle_tankll48_shield_regen, int, 25, "");
AUTOCVAR(g_vehicle_tankll48_shield_regen_pause, float, 0.35, "");

//AUTOCVAR(g_vehicle_tankll48_energy, int, 100, "");
//AUTOCVAR(g_vehicle_tankll48_energy_regen, int, 10, "");
//AUTOCVAR(g_vehicle_tankll48_energy_regen_pause, float, 0.25, "");

AUTOCVAR(g_vehicle_tankll48_turret_turnlimit, float, 90, "");
AUTOCVAR(g_vehicle_tankll48_turret_turnspeed, float, 120, "");

AUTOCVAR(g_vehicle_tankll48_gun_pitchlimit_up, float, 30, "");
AUTOCVAR(g_vehicle_tankll48_gun_pitchlimit_down, float, -20, "");
AUTOCVAR(g_vehicle_tankll48_gun_pitchspeed, float, 50, "");

AUTOCVAR(g_vehicle_tankll48_cannon_radius, float, 500, "");
AUTOCVAR(g_vehicle_tankll48_cannon_force, float, 9, "");
AUTOCVAR(g_vehicle_tankll48_cannon_speed, float, 9001, "");
AUTOCVAR(g_vehicle_tankll48_cannon_spread, float, 0, "");
AUTOCVAR(g_vehicle_tankll48_cannon_speedaccel, float, 6500, "");
AUTOCVAR(g_vehicle_tankll48_cannon_speed_up, float, 0, "");
AUTOCVAR(g_vehicle_tankll48_cannon_damage, float, 2000, "");
AUTOCVAR(g_vehicle_tankll48_cannon_damage2, float, 1700, "");
AUTOCVAR(g_vehicle_tankll48_cannon_edgedamage, float, 1500, "");
AUTOCVAR(g_vehicle_tankll48_cannon_pitchlimit_down, float, -10, "");
AUTOCVAR(g_vehicle_tankll48_cannon_pitchlimit_up, float, 40, "");
//AUTOCVAR(g_vehicle_tankll48_cannon_turnlimit_in, float, 20, "");
//AUTOCVAR(g_vehicle_tankll48_cannon_turnlimit_out, float, 80, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_cost, int, 200, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_max, int, 200, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_regen, int, 100, "");
AUTOCVAR(g_vehicle_tankll48_cannon_ammo_regen_pause, float, 1, "");
AUTOCVAR(g_vehicle_tankll48_cannon_pitchspeed, float, 60, "");
//AUTOCVAR(g_vehicle_tankll48_cannon_turnspeed, float, 110, "");
//AUTOCVAR(g_vehicle_tankll48_cannon_turnlimit, float, 90, "");

AUTOCVAR(g_vehicle_tankll48_bouncepain, vector, '0 0 0', "");

AUTOCVAR(g_vehicle_tankll48_movement_inertia, float, 0.15, "");
AUTOCVAR(g_vehicle_tankll48_speed_stop, float, 50, "");
//AUTOCVAR(g_vehicle_tankll48_speed_strafe, float, 600, "");
AUTOCVAR(g_vehicle_tankll48_speed_walk, float, 700, "");
AUTOCVAR(g_vehicle_tankll48_springlength, float, 150, "");
AUTOCVAR(g_vehicle_tankll48_springup, float, 20, "");
AUTOCVAR(g_vehicle_tankll48_springblend, float, 0.1, "");
//AUTOCVAR(g_vehicle_tankll48_mass, float, 1000, "");
//AUTOCVAR(g_vehicle_tankll48_friction, float, 2, "");
AUTOCVAR(g_vehicle_tankll48_tiltlimit, float, 90, "");
//AUTOCVAR(g_vehicle_tankll48_turnspeed, float, 90, "");
//AUTOCVAR(g_vehicle_tankll48_turnspeed_strafe, float, 300, "");

//AUTOCVAR(g_vehicle_tankll48_head_pitchlimit_up, float, 30, "");
//AUTOCVAR(g_vehicle_tankll48_head_pitchlimit_down, float, -20, "");
//AUTOCVAR(g_vehicle_tankll48_head_pitchspeed, float, 50, "");
//AUTOCVAR(g_vehicle_tankll48_head_turnspeed, float, 110, "");
//AUTOCVAR(g_vehicle_tankll48_head_turnlimit, float, 90, "");

AUTOCVAR(g_vehicle_tankll48_snapview, bool, false, "");

void crosshair_trace2(entity pl)
{
	traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * max_shot_distance, MOVE_WORLDONLY, pl, ANTILAG_LATENCY(pl));
}

void tankll48_cannon_explode(entity this, entity directhitentity)
{
	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;

	RadiusDamage (this, this.realowner, autocvar_g_vehicle_tankll48_cannon_damage, autocvar_g_vehicle_tankll48_cannon_edgedamage, autocvar_g_vehicle_tankll48_cannon_radius, 
					NULL, NULL, autocvar_g_vehicle_tankll48_cannon_force, this.projectiledeathtype, directhitentity);

	delete(this);
}

void tankll48_cannon_touch(entity this, entity toucher)
{
	if(WarpZone_Projectile_Touch(this, toucher))
		if(wasfreed(this))
			return;

	//if(other.solid != SOLID_BSP)
	//	  return;

	tankll48_cannon_explode(this, toucher);
}

void tankll48_cannon_think(entity this)
{
	if(this.cnt <= time)
	{
		delete(this);
		return;
	}

	this.cnt = vlen(this.velocity);
	this.wait = this.cnt * sys_frametime;
	this.pos1 = normalize(this.velocity);

	tracebox(this.origin, this.mins, this.maxs, this.origin + this.pos1 * (2 * this.wait), MOVE_NORMAL, this);
	if(trace_ent.takedamage)
		Damage (trace_ent, this, this.realowner, autocvar_g_vehicle_tankll48_cannon_damage2, this.projectiledeathtype, this.origin, normalize(this.origin - other.origin) * autocvar_g_vehicle_tankll48_cannon_force);

	if(trace_allsolid || trace_startsolid)
	{
		gettouch(this)(this, trace_ent);
		return;
	}

	this.velocity = this.pos1 * (this.cnt + (autocvar_g_vehicle_tankll48_cannon_speedaccel * sys_frametime));

	UpdateCSQCProjectile(this);
	this.nextthink = time;
}

void tankll48_fire_cannon(entity actor, entity vehic, string tagname)
{
	vehic.count = time;
	vehic.vehicle_ammo2 -= autocvar_g_vehicle_tankll48_cannon_ammo_cost;
	entity missile = new(cannonball);
	vector v = gettaginfo(vehic.gun2, gettagindex(vehic.gun2, tagname));
	W_SetupShot_ProjectileSize (actor, weaponentities[0], '-3 -3 -3', '3 3 3', false, 5, SND_TANK_FIRE, CH_WEAPON_A, autocvar_g_vehicle_tankll48_cannon_damage);

	v_forward = normalize(v_forward);
	v += v_forward * 12;
	w_shotorg = v;

	Send_Effect(EFFECT_ROCKET_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);
	PROJECTILE_MAKETRIGGER(missile);

	missile.owner = vehic;
	missile.realowner = actor;
	missile.bot_dodge = true;
	missile.bot_dodgerating = autocvar_g_vehicle_tankll48_cannon_damage * 2;
	IL_PUSH(g_bot_dodge, missile);

	missile.takedamage = DAMAGE_NO;
	missile.event_damage = func_null;
	missile.damagedbycontents = true;
	IL_PUSH(g_damagedbycontents, missile);
	set_movetype(missile, MOVETYPE_FLY);

	missile.projectiledeathtype = DEATH_VH_SPID_DEATH.m_id;
	setsize (missile, '-16 -16 -16', '16 16 16'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	//W_SetupProjectileVelocity(missile, autocvar_g_vehicle_tankll48_cannon_speed, 0);
	//W_SetupProjectileVelocityEx(missile, w_shotdir, v_up, autocvar_g_vehicle_tankll48_cannon_speed, 0, 0, 0, false);
	set_movetype(missile, MOVETYPE_BOUNCEMISSILE);
	missile.velocity = w_shotdir * autocvar_g_vehicle_tankll48_cannon_speed;
	missile.velocity = W_CalculateProjectileVelocity(missile.realowner, missile.realowner.velocity, missile.velocity, true);

	settouch(missile, tankll48_cannon_touch);

	setthink(missile, tankll48_cannon_think);
	missile.cnt = time + 15;
	missile.nextthink = time;
	missile.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, missile);
	missile.pos1 = missile.velocity;

	CSQCProjectile(missile, true, PROJECTILE_CANNONBALL, false);
}

void tankll48_shlac(entity player, entity gunmount, float dt) 
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_shlac_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		gunmount.cnt = time;
		gunmount.misc_bulletcounter += 1;

		vwep_shlac_attack(player, "tag_mgun1", gunmount, gunmount.gun1);
		//vwep_shlac_attack(player, "tag_mgun2", gunmount);
		//vwep_shlac_attack(player, "tag_mgun3", gunmount);
		//vwep_shlac_attack(player, "tag_mgun4", gunmount);
		//vwep_shlac_attack(player, "tag_mgun5", gunmount);

		gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_shlac_ammo_cost;
		gunmount.attack_finished_single[0] = time + autocvar_g_vehicle_lightapc_shlac_refire;
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_shlac_ammo_max,
										   autocvar_g_vehicle_lightapc_shlac_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_shlac_ammo_regen, dt, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_shlac_ammo_max) * 100;
}

bool tankll48_frame(entity this, float dt)
{
	entity vehic = this.vehicle;
	return = true;

	if(intermission_running)
	{
		vehic.velocity = '0 0 0';
		vehic.avelocity = '0 0 0';
		return;
	}
	
	PHYS_INPUT_BUTTON_ZOOM(this) = 0;
	//PHYS_INPUT_BUTTON_CROUCH(this)    = 0;
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		this.(weaponentity).m_switchweapon = WEP_Null;
	}

	vector ad = gettaginfo(vehic.gun3, gettagindex(vehic.gun3, "tag_mgun"));
	traceline(ad, ad + v_forward * max_shot_distance, MOVE_WORLDONLY, vehic);
	
	vector vf = ad;
	ad = gettaginfo(vehic.gun2, gettagindex(vehic.gun2, "tag_cannon"));
	traceline(ad, ad + v_forward * max_shot_distance, MOVE_WORLDONLY, vehic);
	UpdateAuxiliaryXhair(this, trace_endpos, '1 0 0', 1);
	//ad = 0.5 * (ad + vf);
	ad = vf;
	
	crosshair_trace2(this);
	ad = vectoangles(normalize(trace_endpos - ad));
	ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(vehic.angles), AnglesTransform_FromAngles(ad))) - vehic.gun3.angles;
	ad = AnglesTransform_Normalize(ad, true);
	
	//Make sure angles are fine
	//if(vehic.tur_head.angles_y > 180)  vehic.tur_head.angles_y -= 360; if(vehic.tur_head.angles_y < -180) vehic.tur_head.angles_y += 360;
	
 
	//Rotate Turret and stabilizing "gun3" (rotates faster than turret)
	float ftmp = autocvar_g_vehicle_tankll48_turret_turnspeed * sys_frametime;    
	ad_y = bound(-ftmp, ad_y, ftmp);
	vehic.gun3.angles_y = bound(autocvar_g_vehicle_tankll48_turret_turnlimit * -1, vehic.gun3.angles_y + ad_y, autocvar_g_vehicle_tankll48_turret_turnlimit);
	vehic.tur_head.angles_y = vehic.gun3.angles_y;

	/////////////////////////
	//Stuff for actual mgun
	ad = gettaginfo(vehic.gun1, gettagindex(vehic.gun1, "tag_mgun"));
	traceline(ad, ad + v_forward * max_shot_distance, MOVE_WORLDONLY, vehic);
	UpdateAuxiliaryXhair(this, trace_endpos, '1 0.25 0', 0);
	
	crosshair_trace2(this);
	ad = vectoangles(normalize(trace_endpos - ad));
	ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(vehic.angles), AnglesTransform_FromAngles(ad))) - vehic.gun1.angles;
	ad = AnglesTransform_Normalize(ad, true);
	
	//ftmp = autocvar_g_vehicle_tankll48_gun_turnspeed * sys_frametime;    
	//ad_y = bound(-ftmp, ad_y, ftmp);
	//vehic.gun1.angles_y = bound(autocvar_g_vehicle_tankll48_gun_turnlimit * -1, vehic.gun1.angles_y + ad_y, autocvar_g_vehicle_tankll48_gun_turnlimit);

	
	// Pitch head
	ftmp = autocvar_g_vehicle_tankll48_gun_pitchspeed * sys_frametime;    
	ad_x = bound(ftmp * -1, ad_x, ftmp);
	vehic.gun1.angles_x = bound(autocvar_g_vehicle_tankll48_gun_pitchlimit_down, vehic.gun1.angles_x + ad_x, autocvar_g_vehicle_tankll48_gun_pitchlimit_up);

	//fixedmakevectors(vehic.angles);
	makevectors(vehic.angles + '-2 0 0' * vehic.angles_x);
	
	movelib_groundalign4point(vehic, autocvar_g_vehicle_tankll48_springlength, autocvar_g_vehicle_tankll48_springup, autocvar_g_vehicle_tankll48_springblend, autocvar_g_vehicle_tankll48_tiltlimit);

	if(IS_ONGROUND(vehic))
	{
		makevectors(this.v_angle);

		if(this.movement == '0 0 0')
		{
			if(vehic.sound_nexttime < time || vehic.delay != 3)
			{                        
				vehic.delay = 3;
				vehic.sound_nexttime = time + 6.0009; //soundlength("machines/generator_loop_pitchdown.ogg");
				//dprint("tankll48_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
				sound(vehic, CH_TRIGGER_SINGLE, SND_TANK_IDLE, VOL_VEHICLEENGINE, ATTN_NORM);
			}                
			movelib_brake_simple(vehic, autocvar_g_vehicle_tankll48_speed_stop);
			//vehic.frame = 5;
		
			vehic.bomb1.gun1.avelocity_y = vehic.bomb1.gun2.avelocity_y = vehic.bomb2.gun1.avelocity_y = vehic.bomb2.gun2.avelocity_y = 0;
		}
	
		if(this.movement_y != 0)
	 	{
			if(vehic.angles_y > 180)  vehic.angles_y -= 360;
			if(vehic.angles_y < -180) vehic.angles_y += 360;
			vehic.angles_y = bound(-184,vehic.angles_y + ((this.movement_y * sys_frametime) / -6.66666),184);	
			
			if(vehic.angles_y >= -1 && vehic.angles_y <= -1)
				vehic.angles_y = 0;	
			
			//Unlike the T27 tank, we do it alittle more complex way so the turret can 
			//be independent somewhat
			float degree_y;
			this.angles_y = this.angles_y + ((this.movement_y * sys_frametime) / -6.66666);
			degree_y = ((this.movement_y * sys_frametime) / -6.66666);
			this.v_angle_y += degree_y;
			
			////this.v_angle_y = vehic.angles_y; //kiss //T27

			if(IS_REAL_CLIENT(this) && autocvar_g_vehicle_tankll48_snapview)
			{
				msg_entity = this;
				WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
				WriteAngle( MSG_ONE, this.v_angle_x);
				WriteAngle( MSG_ONE, this.v_angle_y);
				WriteAngle( MSG_ONE, this.v_angle_z);
			}
			
			////////this.angles_y = this.angles_y + (this.movement_y / -200);
			////////this.fixangle = true;
			
			//////msg_entity = this;
			//////WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
			//////WriteAngle( MSG_ONE, vehic.angles_x); 
			//////WriteAngle( MSG_ONE, vehic.angles_y);
			//////WriteAngle( MSG_ONE, vehic.angles_z);
			if (this.movement_y > 0)
			{
				vehic.bomb1.gun1.avelocity_y = 75; //gear
				vehic.bomb1.gun2.avelocity_y = 90; //wheel
				vehic.bomb2.gun1.avelocity_y = -75; //gear
				vehic.bomb2.gun2.avelocity_y = -90; //wheel
			}
			else
			{
				vehic.bomb1.gun1.avelocity_y = -75; //gear
				vehic.bomb1.gun2.avelocity_y = -90; //wheel
				vehic.bomb2.gun1.avelocity_y = 75; //gear
				vehic.bomb2.gun2.avelocity_y = 90; //wheel
			}
		}
	 
	 	if(this.movement_x != 0)
		{
			if(this.movement_x > 0)
			{
				this.movement_x = 1;
				vehic.frame = 0;
			}
			else if(this.movement_x < 0)
			{
				this.movement_x = -1;
				vehic.frame = 1;
			}
			
			vehic.bomb1.gun1.avelocity_y = 75 * this.movement_x; //gear
			vehic.bomb1.gun2.avelocity_y = 90 * this.movement_x; //wheel
			vehic.bomb2.gun1.avelocity_y = 75 * this.movement_x; //gear
			vehic.bomb2.gun2.avelocity_y = 90 * this.movement_x; //wheel
			
			this.movement_y = 0;
			
			//fixedmakevectors(vehic.angles);
			makevectors(vehic.angles + '-2 0 0' * vehic.angles_x);
	
			movelib_move_simple(vehic, normalize(v_forward * this.movement_x),autocvar_g_vehicle_tankll48_speed_walk,autocvar_g_vehicle_tankll48_movement_inertia);

			if(vehic.sound_nexttime < time || vehic.delay != 1)
			{                        
				vehic.delay = 1;
				vehic.sound_nexttime = time + 3.991; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
				sound(vehic, CH_TRIGGER_SINGLE, SND_TANK_MOVE, VOL_VEHICLEENGINE, ATTN_NORM);
				//dprint("tankll48_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
			}
		  
		}
		else
		{
			//If we are not moving forward or backwards we should stop
			//Otherwise we "drift" while turn buttons are pressed, like on ice
			movelib_brake_simple(vehic, autocvar_g_vehicle_tankll48_speed_stop);
		}
	}
	
	vehic.angles_x = bound(-autocvar_g_vehicle_tankll48_tiltlimit, vehic.angles_x, autocvar_g_vehicle_tankll48_tiltlimit);
	vehic.angles_z = bound(-autocvar_g_vehicle_tankll48_tiltlimit, vehic.angles_z, autocvar_g_vehicle_tankll48_tiltlimit);

	if(PHYS_INPUT_BUTTON_JUMP(this))
		vehic.gun2.angles_x = bound(autocvar_g_vehicle_tankll48_cannon_pitchlimit_down, vehic.gun2.angles_x + (autocvar_g_vehicle_tankll48_cannon_pitchspeed * sys_frametime), autocvar_g_vehicle_tankll48_cannon_pitchlimit_up);
	
	if(PHYS_INPUT_BUTTON_CROUCH(this))
		vehic.gun2.angles_x = bound(autocvar_g_vehicle_tankll48_cannon_pitchlimit_down, vehic.gun2.angles_x - (autocvar_g_vehicle_tankll48_cannon_pitchspeed * sys_frametime), autocvar_g_vehicle_tankll48_cannon_pitchlimit_up);
	
	PHYS_INPUT_BUTTON_CROUCH(this) = false;
	
	tankll48_shlac(this, vehic, dt);
	
	if(!forbidWeaponUse(this))
	if(PHYS_INPUT_BUTTON_ATCK2(this) && vehic.vehicle_ammo2 >= autocvar_g_vehicle_tankll48_cannon_ammo_cost)
		tankll48_fire_cannon(this, vehic, "tag_cannon");
	else
		vehicles_regen(vehic, vehic.count, vehicle_ammo2, autocvar_g_vehicle_tankll48_cannon_ammo_max,
										   autocvar_g_vehicle_tankll48_cannon_ammo_regen_pause,
										   autocvar_g_vehicle_tankll48_cannon_ammo_regen, dt, false);
	
	
	//tankll48_rocket_do();

	if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(vehic, vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_tankll48_shield, autocvar_g_vehicle_tankll48_shield_regen_pause, autocvar_g_vehicle_tankll48_shield_regen, dt, true);

	if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(vehic, vehic.dmg_time, vehicle_health, autocvar_g_vehicle_tankll48_health, autocvar_g_vehicle_tankll48_health_regen_pause, autocvar_g_vehicle_tankll48_health_regen, dt, false);

	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = 0;
	//this.vehicle_ammo2 = vehic.tur_head.frame;

	if(vehic.gun2.cnt <= time)
		this.vehicle_reload2 = 100;
	else
		this.vehicle_reload2 = 100 - ((vehic.gun2.cnt - time) / vehic.attack_finished_single[0]) * 100;

	setorigin(this, vehic.origin + '0 0 1' * vehic.maxs_z);
	this.oldorigin = this.origin; // negate fall damage
	this.velocity = vehic.velocity;

	VEHICLE_UPDATE_PLAYER(this, vehic, health, tankll48);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(this, vehic, shield, tankll48);

	//Gun3 is out invisible angle stabilizer/reducer
	//tur_head gets its value from it above, so we act on it here
	//print(sprintf("m1 = %f\n", vehic.gun3.angles_y));
	if(vehic.gun3.angles_y > 180)
	{
		//print("here 1\n");
		vehic.gun3.angles_y = vehic.gun3.angles_y - 360;
	//print(sprintf("m2 = %f\n", vehic.gun3.angles_y));
	}
	else if(vehic.gun3.angles_y < -180)
	{
		//print("here 2\n");
		vehic.gun3.angles_y = vehic.gun3.angles_y + 360;
		//print(sprintf("m2 = %f\n", vehic.gun3.angles_y));
	}

	//this.vehicle_ammo1 = (vehic.vehicle_ammo1 / autocvar_g_vehicle_tankll48_cannon_ammo_max) * 100;
	this.vehicle_ammo2 = (vehic.vehicle_ammo2 / autocvar_g_vehicle_tankll48_cannon_ammo_max) * 100;   
}

void tankll48_exit(entity this, int eject)
{
	setthink(this, vehicles_think);
	this.nextthink = time;
	this.frame = 5;
	set_movetype(this, MOVETYPE_WALK);
	this.gun2.colormap = this.colormap;

	entity player = this.owner;

	if(!player)
		return;

	if(eject)
	{
		makevectors(this.angles);
		vector spot = this.origin + v_forward * 100 + '0 0 64';
		spot = vehicles_findgoodexit(this, player, spot);
		setorigin(player, spot);
		player.velocity = (v_up + v_forward * 0.25) * 750;
		player.oldvelocity = player.velocity;
	}
	else
	{
		player.velocity = player.oldvelocity = '0 0 300';
		setorigin(player, this.origin + ('0 0 1.5' * this.maxs_z));
	}

	this.owner = NULL;
	antilag_clear(player, CS(player));
}

void tankll48_headfade(entity this)
{
	setthink(this, tankll48_headfade);
	this.nextthink = this.fade_time;
	this.alpha = 1 - (time - this.fade_time) * this.fade_rate;

	if(this.cnt < time || this.alpha < 0.1)
	{
		if(this.alpha > 0.1)
		{
			sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);
			Send_Effect(EFFECT_EXPLOSION_BIG, this.origin + '0 0 100', '0 0 0', 1);
		}
		delete(this);
	}
}

void tankll48_blowup(entity this)
{
	if(this.cnt > time)
	{
		if(random() < 0.1)
		{
			sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);
			Send_Effect(EFFECT_EXPLOSION_SMALL, randomvec() * 80 + (this.origin + '0 0 100'), '0 0 0', 1);
		}
		this.nextthink = time + 0.1;
		return;
	}
	
	entity h = spawn(), g1 = spawn(), g2 = spawn(), b = spawn();

	_setmodel(b,  VEH_TANKLL48.mdl);
	_setmodel(h,  VEH_TANKLL48.head_model);
	setmodel(g1, MDL_TANKLL48_CANNON);
	setmodel(g2, MDL_TANKT27_GEAR);

	setorigin(b, this.origin);
	b.frame         = 11;
	b.angles        = this.angles;
	setsize(b, this.mins, this.maxs);

	setorigin(h, gettaginfo(this, gettagindex(this, "tag_head")));
	set_movetype(h, MOVETYPE_BOUNCE);
	h.solid         = SOLID_BBOX;
	h.velocity      = v_up * (500 + random() * 500) + randomvec() * 128;
	h.modelflags    = MF_ROCKET;
	h.effects       = EF_FLAME | EF_LOWPRECISION;
	h.avelocity     = randomvec() * 360;

	h.alpha         = 1;
	h.cnt           = time + (3.5 * random());
	h.fade_rate     = 1 / min(autocvar_g_vehicle_tankll48_respawntime, 10);
	h.fade_time     = time;
	setthink(h, tankll48_headfade);
	h.nextthink     = time;

	setorigin(g1, gettaginfo(this.tur_head, gettagindex(this.tur_head, "tag_hardpoint01")));
	set_movetype(g1, MOVETYPE_TOSS);
	g1.solid        = SOLID_CORPSE;
	g1.velocity     = v_forward * 700 + (randomvec() * 32);
	g1.avelocity    = randomvec() * 180;

	setorigin(g2, gettaginfo(this.tur_head, gettagindex(this.tur_head, "tag_hardpoint02")));
	set_movetype(g2, MOVETYPE_TOSS);
	g2.solid        = SOLID_CORPSE;
	g2.velocity     = v_forward * 700 + (randomvec() * 32);
	g2.avelocity    = randomvec() * 180;

	h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

	SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_tankll48_respawntime, 1));
	//SUB_SetFade(h,  time, min(autocvar_g_vehicle_tankll48_respawntime, 10));
	SUB_SetFade(g1, time, min(autocvar_g_vehicle_tankll48_respawntime, 10));
	SUB_SetFade(g2, time, min(autocvar_g_vehicle_tankll48_respawntime, 10));

	RadiusDamage (this, this.enemy, 250, 15, 250, NULL, NULL, 250, DEATH_VH_SPID_DEATH.m_id, NULL);

	this.alpha = this.tur_head.alpha = this.gun1.alpha = this.gun2.alpha = this.bomb1.gun1.alpha = this.bomb1.gun2.alpha = this.bomb2.gun1.alpha = this.bomb2.gun2.alpha = -1;
	set_movetype(this, MOVETYPE_NONE);
	this.deadflag   = DEAD_DEAD;
	this.solid      = SOLID_NOT;
	this.tur_head.effects  &= ~EF_FLAME;
	this.vehicle_hudmodel.viewmodelforclient = this;
}

entity tankll48_spawn_spinner(entity veh, Model themodel, string thetag)
{
	entity spinner = spawn(); // leaving it with empty classname so things like warpzones skip it
	spinner.owner = veh;
	setmodel(spinner, themodel);
	setattachment(spinner, veh, thetag);
	spinner.avelocity = '0 90 0';
	spinner.colormod = veh.colormod;
	return spinner;
}

spawnfunc(vehicle_tankll48)
{
	if(!autocvar_g_vehicle_tankll48) { delete(this); return; }
	if(!vehicle_initialize(this, VEH_TANKLL48, false)) { delete(this); return; }
}

METHOD(TankLL48, vr_impact, void(TankLL48 thisveh, entity instance))
{
	if(autocvar_g_vehicle_tankll48_bouncepain)
		vehicles_impact(instance, autocvar_g_vehicle_tankll48_bouncepain_x, autocvar_g_vehicle_tankll48_bouncepain_y, autocvar_g_vehicle_tankll48_bouncepain_z);
}
METHOD(TankLL48, vr_enter, void(TankLL48 thisveh, entity instance))
{
	set_movetype(instance, MOVETYPE_WALK);
	CSQCVehicleSetup(instance.owner, 0);
	instance.owner.vehicle_health = (instance.vehicle_health / autocvar_g_vehicle_tankll48_health) * 100;
	instance.owner.vehicle_shield = (instance.vehicle_shield / autocvar_g_vehicle_tankll48_shield) * 100;

	instance.gun2.colormap = instance.colormap;

	//instance.gun1.colormod = instance.gun2.colormod = instance.bomb1.gun1.colormod = instance.bomb1.gun2.colormod = instance.bomb2.gun1.colormod = instance.bomb2.gun2.colormod = instance.colormod;

	if(instance.owner.flagcarried)
	{
		setattachment(instance.owner.flagcarried, instance.tur_head, "");
		setorigin(instance.owner.flagcarried, '-20 0 120');
	}
}
METHOD(TankLL48, vr_think, void(TankLL48 thisveh, entity instance))
{
	if(IS_ONGROUND(instance))
		movelib_brake_simple(instance, autocvar_g_vehicle_tankll48_speed_stop);
}
METHOD(TankLL48, vr_death, void(TankLL48 thisveh, entity instance))
{
	instance.health				= 0;
	instance.event_damage		= func_null;
	instance.takedamage			= DAMAGE_NO;
	settouch(instance, func_null);
	instance.cnt				= 3.4 + time + random() * 2;
	setthink(instance, tankll48_blowup);
	instance.nextthink			= time;
	instance.deadflag			= DEAD_DYING;
	instance.frame				= 5;
	instance.tur_head.effects  |= EF_FLAME;
	instance.colormod			= instance.tur_head.colormod = instance.gun1.colormod = instance.gun2.colormod = '-1 -1 -1';
	instance.frame				= 10;
	set_movetype(instance, MOVETYPE_TOSS);
	lightapc_kill_hitbox(instance.hitboxft);
	lightapc_kill_hitbox(instance.hitboxbk);
			
	CSQCModel_UnlinkEntity(instance); // networking the death scene would be a nightmare
}
METHOD(TankLL48, vr_spawn, void(TankLL48 thisveh, entity instance))
{
	if(!instance.gun1)
	{
		instance.bomb1 = spawn();
		instance.bomb2 = spawn();

		instance.gravity = 2;
		instance.mass = 5000;

		entity tur;
		tur = instance.gun1 = spawn();
		setmodel(tur, MDL_MG_SHLACGUN);
		setattachment(tur, instance.tur_head, "tag_gunpivot2");
		tur.colormod = instance.colormod;

		tur = instance.gun2 = spawn();
		setmodel(tur, MDL_TANKLL48_CANNON);
		setattachment(tur, instance.tur_head, "tag_cannon_pivot");
		tur.colormod = instance.colormod;

		tur = instance.gun3 = spawn(); // angle stabilizer for the rotating turret
		tur.alpha = -1;
		setmodel(tur, MDL_TANK_ANGLESTABILIZER);
		setattachment(tur, instance.tur_head, "tag_cannon_pivot");

		instance.bomb1.gun1 = tankll48_spawn_spinner(instance, MDL_TANKT27_GEAR, "tag_gear_left");
		instance.bomb1.gun2 = tankll48_spawn_spinner(instance, MDL_TANKT27_WHEEL, "tag_wheel_left");
		instance.bomb2.gun1 = tankll48_spawn_spinner(instance, MDL_TANKT27_GEAR, "tag_gear_right");
		instance.bomb2.gun2 = tankll48_spawn_spinner(instance, MDL_TANKT27_WHEEL, "tag_wheel_right");
			
		// sigh
		setthink(instance.bomb1, raptor_rotor_anglefix);
		instance.bomb1.nextthink = time;
			
		setattachment(instance.vehicle_hudmodel, instance, "");
		//setattachment(instance.vehicle_viewport, instance.gun1, "tag_gcamera");
		setattachment(instance.vehicle_viewport, instance.tur_head, "tag_camera");
			
		instance.gun1.colormap = instance.colormap;
		instance.hitboxft = spawn();
		instance.hitboxbk = spawn();
	}

	instance.frame = 5;
	instance.tur_head.frame = 1;
	set_movetype(instance, MOVETYPE_WALK);
	instance.solid = SOLID_SLIDEBOX;
	instance.alpha = instance.tur_head.alpha = instance.gun1.alpha = instance.gun2.alpha = instance.bomb1.gun1.alpha = instance.bomb1.gun2.alpha = instance.bomb2.gun1.alpha = instance.bomb2.gun2.alpha = 1;
	instance.gun2.colormap = instance.bomb1.gun1.colormap = instance.bomb1.gun2.colormap = instance.bomb2.gun1.colormap = instance.bomb2.gun2.colormap = instance.colormap;
	instance.tur_head.angles = '0 0 0';
	instance.gun1.angles = instance.gun2.angles = '0 0 0';
	instance.vehicle_exit = tankll48_exit;

	instance.bomb1.gun1.avelocity_y = 0;
	instance.bomb1.gun2.avelocity_y = 0;
	instance.bomb2.gun1.avelocity_y = 0;
	instance.bomb2.gun2.avelocity_y = 0;

	setorigin(instance, instance.pos1 + '0 0 128');
	instance.angles = instance.pos2;
	instance.damageforcescale = 0.03;
	instance.vehicle_health = autocvar_g_vehicle_tankll48_health;
	instance.vehicle_shield = autocvar_g_vehicle_tankll48_shield;
			
	instance.PlayerPhysplug = tankll48_frame;

	lightapc_spawn_hitbox(instance, instance.hitboxft, '-105 -105 2', '105 105 95', 95);
	lightapc_spawn_hitbox(instance, instance.hitboxbk, '-60 -60 2', '60 60 50', -120);
}
METHOD(TankLL48, vr_setup, void(TankLL48 thisveh, entity instance))
{
	if(autocvar_g_vehicle_tankll48_shield)
		instance.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_tankll48_shield_regen)
		instance.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_tankll48_health_regen)
		instance.vehicle_flags |= VHF_HEALTHREGEN;

	instance.respawntime = autocvar_g_vehicle_tankll48_respawntime;
	instance.vehicle_health = autocvar_g_vehicle_tankll48_health;
	instance.vehicle_shield = autocvar_g_vehicle_tankll48_shield;
	instance.max_health = instance.vehicle_health;
	//instance.pushable = true; // tankll48 can use jumppads
}

#elif defined(CSQC)
//AUTOCVAR_SAVE(cl_vehicle_tankll48_cross_alpha,                    float,   0.7,      "");
//AUTOCVAR_SAVE(cl_vehicle_tankll48_cross_size,                     float,   1,        "");

const string vCROSS_TANK  = "gfx/vehicles/crosshair_tank.tga";
const string vCROSS_TANK2  = "gfx/vehicles/crosshair_tank2.tga";

METHOD(TankLL48, vr_hud, void(TankLL48 thisveh))
{
	Vehicles_drawHUD(VEH_TANKLL48.m_icon, "vehicle_tank_weapon1", "vehicle_tank_weapon2",
					 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
					 "vehicle_icon_ammo_tank", autocvar_hud_progressbar_vehicles_ammo2_color);
	if(!autocvar_r_letterbox && !scoreboard_showscores && !autocvar_chase_active)
	{
		// custom crosshair
		vector tmpSize  = draw_getimagesize(vCROSS_TANK2) * autocvar_cl_vehicles_crosshair_size;
		vector tmpPos = '0 0 0';
		tmpPos.x = (vid_conwidth - tmpSize.x) / 2;
		tmpPos.y = (vid_conheight - tmpSize.y) / 2;

		drawpic(tmpPos, vCROSS_TANK2, tmpSize, '0 0 1', autocvar_crosshair_alpha * 0.5, DRAWFLAG_NORMAL);
	}
}
METHOD(TankLL48, vr_setup, void(TankLL48 thisveh, entity instance))
{
	AuxiliaryXhair[0].axh_image = vCROSS_HINT; // gun
	AuxiliaryXhair[1].axh_image = vCROSS_LOCK; // cannon?
	AuxiliaryXhair[2].axh_image = vCROSS_BURST; // cannon?
}


REGISTER_MUTATOR(cl_tankll48, true);

SOUND(CANNONBALL_FLY, W_Sound("fireball_fly2"));

MODEL(PROJECTILE_CANNONBALL, "models/sphere/sphere.md3");

MUTATOR_HOOKFUNCTION(cl_tankll48, Ent_Projectile)
{
	entity proj = M_ARGV(0, entity);

	if(proj.cnt == PROJECTILE_CANNONBALL)
	{
		setmodel(proj, MDL_PROJECTILE_CANNONBALL);
		proj.traileffect = EFFECT_TR_ROCKET.m_id;
		return true;
	}
}

MUTATOR_HOOKFUNCTION(cl_tankll48, EditProjectile)
{
	entity proj = M_ARGV(0, entity);

	if(proj.cnt == PROJECTILE_CANNONBALL)
	{
		proj.colormod = '1 1 1';
		proj.scale = 0.5;
		loopsound(proj, CH_SHOTS_SINGLE, SND_CANNONBALL_FLY, VOL_BASE, ATTEN_NORM);
		proj.mins = '-16 -16 -16';
		proj.maxs = '16 16 16';
	}
}

#endif // CSQC
#endif // REGISTER_VEHICLE
