#ifndef IMPLEMENTATION

EFFECT(0, DOTC_DRONE_RART_PROJ_EXPLODE,      "g_dotc_rart_pexplode")
EFFECT(0, DOTC_DRONE_RART_MUZZLEFLASH,       "g_dotc_rart_mflash")

SOUND(DOTC_DRONE_RART_FIRE, W_Sound("rocket_fire"));
SOUND(DOTC_DRONE_RART_PROJ_EXPLODE, W_Sound("rocket_impact"));

MSG_INFO_NOTIF(DEATH_SELF_DOTC_RART_PROJECTILE,            1,  2, 1, "s1 s2loc spree_lost", "s1",         "notify_death",                                _("^BG%s^K1 was destroyed by a Rocket Artillery drone%s%s"), "")
MSG_MULTI_NOTIF(DEATH_SELF_DOTC_RART_PROJECTILE,           1,  NULL,                                      INFO_DEATH_SELF_DOTC_RART_PROJECTILE,          CENTER_DEATH_SELF_DOTC_DRONE_PROJECTILE)
REGISTER_DEATHTYPE(DOTC_RART_PROJECTILE,                   DEATH_SELF_DOTC_RART_PROJECTILE,               DEATH_MURDER_DOTC_DRONE_PROJECTILE,             "")

#ifdef SVQC
AUTOCVAR(g_dotc_rart_health, float, 150, "");
AUTOCVAR(g_dotc_rart_shot_dmg, float, 50, "");
AUTOCVAR(g_dotc_rart_shot_radius, float, 250, "");
AUTOCVAR(g_dotc_rart_shot_force, float, 250, "");
AUTOCVAR(g_dotc_rart_shot_speed, float, 1250, "");
AUTOCVAR(g_dotc_rart_shot_spread, float, 0.025, "");
AUTOCVAR(g_dotc_rart_shot_refire, float, 0.25, "");
AUTOCVAR(g_dotc_rart_target_range, float, 3000, "");
AUTOCVAR(g_dotc_rart_target_range_min, float, 200, "");
AUTOCVAR(g_dotc_rart_target_range_optimal, float, 1000, "");
AUTOCVAR(g_dotc_rart_deathcredits, float, 40, "");
AUTOCVAR(g_dotc_rart_aim_firetolerance_dist, float, 10, "");
AUTOCVAR(g_dotc_rart_aim_speed, float, 90, "");
AUTOCVAR(g_dotc_rart_aim_maxpitch, float, 20, "");
AUTOCVAR(g_dotc_rart_aim_maxrot, float, 45, "");
AUTOCVAR(g_dotc_rart_movespeed, float, 500, "");
AUTOCVAR(g_dotc_rart_turnspeed, float, 70, "");
AUTOCVAR(g_dotc_rart_spring_length, float, 128, "");
AUTOCVAR(g_dotc_rart_spring_strength, float, 1200, "");
#endif

#else

#ifdef SVQC

AUTOCVAR(g_dotc_rart_shot_refire2, float, 2, "");
AUTOCVAR(g_dotc_rart_shots, int, 4, "");

void dotc_rart_fire(entity this)
{
    if(this.drone_turret.lip == 0)
		this.drone_turret.lip = autocvar_g_dotc_rart_shots;

    this.drone_turret.lip -= 1;

	if((this.drone_turret.lip % 2) == 0)
		this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire1"));
    else
		this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "fire2"));

	vector e_org = real_origin(this.squad.enemy);
	float dist = vlen(e_org - this.origin);

	// Randomize impact within +/- this.shot_radius arround target
	vector r_target   = randomvec() * this.shot_radius * 0.5;
	r_target  -= randomvec() * this.shot_radius * 0.5;
	r_target.z = 0;
	r_target  += e_org;

	//float i;

	// Find the height offset to the sky	/ celing
	traceline(e_org + '0 0 4', e_org + ('0 0 1' * max_shot_distance),  MOVE_WORLDONLY, this);

	// Determine suitable rocket arc height
	float hgt = vlen(e_org - trace_endpos) - 64;
	hgt = dist / this.target_range;
	hgt = (hgt * 256) + 64;

#ifdef DOTC_RART_PREDICT
	vector pp = e_org;
	hgt = 128;
	for(i = 0 ; i < 3; ++i)
	{
		arc_projectile_calculatevelocity(this.tur_shotorg, pp, hgt);
		pp = e_org + this.squad.enemy.velocity * arc_projectile_flighttime;
	}
	r_target += pp;
	r_target.z = e_org.z;
#endif

	dotc_ai_aim_ballistic_vel = arc_projectile_calculatevelocity(this.tur_shotorg, r_target, hgt);

	entity rkt = dotc_projectile(this, SND_DOTC_DRONE_RART_FIRE, EFFECT_DOTC_DRONE_RART_MUZZLEFLASH, EFFECT_DOTC_DRONE_RART_PROJ_EXPLODE, SND_DOTC_DRONE_RART_PROJ_EXPLODE, 1, 25, DEATH_DOTC_RART_PROJECTILE.m_id, PROJECTILE_DOTC_DRONE_RART);
	rkt.velocity = dotc_ai_aim_ballistic_vel;
	set_movetype(rkt, MOVETYPE_TOSS);

	if(this.drone_turret.lip == 0)
		this.dotc_nextfire = time + autocvar_g_dotc_rart_shot_refire2;
	else
		this.dotc_nextfire = time + this.shot_refire;
}

void dotc_rart_frame(entity this, entity thesquad, vector formation_loc, float tdelta)
{
	dotc_droneyaw(this);

	vector lvaim_minmax = vec3(this.aim_maxpitch, this.aim_maxpitch * -1, this.aim_maxrot);
	vector lvaim_speed = vec3(this.aim_speed * 0.5, this.aim_speed, 0.75);

    this.tur_shotorg = gettaginfo(this.drone_gun, gettagindex(this.drone_gun, "aim"));

    if(thesquad.enemy)
    {
		//this.velocity = '0 0 0';

		this.velocity = dotc_drone_move(this, formation_loc, 0, 128, 0.5);

		vector aim_at = dotc_ai_aim_ballistic(this, thesquad, this.tur_shotorg, this.shot_speed, 10, 1000);
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
		this.velocity = dotc_drone_move(this, formation_loc, 0, 128, 0.5);

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

void dotc_rart_init(entity this)
{
	this.health					 = autocvar_g_dotc_rart_health;

	this.shot_dmg				 = autocvar_g_dotc_rart_shot_dmg;
	this.shot_radius			 = autocvar_g_dotc_rart_shot_radius;
	this.shot_force				 = autocvar_g_dotc_rart_shot_force;
	this.shot_speed				 = autocvar_g_dotc_rart_shot_speed;
	this.shot_refire			 = autocvar_g_dotc_rart_shot_refire;
	this.shot_spread       		 = autocvar_g_dotc_rart_shot_spread;

	this.target_range			 = autocvar_g_dotc_rart_target_range;
	this.target_range_min		 = autocvar_g_dotc_rart_target_range_min;
	this.target_range_optimal	 = autocvar_g_dotc_rart_target_range_optimal;

	this.dotc_deathcredits		 = autocvar_g_dotc_rart_deathcredits;

	this.aim_firetolerance_dist  = autocvar_g_dotc_rart_aim_firetolerance_dist;
	this.aim_speed				 = autocvar_g_dotc_rart_aim_speed;
	this.aim_maxpitch			 = autocvar_g_dotc_rart_aim_maxpitch;
	this.aim_maxrot			 	 = autocvar_g_dotc_rart_aim_maxrot;

	this.dotc_movespeed		 	 = autocvar_g_dotc_rart_movespeed;
	this.dotc_turnspeed		 	 = autocvar_g_dotc_rart_turnspeed;

	this.dotc_spring_length	 	 = autocvar_g_dotc_rart_spring_length;
	this.dotc_spring_strength	 = autocvar_g_dotc_rart_spring_strength;
}

entity dotc_spawn_rart(entity this, entity own)
{
	entity drone = dotc_spawn_drone(this, own, MDL_DOTC_DRONE_RART_BODY, MDL_DOTC_DRONE_RART_TURRET, MDL_DOTC_DRONE_RART_GUN, MDL_DOTC_DRONE_RART_DEAD, EFFECT_DOTC_DRONE_RART_PROJ_EXPLODE, dotc_rart_frame, dotc_rart_fire, DOTC_DRONETYPE_RART);
	set_movetype(drone, MOVETYPE_FLY);
	drone.classname = "dotc_drone";
	drone.netname 	= "Rocket Artillery";
	setsize(drone, drone_size_small_min, drone_size_small_max);

	dotc_rart_init(drone);

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
