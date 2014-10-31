#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ OGRE,
/* functions  */ M_Ogre, M_Ogre_Attack,
/* spawnflags */ MON_FLAG_MELEE | MONSTER_SIZE_BROKEN,
/* mins,maxs  */ '-36 -36 -20', '36 36 50',
/* model      */ "ogre.mdl",
/* netname    */ "ogre",
/* fullname   */ _("Ogre")
);

#else
#ifdef SVQC
float autocvar_g_monster_ogre_health;
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
				swing_damage, DEATH_MONSTER_ZOMBIE_MELEE,
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
				// TODO: uzi?
				return FALSE;
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
			// TODO
			// makevectors(self.angles);
			//return Monster_Projectile(self);
			return FALSE;
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
		case MR_DEATH:
		{
			self.frame = ((random() > 0.5) ? ogre_anim_death1 : ogre_anim_death2);
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
