/*
 * Impulse map:
 *
 * 0 reserved (no input)
 * 1 to 9, 14: weapon shortcuts
 * 10: next weapon according to linear list
 * 11: most recently used weapon
 * 12: previous weapon according to linear list
 * 13: best weapon according to priority list
 * 15: next weapon according to priority list
 * 16: previous weapon according to priority list
 * 17: throw weapon
 * 18: next weapon according to sbar_hudselector 1 list
 * 19: previous weapon according to sbar_hudselector 1 list
 * 20: reload if needed
 *
 * 30 to 39: create waypoints
 * 47: clear personal waypoints
 * 48: clear team waypoints
 *
 * 99: loaded
 *
 * 140: moving clone
 * 141: ctf speedrun
 * 142: fixed clone
 * 143: emergency teleport
 * 148: unfairly eliminate
 *
 * TODO:
 * 200 to 209: prev weapon shortcuts
 * 210 to 219: best weapon shortcuts
 * 220 to 229: next weapon shortcuts
 * 230 to 253: individual weapons (up to 24)
 */

void ImpulseCommands (void)
{
	float imp;
	vector org;
	float i;
	float m;
	entity e, e2;

	imp = self.impulse;
	if (!imp || gameover)
		return;
	self.impulse = 0;

	// forbid impulses when not in round time
	if(round_handler_IsActive() && !round_handler_IsRoundStarted())
		return;

	if (timeout_status == TIMEOUT_ACTIVE) //don't allow any impulses while the game is paused
		return;
    
    if(self.vehicle)
        if(self.vehicle.deadflag == DEAD_NO)
            if(self.vehicle.vehicles_impusle)
                if(self.vehicle.vehicles_impusle(imp))
                    return;
    
	if(CheatImpulse(imp))
	{
	}
	else if (imp >= 1 && imp <= 9)
	{
		// weapon switching impulses
		if(self.deadflag == DEAD_NO)
			W_NextWeaponOnImpulse(imp);
		else
			self.impulse = imp; // retry in next frame
	}
	else if(imp >= 10 && imp <= 20)
	{
		if(self.deadflag == DEAD_NO)
		{
			switch(imp)
			{
				case 10:
					W_NextWeapon (0);
					break;
				case 11:
					W_LastWeapon();
					break;
				case 12:
					W_PreviousWeapon (0);
					break;
				case 13:
					W_SwitchWeapon (w_getbestweapon(self));
					break;
				case 14:
					W_NextWeaponOnImpulse(0);
					break;
				case 15:
					W_NextWeapon (2);
					break;
				case 16:
					W_PreviousWeapon (2);
					break;
				case 17:
					W_ThrowWeapon(W_CalculateProjectileVelocity(self.velocity, v_forward * 750, FALSE), '0 0 0', TRUE);
					break;
				case 18:
					W_NextWeapon (1);
					break;
				case 19:
					W_PreviousWeapon (1);
					break;
				case 20:
					W_TriggerReload ();
					break;
			}
		}
		else
			self.impulse = imp; // retry in next frame
	}
	else if(imp == 21)
	{
		PlayerUseKey ();
	}
	else if(imp >= 200 && imp <= 229)
	{
		if(self.deadflag == DEAD_NO)
		{
			// custom order weapon cycling
			i = mod(imp, 10);
			m = (imp - (210 + i)); // <0 for prev, =0 for best, >0 for next
			W_CycleWeapon(self.(cvar_cl_weaponpriorities[i]), m);
		}
		else
			self.impulse = imp; // retry in next frame
	}
	else if(imp >= 230 && imp <= 253)
	{
		if(self.deadflag == DEAD_NO)
			W_SwitchWeapon (imp - 230 + WEP_FIRST);
		else
			self.impulse = imp; // retry in next frame
	}
	// deploy waypoints
	else if (imp >= 30 && imp <= 49)
	{
		entity wp;
		switch(imp)
		{
			case 30:
				wp = WaypointSprite_DeployPersonal("waypoint", self.origin, RADARICON_WAYPOINT, '0 1 1');
				if(wp)
					WaypointSprite_Ping(wp);
				sprint(self, "personal waypoint spawned at location\n");
				break;
			case 31:
				WarpZone_crosshair_trace(self);
				wp = WaypointSprite_DeployPersonal("waypoint", trace_endpos, RADARICON_WAYPOINT, '0 1 1');
				if(wp)
					WaypointSprite_Ping(wp);
				sprint(self, "personal waypoint spawned at crosshair\n");
				break;
			case 32:
				if(vlen(self.death_origin))
				{
					wp = WaypointSprite_DeployPersonal("waypoint", self.death_origin, RADARICON_WAYPOINT, '0 1 1');
					if(wp)
						WaypointSprite_Ping(wp);
					sprint(self, "personal waypoint spawned at death location\n");
				}
				break;
			case 33:
				if(self.deadflag == DEAD_NO && teamplay)
				{
					if not(MUTATOR_CALLHOOK(HelpMePing))
					{
						wp = WaypointSprite_Attach("helpme", TRUE, RADARICON_HELPME, '1 0.5 0');
						if(!wp)
							WaypointSprite_HelpMePing(self.waypointsprite_attachedforcarrier);
						else
							WaypointSprite_Ping(wp);
					}
					sprint(self, "HELP ME attached\n");
				}
				break;
			case 34:
				wp = WaypointSprite_DeployFixed("here", FALSE, self.origin, RADARICON_HERE, '0 1 0');
				if(wp)
					WaypointSprite_Ping(wp);
				sprint(self, "HERE spawned at location\n");
				break;
			case 35:
				WarpZone_crosshair_trace(self);
				wp = WaypointSprite_DeployFixed("here", FALSE, trace_endpos, RADARICON_HERE, '0 1 0');
				if(wp)
					WaypointSprite_Ping(wp);
				sprint(self, "HERE spawned at crosshair\n");
				break;
			case 36:
				if(vlen(self.death_origin))
				{
					wp = WaypointSprite_DeployFixed("here", FALSE, self.death_origin, RADARICON_HERE, '0 1 0');
					if(wp)
						WaypointSprite_Ping(wp);
					sprint(self, "HERE spawned at death location\n");
				}
				break;
			case 37:
				wp = WaypointSprite_DeployFixed("danger", FALSE, self.origin, RADARICON_DANGER, '1 0.5 0');
				if(wp)
					WaypointSprite_Ping(wp);
				sprint(self, "DANGER spawned at location\n");
				break;
			case 38:
				WarpZone_crosshair_trace(self);
				wp = WaypointSprite_DeployFixed("danger", FALSE, trace_endpos, RADARICON_DANGER, '1 0.5 0');
				if(wp)
					WaypointSprite_Ping(wp);
				sprint(self, "DANGER spawned at crosshair\n");
				break;
			case 39:
				if(vlen(self.death_origin))
				{
					wp = WaypointSprite_DeployFixed("danger", FALSE, self.death_origin, RADARICON_DANGER, '1 0.5 0');
					if(wp)
						WaypointSprite_Ping(wp);
					sprint(self, "DANGER spawned at death location\n");
				}
				break;
			case 47:
				WaypointSprite_ClearPersonal();
				if(self.personal)
				{
					remove(self.personal);
					self.personal = world;
				}
				sprint(self, "personal waypoint cleared\n");
				break;
			case 48:
				WaypointSprite_ClearOwned();
				if(self.personal)
				{
					remove(self.personal);
					self.personal = world;
				}
				sprint(self, "all waypoints cleared\n");
				break;
		}
	}
	else if(imp >= 103 && imp <= 107)
	{
		if(autocvar_g_waypointeditor)
		{
			switch(imp)
			{
				case 103:
					waypoint_schedulerelink(waypoint_spawn(self.origin, self.origin, 0));
					bprint(strcat("Waypoint spawned at ",vtos(self.origin),"\n"));
					break;
				case 104:
					e = navigation_findnearestwaypoint(self, FALSE);
					if (e)
					if not(e.wpflags & WAYPOINTFLAG_GENERATED)
					{
						bprint(strcat("Waypoint removed at ",vtos(e.origin),"\n"));
						waypoint_remove(e);
					}
					break;
				case 105:
					waypoint_schedulerelinkall();
					break;
				case 106:
					waypoint_saveall();
					break;
				case 107:
					for(e = findchain(classname, "waypoint"); e; e = e.chain)
					{
						e.colormod = '0.5 0.5 0.5';
						e.effects &= ~(EF_NODEPTHTEST | EF_RED | EF_BLUE);
					}
					e2 = navigation_findnearestwaypoint(self, FALSE);
					navigation_markroutes(e2);
					i = 0;
					m = 0;
					for(e = findchain(classname, "waypoint"); e; e = e.chain)
					{
						if(e.wpcost >= 10000000)
						{
							print("unreachable: ", etos(e), " ", vtos(e.origin), "\n");
							e.colormod_z = 8;
							e.effects |= EF_NODEPTHTEST | EF_BLUE;
							++i;
							++m;
						}
					}
					if(i)
						print(ftos(i), " waypoints cannot be reached from here in any way (marked with blue light)\n");
					navigation_markroutes_inverted(e2);
					i = 0;
					for(e = findchain(classname, "waypoint"); e; e = e.chain)
					{
						if(e.wpcost >= 10000000)
						{
							print("cannot reach me: ", etos(e), " ", vtos(e.origin), "\n");
							e.colormod_x = 8;
							if not(e.effects & EF_NODEPTHTEST) // not already reported before
								++m;
							e.effects |= EF_NODEPTHTEST | EF_RED;
							++i;
						}
					}
					if(i)
						print(ftos(i), " waypoints cannot walk to here in any way (marked with red light)\n");
					if(m)
						print(ftos(m), " waypoints have been marked total\n");
					i = 0;
					for(e = findchain(classname, "info_player_deathmatch"); e; e = e.chain)
					{
						org = e.origin;
						tracebox(e.origin, PL_MIN, PL_MAX, e.origin - '0 0 512', MOVE_NOMONSTERS, world);
						setorigin(e, trace_endpos);
						if(navigation_findnearestwaypoint(e, FALSE))
						{
							setorigin(e, org);
							e.effects &= ~EF_NODEPTHTEST;
							e.model = "";
						}
						else
						{
							setorigin(e, org);
							print("spawn without waypoint: ", etos(e), " ", vtos(e.origin), "\n");
							e.effects |= EF_NODEPTHTEST;
							setmodel(e, self.model);
							e.frame = self.frame;
							e.skin = self.skin;
							e.colormod = '8 0.5 8';
							setsize(e, '0 0 0', '0 0 0');
							++i;
						}
					}
					if(i)
						print(ftos(i), " spawnpoints have no nearest waypoint (marked by player model)\n");
					i = 0;
					entity start;
					start = findchainflags(flags, FL_ITEM);
					for(e = start; e; e = e.chain)
					{
						e.effects &= ~(EF_NODEPTHTEST | EF_RED | EF_BLUE);
						e.colormod = '0.5 0.5 0.5';
					}
					for(e = start; e; e = e.chain)
					{
						if(navigation_findnearestwaypoint(e, FALSE))
						{
						}
						else
						{
							print("item without waypoint: ", etos(e), " ", vtos(e.origin), "\n");
							e.effects |= EF_NODEPTHTEST | EF_RED;
							e.colormod_x = 8;
							++i;
						}
					}
					if(i)
						print(ftos(i), " items have no nearest waypoint and cannot be walked away from (marked with red light)\n");
					i = 0;
					for(e = start; e; e = e.chain)
					{
						org = e.origin;
						if(navigation_findnearestwaypoint(e, TRUE))
						{
						}
						else
						{
							print("item without waypoint: ", etos(e), " ", vtos(e.origin), "\n");
							e.effects |= EF_NODEPTHTEST | EF_BLUE;
							e.colormod_z = 8;
							++i;
						}
					}
					if(i)
						print(ftos(i), " items have no nearest waypoint and cannot be walked to (marked with blue light)\n");
					break;
			}
		}
	}
#ifdef TETRIS
	else if(imp == 100)
		TetrisImpulse();
#endif
}
