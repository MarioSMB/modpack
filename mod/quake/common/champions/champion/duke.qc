#include "duke.qh"

#ifdef SVQC
void duke_playersound(entity this, int chan, string sample, float atten)
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
	string s = "";
	float r = random() * 9;
	if(r < 1)
		s = "letsrk.wav";
	else if(r < 2)
		s = "wherami.wav";
	else if(r < 3)
		s = "hell90s.wav";
	else if(r < 4)
		s = "romero.wav";
	else if(r < 5)
		s = "betduke.wav";
	else if(r < 6)
		s = "chew.wav";
	else if(r < 7)
		s = "blowshitup.wav";
	else if(r < 8)
		s = "cokrok.wav";
	else
		s = "wansom.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);

	actor.skin = bound(0, (etof(actor) % 8) - 1, 7);
}

METHOD(Duke, m_playerthink, void(Champions this, entity actor))
{
	if(actor.jetpack_status && actor.health > 0 && !intermission_running && !STAT(CANNON, this))
		actor.modelflags |= MF_ROCKET;
	else
		actor.modelflags &= ~MF_ROCKET;

	if(!actor.jetpack_status && IS_ONGROUND(actor))
		STAT(QCC_JETPACKFUEL, actor) = 100;
}

METHOD(Duke, m_playerspawn, void(Champions this, entity actor))
{
	string s = "";
	float r = random() * 8;
	if(r < 1)
		s = "cry.wav";
	else if(r < 2)
		s = "kicka.wav";
	else if(r < 3)
		s = "pissin.wav";
	else if(r < 4)
		s = "rip.wav";
	else if(r < 5)
		s = "smackdb.wav";
	else if(r < 6)
		s = "yohoho2.wav";
	else if(r < 7)
		s = "nothink.wav";
	else
		s = "mthrfkr.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);

	actor.jetpack_status = false;
	STAT(QCC_JETPACKFUEL, actor) = 100;
}

METHOD(Duke, m_clear, void(Champions this, entity actor))
{
	actor.jetpack_status = false;
}

METHOD(Duke, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death2.wav", ATTN_NORM);
	actor.duke_cannon = true;
}

METHOD(Duke, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.duke_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.duke_cannon = false;
	return false;
}

METHOD(Duke, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	string s = "";
	float r = random();

	if(targ == attacker)
	{
		if(r < 0.333)
			s = "myself.wav";
		else if(r < 0.666)
			s = "realthing.wav";
		else
			s = "kickmyass.wav";
		duke_playersound(attacker, CH_VOICE, s, ATTN_NORM);
		return;
	}

	if(deathtype == WEP_AXE.m_id)
	{
		if(r < 0.25)
			s = "footface.wav";
		else if(r < 0.5)
			s = "stomped.wav";
		else if(r < 0.75)
			s = "bug.wav";
		else
			s = "bloodboot.wav";
		duke_playersound(attacker, CH_VOICE, s, ATTN_NORM);
	}
	else
	{
		r = random() * 30;
		if(r < 1)
			s = "aisle.wav";
		else if(r < 2)
			s = "amess.wav";
		else if(r < 3)
			s = "bitchn.wav";
		else if(r < 4)
			s = "blowit.wav";
		else if(r < 5)
			s = "bookem.wav";
		else if(r < 6)
			s = "cool.wav";
		else if(r < 7)
			s = "damn.wav";
		else if(r < 8)
			s = "getsom.wav";
		else if(r < 9)
			s = "gmeovr.wav";
		else if(r < 10)
			s = "gothrt.wav";
		else if(r < 11)
			s = "groovy.wav";
		else if(r < 12)
			s = "hail.wav";
		else if(r < 13)
			s = "holysh.wav";
		else if(r < 14)
			s = "imgood.wav";
		else if(r < 15)
			s = "inhell.wav";
		else if(r < 16)
			s = "letsrk.wav";
		else if(r < 17)
			s = "lookin.wav";
		else if(r < 18)
			s = "meat.wav";
		else if(r < 19)
			s = "name.wav";
		else if(r < 20)
			s = "nobody.wav";
		else if(r < 21)
			s = "piece.wav";
		else if(r < 22)
			s = "slacker.wav";
		else if(r < 23)
			s = "sukitdn.wav";
		else if(r < 24)
			s = "rokrol.wav";
		else if(r < 25)
			s = "betduke2.wav";
		else if(r < 26)
			s = "huckleberry.wav";
		else if(r < 27)
			s = "itsgood.wav";
		else if(r < 28)
			s = "ripieces.wav";
		else if(r < 29)
			s = "oneking.wav";
		else
			s = "fragged.wav";
		duke_playersound(attacker, CH_VOICE, s, ATTN_NORM);
	}
}

METHOD(Duke, m_pickup_weapon, void(Champions this, entity actor, entity item))
{
	Weapon wep = REGISTRY_GET(Weapons, item.weapon);
	string s = "";
	float r = random();

	if(wep.ammo_type == IT_SHELLS || wep.ammo_type == IT_NAILS)
	{
		if(r < 0.25)
			s = "wansom.wav";
		else if(r < 0.5)
			s = "cool.wav";
		else if(r < 0.75)
			s = "groovy.wav";
		else
			s = "getsom.wav";
		duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
	}
	else
	{
		if(r < 0.333)
			s = "hehehe.wav";
		else if(r < 0.666)
			s = "letsrk.wav";
		else
			s = "timetokill.wav";
		duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
	}
}

METHOD(Duke, m_pickup_powerup, void(Champions this, entity actor, entity item))
{
	string s = "";
	float r = random();

	if(r < 0.333)
		s = "timetokill.wav";
	else if(r < 0.666)
		s = "bos.wav";
	else
		s = "groovy.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
}

METHOD(Duke, m_pickup_key, void(Champions this, entity actor, entity item))
{
	string s = "";
	float r = random();

	if(r < 0.333)
		s = "stormgates.wav";
	else if(r < 0.666)
		s = "lookin.wav";
	else
		s = "groovy.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
}

METHOD(Duke, m_pickup_sigil, void(Champions this, entity actor, entity item))
{
	duke_playersound(actor, CH_VOICE, "imgood.wav", ATTN_NORM);
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
METHOD(Duke, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/duke_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
