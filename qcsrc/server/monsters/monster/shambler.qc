const vector SHAMBLER_MIN = '-41 -41 -31';
const vector SHAMBLER_MAX = '41 41 65';

string SHAMBLER_MODEL = "models/monsters/shambler.mdl";

#ifdef SVQC
float autocvar_g_monster_shambler;
float autocvar_g_monster_shambler_health;
float autocvar_g_monster_shambler_damage;
float autocvar_g_monster_shambler_attack_lightning_damage;
float autocvar_g_monster_shambler_attack_claw_damage;
float autocvar_g_monster_shambler_speed_walk;
float autocvar_g_monster_shambler_speed_run;

const float shambler_anim_stand 	= 0;
const float shambler_anim_walk 		= 1;
const float shambler_anim_run 		= 2;
const float shambler_anim_smash 	= 3;
const float shambler_anim_swingr 	= 4;
const float shambler_anim_swingl 	= 5;
const float shambler_anim_magic 	= 6;
const float shambler_anim_pain 		= 7;
const float shambler_anim_death 	= 8;

void shambler_think()
{
	self.think = shambler_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_shambler_speed_run, autocvar_g_monster_shambler_speed_walk, 300, shambler_anim_run, shambler_anim_walk, shambler_anim_stand);
}

void shambler_smash()
{
	monster_melee(self.enemy, autocvar_g_monster_shambler_damage, 0.3, DEATH_MONSTER_SHAMBLER_SMASH, TRUE);
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
	monster_melee(self.enemy, autocvar_g_monster_shambler_attack_claw_damage, 0.3, DEATH_MONSTER_SHAMBLER_CLAW, TRUE);
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
		
	FireRailgunBullet (org, org + dir * 1000, autocvar_g_monster_shambler_attack_lightning_damage * monster_skill, 0, 0, 0, 0, 0, DEATH_MONSTER_SHAMBLER_ZAP);
	
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

void shambler_die()
{
	Monster_CheckDropCvars ("shambler");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(shambler_anim_death);
	
	monster_hook_death(); // for post-death mods
}

void shambler_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_shambler_health;

	self.damageforcescale   = 0.003;
	self.classname			= "monster_shambler";
	self.monster_attackfunc	= shambler_attack;
	self.nextthink		 	= time + random() * 0.5 + 0.1;
	self.think			  	= shambler_think;
	self.weapon				= WEP_NEX;
	
	monsters_setframe(shambler_anim_stand);
	
	monster_setupsounds("shambler");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_shambler()
{
	if not(autocvar_g_monster_shambler) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_shambler;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Shambler", MONSTER_SHAMBLER,
			 SHAMBLER_MIN, SHAMBLER_MAX,
			 FALSE,
			 shambler_die, shambler_spawn))
	{
		remove(self);
		return;
	}
}

#endif // SVQC
