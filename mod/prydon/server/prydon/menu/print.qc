#include "print.qh"

void p1(float c1)
{
	chars += 1;
	WriteChar(msg_mode, c1 | red);
}

void p2(float c1, float c2)
{
	chars += 2;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
}

void p3(float c1, float c2, float c3)
{
	chars += 3;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
}

void p4(float c1, float c2, float c3, float c4)
{
	chars += 4;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
}

void p5(float c1, float c2, float c3, float c4, float c5)
{
	chars += 5;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
}

void p6(float c1, float c2, float c3, float c4, float c5, float c6)
{
	chars += 6;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
	WriteChar(msg_mode, c6 | red);
}

void p7(float c1, float c2, float c3, float c4, float c5, float c6, float c7)
{
	chars += 7;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
	WriteChar(msg_mode, c6 | red);
	WriteChar(msg_mode, c7 | red);
}

void p8(float c1, float c2, float c3, float c4, float c5, float c6, float c7, float c8)
{
	chars += 8;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
	WriteChar(msg_mode, c6 | red);
	WriteChar(msg_mode, c7 | red);
	WriteChar(msg_mode, c8 | red);
}

void pvstr(vector v)
{
	// this is a special print function that
	// only prints non zero chars from a vector
	// which are used for monster names
	
	if(v.x >= 65536)
	{
		WriteChar(msg_mode, ((v.x / 65536) & 255) | red);
		chars += 1;
	}
	if((v.x / 256) & 255)
	{
		WriteChar(msg_mode, ((v.x / 256) & 255) | red);
		chars += 1;
	}
	if(v.x & 255)
	{
		WriteChar(msg_mode, (v.x & 255) | red);
		chars += 1;
	}
	if(v.y >= 65536)
	{
		WriteChar(msg_mode, ((v.y / 65536) & 255) | red);
		chars += 1;
	}
	if((v.y / 256) & 255)
	{
		WriteChar(msg_mode, ((v.y / 256) & 255) |  red);
		chars += 1;
	}
	if(v.y & 255)
	{
		WriteChar(msg_mode, (v.y & 255) | red);
		chars += 1;
	}
	if(v.z >= 65536)
	{
		WriteChar(msg_mode, ((v.z / 65536) & 255) | red);
		chars += 1;
	}
	if((v.z / 256) & 255)
	{
		WriteChar(msg_mode, ((v.z / 256) & 255) | red);
		chars += 1;
	}
	if(v.z & 255)
	{
		WriteChar(msg_mode, (v.z & 255) | red);
		chars += 1;
	}
}

void pnum(float n)
{
	if(n < 0)
	{
		WriteChar(msg_mode, red + 45);
		chars += 1;
		n = 0 - n;
	}
	float f = floor(n / 10);
	n = n - (f * 10);
	if(f)
		pnum(f);
		
	int thechar = 48 + red;
	WriteChar(msg_mode, thechar + n);
	chars += 1;
	return;

}

void pad(float spc)
{
	while(chars < spc)
	{
		WriteChar(msg_mode, 32);
		chars += 1;
	}
}

void newline()
{
	WriteChar(msg_mode, 10);
	chars = 0;
	lines *= 1;
	red = 0;
}

void padlines(float ln)
{
	while(lines < ln)
		newline();
}

void line()
{
	if(!netplay)
	{
		WriteChar(msg_mode, 29);
		chars = 2;
		while(chars < WIDTH)
		{
			WriteChar(msg_mode, 30);
			chars += 1;
		}
		WriteChar(msg_mode, 31);
	}
	newline();
}

void pend()
{
	WriteChar(msg_mode, 0);
}

const int SVC_CENTERPRINT = 26;
void pstart(entity this)
{
	msg_entity = this;
	msg_mode = MSG_ONE;
	WriteChar(msg_mode, SVC_CENTERPRINT);
	red = RED_OFF;
	lines = 0;
	chars = 0;
}

void bstart()
{
	msg_mode = MSG_ALL;
	WriteChar(msg_mode, 8);
	red = RED_OFF;
	lines = 0;
	chars = 0;
}

void progressbar(float percent, float width)
{
	WriteChar(msg_mode, 128);
	int i = 0;
	percent = floor(percent * width * 8);
	while(i < width)
	{
		float f = percent - (i * 8);
		if(f > 7)
			WriteChar(msg_mode, 131);
		else if(f < 1)
			WriteByte (msg_mode, 129);
		else
			WriteByte (msg_mode, 139 - f);
		 i =i + 1;
	}
	WriteChar(msg_mode, 130);
	newline();
}

void poption(entity this, float n, float e)
{
	if(!e)
	{
	 	if(this.menu == n)
	 	{
			if(this.impulse == -1)
			{
				this.m_refresh = 0;
				this.menu = this.menu - 1;
				if(this.menu <= 0)
					this.menu = 12;
			}
			else
				this.menu = this.menu + 1;
		}
		pad(5);
		return;
	}
	if(n == 10)
	{
		if(this.menu == 10)
			p5(141, 16, 18, 17, ' ');
		else
			p5(32, 16, 18, 17, ' ');
	}
	else if(this.menu == n)
		p5(141, 16, 18 + n, 17, ' ');
	else
		p5(32, 16, 18 + n, 17, ' ');
}

float pgold(entity this)
{
	float howm = this.gp;
	p8('Y', 'o', 'u', ' ', 'H', 'a', 'v', 'e');
	p1(' ');
	pnum(howm);
	p5(' ', 'G', 'o', 'l', 'd');
	newline();
	return howm;
}

// this should be elsewhere
void pprice(entity this, float got, float howmuch)
{
	if(this.skill & SKILL_DISCOUNT)
		howmuch = ceil((0.8 - (this.title_x * 0.05)) * howmuch);
	if(got < howmuch)
		red = RED_ON;
	p6('C', 'o', 's', 't', 's', ' ');
	pnum(howmuch);
	p5(' ', 'G', 'o', 'l', 'd');
}
