#include "vote.qh"

string autocvar_chat_dest_udp; // UDP protocol socket destination for caught chat messages

void chat_grabber_PreFormatMessage(entity this, string msg)
{
	if(autocvar_chat_dest_udp == "")
		return;

	entity client = this;
	string nickname = strdecolorize(GetCallerName(client));

	string formatted = sprintf("#%d <%s>: %s", client.playerid, nickname, msg);
	sendto(autocvar_chat_dest_udp, formatted);
}

void sendto(string destination, string msg)
{
	//LOG_INFO("sendto: sending a packet");
	localcmd(sprintf("packet %s \"%s\"\n", destination, msg));
}
