// =========================
//  SVQC Turret Properties
// =========================


// Generic aiming
vector turret_aim_generic()
{

	vector pre_pos, prep;
	float distance, impact_time = 0, i, mintime;

	turret_tag_fire_update();

	if(self.aim_flags & TFL_AIM_SIMPLE)
		return real_origin(self.enemy);

	mintime = max(self.attack_finished_single - time,0) + sys_frametime;

	// Baseline
	pre_pos = real_origin(self.enemy);

	// Lead?
	if (self.aim_flags & TFL_AIM_LEAD)
	{
		if (self.aim_flags & TFL_AIM_SHOTTIMECOMPENSATE)	   // Need to conpensate for shot traveltime
		{
			prep = pre_pos;
			
			distance = vlen(prep - self.tur_shotorg);
			impact_time = distance / self.shot_speed;

			prep = pre_pos + (self.enemy.velocity * (impact_time + mintime));

			if(self.aim_flags & TFL_AIM_ZPREDICT)
			if(!(self.enemy.flags & FL_ONGROUND))
			if(self.enemy.movetype == MOVETYPE_WALK || self.enemy.movetype == MOVETYPE_TOSS || self.enemy.movetype == MOVETYPE_BOUNCE)
			{
				float vz;
				prep_z = pre_pos_z;
				vz = self.enemy.velocity_z;
				for(i = 0; i < impact_time; i += sys_frametime)
				{
					vz = vz - (autocvar_sv_gravity * sys_frametime);
					prep_z = prep_z + vz * sys_frametime;
				}
			}
			pre_pos = prep;
		}
		else
			pre_pos = pre_pos + self.enemy.velocity * mintime;
	}

	if(self.aim_flags & TFL_AIM_SPLASH)
	{
		//tracebox(pre_pos + '0 0 32',self.enemy.mins,self.enemy.maxs,pre_pos -'0 0 64',MOVE_WORLDONLY,self.enemy);
		traceline(pre_pos + '0 0 32',pre_pos -'0 0 64',MOVE_WORLDONLY,self.enemy);
		if(trace_fraction != 1.0)
			pre_pos = trace_endpos;
	}

	return pre_pos;
}

float turret_targetscore_support(entity _turret,entity _target)
{
	float score;		// Total score
	float s_score = 0, d_score;

	if (_turret.enemy == _target) s_score = 1;

	d_score = min(_turret.target_range_optimal,tvt_dist) / max(_turret.target_range_optimal,tvt_dist);

	score = (d_score * _turret.target_select_rangebias) +
			(s_score * _turret.target_select_samebias);

	return score;
}

/*
* Generic bias aware score system.
*/
float turret_targetscore_generic(entity _turret, entity _target)
{
	float d_dist;	   // Defendmode Distance
	float score;		// Total score
	float d_score;	  // Distance score
	float a_score;	  // Angular score
	float m_score = 0;  // missile score
	float p_score = 0;  // player score
	float ikr;		  // ideal kill range

	if (_turret.tur_defend)
	{
		d_dist = vlen(real_origin(_target) - _turret.tur_defend.origin);
		ikr = vlen(_turret.origin - _turret.tur_defend.origin);
		d_score = 1 - d_dist / _turret.target_range;
	}
	else
	{
		// Make a normlized value base on the targets distance from our optimal killzone
		ikr = _turret.target_range_optimal;
		d_score = min(ikr, tvt_dist) / max(ikr, tvt_dist);
	}

	a_score = 1 - tvt_thadf / _turret.aim_maxrotate;

	if ((_turret.target_select_missilebias > 0) && (_target.flags & FL_PROJECTILE))
		m_score = 1;

	if ((_turret.target_select_playerbias > 0) && IS_CLIENT(_target))
		p_score = 1;

	d_score = max(d_score, 0);
	a_score = max(a_score, 0);
	m_score = max(m_score, 0);
	p_score = max(p_score, 0);

	score = (d_score * _turret.target_select_rangebias) +
			(a_score * _turret.target_select_anglebias) +
			(m_score * _turret.target_select_missilebias) +
			(p_score * _turret.target_select_playerbias);

	if(_turret.target_range < vlen(_turret.tur_shotorg - real_origin(_target)))
	{
		//dprint("Wtf?\n");
		score *= 0.001;
	}

#ifdef TURRET_DEBUG
	string sd,sa,sm,sp,ss;
	string sdt,sat,smt,spt;

	sd = ftos(d_score);
	d_score *= _turret.target_select_rangebias;
	sdt = ftos(d_score);

	//sv = ftos(v_score);
	//v_score *= _turret.target_select_samebias;
	//svt = ftos(v_score);

	sa = ftos(a_score);
	a_score *= _turret.target_select_anglebias;
	sat = ftos(a_score);

	sm = ftos(m_score);
	m_score *= _turret.target_select_missilebias;
	smt = ftos(m_score);

	sp = ftos(p_score);
	p_score *= _turret.target_select_playerbias;
	spt = ftos(p_score);


	ss = ftos(score);
	bprint("^3Target scores^7 \[  ",_turret.netname, "  \] ^3for^7 \[  ", _target.netname,"  \]\n");
	bprint("^5Range:\[  ",sd,  "  \]^2+bias:\[  ",sdt,"  \]\n");
	bprint("^5Angle:\[  ",sa,  "  \]^2+bias:\[  ",sat,"  \]\n");
	bprint("^5Missile:\[  ",sm,"  \]^2+bias:\[  ",smt,"  \]\n");
	bprint("^5Player:\[  ",sp, "  \]^2+bias:\[  ",spt,"  \]\n");
	bprint("^3Total (w/bias):\[^1",ss,"\]\n");

#endif

	return score;
}

// Generic damage handling
void() turret_respawn;
void turret_hide()
{
	self.effects   |= EF_NODRAW;
	self.nextthink = time + self.respawntime - 0.2;
	self.think	 = turret_respawn;
}

void turret_die()
{
	self.deadflag		  = DEAD_DEAD;
	self.tur_head.deadflag = self.deadflag;

// Unsolidify and hide real parts
	self.solid			 = SOLID_NOT;
	self.tur_head.solid	 = self.solid;

	self.event_damage		  = func_null;
	self.takedamage			 = DAMAGE_NO;

	self.health			 = 0;

// Go boom
	//RadiusDamage (self,self, min(self.ammo,50),min(self.ammo,50) * 0.25,250,world,min(self.ammo,50)*5,DEATH_TURRET,world);

	if(self.damage_flags & TFL_DMG_DEATH_NORESPAWN)
	{
		TUR_ACTION(self.turretid, TR_DEATH);

		remove(self.tur_head);
		remove(self);
	}
	else
	{
		// Setup respawn
		self.SendFlags	  |= TNSF_STATUS;
		self.nextthink	 = time + 0.2;
		self.think		 = turret_hide;

		TUR_ACTION(self.turretid, TR_DEATH);
	}
}

void turret_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
	// Enougth allready!
	if(self.deadflag == DEAD_DEAD)
		return;

	// Inactive turrets take no damage. (hm..)
	if(!self.active)
		return;

	if(SAME_TEAM(self, attacker))
	{
		if(autocvar_g_friendlyfire)
			damage = damage * autocvar_g_friendlyfire;
		else
			return;
	}

	self.health -= damage;

	// thorw head slightly off aim when hit?
	if (self.damage_flags & TFL_DMG_HEADSHAKE)
	{
		self.tur_head.angles_x = self.tur_head.angles_x + (-0.5 + random()) * damage;
		self.tur_head.angles_y = self.tur_head.angles_y + (-0.5 + random()) * damage;

		self.SendFlags  |= TNSF_ANG;
	}

	if (self.turret_flags & TUR_FLAG_MOVE)
		self.velocity = self.velocity + vforce;

	if (self.health <= 0)
	{
		self.event_damage		  = func_null;
		self.tur_head.event_damage = func_null;
		self.takedamage			 = DAMAGE_NO;
		self.nextthink = time;
		self.think = turret_die;
	}

	self.SendFlags  |= TNSF_STATUS;
}

void() turret_think;
void turret_respawn()
{
	// Make sure all parts belong to the same team since
	// this function doubles as "teamchange" function.
	self.tur_head.team 	= self.team;
	self.effects			   &= ~EF_NODRAW;
	self.deadflag				= DEAD_NO;
	self.effects				= EF_LOWPRECISION;
	self.solid					= SOLID_BBOX;
	self.takedamage 			= DAMAGE_AIM;
	self.event_damage			= turret_damage;
	self.avelocity				= '0 0 0';
	self.tur_head.avelocity		= self.avelocity;
	self.tur_head.angles		= self.idle_aim;
	self.health					= self.max_health;
	self.enemy					= world;
	self.volly_counter			= self.shot_volly;
	self.ammo					= self.ammo_max;

	self.nextthink = time + self.ticrate;
	self.think	 = turret_think;

	self.SendFlags = TNSF_FULL_UPDATE;
	
	TUR_ACTION(self.turretid, TR_SETUP);
}


// Main functions
#define cvar_base "g_turrets_unit_"
.float clientframe;
void turrets_setframe(float _frame, float client_only)
{
	if((client_only ? self.clientframe : self.frame ) != _frame)
	{
		self.SendFlags |= TNSF_ANIM;
		self.anim_start_time = time;
	}

	 if(client_only)
		self.clientframe = _frame;
	else
		self.frame = _frame;

}

float turret_send(entity to, float sf)
{

	WriteByte(MSG_ENTITY, ENT_CLIENT_TURRET);
	WriteByte(MSG_ENTITY, sf);
	if(sf & TNSF_SETUP)
	{
		WriteByte(MSG_ENTITY, self.turretid);

		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteAngle(MSG_ENTITY, self.angles_x);
		WriteAngle(MSG_ENTITY, self.angles_y);
	}

	if(sf & TNSF_ANG)
	{
		WriteShort(MSG_ENTITY, rint(self.tur_head.angles_x));
		WriteShort(MSG_ENTITY, rint(self.tur_head.angles_y));
	}

	if(sf & TNSF_AVEL)
	{
		WriteShort(MSG_ENTITY, rint(self.tur_head.avelocity_x));
		WriteShort(MSG_ENTITY, rint(self.tur_head.avelocity_y));
	}

	if(sf & TNSF_MOVE)
	{
		WriteShort(MSG_ENTITY, rint(self.origin_x));
		WriteShort(MSG_ENTITY, rint(self.origin_y));
		WriteShort(MSG_ENTITY, rint(self.origin_z));

		WriteShort(MSG_ENTITY, rint(self.velocity_x));
		WriteShort(MSG_ENTITY, rint(self.velocity_y));
		WriteShort(MSG_ENTITY, rint(self.velocity_z));

		WriteShort(MSG_ENTITY, rint(self.angles_y));
	}

	if(sf & TNSF_ANIM)
	{
		WriteCoord(MSG_ENTITY, self.anim_start_time);
		WriteByte(MSG_ENTITY, self.frame);
	}

	if(sf & TNSF_STATUS)
	{
		WriteByte(MSG_ENTITY, self.team);

		if(self.health <= 0)
			WriteByte(MSG_ENTITY, 0);
		else
			WriteByte(MSG_ENTITY, ceil((self.health / self.max_health) * 255));
	}

	return TRUE;
}

void load_unit_settings(entity ent, string unitname, float is_reload)
{
	string sbase;

	if (ent == world)
		return;

	if(!ent.turret_scale_damage)	ent.turret_scale_damage = 1;
	if(!ent.turret_scale_range)		ent.turret_scale_range  = 1;
	if(!ent.turret_scale_refire)	ent.turret_scale_refire = 1;
	if(!ent.turret_scale_ammo)		ent.turret_scale_ammo	= 1;
	if(!ent.turret_scale_aim)		ent.turret_scale_aim	 = 1;
	if(!ent.turret_scale_health)	ent.turret_scale_health = 1;
	if(!ent.turret_scale_respawn)	ent.turret_scale_respawn = 1;

	sbase = strcat(cvar_base,unitname);
	if (is_reload)
	{
		ent.enemy = world;
		ent.tur_head.avelocity = '0 0 0';

		ent.tur_head.angles = '0 0 0';
	}

	ent.health	 = cvar(strcat(sbase,"_health")) * ent.turret_scale_health;
	ent.respawntime = cvar(strcat(sbase,"_respawntime")) * ent.turret_scale_respawn;

	ent.shot_dmg		 = cvar(strcat(sbase,"_shot_dmg")) * ent.turret_scale_damage;
	ent.shot_refire	  = cvar(strcat(sbase,"_shot_refire")) * ent.turret_scale_refire;
	ent.shot_radius	  = cvar(strcat(sbase,"_shot_radius")) * ent.turret_scale_damage;
	ent.shot_speed		= cvar(strcat(sbase,"_shot_speed"));
	ent.shot_spread	  = cvar(strcat(sbase,"_shot_spread"));
	ent.shot_force		= cvar(strcat(sbase,"_shot_force")) * ent.turret_scale_damage;
	ent.shot_volly		= cvar(strcat(sbase,"_shot_volly"));
	ent.shot_volly_refire = cvar(strcat(sbase,"_shot_volly_refire")) * ent.turret_scale_refire;

	ent.target_range		 = cvar(strcat(sbase,"_target_range")) * ent.turret_scale_range;
	ent.target_range_min	 = cvar(strcat(sbase,"_target_range_min")) * ent.turret_scale_range;
	ent.target_range_optimal = cvar(strcat(sbase,"_target_range_optimal")) * ent.turret_scale_range;
	//ent.target_range_fire	= cvar(strcat(sbase,"_target_range_fire")) * ent.turret_scale_range;

	ent.target_select_rangebias = cvar(strcat(sbase,"_target_select_rangebias"));
	ent.target_select_samebias  = cvar(strcat(sbase,"_target_select_samebias"));
	ent.target_select_anglebias = cvar(strcat(sbase,"_target_select_anglebias"));
	ent.target_select_playerbias = cvar(strcat(sbase,"_target_select_playerbias"));
	//ent.target_select_fov = cvar(cvar_gets(sbase,"_target_select_fov"));

	ent.ammo_max	 = cvar(strcat(sbase,"_ammo_max")) * ent.turret_scale_ammo;
	ent.ammo_recharge = cvar(strcat(sbase,"_ammo_recharge")) * ent.turret_scale_ammo;

	ent.aim_firetolerance_dist = cvar(strcat(sbase,"_aim_firetolerance_dist"));
	ent.aim_speed	= cvar(strcat(sbase,"_aim_speed")) * ent.turret_scale_aim;
	ent.aim_maxrotate  = cvar(strcat(sbase,"_aim_maxrot"));
	ent.aim_maxpitch = cvar(strcat(sbase,"_aim_maxpitch"));

	ent.track_type		= cvar(strcat(sbase,"_track_type"));
	ent.track_accel_pitch = cvar(strcat(sbase,"_track_accel_pitch"));
	ent.track_accel_rotate  = cvar(strcat(sbase,"_track_accel_rot"));
	ent.track_blendrate  = cvar(strcat(sbase,"_track_blendrate"));

	if(is_reload)
		TUR_ACTION(self.turretid, TR_SETUP);
}

void turret_projectile_explode()
{

	self.takedamage = DAMAGE_NO;
	self.event_damage = func_null;
#ifdef TURRET_DEBUG
	float d;
	d = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
	self.owner.tur_debug_dmg_t_h = self.owner.tur_debug_dmg_t_h + d;
	self.owner.tur_debug_dmg_t_f = self.owner.tur_debug_dmg_t_f + self.owner.shot_dmg;
#else
	RadiusDamage (self, self.realowner, self.owner.shot_dmg, 0, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
#endif
	remove(self);
}

void turret_projectile_touch()
{
	PROJECTILE_TOUCH;
	turret_projectile_explode();
}

void turret_projectile_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
	self.velocity  += vforce;
	self.health	-= damage;
	//self.realowner = attacker; // Dont change realowner, it does not make much sense for turrets
	if(self.health <= 0)
		W_PrepareExplosionByDamage(self.owner, turret_projectile_explode);
}

entity turret_projectile(string _snd, float _size, float _health, float _death, float _proj_type, float _cull, float _cli_anim)
{
	entity proj;

	sound (self, CH_WEAPON_A, _snd, VOL_BASE, ATTEN_NORM);
	proj				 = spawn ();
	setorigin(proj, self.tur_shotorg);
	setsize(proj, '-0.5 -0.5 -0.5' * _size, '0.5 0.5 0.5' * _size);
	proj.owner		  = self;
	proj.realowner	  = self;
	proj.bot_dodge	  = TRUE;
	proj.bot_dodgerating = self.shot_dmg;
	proj.think		  = turret_projectile_explode;
	proj.touch		  = turret_projectile_touch;
	proj.nextthink	  = time + 9;
	proj.movetype		= MOVETYPE_FLYMISSILE;
	proj.velocity		= normalize(self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
	proj.flags		  = FL_PROJECTILE;
	proj.enemy		  = self.enemy;
	proj.totalfrags	 = _death;
	PROJECTILE_MAKETRIGGER(proj);
	if(_health)
	{
		proj.health		 = _health;
		proj.takedamage	 = DAMAGE_YES;
		proj.event_damage  = turret_projectile_damage;
	}
	else
		proj.flags |= FL_NOTARGET;

	CSQCProjectile(proj, _cli_anim, _proj_type, _cull);

	return proj;
}

/**
** updates enemy distances, predicted impact point/time
** and updated aim<->predict impact distance.
**/
void turret_do_updates(entity t_turret)
{
	vector enemy_pos;
	entity oldself;

	oldself = self;
	self = t_turret;

	enemy_pos = real_origin(self.enemy);

	turret_tag_fire_update();

	self.tur_shotdir_updated = v_forward;
	self.tur_dist_enemy = vlen(self.tur_shotorg - enemy_pos);
	self.tur_dist_aimpos = vlen(self.tur_shotorg - self.tur_aimpos);

	/*if((self.firecheck_flags & TFL_FIRECHECK_VERIFIED) && (self.enemy))
	{
		oldpos = self.enemy.origin;
		setorigin(self.enemy, self.tur_aimpos);
		tracebox(self.tur_shotorg, '-1 -1 -1', '1 1 1', self.tur_shotorg + (self.tur_shotdir_updated * self.tur_dist_aimpos), MOVE_NORMAL,self);
		setorigin(self.enemy, oldpos);

		if(trace_ent == self.enemy)
			self.tur_dist_impact_to_aimpos = 0;
		else
			self.tur_dist_impact_to_aimpos = vlen(trace_endpos - self.tur_aimpos);
	}
	else*/
		tracebox(self.tur_shotorg, '-1 -1 -1','1 1 1', self.tur_shotorg + (self.tur_shotdir_updated * self.tur_dist_aimpos), MOVE_NORMAL,self);

	self.tur_dist_impact_to_aimpos = vlen(trace_endpos - self.tur_aimpos) - (vlen(self.enemy.maxs - self.enemy.mins) * 0.5);
	self.tur_impactent			 = trace_ent;
	self.tur_impacttime			= vlen(self.tur_shotorg - trace_endpos) / self.shot_speed;

	self = oldself;
}

/**
** Handles head rotation according to
** the units .track_type and .track_flags
**/
.float turret_framecounter;
void turret_track()
{
	vector target_angle; // This is where we want to aim
	vector move_angle;   // This is where we can aim
	float f_tmp;
	vector v1, v2;
	v1 = self.tur_head.angles;
	v2 = self.tur_head.avelocity;

	if (self.track_flags == TFL_TRACK_NO)
		return;

	if(!self.active)
		target_angle = self.idle_aim - ('1 0 0' * self.aim_maxpitch);
	else if (self.enemy == world)
	{
		if(time > self.lip)
			target_angle = self.idle_aim + self.angles;
		else
			target_angle = vectoangles(normalize(self.tur_aimpos - self.tur_shotorg));
	}
	else
	{
		target_angle = vectoangles(normalize(self.tur_aimpos - self.tur_shotorg));
	}

	self.tur_head.angles_x = anglemods(self.tur_head.angles_x);
	self.tur_head.angles_y = anglemods(self.tur_head.angles_y);

	// Find the diffrence between where we currently aim and where we want to aim
	//move_angle = target_angle - (self.angles + self.tur_head.angles);
	//move_angle = shortangle_vxy(move_angle,(self.angles + self.tur_head.angles));

	move_angle = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(self.angles), AnglesTransform_FromAngles(target_angle))) - self.tur_head.angles;
	move_angle = shortangle_vxy(move_angle, self.tur_head.angles);

	switch(self.track_type)
	{
		case TFL_TRACKTYPE_STEPMOTOR:
			f_tmp = self.aim_speed * self.ticrate; // dgr/sec -> dgr/tic
			if (self.track_flags & TFL_TRACK_PITCH)
			{
				self.tur_head.angles_x += bound(-f_tmp,move_angle_x, f_tmp);
				if(self.tur_head.angles_x > self.aim_maxpitch)
					self.tur_head.angles_x = self.aim_maxpitch;

				if(self.tur_head.angles_x  < -self.aim_maxpitch)
					self.tur_head.angles_x = self.aim_maxpitch;
			}

			if (self.track_flags & TFL_TRACK_ROTATE)
			{
				self.tur_head.angles_y += bound(-f_tmp, move_angle_y, f_tmp);
				if(self.tur_head.angles_y > self.aim_maxrotate)
					self.tur_head.angles_y = self.aim_maxrotate;

				if(self.tur_head.angles_y  < -self.aim_maxrotate)
					self.tur_head.angles_y = self.aim_maxrotate;
			}

			// CSQC
			self.SendFlags  |= TNSF_ANG;

			return;

		case TFL_TRACKTYPE_FLUIDINERTIA:
			f_tmp = self.aim_speed * self.ticrate; // dgr/sec -> dgr/tic
			move_angle_x = bound(-self.aim_speed, move_angle_x * self.track_accel_pitch * f_tmp, self.aim_speed);
			move_angle_y = bound(-self.aim_speed, move_angle_y * self.track_accel_rotate * f_tmp, self.aim_speed);
			move_angle = (self.tur_head.avelocity * self.track_blendrate) + (move_angle * (1 - self.track_blendrate));
			break;

		case TFL_TRACKTYPE_FLUIDPRECISE:

			move_angle_y = bound(-self.aim_speed, move_angle_y, self.aim_speed);
			move_angle_x = bound(-self.aim_speed, move_angle_x, self.aim_speed);

			break;
	}

	//  pitch
	if (self.track_flags & TFL_TRACK_PITCH)
	{
		self.tur_head.avelocity_x = move_angle_x;
		if((self.tur_head.angles_x + self.tur_head.avelocity_x * self.ticrate) > self.aim_maxpitch)
		{
			self.tur_head.avelocity_x = 0;
			self.tur_head.angles_x = self.aim_maxpitch;

			self.SendFlags  |= TNSF_ANG;
		}

		if((self.tur_head.angles_x + self.tur_head.avelocity_x * self.ticrate) < -self.aim_maxpitch)
		{
			self.tur_head.avelocity_x = 0;
			self.tur_head.angles_x = -self.aim_maxpitch;

			self.SendFlags  |= TNSF_ANG;
		}
	}

	//  rot
	if (self.track_flags & TFL_TRACK_ROTATE)
	{
		self.tur_head.avelocity_y = move_angle_y;

		if((self.tur_head.angles_y + self.tur_head.avelocity_y * self.ticrate) > self.aim_maxrotate)
		{
			self.tur_head.avelocity_y = 0;
			self.tur_head.angles_y = self.aim_maxrotate;

			self.SendFlags  |= TNSF_ANG;
		}

		if((self.tur_head.angles_y + self.tur_head.avelocity_y * self.ticrate) < -self.aim_maxrotate)
		{
			self.tur_head.avelocity_y = 0;
			self.tur_head.angles_y = -self.aim_maxrotate;

			self.SendFlags  |= TNSF_ANG;
		}
	}

	self.SendFlags  |= TNSF_AVEL;

	// Force a angle update every 10'th frame
	self.turret_framecounter += 1;
	if(self.turret_framecounter >= 10)
	{
		self.SendFlags |= TNSF_ANG;
		self.turret_framecounter = 0;
	}
}

/*
 + TFL_TARGETSELECT_NO
 + TFL_TARGETSELECT_LOS
 + TFL_TARGETSELECT_PLAYERS
 + TFL_TARGETSELECT_MISSILES
 - TFL_TARGETSELECT_TRIGGERTARGET
 + TFL_TARGETSELECT_ANGLELIMITS
 + TFL_TARGETSELECT_RANGELIMITS
 + TFL_TARGETSELECT_TEAMCHECK
 - TFL_TARGETSELECT_NOBUILTIN
 + TFL_TARGETSELECT_OWNTEAM
*/

/**
** Evaluate a entity for target valitity based on validate_flags
** NOTE: the caller must check takedamage before calling this, to inline this check.
**/
float turret_validate_target(entity e_turret, entity e_target, float validate_flags)
{
	vector v_tmp;

	//if(!validate_flags & TFL_TARGETSELECT_NOBUILTIN)
	//	return -0.5;

	if(e_target.owner == e_turret)
		return -0.5;

	if(!checkpvs(e_target.origin, e_turret))
		return -1;

	if(!e_target)
		return -2;

	if(g_onslaught)
		if (substring(e_target.classname, 0, 10) == "onslaught_") // don't attack onslaught targets, that's the player's job!
			return - 3;

	if (validate_flags & TFL_TARGETSELECT_NO)
		return -4;

	// If only this was used more..
	if (e_target.flags & FL_NOTARGET)
		return -5;

	// Cant touch this
	if(IS_VEHICLE(e_target))
	{
		if (e_target.vehicle_health <= 0)
			return -6;
	}
	else if (e_target.health <= 0)
		return -6;
	else if(e_target.frozen > 0)
		return -6;
	else if(e_target.jb_isprisoned > 0)
		return -6;

	// player
	if (IS_CLIENT(e_target))
	{
		if(!(validate_flags & TFL_TARGETSELECT_PLAYERS))
			return -7;

		if (e_target.deadflag != DEAD_NO)
			return -8;
	}

	// enemy turrets
	if(validate_flags & TFL_TARGETSELECT_NOTURRETS)
	if(e_target.owner.tur_head == e_target)
	if(e_target.team != e_turret.team) // Dont break support units.
		return -9;

	// Missile
	if (e_target.flags & FL_PROJECTILE)
	if(!(validate_flags & TFL_TARGETSELECT_MISSILES))
		return -10;

	if (validate_flags & TFL_TARGETSELECT_MISSILESONLY)
	if(!(e_target.flags & FL_PROJECTILE))
		return -10.5;

	// Team check
	if (validate_flags & TFL_TARGETSELECT_TEAMCHECK)
	{
		if (validate_flags & TFL_TARGETSELECT_OWNTEAM)
		{
			if (e_target.team != e_turret.team)
				return -11;

			if (e_turret.team != e_target.owner.team)
				return -12;
		}
		else
		{
			if (e_target.team == e_turret.team)
				return -13;

			if (e_turret.team == e_target.owner.team)
				return -14;
		}
	}

	// Range limits?
	tvt_dist = vlen(e_turret.origin - real_origin(e_target));
	if (validate_flags & TFL_TARGETSELECT_RANGELIMITS)
	{
		if (tvt_dist < e_turret.target_range_min)
			return -15;

		if (tvt_dist > e_turret.target_range)
			return -16;
	}

	// Can we even aim this thing?
	tvt_thadv = angleofs3(e_turret.tur_head.origin, e_turret.angles + e_turret.tur_head.angles, e_target);
	tvt_tadv = shortangle_vxy(angleofs(e_turret, e_target), e_turret.angles);
	tvt_thadf = vlen(tvt_thadv);
	tvt_tadf = vlen(tvt_tadv);

	/*
	if(validate_flags & TFL_TARGETSELECT_FOV)
	{
		if(e_turret.target_select_fov < tvt_thadf)
			return -21;
	}
	*/

	if (validate_flags & TFL_TARGETSELECT_ANGLELIMITS)
	{
		if (fabs(tvt_tadv_x) > e_turret.aim_maxpitch)
			return -17;

		if (fabs(tvt_tadv_y) > e_turret.aim_maxrotate)
			return -18;
	}

	// Line of sight?
	if (validate_flags & TFL_TARGETSELECT_LOS)
	{
		v_tmp = real_origin(e_target) + ((e_target.mins + e_target.maxs) * 0.5);

		traceline(e_turret.origin + '0 0 16', v_tmp, 0, e_turret);

		if (e_turret.aim_firetolerance_dist < vlen(v_tmp - trace_endpos))
			return -19;
	}

	if (e_target.classname == "grapplinghook")
		return -20;

	/*
	if (e_target.classname == "func_button")
		return -21;
	*/

#ifdef TURRET_DEBUG_TARGETSELECT
	dprint("Target:",e_target.netname," is a valid target for ",e_turret.netname,"\n");
#endif

	return 1;
}

entity turret_select_target()
{
	entity e;		// target looper entity
	float  score;	// target looper entity score
	entity e_enemy;  // currently best scoreing target
	float  m_score;  // currently best scoreing target's score

	m_score = 0;
	if(self.enemy && self.enemy.takedamage && turret_validate_target(self,self.enemy,self.target_validate_flags) > 0)
	{
		e_enemy = self.enemy;
		m_score = self.turret_score_target(self,e_enemy) * self.target_select_samebias;
	}
	else
		e_enemy = self.enemy = world;

	e = findradius(self.origin, self.target_range);

	// Nothing to aim at?
	if (!e)
		return world;

	while (e)
	{
		if(e.takedamage)
		{
			float f = turret_validate_target(self, e, self.target_select_flags);
			//dprint("F is: ", ftos(f), "\n");
			if ( f > 0)
			{
				score = self.turret_score_target(self,e);
				if ((score > m_score) && (score > 0))
				{
					e_enemy = e;
					m_score = score;
				}
			}
		}
		e = e.chain;
	}

	return e_enemy;
}


/*
 + = implemented
 - = not implemented

 + TFL_FIRECHECK_NO
 + TFL_FIRECHECK_WORLD
 + TFL_FIRECHECK_DEAD
 + TFL_FIRECHECK_DISTANCES
 - TFL_FIRECHECK_LOS
 + TFL_FIRECHECK_AIMDIST
 + TFL_FIRECHECK_REALDIST
 - TFL_FIRECHECK_ANGLEDIST
 - TFL_FIRECHECK_TEAMCECK
 + TFL_FIRECHECK_AFF
 + TFL_FIRECHECK_AMMO_OWN
 + TFL_FIRECHECK_AMMO_OTHER
 + TFL_FIRECHECK_REFIRE
*/

/**
** Preforms pre-fire checks based on the uints firecheck_flags
**/
float turret_firecheck()
{
	// This one just dont care =)
	if (self.firecheck_flags & TFL_FIRECHECK_NO)
		return 1;

	if (self.enemy == world)
		return 0;

	// Ready?
	if (self.firecheck_flags & TFL_FIRECHECK_REFIRE)
		if (self.attack_finished_single > time) return 0;

	// Special case: volly fire turret that has to fire a full volly if a shot was fired.
	if (self.shoot_flags & TFL_SHOOT_VOLLYALWAYS)
		if (self.volly_counter != self.shot_volly)
			if(self.ammo >= self.shot_dmg)
				return 1;

	// Lack of zombies makes shooting dead things unnecessary :P
	if (self.firecheck_flags & TFL_FIRECHECK_DEAD)
		if (self.enemy.deadflag != DEAD_NO)
			return 0;

	// Own ammo?
	if (self.firecheck_flags & TFL_FIRECHECK_AMMO_OWN)
		if (self.ammo < self.shot_dmg)
			return 0;

	// Other's ammo? (support-supply units)
	if (self.firecheck_flags & TFL_FIRECHECK_AMMO_OTHER)
		if (self.enemy.ammo >= self.enemy.ammo_max)
			return 0;

	// Target of opertunity?
	if(turret_validate_target(self, self.tur_impactent, self.target_validate_flags) > 0)
	{
		self.enemy = self.tur_impactent;
		return 1;
	}

	if (self.firecheck_flags & TFL_FIRECHECK_DISTANCES)
	{
		// To close?
		if (self.tur_dist_aimpos < self.target_range_min)
			if(turret_validate_target(self, self.tur_impactent, self.target_validate_flags) > 0)
				return 1; // Target of opertunity?
			else
				return 0;
	}

	// Try to avoid FF?
	if (self.firecheck_flags & TFL_FIRECHECK_AFF)
		if (self.tur_impactent.team == self.team)
			return 0;

	// aim<->predicted impact
	if (self.firecheck_flags & TFL_FIRECHECK_AIMDIST)
		if (self.tur_dist_impact_to_aimpos > self.aim_firetolerance_dist)
			return 0;

	// Volly status
	if (self.shot_volly > 1)
		if (self.volly_counter == self.shot_volly)
			if (self.ammo < (self.shot_dmg * self.shot_volly))
				return 0;

	/*if(self.firecheck_flags & TFL_FIRECHECK_VERIFIED)
		if(self.tur_impactent != self.enemy)
			return 0;*/

	return 1;
}

void turret_fire()
{
	if (autocvar_g_turrets_nofire != 0)
		return;
		
	TUR_ACTION(self.turretid, TR_ATTACK);

	self.attack_finished_single = time + self.shot_refire;
	self.ammo -= self.shot_dmg;
	self.volly_counter = self.volly_counter - 1;

	if (self.volly_counter <= 0)
	{
		self.volly_counter = self.shot_volly;

		if (self.shoot_flags & TFL_SHOOT_CLEARTARGET)
			self.enemy = world;

		if (self.shot_volly > 1)
			self.attack_finished_single = time + self.shot_volly_refire;
	}

#ifdef TURRET_DEBUG
	if (self.enemy) paint_target3(self.tur_aimpos, 64, self.tur_debug_rvec, self.tur_impacttime + 0.25);
#endif
}

void turret_think()
{
	entity e;

	self.nextthink = time + self.ticrate;

	// ONS uses somewhat backwards linking.
	if (teamplay)
	{
		if (g_onslaught)
			if (self.target)
			{
				e = find(world, targetname,self.target);
				if (e != world)
					self.team = e.team;
			}

		if (self.team != self.tur_head.team)
			turret_respawn();
	}

#ifdef TURRET_DEBUG
	if (self.tur_debug_tmr1 < time)
	{
		if (self.enemy) paint_target (self.enemy,128,self.tur_debug_rvec,0.9);
		paint_target(self,256,self.tur_debug_rvec,0.9);
		self.tur_debug_tmr1 = time + 1;
	}
#endif

	// Handle ammo
	if (!(self.spawnflags & TSF_NO_AMMO_REGEN))
	if (self.ammo < self.ammo_max)
		self.ammo = min(self.ammo + self.ammo_recharge, self.ammo_max);

	// Inactive turrets needs to run the think loop,
	// So they can handle animation and wake up if need be.
	if(!self.active)
	{
		turret_track();
		return;
	}

	// This is typicaly used for zaping every target in range
	// turret_fusionreactor uses this to recharge friendlys.
	if (self.shoot_flags & TFL_SHOOT_HITALLVALID)
	{
		// Do a self.turret_fire for every valid target.
		e = findradius(self.origin,self.target_range);
		while (e)
		{
			if(e.takedamage)
			{
				if (turret_validate_target(self,e,self.target_validate_flags))
				{
					self.enemy = e;

					turret_do_updates(self);

					if (self.turret_firecheckfunc())
						turret_fire();
				}
			}

			e = e.chain;
		}
		self.enemy = world;
	}
	else if(self.shoot_flags & TFL_SHOOT_CUSTOM)
	{
		// This one is doing something.. oddball. assume its handles what needs to be handled.

		// Predict?
		if(!(self.aim_flags & TFL_AIM_NO))
			self.tur_aimpos = turret_aim_generic();

		// Turn & pitch?
		if(!(self.track_flags & TFL_TRACK_NO))
			turret_track();

		turret_do_updates(self);

		// Fire?
		if (self.turret_firecheckfunc())
			turret_fire();
	}
	else
	{
		// Special case for volly always. if it fired once it must compleate the volly.
		if(self.shoot_flags & TFL_SHOOT_VOLLYALWAYS)
			if(self.volly_counter != self.shot_volly)
			{
				// Predict or whatnot
				if(!(self.aim_flags & TFL_AIM_NO))
					self.tur_aimpos = turret_aim_generic();

				// Turn & pitch
				if(!(self.track_flags & TFL_TRACK_NO))
					turret_track();

				turret_do_updates(self);

				// Fire!
				if (self.turret_firecheckfunc() != 0)
					turret_fire();
					
				TUR_ACTION(self.turretid, TR_THINK);

				return;
			}

		// Check if we have a vailid enemy, and try to find one if we dont.

		// g_turrets_targetscan_maxdelay forces a target re-scan at least this often
		float do_target_scan = 0;
		if((self.target_select_time + autocvar_g_turrets_targetscan_maxdelay) < time)
			do_target_scan = 1;

		// Old target (if any) invalid?
		if(self.target_validate_time < time)
		if (turret_validate_target(self, self.enemy, self.target_validate_flags) <= 0)
		{
			self.enemy = world;
			self.target_validate_time = time + 0.5;
			do_target_scan = 1;
		}

		// But never more often then g_turrets_targetscan_mindelay!
		if (self.target_select_time + autocvar_g_turrets_targetscan_mindelay > time)
			do_target_scan = 0;

		if(do_target_scan)
		{
			self.enemy = turret_select_target();
			self.target_select_time = time;
		}

		// No target, just go to idle, do any custom stuff and bail.
		if (self.enemy == world)
		{
			// Turn & pitch
			if(!(self.track_flags & TFL_TRACK_NO))
				turret_track();
				
			TUR_ACTION(self.turretid, TR_THINK);

			// And bail.
			return;
		}
		else
			self.lip = time + autocvar_g_turrets_aimidle_delay; // Keep track of the last time we had a target.

		// Predict?
		if(!(self.aim_flags & TFL_AIM_NO))
			self.tur_aimpos = turret_aim_generic();

		// Turn & pitch?
		if(!(self.track_flags & TFL_TRACK_NO))
			turret_track();

		turret_do_updates(self);

		// Fire?
		if (self.turret_firecheckfunc())
			turret_fire();
	}

	TUR_ACTION(self.turretid, TR_THINK);
}

/*
	When .used a turret switch team to activator.team.
	If activator is world, the turret go inactive.
*/
void turret_use()
{
	dprint("Turret ",self.netname, " used by ", activator.classname, "\n");

	self.team = activator.team;

	if(self.team == 0)
		self.active = ACTIVE_NOT;
	else
		self.active = ACTIVE_ACTIVE;

}

void turret_link()
{
	Net_LinkEntity(self, TRUE, 0, turret_send);
	self.think	 = turret_think;
	self.nextthink = time;
	self.tur_head.effects = EF_NODRAW;
}

void turrets_manager_think()
{
	self.nextthink = time + 1;

	entity e;
	if (autocvar_g_turrets_reloadcvars == 1)
	{
		e = nextent(world);
		while (e)
		{
			if (IS_TURRET(e))
			{
				load_unit_settings(e,e.cvar_basename,1);
				TUR_ACTION(self.turretid, TR_THINK);
			}

			e = nextent(e);
		}
		cvar_set("g_turrets_reloadcvars","0");
	}
}

float turret_initialize(float tur_id)
{
	if(!autocvar_g_turrets)
		return FALSE;

	entity e;
	entity tur = get_turretinfo(tur_id);
	if(tur.turretid == 0)
		return FALSE; // invalid turret

	e = find(world, classname, "turret_manager");
	if(!e)
	{
		e = spawn();
		e.classname = "turret_manager";
		e.think = turrets_manager_think;
		e.nextthink = time + 2;
	}

	if(!(self.spawnflags & TSF_SUSPENDED))
		builtin_droptofloor();

	self.cvar_basename = tur.cvar_basename;
	load_unit_settings(self, self.cvar_basename, 0);
	
	if(!self.team || !teamplay)		{ self.team = MAX_SHOT_DISTANCE; }
	if(!self.ticrate)				{ self.ticrate = ((self.turret_flags & TUR_FLAG_SUPPORT) ? 0.2 : 0.1); }
	if(!self.health)				{ self.health = 1000; }
	if(!self.shot_refire)			{ self.shot_refire = 1; }
	if(!self.tur_shotorg)			{ self.tur_shotorg = '50 0 50'; }
	if(!self.turret_flags)			{ self.turret_flags = TUR_FLAG_SPLASH | TUR_FLAG_MEDPROJ | TUR_FLAG_PLAYER; }
	if(!self.damage_flags)			{ self.damage_flags = TFL_DMG_YES | TFL_DMG_RETALIATE | TFL_DMG_AIMSHAKE; }
	if(!self.aim_flags)				{ self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE; }
	if(!self.track_type)			{ self.track_type = TFL_TRACKTYPE_STEPMOTOR; }
	if(!self.track_flags)			{ self.track_flags = TFL_TRACK_PITCH | TFL_TRACK_ROTATE; }
	if(!self.ammo_flags)			{ self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE; }
	if(!self.target_select_flags)	{ self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_ANGLELIMITS; }
	if(!self.firecheck_flags)		{ self.firecheck_flags = TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_LOS
														   | TFL_FIRECHECK_AIMDIST | TFL_FIRECHECK_TEAMCHECK | TFL_FIRECHECK_AMMO_OWN | TFL_FIRECHECK_REFIRE; }
														   
	if(self.track_type != TFL_TRACKTYPE_STEPMOTOR)
	{
		// Fluid / Ineria mode. Looks mutch nicer.
		// Can reduce aim preformance alot, needs a bit diffrent aimspeed
		
		self.aim_speed = bound(0.1, ((!self.aim_speed) ? 180 : self.aim_speed), 1000);
		
		if(!self.track_accel_pitch)		{ self.track_accel_pitch = 0.5; }
		if(!self.track_accel_rotate)	{ self.track_accel_rotate = 0.5; }
		if(!self.track_blendrate)		{ self.track_blendrate = 0.35; }
	}
	
	self.respawntime 				= max(-1, ((!self.respawntime) ? 60 : self.respawntime));
	self.shot_refire 				= bound(0.01, ((!self.shot_refire) ? 1 : self.shot_refire), 9999);
	self.shot_dmg 					= max(1, ((!self.shot_dmg) ? self.shot_refire * 50 : self.shot_dmg));
	self.shot_radius 				= max(1, ((!self.shot_radius) ? self.shot_dmg * 0.5 : self.shot_radius));
	self.shot_speed 				= max(1, ((!self.shot_speed) ? 2500 : self.shot_speed));
	self.shot_spread 				= bound(0.0001, ((!self.shot_spread) ? 0.0125 : self.shot_spread), 500);
	self.shot_force 				= bound(0.001, ((!self.shot_force) ? self.shot_dmg * 0.5 + self.shot_radius * 0.5 : self.shot_force), 5000);
	self.shot_volly 				= bound(1, ((!self.shot_volly) ? 1 : self.shot_volly), floor(self.ammo_max / self.shot_dmg));
	self.shot_volly_refire 			= bound(self.shot_refire, ((!self.shot_volly_refire) ? self.shot_refire * self.shot_volly : self.shot_volly_refire), 60);
	self.target_range 				= bound(0, ((!self.target_range) ? self.shot_speed * 0.5 : self.target_range), MAX_SHOT_DISTANCE);
	self.target_range_min 			= bound(0, ((!self.target_range_min) ? self.shot_radius * 2 : self.target_range_min), MAX_SHOT_DISTANCE);
	self.target_range_optimal 		= bound(0, ((!self.target_range_optimal) ? self.target_range * 0.5 : self.target_range_optimal), MAX_SHOT_DISTANCE);
	self.aim_maxrotate				= bound(0, ((!self.aim_maxrotate) ? 90 : self.aim_maxrotate), 360);
	self.aim_maxpitch				= bound(0, ((!self.aim_maxpitch) ? 20 : self.aim_maxpitch), 90);
	self.aim_speed					= bound(0.1, ((!self.aim_speed) ? 36 : self.aim_speed), 1000);
	self.aim_firetolerance_dist 	= bound(0.1, ((!self.aim_firetolerance_dist) ? 5 + (self.shot_radius * 2) : self.aim_firetolerance_dist), MAX_SHOT_DISTANCE);
	self.target_select_rangebias	= bound(-10, ((!self.target_select_rangebias) ? 1 : self.target_select_rangebias), 10);
	self.target_select_samebias 	= bound(-10, ((!self.target_select_samebias) ? 1 : self.target_select_samebias), 10);
	self.target_select_anglebias	= bound(-10, ((!self.target_select_anglebias) ? 1 : self.target_select_anglebias), 10);
	self.target_select_missilebias	= bound(-10, ((!self.target_select_missilebias) ? 1 : self.target_select_missilebias), 10);
	self.target_select_playerbias	= bound(-10, ((!self.target_select_playerbias) ? 1 : self.target_select_playerbias), 10);
	self.ammo_max					= max(self.shot_dmg, ((!self.ammo_max) ? self.shot_dmg * 10 : self.ammo_max));
	self.ammo_recharge				= max(0, ((!self.ammo_recharge) ? self.shot_dmg * 0.5 : self.ammo_recharge));
	
	self.turret_flags = TUR_FLAG_ISTURRET | (tur.spawnflags);
	
	if(self.turret_flags & TUR_FLAG_SPLASH)
		self.aim_flags |= TFL_AIM_SPLASH;
		
	if(self.turret_flags & TUR_FLAG_MISSILE)
		self.target_select_flags |= TFL_TARGETSELECT_MISSILES;

	if(self.turret_flags & TUR_FLAG_PLAYER)
		self.target_select_flags |= TFL_TARGETSELECT_PLAYERS;
		
	if(self.spawnflags & TSL_NO_RESPAWN)
		self.damage_flags |= TFL_DMG_DEATH_NORESPAWN;
		
	if (self.turret_flags & TUR_FLAG_SUPPORT)
		self.turret_score_target = turret_targetscore_support;
	else
		self.turret_score_target = turret_targetscore_generic;
		
	++turret_count;
		
	setmodel(self, tur.model);
	setsize(self, tur.mins, tur.maxs);
	
	self.turretid				= tur_id;
	self.classname				= "turret_main";
	self.active					= ACTIVE_ACTIVE;
	self.effects				= EF_NODRAW;
	self.netname				= TUR_NAME(tur_id);
	self.ticrate				= bound(sys_frametime, self.ticrate, 60);
	self.max_health				= self.health;
	self.target_validate_flags	= self.target_select_flags;
	self.ammo					= self.ammo_max;
	self.ammo_recharge		   *= self.ticrate;
	self.solid					= SOLID_BBOX;
	self.takedamage				= DAMAGE_AIM;
	self.movetype				= MOVETYPE_NOCLIP;
	self.view_ofs				= '0 0 0';
	self.turret_firecheckfunc	= turret_firecheck;
	self.event_damage			= turret_damage;
	self.use					= turret_use;
	self.bot_attack				= TRUE;
	self.nextthink				= time + 1;
	self.nextthink			   += turret_count * sys_frametime;
	
	self.tur_head = spawn();
	setmodel(self.tur_head, tur.head_model);
	setsize(self.tur_head, '0 0 0', '0 0 0');
	setorigin(self.tur_head, '0 0 0');
	setattachment(self.tur_head, self, "tag_head");
	
	self.tur_head.netname		= self.tur_head.classname = "turret_head";
	self.tur_head.team			= self.team;
	self.tur_head.owner			= self;
	self.tur_head.takedamage	= DAMAGE_NO;
	self.tur_head.solid			= SOLID_NOT;
	self.tur_head.movetype		= self.movetype;
	
	if(!self.tur_defend)
	if(self.target != "")
	{
		self.tur_defend = find(world, targetname, self.target);
		if (self.tur_defend == world)
		{
			self.target = "";
			dprint("Turret has invalid defendpoint!\n");
		}
	}
	
	if (self.tur_defend)
		self.idle_aim = self.tur_head.angles + angleofs(self.tur_head, self.tur_defend);
	else
		self.idle_aim = '0 0 0';
		
#ifdef TURRET_DEBUG
	self.tur_debug_start = self.nextthink;
	while (vlen(self.tur_debug_rvec) < 2)
		self.tur_debug_rvec = randomvec() * 4;

	self.tur_debug_rvec_x = fabs(self.tur_debug_rvec_x);
	self.tur_debug_rvec_y = fabs(self.tur_debug_rvec_y);
	self.tur_debug_rvec_z = fabs(self.tur_debug_rvec_z);
#endif

	turret_link();
	turret_respawn();
	turret_tag_fire_update();
	
	TUR_ACTION(tur_id, TR_SETUP);
	
	if(MUTATOR_CALLHOOK(TurretSpawn))
		return FALSE;

	return TRUE;
}