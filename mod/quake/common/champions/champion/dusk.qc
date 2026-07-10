#include "dusk.qh"

#ifdef SVQC
bool Dusk_Reap_Monster(entity this, entity targ)
{
	vector org = targ.origin + (targ.mins + targ.maxs) * 0.5;
	te_explosion2(org, 2, 7);
	targ.dusk_revived = true;
	entity newmon = spawn();
	newmon.classname = "monster";
	newmon.variant = targ.variant;
	newmon.spawnflags = targ.spawnflags;
	newmon.spawn_time = time;
	newmon = horn_spawnmonster(newmon, targ.origin, this, targ.monsterdef);
	if(newmon)
	{
		newmon.dusk_revived = true;
		newmon.health = min(200, newmon.health);
	}
	delete(targ);
	return true;
}

bool Dusk_Reap_Item(entity this, entity targ)
{
	if(time >= this.nextthink)
		return false;
	if(targ.dusk_revived)
		return false;
	if(targ.solid != SOLID_NOT)
		return false;
	if(targ.classname == "")
		return false; // probably a sigil, no touchy!
	if(targ.powerups)
		return false; // lol no
	if(targ.healamount)
		return false; // no reviving health!
	vector org = (targ.absmin + targ.absmax) * 0.5;
	te_explosion2(org, 2, 7);
	setthink(targ, SUB_regen);
	targ.nextthink = time;
	targ.dusk_revived = true;

	return true;
}

void Dusk_Reap(entity this)
{
	vector org = this.origin + (this.mins + this.maxs) * 0.5;
	te_explosion2(org, 0, 5);

	float reap_range = 300;
	bool found = false;
	FOREACH_ENTITY_RADIUS(org, reap_range, true,
	{
		if(it.flags & FL_ITEM)
			found += Dusk_Reap_Item(this, it);
		else if(it.classname == "dusk_wisp" && it.monsterdef)
			found += Dusk_Reap_Monster(this, it);
	});

	if(found)
	{
		STAT(QCC_ABILITYTIME, this) = time + 5;
		player_sound(this, CH_WEAPON_B, "fastfire.wav", ATTN_NORM);
		T_Damage(this, this, NULL, 25, DEATH_GENERIC.m_id);
	}
	else
	{
		STAT(QCC_ABILITYTIME, this) = time + 1;
		player_sound(this, CH_WEAPON_B, "fastfirestart.wav", ATTN_NORM);
	}
}

bool wisp_customize(entity this, entity client)
{
	return (client.m_champion == CHAMPION_Dusk);
}

void wisp_think(entity this)
{
	if(time > this.wait)
	{
		SUB_SetFade(this, time + 0.1, 1);
		return;
	}

	this.nextthink = time;
	// taken from item code
	float bobheight = 3 + 2 * sin((time - this.spawn_time) * 2);
	vector oldorg = this.pos1;
	if(bobheight != this.origin_z - oldorg.z)
		this.origin_z = oldorg.z + bobheight;
}

void Dusk_MakeWisp(entity targ)
{
	entity wisp = spawn();
	wisp.classname = "dusk_wisp";
	wisp.solid = SOLID_TRIGGER;
	_setmodel(wisp, "progs/wisp.mdl");
	setsize(wisp, '0 0 0', '0 0 0');
	set_movetype(wisp, MOVETYPE_NONE);
	setorigin(wisp, targ.origin);
	wisp.spawn_time = time;
	wisp.pos1 = targ.origin;
	wisp.wait = time + 10;
	wisp.alpha = 0.65;
	wisp.nextthink = time;
	wisp.avelocity = '0 45 0';
	wisp.effects = (EF_FULLBRIGHT | EF_ADDITIVE);
	wisp.spawnflags = targ.spawnflags;
	wisp.variant = targ.variant;
	setthink(wisp, wisp_think);
	wisp.monsterdef = targ.monsterdef;
	setcefc(wisp, wisp_customize);
}

METHOD(Dusk, m_activate, void(Dusk this, entity actor))
{
	player_sound(actor, CH_VOICE, "sicklestart.wav", ATTN_NORM);

	actor.skin = bound(0, (etof(actor) % 6) - 1, 5);
}

METHOD(Dusk, m_playerspawn, void(Champions this, entity actor))
{
	actor.skin = bound(0, (etof(actor) % 6) - 1, 5);
}

.float dusk_cleanup;
METHOD(Dusk, m_playerthink, void(Dusk this, entity actor))
{
	if(!IS_PLAYER(actor))
		return;

	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor) && actor.health > 25)
		Dusk_Reap(actor);

	if(time >= actor.dusk_cleanup)
	{
		actor.dusk_cleanup = time + 0.1;
		int moncount = 0;
		entity chosen = NULL;
		float chosen_time = 0;
		FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
		{
			float mytime = time - it.spawn_time;
			if(it.health > 0 && it.charmed && it.charmer == actor && it.dusk_revived)
			{
				moncount += 1;
				if(!chosen || mytime >= chosen_time)
				{
					chosen = it;
					chosen_time = mytime;
				}
			}
		});

		if(moncount > 10 && chosen)
			T_Damage(chosen, NULL, NULL, chosen.health + chosen.max_health, DEATH_GENERIC.m_id);
	}
}

METHOD(Dusk, m_clear, void(Dusk this, entity actor))
{
	FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
	{
		if(it.charmed && it.charmer == actor && it.dusk_revived && it.health > 20)
			it.health = 20;
	});
}

void Dusk_Killed(entity targ, entity inflictor, entity attacker, int deathtype)
{
	if(!IS_MONSTER(targ) || targ.monsterdef == MON_Null || !targ.monsterdef || (targ.monsterdef.spawnflags & MONSTER_TYPE_DECOY) || (targ.monsterdef.spawnflags & MON_FLAG_PART) || targ.charmed)
		return;
	if(targ.monsterdef == MON_TENTACLE)
		return; // TODO: "can't be spawned" flag?
	Dusk_MakeWisp(targ);
}

// logic copied from Xonotic's spawn near teammates mutator
vector snt_ofs[6];
void Dusk_PlayerSpawn(entity player)
{
	if(gametype == GAMETYPE_HORDE || deathmatch)
		return;
	if(gametype == GAMETYPE_SKATE || gametype == GAMETYPE_SLIDE || gametype == GAMETYPE_DODGEBALL)
		return;

	FOREACH_CLIENT_RANDOM(IS_PLAYER(it) && it.m_champion == CHAMPION_Dusk, {
		if (it.health < 1) continue;
		if (it == player) continue;

		//vector horiz_vel = vec2(it.velocity);
		// when walking slowly sideways, we assume the player wants a clear shot ahead - spawn behind them according to where they're looking
		// when running fast, spawn behind them according to their direction of movement to prevent colliding with the newly spawned player
		vector forward = '0 0 0'; vector right = '0 0 0'; vector up = '0 0 0';
		//if (vdist(horiz_vel, >, autocvar_sv_maxspeed + 50))
		//{
		//	FIXED_MAKE_VECTORS(vectoangles(horiz_vel), forward, right, up);
		//}
		//else
		//{
			FIXED_MAKE_VECTORS(it.angles, forward, right, up);
		//}

		// test different spots close to mate - trace upwards so it works on uneven surfaces
		// don't spawn in front of player or directly behind to avoid players shooting each other
		// test the potential spots in pairs (first pair is better than second and so on) but don't prefer one side
		snt_ofs[0] = up * 64 + right * 128 - forward * 64;
		snt_ofs[1] = up * 64 - right * 128 - forward * 64;
		snt_ofs[2] = up * 64 + right * 192;
		snt_ofs[3] = up * 64 - right * 192;
		snt_ofs[4] = up * 64 + right * 64 - forward * 128;
		snt_ofs[5] = up * 64 - right * 64 - forward * 128;
		RandomSelection_Init();
		for(int i = 0; i < 6; ++i)
		{
			tracebox(it.origin, VEC_HULL_MIN, VEC_HULL_MAX, it.origin + snt_ofs[i], MOVE_NOMONSTERS, it);

			vector horizontal_trace_endpos = trace_endpos;
			//te_lightning1(NULL, it.origin, horizontal_trace_endpos);
			if (trace_fraction != 1.0) goto skip;

			// 400 is about the height of a typical laser jump (in overkill)
			// not traceline because we need space for the whole player, not just their origin
			tracebox(horizontal_trace_endpos, VEC_HULL_MIN, VEC_HULL_MAX, horizontal_trace_endpos - 400 * up, MOVE_NORMAL, it);
			vector vectical_trace_endpos = trace_endpos;
			//te_lightning1(NULL, horizontal_trace_endpos, vectical_trace_endpos);
			if (trace_startsolid) goto skip; // inside another player
			if (trace_fraction == 1.0) goto skip; // above void or too high
			if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY) goto skip;
			if (pointcontents(vectical_trace_endpos) != CONTENT_EMPTY) goto skip; // no lava or slime (or water which i assume would be annoying anyway)

			// make sure the spawned player will have floor ahead (or at least a wall - they shouldn't fall as soon as they start moving)
			// top front of player's bbox - highest point we know is not inside solid
			vector floor_test_start = vectical_trace_endpos + up * VEC_HULL_MAX.z + forward * VEC_HULL_MAX.x; 
			traceline(floor_test_start, floor_test_start + forward * 100 - up * 128, MOVE_NOMONSTERS, it);
			//te_beam(NULL, floor_test_start, trace_endpos);
			if (trace_fraction == 1.0) goto skip;

			// here, we know we found a good spot
			RandomSelection_Add(it, 0, string_null, vectical_trace_endpos, 1, 1);
			//te_lightning1(NULL, vectical_trace_endpos, vectical_trace_endpos + forward * 10);

			LABEL(skip)
			if (i % 2 == 1 && RandomSelection_chosen_ent)
			{
				setorigin(player, RandomSelection_chosen_vec);
				player.angles = RandomSelection_chosen_ent.angles;
				player.angles_z = 0; // never spawn tilted even if the spot says to
				break;
			}
		}
	});
}
#endif

#ifdef CSQC
METHOD(Dusk, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/dusk_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
