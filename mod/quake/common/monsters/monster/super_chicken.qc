#include "super_chicken.qh"

#ifdef SVQC

void superchicken_stand(entity this) { set_anim(this, 0, superchicken_stand); ai_stand(this); }

void superchicken_walk7(entity this) { set_anim(this, 17, superchicken_walk1); ai_walk(this, 8); }
void superchicken_walk6(entity this) { set_anim(this, 16, superchicken_walk7); ai_walk(this, 8); }
void superchicken_walk5(entity this) { set_anim(this, 15, superchicken_walk6); ai_walk(this, 8); }
void superchicken_walk4(entity this) { set_anim(this, 14, superchicken_walk5); ai_walk(this, 8); }
void superchicken_walk3(entity this) { set_anim(this, 13, superchicken_walk4); ai_walk(this, 8); }
void superchicken_walk2(entity this) { set_anim(this, 12, superchicken_walk3); ai_walk(this, 8); }
void superchicken_walk1(entity this) { set_anim(this, 11, superchicken_walk2); ai_walk(this, 8); }

void superchicken_peck10(entity this) { set_anim(this, 10, superchicken_run1); }
void superchicken_peck9(entity this) { set_anim(this, 9, superchicken_peck10); }
void superchicken_peck8(entity this) { set_anim(this, 8, superchicken_peck9); ai_melee(this, DEATH_MONSTER_SUPER_CHICKEN.m_id, 128, false); ai_face(this); }
void superchicken_peck7(entity this) { set_anim(this, 7, superchicken_peck8); ai_melee(this, DEATH_MONSTER_SUPER_CHICKEN.m_id, 128, false); ai_face(this); }
void superchicken_peck6(entity this) { set_anim(this, 6, superchicken_peck7); ai_melee(this, DEATH_MONSTER_SUPER_CHICKEN.m_id, 128, false); ai_face(this); _sound(this, CH_VOICE, "chicken/peck.wav", 1, ATTEN_LARGE); }
void superchicken_peck5(entity this) { set_anim(this, 5, superchicken_peck6); ai_melee(this, DEATH_MONSTER_SUPER_CHICKEN.m_id, 128, false); ai_face(this); }
void superchicken_peck4(entity this) { set_anim(this, 4, superchicken_peck5); ai_melee(this, DEATH_MONSTER_SUPER_CHICKEN.m_id, 128, false); ai_face(this); }
void superchicken_peck3(entity this) { set_anim(this, 3, superchicken_peck4); ai_melee(this, DEATH_MONSTER_SUPER_CHICKEN.m_id, 128, false); _sound(this, CH_VOICE, "chicken/peck.wav", 1, ATTEN_LARGE); }
void superchicken_peck2(entity this) { set_anim(this, 2, superchicken_peck3); ai_face(this); }
void superchicken_peck1(entity this) { set_anim(this, 1, superchicken_peck2); ai_face(this); }

void superchicken_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "chicken/chickdie.wav", 1, ATTEN_LARGE);
	float dm = -50;
	ThrowHead(this, inflictor, "progs/gib1.mdl", dm);
	ThrowGib(this, inflictor, "progs/mangib1.mdl", dm);
	ThrowGib(this, inflictor, "progs/mangib2.mdl", dm);
	ThrowGib(this, inflictor, "progs/mangib3.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib1.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib2.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib3.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib2.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib1.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib2.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib3.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib1.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib2.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib3.mdl", dm);
}

void superchicken_run7(entity this) { set_anim(this, 17, superchicken_run1); ai_run(this, 32); }
void superchicken_run6(entity this) { set_anim(this, 16, superchicken_run7); ai_run(this, 32); }
void superchicken_run5(entity this) { set_anim(this, 15, superchicken_run6); ai_run(this, 32); }
void superchicken_run4(entity this) { set_anim(this, 14, superchicken_run5); ai_run(this, 32); }
void superchicken_run3(entity this) { set_anim(this, 13, superchicken_run4); ai_run(this, 32); }
void superchicken_run2(entity this) { set_anim(this, 12, superchicken_run3); ai_run(this, 32); }
void superchicken_run1(entity this) { set_anim(this, 11, superchicken_run2); ai_run(this, 32); if(random() < 0.2) sound(this, CH_VOICE, SND_MON_SUPER_CHICKEN_BOCK_RANDOM(), 1, ATTEN_LARGE); }

void LaunchLaserbeam(entity this)
{
	int cont = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(this.origin));
	if(cont & DPCONTENTS_LIQUIDSMASK)
	{
		T_RadiusDamage(this, this, 35 * 10, DEATH_DISCHARGE.m_id, NULL);
		return;
	}
	
	this.effects |= EF_MUZZLEFLASH;

	fixedmakevectors(this.angles);
	vector org = (this.origin + (v_forward * 32) + '0 0 112');

	vector dir = this.enemy.origin + '0 0 16' - org;
	dir = normalize(dir);

	traceline(org, this.origin + dir*600, true, this);

	//te_lightning1(NULL, org, trace_endpos); // TODO: entity breaks
	SendCSQCLightningBeam(org, trace_endpos);

	LightningDamage(org, trace_endpos, this, 25, DEATH_MONSTER_SUPER_CHICKEN.m_id);
}

void superchicken_laser(entity this)
{
	if(this.t_width < time)
	{
		_sound(this, CH_VOICE, "enforcer/enfire.wav", 1, ATTEN_LARGE);
		this.t_width = (time + 0.600);
	}

	LaunchLaserbeam(this);
}

void superchicken_laser6(entity this) { set_anim(this, 0, superchicken_run1); ai_face(this); }
void superchicken_laser5(entity this) { set_anim(this, 0, superchicken_laser6); ai_face(this); superchicken_laser(this); }
void superchicken_laser4(entity this) { set_anim(this, 0, superchicken_laser5); ai_face(this); }
void superchicken_laser3(entity this) { set_anim(this, 0, superchicken_laser4); ai_face(this); superchicken_laser(this); }
void superchicken_laser2(entity this) { set_anim(this, 0, superchicken_laser3); ai_face(this); }
void superchicken_laser1(entity this)
{
	set_anim(this, 0, superchicken_laser2);
	if(random() < 0.2)
		sound(this, CH_VOICE, SND_MON_SUPER_CHICKEN_BOCK_RANDOM(), 1, ATTEN_LARGE);
	ai_face(this);
	superchicken_laser(this);
}

spawnfunc(monster_super_chicken) { monster_start(this, true, MON_SUPER_CHICKEN); }
#endif // SVQC

#ifdef SVQC
METHOD(SuperChicken, mr_setup, bool(SuperChicken this, entity actor))
{
    TC(SuperChicken, this);

    precache_sound("chicken/chickdie.wav");
    precache_sound("chicken/peck.wav");
    precache_sound("enforcer/enfire.wav");

    precache_model("progs/mangib1.mdl");
    precache_model("progs/mangib2.mdl");
    precache_model("progs/mangib3.mdl");

    actor.health = 1500;
    actor.th_stand = superchicken_stand;
	actor.th_walk = superchicken_walk1;
	actor.th_run = superchicken_run1;
	actor.th_die = superchicken_die;
	actor.th_melee = superchicken_peck1;
	actor.th_missile = superchicken_laser1;

    return true;
}
#endif
