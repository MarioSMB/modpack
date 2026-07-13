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

	actor.jetpack_status = false;
	STAT(QCC_JETPACKFUEL, actor) = 100;

	actor.skin = bound(0, (etof(actor) % 8) - 1, 7);
}

METHOD(Duke, m_clear, void(Champions this, entity actor))
{
	actor.jetpack_status = false;
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

void PM_jetpack(entity this, float maxspd_mod, float dt)
{
	//makevectors(this.v_angle.y * '0 1 0');
	makevectors(this.v_angle);
	vector wishvel = v_forward * this.movement_x
					+ v_right * this.movement_y;
	// add remaining speed as Z component
	float maxairspd = PHYS_MAXAIRSPEED(this) * max(1, maxspd_mod);
	// fix speedhacks :P
	if(wishvel != '0 0 0')
		wishvel = normalize(wishvel) * min(1, vlen(wishvel) / maxairspd);
	// add the unused velocity as up component
	wishvel.z = 0;

	// if (PHYS_INPUT_BUTTON_JUMP(this))
		wishvel_z = sqrt(max(0, 1 - wishvel * wishvel));

	// it is now normalized, so...
	float a_side = 200;
	float a_up = 500;
	float a_add = 0.5 * PHYS_GRAVITY(this);

	wishvel_x *= a_side;
	wishvel_y *= a_side;
	wishvel_z *= a_up;
	wishvel_z += a_add;

	float best = 0;
	//////////////////////////////////////////////////////////////////////////////////////
	// finding the maximum over all vectors of above form
	// with wishvel having an absolute value of 1
	//////////////////////////////////////////////////////////////////////////////////////
	// we're finding the maximum over
	//   f(a_side, a_up, a_add, z) := a_side * (1 - z^2) + (a_add + a_up * z)^2;
	// for z in the range from -1 to 1
	//////////////////////////////////////////////////////////////////////////////////////
	// maximum is EITHER attained at the single extreme point:
	float a_diff = a_side * a_side - a_up * a_up;
	float f;
	if (a_diff != 0)
	{
		f = a_add * a_up / a_diff; // this is the zero of diff(f(a_side, a_up, a_add, z), z)
		if (f > -1 && f < 1) // can it be attained?
		{
			best = (a_diff + a_add * a_add) * (a_diff + a_up * a_up) / a_diff;
			//print("middle\n");
		}
	}
	// OR attained at z = 1:
	f = (a_up + a_add) * (a_up + a_add);
	if (f > best)
	{
		best = f;
		//print("top\n");
	}
	// OR attained at z = -1:
	f = (a_up - a_add) * (a_up - a_add);
	if (f > best)
	{
		best = f;
		//print("bottom\n");
	}
	best = sqrt(best);
	//////////////////////////////////////////////////////////////////////////////////////

	//print("best possible acceleration: ", ftos(best), "\n");

	float fxy, fz;
	fxy = bound(0, 1 - (this.velocity * normalize(wishvel_x * '1 0 0' + wishvel_y * '0 1 0')) / 150, 1);
	if (wishvel_z - PHYS_GRAVITY(this) > 0)
		fz = bound(0, 1 - this.velocity_z / 200, 1);
	else
		fz = bound(0, 1 + this.velocity_z / 200, 1);

	float fvel;
	fvel = vlen(wishvel);
	wishvel_x *= fxy;
	wishvel_y *= fxy;
	wishvel_z = (wishvel_z - PHYS_GRAVITY(this)) * fz + PHYS_GRAVITY(this);

	if(fvel)
	{
		if(best)
			fvel = min(1, fvel / best);
		float fvelscale = (100 * dt * fvel);
		if(fvelscale)
			f = min(1, 100 / fvelscale);
		else
			f = 0;
	}
	//print("this acceleration: ", ftos(vlen(wishvel) * f), "\n");

	if (f > 0 && wishvel != '0 0 0')
	{
		this.velocity = this.velocity + wishvel * f * dt;
		UNSET_ONGROUND(this);

#ifdef SVQC
		STAT(QCC_JETPACKFUEL, this) -= 75 * dt * fvel * f;
		if(STAT(QCC_JETPACKFUEL, this) <= 0)
			STAT(QCC_JETPACKFUEL, this) = 0;

		this.jetpack_status = true;
#endif
	}
}

#ifdef SVQC
METHOD(Duke, m_fixclient, void(Champions this, entity actor))
{
	actor.jetpack_status = STAT(QCC_JETPACK, actor);
}
#endif

void Duke_PreJump(entity actor)
{
	actor.jetpack_status = false;

	if(!PHYS_INPUT_BUTTON_CROUCH(actor))
		actor.jetpack_stopped = false;
}

METHOD(Duke, m_physics, bool(Champions this, entity actor, float dt))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		bool has_fuel = STAT(QCC_JETPACKFUEL, actor) > 0;

		if(actor.jetpack_stopped) { }
		else if(!has_fuel)
		{
			actor.jetpack_stopped = true;
			actor.jetpack_status = false;	
		}
		else
		{
			actor.jetpack_status = true;
		}
	}
	else
	{
		actor.jetpack_stopped = false;
		actor.jetpack_status = false;
	}

	if(actor.jetpack_status)
	{
		PM_jetpack(actor, 1, dt);
		return true;
	}
	return false;
}

#ifdef CSQC
METHOD(Duke, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/duke_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
