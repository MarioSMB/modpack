#include "driller.qh"

#ifdef SVQC
PRECACHE(Driller)
{
	precache_model("progs/v_driller.mdl");
	//precache_model("progs/g_driller.mdl");

	precache_model("progs/s_drill_explode.spr");

	precache_sound("weapons/drill_shot.wav");
	precache_sound("weapons/drill_loop.wav");
}

void s_drillexplode6(entity this) { set_anim(this, 5, SUB_Remove); }
void s_drillexplode5(entity this) { set_anim(this, 4, s_drillexplode6); }
void s_drillexplode4(entity this) { set_anim(this, 3, s_drillexplode5); }
void s_drillexplode3(entity this) { set_anim(this, 2, s_drillexplode4); }
void s_drillexplode2(entity this) { set_anim(this, 1, s_drillexplode3); }
void s_drillexplode1(entity this) { set_anim(this, 0, s_drillexplode2); }

.float drill_slowtime;

METHOD(Drill, pr_explode, void(Drill this, entity actor, entity directhitentity, bool is_touch))
{
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/s_drill_explode.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, findbetterlocation(actor.origin, 8));
	s_drillexplode1(newmis);

	SUPER(Drill).pr_explode(this, actor, directhitentity, is_touch);
}

METHOD(Drill, pr_collide, void(Drill this, entity actor, entity toucher, bool is_touch))
{
	actor.drill_slowtime = time + 0.1;
}

METHOD(Drill, m_tick, void(Drill this, entity actor))
{
	float myspeed = (time <= actor.drill_slowtime) ? 20 : actor.speed;
	actor.velocity = normalize(actor.velocity) * myspeed;

	SUPER(Drill).m_tick(this, actor);
}

void W_FireDriller(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, IT_DRILLS, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/drill_shot.wav", 1, ATTN_NORM);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;

	makevectors(this.v_angle);

	Projectile ptype = PROJECTILE_DRILL;
	vector org = W_Shotorg(this, weaponentity) + v_up * -4;
	vector dir = qc_aim_fromorg(this, org, ptype.m_speed);

	Projectile_Create(ptype, this, org, dir, WEP_DRILLER.m_id);
}

METHOD(Driller, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireDriller(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.25);
	}
}
METHOD(Driller, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_drills >= 1;
	return ammo_amount;
}
METHOD(Driller, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Driller, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
