void() monster =
{
	if (!self.lvl)
		self.lvl = 1;
	if (!self.ai)
		self.ai = AI_HUNT_PLAYER;
	if (!self.team)
		self.team = 1;
	self.classname = "monster";
	self.flags = self.flags | FL_MONSTER;
	
	npc();
}
void() monster_randomize =
{
	local float r, pf, sf;
	self.lvl = self.lvl * skillm;
	
	self.str = self.agil = self.vit = self.mag = self.dex = self.luck = (self.lvl * 2);
	self.max_health = 5 * self.lvl;

	self.max_mana = 10 * self.lvl;
	r = rint(self.lvl + (random() * (self.lvl / 2)) - (self.lvl / 4)) - self.value;
	if (random() < 0.5)
	{
		if (r < monsvalue)
		{
			// apply a good prefix/suffix to make the monster better
			if (random() < 0.2)
				pf = ceil(random() * MP_GOOD) + MP_BAD; // # of bad prefixes
			if (random() < 0.2)
				sf = ceil(random() * MS_GOOD) + MS_BAD; // # of bad suffixes
			r = r + ((pf - MP_BAD) * 2) - ((sf - MS_BAD) * 2);
		}
		if (r > monsvalue)
		{
			// avoid making monsters TOO bad
			if (random() < 0.2)
				pf = ceil(random() * MP_BAD); // # of bad prefixes
			if (random() < 0.2)
				sf = ceil(random() * MS_BAD); // # of bad suffixes
			r = r - (pf * 2) - (sf * 2);		
		}		
	}
	if (pf == MP_INFERIOR)
	{
		self.str = self.str - 5;
		self.max_health = ceil(self.max_health * 0.5);
		self.tohit = self.tohit - 10;
		self.scale = 0.9;
	}
	else if (pf == MP_WEAK)
	{
		self.str = self.str - 5;
		self.max_health = ceil(self.max_health * 0.25);
	}
	else if (pf == MP_SICK)
		self.max_health = ceil(self.max_health * 0.1);
	else if (pf == MP_CRIPPLED)
	{
		self.tohit = self.tohit - 60;
		self.dodge = self.dodge - 60;
	}
	else if (pf == MP_ELDERLY)
	{
		self.agil = self.agil - 10;
		self.speed = self.speed * 0.5;
	}
	else if (pf == MP_CLUMSY)
		self.dex = self.dex - 10;
		
	else if (pf == MP_FAST)
	{
		self.agil = self.agil + 10;
		self.speed = self.speed * 2;
		self.aspeed = self.aspeed + 33;
	}
	else if (pf == MP_MUSCULAR)
	{
		// muscular
		self.str = self.str + 25;
	}
	else if (pf == MP_SUPERIOR)
	{
		// superior
		self.tohit = self.tohit + 50;
		self.str = self.str + 10;
		self.max_health = self.max_health * 1.8;
		self.scale = 1.1;
	}
	else if (pf == MP_HEALTHY)
	{
		self.max_health = self.max_health * 3;
	}
	else if (pf == MP_FIERY)
	{
		self.fire = self.fire + 2 + floor(0.25 * self.lvl);
		self.res_fire = self.res_fire + 30;
	}
	else if (pf == MP_VILE)
	{
		self.poidam = self.poidam + 5;
		self.res_poison = self.res_poison + 30;
	}
	else if (pf == MP_HELL)
	{
		self.fire = self.fire + 15;
		self.res_fire = self.res_fire + 30;
		self.agil = self.agil + 5;
		self.speed = self.speed * 1.5;
		self.aspeed = self.aspeed + 10;
	}
	else if (pf == MP_ARMOR)
	{
		self.ac = self.ac + 10 * self.lvl;
	}
	else if (pf == MP_WARDED)
	{
		self.res_mag = self.res_mag + 10  + floor(0.1 * self.lvl);
	}
	else if (pf == MP_BURNING)
	{
		self.fire = self.fire + 5  + floor(0.25 * self.lvl);
		self.res_fire = self.res_fire + 80;
	}
	else if (pf == MP_ENRAGED)
	{
		self.tohit = self.tohit + 50;
		self.speed = self.speed * 1.2;
		self.aspeed = self.aspeed + 10;
	}
	else if (pf == MP_CHARGED)
	{
		self.lit = 5 + floor(0.25 * self.lvl);
		self.res_lit = self.res_lit + 50 + floor(0.25 * self.lvl);
	}
	else if (pf == MP_FROSTY)
	{
		self.cold = 5 + floor(0.25 * self.lvl);
		self.res_cold = self.res_cold + 50 + floor(0.25 * self.lvl);
	}
	if (sf == MS_PUPIL)
		self.tohit = self.tohit - 7;
	else if (sf == MS_OAF)
	{
		self.tohit = self.tohit - 10;
		self.dodge = self.dodge - 10;
	}
	else if (sf == MS_LUMMOX)
	{
		self.dex = self.dex - 20;
	}
	else if (sf == MS_IMBECILE)
	{
		self.mag = self.mag - 10;
		self.max_mana = 10;
	}
	else if (sf == MS_WEAKLING)
	{
		self.str = self.str - 50;
	}
	else if (sf == MS_DAWDLER)
	{
		self.speed = self.speed * 0.5;
	}
	else if (sf == MS_VAMPIRE)
		self.spec = self.spec | SPEC_STEAL_LIFE;
	else if (sf == MS_MASTER)
	{
		// superior
		self.tohit = self.tohit + 50;
		self.str = self.str + 10;
		self.max_health = self.max_health * 1.8;
	}
	else if (sf == MS_CHAMPION)
	{
		// superior
		self.tohit = self.tohit + 50;
		self.str = self.str + 20;
		self.dex = self.dex + 10;
		self.max_health = self.max_health * 3;
		self.visibility = 30;
	}
	else if (sf == MS_WIZARD)
	{
		if (random() < 0.5)
			self.spell = SP_ZAP;
		else
			self.spell = SP_FIREBALL; // for now
	}
	else if (sf == MS_MAGE)
	{
		self.spell = SP_ZAP; // for now;
	}
	else if (sf == MS_CLERIC)
	{
		self.spell = SP_HEALOTHER - 8; // for now HACK! -- legacy_npc adds 8 to all spells over 16
		self.health_regen = 10;
	}
	else if (sf == MS_CHIEFTAIN)
	{
		self.max_health = self.max_health * 3;
		self.res_mag = self.res_mag + 10 + floor(0.25 * self.lvl);
		self.ac = self.ac + 10 + floor(0.25 * self.lvl);
	}
	else if (sf == MS_BESERKER)
	{
		self.tohit = self.tohit - 10;
		self.agil = self.agil + 10;
		self.speed = self.speed * 1.7;
		self.aspeed = self.aspeed + 15;
	}
	self.monnum = recode(self.monnum, 2, pf);
	self.monnum = recode(self.monnum, 3, sf);

	self.exp = floor(r * 2.5);
	if (self.exp < 1)
		self.exp = 1;
	r = floor(ceil(r / monsvalue) * random() + random());
	if ((r > 0) && (!self.slot1))
		self.droprandom = self.droprandom | 1;
	if ((r > 1) && (!self.slot2))
		self.droprandom = self.droprandom | 2;
	if ((r > 2) && (!self.slot3))
		self.droprandom = self.droprandom | 4;

	monster();
	self.max_health = ceil(self.max_health * 0.7);
	self.health = self.max_health;
	self.tohit = self.tohit - 15; // monsters take a 15% tohit penalty
	self.dodge = self.dodge - 20; // monsters take a 25% dodge penalty
};
