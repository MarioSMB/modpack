#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ VAPORIZER,
/* function  */ W_Vaporizer,
/* ammotype  */ ammo_cells,
/* impulse   */ 7,
/* flags     */ WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_FLAG_SUPERWEAPON | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_HIGH,
/* color     */ '0.5 1 1',
/* modelname */ "minstanex",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairminstanex 0.4",
/* wepimg    */ "weaponminstanex",
/* refname   */ "vaporizer",
/* wepname   */ _("Vaporizer")
);

#define VAPORIZER_SETTINGS(w_cvar,w_prop) VAPORIZER_SETTINGS_LIST(w_cvar, w_prop, VAPORIZER, vaporizer)
#define VAPORIZER_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, PRI,  ammo) \
	w_cvar(id, sn, PRI,  animtime) \
	w_cvar(id, sn, PRI,  damage) \
	w_cvar(id, sn, PRI,  refire) \
	w_cvar(id, sn, SEC,  ammo) \
	w_cvar(id, sn, SEC,  animtime) \
	w_cvar(id, sn, SEC,  damage) \
	w_cvar(id, sn, SEC,  delay) \
	w_cvar(id, sn, SEC,  edgedamage) \
	w_cvar(id, sn, SEC,  force) \
	w_cvar(id, sn, SEC,  lifetime) \
	w_cvar(id, sn, SEC,  radius) \
	w_cvar(id, sn, SEC,  refire) \
	w_cvar(id, sn, SEC,  shotangle) \
	w_cvar(id, sn, SEC,  speed) \
	w_cvar(id, sn, SEC,  spread) \
	w_cvar(id, sn, NONE, superblast) \
	w_cvar(id, sn, NONE, superblast_distance) \
	w_cvar(id, sn, NONE, superblast_force) \
	w_cvar(id, sn, NONE, superblast_force_forwardbias) \
	w_cvar(id, sn, NONE, superblast_force_zscale) \
	w_cvar(id, sn, NONE, superblast_multiplier_accuracy) \
	w_cvar(id, sn, NONE, superblast_multiplier_distance) \
	w_cvar(id, sn, NONE, superblast_multiplier_min) \
	w_cvar(id, sn, NONE, superblast_jump_damage) \
	w_cvar(id, sn, NONE, superblast_jump_edgedamage) \
	w_cvar(id, sn, NONE, superblast_jump_force) \
	w_cvar(id, sn, NONE, superblast_jump_force_velocitybias) \
	w_cvar(id, sn, NONE, superblast_jump_force_zscale) \
	w_cvar(id, sn, NONE, superblast_jump_multiplier_accuracy) \
	w_cvar(id, sn, NONE, superblast_jump_multiplier_distance) \
	w_cvar(id, sn, NONE, superblast_jump_multiplier_min) \
	w_cvar(id, sn, NONE, superblast_jump_radius) \
	w_cvar(id, sn, NONE, superblast_spread_max) \
	w_cvar(id, sn, NONE, superblast_spread_min) \
	w_cvar(id, sn, NONE, superblast_splash_damage) \
	w_cvar(id, sn, NONE, superblast_splash_edgedamage) \
	w_cvar(id, sn, NONE, superblast_splash_force) \
	w_cvar(id, sn, NONE, superblast_splash_force_forwardbias) \
	w_cvar(id, sn, NONE, superblast_splash_force_zscale) \
	w_cvar(id, sn, NONE, superblast_splash_multiplier_accuracy) \
	w_cvar(id, sn, NONE, superblast_splash_multiplier_distance) \
	w_cvar(id, sn, NONE, superblast_splash_multiplier_min) \
	w_cvar(id, sn, NONE, superblast_splash_radius) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
VAPORIZER_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.float vaporizer_lasthit;
.float jump_interval;
.float jump_interval2;
.float held_down;
.float vaporizer_held_down;
.float vaporizer_jumpinterval;
.float superrocket_lasthit;
.float rm_force;
.float rm_damage;
.float rm_edmg;
#endif
#ifdef CSQC
void Net_ReadSuperBlastParticle();
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_vaporizer(void) { weapon_defaultspawnfunc(WEP_VAPORIZER); }
void spawnfunc_weapon_minstanex(void) { spawnfunc_weapon_vaporizer(); }

void SendCSQCSuperBlastParticle(vector endpos)
{
	//endpos = WarpZone_UnTransformOrigin(transform, endpos);
	
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_SUPERBLASTPARTICLE);
	WriteCoord(MSG_BROADCAST, w_shotorg_x);
	WriteCoord(MSG_BROADCAST, w_shotorg_y);
	WriteCoord(MSG_BROADCAST, w_shotorg_z);
	WriteCoord(MSG_BROADCAST, endpos_x);
	WriteCoord(MSG_BROADCAST, endpos_y);
	WriteCoord(MSG_BROADCAST, endpos_z);
	WriteByte(MSG_BROADCAST, bound(0, WEP_CVAR(vaporizer, superblast_spread_max), 255));
	WriteByte(MSG_BROADCAST, bound(0, WEP_CVAR(vaporizer, superblast_spread_min), 255));
	WriteByte(MSG_BROADCAST, num_for_edict(self));
}

float W_Vaporizer_SuperBlast_CheckSpread(vector targetorg, vector nearest_on_line, vector sw_shotorg, vector attack_endpos)
{
	float spreadlimit;
	float distance_of_attack = vlen(sw_shotorg - attack_endpos);
	float distance_from_line = vlen(targetorg - nearest_on_line);
	
	spreadlimit = (distance_of_attack ? min(1, (vlen(sw_shotorg - nearest_on_line) / distance_of_attack)) : 1);
	spreadlimit = (WEP_CVAR(vaporizer, superblast_spread_min) * (1 - spreadlimit) + WEP_CVAR(vaporizer, superblast_spread_max) * spreadlimit);
	
	if(spreadlimit && (distance_from_line <= spreadlimit) && ((vlen(normalize(targetorg - sw_shotorg) - normalize(attack_endpos - sw_shotorg)) * RAD2DEG) <= 90))
		return bound(0, (distance_from_line / spreadlimit), 1);
	else
		return FALSE;
}

float W_Vaporizer_SuperBlast_IsVisible(entity head, vector nearest_on_line, vector sw_shotorg, vector attack_endpos)
{
	vector nearest_to_attacker = head.WarpZone_findradius_nearest;
	vector center = (head.origin + (head.mins + head.maxs) * 0.5);
	vector corner;
	float i;

	// STEP ONE: Check if the nearest point is clear
	if(W_Vaporizer_SuperBlast_CheckSpread(nearest_to_attacker, nearest_on_line, sw_shotorg, attack_endpos))
	{
		WarpZone_TraceLine(sw_shotorg, nearest_to_attacker, MOVE_NOMONSTERS, self);
		if(trace_fraction == 1) { return TRUE; } // yes, the nearest point is clear and we can allow the damage
	}

	// STEP TWO: Check if shotorg to center point is clear
	if(W_Vaporizer_SuperBlast_CheckSpread(center, nearest_on_line, sw_shotorg, attack_endpos))
	{
		WarpZone_TraceLine(sw_shotorg, center, MOVE_NOMONSTERS, self);
		if(trace_fraction == 1) { return TRUE; } // yes, the center point is clear and we can allow the damage
	}

	// STEP THREE: Check each corner to see if they are clear
	for(i=1; i<=8; ++i)
	{
		corner = get_corner_position(head, i);
		if(W_Vaporizer_SuperBlast_CheckSpread(corner, nearest_on_line, sw_shotorg, attack_endpos))
		{
			WarpZone_TraceLine(sw_shotorg, corner, MOVE_NOMONSTERS, self);
			if(trace_fraction == 1) { return TRUE; } // yes, this corner is clear and we can allow the damage
		}
	}

	return FALSE;
}

entity shockwave_hit[32];
float shockwave_hit_damage[32];
vector shockwave_hit_force[32];

float W_Vaporizer_SuperBlast_CheckHit(float queue, entity head, vector final_force, float final_damage)
{
	if(!head) { return FALSE; }
	float i;

	++queue;
	
	for(i = 1; i <= queue; ++i)
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

void W_RocketMinsta_Explosion(vector loc)
{
	pointparticles(particleeffectnum("rocket_explode"), loc, '0 0 0', 1);
	
	if(accuracy_canbegooddamage(self))
		accuracy_add(self, WEP_DEVASTATOR, autocvar_g_rm_damage, 0);

	// declarations
	float multiplier, multiplier_from_accuracy;
	float final_damage = 0; //, final_spread;
	vector final_force, center;
	entity head, next;
	
	float i, queue = 0;
	
	// splash damage/jumping trace
	head = WarpZone_FindRadius(loc, autocvar_g_rm_radius, FALSE);
	while(head)
	{
		next = head.chain;

		if(head.takedamage)
		{
			// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc)
			//center = CENTER_OR_VIEWOFS(head);
			center = WarpZone_UnTransformOrigin(head, CENTER_OR_VIEWOFS(head));

			float distance_to_head = vlen(loc - head.WarpZone_findradius_nearest);
			
			if (distance_to_head <= autocvar_g_rm_radius || head == self)
			{
				multiplier_from_accuracy = (1 - (distance_to_head ? min(1, (distance_to_head / autocvar_g_rm_radius)) : 0));
				multiplier = max(autocvar_g_rm_damage_multiplier_min, multiplier_from_accuracy * autocvar_g_rm_damage_multiplier_accuracy);

				final_force = normalize(center - loc);
				if(head == self)
					final_force = (final_force * autocvar_g_rm_force);
				else
					final_force = ((final_force * autocvar_g_rm_force) * multiplier);
					
				final_damage = (autocvar_g_rm_damage * multiplier + autocvar_g_rm_edgedamage * (1 - multiplier));

				if(W_Vaporizer_SuperBlast_CheckHit(queue, head, final_force, final_damage)) { ++queue; }
			}
		}
		head = next;
	}

	for(i = 1; i <= queue; ++i)
	{
		head = shockwave_hit[i];
		final_force = shockwave_hit_force[i];
		final_damage = shockwave_hit_damage[i];

		if(accuracy_isgooddamage(self, head))
			accuracy_add(self, WEP_DEVASTATOR, 0, final_damage);
		
		Damage(head, self, self, final_damage, (WEP_DEVASTATOR | HITTYPE_SPLASH), head.origin, final_force);
		//print("SHOCKWAVE by ", self.netname, ": damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force)), ".\n");

		shockwave_hit[i] = world;
		shockwave_hit_force[i] = '0 0 0';
		shockwave_hit_damage[i] = 0;
	}
}

void W_Vaporizer_Attack(void)
{
	float flying, vaporizer_damage;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last
	vaporizer_damage = ((WEP_CVAR_PRI(vaporizer, damage) > 0) ? WEP_CVAR_PRI(vaporizer, damage) : 10000);

	W_SetupShot(self, TRUE, 0, "", CH_WEAPON_A, vaporizer_damage);
	sound (self, CH_WEAPON_A, "weapons/minstanexfire.wav", VOL_BASE * 0.8, ATTEN_NORM);

	yoda = 0;
	damage_goodhits = 0;
	FireRailgunBullet(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, vaporizer_damage, 800, 0, 0, 0, 0, WEP_VAPORIZER);

	if(yoda && flying)
		Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_ACHIEVEMENT_YODA);
	if(damage_goodhits && self.vaporizer_lasthit)
	{
		Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_ACHIEVEMENT_IMPRESSIVE);
		damage_goodhits = 0; // only every second time
	}

	self.vaporizer_lasthit = damage_goodhits;

	pointparticles(particleeffectnum("nex_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	// teamcolor / hit beam effect
	vector v;
	string s;
	v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	s = strcat("TE_TEI_G3", Static_Team_ColorName_Upper(self.team), ((damage_goodhits) ? "_HIT" : ""));
	
	if(autocvar_g_rm)
	if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
		W_RocketMinsta_Explosion(trace_endpos);
		
	WarpZone_TrailParticles(world, particleeffectnum(s), w_shotorg, v);
	
	W_DecreaseAmmo(((g_minstagib) ? 1 : WEP_CVAR_PRI(vaporizer, ammo)));
}

void W_Vaporizer_SuperBlast()
{
	// declarations
	float multiplier, multiplier_from_accuracy, multiplier_from_distance;
	float final_damage; //, final_spread;
	vector final_force, center, vel;
	entity head, next;

	float i, queue = 0;
	
	// set up the shot direction
	W_SetupShot(self, FALSE, 3, "weapons/minstanex_charge2.wav", CH_WEAPON_B, WEP_CVAR_PRI(vaporizer, damage));
	vector attack_endpos = (w_shotorg + (w_shotdir * WEP_CVAR(vaporizer, superblast_distance)));
	WarpZone_TraceLine(w_shotorg, attack_endpos, MOVE_NOMONSTERS, self);
	vector attack_hitpos = trace_endpos;
	float distance_to_end = vlen(w_shotorg - attack_endpos);
	float distance_to_hit = vlen(w_shotorg - attack_hitpos);
	//entity transform = WarpZone_trace_transform;

	// do the firing effect now
	SendCSQCSuperBlastParticle(attack_endpos);
	Damage_DamageInfo(attack_hitpos, WEP_CVAR(vaporizer, superblast_splash_damage), WEP_CVAR(vaporizer, superblast_splash_edgedamage), WEP_CVAR(vaporizer, superblast_splash_radius), w_shotdir * WEP_CVAR(vaporizer, superblast_splash_force), (WEP_VAPORIZER | HITTYPE_SPLASH), 0, self);

	// splash damage/jumping trace
	head = WarpZone_FindRadius(attack_hitpos, max(WEP_CVAR(vaporizer, superblast_splash_radius), WEP_CVAR(vaporizer, superblast_jump_radius)), FALSE);
	while(head)
	{
		next = head.chain;

		if(head.takedamage)
		{
			// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc)
			center = CENTER_OR_VIEWOFS(head);

			float distance_to_head = vlen(attack_hitpos - head.WarpZone_findradius_nearest);
			
			if((head == self) && (distance_to_head <= WEP_CVAR(vaporizer, superblast_jump_radius)))
			{
				multiplier_from_accuracy = (1 - (distance_to_head ? min(1, (distance_to_head / WEP_CVAR(vaporizer, superblast_jump_radius))) : 0));
				multiplier_from_distance = (1 - (distance_to_hit ? min(1, (distance_to_hit / distance_to_end)) : 0));
				multiplier = max(WEP_CVAR(vaporizer, superblast_jump_multiplier_min), ((multiplier_from_accuracy * WEP_CVAR(vaporizer, superblast_jump_multiplier_accuracy)) + (multiplier_from_distance * WEP_CVAR(vaporizer, superblast_jump_multiplier_distance))));

				final_force = ((normalize(center - attack_hitpos) * WEP_CVAR(vaporizer, superblast_jump_force)) * multiplier);
				vel = head.velocity; vel_z = 0;
				vel = normalize(vel) * bound(0, vlen(vel) / autocvar_sv_maxspeed, 1) * WEP_CVAR(vaporizer, superblast_jump_force_velocitybias);
				final_force = (vlen(final_force) * normalize(normalize(final_force) + vel));
				final_force_z *= WEP_CVAR(vaporizer, superblast_jump_force_zscale);
				final_damage = (WEP_CVAR(vaporizer, superblast_jump_damage) * multiplier + WEP_CVAR(vaporizer, superblast_jump_edgedamage) * (1 - multiplier));

				Damage(head, self, self, final_damage, (WEP_VAPORIZER | HITTYPE_SPLASH), head.origin, final_force);
				//print("SELF HIT: multiplier = ", ftos(multiplier), strcat(", damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force))),"... multiplier_from_accuracy = ", ftos(multiplier_from_accuracy), ", multiplier_from_distance = ", ftos(multiplier_from_distance), ".\n");
			}
			else if (distance_to_head <= WEP_CVAR(vaporizer, superblast_splash_radius))
			{	
				multiplier_from_accuracy = (1 - (distance_to_head ? min(1, (distance_to_head / WEP_CVAR(vaporizer, superblast_splash_radius))) : 0));
				multiplier_from_distance = (1 - (distance_to_hit ? min(1, (distance_to_hit / distance_to_end)) : 0));
				multiplier = max(WEP_CVAR(vaporizer, superblast_splash_multiplier_min), ((multiplier_from_accuracy * WEP_CVAR(vaporizer, superblast_splash_multiplier_accuracy)) + (multiplier_from_distance * WEP_CVAR(vaporizer, superblast_splash_multiplier_distance))));

				final_force = normalize(center - (attack_hitpos - (w_shotdir * WEP_CVAR(vaporizer, superblast_splash_force_forwardbias))));
				//te_lightning2(world, attack_hitpos, (attack_hitpos + (final_force * 200)));
				final_force = ((final_force * WEP_CVAR(vaporizer, superblast_splash_force)) * multiplier);
				final_force_z *= WEP_CVAR(vaporizer, superblast_splash_force_zscale);
				final_damage = (WEP_CVAR(vaporizer, superblast_splash_damage) * multiplier + WEP_CVAR(vaporizer, superblast_splash_edgedamage) * (1 - multiplier));

				if(W_Vaporizer_SuperBlast_CheckHit(queue, head, final_force, final_damage)) { ++queue; }
				//print("SPLASH HIT: multiplier = ", ftos(multiplier), strcat(", damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force))),"... multiplier_from_accuracy = ", ftos(multiplier_from_accuracy), ", multiplier_from_distance = ", ftos(multiplier_from_distance), ".\n");
			}
		}
		head = next;
	}

	// cone damage trace
	head = WarpZone_FindRadius(w_shotorg, WEP_CVAR(vaporizer, superblast_distance), FALSE);
	while(head)
	{
		next = head.chain;
		
		if((head != self) && head.takedamage)
		{
			// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc) 
			center = CENTER_OR_VIEWOFS(head);

			// find the closest point on the enemy to the center of the attack
			float ang; // angle between shotdir and h
			float h; // hypotenuse, which is the distance between attacker to head
			float a; // adjacent side, which is the distance between attacker and the point on w_shotdir that is closest to head.origin
			
			h = vlen(center - self.origin);
			ang = acos(dotproduct(normalize(center - self.origin), w_shotdir));
			a = h * cos(ang);

			vector nearest_on_line = (w_shotorg + a * w_shotdir);
			vector nearest_to_attacker = WarpZoneLib_NearestPointOnBox(center + head.mins, center + head.maxs, nearest_on_line);
			float distance_to_target = vlen(w_shotorg - nearest_to_attacker); // todo: use the findradius function for this

			if((distance_to_target <= WEP_CVAR(vaporizer, superblast_distance)) 
				&& (W_Vaporizer_SuperBlast_IsVisible(head, nearest_on_line, w_shotorg, attack_endpos)))
			{
				multiplier_from_accuracy = (1 - W_Vaporizer_SuperBlast_CheckSpread(nearest_to_attacker, nearest_on_line, w_shotorg, attack_endpos));
				multiplier_from_distance = (1 - (distance_to_hit ? min(1, (distance_to_target / distance_to_end)) : 0));
				multiplier = max(WEP_CVAR(vaporizer, superblast_multiplier_min), ((multiplier_from_accuracy * WEP_CVAR(vaporizer, superblast_multiplier_accuracy)) + (multiplier_from_distance * WEP_CVAR(vaporizer, superblast_multiplier_distance))));

				final_force = normalize(center - (nearest_on_line - (w_shotdir * WEP_CVAR(vaporizer, superblast_force_forwardbias))));
				//te_lightning2(world, nearest_on_line, (attack_hitpos + (final_force * 200)));
				final_force = ((final_force * WEP_CVAR(vaporizer, superblast_force)) * multiplier);
				final_force_z *= WEP_CVAR(vaporizer, superblast_force_zscale);
				final_damage = (WEP_CVAR_PRI(vaporizer, damage) * multiplier + WEP_CVAR_PRI(vaporizer, damage) * (1 - multiplier));

				if(W_Vaporizer_SuperBlast_CheckHit(queue, head, final_force, final_damage)) { ++queue; }
				//print("CONE HIT: multiplier = ", ftos(multiplier), strcat(", damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force))),"... multiplier_from_accuracy = ", ftos(multiplier_from_accuracy), ", multiplier_from_distance = ", ftos(multiplier_from_distance), ".\n");
			}
		}
		head = next;
	}

	for(i = 1; i <= queue; ++i)
	{
		head = shockwave_hit[i];
		final_force = shockwave_hit_force[i];
		final_damage = shockwave_hit_damage[i];
		
		Damage(head, self, self, final_damage, (WEP_VAPORIZER | HITTYPE_SPLASH), head.origin, final_force);
		
		if(accuracy_isgooddamage(self, head))
			accuracy_add(self, WEP_VAPORIZER, 1, final_damage);
		//print("SHOCKWAVE by ", self.netname, ": damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force)), ".\n");
		
		shockwave_hit[i] = world;
		shockwave_hit_force[i] = '0 0 0';
		shockwave_hit_damage[i] = 0;
	}
	//print("queue was ", ftos(queue), ".\n\n");
	
	self.ammo_supercells -= 1;
}

float W_Vaporizer_SuperBlast_CheckAmmo()
{
	if(WEP_CVAR(vaporizer, superblast) == 3)
		return TRUE; // forced
	float ammo_amount;
	ammo_amount = self.ammo_supercells >= 1;
	ammo_amount += self.(weapon_load[WEP_VAPORIZER]) >= 1;
	return ammo_amount;
}

void W_RocketMinsta_SuperRocket_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, 250, 250, 250, world, world, 250, self.projectiledeathtype, other);

	remove (self);
}

void W_RocketMinsta_SuperRocket_Think (void)
{
	self.nextthink = time;
	makevectors(self.angles);
	self.velocity = v_forward * autocvar_g_rm_superrocket_speed;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_RocketMinsta_SuperRocket_Explode ();
		return;
	}
}

void W_RocketMinsta_SuperRocket_Touch (void)
{
	if(other.takedamage == DAMAGE_AIM && other.classname != "object" && time > other.superrocket_lasthit)
	{
		float minstanex_damage = ((WEP_CVAR_PRI(vaporizer, damage)) ? WEP_CVAR_PRI(vaporizer, damage) : 10000);
		Damage(other, self, self.realowner, minstanex_damage, WEP_DEVASTATOR, other.origin, '0 0 0');
		other.superrocket_lasthit = time + 1;
		return;
	}
	W_RocketMinsta_SuperRocket_Explode();
}

void W_RocketMinsta_SuperRocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_RocketMinsta_SuperRocket_Explode);
}

void W_RocketMinsta_SuperRocket()
{
	entity missile;
	float minstanex_damage = ((WEP_CVAR_PRI(vaporizer, damage)) ? WEP_CVAR_PRI(vaporizer, damage) : 10000);
	
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '-32 -32 -32', '32 32 32', FALSE, 5, "weapons/minstanex_charge2.wav", CH_WEAPON_A, minstanex_damage);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = missile.realowner = self;
	missile.classname = "rocket";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = minstanex_damage;

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 0;
	missile.health = 350;
	missile.event_damage = W_RocketMinsta_SuperRocket_Damage;
	missile.damagedbycontents = TRUE;

	missile.movetype = MOVETYPE_FLYMISSILE;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_DEVASTATOR;
	setsize (missile, '-32 -32 -32', '32 32 32'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjVelocity_Basic(missile, autocvar_g_rm_superrocket_speed, 0);
	missile.angles = self.v_angle;

	missile.touch = W_RocketMinsta_SuperRocket_Touch;
	missile.think = W_RocketMinsta_SuperRocket_Think;
	missile.nextthink = time;
	missile.cnt = time + 10;
	missile.flags = FL_PROJECTILE;
	//missile.missile_flags = MIF_SPLASH;

	CSQCProjectile(missile, TRUE, PROJECTILE_SUPERROCKET, FALSE); // because of fly sound
	
	self.ammo_supercells -= 1;
}

void W_RocketMinsta_Laser_Explode (void)
{
	if(other.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(other))
			if(DIFF_TEAM(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						Send_Notification(NOTIF_ONE, self.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_ELECTROBITCH);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	RadiusDamage (self, self.realowner, self.rm_damage, self.rm_edmg, autocvar_g_rm_laser_radius, world, world, self.rm_force, self.projectiledeathtype, other);
	remove(self);
}

void W_RocketMinsta_Laser_Touch (void)
{
	PROJECTILE_TOUCH;
	//W_RocketMinsta_Laser_Explode ();
	RadiusDamage (self, self.realowner, self.rm_damage, self.rm_edmg, autocvar_g_rm_laser_radius, world, world, self.rm_force, self.projectiledeathtype, other);
	remove(self);
}

void W_RocketMinsta_Attack2(void)
{
	makevectors(self.v_angle);
	
	entity proj;
	float counter = 0;
	float total = autocvar_g_rm_laser_count;
	float spread = autocvar_g_rm_laser_spread;
	float rndspread = autocvar_g_rm_laser_spread_random;

	float w = self.weapon;
	self.weapon = WEP_ELECTRO;
	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, autocvar_g_rm_laser_damage);
	self.weapon = w;
	
	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

    while(counter < total)
	{
        proj = spawn ();
        proj.classname = "plasma_prim";
        proj.owner = proj.realowner = self;
        proj.bot_dodge = TRUE;
        proj.bot_dodgerating = autocvar_g_rm_laser_damage;
        proj.use = W_RocketMinsta_Laser_Explode;
        proj.think = adaptor_think2use_hittype_splash;
        proj.nextthink = time + autocvar_g_rm_laser_lifetime;
        PROJECTILE_MAKETRIGGER(proj);
        proj.projectiledeathtype = WEP_ELECTRO;
        setorigin(proj, w_shotorg);
		
		proj.rm_force = autocvar_g_rm_laser_force / total;
		proj.rm_damage = autocvar_g_rm_laser_damage / total;
		proj.rm_edmg = proj.rm_damage;
        
        //W_SetupProjectileVelocity(proj, autocvar_g_rm_laser_speed, spread * (rndspread ? random() : 1) * autocvar_g_rm_laser_speed);

        proj.movetype = MOVETYPE_BOUNCEMISSILE;
        //W_SETUPPROJECTILEVELOCITY(proj, g_balance_minstanex_laser);
		proj.velocity = (w_shotdir + (((counter + 0.5) / total) * 2 - 1) * v_right * (spread * (rndspread ? random() : 1))) * cvar("g_rm_laser_speed");
		proj.velocity_z = proj.velocity_z + cvar("g_rm_laser_zspread") * (random() - 0.5);
		proj.velocity = W_CalculateProjectileVelocity(proj.realowner.velocity, proj.velocity, TRUE);
        proj.angles = vectoangles(proj.velocity);
        proj.touch = W_RocketMinsta_Laser_Touch;
        setsize(proj, '0 0 -3', '0 0 -3');
        proj.flags = FL_PROJECTILE;
        proj.missile_flags = MIF_SPLASH;

        CSQCProjectile(proj, TRUE, PROJECTILE_ROCKETMINSTA_LASER, TRUE);

        other = proj; MUTATOR_CALLHOOK(EditProjectile);
        counter++;
    }
}

void W_RocketMinsta_Attack3 (void)
{
	makevectors(self.v_angle);
	
	entity proj;
	float counter = 0;
	float total = 1;

	float w = self.weapon;
	self.weapon = WEP_ELECTRO;
	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 2, "weapons/electro_fire2.wav", CH_WEAPON_A, autocvar_g_rm_laser_damage);
	self.weapon = w;
	
	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

    while(counter < total)
	{
        proj = spawn ();
        proj.classname = "plasma_prim";
        proj.owner = proj.realowner = self;
        proj.bot_dodge = TRUE;
        proj.bot_dodgerating = autocvar_g_rm_laser_damage;
        proj.use = W_RocketMinsta_Laser_Explode;
        proj.think = adaptor_think2use_hittype_splash;
        proj.nextthink = time + autocvar_g_rm_laser_lifetime;
        PROJECTILE_MAKETRIGGER(proj);
        proj.projectiledeathtype = WEP_ELECTRO;
        setorigin(proj, w_shotorg);
		
		proj.rm_force = autocvar_g_rm_laser_force / total;
		proj.rm_damage = autocvar_g_rm_laser_damage / total;
		proj.rm_edmg = proj.rm_damage;
        
        //W_SetupProjectileVelocity(proj, autocvar_g_rm_laser_speed, spread * (rndspread ? random() : 1) * autocvar_g_rm_laser_speed);

        proj.movetype = MOVETYPE_BOUNCEMISSILE;
        //W_SETUPPROJECTILEVELOCITY(proj, g_balance_minstanex_laser);
		proj.velocity = w_shotdir * autocvar_g_rm_laser_speed;
		proj.velocity = W_CalculateProjectileVelocity(proj.realowner.velocity, proj.velocity, TRUE);
        proj.angles = vectoangles(proj.velocity);
        proj.touch = W_RocketMinsta_Laser_Touch;
        setsize(proj, '0 0 -3', '0 0 -3');
        proj.flags = FL_PROJECTILE;
        proj.missile_flags = MIF_SPLASH;

        CSQCProjectile(proj, TRUE, PROJECTILE_ROCKETMINSTA_LASER, TRUE);

        other = proj; MUTATOR_CALLHOOK(EditProjectile);
        counter++;
    }
}

float W_Vaporizer(float req)
{
	float ammo_amount;
	float vaporizer_ammo;
	float rapid = autocvar_g_rm_laser_rapid;

	// now multiple WR_s use this
	vaporizer_ammo = ((g_minstagib) ? 1 : WEP_CVAR_PRI(vaporizer, ammo));

	switch(req)
	{
		case WR_AIM:
		{
			if(self.WEP_AMMO(VAPORIZER) > 0)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 1, FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(WEP_CVAR_SEC(vaporizer, speed), 0, WEP_CVAR_SEC(vaporizer, lifetime), FALSE); // WEAPONTODO: replace with proper vaporizer cvars
				
			return TRUE;
		}
		case WR_THINK:
		{
			// if the laser uses load, we also consider its ammo for reloading
			if(WEP_CVAR(vaporizer, reload_ammo) && WEP_CVAR_SEC(vaporizer, ammo) && self.clip_load < min(vaporizer_ammo, WEP_CVAR_SEC(vaporizer, ammo))) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			else if(WEP_CVAR(vaporizer, reload_ammo) && self.clip_load < vaporizer_ammo) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			if (self.BUTTON_ATCK && ((self.ammo_cells && autocvar_g_rm) || !autocvar_g_rm) && !forbidWeaponUse(self))
			{
				if (!self.vaporizer_held_down)
				{
					if(weapon_prepareattack(0, WEP_CVAR_PRI(vaporizer, refire)))
					{
						W_Vaporizer_Attack();
						if(time >= self.vaporizer_jumpinterval)
						if(WEP_CVAR(vaporizer, superblast) == 1 || (WEP_CVAR(vaporizer, superblast) == 2 && self.cvar_cl_charge) || WEP_CVAR(vaporizer, superblast) >= 3)
						if(W_Vaporizer_SuperBlast_CheckAmmo())
							self.vaporizer_held_down = 1;
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(vaporizer, animtime), w_ready);
					}
				}
				else if(self.vaporizer_held_down == 1)
				{
					if(weapon_prepareattack(0, WEP_CVAR_PRI(vaporizer, refire)))
					{
						sound(self, CH_SHOTS, "weapons/minstanex_charge_new.wav", VOL_BASE, ATTN_NORM);
						self.vaporizer_held_down = 2;
						self.vaporizer_jumpinterval = time + 1.822;
						weapon_thinkf(WFRAME_DONTCHANGE, WEP_CVAR_PRI(vaporizer, refire), w_ready); // update frame so we dont get stuck
					}
				}
				else if(time >= self.vaporizer_jumpinterval && self.vaporizer_held_down == 2)
				{
					if(weapon_prepareattack(0, WEP_CVAR_PRI(vaporizer, refire)))
					{
						if((autocvar_g_rm && autocvar_g_rm_superrocket) || autocvar_g_rm_superrocket == 2)
							W_RocketMinsta_SuperRocket();
						else
							W_Vaporizer_SuperBlast();
						
						self.vaporizer_held_down = 0;
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(vaporizer, animtime), w_ready);
					}
				}
			}
			else
				self.vaporizer_held_down = FALSE;

			if (self.BUTTON_ATCK2 || (self.BUTTON_ATCK && !self.ammo_cells && autocvar_g_rm))
			{
				if((autocvar_g_rm && autocvar_g_rm_laser) || autocvar_g_rm_laser == 2)
				{
					if(self.jump_interval <= time && !self.held_down)
					{
						if(rapid)
							self.held_down = TRUE;
						self.jump_interval = time + autocvar_g_rm_laser_refire;
						self.jump_interval2 = time + autocvar_g_rm_laser_rapid_delay;
						damage_goodhits = 0;
						W_RocketMinsta_Attack2();
						//weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_minstanex_laser_animtime, w_ready);
					}
					else if(rapid && self.jump_interval2 <= time && self.held_down)
					{
						self.jump_interval2 = time + autocvar_g_rm_laser_rapid_refire;
						damage_goodhits = 0;
						W_RocketMinsta_Attack3();
						//weapon_thinkf(WFRAME_FIRE2, autocvar_g_rm_laser_rapid_animtime, w_ready);
					}
				}
				else if (self.jump_interval <= time)
				{
					// handle refire manually, so that primary and secondary can be fired without conflictions (important for minstagib)
					self.jump_interval = time + WEP_CVAR_SEC(vaporizer, refire) * W_WeaponRateFactor();
					
					// decrease ammo for the laser?
					if(WEP_CVAR_SEC(vaporizer, ammo))
						W_DecreaseAmmo(WEP_CVAR_SEC(vaporizer, ammo));

					// ugly minstagib hack to reuse the fire mode of the laser
					W_Blaster_Attack(
						WEP_VAPORIZER | HITTYPE_SECONDARY,
						WEP_CVAR_SEC(vaporizer, shotangle),
						WEP_CVAR_SEC(vaporizer, damage),
						WEP_CVAR_SEC(vaporizer, edgedamage),
						WEP_CVAR_SEC(vaporizer, radius),
						WEP_CVAR_SEC(vaporizer, force),
						WEP_CVAR_SEC(vaporizer, speed),
						WEP_CVAR_SEC(vaporizer, spread),
						WEP_CVAR_SEC(vaporizer, delay),
						WEP_CVAR_SEC(vaporizer, lifetime)
					);
					
					// now do normal refire
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(vaporizer, animtime), w_ready);
				}
			}
			else
				self.held_down = FALSE;
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/nexflash.md3");
			precache_model("models/weapons/g_minstanex.md3");
			precache_model("models/weapons/v_minstanex.md3");
			precache_model("models/weapons/h_minstanex.iqm");
			precache_sound ("weapons/minstanex_charge_new.wav");
			precache_sound ("weapons/minstanex_charge2.wav");
			precache_sound("weapons/minstanexfire.wav");
			precache_sound("weapons/nexwhoosh1.wav");
			precache_sound("weapons/nexwhoosh2.wav");
			precache_sound("weapons/nexwhoosh3.wav");
			//W_Blaster(WR_INIT); // Samual: Is this really the proper thing to do? Didn't we already run this previously?
			VAPORIZER_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_SETUP:
		{
			self.ammo_field = WEP_AMMO(VAPORIZER);
			self.vaporizer_lasthit = 0;
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			ammo_amount = self.WEP_AMMO(VAPORIZER) >= vaporizer_ammo;
			ammo_amount += self.(weapon_load[WEP_VAPORIZER]) >= vaporizer_ammo;
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			if(!WEP_CVAR_SEC(vaporizer, ammo))
				return TRUE;
			ammo_amount = self.WEP_AMMO(VAPORIZER) >= WEP_CVAR_SEC(vaporizer, ammo);
			ammo_amount += self.(weapon_load[WEP_VAPORIZER]) >= WEP_CVAR_SEC(vaporizer, ammo);
			return ammo_amount;
		}
		case WR_CONFIG:
		{
			VAPORIZER_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RESETPLAYER:
		{
			self.vaporizer_lasthit = 0;
			return TRUE;
		}
		case WR_RELOAD:
		{
			float used_ammo;
			if(WEP_CVAR_SEC(vaporizer, ammo))
				used_ammo = min(vaporizer_ammo, WEP_CVAR_SEC(vaporizer, ammo));
			else
				used_ammo = vaporizer_ammo;

			W_Reload(used_ammo, "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			if(w_deathtype & HITTYPE_SPLASH)
				return WEAPON_VAPORIZER_SUICIDE;
			else
				return WEAPON_THINKING_WITH_PORTALS;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SPLASH)
				return WEAPON_VAPORIZER_MURDER_CHARGE;
			else
				return WEAPON_VAPORIZER_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC

.vector sb_shotorg;
.vector sb_endpos;
.float sb_spread_max;
.float sb_spread_min;
.float sb_time;

void Draw_SuperBlast()
{
	float a = bound(0, (0.5 - ((time - self.sb_time) / 0.4)), 0.5);

	if(!a) { remove(self); }
	
	vector deviation, angle;

	vector sb_color = getcsqcplayercolor(self.sv_entnum); // GetTeamRGB(GetPlayerColor(self.sv_entnum));

	vector first_min_end = '0 0 0', prev_min_end = '0 0 0', new_min_end = '0 0 0';
	vector first_max_end = '0 0 0', prev_max_end = '0 0 0', new_max_end = '0 0 0';

	float new_max_dist, new_min_dist;
	
	vector shotdir = normalize(self.sb_endpos - self.sb_shotorg);
	vectorvectors(shotdir);
	vector right = v_right;
	vector up = v_up;
	
	float counter, dist_before_normal = 200, shots = 20;
	
	vector min_end = ((self.sb_shotorg + (shotdir * dist_before_normal)) + (up * self.sb_spread_min));
	vector max_end = (self.sb_endpos + (up * self.sb_spread_max));
	
	float spread_to_min = vlen(normalize(min_end - self.sb_shotorg) - shotdir);
	float spread_to_max = vlen(normalize(max_end - min_end) - shotdir);
	
	for(counter = 0; counter < shots; ++counter)
	{
		// perfect circle effect lines
		angle = '0 0 0';
		makevectors('0 360 0' * (0.75 + (counter - 0.5) / shots));
		angle_y = v_forward_x;
		angle_z = v_forward_y;

		// first do the spread_to_min effect
		deviation = angle * spread_to_min;
		deviation = ((shotdir + (right * deviation_y) + (up * deviation_z)));
		new_min_dist = dist_before_normal;
		new_min_end = (self.sb_shotorg + (deviation * new_min_dist));
		//te_lightning2(world, new_min_end, self.sb_shotorg);

		// then calculate spread_to_max effect
		deviation = angle * spread_to_max;
		deviation = ((shotdir + (right * deviation_y) + (up * deviation_z)));
		new_max_dist = vlen(new_min_end - self.sb_endpos);
		new_max_end = (new_min_end + (deviation * new_max_dist));
		//te_lightning2(world, new_end, prev_min_end);
		

		if(counter == 0)
		{
			first_min_end = new_min_end;
			first_max_end = new_max_end;
		}

		if(counter >= 1)
		{
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(prev_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(new_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(self.sb_shotorg, '0 0 0', sb_color, a);
			R_EndPolygon();

			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(new_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(prev_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(prev_max_end, '0 0 0', sb_color, a);
			R_PolygonVertex(new_max_end, '0 0 0', sb_color, a);
			R_EndPolygon();
		}

		prev_min_end = new_min_end;
		prev_max_end = new_max_end;

		if((counter + 1) == shots)
		{
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(prev_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(first_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(self.sb_shotorg, '0 0 0', sb_color, a);
			R_EndPolygon();

			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(first_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(prev_min_end, '0 0 0', sb_color, a);
			R_PolygonVertex(prev_max_end, '0 0 0', sb_color, a);
			R_PolygonVertex(first_max_end, '0 0 0', sb_color, a);
			R_EndPolygon();
		}
	}
}

void Net_ReadSuperBlastParticle()
{
	entity shockwave;
	shockwave = spawn();
	shockwave.draw = Draw_SuperBlast;
	
	shockwave.sb_shotorg_x = ReadCoord(); shockwave.sb_shotorg_y = ReadCoord(); shockwave.sb_shotorg_z = ReadCoord();
	shockwave.sb_endpos_x  = ReadCoord(); shockwave.sb_endpos_y  = ReadCoord(); shockwave.sb_endpos_z  = ReadCoord();
	
	shockwave.sb_spread_max = ReadByte();
	shockwave.sb_spread_min = ReadByte();

	shockwave.sv_entnum = ReadByte();

	shockwave.sb_time = time;
}

float W_Vaporizer(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 6;
			if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
			if(!(w_deathtype & HITTYPE_SPLASH))
			/*{
				pointparticles(particleeffectnum("rocket_impact"), org2, w_backoff * 1000, 1);
				if(!w_issilent) { sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM); }
			}
			else */if(w_deathtype & HITTYPE_SECONDARY)
			{
				pointparticles(particleeffectnum("laser_impact"), org2, w_backoff * 1000, 1);
				if(!w_issilent) { sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM); }
			}
			else
			{
				pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
				if(!w_issilent) { sound(self, CH_SHOTS, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM); }
			}
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/laserimpact.wav");
			precache_sound("weapons/neximpact.wav");
			if(autocvar_cl_reticle && autocvar_cl_reticle_weapon)
			{
				precache_pic("gfx/reticle_nex");
			}
			return TRUE;
		}
		case WR_ZOOMRETICLE:
		{
			if(button_zoom || zoomscript_caught)
			{
				reticle_image = "gfx/reticle_nex";
				return TRUE;
			}
			else
			{
				// no weapon specific image for this weapon
				return FALSE;
			}
		}
	}
	return FALSE;
}
#endif
#endif
