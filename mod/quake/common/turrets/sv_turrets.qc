#include "sv_turrets.qh"

#ifdef SVQC

void turret_initparams(entity tur);
void turret_levelstats(entity ent)
{
	// reset the properties of the turret before scaling

	Turret tur = ent.turretdef;

	#define X(class, prefix, fld, type) ent.fld = tur.fld;
	TR_PROPS_COMMON(X, , )
	#undef X

	//ent.ammo_max             *= turret_getpower(ent.tur_level, 0.2);
	//ent.ammo_recharge        *= turret_getpower(ent.tur_level, 0.2);
	//ent.aim_speed            *= turret_getpower(ent.tur_level, 0.2);
	ent.health               *= turret_getpower(ent.tur_level, 0.2);
	//ent.respawntime          *= turret_getpower(ent.tur_level, 0.2);
	ent.shot_dmg             *= turret_getpower(ent.tur_level, 0.2);
	ent.shot_refire          /= turret_getpower(ent.tur_level, 0.2);
	//ent.shot_radius          *= turret_getpower(ent.tur_level, 0.2);
	//ent.shot_force           *= turret_getpower(ent.tur_level, 0.2);
	ent.shot_volly_refire    /= turret_getpower(ent.tur_level, 0.2);
	ent.target_range         *= turret_getpower(ent.tur_level, 0.2);
	ent.target_range_min     *= turret_getpower(ent.tur_level, 0.2); // TODO?
	ent.target_range_optimal *= turret_getpower(ent.tur_level, 0.2);

	// quake specific
	ent.aim_maxrot           *= turret_getpower(ent.tur_level, 0.05);
	ent.aim_maxpitch         *= turret_getpower(ent.tur_level, 0.05);

	// sanitise them
	turret_initparams(ent);

	ent.max_health = ent.health;
}

void turret_levelup(entity this)
{
	this.tur_level = min(this.tur_level + 1, 5); // TODO: safety check?
	this.health = this.max_health; // fully heals on upgrade
	turret_levelstats(this);
	// TODO: per-turret update function?
	this.SendFlags |= TNSF_STATUS;
	this.SendFlags |= TNSF_LEVEL;
}

// Generic aiming
vector turret_aim_generic(entity this)
{
	turret_tag_fire_update(this);

	if (this.aim_flags & TFL_AIM_SIMPLE)
		return real_origin(this.enemy);

	// Baseline
	vector pre_pos = real_origin(this.enemy);

	// Lead?
	if (this.aim_flags & TFL_AIM_LEAD)
	{
		float mintime = max(this.attack_finished - time, 0) + sys_frametime;

		if (this.aim_flags & TFL_AIM_SHOTTIMECOMPENSATE) // Need to conpensate for shot traveltime
		{
			vector prep = pre_pos;

			float impact_time = vlen(prep - this.tur_shotorg) / this.shot_speed;

			prep += this.enemy.velocity * (impact_time + mintime);

			if ((this.aim_flags & TFL_AIM_ZPREDICT)
			&& !IS_ONGROUND(this.enemy)
			&& (this.enemy.move_movetype == MOVETYPE_WALK || this.enemy.move_movetype == MOVETYPE_STEP || this.enemy.move_movetype == MOVETYPE_TOSS || this.enemy.move_movetype == MOVETYPE_BOUNCE))
			{
				prep.z = pre_pos.z;
				float vz = this.enemy.velocity.z;
				for (float i = 0; i < impact_time; i += sys_frametime)
				{
					vz -= autocvar_sv_gravity * sys_frametime;
					prep.z += vz * sys_frametime;
				}
			}
			pre_pos = prep;
		}
		else
			pre_pos += this.enemy.velocity * mintime;
	}

	if (this.aim_flags & TFL_AIM_SPLASH)
	{
		//tracebox(pre_pos + '0 0 32', this.enemy.mins, this.enemy.maxs, pre_pos -'0 0 64', MOVE_WORLDONLY, this.enemy);
		traceline(pre_pos + '0 0 32', pre_pos - '0 0 64', MOVE_WORLDONLY, this.enemy);
		if (trace_fraction != 1.0)
			pre_pos = trace_endpos;
	}

	return pre_pos;
}

float turret_targetscore_support(entity _turret, entity _target)
{
	float s_score = (_turret.enemy == _target);
	float d_score = min(_turret.target_range_optimal, tvt_dist) / max(_turret.target_range_optimal, tvt_dist);

	// Total score
	float score = (d_score * _turret.target_select_rangebias)
	            + (s_score * _turret.target_select_samebias);
	return score;
}

/*
* Generic bias aware score system.
*/
float turret_targetscore_generic(entity _turret, entity _target)
{
	float d_dist;       // Defendmode Distance
	float score;        // Total score
	float d_score;      // Distance score
	float a_score;      // Angular score
	float m_score = 0;  // missile score
	float p_score = 0;  // player score
	float ikr;          // ideal kill range

	//if (_turret.tur_defend)
	//{
	//	d_dist = vlen(real_origin(_target) - _turret.tur_defend.origin);
	//	ikr = vlen(_turret.origin - _turret.tur_defend.origin);
	//	d_score = 1 - d_dist / _turret.target_range;
	//}
	//else
	//{
		// Make a normlized value base on the targets distance from our optimal killzone
		ikr = _turret.target_range_optimal;
		d_score = min(ikr, tvt_dist) / max(ikr, tvt_dist);
	//}

	a_score = 1 - tvt_thadf / _turret.aim_maxrot;

	if (_turret.target_select_missilebias > 0 && (_target.flags & FL_PROJECTILE))
		m_score = 1;

	if (_turret.target_select_playerbias > 0 && IS_PLAYER(_target))
		p_score = 1;

	d_score = max(d_score, 0);
	a_score = max(a_score, 0);
	m_score = max(m_score, 0);
	p_score = max(p_score, 0);

	score = (d_score * _turret.target_select_rangebias)
	      + (a_score * _turret.target_select_anglebias)
	      + (m_score * _turret.target_select_missilebias)
	      + (p_score * _turret.target_select_playerbias);

	if (vdist(_turret.tur_shotorg - real_origin(_target), >, _turret.target_range))
	{
		//dprint("Wtf?\n");
		score *= 0.001;
	}

	return score;
}

// Generic damage handling
void turret_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.deadflag          = DEAD_DEAD;
	this.tur_head.deadflag = this.deadflag;

	// Unsolidify and hide real parts
	this.solid          = SOLID_NOT;
	this.tur_head.solid = this.solid;

	this.th_pain = func_null;
	this.th_die = func_null;
	this.takedamage   = DAMAGE_NO;

	this.health = 0;

	// Go boom
	//RadiusDamage(this, this, min(this.ammo, 50), min(this.ammo, 50) * 0.25, 250, NULL, min(this.ammo, 50) * 5, DEATH_TURRET, NULL);

	Turret tur = this.turretdef;
	// do a simple explosion effect here, since CSQC can't do it on a to-be-removed entity
	sound(this, CH_SHOTS, SND_ROCKET_EXPLOSION, VOL_BASE, ATTEN_NORM);
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	if(IS_REAL_CLIENT(this.realowner))
	{
		// an easter egg
		string theirname = (tur == TUR_JUMPING_CASTLE) ? "^3J^1u^5m^3p^1i^5n^3g ^5C^3a^1s^5t^3l^1e" : tur.m_name;
		//string theirname = tur.m_name;
		Send_Notification(NOTIF_ONE_ONLY, this.realowner, MSG_CENTER, CENTER_TURRET_DESTROYED_SELF, theirname);
		Send_Notification(NOTIF_ALL_EXCEPT, this.realowner, MSG_CENTER, CENTER_TURRET_DESTROYED, theirname);
	}

	if(td_ent)
	{
		td_ent.tur_units -= this.tur_units;
		td_ent.SendFlags |= SF_TD_ENT_COUNTS;
	}

	tur.tr_death(tur, this);

	delete(this.tur_head);
	delete(this);
}

void turret_damage(entity this, entity attacker, float damage, int deathtype)
{
	// Enough already!
	if (this.deadflag == DEAD_DEAD)
		return;

	// thorw head slightly off aim when hit?
	if (this.damage_flags & TFL_DMG_HEADSHAKE)
	{
		this.tur_head.angles.x += (random() - 0.5) * damage;
		this.tur_head.angles.y += (random() - 0.5) * damage;

		this.SendFlags |= TNSF_ANG;
	}

	this.SendFlags |= TNSF_STATUS;
}

void turret_think(entity this);
void turret_respawn(entity this)
{
	this.effects            &= ~EF_NODRAW;
	this.deadflag            = DEAD_NO;
	this.effects             = EF_LOWPRECISION;
	this.solid               = SOLID_BBOX;
	this.takedamage          = DAMAGE_AIM;
	this.th_pain             = turret_damage;
	this.th_die              = turret_die;
	this.avelocity           = '0 0 0';
	this.tur_head.avelocity  = this.avelocity;
	this.tur_head.angles     = this.idle_aim;
	this.health              = this.max_health;
	this.enemy               = NULL;
	this.oldorigin           = this.origin;
	this.volly_counter       = this.shot_volly;

	this.nextthink = time;
	setthink(this, turret_think);

	this.SendFlags = TNSF_FULL_UPDATE;

	Turret tur = this.turretdef;
	tur.tr_setup(tur, this);

	setorigin(this, this.origin); // make sure it's linked to the area grid
}


// Main functions
.float clientframe;
void turrets_setframe_force(entity this, int _frame, bool client_only, bool forced)
{
	if ((client_only ? this.clientframe : this.frame) != _frame || forced)
	{
		this.SendFlags |= TNSF_ANIM;
		this.anim_start_time = time;
	}

	if (client_only)
		this.clientframe = _frame;
	else
		this.frame = _frame;
}

void turrets_setframe(entity this, int _frame, bool client_only)
{
	turrets_setframe_force(this, _frame, client_only, false);
}

void turrets_headframe_force(entity this, int _frame, bool client_only, bool forced)
{
	if ((client_only ? this.tur_head.clientframe : this.tur_head.frame) != _frame || forced)
	{
		this.SendFlags |= TNSF_HEADANIM;
		this.tur_head.anim_start_time = time;
	}

	if (client_only)
		this.tur_head.clientframe = _frame;
	else
		this.tur_head.frame = _frame;
}

void turrets_headframe(entity this, int _frame, bool client_only)
{
	turrets_headframe_force(this, _frame, client_only, false);
}

bool turret_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TURRET);
	WriteByte(MSG_ENTITY, sf);
	if (sf & TNSF_SETUP)
	{
		WriteRegistered(Turrets, MSG_ENTITY, this.turretdef);
		WriteByte(MSG_ENTITY, this.clipgroup);
		WriteByte(MSG_ENTITY, this.tur_units);

		WriteVector(MSG_ENTITY, this.origin);

		WriteAngleVector2D(MSG_ENTITY, this.angles);
	}

	if (sf & TNSF_ANG)
	{
		WriteShort(MSG_ENTITY, rint(this.tur_head.angles.x));
		WriteShort(MSG_ENTITY, rint(this.tur_head.angles.y));
	}

	if (sf & TNSF_AVEL)
	{
		WriteShort(MSG_ENTITY, rint(this.tur_head.avelocity.x));
		WriteShort(MSG_ENTITY, rint(this.tur_head.avelocity.y));
	}

	if (sf & TNSF_MOVE)
	{
		WriteVector(MSG_ENTITY, this.origin);
		WriteVector(MSG_ENTITY, this.velocity);
		WriteShort(MSG_ENTITY, rint(this.angles.y));
	}

	if (sf & TNSF_ANIM)
	{
		WriteCoord(MSG_ENTITY, this.anim_start_time);
		WriteByte(MSG_ENTITY, this.frame);
	}

	if (sf & TNSF_STATUS)
	{
		//WriteFloat(MSG_ENTITY, max(0, this.health));
		if (this.health <= 0)
			WriteByte(MSG_ENTITY, 0);
		else
			WriteByte(MSG_ENTITY, ceil((this.health / this.max_health) * 255));
	}

	if (sf & TNSF_LEVEL)
	{
		WriteByte(MSG_ENTITY, this.tur_level);
	}

	if (sf & TNSF_HEADANIM)
	{
		WriteCoord(MSG_ENTITY, this.tur_head.anim_start_time);
		WriteByte(MSG_ENTITY, this.tur_head.frame);
	}

	return true;
}

// NOTE: expects .turretdef to be set
void load_unit_settings(entity ent, bool is_reload)
{
	if (!ent)
		return;

	Turret tur = ent.turretdef;

	if (is_reload)
	{
		ent.enemy = NULL;
		ent.tur_head.avelocity = '0 0 0';

		ent.tur_head.angles = '0 0 0';
	}

	//string unitname = ent.netname;
	#define X(class, prefix, fld, type) ent.fld = tur.fld;
	TR_PROPS_COMMON(X, , )
	#undef X

	if (is_reload)
	{
		Turret tur = ent.turretdef;
		tur.tr_setup(tur, ent);
	}
}

/**
** updates enemy distances, predicted impact point/time
** and updated aim<->predict impact distance.
**/
void turret_do_updates(entity t_turret)
{
	vector enemy_pos = real_origin(t_turret.enemy);

	turret_tag_fire_update(t_turret);

	t_turret.tur_shotdir_updated = v_forward;
	t_turret.tur_dist_enemy  = vlen(t_turret.tur_shotorg - enemy_pos);
	t_turret.tur_dist_aimpos = vlen(t_turret.tur_shotorg - t_turret.tur_aimpos);

	/*if ((t_turret.firecheck_flags & TFL_FIRECHECK_VERIFIED) && t_turret.enemy)
	{
		oldpos = t_turret.enemy.origin;
		setorigin(t_turret.enemy, t_turret.tur_aimpos);
		tracebox(t_turret.tur_shotorg, '-1 -1 -1', '1 1 1', t_turret.tur_shotorg + t_turret.tur_shotdir_updated * t_turret.tur_dist_aimpos, MOVE_NORMAL, t_turret);
		setorigin(t_turret.enemy, oldpos);

		if (trace_ent == t_turret.enemy)
			t_turret.tur_dist_impact_to_aimpos = 0;
		else
			t_turret.tur_dist_impact_to_aimpos = vlen(trace_endpos - t_turret.tur_aimpos);
	}
	else*/
		tracebox(t_turret.tur_shotorg, '-1 -1 -1', '1 1 1', t_turret.tur_shotorg + t_turret.tur_shotdir_updated * t_turret.tur_dist_aimpos, MOVE_NORMAL, t_turret);

	t_turret.tur_dist_impact_to_aimpos = vlen(trace_endpos - t_turret.tur_aimpos) - 0.5 * vlen(t_turret.enemy.maxs - t_turret.enemy.mins);
	t_turret.tur_impactent  = trace_ent;
	t_turret.tur_impacttime = vlen(t_turret.tur_shotorg - trace_endpos) / t_turret.shot_speed;
}

/// Handles head rotation according to the units .track_type and .track_flags
.float turret_framecounter;
void turret_track(entity this)
{
	vector target_angle; // This is where we want to aim
	vector move_angle;   // This is where we can aim
	float f_tmp;
	vector v1, v2;
	v1 = this.tur_head.angles;
	v2 = this.tur_head.avelocity;

	if (this.track_flags == TFL_TRACK_NO)
		return;

	if (!this.active)
		target_angle = this.idle_aim - ('1 0 0' * this.aim_maxpitch);
	else if (!this.enemy)
	{
		if (time > this.lip)
			target_angle = this.idle_aim + this.angles;
		else
			target_angle = vectoangles(normalize(this.tur_aimpos - this.tur_shotorg));
	}
	else
	{
		target_angle = vectoangles(normalize(this.tur_aimpos - this.tur_shotorg));
	}

	this.tur_head.angles.x = anglemods(this.tur_head.angles.x);
	this.tur_head.angles.y = anglemods(this.tur_head.angles.y);

	// Find the diffrence between where we currently aim and where we want to aim
	//move_angle = target_angle - (this.angles + this.tur_head.angles);
	//move_angle = shortangle_vxy(move_angle, this.angles + this.tur_head.angles);

	move_angle = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(this.angles), AnglesTransform_FromAngles(target_angle))) - this.tur_head.angles;
	move_angle = shortangle_vxy(move_angle, this.tur_head.angles);

	switch (this.track_type)
	{
		case TFL_TRACKTYPE_STEPMOTOR:
			f_tmp = this.aim_speed * frametime;
			if (this.track_flags & TFL_TRACK_PITCH)
			{
				this.tur_head.angles.x += bound(-f_tmp, move_angle.x, f_tmp);
				if (this.tur_head.angles.x > this.aim_maxpitch)
					this.tur_head.angles.x = this.aim_maxpitch;

				if (this.tur_head.angles.x  < -this.aim_maxpitch)
					this.tur_head.angles.x = this.aim_maxpitch;
			}

			if (this.track_flags & TFL_TRACK_ROTATE)
			{
				this.tur_head.angles.y += bound(-f_tmp, move_angle.y, f_tmp);
				if (this.tur_head.angles.y > this.aim_maxrot)
					this.tur_head.angles.y = this.aim_maxrot;

				if (this.tur_head.angles.y < -this.aim_maxrot)
					this.tur_head.angles.y = this.aim_maxrot;
			}

			// CSQC
			this.SendFlags |= TNSF_ANG;
			return;

		case TFL_TRACKTYPE_FLUIDINERTIA:
			f_tmp = this.aim_speed * frametime;
			move_angle.x = bound(-this.aim_speed, move_angle.x * this.track_accel_pitch * f_tmp, this.aim_speed);
			move_angle.y = bound(-this.aim_speed, move_angle.y * this.track_accel_rot   * f_tmp, this.aim_speed);
			move_angle = this.tur_head.avelocity * this.track_blendrate + move_angle * (1 - this.track_blendrate);
			break;

		case TFL_TRACKTYPE_FLUIDPRECISE:
			move_angle.y = bound(-this.aim_speed, move_angle.y, this.aim_speed);
			move_angle.x = bound(-this.aim_speed, move_angle.x, this.aim_speed);
			break;
	}

	//  pitch
	if (this.track_flags & TFL_TRACK_PITCH)
	{
		this.tur_head.avelocity.x = move_angle.x;
		if (this.tur_head.angles.x + this.tur_head.avelocity.x * frametime > this.aim_maxpitch)
		{
			this.tur_head.avelocity.x = 0;
			this.tur_head.angles.x = this.aim_maxpitch;

			this.SendFlags |= TNSF_ANG;
		}

		if (this.tur_head.angles.x + this.tur_head.avelocity.x * frametime < -this.aim_maxpitch)
		{
			this.tur_head.avelocity.x = 0;
			this.tur_head.angles.x = -this.aim_maxpitch;

			this.SendFlags |= TNSF_ANG;
		}
	}

	//  rot
	if (this.track_flags & TFL_TRACK_ROTATE)
	{
		this.tur_head.avelocity.y = move_angle.y;

		if (this.tur_head.angles.y + this.tur_head.avelocity.y * frametime > this.aim_maxrot)
		{
			this.tur_head.avelocity.y = 0;
			this.tur_head.angles.y = this.aim_maxrot;

			this.SendFlags |= TNSF_ANG;
		}

		if (this.tur_head.angles.y + this.tur_head.avelocity.y * frametime < -this.aim_maxrot)
		{
			this.tur_head.avelocity.y = 0;
			this.tur_head.angles.y = -this.aim_maxrot;

			this.SendFlags |= TNSF_ANG;
		}
	}

	this.SendFlags |= TNSF_AVEL;

	// Force a angle update every 10'th frame
	++this.turret_framecounter;
	if (this.turret_framecounter >= 10)
	{
		this.SendFlags |= TNSF_ANG;
		this.turret_framecounter = 0;
	}
}

/*
 + TFL_TARGETSELECT_NO
 + TFL_TARGETSELECT_LOS
 + TFL_TARGETSELECT_PLAYERS
 + TFL_TARGETSELECT_MISSILES
 + TFL_TARGETSELECT_MONSTERS
 - TFL_TARGETSELECT_TRIGGERTARGET
 + TFL_TARGETSELECT_ANGLELIMITS
 + TFL_TARGETSELECT_RANGELIMITS
 //+ TFL_TARGETSELECT_TEAMCHECK
 - TFL_TARGETSELECT_NOBUILTIN
 //+ TFL_TARGETSELECT_OWNTEAM
*/

/**
** Evaluate a entity for target valitity based on validate_flags
** NOTE: the caller must check takedamage before calling this, to inline this check.
**/
float turret_validate_target(entity e_turret, entity e_target, float validate_flags)
{
	//if (!validate_flags & TFL_TARGETSELECT_NOBUILTIN)
	//	return -0.5;

	if (!e_target)
		return -2;

	if (e_target.owner == e_turret || e_target == e_turret.realowner) // Don't attack against owner
		return -0.5;

	if (!checkpvs(e_target.origin, e_turret))
		return -1;
	if (e_target.alpha != 0 && e_target.alpha <= 0.3)
		return -1;

	if (validate_flags & TFL_TARGETSELECT_NO)
		return -4;

	if (e_target.flags & FL_NOTARGET) // If only this was used more..
		return -5;

	if (e_target.health <= 0 || e_target.exptime != 0) // Cant touch this
		return -6;

	if(time < e_target.invincible_finished)
		return -6;

	// monster
	if (!IS_MONSTER(e_target)
	&& (validate_flags & TFL_TARGETSELECT_MONSTERS))
		return -7;

	if (IS_PLAYER(e_target)) // player
	{
		if (!(validate_flags & TFL_TARGETSELECT_PLAYERS))
			return -7;
		if (e_target.health <= 0)
			return -8;
	}

	// enemy turrets
	if ((validate_flags & TFL_TARGETSELECT_NOTURRETS)
	&& e_target.owner.tur_head == e_target) // Dont break support units.
		return -9;

	// Missile
	if ((e_target.flags & FL_PROJECTILE)
	&& !(validate_flags & TFL_TARGETSELECT_MISSILES))
		return -10;

	if ((validate_flags & TFL_TARGETSELECT_MISSILESONLY)
	&& !(e_target.flags & FL_PROJECTILE))
		return -10.5;

#if 0
	// Team check
	// TODO: no real teams in quake, just check clipgroups
	if (validate_flags & TFL_TARGETSELECT_TEAMCHECK)
	{
		if (validate_flags & TFL_TARGETSELECT_OWNTEAM)
		{
			if (!e_target.turretdef)
				return -11;
			if (!e_target.owner.turretdef)
				return -12;
		}
		else
		{
			if (e_target.turretdef)
				return -13;
			if (e_target.owner.turretdef)
				return -14;
		}
	}
#endif

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
	tvt_thadv = angleofs3(e_turret.tur_head.origin, e_turret.angles + e_turret.tur_head.angles, e_target.origin);
	tvt_tadv = shortangle_vxy(angleofs(e_turret, e_target), e_turret.angles);
	tvt_thadf = vlen(tvt_thadv);

	/*
	if ((validate_flags & TFL_TARGETSELECT_FOV)
	&& e_turret.target_select_fov < tvt_thadf)
		return -21;
	*/

	if (validate_flags & TFL_TARGETSELECT_ANGLELIMITS)
	{
		if (fabs(tvt_tadv.x) > e_turret.aim_maxpitch)
			return -17;
		if (fabs(tvt_tadv.y) > e_turret.aim_maxrot)
			return -18;
	}

	// Line of sight?
	if (validate_flags & TFL_TARGETSELECT_LOS)
	{
		vector myorg = e_turret.origin + ('0 0 0.8' * e_turret.maxs_z);
		vector v_tmp = NearestPointOnBoundingBox(real_origin(e_target) + e_target.mins, real_origin(e_target) + e_target.maxs, myorg);

		traceline(myorg, v_tmp, 0, e_turret);
		if (vdist(v_tmp - trace_endpos, >, e_turret.aim_firetolerance_dist))
			return -19;
	}

	if (e_target.classname == "grapplinghook" || e_target.classname == "hook")
		return -20;

	return 1;
}

entity turret_select_target(entity this)
{
	entity e;        // target looper entity
	float  score;    // target looper entity score
	entity e_enemy;  // currently best scoreing target
	float  m_score;  // currently best scoreing target's score

	m_score = 0;
	if (this.enemy && this.enemy.takedamage && turret_validate_target(this, this.enemy, this.target_validate_flags) > 0)
	{
		e_enemy = this.enemy;
		m_score = this.turret_score_target(this, e_enemy) * this.target_select_samebias;
	}
	else
		e_enemy = this.enemy = NULL;

	e = findradius(this.origin, this.target_range);

	// Nothing to aim at?
	if (!e)
		return NULL;

	float f;
	for (; e; e = e.chain)
		if (e.takedamage)
		{
			f = turret_validate_target(this, e, this.target_select_flags);
			//dprint("F is: ", ftos(f), "\n");
			if (f > 0)
			{
				score = this.turret_score_target(this, e);
				if (score > m_score && score > 0)
				{
					e_enemy = e;
					m_score = score;
				}
			}
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
 //+ TFL_FIRECHECK_AMMO_OWN
 //+ TFL_FIRECHECK_AMMO_OTHER
 + TFL_FIRECHECK_REFIRE
*/

/**
** Preforms pre-fire checks based on the uints firecheck_flags
**/
bool turret_firecheck(entity this)
{
	// This one just dont care =)
	if (this.firecheck_flags & TFL_FIRECHECK_NO)
		return true;

	if (!this.enemy)
		return false;

	// Ready?
	if ((this.firecheck_flags & TFL_FIRECHECK_REFIRE)
	&& this.attack_finished > time)
		return false;

	// Special case: volly fire turret that has to fire a full volly if a shot was fired.
	if ((this.shoot_flags & TFL_SHOOT_VOLLYALWAYS)
	&& this.volly_counter != this.shot_volly)
		return true;

	// Lack of zombies makes shooting dead things unnecessary :P
	if ((this.firecheck_flags & TFL_FIRECHECK_DEAD)
	&& (this.enemy.health < 1 || this.enemy.exptime != 0))
		return false;

	// Target of opertunity?
	if (turret_validate_target(this, this.tur_impactent, this.target_validate_flags) > 0)
	{
		this.enemy = this.tur_impactent;
		return true;
	}

	if (this.firecheck_flags & TFL_FIRECHECK_DISTANCES)
	{
		// To close?
		if (this.tur_dist_aimpos < this.target_range_min)
		{
			if (turret_validate_target(this, this.tur_impactent, this.target_validate_flags) > 0)
				return true; // Target of opertunity?
			return false;
		}
	}

	// Try to avoid FF?
	if ((this.firecheck_flags & TFL_FIRECHECK_AFF)
	&& this.tur_impactent.turretdef)
		return false;

	// aim<->predicted impact
	if ((this.firecheck_flags & TFL_FIRECHECK_AIMDIST)
	&& this.tur_dist_impact_to_aimpos > this.aim_firetolerance_dist)
		return false;

	// Volly status
	if (this.shot_volly > 1
	&&  this.volly_counter == this.shot_volly)
		return false;

	/*
	if ((this.firecheck_flags & TFL_FIRECHECK_VERIFIED)
	&& this.tur_impactent != this.enemy)
		return false;
	*/

	return true;
}

bool turret_checkfire(entity this)
{
	return (this.turret_firecheckfunc) ? this.turret_firecheckfunc(this) : false;
}

void turret_fire(entity this)
{
	Turret info = this.turretdef;
	info.tr_attack(info, this);

	this.attack_finished = time + this.shot_refire;
	this.volly_counter -= 1;

	if (this.volly_counter <= 0)
	{
		this.volly_counter = this.shot_volly;

		if (this.shoot_flags & TFL_SHOOT_CLEARTARGET)
			this.enemy = NULL;

		if (this.shot_volly > 1)
			this.attack_finished = time + this.shot_volly_refire;
	}
}

void turret_think(entity this)
{
	this.nextthink = time;

	if (this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.SendFlags |= TNSF_MOVE;
	}

	if(this.tur_head && time >= this.tur_head.animstate_endtime)
	{
		int oldframe = this.tur_head.frame;
		setanim(this.tur_head, this.tur_head.anim_idle, true, false, false);
		if(this.tur_head.frame != oldframe)
		{
			this.tur_head.anim_start_time = this.tur_head.animstate_starttime;
			this.SendFlags |= TNSF_HEADANIM;
		}
	}

	// fake friction so we don't slide everywhere
	if (!(this.turret_flags & TUR_FLAG_MOVE) && vdist(this.velocity, >, 0))
	{
		float mspeed = max(0, vlen(this.velocity) - 20);
		vector mdir = normalize(this.velocity);
		float vz = this.velocity.z;
		this.velocity = mdir * mspeed;
		this.velocity_z = vz;
	}

	// This is typicaly used for zaping every target in range
	// turret_fusionreactor uses this to recharge friendlys.
	if (this.shoot_flags & TFL_SHOOT_HITALLVALID)
	{
		// Do a this.turret_fire for every valid target.
		for (entity e = findradius(this.origin, this.target_range); e; e = e.chain)
			if (e.takedamage)
			{
				if (turret_validate_target(this, e, this.target_validate_flags) > 0)
				{
					this.enemy = e;

					turret_do_updates(this);

					if (turret_checkfire(this))
						turret_fire(this);
				}
			}

		this.enemy = NULL;
	}
	else if (this.shoot_flags & TFL_SHOOT_CUSTOM)
	{
		// This one is doing something.. oddball. assume its handles what needs to be handled.

		if (!(this.aim_flags & TFL_AIM_NO)) // Predict?
			this.tur_aimpos = turret_aim_generic(this);

		if (!(this.track_flags & TFL_TRACK_NO)) // Turn & pitch?
			turret_track(this);

		turret_do_updates(this);

		if (turret_checkfire(this)) // Fire?
			turret_fire(this);
	}
	else
	{
		// Special case for volly always. if it fired once it must compleate the volly.
		if ((this.shoot_flags & TFL_SHOOT_VOLLYALWAYS)
		&& this.volly_counter != this.shot_volly)
		{
			// Predict or whatnot
			if (!(this.aim_flags & TFL_AIM_NO))
				this.tur_aimpos = turret_aim_generic(this);

			// Turn & pitch
			if (!(this.track_flags & TFL_TRACK_NO))
				turret_track(this);

			turret_do_updates(this);

			// Fire!
			if (turret_checkfire(this))
				turret_fire(this);

			Turret tur = this.turretdef;
			tur.tr_think(tur, this);

			return;
		}

		// Check if we have a vailid enemy, and try to find one if we dont.

		// g_turrets_targetscan_maxdelay forces a target re-scan at least this often
		bool do_target_scan = false;
		if (this.target_select_time + 1 < time) //autocvar_g_turrets_targetscan_maxdelay
			do_target_scan = true;

		// Old target (if any) invalid?
		if (this.target_validate_time < time
		&& turret_validate_target(this, this.enemy, this.target_validate_flags) <= 0)
		{
			this.enemy = NULL;
			this.target_validate_time = time + 0.5;
			do_target_scan = true;
		}

		// But never more often then g_turrets_targetscan_mindelay!
		if (this.target_select_time + 0.1 > time) //autocvar_g_turrets_targetscan_mindelay
			do_target_scan = false;

		if (do_target_scan)
		{
			this.enemy = turret_select_target(this);
			this.target_select_time = time;
		}

		// No target, just go to idle, do any custom stuff and bail.
		if (!this.enemy)
		{
			// Turn & pitch
			if (!(this.track_flags & TFL_TRACK_NO))
				turret_track(this);

			Turret tur = this.turretdef;
			tur.tr_think(tur, this);

			// And bail.
			return;
		}
		else
			this.lip = time + 5; // Keep track of the last time we had a target. //g_turrets_aimidle_delay

		// Predict?
		if (!(this.aim_flags & TFL_AIM_NO))
			this.tur_aimpos = turret_aim_generic(this);

		// Turn & pitch?
		if (!(this.track_flags & TFL_TRACK_NO))
			turret_track(this);

		turret_do_updates(this);

		// Fire?
		if (turret_checkfire(this))
			turret_fire(this);
	}

	Turret tur = this.turretdef;
	tur.tr_think(tur, this);
}

void turret_link(entity this)
{
	Net_LinkEntity(this, true, 0, turret_send);
	setthink(this, turret_think);
	this.nextthink = time;
	this.tur_head.effects = EF_NODRAW;
}

void turret_initparams(entity tur)
{
	#define TRY(x) (x) ? (x)
	tur.shot_refire                 = bound(0.01,            (TRY(tur.shot_refire)               :  1                                          ), 9999);
	tur.shot_dmg                    = max  (1,               (TRY(tur.shot_dmg)                  :  tur.shot_refire * 50                       ));
	tur.shot_radius                 = max  (1,               (TRY(tur.shot_radius)               :  tur.shot_dmg * 0.5                         ));
	tur.shot_speed                  = max  (1,               (TRY(tur.shot_speed)                :  2500                                       ));
	tur.shot_spread                 = bound(0.0001,          (TRY(tur.shot_spread)               :  0.0125                                     ), 500);
	tur.shot_force                  = bound(0.001,           (TRY(tur.shot_force)                :  tur.shot_dmg * 0.5 + tur.shot_radius * 0.5 ), 5000);
	tur.shot_volly                  = bound(1,               (TRY(tur.shot_volly)                :  1                                          ), 20);
	tur.shot_volly_refire           = bound(tur.shot_refire, (TRY(tur.shot_volly_refire)         :  tur.shot_refire * tur.shot_volly           ), 60);
	tur.target_range                = bound(0,               (TRY(tur.target_range)              :  tur.shot_speed * 0.5                       ), 65535);
	tur.target_range_min            = bound(0,               (TRY(tur.target_range_min)          :  tur.shot_radius * 2                        ), 65535);
	tur.target_range_optimal        = bound(0,               (TRY(tur.target_range_optimal)      :  tur.target_range * 0.5                     ), 65535);
	tur.aim_maxrot                  = bound(0,               (TRY(tur.aim_maxrot)                :  90                                         ), 360);
	tur.aim_maxpitch                = bound(0,               (TRY(tur.aim_maxpitch)              :  20                                         ), 90);
	tur.aim_speed                   = bound(0.1,             (TRY(tur.aim_speed)                 :  36                                         ), 1000);
	tur.aim_firetolerance_dist      = bound(0.1,             (TRY(tur.aim_firetolerance_dist)    :  5 + (tur.shot_radius * 2)                  ), 65535);
	tur.target_select_rangebias     = bound(-10,             (TRY(tur.target_select_rangebias)   :  1                                          ), 10);
	tur.target_select_samebias      = bound(-10,             (TRY(tur.target_select_samebias)    :  1                                          ), 10);
	tur.target_select_anglebias     = bound(-10,             (TRY(tur.target_select_anglebias)   :  1                                          ), 10);
	tur.target_select_missilebias   = bound(-10,             (TRY(tur.target_select_missilebias) :  1                                          ), 10);
	tur.target_select_playerbias    = bound(-10,             (TRY(tur.target_select_playerbias)  :  1                                          ), 10);
	//tur.ammo_max                    = max  (tur.shot_dmg,    (TRY(tur.ammo_max)                  :  tur.shot_dmg * 10                          ));
	//tur.ammo_recharge               = max  (0,               (TRY(tur.ammo_recharge)             :  tur.shot_dmg * 0.5                         ));
	#undef TRY
}

bool turret_closetotarget(entity this, vector targ, float range)
{
	vector path_extra_size = '1 1 1' * range;
	return boxesoverlap(targ - path_extra_size, targ + path_extra_size, this.absmin - path_extra_size, this.absmax + path_extra_size);
}

bool turret_initialize(entity this, Turret tur)
{
	if (tur.m_id == 0)
		return false; // invalid turret

	// if tur_head exists, we can assume this turret re-spawned
	if (!this.tur_head)
	{
		tur.tr_precache(tur);
		precache_model(tur.mdl);
		precache_model(tur.head_model);
		IL_PUSH(g_turrets, this);
	}

	this.netname = tur.netname;
	this.turretdef = tur;
	load_unit_settings(this, false);

	if (!this.health)                    this.health = 1000;
	if (!this.shot_refire)               this.shot_refire = 1;
	if (this.tur_shotorg == '0 0 0')     this.tur_shotorg = '50 0 50';
	if (!this.turret_flags)              this.turret_flags = TUR_FLAG_SPLASH | TUR_FLAG_MEDPROJ;
	if (!this.damage_flags)              this.damage_flags = TFL_DMG_YES | TFL_DMG_RETALIATE | TFL_DMG_AIMSHAKE;
	if (!this.aim_flags)                 this.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
	if (!this.track_type)                this.track_type = TFL_TRACKTYPE_STEPMOTOR;
	if (!this.track_flags)               this.track_flags = TFL_TRACK_PITCH | TFL_TRACK_ROTATE;
	//if (!this.ammo_flags)                this.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE;
	if (!this.target_select_flags)       this.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_ANGLELIMITS;
	if (!this.firecheck_flags)           this.firecheck_flags = TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_LOS
	                                                          | TFL_FIRECHECK_AIMDIST | TFL_FIRECHECK_REFIRE;

	if (this.track_type != TFL_TRACKTYPE_STEPMOTOR)
	{
		// Fluid / Ineria mode. Looks mutch nicer.
		// Can reduce aim preformance alot, needs a bit diffrent aimspeed

		this.aim_speed = bound(0.1, (!this.aim_speed ? 180 : this.aim_speed), 1000);

		if (!this.track_accel_pitch)
			this.track_accel_pitch = 0.5;
		if (!this.track_accel_rot)
			this.track_accel_rot = 0.5;
		if (!this.track_blendrate)
			this.track_blendrate = 0.35;
	}

	turret_initparams(this);

	this.turret_flags = TUR_FLAG_ISTURRET | (tur.spawnflags);

	if (this.turret_flags & TUR_FLAG_SPLASH)
		this.aim_flags |= TFL_AIM_SPLASH;

	if (this.turret_flags & TUR_FLAG_MISSILE)
		this.target_select_flags |= TFL_TARGETSELECT_MISSILES;

	if (this.turret_flags & TUR_FLAG_PLAYER)
		this.target_select_flags |= TFL_TARGETSELECT_PLAYERS;

	if (this.turret_flags & TUR_FLAG_SUPPORT)
		this.turret_score_target = turret_targetscore_support;
	else
		this.turret_score_target = turret_targetscore_generic;

	_setmodel(this, tur.mdl);
	setsize(this, tur.m_mins, tur.m_maxs);

	this.active                 = ACTIVE_ACTIVE;
	this.effects                = EF_NODRAW;
	this.netname                = tur.m_name;
	this.max_health             = this.health;
	this.target_validate_flags  = this.target_select_flags;
	this.solid                  = SOLID_BBOX;
	this.takedamage             = DAMAGE_AIM;
	if(tur.spawnflags & TUR_FLAG_FLOATING)
		set_movetype(this, MOVETYPE_FLY);
	else
		set_movetype(this, MOVETYPE_TOSS); // was noclip
	this.view_ofs               = '0 0 0';
	this.idle_aim               = '0 0 0';
	this.turret_firecheckfunc   = turret_firecheck;
	this.th_pain                = turret_damage;
	this.th_die                 = turret_die;
	this.monster_attack         = true;
	this.nextthink              = time + 1;

	this.tur_head = new(turret_head);
	_setmodel(this.tur_head, tur.head_model);
	setsize(this.tur_head, '0 0 0', '0 0 0');
	setorigin(this.tur_head, '0 0 0');
	if(gettagindex(this, "tag_head"))
		setattachment(this.tur_head, this, "tag_head");
	else
		setattachment(this.tur_head, this, "");

	this.tur_head.netname     = this.tur_head.classname;
	this.tur_head.owner       = this;
	this.tur_head.takedamage  = DAMAGE_NO;
	this.tur_head.solid       = SOLID_NOT;
	set_movetype(this.tur_head, MOVETYPE_NOCLIP); // no collisions anyway, lets spinning work

	if(!(tur.spawnflags & TUR_FLAG_FLOATING))
		DropToFloor_QC_DelayedInit(this);

	turret_link(this);
	turret_respawn(this);
	turret_tag_fire_update(this);

	tur.tr_setup(tur, this);

	return true;
}
#endif // SVQC
