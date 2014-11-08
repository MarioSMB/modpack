#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ CRYLINK,
/* function  */ W_Crylink,
/* ammotype  */ ammo_cells,
/* impulse   */ 6,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '1 0.5 1',
/* modelname */ "crylink",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshaircrylink 0.4",
/* wepimg    */ "weaponcrylink",
/* refname   */ "crylink",
/* wepname   */ _("Crylink")
);

#define CRYLINK_SETTINGS(w_cvar,w_prop) CRYLINK_SETTINGS_LIST(w_cvar, w_prop, CRYLINK, crylink)
#define CRYLINK_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, ammo) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, edgedamage) \
	w_cvar(id, sn, BOTH, radius) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, BOTH, spread) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, speed) \
	w_cvar(id, sn, BOTH, shots) \
	w_cvar(id, sn, BOTH, bounces) \
	w_cvar(id, sn, BOTH, bouncedamagefactor) \
	w_cvar(id, sn, BOTH, middle_lifetime) \
	w_cvar(id, sn, BOTH, middle_fadetime) \
	w_cvar(id, sn, BOTH, other_lifetime) \
	w_cvar(id, sn, BOTH, other_fadetime) \
	w_cvar(id, sn, BOTH, linkexplode) \
	w_cvar(id, sn, BOTH, joindelay) \
	w_cvar(id, sn, BOTH, joinspread) \
	w_cvar(id, sn, BOTH, joinexplode) \
	w_cvar(id, sn, BOTH, joinexplode_damage) \
	w_cvar(id, sn, BOTH, joinexplode_edgedamage) \
	w_cvar(id, sn, BOTH, joinexplode_radius) \
	w_cvar(id, sn, BOTH, joinexplode_force) \
	w_cvar(id, sn, SEC,  spreadtype) \
	w_cvar(id, sn, NONE, secondary) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
CRYLINK_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.float gravity;
.float crylink_waitrelease;
.entity crylink_lastgroup;

.entity queuenext;
.entity queueprev;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_crylink(void) { weapon_defaultspawnfunc(WEP_CRYLINK); }

void W_Crylink_CheckLinks(entity e)
{
	float i;
	entity p;

	if(e == world)
		error("W_Crylink_CheckLinks: entity is world");
	if(e.classname != "spike" || wasfreed(e))
		error(sprintf("W_Crylink_CheckLinks: entity is not a spike but a %s (freed: %d)", e.classname, wasfreed(e)));

	p = e;
	for(i = 0; i < 1000; ++i)
	{
		if(p.queuenext.queueprev != p || p.queueprev.queuenext != p)
			error("W_Crylink_CheckLinks: queue is inconsistent");
		p = p.queuenext;
		if(p == e)
			break;
	}
	if(i >= 1000)
		error("W_Crylink_CheckLinks: infinite chain");
}

void W_Crylink_Dequeue_Raw(entity own, entity prev, entity me, entity next)
{
	W_Crylink_CheckLinks(next);
	if(me == own.crylink_lastgroup)
		own.crylink_lastgroup = ((me == next) ? world : next);
	prev.queuenext = next;
	next.queueprev = prev;
	me.classname = "spike_oktoremove";
	if(me != next)
		W_Crylink_CheckLinks(next);
}

void W_Crylink_Dequeue(entity e)
{
	W_Crylink_Dequeue_Raw(e.realowner, e.queueprev, e, e.queuenext);
}

void W_Crylink_Reset(void)
{
	W_Crylink_Dequeue(self);
	remove(self);
}

// force projectile to explode
void W_Crylink_LinkExplode(entity e, entity e2)
{
	float a;

	if(e == e2)
		return;

	a = bound(0, 1 - (time - e.fade_time) * e.fade_rate, 1);

	if(e == e.realowner.crylink_lastgroup)
		e.realowner.crylink_lastgroup = world;
		
	float isprimary = !(e.projectiledeathtype & HITTYPE_SECONDARY);
		
	RadiusDamage(e, e.realowner, WEP_CVAR_BOTH(crylink, isprimary, damage) * a, WEP_CVAR_BOTH(crylink, isprimary, edgedamage) * a, WEP_CVAR_BOTH(crylink, isprimary, radius), world, world, WEP_CVAR_BOTH(crylink, isprimary, force) * a, e.projectiledeathtype, other);

	W_Crylink_LinkExplode(e.queuenext, e2);

	e.classname = "spike_oktoremove";
	remove(e);
}

// adjust towards center
// returns the origin where they will meet... and the time till the meeting is
// stored in w_crylink_linkjoin_time.
// could possibly network this origin and time, and display a special particle
// effect when projectiles meet there :P
// jspeed: joining speed (calculate this as join spread * initial speed)
float w_crylink_linkjoin_time;
vector W_Crylink_LinkJoin(entity e, float jspeed)
{
	vector avg_origin, avg_velocity;
	vector targ_origin;
	float avg_dist, n;
	entity p;

	// FIXME remove this debug code
	W_Crylink_CheckLinks(e);

	w_crylink_linkjoin_time = 0;

	avg_origin = e.origin;
	avg_velocity = e.velocity;
	n = 1;
	for(p = e; (p = p.queuenext) != e; )
	{
		avg_origin += WarpZone_RefSys_TransformOrigin(p, e, p.origin);
		avg_velocity += WarpZone_RefSys_TransformVelocity(p, e, p.velocity);
		++n;
	}
	avg_origin *= (1.0 / n);
	avg_velocity *= (1.0 / n);

	if(n < 2)
		return avg_origin; // nothing to do

	// yes, mathematically we can do this in ONE step, but beware of 32bit floats...
	avg_dist = pow(vlen(e.origin - avg_origin), 2);
	for(p = e; (p = p.queuenext) != e; )
		avg_dist += pow(vlen(WarpZone_RefSys_TransformOrigin(p, e, p.origin) - avg_origin), 2);
	avg_dist *= (1.0 / n);
	avg_dist = sqrt(avg_dist);

	if(avg_dist == 0)
		return avg_origin; // no change needed

	if(jspeed == 0)
	{
		e.velocity = avg_velocity;
		UpdateCSQCProjectile(e);
		for(p = e; (p = p.queuenext) != e; )
		{
			p.velocity = WarpZone_RefSys_TransformVelocity(e, p, avg_velocity);
			UpdateCSQCProjectile(p);
		}
		targ_origin = avg_origin + 1000000000 * normalize(avg_velocity); // HUUUUUUGE
	}
	else
	{
		w_crylink_linkjoin_time = avg_dist / jspeed;
		targ_origin = avg_origin + w_crylink_linkjoin_time * avg_velocity;

		e.velocity = (targ_origin - e.origin) * (1.0 / w_crylink_linkjoin_time);
		UpdateCSQCProjectile(e);
		for(p = e; (p = p.queuenext) != e; )
		{
			p.velocity = WarpZone_RefSys_TransformVelocity(e, p, (targ_origin - WarpZone_RefSys_TransformOrigin(p, e, p.origin)) * (1.0 / w_crylink_linkjoin_time));
			UpdateCSQCProjectile(p);
		}

		// analysis:
		//   jspeed -> +infinity:
		//      w_crylink_linkjoin_time -> +0
		//      targ_origin -> avg_origin
		//      p->velocity -> HUEG towards center
		//   jspeed -> 0:
		//      w_crylink_linkjoin_time -> +/- infinity
		//      targ_origin -> avg_velocity * +/- infinity
		//      p->velocity -> avg_velocity
		//   jspeed -> -infinity:
		//      w_crylink_linkjoin_time -> -0
		//      targ_origin -> avg_origin
		//      p->velocity -> HUEG away from center
	}

	W_Crylink_CheckLinks(e);

	return targ_origin;
}

void W_Crylink_LinkJoinEffect_Think(void)
{
	// is there at least 2 projectiles very close?
	entity e, p;
	float n;
	e = self.owner.crylink_lastgroup;
	n = 0;
	if(e)
	{
		if(vlen(e.origin - self.origin) < vlen(e.velocity) * frametime)
			++n;
		for(p = e; (p = p.queuenext) != e; )
		{
			if(vlen(p.origin - self.origin) < vlen(p.velocity) * frametime)
				++n;
		}
		if(n >= 2)
		{
			float isprimary = !(e.projectiledeathtype & HITTYPE_SECONDARY);
			
			if(WEP_CVAR_BOTH(crylink, isprimary, joinexplode))
			{
				n /= WEP_CVAR_BOTH(crylink, isprimary, shots);
				RadiusDamage(
					e,
					e.realowner,
					WEP_CVAR_BOTH(crylink, isprimary, joinexplode_damage) * n,
					WEP_CVAR_BOTH(crylink, isprimary, joinexplode_edgedamage) * n,
					WEP_CVAR_BOTH(crylink, isprimary, joinexplode_radius) * n,
					e.realowner,
					world,
					WEP_CVAR_BOTH(crylink, isprimary, joinexplode_force) * n,
					e.projectiledeathtype,
					other
				);
				pointparticles(particleeffectnum("crylink_joinexplode"), self.origin, '0 0 0', n);
			}
		}
	}
	remove(self);
}

float W_Crylink_Touch_WouldHitFriendly(entity projectile, float rad)
{
	entity head = WarpZone_FindRadius((projectile.origin + (projectile.mins + projectile.maxs) * 0.5), rad + MAX_DAMAGEEXTRARADIUS, FALSE);
	float hit_friendly = 0;
	float hit_enemy = 0;

	while(head)
	{
		if((head.takedamage != DAMAGE_NO) && (head.deadflag == DEAD_NO))
		{
			if(SAME_TEAM(head, projectile.realowner))
				++hit_friendly;
			else
				++hit_enemy;
		}
			
		head = head.chain;
	}

	return (hit_enemy ? FALSE : hit_friendly);
}

// NO bounce protection, as bounces are limited!
void W_Crylink_Touch(void)
{
	float finalhit;
	float f;
	float isprimary = !(self.projectiledeathtype & HITTYPE_SECONDARY);
	PROJECTILE_TOUCH;

	float a;
	a = bound(0, 1 - (time - self.fade_time) * self.fade_rate, 1);

	finalhit = ((self.cnt <= 0) || (other.takedamage != DAMAGE_NO));
	if(finalhit)
		f = 1;
	else
		f = WEP_CVAR_BOTH(crylink, isprimary, bouncedamagefactor);
	if(a)
		f *= a;

	float totaldamage = RadiusDamage(self, self.realowner, WEP_CVAR_BOTH(crylink, isprimary, damage) * f, WEP_CVAR_BOTH(crylink, isprimary, edgedamage) * f, WEP_CVAR_BOTH(crylink, isprimary, radius), world, world, WEP_CVAR_BOTH(crylink, isprimary, force) * f, self.projectiledeathtype, other);
		
	if(totaldamage && ((WEP_CVAR_BOTH(crylink, isprimary, linkexplode) == 2) || ((WEP_CVAR_BOTH(crylink, isprimary, linkexplode) == 1) && !W_Crylink_Touch_WouldHitFriendly(self, WEP_CVAR_BOTH(crylink, isprimary, radius)))))
	{
		if(self == self.realowner.crylink_lastgroup)
			self.realowner.crylink_lastgroup = world;
		W_Crylink_LinkExplode(self.queuenext, self);
		self.classname = "spike_oktoremove";
		remove(self);
		return;
	}
	else if(finalhit)
	{
		// just unlink
		W_Crylink_Dequeue(self);
		remove(self);
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.owner = world;
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	// commented out as it causes a little hitch...
	//if(proj.cnt == 0)
	//	CSQCProjectile(proj, TRUE, PROJECTILE_CRYLINK, TRUE);
}

void W_Crylink_Fadethink(void)
{
	W_Crylink_Dequeue(self);
	remove(self);
}

void W_Crylink_Attack(void)
{
	float counter, shots;
	entity proj, prevproj, firstproj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	W_DecreaseAmmo(WEP_CVAR_PRI(crylink, ammo));

	maxdmg = WEP_CVAR_PRI(crylink, damage) * WEP_CVAR_PRI(crylink, shots);
	maxdmg *= 1 + WEP_CVAR_PRI(crylink, bouncedamagefactor) * WEP_CVAR_PRI(crylink, bounces);
	if(WEP_CVAR_PRI(crylink, joinexplode))
		maxdmg += WEP_CVAR_PRI(crylink, joinexplode_damage);

	W_SetupShot(self, FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = WEP_CVAR_PRI(crylink, shots);
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn();
		proj.reset = W_Crylink_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = WEP_CVAR_PRI(crylink, damage);
		if(shots == 1) {
			proj.queuenext = proj;
			proj.queueprev = proj;
		}
		else if(counter == 0) { // first projectile, store in firstproj for now
			firstproj = proj;
		}
		else if(counter == shots - 1) { // last projectile, link up with first projectile
			prevproj.queuenext = proj;
			firstproj.queueprev = proj;
			proj.queuenext = firstproj;
			proj.queueprev = prevproj;
		}
		else { // else link up with previous projectile
			prevproj.queuenext = proj;
			proj.queueprev = prevproj;
		}

		prevproj = proj;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYLINK;
		//proj.gravity = 0.001;

		setorigin(proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');


		s = '0 0 0';
		if(counter == 0)
			s = '0 0 0';
		else
		{
			makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
			s_y = v_forward_x;
			s_z = v_forward_y;
		}
		s = s * WEP_CVAR_PRI(crylink, spread) * g_weaponspreadfactor;
		W_SetupProjVelocity_Explicit(proj, w_shotdir + right * s_y + up * s_z, v_up, WEP_CVAR_PRI(crylink, speed), 0, 0, 0, FALSE);
		proj.touch = W_Crylink_Touch;

		proj.think = W_Crylink_Fadethink;
		if(counter == 0)
		{
			proj.fade_time = time + WEP_CVAR_PRI(crylink, middle_lifetime);
			proj.fade_rate = 1 / WEP_CVAR_PRI(crylink, middle_fadetime);
			proj.nextthink = time + WEP_CVAR_PRI(crylink, middle_lifetime) + WEP_CVAR_PRI(crylink, middle_fadetime);
		}
		else
		{
			proj.fade_time = time + WEP_CVAR_PRI(crylink, other_lifetime);
			proj.fade_rate = 1 / WEP_CVAR_PRI(crylink, other_fadetime);
			proj.nextthink = time + WEP_CVAR_PRI(crylink, other_lifetime) + WEP_CVAR_PRI(crylink, other_fadetime);
		}
		proj.teleport_time = time + WEP_CVAR_PRI(crylink, joindelay);
		proj.cnt = WEP_CVAR_PRI(crylink, bounces);
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles(proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
		proj.missile_flags = MIF_SPLASH;
    
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
	if(WEP_CVAR_PRI(crylink, joinspread) != 0)
	{
		self.crylink_lastgroup = proj;
		W_Crylink_CheckLinks(proj);
		self.crylink_waitrelease = 1;
	}
}

void W_Crylink_Attack2(void)
{
	float counter, shots;
	entity proj, prevproj, firstproj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	W_DecreaseAmmo(WEP_CVAR_SEC(crylink, ammo));

	maxdmg = WEP_CVAR_SEC(crylink, damage) * WEP_CVAR_SEC(crylink, shots);
	maxdmg *= 1 + WEP_CVAR_SEC(crylink, bouncedamagefactor) * WEP_CVAR_SEC(crylink, bounces);
	if(WEP_CVAR_SEC(crylink, joinexplode))
		maxdmg += WEP_CVAR_SEC(crylink, joinexplode_damage);

	W_SetupShot(self, FALSE, 2, "weapons/crylink_fire2.wav", CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = WEP_CVAR_SEC(crylink, shots);
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn();
		proj.reset = W_Crylink_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = WEP_CVAR_SEC(crylink, damage);
		if(shots == 1) {
			proj.queuenext = proj;
			proj.queueprev = proj;
		}
		else if(counter == 0) { // first projectile, store in firstproj for now
			firstproj = proj;
		}
		else if(counter == shots - 1) { // last projectile, link up with first projectile
			prevproj.queuenext = proj;
			firstproj.queueprev = proj;
			proj.queuenext = firstproj;
			proj.queueprev = prevproj;
		}
		else { // else link up with previous projectile
			prevproj.queuenext = proj;
			proj.queueprev = prevproj;
		}

		prevproj = proj;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYLINK | HITTYPE_SECONDARY;
		//proj.gravity = 0.001;

		setorigin(proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');

		if(WEP_CVAR_SEC(crylink, spreadtype) == 1)
		{
			s = '0 0 0';
			if(counter == 0)
				s = '0 0 0';
			else
			{
				makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
				s_y = v_forward_x;
				s_z = v_forward_y;
			}
			s = s * WEP_CVAR_SEC(crylink, spread) * g_weaponspreadfactor;
			s = w_shotdir + right * s_y + up * s_z;
		}
		else
		{
			s = (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_right * WEP_CVAR_SEC(crylink, spread) * g_weaponspreadfactor);
		}

		W_SetupProjVelocity_Explicit(proj, s, v_up, WEP_CVAR_SEC(crylink, speed), 0, 0, 0, FALSE);
		proj.touch = W_Crylink_Touch;
		proj.think = W_Crylink_Fadethink;
		if(counter == (shots - 1) / 2)
		{
			proj.fade_time = time + WEP_CVAR_SEC(crylink, middle_lifetime);
			proj.fade_rate = 1 / WEP_CVAR_SEC(crylink, middle_fadetime);
			proj.nextthink = time + WEP_CVAR_SEC(crylink, middle_lifetime) + WEP_CVAR_SEC(crylink, middle_fadetime);
		}
		else
		{
			proj.fade_time = time + WEP_CVAR_SEC(crylink, other_lifetime);
			proj.fade_rate = 1 / WEP_CVAR_SEC(crylink, other_fadetime);
			proj.nextthink = time + WEP_CVAR_SEC(crylink, other_lifetime) + WEP_CVAR_SEC(crylink, other_fadetime);
		}
		proj.teleport_time = time + WEP_CVAR_SEC(crylink, joindelay);
		proj.cnt = WEP_CVAR_SEC(crylink, bounces);
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles(proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
        proj.missile_flags = MIF_SPLASH;
        
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
	if(WEP_CVAR_SEC(crylink, joinspread) != 0)
	{
		self.crylink_lastgroup = proj;
		W_Crylink_CheckLinks(proj);
		self.crylink_waitrelease = 2;
	}
}

float W_Crylink(float req)
{
	float ammo_amount;
	switch(req)
	{
		case WR_AIM:
		{
			if(random() < 0.10)
				self.BUTTON_ATCK = bot_aim(WEP_CVAR_PRI(crylink, speed), 0, WEP_CVAR_PRI(crylink, middle_lifetime), FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(WEP_CVAR_SEC(crylink, speed), 0, WEP_CVAR_SEC(crylink, middle_lifetime), FALSE);
				
			return TRUE;
		}
		case WR_THINK:
		{
			if(autocvar_g_balance_crylink_reload_ammo && self.clip_load < min(WEP_CVAR_PRI(crylink, ammo), WEP_CVAR_SEC(crylink, ammo))) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);

			if(self.BUTTON_ATCK)
			{
				if(self.crylink_waitrelease != 1)
				if(weapon_prepareattack(0, WEP_CVAR_PRI(crylink, refire)))
				{
					W_Crylink_Attack();
					weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(crylink, animtime), w_ready);
				}
			}

			if(self.BUTTON_ATCK2 && autocvar_g_balance_crylink_secondary)
			{
				if(self.crylink_waitrelease != 2)
				if(weapon_prepareattack(1, WEP_CVAR_SEC(crylink, refire)))
				{
					W_Crylink_Attack2();
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(crylink, animtime), w_ready);
				}
			}

			if((self.crylink_waitrelease == 1 && !self.BUTTON_ATCK) || (self.crylink_waitrelease == 2 && !self.BUTTON_ATCK2))
			{
				if(!self.crylink_lastgroup || time > self.crylink_lastgroup.teleport_time)
				{
					// fired and released now!
					if(self.crylink_lastgroup)
					{
						vector pos;
						entity linkjoineffect;
						float isprimary = (self.crylink_waitrelease == 1);
						
						pos = W_Crylink_LinkJoin(self.crylink_lastgroup, WEP_CVAR_BOTH(crylink, isprimary, joinspread) * WEP_CVAR_BOTH(crylink, isprimary, speed));

						linkjoineffect = spawn();
						linkjoineffect.think = W_Crylink_LinkJoinEffect_Think;
						linkjoineffect.classname = "linkjoineffect";
						linkjoineffect.nextthink = time + w_crylink_linkjoin_time;
						linkjoineffect.owner = self;
						setorigin(linkjoineffect, pos);
					}
					self.crylink_waitrelease = 0;
					if(!W_Crylink(WR_CHECKAMMO1) && !W_Crylink(WR_CHECKAMMO2))
					if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
					{
						// ran out of ammo!
						self.cnt = WEP_CRYLINK;
						self.switchweapon = w_getbestweapon(self);
					}
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_crylink.md3");
			precache_model("models/weapons/v_crylink.md3");
			precache_model("models/weapons/h_crylink.iqm");
			precache_sound("weapons/crylink_fire.wav");
			precache_sound("weapons/crylink_fire2.wav");
			precache_sound("weapons/crylink_linkjoin.wav");
			CRYLINK_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			// don't "run out of ammo" and switch weapons while waiting for release
			if(self.crylink_lastgroup && self.crylink_waitrelease)
				return TRUE;

			ammo_amount = self.WEP_AMMO(CRYLINK) >= WEP_CVAR_PRI(crylink, ammo);
			ammo_amount += self.(weapon_load[WEP_CRYLINK]) >= WEP_CVAR_PRI(crylink, ammo);
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			// don't "run out of ammo" and switch weapons while waiting for release
			if(self.crylink_lastgroup && self.crylink_waitrelease)
				return TRUE;

			ammo_amount = self.WEP_AMMO(CRYLINK) >= WEP_CVAR_SEC(crylink, ammo);
			ammo_amount += self.(weapon_load[WEP_CRYLINK]) >= WEP_CVAR_SEC(crylink, ammo);
			return ammo_amount;
		}
		case WR_CONFIG:
		{
			CRYLINK_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(min(WEP_CVAR_PRI(crylink, ammo), WEP_CVAR_SEC(crylink, ammo)), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_CRYLINK_SUICIDE;
		}
		case WR_KILLMESSAGE:
		{
			return WEAPON_CRYLINK_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Crylink(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			if(w_deathtype & HITTYPE_SECONDARY)
			{
				pointparticles(particleeffectnum("crylink_impact"), org2, '0 0 0', 1);
				if(!w_issilent)
					sound(self, CH_SHOTS, "weapons/crylink_impact2.wav", VOL_BASE, ATTN_NORM);
			}
			else
			{
				pointparticles(particleeffectnum("crylink_impactbig"), org2, '0 0 0', 1);
				if(!w_issilent)
					sound(self, CH_SHOTS, "weapons/crylink_impact.wav", VOL_BASE, ATTN_NORM);
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/crylink_impact2.wav");
			precache_sound("weapons/crylink_impact.wav");
			return TRUE;
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
