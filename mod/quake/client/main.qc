// required engine functions

#define DP_CSQC_ENTITY_REMOVE_IS_B0RKED

void LoadMenuSkinValues();
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

	LoadMenuSkinValues();
}

#define drawpic(position, pic, size, rgb, alpha, flag) \
	drawpic_builtin(position, pic, size, rgb, alpha, flag)

#define drawstring(position, text, scale, rgb, alpha, flag) \
	drawstring_builtin(position, text, scale, rgb, alpha, flag)

#define drawcolorcodedstring(position, text, scale, alpha, flag) \
	drawcolorcodedstring_builtin(position, text, scale, alpha, flag)

#define drawcolorcodedstring2(position, text, scale, rgb, alpha, flag) \
	drawcolorcodedstring2_builtin(position, text, scale, rgb, alpha, flag)

#define drawfill(position, size, rgb, alpha, flag) \
	drawfill_builtin(position, size, rgb, alpha, flag)

string draw_currentSkin;
void draw_cursor(vector pos, vector ofs, string img, vector col, float a)
{
	ofs = eX * (ofs.x * SIZE_CURSOR.x) + eY * (ofs.y * SIZE_CURSOR.y);
	drawpic(pos - ofs, strcat(draw_currentSkin, img), SIZE_CURSOR, col, a, DRAWFLAG_NORMAL);
}

void draw_cursor_normal(vector pos, vector col, float a)
{
	draw_cursor(pos, OFFSET_CURSOR, "/cursor", col, a);
}

void LoadMenuSkinValues()
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

int cs_project_is_b0rked;

float autocvar_vid_conwidth;
float autocvar_vid_conheight;

bool autocvar_cl_enginesbar = false;

void Sbar_Draw();
void HUD_Crosshair(entity this);
void CSQC_UpdateView(entity this, float w, float h)
{
	++framecount;

	stats_get();

	CSQCPlayer_SetCamera();

	ticrate = STAT(MOVEVARS_TICRATE) * STAT(MOVEVARS_TIMESCALE);

	// ALWAYS Clear Current Scene First
	clearscene();

	// Assign Standard Viewflags
	// Draw the World (and sky)
	setproperty(VF_DRAWWORLD, 1);

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 0);

	// Draw the Engine Status Bar (the default Quake HUD)
	setproperty(VF_DRAWENGINESBAR, autocvar_cl_enginesbar);

	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();

	// now switch to 2D drawing mode by calling a 2D drawing function
	// then polygon drawing will draw as 2D stuff, and NOT get queued until the
	// next R_RenderScene call
	drawstring('0 0 0', "", '1 1 0', '1 1 1', 0, 0);

	Sbar_Draw();
	HUD_Crosshair(this);

	// we must do this check AFTER a frame was rendered, or it won't work
	if(cs_project_is_b0rked == 0)
	{
		string w0, h0;
		w0 = ftos(autocvar_vid_conwidth);
		h0 = ftos(autocvar_vid_conheight);
		//setproperty(VF_VIEWPORT, '0 0 0', '640 480 0');
		//setproperty(VF_FOV, '90 90 0');
		setproperty(VF_ORIGIN, '0 0 0');
		setproperty(VF_ANGLES, '0 0 0');
		setproperty(VF_PERSPECTIVE, 1);
		makevectors('0 0 0');
		vector v1, v2;
		cvar_set("vid_conwidth", "800");
		cvar_set("vid_conheight", "600");
		v1 = cs_project(v_forward);
		cvar_set("vid_conwidth", "640");
		cvar_set("vid_conheight", "480");
		v2 = cs_project(v_forward);
		if(v1 == v2)
			cs_project_is_b0rked = 1;
		else
			cs_project_is_b0rked = -1;
		cvar_set("vid_conwidth", w0);
		cvar_set("vid_conheight", h0);
	}

	if(intermission && !completed_time)
		completed_time = time;

	IL_ENDFRAME();
}

bool CSQC_InputEvent(int inputType, float nPrimary, float nSecondary)
{
	if(inputType == 3)
	{
		mousepos.x = nPrimary;
		mousepos.y = nSecondary;
		return true;
	}

	return false;
}

STATIC_INIT(accuracy_commands)
{
	registercommand("+showaccuracy");
	registercommand("-showaccuracy");
}

bool CSQC_ConsoleCommand(string command)
{
	tokenize_console(command);
	string s = strtolower(argv(0));

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

	if(this.snd_looping > 0)
	{
		sound(this, this.snd_looping, SND_Null, VOL_BASE, 2);
		this.snd_looping = 0;
	}

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


// optional stuff
STATIC_INIT_LATE(fix_hud)
{
	registercvar("_rrestarted", "0");

	//if(autocvar_cl_enginesbar)
	if(!cvar("_rrestarted"))
	{
		cvar_set("_rrestarted", "1");
		localcmd("\ndefer 1 r_restart\n");
	}
}
