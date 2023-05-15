


entity(float spawnpoint, float type) rq_spawnnpc_go;
string (float n) rq_npcmodel;
entity() rq_spawnmonster;
void (entity e, vector v) rq_chatstrings;
string (entity e) rewardstring;
void() rq_createdialog;
string (float f) rq_npcname;
entity (vector v) rq_getscenario;
void() rq_update;
void() opendialog;

float (vector v) rq_templateforquest =
{
	local entity e;
	e = rq_getscenario(v);
	if (e)
		return e.m_num;
		
	if (v_x == 1)
		return RQ_ITEMS | MT_BOTH;
	else if (v_x == 2)
		return RQ_RESCUE_NPC | MT_HOSTILE;
	else if (v_x == 3)
		return RQ_RESCUE_NPC | MT_FRIENDLY | RQ_ALT;
	else if (v_x == 4)
		return RQ_MONSTERS | MT_HOSTILE;
	else if (v_x == 5)
		return RQ_ESCORT | MT_FRIENDLY;
	else if (v_x == 6)
		return RQ_PICKUP_NPC | RQ_GIVE_ITEM | MT_FRIENDLY;
	else if (v_x == 7)
		return RQ_ESCORT | RQ_FIGHT | RQ_MONSTERS | MT_HOSTILE;
	else if (v_x == 8)
		return RQ_MONSTERS | MT_HOSTILE;
	else if (v_x == 9)
		return RQ_MONSTERS | RQ_RESCUE_NPC | MT_HOSTILE;
	else if (v_x == 10)
		return RQ_GIVE_NPC | MT_FRIENDLY;
	else if (v_x == 11)
		return RQ_ITEMS | MT_BOTH;
	else if (v_x == 12)
		return RQ_RESCUE_NPC | MT_HOSTILE;
	else if (v_x == 13)
		return RQ_RESCUE_NPC | MT_FRIENDLY | RQ_ALT;
};

vector (vector v) rq_itemforquest =
{
	local entity e;
	e = rq_getscenario(v);
	if (e)
		return e.slot1;
	if (v_x == 1)
		return IV_BOOK;
	else if (v_x == 6)
		return IV_BOOK;
	else if (v_x == 8)
		return IV_BOOK;
	else if (v_x == 10)
		return IV_ELIXIR;
	else if (v_x == 11)
		return IV_3ALES;
	return IV_NULL;
};

float(vector v) rq_quantityforquest =
{
	local entity e;
	e = rq_getscenario(v);
	if (e)
		return e.value;

	return 1;
};

string (vector v) rq_modelforquest =
{
	local float tm;
	local entity e;
	e = rq_getscenario(v);
	if (e)
		if (e.model)
			return e.model;
	if (v_x == 2)
		return "progs/sadoc.mdl";
	else if (v_x == 3)
		return "progs/sadoc.mdl";
	else if (v_x == 6)
		return "progs/sadoc.mdl";
	else if (v_x == 9)
		return "progs/fem.mdl";
	else if (v_x == 10)
		return "progs/sadoc.mdl";
	else if (v_x == 12)
		return "progs/guy.mdl";
	else if (v_x == 13)
		return "progs/guy.mdl";
	else
	{
		return rq_npcmodel(v_x & 15);
	}
};
string (vector v) rq_npcnameforquest =
{
	local entity e;
	e = rq_getscenario(v);
	if (e)
		if (e.netname)
			return e.netname;
	if (v_x == 2)
		return "Lost healer";
	else if (v_x == 3)
		return "Healer";
	else if (v_x == 6)
		return "Book Collector";
	else if (v_x == 9)
		return "Kidnapped Daughter";
	else if (v_x == 10)
		return "Alchemist";
	else if (v_x == 12)
		return "Lost Brother";
	else if (v_x == 13)
		return "Blacksmith";
	return rq_npcname(v_x & 63);
};

void() monster_hideous_goblin;
void() monster_evile_wizard;

void (vector v) rq_villantype =
{
	if (v_x == 4)
		monster_evile_wizard();
	else if (v_x == 7)
		monster_evile_wizard();
	else if (v_x == 8)
		monster_evile_wizard();
	else if (v_x == 9)
		monster_hideous_goblin();
};


// this ain't gonna work.
void() random_quest =
{
	// impulse scenario number
	// target = info_class for monster.
	// m_num - template?
	// netname - name for npc
	// model - model name
	// slot1 - item
	if (self.model)
		precache_model(self.model);
};
void(entity e) rq_npcsetreward =
{
	local vector v;
	e.action = opendialog;
	v = rndquest;
	v_z = 2; // hack city
	rq_chatstrings(e, v);
	e.req_item = rq_itemforquest(rndquest);
	e.message1 = rewardstring(e);
	e.message2 = "You're welcome";
	e.target2 = "rq_reward";
}
entity (vector v) rq_getscenario =
{
	local entity e;
	
	e = find(world, classname, "random_quest");
	
	while (e)
	{
		if (e.impulse == v_x)
			return e;
		e = find(e, classname, "random_quest");
	}
	return world;	
};
float () rq_objectives =
{
	float r, tm;
	r = 1;
	tm = rq_templateforquest(rndquest);
	

	return (tm - (tm & rndquest_z)) & RQ_OBJECTIVES;

};
void() rq_docomplete =
{
	local entity e;
	e = find(world, targetname, "rq_npc");
	while(e)
	{
		if (e.v_angle == rq_vars)
			rq_npcsetreward(e);
		e.ai = (e.ai - (e.ai & AI_FOLLOW)) | AI_ROAM;
		if (e.wad)
			e.ai = e.ai | AI_STAY_NEAR;
		e.targetname = string_null;
		e = find(e, targetname, "rq_npc");
	}
}
float() rq_iscomplete =
{
	local float tm, o;
	tm = rq_templateforquest(rndquest);
	o = rq_objectives();
	if (tm & RQ_ESCORT)
		if (rndquest_y != world.impulse)
			return FALSE;
	if (rndquest_z == 0)
		return TRUE;
	else if (o)
		return FALSE;
	else if (rq_objquan <= 0)
	{
		return TRUE;
	}
	return FALSE;
};

float (vector v) rq_destinationtype =
{
	local float f;
	
	f = rq_templateforquest(v);
	return f & 3;
};

float (vector v) rq_difficulty =
{
	local float f, r;
	
	f = rq_templateforquest(v);
	
	r = 1;
	
	if (f & RQ_RESCUE_NPC)
		r = r + 2;
	if (f & RQ_ITEMS)
		r = r + 1;
	if (f & RQ_MONSTERS)
		r = r + 2;
	if (f & RQ_ESCORT)
		r = r + 1;
	return r;
	
};
void(entity snpc, entity splayer) rq_doaccept =
{
	local float tm;
	local entity oself;
	oself = self;
	
	tm = rq_templateforquest(rndquest);
	if (tm & RQ_ESCORT)
	{
		snpc.action = donothing;
		snpc.ai = AI_FOLLOW;
	}
	if (tm & RQ_FIGHT)
		snpc.ai = snpc.ai | AI_HUNT_MONSTERS;
	else if (tm & RQ_GIVE_ITEM)
	{
		self = splayer.owner;
		dropitem(pickupitem(rq_itemforquest(rndquest)));
		self = oself;
	}
};

void(float obj) rq_advance =
{
	rndquest_z = rndquest_z | obj;
	rq_objquan = rq_objquan - 1;
	if (rq_iscomplete())
	{
		rq_docomplete();
		rq_update();
		quest_update();
	}
};


float(entity snpc, entity splayer) rq_shouldreward =
{
	local float tm;
	local vector it;
	
	// tie up loose ends.
	
	tm = rq_templateforquest(rndquest);
	it = rq_itemforquest(rndquest);
	
	if (it)
	{
		if (!takesomething(it, splayer.owner))
		{
			return FALSE;
		}
		else
			rq_advance(RQ_PICKUP_NPC);
	}

	if (snpc)
		snpc.killtarget = string_null; // if he dies now, that's his problem.
	return rq_iscomplete();
};


vector() rq_generate =
{
	local vector v;
	local float fl;
	// QUESTS
	do
	{
		v_x = ceil(random() * MAX_RQ);
	}
	while (rq_templateforquest(v) == 0);
	fl = rq_destinationtype(v);
	v_y = getrandmap(fl);
	v_z = 1;
	return v;
};



nosave var float rq_gps;

void(float q) rq_goalpoint_spawn =
{
	local float tm, o, n;
	local entity e;
	
	tm = rq_templateforquest(rndquest);
	o = rq_objectives();
	
	if (o & RQ_ITEMS)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while(n > 0)
		{
			e = find_spot();
			e.slot1 = rq_itemforquest(rndquest);
			if (stat_loc & STACKABLE)
			{
				e.slot1_z = n;
				n = 0;
			}
			e.movedir = rndquest + '0 0 1';
			call(item, e);
			n = n - 1;
		}
	}
	if (o & RQ_RESCUE_NPC)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while (n > 0)
		{
			e = rq_spawnnpc_go(FALSE, 2);
			// todo, make this more definable.
			e.target1 = "rq_rescue";
			if (tm & RQ_ALT)
			{
				e.message = "Hello. How can I help you?";
				e.message1 = "Come with me, you are needed\nin ";
				e.message2 = getmapname(rq_vars_y);
			}
			else
			{
				e.message = "Thank you for rescuing me!\nPlease take me home!";
				e.message1 = "Okay";
	
			}
			n = n - 1;
		}
	}
	if (o & RQ_MONSTERS)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while (n > 0)
		{
			e = rq_spawnmonster();
			e.slot1 = rq_itemforquest(rndquest);
			n = n - 1;
		}
	}

	if (o & RQ_PICKUP_NPC)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while (n > 0)
		{
			e = rq_spawnnpc_go(FALSE, 3);
			// bit presumptuios, no?
			rq_npcsetreward(e);
			n = n - 1;
		}
	}
	if (o & RQ_GIVE_NPC)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while (n > 0)
		{
			e = rq_spawnnpc_go(FALSE, 3);
			e.message = "Hello. How can I help you?";
			e.message1 = "I'm here to pickup something\nfor ";
			e.message2 = rq_npcname(rq_vars_z & 63);
			e.target1 = "rq_recieve";
			n = n - 1;
		}
	}
	remove(self);		
};

void() rq_goalpoint_random =
{
	local float f, quantity, q, n;
	local entity e, oself;
	oself = self;
	it_simplestat(rq_itemforquest(rndquest));
	it_itemstat();
	
	if (stat_loc & STACKABLE)
		quantity = stat_dur;
	else
		quantity = rq_quantityforquest(rndquest);
	q = ceil(quantity/rq_gps);
	
	while(quantity > 0)
	{
		f = floor(random() * rq_gps);
		n = 0;
		e = find(world, classname, "rq_goalpoint");
		while (e)
		{
			if (e.impulse == f)
			{
				self = e;
				rq_goalpoint_spawn(q);
				self = oself;
			}
			e.impulse = n;
			n = n + 1;
			e = find(e, classname, "rq_goalpoint");
		}
		rq_gps = n;
		quantity = quantity - q;
	}
	self = oself;
};

void() rq_goalpoint =
{
	if (rndquest_y != world.impulse)
	{
		if (rndquest_y != self.impulse && self.impulse)
		{
			remove(self);
			return;
		}
	}
	if (rq_iscomplete())
	{
		remove(self);
		return;
	}
	if (self.team)
	{
		if (!(self.team & rq_destinationtype(rndquest)))
		{
			remove(self);
			return;	
		}
	}
	
	if (rq_modelforquest(rndquest) != string_null)
		precache_model(rq_modelforquest(rndquest));
	if (cache)
		rq_villantype(rndquest);
	
	if (!rq_gps)
	{
		self.think = rq_goalpoint_random;
		self.nextthink = time;
	}
	self.impulse = rq_gps;
	rq_gps = rq_gps + 1;

};
