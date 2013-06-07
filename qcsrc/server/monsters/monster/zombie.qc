const vector ZOMBIE_MIN = '-18 -18 -25';
const vector ZOMBIE_MAX = '18 18 47';

string ZOMBIE_MODEL = "models/monsters/zombie.dpm";

#ifdef SVQC
float autocvar_g_monster_zombie;
float autocvar_g_monster_zombie_stopspeed;
float autocvar_g_monster_zombie_attack_leap_damage;
float autocvar_g_monster_zombie_attack_leap_delay;
float autocvar_g_monster_zombie_attack_leap_force;
float autocvar_g_monster_zombie_attack_leap_speed;
float autocvar_g_monster_zombie_attack_stand_damage;
float autocvar_g_monster_zombie_attack_stand_delay;
float autocvar_g_monster_zombie_health;
float autocvar_g_monster_zombie_speed_walk;
float autocvar_g_monster_zombie_speed_run;

const float zombie_anim_attackleap			= 0;
const float zombie_anim_attackrun1			= 1;
const float zombie_anim_attackrun2			= 2;
const float zombie_anim_attackrun3			= 3;
const float zombie_anim_attackstanding1		= 4;
const float zombie_anim_attackstanding2		= 5;
const float zombie_anim_attackstanding3		= 6;
const float zombie_anim_blockend		   	= 7;
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
const float zombie_anim_idle			   	= 19;
const float zombie_anim_painback1		  	= 20;
const float zombie_anim_painback2		  	= 21;
const float zombie_anim_painfront1			= 22;
const float zombie_anim_painfront2			= 23;
const float zombie_anim_runbackwards	   	= 24;
const float zombie_anim_runbackwardsleft   	= 25;
const float zombie_anim_runbackwardsright  	= 26;
const float zombie_anim_runforward			= 27;
const float zombie_anim_runforwardleft	 	= 28;
const float zombie_anim_runforwardright		= 29;
const float zombie_anim_spawn			  	= 30;

void zombie_think()
{
	self.think = zombie_think;
	self.nextthink = time + self.ticrate;

	monster_move(autocvar_g_monster_zombie_speed_run, autocvar_g_monster_zombie_speed_walk, autocvar_g_monster_zombie_stopspeed, zombie_anim_runforward, zombie_anim_runforward, zombie_anim_idle);
}

void zombie_attack_leap_touch()
{
	if (self.health <= 0)
		return;
		
	vector angles_face;

	if(other.takedamage)
	{
		angles_face = vectoangles(self.moveto - self.origin);
		angles_face = normalize(angles_face) * autocvar_g_monster_zombie_attack_leap_force;
		Damage(other, self, self, autocvar_g_monster_zombie_attack_leap_damage * monster_skill, DEATH_MONSTER_ZOMBIE_JUMP, other.origin, angles_face);
		self.touch = MonsterTouch; // instantly turn it off to stop damage spam
	}

	if (trace_dphitcontents)
		self.touch = MonsterTouch;
}

float zombie_attack(float attack_type)
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
				
			monsters_setframe(chosen_anim);

			self.attack_finished_single = time + autocvar_g_monster_zombie_attack_stand_delay;
			
			monster_melee(self.enemy, autocvar_g_monster_zombie_attack_stand_damage, 0.3, DEATH_MONSTER_ZOMBIE_MELEE, TRUE);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			if(monster_leap(zombie_anim_attackleap, zombie_attack_leap_touch, v_forward * autocvar_g_monster_zombie_attack_leap_speed + '0 0 200', autocvar_g_monster_zombie_attack_leap_delay))
				return TRUE;
		}
	}
	
	return FALSE;
}

void zombie_die()
{
	Monster_CheckDropCvars ("zombie");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe((random() > 0.5) ? zombie_anim_deathback1 : zombie_anim_deathfront1);
		
	monster_hook_death(); // for post-death mods
}

void zombie_spawn() 
{
	if not(self.health)
		self.health = autocvar_g_monster_zombie_health;
	
	self.classname			= "monster_zombie";
	self.spawn_time	  		= time + 2.1;
	self.nextthink			= time + random() * 0.5 + 0.1;
	self.think		  		= zombie_think;
	self.monster_attackfunc	= zombie_attack;
	self.spawnshieldtime	= self.spawn_time;
	self.respawntime		= 0.1;
	self.spawnflags		   |= MONSTER_RESPAWN_DEATHPOINT; // always enabled for zombie
	
	monsters_setframe(zombie_anim_spawn);
	
	monster_setupsounds("zombie");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_zombie() 
{
	if not(autocvar_g_monster_zombie) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_zombie;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not (monster_initialize(
			 "Zombie", MONSTER_ZOMBIE,
			 ZOMBIE_MIN, ZOMBIE_MAX,
			 FALSE,
			 zombie_die, zombie_spawn))
	{
		remove(self);
		return;
	}
}

#endif //SVQC
