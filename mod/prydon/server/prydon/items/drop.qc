#include "drop.qh"

void dropitem(entity this, vector itslot)
{
	if(!itslot.x)
		return;

	entity newitem = spawn();
	if(this.player)
		this = this.player;
	setorigin(newitem, (this.absmin + this.absmax) * 0.5);
	makevectors(this.angles + this.lip * '0 1 0');
	this.lip = this.lip + 45;
	newitem.velocity = v_up * 150 + v_forward * 100;
	newitem.slot1 = itslot;

	newitem.avelocity = random() *  '0 300 0' + '0 0 600';
	_sound(newitem, CHAN_BODY, "items/flip.wav", 1, ATTN_NORM);
	it_simplestat(this, itslot);
	if(stat_it == IT_GOLD || stat_it == IT_BOOK)
		newitem.frame = 2;
	spawnfunc_item(newitem);
}
 
void dropgold(entity this, float g)
{
	stat_it = IT_GOLD;
	stat_id = 1;
	stat_pref = stat_suf = 0;	
	while(g)
	{
		stat_dur = g;
		if(stat_dur > 15000)
			stat_dur = 15000;
		g -= stat_dur;
		dropitem(this, it_setstat());
	}
}

void dropallitems(entity this)
{
	vector itslot;

	if(this.owner)
		this = this.owner;
	for(int i = 1; i <= TOTAL_SLOTS; i += 1)
	{
		if(this.droprandom & (2 ** i))
		{
			if(random() > 0.6)
			{
				itslot = GetSlot(this, i);
				dropitem(this, randitem(this, itslot.x, itemvalue + this.value, false));
			}
		}
		else
		{
			itslot = GetSlot(this, i);
			if(itslot)
			{
				Unequip(this, i, 0);
				dropitem(this, GetSlot(this, i));
			}
			ClearSlot(this, i);
		}
	}

	dropgold(this, this.gp);
	this.gp = 0;
}