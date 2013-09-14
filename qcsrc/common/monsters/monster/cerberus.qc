#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ CERBERUS,
/* function   */ m_cerberus,
/* spawnflags */ MON_FLAG_MELEE,
/* mins,maxs  */ '-16 -16 -24', '16 16 12',
/* model      */ "dog.dpm",
/* netname    */ "cerberus",
/* fullname   */ _("Cerberus")
);

#define CERBERUS_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_bite_damage) \
	MON_ADD_CVAR(monster, attack_jump_damage) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
CERBERUS_SETTINGS(cerberus)
#endif // SVQC
#else
#ifdef SVQC
const float cerberus_anim_idle		= 0;
const float cerberus_anim_walk		= 1;
const float cerberus_anim_run		= 2;
const float cerberus_anim_attack	= 3;
const float cerberus_anim_die		= 4;
const float cerberus_anim_pain		= 5;

.float cerberus_last_trace;

void cerberus_findowner()
{
	if(time < self.cerberus_last_trace || self.monster_owner)
		return;
		
	entity head;
	
	FOR_EACH_MONSTER(head)
	if(head.health > 0)
	if(head.monsterid == MON_BRUISER)
	if(findentity(world, monster_owner, head) == world)
	if(vlen(head.origin - self.origin) < self.target_range)
	if(SAME_TEAM(head, self))
	if(head.enemy == world)
	{
		self.monster_owner = head;
		break;
	}
		
	self.cerberus_last_trace = time + 3;
}

void cerberus_checkowner()
{
	if(time < self.cerberus_last_trace)
		return;
	if(IS_PLAYER(self.monster_owner))
		return; // don't check player masters

	if(vlen(self.origin - self.monster_owner.origin) > self.target_range)
		self.monster_owner = world;
	if(self.monster_owner.health < 1)
		self.monster_owner = world;
	if(DIFF_TEAM(self.monster_owner, self))
		self.monster_owner = world;
		
	self.cerberus_last_trace = time + 3;
}

void cerberus_touch_jump()
{
	if (other.takedamage)
	if (vlen(self.velocity) > 300)
	{
		Damage(self.enemy, self, self, MON_CVAR(cerberus, attack_jump_damage) * monster_skill, DEATH_MONSTER_CERBERUS_JUMP, self.enemy.origin, normalize(self.enemy.origin - self.origin));
		self.touch = MonsterTouch;
	}

	if(trace_dphitcontents)
		self.touch = MonsterTouch;
}

float cerberus_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return monster_melee(self.enemy, MON_CVAR(cerberus, attack_bite_damage), cerberus_anim_attack, self.attack_range, 0.7, DEATH_MONSTER_CERBERUS_BITE, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			return monster_leap(cerberus_anim_attack, cerberus_touch_jump, v_forward * 300 + '0 0 200', 0.8);
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_cerberus()
{
	self.classname = "monster_cerberus";
	
	self.monster_spawnfunc = spawnfunc_monster_cerberus;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_CERBERUS, FALSE)) { remove(self); return; }
}

// compatibility with old spawns
void spawnfunc_monster_dog() { spawnfunc_monster_cerberus(); }

float m_cerberus(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			if(self.monster_owner)
				cerberus_checkowner();
			else
				cerberus_findowner();
			monster_move(MON_CVAR(cerberus, speed_run), MON_CVAR(cerberus, speed_walk), MON_CVAR(cerberus, speed_stop), cerberus_anim_run, cerberus_anim_walk, cerberus_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			if(self.monster_owner.flags & FL_MONSTER)
				self.monster_owner = world;
			monsters_setframe(cerberus_anim_die);
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(cerberus, health);
			
			self.monster_loot = spawnfunc_item_health_small;
			self.monster_attackfunc	= cerberus_attack;
			monsters_setframe(cerberus_anim_idle);
			
			return TRUE;
		}
		case MR_INIT:
		{
			// nothing
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(CERBERUS_SETTINGS(cerberus))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_cerberus(float req)
{
	switch(req)
	{
		case MR_DEATH:
		{
			// nothing
			return TRUE;
		}
		case MR_INIT:
		{
			precache_model ("models/monsters/dog.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
