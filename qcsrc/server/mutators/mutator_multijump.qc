.float multijump_count;
.float multijump_ready;
.float cvar_cl_multijump;

MUTATOR_HOOKFUNCTION(multijump_PlayerPhysics)
{
	if(self.flags & FL_ONGROUND)
	{
		if (autocvar_g_multijump > 0)
			self.multijump_count = 0;
		else
			self.multijump_count = -2; // the cvar value for infinite jumps is -1, so this needs to be smaller
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(multijump_PlayerJump)
{
	if (self.cvar_cl_multijump)
	if (self.flags & FL_JUMPRELEASED && !(self.flags & FL_ONGROUND)) // jump button pressed this frame and we are in midair
		self.multijump_ready = TRUE;  // this is necessary to check that we released the jump button and pressed it again
	else
		self.multijump_ready = FALSE;

	if(!player_multijump && self.multijump_ready && self.multijump_count < autocvar_g_multijump && self.velocity_z > autocvar_g_multijump_speed && vlen(self.velocity) <= autocvar_g_multijump_maxspeed)
	{
		if (autocvar_g_multijump)
		if (self.cvar_cl_multijump)
		{
			if (autocvar_g_multijump_add == 0) // in this case we make the z velocity == jumpvelocity
			{
				if (self.velocity_z < autocvar_sv_jumpvelocity)
				{
					player_multijump = TRUE;
					self.velocity_z = 0;
				}
			}
			else
				player_multijump = TRUE;

			if(player_multijump)
			{
				if(self.movement_x != 0 || self.movement_y != 0) // don't remove all speed if player isnt pressing any movement keys
				{
					float curspeed;
					vector wishvel, wishdir;

					curspeed = max(
						vlen(vec2(self.velocity)), // current xy speed
						vlen(vec2(antilag_takebackavgvelocity(self, max(self.lastteleporttime + sys_frametime, time - 0.25), time))) // average xy topspeed over the last 0.25 secs
					);
					makevectors(self.v_angle_y * '0 1 0');
					wishvel = v_forward * self.movement_x + v_right * self.movement_y;
					wishdir = normalize(wishvel);

					self.velocity_x = wishdir_x * curspeed; // allow "dodging" at a multijump
					self.velocity_y = wishdir_y * curspeed;
					// keep velocity_z unchanged!
				}
				if (autocvar_g_multijump > 0)
					self.multijump_count += 1;
			}
		}
		self.multijump_ready = FALSE; // require releasing and pressing the jump button again for the next jump
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(multijump_GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_multijump, "cl_multijump");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(multijump_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":multijump");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(multijump_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Multi jump");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_multijump)
{
	MUTATOR_HOOK(PlayerPhysics, multijump_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerJump, multijump_PlayerJump, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetCvars, multijump_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, multijump_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, multijump_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return FALSE;
}
