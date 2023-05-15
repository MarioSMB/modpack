void (entity e, vector v) rq_chatstrings =
{
	// initial


	if (v_z == 2)
	{
		if (v_x == 1)
			e.message = rq1_cc;
		else if (v_x == 2)
			e.message = rq2_cc;
		else if (v_x == 3)
			e.message = rq3_cc;
		else if (v_x == 4)
			e.message = rq4_cc;
		else if (v_x == 5)
			e.message = rq5_cc;
		else if (v_x == 6)
			e.message = rq6_cc;
		else if (v_x == 7)
			e.message = rq7_cc;
		else if (v_x == 8)
			e.message = rq8_cc;
		else if (v_x == 9)
			e.message = rq9_cc;
		else if (v_x == 10)
			e.message = rq10_cc;
		else if (v_x == 11)
			e.message = rq11_cc;
		else if (v_x == 12)
			e.message = rq12_cc;
		else if (v_x == 13)
			e.message = rq13_cc;
		else if (v_x == 14)
			e.message = rq14_cc;
	}
	else
	{
		if (v_x == 1)
		{
			e.message = rq1_ca;
			e.message2 = rq1_cb;
		}
		else if (v_x == 2)
		{
			e.message = rq2_ca;
			e.message2 = rq2_cb;
		}
		else if (v_x == 3)
		{
			e.message = rq3_ca;
			e.message2 = rq3_cb;
		}
		else if (v_x == 4)
		{
			e.message = rq4_ca;
			e.message2 = rq4_cb;
		}
		else if (v_x == 5)
		{
			e.message = rq5_ca;
			e.message2 = rq5_cb;
		}
		else if (v_x == 6)
		{
			e.message = rq6_ca;
			e.message2 = rq6_cb;
		}
		else if (v_x == 7)
		{
			e.message = rq7_ca;
			e.message2 = rq7_cb;
		}
		else if (v_x == 8)
		{
			e.message = rq8_ca;
			e.message2 = rq8_cb;
		}
		else if (v_x == 9)
		{
			e.message = rq9_ca;
			e.message2 = rq9_cb;
		}
		else if (v_x == 10)
		{
			e.message = rq10_ca;
			e.message2 = rq10_cb;
		}
		else if (v_x == 11)
		{
			e.message = rq11_ca;
			e.message2 = rq11_cb;
		}
		else if (v_x == 12)
		{
			e.message = rq12_ca;
			e.message2 = rq12_cb;
		}
		else if (v_x == 13)
		{
			e.message = rq13_ca;
			e.message2 = rq13_cb;
		}
		else if (v_x == 14)
		{
			e.message = rq14_ca;
			e.message2 = rq14_cb;
		}
	}
};

string (entity e) rewardstring =
{
	local float r;
	if (!e.m_num)
	{
		
		e.m_num = floor(random() * 6) + 1;
		if (e.m_num > 3)
			e.m_num = 1;

	}
	if (e.m_num == 1)
	{
		r = random();
		
		if (r < 0.1)
			return "Take this gold it\ndoes me no good!";
		else if (r < 0.2)
			return "Have this gold as\na reward.";
		else if (r < 0.3)
			return "Here's some gold\nfor your troubles.";
		else if (r < 0.4)
			return "Take this gold as\na token of my thanks.";
		else if (r < 0.5)
			return "Have this gold as\na thank you.";
		else if (r < 0.6)
			return "Perhaps you could\nuse this gold more than I.";
		else if (r < 0.7)
			return "Take this gold as\npayment for your deeds.";
		else if (r < 0.8)
			return "Here, take this\ngold for your troubles.";
		else if (r < 0.9)
			return "Take this gold as\na token of my gratitude.";
		else
			return "This gold is all\nI can offer in thanks.";
	}
	else if (e.m_num == 2)
	{
		r = random();
		
		if (r < 0.2)
			return "I offer you my\nwisdom as a reward.";
		else if (r < 0.4)
			return "For your reward,\nI shall teach you what I know.";
		else if (r < 0.6)
			return "I can only offer\nwhat I know as reward\n";
		else if (r < 0.8)
			return "I have nothing to\noffer but what I have learned.";
		else 
			return "I will teach you\nwhat I know as my thanks.";
	}
	else if (e.m_num == 3)
	{
		r = random();
		if (r < 0.2)
			return "Take this item\nas payment for a job well done.";
		else if (r < 0.4)
			return "Have this item\nas a token of my gratitude.";
		else if (r < 0.6)
			return "Ths item is all\nI have to show my appeciation.";
		else if (r < 0.8)
			return "Here, take this\nitem for you troubles.";
		else
			return "Perhaps you could\nuse this item more than I.";	
	}
};

void(entity e) rq_updatedialog =
{
	local float r;
	e.target1 = string_null;
	e.target2 = string_null;
	e.target3 = string_null;
	e.target4 = string_null;
	
	e.message1 = string_null;
	e.message2 = string_null;
	e.message3 = string_null;
	e.message4 = string_null;
	if (rq_vars == e.v_angle)
	{
		if (rq_iscomplete())
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
	else if (rndquest_z == 0)
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
		r = random();
		if (r < 0.1)
			e.message = "You appear to be too busy\nto talk with me.";
		else if (r < 0.2)
			e.message = "You look busy. Talk with me\nlater.";
		else if (r < 0.3)
			e.message = "You're a great adventurer\nI may need you later.";
		else if (r < 0.4)
			e.message = "I may need a great adventurer\nlike you later.";
		else if (r < 0.5)
			e.message = "I need something done, but\nyou appear too busy.";
		else if (r < 0.6)
			e.message = "I need help with a task\nbut finish your other duties first.";
		else if (r < 0.7)
			e.message = "I require an adenturer\nbut I see you're already busy.";
		else if (r < 0.8)
			e.message = "I need your help, come back\nwhen you're free.";
		else if (r < 0.9)
			e.message = "I need someone to help me but\nyou have other duties to attend to.";
		else
			e.message = "You're too busy to take up\nthe job I need done. Come back later.";
		return;
	}
};


void () rq_update =
{
	local entity e;
	
	e = find(world, classname, "npc");
	while (e)
	{
		if (e.movedir)
			rq_updatedialog(e);
		e = find(e, classname, "npc");
	}
};
void(entity e) rq_accept =
{
	rq_vars = e.v_angle;
	rndquest = e.movedir;
	
	quest_update();
	rq_update();
	rq_doaccept(e, e.m_subject);
	closemenu(e.m_subject.owner);
	
};
void() rq_cancel =
{
	//quest_update();
	if (!rndquest)
		return; // already failed?
	if (activator)
		closemenu(activator.m_subject.owner);
	bprint("You have failed to help ");
	bprint(rq_npcname(rq_vars_z & 63));
	bprint("\n");
	rq_vars = '0 0 0';
	rndquest = '0 0 0';

	rq_update();
};
void(entity e) rq_recieve =
{
	local entity oself;
	if (!rndquest)
		return; // already failed?
	rq_advance(RQ_GIVE_NPC);
	oself = self;
	if (activator)
		closemenu(activator.m_subject.owner);
	activator.message = "Is there anything else?";
	activator.message1 = "No";
	activator.message2 = string_null;
	activator.target1 = "m_exit";
	
	self = e.owner;
	sound(self.m_subject, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
	dropitem(pickupitem(rq_itemforquest(rndquest)));
	self = oself;
	
};
void(entity e) rq_rescue =
{
local float tm;


	if (!rndquest)
		return; // already failed?
		
	rq_advance(RQ_RESCUE_NPC);
tm=rq_templateforquest(rndquest);

	e.ai = AI_FOLLOW;
	if (tm & RQ_FIGHT)
		e.ai = e.ai | AI_HUNT_MONSTERS;

	e.action = donothing;

	closemenu(e.m_subject.owner);
};


void() rq_mondie =
{

	if (!rndquest)
		return; // already failed?
	
	rq_advance(RQ_MONSTERS);
};

void(entity e) rq_reward =
{

	local float difficulty, r;
	
	local entity oself, t;
	
	if (rq_shouldreward(activator, activator.m_subject))
	{
		rq_docomplete();
		closemenu(activator.m_subject.owner);
		if (world.impulse == rndquest_y)
			difficulty = getmapdiff(rq_vars_y);
		else
			difficulty = getmapdiff(rndquest_y) * 2;
		difficulty = (difficulty + rq_difficulty(rndquest)) * monsvalue;
		
		if (activator.m_num == 1) // gold
		{
			oself = self;
			t = find(world, classname, "player");
			while(t)
			{
				self = t;
				if (t.player)
					givegold(ceil(difficulty/numplayers/5));
				t = find(t, classname, "player");
			}
			self = oself;
		}
		else if (activator.m_num == 2)
		{
			oself = self;
	
			t = find(world, classname, "player");
			while(t)
			{
				self = t;
				if (t.player)
					r = GiveExp(t, activator, ceil(difficulty/numplayers));

				t = find(t, classname, "player");
			}
			self = oself;
		}
		else if (activator.m_num == 3)
		{
			oself = self;
			self = activator;
			for(r = 0; r < numplayers; r = r + 1)
				dropitem(randitem(0, itemvalue + difficulty, FALSE));
			self = oself;
		}
		activator.movedir = '0 0 0';
		activator.req_item = IV_NULL;
		activator.message1 = string_null;
		activator.message2 = string_null;
		activator.target2 = string_null;
		rq_vars = '0 0 0';
		rndquest = '0 0 0';
		rq_update();
	}
};

void() rq_createdialog =
{
	local vector v;
	
	v = rq_generate();
	if (rndquest)
	{
		if (rq_vars_y == world.impulse)
			if (rq_vars_z  == rq_npcs)
				v = rndquest;
	}	
	self.movedir = v;	
	rq_updatedialog(self);
	self.think = AnimatePlayer;
	self.nextthink = time;
	
};

