#include "parmsv1.qh"

#include "../stats/exp.qh"
#include "../subs/math.qh"

void legacy_parmsv1(entity this)
{

	/* Prydon 1.3 - 1.4 */
	
	this.health = decode(parm1, 1);
	this.max_health = decode(parm1, 2);
	this.mana = decode(parm1, 3);
	this.experience = parm2;
	if(!this.experience)
	{
		this.experience = 1;
		this.lvl = 0;
		this.questlog = 2;
	}
	else if(this.experience < 0)
	{
		this.questlog = 2;
		this.experience = 0 - this.experience;
		this.lvl = LvlForExp(this.experience);
	}
	else
	{
		this.questlog = 0;
		this.lvl = LvlForExp(this.experience);
	}
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
	this.ptd = decode(parm7, 2);
	if(this.ptd & 128)
	{
		this.options |= OPT_SEEN_PTD;
		this.ptd = this.ptd & 127;
	}
	this.equip = decode(parm7, 3);
	this.gp = ceil(parm8 / 10);
	this.slot1 = legacy_itemv1(parm9);
	this.slot2 = legacy_itemv1(parm10);
	this.slot3 = legacy_itemv1(parm11);
	this.slot4 = legacy_itemv1(parm12);
	this.slot5 = legacy_itemv1(parm13);
	this.slot6 = legacy_itemv1(parm14);
	this.slot7 = legacy_itemv1(parm15);
	this.slot8 = legacy_itemv1(parm16);
	if(stashent)
	{
		this.slot9 = legacy_itemv1(stashent.slot1_x);
		this.slot10 = legacy_itemv1(stashent.slot2_x);
		this.slot11 = legacy_itemv1(stashent.slot3_x);
		this.slot12 = legacy_itemv1(stashent.slot4_x);
		this.slot13 = legacy_itemv1(stashent.slot5_x);
		this.slot14 = legacy_itemv1(stashent.slot6_x);
		this.slot15 = legacy_itemv1(stashent.slot7_x);
		this.slot16 = legacy_itemv1(stashent.slot8_x);
	}
}
