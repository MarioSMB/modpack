#ifndef SOLDIER_H
#define SOLDIER_H

#ifndef MENUQC
MODEL(MON_SOLDIER, M_Model("soldier.mdl"));
#endif

CLASS(Soldier, Monster)
    ATTRIB(Soldier, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Soldier, mins, vector, '-16 -16 -24');
    ATTRIB(Soldier, maxs, vector, '16 16 40');
#ifndef MENUQC
    ATTRIB(Soldier, m_model, Model, MDL_MON_SOLDIER);
#endif
    ATTRIB(Soldier, netname, string, "soldier");
    ATTRIB(Soldier, monster_name, string, _("Soldier"));
ENDCLASS(Soldier)

REGISTER_MONSTER(SOLDIER, NEW(Soldier)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_soldier_health = 70;
float autocvar_g_monster_soldier_damageforcescale = 0.5;
float autocvar_g_monster_soldier_attack_shotgun_damage = 4;
int autocvar_g_monster_soldier_attack_shotgun_bullets = 4;
float autocvar_g_monster_soldier_attack_shotgun_spread = 0.03;
float autocvar_g_monster_soldier_attack_shotgun_solidpenetration = 12;
float autocvar_g_monster_soldier_attack_shotgun_force = 50;
float autocvar_g_monster_soldier_attack_shotgun_refire = 0.5;
float autocvar_g_monster_soldier_speed_stop = 100;
float autocvar_g_monster_soldier_speed_run = 80;
float autocvar_g_monster_soldier_speed_walk = 40;


void M_Soldier_Attack_Shotgun(entity this)
{
	if (!IS_PLAYER(this)) w_shotdir = normalize((this.enemy.origin + '0 0 10') - this.origin);

	W_SetupShot(this, true, 5, SND_SHOTGUN_FIRE, CH_WEAPON_A, autocvar_g_monster_soldier_attack_shotgun_damage * autocvar_g_monster_soldier_attack_shotgun_bullets);

	for(int sc = 0; sc < autocvar_g_monster_soldier_attack_shotgun_bullets;sc = sc + 1)
		fireBullet(this, w_shotdir, this.enemy.origin, autocvar_g_monster_soldier_attack_shotgun_spread, autocvar_g_monster_soldier_attack_shotgun_solidpenetration, autocvar_g_monster_soldier_attack_shotgun_damage, autocvar_g_monster_soldier_attack_shotgun_force, WEP_SHOTGUN.m_id, 0);

	Send_Effect(EFFECT_SHOTGUN_MUZZLEFLASH, w_shotdir, w_shotdir * 1000, 1);

	this.attack_finished_single[0] = time + autocvar_g_monster_soldier_attack_shotgun_refire + random();
	this.anim_finished = time + 0.8;

	setanim(this, this.anim_shoot, true, true, true);
}

bool M_Soldier_Attack(int attack_type, entity actor, entity targ)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			M_Soldier_Attack_Shotgun(actor);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_army) { Monster_Spawn(this, MON_SOLDIER.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Soldier, mr_think, bool(Monster thismon, entity actor))
		{
			return true;
		}
		METHOD(Soldier, mr_death, bool(Monster thismon, entity actor))
		{
			setanim(actor, actor.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Soldier, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '1 0.9 1', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '9 2.3 1', none);
			actor.anim_idle = animfixfps(actor, '0 0.7 1', none);
			actor.anim_pain1 = animfixfps(actor, '4 1 2', none); // 0.5 seconds
			actor.anim_shoot = animfixfps(actor, '8 0.8 1', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '7 0.7 1', none);
			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_health_large);
		METHOD(Soldier, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_soldier_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_soldier_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_soldier_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_soldier_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_soldier_damageforcescale); }

			actor.monster_loot = spawnfunc_item_shells;
			actor.monster_attackfunc = M_Soldier_Attack;

			return true;
		}
		METHOD(Soldier, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
