#include "dryad.qh"

// =============
//  WORLD TREE
// =============

#ifdef SVQC
.float worldtree_healtime; // antispam
bool worldtree_heal(entity this, entity toucher)
{	
	if(toucher.tank)
		return false;
	if(toucher.clockwork)
		return false;
	if(toucher.m_transform)
		return false;
	//if(time < toucher.worldtree_healtime)
		//return false;
	
	float healing = this.shot_dmg;
	if(IS_PLAYER(toucher))
		healing *= 0.5; // for players, less healing (sorry!)
	if(!T_Heal(toucher, max(1, floor(healing)), IS_PLAYER(toucher)))
		return false;

	toucher.healthrot_nextcheck = time + 2;

	if(IS_TURRET(toucher))
		toucher.SendFlags |= TNSF_STATUS;
	
	// health touch sound
	//_sound(toucher, CH_TRIGGER_SINGLE, "items/r_item1.wav", 1, ATTN_NORM);

	//particle(toucher.origin, '0 0 0', 26, 32);
	if(time >= toucher.worldtree_healtime)
	{
		Send_Effect(EFFECT_QCC_MUSHROOM, (toucher.absmin + toucher.absmax) * 0.5, '0 0 0', 1);
		toucher.worldtree_healtime = time + 1;
	}
	
	//this.model = string_null;
	//this.solid = SOLID_NOT;
	//delete(this);
	return true;
}

METHOD(DryadWorldTree, tr_think, void(DryadWorldTree this, entity actor))
{
	if(time < actor.idle_finished)
		return;

	actor.idle_finished = time + 0.33; // delay mostly to prevent lag

	FOREACH_ENTITY_RADIUS(actor.origin + actor.view_ofs, this.target_range, it != actor && it.turretdef != TUR_WORLD_TREE && (IS_PLAYER(it) || IS_TURRET(it)) && it.health > 0,
	{
		if(it.exptime != 0)
			continue;
		if(IS_PLAYER(it) && it.health > 250)
			continue;
		if(IS_TURRET(it) && it.health >= it.max_health)
			continue;

		worldtree_heal(actor, it);
	});
}
METHOD(DryadWorldTree, tr_setup, void(DryadWorldTree this, entity actor))
{
	actor.view_ofs = '0 0 24';

	// does nothing on its own
	actor.damage_flags = TFL_DMG_YES;
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	actor.firecheck_flags = TFL_FIRECHECK_NO;
	actor.shoot_flags = TFL_SHOOT_NO;
	actor.target_select_flags = TFL_TARGETSELECT_NO;
	actor.target_validate_flags = actor.target_select_flags;
}
#endif // SVQC
#ifdef CSQC
METHOD(DryadWorldTree, tr_drawselected, void(DryadWorldTree this, entity actor))
{
	float myrange = this.target_range;
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 2';

	Draw_Circle(org, myrange);
}
METHOD(DryadWorldTree, tr_setup, void(DryadWorldTree this, entity actor))
{
	actor.anim_idle = '0 32 0';
}
#endif // CSQC

// ==============
//  HORNETS NEST
// ==============

#ifdef SVQC
void HornetHome(entity this)
{
	if(!this.enemy || this.enemy.health < 1)
	{
		RandomSelection_Init();
		float myrange = (this.cnt) ? this.cnt : 256;
		FOREACH_ENTITY_RADIUS(this.origin, myrange, it.takedamage && IS_MONSTER(it) && it.health > 0,
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		this.enemy = RandomSelection_chosen_ent;
	}

	vector vtemp = (this.enemy) ? CENTER_OR_VIEWOFS(this.enemy) : this.origin;
	if(time > this.count)
	{
		stopsound(this, CH_SHOTS_SINGLE);
		delete(this);
		return;
	}
	if(time >= this.attack_finished)
	{
		float damage = (this.dmg) ? this.dmg : 15;
		FOREACH_ENTITY_RADIUS(this.origin, 16, it.takedamage && IS_MONSTER(it) && it.health > 0,
		{
			if(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
				continue;
			T_Damage(it, this, this.owner, damage, DEATH_TRAP.m_id);
		});

		this.attack_finished = time + 0.5;
	}

	vector dir = normalize(vtemp - this.origin);
	this.velocity = dir * 250;
	this.nextthink = time;
	UpdateCSQCProjectile(this);
}

void Hornet_Launch(entity this, vector org, entity targ)
{
	vector dir = normalize(CENTER_OR_VIEWOFS(targ) - org);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "moss_hornet";
	missile.owner = this;
	missile.projectiledeathtype = DEATH_TRAP.m_id;
	missile.clipgroup = this.clipgroup;
	missile.poisonous = true;

	missile.solid = SOLID_TRIGGER;
	set_movetype(missile, MOVETYPE_FLYMISSILE);

	setsize(missile, '0 0 0', '0 0 0');		

	setorigin(missile, org);
	missile.velocity = dir * 400;
	missile.nextthink = time;
	missile.count = time + 3.6;
	setthink(missile, HornetHome);
	missile.enemy = targ;
	missile.dmg = this.shot_dmg;
	missile.cnt = 256 * turret_getpower(this.tur_level, 0.2);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, false, PROJECTILE_MOSS_HORNET, true);

	_sound(missile, CH_SHOTS_SINGLE, "turrets/hornetsnest_swarm.wav", 1, ATTN_NORM);
}

METHOD(DryadHornetsNest, tr_precache, void(DryadHornetsNest this))
{
	precache_sound("turrets/hornetsnest_swarm.wav");
}
METHOD(DryadHornetsNest, tr_attack, void(DryadHornetsNest this, entity actor))
{
	Hornet_Launch(actor, actor.tur_shotorg, actor.enemy);
}
#endif // SVQC
#ifdef CSQC
METHOD(DryadHornetsNest, tr_drawselected, void(DryadHornetsNest this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	vector org = actor.origin + ((actor.mins + actor.maxs) * 0.5) + '0 0 8';
	//vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

	Draw_Circle(org, myrange);
}
#endif // CSQC

// ============
//  HARPY PERCH
// ============

#ifdef SVQC
const int HARPYPERCH_ANIM_NO = 0;
const int HARPYPERCH_ANIM_SHOOT = 1;

.float animflag;

bool harpyperch_firecheck(entity this)
{
	if (this.animflag == HARPYPERCH_ANIM_SHOOT)
		return false;
	return turret_firecheck(this);
}

void harpyperch_setnoanim(entity this)
{
	turrets_setframe(this, HARPYPERCH_ANIM_NO, false);
	this.animflag = this.frame;
}

METHOD(DryadHarpyPerch, tr_precache, void(DryadHarpyPerch this))
{
	precache_sound("turrets/harpyperch_fire.wav");
}
METHOD(DryadHarpyPerch, tr_attack, void(DryadHarpyPerch this, entity actor))
{
	defer(actor, 0.3, harpyperch_setnoanim);
	turrets_setframe(actor, HARPYPERCH_ANIM_SHOOT, false);
	actor.animflag = actor.frame;

	_sound(actor, CH_WEAPON_SINGLE, "turrets/harpyperch_fire.wav", 1, ATTN_NORM);

	entity missile = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	missile.dmg = actor.shot_dmg;
	missile.projectiledeathtype = DEATH_TRAP.m_id;
	setsize(missile, '0 0 0', '0 0 0');

	CSQCProjectile(missile, true, PROJECTILE_FEATHER, true);
}
METHOD(DryadHarpyPerch, tr_setup, void(DryadHarpyPerch this, entity actor))
{
	//actor.track_flags = TFL_TRACK_NO;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
	actor.turret_firecheckfunc = harpyperch_firecheck;

	actor.view_ofs = '0 0 48';
}
#endif // SVQC
#ifdef CSQC
METHOD(DryadHarpyPerch, tr_drawselected, void(DryadHarpyPerch this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);

	vector org;
	int tag = gettagindex(actor.tur_head, "tag_fire");
	if(tag)
		org = gettaginfo(actor.tur_head, tag);
	else
	{
		org = gettaginfo(actor.tur_head, 0) + '0 0 48';
		vector absang = fixedvectoangles2(v_forward, v_up);
		vector relang = AnglesTransform_ToAngles(absang);

		fixedmakevectors(relang);
	}

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC

// ===========
//  SLIME PIT
// ===========

#ifdef SVQC
void slimepit_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = (this.dmg) ? this.dmg : 5;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.takedamage)
	{
		if(!IS_MONSTER(toucher))
		{
			float efftime = 3;
			float curtime = StatusEffects_gettime(STATUSEFFECT_Slowness, toucher);
			if((time + efftime) > curtime)
				StatusEffects_apply(STATUSEFFECT_Slowness, toucher, time + efftime, 0);
		}

		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	if(random() < 0.5)
		_sound(this, CH_SHOTS, "turrets/slimepit_impact1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_SHOTS, "turrets/slimepit_impact2.wav", 1, ATTN_NORM);

	this.origin = this.origin - 8 * normalize(this.velocity);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	delete(this);
}

vector tuba_calc_arc(vector org, vector tgt, float ht); // saves some copy-pasta
vector slimepit_calc_velocity(entity actor, vector org, vector targ_org)
{
	//vector oldvel = normalize(actor.enemy.origin - org) * 500 + v_up * 500;

	vector tpos1 = targ_org;
	vector v = org;

	traceline(v, v + '0 0 1' * 65535, MOVE_WORLDONLY, actor);
	float h1 = 0.75 * vlen(v - trace_endpos);

	traceline(v, tpos1 + '0 0 1' * 65535, MOVE_WORLDONLY, actor);
	float h2 = 0.75 * vlen(tpos1 - v);

	return tuba_calc_arc(v, tpos1, ((h1 < h2) ? h1 : h2));
}

METHOD(DryadSlimePit, tr_precache, void(DryadSlimePit this))
{
	precache_sound("turrets/slimepit_fire1.wav");
	precache_sound("turrets/slimepit_fire2.wav");
	precache_sound("turrets/slimepit_fire3.wav");

	precache_sound("turrets/slimepit_impact1.wav");
	precache_sound("turrets/slimepit_impact2.wav");
}
METHOD(DryadSlimePit, tr_attack, void(DryadSlimePit this, entity actor))
{
	float r = random();
	if(r < 0.33)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/slimepit_fire1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/slimepit_fire2.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "turrets/slimepit_fire3.wav", 1, ATTN_NORM);

	entity newmis = launch_spike(actor, actor.tur_shotorg, '0 0 1');
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = slimepit_calc_velocity(newmis, actor.tur_shotorg, actor.tur_aimpos);
	newmis.gravity = 1;
	newmis.dmg = actor.shot_dmg;
	set_movetype(newmis, MOVETYPE_TOSS);
	settouch(newmis, slimepit_touch);
	CSQCProjectile(newmis, true, PROJECTILE_SLIME, true);
}
METHOD(DryadSlimePit, tr_setup, void(DryadSlimePit this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
	actor.monster_attack = false;

	actor.track_flags = TFL_TRACK_ROTATE; // no pitching!
	actor.target_select_flags = TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS;
	actor.target_validate_flags = actor.target_select_flags;

	actor.view_ofs = '0 0 4'; // shot origin TODO
}
#endif // SVQC
#ifdef CSQC
METHOD(DryadSlimePit, tr_precache, void(DryadSlimePit this))
{
	precache_sound("turrets/slimepit_idle.wav");
}
.float idle_finished;
METHOD(DryadSlimePit, tr_think, void(DryadSlimePit this, entity actor))
{
	if(time >= actor.idle_finished)
	{
		actor.idle_finished = time + 8.627;
		_sound(actor, CH_TRIGGER_SINGLE, "turrets/slimepit_idle.wav", 1, ATTN_NORM);
	}
}
METHOD(DryadSlimePit, tr_setup, void(DryadSlimePit this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
}
METHOD(DryadSlimePit, tr_drawselected, void(DryadSlimePit this, entity actor))
{
	float myrange = this.target_range;
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 4';

	Draw_Circle(org, myrange);
}
#endif // CSQC

// ==============
//  ANGRY NIMBUS
// ==============

#ifdef SVQC
void NimbusHome(entity this)
{
	if(!this.enemy || this.enemy.health < 1)
	{
		RandomSelection_Init();
		float myrange = (this.cnt) ? this.cnt : 256;
		FOREACH_ENTITY_RADIUS(this.origin, myrange, it.takedamage && IS_MONSTER(it) && it.health > 0,
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		this.enemy = RandomSelection_chosen_ent;
	}

	vector vtemp = (this.enemy) ? (this.enemy.origin + ('0 0 1' * this.enemy.maxs_z) + '0 0 64') : this.origin;
	if(time > this.count)
	{
		stopsound(this, CH_SHOTS_SINGLE);
		delete(this);
		return;
	}
	if(time >= this.attack_finished)
	{
		float damage = (this.dmg) ? this.dmg : 15;
		FOREACH_ENTITY_RADIUS(this.origin, 100, it.takedamage && IS_MONSTER(it) && it.health > 0,
		{
			vector org = (it.absmin + it.absmax) * 0.5;
			if(org.z > this.origin_z || it == this.owner || !Damage_ValidTarget(it, this.owner))
				continue;
			T_Damage(it, this, this.owner, damage, this.projectiledeathtype);
		});

		this.attack_finished = time + 0.25;
	}

	vector dir = normalize(vtemp - this.origin);
	this.velocity = dir * 200;
	this.nextthink = time;
	UpdateCSQCProjectile(this);
}

void Nimbus_Launch(entity this, vector org, entity targ)
{
	vector targ_org = targ.origin + ('0 0 1' * targ.maxs_z) + '0 0 64';
	vector dir = normalize(targ_org - org);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "moss_hornet";
	missile.owner = this;
	missile.projectiledeathtype = DEATH_TRAP.m_id;
	missile.clipgroup = this.clipgroup;
	missile.poisonous = true;

	missile.solid = SOLID_TRIGGER;
	set_movetype(missile, MOVETYPE_FLYMISSILE);

	setsize(missile, '0 0 0', '0 0 0');		

	setorigin(missile, org);
	missile.velocity = dir * 200;
	missile.nextthink = time;
	missile.count = time + 6;
	setthink(missile, NimbusHome);
	missile.enemy = targ;
	missile.dmg = this.shot_dmg;
	missile.cnt = 256 * turret_getpower(this.tur_level, 0.2);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, false, PROJECTILE_NIMBUS, true);
}

METHOD(DryadAngryNimbus, tr_precache, void(DryadAngryNimbus this))
{
	precache_sound("turrets/hornetsnest_swarm.wav");
}
METHOD(DryadAngryNimbus, tr_attack, void(DryadAngryNimbus this, entity actor))
{
	//turrets_setframe(actor, NANIM_SPAWN, true);
	// force a resend
	actor.SendFlags |= TNSF_ANIM;
	actor.anim_start_time = time;
	actor.frame = NANIM_SPAWN;

	actor.attack_finished = time + 2; // special handling

	Nimbus_Launch(actor, actor.tur_shotorg, actor.enemy);
}
METHOD(DryadAngryNimbus, tr_setup, void(DryadAngryNimbus this, entity actor))
{
	turrets_setframe(actor, NANIM_SPAWN, false);
	actor.attack_finished = time + 1;
}
#endif // SVQC
#ifdef CSQC
METHOD(DryadAngryNimbus, tr_precache, void(DryadAngryNimbus this))
{
	precache_sound("turrets/angrynimbus_idle.wav");
}
.float idle_finished;
METHOD(DryadAngryNimbus, tr_drawselected, void(DryadAngryNimbus this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = actor.origin + '0 0 48';
	makevectors(actor.angles);

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: circle
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
METHOD(DryadAngryNimbus, tr_think, void(DryadAngryNimbus this, entity actor))
{
	if(time >= actor.idle_finished)
	{
		actor.idle_finished = time + 16.463;
		_sound(actor, CH_TRIGGER_SINGLE, "turrets/angrynimbus_idle.wav", 1, ATTN_NORM);
	}

	entity head = actor.tur_head;
	if(time < head.anim_finished)
	{
		CSQCModel_InterpolateAnimation_Do(head);
		return;
	}
	head.anim_finished = time + 0.1;

	vector anim = '0 18 0';
	bool doreset = false;

	if(head.clientframe != actor.frame)
	{
		head.clientframe = actor.frame;
		doreset = true;
	}

	switch(head.clientframe)
	{
		case NANIM_IDLE: anim = '0 18 0'; break;
		case NANIM_SHOOT: anim = '19 28 0'; break;
		case NANIM_SPAWN: anim = '29 40 0'; break;
		case NANIM_WIN: anim = '41 56 0'; break;
		case NANIM_LOSE: anim = '57 74 0'; break;
	}

	int nframe = head.frame + 1;

	if(nframe < anim.x || doreset)
		nframe = anim.x;

	// at the final frame, go back to idle animation
	if(!doreset && nframe > anim.y)
	{
		actor.frame = NANIM_IDLE; // updates next frame and until server ping
		nframe = 0;
	}

	if(head.frame != nframe)
	{
		CSQCModel_InterpolateAnimation_1To2_PreNote(head, BIT(23));
		head.frame = nframe;
		CSQCModel_InterpolateAnimation_1To2_Note(head, BIT(23), true);
	}
	CSQCModel_InterpolateAnimation_Do(head);
}
#endif // CSQC
