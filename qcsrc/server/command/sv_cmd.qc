// =====================================================
//  Server side game commands code, reworked by Samual
//  Last updated: December 29th, 2011
// =====================================================

//  used by GameCommand_make_mapinfo()
void make_mapinfo_Think()
{
	if(MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 0, 0, 1))
	{
		print("Done rebuiling mapinfos.\n");
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
		remove(self);
	}
	else
	{
		self.think = make_mapinfo_Think;
		self.nextthink = time;
	}
}

float GameCommand_checkinlist(string game_command, string list)
{
	string l = strcat(" ", list, " ");

	if(strstrofs(l, strcat(" ", game_command, " "), 0) >= 0)
		return TRUE;

	return FALSE;
}

//  used by GameCommand_extendmatchtime() and GameCommand_reducematchtime()
void changematchtime(float delta, float mi, float ma)
{
	float cur;
	float new;
	float lim;

	if(delta == 0)
		return;
	if(autocvar_timelimit < 0)
		return;

	if(mi <= 10)
		mi = 10; // at least ten sec in the future
	cur = time - game_starttime;
	if(cur > 0)
		mi += cur; // from current time!

	lim = autocvar_timelimit * 60;

	if(delta > 0)
	{
		if(lim == 0)
			return; // cannot increase any further
		else if(lim < ma)
			new = min(ma, lim + delta);
		else // already above maximum: FAIL
			return;
	}
	else
	{
		if(lim == 0) // infinite: try reducing to max, if we are allowed to
			new = max(mi, ma);
		else if(lim > mi) // above minimum: decrease
			new = max(mi, lim + delta);
		else // already below minimum: FAIL
			return;
	}

	cvar_set("timelimit", ftos(new / 60));
}

void MorningRescue(entity e)
{
	if(e == world)
		return;

	float accepted;

	accepted = VerifyClientEntity(e, TRUE, FALSE);

	if(accepted > 0) 
	{
		msg_entity = e;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_MORNINGRESCUE);
	}
}


// =======================
//  Command Sub-Functions
// =======================

void GameCommand_adminmsg(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity client;
			float accepted;

			string targets = strreplace(",", " ", argv(1));
			string original_targets = strreplace(" ", ", ", targets);
			string admin_message = argv(2);
			float infobartime = stof(argv(3));

			string successful, t;
			successful = string_null;

			if((targets) && (admin_message))
			{
				for(;targets;)
				{
					t = car(targets); targets = cdr(targets);

					// Check to see if the player is a valid target
					client = GetFilteredEntity(t);
					accepted = VerifyClientEntity(client, TRUE, FALSE);

					if(accepted <= 0)
					{
						print("adminmsg: ", GetClientErrorString(accepted, t), (targets ? ", skipping to next player.\n" : ".\n"));
						continue;
					}

					// send the centerprint/console print or infomessage
					if(infobartime)
					{
						stuffcmd(client, sprintf("\ninfobar %f \"%s\"\n", infobartime, MakeConsoleSafe(admin_message)));
					}
					else
					{
						centerprint(client, strcat("^3", admin_name(), ":\n^7", admin_message));
						sprint(client, strcat("\{1}\{13}^3", admin_name(), "^7: ", admin_message, "\n"));
					}

					successful = strcat(successful, (successful ? ", " : ""), client.netname);
					dprint("Message sent to ", client.netname, "\n");
					continue;
				}

				if(successful)
					bprint("Successfully sent message '", admin_message, "' to ", successful, ".\n");
				else
					print("No players given (", original_targets, ") could receive the message.\n");

				return;
			}
		}

		default:
			print("Incorrect parameters for ^2adminmsg^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd adminmsg clients \"message\" [infobartime]\n");
			print("  'clients' is a list (separated by commas) of player entity ID's or nicknames\n");
			print("  If infobartime is provided, the message will be sent to infobar.\n");
			print("  Otherwise, it will just be sent as a centerprint message.\n");
			print("Examples: adminmsg 2,4 \"this infomessage will last for ten seconds\" 10\n");
			print("          adminmsg 2,5 \"this message will be a centerprint\"\n");
			return;
		}
	}
}

void GameCommand_mobbutcher(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(autocvar_g_campaign) { print("This command doesn't work in campaign mode.\n"); return; }
			if(g_invasion) { print("This command doesn't work during an invasion.\n"); return; }

			float removed_count = 0;
			entity head;

			FOR_EACH_MONSTER(head)
			{
				monster_remove(head);
				++removed_count;
			}

			FOR_EACH_PLAYER(head)
				head.monstercount = 0;

			monsters_total = 0; // reset stats?
			monsters_killed = 0;

			totalspawned = 0;

			if(removed_count <= 0)
				print("No monsters to kill\n");
			else
				printf("Killed %d monster%s\n", removed_count, ((removed_count == 1) ? "" : "s"));

			return; // never fall through to usage
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd mobbutcher\n");
			print("  No arguments required.\n");
			return;
		}
	}
}

void GameCommand_allready(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			ReadyRestart();
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd allready\n");
			print("  No arguments required.\n");
			return;
		}
	}
}

void GameCommand_allspec(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity client;
			string reason = argv(1);
			float i = 0;

			FOR_EACH_REALPLAYER(client)
			{
				self = client;
				PutObserverInServer();
				++i;
			}
			if(i) { bprint(strcat("Successfully forced all (", ftos(i), ") players to spectate", (reason ? strcat(" for reason: '", reason, "'") : ""), ".\n")); }
			else { print("No players found to spectate.\n"); }
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd allspec [reason]\n");
			print("  Where 'reason' is an optional argument for explanation of allspec command.\n");
			print("See also: ^2moveplayer, shuffleteams^7\n");
			return;
		}
	}
}

void GameCommand_anticheat(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity client = GetIndexedEntity(argc, 1);
			float accepted = VerifyClientEntity(client, FALSE, FALSE);

			if(accepted > 0)
			{
				self = client;
				anticheat_report();
				return;
			}
			else
			{
				print("anticheat: ", GetClientErrorString(accepted, argv(1)), ".\n");
			}
		}

		default:
			print("Incorrect parameters for ^2anticheat^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd anticheat client\n");
			print("  'client' is the entity number or name of the player.\n");
			return;
		}
	}
}

void GameCommand_bbox(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print("Original size: ", ftos(world.absmin_x), " ", ftos(world.absmin_y), " ", ftos(world.absmin_z));
			print(" ", ftos(world.absmax_x), " ", ftos(world.absmax_y), " ", ftos(world.absmax_z), "\n");
			print("Currently set size: ", ftos(world.mins_x), " ", ftos(world.mins_y), " ", ftos(world.mins_z));
			print(" ", ftos(world.maxs_x), " ", ftos(world.maxs_y), " ", ftos(world.maxs_z), "\n");
			print("Solid bounding box size:");

			tracebox('1 0 0' * world.absmin_x,
							'0 1 0' * world.absmin_y + '0 0 1' * world.absmin_z,
							'0 1 0' * world.absmax_y + '0 0 1' * world.absmax_z,
							'1 0 0' * world.absmax_x,
					MOVE_WORLDONLY,
					world);
			if(trace_startsolid)
				print(" ", ftos(world.absmin_x));
			else
				print(" ", ftos(trace_endpos_x));

			tracebox('0 1 0' * world.absmin_y,
							'1 0 0' * world.absmin_x + '0 0 1' * world.absmin_z,
							'1 0 0' * world.absmax_x + '0 0 1' * world.absmax_z,
							'0 1 0' * world.absmax_y,
					MOVE_WORLDONLY,
					world);
			if(trace_startsolid)
				print(" ", ftos(world.absmin_y));
			else
				print(" ", ftos(trace_endpos_y));

			tracebox('0 0 1' * world.absmin_z,
							'1 0 0' * world.absmin_x + '0 1 0' * world.absmin_y,
							'1 0 0' * world.absmax_x + '0 1 0' * world.absmax_y,
							'0 0 1' * world.absmax_z,
					MOVE_WORLDONLY,
					world);
			if(trace_startsolid)
				print(" ", ftos(world.absmin_z));
			else
				print(" ", ftos(trace_endpos_z));

			tracebox('1 0 0' * world.absmax_x,
							'0 1 0' * world.absmin_y + '0 0 1' * world.absmin_z,
							'0 1 0' * world.absmax_y + '0 0 1' * world.absmax_z,
							'1 0 0' * world.absmin_x,
					MOVE_WORLDONLY,
					world);
			if(trace_startsolid)
				print(" ", ftos(world.absmax_x));
			else
				print(" ", ftos(trace_endpos_x));

			tracebox('0 1 0' * world.absmax_y,
							'1 0 0' * world.absmin_x + '0 0 1' * world.absmin_z,
							'1 0 0' * world.absmax_x + '0 0 1' * world.absmax_z,
							'0 1 0' * world.absmin_y,
					MOVE_WORLDONLY,
					world);
			if(trace_startsolid)
				print(" ", ftos(world.absmax_y));
			else
				print(" ", ftos(trace_endpos_y));

			tracebox('0 0 1' * world.absmax_z,
							'1 0 0' * world.absmin_x + '0 1 0' * world.absmin_y,
							'1 0 0' * world.absmax_x + '0 1 0' * world.absmax_y,
							'0 0 1' * world.absmin_z,
					MOVE_WORLDONLY,
					world);
			if(trace_startsolid)
				print(" ", ftos(world.absmax_z));
			else
				print(" ", ftos(trace_endpos_z));

			print("\n");
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd bbox\n");
			print("  No arguments required.\n");
			print("See also: ^2gettaginfo, trace^7\n");
			return;
		}
	}
}

void GameCommand_bot_cmd(float request, float argc, string command)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity bot;

			if(argv(1) == "reset")
			{
				bot_resetqueues();
				return;
			}
			else if(argv(1) == "setbots")
			{
				cvar_settemp("bot_vs_human", "0");
				cvar_settemp("minplayers", "0");
				cvar_settemp("bot_number", "0");
				bot_fixcount();
				cvar_settemp("bot_number", argv(2));
				if(!bot_fixcount())
					print("Sorry, could not set requested bot count\n");
				return;
			}
			else if(argv(1) == "load" && argc == 3)
			{
				float fh, i;
				string s;
				fh = fopen(argv(2), FILE_READ);
				if(fh < 0)
				{
					print("cannot open the file\n");
					return;
				}

				i = 0;
				while((s = fgets(fh)))
				{
					argc = tokenize_console(s);

					if(argc >= 3 && argv(0) == "sv_cmd" && argv(1) == "bot_cmd")
					{
						if(argv(2) == "reset")
						{
							bot_resetqueues();
						}
						else if(argv(2) == "setbots")
						{
							cvar_settemp("bot_vs_human", "0");
							cvar_settemp("minplayers", "0");
							cvar_settemp("bot_number", "0");
							bot_fixcount();
							cvar_settemp("bot_number", argv(3));
							if(!bot_fixcount())
								print("Sorry, could not set requested bot count\n");
						}
						else
						{
							// let's start at token 2 so we can skip sv_cmd bot_cmd
							bot = find_bot_by_number(stof(argv(2)));
							if(bot == world)
								bot = find_bot_by_name(argv(2));
							if(bot)
								bot_queuecommand(bot, substring(s, argv_start_index(3), -1));
						}
					}
					else
						localcmd(strcat(s, "\n"));

					++i;
				}
				print(ftos(i), " commands read\n");
				fclose(fh);
				return;
			}
			else if(argv(1) == "help")
			{
				if(argv(2))
					bot_cmdhelp(argv(2));
				else
					bot_list_commands();
				return;
			}
			else if(argc >= 3) // this comes last
			{
				bot = find_bot_by_number(stof(argv(1)));
				if(bot == world)
					bot = find_bot_by_name(argv(1));
				if(bot)
				{
					print(strcat("Command '", substring(command, argv_start_index(2), -1), "' sent to bot ", bot.netname, "\n"));
					bot_queuecommand(bot, substring(command, argv_start_index(2), -1));
					return;
				}
				else
					print(strcat("Error: Can't find bot with the name or id '", argv(1),"' - Did you mistype the command?\n")); // don't return so that usage is shown
			}
		}

		default:
			print("Incorrect parameters for ^2bot_cmd^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd bot_cmd client command [argument]\n");
			print("  'client' can be either the name or entity id of the bot\n");
			print("  For full list of commands, see bot_cmd help [command].\n");
			print("Examples: sv_cmd bot_cmd client cc \"say something\"\n");
			print("          sv_cmd bot_cmd client presskey jump\n");
			return;
		}
	}
}

void GameCommand_cointoss(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			string result1 = (argv(2) ? strcat("^7", argv(1)) : "^1HEADS");
			string result2 = (argv(2) ? strcat("^7", argv(2)) : "^4TAILS");
			string choice = ((random() > 0.5) ? result1 : result2);

			Send_Notification(NOTIF_ALL, world, MSG_MULTI, MULTI_COINTOSS, choice);

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd cointoss [result1 result2]\n");
			print("  Where 'result1' and 'result2' are user created options.\n");
			return;
		}
	}
}

void GameCommand_database(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argc == 3)
			{
				if(argv(1) == "save")
				{
					db_save(ServerProgsDB, argv(2));
					print(strcat("Copied serverprogs database to '", argv(2), "' in the data directory.\n"));
					return;
				}
				else if(argv(1) == "dump")
				{
					db_dump(ServerProgsDB, argv(2));
					print("DB dumped.\n"); // wtf does this do?
					return;
				}
				else if(argv(1) == "load")
				{
					db_close(ServerProgsDB);
					ServerProgsDB = db_load(argv(2));
					print(strcat("Loaded '", argv(2), "' as new serverprogs database.\n"));
					return;
				}
			}
		}

		default:
			print("Incorrect parameters for ^2database^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd database action filename\n");
			print("  Where 'action' is the command to complete,\n");
			print("  and 'filename' is what it acts upon.\n");
			print("  Full list of commands here: \"save, dump, load.\"\n");
			return;
		}
	}
}

void GameCommand_defer_clear(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity client;
			float accepted;

			if(argc >= 2)
			{
				client = GetIndexedEntity(argc, 1);
				accepted = VerifyClientEntity(client, TRUE, FALSE);

				if(accepted > 0)
				{
					stuffcmd(client, "defer clear\n");
					print("defer clear stuffed to ", client.netname, "\n");
				}
				else { print("defer_clear: ", GetClientErrorString(accepted, argv(1)), ".\n"); }

				return;
			}
		}

		default:
			print("Incorrect parameters for ^2defer_clear^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd defer_clear client\n");
			print("  'client' is the entity number or name of the player.\n");
			print("See also: ^2defer_clear_all^7\n");
			return;
		}
	}
}

void GameCommand_defer_clear_all(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity client;
			float i = 0;
			float argc;

			FOR_EACH_CLIENT(client)
			{
				argc = tokenize_console(strcat("defer_clear ", ftos(num_for_edict(client))));
				GameCommand_defer_clear(CMD_REQUEST_COMMAND, argc);
				++i;
			}
			if(i) { print(strcat("Successfully stuffed defer clear to all clients (", ftos(i), ")\n")); } // should a message be added if no players were found?
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd defer_clear_all\n");
			print("  No arguments required.\n");
			print("See also: ^2defer_clear^7\n");
			return;
		}
	}
}

void GameCommand_delrec(float request, float argc)  // perhaps merge later with records and printstats and such?
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(1))
			{
				if(argv(2))
					race_deleteTime(argv(2), stof(argv(1)));
				else
					race_deleteTime(GetMapname(), stof(argv(1)));
				return;
			}
		}

		default:
			print("Incorrect parameters for ^2delrec^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd delrec ranking [map]\n");
			print("  'ranking' is which ranking level to clear up to, \n");
			print("  it will clear all records up to nth place.\n");
			print("  if 'map' is not provided it will use current map.\n");
			return;
		}
	}
}

void GameCommand_effectindexdump(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float fh, d;
			string s;

			d = db_create();
			print("begin of effects list\n");
			db_put(d, "TE_GUNSHOT", "1"); print("effect TE_GUNSHOT is ", ftos(particleeffectnum("TE_GUNSHOT")), "\n");
			db_put(d, "TE_GUNSHOTQUAD", "1"); print("effect TE_GUNSHOTQUAD is ", ftos(particleeffectnum("TE_GUNSHOTQUAD")), "\n");
			db_put(d, "TE_SPIKE", "1"); print("effect TE_SPIKE is ", ftos(particleeffectnum("TE_SPIKE")), "\n");
			db_put(d, "TE_SPIKEQUAD", "1"); print("effect TE_SPIKEQUAD is ", ftos(particleeffectnum("TE_SPIKEQUAD")), "\n");
			db_put(d, "TE_SUPERSPIKE", "1"); print("effect TE_SUPERSPIKE is ", ftos(particleeffectnum("TE_SUPERSPIKE")), "\n");
			db_put(d, "TE_SUPERSPIKEQUAD", "1"); print("effect TE_SUPERSPIKEQUAD is ", ftos(particleeffectnum("TE_SUPERSPIKEQUAD")), "\n");
			db_put(d, "TE_WIZSPIKE", "1"); print("effect TE_WIZSPIKE is ", ftos(particleeffectnum("TE_WIZSPIKE")), "\n");
			db_put(d, "TE_KNIGHTSPIKE", "1"); print("effect TE_KNIGHTSPIKE is ", ftos(particleeffectnum("TE_KNIGHTSPIKE")), "\n");
			db_put(d, "TE_EXPLOSION", "1"); print("effect TE_EXPLOSION is ", ftos(particleeffectnum("TE_EXPLOSION")), "\n");
			db_put(d, "TE_EXPLOSIONQUAD", "1"); print("effect TE_EXPLOSIONQUAD is ", ftos(particleeffectnum("TE_EXPLOSIONQUAD")), "\n");
			db_put(d, "TE_TAREXPLOSION", "1"); print("effect TE_TAREXPLOSION is ", ftos(particleeffectnum("TE_TAREXPLOSION")), "\n");
			db_put(d, "TE_TELEPORT", "1"); print("effect TE_TELEPORT is ", ftos(particleeffectnum("TE_TELEPORT")), "\n");
			db_put(d, "TE_LAVASPLASH", "1"); print("effect TE_LAVASPLASH is ", ftos(particleeffectnum("TE_LAVASPLASH")), "\n");
			db_put(d, "TE_SMALLFLASH", "1"); print("effect TE_SMALLFLASH is ", ftos(particleeffectnum("TE_SMALLFLASH")), "\n");
			db_put(d, "TE_FLAMEJET", "1"); print("effect TE_FLAMEJET is ", ftos(particleeffectnum("TE_FLAMEJET")), "\n");
			db_put(d, "EF_FLAME", "1"); print("effect EF_FLAME is ", ftos(particleeffectnum("EF_FLAME")), "\n");
			db_put(d, "TE_BLOOD", "1"); print("effect TE_BLOOD is ", ftos(particleeffectnum("TE_BLOOD")), "\n");
			db_put(d, "TE_SPARK", "1"); print("effect TE_SPARK is ", ftos(particleeffectnum("TE_SPARK")), "\n");
			db_put(d, "TE_PLASMABURN", "1"); print("effect TE_PLASMABURN is ", ftos(particleeffectnum("TE_PLASMABURN")), "\n");
			db_put(d, "TE_TEI_G3NEUTRAL", "1"); print("effect TE_TEI_G3NEUTRAL is ", ftos(particleeffectnum("TE_TEI_G3NEUTRAL")), "\n");
			db_put(d, "TE_TEI_SMOKE", "1"); print("effect TE_TEI_SMOKE is ", ftos(particleeffectnum("TE_TEI_SMOKE")), "\n");
			db_put(d, "TE_TEI_BIGEXPLOSION", "1"); print("effect TE_TEI_BIGEXPLOSION is ", ftos(particleeffectnum("TE_TEI_BIGEXPLOSION")), "\n");
			db_put(d, "TE_TEI_PLASMAHIT", "1"); print("effect TE_TEI_PLASMAHIT is ", ftos(particleeffectnum("TE_TEI_PLASMAHIT")), "\n");
			db_put(d, "EF_STARDUST", "1"); print("effect EF_STARDUST is ", ftos(particleeffectnum("EF_STARDUST")), "\n");
			db_put(d, "TR_ROCKET", "1"); print("effect TR_ROCKET is ", ftos(particleeffectnum("TR_ROCKET")), "\n");
			db_put(d, "TR_GRENADE", "1"); print("effect TR_GRENADE is ", ftos(particleeffectnum("TR_GRENADE")), "\n");
			db_put(d, "TR_BLOOD", "1"); print("effect TR_BLOOD is ", ftos(particleeffectnum("TR_BLOOD")), "\n");
			db_put(d, "TR_WIZSPIKE", "1"); print("effect TR_WIZSPIKE is ", ftos(particleeffectnum("TR_WIZSPIKE")), "\n");
			db_put(d, "TR_SLIGHTBLOOD", "1"); print("effect TR_SLIGHTBLOOD is ", ftos(particleeffectnum("TR_SLIGHTBLOOD")), "\n");
			db_put(d, "TR_KNIGHTSPIKE", "1"); print("effect TR_KNIGHTSPIKE is ", ftos(particleeffectnum("TR_KNIGHTSPIKE")), "\n");
			db_put(d, "TR_VORESPIKE", "1"); print("effect TR_VORESPIKE is ", ftos(particleeffectnum("TR_VORESPIKE")), "\n");
			db_put(d, "TR_NEHAHRASMOKE", "1"); print("effect TR_NEHAHRASMOKE is ", ftos(particleeffectnum("TR_NEHAHRASMOKE")), "\n");
			db_put(d, "TR_NEXUIZPLASMA", "1"); print("effect TR_NEXUIZPLASMA is ", ftos(particleeffectnum("TR_NEXUIZPLASMA")), "\n");
			db_put(d, "TR_GLOWTRAIL", "1"); print("effect TR_GLOWTRAIL is ", ftos(particleeffectnum("TR_GLOWTRAIL")), "\n");
			db_put(d, "TR_SEEKER", "1"); print("effect TR_SEEKER is ", ftos(particleeffectnum("TR_SEEKER")), "\n");
			db_put(d, "SVC_PARTICLE", "1"); print("effect SVC_PARTICLE is ", ftos(particleeffectnum("SVC_PARTICLE")), "\n");

			fh = fopen("effectinfo.txt", FILE_READ);
			while((s = fgets(fh)))
			{
				tokenize_console(s);
				if(argv(0) == "effect")
				{
					if(db_get(d, argv(1)) != "1")
					{
						if(particleeffectnum(argv(1)) >= 0)
							print("effect ", argv(1), " is ", ftos(particleeffectnum(argv(1))), "\n");
						db_put(d, argv(1), "1");
					}
				}
			}
			print("end of effects list\n");

			db_close(d);
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd effectindexdump\n");
			print("  No arguments required.\n");
			return;
		}
	}
}

void GameCommand_extendmatchtime(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			changematchtime(autocvar_timelimit_increment * 60, autocvar_timelimit_min * 60, autocvar_timelimit_max * 60);
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd extendmatchtime\n");
			print("  No arguments required.\n");
			print("See also: ^2reducematchtime^7\n");
			return;
		}
	}
}

void GameCommand_find(float request, float argc)  // is this even needed? We have prvm_edicts command and such ANYWAY
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity client;

			for(client = world; (client = find(client, classname, argv(1))); )
				print(etos(client), "\n");

			return;
		}

		default:
			print("Incorrect parameters for ^2find^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd find classname\n");
			print("  Where 'classname' is the classname to search for.\n");
			return;
		}
	}
}

void GameCommand_gametype(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(1) != "")
			{
				string s = argv(1);
				float t = MapInfo_Type_FromString(s), tsave = MapInfo_CurrentGametype();

				if(t)
				{
					MapInfo_SwitchGameType(t);
					MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
					if(MapInfo_count > 0)
					{
						// update lsmaps in case the gametype changed, this way people can easily list maps for it
						if(lsmaps_reply != "") { strunzone(lsmaps_reply); }
						lsmaps_reply = strzone(getlsmaps());
						bprint("Game type successfully switched to ", s, "\n");
					}
					else
					{
						bprint("Cannot use this game type: no map for it found\n");
						MapInfo_SwitchGameType(tsave);
						MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
					}
				}
				else
					bprint("Game type switch to ", s, " failed: this type does not exist!\n");

				return;
			}
		}

		default:
			print("Incorrect parameters for ^2gametype^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd gametype mode\n");
			print("  Where 'mode' is the gametype mode to switch to.\n");
			print("See also: ^2gotomap^7\n");
			return;
		}
	}
}

void GameCommand_gettaginfo(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity tmp_entity;
			float i;
			vector v;

			if(argc >= 4)
			{
				tmp_entity = spawn();
				if(argv(1) == "w")
					setmodel(tmp_entity, (nextent(world)).weaponentity.model);
				else
				{
					precache_model(argv(1));
					setmodel(tmp_entity, argv(1));
				}
				tmp_entity.frame = stof(argv(2));
				if(substring(argv(3), 0, 1) == "#")
					i = stof(substring(argv(3), 1, -1));
				else
					i = gettagindex(tmp_entity, argv(3));
				if(i)
				{
					v = gettaginfo(tmp_entity, i);
					print("model ", tmp_entity.model, " frame ", ftos(tmp_entity.frame), " tag ", gettaginfo_name);
					print(" index ", ftos(i), " parent ", ftos(gettaginfo_parent), "\n");
					print(" vector = ", ftos(v_x), " ", ftos(v_y), " ", ftos(v_z), "\n");
					print(" offset = ", ftos(gettaginfo_offset_x), " ", ftos(gettaginfo_offset_y), " ", ftos(gettaginfo_offset_z), "\n");
					print(" forward = ", ftos(gettaginfo_forward_x), " ", ftos(gettaginfo_forward_y), " ", ftos(gettaginfo_forward_z), "\n");
					print(" right = ", ftos(gettaginfo_right_x), " ", ftos(gettaginfo_right_y), " ", ftos(gettaginfo_right_z), "\n");
					print(" up = ", ftos(gettaginfo_up_x), " ", ftos(gettaginfo_up_y), " ", ftos(gettaginfo_up_z), "\n");
					if(argc >= 6)
					{
						v_y = -v_y;
						localcmd(strcat(argv(4), vtos(v), argv(5), "\n"));
					}
				}
				else
					print("bone not found\n");

				remove(tmp_entity);
				return;
			}
		}

		default:
			print("Incorrect parameters for ^2gettaginfo^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd gettaginfo model frame index [command one] [command two]\n");
			print("See also: ^2bbox, trace^7\n");
			return;
		}
	}
}

void GameCommand_animbench(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity tmp_entity;

			if(argc >= 4)
			{
				tmp_entity = spawn();
				if(argv(1) == "w")
					setmodel(tmp_entity, (nextent(world)).weaponentity.model);
				else
				{
					precache_model(argv(1));
					setmodel(tmp_entity, argv(1));
				}
				float f1 = stof(argv(2));
				float f2 = stof(argv(3));
				float t0;
				float t1 = 0;
				float t2 = 0;
				float n = 0;

				while(t1 + t2 < 1)
				{
					tmp_entity.frame = f1;
					t0 = gettime(GETTIME_HIRES);
					getsurfacepoint(tmp_entity, 0, 0);
					t1 += gettime(GETTIME_HIRES) - t0;
					tmp_entity.frame = f2;
					t0 = gettime(GETTIME_HIRES);
					getsurfacepoint(tmp_entity, 0, 0);
					t2 += gettime(GETTIME_HIRES) - t0;
					n += 1;
				}
				print("model ", tmp_entity.model, " frame ", ftos(f1), " animtime ", ftos(n / t1), "/s\n");
				print("model ", tmp_entity.model, " frame ", ftos(f2), " animtime ", ftos(n / t2), "/s\n");

				remove(tmp_entity);
				return;
			}
		}

		default:
			print("Incorrect parameters for ^2gettaginfo^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd gettaginfo model frame index [command one] [command two]\n");
			print("See also: ^2bbox, trace^7\n");
			return;
		}
	}
}

void GameCommand_gotomap(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(1))
			{
				print(GotoMap(argv(1)), "\n");
				return;
			}
		}

		default:
			print("Incorrect parameters for ^2gotomap^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd gotomap map\n");
			print("  Where 'map' is the *.bsp file to change to.\n");
			print("See also: ^2gametype^7\n");
			return;
		}
	}
}

void GameCommand_gravity(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			string rm = (autocvar_g_rm ? "rm_" : "");
			string grav = argv(1);
			string gravity_list = cvar_string(strcat(rm, "gravity_list"));
			if(grav == "random")
			{
				cvar_set("g_random_gravity", "1");
				localcmd("defer 2 restart");
				return;
			}
			else if(grav == "help")
			{
				localcmd("say ^3Usage: ^2vcall gravity [value]\n");
				return;
			}
			else if(grav == "list")
			{
				localcmd(strcat("say ^3Available gravity votes: ^2", gravity_list));
				return;
			}
			if(!cvar(strcat(rm, "gravity_", grav)) || !GameCommand_checkinlist(grav, gravity_list))
			{
				localcmd("say ^1That gravity does not exist, vote for ^2gravity list ^1to see available gravity votes\n");
				return;
			}
			cvar_set("sv_gravity", ftos(cvar(strcat(rm, "gravity_", grav))));
			localcmd(sprintf("say ^3Gravity is now: %d", autocvar_sv_gravity, "\n"));
			return;
		}
			
		default:
			print("Incorrect parameters for ^2gravity^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd gravity [command]\n");
			return;
		}
	}
}

void GameCommand_ircmsg(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			IRCSay(argv(1), argv(2));
			return;
		}
			
		default:
			print("Incorrect parameters for ^2ircmsg^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd ircmsg [message]\n");
			return;
		}
	}
}

void GameCommand_lockteams(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(teamplay)
			{
				lockteams = 1;
				bprint("^1The teams are now locked.\n");
			}
			else
			{
				bprint("lockteams command can only be used in a team-based gamemode.\n");
			}
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd lockteams\n");
			print("  No arguments required.\n");
			print("See also: ^2unlockteams^7\n");
			return;
		}
	}
}

void GameCommand_make_mapinfo(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity tmp_entity;

			tmp_entity = spawn();
			tmp_entity.classname = "make_mapinfo";
			tmp_entity.think = make_mapinfo_Think;
			tmp_entity.nextthink = time;
			MapInfo_Enumerate();
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd make_mapinfo\n");
			print("  No arguments required.\n");
			print("See also: ^2radarmap^7\n");
			return;
		}
	}
}

void GameCommand_moveplayer(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float accepted;
			entity client;

			string targets = strreplace(",", " ", argv(1));
			string original_targets = strreplace(" ", ", ", targets);
			string destination = argv(2);

			string successful, t;
			successful = string_null;

			// lets see if the target(s) even actually exist.
			if((targets) && (destination))
			{
				for(;targets;)
				{
					t = car(targets); targets = cdr(targets);

					// Check to see if the player is a valid target
					client = GetFilteredEntity(t);
					accepted = VerifyClientEntity(client, FALSE, FALSE);

					if(accepted <= 0)
					{
						print("moveplayer: ", GetClientErrorString(accepted, t), (targets ? ", skipping to next player.\n" : ".\n"));
						continue;
					}

					// Where are we putting this player?
					if(destination == "spec" || destination == "spectator")
					{
						if(!IS_SPEC(client) && !IS_OBSERVER(client))
						{
							self = client;
							PutObserverInServer();

							successful = strcat(successful, (successful ? ", " : ""), client.netname);
						}
						else
						{
							print("Player ", ftos(GetFilteredNumber(t)), " (", client.netname, ") is already spectating.\n");
						}
						continue;
					}
					else
					{
						if(!IS_SPEC(client) && !IS_OBSERVER(client))
						{
							if(teamplay)
							{
								// set up
								float team_id;
								float save = client.team_forced;
								client.team_forced = 0;

								// find the team to move the player to
								team_id = Team_ColorToTeam(destination);
								if(team_id == client.team) // already on the destination team
								{
									// keep the forcing undone
									print("Player ", ftos(GetFilteredNumber(t)), " (", client.netname, ") is already on the ", Team_ColoredFullName(client.team), (targets ? "^7, skipping to next player.\n" : "^7.\n"));
									continue;
								}
								else if(team_id == 0)  // auto team
								{
									team_id = Team_NumberToTeam(FindSmallestTeam(client, FALSE));
								}
								else
								{
									CheckAllowedTeams(client);
								}
								client.team_forced = save;

								// Check to see if the destination team is even available
								switch(team_id)
								{
									case NUM_TEAM_1: if(c1 == -1) { print("Sorry, can't move player to red team if it doesn't exist.\n"); return; } break;
									case NUM_TEAM_2: if(c2 == -1) { print("Sorry, can't move player to blue team if it doesn't exist.\n"); return; } break;
									case NUM_TEAM_3: if(c3 == -1) { print("Sorry, can't move player to yellow team if it doesn't exist.\n"); return; } break;
									case NUM_TEAM_4: if(c4 == -1) { print("Sorry, can't move player to pink team if it doesn't exist.\n"); return; } break;

									default: print("Sorry, can't move player here if team ", destination, " doesn't exist.\n"); return;
								}

								// If so, lets continue and finally move the player
								client.team_forced = 0;
								MoveToTeam(client, team_id, 6);
								successful = strcat(successful, (successful ? ", " : ""), client.netname);
								print("Player ", ftos(GetFilteredNumber(t)), " (", client.netname, ") has been moved to the ", Team_ColoredFullName(team_id), "^7.\n");
								continue;
							}
							else
							{
								print("Can't change teams when currently not playing a team game.\n");
								return;
							}
						}
						else
						{
							print("Can't change teams if the player isn't in the game.\n"); // well technically we could, but should we allow that? :P
							return;
						}
					}
				}

				if(successful)
					bprint("Successfully moved players ", successful, " to destination ", destination, ".\n");
				else
					print("No players given (", original_targets, ") are able to move.\n");

				return; // still correct parameters so return to avoid usage print
			}
		}

		default:
			print("Incorrect parameters for ^2moveplayer^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd moveplayer clients destination\n");
			print("  'clients' is a list (separated by commas) of player entity ID's or nicknames\n");
			print("  'destination' is what to send the player to, be it team or spectating\n");
			print("  Full list of destinations here: \"spec, spectator, red, blue, yellow, pink, auto.\"\n");
			print("Examples: sv_cmd moveplayer 1,3,5 red 3\n");
			print("          sv_cmd moveplayer 2 spec \n");
			print("See also: ^2allspec, shuffleteams^7\n");
			return;
		}
	}
}

void GameCommand_nospectators(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			blockSpectators = 1;
			entity plr;
			FOR_EACH_CLIENT(plr) //give every spectator <g_maxplayers_spectator_blocktime> seconds time to become a player
			{
				if(IS_SPEC(plr) || IS_OBSERVER(plr))
				{
					plr.spectatortime = time;
					Send_Notification(NOTIF_ONE_ONLY, plr, MSG_INFO, INFO_SPECTATE_WARNING, autocvar_g_maxplayers_spectator_blocktime);
				}
			}
			bprint(strcat("^7All spectators will be automatically kicked when not joining the game after ", ftos(autocvar_g_maxplayers_spectator_blocktime), " seconds!\n"));
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd nospectators\n");
			print("  No arguments required.\n");
			return;
		}
	}
}

void GameCommand_playerdemo(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(2) && argv(3))
			{
				entity client;
				float i, n, accepted;

				switch(argv(1))
				{
					case "read":
					{
						client = GetIndexedEntity(argc, 2);
						accepted = VerifyClientEntity(client, FALSE, TRUE);

						if(accepted <= 0)
						{
							print("playerdemo: read: ", GetClientErrorString(accepted, argv(2)), ".\n");
							return;
						}

						self = client;
						playerdemo_open_read(argv(next_token));
						return;
					}

					case "write":
					{
						client = GetIndexedEntity(argc, 2);
						accepted = VerifyClientEntity(client, FALSE, FALSE);

						if(accepted <= 0)
						{
							print("playerdemo: write: ", GetClientErrorString(accepted, argv(2)), ".\n");
							return;
						}

						self = client;
						playerdemo_open_write(argv(next_token));
						return;
					}

					case "auto_read_and_write":
					{
						n = GetFilteredNumber(argv(3));
						cvar_set("bot_number", ftos(n));

						localcmd("wait; wait; wait\n");
						for(i = 0; i < n; ++i) { localcmd("sv_cmd playerdemo read ", ftos(i+2), " ", argv(2), ftos(i+1), "\n"); }

						localcmd("sv_cmd playerdemo write 1 ", ftos(n+1), "\n");
						return;
					}

					case "auto_read":
					{
						n = GetFilteredNumber(argv(3));
						cvar_set("bot_number", ftos(n));

						localcmd("wait; wait; wait\n");
						for(i = 0; i < n; ++i) { localcmd("sv_cmd playerdemo read ", ftos(i+2), " ", argv(2), ftos(i+1), "\n"); }
						return;
					}
				}
			}
		}

		default:
			print("Incorrect parameters for ^2playerdemo^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd playerdemo command (entitynumber filename | entitynumber botnumber)\n");
			print("  Full list of commands here: \"read, write, auto_read_and_write, auto_read.\"\n");
			return;
		}
	}
}

void GameCommand_printstats(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			DumpStats(FALSE);
			print("stats dumped.\n");
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd printstats\n");
			print("  No arguments required.\n");
			return;
		}
	}
}

void GameCommand_radarmap(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(RadarMap_Make(argc))
				return;
		}

		default:
			print("Incorrect parameters for ^2radarmap^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd radarmap [--force] [--loop] [--quit] [--block | --trace | --sample | --lineblock] [--sharpen N] [--res W H] [--qual Q]\n");
			print("  The quality factor Q is roughly proportional to the time taken.\n");
			print("  trace supports no quality factor; its result should look like --block with infinite quality factor.\n");
			print("See also: ^2make_mapinfo^7\n");
			return;
		}
	}
}

void GameCommand_reducematchtime(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			changematchtime(autocvar_timelimit_decrement *-60, autocvar_timelimit_min * 60, autocvar_timelimit_max * 60);
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd reducematchtime\n");
			print("  No arguments required.\n");
			print("See also: ^2extendmatchtime^7\n");
			return;
		}
	}
}

void GameCommand_setbots(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argc >= 2)
			{
				cvar_settemp("minplayers", "0");
				cvar_settemp("bot_number", argv(1));
				bot_fixcount();
				return;
			}
		}

		default:
			print("Incorrect parameters for ^2setbots^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd setbots botnumber\n");
			print("  Where 'botnumber' is the amount of bots to set bot_number cvar to.\n");
			print("See also: ^2bot_cmd^7\n");
			return;
		}
	}
}

void GameCommand_shuffleteams(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(teamplay)
			{
				entity tmp_player;
				float i, x, z, t_teams, t_players, team_color;

				// count the total amount of players and total amount of teams
				t_players = 0;
				t_teams = 0;
				FOR_EACH_PLAYER(tmp_player)
				{
					CheckAllowedTeams(tmp_player);

					if(c1 >= 0) t_teams = max(1, t_teams);
					if(c2 >= 0) t_teams = max(2, t_teams);
					if(c3 >= 0) t_teams = max(3, t_teams);
					if(c4 >= 0) t_teams = max(4, t_teams);

					++t_players;
				}

				// build a list of the players in a random order
				FOR_EACH_PLAYER(tmp_player)
				{
					for(;;)
					{
						i = bound(1, floor(random() * maxclients) + 1, maxclients);

						if(shuffleteams_players[i])
						{
							continue; // a player is already assigned to this slot
						}
						else
						{
							shuffleteams_players[i] = num_for_edict(tmp_player);
							break;
						}
					}
				}

				// finally, from the list made earlier, re-join the players in different order.
				for(i = 1; i <= t_teams; ++i)
				{
					// find out how many players to assign to this team
					x = (t_players / t_teams);
					x = ((i == 1) ? ceil(x) : floor(x));

					team_color = Team_NumberToTeam(i);

					// sort through the random list of players made earlier
					for(z = 1; z <= maxclients; ++z)
					{
						if (!(shuffleteams_teams[i] >= x))
						{
							if (!(shuffleteams_players[z]))
								continue; // not a player, move on to next random slot

							if(VerifyClientNumber(shuffleteams_players[z]))
								self = edict_num(shuffleteams_players[z]);

							if(self.team != team_color)
								MoveToTeam(self, team_color, 6);

							shuffleteams_players[z] = 0;
							shuffleteams_teams[i] = shuffleteams_teams[i] + 1;
						}
						else
						{
							break; // move on to next team
						}
					}
				}

				bprint("Successfully shuffled the players around randomly.\n");

				// clear the buffers now
				for (i=0; i<SHUFFLETEAMS_MAX_PLAYERS; ++i)
					shuffleteams_players[i] = 0;

				for (i=0; i<SHUFFLETEAMS_MAX_TEAMS; ++i)
					shuffleteams_teams[i] = 0;
			}
			else
			{
				print("Can't shuffle teams when currently not playing a team game.\n");
			}

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd shuffleteams\n");
			print("  No arguments required.\n");
			print("See also: ^2moveplayer, allspec^7\n");
			return;
		}
	}
}

void GameCommand_stuffto(float request, float argc)
{
	// This... is a fairly dangerous and powerful command... - It allows any arguments to be sent to a client via rcon.
	// Because of this, it is disabled by default and must be enabled by the server owner when doing compilation. That way,
	// we can be certain they understand the risks of it... So to enable, compile server with -DSTUFFTO_ENABLED argument.

	#ifdef STUFFTO_ENABLED
	#message "stuffto command enabled"
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(2))
			{
				float accepted;
				if(argv(1) == "all")
				{
					entity head;
					
					FOR_EACH_REALCLIENT(head)
					{
						accepted = VerifyClientEntity(head, TRUE, FALSE);
						if(accepted > 0)
						{
							stuffcmd(head, strcat("\n", argv(2), "\n"));
							print(strcat("Command: \"", argv(2), "\" sent to ", GetCallerName(head), ".\n"));
							continue;
						}
						else
						{
							print("stuffto failed on ", GetCallerName(head), ".\n");
							continue;
						}
					}
					return;
				}

				entity client = GetIndexedEntity(argc, 1);
				accepted = VerifyClientEntity(client, TRUE, FALSE);

				if(accepted > 0)
				{
					stuffcmd(client, strcat("\n", argv(next_token), "\n"));
					print(strcat("Command: \"", argv(next_token), "\" sent to ", GetCallerName(client), " (", argv(1) ,").\n"));
				}
				else
					print("stuffto: ", GetClientErrorString(accepted, argv(1)), ".\n");

				return;
			}
		}

		default:
			print("Incorrect parameters for ^2stuffto^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd stuffto client \"command\"\n");
			print("  'client' is the entity number or name of the player,\n");
			print("  and 'command' is the command to be sent to that player.\n");
			return;
		}
	}
	#else
	if(request)
	{
		print("stuffto command is not enabled on this server.\n");
		return;
	}
	#endif
}

void GameCommand_supermentalrescue(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity head;

			FOR_EACH_REALPLAYER(head)
				MorningRescue(head);

			FOR_EACH_PLAYER(head)
				Unfreeze(head);

			return; // never fall through to usage
		}
		
		default:
			print("Incorrect parameters for ^2supermentalrescue^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd supermentalrescue\n");
			return;
		}
	}
}

void GameCommand_trace(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity e;
			vector org, delta, start, end, p, q, q0, pos, vv, dv;
			float i, f, safe, unsafe, dq, dqf;

			switch(argv(1))
			{
				case "debug":
				{
					print("TEST CASE. If this returns the runaway loop counter error, possibly everything is oaky.\n");
					for(;;)
					{
						org = world.mins;
						delta = world.maxs - world.mins;

						start_x = org_x + random() * delta_x;
						start_y = org_y + random() * delta_y;
						start_z = org_z + random() * delta_z;

						end_x = org_x + random() * delta_x;
						end_y = org_y + random() * delta_y;
						end_z = org_z + random() * delta_z;

						start = stov(vtos(start));
						end = stov(vtos(end));

						tracebox(start, PL_MIN, PL_MAX, end, MOVE_NOMONSTERS, world);
						if(!trace_startsolid)
						{
							p = trace_endpos;
							tracebox(p, PL_MIN, PL_MAX, p, MOVE_NOMONSTERS, world);
							if(trace_startsolid || trace_fraction == 1)
							{
								rint(42); // do an engine breakpoint on VM_rint so you can get the trace that errnoeously returns startsolid
								tracebox(start, PL_MIN, PL_MAX, end, MOVE_NOMONSTERS, world);

								if(trace_startsolid)
								{
									// how much do we need to back off?
									safe = 1;
									unsafe = 0;
									for(;;)
									{
										pos = p * (1 - (safe + unsafe) * 0.5) + start * ((safe + unsafe) * 0.5);
										tracebox(pos, PL_MIN, PL_MAX, pos, MOVE_NOMONSTERS, world);
										if(trace_startsolid)
										{
											if((safe + unsafe) * 0.5 == unsafe)
												break;
											unsafe = (safe + unsafe) * 0.5;
										}
										else
										{
											if((safe + unsafe) * 0.5 == safe)
												break;
											safe = (safe + unsafe) * 0.5;
										}
									}

									print("safe distance to back off: ", ftos(safe * vlen(p - start)), "qu\n");
									print("unsafe distance to back off: ", ftos(unsafe * vlen(p - start)), "qu\n");

									tracebox(p, PL_MIN + '0.1 0.1 0.1', PL_MAX - '0.1 0.1 0.1', p, MOVE_NOMONSTERS, world);
									if(trace_startsolid)
										print("trace_endpos much in solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(p), "\n");
									else
										print("trace_endpos just in solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(p), "\n");
									break;
								}

								q0 = p;
								dq = 0;
								dqf = 1;
								for(;;)
								{
									q = p + normalize(end - p) * (dq + dqf);
									if(q == q0)
										break;
									tracebox(p, PL_MIN, PL_MAX, q, MOVE_NOMONSTERS, world);
									if(trace_startsolid)
										error("THIS ONE cannot happen");
									if(trace_fraction > 0)
										dq += dqf * trace_fraction;
									dqf *= 0.5;
									q0 = q;
								}
								if(dq > 0)
								{
									print("trace_endpos still before solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(p), "\n");
									print("could go ", ftos(dq), " units further to ", vtos(q), "\n");
									break;
								}
							}
						}
					}
					return;
				}

				case "debug2":
				{
					e = nextent(world);
					tracebox(e.origin + '0 0 32', e.mins, e.maxs, e.origin + '0 0 -1024', MOVE_NORMAL, e);
					vv = trace_endpos;
					if(trace_fraction == 1)
					{
						print("not above ground, aborting\n");
						return;
					}
					f = 0;
					for(i = 0; i < 100000; ++i)
					{
						dv = randomvec();
						if(dv_z > 0)
							dv = -1 * dv;
						tracebox(vv, e.mins, e.maxs, vv + dv, MOVE_NORMAL, e);
						if(trace_startsolid)
							print("bug 1\n");
						if(trace_fraction == 1)
						if(dv_z < f)
						{
							print("bug 2: ", ftos(dv_x), " ", ftos(dv_y), " ", ftos(dv_z));
							print(" (", ftos(asin(dv_z / vlen(dv)) * 180 / M_PI), " degrees)\n");
							f = dv_z;
						}
					}
					print("highest possible dist: ", ftos(f), "\n");
					return;
				}

				case "walk":
				{
					if(argc == 4)
					{
						e = nextent(world);
						if(tracewalk(e, stov(argv(2)), e.mins, e.maxs, stov(argv(3)), MOVE_NORMAL))
							print("can walk\n");
						else
							print("cannot walk\n");
						return;
					}
				}

				case "showline":
				{
					if(argc == 4)
					{
						vv = stov(argv(2));
						dv = stov(argv(3));
						traceline(vv, dv, MOVE_NORMAL, world);
						trailparticles(world, particleeffectnum("TR_NEXUIZPLASMA"), vv, trace_endpos);
						trailparticles(world, particleeffectnum("TR_CRYLINKPLASMA"), trace_endpos, dv);
						return;
					}
				}

				// no default case, just go straight to invalid
			}
		}

		default:
			print("Incorrect parameters for ^2trace^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd trace command (startpos endpos)\n");
			print("  Full list of commands here: \"debug, debug2, walk, showline.\"\n");
			print("See also: ^2bbox, gettaginfo^7\n");
			return;
		}
	}
}

void GameCommand_unlockteams(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(teamplay)
			{
				lockteams = 0;
				bprint("^1The teams are now unlocked.\n");
			}
			else
			{
				bprint("unlockteams command can only be used in a team-based gamemode.\n");
			}
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd unlockteams\n");
			print("  No arguments required.\n");
			print("See also: ^2lockteams^7\n");
			return;
		}
	}
}

void GameCommand_warp(float request, float argc)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(autocvar_g_campaign)
			{
				if(argc >= 2)
				{
					CampaignLevelWarp(stof(argv(1)));
					print("Successfully warped to campaign level ", stof(argv(1)), ".\n");
				}
				else
				{
					CampaignLevelWarp(-1);
					print("Successfully warped to next campaign level.\n");
				}
			}
			else
				print("Not in campaign, can't level warp\n");
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd warp [level]\n");
			print("  'level' is the level to change campaign mode to.\n");
			print("  if 'level' is not provided it will change to the next level.\n");
			return;
		}
	}
}

/* use this when creating a new command, making sure to place it in alphabetical order... also,
** ADD ALL NEW COMMANDS TO commands.cfg WITH PROPER ALIASES IN THE SAME FASHION!
void GameCommand_(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 sv_cmd \n");
			print("  No arguments required.\n");
			return;
		}
	}
}
*/


// ==================================
//  Macro system for server commands
// ==================================

// Do not hard code aliases for these, instead create them in commands.cfg... also: keep in alphabetical order, please ;)
#define SERVER_COMMANDS(request,arguments,command) \
	SERVER_COMMAND("adminmsg", GameCommand_adminmsg(request, arguments), "Send an admin message to a client directly") \
	SERVER_COMMAND("mobbutcher", GameCommand_mobbutcher(request), "Instantly removes all monsters on the map") \
	SERVER_COMMAND("allready", GameCommand_allready(request), "Restart the server and reset the players") \
	SERVER_COMMAND("allspec", GameCommand_allspec(request, arguments), "Force all players to spectate") \
	SERVER_COMMAND("anticheat", GameCommand_anticheat(request, arguments), "Create an anticheat report for a client") \
	SERVER_COMMAND("animbench", GameCommand_animbench(request, arguments), "Benchmark model animation (LAGS)") \
	SERVER_COMMAND("bbox", GameCommand_bbox(request), "Print detailed information about world size") \
	SERVER_COMMAND("bot_cmd", GameCommand_bot_cmd(request, arguments, command), "Control and send commands to bots") \
	SERVER_COMMAND("cointoss", GameCommand_cointoss(request, arguments), "Flip a virtual coin and give random result") \
	SERVER_COMMAND("database", GameCommand_database(request, arguments), "Extra controls of the serverprogs database") \
	SERVER_COMMAND("defer_clear", GameCommand_defer_clear(request, arguments), "Clear all queued defer commands for a specific client") \
	SERVER_COMMAND("defer_clear_all", GameCommand_defer_clear_all(request), "Clear all queued defer commands for all clients") \
	SERVER_COMMAND("delrec", GameCommand_delrec(request, arguments), "Delete race time record for a map") \
	SERVER_COMMAND("effectindexdump", GameCommand_effectindexdump(request), "Dump list of effects from code and effectinfo.txt") \
	SERVER_COMMAND("extendmatchtime", GameCommand_extendmatchtime(request), "Increase the timelimit value incrementally") \
	SERVER_COMMAND("find", GameCommand_find(request, arguments), "Search through entities for matching classname") \
	SERVER_COMMAND("gametype", GameCommand_gametype(request, arguments), "Simple command to change the active gametype") \
	SERVER_COMMAND("gettaginfo", GameCommand_gettaginfo(request, arguments), "Get specific information about a weapon model") \
	SERVER_COMMAND("gotomap", GameCommand_gotomap(request, arguments), "Simple command to switch to another map") \
	SERVER_COMMAND("gravity", GameCommand_gravity(request, arguments), "Changes gravity based on cvars") \
	SERVER_COMMAND("ircmsg", GameCommand_ircmsg(request, arguments), "Say a message as an IRC user") \
	SERVER_COMMAND("lockteams", GameCommand_lockteams(request), "Disable the ability for players to switch or enter teams") \
	SERVER_COMMAND("make_mapinfo", GameCommand_make_mapinfo(request), "Automatically rebuild mapinfo files") \
	SERVER_COMMAND("moveplayer", GameCommand_moveplayer(request, arguments), "Change the team/status of a player") \
	SERVER_COMMAND("nospectators", GameCommand_nospectators(request), "Automatically remove spectators from a match") \
	SERVER_COMMAND("playerdemo", GameCommand_playerdemo(request, arguments), "Control the ability to save demos of players") \
	SERVER_COMMAND("printstats", GameCommand_printstats(request), "Dump eventlog player stats and other score information") \
	SERVER_COMMAND("radarmap", GameCommand_radarmap(request, arguments), "Generate a radar image of the map") \
	SERVER_COMMAND("reducematchtime", GameCommand_reducematchtime(request), "Decrease the timelimit value incrementally") \
	SERVER_COMMAND("setbots", GameCommand_setbots(request, arguments), "Adjust how many bots are in the match") \
	SERVER_COMMAND("shuffleteams", GameCommand_shuffleteams(request), "Randomly move players to different teams") \
	SERVER_COMMAND("stuffto", GameCommand_stuffto(request, arguments), "Send a command to be executed on a client") \
	SERVER_COMMAND("supermentalrescue", GameCommand_supermentalrescue(request), "Moaning lescue") \
	SERVER_COMMAND("trace", GameCommand_trace(request, arguments), "Various debugging tools with tracing") \
	SERVER_COMMAND("unlockteams", GameCommand_unlockteams(request), "Enable the ability for players to switch or enter teams") \
	SERVER_COMMAND("warp", GameCommand_warp(request, arguments), "Choose different level in campaign") \
	/* nothing */

void GameCommand_macro_help()
{
	#define SERVER_COMMAND(name,function,description) \
		{ print("  ^2", name, "^7: ", description, "\n"); }

	SERVER_COMMANDS(0, 0, "")
	#undef SERVER_COMMAND

	return;
}

float GameCommand_macro_command(float argc, string command)
{
	#define SERVER_COMMAND(name,function,description) \
		{ if(name == strtolower(argv(0))) { function; return TRUE; } }

	SERVER_COMMANDS(CMD_REQUEST_COMMAND, argc, command)
	#undef SERVER_COMMAND

	return FALSE;
}

float GameCommand_macro_usage(float argc)
{
	#define SERVER_COMMAND(name,function,description) \
		{ if(name == strtolower(argv(1))) { function; return TRUE; } }

	SERVER_COMMANDS(CMD_REQUEST_USAGE, argc, "")
	#undef SERVER_COMMAND

	return FALSE;
}

void GameCommand_macro_write_aliases(float fh)
{
	#define SERVER_COMMAND(name,function,description) \
		{ CMD_Write_Alias("qc_cmd_sv", name, description); }

	SERVER_COMMANDS(0, 0, "")
	#undef SERVER_COMMAND

	return;
}


// =========================================
//  Main Function Called By Engine (sv_cmd)
// =========================================
// If this function exists, game code handles gamecommand instead of the engine code.

void GameCommand(string command)
{
	float argc = tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	if(strtolower(argv(0)) == "help")
	{
		if(argc == 1)
		{
			print("\nServer console commands:\n");
			GameCommand_macro_help();

			print("\nBanning commands:\n");
			BanCommand_macro_help();

			print("\nCommon networked commands:\n");
			CommonCommand_macro_help(world);

			print("\nGeneric commands shared by all programs:\n");
			GenericCommand_macro_help();

			print("\nUsage:^3 sv_cmd COMMAND...^7, where possible commands are listed above.\n");
			print("For help about a specific command, type sv_cmd help COMMAND\n");

			return;
		}
		else if(BanCommand_macro_usage(argc)) // Instead of trying to call a command, we're going to see detailed information about it
		{
			return;
		}
		else if(CommonCommand_macro_usage(argc, world)) // same here, but for common commands instead
		{
			return;
		}
		else if(GenericCommand_macro_usage(argc)) // same here, but for generic commands instead
		{
			return;
		}
		else if(GameCommand_macro_usage(argc)) // finally try for normal commands too
		{
			return;
		}
	}
	else if(BanCommand(command))
	{
		return; // handled by server/command/ipban.qc
	}
	else if(CommonCommand_macro_command(argc, world, command))
	{
		return; // handled by server/command/common.qc
	}
	else if(GenericCommand(command))
	{
		return; // handled by common/command/generic.qc
	}
	else if(GameCommand_macro_command(argc, command)) // continue as usual and scan for normal commands
	{
		return; // handled by one of the above GameCommand_* functions
	}

	// nothing above caught the command, must be invalid
	print(((command != "") ? strcat("Unknown server command \"", command, "\"") : "No command provided"), ". For a list of supported commands, try sv_cmd help.\n");

	return;
}
