#include "sv_td.qh"

#include "td.qh"

bool td_rankings_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TD_RANKINGS);

	if(td_phase != TD_PHASE_WIN)
		sf &= ~TD_RANKINGS_MVP;

	WriteByte(MSG_ENTITY, sf);

	if(sf & TD_RANKINGS_KILLED)
	{
		// TODO: maybe network as a float?
		WriteInt24_t(MSG_ENTITY, this.cnt);
	}

	if(sf & TD_RANKINGS_MVP)
	{
		int mvpsf = 0;
		WriteFloat(MSG_ENTITY, this.scale);
		WriteString(MSG_ENTITY, this.netname);

		if(this.score_playerkills > 0)
			mvpsf |= BIT(0);
		if(this.score_turretkills > 0)
			mvpsf |= BIT(1);
		if(this.score_repaired > 0)
			mvpsf |= BIT(2);
		if(this.score_upgrades > 0)
			mvpsf |= BIT(3);
		if(this.score_bosskilled > 0)
			mvpsf |= BIT(4); // not networked, we just check it
		WriteByte(MSG_ENTITY, mvpsf);
		if(mvpsf & BIT(0))
			WriteInt24_t(MSG_ENTITY, this.score_playerkills);
		if(mvpsf & BIT(1))
			WriteInt24_t(MSG_ENTITY, this.score_turretkills);
		if(mvpsf & BIT(2))
			WriteFloat(MSG_ENTITY, this.score_repaired);
		if(mvpsf & BIT(3))
			WriteShort(MSG_ENTITY, this.score_upgrades);
	}

	if(sf & TD_RANKINGS_TIME)
	{
		WriteInt24_t(MSG_ENTITY, TIME_ENCODE(this.wait));
	}

	if(sf & TD_RANKINGS_TOPSCORE)
	{
		WriteFloat(MSG_ENTITY, this.lip);
		WriteString(MSG_ENTITY, this.mdl);
	}

	return true;
}

void td_data_write(string data, string value)
{
	db_put(ServerProgsDB, strcat(mapname, "/", data, "/", ftos(td_skill)), value);
}

string td_data_read(string data)
{
	return db_get(ServerProgsDB, strcat(mapname, "/", data, "/", ftos(td_skill)));
}

// called when the match is won, writes stats back into the database
void td_Rankings_Save(entity this)
{
	float temptime = max(0, time - td_ent.td_matchtime);
	if(temptime < this.wait || this.wait == 0)
		td_data_write("total_time", ftos(temptime));

	if(this.scale > this.lip)
	{
		td_data_write("mvpscore", ftos(this.scale));
		td_data_write("mvp", this.netname);
	}
}

void td_Rankings_Read(entity this)
{
	this.wait = stof(td_data_read("total_time"));
	this.lip = stof(td_data_read("mvpscore"));
	this.mdl = strzone(td_data_read("mvp"));
}

void td_Ranking_SetMVP(entity this)
{
	entity best = NULL;
	float best_score = 0;

	FOREACH_CLIENT(true,
	{
		float myscore = (it.score_playerkills + it.score_turretkills + rint(it.score_repaired * 0.33) + it.score_upgrades);
		if(!best || myscore > best_score)
		{
			best = it;
			best_score = myscore;
		}
	});

	if(best)
	{
		strcpy(this.netname, best.netname);
		this.scale = best_score;
		this.score_playerkills = best.score_playerkills;
		this.score_turretkills = best.score_turretkills;
		this.score_repaired = best.score_repaired;
		this.score_upgrades = best.score_upgrades;
		this.score_bosskilled = best.score_bosskilled;
	}
	else
	{
		// if we happen to get here, nobody wins, good job
		strcpy(this.netname, "(Nobody)");
	}
	this.SendFlags |= TD_RANKINGS_MVP;
}

void td_Rankings_Init(entity this)
{
	entity rankings = spawn();
	rankings.classname = "td_rankings";

	td_Rankings_Read(rankings); // pulls current data

	Net_LinkEntity(rankings, false, 0, td_rankings_send);

	// move to a global entity so it can be pinged
	td_rankings = rankings;
}

void td_changelevel(entity this)
{
	mapname = "td";
	NextLevel();

	// play a cheer now that everyone can see it
	IL_EACH(g_td_towers, it.health > 0,
	{
		sound(it, CH_TRIGGER_SINGLE, SND_CHEER, 1, 0.1);
		Send_Effect(EFFECT_CHEER, it.origin, '0 0 150', 4);
	});
}

void td_RoundWon_Finish(entity this)
{
	IL_EACH(g_td_towers, it.health > 0,
	{
		it.takedamage = DAMAGE_NO; // no post-win death thank you
	});

	IL_EACH(g_td_fuel, true,
	{
		// stagger removal ever so slightly to reduce lag
		setthink(it, SUB_Remove);
		it.nextthink = time + random();
	});

	IL_EACH(g_turrets, true,
	{
		te_teleport(it.origin);
		if(it.tur_head)
			delete(it.tur_head);
		delete(it);
	});

	this.tur_units = 0;
	this.SendFlags |= SF_TD_ENT_COUNTS;

	// call before saving ranks
	td_Ranking_SetMVP(td_rankings);
	td_Rankings_Save(td_rankings);

	setthink(this, td_changelevel);
	this.nextthink = time + 3;
}

void td_RoundWon(entity this)
{
	Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_COMPLETE);
	if(this.noise4 != "")
	{
		if(autocvar_sv_quake_enginemusic)
			_sound(this, CH_INFO, this.noise4, 1, ATTN_NONE);
		else
			TempSound(this.noise4, 5);
	}

	IL_EACH(g_turrets, it.turretdef == TUR_ANGRY_NIMBUS,
	{
		it.clientframe = NANIM_WIN;
		it.attack_finished = time + 2;
	});

	// final wave was beaten, end the match!
	if(this.count > 0 && this.wave >= this.count)
	{
		td_phase = TD_PHASE_WIN;
		setthink(this, td_RoundWon_Finish);
		this.nextthink = time + 2;
		return;
	}

	setthink(this, td_BuildPhase_Init);
	this.nextthink = time + 5;
}

void td_delayed_end(entity this)
{
	string themap = "td";
	changelevel(themap);
}

void td_RoundLost(entity this)
{
	td_phase = TD_PHASE_LOSE;
	bprint("Game over, the monsters win\n");
	// manager ticks will stop once intermission is reached
	mapname = "td";
	NextLevel();

	IL_EACH(g_turrets, it.turretdef == TUR_ANGRY_NIMBUS,
	{
		it.clientframe = NANIM_LOSE;
		it.attack_finished = time + 2;
	});

	// reset server after some time
	if(this)
	{
		intermission_exittime = time + 10000000;  // never allow exit
		setthink(this, td_delayed_end);
		this.nextthink = time + 5;
	}
}

// very verbose way of doing it, but allows us to have multiple entries per wave/skill!

void td_SetMonsters_Easy(entity wave_ent)
{
	switch(wave_ent.wave)
	{
		case 1:
		{
			RandomSelection_AddString("15 grunt 2 enforcer", 1, 1);
			RandomSelection_AddString("13 grunt 2 enforcer 2 knight", 1, 1);
			break;
		}
		case 2:
		{
			RandomSelection_AddString("1 ogre 3 knight", 1, 1);
			RandomSelection_AddString("2 ogre", 1, 1);
			break;
		}
		case 3:
		{
			RandomSelection_AddString("2 ogre 1 hknight", 1, 1);
			RandomSelection_AddString("4 enforcer 1 hknight", 1, 1);
			break;
		}
		case 4:
		{
			RandomSelection_AddString("1 shalrath", 1, 1);
			break;
		}
		case 5:
		{
			RandomSelection_AddString("2 ogre 1 hknight 4 wizard 1 demon", 1, 1);
			break;
		}
		case 6:
		{
			RandomSelection_AddString("1 shambler 1 demon", 1, 1);
			break;
		}
		default:
		case 7:
		{
			RandomSelection_AddString("3 knight 4 ogre 1 hknight 1 demon", 1, 1);
			break;
		}
	}
}

void td_SetMonsters_Normal(entity wave_ent)
{
	switch(wave_ent.wave)
	{
		case 1:
		{
			RandomSelection_AddString("12 grunt 2 enforcer 1 ogre", 1, 1);
			break;
		}
		case 2:
		{
			RandomSelection_AddString("1 hknight 2 ogre 4 knight", 1, 1);
			break;
		}
		case 3:
		{
			RandomSelection_AddString("8 grunt 2 enforcer", 1, 1);
			break;
		}
		case 4:
		{
			RandomSelection_AddString("8 grunt 2 enforcer", 1, 1);
			break;
		}
		case 5:
		{
			RandomSelection_AddString("8 grunt 4 wizard 1 jim 2 enforcer 1 bambler 1 demon", 1, 1);
			break;
		}
		case 6:
		{
			RandomSelection_AddString("2 shambler 2 demon", 1, 1);
			break;
		}
		default:
		case 7:
		{
			RandomSelection_AddString("3 knight 4 ogre 1 hknight 1 demon", 1, 1);
			break;
		}
	}
}

void td_SetMonsters_Hard(entity wave_ent)
{
	switch(wave_ent.wave)
	{
		case 1:
		{
			RandomSelection_AddString("12 grunt 2 enforcer 1 ogre", 1, 1);
			break;
		}
		case 2:
		{
			RandomSelection_AddString("1 ogre 3 knight", 1, 1);
			break;
		}
		case 3:
		{
			RandomSelection_AddString("8 grunt 2 enforcer", 1, 1);
			break;
		}
		case 4:
		{
			RandomSelection_AddString("8 grunt 2 enforcer", 1, 1);
			break;
		}
		case 5:
		{
			RandomSelection_AddString("12 grunt 8 wizard 2 jim 2 enforcer 1 shambler", 1, 1);
			break;
		}
		case 6:
		{
			RandomSelection_AddString("1 shambler 1 demon", 1, 1);
			break;
		}
		default:
		case 7:
		{
			RandomSelection_AddString("3 knight 5 ogre 3 hknight 2 demon", 1, 1);
			break;
		}
	}
}

void td_SetMonsters_Nightmare(entity wave_ent)
{
	switch(wave_ent.wave)
	{
		case 1:
		{
			RandomSelection_AddString("24 grunt 6 enforcer 3 axegrunt 2 ogre 1 bambler", 1, 1);
			RandomSelection_AddString("10 knight 6 ogre 3 knight 2 hknight 1 hogremac", 1, 1);
			RandomSelection_AddString("10 knight 2 hknight 1 demon 1 shambler", 1, 1);
			RandomSelection_AddString("10 knight 2 sam 6 enforcer 2 grunt 3 hogreham", 1, 1);
			RandomSelection_AddString("5 knight 1 shambler 2 cacodemon 1 mutant", 1, 1);
			break;
		}
		case 2:
		{
			RandomSelection_AddString("1 ogre 3 knight 2 edie 1 minotaur", 1, 1);
			break;
		}
		case 3:
		{
			RandomSelection_AddString("1 juggernaut 2 minotaur 1 arachnofloyd 3 demon 1 tortoise 5 boil", 1, 1);
			break;
		}
		case 4:
		{
			RandomSelection_AddString("2 dfury 1 gug 1 biter 3 octa 2 wizard 2 gaunt 1 justice", 1, 1);
			break;
		}
		case 5:
		{
			RandomSelection_AddString("4 dknight 3 mutant 10 wizard 4 jim 3 bambler 1 amalgam 1 shambler 2 hogreham 1 hogremac 1 justice", 1, 1);
			break;
		}
		case 6:
		{
			RandomSelection_AddString("1 edie 2 mancubus 2 dknight 2 shalrath", 1, 1);
			break;
		}
		default:
		case 7:
		{
			RandomSelection_AddString("8 grunt 2 enforcer", 1, 1);
			break;
		}
	}
}

void td_SetMonsters(entity wave_ent)
{
	RandomSelection_Init();

	switch(wave_ent.cnt)
	{
		default:
		case 0: td_SetMonsters_Easy(wave_ent); break;
		case 1: td_SetMonsters_Normal(wave_ent); break;
		case 2: td_SetMonsters_Hard(wave_ent); break;
		case 3: td_SetMonsters_Nightmare(wave_ent); break;
#if 0
		case 1: // normal
		{
			RandomSelection_AddString("12 grunt 2 enforcer 2 axegrunt", 1, 1);
			RandomSelection_AddString("2 ogre 1 knight", 1, 1);
			RandomSelection_AddString("1 hknight", 1, 1);
			RandomSelection_AddString("1 sam 2 enforcer 2 grunt", 1, 1);
			RandomSelection_AddString("1 bambler", 1, 1);
			break;
		}
		case 2: // hard
		{
			RandomSelection_AddString("16 grunt 4 enforcer 2 axegrunt 1 ogre", 1, 1);
			RandomSelection_AddString("3 ogre 2 knight 1 hknight", 1, 1);
			RandomSelection_AddString("2 hknight 1 demon", 1, 1);
			RandomSelection_AddString("1 sam 2 enforcer 2 grunt", 1, 1);
			RandomSelection_AddString("1 shambler", 1, 1);
			break;
		}
		case 3: // nightmare
		{
			RandomSelection_AddString("24 grunt 6 enforcer 3 axegrunt 2 ogre 1 bambler", 1, 1);
			RandomSelection_AddString("6 ogre 3 knight 2 hknight 1 hogremac", 1, 1);
			RandomSelection_AddString("2 hknight 1 demon 1 shambler", 1, 1);
			RandomSelection_AddString("2 sam 6 enforcer 2 grunt 3 hogreham", 1, 1);
			RandomSelection_AddString("1 shambler 2 cacodemon", 1, 1);
			break;
		}
#endif
	}

	wave_ent.netname = strzone(RandomSelection_chosen_string);
}

string td_GetLoot(entity this)
{
	// always drop ammo
	RandomSelection_Init();
	RandomSelection_AddString("ammo_shells", 2.5, 1);
	RandomSelection_AddString("ammo_nails", 4, 1);
	RandomSelection_AddString("ammo_rockets", 2.5, 1);
	RandomSelection_AddString("ammo_cells", 2.5, 1);
	RandomSelection_AddString("ammo_lava_nails", 2.5, 1);
	RandomSelection_AddString("ammo_multi_rockets", 2.5, 1);
	RandomSelection_AddString("ammo_plasma", 2.5, 1);
	RandomSelection_AddString("ammo_drills", 2.5, 1);

	// armor depends on wave?
	RandomSelection_AddString("armor1", 0.5, 1);
	RandomSelection_AddString("armor2", 0.5, 1);
	if(this.wave >= 3)
		RandomSelection_AddString("armorInv", 0.5, 1);
	if(this.wave >= 5)
	{
		RandomSelection_AddString("armor_mage", 0.5, 1);
		RandomSelection_AddString("armor_tech", 0.5, 1);
		RandomSelection_AddString("armor_heavy", 0.5, 1);
	}

	// health
	RandomSelection_AddString("health10", 1.5, 1);
	RandomSelection_AddString("health25", 1, 1);
	RandomSelection_AddString("health100", 0.5, 1);

	int mywave = bound(2, this.wave, 9);

	FOREACH(Weapons, it != WEP_Null && it.impulse > 0,
	{
		if(it.impulse == 1 && this.wave < 5)
			continue;
		else if(it.impulse > mywave)
			continue;
		if(it.spawnflags & WEP_FLAG_ROGUE)
			continue;
		if(it.spawnflags & WEP_FLAG_CHAMPION)
			continue;
		if(it == WEP_BALL || it == WEP_BERSERKER_FISTS || it == WEP_PEWPEW || it == WEP_AXE || it == WEP_SHOTGUN || it == WEP_DRILLER)
			continue; // weapons that won't work at all
		if(it == WEP_CANNON || it == WEP_INVOKER)
			continue; // overpowered weapons
		RandomSelection_AddString(it.netname, ((it.impulse == 1 || (it.spawnflags & WEP_FLAG_MUSIC)) ? 0.5 : 1), 1);
	});

	return RandomSelection_chosen_string;
}

void td_spawnmonster(entity this, entity sp, Monster mon)
{
	entity monster = spawn();
	monster.category = CATEGORY_MONSTER;
	monster.target = sp.target;
	monster.clipgroup = CLIPGROUP_TD;
	// so they don't get spawncamped
	monster.invincible_finished = time + 2.2;

	monster = spawnmonster(monster, sp.origin, '0 1 0' * sp.angles_y, mon);
	if(!monster)
	{
		LOG_INFO("Couldn't spawn monster?");
		return; // TODO?
	}

	//LOG_INFO("Spawned ", monster.monsterdef.netname);

	sp.td_monsters[mon.monsterid] -= 1;
}

void td_SpawnMonsters(entity this, entity sp)
{
	// delay regardless of whether monster spawning succeeds
	sp.wait = time + 0.25 + (this.spawntime * random());

	RandomSelection_Init();
	FOREACH(Monsters, it != MON_Null,
	{
		if(sp.td_monsters[it.monsterid] > 0)
			RandomSelection_AddEnt(it, 1, 1);
	});

	Monster mon = RandomSelection_chosen_ent;
	if(!mon || mon == MON_Null)
	{
		// TODO?
		//LOG_INFO("No valid monster?");
		return;
	}
	td_spawnmonster(this, sp, mon);
}

void td_CombatPhase_Tick(entity this)
{
	if(intermission_running)
		return;

	this.nextthink = time;

	if(monsters_killed >= monsters_total)
	{
		// we've reached the needed count, but make sure none are lingering
		int monstercount = 0;
		FOREACH_ENTITY_STRING(category, CATEGORY_MONSTER,
		{
			if(it.charmed)
				continue;
			if(it.health > 0)
				monstercount += 1;
		});
		if(monstercount > 0)
			return;

		td_RoundWon(this);
		return;
	}

	IL_EACH(g_td_spawns, time >= it.wait && it.wave <= this.wave,
	{
		td_SpawnMonsters(this, it);
	});
}

void td_CombatPhase_Init(entity this)
{
	td_phase = TD_PHASE_COMBAT;

	bprint("Combat phase!\n");

	if(this.noise2 && this.noise2 != "")
		_sound(this, CH_INFO, this.noise2, 1, ATTN_NONE);

	Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_COMBATPHASE);

	IL_EACH(g_td_towers, it.health > 0 && it.noise1 && it.noise1 != "",
	{
		_sound(it, CH_TRIGGER_SINGLE, it.noise1, 1, 0.1);
	});

	// clean up previous wave's drops
	IL_EACH(g_td_fuel, true,
	{
		setthink(it, SUB_Remove);
		it.nextthink = time;
		settouch(it, func_null);
	});
	IL_EACH(g_moveables, (it.classname == "backpack" || it.isloot) && !IS_PLAYER(it.owner),
	{
		setthink(it, SUB_Remove);
		it.nextthink = time;
		settouch(it, func_null);
	});

	FOREACH_CLIENT(true, { it.ready = false; });
	readycount = 0;
	Nagger_ReadyCounted();  // NOTE: this causes a resend of that entity, and will also turn off warmup state on the client

	setthink(this, td_CombatPhase_Tick);
	this.nextthink = time;
}

void td_BuildPhase_Tick(entity this)
{
	if(intermission_running)
		return;

	this.nextthink = time;

	// if the timer's up, begin!
	if(td_starttime > 0 && time >= td_starttime)
	{
		td_CombatPhase_Init(this);
		return;
	}

	if(td_starttime >= 0)
	{
		float time_left = td_starttime - time;
		if(time_left < 11 && floor(time_left - frametime) != floor(time_left))
		{
			Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_ROUNDSTART, this.wave, floor(time_left));
			_sound(this, CH_INFO, "misc/talk.wav", 1, ATTEN_NONE);
		}
	}
}

void td_MonsterSetup(entity this, Monster mon)
{
	if(mon.spawnflags & MONSTER_TYPE_BOSS)
		return;
	if(!td_ent)
		return;
	if(td_ent.scale <= 0)
		return;

	// only a minor step up per wave as otherwise they'll be impossible to kill!
	float myscale = td_ent.scale * 0.02;
	this.health = this.health * (1 + (myscale * (td_skill + 1)) * td_ent.wave);
}

int td_CountMonsters(entity this, entity sp)
{
	int monsters = 0;
	FOREACH(Monsters, it != MON_Null,
	{
		if(sp.td_monsters[it.monsterid] > 0)
			monsters += sp.td_monsters[it.monsterid];
	});
	return monsters;
}

int td_CountMonsters_Total(entity this)
{
	int monsters = 0;
	IL_EACH(g_td_spawns, it.wave <= this.wave,
	{
		monsters += td_CountMonsters(this, it);
	});
	return monsters;
}

int td_DistributeMonsters(entity this, entity wave_ent, Monster mon, int spawncount)
{
	int monsters = 0;
	// randomly allocates the monsters between the available spawn points
	for(int j = 0; j < spawncount; ++j)
	{
		RandomSelection_Init();

		IL_EACH(g_td_spawns, it.wave <= this.wave,
		{
			// random placement, be a little picky
			if(!wave_ent.target || wave_ent.target == "")
			{
				// NOTE: this is written verbosely so a monster that is both
				// a boss and a flying type doesn't get culled
				// TODO: simplify
				if(mon.spawnflags & MONSTER_TYPE_BOSS)
				{
					if(it.cnt != TD_SPAWNPOINT_BOSS)
						continue;
				}
				else if(mon.spawnflags & MONSTER_TYPE_FLY)
				{
					if(it.cnt != TD_SPAWNPOINT_FLYING)
						continue;
				}
				else if(mon.spawnflags & MONSTER_TYPE_SWIM)
				{
					if(it.cnt != TD_SPAWNPOINT_SWIMMING)
						continue;
				}
				else
				{
					if(it.cnt != TD_SPAWNPOINT_NORMAL)
						continue;
				}
			}
			else if(wave_ent.target != it.targetname)
				continue;
			RandomSelection_AddEnt(it, 1, 1);
		});

		entity sp = RandomSelection_chosen_ent;
		if(sp)
		{
			monsters += 1;
			sp.td_monsters[mon.monsterid] += 1;
		}
	}
	return monsters;
}

Monster td_PickBoss()
{
	RandomSelection_Init();
	FOREACH(Monsters, it != MON_Null && (it.spawnflags & MONSTER_TYPE_BOSS),
	{
		if(it.spawnflags & MON_FLAG_STATIONARY)
			continue;
		if(it.spawnflags & MON_FLAG_HIDDEN)
			continue;
		if(it.spawnflags & MON_FLAG_PART)
			continue;
		RandomSelection_AddEnt(it, 1, 1);
	});
	return RandomSelection_chosen_ent;
}

void td_BuildPhase_Init(entity this)
{
	this.wave += 1;
	this.SendFlags |= SF_TD_ENT_COUNTS;

	bprint("Build phase!\n");

	int bosscount = 0;
	bool chickens = false, cheddar = false;
	int chickenbosses = 0;
	float chicken_chance = 0.075;
	bool have_flying = false;
	bool bosswave = (this.count > 0 && this.wave == this.count);
	if(this.wave > this.lip && random() < 0.075)
		bosswave = true;
	else if(!(this.spawnflags & TD_ENT_NOCHEDDAR) && this.wave > this.lip && (this.wave < this.count || this.count <= 0) && random() < chicken_chance)
	{
		if(random() > 0.5)
			chickens = true;
		else
			cheddar = true;

		chickenbosses = (random() < 0.25) ? 2 : 1;
	}

	if(this.count > 0 && this.wave == this.count)
	{
		if(this.noise3 != "")
			_sound(this, CH_INFO, this.noise3, 1, ATTN_NONE);
		else if(this.noise1 != "")
			_sound(this, CH_INFO, this.noise1, 1, ATTN_NONE);
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_FINALWAVE);
	}
	else if(bosswave)
	{
		if(this.noise3 != "")
			_sound(this, CH_INFO, this.noise3, 1, ATTN_NONE);
		else if(this.noise1 != "")
			_sound(this, CH_INFO, this.noise1, 1, ATTN_NONE);
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_BOSSWAVE);
	}
	else if(cheddar)
	{
		_sound(this, CH_INFO, "cheddar_goblin/sight.wav", 1, ATTN_NONE);
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_CHEDDARPHASE);
	}
	else if(chickens)
	{
		_sound(this, CH_INFO, "chicken/sight.wav", 1, ATTN_NONE);
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_CHICKENPHASE);
	}
	else
	{
		if(this.noise1 != "")
			_sound(this, CH_INFO, this.noise1, 1, ATTN_NONE);
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_BUILDPHASE);
	}

	float mydelay = this.delay;
	// double the initial delay for easier building
	if(this.wave == this.lip)
		mydelay *= 2;
	float start_delay = (mydelay > 0) ? time + mydelay : 0;

	td_phase = TD_PHASE_BUILD;
	td_starttime = start_delay;
	monsters_total = 0; // updated later, but reset regardless
	monsters_killed = 0;

	// heal towers on lower difficulties
	if(autocvar_skill <= 1)
	{
		IL_EACH(g_td_towers, it.health < it.max_health,
		{
			it.health = it.max_health;
			if(it.sprite)
				WaypointSprite_UpdateHealth(it.sprite, it.health);
		});
	}

	// reset chests
	IL_EACH(g_td_chests, it.state,
	{
		it.state = false;
		it.SendFlags |= 1;
	});

	// remove any waves that are no longer valid
	IL_EACH(g_td_waves, true,
	{
		if((it.spawnflags & TD_WAVE_SINGLEUSE) && it.wave < this.wave)
		{
			delete(it);
			continue;
		}
	});
	// reset monster counts
	IL_EACH(g_td_spawns, true,
	{
		entity sp = it;
		FOREACH(Monsters, it != MON_Null,
		{
			sp.td_monsters[it.monsterid] = 0;
		});
	});

	IL_EACH(g_td_waves, true,
	{
		if(it.wave > this.wave)
			continue;

		// logic copied from horde SpawnSquad2
		int argc = tokenize_console(it.netname);
		for(int j = 0; j < argc; ++j)
		{
			int spawncount = stoi(argv(j));
			if(spawncount == 0)
				continue; // not a number
			string next = argv(j + 1);
			Monster mon = Monster_from_name(next);
			if(mon == MON_Null)
			{
				LOG_INFO("td_wave: invalid monster name ", next);
				j += 1;
				continue;
			}
			// done after making sure the entry is valid
			if(chickens)
				mon = MON_CHICKEN;
			else if(cheddar)
				mon = MON_CHEDDAR_GOBLIN;
			LOG_INFO("Adding spawns ", mon.netname, " ", itos(spawncount));
			// if it's an old wave, scale up its counts!
			if(it.wave != this.wave)
				spawncount += rint(((this.wave - it.wave) * this.wave) * 0.5);

			if(!(mon.spawnflags & MONSTER_TYPE_BOSS) && this.scale > 0)
				spawncount = rint(spawncount * this.scale);

			int addedmonsters = td_DistributeMonsters(this, it, mon, spawncount);
			monsters_total += addedmonsters;
			if((mon.spawnflags & MONSTER_TYPE_FLY) && addedmonsters > 0)
				have_flying = true;

			j += 1; // skip the next token
		}

		// final wave: boss!
		// TODO: do this outside of the wave logic?
		if(bosswave && bosscount < 1 && !(this.spawnflags & TD_ENT_NOBOSS))
		{
			Monster mon = td_PickBoss();
			if(mon && mon != MON_Null)
			{
				bosscount = td_DistributeMonsters(this, it, mon, 1);
				monsters_total += bosscount;
				if(bosscount > 0)
					LOG_INFO("Adding boss spawn ", mon.netname, " ", itos(bosscount));
				else
					LOG_INFO("Failed to add boss ", mon.netname, " ", itos(bosscount));
			}
		}

		// add funny bosses as well
		if(chickens && chickenbosses > 0 && random() < 0.33)
		{
			chickenbosses -= 1;
			monsters_total += td_DistributeMonsters(this, it, MON_SUPER_CHICKEN, 1);
		}
		if(cheddar && chickenbosses > 0 && random() < 0.33)
		{
			chickenbosses -= 1;
			monsters_total += td_DistributeMonsters(this, it, MON_BOGLORD, 1);
		}
	});

	// update spawn points
	// must be done after their counts have been set
	IL_EACH(g_td_spawns, it.wave <= this.wave,
	{
		// update regardless
		int mycnt = it.sprite.wp_extra;
		it.sprite.wp_extra = td_CountMonsters(this, it);
		if(mycnt != it.sprite.wp_extra)
			it.sprite.SendFlags |= 1; // force an update
	});

	bprintf("Wave %d monsters: %d\n", this.wave, monsters_total);

	if(have_flying && !this.attack_released)
	{
		this.attack_released = true;
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_BEWARE_SKIES);
	}

	setthink(this, td_BuildPhase_Tick);
	this.nextthink = time;
}

bool td_manager_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TD_ENT);

	// only send music if it exists!
	if(!this.music || this.music == "")
		sf &= ~SF_TD_ENT_MUSIC;

	WriteByte(MSG_ENTITY, sf);

	if(sf & SF_TD_ENT_COUNTS)
	{
		WriteByte(MSG_ENTITY, this.wave);
		WriteShort(MSG_ENTITY, this.tur_units);
	}

	if(sf & SF_TD_ENT_LIMITS)
	{
		int wlimit = (this.count > 0) ? this.count : 0;
		WriteByte(MSG_ENTITY, wlimit); // wave limit
		WriteShort(MSG_ENTITY, this.currentammo); // max units
	}

	if(sf & SF_TD_ENT_MUSIC)
	{
		WriteString(MSG_ENTITY, this.music);
	}

	return true;
}

void td_Init(entity this)
{
	// check for td_wave entities, spawn defaults if none are found
	if(!find(NULL, classname, "td_wave"))
	{
		int maxwaves = bound(1, this.count, 8); // we don't have that many variants!
		for(int j = 1; j <= maxwaves; ++j)
		{
			entity wave_ent = spawn();
			wave_ent.classname = "td_wave";
			wave_ent.wave = j;
			wave_ent.cnt = td_skill;
			// netname is unset so it will be populated automatically
			td_wave_setup(wave_ent);
		}
	}

	this.td_matchtime = time;

	td_Rankings_Init(this);

	setthink(this, td_BuildPhase_Init);
	this.nextthink = time;

	Net_LinkEntity(this, false, 0, td_manager_send);
}

spawnfunc(td_manager)
{
	if(td_ent)
	{
		// if we're a higher skill level and still within the match skill, replace!
		// allows per-skill managers (wave limit, delays etc)
		// NOTE: high skill managers will still be used if there's no alternative
		if((this.cnt > td_ent.cnt && this.cnt <= autocvar_skill) || (this.cnt < td_ent.cnt && td_ent.cnt > autocvar_skill))
		{
			delete(td_ent);
		}
		else
		{
			delete(this);
			return;
		}
	}

	td_ent = this;

	setthink(this, td_Init);
	this.nextthink = time + 2; // initial delay to let players load in

	precache_sound("cheddar_goblin/sight.wav");
	precache_sound("chicken/sight.wav");
	precache_sound("misc/talk.wav");

	// build phase
	if(!this.noise1 || this.noise1 == "")
		this.noise1 = "td/buildphase.wav";
	// combat phase
	if(!this.noise2 || this.noise2 == "")
		this.noise2 = "td/combatphase.wav";
	// final wave
	if(!this.noise3 || this.noise3 == "")
		this.noise3 = "td/finalwave.wav";
	// round complete
	if(!this.noise4 || this.noise4 == "")
		this.noise4 = "td/roundcomplete.wav";

	precache_sound(this.noise1);
	precache_sound(this.noise2);
	precache_sound(this.noise3);
	precache_sound(this.noise4);

	td_skill = autocvar_skill;
	td_phase = TD_PHASE_INIT;

	// build time, set to negative for infinite build time
	if(!this.delay)
		this.delay = autocvar_sv_quake_td_buildtime;

	// wave limit, can be negative for infinite waves
	if(this.count < 0)
		this.count = 0;
	else if(!this.count)
		this.count = autocvar_sv_quake_td_wavelimit;

	// available units for defence placement
	if(!this.currentammo)
		this.currentammo = autocvar_sv_quake_td_units;

	// overall difficulty/monster scale of the map
	// setting it to a negative value disables enemy health/damage scaling
	if(!this.scale)
		this.scale = 1;

	// HACK: we increase the wave count later, but mappers may set a starting wave
	// so reduce the wave counter by 1 so it starts at the mapper's intended wave
	if(this.wave > 0)
		this.wave -= 1;

	// spawn rate of monsters, scaled by randomness
	if(this.spawntime <= 0)
		this.spawntime = 1;

	// store the actual starting wave for later checks
	this.lip = this.wave + 1;
}

void td_wave_setup(entity this)
{
	if(!this.wave)
		this.wave = 1;

	// an empty netname is allowed, falls back to an internal list
	if(!this.netname || this.netname == "")
		td_SetMonsters(this);

	IL_PUSH(g_td_waves, this);
}

spawnfunc(td_wave)
{
	if(gametype != GAMETYPE_TD || this.cnt > autocvar_skill)
	{
		delete(this);
		return;
	}

	td_wave_setup(this);
}

void td_spawnpoint_sendtracer(vector org, entity targ);
void td_tracer_think(entity this)
{
	this.nextthink = time;

	if(td_phase != TD_PHASE_BUILD)
	{
		delete(this);
		return;
	}

	vector targ_org = CENTER_OR_VIEWOFS(this.goalentity);
	vector dir = normalize(targ_org - this.origin);

	if(!this.goalentity || vdist(this.origin - targ_org, <=, 64))
	{
		if(this.goalentity.target && this.goalentity.target != "")
		{
			bool first = false;
			FOREACH_ENTITY_STRING(targetname, this.goalentity.target,
			{
				// we get the first found
				if(!first)
				{
					this.goalentity = it;
					first = true;
					continue;
				}
				// at converging paths, send off another tracer!
				td_spawnpoint_sendtracer(this.origin, it);
			});
		}
		else
			this.goalentity = NULL;

		if(!this.goalentity)
		{
			delete(this);
			return;
		}
		targ_org = CENTER_OR_VIEWOFS(this.goalentity);
		dir = normalize(targ_org - this.origin);
	}

	this.velocity = dir * 500;
}

void td_spawnpoint_sendtracer(vector org, entity targ)
{
	entity tracer = spawn();
	tracer.classname = "tracer";
	set_movetype(tracer, MOVETYPE_NOCLIP);
	setmodel(tracer, MDL_Null);
	setsize(tracer, '-4 -4 -4', '4 4 4');
	setorigin(tracer, org);
	tracer.goalentity = targ;
	tracer.effects = EF_LOWPRECISION;
	tracer.alpha = 1;
	tracer.traileffectnum = _particleeffectnum("nade_red");
	setthink(tracer, td_tracer_think);
	tracer.nextthink = time;
}

void td_spawnpoint_tracers(entity this)
{
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		td_spawnpoint_sendtracer(this.origin, it);
	});
}

void td_spawnpoint_think(entity this)
{
	this.nextthink = time;

	if(this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.SendFlags |= 1; // ping
	}

	if(this.sprite.wp_extra <= 0)
		return;

	if(this.wave > td_ent.wave)
		return;

	if(this.target && this.target != "" && td_phase == TD_PHASE_BUILD && time >= this.attack_finished)
	{
		this.attack_finished = time + 3;
		td_spawnpoint_tracers(this);
	}
}

bool td_waypointsprite_visible_for_player(entity this, entity player, entity view)
{
	if(gameover || intermission_running || td_phase != TD_PHASE_BUILD)
		return false;
	if(this.owner.classname == "td_manager" && this.wp_extra <= 0)
		return false;
	else if(this.wp_extra <= 0)
		return false;
	return true;
}

bool td_spawnpoint_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TD_SPAWNPOINT);
	WriteVector(MSG_ENTITY, this.origin);

	return true;
}

void td_spawnpoint_setup(entity this)
{
	// we actually allow this! stationary guards
#if 0
	if(!this.target || this.target == "")
	{
		objerror(this, "td_spawnpoint must target a path_corner");
		return;
	}
#endif

	this.classname = "td_spawnpoint";
	this.solid = SOLID_TRIGGER; // thanks engine
	setsize(this, '-150 -150 -150', '150 150 150');
	set_movetype(this, MOVETYPE_NONE);

	setthink(this, td_spawnpoint_think);
	this.nextthink = time;
	this.attack_finished = time + 1 + random() * 2; // don't start doing it immediately

	WaypointSprite_SpawnFixed(WP_Monsters, (this.absmin + this.absmax) * 0.5, this, sprite, NULL);
	this.sprite.waypointsprite_visible_for_player = td_waypointsprite_visible_for_player;

	// bosses aren't so worried about turrets
	if(this.cnt != TD_SPAWNPOINT_BOSS)
		Net_LinkEntity(this, false, 0, td_spawnpoint_send);

	IL_PUSH(g_td_spawns, this);
}

spawnfunc(td_spawnpoint)
{
	if(gametype != GAMETYPE_TD) { delete(this); return; }

	this.cnt = TD_SPAWNPOINT_NORMAL;
	td_spawnpoint_setup(this);
}

spawnfunc(td_spawnpoint_flying)
{
	if(gametype != GAMETYPE_TD) { delete(this); return; }

	this.cnt = TD_SPAWNPOINT_FLYING;
	td_spawnpoint_setup(this);
}

spawnfunc(td_spawnpoint_swimming)
{
	if(gametype != GAMETYPE_TD) { delete(this); return; }

	this.cnt = TD_SPAWNPOINT_SWIMMING;
	td_spawnpoint_setup(this);
}

spawnfunc(td_spawnpoint_boss)
{
	if(gametype != GAMETYPE_TD) { delete(this); return; }

	this.cnt = TD_SPAWNPOINT_BOSS;
	td_spawnpoint_setup(this);
}

void td_tower_explode(entity this)
{
	if(random() < 0.33)
		_sound(this, CH_TRIGGER_SINGLE, "weapons/nuke_explode_alt.wav", 1, 0.1);
	else
		sound(this, CH_TRIGGER_SINGLE, SND_ROCKET_EXPLOSION, 1, 0.1);
	Send_Effect(EFFECT_EXPLOSION_MEDIUM, CENTER_OR_VIEWOFS(this), '0 0 0', 1);

	delete(this);
}

void td_tower_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.sprite)
		WaypointSprite_Kill(this.sprite);

	if(td_phase != TD_PHASE_LOSE && td_phase != TD_PHASE_WIN)
		td_RoundLost(td_ent);

	this.takedamage = DAMAGE_NO;

	setthink(this, td_tower_explode);
	this.nextthink = time + 2; // give players a moment to arrive!
}

void td_tower_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.sprite)
		WaypointSprite_UpdateHealth(this.sprite, this.health);

	if(time >= this.pain_finished)
	{
		this.pain_finished = time + 0.1;
		if(this.noise2 && this.noise2 != "")
			_sound(this, CH_TRIGGER_SINGLE, this.noise2, 1, 0.1);
	}

	if(time >= this.attack_finished)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_TOWER_UNDERATTACK);
		if(random() < 0.15)
			_sound(this, CH_INFO, "td/alarme.wav", 1, ATTN_NONE);
		else
			_sound(this, CH_INFO, "td/alarm.wav", 1, ATTN_NONE);
		if(this.sprite)
			WaypointSprite_HelpMePing(this.sprite);
		this.attack_finished = time + 5;
	}
}

bool td_tower_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TD_TOWER);

	sf = 0;
	if(this.mdl && this.mdl != "")
		sf |= SF_TD_TOWER_MDL;

	WriteVector(MSG_ENTITY, this.origin);
	WriteAngle(MSG_ENTITY, this.angles_y);
	WriteByte(MSG_ENTITY, sf);
	WriteByte(MSG_ENTITY, this.worldtype);

	if(sf & SF_TD_TOWER_MDL)
		WriteString(MSG_ENTITY, this.mdl);
	return true;
}

void td_tower_think(entity this)
{
	this.nextthink = time;
	if(this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.SendFlags |= 1; // ping
	}
}

spawnfunc(td_tower)
{
	if(gametype != GAMETYPE_TD) { delete(this); return; }

	precache_sound("td/alarm.wav");
	precache_sound("td/alarme.wav");
	precache_sound("weapons/nuke_explode_alt.wav");

	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_NONE);

	if(!this.health)
		this.health = 1500;

	if(autocvar_skill > 0)
		this.health *= autocvar_skill;

	switch(world.worldtype)
	{
		case WORLDTYPE_MEDIEVAL:
		{
			if(!this.noise1 || this.noise1 == "")
				this.noise1 = "enviro/security/onalarm2.wav";
			if(!this.noise2 || this.noise2 == "")
				this.noise2 = "misc/glass_impact.wav";
			break;
		}
		default:
		case WORLDTYPE_METAL:
		{
			if(!this.noise1 || this.noise1 == "")
				this.noise1 = "floyd/sight.wav";
			if(!this.noise2 || this.noise2 == "")
				this.noise2 = "floyd/pain.wav";
			break;
		}
		case WORLDTYPE_BASE:
		{
			if(!this.noise1 || this.noise1 == "")
				this.noise1 = "misc/basekey.wav";
			if(!this.noise2 || this.noise2 == "")
				this.noise2 = "break/metal_i3.wav";
			break;
		}
	}

	if(this.noise1 && this.noise1 != "")
		precache_sound(this.noise1);
	if(this.noise2 && this.noise2 != "")
		precache_sound(this.noise2);

	// TODO: custom sized towers?
	setsize(this, '-32 -32 -24', '32 32 64');

	this.monster_attack = true;
	this.takedamage = DAMAGE_YES;
	this.th_die = td_tower_die;
	this.th_pain = td_tower_pain;
	this.max_health = this.health;
	this.worldtype = world.worldtype;

	setthink(this, td_tower_think);
	this.nextthink = time + 0.1;

	DropToFloor_QC_DelayedInit(this);
	this.oldorigin = this.origin;

	entity wp = WaypointSprite_Spawn(WP_Tower, 0, 0, this, '0 0 64', NULL, 0, this, sprite, false, NULL);
	WaypointSprite_UpdateMaxHealth(wp, this.max_health);
	WaypointSprite_UpdateHealth(wp, this.health);

	Net_LinkEntity(this, false, 0, td_tower_send);

	IL_PUSH(g_td_towers, this);
}

bool td_chest_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TD_CHEST);

	sf = 0;
	if(this.state)
		sf |= SF_TD_CHEST_OPEN;
	if(this.mdl && this.mdl != "")
		sf |= SF_TD_CHEST_MDL;
	if(this.noise && this.noise != "")
		sf |= SF_TD_CHEST_NOISE;

	WriteVector(MSG_ENTITY, this.origin);
	WriteAngle(MSG_ENTITY, this.angles_y);
	WriteByte(MSG_ENTITY, sf);
	WriteByte(MSG_ENTITY, this.worldtype);

	if(sf & SF_TD_CHEST_MDL)
		WriteString(MSG_ENTITY, this.mdl);
	if(sf & SF_TD_CHEST_NOISE)
		WriteString(MSG_ENTITY, this.noise);
	return true;
}

void td_chest_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) || this.state)
		return;
	if(td_phase != TD_PHASE_BUILD && td_phase != TD_PHASE_COMBAT)
		return; // no touchies during init?

	this.state = true;
	this.SendFlags |= 1;

	// TODO: allow customisation of chest fuel amounts
	float startwave = (td_ent && td_ent.lip > 0) ? td_ent.lip : 1;
	float amount = this.count * startwave * (autocvar_skill + 1);
	td_DropFuel(this, amount, NULL, true);

	int myloot = floor(random() * 4) + 1;
	for(int j = 0; j < myloot; ++j)
	{
		td_DropItem(this);
	}

	if(this.spawnflags & TD_CHEST_SINGLEUSE)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time + 2;
		settouch(this, func_null);
	}
}

spawnfunc(td_chest)
{
	if(gametype != GAMETYPE_TD) { delete(this); return; }

	IL_PUSH(g_td_chests, this);

	this.worldtype = world.worldtype; // TODO? more reliable than waiting for the STAT

	if(this.count <= 0)
		this.count = 40;

	settouch(this, td_chest_touch);
	this.state = false; // closed
	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_NONE);
	setsize(this, '-24 -24 0', '24 24 32');
	DropToFloor_QC_DelayedInit(this);
	set_movetype(this, MOVETYPE_NONE);
	Net_LinkEntity(this, false, 0, td_chest_send);
}

PRECACHE(td_fuel)
{
	precache_sound("items/vamppickup1.wav");
	precache_sound("items/vamppickup2.wav");
	precache_sound("items/vamppickup3.wav");

	precache_sound("enviro/physics/glassbit.wav");
}

bool td_fuel_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TD_FUEL);
	WriteByte(MSG_ENTITY, sf);

	if(sf & SF_TD_FUEL_TYPE)
	{
		WriteByte(MSG_ENTITY, this.cnt);
	}

	if(sf & SF_TD_FUEL_ORIGIN)
	{
		WriteVector(MSG_ENTITY, this.origin);
	}

	if(sf & SF_TD_FUEL_VELOCITY)
	{
		WriteVector(MSG_ENTITY, this.velocity);
	}

	return true;
}

void td_fuel_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(STAT(TD_FUEL, toucher) >= TD_FUEL_MAX)
		return;
	if(time < this.delay)
		return;
	if(this.buddy == toucher)
		return;

	float r = random();
	if(r < 0.33)
		_sound(toucher, CH_TRIGGER_SINGLE, "items/vamppickup1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(toucher, CH_TRIGGER_SINGLE, "items/vamppickup2.wav", 1, ATTN_NORM);
	else
		_sound(toucher, CH_TRIGGER_SINGLE, "items/vamppickup3.wav", 1, ATTN_NORM);

	STAT(TD_FUEL, toucher) = min(STAT(TD_FUEL, toucher) + this.count, TD_FUEL_MAX);
	delete(this);
}

void td_fuel_think(entity this)
{
	this.nextthink = time;

	if(time > this.wait || intermission_running)
	{
		delete(this);
		return;
	}

	if(this.wait < time + 4 && this.lip > time)
	{
		this.alpha = (this.alpha == 1) ? 0.25 : 1;
		this.lip = time + 0.25;
	}

	if(this.buddy && time >= this.attack2_finished)
		this.buddy = NULL;

	if(this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.SendFlags |= SF_TD_FUEL_ORIGIN;
	}

	if(time < this.delay)
		return;

	vector extrasize = '64 64 64';
	vector emin = this.absmin - extrasize;
	vector emax = this.absmax + extrasize;

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this && IS_PLAYER(it),
	{
		if(gettouch(this))
			gettouch(this)(this, it);
		if(wasfreed(this))
			break;
	});
}

void td_DropFuelAmount(vector from, int ftype, float amount, vector dir, entity ignore)
{
	entity item = new(td_fuel);
	setorigin(item, from);

	if(dir != '0 0 0')
		item.velocity = dir * 100;

	item.velocity_x += -150 + (random() * 300);
	item.velocity_y += -150 + (random() * 300);
	item.velocity_z += 150 + (random() * 100);

	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.gravity = 1;
	item.effects = EF_FULLBRIGHT;
	set_movetype(item, MOVETYPE_TOSS);

	if(ignore)
	{
		item.buddy = ignore;
		item.attack2_finished = time + 5; // ignore them for this long
	}

	item.cnt = ftype;
	item.count = amount;

	float item_lifetime = 360;
	if(ignore.turretdef) // spawned by a turret
		item_lifetime = 10;

	if(ftype == TD_FUEL_SUN)
		setsize(item, '-16 -16 -16', '16 16 16');
	else
		setsize(item, '-16 -16 -8', '16 16 24');
	settouch(item, td_fuel_touch);
	item.wait = time + item_lifetime;
	item.alpha = 1;
	item.state = 0;
	item.distance = 0;
	item.delay = time + 0.5; // no instant pickups thank you
	item.spawn_time = time;

	setthink(item, td_fuel_think);
	item.nextthink = time;

	IL_PUSH(g_td_fuel, item);

	Net_LinkEntity(item, true, 0, td_fuel_send);
}

void td_DropFuel(entity this, int fuel, entity ignore, bool ischest)
{
	fuel = rint(fuel);

	vector from = CENTER_OR_VIEWOFS(this);
	vector dir = '0 0 0';
	if(ischest)
	{
		makevectors(this.angles);
		dir = v_forward;
	}

	// chests only drop a maximum size of 50 so other players have a chance to gather it
	if(!ischest)
	{
		while(fuel >= 2000)
		{
			td_DropFuelAmount(from, TD_FUEL_MEGA, 2000, dir, ignore);
			fuel -= 2000;
		}
		while(fuel >= 500)
		{
			td_DropFuelAmount(from, TD_FUEL_LARGE, 500, dir, ignore);
			fuel -= 500;
		}
	}
	while(fuel >= 50)
	{
		td_DropFuelAmount(from, TD_FUEL_LARGE, 50, dir, ignore);
		fuel -= 50;
	}
	while(fuel >= 10)
	{
		td_DropFuelAmount(from, TD_FUEL_MEDIUM, 10, dir, ignore);
		fuel -= 10;
	}
	while(fuel >= 5)
	{
		td_DropFuelAmount(from, TD_FUEL_SMALL, 5, dir, ignore);
		fuel -= 5;
	}
	while(fuel >= 1)
	{
		td_DropFuelAmount(from, TD_FUEL_TINY, 1, dir, ignore);
		fuel -= 1;
	}
}

void td_PlayerDropFuel(entity this)
{
	float maxdropped = 100;
	float fuel = min(STAT(TD_FUEL, this), maxdropped);
	if(fuel <= 0)
		return;

	_sound(this, CH_TRIGGER_SINGLE, "enviro/physics/glassbit.wav", 1, 0.5);
	td_DropFuel(this, fuel, this, false);
	STAT(TD_FUEL, this) = max(STAT(TD_FUEL, this) - fuel, 0);
}

void td_FuelCleanup()
{
	int fuelcount = 0;
	entity chosen = NULL;
	float chosen_time = 0;
	IL_EACH(g_td_fuel, true,
	{
		fuelcount += 1;
		float mytime = time - it.spawn_time;
		if(!chosen || mytime >= chosen_time)
		{
			chosen = it;
			chosen_time = mytime;
		}
	});

	int maxfuel = (autocvar_sv_quake_td_maxfuel > 0) ? autocvar_sv_quake_td_maxfuel : 200;

	if(fuelcount > maxfuel && chosen)
		delete(chosen);
}

void td_BackpackCleanup()
{
	int bcount = 0;
	entity chosen = NULL;
	float chosen_time = 0;
	IL_EACH(g_moveables, (it.classname == "backpack" || it.isloot) && !IS_PLAYER(it.owner),
	{
		bcount += 1;
		float mytime = time - it.spawn_time;
		if(!chosen || mytime >= chosen_time)
		{
			chosen = it;
			chosen_time = mytime;
		}
	});

	int maxloot = (autocvar_sv_quake_td_maxloot > 0) ? autocvar_sv_quake_td_maxloot : 25;

	if(bcount > maxloot && chosen)
		delete(chosen);
}

void td_StartFrame()
{
	if(td_phase == TD_PHASE_BUILD)
		return; // allow some leeway while setting up

	td_FuelCleanup();

	td_BackpackCleanup();
}

void td_DropArmor(entity from, entity this, string item)
{
	this.classname = "item_armor";
	this.noalign = true;
	this.flags = FL_ITEM;
	this.solid = SOLID_TRIGGER;
	settouch(this, horde_armor_touch);
	set_movetype(this, MOVETYPE_TOSS);
	this.isloot = true;

	int mytype = ARMOR_GREEN;
	switch(item)
	{
		default:
		case "armor1": mytype = ARMOR_GREEN; break;
		case "armor2": mytype = ARMOR_YELLOW; break;
		case "armorInv": mytype = ARMOR_RED; break;
		case "armor_mage": mytype = ARMOR_MAGE; break;
		case "armor_tech": mytype = ARMOR_TECH; break;
		case "armor_heavy": mytype = ARMOR_HEAVY; break;
	}

	traceline(from.origin, from.origin - '0 0 24', MOVE_NORMAL, from);
	setorigin(this, trace_endpos);

	armor_init(this, mytype);
	precache_sound(this.noise);
	precache_model(this.mdl);
	_setmodel(this, this.mdl);
	setsize(this, '-16 -16 0', '16 16 56');

	this.velocity_z = 300;
	this.velocity_x = -100 +(random() * 200);
	this.velocity_y = -100 +(random() * 200);

	// removal is already set
	this.nextthink = time + 360;
}

void td_DropHealth(entity from, entity this, string item)
{
	this.classname = "item_health";
	this.noalign = true;
	this.flags = FL_ITEM;
	this.solid = SOLID_TRIGGER;
	settouch(this, horde_health_touch);
	set_movetype(this, MOVETYPE_TOSS);
	this.isloot = true;

	switch(item)
	{
		default:
		case "health10":
		{
			this.mdl = "maps/b_bh10.bsp";
			this.noise = "items/r_item1.wav";
			this.healamount = 15;
			this.healtype = 0;
			if(IsMCJMap() && fexists("maps/b_bh10_simple.bsp"))
			{
				this.mdl = "maps/b_bh10_simple.bsp";
				this.noise = "items/burp.wav";
			}
			break;
		}
		case "health25":
		{
			this.mdl = "maps/b_bh25.bsp";
			this.noise = "items/health1.wav";
			this.healamount = 25;
			this.healtype = 1;
			if(IsMCJMap() && fexists("maps/b_bh25_simple.bsp"))
			{
				this.mdl = "maps/b_bh25_simple.bsp";
				this.noise = "items/burp.wav";
			}
			break;
		}
		case "health100":
		{
			this.mdl = "maps/b_bh100.bsp";
			this.noise = "items/r_item2.wav";
			this.healamount = 100;
			this.healtype = 2;
			if(IsMCJMap() && fexists("maps/b_bh100_simple.bsp"))
			{
				this.mdl = "maps/b_bh100_simple.bsp";
				this.noise = "items/burp.wav";
			}
			break;
		}
	}

	traceline(from.origin, from.origin - '0 0 24', MOVE_NORMAL, from);
	setorigin(this, trace_endpos);

	precache_sound(this.noise);
	precache_model(this.mdl);
	_setmodel(this, this.mdl);
	setsize(this, '0 0 0', '32 32 56');

	this.velocity_z = 300;
	this.velocity_x = -100 +(random() * 200);
	this.velocity_y = -100 +(random() * 200);

	// removal is already set
	this.nextthink = time + 360;
}

void td_DropItem(entity this)
{
	// make a temporary entity that we can add our stuff to without affecting the monster
	entity targ = spawn();
	targ.spawnfunc_checked = true;
	targ.classname = "lootbox";
	setorigin(targ, this.origin);
	setthink(targ, SUB_Remove);
	targ.nextthink = time;

	string item = td_GetLoot(td_ent);
	Weapon wep = Weapon_from_name(item);

	if(wep != WEP_Null)
	{
		Inventory_new(targ);
		Inventory_add(wep, targ, ITEM_OWNED);
	}
	else
	{
		switch(item)
		{
			default: return; // not valid
			case "ammo_shells": targ.ammo_shells = 20; break;
			case "ammo_nails": targ.ammo_nails = 50; break;
			case "ammo_nails": targ.ammo_rockets = 10; break;
			case "ammo_cells": targ.ammo_cells = 20; break;
			case "ammo_lava_nails": targ.ammo_lava_nails = 50; break;
			case "ammo_multi_rockets": targ.ammo_multi_rockets = 10; break;
			case "ammo_plasma": targ.ammo_plasma = 20; break;
			case "ammo_drills": targ.ammo_drills = 10; break;
			// armor drops
			case "armor1":
			case "armor2":
			case "armorInv":
			case "armor_mage":
			case "armor_tech":
			case "armor_heavy":
			{
				td_DropArmor(this, targ, item);
				return; // no regular item
			}
			case "health10":
			case "health25":
			case "health100":
			{
				td_DropHealth(this, targ, item);
				return; // no regular item
			}
		}
	}

	DropBackpack(targ);
}

void td_MonsterDies(entity targ, entity attacker)
{
	float mhealth = (targ.max_health > 0) ? targ.max_health : 40;

	float fuel = max(10, mhealth * 0.25);

	td_DropFuel(targ, fuel, NULL, false);

	if(random() < 0.15) // TODO: custom chances
		td_DropItem(targ);

	// TODO: shouldn't this be above the dropping of items?!
	if(targ.flags & FL_CLONE)
		return;

	// update rankings
	if(td_rankings)
	{
		td_rankings.cnt += 1;
		td_rankings.SendFlags |= TD_RANKINGS_KILLED;
	}

	if(IS_PLAYER(attacker))
	{
		attacker.score_playerkills += 1;
		// TODO: only count final wave boss kills?
		if(targ.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
			attacker.score_bosskilled += 1;
	}
	else if(attacker.turretdef && IS_PLAYER(attacker.realowner))
		attacker.realowner.score_turretkills += 1;
}

float td_GetMonsterSpeed(entity this, float dist)
{
	if(this.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
		return 1;
	if(!td_ent)
		return 1;
	// incase of no scale, we just go by difficulty
	if(td_ent.scale <= 0)
		return (0.5 + td_skill * ((1.2 - 0.3) / 2.5));

	// only 10% boost per wave!
	// we also bound it as Quake may break if speed is too high
	float myscale = td_ent.scale * 0.04;
	return bound(1, 1 * (1 + (myscale * (td_skill + 1)) * td_ent.wave), 5);
}

void td_BuildMode_Clear(entity this)
{
	STAT(TD_BUILDMODE, this) = 0;
	STAT(TD_TURRET, this) = 0;
}

void td_BuildMode_Toggle(entity this)
{
	if(this.m_transform)
		return;
	if(this.health < 1)
		return;
	if(STAT(CANNON, this) || STAT(SKATING, this) || STAT(SLIDE_ON, this) || this.tank || this.clockwork)
		return;

	int buildmode = STAT(TD_BUILDMODE, this);
	buildmode += 1;
	if(buildmode > 2)
		buildmode = 0;
	STAT(TD_BUILDMODE, this) = buildmode;

	msg_entity = this;

	switch(buildmode)
	{
		case 0: soundto(MSG_ONE, this, CH_INFO, "td/buildmode0.wav", 1, ATTN_NONE); break;
		case 1: soundto(MSG_ONE, this, CH_INFO, "td/buildmode1.wav", 1, ATTN_NONE); break;
		case 2: soundto(MSG_ONE, this, CH_INFO, "td/buildmode2.wav", 1, ATTN_NONE); break;
	}

	// TODO: always reset turret?
	STAT(TD_TURRET, this) = 0;
}

void td_RemovePlayer(entity this)
{
	if(intermission_running || gameover)
		return;

	STAT(TD_BUILDMODE, this) = false;
	float amount = STAT(TD_FUEL, this);
	if(td_phase == TD_PHASE_COMBAT)
		amount *= 0.5; // only half if you leave in combat!
	if(amount > 0)
		td_DropFuel(this, amount, this, false);

	STAT(TD_FUEL, this) = 0;
}

void td_PlayerDies(entity this)
{
	if(intermission_running || gameover)
		return;
	if(td_phase != TD_PHASE_COMBAT)
		return;

	STAT(TD_BUILDMODE, this) = false;
	float amount = STAT(TD_FUEL, this) * 0.5;
	if(amount > 0)
		td_DropFuel(this, amount, this, false);

	STAT(TD_FUEL, this) = 0;
}

void td_PutPlayerInServer(entity this)
{
	STAT(TD_BUILDMODE, this) = false;
	//STAT(TD_FUEL, this) = 0;
}
