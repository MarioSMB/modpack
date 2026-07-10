#include "all.qh"

#ifdef GAMEQC
REGISTER_NET_LINKED(ENT_CLIENT_TURRET)

.float max_health;

float turret_getpower(int tlevel, float pscale)
{
	float mypower = (1 + tlevel * ((1.2 - 0.3) * pscale));

	return mypower;
}
#endif
