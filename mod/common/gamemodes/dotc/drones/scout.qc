#ifndef IMPLEMENTATION

EFFECT(0, DOTC_DRONE_SCOUT_PROJ_EXPLODE,      "g_dotc_scout_pexplode")
EFFECT(0, DOTC_DRONE_SCOUT_MUZZLEFLASH,       "g_dotc_scout_mflash")

SOUND(DOTC_DRONE_SCOUT_FIRE, "dotc/lasershot3");
SOUND(DOTC_DRONE_SCOUT_PROJ_EXPLODE, "dotc/explosion2");

MSG_INFO_NOTIF(DEATH_SELF_DOTC_SCOUT_PROJECTILE,            1,  2, 1, "s1 s2loc spree_lost", "s1",         "notify_death",                                _("^BG%s^K1 was gunned down by a Scout drone%s%s"), "")
MSG_MULTI_NOTIF(DEATH_SELF_DOTC_SCOUT_PROJECTILE,           1,  NULL,                                      INFO_DEATH_SELF_DOTC_SCOUT_PROJECTILE,         CENTER_DEATH_SELF_DOTC_DRONE_PROJECTILE)
REGISTER_DEATHTYPE(DOTC_SCOUT_PROJECTILE,                   DEATH_SELF_DOTC_SCOUT_PROJECTILE,              DEATH_MURDER_DOTC_DRONE_PROJECTILE,            "")

#ifdef SVQC
AUTOCVAR(g_dotc_scout_health, float, 50, "");
AUTOCVAR(g_dotc_scout_shot_dmg, float, 5, "");
AUTOCVAR(g_dotc_scout_shot_radius, float, 25, "");
AUTOCVAR(g_dotc_scout_shot_force, float, 25, "");
AUTOCVAR(g_dotc_scout_shot_speed, float, 6000, "");
AUTOCVAR(g_dotc_scout_shot_spread, float, 0.045, "");
AUTOCVAR(g_dotc_scout_shot_refire, float, 0.15, "");
AUTOCVAR(g_dotc_scout_target_range, float, 3000, "");
AUTOCVAR(g_dotc_scout_target_range_min, float, 5, "");
AUTOCVAR(g_dotc_scout_target_range_optimal, float, 1000, "");
AUTOCVAR(g_dotc_scout_deathcredits, float, 10, "");
AUTOCVAR(g_dotc_scout_aim_firetolerance_dist, float, 8, "");
AUTOCVAR(g_dotc_scout_aim_speed, float, 200, "");
AUTOCVAR(g_dotc_scout_aim_maxpitch, float, 25, "");
AUTOCVAR(g_dotc_scout_aim_maxrot, float, 10, "");
AUTOCVAR(g_dotc_scout_movespeed, float, 800, "");
AUTOCVAR(g_dotc_scout_turnspeed, float, 350, "");
AUTOCVAR(g_dotc_scout_spring_length, float, 200, "");
AUTOCVAR(g_dotc_scout_spring_strength, float, 1250, "");
#endif

#else

#ifdef SVQC

AUTOCVAR(g_dotc_scout_shot_refire2, float, 1, "");
AUTOCVAR(g_dotc_scout_shots, int, 2, "");

void dotc_scout_fire(entity this)
{
	if(this.drone_turret.lip == 0)
		this.drone_turret.lip = autocvar_g_dotc_scout_shots;

	this.drone_turret.lip -= 1;

	if((this.drone_turret.lip % 2) == 0)
		this.tur_shotorg = gettaginfo(this.drone_turret, gettagindex(this.drone_turret, "fire1"));
	else
		this.tur_shotorg = gettaginfo(this.drone_turret, gettagindex(this.drone_turret, "fire2"));

	v_forward = normalize(v_forward);

	// ff avoid?
	tracebox(this.tur_shotorg, '-1 -1 -1', '1 1 1', this.tur_shotorg + v_forward * 256, MOVE_NORMAL, this);
	if(trace_ent)
	if(SAME_TEAM(trace_ent, this))
		return;

	dotc_projectile(this, SND_DOTC_DRONE_SCOUT_FIRE, EFFECT_DOTC_DRONE_SCOUT_MUZZLEFLASH, EFFECT_DOTC_DRONE_SCOUT_PROJ_EXPLODE, SND_DOTC_DRONE_SCOUT_PROJ_EXPLODE, 0, 0, DEATH_DOTC_SCOUT_PROJECTILE.m_id, PROJECTILE_DOTC_DRONE_SCOUT);

	this.dotc_nextfire = time + this.shot_refire;

	if(this.drone_turret.lip == 0)
		this.dotc_nextfire = time + autocvar_g_dotc_scout_shot_refire2;
	else
		this.dotc_nextfire = time + this.shot_refire;

}

void dotc_scout_frame(entity this, entity thesquad, vector formation_loc, float tdelta)
{
	dotc_droneyaw(this);
	this.tur_shotorg = gettaginfo(this.drone_turret, gettagindex(this.drone_turret, "fire1"));

	if(thesquad.enemy)
	{
#if 0
		this.enemy = thesquad.enemy;
		float ret;
		this.dotc_attack_spot_loc = this.origin;
		//traceline(this.tur_shotorg, this.enemy.origin, MOVE_NORMAL, this);
		if(1)//trace_fraction != 1.0 && trace_ent != this.enemy)
		{
			//dprint("^2Blocked, looking up vantage.. \n");
			ret = dotc_find_attack_spot_direct(this);
			if (ret == 0 || ret == -1)
			{
				this.effects &~= EF_FLAME;
				dprint("^1Vatntage found\n");
			}
			else
			{
				this.effects |= EF_FLAME;
				dprint("^3Vatntage NOT found\n");
				this.dotc_attack_spot_loc = formation_loc;
			}
		}
		this.velocity = dotc_drone_move(this, this.dotc_attack_spot_loc , 0, 128, 0.5);
#endif

		this.velocity = dotc_drone_move(this, formation_loc , 0, 128, 0.5);

		vector aim_minmax = vec3(this.aim_maxpitch, this.aim_maxpitch * -1, this.aim_maxrot);

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

	//this.velocity_z = -800 + dotc_hoverforce2(this, this.dotc_spring_length, this.dotc_spring_strength);
	this.velocity_z = dotc_hoverforce(this, this.dotc_spring_length, this.dotc_spring_strength);

	dotc_bob(this, 8, 12);
}

void dotc_scout_init(entity this)
{
	SetResourceAmountExplicit(this, RESOURCE_HEALTH, autocvar_g_dotc_scout_health);

	this.shot_dmg				 = autocvar_g_dotc_scout_shot_dmg;
	this.shot_radius			 = autocvar_g_dotc_scout_shot_radius;
	this.shot_force				 = autocvar_g_dotc_scout_shot_force;
	this.shot_speed				 = autocvar_g_dotc_scout_shot_speed;
	this.shot_refire			 = autocvar_g_dotc_scout_shot_refire;
	this.shot_spread       		 = autocvar_g_dotc_scout_shot_spread;

	this.target_range			 = autocvar_g_dotc_scout_target_range;
	this.target_range_min		 = autocvar_g_dotc_scout_target_range_min;
	this.target_range_optimal	 = autocvar_g_dotc_scout_target_range_optimal;

	this.dotc_deathcredits		 = autocvar_g_dotc_scout_deathcredits;

	this.aim_firetolerance_dist  = autocvar_g_dotc_scout_aim_firetolerance_dist;
	this.aim_speed				 = autocvar_g_dotc_scout_aim_speed;
	this.aim_maxpitch			 = autocvar_g_dotc_scout_aim_maxpitch;
	this.aim_maxrot			 	 = autocvar_g_dotc_scout_aim_maxrot;

	this.dotc_movespeed		 	 = autocvar_g_dotc_scout_movespeed;
	this.dotc_turnspeed		 	 = autocvar_g_dotc_scout_turnspeed;

	this.dotc_spring_length	 	 = autocvar_g_dotc_scout_spring_length;
	this.dotc_spring_strength	 = autocvar_g_dotc_scout_spring_strength;
}

entity dotc_spawn_scout(entity sqd, entity own)
{
	entity drone = dotc_spawn_drone(sqd, own, MDL_DOTC_DRONE_SCOUT_BODY, MDL_DOTC_DRONE_SCOUT_TURRET, MDL_Null, MDL_DOTC_DRONE_SCOUT_DEAD, EFFECT_DOTC_DRONE_SCOUT_PROJ_EXPLODE, dotc_scout_frame, dotc_scout_fire, DOTC_DRONETYPE_SCOUT);

	setsize(drone, '-30 -30 -5', '30 30 25');
	set_movetype(drone, MOVETYPE_BOUNCEMISSILE);
	drone.classname = "dotc_drone";
	drone.netname = "Scout";

	dotc_scout_init(drone);

	if(drone.waypointsprite_attached)
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_FLAG, '0.2 0.7 0.9');

	return drone;
}
#endif

#endif
