#include "invenlst.qh"

float invenlst(entity this, entity who, float stats, float(entity) callback, vector ptitle)
{
	int end = 0;
	int total = 0;
	int mslot = 0;

	if(this.menu < 1)
		this.menu = 10;
	else if(this.menu > 10)
		this.menu = 1;
	
	int begin = TOTAL_SLOTS;
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		vector f = GetSlot(who, i);
		it_simplestat(this, f);
		it_itemstat(this);
		
		if(callback(this))
		{
			total += 1;
			if(total > this.m_num)
				if(i < begin)
					begin = i;
			if(i > end)
				end = i;
			if((this.menu + this.m_num) == total)
				mslot = i;
		}
	}
	if(this.menu < 9)
	{
		if(!mslot)
		{
			if(this.impulse == -1)
			{
				this.menu -= 1;
				this.m_refresh = 0;
				if(this.menu < 1)
					this.menu = 10;
			}
			else	
				this.menu += 1;
		}
	}
	else if(this.menu == 9)
	{
		if(total <= 8)
		{
			if(this.impulse == -1)
			{
				this.menu -= 1;
				this.m_refresh = 0;
				if(this.menu < 1)
					this.menu = 10;
			}
			else	
				this.menu += 1;
		}
	}
	
	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 9)
		{
			if(total > 8)
			{
				this.m_num += 8;
				if(this.m_num >= TOTAL_SLOTS)
					this.m_num = 0;
			}
		}
		else if(this.menu == 10)
		{
			closemenu(this);
			return 0;
		}
		else
		{
			it_simplestat(this, GetSlot(who, mslot));
			it_itemstat(this);
			if(callback(this))
				return mslot;
		}
	}
	if(this.m_refresh >= time)
		return 0;
	pstart(this);
	if(ptitle != '0 0 0')
	{
		pvstr(ptitle);
		newline();
		if(stats & 1)
			pgold(this);
		line();
	}
	total = 0;
	for(int i = begin; i <= end; i = i + 1)
	{
		vector f = GetSlot(who, i);
		it_simplestat(this,f);
		it_itemstat(this);
		float c = callback(this);
		
		if(c)
		{
			total += 1;
			if(total > 8)
				break;
			newline();
			poption(this, total, true);	
			
			if(who.equip & (2 ** i))
				red = RED_ON;		
			PrintItemName();
			if(stats & 1)
			{
				pad(33);
				pnum(c);
				p2('G', 'P');
			}
			pad(40);

			if(stats & (DURABILITY | STACKABLE | CHARGES))
			{
				newline();
				pad(5);
				if(stats & STACKABLE)
				{
					p8('Q', 'u', 'a', 'n', 't', 'i', 't', 'y');
					p1(' ');
				}
				else if(stats & CHARGES)
					p8('C', 'h', 'a', 'r', 'g', 'e', 's', ' ');
				else
				{
					p8('D', 'u', 'r', 'a', 'b', 'i', 'l', 'i');
					p3('t', 'y', ' ');
				}
				pnum(stat_dur);
				p1('/');
				pnum(stat_max_dur);
				pad (40);
			}
		}
	}
	if(this.menu > total)
	{
		if(this.impulse == -1)
			this.menu = total;
		else if(this.m_num)
			this.menu = 9;
		else 
			this.menu = 10;
	}
	newline();
	if(ptitle)
		padlines(11);
	else
		padlines(10);
	line();
	
	if(total > 8)
	{
		poption(this, 9, true);
		p8('N', 'e', 'x', 't', ' ', 'P', 'a', 'g');
		p1('e');
		pad(40);
		newline();
	}
	else if(this.m_num)
	{
		poption(this, 9, true);
		p8('P', 'r', 'e', 'v', 'i', 'o', 'u', 's');
		p5(' ', 'P', 'a', 'g', 'e');
		pad(40);
		newline();
	}
	poption(this, 10, true);
	p4('E', 'x', 'i', 't');
	pad(40);
	p1(0);
	return 0;
}

bool m_invenlstcallback(entity this)
{
	if(stat_it)
		return true;
	return false;
}

void m_invenlst(entity this)
{
	int i = invenlst(this, this.m_subject, 0, m_invenlstcallback, '0 0 0');
	
	if(i)
	{
		this.weapon = (2 ** i);
		openmenu(this, m_inven, this.m_subject);
	}
}
