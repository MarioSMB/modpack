void player_clear_minigame(entity player)
{
	player.active_minigame = world;
	if ( IS_PLAYER(player) )
		player.movetype = MOVETYPE_WALK;
	else
		player.movetype = MOVETYPE_FLY_WORLDONLY;
}

void minigame_rmplayer(entity minigame_session, entity player)
{
	entity e;
	entity p = minigame_session.minigame_players;
	
	if ( p.owner == player )
	{
		if ( p.chain == world )
		{
			end_minigame(minigame_session);
			return;
		}
		minigame_session.minigame_event(minigame_session,"part",player);
		minigame_session.minigame_players = p.chain;
		remove ( p );
		player_clear_minigame(player);
	}
	else
	{
		for ( e = p.chain; e != world; e = e.chain )
		{
			if ( e.owner == player )
			{
				minigame_session.minigame_event(minigame_session,"part",player);
				p.chain = e.chain;
				remove(e);
				player_clear_minigame(player);
				return;
			}
			p = e;
		}
	}
}

float minigame_addplayer(entity minigame_session, entity player)
{
	if ( player.active_minigame )
		minigame_rmplayer(player.active_minigame,player);
	
	float ok = minigame_session.minigame_event(minigame_session,"join",player);
	
	if ( ok )
	{
		entity player_pointer = spawn();
		player_pointer.owner = player;
		//TODO append new player at the end of the list (?)
		player_pointer.chain = minigame_session.minigame_players;
		minigame_session.minigame_players = player_pointer;
		player.active_minigame = minigame_session;
		self.movetype = MOVETYPE_NONE;
	}
	
	return ok;
}

entity start_minigame(entity player, string minigame )
{
	if ( !autocvar_sv_minigames || !IS_REAL_CLIENT(player) )
		return world;
	
	entity e = minigame_get_descriptor(minigame);
	if ( e ) 
	{
		entity minig = spawn();
		minig.classname = "minigame";
		minig.descriptor = e;
		minig.minigame_event = e.minigame_event;
		minig.minigame_event(minig,"start");
		minigame_addplayer(minig,player);
		
		if ( !minigame_sessions )
			minigame_sessions = minig;
		else
		{
			minigame_sessions.owner = minig;
			minig.chain = minigame_sessions;
			minigame_sessions = minig;
		}
		return minig;
	}
		
	return world;
}

entity join_minigame(entity player, float game_id )
{
	if ( !autocvar_sv_minigames || !IS_REAL_CLIENT(player) )
		return world;
	
	entity minig = edict_num(game_id);
	
	if ( minig && minig.classname == "minigame" )
	if ( minigame_addplayer(minig,player) )
		return minig;
	
	return world;
}

void part_minigame(entity player )
{
	entity minig = player.active_minigame;
	
	if ( minig && minig.classname == "minigame" )
		minigame_rmplayer(minig,player);
}

void end_minigame(entity minigame_session)
{
	if ( minigame_session.owner )
		minigame_session.owner.chain = minigame_session.chain;
	else
		minigame_sessions = minigame_session.chain;
	
	minigame_session.minigame_event(minigame_session,"end");
	
	entity e, p;
	for ( e = minigame_session.minigame_players; e != world; e = p )
	{
		p = e.chain;
		player_clear_minigame(e.owner);
		remove(e);
	}
	
	remove(minigame_session);
}

void end_minigames()
{
	while ( minigame_sessions )
	{
		end_minigame(minigame_sessions);
	}
}

void initialize_minigames()
{
	entity last_minig = world;
	entity minig;
	#define MINIGAME(name) \
		minig = spawn(); \
		minig.netname = strzone(strtolower(#name)); \
		minig.minigame_event = minigame_event_##name; \
		if ( !last_minig ) minigame_descriptors = minig; \
		else last_minig.chain = minig; \
		last_minig = minig;
		
	REGISTERED_MINIGAMES
	
	#undef MINIGAME
}