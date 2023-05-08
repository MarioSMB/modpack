#include "main.qh"

#include "centerprint.qh"
#include "sbar.qh"
#include "shop.qh"
#include "../common/stats.qh"
#include "../common/sui_sys.qh"
#include "../common/weapons/all.qh"

bool autocvar_developer_csqcentities;

// required engine functions

#define DP_CSQC_ENTITY_REMOVE_IS_B0RKED

void CSQC_Init()
{
	{
		int i = 0;
		for ( ; i < 255; ++i)
			if (getplayerkeyvalue(i, "viewentity") == "")
				break;
		maxclients = i;
	}

	postinit = false;

	// needs to be done so early because of the constants they create
	static_init();
	static_init_late();
	static_init_precache();
}

string draw_currentSkin;

STATIC_INIT_LATE(LoadMenuSkinValues)
{
	int fh = -1;
	if(cvar_string("menu_skin") != "")
	{
		draw_currentSkin = strcat("gfx/menu/", cvar_string("menu_skin"));
		fh = fopen(strcat(draw_currentSkin, "/skinvalues.txt"), FILE_READ);
	}
	if(fh < 0 && cvar_defstring("menu_skin") != "")
	{
		cvar_set("menu_skin", cvar_defstring("menu_skin"));
		draw_currentSkin = strcat("gfx/menu/", cvar_string("menu_skin"));
		fh = fopen(strcat(draw_currentSkin, "/skinvalues.txt"), FILE_READ);
	}
	if(fh < 0)
	{
		draw_currentSkin = "gfx/menu/default";
		fh = fopen(strcat(draw_currentSkin, "/skinvalues.txt"), FILE_READ);
	}

	draw_currentSkin = strzone(draw_currentSkin);

	if(fh >= 0)
	{
		string s;
		while((s = fgets(fh)))
		{
			int n = tokenize_console(s);
			if (n < 2)
				continue;
			if(substring(argv(0), 0, 2) == "//")
				continue;
			if(argv(0) == "SIZE_CURSOR")
				SIZE_CURSOR = stov(substring(s, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)));
			else if(argv(0) == "OFFSET_CURSOR")
				OFFSET_CURSOR = stov(substring(s, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)));
		}
		fclose(fh);
	}
}

bool CSQC_InputEvent(int inputType, float nPrimary, float nSecondary)
{
	int evtype = 0;
	switch(inputType)
	{
		case 0: evtype = IE_KEYDOWN; break;
		case 1: evtype = IE_KEYUP; break;
		case 2:
		case 3: evtype = IE_MOUSEABS; break;
	}

	sui_input_event(evtype, nPrimary, nSecondary, 0);

	switch(evtype)
	{
		case IE_KEYDOWN:
			if(nPrimary == K_ALT)
				alt_held = true;
			if(nPrimary == K_CTRL)
				ctrl_held = true;
			if(nPrimary == K_SHIFT)
				shift_held = true;
			break;
		case IE_KEYUP:
			if(nPrimary == K_ALT)
				alt_held = false;
			if(nPrimary == K_CTRL)
				ctrl_held = false;
			if(nPrimary == K_SHIFT)
				shift_held = false;
			break;
		case IE_MOUSEDELTA:
			break;
		case IE_MOUSEABS:
			_cursor_position.x = nPrimary;
			_cursor_position.y = nSecondary;
			break;
	}

	if(cl_shop_input_event(evtype, nPrimary, nSecondary, 0))
		return true;

	if(inputType == 3)
	{
		mousepos.x = nPrimary;
		mousepos.y = nSecondary;
		return true;
	}

	return false;
}

STATIC_INIT(fix_commands)
{
	registercommand("+showaccuracy");
	registercommand("-showaccuracy");
}

bool CSQC_ConsoleCommand(string command)
{
	tokenize_console(command);
	string s = strtolower(argv(0));

	if(cl_shop_command(s))
		return true;

	if(s == "+showaccuracy" || s == "-showaccuracy")
		return true; // don't handle, just don't do anything

	return false;
}

void GameCommand(string command)
{
	tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password
	string s = strtolower(argv(0));
	if(s == "sendcvar")
	{
		if (argv(1))
		{
			// W_FixWeaponOrder will trash argv, so save what we need.
			string thiscvar = string_null; strcpy(thiscvar, argv(1));
			string s = cvar_string(thiscvar);

			if (thiscvar == "cl_quake_weaponpriority")
				s = W_FixWeaponOrder(W_NumberWeaponOrder(s), 1);
			else if (substring(thiscvar, 0, 17) == "cl_quake_weaponpriority" && strlen(thiscvar) == 18)
				s = W_FixWeaponOrder(W_NumberWeaponOrder(s), 0);

			localcmd("cmd sentcvar ", thiscvar, " \"", s, "\"\n");
			strfree(thiscvar);
			return;
		}
		LOG_INFOF("Incorrect parameters for ^2%s^7", s);
		LOG_HELP("Usage:^3 cl_cmd sendcvar <cvar>");
		LOG_HELP("  Where <cvar> is the cvar to send to the server.");
		return;
	}

	// nothing above caught the command, must be invalid
	LOG_INFO(((command != "") ? strcat("Unknown client command \"", command, "\"") : "No command provided"), ". For a list of supported commands, try cl_cmd help.");
}

void Ent_Remove(entity this);
void CSQC_Ent_Update(entity this, bool isnew)
{
	this.sourceLoc = __FILE__ ":" STR(__LINE__);
	int t = ReadByte();

	// set up the "time" global for received entities to be correct for interpolation purposes
	float savetime = time;
	if(servertime)
	{
		time = servertime;
	}
	else
	{
		serverprevtime = time;
		serverdeltatime = STAT(MOVEVARS_TICRATE) * STAT(MOVEVARS_TIMESCALE);
		time = serverprevtime + serverdeltatime;
	}

#ifdef DP_CSQC_ENTITY_REMOVE_IS_B0RKED
	if (this.enttype)
	{
		if (t != this.enttype || isnew)
		{
			LOG_INFOF("A CSQC entity changed its type! (edict: %d, server: %d, type: %d -> %d)\n", etof(this), this.entnum, this.enttype, t);
			Ent_Remove(this);
			clearentity(this);
			isnew = true;
		}
	}
	else
	{
		if (!isnew)
		{
			LOG_INFOF("A CSQC entity appeared out of nowhere! (edict: %d, server: %d, type: %d)\n", etof(this), this.entnum, t);
			isnew = true;
		}
	}
#endif
	this.enttype = t;
	bool done = false;
	FOREACH(LinkedEntities, it.m_id == t, {
		if (isnew) this.classname = it.netname;
		if (autocvar_developer_csqcentities)
            LOG_INFOF("CSQC_Ent_Update(%d) at %f with this=%i {.entnum=%d, .enttype=%d} t=%s (%d)\n", isnew, savetime, this, this.entnum, this.enttype, this.classname, t);
		done = it.m_read(this, NULL, isnew);
		//MUTATOR_CALLHOOK(Ent_Update, this, isnew);
		break;
	});
	time = savetime;
	if (!done)
	{
		LOG_FATALF("CSQC_Ent_Update(%d) at %f with this=%i {.entnum=%d, .enttype=%d} t=%s (%d)", isnew, savetime, this, this.entnum, this.enttype, this.classname, t);
	}
}

// Destructor, but does NOT deallocate the entity by calling remove(). Also
// used when an entity changes its type. For an entity that someone interacts
// with others, make sure it can no longer do so.
void Ent_Remove(entity this)
{
	if(this.entremove) this.entremove(this);

#if 0
	if(this.snd_looping > 0)
	{
		sound(this, this.snd_looping, SND_Null, VOL_BASE, 2);
		this.snd_looping = 0;
	}
#endif

	this.enttype = 0;
	this.classname = "";
	this.draw = func_null;
	this.entremove = func_null;
	// TODO possibly set more stuff to defaults
}
// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(this) as well.
void CSQC_Ent_Remove(entity this)
{
	if (autocvar_developer_csqcentities) LOG_INFOF("CSQC_Ent_Remove() with this=%i {.entnum=%d, .enttype=%d}\n", this, this.entnum, this.enttype);
	if (wasfreed(this))
	{
		LOG_WARN("CSQC_Ent_Remove called for already removed entity. Packet loss?");
		return;
	}
	if (this.enttype) Ent_Remove(this);
	delete(this);
}

// CSQC_Parse_CenterPrint : Provides the centerprint_AddStandard string in the first parameter that the server provided.
void CSQC_Parse_CenterPrint(string strMessage)
{
	if (autocvar_developer_csqcentities) LOG_INFOF("CSQC_Parse_CenterPrint(\"%s\")", strMessage);
	centerprint_AddStandard(strMessage);
}

// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
bool CSQC_Parse_TempEntity()
{
	// Acquire TE ID
	int nTEID = ReadByte();

	FOREACH(TempEntities, it.m_id == nTEID, {
		if (autocvar_developer_csqcentities)
			LOG_INFOF("CSQC_Parse_TempEntity() nTEID=%s (%d)\n", it.netname, nTEID);
		return it.m_read(NULL, NULL, true);
	});

	if (autocvar_developer_csqcentities)
		LOG_INFOF("CSQC_Parse_TempEntity() with nTEID=%d\n", nTEID);

	// No special logic for this temporary entity; return 0 so the engine can handle it
	return false;
}

void PostInit()
{
	// this can't be called in CSQC_Init as it'd send cvars too early
	ReplicateVars_Start();

	postinit = true;
}

NET_HANDLE(ENT_CLIENT_INIT, bool isnew)
{
	serverflags = ReadByte();

	return = true;

	if (!postinit) PostInit();
}

STATIC_INIT(PlayerSlots_Spawn)
{
	for(int j = 0; j < maxclients; ++j)
	{
		entity e = playerslots[j] = new_pure(playerslot);
		e.sv_entnum = j;
	}
}

// optional stuff

NET_HANDLE(TE_CSQC_PINGPLREPORT, bool isNew)
{
	int i = ReadByte();
	int pi = ReadShort();
	int pl = ReadByte();
	int ml = ReadByte();
	return = true;
	entity e = playerslots[i];
	if (!e) return;
	e.ping = pi;
	e.ping_packetloss = pl / 255.0;
	e.ping_movementloss = ml / 255.0;
}

.vector vorg1, vorg2;
void Lightning_Draw(entity this)
{
	string tex;
	//tex = "particles/lgbeam";
	tex = "particles/gauntletbeam";

	Draw_CylindricLine(this.vorg1, this.vorg2, 6, tex, 0.25, -time * 3, '1 1 1', 1, DRAWFLAG_NORMAL, view_origin);
}

NET_HANDLE(TE_CSQC_LIGHTNING, bool isNew)
{
	Net_Accept(lightning);
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.15;
	this.draw = Lightning_Draw;
	if (isNew) IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	this.vorg1 = ReadVector();
	this.vorg2 = ReadVector();

	return true;
}

NET_HANDLE(TE_CSQC_ITEMPICKUP, bool isNew)
{
	int theitem = ReadByte();
	float amount = ReadShort();
	Sbar_Notify_Push(amount, theitem);
	return true;
}

.string mdl;
void togglewall_remove(entity this)
{
	strfree(this.mdl);
}

NET_HANDLE(ENT_CLIENT_TOGGLEWALL, bool isnew)
{
	InterpolateOrigin_Undo(this);
	this.iflags = IFLAG_ANGLES | IFLAG_ORIGIN;

	int sf = ReadByte();

	if(sf & BIT(0))
	{
		this.skin = ReadByte();
	}

	if(sf & BIT(1))
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);
	}

	if(sf & BIT(2))
	{
		if(sf & 0x10)
			this.angles = ReadAngleVector();
		else
			this.angles = '0 0 0';
	}

	if(sf & BIT(3))
	{
		strfree(this.mdl);
		this.mdl = strzone(ReadString());
		this.solid = ReadByte();
		this.scale = ReadShort() / 256.0;
		_setmodel(this, this.mdl);
		if(sf & 0x20)
		{
			this.mins = ReadVector();
			this.maxs = ReadVector();
		}
		else
			this.mins = this.maxs = '0 0 0';
		setsize(this, this.mins, this.maxs);
		this.model = "null";
	}

	return = true;

	this.entremove = togglewall_remove;

	InterpolateOrigin_Note(this);
}
