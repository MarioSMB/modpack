#ifdef CSQC
REGISTER_MUTATOR(walljump, true);
#elif defined(SVQC)
REGISTER_MUTATOR(walljump, cvar("g_walljump"));

AUTOCVAR(g_walljump, bool, false, "Enable wall jumping mutator");
AUTOCVAR(g_walljump_delay, float, 1, "Minimum delay between wall jumps");
AUTOCVAR(g_walljump_force, float, 300, "How far to bounce/jump off the wall");
AUTOCVAR(g_walljump_velocity_xy_factor, float, 1.15, "How much to slow down along horizontal axis, higher value = higher deceleration, if factor is < 1, you accelerate by wall jumping");
AUTOCVAR(g_walljump_velocity_z_factor, float, 0.5, "Upwards velocity factor, multiplied by normal jump velocity");
#endif

.float lastwj;

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
REGISTER_STAT(LASTWJ, float, this.lastwj)

vector PlayerTouchWall(entity this)
{
	local float dist, max_normal;
	local vector start, end;
	dist = 10;
	max_normal = 0.2;
	start = this.origin;
	end = start + v_forward * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vdist(this.origin - trace_endpos, <, dist) && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_forward * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vdist(this.origin - trace_endpos, <, dist) && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start + v_right * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vdist(this.origin - trace_endpos, <, dist) && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_right * 100;
	tracebox (start, this.mins, this.maxs, end, true, this);
	if (trace_fraction < 1 && vdist(this.origin - trace_endpos, <, dist) && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	return '0 0 0';
}

MUTATOR_HOOKFUNCTION(walljump, PlayerJump)
{
	entity player = M_ARGV(0, entity);

#ifdef CSQC
	player.lastwj = STAT(LASTWJ, player);
#endif
	if(PHYS_WALLJUMP(player))
	if(time - player.lastwj > PHYS_WALLJUMP_DELAY(player)) // can't do this on client, as it's too stupid to obey counters
	if(!IS_ONGROUND(player))
#ifdef SVQC
	if(player.movetype != MOVETYPE_NONE && player.movetype != MOVETYPE_FOLLOW && player.movetype != MOVETYPE_FLY && player.movetype != MOVETYPE_NOCLIP)
#elif defined(CSQC)
	if(player.move_movetype != MOVETYPE_NONE && player.move_movetype != MOVETYPE_FOLLOW && player.move_movetype != MOVETYPE_FLY && player.move_movetype != MOVETYPE_NOCLIP)
#endif
	if(!IS_JUMP_HELD(player))
	if(!STAT(FROZEN, player))
	if(!IS_DEAD(player))
	{
		vector plane_normal = PlayerTouchWall(player);
		
		if(plane_normal != '0 0 0')
		{
			player.lastwj = time;
			float wj_force = PHYS_WALLJUMP_FORCE(player);
			float wj_xy_factor = PHYS_WALLJUMP_VELOCITY_XY_FACTOR(player);
			float wj_z_factor = PHYS_WALLJUMP_VELOCITY_Z_FACTOR(player);
			player.velocity_x += plane_normal_x * wj_force;
			player.velocity_x /= wj_xy_factor;
			player.velocity_y += plane_normal_y * wj_force;
			player.velocity_y /= wj_xy_factor;
			player.velocity_z = PHYS_JUMPVELOCITY(player) * wj_z_factor;
			if(PHYS_INPUT_BUTTON_CROUCH(player)) player.velocity_z *= -1;

#ifdef SVQC
			player.oldvelocity = player.velocity;
			Send_Effect(EFFECT_SMOKE_RING, trace_endpos, plane_normal, 5);
			PlayerSound(player, playersound_jump, CH_PLAYER, VOL_BASE, VOICETYPE_PLAYERSOUND);
			animdecide_setaction(player, ANIMACTION_JUMP, true);
#endif
			
			M_ARGV(2, bool) = true; // multijump
		}
	}
}
