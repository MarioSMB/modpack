//FEATURE: Persistent custom player models, so you can always show off that pony complexion!

#ifdef GAMEQC
AUTOCVAR(sv_jumpvelocity_backflip, float, 600, "");

#ifdef SVQC
int models_allowed;
bool g_overkill; // reliable check for overkill
#endif

//REGISTER_STAT(JUMPVELOCITY_CROUCH, float, autocvar_sv_jumpvelocity_backflip);
//REGISTER_STAT(MODELS_ALLOWED, int, models_allowed);

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
const int MODELS_MONK = BIT(10);
const int MODELS_NEXUS = BIT(11);
const int MODELS_IGGY = BIT(12);
#endif

#ifdef SVQC

REGISTER_MUTATOR(cpmodels, true);

AUTOCVAR(sv_allow_customplayermodels, bool, false, "");
AUTOCVAR(sv_allow_customplayermodels_bots, bool, true, "");
AUTOCVAR(sv_allow_customplayermodels_idlist, string, "", "");
AUTOCVAR(sv_allow_customplayermodels_speciallist, string, "", "");
AUTOCVAR(sv_smokeball_time, float, 2, "");
AUTOCVAR(sv_smokeball_refire, float, 10, "");
AUTOCVAR(sv_smokeball_alpha, float, 0, "");

PRECACHE(cpmodels_precache)
{
	g_overkill = MUTATOR_ok.mutatorcheck();
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
		CHECK_MODEL("monk2.dpm", MONK)
		CHECK_MODEL("nexus.zym", NEXUS)
		CHECK_MODEL("iggy.dpm", IGGY)
	}
#undef CHECK_MODEL
}

.string cvar_cl_model;
.int cvar_cl_pony_skin;
.int cvar_cl_sparkle;
.bool cow;

.float ninja_sneak;
.float ninja_cooldown;
.float ninja_prevalpha;

REPLICATE(cvar_cl_pony_skin, int, "cl_pony_skin");
REPLICATE(cvar_cl_sparkle, int, "cl_sparkle");
REPLICATE(cvar_cl_model, string, "cl_custommodel");

MUTATOR_HOOKFUNCTION(cpmodels, FormatMessage)
{
	entity player = M_ARGV(0, entity);
	string format_message = M_ARGV(3, string);

	if(format_message == "moo")
		CS(player).cow = true;
}

MUTATOR_HOOKFUNCTION(cpmodels, FixPlayermodel)
{
	if(autocvar_sv_allow_customplayermodels && !cvar("g_overkill"))
	{
		entity player = M_ARGV(2, entity);
#define ALLOWED(d) (models_allowed & MODELS_##d)
		// public hax
		// stuff anyone can use
		if(CS(player).cvar_cl_model == "pony" && ALLOWED(PONY))
		{
			M_ARGV(0, string) = "models/player/pony.iqm";
			M_ARGV(1, int) = CS(player).cvar_cl_pony_skin;
		}
		if(CS(player).cvar_cl_model == "robot" && ALLOWED(ROBOT))
			M_ARGV(0, string) = "models/player/terminusmale.iqm";
		if(CS(player).cvar_cl_model == "goat" && ALLOWED(GOAT))
			M_ARGV(0, string) = "models/player/draconimale.iqm";

		if(CS(player).cvar_cl_model == "monk" && ALLOWED(MONK))
			M_ARGV(0, string) = "models/player/monk2.dpm";

		if(CS(player).cvar_cl_model == "nexus" && ALLOWED(NEXUS))
			M_ARGV(0, string) = "models/player/nexus.zym";

		if(ALLOWED(BOT) && IS_BOT_CLIENT(player) && autocvar_sv_allow_customplayermodels_bots)
			M_ARGV(0, string) = "models/player/ubot.iqm";

		// special hax
		if(PlayerInList(player, autocvar_sv_allow_customplayermodels_idlist))
		{
			if(CS(player).cvar_cl_model == "rosalina" && ALLOWED(ROSALINA))
			{
				if(autocvar_g_fullbrightplayers && autocvar_g_player_brightness)
					player.colormod = '0.7 0.7 0.7'; // regular brightness is way too bright here
				M_ARGV(0, string) = "models/player/rosalina.dpm";
			}
			if(CS(player).cvar_cl_model == "foxy" && ALLOWED(RENAMON))
				M_ARGV(0, string) = "models/player/renamon.iqm";
			if(CS(player).cvar_cl_model == "iggy" && ALLOWED(IGGY))
				M_ARGV(0, string) = "models/player/iggy.dpm";
		}
		else if(player.playermodel == "models/player/renamon.iqm" || player.playermodel == "models/player/rosalina.dpm" || player.playermodel == "models/player/iggy.dpm")
			M_ARGV(0, string) = autocvar_sv_defaultplayermodel;

		if(PlayerInList(player, autocvar_sv_allow_customplayermodels_speciallist))
		{
			if(CS(player).cvar_cl_sparkle == 3 && ALLOWED(MARIO))
				M_ARGV(0, string) = "models/player/mario.dpm";
			if(CS(player).cvar_cl_sparkle >= 4 && ALLOWED(WEEGEE))
				M_ARGV(0, string) = "models/player/luigi.dpm";
			if(CS(player).cvar_cl_model == "bear" && ALLOWED(BEAR))
				M_ARGV(0, string) = "models/player/bear.dpm";
		}
		else if(player.playermodel == "models/player/mario.dpm" || player.playermodel == "models/player/bear.dpm" || player.playermodel == "models/player/luigi.dpm")
			M_ARGV(0, string) = autocvar_sv_defaultplayermodel;

		if(CS(player).cow && ALLOWED(COW))
			M_ARGV(0, string) = "models/player/cow.md3";
	}

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

MUTATOR_HOOKFUNCTION(cpmodels, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(time < player.ninja_sneak)
		player.alpha = ((autocvar_sv_smokeball_alpha) ? autocvar_sv_smokeball_alpha : -1);
	else if(player.ninja_sneak)
	{
		player.alpha = player.ninja_prevalpha;
		player.ninja_sneak = 0;
	}
}

MUTATOR_HOOKFUNCTION(cpmodels, PlayerUseKey)
{
	// NOTE: this doesn't stop if something else called use key, since it's supposed to always work!
	//if(MUTATOR_RETURNVALUE) return;
	if(game_stopped) return;

	entity player = M_ARGV(0, entity);

	if(time < player.ninja_cooldown || !PHYS_INPUT_BUTTON_CROUCH(player))
		return;

	if(player.model != "models/player/monk2.dpm" || !PlayerInList(player, autocvar_sv_allow_customplayermodels_speciallist))
		return;

	Send_Effect(EFFECT_SMOKE_RING, player.origin, '0 0 50', 2);
	sound(player, CH_TRIGGER, SND_NEXIMPACT, VOL_BASE, ATTN_NORM);
	player.ninja_sneak = time + autocvar_sv_smokeball_time;
	player.ninja_cooldown = time + autocvar_sv_smokeball_refire;
	player.ninja_prevalpha = player.alpha;
	player.alpha = ((autocvar_sv_smokeball_alpha) ? autocvar_sv_smokeball_alpha : -1);
	return true;
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

	if(autocvar_sv_jumpvelocity_backflip && PHYS_INPUT_BUTTON_CROUCH(player) && IS_ONGROUND(player) && vdist(player.velocity, <, PHYS_MAXSPEED(player) * 0.6) &&
		player.model == "models/player/mario.dpm" &&
#ifdef SVQC
		!g_cts && !g_race && CS(player).cvar_cl_sparkle == 3 && (models_allowed & MODELS_MARIO)
#elif defined(CSQC)
		gametype != MAPINFO_TYPE_CTS && gametype != MAPINFO_TYPE_RACE && autocvar_cl_sparkle == 3 /* sorry csqc, no way to check allowed thanks to a stupid stats bug */
#endif
		)
	{
		M_ARGV(1, float) = autocvar_sv_jumpvelocity_backflip;
		makevectors(PHYS_WORLD_ANGLES(player));
		player.velocity -= v_forward * 50;
	#ifdef SVQC
		sound(player, CH_VOICE, SND_MARIO_CJUMP, VOL_BASE, ATTEN_NORM);
	#endif
	}
}
#endif
