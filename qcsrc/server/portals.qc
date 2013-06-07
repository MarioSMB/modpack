#define PORTALS_ARE_NOT_SOLID

#define SAFENUDGE '1 1 1'
#define SAFERNUDGE '8 8 8'

.vector portal_transform;
.vector portal_safe_origin;
.float portal_wants_to_vanish;
.float portal_activatetime;
.float savemodelindex;

float PlayerEdgeDistance(entity p, vector v)
{
	vector vbest;

	if(v_x < 0) vbest_x = p.mins_x; else vbest_x = p.maxs_x;
	if(v_y < 0) vbest_y = p.mins_y; else vbest_y = p.maxs_y;
	if(v_z < 0) vbest_z = p.mins_z; else vbest_z = p.maxs_z;

	return vbest * v;
}

vector Portal_ApplyTransformToPlayerAngle(vector transform, vector vangle)
{
	vector old_forward, old_up;
	vector old_yawforward;
	vector new_forward, new_up;
	vector new_yawforward;

	vector ang;
	ang = vangle;
	/*
	   ang_x = bound(-89, mod(-ang_x + 180, 360) - 180, 89);
	   ang = AnglesTransform_ApplyToVAngles(transform, ang);
	 */

	// PLAYERS use different math
#ifndef POSITIVE_PITCH_IS_DOWN
	ang_x = -ang_x;
#endif

	//print("reference: ", vtos(AnglesTransform_ApplyToVAngles(transform, ang)), "\n");

	fixedmakevectors(ang);
	old_forward = v_forward;
	old_up = v_up;
	fixedmakevectors(ang_y * '0 1 0');
	old_yawforward = v_forward;

	// their aiming directions are portalled...
	new_forward = AnglesTransform_Apply(transform, old_forward);
	new_up = AnglesTransform_Apply(transform, old_up);
	new_yawforward = AnglesTransform_Apply(transform, old_yawforward);

	// but now find a new sense of direction
	// this is NOT easy!
	// assume new_forward points straight up.
	// What is our yaw?
	//
	// new_up could now point forward OR backward... which direction to choose?

	if(new_forward_z > 0.7 || new_forward_z < -0.7) // far up; in this case, the "up" vector points backwards
	{
		// new_yawforward and new_yawup define the new aiming half-circle
		// we "just" need to find out whether new_up or -new_up is in that half circle
		ang = fixedvectoangles(new_forward); // this still gets us a nice pitch value...
		if(new_up * new_yawforward < 0)
			new_up = -1 * new_up;
		ang_y = vectoyaw(new_up); // this vector is the yaw we want
		//print("UP/DOWN path: ", vtos(ang), "\n");
	}
	else
	{
		// good angles; here, "forward" suffices
		ang = fixedvectoangles(new_forward);
		//print("GOOD path: ", vtos(ang), "\n");
	}

#ifndef POSITIVE_PITCH_IS_DOWN
	ang_x = -ang_x;
#endif
	ang_z = vangle_z;
	return ang;
}

.vector right_vector;
float Portal_TeleportPlayer(entity teleporter, entity player)
{
	vector from, to, safe, step, transform, ang, newvel;
	float planeshift, s, t;

	if not(teleporter.enemy)
	{
		backtrace("Portal_TeleportPlayer called without other portal being set. Stop.");
		return 0;
	}

	from = teleporter.origin;
	transform = teleporter.portal_transform;

	to = teleporter.enemy.origin;
	to = to + AnglesTransform_Apply(teleporter.portal_transform, player.origin - from);
	newvel = AnglesTransform_Apply(transform, player.velocity);
	// this now is INSIDE the plane... can't use that

	// shift it out
	fixedmakevectors(teleporter.enemy.mangle);

	// first shift it ON the plane if needed
	planeshift = ((teleporter.enemy.origin - to) * v_forward) + PlayerEdgeDistance(player, v_forward) + 1;
	/*
	if(planeshift > 0 && (newvel * v_forward) > vlen(newvel) * 0.01)
		// if we can't, let us not do the planeshift and do somewhat incorrect transformation in the end
		to += newvel * (planeshift / (newvel * v_forward));
	else
	*/
		to += v_forward * planeshift;

	s = (to - teleporter.enemy.origin) * v_right;
	t = (to - teleporter.enemy.origin) * v_up;
	s = bound(-48, s, 48);
	t = bound(-48, t, 48);
	to = teleporter.enemy.origin
	   + ((to - teleporter.enemy.origin) * v_forward) * v_forward
	   +     s                                        * v_right
	   +     t                                        * v_up;

	safe = teleporter.enemy.portal_safe_origin; // a valid player origin
	step = to + ((safe - to) * v_forward) * v_forward;
	tracebox(safe, player.mins - SAFENUDGE, player.maxs + SAFENUDGE, step, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
	{
		print("'safe' teleport location is not safe!\n");
		// FAIL TODO why does this happen?
		return 0;
	}
	safe = trace_endpos + normalize(safe - trace_endpos) * 0;
	tracebox(safe, player.mins - SAFENUDGE, player.maxs + SAFENUDGE, to, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
	{
		print("trace_endpos in solid, this can't be!\n");
		// FAIL TODO why does this happen? (reported by MrBougo)
		return 0;
	}
	to = trace_endpos + normalize(safe - trace_endpos) * 0;
	//print(vtos(to), "\n");

	// ang_x stuff works around weird quake angles
	if(IS_PLAYER(player))
		ang = Portal_ApplyTransformToPlayerAngle(transform, player.v_angle);
	else
		ang = AnglesTransform_ApplyToAngles(transform, player.angles);

	// factor -1 allows chaining portals, but may be weird
	player.right_vector = -1 * AnglesTransform_Apply(transform, player.right_vector);

	entity oldself = self;
	self = player;
	MUTATOR_CALLHOOK(PortalTeleport);
	player = self;
	self = oldself;

	if not(teleporter.enemy)
	{
		backtrace("Portal_TeleportPlayer ended up without other portal being set BEFORE TeleportPlayer. Stop.");
		return 0;
	}

	tdeath_hit = 0;
	TeleportPlayer(teleporter, player, to, ang, newvel, teleporter.enemy.absmin, teleporter.enemy.absmax, TELEPORT_FLAGS_PORTAL);
	if(tdeath_hit)
	{
		// telefrag within 1 second of portal creation = amazing
		if(time < teleporter.teleport_time + 1)
			Send_Notification(NOTIF_ONE, player, MSG_ANNCE, ANNCE_ACHIEVEMENT_AMAZING);
	}

	if not(teleporter.enemy)
	{
		backtrace("Portal_TeleportPlayer ended up without other portal being set AFTER TeleportPlayer. Stop.");
		return 0;
	}

	// reset fade counter
	teleporter.portal_wants_to_vanish = 0;
	teleporter.fade_time = time + autocvar_g_balance_portal_lifetime;
	teleporter.health = autocvar_g_balance_portal_health;
	teleporter.enemy.health = autocvar_g_balance_portal_health;

	return 1;
}

float Portal_FindSafeOrigin(entity portal)
{
	vector o;
	o = portal.origin;
	portal.mins = PL_MIN - SAFERNUDGE;
	portal.maxs = PL_MAX + SAFERNUDGE;
	fixedmakevectors(portal.mangle);
	portal.origin += 16 * v_forward;
	if(!move_out_of_solid(portal))
	{
#ifdef DEBUG
		print("NO SAFE ORIGIN\n");
#endif
		return 0;
	}
	portal.portal_safe_origin = portal.origin;
	setorigin(portal, o);
	return 1;
}

float Portal_WillHitPlane(vector eorg, vector emins, vector emaxs, vector evel, vector porg, vector pnorm, float psize)
{
	float dist, distpersec, delta;
	vector v;

	dist = (eorg - porg) * pnorm;
	dist += min(emins_x * pnorm_x, emaxs_x * pnorm_x);
	dist += min(emins_y * pnorm_y, emaxs_y * pnorm_y);
	dist += min(emins_z * pnorm_z, emaxs_z * pnorm_z);
	if(dist < -1) // other side?
		return 0;
#ifdef PORTALS_ARE_NOT_SOLID
	distpersec = evel * pnorm;
	if(distpersec >= 0) // going away from the portal?
		return 0;
	// we don't need this check with solid portals, them being SOLID_BSP should suffice
	delta = dist / distpersec;
	v = eorg - evel * delta - porg;
	v = v - pnorm * (pnorm * v);
	return vlen(v) < psize;
#else
	return 1;
#endif
}

void Portal_Touch()
{
	vector g;

#ifdef PORTALS_ARE_NOT_SOLID
	// portal is being removed?
	if(self.solid != SOLID_TRIGGER)
		return; // possibly engine bug

	if(IS_PLAYER(other))
		return; // handled by think
#endif

	if(other.classname == "item_flag_team")
		return; // never portal these

	if(other.classname == "grapplinghook")
		return; // handled by think

	if(!self.enemy)
		error("Portal_Touch called for a broken portal\n");

#ifdef PORTALS_ARE_NOT_SOLID
	if(trace_fraction < 1)
		return; // only handle TouchAreaGrid ones (only these can teleport)
#else
	if(trace_fraction >= 1)
		return; // only handle impacts
#endif

	if(other.classname == "porto")
	{
		if(other.portal_id == self.portal_id)
			return;
	}
	if(time < self.portal_activatetime)
		if(other == self.aiment)
		{
			self.portal_activatetime = time + 0.1;
			return;
		}
	if(other != self.aiment)
		if(IS_PLAYER(other))
			if(IS_INDEPENDENT_PLAYER(other) || IS_INDEPENDENT_PLAYER(self.aiment))
				return; // cannot go through someone else's portal
	if(other.aiment != self.aiment)
		if(IS_PLAYER(other.aiment))
			if(IS_INDEPENDENT_PLAYER(other.aiment) || IS_INDEPENDENT_PLAYER(self.aiment))
				return; // cannot go through someone else's portal
	fixedmakevectors(self.mangle);
	g = frametime * '0 0 -1' * autocvar_sv_gravity;
	if(!Portal_WillHitPlane(other.origin, other.mins, other.maxs, other.velocity + g, self.origin, v_forward, self.maxs_x))
		return;

	/*
	if(other.mins_x < PL_MIN_x || other.mins_y < PL_MIN_y || other.mins_z < PL_MIN_z
	|| other.maxs_x > PL_MAX_x || other.maxs_y > PL_MAX_y || other.maxs_z > PL_MAX_z)
	{
		// can't teleport this
		return;
	}
	*/

	if(Portal_TeleportPlayer(self, other))
		if(other.classname == "porto")
			if(other.effects & EF_RED)
				other.effects += EF_BLUE - EF_RED;
}

void Portal_Think();
void Portal_MakeBrokenPortal(entity portal)
{
	portal.skin = 2;
	portal.solid = SOLID_NOT;
	portal.touch = func_null;
	portal.think = func_null;
	portal.effects = 0;
	portal.nextthink = 0;
	portal.takedamage = DAMAGE_NO;
}

void Portal_MakeWaitingPortal(entity portal)
{
	portal.skin = 2;
	portal.solid = SOLID_NOT;
	portal.touch = func_null;
	portal.think = func_null;
	portal.effects = EF_ADDITIVE;
	portal.nextthink = 0;
	portal.takedamage = DAMAGE_YES;
}

void Portal_MakeInPortal(entity portal)
{
	portal.skin = 0;
	portal.solid = SOLID_NOT; // this is done when connecting them!
	portal.touch = Portal_Touch;
	portal.think = Portal_Think;
	portal.effects = EF_RED;
	portal.nextthink = time;
	portal.takedamage = DAMAGE_NO;
}

void Portal_MakeOutPortal(entity portal)
{
	portal.skin = 1;
	portal.solid = SOLID_NOT;
	portal.touch = func_null;
	portal.think = func_null;
	portal.effects = EF_STARDUST | EF_BLUE;
	portal.nextthink = 0;
	portal.takedamage = DAMAGE_YES;
}

void Portal_Disconnect(entity teleporter, entity destination)
{
	teleporter.enemy = world;
	destination.enemy = world;
	Portal_MakeBrokenPortal(teleporter);
	Portal_MakeBrokenPortal(destination);
}

void Portal_Connect(entity teleporter, entity destination)
{
	teleporter.portal_transform = AnglesTransform_RightDivide(AnglesTransform_TurnDirectionFR(destination.mangle), teleporter.mangle);

	teleporter.enemy = destination;
	destination.enemy = teleporter;
	Portal_MakeInPortal(teleporter);
	Portal_MakeOutPortal(destination);
	teleporter.fade_time = time + autocvar_g_balance_portal_lifetime;
	destination.fade_time = teleporter.fade_time;
	teleporter.portal_wants_to_vanish = 0;
	destination.portal_wants_to_vanish = 0;
	teleporter.teleport_time = time;
#ifdef PORTALS_ARE_NOT_SOLID
	teleporter.solid = SOLID_TRIGGER;
#else
	teleporter.solid = SOLID_BSP;
#endif
}

void Portal_Remove(entity portal, float killed)
{
	entity e;
	e = portal.enemy;

	if(e)
	{
		Portal_Disconnect(portal, e);
		Portal_Remove(e, killed);
	}

	if(portal == portal.aiment.portal_in)
		portal.aiment.portal_in = world;
	if(portal == portal.aiment.portal_out)
		portal.aiment.portal_out = world;
	//portal.aiment = world;

	// makes the portal vanish
	if(killed)
	{
		fixedmakevectors(portal.mangle);
		sound(portal, CH_SHOTS, "porto/explode.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("rocket_explode"), portal.origin + v_forward * 16, v_forward * 1024, 4);
		remove(portal);
	}
	else
	{
		Portal_MakeBrokenPortal(portal);
		sound(portal, CH_SHOTS, "porto/expire.wav", VOL_BASE, ATTN_NORM);
		SUB_SetFade(portal, time, 0.5);
	}
}

void Portal_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(deathtype == DEATH_TELEFRAG)
		return;
	if(attacker != self.aiment)
		if(IS_INDEPENDENT_PLAYER(attacker) || IS_INDEPENDENT_PLAYER(self.aiment))
			return;
	self.health -= damage;
	if(self.health < 0)
		Portal_Remove(self, 1);
}

void Portal_Think_TryTeleportPlayer(entity e, vector g)
{
	if(!Portal_WillHitPlane(e.origin, e.mins, e.maxs, e.velocity + g, self.origin, v_forward, self.maxs_x))
		return;

	// if e would hit the portal in a frame...
	// already teleport him
	tracebox(e.origin, e.mins, e.maxs, e.origin + e.velocity * 2 * frametime, MOVE_NORMAL, e);
	if(trace_ent == self)
		Portal_TeleportPlayer(self, e);
}

void Portal_Think()
{
	entity e, o;
	vector g;

#ifdef PORTALS_ARE_NOT_SOLID
	// portal is being removed?
	if(self.solid != SOLID_TRIGGER)
		return; // possibly engine bug

	if(!self.enemy)
		error("Portal_Think called for a broken portal\n");

	o = self.aiment;
	self.solid = SOLID_BBOX;
	self.aiment = world;

	g = frametime * '0 0 -1' * autocvar_sv_gravity;

	fixedmakevectors(self.mangle);

	FOR_EACH_PLAYER(e)
	{
		if(e != o)
			if(IS_INDEPENDENT_PLAYER(e) || IS_INDEPENDENT_PLAYER(o))
				continue; // cannot go through someone else's portal

		if(e != o || time >= self.portal_activatetime)
			Portal_Think_TryTeleportPlayer(e, g);

		if(e.hook)
			Portal_Think_TryTeleportPlayer(e.hook, g);
	}
	self.solid = SOLID_TRIGGER;
	self.aiment = o;
#endif

	self.nextthink = time;

	if(time > self.fade_time)
		Portal_Remove(self, 0);
}

float Portal_Customize()
{
	if(IS_SPEC(other))
		other = other.enemy;
	if(other == self.aiment)
	{
		self.modelindex = self.savemodelindex;
	}
	else if(IS_INDEPENDENT_PLAYER(other) || IS_INDEPENDENT_PLAYER(self.aiment))
	{
		self.modelindex = 0;
	}
	else
	{
		self.modelindex = self.savemodelindex;
	}
	return TRUE;
}

// cleanup:
//   when creating in-portal:
//     disconnect
//     clear existing in-portal
//     set as in-portal
//     connect
//   when creating out-portal:
//     disconnect
//     clear existing out-portal
//     set as out-portal
//   when player dies:
//     disconnect portals
//     clear both portals
//   after timeout of in-portal:
//     disconnect portals
//     clear both portals
//   TODO: ensure only one portal shot at once
float Portal_SetInPortal(entity own, entity portal)
{
	if(own.portal_in)
	{
		if(own.portal_out)
			Portal_Disconnect(own.portal_in, own.portal_out);
		Portal_Remove(own.portal_in, 0);
	}
	own.portal_in = portal;
	if(own.portal_out)
	{
		own.portal_out.portal_id = portal.portal_id;
		Portal_Connect(own.portal_in, own.portal_out);
	}
	return 2;
}
float Portal_SetOutPortal(entity own, entity portal)
{
	if(own.portal_out)
	{
		if(own.portal_in)
			Portal_Disconnect(own.portal_in, own.portal_out);
		Portal_Remove(own.portal_out, 0);
	}
	own.portal_out = portal;
	if(own.portal_in)
	{
		own.portal_in.portal_id = portal.portal_id;
		Portal_Connect(own.portal_in, own.portal_out);
	}
	return 1;
}
void Portal_ClearAll_PortalsOnly(entity own)
{
	if(own.portal_in)
		Portal_Remove(own.portal_in, 0);
	if(own.portal_out)
		Portal_Remove(own.portal_out, 0);
}
void Portal_ClearAll(entity own)
{
	Portal_ClearAll_PortalsOnly(own);
	W_Porto_Remove(own);
}
void Portal_RemoveLater_Think()
{
	Portal_Remove(self, self.cnt);
}
void Portal_RemoveLater(entity portal, float kill)
{
	Portal_MakeBrokenPortal(portal);
	portal.cnt = kill;
	portal.think = Portal_RemoveLater_Think;
	portal.nextthink = time;
}
void Portal_ClearAllLater_PortalsOnly(entity own)
{
	if(own.portal_in)
		Portal_RemoveLater(own.portal_in, 0);
	if(own.portal_out)
		Portal_RemoveLater(own.portal_out, 0);
}
void Portal_ClearAllLater(entity own)
{
	Portal_ClearAllLater_PortalsOnly(own);
	W_Porto_Remove(own);
}
void Portal_ClearWithID(entity own, float id)
{
	if(own.portal_in)
		if(own.portal_in.portal_id == id)
		{
			if(own.portal_out)
				Portal_Disconnect(own.portal_in, own.portal_out);
			Portal_Remove(own.portal_in, 0);
		}
	if(own.portal_out)
		if(own.portal_out.portal_id == id)
		{
			if(own.portal_in)
				Portal_Disconnect(own.portal_in, own.portal_out);
			Portal_Remove(own.portal_out, 0);
		}
}

entity Portal_Spawn(entity own, vector org, vector ang)
{
	entity portal;

	fixedmakevectors(ang);
	if(!CheckWireframeBox(own, org - 48 * v_right - 48 * v_up + 16 * v_forward, 96 * v_right, 96 * v_up, 96 * v_forward))
		return world;

	portal = spawn();
	portal.classname = "portal";
	portal.aiment = own;
	setorigin(portal, org);
	portal.mangle = ang;
	portal.angles = ang;
	portal.angles_x = -portal.angles_x; // is a bmodel
	portal.think = Portal_Think;
	portal.nextthink = 0;
	portal.portal_activatetime = time + 0.1;
	portal.takedamage = DAMAGE_AIM;
	portal.event_damage = Portal_Damage;
	portal.fade_time = time + autocvar_g_balance_portal_lifetime;
	portal.health = autocvar_g_balance_portal_health;
	setmodel(portal, "models/portal.md3");
	portal.savemodelindex = portal.modelindex;
	portal.customizeentityforclient = Portal_Customize;

	if(!Portal_FindSafeOrigin(portal))
	{
		remove(portal);
		return world;
	}

	setsize(portal, '-48 -48 -48', '48 48 48');
	Portal_MakeWaitingPortal(portal);

	return portal;
}

float Portal_SpawnInPortalAtTrace(entity own, vector dir, float portal_id_val)
{
	entity portal;
	vector ang;
	vector org;

	org = trace_endpos;
	ang = fixedvectoangles2(trace_plane_normal, dir);
	fixedmakevectors(ang);

	portal = Portal_Spawn(own, org, ang);
	if(!portal)
		return 0;

	portal.portal_id = portal_id_val;
	Portal_SetInPortal(own, portal);

	return 1;
}

float Portal_SpawnOutPortalAtTrace(entity own, vector dir, float portal_id_val)
{
	entity portal;
	vector ang;
	vector org;

	org = trace_endpos;
	ang = fixedvectoangles2(trace_plane_normal, dir);
	fixedmakevectors(ang);

	portal = Portal_Spawn(own, org, ang);
	if(!portal)
		return 0;

	portal.portal_id = portal_id_val;
	Portal_SetOutPortal(own, portal);

	return 1;
}
