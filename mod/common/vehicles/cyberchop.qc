#include "cyberchop.qh"

#if defined(SVQC)
	#include <common/gamemodes/gamemode/ctf/sv_ctf.qh>
#endif

#ifdef GAMEQC
SOUND(CHOPNOISE, "vehicles/chopnoise");
SOUND(CHOPNOISE_LANDED, "vehicles/chopnoise_landed");
MODEL(CYBERCHOP_MILSPEC, "models/vehicles/cybermilspec.iqm");
MODEL(CYBERCHOP_ROTOR, "models/vehicles/cyberrotor.iqm");
MODEL(CYBERCHOP_SMALLROTOR, "models/vehicles/cybersmallrotor.iqm");
#endif

#ifdef SVQC
AUTOCVAR(g_vehicle_cyberchop, bool, true, "Enable CyberChopper vehicle");
AUTOCVAR(g_vehicle_cyberchop_respawntime, float, 30, "");

AUTOCVAR(g_vehicle_cyberchop_blowup_radius, float, 500, "");
AUTOCVAR(g_vehicle_cyberchop_blowup_coredamage, float, 500, "");
AUTOCVAR(g_vehicle_cyberchop_blowup_edgedamage, float, 100, "");
AUTOCVAR(g_vehicle_cyberchop_blowup_forceintensity, float, 600, "");

AUTOCVAR(g_vehicle_cyberchop_health, int, 1200, "");
AUTOCVAR(g_vehicle_cyberchop_health_regen, int, 20, "");
AUTOCVAR(g_vehicle_cyberchop_health_regen_pause, float, 1, "");

AUTOCVAR(g_vehicle_cyberchop_shield, int, 600, "");
AUTOCVAR(g_vehicle_cyberchop_shield_regen, int, 30, "");
AUTOCVAR(g_vehicle_cyberchop_shield_regen_pause, float, 1.5, "");

AUTOCVAR(g_vehicle_cyberchop_energy, int, 100, "");
AUTOCVAR(g_vehicle_cyberchop_energy_regen, int, 10, "");
AUTOCVAR(g_vehicle_cyberchop_energy_regen_pause, float, 0.25, "");

AUTOCVAR(g_vehicle_cyberchop_bouncefactor, float, 0.25, "");
AUTOCVAR(g_vehicle_cyberchop_bouncestop, float, 0, "");
AUTOCVAR(g_vehicle_cyberchop_bouncepain, vector, '70 3 250', "");

AUTOCVAR(g_vehicle_cyberchop_movestyle, int, 1, "");
AUTOCVAR(g_vehicle_cyberchop_takeofftime, float, 1.5, "");
AUTOCVAR(g_vehicle_cyberchop_speed_forward, float, 1700, "");
AUTOCVAR(g_vehicle_cyberchop_speed_strafe, float, 900, "");
AUTOCVAR(g_vehicle_cyberchop_speed_up, float, 1700, "");
AUTOCVAR(g_vehicle_cyberchop_speed_down, float, 1700, "");
AUTOCVAR(g_vehicle_cyberchop_mass, float, 1000, "");
AUTOCVAR(g_vehicle_cyberchop_friction, float, 2, "");
AUTOCVAR(g_vehicle_cyberchop_pitchlimit, float, 45, "");
AUTOCVAR(g_vehicle_cyberchop_pitchspeed, float, 50, "");
AUTOCVAR(g_vehicle_cyberchop_turnspeed, float, 200, "");

AUTOCVAR(g_vehicle_cyberchop_minigun_turnspeed, float, 200, "");
AUTOCVAR(g_vehicle_cyberchop_minigun_turnlimit, float, 20, "");
AUTOCVAR(g_vehicle_cyberchop_minigun_pitchlimit_up, float, 12, "");
AUTOCVAR(g_vehicle_cyberchop_minigun_pitchlimit_down, float, 32, "");

AUTOCVAR(g_vehicle_cyberchop_minigun_locktarget, bool, true, "");
AUTOCVAR(g_vehicle_cyberchop_minigun_locking_time, float, 0.2, "");
AUTOCVAR(g_vehicle_cyberchop_minigun_locking_releasetime, float, 0.45, "");
AUTOCVAR(g_vehicle_cyberchop_minigun_locked_time, float, 1, "");
AUTOCVAR(g_vehicle_cyberchop_minigun_predicttarget, float, 1, "");

.entity bomb1;
.entity bomb2;

bool cyberchop_takeoff(entity this, float dt);
bool cyberchop_pilot_frame(entity this, float dt);

void cyberchop_land(entity this)
{
	float hgt = vehicle_altitude(this, 512);
	this.velocity = (this.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * PHYS_INPUT_FRAMETIME);
	this.angles_x *= 0.95;
	this.angles_z *= 0.95;

	if(hgt < 128 && hgt > 0)
		this.frame = (hgt / 128) * 25;

	if (this.waterlevel > 0)
	{
		this.bomb1.gun1.avelocity_y = this.bomb1.gun1.avelocity_y * 0.95;
		this.bomb1.gun2.avelocity_y = -this.bomb1.gun1.avelocity_y;
	}
	else
	{
		this.bomb1.gun1.avelocity_y = 90 + ((this.frame / 25) * 2000);
		this.bomb1.gun2.avelocity_y = -this.bomb1.gun1.avelocity_y;
	}

	if(hgt < 16)
	{
		set_movetype(this, MOVETYPE_TOSS);
		setthink(this, vehicles_think);
		this.frame    = 0;
	}

	this.nextthink = time;

	CSQCMODEL_AUTOUPDATE(this);
}

void cyberchop_exit(entity this, int eject)
{
	settouch(this, vehicles_touch);
	setthink(this, vehicles_think);
	this.nextthink = time;
	
	if(!this.owner)
		return;
	
	// add from sparrow	
	if(!IS_DEAD(this))
	{
		setthink(this, cyberchop_land);
		this.nextthink  = time;
	}

	this.bomb1.gun1.count = 0;
	
	makevectors(this.angles);
	if(eject)
	{
		vector spot = this.origin + v_forward * 100 + '0 0 64';
		spot = vehicles_findgoodexit(this, this.owner, spot);
		setorigin(this.owner, spot);
		this.owner.velocity = (v_up + v_forward * 0.25) * 750;
		this.owner.oldvelocity = this.owner.velocity;
	}
	else
	{
		vector spot;
		if(vdist(this.velocity, >, 2 * PHYS_MAXAIRSPEED(this.owner)))
		{
			this.owner.velocity = normalize(this.velocity) * PHYS_MAXAIRSPEED(this.owner) * 2;
			this.owner.velocity_z += 200;
			spot = this.origin + v_forward * 32 + '0 0 32';
			spot = vehicles_findgoodexit(this, this.owner, spot);
		}
		else
		{
			this.owner.velocity = this.velocity * 0.5;
			this.owner.velocity_z += 10;
			spot = this.origin - v_forward * 200 + '0 0 32';
			spot = vehicles_findgoodexit(this, this.owner, spot);
		}
		this.owner.oldvelocity = this.owner.velocity;
		setorigin(this.owner, spot);
	}
	
	antilag_clear(this.owner, CS(this.owner));
	this.owner = NULL;
}

bool cyberchop_pilot_frame(entity this, float dt)
{


	
	//TODO: THERE ARE WEAPONS DELUGE, MINIGUN, HMG, ROCKET




	entity vehic = this.vehicle;
	return = true;

	if(intermission_running)
	{
		vehic.velocity = '0 0 0';
		vehic.avelocity = '0 0 0';
		return;
	}
	
	float ftmp = 0;
	if(vehic.sound_nexttime < time)
	if(this.waterlevel != WATERLEVEL_SUBMERGED)
	{
		vehic.sound_nexttime = time + 2.3807; 
		sound(vehic, CH_TRIGGER_SINGLE, SND_CHOPNOISE, 1, ATTN_NORM);
		vehic.wait = ftmp;
	}
	/*
	else if(fabs(ftmp - vehic.wait) > 0.2)
	{
		sound (vehic.tur_head, CH_TRIGGER_SINGLE, "", 1 - ftmp,   ATTN_NORM );
		sound (vehic, CH_TRIGGER_SINGLE, "", ftmp, ATTN_NORM);        
		vehic.wait = ftmp;
	}
	*/
	
	if(IS_DEAD(vehic))
	{
		PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = 0;
		return;
	}
	//crosshair_trace(this);
	makevectors(this.v_angle);
	trace_endpos = this.origin + v_forward * max_shot_distance;

	vector vang;
	vang = vehic.angles;
	vector df = vectoangles(normalize(trace_endpos - vehic.origin + '0 0 32'));
	vang_x *= -1;
	df_x *= -1;
	if(df_x > 180)  df_x -= 360;
	if(df_x < -180) df_x += 360;
	if(df_y > 180)  df_y -= 360;
	if(df_y < -180) df_y += 360;
	
	
	//print("wl: ", ftos(vehic.waterlevel), "\n");
	//print(sprintf("waterlevel: %f vehic to player %f\n", vehic.waterlevel, this.waterlevel));
	
	if(this.waterlevel != WATERLEVEL_SUBMERGED)
	{
		// gotta do it this way as vehicles waterlevel is always 1
		// thus we check players water level instead.
		/////////////////////////////////////////////////////////////////////////
		//BEGIN If not in water
		/////////////////////////////////////////////////////////////////////////

		ftmp = shortangle_f(this.v_angle_y - vang_y, vang_y);
		if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
		vehic.avelocity_y = bound(-autocvar_g_vehicle_cyberchop_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_cyberchop_turnspeed);

		// Pitch
		ftmp = 0;
		if(!((PHYS_INPUT_BUTTON_HOOK(this)) && (this.movement_x < 0)))
		{
			if(this.movement_x > 0 && vang_x < autocvar_g_vehicle_cyberchop_pitchlimit)
				ftmp = 5;
			else if(this.movement_x < 0 && vang_x > -autocvar_g_vehicle_cyberchop_pitchlimit)
				ftmp = -20;
		}

		df_x = bound(-autocvar_g_vehicle_cyberchop_pitchlimit, df_x , autocvar_g_vehicle_cyberchop_pitchlimit);
		ftmp = vang_x - bound(-autocvar_g_vehicle_cyberchop_pitchlimit, df_x + ftmp, autocvar_g_vehicle_cyberchop_pitchlimit);
		vehic.avelocity_x = bound(-autocvar_g_vehicle_cyberchop_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_cyberchop_pitchspeed);

		vehic.angles_x = anglemods(vehic.angles_x);
		vehic.angles_y = anglemods(vehic.angles_y);
		vehic.angles_z = anglemods(vehic.angles_z);

		if(autocvar_g_vehicle_cyberchop_movestyle == 1)
			makevectors('0 1 0' * vehic.angles_y);
		else
			makevectors(this.v_angle);

		df = vehic.velocity * -autocvar_g_vehicle_cyberchop_friction;
		
		if(PHYS_INPUT_BUTTON_HOOK(this))
		{
			if(vehicle_altitude(this, 512) < 16) 
			{
				this.PlayerPhysplug = cyberchop_takeoff;
				vehic.bomb1.gun1.count = 0;
			}	 
		}
		else
		{
			if(this.movement_x != 0)
			{
				if(this.movement_x > 0)
					df += v_forward  * autocvar_g_vehicle_cyberchop_speed_forward;
				else if(this.movement_x < 0)
					df -= v_forward  * autocvar_g_vehicle_cyberchop_speed_forward;
			}
		}

		if(this.movement_y != 0)
		{
			if(this.movement_y < 0)
				df -= v_right * autocvar_g_vehicle_cyberchop_speed_strafe;
			else if(this.movement_y > 0)
				df += v_right * autocvar_g_vehicle_cyberchop_speed_strafe;

			vehic.angles_z = bound(-30,vehic.angles_z + (this.movement_y / autocvar_g_vehicle_cyberchop_speed_strafe),30);
		}
		else
		{
			vehic.angles_z *= 0.95;
			if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
				vehic.angles_z = 0;
		}

		if(PHYS_INPUT_BUTTON_CROUCH(this))
			df -= v_up * autocvar_g_vehicle_cyberchop_speed_down;
		else if (PHYS_INPUT_BUTTON_JUMP(this))
			df += v_up * autocvar_g_vehicle_cyberchop_speed_up;
		
		//Cannon firing
		vehic.velocity  += df * dt;
		this.velocity = CS(this).movement  = vehic.velocity;
		setorigin(this, vehic.origin + '0 0 32');
		this.oldorigin = this.origin; // negate fall damage

		STAT(VEHICLESTAT_W2MODE, this) = STAT(VEHICLESTAT_W2MODE, vehic);

		vector vf, ad;
		// Target lock & predict
		if(autocvar_g_vehicle_cyberchop_minigun_locktarget == 2)
		{
			if(vehic.gun1.lock_time < time || IS_DEAD(vehic.gun1.enemy) || STAT(FROZEN, vehic.gun1.enemy))
				vehic.gun1.enemy = NULL;

			if(trace_ent)
			if(trace_ent.move_movetype)
			if(trace_ent.takedamage)
			if(!IS_DEAD(trace_ent) && !STAT(FROZEN, trace_ent))
			{
				if(teamplay)
				{
					if(trace_ent.team != this.team)
					{
						vehic.gun1.enemy = trace_ent;
						vehic.gun1.lock_time = time + 5;
					}
				}
				else
				{
					vehic.gun1.enemy = trace_ent;
					vehic.gun1.lock_time = time + 0.5;
				}
			}

			if(vehic.gun1.enemy)
			{
				float distance, impact_time;

				vf = real_origin(vehic.gun1.enemy);
				UpdateAuxiliaryXhair(this, vf, '1 0 0', 1);
				vector _vel = vehic.gun1.enemy.velocity;
				if(vehic.gun1.enemy.move_movetype == MOVETYPE_WALK)
					_vel_z *= 0.1;

				if(autocvar_g_vehicle_cyberchop_minigun_predicttarget)
				{
					ad = vf;
					distance = vlen(ad - this.origin);
					impact_time = distance / autocvar_g_vehicle_cyberchop_minigun_speed;
					ad = vf + _vel * impact_time;
					trace_endpos = ad;
				}
				else
					trace_endpos = vf;
			}
		}
		else if(autocvar_g_vehicle_cyberchop_minigun_locktarget == 1)
		{

			vehicles_locktarget(vehic, (1 / autocvar_g_vehicle_cyberchop_minigun_locking_time) * dt,
								(1 / autocvar_g_vehicle_cyberchop_minigun_locking_releasetime) * dt,
								autocvar_g_vehicle_cyberchop_minigun_locked_time);

			if(vehic.lock_target != NULL)
			if(autocvar_g_vehicle_cyberchop_minigun_predicttarget)
			if(vehic.lock_strength == 1)
			{
				float i, distance, impact_time;

				vf = real_origin(vehic.lock_target);
				ad = vf;
				for(i = 0; i < 4; ++i)
				{
					distance = vlen(ad - vehic.origin);
					impact_time = distance / autocvar_g_vehicle_cyberchop_minigun_speed;
					ad = vf + vehic.lock_target.velocity * impact_time;
				}
				trace_endpos = ad;
			}

			if(vehic.lock_target)
			{
				if(vehic.lock_strength == 1)
					UpdateAuxiliaryXhair(this, real_origin(vehic.lock_target), '1 0 0', 1);
				else if(vehic.lock_strength > 0.5)
					UpdateAuxiliaryXhair(this, real_origin(vehic.lock_target), '0 1 0', 1);
				else if(vehic.lock_strength < 0.5)
					UpdateAuxiliaryXhair(this, real_origin(vehic.lock_target), '0 0 1', 1);
			}
		}

		vehicle_aimturret(vehic, trace_endpos, vehic.gun1, "fire1",
							autocvar_g_vehicle_cyberchop_minigun_pitchlimit_down * -1,  autocvar_g_vehicle_cyberchop_minigun_pitchlimit_up,
							autocvar_g_vehicle_cyberchop_minigun_turnlimit * -1,  autocvar_g_vehicle_cyberchop_minigun_turnlimit,  autocvar_g_vehicle_cyberchop_minigun_turnspeed, dt);

		vehicle_aimturret(vehic, trace_endpos, vehic.gun2, "fire1",
							autocvar_g_vehicle_cyberchop_minigun_pitchlimit_down * -1,  autocvar_g_vehicle_cyberchop_minigun_pitchlimit_up,
							autocvar_g_vehicle_cyberchop_minigun_turnlimit * -1,  autocvar_g_vehicle_cyberchop_minigun_turnlimit,  autocvar_g_vehicle_cyberchop_minigun_turnspeed, dt);

		vehic.velocity += df * dt;
		set_movetype(vehic, MOVETYPE_BOUNCEMISSILE);
	}
	else
	{
		/////////////////////////////////////////////////////////////////////////
		//END If not in water
		/////////////////////////////////////////////////////////////////////////
		vehic.velocity  = '0 0 0';
		vehic.velocity_x = 0;
		vehic.velocity_y = 0;
		vehic.velocity_z = 0;
		vehic.avelocity_x = 0;
		vehic.avelocity_y = 0;
		vehic.avelocity_z = 0;
		set_movetype(vehic, MOVETYPE_TOSS);
		vehic.bomb1.gun1.avelocity_y = vehic.bomb1.gun1.avelocity_y * 0.95;
			vehic.bomb1.gun2.avelocity_y = -vehic.bomb1.gun1.avelocity_y;
	}
	
	this.velocity = this.movement = vehic.velocity;
	setorigin(this, vehic.origin + '0 0 32');

	Weapon wep1 = WEP_CYBERCHOP;
	.entity weaponentity = weaponentities[0];
	if(!weaponLocked(this) && !weaponUseForbidden(this))
	if(PHYS_INPUT_BUTTON_ATCK(this))
	if (wep1.wr_checkammo1(wep1, vehic, weaponentity))
	{
		wep1.wr_think(wep1, vehic, weaponentity, 1);
	}

	// Target lock & predict

	if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(vehic, vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_cyberchop_shield, autocvar_g_vehicle_cyberchop_shield_regen_pause, autocvar_g_vehicle_cyberchop_shield_regen, dt, true);

	if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen_resource(vehic, vehic.dmg_time, vehicle_health, autocvar_g_vehicle_cyberchop_health, autocvar_g_vehicle_cyberchop_health_regen_pause, autocvar_g_vehicle_cyberchop_health_regen, dt, false, RES_HEALTH);

	if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(vehic, vehic.wait, vehicle_energy, autocvar_g_vehicle_cyberchop_energy, autocvar_g_vehicle_cyberchop_energy_regen_pause, autocvar_g_vehicle_cyberchop_energy_regen, dt, false);

	//Bomb dropping removed

	Weapon wep2a = WEP_CYBERCHOP_BOMB;
	if(!weaponLocked(this) && !weaponUseForbidden(this))
	if(STAT(VEHICLESTAT_W2MODE, vehic) == RSM_BOMB)
	{
		if(time > vehic.lip + autocvar_g_vehicle_cyberchop_bombs_refire)
		if(PHYS_INPUT_BUTTON_ATCK2(this))
		{
		    .entity weaponentity = weaponentities[1];
			wep2a.wr_think(wep2a, vehic, weaponentity, 2);
			vehic.delay = time + autocvar_g_vehicle_cyberchop_bombs_refire;
			vehic.lip   = time;
		}
	}
	else
	{
		Weapon wep2b = WEP_CYBERCHOP_FLARE;
		if(time > vehic.lip + autocvar_g_vehicle_cyberchop_flare_refire)
		if(PHYS_INPUT_BUTTON_ATCK2(this))
		{
		    .entity weaponentity = weaponentities[1];
			wep2b.wr_think(wep2b, vehic, weaponentity, 2);
			vehic.delay = time + autocvar_g_vehicle_cyberchop_flare_refire;
			vehic.lip   = time;
		}
	}
	
	vehic.bomb1.alpha = vehic.bomb2.alpha = (time - vehic.lip) / (vehic.delay - vehic.lip);
	this.vehicle_reload2 = bound(0, vehic.bomb1.alpha * 100, 100);
	this.vehicle_ammo2 = (this.vehicle_reload2 == 100) ? 100 : 0;

	if(vehic.bomb1.cnt < time)
	{
		bool incoming = false;
		IL_EACH(g_projectiles, it.enemy == vehic,
		{
			if(it.missile_flags & MIF_GUIDED_TRACKING)
			if(vdist(vehic.origin - it.origin, <, 2 * autocvar_g_vehicle_cyberchop_flare_range))
			{
				incoming = true;
				break;
			}
		});

		if(incoming)
		{
			msg_entity = this;
			soundto(MSG_ONE, vehic, CH_PAIN_SINGLE, SND(VEH_MISSILE_ALARM), VOL_BASE, ATTEN_NONE, 0);
		}
		
		vehic.bomb1.cnt = time + 1;
	}

	// weapons removed

	VEHICLE_UPDATE_PLAYER_RESOURCE(this, vehic, health, cyberchop, RES_HEALTH);
	VEHICLE_UPDATE_PLAYER(this, vehic, energy, cyberchop);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(this, vehic, shield, cyberchop);

	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = false;
	setorigin(this,vehic.origin + '0 0 32');
	this.velocity = vehic.velocity;
}

bool cyberchop_takeoff(entity this, float dt)
{
	entity vehic = this.vehicle;
	return = true;

	vehic.nextthink = time;
	CSQCMODEL_AUTOUPDATE(vehic);
	vehic.nextthink = 0; // will this work?

	// make sure it's valid?
	if(PHYS_INPUT_BUTTON_JUMP(this))
	if(!vehic.bomb1.gun1.count)
		vehic.bomb1.gun1.count = 1;
	
	if(vehic.sound_nexttime < time)
	if(this.waterlevel != WATERLEVEL_SUBMERGED)
	{
		vehic.sound_nexttime = time + 2.3807; //soundlength("vehicles/raptor_fly.wav");
		sound(vehic, CH_TRIGGER_SINGLE, SND_CHOPNOISE_LANDED, VOL_VEHICLEENGINE, ATTN_NORM);
	}

	// takeoff sequence
	if(vehic.bomb1.gun1.count == 1)
	{
		set_movetype(vehic, MOVETYPE_BOUNCEMISSILE);
		if(vehic.frame < 25)
		{
			vehic.frame += 25 / (autocvar_g_vehicle_cyberchop_takeofftime / dt);
			vehic.velocity_z = min(vehic.velocity_z * 1.5, 256);
			vehic.bomb1.gun1.avelocity_y = 90 + ((vehic.frame / 25) * 25000);
			vehic.bomb1.gun2.avelocity_y = -vehic.bomb1.gun1.avelocity_y;
			PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = false;

			setorigin(this, vehic.origin + '0 0 32');
			this.oldorigin = this.origin;
		}
		else
			this.PlayerPhysplug = cyberchop_pilot_frame;
	}
	else
	{
		// engine off?
		set_movetype(vehic, MOVETYPE_BOUNCE);
		if (vehic.frame > 0)
		{
			vehic.frame -= 25 / (autocvar_g_vehicle_cyberchop_takeofftime / dt);
			if(this.waterlevel != WATERLEVEL_SUBMERGED)
			{
				vehic.bomb1.gun1.avelocity_y = 90 + ((vehic.frame / 25) * 25000);
				vehic.bomb1.gun2.avelocity_y = -vehic.bomb1.gun1.avelocity_y;
			}
		}
		if(IS_ONGROUND(vehic))
			movelib_brake_simple(vehic, 1);
	}

	// minigun firing
	STAT(VEHICLESTAT_W2MODE, this) = STAT(VEHICLESTAT_W2MODE, vehic);

	// end takeoff weapons stuff
	
	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = 0;
	setorigin(this, vehic.origin + '0 0 32');

	if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(vehic, vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_cyberchop_shield, autocvar_g_vehicle_cyberchop_shield_regen_pause, autocvar_g_vehicle_cyberchop_shield_regen, dt, true);

	if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen_resource(vehic, vehic.dmg_time, vehicle_health, autocvar_g_vehicle_cyberchop_health, autocvar_g_vehicle_cyberchop_health_regen_pause, autocvar_g_vehicle_cyberchop_health_regen, dt, false, RES_HEALTH);

	if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(vehic, vehic.wait, vehicle_energy, autocvar_g_vehicle_cyberchop_energy, autocvar_g_vehicle_cyberchop_energy_regen_pause, autocvar_g_vehicle_cyberchop_energy_regen, dt, false);

	vehic.bomb1.alpha = vehic.bomb2.alpha = (time - vehic.lip) / (vehic.delay - vehic.lip);
	this.vehicle_reload2 = bound(0, vehic.bomb1.alpha * 100, 100);
	this.vehicle_ammo2 = (this.vehicle_reload2 == 100) ? 100 : 0;

	VEHICLE_UPDATE_PLAYER_RESOURCE(this, vehic, health, cyberchop, RES_HEALTH);
	VEHICLE_UPDATE_PLAYER(this, vehic, energy, cyberchop);
	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(this, vehic, shield, cyberchop);

	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = 0;
}

void cyberchop_blowup(entity this, entity toucher)
{
	//if not try this:
	this.deadflag	= DEAD_DEAD;
	this.vehicle_exit(this, VHEF_NORMAL);
	RadiusDamage (this, this.enemy, autocvar_g_vehicle_cyberchop_blowup_coredamage, 
		autocvar_g_vehicle_cyberchop_blowup_edgedamage, 
		autocvar_g_vehicle_cyberchop_blowup_radius, NULL, NULL, 
		autocvar_g_vehicle_cyberchop_blowup_forceintensity, 
		DEATH_VH_CCHOP_DEATH.m_id, DMG_NOWEP, NULL);

	this.alpha		  = -1;
	set_movetype(this, MOVETYPE_NONE);
	this.effects		= EF_NODRAW;
	this.colormod	   = '0 0 0';
	this.avelocity	  = '0 0 0';
	this.velocity	   = '0 0 0';

	setorigin(this, this.pos1);
	settouch(this, func_null);
	this.nextthink = 0;
}

void cyberchop_diethink(entity this)
{
	//if not, try this: 
	if(time >= this.wait)
	{
		cyberchop_blowup(this, NULL);
		return;
	}

	if(random() < 0.05)
	{
		sound (this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);
		Send_Effect(EFFECT_EXPLOSION_SMALL, randomvec() * 80 + (this.origin + '0 0 100'), '0 0 0', 1);
	}
	this.nextthink = time;

	CSQCMODEL_AUTOUPDATE(this);
}

// if we dont do this every now and then, the cyberchop's rotors
// stop working, presumably due to angle overflow
void cyberchop_rotor_anglefix(entity this)
{
	this.gun1.angles_y = anglemods(this.gun1.angles_y);
	this.gun2.angles_y = anglemods(this.gun2.angles_y);
	this.nextthink = time + 15;
}





//TODO: REPLACE GUNNERS WITH ANOTHER WEAPON





bool cyberchop_gunner_frame(entity this, float dt)
{
	entity vehic = this.vehicle.owner;
	//entity gun = this.vehicle;
	return = true;

	setorigin(this, vehic.origin);
	this.velocity = vehic.velocity;

	VEHICLE_UPDATE_PLAYER_RESOURCE(this, vehic, health, cyberchop, RES_HEALTH);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(this, vehic, shield, cyberchop);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * this.vehicle_reload1) + ('0 1 0' *(1 - this.vehicle_reload1)), ((this == vehic.gunner1) ? 1 : 2));

	vehic.solid = SOLID_BBOX;
	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = 0;
}

void cyberchop_gunner_exit(entity this, int _exitflag)
{
	entity player = this.owner.gunner1;
	entity gunner = this;
	entity vehic = gunner.owner;

	if(IS_REAL_CLIENT(player))
	{
		msg_entity = player;
		WriteByte(MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, player);

		WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, 0);
		WriteAngle(MSG_ONE, vehic.angles.y);
		WriteAngle(MSG_ONE, 0);
	}

	CSQCVehicleSetup(player, HUD_NORMAL);
	setsize(player, STAT(PL_MIN, player), STAT(PL_MAX, player));

	player.takedamage     = DAMAGE_AIM;
	player.solid          = SOLID_SLIDEBOX;
	set_movetype(player, MOVETYPE_WALK);
	player.effects       &= ~EF_NODRAW;
	player.alpha          = 1;
	player.PlayerPhysplug = func_null;
	player.view_ofs       = STAT(PL_VIEW_OFS, NULL);
	player.event_damage   = PlayerDamage;
	STAT(HUD, player)            = HUD_NORMAL;
	player.teleportable	  = TELEPORT_NORMAL;
	player.vehicle_enter_delay = time + 2;

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		player.(weaponentity).m_switchweapon = gunner.(weaponentity).m_switchweapon;
		delete(gunner.(weaponentity));
	}

	fixedmakevectors(vehic.angles);

	vector spot = real_origin(gunner);
	spot = spot + v_up * 128 + v_forward * 300 + v_right * 150;
	spot = vehicles_findgoodexit(vehic, player, spot);

	// TODO: figure a way to move player out of the gunner

	player.velocity = 0.75 * vehic.velocity + normalize(spot - vehic.origin) * 200;
	player.velocity_z += 10;

	gunner.phase = time + 5;
	gunner.vehicle_hudmodel.viewmodelforclient = gunner;

	MUTATOR_CALLHOOK(VehicleExit, player, gunner);

	vehic.gunner1 = NULL;
	player.vehicle = NULL;
}

bool cyberchop_gunner_enter(entity this, entity player)
{
	entity vehic = this;
	entity gunner = vehic.gun1;

	if(vehic.gunner1)
		return false; // already occupied

	if(vehic.gun1.phase > time)
		return false; // too soon

	vehic.gunner1 = player;

	player.vehicle 			= gunner;
	player.angles 			= vehic.angles;
	player.takedamage 		= DAMAGE_NO;
	player.solid 			= SOLID_NOT;
	player.alpha 			= -1;
	set_movetype(player, MOVETYPE_NOCLIP);
	player.event_damage 	= func_null;
	player.view_ofs 		= '0 0 0';
	STAT(HUD, player) 				= STAT(HUD, gunner);
	player.teleportable 	= false;
	player.PlayerPhysplug 	= gunner.PlayerPhysplug;
	player.vehicle_ammo1 	= vehic.vehicle_ammo1;
	player.vehicle_ammo2 	= vehic.vehicle_ammo2;
	player.vehicle_reload1 	= vehic.vehicle_reload1;
	player.vehicle_reload2 	= vehic.vehicle_reload2;
	player.vehicle_energy 	= vehic.vehicle_energy;
	UNSET_ONGROUND(player);

	RemoveGrapplingHooks(player);

	gunner.vehicle_exit = cyberchop_gunner_exit;
	gunner.vehicle_hudmodel.viewmodelforclient = player;

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];

		gunner.(weaponentity) = new(temp_wepent);
		gunner.(weaponentity).m_switchweapon = player.(weaponentity).m_switchweapon;
	}

	if(IS_REAL_CLIENT(player))
	{
		msg_entity = player;
		WriteByte(MSG_ONE, 		SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, 	gunner.vehicle_viewport);

		WriteByte(MSG_ONE, 		SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, 	gunner.angles_x + vehic.angles_x); // tilt
		WriteAngle(MSG_ONE, 	gunner.angles_y + vehic.angles_y); // yaw
		WriteAngle(MSG_ONE, 	0); // roll
	}

	CSQCVehicleSetup(player, STAT(HUD, player));

	MUTATOR_CALLHOOK(VehicleEnter, player, gunner);

	return true;
}

///
bool cyberchop_impulse(entity this, int _imp)
{
	switch(_imp)
	{
		case IMP_weapon_group_1.impulse:
			STAT(VEHICLESTAT_W2MODE, this.vehicle) = RSM_BOMB;
			CSQCVehicleSetup(this, 0);
			return true;
		case IMP_weapon_group_2.impulse:
			STAT(VEHICLESTAT_W2MODE, this.vehicle) = RSM_FLARE;
			CSQCVehicleSetup(this, 0);
			return true;

		case IMP_weapon_next_byid.impulse:
		case IMP_weapon_next_bypriority.impulse:
		case IMP_weapon_next_bygroup.impulse:
			STAT(VEHICLESTAT_W2MODE, this.vehicle) += 1;
			if(STAT(VEHICLESTAT_W2MODE, this.vehicle) > RSM_LAST)
				STAT(VEHICLESTAT_W2MODE, this.vehicle) = RSM_FIRST;

			CSQCVehicleSetup(this, 0);
			return true;
		case IMP_weapon_last.impulse:
		case IMP_weapon_prev_byid.impulse:
		case IMP_weapon_prev_bypriority.impulse:
		case IMP_weapon_prev_bygroup.impulse:
			STAT(VEHICLESTAT_W2MODE, this.vehicle) -= 1;
			if(STAT(VEHICLESTAT_W2MODE, this.vehicle) < RSM_FIRST)
				STAT(VEHICLESTAT_W2MODE, this.vehicle) = RSM_LAST;

			CSQCVehicleSetup(this, 0);
			return true;

		/*
		case IMP_weapon_drop.impulse: // toss gun, could be used to exit?
			break;
		case IMP_weapon_reload.impulse: // Manual minigun reload?
			break;
		*/
	}
	return false;
}

bool vehicles_valid_pilot(entity this, entity toucher);

void cyberchop_touch(entity this, entity toucher)
{
	if(autocvar_g_vehicles_enter) { return; }

	if(this.gunner1 != NULL)
	{
		vehicles_touch(this, toucher);
		return;
	}

	if(vehicles_valid_pilot(this, toucher))
	{
		if(time >= toucher.vehicle_enter_delay && time >= this.gun1.phase)
			if(cyberchop_gunner_enter(this, toucher))
				return;
	}

	vehicles_touch(this, toucher);
}

spawnfunc(vehicle_cyberchop)
{
	if(!autocvar_g_vehicle_cyberchop) { delete(this); return; }
	if(!vehicle_initialize(this, VEH_CCHOP, false)) { delete(this); return; }
}

spawnfunc(vehicle_cyberchop_milspec)
{
	if(this.spawnflags < 64)
		this.spawnflags |= 64; // so we spawn weapons
	if(this.colormap < 1024)
		this.colormap = 1024; // black
	spawnfunc_vehicle_cyberchop(this);
}

METHOD(CyberChop, vr_impact, void(CyberChop thisveh, entity instance))
{
	if(autocvar_g_vehicle_cyberchop_bouncepain)
		vehicles_impact(instance, autocvar_g_vehicle_cyberchop_bouncepain_x, autocvar_g_vehicle_cyberchop_bouncepain_y, autocvar_g_vehicle_cyberchop_bouncepain_z);
}
METHOD(CyberChop, vr_enter, void(CyberChop thisveh, entity instance))
{
	STAT(VEHICLESTAT_W2MODE, instance) = RSM_BOMB;
    instance.owner.PlayerPhysplug = cyberchop_takeoff;

	settouch(instance, cyberchop_touch);
	instance.nextthink = 0;
	set_movetype(instance, MOVETYPE_BOUNCE);
	//instance.vehicle_weapon2mode = RSM_BOMB;
	instance.owner.PlayerPhysplug = cyberchop_takeoff;
	set_movetype(instance, MOVETYPE_BOUNCEMISSILE);
	instance.solid          = SOLID_SLIDEBOX;
	instance.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
	instance.tur_head.exteriormodeltoclient = instance.owner;

	instance.delay = time + autocvar_g_vehicle_cyberchop_bombs_refire;
	instance.lip   = time;

	CSQCVehicleSetup(instance.owner, 0);
	instance.owner.vehicle_health = (GetResource(instance, RES_HEALTH) / autocvar_g_vehicle_cyberchop_health) * 100;
	instance.owner.vehicle_shield = (instance.vehicle_shield / autocvar_g_vehicle_cyberchop_shield) * 100;

	if(instance.owner.flagcarried)
		setorigin(instance.owner.flagcarried, '-20 0 96');
}
METHOD(CyberChop, vr_think, void(CyberChop thisveh, entity instance))
{
	if(!instance.owner)
	{	
		if(instance.gunner1)
		{
			if(instance.gun1.vehicle_exit)
				instance.gun1.vehicle_exit(instance.gun1, VHEF_EJECT);
			instance.phase = 0;
			if(gettouch(instance))
				gettouch(instance)(instance, instance.gunner1);
		}

	}
}
METHOD(CyberChop, vr_death, void(CyberChop thisveh, entity actor))
{
	CSQCModel_UnlinkEntity(actor); // networking the death scene would be a nightmare
	
	SetResourceExplicit(actor, RES_HEALTH, 0);
    actor.event_damage		= func_null;
    actor.solid				= SOLID_CORPSE;
    actor.takedamage		= DAMAGE_NO;
    actor.deadflag			= DEAD_DYING;
    set_movetype(actor, MOVETYPE_BOUNCE);
    setthink(actor, cyberchop_diethink);
    actor.nextthink			= time;
    actor.wait				= time + 5 + (random() * 5);

    Send_Effect(EFFECT_EXPLOSION_MEDIUM, findbetterlocation (actor.origin, 16), '0 0 0', 1);

    actor.velocity_z += 600;

    actor.avelocity = '0 0.5 1' * (random() * 400);
    actor.avelocity -= '0 0.5 1' * (random() * 400);

    actor.colormod = '-0.5 -0.5 -0.5';
    settouch(actor, cyberchop_blowup);
	//cyberchop_die(actor);
}
METHOD(CyberChop, vr_spawn, void(CyberChop thisveh, entity actor))
{
	if(!actor.gun1)
	{
		entity spinner;
	
		// for some reason, autosizing of the shield entity refuses to work for this one so set it up in advance.
		actor.vehicle_shieldent = spawn();
		actor.vehicle_shieldent.effects = EF_LOWPRECISION;
		_setmodel(actor.vehicle_shieldent, "models/vhshield.md3");
		setattachment(actor.vehicle_shieldent, actor, "");
		setorigin(actor.vehicle_shieldent, real_origin(actor) - actor.origin);
		actor.vehicle_shieldent.scale       = 512 / vlen(actor.maxs - actor.mins);
		setthink(actor.vehicle_shieldent, shieldhit_think);
		actor.vehicle_shieldent.alpha = -1;
		actor.vehicle_shieldent.effects = EF_LOWPRECISION | EF_NODRAW;
	 
		actor.frame = 0;

		actor.bomb1 = spawn();
		actor.bomb2 = spawn();
		actor.gun1  = spawn();
		actor.gun2  = spawn();

		_setmodel(actor.bomb1,"null");
		_setmodel(actor.bomb2,"null");
		_setmodel(actor.gun1, "null");
		_setmodel(actor.gun2, "null");
		//_setmodel(actor.tur_head, "models/vehicles/cyberchopedits_body.iqm");

		setattachment(actor.bomb1, actor, "bombmount_left");
		setattachment(actor.bomb2, actor, "bombmount_right");
		//setattachment(actor.tur_head, actor,"root");

		// FIXMODEL guns mounts to angled bones
		actor.bomb1.angles = actor.angles;
		actor.angles = '0 0 0';

		actor.angles = actor.bomb1.angles;
		actor.bomb1.angles = '0 0 0';

		spinner = spawn();
		spinner.owner = actor;
		setmodel(spinner, MDL_CYBERCHOP_ROTOR);
		setattachment(spinner, actor, "engine_left");
		set_movetype(spinner, MOVETYPE_NOCLIP);
		spinner.avelocity = '0 90 0';
		//spinner.scale = 3.0;
		actor.bomb1.gun1 = spinner;

		spinner = spawn();
		spinner.owner = actor;
		setmodel(spinner, MDL_CYBERCHOP_SMALLROTOR);
		setattachment(spinner, actor, "engine_right");
		set_movetype(spinner, MOVETYPE_NOCLIP);
		spinner.avelocity = '0 -90 0';
		actor.bomb1.gun2 = spinner;

		// sigh
		setthink(actor.bomb1, cyberchop_rotor_anglefix);
		actor.bomb1.nextthink = time;

		setattachment(actor.vehicle_viewport, actor, "tag_camera");
		//actor.mass               = 1 ;
		actor.mass               = autocvar_g_vehicle_cyberchop_mass;
		
		actor.vehicle_flags |= VHF_MULTISLOT;

		actor.gun1.owner = actor;
			
		setattachment(actor.gun1, actor, "tag_pass1");
		
		vehicle_addplayerslot(actor, actor.gun1, HUD_BUMBLEBEE_GUN, MDL_Null, cyberchop_gunner_frame, cyberchop_gunner_exit, cyberchop_gunner_enter);

		//actor.rotorbox = spawn();
	}

	actor.frame = 0;
	SetResourceExplicit(actor, RES_HEALTH, autocvar_g_vehicle_cyberchop_health);
	actor.vehicle_shield = autocvar_g_vehicle_cyberchop_shield;
	set_movetype(actor, MOVETYPE_TOSS);
	actor.solid = SOLID_SLIDEBOX;
	actor.vehicle_energy = 1;

	actor.bomb1.gun1.avelocity_y = 90;
	actor.bomb1.gun2.avelocity_y = -90;

	//setsize(actor, CYBERCHOP_MIN, CYBERCHOP_MAX );
	actor.delay = time;
		
	actor.bouncefactor = autocvar_g_vehicle_cyberchop_bouncefactor;
	actor.bouncestop = autocvar_g_vehicle_cyberchop_bouncestop;
	actor.damageforcescale = 0.25;

	float oldy = actor.angles_y;
	actor.angles_y = 0; // so we can do the init math correctly

	// spinning rotor death area
	//float CYBERCHOPROTOR_HEIGHT = 145;
	//helicopter_rotor_spawn_hitbox(0, actor, actor.rotorbox, '-140 -140 -1', '140 140 1', 0, 0, CYBERCHOPROTOR_HEIGHT);

	actor.angles_y = oldy; // done doing the init math, reset.
}
METHOD(CyberChop, vr_setup, void(CyberChop thisveh, entity instance))
{
	string bodymodel;

	//if(instance.spawnflags)
	//{
		//RandomSelection_Init();

		//RandomSelection_Add(NULL, 0, string_null, 1, 1);
		//RandomSelection_Add(NULL, 32, string_null, 1, 1);
		//RandomSelection_Add(NULL, 64, string_null, 1, 1);
		//RandomSelection_Add(NULL, 128, string_null, 1, 1);

		//instance.spawnflags = RandomSelection_chosen_float;
		instance.spawnflags |= 128;
	//}
			
	if(instance.spawnflags >= 64)
		bodymodel = MDL_CYBERCHOP_MILSPEC.model_str();
	else
		bodymodel = VEH_CCHOP.mdl;

	instance.mdl = bodymodel; // override default function
	_setmodel(instance, instance.mdl);
	setsize(instance, thisveh.m_mins, thisveh.m_maxs);

	if(autocvar_g_vehicle_cyberchop_energy)
	if(autocvar_g_vehicle_cyberchop_energy_regen)
		instance.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_cyberchop_shield)
		instance.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_cyberchop_shield_regen)
		instance.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_cyberchop_health_regen)
		instance.vehicle_flags |= VHF_HEALTHREGEN;

	instance.vehicle_exit = cyberchop_exit;
	instance.respawntime = autocvar_g_vehicle_cyberchop_respawntime;
	SetResourceExplicit(instance, RES_HEALTH, autocvar_g_vehicle_cyberchop_health);
	instance.vehicle_shield = autocvar_g_vehicle_cyberchop_shield;
	instance.max_health = GetResource(instance, RES_HEALTH);
}

#elif defined(CSQC)

METHOD(CyberChop, vr_hud, void(CyberChop thisveh))
{
	Vehicles_drawHUD(VEH_CCHOP.m_icon, "vehicle_chopper_weapon1", "vehicle_chopper_weapon2",
					 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
					 "vehicle_icon_ammo2", autocvar_hud_progressbar_vehicles_ammo1_color);
}
METHOD(CyberChop, vr_crosshair, void(CyberChop thisveh, entity player))
{
	//Vehicles_drawCrosshair(vCROSS_LOCK);
	string crosshair;

    switch(weapon2mode)
    {
        case RSM_FLARE: crosshair = vCROSS_RAIN;  break;
        case RSM_BOMB:  crosshair = vCROSS_GUIDE; break;
        default:        crosshair = vCROSS_GUIDE;
    }

    vector tmpSize = '0 0 0';
    if(weapon2mode != RSM_FLARE && !spectatee_status)
    {
        vector where;

        if(!dropmark)
        {
            dropmark = new(cyberchop_dropmark);
            dropmark.owner = player;
            dropmark.gravity = 1;
            dropmark.dphitcontentsmask = DPCONTENTS_SOLID;
            dropmark.solid = SOLID_CORPSE;
			set_movetype(dropmark, MOVETYPE_BOUNCE);
        }

        float reload2 = STAT(VEHICLESTAT_RELOAD2) * 0.01;
        if(reload2 == 1)
        {
            setorigin(dropmark, pmove_org);
            dropmark.velocity = pmove_vel;
            tracetoss(dropmark, player);

            where = project_3d_to_2d(trace_endpos);

            setorigin(dropmark, trace_endpos);

            if (!(where.z < 0 || where.x < 0 || where.y < 0 || where.x > vid_conwidth || where.y > vid_conheight))
            {
                tmpSize = draw_getimagesize(vCROSS_DROP) * autocvar_cl_vehicles_crosshair_size;
                where.x -= tmpSize.x * 0.5;
                where.y -= tmpSize.y * 0.5;
                where.z = 0;
                drawpic(where, vCROSS_DROP, tmpSize, '0 1 0', autocvar_crosshair_alpha * 0.9, DRAWFLAG_ADDITIVE);
                drawpic(where, vCROSS_DROP, tmpSize, '0 1 0', autocvar_crosshair_alpha * 0.6, DRAWFLAG_NORMAL); // Ensure visibility against bright bg
            }
            dropmark.cnt = time + 5;
        }
        else
        {
            if(dropmark.cnt > time)
            {
                where = project_3d_to_2d(dropmark.origin);

                if (!(where.z < 0 || where.x < 0 || where.y < 0 || where.x > vid_conwidth || where.y > vid_conheight))
                {
                    tmpSize = draw_getimagesize(vCROSS_DROP) * autocvar_cl_vehicles_crosshair_size * 1.25;
                    where.x -= tmpSize.x * 0.5;
                    where.y -= tmpSize.y * 0.5;
                    where.z = 0;
                    drawpic(where, vCROSS_DROP, tmpSize, '1 0 0', autocvar_crosshair_alpha * 0.9, DRAWFLAG_ADDITIVE);
                    drawpic(where, vCROSS_DROP, tmpSize, '1 0 0', autocvar_crosshair_alpha * 0.6, DRAWFLAG_NORMAL); // Ensure visibility against bright bg
                }
            }
        }
    }
	Vehicles_drawCrosshair(crosshair);
}
METHOD(CyberChop, vr_setup, void(CyberChop thisveh, entity actor))
{
	AuxiliaryXhair[0].axh_image = vCROSS_HINT; // Minigun1
	AuxiliaryXhair[1].axh_image = vCROSS_LOCK; // Minigun2
}

#endif // CSQC

#ifdef CSQC
REGISTER_MUTATOR(cl_cyberchop, true);

MUTATOR_HOOKFUNCTION(cl_cyberchop, DamageInfo)
{
	entity dmgent = M_ARGV(0, entity);
	int w_deathtype = M_ARGV(1, int);

	// the deathtype is marked as vehicle death, so we can get away with not performing the additional traces!
	if(DEATH_ENT(w_deathtype) == DEATH_VH_CCHOP_DEATH)
	{
		sound(dmgent, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, 0.2);
		pointparticles(EFFECT_EXPLOSION_BIG, dmgent.origin, w_backoff * 1000, 1);
	}
}
#endif