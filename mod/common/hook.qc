#ifdef SVQC
.int cvar_cl_customhook;
REPLICATE(cvar_cl_customhook, int, "cl_customhook");
#elif defined(CSQC)
.int hook_type;
#endif

ENTCS_PROP(HOOKTYPE, true, cvar_cl_customhook, ENTCS_SET_NORMAL,
	{ WriteByte(chan, ent.cvar_cl_customhook); },
	{ ent.hook_type = ReadByte(); })

#ifdef CSQC
AUTOCVAR_SAVE(cl_customhook, int, 0, "Replace grappling hook textures, 0=normal, 1='pro', 2=nexuiz, 3=muffins");
AUTOCVAR_SAVE(cl_customhook_perplayer, bool, true, "Show other player's hook selections");

REGISTER_MUTATOR(cl_hooks, true);

STATIC_INIT(cl_hooks_compat)
{
	localcmd("\nalias cl_hook \"cl_customhook ${* ?}; sendcvar cl_customhook\"\n");

	if(autocvar_cl_customhook)
		return;

	if(cvar_type("cl_prohook") & CVAR_TYPEFLAG_EXISTS)
	if(cvar("cl_prohook"))
		cvar_set("cl_customhook", "1");

	if(cvar_type("cl_nexuizhook") & CVAR_TYPEFLAG_EXISTS)
	if(cvar("cl_nexuizhook"))
		cvar_set("cl_customhook", "2");
}

MUTATOR_HOOKFUNCTION(cl_hooks, DrawGrapplingHook)
{
	entity thehook = M_ARGV(0, entity);
	if(thehook.HookType != NET_ENT_CLIENT_HOOK)
		return;

	float t = M_ARGV(3, float);
	int hooktype = autocvar_cl_customhook;
	int ownnum = thehook.owner.sv_entnum;

	if((ownnum + 1) != player_localentnum && autocvar_cl_customhook_perplayer)
	{
		entity e = entcs_receiver(ownnum);
		if(e && e.hook_type)
			hooktype = e.hook_type;
	}

	if(hooktype == 1)
	{
		// we don't need to adjust colours here, already done by main code
		switch(t)
		{
			case NUM_TEAM_1: M_ARGV(1, string) = "particles/hook_red_pro"; break;
			case NUM_TEAM_2: M_ARGV(1, string) = "particles/hook_blue_pro"; break;
			case NUM_TEAM_3: M_ARGV(1, string) = "particles/hook_yellow_pro"; break;
			case NUM_TEAM_4: M_ARGV(1, string) = "particles/hook_pink_pro"; break;
			default: 		 M_ARGV(1, string) = "particles/hook_white_pro"; break;
		}

		return; // don't do other hooks?
	}

	if(hooktype == 2)
	{
		// we don't need to adjust colours here, already done by main code
		switch(t)
		{
			case NUM_TEAM_1: M_ARGV(1, string) = "particles/hook_red_nexuiz"; break;
			case NUM_TEAM_2: M_ARGV(1, string) = "particles/hook_blue_nexuiz"; break;
			case NUM_TEAM_3: M_ARGV(1, string) = "particles/hook_yellow_nexuiz"; break;
			case NUM_TEAM_4: M_ARGV(1, string) = "particles/hook_pink_nexuiz"; break;
			default: 		 M_ARGV(1, string) = "particles/hook_white_nexuiz"; break;
		}

		return; // don't do other hooks?
	}

	if(hooktype == 3)
	{
		// we don't need to adjust colours here, already done by main code
		switch(t)
		{
			case NUM_TEAM_1: M_ARGV(1, string) = "particles/hook_red_floxy"; break;
			case NUM_TEAM_2: M_ARGV(1, string) = "particles/hook_blue_floxy"; break;
			case NUM_TEAM_3: M_ARGV(1, string) = "particles/hook_yellow_floxy"; break;
			case NUM_TEAM_4: M_ARGV(1, string) = "particles/hook_pink_floxy"; break;
			default: 		 M_ARGV(1, string) = "particles/hook_white_floxy"; break;
		}

		return; // don't do other hooks?
	}
}
#endif
