#include "parmsv0.qh"

#include "../subs/math.qh"

void legacy_parmsv0(entity this)
{
/* Prydon 1.0 - 1.2 */
	this.health = decode(parm1, 1);
	this.max_health = decode(parm1, 2);
	this.mana = decode(parm1, 3);
	this.experience = parm2;
	this.str = decode(parm3, 1);
	this.mag = decode(parm3, 2);
	this.dex = decode(parm3, 3);
	this.vit = decode(parm4, 1);
	this.agil = decode(parm4, 2);
	this.luck = decode(parm4, 3);
	this.spells1 = parm5;
	this.spells2 = parm6;
	decompress_spells(this);
	this.spell = decode(parm7, 1);
	this.questlog = decode(parm7, 2);
	//this.skill = decode(parm7, 3);
	this.ptd = decode(parm8, 1);
	this.equip = decode(parm8, 2);
	this.lvl = decode(parm8, 3);
	this.slot1 = legacy_itemv1(parm9);
	this.slot2 = legacy_itemv1(parm10);
	this.slot3 = legacy_itemv1(parm11);
	this.slot4 = legacy_itemv1(parm12);
	this.slot5 = legacy_itemv1(parm13);
	this.slot6 = legacy_itemv1(parm14);
	this.slot7 = legacy_itemv1(parm15);
	this.slot8 = legacy_itemv1(parm16);
	this.gp = ceil(itemcount(this, IT_GOLD) / 10);
	for(int i = 1; i <= 8; i = i + 1) // we're converting up, don't use TOTAL_SLOTS
	{
		it_simplestat(this, GetSlot(this, i));
		if(stat_it == IT_GOLD)
			ClearSlot(this, i);
	}
}
