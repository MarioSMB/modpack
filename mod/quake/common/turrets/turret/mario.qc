#include "mario.qh"

// ==============
//  BILL BLASTER
// ==============

#ifdef SVQC
METHOD(MarioBillBlaster, tr_precache, void(MarioBillBlaster thistur))
{
	precache_sound("turrets/billblaster_fire.wav");
	precache_sound("weapons/r_exp3.wav");
}
METHOD(MarioBillBlaster, tr_attack, void(MarioBillBlaster this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/billblaster_fire.wav", 1, ATTN_NORM);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 700;
	newmis.noise = "weapons/r_exp3.wav";
	settouch(newmis, T_MissileTouch);
	newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
	CSQCProjectile(newmis, true, PROJECTILE_BULLET_BILL, true);
}
METHOD(MarioBillBlaster, tr_setup, void(MarioBillBlaster this, entity actor))
{
	actor.view_ofs = '0 0 48'; // for line of sight checks
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(MarioBillBlaster, tr_drawselected, void(MarioBillBlaster this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 48';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ==================
//  BULLSEYE BLASTER
// ==================

#ifdef SVQC
void BillHome(entity this)
{
	if(time > this.count)
	{
		delete(this);
		return;
	}

	if(wasfreed(this.enemy) || this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET))
	{
		this.enemy = NULL; // prevent edict number being filled by something else
		// just keep going forward
		this.nextthink = time;
		UpdateCSQCProjectile(this);
		return;
	}

	vector vtemp = (this.enemy.absmin + this.enemy.absmax) * 0.5;
	vector dir = normalize(vtemp - this.origin);
	this.velocity = dir * 400;
	this.nextthink = time;
	UpdateCSQCProjectile(this);
}

// NOTE: sounds all cached by bill blaster
METHOD(MarioBullsEyeBlaster, tr_attack, void(MarioBullsEyeBlaster this, entity actor))
{
	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 700;
	setthink(newmis, BillHome);
	newmis.nextthink = time;
	newmis.count = time + 10;
	newmis.enemy = actor.enemy;
	newmis.noise = "weapons/r_exp3.wav";
	settouch(newmis, T_MissileTouch);
	newmis.dmg = actor.shot_dmg;
	CSQCProjectile(newmis, false, PROJECTILE_BULLSEYE_BILL, true);
}
METHOD(MarioBullsEyeBlaster, tr_setup, void(MarioBullsEyeBlaster this, entity actor))
{
	actor.view_ofs = '0 0 48'; // for line of sight checks
	actor.aim_flags = TFL_AIM_SPLASH;
}
#endif // SVQC
#ifdef CSQC
METHOD(MarioBullsEyeBlaster, tr_drawselected, void(MarioBullsEyeBlaster this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 48';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
