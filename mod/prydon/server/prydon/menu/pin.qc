void(string msg) Secure_Boot =
{
	sprint(self, msg);
	self.menu = 0;
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_DISCONNECT);

};
void(float lock) Authed =
{
	// lock the character by appending 'authed'
	self.authed = AUTH_YES;
};

void() Secure_GetPin =
{
	string fname, s;
	if (!mplayer)
		return;
	if (!fileaccess)
	{
		Authed(FALSE);
		return;
	}
	self.username = strzone(self.netname);	
	if (!secure)
	{
		Authed(FALSE);
		return;
	}
	self.authed = AUTH_SIGNUP;
	fname = self.username;
	fname = strcat(fname, ".pgf");
	qopenread(fname);
	if (fileerror)
	{
		if (secure & 2)
			Secure_Boot("\bServer doesn't allow new users\b\n");
		return;
	}
	s = qread();
	if (stof(s) != SAVE_VERSION)
		return;
	self.pin = stof(qread());
	qclose();
	setspawnparms(self);
	if (self.pin == 0)
		return;
	else if (parm2 == self.pin)
		Authed(TRUE);
	else
		self.authed = AUTH_NO;
	parm2 = 0;		
};
void() ClientSpawn;

void() m_pin =
{
	float n;
	
	if (self.menu < 1)
		self.menu = 10;
	else if (self.menu > 10)
		self.menu = 1;
	if (self.menu == 10)
		n = 0;
	else
		n = self.menu;
		
	if (self.button1)
	{
		self.m_num = self.m_num * 10 + n;
	}
	else if (self.button0 || self.button2)
	{

		if (self.authed == AUTH_SIGNUP)
		{
			// don't allow 0
			if (self.m_num)
			{
				self.pin = self.m_num;
				Authed(FALSE);
				self.menu = 0;
				ClientSpawn();
			}
		}
		else if (self.m_num != self.pin)
		{
			if (self.m_num)
			{
				Secure_Boot("\bIncorrect pin number\b\n");
			}
		}
		else
		{
			Authed(TRUE);
			self.menu = 0;
			ClientSpawn();
		}
	}
	
	if (self.m_refresh < time)
	{
		if (!self.m_refresh)
			self.misc = self.misc - (self.misc & MISC_UPDATE_BLINK);
			
		pstart();
		if (self.authed == AUTH_SIGNUP)
			p8('N', 'e', 'w', ' ', 'U', 's', 'e', 'r');
		else
			p5('L', 'o', 'g', 'i', 'n');
			
		newline();
		
		p8('E', 'n', 't', 'e', 'r', ' ', 'P', 'i');
		p1('n');
		newline();
		line();

		if (self.m_num)
			pnum(self.m_num);
		red = RED_ON;
		if (self.misc & MISC_UPDATE_BLINK)
			p1(11);
		else
			pnum(n);
		red = 0;
		newline();
		
		p8('F', 'o', 'r', ' ', 'U', 's', 'e', 'r');
		p5('n', 'a', 'm', 'e', ':');
		newline();
		WriteString(msg_mode, self.username);
		self.m_refresh = time + 1;
	}
}
