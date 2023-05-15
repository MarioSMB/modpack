// shitty hack

// this file is all frelled up, gettitle takes no parms, so it cant work right with m_subject

.float field_to_increase;
.vector newtitle;


void() m_stats_confirm =
{
	var .float fld;
	float cost;
	
	if (self.menu < 1)
		self.menu = 2;
	else if (self.menu > 2)
		self.menu = 1;
	if (self.button1)
	{
		if (self.menu == 2)
		{
			Unstat();
			if (self.field_to_increase == 1)
				fld = str;
			else if (self.field_to_increase == 2)
				fld = dex;
			else if (self.field_to_increase == 3)
				fld = mag;
			else if (self.field_to_increase == 4)
				fld = vit;
			else if (self.field_to_increase == 5)
				fld = luck;
			else if (self.field_to_increase == 6)
				fld = agil;
			else
			{
				Restat();
				return;
			}
			if (self.m_subject.fld < 255)
			{
				cost = cost_to_increase(fld);
				if (self.m_subject.ptd >= cost)
				{
					self.m_subject.ptd = self.m_subject.ptd - cost;
					self.m_subject.fld = self.m_subject.fld + 1;
				}
			}
			Restat();
		}
		openmenu(self, m_stats, self.m_subject);

	}
	
	if (self.m_refresh >= time)
		return;
	pstart();
        //  1    2    3    4    5    6    7    8
	p8('D', 'o', 'i', 'n', 'g', ' ', 't', 'h');
	p8('i', 's', ' ', 'w', 'i', 'l', 'l', ' ');
	p8('c', 'h', 'a', 'n', 'g', 'e', ' ', 'y');
	p8('o', 'u', 'r', ' ', 't', 'i', 't', 'l');
	p2('e', ':');
	newline();
	line();
	red = RED_ON;
	PrintClass(self.m_subject.title);
	newline();
	TitleStat(self.m_subject.title);
	stats_report(IV_NULL, 0);
	line();

	p2('t', 'o');
	newline();
	line();
	red = RED_ON;
	PrintClass(self.newtitle);
	newline();
	TitleStat(self.newtitle);
	stats_report(IV_NULL, 0);
	
	line();
	p6('A', 'd', 'd', ' ', '1', ' ');
	if (self.field_to_increase == 1)
	{
		p8('S', 't', 'r', 'e', 'n', 'g', 't', 'h');
		p1('?');
	}
	else if (self.field_to_increase == 2)
	{
		p8('D', 'e', 'x', 't', 'e', 'r', 'i', 't');
		p2('y', '?');
	}
	else if (self.field_to_increase == 3)
	{
		p8('I', 'n', 't', 'e', 'l', 'l', 'i', 'g');
		p5('e', 'n', 'c', 'e', '?');
	}
	else if (self.field_to_increase == 4)
	{
		p8('V', 'i', 't', 'a', 'l', 'i', 't', 'y');
		p1('?');
	}
	else if (self.field_to_increase == 5)
		p5('L', 'u', 'c', 'k', '?');
	else if (self.field_to_increase == 6)
		p8('A', 'g', 'i', 'l', 'i', 't', 'y', '?');
	newline();
	poption(1, TRUE);
	p3('N', 'o', ' ');
	newline();
	poption(2, TRUE);
	p3('Y', 'e', 's');

	p1(0);
	
};
void(entity e) PrintDamage =
{
	local float damlw, damh, mgic;
	
	damlw = e.daml;
	damh = e.dama + damlw;
	mgic = 0;
	if (e.skill & SKILL_MELEE)
	{
		if (e.altaction & 63 == SP_FIGHT_MELEE)
		{
			damlw = damlw + damlw * ((e.title_x + 1) / 7);
			damh = damh + damh * ((e.title_x + 1) / 7);
			mgic = 2;
		}
	}
	if (e.skill & SKILL_BOW)
	{
		if ((e.altaction & 63 == SP_FIGHT_BOW) || (e.altaction & 63 == SP_FIGHT_CBOW))
		{
			damlw = damlw + damlw * ((e.title_x + 1) / 7);
			damh = damh + damh * ((e.title_x + 1) / 7);
			mgic = 2;
		}
	}
	if (e.skill & SKILL_THROW)
	{
		if ((e.altaction & 63 == SP_THROW) || (e.altaction & 63 == SP_THROW_CHAKRAM))
		{
			damlw = damlw + damlw * ((e.title_x + 1) / 7);
			damh = damh + damh * ((e.title_x + 1) / 7);
			mgic = 2;
		}
	}
	if (e.poidam)
	{
		damlw = damlw + e.poidam;
		damh = damh + e.poidam;
		mgic = 1;
	}
	if (e.lit)
	{
		damlw = damlw + 1;
		damh = damh + e.lit;
		mgic = 1;
	}
	if (e.fire)
	{
		damlw = damlw + floor(e.fire/2);
		damh = damh + e.fire;
		mgic = 1;
	}
	if (e.cold)
	{
		damlw = damlw + floor(e.cold/2);
		damh = damh + e.cold;
		mgic = 1;
	}
	if (e.magic)
	{
		damlw = damlw + e.magic;
		damh = damh + e.magic;
		mgic = 1;
	}
	if (mgic == 1)
		red = RED_GOLD;
	else if (mgic == 2)
		red = RED_ON;
	pnum(damlw);
	red = 0;
	
	p1(45);
	if (mgic == 1)
		red = RED_GOLD;
	else if (mgic == 2)
		red = RED_ON;
	pnum(damh);
	red = 0;
};
void(entity e) updateable_stats =
{
float cost;
// ---------------------------------------------------------
	cost = cost_to_increase(str);
	poption(1, e.ptd >= cost);
	p8('S', 't', 'r', 'e', 'n', 'g', 't', 'h');
	pad(18);
	pnum(e.str);
	pad(22);
	p2('(', '-');
	pnum(cost);
	p2(')', ' ');
	pad(30);
	newline();
// ---------------------------------------------------------
	cost = cost_to_increase(dex);
	poption(2, e.ptd >= cost);

	p8('D', 'e', 'x', 't', 'e', 'r', 'i', 't');
	p1('y');
	pad(18);
	pnum(e.dex);
	pad(22);
	p2('(', '-');
	pnum(cost);
	p2(')', ' ');
	pad(30);
	newline();
// ---------------------------------------------------------
	cost = cost_to_increase(mag);
	poption(3, e.ptd >= cost);
	p4('I', 'n', 't', 'e');
	p8('l', 'l', 'i', 'g', 'e', 'n', 'c', 'e');
	pad(18);
	pnum(e.mag);
	pad(22);
	p2('(', '-');
	pnum(cost);
	p2(')', ' ');
	pad(30);
	newline();
// ---------------------------------------------------------
	cost = cost_to_increase(vit);
	poption(4, e.ptd >= cost);
	p8('V', 'i', 't', 'a', 'l', 'i', 't', 'y');
	pad(18);
	pnum(e.vit);
	pad(22);
	p2('(', '-');
	pnum(cost);
	p2(')', ' ');
	pad(30);
	newline();
// ---------------------------------------------------------
	cost = cost_to_increase(luck);
	poption(5, e.ptd >= cost);
	p4('L', 'u', 'c', 'k');
	pad(18);
	pnum(e.luck);
	pad(22);
	p2('(', '-');
	pnum(cost);
	p2(')', ' ');
	pad(30);
	newline();
// ---------------------------------------------------------
	cost = cost_to_increase(agil);
	poption(6, e.ptd >= cost);
	p7('A', 'g', 'i', 'l', 'i', 't', 'y');
	pad(18);
	pnum(e.agil);
	pad(22);
	p2('(', '-');
	pnum(cost);
	p2(')', ' ');
	pad(30);
	newline();
// ---------------------------------------------------------

};


void(entity e) regular_stats =
{

// ---------------------------------------------------------
	p8('S', 't', 'r', 'e', 'n', 'g', 't', 'h');
	pad(13);
	pnum(e.str);
	pad(16);
	p8('R', 'e', 's', 'i', 's', 't', 'a', 'n');
	p3('c', 'e', 's');
	
	pad(30);
	newline();
// ---------------------------------------------------------
	p8('D', 'e', 'x', 't', 'e', 'r', 'i', 't');
	p1('y');
	pad(13);
	pnum(e.dex);
	pad(16);
	p5('M', 'a', 'g', 'i', 'c');
	pad(26);
	pnum(e.res_mag);
	pad(30);
	newline();
// ---------------------------------------------------------
	p4('I', 'n', 't', 'e');
	p8('l', 'l', 'i', 'g', 'e', 'n', 'c', 'e');
	pad(13);
	pnum(e.mag);
	pad(16);
	p4('F', 'i', 'r', 'e');
	pad(26);
	pnum(e.res_fire);
	pad(30);
	newline();
// ---------------------------------------------------------
	p8('V', 'i', 't', 'a', 'l', 'i', 't', 'y');

	pad(13);
	pnum(e.vit);
	pad(16);
	p8('L', 'i', 'g', 'h', 't', 'n', 'i', 'n');
	p1('g');
	pad(26);
	pnum(e.res_lit);
	pad(30);
	newline();
// ---------------------------------------------------------
	p4('L', 'u', 'c', 'k');
	pad(13);
	pnum(e.luck);
	pad(16);
	p6('P', 'o', 'i', 's', 'o', 'n');
	
	pad(26);
	pnum(e.res_poison);
	pad(30);
	newline();
// ---------------------------------------------------------
	p7('A', 'g', 'i', 'l', 'i', 't', 'y');
	pad(13);
	pnum(e.agil);
	pad(16);
	p4('C', 'o', 'l', 'd');
	pad(26);
	pnum(e.res_cold);
	pad(30);
	newline();
// ---------------------------------------------------------

};




void() m_stats =
{
	var .float fld;
	float cost;
	entity e;
	
	e = self.m_subject;
	
	vector t;
	Unstat();
	set_ranks(e);
	
	if (self.menu < 1)
		self.menu = 7;
	else if (self.menu > 7)
		self.menu = 1;
	if (!e.ptd)
		self.menu = 7;
	if (self.button1)
	{
		self.m_refresh = 0;
		self.button1 = 0;
		if (self.menu == 7)
		{
			closemenu(self);
			Restat();
			return;
		}
		else if (e.ptd > 0)
		{
			if (self.menu == 1)
				fld = str;
			else if (self.menu == 2)
				fld = dex;
			else if (self.menu == 3)
				fld = mag;
			else if (self.menu == 4)
				fld = vit;
			else if (self.menu == 5)
				fld = luck;
			else if (self.menu == 6)
				fld = agil;
			else
			{
				Restat();
				return;
			}
			if (e.fld < 255)
			{
			

				set_ranks(e);
				cost = cost_to_increase(fld);
				if (e.ptd >= cost)
				{
					e.fld = e.fld + 1;
					set_ranks(e);
					t = gettitle();
					if (t != e.title)
					{
						e.fld = e.fld - 1;
						set_ranks(e);
						e.newtitle = t;
						e.field_to_increase = self.menu;
						Restat();
						openmenu(self, m_stats_confirm, e);
						return;
					}
					else
					{
						e.ptd = e.ptd - cost;
					}
				}
			}
			
		}	
	}
	Restat();
	if (self.m_refresh >= time)
		return;
	// show the player his stats and allows ptd
	pstart();
	red = RED_ON;
	PrintClass(e.title);
	newline();
	
	p5('L', 'e', 'v', 'e', 'l');
	pad(6);
	pnum(e.lvl);
	pad(14);
	p4('G', 'o', 'l', 'd');
	pad(23);
	pnum(e.gp);
	pad(30);
	newline();
	
	p4('M', 'a', 'n', 'a');
	pad(6);
	pnum(e.mana);
	p1('/');
	pnum(e.max_mana);
	pad(14);
	p6('H', 'e', 'a', 'l', 't', 'h');
	pad(23);
	pnum(e.health);
	p1('/');
	pnum(e.max_health);
	pad(30);
	newline();
		
	p5('D', 'o', 'd', 'g', 'e');
	pad(6);
	pnum(e.dodge);
	p1('%');
	pad(14);
	p6('T', 'o', ' ', 'H', 'i', 't');
	pad(23);
	pnum(e.tohit);
	p1('%');
	pad(30);
	newline();
	
	p5('B', 'l', 'o', 'c', 'k');
	pad(6);
	pnum(e.block);
	p1('%');
	pad(14);
	p8('C', 'r', 'i', 't', 'i', 'c', 'a', 'l');
	pad(23);
	pnum(e.critical);
	p1('%');
	pad(30);
	newline();
	
	p2('A', 'C');
	pad(6);
	pnum(e.ac);
	pad(14);
	p6('D', 'a', 'm', 'a', 'g', 'e');
	pad(23);
	PrintDamage(e);
	pad(30);
	newline();
	
	p4('E', 'x', 'p', ' ');
	pad(6);
	pnum(e.exp);
	pad(14);
	p8('N', 'e', 'x', 't', ' ', 'L', 'v', 'l');
	pad(23);
	if (e.lvl < MAX_CHAR_LEVEL)
		pnum(ExpForLevel(e.lvl));
	else
		p3('N', '/', 'A');

	pad(30);
	newline();
	line();

	if (e.ptd)
	{
		updateable_stats(e);
		e.options = e.options | OPT_SEEN_PTD;
		red = RED_ON;
		p8('P', 'o', 'i', 'n', 't', 's', ' ', 'l');
		p8('e', 'f', 't', ' ', 't', 'o', ' ', 'd');
		p8('i', 's', 't', 'r', 'i', 'b', 'u', 't');
		p2('e', ' ');
		pnum(e.ptd);
		pad(29);
		newline();
	}
	else
		regular_stats(e);
	line();
	poption(7, TRUE);
	p4('E', 'x', 'i', 't');
	pad(30);
	p1(0);
	
};

