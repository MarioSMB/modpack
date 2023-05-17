#include "body.qh"

void body_pickup(entity this, entity targ)
{
	if(targ.owner != this.enemy)
		return;
	this.action = donothing;

	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		vector r = pickupitem(targ.owner, GetSlot(this, i));
		if(r)
			dropitem(targ.owner, r);
	}
	targ.owner.gp = targ.owner.gp + this.gp;
	
	delete(this);
}

entity find_body(entity this)
{
	FOREACH_ENTITY_CLASS("body", it.enemy == this.owner,
	{
		return it;
	});
	return NULL;	
}

bool drop_body(entity this)
{
	if(!IS_PLAYER(this.owner))
		return false;
		
	if(find_body(this))
		return false;

	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
		SetSlot(this, i, GetSlot(this.owner, i));
	this.gp = this.owner.gp;
	this.enemy = this.owner;
	this.effects |= EF_SELECTABLE;
	this.flags = FL_ITEM;		// make extra wide
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);
	this.classname = "body";
	this.action = body_pickup;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.netname = this.owner.netname;

	setorigin(this, this.origin);
	return true;
}

void regain_body(entity this)
{
	entity e = find_body(this);
	if(e)
		body_pickup(e, this);
}
