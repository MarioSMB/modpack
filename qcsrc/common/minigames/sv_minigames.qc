void player_clear_minigame(entity player)
{
	player.active_minigame = world;
	player.movetype = MOVETYPE_FLY_WORLDONLY;
}

void minigame_rmplayer(entity minigame_session, entity player)
{
	entity e;
	entity p = minigame_session.minigame_players;
	
	if ( p.minigame_players == player )
	{
		if ( p.chain == world )
		{
			end_minigame(minigame_session);
			return;
		}
		minigame_session.minigame_event(minigame_session,"part",player);
		GameLogEcho(strcat(":minigame:part:",minigame_session.netname,":",
			ftos(num_for_edict(player)),":",player.netname));
		minigame_session.minigame_players = p.chain;
		remove ( p );
		player_clear_minigame(player);
	}
	else
	{
		for ( e = p.chain; e != world; e = e.chain )
		{
			if ( e.minigame_players == player )
			{
				minigame_session.minigame_event(minigame_session,"part",player);
				GameLogEcho(strcat(":minigame:part:",minigame_session.netname,":",
					ftos(num_for_edict(player)),":",player.netname));
				p.chain = e.chain;
				remove(e);
				player_clear_minigame(player);
				return;
			}
			p = e;
		}
	}
}

// Send an entity to a client
// only use on minigame entities or entities with a minigame owner
float minigame_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_MINIGAME);
	WriteByte(MSG_ENTITY, sf);
	
	if ( sf & MINIG_SF_CREATE )
	{
		WriteString(MSG_ENTITY,self.classname);
		WriteString(MSG_ENTITY,self.netname);
	}
	
	entity minigame_ent = self.owner;
	
	if ( self.classname == "minigame" )
	{
		minigame_ent = self;
		
		if ( sf & MINIG_SF_CREATE )
		{
			WriteString(MSG_ENTITY,self.descriptor.netname);
		}
	}
	else if ( self.classname == "minigame_board_piece" )
	{
		if ( sf & MINIG_SF_CREATE )
		{
			WriteString(MSG_ENTITY,self.owner.netname);
			WriteByte(MSG_ENTITY,self.team);
			// TODO: colormod
		}
		if ( sf & MINIG_SF_UPDATE )
		{
			WriteShort(MSG_ENTITY,self.minigame_flags);
			WriteCoord(MSG_ENTITY,self.origin_x);
			WriteCoord(MSG_ENTITY,self.origin_y);
		}
	}
	else if ( self.classname == "minigame_player" )
	{
		if ( sf & MINIG_SF_CREATE )
		{
			WriteString(MSG_ENTITY,self.owner.netname);
			WriteLong(MSG_ENTITY,num_for_edict(self.minigame_players));
		}
		if ( sf & MINIG_SF_UPDATE )
			WriteByte(MSG_ENTITY,self.team);
	}
	
	minigame_ent.minigame_event(minigame_ent,"network_send",self,sf);
	
	return 1;
	
}

float minigame_CheckSend()
{
	entity e;
	for ( e = self.owner.minigame_players; e != world; e = e.chain )
		if ( e.minigame_players == other )
			return 1;
	return 0;
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
		player_pointer.classname = "minigame_player";
		player_pointer.owner = minigame_session;
		player_pointer.minigame_players = player;
		if ( minigame_session.minigame_players )
			player_pointer.team = minigame_session.minigame_players.team + 1;
		else
			player_pointer.team = 1;
		player_pointer.chain = minigame_session.minigame_players;
		minigame_session.minigame_players = player_pointer;
		player.active_minigame = minigame_session;
		player_pointer.customizeentityforclient = minigame_CheckSend;
		Net_LinkEntity(player_pointer, FALSE, 0, minigame_SendEntity);

		if ( !IS_OBSERVER(player) )
		{
			entity e = self;
			self = player;
			PutObserverInServer();
			self = e;
			player.team_forced = -1;
		}
	}
	GameLogEcho(strcat(":minigame:join",(ok?"":"fail"),":",minigame_session.netname,":",
		ftos(num_for_edict(player)),":",player.netname));
	
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
		GameLogEcho(strcat(":minigame:start:",minig.netname));
		if ( ! minigame_addplayer(minig,player) )
		{
			dprint("Minigame ",minig.netname," rejected the first player join!\n");
			end_minigame(minig);
			return world;
		}
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
	GameLogEcho(strcat(":minigame:end:",minigame_session.netname));
	
	
	entity e = world;
	while( (e = findentity(e, owner, minigame_session)) )
		if ( e.minigame_autoclean )
		{
			dprint("SV Auto-cleaned: ",ftos(num_for_edict(e)), " (",e.classname,")\n");
			remove(e);
		}
	
	entity p;
	for ( e = minigame_session.minigame_players; e != world; e = p )
	{
		p = e.chain;
		player_clear_minigame(e.minigame_players);
		remove(e);
	}
	
	strunzone(minigame_session.netname);
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
		minig.classname = "minigame_descriptor"; \
		minig.netname = #name; \
		minig.message = nicename; \
		minig.minigame_event = minigame_event_##name; \
		if ( !last_minig ) minigame_descriptors = minig; \
		else last_minig.chain = minig; \
		last_minig = minig;
		
	REGISTERED_MINIGAMES
	
	#undef MINIGAME
}

entity minigame_spawn_board_piece(entity minigame_session)
{
	entity e = spawn();
	e.classname = "minigame_board_piece";
	e.owner = minigame_session;
	e.customizeentityforclient = minigame_CheckSend;
	e.minigame_autoclean = 1;
	Net_LinkEntity(e, FALSE, 0, minigame_SendEntity);
	return e;
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
	
	GameLogEcho(strcat(":minigame:invite:",inviter.active_minigame.netname,":",
		ftos(num_for_edict(player)),":",player.netname));
	
	return "";
}
