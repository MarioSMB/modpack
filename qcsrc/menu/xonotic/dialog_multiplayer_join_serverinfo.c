#ifdef INTERFACE
CLASS(XonoticServerInfoDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticServerInfoDialog, fill, void(entity))
	METHOD(XonoticServerInfoDialog, loadServerInfo, void(entity, float))
	ATTRIB(XonoticServerInfoDialog, title, string, _("Server Information"))
	ATTRIB(XonoticServerInfoDialog, color, vector, SKINCOLOR_DIALOG_SERVERINFO)
	ATTRIB(XonoticServerInfoDialog, intendedWidth, float, 0.8)
	ATTRIB(XonoticServerInfoDialog, rows, float, 18)
	ATTRIB(XonoticServerInfoDialog, columns, float, 6.2)

	ATTRIB(XonoticServerInfoDialog, currentServerName, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerCName, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerType, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerMap, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerPlayers, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerNumPlayers, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerNumBots, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerNumFreeSlots, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerMod, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerVersion, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerKey, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerID, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerEncrypt, string, string_null)
	ATTRIB(XonoticServerInfoDialog, currentServerPure, string, string_null)

	ATTRIB(XonoticServerInfoDialog, nameLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, cnameLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, typeLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, mapLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, rawPlayerList, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, numPlayersLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, numBotsLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, numFreeSlotsLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, modLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, versionLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, keyLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, idLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, encryptLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, canConnectLabel, entity, NULL)
	ATTRIB(XonoticServerInfoDialog, pureLabel, entity, NULL)
ENDCLASS(XonoticServerInfoDialog)

void Join_Click(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION
void XonoticServerInfoDialog_loadServerInfo(entity me, float i)
{
	float m, pure, freeslots, j, numh, maxp, numb, sflags;
	string s, typestr, versionstr, k, v, modname;

	// ====================================
	//  First clear and unzone the strings
	// ====================================
	if(me.currentServerName)
		strunzone(me.currentServerName);
	me.currentServerName = string_null;
	
	if(me.currentServerCName)
		strunzone(me.currentServerCName);
	me.currentServerCName = string_null;
	
	if(me.currentServerType)
		strunzone(me.currentServerType);
	me.currentServerType = string_null;
	
	if(me.currentServerMap)
		strunzone(me.currentServerMap);
	me.currentServerMap = string_null;
	
	if(me.currentServerPlayers)
		strunzone(me.currentServerPlayers);
	me.currentServerPlayers = string_null;
	
	if(me.currentServerNumPlayers)
		strunzone(me.currentServerNumPlayers);
	me.currentServerNumPlayers = string_null;
	
	if(me.currentServerNumBots)
		strunzone(me.currentServerNumBots);
	me.currentServerNumBots = string_null;
	
	if(me.currentServerNumFreeSlots)
		strunzone(me.currentServerNumFreeSlots);
	me.currentServerNumFreeSlots = string_null;
	
	if(me.currentServerMod)
		strunzone(me.currentServerMod);
	me.currentServerMod = string_null;
	
	if(me.currentServerVersion)
		strunzone(me.currentServerVersion);
	me.currentServerVersion = string_null;
	
	// not zoned!
	//if(me.currentServerEncrypt)
	//	strunzone(me.currentServerEncrypt);
	//me.currentServerEncrypt = string_null;
	if(me.currentServerPure)
		strunzone(me.currentServerPure);
	me.currentServerPure = string_null;
	
	if(me.currentServerKey)
		strunzone(me.currentServerKey);
	me.currentServerKey = string_null;
	
	if(me.currentServerID)
		strunzone(me.currentServerID);
	me.currentServerID = string_null;

	// ==========================
	//  Now, fill in the strings
	// ==========================
	me.currentServerName = strzone(gethostcachestring(SLIST_FIELD_NAME, i));
	me.nameLabel.setText(me.nameLabel, me.currentServerName);

	me.currentServerCName = strzone(gethostcachestring(SLIST_FIELD_CNAME, i));
	me.cnameLabel.setText(me.cnameLabel, me.currentServerCName);

	pure = -1;
	typestr = _("N/A");
	versionstr = _("N/A");

	s = gethostcachestring(SLIST_FIELD_QCSTATUS, i);
	m = tokenizebyseparator(s, ":");
	if(m >= 2)
	{
		typestr = argv(0);
		versionstr = argv(1);
	}
	freeslots = -1;
	sflags = -1;
	modname = "";
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

	s = gethostcachestring(SLIST_FIELD_MOD, i);
	if(s != "data")
		modname = sprintf(_("%s (%s)"), modname, s);

	j = MapInfo_Type_FromString(typestr); // try and get the real name of the game type
	if(j) { typestr = MapInfo_Type_ToText(j); } // only set it if we actually found it
	
	me.currentServerType = strzone(typestr);
	me.typeLabel.setText(me.typeLabel, me.currentServerType);

	me.currentServerMap = strzone(gethostcachestring(SLIST_FIELD_MAP, i));
	me.mapLabel.setText(me.mapLabel, me.currentServerMap);

	me.currentServerPlayers = strzone(gethostcachestring(SLIST_FIELD_PLAYERS, i));
	me.rawPlayerList.setPlayerList(me.rawPlayerList, me.currentServerPlayers);

	numh = gethostcachenumber(SLIST_FIELD_NUMHUMANS, i);
	maxp = gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i);
	numb = gethostcachenumber(SLIST_FIELD_NUMBOTS, i);
	me.currentServerNumPlayers = strzone(sprintf(_("%d/%d"), numh, maxp));
	me.numPlayersLabel.setText(me.numPlayersLabel, me.currentServerNumPlayers);

	s = ftos(numb);
	me.currentServerNumBots = strzone(s);
	me.numBotsLabel.setText(me.numBotsLabel, me.currentServerNumBots);
	
	if(freeslots < 0) { freeslots = maxp - numh - numb; }
	s = ftos(freeslots);
	me.currentServerNumFreeSlots = strzone(s);
	me.numFreeSlotsLabel.setText(me.numFreeSlotsLabel, me.currentServerNumFreeSlots);

	me.currentServerMod = ((modname == "Xonotic") ? _("Default") : modname);
	me.currentServerMod = strzone(me.currentServerMod);
	me.modLabel.setText(me.modLabel, me.currentServerMod);

	me.currentServerVersion = strzone(versionstr);
	me.versionLabel.setText(me.versionLabel, me.currentServerVersion);

	me.currentServerPure = ((pure < 0) ? "N/A" : (pure == 0) ? _("Official") : sprintf(_("%d modified"), pure));
	me.currentServerPure = strzone(me.currentServerPure);
	me.pureLabel.setText(me.pureLabel, me.currentServerPure);

	s = crypto_getencryptlevel(me.currentServerCName);
	if(s == "")
	{
		if(cvar("crypto_aeslevel") >= 3)
			me.currentServerEncrypt = _("N/A (auth library missing, can't connect)");
		else
			me.currentServerEncrypt = _("N/A (auth library missing)");
	}
	else switch(stof(substring(s, 0, 1)))
	{
		case 0:
			if(cvar("crypto_aeslevel") >= 3)
				me.currentServerEncrypt = _("Not supported (can't connect)");
			else
				me.currentServerEncrypt = _("Not supported (won't encrypt)");
			break;
		case 1:
			if(cvar("crypto_aeslevel") >= 2)
				me.currentServerEncrypt = _("Supported (will encrypt)");
			else
				me.currentServerEncrypt = _("Supported (won't encrypt)");
			break;
		case 2:
			if(cvar("crypto_aeslevel") >= 1)
				me.currentServerEncrypt = _("Requested (will encrypt)");
			else
				me.currentServerEncrypt = _("Requested (won't encrypt)");
			break;
		case 3:
			if(cvar("crypto_aeslevel") <= 0)
				me.currentServerEncrypt = _("Required (can't connect)");
			else
				me.currentServerEncrypt = _("Required (will encrypt)");
			break;
	}
	me.encryptLabel.setText(me.encryptLabel, me.currentServerEncrypt);
	
	s = crypto_getidfp(me.currentServerCName);
	if not(s) { s = _("N/A"); }
	me.currentServerID = strzone(s);
	me.idLabel.setText(me.idLabel, me.currentServerID);

	s = crypto_getkeyfp(me.currentServerCName);
	if not(s) { s = _("N/A"); }
	me.currentServerKey = strzone(s);
	me.keyLabel.setText(me.keyLabel, me.currentServerKey);
}

void XonoticServerInfoDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Hostname:")));
		me.TD(me, 1, 4.6, e = makeXonoticTextLabel(0.5, ""));
		e.colorL = SKINCOLOR_SERVERINFO_NAME;
		e.allowCut = 1;
		me.nameLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Address:")));
		me.TD(me, 1, 4.6, e = makeXonoticTextLabel(0.5, ""));
		e.colorL = SKINCOLOR_SERVERINFO_IP;
		e.allowCut = 1;
		me.cnameLabel = e;
		
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Gametype:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.typeLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Map:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.mapLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Mod:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.modLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Version:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.versionLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Settings:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.pureLabel = e;
		
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Players:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.numPlayersLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Bots:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.numBotsLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Free slots:")));
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, ""));
		e.allowCut = 1;
		me.numFreeSlotsLabel = e;
		
	me.gotoRC(me, me.rows - 5, 0);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Encryption:")));
		me.TD(me, 1, 5.4, e = makeXonoticTextLabel(0, ""));
			e.allowCut = 1;
			me.encryptLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("ID:")));
		me.TD(me, 1, 5.4, e = makeXonoticTextLabel(0, ""));
			e.allowCut = 1;
			me.keyLabel = e;
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Key:")));
		me.TD(me, 1, 5.4, e = makeXonoticTextLabel(0, ""));
			e.allowCut = 1;
			me.idLabel = e;

	me.gotoRC(me, 2, 2.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Players:")));
	me.TR(me);
		me.TD(me, me.rows - 8, 4, e = makeXonoticPlayerList());
			me.rawPlayerList = e;

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns/2, e = makeXonoticButton(_("Close"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
		//me.TD(me, 1, me.columns/3, e = makeXonoticButton("", '0 0 0')); // TODO: Add bookmark button here
		//	e.onClick = ServerList_Favorite_Click;
		//	e.onClickEntity = slist;
		//	slist.favoriteButton = e;
		me.TD(me, 1, me.columns/2, e = makeXonoticButton(_("Join!"), '0 0 0'));
			e.onClick = Join_Click;
			e.onClickEntity = me;
}

void Join_Click(entity btn, entity me)
{
	localcmd("connect ", me.currentServerCName, "\n");
}

#endif
