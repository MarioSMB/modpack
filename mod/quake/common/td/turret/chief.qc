#include "chief.qh"

// ===============
//  PLASMA CANNON
// ===============

#ifdef SVQC
entity LaunchPlasmaBolt(entity this, vector org, vector dir, float damage, int deathtype)
{
	entity newmis = new(plasmacannon_bolt);
	newmis.flags = FL_PROJECTILE;
	newmis.owner = this;
	newmis.realowner = this;
	newmis.projectiledeathtype = deathtype;
	newmis.clipgroup = this.clipgroup;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	newmis.dmg = damage;

	setsize(newmis, '0 0 0', '0 0 0');

	setorigin(newmis, org);

	newmis.velocity = dir * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, Laser_Touch);

	IL_PUSH(g_projectiles, newmis);

	CSQCProjectile(newmis, true, PROJECTILE_PLASMA_CANNON, true);

	return newmis;
}

METHOD(ChiefPlasmaCannon, tr_precache, void(ChiefPlasmaCannon thistur))
{
	precache_sound("hipweap/laserg.wav");
}
METHOD(ChiefPlasmaCannon, tr_think, void(ChiefPlasmaCannon this, entity actor))
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
			actor.attack_finished = time + max(0.03, (0.5 / turret_getpower(actor.tur_level, 0.5)));
			actor.cnt = (actor.cnt) ? 0 : 1;

			_sound(actor, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 0.5, ATTN_NORM);

			vector org;
			vector dir;
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);

			if(actor.cnt)
			{
				org = myorg;
				dir = normalize(targ_org - org);
				LaunchPlasmaBolt(actor, org, dir, damage, DEATH_TRAP.m_id);
			}
			else
			{
				org = myorg + v_right * 6 + v_up * -4;
				dir = normalize(targ_org - org);
				LaunchPlasmaBolt(actor, org, dir, damage * 0.5, DEATH_TRAP.m_id);

				org = myorg + v_right * -6 + v_up * -4;
				dir = normalize(targ_org - org);
				LaunchPlasmaBolt(actor, org, dir, damage * 0.5, DEATH_TRAP.m_id);
			}
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(ChiefPlasmaCannon, tr_setup, void(ChiefPlasmaCannon this, entity actor))
{
	actor.view_ofs = '0 0 38'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(ChiefPlasmaCannon, tr_drawselected, void(ChiefPlasmaCannon this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 38';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// =======
//  GAUSS
// =======

#ifdef SVQC
METHOD(ChiefGauss, tr_precache, void(ChiefGauss thistur))
{
	precache_sound("turrets/gauss_fire1.wav");
	precache_sound("turrets/gauss_fire2.wav");
	precache_sound("turrets/gauss_fire3.wav");
	precache_sound("turrets/gauss_fire4.wav");
}
METHOD(ChiefGauss, tr_think, void(ChiefGauss this, entity actor))
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
			actor.attack_finished = time + max(0.03, (3 / turret_getpower(actor.tur_level, 0.5)));

			float r = random();
			if(r < 0.25)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire1.wav", 1, ATTN_NORM);
			else if(r < 0.50)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire2.wav", 1, ATTN_NORM);
			else if(r < 0.75)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire3.wav", 1, ATTN_NORM);
			else
				_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire4.wav", 1, ATTN_NORM);

			makevectors(actor.angles);
			vector org = myorg + v_right * 8;
			vector dir = normalize(targ_org - org);
			entity newmis = launch_spike(actor, org, dir);
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.velocity = dir * 4000;
			newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			CSQCProjectile(newmis, true, PROJECTILE_DRILL, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(ChiefGauss, tr_setup, void(ChiefGauss this, entity actor))
{
	actor.view_ofs = '0 0 38'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(ChiefGauss, tr_drawselected, void(ChiefGauss this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 38';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ===========
//  HELIBLADE
// ===========

#ifdef SVQC
void HelibladeRocketHome(entity this)
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
	this.velocity = dir * 450;
	this.nextthink = time;
	UpdateCSQCProjectile(this);
}

METHOD(ChiefHeliblade, tr_precache, void(ChiefHeliblade thistur))
{
	precache_sound("weapons/rocket1i.wav");
	precache_sound("weapons/r_exp3.wav");
	precache_sound("weapons/sgun1.wav");
}
METHOD(ChiefHeliblade, tr_think, void(ChiefHeliblade this, entity actor))
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
		// keeps a target for a few seconds instead
		//if(isvisible || isinfront)
			//actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(myorg - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time >= actor.attack_finished && isinfront && isvisible)
		{
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);

			// rocket attack
			if(targ_org.z > myorg.z)
			{
				actor.attack_finished = time + max(0.03, (1.2 / turret_getpower(actor.tur_level, 0.3)));

				float offset = (actor.cnt) ? 16 : -16;
				actor.cnt = (actor.cnt) ? 0 : 1;
				makevectors(actor.angles);

				vector org = myorg + v_right * offset;
				vector dir = normalize(targ_org - org);

				_sound(actor, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 0.5, ATTN_NORM);

				entity newmis = launch_spike(actor, org, dir);
				newmis.projectiledeathtype = DEATH_TRAP.m_id;
				newmis.velocity = dir * 800;
				setthink(newmis, HelibladeRocketHome);
				newmis.nextthink = time;
				newmis.count = time + 10;
				newmis.enemy = actor.enemy;
				newmis.noise = "weapons/r_exp3.wav";
				settouch(newmis, T_MissileTouch);
				newmis.dmg = damage * 2; // double damage, but half attack rate!
				CSQCProjectile(newmis, false, PROJECTILE_ROCKET, true);
			}
			else
			{
				actor.attack_finished = time + max(0.03, (0.4 / turret_getpower(actor.tur_level, 0.3)));

				if(time >= actor.spamtime)
				{
					actor.spamtime = time + 0.1;
					_sound(actor, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 0.5, ATTN_NORM);
				}

				vector org = actor.origin;
				vector dir = normalize(targ_org - org);
				entity newmis = launch_spike(actor, org, dir);
				newmis.projectiledeathtype = DEATH_TRAP.m_id;
				newmis.velocity = dir * 1000;
				newmis.dmg = damage;
				CSQCProjectile(newmis, true, PROJECTILE_BULLET, true);
			}
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
		if(actor.enemy)
			actor.search_time = time + 2;
	}
}
METHOD(ChiefHeliblade, tr_setup, void(ChiefHeliblade this, entity actor))
{
	actor.view_ofs = '0 0 48';
}
#endif // SVQC
#ifdef CSQC
METHOD(ChiefHeliblade, tr_drawselected, void(ChiefHeliblade this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 48';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
METHOD(ChiefHeliblade, tr_setup, void(ChiefHeliblade this, entity actor))
{
	actor.anim_idle = '0 19 0';
}
#endif // CSQC
