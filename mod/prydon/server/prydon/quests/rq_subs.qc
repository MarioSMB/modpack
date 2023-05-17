#include "rq_subs.qh"

#include "_mod.qh"
#include "../subs/subs.qh"

float rq_templateforquest(vector v)
{
	entity e = rq_getscenario(v);
	if(e)
		return e.m_num;
		
	if(v.x == 1)
		return RQ_ITEMS | MT_BOTH;
	else if(v.x == 2)
		return RQ_RESCUE_NPC | MT_HOSTILE;
	else if(v.x == 3)
		return RQ_RESCUE_NPC | MT_FRIENDLY | RQ_ALT;
	else if(v.x == 4)
		return RQ_MONSTERS | MT_HOSTILE;
	else if(v.x == 5)
		return RQ_ESCORT | MT_FRIENDLY;
	else if(v.x == 6)
		return RQ_PICKUP_NPC | RQ_GIVE_ITEM | MT_FRIENDLY;
	else if(v.x == 7)
		return RQ_ESCORT | RQ_FIGHT | RQ_MONSTERS | MT_HOSTILE;
	else if(v.x == 8)
		return RQ_MONSTERS | MT_HOSTILE;
	else if(v.x == 9)
		return RQ_MONSTERS | RQ_RESCUE_NPC | MT_HOSTILE;
	else if(v.x == 10)
		return RQ_GIVE_NPC | MT_FRIENDLY;
	else if(v.x == 11)
		return RQ_ITEMS | MT_BOTH;
	else if(v.x == 12)
		return RQ_RESCUE_NPC | MT_HOSTILE;
	else if(v.x == 13)
		return RQ_RESCUE_NPC | MT_FRIENDLY | RQ_ALT;
	return 0;
}

vector rq_itemforquest(vector v)
{
	entity e = rq_getscenario(v);
	if(e)
		return e.slot1;
	if(v.x == 1)
		return IV_BOOK;
	else if(v.x == 6)
		return IV_BOOK;
	else if(v.x == 8)
		return IV_BOOK;
	else if(v.x == 10)
		return IV_ELIXIR;
	else if(v.x == 11)
		return IV_3ALES;
	return IV_NULL;
}

float rq_quantityforquest(vector v)
{
	entity e = rq_getscenario(v);
	if(e)
		return e.value;

	return 1;
}

string rq_modelforquest(entity this, vector v)
{
	entity e = rq_getscenario(v);
	if(e)
		if(e.model)
			return e.model;
	if(v.x == 2)
		return "progs/sadoc.mdl";
	else if(v.x == 3)
		return "progs/sadoc.mdl";
	else if(v.x == 6)
		return "progs/sadoc.mdl";
	else if(v.x == 9)
		return "progs/fem.mdl";
	else if(v.x == 10)
		return "progs/sadoc.mdl";
	else if(v.x == 12)
		return "progs/guy.mdl";
	else if(v.x == 13)
		return "progs/guy.mdl";
	else
		return rq_npcmodel(this, v.x & 15);
}

string rq_npcnameforquest(vector v)
{
	entity e = rq_getscenario(v);
	if(e)
		if(e.netname)
			return e.netname;
	if(v.x == 2)
		return "Lost healer";
	else if(v.x == 3)
		return "Healer";
	else if(v.x == 6)
		return "Book Collector";
	else if(v.x == 9)
		return "Kidnapped Daughter";
	else if(v.x == 10)
		return "Alchemist";
	else if(v.x == 12)
		return "Lost Brother";
	else if(v.x == 13)
		return "Blacksmith";
	return
		rq_npcname(v.x & 63);
}

void rq_villantype(entity this, vector v)
{
	if(v.x == 4)
		spawnfunc_monster_evile_wizard(this);
	else if(v.x == 7)
		spawnfunc_monster_evile_wizard(this);
	else if(v.x == 8)
		spawnfunc_monster_evile_wizard(this);
	else if(v.x == 9)
		spawnfunc_monster_hideous_goblin(this);
}

// this ain't gonna work.
spawnfunc(random_quest)
{
	// impulse scenario number
	// target = info_class for monster.
	// m_num - template?
	// netname - name for npc
	// model - model name
	// slot1 - item
	if(this.model)
		precache_model(this.model);
}

void rq_npcsetreward(entity e)
{
	e.action = opendialog;
	vector v = rndquest;
	v.z = 2; // hack city
	rq_chatstrings(e, v);
	e.req_item = rq_itemforquest(rndquest);
	e.message1 = rewardstring(e);
	e.message2 = "You're welcome";
	e.target2 = "rq_reward";
}

entity rq_getscenario(vector v)
{
	entity e = find(NULL, classname, "random_quest");
	
	while(e)
	{
		if(e.impulse == v.x)
			return e;
		e = find(e, classname, "random_quest");
	}
	return NULL;	
}

float rq_objectives()
{
	float tm = rq_templateforquest(rndquest);

	tm &= ~rndquest.z;
	return tm & RQ_OBJECTIVES;

}

void rq_docomplete()
{
	entity e = find(NULL, targetname, "rq_npc");
	while(e)
	{
		if(e.v_angle == rq_vars)
			rq_npcsetreward(e);
		e.ai |= AI_ROAM;
		e.ai &= ~AI_FOLLOW;
		if(e.wad)
			e.ai |= AI_STAY_NEAR;
		e.targetname = string_null;
		e = find(e, targetname, "rq_npc");
	}
}

bool rq_iscomplete()
{
	float tm = rq_templateforquest(rndquest);
	float o = rq_objectives();
	if(tm & RQ_ESCORT)
		if(rndquest_y != world.impulse)
			return false;
	if(rndquest_z == 0)
		return true;
	else if(o)
		return false;
	else if(rq_objquan <= 0)
		return true;

	return false;
}

float rq_destinationtype(vector v)
{
	float f = rq_templateforquest(v);
	return f & 3;
}

float rq_difficulty(vector v)
{
	float f = rq_templateforquest(v);
	int r = 1;
	
	if(f & RQ_RESCUE_NPC)
		r += 2;
	if(f & RQ_ITEMS)
		r += 1;
	if(f & RQ_MONSTERS)
		r += 2;
	if(f & RQ_ESCORT)
		r += 1;
	return r;
	
}

void rq_doaccept(entity snpc, entity splayer)
{
	float tm = rq_templateforquest(rndquest);
	if(tm & RQ_ESCORT)
	{
		snpc.action = donothing;
		snpc.ai = AI_FOLLOW;
	}
	if(tm & RQ_FIGHT)
		snpc.ai = snpc.ai | AI_HUNT_MONSTERS;
	else if(tm & RQ_GIVE_ITEM)
	{
		dropitem(splayer.owner, pickupitem(splayer.owner, rq_itemforquest(rndquest)));
	}
}

void rq_advance(float obj)
{
	rndquest.z |= obj;
	rq_objquan = rq_objquan - 1;
	if(rq_iscomplete())
	{
		rq_docomplete();
		rq_update();
		quest_update();
	}
}

float rq_shouldreward(entity snpc, entity splayer)
{
	// tie up loose ends.
	
	//float tm = rq_templateforquest(rndquest);
	vector itslot = rq_itemforquest(rndquest);
	
	if(itslot)
	{
		if(!takesomething(itslot, splayer.owner))
		{
			return false;
		}
		else
			rq_advance(RQ_PICKUP_NPC);
	}

	if(snpc)
		snpc.killtarget = string_null; // if he dies now, that's his problem.
	return rq_iscomplete();
}

vector rq_generate()
{
	// QUESTS
	vector v = '0 0 0';
	do
	{
		v.x = ceil(random() * MAX_RQ);
	}
	while(rq_templateforquest(v) == 0);
	float fl = rq_destinationtype(v);
	v.y = getrandmap(fl);
	v.z = 1;
	return v;
}

float rq_gps = 1; // avoid division by 0

void rq_goalpoint_spawn(entity this, float q)
{
	float tm = rq_templateforquest(rndquest);
	float o = rq_objectives();
	float n;
	entity e;
	
	if(o & RQ_ITEMS)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while(n > 0)
		{
			e = find_spot(this);
			e.slot1 = rq_itemforquest(rndquest);
			if(stat_loc & STACKABLE)
			{
				e.slot1_z = n;
				n = 0;
			}
			e.movedir = rndquest + '0 0 1';
			spawnfunc_item(e);
			n = n - 1;
		}
	}
	if(o & RQ_RESCUE_NPC)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while(n > 0)
		{
			e = rq_spawnnpc_go(this, false, 2);
			// todo, make this more definable.
			e.target1 = "rq_rescue";
			if(tm & RQ_ALT)
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
	if(o & RQ_MONSTERS)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while(n > 0)
		{
			e = rq_spawnmonster(this);
			e.slot1 = rq_itemforquest(rndquest);
			n = n - 1;
		}
	}

	if(o & RQ_PICKUP_NPC)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while(n > 0)
		{
			e = rq_spawnnpc_go(this, false, 3);
			// bit presumptuios, no?
			rq_npcsetreward(e);
			n = n - 1;
		}
	}
	if(o & RQ_GIVE_NPC)
	{
		n = q;
		rq_objquan = rq_objquan + q;
		while(n > 0)
		{
			e = rq_spawnnpc_go(this, false, 3);
			e.message = "Hello. How can I help you?";
			e.message1 = "I'm here to pickup something\nfor ";
			e.message2 = rq_npcname(rq_vars_z & 63);
			e.target1 = "rq_recieve";
			n = n - 1;
		}
	}
	delete(this);		
}

void rq_goalpoint_random(entity this)
{
	float quantity;
	it_simplestat(this, rq_itemforquest(rndquest));
	it_itemstat(this);
	
	if(stat_loc & STACKABLE)
		quantity = stat_dur;
	else
		quantity = rq_quantityforquest(rndquest);
	int q = ceil(quantity/rq_gps);
	
	while(quantity > 0)
	{
		float f = floor(random() * rq_gps);
		int n = 0;
		entity e = find(NULL, classname, "rq_goalpoint");
		while(e)
		{
			if(e.impulse == f)
			{
				rq_goalpoint_spawn(e, q);
			}
			e.impulse = n;
			n = n + 1;
			e = find(e, classname, "rq_goalpoint");
		}
		rq_gps = n;
		quantity -= q;
	}
}

void rq_goalpoint(entity this)
{
	if(rndquest_y != world.impulse)
	{
		if(rndquest_y != this.impulse && this.impulse)
		{
			delete(this);
			return;
		}
	}
	if(rq_iscomplete())
	{
		delete(this);
		return;
	}
	if(this.team)
	{
		if(!(this.team & rq_destinationtype(rndquest)))
		{
			delete(this);
			return;	
		}
	}
	
	if(rq_modelforquest(this, rndquest) != string_null)
		precache_model(rq_modelforquest(this, rndquest));
	if(cache)
		rq_villantype(this, rndquest);
	
	if(!rq_gps)
	{
		setthink(this, rq_goalpoint_random);
		this.nextthink = time;
	}
	this.impulse = rq_gps;
	rq_gps += 1;
}
