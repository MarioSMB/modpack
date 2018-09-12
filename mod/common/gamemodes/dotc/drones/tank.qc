#ifndef IMPLEMENTATION

EFFECT(0, DOTC_DRONE_TANK_PROJ_EXPLODE,      "g_dotc_tank_pexplode")
EFFECT(0, DOTC_DRONE_TANK_MUZZLEFLASH,       "g_dotc_tank_mflash")

SOUND(DOTC_DRONE_TANK_FIRE, W_Sound("hagar_fire"));
SOUND(DOTC_DRONE_TANK_PROJ_EXPLODE, "dotc/explosion1");

MSG_INFO_NOTIF(DEATH_SELF_DOTC_TANK_PROJECTILE,            1,  2, 1, "s1 s2loc spree_lost", "s1",         "notify_death",                                _("^BG%s^K1 was obliterated by a Tank drone%s%s"), "")
MSG_MULTI_NOTIF(DEATH_SELF_DOTC_TANK_PROJECTILE,           1,  NULL,                                      INFO_DEATH_SELF_DOTC_TANK_PROJECTILE,          CENTER_DEATH_SELF_DOTC_DRONE_PROJECTILE)
REGISTER_DEATHTYPE(DOTC_TANK_PROJECTILE,                   DEATH_SELF_DOTC_TANK_PROJECTILE,               DEATH_MURDER_DOTC_DRONE_PROJECTILE,             "")

#ifdef SVQC
entity dotc_spawn_tank(entity this, entity own);

AUTOCVAR(g_dotc_tank_health, float, 250, "");
AUTOCVAR(g_dotc_tank_shot_dmg, float, 40, "");
AUTOCVAR(g_dotc_tank_shot_radius, float, 70, "");
AUTOCVAR(g_dotc_tank_shot_force, float, 400, "");
AUTOCVAR(g_dotc_tank_shot_speed, float, 4000, "");
AUTOCVAR(g_dotc_tank_shot_spread, float, 0.035, "");
AUTOCVAR(g_dotc_tank_shot_refire, float, 2.5, "");
AUTOCVAR(g_dotc_tank_target_range, float, 2500, "");
AUTOCVAR(g_dotc_tank_target_range_min, float, 5, "");
AUTOCVAR(g_dotc_tank_target_range_optimal, float, 1000, "");
AUTOCVAR(g_dotc_tank_deathcredits, float, 35, "");
AUTOCVAR(g_dotc_tank_aim_firetolerance_dist, float, 10, "");
AUTOCVAR(g_dotc_tank_aim_speed, float, 90, "");
AUTOCVAR(g_dotc_tank_aim_maxpitch, float, 20, "");
AUTOCVAR(g_dotc_tank_aim_maxrot, float, 360, "");
AUTOCVAR(g_dotc_tank_movespeed, float, 600, "");
AUTOCVAR(g_dotc_tank_turnspeed, float, 180, "");
AUTOCVAR(g_dotc_tank_spring_length, float, 128, "");
AUTOCVAR(g_dotc_tank_spring_strength, float, 1200, "");
#endif

#else

#ifdef SVQC
void dotc_tank_fire(entity this)
{
    this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire"));
    v_forward = normalize(v_forward);

	// ff avoid?
	tracebox(this.tur_shotorg, '-1 -1 -1', '1 1 1', this.tur_shotorg + v_forward * 256, MOVE_NORMAL, this);
	if(trace_ent)
	if(SAME_TEAM(trace_ent, this))
		return;

	dotc_projectile(this, SND_DOTC_DRONE_TANK_FIRE, EFFECT_DOTC_DRONE_TANK_MUZZLEFLASH, EFFECT_DOTC_DRONE_TANK_PROJ_EXPLODE, SND_DOTC_DRONE_TANK_PROJ_EXPLODE, 0, 0, DEATH_DOTC_TANK_PROJECTILE.m_id, PROJECTILE_DOTC_DRONE_TANK);

	this.dotc_nextfire = time + this.shot_refire;
}

void dotc_tank_frame(entity this, entity thesquad, vector formation_loc, float tdelta)
{
	dotc_droneyaw(this);

	vector lvaim_minmax = vec3(this.aim_maxpitch, this.aim_maxpitch * -1, this.aim_maxrot);
	vector lvaim_speed = vec3(this.aim_speed * 0.5, this.aim_speed, 0.75);

    this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire"));

    if(thesquad.enemy)
    {
		this.velocity = dotc_drone_move(this, formation_loc, 0, 128, 0.5);

		vector aim_at = dotc_ai_aim_projectile(thesquad.enemy, this.tur_shotorg, this.shot_speed, this.dotc_nextfire);
		dotc_ai_track_separate_inert(this, this.drone_turret, this.drone_gun, this.tur_shotorg, aim_at, lvaim_speed, 0.2, lvaim_minmax, tdelta);

		if(this.dotc_nextfire < time)
			if(vdist(dotc_ai_track_targetoffset, <, this.aim_firetolerance_dist))
				this.drone_fire(this);
    }
	else
	{
		// FIXME: Use smooth movement to return to idle aim
		this.velocity = dotc_drone_move(this, formation_loc, 0, 128, 0.5);

		//this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire"));
		//dotc_ai_track_separate_inert(this, this.drone_turret, this.drone_gun, this.tur_shotorg, this.origin + v_forward * 200, lvaim_speed, 0.2, lvaim_minmax, tdelta);
		this.drone_turret.angles_y = 0;
		this.drone_turret.avelocity_y = 0;

		this.drone_gun.angles_x = 0;
		this.drone_gun.avelocity_x = 0;
	}

	this.velocity_z = dotc_hoverforce(this, this.dotc_spring_length, this.dotc_spring_strength);
	dotc_bob(this, 4, 16);
}

void dotc_tank_init(entity this)
{
	SetResourceAmountExplicit(this, RESOURCE_HEALTH, autocvar_g_dotc_tank_health);

	this.shot_dmg				 = autocvar_g_dotc_tank_shot_dmg;
	this.shot_radius			 = autocvar_g_dotc_tank_shot_radius;
	this.shot_force				 = autocvar_g_dotc_tank_shot_force;
	this.shot_speed				 = autocvar_g_dotc_tank_shot_speed;
	this.shot_refire			 = autocvar_g_dotc_tank_shot_refire;
	this.shot_spread       		 = autocvar_g_dotc_tank_shot_spread;

	this.target_range			 = autocvar_g_dotc_tank_target_range;
	this.target_range_min		 = autocvar_g_dotc_tank_target_range_min;
	this.target_range_optimal	 = autocvar_g_dotc_tank_target_range_optimal;

	this.dotc_deathcredits		 = autocvar_g_dotc_tank_deathcredits;

	this.aim_firetolerance_dist  = autocvar_g_dotc_tank_aim_firetolerance_dist;
	this.aim_speed				 = autocvar_g_dotc_tank_aim_speed;
	this.aim_maxpitch			 = autocvar_g_dotc_tank_aim_maxpitch;
	this.aim_maxrot			 	 = autocvar_g_dotc_tank_aim_maxrot;

	this.dotc_movespeed		 	 = autocvar_g_dotc_tank_movespeed;
	this.dotc_turnspeed		 	 = autocvar_g_dotc_tank_turnspeed;

	this.dotc_spring_length	 	 = autocvar_g_dotc_tank_spring_length;
	this.dotc_spring_strength	 = autocvar_g_dotc_tank_spring_strength;
}

entity dotc_spawn_tank(entity this, entity own)
{
	entity drone = dotc_spawn_drone(this, own, MDL_DOTC_DRONE_TANK_BODY, MDL_DOTC_DRONE_TANK_TURRET, MDL_DOTC_DRONE_TANK_GUN, MDL_DOTC_DRONE_TANK_DEAD, EFFECT_DOTC_DRONE_TANK_PROJ_EXPLODE, dotc_tank_frame, dotc_tank_fire, DOTC_DRONETYPE_TANK);
	setsize(drone, drone_size_medium_min, drone_size_medium_max * 1.25);
	set_movetype(drone, MOVETYPE_FLY);
	drone.classname = "dotc_drone";
	drone.netname 	= "Tank";

	dotc_tank_init(drone);

	if(drone.waypointsprite_attached)
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_FLAG, '0.6 0.4 1');

	return drone;
}
#endif

#endif
