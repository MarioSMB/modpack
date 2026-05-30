#include "mime.qh"

// =========
//  MIME JR
// =========

#ifdef SVQC
void MimeJrBallTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	float damage = (this.dmg) ? this.dmg : 8;
	if(toucher.takedamage == DAMAGE_AIM && Damage_ValidTarget(toucher, this.owner))
		T_Damage(toucher, this, this.owner, damage, this.projectiledeathtype);

	if(this.attack_finished < time)
		sound7(this, CH_SHOTS_SINGLE, "player_mime/bounce.wav", 0.7, ATTN_NORM, 150, 0);
	this.attack_finished = time + 0.1;
	
	if(toucher)
		UpdateCSQCProjectile(this);
}

METHOD(MimeMimeJr, tr_precache, void(MimeMimeJr thistur))
{
	precache_sound("turrets/mimejr.wav");
	precache_sound("player_mime/bounce.wav");
}
METHOD(MimeMimeJr, tr_think, void(MimeMimeJr thistur, entity actor))
{
	// make sure it matches drawn values!
	float myrange = thistur.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = thistur.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = thistur.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector myorg = actor.origin + actor.view_ofs;
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isvisible = visible(actor, actor.enemy);
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(myorg - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time > actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (2 / turret_getpower(actor.tur_level, 0.5)));
			actor.clientframe = TANIM_SHOOT;

			_sound(actor, CH_WEAPON_SINGLE, "turrets/mimejr.wav", 1, ATTN_NORM);

			vector org = myorg;
			vector dir = normalize(targ_org - org);
			entity missile = launch_spike(actor, org, dir);
			missile.velocity = dir * 400;
			set_movetype(missile, MOVETYPE_BOUNCE);
			settouch(missile, MimeJrBallTouch);
			missile.dmg = thistur.tur_dmg * turret_getpower(actor.tur_level, thistur.tur_dmgscale);
			missile.projectiledeathtype = DEATH_TRAP.m_id;
			missile.bouncefactor = 1;
			missile.bouncestop = 0.1;

			setthink(missile, SUB_Remove);
			missile.nextthink = time + 7;

			CSQCProjectile(missile, true, PROJECTILE_MIMEJR_BALL, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(MimeMimeJr, tr_setup, void(MimeMimeJr this, entity actor))
{
	actor.view_ofs = '0 0 24';
}
#endif // SVQC
#ifdef CSQC
METHOD(MimeMimeJr, tr_drawselected, void(MimeMimeJr this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 24';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
METHOD(MimeMimeJr, tr_setup, void(MimeMimeJr this, entity actor))
{
	actor.anim_idle = '0 12 0';
	actor.anim_shoot = '13 26 1';

	actor.view_ofs = '0 0 24';
}
#endif // CSQC
