const int MIT_STAR = BIT(0);
const int MIT_MINI = BIT(1);
const int MIT_LIFE = BIT(2);

REGISTER_STAT(STAR_FINISHED, float);
REGISTER_STAT(MINI_FINISHED, float);
REGISTER_STAT(LIFE_FINISHED, float);

MSG_INFO_NOTIF(POWERUP_STAR,                        1,      1, 0, "s1", "s1",       "star",                         "^BG%s^K1 picked up Starman", "")
MSG_CENTER_NOTIF(POWERUP_STAR,                      1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Starman gives you complete invulnerability!", "")
MSG_CENTER_NOTIF(POWERDOWN_STAR,                    1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Starman has faded", "")

MSG_INFO_NOTIF(POWERUP_MINI,                        1,      1, 0, "s1", "s1",       "mini",                         "^BG%s^K1 picked up Mini Mushroom", "")
MSG_CENTER_NOTIF(POWERUP_MINI,                      1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Mini Mushroom makes you tiny but vulnerable!", "")
MSG_CENTER_NOTIF(POWERDOWN_MINI,                    1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Mini Mushroom has outgrown you", "")

MSG_INFO_NOTIF(POWERUP_LIFE,                        1,      1, 0, "s1", "s1",       "life",                         "^BG%s^K1 picked up Life Mushroom", "")
MSG_CENTER_NOTIF(POWERUP_LIFE,                      1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Life Mushroom gives you double health capacity!", "")
MSG_CENTER_NOTIF(POWERDOWN_LIFE,                    1,      0, 0, "",               CPID_POWERUP,           "0 0",  "^F2Life Mushroom has withered", "")

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
    this.m_itemid           =   MIT_STAR;
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
    this.m_itemid           =   MIT_MINI;
}

#ifdef GAMEQC
MODEL(Life_ITEM, Item_Model("life.md3"));
SOUND(Life, "items/powerup_life");
#endif

REGISTER_ITEM(Life, Powerup) {
#ifdef GAMEQC
    this.m_model            =   MDL_Life_ITEM;
    this.m_sound            =   SND_Life;
#endif
    this.m_name             =   "lifeshroom";
    this.m_icon             =   "life";
    this.m_color            =   '1 0.25 0.25';
    this.m_waypoint         =   "Life Mushroom";
    this.m_waypointblink    =   2;
    this.m_itemid           =   MIT_LIFE;
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
AUTOCVAR(g_powerups_mario_replace, bool, false, "");
AUTOCVAR(g_powerup_mini_time, float, 30, "");
AUTOCVAR(g_powerup_mini_gravity, float, 0.4, "");
AUTOCVAR(g_powerup_mini_healthscale, float, 0.5, "Scale of the player's health limits, use a value between 0 and 1");
AUTOCVAR(g_powerup_mini_size, float, 0.2, "Scale of the player when under the influence, use a value between 0 and 1");
AUTOCVAR(g_powerup_life_time, float, 60, "");

const vector PL_VIEW_OFS_CONST = '0 0 35';
const vector PL_CROUCH_VIEW_OFS_CONST = '0 0 20';

const vector PL_CROUCH_MAX_CONST = '16 16 25';
const vector PL_CROUCH_MIN_CONST = '-16 -16 -24';

.int mitems;

.float star_finished;
.float mini_finished;
.float life_finished;

.float mini_oldgravity;
.float star_touch_time;

bool have_powerup(entity this)
{
	return ((this.mitems & ITEM_Star.m_itemid) || (this.mitems & ITEM_Mini.m_itemid) || (this.mitems & ITEM_Life.m_itemid));
}

void RemovePowerups(entity this)
{
	STAT(STAR_FINISHED, this) = 0;
	STAT(MINI_FINISHED, this) = 0;
	STAT(LIFE_FINISHED, this) = 0;

	this.mitems = 0;

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
	//GameItem def = item.itemdef;

	if (item.star_finished)
	{
		if(have_powerup(toucher))
			return MUT_ITEMTOUCH_RETURN;
		STAT(STAR_FINISHED, toucher) = max(STAT(STAR_FINISHED, toucher), time) + item.star_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}
	if (item.mini_finished)
	{
		if(have_powerup(toucher))
			return MUT_ITEMTOUCH_RETURN;
		STAT(MINI_FINISHED, toucher) = max(STAT(MINI_FINISHED, toucher), time) + item.mini_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}
	if (item.life_finished)
	{
		if(have_powerup(toucher))
			return MUT_ITEMTOUCH_RETURN;
		STAT(LIFE_FINISHED, toucher) = max(STAT(LIFE_FINISHED, toucher), time) + item.life_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}

	if(item.health && STAT(LIFE_FINISHED, toucher) > time)
	{
		bool gave = Item_GiveAmmoTo(item, toucher, health, item.max_health * 2, ITEM_MODE_HEALTH);
		if(!gave)
			return MUT_ITEMTOUCH_RETURN;
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

	if (player.mitems & ITEM_Star.m_itemid)
	{
		play_countdown(player, STAT(STAR_FINISHED, player), SND_POWEROFF);
		player.effects = player.effects | (EF_DIMLIGHT | EF_FULLBRIGHT);
		if (time > STAT(STAR_FINISHED, player))
		{
			player.mitems &= ~ITEM_Star.m_itemid;
			//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_STAR, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERDOWN_STAR);
		}
	}
	else
	{
		if (time < STAT(STAR_FINISHED, player))
		{
			player.mitems |= ITEM_Star.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_STAR, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERUP_STAR);
		}
	}

	if (player.mitems & ITEM_Mini.m_itemid)
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

			player.mitems &= ~ITEM_Mini.m_itemid;
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
			player.mitems |= ITEM_Mini.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_MINI, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERUP_MINI);
		}
	}

	if (player.mitems & ITEM_Life.m_itemid)
	{
		play_countdown(player, STAT(LIFE_FINISHED, player), SND_POWEROFF);
		if (time > STAT(LIFE_FINISHED, player))
		{
			player.mitems &= ~ITEM_Life.m_itemid;
			//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_LIFE, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERDOWN_LIFE);
		}
	}
	else
	{
		if (time < STAT(LIFE_FINISHED, player))
		{
			float starthp = ((warmup_stage) ? warmup_start_health : start_health);

			if(player.health > 0)
				player.health = starthp * 2;

			player.mitems |= ITEM_Life.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_LIFE, player.netname);
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_POWERUP_LIFE);
		}
	}
}

MUTATOR_HOOKFUNCTION(mpowerups, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);
	float frag_damage = M_ARGV(4, float);
	vector frag_force = M_ARGV(6, vector);

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

	if(time < STAT(STAR_FINISHED, player))
		M_ARGV(1, int) = 2;
}

MUTATOR_HOOKFUNCTION(mpowerups, OnEntityPreSpawn, CBC_ORDER_FIRST)
{
	if(!autocvar_g_powerups_mario_replace) return false;

	entity ent = M_ARGV(0, entity);

	switch(ent.classname)
	{
		case "item_strength": ent.classname = "item_minishroom"; break;
		case "item_invincible": ent.classname = "item_starman"; break;
		case "item_quad": ent.classname = "item_lifeshroom"; break;
	}
}

MUTATOR_HOOKFUNCTION(mpowerups, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	if(time < STAT(MINI_FINISHED, player))
	{
		M_ARGV(9, float) *= autocvar_g_powerup_mini_healthscale; // regen_health_stable
		M_ARGV(10, float) *= autocvar_g_powerup_mini_healthscale; // regen_health_rotstable
	}

	if(time < STAT(LIFE_FINISHED, player))
	{
		M_ARGV(1, float) *= 2; // max_mod
		M_ARGV(4, float) *= 2; // limit_mod
	}
}

spawnfunc(item_starman)
{
	if(!this.star_finished)
		this.star_finished = autocvar_g_powerup_star_time;
	StartItem(this, ITEM_Star);
}

spawnfunc(item_minishroom)
{
	if(!this.mini_finished)
		this.mini_finished = autocvar_g_powerup_mini_time;
	StartItem(this, ITEM_Mini);
}

spawnfunc(item_lifeshroom)
{
	if(!this.life_finished)
		this.life_finished = autocvar_g_powerup_life_time;
	StartItem(this, ITEM_Life);
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

#ifdef CSQC
bool have_star;

int powerup_music_index_backup;

entity rainbowvision_noise2;

AUTOCVAR_SAVE(hud_progressbar_star_color,	vector,   '0.8 0.8 0.1',   "");
AUTOCVAR_SAVE(hud_progressbar_mini_color,	vector,   '0.2 0.2 0.8',   "");
AUTOCVAR_SAVE(hud_progressbar_life_color,	vector,   '0.8 0.2 0.2',   "");

MUTATOR_HOOKFUNCTION(mpowerups, HUD_Powerups_add)
{
	if(autocvar__hud_configure)
		return;

	//int allItems = STAT(ITEMS);
	float starTime = bound(0, STAT(STAR_FINISHED) - time, 99);
	float miniTime = bound(0, STAT(MINI_FINISHED) - time, 99);
	float lifeTime = bound(0, STAT(LIFE_FINISHED) - time, 99);

	if(starTime)
		addPowerupItem("Starman", "star", autocvar_hud_progressbar_star_color, starTime, 33.616);
	if(miniTime)
		addPowerupItem("Mini Mushroom", "mini", autocvar_hud_progressbar_mini_color, miniTime, 30);
	if(lifeTime)
		addPowerupItem("Life Mushroom", "life", autocvar_hud_progressbar_life_color, lifeTime, 60);
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
