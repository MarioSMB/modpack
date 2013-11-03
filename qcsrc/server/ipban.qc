/*
 * Protocol of online ban list:
 *
 * - Reporting a ban:
 *     GET g_ban_sync_uri?action=ban&hostname=...&ip=xxx.xxx.xxx&duration=nnnn&reason=...................
 *     (IP 1, 2, 3, or 4 octets, 3 octets for example is a /24 mask)
 * - Removing a ban:
 *     GET g_ban_sync_uri?action=unban&hostname=...&ip=xxx.xxx.xxx
 * - Querying the ban list
 *     GET g_ban_sync_uri?action=list&hostname=...&servers=xxx.xxx.xxx.xxx;xxx.xxx.xxx.xxx;...
 *     
 *     shows the bans from the listed servers, and possibly others.
 *     Format of a ban is ASCII plain text, four lines per ban, delimited by
 *     newline ONLY (no carriage return):
 *
 *     IP address (also 1, 2, 3, or 4 octets, delimited by dot)
 *     time left in seconds
 *     reason of the ban
 *     server IP that registered the ban
 */

#define MAX_IPBAN_URIS (URI_GET_IPBAN_END - URI_GET_IPBAN + 1)

float Ban_Insert(string ip, float bantime, string reason, float dosync);

void OnlineBanList_SendBan(string ip, float bantime, string reason)
{
	string uri;
	float i, n;

	uri = strcat(     "action=ban&hostname=", uri_escape(autocvar_hostname));
	uri = strcat(uri, "&ip=", uri_escape(ip));
	uri = strcat(uri, "&duration=", ftos(bantime));
	uri = strcat(uri, "&reason=", uri_escape(reason));

	n = tokenize_console(autocvar_g_ban_sync_uri);
	if(n >= MAX_IPBAN_URIS)
		n = MAX_IPBAN_URIS;
	for(i = 0; i < n; ++i)
	{
		if(strstrofs(argv(i), "?", 0) >= 0)
			uri_get(strcat(argv(i), "&", uri), URI_GET_DISCARD); // 0 = "discard" callback target
		else
			uri_get(strcat(argv(i), "?", uri), URI_GET_DISCARD); // 0 = "discard" callback target
	}
}

void OnlineBanList_SendUnban(string ip)
{
	string uri;
	float i, n;

	uri = strcat(     "action=unban&hostname=", uri_escape(autocvar_hostname));
	uri = strcat(uri, "&ip=", uri_escape(ip));

	n = tokenize_console(autocvar_g_ban_sync_uri);
	if(n >= MAX_IPBAN_URIS)
		n = MAX_IPBAN_URIS;
	for(i = 0; i < n; ++i)
	{
		if(strstrofs(argv(i), "?", 0) >= 0)
			uri_get(strcat(argv(i), "&", uri), URI_GET_DISCARD); // 0 = "discard" callback target
		else
			uri_get(strcat(argv(i), "?", uri), URI_GET_DISCARD); // 0 = "discard" callback target
	}
}

string OnlineBanList_Servers;
float OnlineBanList_Timeout;
float OnlineBanList_RequestWaiting[MAX_IPBAN_URIS];

void OnlineBanList_URI_Get_Callback(float id, float status, string data)
{
	float n, i, j, l;
	string ip;
	float timeleft;
	string reason;
	string serverip;
	float syncinterval;
	string uri;

	id -= URI_GET_IPBAN;

	if(id >= MAX_IPBAN_URIS)
	{
		print("Received ban list for invalid ID\n");
		return;
	}

	tokenize_console(autocvar_g_ban_sync_uri);
	uri = argv(id);

	print("Received ban list from ", uri, ": ");

	if(OnlineBanList_RequestWaiting[id] == 0)
	{
		print("rejected (unexpected)\n");
		return;
	}

	OnlineBanList_RequestWaiting[id] = 0;

	if(time > OnlineBanList_Timeout)
	{
		print("rejected (too late)\n");
		return;
	}

	syncinterval = autocvar_g_ban_sync_interval;
	if(syncinterval == 0)
	{
		print("rejected (syncing disabled)\n");
		return;
	}
	if(syncinterval > 0)
		syncinterval *= 60;
	
	if(status != 0)
	{
		print("error: status is ", ftos(status), "\n");
		return;
	}

	if(substring(data, 0, 1) == "<")
	{
		print("error: received HTML instead of a ban list\n");
		return;
	}

	if(strstrofs(data, "\r", 0) != -1)
	{
		print("error: received carriage returns\n");
		return;
	}

	if(data == "")
		n = 0;
	else
		n = tokenizebyseparator(data, "\n");

	if(mod(n, 4) != 0)
	{
		print("error: received invalid item count: ", ftos(n), "\n");
		return;
	}

	print("OK, ", ftos(n / 4), " items\n");

	for(i = 0; i < n; i += 4)
	{
		ip = argv(i);
		timeleft = stof(argv(i + 1));
		reason = argv(i + 2);
		serverip = argv(i + 3);

		dprint("received ban list item ", ftos(i / 4), ": ip=", ip);
		dprint(" timeleft=", ftos(timeleft), " reason=", reason);
		dprint(" serverip=", serverip, "\n");

		timeleft -= 1.5 * autocvar_g_ban_sync_timeout;
		if(timeleft < 0)
			continue;

		l = strlen(ip);
		if(l != 44) // length 44 is a cryptographic ID
		{
			for(j = 0; j < l; ++j)
				if(strstrofs("0123456789.", substring(ip, j, 1), 0) == -1)
				{
					print("Invalid character ", substring(ip, j, 1), " in IP address ", ip, ". Skipping this ban.\n");
					goto skip;
				}
		}

		if(autocvar_g_ban_sync_trusted_servers_verify)
			if((strstrofs(strcat(";", OnlineBanList_Servers, ";"), strcat(";", serverip, ";"), 0) == -1))
				continue;

		if(syncinterval > 0)
			timeleft = min(syncinterval + (OnlineBanList_Timeout - time) + 5, timeleft);
			// the ban will be prolonged on the next sync
			// or expire 5 seconds after the next timeout
		Ban_Insert(ip, timeleft, strcat("ban synced from ", serverip, " at ", uri), 0);
		print("Ban list syncing: accepted ban of ", ip, " by ", serverip, " at ", uri, ": ");
		print(reason, "\n");

:skip
	}
}

void OnlineBanList_Think()
{
	float argc;
	string uri;
	float i, n;
	
	if(autocvar_g_ban_sync_uri == "")
		goto killme;
	if(autocvar_g_ban_sync_interval == 0) // < 0 is okay, it means "sync on level start only"
		goto killme;
	argc = tokenize_console(autocvar_g_ban_sync_trusted_servers);
	if(argc == 0)
		goto killme;

	if(OnlineBanList_Servers)
		strunzone(OnlineBanList_Servers);
	OnlineBanList_Servers = argv(0);
	for(i = 1; i < argc; ++i)
		OnlineBanList_Servers = strcat(OnlineBanList_Servers, ";", argv(i));
	OnlineBanList_Servers = strzone(OnlineBanList_Servers);
	
	uri = strcat(     "action=list&hostname=", uri_escape(autocvar_hostname));
	uri = strcat(uri, "&servers=", uri_escape(OnlineBanList_Servers));

	OnlineBanList_Timeout = time + autocvar_g_ban_sync_timeout;

	n = tokenize_console(autocvar_g_ban_sync_uri);
	if(n >= MAX_IPBAN_URIS)
		n = MAX_IPBAN_URIS;
	for(i = 0; i < n; ++i)
	{
		if(OnlineBanList_RequestWaiting[i])
			continue;
		OnlineBanList_RequestWaiting[i] = 1;
		if(strstrofs(argv(i), "?", 0) >= 0)
			uri_get(strcat(argv(i), "&", uri), URI_GET_IPBAN + i); // 1000 = "banlist" callback target
		else
			uri_get(strcat(argv(i), "?", uri), URI_GET_IPBAN + i); // 1000 = "banlist" callback target
	}
	
	if(autocvar_g_ban_sync_interval > 0)
		self.nextthink = time + max(60, autocvar_g_ban_sync_interval * 60);
	else
		goto killme;
	return;

:killme
	remove(self);
}

#define BAN_MAX 256
float ban_loaded;
string ban_ip[BAN_MAX];
float ban_expire[BAN_MAX];
float ban_count;

string ban_ip1;
string ban_ip2;
string ban_ip3;
string ban_ip4;
string ban_idfp;

void Ban_SaveBans()
{
	string out;
	float i;

	if(!ban_loaded)
		return;

	// version of list
	out = "1";
	for(i = 0; i < ban_count; ++i)
	{
		if(time > ban_expire[i])
			continue;
		out = strcat(out, " ", ban_ip[i]);
		out = strcat(out, " ", ftos(ban_expire[i] - time));
	}
	if(strlen(out) <= 1) // no real entries
		cvar_set("g_banned_list", "");
	else
		cvar_set("g_banned_list", out);
}

float Ban_Delete(float i)
{
	if(i < 0)
		return FALSE;
	if(i >= ban_count)
		return FALSE;
	if(ban_expire[i] == 0)
		return FALSE;
	if(ban_expire[i] > 0)
	{
		OnlineBanList_SendUnban(ban_ip[i]);
		strunzone(ban_ip[i]);
	}
	ban_expire[i] = 0;
	ban_ip[i] = "";
	Ban_SaveBans();
	return TRUE;
}

void Ban_LoadBans()
{
	float i, n;
	for(i = 0; i < ban_count; ++i)
		Ban_Delete(i);
	ban_count = 0;
	ban_loaded = TRUE;
	n = tokenize_console(autocvar_g_banned_list);
	if(stof(argv(0)) == 1)
	{
		ban_count = (n - 1) / 2;
		for(i = 0; i < ban_count; ++i)
		{
			ban_ip[i] = strzone(argv(2*i+1));
			ban_expire[i] = time + stof(argv(2*i+2));
		}
	}

	entity e;
	e = spawn();
	e.classname = "bansyncer";
	e.think = OnlineBanList_Think;
	e.nextthink = time + 1;
}

void Ban_View()
{
	float i, n;
	string msg;
	
	print("^2Listing all existing active bans:\n");
	
	n = 0;
	for(i = 0; i < ban_count; ++i)
	{
		if(time > ban_expire[i])
			continue;
			
		++n; // total number of existing bans
			
		msg = strcat("#", ftos(i), ": ");
		msg = strcat(msg, ban_ip[i], " is still banned for ");
		msg = strcat(msg, ftos(ban_expire[i] - time), " seconds");
		
		print("  ", msg, "\n");
	}
	
	print("^2Done listing all active (", ftos(n), ") bans.\n");
}

float Ban_GetClientIP(entity client)
{
	// we can't use tokenizing here, as this is called during ban list parsing
	float i1, i2, i3, i4;
	string s;

	if(client.crypto_keyfp)
		ban_idfp = client.crypto_idfp;
	else
		ban_idfp = string_null;

	s = client.netaddress;

	i1 = strstrofs(s, ".", 0);
	if(i1 < 0)
		goto ipv6;
	i2 = strstrofs(s, ".", i1 + 1);
	if(i2 < 0)
		return FALSE;
	i3 = strstrofs(s, ".", i2 + 1);
	if(i3 < 0)
		return FALSE;
	i4 = strstrofs(s, ".", i3 + 1);
	if(i4 >= 0)
		s = substring(s, 0, i4);
	
	ban_ip1 = substring(s, 0, i1); // 8
	ban_ip2 = substring(s, 0, i2); // 16
	ban_ip3 = substring(s, 0, i3); // 24
	ban_ip4 = strcat1(s); // 32
	return TRUE;

:ipv6
	i1 = strstrofs(s, ":", 0);
	if(i1 < 0)
		return FALSE;
	i1 = strstrofs(s, ":", i1 + 1);
	if(i1 < 0)
		return FALSE;
	i2 = strstrofs(s, ":", i1 + 1);
	if(i2 < 0)
		return FALSE;
	i3 = strstrofs(s, ":", i2 + 1);
	if(i3 < 0)
		return FALSE;

	ban_ip1 = strcat(substring(s, 0, i1), "::/32"); // 32
	ban_ip2 = strcat(substring(s, 0, i2), "::/48"); // 48
	ban_ip4 = strcat(substring(s, 0, i3), "::/64"); // 64

	if(i3 - i2 > 3) // means there is more than 2 digits and a : in the range
		ban_ip3 = strcat(substring(s, 0, i2), ":", substring(s, i2 + 1, i3 - i2 - 3), "00::/56");
	else
		ban_ip3 = strcat(substring(s, 0, i2), ":0::/56");

	return TRUE;
}

float Ban_IsClientBanned(entity client, float idx)
{
	float i, b, e, ipbanned;
	if(!ban_loaded)
		Ban_LoadBans();
	if(!Ban_GetClientIP(client))
		return FALSE;
	if(idx < 0)
	{
		b = 0;
		e = ban_count;
	}
	else
	{
		b = idx;
		e = idx + 1;
	}
	ipbanned = FALSE;
	for(i = b; i < e; ++i)
	{
		string s;
		if(time > ban_expire[i])
			continue;
		s = ban_ip[i];
		if(ban_ip1 == s) ipbanned = TRUE;
		if(ban_ip2 == s) ipbanned = TRUE;
		if(ban_ip3 == s) ipbanned = TRUE;
		if(ban_ip4 == s) ipbanned = TRUE;
		if(ban_idfp == s) return TRUE;
	}
	if(ipbanned)
	{
		if(!autocvar_g_banned_list_idmode)
			return TRUE;
		if (!ban_idfp)
			return TRUE;
	}
	return FALSE;
}

float Ban_MaybeEnforceBan(entity client)
{
	if(Ban_IsClientBanned(client, -1))
	{
		string s;
		s = strcat("^1NOTE:^7 banned client ", client.netaddress, " just tried to enter\n");
		dropclient(client);
		bprint(s);
		return TRUE;
	}
	return FALSE;
}

.float ban_checked;
float Ban_MaybeEnforceBanOnce(entity client)
{
	if(client.ban_checked)
		return FALSE;
	client.ban_checked = TRUE;
	return Ban_MaybeEnforceBan(self);
}

string Ban_Enforce(float i, string reason)
{
	string s;
	entity e;

	// Enforce our new ban
	s = "";
	FOR_EACH_REALCLIENT(e)
		if(Ban_IsClientBanned(e, i))
		{
			if(reason != "")
			{
				if(s == "")
					reason = strcat(reason, ": affects ");
				else
					reason = strcat(reason, ", ");
				reason = strcat(reason, e.netname);
			}
			s = strcat(s, "^1NOTE:^7 banned client ", e.netaddress, "^7 has to go\n");
			dropclient(e);
		}
	bprint(s);

	return reason;
}

float Ban_Insert(string ip, float bantime, string reason, float dosync)
{
	float i;
	float j;
	float bestscore;

	// already banned?
	for(i = 0; i < ban_count; ++i)
		if(ban_ip[i] == ip)
		{
			// prolong the ban
			if(time + bantime > ban_expire[i])
			{
				ban_expire[i] = time + bantime;
				dprint(ip, "'s ban has been prolonged to ", ftos(bantime), " seconds from now\n");
			}
			else
				dprint(ip, "'s ban is still active until ", ftos(ban_expire[i] - time), " seconds from now\n");

			// and enforce
			reason = Ban_Enforce(i, reason);

			// and abort
			if(dosync)
				if(reason != "")
					if(substring(reason, 0, 1) != "~") // like IRC: unauthenticated banner
						OnlineBanList_SendBan(ip, bantime, reason);

			return FALSE;
		}

	// do we have a free slot?
	for(i = 0; i < ban_count; ++i)
		if(time > ban_expire[i])
			break;
	// no free slot? Then look for the one who would get unbanned next
	if(i >= BAN_MAX)
	{
		i = 0;
		bestscore = ban_expire[i];
		for(j = 1; j < ban_count; ++j)
		{
			if(ban_expire[j] < bestscore)
			{
				i = j;
				bestscore = ban_expire[i];
			}
		}
	}
	// if we replace someone, will we be banned longer than him (so long-term
	// bans never get overridden by short-term bans)
	if(i < ban_count)
	if(ban_expire[i] > time + bantime)
	{
		print(ip, " could not get banned due to no free ban slot\n");
		return FALSE;
	}
	// okay, insert our new victim as i
	Ban_Delete(i);
	dprint(ip, " has been banned for ", ftos(bantime), " seconds\n");
	ban_expire[i] = time + bantime;
	ban_ip[i] = strzone(ip);
	ban_count = max(ban_count, i + 1);

	Ban_SaveBans();

	reason = Ban_Enforce(i, reason);

	// and abort
	if(dosync)
		if(reason != "")
			if(substring(reason, 0, 1) != "~") // like IRC: unauthenticated banner
				OnlineBanList_SendBan(ip, bantime, reason);

	return TRUE;
}

void Ban_KickBanClient(entity client, float bantime, float masksize, string reason)
{
	string ip, id;
	if(!Ban_GetClientIP(client))
	{
		sprint(client, strcat("Kickbanned: ", reason, "\n"));
		dropclient(client);
		return;
	}

	// who to ban?
	switch(masksize)
	{
		case 1:
			ip = strcat1(ban_ip1);
			break;
		case 2:
			ip = strcat1(ban_ip2);
			break;
		case 3:
			ip = strcat1(ban_ip3);
			break;
		case 4:
		default:
			ip = strcat1(ban_ip4);
			break;
	}
	if(ban_idfp)
		id = strcat1(ban_idfp);
	else
		id = string_null;

	Ban_Insert(ip, bantime, reason, 1);
	if(id)
		Ban_Insert(id, bantime, reason, 1);
	/*
	 * not needed, as we enforce the ban in Ban_Insert anyway
	// and kick him
	sprint(client, strcat("Kickbanned: ", reason, "\n"));
	dropclient(client);
	 */
}
