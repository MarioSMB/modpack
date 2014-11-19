void player_clear_minigame(entity player)
{
	player.active_minigame = world;
	if ( IS_PLAYER(player) )
		player.movetype = MOVETYPE_WALK;
	else
		player.movetype = MOVETYPE_FLY_WORLDONLY;
	player.team_forced = 0;
}

void minigame_rmplayer(entity minigame_session, entity player)
{
	entity e;
	entity p = minigame_session.minigame_players;
	
	if ( p.minigame_players == player )
	{
		if ( p.list_next == world )
		{
			end_minigame(minigame_session);
			return;
		}
		minigame_session.minigame_event(minigame_session,"part",player);
		GameLogEcho(strcat(":minigame:part:",minigame_session.netname,":",
			ftos(num_for_edict(player)),":",player.netname));
		minigame_session.minigame_players = p.list_next;
		remove ( p );
		player_clear_minigame(player);
	}
	else
	{
		for ( e = p.list_next; e != world; e = e.list_next )
		{
			if ( e.minigame_players == player )
			{
				minigame_session.minigame_event(minigame_session,"part",player);
				GameLogEcho(strcat(":minigame:part:",minigame_session.netname,":",
					ftos(num_for_edict(player)),":",player.netname));
				p.list_next = e.list_next;
				remove(e);
				player_clear_minigame(player);
				return;
			}
			p = e;
		}
	}
}


#define FIELD(Flags, Type,Name) if ( sf & (Flags) ) Write##Type(MSG_ENTITY, self.Name);
#define WriteVector(to,Name) WriteCoord(to,Name##_x); WriteCoord(to,Name##_y); WriteCoord(to,Name##_z)
#define WriteVector2D(to,Name) WriteCoord(to,Name##_x); WriteCoord(to,Name##_y)
#define WriteFloat WriteCoord
#define MSLE(Name,Fields) \
	else if ( self.classname == #Name ) { \
		if ( sf & MINIG_SF_CREATE ) WriteString(MSG_ENTITY,self.owner.netname); \
		Fields }

// Send an entity to a client
// only use on minigame entities or entities with a minigame owner
float minigame_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_MINIGAME);
	WriteByte(MSG_ENTITY, sf);
	
	if ( sf & MINIG_SF_CREATE )
	{
		WriteShort(MSG_ENTITY,msle_id(self.classname));
		WriteString(MSG_ENTITY,self.netname);
	}
	
	entity minigame_ent = self.owner;
	
	if ( self.classname == "minigame" )
	{
		minigame_ent = self;
		
		if ( sf & MINIG_SF_CREATE )
			WriteString(MSG_ENTITY,self.descriptor.netname);
		
		if ( sf & MINIG_SF_UPDATE )
			WriteLong(MSG_ENTITY,self.minigame_flags);
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
	MINIGAME_SIMPLELINKED_ENTITIES
	
	minigame_ent.minigame_event(minigame_ent,"network_send",self,sf);
	
	return 1;
	
}
#undef FIELD
#undef MSLE
#undef WriteFloat

// Force resend all minigame entities
void minigame_resend(entity minigame)
{
	minigame.SendFlags = MINIG_SF_ALL;
	entity e = world;
	while (( e = findentity(e,owner,minigame) ))
	{
		e.SendFlags = MINIG_SF_ALL;
	}
}

float minigame_CheckSend()
{
	entity e;
	for ( e = self.owner.minigame_players; e != world; e = e.list_next )
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
	
	float mgteam = minigame_session.minigame_event(minigame_session,"join",player);
	
	if ( mgteam )
	{
		entity player_pointer = spawn();
		player_pointer.classname = "minigame_player";
		player_pointer.owner = minigame_session;
		player_pointer.minigame_players = player;
		player_pointer.team = mgteam;
		player_pointer.list_next = minigame_session.minigame_players;
		minigame_session.minigame_players = player_pointer;
		player.active_minigame = minigame_session;
		player_pointer.customizeentityforclient = minigame_CheckSend;
		Net_LinkEntity(player_pointer, FALSE, 0, minigame_SendEntity);

		if ( !IS_OBSERVER(player) && autocvar_sv_minigames_observer )
		{
			entity e = self;
			self = player;
			PutObserverInServer();
			self = e;
		}
		if ( autocvar_sv_minigames_observer == 2 )
			player.team_forced = -1;
		
		minigame_resend(minigame_session);
	}
	GameLogEcho(strcat(":minigame:join",(mgteam?"":"fail"),":",minigame_session.netname,":",
		ftos(num_for_edict(player)),":",player.netname));
	
	return mgteam;
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
			minig.list_next = minigame_sessions;
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
	for ( minig = minigame_sessions; minig != world; minig = minig.list_next )
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
		minigame_session.owner.list_next = minigame_session.list_next;
	else
		minigame_sessions = minigame_session.list_next;
	
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
		p = e.list_next;
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
		else last_minig.list_next = minig; \
		last_minig = minig;
		
	REGISTERED_MINIGAMES
	
	#undef MINIGAME
}

entity minigame_spawn_linked_entity(entity minigame_session, string class_name)
{
	entity e = spawn();
	e.classname = class_name;
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

entity minigame_find_player(entity client)
{
	if ( ! client.active_minigame )
		return world;
	entity e;
	for ( e = client.active_minigame.minigame_players; e; e = e.list_next )
		if ( e.minigame_players == client )
			return e;
	return world;
}

float MinigameImpulse(float imp)
{
	entity e = minigame_find_player(self);
	if ( imp && self.active_minigame && e )
	{
		return self.active_minigame.minigame_event(self.active_minigame,"impulse",e,imp);
	}
	return 0;
}



void ClientCommand_minigame(float request, float argc, string command)
{
	if ( !autocvar_sv_minigames )
	{
		sprint(self,"Minigames are not enabled!\n");
		return;
	}
	
	if (request == CMD_REQUEST_COMMAND )
	{
		string minig_cmd = argv(1);
		if ( minig_cmd == "create" && argc > 2 )
		{
			entity minig = start_minigame(self, argv(2));
			if ( minig )
				sprint(self,"Created minigame session: ",minig.netname,"\n");
			else
				sprint(self,"Cannot start minigame session!\n");
			return;
		}
		else if ( minig_cmd == "join" && argc > 2 )
		{
			entity minig = join_minigame(self, argv(2));
			if ( minig )
				sprint(self,"Joined: ",minig.netname,"\n");
			else
			{
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_JOIN_PREVENT_MINIGAME);
				sprint(self,"Cannot join given minigame session!\n");
			}
			return;
		}
		else if ( minig_cmd == "list" )
		{
			entity e;
			for ( e = minigame_descriptors; e != world; e = e.list_next )
				sprint(self,e.netname," (",e.message,") ","\n");
			return;
		}
		else if ( minig_cmd == "list-sessions" )
		{
			entity e;
			for ( e = minigame_sessions; e != world; e = e.list_next )
				sprint(self,e.netname,"\n");
			return;
		}
		else if ( minig_cmd == "end" || minig_cmd == "part" )
		{
			if ( self.active_minigame )
			{
				part_minigame(self);
				sprint(self,"Left minigame session\n");
			}
			else
				sprint(self,"You aren't playing any minigame...\n");
			return;
		}
		else if ( minig_cmd == "invite" && argc > 2 )
		{
			if ( self.active_minigame )
			{
				entity client = GetIndexedEntity(argc, 2);
				string error = invite_minigame(self,client);
				if ( error == "" )
				{
					sprint(self,"You have invited ",client.netname,
						" to join your game of ", self.active_minigame.descriptor.message, "\n");
				}
				else
					sprint(self,"Could not invite: ", error, ".\n");
			}
			else
				sprint(self,"You aren't playing any minigame...\n");
			return;
		}
		else if ( self.active_minigame )
		{
			entity e = minigame_find_player(self);
			string subcommand = substring(command,argv_end_index(0),-1);
			float arg_c = tokenize_console(subcommand);
			if ( self.active_minigame.minigame_event(self.active_minigame,"cmd",e,arg_c,subcommand) )
				return;
				
		}
		else sprint(self,strcat("Wrong command:^1 ",command,"\n"));
	}
	
	sprint(self, "\nUsage:^3 cmd minigame create <minigame>\n");
	sprint(self, "  Start a new minigame session\n");
	sprint(self, "Usage:^3 cmd minigame join <session>\n");
	sprint(self, "  Join an exising minigame session\n");
	sprint(self, "Usage:^3 cmd minigame list\n");
	sprint(self, "  List available minigames\n");
	sprint(self, "Usage:^3 cmd minigame list-sessions\n");
	sprint(self, "  List available minigames sessions\n");
	sprint(self, "Usage:^3 cmd minigame part|end\n");
	sprint(self, "  Leave the current minigame\n");
	sprint(self, "Usage:^3 cmd minigame invite <player>\n");
	sprint(self, "  Invite the given player to join you in a minigame\n");
}