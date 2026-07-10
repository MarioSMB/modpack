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
	if(STAT(SLIDE_ON, this) || gametype == GAMETYPE_SLIDE)
		return false;
	if(STAT(SKATING, this))
		return false;
	if(gametype == GAMETYPE_DODGEBALL)
		return false;
	if(Challenge_Active(CHALLENGE_BONK))
		return false;
	if(gametype == GAMETYPE_JUMPSDONEWELL)
		return false;
	return true;
}

#ifdef SVQC
void QCC_ClearTransform(entity this)
{
	if(this.m_transform)
	{
		if(this.transform_prevhealth)
			this.health = max(1, rint(this.transform_prevhealth));
		this.armortype = this.transform_armortype;
		this.armorvalue = this.transform_armorvalue;

		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			if(this.(weaponentity))
			{
				Weapon wep = this.(weaponentity).transform_weapon;

				if(wep && wep != WEP_Null && wep != this.(weaponentity).m_weapon && client_hasweapon(this, wep, weaponentity, true, false))
					W_SwitchWeapon_Force(this, wep, weaponentity);
				if(this.(weaponentity).transform_prevweapon != 0)
					this.(weaponentity).cnt = this.(weaponentity).transform_prevweapon;
			}
		}
	}
	this.transform_health = 0;
	this.transform_prevhealth = 0;
	this.transform_limited = 0;
	this.transform_armortype = ARMOR_NONE;
	this.transform_armorvalue = 0;
	this.m_transform = NULL;

	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(this.(weaponentity))
		{
			this.(weaponentity).transform_weapon = WEP_Null;
			this.(weaponentity).transform_prevweapon = 0;
		}
	}
}

void QCC_ClearWeapons(entity this)
{
	td_BuildMode_Clear(this);

	FOREACH(Weapons, (it.spawnflags & WEP_FLAG_CHAMPION) && Inventory_have(it, this, ITEM_OWNED),
	{
		Inventory_remove(it, this, ITEM_OWNED);
	});
	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		Weapon wep = this.(weaponentity).m_weapon;
		if((wep.spawnflags & WEP_FLAG_CHAMPION) || !client_hasweapon(this, wep, weaponentity, true, false))
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
	if(intermission_running || !QCC_Allowed(this) || this.clockwork || this.exptime != 0 || this.deadflag >= DEAD_DEAD || this.health <= 0)
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

void QCC_SavePlayer(entity targ, entity inflictor, entity attacker, int deathtype)
{
	if(targ.m_transform)
	{
		QCC_ClearTransform(targ);
		QCC_UpdatePlayer(targ);
		// hard delay of weapons so you don't get stuck spamming!
		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			if(targ.(weaponentity))
			{
				wep_set_anim(targ.(weaponentity), 0, w_ready);
				ATTACK_FINISHED(targ, weaponentity) = time + 1;
			}
		}

		STAT(QCC_ABILITYTIME, targ) = max(STAT(QCC_ABILITYTIME, targ), time + 2);
	}

	if(targ.m_champion && targ.m_champion.m_saveplayer)
		targ.m_champion.m_saveplayer(targ.m_champion, targ, inflictor, attacker, deathtype);
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
				if(Challenge_Active(CHALLENGE_ONEHP))
					this.health = 1;
			}
			this.transform_armortype = this.armortype;
			this.transform_armorvalue = this.armorvalue;
			this.armortype = ARMOR_NONE;
			this.armorvalue = 0;

			for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
			{
				.entity weaponentity = weaponentities[slot];
				if(this.(weaponentity))
				{
					this.(weaponentity).transform_weapon = this.(weaponentity).m_weapon;
					this.(weaponentity).transform_prevweapon = this.(weaponentity).cnt;

					wep_set_anim(this.(weaponentity), 0, w_ready);
					ATTACK_FINISHED(this, weaponentity) = time + 0.5;
				}
			}
		}
		champ = this.m_transform;
	}
	else if(gametype == GAMETYPE_INSTAGIB)
		champ = CHAMPION_V1;
	else if(champ.qcc_noselect || (champ.m_condition && champ.m_condition(champ, this)))
		champ = CHAMPION_Ranger;

	STAT(QCC_CHAMPION, this) = champ.m_id;
	this.m_champion = champ;

	string newmdl;
	if(champ.m_getplayermodel)
		newmdl = champ.m_getplayermodel(champ, this);
	else
		newmdl = champ.m_model.model_str();; // unused fallback
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
		this.skin = champ.m_skin;

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
	this.transform_armortype = ARMOR_NONE;
	this.transform_armorvalue = 0;

	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(this.(weaponentity))
		{
			this.(weaponentity).transform_weapon = WEP_Null;
			this.(weaponentity).transform_prevweapon = 0;
		}
	}

	if(this.m_champion && this.m_champion.m_clear)
		this.m_champion.m_clear(this.m_champion, this);

	// TODO: generic handler
	W_Star_Clear(this);
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

entity champion_model;

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

vector Champion_Color(int index)
{
	Champions champ = champdata[index];
	return (champ.m_color != '0 0 0') ? champ.m_color : '1 1 1';
}

void champion_model_draw(entity this)
{
	int dmask = MASK_NORMAL;
	if(intermission || STAT(HEALTH) <= 0 || !QCC_Allowed(csqcplayer))
		dmask = 0;
	this.drawmask = dmask;

	if(!dmask)
		return;

	Champions champ;
	if(champion_hovered_index != -1)
		champ = champdata[champion_hovered_index];
	else
		champ = (csqcplayer) ? csqcplayer.m_champion : Champion_FromString(autocvar_cl_quake_model);
	if(champ != this.m_champion)
	{
		this.m_champion = champ;
		setmodel(this, champ.m_model);
		setsize(this, '0 0 0', '0 0 0');
	}

	int fx = EF_FULLBRIGHT | EF_NODEPTHTEST;
	this.csqcmodel_effects = fx;
	CSQCModel_Effects_Apply(this);

	// do this without MF_ROTATE to avoid overlapping
	this.angles += this.avelocity * frametime;

#if 1
	vector ent_menu_size = '200 200 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_push_frame('-128 64 0', ent_menu_size);
	vector pos = sui_transform_box('0 64 0', ent_menu_size);
	sui_pop_frame();

	vector near = cs_unproject(vec3(pos.x, pos.y, 0));
	vector far = cs_unproject(vec3(pos.x, pos.y, 1));

	vector dir = normalize(far - near);

	float depth = 128;
	vector mpos = near + (dir * depth);
#else
	vector mpos = view_origin + view_forward * 128 + view_right * 64 + view_up * -16;
#endif

	setorigin(this, mpos);
	//this.angles = view_angles;
}

void champion_model_create()
{
	if(champion_model)
		return; // ???

	entity ent = spawn();
	ent.classname = "champion_model";
	ent.drawmask = MASK_NORMAL;
	ent.draw = champion_model_draw;
	ent.alpha = 1;
	ent.colormap = 255;
	ent.colormap |= BIT(10); // RENDER_COLORMAPPED
	IL_PUSH(g_drawables, ent);
	set_movetype(ent, MOVETYPE_NONE);
	ent.avelocity = '0 100 0';

	champion_model = ent;
}

void champion_model_clear()
{
	if(champion_model)
		delete(champion_model);
	champion_model = NULL;
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
		sui_drawtext('0 0 0', '16 16 0', text, '1 1 1', 1, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
}

void champion_menu_info(int index)
{
	Champions champ = champdata[index];
	if(!champ.message || champ.message == "")
		return;
	
	vector ent_menu_size = '300 200 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_push_frame('300 10 0', ent_menu_size);

	drawfont = 8 + 2;
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext('0 -32 0', '18 18 0', "Champion Stats", '1 1 1', 1, 0);
	drawfont = 8 + 1;
	
	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_START));
	sui_fill('0 0 0', ent_menu_size, '0 0 0', 0.5, 0);
	sui_offset = champion_info_scroll;
	champion_info_list("champion_info_list", '0 0 0', ent_menu_size - '2 2 0');
	champion_info_scroll = sui_offset;
	
	sui_pop_frame();
}

void champion_menu_list(string id, vector pos, vector size)
{
	// we don't need to build this dynamically...
	for(int j = 0; j < REGISTRY_MAX(Champion); ++j)
	{
		champdata[j] = NULL;
	}
	int champcount = 0;
	int current_champ = -1;
	FOREACH(Champion, !it.m_hidden,
	{
		champdata[champcount] = it;
		if(it.netname == autocvar_cl_quake_model)
			current_champ = champcount;
		champcount += 1;
	});

	if(champion_hovered_index == -1)
		champion_hovered_index = current_champ;

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
		sui_drawtext('0 0 0', '16 16 0', Champion_PrettyName(index), Champion_Color(index), 1, 0);
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

	float oldfont = drawfont;

	vector ent_menu_size = '200 300 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_push_frame('0 0 0', ent_menu_size);

	drawfont = 8 + 2;
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext('0 -32 0', '20 20 0', "CHOOSE A CHAMPION", '0.3 1 0.3', 1, 0);
	drawfont = 8 + 1;
	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_START));
	
	sui_fill('0 0 0', ent_menu_size, '0 0 0', 0.5, 0);
	sui_offset = champion_menu_scroll;
	champion_menu_list("champion_menu_list", '0 0 0', ent_menu_size - '2 2 0');
	champion_menu_scroll = sui_offset;
	
	sui_pop_frame();

	if(champion_hovered_index != -1)
		champion_menu_info(champion_hovered_index);

	drawfont = oldfont;
}

void champion_menu_open()
{
	selected_champion_index = 0;
	champion_hovered_index = -1;
	cursor_active |= GUI_OPEN_CHAMPIONS;
	setcursormode(cursor_active);

	champion_model_create();

	vote_menu_reset();
}

void champion_menu_close()
{
	selected_champion_index = 0;
	champion_hovered_index = -1;
	cursor_active &= ~GUI_OPEN_CHAMPIONS;
	setcursormode(cursor_active);

	champion_model_clear();

	vote_menu_reset();
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

// HUD elements for champions
#ifdef CSQC
void DrawChampionNotice()
{
	float oldfont = drawfont; // since this is a modern panel, it can use modern fonts
	drawfont = 8; // FONT_USER

	vector panel_pos = vec2(0.45 * vid_conwidth, 0.85 * vid_conheight);
	vector panel_size = vec2(0.09 * vid_conwidth, 0.09 * vid_conheight);

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	// always force 3:1 aspect
	vector newSize = '0 0 0';
	if(mySize.x/mySize.y > 3)
	{
		newSize.x = 3 * mySize.y;
		newSize.y = mySize.y;

		pos.x = pos.x + (mySize.x - newSize.x) / 2;
	}
	else
	{
		newSize.y = 1/3 * mySize.x;
		newSize.x = mySize.x;

		pos.y = pos.y + (mySize.y - newSize.y) / 2;
	}
	mySize = newSize;

	string s;
	s = sprintf(_("Champion: %s"), csqcplayer.m_champion.m_name);
	drawstring_aspect(pos, s, vec2(mySize.x, (2/8) * mySize.y), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	s = sprintf(_("Press %s to swap"), getcommandkey(_("quickmenu"), "quickmenu"));
	drawstring_aspect(pos + eY * (4/8) * mySize.y, s, vec2(mySize.x, (2/8) * mySize.y), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}

entity oldchampion;
float champion_messagetime;
void HUD_Champions()
{
	if(autocvar_r_letterbox)
		return;

	if(csqcplayer && csqcplayer.m_champion != oldchampion && !csqcplayer.m_champion.qcc_noselect)
	{
		oldchampion = csqcplayer.m_champion;
		champion_messagetime = time + 6;
	}
	if(csqcplayer && csqcplayer.m_champion && csqcplayer.m_champion.m_overlay)
		csqcplayer.m_champion.m_overlay(csqcplayer.m_champion);

	if(csqcplayer.m_champion && time < champion_messagetime)
	{
		DrawChampionNotice();
	}
}

void champions_DrawWorld()
{
	if(csqcplayer && csqcplayer.m_champion && csqcplayer.m_champion.m_drawworld)
		csqcplayer.m_champion.m_drawworld(csqcplayer.m_champion);
}
#endif
