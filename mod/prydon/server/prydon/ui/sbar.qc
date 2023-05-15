void() h_sbar =
{
	if (self.menu)
		return;

	trace_ent = self.cursor_trace_ent;
	if (trace_ent.classname == "func_door2")
	{
		trace_ent = trace_ent.enemy;
		if (trace_ent.solid != SOLID_BBOX)
			trace_ent = world;
	}

	if (!trace_ent)
	{
		if (!self.ptd)
		{
			if (!self.questlog || (self.options & OPT_NOQUEST_UPDATE))
			{
				if (!self.sbarsub)
				{
					if ((!self.spell) || (self.options & OPT_HIDESPELLS))
					{
						if (self.m_refresh > time)
							return;
							
						self.m_refresh = time + 1;
						centerprint(self, "");
					}
				}
			}
		}
	}
	if (trace_ent != self.sbarsub)
	{
		if (!self.cursor_active)
			if (self.sbarsub)
				self.sbarsub.effects = self.sbarsub.effects - (self.sbarsub.effects & EF_FULLBRIGHT);
		self.sbarsub = trace_ent;
	}
	else if (self.m_refresh > time)
		return;
		
	self.m_refresh = time + 1;

	pstart();
	padlines(11);
	
	if (!(self.options & OPT_NOQUEST_UPDATE))
	{
		if (self.questlog)
		{
			if (self.quest_time < time)
			{
				p8('Q', 'u', 'e', 's', 't', ' ', 'U', 'p');
				p4('d', 'a', 't', 'e');
				if (self.questlog == 1)
					sound2(self, "player/quest.wav");
				self.questlog = 2;
				newline();
			}
		}
	}
	if (self.ptd)
	{
		if (!(self.options & OPT_SEEN_PTD)) // ugly hack
		{
			if (self.misc & MISC_UPDATE_BLINK)
				red = RED_ON;
			p8('N', 'e', 'w', ' ', 'S', 't', 'a', 't');
			p1('s');
			newline();
		}
	}
	if (!(self.options & OPT_HIDESPELLS))
	{
		if (self.spell)
		{
	
			p7('S', 'p', 'e', 'l', 'l', ':', ' ');
			PrintSpellName(self.spell);
			newline();
		}
	}

	if (trace_ent.ui_hover)
	{
		other = self;
		trace_ent.ui_hover();
		self = other;
	}
	else if (trace_ent.classname == "item")
	{
		if (trace_ent.slot1_x)
		{
			if (!self.cursor_active)
				trace_ent.effects = trace_ent.effects | EF_FULLBRIGHT;
			it_simplestat(trace_ent.slot1);
			PrintItemName();
		}
		pend();
	}
	else if (trace_ent.solid == SOLID_SLIDEBOX && trace_ent.spawnflags & 1)
	{
		if (!self.cursor_active)
			trace_ent.effects = trace_ent.effects | EF_FULLBRIGHT;

		progressbar(trace_ent.health/trace_ent.max_health, 15);
		WriteString(msg_mode, trace_ent.owner.netname);
	}
	else if (trace_ent.ai & (AI_FOLLOW | AI_HUNT_PLAYER))
	{
		if (trace_ent.takedamage)
		{
			if (trace_ent.finalangle_x)
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
			if (!self.cursor_active)
				trace_ent.effects = trace_ent.effects | EF_FULLBRIGHT;
		}
		else
			pend();
	}
	else if (trace_ent.classname == "dummy")
	{
		PrintClass(trace_ent.owner.title);
		p2(' ', '(');
		pnum(trace_ent.owner.lvl);
		p1(')');
		newline();
		WriteString(msg_mode, trace_ent.owner.netname);
	}
	else if (trace_ent.action)
	{
		WriteString(msg_mode, trace_ent.netname);
		if (!self.cursor_active)
			trace_ent.effects = trace_ent.effects | EF_FULLBRIGHT;
	}
	else 
		pend();

			
};
