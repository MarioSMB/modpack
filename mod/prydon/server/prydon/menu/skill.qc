#include "skill.qh"

#include "../spells/spells.qh"
#include "../spells/sval.qh"

void m_skill(entity this)
{
	float r, opt, skillmax, sspec, lev, dam;
	
	lev = this.m_subject.title_x + 1;
	sspec = this.m_subject.skill;
	skillmax =
	((sspec & SKILL_REPAIR) == SKILL_REPAIR) +
	((sspec & SKILL_IDENTIFY) == SKILL_IDENTIFY) +
	((sspec & SKILL_SPRINT) == SKILL_SPRINT) +
	((sspec & SKILL_BRAWL) == SKILL_BRAWL) +
	((sspec & SKILL_RELOAD) == SKILL_RELOAD) +
	((sspec & SKILL_FLAME_ARROW) == SKILL_FLAME_ARROW) +
	((sspec & SKILL_BRIBE) == SKILL_BRIBE) +
	((sspec & SKILL_JUMP) == SKILL_JUMP) +
	1;
	
	if(this.menu < 1)
		this.menu = skillmax;
	else if(this.menu > skillmax)
		this.menu = 1;

	r = this.menu;	
	if(this.button1)
	{
		opt = 1;
		if(sspec & SKILL_REPAIR)
		{
			if(r == opt)
				openmenu(this, m_repair, this.m_subject);
			opt = opt + 1;
		}
		if(sspec & SKILL_IDENTIFY)
		{
			if(r == opt)
			{
				if(SelectSpell(this, SP_IDENTIFY))
				{
					closemenu(this);
					return;
				}
			}
			opt = opt + 1;
		}
		if(sspec & SKILL_SPRINT)
		{
			if(r == opt)
			{
				if(SelectSpell(this, SP_SPRINT))
				{
					closemenu(this);
					return;
				}
			}
			opt = opt + 1;
		}
		if(sspec & SKILL_BRAWL)
		{
			if(r == opt)
			{
				if(SelectSpell(this, SP_BRAWL))
				{
					closemenu(this);
					return;
				}
			}
			opt = opt + 1;
		}
		if(sspec & SKILL_RELOAD)
		{
			if(r == opt)
				openmenu(this, m_restock, this.m_subject);
			opt = opt + 1;
		}
		if(sspec & SKILL_FLAME_ARROW)
		{
			if(r == opt)
			{
				if(SelectSpell(this, SP_FLAME_ARROW))
				{
					closemenu(this);
					return;
				}
			}
			opt = opt + 1;
		}
		if(sspec & SKILL_BRIBE)
		{
			if(r == opt)
			{
				if(SelectSpell(this, SP_BRIBE))
				{
					closemenu(this);
					return;
				}
			}
			opt = opt + 1;
		}
		if(sspec & SKILL_JUMP)
		{
			if(r == opt)
			{
				if(SelectSpell(this, SP_JUMP))
				{
					closemenu(this);
					return;
				}
			}
			opt = opt + 1;
		}
		if(sspec & SKILL_FRENZY)
		{
			if(r == opt)
			{
				if(SelectSpell(this, SP_FRENZY))
				{
					closemenu(this);
					return;
				}
			}
			opt = opt + 1;
		}
		if(r == opt)
		{
			closemenu(this);
			return;
		}
		this.button1 = 0;
	}
	if(this.m_refresh < time)
	{
		pstart(this);
		red = RED_ON;
		PrintClass(this.m_subject.title);
		newline();
		line();
		TitleStat(this.m_subject.title);
		stats_report(this, IV_NULL, 0);
		line();
		opt = 1;
		if(sspec & SKILL_REPAIR)
		{
			poption(this, opt, true);
			p6('R', 'e', 'p', 'a', 'i', 'r');
			pad(30);
			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_IDENTIFY)
		{
			poption(this, opt, true);
			p8('I', 'd', 'e', 'n', 't', 'i', 'f', 'y');
			pad(30);
			newline();
			p4('M', 'P', ':', ' ');
			pnum(lev);
			pad(30);
			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_SPRINT)
		{
			poption(this, opt, true);
			p6('S', 'p', 'r', 'i', 'n', 't');
			pad(30);
			newline();
			pad(5);
			p4('M', 'P', ':', ' ');

			pnum(lev);

			pad(30);
			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_BRAWL)
		{
			poption(this, opt, true);
			p5('B', 'r', 'a', 'w', 'l');
			pad(30);
			newline();
			pad(5);
			p4('M', 'P', ':', ' ');

			pnum(lev);
			pad(15);
			p5('D', 'a', 'm', ':', ' ');
			pnum(ceil(this.daml * (1 + lev * 0.1)));
			p1('-');
			pnum(ceil((this.daml + this.dama) * (1 + lev * 0.1)));
			pad(30);
			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_RELOAD)
		{
			poption(this, opt, true);
			p6('R', 'e', 'l', 'o', 'a', 'd');
			pad(30);
			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_FLAME_ARROW)
		{
			poption(this, opt, true);
			p8('F', 'i', 'r', 'e', ' ', 'A', 'r', 'r');
			p2('o', 'w');
			dam = lev * lev * 5;
			pad(30);
			newline();
			pad(5);
			p4('M', 'P', ':', ' ');
			pnum(lev);
			pad(15);
			p5('D', 'a', 'm', ':', ' ');
			pnum(dam/2);
			p1('-');
			pnum(dam);
			pad(30);
			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_BRIBE)
		{
			poption(this, opt, true);
			p5('B', 'r', 'i', 'b', 'e');
			pad(30);
			newline();
			pad(5);
			p4('G', 'P', ':', ' ');
			pnum(ceil(50 / lev));
			pad(30);

			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_JUMP)
		{
			poption(this, opt, true);
			p4('L', 'e', 'a', 'p');
			pad(30);
			newline();
			opt = opt + 1;
		}
		if(sspec & SKILL_FRENZY)
		{
			poption(this, opt, true);
			p6('F', 'r', 'e', 'n', 'z', 'y');
			pad(30);
			newline();
			p4('M', 'P', ':', ' ');

			pnum(lev);
			pad(30);
			newline();
			opt = opt + 1;
		}
		poption(this, opt, true);
		p4('E', 'x', 'i', 't');
		pad(30);
		p1(0);
	}
}
