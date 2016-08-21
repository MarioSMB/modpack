#ifndef IMPLEMENTATION

SOUND(DOTC_DRONE_GART_FIRE, "dotc/lasershot3");

#else

#ifdef SVQC

void dotc_gart_fire(entity this)
{
    this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire"));
    v_forward = normalize(v_forward);

	// ff avoid?
	tracebox(this.tur_shotorg, '-1 -1 -1', '1 1 1', this.tur_shotorg + v_forward * 256, MOVE_NORMAL, this);
	if(trace_ent)
	if(SAME_TEAM(trace_ent, this))
		return;

	dotc_projectile(this, SND_DOTC_DRONE_GART_FIRE, "g_dotc_rart_mflash", "g_dotc_rart_pexplode", 0, 0, PROJECTILE_DOTC_DRONE_GART);

	this.dotc_nextfire = time + this.shot_refire;
}

void dotc_gart_frame(entity this, vector formaion_loc, float tdelta)
{
	vector aim_at, lvaim_minmax, lvaim_speed;

	dotc_droneyaw(this);

	lvaim_minmax_x = this.aim_maxpitch;
	lvaim_minmax_y = this.aim_maxpitch * -1;
	lvaim_minmax_z = this.aim_maxrot;

	lvaim_speed_x = this.aim_speed * 0.5;
	lvaim_speed_y = this.aim_speed;
	lvaim_speed_z = 0.75;

    if(this.squad.enemy)
    {
		this.velocity = dotc_drone_move(this, formaion_loc, 0, 128, 0.5);

		this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire"));
		aim_at = dotc_ai_aim_projectile(this.squad.enemy, this.tur_shotorg, this.shot_speed, this.dotc_nextfire);
		dotc_ai_track_separate_inert(this, this.drone_turret, this.drone_gun, this.tur_shotorg, aim_at, lvaim_speed, 0.2, lvaim_minmax, tdelta);

		if(this.dotc_nextfire < time)
			if(vdist(dotc_ai_track_targetoffset, <, this.aim_firetolerance_dist))
				this.drone_fire(this);
    }
	else
	{
		this.velocity = dotc_drone_move(this, formaion_loc, 0, 128, 0.5);

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

entity dotc_spawn_gart(entity this, entity own)
{
	entity drone;

	drone 			= dotc_spawn_drone(this, own, MDL_DOTC_DRONE_GART_BODY, MDL_DOTC_DRONE_GART_TURRET, MDL_DOTC_DRONE_GART_GUN, MDL_DOTC_DRONE_GART_DEAD.model_str(), "g_dotc_gart_", "g_dotc_gart_pexplode", dotc_gart_frame, dotc_gart_fire, DOTC_DRONETYPE_GART);
	setsize(drone, drone_size_small_min, drone_size_small_max);
	set_movetype(drone, MOVETYPE_FLY);
	drone.classname = "cannon_artillery";
	drone.netname 	= "Cannon Artillery";

	if(drone.waypointsprite_attached)
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_FLAG, '0.9 0.9 0');

	return drone;
}
#endif

#endif
