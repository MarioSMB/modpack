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


void M_Soldier_Attack_Shotgun()
{SELFPARAM();
	if (!IS_PLAYER(self)) w_shotdir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	W_SetupShot(self, true, 5, SND(SHOTGUN_FIRE), CH_WEAPON_A, autocvar_g_monster_soldier_attack_shotgun_damage * autocvar_g_monster_soldier_attack_shotgun_bullets);

	for(int sc = 0; sc < autocvar_g_monster_soldier_attack_shotgun_bullets;sc = sc + 1)
		fireBullet(w_shotdir, self.enemy.origin, autocvar_g_monster_soldier_attack_shotgun_spread, autocvar_g_monster_soldier_attack_shotgun_solidpenetration, autocvar_g_monster_soldier_attack_shotgun_damage, autocvar_g_monster_soldier_attack_shotgun_force, WEP_SHOTGUN.m_id, 0);

	Send_Effect(EFFECT_SHOTGUN_MUZZLEFLASH, w_shotdir, w_shotdir * 1000, 1);

	self.attack_finished_single[0] = time + autocvar_g_monster_soldier_attack_shotgun_refire + random();
	self.anim_finished = time + 0.8;

	setanim(self, self.anim_shoot, true, true, true);
}

bool M_Soldier_Attack(int attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			M_Soldier_Attack_Shotgun();
			return true;
		}
	}

	return false;
}

spawnfunc(monster_army) { Monster_Spawn(MON_SOLDIER.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Soldier, mr_think, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Soldier, mr_pain, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Soldier, mr_death, bool(Monster thismon))
		{
			SELFPARAM();
			setanim(self, self.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Soldier, mr_anim, bool(Monster thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '1 0.9 1', none); // 2 seconds
			self.anim_walk = animfixfps(self, '9 2.3 1', none);
			self.anim_idle = animfixfps(self, '0 0.7 1', none);
			self.anim_pain1 = animfixfps(self, '4 1 2', none); // 0.5 seconds
			self.anim_shoot = animfixfps(self, '8 0.8 1', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '7 0.7 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_health_large);
		METHOD(Soldier, mr_setup, bool(Monster thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_soldier_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_soldier_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_soldier_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_soldier_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_soldier_damageforcescale); }

			self.monster_loot = spawnfunc_item_shells;
			self.monster_attackfunc = M_Soldier_Attack;

			self.hitplotfh = -1;

			return true;
		}
		METHOD(Soldier, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
