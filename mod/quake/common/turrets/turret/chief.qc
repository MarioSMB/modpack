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
METHOD(ChiefPlasmaCannon, tr_attack, void(ChiefPlasmaCannon this, entity actor))
{
	actor.cnt = (actor.cnt) ? 0 : 1;

	_sound(actor, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 0.5, ATTN_NORM);

	// FIXME? using the v_ angles from the tag are skewed
	makevectors(actor.tur_shotdir_updated);

	vector org;
	float damage = actor.shot_dmg;

	if(actor.cnt)
	{
		org = actor.tur_shotorg;
		LaunchPlasmaBolt(actor, org, actor.tur_shotdir_updated, damage, DEATH_TRAP.m_id);
	}
	else
	{
		org = actor.tur_shotorg + v_right * 6 + v_up * -4;
		LaunchPlasmaBolt(actor, org, actor.tur_shotdir_updated, damage * 0.5, DEATH_TRAP.m_id);

		org = actor.tur_shotorg + v_right * -6 + v_up * -4;
		LaunchPlasmaBolt(actor, org, actor.tur_shotdir_updated, damage * 0.5, DEATH_TRAP.m_id);
	}
}
METHOD(ChiefPlasmaCannon, tr_setup, void(ChiefPlasmaCannon this, entity actor))
{
	actor.view_ofs = '0 0 38'; // for line of sight checks

	actor.target_select_flags = TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_ANGLELIMITS;
	actor.target_validate_flags = actor.target_select_flags;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
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
METHOD(ChiefGauss, tr_attack, void(ChiefGauss this, entity actor))
{
	float r = random();
	if(r < 0.25)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire1.wav", 1, ATTN_NORM);
	else if(r < 0.50)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire2.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire3.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "turrets/gauss_fire4.wav", 1, ATTN_NORM);

	// FIXME? using the v_ angles from the tag are skewed
	makevectors(actor.tur_shotdir_updated);

	vector org = actor.tur_shotorg + v_right * 8;
	entity newmis = launch_spike(actor, org, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 4000;
	newmis.dmg = actor.shot_dmg;
	CSQCProjectile(newmis, true, PROJECTILE_DRILL, true);
}
METHOD(ChiefGauss, tr_setup, void(ChiefGauss this, entity actor))
{
	actor.view_ofs = '0 0 38'; // for line of sight checks

	actor.target_select_flags = TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_ANGLELIMITS;
	actor.target_validate_flags = actor.target_select_flags;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
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

void heliblade_fire_rocket(entity this, vector org, vector dir, entity targ)
{
	_sound(this, CH_WEAPON_B, "weapons/sgun1.wav", 0.5, ATTN_NORM);

	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = dir * 800;
	setthink(newmis, HelibladeRocketHome);
	newmis.nextthink = time;
	newmis.count = time + 10;
	newmis.enemy = targ;
	newmis.noise = "weapons/r_exp3.wav";
	settouch(newmis, T_MissileTouch);
	newmis.dmg = this.shot_dmg * 2; // double damage, but half attack rate!
	CSQCProjectile(newmis, false, PROJECTILE_ROCKET, true);
}

METHOD(ChiefHeliblade, tr_precache, void(ChiefHeliblade thistur))
{
	precache_sound("weapons/rocket1i.wav");
	precache_sound("weapons/r_exp3.wav");
	precache_sound("weapons/sgun1.wav");
}
METHOD(ChiefHeliblade, tr_attack, void(ChiefHeliblade this, entity actor))
{
	float damage = actor.shot_dmg;

	if(time >= actor.spamtime)
	{
		actor.spamtime = time + 0.1;
		_sound(actor, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 0.5, ATTN_NORM);
	}

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 1000;
	newmis.dmg = damage;
	CSQCProjectile(newmis, true, PROJECTILE_BULLET, true);
}
METHOD(ChiefHeliblade, tr_think, void(ChiefHeliblade this, entity actor))
{
	if(!actor.enemy)
		return;

	entity head = actor.tur_head;
	if(head.attack_finished < time)
	{
		if(head.shot_volly > 0)
		{
			head.shot_volly -= 1;
			if(head.shot_volly <= 0)
				head.attack_finished = time + (3 / turret_getpower(actor.tur_level, 0.2));
			else
				head.attack_finished = time + (0.5 / turret_getpower(actor.tur_level, 0.2));

			vector org = gettaginfo(actor, gettagindex(actor, ((head.shot_volly > 0) ? "tag_rocket01" : "tag_rocket02")));
			vector dir = normalize(v_forward);
			heliblade_fire_rocket(actor, org, dir, actor.enemy);
		}
		else
		{
			if(actor.tur_dist_enemy <= (300 * turret_getpower(actor.tur_level, 0.2)))
				head.shot_volly = 2;
		}
	}
}
METHOD(ChiefHeliblade, tr_setup, void(ChiefHeliblade this, entity actor))
{
	actor.view_ofs = '0 0 48';

	actor.target_select_flags = TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS;
	actor.target_validate_flags = actor.target_select_flags;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
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
