void cpmodels_Precache();
REGISTER_MUTATOR(cpmodels, true)
{
	MUTATOR_ONADD
	{
		cpmodels_Precache();
	}
}

AUTOCVAR(sv_allow_customplayermodels, bool, false, "");
AUTOCVAR(sv_allow_customplayermodels_bots, bool, true, "");
AUTOCVAR(sv_allow_customplayermodels_idlist, string, "", "");
AUTOCVAR(sv_allow_customplayermodels_speciallist, string, "", "");

bool pony_allowed;
bool weegee_allowed;
bool rosa_allowed;
bool cow_allowed;
bool use_botmodel;

void cpmodels_Precache()
{
	if(fexists("models/player/cow.md3"))
	{
		cow_allowed = true;
		precache_playermodel("models/player/cow.md3");
	}

	if(cvar("sv_allow_customplayermodels"))
	{
		if(fexists("models/player/pony.iqm"))
		{
			pony_allowed = true;
			precache_playermodel("models/player/pony.iqm");
		}
		precache_playermodel("models/player/renamon.iqm");
		precache_playermodel("models/player/terminusmale.iqm");
		precache_playermodel("models/player/ubot.iqm");
		precache_playermodel("models/player/rosalina.dpm");
		precache_playermodel("models/player/draconimale.iqm");

		if(fexists("models/player/ubot.iqm"))
		{
			use_botmodel = true;
			precache_playermodel("models/player/ubot.iqm");
		}

		if(fexists("models/player/luigi.dpm"))
		{
			weegee_allowed = true;
			precache_playermodel("models/player/luigi.dpm");
		}

		if(fexists("models/player/rosalina.dpm"))
		{
			rosa_allowed = true;
			precache_playermodel("models/player/rosalina.dpm");
		}
	}
}

.bool cvar_cl_pony;
.int cvar_cl_pony_skin;
.bool cvar_cl_robot;
.bool cvar_cl_thestars;
.int cvar_cl_sparkle;
.bool cvar_cl_goat;
.bool cvar_cl_damnfurries;
.bool cow;

MUTATOR_HOOKFUNCTION(cpmodels, FormatMessage)
{SELFPARAM();
	if(format_message == "moo")
		self.cow = true;

	return false;
}

MUTATOR_HOOKFUNCTION(cpmodels, GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_pony, "cl_pony");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_pony_skin, "cl_pony_skin");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_robot, "cl_robot");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_thestars, "cl_thestars");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_sparkle, "cl_sparkle");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_goat, "cl_goat");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_damnfurries, "cl_damnfurries");
	return false;
}

MUTATOR_HOOKFUNCTION(cpmodels, FixPlayermodel)
{SELFPARAM();
	if(autocvar_sv_allow_customplayermodels)
	if(!cvar("g_overkill"))
	{
		// public hax
		// stuff anyone can use
		if(self.cvar_cl_pony && pony_allowed)
		{
			ret_string = "models/player/pony.iqm";
			ret_int = self.cvar_cl_pony_skin;
		}
		if(self.cvar_cl_robot == 1)
			ret_string = "models/player/terminusmale.iqm";
		if(self.cvar_cl_goat)
			ret_string = "models/player/draconimale.iqm";

		if(use_botmodel && IS_BOT_CLIENT(self) && autocvar_sv_allow_customplayermodels_bots)
			ret_string = "models/player/ubot.iqm";

		// special hax
		if(strhasword(self.crypto_idfp, autocvar_sv_allow_customplayermodels_idlist))
		{
			if(self.cvar_cl_thestars == 1)
			{
				if(autocvar_g_fullbrightplayers && autocvar_g_player_brightness)
					self.colormod = '0.7 0.7 0.7'; // regular brightness is way too bright here
				ret_string = "models/player/rosalina.dpm";
			}
			if(self.cvar_cl_damnfurries == 1)
				ret_string = "models/player/renamon.iqm";
		}
		else if(self.model == "models/player/renamon.iqm")
		{
			ret_string = autocvar_sv_defaultplayermodel;
		}
		if(strhasword(self.crypto_idfp, autocvar_sv_allow_customplayermodels_speciallist))
		{
			if(self.cvar_cl_sparkle >= 4 && weegee_allowed)
				ret_string = "models/player/luigi.dpm";
		}
	}

	if(!cvar("g_overkill") && self.cow && cow_allowed)
		ret_string = "models/player/cow.md3";

	return false;
}

MUTATOR_HOOKFUNCTION(cpmodels, PlayerSpawn)
{SELFPARAM();
	if(self.cvar_cl_sparkle >= 1 && strhasword(self.crypto_idfp, autocvar_sv_allow_customplayermodels_speciallist))
		self.effects |= EF_STARDUST;

	if(self.cvar_cl_sparkle == 2 && strhasword(self.crypto_idfp, autocvar_sv_allow_customplayermodels_speciallist))
		self.colormap = 4351;

	return false;
}
