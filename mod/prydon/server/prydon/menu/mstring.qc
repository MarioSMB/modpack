#include "mstring.qh"

string s1, s2, s3, s4, s5, s6, s7;
float strings;
float moptions;

string l_alis = "\
My Dearest Alis,                       \n\n\
It's probably a shock to get a letter  \n\
from me, as it must seem I died years  \n\
ago. Recently a gateway was created    \n\
that granted access to this world.     \n\
I must urge you to leave Capel Curig,  \n\
it will not be safe for much longer.   \n\
                                 Ramuka\n";


void mstring_clear()
{
	s1 = s2 = s3 = s4 = s5 = s6 = s7 = "";
	strings = 0;
	moptions = 0;
}
void mstring_add(entity this, string h)
{
	if(h == "player_name")
		h = this.netname;
	else if(h == "l_alis")
		h = l_alis;
	else if(h == "l_player")
		h = this.netname;
	// what use are these?
	else if(h == "l_pclass")
		h = ClassString(this.title);
	else if(h == "l_ppre")
		h = ClassPreString(this.title);
	else if(h == "l_myname")
		h = this.m_subject.netname;
	else if(h == "l_pstat")
	{
		if(this.m_subject.mod_field)
			h = ftos(this.(this.m_subject.mod_field));
		else
			h = "**stat**";
	}
	else if(h == "l_mstat")
	{
		if(this.m_subject.mod_field)
			h = ftos(this.m_subject.(this.m_subject.mod_field));
		else
			h = "**stat**";
	}
	else if(h == "l_talk")
		return;
	if(strings == 0)
		s1 = h;
	else if(strings == 1)
		s2 = h;
	else if(strings == 2)
		s3 = h;
	else if(strings == 3)
		s4 = h;	
	else if(strings == 4)
		s5 = h;
	else if(strings == 5)
		s6 = h;
	else if(strings == 6)
		s7 = h;
	strings += 1;
}

void mstring_print(entity this)
{
	centerprint(this, s1, s2, s3, s4, s5, s6, s7);
}

void mstring_addop(entity this)
{
	moptions += 1;
	if(this.menu == moptions)
	{
		if(moptions == 1)
			mstring_add(this, "\n\n\{141}\[\1\] ");
		else if(moptions == 2)
			mstring_add(this, "\n\{141}\[\2\] ");
		else if(moptions == 3)
			mstring_add(this, "\n\{141}\[\3\] ");
	}
	else
	{
		if(moptions == 1)
			mstring_add(this, "\n\n \[\1\] ");
		else if(moptions == 2)
			mstring_add(this, "\n \[\2\] ");
		else if(moptions == 3)
			mstring_add(this, "\n \[\3\] ");
	}
}
