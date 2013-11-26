.vector iorigin1, iorigin2;
.float spawntime;
.vector trail_oldorigin;
.float trail_oldtime;
.float fade_time, fade_rate;

void SUB_Stop()
{
	self.move_velocity = self.move_avelocity = '0 0 0';
	self.move_movetype = MOVETYPE_NONE;
}

.float alphamod;
.float count; // set if clientside projectile
.float cnt; // sound index
.float gravity;
.float snd_looping;
.float silent;

void Projectile_ResetTrail(vector to)
{
	self.trail_oldorigin = to;
	self.trail_oldtime = time;
}

void Projectile_DrawTrail(vector to)
{
	vector from;
	float t0;

	from = self.trail_oldorigin;
	t0 = self.trail_oldtime;
	self.trail_oldorigin = to;
	self.trail_oldtime = time;

	// force the effect even for stationary firemine
	if(self.cnt == PROJECTILE_FIREMINE)
		if(from == to)
			from_z += 1;

	if (self.traileffect)
	{
		particles_alphamin = particles_alphamax = particles_fade = sqrt(self.alpha);
		boxparticles(self.traileffect, self, from, to, self.velocity, self.velocity, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE | PARTICLES_DRAWASTRAIL);
	}
}

void Projectile_Draw()
{
	vector rot;
	vector trailorigin;
	float f;
	float drawn;
	float t;
	float a;

	f = self.move_flags;

	if(self.count & 0x80)
	{
		//self.move_flags &= ~FL_ONGROUND;
		if(self.move_movetype == MOVETYPE_NONE || self.move_movetype == MOVETYPE_FLY)
			Movetype_Physics_NoMatchServer();
			// the trivial movetypes do not have to match the
			// server's ticrate as they are ticrate independent
			// NOTE: this assumption is only true if MOVETYPE_FLY
			// projectiles detonate on impact. If they continue
			// moving, we might still be ticrate dependent.
		else
			Movetype_Physics_MatchServer(autocvar_cl_projectiles_sloppy);
		if(!(self.move_flags & FL_ONGROUND))
			if(self.velocity != '0 0 0')
				self.move_angles = self.angles = vectoangles(self.velocity);
	}
	else
	{
		InterpolateOrigin_Do();
	}

	if(self.count & 0x80)
	{
		drawn = (time >= self.spawntime - 0.02);
		t = max(time, self.spawntime);
	}
	else
	{
		drawn = (self.iflags & IFLAG_VALID);
		t = time;
	}

	if(!(f & FL_ONGROUND))
	{
		rot = '0 0 0';
		switch(self.cnt)
		{
			/*
			case PROJECTILE_GRENADE:
				rot = '-2000 0 0'; // forward
				break;
			*/
			case PROJECTILE_GRENADE_BOUNCING:
				rot = '0 -1000 0'; // sideways
				break;
			case PROJECTILE_HOOKBOMB:
				rot = '1000 0 0'; // forward
				break;
			default:
				break;
		}

		if(Nade_IDFromProjectile(self.cnt) != 0)
			rot = self.avelocity;

		self.angles = AnglesTransform_ToAngles(AnglesTransform_Multiply(AnglesTransform_FromAngles(self.angles), rot * (t - self.spawntime)));
	}

	vector ang;
	ang = self.angles;
	ang_x = -ang_x;
	makevectors(ang);

	a = 1 - (time - self.fade_time) * self.fade_rate;
	self.alpha = bound(0, self.alphamod * a, 1);
	if(self.alpha <= 0)
		drawn = 0;
	self.renderflags = 0;

	trailorigin = self.origin;
	switch(self.cnt)
	{
		case PROJECTILE_GRENADE:
		case PROJECTILE_GRENADE_BOUNCING:
			trailorigin += v_right * 1 + v_forward * -10;
			break;
		default:
			break;
	}

	if(Nade_IDFromProjectile(self.cnt) != 0)
		trailorigin += v_up * 4;

	if(drawn)
		Projectile_DrawTrail(trailorigin);
	else
		Projectile_ResetTrail(trailorigin);

	self.drawmask = 0;

	if(!drawn)
		return;

	switch(self.cnt)
	{
		// Possibly add dlights here.
		default:
			break;
	}

	self.drawmask = MASK_NORMAL;
}

void loopsound(entity e, float ch, string samp, float vol, float attn)
{
	if(self.silent)
		return;

	sound(e, ch, samp, vol, attn);
	e.snd_looping = ch;
}

void Ent_RemoveProjectile()
{
	if(self.count & 0x80)
	{
		tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * 0.05, MOVE_NORMAL, self);
		Projectile_DrawTrail(trace_endpos);
	}
}

void Ent_Projectile()
{
	float f;

	// projectile properties:
	//   kind (interpolated, or clientside)
	//
	//   modelindex
	//   origin
	//   scale
	//   if clientside:
	//     velocity
	//     gravity
	//   soundindex (hardcoded list)
	//   effects
	//
	// projectiles don't send angles, because they always follow the velocity

	f = ReadByte();
	self.count = (f & 0x80);
	self.iflags = (self.iflags & IFLAG_INTERNALMASK) | IFLAG_AUTOANGLES | IFLAG_ANGLES | IFLAG_ORIGIN;
	self.solid = SOLID_TRIGGER;
	//self.effects = EF_NOMODELFLAGS;

	// this should make collisions with bmodels more exact, but it leads to
	// projectiles no longer being able to lie on a bmodel
	self.move_nomonsters = MOVE_WORLDONLY;
	if(f & 0x40)
		self.move_flags |= FL_ONGROUND;
	else
		self.move_flags &= ~FL_ONGROUND;

	if(!self.move_time)
	{
		// for some unknown reason, we don't need to care for
		// sv_gameplayfix_delayprojectiles here.
		self.move_time = time;
		self.spawntime = time;
	}
	else
		self.move_time = max(self.move_time, time);

	if(!(self.count & 0x80))
		InterpolateOrigin_Undo();

	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
		if(self.count & 0x80)
		{
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
			if(f & 0x10)
				self.gravity = ReadCoord();
			else
				self.gravity = 0; // none
			self.move_origin = self.origin;
			self.move_velocity = self.velocity;
		}

		if(time == self.spawntime || (self.count & 0x80) || (f & 0x08))
		{
			self.trail_oldorigin = self.origin;
			if(!(self.count & 0x80))
				InterpolateOrigin_Reset();
		}

		if(f & 0x20)
		{
			self.fade_time = time + ReadByte() * ticrate;
			self.fade_rate = 1 / (ReadByte() * ticrate);
		}
		else
		{
			self.fade_time = 0;
			self.fade_rate = 0;
		}

		self.team = ReadByte() - 1;
	}

	if(f & 2)
	{
		string nade_suffix, rm_suffix;
		nade_suffix = strcat("nade_", Static_Team_ColorName_Lower(self.team));
		rm_suffix = strcat("rocketminsta_laser_", Static_Team_ColorName_Lower(self.team));

		self.cnt = ReadByte();

		self.silent = (self.cnt & 0x80);
		self.cnt = (self.cnt & 0x7F);

		self.scale = 1;
		self.traileffect = 0;
		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO: setmodel(self, "models/ebomb.mdl");self.traileffect = particleeffectnum(rm_suffix); break;
			case PROJECTILE_ROCKET: setmodel(self, "models/rocket.md3");self.traileffect = particleeffectnum("TR_ROCKET"); self.scale = 2; break;
			case PROJECTILE_SUPERROCKET: setmodel(self, "models/rocket.md3");self.traileffect = particleeffectnum("TR_ROCKET"); self.scale = 15; break;
			case PROJECTILE_ROCKETMINSTA_LASER: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum(rm_suffix); break;
			case PROJECTILE_CRYLINK: setmodel(self, "models/plasmatrail.mdl");self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;
			case PROJECTILE_CRYLINK_BOUNCING: setmodel(self, "models/plasmatrail.mdl");self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;
			case PROJECTILE_ELECTRO_BEAM: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum(rm_suffix); break;
			case PROJECTILE_GRENADE: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_GRENADE_BOUNCING: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_MINE: setmodel(self, "models/mine.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_LASER: setmodel(self, "models/laser.mdl");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_HLAC: setmodel(self, "models/hlac_bullet.md3");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_PORTO_RED: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_WIZSPIKE"); self.scale = 4; break;
			case PROJECTILE_PORTO_BLUE: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_WIZSPIKE"); self.scale = 4; break;
			case PROJECTILE_HOOKBOMB: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_KNIGHTSPIKE"); break;
			case PROJECTILE_HAGAR: setmodel(self, "models/hagarmissile.mdl");self.traileffect = particleeffectnum("tr_hagar"); self.scale = 0.75; break;
			case PROJECTILE_HAGAR_BOUNCING: setmodel(self, "models/hagarmissile.mdl");self.traileffect = particleeffectnum("tr_hagar"); self.scale = 0.75; break;
			case PROJECTILE_NAPALM_FOUNTAIN: //self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("torch_small"); break;
			case PROJECTILE_FIREBALL: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("fireball"); break; // particle effect is good enough
			case PROJECTILE_FIREMINE: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("firemine"); break; // particle effect is good enough
			case PROJECTILE_TAG: setmodel(self, "models/laser.mdl"); self.traileffect = particleeffectnum("TR_ROCKET"); break;
			case PROJECTILE_FLAC: setmodel(self, "models/hagarmissile.mdl"); self.scale = 0.4; self.traileffect = particleeffectnum("TR_SEEKER"); break;
			case PROJECTILE_SEEKER: setmodel(self, "models/tagrocket.md3"); self.traileffect = particleeffectnum("TR_SEEKER"); break;

			case PROJECTILE_MAGE_SPIKE: setmodel(self, "models/ebomb.mdl"); self.traileffect = particleeffectnum("TR_VORESPIKE"); break;
			case PROJECTILE_SHAMBLER_LIGHTNING: setmodel(self, "models/ebomb.mdl"); self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;

			case PROJECTILE_RAPTORBOMB:    setmodel(self, "models/vehicles/clusterbomb.md3"); self.gravity = 1; self.avelocity = '0 0 180'; self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_RAPTORBOMBLET: setmodel(self, "models/vehicles/bomblet.md3");     self.gravity = 1; self.avelocity = '0 0 180'; self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_RAPTORCANNON:  setmodel(self, "models/plasmatrail.mdl"); self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;

			case PROJECTILE_SPIDERROCKET: setmodel(self, "models/vehicles/rocket02.md3"); self.traileffect = particleeffectnum("spiderbot_rocket_thrust"); break;
			case PROJECTILE_WAKIROCKET:   setmodel(self, "models/vehicles/rocket01.md3");  self.traileffect = particleeffectnum("wakizashi_rocket_thrust"); break;
			case PROJECTILE_WAKICANNON:   setmodel(self, "models/laser.mdl");  self.traileffect = particleeffectnum(""); break;

			case PROJECTILE_BUMBLE_GUN: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum("rocketminsta_laser_neutral"); break;
			case PROJECTILE_BUMBLE_BEAM: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum("rocketminsta_laser_neutral"); break;

			case PROJECTILE_NADE: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum(nade_suffix); break;		
			case PROJECTILE_NADE_BURN: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum(strcat(nade_suffix, "_burn")); break;
			case PROJECTILE_NADE_NAPALM: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("TR_ROCKET"); break;
			case PROJECTILE_NADE_NAPALM_BURN: setmodel(self, "models/weapons/v_ok_grenade.md3"); self.traileffect = particleeffectnum("spiderbot_rocket_thrust"); break;
			case PROJECTILE_NADE_ICE: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;
			case PROJECTILE_NADE_ICE_BURN: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("wakizashi_rocket_thrust"); break;
			case PROJECTILE_NADE_TRANSLOCATE: setmodel(self, "models/runematch/rune.mdl"); self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;
			case PROJECTILE_NADE_SPAWN: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("nade_yellow"); break;
			case PROJECTILE_NADE_HEAL: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("nade_red"); break;       
			case PROJECTILE_NADE_HEAL_BURN: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("nade_red_burn"); break;
            
            
			case PROJECTILE_RPC: setmodel(self, "models/weapons/ok_rocket.md3");self.traileffect = particleeffectnum("TR_ROCKET"); break;

			default:
				error("Received invalid CSQC projectile, can't work with this!");
				break;
		}

		self.mins = '0 0 0';
		self.maxs = '0 0 0';
		self.colormod = '0 0 0';
		self.move_touch = SUB_Stop;
		self.move_movetype = MOVETYPE_TOSS;
		self.alphamod = 1;

		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO:
				// only new engines support sound moving with object
				loopsound(self, CH_SHOTS_SINGLE, "weapons/electro_fly.wav", VOL_BASE, ATTEN_NORM);
				self.mins = '0 0 -4';
				self.maxs = '0 0 -4';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_electro_secondary_bouncefactor;
				self.move_bounce_stopspeed = g_balance_electro_secondary_bouncestop;
				break;
			case PROJECTILE_RPC:
			case PROJECTILE_ROCKET:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/rocket_fly.wav", VOL_BASE, ATTEN_NORM);
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_SUPERROCKET:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/rocket_fly.wav", VOL_BASE, ATTEN_NORM);
				self.mins = '-32 -32 -32';
				self.maxs = '32 32 32';
				break;
			case PROJECTILE_GRENADE:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_GRENADE_BOUNCING:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_grenadelauncher_bouncefactor;
				self.move_bounce_stopspeed = g_balance_grenadelauncher_bouncestop;
				break;
			case PROJECTILE_SHAMBLER_LIGHTNING:
				self.mins = '-8 -8 -8';
				self.maxs = '8 8 8';
				self.scale = 2.5;
				self.avelocity = randomvec() * 720;
				break;
			case PROJECTILE_MINE:
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			case PROJECTILE_PORTO_RED:
				self.colormod = '2 1 1';
				self.alphamod = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_PORTO_BLUE:
				self.colormod = '1 1 2';
				self.alphamod = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_HAGAR_BOUNCING:
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_CRYLINK_BOUNCING:
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_NAPALM_FOUNTAIN:
			case PROJECTILE_FIREBALL:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/fireball_fly2.wav", VOL_BASE, ATTEN_NORM);
				self.mins = '-16 -16 -16';
				self.maxs = '16 16 16';
				break;
			case PROJECTILE_FIREMINE:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/fireball_fly.wav", VOL_BASE, ATTEN_NORM);
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			case PROJECTILE_TAG:
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				break;
			case PROJECTILE_FLAC:
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				break;
			case PROJECTILE_SEEKER:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTEN_NORM);
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
            case PROJECTILE_RAPTORBOMB:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
            case PROJECTILE_RAPTORBOMBLET:
				break;
            case PROJECTILE_RAPTORCANNON:
				break;
            case PROJECTILE_SPIDERROCKET:
                loopsound(self, CH_SHOTS_SINGLE, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTEN_NORM);
				break;
            case PROJECTILE_WAKIROCKET:
                loopsound(self, CH_SHOTS_SINGLE, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTEN_NORM);
				break;
            /*
            case PROJECTILE_WAKICANNON:
				break;
			case PROJECTILE_BUMBLE_GUN:
				// only new engines support sound moving with object
				loopsound(self, CH_SHOTS_SINGLE, "weapons/electro_fly.wav", VOL_BASE, ATTEN_NORM);
				self.mins = '0 0 -4';
				self.maxs = '0 0 -4';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_electro_secondary_bouncefactor;
				self.move_bounce_stopspeed = g_balance_electro_secondary_bouncestop;
				break;
			*/
			default:
				break;
		}
		
		if(Nade_IDFromProjectile(self.cnt) != 0)
		{
			self.mins = '-16 -16 -16';
			self.maxs = '16 16 16';
			self.colormod = Nade_Color(Nade_IDFromProjectile(self.cnt));
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = func_null;
			self.scale = 1.5;
			self.avelocity = randomvec() * 720;
		}
		
		setsize(self, self.mins, self.maxs);
	}

	if(self.gravity)
	{
		if(self.move_movetype == MOVETYPE_FLY)
			self.move_movetype = MOVETYPE_TOSS;
		if(self.move_movetype == MOVETYPE_BOUNCEMISSILE)
			self.move_movetype = MOVETYPE_BOUNCE;
	}
	else
	{
		if(self.move_movetype == MOVETYPE_TOSS)
			self.move_movetype = MOVETYPE_FLY;
		if(self.move_movetype == MOVETYPE_BOUNCE)
			self.move_movetype = MOVETYPE_BOUNCEMISSILE;
	}

	if(!(self.count & 0x80))
		InterpolateOrigin_Note();

	self.draw = Projectile_Draw;
	self.entremove = Ent_RemoveProjectile;
}

void Projectile_Precache()
{
	precache_model("models/ebomb.mdl");
	precache_model("models/elaser.mdl");
	precache_model("models/grenademodel.md3");
	precache_model("models/mine.md3");
	precache_model("models/hagarmissile.mdl");
	precache_model("models/hlac_bullet.md3");
	precache_model("models/laser.mdl");
	precache_model("models/plasmatrail.mdl");
	precache_model("models/rocket.md3");
	precache_model("models/tagrocket.md3");
	precache_model("models/tracer.mdl");
	precache_model("models/runematch/rune.mdl");

	precache_model("models/weapons/v_ok_grenade.md3");
	precache_model("models/weapons/ok_rocket.md3");

	precache_sound("weapons/electro_fly.wav");
	precache_sound("weapons/rocket_fly.wav");
	precache_sound("weapons/fireball_fly.wav");
	precache_sound("weapons/fireball_fly2.wav");
	precache_sound("weapons/tag_rocket_fly.wav");

}
