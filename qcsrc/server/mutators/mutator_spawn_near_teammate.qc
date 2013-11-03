.entity msnt_lookat;

.float msnt_timer;
.vector msnt_deathloc;

MUTATOR_HOOKFUNCTION(msnt_Spawn_Score)
{
	if(autocvar_g_spawn_near_teammate_ignore_spawnpoint)
		return 0;

	entity p;

	spawn_spot.msnt_lookat = world;

	if(!teamplay)
		return 0;

	RandomSelection_Init();
	FOR_EACH_PLAYER(p) if(p != self) if(p.team == self.team) if(!p.deadflag)
	{
		float l = vlen(spawn_spot.origin - p.origin);
		if(l > autocvar_g_spawn_near_teammate_distance)
			continue;
		if(l < 48)
			continue;
		if(!checkpvs(spawn_spot.origin, p))
			continue;
		RandomSelection_Add(p, 0, string_null, 1, 1);
	}

	if(RandomSelection_chosen_ent)
	{
		spawn_spot.msnt_lookat = RandomSelection_chosen_ent;
		spawn_score_x += SPAWN_PRIO_NEAR_TEAMMATE_FOUND;
	}
	else if(self.team == spawn_spot.team)
		spawn_score_x += SPAWN_PRIO_NEAR_TEAMMATE_SAMETEAM; // prefer same team, if we can't find a spawn near teammate

	return 0;
}

MUTATOR_HOOKFUNCTION(msnt_PlayerSpawn)
{
	if(autocvar_g_spawn_near_teammate_ignore_spawnpoint)
	{
		if(autocvar_g_spawn_near_teammate_ignore_spawnpoint_delay_death)
			self.msnt_timer = time + autocvar_g_spawn_near_teammate_ignore_spawnpoint_delay_death;
			
		entity team_mate, best_mate = world;
		vector best_spot = '0 0 0';
		float pc = 0, best_dist = 0, dist = 0;
		FOR_EACH_PLAYER(team_mate)
		{
			if((autocvar_g_spawn_near_teammate_ignore_spawnpoint_check_health >= 0 && team_mate.health >= autocvar_g_balance_health_regenstable) || autocvar_g_spawn_near_teammate_ignore_spawnpoint_check_health == 0)
			if(team_mate.deadflag == DEAD_NO)
			if(team_mate.msnt_timer < time)
			if(SAME_TEAM(self, team_mate))
			if(time > team_mate.spawnshieldtime) // spawn shielding
			if(team_mate.frozen == 0)
			if(team_mate != self)
			{
				tracebox(team_mate.origin, PL_MIN, PL_MAX, team_mate.origin - '0 0 100', MOVE_WORLDONLY, team_mate);
				if(trace_fraction != 1.0)
				if(!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY))
				{
					pc = pointcontents(trace_endpos + '0 0 1');
					if(pc == CONTENT_EMPTY)
					{
						if(vlen(team_mate.velocity) > 5)
							fixedmakevectors(vectoangles(team_mate.velocity));
						else
							fixedmakevectors(team_mate.angles);

						for(pc = 0; pc != 5; ++pc) // test 5 diffrent spots close to mate
						{
							switch(pc)
							{
								case 0:
									tracebox(team_mate.origin , PL_MIN, PL_MAX, team_mate.origin + v_right * 128, MOVE_NORMAL, team_mate);
									break;
								case 1:
									tracebox(team_mate.origin , PL_MIN, PL_MAX, team_mate.origin - v_right * 128 , MOVE_NORMAL, team_mate);
									break;
								case 2:
									tracebox(team_mate.origin , PL_MIN, PL_MAX, team_mate.origin + v_right * 64 - v_forward * 64, MOVE_NORMAL, team_mate);
									break;
								case 3:
									tracebox(team_mate.origin , PL_MIN, PL_MAX, team_mate.origin - v_right * 64 - v_forward * 64, MOVE_NORMAL, team_mate);
									break;
								case 4:
									tracebox(team_mate.origin , PL_MIN, PL_MAX, team_mate.origin - v_forward * 128, MOVE_NORMAL, team_mate);
									break;
							}

							if(trace_fraction == 1.0)
							{
								traceline(trace_endpos + '0 0 4', trace_endpos - '0 0 100', MOVE_NORMAL, team_mate);
								if(trace_fraction != 1.0)
								{
									if(autocvar_g_spawn_near_teammate_ignore_spawnpoint_closetodeath)
									{
										dist = vlen(trace_endpos - self.msnt_deathloc);
										if(dist < best_dist || best_dist == 0)
										{
											best_dist = dist;
											best_spot = trace_endpos;
											best_mate = team_mate;
										}
									}
									else
									{
										setorigin(self, trace_endpos);
										self.angles = team_mate.angles;
										self.angles_z = 0; // never spawn tilted even if the spot says to
										self.fixangle = TRUE; // turn this way immediately
										team_mate.msnt_timer = time + autocvar_g_spawn_near_teammate_ignore_spawnpoint_delay;
										return 0;
									}
								}
							}
						}
					}
				}
			}
		}

		if(autocvar_g_spawn_near_teammate_ignore_spawnpoint_closetodeath)
		if(best_dist)
		{
			setorigin(self, best_spot);
			self.angles = best_mate.angles;
			self.angles_z = 0; // never spawn tilted even if the spot says to
			self.fixangle = TRUE; // turn this way immediately
			best_mate.msnt_timer = time + autocvar_g_spawn_near_teammate_ignore_spawnpoint_delay;
		}
	}
	else if(spawn_spot.msnt_lookat)
	{
		self.angles = vectoangles(spawn_spot.msnt_lookat.origin - self.origin);
		self.angles_x = -self.angles_x;
		self.angles_z = 0; // never spawn tilted even if the spot says to
		self.fixangle = TRUE; // turn this way immediately
		/*
		sprint(self, "You should be looking at ", spawn_spot.msnt_lookat.netname, "^7.\n");
		sprint(self, "distance: ", vtos(spawn_spot.msnt_lookat.origin - self.origin), "\n");
		sprint(self, "angles: ", vtos(self.angles), "\n");
		*/
	}

	return 0;
}

MUTATOR_HOOKFUNCTION(msnt_PlayerDies)
{
	self.msnt_deathloc = self.origin;
	return 0;
}

MUTATOR_DEFINITION(mutator_spawn_near_teammate)
{
	MUTATOR_HOOK(Spawn_Score, msnt_Spawn_Score, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, msnt_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, msnt_PlayerDies, CBC_ORDER_ANY);

	return 0;
}
