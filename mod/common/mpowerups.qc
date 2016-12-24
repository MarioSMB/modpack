const int IT_STAR = BIT(18); // same id as ctf shielded
const int IT_METAL = BIT(19); // same id as invisibility (which gives a nice side effect of making monsters not target this player)
const int IT_MINI = BIT(23); // TODO: make sure this is actually available

REGISTER_STAT(STAR_FINISHED, float);
REGISTER_STAT(METAL_FINISHED, float);
REGISTER_STAT(MINI_FINISHED, float);

MSG_INFO_NOTIF(POWERUP_STAR,                        1,      1, 0, "s1", "s1",       "star",                         "^BG%s^K1 picked up Starman", "")
MSG_CENTER_NOTIF(POWERUP_STAR,                      1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Starman gives you complete invulnerability!", "")
MSG_CENTER_NOTIF(POWERDOWN_STAR,                    1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Starman has faded", "")

MSG_INFO_NOTIF(POWERUP_METAL,                       1,      1, 0, "s1", "s1",       "metal",                        "^BG%s^K1 picked up Metal Cap", "")
MSG_CENTER_NOTIF(POWERUP_METAL,                     1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Metal Cap gives you a heavy feeling!", "")
MSG_CENTER_NOTIF(POWERDOWN_METAL,                   1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Metal Cap has worn off", "")

MSG_INFO_NOTIF(POWERUP_MINI,                        1,      1, 0, "s1", "s1",       "mini",                         "^BG%s^K1 picked up Mini Mushroom", "")
MSG_CENTER_NOTIF(POWERUP_MINI,                      1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Mini Mushroom makes you tiny but vulnerable!", "")
MSG_CENTER_NOTIF(POWERDOWN_MINI,                    1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Mini Mushroom has outgrown you", "")

REGISTER_GLOBALSOUND(FALL_METALCAP, "misc/metalcaphitground")

#ifdef GAMEQC
MODEL(Star_ITEM, Item_Model("star.md3"));
SOUND(Star, "items/powerup_star");
#endif

REGISTER_ITEM(Star, Powerup) {
#ifdef GAMEQC
    this.m_model            =   MDL_Star_ITEM;
    this.m_sound            =   SND_Star;
#endif
    this.m_name             =   "starman";
    this.m_icon             =   "star";
    this.m_color            =   '1 1 0';
    this.m_waypoint         =   "Starman";
    this.m_waypointblink    =   2;
    this.m_itemid           =   IT_STAR;
}

#ifdef GAMEQC
MODEL(Metal_ITEM, Item_Model("metal.md3"));
SOUND(Metal, "items/powerup_metal");
#endif

REGISTER_ITEM(Metal, Powerup) {
#ifdef GAMEQC
    this.m_model            =   MDL_Metal_ITEM;
    this.m_sound            =   SND_Metal;
#endif
    this.m_name             =   "metalcap";
    this.m_icon             =   "metal";
    this.m_color            =   '0.5 0.5 0.5';
    this.m_waypoint         =   "Metal Cap";
    this.m_waypointblink    =   2;
    this.m_itemid           =   IT_METAL;
}

#ifdef GAMEQC
MODEL(Mini_ITEM, Item_Model("mini.md3"));
SOUND(Mini, "items/powerup_mini");
#endif

REGISTER_ITEM(Mini, Powerup) {
#ifdef GAMEQC
    this.m_model            =   MDL_Mini_ITEM;
    this.m_sound            =   SND_Mini;
#endif
    this.m_name             =   "minishroom";
    this.m_icon             =   "mini";
    this.m_color            =   '0.25 0.25 1';
    this.m_waypoint         =   "Mini Mushroom";
    this.m_waypointblink    =   2;
    this.m_itemid           =   IT_MINI;
}

#ifdef SVQC
AUTOCVAR(g_powerup_mini_water_minspeed, float, 100, "Need to be moving faster than this to stay above water");
#endif
REGISTER_STAT(MINI_WATER_MINSPEED, float, autocvar_g_powerup_mini_water_minspeed);

REGISTER_MUTATOR(mpowerups, true);

#ifdef SVQC
AUTOCVAR(g_powerup_star_touch_delay, float, 0.2, "");
AUTOCVAR(g_powerup_star_speed, float, 1.7, "");
AUTOCVAR(g_powerup_star_time, float, 33.616, "");
AUTOCVAR(g_powerup_metal_time, float, 29.930, "");
AUTOCVAR(g_powerups_mario_replace, bool, false, "");
AUTOCVAR(g_powerup_mini_time, float, 30, "");
AUTOCVAR(g_powerup_mini_gravity, float, 0.4, "");
AUTOCVAR(g_powerup_mini_healthscale, float, 0.5, "Scale of the player's health limits, use a value between 0 and 1");
AUTOCVAR(g_powerup_mini_size, float, 0.2, "Scale of the player when under the influence, use a value between 0 and 1");

const vector PL_VIEW_OFS_CONST = '0 0 35';
const vector PL_CROUCH_VIEW_OFS_CONST = '0 0 20';

const vector PL_CROUCH_MAX_CONST = '16 16 25';
const vector PL_CROUCH_MIN_CONST = '-16 -16 -24';

.float star_finished;
.float metal_finished;
.float mini_finished;

.float mini_oldgravity;
.float star_touch_time;

bool have_powerup(entity this)
{
	FOREACH(Items, it.instanceOfPowerup && (this.items & it.m_itemid),
	{
		if(it != ITEM_Star && it != ITEM_Metal && it != ITEM_JetpackRegen && it != ITEM_Jetpack && it != ITEM_Mini)
			return true;
	});

	return false;
}

void RemovePowerups(entity this)
{
	STAT(METAL_FINISHED, this) = 0;
	STAT(STAR_FINISHED, this) = 0;

	STAT(MINI_FINISHED, this) = 0;
	this.scale = 0; // 0 is default, it'll do for now
	if(this.mini_oldgravity)
	{
		this.gravity = ((this.trigger_gravity_check) ? this.trigger_gravity_check.enemy.gravity : this.mini_oldgravity);
		if(this.gravity == 1)
			this.gravity = 0; // just reset it
	}
	this.mini_oldgravity = 0;
	this.dphitcontentsmask &= ~DPCONTENTS_LIQUIDSMASK;

	// physics doesn't run while player is dead, so we must assume defaults here
	STAT(PL_MIN, this) = autocvar_sv_player_mins;
	STAT(PL_MAX, this) = autocvar_sv_player_maxs;
	STAT(PL_VIEW_OFS, this) = autocvar_sv_player_viewoffset;
	STAT(PL_CROUCH_MIN, this) = autocvar_sv_player_crouch_mins;
	STAT(PL_CROUCH_MAX, this) = autocvar_sv_player_crouch_maxs;
	STAT(PL_CROUCH_VIEW_OFS, this) = autocvar_sv_player_crouch_viewoffset;

	sound(this, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
}

MUTATOR_HOOKFUNCTION(mpowerups, ItemTouch)
{
	entity item = M_ARGV(0, entity);
	entity toucher = M_ARGV(1, entity);
	GameItem def = item.itemdef;

	if(def.instanceOfPowerup)
	{
		if((toucher.items & ITEM_Star.m_itemid) || (toucher.items & ITEM_Metal.m_itemid) || (toucher.items & ITEM_Mini.m_itemid))
			return MUT_ITEMTOUCH_RETURN; // nope
	}

	if (item.star_finished)
	{
		if(have_powerup(toucher))
			return MUT_ITEMTOUCH_RETURN;
		STAT(STAR_FINISHED, toucher) = max(STAT(STAR_FINISHED, toucher), time) + item.star_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}
	if (item.metal_finished)
	{
		if(have_powerup(toucher))
			return MUT_ITEMTOUCH_RETURN;
		STAT(METAL_FINISHED, toucher) = max(STAT(METAL_FINISHED, toucher), time) + item.metal_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}
	if (item.mini_finished)
	{
		if(have_powerup(toucher))
			return MUT_ITEMTOUCH_RETURN;
		STAT(MINI_FINISHED, toucher) = max(STAT(MINI_FINISHED, toucher), time) + item.mini_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}
	return MUT_ITEMTOUCH_CONTINUE;
}

.int cvar_cl_sparkle; // TODO?
MUTATOR_HOOKFUNCTION(mpowerups, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(frametime) // reduce load by only doing it in server frames
	{
		if(!player.cvar_cl_sparkle)
			player.effects &= ~EF_STARDUST;
		player.effects &= ~EF_DIMLIGHT;
	}

	if(time < STAT(STAR_FINISHED, player))
	if(time > player.star_touch_time)
	if(!gameover && IS_PLAYER(player))
	if(!IS_DEAD(player) && !STAT(FROZEN, player))
	if(!IS_INDEPENDENT_PLAYER(player))
	{
		FOREACH_CLIENT(IS_PLAYER(it) && it != player, LAMBDA(
			if(time > it.star_touch_time)
			if(!IS_DEAD(it) && !STAT(FROZEN, it))
			if(!IS_INDEPENDENT_PLAYER(it))
			if(boxesoverlap(player.absmin, player.absmax, it.absmin, it.absmax))
			{
				Damage(it, player, player, 999, DEATH_CHEAT.m_id, it.origin, it.origin);
				player.star_touch_time = it.star_touch_time = time + autocvar_g_powerup_star_touch_delay;
			}
		));
	}
}

.string oldhatname;
.string hatname; // TODO?
MUTATOR_HOOKFUNCTION(mpowerups, PlayerPowerups)
{
	entity player = M_ARGV(0, entity);

	if (player.items & ITEM_Star.m_itemid)
	{
		play_countdown(player, STAT(STAR_FINISHED, player), SND_POWEROFF);
		player.effects = player.effects | (EF_DIMLIGHT | EF_FULLBRIGHT);
		if (time > STAT(STAR_FINISHED, player))
		{
			player.items = player.items - (player.items & ITEM_Star.m_itemid);
			//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_STAR, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERDOWN_STAR);
		}
	}
	else
	{
		if (time < STAT(STAR_FINISHED, player))
		{
			player.items = player.items | ITEM_Star.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_STAR, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERUP_STAR);
		}
	}

	if (player.items & ITEM_Metal.m_itemid)
	{
		play_countdown(player, STAT(METAL_FINISHED, player), SND_POWEROFF);
		player.effects = player.effects | (EF_FULLBRIGHT);
		if (time > STAT(METAL_FINISHED, player))
		{
			player.hatname = player.oldhatname;
			player.items = player.items - (player.items & ITEM_Metal.m_itemid);
			//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_METAL, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERDOWN_METAL);
		}
	}
	else
	{
		if (time < STAT(METAL_FINISHED, player))
		{
			player.oldhatname = player.hatname; // copying zoned string, risky business
			player.hatname = strzone("metal");
			player.items = player.items | ITEM_Metal.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_METAL, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERUP_METAL);
		}
	}

	if (player.items & ITEM_Mini.m_itemid)
	{
		play_countdown(player, STAT(MINI_FINISHED, player), SND_POWEROFF);
		if (time > STAT(MINI_FINISHED, player))
		{
			if(player.crouch)
				setsize(player, autocvar_sv_player_crouch_mins, autocvar_sv_player_crouch_maxs);
			else
				setsize(player, autocvar_sv_player_mins, autocvar_sv_player_maxs);

			player.scale = 0; // 0 is default, it'll do for now
			if(player.mini_oldgravity)
			{
				player.gravity = ((player.trigger_gravity_check) ? player.trigger_gravity_check.enemy.gravity : player.mini_oldgravity);
				if(player.gravity == 1)
					player.gravity = 0; // just reset it
			}
			player.mini_oldgravity = 0;
			player.dphitcontentsmask &= ~DPCONTENTS_LIQUIDSMASK;

			// physics doesn't run while player is dead, so we must assume defaults here
			STAT(PL_MIN, player) = autocvar_sv_player_mins;
			STAT(PL_MAX, player) = autocvar_sv_player_maxs;
			STAT(PL_VIEW_OFS, player) = autocvar_sv_player_viewoffset;
			STAT(PL_CROUCH_MIN, player) = autocvar_sv_player_crouch_mins;
			STAT(PL_CROUCH_MAX, player) = autocvar_sv_player_crouch_maxs;
			STAT(PL_CROUCH_VIEW_OFS, player) = autocvar_sv_player_crouch_viewoffset;

			vector offset = vec3(0, 0, (PL_MIN_CONST.z - (PL_MIN_CONST.z * max(0, autocvar_g_powerup_mini_size))) * -1);
			setorigin(player, player.origin + (offset + '0 0 1')); // restore player's location

			player.items = player.items - (player.items & ITEM_Mini.m_itemid);
			//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_MINI, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERDOWN_MINI);

			tracebox(player.origin, player.mins, player.maxs, player.origin, MOVE_NOMONSTERS, player);
			// if player is going to be stuck in solid when they grow, just kill them
			if(trace_startsolid)
				Damage(player, player, player, 100000, DEATH_VH_CRUSH.m_id, player.origin, '0 0 0');
		}
	}
	else
	{
		if (time < STAT(MINI_FINISHED, player))
		{
			float myscale = max(0, autocvar_g_powerup_mini_size);
			STAT(PL_MIN, player) = PL_MIN_CONST * myscale;
			STAT(PL_MAX, player) = PL_MAX_CONST * myscale;
			STAT(PL_CROUCH_MIN, player) = PL_CROUCH_MIN_CONST * myscale;
			STAT(PL_CROUCH_MAX, player) = PL_CROUCH_MAX_CONST * myscale;
			STAT(PL_VIEW_OFS, player) = PL_VIEW_OFS_CONST * myscale;
			STAT(PL_CROUCH_VIEW_OFS, player) = PL_CROUCH_VIEW_OFS_CONST * myscale;
			if(player.crouch)
				setsize(player, STAT(PL_CROUCH_MIN, player), STAT(PL_CROUCH_MAX, player));
			else
				setsize(player, STAT(PL_MIN, player), STAT(PL_MAX, player));
			player.mini_oldgravity = ((player.gravity != 0) ? player.gravity : 1);
			player.scale = myscale;
			player.gravity = autocvar_g_powerup_mini_gravity;
			player.items = player.items | ITEM_Mini.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_MINI, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERUP_MINI);
		}
	}
}

MUTATOR_HOOKFUNCTION(mpowerups, PlayerDamage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);
	float frag_damage = M_ARGV(4, float);
	vector frag_force = M_ARGV(6, vector);

	if(time < STAT(METAL_FINISHED, frag_target))
	{
		if(frag_attacker != frag_target)
		{
			frag_damage *= 0.3;
			frag_force = '0 0 0';
		}
		else
			frag_damage *= 0.1;

		if(frag_deathtype == DEATH_FALL.m_id || frag_deathtype == DEATH_DROWN.m_id || frag_deathtype == DEATH_LAVA.m_id || frag_deathtype == DEATH_SLIME.m_id)
			frag_damage = 0;
	}

	if(time < STAT(STAR_FINISHED, frag_target))
	{
		if(!ITEM_DAMAGE_NEEDKILL(frag_deathtype))
			frag_damage = 0;
		if(frag_attacker != frag_target)
			frag_force = '0 0 0';
	}

	M_ARGV(4, float) = frag_damage;
	M_ARGV(6, vector) = frag_force;
}

MUTATOR_HOOKFUNCTION(mpowerups, SpectateCopy)
{
	entity spectatee = M_ARGV(0, entity);
	entity client = M_ARGV(1, entity);

	STAT(METAL_FINISHED, client) = STAT(METAL_FINISHED, spectatee);
	STAT(STAR_FINISHED, client) = STAT(STAR_FINISHED, spectatee);
	STAT(MINI_FINISHED, client) = STAT(MINI_FINISHED, spectatee);
	return false;
}

MUTATOR_HOOKFUNCTION(mpowerups, PlayerDies)
{
	entity frag_target = M_ARGV(2, entity);

	RemovePowerups(frag_target);
}

MUTATOR_HOOKFUNCTION(mpowerups, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	RemovePowerups(player);
}

MUTATOR_HOOKFUNCTION(mpowerups, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	RemovePowerups(player);
}

MUTATOR_HOOKFUNCTION(mpowerups, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	RemovePowerups(player);
}

MUTATOR_HOOKFUNCTION(mpowerups, MatchEnd)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		RemovePowerups(it);
	});
}

MUTATOR_HOOKFUNCTION(mpowerups, FixPlayermodel)
{
	entity player = M_ARGV(2, entity);

	if(time < STAT(METAL_FINISHED, player))
		M_ARGV(1, int) = 3;
	if(time < STAT(STAR_FINISHED, player))
		M_ARGV(1, int) = 2;
}

MUTATOR_HOOKFUNCTION(mpowerups, OnEntityPreSpawn, CBC_ORDER_FIRST)
{
	if(!autocvar_g_powerups_mario_replace) return false;

	entity ent = M_ARGV(0, entity);

	switch(ent.classname)
	{
		case "item_strength": ent.classname = "item_metalcap"; break;
		case "item_invincible": ent.classname = "item_starman"; break;
		case "item_quad": case "item_enviro": ent.classname = "item_minishroom"; break;
	}
}

void Metal_check_hitground(entity this)
{
#ifdef SVQC
	if (!this.wasFlying) return;
    this.wasFlying = false;
    if (this.waterlevel >= WATERLEVEL_SWIMMING) return;
    if (time < this.ladder_time) return;
    if (this.hook) return;
    this.nextstep = time + 0.3 + random() * 0.1;
    trace_dphitq3surfaceflags = 0;
    tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 1', MOVE_NOMONSTERS, this);
    if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS) return;
    GlobalSound(this, GS_FALL_METALCAP, CH_PLAYER, VOL_BASE, VOICETYPE_PLAYERSOUND);
#endif
}

MUTATOR_HOOKFUNCTION(mpowerups, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	if(time < STAT(MINI_FINISHED, player))
	{
		M_ARGV(9, float) *= autocvar_g_powerup_mini_healthscale; // regen_health_stable
		M_ARGV(10, float) *= autocvar_g_powerup_mini_healthscale; // regen_health_rotstable
	}
}

spawnfunc(item_starman)
{
	if(!this.star_finished)
		this.star_finished = autocvar_g_powerup_star_time;
	StartItem(this, ITEM_Star);
}

spawnfunc(item_metalcap)
{
	if(!this.metal_finished)
		this.metal_finished = autocvar_g_powerup_metal_time;
	StartItem(this, ITEM_Metal);
}

spawnfunc(item_minishroom)
{
	if(!this.mini_finished)
		this.mini_finished = autocvar_g_powerup_mini_time;
	StartItem(this, ITEM_Mini);
}

#endif

MUTATOR_HOOKFUNCTION(mpowerups, PlayerPhysics)
{
	entity player = M_ARGV(0, entity);

#ifdef SVQC
	if(time < STAT(STAR_FINISHED, player))
	{
		player.stat_sv_maxspeed *= autocvar_g_powerup_star_speed;
		player.stat_sv_airspeedlimit_nonqw *= autocvar_g_powerup_star_speed;
	}

	if(time < STAT(METAL_FINISHED, player))
	{
		if(IS_PLAYER(player) && IS_ONGROUND(player))
			Metal_check_hitground(player);
	}

	if(time < STAT(MINI_FINISHED, player))
	{
		float myscale = max(0, autocvar_g_powerup_mini_size);
		STAT(PL_MIN, player) = PL_MIN_CONST * myscale;
		STAT(PL_MAX, player) = PL_MAX_CONST * myscale;
		STAT(PL_CROUCH_MIN, player) = PL_CROUCH_MIN_CONST * myscale;
		STAT(PL_CROUCH_MAX, player) = PL_CROUCH_MAX_CONST * myscale;
		STAT(PL_VIEW_OFS, player) = PL_VIEW_OFS_CONST * myscale;
		STAT(PL_CROUCH_VIEW_OFS, player) = PL_CROUCH_VIEW_OFS_CONST * myscale;
	}
#endif

	if(time < STAT(MINI_FINISHED, player))
	{
		if(player.waterlevel == WATERLEVEL_NONE && vdist(player.velocity, >, STAT(MINI_WATER_MINSPEED, player)))
			player.dphitcontentsmask |= DPCONTENTS_LIQUIDSMASK;
		else
			player.dphitcontentsmask &= ~DPCONTENTS_LIQUIDSMASK;
	}
}

MUTATOR_HOOKFUNCTION(mpowerups, PM_Physics)
{
	entity player = M_ARGV(0, entity);
	float maxspeed_mod = M_ARGV(1, float);
	float dt = M_ARGV(2, float);

	if(time < STAT(METAL_FINISHED, player))
	if(player.waterlevel)
	{
		if(IS_ONGROUND(player))
		{
			if (!WAS_ONGROUND(player)) {
				emit(phys_land, player);
				if (player.lastground < time - 0.3) {
					player.velocity *= (1 - PHYS_FRICTION_ONLAND(player));
				}
			}
			player.com_phys_vel_max = PHYS_MAXSPEED(player) * (maxspeed_mod * 0.6);
			player.com_phys_gravity = '0 0 -1' * PHYS_GRAVITY(player) * dt;
			if (PHYS_ENTGRAVITY(player)) { player.com_phys_gravity *= PHYS_ENTGRAVITY(player); }
			player.com_phys_ground = true;
			player.com_phys_vel_2d = true;
			sys_phys_simulate(player, dt);
			player.com_phys_vel_2d = false;
			player.com_phys_ground = false;
			player.com_phys_gravity = '0 0 0';
		}
		else
		{
			maxspeed_mod *= 1.2;

			player.com_phys_acc_rate_air = PHYS_AIRACCELERATE(player) * min(maxspeed_mod, 1);
			player.com_phys_acc_rate_air_stop = PHYS_AIRSTOPACCELERATE(player) * maxspeed_mod;
			player.com_phys_acc_rate_air_strafe = PHYS_AIRSTRAFEACCELERATE(player) * maxspeed_mod;
			player.com_phys_vel_max_air_strafe = PHYS_MAXAIRSTRAFESPEED(player) * maxspeed_mod;
			player.com_phys_vel_max_air = PHYS_MAXAIRSPEED(player) * maxspeed_mod;
			player.com_phys_vel_max = PHYS_MAXAIRSPEED(player) * min(maxspeed_mod, 1);
			player.com_phys_air = true;
			player.com_phys_vel_2d = true;
			sys_phys_simulate(player, dt);
			player.com_phys_vel_2d = false;
			player.com_phys_air = false;
		}

		return true;
	}
}

#ifdef CSQC
bool have_star;
bool have_metalcap;

int powerup_music_index_backup;

entity rainbowvision_noise2;

AUTOCVAR_SAVE(hud_progressbar_metal_color,	vector,   '0.5 0.5 0.5',   "");
AUTOCVAR_SAVE(hud_progressbar_star_color,	vector,   '0.8 0.8 0.1',   "");
AUTOCVAR_SAVE(hud_progressbar_mini_color,	vector,   '0.2 0.2 0.8',   "");

MUTATOR_HOOKFUNCTION(mpowerups, HUD_Powerups_add)
{
	if(autocvar__hud_configure)
		return;

	//int allItems = STAT(ITEMS);
	float metalTime = bound(0, STAT(METAL_FINISHED) - time, 99);
	float starTime = bound(0, STAT(STAR_FINISHED) - time, 99);
	float miniTime = bound(0, STAT(MINI_FINISHED) - time, 99);

	if(metalTime)
		addPowerupItem("Metal Cap", "metal", autocvar_hud_progressbar_metal_color, metalTime, 30);
	if(starTime)
		addPowerupItem("Starman", "star", autocvar_hud_progressbar_star_color, starTime, 33.616);
	if(miniTime)
		addPowerupItem("Mini Mushroom", "mini", autocvar_hud_progressbar_mini_color, miniTime, 30);
}

MUTATOR_HOOKFUNCTION(mpowerups, HUD_Draw_overlay)
{
	if(have_star)
	{
		if(time > STAT(STAR_FINISHED) || autocvar__hud_configure)
		{
			if(cvar("music_playlist_index") == 999)
			{
				cvar_set("music_playlist_index", ftos(powerup_music_index_backup));
			}
			else
				localcmd("\ncd resume\n");
				
			have_star = false;
		}
	}
	else if(!autocvar__hud_configure)
	{
		if(time < STAT(STAR_FINISHED))
		{
			if(cvar("music_playlist_index") != 999) // if the playlist isn't paused
			{
				// pause music
				if(cvar("music_playlist_index") != -1)
				{
					powerup_music_index_backup = cvar("music_playlist_index");
					cvar_set("music_playlist_sampleposition0", "0");
					cvar_set("music_playlist_index", "999");
				}
				else
					localcmd("\ncd pause\n");
			}
			
			have_star = true;
		}
	}
	if(have_metalcap)
	{
		if(time > STAT(METAL_FINISHED) || autocvar__hud_configure)
		{
			if(cvar("music_playlist_index") == 999)
			{
				cvar_set("music_playlist_index", ftos(powerup_music_index_backup));
			}
			else
				localcmd("\ncd resume\n");
				
			have_metalcap = false;
		}
	}
	else if(!autocvar__hud_configure)
	{
		if(time < STAT(METAL_FINISHED))
		{
			if(cvar("music_playlist_index") != 999) // if the playlist isn't paused
			{
				// pause music
				if(cvar("music_playlist_index") != -1)
				{
					powerup_music_index_backup = cvar("music_playlist_index");
					cvar_set("music_playlist_sampleposition0", "0");
					cvar_set("music_playlist_index", "999");
				}
				else
					localcmd("\ncd pause\n");
			}
			
			have_metalcap = true;
		}
	}

	if(time < STAT(STAR_FINISHED))
	{
		// apply rainbow vision effect

		if(!rainbowvision_noise2)
			rainbowvision_noise2 = new_pure(rainbowvision_noise2);

		// draw BG
		float a = Noise_Pink(rainbowvision_noise2, frametime * 1.5) * 0.05 + 0.15;
		vector rgb = '1 1 1';
		vector tc_00 = '0 0 0' + '0.2 0 0' * sin(time * 0.3) + '0 0.3 0' * cos(time * 0.7);
		vector tc_01 = '0 2.25 0' + '0.6 0 0' * cos(time * 1.2) - '0 0.3 0' * sin(time * 2.2);
		vector tc_10 = '1.5 0 0' - '0.2 0 0' * sin(time * 0.5) + '0 0.5 0' * cos(time * 1.7);
		//tc_11 = '1 1 0' + '0.6 0 0' * sin(time * 0.6) + '0 0.3 0' * cos(time * 0.1);
		vector tc_11 = tc_01 + tc_10 - tc_00;
		R_BeginPolygon("gfx/rainbow.tga", DRAWFLAG_ADDITIVE);
		R_PolygonVertex('0 0 0', tc_00, rgb, a);
		R_PolygonVertex(autocvar_vid_conwidth * '1 0 0', tc_10, rgb, a);
		R_PolygonVertex(autocvar_vid_conwidth * '1 0 0' + autocvar_vid_conheight * '0 1 0', tc_11, rgb, a);
		R_PolygonVertex(autocvar_vid_conheight * '0 1 0', tc_01, rgb, a);
		R_EndPolygon();
	}
}
#endif
