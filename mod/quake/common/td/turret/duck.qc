#include "duck.qh"

// =======
//  DUCKY
// =======

#ifdef SVQC
METHOD(DuckDucky, tr_precache, void(DuckDucky thistur))
{
	precache_sound("turrets/ducky_fire.wav");
	precache_sound("weapons/grape_impact.wav");
}
METHOD(DuckDucky, tr_think, void(DuckDucky this, entity actor))
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
			actor.attack_finished = time + max(0.03, (1.5 / turret_getpower(actor.tur_level, 0.3)));
			actor.clientframe = TANIM_SHOOT;

			_sound(actor, CH_WEAPON_SINGLE, "turrets/ducky_fire.wav", 1, ATTN_NORM);

			vector org = myorg;
			vector dir = normalize(targ_org - org);
			entity newmis = grape_launch(actor, org, dir);
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.velocity = dir * 500;
			newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(DuckDucky, tr_setup, void(DuckDucky this, entity actor))
{
	actor.view_ofs = '0 0 36'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(DuckDucky, tr_drawselected, void(DuckDucky this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 36';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
METHOD(DuckDucky, tr_setup, void(DuckDucky this, entity actor))
{
	actor.anim_idle = '0 0 0';
	actor.anim_shoot = '1 7 1';
}
#endif // CSQC
