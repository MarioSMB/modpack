//#include <common/mapobjects/subs.qc>

#ifdef SVQC
void fake_remove(entity e)
{
	e.modelindex = 0;
	e.solid = SOLID_NOT;
	set_movetype(e, MOVETYPE_NONE);
	setorigin(e, '0 0 -90000'); // TODO: needs a better way of "hiding" the entity!
}

void sub_fake_remove(entity this, entity toucher)
{
	fake_remove(this);
}

/*QUAKED info_null(0 0.5 0)(-4 -4 -4)(4 4 4)
Used as a positional target for spotlights, etc.
*/
spawnfunc(info_null)
{
	//delete(this);
}
#endif
