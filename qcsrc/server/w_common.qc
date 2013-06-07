
void W_GiveWeapon (entity e, float wep)
{
	entity oldself;

	if (!wep)
		return;

	WEPSET_OR_EW(e, wep);

	oldself = self;
	self = e;

	if(IS_PLAYER(other))
		{ Send_Notification(NOTIF_ONE, other, MSG_MULTI, ITEM_WEAPON_GOT, wep); }

	self = oldself;
}

.float railgundistance;
.vector railgunforce;
void FireRailgunBullet (vector start, vector end, float bdamage, float bforce, float mindist, float maxdist, float halflifedist, float forcehalflifedist, float deathtype)
{
	vector hitloc, force, endpoint, dir;
	entity ent, endent;
	float endq3surfaceflags;
	float totaldmg;
	entity o;

	float length;
	vector beampos;
	string snd;
	entity pseudoprojectile;
	float f, ffs;

	pseudoprojectile = world;

	railgun_start = start;
	railgun_end = end;

	dir = normalize(end - start);
	length = vlen(end - start);
	force = dir * bforce;

	// go a little bit into the wall because we need to hit this wall later
	end = end + dir;

	totaldmg = 0;

	// trace multiple times until we hit a wall, each obstacle will be made
	// non-solid so we can hit the next, while doing this we spawn effects and
	// note down which entities were hit so we can damage them later
	o = self;
	while (1)
	{
		if(self.antilag_debug)
			WarpZone_traceline_antilag (self, start, end, FALSE, o, self.antilag_debug);
		else
			WarpZone_traceline_antilag (self, start, end, FALSE, o, ANTILAG_LATENCY(self));
		if(o && WarpZone_trace_firstzone)
		{
			o = world;
			continue;
		}

		if(trace_ent.solid == SOLID_BSP || trace_ent.solid == SOLID_SLIDEBOX)
			Damage_DamageInfo(trace_endpos, bdamage, 0, 0, force, deathtype, trace_ent.species, self);

		// if it is world we can't hurt it so stop now
		if (trace_ent == world || trace_fraction == 1)
			break;

		// make the entity non-solid so we can hit the next one
		trace_ent.railgunhit = TRUE;
		trace_ent.railgunhitloc = end;
		trace_ent.railgunhitsolidbackup = trace_ent.solid;
		trace_ent.railgundistance = vlen(WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos) - start);
		trace_ent.railgunforce = WarpZone_TransformVelocity(WarpZone_trace_transform, force);

		// stop if this is a wall
		if (trace_ent.solid == SOLID_BSP)
			break;

		// make the entity non-solid
		trace_ent.solid = SOLID_NOT;
	}

	endpoint = trace_endpos;
	endent = trace_ent;
	endq3surfaceflags = trace_dphitq3surfaceflags;

	// find all the entities the railgun hit and restore their solid state
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// restore their solid type
		ent.solid = ent.railgunhitsolidbackup;
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// spawn a temporary explosion entity for RadiusDamage calls
	//explosion = spawn();

	// Find all non-hit players the beam passed close by
	if(deathtype == WEP_MINSTANEX || deathtype == WEP_NEX)
	{
		FOR_EACH_REALCLIENT(msg_entity) if(msg_entity != self) if(!msg_entity.railgunhit) if not(IS_SPEC(msg_entity) && msg_entity.enemy == self) // we use realclient, so spectators can hear the whoosh too
		{
			// nearest point on the beam
			beampos = start + dir * bound(0, (msg_entity.origin - start) * dir, length);

			f = bound(0, 1 - vlen(beampos - msg_entity.origin) / 512, 1);
			if(f <= 0)
				continue;

			snd = strcat("weapons/nexwhoosh", ftos(floor(random() * 3) + 1), ".wav");

			if(!pseudoprojectile)
				pseudoprojectile = spawn(); // we need this so the sound uses the "entchannel4" volume
			soundtoat(MSG_ONE, pseudoprojectile, beampos, CH_SHOTS, snd, VOL_BASE * f, ATTN_NONE);
		}

		if(pseudoprojectile)
			remove(pseudoprojectile);
	}

	// find all the entities the railgun hit and hurt them
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// get the details we need to call the damage function
		hitloc = ent.railgunhitloc;

		f = ExponentialFalloff(mindist, maxdist, halflifedist, ent.railgundistance);
		ffs = ExponentialFalloff(mindist, maxdist, forcehalflifedist, ent.railgundistance);

		if(accuracy_isgooddamage(self.realowner, ent))
			totaldmg += bdamage * f;

		// apply the damage
		if (ent.takedamage)
			Damage (ent, self, self, bdamage * f, deathtype, hitloc, ent.railgunforce * ffs);

		// create a small explosion to throw gibs around (if applicable)
		//setorigin (explosion, hitloc);
		//RadiusDamage (explosion, self, 10, 0, 50, world, 300, deathtype);

		ent.railgunhitloc = '0 0 0';
		ent.railgunhitsolidbackup = SOLID_NOT;
		ent.railgunhit = FALSE;
		ent.railgundistance = 0;

		// advance to the next entity
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// calculate hits and fired shots for hitscan
	accuracy_add(self, self.weapon, 0, min(bdamage, totaldmg));

	trace_endpos = endpoint;
	trace_ent = endent;
	trace_dphitq3surfaceflags = endq3surfaceflags;
}

.float dmg_force;
.float dmg_radius;
.float dmg_total;
//.float last_yoda;
void W_BallisticBullet_Hit (void)
{
	float f, q, g;

	f = pow(bound(0, vlen(self.velocity) / vlen(self.oldvelocity), 1), 2); // energy multiplier
	q = 1 + self.dmg_edge / self.dmg;

	if(other.solid == SOLID_BSP || other.solid == SOLID_SLIDEBOX)
		Damage_DamageInfo(self.origin, self.dmg * f, 0, 0, max(1, self.dmg_force) * normalize(self.velocity) * f, self.projectiledeathtype, other.species, self);

	if(other && other != self.enemy)
	{
		endzcurveparticles();

		yoda = 0;
		railgun_start = self.origin - 2 * frametime * self.velocity;
		railgun_end = self.origin + 2 * frametime * self.velocity;
		g = accuracy_isgooddamage(self.realowner, other);
		Damage(other, self, self.realowner, self.dmg * f, self.projectiledeathtype, self.origin, self.dmg_force * normalize(self.velocity) * f);

		/*if(yoda && (time > (self.last_yoda + 5)))
		{
			Send_Notification(NOTIF_ONE, self.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_YODA);
			self.last_yoda = time; 
		}*/

		// calculate hits for ballistic weapons
		if(g)
		{
			// do not exceed 100%
			q = min(self.dmg * q, self.dmg_total + f * self.dmg) - self.dmg_total;
			self.dmg_total += f * self.dmg;
			accuracy_add(self.realowner, self.realowner.weapon, 0, q);
		}
	}

	self.enemy = other; // don't hit the same player twice with the same bullet
}

.void(void) W_BallisticBullet_LeaveSolid_think_save;
.float W_BallisticBullet_LeaveSolid_nextthink_save;
.vector W_BallisticBullet_LeaveSolid_origin;
.vector W_BallisticBullet_LeaveSolid_velocity;

void W_BallisticBullet_LeaveSolid_think()
{
	setorigin(self, self.W_BallisticBullet_LeaveSolid_origin);
	self.velocity = self.W_BallisticBullet_LeaveSolid_velocity;

	self.think = self.W_BallisticBullet_LeaveSolid_think_save;
	self.nextthink = max(time, self.W_BallisticBullet_LeaveSolid_nextthink_save);
	self.W_BallisticBullet_LeaveSolid_think_save = func_null;

	self.flags &~= FL_ONGROUND;

	if(self.enemy.solid == SOLID_BSP)
	{
		float f;
		f = pow(bound(0, vlen(self.velocity) / vlen(self.oldvelocity), 1), 2); // energy multiplier
		Damage_DamageInfo(self.origin, 0, 0, 0, max(1, self.dmg_force) * normalize(self.velocity) * -f, self.projectiledeathtype, 0, self);
	}

	UpdateCSQCProjectile(self);
}

float W_BallisticBullet_LeaveSolid(float eff)
{
	// move the entity along its velocity until it's out of solid, then let it resume
	vector vel = self.velocity;
	float dt, dst, velfactor, v0, vs;
	float maxdist;
	float E0_m, Es_m;
	float constant = self.dmg_radius * (other.ballistics_density ? other.ballistics_density : 1);

	// outside the world? forget it
	if(self.origin_x > world.maxs_x || self.origin_y > world.maxs_y || self.origin_z > world.maxs_z || self.origin_x < world.mins_x || self.origin_y < world.mins_y || self.origin_z < world.mins_z)
		return 0;

	// special case for zero density and zero bullet constant: 

	if(self.dmg_radius == 0)
	{
		if(other.ballistics_density < 0)
			constant = 0; // infinite travel distance
		else
			return 0; // no penetration
	}
	else
	{
		if(other.ballistics_density < 0)
			constant = 0; // infinite travel distance
		else if(other.ballistics_density == 0)
			constant = self.dmg_radius;
		else
			constant = self.dmg_radius * other.ballistics_density;
	}

	// E(s) = E0 - constant * s, constant = area of bullet circle * material constant / mass
	v0 = vlen(vel);

	E0_m = 0.5 * v0 * v0;

	if(constant)
	{
		maxdist = E0_m / constant;
		// maxdist = 0.5 * v0 * v0 / constant
		// dprint("max dist = ", ftos(maxdist), "\n");

		if(maxdist <= autocvar_g_ballistics_mindistance)
			return 0;
	}
	else
	{
		maxdist = vlen(other.maxs - other.mins) + 1; // any distance, as long as we leave the entity
	}

	traceline_inverted (self.origin, self.origin + normalize(vel) * maxdist, MOVE_NORMAL, self, TRUE);
	if(trace_fraction == 1) // 1: we never got out of solid
		return 0;

	self.W_BallisticBullet_LeaveSolid_origin = trace_endpos;

	dst = max(autocvar_g_ballistics_mindistance, vlen(trace_endpos - self.origin));
	// E(s) = E0 - constant * s, constant = area of bullet circle * material constant / mass
	Es_m = E0_m - constant * dst;
	if(Es_m <= 0)
	{
		// roundoff errors got us
		return 0;
	}
	vs = sqrt(2 * Es_m);
	velfactor = vs / v0;

	dt = dst / (0.5 * (v0 + vs));
	// this is not correct, but the differential equations have no analytic
	// solution - and these times are very small anyway
	//print("dt = ", ftos(dt), "\n");

	self.W_BallisticBullet_LeaveSolid_think_save = self.think;
	self.W_BallisticBullet_LeaveSolid_nextthink_save = self.nextthink;
	self.think = W_BallisticBullet_LeaveSolid_think;
	self.nextthink = time + dt;

	vel = vel * velfactor;

	self.velocity = '0 0 0';
	self.flags |= FL_ONGROUND; // prevent moving
	self.W_BallisticBullet_LeaveSolid_velocity = vel;

	if(eff >= 0)
		if(vlen(trace_endpos - self.origin) > 4)
		{
			endzcurveparticles();
			trailparticles(self, eff, self.origin, trace_endpos);
		}

	return 1;
}

void W_BallisticBullet_Touch (void)
{
	//float density;

	if(self.think == W_BallisticBullet_LeaveSolid_think) // skip this!
		return;

	PROJECTILE_TOUCH;
	W_BallisticBullet_Hit ();

	if(self.dmg_radius < 0) // these NEVER penetrate solid
	{
		remove(self);
		return;
	}

	// if we hit "weapclip", bail out
	//
	// rationale of this check:
	//
	// any shader that is solid, nodraw AND trans is meant to clip weapon
	// shots and players, but has no other effect!
	//
	// if it is not trans, it is caulk and should not have this side effect
	//
	// matching shaders:
	//   common/weapclip (intended)
	//   common/noimpact (is supposed to eat projectiles, but is erased farther above)
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NODRAW)
	if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NONSOLID)
	if not(trace_dphitcontents & DPCONTENTS_OPAQUE)
	{
		remove(self);
		return;
	}

	// go through solid!
	if(!W_BallisticBullet_LeaveSolid(-1))
	{
		remove(self);
		return;
	}

	self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void endFireBallisticBullet()
{
	endzcurveparticles();
}

entity fireBallisticBullet_trace_callback_ent;
float fireBallisticBullet_trace_callback_eff;
void fireBallisticBullet_trace_callback(vector start, vector hit, vector end)
{
	if(vlen(trace_endpos - fireBallisticBullet_trace_callback_ent.origin) > 16)
		zcurveparticles_from_tracetoss(fireBallisticBullet_trace_callback_eff, fireBallisticBullet_trace_callback_ent.origin, trace_endpos, fireBallisticBullet_trace_callback_ent.velocity);
	WarpZone_trace_forent = world;
	self.owner = world;
}

void fireBallisticBullet(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float force, float dtype, float tracereffects, float gravityfactor, float bulletconstant)
{
	float lag, dt, savetime; //, density;
	entity pl, oldself;
	float antilagging;

	antilagging = (autocvar_g_antilag_bullets && (pSpeed >= autocvar_g_antilag_bullets));

	entity proj;
	proj = spawn();
	proj.classname = "bullet";
	proj.owner = proj.realowner = self;
	PROJECTILE_MAKETRIGGER(proj);
	if(gravityfactor > 0)
	{
		proj.movetype = MOVETYPE_TOSS;
		proj.gravity = gravityfactor;
	}
	else
		proj.movetype = MOVETYPE_FLY;
	proj.think = SUB_Remove;
	proj.nextthink = time + lifetime; // min(pLifetime, vlen(world.maxs - world.mins) / pSpeed);
	W_SetupProjectileVelocityEx(proj, dir, v_up, pSpeed, 0, 0, spread, antilagging);
	proj.angles = vectoangles(proj.velocity);
	if(bulletconstant > 0)
		proj.dmg_radius = autocvar_g_ballistics_materialconstant / bulletconstant;
	else if(bulletconstant == 0)
		proj.dmg_radius = 0;
	else
		proj.dmg_radius = -1;
	// so: bulletconstant = bullet mass / area of bullet circle
	setorigin(proj, start);
	proj.flags = FL_PROJECTILE;

	proj.touch = W_BallisticBullet_Touch;
	proj.dmg = damage;
	proj.dmg_force = force;
	proj.projectiledeathtype = dtype;

	proj.oldvelocity = proj.velocity;

	other = proj; MUTATOR_CALLHOOK(EditProjectile);

	if(antilagging)
	{
		float eff;

		if(tracereffects & EF_RED)
			eff = particleeffectnum("tr_rifle");
		else if(tracereffects & EF_BLUE)
			eff = particleeffectnum("tr_rifle_weak");
		else
			eff = particleeffectnum("tr_bullet");

		// NOTE: this may severely throw off weapon balance
		lag = ANTILAG_LATENCY(self);
		if(lag < 0.001)
			lag = 0;
		if not(IS_REAL_CLIENT(self))
			lag = 0;
		if(autocvar_g_antilag == 0 || self.cvar_cl_noantilag)
			lag = 0; // only do hitscan, but no antilag

		if(lag)
			FOR_EACH_PLAYER(pl)
				if(pl != self)
					antilag_takeback(pl, time - lag);

		oldself = self;
		self = proj;

		savetime = frametime;
		frametime = 0.05;

		for(;;)
		{
			// DP tracetoss is stupid and always traces in 0.05s
			// ticks. This makes it trace in 0.05*0.125s ticks
			// instead.
			vector v0;
			float g0;
			v0 = self.velocity;
			g0 = self.gravity;
			self.velocity = self.velocity * 0.125;
			self.gravity *= 0.125 * 0.125;
			trace_fraction = 0;
			fireBallisticBullet_trace_callback_ent = self;
			fireBallisticBullet_trace_callback_eff = eff;
			WarpZone_TraceToss_ThroughZone(self, self.owner, world, fireBallisticBullet_trace_callback);
			self.velocity = v0;
			self.gravity = g0;

			if(trace_fraction == 1)
				break;
				// won't hit anything anytime soon (DP's
				// tracetoss does 200 tics of, here,
				// 0.05*0.125s, that is, 1.25 seconds

			other = trace_ent;
			dt = WarpZone_tracetoss_time * 0.125; // this is only approximate!
			setorigin(self, trace_endpos);
			self.velocity = WarpZone_tracetoss_velocity * (1 / 0.125);

			if(!SUB_OwnerCheck())
			{
				if(SUB_NoImpactCheck())
					break;

				// hit the player
				W_BallisticBullet_Hit();
			}

			if(proj.dmg_radius < 0) // these NEVER penetrate solid
				break;

			// if we hit "weapclip", bail out
			//
			// rationale of this check:
			//
			// any shader that is solid, nodraw AND trans is meant to clip weapon
			// shots and players, but has no other effect!
			//
			// if it is not trans, it is caulk and should not have this side effect
			//
			// matching shaders:
			//   common/weapclip (intended)
			//   common/noimpact (is supposed to eat projectiles, but is erased farther above)
			if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NODRAW)
			if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NONSOLID)
			if not(trace_dphitcontents & DPCONTENTS_OPAQUE)
				break;

			// go through solid!
			if(!W_BallisticBullet_LeaveSolid((other && (other.solid != SOLID_BSP)) ? eff : -1))
				break;

			W_BallisticBullet_LeaveSolid_think();

			self.projectiledeathtype |= HITTYPE_BOUNCE;
		}
		frametime = savetime;
		self = oldself;

		if(lag)
			FOR_EACH_PLAYER(pl)
				if(pl != self)
					antilag_restore(pl);

		remove(proj);

		return;
	}

	if(tracereffects & EF_RED)
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET_GLOWING_TRACER, TRUE);
	else if(tracereffects & EF_BLUE)
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET_GLOWING, TRUE);
	else
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET, TRUE);
}

void fireBullet (vector start, vector dir, float spread, float damage, float force, float dtype, float tracer)
{
	vector  end;

	dir = normalize(dir + randomvec() * spread);
	end = start + dir * MAX_SHOT_DISTANCE;
	if(self.antilag_debug)
		traceline_antilag (self, start, end, FALSE, self, self.antilag_debug);
	else
		traceline_antilag (self, start, end, FALSE, self, ANTILAG_LATENCY(self));

	end = trace_endpos;

	if (pointcontents (trace_endpos) != CONTENT_SKY)
	{
		if not (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
			Damage_DamageInfo(trace_endpos, damage, 0, 0, dir * max(1, force), dtype, trace_ent.species, self);                    

		Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * force);
	}
	trace_endpos = end;
}

float W_CheckProjectileDamage(entity inflictor, entity projowner, float deathtype, float exception)
{
	float is_from_contents = (deathtype == DEATH_SLIME || deathtype == DEATH_LAVA);
	float is_from_owner = (inflictor == projowner);
	float is_from_exception = (exception != -1);
	
	//dprint(strcat("W_CheckProjectileDamage: from_contents ", ftos(is_from_contents), " : from_owner ", ftos(is_from_owner), " : exception ", strcat(ftos(is_from_exception), " (", ftos(exception), "). \n")));

	if(autocvar_g_projectiles_damage <= -2)
	{
		return FALSE; // no damage to projectiles at all, not even with the exceptions
	}
	else if(autocvar_g_projectiles_damage == -1)
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
		else
			return FALSE; // otherwise, no other damage is allowed
	}
	else if(autocvar_g_projectiles_damage == 0)
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
		else if not(is_from_contents)
			return FALSE; // otherwise, only allow damage from contents
	}	
	else if(autocvar_g_projectiles_damage == 1)
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
		else if not(is_from_contents || is_from_owner)
			return FALSE; // otherwise, only allow self damage and damage from contents
	}
	else if(autocvar_g_projectiles_damage == 2) // allow any damage, but override for exceptions
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
	}

	return TRUE; // if none of these return, then allow damage anyway.
}

void W_PrepareExplosionByDamage(entity attacker, void() explode)
{
	self.takedamage = DAMAGE_NO;
	self.event_damage = func_null;
	
	if(IS_CLIENT(attacker) && !autocvar_g_projectiles_keep_owner)
	{
		self.owner = attacker;
		self.realowner = attacker;
	}
	
	// do not explode NOW but in the NEXT FRAME!
	// because recursive calls to RadiusDamage are not allowed
	self.nextthink = time;
	self.think = explode;
}
