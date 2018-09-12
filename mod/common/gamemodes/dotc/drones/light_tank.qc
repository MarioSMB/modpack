#ifndef IMPLEMENTATION

EFFECT(0, DOTC_DRONE_LIGHTTANK_PROJ_EXPLODE,      "g_dotc_lighttank_pexplode")
EFFECT(0, DOTC_DRONE_LIGHTTANK_MUZZLEFLASH,       "g_dotc_lighttank_mflash")

SOUND(DOTC_DRONE_LIGHT_FIRE, W_Sound("hagar_fire"));
SOUND(DOTC_DRONE_LIGHTTANK_PROJ_EXPLODE, "dotc/explosion1");

MSG_INFO_NOTIF(DEATH_SELF_DOTC_LIGHTTANK_PROJECTILE,            1,  2, 1, "s1 s2loc spree_lost", "s1",         "notify_death",                                _("^BG%s^K1 was blasted by a Light Tank drone%s%s"), "")
MSG_MULTI_NOTIF(DEATH_SELF_DOTC_LIGHTTANK_PROJECTILE,           1,  NULL,                                      INFO_DEATH_SELF_DOTC_LIGHTTANK_PROJECTILE,     CENTER_DEATH_SELF_DOTC_DRONE_PROJECTILE)
REGISTER_DEATHTYPE(DOTC_LIGHTTANK_PROJECTILE,                   DEATH_SELF_DOTC_LIGHTTANK_PROJECTILE,          DEATH_MURDER_DOTC_DRONE_PROJECTILE,            "")

#ifdef SVQC
AUTOCVAR(g_dotc_lighttank_health, float, 90, "");
AUTOCVAR(g_dotc_lighttank_shot_dmg, float, 15, "");
AUTOCVAR(g_dotc_lighttank_shot_radius, float, 50, "");
AUTOCVAR(g_dotc_lighttank_shot_force, float, 50, "");
AUTOCVAR(g_dotc_lighttank_shot_speed, float, 2000, "");
AUTOCVAR(g_dotc_lighttank_shot_spread, float, 0.075, "");
AUTOCVAR(g_dotc_lighttank_shot_refire, float, 2, "");
AUTOCVAR(g_dotc_lighttank_target_range, float, 2000, "");
AUTOCVAR(g_dotc_lighttank_target_range_min, float, 5, "");
AUTOCVAR(g_dotc_lighttank_target_range_optimal, float, 900, "");
AUTOCVAR(g_dotc_lighttank_deathcredits, float, 20, "");
AUTOCVAR(g_dotc_lighttank_aim_firetolerance_dist, float, 10, "");
AUTOCVAR(g_dotc_lighttank_aim_speed, float, 180, "");
AUTOCVAR(g_dotc_lighttank_aim_maxpitch, float, 20, "");
AUTOCVAR(g_dotc_lighttank_aim_maxrot, float, 100, "");
AUTOCVAR(g_dotc_lighttank_movespeed, float, 750, "");
AUTOCVAR(g_dotc_lighttank_turnspeed, float, 300, "");
AUTOCVAR(g_dotc_lighttank_spring_length, float, 100, "");
AUTOCVAR(g_dotc_lighttank_spring_strength, float, 1500, "");
#endif

#else

#ifdef SVQC

void dotc_ltank_fire(entity this)
{
    this.tur_shotorg = gettaginfo(this.drone_turret, gettagindex(this.drone_turret, "fire"));
    v_forward = normalize(v_forward);

	// ff avoid?
	tracebox(this.tur_shotorg, '-1 -1 -1', '1 1 1', this.tur_shotorg + v_forward * 256, MOVE_NORMAL, this);
	if(trace_ent)
	if(SAME_TEAM(trace_ent, this))
		return;

	dotc_projectile(this, SND_DOTC_DRONE_LIGHT_FIRE, EFFECT_DOTC_DRONE_LIGHTTANK_MUZZLEFLASH, EFFECT_DOTC_DRONE_LIGHTTANK_PROJ_EXPLODE, SND_DOTC_DRONE_LIGHTTANK_PROJ_EXPLODE, 0, 0, DEATH_DOTC_LIGHTTANK_PROJECTILE.m_id, PROJECTILE_DOTC_DRONE_LTANK);

	this.dotc_nextfire = time + this.shot_refire;
}

void dotc_ltank_frame(entity this, entity thesquad, vector formation_loc, float tdelta)
{
	dotc_droneyaw(this);

	this.tur_shotorg = gettaginfo(this.drone_turret, gettagindex(this.drone_turret, "fire"));

    if(thesquad.enemy)
    {
    	//vector vantage;
    	this.enemy = thesquad.enemy;

    	/*vantage = dotc_find_firelocation_los2(this.origin, 512);
    	if(vantage != '0 0 0')
			this.velocity = dotc_drone_move(this, vantage, 0, 128, 0.5);
		else*/
			this.velocity = dotc_drone_move(this, formation_loc, 0, 128, 0.5);

		vector aim_minmax;
		aim_minmax.x = this.aim_maxpitch;
		aim_minmax.y = this.aim_maxpitch * -1;
		aim_minmax.z = this.aim_maxrot;

		vector aim_at = real_origin(thesquad.enemy);
		dotc_ai_track_combined_step(this, this.drone_turret, this.tur_shotorg ,aim_at, this.aim_speed, 0.5 * this.aim_speed, aim_minmax, tdelta);

		if(this.dotc_nextfire < time)
			if(vdist(dotc_ai_track_targetoffset, <, this.aim_firetolerance_dist))
				this.drone_fire(this);
    }
	else
	{
		#if 0
		if(vlen(this.origin - this.pos1) < 16)
			this.pos1 = formation_loc;

    	this.velocity = dotc_drone_move(this, this.pos1, 150, 128, 0.5);
    	#else
    	this.velocity = dotc_drone_move(this, formation_loc, 150, 128, 0.5);
		#endif

		// FIXME: Use smooth movement to return to idle aim
		this.drone_turret.angles_x = 0;
		this.drone_turret.angles_y = 0;
	}

	this.velocity_z = dotc_hoverforce(this, this.dotc_spring_length, this.dotc_spring_strength);

	dotc_bob(this, 8, 12);
}

void dotc_lighttank_init(entity this)
{
	SetResourceAmountExplicit(this, RESOURCE_HEALTH, autocvar_g_dotc_lighttank_health);

	this.shot_dmg				 = autocvar_g_dotc_lighttank_shot_dmg;
	this.shot_radius			 = autocvar_g_dotc_lighttank_shot_radius;
	this.shot_force				 = autocvar_g_dotc_lighttank_shot_force;
	this.shot_speed				 = autocvar_g_dotc_lighttank_shot_speed;
	this.shot_refire			 = autocvar_g_dotc_lighttank_shot_refire;
	this.shot_spread       		 = autocvar_g_dotc_lighttank_shot_spread;

	this.target_range			 = autocvar_g_dotc_lighttank_target_range;
	this.target_range_min		 = autocvar_g_dotc_lighttank_target_range_min;
	this.target_range_optimal	 = autocvar_g_dotc_lighttank_target_range_optimal;

	this.dotc_deathcredits		 = autocvar_g_dotc_lighttank_deathcredits;

	this.aim_firetolerance_dist  = autocvar_g_dotc_lighttank_aim_firetolerance_dist;
	this.aim_speed				 = autocvar_g_dotc_lighttank_aim_speed;
	this.aim_maxpitch			 = autocvar_g_dotc_lighttank_aim_maxpitch;
	this.aim_maxrot			 	 = autocvar_g_dotc_lighttank_aim_maxrot;

	this.dotc_movespeed		 	 = autocvar_g_dotc_lighttank_movespeed;
	this.dotc_turnspeed		 	 = autocvar_g_dotc_lighttank_turnspeed;

	this.dotc_spring_length	 	 = autocvar_g_dotc_lighttank_spring_length;
	this.dotc_spring_strength	 = autocvar_g_dotc_lighttank_spring_strength;
}

entity dotc_spawn_ltank(entity sqd, entity own)
{
	entity drone = dotc_spawn_drone(sqd, own, MDL_DOTC_DRONE_LIGHT_BODY, MDL_DOTC_DRONE_LIGHT_TURRET, MDL_Null, MDL_DOTC_DRONE_LIGHT_DEAD, EFFECT_DOTC_DRONE_LIGHTTANK_PROJ_EXPLODE, dotc_ltank_frame, dotc_ltank_fire, DOTC_DRONETYPE_LTANK);
	setsize(drone, drone_size_small_min, drone_size_small_max);
	set_movetype(drone, MOVETYPE_FLY);
	drone.classname = "dotc_drone";
	drone.netname = "Light tank";

	dotc_lighttank_init(drone);

	if(drone.waypointsprite_attached)
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_FLAG, '0.4 0.6 0.9');

	return drone;
}
#endif

#endif
