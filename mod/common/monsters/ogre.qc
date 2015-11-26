#ifndef OGRE_H
#define OGRE_H

#ifndef MENUQC
MODEL(MON_OGRE, M_Model("ogre.mdl"));

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_OGRE_MACHINEGUN,          2, 1, "s1 s2loc spree_lost", "s1",      "notify_death",         			_("^BG%s^K1 was nailed by an Ogre%s%s"), "")
MSG_MULTI_NOTIF(1, DEATH_SELF_MON_OGRE_MACHINEGUN,              NO_MSG,        							INFO_DEATH_SELF_MON_OGRE_MACHINEGUN,CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_OGRE_MACHINEGUN,            			DEATH_SELF_MON_OGRE_MACHINEGUN,         DEATH_MURDER_MONSTER,           	"monster")

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_OGRE_GRENADE,             2, 1, "s1 s2loc spree_lost", "s1",      "notify_death",         			_("^BG%s^K1 was blown up by an Ogre%s%s"), "")
MSG_MULTI_NOTIF(1, DEATH_SELF_MON_OGRE_GRENADE,                 NO_MSG,        							INFO_DEATH_SELF_MON_OGRE_GRENADE,   CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_OGRE_GRENADE,            			DEATH_SELF_MON_OGRE_GRENADE,            DEATH_MURDER_MONSTER,           	"monster")

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_OGRE_MELEE,            	2, 1, "s1 s2loc spree_lost", "s1",      "notify_death",         			_("^BG%s^K1 was chopped into bits by an Ogre%s%s"), "")
MSG_MULTI_NOTIF(1, DEATH_SELF_MON_OGRE_MELEE,                  	NO_MSG,        							INFO_DEATH_SELF_MON_OGRE_MELEE,     CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_OGRE_MELEE,            				DEATH_SELF_MON_OGRE_MELEE,            	DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Ogre, Monster)
    ATTRIB(Ogre, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Ogre, mins, vector, '-36 -36 -20');
    ATTRIB(Ogre, maxs, vector, '36 36 50');
#ifndef MENUQC
    ATTRIB(Ogre, m_model, Model, MDL_MON_OGRE);
#endif
    ATTRIB(Ogre, netname, string, "ogre");
    ATTRIB(Ogre, monster_name, string, _("Ogre"));
ENDCLASS(Ogre)

REGISTER_MONSTER(OGRE, NEW(Ogre)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_ogre_health = 320;
float autocvar_g_monster_ogre_damageforcescale = 0.4;
float autocvar_g_monster_ogre_attack_machinegun_spread = 0.04;
float autocvar_g_monster_ogre_attack_machinegun_solidpenetration = 13.1;
float autocvar_g_monster_ogre_attack_machinegun_damage = 10;
float autocvar_g_monster_ogre_attack_machinegun_force = 5;
float autocvar_g_monster_ogre_attack_grenade_damage = 50;
float autocvar_g_monster_ogre_attack_grenade_edgedamage = 20;
float autocvar_g_monster_ogre_attack_grenade_radius = 120;
float autocvar_g_monster_ogre_attack_grenade_speed = 1000;
float autocvar_g_monster_ogre_attack_grenade_speed_up = 120;
float autocvar_g_monster_ogre_attack_grenade_speed_z = 0;
float autocvar_g_monster_ogre_attack_grenade_spread = 0;
float autocvar_g_monster_ogre_attack_grenade_force = 150;
float autocvar_g_monster_ogre_attack_grenade_bouncefactor = 0.3;
float autocvar_g_monster_ogre_attack_grenade_bouncestop = 0.75;
float autocvar_g_monster_ogre_attack_grenade_lifetime = 3;
float autocvar_g_monster_ogre_attack_grenade_health = 30;
float autocvar_g_monster_ogre_attack_grenade_damageforcescale = 4;
float autocvar_g_monster_ogre_attack_melee_damage = 45;
float autocvar_g_monster_ogre_attack_melee_nonplayerdamage = 30;
float autocvar_g_monster_ogre_attack_melee_delay = 0.35;
float autocvar_g_monster_ogre_attack_melee_time = 0.25;
float autocvar_g_monster_ogre_attack_melee_range = 120;
float autocvar_g_monster_ogre_attack_melee_traces = 10;
float autocvar_g_monster_ogre_attack_melee_swing_up = 40;
float autocvar_g_monster_ogre_attack_melee_swing_side = 130;
float autocvar_g_monster_ogre_speed_stop = 100;
float autocvar_g_monster_ogre_speed_run = 120;
float autocvar_g_monster_ogre_speed_walk = 60;

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

void M_Ogre_Attack_MachineGun()
{
	vector dir = normalize(self.enemy.origin - self.origin);
	vector org = self.origin + self.view_ofs + v_forward * 14;
	sound (self, CH_WEAPON_A, SND_UZI_FIRE, VOL_BASE, ATTEN_NORM);

	fireBullet(org, dir, autocvar_g_monster_ogre_attack_machinegun_spread, autocvar_g_monster_ogre_attack_machinegun_solidpenetration, autocvar_g_monster_ogre_attack_machinegun_damage, autocvar_g_monster_ogre_attack_machinegun_force, DEATH_MONSTER_OGRE_MACHINEGUN.m_id, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, org, dir * 1000, 1);

	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);
}

void M_Ogre_Attack_Grenade_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	sound (self, CH_WEAPON_A, SND_GRENADE_IMPACT, VOL_BASE, ATTEN_NORM);
	Send_Effect(EFFECT_GRENADE_EXPLODE, self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, autocvar_g_monster_ogre_attack_grenade_damage, autocvar_g_monster_ogre_attack_grenade_edgedamage, autocvar_g_monster_ogre_attack_grenade_radius, world, world, autocvar_g_monster_ogre_attack_grenade_force, self.projectiledeathtype, other);

	remove (self);
}

void M_Ogre_Attack_Grenade_Damage(entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health -= damage;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void M_Ogre_Attack_Grenade_Touch()
{
	PROJECTILE_TOUCH;

	if (other.takedamage == DAMAGE_AIM)
	{
		self.use();
		return;
	}

	spamsound(self, CH_SHOTS, SND(GRENADE_BOUNCE_RANDOM()), VOL_BASE, ATTEN_NORM);
	//self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void M_Ogre_Attack_Grenade()
{
	sound (self, CH_WEAPON_A, SND_GRENADE_FIRE, VOL_BASE, ATTEN_NORM);

	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	vector org = self.origin + v_forward * 14 + '0 0 30' + v_right * -14;

	makevectors(self.angles);

	Send_Effect(EFFECT_GRENADE_MUZZLEFLASH, org, dir * 1000, 1);

	entity gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = true;
	gren.bot_dodgerating = autocvar_g_monster_ogre_attack_grenade_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_monster_ogre_attack_grenade_bouncefactor;
	gren.bouncestop = autocvar_g_monster_ogre_attack_grenade_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_OGRE_GRENADE.m_id;
	setorigin(gren, org);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_monster_ogre_attack_grenade_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = M_Ogre_Attack_Grenade_Explode;
	gren.touch = M_Ogre_Attack_Grenade_Touch;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_monster_ogre_attack_grenade_health;
	gren.damageforcescale = autocvar_g_monster_ogre_attack_grenade_damageforcescale;
	gren.event_damage = M_Ogre_Attack_Grenade_Damage;
	gren.damagedbycontents = true;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjVelocity_Explicit(gren, dir, v_up, autocvar_g_monster_ogre_attack_grenade_speed, autocvar_g_monster_ogre_attack_grenade_speed_up, autocvar_g_monster_ogre_attack_grenade_speed_z, autocvar_g_monster_ogre_attack_grenade_spread, false);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, true, PROJECTILE_GRENADE_BOUNCING, true);

	MUTATOR_CALLHOOK(EditProjectile, self, gren);

	self.attack_finished_single[0] = time + 0.7;
	self.state = 0;
}

.float ogre_swing_prev;
.entity ogre_swing_alreadyhit;
void M_Ogre_Attack_Chainsaw()
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player, is_monster;
	entity target_victim;
	vector targpos;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time;
	}

	makevectors(self.realowner.angles); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = autocvar_g_monster_ogre_attack_melee_time;
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * autocvar_g_monster_ogre_attack_melee_traces);

	// check to see if we can still continue, otherwise give up now
	if(self.realowner.deadflag != DEAD_NO)
	{
		remove(self);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=self.ogre_swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_monster_ogre_attack_melee_traces)) * 2 - 1);

		targpos = (self.realowner.origin + self.realowner.view_ofs
			+ (v_forward * autocvar_g_monster_ogre_attack_melee_range)
			+ (v_up * swing_factor * autocvar_g_monster_ogre_attack_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_monster_ogre_attack_melee_swing_side));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, false, self, 0);

		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body");
		is_monster = IS_MONSTER(trace_ent);

		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != self.ogre_swing_alreadyhit)
			&& ((is_player || is_monster) || autocvar_g_monster_ogre_attack_melee_nonplayerdamage))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player || is_monster) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (autocvar_g_monster_ogre_attack_melee_damage * min(1, swing_factor + 1));
			else
				swing_damage = (autocvar_g_monster_ogre_attack_melee_nonplayerdamage * min(1, swing_factor + 1));

			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, self.realowner, self.realowner,
				swing_damage, DEATH_MONSTER_OGRE_MELEE.m_id,
				self.realowner.origin + self.realowner.view_ofs,
				v_forward * 1);

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			self.ogre_swing_alreadyhit = target_victim;
			continue; // move along to next trace
		}
	}

	if(time >= self.cnt + meleetime)
	{
		// melee is finished
		setanim(self.realowner, self.realowner.anim_idle, true, false, false);
		remove(self);
		return;
	}
	else
	{
		// set up next frame
		self.ogre_swing_prev = i;
		self.nextthink = time;
	}
}

bool M_Ogre_Attack(int attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			vector vdir = normalize(self.enemy.origin - self.origin);

			if(vdir_z > 0.7)
			{
				self.attack_finished_single[0] = time + 1.2;
				setanim(self, self.anim_pain1, true, true, false);
				self.state = MONSTER_ATTACK_RANGED;
				Monster_Delay(2, 0.1, 0.4, M_Ogre_Attack_MachineGun);
				return 2;
			}
			entity meleetemp;
			meleetemp = spawn();
			meleetemp.realowner = self;
			meleetemp.think = M_Ogre_Attack_Chainsaw;
			meleetemp.nextthink = time + autocvar_g_monster_ogre_attack_melee_delay;
			self.attack_finished_single[0] = time + autocvar_g_monster_ogre_attack_melee_time + autocvar_g_monster_ogre_attack_melee_delay + 0.7;
			self.anim_finished = self.attack_finished_single[0];
			self.state = MONSTER_ATTACK_MELEE;
			setanim(self, self.anim_melee1, true, true, false);

			return true;
		}
		case MONSTER_ATTACK_RANGED:
		{
			Monster_Delay(0, 0, 0.5, M_Ogre_Attack_Grenade);
			self.state = MONSTER_ATTACK_RANGED;
			self.attack_finished_single[0] = time + 1;
			self.anim_finished = time + 0.5;
			setanim(self, self.anim_pain1, true, true, false);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_ogre) { Monster_Spawn(MON_OGRE.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Ogre, mr_think, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Ogre, mr_pain, bool(Monster thismon))
		{
			vector anim;
			switch(floor(random() * 6))
			{
				default:
				case 1: anim = self.anim_pain1; self.anim_finished = time + 0.4; break;
				case 2: anim = self.anim_pain2; self.anim_finished = time + 0.2; break;
				case 3: anim = self.anim_pain3; self.anim_finished = time + 0.5; break;
				case 4: anim = self.anim_pain4; self.anim_finished = time + 1.5; break;
				case 5: anim = self.anim_pain5; self.anim_finished = time + 1.4; break;
			}
			setanim(self, anim, true, true, true);
			return true;
		}
		METHOD(Ogre, mr_death, bool(Monster thismon))
		{
			SELFPARAM();
			setanim(self, ((random() > 0.5) ? self.anim_die1 : self.anim_die2), false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Ogre, mr_anim, bool(Monster thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '11 1 0.5', none); // 2 seconds
			self.anim_die2 = animfixfps(self, '12 1 0.5', none); // 2 seconds
			self.anim_walk = animfixfps(self, '1 1 1', none);
			self.anim_idle = animfixfps(self, '0 1 1', none);
			self.anim_pain1 = animfixfps(self, '6 1 2', none); // 0.5 seconds
			self.anim_pain2 = animfixfps(self, '7 1 2', none); // 0.5 seconds
			self.anim_pain3 = animfixfps(self, '8 1 2', none); // 0.5 seconds
			self.anim_pain4 = animfixfps(self, '9 1 2', none); // 0.5 seconds
			self.anim_pain5 = animfixfps(self, '10 1 2', none); // 0.5 seconds
			self.anim_melee1 = animfixfps(self, '3 1 5', none); // analyze models and set framerate
			self.anim_melee2 = animfixfps(self, '4 1 5', none); // analyze models and set framerate
			self.anim_shoot = animfixfps(self, '5 1 5', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '2 1 1', none);
			self.anim_draw = animfixfps(self, '13 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_rockets);
		METHOD(Ogre, mr_setup, bool(Monster thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_ogre_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_ogre_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_ogre_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_ogre_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_ogre_damageforcescale); }

			self.monster_loot = spawnfunc_item_rockets;
			self.weapon = WEP_MACHINEGUN.m_id;
			setanim(self, self.anim_draw, false, true, true);
			self.spawn_time = self.animstate_endtime;
			self.spawnshieldtime = self.spawn_time;
			self.monster_attackfunc = M_Ogre_Attack;

			self.hitplotfh = -1;

			return true;
		}
		METHOD(Ogre, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
