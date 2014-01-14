void CampaignSetup(float n)
{
	localcmd("set g_campaign 1\n");
	localcmd("set _campaign_name \"");
		localcmd(campaign_name);
		localcmd("\"\n");
	localcmd("set _campaign_index ");
		localcmd(ftos(campaign_offset + n));
		localcmd("\n");
	localcmd("disconnect\nmaxplayers 16\n");
	MapInfo_LoadMap(campaign_mapname[n], 1);
}
