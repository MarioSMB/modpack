.entity accuracy;
.float accuracy_frags[WEP_MAXCOUNT];

float weaponstats_buffer;

void WeaponStats_Init()
{
	if(autocvar_sv_weaponstats_file != "")
		weaponstats_buffer = buf_create();
	else
		weaponstats_buffer = -1;
}

#define WEAPONSTATS_GETINDEX(awep,abot,vwep,vbot) (((vwep) + (awep) * (WEP_LAST - WEP_FIRST + 1) - (WEP_FIRST + WEP_FIRST * (WEP_LAST - WEP_FIRST + 1))) * 4 + (abot) * 2 + (vbot))

void WeaponStats_ready(entity fh, entity pass, float status)
{
	float i, j, n, ibot, jbot, idx;
	vector v;
	string prefix, s;
	switch(status)
	{
		case URL_READY_CANWRITE:
			// we can write
			prefix = strcat(autocvar_hostname, "\t", GetGametype(), "_", GetMapname(), "\t");
			url_fputs(fh, "#begin statsfile\n");
			url_fputs(fh, strcat("#date ", strftime(TRUE, "%a %b %e %H:%M:%S %Z %Y"), "\n"));
#ifdef WATERMARK
			url_fputs(fh, strcat("#version ", WATERMARK, "\n"));
#endif
			url_fputs(fh, strcat("#config ", ftos(crc16(FALSE, cvar_purechanges)), "\n"));
			url_fputs(fh, strcat("#cvar_purechanges ", ftos(cvar_purechanges_count), "\n"));
			n = tokenizebyseparator(cvar_purechanges, "\n");
			for(i = 0; i < n; ++i)
				url_fputs(fh, strcat("#cvar_purechange ", argv(i), "\n"));
			for(i = WEP_FIRST; i <= WEP_LAST; ++i) for(ibot = 0; ibot <= 1; ++ibot)
				for(j = WEP_FIRST; j <= WEP_LAST; ++j) for(jbot = 0; jbot <= 1; ++jbot)
				{
					idx = WEAPONSTATS_GETINDEX(i, ibot, j, jbot);
					v = stov(bufstr_get(weaponstats_buffer, idx));
					if(v != '0 0 0')
					{
						//vector is: kills hits damage
						url_fputs(fh, sprintf("%s%d %d\t%d %d\t", prefix, i, ibot, j, jbot));
						url_fputs(fh, sprintf("%d %d %g\n", v_x, v_y, v_z));
					}
				}
			url_fputs(fh, "#end\n\n");
			url_fclose(fh);
			break;
		case URL_READY_CANREAD:
			// url_fclose is processing, we got a response for writing the data
			// this must come from HTTP
			print("Got response from weapon stats server:\n");
			while((s = url_fgets(fh)))
				print("  ", s, "\n");
			print("End of response.\n");
			url_fclose(fh);
			break;
		case URL_READY_CLOSED:
			// url_fclose has finished
			print("Weapon stats written\n");
			buf_del(weaponstats_buffer);
			weaponstats_buffer = -1;
			break;
		case URL_READY_ERROR:
		default:
			print("Weapon stats writing failed: ", ftos(status), "\n");
			buf_del(weaponstats_buffer);
			weaponstats_buffer = -1;
			break;
	}
}

void WeaponStats_Shutdown()
{
	if(weaponstats_buffer < 0)
		return;
	if(autocvar_sv_weaponstats_file != "")
	{
		url_multi_fopen(autocvar_sv_weaponstats_file, FILE_APPEND, WeaponStats_ready, world);
	}
	else
	{
		buf_del(weaponstats_buffer);
		weaponstats_buffer = -1;
	}
}

void WeaponStats_LogItem(float awep, float abot, float vwep, float vbot, vector item)
{
	float idx;
	if(weaponstats_buffer < 0)
		return;
	if(awep < WEP_FIRST || vwep < WEP_FIRST)
		return;
	if(awep > WEP_LAST || vwep > WEP_LAST)
		return;
	idx = WEAPONSTATS_GETINDEX(awep,abot,vwep,vbot);
	bufstr_set(weaponstats_buffer, idx, vtos(stov(bufstr_get(weaponstats_buffer, idx)) + item));
}
void WeaponStats_LogDamage(float awep, float abot, float vwep, float vbot, float damage)
{
	if(damage < 0)
		error("negative damage?");
	WeaponStats_LogItem(awep, abot, vwep, vbot, '0 0 1' * damage + '0 1 0');
}
void WeaponStats_LogKill(float awep, float abot, float vwep, float vbot)
{
	WeaponStats_LogItem(awep, abot, vwep, vbot, '1 0 0');
}

// changes by LordHavoc on 03/29/04 and 03/30/04 at Vermeulen's request
// merged player_run and player_stand to player_anim
// added death animations to player_anim
// can now spawn thrown weapons from anywhere, not just from players
// thrown weapons now fade out after 20 seconds
// created PlayerGib function
// PlayerDie no longer uses hitloc or damage
// PlayerDie now supports dying animations as well as gibbing
// cleaned up PlayerDie a lot
// added CopyBody

.entity pusher;
.float pushltime;
.float istypefrag;

.float CopyBody_nextthink;
.void(void) CopyBody_think;
void CopyBody_Think(void)
{
	if(self.CopyBody_nextthink && time > self.CopyBody_nextthink)
	{
		self.CopyBody_think();
		if(wasfreed(self))
			return;
		self.CopyBody_nextthink = self.nextthink;
		self.CopyBody_think = self.think;
		self.think = CopyBody_Think;
	}
	CSQCMODEL_AUTOUPDATE();
	self.nextthink = time;
}
void CopyBody(float keepvelocity)
{
	entity oldself;
	if (self.effects & EF_NODRAW)
		return;
	oldself = self;
	self = spawn();
	self.enemy = oldself;
	self.lip = oldself.lip;
	self.colormap = oldself.colormap;
	self.iscreature = oldself.iscreature;
	self.teleportable = oldself.teleportable;
	self.damagedbycontents = oldself.damagedbycontents;
	self.angles = oldself.angles;
	self.avelocity = oldself.avelocity;
	self.classname = "body";
	self.damageforcescale = oldself.damageforcescale;
	self.effects = oldself.effects;
	self.glowmod = oldself.glowmod;
	self.event_damage = oldself.event_damage;
	self.anim_state = oldself.anim_state;
	self.anim_time = oldself.anim_time;
	self.anim_lower_action = oldself.anim_lower_action;
	self.anim_lower_time = oldself.anim_lower_time;
	self.anim_upper_action = oldself.anim_upper_action;
	self.anim_upper_time = oldself.anim_upper_time;
	self.anim_implicit_state = oldself.anim_implicit_state;
	self.anim_implicit_time = oldself.anim_implicit_time;
	self.anim_lower_implicit_action = oldself.anim_lower_implicit_action;
	self.anim_lower_implicit_time = oldself.anim_lower_implicit_time;
	self.anim_upper_implicit_action = oldself.anim_upper_implicit_action;
	self.anim_upper_implicit_time = oldself.anim_upper_implicit_time;
	self.dphitcontentsmask = oldself.dphitcontentsmask;
	self.death_time = oldself.death_time;
	self.pain_finished = oldself.pain_finished;
	self.health = oldself.health;
	self.armorvalue = oldself.armorvalue;
	self.armortype = oldself.armortype;
	self.model = oldself.model;
	self.modelindex = oldself.modelindex;
	self.skin = oldself.skin;
	self.species = oldself.species;
	self.movetype = oldself.movetype;
	self.solid = oldself.solid;
	self.ballistics_density = oldself.ballistics_density;
	self.takedamage = oldself.takedamage;
	self.customizeentityforclient = oldself.customizeentityforclient;
	self.uncustomizeentityforclient = oldself.uncustomizeentityforclient;
	self.uncustomizeentityforclient_set = oldself.uncustomizeentityforclient_set;
	if (keepvelocity == 1)
		self.velocity = oldself.velocity;
	self.oldvelocity = self.velocity;
	self.alpha = oldself.alpha;
	self.fade_time = oldself.fade_time;
	self.fade_rate = oldself.fade_rate;
	//self.weapon = oldself.weapon;
	setorigin(self, oldself.origin);
	setsize(self, oldself.mins, oldself.maxs);
	self.prevorigin = oldself.origin;
	self.reset = SUB_Remove;

	Drag_MoveDrag(oldself, self);

	if(self.colormap <= maxclients && self.colormap > 0)
		self.colormap = 1024 + oldself.clientcolors;

	CSQCMODEL_AUTOINIT();
	self.CopyBody_nextthink = oldself.nextthink;
	self.CopyBody_think = oldself.think;
	self.nextthink = time;
	self.think = CopyBody_Think;
	// "bake" the current animation frame for clones (they don't get clientside animation)
	animdecide_setframes(self, FALSE, frame, frame1time, frame2, frame2time);

	self = oldself;
}

float player_getspecies()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_species;
	get_model_parameters(string_null, 0);
	if(s < 0)
		return SPECIES_HUMAN;
	return s;
}

void player_setupanimsformodel()
{
	// load animation info
	animdecide_init(self);
	animdecide_setstate(self, 0, FALSE);
}

void player_anim (void)
{
	float deadbits = (self.anim_state & (ANIMSTATE_DEAD1 | ANIMSTATE_DEAD2));
	if(self.deadflag && !deadbits)
		if(random() < 0.5)
			deadbits = ANIMSTATE_DEAD1;
		else
			deadbits = ANIMSTATE_DEAD2;
	float animbits = deadbits;
	if(self.frozen)
		animbits |= ANIMSTATE_FROZEN;
	if(self.crouch)
		animbits |= ANIMSTATE_DUCK;
	animdecide_setstate(self, animbits, FALSE);
	animdecide_setimplicitstate(self, (self.flags & FL_ONGROUND));

	if (self.weaponentity)
	{
		updateanim(self.weaponentity);
		if (!self.weaponentity.animstate_override)
			setanim(self.weaponentity, self.weaponentity.anim_idle, TRUE, FALSE, FALSE);
	}
}

void SpawnThrownWeapon (vector org, float w)
{
	if(WEPSET_CONTAINS_EW(self, self.weapon))
		if(W_IsWeaponThrowable(self.weapon))
			W_ThrowNewWeapon(self, self.weapon, FALSE, org, randomvec() * 125 + '0 0 200');
}

void PlayerCorpseDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float take, save;
	vector v;
	Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);

	// damage resistance (ignore most of the damage from a bullet or similar)
	damage = max(damage - 5, 1);

	v = healtharmor_applydamage(self.armorvalue, autocvar_g_balance_armor_blockpercent, damage);
	take = v_x;
	save = v_y;

	if(sound_allowed(MSG_BROADCAST, attacker))
	{
		if (save > 10)
			sound (self, CH_SHOTS, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
		else if (take > 30)
			sound (self, CH_SHOTS, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
		else if (take > 10)
			sound (self, CH_SHOTS, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM);
	}

	if (take > 50)
		Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
	if (take > 100)
		Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);

	if (!(self.flags & FL_GODMODE))
	{
		self.armorvalue = self.armorvalue - save;
		self.health = self.health - take;
		// pause regeneration for 5 seconds
		self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_pause_health_regen);
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
	self.dmg_inflictor = inflictor;

	if (self.health <= -autocvar_sv_gibhealth && self.alpha >= 0)
	{
		// don't use any animations as a gib
		self.frame = 0;
		// view just above the floor
		self.view_ofs = '0 0 4';

		Violence_GibSplash(self, 1, 1, attacker);
		self.alpha = -1;
		self.solid = SOLID_NOT; // restore later
		self.takedamage = DAMAGE_NO; // restore later
		self.damagedbycontents = FALSE;
	}
}

void ClientKill_Now_TeamChange();

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float take, save, waves, sdelay, dh, da, j;
	vector v;
	float valid_damage_for_weaponstats;
	float excess;

	dh = max(self.health, 0);
	da = max(self.armorvalue, 0);

	if(!DEATH_ISSPECIAL(deathtype))
	{
		damage *= sqrt(bound(1.0, self.cvar_cl_handicap, 100.0));
		if(self != attacker)
			damage /= sqrt(bound(1.0, attacker.cvar_cl_handicap, 100.0));
	}

	if(DEATH_ISWEAPON(deathtype, WEP_TUBA))
	{
		// tuba causes blood to come out of the ears
		vector ear1, ear2;
		vector d;
		float f;
		ear1 = self.origin;
		ear1_z += 0.125 * self.view_ofs_z + 0.875 * self.maxs_z; // 7/8
		ear2 = ear1;
		makevectors(self.angles);
		ear1 += v_right * -10;
		ear2 += v_right * +10;
		d = inflictor.origin - self.origin;
		f = (d * v_right) / vlen(d); // this is cos of angle of d and v_right!
		force = v_right * vlen(force);
		Violence_GibSplash_At(ear1, force * -1, 2, bound(0, damage, 25) / 2 * (0.5 - 0.5 * f), self, attacker);
		Violence_GibSplash_At(ear2, force,      2, bound(0, damage, 25) / 2 * (0.5 + 0.5 * f), self, attacker);
		if(f > 0)
		{
			hitloc = ear1;
			force = force * -1;
		}
		else
		{
			hitloc = ear2;
			// force is already good
		}
	}
	else
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);


	v = healtharmor_applydamage(self.armorvalue, autocvar_g_balance_armor_blockpercent, damage);
	take = v_x;
	save = v_y;

	if(attacker == self)
	{
		// don't reset pushltime for self damage as it may be an attempt to
		// escape a lava pit or similar
		//self.pushltime = 0;
		self.istypefrag = 0;
	}
	else if(IS_PLAYER(attacker))
	{
		self.pusher = attacker;
		self.pushltime = time + autocvar_g_maxpushtime;
		self.istypefrag = self.BUTTON_CHAT;
	}
	else if(time < self.pushltime)
	{
		attacker = self.pusher;
		self.pushltime = max(self.pushltime, time + 0.6);
	}
	else
	{
		self.pushltime = 0;
		self.istypefrag = 0;
	}

	frag_inflictor = inflictor;
	frag_attacker = attacker;
	frag_target = self;
	frag_damage = damage;
	damage_take = take;
	damage_save = save;
	damage_force = force;
	MUTATOR_CALLHOOK(PlayerDamage_SplitHealthArmor);
	take = bound(0, damage_take, self.health);
	save = bound(0, damage_save, self.armorvalue);
	excess = max(0, damage - take - save);

	if(sound_allowed(MSG_BROADCAST, attacker))
	{
		if (save > 10)
			sound (self, CH_SHOTS, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
		else if (take > 30)
			sound (self, CH_SHOTS, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
		else if (take > 10)
			sound (self, CH_SHOTS, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM); // FIXME possibly remove them?
	}

	if (take > 50)
		Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
	if (take > 100)
		Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);

	if not(autocvar_g_spawnshield_nodamage)
	if (time >= self.spawnshieldtime)
	{
		if (!(self.flags & FL_GODMODE))
		{
			self.armorvalue = self.armorvalue - save;
			self.health = self.health - take;
			// pause regeneration for 5 seconds
			if(take)
                self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_pause_health_regen);

			if (time > self.pain_finished)		//Don't switch pain sequences like crazy
			{
				self.pain_finished = time + 0.5;	//Supajoe

				if(autocvar_sv_gentle < 1) {
					if(self.classname != "body") // pain anim is BORKED on our ZYMs, FIXME remove this once we have good models
					{
						if (!self.animstate_override)
						{
							if (random() > 0.5)
								animdecide_setaction(self, ANIMACTION_PAIN1, TRUE);
							else
								animdecide_setaction(self, ANIMACTION_PAIN2, TRUE);
						}
					}

					if(sound_allowed(MSG_BROADCAST, attacker))
					if(take > 0)
					if(!DEATH_ISWEAPON(deathtype, WEP_LASER) || attacker != self || self.health < 2 * autocvar_g_balance_laser_primary_damage * autocvar_g_balance_selfdamagepercent + 1)
					if(self.health > 1)
					// exclude pain sounds for laserjumps as long as you aren't REALLY low on health and would die of the next two
					{
						if(deathtype == DEATH_FALL)
							PlayerSound(playersound_fall, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 75) // TODO make a "gentle" version?
							PlayerSound(playersound_pain100, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 50)
							PlayerSound(playersound_pain75, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 25)
							PlayerSound(playersound_pain50, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else
							PlayerSound(playersound_pain25, CH_PAIN, VOICETYPE_PLAYERSOUND);
					}
				}

				// throw off bot aim temporarily
				float shake;
				shake = damage * 5 / (bound(0,skill,100) + 1);
				self.v_angle_x = self.v_angle_x + (random() * 2 - 1) * shake;
				self.v_angle_y = self.v_angle_y + (random() * 2 - 1) * shake;
			}
		}
		else
			self.max_armorvalue += (save + take);
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
	self.dmg_inflictor = inflictor;

	if(g_ca && self != attacker && IS_PLAYER(attacker))
		PlayerTeamScore_Add(attacker, SP_SCORE, ST_SCORE, (damage - excess) * autocvar_g_ca_damage2score_multiplier);

	float abot, vbot, awep;
	abot = (IS_BOT_CLIENT(attacker));
	vbot = (IS_BOT_CLIENT(self));

	valid_damage_for_weaponstats = 0;
	awep = 0;

	if(vbot || IS_REAL_CLIENT(self))
	if(abot || IS_REAL_CLIENT(attacker))
	if(attacker && self != attacker)
	if(IsDifferentTeam(self, attacker))
	{
		if(DEATH_ISSPECIAL(deathtype))
			awep = attacker.weapon;
		else
			awep = DEATH_WEAPONOF(deathtype);
		valid_damage_for_weaponstats = 1;
	}

	if(valid_damage_for_weaponstats)
	{
		dh = dh - max(self.health, 0);
		da = da - max(self.armorvalue, 0);
		WeaponStats_LogDamage(awep, abot, self.weapon, vbot, dh + da);
	}

	if (self.health < 1)
	{
		float defer_ClientKill_Now_TeamChange;
		defer_ClientKill_Now_TeamChange = FALSE;

		if(self.alivetime)
		{
			PlayerStats_Event(self, PLAYERSTATS_ALIVETIME, time - self.alivetime);
			self.alivetime = 0;
		}

		if(valid_damage_for_weaponstats)
			WeaponStats_LogKill(awep, abot, self.weapon, vbot);

		if(autocvar_sv_gentle < 1) // TODO make a "gentle" version?
		if(sound_allowed(MSG_BROADCAST, attacker))
		{
			if(deathtype == DEATH_DROWN)
				PlayerSound(playersound_drown, CH_PAIN, VOICETYPE_PLAYERSOUND);
			else
				PlayerSound(playersound_death, CH_PAIN, VOICETYPE_PLAYERSOUND);
		}

		// get rid of kill indicator
		if(self.killindicator)
		{
			remove(self.killindicator);
			self.killindicator = world;
			if(self.killindicator_teamchange)
				defer_ClientKill_Now_TeamChange = TRUE;

			if(self.classname == "body")
			if(deathtype == DEATH_KILL)
			{
				// for the lemmings fans, a small harmless explosion
				pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);
			}
		}

		if(IS_PLAYER(attacker))
		{
			self.lastkiller = attacker;
			attacker.lastkilled = self;
		}

		// print an obituary message
		Obituary (attacker, inflictor, self, deathtype);
		race_PreDie();

        // increment frag counter for used weapon type
        float w;
        w = DEATH_WEAPONOF(deathtype);
        if(WEP_VALID(w))
	if(accuracy_isgooddamage(attacker, self))
        attacker.accuracy.(accuracy_frags[w-1]) += 1;

		frag_attacker = attacker;
		frag_inflictor = inflictor;
		frag_target = self;
		frag_damage = excess;
		frag_deathtype = deathtype;
		MUTATOR_CALLHOOK(PlayerDies);
		excess = frag_damage;
		weapon_action(self.weapon, WR_PLAYERDEATH);

		RemoveGrapplingHook(self);

		Portal_ClearAllLater(self);

		if(IS_REAL_CLIENT(self))
		{
			self.fixangle = TRUE;
			//msg_entity = self;
			//WriteByte (MSG_ONE, SVC_SETANGLE);
			//WriteAngle (MSG_ONE, self.v_angle_x);
			//WriteAngle (MSG_ONE, self.v_angle_y);
			//WriteAngle (MSG_ONE, 80);
		}

		if(defer_ClientKill_Now_TeamChange)
			ClientKill_Now_TeamChange(); // can turn player into spectator

		// player could have been miraculously resuscitated ;)
		// e.g. players in freezetag get frozen, they don't really die
		if(self.health >= 1 || !IS_PLAYER(self))
			return;

		// when we get here, player actually dies
		
		Unfreeze(self); // remove any icy remains

		// clear waypoints
		WaypointSprite_PlayerDead();
		// throw a weapon
		SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.switchweapon);

		// become fully visible
		self.alpha = default_player_alpha;
		// make the corpse upright (not tilted)
		self.angles_x = 0;
		self.angles_z = 0;
		// don't spin
		self.avelocity = '0 0 0';
		// view from the floor
		self.view_ofs = '0 0 -8';
		// toss the corpse
		self.movetype = MOVETYPE_TOSS;
		// shootable corpse
		self.solid = SOLID_CORPSE;
		self.ballistics_density = autocvar_g_ballistics_density_corpse;
		// don't stick to the floor
		self.flags &~= FL_ONGROUND;
		// dying animation
		self.deadflag = DEAD_DYING;
		// when to allow respawn
		sdelay = 0;
		waves = 0;
		if(autocvar_g_respawn_delay_forced)
			sdelay = autocvar_g_respawn_delay;
		else
			sdelay = cvar(strcat("g_", GetGametype(), "_respawn_delay"));
		if(!sdelay)
		{
			if(g_cts)
				sdelay = 0; // no respawn delay in CTS
			else
				sdelay = autocvar_g_respawn_delay;
		}
		waves = cvar(strcat("g_", GetGametype(), "_respawn_waves"));
		if(!waves)
			waves = autocvar_g_respawn_waves;
		if(waves)
			self.respawn_time = ceil((time + sdelay) / waves) * waves;
		else
			self.respawn_time = time + sdelay;
		if(autocvar_g_respawn_delay_max && autocvar_g_forced_respawn)
			self.respawn_time_max = time + autocvar_g_respawn_delay_max;
		else
			self.respawn_time_max = self.respawn_time;
		if((sdelay + waves >= 5.0) && (self.respawn_time - time > 1.75))
			self.respawn_countdown = 10; // first number to count down from is 10
		else
			self.respawn_countdown = -1; // do not count down

		if(g_cts || autocvar_g_forced_respawn)
			self.respawn_flags = self.respawn_flags | RESPAWN_FORCE;

		self.death_time = time;
		if (random() < 0.5)
			animdecide_setstate(self, self.anim_state | ANIMSTATE_DEAD1, TRUE);
		else
			animdecide_setstate(self, self.anim_state | ANIMSTATE_DEAD2, TRUE);
		if (self.maxs_z > 5)
		{
			self.maxs_z = 5;
			setsize(self, self.mins, self.maxs);
		}
		// set damage function to corpse damage
		if(autocvar_g_player_gib_always)
			excess = 10000;
		self.event_damage = PlayerCorpseDamage;
		// call the corpse damage function just in case it wants to gib
		self.event_damage(inflictor, attacker, excess, deathtype, hitloc, force);
		// set up to fade out later
		SUB_SetFade (self, time + 6 + random (), 1);

		if(autocvar_sv_gentle > 0 || autocvar_ekg) {
			// remove corpse
			PlayerCorpseDamage (inflictor, attacker, autocvar_sv_gibhealth+1.0, deathtype, hitloc, force);
		}

		// reset fields the weapons may use just in case
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			weapon_action(j, WR_RESETPLAYER);
			ATTACK_FINISHED_FOR(self, j) = 0;
		}
	}
}

.float muted; // to be used by prvm_edictset server playernumber muted 1
float Say(entity source, float teamsay, entity privatesay, string msgin, float floodcontrol)
// message "": do not say, just test flood control
// return value:
//   1 = accept
//   0 = reject
//  -1 = fake accept
{
	string msgstr, colorstr, cmsgstr, namestr, fullmsgstr, sourcemsgstr, fullcmsgstr, sourcecmsgstr;
	float flood;
	var .float flood_field;
	entity head;
	float ret;
	string privatemsgprefix = string_null; float privatemsgprefixlen = 0;

	if(!teamsay && !privatesay)
		if(substring(msgin, 0, 1) == " ")
			msgin = substring(msgin, 1, strlen(msgin) - 1); // work around DP say bug (say_team does not have this!)

	msgin = formatmessage(msgin);

	if not(IS_PLAYER(source))
		colorstr = "^0"; // black for spectators
	else if(teamplay)
		colorstr = Team_ColorCode(source.team);
	else
	{
		colorstr = "";
		teamsay = FALSE;
	}

	if(intermission_running)
		teamsay = FALSE;

	if(msgin != "")
		msgin = trigger_magicear_processmessage_forallears(source, teamsay, privatesay, msgin);

	/*
	 * using bprint solves this... me stupid
	// how can we prevent the message from appearing in a listen server?
	// for now, just give "say" back and only handle say_team
	if(!teamsay)
	{
		clientcommand(self, strcat("say ", msgin));
		return;
	}
	*/

	if(autocvar_g_chat_teamcolors)
		namestr = playername(source);
	else
		namestr = source.netname;

	if(msgin != "")
	{
		if(privatesay)
		{
			msgstr = strcat("\{1}\{13}* ^3", namestr, "^3 tells you: ^7");
			privatemsgprefixlen = strlen(msgstr);
			msgstr = strcat(msgstr, msgin);
			cmsgstr = strcat(colorstr, "^3", namestr, "^3 tells you:\n^7", msgin);
			if(autocvar_g_chat_teamcolors)
				privatemsgprefix = strcat("\{1}\{13}* ^3You tell ", playername(privatesay), ": ^7");
			else
				privatemsgprefix = strcat("\{1}\{13}* ^3You tell ", privatesay.netname, ": ^7");
		}
		else if(teamsay)
		{
			msgstr = strcat("\{1}\{13}", colorstr, "(^3", namestr, colorstr, ") ^7", msgin);
			cmsgstr = strcat(colorstr, "(^3", namestr, colorstr, ")\n^7", msgin);
		}
		else
		{
			if(substring(msgin, 0, 3) == "/me")
			{
				msgin = strreplace("/me", "", msgin);
				msgstr = strcat("\{1}^4* ^7", namestr, "^7", msgin);
			}
			else
				msgstr = strcat("\{1}", namestr, "^7: ", msgin);
			cmsgstr = "";
		}
		msgstr = strcat(strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint
	}
	else
	{
		msgstr = cmsgstr = "";
	}

	fullmsgstr = msgstr;
	fullcmsgstr = cmsgstr;

	// FLOOD CONTROL
	flood = 0;
	flood_field = floodcontrol_chat;
	if(floodcontrol)
	{
		float flood_spl;
		float flood_burst;
		float flood_lmax;
		float lines;
		if(privatesay)
		{
			flood_spl = autocvar_g_chat_flood_spl_tell;
			flood_burst = autocvar_g_chat_flood_burst_tell;
			flood_lmax = autocvar_g_chat_flood_lmax_tell;
			flood_field = floodcontrol_chattell;
		}
		else if(teamsay)
		{
			flood_spl = autocvar_g_chat_flood_spl_team;
			flood_burst = autocvar_g_chat_flood_burst_team;
			flood_lmax = autocvar_g_chat_flood_lmax_team;
			flood_field = floodcontrol_chatteam;
		}
		else
		{
			flood_spl = autocvar_g_chat_flood_spl;
			flood_burst = autocvar_g_chat_flood_burst;
			flood_lmax = autocvar_g_chat_flood_lmax;
			flood_field = floodcontrol_chat;
		}
		flood_burst = max(0, flood_burst - 1);
		// to match explanation in default.cfg, a value of 3 must allow three-line bursts and not four!

		// do flood control for the default line size
		if(msgstr != "")
		{
			getWrappedLine_remaining = msgstr;
			msgstr = "";
			lines = 0;
			while(getWrappedLine_remaining && (!flood_lmax || lines <= flood_lmax))
			{
				msgstr = strcat(msgstr, " ", getWrappedLineLen(82.4289758859709, strlennocol)); // perl averagewidth.pl < gfx/vera-sans.width
				++lines;
			}
			msgstr = substring(msgstr, 1, strlen(msgstr) - 1);

			if(getWrappedLine_remaining != "")
			{
				msgstr = strcat(msgstr, "\n");
				flood = 2;
			}

			if(time >= source.flood_field)
			{
				source.flood_field = max(time - flood_burst * flood_spl, source.flood_field) + lines * flood_spl;
			}
			else
			{
				flood = 1;
				msgstr = fullmsgstr;
			}
		}
		else
		{
			if(time >= source.flood_field)
				source.flood_field = max(time - flood_burst * flood_spl, source.flood_field) + flood_spl;
			else
				flood = 1;
		}

		if (timeout_status == TIMEOUT_ACTIVE) // when game is paused, no flood protection
			source.flood_field = flood = 0;
	}

	if(flood == 2) // cannot happen for empty msgstr
	{
		if(autocvar_g_chat_flood_notify_flooder)
		{
			sourcemsgstr = strcat(msgstr, "\n^3FLOOD CONTROL: ^7message too long, trimmed\n");
			sourcecmsgstr = "";
		}
		else
		{
			sourcemsgstr = fullmsgstr;
			sourcecmsgstr = fullcmsgstr;
		}
		cmsgstr = "";
	}
	else
	{
		sourcemsgstr = msgstr;
		sourcecmsgstr = cmsgstr;
	}

	if(!privatesay)
	if not(IS_PLAYER(source))
	{
		if not(intermission_running)
			if(teamsay || (autocvar_g_chat_nospectators == 1) || (autocvar_g_chat_nospectators == 2 && !(inWarmupStage || gameover)))
				teamsay = -1; // spectators
	}

	if(flood)
		print("NOTE: ", playername(source), "^7 is flooding.\n");

	// build sourcemsgstr by cutting off a prefix and replacing it by the other one
	if(privatesay)
		sourcemsgstr = strcat(privatemsgprefix, substring(sourcemsgstr, privatemsgprefixlen, -1));

	if(source.muted)
	{
		// always fake the message
		ret = -1;
	}
	else if(flood == 1)
	{
		if(autocvar_g_chat_flood_notify_flooder)
		{
			sprint(source, strcat("^3FLOOD CONTROL: ^7wait ^1", ftos(source.flood_field - time), "^3 seconds\n"));
			ret = 0;
		}
		else
			ret = -1;
	}
	else
	{
		ret = 1;
	}

	if(sourcemsgstr != "" && ret != 0)
	{
		if(ret < 0) // faked message, because the player is muted
		{
			sprint(source, sourcemsgstr);
			if(sourcecmsgstr != "" && !privatesay)
				centerprint(source, sourcecmsgstr);
		}
		else if(privatesay) // private message, between 2 people only
		{
			sprint(source, sourcemsgstr);
			sprint(privatesay, msgstr);
			if not(autocvar_g_chat_tellprivacy) { dedicated_print(msgstr); } // send to server console too if "tellprivacy" is disabled
			if(cmsgstr != "")
				centerprint(privatesay, cmsgstr);
		}
		else if(teamsay > 0) // team message, only sent to team mates
		{
			sprint(source, sourcemsgstr);
			dedicated_print(msgstr); // send to server console too
			if(sourcecmsgstr != "")
				centerprint(source, sourcecmsgstr);
			FOR_EACH_REALPLAYER(head) if(head.team == source.team)
				if(head != source)
				{
					sprint(head, msgstr);
					if(cmsgstr != "")
						centerprint(head, cmsgstr);
				}
		}
		else if(teamsay < 0) // spectator message, only sent to spectators
		{
			sprint(source, sourcemsgstr);
			dedicated_print(msgstr); // send to server console too
			FOR_EACH_REALCLIENT(head) if not(IS_PLAYER(head))
				if(head != source)
					sprint(head, msgstr);
		}
		else if(sourcemsgstr != msgstr) // trimmed/server fixed message, sent to all players
		{
			sprint(source, sourcemsgstr);
			dedicated_print(msgstr); // send to server console too
			FOR_EACH_REALCLIENT(head)
				if(head != source)
					sprint(head, msgstr);
		}
		else
			bprint(msgstr); // entirely normal message, sent to all players -- bprint sends to server console too.
	}

	return ret;
}

void IRCSay(string sourcename, string msgin)
{
	string msgstr, cmsgstr, fullmsgstr, fullcmsgstr;
	entity head;
        
	if(substring(msgin, 0, 1) == " ")
		msgin = substring(msgin, 1, strlen(msgin) - 1); // work around DP say bug (say_team does not have this!)

	msgin = formatmessage(msgin);

	if(msgin == "")
		return;

	if(msgin == "")
		return;

    msgstr = strcat("\{1}[IRC] ", sourcename, "^7", msgin);
	cmsgstr = "";

	msgstr = strcat(strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint
	fullmsgstr = msgstr;
	fullcmsgstr = cmsgstr;

	FOR_EACH_REALCLIENT(head)
		sprint(head, msgstr);
}

float GetVoiceMessageVoiceType(string type)
{
	if(type == "taunt")
		return VOICETYPE_TAUNT;
	if(type == "teamshoot")
		return VOICETYPE_LASTATTACKER;
	return VOICETYPE_TEAMRADIO;
}

string allvoicesamples;
.string GetVoiceMessageSampleField(string type)
{
	GetPlayerSoundSampleField_notFound = 0;
	switch(type)
	{
#define _VOICEMSG(m) case #m: return playersound_##m;
		ALLVOICEMSGS
#undef _VOICEMSG
	}
	GetPlayerSoundSampleField_notFound = 1;
	return playersound_taunt;
}

.string GetPlayerSoundSampleField(string type)
{
	GetPlayerSoundSampleField_notFound = 0;
	switch(type)
	{
#define _VOICEMSG(m) case #m: return playersound_##m;
		ALLPLAYERSOUNDS
#undef _VOICEMSG
	}
	GetPlayerSoundSampleField_notFound = 1;
	return playersound_taunt;
}

void PrecacheGlobalSound(string samplestring)
{
	float n, i;
	tokenize_console(samplestring);
	n = stof(argv(1));
	if(n > 0)
	{
		for(i = 1; i <= n; ++i)
			precache_sound(strcat(argv(0), ftos(i), ".wav"));
	}
	else
	{
		precache_sound(strcat(argv(0), ".wav"));
	}
}

void PrecachePlayerSounds(string f)
{
	float fh;
	string s;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 3)
		{
			dprint("Invalid sound info line: ", s, "\n");
			continue;
		}
		PrecacheGlobalSound(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);

	if not(allvoicesamples)
	{
#define _VOICEMSG(m) allvoicesamples = strcat(allvoicesamples, " ", #m);
		ALLVOICEMSGS
#undef _VOICEMSG
		allvoicesamples = strzone(substring(allvoicesamples, 1, strlen(allvoicesamples) - 1));
	}
}

void ClearPlayerSounds()
{
#define _VOICEMSG(m) if(self.playersound_##m) { strunzone(self.playersound_##m); self.playersound_##m = string_null; }
	ALLPLAYERSOUNDS
	ALLVOICEMSGS
#undef _VOICEMSG
}

float LoadPlayerSounds(string f, float first)
{
	float fh;
	string s;
	var .string field;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
	{
		dprint("Player sound file not found: ", f, "\n");
		return 0;
	}
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 3)
			continue;
		field = GetPlayerSoundSampleField(argv(0));
		if(GetPlayerSoundSampleField_notFound)
			field = GetVoiceMessageSampleField(argv(0));
		if(GetPlayerSoundSampleField_notFound)
			continue;
		if(self.field)
			strunzone(self.field);
		self.field = strzone(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);
	return 1;
}

.float modelindex_for_playersound;
.float skin_for_playersound;
void UpdatePlayerSounds()
{
	if(self.modelindex == self.modelindex_for_playersound)
	if(self.skin == self.skin_for_playersound)
		return;
	self.modelindex_for_playersound = self.modelindex;
	self.skin_for_playersound = self.skin;
	ClearPlayerSounds();
	LoadPlayerSounds("sound/player/default.sounds", 1);
	if(!autocvar_g_debug_defaultsounds)
		if(!LoadPlayerSounds(get_model_datafilename(self.model, self.skin, "sounds"), 0))
			LoadPlayerSounds(get_model_datafilename(self.model, 0, "sounds"), 0);
}

void FakeGlobalSound(string sample, float chan, float voicetype)
{
	float n;
	float tauntrand;

	if(sample == "")
		return;

	tokenize_console(sample);
	n = stof(argv(1));
	if(n > 0)
		sample = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
	else
		sample = strcat(argv(0), ".wav"); // randomization

	switch(voicetype)
	{
		case VOICETYPE_LASTATTACKER_ONLY:
			break;
		case VOICETYPE_LASTATTACKER:
			if(self.pusher)
			{
				msg_entity = self;
				if(IS_REAL_CLIENT(msg_entity))
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
			}
			break;
		case VOICETYPE_TEAMRADIO:
			msg_entity = self;
			if(msg_entity.cvar_cl_voice_directional == 1)
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
			else
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			break;
		case VOICETYPE_AUTOTAUNT:
			if(!sv_autotaunt)
				break;
			if(!sv_taunt)
				break;
			if(autocvar_sv_gentle)
				break;
			tauntrand = random();
			msg_entity = self;
			if (tauntrand < msg_entity.cvar_cl_autotaunt)
			{
				if (msg_entity.cvar_cl_voice_directional >= 1)
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
				else
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			}
			break;
		case VOICETYPE_TAUNT:
			if(IS_PLAYER(self))
				if(self.deadflag == DEAD_NO)
					animdecide_setaction(self, ANIMACTION_TAUNT, TRUE);
			if(!sv_taunt)
				break;
			if(autocvar_sv_gentle)
				break;
			msg_entity = self;
			if (msg_entity.cvar_cl_voice_directional >= 1)
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
			else
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			break;
		case VOICETYPE_PLAYERSOUND:
			msg_entity = self;
			soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NORM);
			break;
		default:
			backtrace("Invalid voice type!");
			break;
	}
}

void GlobalSound(string sample, float chan, float voicetype)
{
	float n;
	float tauntrand;

	if(sample == "")
		return;

	tokenize_console(sample);
	n = stof(argv(1));
	if(n > 0)
		sample = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
	else
		sample = strcat(argv(0), ".wav"); // randomization

	switch(voicetype)
	{
		case VOICETYPE_LASTATTACKER_ONLY:
			if(self.pusher)
			{
				msg_entity = self.pusher;
				if(IS_REAL_CLIENT(msg_entity))
				{
					if(msg_entity.cvar_cl_voice_directional == 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			}
			break;
		case VOICETYPE_LASTATTACKER:
			if(self.pusher)
			{
				msg_entity = self.pusher;
				if(IS_REAL_CLIENT(msg_entity))
				{
					if(msg_entity.cvar_cl_voice_directional == 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
				msg_entity = self;
				if(IS_REAL_CLIENT(msg_entity))
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
			}
			break;
		case VOICETYPE_TEAMRADIO:
			FOR_EACH_REALCLIENT(msg_entity)
				if(!teamplay || msg_entity.team == self.team)
				{
					if(msg_entity.cvar_cl_voice_directional == 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			break;
		case VOICETYPE_AUTOTAUNT:
			if(!sv_autotaunt)
				break;
			if(!sv_taunt)
				break;
			if(autocvar_sv_gentle)
				break;
			tauntrand = random();
			FOR_EACH_REALCLIENT(msg_entity)
				if (tauntrand < msg_entity.cvar_cl_autotaunt)
				{
					if (msg_entity.cvar_cl_voice_directional >= 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			break;
		case VOICETYPE_TAUNT:
			if(IS_PLAYER(self))
				if(self.deadflag == DEAD_NO)
					animdecide_setaction(self, ANIMACTION_TAUNT, TRUE);
			if(!sv_taunt)
				break;
			if(autocvar_sv_gentle)
				break;
			FOR_EACH_REALCLIENT(msg_entity)
			{
				if (msg_entity.cvar_cl_voice_directional >= 1)
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
				else
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			}
			break;
		case VOICETYPE_PLAYERSOUND:
			sound(self, chan, sample, VOL_BASE, ATTN_NORM);
			break;
		default:
			backtrace("Invalid voice type!");
			break;
	}
}

void PlayerSound(.string samplefield, float chan, float voicetype)
{
	GlobalSound(self.samplefield, chan, voicetype);
}

void VoiceMessage(string type, string msg)
{
	var .string sample;
	float voicetype, ownteam;
	float flood;
	sample = GetVoiceMessageSampleField(type);

	if(GetPlayerSoundSampleField_notFound)
	{
		sprint(self, strcat("Invalid voice. Use one of: ", allvoicesamples, "\n"));
		return;
	}

	voicetype = GetVoiceMessageVoiceType(type);
	ownteam = (voicetype == VOICETYPE_TEAMRADIO);

	flood = Say(self, ownteam, world, msg, 1);

	if (flood > 0)
		GlobalSound(self.sample, CH_VOICE, voicetype);
	else if (flood < 0)
		FakeGlobalSound(self.sample, CH_VOICE, voicetype);
}

void MoveToTeam(entity client, float team_colour, float type)
{
	float lockteams_backup;

	lockteams_backup = lockteams;  // backup any team lock

	lockteams = 0;  // disable locked teams

	TeamchangeFrags(client);  // move the players frags
	SetPlayerColors(client, team_colour - 1);  // set the players colour
	Damage(client, client, client, 100000, DEATH_AUTOTEAMCHANGE, client.origin, '0 0 0');  // kill the player

	lockteams = lockteams_backup;  // restore the team lock

	LogTeamchange(client.playerid, client.team, type);
}
