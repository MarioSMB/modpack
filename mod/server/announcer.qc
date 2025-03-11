// FEATURE: Custom "newrecord" announcement can be played when a new record is set in CTF

ACCUMULATE
void write_recordmarker(entity pl, float tstart, float dt)
{
	if(g_ctf)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_ANNCE, ANNCE_NEWRECORD);
	}
}
