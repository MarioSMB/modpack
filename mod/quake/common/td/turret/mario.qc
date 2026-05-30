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
METHOD(MarioBillBlaster, tr_think, void(MarioBillBlaster this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector myorg = actor.origin + actor.view_ofs;
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		bool isvisible = visible(actor, actor.enemy);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(myorg - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time >= actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (2 / turret_getpower(actor.tur_level, 0.3)));
			actor.cnt = (actor.cnt) ? 0 : 1;

			_sound(actor, CH_WEAPON_SINGLE, "turrets/billblaster_fire.wav", 1, ATTN_NORM);

			vector org = myorg;
			vector dir = normalize(targ_org - org);
			entity newmis = launch_spike(actor, org, dir);
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.velocity = dir * 700;
			newmis.noise = "weapons/r_exp3.wav";
			settouch(newmis, T_MissileTouch);
			newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			CSQCProjectile(newmis, true, PROJECTILE_BULLET_BILL, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(MarioBillBlaster, tr_setup, void(MarioBillBlaster this, entity actor))
{
	actor.view_ofs = '0 0 48'; // for line of sight checks
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

	if(!this.enemy || this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET))
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
METHOD(MarioBullsEyeBlaster, tr_think, void(MarioBullsEyeBlaster this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector myorg = actor.origin + actor.view_ofs;
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		bool isvisible = visible(actor, actor.enemy);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(myorg - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time >= actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (2.5 / turret_getpower(actor.tur_level, 0.3)));
			actor.cnt = (actor.cnt) ? 0 : 1;

			_sound(actor, CH_WEAPON_SINGLE, "turrets/billblaster_fire.wav", 1, ATTN_NORM);

			vector org = myorg;
			vector dir = normalize(targ_org - org);
			entity newmis = launch_spike(actor, org, dir);
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.velocity = dir * 700;
			setthink(newmis, BillHome);
			newmis.nextthink = time;
			newmis.count = time + 10;
			newmis.enemy = actor.enemy;
			newmis.noise = "weapons/r_exp3.wav";
			settouch(newmis, T_MissileTouch);
			newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			CSQCProjectile(newmis, false, PROJECTILE_BULLSEYE_BILL, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(MarioBullsEyeBlaster, tr_setup, void(MarioBullsEyeBlaster this, entity actor))
{
	actor.view_ofs = '0 0 48'; // for line of sight checks
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
