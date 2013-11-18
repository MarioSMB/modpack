#ifdef REGISTER_VEHICLE
REGISTER_VEHICLE(
/* VEH_##id   */ BUMBLEBEE,
/* function   */ v_bumblebee,
/* spawnflags */ VHF_DMGSHAKE,
/* mins,maxs  */ '-130 -130 -130', '130 130 130',
/* model	  */ "models/vehicles/bumblebee_body.dpm",
/* head_model */ "",
/* hud_model  */ "models/vehicles/spiderbot_cockpit.dpm",
/* tags	   	  */ "", "", "tag_viewport",
/* netname	  */ "bumblebee",
/* fullname   */ _("Bumblebee")
);
#else

const float BRG_SETUP = 2;
const float BRG_START = 4;
const float BRG_END = 8;

#ifdef SVQC
float autocvar_g_vehicle_bumblebee_speed_forward;
float autocvar_g_vehicle_bumblebee_speed_strafe;
float autocvar_g_vehicle_bumblebee_speed_up;
float autocvar_g_vehicle_bumblebee_speed_down;
float autocvar_g_vehicle_bumblebee_turnspeed;
float autocvar_g_vehicle_bumblebee_pitchspeed;
float autocvar_g_vehicle_bumblebee_pitchlimit;
float autocvar_g_vehicle_bumblebee_friction;

float autocvar_g_vehicle_bumblebee_energy;
float autocvar_g_vehicle_bumblebee_energy_regen;
float autocvar_g_vehicle_bumblebee_energy_regen_pause;

float autocvar_g_vehicle_bumblebee_health;
float autocvar_g_vehicle_bumblebee_health_regen;
float autocvar_g_vehicle_bumblebee_health_regen_pause;

float autocvar_g_vehicle_bumblebee_shield;
float autocvar_g_vehicle_bumblebee_shield_regen;
float autocvar_g_vehicle_bumblebee_shield_regen_pause;

float autocvar_g_vehicle_bumblebee_cannon_cost;
float autocvar_g_vehicle_bumblebee_cannon_damage;
float autocvar_g_vehicle_bumblebee_cannon_radius;
float autocvar_g_vehicle_bumblebee_cannon_refire;
float autocvar_g_vehicle_bumblebee_cannon_speed;
float autocvar_g_vehicle_bumblebee_cannon_spread;
float autocvar_g_vehicle_bumblebee_cannon_force;

float autocvar_g_vehicle_bumblebee_cannon_ammo;
float autocvar_g_vehicle_bumblebee_cannon_ammo_regen;
float autocvar_g_vehicle_bumblebee_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_bumblebee_cannon_lock = 0;

float autocvar_g_vehicle_bumblebee_cannon_turnspeed;
float autocvar_g_vehicle_bumblebee_cannon_pitchlimit_down;
float autocvar_g_vehicle_bumblebee_cannon_pitchlimit_up;
float autocvar_g_vehicle_bumblebee_cannon_turnlimit_in;
float autocvar_g_vehicle_bumblebee_cannon_turnlimit_out;


float autocvar_g_vehicle_bumblebee_raygun_turnspeed;
float autocvar_g_vehicle_bumblebee_raygun_pitchlimit_down;
float autocvar_g_vehicle_bumblebee_raygun_pitchlimit_up;
float autocvar_g_vehicle_bumblebee_raygun_turnlimit_sides;

float autocvar_g_vehicle_bumblebee_raygun_range;
float autocvar_g_vehicle_bumblebee_raygun_dps;
float autocvar_g_vehicle_bumblebee_raygun_aps;
float autocvar_g_vehicle_bumblebee_raygun_fps;

float autocvar_g_vehicle_bumblebee_raygun;
float autocvar_g_vehicle_bumblebee_healgun_hps;
float autocvar_g_vehicle_bumblebee_healgun_hmax;
float autocvar_g_vehicle_bumblebee_healgun_aps;
float autocvar_g_vehicle_bumblebee_healgun_amax;
float autocvar_g_vehicle_bumblebee_healgun_sps;
float autocvar_g_vehicle_bumblebee_healgun_locktime;

float autocvar_g_vehicle_bumblebee_respawntime;

float autocvar_g_vehicle_bumblebee_blowup_radius;
float autocvar_g_vehicle_bumblebee_blowup_coredamage;
float autocvar_g_vehicle_bumblebee_blowup_edgedamage;
float autocvar_g_vehicle_bumblebee_blowup_forceintensity;
var vector autocvar_g_vehicle_bumblebee_bouncepain;

var float autocvar_g_vehicle_bumblebee = 0;


float bumble_raygun_send(entity to, float sf);

void bumblebee_fire_cannon(entity _gun, string _tagname, entity _owner)
{
	vector v = gettaginfo(_gun, gettagindex(_gun, _tagname));
	vehicles_projectile("bigplasma_muzzleflash", "weapons/flacexp3.wav",
						v, normalize(v_forward + randomvec() * autocvar_g_vehicle_bumblebee_cannon_spread) * autocvar_g_vehicle_bumblebee_cannon_speed,
						autocvar_g_vehicle_bumblebee_cannon_damage, autocvar_g_vehicle_bumblebee_cannon_radius, autocvar_g_vehicle_bumblebee_cannon_force,  0,
						DEATH_VH_BUMB_GUN, PROJECTILE_BUMBLE_GUN, 0, TRUE, TRUE, _owner);
}

float bumblebee_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;

	vehic.solid = SOLID_NOT;
	//setorigin(gunner, vehic.origin);
	gunner.velocity = vehic.velocity;

	float _in, _out;
	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
	if((gun == vehic.gun1))
	{
		_in = autocvar_g_vehicle_bumblebee_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_bumblebee_cannon_turnlimit_out;
		setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		_in = autocvar_g_vehicle_bumblebee_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_bumblebee_cannon_turnlimit_in;
		setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);
	}

	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	vector ad;

	if(autocvar_g_vehicle_bumblebee_cannon_lock)
	{
		if(gun.lock_time < time)
			gun.enemy = world;

		if(trace_ent)
			if(trace_ent.movetype)
				if(trace_ent.takedamage)
					if(!trace_ent.deadflag)
					{
						if(teamplay)
						{
							if(trace_ent.team != gunner.team)
							{
								gun.enemy = trace_ent;
								gun.lock_time = time + 5;
							}
						}
						else
						{
							gun.enemy = trace_ent;
							gun.lock_time = time + 5;
						}
					}
	}

	if(gun.enemy)
	{
		float i, distance, impact_time;

		vector vf = real_origin(gun.enemy);
		vector _vel = gun.enemy.velocity;
		if(gun.enemy.movetype == MOVETYPE_WALK)
			_vel_z *= 0.1;


		ad = vf;
		for(i = 0; i < 4; ++i)
		{
			distance = vlen(ad - gunner.origin);
			impact_time = distance / autocvar_g_vehicle_bumblebee_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  autocvar_g_vehicle_bumblebee_cannon_pitchlimit_down * -1, autocvar_g_vehicle_bumblebee_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_bumblebee_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  autocvar_g_vehicle_bumblebee_cannon_pitchlimit_down * -1, autocvar_g_vehicle_bumblebee_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_bumblebee_cannon_turnspeed);

	if(gunner.BUTTON_ATCK)
		if(time > gun.attack_finished_single)
			if(gun.vehicle_energy >= autocvar_g_vehicle_bumblebee_cannon_cost)
			{
				gun.vehicle_energy -= autocvar_g_vehicle_bumblebee_cannon_cost;
				bumblebee_fire_cannon(gun, "fire", gunner);
				gun.delay = time;
				gun.attack_finished_single = time + autocvar_g_vehicle_bumblebee_cannon_refire;
			}

	VEHICLE_UPDATE_PLAYER(gunner, health, bumblebee);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, bumblebee);

	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);

	UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), 0);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));

	vehic.solid = SOLID_BBOX;
	gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_bumblebee_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void bumblebee_gunner_exit(float _exitflag)
{
	if(IS_REAL_CLIENT(self))
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, self);

		WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, 0);
		WriteAngle(MSG_ONE, self.vehicle.angles_y);
		WriteAngle(MSG_ONE, 0);
	}

	CSQCVehicleSetup(self, HUD_NORMAL);
	setsize(self, PL_MIN, PL_MAX);

	self.takedamage     = DAMAGE_AIM;
	self.solid          = SOLID_SLIDEBOX;
	self.movetype       = MOVETYPE_WALK;
	self.effects        &= ~EF_NODRAW;
	self.alpha          = 1;
	self.PlayerPhysplug = func_null;
	self.view_ofs       = PL_VIEW_OFS;
	self.event_damage   = PlayerDamage;
	self.hud            = HUD_NORMAL;
	self.switchweapon   = self.vehicle.switchweapon;

    vh_player = self;
    vh_vehicle = self.vehicle;
    MUTATOR_CALLHOOK(VehicleExit);
    self = vh_player;
    self.vehicle = vh_vehicle;

	self.vehicle.vehicle_hudmodel.viewmodelforclient = self.vehicle;

	fixedmakevectors(self.vehicle.owner.angles);

	if(self == self.vehicle.owner.gunner1)
	{
		self.vehicle.owner.gunner1 = world;
	}
	else if(self == self.vehicle.owner.gunner2)
	{
		self.vehicle.owner.gunner2 = world;
		v_right *= -1;
	}
	else
		dprint("^1self != gunner1 or gunner2, this is a BIG PROBLEM, tell tZork this happend.\n");

	vector spot = self.vehicle.owner.origin + + v_up * 128 + v_right * 300;
	spot = vehicles_findgoodexit(spot);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float bumblebee_gunner_enter()
{
	RemoveGrapplingHook(other);
	entity _gun, _gunner;
	if(!self.gunner1)
	{
		_gun = self.gun1;
		_gunner = self.gunner1;
		self.gunner1 = other;
	}
	else if(!self.gunner2)
	{
		_gun = self.gun2;
		_gunner = self.gunner2;
		self.gunner2 = other;
	}
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = bumblebee_gunner_exit;

	other.angles            = self.angles;
	other.takedamage        = DAMAGE_NO;
	other.solid             = SOLID_NOT;
	other.movetype          = MOVETYPE_NOCLIP;
	other.alpha             = -1;
	other.event_damage      = func_null;
	other.view_ofs          = '0 0 0';
	other.hud               = _gun.hud;
	other.PlayerPhysplug    = _gun.PlayerPhysplug;
	other.vehicle_ammo1     = self.vehicle_ammo1;
	other.vehicle_ammo2     = self.vehicle_ammo2;
	other.vehicle_reload1   = self.vehicle_reload1;
	other.vehicle_reload2   = self.vehicle_reload2;
	other.vehicle_energy    = self.vehicle_energy;
	other.PlayerPhysplug    = bumblebee_gunner_frame;
	other.flags             &= ~FL_ONGROUND;

	msg_entity = other;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, _gun.vehicle_viewport);
	WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
	WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
	WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y);    // yaw
	WriteAngle(MSG_ONE, 0);                             // roll
	_gun.vehicle_hudmodel.viewmodelforclient = other;

	CSQCVehicleSetup(other, other.hud);

    vh_player = other;
    vh_vehicle = _gun;
    MUTATOR_CALLHOOK(VehicleEnter);
    other = vh_player;
    _gun = vh_vehicle;

	return TRUE;
}

float vehicles_valid_pilot()
{
	if (!IS_PLAYER(other))
		return FALSE;

	if(other.deadflag != DEAD_NO)
		return FALSE;

	if(other.vehicle != world)
		return FALSE;

	if (!IS_REAL_CLIENT(other))
		if(!autocvar_g_vehicles_allow_bots)
			return FALSE;

	if(teamplay && other.team != self.team)
		return FALSE;

	return TRUE;
}

void bumblebee_touch()
{
	if(self.gunner1 != world && self.gunner2 != world)
	{
		vehicles_touch();
		return;
	}

	if(vehicles_valid_pilot())
	{
		if(self.gun1.phase <= time)
			if(bumblebee_gunner_enter())
				return;

		if(self.gun2.phase <= time)
			if(bumblebee_gunner_enter())
				return;
	}

	vehicles_touch();
}

void bumblebee_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_bumblebee_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_bumblebee_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_bumblebee_cannon_ammo_regen * frametime);

	if(self.gun2.delay + autocvar_g_vehicle_bumblebee_cannon_ammo_regen_pause < time)
		self.gun2.vehicle_energy = min(autocvar_g_vehicle_bumblebee_cannon_ammo,
									   self.gun2.vehicle_energy + autocvar_g_vehicle_bumblebee_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_bumblebee_shield, autocvar_g_vehicle_bumblebee_shield_regen_pause, autocvar_g_vehicle_bumblebee_shield_regen, frametime, TRUE);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_bumblebee_health, autocvar_g_vehicle_bumblebee_health_regen_pause, autocvar_g_vehicle_bumblebee_health_regen, frametime, FALSE);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_bumblebee_energy, autocvar_g_vehicle_bumblebee_energy_regen_pause, autocvar_g_vehicle_bumblebee_energy_regen, frametime, FALSE);

}

float bumblebee_pilot_frame()
{
	entity pilot, vehic;
	vector newvel;

	pilot = self;
	vehic = self.vehicle;
	self   = vehic;


	if(vehic.deadflag != DEAD_NO)
	{
		self = pilot;
		pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
		return 1;
	}

	bumblebee_regen();

	crosshair_trace(pilot);

	vector vang;
	float ftmp;

	vang = vehic.angles;
	newvel = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
	vang_x *= -1;
	newvel_x *= -1;
	if(newvel_x > 180)  newvel_x -= 360;
	if(newvel_x < -180) newvel_x += 360;
	if(newvel_y > 180)  newvel_y -= 360;
	if(newvel_y < -180) newvel_y += 360;

	ftmp = shortangle_f(pilot.v_angle_y - vang_y, vang_y);
	if(ftmp > 180)  ftmp -= 360;
	if(ftmp < -180) ftmp += 360;
	vehic.avelocity_y = bound(-autocvar_g_vehicle_bumblebee_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_bumblebee_turnspeed);

	// Pitch
	ftmp = 0;
	if(pilot.movement_x > 0 && vang_x < autocvar_g_vehicle_bumblebee_pitchlimit)
		ftmp = 4;
	else if(pilot.movement_x < 0 && vang_x > -autocvar_g_vehicle_bumblebee_pitchlimit)
		ftmp = -8;

	newvel_x = bound(-autocvar_g_vehicle_bumblebee_pitchlimit, newvel_x , autocvar_g_vehicle_bumblebee_pitchlimit);
	ftmp = vang_x - bound(-autocvar_g_vehicle_bumblebee_pitchlimit, newvel_x + ftmp, autocvar_g_vehicle_bumblebee_pitchlimit);
	vehic.avelocity_x = bound(-autocvar_g_vehicle_bumblebee_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_bumblebee_pitchspeed);

	vehic.angles_x = anglemods(vehic.angles_x);
	vehic.angles_y = anglemods(vehic.angles_y);
	vehic.angles_z = anglemods(vehic.angles_z);

	makevectors('0 1 0' * vehic.angles_y);
	newvel = vehic.velocity * -autocvar_g_vehicle_bumblebee_friction;

	if(pilot.movement_x != 0)
	{
		if(pilot.movement_x > 0)
			newvel += v_forward  * autocvar_g_vehicle_bumblebee_speed_forward;
		else if(pilot.movement_x < 0)
			newvel -= v_forward  * autocvar_g_vehicle_bumblebee_speed_forward;
	}

	if(pilot.movement_y != 0)
	{
		if(pilot.movement_y < 0)
			newvel -= v_right * autocvar_g_vehicle_bumblebee_speed_strafe;
		else if(pilot.movement_y > 0)
			newvel += v_right * autocvar_g_vehicle_bumblebee_speed_strafe;
		ftmp = newvel * v_right;
		ftmp *= frametime * 0.1;
		vehic.angles_z = bound(-15, vehic.angles_z + ftmp, 15);
	}
	else
	{
		vehic.angles_z *= 0.95;
		if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
			vehic.angles_z = 0;
	}

	if(pilot.BUTTON_CROUCH)
		newvel -=   v_up * autocvar_g_vehicle_bumblebee_speed_down;
	else if(pilot.BUTTON_JUMP)
		newvel +=  v_up * autocvar_g_vehicle_bumblebee_speed_up;

	vehic.velocity  += newvel * frametime;
	pilot.velocity = pilot.movement  = vehic.velocity;


	if(autocvar_g_vehicle_bumblebee_healgun_locktime)
	{
		if(vehic.tur_head.lock_time < time || vehic.tur_head.enemy.deadflag)
			vehic.tur_head.enemy = world;

		if(trace_ent)
		if(trace_ent.movetype)
		if(trace_ent.takedamage)
		if(!trace_ent.deadflag)
		{
			if(teamplay)
			{
				if(trace_ent.team == pilot.team)
				{
					vehic.tur_head.enemy = trace_ent;
					vehic.tur_head.lock_time = time + autocvar_g_vehicle_bumblebee_healgun_locktime;
				}
			}
			else
			{
				vehic.tur_head.enemy = trace_ent;
				vehic.tur_head.lock_time = time + autocvar_g_vehicle_bumblebee_healgun_locktime;
			}
		}

		if(vehic.tur_head.enemy)
		{
			trace_endpos = real_origin(vehic.tur_head.enemy);
			UpdateAuxiliaryXhair(pilot, trace_endpos, '0 0.75 0', 0);
		}
	}

	vang = vehicle_aimturret(vehic, trace_endpos, self.gun3, "fire",
					  autocvar_g_vehicle_bumblebee_raygun_pitchlimit_down * -1,  autocvar_g_vehicle_bumblebee_raygun_pitchlimit_up,
					  autocvar_g_vehicle_bumblebee_raygun_turnlimit_sides * -1,  autocvar_g_vehicle_bumblebee_raygun_turnlimit_sides,  autocvar_g_vehicle_bumblebee_raygun_turnspeed);

	if((pilot.BUTTON_ATCK || pilot.BUTTON_ATCK2) && (vehic.vehicle_energy > autocvar_g_vehicle_bumblebee_raygun_dps * sys_frametime || autocvar_g_vehicle_bumblebee_raygun == 0))
	{
		vehic.gun3.enemy.realowner = pilot;
		vehic.gun3.enemy.effects &= ~EF_NODRAW;

		vehic.gun3.enemy.hook_start = gettaginfo(vehic.gun3, gettagindex(vehic.gun3, "fire"));
		vehic.gun3.enemy.SendFlags |= BRG_START;

		traceline(vehic.gun3.enemy.hook_start, vehic.gun3.enemy.hook_start + v_forward * autocvar_g_vehicle_bumblebee_raygun_range, MOVE_NORMAL, vehic);

		if(trace_ent)
		{
			if(autocvar_g_vehicle_bumblebee_raygun)
			{
				Damage(trace_ent, vehic, pilot, autocvar_g_vehicle_bumblebee_raygun_dps * sys_frametime, DEATH_GENERIC, trace_endpos, v_forward * autocvar_g_vehicle_bumblebee_raygun_fps * sys_frametime);
				vehic.vehicle_energy -= autocvar_g_vehicle_bumblebee_raygun_aps * sys_frametime;
			}
			else
			{
				if(trace_ent.deadflag == DEAD_NO)
					if((teamplay && trace_ent.team == pilot.team) || !teamplay)
					{

						if(trace_ent.vehicle_flags & VHF_ISVEHICLE)
						{
							if(autocvar_g_vehicle_bumblebee_healgun_sps && trace_ent.vehicle_health <= trace_ent.max_health)
								trace_ent.vehicle_shield = min(trace_ent.vehicle_shield + autocvar_g_vehicle_bumblebee_healgun_sps * frametime, trace_ent.tur_head.max_health);

							if(autocvar_g_vehicle_bumblebee_healgun_hps)
								trace_ent.vehicle_health = min(trace_ent.vehicle_health + autocvar_g_vehicle_bumblebee_healgun_hps * frametime, trace_ent.max_health);
						}
						else if(IS_CLIENT(trace_ent))
						{
							if(trace_ent.health <= autocvar_g_vehicle_bumblebee_healgun_hmax && autocvar_g_vehicle_bumblebee_healgun_hps)
								trace_ent.health = min(trace_ent.health + autocvar_g_vehicle_bumblebee_healgun_hps * frametime, autocvar_g_vehicle_bumblebee_healgun_hmax);

							if(trace_ent.armorvalue <= autocvar_g_vehicle_bumblebee_healgun_amax && autocvar_g_vehicle_bumblebee_healgun_aps)
								trace_ent.armorvalue = min(trace_ent.armorvalue + autocvar_g_vehicle_bumblebee_healgun_aps * frametime, autocvar_g_vehicle_bumblebee_healgun_amax);

							trace_ent.health = min(trace_ent.health + autocvar_g_vehicle_bumblebee_healgun_hps * frametime, autocvar_g_vehicle_bumblebee_healgun_hmax);
						}
						else if(IS_TURRET(trace_ent))
						{
							if(trace_ent.health  <= trace_ent.max_health && autocvar_g_vehicle_bumblebee_healgun_hps)
								trace_ent.health = min(trace_ent.health + autocvar_g_vehicle_bumblebee_healgun_hps * frametime, trace_ent.max_health);
							//else ..hmmm what? ammo?

							trace_ent.SendFlags |= TNSF_STATUS;
						}
					}
			}
		}

		vehic.gun3.enemy.hook_end = trace_endpos;
		setorigin(vehic.gun3.enemy, trace_endpos);
		vehic.gun3.enemy.SendFlags |= BRG_END;

		vehic.wait = time + 1;
	}
	else
		vehic.gun3.enemy.effects |= EF_NODRAW;
	/*{
		if(vehic.gun3.enemy)
			remove(vehic.gun3.enemy);

		vehic.gun3.enemy = world;
	}
	*/

	VEHICLE_UPDATE_PLAYER(pilot, health, bumblebee);
	VEHICLE_UPDATE_PLAYER(pilot, energy, bumblebee);

	pilot.vehicle_ammo1 = (vehic.gun1.vehicle_energy / autocvar_g_vehicle_bumblebee_cannon_ammo) * 100;
	pilot.vehicle_ammo2 = (vehic.gun2.vehicle_energy / autocvar_g_vehicle_bumblebee_cannon_ammo) * 100;

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(pilot, shield, bumblebee);

	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
	setorigin(pilot, vehic.origin + v_up * 48 + v_forward * 160);

	pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = pilot.BUTTON_CROUCH = 0;
	self = pilot;

	return 1;
}

void bumblebee_exit(float eject)
{
	self.touch = vehicles_touch;
	self.think = vehicles_think;
	self.nextthink = time;

	if(!self.owner)
		return;

	fixedmakevectors(self.angles);
	vector spot;
	if(vlen(self.velocity) > autocvar_g_vehicle_bumblebee_speed_forward * 0.5)
		spot = self.origin + v_up * 128 + v_forward * 200;
	else
		spot = self.origin + v_up * 128 - v_forward * 200;

	spot = vehicles_findgoodexit(spot);

	// Hide beam
	if(self.gun3.enemy || !wasfreed(self.gun3.enemy)) {
		self.gun3.enemy.effects |= EF_NODRAW;
    }

	self.owner.velocity = 0.75 * self.vehicle.velocity + normalize(spot - self.vehicle.origin) * 200;
	self.owner.velocity_z += 10;
	setorigin(self.owner, spot);

	antilag_clear(self.owner);
    self.owner = world;
}

void bumblebee_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_bumblebee_blowup_coredamage,
				 autocvar_g_vehicle_bumblebee_blowup_edgedamage,
				 autocvar_g_vehicle_bumblebee_blowup_radius, self,
				 autocvar_g_vehicle_bumblebee_blowup_forceintensity,
				 DEATH_VH_BUMB_DEATH, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);

	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;

	remove(self);
}

void bumblebee_diethink()
{
	if(time >= self.wait)
		self.think = bumblebee_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

float bumble_raygun_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_BUMBLE_RAYGUN);

	WriteByte(MSG_ENTITY, sf);
	if(sf & BRG_SETUP)
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.realowner));
		WriteByte(MSG_ENTITY, self.realowner.team);
		WriteByte(MSG_ENTITY, self.cnt);
	}

	if(sf & BRG_START)
	{
		WriteCoord(MSG_ENTITY, self.hook_start_x);
		WriteCoord(MSG_ENTITY, self.hook_start_y);
		WriteCoord(MSG_ENTITY, self.hook_start_z);
	}

	if(sf & BRG_END)
	{
		WriteCoord(MSG_ENTITY, self.hook_end_x);
		WriteCoord(MSG_ENTITY, self.hook_end_y);
		WriteCoord(MSG_ENTITY, self.hook_end_z);
	}

	return TRUE;
}

void spawnfunc_vehicle_bumblebee()
{
	if(!autocvar_g_vehicle_bumblebee) { remove(self); return; }
	if(!vehicle_initialize(VEH_BUMBLEBEE, FALSE)) { remove(self); return; }
}

float v_bumblebee(float req)
{
	switch(req)
	{
		case VR_IMPACT:
		{
			if(autocvar_g_vehicle_bumblebee_bouncepain)
				vehicles_impact(autocvar_g_vehicle_bumblebee_bouncepain_x, autocvar_g_vehicle_bumblebee_bouncepain_y, autocvar_g_vehicle_bumblebee_bouncepain_z);
				
			return TRUE;
		}
		case VR_ENTER:
		{
			self.touch = bumblebee_touch;
			self.nextthink = 0;
			self.movetype = MOVETYPE_BOUNCEMISSILE;
			return TRUE;
		}
		case VR_THINK:
		{
			self.movetype = MOVETYPE_TOSS;
			
			self.angles_z *= 0.8;
			self.angles_x *= 0.8;
			
			self.nextthink = time + 0.05;
			
			if(!self.owner)
			{
				entity oldself = self;		
				if(self.gunner1)
				{
					self = self.gunner1;
					oldself.gun1.vehicle_exit(VHEF_EJECT);
					entity oldother = other;
					other = self;
					self = oldself;
					self.phase = 0;
					self.touch();
					other = oldother;
					return TRUE;
				}
				
				if(self.gunner2)
				{
					self = self.gunner2;
					oldself.gun2.vehicle_exit(VHEF_EJECT);
					entity oldother = other;
					other = self;
					self = oldself;
					self.phase = 0;
					self.touch();
					other = oldother;
					return TRUE;
				}		
			}
			
			return TRUE;
		}
		case VR_DEATH:
		{
			entity oldself = self;
	
			// Hide beam
			if(self.gun3.enemy || !wasfreed(self.gun3.enemy))
				self.gun3.enemy.effects |= EF_NODRAW;
			
			if(self.gunner1)
			{
				self = self.gunner1;
				oldself.gun1.vehicle_exit(VHEF_EJECT);
				self = oldself;
			}

			if(self.gunner2)
			{
				self = self.gunner2;
				oldself.gun2.vehicle_exit(VHEF_EJECT);
				self = oldself;
			}

			self.vehicle_exit(VHEF_EJECT);

			fixedmakevectors(self.angles);
			vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);
			vehicle_tossgib(self.gun2, self.velocity + v_right * -300 + v_up * 100 + randomvec() * 200, "cannon_left", rint(random()), rint(random()), 6, randomvec() * 200);
			vehicle_tossgib(self.gun3, self.velocity + v_forward * 300 + v_up * -100 + randomvec() * 200, "raygun", rint(random()), rint(random()), 6, randomvec() * 300);

			entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);

			if(random() > 0.5)
				_body.touch = bumblebee_blowup;
			else
				_body.touch = func_null;
				
			_body.think = bumblebee_diethink;
			_body.nextthink = time;
			_body.wait = time + 2 + (random() * 8);
			_body.owner = self;
			_body.enemy = self.enemy;
			
			pointparticles(particleeffectnum("explosion_medium"), findbetterlocation(self.origin, 16), '0 0 0', 1);
			
			self.health			= 0;
			self.event_damage	= func_null;
			self.solid			= SOLID_CORPSE;
			self.takedamage		= DAMAGE_NO;
			self.deadflag		= DEAD_DYING;
			self.movetype		= MOVETYPE_NONE;
			self.effects		= EF_NODRAW;
			self.colormod		= '0 0 0';
			self.avelocity		= '0 0 0';
			self.velocity		= '0 0 0';
			self.touch 			= func_null;
			self.nextthink 		= 0;

			setorigin(self, self.pos1);
			return TRUE;
		}
		case VR_SPAWN:
		{
			if(!self.gun1)
			{
				// for some reason, autosizing of the shield entity refuses to work for this one so set it up in advance.
				self.vehicle_shieldent = spawn();
				self.vehicle_shieldent.effects = EF_LOWPRECISION;
				setmodel(self.vehicle_shieldent, "models/vhshield.md3");
				setattachment(self.vehicle_shieldent, self, "");
				setorigin(self.vehicle_shieldent, real_origin(self) - self.origin);
				self.vehicle_shieldent.scale       = 512 / vlen(self.maxs - self.mins);
				self.vehicle_shieldent.think       = shieldhit_think;
				self.vehicle_shieldent.alpha = -1;
				self.vehicle_shieldent.effects = EF_LOWPRECISION | EF_NODRAW;

				self.gun1 = spawn();
				self.gun2 = spawn();
				self.gun3 = spawn();

				self.vehicle_flags |= VHF_MULTISLOT;

				self.gun1.owner = self;
				self.gun2.owner = self;
				self.gun3.owner = self;

				setmodel(self.gun1, "models/vehicles/bumblebee_plasma_right.dpm");
				setmodel(self.gun2, "models/vehicles/bumblebee_plasma_left.dpm");
				setmodel(self.gun3, "models/vehicles/bumblebee_ray.dpm");

				setattachment(self.gun1, self, "cannon_right");
				setattachment(self.gun2, self, "cannon_left");

				// Angled bones are no fun, messes up gun-aim; so work arround it.
				self.gun3.pos1 = self.angles;
				self.angles = '0 0 0';
				vector ofs = gettaginfo(self, gettagindex(self, "raygun"));
				ofs -= self.origin;
				setattachment(self.gun3, self, "");
				setorigin(self.gun3, ofs);
				self.angles = self.gun3.pos1;

				vehicle_addplayerslot(self, self.gun1, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", bumblebee_gunner_frame, bumblebee_gunner_exit);
				vehicle_addplayerslot(self, self.gun2, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", bumblebee_gunner_frame, bumblebee_gunner_exit);

				setorigin(self.vehicle_hudmodel, '50 0 -5');    // Move cockpit forward - down.
				setorigin(self.vehicle_viewport, '5 0 2');    // Move camera forward up

				//fixme-model-bones
				setorigin(self.gun1.vehicle_hudmodel, '90 -27 -23');
				setorigin(self.gun1.vehicle_viewport, '-85 0 50');
				//fixme-model-bones
				setorigin(self.gun2.vehicle_hudmodel, '90 27 -23');
				setorigin(self.gun2.vehicle_viewport, '-85 0 50');

				self.scale = 1.5;
				
				// Raygun beam
				if(self.gun3.enemy == world)
				{			
					self.gun3.enemy = spawn();
					Net_LinkEntity(self.gun3.enemy, TRUE, 0, bumble_raygun_send);
					self.gun3.enemy.SendFlags = BRG_SETUP;			
					self.gun3.enemy.cnt = autocvar_g_vehicle_bumblebee_raygun;			
					self.gun3.enemy.effects = EF_NODRAW | EF_LOWPRECISION;
				}
			}

			self.vehicle_health = autocvar_g_vehicle_bumblebee_health;
			self.vehicle_shield = autocvar_g_vehicle_bumblebee_shield;
			self.solid = SOLID_BBOX;
			self.movetype = MOVETYPE_TOSS;
			self.damageforcescale = 0.025;
			
			self.PlayerPhysplug = bumblebee_pilot_frame;
			
			setorigin(self, self.origin + '0 0 25');
			return TRUE;
		}
		case VR_SETUP:
		{
			if(autocvar_g_vehicle_bumblebee_energy)
			if(autocvar_g_vehicle_bumblebee_energy_regen)
				self.vehicle_flags |= VHF_ENERGYREGEN;

			if(autocvar_g_vehicle_bumblebee_shield)
				self.vehicle_flags |= VHF_HASSHIELD;

			if(autocvar_g_vehicle_bumblebee_shield_regen)
				self.vehicle_flags |= VHF_SHIELDREGEN;

			if(autocvar_g_vehicle_bumblebee_health_regen)
				self.vehicle_flags |= VHF_HEALTHREGEN;
				
			self.vehicle_exit = bumblebee_exit;
			self.respawntime = autocvar_g_vehicle_bumblebee_respawntime;
			self.vehicle_health = autocvar_g_vehicle_bumblebee_health;
			self.max_health = self.vehicle_health;
			self.vehicle_shield = autocvar_g_vehicle_bumblebee_shield;
				
			return TRUE;
		}
		case VR_PRECACHE:
		{
			precache_model("models/vehicles/bumblebee_body.dpm");
			precache_model("models/vehicles/bumblebee_plasma_left.dpm");
			precache_model("models/vehicles/bumblebee_plasma_right.dpm");
			precache_model("models/vehicles/bumblebee_ray.dpm");
			precache_model("models/vehicles/wakizashi_cockpit.dpm");
			precache_model("models/vehicles/spiderbot_cockpit.dpm");
			precache_model("models/vehicles/raptor_cockpit.dpm");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC

void bumble_raygun_draw()
{
	float _len;
	vector _dir;
	vector _vtmp1, _vtmp2;

	_len = vlen(self.origin - self.move_origin);
	_dir = normalize(self.move_origin - self.origin);

	if(self.total_damages < time)
	{
		boxparticles(self.traileffect, self, self.origin, self.origin + _dir * -64, _dir * -_len , _dir * -_len, 1, PARTICLES_USEALPHA);
		boxparticles(self.lip, self, self.move_origin, self.move_origin + _dir * -64, _dir * -200 , _dir * -200, 1, PARTICLES_USEALPHA);
		self.total_damages = time + 0.1;
	}

	float i, df, sz, al;
	for(i = -0.1; i < 0.2; i += 0.1)
	{
		df = DRAWFLAG_NORMAL; //((random() < 0.5) ? DRAWFLAG_ADDITIVE : DRAWFLAG_SCREEN);
		sz = 5 + random() * 5;
		al = 0.25 + random() * 0.5;
		_vtmp1 = self.origin + _dir * _len * (0.25 + i);
		_vtmp1 += (randomvec() * (_len * 0.2) * (frametime * 2));       //self.raygun_l1;
		Draw_CylindricLine(self.origin, _vtmp1, sz, "gfx/colors/white.tga", 1, 1, self.colormod, al, df, view_origin);

		_vtmp2 = self.origin + _dir * _len * (0.5 + i);
		_vtmp2 += (randomvec() * (_len * 0.2) * (frametime * 5));       //self.raygun_l2;
		Draw_CylindricLine(_vtmp1, _vtmp2, sz, "gfx/colors/white.tga", 1, 1, self.colormod, al, df, view_origin);

		_vtmp1 = self.origin + _dir * _len * (0.75 + i);
		_vtmp1 += randomvec() * (_len * 0.2) * (frametime * 10);     //self.raygun_l3;
		Draw_CylindricLine(_vtmp2, _vtmp1, sz, "gfx/colors/white.tga", 1, 1, self.colormod, al, df, view_origin);

		Draw_CylindricLine(_vtmp1, self.move_origin +  randomvec() * 32, sz, "gfx/colors/white.tga", 1, 1, self.colormod, al, df, view_origin);
	}
}

void bumble_raygun_read(float bIsNew)
{
	float sf = ReadByte();

	if(sf & BRG_SETUP)
	{
		self.cnt  = ReadByte();
		self.team = ReadByte();
		self.cnt  = ReadByte();

		if(self.cnt)
			self.colormod = '1 0 0';
		else
			self.colormod = '0 1 0';

		self.traileffect = particleeffectnum("healray_muzzleflash");
		self.lip = particleeffectnum("healray_impact");

		self.draw = bumble_raygun_draw;
	}


	if(sf & BRG_START)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}

	if(sf & BRG_END)
	{
		self.move_origin_x = ReadCoord();
		self.move_origin_y = ReadCoord();
		self.move_origin_z = ReadCoord();
	}
}

float v_bumblebee(float req)
{
	switch(req)
	{
		case VR_HUD:
		{
			if(autocvar_r_letterbox)
				return TRUE;

			vector picsize, hudloc = '0 0 0', pic2size, picloc;

			// Fetch health & ammo stats
			HUD_GETVEHICLESTATS

			picsize = draw_getimagesize(hud_bg) * autocvar_cl_vehicles_hudscale;
			hudloc_y = vid_conheight - picsize_y;
			hudloc_x = vid_conwidth * 0.5 - picsize_x * 0.5;

			drawpic(hudloc, hud_bg, picsize, '1 1 1', autocvar_cl_vehicles_hudalpha, DRAWFLAG_NORMAL);

			shield  *= 0.01;
			vh_health  *= 0.01;
			energy  *= 0.01;
			reload1 *= 0.01;

			pic2size = draw_getimagesize(bumb_ico) * (autocvar_cl_vehicles_hudscale * 0.8);
			picloc = picsize * 0.5 - pic2size * 0.5;

			if(vh_health < 0.25)
				drawpic(hudloc + picloc, bumb_ico, pic2size,  '1 0 0' + '0 1 1' * sin(time * 8),  1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, bumb_ico, pic2size,  '1 1 1' * vh_health  + '1 0 0' * (1 - vh_health),  1, DRAWFLAG_NORMAL);

			drawpic(hudloc + picloc, bumb_lgun, pic2size, '1 1 1' * energy   + '1 0 0' * (1 - energy),   1, DRAWFLAG_NORMAL);
			drawpic(hudloc + picloc, bumb_lgun, pic2size, '1 1 1' * energy   + '1 0 0' * (1 - energy),   1, DRAWFLAG_NORMAL);
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

			ammo1 *= 0.01;
			ammo2 *= 0.01;

		// Gunner1 bar
			picsize = draw_getimagesize(hud_ammo1_bar) * autocvar_cl_vehicles_hudscale;
			picloc = '450 69 0' * autocvar_cl_vehicles_hudscale;
			drawsetcliparea(hudloc_x + picloc_x, picloc_y, picsize_x * ammo1, vid_conheight);
			drawpic(hudloc + picloc, hud_ammo1_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			drawresetcliparea();

		// Right gunner slot occupied?
			if(!AuxiliaryXhair[1].draw2d)
			{
				shield = (picsize_x * 0.5) - (0.5 * stringwidth(_("No right gunner!"), FALSE, '1 0 0' * picsize_y + '0 1 0' * picsize_y));
				drawfill(hudloc + picloc - '0.2 0.2 0', picsize + '0.4 0.4 0', '0.25 0.25 0.25', 0.75, DRAWFLAG_NORMAL);
				drawstring(hudloc + picloc + '1 0 0' * shield, _("No right gunner!"), '1 0 0' * picsize_y + '0 1 0' * picsize_y, '1 0 0' + '0 1 1' * sin(time * 10), 1, DRAWFLAG_NORMAL);
			}

		// ..  and icon
			picsize = 1.5 * draw_getimagesize(hud_energy) * autocvar_cl_vehicles_hudscale;
			picloc = '664 60 0' * autocvar_cl_vehicles_hudscale;
			if(ammo1 < 0.2)
				drawpic(hudloc + picloc, hud_energy, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, hud_energy, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);

		// Gunner2 bar
			picsize = draw_getimagesize(hud_ammo2_bar) * autocvar_cl_vehicles_hudscale;
			picloc = '450 140 0' * autocvar_cl_vehicles_hudscale;
			drawsetcliparea(hudloc_x + picloc_x, picloc_y, picsize_x * ammo2, vid_conheight);
			drawpic(hudloc + picloc, hud_ammo2_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			drawresetcliparea();
		// Left gunner slot occupied?
			if(!AuxiliaryXhair[2].draw2d)
			{
				shield = (picsize_x * 0.5) - (0.5 * stringwidth(_("No left gunner!"), FALSE, '1 0 0' * picsize_y + '0 1 0' * picsize_y));
				drawfill(hudloc + picloc - '0.2 0.2 0', picsize + '0.4 0.4 0', '0.25 0.25 0.25', 0.75, DRAWFLAG_NORMAL);
				drawstring(hudloc + picloc + '1 0 0' * shield, _("No left gunner!"), '1 0 0' * picsize_y + '0 1 0' * picsize_y, '1 0 0' + '0 1 1' * sin(time * 10), 1, DRAWFLAG_NORMAL);
			}

		// ..  and icon
			picsize = 1.5 * draw_getimagesize(hud_energy) * autocvar_cl_vehicles_hudscale;
			picloc = '664 130 0' * autocvar_cl_vehicles_hudscale;
			if(ammo2 < 0.2)
				drawpic(hudloc + picloc, hud_energy, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, hud_energy, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);

			if (scoreboard_showscores)
				HUD_DrawScoreboard();
			else
			{
				picsize = draw_getimagesize(waki_xhair);
				picsize_x *= 0.5;
				picsize_y *= 0.5;
				drawpic('0.5 0 0' * (vid_conwidth - picsize_x) + '0 0.5 0' * (vid_conheight - picsize_y), waki_xhair, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			}
			return TRUE;
		}
		case VR_SETUP:
		{
			// Raygun-locked
			AuxiliaryXhair[0].axh_image   = "gfx/vehicles/axh-bracket.tga";
			AuxiliaryXhair[0].axh_scale   = 0.5;

			// Gunner1
			AuxiliaryXhair[1].axh_image   = "gfx/vehicles/axh-target.tga";
			AuxiliaryXhair[1].axh_scale   = 0.75;

			// Gunner2
			AuxiliaryXhair[2].axh_image   = "gfx/vehicles/axh-target.tga";
			AuxiliaryXhair[2].axh_scale   = 0.75;
			return TRUE;
		}
		case VR_PRECACHE:
		{
			precache_model("models/vehicles/bumblebee_body.dpm");
			precache_model("models/vehicles/bumblebee_plasma_left.dpm");
			precache_model("models/vehicles/bumblebee_plasma_right.dpm");
			precache_model("models/vehicles/bumblebee_ray.dpm");
			precache_model("models/vehicles/wakizashi_cockpit.dpm");
			precache_model("models/vehicles/spiderbot_cockpit.dpm");
			precache_model("models/vehicles/raptor_cockpit.dpm");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_VEHICLE
