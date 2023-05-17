#include "sbar.qh"

#include "../spells/pspell.qh"
#include "../subs/subs.qh"

bool BROKEN = true;
void h_sbar(entity this)
{
	if(this.menu)
		return;
	if(BROKEN)
		return;

	trace_ent = this.cursor_trace_ent;
	if(trace_ent.classname == "func_door2")
	{
		trace_ent = trace_ent.enemy;
		if(trace_ent.solid != SOLID_BBOX)
			trace_ent = NULL;
	}

	if(!trace_ent)
	{
		if(!this.ptd)
		{
			if(!this.questlog || (this.options & OPT_NOQUEST_UPDATE))
			{
				if(!this.sbarsub)
				{
					if((!this.spell) || (this.options & OPT_HIDESPELLS))
					{
						if(this.m_refresh > time)
							return;
							
						this.m_refresh = time + 1;
						centerprint(this, "");
					}
				}
			}
		}
	}
	if(trace_ent != this.sbarsub)
	{
		if(!this.cursor_active)
			if(this.sbarsub)
				this.sbarsub.effects = this.sbarsub.effects - (this.sbarsub.effects & EF_FULLBRIGHT);
		this.sbarsub = trace_ent;
	}
	else if(this.m_refresh > time)
		return;
		
	this.m_refresh = time + 1;

	pstart(this);
	padlines(11);
	
	if(!(this.options & OPT_NOQUEST_UPDATE))
	{
		if(this.questlog)
		{
			if(this.quest_time < time)
			{
				p8('Q', 'u', 'e', 's', 't', ' ', 'U', 'p');
				p4('d', 'a', 't', 'e');
				if(this.questlog == 1)
					sound2(this, "player/quest.wav");
				this.questlog = 2;
				newline();
			}
		}
	}
	if(this.ptd)
	{
		if(!(this.options & OPT_SEEN_PTD)) // ugly hack
		{
			if(this.misc & MISC_UPDATE_BLINK)
				red = RED_ON;
			p8('N', 'e', 'w', ' ', 'S', 't', 'a', 't');
			p1('s');
			newline();
		}
	}
	if(!(this.options & OPT_HIDESPELLS))
	{
		if(this.spell)
		{
	
			p7('S', 'p', 'e', 'l', 'l', ':', ' ');
			PrintSpellName(this.spell);
			newline();
		}
	}

	if(trace_ent.ui_hover)
	{
		trace_ent.ui_hover(trace_ent, this);
	}
	else if(trace_ent.classname == "item")
	{
		if(trace_ent.slot1_x)
		{
			if(!this.cursor_active)
				trace_ent.effects |= EF_FULLBRIGHT;
			it_simplestat(this, trace_ent.slot1);
			PrintItemName();
		}
		pend();
	}
	else if(trace_ent.solid == SOLID_SLIDEBOX && trace_ent.spawnflags & 1)
	{
		if(!this.cursor_active)
			trace_ent.effects |= EF_FULLBRIGHT;

		progressbar(trace_ent.health/trace_ent.max_health, 15);
		WriteString(msg_mode, trace_ent.owner.netname);
	}
	else if(trace_ent.ai & (AI_FOLLOW | AI_HUNT_PLAYER))
	{
		if(trace_ent.takedamage)
		{
			if(trace_ent.finalangle_x)
			{
				PrintMonsterName(trace_ent);
				newline();
				p7('H', 'e', 'a', 'l', 't', 'h', ':');
				pnum(trace_ent.health);
				p1('/');
				pnum(trace_ent.max_health);
				p1(0);
			}
			else
			{
				p7('H', 'e', 'a', 'l', 't', 'h', ':');
				pnum(trace_ent.health);
				p1('/');
				pnum(trace_ent.max_health);
				newline();
				WriteString(msg_mode, trace_ent.netname);
			}
			if(!this.cursor_active)
				trace_ent.effects |= EF_FULLBRIGHT;
		}
		else
			pend();
	}
	else if(trace_ent.classname == "dummy")
	{
		PrintClass(trace_ent.owner.title);
		p2(' ', '(');
		pnum(trace_ent.owner.lvl);
		p1(')');
		newline();
		WriteString(msg_mode, trace_ent.owner.netname);
	}
	else if(trace_ent.action)
	{
		WriteString(msg_mode, trace_ent.netname);
		if(!this.cursor_active)
			trace_ent.effects |= EF_FULLBRIGHT;
	}
	else 
		pend();
}
