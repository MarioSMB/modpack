#define _SSMAGIX "SUPERSPEC_OPTIONSFILE_V1"
#define _ISLOCAL ((edict_num(1) == self) ? TRUE : FALSE)

#define ASF_STRENGTH        1
#define ASF_SHIELD          2
#define ASF_MEGA_AR         4
#define ASF_MEGA_HP         8
#define ASF_FLAG_GRAB       16
#define ASF_OBSERVER_ONLY   32
#define ASF_SHOWWHAT        64
#define ASF_SSIM            128
#define ASF_ALL             0xFFFFFF
.float autospec_flags;

#define SSF_SILENT          1
#define SSF_VERBOSE         2
#define SSF_ITEMMSG         4
.float superspec_flags;

.string superspec_itemfilter; //"classname1 classname2 ..."

float _spectate(entity _player)
{
	if(Spectate(_player) == 1)
	{
		PutObserverInServer();
		self.classname = "spectator";
	}

	return TRUE;
}

void superspec_save_client_conf()
{
	string fn = "superspec-local.options";
	float fh;


	if not(_ISLOCAL)
	{
		if(self.crypto_idfp == "")
			return;

		fn = sprintf("superspec-%s.options", uri_escape(self.crypto_idfp));
	}

	fh = fopen(fn, FILE_WRITE);
	if(fh < 0)
	{
		dprint("^1ERROR: ^7 superspec can not open ", fn, " for writing.\n");
	}
	else
	{
		fputs(fh, _SSMAGIX);
		fputs(fh, "\n");
		fputs(fh, ftos(self.autospec_flags));
		fputs(fh, "\n");
		fputs(fh, ftos(self.superspec_flags));
		fputs(fh, "\n");
		fputs(fh, self.superspec_itemfilter);
		fputs(fh, "\n");
		fclose(fh);
	}
}

void superspec_msg(string _center_title, string _con_title, entity _to, string _msg, float _spamlevel)
{

	sprint(_to, strcat(_con_title, _msg));

	if(_to.superspec_flags & SSF_SILENT)
		return;

	if(_spamlevel > 1)
		if not(_to.superspec_flags & SSF_VERBOSE)
			return;

	centerprint(_to, strcat(_center_title, _msg));
}

float superspec_filteritem(entity _for, entity _item)
{
	float i;

	if(_for.superspec_itemfilter == "")
		return TRUE;

	if(_for.superspec_itemfilter == "")
		return TRUE;

	float l = tokenize_console(_for.superspec_itemfilter);
	for(i = 0; i < l; ++i)
	{
		if(argv(i) == _item.classname)
			return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(superspec_ItemTouch)
{
	entity _oldself = self;
	entity _item = self;

	FOR_EACH_SPEC(self)
	{
		if(self.superspec_flags & SSF_ITEMMSG)
			if(superspec_filteritem(self, _item))
			{
				if(self.superspec_flags & SSF_VERBOSE)
					superspec_msg("", "", self, sprintf("Player %s^7 just picked up ^3%s\n", other.netname, _item.netname), 1);
				else
					superspec_msg("", "", self, sprintf("Player %s^7 just picked up ^3%s\n^8(%s^8)\n", other.netname, _item.netname, _item.classname), 1);
				if(self.autospec_flags& ASF_SSIM && self.enemy != other)
				{
					_spectate(other);

					self = _oldself;
					return MUT_ITEMTOUCH_CONTINUE;
				}
			}


		if((self.autospec_flags & ASF_SHIELD && _item.invincible_finished) ||
				(self.autospec_flags & ASF_STRENGTH && _item.strength_finished) ||
				(self.autospec_flags& ASF_MEGA_AR && _item.classname == "item_armor_large") ||
				(self.autospec_flags& ASF_MEGA_HP && _item.classname == "item_health_mega") ||
				(self.autospec_flags& ASF_FLAG_GRAB && _item.classname == "item_flag_team"))
		{

			if((self.enemy != other) || IS_OBSERVER(self))
			{
				if(self.autospec_flags & ASF_OBSERVER_ONLY && !IS_OBSERVER(self))
				{
					if(self.superspec_flags & SSF_VERBOSE)
						superspec_msg("", "", self, sprintf("^8Ignored that %s^8 grabbed %s^8 since the observer_only option is ON\n", other.netname, _item.netname), 2);
				}
				else
				{
					if(self.autospec_flags & ASF_SHOWWHAT)
						superspec_msg("", "", self, sprintf("^7Following %s^7 due to picking up %s\n", other.netname, _item.netname), 2);

					_spectate(other);
				}
			}
		}
	}

	self = _oldself;

	return MUT_ITEMTOUCH_CONTINUE;
}

MUTATOR_HOOKFUNCTION(superspec_SV_ParseClientCommand)
{
#define OPTIONINFO(flag,var,test,text,long,short) \
    var = strcat(var, ((flag & test) ? "^2[ON]  ^7" : "^1[OFF] ^7")); \
    var = strcat(var, text," ^7(^3 ", long, "^7 | ^3", short, " ^7)\n")

	if(MUTATOR_RETURNVALUE) // command was already handled?
		return FALSE;

	if(IS_PLAYER(self))
		return FALSE;

	if(cmd_name == "superspec_itemfilter")
	{
		if(argv(1) == "help")
		{
			string _aspeco;
			_aspeco = "^7 superspec_itemfilter ^3\"item_classname1 item_classname2\"^7 only show thise items when ^2superspec ^3item_message^7 is on\n";
			_aspeco = strcat(_aspeco, "^3 clear^7 Remove the filter (show all pickups)\n");
			_aspeco = strcat(_aspeco, "^3 show ^7 Display current filter\n");
			superspec_msg("^3superspec_itemfilter help:\n\n\n", "\n^3superspec_itemfilter help:\n", self, _aspeco, 1);
		}
		else if(argv(1) == "clear")
		{
			if(self.superspec_itemfilter != "")
				strunzone(self.superspec_itemfilter);

			self.superspec_itemfilter = "";
		}
		else if(argv(1) == "show" || argv(1) == "")
		{
			if(self.superspec_itemfilter == "")
			{
				superspec_msg("^3superspec_itemfilter^7 is ^1not^7 set", "\n^3superspec_itemfilter^7 is ^1not^7 set\n", self, "", 1);
				return TRUE;
			}
			float i;
			float l = tokenize_console(self.superspec_itemfilter);
			string _msg = "";
			for(i = 0; i < l; ++i)
				_msg = strcat(_msg, "^3#", ftos(i), " ^7", argv(i), "\n");
				//_msg = sprintf("^3#%d^7 %s\n%s", i, _msg, argv(i));

			_msg = strcat(_msg,"\n");

			superspec_msg("^3superspec_itemfilter is:\n\n\n", "\n^3superspec_itemfilter is:\n", self, _msg, 1);
		}
		else
		{
			if(self.superspec_itemfilter != "")
				strunzone(self.superspec_itemfilter);

			self.superspec_itemfilter = strzone(argv(1));
		}


		return TRUE;
	}

	if(cmd_name == "superspec")
	{
		string _aspeco;

		if(cmd_argc > 1)
		{
			float i, _bits = 0, _start = 1;
			if(argv(1) == "help")
			{
				_aspeco = "use cmd superspec [option] [on|off] to set options\n\n";
				_aspeco = strcat(_aspeco, "^3 silent ^7(short^5 si^7) supress ALL mesagess from superspectate.\n");
				_aspeco = strcat(_aspeco, "^3 verrbose ^7(short^5 ve^7) makes superspectate print some additional information.\n");
				_aspeco = strcat(_aspeco, "^3 item_message ^7(short^5 im^7) makes superspectate print items that was picked up.\n");
				_aspeco = strcat(_aspeco, "^7    Use cmd superspec_itemfilter \"item_class1 item_class2\" to set up a filter of what to show with ^3item_message.\n");
				superspec_msg("^2Available Super Spectate ^3options:\n\n\n", "\n^2Available Super Spectate ^3options:\n", self, _aspeco, 1);
				return TRUE;
			}

			if(argv(1) == "clear")
			{
				self.superspec_flags = 0;
				_start = 2;
			}

			for(i = _start; i < cmd_argc; ++i)
			{
				if(argv(i) == "on" || argv(i) == "1")
				{
					self.superspec_flags |= _bits;
					_bits = 0;
				}
				else if(argv(i) == "off" || argv(i) == "0")
				{
					if(_start == 1)
						self.superspec_flags &~= _bits;

					_bits = 0;
				}
				else
				{
					if((argv(i) == "silent") || (argv(i) == "si")) _bits |= SSF_SILENT ;
					if((argv(i) == "verbose") || (argv(i) == "ve")) _bits |= SSF_VERBOSE;
					if((argv(i) == "item_message") || (argv(i) == "im")) _bits |= SSF_ITEMMSG;
				}
			}
		}


		_aspeco = "";
		OPTIONINFO(self.superspec_flags, _aspeco, SSF_SILENT, "Silent", "silent", "si");
		OPTIONINFO(self.superspec_flags, _aspeco, SSF_VERBOSE, "Verbose", "verbose", "ve");
		OPTIONINFO(self.superspec_flags, _aspeco, SSF_ITEMMSG, "Item pickup messages", "item_message", "im");

		superspec_msg("^3Current Super Spectate options are:\n\n\n\n\n", "\n^3Current Super Spectate options are:\n", self, _aspeco, 1);
		return TRUE;

	}

/////////////////////

	if(cmd_name == "autospec")
	{
		string _aspeco;
		if(cmd_argc > 1)
		{
			if(argv(1) == "help")
			{
				_aspeco = "use cmd autospec [option] [on|off] to set options\n\n";
				_aspeco = strcat(_aspeco, "^3 strength ^7(short^5 st^7) for automatic spectate on strength powerup\n");
				_aspeco = strcat(_aspeco, "^3 shield ^7(short^5 sh^7) for automatic spectate on shield powerup\n");
				_aspeco = strcat(_aspeco, "^3 mega_health ^7(short^5 mh^7) for automatic spectate on mega health\n");
				_aspeco = strcat(_aspeco, "^3 mega_armor ^7(short^5 ma^7) for automatic spectate on mega armor\n");
				_aspeco = strcat(_aspeco, "^3 flag_grab ^7(short^5 fg^7) for automatic spectate on CTF flag grab\n");
				_aspeco = strcat(_aspeco, "^3 observer_only (short^5 oo^7) for automatic spectate only if in observer mode\n");
				_aspeco = strcat(_aspeco, "^3 show_what (short^5 sw^7) to display what event triggerd autospectate\n");
				_aspeco = strcat(_aspeco, "^3 item_msg ^7(short^5 im^7) to autospec when item_message in superspectate is triggerd\n");
				_aspeco = strcat(_aspeco, "^3 all ^7(short ^5aa^7) turn everything on/off\n");
				superspec_msg("^2Available Auto Spectate ^3options:\n\n\n", "\n^2Available Auto Spectate ^3options:\n", self, _aspeco, 1);
				return TRUE;
			}

			float i, _bits = 0, _start = 1;
			if(argv(1) == "clear")
			{
				self.autospec_flags = 0;
				_start = 2;
			}

			for(i = _start; i < cmd_argc; ++i)
			{
				if(argv(i) == "on" || argv(i) == "1")
				{
					self.autospec_flags |= _bits;
					_bits = 0;
				}
				else if(argv(i) == "off" || argv(i) == "0")
				{
					if(_start == 1)
						self.autospec_flags &~= _bits;

					_bits = 0;
				}
				else
				{
					if((argv(i) == "strength") || (argv(i) == "st")) _bits |= ASF_STRENGTH;
					if((argv(i) == "shield") || (argv(i) == "sh")) _bits |= ASF_SHIELD;
					if((argv(i) == "mega_health") || (argv(i) == "mh")) _bits |= ASF_MEGA_HP;
					if((argv(i) == "mega_armor") || (argv(i) == "ma")) _bits |= ASF_MEGA_AR;
					if((argv(i) == "flag_grab") || (argv(i) == "fg")) _bits |= ASF_FLAG_GRAB;
					if((argv(i) == "observer_only") || (argv(i) == "oo")) _bits |= ASF_OBSERVER_ONLY;
					if((argv(i) == "show_what") || (argv(i) == "sw")) _bits |= ASF_SHOWWHAT;
					if((argv(i) == "item_msg") || (argv(i) == "im")) _bits |= ASF_SSIM;
					if((argv(i) == "all") || (argv(i) == "aa")) _bits |= ASF_ALL;
				}
			}
		}

		_aspeco = "";
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_STRENGTH, "Strength", "strength", "st");
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_SHIELD, "Shield", "shield", "sh");
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_MEGA_HP, "Mega Health", "mega_health", "mh");
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_MEGA_AR, "Mega Armor", "mega_armor", "ma");
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_FLAG_GRAB, "Flag grab", "flag_grab","fg");
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_OBSERVER_ONLY, "Only switch if Observer", "observer_only", "oo");
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_SHOWWHAT, "Show what item triggered spectate", "show_what", "sw");
		OPTIONINFO(self.autospec_flags, _aspeco, ASF_SSIM, "Switch on superspec item message", "item_msg", "im");

		superspec_msg("^3Current auto spectate options are:\n\n\n\n\n", "\n^3Current auto spectate options are:\n", self, _aspeco, 1);
		return TRUE;
	}

	if(cmd_name == "followpowerup")
	{
		entity _player;
		FOR_EACH_PLAYER(_player)
		{
			if(_player.strength_finished > time || _player.invincible_finished > time)
				return _spectate(_player);
		}

		superspec_msg("", "", self, "No active powerups\n", 1);
		return TRUE;
	}

	if(cmd_name == "followstrength")
	{
		entity _player;
		FOR_EACH_PLAYER(_player)
		{
			if(_player.strength_finished > time)
				return _spectate(_player);
		}

		superspec_msg("", "", self, "No active Strength\n", 1);
		return TRUE;
	}

	if(cmd_name == "followstshield")
	{
		entity _player;
		FOR_EACH_PLAYER(_player)
		{
			if(_player.invincible_finished > time)
				return _spectate(_player);
		}

		superspec_msg("", "", self, "No active Shield\n", 1);
		return TRUE;
	}

	if(cmd_name == "followfc")
	{
		if(!g_ctf)
			return TRUE;

		entity _player;
		float _team = 0;

		if(cmd_argc == 2)
		{
			if(argv(1) == "red")
				_team = NUM_TEAM_1;
			else
				_team = NUM_TEAM_2;
		}

		FOR_EACH_PLAYER(_player)
		{
			if(_player.flagcarried && (_player.team == _team || _team == 0))
				return _spectate(_player);
		}

		superspec_msg("", "", self, "No active flag carrier\n", 1);
		return TRUE;
	}

	return FALSE;
#undef OPTIONINFO
}

MUTATOR_HOOKFUNCTION(superspec_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":SS");
	return 0;
}

MUTATOR_HOOKFUNCTION(superspec_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Super Spectators");
	return 0;
}

/*
MUTATOR_HOOKFUNCTION(superspec_PlayerSpawn)
{

    return FALSE;
}
*/

void superspec_hello()
{
	if(self.enemy.crypto_idfp == "")
		centerprint(self.enemy, "Your client have/allow no crypto id, superspec options will not be saved/restored.");
	else
		centerprint(self.enemy, sprintf("Hello %s\nSince your client has a Crypto ID, your superspec preferenses will be presisted on this server.", self.enemy.netname));

	remove(self);
}

MUTATOR_HOOKFUNCTION(superspec_ClientConnect)
{
	if(!IS_REAL_CLIENT(self))
		return FALSE;

	string fn = "superspec-local.options";
	float fh;

	self.superspec_flags = SSF_VERBOSE;
	self.superspec_itemfilter = "";

	entity _hello = spawn();
	_hello.enemy = self;
	_hello.think = superspec_hello;
	_hello.nextthink = time + 5;

	if not(_ISLOCAL)
	{
		if(self.crypto_idfp == "")
			return FALSE;

		fn = sprintf("superspec-%s.options", uri_escape(self.crypto_idfp));
	}

	fh = fopen(fn, FILE_READ);
	if(fh < 0)
	{
		dprint("^1ERROR: ^7 superspec can not open ", fn, " for reading.\n");
	}
	else
	{
		string _magic = fgets(fh);
		if(_magic != _SSMAGIX)
		{
			dprint("^1ERROR^7 While reading superspec options file: unkown magic\n");
		}
		else
		{
			self.autospec_flags = stof(fgets(fh));
			self.superspec_flags = stof(fgets(fh));
			self.superspec_itemfilter = strzone(fgets(fh));
		}
		fclose(fh);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(superspec_ClientDisconnect)
{
	superspec_save_client_conf();
	return FALSE;
}


/*
MUTATOR_HOOKFUNCTION(superspec_MakePlayerObserver)
{
    return FALSE;
}

MUTATOR_HOOKFUNCTION(superspec_PlayerPreThink)
{
    return FALSE;
}
*/

MUTATOR_DEFINITION(mutator_superspec)
{

	MUTATOR_HOOK(BuildMutatorsString, superspec_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, superspec_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_ParseClientCommand, superspec_SV_ParseClientCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(ItemTouch, superspec_ItemTouch, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientConnect, superspec_ClientConnect, CBC_ORDER_ANY);
	//MUTATOR_HOOK(PlayerSpawn, superspec_PlayerSpawn, CBC_ORDER_ANY);
	//MUTATOR_HOOK(PlayerPreThink, superspec_PlayerPreThink, CBC_ORDER_ANY);
	//MUTATOR_HOOK(MakePlayerObserver, superspec_MakePlayerObserver, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, superspec_ClientDisconnect, CBC_ORDER_ANY);

	return 0;
}
