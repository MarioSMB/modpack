void() legacy_fixinv =
{
	if (self.slot1_x > BASEITEMS)
		self.slot1 = legacy_itemv1(self.slot1_x);
	if (self.slot2_x > BASEITEMS)
		self.slot2 = legacy_itemv1(self.slot2_x);
	if (self.slot3_x > BASEITEMS)
		self.slot3 = legacy_itemv1(self.slot3_x);
	if (self.slot4_x > BASEITEMS)
		self.slot4 = legacy_itemv1(self.slot4_x);
	if (self.slot5_x > BASEITEMS)
		self.slot5 = legacy_itemv1(self.slot4_x);
	if (self.slot6_x > BASEITEMS)
		self.slot6 = legacy_itemv1(self.slot4_x);
	if (self.slot7_x > BASEITEMS)
		self.slot7 = legacy_itemv1(self.slot4_x);
	if (self.slot8_x > BASEITEMS)
		self.slot8 = legacy_itemv1(self.slot4_x);

};
void() legacy_npc =
{
	if (self.rightarm_x > IT_SPEARS)
		self.rightarm_x = self.rightarm_x + 32;
	if (self.leftarm_x > IT_SPEARS)
		self.leftarm_x = self.leftarm_x + 32;
		
	legacy_fixinv();

	if (self.spec & SPEC_SPEED)
		self.aspeed = self.aspeed + 33;
	if (self.gotstuff > 16)
		self.altaction = self.gotstuff + 8;
	else
		self.altaction = self.gotstuff;
	if (self.spell > 16)
		self.spell = self.spell + 8;
	if (self.spells1 > 7 || self.spells2 > 7)
		decompress_spells(self);
	if (self.message == "talk")
		self.message = "l_talk";
}
