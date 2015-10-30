#ifndef SCRAG_H
#define SCRAG_H

#ifndef MENUQC
MODEL(MON_SCRAG, "models/monsters/scrag.mdl");
#endif

CLASS(Scrag, Monster)
    ATTRIB(Scrag, spawnflags, int, MONSTER_SIZE_QUAKE | MONSTER_TYPE_FLY | MON_FLAG_RANGED);
    ATTRIB(Scrag, mins, vector, '-16 -16 -24');
    ATTRIB(Scrag, maxs, vector, '16 16 40');
#ifndef MENUQC
    ATTRIB(Scrag, m_model, Model, MDL_MON_SCRAG);
#endif
    ATTRIB(Scrag, netname, string, "scrag");
    ATTRIB(Scrag, monster_name, string, _("Scrag"));
ENDCLASS(Scrag)

REGISTER_MONSTER(SCRAG, NEW(Scrag)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

CLASS(ScragAttack, PortoLaunch)
/* flags     */ ATTRIB(ScragAttack, spawnflags, int, WEP_TYPE_OTHER | WEP_FLAG_HIDDEN | WEP_FLAG_MUTATORBLOCKED);
/* impulse   */ ATTRIB(ScragAttack, impulse, int, 9);
/* refname   */ ATTRIB(ScragAttack, netname, string, "scrag");
/* wepname   */ ATTRIB(ScragAttack, message, string, _("Scrag attack"));
ENDCLASS(ScragAttack)
REGISTER_WEAPON(SCRAG_ATTACK, NEW(ScragAttack));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_scrag_attack_spike_damage = 10;
float autocvar_g_monster_scrag_attack_spike_edgedamage = 4;
float autocvar_g_monster_scrag_attack_spike_force = 10;
float autocvar_g_monster_scrag_attack_spike_radius = 10;
float autocvar_g_monster_scrag_attack_spike_speed = 600;

void M_Scrag_Attack_Spike_Explode();
void M_Scrag_Attack_Spike_Touch();

METHOD(ScragAttack, wr_think, void(ScragAttack thiswep, entity actor, int slot, int fire)) {
    if (fire & 1)
    if (time > actor.attack_finished_single[slot] || weapon_prepareattack(thiswep, actor, slot, false, 1.2)) {
        if (IS_PLAYER(actor)) W_SetupShot_Dir(actor, v_forward, false, 0, W_Sound("electro_fire"), CH_WEAPON_B, 0);
		if (IS_MONSTER(actor)) {
			actor.attack_finished_single[slot] = time + 1.2;
			actor.anim_finished = time + 1.2;
			monster_makevectors(actor.enemy);
		}

		entity missile = spawn();
		missile.owner = missile.realowner = actor;
		missile.solid = SOLID_TRIGGER;
		missile.movetype = MOVETYPE_FLYMISSILE;
		missile.projectiledeathtype = DEATH_MONSTER_WYVERN.m_id;
		setsize(missile, '-6 -6 -6', '6 6 6');
		setorigin(missile, actor.origin + actor.view_ofs + v_forward * 14);
		missile.flags = FL_PROJECTILE;
		missile.velocity = w_shotdir * (autocvar_g_monster_scrag_attack_spike_speed);
		missile.avelocity = '300 300 300';
		missile.nextthink = time + 5;
		missile.think = M_Scrag_Attack_Spike_Explode;
		missile.touch = M_Scrag_Attack_Spike_Touch;
		CSQCProjectile(missile, true, PROJECTILE_CRYLINK, true);

        weapon_thinkf(actor, slot, WFRAME_FIRE1, 0, w_ready);
    }
}

METHOD(ScragAttack, wr_checkammo1, bool(ScragAttack thiswep)) {
	return true;
}

float autocvar_g_monster_scrag_health = 110;
float autocvar_g_monster_scrag_damageforcescale = 0.55;
float autocvar_g_monster_scrag_speed_stop = 50;
float autocvar_g_monster_scrag_speed_run = 120;
float autocvar_g_monster_scrag_speed_walk = 80;

/*
const float scrag_anim_hover	= 0;
const float scrag_anim_fly		= 1;
const float scrag_anim_magic	= 2;
const float scrag_anim_pain	= 3;
const float scrag_anim_death	= 4;
*/

void M_Scrag_Attack_Spike_Explode()
{
	SELFPARAM();
	//Send_Effect(EFFECT_FIREBALL_EXPLODE, self.origin, '0 0 0', 1);
	__pointparticles(_particleeffectnum("TE_WIZSPIKE"), self.origin, '0 0 0', 1);

	entity owner = self.realowner;

	RadiusDamage(self, owner, autocvar_g_monster_scrag_attack_spike_damage, autocvar_g_monster_scrag_attack_spike_edgedamage, autocvar_g_monster_scrag_attack_spike_force, 
		world, world, autocvar_g_monster_scrag_attack_spike_radius, self.projectiledeathtype, world);

	remove(self);
}

void M_Scrag_Attack_Spike_Touch()
{
	PROJECTILE_TOUCH;
	if(other == self.owner) { return; }

	M_Scrag_Attack_Spike_Explode();
}

bool M_Scrag_Attack(int attack_type, entity targ)
{
	SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			w_shotdir = normalize((self.enemy.origin + '0 0 10') - self.origin);
			Weapon wep = WEP_SCRAG_ATTACK;
			wep.wr_think(wep, self, true, false);

			if(random() <= 0.1 || self.monster_moveto)
			{
				makevectors(self.angles);
				self.monster_moveto = self.origin + '1 1 0' * (random() >= 0.5) ? (v_right * 300) : (v_right * -300);
				self.monster_face = self.enemy.origin; // but still look at enemy
				if(random() <= 0.4)
					self.monster_moveto = self.monster_face = '0 0 0';
			}
			return true;
		}
	}

	return false;
}

spawnfunc(monster_scrag) { Monster_Spawn(MON_SCRAG.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Scrag, mr_think, bool(Scrag thismon))
		{
			return true;
		}
		METHOD(Scrag, mr_pain, bool(Scrag thismon))
		{
			SELFPARAM();
			self.pain_finished = time + 0.5;
			setanim(self, self.anim_pain1, true, true, false);
			return true;
		}
		METHOD(Scrag, mr_death, bool(Scrag thismon))
		{
			SELFPARAM();
			setanim(self, self.anim_die1, false, true, true);
			self.velocity_x = -200 + 400 * random();
			self.velocity_y = -200 + 400 * random();
			self.velocity_z = 100 + 100 * random();
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Scrag, mr_anim, bool(Scrag thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '4 1 0.5', none); // 2 seconds
			self.anim_walk = animfixfps(self, '1 1 1', none);
			self.anim_idle = animfixfps(self, '0 1 1', none);
			self.anim_pain1 = animfixfps(self, '3 1 2', none); // 0.5 seconds
			self.anim_shoot = animfixfps(self, '2 1 5', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '1 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		spawnfunc(item_cells);
		METHOD(Scrag, mr_setup, bool(Scrag thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_scrag_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_scrag_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_scrag_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_scrag_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_scrag_damageforcescale); }

			//self.monster_loot = spawnfunc_item_cells;
			self.monster_attackfunc = M_Scrag_Attack;

			return true;
		}
		METHOD(Scrag, mr_precache, bool(Scrag thismon))
		{
			return true;
		}
		#endif

#endif
