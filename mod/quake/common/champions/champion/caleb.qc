#include "caleb.qh"

bool Caleb_bloodrage_max()
{
	int bloodmax = BLOODRAGE_MAX;
	// enable for horde-specific higher limit
	//if(STAT(HORDE))
		//return ceil(bloodmax * 2);
	return bloodmax;
}

#ifdef SVQC
string Caleb_crazy_randomquip()
{
	RandomSelection_Init();
	RandomSelection_AddString("quips/1001.wav", 1, 1);
	RandomSelection_AddString("quips/1008.wav", 1, 1);
	RandomSelection_AddString("quips/1012.wav", 1, 1);
	RandomSelection_AddString("quips/1014.wav", 1, 1);
	RandomSelection_AddString("quips/1017.wav", 1, 1);
	RandomSelection_AddString("quips/1018.wav", 1, 1);
	RandomSelection_AddString("quips/1019.wav", 1, 1);
	RandomSelection_AddString("quips/1021.wav", 1, 1);
	RandomSelection_AddString("quips/1022.wav", 1, 1);
	RandomSelection_AddString("quips/1023.wav", 1, 1);
	RandomSelection_AddString("quips/1024.wav", 1, 1);
	RandomSelection_AddString("quips/1025.wav", 1, 1);
	RandomSelection_AddString("quips/1027.wav", 1, 1);
	RandomSelection_AddString("quips/1028.wav", 1, 1);
	RandomSelection_AddString("quips/1029.wav", 1, 1);
	RandomSelection_AddString("quips/1030.wav", 1, 1);
	RandomSelection_AddString("quips/1031.wav", 1, 1);
	RandomSelection_AddString("quips/1032.wav", 1, 1);
	RandomSelection_AddString("quips/1033.wav", 1, 1);
	RandomSelection_AddString("quips/1034.wav", 1, 1);
	RandomSelection_AddString("quips/1035.wav", 1, 1);
	RandomSelection_AddString("quips/1036.wav", 1, 1);
	RandomSelection_AddString("quips/1037.wav", 1, 1);
	RandomSelection_AddString("quips/1038.wav", 1, 1);
	RandomSelection_AddString("quips/1039.wav", 1, 1);
	RandomSelection_AddString("quips/1040.wav", 1, 1);
	RandomSelection_AddString("quips/1041.wav", 1, 1);
	RandomSelection_AddString("quips/1042.wav", 1, 1);
	RandomSelection_AddString("quips/1043.wav", 1, 1);
	RandomSelection_AddString("quips/1044.wav", 1, 1);
	RandomSelection_AddString("quips/1045.wav", 1, 1);
	RandomSelection_AddString("quips/1046.wav", 1, 1);
	RandomSelection_AddString("quips/1048.wav", 1, 1);
	RandomSelection_AddString("quips/1049.wav", 1, 1);
	RandomSelection_AddString("quips/1050.wav", 1, 1);
	RandomSelection_AddString("quips/1051.wav", 1, 1);
	RandomSelection_AddString("quips/1052.wav", 1, 1);
	RandomSelection_AddString("quips/1053.wav", 1, 1);
	RandomSelection_AddString("quips/1054.wav", 1, 1);
	RandomSelection_AddString("quips/1055.wav", 1, 1);
	RandomSelection_AddString("quips/1056.wav", 1, 1);
	RandomSelection_AddString("quips/1057.wav", 1, 1);
	RandomSelection_AddString("quips/1059.wav", 1, 1);
	RandomSelection_AddString("quips/1060.wav", 1, 1);
	RandomSelection_AddString("quips/1061.wav", 1, 1);
	RandomSelection_AddString("quips/1062.wav", 1, 1);
	RandomSelection_AddString("quips/1063.wav", 1, 1);
	RandomSelection_AddString("quips/1064.wav", 1, 1);
	RandomSelection_AddString("quips/1065.wav", 1, 1);
	RandomSelection_AddString("quips/1066.wav", 1, 1);
	RandomSelection_AddString("quips/1068.wav", 1, 1);
	RandomSelection_AddString("quips/1069.wav", 1, 1);
	RandomSelection_AddString("quips/1070.wav", 1, 1);
	RandomSelection_AddString("quips/1071.wav", 1, 1);
	RandomSelection_AddString("quips/1072.wav", 1, 1);
	RandomSelection_AddString("quips/1073.wav", 1, 1);
	RandomSelection_AddString("quips/1074.wav", 1, 1);
	RandomSelection_AddString("quips/1075.wav", 1, 1);
	RandomSelection_AddString("quips/1076.wav", 1, 1);
	RandomSelection_AddString("quips/1077.wav", 1, 1);
	RandomSelection_AddString("quips/1078.wav", 1, 1);
	RandomSelection_AddString("quips/1079.wav", 1, 1);
	RandomSelection_AddString("quips/1080.wav", 1, 1);
	RandomSelection_AddString("quips/1081.wav", 1, 1);
	RandomSelection_AddString("quips/1082.wav", 1, 1);
	RandomSelection_AddString("quips/1083.wav", 1, 1);
	RandomSelection_AddString("quips/1084.wav", 1, 1);
	RandomSelection_AddString("quips/2112.wav", 1, 1);
	return RandomSelection_chosen_string;
}

void Caleb_crazy_reset(entity this)
{
	this.caleb_crazy_time = time + 10 + (random() * 15);
}

void Caleb_bloodrage_clear(entity this)
{
	STAT(QCC_BLOODRAGE, this) = 0;
	STAT(QCC_BLOODRAGE_COUNT, this) = 0;
	this.bloodrage_time = 0;
	this.bloodrage_heartbeat = 0;
}

void Caleb_bats_think(entity this)
{
	if(!this.owner || this.owner.caleb_bats != this || this.owner.m_champion != CHAMPION_Caleb || 
			this.owner.health <= 0 || time > STAT(QCC_ABILITYTIME, this.owner) || gameover || intermission_running)
	{
		if(this.owner.caleb_bats == this)
		{
			stopsound(this.owner, CH_PLAYER_SINGLE);
			this.owner.caleb_bats = NULL;
		}
		delete(this);
		return;
	}
	this.nextthink = time;

	if(time < this.count)
		return;
	this.count = time + 0.5;

	entity player = this.owner;
	FOREACH_ENTITY_RADIUS(player.origin, 250, IS_MONSTER(it) && !it.charmed && it.health > 0 && 
							!(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD) && checkpvs(player.origin, it),
	{
		float oldhealth = it.health;
		T_Damage(it, this, this.owner, 5, DEATH_TRAP.m_id);
		float hpamount = oldhealth - it.health;
		if(hpamount > 0)
		{
			Send_Effect(EFFECT_QCC_BLOODTRAIL, it.origin, player.origin, 1);
			T_Heal(player, hpamount, false);
		}
	});
}

void Caleb_bats_summon(entity this)
{
	if(!this.caleb_bats)
		this.caleb_bats = new(bats);
	entity bats = this.caleb_bats;
	bats.owner = this;
	_setmodel(bats, "progs/bats.mdl");
	setsize(bats, '0 0 0', '0 0 0');
	//setattachment(bats, this, "");
	SetMovetypeFollow(bats, this);
	//setorigin(bats, this.origin);
	bats.effects = EF_LOWPRECISION | EF_NOSHADOW;
	setthink(bats, Caleb_bats_think);
	bats.nextthink = time;
}

METHOD(Caleb, m_activate, void(Champions this, entity actor))
{
	// make sure there isn't a sound as soon as he starts, gotta build up the crazy!
	Caleb_crazy_reset(actor);

	RandomSelection_Init();
	RandomSelection_AddString("mutter/3004b.wav", 1, 1);
	RandomSelection_AddString("mutter/3010.wav", 1, 1);
	RandomSelection_AddString("mutter/3018b.wav", 1, 1);
	RandomSelection_AddString("mutter/3023a.wav", 1, 1);
	RandomSelection_AddString("mutter/3027.wav", 1, 1);
	RandomSelection_AddString("mutter/3031.wav", 1, 1);
	RandomSelection_AddString("mutter/3038.wav", 1, 1);
	player_sound(actor, CH_VOICE, RandomSelection_chosen_string, ATTN_NORM);
}

METHOD(Caleb, m_playerthink, void(Champions this, entity actor))
{
	if(STAT(QCC_BLOODRAGE, actor))
	{
		Caleb_crazy_reset(actor); // no crazy while this is going on!
		if(time > actor.bloodrage_time)
		{
			STAT(QCC_BLOODRAGE_COUNT, actor) = max(-1, STAT(QCC_BLOODRAGE_COUNT, actor) - 1);
			if(STAT(QCC_BLOODRAGE_COUNT, actor) < 0)
			{
				T_Damage(actor, NULL, NULL, 4000, DEATH_GENERIC.m_id);
				return;
			}
			actor.bloodrage_time = time + 5;
		}

		if(time > actor.bloodrage_heartbeat)
		{
			player_sound(actor, CH_VOICE, "heartbeat.wav", ATTN_NORM);
			actor.bloodrage_heartbeat = time + 1.8;
		}
	}

	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		Caleb_crazy_reset(actor);
		string mutter = "";
		float mutter_rand = random();
		if(mutter_rand < 0.333)
			mutter = "mutter/3001b.wav";
		else if(mutter_rand < 0.666)
			mutter = "mutter/3004b.wav";
		else
			mutter = "mutter/3012.wav";
		player_sound(actor, CH_VOICE, mutter, ATTN_NORM);
		_sound(actor, CH_PLAYER_SINGLE, "player_caleb/bats.wav", 1, ATTN_NORM);
		Send_Effect(EFFECT_SMOKE_LARGE, actor.origin, '0 0 0', 1);
		STAT(QCC_ABILITYTIME, actor) = time + 10;
		Caleb_bats_summon(actor);
	}

	if(time > actor.caleb_crazy_time)
	{
		Caleb_crazy_reset(actor);
		if(random() > 0.5)
		{
			float rsound = 1109 + rint(random() * 7);
			string s = strcat("play", ftos(rsound), ".wav");
			player_sound(actor, CH_VOICE, s, ATTN_NORM);
		}
		else
			player_sound(actor, CH_VOICE, Caleb_crazy_randomquip(), ATTN_NORM);
	}
}

METHOD(Caleb, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && STAT(QCC_BLOODRAGE, attacker) && IS_MONSTER(targ))
	{
		STAT(QCC_BLOODRAGE_COUNT, attacker) += 1;
		attacker.bloodrage_time = time + 5;
		if(STAT(QCC_BLOODRAGE_COUNT, attacker) >= Caleb_bloodrage_max())
		{
			attacker.health = max(100, attacker.health);
			player_sound(attacker, CH_VOICE, "quips/1024.wav", ATTN_NORM);
			Caleb_bloodrage_clear(attacker);
		}
	}
}

METHOD(Caleb, m_clear, void(Champions this, entity actor))
{
	Caleb_bloodrage_clear(actor);

	if(actor.caleb_bats)
	{
		stopsound(actor, CH_PLAYER_SINGLE);
		delete(actor.caleb_bats);
	}
	actor.caleb_bats = NULL;
}

METHOD(Caleb, m_damage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	bool dont_ignore = (deathtype != DEATH_VOID.m_id && deathtype != DEATH_HURTTRIGGER.m_id && 
		deathtype != DEATH_KILL.m_id && deathtype != DEATH_GENERIC.m_id && deathtype != DEATH_LAVA.m_id);
	if(targ.m_champion == this && targ.health > 0 && dont_ignore)
	{
		if(STAT(QCC_BLOODRAGE, targ))
			return 0;
		if(coop && attacker != targ && IS_PLAYER(attacker) && IS_PLAYER(targ))
		{
			if(autocvar_g_friendlyfire_virtual)
				return 1;
		}
		if((targ.health - damage) < 1)
		{
			string quip = "";
			float r =  random();
			if(r < 0.33)
				quip = "quips/1034.wav";
			else if(r < 0.66)
				quip = "quips/1045.wav";
			else
				quip = "quips/1052.wav";

			player_sound(targ, CH_VOICE, quip, ATTN_NORM);
			STAT(QCC_BLOODRAGE, targ) = true;
			STAT(QCC_BLOODRAGE_COUNT, targ) = 0;
			targ.bloodrage_time = time + 5;
			targ.health = 1;
			return 0;
		}
	}
	return 1;
}
#endif

#ifdef CSQC
METHOD(Caleb, m_overlay, void(Champions this))
{
	if(!STAT(QCC_BLOODRAGE))
		return;
	if(intermission || STAT(HEALTH) == -666)
		return;

	int bloodmax = Caleb_bloodrage_max();
	vector iconpos = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
	iconpos += '0 64 0'; // below crosshair slightly
	iconpos -= '64 0 0' * floor(bloodmax * 0.5); // also center
	for(int j = 1; j <= bloodmax; ++j)
	{
		float ofs = (64 * (j - 1));
		bool isfilled = (STAT(QCC_BLOODRAGE_COUNT) >= j);
		drawpic(iconpos + ('1 0 0' * ofs), "gfx/quake/bloodstrike", '32 32 0', ((isfilled) ? '1 1 1' : '0.1 0.1 0.1'), ((isfilled) ? 1 : 0.5), DRAWFLAG_NORMAL);
	}

	drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '1 0 0', 0.25 + bound(0, 0.25 * sin(4 * time), 0.05), DRAWFLAG_NORMAL);
}
#endif
