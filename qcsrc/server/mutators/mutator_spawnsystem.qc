.float spawnsys_timer;
.vector spawnsys_deathloc;

MUTATOR_HOOKFUNCTION(spawn_PlayerDies)
{
	self.spawnsys_deathloc = self.origin;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(spawn_PlayerSpawn)
{
	if(autocvar_g_spawnsystem_delay_death)
		self.spawnsys_timer = time + autocvar_g_spawnsystem_delay_death;

	if not(autocvar_g_spawnsystem)
		return FALSE;

	entity team_mate, best_mate = world;
	vector best_spot = '0 0 0';
	float pc = 0, best_dist = 0, dist = 0;
	FOR_EACH_PLAYER(team_mate)
	{
		if((autocvar_g_spawnsystem_check_health >= 0 && team_mate.health >= autocvar_g_balance_health_regenstable) || autocvar_g_spawnsystem_check_health == 0)
		if(team_mate.deadflag == DEAD_NO)
		if(team_mate.spawnsys_timer < time)
		if(!IsDifferentTeam(self, team_mate))
		if(team_mate != self)
		{
			tracebox(team_mate.origin, PL_MIN, PL_MAX, team_mate.origin - '0 0 100', MOVE_WORLDONLY, team_mate);
			if(trace_fraction != 1.0)
			if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
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
								tracebox(team_mate.origin , PL_MIN, PL_MAX,team_mate.origin - v_right * 128 , MOVE_NORMAL, team_mate);
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
								if(autocvar_g_spawnsystem_closetodeath)
								{
									dist = vlen(trace_endpos - self.spawnsys_deathloc);
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
									team_mate.spawnsys_timer = time + autocvar_g_spawnsystem_delay;
									return 0;
								}
							}
						}
					}
				}
			}
		}
	}

	if(autocvar_g_spawnsystem_closetodeath)
	if(best_dist)
	{
		setorigin(self, best_spot);
		self.angles = best_mate.angles;
		self.fixangle = TRUE;
		best_mate.spawnsys_timer = time + autocvar_g_spawnsystem_delay;
	}
	
	return FALSE;
}

MUTATOR_DEFINITION(mutator_spawnsystem)
{
	MUTATOR_HOOK(PlayerDies, spawn_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, spawn_PlayerSpawn, CBC_ORDER_ANY);

	return FALSE;
}
