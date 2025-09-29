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
	return (STAT(CHALLENGE) & ctype);
}

#ifdef SVQC
void Challenges_DelayedInit(entity this)
{
	delete(this);

	if(deathmatch)
		return;

	if(world.worldtype == WORLDTYPE_SLIDE || world.worldtype == WORLDTYPE_SKATE || world.worldtype == WORLDTYPE_DODGEBALL)
		return;

	if(horde_ent)
		return;

	FOREACH_WORD(autocvar_sv_quake_challenge, true,
	{
		challenge |= Challenge_fromstring(it);
	});
}

STATIC_INIT(Challenges)
{
	challenge = CHALLENGE_NONE;

	// delay by a single frame to allow necessary entities to spawn in (namely horde)
	entity temp = new_pure(challenges_delayedinit);
	setthink(temp, Challenges_DelayedInit);
	temp.nextthink = time;
}
#endif
