#include "spells.qh"

#include "../spells/_mod.qh"

void display_effect(float sp, float lev)
{
	float dm;
	// 10 chars only :|
	if(sp == SP_FIREBALL)
	{
		p4('D', 'a', 'm', ':');
		dm = ceil(lev * lev * 1.5) + 7;
		pnum(dm/2);
		p1('-');
		pnum(dm);
	}
	else if(sp == SP_ZAP)
	{
		p6('D', 'a', 'm', ':', '1', '-');
		pnum( 10 + lev * lev);
	}
	else if(sp == SP_ICEBLAST)
	{
		p4('D', 'a', 'm', ':');
		dm = ceil(lev * lev * 1.4) + 4;
		pnum(dm/2);
		p1('-');
		pnum(dm);
	}
	else if(sp == SP_POISONBALL)
	{
		p4('D', 'a', 'm', ':');
		pnum( ceil(lev * lev * 1.2) + 20);
	}
	else if(sp == SP_LEECH)
	{
		p4('D', 'a', 'm', ':');
		pnum(ceil(lev * lev / 2) + 2);	
	}
	else if(sp == SP_HEAL)
	{
		p5('H', 'e', 'a', 'l', ' ');
		dm = (lev + 4) / 2;
		pnum(ceil(dm*dm) + 5);
	}
	else if(sp == SP_SHIELD)
	{
		p4('D', 'u', 'r', ':');
		pnum(8 + lev * 2.5);
		p4('s', 'e', 'c','s');
	}
	else if(sp == SP_TRANSMUTE)
	{
		p6('V', 'a', 'l', 'u', 'e', ':');
		pnum(lev*10);
		p1('%');
	}
	else if(sp == SP_TWISTER)
	{
		p4('D', 'u', 'r', ':');
		pnum( 1 + lev  * 3);
		p4('s', 'e', 'c', 's');
	}
	else if(sp == SP_NOVA)
	{
		p6('D', 'a', 'm', ':', '1', '-');
		pnum(12 + ceil(lev * lev * 2.5));
	}
	else if(sp == SP_REPEL)
	{
		p5('A', 'r', 'e', 'a',':');
		pnum(floor(5 + lev * lev * 0.2) * 2);
	}
	else if(sp == SP_METEOR)
	{
		p4('D', 'a', 'm', ':');
		dm = rint(60 + 35 * lev * lev);
		pnum(dm/2);
		p1('-');
		pnum(dm);
	}
	else if(sp == SP_SUMMON)
	{
		pnum(lev);
		if(lev < 3)
			p8(' ', 'S', 'c', 'a', 'r', 'i','t', 'e');
		else if(lev < 5)
			p8(' ', 'G', 'u', 'a', 'n', 'i', 't', 'e');
		else if(lev < 7)
			p6(' ', 'D', 'r', 'a', 'k', 's');
		else
			p8(' ', 'H', 'o', 'r', 'r', 'o', 'r', 's');
	}
	else if(sp == SP_EVILE)
	{
		p5('A', 'r', 'e', 'a',':');
		pnum(floor((5 + lev * lev * 0.2) / 2));
	}
		
}

void m_spells(entity this, float off)
{
	if(this.menu < 1)
		this.menu = 9;
	else if(this.menu > 9)
		this.menu = 1;
	
	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 9)
		{
			closemenu(this);
			return;
		}
		if(SelectSpell(this, this.menu + off))
		{
			closemenu(this);
			return;
		}
	}
		
	if(this.m_refresh >= time)
		return;
	pstart(this);	

	for(int i=1; i < 9; i = i + 1)
	{
		int lv = GetSpellLevel(this.m_subject, i + off);
		poption(this, i, lv);
		if(lv)
		{
			PrintSpellName(i + off);
			pad(20);
			p6('L', 'e', 'v', 'e', 'l', 32);
			pnum(lv);
			pad(30);
			newline();
			p6(32, 32 ,32, 'M', 'P', ':');
			pnum(mana_for_spell(i+off,lv));
			int rn = spell_range(this, i+off);
			if(rn != BIG_DISTANCE)
			{
				pad(10);
				p6('R', 'a', 'n', 'g', 'e', ':');
				pnum(floor((rn - 70)/10));
			}
			pad(20);
			display_effect(i+off,lv);
			pad(30);

		}
		newline();
	}
	line();
	
	poption(this, 9, true);	
	p4('E', 'x', 'i', 't');
	pad(30);
	newline();
	p1(0);

}

void m_spells1(entity this)
{	
	m_spells(this, 0);
}

void m_spells2(entity this)
{
	m_spells(this, 8);
}
