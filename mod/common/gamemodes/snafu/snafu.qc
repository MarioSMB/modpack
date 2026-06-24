//FEATURE: SNAFU gamemode... needs no explanation

#ifndef IMPLEMENTATION
#ifdef SVQC
AUTOCVAR_NOREF(g_snafu, bool, false, "SNAFU: I don't even know");
#endif
#include "snafu.qh"
#ifdef GAMEQC
MODEL(SNAFU_TADPOLE, "models/snafu/tadpole.dpm");

SOUND(SNAFU_ZOMBIE_ATTACK1, "snafu/zombie/attack1");
SOUND(SNAFU_ZOMBIE_ATTACK2, "snafu/zombie/attack2");
SOUND(SNAFU_ZOMBIE_ATTACK3, "snafu/zombie/attack3");
SOUND(SNAFU_ZOMBIE_ATTACK4, "snafu/zombie/attack3");
SOUND(SNAFU_ZOMBIE_ATTACK5, "snafu/zombie/attack3");
Sound SND_SNAFU_ZOMBIE_ATTACK_RANDOM() {
    return REGISTRY_GET(Sounds, SND_SNAFU_ZOMBIE_ATTACK1.m_id + floor(prandom() * 5));
}
Sound SND_SNAFU_ZOMBIE_ATTACK_FRAME(int frm) {
	return REGISTRY_GET(Sounds, SND_SNAFU_ZOMBIE_ATTACK1.m_id + frm);
}

SOUND(SNAFU_ZOMBIE_DEATH1, "snafu/zombie/death1");
SOUND(SNAFU_ZOMBIE_DEATH2, "snafu/zombie/death2");

SOUND(SNAFU_ZOMBIE_PAIN1, "snafu/zombie/pain1");
SOUND(SNAFU_ZOMBIE_PAIN2, "snafu/zombie/pain2");

SOUND(SNAFU_ZOMBIE_GROWL1, "snafu/zombie/growl1");
SOUND(SNAFU_ZOMBIE_GROWL2, "snafu/zombie/growl2");
#endif
#endif

#ifdef IMPLEMENTATION

#ifdef SVQC
void snafu_Initialize();
REGISTER_MUTATOR(snafu, false)
{
	MUTATOR_STATIC();
	MUTATOR_ONADD
	{
		GameRules_teams(true);

		snafu_Initialize();
	}

	return false;
}

int snafu_teams;

MUTATOR_HOOKFUNCTION(snafu, TeamBalance_CheckAllowedTeams, CBC_ORDER_EXCLUSIVE)
{
	M_ARGV(0, float) = snafu_teams;
	return true;
}

MUTATOR_HOOKFUNCTION(snafu, PlayHitsound)
{
	entity frag_victim = M_ARGV(0, entity);

	return (frag_victim.snafu_ai_flags & SAF_ZOMBIE);
}

// round handling
float snafu_spawn_delay;
#define ST_SNAFU_ROUNDS 1
void snafu_ScoreRules(int teams)
{
	GameRules_scoring(teams, SFL_SORT_PRIO_PRIMARY, 0, {
		field_team(ST_SNAFU_ROUNDS, _("SCO^rounds"), SFL_SORT_PRIO_PRIMARY);
	});
}

int SNAFU_GetWinnerTeam()
{
	/*float winner_team = 0;
	if(redalive >= 1)
		winner_team = NUM_TEAM_1;
	if(bluealive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(yellowalive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(pinkalive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // no player left*/

	return NUM_TEAM_1; // red always wins for now
}

#define SNAFU_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define SNAFU_ALIVE_TEAMS_OK() (SNAFU_ALIVE_TEAMS() == NumTeams(snafu_teams))
bool SNAFU_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(autocvar_g_snafu_wave_pause, autocvar_g_snafu_warmup, autocvar_g_snafu_round_timelimit);
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			nades_Clear(it);
		});
		FOREACH_ENTITY_FLAGS(snafu_ai_flags, SAF_ZOMBIE,
		{
			it.deadflag = DEAD_DYING;
			setthink(it, snafu_fatty_die);
			it.nextthink = time;
		});
		snafu_zombie_alive = 0;
		snafu_zombie_killed = 0;
		return true;
	}

	//SNAFU_count_alive_zombies();
	if(snafu_zombie_killed < snafu_zombie_wavemax)
	{
		if(snafu_spawn_delay >= time)
			return false;
		snafu_spawn_delay = time + autocvar_g_snafu_wave_first_rate;
		if(snafu_zombie_alive < (snafu_zombie_wavemax - snafu_zombie_killed))
		{
			entity e = findchain(classname, "snafu_zombies");
			float _idx = 1 + rint(random() * (snafu_spawnareas -1));
			float i;

			for(i = 1; i != _idx; ++i)
				e = e.chain;

			RandomSelection_Init();
			RandomSelection_AddFloat(1, autocvar_g_snafu_fatty_chance, 1);
			RandomSelection_AddFloat(2, autocvar_g_snafu_princess_chance, 1);
		#if 0
			RandomSelection_AddFloat(3, autocvar_g_snafu_vprincess_chance, 1);
		#endif

			switch(RandomSelection_chosen_float)
			{
				case 1: snafu_fatty_create(e);
				case 2: snafu_princess_create(e);
			#if 0
				case 3: snafu_vprincess_create(e);
			#endif
			}
		}
		return false;
	}

	int winner_team = SNAFU_GetWinnerTeam();
	if(winner_team > 0)
	{
		//Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		//Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		int prevmax = snafu_zombie_wavemax;
		snafu_zombie_wavemax  = floor(autocvar_g_snafu_wave_count_multi * snafu_zombie_wavemax);
		snafu_zombie_waverate = floor(autocvar_g_snafu_wave_rate_multi * snafu_zombie_waverate);
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_SNAFU_ROUND_WON, snafu_wavenum, prevmax, snafu_wavenum + 1, snafu_zombie_wavemax);
		TeamScore_AddToTeam(winner_team, ST_SNAFU_ROUNDS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);
	}

	round_handler_Init(autocvar_g_snafu_wave_pause, autocvar_g_snafu_warmup, autocvar_g_snafu_round_timelimit);

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		nades_Clear(it);
	});

	FOREACH_ENTITY_FLAGS(snafu_ai_flags, SAF_ZOMBIE,
	{
		it.deadflag = DEAD_DYING;
		setthink(it, snafu_fatty_die);
		it.nextthink = time;
	});

	snafu_zombie_alive = 0;
	snafu_zombie_killed = 0;
	snafu_wavenum += 1;

	return true;
}

void SNAFU_RoundStart()
{
	allowed_to_spawn = true;
}

bool SNAFU_CheckTeams()
{
	allowed_to_spawn = true;
	return true;
}

// spawn functions
void snafu_damageswitch(entity this, entity attacker)
{
	bool _switch = false;

	LOG_DEBUG("Attacker is ", attacker.classname, " - ", attacker.netname);

	if(random() < 0.5)
		_switch = true;

	if(this.enemy.classname == "snafu_tadpole")
		_switch = true;

	if(!IS_PLAYER(attacker) && !attacker.snafu_ai_flags)
		_switch = false;

	if(attacker.deadflag != DEAD_NO)
		_switch = false;

	if(_switch)
	{
		this.snafu_ai_enemy_select_timer = time + 15;
		this.enemy = attacker;
		LOG_DEBUG("Enemy damage switch");
	}
}

void snafu_deathalert(entity this, entity attacker)
{
	FOREACH_ENTITY_RADIUS(this.origin, 1024, it.snafu_ai_flags,
	{
		if(it.enemy.classname != "snafu_tadpole" && IS_PLAYER(attacker))
		{
			it.enemy = attacker;
			it.snafu_ai_enemy_select_timer = time + 5;
			LOG_DEBUG("Enemy deathalert switch");
		}
	});
}

bool snafu_zombie_domelee(entity this, float _up, float _range, float _dmg, float _force)
{
	vector _from = this.origin + '0 0 1' * _up;
	vector _to = v_forward * _range + _from;

	//te_lightning1(this, _from, _to);
	tracebox(_from, '-1 -1 -1', '1 1 1', _to, MOVE_NORMAL, this);
	if(trace_ent && trace_ent.takedamage)
	{
		Damage(trace_ent, this, this, _dmg, DEATH_GENERIC.m_id, DMG_NOWEP, '0 0 0' , v_forward * _force);
		return true;
	}

	return false;
}

void snafu_zombie_localtarget(entity this, float _range)
{
	entity best_targ = NULL;
	float targ_score, targ_score_best = max_shot_distance;

	if(this.enemy)
	{
		targ_score_best = vlen(this.enemy.origin - this.origin) * 0.9; // nudge it so it prefers its old target
		best_targ = this.enemy;
		if(IS_PLAYER(this.enemy))
			targ_score_best *= 0.1;
	}

	FOREACH_ENTITY_RADIUS(this.origin, _range, true,
	{
		if(IS_PLAYER(it) || it.classname == "snafu_tadpole")
		if(!IS_DEAD(it))
		{
			targ_score = vlen(it.origin - this.origin);

			if(IS_PLAYER(it))
				targ_score *= 0.1;

			if(targ_score < targ_score_best)
			{
				targ_score_best = targ_score;
				best_targ = it;
			}
		}
	});

	if(best_targ)
	{
		FOREACH_ENTITY_RADIUS(this.origin, 1500, it.snafu_ai_flags & SAF_ZOMBIE,
		{
			if(!IS_DEAD(it) && it.enemy.classname == "snafu_tadpole")
			{
				it.enemy = best_targ;
				it.snafu_ai_enemy_select_timer = time + 1;
			}
		});

		this.enemy = best_targ;
	}
	else
	{
		RandomSelection_Init();
		FOREACH_ENTITY_CLASS("snafu_tadpole", !IS_DEAD(it),
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		this.enemy = RandomSelection_chosen_ent;
	}

	this.snafu_ai_enemy_select_timer = time + 1;
}


spawnfunc(snafu_zombies)
{
	if(!g_snafu) { delete(this); return; }

	++snafu_spawnareas;

	this.cnt = snafu_spawnareas;
	this.solid = SOLID_TRIGGER;
	setsize(this, this.mins, this.maxs);
	EXACTTRIGGER_INIT;
}

void snafu_game_stopped()
{
	RandomSelection_Init();
	FOREACH_ENTITY_CLASS("snafu_tadpole", IS_DEAD(it),
	{
		RandomSelection_AddEnt(it, 1, 1);
	});

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		centerprint(it, _("The tadpole is ^1DEAD^7 you ^1LOSERS!"));
		set_movetype(it, MOVETYPE_NONE);
		it.origin = RandomSelection_chosen_ent.origin + '0 0 200';

		it.origin_x += 500 * random();
		it.origin_x -= 500 * random();
		it.origin_y += 500 * random();
		it.origin_y -= 500 * random();
		it.fixangle = true;

		setorigin(it, it.origin);
		it.angles = vectoangles(normalize(RandomSelection_chosen_ent.origin - it.origin));
		it.angles_x *= -1;
	});

	NextLevel();
}

const int TADPOLE_FRAME_IDLE = 0;
const int TADPOLE_FRAME_PAIN_FIRST = 1;
const int TADPOLE_FRAME_PAIN_COUNT = 5;
const int TADPOLE_FRAME_DIE = 6;

void snafu_tadpole_damage(entity this, entity inflictor, entity attacker, float damage, float deathtype, .entity weaponentity, vector hitloc, vector force)
{
	if(!IS_PLAYER(attacker))
		TakeResource(this, RES_HEALTH, damage);

	if(GetResource(this, RES_HEALTH) <= 0)
	{
		this.deadflag = DEAD_DEAD;
		this.frame = TADPOLE_FRAME_DIE;
		this.solid = SOLID_NOT;
		this.event_damage = func_null;
		this.nextthink = 0;
		CSQCMODEL_AUTOUPDATE(this);
		snafu_game_stopped();
		return;
	}

	if(this.pain_finished < time)
	{
		this.frame = TADPOLE_FRAME_PAIN_FIRST + floor(random() * TADPOLE_FRAME_PAIN_COUNT);
		this.pain_finished = time + (0.5 * 0.3666666666666667);
		this.nextthink = time + 0.3666666666666667;
		CSQCMODEL_AUTOUPDATE(this);
	}

	if(this.wait > time)
		return;

	this.wait = time + 3;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		centerprint(it, _("^1The tadpole is under attack!\n^2DEFEND^7 the tadpole!"));
	});

}

void snafu_tadpole_think(entity this)
{
	this.nextthink = time + 2;
	if(this.pain_finished < time && this.deadflag == DEAD_NO)
		this.frame = TADPOLE_FRAME_IDLE;

	CSQCMODEL_AUTOUPDATE(this);
}

spawnfunc(snafu_tadpole)
{
	if(!g_snafu) { delete(this); return; }

	setmodel(this, MDL_SNAFU_TADPOLE);
	setsize(this, TADPOLE_MIN, TADPOLE_MAX);
	tracebox(this.origin + '0 0 64', TADPOLE_MIN, TADPOLE_MAX, this.origin - '0 0 512', MOVE_NORMAL, this);
	setorigin(this, trace_endpos);
	this.solid = SOLID_BBOX;
	this.deadflag = DEAD_NO;
	this.takedamage = DAMAGE_AIM;
	this.event_damage = snafu_tadpole_damage;
	SetResourceExplicit(this, RES_HEALTH, autocvar_g_snafu_tadpole_health);
	this.team = 10;
	setthink(this, snafu_tadpole_think);

	CSQCMODEL_AUTOINIT(this);
}

// mutator hooks
// or lack thereof

void snafu_Initialize()
{
	snafu_teams = 0;
	snafu_teams |= BIT(0);
	//snafu_teams |= BIT(1); // always red vs blue?
	snafu_ScoreRules(snafu_teams);

	snafu_zombie_wavemax = autocvar_g_snafu_wave_first_count;
	snafu_zombie_waverate = autocvar_g_snafu_wave_first_rate;

	round_handler_Spawn(SNAFU_CheckTeams, SNAFU_CheckWinner, SNAFU_RoundStart);
	round_handler_Init(autocvar_g_snafu_wave_pause, autocvar_g_snafu_warmup, autocvar_g_snafu_round_timelimit);
}
#endif

#endif
