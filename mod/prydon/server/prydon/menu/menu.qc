/*
Menus

main menu (for DC users mostly)
- magic
- inventory slots
- stats
- exit
inventory slots 1-8
- drop
- equip / use / buy / pickup
- repair (in town)

magic menu
(list of spells, you select one then go back to the game)

stats
(list of stats, can increase some on level up)


*/

void(entity who, void() menufunc, entity subj) openmenu =
{
	if (who.owner)
		who = who.owner;
	if (who.classname != "player")
		return;
	who.m_subject = subj;
	who.menu = TRUE;
	who.m_refresh = 0;
	who.weaponmodel = string_null;
	if (who.vmodel)
	{
		remove(who.vmodel);
		who.vmodel = world;
	}
	who.m_func = menufunc;
	who.m_num = 0;
	stuffcmd(who, "m_on\n");
};

void(entity who) closemenu =
{
	if (!who)
		return;
	who.m_refresh = 0;
	who.m_func = SUB_Null;
	if (who.m_subject.m_subject == who.player)
		if (who.m_subject)
			who.m_subject.m_subject = world;
	who.m_targ = world; // reset
	who.m_subject = world;
	who.menu = 0;
	who.weaponmodel = string_null;
	if (who.vmodel)
	{
		remove(who.vmodel);
		who.vmodel = world;
	}
	who.m_expire = 0;
	if (who.classname != "player")
		return;
	stuffcmd(who, "m_off\n");
	centerprint(who, " ");

};

void() m_prompt =
{
	if (self.m_refresh < time)
		centerprint(self, self.message);
};

void(entity who, string text, entity subj, float expire) prompt =
{
	openmenu(who, m_prompt, subj);
	if (expire)
		who.m_expire = time + expire;
	else
		who.m_expire = 0;
	who.message = text;
};


void m_menu(entity this)
{
	local vector v;
	if (!self.menu)
		return;
	// check menu dismissal conditions
	if (self.m_subject)
	{
		if (self.m_subject != self)
		{
			if (self.m_subject.origin != '0 0 0')
			{
				v = self.player.origin - self.m_subject.origin;
				v_z = 0;
				if (vlen(v) > 60)
					self.menu = 0;
			}
		}
	}
	else
		self.menu = 0;
	if (self.m_expire)
		if (self.m_expire < time)
			self.menu = 0;
	if (self.menu)
	{
		if (self.impulse == 18)
		{
			self.menu = self.menu - 1;
			self.m_refresh = 0;
			self.impulse = -1;
		}
		else if (self.impulse == 12)
		{
			self.menu = self.menu + 1;
			self.m_refresh = 0;
			self.impulse = 0;
		}
		else if ((self.impulse > 0) && (self.impulse < 11))
		{
			self.menu = self.impulse;
			self.m_refresh = 0;
			self.impulse = 0;
			self.button1 = 1;	
		}
		if (self.button1)
		{
			self.m_refresh = 0;
		}
		
		self.m_func();
		if (self.menu)
		{
			if (self.m_refresh)
			{
				
				if (self.m_refresh < time)
				{
					self.m_refresh = time + 49;

				}
			}
			else
				self.m_refresh = 1;
		}
		
	}
	
	if (!self.menu)
		closemenu(self);
};
