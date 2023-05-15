void() m_mainmenu =
{
	if (self.menu < 1)
		self.menu = 10;
	else if (self.menu > 10)
		self.menu = 1;

	if (self.button1)
	{
		self.button1 = 0;

		if (self.menu == 1)
		{
			openmenu(self, m_stats, self.m_subject);
			return;
		}
		else if (self.menu == 2)
		{
			openmenu(self, m_invenlst, self.m_subject);
			return;
		}
		else if (self.menu == 3)
		{
			openmenu(self, m_spells1, self.m_subject);
			return;
		}
		else if (self.menu == 4)
		{
			openmenu(self, m_spells2, self.m_subject);
			return;
		}
		else if (self.menu == 5)
		{
			openmenu(self, m_skill, self.m_subject);
			return;
		}
		else if (self.menu == 6)
		{
			openmenu(self, m_quest, self.m_subject);
			return;
		}
		else if (self.menu == 7)
		{
			self.m_num = 0;
			openmenu(self, m_dropgold, self.m_subject);
			return;
		}
		else if (self.menu == 8)
		{
			openmenu(self, m_console, self.m_subject);
			self.menu = 97;
			return;
		}
		else if (self.menu == 9)
		{
			openmenu(self, m_opitions,self.m_subject);
			return;
		}
		closemenu(self);
		return;
	}
	
	if (self.m_refresh >= time)
		return;
		
	if (self.menu == 1)
		centerprint(self, "\{141}\[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 2)
		centerprint(self, " \[\1\] Stats    \n\{141}\[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 3)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n\{141}\[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 4)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n\{141}\[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 5)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n\{141}\[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 6)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n\{141}\[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 7)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n\{141}\[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 8)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n\{141}\[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 9)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n\{141}\[\9\] Options  \n \[\0\] Exit     \n");
	else if (self.menu == 10)
		centerprint(self, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n\{141}\[\0\] Exit     \n");
	
/*
 \[\1\] Stats    \n
 \[\2\] Inventory\n
 \[\3\] Spells 1 \n
 \[\4\] Spells 2 \n
 \[\5\] Skills   \n
 \[\6\] Quest Log\n
 \[\7\] Drop Gold\n
 \[\8\] Console  \n
 \[\9\] Options  \n \[\0\] Exit     \n
*/

};