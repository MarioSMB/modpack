#include "options.qh"

void pcheckbox(float check)
{
	pad(27);
	if(check)
		p3(16, 156, 17);
	else
		p3(16, 32, 17);
}

void m_options(entity this)
{
	if(this.menu < 1)
		this.menu = 5;
	else if(this.menu > 5)
		this.menu = 1;
	if(this.button1)
	{
		if(this.menu == 5)
		{
			closemenu(this);
			return;
		}
		int moption = (2 ** this.menu);
		if(this.options & moption)
			this.options &= ~moption;
		else
			this.options |= moption;	
	
	}
	if(this.m_refresh >= time)
		return;
	// show the player his stats and allows ptd
	pstart(this);

	poption(this, 1, true);
	p8('A', 'l', 'w', 'a', 'y', 's', ' ', 'S');
	p8('h', 'o', 'w', ' ', 'S', 'p', 'e', 'l');
	p1('l');
	pcheckbox(!(this.options & 1));
	newline();
	
	poption(this, 2, true);
	p8('M', 'o', 'u', 's', 'e', ' ', 'R', 'o');
	p8('t', 'a', 't', 'e', '/', 'Z', 'o', 'o');
	p1('m');
	pcheckbox(!(this.options & 2));
	newline();
	
	poption(this, 3, true);
	p8('Q', 'u', 'e', 's', 't', ' ', 'N', 'o');
	p4('t', 'i', 'c', 'e');
	pcheckbox(!(this.options & 4));
	newline();
	
	poption(this, 4, true);
	p7('V', 'e', 'r', 'b', 'o', 's', 'e');
	pcheckbox(this.options & OPT_VERBOSE);
	newline();
	
	poption(this, 5, true);
	p4('E', 'x', 'i', 't');
	pad(30);
	p1(0);
/*
 \[\1\] Always Show Spell \[ \]\n
 \[\2\] Mouse Rotate/Zoom \[ \]\n
 \[\3\] Quest Notice      \[ \]\n
*/
}
