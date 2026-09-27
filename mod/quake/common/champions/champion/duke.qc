#include "duke.qh"

#ifdef SVQC
void duke_playersound(entity this, int chan, Sound sample, float atten)
{
	if(this.duke_taunt_timer > time)
		return;
	if(this.waterlevel > 2)
		return;
	this.duke_taunt_timer = time + 6;
	player_sound(this, chan, sample, atten);
}

METHOD(Duke, m_activate, void(Champions this, entity actor))
{
	duke_playersound(actor, CH_VOICE, SND_Duke_Start_Random(), ATTN_NORM);

	actor.skin = bound(0, (etof(actor) % 8) - 1, 7);
}

METHOD(Duke, m_playerthink, void(Champions this, entity actor))
{
	if(actor.jetpack_status && actor.health > 0 && !intermission_running && !STAT(CANNON, actor))
		actor.modelflags |= MF_ROCKET;
	else
		actor.modelflags &= ~MF_ROCKET;

	if(!actor.jetpack_status && IS_ONGROUND(actor))
		STAT(QCC_JETPACKFUEL, actor) = 100;
}

METHOD(Duke, m_playerspawn, void(Champions this, entity actor))
{
	duke_playersound(actor, CH_VOICE, SND_Duke_Spawn_Random(), ATTN_NORM);

	STAT(QCC_JETPACKFUEL, actor) = 100;

	actor.skin = bound(0, (etof(actor) % 8) - 1, 7);
}

METHOD(Duke, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Duke_Death2, ATTN_NORM);
	actor.duke_cannon = true;
}

METHOD(Duke, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.duke_cannon)
		return false;
	stopsound(actor, CH_PLAYER_SINGLE);
	actor.duke_cannon = false;
	return false;
}

METHOD(Duke, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(targ == attacker)
	{
		duke_playersound(attacker, CH_VOICE, SND_Duke_Suicide_Random(), ATTN_NORM);
		return;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_AXE))
		duke_playersound(attacker, CH_VOICE, SND_Duke_Kill_Axe_Random(), ATTN_NORM);
	else
		duke_playersound(attacker, CH_VOICE, SND_Duke_Kill_Random(), ATTN_NORM);
}

METHOD(Duke, m_pickup_weapon, void(Champions this, entity actor, entity item))
{
	Weapon wep = REGISTRY_GET(Weapons, item.weapon);

	if(wep.ammo_type == IT_SHELLS || wep.ammo_type == IT_NAILS)
		duke_playersound(actor, CH_VOICE, SND_Duke_Pickup_Weapon_Nail_Random(), ATTN_NORM);
	else
		duke_playersound(actor, CH_VOICE, SND_Duke_Pickup_Weapon_Rocket_Random(), ATTN_NORM);
}

METHOD(Duke, m_pickup_powerup, void(Champions this, entity actor, entity item))
{
	duke_playersound(actor, CH_VOICE, SND_Duke_Pickup_Powerup_Random(), ATTN_NORM);
}

METHOD(Duke, m_pickup_key, void(Champions this, entity actor, entity item))
{
	duke_playersound(actor, CH_VOICE, SND_Duke_Pickup_Key_Random(), ATTN_NORM);
}

METHOD(Duke, m_pickup_sigil, void(Champions this, entity actor, entity item))
{
	duke_playersound(actor, CH_VOICE, SND_Duke_Pickup_Sigil, ATTN_NORM);
}
#endif

METHOD(Duke, m_jetpack, bool(Champions this, entity actor, float maxspd_mod, float dt))
{
	if(!PHYS_INPUT_BUTTON_CROUCH(actor) || QCC_PlayerOccupied(actor))
		return false;

	float fuel_cost = 75;
	float maxspeed_up = 200;
	float maxspeed_side = 150;
	float accel_side = 200;
	float accel_up = 500;
	float antigrav = 0.5;
	float fuel_scale = 100;
	bool do_vertical_scale = true;
	if(getworldbasename() == "terraria")
	{
		fuel_cost = 15;
		maxspeed_up = 220;
		maxspeed_side = 700;
		accel_side = 1200;
		accel_up = 1000;
		antigrav = 0.5;
		do_vertical_scale = false;
	}
	jetpack_physics(actor, maxspd_mod, dt, fuel_cost, maxspeed_up, maxspeed_side, accel_side, accel_up, antigrav, fuel_scale, do_vertical_scale);
	return true;
}

#ifdef CSQC
METHOD(Duke, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/duke_face";
	if(StatusEffects_active(STATUSEFFECT_Quad, g_statuseffects))
		pic = "gfx/quake/duke_face_powerup";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, "gfx/quake/backtile", icon_size, '1 1 1', autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
