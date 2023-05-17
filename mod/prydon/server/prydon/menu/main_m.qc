#include "main_m.qh"

void m_mainmenu(entity this)
{
	if(this.menu < 1)
		this.menu = 10;
	else if(this.menu > 10)
		this.menu = 1;

	if(this.button1)
	{
		this.button1 = 0;

		if(this.menu == 1)
		{
			openmenu(this, m_stats, this.m_subject);
			return;
		}
		else if(this.menu == 2)
		{
			openmenu(this, m_invenlst, this.m_subject);
			return;
		}
		else if(this.menu == 3)
		{
			openmenu(this, m_spells1, this.m_subject);
			return;
		}
		else if(this.menu == 4)
		{
			openmenu(this, m_spells2, this.m_subject);
			return;
		}
		else if(this.menu == 5)
		{
			openmenu(this, m_skill, this.m_subject);
			return;
		}
		else if(this.menu == 6)
		{
			openmenu(this, m_quest, this.m_subject);
			return;
		}
		else if(this.menu == 7)
		{
			this.m_num = 0;
			openmenu(this, m_dropgold, this.m_subject);
			return;
		}
		else if(this.menu == 8)
		{
			openmenu(this, m_console, this.m_subject);
			this.menu = 97;
			return;
		}
		else if(this.menu == 9)
		{
			openmenu(this, m_options,this.m_subject);
			return;
		}
		closemenu(this);
		return;
	}
	
	if(this.m_refresh >= time)
		return;
		
	if(this.menu == 1)
		centerprint(this, "\{141}\[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 2)
		centerprint(this, " \[\1\] Stats    \n\{141}\[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 3)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n\{141}\[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 4)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n\{141}\[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 5)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n\{141}\[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 6)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n\{141}\[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 7)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n\{141}\[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 8)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n\{141}\[\8\] Console  \n \[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 9)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n\{141}\[\9\] Options  \n \[\0\] Exit     \n");
	else if(this.menu == 10)
		centerprint(this, " \[\1\] Stats    \n \[\2\] Inventory\n \[\3\] Spells 1 \n \[\4\] Spells 2 \n \[\5\] Skills   \n \[\6\] Quest Log\n \[\7\] Drop Gold\n \[\8\] Console  \n \[\9\] Options  \n\{141}\[\0\] Exit     \n");
	
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

}
