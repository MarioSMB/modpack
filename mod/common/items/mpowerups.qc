const int IT_STAR = BIT(18);
const int IT_METAL = BIT(19);

REGISTER_STAT(STAR_FINISHED, float);
REGISTER_STAT(METAL_FINISHED, float);

MSG_INFO_NOTIF(POWERUP_STAR,                        1,      1, 0, "s1", "s1",       "star",                         _("^BG%s^K1 picked up Starman"), "")

MSG_CENTER_NOTIF(POWERUP_STAR,                      1,      0, 0, "",               CPID_POWERUP,           "0 0",  _("^F2Starman gives you complete invulnerability!"), "")
MSG_CENTER_NOTIF(POWERDOWN_STAR,                    1,      0, 0, "",               CPID_POWERUP,           "0 0",  _("^F2Starman has worn off"), "")

MSG_INFO_NOTIF(POWERUP_METAL,                       1,      1, 0, "s1", "s1",       "metal",                        _("^BG%s^K1 picked up Metal Cap"), "")

MSG_CENTER_NOTIF(POWERUP_METAL,                     1,      0, 0, "",               CPID_POWERUP,           "0 0",  _("^F2Metal Cap gives you a heavy feeling!"), "")
MSG_CENTER_NOTIF(POWERDOWN_METAL,                   1,      0, 0, "",               CPID_POWERUP,           "0 0",  _("^F2Metal Cap has worn off"), "")

REGISTER_GLOBALSOUND(FALL_METALCAP, "misc/metalcaphitground")

#ifndef MENUQC
MODEL(Star_ITEM, Item_Model("star.md3"));
SOUND(Star, "items/powerup_star");
#endif

REGISTER_ITEM(Star, Powerup) {
#ifndef MENUQC
    this.m_model            =   MDL_Star_ITEM;
    this.m_sound            =   SND_Star;
#endif
    this.m_name             =   "starman";
    this.m_icon             =   "star";
    this.m_color            =   '1 1 0';
    this.m_waypoint         =   _("Starman");
    this.m_waypointblink    =   2;
    this.m_itemid           =   IT_STAR;
}

#ifndef MENUQC
MODEL(Metal_ITEM, Item_Model("metal.md3"));
SOUND(Metal, "items/powerup_metal");
#endif

REGISTER_ITEM(Metal, Powerup) {
#ifndef MENUQC
    this.m_model            =   MDL_Metal_ITEM;
    this.m_sound            =   SND_Metal;
#endif
    this.m_name             =   "metalcap";
    this.m_icon             =   "metal";
    this.m_color            =   '0.5 0.5 0.5';
    this.m_waypoint         =   _("Metal Cap");
    this.m_waypointblink    =   2;
    this.m_itemid           =   IT_METAL;
}

#ifdef SVQC
REGISTER_MUTATOR(sv_mpowerups, true);

float autocvar_g_powerup_star_touch_delay = 0.2;
float autocvar_g_powerup_star_speed = 1.7;
float autocvar_g_powerup_star_time = 33.616;
float autocvar_g_powerup_metal_time = 29.930;

bool autocvar_g_powerups_mario_replace = false;

.float star_finished;
.float metal_finished;

.float star_touch_time;

bool have_powerup(entity this)
{
	FOREACH(Items, it.instanceOfPowerup && (this.items & it.m_itemid),
	{
		if(it != ITEM_Star && it != ITEM_Metal && it != ITEM_JetpackRegen && it != ITEM_Jetpack)
			return true;
	});

	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, ItemTouch)
{SELFPARAM();
	if(this.itemdef.instanceOfPowerup)
	{
		if((other.items & ITEM_Star.m_itemid) || (other.items & ITEM_Metal.m_itemid))
			return MUT_ITEMTOUCH_RETURN; // nope
	}

	if (this.star_finished)
	{
		if(have_powerup(other))
			return MUT_ITEMTOUCH_RETURN;
		STAT(STAR_FINISHED, other) = max(STAT(STAR_FINISHED, other), time) + this.star_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}
	if (this.metal_finished)
	{
		if(have_powerup(other))
			return MUT_ITEMTOUCH_RETURN;
		STAT(METAL_FINISHED, other) = max(STAT(METAL_FINISHED, other), time) + this.metal_finished;
		return MUT_ITEMTOUCH_PICKUP;
	}
	return MUT_ITEMTOUCH_CONTINUE;
}

.int cvar_cl_sparkle; // TODO?
MUTATOR_HOOKFUNCTION(sv_mpowerups, PlayerPreThink)
{SELFPARAM();
	if(frametime) // reduce load by only doing it in server frames
	{
		if(!this.cvar_cl_sparkle)
			this.effects &= ~EF_STARDUST;
		this.effects &= ~EF_DIMLIGHT;
	}

	if(this.items & ITEM_Star.m_itemid)
	if(time > this.star_touch_time)
	if(!gameover)
	if(!STAT(FROZEN, this))
	if(IS_PLAYER(this))
	if(!IS_DEAD(this))
	if(!IS_INDEPENDENT_PLAYER(this))
	{
		FOREACH_CLIENT(IS_PLAYER(it) && it != this, LAMBDA(
			if(time > it.star_touch_time)
			if(!STAT(FROZEN, it))
			if(!IS_DEAD(it))
			if(!IS_INDEPENDENT_PLAYER(it))
			if(boxesoverlap(this.absmin, this.absmax, it.absmin, it.absmax))
			{
				Damage(it, this, this, 999, DEATH_CHEAT.m_id, it.origin, it.origin);
				this.star_touch_time = it.star_touch_time = time + autocvar_g_powerup_star_touch_delay;
			}
		));
	}
	return false;
}

.string oldhatname;
.string hatname; // TODO?
MUTATOR_HOOKFUNCTION(sv_mpowerups, PlayerPowerups)
{SELFPARAM();
	if (this.items & ITEM_Star.m_itemid)
	{
		play_countdown(STAT(STAR_FINISHED, this), SND_POWEROFF);
		this.effects = this.effects | (EF_DIMLIGHT | EF_FULLBRIGHT);
		if (time > STAT(STAR_FINISHED, this))
		{
			this.items = this.items - (this.items & ITEM_Star.m_itemid);
			//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_STAR, this.netname);
			Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_POWERDOWN_STAR);
		}
	}
	else
	{
		if (time < STAT(STAR_FINISHED, this))
		{
			this.items = this.items | ITEM_Star.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_STAR, this.netname);
			Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_POWERUP_STAR);
		}
	}

	if (this.items & ITEM_Metal.m_itemid)
	{
		play_countdown(STAT(METAL_FINISHED, this), SND_POWEROFF);
		this.effects = this.effects | (EF_FULLBRIGHT);
		if (time > STAT(METAL_FINISHED, this))
		{
			this.hatname = this.oldhatname;
			this.items = this.items - (this.items & ITEM_Metal.m_itemid);
			//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_METAL, this.netname);
			Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_POWERDOWN_METAL);
		}
	}
	else
	{
		if (time < STAT(METAL_FINISHED, this))
		{
			self.oldhatname = self.hatname;
			this.hatname = strzone("metal");
			this.items = this.items | ITEM_Metal.m_itemid;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_METAL, this.netname);
			Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_POWERUP_METAL);
		}
	}
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, PlayerDamage_Calculate)
{SELFPARAM();
	if(frag_target.items & ITEM_Metal.m_itemid)
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

	if(frag_target.items & ITEM_Star.m_itemid)
	{
		if(!ITEM_DAMAGE_NEEDKILL(frag_deathtype))
			frag_damage = 0;
		if(frag_attacker != frag_target)
			frag_force = '0 0 0';
	}

	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, SpectateCopy)
{SELFPARAM();
	STAT(METAL_FINISHED, this) = STAT(METAL_FINISHED, other);
	STAT(STAR_FINISHED, this) = STAT(STAR_FINISHED, other);
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, PlayerDies)
{SELFPARAM();
	STAT(METAL_FINISHED, this) = 0;
	STAT(STAR_FINISHED, this) = 0;
	sound(this, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, PlayerSpawn)
{SELFPARAM();
	STAT(METAL_FINISHED, this) = 0;
	STAT(STAR_FINISHED, this) = 0;
	sound(this, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, MakePlayerObserver)
{SELFPARAM();
	STAT(METAL_FINISHED, this) = 0;
	STAT(STAR_FINISHED, this) = 0;
	sound(this, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, ClientDisconnect)
{SELFPARAM();
	STAT(METAL_FINISHED, this) = 0;
	STAT(STAR_FINISHED, this) = 0;
	sound(this, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, MatchEnd)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		STAT(METAL_FINISHED, it) = 0;
		STAT(STAR_FINISHED, it) = 0;
		sound(it, CH_TRIGGER_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
	});
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, FixPlayermodel)
{SELFPARAM();
	if(this.items & ITEM_Metal.m_itemid)
		ret_int = 2;
	if(this.items & ITEM_Star.m_itemid)
		ret_int = 1;
	return false;
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, OnEntityPreSpawn, CBC_ORDER_FIRST)
{SELFPARAM();
	if(!autocvar_g_powerups_mario_replace) return false;
	if(this.classname == "item_strength")
		this.classname = "item_metalcap";
	if(this.classname == "item_invincible")
		this.classname = "item_starman";

	return false;
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
    GlobalSound(this, GS_FALL_METALCAP, CH_PLAYER, VOICETYPE_PLAYERSOUND);
#endif
}

MUTATOR_HOOKFUNCTION(sv_mpowerups, PlayerPhysics)
{SELFPARAM();
	if(this.items & ITEM_Star.m_itemid)
	{
		this.stat_sv_maxspeed *= autocvar_g_powerup_star_speed;
		this.stat_sv_airspeedlimit_nonqw *= autocvar_g_powerup_star_speed;
	}

	if(this.items & ITEM_Metal.m_itemid)
	{
		if(IS_PLAYER(this) && IS_ONGROUND(this))
			Metal_check_hitground(this);
	}
	return false;
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

#endif

#ifndef MENUQC
#ifdef SVQC
MUTATOR_HOOKFUNCTION(sv_mpowerups, PM_Physics)
#elif defined(CSQC)
MUTATOR_HOOKFUNCTION(cl_mpowerups, PM_Physics)
#endif
{SELFPARAM();
	if(STAT(ITEMS, this) & ITEM_Metal.m_itemid)
	if(this.waterlevel)
	{
		if(IS_ONGROUND(this))
			PM_walk(this, pm_maxspeed_mod * 0.6);
		else
			PM_air(this, this.buttons_old, pm_maxspeed_mod * 1.2);
		return true;
	}

	return false;
}
#endif

#ifdef CSQC
REGISTER_MUTATOR(cl_mpowerups, true);

bool have_star;
bool have_metalcap;

int powerup_music_index_backup;

entity rainbowvision_noise2;

AUTOCVAR_SAVE(hud_progressbar_metal_color,	vector,   '0.5 0.5 0.5',   "");
AUTOCVAR_SAVE(hud_progressbar_star_color,	vector,   '0.8 0.8 0.1',   "");

MUTATOR_HOOKFUNCTION(cl_mpowerups, HUD_Powerups_add)
{
	int allItems = STAT(ITEMS);
	int metalTime, starTime;
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_powerups) return;
		if(spectatee_status == -1) return;
		if(STAT(HEALTH) <= 0) return;
		if(!(allItems & (ITEM_Star.m_itemid | ITEM_Metal.m_itemid))) return;

		metalTime = bound(0, STAT(METAL_FINISHED) - time, 99);
		starTime = bound(0, STAT(STAR_FINISHED) - time, 99);
	}
	else
	{
		metalTime = 12;
		starTime = 25;
	}

	if(metalTime)
		addPowerupItem("Metal Cap", "metal", autocvar_hud_progressbar_metal_color, metalTime, 30);
	if(starTime)
		addPowerupItem("Starman", "star", autocvar_hud_progressbar_star_color, starTime, 33.616);
	return false;
}

MUTATOR_HOOKFUNCTION(cl_mpowerups, HUD_Draw_overlay)
{
	if(have_star)
	{
		if(time > STAT(STAR_FINISHED, NULL) || autocvar__hud_configure)
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
		if(time < STAT(STAR_FINISHED, NULL))
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
		if(time > STAT(METAL_FINISHED, NULL) || autocvar__hud_configure)
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
		if(time < STAT(METAL_FINISHED, NULL))
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

	if(time < STAT(STAR_FINISHED, NULL))
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

	return false;
}
#endif
