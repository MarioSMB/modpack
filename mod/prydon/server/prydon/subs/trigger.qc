
void(string h) menutrigger =
{
	if (h == "m_sell")
		openmenu(s_player, m_sell, activator);
	else if (h == "m_repair")
		openmenu(s_player, m_repair, activator);
	else if (h == "m_exit")
		closemenu(s_player);
	else if (h == "m_reset")
		activator.m_targ = activator.m_subject;
	else if (h == "m_save")
		InnSave(5);
	else if (h == "m_identify")
		openmenu(s_player, m_identify, activator);
	else if (h == "m_save2") // save w/no gp
		InnSave(0);
// USELESS JUNK BEGIN
	else if (h == "m_inven")
		openmenu(s_player, m_invenlst, activator);
	else if (h == "m_spells1")
		openmenu(s_player, m_spells1, activator);
	else if (h == "m_spells2")
		openmenu(s_player, m_spells2, activator);
	else if (h == "m_mainmenu")
		openmenu(s_player, m_mainmenu, activator);
	else if (h == "m_stats")
		openmenu(s_player, m_stats, activator);
	else if (h == "m_skill")
		openmenu(s_player, m_skill, activator);
// USELESS JUNK END
	else if (h == "m_restock")
		openmenu(s_player, m_restock, activator);
	else if (h == "m_deposit")
		openmenu(s_player, m_deposit, activator);
	else if (h == "m_withdraw")
		openmenu(s_player, m_withdraw, activator);
	else if (h == "m_buy")
		openmenu(s_player, m_buy, activator);
	else if (h == "m_recharge")
		openmenu(s_player, m_recharge, activator);
// Random Quest stuff -- DO NOT USE
	else if (h == "rq_accept")
		rq_accept(activator);
	else if (h == "rq_cancel")
		rq_cancel();
	else if (h == "rq_mondie")
		rq_mondie();
	else if (h == "rq_rescue")
		rq_rescue(activator);
	else if (h == "rq_reward")
		rq_reward(s_player);
	else if (h == "rq_recieve")
		rq_recieve(s_player);
};

float(entity who, string s, float i) DoTrigger =
{
	local float total;
	local entity n;
	
	total = 0;
	if (!s)
		return 0;
	n = find(world, targetname, s);
	while(n)
	{

		if (RequirementsMet(n, s_player))
		{
			if (n.rand_trig)
			{
				total = total + 1;
				if (i == total)
				{
					if (n.use)
						call(n.use, n);
					return i;
				}
			}
			else if (!i)
				if (n.use)
					call(n.use, n);
		}	
		n = find(n, targetname, s);
	}
	if (total > 0)
	{
		if (!i)
		{
			i = floor(random() * total) + 1;
			if (who.rand_sel > 0)
			{
				DoTrigger(who, s, who.rand_sel);
				return who.rand_sel;
			}
			else if (who.rand_sel == -1)
				who.rand_sel = i;
			DoTrigger(who, s, i);
			return i;
		}
	}
	menutrigger(s);
	return 0;
};
void(entity who, entity snpc, entity splayer, float num) Trigger =
{
	s_player = splayer;
	
	if (who.subject)
	{
		if (who.subject == "s_player")
			activator = splayer;
		else if (who.subject == "s_npc")
			activator = snpc;
		else
			activator = find(world, targetname, who.subject);
	}
	else
		activator = snpc;
	other = splayer;
	
	if (!num)
	{
		DoTrigger(who, who.target, 0);
		DoTrigger(who, who.target1, 0);
		DoTrigger(who, who.target2, 0);
		DoTrigger(who, who.target3, 0);
		DoTrigger(who, who.target4, 0);
		DoTrigger(who, who.target5, 0);
		DoTrigger(who, who.target6, 0);
		DoTrigger(who, who.target7, 0);
		DoTrigger(who, who.target8, 0);
	}
	else if (num == 1)
		DoTrigger(who, who.target1, 0);
	else if (num == 2)
		DoTrigger(who, who.target2, 0);
	else if (num == 3)
		DoTrigger(who, who.target3, 0);
	else if (num == 4)
		DoTrigger(who, who.target4, 0);
	else if (num == 5)
		DoTrigger(who, who.target5, 0);
	else if (num == 6)
		DoTrigger(who, who.target6, 0);
	else if (num == 7)
		DoTrigger(who, who.target7, 0);
	else if (num == 8)
		DoTrigger(who, who.target8, 0);
};

void() generictrigger = 
{
	Trigger(self, other, self, 0);
};

void() playertrigger=
{
	local entity e;
	e = self.m_subject;
	if (self.classname == "dummy")
		self.m_subject = self;
		
	Trigger(self, self, other, 4);
	if (self.m_subject == self)
		self.m_subject = e;
};

void() InitTrigger =
{
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};