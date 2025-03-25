// FEATURE: Custom "newrecord" announcement can be played when a new record is set in CTF

bool newrecord_override(entity this);

ACCUMULATE
void write_recordmarker(entity pl, float tstart, float dt)
{
	if(g_ctf)
	{
		if(!newrecord_override(pl))
			Send_Notification(NOTIF_ALL, NULL, MSG_ANNCE, ANNCE_NEWRECORD);
	}
}
