//FEATURE: Hidden player voice messages are accessible: flagcarriertakingdamage getflag affirmative attacking defending roaming onmyway droppedflag negative seenenemy

STATIC_INIT_LATE(PlayerSoundsExtra)
{
	// TRICK: only voice messages set voice type
	FOREACH(PlayerSounds, it.m_playersoundvt,
	{
		it.instanceOfVoiceMessage = true;
	});
}
