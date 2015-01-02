// Modded announcer and random functions for the Jeff Resurrection servers
#ifdef JEFF

var float autocvar_jeff_announce_eagleeye_distance = 32768;
var float autocvar_jeff_announce_rocketscientist_count = 5;
var float autocvar_jeff_announce_shaftmaster_count = 5;
var float autocvar_jeff_announce_flakmaster_count = 5;
var float autocvar_jeff_announce_jackhammer_count = 5;
var float autocvar_jeff_announce_nodebuster_count = 5;
var float autocvar_jeff_announce_mutdestruct_time = 1.5;
var float autocvar_jeff_announce_multikill_time = 0.6;
var float autocvar_jeff_announce_roadrage_count = 6;
var float autocvar_jeff_announce_roadrampage_count = 12;
var float autocvar_jeff_announce_manslaughter_count = 20;
var float autocvar_jeff_announce_hattrick_count = 50;
var float autocvar_jeff_announce_denied_radius = 60;
var float autocvar_jeff_announce_bottomfeeder_count = 20;
var float autocvar_jeff_announce_wickedsick_count = 3;
var float autocvar_jeff_announce_bluestreak_distance = 400;
var float autocvar_jeff_announce_holy_distance = 800;
var float autocvar_jeff_announce_hitandrun_speed = 1000;
var float autocvar_jeff_announce_juggernaut_armor = 180;
var float autocvar_jeff_announce_juggernaut_health = 170;
var float autocvar_jeff_announce_slacker_time = 30;
var float autocvar_jeff_announce_comboking_count = 30;

.float rocketkill_count; // counter for rocket scientist
.float arckill_count; // counter for shaft master
.float hagarkill_count; // counter for flak master
.float meleekill_count; // counter for flak master
.float electrokill_count; // counter for flak master
.float vkill_count; // counter for vehicle kills
.float minipickup_count; // counter for bottom feeder

.float lastkiller_weapon;
.float lastkiller_time;
.float lastkilled_time;
.float lastkilled_flying; // actually a counter

.float jeff_weaponswitch_count;

.float annce_count;
.float last_announcer;

float Fire_IsBurning(entity e); // defined later

void jeff_Announcer_Send(entity player, float toall, float announce)
{
	if(player == world || !IS_PLAYER(player)) { return; }
	if(player.last_announcer > time) { return; }

	player.last_announcer = time + 0.3; // avoid spam
	player.annce_count += 1;

	//dprint("Sending an announcement to player ", player.netname, "\n");

	if(player.annce_count == autocvar_jeff_announce_hattrick_count)
	{
		Send_Notification(NOTIF_ONE, player, MSG_ANNCE, ANNCE_JEFF_HATTRICK);
		return;
	}

	Send_Notification(((toall) ? NOTIF_ALL : NOTIF_ONE), ((toall) ? world : player), MSG_ANNCE, announce);
}

void jeff_Announcer_PlayerDies(entity attacker, float deathtype, entity targ, entity inflictor)
{
	if(attacker == targ) { return; } // don't play announcements for self kills (yet)
	if(!IS_PLAYER(targ) || !targ) { return; } // don't play announcements for non-player kills

	// set required values
	float death_weapon = DEATH_WEAPONOF(deathtype);
	float targ_flying = !(targ.flags & FL_ONGROUND);
	float attacker_flying = !(attacker.flags & FL_ONGROUND);
	float denied = FALSE; entity head;
	float bluestreak = FALSE;
	float killed = 0;
	float player_count = 0, best_killcount = 0;
	float wepcount = 0, mywepcount = 0;
	float i;

	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
	{
		if(weaponsInMap & WepSet_FromWeapon(i))
		{
			if(attacker.weapons & WepSet_FromWeapon(i))
				++mywepcount;
			++wepcount;
		}
	}

	FOR_EACH_PLAYER(head)
	{
		if(head != attacker)
		if(head.lastkiller == attacker)
		if(head.lastkiller_time - time <= 0.1) // killed within 0.1 seconds by this attacker
			++killed;

		++player_count;
	}

	if(player_count > 5)
	FOR_EACH_PLAYER(head)
	{
		if(head != attacker)
		if(head.killcount >= 1)
		if(!best_killcount || head.killcount >= best_killcount)
			best_killcount = head.killcount;
	}

	if(!IS_PLAYER(attacker))
	FOR_EACH_PLAYER(head)
	if(vlen(head.origin - targ.origin) <= autocvar_jeff_announce_bluestreak_distance)
	{
		bluestreak = TRUE;
		break;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR)) { attacker.rocketkill_count += 1; }
	else { attacker.rocketkill_count = 0; }

	if(DEATH_ISWEAPON(deathtype, WEP_HAGAR)) { attacker.hagarkill_count += 1; }
	else { attacker.hagarkill_count = 0; }

	if(DEATH_ISWEAPON(deathtype, WEP_ARC)) { attacker.arckill_count += 1; }
	else { attacker.arckill_count = 0; }

	if((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY)) { attacker.meleekill_count += 1; }
	else { attacker.meleekill_count = 0; }

	if(DEATH_ISWEAPON(deathtype, WEP_ELECTRO)) { attacker.electrokill_count += 1; }
	else { attacker.electrokill_count = 0; }

	if(attacker.vehicle) { attacker.vkill_count += 1; }
	else { attacker.vkill_count = 0; }

	if(attacker_flying) { attacker.lastkilled_flying += 1; }
	else { attacker.lastkilled_flying = 0; }

	targ.lastkiller_weapon = death_weapon;
	targ.lastkiller_time = time;

	for(head = findradius(targ.origin, autocvar_jeff_announce_denied_radius); head; head = head.chain)
	{
		float avail = (head.ItemStatus & ITS_AVAILABLE);
		if( (head.classname == "item_health_mega" && avail)
		||	(head.classname == "item_armor_large" && avail)
		||	(head.classname == "item_flag_team" && (CTF_DIFFTEAM(head, targ) || targ.flagcarried))
		||	(avail && (head.weapon == WEP_VORTEX || head.weapon == WEP_DEVASTATOR || (head.weapon == WEP_VAPORIZER && !g_instagib)))
		)
		{
			denied = TRUE;
			break;
		}
	}

	// play the announcements
	if(attacker.meleekill_count == autocvar_jeff_announce_jackhammer_count)
	if((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_JACKHAMMER);

	if(DEATH_ISWEAPON(deathtype, WEP_BLASTER) || ((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY)))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_HUMILIATION);

	if(deathtype == DEATH_FALL && IS_PLAYER(attacker))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_PANCAKE);

	if(SAME_TEAM(attacker, targ))
	if(attacker.lastkiller == targ)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_RETRIBUTION);
	else
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_TEAMKILLER);

	if(vlen(attacker.origin - targ.origin) > autocvar_jeff_announce_eagleeye_distance)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_EAGLEEYE);

	if(attacker.lastkiller == targ)
	if(attacker.lastkiller_weapon == death_weapon)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_PAYBACK);
	else if(player_count > 2)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_VENGEANCE);

	if(attacker.rocketkill_count == autocvar_jeff_announce_rocketscientist_count && DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_ROCKETSCIENTIST);

	if(attacker.arckill_count == autocvar_jeff_announce_shaftmaster_count && DEATH_ISWEAPON(deathtype, WEP_ARC))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_SHAFTMASTER);

	if(time - attacker.lastkiller_time <= autocvar_jeff_announce_mutdestruct_time)
	if(time - targ.lastkiller_time <= autocvar_jeff_announce_mutdestruct_time)
	if(attacker.lastkiller == targ && targ.lastkiller == attacker)
	{
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_MUTDESTRUCT);
		jeff_Announcer_Send(targ, ANNCE_JEFF_MUTDESTRUCT);
	}

	if(time - attacker.lastkilled_time <= autocvar_jeff_announce_multikill_time && time - attacker.lastkilled_time > 0.2) // don't do this for real multikills
	if(attacker.lastkilled_flying == autocvar_jeff_announce_wickedsick_count)
		jeff_Announcer_Send(attacker, TRUE, ANNCE_JEFF_NUKEMHOLY);
	else
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_MULTIKILL);

	if(attacker.vehicle && deathtype == DEATH_VH_CRUSH && attacker.vkill_count && !!(attacker.vkill_count % 2))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_ROADKILL);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_roadrage_count)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_ROADRAGE);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_roadrampage_count)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_ROADRAMPAGE);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_manslaughter_count)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_MANSLAUGHTER);

	if(attacker_flying && targ_flying)
	if(DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR) && !(deathtype & HITTYPE_SPLASH))
	if(vlen(targ.origin - attacker.origin) >= autocvar_jeff_announce_holy_distance)
		jeff_Announcer_Send(attacker, TRUE, ANNCE_JEFF_HOLY);

	if(denied)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_DENIED);

	if(inflictor.realowner == attacker && inflictor.jeff_projowner == targ) // killed by their own projectile
		jeff_Announcer_Send(targ, ANNCE_JEFF_REJECTED);

	if(attacker.minipickup_count >= autocvar_jeff_announce_bottomfeeder_count)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_BOTTOMFEEDER);

	if(attacker.lastkilled_flying == autocvar_jeff_announce_wickedsick_count)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_WICKEDSICK);

	if(deathtype == DEATH_SLIME && IS_PLAYER(attacker))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_BIOHAZARD);

	if(Fire_IsBurning(attacker) && deathtype == DEATH_FIRE)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_BLAZEOFGLORY);

	if(bluestreak)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_BLUESTREAK);

	if(vlen(attacker.velocity) >= autocvar_jeff_announce_hitandrun_speed)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_HITANDRUN);

	if(attacker.armorvalue >= autocvar_jeff_announce_juggernaut_armor && attacker.health >= autocvar_jeff_announce_juggernaut_health)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_JUGGERNAUT);

	switch(killed)
	{
		case 2: jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_DOUBLEKILL); break;
		case 3: jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_MULTIKILL); break;
		case 4: jeff_Announcer_Send(attacker, TRUE, ANNCE_JEFF_MEGAKILL); break;
		case 5: jeff_Announcer_Send(attacker, TRUE, ANNCE_JEFF_ULTRAKILL); break;
		case 6: jeff_Announcer_Send(attacker, TRUE, ANNCE_JEFF_MONSTERKILL); break;
		case 7: jeff_Announcer_Send(attacker, TRUE, ANNCE_JEFF_LUDICROUSKILL); break;
		case 10: jeff_Announcer_Send(attacker, TRUE, ANNCE_JEFF_GODLIKE); break;
	}

	if(attacker.hagarkill_count == autocvar_jeff_announce_flakmaster_count && DEATH_ISWEAPON(deathtype, WEP_HAGAR))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_FLAKMASTER);

	if(attacker.electrokill_count == autocvar_jeff_announce_nodebuster_count && DEATH_ISWEAPON(deathtype, WEP_ELECTRO))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_NODEBUSTER);

	if(attacker.lastkilled_time - time >= autocvar_jeff_announce_slacker_time)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_SLACKER);

	if(attacker.killcount >= 1)
	if(best_killcount == attacker.killcount - 1) // attacker just took the lead (TODO: make sure this isn't spammed)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_TOPGUN);

	if(attacker.jeff_weaponswitch_count >= autocvar_jeff_announce_comboking_count)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_COMBOKING);

	if(mywepcount >= wepcount)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_GUNSLINGER);

	if(targ_flying && attacker_flying && (DEATH_ISWEAPON(deathtype, WEP_HAGAR) || DEATH_ISWEAPON(deathtype, WEP_SEEKER) || DEATH_ISWEAPON(deathtype, WEP_CRYLINK)))
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_OUTSTANDING);

	if(targ.buffs & BUFF_SPEED)
		jeff_Announcer_Send(attacker, FALSE, ANNCE_JEFF_SPEED);


	attacker.jeff_weaponswitch_count = 0;
}

void jeff_Announcer_MatchEnd()
{
	Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_JEFF_GAMEOVER);
}

void jeff_Announcer_VehicleEnter(entity player, entity veh)
{
	if(DIFF_TEAM(player, veh))
		jeff_Announcer_Send(player, ANNCE_JEFF_HIJACKED);
}

void jeff_Announcer_ItemTouch(entity player, entity item)
{
	if(item.classname == "item_health_small" || item.classname == "item_armor_small")
		player.minipickup_count += 1;
	else
		player.minipickup_count -= 1;
}

void jeff_Announcer_FireBullet(entity targ, entity ent, vector hitloc, vector start, vector end)
{
	if(ent.weapon != WEP_RIFLE && ent.weapon != WEP_VAPORIZER && ent.weapon != WEP_VORTEX)
		return;
	if(!IS_PLAYER(targ))
		return;
	if(targ.frozen || !targ.takedamage || targ.jb_isprisoned || targ.deadflag != DEAD_NO)
		return;
	vector headmins, headmaxs, org;
	org = antilag_takebackorigin(targ, time - ANTILAG_LATENCY(ent));
	headmins = org - '5 5 15';
	headmaxs = org + '5 5 15';
	if(trace_hits_box(start, end, headmins, headmaxs))
		jeff_Announcer_Send(ent, ANNCE_JEFF_BULLSEYE);
}

#else

void jeff_Announcer_PlayerDies(entity attacker, float deathtype, entity targ, entity inflictor) { }
void jeff_Announcer_MatchEnd() { }
void jeff_Announcer_VehicleEnter(entity player, entity veh) { }
void jeff_Announcer_ItemTouch(entity player, entity item) { }
void jeff_Announcer_FireBullet(entity targ, entity ent, vector hitloc, vector start, vector end) { }

#endif
