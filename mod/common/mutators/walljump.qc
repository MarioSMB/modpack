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

vector PlayerTouchWall ()
{
	local float dist, max_normal;
	local vector start, end;
	dist = 10;
	max_normal = 0.2;
	start = self.origin;
	end = start + v_forward * 100;
	tracebox (start, self.mins, self.maxs, end, true, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_forward * 100;
	tracebox (start, self.mins, self.maxs, end, true, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start + v_right * 100;
	tracebox (start, self.mins, self.maxs, end, true, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_right * 100;
	tracebox (start, self.mins, self.maxs, end, true, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	return '0 0 0';
}

void PM_walljump_PlayerJump()
{
	if(PHYS_WALLJUMP(self))
	if(time - self.lastwj > PHYS_WALLJUMP_DELAY(self)) // can't do this on client, as it's too stupid to obey counters
	if(!IS_ONGROUND(self))
#ifdef SVQC
	if(self.movetype != MOVETYPE_NONE && self.movetype != MOVETYPE_FOLLOW && self.movetype != MOVETYPE_FLY && self.movetype != MOVETYPE_NOCLIP)
#endif
	if(!IS_JUMP_HELD(self))
	if(!PHYS_FROZEN(self))
	if(!PHYS_DEAD(self))
	{
		vector plane_normal = PlayerTouchWall();
		
		if(plane_normal != '0 0 0')
		{
			self.lastwj = time;
			float wj_force = PHYS_WALLJUMP_FORCE(self);
			float wj_xy_factor = PHYS_WALLJUMP_VELOCITY_XY_FACTOR(self);
			float wj_z_factor = PHYS_WALLJUMP_VELOCITY_Z_FACTOR(self);
			self.velocity_x += plane_normal_x * wj_force;
			self.velocity_x /= wj_xy_factor;
			self.velocity_y += plane_normal_y * wj_force;
			self.velocity_y /= wj_xy_factor;
			self.velocity_z = PHYS_JUMPVELOCITY(self) * wj_z_factor;
			if(PHYS_INPUT_BUTTON_CROUCH(self)) self.velocity_z *= -1;

#ifdef SVQC
			self.oldvelocity = self.velocity;
			Send_Effect(EFFECT_SMOKE_RING, trace_endpos, plane_normal, 5);
			PlayerSound(self, playersound_jump, CH_PLAYER, VOICETYPE_PLAYERSOUND);
			animdecide_setaction(self, ANIMACTION_JUMP, true);
#endif
			
			player_multijump = true;
		}
	}
}

MUTATOR_HOOKFUNCTION(walljump, PlayerJump)
{
	PM_walljump_PlayerJump();
	return false;
}
