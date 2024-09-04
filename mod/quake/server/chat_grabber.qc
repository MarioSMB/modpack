#include "vote.qh"

string autocvar_chat_dest_udp; // UDP protocol socket destination for caught chat messages
string autocvar__player_list; // internal list of player IPs, not to be shared
bool autocvar_chat_grabber_show_id = false; // show player IDs in the message
bool autocvar_chat_grabber_show_circle = false; // NOTE: doesn't work currently! show circle emoji behind each player to differentiate them

const int CIRCLES = 8; // discord comes with 8 unique circle types
string chat_circles[CIRCLES] = {":blue_circle:", ":brown_circle:", ":green_circle:", ":orange_circle:", ":purple_circle:", ":red_circle:", ":white_circle:", ":yellow_circle:"};

void chat_grabber_PreFormatMessage(entity this, string msg)
{
	if(autocvar_chat_dest_udp == "")
		return;

	entity client = this;
	string nickname = strdecolorize(GetCallerName(client));
	string output = strdecolorize(msg);

	string formatted = sprintf("<**%s**>: %s", nickname, output);
	if(autocvar_chat_grabber_show_circle)
	{
		int chosen = (client.playerid - 1) % CIRCLES;
		string mycircle = chat_circles[chosen];
		// TODO: custom handler?
		if(substring(nickname, 0, 5) == "Mario")
			mycircle = ":circled_m:";
		else if(nickname == "daro")
			mycircle = ":wheel:";
		else if(strstrofs(nickname, "Musicgoat", 0) >= 0)
			mycircle = ":goat:";
		formatted = strcat(mycircle, " ", formatted);
	}
	if(autocvar_chat_grabber_show_id)
		formatted = sprintf("#%d %s", client.playerid, formatted);
	sendto(autocvar_chat_dest_udp, formatted);
}

void chat_grabber_ClientConnect(entity this)
{
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

void chat_grabber_ClientDisconnect(entity this)
{
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
	cvar_set("_player_list", "");

	string tmp_string = "";
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		tmp_string = cons(tmp_string, it.netaddress);
	});
	cvar_set("_player_list", tmp_string);
}

void sendto(string destination, string msg)
{
	//LOG_INFO("sendto: sending a packet");
	localcmd(sprintf("packet %s \"%s\"\n", destination, msg));
}
