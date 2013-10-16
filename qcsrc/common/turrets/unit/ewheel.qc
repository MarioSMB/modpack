#ifdef REGISTER_TURRET
REGISTER_TURRET(
/* TUR_##id   */ EWHEEL,
/* function   */ t_ewheel,
/* spawnflags */ TUR_FLAG_PLAYER | TUR_FLAG_MOVE | TUR_FLAG_ROAM,
/* mins,maxs  */ '-32 -32 0', '32 32 48',
/* model      */ "ewheel-base2.md3",
/* head_model */ "ewheel-gun1.md3",
/* netname    */ "ewheel",
/* fullname   */ _("eWheel Turret")
);

#define EWHEEL_SETTINGS(turret) \
	TUR_ADD_CVAR(turret, speed_fast) \
	TUR_ADD_CVAR(turret, speed_slow) \
	TUR_ADD_CVAR(turret, speed_slower) \
	TUR_ADD_CVAR(turret, speed_stop) \
	TUR_ADD_CVAR(turret, turnrate) 
	

#ifdef SVQC
EWHEEL_SETTINGS(ewheel)
#endif // SVQC
#else
#ifdef SVQC
const float ewheel_anim_stop = 0;
const float ewheel_anim_fwd_slow = 1;
const float ewheel_anim_fwd_fast = 2;
const float ewheel_anim_bck_slow = 3;
const float ewheel_anim_bck_fast = 4;

//#define EWHEEL_FANCYPATH
void ewheel_move_path()
{
#ifdef EWHEEL_FANCYPATH
	// Are we close enougth to a path node to switch to the next?
	if (vlen(self.origin  - self.pathcurrent.origin) < 64)
		if (self.pathcurrent.path_next == world)
		{
			// Path endpoint reached
			pathlib_deletepath(self.pathcurrent.owner);
			self.pathcurrent = world;

			if (self.pathgoal)
			{
				if (self.pathgoal.use)
					self.pathgoal.use();

				if (self.pathgoal.enemy)
				{
					self.pathcurrent = pathlib_astar(self.pathgoal.origin,self.pathgoal.enemy.origin);
					self.pathgoal = self.pathgoal.enemy;
				}
			}
			else
				self.pathgoal = world;
		}
		else
			self.pathcurrent = self.pathcurrent.path_next;

#else
	if (vlen(self.origin - self.pathcurrent.origin) < 64)
		self.pathcurrent = self.pathcurrent.enemy;
#endif

	if (self.pathcurrent)
	{

		self.moveto = self.pathcurrent.origin;
		self.steerto = steerlib_attract2(self.moveto, 0.5, 500, 0.95);

		movelib_move_simple(v_forward, TUR_CVAR(ewheel, speed_fast), 0.4);
	}
}

void ewheel_move_enemy()
{
	float newframe;

	self.steerto = steerlib_arrive(self.enemy.origin,self.target_range_optimal);
	
	self.moveto  = self.origin + self.steerto * 128;

	if (self.tur_dist_enemy > self.target_range_optimal)
	{
		if ( self.tur_head.spawnshieldtime < 1 )
		{
			newframe = ewheel_anim_fwd_fast;
			movelib_move_simple(v_forward, TUR_CVAR(ewheel, speed_fast), 0.4);
		}
		else if (self.tur_head.spawnshieldtime < 2)
		{

			newframe = ewheel_anim_fwd_slow;
			movelib_move_simple(v_forward, TUR_CVAR(ewheel, speed_slow), 0.4);
	   }
		else
		{
			newframe = ewheel_anim_fwd_slow;
			movelib_move_simple(v_forward, TUR_CVAR(ewheel, speed_slower), 0.4);
		}
	}
	else if (self.tur_dist_enemy < self.target_range_optimal * 0.5)
	{
		newframe = ewheel_anim_bck_slow;
		movelib_move_simple(v_forward * -1, TUR_CVAR(ewheel, speed_slow), 0.4);
	}
	else
	{
		newframe = ewheel_anim_stop;
		movelib_beak_simple(TUR_CVAR(ewheel, speed_stop));
	}

	turrets_setframe(newframe, FALSE);
}

void ewheel_move_idle()
{
	if(self.frame != 0)
	{
		self.SendFlags |= TNSF_ANIM;
		self.anim_start_time = time;
	}

	self.frame = 0;
	if (vlen(self.velocity))
		movelib_beak_simple(TUR_CVAR(ewheel, speed_stop));
}

void spawnfunc_turret_ewheel() { if not(turret_initialize(TUR_EWHEEL)) remove(self); }

float t_ewheel(float req)
{
	switch(req)
	{
		case TR_ATTACK:
		{
			float i;
			entity _mis;

			for (i = 0; i < 1; ++i)
			{
				turret_do_updates(self);

				_mis = turret_projectile("weapons/lasergun_fire.wav", 1, 0, DEATH_TURRET_EWHEEL, PROJECTILE_LASER, TRUE, TRUE);
				_mis.missile_flags = MIF_SPLASH;

				pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);

				self.tur_head.frame += 2;

				if (self.tur_head.frame > 3)
					self.tur_head.frame = 0;
			}
			
			return TRUE;
		}
		case TR_THINK:
		{
			float vz;
			vector wish_angle, real_angle;

			vz = self.velocity_z;

			self.angles_x = anglemods(self.angles_x);
			self.angles_y = anglemods(self.angles_y);

			fixedmakevectors(self.angles);

			wish_angle = normalize(self.steerto);
			wish_angle = vectoangles(wish_angle);
			real_angle = wish_angle - self.angles;
			real_angle = shortangle_vxy(real_angle, self.tur_head.angles);

			self.tur_head.spawnshieldtime = fabs(real_angle_y);
			real_angle_y  = bound(-self.tur_head.aim_speed, real_angle_y, self.tur_head.aim_speed);
			self.angles_y = (self.angles_y + real_angle_y);

			if(self.enemy)
				ewheel_move_enemy();
			else if(self.pathcurrent)
				ewheel_move_path();
			else
				ewheel_move_idle();

			self.velocity_z = vz;

			if(vlen(self.velocity))
				self.SendFlags |= TNSF_MOVE;
		
			return TRUE;
		}
		case TR_DEATH:
		{
			self.velocity = '0 0 0';

#ifdef EWHEEL_FANCYPATH
			if (self.pathcurrent)
				pathlib_deletepath(self.pathcurrent.owner);
#endif
			self.pathcurrent = world;
	
			return TRUE;
		}
		case TR_SETUP:
		{
			entity e;
			
			if(self.movetype == MOVETYPE_WALK)
			{
				self.velocity = '0 0 0';
				self.enemy = world;

				setorigin(self, self.pos1);

				if (self.target != "")
				{
					e = find(world, targetname, self.target);
					if (!e)
					{
						dprint("Initital waypoint for ewheel does NOT exsist, fix your map!\n");
						self.target = "";
					}

					if (e.classname != "turret_checkpoint")
						dprint("Warning: not a turrret path\n");
					else
					{

#ifdef EWHEEL_FANCYPATH
						self.pathcurrent = WALKER_PATH(self.origin,e.origin);
						self.pathgoal = e;
#else
						self.pathcurrent  = e;
#endif
					}
				}
			}
			
			self.iscreature				= TRUE;
			self.teleportable			= TELEPORT_NORMAL;
			self.damagedbycontents		= TRUE;
			self.movetype				= MOVETYPE_WALK;
			self.solid					= SOLID_SLIDEBOX;
			self.takedamage				= DAMAGE_AIM;
			self.idle_aim				= '0 0 0';
			self.pos1					= self.origin;
			self.target_select_flags	= TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
			self.target_validate_flags	= TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
			self.frame					= self.tur_head.frame = 1;
			self.ammo_flags				= TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIEVE;
			
			// Convert from dgr / sec to dgr / tic
			self.tur_head.aim_speed = TUR_CVAR(ewheel, turnrate);
			self.tur_head.aim_speed = self.tur_head.aim_speed / (1 / self.ticrate);
		
			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/ewheel-base2.md3");
			precache_model ("models/turrets/ewheel-gun1.md3");
			return TRUE;
		}
		case TR_CONFIG:
		{
			TUR_CONFIG_SETTINGS(EWHEEL_SETTINGS(ewheel))
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC

void ewheel_draw()
{
	float dt;

	dt = time - self.move_time;
	self.move_time = time;
	if(dt <= 0)
		return;

	fixedmakevectors(self.angles);
	setorigin(self, self.origin + self.velocity * dt);
	self.tur_head.angles += dt * self.tur_head.move_avelocity;
	self.angles_y = self.move_angles_y;

	if (self.health < 127)
	if(random() < 0.05)
		te_spark(self.origin + '0 0 40', randomvec() * 256 + '0 0 256', 16);
}

float t_ewheel(float req)
{
	switch(req)
	{
		case TR_SETUP:
		{
			self.gravity		= 1;
			self.movetype		= MOVETYPE_BOUNCE;
			self.move_movetype	= MOVETYPE_BOUNCE;
			self.move_origin	= self.origin;
			self.move_time		= time;
			self.draw			= ewheel_draw;
			
			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/ewheel-base2.md3");
			precache_model ("models/turrets/ewheel-gun1.md3");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_TURRET
