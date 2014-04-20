#ifdef INTERFACE
CLASS(XonoticServerList) EXTENDS(XonoticListBox)
	METHOD(XonoticServerList, configureXonoticServerList, void(entity))
	ATTRIB(XonoticServerList, rowsPerItem, float, 1)
	METHOD(XonoticServerList, draw, void(entity))
	METHOD(XonoticServerList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticServerList, clickListBoxItem, void(entity, float, vector))
	METHOD(XonoticServerList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticServerList, keyDown, float(entity, float, float, float))
	METHOD(XonoticServerList, toggleFavorite, void(entity, string))

	ATTRIB(XonoticServerList, iconsSizeFactor, float, 0.85)

	ATTRIB(XonoticServerList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticServerList, realUpperMargin, float, 0)
	ATTRIB(XonoticServerList, columnIconsOrigin, float, 0)
	ATTRIB(XonoticServerList, columnIconsSize, float, 0)
	ATTRIB(XonoticServerList, columnPingOrigin, float, 0)
	ATTRIB(XonoticServerList, columnPingSize, float, 0)
	ATTRIB(XonoticServerList, columnNameOrigin, float, 0)
	ATTRIB(XonoticServerList, columnNameSize, float, 0)
	ATTRIB(XonoticServerList, columnMapOrigin, float, 0)
	ATTRIB(XonoticServerList, columnMapSize, float, 0)
	ATTRIB(XonoticServerList, columnTypeOrigin, float, 0)
	ATTRIB(XonoticServerList, columnTypeSize, float, 0)
	ATTRIB(XonoticServerList, columnPlayersOrigin, float, 0)
	ATTRIB(XonoticServerList, columnPlayersSize, float, 0)

	ATTRIB(XonoticServerList, selectedServer, string, string_null) // to restore selected server when needed
	METHOD(XonoticServerList, setSelected, void(entity, float))
	METHOD(XonoticServerList, setSortOrder, void(entity, float, float))
	ATTRIB(XonoticServerList, filterShowEmpty, float, 1)
	ATTRIB(XonoticServerList, filterShowFull, float, 1)
	ATTRIB(XonoticServerList, filterString, string, string_null)
	ATTRIB(XonoticServerList, controlledTextbox, entity, NULL)
	ATTRIB(XonoticServerList, ipAddressBox, entity, NULL)
	ATTRIB(XonoticServerList, favoriteButton, entity, NULL)
	ATTRIB(XonoticServerList, nextRefreshTime, float, 0)
	METHOD(XonoticServerList, refreshServerList, void(entity, float)) // refresh mode: REFRESHSERVERLIST_*
	ATTRIB(XonoticServerList, needsRefresh, float, 1)
	METHOD(XonoticServerList, focusEnter, void(entity))
	METHOD(XonoticServerList, positionSortButton, void(entity, entity, float, float, string, void(entity, entity)))
	ATTRIB(XonoticServerList, sortButton1, entity, NULL)
	ATTRIB(XonoticServerList, sortButton2, entity, NULL)
	ATTRIB(XonoticServerList, sortButton3, entity, NULL)
	ATTRIB(XonoticServerList, sortButton4, entity, NULL)
	ATTRIB(XonoticServerList, sortButton5, entity, NULL)
	ATTRIB(XonoticServerList, connectButton, entity, NULL)
	ATTRIB(XonoticServerList, infoButton, entity, NULL)
	ATTRIB(XonoticServerList, currentSortOrder, float, 0)
	ATTRIB(XonoticServerList, currentSortField, float, -1)
	ATTRIB(XonoticServerList, lastClickedServer, float, -1)
	ATTRIB(XonoticServerList, lastClickedTime, float, 0)

	ATTRIB(XonoticServerList, ipAddressBoxFocused, float, -1)

	ATTRIB(XonoticServerList, seenIPv4, float, 0)
	ATTRIB(XonoticServerList, seenIPv6, float, 0)
	ATTRIB(XonoticServerList, categoriesHeight, float, 1.25)

	METHOD(XonoticServerList, getTotalHeight, float(entity))
	METHOD(XonoticServerList, getItemAtPos, float(entity, float))
	METHOD(XonoticServerList, getItemStart, float(entity, float))
	METHOD(XonoticServerList, getItemHeight, float(entity, float))
ENDCLASS(XonoticServerList)
entity makeXonoticServerList();

#ifndef IMPLEMENTATION
float autocvar_menu_slist_categories;
float autocvar_menu_slist_categories_onlyifmultiple; 
float autocvar_menu_slist_purethreshold;
float autocvar_menu_slist_modimpurity;
float autocvar_menu_slist_recommendations;
float autocvar_menu_slist_recommendations_maxping;
float autocvar_menu_slist_recommendations_minfreeslots; 
float autocvar_menu_slist_recommendations_minhumans;
float autocvar_menu_slist_recommendations_purethreshold; 

// server cache fields
#define SLIST_FIELDS \
	SLIST_FIELD(CNAME,       "cname") \
	SLIST_FIELD(PING,        "ping") \
	SLIST_FIELD(GAME,        "game") \
	SLIST_FIELD(MOD,         "mod") \
	SLIST_FIELD(MAP,         "map") \
	SLIST_FIELD(NAME,        "name") \
	SLIST_FIELD(MAXPLAYERS,  "maxplayers") \
	SLIST_FIELD(NUMPLAYERS,  "numplayers") \
	SLIST_FIELD(NUMHUMANS,   "numhumans") \
	SLIST_FIELD(NUMBOTS,     "numbots") \
	SLIST_FIELD(PROTOCOL,    "protocol") \
	SLIST_FIELD(FREESLOTS,   "freeslots") \
	SLIST_FIELD(PLAYERS,     "players") \
	SLIST_FIELD(QCSTATUS,    "qcstatus") \
	SLIST_FIELD(CATEGORY,    "category") \
	SLIST_FIELD(ISFAVORITE,  "isfavorite")

#define SLIST_FIELD(suffix,name) float SLIST_FIELD_##suffix;
SLIST_FIELDS
#undef SLIST_FIELD

const float REFRESHSERVERLIST_RESORT = 0;    // sort the server list again to update for changes to e.g. favorite status, categories
const float REFRESHSERVERLIST_REFILTER = 1;  // ..., also update filter and sort criteria
const float REFRESHSERVERLIST_ASK = 2;       // ..., also suggest querying servers now
const float REFRESHSERVERLIST_RESET = 3;     // ..., also clear the list first

// function declarations
float IsServerInList(string list, string srv);
#define IsFavorite(srv) IsServerInList(cvar_string("net_slist_favorites"), srv)
#define IsPromoted(srv) IsServerInList(_Nex_ExtResponseSystem_PromotedServers, srv)
#define IsRecommended(srv) IsServerInList(_Nex_ExtResponseSystem_RecommendedServers, srv)

entity RetrieveCategoryEnt(float catnum);

float CheckCategoryOverride(float cat);
float CheckCategoryForEntry(float entry); 
float m_gethostcachecategory(float entry) { return CheckCategoryOverride(CheckCategoryForEntry(entry)); }

void RegisterSLCategories();

void ServerList_Connect_Click(entity btn, entity me);
void ServerList_Categories_Click(entity box, entity me);
void ServerList_ShowEmpty_Click(entity box, entity me);
void ServerList_ShowFull_Click(entity box, entity me);
void ServerList_Filter_Change(entity box, entity me);
void ServerList_Favorite_Click(entity btn, entity me);
void ServerList_Info_Click(entity btn, entity me);
void ServerList_Update_favoriteButton(entity btn, entity me);

// fields for category entities
#define MAX_CATEGORIES 9
#define CATEGORY_FIRST 1
entity categories[MAX_CATEGORIES];
float category_ent_count;
.string cat_name;
.string cat_string;
.string cat_enoverride_string;
.string cat_dioverride_string;
.float cat_enoverride;
.float cat_dioverride;

// fields for drawing categories
float category_name[MAX_CATEGORIES];
float category_item[MAX_CATEGORIES];
float category_draw_count;

#define SLIST_CATEGORIES \
	SLIST_CATEGORY(CAT_FAVORITED,    "",            "",             ZCTX(_("SLCAT^Favorites"))) \
	SLIST_CATEGORY(CAT_RECOMMENDED,  "",            "",             ZCTX(_("SLCAT^Recommended"))) \
	SLIST_CATEGORY(CAT_NORMAL,       "",            "CAT_SERVERS",  ZCTX(_("SLCAT^Normal Servers"))) \
	SLIST_CATEGORY(CAT_SERVERS,      "CAT_NORMAL",  "CAT_SERVERS",  ZCTX(_("SLCAT^Servers"))) \
	SLIST_CATEGORY(CAT_XPM,          "CAT_NORMAL",  "CAT_SERVERS",  ZCTX(_("SLCAT^Competitive Mode"))) \
	SLIST_CATEGORY(CAT_MODIFIED,     "",            "CAT_SERVERS",  ZCTX(_("SLCAT^Modified Servers"))) \
	SLIST_CATEGORY(CAT_OVERKILL,     "",            "CAT_SERVERS",  ZCTX(_("SLCAT^Overkill Mode"))) \
	SLIST_CATEGORY(CAT_MINSTAGIB,    "",            "CAT_SERVERS",  ZCTX(_("SLCAT^MinstaGib Mode"))) \
	SLIST_CATEGORY(CAT_DEFRAG,       "",            "CAT_SERVERS",  ZCTX(_("SLCAT^Defrag Mode")))

#define SLIST_CATEGORY_AUTOCVAR(name) autocvar_menu_slist_categories_##name##_override
#define SLIST_CATEGORY(name,enoverride,dioverride,str) \
	float name; \
	var string SLIST_CATEGORY_AUTOCVAR(name) = enoverride;
SLIST_CATEGORIES
#undef SLIST_CATEGORY

#endif
#endif
#ifdef IMPLEMENTATION

void RegisterSLCategories()
{
	entity cat;
	#define SLIST_CATEGORY(name,enoverride,dioverride,str) \
		SET_FIELD_COUNT(name, CATEGORY_FIRST, category_ent_count) \
		CHECK_MAX_COUNT(name, MAX_CATEGORIES, category_ent_count, "SLIST_CATEGORY") \
		cat = spawn(); \
		categories[name - 1] = cat; \
		cat.classname = "slist_category"; \
		cat.cat_name = strzone(#name); \
		cat.cat_enoverride_string = strzone(SLIST_CATEGORY_AUTOCVAR(name)); \
		cat.cat_dioverride_string = strzone(dioverride); \
		cat.cat_string = strzone(str);
	SLIST_CATEGORIES
	#undef SLIST_CATEGORY

	float i, x, catnum;
	string s;

	#define PROCESS_OVERRIDE(override_string,override_field) \
		for(i = 0; i < category_ent_count; ++i) \
		{ \
			s = categories[i].override_string; \
			if((s != "") && (s != categories[i].cat_name)) \
			{ \
				catnum = 0; \
				for(x = 0; x < category_ent_count; ++x) \
				{ if(categories[x].cat_name == s) { \
					catnum = (x+1); \
					break; \
				} } \
				if(catnum) \
				{ \
					strunzone(categories[i].override_string); \
					categories[i].override_field = catnum; \
					continue; \
				} \
				else \
				{ \
					printf( \
						"RegisterSLCategories(): Improper override '%s' for category '%s'!\n", \
						s, \
						categories[i].cat_name \
					); \
				} \
			} \
			strunzone(categories[i].override_string); \
			categories[i].override_field = 0; \
		}
	PROCESS_OVERRIDE(cat_enoverride_string, cat_enoverride)
	PROCESS_OVERRIDE(cat_dioverride_string, cat_dioverride)
	#undef PROCESS_OVERRIDE
}

// Supporting Functions
entity RetrieveCategoryEnt(float catnum)
{
	if((catnum > 0) && (catnum <= category_ent_count))
	{
		return categories[catnum - 1];
	}
	else
	{
		error(sprintf("RetrieveCategoryEnt(%d): Improper category number!\n", catnum));
		return world;
	}
}

float IsServerInList(string list, string srv)
{
	string p;
	float i, n;
	if(srv == "")
		return FALSE;
	srv = netaddress_resolve(srv, 26000);
	if(srv == "")
		return FALSE;
	p = crypto_getidfp(srv);
	n = tokenize_console(list);
	for(i = 0; i < n; ++i)
	{
		if(substring(argv(i), 0, 1) != "[" && strlen(argv(i)) == 44 && strstrofs(argv(i), ".", 0) < 0)
		{
			if(p)
				if(argv(i) == p)
					return TRUE;
		}
		else
		{
			if(srv == netaddress_resolve(argv(i), 26000))
				return TRUE;
		}
	}
	return FALSE;
}

float CheckCategoryOverride(float cat)
{
	entity catent = RetrieveCategoryEnt(cat);
	if(catent)
	{
		float override = (autocvar_menu_slist_categories ? catent.cat_enoverride : catent.cat_dioverride); 
		if(override) { return override; }
		else { return cat; }
	}
	else
	{
		error(sprintf("CheckCategoryOverride(%d): Improper category number!\n", cat));
		return cat;
	}
}

float CheckCategoryForEntry(float entry)
{
	string s, k, v, modtype = "";
	float j, m, impure = 0, freeslots = 0, sflags = 0;
	s = gethostcachestring(SLIST_FIELD_QCSTATUS, entry);
	m = tokenizebyseparator(s, ":");

	for(j = 2; j < m; ++j)
	{
		if(argv(j) == "") { break; }
		k = substring(argv(j), 0, 1);
		v = substring(argv(j), 1, -1);
		switch(k)
		{
			case "P": { impure = stof(v); break; }
			case "S": { freeslots = stof(v); break; }
			case "F": { sflags = stof(v); break; }
			case "M": { modtype = strtolower(v); break; }
		}
	}

	if(modtype != "xonotic") { impure += autocvar_menu_slist_modimpurity; }

	// check if this server is favorited
	if(gethostcachenumber(SLIST_FIELD_ISFAVORITE, entry)) { return CAT_FAVORITED; }

	// now check if it's recommended
	if(autocvar_menu_slist_recommendations)
	{
		string cname = gethostcachestring(SLIST_FIELD_CNAME, entry);
		
		if(IsPromoted(cname)) { return CAT_RECOMMENDED; }
		else
		{
			float recommended = 0;
			if(autocvar_menu_slist_recommendations & 1)
			{
				if(IsRecommended(cname)) { ++recommended; }
				else { --recommended; }
			}
			if(autocvar_menu_slist_recommendations & 2)
			{
				if(
					///// check for minimum free slots
					(freeslots >= autocvar_menu_slist_recommendations_minfreeslots)
					
					&& // check for purity requirement
					(
						(autocvar_menu_slist_recommendations_purethreshold < 0)
						||
						(impure <= autocvar_menu_slist_recommendations_purethreshold)
					)
					
					&& // check for minimum amount of humans
					(
						gethostcachenumber(SLIST_FIELD_NUMHUMANS, entry)
						>=
						autocvar_menu_slist_recommendations_minhumans
					)
					
					&& // check for maximum latency
					(
						gethostcachenumber(SLIST_FIELD_PING, entry)
						<=
						autocvar_menu_slist_recommendations_maxping
					)
				)
					{ ++recommended; }
				else
					{ --recommended; }
			}
			if(recommended > 0) { return CAT_RECOMMENDED; }
		}
	}

	// if not favorited or recommended, check modname
	if(modtype != "xonotic")
	{
		switch(modtype)
		{
			// old servers which don't report their mod name are considered modified now
			case "": { return CAT_MODIFIED; }
			
			case "xpm": { return CAT_XPM; } 
			case "minstagib": { return CAT_MINSTAGIB; }
			case "overkill": { return CAT_OVERKILL; }
			//case "nix": { return CAT_NIX; }
			//case "newtoys": { return CAT_NEWTOYS; }

			// "cts" is allowed as compat, xdf is replacement
			case "cts": 
			case "xdf": { return CAT_DEFRAG; }
			
			default: { dprintf("Found strange mod type: %s\n", modtype); return CAT_MODIFIED; }
		}
	}

	// must be normal or impure server
	return ((impure > autocvar_menu_slist_purethreshold) ? CAT_MODIFIED : CAT_NORMAL);
}

void XonoticServerList_toggleFavorite(entity me, string srv)
{
	string s, s0, s1, s2, srv_resolved, p;
	float i, n, f;
	srv_resolved = netaddress_resolve(srv, 26000);
	p = crypto_getidfp(srv_resolved);
	s = cvar_string("net_slist_favorites");
	n = tokenize_console(s);
	f = 0;
	for(i = 0; i < n; ++i)
	{
		if(substring(argv(i), 0, 1) != "[" && strlen(argv(i)) == 44 && strstrofs(argv(i), ".", 0) < 0)
		{
			if(p)
				if(argv(i) != p)
					continue;
		}
		else
		{
			if(srv_resolved != netaddress_resolve(argv(i), 26000))
				continue;
		}
		s0 = s1 = s2 = "";
		if(i > 0)
			s0 = substring(s, 0, argv_end_index(i - 1));
		if(i < n-1)
			s2 = substring(s, argv_start_index(i + 1), -1);
		if(s0 != "" && s2 != "")
			s1 = " ";
		cvar_set("net_slist_favorites", strcat(s0, s1, s2));
		s = cvar_string("net_slist_favorites");
		n = tokenize_console(s);
		f = 1;
		--i;
	}

	if(!f)
	{
		s1 = "";
		if(s != "")
			s1 = " ";
		if(p)
			cvar_set("net_slist_favorites", strcat(s, s1, p));
		else
			cvar_set("net_slist_favorites", strcat(s, s1, srv));
	}

	me.refreshServerList(me, REFRESHSERVERLIST_RESORT);
}

void ServerList_Update_favoriteButton(entity btn, entity me)
{
	me.favoriteButton.setText(me.favoriteButton,
		(IsFavorite(me.ipAddressBox.text) ?
			_("Remove") : _("Favorite")
		)
	);
}

entity makeXonoticServerList()
{
	entity me;
	me = spawnXonoticServerList();
	me.configureXonoticServerList(me);
	return me;
}
void XonoticServerList_configureXonoticServerList(entity me)
{
	me.configureXonoticListBox(me);

	// update field ID's
	#define SLIST_FIELD(suffix,name) SLIST_FIELD_##suffix = gethostcacheindexforkey(name);
	SLIST_FIELDS
	#undef SLIST_FIELD

	// clear list
	me.nItems = 0;
}
void XonoticServerList_setSelected(entity me, float i)
{
	float save;
	save = me.selectedItem;
	SUPER(XonoticServerList).setSelected(me, i);
	/*
	if(me.selectedItem == save)
		return;
	*/
	if(me.nItems == 0)
		return;
	if(gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT) != me.nItems)
		return; // sorry, it would be wrong

	if(me.selectedServer)
		strunzone(me.selectedServer);
	me.selectedServer = strzone(gethostcachestring(SLIST_FIELD_CNAME, me.selectedItem));

	me.ipAddressBox.setText(me.ipAddressBox, me.selectedServer);
	me.ipAddressBox.cursorPos = strlen(me.selectedServer);
	me.ipAddressBoxFocused = -1;
}
void XonoticServerList_refreshServerList(entity me, float mode)
{
	//print("refresh of type ", ftos(mode), "\n");

	if(mode >= REFRESHSERVERLIST_REFILTER)
	{
		float m, i, n;
		float listflags = 0;
		string s, typestr, modstr;

		s = me.filterString;

		m = strstrofs(s, ":", 0);
		if(m >= 0)
		{
			typestr = substring(s, 0, m);
			s = substring(s, m + 1, strlen(s) - m - 1);
			while(substring(s, 0, 1) == " ")
				s = substring(s, 1, strlen(s) - 1);
		}
		else
			typestr = "";

		modstr = cvar_string("menu_slist_modfilter");

		m = SLIST_MASK_AND - 1;
		resethostcachemasks();

		// ping: reject negative ping (no idea why this happens in the first place, engine bug)
		sethostcachemasknumber(++m, SLIST_FIELD_PING, 0, SLIST_TEST_GREATEREQUAL);

		// show full button
		if(!me.filterShowFull)
		{
			sethostcachemasknumber(++m, SLIST_FIELD_FREESLOTS, 1, SLIST_TEST_GREATEREQUAL); // legacy
			sethostcachemaskstring(++m, SLIST_FIELD_QCSTATUS, ":S0:", SLIST_TEST_NOTCONTAIN); // g_maxplayers support
		}

		// show empty button
		if(!me.filterShowEmpty)
			sethostcachemasknumber(++m, SLIST_FIELD_NUMHUMANS, 1, SLIST_TEST_GREATEREQUAL);

		// gametype filtering
		if(typestr != "")
			sethostcachemaskstring(++m, SLIST_FIELD_QCSTATUS, strcat(typestr, ":"), SLIST_TEST_STARTSWITH);

		// mod filtering
		if(modstr != "")
		{
			if(substring(modstr, 0, 1) == "!")
				sethostcachemaskstring(++m, SLIST_FIELD_MOD, resolvemod(substring(modstr, 1, strlen(modstr) - 1)), SLIST_TEST_NOTEQUAL);
			else
				sethostcachemaskstring(++m, SLIST_FIELD_MOD, resolvemod(modstr), SLIST_TEST_EQUAL);
		}

		// server banning
		n = tokenizebyseparator(_Nex_ExtResponseSystem_BannedServers, " ");
		for(i = 0; i < n; ++i)
			if(argv(i) != "")
				sethostcachemaskstring(++m, SLIST_FIELD_CNAME, argv(i), SLIST_TEST_NOTSTARTSWITH);

		m = SLIST_MASK_OR - 1;
		if(s != "")
		{
			sethostcachemaskstring(++m, SLIST_FIELD_NAME, s, SLIST_TEST_CONTAINS);
			sethostcachemaskstring(++m, SLIST_FIELD_MAP, s, SLIST_TEST_CONTAINS);
			sethostcachemaskstring(++m, SLIST_FIELD_PLAYERS, s, SLIST_TEST_CONTAINS);
			sethostcachemaskstring(++m, SLIST_FIELD_QCSTATUS, strcat(s, ":"), SLIST_TEST_STARTSWITH);
		}

		// sorting flags
		//listflags |= SLSF_FAVORITES;
		listflags |= SLSF_CATEGORIES;
		if(me.currentSortOrder < 0) { listflags |= SLSF_DESCENDING; }
		sethostcachesort(me.currentSortField, listflags);
	}
	
	resorthostcache();
	if(mode >= REFRESHSERVERLIST_ASK)
		refreshhostcache(mode >= REFRESHSERVERLIST_RESET);
}
void XonoticServerList_focusEnter(entity me)
{
	if(time < me.nextRefreshTime)
	{
		//print("sorry, no refresh yet\n");
		return;
	}
	me.nextRefreshTime = time + 10;
	me.refreshServerList(me, REFRESHSERVERLIST_ASK);
}

void XonoticServerList_draw(entity me)
{
	float i, found, owned;

	if(_Nex_ExtResponseSystem_BannedServersNeedsRefresh)
	{
		if(!me.needsRefresh)
			me.needsRefresh = 2;
		_Nex_ExtResponseSystem_BannedServersNeedsRefresh = 0;
	}

	if(_Nex_ExtResponseSystem_PromotedServersNeedsRefresh)
	{
		if(!me.needsRefresh)
			me.needsRefresh = 3;
		_Nex_ExtResponseSystem_PromotedServersNeedsRefresh = 0;
	}

	if(_Nex_ExtResponseSystem_RecommendedServersNeedsRefresh)
	{
		if(!me.needsRefresh)
			me.needsRefresh = 3;
		_Nex_ExtResponseSystem_RecommendedServersNeedsRefresh = 0;
	}

	if(me.currentSortField == -1)
	{
		me.setSortOrder(me, SLIST_FIELD_PING, +1);
		me.refreshServerList(me, REFRESHSERVERLIST_RESET);
	}
	else if(me.needsRefresh == 1)
	{
		me.needsRefresh = 2; // delay by one frame to make sure "slist" has been executed
	}
	else if(me.needsRefresh == 2)
	{
		me.needsRefresh = 0;
		me.refreshServerList(me, REFRESHSERVERLIST_REFILTER);
	}
	else if(me.needsRefresh == 3)
	{
		me.needsRefresh = 0;
		me.refreshServerList(me, REFRESHSERVERLIST_RESORT);
	}

	owned = ((me.selectedServer == me.ipAddressBox.text) && (me.ipAddressBox.text != ""));

	for(i = 0; i < category_draw_count; ++i) { category_name[i] = -1; category_item[i] = -1; }
	category_draw_count = 0;

	if(autocvar_menu_slist_categories >= 0) // if less than 0, don't even draw a category heading for favorites
	{
		float itemcount = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
		me.nItems = itemcount;
		
		//float visible = floor(me.scrollPos / me.itemHeight);
		// ^ unfortunately no such optimization can be made-- we must process through the
		// entire list, otherwise there is no way to know which item is first in its category.

		// binary search method suggested by div
		float x;
		float begin = 0;
		for(x = 1; x <= category_ent_count; ++x) {
			float first = begin;
			float last = (itemcount - 1);
			if (first > last) {
				// List is empty.
				break;
			}
			float catf = gethostcachenumber(SLIST_FIELD_CATEGORY, first);
			float catl = gethostcachenumber(SLIST_FIELD_CATEGORY, last);
			if (catf > x) {
				// The first one is already > x.
				// Therefore, category x does not exist.
				// Higher numbered categories do exist though.
			} else if (catl < x) {
				// The last one is < x.
				// Thus this category - and any following -
				// don't exist.
				break;
			} else if (catf == x) {
				// Starts at first. This breaks the loop
				// invariant in the binary search and thus has
				// to be handled separately.
				if(gethostcachenumber(SLIST_FIELD_CATEGORY, first) != x)
					error("Category mismatch I");
				if(first > 0)
					if(gethostcachenumber(SLIST_FIELD_CATEGORY, first - 1) == x)
						error("Category mismatch II");
				category_name[category_draw_count] = x;
				category_item[category_draw_count] = first;
				++category_draw_count;
				begin = first + 1;
			} else {
				// At this point, catf <= x < catl, thus
				// catf < catl, thus first < last.
				// INVARIANTS:
				// last - first >= 1
				// catf == gethostcachenumber(SLIST_FIELD_CATEGORY(first)
				// catl == gethostcachenumber(SLIST_FIELD_CATEGORY(last)
				// catf < x
				// catl >= x
				while (last - first > 1) {
					float middle = floor((first + last) / 2);
					// By loop condition, middle != first && middle != last.
					float cat = gethostcachenumber(SLIST_FIELD_CATEGORY, middle);
					if (cat >= x) {
						last = middle;
						catl = cat;
					} else {
						first = middle;
						catf = cat;
					}
				}
				if (catl == x) {
					if(gethostcachenumber(SLIST_FIELD_CATEGORY, last) != x)
						error("Category mismatch III");
					if(last > 0)
						if(gethostcachenumber(SLIST_FIELD_CATEGORY, last - 1) == x)
							error("Category mismatch IV");
					category_name[category_draw_count] = x;
					category_item[category_draw_count] = last;
					++category_draw_count;
					begin = last + 1; // already scanned through these, skip 'em
				}
				else
					begin = last; // already scanned through these, skip 'em
			}
		}
		if(autocvar_menu_slist_categories_onlyifmultiple && (category_draw_count == 1))
		{
			category_name[0] = -1;
			category_item[0] = -1;
			category_draw_count = 0;
			me.nItems = itemcount;
		}
	}
	else { me.nItems = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT); }

	me.connectButton.disabled = ((me.nItems == 0) && (me.ipAddressBox.text == ""));
	me.infoButton.disabled = ((me.nItems == 0) || !owned);
	me.favoriteButton.disabled = ((me.nItems == 0) && (me.ipAddressBox.text == ""));

	found = 0;
	if(me.selectedServer)
	{
		for(i = 0; i < me.nItems; ++i)
		{
			if(gethostcachestring(SLIST_FIELD_CNAME, i) == me.selectedServer)
			{
				if(i != me.selectedItem)
				{
					me.lastClickedServer = -1;
					me.selectedItem = i;
				}
				found = 1;
				break;
			}
		}
	}
	if(!found)
	{
		if(me.nItems > 0)
		{
			if(me.selectedItem >= me.nItems)
				me.selectedItem = me.nItems - 1;
			if(me.selectedServer)
				strunzone(me.selectedServer);
			me.selectedServer = strzone(gethostcachestring(SLIST_FIELD_CNAME, me.selectedItem));
		}
	}
	
	if(owned)
	{
		if(me.selectedServer != me.ipAddressBox.text)
		{
			me.ipAddressBox.setText(me.ipAddressBox, me.selectedServer);
			me.ipAddressBox.cursorPos = strlen(me.selectedServer);
			me.ipAddressBoxFocused = -1;
		}
	}

	if(me.ipAddressBoxFocused != me.ipAddressBox.focused)
	{
		if(me.ipAddressBox.focused || me.ipAddressBoxFocused < 0)
			ServerList_Update_favoriteButton(NULL, me);
		me.ipAddressBoxFocused = me.ipAddressBox.focused;
	}

	SUPER(XonoticServerList).draw(me);
}
void ServerList_PingSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_PING, +1);
}
void ServerList_NameSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_NAME, -1); // why?
}
void ServerList_MapSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_MAP, -1); // why?
}
void ServerList_PlayerSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_NUMHUMANS, -1);
}
void ServerList_TypeSort_Click(entity btn, entity me)
{
	string s, t;
	float i, m;
	s = me.filterString;
	m = strstrofs(s, ":", 0);
	if(m >= 0)
	{
		s = substring(s, 0, m);
		while(substring(s, m+1, 1) == " ") // skip spaces
			++m;
	}
	else
		s = "";

	for(i = 1; ; i *= 2) // 20 modes ought to be enough for anyone
	{
		t = MapInfo_Type_ToString(i);
		if(i > 1)
			if(t == "") // it repeats (default case)
			{
				// no type was found
				// choose the first one
				s = MapInfo_Type_ToString(1);
				break;
			}
		if(s == t)
		{
			// the type was found
			// choose the next one
			s = MapInfo_Type_ToString(i * 2);
			if(s == "")
				s = MapInfo_Type_ToString(1);
			break;
		}
	}

	if(s != "")
		s = strcat(s, ":");
	s = strcat(s, substring(me.filterString, m+1, strlen(me.filterString) - m - 1));

	me.controlledTextbox.setText(me.controlledTextbox, s);
	me.controlledTextbox.keyDown(me.controlledTextbox, K_END, 0, 0);
	me.controlledTextbox.keyUp(me.controlledTextbox, K_END, 0, 0);
	//ServerList_Filter_Change(me.controlledTextbox, me);
}
void ServerList_Filter_Change(entity box, entity me)
{
	if(me.filterString)
		strunzone(me.filterString);
	if(box.text != "")
		me.filterString = strzone(box.text);
	else
		me.filterString = string_null;
	me.refreshServerList(me, REFRESHSERVERLIST_REFILTER);

	me.ipAddressBox.setText(me.ipAddressBox, "");
	me.ipAddressBox.cursorPos = 0;
	me.ipAddressBoxFocused = -1;
}
void ServerList_Categories_Click(entity box, entity me)
{
	box.setChecked(box, autocvar_menu_slist_categories = !autocvar_menu_slist_categories);
	me.refreshServerList(me, REFRESHSERVERLIST_RESORT);

	me.ipAddressBox.setText(me.ipAddressBox, "");
	me.ipAddressBox.cursorPos = 0;
	me.ipAddressBoxFocused = -1;
}
void ServerList_ShowEmpty_Click(entity box, entity me)
{
	box.setChecked(box, me.filterShowEmpty = !me.filterShowEmpty);
	me.refreshServerList(me, REFRESHSERVERLIST_REFILTER);

	me.ipAddressBox.setText(me.ipAddressBox, "");
	me.ipAddressBox.cursorPos = 0;
	me.ipAddressBoxFocused = -1;
}
void ServerList_ShowFull_Click(entity box, entity me)
{
	box.setChecked(box, me.filterShowFull = !me.filterShowFull);
	me.refreshServerList(me, REFRESHSERVERLIST_REFILTER);

	me.ipAddressBox.setText(me.ipAddressBox, "");
	me.ipAddressBox.cursorPos = 0;
	me.ipAddressBoxFocused = -1;
}
void XonoticServerList_setSortOrder(entity me, float fld, float direction)
{
	if(me.currentSortField == fld)
		direction = -me.currentSortOrder;
	me.currentSortOrder = direction;
	me.currentSortField = fld;
	me.sortButton1.forcePressed = (fld == SLIST_FIELD_PING);
	me.sortButton2.forcePressed = (fld == SLIST_FIELD_NAME);
	me.sortButton3.forcePressed = (fld == SLIST_FIELD_MAP);
	me.sortButton4.forcePressed = 0;
	me.sortButton5.forcePressed = (fld == SLIST_FIELD_NUMHUMANS);
	me.selectedItem = 0;
	if(me.selectedServer)
		strunzone(me.selectedServer);
	me.selectedServer = string_null;
	me.refreshServerList(me, REFRESHSERVERLIST_REFILTER);
}
void XonoticServerList_positionSortButton(entity me, entity btn, float theOrigin, float theSize, string theTitle, void(entity, entity) theFunc)
{
	vector originInLBSpace, sizeInLBSpace;
	originInLBSpace = eY * (-me.itemHeight);
	sizeInLBSpace = eY * me.itemHeight + eX * (1 - me.controlWidth);

	vector originInDialogSpace, sizeInDialogSpace;
	originInDialogSpace = boxToGlobal(originInLBSpace, me.Container_origin, me.Container_size);
	sizeInDialogSpace = boxToGlobalSize(sizeInLBSpace, me.Container_size);

	btn.Container_origin_x = originInDialogSpace_x + sizeInDialogSpace_x * theOrigin;
	btn.Container_size_x   =                         sizeInDialogSpace_x * theSize;
	btn.setText(btn, theTitle);
	btn.onClick = theFunc;
	btn.onClickEntity = me;
	btn.resized = 1;
}
void XonoticServerList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(XonoticServerList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnIconsOrigin = 0;
	me.columnIconsSize = me.realFontSize_x * 4 * me.iconsSizeFactor;
	me.columnPingSize = me.realFontSize_x * 3;
	me.columnMapSize = me.realFontSize_x * 10;
	me.columnTypeSize = me.realFontSize_x * 4;
	me.columnPlayersSize = me.realFontSize_x * 5;
	me.columnNameSize = 1 - me.columnPlayersSize - me.columnMapSize - me.columnPingSize - me.columnIconsSize - me.columnTypeSize - 5 * me.realFontSize_x;
	me.columnPingOrigin = me.columnIconsOrigin + me.columnIconsSize + me.realFontSize_x;
	me.columnNameOrigin = me.columnPingOrigin + me.columnPingSize + me.realFontSize_x;
	me.columnMapOrigin = me.columnNameOrigin + me.columnNameSize + me.realFontSize_x;
	me.columnTypeOrigin = me.columnMapOrigin + me.columnMapSize + me.realFontSize_x;
	me.columnPlayersOrigin = me.columnTypeOrigin + me.columnTypeSize + me.realFontSize_x;

	me.positionSortButton(me, me.sortButton1, me.columnPingOrigin, me.columnPingSize, _("Ping"), ServerList_PingSort_Click);
	me.positionSortButton(me, me.sortButton2, me.columnNameOrigin, me.columnNameSize, _("Host name"), ServerList_NameSort_Click);
	me.positionSortButton(me, me.sortButton3, me.columnMapOrigin, me.columnMapSize, _("Map"), ServerList_MapSort_Click);
	me.positionSortButton(me, me.sortButton4, me.columnTypeOrigin, me.columnTypeSize, _("Type"), ServerList_TypeSort_Click);
	me.positionSortButton(me, me.sortButton5, me.columnPlayersOrigin, me.columnPlayersSize, _("Players"), ServerList_PlayerSort_Click);

	float f;
	f = me.currentSortField;
	if(f >= 0)
	{
		me.currentSortField = -1;
		me.setSortOrder(me, f, me.currentSortOrder); // force resetting the sort order
	}
}
void ServerList_Connect_Click(entity btn, entity me)
{
	localcmd(sprintf("connect %s\n",
		((me.ipAddressBox.text != "") ?
			me.ipAddressBox.text : me.selectedServer
		)
	));
}
void ServerList_Favorite_Click(entity btn, entity me)
{
	string ipstr;
	ipstr = netaddress_resolve(me.ipAddressBox.text, 26000);
	if(ipstr != "")
	{
		me.toggleFavorite(me, me.ipAddressBox.text);
		me.ipAddressBoxFocused = -1;
	}
}
void ServerList_Info_Click(entity btn, entity me)
{
	if (me.nItems != 0)
		main.serverInfoDialog.loadServerInfo(main.serverInfoDialog, me.selectedItem);
	DialogOpenButton_Click(me, main.serverInfoDialog);
}
void XonoticServerList_clickListBoxItem(entity me, float i, vector where)
{
	if(i == me.lastClickedServer)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			ServerList_Connect_Click(NULL, me);
		}
	me.lastClickedServer = i;
	me.lastClickedTime = time;
}
void XonoticServerList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Server name, Map name, NP, TP, MP
	float p, q;
	float isv4, isv6;
	vector theColor;
	float theAlpha;
	float m, pure, freeslots, j, sflags;
	string s, typestr, versionstr, k, v, modname;

	//printf("time: %f, i: %d, item: %d, nitems: %d\n", time, i, item, me.nItems);

	vector oldscale = draw_scale;
	vector oldshift = draw_shift;
#define SET_YRANGE(start,end) \
	draw_scale = boxToGlobalSize(eX * 1 + eY * (end - start), oldscale); \
	draw_shift = boxToGlobal(eY * start, oldshift, oldscale);

	for (j = 0; j < category_draw_count; ++j) {
		// Matches exactly the headings with increased height.
		if (i == category_item[j])
			break;
	}

	if (j < category_draw_count)
	{
		entity catent = RetrieveCategoryEnt(category_name[j]);
		if(catent)
		{
			SET_YRANGE(
				(me.categoriesHeight - 1) / (me.categoriesHeight + 1),
				me.categoriesHeight / (me.categoriesHeight + 1)
			);
			draw_Text(
				eY * me.realUpperMargin
				+
#if 0
				eX * (me.columnNameOrigin + (me.columnNameSize - draw_TextWidth(catent.cat_string, 0, me.realFontSize)) * 0.5),
				catent.cat_string,
#else
				eX * (me.columnNameOrigin),
				strcat(catent.cat_string, ":"),
#endif
				me.realFontSize,
				'1 1 1',
				SKINALPHA_TEXT,
				0
			);
			SET_YRANGE(me.categoriesHeight / (me.categoriesHeight + 1), 1);
		}
	}
	
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);

	s = gethostcachestring(SLIST_FIELD_QCSTATUS, i);
	m = tokenizebyseparator(s, ":");
	typestr = "";
	if(m >= 2)
	{
		typestr = argv(0);
		versionstr = argv(1);
	}
	freeslots = -1;
	sflags = -1;
	modname = "";
	pure = 0;
	for(j = 2; j < m; ++j)
	{
		if(argv(j) == "")
			break;
		k = substring(argv(j), 0, 1);
		v = substring(argv(j), 1, -1);
		if(k == "P")
			pure = stof(v);
		else if(k == "S")
			freeslots = stof(v);
		else if(k == "F")
			sflags = stof(v);
		else if(k == "M")
			modname = v;
	}

#ifdef COMPAT_NO_MOD_IS_XONOTIC
	if(modname == "")
		modname = "Xonotic";
#endif

	/*
	SLIST_FIELD_MOD = gethostcacheindexforkey("mod");
	s = gethostcachestring(SLIST_FIELD_MOD, i);
	if(s != "data")
		if(modname == "Xonotic")
			modname = s;
	*/

	// list the mods here on which the pure server check actually works
	if(modname != "Xonotic")
	if(modname != "MinstaGib")
	if(modname != "CTS")
	if(modname != "NIX")
	if(modname != "NewToys")
		pure = 0;

	if(gethostcachenumber(SLIST_FIELD_FREESLOTS, i) <= 0)
		theAlpha = SKINALPHA_SERVERLIST_FULL;
	else if(freeslots == 0)
		theAlpha = SKINALPHA_SERVERLIST_FULL; // g_maxplayers support
	else if (!gethostcachenumber(SLIST_FIELD_NUMHUMANS, i))
		theAlpha = SKINALPHA_SERVERLIST_EMPTY;
	else
		theAlpha = 1;

	p = gethostcachenumber(SLIST_FIELD_PING, i);
#define PING_LOW 75
#define PING_MED 200
#define PING_HIGH 500
	if(p < PING_LOW)
		theColor = SKINCOLOR_SERVERLIST_LOWPING + (SKINCOLOR_SERVERLIST_MEDPING - SKINCOLOR_SERVERLIST_LOWPING) * (p / PING_LOW);
	else if(p < PING_MED)
		theColor = SKINCOLOR_SERVERLIST_MEDPING + (SKINCOLOR_SERVERLIST_HIGHPING - SKINCOLOR_SERVERLIST_MEDPING) * ((p - PING_LOW) / (PING_MED - PING_LOW));
	else if(p < PING_HIGH)
	{
		theColor = SKINCOLOR_SERVERLIST_HIGHPING;
		theAlpha *= 1 + (SKINALPHA_SERVERLIST_HIGHPING - 1) * ((p - PING_MED) / (PING_HIGH - PING_MED));
	}
	else
	{
		theColor = eX;
		theAlpha *= SKINALPHA_SERVERLIST_HIGHPING;
	}

	if(gethostcachenumber(SLIST_FIELD_ISFAVORITE, i))
	{
		theColor = theColor * (1 - SKINALPHA_SERVERLIST_FAVORITE) + SKINCOLOR_SERVERLIST_FAVORITE * SKINALPHA_SERVERLIST_FAVORITE;
		theAlpha = theAlpha * (1 - SKINALPHA_SERVERLIST_FAVORITE) + SKINALPHA_SERVERLIST_FAVORITE;
	}

	s = gethostcachestring(SLIST_FIELD_CNAME, i);

	isv4 = isv6 = 0;
	if(substring(s, 0, 1) == "[")
	{
		isv6 = 1;
		me.seenIPv6 += 1;
	}
	else if(strstrofs("0123456789", substring(s, 0, 1), 0) >= 0)
	{
		isv4 = 1;
		me.seenIPv4 += 1;
	}

	q = stof(substring(crypto_getencryptlevel(s), 0, 1));
	if((q <= 0 && cvar("crypto_aeslevel") >= 3) || (q >= 3 && cvar("crypto_aeslevel") <= 0))
	{
		theColor = SKINCOLOR_SERVERLIST_IMPOSSIBLE;
		theAlpha = SKINALPHA_SERVERLIST_IMPOSSIBLE;
	}

	if(q == 1)
	{
		if(cvar("crypto_aeslevel") >= 2)
			q |= 4;
	}
	if(q == 2)
	{
		if(cvar("crypto_aeslevel") >= 1)
			q |= 4;
	}
	if(q == 3)
		q = 5;
	else if(q >= 3)
		q -= 2;
	// possible status:
	// 0: crypto off
	// 1: AES possible
	// 2: AES recommended but not available
	// 3: AES possible and will be used
	// 4: AES recommended and will be used
	// 5: AES required

	// --------------
	//  RENDER ICONS
	// --------------
	vector iconSize = '0 0 0';
	iconSize_y = me.realFontSize_y * me.iconsSizeFactor;
	iconSize_x = me.realFontSize_x * me.iconsSizeFactor;

	vector iconPos = '0 0 0';
	iconPos_x = (me.columnIconsSize - 3 * iconSize_x) * 0.5;
	iconPos_y = (1 - iconSize_y) * 0.5;

	string n;

	if (!(me.seenIPv4 && me.seenIPv6))
	{
		iconPos_x += iconSize_x * 0.5;
	}
	else if(me.seenIPv4 && me.seenIPv6)
	{
		n = string_null;
		if(isv6)
			draw_PreloadPictureWithFlags(n = strcat(SKINGFX_SERVERLIST_ICON, "_ipv6"), 0); // PRECACHE_PIC_MIPMAP
		else if(isv4)
			draw_PreloadPictureWithFlags(n = strcat(SKINGFX_SERVERLIST_ICON, "_ipv4"), 0); // PRECACHE_PIC_MIPMAP
		if(n)
			draw_Picture(iconPos, n, iconSize, '1 1 1', 1);
		iconPos_x += iconSize_x;
	}

	if(q > 0)
	{
		draw_PreloadPictureWithFlags(n = strcat(SKINGFX_SERVERLIST_ICON, "_aeslevel", ftos(q)), 0); // PRECACHE_PIC_MIPMAP
		draw_Picture(iconPos, n, iconSize, '1 1 1', 1);
	}
	iconPos_x += iconSize_x;

	if(modname == "Xonotic")
	{
		if(pure == 0)
		{
			draw_PreloadPictureWithFlags(n = strcat(SKINGFX_SERVERLIST_ICON, "_pure1"), PRECACHE_PIC_MIPMAP);
			draw_Picture(iconPos, n, iconSize, '1 1 1', 1);
		}
	}
	else
	{
		draw_PreloadPictureWithFlags(n = strcat(SKINGFX_SERVERLIST_ICON, "_mod_", modname), PRECACHE_PIC_MIPMAP);
		if(draw_PictureSize(n) == '0 0 0')
			draw_PreloadPictureWithFlags(n = strcat(SKINGFX_SERVERLIST_ICON, "_mod_"), PRECACHE_PIC_MIPMAP);
		if(pure == 0)
			draw_Picture(iconPos, n, iconSize, '1 1 1', 1);
		else
			draw_Picture(iconPos, n, iconSize, '1 1 1', SKINALPHA_SERVERLIST_ICON_NONPURE);
	}
	iconPos_x += iconSize_x;

	if(sflags >= 0 && (sflags & SERVERFLAG_PLAYERSTATS))
	{
		draw_PreloadPictureWithFlags(n = strcat(SKINGFX_SERVERLIST_ICON, "_stats1"), 0); // PRECACHE_PIC_MIPMAP
		draw_Picture(iconPos, n, iconSize, '1 1 1', 1);
	}
	iconPos_x += iconSize_x;
	
	// --------------
	//  RENDER TEXT
	// --------------
	
	// ping
	s = ftos(p);
	draw_Text(me.realUpperMargin * eY + (me.columnPingOrigin + me.columnPingSize - draw_TextWidth(s, 0, me.realFontSize)) * eX, s, me.realFontSize, theColor, theAlpha, 0);

	// server name
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_NAME, i), me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + me.columnNameOrigin * eX, s, me.realFontSize, theColor, theAlpha, 0);

	// server map
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_MAP, i), me.columnMapSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + (me.columnMapOrigin + (me.columnMapSize - draw_TextWidth(s, 0, me.realFontSize)) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);

	// server gametype
	s = draw_TextShortenToWidth(typestr, me.columnTypeSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + (me.columnTypeOrigin + (me.columnTypeSize - draw_TextWidth(s, 0, me.realFontSize)) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);

	// server playercount
	s = strcat(ftos(gethostcachenumber(SLIST_FIELD_NUMHUMANS, i)), "/", ftos(gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i)));
	draw_Text(me.realUpperMargin * eY + (me.columnPlayersOrigin + (me.columnPlayersSize - draw_TextWidth(s, 0, me.realFontSize)) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float XonoticServerList_keyDown(entity me, float scan, float ascii, float shift)
{
	vector org, sz;

	org = boxToGlobal(eY * (me.selectedItem * me.itemHeight - me.scrollPos), me.origin, me.size);
	sz = boxToGlobalSize(eY * me.itemHeight + eX * (1 - me.controlWidth), me.size);

	if(scan == K_ENTER || scan == K_KP_ENTER)
	{
		ServerList_Connect_Click(NULL, me);
		return 1;
	}
	else if(scan == K_MOUSE2 || scan == K_SPACE)
	{
		if(me.nItems != 0)
		{
			main.serverInfoDialog.loadServerInfo(main.serverInfoDialog, me.selectedItem);
			DialogOpenButton_Click_withCoords(me, main.serverInfoDialog, org, sz);
			return 1;
		}
		return 0;
	}
	else if(scan == K_INS || scan == K_MOUSE3 || scan == K_KP_INS)
	{
		if(me.nItems != 0)
		{
			me.toggleFavorite(me, me.selectedServer);
			me.ipAddressBoxFocused = -1;
			return 1;
		}
		return 0;
	}
	else if(SUPER(XonoticServerList).keyDown(me, scan, ascii, shift))
		return 1;
	else if(!me.controlledTextbox)
		return 0;
	else
		return me.controlledTextbox.keyDown(me.controlledTextbox, scan, ascii, shift);
}

float XonoticServerList_getTotalHeight(entity me) {
	float num_normal_rows = me.nItems;
	float num_headers = category_draw_count;
	return me.itemHeight * (num_normal_rows + me.categoriesHeight * num_headers);
}
float XonoticServerList_getItemAtPos(entity me, float pos) {
	pos = pos / me.itemHeight;
	float i;
	for (i = category_draw_count - 1; i >= 0; --i) {
		float itemidx = category_item[i];
		float itempos = i * me.categoriesHeight + category_item[i];
		if (pos >= itempos + me.categoriesHeight + 1)
			return itemidx + 1 + floor(pos - (itempos + me.categoriesHeight + 1));
		if (pos >= itempos)
			return itemidx;
	}
	// No category matches? Note that category 0 is... 0. Therefore no headings exist at all.
	return floor(pos);
}
float XonoticServerList_getItemStart(entity me, float item) {
	float i;
	for (i = category_draw_count - 1; i >= 0; --i) {
		float itemidx = category_item[i];
		float itempos = i * me.categoriesHeight + category_item[i];
		if (item >= itemidx + 1)
			return (itempos + me.categoriesHeight + 1 + item - (itemidx + 1)) * me.itemHeight;
		if (item >= itemidx)
			return itempos * me.itemHeight;
	}
	// No category matches? Note that category 0 is... 0. Therefore no headings exist at all.
	return item * me.itemHeight;
}
float XonoticServerList_getItemHeight(entity me, float item) {
	float i;
	for (i = 0; i < category_draw_count; ++i) {
		// Matches exactly the headings with increased height.
		if (item == category_item[i])
			return me.itemHeight * (me.categoriesHeight + 1);
	}
	return me.itemHeight;
}

#endif
