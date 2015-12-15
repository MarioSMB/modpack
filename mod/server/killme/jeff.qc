// Modded announcer and random functions for the Jeff Resurrection servers
#ifdef JEFF
REGISTER_MUTATOR(egoass, true);

float autocvar_jeff_announce_eagleeye_distance = 32768;
int autocvar_jeff_announce_rocketscientist_count = 5;
int autocvar_jeff_announce_shaftmaster_count = 5;
int autocvar_jeff_announce_flakmaster_count = 5;
int autocvar_jeff_announce_jackhammer_count = 5;
int autocvar_jeff_announce_nodebuster_count = 5;
float autocvar_jeff_announce_mutdestruct_time = 1.5;
float autocvar_jeff_announce_multikill_time = 0.6;
int autocvar_jeff_announce_roadrage_count = 6;
int autocvar_jeff_announce_roadrampage_count = 12;
int autocvar_jeff_announce_manslaughter_count = 20;
int autocvar_jeff_announce_hattrick_count = 50;
float autocvar_jeff_announce_denied_radius = 60;
int autocvar_jeff_announce_bottomfeeder_count = 20;
int autocvar_jeff_announce_wickedsick_count = 3;
float autocvar_jeff_announce_bluestreak_distance = 400;
float autocvar_jeff_announce_holy_distance = 800;
float autocvar_jeff_announce_hitandrun_speed = 1000;
float autocvar_jeff_announce_juggernaut_armor = 180;
float autocvar_jeff_announce_juggernaut_health = 170;
float autocvar_jeff_announce_slacker_time = 30;
int autocvar_jeff_announce_comboking_count = 30;
int autocvar_jeff_announce_wrecker_count = 30;
int autocvar_jeff_announce_monkill_count = 5;

.int rocketkill_count; // counter for rocket scientist
.int arckill_count; // counter for shaft master
.int hagarkill_count; // counter for flak master
.int meleekill_count; // counter for flak master
.int electrokill_count; // counter for flak master
.int vkill_count; // counter for vehicle kills
.int minipickup_count; // counter for bottom feeder
.int nadekill_count; // counter for wrecker

.int lastkiller_weapon;
.float lastkiller_time;
.float lastkilled_time;
.float lastkilled_flying; // actually a counter

.entity jeff_projowner;

.int monkill_count; // monster kills

.int jeff_weaponswitch_count;

.int jeff_switchweapon;

.int annce_count;
.float last_announcer;

bool Fire_IsBurning(entity e); // defined later

void jeff_Announcer_Send(entity player, bool toall, int announce)
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

MUTATOR_HOOKFUNCTION(egoass, MonsterSpawn)
{
	if(self.monsterid == MON_WYVERN.monsterid)
		return true;
	return false;
}

MUTATOR_HOOKFUNCTION(egoass, OnEntityPreSpawn)
{
	if(self.classname == "monster_wyvern")
		self.classname = "monster_scrag";

	return false;
}

MUTATOR_HOOKFUNCTION(egoass, PlayerPreThink)
{
	if(PS(self).m_weapon != PS(self).m_switchweapon)
	if(self.jeff_switchweapon != PS(self).m_switchweapon.m_id)
	{
		self.jeff_switchweapon = PS(self).m_switchweapon.m_id;
		self.jeff_weaponswitch_count += 1;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(egoass, PlayerSpawn)
{
	self.jeff_switchweapon = Weapons_from(w_getbestweapon(self));
	return false;
}

MUTATOR_HOOKFUNCTION(egoass, PrepareExplosionByDamage)
{
	if(IS_CLIENT(frag_attacker) && !autocvar_g_projectiles_keep_owner)
		self.jeff_projowner = self.realowner;

	return false;
}

MUTATOR_HOOKFUNCTION(egoass, PlayerDies)
{
	entity targ = frag_target;
	entity attacker = frag_attacker;
	int deathtype = frag_deathtype;
	entity inflictor = frag_inflictor;

	if(attacker == targ) { return; } // don't play announcements for self kills (yet)
	if(!IS_PLAYER(targ) || !targ) { return; } // don't play announcements for non-player kills

	// set required values
	float death_weapon = DEATH_WEAPONOF(deathtype).m_id;
	float targ_flying = !(targ.flags & FL_ONGROUND);
	float attacker_flying = !(attacker.flags & FL_ONGROUND);
	float denied = false; entity head;
	float bluestreak = false;
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
		if(head.lastkiller_time - time <= 5) // killed within 5 seconds by this attacker
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
		bluestreak = true;
		break;
	}

	if(deathtype == DEATH_NADE.m_id) { attacker.nadekill_count += 1; }
	else { attacker.nadekill_count = 0; }

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
		||	(avail && (head.weapon == WEP_VORTEX.m_id || head.weapon == WEP_DEVASTATOR.m_id || (head.weapon == WEP_VAPORIZER.m_id && !g_instagib)))
		)
		{
			denied = true;
			break;
		}
	}

	// play the announcements
	if(attacker.meleekill_count == autocvar_jeff_announce_jackhammer_count)
	if((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_JACKHAMMER);

	if(DEATH_ISWEAPON(deathtype, WEP_BLASTER) || ((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY)))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_HUMILIATION);

	if(deathtype == DEATH_FALL.m_id && IS_PLAYER(attacker))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_PANCAKE);

	if(SAME_TEAM(attacker, targ))
	if(attacker.lastkiller == targ)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_RETRIBUTION);
	else
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_TEAMKILLER);

	if(vlen(attacker.origin - targ.origin) > autocvar_jeff_announce_eagleeye_distance)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_EAGLEEYE);

	if(attacker.lastkiller == targ)
	if(attacker.lastkiller_weapon == death_weapon)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_PAYBACK);
	else if(player_count > 2)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_VENGEANCE);

	if(attacker.rocketkill_count == autocvar_jeff_announce_rocketscientist_count && DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROCKETSCIENTIST);

	if(attacker.arckill_count == autocvar_jeff_announce_shaftmaster_count && DEATH_ISWEAPON(deathtype, WEP_ARC))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_SHAFTMASTER);

	if(time - attacker.lastkiller_time <= autocvar_jeff_announce_mutdestruct_time)
	if(time - targ.lastkiller_time <= autocvar_jeff_announce_mutdestruct_time)
	if(attacker.lastkiller == targ && targ.lastkiller == attacker)
	{
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_MUTDESTRUCT);
		//jeff_Announcer_Send(targ, false, ANNCE_JEFF_MUTDESTRUCT);
	}

	if(IS_PLAYER(attacker))
	if(time - attacker.lastkilled_time <= autocvar_jeff_announce_multikill_time && time - attacker.lastkilled_time > 0.2) // don't do this for real multikills
	if(attacker.lastkilled_flying == autocvar_jeff_announce_wickedsick_count)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_NUKEMHOLY);
	else
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_MULTIKILL);

	if(attacker.vehicle && deathtype == DEATH_VH_CRUSH.m_id && attacker.vkill_count && !!(attacker.vkill_count % 2))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROADKILL);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_roadrage_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROADRAGE);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_roadrampage_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROADRAMPAGE);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_manslaughter_count)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_MANSLAUGHTER);

	if(attacker_flying && targ_flying)
	if(DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR) && !(deathtype & HITTYPE_SPLASH))
	if(vlen(targ.origin - attacker.origin) >= autocvar_jeff_announce_holy_distance)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_HOLY);

	if(denied)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_DENIED);

	if(inflictor.realowner == attacker && inflictor.jeff_projowner == targ) // killed by their own projectile
		jeff_Announcer_Send(targ, false, ANNCE_JEFF_REJECTED);

	if(attacker.minipickup_count >= autocvar_jeff_announce_bottomfeeder_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_BOTTOMFEEDER);

	if(attacker.lastkilled_flying == autocvar_jeff_announce_wickedsick_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_WICKEDSICK);

	if(deathtype == DEATH_SLIME.m_id && IS_PLAYER(attacker))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_BIOHAZARD);

	if(Fire_IsBurning(attacker) && deathtype == DEATH_FIRE.m_id)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_BLAZEOFGLORY);

	if(bluestreak)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_BLUESTREAK);

	if(vlen(attacker.velocity) >= autocvar_jeff_announce_hitandrun_speed)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_HITANDRUN);

	if(attacker.armorvalue >= autocvar_jeff_announce_juggernaut_armor && attacker.health >= autocvar_jeff_announce_juggernaut_health)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_JUGGERNAUT);

	switch(killed)
	{
		case 2: jeff_Announcer_Send(attacker, false, ((random() > 0.5) ? ANNCE_JEFF_DOUBLEKILL : ((random() > 0.5) ? ANNCE_JEFF_DOUBLEKILL1 : ANNCE_JEFF_DOUBLEKILL2))); break;
		case 3: jeff_Announcer_Send(attacker, false, ((random() > 0.5) ? ANNCE_JEFF_TRIPLEKILL : ((random() > 0.5) ? ANNCE_JEFF_MULTIKILL : ANNCE_JEFF_TRIPLEKILL1))); break;
		case 4: jeff_Announcer_Send(attacker, true, ANNCE_JEFF_MEGAKILL); break;
		case 5: jeff_Announcer_Send(attacker, true, ((random() > 0.5) ? ANNCE_JEFF_ULTRAKILL : ANNCE_JEFF_ULTRAKILL2)); break;
		case 6: jeff_Announcer_Send(attacker, true, ((random() > 0.5) ? ANNCE_JEFF_MONSTERKILL : ANNCE_JEFF_MONSTERKILL1)); break;
		case 7: jeff_Announcer_Send(attacker, true, ANNCE_JEFF_LUDICROUSKILL); break;
		case 10: jeff_Announcer_Send(attacker, true, ((random() > 0.5) ? ANNCE_JEFF_GODLIKE1 : ANNCE_JEFF_GODLIKE)); break;
	}

	if(attacker.hagarkill_count == autocvar_jeff_announce_flakmaster_count && DEATH_ISWEAPON(deathtype, WEP_HAGAR))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_FLAKMASTER);

	if(attacker.electrokill_count == autocvar_jeff_announce_nodebuster_count && DEATH_ISWEAPON(deathtype, WEP_ELECTRO))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_NODEBUSTER);

	if(attacker.lastkilled_time - time >= autocvar_jeff_announce_slacker_time)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_SLACKER);

	if(attacker.killcount >= 1)
	if(best_killcount == attacker.killcount - 1) // attacker just took the lead (TODO: make sure this isn't spammed)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_TOPGUN);

	if(attacker.killcount >= 1)
	if(best_killcount == attacker.killcount - 5)
		jeff_Announcer_Send(attacker, true, ((random() > 0.5) ? ANNCE_JEFF_DOMINATING : ((random() > 0.5) ? ANNCE_JEFF_DOMINATING1 : ANNCE_JEFF_DOMINATING2)));

	if(attacker.killcount >= 1)
	if(best_killcount == attacker.killcount - 10)
	{
		RandomSelection_Init();
		RandomSelection_Add(world, ANNCE_JEFF_UNSTOPPABLE, string_null, 1, 1);
		RandomSelection_Add(world, ANNCE_JEFF_UNSTOPPABLE1, string_null, 1, 1);
		RandomSelection_Add(world, ANNCE_JEFF_UNSTOPPABLE2, string_null, 1, 1);
		RandomSelection_Add(world, ANNCE_JEFF_UNSTOPPABLE3, string_null, 1, 1);
		jeff_Announcer_Send(attacker, true, RandomSelection_chosen_float);
	}

	if(attacker.jeff_weaponswitch_count >= autocvar_jeff_announce_comboking_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_COMBOKING);

	if(mywepcount >= wepcount)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_GUNSLINGER);

	if(targ_flying && attacker_flying && (DEATH_ISWEAPON(deathtype, WEP_HAGAR) || DEATH_ISWEAPON(deathtype, WEP_SEEKER) || DEATH_ISWEAPON(deathtype, WEP_CRYLINK)))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_OUTSTANDING);

	if(time - targ.spawnshieldtime <= 5)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_INSTAGIB);

	if(attacker.nadekill_count == autocvar_jeff_announce_wrecker_count && deathtype == DEATH_NADE.m_id)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_WRECKER);

	if(targ_flying && attacker_flying && DEATH_ISWEAPON(deathtype, WEP_FLAK))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_EXCELLENT);

	if(targ.classname != "body")
	if(IS_PLAYER(targ))
	if(targ != attacker)
	if(DIFF_TEAM(targ, attacker))
	{
		#define SPREE_ITEM(counta,countb,center,normal,gentle) \
			case counta: \
			{ \
				Send_Notification(NOTIF_ONE, attacker, MSG_ANNCE, ANNCE_JEFF_KILLSTREAK_##countb); \
				break; \
			}
		switch(attacker.killcount)
		{
			JEFF_KILL_SPREE_LIST
			default: break;
		}
		#undef SPREE_ITEM
	}


	attacker.jeff_weaponswitch_count = 0;
	attacker.lastkilled_time = time;

	return false;
}

MUTATOR_HOOKFUNCTION(egoass, PlayerDamage_SplitHealthArmor)
{
	if(time >= frag_target.spawnshieldtime)
	if(frag_target.health - damage_take <= 0)
	if(!(frag_target.flags & FL_GODMODE))
	if(!checkrules_firstblood)
	if(IS_PLAYER(frag_attacker))
	if(DIFF_TEAM(frag_attacker, frag_target))
		Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ((random() > 0.5) ? ANNCE_JEFF_FIRSTBLOOD : ((random() > 0.5) ? ANNCE_JEFF_FIRSTBLOOD1 : ANNCE_JEFF_FIRSTBLOOD2)));

	return false;
}

MUTATOR_HOOKFUNCTION(egoass, MatchEnd)
{
	Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_JEFF_GAMEOVER);
	return false;
}

MUTATOR_HOOKFUNCTION(egoass, VehicleEnter)
{
	if(vh_vehicle.tur_head.team)
	if(DIFF_TEAM(vh_player, vh_vehicle.tur_head))
		jeff_Announcer_Send(vh_player, true, ANNCE_JEFF_HIJACKED);
	return false;
}

MUTATOR_HOOKFUNCTION(egoass, ItemTouch)
{
	if(self.classname == "item_health_small" || self.classname == "item_armor_small")
		other.minipickup_count += 1;
	else
		other.minipickup_count -= 1;
	return false;
}

MUTATOR_HOOKFUNCTION(egoass, FireBullet_Hit, CBC_ORDER_FIRST)
{
	if(self.weapon != WEP_RIFLE.m_id && self.weapon != WEP_VAPORIZER.m_id && self.weapon != WEP_VORTEX.m_id)
		return false;
	if(!IS_PLAYER(bullet_hit))
		return false;
	if(bullet_hit.deadflag != DEAD_NO || bullet_hit.frozen || !bullet_hit.takedamage)
		return false;

	// TODO: hooks into another mutator?
	if(Headshot(bullet_hit, self, bullet_endpos, bullet_startpos, bullet_endpos))
	{
		if(random() > 0.8)
			return false;

		frag_damage *= autocvar_sv_headshot_damage; // more damage
		jeff_Announcer_Send(self, false, ((random() > 0.5) ? ANNCE_JEFF_HEADSHOT2 : ((random() > 0.5) ? ANNCE_JEFF_HEADSHOT3 : ANNCE_JEFF_HEADSHOT4)));
		return true;
	}

	vector headmins, headmaxs, org;
	org = antilag_takebackorigin(bullet_hit, time - ANTILAG_LATENCY(self));
	headmins = org - '5 5 10';
	headmaxs = org + '5 5 10';
	if(trace_hits_box(bullet_startpos, bullet_endpos, headmins, headmaxs))
		jeff_Announcer_Send(self, false, ANNCE_JEFF_BULLSEYE);

	return true;
}

MUTATOR_HOOKFUNCTION(egoass, BuffTouch)
{
	if(self.buffs & BUFF_INVISIBLE.m_itemid)
		jeff_Announcer_Send(other, true, ANNCE_JEFF_CAMOUFLAGED);

	if(self.buffs & BUFF_VAMPIRE.m_itemid)
		jeff_Announcer_Send(other, true, ANNCE_JEFF_VAMPIRE);

	if(self.buffs & BUFF_BASH.m_itemid)
		jeff_Announcer_Send(other, true, ANNCE_JEFF_BOOSTER);

	if(self.buffs & BUFF_SPEED.m_itemid)
		jeff_Announcer_Send(other, true, ANNCE_JEFF_SPEED);

	return false;
}

MUTATOR_HOOKFUNCTION(egoass, MonsterDies)
{
	if(IS_PLAYER(frag_attacker))
		frag_attacker.monkill_count += 1;

	if(IS_PLAYER(frag_attacker))
	if(frag_attacker.monkill_count == autocvar_jeff_announce_monkill_count)
		jeff_Announcer_Send(frag_attacker, false, ANNCE_JEFF_KILLINGSPREE);

	return false;
}

#endif
