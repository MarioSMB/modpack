//FEATURE: Option to enable extra normally hidden voice messages (g_player_sounds_extra)

AUTOCVAR(g_player_sounds_extra, bool, false, "allow access to additional player voice messages");

STATIC_INIT_LATE(PlayerSoundsExtra)
{
	if(!autocvar_g_player_sounds_extra)
		return;

	// TRICK: only voice messages set voice type
	FOREACH(PlayerSounds, it.m_playersoundvt,
	{
		it.instanceOfVoiceMessage = true;
	});
}
