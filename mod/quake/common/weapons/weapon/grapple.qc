#include "grapple.qh"

#ifdef SVQC
#include "../../../server/rogue/grapple.qh"
#endif

#ifdef SVQC
METHOD(Grapple, wr_think, void(entity thiswep, entity actor))
{
	if(!actor.hook_out)
		player_grapple1(actor);
	else
		player_grapple3(actor);
	actor.attack_finished = time + 0.1;
}
METHOD(Grapple, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
