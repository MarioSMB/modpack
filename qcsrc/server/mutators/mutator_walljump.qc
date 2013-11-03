.float lastwj;

vector PlayerTouchWall ()
{
	local float dist, max_normal;
	local vector start, end;
	dist = 10;
	max_normal = 0.2;
	start = self.origin;
	end = start + v_forward * 100;
	tracebox (start, self.mins, self.maxs, end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_forward * 100;
	tracebox (start, self.mins, self.maxs, end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start + v_right * 100;
	tracebox (start, self.mins, self.maxs, end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	end = start - v_right * 100;
	tracebox (start, self.mins, self.maxs, end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < dist && trace_plane_normal_z < max_normal)
	if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		return trace_plane_normal;
	return '0 0 0';
}

MUTATOR_HOOKFUNCTION(walljump_PlayerJump)
{
	if(autocvar_g_walljump)
	if(time - self.lastwj > autocvar_g_walljump_delay)
	if(!(self.flags & FL_ONGROUND))
	if(self.flags & FL_JUMPRELEASED)
	if(!self.frozen)
	if(self.deadflag == DEAD_NO)
	{
		vector plane_normal = PlayerTouchWall();
		
		if(plane_normal != '0 0 0')
		{
			self.lastwj = time;
			float wj_force = autocvar_g_walljump_force;
			float wj_xy_factor = autocvar_g_walljump_velocity_xy_factor;
			float wj_z_factor = autocvar_g_walljump_velocity_z_factor;
			self.velocity_x += plane_normal_x * wj_force;
			self.velocity_x /= wj_xy_factor;
			self.velocity_y += plane_normal_y * wj_force;
			self.velocity_y /= wj_xy_factor;
			self.velocity_z = autocvar_sv_jumpvelocity * wj_z_factor;
			if (self.crouch) self.velocity_z *= -1;
			self.oldvelocity = self.velocity;
		
			pointparticles(particleeffectnum("smoke_ring"), trace_endpos, plane_normal, 5);
			PlayerSound(playersound_jump, CH_PLAYER, VOICETYPE_PLAYERSOUND);
			animdecide_setaction(self, ANIMACTION_JUMP, TRUE);
			
			player_multijump = TRUE;
		}
	}
	
	return FALSE;
}

MUTATOR_DEFINITION(mutator_walljump)
{
	MUTATOR_HOOK(PlayerJump, walljump_PlayerJump, CBC_ORDER_ANY);

	return FALSE;
}
