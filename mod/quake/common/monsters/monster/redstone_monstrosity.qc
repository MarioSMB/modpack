#include "redstone_monstrosity.qh"

#ifdef SVQC
const int anim_rm_awaken = 0;
const int anim_rm_idle = 10;
const int anim_rm_defeat = 26;
const int anim_rm_walk = 37;
const int anim_rm_stun = 50;
const int anim_rm_spit = 65;
const int anim_rm_lava = 86;
const int anim_rm_slam = 107;
const int anim_rm_swing = 122;
const int anim_rm_bigswing = 134;

void rm_run1(entity this);

void rm_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 3)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

void rm_idlesound(entity this)
{
	if(random() > 0.1)
		return;

	if(this.enemy)
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_VOICE, "redstone_monstrosity/idle5.wav", 1, ATTN_BOSS);
		else if(r < 0.66)
			_sound(this, CH_VOICE, "redstone_monstrosity/idle6.wav", 1, ATTN_BOSS);
		else
			_sound(this, CH_VOICE, "redstone_monstrosity/idle7.wav", 1, ATTN_BOSS);
	}
	else
	{
		float r = random();
		if(r < 0.25)
			_sound(this, CH_VOICE, "redstone_monstrosity/idle1.wav", 1, ATTN_BOSS);
		else if(r < 0.50)
			_sound(this, CH_VOICE, "redstone_monstrosity/idle2.wav", 1, ATTN_BOSS);
		else if(r < 0.75)
			_sound(this, CH_VOICE, "redstone_monstrosity/idle3.wav", 1, ATTN_BOSS);
		else
			_sound(this, CH_VOICE, "redstone_monstrosity/idle4.wav", 1, ATTN_BOSS);
	}
}

void rm_stand1(entity this)
{
	this.walkframe += 1;
	if(this.walkframe >= 16)
		this.walkframe = 0;
	set_animofs(this, anim_rm_idle, this.walkframe + 1, rm_stand1);
	ai_stand(this);

	if(this.walkframe == 0)
		rm_idlesound(this);
}

void rm_walk1(entity this)
{
	this.walkframe += 1;
	if(this.walkframe >= 13)
		this.walkframe = 0;
	set_animofs(this, anim_rm_walk, this.walkframe + 1, rm_walk1);
	ai_walk(this, bound(1, random() * 4, 4));
	if(this.frame == 40 || this.frame == 46)
		monster_footstep(this, false);

	if(this.walkframe == 0)
		rm_idlesound(this);
}

vector rm_getspot(entity this, vector org, vector dir)
{
	Monster mon = MON_REDSTONE_CUBE;
	vector rmin = mon.m_mins, rmax = mon.m_maxs;

	if(!tracetossent)
		tracetossent = new(tracetossent);

	tracetossent.owner = this;
	tracetossent.dphitcontentsmask = DPCONTENTS_SOLID;
	setsize(tracetossent, rmin, rmax);
	setorigin(tracetossent, org);

	tracetossent.velocity = dir * max(600, random() * 1000);
	tracetoss(tracetossent, this);

	if(trace_startsolid || vdist(trace_endpos - org, <, 90))
		return '0 0 0'; // error case

	return trace_endpos;
}

void rm_summon1(entity this)
{
	set_animofs(this, anim_rm_lava, this.walkframe + 1, rm_summon1);
	this.walkframe += 1;
	if(this.walkframe >= 21)
	{
		this.skin = 0;
		rm_run1(this);
		return;
	}

	if((this.walkframe + 1) == 13)
	{
		fixedmakevectors(this.angles);
		for(int j = 0; j < this.attack_summon; ++j)
		{
			float rnd = random() * 360;
			float radians = rnd * DEG2RAD;
			vector dir;
			dir.x = cos(radians);
			dir.y = sin(radians);
			dir.z = 0;
			vector org = rm_getspot(this, this.origin + '0 0 64', dir);
			if(org == '0 0 0')
				continue; // failed

			te_explosion2(org, 40, 7);
			minion_spawn(this, org, new(monster), MON_REDSTONE_CUBE);
		}
	}
}

vector tuba_calc_arc(vector org, vector tgt, float ht); // saves some copy-pasta
vector rm_calc_velocity(entity actor, vector org, vector targ_org)
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

void rm_spit_fire(entity this, entity targ)
{
	vector org = this.origin + '0 0 112';
	vector targ_org = CENTER_OR_VIEWOFS(targ);
	vector spread = vec2(randomvec() * 255);

	entity newmis = launch_spike(this, org, '0 0 1');
	newmis.projectiledeathtype = DEATH_MONSTER_REDSTONE_MONSTROSITY.m_id;
	newmis.classname = "rm_lavaball";
	newmis.dmg = 60;
	newmis.velocity = rm_calc_velocity(this, org, targ_org + spread);
	newmis.gravity = 1;
	newmis.noise = "weapons/r_exp3b.wav";
	set_movetype(newmis, MOVETYPE_TOSS);
	settouch(newmis, T_MissileTouch); // rocket explosion

	CSQCProjectile(newmis, true, PROJECTILE_RM_LAVABALL, true);
}

void rm_spit1(entity this)
{
	set_animofs(this, anim_rm_spit, this.walkframe + 1, rm_spit1);
	this.walkframe += 1;
	if(this.walkframe >= 21)
	{
		rm_run1(this);
		return;
	}
	if((this.walkframe + 1) == 8)
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_WEAPON_A, "redstone_monstrosity/shoot1.wav", 1, ATTN_BOSS);
		else if(r < 0.66)
			_sound(this, CH_WEAPON_A, "redstone_monstrosity/shoot2.wav", 1, ATTN_BOSS);
		else
			_sound(this, CH_WEAPON_A, "redstone_monstrosity/shoot3.wav", 1, ATTN_BOSS);

		FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && Damage_ValidTarget(it, this),
		{
			if(infront(this, it))
			{
				int scount = max(3, rint(random() * 6));
				for(int j = 0; j < scount; ++j)
				{
					rm_spit_fire(this, it);
				}
			}
		});
	}
}

void rm_run1(entity this)
{
	this.walkframe += 1;
	if(this.walkframe >= 13)
		this.walkframe = 0;
	set_animofs(this, anim_rm_walk, this.walkframe + 1, rm_run1);
	if(this.walkframe == 0)
	{
		if(time >= this.attack_finished && random() < 0.33)
		{
			ai_face(this);
			this.attack_finished = time + 3 + (random() * 3);
			this.walkframe = 0;
			rm_spit1(this);
			return;
		}
		if(time >= this.attack_finished && random() < 0.2)
		{
			_sound(this, CH_WEAPON_B, "redstone_monstrosity/lava2.wav", 1, ATTN_BOSS);
			this.walkframe = 0;
			this.skin = 1;
			this.attack_finished = time + 3 + (random() * 3);
			rm_summon1(this);
			return;
		}
	}
	ai_run(this, bound(3, random() * 10, 10));
	if(this.frame == 40 || this.frame == 46)
		monster_footstep(this, false);

	if(this.walkframe == 0 && random() < 0.1)
		rm_idlesound(this);
}

void rm_bigswing16(entity this) { set_animofs(this, anim_rm_bigswing, 16, rm_run1); }
void rm_bigswing15(entity this) { set_animofs(this, anim_rm_bigswing, 15, rm_bigswing16); }
void rm_bigswing14(entity this) { set_animofs(this, anim_rm_bigswing, 14, rm_bigswing15); }
void rm_bigswing13(entity this) { set_animofs(this, anim_rm_bigswing, 13, rm_bigswing14); }
void rm_bigswing12(entity this) { set_animofs(this, anim_rm_bigswing, 12, rm_bigswing13); }
void rm_bigswing11(entity this) { set_animofs(this, anim_rm_bigswing, 11, rm_bigswing12); }
void rm_bigswing10(entity this) { set_animofs(this, anim_rm_bigswing, 10, rm_bigswing11); }
void rm_bigswing9(entity this)
{
	set_animofs(this, anim_rm_bigswing, 9, rm_bigswing10);
	_sound(this, CH_SHOTS, "redstone_monstrosity/step3.wav", 1, ATTN_BOSS);
	ai_shockwave(this, '72 0 -22', 110, 170, 100, 40, DEATH_MONSTER_REDSTONE_MONSTROSITY.m_id, SND(Null));
}
void rm_bigswing8(entity this) { set_animofs(this, anim_rm_bigswing, 8, rm_bigswing9); }
void rm_bigswing7(entity this) { set_animofs(this, anim_rm_bigswing, 7, rm_bigswing8); }
void rm_bigswing6(entity this) { set_animofs(this, anim_rm_bigswing, 6, rm_bigswing7); }
void rm_bigswing5(entity this) { set_animofs(this, anim_rm_bigswing, 5, rm_bigswing6); }
void rm_bigswing4(entity this) { set_animofs(this, anim_rm_bigswing, 4, rm_bigswing5); }
void rm_bigswing3(entity this) { set_animofs(this, anim_rm_bigswing, 3, rm_bigswing4); }
void rm_bigswing2(entity this) { set_animofs(this, anim_rm_bigswing, 2, rm_bigswing3); }
void rm_bigswing1(entity this)
{
	set_animofs(this, anim_rm_bigswing, 1, rm_bigswing2);
	if(random() > 0.5)
		_sound(this, CH_VOICE, "redstone_monstrosity/arm1.wav", 1, ATTN_BOSS);
	else
		_sound(this, CH_VOICE, "redstone_monstrosity/arm2.wav", 1, ATTN_BOSS);
}

void rm_swing12(entity this) { set_animofs(this, anim_rm_swing, 12, rm_run1); }
void rm_swing11(entity this) { set_animofs(this, anim_rm_swing, 11, rm_swing12); }
void rm_swing10(entity this) { set_animofs(this, anim_rm_swing, 10, rm_swing11); }
void rm_swing9(entity this) { set_animofs(this, anim_rm_swing, 9, rm_swing10); }
void rm_swing8(entity this) { set_animofs(this, anim_rm_swing, 8, rm_swing9); }
void rm_swing7(entity this) { set_animofs(this, anim_rm_swing, 7, rm_swing8); }
void rm_swing6(entity this) { set_animofs(this, anim_rm_swing, 6, rm_swing7); }
void rm_swing5(entity this)
{
	set_animofs(this, anim_rm_swing, 5, rm_swing6);
	_sound(this, CH_SHOTS, "redstone_monstrosity/step2.wav", 1, ATTN_BOSS);
	ai_shockwave(this, '64 0 -22', 60, 170, 50, 40, DEATH_MONSTER_REDSTONE_MONSTROSITY.m_id, SND(Null));
}
void rm_swing4(entity this) { set_animofs(this, anim_rm_swing, 4, rm_swing5); }
void rm_swing3(entity this) { set_animofs(this, anim_rm_swing, 3, rm_swing4); }
void rm_swing2(entity this) { set_animofs(this, anim_rm_swing, 2, rm_swing3); }
void rm_swing1(entity this)
{
	set_animofs(this, anim_rm_swing, 1, rm_swing2);
	if(random() > 0.5)
		_sound(this, CH_VOICE, "redstone_monstrosity/arm1.wav", 1, ATTN_BOSS);
	else
		_sound(this, CH_VOICE, "redstone_monstrosity/arm2.wav", 1, ATTN_BOSS);
}

void rm_slam15(entity this) { set_animofs(this, anim_rm_slam, 15, rm_run1); }
void rm_slam14(entity this) { set_animofs(this, anim_rm_slam, 14, rm_slam15); }
void rm_slam13(entity this) { set_animofs(this, anim_rm_slam, 13, rm_slam14); }
void rm_slam12(entity this) { set_animofs(this, anim_rm_slam, 12, rm_slam13); }
void rm_slam11(entity this) { set_animofs(this, anim_rm_slam, 11, rm_slam12); }
void rm_slam10(entity this) { set_animofs(this, anim_rm_slam, 10, rm_slam11); }
void rm_slam9(entity this) { set_animofs(this, anim_rm_slam, 9, rm_slam10); }
void rm_slam8(entity this)
{
	set_animofs(this, anim_rm_slam, 8, rm_slam9);
	T_RadiusDamage(this, this, 110, DEATH_MONSTER_REDSTONE_MONSTROSITY.m_id, this);
	_sound(this, CH_SHOTS, "redstone_monstrosity/step1.wav", 1, ATTN_BOSS);
	ai_shockwave(this, '16 -68 -22', 60, 300, 300, 600, DEATH_MONSTER_REDSTONE_MONSTROSITY.m_id, SND(Null));
	ai_shockwave(this, '16 68 -22', 60, 300, 300, 600, DEATH_MONSTER_REDSTONE_MONSTROSITY.m_id, SND(Null));
}
void rm_slam7(entity this) { set_animofs(this, anim_rm_slam, 7, rm_slam8); }
void rm_slam6(entity this) { set_animofs(this, anim_rm_slam, 6, rm_slam7); }
void rm_slam5(entity this) { set_animofs(this, anim_rm_slam, 5, rm_slam6); }
void rm_slam4(entity this) { set_animofs(this, anim_rm_slam, 4, rm_slam5); }
void rm_slam3(entity this) { set_animofs(this, anim_rm_slam, 3, rm_slam4); }
void rm_slam2(entity this) { set_animofs(this, anim_rm_slam, 2, rm_slam3); }
void rm_slam1(entity this)
{
	set_animofs(this, anim_rm_slam, 1, rm_slam2);
	_sound(this, CH_VOICE, "redstone_monstrosity/shortgrowl.wav", 1, ATTN_BOSS);
}

void rm_melee(entity this)
{
	if(random() < 0.25)
		rm_slam1(this);
	else if(random() < 0.33)
		rm_bigswing1(this);
	else
		rm_swing1(this);
}

void rm_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	float r = random();
	if(r < 0.25)
		_sound(this, CH_VOICE, "redstone_monstrosity/hurt1.wav", 1, ATTN_BOSS);
	else if(r < 0.50)
		_sound(this, CH_VOICE, "redstone_monstrosity/hurt2.wav", 1, ATTN_BOSS);
	else if(r < 0.75)
		_sound(this, CH_VOICE, "redstone_monstrosity/hurt3.wav", 1, ATTN_BOSS);
	else
		_sound(this, CH_VOICE, "redstone_monstrosity/hurt4.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.2;
}

void rm_death11(entity this) { set_animofs(this, anim_rm_defeat, 11, rm_death11); CorpseThink(this); }
void rm_death10(entity this) { set_animofs(this, anim_rm_defeat, 10, rm_death11); }
void rm_death9(entity this) { set_animofs(this, anim_rm_defeat, 9, rm_death10); }
void rm_death8(entity this) { set_animofs(this, anim_rm_defeat, 8, rm_death9); }
void rm_death7(entity this) { set_animofs(this, anim_rm_defeat, 7, rm_death8); }
void rm_death6(entity this) { set_animofs(this, anim_rm_defeat, 6, rm_death7); }
void rm_death5(entity this) { set_animofs(this, anim_rm_defeat, 5, rm_death6); }
void rm_death4(entity this) { set_animofs(this, anim_rm_defeat, 4, rm_death5); }
void rm_death3(entity this) { set_animofs(this, anim_rm_defeat, 3, rm_death4); }
void rm_death2(entity this) { set_animofs(this, anim_rm_defeat, 2, rm_death3); }
void rm_death1(entity this) { set_animofs(this, anim_rm_defeat, 1, rm_death2); }

void gib_rm(entity this)
{
	sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	entity head = ThrowGib(this, this, "progs/redstone_cube.mdl", this.health);
	head.skin = 1;

	int gibcount = floor(max(6, random() * 12));
	for(int j = 0; j < gibcount; ++j)
	{
		entity gib = ThrowGib(this, this, "progs/rubble.mdl", this.health);
		gib.scale = random() * 8;
	}
}

void rm_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			gib_rm(this);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	_sound(this, CH_VOICE, "redstone_monstrosity/death.wav", 1, ATTN_BOSS);
	this.solid = SOLID_NOT;
	rm_death1(this);
}

void rm_wakeframe(entity this)
{
	this.walkframe += 1;
	this.frame = anim_rm_awaken + this.walkframe;
	this.nextthink = time + FRAME_TIME;

	if(this.walkframe >= 10)
		setthink(this, monster_start_go);
}

void rm_wake(entity this, entity actor, entity trigger)
{
	this.enemy = actor;
	this.use = func_null;

	this.walkframe = 0;
	setthink(this, rm_wakeframe);
	this.nextthink = time;

	_sound(this, CH_VOICE, "redstone_monstrosity/awaken.wav", 1, ATTN_BOSS);
}

spawnfunc(monster_redstone_monstrosity) { monster_start(this, true, MON_REDSTONE_MONSTROSITY); }
#endif // SVQC

#ifdef SVQC
METHOD(RedstoneMonstrosity, mr_setup, bool(RedstoneMonstrosity this, entity actor))
{
	TC(RedstoneMonstrosity, this);

	precache_model("progs/rubble.mdl");
	precache_model("progs/redstone_cube.mdl");

	precache_sound("redstone_monstrosity/death.wav");
	precache_sound("redstone_monstrosity/growl.wav");
	precache_sound("redstone_monstrosity/hurt1.wav");
	precache_sound("redstone_monstrosity/hurt2.wav");
	precache_sound("redstone_monstrosity/hurt3.wav");
	precache_sound("redstone_monstrosity/hurt4.wav");
	precache_sound("redstone_monstrosity/step1.wav");
	precache_sound("redstone_monstrosity/step2.wav");
	precache_sound("redstone_monstrosity/step3.wav");
	precache_sound("redstone_monstrosity/shortgrowl.wav");
	precache_sound("redstone_monstrosity/idle1.wav");
	precache_sound("redstone_monstrosity/idle2.wav");
	precache_sound("redstone_monstrosity/idle3.wav");
	precache_sound("redstone_monstrosity/idle4.wav");
	precache_sound("redstone_monstrosity/idle5.wav");
	precache_sound("redstone_monstrosity/idle6.wav");
	precache_sound("redstone_monstrosity/idle7.wav");
	precache_sound("redstone_monstrosity/awaken.wav");
	precache_sound("redstone_monstrosity/shoot1.wav");
	precache_sound("redstone_monstrosity/shoot2.wav");
	precache_sound("redstone_monstrosity/shoot3.wav");
	precache_sound("redstone_monstrosity/arm1.wav");
	precache_sound("redstone_monstrosity/arm2.wav");
	precache_sound("redstone_monstrosity/lava2.wav");
	precache_sound("weapons/r_exp3b.wav");

	actor.gibhealth = -120;
	actor.health = 2500;
	actor.th_stand = rm_stand1;
	actor.th_walk = rm_walk1;
	actor.th_run = rm_run1;
	actor.th_melee = rm_melee;
	actor.th_pain = rm_pain;
	actor.th_die = rm_die;
	actor.use = rm_wake;
	actor.skin = 0;

	actor.attack_summon = autocvar_skill + 6;

	// Custom feet sounds
	actor.stepc1 = "redstone_monstrosity/lightstep1.wav";
	actor.stepc2 = "redstone_monstrosity/lightstep2.wav";
	actor.stepc3 = "redstone_monstrosity/lightstep3.wav";
	actor.stepc4 = "redstone_monstrosity/lightstep4.wav";
	actor.stepc5 = "redstone_monstrosity/lightstep1.wav";
	precache_sound(actor.stepc1);
	precache_sound(actor.stepc2);
	precache_sound(actor.stepc3);
	precache_sound(actor.stepc4);
	actor.steptype = FS_TYPECUSTOM;

	// play a little waking animation when activated
	if(!actor.targetname || actor.targetname == "")
	if(gametype != GAMETYPE_HORDE && !actor.charmed)
		rm_wake(actor, actor.enemy, NULL);

	return true;
}
METHOD(RedstoneMonstrosity, mr_sight, bool(RedstoneMonstrosity this, entity actor))
{
	TC(RedstoneMonstrosity, this);

	_sound(actor, CH_VOICE, "redstone_monstrosity/growl.wav", 1, ATTN_BOSS);

	return true;
}
#endif
