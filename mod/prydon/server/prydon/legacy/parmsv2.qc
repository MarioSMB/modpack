void() legacy_parmsv2 =
{	
/* Prydon 1.5 */
	float i;

	if (parm_load_begin())
	{
		if (fileaccess)
		{
			qread(); // read past pin
		}
		self.health = 		parm_load(256);
		self.max_health = 	parm_load(256);
		self.mana =		parm_load(256);
		self.questlog =		parm_load(2) * 2;
		self.exp = 		parm_load(1048576);
		self.str = 		parm_load(256);
		self.mag =		parm_load(256);
		self.dex = 		parm_load(256);
		self.vit = 		parm_load(256);
		self.agil = 		parm_load(256);
		self.luck =		parm_load(256);
		self.ptd =		parm_load(128);
		self.options =          parm_load(32);

		for (i = 1; i <= 16; i = i + 1)
			SetSpellLevel(self, i, parm_load(8));
		
		self.spell =		parm_load(64);
		self.gp =		parm_load(32768);
		self.equip =		parm_load(65536);
		for (i = 1; i <= TOTAL_SLOTS; i = i + 1)
			SetSlot(self, i, decodeitem());
	
		parm_load_end();
	}
	else
		SetNewParms();
	if (!self.exp)
		self.exp = 1;
	self.lvl = LvlForExp(self.exp);
}