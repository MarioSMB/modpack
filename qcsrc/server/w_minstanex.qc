#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ MINSTANEX,
/* function  */ w_minstanex,
/* ammotype  */ IT_CELLS | IT_SUPERCELLS,
/* impulse   */ 7,
/* flags     */ WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_FLAG_SUPERWEAPON | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_HIGH,
/* model     */ "minstanex",
/* shortname */ "minstanex",
/* fullname  */ _("MinstaNex")
);
#else
#ifdef SVQC
.float minstanex_lasthit;
.float jump_interval;
.float jump_interval2;
.float held_down;
.float minstanex_held_down;
.float minstanex_jumpinterval;

.float superrocket_lasthit;

.float rm_force;
.float rm_damage;
.float rm_edmg;

void SendCSQCSuperBlastParticle(vector endpos) 
{
	//endpos = WarpZone_UnTransformOrigin(transform, endpos);
	
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_SHOCKWAVEPARTICLE);
	WriteCoord(MSG_BROADCAST, w_shotorg_x);
	WriteCoord(MSG_BROADCAST, w_shotorg_y);
	WriteCoord(MSG_BROADCAST, w_shotorg_z);
	WriteCoord(MSG_BROADCAST, endpos_x);
	WriteCoord(MSG_BROADCAST, endpos_y);
	WriteCoord(MSG_BROADCAST, endpos_z);
	WriteByte(MSG_BROADCAST, bound(0, autocvar_g_balance_minstanex_superblast_spread_max, 255));
	WriteByte(MSG_BROADCAST, bound(0, autocvar_g_balance_minstanex_superblast_spread_min, 255));
	WriteByte(MSG_BROADCAST, num_for_edict(self));
}

float W_MinstaNex_SuperBlast_CheckSpread(vector targetorg, vector nearest_on_line, vector sw_shotorg, vector attack_endpos)
{
	float spreadlimit;
	float distance_of_attack = vlen(sw_shotorg - attack_endpos);
	float distance_from_line = vlen(targetorg - nearest_on_line);
	
	spreadlimit = (distance_of_attack ? min(1, (vlen(sw_shotorg - nearest_on_line) / distance_of_attack)) : 1);
	spreadlimit = (autocvar_g_balance_minstanex_superblast_spread_min * (1 - spreadlimit) + autocvar_g_balance_minstanex_superblast_spread_max * spreadlimit);
	
	if(spreadlimit && (distance_from_line <= spreadlimit) && ((vlen(normalize(targetorg - sw_shotorg) - normalize(attack_endpos - sw_shotorg)) * RAD2DEG) <= 90))
		return bound(0, (distance_from_line / spreadlimit), 1);
	else
		return FALSE;
}

float W_MinstaNex_SuperBlast_IsVisible(entity head, vector nearest_on_line, vector sw_shotorg, vector attack_endpos)
{
	vector nearest_to_attacker = head.WarpZone_findradius_nearest;
	vector center = (head.origin + (head.mins + head.maxs) * 0.5);
	vector corner;
	float i;

	// STEP ONE: Check if the nearest point is clear
	if(W_MinstaNex_SuperBlast_CheckSpread(nearest_to_attacker, nearest_on_line, sw_shotorg, attack_endpos))
	{
		WarpZone_TraceLine(sw_shotorg, nearest_to_attacker, MOVE_NOMONSTERS, self);
		if(trace_fraction == 1) { return TRUE; } // yes, the nearest point is clear and we can allow the damage
	}

	// STEP TWO: Check if shotorg to center point is clear
	if(W_MinstaNex_SuperBlast_CheckSpread(center, nearest_on_line, sw_shotorg, attack_endpos))
	{
		WarpZone_TraceLine(sw_shotorg, center, MOVE_NOMONSTERS, self);
		if(trace_fraction == 1) { return TRUE; } // yes, the center point is clear and we can allow the damage
	}

	// STEP THREE: Check each corner to see if they are clear
	for(i=1; i<=8; ++i)
	{
		corner = get_corner_position(head, i);
		if(W_MinstaNex_SuperBlast_CheckSpread(corner, nearest_on_line, sw_shotorg, attack_endpos))
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

float W_MinstaNex_SuperBlast_CheckHit(float queue, entity head, vector final_force, float final_damage)
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
		accuracy_add(self, WEP_ROCKET_LAUNCHER, autocvar_g_rm_damage, 0);

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

				if(W_MinstaNex_SuperBlast_CheckHit(queue, head, final_force, final_damage)) { ++queue; }
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
			accuracy_add(self, WEP_ROCKET_LAUNCHER, 0, final_damage);
		
		Damage(head, self, self, final_damage, (WEP_ROCKET_LAUNCHER | HITTYPE_SPLASH), head.origin, final_force);
		//print("SHOCKWAVE by ", self.netname, ": damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force)), ".\n");

		shockwave_hit[i] = world;
		shockwave_hit_force[i] = '0 0 0';
		shockwave_hit_damage[i] = 0;
	}
}

void W_MinstaNex_Attack (void)
{
	makevectors(self.v_angle);

	float flying;
	float minstanex_damage = ((autocvar_g_balance_minstanex_damage) ? autocvar_g_balance_minstanex_damage : 10000);

	if(!self.minsta_range)
		self.minsta_range = ((autocvar_g_balance_minstanex_distance > 0) ? autocvar_g_balance_minstanex_distance : MAX_SHOT_DISTANCE);

	float minstanex_ammo = ((g_minstagib) ? 1 : autocvar_g_balance_minstanex_ammo);
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

	W_SetupShot (self, TRUE, 0, "weapons/minstanexfire.wav", CH_WEAPON_A, minstanex_damage, self.weapon);
	
	self.projectiledeathtype = WEP_MINSTANEX;

	yoda = 0;
	damage_goodhits = 0;
	FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * self.minsta_range, minstanex_damage, 800, 0, 0, 0, 0, self.projectiledeathtype);

	if(yoda && flying)
		Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_ACHIEVEMENT_YODA);
	if(damage_goodhits && self.minstanex_lasthit)
	{
		Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_ACHIEVEMENT_IMPRESSIVE);
		damage_goodhits = 0; // only every second time
	}

	self.minstanex_lasthit = damage_goodhits;

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
	
	W_DecreaseAmmo(ammo_cells, minstanex_ammo, autocvar_g_balance_minstanex_reload_ammo);
}

void W_MinstaNex_SuperBlast()
{
	// declarations
	float multiplier, multiplier_from_accuracy, multiplier_from_distance;
	float final_damage; //, final_spread;
	vector final_force, center, vel;
	entity head, next;

	float i, queue = 0;
	
	// set up the shot direction
	W_SetupShot(self, FALSE, 3, "weapons/minstanex_charge2.wav", CH_WEAPON_B, autocvar_g_balance_minstanex_damage, self.weapon);
	vector attack_endpos = (w_shotorg + (w_shotdir * self.minsta_range));
	WarpZone_TraceLine(w_shotorg, attack_endpos, MOVE_NOMONSTERS, self);
	vector attack_hitpos = trace_endpos;
	float distance_to_end = vlen(w_shotorg - attack_endpos);
	float distance_to_hit = vlen(w_shotorg - attack_hitpos);
	//entity transform = WarpZone_trace_transform;

	// do the firing effect now
	SendCSQCSuperBlastParticle(attack_endpos);
	Damage_DamageInfo(attack_hitpos, autocvar_g_balance_minstanex_superblast_splash_damage, autocvar_g_balance_minstanex_superblast_splash_edgedamage, autocvar_g_balance_minstanex_superblast_splash_radius, w_shotdir * autocvar_g_balance_minstanex_superblast_splash_force, (WEP_MINSTANEX | HITTYPE_SPLASH), 0, self);

	// splash damage/jumping trace
	head = WarpZone_FindRadius(attack_hitpos, max(autocvar_g_balance_minstanex_superblast_splash_radius, autocvar_g_balance_minstanex_superblast_jump_radius), FALSE);
	while(head)
	{
		next = head.chain;

		if(head.takedamage)
		{
			// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc)
			center = CENTER_OR_VIEWOFS(head);

			float distance_to_head = vlen(attack_hitpos - head.WarpZone_findradius_nearest);
			
			if((head == self) && (distance_to_head <= autocvar_g_balance_minstanex_superblast_jump_radius))
			{
				multiplier_from_accuracy = (1 - (distance_to_head ? min(1, (distance_to_head / autocvar_g_balance_minstanex_superblast_jump_radius)) : 0));
				multiplier_from_distance = (1 - (distance_to_hit ? min(1, (distance_to_hit / distance_to_end)) : 0));
				multiplier = max(autocvar_g_balance_minstanex_superblast_jump_multiplier_min, ((multiplier_from_accuracy * autocvar_g_balance_minstanex_superblast_jump_multiplier_accuracy) + (multiplier_from_distance * autocvar_g_balance_minstanex_superblast_jump_multiplier_distance)));

				final_force = ((normalize(center - attack_hitpos) * autocvar_g_balance_minstanex_superblast_jump_force) * multiplier);
				vel = head.velocity; vel_z = 0;
				vel = normalize(vel) * bound(0, vlen(vel) / autocvar_sv_maxspeed, 1) * autocvar_g_balance_minstanex_superblast_jump_force_velocitybias;
				final_force = (vlen(final_force) * normalize(normalize(final_force) + vel));
				final_force_z *= autocvar_g_balance_minstanex_superblast_jump_force_zscale;
				final_damage = (autocvar_g_balance_minstanex_superblast_jump_damage * multiplier + autocvar_g_balance_minstanex_superblast_jump_edgedamage * (1 - multiplier));

				Damage(head, self, self, final_damage, (WEP_MINSTANEX | HITTYPE_SPLASH), head.origin, final_force);
				//print("SELF HIT: multiplier = ", ftos(multiplier), strcat(", damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force))),"... multiplier_from_accuracy = ", ftos(multiplier_from_accuracy), ", multiplier_from_distance = ", ftos(multiplier_from_distance), ".\n");
			}
			else if (distance_to_head <= autocvar_g_balance_minstanex_superblast_splash_radius)
			{	
				multiplier_from_accuracy = (1 - (distance_to_head ? min(1, (distance_to_head / autocvar_g_balance_minstanex_superblast_splash_radius)) : 0));
				multiplier_from_distance = (1 - (distance_to_hit ? min(1, (distance_to_hit / distance_to_end)) : 0));
				multiplier = max(autocvar_g_balance_minstanex_superblast_splash_multiplier_min, ((multiplier_from_accuracy * autocvar_g_balance_minstanex_superblast_splash_multiplier_accuracy) + (multiplier_from_distance * autocvar_g_balance_minstanex_superblast_splash_multiplier_distance)));

				final_force = normalize(center - (attack_hitpos - (w_shotdir * autocvar_g_balance_minstanex_superblast_splash_force_forwardbias)));
				//te_lightning2(world, attack_hitpos, (attack_hitpos + (final_force * 200)));
				final_force = ((final_force * autocvar_g_balance_minstanex_superblast_splash_force) * multiplier);
				final_force_z *= autocvar_g_balance_minstanex_superblast_force_zscale;
				final_damage = (autocvar_g_balance_minstanex_superblast_splash_damage * multiplier + autocvar_g_balance_minstanex_superblast_splash_edgedamage * (1 - multiplier));

				if(W_MinstaNex_SuperBlast_CheckHit(queue, head, final_force, final_damage)) { ++queue; }
				//print("SPLASH HIT: multiplier = ", ftos(multiplier), strcat(", damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force))),"... multiplier_from_accuracy = ", ftos(multiplier_from_accuracy), ", multiplier_from_distance = ", ftos(multiplier_from_distance), ".\n");
			}
		}
		head = next;
	}

	// cone damage trace
	head = WarpZone_FindRadius(w_shotorg, self.minsta_range, FALSE);
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

			if((distance_to_target <= self.minsta_range) 
				&& (W_MinstaNex_SuperBlast_IsVisible(head, nearest_on_line, w_shotorg, attack_endpos)))
			{
				multiplier_from_accuracy = (1 - W_MinstaNex_SuperBlast_CheckSpread(nearest_to_attacker, nearest_on_line, w_shotorg, attack_endpos));
				multiplier_from_distance = (1 - (distance_to_hit ? min(1, (distance_to_target / distance_to_end)) : 0));
				multiplier = max(autocvar_g_balance_minstanex_superblast_multiplier_min, ((multiplier_from_accuracy * autocvar_g_balance_minstanex_superblast_multiplier_accuracy) + (multiplier_from_distance * autocvar_g_balance_minstanex_superblast_multiplier_distance)));

				final_force = normalize(center - (nearest_on_line - (w_shotdir * autocvar_g_balance_minstanex_superblast_force_forwardbias)));
				//te_lightning2(world, nearest_on_line, (attack_hitpos + (final_force * 200)));
				final_force = ((final_force * autocvar_g_balance_minstanex_superblast_force) * multiplier);
				final_force_z *= autocvar_g_balance_minstanex_superblast_force_zscale;
				final_damage = (autocvar_g_balance_minstanex_damage * multiplier + autocvar_g_balance_minstanex_damage * (1 - multiplier));

				if(W_MinstaNex_SuperBlast_CheckHit(queue, head, final_force, final_damage)) { ++queue; }
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
		
		Damage(head, self, self, final_damage, (WEP_MINSTANEX | HITTYPE_SPLASH), head.origin, final_force);
		
		if(accuracy_isgooddamage(self, head))
			accuracy_add(self, WEP_MINSTANEX, 1, final_damage);
		//print("SHOCKWAVE by ", self.netname, ": damage = ", ftos(final_damage), ", force = ", ftos(vlen(final_force)), ".\n");
		
		shockwave_hit[i] = world;
		shockwave_hit_force[i] = '0 0 0';
		shockwave_hit_damage[i] = 0;
	}
	//print("queue was ", ftos(queue), ".\n\n");
	
	W_DecreaseAmmo(ammo_supercells, 1, autocvar_g_balance_minstanex_reload_ammo);
}

float W_MinstaNex_SuperBlast_CheckAmmo()
{
	if(autocvar_g_balance_minstanex_superblast == 3)
		return TRUE; // forced
	float ammo_amount;
	ammo_amount = self.ammo_supercells >= 1;
	ammo_amount += self.(weapon_load[WEP_MINSTANEX]) >= 1;
	return ammo_amount;
}

void W_RocketMinsta_SuperRocket_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, 250, 250, 250, world, 250, self.projectiledeathtype, other);

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
		float minstanex_damage = ((autocvar_g_balance_minstanex_damage) ? autocvar_g_balance_minstanex_damage : 10000);
		Damage(other, self, self.realowner, minstanex_damage, WEP_ROCKET_LAUNCHER, other.origin, '0 0 0');
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
	float minstanex_damage = ((autocvar_g_balance_minstanex_damage) ? autocvar_g_balance_minstanex_damage : 10000);
	
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '-32 -32 -32', '32 32 32', FALSE, 5, "weapons/minstanex_charge2.wav", CH_WEAPON_A, minstanex_damage, WEP_ROCKET_LAUNCHER);
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
	missile.projectiledeathtype = WEP_ROCKET_LAUNCHER;
	setsize (missile, '-32 -32 -32', '32 32 32'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(missile, autocvar_g_rm_superrocket_speed, 0);
	missile.angles = self.v_angle;

	missile.touch = W_RocketMinsta_SuperRocket_Touch;
	missile.think = W_RocketMinsta_SuperRocket_Think;
	missile.nextthink = time;
	missile.cnt = time + 10;
	missile.flags = FL_PROJECTILE;
	//missile.missile_flags = MIF_SPLASH;

	CSQCProjectile(missile, TRUE, PROJECTILE_SUPERROCKET, FALSE); // because of fly sound
	
	W_DecreaseAmmo(ammo_supercells, 1, autocvar_g_balance_minstanex_reload_ammo);
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
	RadiusDamage (self, self.realowner, self.rm_damage, self.rm_edmg, autocvar_g_rm_laser_radius, world, self.rm_force, self.projectiledeathtype, other);
	remove(self);
}

void W_RocketMinsta_Laser_Touch (void)
{
	PROJECTILE_TOUCH;
	//W_RocketMinsta_Laser_Explode ();
	RadiusDamage (self, self.realowner, self.rm_damage, self.rm_edmg, autocvar_g_rm_laser_radius, world, self.rm_force, self.projectiledeathtype, other);
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

	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, autocvar_g_rm_laser_damage, WEP_ELECTRO);
	
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

	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 2, "weapons/electro_fire2.wav", CH_WEAPON_A, autocvar_g_rm_laser_damage, WEP_ELECTRO);
	
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

void spawnfunc_weapon_minstanex (void); // defined in t_items.qc
float forbidWeaponUse(); // defined in cl_weapons.qc

float w_minstanex(float req)
{
	float ammo_amount;
	float minstanex_ammo;
	float rapid = autocvar_g_rm_laser_rapid;

	// now multiple WR_s use this
	minstanex_ammo = ((g_minstagib) ? 1 : autocvar_g_balance_minstanex_ammo);

	if (req == WR_AIM)
	{
		if(self.ammo_cells > 0)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 1, FALSE);
		else
			self.BUTTON_ATCK2 = bot_aim(autocvar_g_balance_laser_primary_speed, 0, autocvar_g_balance_laser_primary_lifetime, FALSE);
	}
	else if (req == WR_THINK)
	{
		// if the laser uses load, we also consider its ammo for reloading
		if(autocvar_g_balance_minstanex_reload_ammo && autocvar_g_balance_minstanex_laser_ammo && self.clip_load < min(minstanex_ammo, autocvar_g_balance_minstanex_laser_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if(autocvar_g_balance_minstanex_reload_ammo && self.clip_load < minstanex_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		if (self.BUTTON_ATCK && ((self.ammo_cells && autocvar_g_rm) || !autocvar_g_rm) && !forbidWeaponUse())
		{
			if (!self.minstanex_held_down)
			{
				if(weapon_prepareattack(0, autocvar_g_balance_minstanex_refire))
				{
					W_MinstaNex_Attack();
					
					if(time >= self.minstanex_jumpinterval)
					if(autocvar_g_balance_minstanex_superblast == 1 || (autocvar_g_balance_minstanex_superblast == 2 && self.cvar_cl_charge) || autocvar_g_balance_minstanex_superblast >= 3)
					if(W_MinstaNex_SuperBlast_CheckAmmo())
						self.minstanex_held_down = 1;
						
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_minstanex_animtime, w_ready);
				}
			}
			else if(self.minstanex_held_down == 1)
			{
				if(weapon_prepareattack(0, autocvar_g_balance_minstanex_refire))
				{
					sound(self, CH_SHOTS, "weapons/minstanex_charge_new.wav", VOL_BASE, ATTN_NORM);
					self.minstanex_held_down = 2;
					self.minstanex_jumpinterval = time + 1.822;
					weapon_thinkf(WFRAME_DONTCHANGE, autocvar_g_balance_minstanex_refire, w_ready); // update frame so we dont get stuck
				}
			}
			else if(time >= self.minstanex_jumpinterval && self.minstanex_held_down == 2)
			{
				if(weapon_prepareattack(0, autocvar_g_balance_minstanex_refire))
				{
					if((autocvar_g_rm && autocvar_g_rm_superrocket) || autocvar_g_rm_superrocket == 2)
						W_RocketMinsta_SuperRocket();
					else
						W_MinstaNex_SuperBlast();
						
					self.minstanex_held_down = 0;
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_minstanex_animtime, w_ready);
				}
			}
		}
		else
			self.minstanex_held_down = FALSE;
			
		if (self.BUTTON_ATCK2 || (self.BUTTON_ATCK && !self.ammo_cells && autocvar_g_rm))
		{
			if((autocvar_g_rm && autocvar_g_rm_laser) || autocvar_g_rm_laser == 2)
			{
				if (self.jump_interval <= time && !self.held_down)
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
				self.jump_interval = time + autocvar_g_balance_minstanex_laser_refire * W_WeaponRateFactor();

				// decrease ammo for the laser?
				if(autocvar_g_balance_minstanex_laser_ammo)
					W_DecreaseAmmo(ammo_cells, autocvar_g_balance_minstanex_laser_ammo, autocvar_g_balance_minstanex_reload_ammo);

				W_Laser_Attack(2, WEP_LASER, WEP_LASER);

				// now do normal refire
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_minstanex_laser_animtime, w_ready);
			}
		}
		else
			self.held_down = FALSE;
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/nexflash.md3");
		precache_model ("models/weapons/g_minstanex.md3");
		precache_model ("models/weapons/v_minstanex.md3");
		precache_model ("models/weapons/h_minstanex.iqm");
		precache_sound ("weapons/minstanexfire.wav");
		precache_sound ("weapons/minstanex_charge_new.wav");
		precache_sound ("weapons/minstanex_charge2.wav");
		precache_sound ("weapons/crylink_fire.wav");
		precache_sound ("weapons/electro_fire2.wav");
		precache_sound ("weapons/nexwhoosh1.wav");
		precache_sound ("weapons/nexwhoosh2.wav");
		precache_sound ("weapons/nexwhoosh3.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		w_laser(WR_PRECACHE);
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_MINSTANEX);
		self.current_ammo = ammo_cells;
		self.minstanex_lasthit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_cells >= minstanex_ammo;
		ammo_amount += self.(weapon_load[WEP_MINSTANEX]) >= minstanex_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(!autocvar_g_balance_minstanex_laser_ammo)
			return TRUE;
		ammo_amount = self.ammo_cells >= autocvar_g_balance_minstanex_laser_ammo;
		ammo_amount += self.(weapon_load[WEP_MINSTANEX]) >= autocvar_g_balance_minstanex_laser_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.minstanex_lasthit = 0;
		self.minstanex_held_down = 0;
		self.held_down = 0;
	}
	else if (req == WR_RELOAD)
	{
		float used_ammo;
		if(autocvar_g_balance_minstanex_laser_ammo)
			used_ammo = min(minstanex_ammo, autocvar_g_balance_minstanex_laser_ammo);
		else
			used_ammo = minstanex_ammo;

		W_Reload(used_ammo, autocvar_g_balance_minstanex_reload_ammo, autocvar_g_balance_minstanex_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			return WEAPON_MINSTANEX_SUICIDE;
		else
			return WEAPON_THINKING_WITH_PORTALS;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			return WEAPON_MINSTANEX_MURDER_CHARGE;
		else
			return WEAPON_MINSTANEX_MURDER;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_minstanex(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		if(!(w_deathtype & HITTYPE_SPLASH))
		if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
			pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/neximpact.wav", VOL_BASE, ATTEN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/neximpact.wav");
	}
	return TRUE;
}
#endif
#endif
