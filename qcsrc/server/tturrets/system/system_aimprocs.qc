/*
* Generic aim

supports:
TFL_AIM_NO
TFL_AIM_GROUNDGROUND
TFL_AIM_LEAD
TFL_AIM_SHOTTIMECOMPENSATE
*/
vector turret_stdproc_aim_generic()
{

    vector pre_pos, prep;
    float distance, impact_time, i, mintime;

    turret_tag_fire_update();

    if(self.aim_flags & TFL_AIM_SIMPLE)
        return real_origin(self.enemy);

	mintime = max(self.attack_finished_single - time,0) + sys_frametime;

    // Baseline
    pre_pos = real_origin(self.enemy);

    // Lead?
    if (self.aim_flags & TFL_AIM_LEAD)
    {    	
		if (self.aim_flags & TFL_AIM_SHOTTIMECOMPENSATE)       // Need to conpensate for shot traveltime
		{
			// FIXME: this cant be the best way to do this..
			prep = pre_pos;
#ifdef GMQCC
			impact_time = 0;
#endif
			for(i = 0; i < 4; ++i)
			{
				distance = vlen(prep - self.tur_shotorg);
				impact_time = distance / self.shot_speed;
				prep = pre_pos + self.enemy.velocity * impact_time;
			}

			prep = pre_pos + (self.enemy.velocity * (impact_time + mintime));

			if(self.aim_flags & TFL_AIM_ZPREDICT)
			if not(self.enemy.flags & FL_ONGROUND)
			if(self.enemy.movetype == MOVETYPE_WALK || self.enemy.movetype == MOVETYPE_TOSS || self.enemy.movetype == MOVETYPE_BOUNCE)
			{
				float vz;
				prep_z = pre_pos_z;
				vz = self.enemy.velocity_z;
				for(i = 0; i < impact_time; i += sys_frametime)
				{
					vz = vz - (autocvar_sv_gravity * sys_frametime);
					prep_z = prep_z + vz * sys_frametime;
				}
			}
			pre_pos = prep;
		}
		else
			pre_pos = pre_pos + self.enemy.velocity * mintime;
    }
    
    if(self.aim_flags & TFL_AIM_GROUNDGROUND)
    {
        //tracebox(pre_pos + '0 0 32',self.enemy.mins,self.enemy.maxs,pre_pos -'0 0 64',MOVE_WORLDONLY,self.enemy);
        traceline(pre_pos + '0 0 32',pre_pos -'0 0 64',MOVE_WORLDONLY,self.enemy);
        if(trace_fraction != 1.0)
            pre_pos = trace_endpos;
    }

    return pre_pos;
}
