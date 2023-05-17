#include "map.qh"

#include "../subs/reqs.qh"

void item_touch(entity this, entity toucher)
{
	if(!toucher)
	{
		it_simplestat(this, this.slot1);
		_sound(this, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
		this.avelocity = '0 0 0';
		this.angles_z = this.angles_x = 0;
		this.frame = 0;
		settouch(this, func_null);
		if(this.gp)
			this.action = openitembuy;
		else
			this.action = action_pickup;
	}
	else if(IS_ONGROUND(this))
	{
		if(this.gp)
			this.action = openitembuy;
		else
			this.action = action_pickup;
	}
}

spawnfunc(item)
{
	this.classname = "item";
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	legacy_item(this, 0);
	it_simplestat(this, this.slot1);
	
	if(!stat_it && !this.fallz)
	{
		delete(this);
		return;
	}
	itemapplyeffects(this);
	
	setsize (this, '-16 -16 0', '16 16 5');
	this.flags = FL_ITEM;		// make extra wide
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);
	this.effects |= EF_SELECTABLE;
	settouch(this, item_touch);
	if(this.menu)
		this.gp = this.menu;
}

spawnfunc(shopitem)
{
	if(!this.angles_y)
		this.angles_y = random() * 360;
		
	if(this.fallz)
	{
		legacy_item(this, 1);
		this.slot1 = randitem(this, this.slot1_x, itemvalue, this.fallz);
		if(this.fallz & 1)
		{
			if(!this.netname)
				this.netname = "wepshop";
		}
		else if(this.fallz & 2)
		{
			if(!this.netname)
				this.netname = "magshop";
		}
	}
	else
		legacy_item(this, 0);
	it_simplestat(this, this.slot1);
	it_itemstat(this);
	if(!this.gp)
		this.gp = stat_price; // fixme
	spawnfunc_item(this);
}

spawnfunc(armoryitem)
{
	this.fallz |= 1;
	spawnfunc_shopitem(this);
}

spawnfunc(magicitem)
{
	this.fallz |= 2;
	spawnfunc_shopitem(this);
}
