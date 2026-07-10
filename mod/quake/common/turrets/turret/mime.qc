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

METHOD(MimeMimeJr, tr_precache, void(MimeMimeJr this))
{
	precache_sound("turrets/mimejr.wav");
	precache_sound("player_mime/bounce.wav");
}
METHOD(MimeMimeJr, tr_attack, void(MimeMimeJr this, entity actor))
{
	setanim(actor, actor.anim_shoot, true, true, true);
	actor.anim_start_time = actor.animstate_starttime;
	actor.SendFlags |= TNSF_ANIM; // assume it updated anyway
	
	_sound(actor, CH_WEAPON_SINGLE, "turrets/mimejr.wav", 1, ATTN_NORM);

	entity missile = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	missile.velocity = actor.tur_shotdir_updated * 400;
	set_movetype(missile, MOVETYPE_BOUNCE);
	settouch(missile, MimeJrBallTouch);
	missile.dmg = actor.shot_dmg;
	missile.projectiledeathtype = DEATH_TRAP.m_id;
	missile.bouncefactor = 1;
	missile.bouncestop = 0.1;

	setthink(missile, SUB_Remove);
	missile.nextthink = time + 7;

	CSQCProjectile(missile, true, PROJECTILE_MIMEJR_BALL, true);
}
METHOD(MimeMimeJr, tr_think, void(MimeMimeJr this, entity actor))
{
	if(actor && time >= actor.animstate_endtime)
	{
		int oldframe = actor.frame;
		setanim(actor, actor.anim_idle, true, false, false);
		if(actor.frame != oldframe)
		{
			actor.anim_start_time = actor.animstate_starttime;
			actor.SendFlags |= TNSF_ANIM;
		}
	}
}
METHOD(MimeMimeJr, tr_setup, void(MimeMimeJr this, entity actor))
{
	actor.view_ofs = '0 0 24';

	vector none = '0 0 0';
	actor.anim_idle = animfixfps(actor, '0 1 1', none);
	actor.anim_shoot = animfixfps(actor, '1 1 1', none);

	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
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
	actor.view_ofs = '0 0 24';
}
#endif // CSQC
