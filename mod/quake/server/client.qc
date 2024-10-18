#include "client.qh"

#include <lib/csqcmodel/sv_model.qh>
#include <common/csqcmodel_settings.qh>
#include "../common/physics.qh"
#include "../common/dodgeball/dodgeball.qh"
#include "../common/slide/slide.qh"
#include "../common/champions/_mod.qh"
#include "../common/editor.qh"
#include "../common/music.qh"
#include "chat_grabber.qh"
#include "combat.qh"
#include "command/banning.qh"
#include "command/cmd.qh"
#include "getreplies.qh"
#include "ipban.qh"
#include "player.qh"
#include "rogue/sphere.qh"
#include "shop.qh"
#include "../common/triggers/teleporters.qh"
#include "../common/triggers/trigger/fog.qh"
#include "vote.qh"
#include "weapons/weaponsystem.qh"

.entity chatbubbleentity;

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

void clear_powerups(entity this)
{
	this.powerups = 0;
	this.effects &= ~EF_STARDUST;

	FOREACH(StatusEffect, it.instanceOfPowerups,
	{
		if(StatusEffects_active(it, this))
			StatusEffects_remove(it, this, STATUSEFFECT_REMOVE_CLEAR);
	});
}

bool reset_flag;
void SetChangeParms(entity this)
{
	if(reset_flag)
	{
		setspawnparms(this);
		return;
	}
	if(this.health <= 0 || deathmatch || world.worldtype == WORLDTYPE_HUB || world.worldtype == WORLDTYPE_SKATE || world.worldtype == WORLDTYPE_SLIDE || world.worldtype == WORLDTYPE_DODGEBALL)
	{
		SetNewParms();
		return;
	}

// remove items
	this.items &= ~(IT_KEY1 | IT_KEY2);
	this.items &= ~IT_TANK;
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
	.entity weaponentity = weaponentities[0]; // only save first slot
	if(this.(weaponentity))
		parm9 = this.(weaponentity).m_weapon.m_id;
	parm10 = STAT(BREEGULL_EGGTYPE, this);
	parm11 = this.ammo_lava_nails;
	parm12 = this.ammo_multi_rockets;
	parm13 = this.ammo_plasma;
	parm14 = this.currentspell;
	if(this.(weaponentity))
		parm15 = this.(weaponentity).cnt;
	parm16 = this.items;
}

void SetNewParms()
{
	Weapon start_weapon = WEP_AXE;
	if(autocvar_horde)
		start_weapon = WEP_CHAINSAW;
	else if(world.worldtype == WORLDTYPE_DODGEBALL)
		start_weapon = WEP_BALL;
	WepSet weps = (WEPSET(SHOTGUN) | start_weapon.m_wepset);
	if(world.worldtype == WORLDTYPE_DODGEBALL)
		weps = start_weapon.m_wepset;
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
	parm10 = 0;
	parm11 = 0;
	parm12 = 0;
	parm13 = 0;
	parm14 = 0;
	parm15 = start_weapon.m_id; // always use axe as the alternate weapon
}

void DecodeLevelParms(entity this)
{
	WepSet oldweps = vec3(parm1, parm2, parm3);
	if(world.model == "maps/quake.bsp" || world.model == "maps/start.bsp" || world.model == "maps/aopstart.bsp" || world.worldtype == WORLDTYPE_HUB || world.worldtype == WORLDTYPE_SLIDE || world.worldtype == WORLDTYPE_DODGEBALL || (oldweps & WEPSET(BALL)))
		SetNewParms();		// take away all stuff on starting new episode

	// Yoder Oct25, reset weapons between map loads
	if(autocvar_horde)
		SetNewParms();

	if(world.model == "maps/hipstart.bsp"
	|| world.model == "maps/hip1m1.bsp"
	|| world.model == "maps/hip2m1.bsp"
	|| world.model == "maps/hip3m1.bsp"
	) SetNewParms(); // take away all stuff on starting new episode

	if(world.model == "maps/rstart.bsp" || ((world.model == "maps/r2m1.bsp" || world.model == "maps/aop2m1.bsp") && !deathmatch))
		SetNewParms(); // reset all stuff on level 8 and new episode

	STAT(WEAPONS, this) = vec3(parm1, parm2, parm3);
	QCC_ClearWeapons(this);
	this.armorvalue = parm4;
	this.ammo_shells = parm5;
	this.ammo_nails = parm6;
	this.ammo_rockets = parm7;
	this.ammo_cells = parm8;
	.entity weaponentity = weaponentities[0]; // only enough space to save the first slot!
	Weapon wep = REGISTRY_GET(Weapons, parm9);
	if(this.(weaponentity) && wep != WEP_Null && (STAT(WEAPONS, this) & wep.m_wepset))
		this.(weaponentity).m_weapon = REGISTRY_GET(Weapons, parm9);
	if(STAT(BREEGULL_EGGTYPE, this) <= 0) // allow preserving current selection over the map given one
		STAT(BREEGULL_EGGTYPE, this) = parm10;
	this.ammo_lava_nails = parm11;
	this.ammo_multi_rockets = parm12;
	this.ammo_plasma = parm13;

	this.currentspell = parm14;
	if(this.(weaponentity))
		this.(weaponentity).skin = parm14;
	if(this.(weaponentity))
		this.(weaponentity).cnt = parm15;
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

string autocvar_sv_allow_customplayermodels_silent = "";

string get_playermodel(entity this)
{
	if(STAT(SKATING, this))
		return "progs/skater.mdl";
	else if(world.worldtype == WORLDTYPE_DODGEBALL)
	{
		if(STAT(HAS_BALL, this))
			return "progs/player_db2.mdl";
		else
			return "progs/player_db.mdl";
	}
	else if(STAT(SLIDE_ON, this))
	{
		if(this.cvar_cl_quake_model == "goat" && !CHAMPION_Goat.m_condition(CHAMPION_Goat, this))
			return "progs/player_goat.mdl";
		else
			return "progs/surfer1.mdl";
	}
	if(this.m_champion)
		return this.m_champion.m_model.model_str();
	return "progs/player.mdl";
}

string get_playerhead(entity this)
{
	if(STAT(SKATING, this))
		return "progs/h_player.mdl";
	else if(STAT(SLIDE_ON, this))
		return "progs/h_player.mdl";
	if(this.m_champion)
		return this.m_champion.m_model_head.model_str();
	return "progs/h_player.mdl";
}

string get_deathsound(entity this, int chance)
{
	if(STAT(SKATING, this))
		return "player/death1.wav"; // not actually used
	if(this.m_champion && !STAT(SLIDE_ON, this))
		return this.m_champion.m_sound_death();
	switch(chance)
	{
		default:
		case 1: return "player/death1.wav";
		case 2: return "player/death2.wav";
		case 3: return "player/death3.wav";
		case 4: return "player/death4.wav";
		case 5: return "player/death5.wav";
	}

	// never actually reached, thanks gmqcc
	return "player/death1.wav";
}

string get_painsound(entity this, int chance)
{
	if(STAT(SKATING, this))
		return "player/pain6.wav";
	if(this.m_champion && !STAT(SLIDE_ON, this))
		return this.m_champion.m_sound_pain();
	switch(chance)
	{
		case 1: return "player/pain1.wav";
		case 2: return "player/pain2.wav";
		case 3: return "player/pain3.wav";
		case 4: return "player/pain4.wav";
		case 5: return "player/pain5.wav";
		default: return "player/pain6.wav";
	}

	// never actually reached, thanks gmqcc
	return "player/pain6.wav";
}

void playersound(entity this, int chan, string sample, float vol, float atten)
{
	if(this.spawnsilent)
	{
		float r = random() * (random() * 3);
		sound7(this, chan, sample, vol, atten, 100 / r, 0);
	}
	else
		_sound(this, chan, sample, vol, atten);
}

void player_sound(entity this, int chan, string sample, float atten)
{
	if(this.clockwork)
		return; // no player sounds thank you very much
	string soundpath;
	if(STAT(SKATING, this))
		soundpath = "player/";
	else if(this.m_champion)
		soundpath = this.m_champion.m_soundpath;
	else
		soundpath = "player/";
	playersound(this, chan, strcat(soundpath, sample), 1, atten);
}

void ChatBubbleThink(entity this)
{
	this.nextthink = time;
	if ((this.owner.alpha < 0) || this.owner.chatbubbleentity != this)
	{
		if(this.owner) // but why can that ever be NULL?
			this.owner.chatbubbleentity = NULL;
		delete(this);
		return;
	}

	this.mdl = "";

	if ( this.owner.health > 0 && !this.owner.elec && IS_PLAYER(this.owner) )
	{
		if (PHYS_INPUT_BUTTON_CHAT(this.owner))
			this.mdl = "models/misc/chatbubble.spr";
	}

	if ( this.model != this.mdl )
		_setmodel(this, this.mdl);

}

void UpdateChatBubble(entity this)
{
	if (this.alpha < 0)
		return;
	// spawn a chatbubble entity if needed
	if (!this.chatbubbleentity)
	{
		this.chatbubbleentity = new(chatbubbleentity);
		this.chatbubbleentity.owner = this;
		this.chatbubbleentity.exteriormodeltoclient = this;
		setthink(this.chatbubbleentity, ChatBubbleThink);
		this.chatbubbleentity.nextthink = time;
		setmodel(this.chatbubbleentity, MDL_CHAT); // precision set below
		//setorigin(this.chatbubbleentity, this.origin + '0 0 15' + this.maxs_z * '0 0 1');
		setorigin(this.chatbubbleentity, '0 0 12' + this.maxs_z * '0 0 1');
		setattachment(this.chatbubbleentity, this, "");  // sticks to moving player better, also conserves bandwidth
		this.chatbubbleentity.mdl = this.chatbubbleentity.model;
		//this.chatbubbleentity.model = "";
		this.chatbubbleentity.effects = EF_LOWPRECISION;
	}
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
		if(autocvar_horde)
			changelevel(HordeRandomMap());
		else if(deathmatch)
			changelevel(PickDMMap(true));
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
			//if(!autocvar_registered)
			//{
				//WriteByte(MSG_ALL, SVC_FINALE);
				//WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			//}
			//else
			//{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			//}
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
		if(world.endtext && world.endtext != "")
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
		//if(nextmap == "start" || nextmap == "hipstart" || nextmap == "rstart" || nextmap == "aopstart" || nextmap == "mgstart" && !coop && !autocvar_horde) // Yoder modify Oct25 to check against horde
		GotoNextMap();
	}
	
	if(intermission_running == 3)
	{
		//if(!autocvar_registered)
		//{	// shareware episode has been completed, go to sell screen
			//WriteByte(MSG_ALL, SVC_SELLSCREEN);
			//return;
		//}
		
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
	string themap = "quake";
	changelevel(themap);
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
	if(deathmatch || world.worldtype == WORLDTYPE_DODGEBALL)
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
		W_Spellbook_ClearSpells(it);
		tank_cleanup(it);
		cannon_clear(it);
		Clockwork_Clear(it);
		QCC_ClearTransform(it);
		it.nextthink = time + 0.5;
		it.takedamage = DAMAGE_NO;
		it.clientcamera = it;
		it.solid = SOLID_NOT;
		it.flags |= FL_NOTARGET; // fix a silly monster bug
		//it.health = -2342; // can't do this because of parms
		set_movetype(it, MOVETYPE_NONE);
		clear_powerups(it);
		FogPushSettingsFrom(it, pos, 0);
		if(pos)
		{
			//it.modelindex = 0;
			setmodel(it, MDL_Null);
			setsize(it, VEC_HULL_MIN, VEC_HULL_MAX);
			setorigin(it, pos.origin);
		}
	});

	WriteByte(MSG_ALL, SVC_INTERMISSION);

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
	if(ent.model == "")
		return;

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
	if(world.worldtype == WORLDTYPE_DODGEBALL)
	{
		sprint(this, "Pointless...\n");
		return;
	}
	if(time < this.suicide_delay)
	{
		sprint(this, "You must wait before suiciding again... Get help.\n");
		return;
	}
	if(world.worldtype == WORLDTYPE_SLIDE)
		this.suicide_delay = time + 1;
	else
		this.suicide_delay = time + autocvar_sv_quake_kill_delay;

	sphere_remove(this);

	bprintf("%s suicides\n", this.netname);

	if(autocvar_horde) // horde mode behaviour
	{
		PlayerDie(this, NULL, NULL, DEATH_KILL.m_id);
		this.health = 0;
		return;
	}
	champions_PlayerDies(this);
	Tank_PlayerDie(this);
	slide_PlayerDies(this);
	cannon_clear(this);
	this.modelindex = this.modelindex_player;
	WaypointSprite_PlayerDead(this);
	set_suicide_frame(this);
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

	bool have_spawntarget = false;
	if(autocvar__spawntarget && autocvar__spawntarget != "" && find(NULL, targetname, autocvar__spawntarget))
		have_spawntarget = true;
		
// choose a info_player_deathmatch point
	if(autocvar_horde)
	{ // run simpler logic for horde - just need a spot with noone on top of it...
		string horde_spawnpoint = "info_player_coop";
		if(horde_ent.currentammo)
			horde_spawnpoint = "info_player_start";
    	entity hordeSpawn = find(NULL, classname, horde_spawnpoint);

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
			hordeSpawn = find(hordeSpawn, classname, horde_spawnpoint);
		}

		if(coop) // fix for singleplayer
			return NULL; // didn't find anything....
	}
	else if(have_spawntarget)
	{
		RandomSelection_Init();
		FOREACH_ENTITY_STRING(targetname, autocvar__spawntarget,
		{
			if(!coop && it.classname == "info_player_coop")
				continue;
			if(it.classname != "info_player_start" && it.classname != "info_player_coop")
				continue;
			RandomSelection_AddEnt(it, ((it.classname == "info_player_coop") ? 2 : 1), 1);
		});
		lastspawn = RandomSelection_chosen_ent;
		if(!lastspawn)
			lastspawn = find(lastspawn, classname, "info_player_start");
		if(lastspawn)
			return lastspawn;
	}
    else if(coop)
	{
		// choose a point that is active
		RandomSelection_Init();
		FOREACH_ENTITY_CLASS("info_player_coop", it.state == COOP_SPAWN_ACTIVE,
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		lastspawn = RandomSelection_chosen_ent;
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
		spot = find(NULL, classname, "info_player_start2");
		if(spot)
			return spot;
	}
	
	spot = find(NULL, classname, "info_player_start");
	if(!spot)
	{
		//if(!deathmatch) // desperate times
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

.float rejoin_delay;
.float spectate_delay;
float autocvar_sv_quake_rejoin_delay = 3;
void ObserverThink(entity this)
{
	if (this.flags & FL_JUMPRELEASED) {
		if (PHYS_INPUT_BUTTON_JUMP(this)) {
			this.flags &= ~FL_JUMPRELEASED;
			if(time >= this.rejoin_delay)
				this.flags |= FL_SPAWNING;
		}
	} else { // jump pressed
		if (!PHYS_INPUT_BUTTON_JUMP(this)) {
			this.flags |= FL_JUMPRELEASED;
			// primary attack pressed
			if(this.flags & FL_SPAWNING)
			{
				stuffcmd(this, "\ncl_quake_spectate 0\n");
				this.flags &= ~FL_SPAWNING;
				this.classname = STR_PLAYER;
				this.rejoin_delay = time + autocvar_sv_quake_rejoin_delay; // prevent fast spec-rejoin
				dodgeball_Rejoin(this);
				// get the spawn parms as they were at level start
				setspawnparms(this);
				PutClientInServer(this);
				return;
			}
		}
	}

	if(this.button0 && time > this.spectate_delay)
	{
		entity player = (this.clientcamera == this) ? NULL : this.clientcamera;
		entity ent = find(player, classname, STR_PLAYER);
		if(!ent)
			ent = find(ent, classname, STR_PLAYER);
		if(ent)
			this.clientcamera = ent;
		if(this.clientcamera && this.clientcamera != this)
			centerprint(this, strcat("Spectating ", this.clientcamera.netname));
		this.spectate_delay = time + 1;
	}
	else if(PHYS_INPUT_BUTTON_ATCK2(this))
	{
		this.clientcamera = this;
		this.spectate_delay = time + 0.5;
	}
}

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

	if(horde_ent && horde_ent.active && player.just_joined)
	{
		player.health = 0;
		player.takedamage = DAMAGE_NO;
		player.solid = SOLID_NOT;
		set_movetype(player, MOVETYPE_NONE);
		player.deadflag = DEAD_DEAD;
		setmodel(player, MDL_Null);
		player.view_ofs = '0 0 -8'; // not 0 because PlayerPreThink would return out
		player.velocity = '0 0 0';

		spot = FindIntermission(player);
		player.angles = player.v_angle = spot.mangle;
		player.angles_z = 0; // never spawn tilted even if the spot says to
		player.fixangle = true;
		setorigin(player, spot.origin);
		bprintf("%s ^1will join when the next wave begins\n", player.netname);
	}

	player.just_joined = false;

	delete(this);
}

void PutClientInServer(entity this)
{
	if(IS_OBSERVER(this) || gameover || intermission_running || PlayerInList(this, autocvar_g_playban_list))
		PutObserverInServer(this);
	else
		PutPlayerInServer(this);
}

void PutObserverInServer(entity this)
{
	if(IS_PLAYER(this))
	{
		// was a player, recount votes and ready status
		if(IS_REAL_CLIENT(this))
		{
			if (vote_called) { VoteCount(false); }
		}
		entcs_update_players(this);
	}

	WaypointSprite_PlayerDead(this);

	entity spot = SelectSpawnPoint(this, false);

	setorigin(this, spot.origin + '0 0 32');
	this.angles = vec2(spot.angles);
	this.fixangle = true;

	if(this.damagedbycontents)
		IL_REMOVE(g_damagedbycontents, this);
	this.spectating = true;
	this.damagedbycontents = false;
	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_NOT;
	QCC_ClearTransform(this);
	set_movetype(this, MOVETYPE_NONE);
	clear_powerups(this);
	cannon_clear(this);
	this.flags = FL_CLIENT | FL_NOTARGET;
	this.effects = 0;
	this.alpha = 0;
	this.scale = 0;
	this.pain_finished = 0;
	this.dphitcontentsmask = DPCONTENTS_SOLID;
	if (autocvar_g_playerclip_collisions)
		this.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;
	setthink(this, func_null);
	this.nextthink = 0;
	this.deadflag = DEAD_NO;
	this.exptime = 0;
	this.clientcamera = this;
	this.waterlevel = WATERLEVEL_NONE;
	this.watertype = CONTENT_EMPTY;
	this.pushltime = 0;
	this.pusher = NULL;

	STAT(PASSIVES, this) = 0;

	Clockwork_Clear(this);

	skate_unspawn(this);

	this.classname = STR_OBSERVER;
	this.health = -666;
	setmodel(this, MDL_Null);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.view_ofs = '0 0 0';

	this.items = 0;
	STAT(WEAPONS, this) = '0 0 0';
	this.drawonlytoclient = this;

	this.weaponmodel = "";
	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		this.weaponentities[slot] = NULL;
	}
	this.velocity = '0 0 0';
	this.avelocity = '0 0 0';
	this.punchangle = '0 0 0';
	this.punchvector = '0 0 0';
	this.oldvelocity = this.velocity;

	//if(this.just_joined)
	this.just_joined = true; // HACK: for horde to properly "detect" when a player is attempting to join again

	Tank_PlayerDie(this);
	champions_RemovePlayer(this);
	music_RemovePlayer(this);
	dodgeball_RemovePlayer(this);
}

void PutPlayerInServer(entity this)
{
	entity spot = SelectSpawnPoint(this, false);

	this.spectating = false;
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
	clear_powerups(this);
	cannon_clear(this);
	this.healthrot_nextcheck = 0;
	this.effects = EF_TELEPORT_BIT;
	this.drawonlytoclient = NULL;
	this.clientcamera = this;
	this.waterlevel = WATERLEVEL_NONE;
	this.watertype = CONTENT_EMPTY;
	this.pushltime = 0;
	this.pusher = NULL;

	this.alpha = 1;
	this.colormod = '1 1 1';

	this.viewloc = NULL;

	this.weaponframe = 0;
	this.weaponmodel = "";

	STAT(DUAL_WEAPONS, this) = '0 0 0';

	// hipnotic fields
	this.gravity = 1.0;
	this.gorging = false;

	STAT(PASSIVES, this) = 0;

	Clockwork_Clear(this);

	// Cut off any still running player sounds.
	stopsound(this, CH_PLAYER_SINGLE);

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	this.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID;
	if (autocvar_g_playerclip_collisions)
		this.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;

	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		CL_SpawnWeaponentity(this, weaponentity);
		entity w_ent = this.(weaponentity);
		w_ent.m_weapon = WEP_Null;
		w_ent.weaponname = "";
		//w_ent.cnt = -1;
		w_ent.skin = this.currentspell; // TODO: after DecodeLevelParms?
	}

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
	if(world.worldtype == WORLDTYPE_DODGEBALL)
		spot = SelectTeamSpawn(this, this.team_no);
	else
		spot = SelectSpawnPoint(this, false);
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
		for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			this.(weaponentity).m_weapon = WEP_Null;
			this.(weaponentity).hammer_skin = 1;
		}

		return;
	}

	this.spawn_deferred = 0;

	this.origin = spot.origin + '0 0 1';
	this.angles = vec2(spot.angles);
	this.angles_z = 0; // never spawn tilted even if the spot says to
	this.fixangle = true;		// turn this way immediately

	if(coop && STAT(WEAPONS, spot))
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

	music_RemovePlayer(this);

	//JIM
	// Clear out velocity so you're not launched into the air
	// when you respawn.
	this.velocity = '0 0 0';

	STAT(MANA, this) = 100;
	this.mana_regen_pause = 0;

	skate_spawn(this);

	slide_PutPlayerInServer(this);

	dodgeball_PutPlayerInServer(this);

// oh, this is a hack!
	_setmodel(this, "progs/bolt2.mdl");
	modelindex_bolt = this.modelindex;

	_setmodel(this, get_playermodel(this));
	this.modelindex_player = this.modelindex;

	if(autocvar_sv_allow_customplayermodels_silent != "" && random() > 0.5 && PlayerInList(this, autocvar_sv_allow_customplayermodels_silent))
		this.spawnsilent = true;
	else
		this.spawnsilent = false;

	this.scale = 0;

	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);

	this.view_ofs = '0 0 22';
	this.velocity = '0 0 0'; // 1998-07-21 Player moves after respawn fix by Xian

	STAT(QCC_CHAMPION, this) = 0;
	if(!STAT(SKATING, this) && world.worldtype != WORLDTYPE_SLIDE && world.worldtype != WORLDTYPE_DODGEBALL)
		champions_PutPlayerInServer(this);

	player_stand1(this);

	if (this.impulse) ImpulseCommands(this);

	W_ResetGunAlign(this, 1);
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_WeaponFrame(this, weaponentity);
	}

	if(deathmatch || coop)
	{
		fixedmakevectors(this.angles);
		spawn_tfog(this.origin + v_forward * 20);
	}

	spawn_tdeath(this.origin, this);

	entity postSpawn = new(postSpawn);
	postSpawn.owner = this;
	postSpawn.enemy = spot;
	setthink(postSpawn, RunPostPutClientInServer);
	postSpawn.nextthink = time + 0.05;

	stuffcmd(this, "-attack\n"); // prevent shooting after respawning

	// spawns fire targets when spawned at
	SUB_UseTargets(spot, this, NULL);
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
	IL_PUSH(g_spawnpoints, this);
}


/*QUAKED info_player_start2(1 0 0)(-16 -16 -24)(16 16 24)
Only used on start map for the return point from an episode.
*/
spawnfunc(info_player_start2)
{
	IL_PUSH(g_spawnpoints, this);
}

/*QUAKED info_player_start_hub (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
spawnfunc(info_player_start_hub)
{
	IL_PUSH(g_spawnpoints, this);
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
	//if(!deathmatch) { delete(this); return; }
	IL_PUSH(g_spawnpoints, this);
}

spawnfunc(info_player_team1)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		spawnfunc_info_player_deathmatch(this);
}

spawnfunc(info_player_team2)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		spawnfunc_info_player_deathmatch(this);
}

//////////////////////////////////////////////////////////////////////////

void trigger_activate_coop_spawns_use(entity this, entity actor, entity trigger)
{
	WepSet newitems = '0 0 0';
	FOREACH_CLIENT(IS_PLAYER(it) && !it.maycheat,
	{
		newitems |= STAT(WEAPONS, it);
	});
	newitems &= ~WEPSET_CHAMPIONS;

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
	if(!coop) { delete(this); return; }
	this.use = trigger_activate_coop_spawns_use;
}

const int COOP_SPAWN_START_ACTIVE = BIT(0);

// dumb way to make coop starts visible/invisible to the cyclical spawnpoint search 
// code without making that code overly complex
void coop_lock(entity this, bool unlock)
{
	if(unlock)
		this.classname = "info_player_coop";
	else
		this.classname = "info_player_coop_notyet";
}

void coop_enable(entity this, entity actor, entity trigger)
{
	this.classname = "info_player_coop";
	this.use = func_null;
}

/*QUAKED info_player_coop(1 0 1)(-16 -16 -24)(16 16 24)
potential spawning position for coop games
*/
spawnfunc(info_player_coop)
{
	if(!coop)
	{
		delete(this);
		return;
	}
	if((this.spawnflags & COOP_SPAWN_START_ACTIVE) || (!this.targetname || this.targetname == ""))
		this.state = COOP_SPAWN_ACTIVE;

	if(this.spawnflags & 1)
	{
		this.classname = "info_player_coop_notyet";
		this.use = coop_enable;
	}
	this.lock = coop_lock;

	IL_PUSH(g_spawnpoints, this);
}

/*
===============================================================================

RULES

===============================================================================
*/

bool is_start_map()
{
	// TODO: allow mappers to define their own start maps
	return (mapname == "start" || mapname == "mgstart" || mapname == "aopstart" || mapname == "hipstart" || mapname == "rstart");
}

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void NextLevel()
{
	cvar_set("_endmatch", "0");
	if(nextmap && nextmap != "")
		return; // already done

	VoteReset(true);

	// TODO: pick the one with the most players
	entity o = find(NULL, classname, "trigger_changelevel");

	// go back to same map if no trigger_changelevel
	if(!o || is_start_map())
	{
		if(!o)
			o = new(trigger_changelevel);
		o.map = mapname;
	}
#if 0
	if(mapname == "start")
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
#endif
	if(world.model == "maps/mgdm1.bsp")
	{
		if(!o)
			o = new(trigger_changelevel);
		o.map = "mgdm2";
	}
	else if(world.model == "maps/mgdm2.bsp")
	{
		if(!o)
			o = new(trigger_changelevel);
		o.map = "mgdm3";
	}
	else if(world.model == "maps/mgdm3.bsp")
	{
		if(!o)
			o = new(trigger_changelevel);
		o.map = "mgdm4";
	}
	else if(world.model == "maps/mgdm4.bsp")
	{
		if(!o)
			o = new(trigger_changelevel);
		o.map = "mgdm1";
	}

	nextmap = o.map;
	gameover = true;

	target_music_kill();

	chat_grabber_CheckClients();

	if(autocvar_sv_eventlog)
		GameLogEcho(":gameover");

	GameLogClose();
	
	if(o && !o.lip)
	{
		o.lip = 1;
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
	if(horde_ent && horde_ent.active)
		return;
	respawn(this);
}

.bool usekeypressed;
void PlayerUseKey(entity this)
{
	if(this.tank)
		Tank_Eject(this, false);
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

	this.disableclientprediction = ((intermission_running) ? 1 : -1);

	this.modelflags &= ~MF_ROCKET; // always do this regardless

	if(this.exptime != 0)
		return;

	if(intermission_running)
	{
		IntermissionThink(this);	// otherwise a button could be missed between
		return;					// the think tics
	}

	if(IS_OBSERVER(this))
	{
		ObserverThink(this);
		return;
	}

	if(this.view_ofs == '0 0 0')
		return;		// intermission or finale

	if(this.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink(this);
		return;
	}

	//JIM
	// Kill player on Edge of Oblivion
	if((this.origin_z < -1300) && (world.model == "maps/hipdm1.bsp") && (this.health > 0))
	{
		if(StatusEffects_active(STATUSEFFECT_Invulnerability, this))
			StatusEffects_remove(STATUSEFFECT_Invulnerability, this, STATUSEFFECT_REMOVE_CLEAR);
		T_Damage(this, this, NULL, this.health + 1000, DEATH_FALL.m_id);
	}

	if(earthquake_active && IS_ONGROUND(this) && !this.tank)
	{
		this.velocity_x = this.velocity_x + (random() * earthquake_intensity * 2) - earthquake_intensity;
		this.velocity_y = this.velocity_y + (random() * earthquake_intensity * 2) - earthquake_intensity;
		this.velocity_z = this.velocity_z + (random() * earthquake_intensity * 2) - earthquake_intensity;
	}

	//makevectors(this.v_angle);		// is this still used
	
	if(this.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if(STAT(FROZEN, this) > time)
		return;

	if(PHYS_INPUT_BUTTON_USE(this) && !this.usekeypressed)
		PlayerUseKey(this);
	this.usekeypressed = PHYS_INPUT_BUTTON_USE(this);

	if(!STAT(SKATING, this) && world.worldtype != WORLDTYPE_SLIDE) // champions handles tank status properly
		champions_PlayerPreThink(this);

	cannon_PlayerPreThink(this);

	dodgeball_PlayerPreThink(this);

// teleporters can force a non-moving pause time	
	if(this.pausetime != -1 && time < this.pausetime)
		this.velocity = '0 0 0';

	if(StatusEffects_active(STATUSEFFECT_Antigrav, this) && time > this.AGping)
	{
		float atime = StatusEffects_gettime(STATUSEFFECT_Antigrav, this);
		_sound(this, CH_TRIGGER_SINGLE, "belt/use.wav", 0.4, ATTN_NORM);
		this.AGping = time + 3;
		if(this.AGping >= (atime - 3))
			this.AGping = atime + 3;
	}

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		Weapon wep = this.(weaponentity).m_weapon;
		if(time > ATTACK_FINISHED(this, weaponentity) && !wep.wr_checkammo1(wep, this, weaponentity))
		{
			ATTACK_FINISHED(this, weaponentity) = time + 0.5;
			W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		}
		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void CheckPowerups(entity this)
{
	dodgeball_PlayerPowerups(this);
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
		float airtime = 12;
		if(this.m_champion && this.m_champion.qcc_breathtime)
			airtime *= this.m_champion.qcc_breathtime;
		this.air_finished = time + airtime;
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
	if(this.tank)
		return;
	if(this.clockwork)
		return;
	if(world.worldtype == WORLDTYPE_DODGEBALL)
		return;

	if(this.healthrot_nextcheck > time)
		return;

	float hp_rot_max = this.max_health;
	if(this.m_champion)
		hp_rot_max *= this.m_champion.qcc_health_rot_max;

	if(this.health > hp_rot_max)
	{
		this.health -= 1;
		this.healthrot_nextcheck = time + 1;
		return;
	}

	this.healthrot_nextcheck = 0;
}

void Regenerate_Health(entity this)
{
	//if(!STAT(SKATING, this))
		//return;
	if(StatusEffects_active(STATUSEFFECT_Poisoned, this))
		return; // no regen while poisoned!!
	if(this.tank)
		return;
	if(this.clockwork)
		return;
	if(world.worldtype == WORLDTYPE_DODGEBALL)
		return;

	float regen_rate = 1;
	float regen_stable = 100;
	float regen_max = 250;
	if(this.m_champion)
	{
		regen_rate *= this.m_champion.qcc_health_regen_rate;
		regen_stable *= this.m_champion.qcc_health_regen_stable;
		regen_max *= this.m_champion.qcc_health_regen_max;
	}

	if(this.health_regen_time < time && this.health < regen_stable)
	{
		float old_health = this.health;
		this.health += 1;
		
		if(this.health > regen_max)
			this.health = regen_max;
		
		if(old_health <= regen_stable && this.health > regen_stable)
			this.health = regen_stable;
	
		this.health_regen_time = time + regen_rate;
	}
}

void Regenerate_Mana(entity this)
{
	float max_mana = 100;
	if(STAT(PASSIVES, this) & PASSIVE_ARCANA)
		max_mana *= 2;

	if(this.mana_regen_time < time && STAT(MANA, this) < max_mana && time > this.mana_regen_pause)
	{
		STAT(MANA, this) = min(STAT(MANA, this) + 3, max_mana);

		float regen_rate = MANA_REGEN_RATE;
		if(time < this.mana_regen_boost)
			regen_rate *= 0.5;
	
		this.mana_regen_time = time + regen_rate;
	}
}

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void xpackEnding(entity this);
.bool dualwielding_prev;
void PlayerPostThink(entity this)
{
	Player_Physics(this);

	if(this.view_ofs == '0 0 0')
	{
		earthquake_postthink(this);
		CSQCMODEL_AUTOUPDATE(this);
		return;		// intermission or finale
	}

	if(world.worldtype == WORLDTYPE_SLIDE)
		Slide_OnThink(this);

	if(this.tank)
		Tank_PlayerPostThink(this);

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
				if (timeleft != this.idlekick_lasttimeleft && IS_REAL_CLIENT(this))
					play2(this, SND(TALK2));
				this.idlekick_lasttimeleft = timeleft;
			}
		}
	}

	if(this.deadflag == DEAD_NO && IS_PLAYER(this))
	{
		if(cutscene_running)
			xpackEnding(this);

		// reset gun alignment when dual wielding status changes
		// to ensure guns are always aligned right and left
		bool dualwielding = W_DualWielding(this);
		if(this.dualwielding_prev != dualwielding)
		{
			W_ResetGunAlign(this, 1);
			this.dualwielding_prev = dualwielding;
		}

		if(this.impulse) // fix imported from rogue, lowers resource usage a tiny bit
			ImpulseCommands(this);

		if(STAT(CANNON, this))
			{ /* do nothing */ }
		else if(this.tank)
			Tank_WeaponFrame(this);
		else
		{
			// do weapon stuff
			for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
			{
				.entity weaponentity = weaponentities[slot];
				W_WeaponFrame(this, weaponentity);
			}
		}

		if(!this.tank && !this.clockwork)
			W_Passives(this);

		if(this.cnt > 0 && !this.button0)
		{
			this.attack_finished = time + 0.8;
			this.cnt = 0;
		}

		// AY 11 Nov 2021, check killspree end
		if(this.killspree > 0 && time > this.killtime)
		{
			//LOG_DEBUG("killspree ended.");

			//score = (this.killspree + (this.killspree - 1) -1) * 5; // previously was "attacker.killspree - 1"
			if(this.killspree > 1)
			{
				float score = ceil((this.killspree * this.killspree) / 2);
				//sprint(this, sprintf("%s lost their kill streak of %d!\n", this.netname, this.killspree));
				this.frags += score;
			}

			this.killspree = 0; // reset killspree
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
		{
			DrownPlayer(this);
			UpdateChatBubble(this);
		}
	}

	if (this.waypointsprite_attachedforcarrier) {
		float hp = this.health;
		WaypointSprite_UpdateHealth(this.waypointsprite_attachedforcarrier, hp);
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

.string music;
string getcdtrack(int numb)
{
	if(world.music)
		return world.music;
	if(IsHipnoticMap())
		return hip_getcdtrack(numb);
	if(IsRogueMap())
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
	if (Ban_MaybeEnforceBanOnce(this)) return;
	make_impure(this);
	this.classname = "player_joining";
	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_JOIN_CONNECT, this.netname);

	this.suicide_delay = time + 5;

	static int playerid_last;
	this.playerid = ++playerid_last;

	entcs_attach(this);

	this.flags |= FL_CLIENT;

	this.netname_previous = strzone(this.netname);

	this.disableclientprediction = -1;

	this.just_joined = true;

	StatusEffectsStorage_attach(this);

	chat_grabber_ClientConnect(this);

	dodgeball_ClientConnect(this);

	if (PlayerInList(this, autocvar_g_chatban_list)) // chatban
		this.muted = true;

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
	/* from "ignore" command */
	strfree(this.ignore_list);
	FOREACH_CLIENT(IS_REAL_CLIENT(it) && it.ignore_list,
	{
		if(it.crypto_idfp && it.crypto_idfp != "")
			continue;
		string mylist = ignore_removefromlist(it, this);
		if(it.ignore_list)
			strunzone(it.ignore_list);

		it.ignore_list = strzone(mylist);
	});
	/* from "ignore" command */
	
	if(gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// yoder oct13, horde fix for dc-ing players
	this.health = 0;

	// let everyone else know
	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_QUIT_DISCONNECT, this.netname, this.frags);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(this.playerid)));
	_sound(this, CH_PLAYER, "player/tornoff2.wav", 1, ATTN_NONE);
	this.effects = 0;

	chat_grabber_ClientDisconnect(this);

	StatusEffectsStorage_delete(this);

	status_effects_ClientDisconnect(this);

	champions_RemovePlayer(this);

	music_RemovePlayer(this);

	Tank_PlayerDie(this);

	dodgeball_RemovePlayer(this);

	sphere_remove(this);

	cannon_clear(this);

	W_Spellbook_ClearSpells(this);

	set_suicide_frame(this);

	strfree(this.weaponorder_byimpulse);
	GetCvars(this, this, -1);
	entcs_detach(this);

	WaypointSprite_PlayerGone(this);

	//this.flags &= ~FL_CLIENT;
	if (this.chatbubbleentity) delete(this.chatbubbleentity);

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
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		int w = player.(weaponentity).m_weapon.m_id;
		if(w == 0)
			w = player.(weaponentity).cnt; // previous weapon
		if(w != 0 || slot == 0)
			s = strcat(s, ftos(w));
	}
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
	targ.death_origin = targ.origin;
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
				if(!Obituary_WeaponDeath(targ, false, deathtype, targ.netname, ""))
					Obituary_SpecialDeath(targ, false, deathtype, targ.netname, "");
				break;
			}
		}

		LogDeath("accident", deathtype, targ, targ);
		targ.frags -= 1;
	}
}

.float spectate_antispam;
void ClientCommand_spectate(entity this)
{
	if(!autocvar_sv_spectate)
	{
		sprint(this, "Spectating is disabled\n");
		return;
	}

	if(IS_OBSERVER(this))
	{
		sprint(this, "You are already spectating\n");
		return;
	}

	if(IS_PLAYER(this))
	{
		if(time > this.spectate_antispam)
		{
			this.spectate_antispam = time + 3;
			Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_QUIT_SPECTATE, this.netname);
		}
		PutObserverInServer(this);
	}
}

REPLICATE_APPLYCHANGE("cl_quake_spectate",
	if(IS_PLAYER(this) && this.cvar_cl_quake_spectate)
		ClientCommand_spectate(this);
);

entity GetIndexedEntity(float argc, float start_index);
float VerifyClientEntity(entity client, float must_be_real, float must_be_bots);
void print_to(entity to, string input);

void ClientCommand_ignore(entity caller, int argc)
{
	// TOOD: proper commands system hanlding
			if (argc >= 2)
			{
				bool advanced = (caller.crypto_idfp && caller.crypto_idfp != "");

				if(!argv(1) || argv(1) == "")
				{
					sprint(caller, "This command requires an argument. Use a player's name or their ID from the ^2status^7 command.\n");
					return;
				}

				entity ignore_to = GetIndexedEntity(argc, 1);
				float ignore_accepted = VerifyClientEntity(ignore_to, true, false);

				if (ignore_accepted > 0 && IS_REAL_CLIENT(ignore_to))   // the target is a real client
				{
					if (ignore_to != caller) // and we're allowed to ignore them heh
					{
						if(ignore_playerinlist(ignore_to, caller))
						{
							sprint(caller, ignore_to.netname, " ^7is already ignored!\n");
							return;
						}

						// advanced ignore mode, works if both the player and the sender have a stats UID
						if(advanced && ignore_to.crypto_idfp && ignore_to.crypto_idfp != "")
						{
							for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
							{
								string pos = db_get(ServerProgsDB, strcat("/ignore/", caller.crypto_idfp, "/", ftos(j)));
								if(pos == "")
								{
									db_put(ServerProgsDB, strcat("/ignore/", caller.crypto_idfp, "/", ftos(j)), ignore_to.crypto_idfp);
									sprint(caller, "You will no longer receive messages from ", ignore_to.netname, "^7, use ^2unignore^7 to hear them again.\n");
									return;
								}
							}

							sprint(caller, "You may only ignore up to ", ftos(IGNORE_MAXPLAYERS), " players, remove one before trying again.\n");
							return;
						}

						if(caller.ignore_list)
							strunzone(caller.ignore_list);
						caller.ignore_list = strzone(cons(caller.ignore_list, ftos(etof(ignore_to))));

						sprint(caller, "You no longer receive messages from ", ignore_to.netname, "^7, use ^2unignore^7 to hear them again.\n");
					}
					else { sprint(caller, "You can't ^2ignore^7 yourself.\n"); }
				}
				else { print_to(caller, "ignore: Unable to ignore this player, check their ID."); }

				return;
			}

		sprint(caller, sprintf("Incorrect parameters for ^2%s^7\n", argv(0)));
}

void ClientCommand_unignore(entity caller, int argc)
{
			if (argc >= 2)
			{
				bool advanced = (caller.crypto_idfp && caller.crypto_idfp != "");

				if(!argv(1) || argv(1) == "")
				{
					sprint(caller, "This command requires an argument. Use a player's name or their ID from the ^2status^7 command.\n");
					return;
				}

				entity unignore_to = GetIndexedEntity(argc, 1);
				float unignore_accepted = VerifyClientEntity(unignore_to, true, false);

				if (unignore_accepted > 0 && IS_REAL_CLIENT(unignore_to))   // the target is a real client
				{
					if (unignore_to != caller)
					{
						string mylist = ignore_removefromlist(caller, unignore_to);
						if(!advanced)
						{
							if(caller.ignore_list)
								strunzone(caller.ignore_list);

							caller.ignore_list = strzone(mylist);
						}

						sprint(caller, "You can now receive messages from ", unignore_to.netname, " ^7again.\n");
						return;
					}
					else { sprint(caller, "You can't ^2unignore^7 yourself.\n"); }
				}
				else {  print_to(caller, "unignore: Unable to stop ignoring this player, check their ID."); }

				return;
			}

		sprint(caller, sprintf("Incorrect parameters for ^2%s^7\n", argv(0)));
}

void exploder_think(entity this)
{
	te_explosion2(this.origin, this.count, this.cnt);
	delete(this);
}

void part_think(entity this)
{
	particle(this.origin, '0 0 0', this.count, this.cnt);
	delete(this);
}

#if 0
void target_spawn_helper_setmodel(entity this)
{
	_setmodel(this, this.model);
}

void target_spawn_helper_setsize(entity this)
{
	setsize(this, this.mins, this.maxs);
}

.void(entity this) target_spawn_spawnfunc;
void target_spawn_edit_entity(entity this, entity e, string msg, entity kt, entity t2, entity t3, entity t4, entity act, entity trigger)
{
	float i, n, valuefieldpos;
	string key, value, valuefield, valueoffset, valueoffsetrandom;
	entity valueent;
	vector data, data2;

	n = tokenize_console(msg);

	for(i = 0; i < n-1; i += 2)
	{
		key = argv(i);
		value = argv(i+1);
		if(key == "$")
		{
			data.x = -1;
			data.y = FIELD_STRING;
		}
		else
		{
			data = stov(db_get(TemporaryDB, strcat("/target_spawn/field/", key)));
			if(data.y == 0) // undefined field, i.e., invalid type
			{
				LOG_INFO("target_spawn: invalid/unknown entity key ", key, " specified, ignored!");
				continue;
			}
		}
		if(substring(value, 0, 1) == "$")
		{
			value = substring(value, 1, strlen(value) - 1);
			if(substring(value, 0, 1) == "$")
			{
				// deferred replacement
				// do nothing
				// useful for creating target_spawns with this!
			}
			else
			{
				// replace me!
				valuefieldpos = strstrofs(value, "+", 0);
				valueoffset = "";
				if(valuefieldpos != -1)
				{
					valueoffset = substring(value, valuefieldpos + 1, strlen(value) - valuefieldpos - 1);
					value = substring(value, 0, valuefieldpos);
				}

				valuefieldpos = strstrofs(valueoffset, "+", 0);
				valueoffsetrandom = "";
				if(valuefieldpos != -1)
				{
					valueoffsetrandom = substring(valueoffset, valuefieldpos + 1, strlen(valueoffset) - valuefieldpos - 1);
					valueoffset = substring(valueoffset, 0, valuefieldpos);
				}

				valuefieldpos = strstrofs(value, ".", 0);
				valuefield = "";
				if(valuefieldpos != -1)
				{
					valuefield = substring(value, valuefieldpos + 1, strlen(value) - valuefieldpos - 1);
					value = substring(value, 0, valuefieldpos);
				}

				if(value == "self")
				{
					valueent = this;
					value = "";
				}
				else if(value == "activator")
				{
					valueent = act;
					value = "";
				}
				else if(value == "other")
				{
					valueent = trigger;
					value = "";
				}
				else if(value == "pusher")
				{
					valueent = NULL;
					value = "";
				}
				else if(value == "target")
				{
					valueent = e;
					value = "";
				}
				else if(value == "killtarget")
				{
					valueent = kt;
					value = "";
				}
				else if(value == "target2")
				{
					valueent = t2;
					value = "";
				}
				else if(value == "target3")
				{
					valueent = t3;
					value = "";
				}
				else if(value == "target4")
				{
					valueent = t4;
					value = "";
				}
				else if(value == "time")
				{
					valueent = NULL;
					value = ftos(time);
				}
				else
				{
					LOG_INFO("target_spawn: invalid/unknown variable replacement ", value, " specified, ignored!");
					continue;
				}

				if(valuefield == "")
				{
					if(value == "")
						value = ftos(etof(valueent));
				}
				else
				{
					if(value != "")
					{
						LOG_INFO("target_spawn: try to get a field of a non-entity, ignored!");
						continue;
					}
					data2 = stov(db_get(TemporaryDB, strcat("/target_spawn/field/", valuefield)));
					if(data2_y == 0) // undefined field, i.e., invalid type
					{
						LOG_INFO("target_spawn: invalid/unknown entity key replacement ", valuefield, " specified, ignored!");
						continue;
					}
					value = getentityfieldstring(data2_x, valueent);
				}

				if(valueoffset != "")
				{
					switch(data.y)
					{
						case FIELD_STRING:
							value = strcat(value, valueoffset);
							break;
						case FIELD_FLOAT:
							value = ftos(stof(value) + stof(valueoffset));
							break;
						case FIELD_VECTOR:
							value = vtos(stov(value) + stov(valueoffset));
							break;
						default:
							LOG_INFO("target_spawn: only string, float and vector fields can do calculations, calculation ignored!");
							break;
					}
				}

				if(valueoffsetrandom != "")
				{
					switch(data.y)
					{
						case FIELD_FLOAT:
							value = ftos(stof(value) + random() * stof(valueoffsetrandom));
							break;
						case FIELD_VECTOR:
							data2 = stov(valueoffsetrandom);
							value = vtos(stov(value) + random() * data2_x * '1 0 0' + random() * data2_y * '0 1 0' + random() * data2_z * '0 0 1');
							break;
						default:
							LOG_INFO("target_spawn: only float and vector fields can do random calculations, calculation ignored!");
							break;
					}
				}
			}
		}
		if(key == "$")
		{
			if(substring(value, 0, 1) == "_")
				value = strcat("target_spawn_helper", value);
			putentityfieldstring(target_spawn_spawnfunc_field, e, value);

			e.target_spawn_spawnfunc(e);

			// We called an external function, so we have to re-tokenize msg.
			n = tokenize_console(msg);
		}
		else
		{
			if(data.y == FIELD_VECTOR)
				value = strreplace("'", "", value); // why?!?
			putentityfieldstring(data.x, e, value);
		}
	}
}
#endif

bool ping_waypointsprite_visible_for_player(entity this, entity player, entity view)
{
	return (this.realowner == player);
}

int Say(entity source, int teamsay, entity privatesay, string msgin, bool floodcontrol);
void NoclipCheat(entity this);
void GodCheat(entity this);
void NotargetCheat(entity this);
void GiveCheat(entity this, string input);
.entity waypointsprite_attachedforping;
void SV_ParseClientCommand(entity this, string command)
{
	// If invalid UTF-8, don't even parse it
	string command2 = "";
	float len = strlen(command);
	float i;
	for (i = 0; i < len; ++i)
		command2 = strcat(command2, chr2str(str2chr(command, i)));
	if (command != command2) return;

	// if we're banned, don't even parse the command
	if (Ban_MaybeEnforceBanOnce(this)) return;

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
		case "say": case "say_team": case "tell": break;   // chat has its own flood control in chat.qc
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

	if(cmd_name == "give")
	{
		GiveCheat(this, argv(1));
		return;
	}

	if(cmd_name == "god")
	{
		GodCheat(this);
		return;
	}

	if(cmd_name == "notarget")
	{
		NotargetCheat(this);
		return;
	}

	if(cmd_name == "ignore")
	{
		ClientCommand_ignore(this, argc);
		return;
	}

	if(cmd_name == "unignore")
	{
		ClientCommand_unignore(this, argc);
		return;
	}

	if(cmd_name == "vote")
	{
		VoteCommand(CMD_REQUEST_COMMAND, this, argc, command);
		return;
	}

	if(cmd_name == "autoswitch")
	{
		if (argv(1) != "")
		{
			this.cvar_cl_autoswitch = InterpretBoolean(argv(1));
			sprint(this, strcat("^1autoswitch is currently turned ", (this.cvar_cl_autoswitch ? "on" : "off"), ".\n"));
			return;
		}
		LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		return;
	}

	if(cmd_name == "spectate")
	{
		//ClientCommand_spectate(this);
		stuffcmd(this, "\ncl_quake_spectate 1\n");
		return;
	}

	if(cmd_name == "tracer")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		makevectors(this.v_angle);
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 300, MOVE_NORMAL, this);
		sprint(this, strcat("Texture: ", trace_dphittexturename, "\n"));
		sprint(this, strcat("Texture flag: ", ftos(trace_dphitq3surfaceflags), "\n"));
		sprint(this, sprintf("Entity: %s (%d)\n", trace_ent.classname, etof(trace_ent)));
		return;
	}

	if(cmd_name == "explosion2")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		makevectors(this.v_angle);
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 100, MOVE_NORMAL, this);
		entity exploder = new(exploder);
		setthink(exploder, exploder_think);
		exploder.count = stof(argv(1));
		exploder.cnt = stof(argv(2));
		exploder.nextthink = time + 0.5; // give them enough time to close the console!
		setorigin(exploder, trace_endpos);
		return;
	}

	if(cmd_name == "particle")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		makevectors(this.v_angle);
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 100, MOVE_NORMAL, this);
		entity part = new(particle);
		setthink(part, part_think);
		part.count = stof(argv(1));
		part.cnt = stof(argv(2));
		part.nextthink = time + 0.5; // give them enough time to close the console!
		setorigin(part, trace_endpos);
		return;
	}

	if(cmd_name == "addent")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		initialize_field_db();
		makevectors(this.v_angle);
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 150, MOVE_NORMAL, this);
		entity e = spawn();
		e.spawnfunc_checked = true;
		setorigin(e, trace_endpos);
		e.angles = this.angles;
	#if 0
		string themsg = strcat(substring(command, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)));
		target_spawn_edit_entity(this, e, themsg, NULL, NULL, NULL, NULL, this, this);
	#else
		string themsg = strcat(argv(1));
		if(themsg != "")
		{
			string value = strcat("spawnfunc_", themsg);
			if(substring(value, 0, 1) == "_")
				value = strcat("target_spawn_helper", value);
			putentityfieldstring(target_spawn_spawnfunc_field, e, value);

			if(e.target_spawn_spawnfunc)
			{
				setthink(e, e.target_spawn_spawnfunc);
				e.nextthink = time;
			}
			else
				delete(e);
		}
	#endif
		if(e)
			sprint(this, strcat("Created entity ", etos(e), "\n"));
		return;
	}

	if(cmd_name == "addmob" || cmd_name == "addmob2")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		makevectors(this.v_angle);
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 150, MOVE_NORMAL, this);
		string arg = argv(1);
		Monster mon = MON_Null;
		if(arg != "")
		{
			FOREACH(Monsters, it.netname == arg,
			{
				mon = it;
				break;
			});
		}
		horn_spawnmonster(trace_endpos, ((cmd_name == "addmob2") ? NULL : this), mon);
		return;
	}

	if(cmd_name == "effect")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		makevectors(this.v_angle);
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 150, MOVE_NORMAL, this);
		__pointparticles(_particleeffectnum(argv(1)), trace_endpos, '0 0 0', 1);
		return;
	}

	if(cmd_name == "pingents")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		IL_EACH(g_moveables, it.pure_data == 0,
		{
			entity e = WaypointSprite_Spawn(WP_Entity, 10, 0, NULL, (it.absmin + it.absmax) * 0.5, NULL, 0, it, waypointsprite_attachedforping, false, NULL);
			e.realowner = this;
			e.wp_extra = num_for_edict(it);
			e.waypointsprite_visible_for_player = ping_waypointsprite_visible_for_player;
		});
		return;
	}

	if(cmd_name == "pingent")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;

		entity foundent = ftoe(stof(argv(1)));
		if(!foundent)
		{
			sprint(this, "Need to provide an entity number\n");
			return;
		}

		entity e = WaypointSprite_Spawn(WP_Entity, 10, 0, NULL, (foundent.absmin + foundent.absmax) * 0.5, NULL, 0, foundent, waypointsprite_attachedforping, false, NULL);
		e.realowner = this;
		e.wp_extra = num_for_edict(foundent);
		e.waypointsprite_visible_for_player = ping_waypointsprite_visible_for_player;
		return;
	}

	if(cmd_name == "pingpos")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;

		vector thepos = stov(argv(1));
		if(thepos == '0 0 0')
		{
			sprint(this, "Gotta provide a position in quotes\n");
			return;
		}

		entity e = WaypointSprite_Spawn(WP_Waypoint, 20, 0, NULL, thepos, NULL, 0, NULL, waypointsprite_attachedforping, false, NULL);
		e.realowner = this;
		e.waypointsprite_visible_for_player = ping_waypointsprite_visible_for_player;
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

	if(cmd_name == "editor")
	{
		if(!autocvar_sv_cheats && !this.maycheat)
			return;
		if(sv_editor_command(this, cmd_name, argc))
			return;
	}

	if(sv_shop_command(this, cmd_name, argc))
		return;

	if(sv_music_command(this, cmd_name, argc))
		return;

	clientcommand(this, command);
}

void setcolor(entity this, int clr)
{
#if 1
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
