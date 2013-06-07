MUTATOR_HOOKFUNCTION(grunt_PlayerJump)
{
	if(self.flags & FL_ONGROUND)
		PlayerSound(playersound_jump, CH_PLAYER, VOICETYPE_PLAYERSOUND);
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(grunt_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":JumpGrunt");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_jump_grunt)
{
	MUTATOR_HOOK(PlayerJump, grunt_PlayerJump, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, grunt_BuildMutatorsString, CBC_ORDER_ANY);

	return FALSE;
}
