#ifndef ENFORCER_H
#define ENFORCER_H

#ifndef MENUQC
MODEL(MON_ENFORCER, "models/monsters/enforcer.mdl");
#endif

CLASS(Enforcer, Monster)
    ATTRIB(Enforcer, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Enforcer, mins, vector, '-16 -16 -24');
    ATTRIB(Enforcer, maxs, vector, '16 16 40');
#ifndef MENUQC
    ATTRIB(Enforcer, m_model, Model, MDL_MON_ENFORCER);
#endif
    ATTRIB(Enforcer, netname, string, "enforcer");
    ATTRIB(Enforcer, monster_name, string, _("Enforcer"));
ENDCLASS(Enforcer)

REGISTER_MONSTER(ENFORCER, NEW(Enforcer)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_enforcer_health = 200;
float autocvar_g_monster_enforcer_damageforcescale = 0.7;
float autocvar_g_monster_enforcer_attack_plasma_damage = 25;
float autocvar_g_monster_enforcer_attack_plasma_edgedamage = 20;
float autocvar_g_monster_enforcer_attack_plasma_force = 50;
float autocvar_g_monster_enforcer_attack_plasma_radius = 100;
float autocvar_g_monster_enforcer_attack_plasma_spread = 0;
float autocvar_g_monster_enforcer_attack_plasma_speed = 1500;
float autocvar_g_monster_enforcer_attack_plasma_lifetime = 7;
float autocvar_g_monster_enforcer_attack_plasma_shots = 2;
float autocvar_g_monster_enforcer_attack_plasma_delay = 0.7;
float autocvar_g_monster_enforcer_speed_stop = 100;
float autocvar_g_monster_enforcer_speed_run = 150;
float autocvar_g_monster_enforcer_speed_walk = 60;

/*
const float enforcer_anim_stand			= 0;
const float enforcer_anim_walk			= 1;
const float enforcer_anim_run			= 2;
const float enforcer_anim_attack		= 3;
const float enforcer_anim_death1		= 4;
const float enforcer_anim_death2		= 5;
const float enforcer_anim_pain1			= 6;
const float enforcer_anim_pain2			= 7;
const float enforcer_anim_pain3			= 8;
const float enforcer_anim_pain4			= 9;
*/

void M_Enforcer_Attack_Plasma_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	sound (self, CH_WEAPON_A, SND(TAG_IMPACT), VOL_BASE, ATTEN_NORM);
	Send_Effect(EFFECT_ELECTRO_IMPACT, self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, autocvar_g_monster_enforcer_attack_plasma_damage, autocvar_g_monster_enforcer_attack_plasma_edgedamage, 
				  autocvar_g_monster_enforcer_attack_plasma_radius, world, world, autocvar_g_monster_enforcer_attack_plasma_force, self.projectiledeathtype, other);

	remove (self);
}

void M_Enforcer_Attack_Plasma_Touch()
{
	PROJECTILE_TOUCH;
	M_Enforcer_Attack_Plasma_Explode();
}

void M_Enforcer_Attack_Plasma()
{
	entity gren;

	sound (self, CH_WEAPON_A, SND(LASERGUN_FIRE), VOL_BASE, ATTEN_NORM);

	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	vector org = self.origin + v_forward * 14 + '0 0 5' + v_right * -14;

	makevectors(self.angles);

	pointparticles(particleeffectnum("electro_muzzleflash"), org, dir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = true;
	gren.bot_dodgerating = autocvar_g_monster_enforcer_attack_plasma_damage;
	gren.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_ENFORCER_PLASMA.m_id;
	setorigin(gren, org);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_monster_enforcer_attack_plasma_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = M_Enforcer_Attack_Plasma_Explode;
	gren.touch = M_Enforcer_Attack_Plasma_Touch;

	gren.missile_flags = MIF_SPLASH;
	W_SetupProjVelocity_Explicit(gren, dir, v_up, autocvar_g_monster_enforcer_attack_plasma_speed, 0, 0, autocvar_g_monster_enforcer_attack_plasma_spread, false);

	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, true, PROJECTILE_ELECTRO, true);

	MUTATOR_CALLHOOK(EditProjectile, self, gren);

	self.attack_finished_single[0] = time + autocvar_g_monster_enforcer_attack_plasma_delay;
}

bool M_Enforcer_Attack(int attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			setanim(self, self.anim_shoot, true, true, true);
			self.attack_finished_single[0] = time + 0.7;
			self.anim_finished = time + 0.7 * autocvar_g_monster_enforcer_attack_plasma_shots;
			self.state = MONSTER_ATTACK_RANGED;
			Monster_Delay(autocvar_g_monster_enforcer_attack_plasma_shots - 1, 0.3, 0.4, M_Enforcer_Attack_Plasma);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_enforcer) { Monster_Spawn(MON_ENFORCER.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Enforcer, mr_think, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Enforcer, mr_pain, bool(Monster thismon))
		{
			vector anim;
			switch(floor(random() * 5))
			{
				default:
				case 1: anim = self.anim_pain1; self.pain_finished = time + 0.3; break;
				case 2: anim = self.anim_pain2; self.pain_finished = time + 0.4; break;
				case 3: anim = self.anim_pain3; self.pain_finished = time + 0.7; break;
				case 4: anim = self.anim_pain4; self.pain_finished = time + 1; break;
			}
			setanim(self, anim, true, true, false);
			return true;
		}
		METHOD(Enforcer, mr_death, bool(Monster thismon))
		{
			SELFPARAM();
			setanim(self, ((random() > 0.5) ? self.anim_die1 : self.anim_die2), false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Enforcer, mr_anim, bool(Monster thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '4 1 0.5', none); // 2 seconds
			self.anim_die2 = animfixfps(self, '5 1 0.5', none); // 2 seconds
			self.anim_walk = animfixfps(self, '1 1 1', none);
			self.anim_idle = animfixfps(self, '0 1 1', none);
			self.anim_pain1 = animfixfps(self, '6 1 2', none); // 0.5 seconds
			self.anim_pain2 = animfixfps(self, '7 1 2', none); // 0.5 seconds
			self.anim_pain3 = animfixfps(self, '8 1 2', none); // 0.5 seconds
			self.anim_pain4 = animfixfps(self, '9 1 2', none); // 0.5 seconds
			self.anim_shoot = animfixfps(self, '3 1 5', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '2 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_cells);
		METHOD(Enforcer, mr_setup, bool(Monster thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_enforcer_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_enforcer_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_enforcer_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_enforcer_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_enforcer_damageforcescale); }

			self.monster_loot = spawnfunc_item_cells;
			self.weapon = WEP_CRYLINK.m_id;

			self.hitplotfh = -1;

			return true;
		}
		METHOD(Enforcer, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
