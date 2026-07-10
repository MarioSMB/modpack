#include "duke.qh"

// =============
//  FLAK CANNON
// =============

#ifdef SVQC
void flakcannon_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = (this.dmg) ? this.dmg : 15;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.takedamage)
	{
		if(Resist_Explosions(toucher))
			damg *= 0.5;	// mostly immune
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	if(this.noise && this.noise != "")
		_sound(this, CH_WEAPON_SINGLE, this.noise, 1, ATTN_NORM);

	this.origin = this.origin - 8 * normalize(this.velocity);

	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	_setmodel(exp, "progs/s_explod.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	delete(this);
}

METHOD(DukeFlakCannon, tr_precache, void(DukeFlakCannon this))
{
	precache_sound("turrets/flakcannon_fire.wav");
	precache_sound("turrets/flakcannon_explode.wav");
}
METHOD(DukeFlakCannon, tr_attack, void(DukeFlakCannon this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/flakcannon_fire.wav", 1, ATTN_NORM);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 1200;
	newmis.noise = "turrets/flakcannon_explode.wav";
	settouch(newmis, flakcannon_touch);
	newmis.dmg = actor.shot_dmg;
	CSQCProjectile(newmis, true, PROJECTILE_FLAK_CANNON, true);
}
METHOD(DukeFlakCannon, tr_setup, void(DukeFlakCannon this, entity actor))
{
	actor.damage_flags |= TFL_DMG_HEADSHAKE;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(DukeFlakCannon, tr_drawselected, void(DukeFlakCannon this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ========
//  NAILER
// ========

#ifdef SVQC
METHOD(DukeTwinGun, tr_precache, void(DukeTwinGun this))
{
	precache_sound("weapons/spike2.wav");
}
METHOD(DukeTwinGun, tr_attack, void(DukeTwinGun this, entity actor))
{
	if(time >= actor.spamtime)
	{
		actor.spamtime = time + 0.1;
		_sound(actor, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 0.7, ATTN_NORM);
	}

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 1000;
	newmis.dmg = actor.shot_dmg;
	CSQCProjectile(newmis, true, PROJECTILE_BULLET, true);

	actor.tur_head.frame = (actor.tur_head.frame) ? 0 : 1;
}
METHOD(DukeTwinGun, tr_setup, void(DukeTwinGun this, entity actor))
{
	actor.damage_flags |= TFL_DMG_HEADSHAKE;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(DukeTwinGun, tr_drawselected, void(DukeTwinGun this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// =================
//  ROCKET LAUNCHER
// =================

#ifdef SVQC
METHOD(DukeRocketLauncher, tr_precache, void(DukeRocketLauncher this))
{
	precache_sound("turrets/rocketlauncher_fire.wav");
}
METHOD(DukeRocketLauncher, tr_attack, void(DukeRocketLauncher this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/rocketlauncher_fire.wav", 1, ATTN_NORM);

	//turret_tag_fire_update(actor);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 1000;
	settouch(newmis, T_MissileTouch);
	newmis.dmg = actor.shot_dmg;
	CSQCProjectile(newmis, true, PROJECTILE_MULTI_ROCKET, true);
}
METHOD(DukeRocketLauncher, tr_think, void(DukeRocketLauncher this, entity actor))
{
	// 0 = full, 8 = empty
	// zero indexed for frames
	actor.tur_head.frame = bound(0, 7 - (actor.volly_counter - 1), 7);
}
METHOD(DukeRocketLauncher, tr_setup, void(DukeRocketLauncher this, entity actor))
{
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;

	actor.damage_flags |= TFL_DMG_HEADSHAKE;
	actor.shoot_flags  |= TFL_SHOOT_VOLLYALWAYS;
	actor.volly_counter = actor.shot_volly;
}
#endif // SVQC
#ifdef CSQC
METHOD(DukeRocketLauncher, tr_drawselected, void(DukeRocketLauncher this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
