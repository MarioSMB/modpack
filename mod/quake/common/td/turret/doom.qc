#include "doom.qh"

// ==================
//  CONCRETE BARRIER
// ==================

// no code, just a wall

// =================
//  AUTO MACHINEGUN
// =================

#ifdef SVQC
METHOD(DoomAutoMachineGun, tr_precache, void(DoomAutoMachineGun thistur))
{
	precache_sound("weapons/spike2.wav");
}
METHOD(DoomAutoMachineGun, tr_think, void(DoomAutoMachineGun this, entity actor))
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
			actor.attack_finished = time + max(0.03, (0.66 / turret_getpower(actor.tur_level, 0.3)));

			if(time >= actor.spamtime)
			{
				actor.spamtime = time + 0.1;
				_sound(actor, CH_WEAPON_SINGLE, "weapons/spike2.wav", 0.5, ATTN_NORM);
			}

			makevectors(actor.angles);
			vector org = myorg;
			vector dir = normalize(CENTER_OR_VIEWOFS(actor.enemy) - org);
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			int shotcount = 4;
			vector spread = '0.08 0.08 0';

			damage /= shotcount;
			for(int j = 0; j < shotcount; ++j)
			{
				float var_speed = crandom() * 10 + 800;
				vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
				entity missile = launch_spike(actor, org, spread_dir);
				missile.classname = "bullet"; // hack
				missile.velocity = spread_dir * var_speed;
				missile.projectiledeathtype = DEATH_TRAP.m_id;
				missile.dmg = damage;

				CSQCProjectile(missile, true, PROJECTILE_BULLET, true);
			}
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(DoomAutoMachineGun, tr_setup, void(DoomAutoMachineGun this, entity actor))
{
	actor.view_ofs = '0 0 27';
}
#endif // SVQC
#ifdef CSQC
METHOD(DoomAutoMachineGun, tr_drawselected, void(DoomAutoMachineGun this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 27';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC

// ========
//  PHASER
// ========

#ifdef SVQC
METHOD(DoomPhaser, tr_precache, void(DoomPhaser thistur))
{
	precache_sound("hipweap/laserg.wav");
}
METHOD(DoomPhaser, tr_think, void(DoomPhaser this, entity actor))
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
			actor.attack_finished = time + max(0.03, (1 / turret_getpower(actor.tur_level, 0.5)));

			_sound(actor, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 0.5, ATTN_NORM);

			int shots = 3;
			float spread = 0.08;
			vector shotdir = normalize(targ_org - myorg);
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			damage /= shots;
			for(int counter = 0; counter < shots; ++counter)
			{
				vector dir = shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_right * spread;
				entity newmis = LaunchLaser(actor, myorg, dir);
				newmis.velocity = dir * 600;
				newmis.projectiledeathtype = DEATH_TRAP.m_id;
				newmis.dmg = damage;
			}
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(DoomPhaser, tr_setup, void(DoomPhaser this, entity actor))
{
	actor.view_ofs = '0 0 32'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(DoomPhaser, tr_drawselected, void(DoomPhaser this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 32';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ========
//  COIL
// ========

#ifdef SVQC
METHOD(DoomCoil, tr_precache, void(DoomCoil thistur))
{
	precache_sound("weapons/lhit.wav");
}
METHOD(DoomCoil, tr_think, void(DoomCoil this, entity actor))
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
			actor.attack_finished = time + 0.2; // hardcoded delay (lightning zappy)

			if(actor.spamtime < time)
			{
				_sound(actor, CH_WEAPON_SINGLE, "weapons/lhit.wav", 0.5, ATTN_NORM);
				actor.spamtime = time + 0.6;
			}

			// TODO: water check? explode turret!
			vector dir = normalize(CENTER_OR_VIEWOFS(actor.enemy) - myorg);
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);

			traceline(myorg, myorg + dir * myrange, MOVE_NORMAL, actor);

			SendCSQCLightningBeam(myorg, trace_endpos);
			LightningDamage(myorg, trace_endpos, actor, damage, DEATH_TRAP.m_id);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(DoomCoil, tr_setup, void(DoomCoil this, entity actor))
{
	actor.view_ofs = '0 0 20'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(DoomCoil, tr_drawselected, void(DoomCoil this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 20';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
