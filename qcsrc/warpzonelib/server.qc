#ifdef WARPZONELIB_KEEPDEBUG
#define WARPZONELIB_REMOVEHACK
#endif

// for think function
.vector warpzone_save_origin;
.vector warpzone_save_angles;
.vector warpzone_save_eorigin;
.vector warpzone_save_eangles;

// for all entities
.vector warpzone_oldorigin, warpzone_oldvelocity, warpzone_oldangles;
.float warpzone_teleport_time;
.float warpzone_teleport_finishtime;
.entity warpzone_teleport_zone;

void WarpZone_StoreProjectileData(entity e)
{
	e.warpzone_oldorigin = e.origin;
	e.warpzone_oldvelocity = e.velocity;
	e.warpzone_oldangles = e.angles;
}

void WarpZone_TeleportPlayer(entity teleporter, entity player, vector to, vector to_angles, vector to_velocity)
{
	setorigin (player, to); // NOTE: this also aborts the move, when this is called by touch
	player.oldorigin = to; // for DP's unsticking
	player.angles = to_angles;
	player.fixangle = TRUE;
	player.velocity = to_velocity;

	BITXOR_ASSIGN(player.effects, EF_TELEPORT_BIT);

	if(IS_PLAYER(player))
		BITCLR_ASSIGN(player.flags, FL_ONGROUND);

	WarpZone_PostTeleportPlayer_Callback(player);
}

float WarpZone_Teleported_Send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_WARPZONE_TELEPORTED);
	WriteCoord(MSG_ENTITY, self.angles_x);
	WriteCoord(MSG_ENTITY, self.angles_y);
	WriteCoord(MSG_ENTITY, self.angles_z);
	return TRUE;
}

float WarpZone_Teleport(entity wz, entity player, float f0, float f1)
{
	vector o0, a0, v0, o1, a1, v1, o10;

	o0 = player.origin + player.view_ofs;
	v0 = player.velocity;
	a0 = player.angles;

	o10 = o1 = WarpZone_TransformOrigin(wz, o0);
	v1 = WarpZone_TransformVelocity(wz, v0);
	if not(IS_NOT_A_CLIENT(player))
		a1 = WarpZone_TransformVAngles(wz, player.v_angle);
	else
		a1 = WarpZone_TransformAngles(wz, a0);

	if(f0 != 0 || f1 != 0)
	{
		// retry last move but behind the warpzone!
		// we must first go back as far as we can, then forward again, to not cause double touch events!

		tracebox(o1 - player.view_ofs + v1 * frametime * f1, player.mins, player.maxs, o1 - player.view_ofs + v1 * frametime * f0, MOVE_WORLDONLY, player);
		{
			entity own;
			own = player.owner;
			player.owner = world;
			tracebox(trace_endpos, player.mins, player.maxs, o1 - player.view_ofs + v1 * frametime * f1, MOVE_NORMAL, player); // this should get us through the warpzone
			player.owner = own;
		}
		o1 = trace_endpos + player.view_ofs;

		float d, dv, md;
		md = max(vlen(player.mins), vlen(player.maxs));
		d = WarpZone_TargetPlaneDist(wz, o1);
		dv = WarpZone_TargetPlaneDist(wz, v1);
		if(d < 0)
			o1 = o1 - v1 * (d / dv);
	}

	// put him out of solid
	tracebox(o1 - player.view_ofs, player.mins, player.maxs, o1 - player.view_ofs, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
	{
		setorigin(player, o1 - player.view_ofs);
		if(WarpZoneLib_MoveOutOfSolid(player))
		{
			o1 = player.origin + player.view_ofs;
			setorigin(player, o0 - player.view_ofs);
		}
		else
		{
			print("would have to put player in solid, won't do that\n");
			setorigin(player, o0 - player.view_ofs);
			return 0;
		}
	}

	// do the teleport
	WarpZone_RefSys_Add(player, wz);
	WarpZone_TeleportPlayer(wz, player, o1 - player.view_ofs, a1, v1);
	WarpZone_StoreProjectileData(player);
	player.warpzone_teleport_time = time;
	player.warpzone_teleport_finishtime = time;
	player.warpzone_teleport_zone = wz;

	// prevent further teleports back
	float dt = (o1 - o10) * v1 * (1 / (v1 * v1));
	if(dt < sys_frametime)
		player.warpzone_teleport_finishtime += sys_frametime - dt;

#ifndef WARPZONE_USE_FIXANGLE
	if(IS_PLAYER(player))
	{
		// instead of fixangle, send the transform to the client for smoother operation
		player.fixangle = FALSE;

		entity ts = spawn();
		setmodel(ts, "null");
		ts.SendEntity = WarpZone_Teleported_Send;
		ts.SendFlags = 0xFFFFFF;
		ts.drawonlytoclient = player;
		ts.think = SUB_Remove;
		ts.nextthink = time + 1;
		ts.owner = player;
		ts.enemy = wz;
		ts.effects = EF_NODEPTHTEST;
		ts.classname = "warpzone_teleported";
		ts.angles = wz.warpzone_transform;
	}
#endif

	return 1;
}

void WarpZone_Touch (void)
{
	entity oldself;

	if(other.classname == "trigger_warpzone")
		return;

	if(time <= other.warpzone_teleport_finishtime) // already teleported this frame
		return;

	// FIXME needs a better check to know what is safe to teleport and what not
	if(other.movetype == MOVETYPE_NONE || other.movetype == MOVETYPE_FOLLOW || other.tag_entity)
		return;

	if(WarpZoneLib_ExactTrigger_Touch())
		return;

	if(WarpZone_PlaneDist(self, other.origin + other.view_ofs) >= 0) // wrong side of the trigger_warpzone (don't teleport yet)
		return;

	float f;
	// number of frames we need to go back:
	//   dist = 16*sqrt(2) qu
	//   dist ~ 24 qu
	//   24 qu = v*t
	//   24 qu = v*frametime*n
	//       n = 24 qu/(v*frametime)
	// for clients go only one frame though, may be too irritating otherwise
	// but max 0.25 sec = 0.25/frametime frames
	//       24/(0.25/frametime)
	//       96*frametime
	float d;
	d = 24 + max(vlen(other.mins), vlen(other.maxs));
	if(IS_NOT_A_CLIENT(other))
		f = -d / bound(frametime * d * 1, frametime * vlen(other.velocity), d);
	else
		f = -1;
	if(WarpZone_Teleport(self, other, f, 0))
	{
		string save1, save2;
		activator = other;

		save1 = self.target; self.target = string_null;
		save2 = self.target3; self.target3 = string_null;
		SUB_UseTargets();
		if not(self.target) self.target = save1;
		if not(self.target3) self.target3 = save2;

		oldself = self;
		self = self.enemy;
		save1 = self.target; self.target = string_null;
		save2 = self.target2; self.target2 = string_null;
		SUB_UseTargets();
		if not(self.target) self.target = save1;
		if not(self.target2) self.target2 = save2;
		self = oldself;
	}
	else
	{
		dprint("WARPZONE FAIL AHAHAHAHAH))\n");
	}
}

float WarpZone_Send(entity to, float sendflags)
{
	float f;
	WriteByte(MSG_ENTITY, ENT_CLIENT_WARPZONE);

	// we must send this flag for clientside to match properly too
	f = 0;
	if(self.warpzone_isboxy)
		BITSET_ASSIGN(f, 1);
	if(self.warpzone_fadestart)
		BITSET_ASSIGN(f, 2);
	if(self.origin != '0 0 0')
		BITSET_ASSIGN(f, 4);
	WriteByte(MSG_ENTITY, f);

	// we need THESE to render the warpzone (and cull properly)...
	if(f & 4)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}

	WriteShort(MSG_ENTITY, self.modelindex);
	WriteCoord(MSG_ENTITY, self.mins_x);
	WriteCoord(MSG_ENTITY, self.mins_y);
	WriteCoord(MSG_ENTITY, self.mins_z);
	WriteCoord(MSG_ENTITY, self.maxs_x);
	WriteCoord(MSG_ENTITY, self.maxs_y);
	WriteCoord(MSG_ENTITY, self.maxs_z);
	WriteByte(MSG_ENTITY, bound(1, self.scale * 16, 255));

	// we need THESE to calculate the proper transform
	WriteCoord(MSG_ENTITY, self.warpzone_origin_x);
	WriteCoord(MSG_ENTITY, self.warpzone_origin_y);
	WriteCoord(MSG_ENTITY, self.warpzone_origin_z);
	WriteCoord(MSG_ENTITY, self.warpzone_angles_x);
	WriteCoord(MSG_ENTITY, self.warpzone_angles_y);
	WriteCoord(MSG_ENTITY, self.warpzone_angles_z);
	WriteCoord(MSG_ENTITY, self.warpzone_targetorigin_x);
	WriteCoord(MSG_ENTITY, self.warpzone_targetorigin_y);
	WriteCoord(MSG_ENTITY, self.warpzone_targetorigin_z);
	WriteCoord(MSG_ENTITY, self.warpzone_targetangles_x);
	WriteCoord(MSG_ENTITY, self.warpzone_targetangles_y);
	WriteCoord(MSG_ENTITY, self.warpzone_targetangles_z);

	if(f & 2)
	{
		WriteShort(MSG_ENTITY, self.warpzone_fadestart);
		WriteShort(MSG_ENTITY, self.warpzone_fadeend);
	}

	return TRUE;
}

float WarpZone_Camera_Send(entity to, float sendflags)
{
	float f = 0;
	WriteByte(MSG_ENTITY, ENT_CLIENT_WARPZONE_CAMERA);

	if(self.warpzone_fadestart)
		BITSET_ASSIGN(f, 2);
	if(self.origin != '0 0 0')
		BITSET_ASSIGN(f, 4);
	WriteByte(MSG_ENTITY, f);

	// we need THESE to render the warpzone (and cull properly)...
	if(f & 4)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}

	WriteShort(MSG_ENTITY, self.modelindex);
	WriteCoord(MSG_ENTITY, self.mins_x);
	WriteCoord(MSG_ENTITY, self.mins_y);
	WriteCoord(MSG_ENTITY, self.mins_z);
	WriteCoord(MSG_ENTITY, self.maxs_x);
	WriteCoord(MSG_ENTITY, self.maxs_y);
	WriteCoord(MSG_ENTITY, self.maxs_z);
	WriteByte(MSG_ENTITY, bound(1, self.scale * 16, 255));

	// we need THESE to calculate the proper transform
	WriteCoord(MSG_ENTITY, self.enemy.origin_x);
	WriteCoord(MSG_ENTITY, self.enemy.origin_y);
	WriteCoord(MSG_ENTITY, self.enemy.origin_z);
	WriteCoord(MSG_ENTITY, self.enemy.angles_x);
	WriteCoord(MSG_ENTITY, self.enemy.angles_y);
	WriteCoord(MSG_ENTITY, self.enemy.angles_z);

	if(f & 2)
	{
		WriteShort(MSG_ENTITY, self.warpzone_fadestart);
		WriteShort(MSG_ENTITY, self.warpzone_fadeend);
	}

	return TRUE;
}

#ifdef WARPZONELIB_KEEPDEBUG
float WarpZone_CheckProjectileImpact(entity player)
{
	vector o0, v0;

	o0 = player.origin + player.view_ofs;
	v0 = player.velocity;

	// if we teleported shortly before, abort
	if(time <= player.warpzone_teleport_finishtime + 0.1)
		return 0;

	// if player hit a warpzone, abort
	entity wz;
	wz = WarpZone_Find(o0 + player.mins, o0 + player.maxs);
	if(!wz)
		return 0;

#ifdef WARPZONELIB_REMOVEHACK
	print("impactfilter found something - and it no longer gets handled correctly - please tell divVerent whether anything behaves broken now\n");
#else
	print("impactfilter found something - and it even gets handled correctly - please tell divVerent that this code apparently gets triggered again\n");
#endif
	print("Entity type: ", player.classname, "\n");
	print("Origin: ", vtos(player.origin), "\n");
	print("Velocity: ", vtos(player.velocity), "\n");

#ifdef WARPZONELIB_REMOVEHACK
	return 0;
#else
	// retry previous move
	setorigin(player, player.warpzone_oldorigin);
	player.velocity = player.warpzone_oldvelocity;
	if(WarpZone_Teleport(wz, player, 0, 1))
	{
		entity oldself;
		string save1, save2;

		oldself = self;
		self = wz;
		other = player;
		activator = player;

		save1 = self.target; self.target = string_null;
		save2 = self.target3; self.target3 = string_null;
		SUB_UseTargets();
		if not(self.target) self.target = save1;
		if not(self.target3) self.target3 = save2;

		self = self.enemy;
		save1 = self.target; self.target = string_null;
		save2 = self.target2; self.target2 = string_null;
		SUB_UseTargets();
		if not(self.target) self.target = save1;
		if not(self.target2) self.target2 = save2;
		self = oldself;
	}
	else
	{
		setorigin(player, o0 - player.view_ofs);
		player.velocity = v0;
	}

	return +1;
#endif
}
#endif

float WarpZone_Projectile_Touch()
{
	if(other.classname == "trigger_warpzone")
		return TRUE;

	// no further impacts if we teleported this frame!
	// this is because even if we did teleport, the engine still may raise
	// touch events for the previous location
	// engine now aborts moves on teleport, so this SHOULD not happen any more
	// but if this is called from TouchAreaGrid of the projectile moving,
	// then this won't do
	if(time == self.warpzone_teleport_time)
		return TRUE;

#ifdef WARPZONELIB_KEEPDEBUG
	// this SEEMS to not happen at the moment, but if it did, it would be more reliable
	{
		float save_dpstartcontents;
		float save_dphitcontents;
		float save_dphitq3surfaceflags;
		string save_dphittexturename;
		float save_allsolid;
		float save_startsolid;
		float save_fraction;
		vector save_endpos;
		vector save_plane_normal;
		float save_plane_dist;
		entity save_ent;
		float save_inopen;
		float save_inwater;
		save_dpstartcontents = trace_dpstartcontents;
		save_dphitcontents = trace_dphitcontents;
		save_dphitq3surfaceflags = trace_dphitq3surfaceflags;
		save_dphittexturename = trace_dphittexturename;
		save_allsolid = trace_allsolid;
		save_startsolid = trace_startsolid;
		save_fraction = trace_fraction;
		save_endpos = trace_endpos;
		save_plane_normal = trace_plane_normal;
		save_plane_dist = trace_plane_dist;
		save_ent = trace_ent;
		save_inopen = trace_inopen;
		save_inwater = trace_inwater;
		float f;
		if((f = WarpZone_CheckProjectileImpact(self)) != 0)
			return (f > 0);
		trace_dpstartcontents = save_dpstartcontents;
		trace_dphitcontents = save_dphitcontents;
		trace_dphitq3surfaceflags = save_dphitq3surfaceflags;
		trace_dphittexturename = save_dphittexturename;
		trace_allsolid = save_allsolid;
		trace_startsolid = save_startsolid;
		trace_fraction = save_fraction;
		trace_endpos = save_endpos;
		trace_plane_normal = save_plane_normal;
		trace_plane_dist = save_plane_dist;
		trace_ent = save_ent;
		trace_inopen = save_inopen;
		trace_inwater = save_inwater;
	}
#endif

	if(WarpZone_Projectile_Touch_ImpactFilter_Callback())
		return TRUE;

	return FALSE;
}

void WarpZone_InitStep_FindOriginTarget()
{
	if(self.killtarget != "")
	{
		self.aiment = find(world, targetname, self.killtarget);
		if(self.aiment == world)
		{
			error("Warp zone with nonexisting killtarget");
			return;
		}
		self.killtarget = string_null;
	}
}

void WarpZonePosition_InitStep_FindTarget()
{
	if(self.target == "")
	{
		error("Warp zone position with no target");
		return;
	}
	self.enemy = find(world, targetname, self.target);
	if(self.enemy == world)
	{
		error("Warp zone position with nonexisting target");
		return;
	}
	if(self.enemy.aiment)
	{
		// already is positioned
		error("Warp zone position targeting already oriented warpzone");
		return;
	}
	self.enemy.aiment = self;
}

void WarpZoneCamera_Think(void)
{
	if(self.warpzone_save_origin != self.origin
	|| self.warpzone_save_angles != self.angles
	|| self.warpzone_save_eorigin != self.enemy.origin
	|| self.warpzone_save_eangles != self.enemy.angles)
	{
		WarpZone_Camera_SetUp(self, self.enemy.origin, self.enemy.angles);
		self.warpzone_save_origin = self.origin;
		self.warpzone_save_angles = self.angles;
		self.warpzone_save_eorigin = self.enemy.origin;
		self.warpzone_save_eangles = self.enemy.angles;
	}
	self.nextthink = time;
}

void WarpZoneCamera_InitStep_FindTarget()
{
	entity e;
	float i;
	if(self.target == "")
	{
		error("Camera with no target");
		return;
	}
	self.enemy = world;
	for(e = world, i = 0; (e = find(e, targetname, self.target)); )
		if(random() * ++i < 1)
			self.enemy = e;
	if(self.enemy == world)
	{
		error("Camera with nonexisting target");
		return;
	}
	warpzone_cameras_exist = 1;
	WarpZone_Camera_SetUp(self, self.enemy.origin, self.enemy.angles);
	self.SendFlags = 0xFFFFFF;
	if(self.spawnflags & 1)
	{
		self.think = WarpZoneCamera_Think;
		self.nextthink = time;
	}
	else
		self.nextthink = 0;
}

void WarpZone_InitStep_UpdateTransform()
{
	vector org, ang, norm, point;
	float area;
	vector tri, a, b, c, p, q, n;
	float i_s, i_t, n_t;
	string tex;

	org = self.origin;
	if(org == '0 0 0')
		org = 0.5 * (self.mins + self.maxs);

	norm = point = '0 0 0';
	area = 0;
	for(i_s = 0; ; ++i_s)
	{
		tex = getsurfacetexture(self, i_s);
		if not(tex)
			break; // this is beyond the last one
		if(tex == "textures/common/trigger" || tex == "trigger")
			continue;
		n_t = getsurfacenumtriangles(self, i_s);
		for(i_t = 0; i_t < n_t; ++i_t)
		{
			tri = getsurfacetriangle(self, i_s, i_t);
			a = getsurfacepoint(self, i_s, tri_x);
			b = getsurfacepoint(self, i_s, tri_y);
			c = getsurfacepoint(self, i_s, tri_z);
			p = b - a;
			q = c - a;
			n =     '1 0 0' * (q_y * p_z - q_z * p_y)
			+       '0 1 0' * (q_z * p_x - q_x * p_z)
			+       '0 0 1' * (q_x * p_y - q_y * p_x);
			area = area + vlen(n);
			norm = norm + n;
			point = point + vlen(n) * (a + b + c);
		}
	}
	if(area > 0)
	{
		norm = norm * (1 / area);
		point = point * (1 / (3 * area));
		if(vlen(norm) < 0.99)
		{
			print("trigger_warpzone near ", vtos(self.aiment.origin), " is nonplanar. BEWARE.\n");
			area = 0; // no autofixing in this case
		}
		norm = normalize(norm);
	}

#ifdef GMQCC
	ang = '0 0 0';
#endif
	if(self.aiment)
	{
		org = self.aiment.origin;
		ang = self.aiment.angles;
		if(area > 0)
		{
			org = org - ((org - point) * norm) * norm; // project to plane
			makevectors(ang);
			if(norm * v_forward < 0)
			{
				print("Position target of trigger_warpzone near ", vtos(self.aiment.origin), " points into trigger_warpzone. BEWARE.\n");
				norm = -1 * norm;
			}
			ang = vectoangles2(norm, v_up); // keep rotation, but turn exactly against plane
			ang_x = -ang_x;
			if(norm * v_forward < 0.99)
				print("trigger_warpzone near ", vtos(self.aiment.origin), " has been turned to match plane orientation (", vtos(self.aiment.angles), " -> ", vtos(ang), "\n");
			if(vlen(org - self.aiment.origin) > 0.5)
				print("trigger_warpzone near ", vtos(self.aiment.origin), " has been moved to match the plane (", vtos(self.aiment.origin), " -> ", vtos(org), ").\n");
		}
	}
	else if(area > 0)
	{
		org = point;
		ang = vectoangles(norm);
		ang_x = -ang_x;
	}
	else
		error("cannot infer origin/angles for this warpzone, please use a killtarget or a trigger_warpzone_position");

	self.warpzone_origin = org;
	self.warpzone_angles = ang;
}

void WarpZone_InitStep_ClearTarget()
{
	if(self.enemy)
		self.enemy.enemy = world;
	self.enemy = world;
}

entity warpzone_first; .entity warpzone_next;
void WarpZone_InitStep_FindTarget()
{
	float i;
	entity e, e2;

	if(self.enemy)
		return;

	// this way only one of the two ents needs to target
	if(self.target != "")
	{
		self.enemy = self; // so the if(!e.enemy) check also skips self, saves one IF

		e2 = world;
		for(e = world, i = 0; (e = find(e, targetname, self.target)); )
			if(!e.enemy)
				if(e.classname == self.classname) // possibly non-warpzones may use the same targetname!
					if(random() * ++i < 1)
						e2 = e;
		if(!e2)
		{
			self.enemy = world;
			error("Warpzone with non-existing target");
			return;
		}
		self.enemy = e2;
		e2.enemy = self;
	}
}

void WarpZone_Think();
void WarpZone_InitStep_FinalizeTransform()
{
	if(!self.enemy || self.enemy.enemy != self)
	{
		error("Invalid warp zone detected. Killed.");
		return;
	}

	warpzone_warpzones_exist = 1;
	WarpZone_SetUp(self, self.warpzone_origin, self.warpzone_angles, self.enemy.warpzone_origin, self.enemy.warpzone_angles);
	self.touch = WarpZone_Touch;
	self.SendFlags = 0xFFFFFF;
	if(self.spawnflags & 1)
	{
		self.think = WarpZone_Think;
		self.nextthink = time;
	}
	else
		self.nextthink = 0;
}

float warpzone_initialized;
entity warpzone_first;
entity warpzone_position_first;
entity warpzone_camera_first;
.entity warpzone_next;
void spawnfunc_misc_warpzone_position(void)
{
	// "target", "angles", "origin"
	self.warpzone_next = warpzone_position_first;
	warpzone_position_first = self;
}
void spawnfunc_trigger_warpzone_position(void)
{
	spawnfunc_misc_warpzone_position();
}
void spawnfunc_trigger_warpzone(void)
{
	// warp zone entities must have:
	// "killtarget" pointing to a target_position with a direction arrow
	//              that points AWAY from the warp zone, and that is inside
	//              the warp zone trigger
	// "target"     pointing to an identical warp zone at another place in
	//              the map, with another killtarget to designate its
	//              orientation

#ifndef WARPZONE_USE_FIXANGLE
	// used when teleporting
	precache_model("null");
#endif

	if(!self.scale)
		self.scale = self.modelscale;
	if(!self.scale)
		self.scale = 1;
	string m;
	m = self.model;
	WarpZoneLib_ExactTrigger_Init();
 	if(m != "")
 	{
 		precache_model(m);
 		setmodel(self, m); // no precision needed
	}
	setorigin(self, self.origin);
	if(self.scale)
		setsize(self, self.mins * self.scale, self.maxs * self.scale);
	else
		setsize(self, self.mins, self.maxs);
	self.SendEntity = WarpZone_Send;
	self.SendFlags = 0xFFFFFF;
	BITSET_ASSIGN(self.effects, EF_NODEPTHTEST);
	self.warpzone_next = warpzone_first;
	warpzone_first = self;
}
void spawnfunc_func_camera(void)
{
	if(!self.scale)
		self.scale = self.modelscale;
	if(!self.scale)
		self.scale = 1;
 	if(self.model != "")
 	{
 		precache_model(self.model);
 		setmodel(self, self.model); // no precision needed
	}
	setorigin(self, self.origin);
	if(self.scale)
		setsize(self, self.mins * self.scale, self.maxs * self.scale);
	else
		setsize(self, self.mins, self.maxs);
	if(!self.solid)
		self.solid = SOLID_BSP;
	else if(self.solid < 0)
		self.solid = SOLID_NOT;
	self.SendEntity = WarpZone_Camera_Send;
	self.SendFlags = 0xFFFFFF;
	self.warpzone_next = warpzone_camera_first;
	warpzone_camera_first = self;
}
void WarpZones_Reconnect()
{
	entity e;
	e = self;
	for(self = warpzone_first; self; self = self.warpzone_next)
		WarpZone_InitStep_ClearTarget();
	for(self = warpzone_first; self; self = self.warpzone_next)
		WarpZone_InitStep_FindTarget();
	for(self = warpzone_camera_first; self; self = self.warpzone_next)
		WarpZoneCamera_InitStep_FindTarget();
	for(self = warpzone_first; self; self = self.warpzone_next)
		WarpZone_InitStep_FinalizeTransform();
	self = e;
}

void WarpZone_Think()
{
	if(self.warpzone_save_origin != self.origin
	|| self.warpzone_save_angles != self.angles
	|| self.warpzone_save_eorigin != self.enemy.origin
	|| self.warpzone_save_eangles != self.enemy.angles)
	{
		entity oldself;
		oldself = self;
		WarpZone_InitStep_UpdateTransform();
		self = self.enemy;
		WarpZone_InitStep_UpdateTransform();
		self = oldself;
		WarpZone_InitStep_FinalizeTransform();
		self = self.enemy;
		WarpZone_InitStep_FinalizeTransform();
		self = oldself;
		self.warpzone_save_origin = self.origin;
		self.warpzone_save_angles = self.angles;
		self.warpzone_save_eorigin = self.enemy.origin;
		self.warpzone_save_eangles = self.enemy.angles;
	}
	self.nextthink = time;
}

void WarpZone_StartFrame()
{
	entity e;
	if(warpzone_initialized == 0)
	{
		warpzone_initialized = 1;
		e = self;
		for(self = warpzone_first; self; self = self.warpzone_next)
			WarpZone_InitStep_FindOriginTarget();
		for(self = warpzone_position_first; self; self = self.warpzone_next)
			WarpZonePosition_InitStep_FindTarget();
		for(self = warpzone_first; self; self = self.warpzone_next)
			WarpZone_InitStep_UpdateTransform();
		self = e;
		WarpZones_Reconnect();
		WarpZone_PostInitialize_Callback();
	}

	entity oldself, oldother;
	oldself = self;
	oldother = other;
	for(e = world; (e = nextent(e)); )
	{
		if(warpzone_warpzones_exist) { WarpZone_StoreProjectileData(e); }
		
		if(IS_REAL_CLIENT(e))
		{
			if(e.solid == SOLID_NOT) // not spectating?
			if(e.movetype == MOVETYPE_NOCLIP || e.movetype == MOVETYPE_FLY || e.movetype == MOVETYPE_FLY_WORLDONLY) // not spectating? (this is to catch observers)
			{
				other = e; // player
			
				// warpzones
				if(warpzone_warpzones_exist) { 
				self = WarpZone_Find(e.origin + e.mins, e.origin + e.maxs); 
				if(self)
				if(!WarpZoneLib_ExactTrigger_Touch())
					if(WarpZone_PlaneDist(self, e.origin + e.view_ofs) <= 0)
						WarpZone_Teleport(self, e, -1, 0); } // NOT triggering targets by this!
			
				// teleporters
				self = Teleport_Find(e.origin + e.mins, e.origin + e.maxs);
				if(self)
				if(!WarpZoneLib_ExactTrigger_Touch())
					Simple_TeleportPlayer(self, other); // NOT triggering targets by this!
			}
		}
		
		if(IS_NOT_A_CLIENT(e))
		{
			if(warpzone_warpzones_exist)
				for(; (e = nextent(e)); )
					WarpZone_StoreProjectileData(e);
			break;
		}
	}
	self = oldself;
	other = oldother;
}

.float warpzone_reconnecting;
float visible_to_some_client(entity ent)
{
	entity e;
	for(e = nextent(world); !IS_NOT_A_CLIENT(e); e = nextent(e))
		if(IS_PLAYER(e) && IS_REAL_CLIENT(e))
			if(checkpvs(e.origin + e.view_ofs, ent))
				return 1;
	return 0;
}
void trigger_warpzone_reconnect_use()
{
	entity e;
	e = self;
	// NOTE: this matches for target, not targetname, but of course
	// targetname must be set too on the other entities
	for(self = warpzone_first; self; self = self.warpzone_next)
		self.warpzone_reconnecting = ((e.target == "" || self.target == e.target) && !((e.spawnflags & 1) && (visible_to_some_client(self) || visible_to_some_client(self.enemy))));
	for(self = warpzone_camera_first; self; self = self.warpzone_next)
		self.warpzone_reconnecting = ((e.target == "" || self.target == e.target) && !((e.spawnflags & 1) && visible_to_some_client(self)));
	for(self = warpzone_first; self; self = self.warpzone_next)
		if(self.warpzone_reconnecting)
			WarpZone_InitStep_ClearTarget();
	for(self = warpzone_first; self; self = self.warpzone_next)
		if(self.warpzone_reconnecting)
			WarpZone_InitStep_FindTarget();
	for(self = warpzone_camera_first; self; self = self.warpzone_next)
		if(self.warpzone_reconnecting)
			WarpZoneCamera_InitStep_FindTarget();
	for(self = warpzone_first; self; self = self.warpzone_next)
		if(self.warpzone_reconnecting || self.enemy.warpzone_reconnecting)
			WarpZone_InitStep_FinalizeTransform();
	self = e;
}

void spawnfunc_trigger_warpzone_reconnect()
{
	self.use = trigger_warpzone_reconnect_use;
}

void spawnfunc_target_warpzone_reconnect()
{
	spawnfunc_trigger_warpzone_reconnect(); // both names make sense here :(
}

void WarpZone_PlayerPhysics_FixVAngle(void)
{
#ifndef WARPZONE_DONT_FIX_VANGLE
	if(IS_REAL_CLIENT(self))
	if(self.v_angle_z <= 360) // if not already adjusted
	if(time - self.ping * 0.001 < self.warpzone_teleport_time)
	{
		self.v_angle = WarpZone_TransformVAngles(self.warpzone_teleport_zone, self.v_angle);
		self.v_angle_z += 720; // mark as adjusted
	}
#endif
}
