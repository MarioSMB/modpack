#ifndef IMPLEMENTATION

SOUND(DOTC_DRONE_LIGHT_FIRE, W_Sound("hagar_fire"));

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

	dotc_projectile(this, SND_DOTC_DRONE_LIGHT_FIRE, "g_dotc_lighttank_mflash", "g_dotc_lighttank_pexplode", 0, 0, PROJECTILE_DOTC_DRONE_LTANK);

	this.dotc_nextfire = time + this.shot_refire;
}

void dotc_ltank_frame(entity this, vector formaion_loc, float tdelta)
{
	vector aim_at, aim_minmax;

	dotc_droneyaw(this);

	this.tur_shotorg = gettaginfo(this.drone_turret, gettagindex(this.drone_turret, "fire"));

    if(this.squad.enemy)
    {
    	//vector vantage;
    	this.enemy = this.squad.enemy;

    	/*vantage = dotc_find_firelocation_los2(this.origin, 512);
    	if(vantage != '0 0 0')
			this.velocity = dotc_drone_move(this, vantage, 0, 128, 0.5);
		else*/
			this.velocity = dotc_drone_move(this, formaion_loc, 0, 128, 0.5);

		aim_minmax_x = this.aim_maxpitch;
		aim_minmax_y = this.aim_maxpitch * -1;
		aim_minmax_z = this.aim_maxrot;

		aim_at = real_origin(this.squad.enemy);
		dotc_ai_track_combined_step(this, this.drone_turret, this.tur_shotorg ,aim_at, this.aim_speed, 0.5 * this.aim_speed, aim_minmax, tdelta);

		if(this.dotc_nextfire < time)
			if(vdist(dotc_ai_track_targetoffset, <, this.aim_firetolerance_dist))
				this.drone_fire(this);
    }
	else
	{
		#if 0
		if(vlen(this.origin - this.pos1) < 16)
			this.pos1 = formaion_loc;

    	this.velocity = dotc_drone_move(this, this.pos1, 150, 128, 0.5);
    	#else
    	this.velocity = dotc_drone_move(this, formaion_loc, 150, 128, 0.5);
		#endif

		// FIXME: Use smooth movement to return to idle aim
		this.drone_turret.angles_x = 0;
		this.drone_turret.angles_y = 0;
	}

	this.velocity_z = dotc_hoverforce(this, this.dotc_spring_length, this.dotc_spring_strength);

	dotc_bob(this, 8, 12);

}

entity dotc_spawn_ltank(entity sqd, entity own)
{
	entity drone;

	drone 			= dotc_spawn_drone( sqd, own, MDL_DOTC_DRONE_LIGHT_BODY, MDL_DOTC_DRONE_LIGHT_TURRET, MDL_Null, MDL_DOTC_DRONE_LIGHT_DEAD.model_str(), "g_dotc_lighttank_", "g_dotc_lighttank_pexplode", dotc_ltank_frame, dotc_ltank_fire, DOTC_DRONETYPE_LTANK);
	setsize(drone, drone_size_small_min, drone_size_small_max);
	set_movetype(drone, MOVETYPE_FLY);
	drone.classname = "dotc_drone";
	drone.netname 	= "Light tank";

	if(drone.waypointsprite_attached)
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_FLAG, '0.4 0.6 0.9');

	return drone;
}
#endif

#endif
