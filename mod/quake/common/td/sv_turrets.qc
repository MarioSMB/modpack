#include "sv_turrets.qh"

#ifdef SVQC

bool turret_infront(entity this, entity targ, vector sangle, float maxpitch, float maxrot)
{
	vector org = this.origin + this.view_ofs;
	vector targ_org = (targ.absmin + targ.absmax) * 0.5;
	vector tvt_tadv = shortangle_vxy(angleofs3(org, sangle, targ_org), sangle);
	if(maxpitch > 0 && fabs(tvt_tadv.x) > maxpitch)
		return false;
	if(maxrot > 0 && fabs(tvt_tadv.y) > maxrot)
		return false;
	return true;
}

entity turret_findtarget_ignore(entity this, float maxpitch, float maxrot, float trange, entity ignore)
{
	entity best = NULL;
	float bestdist = 0;
	vector org = this.origin + this.view_ofs;
	FOREACH_ENTITY_RADIUS(org, trange, it.takedamage && IS_MONSTER(it) && !it.charmed && it != ignore,
	{
		if(it.health < 1 || it.exptime != 0)
			continue;
		if(time < it.invincible_finished)
			continue;
		if(!turret_infront(this, it, this.angles, maxpitch, maxrot))
			continue;
		if(!checkpvs(org, it))
			continue;
		vector targ_org = (it.absmin + it.absmax) * 0.5;
		float newdist = vlen2(targ_org - org);
		if(!best || newdist <= bestdist)
		{
			bestdist = newdist;
			best = it;
		}
	});
	return best;
}

entity turret_findtarget(entity this, float maxpitch, float maxrot, float trange)
{
	return turret_findtarget_ignore(this, maxpitch, maxrot, trange, NULL);
}

void turret_levelup(entity this)
{
	this.tur_level = min(this.tur_level + 1, 5); // TODO: safety check?
	float mypower = turret_getpower(this.tur_level, 0.2);
	this.max_health *= mypower;
	this.health = this.max_health;
	// TODO: per-turret update function?
	this.SendFlags |= TNSF_STATUS;
	this.SendFlags |= TNSF_LEVEL;
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
	this.health              = this.max_health;
	this.enemy               = NULL;
	this.oldorigin           = this.origin;

	this.nextthink = time;
	setthink(this, turret_think);

	this.SendFlags = TNSF_FULL_UPDATE;

	Turret tur = this.turretdef;
	tur.tr_setup(tur, this);

	setorigin(this, this.origin); // make sure it's linked to the area grid
}


// Main functions

bool turret_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TURRET);
	WriteByte(MSG_ENTITY, sf);
	if (sf & TNSF_SETUP)
	{
		WriteRegistered(Turrets, MSG_ENTITY, this.turretdef);
		WriteFloat(MSG_ENTITY, this.max_health);
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
		WriteByte(MSG_ENTITY, this.clientframe);
	}

	if (sf & TNSF_LEVEL)
	{
		WriteByte(MSG_ENTITY, this.tur_level);
		WriteFloat(MSG_ENTITY, this.max_health);
	}

	if (sf & TNSF_STATUS)
	{
		WriteFloat(MSG_ENTITY, max(0, this.health));
		//if (this.health <= 0)
			//WriteByte(MSG_ENTITY, 0);
		//else
			//WriteByte(MSG_ENTITY, ceil((this.health / this.max_health) * 255));
	}

	return true;
}

void turret_think(entity this)
{
	this.nextthink = time;

	if (this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.SendFlags |= TNSF_MOVE;
	}

	// done before the current frame so the client has a chance to update
	if(time >= this.attack_finished)
		this.clientframe = TANIM_IDLE;

	if (this.clientframe != this.walkframe)
	{
		this.walkframe = this.clientframe;
		this.SendFlags |= TNSF_ANIM;
	}

	// in quake, to keep things simple each turret will handle its firing mechanics

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
		IL_PUSH(g_turrets, this);
	}

	this.netname = tur.netname;

	//_setmodel(this, tur.mdl);
	setsize(this, tur.m_mins, tur.m_maxs);

	if(!this.health)
		this.health = tur.tur_health;

	this.turretdef              = tur;
	this.active                 = ACTIVE_ACTIVE;
	this.effects                = EF_NODRAW;
	this.netname                = tur.m_name;
	this.max_health             = this.health;
	this.solid                  = SOLID_BBOX;
	this.takedamage             = DAMAGE_AIM;
	if(tur.spawnflags & TUR_FLAG_FLOATING)
		set_movetype(this, MOVETYPE_FLY);
	else
		set_movetype(this, MOVETYPE_TOSS); // was noclip
	this.view_ofs               = '0 0 0';
	this.th_pain                = turret_damage;
	this.th_die                 = turret_die;
	this.monster_attack         = true;
	this.nextthink              = time + 1;

	this.tur_head = new(turret_head);
	//_setmodel(this.tur_head, tur.head_model);
	setsize(this.tur_head, '0 0 0', '0 0 0');
	setorigin(this.tur_head, '0 0 0');
	setattachment(this.tur_head, this, "");

	this.tur_head.netname     = this.tur_head.classname;
	this.tur_head.owner       = this;
	this.tur_head.takedamage  = DAMAGE_NO;
	this.tur_head.solid       = SOLID_NOT;
	set_movetype(this.tur_head, this.move_movetype);

	if(!(tur.spawnflags & TUR_FLAG_FLOATING))
		DropToFloor_QC_DelayedInit(this);

	turret_link(this);
	turret_respawn(this);

	tur.tr_setup(tur, this);

	return true;
}
#endif // SVQC
