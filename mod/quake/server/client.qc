#include "combat.qh"

// prototypes
void W_WeaponFrame(entity this);
void W_SetCurrentAmmo(entity this);
void player_pain(entity this, entity attacker, float damage);
void player_stand1(entity this);
void spawn_tfog(vector org);
void spawn_tdeath(vector org, entity death_owner);

void(entity targ, entity attacker) dmatch_score;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float intermission_exittime;

/*QUAKED info_intermission(1 0.5 0.5)(-16 -16 -16)(16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
spawnfunc(info_intermission)
{
}

void SetChangeParms(entity this)
{
	if(this.health <= 0)
	{
		SetNewParms();
		parm14 = this.steam; // Save the current team of the player
		return;
	}

// remove items
	this.items &= ~(IT_KEY1 | IT_KEY2);
	this.items &= ~IT_SUPERHEALTH; // rogue
	this.gravity = 1.0;

	this.health = bound(50, this.health, 100); // cap super health
	if(teamplay >= TEAM_CTF) // don't carry items between level in CTF
		SetNewParms();
	else
	{
		parm1 = this.weapons;
		parm2 = this.health;
		parm3 = this.armorvalue;
		parm4 = max(25, this.ammo_shells);
		parm5 = this.ammo_nails;
		parm6 = this.ammo_rockets;
		parm7 = this.ammo_cells;
		parm8 = this.weapon;
		parm9 = this.armortype * 100;
		//parm10 = this.items2;
		parm10 = this.model_randomizer;
		parm11 = this.ammo_lava_nails;
		parm12 = this.ammo_multi_rockets;
		parm13 = this.ammo_plasma;
		parm15 = this.prevweapon;
		parm16 = this.items;
	}
	parm14 = this.steam; // save team setting
}

void SetNewParms()
{
	if(deathmatch && teamplay >= TEAM_CTF)
	{
		parm1 = WEP_SHOTGUN | WEP_AXE | WEP_GRAPPLE;
		parm3 = 50;
		parm9 = 30;
		parm16 = IT_ARMOR1;
	}
	else
	{
		parm1 = WEP_SHOTGUN | WEP_AXE;
		parm3 = 0;
		parm9 = 0;
		parm16 = 0;
	}
	parm2 = 100;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = WEP_SHOTGUN;
	parm10 = random();
	parm11 = 0;
	parm12 = 0;
	parm13 = 0;
	parm14 = -1; // CTF: reset current team selection
	parm15 = WEP_AXE; // always use axe as the alternate weapon
}

bool TeamColorIsLegal(int thecolor);
void TeamSetSkin(entity this);
void DecodeLevelParms(entity this)
{
	if(serverflags)
	{
		if(world.model == "maps/start.bsp" || world.model == "maps/aopstart.bsp")
			SetNewParms();		// take away all stuff on starting new episode
	}

	if(world.model == "maps/hipstart.bsp"
	|| world.model == "maps/hip1m1.bsp"
	|| world.model == "maps/hip2m1.bsp"
	|| world.model == "maps/hip3m1.bsp"
	) SetNewParms(); // take away all stuff on starting new episode

	if(world.model == "maps/rstart.bsp" || ((world.model == "maps/r2m1.bsp" || world.model == "maps/aop2m1.bsp") && !deathmatch))
		SetNewParms(); // reset all stuff on level 8 and new episode

	//if(deathmatch && teamplay >= TEAM_CTF)
		//SetNewParms(); // engine doesn't do this for us, apparently
	
	this.weapons = parm1;
	this.health = parm2;
	this.armorvalue = parm3;
	this.ammo_shells = parm4;
	this.ammo_nails = parm5;
	this.ammo_rockets = parm6;
	this.ammo_cells = parm7;
	if(parm8 == WEP_GRAPPLE && teamplay < TEAM_CTF)
		this.weapon = WEP_AXE;
	else
		this.weapon = parm8;
	this.armortype = parm9 * 0.01;
	this.model_randomizer = parm10;
	//this.items2 = parm10;
	this.ammo_lava_nails = parm11;
	this.ammo_multi_rockets = parm12;
	this.ammo_plasma = parm13;
	if(TeamColorIsLegal(parm14))
	{
		this.steam = parm14;
		TeamSetSkin(this);
	}

	this.prevweapon = parm15;
	this.items = parm16;
	this.powerups = 0;
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

bool have_katria;
bool have_mario;
STATIC_INIT(check_katria)
{
	have_katria = fexists("progs/player_katria.mdl");
	have_mario = fexists("progs/player_mario.mdl");
}

string get_playermodel(entity this)
{
	if(have_mario && autocvar_sv_allow_customplayermodels_speciallist != "")
	{
		if(PlayerInList(this, autocvar_sv_allow_customplayermodels_speciallist))
			return "progs/player_mario.mdl";
	}
	if(this.model_randomizer < autocvar_sv_quake_katria && have_katria)
		return "progs/player_katria.mdl";
	return "progs/player.mdl";
}

string get_playerhead(entity this)
{
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
	if(have_mario && autocvar_sv_allow_customplayermodels_speciallist != "" && PlayerInList(this, autocvar_sv_allow_customplayermodels_speciallist))
		soundpath = "player_mario/";
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
		changelevel(nextmap);
}

string getcdtrack(int numb);
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

void server_reset();
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
			WriteString(MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herthis in her frightful\notherworld cathedral.");
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

		GotoNextMap();
	}
	
	if(intermission_running == 3)
	{
		if(!autocvar_registered)
		{	// shareware episode has been completed, go to sell screen
			WriteByte(MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if((serverflags&15) == 15)
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

float autocvar_sv_quake_autoreset;
void server_delayed_reset(entity this)
{
	if(deathmatch)
		return; // don't wanna do a hard reset in these cases

	// kicks everyone and resets the server!
	string themap = "start";
	if(MP_HIPNOTIC)
		themap = "hipstart";
	else if(MP_ROGUE)
		themap = "rstart";
	else if(MP_IMPEL)
		themap = "aopstart";

	localcmd("\nmap ", themap, "\n");
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
	WriteByte(MSG_ALL, ((MP_HIPNOTIC) ? 9 : 3));
	WriteByte(MSG_ALL, 3);
#else
	SendCDTrack(NULL, 3);
#endif

	entity pos = FindIntermission(this);

	if(pos)
	{
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			it.view_ofs = '0 0 0';
			it.angles = it.v_angle = pos.mangle;
			it.fixangle = true;		// turn this way immediately
			it.nextthink = time + 0.5;
			it.takedamage = DAMAGE_NO;
			it.solid = SOLID_NOT;
			it.flags |= FL_NOTARGET; // fix a silly monster bug
			//it.health = -2342; // can't do this because of parms
			set_movetype(it, MOVETYPE_NONE);
			//it.modelindex = 0;
			setmodel(it, MDL_Null);
			setorigin(it, pos.origin);
		});
	}

	WriteByte(MSG_ALL, SVC_INTERMISSION);
}


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void set_suicide_frame(entity this);

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void CopyToBodyQue(entity ent)
{
	entity body = new(bodyque);
	body.angles = ent.angles;
	body.model = ent.model;
	body.modelindex = ent.modelindex;
	body.frame = ent.frame;
	body.colormap = ent.colormap;
	set_movetype(body, ent.move_movetype);
	body.velocity = ent.velocity;
	body.move_qcphysics = false; // not for clones
	body.flags = 0;
	if(MP_ROGUE)
		body.skin = ent.skin;
	setorigin(body, ent.origin);
	setsize(body, ent.mins, ent.maxs);

	if(coop)
	{
		setthink(body, SUB_Remove);
		body.nextthink = time + 10;
	}
}

// called by ClientKill and DeadThink
void respawn(entity this)
{
	if(coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue(this);
		// get the spawn parms as they were at level start
		setspawnparms(this);
		// respawn		
		PutClientInServer(this);
	}
	else if(deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue(this);
		// set default spawn parms
		SetNewParms();
		// respawn		
		PutClientInServer(this);
		if(MP_ROGUE)
		{
			// set the skin correctly
			TeamSetSkin(this);
		}
	}
	else
	{	// restart the entire server
		localcmd("restart\n");
	}
}


/*
============
ClientKill

Player entered the suicide command
============
*/
void TeamDropFlagOfPlayer(entity player);
void tag_token_drop();
void ClientKill(entity this)
{
	if(MP_ROGUE)
	{
		if(this.suicide_count > 3)
		{
			sprint(this, "You have suicide too much already... Get help.\n");
			return;
		}
		TeamDropFlagOfPlayer(this);
		this.suicide_count += 1;

		if(tag_token_owner == this)
		{
			this.health = 0;
			this.solid = SOLID_NOT;
			tag_token_drop();
		}

		if(this.powerups & POWERUP_V_SPHERE)
		{
			FOREACH_ENTITY_CLASS("Vengeance", it.owner == this,
			{
				delete(it);
			});
		}
	}

	bprintf("%s suicides\n", this.netname);
	set_suicide_frame(this);
	this.modelindex = this.modelindex_player;
	this.frags = this.frags - 2;	// extra penalty
	respawn(this);
}

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity SelectSpawnPoint(entity this)
{
// testinfo_player_start is only found in regioned levels
	entity spot = find(NULL, classname, "testplayerstart");
	if(spot)
		return spot;
		
// choose a info_player_deathmatch point
	if(coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if(lastspawn == NULL)
			lastspawn = find(lastspawn, classname, "info_player_start");
		if(lastspawn != NULL)
			return lastspawn;
	}
	else if(deathmatch)
	{
		entity startspot = spot = lastspawn;
		int t = 0;
		if(MP_ROGUE && !this.ctf_killed && teamplay >= TEAM_CTF)
		{
			if(this.steam == TEAM1)
			{
				startspot = spot = team1_lastspawn;
				t = TEAM1;
			}
			else if(this.steam == TEAM2)
			{
				startspot = spot = team2_lastspawn;
				t = TEAM2;
			}
		}
		while(1)
		{
			if(MP_ROGUE && t == TEAM1)
				spot = find(spot, classname, "info_player_team1");
			else if(MP_ROGUE && t == TEAM2)
				spot = find(spot, classname, "info_player_team2");
			else
				spot = find(spot, classname, "info_player_deathmatch");
			if(spot != NULL)
			{
				if(MP_ROGUE)
				{
					if(spot == startspot)
						return startspot;
				}
				else
				{
					if(spot == lastspawn)
						return lastspawn;
				}
				int pcount = 0;
				entity thing = findradius(spot.origin, 32);
				while(thing)
				{
					if(IS_PLAYER(thing))
						pcount = pcount + 1;
					thing = thing.chain;
				}
				if(pcount == 0)
				{
					if(MP_ROGUE && t == TEAM1)
						team1_lastspawn = spot;
					else if(MP_ROGUE && t == TEAM2)
						team2_lastspawn = spot;
					else
						lastspawn = spot;
					return spot;
				}
			}
			else if(MP_ROGUE)
				t = 0; // fix for ctf levels without ctf support
		}
	}

	if(serverflags)
	{	// return with a rune to start
		spot = find(NULL, classname, "info_player_start2");
		if(spot)
			return spot;
	}
	
	spot = find(NULL, classname, "info_player_start");
	if(!spot)
	{
		if(MP_IMPEL)
		{
			if(!deathmatch)
				spot = find(NULL, classname, "info_player_deathmatch");
			if(!spot)
				error("PutClientInServer: no info_player_start/deathmatch on level");
		}
		else
			error("PutClientInServer: no info_player_start on level");
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
void PlayerDie(entity this, entity inflictor, entity attacker);
void player_touch(entity this, entity toucher);

void PutClientInServer(entity this)
{
	this.classname = STR_PLAYER;
	this.health = 100;
	this.takedamage = DAMAGE_AIM;
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_WALK);
	this.show_hostile = 0;
	this.max_health = 100;
	this.flags = FL_CLIENT;
	this.air_finished = time + 12;
	this.dmg = 2;   		// initial water damage
	this.super_damage_finished = 0;
	this.radsuit_finished = 0;
	this.invisible_finished = 0;
	this.invincible_finished = 0;
	this.field_generator_finished = 0;
	this.effects = EF_TELEPORT_BIT;
	this.invincible_time = 0;

	// hipnotic fields
	this.wetsuit_finished = 0;
	this.empathy_finished = 0;
	this.gravity = 1.0;
	this.gorging = false;

	// rogue fields
	this.shield_finished = 0;
	this.antigrav_finished = 0;
	this.ctf_lastreturnedflag = -10;
	this.ctf_lastfraggedcarrier = -10;
	this.ctf_flagsince = -10;
	this.ctf_lasthurtcarrier = -10;

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	this.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID;
	if (autocvar_g_playerclip_collisions)
		this.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;

	DecodeLevelParms(this);

	entity spot = SelectSpawnPoint(this);

	W_SetCurrentAmmo(this);

	this.attack_finished = time;
	this.attack2_finished = time;
	this.th_pain = player_pain;
	this.th_die = PlayerDie;
	
	this.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	this.pausetime = 0;
	
//	spot = SelectSpawnPoint();

	this.origin = spot.origin + '0 0 1';
	this.angles = vec2(spot.angles);
	this.fixangle = true;		// turn this way immediately

	if(MP_ROGUE)
		settouch(this, player_touch);

	//JIM
	// Clear out velocity so you're not launched into the air
	// when you respawn.
	this.velocity = '0 0 0';

// oh, this is a hack!
	if(MP_HIPNOTIC)
	{
		_setmodel(this, "progs/playham.mdl");
		modelindex_hammer = this.modelindex;
	}
	_setmodel(this, "progs/eyes.mdl");
	modelindex_eyes = this.modelindex;

	_setmodel(this, "progs/bolt2.mdl");
	modelindex_bolt = this.modelindex;

	_setmodel(this, get_playermodel(this));
	this.modelindex_player = this.modelindex;

	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	
	this.view_ofs = '0 0 22';

	player_stand1(this);
	
	if(deathmatch || coop)
	{
		makevectors(this.angles);
		spawn_tfog(this.origin + v_forward * 20);
	}

	this.on_hook = false;
	this.hook_out = false;

	spawn_tdeath(this.origin, this);
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


/*
saved out by quaked in region mode
*/
spawnfunc(testplayerstart)
{
}

/*QUAKED info_player_deathmatch(1 0 1)(-16 -16 -24)(16 16 24)
potential spawning position for deathmatch games
*/
void SpawnRunes(entity this);
spawnfunc(info_player_deathmatch)
{
	if(MP_ROGUE)
		SpawnRunes(this);
}

/*QUAKED info_player_coop(1 0 1)(-16 -16 -24)(16 16 24)
potential spawning position for coop games
*/
spawnfunc(info_player_coop)
{
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
	entity o = NULL;

	if(MP_IMPEL)
	{
	// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if(!o)
		{
			mapname = "aopstart";
			o = spawn();
			o.map = mapname;
		}
	}
	else if(MP_HIPNOTIC)
	{
		// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if(!o)
		{
			mapname = "hipstart";
			o = spawn();
			o.map = mapname;
		}
	}
	else if(MP_ROGUE)
	{
		if(mapname == "start" || mapname == "rstart" || mapname == "hipstart" || mapname == "aopstart")
		{
			mapname = "r1m1";

			o = spawn();
			o.map = mapname;
		}
		else
		{
			// find a trigger changelevel
			o = find(NULL, classname, "trigger_changelevel");

			// go back to start if no trigger_changelevel
			if(!o)
			{
				mapname = "rstart";
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
	else
	{
		// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if(!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = true;
	
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
	if(MP_IMPEL)
	{
		if(this.impaled)
			return;
		this.impaled = false;
	}

	this.button0 = 0;
	this.button1 = 0;
	this.button2 = 0;
	this.button3 = 0;
	respawn(this);
}


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void DeathBubbles(entity this, int num_bubbles);
void TeamCheckLock(entity this);
void CheckMOTD(entity this);
void RuneApplyElder(entity who);
void GrappleService(entity this);
void GameLogEcho(string s);
void impel_MOTD(entity this);

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

	if(MP_IMPEL && this.exptime != 0)
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
	if(MP_HIPNOTIC)
	if((this.origin_z < -1300) && (world.model == "maps/hipdm1.bsp") && (this.health > 0))
	{
		this.deathtype = "falling";

		if (this.invincible_finished >= time)
		{
			this.invincible_finished = 0;
			this.powerups &= ~POWERUP_INVULNERABILITY;
			this.invincible_time = 0;
			this.invincible_finished = 0;
			this.effects &= ~EF_DIMLIGHT;
		}
		T_Damage(this, this, world, this.health + 1000);
	}

	if(MP_ROGUE && earthquake_active && IS_ONGROUND(this))
	{
		this.velocity_x = this.velocity_x + (random() * earthquake_intensity * 2) - earthquake_intensity;
		this.velocity_y = this.velocity_y + (random() * earthquake_intensity * 2) - earthquake_intensity;
		this.velocity_z = this.velocity_z + (random() * earthquake_intensity * 2) - earthquake_intensity;
	}

	if(MP_IMPEL && this.motd_time && this.motd_time < time && OPT_MOTD)
		impel_MOTD(this);

	//makevectors(this.v_angle);		// is this still used

	if(MP_ROGUE)
	{
		TeamCheckLock(this);

		CheckMOTD(this);
	}

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

	if(MP_ROGUE)
	{
		if((this.powerups & POWERUP_ANTIGRAV) && time > this.AGping)
		{
			_sound(this, CH_TRIGGER_SINGLE, "belt/use.wav", 0.4, ATTN_NORM);
			this.AGping = time + 3;
			if(this.AGping >= (this.antigrav_finished - 3))
				this.AGping = this.antigrav_finished + 3;
		}

		RuneApplyElder(this); // regen rune

		if(this.hook_out)
			GrappleService(this);
	}

	if(!MP_ROGUE)
	if(time > this.attack_finished && this.currentammo == 0 && this.weapon != WEP_AXE && this.weapon != WEP_MJOLNIR)
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
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
				sprint(this, "Ring of Shadows magic is fading\n");
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
	else if(this.weapon == WEP_MJOLNIR)
		this.modelindex = modelindex_hammer; // don't use eyes
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
				sprint(this, "Protection is almost burned out\n");
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
				sprint(this, "Quad Damage is wearing off\n");
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
	if(MP_IMPEL)
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
				sprint(this, "Air supply in Biosuit expiring\n");
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
	if(MP_HIPNOTIC && this.wetsuit_finished)
	{
		this.air_finished = time + 12;		// don't drown

	// sound and screen flash when items starts to run out
		if(this.wetsuit_finished < time + 3)
		{
			if(this.wetsuit_time == 1)
			{
				sprint(this, "Air supply in Wetsuit is running out\n");
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
	if(MP_HIPNOTIC && this.empathy_finished)
	{
		// sound and screen flash when items starts to run out
		if(this.empathy_finished < time + 3)
		{
			if(this.empathy_time == 1)
			{
				sprint(this, "Empathy Shields are running out\n");
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
				sprint(this, "Shield failing...\n");
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
				sprint(this, "Antigrav failing...\n");
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
			sprint(this, "Antigrav Lost.\n");
			this.antigrav_finished = 0;
			this.powerups &= ~POWERUP_ANTIGRAV;
			this.gravity = 1.0;
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
			T_Damage(this, NULL, NULL, this.dmg);
			this.pain_finished = time + 1;
		}
	}
}

void Player_Physics(entity this)
{
	set_movetype(this, this.move_movetype);

	if(!this.move_qcphysics)
		return;

	if(!frametime && !this.pm_frametime)
		return;

	Movetype_Physics_NoMatchTicrate(this, this.pm_frametime, true);

	this.pm_frametime = 0;
}


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void xpackEnding(entity this);
void PlayerPostThink(entity this)
{
	Player_Physics(this);

	if(this.view_ofs == '0 0 0')
	{
		if(MP_HIPNOTIC)
			earthquake_postthink(this);
		CSQCMODEL_AUTOUPDATE(this);
		return;		// intermission or finale
	}

	if(MP_HIPNOTIC)
		earthquake_postthink(this); // !deathmatch?

	if(this.deadflag == DEAD_NO)
	{
		if(MP_ROGUE && cutscene_running)
			xpackEnding(this);

		// do weapon stuff
		W_WeaponFrame(this);

		if(MP_IMPEL && this.cnt > 0 && !this.button0)
		{
			this.attack_finished = time + 0.8;
			this.cnt = 0;
		}

		if(MP_IMPEL && this.rifle_cnt > 0 && !this.button3)
		{
			this.attack_finished = time + 0.8;
			this.rifle_cnt = 0;
		}

		CheckPowerups(this);
	}

	if(IS_PLAYER(this))
		DrownPlayer(this);

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
void SetMOTD(entity this);
void ClientConnect(entity this)
{
	if(MP_IMPEL)
	{
		bprintf("%s enters the Abyss!\n", this.netname);
		if(OPT_MOTD)
		{
			this.motd_time = time + 3;
			this.motd_count = 0;
		}
	}
	else
		bprintf("%s entered the game\n", this.netname);

	this.suicide_count = 0;
	this.ctf_killed = 0;

	if(MP_ROGUE)
		SetMOTD(this);

	// if this is our first connection, parm14 is < 0
	// set lastteam negative
	// NOTE: parm14 is NOT < 0 here, spawn parameters are not adjusted on connect!
	if(MP_ROGUE && parm14 <= 0 && teamplay > 0)
	{
		if(cvar("gamecfg") & GAMECFG_USE_COLOR)
			this.steam = this.team; // accept joining player's color if legal
		else
			this.steam = -50; // always reassign
		TeamCheckLock(this);
	}

	static int playerid_last;
	this.playerid = ++playerid_last;

	this.flags |= FL_CLIENT;

	this.netname_previous = strzone(this.netname);

	this.disableclientprediction = -1;

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
void sphere_remove(entity this);
void ClientDisconnect(entity this)
{
	if(gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprintf("%s left the %s with %d frags\n", this.netname, ((MP_IMPEL) ? "Abyss" : "game"), this.frags);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(this.playerid)));
	_sound(this, CH_PLAYER, "player/tornoff2.wav", 1, ATTN_NONE);

	if(MP_ROGUE)
	{
		sphere_remove(this);
		if(tag_token_owner == this)
			tag_token_drop();

		TeamDropFlagOfPlayer(this);
		this.steam = -50;
		this.team = 0;
	}
	set_suicide_frame(this);
}

/*
===========
ClientObituary

called when a player dies
============
*/
void TeamResetCarrier(entity who);
void TeamAssists(entity targ, entity attacker);
void ClientObituary(entity targ, entity inflictor, entity attacker)
{
	string deathstring = "", deathstring2 = "";
	float rnum = random();

	if(IS_PLAYER(targ))
	{
		if(MP_ROGUE)
			TeamResetCarrier(targ);

		if(attacker.classname == "teledeath")
		{
			bprintf("%s was telefragged by %s\n", targ.netname, attacker.owner.netname);

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if(attacker.classname == "teledeath2")
		{
			bprintf("Satan's power deflects %s's telefrag\n", targ.netname);

			targ.frags = targ.frags - 1;
			return;
		}

		if(IS_PLAYER(attacker))
		{
			if(targ == attacker)
			{
				// killed this
				attacker.frags = attacker.frags - 1;
				bprint(targ.netname);
				
				if(targ.weapon == 64 && targ.waterlevel > 1)
				{
					bprint(" discharges into the water.\n");
					return;
				}
				if(MP_IMPEL)
				{
					if(inflictor == attacker && targ.weapon == WEP_LIGHTME && targ.waterlevel > 1)
					{
						bprint(" screwed up AGAIN with the LG-2.\n");
						return;
					}
					if(targ.weapon == WEP_LIGHTME)
					{
						bprint(" screwed up with the LG-2 Prototype.\n");
						return;
					}
					if(inflictor == attacker && targ.weapon == WEP_LIGHTME && targ.waterlevel > 1)
					{
						bprint(" discharges into the water.\n");
						return;
					}
					if(inflictor.classname == "grenade")
						bprint(" tries to put the pin back in!\n");
					else if(inflictor.classname == "flame")
						bprint(" went up in his own flames!\n");
					else
						bprint(" got bored with life.\n");
					return;
				}
				else if(targ.weapon == WEP_GRENADE_LAUNCHER)
					bprint(" tries to put the pin back in\n");
				else if(MP_HIPNOTIC)
				{
					if(rnum > 0.4)
						bprint(" becomes bored with life\n");
					else
						bprint(" checks if their weapon is loaded\n");
				}
				else if(MP_ROGUE && teamplay && targ.team != targ.steam)
				{
					if(cvar("gamecfg") & GAMECFG_ALLOW_CHG)
						bprint(" changed teams\n");
					else
						bprint(" tried to change teams\n");
				}
				else
					bprint(" becomes bored with life\n");
				return;
			}
			else if((teamplay == 2) &&(targ.team > 0)&&(targ.team == attacker.team) )
			{
				// NOTE: impel adds punctuation here, couldn't be bothered sorry!
				if(rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if(rnum < 0.50)
					deathstring = " checks their glasses\n";
				else if(rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint(attacker.netname);
				bprint(deathstring);
				attacker.frags = attacker.frags - 1;
				return;
			}
			else
			{
				if(MP_ROGUE && teamplay == TEAM_DMATCH_TAG)
					dmatch_score(targ, attacker);
				else
				{
					attacker.frags = attacker.frags + 1;
					if(MP_ROGUE)
						TeamAssists(targ, attacker);
				}

				//MED 01/19/97
				if(empathyused == 1)
				{
					bprint(targ.netname);
					if (random() < 0.5)
						bprint(" shares ");
					else
						bprint(" feels ");
					bprint(attacker.netname);
					bprint("'s pain\n");
					return;
				}

//MED 11/18/96
				if(targ.dmg_inflictor.classname == "proximity_grenade")
				{
					bprint(targ.netname);
					if(random() < 0.5)
						bprint(" got too friendly with ");
					else
						bprint(" did the rhumba with ");
					bprint(attacker.netname);
					bprint("'s bomb\n");
					return;
				}

				rnum = attacker.weapon;
				if(rnum == WEP_AXE && (!MP_IMPEL || inflictor == attacker))
				{
					if(MP_IMPEL)
					{
						deathstring = " was hacked up by ";
						deathstring2 = "!\n";
					}
					else
					{
						deathstring = " was ax-murdered by ";
						deathstring2 = "\n";
					}
				}
				if(rnum == WEP_GRAPPLE)
				{
					deathstring = " was grappled by ";
					deathstring2 = "\n";
				}
				if(rnum == WEP_SHOTGUN && (!MP_IMPEL || inflictor == attacker))
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				if(rnum == WEP_SUPER_SHOTGUN && (!MP_IMPEL || inflictor == attacker))
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				if(rnum == WEP_NAILGUN || (MP_IMPEL && inflictor.classname == "spike"))
				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				if(rnum == WEP_SUPER_NAILGUN || (MP_IMPEL && inflictor.classname == "superspike"))
				{
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				if(rnum == WEP_GRENADE_LAUNCHER || (MP_IMPEL && inflictor.classname == "grenade"))
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if(targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				if(rnum == WEP_ROCKET_LAUNCHER || (MP_IMPEL && inflictor.classname == "missile"))
				{
					deathstring = " rides ";
					deathstring2 = "'s rocket\n";
					if(targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s rocket\n" ;
					}
				}
				if(rnum == WEP_LIGHTNING && (!MP_IMPEL || inflictor == attacker))
				{
					deathstring = " accepts ";
					if(attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
				if(rnum == WEP_LASER_CANNON)
				{
					if(random() < 0.5)
						deathstring = " was toasted by ";
					else
						deathstring = " was radiated by ";
					deathstring2 = "'s laser\n";
				}
				if(rnum == WEP_MJOLNIR)
				{
					deathstring = " was slammed by ";
					deathstring2 = "'s hammer\n";
				}
				if(rnum == WEP_LAVA_NAILGUN || rnum == WEP_LAVA_SUPER_NAILGUN)
				{
					deathstring = " was burned by ";
					deathstring2 = "\n";
				}
				if(rnum == WEP_PLASMA_GUN)
				{
					deathstring = " was fused by ";
					deathstring2 = "\n";
				}
				if(rnum == WEP_MULTI_GRENADE || rnum == WEP_MULTI_ROCKET)
				{
					deathstring = " was blasted to bits by ";
					deathstring2 = "\n";
				}
				if(rnum == WEP_LIGHTME)
				{
					if(attacker.waterlevel > 1)
					{
						deathstring = " accepts ";
						deathstring2 = "'s shock beam!\n";
					}
					else
					{
						deathstring = " was killed by ";
						deathstring2 = "'s shock beam!\n";
					}
				}
				if(inflictor.classname == "flame")
				{
					deathstring = " was flamed by ";
					deathstring2 = "!\n";
				}
				if(inflictor.classname == "pulse")
				{
					deathstring = " was zapped by ";
					deathstring2 = "!\n";
				}
				if(inflictor.classname == "spear" || inflictor.classname == "impaler")
				{
					deathstring = " was impaled by ";
					deathstring2 = "!\n";
				}
				if(MP_IMPEL && deathstring == "")
				{
					deathstring = " died at the hands of ";
					deathstring2 = "!\n";
				}
				bprint(targ.netname);
				bprint(deathstring);
				bprint(attacker.netname);
				bprint(deathstring2);
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1; // killed self
			bprint(targ.netname);

			if(MP_HIPNOTIC && attacker.deathtype)
			{
				bprintf(" %s\n", attacker.deathtype);
				attacker.deathtype = "";
				return;
			}

			// killed by a monster?
			if(IS_MONSTER(attacker))
			{
				if(attacker.deathmessage)
					bprintf(" %s\n", attacker.deathmessage(attacker));
				return;
			}

			// tricks and traps
			if(targ.weapon == WEP_LIGHTME) // TODO: overrides all other deathtypes!
			{
				bprint(" couldn't control the LG-2 Prototype!\n");
				return;
			}
			if(attacker.classname == "explo_box")
			{
				bprint(" blew up\n");
				return;
			}
			if(attacker.solid == SOLID_BSP && attacker != NULL)
			{	
				bprint(" was squished\n");
				return;
			}
			if(attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint(" was spiked\n");
				return;
			}
			if(attacker.classname == "fireball")
			{
				bprint(" ate a lavaball\n");
				return;
			}
			if(attacker.classname == "trigger_changelevel")
			{
				bprint(" tried to leave\n");
				return;
			}
			if(attacker.classname == "ltrail_start" || attacker.classname == "ltrail_relay")
			{
				bprint(" rode the lightning\n");
				return;
			}
			if (attacker.classname == "pendulum")
			{
				bprint (" was cleaved in two\n");
				return;
			}
			if (attacker.classname == "buzzsaw")
			{
				bprint (" was sliced to pieces\n");
				return;
			}
			if (attacker.classname == "plasma")
			{
				bprint ( " was turned to plasma\n");
				return;
			}
			if (attacker.classname == "Vengeance")
			{
				// vengeance sphere doesn't count as a negative frag
				targ.frags = targ.frags + 1;
				bprint ( " was purged by the Vengeance Sphere\n");
				return;
			}
			if (attacker.classname == "power_shield")
			{
				// shield attacks should count for frags too..
				// shield death doesn't count as a negative frag
				targ.frags = targ.frags + 1;
				attacker.owner.frags = attacker.owner.frags + 1;
				TeamAssists(targ, attacker.owner);			//PGM

				deathstring = " was smashed by ";
				deathstring2 = "\n";
				bprint (deathstring);
				bprint (attacker.owner.netname);
				bprint (deathstring2);
				return;
			}

			// in-water deaths
			rnum = targ.watertype;
			if(rnum == CONTENT_WATER)
			{
				if(random() < 0.5)
					bprint(" sleeps with the fishes\n");
				else
					bprint(" sucks it down\n");
				return;
			}
			else if(rnum == CONTENT_SLIME)
			{
				if(random() < 0.5)
					bprint(" gulped a load of slime\n");
				else
					bprint(" can't exist on slime alone\n");
				return;
			}
			else if(rnum == CONTENT_LAVA)
			{
				if(targ.health < -15)
				{
					bprint(" burst into flames\n");
					return;
				}
				if(random() < 0.5)
					bprint(" turned into hot slag\n");
				else
					bprint(" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if(targ.deathtype == "falling")
			{
				if(!MP_IMPEL)
					targ.deathtype = "";
				bprint(" fell to their death\n");
				return;
			}

			// hell if I know; he's just dead!!!
			if(MP_IMPEL)
				bprint(" died wickedly!\n");
			else
				bprint(" died\n");
		}
	}
}

int Say(entity source, int teamsay, entity privatesay, string msgin, bool floodcontrol);
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
		bprintf("%s is connecting...\n", this.netname);
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
