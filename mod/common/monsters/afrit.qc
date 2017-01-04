#ifndef AFRIT_H
#define AFRIT_H

#ifndef MENUQC
MODEL(MON_AFRIT, M_Model("afrit.mdl"));

MSG_INFO_NOTIF(DEATH_SELF_MON_AFRIT,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 was fireballed by an Afrit%s%s", "")

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
    ATTRIB(Afrit, monster_name, string, "Afrit");
ENDCLASS(Afrit)

REGISTER_MONSTER(AFRIT, NEW(Afrit)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_afrit_health, float, 400, "");
AUTOCVAR(g_monster_afrit_damageforcescale, float, 0.3, "");
AUTOCVAR(g_monster_afrit_attack_fireball_damage, float, 20, "");
AUTOCVAR(g_monster_afrit_attack_fireball_edgedamage, float, 15, "");
AUTOCVAR(g_monster_afrit_attack_fireball_damagetime, float, 2, "");
AUTOCVAR(g_monster_afrit_attack_fireball_force, float, 50, "");
AUTOCVAR(g_monster_afrit_attack_fireball_radius, float, 120, "");
AUTOCVAR(g_monster_afrit_attack_fireball_speed, float, 1200, "");
AUTOCVAR(g_monster_afrit_speed_stop, float, 300, "");
AUTOCVAR(g_monster_afrit_speed_run, float, 120, "");
AUTOCVAR(g_monster_afrit_speed_walk, float, 40, "");

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

void M_Afrit_Attack_Fireball_Explode(entity this, entity directhitentity)
{
	if(this)
	{
		Send_Effect(EFFECT_FIREBALL_EXPLODE, this.origin, '0 0 0', 1);

		RadiusDamage(this, this.realowner, (autocvar_g_monster_afrit_attack_fireball_damage), (autocvar_g_monster_afrit_attack_fireball_edgedamage), 
					(autocvar_g_monster_afrit_attack_fireball_force), NULL, NULL, (autocvar_g_monster_afrit_attack_fireball_radius), this.projectiledeathtype, directhitentity);

		FOREACH_ENTITY_RADIUS(this.origin, autocvar_g_monster_afrit_attack_fireball_radius, it.takedamage == DAMAGE_AIM,
		{
			Fire_AddDamage(it, this, 5 * MONSTER_SKILLMOD(this), (autocvar_g_monster_afrit_attack_fireball_damagetime), this.projectiledeathtype);
		});

		delete(this);
	}
}

void M_Afrit_Attack_Fireball_Explode_think(entity this)
{
	M_Afrit_Attack_Fireball_Explode(this, NULL);
}

void M_Afrit_Attack_Fireball_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	M_Afrit_Attack_Fireball_Explode(this, toucher);
}

void M_Afrit_Attack_Fireball(entity this)
{
	entity missile = spawn();
	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);

	monster_makevectors(this, this.enemy);

	missile.owner = missile.realowner = this;
	missile.solid = SOLID_TRIGGER;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.projectiledeathtype = DEATH_MONSTER_AFRIT.m_id;
	setsize(missile, '-6 -6 -6', '6 6 6');
	setorigin(missile, this.origin + '0 0 13' + v_forward * 10);
	missile.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, missile);
	IL_PUSH(g_bot_dodge, missile);
	missile.velocity = dir * (autocvar_g_monster_afrit_attack_fireball_speed);
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	setthink(missile, M_Afrit_Attack_Fireball_Explode_think);
	missile.enemy = this.enemy;
	settouch(missile, M_Afrit_Attack_Fireball_Touch);
	CSQCProjectile(missile, true, PROJECTILE_FIREMINE, true);
}

bool M_Afrit_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
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

spawnfunc(monster_afrit) { Monster_Spawn(this, true, MON_AFRIT.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Afrit, mr_think, bool(Afrit thismon, entity actor))
		{
			if(actor.target_range < 0)
			{
				if(time >= actor.afrit_targetcheck_delay)
				{
					actor.target_range = actor.afrit_targetrange_backup;
					if(Monster_FindTarget(actor) != NULL)
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

			if(IS_ONGROUND(actor))
				actor.armorvalue = 0.95; // almost invincible
			else
				actor.armorvalue = autocvar_g_monsters_armor_blockpercent;
			return true;
		}
		METHOD(Afrit, mr_pain, float(Afrit thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			if(deathtype == DEATH_FIRE.m_id || deathtype == DEATH_LAVA.m_id)
				damage_take = 0; // afrit doesn't burn
			else
				setanim(actor, actor.anim_pain1, true, true, true);
			return damage_take;
		}
		METHOD(Afrit, mr_death, bool(Afrit thismon, entity actor))
		{
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
