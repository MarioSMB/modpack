#include "challenges.qh"

int Challenge_fromstring(string chalstr)
{
	switch(chalstr)
	{
		case "onehp": return CHALLENGE_ONEHP;
		case "bonk": return CHALLENGE_BONK;
	}

	return CHALLENGE_NONE;
}

STATIC_INIT(Challenges)
{
	challenge = CHALLENGE_NONE;

	if(deathmatch)
		return;

	if(world.worldtype == WORLDTYPE_SLIDE || world.worldtype == WORLDTYPE_SKATE || world.worldtype == WORLDTYPE_DODGEBALL)
		return;

	// can't check for horde the classic way this early
	if(find(NULL, classname, "horde_manager") || find(NULL, classname, "info_qonquer"))
		return;

	challenge = Challenge_fromstring(autocvar_sv_quake_challenge);
}
