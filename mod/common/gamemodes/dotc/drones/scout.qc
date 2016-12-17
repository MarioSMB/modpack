#ifndef IMPLEMENTATION

SOUND(DOTC_DRONE_SCOUT_FIRE, "dotc/lasershot3");

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

    dotc_projectile(this, SND_DOTC_DRONE_SCOUT_FIRE, "g_dotc_scout_mflash", "g_dotc_scout_pexplode", 0, 0, PROJECTILE_DOTC_DRONE_SCOUT);

	this.dotc_nextfire = time + this.shot_refire;

	if(this.drone_turret.lip == 0)
		this.dotc_nextfire = time + autocvar_g_dotc_scout_shot_refire2;
	else
		this.dotc_nextfire = time + this.shot_refire;

}

void dotc_scout_frame(entity this, vector formaion_loc, float tdelta)
{
	vector aim_at, aim_minmax;

	dotc_droneyaw(this);
	this.tur_shotorg = gettaginfo(this.drone_turret, gettagindex(this.drone_turret, "fire1"));

    if(this.squad.enemy)
    {
        /*this.enemy = this.squad.enemy;
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
                this.dotc_attack_spot_loc = formaion_loc;
            }
		}
        this.velocity = dotc_drone_move(this, this.dotc_attack_spot_loc , 0, 128, 0.5);*/

        this.velocity = dotc_drone_move(this, formaion_loc , 0, 128, 0.5);

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

	//this.velocity_z = -800 + dotc_hoverforce2(this, this.dotc_spring_length, this.dotc_spring_strength);
	this.velocity_z = dotc_hoverforce(this, this.dotc_spring_length, this.dotc_spring_strength);

	dotc_bob(this, 8, 12);
}

entity dotc_spawn_scout(entity sqd, entity own)
{
	entity drone = dotc_spawn_drone(sqd, own, MDL_DOTC_DRONE_SCOUT_BODY, MDL_DOTC_DRONE_SCOUT_TURRET, MDL_Null, MDL_DOTC_DRONE_SCOUT_DEAD.model_str(), "g_dotc_scout_", "g_dotc_scout_pexplode", dotc_scout_frame, dotc_scout_fire, DOTC_DRONETYPE_SCOUT);

	setsize(drone, '-30 -30 -5', '30 30 25');
	set_movetype(drone, MOVETYPE_BOUNCEMISSILE);
	drone.classname = "dotc_drone";
	drone.netname = "Scout";

	if(drone.waypointsprite_attached)
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_FLAG, '0.2 0.7 0.9');

	return drone;
}
#endif

#endif
