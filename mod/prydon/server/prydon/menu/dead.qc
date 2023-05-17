#include "dead.qh"

void m_dead(entity this)
{
	if(this.menu < 1)
		this.menu = 2;
	else if(this.menu > 2)
		this.menu = 1;

	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 2 || mplayer)
		{
			closemenu(this);
			this.player = NULL;
			this.misc |= MISC_RESPAWN;
			PutClientInServer(this);
			this.health = this.max_health;			
			return;
		}
		else
		{
			closemenu(this);
			localcmd("restart\n");
		}
	}
	
	if(this.m_refresh >= time)
		return;
	if(mplayer)
	{
		centerprint(this, "You have perished.\n\n\{141}\[\1\] Naked run    \n");
	}
	else
	{
		if(this.menu == 1)
			centerprint(this, "You have perished.\n\n\{141}\[\1\] Restart level\n \[\2\] Naked run    \n");
		else
			centerprint(this, "You have perished.\n\n \[\1\] Restart level\n\{141}\[\2\] Naked run    \n");
	}
}
