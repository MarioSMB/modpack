#include "pogo.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC

METHOD(Pogo, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	// TODO: handle bouncing here? maybe best to keep it on the champion!
}
METHOD(Pogo, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Pogo, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
