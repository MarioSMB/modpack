#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ OGRE,
/* functions  */ M_Ogre, M_Ogre_Attack,
/* spawnflags */ MON_FLAG_MELEE | MON_FLAG_RANGED | MONSTER_SIZE_BROKEN,
/* mins,maxs  */ '-36 -36 -20', '36 36 50',
/* model      */ "ogre.mdl",
/* netname    */ "ogre",
/* fullname   */ _("Ogre")
);

#else
#ifdef SVQC
float autocvar_g_monster_ogre_health;
float autocvar_g_monster_ogre_attack_machinegun_spread;
float autocvar_g_monster_ogre_attack_machinegun_solidpenetration;
float autocvar_g_monster_ogre_attack_machinegun_damage;
float autocvar_g_monster_ogre_attack_machinegun_force;
float autocvar_g_monster_ogre_attack_grenade_damage;
float autocvar_g_monster_ogre_attack_grenade_edgedamage;
float autocvar_g_monster_ogre_attack_grenade_radius;
float autocvar_g_monster_ogre_attack_grenade_speed;
float autocvar_g_monster_ogre_attack_grenade_speed_up;
float autocvar_g_monster_ogre_attack_grenade_speed_z;
float autocvar_g_monster_ogre_attack_grenade_spread;
float autocvar_g_monster_ogre_attack_grenade_force;
float autocvar_g_monster_ogre_attack_grenade_bouncefactor;
float autocvar_g_monster_ogre_attack_grenade_bouncestop;
float autocvar_g_monster_ogre_attack_grenade_lifetime;
float autocvar_g_monster_ogre_attack_grenade_health;
float autocvar_g_monster_ogre_attack_grenade_damageforcescale;
float autocvar_g_monster_ogre_attack_melee_damage;
float autocvar_g_monster_ogre_attack_melee_nonplayerdamage;
float autocvar_g_monster_ogre_attack_melee_delay;
float autocvar_g_monster_ogre_attack_melee_time;
float autocvar_g_monster_ogre_attack_melee_range;
float autocvar_g_monster_ogre_attack_melee_traces;
float autocvar_g_monster_ogre_attack_melee_swing_up;
float autocvar_g_monster_ogre_attack_melee_swing_side;
float autocvar_g_monster_ogre_speed_stop;
float autocvar_g_monster_ogre_speed_run;
float autocvar_g_monster_ogre_speed_walk;

const float ogre_anim_idle 			= 0;
const float ogre_anim_walk 			= 1;
const float ogre_anim_run 			= 2;
const float ogre_anim_swing 		= 3;
const float ogre_anim_smash 		= 4;
const float ogre_anim_shoot 		= 5;
const float ogre_anim_pain1 		= 6;
const float ogre_anim_pain2 		= 7;
const float ogre_anim_pain3 		= 8;
const float ogre_anim_pain4 		= 9;
const float ogre_anim_pain5 		= 10;
const float ogre_anim_death1 		= 11;
const float ogre_anim_death2 		= 12;
const float ogre_anim_pull 			= 13;

void M_Ogre_Attack_MachineGun()
{
	vector dir = normalize(self.enemy.origin - self.origin);
	vector org = self.origin + self.view_ofs + v_forward * 14;
	sound (self, CH_WEAPON_A, W_Sound("uzi_fire"), VOL_BASE, ATTEN_NORM);

	fireBullet(org, dir, autocvar_g_monster_ogre_attack_machinegun_spread, autocvar_g_monster_ogre_attack_machinegun_solidpenetration, autocvar_g_monster_ogre_attack_machinegun_damage, autocvar_g_monster_ogre_attack_machinegun_force, DEATH_MONSTER_OGRE_MACHINEGUN, 0);

	pointparticles(particleeffectnum("uzi_muzzleflash"), org, dir * 1000, 1);

	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);
}

void M_Ogre_Attack_Grenade_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	sound (self, CH_WEAPON_A, W_Sound("grenade_impact"), VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("grenade_explode"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, autocvar_g_monster_ogre_attack_grenade_damage, autocvar_g_monster_ogre_attack_grenade_edgedamage, autocvar_g_monster_ogre_attack_grenade_radius, world, autocvar_g_monster_ogre_attack_grenade_force, self.projectiledeathtype, other);

	remove (self);
}

void M_Ogre_Attack_Grenade_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health -= damage;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void M_Ogre_Attack_Grenade_Touch()
{
	PROJECTILE_TOUCH;

	if (other.takedamage == DAMAGE_AIM)
	{
		self.use();
		return;
	}

	float r;
	r = random() * 6;
	if(r < 1)
		spamsound (self, CH_SHOTS, W_Sound("grenade_bounce1"), VOL_BASE, ATTEN_NORM);
	else if(r < 2)
		spamsound (self, CH_SHOTS, W_Sound("grenade_bounce2"), VOL_BASE, ATTEN_NORM);
	else if(r < 3)
		spamsound (self, CH_SHOTS, W_Sound("grenade_bounce3"), VOL_BASE, ATTEN_NORM);
	else if(r < 4)
		spamsound (self, CH_SHOTS, W_Sound("grenade_bounce4"), VOL_BASE, ATTEN_NORM);
	else if(r < 5)
		spamsound (self, CH_SHOTS, W_Sound("grenade_bounce5"), VOL_BASE, ATTEN_NORM);
	else
		spamsound (self, CH_SHOTS, W_Sound("grenade_bounce6"), VOL_BASE, ATTEN_NORM);
	self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void M_Ogre_Attack_Grenade()
{
	entity gren;

	sound (self, CH_WEAPON_A, W_Sound("grenade_fire"), VOL_BASE, ATTEN_NORM);

	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	vector org = self.origin + v_forward * 14 + '0 0 30' + v_right * -14;

	makevectors(self.angles);

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), org, dir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_monster_ogre_attack_grenade_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_monster_ogre_attack_grenade_bouncefactor;
	gren.bouncestop = autocvar_g_monster_ogre_attack_grenade_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_OGRE_GRENADE;
	setorigin(gren, org);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_monster_ogre_attack_grenade_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = M_Ogre_Attack_Grenade_Explode;
	gren.touch = M_Ogre_Attack_Grenade_Touch;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_monster_ogre_attack_grenade_health;
	gren.damageforcescale = autocvar_g_monster_ogre_attack_grenade_damageforcescale;
	gren.event_damage = M_Ogre_Attack_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjectileVelocityEx(gren, dir, v_up, autocvar_g_monster_ogre_attack_grenade_speed, autocvar_g_monster_ogre_attack_grenade_speed_up, autocvar_g_monster_ogre_attack_grenade_speed_z, autocvar_g_monster_ogre_attack_grenade_spread, FALSE);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);

	self.attack_finished_single = time + 0.7;
	self.state = 0;
}

.float ogre_swing_prev;
.entity ogre_swing_alreadyhit;
void M_Ogre_Attack_Chainsaw()
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player, is_monster;
	entity target_victim;
	vector targpos;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time;
	}

	makevectors(self.realowner.angles); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = autocvar_g_monster_ogre_attack_melee_time;
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * autocvar_g_monster_ogre_attack_melee_traces);

	// check to see if we can still continue, otherwise give up now
	if(self.realowner.deadflag != DEAD_NO)
	{
		remove(self);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=self.ogre_swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_monster_ogre_attack_melee_traces)) * 2 - 1);

		targpos = (self.realowner.origin + self.realowner.view_ofs
			+ (v_forward * autocvar_g_monster_ogre_attack_melee_range)
			+ (v_up * swing_factor * autocvar_g_monster_ogre_attack_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_monster_ogre_attack_melee_swing_side));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, self, 0);

		// draw lightning beams for debugging
		te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5);
		te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body");
		is_monster = IS_MONSTER(trace_ent);

		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != self.ogre_swing_alreadyhit)
			&& ((is_player || is_monster) || autocvar_g_monster_ogre_attack_melee_nonplayerdamage))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player || is_monster) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (autocvar_g_monster_ogre_attack_melee_damage * min(1, swing_factor + 1));
			else
				swing_damage = (autocvar_g_monster_ogre_attack_melee_nonplayerdamage * min(1, swing_factor + 1));

			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, self.realowner, self.realowner,
				swing_damage, DEATH_MONSTER_OGRE_MELEE,
				self.realowner.origin + self.realowner.view_ofs,
				v_forward * 1);

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			self.ogre_swing_alreadyhit = target_victim;
			continue; // move along to next trace
		}
	}

	if(time >= self.cnt + meleetime)
	{
		// melee is finished
		self.realowner.frame = ogre_anim_idle;
		remove(self);
		return;
	}
	else
	{
		// set up next frame
		self.ogre_swing_prev = i;
		self.nextthink = time;
	}
}

float M_Ogre_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			vector vdir = normalize(self.enemy.origin - self.origin);

			if(vdir_z > 0.7)
			{
				self.attack_finished_single = time + 1.2;
				self.frame = ogre_anim_shoot;
				self.state = MONSTER_ATTACK_RANGED;
				Monster_Delay(2, 0.1, 0.4, M_Ogre_Attack_MachineGun);
				return TRUE;
			}
			entity meleetemp;
			meleetemp = spawn();
			meleetemp.realowner = self;
			meleetemp.think = M_Ogre_Attack_Chainsaw;
			meleetemp.nextthink = time + autocvar_g_monster_ogre_attack_melee_delay;
			self.attack_finished_single = time + autocvar_g_monster_ogre_attack_melee_time + autocvar_g_monster_ogre_attack_melee_delay + 0.7;
			self.state = MONSTER_ATTACK_MELEE;
			self.frame = ogre_anim_swing;

			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			Monster_Delay(0, 0, 0.5, M_Ogre_Attack_Grenade);
			self.state = MONSTER_ATTACK_RANGED;
			self.attack_finished_single = time + 0.5;
			self.frame = ogre_anim_shoot;
			return TRUE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_ogre() { Monster_Spawn(MON_OGRE); }

float M_Ogre(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			return TRUE;
		}
		case MR_PAIN:
		{
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = ((random() >= 0.5) ? ogre_anim_death1 : ogre_anim_death2);
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_ogre_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_ogre_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_ogre_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_ogre_speed_stop); }

			self.m_anim_walk = ogre_anim_walk;
			self.m_anim_run = ogre_anim_run;
			self.m_anim_idle = ogre_anim_idle;

			self.monster_loot = spawnfunc_item_rockets;
			self.weapon = WEP_UZI;
			self.frame = ogre_anim_pull;
			self.spawn_time = time + 1;
			self.spawnshieldtime = self.spawn_time;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/ogre.mdl");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
