#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SHAMBLER,
/* function   */ m_shambler,
/* spawnflags */ MONSTER_SIZE_BROKEN | MON_FLAG_SUPERMONSTER,
/* mins,maxs  */ '-41 -41 -31', '41 41 65',
/* model      */ "shambler.mdl",
/* netname    */ "shambler",
/* fullname   */ _("Shambler")
);

#define SHAMBLER_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_smash_damage) \
	MON_ADD_CVAR(monster, attack_claw_damage) \
	MON_ADD_CVAR(monster, attack_lightning_damage) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
SHAMBLER_SETTINGS(shambler)
#endif // SVQC
#else
#ifdef SVQC
const float shambler_anim_stand 	= 0;
const float shambler_anim_walk 		= 1;
const float shambler_anim_run 		= 2;
const float shambler_anim_smash 	= 3;
const float shambler_anim_swingr 	= 4;
const float shambler_anim_swingl 	= 5;
const float shambler_anim_magic 	= 6;
const float shambler_anim_pain 		= 7;
const float shambler_anim_death 	= 8;

void shambler_smash()
{
	monster_melee(self.enemy, MON_CVAR(shambler, attack_smash_damage), self.attack_range, DEATH_MONSTER_SHAMBLER_SMASH, TRUE);
}

void shambler_delayedsmash()
{
	monsters_setframe(shambler_anim_smash);
	defer(0.7, shambler_smash);
	self.attack_finished_single = time + 1.1;
}

void shambler_swing()
{
	float r = (random() < 0.5);
	monsters_setframe((r) ? shambler_anim_swingr : shambler_anim_swingl);
	monster_melee(self.enemy, MON_CVAR(shambler, attack_claw_damage), self.attack_range, DEATH_MONSTER_SHAMBLER_CLAW, TRUE);
	self.attack_finished_single = time + 0.8;
	if(r)
		defer(0.5, shambler_swing);
}

void CastLightning()
{
	local vector org, dir;
	//vector v = '0 0 0';

	self.effects |= EF_MUZZLEFLASH;

	org = self.origin + '0 0 40';

	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);

	traceline (org, self.origin + dir * 1000, TRUE, self);
		
	FireRailgunBullet (org, org + dir * 1000, MON_CVAR(shambler, attack_lightning_damage) * monster_skill, 0, 0, 0, 0, 0, DEATH_MONSTER_SHAMBLER_ZAP);
	
	// teamcolor / hit beam effect
	//v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	//WarpZone_TrailParticles(world, particleeffectnum("TE_TEI_G3"), org, v);
	
	te_csqc_lightningarc(org, trace_endpos);
}

float shambler_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float chance = random();

			if(chance > 0.6)
				shambler_delayedsmash();
			else
				shambler_swing();
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			monsters_setframe(shambler_anim_magic);
			self.attack_finished_single = time + 1.1;
			defer(0.6, CastLightning);
			
			return TRUE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_shambler()
{
	self.classname = "monster_shambler";
	
	self.monster_spawnfunc = spawnfunc_monster_shambler;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_SHAMBLER, FALSE)) { remove(self); return; }
}

float m_shambler(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(shambler, speed_run), MON_CVAR(shambler, speed_walk), MON_CVAR(shambler, speed_stop), shambler_anim_run, shambler_anim_walk, shambler_anim_stand);
			return TRUE;
		}
		case MR_DEATH:
		{
			monsters_setframe(shambler_anim_death);
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(shambler, health);
			if not(self.attack_range) self.attack_range = 150;
			
			self.monster_loot = spawnfunc_item_health_mega;
			self.monster_attackfunc	= shambler_attack;
			monsters_setframe(shambler_anim_stand);
			self.weapon = WEP_NEX;
			
			return TRUE;
		}
		case MR_INIT:
		{
			// nothing
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(SHAMBLER_SETTINGS(shambler))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_shambler(float req)
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
			precache_model ("models/monsters/shambler.mdl");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
