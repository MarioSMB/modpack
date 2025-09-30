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

bool Challenge_Active(int ctype)
{
#ifdef SVQC
	return !!(challenge & ctype);
#else
	return !!(STAT(CHALLENGE) & ctype);
#endif
}

#ifdef SVQC
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

	FOREACH_WORD(autocvar_sv_quake_challenge, true,
	{
		challenge |= Challenge_fromstring(it);
	});
}
#endif
