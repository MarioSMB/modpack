#include "client.qh"

#include <lib/csqcmodel/sv_model.qh>
#include <common/csqcmodel_settings.qh>
#include "../common/physics.qh"
#include "combat.qh"
#include "getreplies.qh"
#include "player.qh"
#include "rogue/sphere.qh"
#include "shop.qh"
#include "triggers/teleporters.qh"
#include "triggers/trigger/fog.qh"
#include "vote.qh"
#include "weapons/weaponsystem.qh"

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

void centerprint_all(string s)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		centerprint(it, s);
	});
}

void horde_set_keys(entity temp_player); // yoder sept24
void GibMonster(entity this);
float HordeGetPlayersAlive();

/*QUAKED info_intermission(1 0.5 0.5)(-16 -16 -16)(16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
spawnfunc(info_intermission)
{
}

void intermission_clear_powerups(entity this)
{
	this.powerups &= ~(POWERUP_QUAD | POWERUP_INVISIBILITY | POWERUP_INVULNERABILITY | POWERUP_SUIT);
	this.super_damage_finished = 0;
	this.super_time = 0;
	this.invisible_finished = 0;
	this.invisible_time = 0;
	this.invincible_finished = 0;
	this.invincible_time = 0;
	this.radsuit_finished = 0;
	this.rad_time = 0;
}

bool reset_flag;
void SetChangeParms(entity this)
{
	if(reset_flag)
	{
		setspawnparms(this);
		return;
	}
	if(this.health <= 0 || deathmatch || (MP_MG && world.worldtype == WORLDTYPE_HUB) || world.worldtype == WORLDTYPE_SKATE)
	{
		SetNewParms();
		return;
	}

// remove items
	this.items &= ~(IT_KEY1 | IT_KEY2);
	this.items &= ~IT_SUPERHEALTH; // rogue
	this.gravity = 1.0;

	this.health = this.max_health;
	vector myweps = STAT(WEAPONS, this);
	parm1 = myweps.x;
	parm2 = myweps.y;
	parm3 = myweps.z;
	parm4 = this.armorvalue;
	parm5 = max(25, this.ammo_shells);
	parm6 = this.ammo_nails;
	parm7 = this.ammo_rockets;
	parm8 = this.ammo_cells;
	if(this.weaponentity)
		parm9 = this.weaponentity.m_weapon.m_id;
	parm10 = this.model_randomizer;
	parm11 = this.ammo_lava_nails;
	parm12 = this.ammo_multi_rockets;
	parm13 = this.ammo_plasma;
	parm14 = this.currentspell;
	if(this.weaponentity)
		parm15 = this.weaponentity.cnt;
	parm16 = this.items;
}

void SetNewParms()
{
	Weapon start_weapon = (autocvar_horde) ? WEP_CHAINSAW : WEP_AXE;
	WepSet weps = (WEPSET(SHOTGUN) | start_weapon.m_wepset);
	parm1 = weps.x;
	parm2 = weps.y;
	parm3 = weps.z;
	parm4 = 0;
	parm16 = 0;
	parm5 = 25;
	parm6 = 0;
	parm7 = 0;
	parm8 = 0;
	parm9 = WEP_SHOTGUN.m_id;
	parm10 = (deathmatch) ? 1 : random();
	parm11 = 0;
	parm12 = 0;
	parm13 = 0;
	parm14 = 0;
	parm15 = start_weapon.m_id; // always use axe as the alternate weapon
}

void DecodeLevelParms(entity this)
{
	if(world.model == "maps/quake.bsp" || world.model == "maps/start.bsp" || world.model == "maps/aopstart.bsp" || (MP_MG && world.worldtype == WORLDTYPE_HUB))
		SetNewParms();		// take away all stuff on starting new episode

	// Yoder Oct25, reset weapons between map loads
	if(MP_MG && autocvar_horde)
		SetNewParms();

	if(world.model == "maps/hipstart.bsp"
	|| world.model == "maps/hip1m1.bsp"
	|| world.model == "maps/hip2m1.bsp"
	|| world.model == "maps/hip3m1.bsp"
	) SetNewParms(); // take away all stuff on starting new episode

	if(world.model == "maps/rstart.bsp" || ((world.model == "maps/r2m1.bsp" || world.model == "maps/aop2m1.bsp") && !deathmatch))
		SetNewParms(); // reset all stuff on level 8 and new episode

	STAT(WEAPONS, this) = vec3(parm1, parm2, parm3);
	this.armorvalue = parm4;
	this.ammo_shells = parm5;
	this.ammo_nails = parm6;
	this.ammo_rockets = parm7;
	this.ammo_cells = parm8;
	if(this.weaponentity)
		this.weaponentity.m_weapon = REGISTRY_GET(Weapons, parm9);
	this.model_randomizer = parm10;
	this.ammo_lava_nails = parm11;
	this.ammo_multi_rockets = parm12;
	this.ammo_plasma = parm13;

	this.currentspell = parm14;
	if(this.weaponentity)
		this.weaponentity.skin = parm14;
	if(this.weaponentity)
		this.weaponentity.cnt = parm15;
	this.items = parm16;
	this.powerups = 0;
	if(this.items & IT_ARMOR3)
		this.armortype = 0.8;
	else if(this.items & IT_ARMOR2)
		this.armortype = 0.6;
	else if(this.items & IT_ARMOR1)
		this.armortype = 0.3;

	// no parms left! let's just count from when they join
	this.parm_idlesince = time;
}

bool findinlist_abbrev(string tofind, string list)
{
	if(list == "" || tofind == "")
		return false; // empty list or search, just return

	// this function allows abbreviated strings!
	FOREACH_WORD(list, it == substring(tofind, 0, strlen(it)),
	{
		return true;
	});

	return false;
}

bool PlayerInIPList(entity p, string iplist)
{
	// some safety checks (never allow local?)
	if(p.netaddress == "local" || p.netaddress == "" || !IS_REAL_CLIENT(p))
		return false;

	return findinlist_abbrev(p.netaddress, iplist);
}

bool PlayerInIDList(entity p, string idlist)
{
	// NOTE: we do NOT check crypto_idfp_signed here, an unsigned ID is fine too for this
	if(!p.crypto_idfp)
		return false;

	return findinlist_abbrev(p.crypto_idfp, idlist);
}

bool PlayerInList(entity player, string list)
{
	return boolean(PlayerInIDList(player, list) || PlayerInIPList(player, list));
}

string autocvar_sv_allow_customplayermodels_speciallist = "";
string autocvar_sv_allow_customplayermodels_idlist = "";

bool have_katria;
bool have_mario;
bool have_goat;
STATIC_INIT(check_models)
{
	have_katria = fexists("progs/player_katria.mdl");
	have_mario = fexists("progs/player_mario.mdl");
	have_goat = fexists("progs/player_goat.mdl");
}

string get_playermodel(entity this)
{
	if(STAT(SKATING, this))
		return "progs/skater.mdl";
	if(have_mario && autocvar_sv_allow_customplayermodels_speciallist != "")
	{
		if(PlayerInList(this, autocvar_sv_allow_customplayermodels_speciallist))
			return "progs/player_mario.mdl";
	}
	if(have_goat && autocvar_sv_allow_customplayermodels_idlist != "")
	{
		if(PlayerInList(this, autocvar_sv_allow_customplayermodels_idlist))
			return "progs/player_goat.mdl";
	}
	if(this.model_randomizer < autocvar_sv_quake_katria && have_katria)
		return "progs/player_katria.mdl";
	return "progs/player.mdl";
}

string get_playerhead(entity this)
{
	if(STAT(SKATING, this))
		return "progs/h_player.mdl";
	if(have_mario && autocvar_sv_allow_customplayermodels_speciallist != "")
	{
		if(PlayerInList(this, autocvar_sv_allow_customplayermodels_speciallist))
			return "progs/null.mdl";
	}
	if(this.model_randomizer < autocvar_sv_quake_katria && have_katria)
		return "progs/h_player_katria.mdl";
	return "progs/h_player.mdl";
}

string get_deathsound(entity this, int chance)
{
	if(STAT(SKATING, this))
		return "player/death1.wav"; // not actually used
	if(have_mario && autocvar_sv_allow_customplayermodels_speciallist != "" && PlayerInList(this, autocvar_sv_allow_customplayermodels_speciallist))
	{
		switch(chance)
		{
			default:
			case 1: return "player_mario/death1.wav";
			case 2: return "player_mario/death2.wav";
			case 3: return "player_mario/death3.wav";
			case 4: return "player_mario/death4.wav";
			case 5: return "player_mario/death5.wav";
		}
	}
	else if(have_goat && autocvar_sv_allow_customplayermodels_idlist != "" && PlayerInList(this, autocvar_sv_allow_customplayermodels_idlist))
	{
		switch(chance)
		{
			default:
			case 1: return "player_goat/death1.wav";
			case 2: return "player_goat/death2.wav";
			case 3: return "player_goat/death3.wav";
			case 4: return "player_goat/death4.wav";
			case 5: return "player_goat/death5.wav";
		}
	}
	else if(this.model_randomizer < autocvar_sv_quake_katria && have_katria)
	{
		switch(chance)
		{
			default:
			case 1: return "player_katria/death1.wav";
			case 2: return "player_katria/death2.wav";
			case 3: return "player_katria/death3.wav";
			case 4: return "player_katria/death4.wav";
			case 5: return "player_katria/death5.wav";
		}
	}
	else
	{
		switch(chance)
		{
			default:
			case 1: return "player/death1.wav";
			case 2: return "player/death2.wav";
			case 3: return "player/death3.wav";
			case 4: return "player/death4.wav";
			case 5: return "player/death5.wav";
		}
	}

	// never actually reached, thanks gmqcc
	return "player/death1.wav";
}

string get_painsound(entity this, int chance)
{
	if(STAT(SKATING, this))
		return "player/pain6.wav";
	if(have_mario && autocvar_sv_allow_customplayermodels_speciallist != "" && PlayerInList(this, autocvar_sv_allow_customplayermodels_speciallist))
	{
		switch(chance)
		{
			case 1: return "player_mario/pain1.wav";
			case 2: return "player_mario/pain2.wav";
			case 3: return "player_mario/pain3.wav";
			case 4: return "player_mario/pain4.wav";
			case 5: return "player_mario/pain5.wav";
			default: return "player_mario/pain6.wav";
		}
	}
	else if(have_goat && autocvar_sv_allow_customplayermodels_idlist != "" && PlayerInList(this, autocvar_sv_allow_customplayermodels_idlist))
	{
		switch(chance)
		{
			case 1: return "player_goat/pain1.wav";
			case 2: return "player_goat/pain2.wav";
			case 3: return "player_goat/pain3.wav";
			case 4: return "player_goat/pain4.wav";
			case 5: return "player_goat/pain5.wav";
			default: return "player_goat/pain6.wav";
		}
	}
	else if(this.model_randomizer < autocvar_sv_quake_katria && have_katria)
	{
		switch(chance)
		{
			case 1: return "player_katria/pain1.wav";
			case 2: return "player_katria/pain2.wav";
			case 3: return "player_katria/pain3.wav";
			case 4: return "player_katria/pain4.wav";
			case 5: return "player_katria/pain5.wav";
			default: return "player_katria/pain6.wav";
		}
	}
	else
	{
		switch(chance)
		{
			case 1: return "player/pain1.wav";
			case 2: return "player/pain2.wav";
			case 3: return "player/pain3.wav";
			case 4: return "player/pain4.wav";
			case 5: return "player/pain5.wav";
			default: return "player/pain6.wav";
		}
	}

	// never actually reached, thanks gmqcc
	return "player/pain6.wav";
}

void player_sound(entity this, int chan, string sample, float atten)
{
	string soundpath;
	if(STAT(SKATING, this))
		soundpath = "player/";
	else if(have_mario && autocvar_sv_allow_customplayermodels_speciallist != "" && PlayerInList(this, autocvar_sv_allow_customplayermodels_speciallist))
		soundpath = "player_mario/";
	else if(have_goat && autocvar_sv_allow_customplayermodels_idlist != "" && PlayerInList(this, autocvar_sv_allow_customplayermodels_idlist))
		soundpath = "player_goat/";
	else if(this.model_randomizer < autocvar_sv_quake_katria && have_katria)
		soundpath =  "player_katria/";
	else
		soundpath = "player/";
	_sound(this, chan, strcat(soundpath, sample), 1, atten);
}

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity FindIntermission(entity this)
{
	if(world.worldtype == WORLDTYPE_SKATE)
		return NULL; // stay at player view
// look for info_intermission first
	RandomSelection_Init();
	bool found = false;
	FOREACH_ENTITY_CLASS("info_intermission", true,
	{
		found = true;
		RandomSelection_AddEnt(it, 1, 1);
	});
	if(found)
		return RandomSelection_chosen_ent;

// then look for the start position
	entity spot = find(NULL, classname, "info_player_start");
	if(spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find(NULL, classname, "testplayerstart");
	if(!spot)
		objerror(this, "FindIntermission: no spot");

	return spot;
}

string nextmap;
void GotoNextMap()
{
	if(autocvar_samelevel)	// if samelevel is set, stay on same level
		changelevel(mapname);
	else
	{
		if(MP_MG && autocvar_horde)
			changelevel(HordeRandomMap());
		else
			changelevel(nextmap);
	}
}

void SendCDTrack(entity to, int numb)
{
	if(!to)
	{
		// TODO: doesn't support play/loop
		string thetrack = getcdtrack(numb);
		string tostuff = strcat("cd loop ", thetrack, "\n");
		FOREACH_CLIENT(IS_REAL_CLIENT(it),
		{
			stuffcmd(it, tostuff);
		});

		if(current_cdtrack)
			strunzone(current_cdtrack);
		current_cdtrack = strzone(thetrack);

		return;
	}

	stuffcmd(to, strcat("cd loop ", getcdtrack(numb), "\n"));
}

void ExitIntermission()
{
// skip any text in deathmatch
	if(deathmatch)
	{
		GotoNextMap();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if(intermission_running == 2)
	{
		if(world.model == "maps/e1m7.bsp")
		{
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif
			if(!autocvar_registered)
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if(world.model == "maps/e2m6.bsp")
		{
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif

			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if(world.model == "maps/e3m6.bsp")
		{
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif

			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if(world.model == "maps/e4m7.bsp")
		{
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif

			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}
		//MP
		if(MP_MG)
		{
			if(intermissiontext && intermissiontext != "")
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, intermissiontext);
				intermissiontext = string_null;
				if(world.model == "maps/mgend.bsp")
				{
					intermission_exittime = time + 10000000;  // never allow exit
					server_reset();
				}
				return;
			}
			if(MP_MG && world.endtext && world.endtext != "")
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, world.endtext);
				if(world.model == "maps/mgend.bsp")
				{
					intermission_exittime = time + 10000000;  // never allow exit
					server_reset();
				}
				return;
			}
		}
		//HIPNOTIC
		if(world.model == "maps/hip1m4.bsp")
		{
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 6);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif
			WriteByte(MSG_ALL, SVC_FINALE);
/*
			**************************************
			Deep within the bowels of the
			Research Facility, you discover the
			passage that the followers of Quake
			have used to enter our world.
			The bastards used some type of
			gigantic teleporter to overload
			one of our own slipgates!  As long as
			this portal exists, Earth will never
			be safe from Quake's cruel minions.

			If you can find the source of the
			portal's power, you can shut it
			down--possibly forever!  With only a
			moment's consideration for your own
			safety, you re-enter the dark domain,
			knowing Hell would be a better fate
			than experiencing the reign of Quake.
*/
			WriteString(MSG_ALL, "Deep within the bowels of the\nResearch Facility, you discover the\npassage that the followers of Quake\nhave used to enter our world.\nThe bastards used some type of\ngigantic teleporter to overload\none of our own slipgates!  As long as\nthis portal exists, Earth will never\nbe safe from Quake's cruel minions." );
			//WriteString(MSG_ALL, "If you can find the source of the\nportal's power, you can shut it\ndown--possibly forever!  With only a\nmoment's consideration for your own\nsafety, you re-enter the dark domain,\nknowing Hell would be a better fate\nthan experiencing the reign of Quake." );
			return;
		}
		else if(world.model == "maps/hip2m5.bsp")
		{
/*
			**************************************
			After destroying the power generator,
			you pass beyond the gate of Mortum's
			Keep.  A wave of nausea suddenly flows
			over you and you find yourself cast
			out into a liquid void.  You float
			lifelessly, yet aware, in a lavender
			sea of energy.

			After what seems like an eternity,
			you feel the presence of a diabolical
			intelligence.  You are held helpless
			for a moment as your mind is open to
			that of Armagon--Quake's General and
			master of this realm.  Recognizing
			you as the one who foiled his
			attempt to conquer Earth, a hellish
			howl fills your mind and blots out
			all consciousness.  When you awake,
			you find yourself on the shores of
			reality, but in a time and place
			unknown to you.
*/
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 6);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif

			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "After destroying the power generator,\nyou pass beyond the gate of Mortum's\nKeep.  A wave of nausea suddenly flows\nover you and you find yourself cast\nout into a liquid void.  You float\nlifelessly, yet aware, in a lavender\nsea of energy." );
			//WriteString(MSG_ALL, "After what seems like an eternity,\nyou feel the presence of a diabolical\nintelligence.  You are held helpless\nfor a moment as your mind is open to\nthat of Armagon--Quake's General and\nmaster of this realm.  Recognizing\nyou as the one who foiled his\nattempts to conquer Earth, a hellish\nhowl fills your mind and blots out\nall consciousness.  When you awake,\nyou find yourself on the shores of\nreality, but in a time and place\nunknown to you." );
			return;
		}
		else if(world.model == "maps/hipend.bsp")
		{
/*
			**************************************
			After the last echoes of Armagon's
			death yell fade away, you breathe a
			heavy sigh of relief.  With the loss
			of his magic, Armagon's fortress
			begins to collapse.  The rift he
			created to send his grisly troops
			through time slowly closes and seals
			itself forever.  In the chaos that
			ensues, a wall collapses, revealing
			one remaining time portal.  With your
			chances to escape rapidly growing
			slim, you race for the portal,
			mindless of your destination.  In a
			flash of light, you find yourself
			back at Command HQ, safe and sound.

			Congratulations!  You are victorious!
			The minions of Quake have once again
			fallen before your mighty hand.
			Is this the last you will see of
			Quake's hellions?

			Only time will tell...
*/
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif

			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "After the last echoes of Armagon's\ndeath yell fade away, you breathe a\nheavy sigh of relief.  With the loss\nof his magic, Armagon's fortress\nbegins to collapse.  The rift he\ncreated to send his grisly troops\nthrough time slowly closes and seals\nitself forever.  In the chaos that\nensues, a wall collapses, revealing\none remaining time portal.  With your\nchances to escape rapidly growing\nslim, you race for the portal,\nmindless of your destination.  In a\nflash of light, you find yourself\nback at Command HQ, safe and sound." );
			//WriteString(MSG_ALL, "Congratulations!  You are victorious!\nThe minions of Quake have once again\nfallen before your mighty hand.\nIs this the last you will see of\nQuake's hellions?\n\nOnly time will tell..." );
			//intermission_exittime = time + 10000000;  // never allow exit
			intermission_exittime = time + 10000000;  // never allow exit
			server_reset();
			return;
		}
		else if(world.model == "maps/r1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_FINALE);
//-------------------------------------   end here
			WriteString (MSG_ALL, "Victory! The Overlord's mangled\nremains are the evidence.  His evil\nWrath army?  Cast out to wander\naimlessly throughout time.\n\nAs the Slipgate fog surrounds you,\nthoughts rage into your consciousness:\nHas Quake's oppressive reign ended?\nIs it Salvation, or Damnation, which\nwaits beyond the Vortex?\n\nAnother thought, not quite your own,\nrazors through the haze.  \"Forgiveness\ncan yet be granted; Our Master remains\nto absolve your sins against his Chosen.\nFall down upon your knees-pray for\nQuake's mercy.\"");
			return;
		}
		else if(world.model == "maps/aop1m6.bsp")
		{
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "The stench of Blud's rotting gibs\nare enough to make even YOU sick.\n\nNever before have you fought a\ncreature as aggressive and vile as\nthis! You were to be its first victim\nsince being locked away so many ages\nago, without creatures to devour.\n\nDrained from the fight, you realize\nthe worst is far from over...");
			return;
		}
		else if(world.model == "maps/aopend.bsp")
		{
		#if 0
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
		#else
			SendCDTrack(NULL, 3);
		#endif
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "You find yourself standing before the\ncorpse of Quake's highest minion.\n\nThe vapor from her rockets, and the\nslight scent of ionized air particles\nsinge your lungs as you realize that\nyou have won the battle at last.\n\nLegond set out to take revenge on you\nand display your dead lifeless body\nto the citizens of the empire.\nShe wanted to humiliate, desecrate,\ndevour, and torture you for you were\nthe cause of the destruction of\nQuake, the center of her world.\n\nYou have won. It is time to rest\n\nAt least for now...");
			intermission_exittime = time + 10000000;  // never allow exit
			server_reset();
			return;
		}

		// NOTE: credits not implemented
		//if(MP_MG && nextmap == "start" || nextmap == "hipstart" || nextmap == "rstart" || nextmap == "aopstart" || nextmap == "mgstart" && !coop && !autocvar_horde) // Yoder modify Oct25 to check against horde
		GotoNextMap();
	}
	
	if(intermission_running == 3)
	{
		if(!autocvar_registered)
		{	// shareware episode has been completed, go to sell screen
			WriteByte(MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if((serverflags&15) == 15 && substring(world.model, 0, 6) == "maps/e") // try to catch only standard Quake episodes
		{
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herthis to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}

		//HIPNOTIC
		if(world.model == "maps/hip1m4.bsp")
		{
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "If you can find the source of the\nportal's power, you can shut it\ndown--possibly forever!  With only a\nmoment's consideration for your own\nsafety, you re-enter the dark domain,\nknowing Hell would be a better fate\nthan experiencing the reign of Quake." );
			return;
		}
		else if(world.model == "maps/hip2m5.bsp")
		{
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "After what seems like an eternity,\nyou feel the presence of a diabolical\nintelligence.  You are held helpless\nfor a moment as your mind is open to\nthat of Armagon--Quake's General and\nmaster of this realm.  Recognizing\nyou as the one who foiled his\nattempt to conquer Earth, a hellish\nhowl fills your mind and blots out\nall consciousness.  When you awake,\nyou find yourself on the shores of\nreality, but in a time and place\nunknown to you." );
			return;
		}
		else if(world.model == "maps/hipend.bsp")
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Congratulations!  You are victorious!\nThe minions of Quake have once again\nfallen before your mighty hand.\nIs this the last you will see of\nQuake's hellions?\n\nOnly time will tell..." );
			intermission_exittime = time + 10000000;  // never allow exit
			server_reset();
			return;
		}
	}

	GotoNextMap();
}

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void IntermissionThink(entity this)
{
	if(time < intermission_exittime)
		return;

	if(!this.button0 && !this.button1 && !this.button2 && !this.button3)
		return;
	
	ExitIntermission();
}

float autocvar_sv_quake_autoreset = 30;
void server_delayed_reset(entity this)
{
	if(deathmatch)
		return; // don't wanna do a hard reset in these cases

	// kicks everyone and resets the server!
#if 0
	string themap = "start";
	if(MP_HIPNOTIC)
		themap = "hipstart";
	else if(MP_ROGUE)
		themap = "rstart";
	else if(MP_IMPEL)
		themap = "aopstart";
	else if(MP_MG)
		themap = "mgstart";
	localcmd("\nmap ", themap, "\n");
#else
	string themap = "quake";
	changelevel(themap);
#endif
}

void server_reset()
{
	if(autocvar_sv_quake_autoreset <= 0)
		return;

	// reset server after some time
	entity reset_timer = spawn();
	setthink(reset_timer, server_delayed_reset);
	reset_timer.nextthink = time + autocvar_sv_quake_autoreset;
}

void execute_changelevel(entity this)
{
	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	if(deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

#if 0
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, 3);
	WriteByte(MSG_ALL, 3);
#else
	SendCDTrack(NULL, 3);
#endif

	entity pos = FindIntermission(this);

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.view_ofs = '0 0 0';
		if(pos)
		{
			it.angles = it.v_angle = pos.mangle;
			it.fixangle = true;		// turn this way immediately
		}
		it.nextthink = time + 0.5;
		it.takedamage = DAMAGE_NO;
		it.solid = SOLID_NOT;
		it.flags |= FL_NOTARGET; // fix a silly monster bug
		//it.health = -2342; // can't do this because of parms
		set_movetype(it, MOVETYPE_NONE);
		if(MP_MG)
		{
			intermission_clear_powerups(it);
			FogPushSettingsFrom(it, pos, 0);
		}
		if(pos)
		{
			//it.modelindex = 0;
			setmodel(it, MDL_Null);
			setsize(it, VEC_HULL_MIN, VEC_HULL_MAX);
			setorigin(it, pos.origin);
		}
	});

	WriteByte(MSG_ALL, SVC_INTERMISSION);

	if(MP_MG)
	{
		// Yoder merge Horde sept24 2021
		if(horde_ent)
		{
			setthink(horde_ent, func_null);
			horde_ent.nextthink = -1;
			FOREACH_ENTITY_STRING(category, CATEGORY_MONSTER,
			{
				setthink(it, GibMonster);
				it.nextthink = time + 0.2 + random() * 1.8;
			});
		}
		if(this.spawnflags & NO_INTERMISSION)
		{
			//Go directly to intermission text.
			ExitIntermission();
		}
	}
}


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void set_suicide_frame(entity this);

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void CopyToBodyQueue(entity ent)
{
	entity body = new(bodyqueue);
	body.angles = ent.angles;
	body.model = ent.model;
	body.modelindex = ent.modelindex;
	body.frame = ent.frame;
	body.colormap = ent.colormap;
	set_movetype(body, ent.move_movetype);
	body.velocity = ent.velocity;
	//body.move_qcphysics = false; // not for clones
	body.flags = 0;
	body.skin = ent.skin;
	setorigin(body, ent.origin);
	setsize(body, ent.mins, ent.maxs);

	IL_PUSH(g_clones, body);

	if(coop || deathmatch)
	{
		setthink(body, SUB_Remove);
		body.nextthink = time + 10;
	}
}

void LoadGame()
{
	FOREACH_CLIENT(it.fog_density,
	{
		// Restore fog
		SetFog(it, it.fog_density, it.fog_color, 0.0);
	});
}

// called by ClientKill and DeadThink
void respawn(entity this)
{
	if(MP_MG)
		this.velocity = '0 0 0';
	if(coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQueue(this);
		// get the spawn parms as they were at level start
		setspawnparms(this);
		// respawn		
		PutClientInServer(this);
	}
	else if(deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQueue(this);
		// set default spawn parms
		SetNewParms();
		// respawn		
		PutClientInServer(this);
	}
	else
	{
		// put serverflags back to map's initial setting
		serverflags = startingserverflags;
		// request a reset to the parms
		reset_flag = true;
		// "change" to the same level
		localcmd(strcat("changelevel ", mapname, "\n"));
	}
}

// Yoder, Sept24, 2021
// when in horde coop, respawn a dead teammate with this:
void horde_respawn_teammate(entity this)
{
	CopyToBodyQueue(this);
	PutClientInServer(this);
}

// Yoder, Sept24, 2021
// when in horde (coop or solo), respawn all by restarting the server:
void horde_respawn_all()
{
	// restart the entire server
	// put serverflags back to map's initial setting
	serverflags = startingserverflags;
	// request a reset to the parms
	reset_flag = true;
	// "change" to the same level
	localcmd(strcat("changelevel ", HordeRandomMap(), "\n"));
}


/*
============
ClientKill

Player entered the suicide command
============
*/
void ClientKill(entity this)
{
	if(gameover || intermission_running)
		return;
	if(time < this.suicide_delay)
	{
		sprint(this, "You must wait before suiciding again... Get help.\n");
		return;
	}
	this.suicide_delay = time + autocvar_sv_quake_kill_delay;

	sphere_remove(this);

	bprintf("%s suicides\n", this.netname);

	if(MP_MG && autocvar_horde) // horde mode behaviour
	{
		PlayerDie(this, NULL, NULL, DEATH_KILL.m_id);
		this.health = 0;
		return;
	}
	set_suicide_frame(this);
	this.modelindex = this.modelindex_player;
	this.frags = this.frags - 2;	// extra penalty
	respawn(this);
}

/*
============
PlayerVisibleToSpawnPoint

Returns true if player can see this point
============
*/
bool PlayerVisibleToSpawnPoint(entity point)
{
	FOREACH_CLIENT(it.health > 0,
	{
		vector spot1 = point.origin + it.view_ofs;
		vector spot2 = it.origin + it.view_ofs;
		traceline(spot1, spot2, true, point);
		if(trace_fraction >= 1.0f)
			return true;
	});

	return false;
}

float IDEAL_DIST_FROM_DM_SPAWN_POINT = 384;
float MIN_DIST_FROM_DM_SPAWN_POINT = 84;
float MIN_DIST_FROM_HORDE_SPAWN_POINT = 72;

bool predicate_is_active_spawnpoint(entity this)
{
	return (this.state == COOP_SPAWN_ACTIVE);
}

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity SelectSpawnPoint(entity this, bool forceSpawn)
{
	int pcount = 0;
	int numspots = 0, totalspots = 0;
	entity spots = NULL;
	entity thing = NULL;
// testinfo_player_start is only found in regioned levels
	entity spot = find(NULL, classname, "testplayerstart");
	if(spot)
		return spot;
		
// choose a info_player_deathmatch point
	if(MP_MG && autocvar_horde)
	{ // run simpler logic for horde - just need a spot with noone on top of it...
    	entity hordeSpawn = find(NULL, classname, "info_player_coop");

    	while(hordeSpawn)
    	{
    		thing = findradius(hordeSpawn.origin, MIN_DIST_FROM_HORDE_SPAWN_POINT);

    		pcount = 0;

    		while(thing)
    		{
				if(IS_PLAYER(thing) && thing.health > 0)
					++pcount;                      

				thing = thing.chain;      
			}

			if(pcount == 0)
				return hordeSpawn;

			// Get the next spot in the chain
			hordeSpawn = find(hordeSpawn, classname, "info_player_coop");
		}

		if(coop) // fix for singleplayer
			return NULL; // didn't find anything....
	}
    else if(coop)
	{
		if(MP_MG)
		{
			// choose a point that is active
			RandomSelection_Init();
			FOREACH_ENTITY_CLASS("info_player_coop", it.state == COOP_SPAWN_ACTIVE,
			{
				RandomSelection_AddEnt(it, 1, 1);
			});
			lastspawn = RandomSelection_chosen_ent;
		}
		else
			lastspawn = find(lastspawn, classname, "info_player_coop");
		if(!lastspawn)
			lastspawn = find(lastspawn, classname, "info_player_start");
		if(lastspawn)
			return lastspawn;
	}
	else if(deathmatch)
	{
		// find all spots that don't have visible players nearby
		spot = find(NULL, classname, "info_player_deathmatch");

		while(spot)
		{
			totalspots = totalspots + 1;

			thing = findradius(spot.origin, IDEAL_DIST_FROM_DM_SPAWN_POINT);
			pcount = 0;               

			while(thing)
			{
				if(IS_PLAYER(thing) && thing.health > 0)
					pcount += 1;                      

				thing = thing.chain;      
			}

			if(pcount == 0)
			{
				if(PlayerVisibleToSpawnPoint(spot))
					pcount += 1;
			}

			if(pcount == 0)
			{ // good spot!
				spot.goalentity = spots;
				spots = spot;
				numspots += 1;
			}

			// Get the next spot in the chain
			spot = find(spot, classname, "info_player_deathmatch");                
		}

		totalspots = totalspots - 1;

		// on small maps with few spawn points, our "ideal" spawn conditions may not be possible to meet
		// so fallback to just trying to pick a point without a player on top of it, so we don't start
		// a spawn frag loop
		if(numspots == 0)
		{
			spot = find(NULL, classname, "info_player_deathmatch");

			while(spot)
			{
				thing = findradius(spot.origin, MIN_DIST_FROM_DM_SPAWN_POINT);
				pcount = 0;               

				while(thing)
				{
					if(IS_PLAYER(thing) && thing.health > 0)
						pcount += 1;

					thing = thing.chain;      
				}

				if(pcount == 0)
				{ // good spot!
					spot.goalentity = spots;
					spots = spot;
					numspots += 1;
				}

				// Get the next spot in the chain
				spot = find(spot, classname, "info_player_deathmatch");                
			}             
		}

		// uncomment to force a deferred spawn
		// if(!forceSpawn)
		//	return NULL;

		if(!numspots)
		{
			if(!forceSpawn)
				return NULL;

			// no spots available so just pick one at random
			totalspots = rint((random() * totalspots));
			spot = find(NULL, classname, "info_player_deathmatch");       

			while(totalspots > 0)
			{
				totalspots -= 1;
				spot = find(spot, classname, "info_player_deathmatch");
			}
			return spot;
		}
		
		// Generate a random number between 1 and numspots
		numspots -= 1;
	
		numspots = rint((random() * numspots));

		spot = spots;
		while(numspots > 0)
		{
			spot = spot.goalentity;
			numspots -= 1;
		}
	
		return spot;
	}

	if(serverflags)
	{	// return with a rune to start
		if(MP_MG)
		{
			int lastPickup = sigil_getLastPickup();
			if(lastPickup)
			{
				string spname = string_null;
				if(lastPickup & SIGIL_E1) spname = "start_1";
				else if(lastPickup & SIGIL_E2) spname = "start_2";
				else if(lastPickup & SIGIL_E3) spname = "start_3";
				else if(lastPickup & SIGIL_E4) spname = "start_4";
				else if(lastPickup & SIGIL_E5) spname = "start_5";
				else if(lastPickup & SIGIL_E6) spname = "start_6";
				if(spname)
				{
					spot = find(NULL, netname, spname);
					if(spot)
					{
						if(spot.classname == "info_player_start_hub")
						{
							sigil_clearLastPickup();
							return spot;
						}
					}
				}
			}
		}
		spot = find(NULL, classname, "info_player_start2");
		if(spot)
			return spot;
	}
	
	spot = find(NULL, classname, "info_player_start");
	if(!spot)
	{
		if(!deathmatch)
			spot = find(NULL, classname, "info_player_deathmatch");
		if(!spot)
			error("PutClientInServer: no info_player_start/deathmatch on level");
	}
	
	return spot;
}

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void DecodeLevelParms(entity this);
void player_touch(entity this, entity toucher);

void RunPostPutClientInServer(entity this) 
{
	entity player = this.owner;
	entity spot = this.enemy;
	
	// Yoder Sept24, 2021
	horde_set_keys(player); // reset player's key count accordingly

	// Fog settings sometimes (?) need to be set a frame after the client has spawned.
	// Not sure why, or why it sometimes works on the same frame.
	if(!FogPushSettingsFrom(player, spot, 0))
		FogPushSettingsFrom(player, NULL, 0);

	delete(this);
}

void PutClientInServer(entity this)
{
	entity spot = SelectSpawnPoint(this, false);

	this.classname = STR_PLAYER;
	this.health = 100;
	this.takedamage = DAMAGE_AIM;
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_WALK);
	this.show_hostile = 0;
	this.max_health = this.health;
	this.flags = FL_CLIENT;
	this.air_finished = time + 12;
	this.dmg = 2;   		// initial water damage
	this.super_damage_finished = 0;
	this.radsuit_finished = 0;
	this.invisible_finished = 0;
	this.invincible_finished = 0;
	this.healthrot_nextcheck = 0;
	this.field_generator_finished = 0;
	this.effects = EF_TELEPORT_BIT;
	this.invincible_time = 0;

	this.viewloc = NULL;

	this.weaponframe = 0;
	this.weaponmodel = "";

	// hipnotic fields
	this.wetsuit_finished = 0;
	this.empathy_finished = 0;
	this.gravity = 1.0;
	this.gorging = false;

	// rogue fields
	this.shield_finished = 0;
	this.antigrav_finished = 0;

	this.fireflower_finished = 0;
	this.fireflower_time = 0;

	this.jboots_finished = 0;
	this.jboots_time = 0;

	// Cut off any still running player sounds.
	stopsound(this, CH_PLAYER_SINGLE);

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	this.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID;
	if (autocvar_g_playerclip_collisions)
		this.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;

	CL_SpawnWeaponentity(this);
	this.weaponentity.weaponname = "";
	this.weaponentity.m_weapon = WEP_Null;
	this.weaponentity.skin = this.currentspell;

	DecodeLevelParms(this);

	W_SetCurrentAmmo(this);

	this.attack_finished = time;
	this.attack2_finished = time;
	this.th_pain = player_pain;
	this.th_die = PlayerDie;
	
	this.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	this.pausetime = 0;

	bool shouldTelefrag;
	if(this.spawn_deferred > 0 && time >= this.spawn_deferred)
	{
		LOG_DEBUG("forcing telefrag on this spawn");
		shouldTelefrag = true;
	}
	else
		shouldTelefrag = false;
	spot = SelectSpawnPoint(this, shouldTelefrag);
	if(!spot)
	{
		this.takedamage = DAMAGE_NO;
		this.solid = SOLID_NOT;
		set_movetype(this, MOVETYPE_NONE);
		this.deadflag = DEAD_DEAD;
		setmodel(this, MDL_Null);
		this.view_ofs = '0 0 1'; // not 0 because PlayerPreThink would return out
		this.velocity = '0 0 0';

		if(this.spawn_deferred == 0)
		{
			LOG_DEBUG("no spawns available! deferring");
			this.spawn_deferred = time + 5;
		}

		spot = FindIntermission(this);
		this.angles = this.v_angle = spot.mangle;
		this.angles_z = 0; // never spawn tilted even if the spot says to
		this.fixangle = true;
		setorigin(this, spot.origin);
		this.weaponentity.m_weapon = WEP_Null;

		return;
	}

	this.spawn_deferred = 0;

	this.origin = spot.origin + '0 0 1';
	this.angles = vec2(spot.angles);
	this.angles_z = 0; // never spawn tilted even if the spot says to
	this.fixangle = true;		// turn this way immediately

	if(MP_MG && coop && STAT(WEAPONS, spot))
	{
		STAT(WEAPONS, this) |= STAT(WEAPONS, spot);
		if(STAT(WEAPONS, this) & (WEPSET(NAILGUN) | WEPSET(SUPER_NAILGUN)))
			this.ammo_shells = max(30, this.ammo_shells);
		if(STAT(WEAPONS, this) & (WEPSET(GRENADE_LAUNCHER) | WEPSET(ROCKET_LAUNCHER)))
			this.ammo_rockets = max(4, this.ammo_rockets);
		if(STAT(WEAPONS, this) & WEPSET(LIGHTNING))
			this.ammo_cells = max(12, this.ammo_cells);
	}

	settouch(this, player_touch);

	status_effects_PutClientInServer(this);

	//JIM
	// Clear out velocity so you're not launched into the air
	// when you respawn.
	this.velocity = '0 0 0';

	STAT(MANA, this) = 100;

	skate_spawn(this);

// oh, this is a hack!
	_setmodel(this, "progs/eyes.mdl");
	modelindex_eyes = this.modelindex;

	_setmodel(this, "progs/bolt2.mdl");
	modelindex_bolt = this.modelindex;

	_setmodel(this, get_playermodel(this));
	this.modelindex_player = this.modelindex;

	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	
	this.view_ofs = '0 0 22';
	this.velocity = '0 0 0'; // 1998-07-21 Player moves after respawn fix by Xian

	player_stand1(this);

	if(deathmatch || coop)
	{
		fixedmakevectors(this.angles);
		spawn_tfog(this.origin + v_forward * 20);
	}

	spawn_tdeath(this.origin, this);

	if(MP_MG)
	{
		entity postSpawn = new(postSpawn);
		postSpawn.owner = this;
		postSpawn.enemy = spot;
		setthink(postSpawn, RunPostPutClientInServer);
		postSpawn.nextthink = time + 0.05;
	}

	stuffcmd(this, "-attack\n"); // prevent shooting after respawning
}


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start(1 0 0)(-16 -16 -24)(16 16 24)
The normal starting point for a level.
*/
spawnfunc(info_player_start)
{
}


/*QUAKED info_player_start2(1 0 0)(-16 -16 -24)(16 16 24)
Only used on start map for the return point from an episode.
*/
spawnfunc(info_player_start2)
{
}

/*QUAKED info_player_start_hub (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
spawnfunc(info_player_start_hub)
{
}

/*
saved out by quaked in region mode
*/
spawnfunc(testplayerstart)
{
}

/*QUAKED info_player_deathmatch(1 0 1)(-16 -16 -24)(16 16 24)
potential spawning position for deathmatch games
*/
spawnfunc(info_player_deathmatch)
{
	if(MP_MG && !deathmatch) { delete(this); return; }
}

//////////////////////////////////////////////////////////////////////////

void trigger_activate_coop_spawns_use(entity this, entity actor, entity trigger)
{
	WepSet newitems = '0 0 0';
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		newitems |= STAT(WEAPONS, it);
	});

	FOREACH_ENTITY_CLASS("info_player_coop", true,
	{
		if(it.targetname == this.target)
		{
			it.state = COOP_SPAWN_ACTIVE;
			STAT(WEAPONS, it) = newitems;
		}
		else
		{
			it.state = 0;
			STAT(WEAPONS, it) = '0 0 0';
		}
	});
}

/*QUAKED trigger_activate_coop_spawns (1 0 1) (-8 -8 -8) (8 8 8)
Activates a set of coop spawnpoints.
*/
spawnfunc(trigger_activate_coop_spawns)
{
	if(!MP_MG) { delete(this); return; }
	if(!coop) { delete(this); return; }
	this.use = trigger_activate_coop_spawns_use;
}

const int COOP_SPAWN_START_ACTIVE = BIT(0);

/*QUAKED info_player_coop(1 0 1)(-16 -16 -24)(16 16 24)
potential spawning position for coop games
*/
spawnfunc(info_player_coop)
{
	if(MP_MG)
	{
		if(!coop)
		{
			delete(this);
			return;
		}
		if((this.spawnflags & COOP_SPAWN_START_ACTIVE) || (!this.targetname || this.targetname == ""))
			this.state = COOP_SPAWN_ACTIVE;
	}
}

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void NextLevel()
{
	if(nextmap && nextmap != "")
		return; // already done

	entity o = NULL;

	VoteReset(true);

	if(MP_MG)
	{
	// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to same map if no trigger_changelevel
		if(!o || mapname == "mgstart")
		{
			o = spawn();
			o.map = mapname;
		}
	}
	else if(MP_IMPEL)
	{
	// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to same map if no trigger_changelevel
		if(!o || mapname == "aopstart")
		{
			o = spawn();
			o.map = mapname;
		}
	}
	else if(MP_HIPNOTIC)
	{
		// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to same map if no trigger_changelevel
		if(!o || mapname == "hipstart")
		{
			o = spawn();
			o.map = mapname;
		}
	}
	else if(MP_ROGUE)
	{
		if(mapname == "start" || mapname == "rstart" || mapname == "hipstart" || mapname == "aopstart" || mapname == "mgstart")
		{
			mapname = "r1m1";

			o = spawn();
			o.map = mapname;
		}
		else
		{
			// find a trigger changelevel
			o = find(NULL, classname, "trigger_changelevel");

			// go back to same map if no trigger_changelevel
			if(!o || mapname == "rstart")
			{
				o = spawn();
				o.map = mapname;
			}
		}
	}
	else if(mapname == "start")
	{
		if(!autocvar_registered)
		{
			mapname = "e1m1";
		}
		else if(!(serverflags & BIT(0)))
		{
			mapname = "e1m1";
			serverflags |= BIT(0);
		}
		else if(!(serverflags & BIT(1)))
		{
			mapname = "e2m1";
			serverflags |= BIT(1);
		}
		else if(!(serverflags & BIT(2)))
		{
			mapname = "e3m1";
			serverflags |= BIT(2);
		}
		else if(!(serverflags & BIT(3)))
		{
			mapname = "e4m1";
			serverflags &= ~7;
		}

		o = spawn();
		o.map = mapname;
	}
	if(world.model == "maps/mgdm1.bsp")
	{
		o = spawn();
		o.map = "mgdm2";
	}
	else if(world.model == "maps/mgdm2.bsp")
	{
		o = spawn();
		o.map = "mgdm3";
	}
	else if(world.model == "maps/mgdm3.bsp")
	{
		o = spawn();
		o.map = "mgdm4";
	}
	else if(world.model == "maps/mgdm4.bsp")
	{
		o = spawn();
		o.map = "mgdm1";
	}
	else
	{
		// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to same map if no trigger_changelevel
		if(!o)
		{
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = true;

	if(autocvar_sv_eventlog)
		GameLogEcho(":gameover");

	GameLogClose();
	
	if(o.nextthink < time)
	{
		setthink(o, execute_changelevel);
		o.nextthink = time + 0.1;
	}
}

//============================================================================

void PlayerDeathThink(entity this)
{
	if(IS_ONGROUND(this))
	{
		float forward = vlen(this.velocity);
		forward = forward - 20;
		if(forward <= 0)
			this.velocity = '0 0 0';
		else	
			this.velocity = forward * normalize(this.velocity);
	}

	if(this.spawn_deferred)
	{
		entity spot = SelectSpawnPoint(this, false);
		if(spot || time >= this.spawn_deferred)
			respawn(this);
		return;
	}

// wait for all buttons released
	if(this.deadflag == DEAD_DEAD)
	{
		if(this.button3 || this.button2 || this.button1 || this.button0)
			return;
		this.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if(!this.button3 && !this.button2 && !this.button1 && !this.button0)
		return;
	if(this.impaled)
		return;
	this.impaled = false;

	this.button0 = 0;
	this.button1 = 0;
	this.button2 = 0;
	this.button3 = 0;
	this.button4 = 0;
	this.button5 = 0;
	// Yoder Sept24, 2021
	if(MP_MG && horde_ent)
	{
		if((coop && HordeGetPlayersAlive() <= 0) || !coop)
			horde_respawn_all();
		return;
	}
	respawn(this);
}


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void DeathBubbles(entity this, int num_bubbles);
void GameLogEcho(string s);

.string netname_previous;
void PlayerPreThink(entity this)
{
	// Check for nameless players
	if (this.netname != this.netname_previous)
	{
		if (isInvisibleString(this.netname))
		{
			this.netname = strzone(sprintf("Player#%d", this.playerid));
			// stuffcmd(this, strcat("name ", this.netname, "\n")); // maybe?
		}
		if (autocvar_sv_eventlog) {
			GameLogEcho(strcat(":name:", ftos(this.playerid), ":", this.netname));
        }
		if (this.netname_previous) strunzone(this.netname_previous);
		this.netname_previous = strzone(this.netname);
	}

	this.disableclientprediction = ((intermission_running || this.deadflag != DEAD_NO) ? 1 : -1);

	if(this.exptime != 0)
		return;

	if(intermission_running)
	{
		IntermissionThink(this);	// otherwise a button could be missed between
		return;					// the think tics
	}

	if(this.view_ofs == '0 0 0')
		return;		// intermission or finale

	//JIM
	// Kill player on Edge of Oblivion
	if((this.origin_z < -1300) && (world.model == "maps/hipdm1.bsp") && (this.health > 0))
	{
		if (this.invincible_finished >= time)
		{
			this.invincible_finished = 0;
			this.powerups &= ~POWERUP_INVULNERABILITY;
			this.invincible_time = 0;
			this.invincible_finished = 0;
			this.effects &= ~EF_DIMLIGHT;
		}
		T_Damage(this, this, NULL, this.health + 1000, DEATH_FALL.m_id);
	}

	if(earthquake_active && IS_ONGROUND(this))
	{
		this.velocity_x = this.velocity_x + (random() * earthquake_intensity * 2) - earthquake_intensity;
		this.velocity_y = this.velocity_y + (random() * earthquake_intensity * 2) - earthquake_intensity;
		this.velocity_z = this.velocity_z + (random() * earthquake_intensity * 2) - earthquake_intensity;
	}

	//makevectors(this.v_angle);		// is this still used

	if(this.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink(this);
		return;
	}
	
	if(this.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

// teleporters can force a non-moving pause time	
	if(this.pausetime != -1 && time < this.pausetime)
		this.velocity = '0 0 0';

	if((this.powerups & POWERUP_ANTIGRAV) && time > this.AGping)
	{
		_sound(this, CH_TRIGGER_SINGLE, "belt/use.wav", 0.4, ATTN_NORM);
		this.AGping = time + 3;
		if(this.AGping >= (this.antigrav_finished - 3))
			this.AGping = this.antigrav_finished + 3;
	}

	Weapon wep = this.weaponentity.m_weapon;
	if(time > this.attack_finished && !wep.wr_checkammo1(wep, this))
		W_SwitchWeapon(this, w_getbestweapon(this));
}
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void CheckPowerups(entity this)
{
	if(this.health <= 0)
		return;

// invisibility
	if(this.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if(this.invisible_sound < time)
		{
			_sound(this, CH_TRIGGER_SINGLE, "items/inv3.wav", 0.5, ATTN_IDLE);
			this.invisible_sound = time +((random() * 3) + 1);
		}


		if(this.invisible_finished < time + 3)
		{
			if(this.invisible_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_INVISIBLE);
				stuffcmd(this, "bf\n");
				_sound(this, CH_TRIGGER_SINGLE, "items/inv2.wav", 1, ATTN_NORM);
				this.invisible_time = time + 1;
			}
			
			if(this.invisible_time < time)
			{
				this.invisible_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.invisible_finished < time)
		{	// just stopped
			this.powerups &= ~POWERUP_INVISIBILITY;
			this.invisible_finished = 0;
			this.invisible_time = 0;
		}
		
	// use the eyes
		this.frame = 0;
		this.modelindex = modelindex_eyes;
	}
	else
		this.modelindex = this.modelindex_player; // don't use eyes

// invincibility
	if(this.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if(this.invincible_finished < time + 3)
		{
			if(this.invincible_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_PROTECTION);
				stuffcmd(this, "bf\n");
				_sound(this, CH_TRIGGER_SINGLE, "items/protect2.wav", 1, ATTN_NORM);
				this.invincible_time = time + 1;
			}
			
			if(this.invincible_time < time)
			{
				this.invincible_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}
		
		if(this.invincible_finished < time)
		{	// just stopped
			this.powerups &= ~POWERUP_INVULNERABILITY;
			this.invincible_time = 0;
			this.invincible_finished = 0;
		}
		if(this.invincible_finished > time)
			this.effects |= EF_DIMLIGHT;
		else
			this.effects &= ~EF_DIMLIGHT;
	}

// super damage
	if(this.super_damage_finished)
	{
// sound and screen flash when items starts to run out

		if(this.super_damage_finished < time + 3)
		{
			if(this.super_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_QUAD_DAMAGE);
				stuffcmd(this, "bf\n");
				_sound(this, CH_TRIGGER_SINGLE, "items/damage2.wav", 1, ATTN_NORM);
				this.super_time = time + 1;
			}
			
			if(this.super_time < time)
			{
				this.super_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.super_damage_finished < time)
		{	// just stopped
			this.powerups &= ~POWERUP_QUAD;
			this.super_damage_finished = 0;
			this.super_time = 0;
		}
		if(this.super_damage_finished > time)
			this.effects |= EF_DIMLIGHT;
		else
			this.effects &= ~EF_DIMLIGHT;
	}	

// suit
	{
		if(this.field_generator_finished)
		{
			if(this.field_generator_sound < time)
			{
				_sound(this, CHAN_AUTO, "weapons/field/genpulse.wav", 1, ATTN_NORM);
				stuffcmd(this, "bf\n");
				this.field_generator_sound = time + 1.8;
			}
			if(this.field_generator_finished < time || this.field_generator_health <= 0)
			{
				this.powerups &= ~POWERUP_FIELDGEN;
				this.field_generator_finished = 0;
				this.field_generator_time = 0;
				this.field_generator_health = 0;
				_sound(this, CHAN_AUTO, "weapons/field/genstop.wav", 1, ATTN_NORM);
			}
			else if(this.field_generator_finished < time + 10)
			{
				if(this.field_generator_time <= 1)
				{
					stuffcmd(this, "bf\n");
					_sound(this, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
					this.field_generator_time = time + 1;
				}
				if(this.field_generator_time < time)
					this.field_generator_time = time + 1;
			}
			else if(this.field_generator_health <= 10 && this.field_generator_time <= -10)
			{
				_sound(this, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
				this.field_generator_time = 1;
				stuffcmd(this, "bf\n");
				stuffcmd(this, "bf\n");
			}
			else if(this.field_generator_health <= 50 && this.field_generator_time <= -50)
			{
				_sound(this, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
				this.field_generator_time = -10;
				stuffcmd(this, "bf\n");
				stuffcmd(this, "bf\n");
			}
			else if(this.field_generator_health <= 150 && this.field_generator_time == -150)
			{
				_sound(this, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
				this.field_generator_time = -50;
				stuffcmd(this, "bf\n");
				stuffcmd(this, "bf\n");
			}
			else
			{
				if(this.field_generator_health <= 100 && random() > (this.field_generator_health / 50))
					this.effects |= EF_BRIGHTFIELD;
				else if(this.field_generator_finished < (time + 10) && random() > ((this.field_generator_finished - time) / 5))
					this.effects |= EF_BRIGHTFIELD;
				else
					this.effects &= ~EF_BRIGHTFIELD;
			}
		}
		else
			this.effects &= ~EF_BRIGHTFIELD;
	}

	if(this.radsuit_finished)
	{
		this.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if(this.radsuit_finished < time + 3)
		{
			if(this.rad_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_BIOSUIT);
				stuffcmd(this, "bf\n");
				_sound(this, CH_TRIGGER_SINGLE, "items/suit2.wav", 1, ATTN_NORM);
				this.rad_time = time + 1;
			}
			
			if(this.rad_time < time)
			{
				this.rad_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.radsuit_finished < time)
		{	// just stopped
			this.powerups &= ~POWERUP_SUIT;
			this.rad_time = 0;
			this.radsuit_finished = 0;
		}
	}

	//JIM
	// wetsuit
	if(this.wetsuit_finished)
	{
		this.air_finished = time + 12;		// don't drown

	// sound and screen flash when items starts to run out
		if(this.wetsuit_finished < time + 3)
		{
			if(this.wetsuit_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_WETSUIT);
				stuffcmd(this, "bf\n");
				_sound(this, CH_TRIGGER_SINGLE, "items/suit2.wav", 1, ATTN_NORM);
				this.wetsuit_time = time + 1;
			}

			if(this.wetsuit_time < time)
			{
				this.wetsuit_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.wetsuit_finished < time)
		{	// just stopped
//MED
			this.powerups &= ~POWERUP_WETSUIT;
			this.wetsuit_time = 0;
			this.wetsuit_finished = 0;
		}
	}

//MED
// empathy shields
	if(this.empathy_finished)
	{
		// sound and screen flash when items starts to run out
		if(this.empathy_finished < time + 3)
		{
			if(this.empathy_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_EMPATHY);
				stuffcmd(this, "bf\n");
				_sound(this, CH_TRIGGER_SINGLE, "items/suit2.wav", 1, ATTN_NORM);
				this.empathy_time = time + 1;
			}

			if(this.empathy_time < time)
			{
				this.empathy_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.empathy_finished < time)
		{	// just stopped
//MED
			this.powerups &= ~POWERUP_EMPATHY_SHIELDS;
			this.empathy_time = 0;
			this.empathy_finished = 0;
		}
//MED
		if(this.empathy_finished > time)
			this.effects |= EF_DIMLIGHT;
		else
			this.effects &= ~EF_DIMLIGHT;
	}

	if(this.shield_finished)
	{
		if(this.shield_finished < time + 3)
		{
			if(this.shield_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_SHIELD);
				_sound(this, CH_TRIGGER_SINGLE, "shield/fadeout.wav", 1, ATTN_NORM);
				this.shield_time = 0;
			}
			if(this.shield_time < time)
			{
				this.shield_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.shield_finished < time)
		{
			if(!(MP_MG && autocvar_horde))
				sprint(this, "Shield lost.\n");
			this.shield_finished = 0;
			this.powerups &= ~POWERUP_SHIELD;
		}
	}

	if(this.antigrav_finished)
	{
		if(this.antigrav_finished < time + 3)
		{
			if(this.antigrav_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_ANTIGRAV);
				this.antigrav_time = 0;
				_sound(this, CH_TRIGGER_SINGLE, "belt/fadeout.wav", 1, ATTN_NORM);
			}
			if(this.antigrav_time < time)
			{
				this.antigrav_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}
		
		if(this.antigrav_finished < time)
		{
			if(!(MP_MG && autocvar_horde))
				sprint(this, "Antigrav Lost.\n");
			this.antigrav_finished = 0;
			this.powerups &= ~POWERUP_ANTIGRAV;
			this.gravity = 1.0;
		}
	}

	if(this.fireflower_finished)
	{
		if(this.fireflower_finished < time + 3)
		{
			if(this.fireflower_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_FIREFLOWER);
				_sound(this, CH_TRIGGER_SINGLE, "items/powerdown_mario.wav", 1, ATTN_NORM);
				this.fireflower_time = time + 1;
			}

			if(this.fireflower_time < time)
				this.fireflower_time = time + 1;
		}

		if(this.fireflower_finished < time)
		{
			this.powerups &= ~POWERUP_FIREFLOWER;
			this.fireflower_time = 0;
			this.fireflower_finished = 0;
		}
	}

	if(this.jboots_finished)
	{
		if(this.jboots_finished < time + 3)
		{
			if(this.jboots_time == 1)
			{
				if(!(MP_MG && autocvar_horde))
					Send_Notification(NOTIF_ONE, this, MSG_MULTI, POWERDOWN_JUMPBOOTS);
				_sound(this, CH_TRIGGER_SINGLE, "items/jboots_timed.wav", 1, ATTN_NORM);
				this.jboots_time = time + 1;
			}

			if(this.jboots_time < time)
				this.jboots_time = time + 1;
		}

		if(this.jboots_finished < time)
		{
			this.powerups &= ~POWERUP_JUMPBOOTS;
			this.jboots_time = 0;
			this.jboots_finished = 0;
		}
	}
}

void DrownPlayer(entity this)
{
	if(this.deadflag != DEAD_NO)
		return;

	if (this.waterlevel != WATERLEVEL_SUBMERGED)
	{
		if(this.air_finished < time)
			player_sound(this, CH_VOICE, "gasp2.wav", ATTN_NORM);
		else if(this.air_finished < time + 9)
			player_sound(this, CH_VOICE, "gasp1.wav", ATTN_NORM);
		this.air_finished = time + 12;
		this.dmg = 2;
	}
	else if (this.air_finished < time)
	{	// drown!
		if (this.pain_finished < time)
		{
			this.dmg = this.dmg + 2;
			if(this.dmg > 15)
				this.dmg = 10;
			T_Damage(this, NULL, NULL, this.dmg, DEATH_DROWN.m_id);
			this.pain_finished = time + 1;
		}
	}
}

void Player_Physics(entity this)
{
	this.movetype = (this.move_qcphysics) ? MOVETYPE_QCPLAYER : this.move_movetype;

	if(!this.move_qcphysics)
		return;

	if(!frametime && !this.pm_frametime)
		return;

	Movetype_Physics_NoMatchTicrate(this, this.pm_frametime, true);

	this.pm_frametime = 0;

	if(this.movetype >= MOVETYPE_USER_FIRST && this.movetype <= MOVETYPE_USER_LAST) // these cases have no think handling
	{
		if(this.move_movetype == MOVETYPE_PUSH || this.move_movetype == MOVETYPE_FAKEPUSH)
			return; // these movetypes have no regular think function
		// handle thinking here
		if (getthink(this) && this.nextthink > 0 && this.nextthink <= time + PHYS_INPUT_TIMELENGTH)
			RunThink(this, PHYS_INPUT_TIMELENGTH);
	}
}

/*
================
CheckHealthRot

Checks for taking off health points from a player
that recently used a Mega-Health.
================
*/
void CheckHealthRot(entity this)
{
	if(!MP_HIPNOTIC && !(this.items & IT_SUPERHEALTH))
		return;

	if(this.healthrot_nextcheck > time)
		return;

	if(this.health > this.max_health)
	{
		this.health -= 1;
		this.healthrot_nextcheck = time + 1;
		return;
	}

	if(!MP_HIPNOTIC)
		this.items &= ~IT_SUPERHEALTH;
	this.healthrot_nextcheck = 0;
}

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void xpackEnding(entity this);
void Regenerate_Mana(entity this);
void PlayerPostThink(entity this)
{
	Player_Physics(this);

	if(this.view_ofs == '0 0 0')
	{
		earthquake_postthink(this);
		CSQCMODEL_AUTOUPDATE(this);
		return;		// intermission or finale
	}

	earthquake_postthink(this); // !deathmatch?

	if (autocvar_sv_maxidle > 0)
	if (frametime) // WORKAROUND: only use dropclient in server frames (frametime set). Never use it in cl_movement frames (frametime zero).
	if (IS_REAL_CLIENT(this))
	if (IS_PLAYER(this))
	if (!intermission_running) // NextLevel() kills all centerprints after setting this true
	{
		int totalClients = 0;
		FOREACH_CLIENT(IS_REAL_CLIENT(it),
		{
			++totalClients;
		});

		if (totalClients < autocvar_sv_maxidle_minplayers)
		{
			// idle kick disabled
			this.parm_idlesince = time;
		}
		else if (time - this.parm_idlesince < 1) // instead of (time == this.parm_idlesince) to support sv_maxidle <= 10
		{
			if (this.idlekick_lasttimeleft)
			{
				this.idlekick_lasttimeleft = 0;
				Kill_Notification(NOTIF_ONE_ONLY, this, MSG_CENTER, CPID_IDLING);
			}
		}
		else
		{
			float maxidle_time = autocvar_sv_maxidle;
			float timeleft = ceil(maxidle_time - (time - this.parm_idlesince));
			float countdown_time = max(min(10, maxidle_time - 1), ceil(maxidle_time * 0.33)); // - 1 to support maxidle_time <= 10
			if (timeleft == countdown_time && !this.idlekick_lasttimeleft)
			{
				Send_Notification(NOTIF_ONE_ONLY, this, MSG_CENTER, CENTER_DISCONNECT_IDLING, timeleft);
			}
			if (timeleft <= 0) {
				if (dropclient_schedule(this))
					Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_QUIT_KICK_IDLING, this.netname, maxidle_time);
				return;
			}
			else if (timeleft <= countdown_time) {
				if (timeleft != this.idlekick_lasttimeleft)
					play2(this, SND(TALK2));
				this.idlekick_lasttimeleft = timeleft;
			}
		}
	}

	if(this.deadflag == DEAD_NO)
	{
		if(cutscene_running)
			xpackEnding(this);

		// do weapon stuff
		W_WeaponFrame(this);

		if(this.cnt > 0 && !this.button0)
		{
			this.attack_finished = time + 0.8;
			this.cnt = 0;
		}

		// AY 11 Nov 2021, check killspree end
		if(MP_MG)
		{
			if (this.killspree > 0 && time > this.killtime)
			{
				LOG_DEBUG("killspree ended.");
				
				//score = (this.killspree + (this.killspree - 1) -1) * 5; // previously was "attacker.killspree - 1"
				if(this.killspree > 1)
				{
					float score = ceil((this.killspree * this.killspree) / 2);
					//sprint(this, sprintf("%s lost their kill streak of %d!\n", this.netname, this.killspree));
					this.frags += score;
				}
				
				this.killspree = 0; // reset killspree
			}
		}

		Regenerate_Health(this);
		Regenerate_Mana(this);
		if(STAT(BOARD_FALLING, this) && this.pausetime > time)
		{
			this.angles = this.mangle;
			this.push_fast_time = 0;
		}

		CheckPowerups(this);
		CheckHealthRot(this);

		if(IS_PLAYER(this))
			DrownPlayer(this);
	}

	CSQCMODEL_AUTOUPDATE(this);
}

string hip_getcdtrack(int numb)
{
	switch(numb)
	{
		default:
		//case 1: return "track001";
		case 2: return "hip_track02";
		case 3: return "hip_track03";
		case 4: return "hip_track04";
		case 5: return "hip_track05";
		case 6: return "hip_track06";
		case 7: return "hip_track07";
		case 8: return "hip_track08";
		case 9: return "hip_track09";
		//case 10: return "track010";
		//case 11: return "track011";
	}

	return "hip_track02"; // because gmqcc
}

string rogue_getcdtrack(int numb)
{
	switch(numb)
	{
		default:
		//case 1: return "track01";
		case 2: return "rtrack02";
		case 3: return "rtrack03";
		case 4: return "rtrack04";
		case 5: return "rtrack05";
		case 6: return "rtrack06";
		case 7: return "rtrack07";
		case 8: return "rtrack08";
		case 9: return "rtrack09";
		//case 10: return "track010";
		//case 11: return "track011";
	}

	return "rtrack02"; // because gmqcc
}

string getcdtrack(int numb)
{
	if(MP_HIPNOTIC)
		return hip_getcdtrack(numb);
	if(MP_ROGUE)
		return rogue_getcdtrack(numb);

	switch(numb)
	{
		default:
		case 1: return "track001";
		case 2: return "track002";
		case 3: return "track003";
		case 4: return "track004";
		case 5: return "track005";
		case 6: return "track006";
		case 7: return "track007";
		case 8: return "track008";
		case 9: return "track009";
		case 10: return "track010";
		case 11: return "track011";
	}

	return "track001"; // because gmqcc
}


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void ClientConnect(entity this)
{
	make_impure(this);
	this.classname = "player_joining";
	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_JOIN_CONNECT, this.netname);

	this.suicide_delay = time + 5;

	static int playerid_last;
	this.playerid = ++playerid_last;

	this.flags |= FL_CLIENT;

	this.netname_previous = strzone(this.netname);

	this.disableclientprediction = -1;

	StatusEffectsStorage_attach(this);

	string thetrack = ((current_cdtrack) ? current_cdtrack : getcdtrack(world.sounds));
	stuffcmd(this, strcat("cd loop ", thetrack, "\n"));

	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":join:", ftos(this.playerid), ":", ftos(etof(this)), ":", this.netaddress, ":", this.netname));
	
// a client connecting during an intermission can cause problems
	if(intermission_running)
		ExitIntermission();

	CSQCMODEL_AUTOINIT(this);

	Physics_UpdateStats(this);
}


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void ClientDisconnect(entity this)
{
	if(gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// yoder oct13, horde fix for dc-ing players
	if(MP_MG && autocvar_horde)
		this.health = 0;

	// let everyone else know
	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_QUIT_DISCONNECT, this.netname, this.frags);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(this.playerid)));
	_sound(this, CH_PLAYER, "player/tornoff2.wav", 1, ATTN_NONE);
	this.effects = 0;

	StatusEffectsStorage_delete(this);

	status_effects_ClientDisconnect(this);

	sphere_remove(this);

	set_suicide_frame(this);

	strfree(this.weaponorder_byimpulse);
	GetCvars(this, this, -1);

	if (vote_called && IS_REAL_CLIENT(this)) VoteCount(false);

	ONREMOVE(this);
}

/*
===========
ClientObituary

called when a player dies
============
*/
string AppendItemcodes(string s, entity player)
{
	int w = player.weaponentity.m_weapon.m_id;
	if(w == 0)
		w = player.weaponentity.cnt;
	s = strcat(s, ftos(w));
	if(PHYS_INPUT_BUTTON_BUTTON_CHAT(player))
		s = strcat(s, "T");
	return s;
}

void LogDeath(string mode, int deathtype, entity killer, entity killed)
{
	string s;
	if(!autocvar_sv_eventlog)
		return;
	s = strcat(":kill:", mode);
	s = strcat(s, ":", ftos(killer.playerid));
	s = strcat(s, ":", ftos(killed.playerid));
	s = strcat(s, ":type=", Deathtype_Name(deathtype));
	s = strcat(s, ":items=");
	s = AppendItemcodes(s, killer);
	if(killed != killer)
	{
		s = strcat(s, ":victimitems=");
		s = AppendItemcodes(s, killed);
	}
	GameLogEcho(s);
}

void Obituary_SpecialDeath(
	entity notif_target,
	float murder,
	int deathtype,
	string s1, string s2)
{
	if(!DEATH_ISSPECIAL(deathtype))
	{
		backtrace("Obituary_SpecialDeath called without a special deathtype?\n");
		return;
	}

	entity deathent = REGISTRY_GET(Deathtypes, deathtype - DT_FIRST);
	if (!deathent)
	{
		backtrace("Obituary_SpecialDeath: Could not find deathtype entity!\n");
		return;
	}

	Notification death_message = (murder) ? deathent.death_msgmurder : deathent.death_msgself;
	if(death_message)
	{
		Send_Notification(
			NOTIF_ONE,
			notif_target,
			MSG_MULTI,
			death_message,
			s1, s2
		);
		Send_Notification(
			NOTIF_ALL_EXCEPT,
			notif_target,
			MSG_INFO,
			death_message.nent_msginfo,
			s1, s2
		);
	}
}

float Obituary_WeaponDeath(
	entity notif_target,
	float murder,
	int deathtype,
	string s1, string s2)
{
	Weapon death_weapon = DEATH_WEAPONOF(deathtype);
	if (death_weapon == WEP_Null)
		return false;

	w_deathtype = deathtype;
	Notification death_message = ((murder) ? death_weapon.wr_killmessage(death_weapon) : death_weapon.wr_suicidemessage(death_weapon));
	w_deathtype = false;

	if (death_message)
	{
		Send_Notification(
			NOTIF_ONE,
			notif_target,
			MSG_MULTI,
			death_message,
			s1, s2
		);
		// send the info part to everyone
		Send_Notification(
			NOTIF_ALL_EXCEPT,
			notif_target,
			MSG_INFO,
			death_message.nent_msginfo,
			s1, s2
		);
	}
	else
	{
		LOG_TRACEF(
			"Obituary_WeaponDeath(): ^1Deathtype ^7(%d)^1 has no notification for weapon %s!\n",
			deathtype,
			death_weapon.netname
		);
	}

	return true;
}

bool frag_centermessage_override(entity attacker, entity targ, int deathtype, string attacker_name)
{
	if(empathyused)
	{
		Send_Notification(NOTIF_ONE, attacker, MSG_CENTER, CENTER_DEATH_MURDER_FRAG_EMPATHY, targ.netname);
		Send_Notification(NOTIF_ONE, targ, MSG_CENTER, CENTER_DEATH_MURDER_FRAGGED_EMPATHY, attacker_name);
		return true;
	}

	return false;
}

void Obituary(entity attacker, entity inflictor, entity targ, int deathtype)
{
	// Sanity check
	if (!IS_PLAYER(targ)) { backtrace("Obituary called on non-player?!\n"); return; }

	// Declarations
	string attacker_name = attacker.netname;

	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(
		sprintf(
			"Obituary(%s, %s, %s, %s = %d);\n",
			attacker_name,
			inflictor.netname,
			targ.netname,
			Deathtype_Name(deathtype),
			deathtype
		)
	);
	#endif

	// =======
	// SUICIDE
	// =======
	if(targ == attacker)
	{
		if(DEATH_ISSPECIAL(deathtype))
		{
			switch(DEATH_ENT(deathtype))
			{
				case DEATH_MIRRORDAMAGE:
				{
					Obituary_SpecialDeath(targ, false, deathtype, targ.netname, "");
					break;
				}
				case DEATH_HURTTRIGGER:
					Obituary_SpecialDeath(targ, false, deathtype, targ.netname, inflictor.message);
					break;
				default:
				{
					Obituary_SpecialDeath(targ, false, deathtype, targ.netname, "");
					break;
				}
			}
		}
		else if (!Obituary_WeaponDeath(targ, false, deathtype, targ.netname, ""))
		{
			backtrace("SUICIDE: what the hell happened here?\n");
			return;
		}
		LogDeath("suicide", deathtype, targ, targ);
		targ.frags -= 1;
	}

	// ======
	// MURDER
	// ======
	else if(IS_PLAYER(attacker))
	{
		LogDeath("frag", deathtype, attacker, targ);
		attacker.frags += 1;

		if(!frag_centermessage_override(attacker, targ, deathtype, attacker_name))
		{
			Send_Notification(
				NOTIF_ONE,
				attacker,
				MSG_CENTER,
				CENTER_DEATH_MURDER_FRAG,
				targ.netname
			);
			Send_Notification(
				NOTIF_ONE,
				targ,
				MSG_CENTER,
				CENTER_DEATH_MURDER_FRAGGED,
				attacker_name
			);
		}

		if (!Obituary_WeaponDeath(targ, true, deathtype, targ.netname, attacker_name))
			Obituary_SpecialDeath(targ, true, deathtype, targ.netname, attacker_name);
	}

	// =============
	// ACCIDENT/TRAP
	// =============
	else
	{
		switch(DEATH_ENT(deathtype))
		{
			// For now, we're just forcing HURTTRIGGER to behave as "DEATH_VOID" and giving it no special options...
			// Later on you will only be able to make custom messages using DEATH_CUSTOM,
			// and there will be a REAL DEATH_VOID implementation which mappers will use.
			case DEATH_HURTTRIGGER:
			{
				Obituary_SpecialDeath(targ, false, deathtype,
					targ.netname,
					inflictor.message);
				break;
			}

			default:
			{
				Obituary_SpecialDeath(targ, false, deathtype, targ.netname, "");
				break;
			}
		}

		LogDeath("accident", deathtype, targ, targ);
		targ.frags -= 1;
	}
}

int Say(entity source, int teamsay, entity privatesay, string msgin, bool floodcontrol);
void NoclipCheat(entity this);
void SV_ParseClientCommand(entity this, string command)
{
	// If invalid UTF-8, don't even parse it
	string command2 = "";
	float len = strlen(command);
	float i;
	for (i = 0; i < len; ++i)
		command2 = strcat(command2, chr2str(str2chr(command, i)));
	if (command != command2) return;

	float argc = tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	string cmd_name = strtolower(argv(0));

	// for floodcheck
	switch (cmd_name)
	{
		// exempt commands which are not subject to floodcheck
		case "begin": break;                               // handled by engine in host_cmd.c
		case "download": break;                            // handled by engine in cl_parse.c
		case "mv_getpicture": break;                       // handled by server in this file
		case "pause": break;                               // handled by engine in host_cmd.c
		case "prespawn": break;                            // handled by engine in host_cmd.c
		case "sentcvar": break;                            // handled by server in this file
		case "spawn": break;                               // handled by engine in host_cmd.c
		case "c2s": Net_ClientCommand(this, command); return; // handled by net.qh
	}

	if(cmd_name == "cvar_purechanges")
	{
		sprint(this, strcat(cvar_purechanges, "\n"));
		return;
	}

	if(cmd_name == "cvar_changes")
	{
		sprint(this, strcat(cvar_changes, "\n"));
		return;
	}

	if(cmd_name == "sentcvar")
	{
		if(argc >= 3)
			GetCvars(this, this, 1);
		else
			sprint(this, "Incorrect parameters for GetCvars\nUsage:^3 cmd sentcvar <cvar> <arguments>\n");
		return;
	}

	if(cmd_name == "noclip")
	{
		NoclipCheat(this);
		return;
	}

	if(cmd_name == "vote")
	{
		VoteCommand(CMD_REQUEST_COMMAND, this, argc, command);
		return;
	}

	if(cmd_name == "tracer")
	{
		makevectors(this.v_angle);
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 300, MOVE_NORMAL, this);
		sprint(this, strcat("Texture: ", trace_dphittexturename, "\n"));
		sprint(this, strcat("Texture flag: ", ftos(trace_dphitq3surfaceflags), "\n"));
		sprint(this, sprintf("Entity: %s (%d)\n", trace_ent.classname, etof(trace_ent)));
		return;
	}

	if(cmd_name == "say" || cmd_name == "say_team")
	{
		if(argc >= 2) Say(this, false, NULL, substring(command, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), 1);
		return;
	}

	if(cmd_name == "info")
	{
		string thecmd = cvar_string(strcat("sv_info_", argv(1)));

		if (thecmd) wordwrap_sprint(this, thecmd, 1000);
		else sprint(this, "ERROR: unsupported info command");
		return;
	}

	if(sv_shop_command(this, cmd_name, argc))
		return;

	clientcommand(this, command);
}

void setcolor(entity this, int clr)
{
#if 0
	this.clientcolors = clr;
	this.team = (clr & 15) + 1;
#else
	builtin_setcolor(this, clr);
#endif
}

void SetPlayerColors(entity pl, float _color)
{
	/*string s;
	s = ftos(cl);
	stuffcmd(pl, strcat("color ", s, " ", s, "\n")  );
	pl.team = cl + 1;
	//pl.clientcolors = pl.clientcolors - (pl.clientcolors & 15) + cl;
	pl.clientcolors = 16*cl + cl;*/

	int pants = _color & 0x0F;
	int shirt = _color & 0xF0;

	setcolor(pl, shirt + pants);
}

void SV_ChangeTeam(entity this, float _color)
{
	SetPlayerColors(this, _color);

	if(!IS_CLIENT(this))
	{
		// since this is an engine function, and gamecode doesn't have any calls earlier than this, do the connecting message here
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_CONNECTING, this.netname);
		return;
	}
}

/**
 * Determines whether the player is allowed to join. This depends on cvar
 * g_maxplayers, if it isn't used this function always return true, otherwise
 * it checks whether the number of currently playing players exceeds g_maxplayers.
 * @return int number of free slots for players, 0 if none
 */
int nJoinAllowed(entity this, entity ignore)
{
	// TODO simplify this
	int totalClients = 0;
	int currentlyPlaying = 0;
	FOREACH_CLIENT(true, LAMBDA(
		if(it != ignore)
			++totalClients;
		if(IS_REAL_CLIENT(it) && IS_PLAYER(it))
			++currentlyPlaying;
	));

	int free_slots = maxclients - totalClients;

	return free_slots;
}
