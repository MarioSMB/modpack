nosave float msg_mode;
void(float c1) p1 =
{
	chars = chars + 1;
	WriteChar(msg_mode, c1 | red);
};

void(float c1, float c2) p2 =
{
	chars = chars + 2;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
};

void(float c1, float c2, float c3) p3 =
{
	chars = chars + 3;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
};
void(float c1, float c2, float c3, float c4) p4 =
{
	chars = chars + 4;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
};
void(float c1, float c2, float c3, float c4, float c5) p5 =
{
	chars = chars + 5;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
};
void(float c1, float c2, float c3, float c4, float c5, float c6) p6 =
{
	chars = chars + 6;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
	WriteChar(msg_mode, c6 | red);
};
void(float c1, float c2, float c3, float c4, float c5, float c6, float c7) p7 =
{
	chars = chars + 7;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
	WriteChar(msg_mode, c6 | red);
	WriteChar(msg_mode, c7 | red);
};

void(float c1, float c2, float c3, float c4, float c5, float c6, float c7, float c8) p8 =
{
	chars = chars + 8;
	WriteChar(msg_mode, c1 | red);
	WriteChar(msg_mode, c2 | red);
	WriteChar(msg_mode, c3 | red);
	WriteChar(msg_mode, c4 | red);
	WriteChar(msg_mode, c5 | red);
	WriteChar(msg_mode, c6 | red);
	WriteChar(msg_mode, c7 | red);
	WriteChar(msg_mode, c8 | red);
};

void(vector v) pvstr =
{
	// this is a special print function that
	// only prints non zero chars from a vector
	// which are used for monster names
	
	if (v_x >= 65536)
	{
		WriteChar(msg_mode, ((v_x / 65536) & 255) | red);
		chars = chars + 1;
	}
	if ((v_x / 256) & 255)
	{
		WriteChar(msg_mode, ((v_x / 256) & 255) | red);
		chars = chars + 1;
	}
	if (v_x & 255)
	{
		WriteChar(msg_mode, (v_x & 255) | red);
		chars = chars + 1;
	}
	if (v_y >= 65536)
	{
		WriteChar(msg_mode, ((v_y / 65536) & 255) | red);
		chars = chars + 1;
	}
	if ((v_y / 256) & 255)
	{
		WriteChar(msg_mode, ((v_y / 256) & 255) |  red);
		chars = chars + 1;
	}
	if (v_y & 255)
	{
		WriteChar(msg_mode, (v_y & 255) | red);
		chars = chars + 1;
	}
	if (v_z >= 65536)
	{
		WriteChar(msg_mode, ((v_z / 65536) & 255) | red);
		chars = chars + 1;
	}
	if ((v_z / 256) & 255)
	{
		WriteChar(msg_mode, ((v_z / 256) & 255) | red);
		chars = chars + 1;
	}
	if (v_z & 255)
	{
		WriteChar(msg_mode, (v_z & 255) | red);
		chars = chars + 1;
	}
};

void(float n) pnum =
{
	local float f, char;
	if (n < 0)
	{
		WriteChar(msg_mode, red + 45);
		chars = chars + 1;
		n = 0 - n;
	}
	f = floor(n / 10);
	n = n - (f * 10);
	if (f)
		pnum(f);
		
	char = 48 + red;
	WriteChar(msg_mode, char + n);
	chars = chars + 1;
	return;

};

void(float spc) pad =
{
	while(chars < spc)
	{
		WriteChar(msg_mode, 32);
		chars = chars + 1;
	}
};

void() newline =
{
	WriteChar(msg_mode, 10);
	chars = 0;
	lines = lines + 1;
	red = 0;
};

void(float ln) padlines =
{
	while(lines < ln)
		newline();
};

void() line =
{
	if (!netplay)
	{
		WriteChar(msg_mode, 29);
		chars = 2;
		while(chars < WIDTH)
		{
			WriteChar(msg_mode, 30);
			chars = chars + 1;
		}
		WriteChar(msg_mode, 31);
	}
	newline();
};

void() pend =
{
	WriteChar(msg_mode, 0);
};
void() pstart =
{
	msg_entity = self;
	msg_mode = MSG_ONE;
	WriteChar(msg_mode, SVC_CENTERPRINT);
	red = RED_OFF;
	lines = 0;
	chars = 0;
};


void() bstart =
{
	msg_mode = MSG_ALL;
	WriteChar(msg_mode, 8);
	red = RED_OFF;
	lines = 0;
	chars = 0;
};
void(float percent, float width) progressbar =
{
	local float i, f;
	WriteChar(msg_mode, 128);
	i = 0;
	percent = floor(percent * width * 8);
	while(i < width)
	{
		f = percent - (i * 8);
		if (f > 7)
			WriteChar(msg_mode, 131);
		else if (f < 1)
			WriteByte (msg_mode, 129);
		else
			WriteByte (msg_mode, 139 - f);
		 i =i + 1;
	}
	WriteChar(msg_mode, 130);
	newline();
};

void(float n, float e) poption =
{
	if (!e)
	{
	 	if (self.menu == n)
	 	{
			if (self.impulse == -1)
			{
				self.m_refresh = 0;
				self.menu = self.menu - 1;
				if (self.menu <= 0)
					self.menu = 12;
			}
			else
				self.menu = self.menu + 1;
		}
		pad(5);
		return;
	}
	if (n == 10)
	{
		if (self.menu == 10)
			p5(141, 16, 18, 17, ' ');
		else
			p5(32, 16, 18, 17, ' ');
	}
	else if (self.menu == n)
		p5(141, 16, 18 + n, 17, ' ');
	else
		p5(32, 16, 18 + n, 17, ' ');
};

float() pgold =
{
	float howm;

	howm = self.gp;
	p8('Y', 'o', 'u', ' ', 'H', 'a', 'v', 'e');
	p1(' ');
	pnum(howm);
	p5(' ', 'G', 'o', 'l', 'd');
	newline();
	return howm;
}

// this should be elsewhere
void(float got, float howmuch) pprice =
{
	if (self.skill & SKILL_DISCOUNT)
	{
		howmuch = ceil((0.8 - (self.title_x * 0.05)) * howmuch);
		
	}
	if (got < howmuch)
		red = RED_ON;
	p6('C', 'o', 's', 't', 's', ' ');
	pnum(howmuch);
	p5(' ', 'G', 'o', 'l', 'd');

};