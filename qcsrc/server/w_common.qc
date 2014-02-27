
void W_GiveWeapon (entity e, float wep)
{
	entity oldself;

	if (!wep)
		return;

	e.weapons |= WepSet_FromWeapon(wep);

	oldself = self;
	self = e;

	if(IS_PLAYER(other))
		{ Send_Notification(NOTIF_ONE, other, MSG_MULTI, ITEM_WEAPON_GOT, wep); }

	self = oldself;
}

float Headshot(entity targ, entity ent, vector hitloc)
{
	if(!autocvar_sv_headshot)
		return FALSE;
	if(ent.weapon != WEP_RIFLE && ent.weapon != WEP_MINSTANEX && ent.weapon != WEP_NEX)
		return FALSE;
	float nearestbone = 0;
	string tag_lower = "";
	FOR_EACH_TAG(targ)
	{
		if(!tagnum)
			continue; // skip empty bones
			
		tag_lower = strtolower(gettaginfo_name);
			
		if(tag_lower == "master" || tag_lower == "leg_l" || tag_lower == "bip01 r hand" || tag_lower == "leg_r" || startsWith(gettaginfo_name, "dummy") || startsWith(tag_lower, "bone") || startsWith(gettaginfo_name, "forearm") || startsWith(gettaginfo_name, "knee") || startsWith(gettaginfo_name, "foot") || startsWith(gettaginfo_name, "upperarm") || startsWith(gettaginfo_name, "toe") || startsWith(gettaginfo_name, "hand"))
			continue; // player model bone blacklist

		// now choose the bone closest to impact origin
		if(nearestbone == 0 || vlen(hitloc - gettaginfo(targ, tagnum)) <= vlen(hitloc - gettaginfo(targ, nearestbone)))
			nearestbone = tagnum;
	}
	
	if(nearestbone)
	{
		gettaginfo(targ, nearestbone);
		tag_lower = strtolower(gettaginfo_name);
		//print(gettaginfo_name, "\n");
		if(tag_lower == "head" || tag_lower == "tag_head" || tag_lower == "bip01 head" || strstrofs(tag_lower, "head", 0) >= 0)
			return TRUE;
	}
	return FALSE;
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

		if(trace_ent.solid == SOLID_BSP || trace_ent.solid == SOLID_SLIDEBOX || trace_ent.classname == "object")
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
		if (trace_ent.solid == SOLID_BSP || trace_ent.classname == "object")
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
		FOR_EACH_REALCLIENT(msg_entity)
		if(msg_entity != self)
		if(!msg_entity.railgunhit)
		if(!(IS_SPEC(msg_entity) && msg_entity.enemy == self)) // we use realclient, so spectators can hear the whoosh too
		{
			// nearest point on the beam
			beampos = start + dir * bound(0, (msg_entity.origin - start) * dir, length);

			f = bound(0, 1 - vlen(beampos - msg_entity.origin) / 512, 1);
			if(f <= 0)
				continue;

			snd = strcat("weapons/nexwhoosh", ftos(floor(random() * 3) + 1), ".wav");

			if(!pseudoprojectile)
				pseudoprojectile = spawn(); // we need this so the sound uses the "entchannel4" volume
			soundtoat(MSG_ONE, pseudoprojectile, beampos, CH_SHOTS, snd, VOL_BASE * f, ATTEN_NONE);
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

		if(Headshot(ent, self, hitloc))
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_HEADSHOT);

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

float fireBullet_trace_callback_eff;
entity fireBullet_last_hit;
void fireBullet_trace_callback(vector start, vector hit, vector end)
{
	if(vlen(hit - start) > 16)
		trailparticles(world, fireBullet_trace_callback_eff, start, hit);
	WarpZone_trace_forent = world;
	fireBullet_last_hit = world;
}

void fireBullet(vector start, vector dir, float spread, float max_solid_penetration, float damage, float force, float dtype, float tracereffects)
{
	// TODO antilag takeback
	vector  end;

	dir = normalize(dir + randomvec() * spread);
	end = start + dir * MAX_SHOT_DISTANCE;

	entity pl;
	fireBullet_last_hit = world;
	float solid_penetration_left = 1;
	float total_damage = 0;

	if(tracereffects & EF_RED)
		fireBullet_trace_callback_eff = particleeffectnum("tr_rifle");
	else if(tracereffects & EF_BLUE)
		fireBullet_trace_callback_eff = particleeffectnum("tr_rifle_weak");
	else
		fireBullet_trace_callback_eff = particleeffectnum("tr_bullet");

	float lag = ANTILAG_LATENCY(self);
	if(lag < 0.001)
		lag = 0;
	if (!IS_REAL_CLIENT(self))
		lag = 0;
	if(autocvar_g_antilag == 0 || self.cvar_cl_noantilag)
		lag = 0; // only do hitscan, but no antilag
	if(lag)
		FOR_EACH_PLAYER(pl)
			if(pl != self)
				antilag_takeback(pl, time - lag);

	WarpZone_trace_forent = self;

	for (;;)
	{
		// TODO also show effect while tracing
		WarpZone_TraceBox_ThroughZone(start, '0 0 0', '0 0 0', end, FALSE, WarpZone_trace_forent, world, fireBullet_trace_callback);
		dir = WarpZone_TransformVelocity(WarpZone_trace_transform, dir);
		end = WarpZone_TransformOrigin(WarpZone_trace_transform, end);
		start = trace_endpos;
		entity hit = trace_ent;

		// When hitting sky, stop.
		if (pointcontents(start) == CONTENT_SKY)
			break;

		if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
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
		//   common/noimpact (is supposed to eat projectiles, but is erased anyway)
		float is_weapclip = 0;
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NODRAW)
		if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NONSOLID))
		if (!(trace_dphitcontents & DPCONTENTS_OPAQUE))
			is_weapclip = 1;

		if(!hit || hit.solid == SOLID_BSP || hit.solid == SOLID_SLIDEBOX)
			Damage_DamageInfo(start, damage * solid_penetration_left, 0, 0, max(1, force) * dir * solid_penetration_left, dtype, hit.species, self);

		if (hit && hit != WarpZone_trace_forent && hit != fireBullet_last_hit)  // Avoid self-damage (except after going through a warp); avoid hitting the same entity twice (engine bug).
		{
			fireBullet_last_hit = hit;
			yoda = 0;
			float g = accuracy_isgooddamage(self, hit);
			Damage(hit, self, self, damage * solid_penetration_left, dtype, start, force * dir * solid_penetration_left);

			if(Headshot(hit, self, end))
				Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_HEADSHOT);

			// calculate hits for ballistic weapons
			if(g)
			{
				// do not exceed 100%
				float added_damage = min(damage - total_damage, damage * solid_penetration_left);
				total_damage += damage * solid_penetration_left;
				accuracy_add(self, self.weapon, 0, added_damage);
			}
		}

		if (is_weapclip)
			break;

		// go through solid!
		// outside the world? forget it
		if(start_x > world.maxs_x || start_y > world.maxs_y || start_z > world.maxs_z || start_x < world.mins_x || start_y < world.mins_y || start_z < world.mins_z)
			break;

		float maxdist;
		if(max_solid_penetration < 0)
			break;
		else if(hit.ballistics_density < -1)
			break; // -2: no solid penetration, ever
		else if(hit.ballistics_density < 0)
			maxdist = vlen(hit.maxs - hit.mins) + 1; // -1: infinite travel distance
		else if(hit.ballistics_density == 0)
			maxdist = max_solid_penetration * solid_penetration_left;
		else
			maxdist = max_solid_penetration * solid_penetration_left * hit.ballistics_density;

		if(maxdist <= autocvar_g_ballistics_mindistance)
			break;

		// move the entity along its velocity until it's out of solid, then let it resume
		// The previously hit entity is ignored here!
		traceline_inverted (start, start + dir * maxdist, MOVE_NORMAL, WarpZone_trace_forent, TRUE, hit);
		if(trace_fraction == 1) // 1: we never got out of solid
			break;

		float dist_taken = max(autocvar_g_ballistics_mindistance, vlen(trace_endpos - start));
		solid_penetration_left *= (dist_taken / maxdist);

		// Only show effect when going through a player (invisible otherwise)
		if (hit && (hit.solid != SOLID_BSP))
			if(vlen(trace_endpos - start) > 4)
				trailparticles(self, fireBullet_trace_callback_eff, start, trace_endpos);

		start = trace_endpos;

		if(hit.solid == SOLID_BSP)
			Damage_DamageInfo(start, 0, 0, 0, max(1, force) * normalize(dir) * -solid_penetration_left, dtype, 0, self);
	}

	if(lag)
		FOR_EACH_PLAYER(pl)
			if(pl != self)
				antilag_restore(pl);
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
		else if (!is_from_contents)
			return FALSE; // otherwise, only allow damage from contents
	}
	else if(autocvar_g_projectiles_damage == 1)
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
		else if (!(is_from_contents || is_from_owner))
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
