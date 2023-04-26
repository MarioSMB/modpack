#include "main.qh"

#include "editor.qh"

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

// CSQC_InputEvent : Used to perform actions based on any key pressed, key released and mouse on the client.
// Return value should be 1 if CSQC handled the input, otherwise return 0 to have the input passed to the engine.
// All keys are in ascii.
// bInputType = 0 is key pressed, 1 is key released, 2 and 3 are mouse input.
// In the case of keyboard input, nPrimary is the ascii code, and nSecondary is 0.
// In the case of mouse input, nPrimary is xdelta, nSecondary is ydelta.
// In the case of mouse input after a setcursormode(1) call, nPrimary is xpos, nSecondary is ypos.
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

	if(cl_editor_input_event(evtype, nPrimary, nSecondary, 0))
		return true;

	return false;
}

STATIC_INIT(fix_commands)
{
	registercommand("+showaccuracy");
	registercommand("-showaccuracy");

	cvar_settemp("chase_active", "1");
	cvar_settemp("chase_back", "0");
	cvar_settemp("chase_up", "0");
}

NET_HANDLE(win, bool)
{
	the_score = ReadByte();
	return true;
}

float ringshinetime; // shared among all? maybe should be a field
void ring_draw(entity this)
{
	this.origin.z += 32 + sin(time * 4) * 12;
	setorigin(this, this.origin);
	this.angles = vec3(time * 90, time * 125, time * 45);
	if(time > ringshinetime)
	{
		pointparticles(EFFECT_RING_SHINE, this.origin, normalize(randomvec()), 1);
		ringshinetime = time + 0.13;
	}
}

NET_HANDLE(ENT_CLIENT_RING, bool isnew)
{
	this.origin = ReadVector();
	setorigin(this, this.origin);
	this.draw = ring_draw;
	if(isnew) IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	return = true;
}

bool CSQC_ConsoleCommand(string command)
{
	tokenize_console(command);
	string s = strtolower(argv(0));

	if(cl_editor_command(s))
		return true;

	if(s == "noclip")
	{
		cheats_used = true;
		return false;
	}

	if(s == "+showaccuracy" || s == "-showaccuracy")
		return true; // don't handle, just don't do anything

	return false;
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
	//this.draw = func_null;
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

void centerprint_hud(string strMessage);
void centerprint_generic(int new_id, string strMessage, float duration, int countdown_num);
// CSQC_Parse_CenterPrint : Provides the centerprint_hud string in the first parameter that the server provided.
void CSQC_Parse_CenterPrint(string strMessage)
{
	if (autocvar_developer_csqcentities) LOG_INFOF("CSQC_Parse_CenterPrint(\"%s\")", strMessage);
	centerprint_hud(strMessage);
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

STATIC_INIT(PlayerSlots_Spawn)
{
	for(int j = 0; j < maxclients; ++j)
	{
		entity e = playerslots[j] = new_pure(playerslot);
		e.sv_entnum = j;
	}
}
