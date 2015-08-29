#ifdef CSQC
REGISTER_MUTATOR(walljump, true);

#define PHYS_WALLJUMP 						getstati(STAT_WALLJUMP)
#define PHYS_WALLJUMP_VELOCITY_Z_FACTOR 	getstatf(STAT_WALLJUMP_VELOCITY_Z_FACTOR)
#define PHYS_WALLJUMP_VELOCITY_XY_FACTOR 	getstatf(STAT_WALLJUMP_VELOCITY_XY_FACTOR)
#define PHYS_WALLJUMP_DELAY 				getstatf(STAT_WALLJUMP_DELAY)
#define PHYS_WALLJUMP_FORCE 				getstatf(STAT_WALLJUMP_FORCE)

#elif defined(SVQC)
void walljump_AddStats();
REGISTER_MUTATOR(walljump, cvar("g_walljump"))
{
	MUTATOR_ONADD
	{
		walljump_AddStats();
	}
}

bool autocvar_g_walljump;
float autocvar_g_walljump_delay;
float autocvar_g_walljump_force;
float autocvar_g_walljump_velocity_xy_factor;
float autocvar_g_walljump_velocity_z_factor;

#define PHYS_WALLJUMP 						autocvar_g_walljump
#define PHYS_WALLJUMP_VELOCITY_Z_FACTOR 	autocvar_g_walljump_velocity_z_factor
#define PHYS_WALLJUMP_VELOCITY_XY_FACTOR 	autocvar_g_walljump_velocity_xy_factor
#define PHYS_WALLJUMP_DELAY 				autocvar_g_walljump_delay
#define PHYS_WALLJUMP_FORCE 				autocvar_g_walljump_force


.bool stat_walljump;
.float stat_walljump_velocity_xy_factor;
.float stat_walljump_velocity_z_factor;
.float stat_walljump_delay;
.float stat_walljump_force;

void walljump_UpdateStats()
{
	self.stat_walljump = PHYS_WALLJUMP;
	self.stat_walljump_velocity_xy_factor = PHYS_WALLJUMP_VELOCITY_XY_FACTOR;
	self.stat_walljump_velocity_z_factor = PHYS_WALLJUMP_VELOCITY_Z_FACTOR;
	self.stat_walljump_delay = PHYS_WALLJUMP_DELAY;
	self.stat_walljump_force = PHYS_WALLJUMP_FORCE;
}

void walljump_AddStats()
{
	addstat(STAT_WALLJUMP, AS_INT, stat_walljump);
	addstat(STAT_WALLJUMP_VELOCITY_XY_FACTOR, AS_FLOAT, stat_walljump_velocity_xy_factor);
	addstat(STAT_WALLJUMP_VELOCITY_Z_FACTOR, AS_FLOAT, stat_walljump_velocity_z_factor);
	addstat(STAT_WALLJUMP_DELAY, AS_FLOAT, stat_walljump_delay);
	addstat(STAT_WALLJUMP_FORCE, AS_FLOAT, stat_walljump_force);
}

#endif

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
	if(PHYS_WALLJUMP)
	if(time - self.lastwj > PHYS_WALLJUMP_DELAY) // can't do this on client, as it's too stupid to obey counters
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
			float wj_force = PHYS_WALLJUMP_FORCE;
			float wj_xy_factor = PHYS_WALLJUMP_VELOCITY_XY_FACTOR;
			float wj_z_factor = PHYS_WALLJUMP_VELOCITY_Z_FACTOR;
			self.velocity_x += plane_normal_x * wj_force;
			self.velocity_x /= wj_xy_factor;
			self.velocity_y += plane_normal_y * wj_force;
			self.velocity_y /= wj_xy_factor;
			self.velocity_z = PHYS_JUMPVELOCITY * wj_z_factor;
			if(PHYS_INPUT_BUTTON_CROUCH(self)) self.velocity_z *= -1;

#ifdef SVQC
			self.oldvelocity = self.velocity;
			Send_Effect("smoke_ring", trace_endpos, plane_normal, 5);
			PlayerSound(playersound_jump, CH_PLAYER, VOICETYPE_PLAYERSOUND);
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

#ifdef SVQC
MUTATOR_HOOKFUNCTION(walljump, PlayerPhysics)
{
	walljump_UpdateStats();
	return false;
}
#endif
