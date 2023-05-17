#include "stats.qh"

#include "../stats/_mod.qh"

// hack

// this file is all frelled up, gettitle takes no parms, so it cant work right with m_subject

.float field_to_increase;
.vector newtitle;

void m_stats_confirm(entity this)
{
	.float fld;
	float cost;
	
	if(this.menu < 1)
		this.menu = 2;
	else if(this.menu > 2)
		this.menu = 1;
	if(this.button1)
	{
		if(this.menu == 2)
		{
			Unstat(this);
			if(this.field_to_increase == 1)
				fld = str;
			else if(this.field_to_increase == 2)
				fld = dex;
			else if(this.field_to_increase == 3)
				fld = mag;
			else if(this.field_to_increase == 4)
				fld = vit;
			else if(this.field_to_increase == 5)
				fld = luck;
			else if(this.field_to_increase == 6)
				fld = agil;
			else
			{
				Restat(this);
				return;
			}
			if(this.m_subject.fld < 255)
			{
				cost = cost_to_increase(fld);
				if(this.m_subject.ptd >= cost)
				{
					this.m_subject.ptd = this.m_subject.ptd - cost;
					this.m_subject.fld = this.m_subject.fld + 1;
				}
			}
			Restat(this);
		}
		openmenu(this, m_stats, this.m_subject);

	}
	
	if(this.m_refresh >= time)
		return;
	pstart(this);
        //  1    2    3    4    5    6    7    8
	p8('D', 'o', 'i', 'n', 'g', ' ', 't', 'h');
	p8('i', 's', ' ', 'w', 'i', 'l', 'l', ' ');
	p8('c', 'h', 'a', 'n', 'g', 'e', ' ', 'y');
	p8('o', 'u', 'r', ' ', 't', 'i', 't', 'l');
	p2('e', ':');
	newline();
	line();
	red = RED_ON;
	PrintClass(this.m_subject.title);
	newline();
	TitleStat(this.m_subject.title);
	stats_report(this, IV_NULL, 0);
	line();

	p2('t', 'o');
	newline();
	line();
	red = RED_ON;
	PrintClass(this.newtitle);
	newline();
	TitleStat(this.newtitle);
	stats_report(this, IV_NULL, 0);
	
	line();
	p6('A', 'd', 'd', ' ', '1', ' ');
	if(this.field_to_increase == 1)
	{
		p8('S', 't', 'r', 'e', 'n', 'g', 't', 'h');
		p1('?');
	}
	else if(this.field_to_increase == 2)
	{
		p8('D', 'e', 'x', 't', 'e', 'r', 'i', 't');
		p2('y', '?');
	}
	else if(this.field_to_increase == 3)
	{
		p8('I', 'n', 't', 'e', 'l', 'l', 'i', 'g');
		p5('e', 'n', 'c', 'e', '?');
	}
	else if(this.field_to_increase == 4)
	{
		p8('V', 'i', 't', 'a', 'l', 'i', 't', 'y');
		p1('?');
	}
	else if(this.field_to_increase == 5)
		p5('L', 'u', 'c', 'k', '?');
	else if(this.field_to_increase == 6)
		p8('A', 'g', 'i', 'l', 'i', 't', 'y', '?');
	newline();
	poption(this,1, true);
	p3('N', 'o', ' ');
	newline();
	poption(this,2, true);
	p3('Y', 'e', 's');

	p1(0);
	
}
void PrintDamage(entity e)
{
	float damlw = e.daml;
	float damh = e.dama + damlw;
	float mgic = 0;
	if(e.skill & SKILL_MELEE)
	{
		if(e.altaction & 63 == SP_FIGHT_MELEE)
		{
			damlw = damlw + damlw * ((e.title_x + 1) / 7);
			damh = damh + damh * ((e.title_x + 1) / 7);
			mgic = 2;
		}
	}
	if(e.skill & SKILL_BOW)
	{
		if((e.altaction & 63 == SP_FIGHT_BOW) || (e.altaction & 63 == SP_FIGHT_CBOW))
		{
			damlw = damlw + damlw * ((e.title_x + 1) / 7);
			damh = damh + damh * ((e.title_x + 1) / 7);
			mgic = 2;
		}
	}
	if(e.skill & SKILL_THROW)
	{
		if((e.altaction & 63 == SP_THROW) || (e.altaction & 63 == SP_THROW_CHAKRAM))
		{
			damlw = damlw + damlw * ((e.title_x + 1) / 7);
			damh = damh + damh * ((e.title_x + 1) / 7);
			mgic = 2;
		}
	}
	if(e.poidam)
	{
		damlw = damlw + e.poidam;
		damh = damh + e.poidam;
		mgic = 1;
	}
	if(e.lit)
	{
		damlw = damlw + 1;
		damh = damh + e.lit;
		mgic = 1;
	}
	if(e.fire)
	{
		damlw = damlw + floor(e.fire/2);
		damh = damh + e.fire;
		mgic = 1;
	}
	if(e.cold)
	{
		damlw = damlw + floor(e.cold/2);
		damh = damh + e.cold;
		mgic = 1;
	}
	if(e.magic)
	{
		damlw = damlw + e.magic;
		damh = damh + e.magic;
		mgic = 1;
	}
	if(mgic == 1)
		red = RED_GOLD;
	else if(mgic == 2)
		red = RED_ON;
	pnum(damlw);
	red = 0;
	
	p1(45);
	if(mgic == 1)
		red = RED_GOLD;
	else if(mgic == 2)
		red = RED_ON;
	pnum(damh);
	red = 0;
}

void updateable_stats(entity e)
{
	float cost;
// ---------------------------------------------------------
	cost = cost_to_increase(str);
	poption(e, 1, e.ptd >= cost);
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
	poption(e, 2, e.ptd >= cost);

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
	poption(e, 3, e.ptd >= cost);
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
	poption(e, 4, e.ptd >= cost);
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
	poption(e, 5, e.ptd >= cost);
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
	poption(e, 6, e.ptd >= cost);
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
}

void regular_stats(entity e)
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
}

void m_stats(entity this)
{
	.float fld;
	entity e = this.m_subject;
	
	vector t;
	Unstat(this);
	set_ranks(e);
	
	if(this.menu < 1)
		this.menu = 7;
	else if(this.menu > 7)
		this.menu = 1;
	if(!e.ptd)
		this.menu = 7;
	if(this.button1)
	{
		this.m_refresh = 0;
		this.button1 = 0;
		if(this.menu == 7)
		{
			closemenu(this);
			Restat(this);
			return;
		}
		else if(e.ptd > 0)
		{
			if(this.menu == 1)
				fld = str;
			else if(this.menu == 2)
				fld = dex;
			else if(this.menu == 3)
				fld = mag;
			else if(this.menu == 4)
				fld = vit;
			else if(this.menu == 5)
				fld = luck;
			else if(this.menu == 6)
				fld = agil;
			else
			{
				Restat(this);
				return;
			}
			if(e.fld < 255)
			{
				set_ranks(e);
				float cost = cost_to_increase(fld);
				if(e.ptd >= cost)
				{
					e.(fld) += 1;
					set_ranks(e);
					t = gettitle();
					if(t != e.title)
					{
						e.(fld) -= 1;
						set_ranks(e);
						e.newtitle = t;
						e.field_to_increase = this.menu;
						Restat(this);
						openmenu(this, m_stats_confirm, e);
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
	Restat(this);
	if(this.m_refresh >= time)
		return;
	// show the player his stats and allows ptd
	pstart(this);
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
	pnum(e.experience);
	pad(14);
	p8('N', 'e', 'x', 't', ' ', 'L', 'v', 'l');
	pad(23);
	if(e.lvl < MAX_CHAR_LEVEL)
		pnum(ExpForLevel(e.lvl));
	else
		p3('N', '/', 'A');

	pad(30);
	newline();
	line();

	if(e.ptd)
	{
		updateable_stats(e);
		e.options |= OPT_SEEN_PTD;
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
	poption(e, 7, true);
	p4('E', 'x', 'i', 't');
	pad(30);
	p1(0);
}
