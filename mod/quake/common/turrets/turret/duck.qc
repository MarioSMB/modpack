#include "duck.qh"

// =======
//  DUCKY
// =======

#ifdef SVQC
const int DUCKY_ANIM_NO = 0;
const int DUCKY_ANIM_SHOOT = 1;

.float animflag;

bool ducky_firecheck(entity this)
{
	if (this.animflag == DUCKY_ANIM_SHOOT)
		return false;
	return turret_firecheck(this);
}

void ducky_setnoanim(entity this)
{
	turrets_setframe(this, DUCKY_ANIM_NO, false);
	this.animflag = this.frame;
}

METHOD(DuckDucky, tr_precache, void(DuckDucky thistur))
{
	precache_sound("turrets/ducky_fire.wav");
	precache_sound("weapons/grape_impact.wav");
}
METHOD(DuckDucky, tr_attack, void(DuckDucky this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/ducky_fire.wav", 1, ATTN_NORM);

	entity newmis = grape_launch(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 500;
	newmis.dmg = actor.shot_dmg;

	defer(actor, 0.7, ducky_setnoanim);

	turrets_setframe(actor, DUCKY_ANIM_SHOOT, false);
	actor.animflag = actor.frame;
}
METHOD(DuckDucky, tr_setup, void(DuckDucky this, entity actor))
{
	actor.turret_firecheckfunc = ducky_firecheck;
}
#endif // SVQC
#ifdef CSQC
METHOD(DuckDucky, tr_drawselected, void(DuckDucky this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
