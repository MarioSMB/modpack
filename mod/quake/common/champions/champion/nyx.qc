#include "nyx.qh"

#ifdef SVQC
METHOD(Nyx, m_activate, void(Nyx this, entity actor))
{
	player_sound(actor, CH_VOICE, "invis2.wav", ATTN_NORM);
}

void Nyx_Invis(entity this)
{
	this.powerups |= POWERUP_INVISIBILITY;
	this.invisible_time = 1;
	this.invisible_finished = time + 5;

	_sound(this, CH_WEAPON_SINGLE, "player_nyx/invisenter.wav", 1, ATTN_NORM);
	string s;
	float r = random();
	if(r < 0.333)
		s = "invis1.wav";
	else if(r < 0.666)
		s = "invis3.wav";
	else
		s = "invis4.wav";
	player_sound(this, CH_VOICE, s, ATTN_NORM);

	invis_loseaggro(this);
}

METHOD(Nyx, m_playerthink, void(Nyx this, entity actor))
{
	if(actor.powerups & POWERUP_INVISIBILITY)
		return;
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		Nyx_Invis(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 10;
	}
}
#endif

vector PlayerTouchWall(entity this)
{
#define TRACE(newvec) \
	tracebox (start, this.mins, this.maxs, (newvec), true, this); \
	if (trace_fraction < 1 && vdist(this.origin - trace_endpos, <, dist) && trace_plane_normal_z < max_normal) \
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)) \
		return trace_plane_normal;

	float dist = 10, max_normal = 0.2, scaler = 100;
	vector start = this.origin;
	vector forward, right, _up;
	MAKE_VECTORS(this.angles, forward, right, _up);
	TRACE(start + forward * scaler)
	TRACE(start - forward * scaler)
	TRACE(start + right * scaler)
	TRACE(start - right * scaler)
#undef TRACE
	return '0 0 0';
}

METHOD(Nyx, m_doublejump, bool(Nyx this, entity actor))
{
	if(actor.waterlevel > 0)
		return false;
	if(time - STAT(QCC_LASTWJ, actor) > 0.95) // can't do this on client, as it's too stupid to obey counters
	if(!IS_ONGROUND(actor))
	if(actor.move_movetype != MOVETYPE_NONE && actor.move_movetype != MOVETYPE_FOLLOW && actor.move_movetype != MOVETYPE_FLY && actor.move_movetype != MOVETYPE_NOCLIP)
	if(!IS_JUMP_HELD(actor))
	{
		vector plane_normal = PlayerTouchWall(actor);

		if(plane_normal != '0 0 0')
		{
			float wj_force = 270;
			float wj_xy_factor = 1.15;
			float wj_z_factor = 0.5;
			actor.velocity_x += plane_normal_x * wj_force;
			actor.velocity_x /= wj_xy_factor;
			actor.velocity_y += plane_normal_y * wj_force;
			actor.velocity_y /= wj_xy_factor;
			actor.velocity_z = 270 * wj_z_factor;

#ifdef SVQC
			STAT(QCC_LASTWJ, actor) = time;
			actor.oldvelocity = actor.velocity;
			Send_Effect(EFFECT_SMOKE_RING, trace_endpos, plane_normal, 5);
			//player_sound(actor, CH_PLAYER, "plyrjmp8.wav", ATTN_NORM);
#endif

			return true;
		}
	}
	return false;
}
