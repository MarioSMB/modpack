#ifndef OGRE_H
#define OGRE_H

#ifndef MENUQC
MODEL(MON_OGRE, M_Model("ogre.mdl"));

MSG_INFO_NOTIF(DEATH_SELF_MON_OGRE_MACHINEGUN,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 was nailed by an Ogre%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_OGRE_MACHINEGUN,                1,  NULL,           INFO_DEATH_SELF_MON_OGRE_MACHINEGUN,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_OGRE_MACHINEGUN,            			DEATH_SELF_MON_OGRE_MACHINEGUN,         DEATH_MURDER_MONSTER,           	"monster")

MSG_INFO_NOTIF(DEATH_SELF_MON_OGRE_GRENADE,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 was blown up by an Ogre%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_OGRE_GRENADE,                1,  NULL,           INFO_DEATH_SELF_MON_OGRE_GRENADE,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_OGRE_GRENADE,            			DEATH_SELF_MON_OGRE_GRENADE,            DEATH_MURDER_MONSTER,           	"monster")

MSG_INFO_NOTIF(DEATH_SELF_MON_OGRE_MELEE,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 was chopped into bits by an Ogre%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_OGRE_MELEE,                1,  NULL,           INFO_DEATH_SELF_MON_OGRE_MELEE,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_OGRE_MELEE,            				DEATH_SELF_MON_OGRE_MELEE,            	DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Ogre, Monster)
    ATTRIB(Ogre, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_HIDDEN | MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Ogre, mins, vector, '-36 -36 -20');
    ATTRIB(Ogre, maxs, vector, '36 36 50');
#ifndef MENUQC
    ATTRIB(Ogre, m_model, Model, MDL_MON_OGRE);
#endif
    ATTRIB(Ogre, netname, string, "ogre");
    ATTRIB(Ogre, monster_name, string, "Ogre");
ENDCLASS(Ogre)

REGISTER_MONSTER(OGRE, NEW(Ogre)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

.vector anim_pain3;
.vector anim_pain4;
.vector anim_pain5;

#ifdef SVQC

AUTOCVAR(g_monster_ogre_health, float, 320, "");
AUTOCVAR(g_monster_ogre_damageforcescale, float, 0.4, "");
AUTOCVAR(g_monster_ogre_attack_machinegun_spread, float, 0.04, "");
AUTOCVAR(g_monster_ogre_attack_machinegun_solidpenetration, float, 13.1, "");
AUTOCVAR(g_monster_ogre_attack_machinegun_damage, float, 10, "");
AUTOCVAR(g_monster_ogre_attack_machinegun_force, float, 5, "");
AUTOCVAR(g_monster_ogre_attack_grenade_damage, float, 50, "");
AUTOCVAR(g_monster_ogre_attack_grenade_edgedamage, float, 20, "");
AUTOCVAR(g_monster_ogre_attack_grenade_radius, float, 120, "");
AUTOCVAR(g_monster_ogre_attack_grenade_speed, float, 1000, "");
AUTOCVAR(g_monster_ogre_attack_grenade_speed_up, float, 120, "");
AUTOCVAR(g_monster_ogre_attack_grenade_speed_z, float, 0, "");
AUTOCVAR(g_monster_ogre_attack_grenade_spread, float, 0, "");
AUTOCVAR(g_monster_ogre_attack_grenade_force, float, 150, "");
AUTOCVAR(g_monster_ogre_attack_grenade_bouncefactor, float, 0.3, "");
AUTOCVAR(g_monster_ogre_attack_grenade_bouncestop, float, 0.75, "");
AUTOCVAR(g_monster_ogre_attack_grenade_lifetime, float, 3, "");
AUTOCVAR(g_monster_ogre_attack_grenade_health, float, 30, "");
AUTOCVAR(g_monster_ogre_attack_grenade_damageforcescale, float, 4, "");
AUTOCVAR(g_monster_ogre_attack_melee_damage, float, 45, "");
AUTOCVAR(g_monster_ogre_attack_melee_nonplayerdamage, float, 30, "");
AUTOCVAR(g_monster_ogre_attack_melee_delay, float, 0.35, "");
AUTOCVAR(g_monster_ogre_attack_melee_time, float, 0.25, "");
AUTOCVAR(g_monster_ogre_attack_melee_range, float, 120, "");
AUTOCVAR(g_monster_ogre_attack_melee_traces, float, 10, "");
AUTOCVAR(g_monster_ogre_attack_melee_swing_up, float, 40, "");
AUTOCVAR(g_monster_ogre_attack_melee_swing_side, float, 130, "");
AUTOCVAR(g_monster_ogre_speed_stop, float, 100, "");
AUTOCVAR(g_monster_ogre_speed_run, float, 120, "");
AUTOCVAR(g_monster_ogre_speed_walk, float, 60, "");

/*
const float ogre_anim_idle 			= 0;
const float ogre_anim_walk 			= 1;
const float ogre_anim_run 			= 2;
const float ogre_anim_swing 		= 3;
const float ogre_anim_smash 		= 4;
const float ogre_anim_shoot 		= 5;
const float ogre_anim_pain1 		= 6;
const float ogre_anim_pain2 		= 7;
const float ogre_anim_pain3 		= 8;
const float ogre_anim_pain4 		= 9;
const float ogre_anim_pain5 		= 10;
const float ogre_anim_death1 		= 11;
const float ogre_anim_death2 		= 12;
const float ogre_anim_pull 			= 13;
*/

void M_Ogre_Attack_MachineGun(entity this)
{
	vector dir = normalize(this.enemy.origin - this.origin);
	vector org = this.origin + this.view_ofs + v_forward * 14;
	sound (this, CH_WEAPON_A, SND_UZI_FIRE, VOL_BASE, ATTEN_NORM);

	.entity weaponentity = weaponentities[0];
	fireBullet(this, weaponentity, org, dir, autocvar_g_monster_ogre_attack_machinegun_spread, autocvar_g_monster_ogre_attack_machinegun_solidpenetration, autocvar_g_monster_ogre_attack_machinegun_damage,
			autocvar_g_monster_ogre_attack_machinegun_force, DEATH_MONSTER_OGRE_MACHINEGUN.m_id, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, org, dir * 1000, 1);

	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, this, weaponentities[0]);
}

void M_Ogre_Attack_Grenade_Explode(entity this, entity directhitentity)
{
	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;

	if(this.move_movetype == MOVETYPE_NONE)
		this.velocity = this.oldvelocity;

	sound (this, CH_WEAPON_A, SND_GRENADE_IMPACT, VOL_BASE, ATTEN_NORM);
	Send_Effect(EFFECT_GRENADE_EXPLODE, this.origin, '0 0 0', 1);
	RadiusDamage (this, this.realowner, autocvar_g_monster_ogre_attack_grenade_damage, autocvar_g_monster_ogre_attack_grenade_edgedamage, autocvar_g_monster_ogre_attack_grenade_radius, 
				NULL, NULL, autocvar_g_monster_ogre_attack_grenade_force, this.projectiledeathtype, directhitentity);

	remove (this);
}

void M_Ogre_Attack_Grenade_Explode_use(entity this, entity actor, entity trigger)
{
	M_Ogre_Attack_Grenade_Explode(this, trigger);
}

void M_Ogre_Attack_Grenade_Damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
	if (this.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, this.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	this.health -= damage;

	if (this.health <= 0)
		W_PrepareExplosionByDamage(this, attacker, adaptor_think2use);
}

void M_Ogre_Attack_Grenade_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	if (toucher.takedamage == DAMAGE_AIM)
	{
		this.use(this, NULL, toucher);
		return;
	}

	spamsound(this, CH_SHOTS, SND_GRENADE_BOUNCE_RANDOM(), VOL_BASE, ATTEN_NORM);
	//this.projectiledeathtype |= HITTYPE_BOUNCE;
}

void M_Ogre_Attack_Grenade(entity this)
{
	sound (this, CH_WEAPON_A, SND_GRENADE_FIRE, VOL_BASE, ATTEN_NORM);

	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
	vector org = this.origin + v_forward * 14 + '0 0 30' + v_right * -14;

	makevectors(this.angles);

	Send_Effect(EFFECT_GRENADE_MUZZLEFLASH, org, dir * 1000, 1);

	entity gren = spawn ();
	gren.owner = gren.realowner = this;
	gren.classname = "grenade";
	gren.bot_dodge = true;
	gren.bot_dodgerating = autocvar_g_monster_ogre_attack_grenade_damage;
	set_movetype(gren, MOVETYPE_BOUNCE);
	gren.bouncefactor = autocvar_g_monster_ogre_attack_grenade_bouncefactor;
	gren.bouncestop = autocvar_g_monster_ogre_attack_grenade_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_OGRE_GRENADE.m_id;
	setorigin(gren, org);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_monster_ogre_attack_grenade_lifetime;
	setthink(gren, adaptor_think2use_hittype_splash);
	gren.use = M_Ogre_Attack_Grenade_Explode_use;
	settouch(gren, M_Ogre_Attack_Grenade_Touch);

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_monster_ogre_attack_grenade_health;
	gren.damageforcescale = autocvar_g_monster_ogre_attack_grenade_damageforcescale;
	gren.event_damage = M_Ogre_Attack_Grenade_Damage;
	gren.damagedbycontents = true;
	IL_PUSH(g_damagedbycontents, gren);
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjVelocity_Explicit(gren, dir, v_up, autocvar_g_monster_ogre_attack_grenade_speed, autocvar_g_monster_ogre_attack_grenade_speed_up, autocvar_g_monster_ogre_attack_grenade_speed_z, autocvar_g_monster_ogre_attack_grenade_spread, false);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, gren);
	IL_PUSH(g_bot_dodge, gren);

	CSQCProjectile(gren, true, PROJECTILE_GRENADE_BOUNCING, true);

	MUTATOR_CALLHOOK(EditProjectile, this, gren);

	this.attack_finished_single[0] = time + 0.7;
	this.state = 0;
}

.float ogre_swing_prev;
.entity ogre_swing_alreadyhit;
void M_Ogre_Attack_Chainsaw(entity this)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player, is_monster;
	entity target_victim;
	vector targpos;

	if(!this.cnt) // set start time of melee
	{
		this.cnt = time;
	}

	makevectors(this.realowner.angles); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = autocvar_g_monster_ogre_attack_melee_time;
	swing = bound(0, (this.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * autocvar_g_monster_ogre_attack_melee_traces);

	// check to see if we can still continue, otherwise give up now
	if(IS_DEAD(this.realowner))
	{
		delete(this);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=this.ogre_swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_monster_ogre_attack_melee_traces)) * 2 - 1);

		targpos = (this.realowner.origin + this.realowner.view_ofs
			+ (v_forward * autocvar_g_monster_ogre_attack_melee_range)
			+ (v_up * swing_factor * autocvar_g_monster_ogre_attack_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_monster_ogre_attack_melee_swing_side));

		WarpZone_traceline_antilag(this, this.realowner.origin + this.realowner.view_ofs, targpos, false, this, 0);

		// draw lightning beams for debugging
		//te_lightning2(NULL, targpos, this.realowner.origin + this.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body");
		is_monster = IS_MONSTER(trace_ent);

		if((trace_fraction < 1) // if trace is good, apply the damage and remove this
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != this.ogre_swing_alreadyhit)
			&& ((is_player || is_monster) || autocvar_g_monster_ogre_attack_melee_nonplayerdamage))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player || is_monster) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (autocvar_g_monster_ogre_attack_melee_damage * min(1, swing_factor + 1));
			else
				swing_damage = (autocvar_g_monster_ogre_attack_melee_nonplayerdamage * min(1, swing_factor + 1));

			//print(strcat(this.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, this.realowner, this.realowner,
				swing_damage, DEATH_MONSTER_OGRE_MELEE.m_id,
				this.realowner.origin + this.realowner.view_ofs,
				v_forward * 1);

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			this.ogre_swing_alreadyhit = target_victim;
			continue; // move along to next trace
		}
	}

	if(time >= this.cnt + meleetime)
	{
		// melee is finished
		setanim(this.realowner, this.realowner.anim_idle, true, false, false);
		delete(this);
		return;
	}
	else
	{
		// set up next frame
		this.ogre_swing_prev = i;
		this.nextthink = time;
	}
}

bool M_Ogre_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			vector vdir = normalize(targ.origin - actor.origin);

			if(vdir_z > 0.7)
			{
				actor.attack_finished_single[0] = time + 1.2;
				setanim(actor, actor.anim_pain1, true, true, false);
				actor.state = MONSTER_ATTACK_RANGED;
				Monster_Delay(actor, 2, 0.4, M_Ogre_Attack_MachineGun);
				return 2;
			}
			entity meleetemp;
			meleetemp = spawn();
			meleetemp.realowner = actor;
			setthink(meleetemp, M_Ogre_Attack_Chainsaw);
			meleetemp.nextthink = time + autocvar_g_monster_ogre_attack_melee_delay;
			actor.attack_finished_single[0] = time + autocvar_g_monster_ogre_attack_melee_time + autocvar_g_monster_ogre_attack_melee_delay + 0.7;
			actor.anim_finished = actor.attack_finished_single[0];
			actor.state = MONSTER_ATTACK_MELEE;
			setanim(actor, actor.anim_melee1, true, true, false);

			return true;
		}
		case MONSTER_ATTACK_RANGED:
		{
			Monster_Delay(actor, 0, 0.5, M_Ogre_Attack_Grenade);
			actor.state = MONSTER_ATTACK_RANGED;
			actor.attack_finished_single[0] = time + 1;
			actor.anim_finished = time + 0.5;
			setanim(actor, actor.anim_pain1, true, true, false);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_ogre) { Monster_Spawn(this, true, MON_OGRE.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Ogre, mr_think, bool(Monster thismon, entity actor))
		{
			return true;
		}
		METHOD(Ogre, mr_pain, float(Monster thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			vector anim;
			switch(floor(random() * 6))
			{
				default:
				case 1: anim = actor.anim_pain1; actor.anim_finished = time + 0.4; break;
				case 2: anim = actor.anim_pain2; actor.anim_finished = time + 0.2; break;
				case 3: anim = actor.anim_pain3; actor.anim_finished = time + 0.5; break;
				case 4: anim = actor.anim_pain4; actor.anim_finished = time + 1.5; break;
				case 5: anim = actor.anim_pain5; actor.anim_finished = time + 1.4; break;
			}
			setanim(actor, anim, true, true, true);
			return damage_take;
		}
		METHOD(Ogre, mr_death, bool(Monster thismon, entity actor))
		{
			setanim(actor, ((random() > 0.5) ? actor.anim_die1 : actor.anim_die2), false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Ogre, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '11 1 0.5', none); // 2 seconds
			actor.anim_die2 = animfixfps(actor, '12 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '1 1 1', none);
			actor.anim_idle = animfixfps(actor, '0 1 1', none);
			actor.anim_pain1 = animfixfps(actor, '6 1 2', none); // 0.5 seconds
			actor.anim_pain2 = animfixfps(actor, '7 1 2', none); // 0.5 seconds
			actor.anim_pain3 = animfixfps(actor, '8 1 2', none); // 0.5 seconds
			actor.anim_pain4 = animfixfps(actor, '9 1 2', none); // 0.5 seconds
			actor.anim_pain5 = animfixfps(actor, '10 1 2', none); // 0.5 seconds
			actor.anim_melee1 = animfixfps(actor, '3 1 5', none); // analyze models and set framerate
			actor.anim_melee2 = animfixfps(actor, '4 1 5', none); // analyze models and set framerate
			actor.anim_shoot = animfixfps(actor, '5 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '2 1 1', none);
			actor.anim_draw = animfixfps(actor, '13 1 1', none);
			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		METHOD(Ogre, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_ogre_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_ogre_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_ogre_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_ogre_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_ogre_damageforcescale); }

			actor.monster_loot = ITEM_Rockets;
			actor.weapon = WEP_MACHINEGUN.m_id;
			setanim(actor, actor.anim_draw, false, true, true);
			actor.spawn_time = actor.animstate_endtime;
			actor.spawnshieldtime = actor.spawn_time;
			actor.monster_attackfunc = M_Ogre_Attack;

			return true;
		}
		METHOD(Ogre, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
