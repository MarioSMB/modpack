#include "keen.qh"

// ==========
//  DOPEFISH
// ==========

#ifdef SVQC
void dopefish_bubble_pop(entity this)
{
	if(pointcontents(this.origin) == CONTENT_WATER)
		mermaid_bubble_spawnbubbles(this, 10);
	else
		te_wizspike(this.origin);
	_sound(this, CH_WEAPON_SINGLE, "weapons/bubble_impact.wav", 1, ATTN_NORM);

	delete(this);
}

METHOD(KeenDopefish, tr_precache, void(KeenDopefish thistur))
{
	precache_sound("turrets/dopefish_fire.wav");
	precache_sound("weapons/bubble_impact.wav");
}
METHOD(KeenDopefish, tr_think, void(KeenDopefish this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.05);
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

			if(time >= actor.spamtime)
			{
				actor.spamtime = time + 0.1;
				_sound(actor, CH_WEAPON_SINGLE, "turrets/dopefish_fire.wav", 0.5, ATTN_NORM);
			}

			makevectors(actor.angles);
			vector org = myorg;
			vector dir = normalize(CENTER_OR_VIEWOFS(actor.enemy) - org);
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			int shotcount = 4;
			vector spread = '0.08 0.08 0';
			float proj_speed = 300;

			damage /= shotcount;
			for(int j = 0; j < shotcount; ++j)
			{
				float var_speed = crandom() * 10 + proj_speed;
				vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
				entity missile = launch_spike(actor, org, spread_dir);
				missile.classname = "mermaid_bubble"; // hack
				missile.velocity = spread_dir * var_speed;
				missile.projectiledeathtype = DEATH_TRAP.m_id;
				missile.dmg = damage;
				missile.nextthink = time + 1;
				setthink(missile, dopefish_bubble_pop);

				CSQCProjectile(missile, true, PROJECTILE_MERMAID_BUBBLE, true);
			}
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(KeenDopefish, tr_setup, void(KeenDopefish this, entity actor))
{
	actor.view_ofs = '0 0 16';
}
#endif // SVQC
#ifdef CSQC
METHOD(KeenDopefish, tr_drawselected, void(KeenDopefish this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.05);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 16';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC

// ==============
//  ALIEN SNIPER
// ==============

#ifdef SVQC
entity LaunchAlienSniperBolt(entity this, vector org, vector dir, float damage, int deathtype)
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

	newmis.velocity = dir * 1800;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, Laser_Touch);

	IL_PUSH(g_projectiles, newmis);

	CSQCProjectile(newmis, true, PROJECTILE_ALIEN_SNIPER, true);

	return newmis;
}

METHOD(KeenAlienSniper, tr_precache, void(KeenAlienSniper thistur))
{
	precache_sound("turrets/aliensniper_fire1.wav");
	precache_sound("turrets/aliensniper_fire2.wav");
	precache_sound("turrets/aliensniper_fire3.wav");

	precache_sound("turrets/aliensniper_laugh.wav");
}
METHOD(KeenAlienSniper, tr_think, void(KeenAlienSniper this, entity actor))
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

			float r = random();
			if(random() < 0.1 && time >= actor.spamtime)
			{
				actor.spamtime = time + 3; // not too often!
				_sound(actor, CH_VOICE, "turrets/aliensniper_laugh.wav", 1, ATTN_NORM);
			}

			if(r < 0.33)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/aliensniper_fire1.wav", 0.5, ATTN_NORM);
			else if(r < 0.66)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/aliensniper_fire2.wav", 0.5, ATTN_NORM);
			else
				_sound(actor, CH_WEAPON_SINGLE, "turrets/aliensniper_fire3.wav", 0.5, ATTN_NORM);

			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			// left eye
			vector dir = normalize(targ_org - myorg);
			LaunchAlienSniperBolt(actor, myorg, dir, damage, DEATH_TRAP.m_id);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(KeenAlienSniper, tr_setup, void(KeenAlienSniper this, entity actor))
{
	actor.view_ofs = '0 0 30'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(KeenAlienSniper, tr_drawselected, void(KeenAlienSniper this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 32';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// =====
//  UFO
// =====

#ifdef SVQC
bool turret_infront_3d(entity this, entity targ, vector sangle, float maxpitch, float maxrot)
{
	vector org = this.origin + this.view_ofs;
	vector targ_org = (targ.absmin + targ.absmax) * 0.5;
	vector targ_dir = normalize(targ_org - org);
	float dot = (targ_dir * sangle);

	// TODO: also use the rotation limit?
	// for now this doesn't matter as they are equal
	// FIXME: still not detecting enemies reliably...
	float pitch_cos = cos(maxpitch * 0.5 * DEG2RAD);

	return (dot >= pitch_cos);
}

void ufo_hitbox_touch(entity this, entity toucher)
{
	Turret tur = this.turretdef;
	float damage = tur.tur_dmg * turret_getpower(this.tur_level, tur.tur_dmgscale);

	if(time > toucher.spamtime)
	{
		toucher.spamtime = time + 0.1;
		_sound(toucher, CH_SHOTS, "turrets/ufo_tink1.wav", 1, ATTN_NORM);
	}

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);
}

bool ufo_beam_fire(entity this, float maxpitch, float maxrot, float trange)
{
	bool didhit = false;
	makevectors(this.angles);
	vector org = this.origin + this.view_ofs;
	FOREACH_ENTITY_RADIUS(org, trange, it.takedamage && IS_MONSTER(it) && !it.charmed,
	{
		if(it.health < 1 || it.exptime != 0)
			continue;
		if(time < it.invincible_finished)
			continue;
		// always aims straight down
		if(!turret_infront_3d(this, it, -v_up, maxpitch, maxrot))
			continue;
		if(!checkpvs(org, it))
			continue;
		ufo_hitbox_touch(this, it);
		didhit = true;
	});

	return didhit;
}

METHOD(KeenUFO, tr_precache, void(KeenUFO thistur))
{
	precache_sound("turrets/ufo_tink1.wav");
}
METHOD(KeenUFO, tr_think, void(KeenUFO this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);

	// always scan for targets, only draw the beam if we have someone in our midst
	if(time < actor.idle_finished)
		return;

	actor.idle_finished = time + 0.25;

	// inlined version of turret_findtarget
	// doesn't include some checks (direction)
	if(ufo_beam_fire(actor, maxpitch, maxrot, myrange))
	{
		// for drawing of the beam
		actor.clientframe = TANIM_SHOOT;
		actor.attack_finished = time + 1;
	}
}
#endif // SVQC
#ifdef CSQC
METHOD(KeenUFO, tr_think, void(KeenUFO this, entity actor))
{
	if(actor.clientframe != TANIM_SHOOT)
		return; // only draw beam while firing!

	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = actor.origin;

	makevectors(actor.angles);

	Draw_Cone_withline(org, -v_up, myrange, maxpitch, maxrot, '0 1 1', 0.3, false);
}
METHOD(KeenUFO, tr_drawselected, void(KeenUFO this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = actor.origin;

	makevectors(actor.angles);

	Draw_Cone(org, -v_up, myrange, maxpitch, maxrot);
}
METHOD(KeenUFO, tr_setup, void(KeenUFO this, entity actor))
{
	actor.anim_idle = '0 139 0';
	actor.anim_shoot = '0 139 0';
}
#endif // CSQC
