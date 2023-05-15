void() legacy_parmsv1 =
{

	/* Prydon 1.3 - 1.4 */
	
	self.health = decode(parm1, 1);
	self.max_health = decode(parm1, 2);
	self.mana = decode(parm1, 3);
	self.exp = parm2;
	if (!self.exp)
	{
		self.exp = 1;
		self.lvl = 0;
		self.questlog = 2;
	}
	else if (self.exp < 0)
	{
		self.questlog = 2;
		self.exp = 0 - self.exp;
		self.lvl = LvlForExp(self.exp);
	}
	else
	{
		self.questlog = 0;
		self.lvl = LvlForExp(self.exp);
	}
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
	self.ptd = decode(parm7, 2);
	if (self.ptd & 128)
	{
		self.options = self.options | OPT_SEEN_PTD;
		self.ptd = self.ptd & 127;
	}
	self.equip = decode(parm7, 3);
	self.gp = ceil(parm8 / 10);
	self.slot1 = legacy_itemv1(parm9);
	self.slot2 = legacy_itemv1(parm10);
	self.slot3 = legacy_itemv1(parm11);
	self.slot4 = legacy_itemv1(parm12);
	self.slot5 = legacy_itemv1(parm13);
	self.slot6 = legacy_itemv1(parm14);
	self.slot7 = legacy_itemv1(parm15);
	self.slot8 = legacy_itemv1(parm16);
	if (stashent)
	{
		self.slot9 = legacy_itemv1(stashent.slot1_x);
		self.slot10 = legacy_itemv1(stashent.slot2_x);
		self.slot11 = legacy_itemv1(stashent.slot3_x);
		self.slot12 = legacy_itemv1(stashent.slot4_x);
		self.slot13 = legacy_itemv1(stashent.slot5_x);
		self.slot14 = legacy_itemv1(stashent.slot6_x);
		self.slot15 = legacy_itemv1(stashent.slot7_x);
		self.slot16 = legacy_itemv1(stashent.slot8_x);
	}
};