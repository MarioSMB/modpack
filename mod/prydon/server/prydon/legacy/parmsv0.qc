void() legacy_parmsv0 =
{
	float i;
	
/* Prydon 1.0 - 1.2 */
	self.health = decode(parm1, 1);
	self.max_health = decode(parm1, 2);
	self.mana = decode(parm1, 3);
	self.exp = parm2;
	self.str = decode(parm3, 1);
	self.mag = decode(parm3, 2);
	self.dex = decode(parm3, 3);
	self.vit = decode(parm4, 1);
	self.agil = decode(parm4, 2);
	self.luck = decode(parm4, 3);
	self.spells1 = parm5;
	self.spells2 = parm6;
	decompress_spells(self);
	self.spell = decode(parm7, 1);
	self.questlog = decode(parm7, 2);
	//self.skill = decode(parm7, 3);
	self.ptd = decode(parm8, 1);
	self.equip = decode(parm8, 2);
	self.lvl = decode(parm8, 3);
	self.slot1 = legacy_itemv1(parm9);
	self.slot2 = legacy_itemv1(parm10);
	self.slot3 = legacy_itemv1(parm11);
	self.slot4 = legacy_itemv1(parm12);
	self.slot5 = legacy_itemv1(parm13);
	self.slot6 = legacy_itemv1(parm14);
	self.slot7 = legacy_itemv1(parm15);
	self.slot8 = legacy_itemv1(parm16);
	self.gp = ceil(itemcount(IT_GOLD) / 10);
	for (i = 1; i <= 8; i = i + 1) // we're converting up, don't use TOTAL_SLOTS
	{
		it_simplestat(GetSlot(self, i));
		if (stat_it == IT_GOLD)
			ClearSlot(self, i);
	}
};