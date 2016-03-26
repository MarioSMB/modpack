#ifndef AFRIT_H
#define AFRIT_H

#ifndef MENUQC
MODEL(MON_AFRIT, M_Model("afrit.mdl"));

MSG_INFO_NOTIF(DEATH_SELF_MON_AFRIT,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         _("^BG%s^K1 was fireballed by an Afrit%s%s"), "")

MSG_MULTI_NOTIF(DEATH_SELF_MON_AFRIT,                1,  NULL,           INFO_DEATH_SELF_MON_AFRIT,               CENTER_DEATH_SELF_MONSTER)

REGISTER_DEATHTYPE(MONSTER_AFRIT,          DEATH_SELF_MON_AFRIT,          DEATH_MURDER_MONSTER,           "monster")
#endif

CLASS(Afrit, Monster)
    ATTRIB(Afrit, spawnflags, int, MONSTER_TYPE_FLY | MON_FLAG_RANGED | MONSTER_SIZE_QUAKE);
    ATTRIB(Afrit, mins, vector, '-16 -16 -24');
    ATTRIB(Afrit, maxs, vector, '16 16 24');
#ifndef MENUQC
    ATTRIB(Afrit, m_model, Model, MDL_MON_AFRIT);
#endif
    ATTRIB(Afrit, netname, string, "afrit");
    ATTRIB(Afrit, monster_name, string, _("Afrit"));
ENDCLASS(Afrit)

REGISTER_MONSTER(AFRIT, NEW(Afrit)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_afrit_health = 400;
float autocvar_g_monster_afrit_damageforcescale = 0.3;
float autocvar_g_monster_afrit_attack_fireball_damage = 20;
float autocvar_g_monster_afrit_attack_fireball_edgedamage = 15;
float autocvar_g_monster_afrit_attack_fireball_damagetime = 2;
float autocvar_g_monster_afrit_attack_fireball_force = 50;
float autocvar_g_monster_afrit_attack_fireball_radius = 120;
float autocvar_g_monster_afrit_attack_fireball_speed = 1200;
float autocvar_g_monster_afrit_speed_stop = 300;
float autocvar_g_monster_afrit_speed_run = 120;
float autocvar_g_monster_afrit_speed_walk = 40;

/*
const float afrit_anim_sleep	= 0;
const float afrit_anim_getup	= 1;
const float afrit_anim_fly		= 2;
const float afrit_anim_pain		= 3;
const float afrit_anim_attack	= 4;
const float afrit_anim_die1		= 5;
const float afrit_anim_die2		= 6;
*/

.float afrit_targetrange_backup;
.float afrit_targetcheck_delay;

void M_Afrit_Attack_Fireball_Explode()
{SELFPARAM();
	entity e;
	if(self)
	{
		Send_Effect(EFFECT_FIREBALL_EXPLODE, self.origin, '0 0 0', 1);

		RadiusDamage(self, self.realowner, (autocvar_g_monster_afrit_attack_fireball_damage), (autocvar_g_monster_afrit_attack_fireball_edgedamage), 
					(autocvar_g_monster_afrit_attack_fireball_force), world, world, (autocvar_g_monster_afrit_attack_fireball_radius), self.projectiledeathtype, world);

		for(e = world; (e = findfloat(e, takedamage, DAMAGE_AIM)); ) if(vlen(e.origin - self.origin) <= (autocvar_g_monster_afrit_attack_fireball_radius))
			Fire_AddDamage(e, self, 5 * MONSTER_SKILLMOD(self), (autocvar_g_monster_afrit_attack_fireball_damagetime), self.projectiledeathtype);

		remove(self);
	}
}

void M_Afrit_Attack_Fireball_Touch()
{
	PROJECTILE_TOUCH;

	M_Afrit_Attack_Fireball_Explode();
}

void M_Afrit_Attack_Fireball(entity this)
{
	entity missile = spawn();
	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);

	monster_makevectors(this, this.enemy);

	missile.owner = missile.realowner = this;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.projectiledeathtype = DEATH_MONSTER_AFRIT.m_id;
	setsize(missile, '-6 -6 -6', '6 6 6');
	setorigin(missile, this.origin + '0 0 13' + v_forward * 10);
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * (autocvar_g_monster_afrit_attack_fireball_speed);
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = M_Afrit_Attack_Fireball_Explode;
	missile.enemy = this.enemy;
	missile.touch = M_Afrit_Attack_Fireball_Touch;
	CSQCProjectile(missile, true, PROJECTILE_FIREMINE, true);
}

bool M_Afrit_Attack(int attack_type, entity actor, entity targ)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			actor.attack_finished_single[0] = time + 2;
			setanim(actor, actor.anim_shoot, false, true, true);
			actor.anim_finished = actor.animstate_endtime;

			Monster_Delay(actor, 2, 0.7, M_Afrit_Attack_Fireball);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_afrit) { Monster_Spawn(this, MON_AFRIT.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Afrit, mr_think, bool(Afrit thismon, entity actor))
		{
			if(actor.target_range < 0)
			{
				if(time >= actor.afrit_targetcheck_delay)
				{
					actor.target_range = actor.afrit_targetrange_backup;
					if(Monster_FindTarget(actor) != world)
					{
						setanim(actor, actor.anim_draw, false, true, true);
						actor.anim_finished = actor.animstate_endtime;
					}
					else
					{
						actor.target_range = -1;
						actor.afrit_targetcheck_delay = time + 1;
					}
				}
			}
			actor.fire_endtime = 0; // never burns

			if(IS_ONGROUND(actor))
				actor.anim_idle = animfixfps(actor, '0 1 0.5', '0 0 0');
			else
				actor.anim_idle = animfixfps(actor, '2 1 0.5', '0 0 0');

			if(actor.flags & FL_ONGROUND)
				actor.armorvalue = 0.95; // almost invincible
			else
				actor.armorvalue = autocvar_g_monsters_armor_blockpercent;
			return true;
		}
		METHOD(Afrit, mr_pain, bool(Afrit thismon, entity actor))
		{
			if(frag_deathtype == DEATH_FIRE.m_id || frag_deathtype == DEATH_LAVA.m_id)
				frag_damage = 0; // afrit doesn't burn
			else
				setanim(actor, actor.anim_pain1, true, true, true);
			return true;
		}
		METHOD(Afrit, mr_death, bool(Afrit thismon, entity actor))
		{
			SELFPARAM();
			setanim(actor, ((random() >= 0.5) ? actor.anim_die1 : actor.anim_die2), false, true, true);
			actor.superweapons_finished = time + 20;
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Afrit, mr_anim, bool(Afrit thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '5 1 0.5', none); // 2 seconds
			actor.anim_die2 = animfixfps(actor, '6 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '2 1 1', none);
			actor.anim_idle = animfixfps(actor, '0 1 0.5', none);
			actor.anim_pain1 = animfixfps(actor, '3 1 2', none); // 0.5 seconds
			actor.anim_shoot = animfixfps(actor, '4 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '2 1 1', none);
			actor.anim_draw = animfixfps(actor, '1 1 1', none);
			return true;
		}
		#endif
		#ifdef SVQC
		spawnfunc(item_cells);
		METHOD(Afrit, mr_setup, bool(Afrit thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_afrit_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_afrit_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_afrit_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_afrit_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_afrit_damageforcescale); }

			if(!actor.target_range) { actor.afrit_targetrange_backup = autocvar_g_monsters_target_range; }
			else { actor.afrit_targetrange_backup = actor.target_range; }
			actor.target_range = -1; // special handler

			actor.weapon = WEP_FIREBALL.m_id; // hehe
			actor.effects |= EF_FLAME;
			actor.noalign = false; // always starts on ground
			//actor.monster_loot = spawnfunc_item_cells;
			actor.monster_attackfunc = M_Afrit_Attack;

			return true;
		}
		METHOD(Afrit, mr_precache, bool(Afrit thismon))
		{
			return true;
		}
		#endif

#endif
