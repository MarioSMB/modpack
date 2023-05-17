#include "trigger.qh"

#include "../quests/rq_dialog.qh"
#include "reqs.qh"
#include "saves.qh"

void menutrigger(string h, entity actor, entity trigger)
{
	if(h == "m_sell")
		openmenu(s_player, m_sell, actor);
	else if(h == "m_repair")
		openmenu(s_player, m_repair, actor);
	else if(h == "m_exit")
		closemenu(s_player);
	else if(h == "m_reset")
		actor.m_targ = actor.m_subject;
	else if(h == "m_save")
		InnSave(actor, trigger, 5);
	else if(h == "m_identify")
		openmenu(s_player, m_identify, actor);
	else if(h == "m_save2") // save w/no gp
		InnSave(actor, trigger, 0);
// USELESS JUNK BEGIN
	else if(h == "m_inven")
		openmenu(s_player, m_invenlst, actor);
	else if(h == "m_spells1")
		openmenu(s_player, m_spells1, actor);
	else if(h == "m_spells2")
		openmenu(s_player, m_spells2, actor);
	else if(h == "m_mainmenu")
		openmenu(s_player, m_mainmenu, actor);
	else if(h == "m_stats")
		openmenu(s_player, m_stats, actor);
	else if(h == "m_skill")
		openmenu(s_player, m_skill, actor);
// USELESS JUNK END
	else if(h == "m_restock")
		openmenu(s_player, m_restock, actor);
	else if(h == "m_deposit")
		openmenu(s_player, m_deposit, actor);
	else if(h == "m_withdraw")
		openmenu(s_player, m_withdraw, actor);
	else if(h == "m_buy")
		openmenu(s_player, m_buy, actor);
	else if(h == "m_recharge")
		openmenu(s_player, m_recharge, actor);
// Random Quest stuff -- DO NOT USE
	else if(h == "rq_accept")
		rq_accept(actor);
	else if(h == "rq_cancel")
		rq_cancel(actor);
	else if(h == "rq_mondie")
		rq_mondie(actor);
	else if(h == "rq_rescue")
		rq_rescue(actor);
	else if(h == "rq_reward")
		rq_reward(s_player, actor);
	else if(h == "rq_recieve")
		rq_recieve(s_player, actor);
}

bool DoTrigger(entity who, string s, float i, entity actor, entity trigger)
{
	int total = 0;
	if(!s)
		return 0;
	entity n = find(NULL, targetname, s);
	while(n)
	{
		if(RequirementsMet(n, s_player))
		{
			if(n.rand_trig)
			{
				total = total + 1;
				if(i == total)
				{
					if(n.use)
						n.use(n, actor, trigger);
					return i;
				}
			}
			else if(!i)
				if(n.use)
					n.use(n, actor, trigger);
		}	
		n = find(n, targetname, s);
	}
	if(total > 0)
	{
		if(!i)
		{
			i = floor(random() * total) + 1;
			if(who.rand_sel > 0)
			{
				DoTrigger(who, s, who.rand_sel, actor, trigger);
				return who.rand_sel;
			}
			else if(who.rand_sel == -1)
				who.rand_sel = i;
			DoTrigger(who, s, i, actor, trigger);
			return i;
		}
	}
	menutrigger(s, actor, trigger);
	return 0;
}

void Trigger(entity who, entity snpc, entity splayer, float num)
{
	s_player = splayer;
	entity targ = snpc;
	
	if(who.subject)
	{
		if(who.subject == "s_player")
			targ = splayer;
		else if(who.subject == "s_npc")
			targ = snpc;
		else
			targ = find(NULL, targetname, who.subject);
	}
	
	if(!num)
	{
		DoTrigger(who, who.target, 0, targ, splayer);
		DoTrigger(who, who.target1, 0, targ, splayer);
		DoTrigger(who, who.target2, 0, targ, splayer);
		DoTrigger(who, who.target3, 0, targ, splayer);
		DoTrigger(who, who.target4, 0, targ, splayer);
		DoTrigger(who, who.target5, 0, targ, splayer);
		DoTrigger(who, who.target6, 0, targ, splayer);
		DoTrigger(who, who.target7, 0, targ, splayer);
		DoTrigger(who, who.target8, 0, targ, splayer);
	}
	else if(num == 1)
		DoTrigger(who, who.target1, 0, targ, splayer);
	else if(num == 2)
		DoTrigger(who, who.target2, 0, targ, splayer);
	else if(num == 3)
		DoTrigger(who, who.target3, 0, targ, splayer);
	else if(num == 4)
		DoTrigger(who, who.target4, 0, targ, splayer);
	else if(num == 5)
		DoTrigger(who, who.target5, 0, targ, splayer);
	else if(num == 6)
		DoTrigger(who, who.target6, 0, targ, splayer);
	else if(num == 7)
		DoTrigger(who, who.target7, 0, targ, splayer);
	else if(num == 8)
		DoTrigger(who, who.target8, 0, targ, splayer);
}

void generictrigger(entity this, entity actor, entity trigger)
{
	Trigger(this, trigger, this, 0);
}

void playertrigger(entity this, entity actor, entity trigger)
{
	entity e = this.m_subject;
	if(this.classname == "dummy")
		this.m_subject = this;
		
	Trigger(this, this, trigger, 4);
	if(this.m_subject == this)
		this.m_subject = e;
}

void InitTrigger(entity this)
{
	this.solid = SOLID_TRIGGER;
	_setmodel(this, this.model);	// set size and link into world
	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	this.model = "";
}
