#ifdef GAMEQC
#ifdef SVQC
AUTOCVAR(sv_jumpvelocity_crouch, float, 600, "");
int models_allowed;
#endif

REGISTER_STAT(JUMPVELOCITY_CROUCH, float, autocvar_sv_jumpvelocity_crouch);
REGISTER_STAT(MODELS_ALLOWED, int, models_allowed);

// TODO
SOUND(MARIO_CJUMP, "player/mario/player/jump7");

const int MODELS_PONY = BIT(0);
const int MODELS_WEEGEE = BIT(1);
const int MODELS_ROSALINA = BIT(2);
const int MODELS_COW = BIT(3);
const int MODELS_GOAT = BIT(4);
const int MODELS_ROBOT = BIT(5);
const int MODELS_RENAMON = BIT(6);
const int MODELS_BOT = BIT(7);
const int MODELS_MARIO = BIT(8);
const int MODELS_BEAR = BIT(9);
#endif

#ifdef SVQC

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
		CHECK_MODEL("bear.dpm", BEAR)
	}
#undef CHECK_MODEL
}

//ATTRIB(Client, cvar_cl_pony, bool, this.cvar_cl_pony);
//ATTRIB(Client, cvar_cl_pony_skin, int, this.cvar_cl_pony_skin);
//ATTRIB(Client, cvar_cl_robot, bool, this.cvar_cl_robot);
//ATTRIB(Client, cvar_cl_thestars, bool, this.cvar_cl_thestars);
//ATTRIB(Client, cvar_cl_sparkle, int, this.cvar_cl_sparkle);
//ATTRIB(Client, cvar_cl_goat, bool, this.cvar_cl_goat);
//ATTRIB(Client, cvar_cl_damnfurries, bool, this.cvar_cl_damnfurries);
//ATTRIB(Client, cvar_cl_brothersbear, bool, this.cvar_cl_brothersbear);
//ATTRIB(Client, cow, bool, this.cow);

.bool cvar_cl_pony;
.int cvar_cl_pony_skin;
.bool cvar_cl_robot;
.bool cvar_cl_thestars;
.int cvar_cl_sparkle;
.bool cvar_cl_goat;
.bool cvar_cl_damnfurries;
.bool cvar_cl_brothersbear;
.bool cow;

REPLICATE(cvar_cl_pony, bool, "cl_pony");
REPLICATE(cvar_cl_pony_skin, int, "cl_pony_skin");
REPLICATE(cvar_cl_robot, bool, "cl_robot");
REPLICATE(cvar_cl_thestars, bool, "cl_thestars");
REPLICATE(cvar_cl_sparkle, int, "cl_sparkle");
REPLICATE(cvar_cl_goat, bool, "cl_goat");
REPLICATE(cvar_cl_damnfurries, bool, "cl_damnfurries");
REPLICATE(cvar_cl_brothersbear, bool, "cl_brothersbear");

MUTATOR_HOOKFUNCTION(cpmodels, FormatMessage)
{
	entity player = M_ARGV(0, entity);
	string format_message = M_ARGV(3, string);

	if(format_message == "moo")
		CS(player).cow = true;
}

MUTATOR_HOOKFUNCTION(cpmodels, FixPlayermodel)
{
	string ret_string = M_ARGV(0, string);
	int ret_int = M_ARGV(1, int);
	entity player = M_ARGV(2, entity);

	if(autocvar_sv_allow_customplayermodels)
	if(!cvar("g_overkill"))
	{
#define ALLOWED(d) (models_allowed & MODELS_##d)
		// public hax
		// stuff anyone can use
		if(CS(player).cvar_cl_pony && ALLOWED(PONY))
		{
			ret_string = "models/player/pony.iqm";
			ret_int = CS(player).cvar_cl_pony_skin;
		}
		if(CS(player).cvar_cl_robot == 1 && ALLOWED(ROBOT))
			ret_string = "models/player/terminusmale.iqm";
		if(CS(player).cvar_cl_goat && ALLOWED(GOAT))
			ret_string = "models/player/draconimale.iqm";

		if(ALLOWED(BOT) && IS_BOT_CLIENT(player) && autocvar_sv_allow_customplayermodels_bots)
			ret_string = "models/player/ubot.iqm";

		// special hax
		if(PlayerInList(player, autocvar_sv_allow_customplayermodels_idlist))
		{
			if(CS(player).cvar_cl_thestars == 1 && ALLOWED(ROSALINA))
			{
				if(autocvar_g_fullbrightplayers && autocvar_g_player_brightness)
					player.colormod = '0.7 0.7 0.7'; // regular brightness is way too bright here
				ret_string = "models/player/rosalina.dpm";
			}
			if(CS(player).cvar_cl_damnfurries == 1 && ALLOWED(RENAMON))
				ret_string = "models/player/renamon.iqm";
		}
		else if(player.playermodel == "models/player/renamon.iqm")
		{
			ret_string = autocvar_sv_defaultplayermodel;
		}
		if(PlayerInList(player, autocvar_sv_allow_customplayermodels_speciallist))
		{
			if(CS(player).cvar_cl_sparkle == 3 && ALLOWED(MARIO))
				ret_string = "models/player/mario.dpm";
			if(CS(player).cvar_cl_sparkle >= 4 && ALLOWED(WEEGEE))
				ret_string = "models/player/luigi.dpm";
			if(CS(player).cvar_cl_brothersbear && ALLOWED(BEAR))
				ret_string = "models/player/bear.dpm";
		}
	}

	if(player.playermodel == "models/player/mario.dpm" && !PlayerInList(player, autocvar_sv_allow_customplayermodels_speciallist))
		ret_string = autocvar_sv_defaultplayermodel;

	if(player.playermodel == "models/player/bear.dpm" && !PlayerInList(player, autocvar_sv_allow_customplayermodels_speciallist))
		ret_string = autocvar_sv_defaultplayermodel;

	if(!cvar("g_overkill") && CS(player).cow && ALLOWED(COW))
		ret_string = "models/player/cow.md3";

	M_ARGV(0, string) = ret_string;
	M_ARGV(1, int) = ret_int;

#undef ALLOWED
}

MUTATOR_HOOKFUNCTION(cpmodels, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	if(CS(player).cvar_cl_sparkle >= 1 && PlayerInList(player, autocvar_sv_allow_customplayermodels_speciallist))
		player.effects |= EF_STARDUST;

	if(CS(player).cvar_cl_sparkle == 2 && PlayerInList(player, autocvar_sv_allow_customplayermodels_speciallist))
		player.colormap = 4351;
}

#endif

#ifdef CSQC
REGISTER_MUTATOR(cpmodels, true);

int autocvar_cl_sparkle;
#endif

#ifdef GAMEQC
MUTATOR_HOOKFUNCTION(cpmodels, PlayerJump, CBC_ORDER_LAST)
{
	if(M_ARGV(2, bool))
		return false; // no double jumping

	entity player = M_ARGV(0, entity);

	if(STAT(JUMPVELOCITY_CROUCH, player) && PHYS_INPUT_BUTTON_CROUCH(player) && IS_ONGROUND(player) && vdist(player.velocity, <, PHYS_MAXSPEED(player) * 0.6) &&
		player.model == "models/player/mario.dpm" && (STAT(MODELS_ALLOWED, player) & MODELS_MARIO) &&
#ifdef SVQC
		!g_cts && !g_race && CS(player).cvar_cl_sparkle == 3
#elif defined(CSQC)
		gametype != MAPINFO_TYPE_CTS && gametype != MAPINFO_TYPE_RACE && autocvar_cl_sparkle == 3
#endif
		)
	{
		M_ARGV(1, float) = STAT(JUMPVELOCITY_CROUCH, player);
		makevectors(PHYS_WORLD_ANGLES(player));
		player.velocity -= v_forward * 50;
	#ifdef SVQC
		sound(player, CH_VOICE, SND_MARIO_CJUMP, VOL_BASE, ATTEN_NORM);
	#endif
	}
}
#endif
