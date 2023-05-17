#include "console.qh"

float m_blink;
float m_cursorpos = 1;
float m_1, m_2, m_3, m_4, m_5, m_6, m_7, m_8, m_9, m_10, m_11, m_12,
	m_13, m_14, m_15, m_16, m_17, m_18, m_19, m_20, m_21, m_22, m_23,
	m_24, m_25, m_26;

// The below functions allow the above vars to act like a 26 long array
// This particular function gets values from the array
float array_m(float idx)
{
	if(idx == 1) return m_1;
	else if(idx == 2) return m_2;
	else if(idx == 3) return m_3;
	else if(idx == 4) return m_4;
	else if(idx == 5) return m_5;
	else if(idx == 6) return m_6;
	else if(idx == 7) return m_7;
	else if(idx == 8) return m_8;
	else if(idx == 9) return m_9;
	else if(idx == 10) return m_10;
	else if(idx == 11) return m_11;
	else if(idx == 12) return m_12;
	else if(idx == 13) return m_13;
	else if(idx == 14) return m_14;
	else if(idx == 15) return m_15;
	else if(idx == 16) return m_16;
	else if(idx == 17) return m_17;
	else if(idx == 18) return m_18;
	else if(idx == 19) return m_19;
	else if(idx == 20) return m_20;
	else if(idx == 21) return m_21;
	else if(idx == 22) return m_22;
	else if(idx == 23) return m_23;
	else if(idx == 24) return m_24;
	else if(idx == 25) return m_25;
	else if(idx == 26) return m_26;
	return -1; // invalid
}

// This one sets them
void set_array_m(float idx, float val)
{
	if(idx == 1)  { m_1 = val; return; }
	else if(idx == 2)  { m_2 = val; return; }
	else if(idx == 3)  { m_3 = val; return; }
	else if(idx == 4)  { m_4 = val; return; }
	else if(idx == 5)  { m_5 = val; return; }
	else if(idx == 6)  { m_6 = val; return; }
	else if(idx == 7)  { m_7 = val; return; }
	else if(idx == 8)  { m_8 = val; return; }
	else if(idx == 9)  { m_9 = val; return; }
	else if(idx == 10)  { m_10 = val; return; }
	else if(idx == 11)  { m_11 = val; return; }
	else if(idx == 12)  { m_12 = val; return; }
	else if(idx == 13)  { m_13 = val; return; }
	else if(idx == 14)  { m_14 = val; return; }
	else if(idx == 15)  { m_15 = val; return; }
	else if(idx == 16)  { m_16 = val; return; }
	else if(idx == 17)  { m_17 = val; return; }
	else if(idx == 18)  { m_18 = val; return; }
	else if(idx == 19)  { m_19 = val; return; }
	else if(idx == 20)  { m_20 = val; return; }
	else if(idx == 21)  { m_21 = val; return; }
	else if(idx == 22)  { m_22 = val; return; }
	else if(idx == 23)  { m_23 = val; return; }
	else if(idx == 24)  { m_24 = val; return; }
	else if(idx == 25)  { m_25 = val; return; }
	else if(idx == 26)  { m_26 = val; return; }
}

void M_WriteChar(float c)
{
	// delete command
	if(c == 96)
	{
		p3('D', 'E', 'L');
		return;
	}	
	else if(c == 97)
	{ 
		p3('E', 'X', 'T');
		return;
	}	

	else if(c == 98)
	{
		p3('E', 'N', 'D');
		return;
	}
	else if(c > 98)
	{
		p3(' ', ' ', ' ');
		return;
	}
	else if((c > 64) && (c < 91))
		c = c + 32;
	WriteChar(msg_mode, c);
}

void m_console(entity this)
{
	float i, c;
	if(this.menu < 32)
		this.menu = 98;
	else if(this.menu > 98)
		this.menu = 32;
	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 96)
		{
			set_array_m(m_cursorpos, 0);
			if(m_cursorpos > 1)
				m_cursorpos = m_cursorpos - 1;
		}
		else if(this.menu == 97)
		{
			closemenu(this);
			return;
		}
		else if(this.menu == 98)
		{
			closemenu(this);
			WriteChar(msg_mode, 9);
			c = 1;
			while(c < m_cursorpos)
			{
				M_WriteChar(array_m(c));
				c = c + 1;
			}
			WriteChar(msg_mode, 10);
			WriteChar(msg_mode, 0);
			return;
		}	
		else
		{
			set_array_m(m_cursorpos, this.menu);
			if(m_cursorpos < 26)
				m_cursorpos = m_cursorpos + 1;
		}
	}
	if(this.m_refresh >= time)
		return;

	pstart(this);
	
	// Write out what has already been entered
	c = 1;
	while(c < m_cursorpos)
	{
		M_WriteChar(array_m(c));
		c = c + 1;
	}
	// blink the cursor
	m_blink = !m_blink;
	if(m_blink)
		WriteChar( msg_mode, 11);
	else
		WriteChar( msg_mode, 32);
	WriteChar(msg_mode, 10);
	WriteChar(msg_mode, 10);
	c = 32;
	i = 1;
	while(c < 104)
	{
		if(this.menu == c)
			WriteChar(msg_mode, 141);
		else 
			WriteChar( msg_mode, 32);
		M_WriteChar(c);
		if(c < 96)
		{
			WriteChar( msg_mode, 32);
			WriteChar( msg_mode, 32);
		}
		c = c + 1;
		i = i + 1;
		if(i >= 8)
		{
			i = 1;
			WriteChar( msg_mode, 10);
		}
	}
	// and finish up
	WriteChar(msg_mode, 0);
}
