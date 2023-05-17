#include "pin.qh"

void Secure_Boot(entity this, string msg)
{
	sprint(this, msg);
	this.menu = 0;
	dropclient(this);

}

void Authed(entity this, float lock)
{
	// lock the character by appending 'authed'
	this.authed = AUTH_YES;
}

void Secure_GetPin(entity this)
{
	if(!mplayer)
		return;
	if(!fileaccess)
	{
		Authed(this, false);
		return;
	}
	strcpy(this.username, this.netname);	
	if(!secure)
	{
		Authed(this, false);
		return;
	}
	this.authed = AUTH_SIGNUP;
	string fname = this.username;
	fname = strcat(fname, ".pgf");
	qopenread(fname);
	if(fileerror)
	{
		if(secure & 2)
			Secure_Boot(this, "\bServer doesn't allow new users\b\n");
		return;
	}
	string s = qread();
	if(stof(s) != SAVE_VERSION)
		return;
	this.pin = stof(qread());
	qclose();
	setspawnparms(this);
	if(this.pin == 0)
		return;
	else if(parm2 == this.pin)
		Authed(this, true);
	else
		this.authed = AUTH_NO;
	parm2 = 0;		
}

void ClientSpawn(entity this);

void m_pin(entity this)
{
	float n;
	
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
		this.m_num = this.m_num * 10 + n;
	}
	else if(this.button0 || this.button2)
	{

		if(this.authed == AUTH_SIGNUP)
		{
			// don't allow 0
			if(this.m_num)
			{
				this.pin = this.m_num;
				Authed(this, false);
				this.menu = 0;
				ClientSpawn(this);
			}
		}
		else if(this.m_num != this.pin)
		{
			if(this.m_num)
			{
				Secure_Boot(this, "\bIncorrect pin number\b\n");
			}
		}
		else
		{
			Authed(this, true);
			this.menu = 0;
			ClientSpawn(this);
		}
	}
	
	if(this.m_refresh < time)
	{
		if(!this.m_refresh)
			this.misc &= ~MISC_UPDATE_BLINK;
			
		pstart(this);
		if(this.authed == AUTH_SIGNUP)
			p8('N', 'e', 'w', ' ', 'U', 's', 'e', 'r');
		else
			p5('L', 'o', 'g', 'i', 'n');
			
		newline();
		
		p8('E', 'n', 't', 'e', 'r', ' ', 'P', 'i');
		p1('n');
		newline();
		line();

		if(this.m_num)
			pnum(this.m_num);
		red = RED_ON;
		if(this.misc & MISC_UPDATE_BLINK)
			p1(11);
		else
			pnum(n);
		red = 0;
		newline();
		
		p8('F', 'o', 'r', ' ', 'U', 's', 'e', 'r');
		p5('n', 'a', 'm', 'e', ':');
		newline();
		WriteString(msg_mode, this.username);
		this.m_refresh = time + 1;
	}
}
