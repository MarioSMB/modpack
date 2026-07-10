#include "floyd.qh"

#ifdef SVQC

void FLaunchLaser(entity this, vector org, vector vec);
void floydchamp_fire(entity this, float muzzle)
{
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.v_angle);
	
	vector org = this.origin + v_forward * 30 + '0 0 28' + v_right * muzzle;
	vector dir = v_forward;

	_sound(this, CH_WEAPON_SINGLE, "floyd/fire.wav", 1, ATTN_NORM);
	FLaunchLaser(this, org, dir);
}

void floydchamp_attack9(entity this) { set_animofs(this, anim_floyd_attack1, 9, player_run); }
void floydchamp_attack8(entity this) { set_animofs(this, anim_floyd_attack1, 8, floydchamp_attack9); }
void floydchamp_attack7(entity this) { set_animofs(this, anim_floyd_attack1, 7, floydchamp_attack8); floydchamp_fire(this, -6); }
void floydchamp_attack6(entity this) { set_animofs(this, anim_floyd_attack1, 6, floydchamp_attack7); }
void floydchamp_attack5(entity this) { set_animofs(this, anim_floyd_attack1, 5, floydchamp_attack6); }
void floydchamp_attack4(entity this) { set_animofs(this, anim_floyd_attack1, 4, floydchamp_attack5); floydchamp_fire(this, 0); }
void floydchamp_attack3(entity this) { set_animofs(this, anim_floyd_attack1, 3, floydchamp_attack4); }
void floydchamp_attack2(entity this) { set_animofs(this, anim_floyd_attack1, 2, floydchamp_attack3); }
void floydchamp_attack1(entity this) { set_animofs(this, anim_floyd_attack1, 1, floydchamp_attack2); floydchamp_fire(this, 6); }

METHOD(FloydChamp, m_activate, void(Champions this, entity actor))
{
	_sound(actor, CH_VOICE, "floyd/sight.wav", 1, ATTN_NORM);
}

METHOD(FloydChamp, m_weaponframe, bool(Champions this, entity actor, .entity weaponentity))
{
	// no regular weapon use!
	return true;
}

METHOD(FloydChamp, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_ATCK(actor) && time > actor.floyd_shoot_time && !actor.tank && !STAT(CANNON, actor))
	{
		actor.floyd_shoot_time = time + 1.5;
		floydchamp_attack1(actor);
	}

	if(actor.jetpack_status && actor.health > 0 && !intermission_running && !STAT(CANNON, actor))
		actor.modelflags |= MF_ROCKET;
	else
		actor.modelflags &= ~MF_ROCKET;

	if(!actor.jetpack_status && IS_ONGROUND(actor))
		STAT(QCC_JETPACKFUEL, actor) = 100;
}

METHOD(FloydChamp, m_playerspawn, void(Champions this, entity actor))
{
	actor.jetpack_status = false;
	STAT(QCC_JETPACKFUEL, actor) = 100;
}

METHOD(FloydChamp, m_clear, void(Champions this, entity actor))
{
	actor.jetpack_status = false;
}

METHOD(FloydChamp, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	_sound(actor, CH_TRIGGER_SINGLE, "hammer/hammer_clang2_floyd.wav", 1, ATTN_NORM);
	actor.floyd_cannon = true;
}

METHOD(FloydChamp, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.floyd_cannon)
		return false;
	_sound(actor, CH_TRIGGER_SINGLE, "hammer/charge_full_floyd.wav", 1, ATTN_NORM);
	actor.floyd_cannon = false;
	return false;
}
#endif

// TODO: so much code dupe...
void PM_floydjetpack(entity this, float maxspd_mod, float dt)
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
		STAT(QCC_JETPACKFUEL, this) -= 15 * dt * fvel * f;
		if(STAT(QCC_JETPACKFUEL, this) <= 0)
			STAT(QCC_JETPACKFUEL, this) = 0;

		this.jetpack_status = true;
#endif
	}
}

#ifdef SVQC
METHOD(FloydChamp, m_fixclient, void(Champions this, entity actor))
{
	actor.jetpack_status = STAT(QCC_JETPACK, actor);
}
#endif

// same functionality as duke's
void Duke_PreJump(entity actor);

METHOD(FloydChamp, m_playerjump, float(Champions this, entity actor))
{
	return 0.5;
}

METHOD(FloydChamp, m_physics, bool(Champions this, entity actor, float dt))
{
	// inlined check of some of QCC_CanCastAbility
	// separated as we are a transformation and normally can't cast abilities
	bool cancast = true;
	if(STAT(CANNON, actor))
		cancast = false;
	if(STAT(ITEMS, actor) & IT_TANK)
		cancast = false;
	if(STAT(CLOCKWORK, actor))
		cancast = false;

	if(PHYS_INPUT_BUTTON_CROUCH(actor) && cancast)
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
		PM_floydjetpack(actor, 1, dt);
		return true;
	}
	return false;
}

#ifdef CSQC
METHOD(FloydChamp, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/floyd_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
