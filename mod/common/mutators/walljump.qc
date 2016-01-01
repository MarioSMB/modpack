#ifdef CSQC
REGISTER_MUTATOR(walljump, true);
#elif defined(SVQC)
REGISTER_MUTATOR(walljump, cvar("g_walljump"));

AUTOCVAR(g_walljump, bool, false, _("Enable wall jumping mutator"));
AUTOCVAR(g_walljump_delay, float, 1, _("Minimum delay between wall jumps"));
AUTOCVAR(g_walljump_force, float, 300, _("How far to bounce/jump off the wall"));
AUTOCVAR(g_walljump_velocity_xy_factor, float, 1.15, _("How much to slow down along horizontal axis, higher value = higher deceleration, if factor is < 1, you accelerate by wall jumping"));
AUTOCVAR(g_walljump_velocity_z_factor, float, 0.5, _("Upwards velocity factor, multiplied by normal jump velocity"));
#endif

#define PHYS_WALLJUMP(s) 						STAT(WALLJUMP, s)
#define PHYS_WALLJUMP_VELOCITY_Z_FACTOR(s) 		STAT(WALLJUMP_VELOCITY_Z_FACTOR, s)
#define PHYS_WALLJUMP_VELOCITY_XY_FACTOR(s) 	STAT(WALLJUMP_VELOCITY_XY_FACTOR, s)
#define PHYS_WALLJUMP_DELAY(s) 					STAT(WALLJUMP_DELAY, s)
#define PHYS_WALLJUMP_FORCE(s) 					STAT(WALLJUMP_FORCE, s)

REGISTER_STAT(WALLJUMP, int, autocvar_g_walljump)
REGISTER_STAT(WALLJUMP_VELOCITY_Z_FACTOR, float, autocvar_g_walljump_velocity_z_factor)
REGISTER_STAT(WALLJUMP_VELOCITY_XY_FACTOR, float, autocvar_g_walljump_velocity_xy_factor)
REGISTER_STAT(WALLJUMP_DELAY, float, autocvar_g_walljump_delay)
REGISTER_STAT(WALLJUMP_FORCE, float, autocvar_g_walljump_force)

.float lastwj;

vector PlayerTouchWall(entity this)
{
	local float dist, max_normal;
	local vector start, end;
	dist = 10;
	max_normal = 0.2;
	start = this.origin;
	end = start + v_forward * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vlen (this.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_forward * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vlen (this.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start + v_right * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vlen (this.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_right * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vlen (this.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	return '0 0 0';
}

void PM_walljump_PlayerJump(entity this)
{
	if(PHYS_WALLJUMP(this))
	if(time - this.lastwj > PHYS_WALLJUMP_DELAY(this)) // can't do this on client, as it's too stupid to obey counters
	if(!IS_ONGROUND(this))
#ifdef SVQC
	if(this.movetype != MOVETYPE_NONE && this.movetype != MOVETYPE_FOLLOW && this.movetype != MOVETYPE_FLY && this.movetype != MOVETYPE_NOCLIP)
#endif
	if(!IS_JUMP_HELD(this))
	if(!STAT(FROZEN, this))
	if(!IS_DEAD(this))
	{
		vector plane_normal = PlayerTouchWall(this);
		
		if(plane_normal != '0 0 0')
		{
			this.lastwj = time;
			float wj_force = PHYS_WALLJUMP_FORCE(this);
			float wj_xy_factor = PHYS_WALLJUMP_VELOCITY_XY_FACTOR(this);
			float wj_z_factor = PHYS_WALLJUMP_VELOCITY_Z_FACTOR(this);
			this.velocity_x += plane_normal_x * wj_force;
			this.velocity_x /= wj_xy_factor;
			this.velocity_y += plane_normal_y * wj_force;
			this.velocity_y /= wj_xy_factor;
			this.velocity_z = PHYS_JUMPVELOCITY(this) * wj_z_factor;
			if(PHYS_INPUT_BUTTON_CROUCH(this)) this.velocity_z *= -1;

#ifdef SVQC
			this.oldvelocity = this.velocity;
			Send_Effect(EFFECT_SMOKE_RING, trace_endpos, plane_normal, 5);
			PlayerSound(this, playersound_jump, CH_PLAYER, VOICETYPE_PLAYERSOUND);
			animdecide_setaction(this, ANIMACTION_JUMP, true);
#endif
			
			player_multijump = true;
		}
	}
}

MUTATOR_HOOKFUNCTION(walljump, PlayerJump)
{
	PM_walljump_PlayerJump(self);
	return false;
}
