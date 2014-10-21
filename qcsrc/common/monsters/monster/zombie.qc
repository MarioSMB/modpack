#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ ZOMBIE,
/* functions  */ M_Zombie, M_Zombie_Attack,
/* spawnflags */ MON_FLAG_MELEE,
/* mins,maxs  */ '-18 -18 -25', '18 18 47',
/* model      */ "zombie.dpm",
/* netname    */ "zombie",
/* fullname   */ _("Zombie")
);

#else
#ifdef SVQC
float autocvar_g_monster_zombie_health;
float autocvar_g_monster_zombie_attack_melee_damage;
float autocvar_g_monster_zombie_attack_melee_delay;
float autocvar_g_monster_zombie_attack_leap_damage;
float autocvar_g_monster_zombie_attack_leap_force;
float autocvar_g_monster_zombie_attack_leap_speed;
float autocvar_g_monster_zombie_attack_leap_delay;
float autocvar_g_monster_zombie_speed_stop;
float autocvar_g_monster_zombie_speed_run;
float autocvar_g_monster_zombie_speed_walk;

const float zombie_anim_attackleap			= 0;
const float zombie_anim_attackrun1			= 1;
const float zombie_anim_attackrun2			= 2;
const float zombie_anim_attackrun3			= 3;
const float zombie_anim_attackstanding1		= 4;
const float zombie_anim_attackstanding2		= 5;
const float zombie_anim_attackstanding3		= 6;
const float zombie_anim_blockend			= 7;
const float zombie_anim_blockstart			= 8;
const float zombie_anim_deathback1			= 9;
const float zombie_anim_deathback2			= 10;
const float zombie_anim_deathback3			= 11;
const float zombie_anim_deathfront1			= 12;
const float zombie_anim_deathfront2			= 13;
const float zombie_anim_deathfront3			= 14;
const float zombie_anim_deathleft1			= 15;
const float zombie_anim_deathleft2			= 16;
const float zombie_anim_deathright1			= 17;
const float zombie_anim_deathright2			= 18;
const float zombie_anim_idle				= 19;
const float zombie_anim_painback1			= 20;
const float zombie_anim_painback2			= 21;
const float zombie_anim_painfront1			= 22;
const float zombie_anim_painfront2			= 23;
const float zombie_anim_runbackwards		= 24;
const float zombie_anim_runbackwardsleft	= 25;
const float zombie_anim_runbackwardsright	= 26;
const float zombie_anim_runforward			= 27;
const float zombie_anim_runforwardleft		= 28;
const float zombie_anim_runforwardright		= 29;
const float zombie_anim_spawn				= 30;

void M_Zombie_Attack_Leap_Touch()
{
	if (self.health <= 0)
		return;

	vector angles_face;

	if(other.takedamage)
	{
		angles_face = vectoangles(self.moveto - self.origin);
		angles_face = normalize(angles_face) * (autocvar_g_monster_zombie_attack_leap_force);
		Damage(other, self, self, (autocvar_g_monster_zombie_attack_leap_damage) * MONSTER_SKILLMOD(self), DEATH_MONSTER_ZOMBIE_JUMP, other.origin, angles_face);
		self.touch = Monster_Touch; // instantly turn it off to stop damage spam
	}

	if (trace_dphitcontents)
		self.touch = Monster_Touch;
}

void M_Zombie_Defend_Block_End()
{
	if(self.health <= 0)
		return;

	self.frame = zombie_anim_blockend;
	self.armorvalue = autocvar_g_monsters_armor_blockpercent;
}

float M_Zombie_Defend_Block()
{
	self.frame = zombie_anim_blockstart;
	self.armorvalue = 0.9;
	self.state = MONSTER_ATTACK_MELEE; // freeze monster
	self.attack_finished_single = time + 2.1;

	defer(2, M_Zombie_Defend_Block_End);

	return TRUE;
}

float M_Zombie_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float rand = random(), chosen_anim;

			if(rand < 0.33)
				chosen_anim = zombie_anim_attackstanding1;
			else if(rand < 0.66)
				chosen_anim = zombie_anim_attackstanding2;
			else
				chosen_anim = zombie_anim_attackstanding3;

			if(random() < 0.3 && self.health < 75 && self.enemy.health > 10)
				return M_Zombie_Defend_Block();

			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_zombie_attack_melee_damage), chosen_anim, self.attack_range, (autocvar_g_monster_zombie_attack_melee_delay), DEATH_MONSTER_ZOMBIE_MELEE, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			return Monster_Attack_Leap(zombie_anim_attackleap, M_Zombie_Attack_Leap_Touch, v_forward * (autocvar_g_monster_zombie_attack_leap_speed) + '0 0 200', (autocvar_g_monster_zombie_attack_leap_delay));
		}
	}

	return FALSE;
}

void spawnfunc_monster_zombie() { Monster_Spawn(MON_ZOMBIE); }

float M_Zombie(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			return TRUE;
		}
		case MR_DEATH:
		{
			self.armorvalue = autocvar_g_monsters_armor_blockpercent;
			self.frame = ((random() > 0.5) ? zombie_anim_deathback1 : zombie_anim_deathfront1);
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_zombie_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_zombie_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_zombie_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_zombie_speed_stop); }

			self.m_anim_walk = zombie_anim_runforward;
			self.m_anim_run = zombie_anim_runforward;
			self.m_anim_idle = zombie_anim_idle;

			if(self.spawnflags & MONSTERFLAG_NORESPAWN)
				self.spawnflags &= ~MONSTERFLAG_NORESPAWN; // zombies always respawn

			self.spawnflags |= MONSTER_RESPAWN_DEATHPOINT;

			self.monster_loot = spawnfunc_item_health_medium;
			self.frame = zombie_anim_spawn;
			self.spawn_time = time + 2.1;
			self.spawnshieldtime = self.spawn_time;
			self.respawntime = 0.2;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/zombie.dpm");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
