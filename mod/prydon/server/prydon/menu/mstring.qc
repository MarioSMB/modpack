nosave string s1, s2, s3, s4, s5, s6, s7;
nosave float strings;
nosave float moptions;

string l_alis = "\
My Dearest Alis,                       \n\n\
It's probably a shock to get a letter  \n\
from me, as it must seem I died years  \n\
ago. Recently a gateway was created    \n\
that granted access to this world.     \n\
I must urge you to leave Capel Curig,  \n\
it will not be safe for much longer.   \n\
                                 Ramuka\n";


void() mstring_clear =
{
	s1 = s2 = s3 = s4 = s5 = s6 = s7 = "";
	strings = 0;
	moptions = 0;
};
void(string h) mstring_add =
{
	if (h == "player_name")
		h = self.netname;
	else if (h == "l_alis")
		h = l_alis;
	else if (h == "l_player")
		h = self.netname;
	// what use are these?
	else if (h == "l_pclass")
		h = ClassString(self.title);
	else if (h == "l_ppre")
		h = ClassPreString(self.title);
	else if (h == "l_myname")
		h = self.m_subject.netname;
	else if (h == "l_pstat")
	{
		if (self.m_subject.mod_field)
			h = ftos(self.(self.m_subject.mod_field));
		else
			h = "**stat**";
	}
	else if (h == "l_mstat")
	{
		if (self.m_subject.mod_field)
			h = ftos(self.m_subject.(self.m_subject.mod_field));
		else
			h = "**stat**";
	}
	else if (h == "l_talk")
		return;
	if (strings == 0)
		s1 = h;
	else if (strings == 1)
		s2 = h;
	else if (strings == 2)
		s3 = h;
	else if (strings == 3)
		s4 = h;	
	else if (strings == 4)
		s5 = h;
	else if (strings == 5)
		s6 = h;
	else if (strings == 6)
		s7 = h;
	strings = strings + 1;
}

void () mstring_print =
{
	centerprint(self, s1, s2, s3, s4, s5, s6, s7);
};

void () mstring_addop =
{
	moptions = moptions + 1;
	if (self.menu == moptions)
	{
		if (moptions == 1)
			mstring_add("\n\n\{141}\[\1\] ");
		else if (moptions == 2)
			mstring_add("\n\{141}\[\2\] ");
		else if (moptions == 3)
			mstring_add("\n\{141}\[\3\] ");
	
	}
	else
	{
		if (moptions == 1)
			mstring_add("\n\n \[\1\] ");
		else if (moptions == 2)
			mstring_add("\n \[\2\] ");
		else if (moptions == 3)
			mstring_add("\n \[\3\] ");
	}

};