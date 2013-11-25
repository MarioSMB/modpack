// =========================
//  SVQC Vehicle Properties
// =========================


float SendAuxiliaryXhair(entity to, float sf)
{

	WriteByte(MSG_ENTITY, ENT_CLIENT_AUXILIARYXHAIR);

	WriteByte(MSG_ENTITY, self.cnt);

	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);

	WriteByte(MSG_ENTITY, rint(self.colormod_x * 255));
	WriteByte(MSG_ENTITY, rint(self.colormod_y * 255));
	WriteByte(MSG_ENTITY, rint(self.colormod_z * 255));

	return TRUE;
}

void UpdateAuxiliaryXhair(entity own, vector loc, vector clr, float axh_id)
{
	if(!IS_REAL_CLIENT(own))
		return;

	entity axh;

	axh_id = bound(0, axh_id, MAX_AXH);
	axh = own.(AuxiliaryXhair[axh_id]);

	if(axh == world || wasfreed(axh))  // MADNESS? THIS IS QQQQCCCCCCCCC (wasfreed, why do you exsist?)
	{
		axh					 = spawn();
		axh.cnt				 = axh_id;
		axh.drawonlytoclient	= own;
		axh.owner			   = own;
		Net_LinkEntity(axh, FALSE, 0, SendAuxiliaryXhair);
	}

	setorigin(axh, loc);
	axh.colormod			= clr;
	axh.SendFlags		   = 0x01;
	own.(AuxiliaryXhair[axh_id]) = axh;
}

void CSQCVehicleSetup(entity own, float vehicle_id)
{
	if(!IS_REAL_CLIENT(own))
		return;

	msg_entity = own;

	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_VEHICLESETUP);
	WriteByte(MSG_ONE, vehicle_id);
}

vector targetdrone_getnewspot()
{
	vector spot;
	float i;
	for(i = 0; i < 100; ++i)
	{
		spot = self.origin + randomvec() * 1024;
		tracebox(spot, self.mins, self.maxs, spot, MOVE_NORMAL, self);
		if(trace_fraction == 1.0 && trace_startsolid == 0 && trace_allsolid == 0)
			return spot;
	}
	return self.origin;
}

void vehicles_locktarget(float incr, float decr, float _lock_time)
{
	if(self.lock_target && self.lock_target.deadflag != DEAD_NO)
	{
		self.lock_target	= world;
		self.lock_strength  = 0;
		self.lock_time	  = 0;
	}

	if(self.lock_time > time)
	{
		if(self.lock_target)
		if(self.lock_soundtime < time)
		{
			self.lock_soundtime = time + 0.5;
			play2(self.owner, "vehicles/locked.wav");
		}

		return;
	}

	if(trace_ent != world)
	{
		if(teamplay && trace_ent.team == self.team)
			trace_ent = world;

		if(trace_ent.deadflag != DEAD_NO)
			trace_ent = world;

		if(!(IS_VEHICLE(trace_ent) || IS_TURRET(trace_ent)))
			trace_ent = world;
	}

	if(self.lock_target == world && trace_ent != world)
		self.lock_target = trace_ent;

	if(self.lock_target && trace_ent == self.lock_target)
	{
		if(self.lock_strength != 1 && self.lock_strength + incr >= 1)
		{
			play2(self.owner, "vehicles/lock.wav");
			self.lock_soundtime = time + 0.8;
		}
		else if (self.lock_strength != 1 && self.lock_soundtime < time)
		{
			play2(self.owner, "vehicles/locking.wav");
			self.lock_soundtime = time + 0.3;
		}
	}

	// Have a locking target
	// Trace hit current target
	if(trace_ent == self.lock_target && trace_ent != world)
	{
		self.lock_strength = min(self.lock_strength + incr, 1);
		if(self.lock_strength == 1)
			self.lock_time = time + _lock_time;
	}
	else
	{
		if(trace_ent)
			self.lock_strength = max(self.lock_strength - decr * 2, 0);
		else
			self.lock_strength = max(self.lock_strength - decr, 0);

		if(self.lock_strength == 0)
			self.lock_target = world;
	}
}

vector vehicles_force_fromtag_hover(string tag_name, float spring_length, float max_power)
{
	force_fromtag_origin = gettaginfo(self, gettagindex(self, tag_name));
	v_forward  = normalize(v_forward) * -1;
	traceline(force_fromtag_origin, force_fromtag_origin - (v_forward  * spring_length), MOVE_NORMAL, self);

	force_fromtag_power = (1 - trace_fraction) * max_power;
	force_fromtag_normpower = force_fromtag_power / max_power;

	return v_forward  * force_fromtag_power;
}

vector vehicles_force_fromtag_maglev(string tag_name, float spring_length, float max_power)
{

	force_fromtag_origin = gettaginfo(self, gettagindex(self, tag_name));
	v_forward  = normalize(v_forward) * -1;
	traceline(force_fromtag_origin, force_fromtag_origin - (v_forward  * spring_length), MOVE_NORMAL, self);

	// TODO - this may NOT be compatible with wall/celing movement, unhardcode 0.25 (engine count multiplier)
	if(trace_fraction == 1.0)
	{
		force_fromtag_normpower = -0.25;
		return '0 0 -200';
	}

	force_fromtag_power = ((1 - trace_fraction) - trace_fraction) * max_power;
	force_fromtag_normpower = force_fromtag_power / max_power;

	return v_forward  * force_fromtag_power;
}

// projectile handling
void vehicles_projectile_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	// Ignore damage from oterh projectiles from my owner (dont mess up volly's)
	if(inflictor.owner == self.owner)
		return;

	self.health -= damage;
	self.velocity += force;
	if(self.health < 1)
	{
		self.takedamage = DAMAGE_NO;
		self.event_damage = func_null;
		self.think = self.use;
		self.nextthink = time;
	}
}

void vehicles_projectile_explode()
{
	if(self.owner && other != world)
	{
		if(other == self.owner.vehicle)
			return;

		if(other == self.owner.vehicle.tur_head)
			return;
	}

	PROJECTILE_TOUCH;

	self.event_damage = func_null;
	RadiusDamage (self, self.realowner, self.shot_dmg, 0, self.shot_radius, self, self.shot_force, self.totalfrags, other);

	remove (self);
}

entity vehicles_projectile(string _mzlfx, string _mzlsound,
						   vector _org, vector _vel,
						   float _dmg, float _radi, float _force,  float _size,
						   float _deahtype, float _projtype, float _health,
						   float _cull, float _clianim, entity _owner)
{
	entity proj;

	proj = spawn();

	PROJECTILE_MAKETRIGGER(proj);
	setorigin(proj, _org);

	proj.shot_dmg		 = _dmg;
	proj.shot_radius	  = _radi;
	proj.shot_force	   = _force;
	proj.totalfrags	   = _deahtype;
	proj.solid			= SOLID_BBOX;
	proj.movetype		 = MOVETYPE_FLYMISSILE;
	proj.flags			= FL_PROJECTILE;
	proj.bot_dodge		= TRUE;
	proj.bot_dodgerating  = _dmg;
	proj.velocity		 = _vel;
	proj.touch			= vehicles_projectile_explode;
	proj.use			  = vehicles_projectile_explode;
	proj.owner			= self;
	proj.realowner		= _owner;
	proj.think			= SUB_Remove;
	proj.nextthink		= time + 30;

	if(_health)
	{
		proj.takedamage	   = DAMAGE_AIM;
		proj.event_damage	 = vehicles_projectile_damage;
		proj.health		   = _health;
	}
	else
		proj.flags		   = FL_PROJECTILE | FL_NOTARGET;

	if(_mzlsound)
		sound (self, CH_WEAPON_A, _mzlsound, VOL_BASE, ATTEN_NORM);

	if(_mzlfx)
		pointparticles(particleeffectnum(_mzlfx), proj.origin, proj.velocity, 1);


	setsize (proj, '-1 -1 -1' * _size, '1 1 1' * _size);

	CSQCProjectile(proj, _clianim, _projtype, _cull);

	return proj;
}

void vehicles_gib_explode()
{
	sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	remove(self);
}

void vehicles_gib_think()
{
	self.alpha -= 0.1;
	if(self.cnt >= time)
		remove(self);
	else
		self.nextthink = time + 0.1;
}

entity vehicle_tossgib(entity _template, vector _vel, string _tag, float _burn, float _explode, float _maxtime, vector _rot)
{
	entity _gib = spawn();
	setmodel(_gib, _template.model);
	setorigin(_gib, gettaginfo(self, gettagindex(self, _tag)));
	_gib.velocity = _vel;
	_gib.movetype = MOVETYPE_TOSS;
	_gib.solid = SOLID_CORPSE;
	_gib.colormod = '-0.5 -0.5 -0.5';
	_gib.effects = EF_LOWPRECISION;
	_gib.avelocity = _rot;

	if(_burn)
		_gib.effects |= EF_FLAME;

	if(_explode)
	{
		_gib.think = vehicles_gib_explode;
		_gib.nextthink = time + random() * _explode;
		_gib.touch = vehicles_gib_explode;
	}
	else
	{
		_gib.cnt = time + _maxtime;
		_gib.think = vehicles_gib_think;
		_gib.nextthink = time + _maxtime - 1;
		_gib.alpha = 1;
	}
	return _gib;
}

float vehicle_addplayerslot(	entity _owner,
								entity _slot,
								float _hud,
								string _hud_model,
								float() _framefunc,
								void(float) _exitfunc)
{
	if(!(_owner.vehicle_flags & VHF_MULTISLOT))
		_owner.vehicle_flags |= VHF_MULTISLOT;

	_slot.PlayerPhysplug = _framefunc;
	_slot.vehicle_exit = _exitfunc;
	_slot.hud = _hud;
	_slot.vehicle_flags = VHF_PLAYERSLOT;
	_slot.vehicle_viewport = spawn();
	_slot.vehicle_hudmodel = spawn();
	_slot.vehicle_hudmodel.viewmodelforclient = _slot;
	_slot.vehicle_viewport.effects = (EF_ADDITIVE | EF_DOUBLESIDED | EF_FULLBRIGHT | EF_NODEPTHTEST | EF_NOGUNBOB | EF_NOSHADOW | EF_LOWPRECISION | EF_SELECTABLE | EF_TELEPORT_BIT);

	setmodel(_slot.vehicle_hudmodel, _hud_model);
	setmodel(_slot.vehicle_viewport, "null");

	setattachment(_slot.vehicle_hudmodel, _slot, "");
	setattachment(_slot.vehicle_viewport, _slot.vehicle_hudmodel, "");

	return TRUE;
}

vector vehicle_aimturret(entity _vehic, vector _target, entity _turrret, string _tagname,
						 float _pichlimit_min, float _pichlimit_max,
						 float _rotlimit_min, float _rotlimit_max, float _aimspeed)
{
	vector vtmp, vtag;
	float ftmp;
	vtag = gettaginfo(_turrret, gettagindex(_turrret, _tagname));
	vtmp = vectoangles(normalize(_target - vtag));
	vtmp = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(_vehic.angles), AnglesTransform_FromAngles(vtmp))) - _turrret.angles;
	vtmp = AnglesTransform_Normalize(vtmp, TRUE);
	ftmp = _aimspeed * frametime;
	vtmp_y = bound(-ftmp, vtmp_y, ftmp);
	vtmp_x = bound(-ftmp, vtmp_x, ftmp);
	_turrret.angles_y = bound(_rotlimit_min, _turrret.angles_y + vtmp_y, _rotlimit_max);
	_turrret.angles_x = bound(_pichlimit_min, _turrret.angles_x + vtmp_x, _pichlimit_max);
	return vtag;
}

void vehicles_reset_colors()
{
	entity e;
	float _effects = 0, _colormap;
	vector _glowmod, _colormod;

	if(autocvar_g_nodepthtestplayers)
		_effects |= EF_NODEPTHTEST;

	if(autocvar_g_fullbrightplayers)
		_effects |= EF_FULLBRIGHT;

	if(self.team)
		_colormap = 1024 + (self.team - 1) * 17;
	else
		_colormap = 1024;

	_glowmod  = '0 0 0';
	_colormod = '0 0 0';

	// Find all ents attacked to main model and setup effects, colormod etc.
	e = findchainentity(tag_entity, self);
	while(e)
	{
		if(e != self.vehicle_shieldent)
		{
			e.effects   = _effects; //  | EF_LOWPRECISION;
			e.colormod  = _colormod;
			e.colormap  = _colormap;
			e.alpha	 = 1;
		}
		e = e.chain;
	}

	self.vehicle_hudmodel.effects  = self.effects  = _effects; // | EF_LOWPRECISION;
	self.vehicle_hudmodel.colormod = self.colormod = _colormod;
	self.vehicle_hudmodel.colormap = self.colormap = _colormap;
	self.vehicle_viewport.effects = (EF_ADDITIVE | EF_DOUBLESIDED | EF_FULLBRIGHT | EF_NODEPTHTEST | EF_NOGUNBOB | EF_NOSHADOW | EF_LOWPRECISION | EF_SELECTABLE | EF_TELEPORT_BIT);

	self.alpha	 = 1;
	self.avelocity = '0 0 0';
	self.velocity  = '0 0 0';
	self.effects   = _effects;
}

void vehicles_clearreturn(entity veh)
{
	entity ret;
	// Remove "return helper", if any.
	ret = findchain(classname, "vehicle_return");
	while(ret)
	{
		if(ret.wp00 == veh)
		{
			ret.classname   = "";
			ret.think	   = SUB_Remove;
			ret.nextthink   = time + 0.1;

			if(ret.waypointsprite_attached)
				WaypointSprite_Kill(ret.waypointsprite_attached);

			return;
		}
		ret = ret.chain;
	}
}

void vehicles_spawn();
void vehicles_return()
{
	pointparticles(particleeffectnum("teleport"), self.wp00.origin + '0 0 64', '0 0 0', 1);

	self.wp00.think	 = vehicles_spawn;
	self.wp00.nextthink = time;

	if(self.waypointsprite_attached)
		WaypointSprite_Kill(self.waypointsprite_attached);

	remove(self);
}

void vehicles_showwp_goaway()
{
	if(self.waypointsprite_attached)
		WaypointSprite_Kill(self.waypointsprite_attached);

	remove(self);

}

void vehicles_showwp()
{
	entity oldself = world;
	vector rgb;

	if(self.cnt)
	{
		self.think	  = vehicles_return;
		self.nextthink  = self.cnt;
	}
	else
	{
		self.think	  = vehicles_return;
		self.nextthink  = time +1;

		oldself = self;
		self = spawn();
		setmodel(self, "null");
		self.team = oldself.wp00.team;
		self.wp00 = oldself.wp00;
		setorigin(self, oldself.wp00.pos1);

		self.nextthink = time + 5;
		self.think = vehicles_showwp_goaway;
	}

	if(teamplay && self.team)
		rgb = Team_ColorRGB(self.team);
	else
		rgb = '1 1 1';
	WaypointSprite_Spawn("vehicle", 0, 0, self, '0 0 64', world, 0, self, waypointsprite_attached, TRUE, RADARICON_POWERUP, rgb);
	if(self.waypointsprite_attached)
	{
		WaypointSprite_UpdateRule(self.waypointsprite_attached, self.wp00.team, SPRITERULE_DEFAULT);
		if(oldself == world)
			WaypointSprite_UpdateBuildFinished(self.waypointsprite_attached, self.nextthink);
		WaypointSprite_Ping(self.waypointsprite_attached);
	}

	if(oldself != world)
		self = oldself;
}

void vehicles_setreturn(entity veh)
{
	entity ret;

	vehicles_clearreturn(veh);

	ret = spawn();
	ret.classname   = "vehicle_return";
	ret.wp00	   = veh;
	ret.team		= veh.team;
	ret.think	   = vehicles_showwp;

	if(veh.deadflag != DEAD_NO)
	{
		ret.cnt		 = time + veh.respawntime;
		ret.nextthink   = min(time + veh.respawntime, time + veh.respawntime - 5);
	}
	else
	{
		ret.nextthink   = min(time + veh.respawntime, time + veh.respawntime - 1);
	}

	setmodel(ret, "null");
	setorigin(ret, veh.pos1 + '0 0 96');

}

void vehicle_use()
{
	dprint("vehicle ",self.netname, " used by ", activator.classname, "\n");

	self.tur_head.team = activator.team;

	if(self.tur_head.team == 0)
		self.active = ACTIVE_NOT;
	else
		self.active = ACTIVE_ACTIVE;

	if(self.active == ACTIVE_ACTIVE && self.deadflag == DEAD_NO)
	{
		dprint("Respawning vehicle: ", self.netname, "\n");
		vehicles_setreturn(self);
		vehicles_reset_colors();
	}
}

void vehicles_regen(float timer, .float regen_field, float field_max, float rpause, float regen, float delta_time, float _healthscale)
{
	if(self.regen_field < field_max)
	if(timer + rpause < time)
	{
		if(_healthscale)
			regen = regen * (self.vehicle_health / self.max_health);

		self.regen_field = min(self.regen_field + regen * delta_time, field_max);

		if(self.owner)
			self.owner.regen_field = (self.regen_field / field_max) * 100;
	}
}

void shieldhit_think()
{
	self.alpha -= 0.1;
	if (self.alpha <= 0)
	{
		//setmodel(self, "");
		self.alpha = -1;
		self.effects |= EF_NODRAW;
	}
	else
	{
		self.nextthink = time + 0.1;
	}
}

void vehicles_painframe()
{
	if(self.owner.vehicle_health <= 50)
	if(self.pain_frame < time)
	{
		float _ftmp;
		_ftmp = self.owner.vehicle_health / 50;
		self.pain_frame = time + 0.1 + (random() * 0.5 * _ftmp);
		pointparticles(particleeffectnum("smoke_small"), (self.origin + (randomvec() * 80)), '0 0 0', 1);

		if(self.vehicle_flags & VHF_DMGSHAKE)
			self.velocity += randomvec() * 30;

		if(self.vehicle_flags & VHF_DMGROLL)
			if(self.vehicle_flags & VHF_DMGHEADROLL)
				self.tur_head.angles += randomvec();
			else
				self.angles += randomvec();

	}
}

void vehicles_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.dmg_time = time;

	if(DEATH_ISWEAPON(deathtype, WEP_NEX))
		damage *= autocvar_g_vehicles_nex_damagerate;

	if(DEATH_ISWEAPON(deathtype, WEP_UZI))
		damage *= autocvar_g_vehicles_uzi_damagerate;

	if(DEATH_ISWEAPON(deathtype, WEP_RIFLE))
		damage *= autocvar_g_vehicles_rifle_damagerate;

	if(DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
		damage *= autocvar_g_vehicles_minstanex_damagerate;

	if(DEATH_ISWEAPON(deathtype, WEP_SEEKER))
		damage *= autocvar_g_vehicles_tag_damagerate;

	self.enemy = attacker;

	if((self.vehicle_flags & VHF_HASSHIELD) && (self.vehicle_shield > 0))
	{
		if (wasfreed(self.vehicle_shieldent) || self.vehicle_shieldent == world)
		{
			self.vehicle_shieldent = spawn();
			self.vehicle_shieldent.effects = EF_LOWPRECISION;

			setmodel(self.vehicle_shieldent, "models/vhshield.md3");
			setattachment(self.vehicle_shieldent, self, "");
			setorigin(self.vehicle_shieldent, real_origin(self) - self.origin);
			self.vehicle_shieldent.scale	   = 256 / vlen(self.maxs - self.mins);
			self.vehicle_shieldent.think	   = shieldhit_think;
		}

		self.vehicle_shieldent.colormod	= '1 1 1';
		self.vehicle_shieldent.alpha = 0.45;
		self.vehicle_shieldent.angles = vectoangles(normalize(hitloc - (self.origin + self.vehicle_shieldent.origin))) - self.angles;
		self.vehicle_shieldent.nextthink = time;
		self.vehicle_shieldent.effects &= ~EF_NODRAW;

		self.vehicle_shield -= damage;

		if(self.vehicle_shield < 0)
		{
			self.vehicle_health -= fabs(self.vehicle_shield);
			self.vehicle_shieldent.colormod = '2 0 0';
			self.vehicle_shield = 0;
			self.vehicle_shieldent.alpha = 0.75;

			if(sound_allowed(MSG_BROADCAST, attacker))
				spamsound (self, CH_PAIN, "onslaught/ons_hit2.wav", VOL_BASE, ATTEN_NORM);   // FIXME: PLACEHOLDER
		}
		else
			if(sound_allowed(MSG_BROADCAST, attacker))
				spamsound (self, CH_PAIN, "onslaught/electricity_explode.wav", VOL_BASE, ATTEN_NORM);  // FIXME: PLACEHOLDER

	}
	else
	{
		self.vehicle_health -= damage;

		if(sound_allowed(MSG_BROADCAST, attacker))
			spamsound (self, CH_PAIN, "onslaught/ons_hit2.wav", VOL_BASE, ATTEN_NORM);  // FIXME: PLACEHOLDER
	}

	if(self.damageforcescale < 1 && self.damageforcescale > 0)
		self.velocity += force * self.damageforcescale;
	else
		self.velocity += force;

	if(self.vehicle_health <= 0)
	{
		if(self.owner)
			if(self.vehicle_flags & VHF_DEATHEJECT)
				vehicles_exit(VHEF_EJECT);
			else
				vehicles_exit(VHEF_RELESE);


		antilag_clear(self);

		VEH_ACTION(self.vehicleid, VR_DEATH);
		vehicles_setreturn(self);
	}
}

float vehicles_crushable(entity e)
{
	if(IS_PLAYER(e))
		return TRUE;

	if(e.flags & FL_MONSTER)
		return TRUE;

	return FALSE;
}

void vehicles_impact(float _minspeed, float _speedfac, float _maxpain)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
		return;

	if(self.play_time < time)
	{
		float wc = vlen(self.velocity - self.oldvelocity);
		//dprint("oldvel: ", vtos(self.oldvelocity), "\n");
		//dprint("vel: ", vtos(self.velocity), "\n");
		if(_minspeed < wc)
		{
			float take = min(_speedfac * wc, _maxpain);
			Damage (self, world, world, take, DEATH_FALL, self.origin, '0 0 0');
			self.play_time = time + 0.25;

			//dprint("wc: ", ftos(wc), "\n");
			//dprint("take: ", ftos(take), "\n");
		}
	}
}

// vehicle enter/exit handling
vector vehicles_findgoodexit(vector prefer_spot)
{
	//vector exitspot;
	float mysize;

	tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, prefer_spot, MOVE_NORMAL, self.owner);
	if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
		return prefer_spot;

	mysize = 1.5 * vlen(self.maxs - self.mins);
	float i;
	vector v, v2;
	v2 = 0.5 * (self.absmin + self.absmax);
	for(i = 0; i < 100; ++i)
	{
		v = randomvec();
		v_z = 0;
		v = v2 + normalize(v) * mysize;
		tracebox(v2, PL_MIN, PL_MAX, v, MOVE_NORMAL, self.owner);
		if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
			return v;
	}

	/*
	exitspot = (self.origin + '0 0 48') + v_forward * mysize;
	tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
	if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
		return exitspot;

	exitspot = (self.origin + '0 0 48') - v_forward * mysize;
	tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
	if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
		return exitspot;

	exitspot = (self.origin + '0 0 48') + v_right * mysize;
	tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
	if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
		return exitspot;

	exitspot = (self.origin + '0 0 48') - v_right * mysize;
	tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
	if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
		return exitspot;
	*/

	return self.origin;
}

void vehicles_exit(float eject)
{
	entity _vehicle;
	entity _player;
	entity _oldself = self;

	if(vehicles_exit_running)
	{
		dprint("^1vehicles_exit allready running! this is not good..\n");
		return;
	}

	vehicles_exit_running = TRUE;
	if(IS_CLIENT(self))
	{
		_vehicle = self.vehicle;

		if (_vehicle.vehicle_flags & VHF_PLAYERSLOT)
		{
			_vehicle.vehicle_exit(eject);
			self = _oldself;
			vehicles_exit_running = FALSE;
			return;
		}
	}
	else
		_vehicle = self;

	_player = _vehicle.owner;

	self = _vehicle;

	if (_player)
	{
		if (IS_REAL_CLIENT(_player))
		{
			msg_entity = _player;
			WriteByte (MSG_ONE, SVC_SETVIEWPORT);
			WriteEntity( MSG_ONE, _player);

			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
			WriteAngle(MSG_ONE, 0);
			WriteAngle(MSG_ONE, _vehicle.angles_y);
			WriteAngle(MSG_ONE, 0);
		}

		setsize(_player, PL_MIN,PL_MAX);

		_player.takedamage		= DAMAGE_AIM;
		_player.solid			= SOLID_SLIDEBOX;
		_player.movetype		= MOVETYPE_WALK;
		_player.effects		   &= ~EF_NODRAW;
		_player.alpha			= 1;
		_player.PlayerPhysplug	= func_null;
		_player.vehicle			= world;
		_player.view_ofs		= PL_VIEW_OFS;
		_player.event_damage	= PlayerDamage;
		_player.hud				= HUD_NORMAL;
		_player.switchweapon	= _vehicle.switchweapon;
		_player.last_vehiclecheck = time + 3;

		CSQCVehicleSetup(_player, HUD_NORMAL);
	}
	_vehicle.flags |= FL_NOTARGET;

	if(_vehicle.deadflag == DEAD_NO)
		_vehicle.avelocity = '0 0 0';

	_vehicle.tur_head.nodrawtoclient = world;

	if(!teamplay)
		_vehicle.team = 0;

	Kill_Notification(NOTIF_ONE, _player, MSG_CENTER_CPID, CPID_VEHICLES);
	Kill_Notification(NOTIF_ONE, _player, MSG_CENTER_CPID, CPID_VEHICLES_OTHER); // kill all vehicle notifications when exiting a vehicle?

	WaypointSprite_Kill(_vehicle.wps_intruder);

	vh_player = _player;
	vh_vehicle = _vehicle;
	MUTATOR_CALLHOOK(VehicleExit);
	_player = vh_player;
	_vehicle = vh_vehicle;

	_vehicle.team = _vehicle.tur_head.team;

	sound (_vehicle, CH_TRIGGER_SINGLE, "misc/null.wav", 1, ATTEN_NORM);
	_vehicle.vehicle_hudmodel.viewmodelforclient = _vehicle;
	_vehicle.phase = time + 1;

	_vehicle.vehicle_exit(eject);

	vehicles_setreturn(_vehicle);
	vehicles_reset_colors();
	_vehicle.owner = world;
	self = _oldself;

	vehicles_exit_running = FALSE;
}

void vehicles_touch()
{
	if(MUTATOR_CALLHOOK(VehicleTouch))
		return;

	// Vehicle currently in use
	if(self.owner)
	{
		if(other != world)
		if(vehicles_crushable(other))
		{
			if(vlen(self.velocity) != 0)
				Damage(other, self, self.owner, autocvar_g_vehicles_crush_dmg, DEATH_VH_CRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);

			return; // Dont do selfdamage when hitting "soft targets".
		}

		if(self.play_time < time)
			VEH_ACTION(self.vehicleid, VR_IMPACT);

		return;
	}

	if(autocvar_g_vehicles_enter)
		return;

	vehicles_enter(other, self);
}

void vehicles_enter(entity pl, entity veh)
{
   // Remove this when bots know how to use vehicles
	if (IS_BOT_CLIENT(pl))
	if (autocvar_g_vehicles_allow_bots)
		dprint("Bot enters vehicle\n"); // This is where we need to disconnect (some, all?) normal bot AI and hand over to vehicle's _aiframe()
	else
		return;

	if(!IS_PLAYER(pl))
		return;

	if(veh.phase > time)
		return;

	if(pl.frozen)
		return;

	if(pl.deadflag != DEAD_NO)
		return;

	if(pl.vehicle)
		return;

	if(teamplay)
	if(veh.team)
	if(DIFF_TEAM(pl, veh))
	if(autocvar_g_vehicles_steal)
	if(autocvar_g_vehicles_steal_show_waypoint)
	{
		entity head;
		FOR_EACH_PLAYER(head) if(SAME_TEAM(head, veh))
			Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_VEHICLE_STEAL);

		Send_Notification(NOTIF_ONE, pl, MSG_CENTER, CENTER_VEHICLE_STEAL_SELF);

		WaypointSprite_Spawn("intruder", 0, 0, pl, '0 0 68', world, veh.team, veh, wps_intruder, TRUE, RADARICON_DANGER, Team_ColorRGB(pl.team));
	}
	else return;

	RemoveGrapplingHook(pl);

	veh.vehicle_ammo1 = 0;
	veh.vehicle_ammo2 = 0;
	veh.vehicle_reload1 = 0;
	veh.vehicle_reload2 = 0;
	veh.vehicle_energy = 0;

	veh.owner = pl;
	pl.vehicle = veh;

	// .viewmodelforclient works better.
	//veh.vehicle_hudmodel.drawonlytoclient = veh.owner;

	veh.vehicle_hudmodel.viewmodelforclient = pl;

	veh.event_damage	= vehicles_damage;
	veh.nextthink		= 0;
	pl.angles			= veh.angles;
	pl.takedamage		= DAMAGE_NO;
	pl.solid			= SOLID_NOT;
	pl.movetype			= MOVETYPE_NOCLIP;
	pl.alpha			= -1;
	pl.vehicle			= veh;
	pl.event_damage		= func_null;
	pl.view_ofs			= '0 0 0';
	veh.colormap		= pl.colormap;
	if(veh.tur_head)
		veh.tur_head.colormap = pl.colormap;
	veh.switchweapon = pl.switchweapon;
	pl.hud = veh.vehicleid;
	pl.PlayerPhysplug = veh.PlayerPhysplug;

	pl.vehicle_ammo1 = veh.vehicle_ammo1;
	pl.vehicle_ammo2 = veh.vehicle_ammo2;
	pl.vehicle_reload1 = veh.vehicle_reload1;
	pl.vehicle_reload2 = veh.vehicle_reload2;

	// Cant do this, hides attached objects too.
	//veh.exteriormodeltoclient = veh.owner;
	//veh.tur_head.exteriormodeltoclient = veh.owner;

	pl.flags &= ~FL_ONGROUND;
	veh.flags &= ~FL_ONGROUND;

	veh.team = pl.team;
	veh.flags -= FL_NOTARGET;

	if (IS_REAL_CLIENT(pl))
	{
		Send_Notification(NOTIF_ONE, pl, MSG_CENTER, CENTER_VEHICLE_ENTER);

		msg_entity = pl;
		WriteByte (MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, veh.vehicle_viewport);

		WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
		if(veh.tur_head)
		{
			WriteAngle(MSG_ONE, veh.tur_head.angles_x + veh.angles_x); // tilt
			WriteAngle(MSG_ONE, veh.tur_head.angles_y + veh.angles_y); // yaw
			WriteAngle(MSG_ONE, 0);									  // roll
		}
		else
		{
			WriteAngle(MSG_ONE, veh.angles_x * -1); // tilt
			WriteAngle(MSG_ONE, veh.angles_y);	  // yaw
			WriteAngle(MSG_ONE, 0);				  // roll
		}
	}

	vehicles_clearreturn(veh);

	CSQCVehicleSetup(pl, veh.vehicleid);

	vh_player = pl;
	vh_vehicle = veh;
	MUTATOR_CALLHOOK(VehicleEnter);
	pl = vh_player;
	veh = vh_vehicle;

	entity oldself = self;
	self = veh;
	VEH_ACTION(veh.vehicleid, VR_ENTER);
	self = oldself;

	antilag_clear(pl);
}

void vehicles_think()
{
	self.nextthink = time;
	
	if(self.owner)
		self.owner.vehicle_weapon2mode = self.vehicle_weapon2mode;
	
	VEH_ACTION(self.vehicleid, VR_THINK);
}

// initialization
void vehicles_spawn()
{
	dprint("Spawning vehicle: ", self.netname, "\n");

	// disown & reset
	self.vehicle_hudmodel.viewmodelforclient = self;

	self.owner				= world;
	self.touch				= vehicles_touch;
	self.event_damage		= vehicles_damage;
	self.iscreature			= TRUE;
	self.teleportable		= FALSE; // no teleporting for vehicles, too buggy
	self.damagedbycontents	= TRUE;
	self.movetype			= MOVETYPE_WALK;
	self.solid				= SOLID_SLIDEBOX;
	self.takedamage			= DAMAGE_AIM;
	self.deadflag			= DEAD_NO;
	self.bot_attack			= TRUE;
	self.flags				= FL_NOTARGET;
	self.avelocity			= '0 0 0';
	self.velocity			= '0 0 0';
	self.think				= vehicles_think;
	self.nextthink			= time;

	// Reset locking
	self.lock_strength = 0;
	self.lock_target = world;
	self.misc_bulletcounter = 0;

	// Return to spawn
	self.angles = self.pos2;
	setorigin(self, self.pos1 + '0 0 0');
	// Show it
	pointparticles(particleeffectnum("teleport"), self.origin + '0 0 64', '0 0 0', 1);

	if(self.vehicle_controller)
		self.team = self.vehicle_controller.team;

	vehicles_reset_colors();

	VEH_ACTION(self.vehicleid, VR_SPAWN);
}

float vehicle_initialize(float vehicle_id, float nodrop)
{
	if(!autocvar_g_vehicles)
		return FALSE;

	entity veh = get_vehicleinfo(vehicle_id);

	if(self.targetname)
	{
		self.vehicle_controller = find(world, target, self.targetname);
		if(!self.vehicle_controller)
		{
			bprint("^1WARNING: ^7Vehicle with invalid .targetname\n");
		}
		else
		{
			self.team = self.vehicle_controller.team;
			self.use = vehicle_use;

			if(teamplay)
			{
				if(self.vehicle_controller.team == 0)
					self.active = ACTIVE_NOT;
				else
					self.active = ACTIVE_ACTIVE;
			}
		}
	}

	if(self.team && (!teamplay || !autocvar_g_vehicles_teams))
		self.team = 0;

	self.vehicle_flags |= VHF_ISVEHICLE;

	setmodel(self, veh.model);

	self.vehicle_viewport		= spawn();
	self.vehicle_hudmodel		= spawn();
	self.tur_head				= spawn();
	self.tur_head.owner			= self;
	self.takedamage				= DAMAGE_AIM;
	self.bot_attack				= TRUE;
	self.iscreature				= TRUE;
	self.teleportable			= FALSE; // no teleporting for vehicles, too buggy
	self.damagedbycontents		= TRUE;
	self.vehicleid				= vehicle_id;
	self.PlayerPhysplug			= veh.PlayerPhysplug;
	self.event_damage			= func_null;
	self.touch					= vehicles_touch;
	self.think					= vehicles_spawn;
	self.nextthink				= time;
	self.effects				= EF_NODRAW;
	self.dphitcontentsmask		= DPCONTENTS_BODY | DPCONTENTS_SOLID;

	if(autocvar_g_playerclip_collisions)
		self.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;

	if(autocvar_g_nodepthtestplayers)
		self.effects |= EF_NODEPTHTEST;

	if(autocvar_g_fullbrightplayers)
		self.effects |= EF_FULLBRIGHT;

	setmodel(self.vehicle_hudmodel, veh.hud_model);
	setmodel(self.vehicle_viewport, "null");

	if(veh.head_model != "")
	{
		setmodel(self.tur_head, veh.head_model);
		setattachment(self.tur_head, self, veh.tag_head);
		setattachment(self.vehicle_hudmodel, self.tur_head, veh.tag_hud);
		setattachment(self.vehicle_viewport, self.vehicle_hudmodel, veh.tag_view);
	}
	else
	{
		setattachment(self.tur_head, self, "");
		setattachment(self.vehicle_hudmodel, self, veh.tag_hud);
		setattachment(self.vehicle_viewport, self.vehicle_hudmodel, veh.tag_view);
	}

	setsize(self, veh.mins, veh.maxs);

	if(!nodrop)
	{
		setorigin(self, self.origin);
		tracebox(self.origin + '0 0 100', veh.mins, veh.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
		setorigin(self, trace_endpos);
	}

	self.pos1 = self.origin;
	self.pos2 = self.angles;
	self.tur_head.team = self.team;

	VEH_ACTION(vehicle_id, VR_SETUP);

	if(autocvar_g_vehicles_delayspawn)
		self.nextthink = time + self.respawntime + (random() * autocvar_g_vehicles_delayspawn_jitter);
	else
		self.nextthink = time + game_starttime;

	if(MUTATOR_CALLHOOK(VehicleSpawn))
		return FALSE;

	return TRUE;
}
