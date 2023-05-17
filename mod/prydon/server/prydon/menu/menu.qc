#include "menu.qh"

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

void openmenu(entity who, void(entity) menufunc, entity subj)
{
	if(who.owner)
		who = who.owner;
	if(!IS_PLAYER(who))
		return;
	who.m_subject = subj;
	who.menu = true;
	who.m_refresh = 0;
	who.weaponmodel = string_null;
	if(who.vmodel)
	{
		delete(who.vmodel);
		who.vmodel = NULL;
	}
	who.m_func = menufunc;
	who.m_num = 0;
	stuffcmd(who, "m_on\n");
}

void closemenu(entity who)
{
	if(!who)
		return;
	who.m_refresh = 0;
	who.m_func = func_null;
	if(who.m_subject.m_subject == who.player)
		if(who.m_subject)
			who.m_subject.m_subject = NULL;
	who.m_targ = NULL; // reset
	who.m_subject = NULL;
	who.menu = 0;
	who.weaponmodel = string_null;
	if(who.vmodel)
	{
		delete(who.vmodel);
		who.vmodel = NULL;
	}
	who.m_expire = 0;
	if(who.classname != "player")
		return;
	stuffcmd(who, "m_off\n");
	centerprint(who, " ");
}

void m_prompt(entity this)
{
	if(this.m_refresh < time)
		centerprint(this, this.message);
}

void prompt(entity who, string text, entity subj, float expire)
{
	openmenu(who, m_prompt, subj);
	if(expire)
		who.m_expire = time + expire;
	else
		who.m_expire = 0;
	who.message = text;
}


void m_menu(entity this)
{
	if(!this.menu)
		return;
	// check menu dismissal conditions
	if(this.m_subject)
	{
		if(this.m_subject != this)
		{
			if(this.m_subject.origin != '0 0 0')
			{
				vector v = this.player.origin - this.m_subject.origin;
				v.z = 0;
				if(vdist(v, >, 60))
					this.menu = 0;
			}
		}
	}
	else
		this.menu = 0;
	if(this.m_expire)
		if(this.m_expire < time)
			this.menu = 0;
	if(this.menu)
	{
		if(this.impulse == 18)
		{
			this.menu -= 1;
			this.m_refresh = 0;
			this.impulse = -1;
		}
		else if(this.impulse == 12)
		{
			this.menu += 1;
			this.m_refresh = 0;
			this.impulse = 0;
		}
		else if((this.impulse > 0) && (this.impulse < 11))
		{
			this.menu = this.impulse;
			this.m_refresh = 0;
			this.impulse = 0;
			this.button1 = 1;	
		}
		if(this.button1)
		{
			this.m_refresh = 0;
		}
		
		this.m_func(this);
		if(this.menu)
		{
			if(this.m_refresh)
			{
				
				if(this.m_refresh < time)
				{
					this.m_refresh = time + 49;
				}
			}
			else
				this.m_refresh = 1;
		}
		
	}
	
	if(!this.menu)
		closemenu(this);
}
