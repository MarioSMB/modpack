#ifndef VEHICLE_LIGHTAPC
#define VEHICLE_LIGHTAPC

#ifdef GAMEQC
MODEL(LIGHTAPC_DELUGE, "models/mountedguns/delugegun.iqm");
MODEL(LIGHTAPC_SHLAC, "models/mountedguns/shlacgun.iqm");
MODEL(LIGHTAPC_GRAIL, "models/mountedguns/grailgun.iqm");
MODEL(LIGHTAPC_AUTONEX, "models/mountedguns/autonexgun.iqm");
MODEL(LIGHTAPC_HMG2, "models/mountedguns/browning50gun.iqm");
MODEL(LIGHTAPC_T17MM, "models/mountedguns/t17mmgun.iqm");
MODEL(LIGHTAPC_HVYMINIGUN, "models/mountedguns/gau19gun.iqm");
MODEL(LIGHTAPC_HVYMINIGUN_BARRELS, "models/mountedguns/gau19gun_barrels.iqm");
MODEL(LIGHTAPC_MINIGUN, "models/mountedguns/m134gun.iqm");
MODEL(LIGHTAPC_MINIGUN_BARRELS, "models/mountedguns/m134gun_barrels.iqm");

MODEL(LIGHTAPC_TIRE, "models/vehicles/lightapc_tire.iqm");
MODEL(LIGHTAPC_MOUNT, "models/vehicles/lightapc_mount.iqm");

MODEL(LIGHTAPC_BODY, "models/vehicles/lightapc.dpm");


SOUND(LIGHTAPC_ENGINE_IDLE, "machines/generator_loop_pitchdown");
SOUND(LIGHTAPC_ENGINE_MOVE, "machines/generator_loop_speedup_pitchdown");

SOUND(LIGHTAPC_IMPACT_1, "object/impact_metal_3");
SOUND(LIGHTAPC_IMPACT_2, "object/impact_metal_4");
SOUND(LIGHTAPC_DMG_1, "onslaught/ons_hit2");
SOUND(LIGHTAPC_DMG_2, "onslaught/electricity_explode");
#endif

CLASS(LightAPC, Vehicle)
/* mins       */ ATTRIB(LightAPC, m_mins, vector, '-120 -120 0' * 0.5);
/* maxs       */ ATTRIB(LightAPC, m_maxs, vector, '120 120 250' * 0.5);
/* view offset*/ ATTRIB(LightAPC, view_ofs, vector, '0 0 50');
/* view dist  */ ATTRIB(LightAPC, height, float, 400);
/* model	  */ ATTRIB(LightAPC, mdl, string, "models/vehicles/lightapc.dpm");
/* model	  */ ATTRIB(LightAPC, model, string, "models/vehicles/lightapc.dpm");
/* head_model */ ATTRIB(LightAPC, head_model, string, "null");
/* hud_model  */ ATTRIB(LightAPC, hud_model, string, "null");
/* tags       */ ATTRIB(LightAPC, tag_head, string, "");
/* tags       */ ATTRIB(LightAPC, tag_hud, string, "");
/* tags       */ ATTRIB(LightAPC, tag_view, string, "tag_viewport");
/* netname    */ ATTRIB(LightAPC, netname, string, "lightapc");
/* fullname   */ ATTRIB(LightAPC, vehicle_name, string, _("LightAPC"));
/* icon       */ ATTRIB(LightAPC, m_icon, string, "vehicle_lightapc");
ENDCLASS(LightAPC)
REGISTER_VEHICLE(LIGHTAPC, NEW(LightAPC));

CLASS(LightAPCGunner1, Vehicle)
/* spawnflags */ ATTRIB(LightAPCGunner1, spawnflags, int, VHF_PLAYERSLOT);
/* view offset*/ ATTRIB(LightAPCGunner1, view_ofs, vector, '0 0 15');
/* view dist  */ ATTRIB(LightAPCGunner1, height, float, 20);
/* netname    */ ATTRIB(LightAPCGunner1, netname, string, "lightapcgunner");
/* fullname   */ ATTRIB(LightAPCGunner1, vehicle_name, string, _("LightAPC Gunner"));
/* icon       */ ATTRIB(LightAPCGunner1, m_icon, string, "vehicle_lightapc_weapon1");
ENDCLASS(LightAPCGunner1)
REGISTER_VEHICLE(LIGHTAPCGUNNER1, NEW(LightAPCGunner1));

CLASS(LightAPCGunner2, Vehicle)
/* spawnflags */ ATTRIB(LightAPCGunner2, spawnflags, int, VHF_PLAYERSLOT);
/* view offset*/ ATTRIB(LightAPCGunner2, view_ofs, vector, '0 0 15');
/* view dist  */ ATTRIB(LightAPCGunner2, height, float, 20);
/* netname    */ ATTRIB(LightAPCGunner2, netname, string, "lightapcgunner");
/* fullname   */ ATTRIB(LightAPCGunner2, vehicle_name, string, _("LightAPC Gunner"));
/* icon       */ ATTRIB(LightAPCGunner2, m_icon, string, "vehicle_lightapc_weapon2");
ENDCLASS(LightAPCGunner2)
REGISTER_VEHICLE(LIGHTAPCGUNNER2, NEW(LightAPCGunner2));

CLASS(LightAPCPassenger, Vehicle)
/* spawnflags */ ATTRIB(LightAPCPassenger, spawnflags, int, VHF_PLAYERSLOT);
/* view offset*/ ATTRIB(LightAPCPassenger, view_ofs, vector, '0 0 0');
/* view dist  */ ATTRIB(LightAPCPassenger, height, float, 0);
/* netname    */ ATTRIB(LightAPCPassenger, netname, string, "lightapcpassenger");
/* fullname   */ ATTRIB(LightAPCPassenger, vehicle_name, string, _("LightAPC Passenger"));
/* icon       */ ATTRIB(LightAPCPassenger, m_icon, string, "vehicle_lightapc");
ENDCLASS(LightAPCPassenger)
REGISTER_VEHICLE(LIGHTAPCPASSENGER, NEW(LightAPCPassenger));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC
AUTOCVAR(g_vehicle_lightapc, bool, false, "");

AUTOCVAR(g_vehicle_lightapc_thinkrate, float, 0.05, "");

AUTOCVAR(g_vehicle_lightapc_speed_forward, float, 800, "");
AUTOCVAR(g_vehicle_lightapc_speed_stop, float, 2000, "");

AUTOCVAR(g_vehicle_lightapc_movement_inertia, float, 0.15, "");

AUTOCVAR(g_vehicle_lightapc_cannon_turnspeed, float, 160, "");
AUTOCVAR(g_vehicle_lightapc_cannon_pitchlimit_down, float, 60, "");
AUTOCVAR(g_vehicle_lightapc_cannon_pitchlimit_up, float, 60, "");
AUTOCVAR(g_vehicle_lightapc_cannon_turnlimit_in, float, 20, "");
AUTOCVAR(g_vehicle_lightapc_cannon_turnlimit_out, float, 80, "");

AUTOCVAR(g_vehicle_lightapc_tiltlimit, float, 90, "");
AUTOCVAR(g_vehicle_lightapc_springlength, float, 150, "");
AUTOCVAR(g_vehicle_lightapc_springup, float, 20, "");
AUTOCVAR(g_vehicle_lightapc_springblend, float, 0.1, "");

AUTOCVAR(g_vehicle_lightapc_health, float, 3000, "");
AUTOCVAR(g_vehicle_lightapc_health_regen, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_health_regen_pause, float, 0, "");

AUTOCVAR(g_vehicle_lightapc_shield, float, 1000, "");
AUTOCVAR(g_vehicle_lightapc_shield_regen, float, 30, "");
AUTOCVAR(g_vehicle_lightapc_shield_regen_pause, float, 1, "");

AUTOCVAR(g_vehicle_lightapc_respawntime, float, 60, "");

AUTOCVAR(g_vehicle_lightapc_blowup_radius, float, 450, "");
AUTOCVAR(g_vehicle_lightapc_blowup_coredamage, float, 250, "");
AUTOCVAR(g_vehicle_lightapc_blowup_edgedamage, float, 15, "");
AUTOCVAR(g_vehicle_lightapc_blowup_forceintensity, float, 300, "");

AUTOCVAR(g_vehicle_lightapc_gunner_offset, vector, '0 0 15', "");

AUTOCVAR(g_vehicle_lightapc_gear_speed, float, 200, "");
AUTOCVAR(g_vehicle_lightapc_wheel_speed, float, 220, "");

AUTOCVAR(g_vehicle_lightapc_snapview, bool, false, "");

//AUTOCVAR(g_vehicles_crash_damage, float, 500, "");

AUTOCVAR(g_vehicle_lightapc_mass, float, 9001, "");

// Factor of old velocity to keep after collision
AUTOCVAR(g_vehicle_lightapc_bouncefactor, float, 0.25, "");
// if != 0, New veloctiy after bounce = 0 if new velocity < this
AUTOCVAR(g_vehicle_lightapc_bouncestop, float, 0, "");
// "minspeed_for_pain speedchange_to_pain_factor max_damage"
AUTOCVAR(g_vehicle_lightapc_bouncepain, vector, '0 0 0', "");

AUTOCVAR(g_vehicle_lightapc_ballistics_density, float, 4.55, "");

AUTOCVAR(g_vehicle_lightapc_forcetype, int, 0, "");

#endif

// include for both client and server
#include "lightapc_weapons/all.inc"

#ifdef SVQC

.LinkedList gunners;

.entity hitboxmf;
.entity hitboxmb;
.entity bomb3, bomb4, bomb5, bomb6;

vector vehicle_aimturret2(entity _vehic, entity _turretmount, vector _target, entity _turrret, string _tagname, 
						  float _pichlimit_min, float _pichlimit_max, 
						  float _rotlimit_min, float _rotlimit_max, float _aimspeed)
{
	vector vtag = gettaginfo(_turrret, gettagindex(_turrret, _tagname));
	vector vtmp = vectoangles(normalize(_target - vtag));
	vtmp = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(_vehic.angles+_turretmount.angles), AnglesTransform_FromAngles(vtmp))) - _turrret.angles;
	vtmp = AnglesTransform_Normalize(vtmp, true);
	float ftmp = _aimspeed * frametime;
	vtmp.y = bound(-ftmp, vtmp.y, ftmp);
	vtmp.x = bound(-ftmp, vtmp.x, ftmp);
	_turrret.angles_y = bound(_rotlimit_min, _turrret.angles_y + vtmp.y, _rotlimit_max);    
	_turrret.angles_x = bound(_pichlimit_min, _turrret.angles_x + vtmp.x, _pichlimit_max);
	return vtag;
}

void lightapc_kill_hitbox(entity hitbox)
{
	hitbox.health             = 0;
	hitbox.event_damage       = func_null;
	hitbox.takedamage         = DAMAGE_NO;
	setthink(hitbox, func_null);
	settouch(hitbox, func_null);
	hitbox.deadflag           = DEAD_DEAD;
	set_movetype(hitbox, MOVETYPE_NONE);
	hitbox.solid      		  = SOLID_NOT;
}

void lightapc_hitbox_touch2(entity this, entity toucher)
{
	if(autocvar_g_vehicles_enter) { return; }

	if(gettouch(this))
		gettouch(this)(this, toucher);

#if 0

	//This is mostly the same as above but whatever is set as this.hitboxmf
	//is tested for weather it is above or below other rather than this
	//Used for tanks with hitboxes other than the main one: max is thus the max of the hitboxmf hitbox
	//this.hitboxmf is set at tank_spawn (usually to the forward hitbox)
	// Vehicle currently in use
	if(this.owner)
	{
		if(toucher != NULL)
		if(vehicles_crushable(toucher))
		{
			if((this.hitboxmf.origin_z + this.hitboxmf.maxs_z) > (toucher.origin_z))
			{
				//If player or creature is ontop of tank, do not crush.
				if(this.velocity)
				{
					float dmgalgo = autocvar_g_vehicles_crush_dmg * (this.mass*(vlen((this.velocity-toucher.velocity)))*0.0000012);
					Damage(toucher, this, this.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_VH_CRUSH.m_id, '0 0 0', normalize(toucher.origin - this.origin) * autocvar_g_vehicles_crush_force);
				}
			}
			else if(this.velocity)
			{
				//Push player etc
				makevectors(this.angles_x * '-1 0 0' + this.angles_y * '0 1 0' + this.angles_z * '0 0 1'); //Inverted pitch on models
				movelib_move_simple(toucher, normalize(v_forward * this.owner.movement_x),autocvar_g_vehicle_lightapc_speed_forward,autocvar_g_vehicle_lightapc_movement_inertia);
			}

			return; // Dont do thisdamage when hitting "soft targets".
		}
		else if(toucher.mass < 1000)
		{
			//This is for when hitting toucher light vehicles (cars, planes)
			if(this.velocity)
			{
				float theirmass = (toucher.mass) ? toucher.mass : 1;
				float totalmass = this.mass+theirmass;
				float dmgalgo = autocvar_g_vehicles_crash_damage * (this.mass*(vlen((this.velocity-toucher.velocity)))*0.0000012);
				float dmgtoucher = (this.mass/totalmass) * dmgalgo;
				float dmgthis = (theirmass/totalmass) * dmgalgo;
			
				Damage(toucher, this, this.owner, dmgtoucher, DEATH_VH_CRUSH.m_id, '0 0 0', normalize(toucher.origin - this.origin) * autocvar_g_vehicles_crush_force);
			
				Damage(this, this, this.owner, dmgthis, DEATH_VH_CRUSH.m_id, '0 0 0', normalize(toucher.origin - this.origin) * autocvar_g_vehicles_crush_force);		
			}
		}
		else if (toucher.mass >= 1000)
		{
			//Heavy vehicles use a different touch() routine,
			//when we hit them with a light or med vehicle,
			//we only hurt ourselves
			if(this.velocity)
			{
				float theirmass = (toucher.mass) ? toucher.mass : 1;
				float dmgalgo = autocvar_g_vehicles_crash_damage * (this.mass*(vlen((this.velocity-toucher.velocity)))*0.0000012);
				float dmgthis = (theirmass/(this.mass+theirmass)) * dmgalgo;
			
				Damage(this, this, this.owner, dmgthis, DEATH_VH_CRUSH.m_id, '0 0 0', normalize(toucher.origin - this.origin) * autocvar_g_vehicles_crush_force);		
			}
		}

		if(this.play_time < time)
		{
			Vehicle info = Vehicles_from(this.vehicleid);
			info.vr_impact(info, this);
		}

		return;
	}

	if(!IS_PLAYER(toucher))
		return;

	if(IS_DEAD(toucher))
		return;

	if(toucher.vehicle != NULL)
		return;

	vehicles_enter(toucher, this);
#endif
}

void lightapc_hitbox_touch(entity this, entity toucher)
{
	lightapc_hitbox_touch2(this.owner, toucher); // This way this.subordinate is tested for max_z rather than this
}

void lightapc_damage_hitbox(entity this, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(this.owner.event_damage)
		this.owner.event_damage(this.owner, inflictor, attacker, damage, deathtype, hitloc, force);
}

void lightapc_spawn_hitbox(entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s)
{
	hitbox.owner = vehic;
	settouch(hitbox, lightapc_hitbox_touch);

	hitbox.event_damage = lightapc_damage_hitbox;

	if(!hitbox.bot_attack)
		IL_PUSH(g_bot_targets, hitbox);
	hitbox.bot_attack = true;
	hitbox.iscreature = true;
	hitbox.teleportable = false; // no teleporting for vehicles, too buggy
	if(!hitbox.damagedbycontents)
		IL_PUSH(g_damagedbycontents, hitbox);
	hitbox.damagedbycontents = true;
	set_movetype(hitbox, MOVETYPE_WALK);
	hitbox.solid              = SOLID_SLIDEBOX;
	hitbox.takedamage         = DAMAGE_AIM;
	hitbox.deadflag           = DEAD_NO;
	hitbox.flags              = FL_NOTARGET;
	setthink(hitbox, func_null);
	hitbox.vehicle_health = vehic.vehicle_health;
	hitbox.netname = hitbox.owner.netname;
	setsize(hitbox, min_s, max_s);
	makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); // Inverted pitch on models
	setorigin(hitbox, (vehic.origin + v_forward * fwd_s)); // Forward X qunits
	follow_sameorigin(hitbox, vehic); // Follow vehic
	
	hitbox.damageforcescale = 0.03;
	hitbox.ballistics_density = autocvar_g_vehicle_lightapc_ballistics_density;
}

void lightapc_regen(entity this, float dt)
{
	if(this.vehicle_flags & VHF_SHIELDREGEN)
		vehicles_regen(this, this.dmg_time, vehicle_shield, autocvar_g_vehicle_lightapc_shield, autocvar_g_vehicle_lightapc_shield_regen_pause, autocvar_g_vehicle_lightapc_shield_regen, dt, true);

	if(this.vehicle_flags & VHF_HEALTHREGEN)
		vehicles_regen(this, this.dmg_time, vehicle_health, autocvar_g_vehicle_lightapc_health, autocvar_g_vehicle_lightapc_health_regen_pause, autocvar_g_vehicle_lightapc_health_regen, dt, false);
}

bool lightapc_gunner_frame(entity this, float dt)
{
	entity vehic = this.vehicle.vehicle;
	entity gunner = this.vehicle;
	entity player = this;

	return = true;

	if(game_stopped)
		return;

	setorigin(player, vehic.origin);
	player.velocity = vehic.velocity;

	if(gunner == vehic.gun1 || gunner == vehic.gun2)
	{
		entity turretmount = ((gunner == vehic.gun1) ? vehic.bomb5 : vehic.bomb6);

		vehic.solid = SOLID_NOT;
		vehic.hitboxmf.solid = SOLID_NOT;
		vehic.hitboxmb.solid = SOLID_NOT;

		vector ang = vehic.angles;
		ang.x *= -1;
		makevectors(ang);

		crosshair_trace(player);
		vector _ct = trace_endpos;

		float _in, _out;
		if (gunner.spawnflags == 1 || gunner.spawnflags == 2 || gunner.spawnflags == 4 || gunner.spawnflags == 5)
		{
			_in = autocvar_g_vehicle_lightapc_cannon_turnlimit_out;
			_out = autocvar_g_vehicle_lightapc_cannon_turnlimit_out;
		}
		else if (gunner.spawnflags == 6)
		{
			_in = 0;
			_out = 0; 
		}
		else
		{
			_in = autocvar_g_vehicle_lightapc_cannon_turnlimit_in;
			_out = autocvar_g_vehicle_lightapc_cannon_turnlimit_in;
		}
	
		if(player.movement_y != 0)
		{
			if(turretmount.angles_y > 180)
				turretmount.angles_y -= 360;
			if(turretmount.angles_y < -180)
				turretmount.angles_y += 360;
			turretmount.angles_y = bound(-184,turretmount.angles_y + ((player.movement_y * PHYS_INPUT_FRAMETIME) / -6.66666),184);	
		
			if(turretmount.angles_y >= -1 && turretmount.angles_y <= -1)
				turretmount.angles_y = 0;	
		
			//player.v_angle_y = turretmount.angles_y; //kiss
			
			if(autocvar_g_vehicle_lightapc_snapview)
			if(IS_REAL_CLIENT(player))
			{
				player.angles_y = player.angles_y + ((player.movement_y * PHYS_INPUT_FRAMETIME) / -6.66666);
				float ydegrees = ((player.movement_y * PHYS_INPUT_FRAMETIME) / -6.66666);
				player.v_angle_y += ydegrees;

				msg_entity = player;
				WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
				WriteAngle(MSG_ONE, player.v_angle_x);
				WriteAngle(MSG_ONE, player.v_angle_y);
				WriteAngle(MSG_ONE, player.v_angle_z);
			}
		}

		vehicle_aimturret2(vehic, turretmount, _ct, gunner, "fire",
						  autocvar_g_vehicle_lightapc_cannon_pitchlimit_down * -1, autocvar_g_vehicle_lightapc_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_lightapc_cannon_turnspeed);

		vector angvec = gettaginfo(gunner, gettagindex(gunner, "tag_camera"));
		setorigin(player, angvec);
		traceline(angvec, angvec + v_forward * max_shot_distance, MOVE_WORLDONLY, gunner);
		vector crossy = trace_endpos;
		
		// Guns
		switch(gunner.spawnflags)
		{
			case 1:
			{
				lightapc_deluge(player, gunner);
				UpdateAuxiliaryXhair(player, crossy, '0.5 1 0.8', 0);
				break;
			}
			case 2:
			{
				lightapc_shlac(player, gunner);
				UpdateAuxiliaryXhair(player, crossy, '1 0 0', 0);
				break;
			}
			case 3:
			{
				if(PHYS_INPUT_BUTTON_ATCK(player))
					PHYS_INPUT_BUTTON_ATCK2(player) = true;
				lightapc_grail(player, gunner);
				UpdateAuxiliaryXhair(player, crossy, '1 0 1', 0);
				break;
			}
			case 4:
			{
				lightapc_autonex(player, gunner);
				UpdateAuxiliaryXhair(player, crossy, '0 1 1', 0);
				break;
			}
			case 5:
			{
				lightapc_hmg2(player, gunner);	
				UpdateAuxiliaryXhair(player, crossy, '0 0 0', 0);
				break;
			}
			case 6:
			{
				if(PHYS_INPUT_BUTTON_ATCK(player))
					PHYS_INPUT_BUTTON_ATCK2(player) = true;
				lightapc_t17mm(player, gunner);
				UpdateAuxiliaryXhair(player, crossy, '0 0 0', 0);
				break;
			}
			case 7:
			{
				lightapc_hvyminigun(player, gunner, gunner.gun1);
				UpdateAuxiliaryXhair(player, crossy, '0 0 0', 0);
				break;
			}
			case 8:
			{
				lightapc_minigun(player, gunner, gunner.gun1);
				UpdateAuxiliaryXhair(player, crossy, '0 0 0', 0);
				break;
			}
			default:
			{
				UpdateAuxiliaryXhair(player, crossy, '0 0 0', 0);
				break;
			}
		}

		if(vehic.owner)
			UpdateAuxiliaryXhair(vehic.owner, crossy, ('1 0 0' * player.vehicle_reload1) + ('0 0 0' *(1 - player.vehicle_reload1)), ((gunner == vehic.gun1) ? 1 : 2));

		vehic.solid = SOLID_BBOX;
		vehic.hitboxmf.solid = SOLID_SLIDEBOX;
		vehic.hitboxmb.solid = SOLID_SLIDEBOX;
	}	
	VEHICLE_UPDATE_PLAYER(player, vehic, health, lightapc);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(player, vehic, shield, lightapc);

	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = false;
}

void lightapc_gunner_exit(entity this, int _exitflag)
{
	entity player = this.owner;
	entity gunner = this;
	entity vehic = gunner.vehicle;

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
	player.view_ofs       = STAT(PL_VIEW_OFS, player);
	player.event_damage   = PlayerDamage;
	player.hud            = HUD_NORMAL;
	player.teleportable	  = TELEPORT_NORMAL;
	player.vehicle_enter_delay = time + 2;

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		player.(weaponentity).m_switchweapon = gunner.(weaponentity).m_switchweapon;
		delete(gunner.(weaponentity));
	}

	fixedmakevectors(vehic.angles);

	vector spot = vehic.origin + v_forward * 2 + '0 0 64';
	spot = vehicles_findgoodexit(vehic, player, spot);

	// TODO: figure a way to move player out of the gunner

	player.velocity = 0.75 * vehic.velocity + normalize(spot - vehic.origin) * 200;
	player.velocity_z += 10;

	gunner.phase = time + 5;
	gunner.owner = NULL;
	gunner.vehicle_hudmodel.viewmodelforclient = gunner;

	MUTATOR_CALLHOOK(VehicleExit, player, gunner);

	player.vehicle = NULL;
}

bool lightapc_gunner_enter(entity this, entity player)
{
	entity vehic = this;
	entity gunner = NULL;

	LL_EACH(vehic.gunners, !it.owner,
	{
		gunner = it;
		break;
	});

	if(!gunner)
		return false;

	player.vehicle 			= gunner;
	player.angles 			= vehic.angles;
	player.takedamage 		= DAMAGE_NO;
	player.solid 			= SOLID_NOT;
	player.alpha 			= -1;
	set_movetype(player, MOVETYPE_NOCLIP);
	player.event_damage 	= func_null;
	player.view_ofs 		= '0 0 0';
	player.hud 				= gunner.hud;
	player.teleportable 	= false;
	player.PlayerPhysplug 	= gunner.PlayerPhysplug;
	player.vehicle_ammo1 	= vehic.vehicle_ammo1;
	player.vehicle_ammo2 	= vehic.vehicle_ammo2;
	player.vehicle_reload1 	= vehic.vehicle_reload1;
	player.vehicle_reload2 	= vehic.vehicle_reload2;
	player.vehicle_energy 	= vehic.vehicle_energy;
	UNSET_ONGROUND(player);

	RemoveGrapplingHooks(player);

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];

		gunner.(weaponentity) = new(temp_wepent);
		gunner.(weaponentity).m_switchweapon = player.(weaponentity).m_switchweapon;
	}

	gunner.vehicle_exit = lightapc_gunner_exit;
	gunner.vehicle_hudmodel.viewmodelforclient = player;
	gunner.owner = player;

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

	CSQCVehicleSetup(player, player.hud);

	MUTATOR_CALLHOOK(VehicleEnter, player, gunner);

	return true;
}

bool lightapc_pilot_frame(entity this, float dt)
{
	entity pilot = this;
	entity vehic = this.vehicle;
	return = true;

	if(game_stopped)
	{
		vehic.velocity = '0 0 0';
		vehic.avelocity = '0 0 0';
		return;
	}

	vehicles_frame(vehic, this);

	if(IS_DEAD(vehic))
	{
		PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = false;
		return;
	}

	makevectors(vehic.angles + '-2 0 0' * vehic.angles_x);
	
	movelib_groundalign4point(vehic, autocvar_g_vehicle_lightapc_springlength, autocvar_g_vehicle_lightapc_springup, autocvar_g_vehicle_lightapc_springblend, autocvar_g_vehicle_lightapc_tiltlimit);

	if(IS_ONGROUND(vehic))
	{
		makevectors(pilot.v_angle);

		if(pilot.movement == '0 0 0')
		{
			if(vehic.sound_nexttime < time || vehic.delay != 3)
			{
				vehic.delay = 3;
				vehic.sound_nexttime = time + 6.009; //soundlength("machines/generator_loop_pitchdown.ogg");
				//dprint("lightapc_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
				sound (vehic, CH_TRIGGER_SINGLE, SND_LIGHTAPC_ENGINE_IDLE, VOL_VEHICLEENGINE, ATTN_NORM);
			}
			movelib_brake_simple(vehic, autocvar_g_vehicle_lightapc_speed_stop);
			//vehic.frame = 5;
		
			vehic.bomb1.gun1.avelocity_y = vehic.bomb1.gun2.avelocity_y = vehic.bomb2.gun1.avelocity_y = vehic.bomb2.gun2.avelocity_y = 0;
			vehic.bomb3.gun1.avelocity_y = vehic.bomb3.gun2.avelocity_y = vehic.bomb4.gun1.avelocity_y = vehic.bomb4.gun2.avelocity_y = 0;
		}
	
		if(pilot.movement_y != 0)
		{
			if(vehic.angles_y > 180)  vehic.angles_y -= 360;
			if(vehic.angles_y < -180) vehic.angles_y += 360;
			vehic.angles_y = bound(-184,vehic.angles_y + ((pilot.movement_y * PHYS_INPUT_FRAMETIME) / -6.66666),184);	
			
			if(vehic.angles_y >= -1 && vehic.angles_y <= -1)
				vehic.angles_y = 0;	

			////float degree_y;
			////pilot.angles_y = pilot.angles_y + ((pilot.movement_y * PHYS_INPUT_FRAMETIME) / -6.66666);
			////degree_y = ((pilot.movement_y * PHYS_INPUT_FRAMETIME) / -6.66666);
			////pilot.v_angle_y += degree_y;

			if(autocvar_g_vehicle_lightapc_snapview)
			if(IS_REAL_CLIENT(pilot))
			{
				pilot.v_angle_y = vehic.angles_y; //kiss

				msg_entity = pilot;
				WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
				WriteAngle(MSG_ONE, pilot.v_angle_x);
				WriteAngle(MSG_ONE, pilot.v_angle_y);
				WriteAngle(MSG_ONE, pilot.v_angle_z);
			}
			
			////////pilot.angles_y = pilot.angles_y + (pilot.movement_y / -200);
			////////pilot.fixangle = true;
			
			//////msg_entity = pilot;
			//////WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
			//////WriteAngle( MSG_ONE, vehic.angles_x); 
			//////WriteAngle( MSG_ONE, vehic.angles_y);
			//////WriteAngle( MSG_ONE, vehic.angles_z);
			if (pilot.movement_y > 0)
			{
				vehic.bomb1.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb1.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed; //wheel
				vehic.bomb2.gun1.avelocity_y = -autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb2.gun2.avelocity_y = -autocvar_g_vehicle_lightapc_wheel_speed; //wheel
				
				vehic.bomb3.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb3.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed; //wheel
				vehic.bomb4.gun1.avelocity_y = -autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb4.gun2.avelocity_y = -autocvar_g_vehicle_lightapc_wheel_speed; //wheel
			}
			else
			{
				vehic.bomb1.gun1.avelocity_y = -autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb1.gun2.avelocity_y = -autocvar_g_vehicle_lightapc_wheel_speed; //wheel
				vehic.bomb2.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb2.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed; //wheel
				
				vehic.bomb3.gun1.avelocity_y = -autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb3.gun2.avelocity_y = -autocvar_g_vehicle_lightapc_wheel_speed; //wheel
				vehic.bomb4.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed; //gear
				vehic.bomb4.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed; //wheel
			}
		}
	 
		if(pilot.movement_x != 0)
		{
			if(pilot.movement_x > 0)
			{
				pilot.movement_x = 1;
				vehic.frame = 0;
			}
			else if(pilot.movement_x < 0)
			{
				pilot.movement_x = -1;
				vehic.frame = 1;
			}
			
			vehic.bomb1.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed * pilot.movement_x; //gear
			vehic.bomb1.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed * pilot.movement_x; //wheel
			vehic.bomb2.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed * pilot.movement_x; //gear
			vehic.bomb2.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed * pilot.movement_x; //wheel
			
			vehic.bomb3.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed * pilot.movement_x; //gear
			vehic.bomb3.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed * pilot.movement_x; //wheel
			vehic.bomb4.gun1.avelocity_y = autocvar_g_vehicle_lightapc_gear_speed * pilot.movement_x; //gear
			vehic.bomb4.gun2.avelocity_y = autocvar_g_vehicle_lightapc_wheel_speed * pilot.movement_x; //wheel
			
			pilot.movement_y = 0;
			
			//fixedmakevectors(vehic.angles);
			makevectors(vehic.angles + '-2 0 0' * vehic.angles_x);
	
			float myvehicspeed;
			
			if(pilot.waterlevel == WATERLEVEL_SUBMERGED)
				myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward * 0.30;
			else if(pilot.waterlevel == WATERLEVEL_SWIMMING)
				myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward * 0.60;
			else if(pilot.waterlevel == WATERLEVEL_WETFEET)
				myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward * 0.80;
			else
				myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward;
			
			movelib_move_simple(vehic, normalize(v_forward * pilot.movement_x), myvehicspeed, autocvar_g_vehicle_lightapc_movement_inertia);

			if(vehic.sound_nexttime < time || vehic.delay != 1)
			{
				vehic.delay = 1;
				vehic.sound_nexttime = time + 3.991; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
				sound (vehic, CH_TRIGGER_SINGLE, SND_LIGHTAPC_ENGINE_MOVE, VOL_VEHICLEENGINE, ATTEN_NORM);
				//dprint("lightapc_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
			}
		}
		else
		{
			//If we are not moving forward or backwards we should stop
			//Otherwise we "drift" while turn buttons are pressed, like on ice
			movelib_brake_simple(vehic, autocvar_g_vehicle_lightapc_speed_stop);
		}
	}
	
	vehic.angles_x = bound(-autocvar_g_vehicle_lightapc_tiltlimit, vehic.angles_x, autocvar_g_vehicle_lightapc_tiltlimit);
	vehic.angles_z = bound(-autocvar_g_vehicle_lightapc_tiltlimit, vehic.angles_z, autocvar_g_vehicle_lightapc_tiltlimit);

	// pilot has no weapons, gunners must defend the vehicle

	lightapc_regen(vehic, dt);

	if(vehic.gun1.owner)
		pilot.vehicle_ammo1 = vehic.gun1.owner.vehicle_ammo1;
	if(vehic.gun2.owner)
		pilot.vehicle_ammo2 = vehic.gun2.owner.vehicle_ammo1;

	VEHICLE_UPDATE_PLAYER(pilot, vehic, health, lightapc);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(pilot, vehic, shield, lightapc);

	setorigin(pilot, vehic.origin + '0 0 32');
	pilot.velocity = vehic.velocity;

	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = false;
}

void lightapc_think(entity this)
{
	this.nextthink = time + autocvar_g_vehicle_lightapc_thinkrate;

	if(IS_ONGROUND(this))
		movelib_brake_simple(this, autocvar_g_vehicle_lightapc_speed_stop);

	if(!this.owner)
	{
		LL_EACH(this.gunners, it.owner,
		{
			entity player = it.owner;
			it.vehicle_exit(it, VHEF_EJECT);
			this.phase = 0;
			player.vehicle_enter_delay = 0;
			//it.vehicle_enter(this, player);
			//gettouch(this)(this);
			vehicles_enter(player, this);
			break;
		});
	}

	CSQCMODEL_AUTOUPDATE(this);
}

void lightapc_pilot_exit(entity this, int eject)
{
	setthink(this, lightapc_think);
	this.nextthink  = time;
	set_movetype(this, MOVETYPE_BOUNCE);
	sound (this, CH_TRIGGER_SINGLE, SND_Null, VOL_VEHICLEENGINE, ATTEN_NORM);

	this.bomb1.gun1.avelocity_y = 0;
	this.bomb1.gun2.avelocity_y = 0;
	this.bomb2.gun1.avelocity_y = 0;
	this.bomb2.gun2.avelocity_y = 0;
	this.bomb3.gun1.avelocity_y = 0;
	this.bomb3.gun2.avelocity_y = 0;
	this.bomb4.gun1.avelocity_y = 0;
	this.bomb4.gun2.avelocity_y = 0;

	if(!this.owner)
		return;

	entity player = this.owner;
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

void lightapc_setgunnertype(entity gunner, entity instance, entity bomber)
{
	int mytype = bound(1, floor(random() * 9), 8);
	if(autocvar_g_vehicle_lightapc_forcetype)
		mytype = autocvar_g_vehicle_lightapc_forcetype;
	gunner.spawnflags = mytype;

	switch(mytype)
	{
		case 1:
		{
			setmodel(gunner, MDL_LIGHTAPC_DELUGE);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
			break;
		}
		case 2:
		{
			setmodel(gunner, MDL_LIGHTAPC_SHLAC);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
			break;
		}
		case 3:
		{
			setmodel(gunner, MDL_LIGHTAPC_GRAIL);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
			break;
		}
		case 4:
		{
			setmodel(gunner, MDL_LIGHTAPC_AUTONEX);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
			break;
		}
		case 5:
		{
			setmodel(gunner, MDL_LIGHTAPC_HMG2);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
			break;
		}
		case 6:
		{
			setmodel(gunner, MDL_LIGHTAPC_T17MM);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
			break;
		}
		case 7:
		{	
			setmodel(gunner, MDL_LIGHTAPC_HVYMINIGUN);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
				
			//.50 Minigun Barrels
			gunner.gun1 = spawn();
			setmodel(gunner.gun1,MDL_LIGHTAPC_HVYMINIGUN_BARRELS);
			setattachment(gunner.gun1, gunner, "tag_axis");
			gunner.gun1.count = autocvar_g_vehicle_lightapc_hvyminigun_refire;
			break;
		}
		case 8:
		{	
			setmodel(gunner, MDL_LIGHTAPC_MINIGUN);
			setattachment(gunner, bomber, "tag_gunpivot");
			setorigin(gunner, autocvar_g_vehicle_lightapc_gunner_offset);
				
			//Minigun Barrels
			gunner.gun1 = spawn();
			setmodel(gunner.gun1,MDL_LIGHTAPC_MINIGUN_BARRELS);
			setattachment(gunner.gun1, gunner, "tag_axis");
			gunner.gun1.count = autocvar_g_vehicle_lightapc_minigun_refire;
			break;
		}
		default:
		{
			string mytag = ((gunner == gunner.vehicle.gun1) ? "tag_pass1" : "tag_pass2");
			setattachment(gunner, instance, mytag);
			break;
		}
	}
}

void lightapc_blowup(entity this, entity toucher)
{
	entity vehic = this.owner;

	vehic.deadflag = DEAD_DEAD;

	RadiusDamage (this, this.enemy, autocvar_g_vehicle_lightapc_blowup_coredamage,
					autocvar_g_vehicle_lightapc_blowup_edgedamage,
					autocvar_g_vehicle_lightapc_blowup_radius, NULL, NULL,
					autocvar_g_vehicle_lightapc_blowup_forceintensity,
					DEATH_VH_WAKI_DEATH.m_id, NULL);

	delete(this);
}

void lightapc_blowup_think(entity this)
{
	lightapc_blowup(this, NULL);
}

void lightapc_diethink(entity this)
{
	if(time >= this.wait)
		setthink(this, lightapc_blowup_think);

	if(random() < 0.1)
	{
		sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
		Send_Effect(EFFECT_EXPLOSION_SMALL, randomvec() * 80 + (this.origin + '0 0 100'), '0 0 0', 1);
	}

	this.nextthink = time + 0.1;
}

void lightapc_deadtouch(entity this, entity toucher)
{
	this.avelocity_x *= 0.7;
	this.cnt -= 1;
	if(this.cnt <= 0)
		lightapc_blowup(this, toucher);
}

void lightapc_touch(entity this, entity toucher)
{
	if(autocvar_g_vehicles_enter)
	{
		vehicles_touch(this, toucher);
		return; // use button handles entering
	}

	// Vehicle currently in use
	if(this.owner && SAME_TEAM(this.owner, toucher) && toucher.vehicle_enter_delay < time)
	{
		// try gunner first
		if(IS_REAL_CLIENT(toucher))
		{
			LL_EACH(this.gunners, !it.owner && it.vehicle_enter && time >= it.phase,
			{
				if(it.vehicle_enter(this, toucher))
					return; // boom
			});
		}
	}

	vehicles_touch(this, toucher);
}

void lightapc_spawn_gunner(entity vehic, string tagname)
{
	entity gunner = new(lightapc_gunner);
	gunner.vehicle = vehic;
	setmodel(gunner, MDL_Null);
	setattachment(gunner, vehic, tagname);
	vehicle_addplayerslot(vehic, gunner, VEH_LIGHTAPCPASSENGER.vehicleid, MDL_Null, lightapc_gunner_frame, lightapc_gunner_exit, lightapc_gunner_enter);
	LL_PUSH(vehic.gunners, gunner);
}

entity lightapc_spawn_tire(entity vehic, string tagname)
{
	entity spinner = new(lightapctire);
	spinner.owner = vehic;
	setmodel(spinner, MDL_LIGHTAPC_TIRE);
	setattachment(spinner, vehic, tagname);
	set_movetype(spinner, MOVETYPE_NOCLIP);
	spinner.avelocity = '0 90 0';

	return spinner;
}

spawnfunc(vehicle_lightapc)
{
	if(!autocvar_g_vehicle_lightapc) { delete(this); return; }
	if(!vehicle_initialize(this, VEH_LIGHTAPC, false)) { delete(this); return; }
}

#endif // SVQC

METHOD(LightAPC, vr_impact, void(LightAPC thisveh, entity instance))
{
#ifdef SVQC
	if(autocvar_g_vehicle_lightapc_bouncepain)
		vehicles_impact(instance, autocvar_g_vehicle_lightapc_bouncepain_x, autocvar_g_vehicle_lightapc_bouncepain_y, autocvar_g_vehicle_lightapc_bouncepain_z);
#endif
}

METHOD(LightAPC, vr_enter, void(LightAPC thisveh, entity instance))
{
#ifdef SVQC
	set_movetype(instance, MOVETYPE_WALK);
	instance.owner.vehicle_health = (instance.vehicle_health / autocvar_g_vehicle_lightapc_health) * 100;
	instance.owner.vehicle_shield = (instance.vehicle_shield / autocvar_g_vehicle_lightapc_shield) * 100;

	if(instance.owner.flagcarried)
		setorigin(instance.owner.flagcarried, '-190 0 96');
#elif defined(CSQC)
	set_movetype(instance, MOVETYPE_WALK);
#endif
}

METHOD(LightAPC, vr_gunner_enter, void(LightAPC thisveh, entity instance, entity actor))
{
#ifdef SVQC
	if(IS_REAL_CLIENT(actor))
	{
		LL_EACH(instance.gunners, !it.owner && it.vehicle_enter && time >= it.phase,
		{
			if(it.vehicle_enter(instance, actor))
				return; // boom
		});
	}
#endif
}

METHOD(LightAPC, vr_setcolors, void(LightAPC thisveh, entity instance))
{
#ifdef SVQC
	entity veh = instance; // too big a word for so many cases

	veh.bomb1.gun1.colormap = veh.bomb1.gun2.colormap = veh.bomb2.gun1.colormap = veh.bomb2.gun2.colormap = veh.bomb3.gun1.colormap = veh.bomb3.gun2.colormap = veh.bomb4.gun1.colormap = veh.bomb4.gun2.colormap = veh.colormap;
	veh.bomb1.gun1.colormod = veh.bomb1.gun2.colormod = veh.bomb2.gun1.colormod = veh.bomb2.gun2.colormod = veh.bomb3.gun1.colormod = veh.bomb3.gun2.colormod = veh.bomb4.gun1.colormod = veh.bomb4.gun2.colormod = veh.colormod;
	veh.bomb1.gun1.effects = veh.bomb1.gun2.effects = veh.bomb2.gun1.effects = veh.bomb2.gun2.effects = veh.bomb3.gun1.effects = veh.bomb3.gun2.effects = veh.bomb4.gun1.effects = veh.bomb4.gun2.effects = veh.effects;
	veh.bomb1.gun1.alpha = veh.bomb1.gun2.alpha = veh.bomb2.gun1.alpha = veh.bomb2.gun2.alpha = veh.bomb3.gun1.alpha = veh.bomb3.gun2.alpha = veh.bomb4.gun1.alpha = veh.bomb4.gun2.alpha = 1;

	veh.gun1.colormap = veh.gun2.colormap = veh.colormap;
	veh.gun1.colormod = veh.gun2.colormod = veh.colormod;
	veh.gun1.effects = veh.gun2.effects = veh.effects;
	veh.gun1.alpha = veh.gun2.alpha = 1;
#endif
}

METHOD(LightAPC, vr_spawn, void(LightAPC thisveh, entity instance))
{
#ifdef SVQC
	if(!instance.gun1)
	{
		// for some reason, autosizing of the shield entity refuses to work for this one so set it up in advance.
		instance.vehicle_shieldent = new(vehicle_shield);
		instance.vehicle_shieldent.effects = EF_LOWPRECISION;
		setmodel(instance.vehicle_shieldent, MDL_VEH_SHIELD);
		setattachment(instance.vehicle_shieldent, instance, "");
		setorigin(instance.vehicle_shieldent, real_origin(instance) - instance.origin);
		instance.vehicle_shieldent.scale       = 512 / vlen(instance.maxs - instance.mins);
		setthink(instance.vehicle_shieldent, shieldhit_think);
		instance.vehicle_shieldent.alpha = -1;
		instance.vehicle_shieldent.effects = EF_LOWPRECISION | EF_NODRAW;
		
		instance.gun1 = new(lightapcgunner);
		instance.gun2 = new(lightapcgunner);

		instance.bomb1 = new(lightapcwheelcontroller);
		instance.bomb2 = new(lightapcwheelcontroller);
		instance.bomb3 = new(lightapcwheelcontroller);
		instance.bomb4 = new(lightapcwheelcontroller);

		instance.bomb1.gun1 = lightapc_spawn_tire(instance, "tag_gear_left");
		instance.bomb1.gun2 = lightapc_spawn_tire(instance, "tag_wheel_left");
		instance.bomb2.gun1 = lightapc_spawn_tire(instance, "tag_gear_right");
		instance.bomb2.gun2 = lightapc_spawn_tire(instance, "tag_wheel_right");
		instance.bomb3.gun1 = lightapc_spawn_tire(instance, "tag_gear_left2");
		instance.bomb3.gun2 = lightapc_spawn_tire(instance, "tag_wheel_left2");
		instance.bomb4.gun1 = lightapc_spawn_tire(instance, "tag_gear_right2");
		instance.bomb4.gun2 = lightapc_spawn_tire(instance, "tag_wheel_right2");

		instance.vehicle_flags |= VHF_MULTISLOT;

		instance.gun1.vehicle = instance;
		instance.gun2.vehicle = instance;
		
		instance.bomb5 = new(lightapcturret);
		instance.bomb6 = new(lightapcturret);

		lightapc_setgunnertype(instance.gun1, instance, instance.bomb5);
		lightapc_setgunnertype(instance.gun2, instance, instance.bomb6);

		if (instance.gun1.spawnflags)
		{
			setmodel(instance.bomb5,MDL_LIGHTAPC_MOUNT);
			setattachment(instance.bomb5, instance, "tag_gunturret1");
		}

		if(instance.gun2.spawnflags)
		{
			setmodel(instance.bomb6,MDL_LIGHTAPC_MOUNT);
			setattachment(instance.bomb6, instance, "tag_gunturret2");
		}

		if(!instance.gunners)
		{
			instance.gunners = LL_NEW();

			LL_PUSH(instance.gunners, instance.gun1);
			LL_PUSH(instance.gunners, instance.gun2);

			vehicle_addplayerslot(instance, instance.gun1, VEH_LIGHTAPCGUNNER1.vehicleid, MDL_Null, lightapc_gunner_frame, lightapc_gunner_exit, lightapc_gunner_enter);
			vehicle_addplayerslot(instance, instance.gun2, VEH_LIGHTAPCGUNNER2.vehicleid, MDL_Null, lightapc_gunner_frame, lightapc_gunner_exit, lightapc_gunner_enter);

			lightapc_spawn_gunner(instance, "tag_pass3");
			lightapc_spawn_gunner(instance, "tag_pass4");
			lightapc_spawn_gunner(instance, "tag_pass5");
			lightapc_spawn_gunner(instance, "tag_pass6");
			lightapc_spawn_gunner(instance, "tag_pass7");
			lightapc_spawn_gunner(instance, "tag_pass8");
			lightapc_spawn_gunner(instance, "tag_pass9");
			lightapc_spawn_gunner(instance, "tag_pass10");
			lightapc_spawn_gunner(instance, "tag_pass11");
			lightapc_spawn_gunner(instance, "tag_pass12");
			lightapc_spawn_gunner(instance, "tag_pass13");
		}

		if (instance.gun1.spawnflags)
			setattachment(instance.gun1.vehicle_viewport, instance.gun1, "tag_camera");

		if (instance.gun2.spawnflags)
			setattachment(instance.gun2.vehicle_viewport, instance.gun2, "tag_camera");

		instance.hitboxmf = new(lightapchitbox);
		instance.hitboxmb = new(lightapchitbox);
	}

	if(instance.scale != 0.75)
	{
		// FIXME: this be hakkz, fix the models instead (scale body, add tag_viewport to the hudmodel).
		instance.scale = 0.75;
		setattachment(instance.vehicle_hudmodel, instance, "");
		setattachment(instance.vehicle_viewport, instance, "tag_viewport");

		instance.mass = autocvar_g_vehicle_lightapc_mass;
	}

	setthink(instance, lightapc_think);
	settouch(instance, lightapc_touch);
	instance.nextthink = time;

	instance.move_movetype	= MOVETYPE_TOSS;
	instance.solid		= SOLID_SLIDEBOX;
	instance.delay		= time;
	instance.scale		= 0.75;

	instance.PlayerPhysplug = lightapc_pilot_frame;

	instance.bouncefactor = autocvar_g_vehicle_lightapc_bouncefactor;
	instance.bouncestop = autocvar_g_vehicle_lightapc_bouncestop;
	instance.damageforcescale = 0.02;
	instance.vehicle_health = autocvar_g_vehicle_lightapc_health;
	instance.vehicle_shield = autocvar_g_vehicle_lightapc_shield;
	instance.max_health = instance.vehicle_health;

	instance.bomb1.gun1.avelocity_y = 0;
	instance.bomb1.gun2.avelocity_y = 0;
	instance.bomb2.gun1.avelocity_y = 0;
	instance.bomb2.gun2.avelocity_y = 0;
	instance.bomb3.gun1.avelocity_y = 0;
	instance.bomb3.gun2.avelocity_y = 0;
	instance.bomb4.gun1.avelocity_y = 0;
	instance.bomb4.gun2.avelocity_y = 0;

	lightapc_spawn_hitbox(instance, instance.hitboxmf, thisveh.m_mins, thisveh.m_maxs, 90);	
	lightapc_spawn_hitbox(instance, instance.hitboxmb, thisveh.m_mins, thisveh.m_maxs, -90);
#endif
}

METHOD(LightAPC, vr_death, void(LightAPC thisveh, entity instance))
{
#ifdef SVQC
	LL_EACH(instance.gunners, it.owner,
	{
		it.vehicle_exit(it, VHEF_EJECT);
	});

/*
	setSendEntity(instance, func_null); // stop networking this lightapc (for now)
	instance.health			= 0;
	instance.event_damage	= func_null;
	instance.solid			= SOLID_CORPSE;
	instance.takedamage		= DAMAGE_NO;
	instance.deadflag		= DEAD_DYING;
	set_movetype(instance, MOVETYPE_BOUNCE);
	instance.wait			= time;
	instance.delay			= 2 + time + random() * 3;
	instance.cnt			= 1 + random() * 2;
	settouch(instance, lightapc_deadtouch);

	Send_Effect(EFFECT_EXPLOSION_MEDIUM, instance.origin, '0 0 0', 1);

	if(random() < 0.5)
		instance.avelocity_z = 32;
	else
		instance.avelocity_z = -32;

	instance.avelocity_x = -vlen(instance.velocity) * 0.2;
	instance.velocity += '0 0 700';
	instance.colormod = '-0.5 -0.5 -0.5';

	setthink(instance, lightapc_blowup_think);
	instance.nextthink = time;
*/
	instance.vehicle_exit(instance, VHEF_EJECT);
	
	fixedmakevectors(instance.angles);
	vehicle_tossgib(instance, instance.gun1, instance.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);
	vehicle_tossgib(instance, instance.gun2, instance.velocity + v_right * -300 + v_up * 100 + randomvec() * 200, "cannon_left", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(instance, instance, instance.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		settouch(_body, lightapc_blowup);
	else
		settouch(_body, func_null);
		
	_body.scale          = 0.75;
	setthink(_body, lightapc_diethink);
	_body.nextthink = time;
	_body.wait = time + 2 + (random() * 8);
	_body.owner = instance;
	_body.enemy = instance.enemy;
	
	Send_Effect(EFFECT_EXPLOSION_MEDIUM, instance.origin, '0 0 0', 1);
	
	instance.health			= 0;
	instance.event_damage	= func_null;
	instance.solid			= SOLID_CORPSE;
	instance.takedamage		= DAMAGE_NO;
	instance.deadflag		= DEAD_DYING;
	set_movetype(instance, MOVETYPE_NONE);
	instance.effects		= EF_NODRAW;
	instance.colormod		= '0 0 0';
	instance.avelocity		= '0 0 0';
	instance.velocity		= '0 0 0';
	instance.nextthink = time + autocvar_g_vehicle_lightapc_respawntime;
	settouch(instance, func_null);
	setthink(instance, vehicles_spawn);
	setorigin(instance, instance.pos1);

	lightapc_kill_hitbox(instance.hitboxmf); // Middle front //Fine, doesnt do anything tank specific
	lightapc_kill_hitbox(instance.hitboxmb); // Mid back
#endif
}

#ifdef CSQC
METHOD(LightAPC, vr_hud, void(LightAPC thisveh))
{
	Vehicles_drawHUD(VEH_LIGHTAPC.m_icon, "vehicle_lightapc_gun1", "vehicle_lightapc_gun2",
					 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
					 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color);

	float hudAlpha = autocvar_hud_panel_fg_alpha;
	float blinkValue = 0.55 + sin(time * 7) * 0.45;
	vector tmpPos  = '0 0 0';
	vector tmpSize = '1 1 1' * hud_fontsize;
	tmpPos.x = vehicleHud_Pos.x + vehicleHud_Size.x * (520/768);

	if(!AuxiliaryXhair[1].draw2d)
	{
		tmpPos.y = vehicleHud_Pos.y + vehicleHud_Size.y * (96/256) - tmpSize.y;
		drawstring(tmpPos, _("No front gunner!"), tmpSize, '1 1 1', hudAlpha * blinkValue, DRAWFLAG_NORMAL);
	}

	if(!AuxiliaryXhair[2].draw2d)
	{
		tmpPos.y = vehicleHud_Pos.y + vehicleHud_Size.y * (160/256);
		drawstring(tmpPos, _("No back gunner!"), tmpSize, '1 1 1', hudAlpha * blinkValue, DRAWFLAG_NORMAL);
	}
}
METHOD(LightAPC, vr_crosshair, void(LightAPC thisveh, entity player))
{
	// no crosshair for the pilot?
	//Vehicles_drawCrosshair(vCROSS_GUIDE);
}
#endif
METHOD(LightAPC, vr_setup, void(LightAPC thisveh, entity instance))
{
#ifdef SVQC
	instance.vehicle_exit = lightapc_pilot_exit;

	// we have no need to network energy
	if(autocvar_g_vehicle_lightapc_shield)
		instance.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_lightapc_shield_regen)
		instance.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_lightapc_health_regen)
		instance.vehicle_flags |= VHF_HEALTHREGEN;

	instance.respawntime = autocvar_g_vehicle_lightapc_respawntime;
	instance.vehicle_health = autocvar_g_vehicle_lightapc_health;
	instance.vehicle_shield = autocvar_g_vehicle_lightapc_shield;
	instance.max_health = instance.vehicle_health;
#endif

#ifdef CSQC
	AuxiliaryXhair[0].axh_image = vCROSS_LOCK; // Rocket
	AuxiliaryXhair[1].axh_image = vCROSS_BURST; // Gunner1
	AuxiliaryXhair[2].axh_image = vCROSS_BURST; // Gunner2
#endif
}

#ifdef CSQC
METHOD(LightAPCGunner1, vr_hud, void(LightAPCGunner1 thisveh))
{
	Vehicles_drawHUD(VEH_LIGHTAPCGUNNER1.m_icon, "vehicle_lightapc_gun1", string_null,
					 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
					 string_null, '0 0 0');
}
METHOD(LightAPCGunner1, vr_crosshair, void(LightAPCGunner1 thisveh, entity player))
{
	//Vehicles_drawCrosshair(vCROSS_GUIDE);
}

METHOD(LightAPCGunner1, vr_setup, void(LightAPCGunner1 thisveh, entity instance))
{
	AuxiliaryXhair[0].axh_image = vCROSS_LOCK; // Match all?
}
#endif

#ifdef CSQC
METHOD(LightAPCGunner2, vr_hud, void(LightAPCGunner2 thisveh))
{
	Vehicles_drawHUD(VEH_LIGHTAPCGUNNER2.m_icon, "vehicle_lightapc_gun2", string_null,
					 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
					 string_null, '0 0 0');
}
METHOD(LightAPCGunner2, vr_crosshair, void(LightAPCGunner2 thisveh, entity player))
{
	//Vehicles_drawCrosshair(vCROSS_GUIDE);
}

METHOD(LightAPCGunner2, vr_setup, void(LightAPCGunner2 thisveh, entity instance))
{
	AuxiliaryXhair[0].axh_image = vCROSS_LOCK; // Match all?
}
#endif

#ifdef CSQC
METHOD(LightAPCPassenger, vr_hud, void(LightAPCPassenger thisveh))
{
	Vehicles_drawHUD(VEH_LIGHTAPCPASSENGER.m_icon, string_null, string_null,
					 string_null, '0 0 0',
					 string_null, '0 0 0');
}
METHOD(LightAPCPassenger, vr_crosshair, void(LightAPCPassenger thisveh, entity player))
{
	//Vehicles_drawCrosshair(vCROSS_GUIDE);
}

METHOD(LightAPCPassenger, vr_setup, void(LightAPCPassenger thisveh, entity instance))
{
	//AuxiliaryXhair[0].axh_image = vCROSS_LOCK; // Match all?
}
#endif

#endif
