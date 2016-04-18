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

int models_allowed;
const int MODELS_PONY = BIT(0);
const int MODELS_WEEGEE = BIT(1);
const int MODELS_ROSALINA = BIT(2);
const int MODELS_COW = BIT(3);
const int MODELS_GOAT = BIT(4);
const int MODELS_ROBOT = BIT(5);
const int MODELS_RENAMON = BIT(6);
const int MODELS_BOT = BIT(7);
const int MODELS_MARIO = BIT(8);

void cpmodels_Precache()
{
	models_allowed = 0;
#define CHECK_MODEL(d,o) \
	if(fexists(strcat("models/player/", d))) \
	{ \
		models_allowed |= MODELS_##o; \
		precache_playermodel(strcat("models/player/", d)); \
	}

	CHECK_MODEL("cow.md3", COW)

	if(cvar("sv_allow_customplayermodels"))
	{
		CHECK_MODEL("pony.iqm", PONY)
		CHECK_MODEL("renamon.iqm", RENAMON)
		CHECK_MODEL("terminusmale.iqm", ROBOT)
		CHECK_MODEL("draconimale.iqm", GOAT)
		CHECK_MODEL("ubot.iqm", BOT)
		CHECK_MODEL("luigi.dpm", WEEGEE)
		CHECK_MODEL("rosalina.dpm", ROSALINA)
		CHECK_MODEL("mario.dpm", MARIO)
	}
#undef CHECK_MODEL
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
#define ALLOWED(d) (models_allowed & MODELS_##d)
		// public hax
		// stuff anyone can use
		if(self.cvar_cl_pony && ALLOWED(PONY))
		{
			ret_string = "models/player/pony.iqm";
			ret_int = self.cvar_cl_pony_skin;
		}
		if(self.cvar_cl_robot == 1 && ALLOWED(ROBOT))
			ret_string = "models/player/terminusmale.iqm";
		if(self.cvar_cl_goat && ALLOWED(GOAT))
			ret_string = "models/player/draconimale.iqm";

		if(ALLOWED(BOT) && IS_BOT_CLIENT(self) && autocvar_sv_allow_customplayermodels_bots)
			ret_string = "models/player/ubot.iqm";

		// special hax
		if(strhasword(self.crypto_idfp, autocvar_sv_allow_customplayermodels_idlist))
		{
			if(self.cvar_cl_thestars == 1 && ALLOWED(ROSALINA))
			{
				if(autocvar_g_fullbrightplayers && autocvar_g_player_brightness)
					self.colormod = '0.7 0.7 0.7'; // regular brightness is way too bright here
				ret_string = "models/player/rosalina.dpm";
			}
			if(self.cvar_cl_damnfurries == 1 && ALLOWED(RENAMON))
				ret_string = "models/player/renamon.iqm";
		}
		else if(self.playermodel == "models/player/renamon.iqm")
		{
			ret_string = autocvar_sv_defaultplayermodel;
		}
		if(strhasword(self.crypto_idfp, autocvar_sv_allow_customplayermodels_speciallist))
		{
			if(self.cvar_cl_sparkle == 3 && ALLOWED(MARIO))
				ret_string = "models/player/mario.dpm";
			if(self.cvar_cl_sparkle >= 4 && ALLOWED(WEEGEE))
				ret_string = "models/player/luigi.dpm";
		}
	}

	if(self.playermodel == "models/player/mario.dpm" && !strhasword(self.crypto_idfp, autocvar_sv_allow_customplayermodels_speciallist))
		ret_string = autocvar_sv_defaultplayermodel;

	if(!cvar("g_overkill") && self.cow && ALLOWED(COW))
		ret_string = "models/player/cow.md3";

#undef ALLOWED

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
