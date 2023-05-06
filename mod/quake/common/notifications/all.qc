#include "all.qh"

#ifdef CSQC
#include "../../client/centerprint.qh"
#endif
#ifdef SVQC
#include "../../server/getreplies.qh"
#endif

// ================================================
//  Unified notification system, written by Samual
//  Last updated: August, 2013
// ================================================

#ifdef SVQC
string Notification_CheckArgs(
	NOTIF broadcast, entity client)
{
	// check supplied broadcast and target for errors
	switch (broadcast)
	{
		case NOTIF_ONE:
		case NOTIF_ONE_ONLY:
		{
			if (IS_NOT_A_CLIENT(client)) {
				return "No client provided!";
			}
			break;
		}

		case NOTIF_ALL_EXCEPT:
		{
			if (IS_NOT_A_CLIENT(client)) {
				return "Exception can't be a non-client!";
			}
			break;
		}

		case NOTIF_ALL:
		{
			if (client) {
				return "Entity provided when NULL was required!";
			}
			break;
		}

		default:
		{
			return sprintf("Improper broadcast: %d!", broadcast);
		}
	}
	return "";
}

bool Notification_ShouldSend(NOTIF broadcast, entity to_client, entity other_client)
{
	if(!IS_REAL_CLIENT(to_client))
		return false;

	switch (broadcast)
	{
		case NOTIF_ONE:
			return (
				(to_client == other_client)
			);
		case NOTIF_ONE_ONLY:
			return (to_client == other_client);
		case NOTIF_ALL:
			return true;
		case NOTIF_ALL_EXCEPT:
			return (
				(to_client != other_client)
			);
		default:
			return false;
	}
}

#endif

// ===============================
//  Initialization Core Functions
// ===============================

// used by restartnotifs command to initialize notifications
void Destroy_Notification_Entity(entity notif)
{
	if (notif.nent_name != "") strunzone(notif.nent_name);
	if (notif.nent_args != "") strunzone(notif.nent_args);
	if (notif.nent_hudargs != "") strunzone(notif.nent_hudargs);
	if (notif.nent_icon != "") strunzone(notif.nent_icon);
	if (notif.nent_durcnt != "") strunzone(notif.nent_durcnt);
	if (notif.nent_string != "") strunzone(notif.nent_string);
	delete(notif);
}

void Destroy_All_Notifications()
{
	// kill all networked notifications and centerprints
	#ifdef SVQC
	Kill_Notification(NOTIF_ALL, NULL, MSG_Null, CPID_Null);
	#else
	centerprint_KillAll();
	#endif

	// kill all real notification entities
	FOREACH(Notifications, true, { Destroy_Notification_Entity(it); });
}

string Process_Notif_Line(
	MSG typeId,
	bool chat,
	string input,
	string notiftype,
	string notifname,
	string stringtype)
{
	#ifdef CSQC
	if(typeId == MSG_INFO)
	{
		if((chat && autocvar_notification_allow_chatboxprint)
			|| (autocvar_notification_allow_chatboxprint == 2))
		{
			// pass 1: add ETX char at beginning of line
			input = strcat("\{3}", input);

			// pass 2: add ETX char at end of each new line (so that
			// messages with multiple lines are put through chatbox too)
			input = strreplace("\n", "\n\{3}", input);

			// pass 3: strip trailing ETX char
			if(substring(input, (strlen(input) - 1), 1) == "\{3}")
				{ input = substring(input, 0, (strlen(input) - 1)); }
		}
	}
	#endif

	// done to both MSG_INFO and MSG_CENTER
	if(substring(input, (strlen(input) - 1), 1) == "\n")
	{
		LOG_INFOF(
			(
				"^1TRAILING NEW LINE AT END OF NOTIFICATION: "
				"^7net_type = %s, net_name = %s, string = %s."
			),
			notiftype,
			notifname,
			stringtype
		);
		notif_error = true;
		input = substring(input, 1, (strlen(input) - 1));
	}

	return input;
}

string Process_Notif_Args(
	float arg_type,
	string args,
	string notiftype,
	string notifname)
{
	string selected, remaining = args;
	float sel_num = 0;

	for (;(remaining != "");)
	{
		selected = car(remaining); remaining = cdr(remaining);

		switch(arg_type)
		{
			case 1: // normal args
			{
				if(sel_num == NOTIF_MAX_ARGS)
				{
					LOG_INFOF(
						(
							"^1NOTIFICATION HAS TOO MANY ARGUMENTS: "
							"^7net_type = %s, net_name = %s, max args = %d."
						),
						notiftype,
						notifname,
						NOTIF_MAX_ARGS
					);
					notif_error = true;
					break;
				}

				switch(strtolower(selected))
				{
					#define ARG_CASE_ARG_CS_SV_HA(selected,result) case selected: ++sel_num; break;
					#define ARG_CASE_ARG_CS_SV_DC(selected,result) case selected: ++sel_num; break;
					#define ARG_CASE_ARG_CS_SV(selected,result)    case selected: ++sel_num; break;
					#define ARG_CASE_ARG_CS(selected,result)       case selected: ++sel_num; break;
					#define ARG_CASE_ARG_SV(selected,result)       case selected: ++sel_num; break;
					#define ARG_CASE_ARG_DC(selected,result)
					#define ARG_CASE(prog,selected,result)         ARG_CASE_##prog(selected,result)
					NOTIF_ARGUMENT_LIST
					#undef ARG_CASE
					#undef ARG_CASE_ARG_DC
					#undef ARG_CASE_ARG_SV
					#undef ARG_CASE_ARG_CS
					#undef ARG_CASE_ARG_CS_SV
					#undef ARG_CASE_ARG_CS_SV_DC
					#undef ARG_CASE_ARG_CS_SV_HA
					default:
					{
						LOG_INFOF(
							(
								"^1NOTIFICATION WITH UNKNOWN TOKEN IN ARGUMENT STRING: "
								"^7net_type = %s, net_name = %s, args arg = '%s'."
							),
							notiftype,
							notifname,
							selected
						);
						notif_error = true;
						break;
					}
				}
				break;
			}
			case 2: // hudargs
			{
				if(sel_num == NOTIF_MAX_HUDARGS)
				{
					LOG_INFOF(
						(
							"^1NOTIFICATION HAS TOO MANY ARGUMENTS: "
							"^7net_type = %s, net_name = %s, max hudargs = %d."
						),
						notiftype,
						notifname,
						NOTIF_MAX_HUDARGS
					);
					notif_error = true;
					break;
				}

				switch(strtolower(selected))
				{
					#define ARG_CASE_ARG_CS_SV_HA(selected,result) case selected: ++sel_num; break;
					#define ARG_CASE_ARG_CS_SV_DC(selected,result)
					#define ARG_CASE_ARG_CS_SV(selected,result)
					#define ARG_CASE_ARG_CS(selected,result)
					#define ARG_CASE_ARG_SV(selected,result)
					#define ARG_CASE_ARG_DC(selected,result)
					#define ARG_CASE(prog,selected,result)         ARG_CASE_##prog(selected,result)
					NOTIF_ARGUMENT_LIST
					#undef ARG_CASE
					#undef ARG_CASE_ARG_DC
					#undef ARG_CASE_ARG_SV
					#undef ARG_CASE_ARG_CS
					#undef ARG_CASE_ARG_CS_SV
					#undef ARG_CASE_ARG_CS_SV_DC
					#undef ARG_CASE_ARG_CS_SV_HA
					default:
					{
						LOG_INFOF(
							(
								"^1NOTIFICATION WITH UNKNOWN TOKEN IN ARGUMENT STRING: "
								"^7net_type = %s, net_name = %s, hudargs arg = '%s'."
							),
							notiftype,
							notifname,
							selected
						);
						notif_error = true;
						break;
					}
				}
				break;
			}
			case 3: // durcnt
			{
				if(sel_num == NOTIF_MAX_DURCNT)
				{
					LOG_INFOF(
						(
							"^1NOTIFICATION HAS TOO MANY ARGUMENTS: "
							"^7net_type = %s, net_name = %s, max durcnt = %d."
						),
						notiftype,
						notifname,
						NOTIF_MAX_DURCNT
					);
					notif_error = true;
					break;
				}

				switch(strtolower(selected))
				{
					#define ARG_CASE_ARG_CS_SV_HA(selected,result)
					#define ARG_CASE_ARG_CS_SV_DC(selected,result) case selected: ++sel_num; break;
					#define ARG_CASE_ARG_CS_SV(selected,result)
					#define ARG_CASE_ARG_CS(selected,result)
					#define ARG_CASE_ARG_SV(selected,result)
					#define ARG_CASE_ARG_DC(selected,result)       case selected: ++sel_num; break;
					#define ARG_CASE(prog,selected,result)         ARG_CASE_##prog(selected,result)
					NOTIF_ARGUMENT_LIST
					#undef ARG_CASE
					#undef ARG_CASE_ARG_DC
					#undef ARG_CASE_ARG_SV
					#undef ARG_CASE_ARG_CS
					#undef ARG_CASE_ARG_CS_SV
					#undef ARG_CASE_ARG_CS_SV_DC
					#undef ARG_CASE_ARG_CS_SV_HA
					default:
					{
						if(ftos(stof(selected)) != "") { ++sel_num; }
						else
						{
							LOG_INFOF(
								(
									"^1NOTIFICATION WITH UNKNOWN TOKEN IN ARGUMENT STRING: "
									"^7net_type = %s, net_name = %s, durcnt arg = '%s'."
								),
								notiftype,
								notifname,
								selected
							);
							notif_error = true;
						}
						break;
					}
				}
				break;
			}
		}
	}
	return args;
}

void Create_Notification_Entity(entity notif,
	float var_default,
	float var_cvar,
	MSG typeId,
	string namestring,
	int teamnum)
{
	// =====================
	//  Global Entity Setup
	// =====================
	notif.nent_default = var_default;
	notif.nent_enabled = (var_cvar >= 1);
	notif.nent_type = typeId;
	notif.nent_name = strzone(namestring);

	// Other pre-notif-setup requisites
	notif_error = false;

	switch (typeId)
	{
		case MSG_INFO:
		case MSG_CENTER:
		case MSG_MULTI:
		case MSG_CHOICE:
			break;
		default:
			LOG_INFOF(
				(
					"^1NOTIFICATION WITH IMPROPER TYPE: "
					"^7net_type = %d, net_name = %s."
				),
				typeId,
				namestring
			);
			notif_error = true;
			break;
	}

	// now check to see if any errors happened
	if (notif_error)
	{
		notif.nent_enabled = false; // disable the notification so it can't cause trouble
		notif_global_error = true; // throw the red flag that an error happened on init
	}
}

void Create_Notification_Entity_InfoCenter(entity notif,
											float var_cvar,
											string namestring,
											int strnum,
											int flnum,
											/* MSG_INFO & MSG_CENTER */
											string args,
											string hudargs,
											string icon,
											CPID cpid,
											string durcnt,
											string normal,
											string gentle)
		{
			MSG typeId = notif.nent_type;
			// Set MSG_INFO and MSG_CENTER string/float counts
			notif.nent_stringcount = strnum;
			notif.nent_floatcount = flnum;

			// Only initialize arguments if we're either a client or on a dedicated server
			#ifdef SVQC
			float should_process_args = server_is_dedicated;
			#else
			float should_process_args = true;
			#endif
			string typestring = Get_Notif_TypeName(typeId);
			if(should_process_args)
			{
				// ========================
				//  Process Main Arguments
				// ========================
				if(strnum + flnum)
				{
					if(args != "")
					{
						notif.nent_args = strzone(
							Process_Notif_Args(1, args, typestring, namestring));
					}
					else if((hudargs == "") && (durcnt ==""))
					{
						LOG_INFOF(
							(
								"^1NOTIFICATION HAS ARG COUNTS BUT NO ARGS OR HUDARGS OR DURCNT: "
								"^7net_type = %s, net_name = %s, strnum = %d, flnum = %d"
							),
							typestring,
							namestring,
							strnum,
							flnum
						);
						notif_error = true;
					}
				}
				else if(args != "")
				{
					notif.nent_args = strzone(
						Process_Notif_Args(1, args, typestring, namestring));
				}


				// =======================================
				//  Process HUD and Centerprint Arguments
				//    Only processed on CSQC, as these
				//    args are only for HUD features.
				// =======================================
				#ifdef CSQC
				if(hudargs != "")
				{
					notif.nent_hudargs = strzone(
						Process_Notif_Args(2, hudargs, typestring, namestring));

					if(icon != "") { notif.nent_icon = strzone(icon); }
					else
					{
						LOG_INFOF(
							(
								"^1NOTIFICATION HAS HUDARGS BUT NO ICON: "
								"^7net_type = %s, net_name = %s."
							),
							typestring,
							namestring
						);
						notif_error = true;
					}
				}
				else if(icon != "")
				{
					LOG_WARNF(
						(
							"^1NOTIFICATION HAS ICON BUT NO HUDARGS: "
							"^7net_type = %s, net_name = %s.\n"
						),
						typestring,
						namestring
					);
					notif_error = true;
				}

				if (durcnt != "")
				{
					notif.nent_durcnt = strzone(Process_Notif_Args(3, durcnt, typestring, namestring));

					if (cpid == CPID_Null && durcnt != "0 0")
					{
						LOG_WARNF(
							(
								"Notification has durcnt but no cpid: "
								"net_type = %s, net_name = %s."
							),
							typestring,
							namestring
						);
						notif_error = true;
					}
				}
				notif.nent_cpid = cpid;
				#endif


				// ======================
				//  Process Notif String
				// ======================
				#define SET_NOTIF_STRING(string,stringname) MACRO_BEGIN \
					notif.nent_string = strzone(CCR( \
						Process_Notif_Line( \
							typeId, \
							(var_cvar > 1), \
							string, \
							typestring, \
							namestring, \
							stringname \
						)) \
					); \
				MACRO_END

				if(GENTLE)
				{
					if(gentle != "") { SET_NOTIF_STRING(gentle, "GENTLE"); }
					else if(normal != "") { SET_NOTIF_STRING(normal, "NORMAL"); }
				}
				else if(normal != "") { SET_NOTIF_STRING(normal, "NORMAL"); }
				#undef SET_NOTIF_STRING

				// Check to make sure a string was chosen
				if(notif.nent_string == "")
				{
					LOG_INFOF(
						(
							"^1EMPTY NOTIFICATION: "
							"^7net_type = %s, net_name = %s."
						),
						typestring,
						namestring
					);
					notif_error = true;
				}
			}
		}

void Create_Notification_Entity_Multi(entity notif,
										float var_cvar,
										string namestring,
										/* MSG_MULTI */
										Notification anncename,
										Notification infoname,
										Notification centername)
		{
			MSG typeId = MSG_MULTI;
			// Set MSG_MULTI string/float counts
			if (!anncename && !infoname && !centername)
			{
				string typestring = Get_Notif_TypeName(typeId);
				LOG_INFOF(
					(
						"^1NOTIFICATION WITH NO SUBCALLS: "
						"^7net_type = %s, net_name = %s."
					),
					typestring,
					namestring
				);
				notif_error = true;
			}
			else
			{
				float infoname_stringcount = 0, infoname_floatcount = 0;
				float centername_stringcount = 0, centername_floatcount = 0;

				if (infoname)
				{
					notif.nent_msginfo = infoname;
					infoname_stringcount = notif.nent_msginfo.nent_stringcount;
					infoname_floatcount = notif.nent_msginfo.nent_floatcount;
				}

				if (centername)
				{
					notif.nent_msgcenter = centername;
					centername_stringcount = notif.nent_msgcenter.nent_stringcount;
					centername_floatcount = notif.nent_msgcenter.nent_floatcount;
				}

				// set the requirements of THIS notification to the totals of its subcalls
				notif.nent_stringcount = max(infoname_stringcount, centername_stringcount);
				notif.nent_floatcount = max(infoname_floatcount, centername_floatcount);
			}
		}

void Create_Notification_Entity_Choice(entity notif,
										float var_cvar,
										string namestring,
										/* MSG_CHOICE */
										float challow_def,
										float challow_var,
										MSG chtype,
										Notification optiona,
										Notification optionb)
		{
			MSG typeId = MSG_CHOICE;
			if (chtype == MSG_Null || !optiona || !optionb)
			{
				string typestring = Get_Notif_TypeName(typeId);
				LOG_INFOF(
					(
						"^1NOTIFICATION IS MISSING CHOICE PARAMS: "
						"^7net_type = %s, net_name = %s."
					),
					typestring,
					namestring
				);
				notif_error = true;
			}
			else
			{
				notif.nent_optiona = optiona;
				notif.nent_optionb = optionb;
				notif.nent_challow_def = challow_def; // 0: never allowed, 1: allowed in warmup, 2: always allowed
				notif.nent_challow_var = challow_var; // 0: never allowed, 1: allowed in warmup, 2: always allowed
				notif.nent_stringcount = max(notif.nent_optiona.nent_stringcount, notif.nent_optionb.nent_stringcount);
				notif.nent_floatcount = max(notif.nent_optiona.nent_floatcount, notif.nent_optionb.nent_floatcount);

				/*#ifdef NOTIFICATIONS_DEBUG
				Debug_Notification(sprintf(
					"Create_Notification_Entity(...): MSG_CHOICE: %s\n%s\n%s\n",
					notif.nent_name,
					sprintf(
						"^ optiona: %s %s : %d %d",
						Get_Notif_TypeName(notif.nent_optiona.nent_type),
						notif.nent_optiona.nent_name,
						notif.nent_optiona.nent_stringcount,
						notif.nent_optiona.nent_floatcount
					),
					sprintf(
						"^ optionb: %s %s : %d %d",
						Get_Notif_TypeName(notif.nent_optionb.nent_type),
						notif.nent_optionb.nent_name,
						notif.nent_optionb.nent_stringcount,
						notif.nent_optionb.nent_floatcount
					)
				));
				#endif*/
			}
		}


// ===============
//  Cvar Handling
// ===============

// used by MSG_CHOICE to build list of choices
#ifdef SVQC
void Notification_GetCvars(entity this, entity store, string s, int f)
{
	FOREACH(Notifications, it.nent_type == MSG_CHOICE, {
		GetCvars_handleFloat(
			this,
			store,
			s,
			f,
			msg_choice_choices[it.nent_choice_idx],
			sprintf("notification_%s", Get_Notif_CvarName(it))
		);
	});
}
#endif


// ===============================
//  Frontend Notification Pushing
// ===============================

string Local_Notification_sprintf(
	string input, string args,
	string s1, string s2, string s3, string s4,
	int f1, float f2, float f3, float f4)
{
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Local_Notification_sprintf('%s^7', '%s', %s, %s);\n",
		MakeConsoleSafe(input),
		args,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif

	for (int sel_num = 0; sel_num < NOTIF_MAX_ARGS; ++sel_num) { arg_slot[sel_num] = ""; }

	for (int sel_num = 0; (args != ""); )
	{
		string selected = car(args); args = cdr(args);
		NOTIF_HIT_MAX(NOTIF_MAX_ARGS, "Local_Notification_sprintf");
		string tmp_s; // used by NOTIF_ARGUMENT_LIST
		switch (strtolower(selected))
		{
			#define ARG_CASE_ARG_CS_SV_HA(selected, result) case selected: arg_slot[sel_num++] = result; break;
			#define ARG_CASE_ARG_CS_SV_DC(selected, result) case selected: arg_slot[sel_num++] = result; break;
			#define ARG_CASE_ARG_CS_SV(selected, result)    case selected: arg_slot[sel_num++] = result; break;
#ifdef CSQC
			#define ARG_CASE_ARG_CS(selected, result)       case selected: arg_slot[sel_num++] = result; break;
			#define ARG_CASE_ARG_SV(selected, result)
#else
			#define ARG_CASE_ARG_CS(selected, result)
			#define ARG_CASE_ARG_SV(selected, result)       case selected: arg_slot[sel_num++] = result; break;
#endif
			#define ARG_CASE_ARG_DC(selected, result)
			#define ARG_CASE(prog, selected, result)        ARG_CASE_##prog(selected, result)
			NOTIF_ARGUMENT_LIST
			#undef ARG_CASE
			#undef ARG_CASE_ARG_DC
			#undef ARG_CASE_ARG_SV
			#undef ARG_CASE_ARG_CS
			#undef ARG_CASE_ARG_CS_SV
			#undef ARG_CASE_ARG_CS_SV_DC
			#undef ARG_CASE_ARG_CS_SV_HA
			default: NOTIF_HIT_UNKNOWN(NOTIF_MAX_ARGS, "Local_Notification_sprintf")
		}
	}
	return sprintf(
		strcat(input, "\n"),
		arg_slot[0],
		arg_slot[1],
		arg_slot[2],
		arg_slot[3],
		arg_slot[4],
		arg_slot[5],
		arg_slot[6]
	);
}

#ifdef CSQC
void Local_Notification_centerprint_Add(
	string input, string durcnt,
	CPID cpid, float f1, float f2)
{
	arg_slot[0] = ""; arg_slot[1] = "";

	for (int sel_num = 0; (durcnt != ""); )
	{
		string selected = car(durcnt); durcnt = cdr(durcnt);
		NOTIF_HIT_MAX(NOTIF_MAX_DURCNT, "Local_Notification_centerprint_Add");
		switch (strtolower(selected))
		{
			#define ARG_CASE_ARG_CS_SV_HA(selected, result)
			#define ARG_CASE_ARG_CS_SV_DC(selected, result) case selected: arg_slot[sel_num++] = result; break;
			#define ARG_CASE_ARG_CS_SV(selected, result)
			#define ARG_CASE_ARG_CS(selected, result)
			#define ARG_CASE_ARG_SV(selected, result)
			#define ARG_CASE_ARG_DC(selected, result)       case selected: arg_slot[sel_num++] = result; break;
			#define ARG_CASE(prog, selected, result)        ARG_CASE_##prog(selected,result)
			NOTIF_ARGUMENT_LIST
			#undef ARG_CASE
			#undef ARG_CASE_ARG_DC
			#undef ARG_CASE_ARG_SV
			#undef ARG_CASE_ARG_CS
			#undef ARG_CASE_ARG_CS_SV
			#undef ARG_CASE_ARG_CS_SV_DC
			#undef ARG_CASE_ARG_CS_SV_HA
			default:
			{
				if (/* wtf */ ftos(stof(selected)) != "") { arg_slot[sel_num++] = selected; }
				else { NOTIF_HIT_UNKNOWN(NOTIF_MAX_DURCNT, "Local_Notification_centerprint_Add") }
				break;
			}
		}
	}
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Local_Notification_centerprint_Add('%s^7', '%s', %d, %d, %d, %d);\n",
		MakeConsoleSafe(input),
		durcnt,
		f1, f2,
		stof(arg_slot[0]),
		stof(arg_slot[1])
	));
	#endif
	centerprint_Add(ORDINAL(cpid), input, stof(arg_slot[0]), stof(arg_slot[1]));
}

#endif

void Local_Notification(MSG net_type, Notification net_name, ...count)
{
	// retreive entity of this notification
	entity notif = net_name;
	if (!notif)
	{
		#ifdef NOTIFICATIONS_DEBUG
		Debug_Notification(sprintf(
			"Local_Notification(%s, NULL, ...);\n",
			Get_Notif_TypeName(net_type)
		));
		#endif
		LOG_WARNF("Incorrect usage of Local_Notification: %s", "Null notification");
		return;
	}

	// check if the notification is enabled
	if (!notif.nent_enabled)
	{
		#ifdef NOTIFICATIONS_DEBUG
		Debug_Notification(sprintf(
			"Local_Notification(%s, %s, ...): Entity was disabled...\n",
			Get_Notif_TypeName(net_type),
			notif.nent_name
		));
		#endif
		return;
	}

	string s1 = CCR((notif.nent_stringcount > 0) ? ...(0, string) : "");
	string s2 = CCR((notif.nent_stringcount > 1) ? ...(1, string) : "");
	string s3 = CCR((notif.nent_stringcount > 2) ? ...(2, string) : "");
	string s4 = CCR((notif.nent_stringcount > 3) ? ...(3, string) : "");
	float f1 =  ((notif.nent_floatcount  > 0) ? ...((notif.nent_stringcount + 0), float) : 0);
	float f2 =  ((notif.nent_floatcount  > 1) ? ...((notif.nent_stringcount + 1), float) : 0);
	float f3 =  ((notif.nent_floatcount  > 2) ? ...((notif.nent_stringcount + 2), float) : 0);
	float f4 =  ((notif.nent_floatcount  > 3) ? ...((notif.nent_stringcount + 3), float) : 0);

	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Local_Notification(%s, %s, %s, %s);\n",
		Get_Notif_TypeName(net_type),
		notif.nent_name,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif

	if ((notif.nent_stringcount + notif.nent_floatcount) != count)
	{
		backtrace(sprintf(
			(
				"Arguments mismatch for Local_Notification(%s, %s, ...)! "
				"stringcount(%d) + floatcount(%d) != count(%d)\n"
				"Check the definition and function call for accuracy...?\n"
			),
			Get_Notif_TypeName(net_type),
			notif.nent_name,
			notif.nent_stringcount,
			notif.nent_floatcount,
			count
		));
		return;
	}

	switch (net_type)
	{
		case MSG_INFO:
		{
			print(
				Local_Notification_sprintf(
					notif.nent_string,
					notif.nent_args,
					s1, s2, s3, s4,
					f1, f2, f3, f4)
			);
			break;
		}

		#ifdef CSQC
		case MSG_CENTER:
		{
			Local_Notification_centerprint_Add(
				Local_Notification_sprintf(
					notif.nent_string,
					notif.nent_args,
					s1, s2, s3, s4,
					f1, f2, f3, f4),
				notif.nent_durcnt,
				notif.nent_cpid,
				f1, f2);
			break;
		}
		#endif

		case MSG_MULTI:
		{
			if (notif.nent_msginfo && notif.nent_msginfo.nent_enabled)
			{
				Local_Notification_WOVA(
					MSG_INFO,
					notif.nent_msginfo,
					notif.nent_msginfo.nent_stringcount,
					notif.nent_msginfo.nent_floatcount,
					s1, s2, s3, s4,
					f1, f2, f3, f4);
			}
			#ifdef CSQC
			if (notif.nent_msgcenter && notif.nent_msgcenter.nent_enabled)
			{
				Local_Notification_WOVA(
					MSG_CENTER,
					notif.nent_msgcenter,
					notif.nent_msgcenter.nent_stringcount,
					notif.nent_msgcenter.nent_floatcount,
					s1, s2, s3, s4,
					f1, f2, f3, f4);
			}
			#endif
			break;
		}

		case MSG_CHOICE:
		{
			entity found_choice = notif.nent_optiona;
			if (notif.nent_challow_var) {
				switch (cvar(sprintf("notification_%s", Get_Notif_CvarName(notif))))
				{
					case 1: break;
					case 2: found_choice = notif.nent_optionb; break;
					default: return; // not enabled anyway
				}
			}

			Local_Notification_WOVA(
				found_choice.nent_type,
				found_choice,
				found_choice.nent_stringcount,
				found_choice.nent_floatcount,
				s1, s2, s3, s4,
				f1, f2, f3, f4);
			break;
		}
	}
}

// WOVA = Without Variable Arguments
void Local_Notification_WOVA(
	MSG net_type, Notification net_name,
	float stringcount, float floatcount,
	string s1, string s2, string s3, string s4,
	float f1, float f2, float f3, float f4)
{
	#define VARITEM(stringc, floatc, args) \
		if ((stringcount == stringc) && (floatcount == floatc)) \
		{ Local_Notification(net_type, net_name, args); return; }
	EIGHT_VARS_TO_VARARGS_VARLIST
	#undef VARITEM
	Local_Notification(net_type, net_name); // some notifications don't have any arguments at all
}


// =========================
//  Notification Networking
// =========================

/** networked as a linked entity to give newly connecting clients some notification context */
REGISTER_NET_LINKED(ENT_CLIENT_NOTIFICATION)

#ifdef CSQC
NET_HANDLE(ENT_CLIENT_NOTIFICATION, bool is_new)
{
	make_pure(this);
	MSG net_type = ENUMCAST(MSG, ReadByte());
	int net_name = ReadShort();
    return = true;

	if (net_type == MSG_CENTER_KILL)
    {
        if (!is_new) return;
        // killing
        #ifdef NOTIFICATIONS_DEBUG
        Debug_Notification(sprintf(
            "Read_Notification(%d) at %f: net_type = %s, cpid = %d\n",
            is_new,
            time,
            Get_Notif_TypeName(net_type),
            net_name
        ));
        #endif
        int _net_name = net_name;
        CPID net_name = ENUMCAST(CPID, _net_name);
        if (net_name == CPID_Null) {
            centerprint_KillAll();
        } else {
            centerprint_Kill(ORDINAL(net_name));// kill group
        }
        return;
    }

	Notification notif = Get_Notif_Ent(net_type, net_name);

	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Read_Notification(%d) at %f: net_type = %s, net_name = %s (%d)\n",
		is_new,
		time,
		Get_Notif_TypeName(net_type),
		notif.registered_id,
		net_name
	));
	#endif

    if (!notif) {
        backtrace("Read_Notification: Could not find notification entity!\n");
        return false;
    }

    string s1 = ((notif.nent_stringcount > 0) ? ReadString() : "");
    string s2 = ((notif.nent_stringcount > 1) ? ReadString() : "");
    string s3 = ((notif.nent_stringcount > 2) ? ReadString() : "");
    string s4 = ((notif.nent_stringcount > 3) ? ReadString() : "");
    float f1 = ((notif.nent_floatcount > 0) ? ReadLong() : 0);
    float f2 = ((notif.nent_floatcount > 1) ? ReadLong() : 0);
    float f3 = ((notif.nent_floatcount > 2) ? ReadLong() : 0);
    float f4 = ((notif.nent_floatcount > 3) ? ReadLong() : 0);

    if (!is_new) return;
    Local_Notification_WOVA(
        net_type, notif,
        notif.nent_stringcount,
        notif.nent_floatcount,
        s1, s2, s3, s4,
        f1, f2, f3, f4);
}
#endif

#ifdef SVQC
void Net_Notification_Remove(entity this)
{
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Net_Notification_Remove() at %f: %s '%s - %s' notification\n",
		time,
		((this.nent_net_name == -1) ? "Killed" : "Removed"),
		Get_Notif_TypeName(this.nent_net_type),
		this.owner.nent_name
	));
	#endif
	for (int i = 0; i < this.nent_stringcount; ++i) { strfree(this.nent_strings[i]); }
	delete(this);
}

bool Net_Write_Notification(entity this, entity client, int sf)
{
	if (!Notification_ShouldSend(this.nent_broadcast, client, this.nent_client)) return false;
	WriteHeader(MSG_ENTITY, ENT_CLIENT_NOTIFICATION);
	WriteByte(MSG_ENTITY, ORDINAL(this.nent_net_type));
	WriteShort(MSG_ENTITY, this.nent_net_name);
	for (int i = 0; i < this.nent_stringcount; ++i) { WriteString(MSG_ENTITY, this.nent_strings[i]); }
	for (int i = 0; i < this.nent_floatcount; ++i) { WriteLong(MSG_ENTITY, this.nent_floats[i]); }
	return true;
}

void Kill_Notification(
	NOTIF broadcast, entity client,
	/** message group, MSG_Null for all */
	MSG net_type,
	/** cpid group, CPID_Null for all */
	CPID net_cpid)
{
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Kill_Notification(%s, '%s', %s, %d);\n",
		Get_Notif_BroadcastName(broadcast),
		client.netname,
		(net_type ? Get_Notif_TypeName(net_type) : "0"),
		net_cpid
	));
	#endif

	string checkargs = Notification_CheckArgs(broadcast, client);
	if (checkargs != "") { LOG_WARNF("Incorrect usage of Kill_Notification: %s", checkargs); return; }

	entity net_notif = new_pure(net_kill_notification);
	net_notif.nent_broadcast = broadcast;
	net_notif.nent_client = client;
	net_notif.nent_net_type = MSG_CENTER_KILL;
	net_notif.nent_net_name = ORDINAL(net_cpid);
	Net_LinkEntity(net_notif, false, autocvar_notification_lifetime_runtime, Net_Write_Notification);

	IL_EACH(g_notifications,
		(it.owner.nent_type == net_type || net_type == MSG_Null) && (it.owner.nent_cpid == net_cpid || net_cpid == CPID_Null),
		{
			it.nent_net_name = -1;
			it.nextthink = time;
		}
	);
}

void Send_Notification(
	NOTIF broadcast, entity client,
	MSG net_type, Notification net_name,
	...count)
{
    if (broadcast == NOTIF_ONE_ONLY && !IS_REAL_CLIENT(client)) return;
	entity notif = net_name;
	string parms = sprintf("%s, '%s', %s, %s",
		Get_Notif_BroadcastName(broadcast),
		client.classname,
		Get_Notif_TypeName(net_type),
		net_name.registered_id
	);
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf("Send_Notification(%s, ...%d);\n", parms, count));
	#endif

	if (!notif)
	{
		LOG_WARN("Send_Notification: Could not find notification entity!");
		return;
	}

	// check supplied broadcast, target, type, and name for errors
	string checkargs = Notification_CheckArgs(broadcast, client);
    if (!net_name) { checkargs = sprintf("No notification provided! %s", checkargs); }
	if (checkargs != "")
	{
		LOG_WARNF("Incorrect usage of Send_Notification: %s", checkargs);
		return;
	}

	string s1 = ((0 < notif.nent_stringcount) ? ...(0, string) : "");
	string s2 = ((1 < notif.nent_stringcount) ? ...(1, string) : "");
	string s3 = ((2 < notif.nent_stringcount) ? ...(2, string) : "");
	string s4 = ((3 < notif.nent_stringcount) ? ...(3, string) : "");
	float f1 = ((0 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 0), float) : 0);
	float f2 = ((1 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 1), float) : 0);
	float f3 = ((2 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 2), float) : 0);
	float f4 = ((3 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 3), float) : 0);

	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Send_Notification(%s, %s, %s);\n",
		parms,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif

	if ((notif.nent_stringcount + notif.nent_floatcount) != count)
	{
		LOG_WARNF(
			"Argument mismatch for Send_Notification(%s, ...)! "
			"stringcount(%d) + floatcount(%d) != count(%d)\n"
			"Check the definition and function call for accuracy...?\n",
			parms,
			notif.nent_stringcount,
			notif.nent_floatcount,
			count
		);
		return;
	}

	if (server_is_dedicated
		&& (broadcast == NOTIF_ALL || broadcast == NOTIF_ALL_EXCEPT)
		&& !(net_type == MSG_CENTER)
	)
	{
		Local_Notification_WOVA(
			net_type, net_name,
			notif.nent_stringcount,
			notif.nent_floatcount,
			s1, s2, s3, s4,
			f1, f2, f3, f4);
	}

	if (net_type == MSG_CHOICE)
	{
		// THIS GETS TRICKY... now we have to cycle through each possible player (checking broadcast)
		// and then do an individual NOTIF_ONE_ONLY recursive call for each one depending on their option...
		// It's slow, but it's better than the alternatives:
		//   1. Constantly networking all info and letting client decide
		//   2. Manually handling each separate call on per-usage basis (See old CTF usage of verbose)
		entity found_choice;

		#define RECURSE_FROM_CHOICE(ent,action) MACRO_BEGIN \
			if (notif.nent_challow_var) { \
				switch (ent.msg_choice_choices[net_name.nent_choice_idx]) \
				{ \
					case 1: found_choice = notif.nent_optiona; break; \
					case 2: found_choice = notif.nent_optionb; break; \
					default: action; \
				} \
			} else { \
				found_choice = notif.nent_optiona; \
			} \
			Send_Notification_WOVA( \
				NOTIF_ONE_ONLY, \
				ent, \
				found_choice.nent_type, \
				found_choice, \
				found_choice.nent_stringcount, \
				found_choice.nent_floatcount, \
				s1, s2, s3, s4, \
				f1, f2, f3, f4); \
		MACRO_END

		switch (broadcast)
		{
			case NOTIF_ONE_ONLY: // we can potentially save processing power with this broadcast method
			{
				if (IS_REAL_CLIENT(client)) {
					RECURSE_FROM_CHOICE(client, return);
				}
				break;
			}
			default:
			{
				FOREACH_CLIENT(Notification_ShouldSend(broadcast, it, client), {
					RECURSE_FROM_CHOICE(it, continue);
				});
				break;
			}
		}
	}
	else
	{
		entity net_notif = new_pure(net_notification);
		IL_PUSH(g_notifications, net_notif);
		net_notif.owner = notif;
		net_notif.nent_broadcast = broadcast;
		net_notif.nent_client = client;
		net_notif.nent_net_type = net_type;
		net_notif.nent_net_name = notif.m_id;
		net_notif.nent_stringcount = notif.nent_stringcount;
		net_notif.nent_floatcount = notif.nent_floatcount;

		for (int i = 0; i < net_notif.nent_stringcount; ++i) {
			net_notif.nent_strings[i] = strzone(...(i, string));
		}
		for (int i = 0; i < net_notif.nent_floatcount; ++i) {
			net_notif.nent_floats[i] = ...((net_notif.nent_stringcount + i), float);
		}

		setthink(net_notif, Net_Notification_Remove);
		net_notif.nextthink = (time > autocvar_notification_lifetime_mapload)
			? (time + autocvar_notification_lifetime_runtime)
			: autocvar_notification_lifetime_mapload;

		Net_LinkEntity(net_notif, false, 0, Net_Write_Notification);
	}
}

// WOVA = Without Variable Arguments
void Send_Notification_WOVA(
	NOTIF broadcast, entity client,
	MSG net_type, Notification net_name,
	float stringcount, float floatcount,
	string s1, string s2, string s3, string s4,
	float f1, float f2, float f3, float f4)
{
	#ifdef NOTIFICATIONS_DEBUG
	entity notif = net_name;
	Debug_Notification(sprintf(
		"Send_Notification_WOVA(%s, %d, %d, %s, %s);\n",
		sprintf(
			"%s, '%s', %s, %s",
			Get_Notif_BroadcastName(broadcast),
			client.classname,
			Get_Notif_TypeName(net_type),
			notif.nent_name
		),
		stringcount,
		floatcount,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif

	#define VARITEM(stringc, floatc, args) \
		if ((stringcount == stringc) && (floatcount == floatc)) \
		{ Send_Notification(broadcast, client, net_type, net_name, args); return; }
	EIGHT_VARS_TO_VARARGS_VARLIST
	#undef VARITEM
	Send_Notification(broadcast, client, net_type, net_name); // some notifications don't have any arguments at all
}

// WOCOVA = Without Counts Or Variable Arguments
void Send_Notification_WOCOVA(
	NOTIF broadcast, entity client,
	MSG net_type, Notification net_name,
	string s1, string s2, string s3, string s4,
	float f1, float f2, float f3, float f4)
{
	entity notif = net_name;

	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Send_Notification_WOCOVA(%s, %s, %s);\n",
		sprintf(
			"%s, '%s', %s, %s",
			Get_Notif_BroadcastName(broadcast),
			client.classname,
			Get_Notif_TypeName(net_type),
			notif.nent_name
		),
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif

	#define VARITEM(stringc, floatc, args) \
		if ((notif.nent_stringcount == stringc) && (notif.nent_floatcount == floatc)) \
		{ Send_Notification(broadcast, client, net_type, net_name, args); return; }
	EIGHT_VARS_TO_VARARGS_VARLIST
	#undef VARITEM
	Send_Notification(broadcast, client, net_type, net_name); // some notifications don't have any arguments at all
}
#endif // ifdef SVQC
