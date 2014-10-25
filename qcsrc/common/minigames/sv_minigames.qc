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
		minigame_session.SendFlags |= MINIG_SF_PLAYERS;
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
				minigame_session.SendFlags |= MINIG_SF_PLAYERS;
				return;
			}
			p = e;
		}
	}
}


float minigame_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_MINIGAME);
	WriteByte(MSG_ENTITY, sf);
	
	if ( sf & MINIG_SF_CREATE )
	{
		WriteString(MSG_ENTITY,self.classname);
		WriteString(MSG_ENTITY,self.netname);
	}
	
	if ( self.classname == "minigame" )
	{
		if ( sf & MINIG_SF_CREATE )
		{
			WriteString(MSG_ENTITY,self.descriptor.netname);
		}
		
		if ( sf & MINIG_SF_PLAYERS )
		{
			entity e;
			float n = 0;
			for ( e = self.minigame_players; e != world; e = e.chain )
				n++;
			WriteByte(MSG_ENTITY,n);
			for ( e = self.minigame_players; e != world; e = e.chain )
			{
				WriteLong(MSG_ENTITY,num_for_edict(e.owner));
			}
		}
	}
	else if ( self.classname == "minigame_board_tile" )
	{
		WriteString(MSG_ENTITY,self.owner.netname);
		WriteCoord(MSG_ENTITY,self.origin_x);
		WriteCoord(MSG_ENTITY,self.origin_y);
	}
	
	return 1;
	
}

float minigame_addplayer(entity minigame_session, entity player)
{
	if ( player.active_minigame )
	{
		if ( player.active_minigame == minigame_session )
			return 0;
		minigame_rmplayer(player.active_minigame,player);
	}
	
	float ok = minigame_session.minigame_event(minigame_session,"join",player);
	
	if ( ok )
	{
		entity player_pointer = spawn();
		player_pointer.owner = player;
		//TODO append new player at the end of the list (?)
		player_pointer.chain = minigame_session.minigame_players;
		minigame_session.minigame_players = player_pointer;
		player.active_minigame = minigame_session;
		player.movetype = MOVETYPE_NONE;
		minigame_session.SendFlags |= MINIG_SF_PLAYERS;
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
		minig.netname = strzone(strcat(e.netname,"_",ftos(num_for_edict(minig))));
		minig.descriptor = e;
		minig.minigame_event = e.minigame_event;
		minig.minigame_event(minig,"start");
		minigame_addplayer(minig,player);
		Net_LinkEntity(minig, FALSE, 0, minigame_SendEntity);
		
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

entity join_minigame(entity player, string game_id )
{
	if ( !autocvar_sv_minigames || !IS_REAL_CLIENT(player) )
		return world;
	
	entity minig;
	for ( minig = minigame_sessions; minig != world; minig = minig.chain )
	{
		if ( minig.netname == game_id )
		if ( minigame_addplayer(minig,player) )
			return minig;
	}
	
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
	#define MINIGAME(name,nicename) \
		minig = spawn(); \
		minig.netname = strzone(strtolower(#name)); \
		minig.message = nicename; \
		minig.minigame_event = minigame_event_##name; \
		if ( !last_minig ) minigame_descriptors = minig; \
		else last_minig.chain = minig; \
		last_minig = minig;
		
	REGISTERED_MINIGAMES
	
	#undef MINIGAME
}

void minigame_spawn_board_tile(entity minigame_session, string id, vector pos)
{
	entity e = spawn();
	e.origin = pos;
	e.classname = "minigame_board_tile";
	e.netname = id;
	e.owner = minigame_session;
	Net_LinkEntity(e, FALSE, 0, minigame_SendEntity);
}

string invite_minigame(entity inviter, entity player)
{
	if ( !inviter || !inviter.active_minigame )
		return "Invalid minigame";
	if ( !VerifyClientEntity(player, TRUE, FALSE) )
		return "Invalid player";
	if ( inviter == player )
		return "You can't invite yourself";
	if ( player.active_minigame == inviter.active_minigame )
		return strcat(player.netname," is already playing");
	
	Send_Notification(NOTIF_ONE, player, MSG_INFO, INFO_MINIGAME_INVITE, 
		inviter.active_minigame.netname, inviter.netname );
	
	return "";
}
