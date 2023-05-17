#include "rq_dialog.qh"

#include "_mod.qh"
#include "../stats/exp.qh"

void rq_chatstrings(entity e, vector v)
{
	// initial

	if(v.z == 2)
	{
		if(v.x == 1)
			e.message = rq1_cc;
		else if(v.x == 2)
			e.message = rq2_cc;
		else if(v.x == 3)
			e.message = rq3_cc;
		else if(v.x == 4)
			e.message = rq4_cc;
		else if(v.x == 5)
			e.message = rq5_cc;
		else if(v.x == 6)
			e.message = rq6_cc;
		else if(v.x == 7)
			e.message = rq7_cc;
		else if(v.x == 8)
			e.message = rq8_cc;
		else if(v.x == 9)
			e.message = rq9_cc;
		else if(v.x == 10)
			e.message = rq10_cc;
		else if(v.x == 11)
			e.message = rq11_cc;
		else if(v.x == 12)
			e.message = rq12_cc;
		else if(v.x == 13)
			e.message = rq13_cc;
		else if(v.x == 14)
			e.message = rq14_cc;
	}
	else
	{
		if(v.x == 1)
		{
			e.message = rq1_ca;
			e.message2 = rq1_cb;
		}
		else if(v.x == 2)
		{
			e.message = rq2_ca;
			e.message2 = rq2_cb;
		}
		else if(v.x == 3)
		{
			e.message = rq3_ca;
			e.message2 = rq3_cb;
		}
		else if(v.x == 4)
		{
			e.message = rq4_ca;
			e.message2 = rq4_cb;
		}
		else if(v.x == 5)
		{
			e.message = rq5_ca;
			e.message2 = rq5_cb;
		}
		else if(v.x == 6)
		{
			e.message = rq6_ca;
			e.message2 = rq6_cb;
		}
		else if(v.x == 7)
		{
			e.message = rq7_ca;
			e.message2 = rq7_cb;
		}
		else if(v.x == 8)
		{
			e.message = rq8_ca;
			e.message2 = rq8_cb;
		}
		else if(v.x == 9)
		{
			e.message = rq9_ca;
			e.message2 = rq9_cb;
		}
		else if(v.x == 10)
		{
			e.message = rq10_ca;
			e.message2 = rq10_cb;
		}
		else if(v.x == 11)
		{
			e.message = rq11_ca;
			e.message2 = rq11_cb;
		}
		else if(v.x == 12)
		{
			e.message = rq12_ca;
			e.message2 = rq12_cb;
		}
		else if(v.x == 13)
		{
			e.message = rq13_ca;
			e.message2 = rq13_cb;
		}
		else if(v.x == 14)
		{
			e.message = rq14_ca;
			e.message2 = rq14_cb;
		}
	}
}

string rewardstring(entity e)
{
	float r;
	if(!e.m_num)
	{
		
		e.m_num = floor(random() * 6) + 1;
		if(e.m_num > 3)
			e.m_num = 1;

	}
	if(e.m_num == 1)
	{
		r = random();
		
		if(r < 0.1)
			return "Take this gold it\ndoes me no good!";
		else if(r < 0.2)
			return "Have this gold as\na reward.";
		else if(r < 0.3)
			return "Here's some gold\nfor your troubles.";
		else if(r < 0.4)
			return "Take this gold as\na token of my thanks.";
		else if(r < 0.5)
			return "Have this gold as\na thank you.";
		else if(r < 0.6)
			return "Perhaps you could\nuse this gold more than I.";
		else if(r < 0.7)
			return "Take this gold as\npayment for your deeds.";
		else if(r < 0.8)
			return "Here, take this\ngold for your troubles.";
		else if(r < 0.9)
			return "Take this gold as\na token of my gratitude.";
		else
			return "This gold is all\nI can offer in thanks.";
	}
	else if(e.m_num == 2)
	{
		r = random();
		
		if(r < 0.2)
			return "I offer you my\nwisdom as a reward.";
		else if(r < 0.4)
			return "For your reward,\nI shall teach you what I know.";
		else if(r < 0.6)
			return "I can only offer\nwhat I know as reward\n";
		else if(r < 0.8)
			return "I have nothing to\noffer but what I have learned.";
		else 
			return "I will teach you\nwhat I know as my thanks.";
	}
	else if(e.m_num == 3)
	{
		r = random();
		if(r < 0.2)
			return "Take this item\nas payment for a job well done.";
		else if(r < 0.4)
			return "Have this item\nas a token of my gratitude.";
		else if(r < 0.6)
			return "Ths item is all\nI have to show my appeciation.";
		else if(r < 0.8)
			return "Here, take this\nitem for you troubles.";
		else
			return "Perhaps you could\nuse this item more than I.";	
	}
	return "";
}

void rq_updatedialog(entity e)
{
	e.target1 = string_null;
	e.target2 = string_null;
	e.target3 = string_null;
	e.target4 = string_null;
	
	e.message1 = string_null;
	e.message2 = string_null;
	e.message3 = string_null;
	e.message4 = string_null;
	if(rq_vars == e.v_angle)
	{
		if(rq_iscomplete())
		{
			rq_npcsetreward(e);
			return;
		}
		else
		{
			e.message = "Have you done the task that\nI requested yet?";
			e.message1 = "Cancel Quest";
			e.target1 = "rq_cancel";
			return;
		}

	}
	else if(rndquest_z == 0)
	{
		rq_chatstrings(e, e.movedir);
		e.message1 = getmapname(e.movedir_y);
		e.message3 = "Accept ";
		e.message4 = "Decline";
		e.target3 = "rq_accept";
		e.target4 = "m_exit";
	}
	else
	{
		float r = random();
		if(r < 0.1)
			e.message = "You appear to be too busy\nto talk with me.";
		else if(r < 0.2)
			e.message = "You look busy. Talk with me\nlater.";
		else if(r < 0.3)
			e.message = "You're a great adventurer\nI may need you later.";
		else if(r < 0.4)
			e.message = "I may need a great adventurer\nlike you later.";
		else if(r < 0.5)
			e.message = "I need something done, but\nyou appear too busy.";
		else if(r < 0.6)
			e.message = "I need help with a task\nbut finish your other duties first.";
		else if(r < 0.7)
			e.message = "I require an adenturer\nbut I see you're already busy.";
		else if(r < 0.8)
			e.message = "I need your help, come back\nwhen you're free.";
		else if(r < 0.9)
			e.message = "I need someone to help me but\nyou have other duties to attend to.";
		else
			e.message = "You're too busy to take up\nthe job I need done. Come back later.";
		return;
	}
}

void rq_update()
{
	FOREACH_ENTITY_CLASS("npc", it.movedir,
	{
		rq_updatedialog(it);
	});
}

void rq_accept(entity e)
{
	rq_vars = e.v_angle;
	rndquest = e.movedir;
	
	quest_update();
	rq_update();
	rq_doaccept(e, e.m_subject);
	closemenu(e.m_subject.owner);
}

void rq_cancel(entity actor)
{
	//quest_update();
	if(!rndquest)
		return; // already failed?
	if(actor)
		closemenu(actor.m_subject.owner);
	bprint("You have failed to help ");
	bprint(rq_npcname(rq_vars_z & 63));
	bprint("\n");
	rq_vars = '0 0 0';
	rndquest = '0 0 0';

	rq_update();
}

void rq_recieve(entity e, entity actor)
{
	if(!rndquest)
		return; // already failed?
	rq_advance(RQ_GIVE_NPC);
	if(actor)
		closemenu(actor.m_subject.owner);
	actor.message = "Is there anything else?";
	actor.message1 = "No";
	actor.message2 = string_null;
	actor.target1 = "m_exit";

	_sound(e.owner.m_subject, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
	dropitem(e.owner, pickupitem(e.owner, rq_itemforquest(rndquest)));
}

void rq_rescue(entity e)
{
	if(!rndquest)
		return; // already failed?
		
	rq_advance(RQ_RESCUE_NPC);
	float tm = rq_templateforquest(rndquest);

	e.ai = AI_FOLLOW;
	if(tm & RQ_FIGHT)
		e.ai |= AI_HUNT_MONSTERS;

	e.action = donothing;

	closemenu(e.m_subject.owner);
}

void rq_mondie(entity e)
{
	if(!rndquest)
		return; // already failed?
	
	rq_advance(RQ_MONSTERS);
}

void rq_reward(entity e, entity actor)
{
	if(rq_shouldreward(actor, actor.m_subject))
	{
		float difficulty;
		entity t;
		rq_docomplete();
		closemenu(actor.m_subject.owner);
		if(world.impulse == rndquest_y)
			difficulty = getmapdiff(rq_vars_y);
		else
			difficulty = getmapdiff(rndquest_y) * 2;
		difficulty = (difficulty + rq_difficulty(rndquest)) * monsvalue;
		
		if(actor.m_num == 1) // gold
		{
			t = find(NULL, classname, "player");
			while(t)
			{
				if(t.player)
					givegold(t, ceil(difficulty/numplayers/5));
				t = find(t, classname, "player");
			}
		}
		else if(actor.m_num == 2)
		{
			t = find(NULL, classname, "player");
			while(t)
			{
				if(t.player)
					GiveExp(t, actor, ceil(difficulty/numplayers));

				t = find(t, classname, "player");
			}
		}
		else if(actor.m_num == 3)
		{
			for(int j = 0; j < numplayers; j += 1)
				dropitem(actor, randitem(actor, 0, itemvalue + difficulty, false));
		}
		actor.movedir = '0 0 0';
		actor.req_item = IV_NULL;
		actor.message1 = string_null;
		actor.message2 = string_null;
		actor.target2 = string_null;
		rq_vars = '0 0 0';
		rndquest = '0 0 0';
		rq_update();
	}
}

void rq_createdialog(entity this)
{
	vector v = rq_generate();
	if(rndquest)
	{
		if(rq_vars_y == world.impulse)
			if(rq_vars_z  == rq_npcs)
				v = rndquest;
	}	
	this.movedir = v;	
	rq_updatedialog(this);
	setthink(this, AnimatePlayer);
	this.nextthink = time;
	
}
