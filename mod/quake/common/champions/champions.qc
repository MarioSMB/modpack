void QCC_FixClient(entity this)
{
#ifdef CSQC
	Champions champ = NULL;
	int mychamp = STAT(QCC_CHAMPION);
	FOREACH(Champion, it.m_id == mychamp,
	{
		champ = it;
		break;
	});
	this.m_champion = champ;
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

// hack needed
bool QCC_HasSpellbook(entity this)
{
#ifdef SVQC
	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(this.(weaponentity).m_weapon == WEP_SPELLBOOK)
			return true;
	}
#elif defined(CSQC)
	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		entity weaponentity = viewmodels[slot];
		if(weaponentity.activeweapon == WEP_SPELLBOOK)
			return true;
	}
#endif
	return false;
}

bool QCC_CanCastAbility(entity this)
{
	if(time < STAT(QCC_ABILITYTIME, this))
		return false;
	if(STAT(CANNON, this))
		return false;
	if(STAT(ITEMS, this) & IT_TANK)
		return false;
	if(STAT(CLOCKWORK, this))
		return false;
	if(this.m_transform)
		return false;
	if(QCC_HasSpellbook(this))
		return false;
	return true;
}

bool QCC_Allowed(entity this)
{
	if(STAT(ITEMS) & IT_TANK)
		return false;
	if(STAT(SLIDE_ON, this) || STAT(WORLDTYPE) == WORLDTYPE_SLIDE)
		return false;
	if(STAT(SKATING, this))
		return false;
	return true;
}

#ifdef SVQC
void QCC_ClearTransform(entity this)
{
	if(this.transform_prevhealth)
		this.health = this.transform_prevhealth;
	this.armortype = this.transform_armortype;
	this.armorvalue = this.transform_armorvalue;
	armor_set_type(this);
	this.transform_prevhealth = 0;
	this.transform_limited = 0;
	this.transform_armortype = 0;
	this.transform_armorvalue = 0;
	this.m_transform = NULL;
}

void QCC_ClearWeapons(entity this)
{
	STAT(WEAPONS, this) &= ~(WEPSET_CHAMPIONS);
	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_CHAMPION)
			W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
	}
}

void QCC_ClearPlayer(entity this, bool clearweapons)
{
	if(this.m_champion && this.m_champion.m_clear)
		this.m_champion.m_clear(this.m_champion, this);
	this.m_champion = NULL;
	STAT(QCC_CHAMPION, this) = 0;
	if(clearweapons)
		QCC_ClearWeapons(this);
}

void QCC_UpdateStats(entity this)
{
	if(intermission_running || !QCC_Allowed(this) || this.clockwork)
		return;

	if(this.m_champion)
	{
		if(autocvar_sv_quake_champions_custombbox)
		{
			STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = this.m_champion.m_viewofs;
			STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = this.m_champion.m_mins;
			STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = this.m_champion.m_maxs;

			if(this.mins != STAT(PL_MIN, this) || this.maxs != STAT(PL_MAX, this))
			{
				tracebox(this.origin, STAT(PL_MIN, this), STAT(PL_MAX, this), this.origin, MOVE_NORMAL, this);
				if (!trace_startsolid)
					setsize(this, STAT(PL_MIN, this), STAT(PL_MAX, this));
				else
				{
					STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = this.mins;
					STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = this.maxs;
				}
			}
		}

		if(this.m_champion.m_updatestats)
			this.m_champion.m_updatestats(this.m_champion, this);
	}
}

void QCC_UpdatePlayer(entity this)
{
	if(!QCC_Allowed(this) || this.clockwork)
		return;
	Champions oldchamp = this.m_champion;
	Champions champ = Champion_FromString(this.cvar_cl_quake_model);
	if(this.m_transform && this.transform_limited && time > this.transform_limited)
	{
		QCC_ClearTransform(this);
		// hard delay of weapons so you don't get stuck spamming!
		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			if(this.(weaponentity))
			{
				wep_set_anim(this.(weaponentity), 0, w_ready);
				ATTACK_FINISHED(this, weaponentity) = time + 1;
			}
		}
	}

	if(this.m_transform)
	{
		if(this.m_champion != this.m_transform)
		{
			if(this.transform_health)
			{
				this.transform_prevhealth = this.health;
				this.health = this.transform_health;
			}
			this.transform_armortype = this.armortype;
			this.transform_armorvalue = this.armorvalue;
			this.armortype = 0;
			this.armorvalue = 0;
			this.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}
		champ = this.m_transform;
	}
	else if(champ.qcc_noselect || (champ.m_condition && champ.m_condition(champ, this)))
		champ = CHAMPION_Ranger;

	STAT(QCC_CHAMPION, this) = champ.m_id;
	this.m_champion = champ;

	string newmdl = champ.m_model.model_str();
	if(newmdl != this.playermodel)
	{
		vector oldmin = this.mins, oldmax = this.maxs;
		this.playermodel = newmdl;
		_setmodel(this, newmdl);
		setsize(this, oldmin, oldmax);
		this.modelindex_player = this.modelindex;
		if(autocvar_sv_quake_champions_custombbox)
		{
			tracebox(this.origin, champ.m_mins, champ.m_maxs, this.origin, MOVE_NORMAL, this);
			if (!trace_startsolid)
				setsize(this, champ.m_mins, champ.m_maxs);
		}

		this.view_ofs = champ.m_viewofs;
		this.scale = champ.m_scale;

		if(champ != oldchamp)
		{
			QCC_ClearWeapons(this);
			if(oldchamp.m_clear)
				oldchamp.m_clear(oldchamp, this);
			if(champ.m_activate)
				champ.m_activate(champ, this);
		}
	}
}

void champions_PutPlayerInServer(entity this)
{
	this.playermodel = "";

	STAT(QCC_ABILITYTIME, this) = time + 0.5;

	QCC_UpdatePlayer(this);

	if(this.m_champion && this.m_champion.m_playerspawn)
		this.m_champion.m_playerspawn(this.m_champion, this);

	// TODO: special way for champions to always run their own code?
	Dusk_PlayerSpawn(this);
}

void champions_PlayerPreThink(entity this)
{
	if(this.clockwork)
		return;
	if(!QCC_Allowed(this))
	{
		QCC_ClearPlayer(this, true);
		return;
	}
	QCC_UpdatePlayer(this);

	if(this.m_champion && this.m_champion.m_playerthink)
		this.m_champion.m_playerthink(this.m_champion, this);
}

void champions_PlayerDies(entity this)
{
	// reset transformation state
	this.m_transform = NULL;
	this.transform_prevhealth = 0;
	this.transform_health = 0;
	this.transform_armortype = 0;
	this.transform_armorvalue = 0;

	if(this.m_champion && this.m_champion.m_clear)
		this.m_champion.m_clear(this.m_champion, this);
}

void champions_RemovePlayer(entity this)
{
	QCC_ClearPlayer(this, false);	
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
int champion_hovered_index = -1;

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

vector champion_info_scroll;
void champion_info_list(string id, vector pos, vector size)
{
	// by this point we know all the data is accurate
	Champions champ = champdata[champion_hovered_index];

	int linecount = tokenizebyseparator(champ.message, "\n");

	sui_fill(pos, size, '0.2 0.2 0.2', 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, vec2(size.x - 6, 16), linecount, '0 6 0');
	sui_pos = '0 0 0';
	//champion_hovered_index = -1;
	for(float index = sui_list_item(); index > -1; index = sui_list_item())
	{
		sui_push_frame(sui_pos, vec2(size.x - 6, 16));
		sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_CENTER));
		//if(selected_champion_index == index)
			//sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.2, 0);
		string text = argv(index);
		text = strreplace("%ABILITY%", getcommandkey("(Crouch)", "+crouch"), text);
		sui_drawtext('0 0 0', '8 8 0', text, '1 1 1', 1, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
}

void champion_menu_info(int index)
{
	Champions champ = champdata[index];
	if(!champ.message || champ.message == "")
		return;

	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_drawtext('300 -80 0', '10 10 0', "Champion Stats", '1 1 1', 1, 0);
	
	sui_fill('300 0 0', '4 4 0', '0 0 0', 0.5, 0);
	sui_fill('300 0 0', '2 2 0', '1 1 1', 0.75, 0);
	
	vector ent_menu_size = '300 150 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_push_frame('300 10 0', ent_menu_size);
	
	sui_fill('0 0 0', ent_menu_size, '0 0 0', 0.5, 0);
	sui_offset = champion_info_scroll;
	champion_info_list("champion_info_list", '0 0 0', ent_menu_size - '2 2 0');
	champion_info_scroll = sui_offset;
	
	sui_pop_frame();
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
	//champion_hovered_index = -1;
	for(float index = sui_list_item(); index > -1; index = sui_list_item())
	{
		sui_push_frame(sui_pos, vec2(size.x - 6, 16));
		string iid = strcat(id, ftos(index));
		sui_action_element('0 0 0', vec2(size.x -6, 16), iid);
		if(sui_is_hovered(iid))
		{
			champion_hovered_index = index;
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
	if(intermission || STAT(HEALTH) <= 0 || !QCC_Allowed(csqcplayer))
		return;
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_drawtext('0 -170 0', '16 16 0', "CHOOSE A CHAMPION", '0.3 1 0.3', 1, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_fill('0 0 0', '4 4 0', '0 0 0', 0.5, 0);
	sui_fill('0 0 0', '2 2 0', '1 1 1', 0.75, 0);
	
	vector ent_menu_size = '230 260 0'; // NOTE: update y value by at least 10 when adding new champions!
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_push_frame('0 0 0', ent_menu_size);
	
	sui_fill('0 0 0', ent_menu_size, '0 0 0', 0.5, 0);
	sui_offset = champion_menu_scroll;
	champion_menu_list("champion_menu_list", '0 0 0', ent_menu_size - '2 2 0');
	champion_menu_scroll = sui_offset;
	
	sui_pop_frame();

	if(champion_hovered_index != -1)
		champion_menu_info(champion_hovered_index);
}

void champion_menu_open()
{
	selected_champion_index = 0;
	champion_hovered_index = -1;
	cursor_active |= GUI_OPEN_CHAMPIONS;
	setcursormode(cursor_active);
}

void champion_menu_close()
{
	selected_champion_index = 0;
	champion_hovered_index = -1;
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
