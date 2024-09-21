#include "banjo.qh"

#ifdef SVQC

METHOD(BanjoKazooie, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
	STAT(WEAPONS, actor) |= WEP_BREEGULLBLASTER.m_wepset;

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
		W_SwitchWeapon(actor, WEP_BREEGULLBLASTER, weaponentity);
}

METHOD(BanjoKazooie, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.banjo_cannon = true;
}

METHOD(BanjoKazooie, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.banjo_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.banjo_cannon = false;
	actor.jump_flag = 0;
	return false;
}

METHOD(BanjoKazooie, m_pickup_sigil, void(Champions this, entity actor, entity item))
{
	// play a sigil collection sound, but give it a delay to play any jingles
	actor.banjo_sigilsound = time + 2.5;
}

METHOD(BanjoKazooie, m_playerthink, void(Champions this, entity actor))
{
	if(!actor.jetpack_status && IS_ONGROUND(actor))
	{
		actor.banjo_landed = true;
		STAT(QCC_JETPACKFUEL, actor) = 100;
	}

	if(actor.banjo_sigilsound && time > actor.banjo_sigilsound)
	{
		player_sound(actor, CH_TRIGGER_SINGLE, "start.wav", ATTN_NORM);
		actor.banjo_sigilsound = 0;
	}
}

METHOD(BanjoKazooie, m_playerspawn, void(Champions this, entity actor))
{
	actor.jetpack_status = false;
	STAT(QCC_JETPACKFUEL, actor) = 100;
	STAT(WEAPONS, actor) |= WEP_BREEGULLBLASTER.m_wepset;
}

METHOD(BanjoKazooie, m_clear, void(Champions this, entity actor))
{
	actor.banjo_sigilsound = 0;
	actor.jetpack_status = false;
	STAT(WEAPONS, actor) &= ~WEP_BREEGULLBLASTER.m_wepset;
}

#endif

// copy of jetpack with less power
void PM_flight(entity this, float maxspd_mod, float dt)
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
	wishvel_z = 0;

	// if (PHYS_INPUT_BUTTON_JUMP(this))
		wishvel_z = sqrt(max(0, 1 - wishvel * wishvel));

	// it is now normalized, so...
	float a_side = 260;
	float a_up = 15;
	float a_add = 0.2 * PHYS_GRAVITY(this);

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
	fxy = bound(0, 1 - (this.velocity * normalize(wishvel_x * '1 0 0' + wishvel_y * '0 1 0')) / 300, 1);
	if (wishvel_z - PHYS_GRAVITY(this) > 0)
		fz = bound(0, 1 - this.velocity_z / 10, 1);
	else
		fz = bound(0, 1 + this.velocity_z / 10, 1);

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
		STAT(QCC_JETPACKFUEL, this) -= 100 * dt * fvel * f;
		if(STAT(QCC_JETPACKFUEL, this) <= 0)
			STAT(QCC_JETPACKFUEL, this) = 0;

		this.jetpack_status = true;
#endif
	}
}

#ifdef SVQC
METHOD(BanjoKazooie, m_fixclient, void(Champions this, entity actor))
{
	actor.jetpack_status = STAT(QCC_JETPACK, actor);
}
#endif

void Banjo_PreJump(entity actor)
{
	actor.jetpack_status = false;

	if(!PHYS_INPUT_BUTTON_CROUCH(actor))
		actor.jetpack_stopped = false;
}

METHOD(BanjoKazooie, m_physics, bool(Champions this, entity actor, float dt))
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
#ifdef SVQC
		if(actor.banjo_landed && !IS_ONGROUND(actor))
			player_sound(actor, CH_VOICE, "flight.wav", ATTN_NORM);
		actor.banjo_landed = false;
#endif
		PM_flight(actor, 1, dt);
		return true;
	}
	return false;
}
