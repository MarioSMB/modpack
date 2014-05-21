#ifdef REGISTER_VEHICLE
REGISTER_VEHICLE(
/* VEH_##id   */ TANKLL48,
/* function   */ v_tankll48,
/* spawnflags */ VHF_DMGSHAKE,
/* mins,maxs  */ '-185 -185 2', '185 185 136',
/* model	  */ "models/vehicles/tankll48.md3",
/* head_model */ "models/vehicles/tankll48_turret.md3",
/* hud_model  */ "null",
/* tags	   	  */ "tag_turret", "tag_camera", "",
/* netname	  */ "tankll48",
/* fullname   */ _("LL48")
);
#else
#ifdef SVQC
float autocvar_g_vehicle_tankll48;

float autocvar_g_vehicle_tankll48_respawntime;

float autocvar_g_vehicle_tankll48_speed_stop;
float autocvar_g_vehicle_tankll48_speed_strafe;
float autocvar_g_vehicle_tankll48_speed_walk;
float autocvar_g_vehicle_tankll48_turnspeed;
float autocvar_g_vehicle_tankll48_turnspeed_strafe;
float autocvar_g_vehicle_tankll48_movement_inertia;

float autocvar_g_vehicle_tankll48_springlength;
float autocvar_g_vehicle_tankll48_springup;
float autocvar_g_vehicle_tankll48_springblend;
float autocvar_g_vehicle_tankll48_tiltlimit;

float autocvar_g_vehicle_tankll48_head_pitchlimit_down;
float autocvar_g_vehicle_tankll48_head_pitchlimit_up;
float autocvar_g_vehicle_tankll48_head_turnlimit;
float autocvar_g_vehicle_tankll48_head_turnspeed;

float autocvar_g_vehicle_tankll48_turret_turnlimit;

float autocvar_g_vehicle_tankll48_health;
float autocvar_g_vehicle_tankll48_health_regen;
float autocvar_g_vehicle_tankll48_health_regen_pause;

float autocvar_g_vehicle_tankll48_shield;
float autocvar_g_vehicle_tankll48_shield_regen;
float autocvar_g_vehicle_tankll48_shield_regen_pause;

vector autocvar_g_vehicle_tankll48_bouncepain;

float autocvar_g_vehicle_tankll48_cannon_damage;
float autocvar_g_vehicle_tankll48_cannon_ammo;
float autocvar_g_vehicle_tankll48_cannon_speed;
float autocvar_g_vehicle_tankll48_cannon_edgedamage;
float autocvar_g_vehicle_tankll48_cannon_force;
float autocvar_g_vehicle_tankll48_cannon_radius;
float autocvar_g_vehicle_tankll48_cannon_damage2;
float autocvar_g_vehicle_tankll48_cannon_speedaccel;
float autocvar_g_vehicle_tankll48_cannon_ammo_max;
float autocvar_g_vehicle_tankll48_cannon_ammo_regen;
float autocvar_g_vehicle_tankll48_cannon_ammo_regen_pause;

void tankll48_cannon_explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_vehicle_tankll48_cannon_damage, autocvar_g_vehicle_tankll48_cannon_edgedamage, autocvar_g_vehicle_tankll48_cannon_radius, world, world, autocvar_g_vehicle_tankll48_cannon_force, self.projectiledeathtype, other);

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
	entity player, tank;
	float ftmp;

	if(intermission_running)
	{
		self.vehicle.velocity = '0 0 0';
		return 1;
	}

	player = self;
	tank = self.vehicle;
	self   = tank;

	vehicles_painframe();

	player.BUTTON_ZOOM	  = 0;
	player.BUTTON_CROUCH	= 0;
	player.switchweapon	 = 0;
	player.vehicle_weapon2mode = tank.vehicle_weapon2mode;


#if 1 // 0 to enable per-gun impact aux crosshairs
	// Avarage gun impact point's -> aux cross
	ad = gettaginfo(tank.tur_head, gettagindex(tank.tur_head, "tag_cannon_pivot"));
	vf = v_forward;
	ad += gettaginfo(tank.tur_head, gettagindex(tank.tur_head, "tag_cannon_pivot_0"));
	vf += v_forward;
	ad = ad * 0.5;
	v_forward = vf * 0.5;
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, tank);
	UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
#else
	ad = gettaginfo(tank.gun1, gettagindex(tank.gun1, "barrels"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, tank);
	UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
	vf = ad;
	ad = gettaginfo(tank.gun2, gettagindex(tank.gun2, "barrels"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, tank);
	UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 1);
	ad = 0.5 * (ad + vf);
#endif

	crosshair_trace(player);
	ad = vectoangles(normalize(trace_endpos - ad));
	ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tank.angles), AnglesTransform_FromAngles(ad))) - tank.tur_head.angles;
	ad = AnglesTransform_Normalize(ad, TRUE);
	//UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
	
	// rotate turret and head
	ftmp = autocvar_g_vehicle_tankll48_head_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    tank.gun3.angles_y = bound(autocvar_g_vehicle_tankll48_turret_turnlimit * -1, tank.gun3.angles_y + ad_y, autocvar_g_vehicle_tankll48_turret_turnlimit);
	tank.tur_head.angles_y = bound(autocvar_g_vehicle_tankll48_head_turnlimit * -1, tank.tur_head.angles_y + ad_y, autocvar_g_vehicle_tankll48_head_turnlimit);
	

	// Pitch head
	ad_x = bound(ftmp * -1, ad_x, ftmp);
	tank.tur_head.angles_x = bound(autocvar_g_vehicle_tankll48_head_pitchlimit_down, tank.tur_head.angles_x + ad_x, autocvar_g_vehicle_tankll48_head_pitchlimit_up);


	//fixedmakevectors(tank.angles);
	makevectors(tank.angles + '-2 0 0' * tank.angles_x);

	movelib_groundalign4point(autocvar_g_vehicle_tankll48_springlength, autocvar_g_vehicle_tankll48_springup, autocvar_g_vehicle_tankll48_springblend, autocvar_g_vehicle_tankll48_tiltlimit);

	if(tank.flags & FL_ONGROUND)
	{
		if(tank.frame == 4 && self.tur_head.wait != 0)
		{
			tank.frame = 5;
		}

		if(vlen(player.movement) == 0)
		{
			if(self.sound_nexttime < time || self.delay != 3)
			{
				self.delay = 3;
				self.sound_nexttime = time + 6.009; //soundlength("vehicles/tankll48_idle.wav");
				//dprint("tankll48_idle:", ftos(soundlength("vehicles/tankll48_idle.wav")), "\n");
				sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
			}
			movelib_beak_simple(autocvar_g_vehicle_tankll48_speed_stop);
			tank.frame = 5;
		}
		else
		{
			// Turn Body
			if(player.movement_x == 0 && player.movement_y != 0)
				ftmp = autocvar_g_vehicle_tankll48_turnspeed_strafe * sys_frametime;
			else
				ftmp = autocvar_g_vehicle_tankll48_turnspeed * sys_frametime;

			ftmp = bound(-ftmp, tank.tur_head.angles_y, ftmp);
			tank.angles_y = anglemods(tank.angles_y + ftmp);
			tank.tur_head.angles_y -= ftmp;

			if(player.movement_x != 0)
			{
				if(player.movement_x > 0)
				{
					player.movement_x = 1;
					tank.frame = 0;
				}
				else if(player.movement_x < 0)
				{
					player.movement_x = -1;
					tank.frame = 1;
				}
				player.movement_y = 0;
				movelib_move_simple(normalize(v_forward * player.movement_x),autocvar_g_vehicle_tankll48_speed_walk,autocvar_g_vehicle_tankll48_movement_inertia);

				if(self.sound_nexttime < time || self.delay != 1)
				{
					self.delay = 1;
					self.sound_nexttime = time + 3.991; //soundlength("vehicles/tankll48_walk.wav");
					sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
					//dprint("tankll48_walk:", ftos(soundlength("vehicles/tankll48_walk.wav")), "\n");
				}
			}
			else if(player.movement_y != 0)
			{
				if(player.movement_y < 0)
				{
					player.movement_y = -1;
					tank.frame = 2;
				}
				else if(player.movement_y > 0)
				{
					player.movement_y = 1;
					tank.frame = 3;
				}
				
				movelib_move_simple(normalize(v_right * player.movement_y),autocvar_g_vehicle_tankll48_speed_strafe,autocvar_g_vehicle_tankll48_movement_inertia);
				if(self.sound_nexttime < time || self.delay != 2)
				{
					self.delay = 2;
					self.sound_nexttime = time + 3.991; //soundlength("vehicles/tankll48_strafe.wav");
					sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
					//dprint("tankll48_strafe:", ftos(soundlength("vehicles/tankll48_strafe.wav")), "\n");
				}
			}
		}
	}

	self.angles_x = bound(-autocvar_g_vehicle_tankll48_tiltlimit, self.angles_x, autocvar_g_vehicle_tankll48_tiltlimit);
	self.angles_z = bound(-autocvar_g_vehicle_tankll48_tiltlimit, self.angles_z, autocvar_g_vehicle_tankll48_tiltlimit);

	if(!forbidWeaponUse(player))
	if(player.BUTTON_ATCK && tank.vehicle_ammo1 >= autocvar_g_vehicle_tankll48_cannon_ammo && tank.tur_head.attack_finished_single <= time)
	{
		tank.cnt = time;
		entity missile = spawn();
		vector v = gettaginfo(self.gun1, gettagindex(self.gun1, "barrels"));
		W_SetupShot_ProjectileSize (player, '-3 -3 -3', '3 3 3', FALSE, 5, "weapons/campingrifle_fire_morebass.wav", CH_WEAPON_A, autocvar_g_vehicle_tankll48_cannon_damage);
		tank.vehicle_ammo1 -= autocvar_g_vehicle_tankll48_cannon_ammo;
		w_shotorg = v;

		pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
		PROJECTILE_MAKETRIGGER(missile);

		missile.owner = missile.realowner = player;
		missile.bot_dodge = TRUE;
		missile.bot_dodgerating = autocvar_g_vehicle_tankll48_cannon_damage * 2;

		missile.takedamage = DAMAGE_NO;
		missile.event_damage = func_null;
		missile.damagedbycontents = TRUE;
		missile.movetype = MOVETYPE_FLY;

		missile.projectiledeathtype = DEATH_VH_TANKLL48;
		setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

		setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
		W_SetupProjVelocity_Basic(missile, autocvar_g_vehicle_tankll48_cannon_speed, 0);

		missile.touch = tankll48_cannon_touch;

		missile.think = tankll48_cannon_think;
		missile.cnt = time + 15;
		missile.nextthink = time;
		missile.flags = FL_PROJECTILE;
		missile.pos1 = missile.velocity;
			
		CSQCProjectile(missile, TRUE, PROJECTILE_CANNONBALL, FALSE);
	}
	else
		vehicles_regen(tank.cnt, vehicle_ammo1, autocvar_g_vehicle_tankll48_cannon_ammo_max,
										   autocvar_g_vehicle_tankll48_cannon_ammo_regen_pause,
										   autocvar_g_vehicle_tankll48_cannon_ammo_regen, frametime, FALSE);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(tank.dmg_time, vehicle_shield, autocvar_g_vehicle_tankll48_shield, autocvar_g_vehicle_tankll48_shield_regen_pause, autocvar_g_vehicle_tankll48_shield_regen, frametime, TRUE);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(tank.dmg_time, vehicle_health, autocvar_g_vehicle_tankll48_health, autocvar_g_vehicle_tankll48_health_regen_pause, autocvar_g_vehicle_tankll48_health_regen, frametime, FALSE);

	player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

	if(tank.gun2.cnt <= time)
		player.vehicle_reload2 = 100;
	else
		player.vehicle_reload2 = 100 - ((tank.gun2.cnt - time) / tank.attack_finished_single) * 100;

	setorigin(player, tank.origin + '0 0 1' * tank.maxs_z);
	player.velocity = tank.velocity;

	VEHICLE_UPDATE_PLAYER(player, health, tankll48);

	if(self.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(player, shield, tankll48);

	self = player;
	return 1;
}

void tankll48_exit(float eject)
{
	entity e;
	vector spot;

	e = findchain(classname,"tankll48_rocket");
	while(e)
	{
		if(e.owner == self.owner)
		{
			e.realowner = self.owner;
			e.owner = world;
		}
		e = e.chain;
	}

	self.think = vehicles_think;
	self.nextthink = time;
	self.frame = 5;
	self.movetype = MOVETYPE_WALK;

	if(!self.owner)
		return;

	makevectors(self.angles);
	if(eject)
	{
		spot = self.origin + v_forward * 300 + '0 0 64';
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
			spot = self.origin + v_forward * 328 + '0 0 64';
			spot = vehicles_findgoodexit(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 356 + '0 0 64';
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
			sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
			pointparticles(particleeffectnum("explosion_big"), self.origin + '0 0 100', '0 0 0', 1);
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
			sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
			pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
		}
		self.nextthink = time + 0.1;
		return;
	}

	entity h, g1, g2, b;
	b = spawn();
	h = spawn();
	g1 = spawn();
	g2 = spawn();

	setmodel(b, "models/vehicles/tankll48.md3");
	setmodel(h, "models/vehicles/tankll48_turret.md3");
	setmodel(g1, "models/vehicles/tankll48_cannon.md3");
	setmodel(g2, "models/vehicles/tankt27_gear.iqm");

	setorigin(b, self.origin);
	b.frame = 11;
	b.angles = self.angles;
	setsize(b, self.mins, self.maxs);

	setorigin(h, gettaginfo(self, gettagindex(self, "tag_head")));
	h.movetype = MOVETYPE_BOUNCE;
	h.solid = SOLID_BBOX;
	h.velocity = v_up * (500 + random() * 500) + randomvec() * 128;
	h.modelflags = MF_ROCKET;
	h.effects = EF_FLAME | EF_LOWPRECISION;
	h.avelocity = randomvec() * 360;

	h.alpha = 1;
	h.cnt = time + (3.5 * random());
	h.fade_rate = 1 / min(self.respawntime, 10);
	h.fade_time = time;
	h.think = tankll48_headfade;
	h.nextthink = time;

	setorigin(g1, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint01")));
	g1.movetype = MOVETYPE_TOSS;
	g1.solid = SOLID_CORPSE;
	g1.velocity = v_forward * 700 + (randomvec() * 32);
	g1.avelocity = randomvec() * 180;

	setorigin(g2, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint02")));
	g2.movetype = MOVETYPE_TOSS;
	g2.solid = SOLID_CORPSE;
	g2.velocity = v_forward * 700 + (randomvec() * 32);
	g2.avelocity = randomvec() * 180;

	h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

	SUB_SetFade(b,  time + 5, min(self.respawntime, 1));
	//SUB_SetFade(h,  time, min(self.respawntime, 10));
	SUB_SetFade(g1, time, min(self.respawntime, 10));
	SUB_SetFade(g2, time, min(self.respawntime, 10));

	RadiusDamage (self, self.enemy, 250, 15, 250, world, world, 250, DEATH_VH_TANK_DEATH, world);

	self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = -1;
	self.movetype = MOVETYPE_NONE;
	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_NOT;
	self.tur_head.effects &= ~EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void spawnfunc_vehicle_tankll48()
{
	if(!autocvar_g_vehicles_extra) { remove(self); return; }
	if(!autocvar_g_vehicle_tankll48) { remove(self); return; }
	if(!vehicle_initialize(VEH_TANKLL48, FALSE)) { remove(self); return; }
}

float v_tankll48(float req)
{
	switch(req)
	{
		case VR_IMPACT:
		{
			if(autocvar_g_vehicle_tankll48_bouncepain)
				vehicles_impact(autocvar_g_vehicle_tankll48_bouncepain_x, autocvar_g_vehicle_tankll48_bouncepain_y, autocvar_g_vehicle_tankll48_bouncepain_z);
		
			return TRUE;
		}
		case VR_ENTER:
		{
			self.movetype = MOVETYPE_WALK;
			CSQCVehicleSetup(self.owner, 0);
			self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_tankll48_health) * 100;
			self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_tankll48_shield) * 100;
			self.gun2.colormap = self.colormap;

			if(self.owner.flagcarried)
			{
				setattachment(self.owner.flagcarried, self.tur_head, "");
				setorigin(self.owner.flagcarried, '-20 0 120');
			}
		
			return TRUE;
		}
		case VR_THINK:
		{
			if(self.flags & FL_ONGROUND)
				movelib_beak_simple(autocvar_g_vehicle_tankll48_speed_stop);
			
			return TRUE;
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
			self.colormod			= self.tur_head.colormod = self.gun1.colormod = self.gun2.colormod = '-1 -1 -1';
			self.frame				= 10;
			self.movetype			= MOVETYPE_TOSS;
			
			CSQCModel_UnlinkEntity(); // networking the death scene would be a nightmare

			return TRUE;
		}
		case VR_SPAWN:
		{
			if(!self.gun1)
			{
				self.gun3 = spawn(); // Will be an angle stabilizer for the rotating turret
				self.gun3.alpha = -1;
				setmodel(self.gun3, "models/vehicles/anglestabilizer.iqm");
				setattachment(self.gun3, self.tur_head, "tag_cannon_pivot");

				self.gun1 = spawn();
				self.gun2 = spawn();
				setmodel(self.gun1, "models/mountedguns/shlacgun.iqm");
				setmodel(self.gun2, "models/vehicles/tankll48_cannon.md3");
				setattachment(self.gun1, self.tur_head, "tag_gunpivot2");
				setattachment(self.gun2, self.tur_head, "tag_cannon_pivot");
				self.gravity = 2;
				self.mass = 5000;
			}

			self.frame = 5;
			self.tur_head.frame = 1;
			self.movetype = MOVETYPE_WALK;
			self.solid = SOLID_SLIDEBOX;
			self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = 1;
			self.colormod = self.tur_head.colormod = self.gun1.colormod = self.gun2.colormod = '1 1 1';
			self.gun2.colormap = self.colormap;
			self.tur_head.angles = '0 0 0';
			self.vehicle_exit = tankll48_exit;

			setorigin(self, self.pos1 + '0 0 128');
			self.angles = self.pos2;
			self.damageforcescale = 0.03;
			self.vehicle_health = autocvar_g_vehicle_tankll48_health;
			self.vehicle_shield = autocvar_g_vehicle_tankll48_shield;
			
			self.PlayerPhysplug = tankll48_frame;

			return TRUE;
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
			self.pushable = TRUE; // tankll48 can use jumppads
			setorigin(self.tur_head, '0 0 110');
			setorigin(self.vehicle_hudmodel, '0 0 50');

			return TRUE;
		}
		case VR_PRECACHE:
		{
			precache_model ("models/vhshield.md3");
			precache_model ("models/vehicles/tankll48.md3");
			precache_model ("models/vehicles/tankll48_turret.md3");
			precache_model ( "models/uziflash.md3");
			
			precache_model ( "models/sphere/sphexp.md3");
			precache_model ( "models/vehicles/tankt27_wheel.iqm");
			precache_model ( "models/vehicles/tankt27_gear.iqm");
			precache_model ( "models/vehicles/tankll48_cannon.md3");
			precache_model ( "models/vehicles/anglestabilizer.iqm");
			precache_model ( "models/mountedguns/shlacgun.iqm");

			precache_sound ("weapons/rocket_impact.wav");
			precache_sound ("weapons/campingrifle_fire_morebass.wav");
			
			precache_sound ( "machines/generator_loop_speedup_pitchdown.wav");
			precache_sound ( "machines/generator_loop_pitchdown.wav");

			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
#define tank_ico  "gfx/vehicles/tankll48.tga"

float v_tankll48(float req)
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

			ammo1   *= 0.01;
			shield  *= 0.01;
			vh_health  *= 0.01;
			reload2 *= 0.01;

			pic2size = draw_getimagesize(tank_ico) * (autocvar_cl_vehicles_hudscale * 0.8);
			picloc = picsize * 0.5 - pic2size * 0.5;
			if(vh_health < 0.25)
				drawpic(hudloc + picloc, tank_ico, pic2size,  '1 0 0' + '0 1 1' * sin(time * 8),  1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, tank_ico, pic2size,  '1 1 1' * vh_health  + '1 0 0' * (1 - vh_health),  1, DRAWFLAG_NORMAL);
			//drawpic(hudloc + picloc, tank_rkt, pic2size,  '1 1 1' * reload2 + '1 0 0' * (1 - reload2), 1, DRAWFLAG_NORMAL);
			//drawpic(hudloc + picloc, tank_mgun, pic2size, '1 1 1' * ammo1   + '1 0 0' * (1 - ammo1),   1, DRAWFLAG_NORMAL);
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
					vehicle_alarm(self, CH_PAIN_SINGLE, "vehicles/alarm_shield.wav");
				}
				drawpic(hudloc + picloc, hud_sh_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			}
			else
			{
				drawpic(hudloc + picloc, hud_sh_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
				if(alarm2time)
				{
					vehicle_alarm(self, CH_PAIN_SINGLE, "misc/null.wav");
					alarm2time = 0;
				}
			}

		// Minigun bar
			picsize = draw_getimagesize(hud_ammo1_bar) * autocvar_cl_vehicles_hudscale;
			picloc = '450 69 0' * autocvar_cl_vehicles_hudscale;
			drawsetcliparea(hudloc_x + picloc_x, picloc_y, picsize_x * ammo1, vid_conheight);
			drawpic(hudloc + picloc, hud_ammo1_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			drawresetcliparea();
		// ..  and icon
			picsize = draw_getimagesize(hud_ammo2_ico) * autocvar_cl_vehicles_hudscale;
			picloc = '664 60 0' * autocvar_cl_vehicles_hudscale;
			if(ammo1 < 0.2)
				drawpic(hudloc + picloc, hud_ammo2_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, hud_ammo2_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
				
			if (scoreboard_showscores)
				HUD_DrawScoreboard();
			
			return TRUE;
		}
		case VR_SETUP:
		{
			// Minigun1
			AuxiliaryXhair[0].axh_image   = "gfx/vehicles/axh-ring.tga";
			AuxiliaryXhair[0].axh_scale   = 0.25;
			// Minigun2
			AuxiliaryXhair[1].axh_image   = "gfx/vehicles/axh-ring.tga";
			AuxiliaryXhair[1].axh_scale   = 0.25;
			// Rocket
			AuxiliaryXhair[2].axh_image   = "gfx/vehicles/axh-special1.tga";
			AuxiliaryXhair[2].axh_scale   = 0.5;
		
			return TRUE;
		}
		case VR_PRECACHE:
		{
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_VEHICLE
