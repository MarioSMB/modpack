#include "gold.qh"

void m_dropgold(entity this)
{
	int n = 0;
	
	if(this.menu < 1)
		this.menu = 10;
	else if(this.menu > 10)
		this.menu = 1;
	if(this.menu == 10)
		n = 0;
	else
		n = this.menu;
		
	if(this.button1)
	{
		if(this.m_num < this.gp)
			this.m_num = this.m_num * 10 + n;
	}
	else if(this.button0 || this.button2)
	{
		if(this.m_num > this.gp)
		{
			prompt(this, "You don't have enough gold for this", this, 2);
			return;
		}
		dropgold(this, this.m_num);
		this.m_subject.gp = this.m_subject.gp - this.m_num;
		closemenu(this);
	}
	
	if(this.m_refresh < time)
	{
		if(!this.m_refresh)
			this.misc &= ~MISC_UPDATE_BLINK;
			
		pstart(this);
		p5('D', 'r', 'o', 'p', ' ');
		p4('G', 'o', 'l', 'd');
		newline();
		line();
		pgold(this);
		line();
		p8('Q', 'u', 'a', 'n', 't', 'i', 't', 'y');
		p2(':', ' ');
		if(this.m_num)
			pnum(this.m_num);
		red = RED_ON;
		if(this.misc & MISC_UPDATE_BLINK)
			p1(11);
		else
			pnum(n);
		red = 0;
		p1(0);
		this.m_refresh = time + 1;
	}
}
