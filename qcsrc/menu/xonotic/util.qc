float GL_CheckExtension(string ext)
{
	return (strstrofs(strcat(" ", cvar_string("gl_info_extensions"), " "), strcat(" ", ext, " "), 0) >= 0);
}

float GL_Have_TextureCompression()
{
	return (GL_CheckExtension("GL_EXT_texture_compression_s3tc") && GL_CheckExtension("GL_ARB_texture_compression"));
}

void loadTooltips()
{
	tooltipdb = db_load(language_filename("tooltips.db"));
}
void unloadTooltips()
{
	if(tooltipdb >= 0)
		db_close(tooltipdb);
	tooltipdb = -1;
}
string getZonedTooltipForIdentifier(string s)
{
	string t;
	if(s == "")
		return string_null;
	if(tooltipdb >= 0)
	{
		t = db_get(tooltipdb, s);
		if(t == "-")
			return string_null;
		if(t != "")
			return strzone(t);
	}
	if(prvm_language == "en")
	{
		t = cvar_description(s);
		if(t != "" && t != "custom cvar")
			return strzone(t);
	}
	dprint("WARNING: no tooltip set for ", s, "\n");
	return string_null;
}

void forAllDescendants(entity root, void(entity, entity) funcPre, void(entity, entity) funcPost, entity pass)
{
	depthfirst(root, parent, firstChild, nextSibling, funcPre, funcPost, pass);
}

.string cvarName;
void SUB_Null_ee(entity e1, entity e2)
{
}
void saveCvarsOf(entity ignore, entity e)
{
	if(e.saveCvars)
		e.saveCvars(e);
}
void loadCvarsOf(entity ignore, entity e)
{
	if(e.loadCvars)
		e.loadCvars(e);
}
void saveAllCvars(entity root)
{
	forAllDescendants(root, saveCvarsOf, SUB_Null_ee, NULL);
}
void loadAllCvars(entity root)
{
	forAllDescendants(root, loadCvarsOf, SUB_Null_ee, NULL);
}

.string cvarNames_Multi;
.void(entity me) saveCvars_Multi;
string getCvarsMulti(entity me)
{
	if (me.cvarNames_Multi)
		return me.cvarNames_Multi;
	return string_null;
}
void saveCvarsMulti(entity me)
{
	float n, i;
	string s;

	me.saveCvars_Multi(me);
	s = cvar_string(me.cvarName);

	n = tokenize_console(me.cvarNames_Multi);
	for(i = 0; i < n; ++i)
		cvar_set(argv(i), s);
}
void makeMulti(entity e, string otherCvars)
{
	e.cvarNames_Multi = otherCvars;
	e.saveCvars_Multi = e.saveCvars;
	e.saveCvars = saveCvarsMulti;
}

.void(entity me) saveCvars_Callback;
.entity saveCvars_Callback_ent;
.void(entity me, entity cb) saveCvars_Callback_func;
void saveCvarsCallback(entity me)
{
	me.saveCvars_Callback(me);
	me.saveCvars_Callback_func(me.saveCvars_Callback_ent, me);
}
void makeCallback(entity e, entity cbent, void(entity, entity) cbfunc)
{
	e.saveCvars_Callback = e.saveCvars;
	e.saveCvars = saveCvarsCallback;
	e.saveCvars_Callback_ent = cbent;
	e.saveCvars_Callback_func = cbfunc;
}

.void(entity) draw_setDependent;
.string cvar_setDependent;
.float cvarMin_setDependent;
.float cvarMax_setDependent;
.string cvar2_setDependent;
.float cvar2Min_setDependent;
.float cvar2Max_setDependent;
.string cvar3_setDependent;
.float cvar3Min_setDependent;
.float cvar3Max_setDependent;
.float op_setDependent;
.string cvarString_setDependent;
.string cvarValue_setDependent;
.float(entity) func_setDependent;
void setDependent_Check(entity e)
{
	float f;
	string s;
	if(e.func_setDependent)
	{
		e.disabled = !(e.func_setDependent(e));
	}
	else if(e.cvarString_setDependent)
	{
		s = cvar_string(e.cvarString_setDependent);
		e.disabled = (cvar_string(e.cvarString_setDependent) == e.cvarValue_setDependent);
	}
	else
	{
		if(e.cvar_setDependent)
		{
			f = cvar(e.cvar_setDependent);
			if(e.cvarMin_setDependent <= e.cvarMax_setDependent)
				e.disabled = ((f < e.cvarMin_setDependent) || (f > e.cvarMax_setDependent));
			else
				e.disabled = ((f >= e.cvarMax_setDependent) && (f <= e.cvarMin_setDependent));
		}
		if(e.cvar2_setDependent)
		{
			f = cvar(e.cvar2_setDependent);
			if(e.cvar2Min_setDependent <= e.cvar2Max_setDependent)
				e.disabled = (e.disabled + ((f < e.cvar2Min_setDependent) || (f > e.cvar2Max_setDependent)) > e.op_setDependent);
			else
				e.disabled = (e.disabled + ((f >= e.cvar2Max_setDependent) && (f <= e.cvar2Min_setDependent)) > e.op_setDependent);
		}
		if(e.cvar3_setDependent)
		{
			f = cvar(e.cvar3_setDependent);
			if(e.cvar3Min_setDependent <= e.cvar3Max_setDependent)
				e.disabled = (e.disabled + ((f < e.cvar3Min_setDependent) || (f > e.cvar3Max_setDependent)) > e.op_setDependent);
			else
				e.disabled = (e.disabled + ((f >= e.cvar3Max_setDependent) && (f <= e.cvar3Min_setDependent)) > e.op_setDependent);
		}
	}
}
void setDependent_Draw(entity e)
{
	setDependent_Check(e);
	e.draw_setDependent(e);
}
void setDependent(entity e, string theCvarName, float theCvarMin, float theCvarMax)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = string_null;
	e.cvar3_setDependent = string_null;
	e.func_setDependent = func_null;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentStringNotEqual(entity e, string theCvarName, string theCvarValue)
{
	e.draw_setDependent = e.draw;
	e.cvarString_setDependent = theCvarName;
	e.cvarValue_setDependent = theCvarValue;
	e.cvar_setDependent = string_null;
	e.cvar2_setDependent = string_null;
	e.cvar3_setDependent = string_null;
	e.func_setDependent = func_null;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentAND(entity e, string theCvarName, float theCvarMin, float theCvarMax, string theCvar2Name, float theCvar2Min, float theCvar2Max)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = theCvar2Name;
	e.cvar2Min_setDependent = theCvar2Min;
	e.cvar2Max_setDependent = theCvar2Max;
	e.cvar3_setDependent = string_null;
	e.op_setDependent = 0;
	e.func_setDependent = func_null;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentOR(entity e, string theCvarName, float theCvarMin, float theCvarMax, string theCvar2Name, float theCvar2Min, float theCvar2Max)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = theCvar2Name;
	e.cvar2Min_setDependent = theCvar2Min;
	e.cvar2Max_setDependent = theCvar2Max;
	e.cvar3_setDependent = string_null;
	e.op_setDependent = 1;
	e.func_setDependent = func_null;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentAND3(entity e, string theCvarName, float theCvarMin, float theCvarMax, string theCvar2Name, float theCvar2Min, float theCvar2Max, string theCvar3Name, float theCvar3Min, float theCvar3Max)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = theCvar2Name;
	e.cvar2Min_setDependent = theCvar2Min;
	e.cvar2Max_setDependent = theCvar2Max;
	e.cvar3_setDependent = theCvar3Name;
	e.cvar3Min_setDependent = theCvar3Min;
	e.cvar3Max_setDependent = theCvar3Max;
	e.op_setDependent = 0;
	e.func_setDependent = func_null;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentWeird(entity e, float(entity) func)
{
	e.draw_setDependent = e.draw;
	e.func_setDependent = func;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}

// URI SYSTEM ////////////////////////////////////////////////////////

float _Nex_ExtResponseSystem_Queried;
string _Nex_ExtResponseSystem_UpdateTo;
string _Nex_ExtResponseSystem_UpdateToURL;
string _Nex_ExtResponseSystem_Packs;
float _Nex_ExtResponseSystem_PacksStep;

void URI_Get_Callback(float id, float status, string data)
{
	if(url_URI_Get_Callback(id, status, data))
	{
		// handled
	}
	else if (id == URI_GET_DISCARD)
	{
		// discard
	}
	else if (id >= URI_GET_CURL && id <= URI_GET_CURL_END)
	{
		// sv_cmd curl
		Curl_URI_Get_Callback(id, status, data);
	}
	else if (id == URI_GET_UPDATENOTIFICATION)
	{
		UpdateNotification_URI_Get_Callback(id, status, data);
	}
	else
	{
		print(sprintf("Received HTTP request data for an invalid id %d.\n", id));
	}
}

void UpdateNotification_URI_Get_Callback(float id, float status, string data)
{
	float n;

	if(_Nex_ExtResponseSystem_UpdateTo)
	{
		dprint("error: UpdateNotification_URI_Get_Callback has been called before\n");
		return;
	}
	if(status != 0)
	{
		print(sprintf(_("error receiving update notification: status is %d\n"), status));
		return;
	}
	if(substring(data, 0, 1) == "<")
	{
		print(_("error: received HTML instead of an update notification\n"));
		return;
	}
	if(strstrofs(data, "\r", 0) != -1)
	{
		print(_("error: received carriage returns from update notification server\n"));
		return;
	}

	if(data == "")
		n = 0;
	else
		n = tokenizebyseparator(data, "\n");
	
	if(n >= 1)
	{
		_Nex_ExtResponseSystem_UpdateTo = argv(0);

		if(vercmp(cvar_string("g_xonoticversion"), _Nex_ExtResponseSystem_UpdateTo) >= 0)
		{
			_Nex_ExtResponseSystem_UpdateTo = ""; // no update needed
		}
		else
		{
			// update needed
			if(n >= 2)
				print(sprintf(_("Update can be downloaded at:\n%s\n"), argv(1)));
			if(n >= 3)
				_Nex_ExtResponseSystem_UpdateToURL = strzone(argv(2));
		}

		_Nex_ExtResponseSystem_UpdateTo = strzone(_Nex_ExtResponseSystem_UpdateTo);

		if(n >= 4)
		{
			_Nex_ExtResponseSystem_BannedServers = strzone(argv(3));
			_Nex_ExtResponseSystem_BannedServersNeedsRefresh = 1;
		}

		if(n >= 5)
		{
			if(cvar("menu_updatecheck_getpacks"))
			{
				_Nex_ExtResponseSystem_Packs = strzone(argv(4));
				_Nex_ExtResponseSystem_PacksStep = 1;
			}
		}
	}
}

// END OF URI SYSTEM ////////////////////////////////////////////////////////

void updateCheck()
{
	if(cvar("menu_updatecheck"))
	{
		if(!_Nex_ExtResponseSystem_Queried)
		{
			_Nex_ExtResponseSystem_Queried = 1;
			float startcnt;
			string uri;

			cvar_set("cl_startcount", ftos(startcnt = cvar("cl_startcount") + 1));

			// for privacy, munge the start count a little
			startcnt = floor((floor(startcnt / 10) + random()) * 10);
			uri = sprintf("http://www.xonotic.org/dl/checkupdate.txt?version=%s&cnt=%d", uri_escape(cvar_string("g_xonoticversion")), startcnt);

#ifdef CVAR_POPCON
			float cvar_handle, popcon_handle;
			float n, i, j;
			string k, s;
			cvar_handle = buf_create();
			buf_cvarlist(cvar_handle, "", "");
			n = buf_getsize(cvar_handle);
			popcon_handle = buf_create();
			for(i= 0, j = 0; i < n; ++i)
			{
				k = bufstr_get(cvar_handle, i);
				if(!(cvar_type(k) & CVAR_TYPEFLAG_SAVED))
					continue;
				s = sprintf("%s=%d", uri_escape(k), cvar_string(k) != cvar_defstring(k));
				bufstr_set(popcon_handle, j, s);
				++j;
			}
			buf_del(cvar_handle);
			uri_postbuf(
				uri, URI_GET_UPDATENOTIFICATION,
				"application/x-www-form-urlencoded",
				"&",
				popcon_handle
			);
			buf_del(popcon_handle);
#else
			uri_get(uri, URI_GET_UPDATENOTIFICATION);
#endif
		}
	}

	if(_Nex_ExtResponseSystem_PacksStep > 0)
	{
		float n, i;
		float allgood;
		n = tokenize_console(_Nex_ExtResponseSystem_Packs);
		allgood = TRUE;
		for(i = 0; i+1 < n; i += 2)
		{
			if(fexists(argv(i+1)))
				continue;
			allgood = FALSE;
			if(_Nex_ExtResponseSystem_PacksStep == 1) // first run
				localcmd("\ncurl --pak \"", argv(i), "\"\n");
		}
		if(allgood)
		{
			if(_Nex_ExtResponseSystem_PacksStep == 2)
			{
				if(!Menu_Active)
					cvar_set("_menu_initialized", "0");
					// HACK: cause m_hide call on next start
				localcmd("\nmenu_restart\n");
			}
			_Nex_ExtResponseSystem_PacksStep = 0;
		}
		else
			_Nex_ExtResponseSystem_PacksStep = 2;
	}

}

float preMenuInit()
{
	vector sz;
	vector boxA, boxB;

	updateCheck();

	MapInfo_Cache_Create();
	MapInfo_Enumerate();
	if(!MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 0, 0, 1))
	{
		draw_reset_cropped();

		sz = eX * 0.025 + eY * 0.025 * (draw_scale_x / draw_scale_y);
		draw_CenterText('0.5 0.5 0' - 1.25 * sz_y * eY, _("Autogenerating mapinfo for newly added maps..."), sz, '1 1 1', 1, 0);

		boxA = '0.05 0.5 0' + 0.25 * sz_y * eY;
		boxB = '0.95 0.5 0' + 1.25 * sz_y * eY;
		draw_Fill(boxA, boxB - boxA, '1 1 1', 1);
		
		boxA += sz * 0.1;
		boxB -= sz * 0.1;
		draw_Fill(boxA, boxB - boxA, '0.1 0.1 0.1', 1);

		boxB_x = boxA_x * (1 - MapInfo_progress) + boxB_x * MapInfo_progress;
		draw_Fill(boxA, boxB - boxA, '0 0 1', 1);

		return FALSE;
	}
	return TRUE;
}

string campaign_name_previous;
float campaign_won_previous;
#ifdef WATERMARK
var string autocvar_menu_watermark = WATERMARK;
#else
var string autocvar_menu_watermark = "";
#endif
void postMenuDraw()
{
	if(autocvar_menu_watermark != "")
	{
		draw_CenterText('0.5 0.1 0', sprintf(_("^1%s TEST BUILD"), autocvar_menu_watermark), globalToBoxSize('32 32 0', draw_scale), '1 1 1', 0.05, 1);
	}
}
void preMenuDraw()
{
	vector fs, sz = '0 0 0', line, mid;

	updateCheck();

	if(_Nex_ExtResponseSystem_UpdateTo != "")
	{
		// TODO rather turn this into a dialog
		fs = ((1/draw_scale_x) * eX + (1/draw_scale_y) * eY) * 12;
		line = eY * fs_y;
		string l1, l2;
		l1 = sprintf(_("Update to %s now!"), _Nex_ExtResponseSystem_UpdateTo);
		l2 = "http://www.xonotic.org/";
		if(_Nex_ExtResponseSystem_UpdateToURL)
			l2 = _Nex_ExtResponseSystem_UpdateToURL;

		sz_x = draw_TextWidth("    ", 0, fs) + max(
				draw_TextWidth(l1, 0, fs),
				draw_TextWidth(l2, 0, fs)
			);
		sz_y = 3 * fs_y;

		draw_alpha = bound(0, sin(time * 0.112 - 0.3) * 10, 1);
		mid = eX * (0.5 + 0.5 * (1 - sz_x) * cos(time * 0.071))
		    + eY * (0.5 + 0.5 * (1 - sz_y) * sin(time * 0.071));

		draw_Fill(mid - 0.5 * sz, sz, '1 1 0', 1);
		draw_CenterText(mid - 1 * line, l1, fs, '1 0 0', 1, 0);
		draw_CenterText(mid - 0 * line, l2, fs, '0 0 1', 1, 0);
	}
	if not(campaign_name_previous)
		campaign_name_previous = strzone(strcat(campaign_name, "x")); // force unequal
	if(campaign_name == campaign_name_previous)
	{
		if(cvar(strcat("g_campaign", campaign_name, "_won")))
		{
			if(!campaign_won_previous)
			{
				m_display();
				DialogOpenButton_Click_withCoords(NULL, main.winnerDialog, '0 0 0', eX * conwidth + eY * conheight);
			}
			campaign_won_previous = 1;
		}
		else
			campaign_won_previous = 0;
	}
	else
	{
		strunzone(campaign_name_previous);
		campaign_name_previous = strzone(campaign_name);
		campaign_won_previous = cvar(strcat("g_campaign", campaign_name, "_won"));
	}
}

string resolvemod(string m)
{
	if(m == "=")
		return getcurrentmod();
	else
		return m;
}

float updateCompression()
{
	float have_dds, have_jpg, have_tga;
	float can_dds;
	have_dds = (fexists("dds/particles/particlefont.dds"));
	have_jpg = (fexists("particles/particlefont.jpg"));
	have_tga = (fexists("particles/particlefont.tga"));
	can_dds = GL_Have_TextureCompression();
	if(have_dds && (have_jpg || have_tga))
	{
		// both? Let's only use good quality precompressed files
		// but ONLY if we actually support it!
		if(can_dds)
		{
			// these builds are meant to have GOOD quality, so let's not compress non-skinframes
			cvar_set("gl_texturecompression", "0");
			return 1;

			//cvar_set("gl_texturecompression", cvar_string("r_texture_dds_load"));
			//return 2;
		}
		else
		{
			cvar_set("gl_texturecompression", "0");
			cvar_set("r_texture_dds_load", "0");
			return 0;
		}
	}
	else if(have_dds)
	{
		// DDS only? We probably always want texture compression
		cvar_set("gl_texturecompression", "1");
		cvar_set("r_texture_dds_load", "1");
		if(!can_dds)
			print(_("^1ERROR: Texture compression is required but not supported.\n^1Expect visual problems.\n"));
		return 0;
	}
	else
	{
		// TGA only? Allow runtime compression
		if(can_dds)
		{
			cvar_set("gl_texturecompression", cvar_string("r_texture_dds_load"));
			return 2;
		}
		else
		{
			cvar_set("gl_texturecompression", "0");
			cvar_set("r_texture_dds_load", "0");
			return 0;
		}
	}
}

// note: include only those that should be in the menu!
#define GAMETYPES \
	GAMETYPE(MAPINFO_TYPE_ARENA) \
	GAMETYPE(MAPINFO_TYPE_ASSAULT) \
	GAMETYPE(MAPINFO_TYPE_CTF) \
	GAMETYPE(MAPINFO_TYPE_CA) \
	GAMETYPE(MAPINFO_TYPE_DEATHMATCH) \
	GAMETYPE(MAPINFO_TYPE_DOMINATION) \
	GAMETYPE(MAPINFO_TYPE_FREEZETAG) \
	GAMETYPE(MAPINFO_TYPE_KEEPAWAY) \
	GAMETYPE(MAPINFO_TYPE_KEYHUNT) \
	GAMETYPE(MAPINFO_TYPE_LMS) \
	GAMETYPE(MAPINFO_TYPE_NEXBALL) \
	GAMETYPE(MAPINFO_TYPE_ONSLAUGHT) \
	GAMETYPE(MAPINFO_TYPE_RACE) \
	GAMETYPE(MAPINFO_TYPE_CTS) \
	GAMETYPE(MAPINFO_TYPE_TEAM_DEATHMATCH) \
	/* nothing */

float GameType_GetID(float cnt)
{
	float i;
	i = 0;
	
	#define GAMETYPE(id) if(i++ == cnt) return id;
	GAMETYPES
	#undef GAMETYPE

	unused_float = i;
	
	return 0;
}

float GameType_GetCount()
{
	float i;
	i = 0;
	
	#define GAMETYPE(id) ++i;
	GAMETYPES
	#undef GAMETYPE
	
	return i;
}

string GameType_GetName(float cnt)
{
	float i = GameType_GetID(cnt);
	
	if(i)
		return MapInfo_Type_ToText(i);
	
	return "";
}

string GameType_GetIcon(float cnt)
{
	float i = GameType_GetID(cnt);
	
	if(i)
		return strcat("gametype_", MapInfo_Type_ToString(i));
	
	return "";
}

/*string GameType_GetTeams(float cnt) // poor implementation, later something else could be done that's better?
{
	float i = GameType_GetID(cnt);
	string s = _MapInfo_GetDefaultEx(i);
	
	if(i)
	{
		if(strstrofs(s, "teams", 0) >= 0)
			return _("teamplay");
		else
			return _("free for all");
	}
	
	return _("tuba for all");
}*/

void dialog_hudpanel_common_notoggle(entity me, string panelname)
{
	float i;
	entity e;

	me.TR(me);
		me.TD(me, 1, 1.4, e = makeXonoticTextLabel(0, _("Background:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider(strzone(strcat("hud_panel_", panelname, "_bg"))));
				e.addValue(e, _("Default"), "");
				e.addValue(e, _("Disable"), "0");
				e.addValue(e, strzone(strcat("border_", panelname)), strzone(strcat("border_", panelname)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Color:")));
		me.TD(me, 2, 2.6, e = makeXonoticColorpickerString(strzone(strcat("hud_panel_", panelname, "_bg_color")), "hud_panel_bg_color"));
			setDependentStringNotEqual(e, strzone(strcat("hud_panel_", panelname, "_bg_color")), "");
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticCheckBoxString("", "1 1 1", strzone(strcat("hud_panel_", panelname, "_bg_color")), _("Use default")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Border size:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider(strzone(strcat("hud_panel_", panelname, "_bg_border"))));
				e.addValue(e, _("Default"), "");
				e.addValue(e, _("Disable"), "0");
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i * 2, 0)), strzone(ftos(i * 2)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Alpha:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider(strzone(strcat("hud_panel_", panelname, "_bg_alpha"))));
				e.addValue(e, _("Default"), "");
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i/10, 1)), strzone(ftos(i/10)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Team Color:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider(strzone(strcat("hud_panel_", panelname, "_bg_color_team"))));
				e.addValue(e, _("Default"), "");
				e.addValue(e, _("Disable"), "0");
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i/10, 1)), strzone(ftos(i/10)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 3.6, e = makeXonoticCheckBox(0, "hud_configure_teamcolorforced", _("Test team color in configure mode")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Padding:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider(strzone(strcat("hud_panel_", panelname, "_bg_padding"))));
				e.addValue(e, _("Default"), "");
				for(i = 0; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i - 5, 0)), strzone(ftos(i - 5)));
				e.configureXonoticTextSliderValues(e);
}
