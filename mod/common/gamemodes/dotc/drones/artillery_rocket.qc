#ifndef IMPLEMENTATION

SOUND(DOTC_DRONE_RART_FIRE, W_Sound("rocket_fire"));

#else

#ifdef SVQC

AUTOCVAR(g_dotc_rart_shot_refire2, float, 2, "");
AUTOCVAR(g_dotc_rart_shots, int, 4, "");

void dotc_rart_fire(entity this)
{
    vector r_target, e_org;
    entity rkt;
    float hgt, dist;

    if(this.drone_turret.lip == 0)
		this.drone_turret.lip = autocvar_g_dotc_rart_shots;

    this.drone_turret.lip -= 1;

	if((this.drone_turret.lip % 2) == 0)
		this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire1"));
    else
		this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire2"));

	e_org = real_origin(this.squad.enemy);
	dist = vlen(e_org - this.origin);

	// Randomize impact within +/- this.shot_radius arround target
	r_target   = randomvec() * this.shot_radius * 0.5;
	r_target  -= randomvec() * this.shot_radius * 0.5;
	r_target_z = 0;
	r_target  += e_org;

	//float i;

	// Find the height offset to the sky	/ celing
	traceline(e_org + '0 0 4', e_org + ('0 0 1' * MAX_SHOT_DISTANCE),  MOVE_WORLDONLY, this);

	// Determine suitable rocket arc height
	hgt = vlen(e_org - trace_endpos) - 64;
	hgt = dist / this.target_range;
	hgt = (hgt * 256) + 64;

#ifdef DOTC_RART_PREDICT
	vector pp;
	pp = e_org;
	hgt = 128;
	for(i = 0 ; i < 3; ++i)
	{
		arc_projectile_calculatevelocity(this.tur_shotorg, pp, hgt);
		pp = e_org + this.squad.enemy.velocity * arc_projectile_flighttime;
	}
	r_target += pp;
	r_target_z = e_org_z;
#endif

	dotc_ai_aim_ballistic_vel = arc_projectile_calculatevelocity(this.tur_shotorg, r_target, hgt);


	rkt = dotc_projectile(this, SND_DOTC_DRONE_RART_FIRE, "g_dotc_rart_mflash", "g_dotc_rart_pexplode", 1, 25,PROJECTILE_DOTC_DRONE_RART);
	rkt.velocity = dotc_ai_aim_ballistic_vel;
	set_movetype(rkt, MOVETYPE_TOSS);

	if(this.drone_turret.lip == 0)
		this.dotc_nextfire = time + autocvar_g_dotc_rart_shot_refire2;
	else
		this.dotc_nextfire = time + this.shot_refire;
}

void dotc_rart_frame(entity this, vector formaion_loc, float tdelta)
{
	vector aim_at, lvaim_minmax, lvaim_speed;

	dotc_droneyaw(this);

	lvaim_minmax_x = this.aim_maxpitch;
	lvaim_minmax_y = this.aim_maxpitch * -1;
	lvaim_minmax_z = this.aim_maxrot;

	lvaim_speed_x = this.aim_speed * 0.5;
	lvaim_speed_y = this.aim_speed;
	lvaim_speed_z = 0.75;

    this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "aim"));

    if(this.squad.enemy)
    {
		//this.velocity = '0 0 0';

		this.velocity = dotc_drone_move(this, formaion_loc, 0, 128, 0.5);

		aim_at = dotc_ai_aim_ballistic(this, real_origin(this.squad.enemy), this.tur_shotorg, this.shot_speed, 10, 1000);
		dotc_ai_track_separate_inert(this, this.drone_turret, this.drone_gun, this.tur_shotorg, aim_at, lvaim_speed, 0.2, lvaim_minmax, tdelta);

		//te_lightning1(this, this.tur_shotorg, this.tur_shotorg + v_forward * 256);
		//te_lightning1(this.drone_gun, this.tur_shotorg, aim_at);

		//if(this.dotc_nextfire < time || this.drone_turret.lip != 0)
		if(this.drone_turret.lip != 0 && this.dotc_nextfire < time)
			this.drone_fire(this);

		if(vdist(dotc_ai_track_targetoffset, <, this.aim_firetolerance_dist))
			if(this.dotc_nextfire < time)
				this.drone_fire(this);

    }
	else
	{
		this.velocity = dotc_drone_move(this, formaion_loc, 0, 128, 0.5);

		// FIXME: Use smooth movement to return to idle aim
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


entity dotc_spawn_rart(entity this, entity own)
{
	entity drone = dotc_spawn_drone(this, own, MDL_DOTC_DRONE_RART_BODY, MDL_DOTC_DRONE_RART_TURRET, MDL_DOTC_DRONE_RART_GUN, MDL_DOTC_DRONE_RART_DEAD.model_str(), "g_dotc_rart_", "g_dotc_rart_pexplode", dotc_rart_frame, dotc_rart_fire, DOTC_DRONETYPE_RART);
	set_movetype(drone, MOVETYPE_FLY);
	drone.classname = "dotc_drone";
	drone.netname 	= "Rocket Artillery";
	setsize(drone, drone_size_small_min, drone_size_small_max);

	if(drone.waypointsprite_attached)
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_FLAG, '1 0.6 0.4');

	// drone.scale = 2;
	/*
	setorigin(this.drone_turret, '0 0 -15');
	setorigin(this.drone_gun, '0 0 -15');
	this.drone_gun.origin -= '0 0 60';
	*/

	return drone;
}
#endif

#endif
