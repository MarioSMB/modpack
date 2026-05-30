#include "squire.qh"

// ================
//  SPIKE BLOCKADE
// ================

#ifdef SVQC
.float spikeblockade_dmgtime;
void spikeblockade_hitbox_touch(entity this, entity toucher)
{
	if(time < toucher.spikeblockade_dmgtime)
		return;

	Turret tur = this.turretdef;
	toucher.spikeblockade_dmgtime = time + 0.5; // TODO?
	float damage = tur.tur_dmg * turret_getpower(this.tur_level, tur.tur_dmgscale);

	// also push enemy away
	if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

		vector dir = normalize(toucher.origin - this.origin);
		toucher.velocity = dir * (150 * pushforce);
		toucher.velocity_z = (50 * pushforce);
	}

	_sound(toucher, CH_SHOTS, "enviro/physics/trcut.wav", 1, ATTN_NORM);

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);
}

METHOD(SquireSpikeBlockade, tr_think, void(SquireSpikeBlockade thistur, entity actor))
{
	vector emin = actor.absmin, emax = actor.absmax;
	vector extrasize = '16 16 16'; // give it a bit of spiked range
	emin -= extrasize;
	emax += extrasize;

	// unlike barricades, blockades only hurt enemies infront
	makevectors(actor.angles);
	vector myorg = (actor.absmin + actor.absmax) * 0.5;

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != actor && IS_MONSTER(it) && it.health > 0 && !it.charmed && it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY,
	{
		vector targ_org = (it.absmin + it.absmin) * 0.5;
		vector vec = normalize(targ_org - myorg);
		float dot = vec * v_forward;
		if(dot < 0.3)
			continue;

		spikeblockade_hitbox_touch(actor, it);
	});
}
#endif // SVQC

// =========
//  BOUNCER
// =========

#ifdef SVQC
.float bouncer_dmgtime;
void bouncer_hitbox_touch(entity this, entity toucher)
{
	if(time < toucher.bouncer_dmgtime)
		return;

	Turret tur = this.turretdef;
	toucher.bouncer_dmgtime = time + 0.5; // TODO?
	float damage = tur.tur_dmg * turret_getpower(this.tur_level, tur.tur_dmgscale);

	// also push enemy away
	if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

		vector dir = normalize(toucher.origin - this.origin);
		toucher.velocity = dir * (350 * pushforce);
		toucher.velocity_z = (125 * pushforce);
	}

	_sound(toucher, CH_SHOTS, "enviro/physics/trcut.wav", 1, ATTN_NORM);

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);
}

METHOD(SquireBouncer, tr_precache, void(SquireBouncer thistur))
{
	precache_sound("turrets/bouncer_fire1.wav");
	precache_sound("turrets/bouncer_fire2.wav");

	precache_sound("enviro/physics/trcut.wav");
}
METHOD(SquireBouncer, tr_think, void(SquireBouncer thistur, entity actor))
{
	if(time < actor.attack_finished)
		return;

	entity targ = turret_findtarget(actor, 0, 0, 64);

	if(!targ)
		return;

	actor.attack_finished = time + max(0.03, (1.5 / turret_getpower(actor.tur_level, 0.33)));
	actor.clientframe = TANIM_SHOOT;

	if(random() > 0.5)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/bouncer_fire1.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "turrets/bouncer_fire2.wav", 1, ATTN_NORM);

	vector emin = actor.absmin, emax = actor.absmax;
	vector extrasize = '64 64 8'; // give it a bit of spiked range
	emin -= extrasize;
	emax += extrasize;

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != actor && IS_MONSTER(it) && it.health > 0 && !it.charmed && it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY,
	{
		bouncer_hitbox_touch(actor, it);
	});
}
#endif // SVQC
#ifdef CSQC
METHOD(SquireBouncer, tr_drawselected, void(SquireBowlingBall this, entity actor))
{
	float myrange = this.target_range;
	vector org = actor.origin + '0 0 16';

	Draw_Circle(org, myrange);
}
METHOD(SquireBouncer, tr_setup, void(SquireHarpoon this, entity actor))
{
	actor.anim_idle = '0 0 0';
	actor.anim_shoot = '1 15 1';
}
#endif // CSQC

// =========
//  HARPOON
// =========

#ifdef SVQC
METHOD(SquireHarpoon, tr_precache, void(SquireHarpoon thistur))
{
	precache_sound("turrets/harpoon_fire1.wav");
	precache_sound("turrets/harpoon_fire2.wav");

	// already cached by crossbow
#if 0
	precache_sound("weapons/pierce1.wav");
	precache_sound("weapons/pierce2.wav");
	precache_sound("weapons/pierce3.wav");

	precache_model("progs/proj_impalespike.mdl");
	precache_sound("weapons/stick1.wav");
#endif
}
void crossbow_bolt_think(entity this); // copy-pasta
METHOD(SquireHarpoon, tr_think, void(SquireHarpoon this, entity actor))
{
	// make sure it matches drawn values!
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
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
			actor.attack_finished = time + max(0.03, (1.5 / turret_getpower(actor.tur_level, 0.5)));
			actor.clientframe = TANIM_SHOOT;

			if(random() > 0.5)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/harpoon_fire1.wav", 1, ATTN_NORM);
			else
				_sound(actor, CH_WEAPON_SINGLE, "turrets/harpoon_fire2.wav", 1, ATTN_NORM);

			vector org = myorg;
			vector dir = normalize(targ_org - org);
			entity missile = launch_spike(actor, org, dir);
			set_movetype(missile, MOVETYPE_FLYMISSILE);
			missile.solid = SOLID_TRIGGER;
			missile.dphitcontentsmask = DPCONTENTS_SOLID;
			missile.speed = 800;
			missile.pos2 = dir;
			missile.count = time + 12;
			missile.cnt = 32;
			settouch(missile, crossbow_bolt_touch);
			missile.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			missile.classname = "crossbow_bolt"; // identifier for spike touch TODO: clean this mess up
			missile.projectiledeathtype = DEATH_TRAP.m_id;
			//_setmodel(missile, "progs/proj_impalespike.mdl");
			setsize(missile, '0 0 0', '0 0 0');

			setthink(missile, crossbow_bolt_think);
			missile.nextthink = time;

			CSQCProjectile(missile, true, PROJECTILE_CROSSBOW_BOLT, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(SquireHarpoon, tr_setup, void(SquireHarpoon this, entity actor))
{
	actor.view_ofs = '0 0 32'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(SquireHarpoon, tr_drawselected, void(SquireHarpoon this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 32';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
METHOD(SquireHarpoon, tr_setup, void(SquireHarpoon this, entity actor))
{
	actor.anim_idle = '0 0 0';
	actor.anim_shoot = '1 6 1';
}
#endif // CSQC

// ==============
//  SLICE N DICE
// ==============

#ifdef SVQC
.float slicendice_dmgtime;
void slicendice_hitbox_touch(entity this, entity toucher)
{
	if(time < toucher.slicendice_dmgtime)
		return;

	Turret tur = this.turretdef;
	toucher.slicendice_dmgtime = time + 0.25; // TODO?
	float damage = tur.tur_dmg * turret_getpower(this.tur_level, tur.tur_dmgscale);

	_sound(toucher, CH_SHOTS, "enviro/physics/trcut.wav", 1, ATTN_NORM);

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);
}

METHOD(SquireSliceNDice, tr_think, void(SquireSliceNDice thistur, entity actor))
{
	entity head = actor.tur_head;

	entity targ = turret_findtarget(actor, 0, 0, 170);
	if(targ)
	{
		if(time >= actor.attack2_finished && actor.clientframe < 4)
		{
			actor.attack2_finished = time + 0.5;
			actor.clientframe += 1;
			actor.walkframe = actor.clientframe; // instant update
			actor.SendFlags |= TNSF_ANIM;
		}
		actor.attack_finished = time + 4; // keep spinning!
	}
	else if(time >= actor.attack2_finished && actor.clientframe > 0)
	{
		actor.attack2_finished = time + 1;
		actor.clientframe -= 1;
		actor.walkframe = actor.clientframe; // instant update
		actor.SendFlags |= TNSF_ANIM;
	}

	if(actor.clientframe <= 0)
	{
		if(head.avelocity != '0 0 0')
		{
			head.avelocity = '0 0 0';
			actor.SendFlags |= TNSF_AVEL;
		}
		return;
	}

	float myrange = actor.clientframe / 4; // can't be 0
	vector emin = actor.absmax - '0 0 12', emax = actor.absmax - '0 0 4';
	vector extrasize = '100 100 6' * myrange; // give it a bit of spiked range
	emin -= extrasize;
	emax += extrasize;

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != actor && IS_MONSTER(it) && it.health > 0 && !it.charmed && it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY,
	{
		slicendice_hitbox_touch(actor, it);
	});

	vector avel = '0 720 0' * myrange;
	if(head.avelocity != avel)
	{
		head.avelocity = avel;
		actor.SendFlags |= TNSF_AVEL;
	}
}
#endif // SVQC
#ifdef CSQC
.float slicespam;
void slicendice_sounds(entity actor)
{
	if(time < actor.slicespam)
		return;
	entity head = actor.tur_head;
	if(head.frame == 0 && actor.clientframe == 0)
		return;

	if(actor.clientframe > 0 && head.frame == 0)
	{
		_sound(actor, CH_WEAPON_SINGLE, "turrets/slicendice_start.wav", 1, ATTN_NORM);
		actor.slicespam = time + 0.5;
	}
	else if(actor.clientframe == 0 && head.frame > 0)
	{
		_sound(actor, CH_WEAPON_SINGLE, "turrets/slicendice_end.wav", 1, ATTN_NORM);
		actor.slicespam = time + 0.5;
	}
	else if(head.frame > 0)
	{
		_sound(actor, CH_WEAPON_SINGLE, "turrets/slicendice_loop.wav", 1, ATTN_NORM);
		actor.slicespam = time + 1.631;
	}
}

METHOD(SquireSliceNDice, tr_precache, void(SquireSliceNDice thistur))
{
	precache_sound("turrets/slicendice_start.wav");
	precache_sound("turrets/slicendice_end.wav");
	precache_sound("turrets/slicendice_end.wav");
}
METHOD(SquireSliceNDice, tr_think, void(SquireSliceNDice thistur, entity actor))
{
	slicendice_sounds(actor);

	entity head = actor.tur_head;
	if(time < head.anim_finished)
		return;
	head.anim_finished = time + 0.1;

	if(head.frame != actor.clientframe)
	{
		CSQCModel_InterpolateAnimation_1To2_PreNote(head, BIT(23));
		head.frame = actor.clientframe;
		CSQCModel_InterpolateAnimation_1To2_Note(head, BIT(23), true);
	}
	CSQCModel_InterpolateAnimation_Do(head);
}
METHOD(SquireSliceNDice, tr_drawselected, void(SquireSliceNDice this, entity actor))
{
	float myrange = this.target_range;
	vector org = actor.origin + '0 0 38';

	Draw_Circle(org, myrange);
}
#endif // CSQC

// ==============
//  BOWLING BALL
// ==============

#ifdef SVQC
void BecomeMiniBlast(entity this, int blasttype);
void bowlingball_break(entity this)
{
	if(random() < 0.33)
		_sound(this, CH_SHOTS, "turrets/bowlingball_break1.wav", 1, ATTN_NORM);
	else if(random() < 0.66)
		_sound(this, CH_SHOTS, "turrets/bowlingball_break3.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_SHOTS, "turrets/bowlingball_break2.wav", 1, ATTN_NORM);

	// assets cached by MMML
	BecomeMiniBlast(this, 2);
}

.float bowlingball_dmgtime;
void bowlingball_touch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER)
		return;
	if(toucher.takedamage && time >= toucher.bowlingball_dmgtime)
	{
		toucher.bowlingball_dmgtime = time + 0.25;
		float damage = (this.dmg) ? this.dmg : 16;
		T_Damage(toucher, this, this.owner, damage, this.projectiledeathtype);

		UpdateCSQCProjectile(this);
	}

	if(this.attack_finished < time)
	{
		float r = random();
		if(r < 0.25)
			_sound(this, CH_SHOTS_SINGLE, "turrets/bowlingball_bounce1.wav", 0.5, ATTN_NORM);
		else if(r < 0.50)
			_sound(this, CH_SHOTS_SINGLE, "turrets/bowlingball_bounce2.wav", 0.5, ATTN_NORM);
		else if(r < 0.75)
			_sound(this, CH_SHOTS_SINGLE, "turrets/bowlingball_bounce3.wav", 0.5, ATTN_NORM);
		else
			_sound(this, CH_SHOTS_SINGLE, "turrets/bowlingball_bounce4.wav", 0.5, ATTN_NORM);
	}
	this.attack_finished = time + 0.1;
}

METHOD(SquireBowlingBall, tr_precache, void(SquireBowlingBall thistur))
{
	precache_sound("turrets/bowlingball_fire1.wav");
	precache_sound("turrets/bowlingball_fire2.wav");
	precache_sound("turrets/bowlingball_fire3.wav");

	precache_sound("turrets/bowlingball_break1.wav");
	precache_sound("turrets/bowlingball_break2.wav");
	precache_sound("turrets/bowlingball_break3.wav");

	precache_sound("turrets/bowlingball_bounce1.wav");
	precache_sound("turrets/bowlingball_bounce2.wav");
	precache_sound("turrets/bowlingball_bounce3.wav");
	precache_sound("turrets/bowlingball_bounce4.wav");
}
METHOD(SquireBowlingBall, tr_think, void(SquireBowlingBall thistur, entity actor))
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

			if(random() < 0.33)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/bowlingball_fire1.wav", 1, ATTN_NORM);
			else if(random() < 0.66)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/bowlingball_fire3.wav", 1, ATTN_NORM);
			else
				_sound(actor, CH_WEAPON_SINGLE, "turrets/bowlingball_fire2.wav", 1, ATTN_NORM);

			vector org = myorg;
			vector dir = normalize(targ_org - org);
			entity missile = launch_spike(actor, org, dir);
			missile.velocity = dir * 200;
			set_movetype(missile, MOVETYPE_BOUNCE);
			settouch(missile, bowlingball_touch);
			missile.dmg = thistur.tur_dmg * turret_getpower(actor.tur_level, thistur.tur_dmgscale);
			missile.projectiledeathtype = DEATH_TRAP.m_id;
			setsize(missile, '0 0 0', '0 0 0');
			missile.bouncefactor = 0.99;
			missile.bouncestop = 0.01;

			setthink(missile, bowlingball_break);
			missile.nextthink = time + 6;

			CSQCProjectile(missile, true, PROJECTILE_BOWLING_BALL, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(SquireBowlingBall, tr_setup, void(SquireBowlingBall this, entity actor))
{
	actor.view_ofs = '0 0 42';
}
#endif // SVQC
#ifdef CSQC
METHOD(SquireBowlingBall, tr_drawselected, void(SquireBowlingBall this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 42';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
METHOD(SquireBowlingBall, tr_setup, void(SquireBowlingBall this, entity actor))
{
	actor.anim_idle = '0 0 0';
	actor.anim_shoot = '1 5 1';

	actor.view_ofs = '0 0 42';
}
#endif // CSQC
