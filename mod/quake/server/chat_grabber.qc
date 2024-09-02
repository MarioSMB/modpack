#include "vote.qh"

string autocvar_chat_dest_udp; // UDP protocol socket destination for caught chat messages

STATIC_INIT_LATE(chat_grabber)
{
	for(int j = 1; j <= maxclients; ++j)
	{
		string slotvar = strcat("_player_", ftos(j));
		registercvar(slotvar, "");
	}
}

void chat_grabber_PreFormatMessage(entity this, string msg)
{
	if(autocvar_chat_dest_udp == "")
		return;

	entity client = this;
	string nickname = strdecolorize(GetCallerName(client));
	string output = strdecolorize(msg);

	string formatted = sprintf("#%d <%s>: %s", client.playerid, nickname, output);
	sendto(autocvar_chat_dest_udp, formatted);
}

void chat_grabber_ClientConnect(entity this)
{
	if(autocvar_chat_dest_udp == "")
		return;

	string slotvar = strcat("_player_", ftos(this.playerid));
	if(cvar_string(slotvar) == this.netname)
		return; // already joined, don't show again

	// store nickname to compare on next connect
	cvar_set(slotvar, this.netname);

	string nickname = strdecolorize(GetCallerName(this));
	string output = strcat(nickname, " has joined the server");
	sendto(autocvar_chat_dest_udp, output);
}

void chat_grabber_ClientDisconnect(entity this)
{
	if(autocvar_chat_dest_udp == "")
		return;

	string nickname = strdecolorize(GetCallerName(this));
	string output = strcat(nickname, " has left the server");
	sendto(autocvar_chat_dest_udp, output);

	// only called when the match hasn't ended, relatively safe to clear
	string slotvar = strcat("_player_", ftos(this.playerid));
	cvar_set(slotvar, "");
}

void sendto(string destination, string msg)
{
	//LOG_INFO("sendto: sending a packet");
	localcmd(sprintf("packet %s \"%s\"\n", destination, msg));
}
