#include "jester_wheel.qh"

#ifdef GAMEQC
int wheel_getcombo(int s1, int s2, int s3)
{
	int crystals = 0;
	int goblins = 0;
	int swords = 0;
	int potions = 0;
	int mana = 0;

#define SLOTS(x,cnter) \
	if(s1 == (x)) ++cnter; \
	if(s2 == (x)) ++cnter; \
	if(s3 == (x)) ++cnter;

	SLOTS(SLOT_CRYSTAL,crystals)
	SLOTS(SLOT_GOBLIN,goblins)
	SLOTS(SLOT_SWORD,swords)
	SLOTS(SLOT_POTION,potions)
	SLOTS(SLOT_MANA,mana)
#undef SLOTS

	if(goblins == 3)
		return COMBO_GOLDEN_ENEMIES;
	if(crystals == 2 && goblins == 1)
		return COMBO_BUFF_ENEMIES;
	if(mana == 2 && goblins == 1)
		return COMBO_DOWNGRADE_TOWER;
	if(mana == 2 && swords == 1)
		return COMBO_UNABLE_REPAIR;
	if(mana == 2 && potions == 1)
		return COMBO_SPEED_ENEMIES;
	if(mana == 2 && crystals == 1)
		return COMBO_RANDOM_TELEPORT;
	if(potions == 2 && goblins == 1)
		return COMBO_DAMAGE_CORE;
	if(goblins == 2 && crystals == 1)
		return COMBO_DEBUFF_ENEMIES;
	if(crystals == 3)
		return COMBO_BUFF_PLAYERS;
	if(swords == 3)
		return COMBO_DAMAGE_ENEMIES;
	if(swords == 2 && crystals == 1)
		return COMBO_KILL_ENEMIES;
	if(goblins == 2 && potions == 1)
		return COMBO_STUN_ENEMIES;
	if(potions == 2 && mana == 1)
		return COMBO_SLOW_MOTION;
	if(mana == 3)
		return COMBO_UPGRADE_TOWER;
	if(potions == 3)
		return COMBO_HEAL_ALLIES;
	if(potions == 2 && swords == 1)
		return COMBO_SLOW_ENEMIES;
	if(swords == 2 && potions == 1)
		return COMBO_JUMP_BOOST;
	if(potions == 2 && crystals == 1)
		return COMBO_HEAL_CORE;
	return COMBO_NONE;
}
#endif

#ifdef SVQC
PRECACHE(Wheel)
{
	precache_sound("player_jester/slots_slowmo.wav");
	precache_sound("player_jester/slots_slowmo_reset.wav");
	precache_sound("player_jester/slots_downgradetowers.wav");

	precache_sound("td/upgrade.wav");
}

bool wheel_heal(entity toucher)
{	
	if(toucher.tank)
		return false;
	if(toucher.clockwork)
		return false;
	if(toucher.m_transform)
		return false;
	
	float healing = (IS_PLAYER(toucher) ? 50 : toucher.max_health * 0.45);
	if(!T_Heal(toucher, max(1, floor(healing)), IS_PLAYER(toucher)))
		return false;

	toucher.healthrot_nextcheck = time + 2;

	if(IS_TURRET(toucher))
		toucher.SendFlags |= TNSF_STATUS;

	if(toucher.sprite)
		WaypointSprite_UpdateHealth(toucher.sprite, toucher.health);
	
	// health touch sound
	//_sound(toucher, CH_TRIGGER_SINGLE, "items/r_item1.wav", 1, ATTN_NORM);

	//particle(toucher.origin, '0 0 0', 26, 32);
	Send_Effect(EFFECT_RUNE_HEAL, (toucher.absmin + toucher.absmax) * 0.5, '0 0 0', 1);
	
	return true;
}

entity slowmo_marker;
void wheel_slowmo_reset_done(entity this)
{
	cvar_set("slowmo", ftos(this.cnt));
	delete(this);
	slowmo_marker = NULL;
}

void wheel_slowmo_reset(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, "player_jester/slots_slowmo_reset.wav", VOL_BASE, ATTEN_NONE);
	cvar_set("slowmo", "0.75");
	setthink(this, wheel_slowmo_reset_done);
	this.nextthink = time + 1.5;
}

void wheel_slowmo_do(entity this)
{
	cvar_set("slowmo", "0.5");
	setthink(this, wheel_slowmo_reset);
	this.nextthink = time + 7;
}

void wheel_trigger(entity this, int combo)
{
	if(this.health < 1)
		return;

	switch(combo)
	{
		case COMBO_GOLDEN_ENEMIES:
		{
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				if(gametype == GAMETYPE_TD)
					it.is_golden = true; // persists until death
				float efftime = 60;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_Golden, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_Golden, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_BUFF_ENEMIES:
		{
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				float efftime = 30;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_JesterBuff, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_JesterBuff, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_DOWNGRADE_TOWER:
		{
			entity best = NULL;
			float best_dist = 0;
			IL_EACH(g_turrets, it.health > 0 && it.tur_level > 0,
			{
				float mydist = vlen2(it.origin - this.origin);
				if(!best || mydist < best_dist)
				{
					best = it;
					best_dist = mydist;
				}
			});

			if(best)
			{
				best.tur_level -= 2; // HACK: level up adds 1 back on and does the dirty work
				turret_levelup(best);
				Send_Effect(EFFECT_TURRET_LEVELDOWN, best.origin, '0 0 0', 1);
				_sound(best, CH_TRIGGER_SINGLE, "player_jester/slots_downgradetowers.wav", 1, ATTEN_NORM);
			}
			break;
		}
		case COMBO_UNABLE_REPAIR:
		{
			StatusEffects eff = STATUSEFFECT_NoRepairs;
			if(gametype != GAMETYPE_TD)
				eff = STATUSEFFECT_NoPickups;
			FOREACH_CLIENT(it.health > 0 && IS_PLAYER(it),
			{
				float efftime = 10;

				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(eff, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(eff, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_SPEED_ENEMIES:
		{
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				float efftime = 30;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_JesterSpeed, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_JesterSpeed, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_RANDOM_TELEPORT:
		{
			entity prev = NULL;
			FOREACH_CLIENT_RANDOM(IS_PLAYER(it),
			{
				if(!prev)
					prev = it;
				else
				{
					vector from = prev.origin;
					vector from_ang = prev.angles;
					vector to = it.origin;
					vector to_ang = it.angles;
					soundat(NULL, from, CH_TRIGGER, SND(TELE_RANDOM()), 1, ATTEN_NORM);
					soundat(NULL, to, CH_TRIGGER, SND(TELE_RANDOM()), 1, ATTEN_NORM);
					te_teleport(from);
					te_teleport(to);

					setorigin(it, from);
					it.angles = from_ang;
					it.fixangle = true;
					it.velocity = '0 0 0';
					it.oldvelocity = '0 0 0';
					it.oldorigin = it.origin;
					cannon_clear(it);
					UNSET_ONGROUND(it);
					setorigin(prev, to);
					prev.angles = to_ang;
					prev.fixangle = true;
					prev.velocity = '0 0 0';
					prev.oldvelocity = '0 0 0';
					prev.oldorigin = prev.origin;
					cannon_clear(prev);
					UNSET_ONGROUND(prev);

					prev = NULL; // the cycle continues
				}
			});
			break;
		}
		case COMBO_DAMAGE_CORE:
		{
			if(gametype == GAMETYPE_TD)
			{
				IL_EACH(g_td_towers, it.health > 100,
				{
					// hacky workaround to prevent dropping below 100 health
					it.health = max(101, it.health - (it.max_health * 0.25));
					T_Damage(it, NULL, NULL, 1, DEATH_GENERIC.m_id);
				});
			}
			else
			{
				IL_EACH(g_monsters, it.health > 0 && it.charmed,
				{
					T_Damage(it, NULL, NULL, 100, DEATH_GENERIC.m_id);
				});
			}
			break;
		}
		case COMBO_DEBUFF_ENEMIES:
		{
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				float efftime = 15;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_JesterDebuff, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_JesterDebuff, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_BUFF_PLAYERS:
		{
			FOREACH_CLIENT(it.health > 0 && IS_PLAYER(it),
			{
				float efftime = 30;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_JesterBuff, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_JesterBuff, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_DAMAGE_ENEMIES:
		{
			int moncount = 0;
			float fraction = (gametype == GAMETYPE_TD) ? 0.51 : 0.34;
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				float damage = (it.max_health > 0) ? it.max_health * fraction : it.health * fraction;
				// null attacker so they don't aggro
				T_Damage(it, NULL, NULL, damage, DEATH_GENERIC.m_id);
				moncount += 1;
				// way too OP outside of TD
				if(moncount > 10 && gametype != GAMETYPE_TD)
					break;
			});
			break;
		}
		case COMBO_KILL_ENEMIES:
		{
			int totalmonsters = 0;
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				totalmonsters += 1;
			});
			int killcount = (totalmonsters > 0) ? max(1, ceil(totalmonsters * 0.05)) : 0;
			if(killcount <= 0)
				break;
			for(int j = 0; j < killcount; ++j)
			{
				RandomSelection_Init();
				IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
				{
					RandomSelection_AddEnt(it, 1, 1);
				});
				T_Damage(RandomSelection_chosen_ent, this, this, RandomSelection_chosen_ent.health + RandomSelection_chosen_ent.max_health, DEATH_GENERIC.m_id);
			}
			break;
		}
		case COMBO_STUN_ENEMIES:
		{
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				float efftime = 5;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_Confused, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_Confused, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_SLOW_MOTION:
		{
			if(!slowmo_marker)
				slowmo_marker = new_pure(slowmo_marker);
			setthink(slowmo_marker, wheel_slowmo_do);
			slowmo_marker.nextthink = time + 2;
			slowmo_marker.cnt = autocvar_slowmo;
			cvar_settemp("slowmo", "0.75");
			_sound(slowmo_marker, CH_TRIGGER_SINGLE, "player_jester/slots_slowmo.wav", VOL_BASE, ATTEN_NONE);
			break;
		}
		case COMBO_UPGRADE_TOWER:
		{
			entity best = NULL;
			float best_dist = 0;
			IL_EACH(g_turrets, it.health > 0 && it.tur_level < 5,
			{
				float mydist = vlen2(it.origin - this.origin);
				if(!best || mydist < best_dist)
				{
					best = it;
					best_dist = mydist;
				}
			});

			if(best)
			{
				turret_levelup(best);
				Send_Effect(EFFECT_RUNE_FROST_REGEN, best.origin, '0 0 0', 1);
				_sound(best, CH_TRIGGER_SINGLE, "td/upgrade.wav", 1, ATTEN_NORM);
			}
			break;
		}
		case COMBO_HEAL_ALLIES:
		{
			IL_EACH(g_moveables, it.health > 0 && (IS_PLAYER(it) || IS_TURRET(it) || (IS_MONSTER(it) && it.charmed)),
			{
				if(it.exptime != 0)
					continue;
				if((IS_PLAYER(it) && it.health > 250) || (!IS_PLAYER(it) && it.max_health && it.health >= it.max_health))
					continue;

				wheel_heal(it);
			});
			break;
		}
		case COMBO_SLOW_ENEMIES:
		{
			IL_EACH(g_monsters, it.health > 0 && it.takedamage && !it.charmed && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
			{
				float efftime = 15;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_Slowness, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_Slowness, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_JUMP_BOOST:
		{
			FOREACH_CLIENT(it.health > 0 && IS_PLAYER(it),
			{
				float efftime = 15;
				// only add the effect if there isn't already a longer timer running!
				float curtime = StatusEffects_gettime(STATUSEFFECT_JesterJumpBoost, it);
				if((time + efftime) > curtime)
					StatusEffects_apply(STATUSEFFECT_JesterJumpBoost, it, time + efftime, 0);
			});
			break;
		}
		case COMBO_HEAL_CORE:
		{
			if(gametype == GAMETYPE_TD)
			{
				IL_EACH(g_td_towers, it.health < it.max_health,
				{
					it.health = min(it.health + (it.max_health * 0.41), it.max_health);
					if(it.sprite)
						WaypointSprite_UpdateHealth(it.sprite, it.health);
				});
			}
			else
			{
				IL_EACH(g_monsters, it.health > 0 && it.charmed,
				{
					wheel_heal(it);
				});
			}
			break;
		}
	}

	STAT(QCC_ABILITYTIME, this) = time + 33;

	//LOG_INFO("Invalid combo!");
}

NET_HANDLE(wheel, bool)
{
	int s1 = ReadByte();
	int s2 = ReadByte();
	int s3 = ReadByte();

	int combo = wheel_getcombo(s1, s2, s3);
	wheel_trigger(sender, combo);
	return true;
}

void wheel_start(entity this)
{
	if(!IS_REAL_CLIENT(this))
		return;

	td_BuildMode_Clear(this);

	msg_entity = this;
	WriteHeader(MSG_ONE, TE_CSQC_WHEEL);
	for(int j = 0; j < WHEEL_SLOTS; ++j)
	{
		WriteByte(MSG_ONE, floor(random() * WHEEL_ICONS));
	}
}
#endif

#ifdef CSQC
PRECACHE(Wheel)
{
	precache_pic("gfx/quake/wheel_background");
	precache_pic("gfx/quake/wheel_slots");
	precache_pic("gfx/quake/wheel_slots_classic");

	precache_sound("player_jester/slotmachine_loop.wav");
	precache_sound("player_jester/slotmachine_start.wav");
	precache_sound("player_jester/slotmachine_eachiconstop.wav");

	precache_sound("player_jester/slots_buffenemies.wav");
	precache_sound("player_jester/slots_buffenemies.wav");
	precache_sound("player_jester/slots_downgradetowers.wav");
	precache_sound("player_jester/slots_preventrepair.wav");
	precache_sound("player_jester/slots_buffenemies.wav");
	precache_sound("player_jester/slots_teleport.wav");
	precache_sound("player_jester/slots_damagecore.wav");
	precache_sound("player_jester/slots_debuffenemies.wav");
	precache_sound("player_jester/slots_buffallplayers.wav");
	precache_sound("player_jester/slots_hurtenemies.wav");
	precache_sound("player_jester/slots_killenemies.wav");
	precache_sound("player_jester/slots_debuffenemies.wav");
	precache_sound("player_jester/slots_slowmo.wav");
	precache_sound("player_jester/slots_upgradetower.wav");
	precache_sound("player_jester/slots_healallies.wav");
	precache_sound("player_jester/slots_debuffenemies.wav");
	precache_sound("player_jester/slots_buffallplayers.wav");
	precache_sound("player_jester/slots_healcore.wav");
	precache_sound("player_jester/slots_nomatch.wav");

	precache_sound("goatling/idle1.wav");

	registercvar("sbar_wheel_pos", "0.15 0.15");
	registercvar("sbar_wheel_size", "0.7 0.7");

	wheel_closetime = 0;
}

string wheel_gettext(int combo)
{
	switch(combo)
	{
		case COMBO_GOLDEN_ENEMIES: return "^1Golden Enemies";
		case COMBO_BUFF_ENEMIES: return "^1Buff Enemies";
		case COMBO_DOWNGRADE_TOWER: return "^1Downgrade Nearby Turret";
		case COMBO_UNABLE_REPAIR: return (gametype == GAMETYPE_TD) ? "^1Players Unable to Repair" : "^1Players Unable to Pick Up Items";
		case COMBO_SPEED_ENEMIES: return "^1Speed Up Enemies";
		case COMBO_RANDOM_TELEPORT: return "^5Random Player Teleport";
		case COMBO_DAMAGE_CORE: return (gametype == GAMETYPE_TD) ? "^1Damage Tower" : "^1Damage Pets";
		case COMBO_DEBUFF_ENEMIES: return "^2Debuff Enemies";
		case COMBO_BUFF_PLAYERS: return "^2Buff Players";
		case COMBO_DAMAGE_ENEMIES: return "^2Damage All Enemies";
		case COMBO_KILL_ENEMIES: return "^2Kill Portion Of Enemies";
		case COMBO_STUN_ENEMIES: return "^2Stun Enemies";
		case COMBO_SLOW_MOTION: return "^5Slow-Motion";
		case COMBO_UPGRADE_TOWER: return "^2Upgrade Nearest Turret";
		case COMBO_HEAL_ALLIES: return "^2Heal All Allies";
		case COMBO_SLOW_ENEMIES: return "^2Slow Down All Enemies";
		case COMBO_JUMP_BOOST: return "^2Jump Boost";
		case COMBO_HEAL_CORE: return (gametype == GAMETYPE_TD) ? "^2Heal Tower" : "^2Heal Pets";
	}
	return "^1No match!";
}

string wheel_endsound(int combo)
{
	switch(combo)
	{
		case COMBO_GOLDEN_ENEMIES: return (gametype == GAMETYPE_TD) ? "player_jester/slots_buffenemies.wav" : "goatling/idle1.wav";
		case COMBO_BUFF_ENEMIES: return "player_jester/slots_buffenemies.wav";
		case COMBO_DOWNGRADE_TOWER: return "player_jester/slots_downgradetowers.wav";
		case COMBO_UNABLE_REPAIR: return "player_jester/slots_preventrepair.wav";
		case COMBO_SPEED_ENEMIES: return "player_jester/slots_buffenemies.wav";
		case COMBO_RANDOM_TELEPORT: return "player_jester/slots_teleport.wav";
		case COMBO_DAMAGE_CORE: return "player_jester/slots_damagecore.wav";
		case COMBO_DEBUFF_ENEMIES: return "player_jester/slots_debuffenemies.wav";
		case COMBO_BUFF_PLAYERS: return "player_jester/slots_buffallplayers.wav";
		case COMBO_DAMAGE_ENEMIES: return "player_jester/slots_hurtenemies.wav";
		case COMBO_KILL_ENEMIES: return "player_jester/slots_killenemies.wav";
		case COMBO_STUN_ENEMIES: return "player_jester/slots_debuffenemies.wav";
		case COMBO_SLOW_MOTION: return "player_jester/slots_slowmo.wav";
		case COMBO_UPGRADE_TOWER: return "player_jester/slots_upgradetower.wav";
		case COMBO_HEAL_ALLIES: return "player_jester/slots_healallies.wav";
		case COMBO_SLOW_ENEMIES: return "player_jester/slots_debuffenemies.wav";
		case COMBO_JUMP_BOOST: return "player_jester/slots_buffallplayers.wav";
		case COMBO_HEAL_CORE: return "player_jester/slots_healcore.wav";
	}
	return "player_jester/slots_nomatch.wav";
}

void wheel_finish()
{
	for(int j = 0; j < WHEEL_SLOTS; ++j)
	{
		wheel_slots[j] = 0;
		wheel_state[j] = 0;
		wheel_offset[j] = 0;
	}

	wheel_active = false;
	wheel_inputblock = 0;
	wheel_currentslot = 0;
	wheel_closetime = 0;

	if(wheel_sounds)
	{
		sound(wheel_sounds, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NONE);
		delete(wheel_sounds);
		wheel_sounds = NULL;
	}
}

void drawpic_scrolling(vector pos, vector icon_size, string pic, float scroll, vector col, float alph, int dflag)
{
	vector pz = drawgetimagesize(pic);
	if(pz == '0 0 0')
		return;

	vector aspect = '0 0 0';
	aspect.x = icon_size.x;
	aspect.y = icon_size.y / pz.y;

	float yaspect = (icon_size.y / icon_size.x) * (pz.x / pz.y);

	float left = 0;
	float right = 1;

	float top = scroll;
	float bottom = top + yaspect;

	R_BeginPolygon(pic, dflag, true);
	R_PolygonVertex(pos, vec2(left, top), col, alph);
	R_PolygonVertex(pos + vec2(icon_size.x, 0), vec2(right, top), col, alph);
	R_PolygonVertex(pos + icon_size, vec2(right, bottom), col, alph);
	R_PolygonVertex(pos + vec2(0, icon_size.y), vec2(left, bottom), col, alph);
	R_EndPolygon();
}

void HUD_Wheel()
{
	// nopity
	if(intermission || STAT(HEALTH) <= 0 || STAT(TD_PHASE) == TD_PHASE_WIN || STAT(TD_PHASE) == TD_PHASE_LOSE)
	{
		wheel_finish();
		return;
	}

	if(wheel_closetime != 0 && time >= wheel_closetime)
	{
		wheel_finish();
		return;
	}

	if(!wheel_active && time >= wheel_closetime)
		return;

	vector panel_pos = stov(cvar_string("sbar_wheel_pos"));
	vector panel_size = stov(cvar_string("sbar_wheel_size"));

	HUD_Panel_ScalePosSize();

	vector pos = panel_pos;
	vector mySize = panel_size;

	int rows = WHEEL_SLOTS;
	int columns = 1;
	vector icon_size = mySize;
	icon_size.x = mySize.x / rows;
	icon_size.y = mySize.y / columns;

	float aspect = 0.42;

	icon_size.x *= aspect;
	icon_size.y *= aspect;

	float padding = 0.29;

	vector icon_pos = pos + vec2(mySize.x * padding, mySize.y * padding);

	drawpic_aspect(pos, "gfx/quake/wheel_background", mySize, '1 1 1', 1, DRAWFLAG_NORMAL);

	for(int j = 0; j < WHEEL_SLOTS; ++j)
	{
		if(wheel_state[j] == WHEEL_SPINNING)
		{
			wheel_offset[j] += frametime * WHEEL_SPEED;
			if(wheel_offset[j] >= 1)
				wheel_offset[j] -= 1;
		}
		else if(wheel_state[j] == WHEEL_STOPPING)
		{
			float targ_offset = wheel_slots[j] * WHEEL_FRACTION;
			float diff = targ_offset - wheel_offset[j];

			if(diff < -0.5)
				diff += 1;
			if(diff > 0.5)
				diff -= 1;

			if(fabs(diff) < 0.01)
			{
				wheel_offset[j] = targ_offset;
				wheel_state[j] = WHEEL_STOPPED;
			}
			else
				wheel_offset[j] += diff * (frametime * 15);
		}

		vector slot_pos = icon_pos;
		slot_pos.x += icon_size.x * j;

		string pic = (gametype == GAMETYPE_TD) ? "gfx/quake/wheel_slots_classic" : "gfx/quake/wheel_slots";
		drawpic_scrolling(slot_pos, icon_size, pic, wheel_offset[j], '1 1 1', 1, DRAWFLAG_NORMAL);
	}

	// draw the combo text!
	if(!wheel_active)
	{
		int oldfont = drawfont;
		drawfont = 8 + 1;

		vector text_size = vec2(mySize.x * 0.25, mySize.y * 0.1);
		vector text_pos = pos + vec2(mySize.x * 0.25, mySize.y * 0.72);

		int combo = wheel_getcombo(wheel_slots[0], wheel_slots[1], wheel_slots[2]);
		string text = wheel_gettext(combo);
		text_pos.x += stringwidth(text, true, '1 1 1' * text_size.y) * 0.25;
		drawcolorcodedstring_aspect(text_pos, text, text_size, 1, DRAWFLAG_NORMAL);

		drawfont = oldfont;
	}
}

void wheel_send()
{
	int channel = MSG_C2S;
	WriteHeader(channel, wheel);
	WriteByte(channel, wheel_slots[0]);
	WriteByte(channel, wheel_slots[1]);
	WriteByte(channel, wheel_slots[2]);

	wheel_closetime = time + 2;
	wheel_inputblock = wheel_closetime;
	wheel_active = false;

	int combo = wheel_getcombo(wheel_slots[0], wheel_slots[1], wheel_slots[2]);
	string snd = wheel_endsound(combo);
	if(snd)
		_sound(NULL, CH_INFO, snd, VOL_BASE, ATTEN_NONE);

	// stop it at the sent as well, since we're not spinning anymore!
	if(wheel_sounds)
	{
		sound(wheel_sounds, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NONE);
		delete(wheel_sounds);
		wheel_sounds = NULL;
	}
}

bool wheel_stopslot()
{
	for(int j = 0; j < WHEEL_SLOTS; ++j)
	{
		if(wheel_state[j] == WHEEL_SPINNING)
		{
			float nearest = rint(wheel_offset[j] / WHEEL_FRACTION);
			if(nearest >= WHEEL_ICONS)
				nearest = 0;
			wheel_slots[j] = nearest;
			wheel_state[j] = WHEEL_STOPPING;
			_sound(NULL, CH_INFO, "player_jester/slotmachine_eachiconstop.wav", VOL_BASE, ATTEN_NONE);
			return true;
		}
	}
	return false;
}

bool wheel_lastslot()
{
	for(int j = 0; j < WHEEL_SLOTS; ++j)
	{
		if(wheel_state[j] == WHEEL_SPINNING)
			return false;
	}
	return true;
}

bool wheel_input_event(int bInputType, float nPrimary, float nSecondary)
{
	if(bInputType == 2 || bInputType == 3)
		return false;
	//if(time < wheel_inputblock)
	//	return true;
	if(!wheel_active && time >= wheel_inputblock)
		return false;

#if 0
	string con_keys = findkeysforcommand("toggleconsole", 0);
	int keys = tokenize(con_keys); // findkeysforcommand returns data for this
	for (int i = 0; i < keys; ++i)
		if (nPrimary == stof(argv(i)))
			return false; // hit console bind
#endif

	// at this point bInputType can only be 0 or 1 (key pressed or released)
	bool key_pressed = (bInputType == 0);

	// TODO: cancel out if we get hit?
#if 0
	if(key_pressed && nPrimary == K_ESCAPE)
	{
		wheel_finish();
		return true;
	}
#endif

	if(nPrimary == K_MOUSE1 || nPrimary == K_SPACE)
	{
		// activate on release!
		if(!key_pressed && time >= wheel_inputblock)
		{
			wheel_stopslot();
			if(wheel_lastslot())
				wheel_send();
		}
		return true;
	}

	if(nPrimary == K_MOUSE2 || nPrimary == K_ENTER)
	{
		if(!key_pressed && time >= wheel_inputblock)
		{
			while(wheel_stopslot())
				{ /* do nothing */ }
			wheel_send();
		}
		return true;
	}

	return false; // prevent all input!
}

NET_HANDLE(TE_CSQC_WHEEL, bool isNew)
{
	// send a starting point for the slots
	for(int j = 0; j < WHEEL_SLOTS; ++j)
	{
		wheel_slots[j] = ReadByte();
		wheel_state[j] = WHEEL_SPINNING;
		wheel_offset[j] = wheel_slots[j] / WHEEL_ICONS;
	}

	_sound(NULL, CH_INFO, "player_jester/slotmachine_start.wav", VOL_BASE, ATTEN_NONE);

	if(!wheel_sounds)
		wheel_sounds = new_pure(wheel_sounds);

	_sound(wheel_sounds, CH_TRIGGER_SINGLE, "player_jester/slotmachine_loop.wav", VOL_BASE, ATTEN_NONE);

	wheel_active = true;
	wheel_inputblock = time + 0.25; // just to prevent re-presses
	wheel_currentslot = 0;
	return true;
}
#endif
