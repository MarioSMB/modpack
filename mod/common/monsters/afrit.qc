#ifndef AFRIT_H
#define AFRIT_H

#ifndef MENUQC
MODEL(MON_AFRIT, "models/monsters/afrit.mdl");

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_AFRIT,          2, 1, "s1 s2loc spree_lost", "s1",       "notify_death",         _("^BG%s^K1 was fireballed by an Afrit%s%s"), "")

MSG_MULTI_NOTIF(1, DEATH_SELF_MON_AFRIT,                NO_MSG,        INFO_DEATH_SELF_MON_AFRIT,                CENTER_DEATH_SELF_MONSTER)

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
{
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

void M_Afrit_Attack_Fireball()
{
	entity missile = spawn();
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	monster_makevectors(self.enemy);

	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.projectiledeathtype = DEATH_MONSTER_AFRIT.m_id;
	setsize(missile, '-6 -6 -6', '6 6 6');
	setorigin(missile, self.origin + '0 0 13' + v_forward * 10);
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * (autocvar_g_monster_afrit_attack_fireball_speed);
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = M_Afrit_Attack_Fireball_Explode;
	missile.enemy = self.enemy;
	missile.touch = M_Afrit_Attack_Fireball_Touch;
	CSQCProjectile(missile, true, PROJECTILE_FIREMINE, true);
}

bool M_Afrit_Attack(int attack_type, entity targ)
{
	SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			self.attack_finished_single = time + 2;
			setanim(self, self.anim_shoot, false, true, true);
			self.anim_finished = self.animstate_endtime;

			Monster_Delay(2, 0.3, 0.7, M_Afrit_Attack_Fireball);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_afrit) { Monster_Spawn(MON_AFRIT.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Afrit, mr_think, bool(Afrit thismon))
		{
			if(self.target_range < 0)
			{
				if(time >= self.afrit_targetcheck_delay)
				{
					self.target_range = self.afrit_targetrange_backup;
					if(Monster_FindTarget(self) != world)
					{
						setanim(self, self.anim_draw, false, true, true);
						self.anim_finished = self.animstate_endtime;
					}
					else
					{
						self.target_range = -1;
						self.afrit_targetcheck_delay = time + 1;
					}
				}
			}
			self.fire_endtime = 0; // never burns

			if(self.flags & FL_ONGROUND)
				self.anim_idle = animfixfps(self, '0 1 0.5', '0 0 0');
			else
				self.anim_idle = animfixfps(self, '2 1 0.5', '0 0 0');

			if(self.flags & FL_ONGROUND)
				self.armorvalue = 0.95; // almost invincible
			else
				self.armorvalue = autocvar_g_monsters_armor_blockpercent;
			return true;
		}
		METHOD(Afrit, mr_pain, bool(Afrit thismon))
		{
			SELFPARAM();
			if(frag_deathtype == DEATH_FIRE.m_id || frag_deathtype == DEATH_LAVA.m_id)
				frag_damage = 0; // afrit doesn't burn
			else
				setanim(self, self.anim_pain1, true, true, true);
			return true;
		}
		METHOD(Afrit, mr_death, bool(Afrit thismon))
		{
			SELFPARAM();
			setanim(self, ((random() >= 0.5) ? self.anim_die1 : self.anim_die2), false, true, true);
			self.superweapons_finished = time + 20;
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Afrit, mr_anim, bool(Afrit thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '5 1 0.5', none); // 2 seconds
			self.anim_die2 = animfixfps(self, '6 1 0.5', none); // 2 seconds
			self.anim_walk = animfixfps(self, '2 1 1', none);
			self.anim_idle = animfixfps(self, '0 1 0.5', none);
			self.anim_pain1 = animfixfps(self, '3 1 2', none); // 0.5 seconds
			self.anim_shoot = animfixfps(self, '4 1 5', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '2 1 1', none);
			self.anim_draw = animfixfps(self, '1 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		spawnfunc(item_cells);
		METHOD(Afrit, mr_setup, bool(Afrit thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_afrit_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_afrit_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_afrit_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_afrit_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_afrit_damageforcescale); }

			if(!self.target_range) { self.afrit_targetrange_backup = autocvar_g_monsters_target_range; }
			else { self.afrit_targetrange_backup = self.target_range; }
			self.target_range = -1; // special handler

			self.weapon = WEP_FIREBALL.m_id; // hehe
			self.effects |= EF_FLAME;
			self.noalign = false; // always starts on ground
			//self.monster_loot = spawnfunc_item_cells;
			self.monster_attackfunc = M_Afrit_Attack;

			return true;
		}
		METHOD(Afrit, mr_precache, bool(Afrit thismon))
		{
			return true;
		}
		#endif

#endif
