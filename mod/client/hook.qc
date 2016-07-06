AUTOCVAR_SAVE(cl_prohook, bool, false, "Replace grappling hook textures with a simpler 'pro' ones");
AUTOCVAR_SAVE(cl_nexuizhook, bool, false, "Replace grappling hook textures with a the old Nexuiz hook");

REGISTER_MUTATOR(cl_hooks, true);

MUTATOR_HOOKFUNCTION(cl_hooks, DrawGrapplingHook)
{
	entity thehook = M_ARGV(0, entity);
	if(thehook.HookType != NET_ENT_CLIENT_HOOK)
		return;

	float t = M_ARGV(3, float);

	if(autocvar_cl_prohook)
	{
		// we don't need to adjust colours here, already done by main code
		switch(t)
		{
			case NUM_TEAM_1: M_ARGV(1, string) = "particles/hook_red_pro"; break;
			case NUM_TEAM_2: M_ARGV(1, string) = "particles/hook_blue_pro"; break;
			case NUM_TEAM_3: M_ARGV(1, string) = "particles/hook_yellow_pro"; break;
			case NUM_TEAM_4: M_ARGV(1, string) = "particles/hook_pink_pro"; break;
			default: M_ARGV(1, string) = "particles/hook_white_pro"; break;
		}

		return; // don't do other hooks?
	}

	if(autocvar_cl_nexuizhook)
	{
		// we don't need to adjust colours here, already done by main code
		switch(t)
		{
			case NUM_TEAM_1: M_ARGV(1, string) = "particles/hook_red_nexuiz"; break;
			case NUM_TEAM_2: M_ARGV(1, string) = "particles/hook_blue_nexuiz"; break;
			case NUM_TEAM_3: M_ARGV(1, string) = "particles/hook_yellow_nexuiz"; break;
			case NUM_TEAM_4: M_ARGV(1, string) = "particles/hook_pink_nexuiz"; break;
			default: M_ARGV(1, string) = "particles/hook_white_nexuiz"; break;
		}

		return; // don't do other hooks?
	}
}
