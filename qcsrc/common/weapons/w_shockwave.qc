#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ SHOCKWAVE,
/* function  */ W_Shockwave,
/* ammotype  */ ammo_none,
/* impulse   */ 2,
/* flags     */ WEP_FLAG_NORMAL | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_LOW,
/* color     */ '0.5 0.25 0',
/* modelname */ "shotgun",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairshotgun 0.7",
/* wepimg    */ "weaponshotgun",
/* refname   */ "shockwave",
/* wepname   */ _("Shockwave")
);

#define SHOCKWAVE_SETTINGS(w_cvar,w_prop) SHOCKWAVE_SETTINGS_LIST(w_cvar, w_prop, SHOCKWAVE, shockwave)
#define SHOCKWAVE_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, blast_animtime) \
	w_cvar(id, sn, NONE, blast_damage) \
	w_cvar(id, sn, NONE, blast_distance) \
	w_cvar(id, sn, NONE, blast_edgedamage) \
	w_cvar(id, sn, NONE, blast_force) \
	w_cvar(id, sn, NONE, blast_force_forwardbias) \
	w_cvar(id, sn, NONE, blast_force_zscale) \
	w_cvar(id, sn, NONE, blast_jump_damage) \
	w_cvar(id, sn, NONE, blast_jump_edgedamage) \
	w_cvar(id, sn, NONE, blast_jump_force) \
	w_cvar(id, sn, NONE, blast_jump_force_velocitybias) \
	w_cvar(id, sn, NONE, blast_jump_force_zscale) \
	w_cvar(id, sn, NONE, blast_jump_multiplier_accuracy) \
	w_cvar(id, sn, NONE, blast_jump_multiplier_distance) \
	w_cvar(id, sn, NONE, blast_jump_multiplier_min) \
	w_cvar(id, sn, NONE, blast_jump_radius) \
	w_cvar(id, sn, NONE, blast_multiplier_accuracy) \
	w_cvar(id, sn, NONE, blast_multiplier_distance) \
	w_cvar(id, sn, NONE, blast_multiplier_min) \
	w_cvar(id, sn, NONE, blast_refire) \
	w_cvar(id, sn, NONE, blast_splash_damage) \
	w_cvar(id, sn, NONE, blast_splash_edgedamage) \
	w_cvar(id, sn, NONE, blast_splash_force) \
	w_cvar(id, sn, NONE, blast_splash_force_forwardbias) \
	w_cvar(id, sn, NONE, blast_splash_multiplier_accuracy) \
	w_cvar(id, sn, NONE, blast_splash_multiplier_distance) \
	w_cvar(id, sn, NONE, blast_splash_multiplier_min) \
	w_cvar(id, sn, NONE, blast_splash_radius) \
	w_cvar(id, sn, NONE, blast_spread_max) \
	w_cvar(id, sn, NONE, blast_spread_min) \
	w_cvar(id, sn, NONE, melee_animtime) \
	w_cvar(id, sn, NONE, melee_damage) \
	w_cvar(id, sn, NONE, melee_delay) \
	w_cvar(id, sn, NONE, melee_force) \
	w_cvar(id, sn, NONE, melee_multihit) \
	w_cvar(id, sn, NONE, melee_no_doubleslap) \
	w_cvar(id, sn, NONE, melee_nonplayerdamage) \
	w_cvar(id, sn, NONE, melee_range) \
	w_cvar(id, sn, NONE, melee_refire) \
	w_cvar(id, sn, NONE, melee_swing_side) \
	w_cvar(id, sn, NONE, melee_swing_up) \
	w_cvar(id, sn, NONE, melee_time) \
	w_cvar(id, sn, NONE, melee_traces) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
SHOCKWAVE_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#ifdef CSQC
void Net_ReadShockwaveParticle(void);
.vector sw_shotorg;
.vector sw_shotdir;
.float sw_distance;
.float sw_spread_max;
.float sw_spread_min;
.float sw_time;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_shockwave(void)
{
	//if(autocvar_sv_q3acompat_machineshockwaveswap) // WEAPONTODO
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_MACHINEGUN);
		return;
	}
	weapon_defaultspawnfunc(WEP_SHOCKWAVE);
}

#define MAX_SHOCKWAVE_HITS 10
#define DEBUG_SHOCKWAVE

.float swing_prev;
.entity swing_alreadyhit;
.float shockwave_blasttime;
entity shockwave_hit[MAX_SHOCKWAVE_HITS];
float shockwave_hit_damage[MAX_SHOCKWAVE_HITS];
vector shockwave_hit_force[MAX_SHOCKWAVE_HITS];

// MELEE ATTACK MODE
void W_Shockwave_Melee_Think(void)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;

	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && WEP_CVAR(shockwave, melee_no_doubleslap))
	{
		remove(self);
		return;
	}

	// set start time of melee
	if(!self.cnt)
	{
		self.cnt = time; 
		W_PlayStrengthSound(self.realowner);
	}

	// update values for v_* vectors
	makevectors(self.realowner.v_angle);
	
	// calculate swing percentage based on time
	meleetime = WEP_CVAR(shockwave, melee_time) * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR(shockwave, melee_traces));
	
	// perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR(shockwave, melee_traces))) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * WEP_CVAR(shockwave, melee_range))
			+ (v_up * swing_factor * WEP_CVAR(shockwave, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR(shockwave, melee_swing_side)));

		WarpZone_traceline_antilag(
			self.realowner,
			(self.realowner.origin + self.realowner.view_ofs),
			targpos,
			FALSE,
			self.realowner,
			ANTILAG_LATENCY(self.realowner)
		);
		
		// draw lightning beams for debugging
		te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5); 
		te_customflash(targpos, 40,  2, '1 1 1');
		
		is_player = (trace_ent.classname == "player" || trace_ent.classname == "body" || (trace_ent.flags & FL_MONSTER));

		if((trace_fraction < 1) // if trace is good, apply the damage and remove self if necessary
			&& (trace_ent.takedamage == DAMAGE_AIM)  
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || WEP_CVAR(shockwave, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls
			
			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught
				swing_damage = (WEP_CVAR(shockwave, melee_damage) * min(1, swing_factor + 1));
			else
				swing_damage = (WEP_CVAR(shockwave, melee_nonplayerdamage) * min(1, swing_factor + 1));

			// trigger damage with this calculated info
			Damage(
				target_victim,
				self.realowner,
				self.realowner, 
				swing_damage,
				(WEP_SHOCKWAVE | HITTYPE_SECONDARY), 
				(self.realowner.origin + self.realowner.view_ofs), 
				(v_forward * WEP_CVAR(shockwave, melee_force))
			);

			// handle accuracy
			if(accuracy_isgooddamage(self.realowner, target_victim))
				{ accuracy_add(self.realowner, WEP_SHOCKWAVE, 0, swing_damage); }

			#ifdef DEBUG_SHOCKWAVE
			print(sprintf(
				"MELEE: %s hitting %s with %f damage (factor: %f) at %f time.\n",
				self.realowner.netname,
				target_victim.netname,
				swing_damage,
				swing_factor,
				time
			));
			#endif

			// allow multiple hits with one swing, but not against the same player twice
			if(WEP_CVAR(shockwave, melee_multihit))
			{
				self.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				remove(self);
				return;
			}
		}
	}
	
	if(time >= self.cnt + meleetime)
	{
		// melee is finished
		remove(self);
		return;
	}
	else
	{
		// set up next frame 
		self.swing_prev = i;
		self.nextthink = time;
	}
}

void W_Shockwave_Melee(void)
{
	sound(self, CH_WEAPON_A, "weapons/shotgun_melee.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(shockwave, melee_animtime), w_ready);

	entity meleetemp;
	meleetemp = spawn();
	meleetemp.owner = meleetemp.realowner = self;
	meleetemp.think = W_Shockwave_Melee_Think;
	meleetemp.nextthink = time + WEP_CVAR(shockwave, melee_delay) * W_WeaponRateFactor();
	W_SetupShot_Range(self, TRUE, 0, "", 0, WEP_CVAR(shockwave, melee_damage), WEP_CVAR(shockwave, melee_range));
}

// SHOCKWAVE ATTACK MODE
float W_Shockwave_Attack_CheckSpread(
	vector targetorg,
	vector nearest_on_line,
	vector sw_shotorg,
	vector attack_endpos)
{
	float spreadlimit;
	float distance_of_attack = vlen(sw_shotorg - attack_endpos);
	float distance_from_line = vlen(targetorg - nearest_on_line);
	
	spreadlimit = (distance_of_attack ? min(1, (vlen(sw_shotorg - nearest_on_line) / distance_of_attack)) : 1);
	spreadlimit =
		(
			(WEP_CVAR(shockwave, blast_spread_min) * (1 - spreadlimit))
			+
			(WEP_CVAR(shockwave, blast_spread_max) * spreadlimit)
		);

	if(
		(spreadlimit && (distance_from_line <= spreadlimit))
		&&
		((vlen(normalize(targetorg - sw_shotorg) - normalize(attack_endpos - sw_shotorg)) * RAD2DEG) <= 90)
	)
		{ return bound(0, (distance_from_line / spreadlimit), 1); }
	else
		{ return FALSE; }
}

float W_Shockwave_Attack_IsVisible(
	entity head,
	vector nearest_on_line,
	vector sw_shotorg,
	vector attack_endpos)
{
	vector nearest_to_attacker = head.WarpZone_findradius_nearest;
	vector center = (head.origin + (head.mins + head.maxs) * 0.5);
	vector corner;
	float i;

	// STEP ONE: Check if the nearest point is clear
	if(W_Shockwave_Attack_CheckSpread(nearest_to_attacker, nearest_on_line, sw_shotorg, attack_endpos))
	{
		WarpZone_TraceLine(sw_shotorg, nearest_to_attacker, MOVE_NOMONSTERS, self);
		if(trace_fraction == 1) { return TRUE; } // yes, the nearest point is clear and we can allow the damage
	}

	// STEP TWO: Check if shotorg to center point is clear
	if(W_Shockwave_Attack_CheckSpread(center, nearest_on_line, sw_shotorg, attack_endpos))
	{
		WarpZone_TraceLine(sw_shotorg, center, MOVE_NOMONSTERS, self);
		if(trace_fraction == 1) { return TRUE; } // yes, the center point is clear and we can allow the damage
	}

	// STEP THREE: Check each corner to see if they are clear
	for(i=1; i<=8; ++i)
	{
		corner = get_corner_position(head, i);
		if(W_Shockwave_Attack_CheckSpread(corner, nearest_on_line, sw_shotorg, attack_endpos))
		{
			WarpZone_TraceLine(sw_shotorg, corner, MOVE_NOMONSTERS, self);
			if(trace_fraction == 1) { return TRUE; } // yes, this corner is clear and we can allow the damage
		}
	}

	return FALSE;
}

float W_Shockwave_Attack_CheckHit(
	float queue,
	entity head,
	vector final_force,
	float final_damage)
{
	if(!head) { return FALSE; }
	float i;
	
	for(i = 0; i <= queue; ++i)
	{
		if(shockwave_hit[i] == head)
		{
			if(vlen(final_force) > vlen(shockwave_hit_force[i])) { shockwave_hit_force[i] = final_force; }
			if(final_damage > shockwave_hit_damage[i]) { shockwave_hit_damage[i] = final_damage; }
			return FALSE;
		}
	}

	shockwave_hit[queue] = head;
	shockwave_hit_force[queue] = final_force;
	shockwave_hit_damage[queue] = final_damage;
	return TRUE;
}

void W_Shockwave_Send(void)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_SHOCKWAVEPARTICLE);
	WriteCoord(MSG_BROADCAST, w_shotorg_x);
	WriteCoord(MSG_BROADCAST, w_shotorg_y);
	WriteCoord(MSG_BROADCAST, w_shotorg_z);
	WriteCoord(MSG_BROADCAST, w_shotdir_x);
	WriteCoord(MSG_BROADCAST, w_shotdir_y);
	WriteCoord(MSG_BROADCAST, w_shotdir_z);
	WriteShort(MSG_BROADCAST, WEP_CVAR(shockwave, blast_distance));
	WriteByte(MSG_BROADCAST, bound(0, WEP_CVAR(shockwave, blast_spread_max), 255));
	WriteByte(MSG_BROADCAST, bound(0, WEP_CVAR(shockwave, blast_spread_min), 255));
	WriteByte(MSG_BROADCAST, num_for_edict(self));
}

void W_Shockwave_Attack(void)
{
	// declarations
	float multiplier, multiplier_from_accuracy, multiplier_from_distance;
	float final_damage;
	vector final_force, center, vel;
	entity head;

	float i, queue = 0;
	
	// set up the shot direction
	W_SetupShot(self, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_B, WEP_CVAR(shockwave, blast_damage));
	vector attack_endpos = (w_shotorg + (w_shotdir * WEP_CVAR(shockwave, blast_distance)));
	WarpZone_TraceLine(w_shotorg, attack_endpos, MOVE_NOMONSTERS, self);
	vector attack_hitpos = trace_endpos;
	float distance_to_end = vlen(w_shotorg - attack_endpos);
	float distance_to_hit = vlen(w_shotorg - attack_hitpos);
	//entity transform = WarpZone_trace_transform;

	// do the firing effect now
	W_Shockwave_Send();
	Damage_DamageInfo(
		attack_hitpos,
		WEP_CVAR(shockwave, blast_splash_damage),
		WEP_CVAR(shockwave, blast_splash_edgedamage),
		WEP_CVAR(shockwave, blast_splash_radius),
		w_shotdir * WEP_CVAR(shockwave, blast_splash_force),
		WEP_SHOCKWAVE,
		0,
		self
	);

	// splash damage/jumping trace
	head = WarpZone_FindRadius(
		attack_hitpos,
		max(
			WEP_CVAR(shockwave, blast_splash_radius),
			WEP_CVAR(shockwave, blast_jump_radius)
		),
		FALSE
	);
	
	while(head)
	{
		if(head.takedamage)
		{
			float distance_to_head = vlen(attack_hitpos - head.WarpZone_findradius_nearest);
			
			if((head == self) && (distance_to_head <= WEP_CVAR(shockwave, blast_jump_radius)))
			{
				// ========================
				//  BLAST JUMP CALCULATION
				// ========================
				
				// calculate importance of distance and accuracy for this attack
				multiplier_from_accuracy = (1 -
					(distance_to_head ?
						min(1, (distance_to_head / WEP_CVAR(shockwave, blast_jump_radius)))
						:
						0
					)
				);
				multiplier_from_distance = (1 -
					(distance_to_hit ?
						min(1, (distance_to_hit / distance_to_end))
						:
						0
					)
				);
				multiplier =
					max(
						WEP_CVAR(shockwave, blast_jump_multiplier_min),
						(
							(multiplier_from_accuracy * WEP_CVAR(shockwave, blast_jump_multiplier_accuracy))
							+
							(multiplier_from_distance * WEP_CVAR(shockwave, blast_jump_multiplier_distance))
						)
					);

				// calculate damage from multiplier: 1 = "highest" damage, 0 = "lowest" edgedamage
				final_damage =
					(
						(WEP_CVAR(shockwave, blast_jump_damage) * multiplier)
						+
						(WEP_CVAR(shockwave, blast_jump_edgedamage) * (1 - multiplier))
					);

				// figure out the direction of force
				vel = normalize(combine_to_vector(head.velocity_x, head.velocity_y, 0));
				vel *=
					(
						bound(0, (vlen(vel) / autocvar_sv_maxspeed), 1)
						*
						WEP_CVAR(shockwave, blast_jump_force_velocitybias)
					);
				final_force = normalize((CENTER_OR_VIEWOFS(head) - attack_hitpos) + vel);

				// now multiply the direction by force units
				final_force *= (WEP_CVAR(shockwave, blast_jump_force) * multiplier);
				final_force_z *= WEP_CVAR(shockwave, blast_jump_force_zscale);

				// trigger damage with this calculated info
				Damage(
					head,
					self,
					self,
					final_damage,
					WEP_SHOCKWAVE,
					head.origin,
					final_force
				);

				#ifdef DEBUG_SHOCKWAVE
				print(sprintf(
					"SELF HIT: multiplier = %f, damage = %f, force = %f... "
					"multiplier_from_accuracy = %f, multiplier_from_distance = %f.\n",
					multiplier,
					final_damage,
					vlen(final_force),
					multiplier_from_accuracy,
					multiplier_from_distance
				));
				#endif
			}
			else if(distance_to_head <= WEP_CVAR(shockwave, blast_splash_radius))
			{
				// ==========================
				//  BLAST SPLASH CALCULATION
				// ==========================
				
				// calculate importance of distance and accuracy for this attack
				multiplier_from_accuracy = (1 -
					(distance_to_head ?
						min(1, (distance_to_head / WEP_CVAR(shockwave, blast_splash_radius)))
						:
						0
					)
				);
				multiplier_from_distance = (1 -
					(distance_to_hit ?
						min(1, (distance_to_hit / distance_to_end))
						:
						0
					)
				);
				multiplier =
					max(
						WEP_CVAR(shockwave, blast_splash_multiplier_min),
						(
							(multiplier_from_accuracy * WEP_CVAR(shockwave, blast_splash_multiplier_accuracy))
							+
							(multiplier_from_distance * WEP_CVAR(shockwave, blast_splash_multiplier_distance))
						)
					);

				// calculate damage from multiplier: 1 = "highest" damage, 0 = "lowest" edgedamage
				final_damage =
					(
						(WEP_CVAR(shockwave, blast_splash_damage) * multiplier)
						+
						(WEP_CVAR(shockwave, blast_splash_edgedamage) * (1 - multiplier))
					);

				// figure out the direction of force
				final_force = (w_shotdir * WEP_CVAR(shockwave, blast_splash_force_forwardbias));
				final_force = normalize(CENTER_OR_VIEWOFS(head) - (attack_hitpos - final_force));
				//te_lightning2(world, attack_hitpos, (attack_hitpos + (final_force * 200)));

				// now multiply the direction by force units
				final_force *= (WEP_CVAR(shockwave, blast_splash_force) * multiplier);
				final_force_z *= WEP_CVAR(shockwave, blast_force_zscale);

				// queue damage with this calculated info
				if(W_Shockwave_Attack_CheckHit(queue, head, final_force, final_damage)) { queue = min(queue + 1, MAX_SHOCKWAVE_HITS); }

				#ifdef DEBUG_SHOCKWAVE
				print(sprintf(
					"SPLASH HIT: multiplier = %f, damage = %f, force = %f... "
					"multiplier_from_accuracy = %f, multiplier_from_distance = %f.\n",
					multiplier,
					final_damage,
					vlen(final_force),
					multiplier_from_accuracy,
					multiplier_from_distance
				));
				#endif
			}
		}
		head = head.chain;
	}

	// cone damage trace
	head = WarpZone_FindRadius(w_shotorg, WEP_CVAR(shockwave, blast_distance), FALSE);
	while(head)
	{
		if((head != self) && head.takedamage)
		{
			// ========================
			//  BLAST CONE CALCULATION
			// ========================

			// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc) 
			center = CENTER_OR_VIEWOFS(head);

			// find the closest point on the enemy to the center of the attack
			float ang; // angle between shotdir and h
			float h; // hypotenuse, which is the distance between attacker to head
			float a; // adjacent side, which is the distance between attacker and the point on w_shotdir that is closest to head.origin
			
			h = vlen(center - self.origin);
			ang = acos(dotproduct(normalize(center - self.origin), w_shotdir));
			a = h * cos(ang);
			// WEAPONTODO: replace with simpler method

			vector nearest_on_line = (w_shotorg + a * w_shotdir);
			vector nearest_to_attacker = WarpZoneLib_NearestPointOnBox(center + head.mins, center + head.maxs, nearest_on_line);

			if((vlen(head.WarpZone_findradius_dist) <= WEP_CVAR(shockwave, blast_distance)) 
				&& (W_Shockwave_Attack_IsVisible(head, nearest_on_line, w_shotorg, attack_endpos)))
			{
				// calculate importance of distance and accuracy for this attack
				multiplier_from_accuracy = (1 -
					W_Shockwave_Attack_CheckSpread(
						nearest_to_attacker,
						nearest_on_line,
						w_shotorg,
						attack_endpos
					)
				);
				multiplier_from_distance = (1 -
					(distance_to_hit ?
						min(1, (vlen(head.WarpZone_findradius_dist) / distance_to_end))
						:
						0
					)
				);
				multiplier =
					max(
						WEP_CVAR(shockwave, blast_multiplier_min),
						(
							(multiplier_from_accuracy * WEP_CVAR(shockwave, blast_multiplier_accuracy))
							+
							(multiplier_from_distance * WEP_CVAR(shockwave, blast_multiplier_distance))
						)
					);

				// calculate damage from multiplier: 1 = "highest" damage, 0 = "lowest" edgedamage
				final_damage =
					(
						(WEP_CVAR(shockwave, blast_damage) * multiplier)
						+
						(WEP_CVAR(shockwave, blast_edgedamage) * (1 - multiplier))
					);

				// figure out the direction of force
				final_force = (w_shotdir * WEP_CVAR(shockwave, blast_force_forwardbias));
				final_force = normalize(center - (nearest_on_line - final_force));
				//te_lightning2(world, nearest_on_line, (attack_hitpos + (final_force * 200)));

				// now multiply the direction by force units
				final_force *= (WEP_CVAR(shockwave, blast_force) * multiplier);
				final_force_z *= WEP_CVAR(shockwave, blast_force_zscale);

				// queue damage with this calculated info
				if(W_Shockwave_Attack_CheckHit(queue, head, final_force, final_damage)) { queue = min(queue + 1, MAX_SHOCKWAVE_HITS); }

				#ifdef DEBUG_SHOCKWAVE
				print(sprintf(
					"BLAST HIT: multiplier = %f, damage = %f, force = %f... "
					"multiplier_from_accuracy = %f, multiplier_from_distance = %f.\n",
					multiplier,
					final_damage,
					vlen(final_force),
					multiplier_from_accuracy,
					multiplier_from_distance
				));
				#endif
			}
		}
		head = head.chain;
	}

	for(i = 1; i <= queue; ++i)
	{
		head = shockwave_hit[i-1];
		final_force = shockwave_hit_force[i-1];
		final_damage = shockwave_hit_damage[i-1];
		
		Damage(
			head,
			self,
			self,
			final_damage,
			WEP_SHOCKWAVE,
			head.origin,
			final_force
		);

		if(accuracy_isgooddamage(self.realowner, head))
		{
			print("wtf\n");
			accuracy_add(self.realowner, WEP_SHOCKWAVE, 0, final_damage);
		}

		#ifdef DEBUG_SHOCKWAVE
		print(sprintf(
			"SHOCKWAVE by %s: damage = %f, force = %f.\n",
			self.netname,
			final_damage,
			vlen(final_force)
		));
		#endif
		
		shockwave_hit[i-1] = world;
		shockwave_hit_force[i-1] = '0 0 0';
		shockwave_hit_damage[i-1] = 0;
	}
}

float W_Shockwave(float req)
{
	switch(req)
	{
		case WR_AIM:
		{
			if(vlen(self.origin - self.enemy.origin) <= WEP_CVAR(shockwave, melee_range))
				{ self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE); }
			else
				{ self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE); }
			
			return TRUE;
		}
		case WR_THINK:
		{
			if(self.BUTTON_ATCK)
			{
				if(time >= self.shockwave_blasttime) // handle refire separately so the secondary can be fired straight after a primary
				{
					if(weapon_prepareattack(0, WEP_CVAR(shockwave, blast_animtime)))
					{
						W_Shockwave_Attack();
						self.shockwave_blasttime = time + WEP_CVAR(shockwave, blast_refire) * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(shockwave, blast_animtime), w_ready);
					}
				}
			}
			else if(self.BUTTON_ATCK2)
			{
				//if(self.clip_load >= 0) // we are not currently reloading
				if(!self.crouch) // no crouchmelee please
				if(weapon_prepareattack(1, WEP_CVAR(shockwave, melee_refire)))
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_Shockwave_Melee);
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/uziflash.md3");
			precache_model("models/weapons/g_shockwave.md3");
			precache_model("models/weapons/v_shockwave.md3");
			precache_model("models/weapons/h_shockwave.iqm");
			precache_sound("misc/itempickup.wav");
			precache_sound("weapons/shockwave_fire.wav");
			precache_sound("weapons/shockwave_melee.wav");
			SHOCKWAVE_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		case WR_CHECKAMMO2:
		{
			// shockwave has infinite ammo
			return TRUE;
		}
		case WR_CONFIG:
		{
			SHOCKWAVE_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_SHOCKWAVE_MURDER_SLAP;
			else
				return WEAPON_SHOCKWAVE_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
// WEAPONTODO: add client side settings for these
#define SW_MAXALPHA 0.5
#define SW_FADETIME 0.4
#define SW_DISTTOMIN 200
void Draw_Shockwave()
{
	// fading/removal control
	float a = bound(0, (SW_MAXALPHA - ((time - self.sw_time) / SW_FADETIME)), SW_MAXALPHA);
	if(a < ALPHA_MIN_VISIBLE) { remove(self); }

	// WEAPONTODO: save this only once when creating the entity
	vector sw_color = getcsqcplayercolor(self.sv_entnum); // GetTeamRGB(GetPlayerColor(self.sv_entnum));

	// WEAPONTODO: trace to find what we actually hit
	vector endpos = (self.sw_shotorg + (self.sw_shotdir * self.sw_distance));

	vectorvectors(self.sw_shotdir);
	vector right = v_right; // save this for when we do makevectors later
	vector up = v_up; // save this for when we do makevectors later

	// WEAPONTODO: combine and simplify these calculations
	vector min_end = ((self.sw_shotorg + (self.sw_shotdir * SW_DISTTOMIN)) + (up * self.sw_spread_min));
	vector max_end = (endpos + (up * self.sw_spread_max));
	float spread_to_min = vlen(normalize(min_end - self.sw_shotorg) - self.sw_shotdir);
	float spread_to_max = vlen(normalize(max_end - min_end) - self.sw_shotdir);

	vector first_min_end = '0 0 0', prev_min_end = '0 0 0', new_min_end = '0 0 0';
	vector first_max_end = '0 0 0', prev_max_end = '0 0 0', new_max_end = '0 0 0';
	float new_max_dist, new_min_dist;

	vector deviation, angle = '0 0 0';
	float counter, divisions = 20;
	for(counter = 0; counter < divisions; ++counter)
	{
		// perfect circle effect lines
		makevectors('0 360 0' * (0.75 + (counter - 0.5) / divisions));
		angle_y = v_forward_x;
		angle_z = v_forward_y;

		// first do the spread_to_min effect
		deviation = angle * spread_to_min;
		deviation = ((self.sw_shotdir + (right * deviation_y) + (up * deviation_z)));
		new_min_dist = SW_DISTTOMIN;
		new_min_end = (self.sw_shotorg + (deviation * new_min_dist));
		//te_lightning2(world, new_min_end, self.sw_shotorg);

		// then calculate spread_to_max effect
		deviation = angle * spread_to_max;
		deviation = ((self.sw_shotdir + (right * deviation_y) + (up * deviation_z)));
		new_max_dist = vlen(new_min_end - endpos);
		new_max_end = (new_min_end + (deviation * new_max_dist));
		//te_lightning2(world, new_end, prev_min_end);
		

		if(counter == 0)
		{
			first_min_end = new_min_end;
			first_max_end = new_max_end;
		}

		if(counter >= 1)
		{
			// draw from shot origin to min spread radius
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(new_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(self.sw_shotorg, '0 0 0', sw_color, a);
			R_EndPolygon();

			// draw from min spread radius to max spread radius
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(new_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_max_end, '0 0 0', sw_color, a);
			R_PolygonVertex(new_max_end, '0 0 0', sw_color, a);
			R_EndPolygon();
		}

		prev_min_end = new_min_end;
		prev_max_end = new_max_end;

		// last division only
		if((counter + 1) == divisions)
		{
			// draw from shot origin to min spread radius
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(first_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(self.sw_shotorg, '0 0 0', sw_color, a);
			R_EndPolygon();

			// draw from min spread radius to max spread radius
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(first_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_max_end, '0 0 0', sw_color, a);
			R_PolygonVertex(first_max_end, '0 0 0', sw_color, a);
			R_EndPolygon();
		}
	}
}

void Net_ReadShockwaveParticle(void)
{
	entity shockwave;
	shockwave = spawn();
	shockwave.draw = Draw_Shockwave;
	
	shockwave.sw_shotorg_x = ReadCoord(); shockwave.sw_shotorg_y = ReadCoord(); shockwave.sw_shotorg_z = ReadCoord();
	shockwave.sw_shotdir_x  = ReadCoord(); shockwave.sw_shotdir_y  = ReadCoord(); shockwave.sw_shotdir_z  = ReadCoord();

	shockwave.sw_distance = ReadShort();
	shockwave.sw_spread_max = ReadByte();
	shockwave.sw_spread_min = ReadByte();

	shockwave.sv_entnum = ReadByte();

	shockwave.sw_time = time;
}

float W_Shockwave(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			// handled by Net_ReadShockwaveParticle
			//vector org2;
			//org2 = w_org + w_backoff * 2;
			//pointparticles(particleeffectnum("laser_impact"), org2, w_backoff * 1000, 1);
			return FALSE;
		}
		case WR_INIT:
		{
			//precache_sound("weapons/ric1.wav");
			//precache_sound("weapons/ric2.wav");
			//precache_sound("weapons/ric3.wav");
			return FALSE;
		}
		case WR_ZOOMRETICLE:
		{
			// no weapon specific image for this weapon
			return FALSE;
		}
	}
	return FALSE;
}
#endif
#endif
