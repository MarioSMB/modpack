void QCC_FixClient(entity this)
{
#ifdef CSQC
	this.m_champion = REGISTRY_GET(Champion, STAT(QCC_CHAMPION, this));
#endif

	if(this.m_champion && this.m_champion.m_fixclient)
		this.m_champion.m_fixclient(this.m_champion, this);
}

#ifdef GAMEQC
void champions_PlayerTouch(entity this, entity toucher) 
{
	if(this.m_champion && this.m_champion.m_touch)
		this.m_champion.m_touch(this.m_champion, this, toucher);
}
#endif

bool champions_PlayerPhysics(entity this, float dt)
{
	if(this.m_champion && this.m_champion.m_physics)
		return this.m_champion.m_physics(this.m_champion, this, dt);
	return false;
}

#ifdef SVQC
void QCC_UpdateStats(entity this)
{
	if(intermission_running)
		return;

	if(this.m_champion)
	{
		STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = this.m_champion.m_viewofs;
		STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = this.m_champion.m_mins;
		STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = this.m_champion.m_maxs;

		if(this.m_champion.m_updatestats)
			this.m_champion.m_updatestats(this.m_champion, this);
	}
}

void QCC_UpdatePlayer(entity this)
{
	Champions oldchamp = this.m_champion;
	Champions champ = Champion_FromString(this.cvar_cl_quake_model);
	if(champ.m_condition && champ.m_condition(champ, this))
		champ = CHAMPION_Ranger;

	STAT(QCC_CHAMPION, this) = champ.m_id;
	this.m_champion = champ;

	string newmdl = champ.m_model.model_str();
	if(newmdl != this.playermodel)
	{
		this.playermodel = newmdl;
		_setmodel(this, newmdl);
		this.modelindex_player = this.modelindex;

		setsize(this, champ.m_mins, champ.m_maxs);

		this.view_ofs = champ.m_viewofs;
		this.scale = champ.m_scale;

		if(champ != oldchamp && oldchamp.m_clear)
			oldchamp.m_clear(oldchamp, this);

		if(champ.m_activate)
			champ.m_activate(champ, this);
	}
}

void champions_PutPlayerInServer(entity this)
{
	this.playermodel = "";

	QCC_UpdatePlayer(this);

	if(this.m_champion && this.m_champion.m_playerspawn)
		this.m_champion.m_playerspawn(this.m_champion, this);

	// TODO: special way for champions to always run their own code?
	Dusk_PlayerSpawn(this);
}

void champions_PlayerPreThink(entity this)
{
	QCC_UpdatePlayer(this);

	if(this.m_champion && this.m_champion.m_playerthink)
		this.m_champion.m_playerthink(this.m_champion, this);
}

void champions_PlayerDies(entity this)
{
	if(this.m_champion && this.m_champion.m_clear)
		this.m_champion.m_clear(this.m_champion, this);
}

void champions_RemovePlayer(entity this)
{
	if(this.m_champion && this.m_champion.m_clear)
		this.m_champion.m_clear(this.m_champion, this);
}

void champions_Killed(entity targ, entity inflictor, entity attacker, int deathtype)
{
	if(attacker.m_champion && attacker.m_champion.m_killed)
		attacker.m_champion.m_killed(attacker.m_champion, targ, inflictor, attacker, deathtype);
	// TODO: special way for champions to run their own code
	Dusk_Killed(targ, inflictor, attacker, deathtype);
}
#endif

#ifdef CSQC
void champion_menu_close();

float selected_champion_index;

Champions champdata[REGISTRY_MAX(Champion)];

vector champion_menu_scroll;

string Champion_PrettyName(int index)
{
	Champions champ = champdata[index];
	return champ.m_name;
}

string Champion_Name(int index)
{
	Champions champ = champdata[index];
	return champ.netname;
}

void champion_menu_select()
{
	LOG_DEBUG("Selecting ", Champion_Name(selected_champion_index));
	localcmd(sprintf("seta cl_quake_model %s\n", Champion_Name(selected_champion_index)));
	champion_menu_close();
}

void champion_menu_list(string id, vector pos, vector size)
{
	for(int j = 0; j < REGISTRY_MAX(Champion); ++j)
	{
		champdata[j] = NULL;
	}
	int champcount = 0;
	FOREACH(Champion, !it.m_hidden,
	{
		champdata[champcount] = it;
		champcount += 1;
	});

	sui_fill(pos, size, '0.2 0.2 0.2', 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, vec2(size.x - 6, 16), champcount, '0 6 0');
	sui_pos = '0 0 0';
	for(float index = sui_list_item(); index > -1; index = sui_list_item())
	{
		sui_push_frame(sui_pos, vec2(size.x - 6, 16));
		string iid = strcat(id, ftos(index));
		sui_action_element('0 0 0', vec2(size.x -6, 16), iid);
		if(sui_is_hovered(iid))
		{
			sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.1, 0);
			if(sui_is_clicked(iid))
			{
				selected_champion_index = index;
				champion_menu_select();
				break;
			}
		}
		sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_CENTER));
		//if(selected_champion_index == index)
			//sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.2, 0);
		sui_drawtext('0 0 0', '8 8 0', Champion_PrettyName(index), '1 1 1', 1, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
}

void cl_champion_draw()
{
	if(!(cursor_active & GUI_OPEN_CHAMPIONS))
		return;
	if(intermission || STAT(HEALTH) <= 0 || STAT(SKATING))
		return;
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext('0 170 0', '16 16 0', "CHOOSE A CHAMPION", '0.3 1 0.3', 1, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_fill('0 0 0', '4 4 0', '0 0 0', 0.5, 0);
	sui_fill('0 0 0', '2 2 0', '1 1 1', 0.75, 0);
	
	vector ent_menu_size = '280 170 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_push_frame('0 0 0', ent_menu_size);
	
	sui_fill('0 0 0', ent_menu_size, '0 0 0', 0.5, 0);
	sui_offset = champion_menu_scroll;
	champion_menu_list("champion_menu_list", '0 0 0', ent_menu_size - '2 2 0');
	champion_menu_scroll = sui_offset;
	
	sui_pop_frame();
}

void champion_menu_open()
{
	selected_champion_index = 0;
	cursor_active |= GUI_OPEN_CHAMPIONS;
	setcursormode(cursor_active);
}

void champion_menu_close()
{
	selected_champion_index = 0;
	cursor_active &= ~GUI_OPEN_CHAMPIONS;
	setcursormode(cursor_active);
}

// This must be called in CSQC_ConsoleCommand
// input entity self
// input string cmd: same as in CSQC_ConsoleCommand
// output float: true if command was handled, false if not
bool cl_champion_command(string cmd)
{
	if(cmd == "hud" && argv(1) == "quickmenu")
	{
		champion_menu_open();
		return true;
	}
	return false;
}

bool cl_champion_input_event(float evtype, float scanx, float chary, float devid)
{
	if(!(cursor_active & GUI_OPEN_CHAMPIONS))
		return false;
	
	switch(evtype)
	{
		case IE_KEYDOWN:
			if(substring(sui_get_last_clicked(), 0, 3) == "in_")
				return true;
	
			if(scanx == K_MOUSE1)
			{ 
				// handle regardless
				return true;
			}
			if(scanx == K_UPARROW)
			{
				return true;
			}
			if(scanx == K_DOWNARROW)
			{
				return true;
			}
			if(scanx == K_LEFTARROW)
			{
				return true;
			}
			if(scanx == K_RIGHTARROW)
			{
				return true;
			}
			if(scanx == K_PGUP)
			{
				return true;
			}
			if(scanx == K_PGDN)
			{
				return true;
			}
			if(scanx == K_DEL)
			{
				return true;
			}

			if(scanx == K_ENTER)
				return true;

			if(scanx == K_MOUSE2 || scanx == K_ESCAPE)
			{
				champion_menu_close();
				return true;
			}

			if(scanx == K_MWHEELUP || scanx == K_MWHEELDOWN)
				return true; // don't handle on server
			break;
		case IE_KEYUP:
			if(scanx == K_ENTER)
			{
				champion_menu_select();
				return true;
			}

			if(scanx == K_MWHEELUP || scanx == K_MWHEELDOWN)
				return true; // don't handle on server
			break;
		case IE_MOUSEDELTA:
			break;
		case IE_MOUSEABS:
			break;
	}
	
	return false;
}
#endif
