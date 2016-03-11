#ifndef ENFORCER_H
#define ENFORCER_H

#ifndef MENUQC
MODEL(MON_ENFORCER, M_Model("enforcer.mdl"));

MSG_INFO_NOTIF(DEATH_SELF_MON_ENFORCER_PLASMA,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         _("^BG%s^K1 was blasted to death by an Enforcer%s%s"), "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_ENFORCER_PLASMA,                1,  NULL,           INFO_DEATH_SELF_MON_ENFORCER_PLASMA,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_ENFORCER_PLASMA,            				DEATH_SELF_MON_ENFORCER_PLASMA,            	DEATH_MURDER_MONSTER,           		"monster")
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

	sound (self, CH_WEAPON_A, SND_TAG_IMPACT, VOL_BASE, ATTEN_NORM);
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

void M_Enforcer_Attack_Plasma(entity this)
{
	sound (this, CH_WEAPON_A, SND_LASERGUN_FIRE, VOL_BASE, ATTEN_NORM);

	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
	vector org = this.origin + v_forward * 14 + '0 0 5' + v_right * -14;

	makevectors(this.angles);

	Send_Effect(EFFECT_ELECTRO_MUZZLEFLASH, org, dir * 1000, 1);

	entity gren = spawn ();
	gren.owner = gren.realowner = this;
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

	MUTATOR_CALLHOOK(EditProjectile, this, gren);

	this.attack_finished_single[0] = time + autocvar_g_monster_enforcer_attack_plasma_delay;
}

bool M_Enforcer_Attack(int attack_type, entity actor, entity targ)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			setanim(actor, actor.anim_shoot, true, true, true);
			actor.attack_finished_single[0] = time + 0.7;
			actor.anim_finished = time + 0.7 * autocvar_g_monster_enforcer_attack_plasma_shots;
			actor.state = MONSTER_ATTACK_RANGED;
			Monster_Delay(actor, autocvar_g_monster_enforcer_attack_plasma_shots - 1, 0.4, M_Enforcer_Attack_Plasma);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_enforcer) { Monster_Spawn(this, MON_ENFORCER.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Enforcer, mr_think, bool(Monster thismon, entity actor))
		{
			return true;
		}
		METHOD(Enforcer, mr_pain, bool(Monster thismon, entity actor))
		{
			vector anim;
			switch(floor(random() * 5))
			{
				default:
				case 1: anim = actor.anim_pain1; actor.pain_finished = time + 0.3; break;
				case 2: anim = actor.anim_pain2; actor.pain_finished = time + 0.4; break;
				case 3: anim = actor.anim_pain3; actor.pain_finished = time + 0.7; break;
				case 4: anim = actor.anim_pain4; actor.pain_finished = time + 1; break;
			}
			setanim(actor, anim, true, true, false);
			return true;
		}
		METHOD(Enforcer, mr_death, bool(Monster thismon, entity actor))
		{
			setanim(actor, ((random() > 0.5) ? actor.anim_die1 : actor.anim_die2), false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Enforcer, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '4 1 0.5', none); // 2 seconds
			actor.anim_die2 = animfixfps(actor, '5 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '1 1 1', none);
			actor.anim_idle = animfixfps(actor, '0 1 1', none);
			actor.anim_pain1 = animfixfps(actor, '6 1 2', none); // 0.5 seconds
			actor.anim_pain2 = animfixfps(actor, '7 1 2', none); // 0.5 seconds
			actor.anim_pain3 = animfixfps(actor, '8 1 2', none); // 0.5 seconds
			actor.anim_pain4 = animfixfps(actor, '9 1 2', none); // 0.5 seconds
			actor.anim_shoot = animfixfps(actor, '3 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '2 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_cells);
		METHOD(Enforcer, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_enforcer_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_enforcer_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_enforcer_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_enforcer_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_enforcer_damageforcescale); }

			actor.monster_loot = spawnfunc_item_cells;
			actor.weapon = WEP_CRYLINK.m_id;
			actor.monster_attackfunc = M_Enforcer_Attack;

			return true;
		}
		METHOD(Enforcer, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
