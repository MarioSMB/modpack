#include "valkyrie.qh"

#ifdef SVQC
void valkyrie_nail2(entity this) { set_anim(this, 151, player_run); }
void valkyrie_nail1(entity this) { set_anim(this, 149, valkyrie_nail2); }
#endif

METHOD(Valkyrie, m_physics, bool(Champions this, entity actor, float dt))
{
	if(actor.waterlevel >= 2)
		return false;

	//makevectors(actor.v_angle);
	makevectors('0 1 0' * actor.angles_y);

	vector wishvel;
	wishvel = v_forward * actor.movement_x + v_right * actor.movement_y + '0 0 1' * actor.movement_z;

	float maxspeed = 420;

	vector wishdir = normalize(wishvel);
	float wishspeed = min(maxspeed, vlen(wishvel));
	wishspeed *= 1.2;

	// water friction
	float frict = 3;
	float speed = vlen(actor.velocity);
	float spd = (1 - dt * frict);
	float newspeed = max(0, speed - spd);
	actor.velocity = actor.velocity * spd;

	// water acceleration
	float addspeed = max(0, wishspeed - newspeed);

	float accel = 15;
	float accelspeed = accel * wishspeed * dt;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	actor.velocity += accelspeed * wishdir;

	// anti gravity
	if(!IS_ONGROUND(actor))
	{
		float grav = PHYS_GRAVITY(actor);
		actor.velocity_z += grav * 0.95 * dt;

		if(PHYS_INPUT_BUTTON_CROUCH(actor))
		{
#ifdef SVQC
			if(time > actor.valyrie_noflytime)
#endif
			actor.velocity_z = -maxspeed * 0.7;
		}
	}

	return true;
}

METHOD(Valkyrie, m_doublejump, bool(Champions this, entity actor))
{
	if(actor.waterlevel >= 2)
		return false;
	float maxspeed = 420;
	actor.velocity_z = maxspeed * 0.7;

	return false;
}

METHOD(Valkyrie, m_playerjump, float(Champions this, entity actor))
{
	return 0; // no normal jumping
}

#ifdef SVQC
METHOD(Valkyrie, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this)
		return 0.33;
	return 1;
}

METHOD(Valkyrie, m_activate, void(Champions this, entity actor))
{
	if(IS_ONGROUND(actor))
	{
		actor.velocity_z += 350;
		UNSET_ONGROUND(actor);
	}
	actor.valyrie_noflytime = time + 0.5; // hack to prevent downward movement cancelling the starting jump

	STAT(WEAPONS, actor) |= WEP_SMG.m_wepset;

	.entity weaponentity = weaponentities[0]; // WEAPONTODO
	W_SwitchWeapon_Force(actor, WEP_SMG, weaponentity);

	float r = random();
	if(r < 0.33)
		_sound(actor, CH_VOICE, "player_enyo/taunts/deathfromabove.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(actor, CH_VOICE, "player_enyo/taunts/flymydarlings.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "player_enyo/taunts/looksosmall.wav", 1, ATTN_NORM);
}

METHOD(Valkyrie, m_playerspawn, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) |= WEP_SMG.m_wepset;
}
#endif

#ifdef CSQC
METHOD(Valkyrie, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/enyo_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}

METHOD(Valkyrie, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) == -666 || !STAT(TRANSFORM_LIMITED))
		return;

	vector pos;
	pos.x = 256;
	pos.y = vid_conheight - 48;
	pos.z = 0;

	vector mySize = '0 0 0';
	mySize.x = 256;
	mySize.y = 32;

	vector col;
	col.x = time % (M_PI * 2);
	col.y = 1;
	col.z = 1;
	col = hsv_to_rgb(col);

	float charge = STAT(TRANSFORM_LIMITED) - time;
	if(charge)
		charge /= 15;

	HUD_Panel_DrawProgressBar(pos + '34 8 0', vec2(mySize.x * 0.87, mySize.y * 0.5), "progressbar", charge, false, 0, col, 0.6, DRAWFLAG_NORMAL);
	drawpic(pos, "gfx/quake/enyo_wingcharge", mySize, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}
#endif
