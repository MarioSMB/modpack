//FEATURE: Pick Spawns mutator, allowing you to choose where you spawn

#ifdef GAMEQC
REGISTER_MUTATOR(pickspawns, true);

REGISTER_STAT(PICK_SPAWNS, bool);
#endif

#ifdef SVQC
AUTOCVAR(g_pick_spawns, bool, false, "Allow players to choose where they spawn");
AUTOCVAR(g_pick_spawns_click_radius, float, 350, "");

.entity pickspawns_chosen;

entity pickspawns_Nearest_2D(entity this, vector pos, float max_dist)
{
	entity closest_target = NULL;

	FOREACH_ENTITY_CLASS("info_player_deathmatch", true,
	{
		if(teamplay && it.team != this.team) continue;

		vector my_delta = vec2(it.origin - pos);

		if(max_dist <= 0 || vdist(my_delta, <=, max_dist))
		if(!closest_target || vlen2(my_delta) <= vlen2(vec2(closest_target.origin - pos)))
			closest_target = it;
	});

	return closest_target;
}

MUTATOR_HOOKFUNCTION(pickspawns, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE || g_onslaught) // command was already handled?
		return false;

	string cmd_name = M_ARGV(1, string);

	if(cmd_name == "ons_spawn")
	{
		entity caller = M_ARGV(0, entity);
		int cmd_argc = M_ARGV(2, int);
		return = true;

		if(!autocvar_g_pick_spawns)
		{
			sprint(caller, "This command does not work without the pick spawns mutator.\n");
			return;
		}
		if (IS_PLAYER(caller) && !STAT(FROZEN, caller) && IS_DEAD(caller))
		{
			vector pos = caller.origin;
			if(cmd_argc > 1)
				pos_x = stof(argv(1));
			if(cmd_argc > 2)
				pos_y = stof(argv(2));
			if(cmd_argc > 3)
				pos_z = stof(argv(3));

			entity closest_target = pickspawns_Nearest_2D(caller, pos, autocvar_g_pick_spawns_click_radius);

			if ( !closest_target )
			{
				sprint(caller, "\nNo nearby spawn point found.\n");
				return;
			}

			caller.pickspawns_chosen = closest_target;
			caller.respawn_flags |= RESPAWN_FORCE;
		}
		return;
	}
}

MUTATOR_HOOKFUNCTION(pickspawns, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	STAT(PICK_SPAWNS, player) = autocvar_g_pick_spawns;
}

MUTATOR_HOOKFUNCTION(pickspawns, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	player.pickspawns_chosen = NULL;
}

MUTATOR_HOOKFUNCTION(pickspawns, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	player.pickspawns_chosen = NULL;
}

MUTATOR_HOOKFUNCTION(pickspawns, PlayerDies)
{
	entity frag_target = M_ARGV(2, entity);

	if(autocvar_g_pick_spawns)
		stuffcmd(frag_target, "\nqc_cmd_cl hud clickradar\n");
}

MUTATOR_HOOKFUNCTION(pickspawns, Spawn_Score)
{
	entity player = M_ARGV(0, entity);

	// give it a high score to favour
	if(autocvar_g_pick_spawns)
	if(M_ARGV(1, entity) == player.pickspawns_chosen)
		M_ARGV(2, vector) = '666 0 0'; // score
}
#endif

#ifdef CSQC
MUTATOR_HOOKFUNCTION(pickspawns, Ent_Update)
{
	entity ent = M_ARGV(0, entity);

	if(ent.classname == "ENT_CLIENT_SPAWNPOINT")
	if(STAT(PICK_SPAWNS))
	{
		ent.teamradar_icon = RADARICON_WAYPOINT.m_id;
		ent.teamradar_color = ((serverflags & SERVERFLAG_TEAMPLAY) ? Team_ColorRGB(ent.team - 1) : '1 1 1');
	}
}
#endif
