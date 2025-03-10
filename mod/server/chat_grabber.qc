#include "chat_grabber.qh"

string autocvar_chat_dest_udp; // UDP protocol socket destination for caught chat messages
string autocvar__player_list; // internal list of player IPs, not to be shared
bool autocvar_chat_grabber_show_id = false; // show player IDs in the message
bool autocvar_chat_grabber_show_mapchange = true; // show map changes

REGISTER_MUTATOR(chat_grabber, true);

STATIC_INIT_LATE(chat_grabber)
{
	if(autocvar_chat_dest_udp == "")
		return;

	if(autocvar_chat_grabber_show_mapchange)
	{
		string formatted = sprintf("- *Now playing **%s**", mapname);
		if(world.message != "")
			formatted = strcat(formatted, " (", MakeConsoleSafe(world.message), ")");
		formatted = strcat(formatted, "*");
		sendto(autocvar_chat_dest_udp, formatted);
	}
}

MUTATOR_HOOKFUNCTION(chat_grabber, PreFormatMessage)
{
	entity this = M_ARGV(0, entity);
	string msg = M_ARGV(1, string);
	if(autocvar_chat_dest_udp == "")
		return;
	if(this.muted)
		return;

	entity client = this;
	string nickname = strdecolorize(GetCallerName(client));
	string output = strdecolorize(msg);

	string formatted = sprintf("<**%s**>: %s", nickname, output);
	if(autocvar_chat_grabber_show_id)
		formatted = sprintf("#%d %s", client.playerid, formatted);
	sendto(autocvar_chat_dest_udp, formatted);
}

MUTATOR_HOOKFUNCTION(chat_grabber, ClientConnect)
{
	entity this = M_ARGV(0, entity);
	if(autocvar_chat_dest_udp == "")
		return;

	if(PlayerInIPList(this, autocvar__player_list))
		return;

	// storing IP only as crypto is unreliable
	string theid = this.netaddress;
	cvar_set("_player_list", cons(autocvar__player_list, theid));

	string nickname = strdecolorize(GetCallerName(this));
	string output = strcat("*", nickname, " has joined the server", "*");
	sendto(autocvar_chat_dest_udp, output);
}

MUTATOR_HOOKFUNCTION(chat_grabber, ClientDisconnect)
{
	entity this = M_ARGV(0, entity);
	if(autocvar_chat_dest_udp == "")
		return;

	entity client = this;
	string nickname = strdecolorize(GetCallerName(client));
	string output = strcat("*", nickname, " has left the server", "*");
	sendto(autocvar_chat_dest_udp, output);

	// rebuild the string minus our details
	string tmp_string = "";
	FOREACH_WORD(autocvar__player_list, it != client.netaddress,
	{
		tmp_string = cons(tmp_string, it);
	});

	cvar_set("_player_list", tmp_string);
}

void chat_grabber_CheckClients()
{
	if(autocvar_chat_dest_udp == "")
		return;

	// basically redo the entire list with the current players
	// ensures no dangling references to players who leave mid-connect
	string tmp_string = "";
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		tmp_string = cons(tmp_string, it.netaddress);
	});
	cvar_set("_player_list", tmp_string);
}

MUTATOR_HOOKFUNCTION(chat_grabber, MatchEnd_BeforeScores)
{
	chat_grabber_CheckClients();
}

void sendto(string destination, string msg)
{
	//LOG_INFO("sendto: sending a packet");
	localcmd(sprintf("packet %s \"%s\"\n", destination, msg));
}
