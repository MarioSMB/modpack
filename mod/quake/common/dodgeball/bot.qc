#include "bot.qh"

#include "dodgeball.qh"

#ifdef SVQC
bool CheckForGap(entity this)
{
	vector dir, src;
	
	dir = vectoangles(this.velocity);
	dir_x = 0;
	makevectors (dir);
	
	src = this.origin + v_forward*60;
	traceline (src, src - '0 0 10000', true, this);
	if(pointcontents(trace_endpos + '0 0 1') <= CONTENT_SLIME)
		return true;
	
	return false;
}

void BotStrafe(entity this)
{
	if(this.fb_time < time)
	{
		if(this.move_mode == 0)
			this.move_mode = 1;
		else
			this.move_mode = 0;
		this.fb_time = time + 1 + random();
	}
	
	if(this.move_mode == 0)
	{
		if(this.strafe_time < time)
		{
			if(this.movement == '0 320 0')
				this.movement = '0 -320 0';
			else
				this.movement = '0 320 0';
			this.strafe_time = time + 0.5 + 0.6*random();
		}
	}
	else
	{
		if(this.strafe_time < time)
		{
			if(this.movement == '320 0 0')
				this.movement = '-320 0 0';
			else
				this.movement = '320 0 0';
			this.strafe_time = time + 0.5 + 0.6*random();
		}
	}
	
	if(CheckForGap(this))
	{
		if(this.move_mode == 0)
		{
			if(this.movement == '0 320 0')
				this.movement = '0 -320 0';
			else
				this.movement = '0 320 0';
		}
		else
		{
			if(this.movement == '320 0 0')
				this.movement = '-320 0 0';
			else
				this.movement = '320 0 0';
		}
	}
}


void BotFindTarget(entity this)
{
	RandomSelection_Init();

	FOREACH_ENTITY_RADIUS(this.origin, 10000, it != this,
	{
		if(it.health > 0 && it.team_no != this.team_no && !it.died && visible(this, it))
			RandomSelection_AddEnt(it, 1, 1);
	});
	
	this.enemy = RandomSelection_chosen_ent;
}

bool type_check(entity ent)
{
	if(STAT(SPECIAL, ent) && ent.solid == SOLID_TRIGGER)
		return true;
	if(!STAT(SPECIAL, ent))
		return true;
	
	return false;
}

void BotFindBall(entity this)
{
	entity targ = find(NULL, classname, "dodgeball");
	while(targ)
	{
		if(visible(this, targ))
		if(targ.search_time < time && targ.velocity == '0 0 0')
		if(type_check(targ))
		{
			float dist;
			float ofs;
			if(targ.velocity != '0 0 0')
			{
				dist = 100;
				ofs = 9999;
			}
			else
			{
				dist = 1000;
				ofs = 22;
			}
			
			if(vdist(targ.origin - this.origin, <, dist) && targ.origin_z < this.origin_z + ofs)
			{
				this.goalentity = targ;
				this.search_time = time + 2;
			}
		}
		targ = find(targ, classname, "dodgeball");
	}
}

void bot_face(entity this, entity ent)
{
	vector dir, vel;
	
	if(STAT(HAS_BALL, this))
	{
		vel = ent.velocity;
		if(ent.velocity_z > 0)
			vel_z = 0;
		dir = ent.origin + vel * (random()*0.4);
	}
	else
		dir = ent.origin;
	dir = normalize(dir - this.origin);
	
	this.v_angle = vectoangles(dir);
	this.v_angle_x = this.v_angle_x * -1;
	while(this.v_angle_x < -180)
		this.v_angle_x = this.v_angle_x + 360;
	while(this.v_angle_x > 180)
		this.v_angle_x = this.v_angle_x - 360;
}

void BotAI(entity this)
{
	if(this.health < 1)
	{
		this.button0 = rint(random()*2);
		this.button1 = 0;
		this.button2 = 0;
		return;
	}
	
	if(STAT(FROZEN, this) > time)
	{
		this.movement = '0 0 0';
		return;	// hack!
	}
	
	if(!this.enemy)
	{
		this.button0 = 0;
		this.v_angle_x = 0;
		
		if(!dodgeball_Sprinting(this))
			this.button5 = 1;
		
		if(this.died)
		{
			this.movement = '0 0 0';
			return;
		}
		
		if(STAT(HAS_BALL, this))
			BotFindTarget(this);
		else
			BotFindBall(this);
		
		if(this.search_time < time)
		{
			if(this.goalentity && !STAT(SPECIAL, this.goalentity))
				this.goalentity.search_time = time + 7;
			this.goalentity = NULL;
		}
		
		if(this.goalentity)
		{
			if(CheckForGap(this))
			{
				this.goalentity.search_time = time + 5;
				this.goalentity = NULL;
				return;
			}
			
			bot_face(this, this.goalentity);
			this.movement = '320 0 0';
			if(random() <= 0.02)
				this.button1 = 1;
		}
		else
			BotStrafe(this);
	}
	
	if(this.enemy)
	{
		if(this.enemy.health <= 0 || !visible(this, this.enemy) || !STAT(HAS_BALL, this))
		{
			this.enemy = NULL;
			return;
		}
		
		if(STAT(STAMINA, this) > 5 && !dodgeball_Sprinting(this))
			this.button5 = 1;
		
		bot_face(this, this.enemy);
		BotStrafe(this);
		if(!countdown && !ceasefire && random() < 0.1)
		{
			if(random() < 0.5)
				this.button3 = 1;
			else
				ThrowBall(this);
		}
	}
}

void BotCheckTeams()
{
	int team1_players = 0, team1_bots = 0;
	int team2_players = 0, team2_bots = 0;
	int total_players = 0;
	FOREACH_CLIENT(true,
	{
		total_players += 1;
		if(!IS_PLAYER(it))
			continue;
		if(it.team_no == 1)
			team1_players += 1;
		else if(it.team_no == 2)
			team2_players += 1;
		if(IS_BOT_CLIENT(it))
		{
			if(it.team_no == 1)
				team1_bots += 1;
			else if(it.team_no == 2)
				team2_bots += 1;
		}
	});

	int bots_perteam = autocvar_sv_quake_dodgeball_bots_perteam;

	while(team1_players < bots_perteam && total_players < maxclients)
	{
		if(!SpawnBot(1))
			break;
		team1_players += 1;
		team1_bots += 1;
	}
	while(team2_players < bots_perteam && total_players < maxclients)
	{
		if(!SpawnBot(2))
			break;
		team2_players += 1;
		team2_bots += 2;
	}

	while(team1_players > bots_perteam && team1_bots > 0)
	{
		team1_players -= 1;
		team1_bots -= 1;
		DropBot(1);
	}
	while(team2_players > bots_perteam && team2_bots > 0)
	{
		team2_players -= 1;
		team2_bots -= 1;
		DropBot(2);
	}
}

void BotFrame()
{
	if (intermission_running)
	{
		// after the end of the match all bots stay unless all human players disconnect
		int realplayers = 0;
		FOREACH_CLIENT(IS_REAL_CLIENT(it), { ++realplayers; });
		if (!realplayers)
		{
			FOREACH_CLIENT(IS_BOT_CLIENT(it), { dropclient(it); });
		}
		return;
	}

	if(db_init_delay && time < db_init_delay)
		return;

	BotCheckTeams();

	FOREACH_CLIENT(IS_PLAYER(it) && clienttype(it) == CLIENTTYPE_BOT,
	{
		SV_PlayerPhysics(it);
		BotAI(it);
	});
}

void BotSetName(entity this)
{
	RandomSelection_Init();
	RandomSelection_AddString("Mary", 1, 1);
	RandomSelection_AddString("Anna", 1, 1);
	RandomSelection_AddString("Emma", 1, 1);
	RandomSelection_AddString("Elizabeth", 1, 1);
	RandomSelection_AddString("Minnie", 1, 1);
	RandomSelection_AddString("Margaret", 1, 1);
	RandomSelection_AddString("Ida", 1, 1);
	RandomSelection_AddString("Alice", 1, 1);
	RandomSelection_AddString("Bertha", 1, 1);
	RandomSelection_AddString("Sarah", 1, 1);
	RandomSelection_AddString("John", 1, 1);
	RandomSelection_AddString("William", 1, 1);
	RandomSelection_AddString("James", 1, 1);
	RandomSelection_AddString("Charles", 1, 1);
	RandomSelection_AddString("George", 1, 1);
	RandomSelection_AddString("Frank", 1, 1);
	RandomSelection_AddString("Joseph", 1, 1);
	RandomSelection_AddString("Thomas", 1, 1);
	RandomSelection_AddString("Henry", 1, 1);
	RandomSelection_AddString("Robert", 1, 1);
	RandomSelection_AddString("Annie", 1, 1);

	this.netname = RandomSelection_chosen_string;
}

bool SpawnBot(int tno) 
{
	entity bot = spawnclient();
	if(!bot)
	{
		bprint("Can not add bot, server full\n");
		return false;
	}
	BotSetName(bot);
	if(tno == 1)
		bot.clientcolors = 6 * 16 + 6;
	else if(tno == 2)
		bot.clientcolors = 11 * 16 + 11;
	ClientConnect(bot);
	PutClientInServer(bot);
	return true;
}

void DropBot(int tno)
{
	FOREACH_CLIENT(IS_PLAYER(it) && IS_BOT_CLIENT(it),
	{
		if(it.team_no == tno)
		{
			dropclient(it);
			break;
		}
	});
}
#endif
#endif
