#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ MAGE,
/* functions  */ M_Mage, M_Mage_Attack,
/* spawnflags */ MON_FLAG_MELEE | MON_FLAG_RANGED,
/* mins,maxs  */ '-36 -36 -24', '36 36 50',
/* model      */ "mage.dpm",
/* netname    */ "mage",
/* fullname   */ _("Mage")
);

#else
#ifdef SVQC
float autocvar_g_monster_mage_health;
float autocvar_g_monster_mage_attack_spike_damage;
float autocvar_g_monster_mage_attack_spike_radius;
float autocvar_g_monster_mage_attack_spike_delay;
float autocvar_g_monster_mage_attack_spike_accel;
float autocvar_g_monster_mage_attack_spike_decel;
float autocvar_g_monster_mage_attack_spike_turnrate;
float autocvar_g_monster_mage_attack_spike_speed_max;
float autocvar_g_monster_mage_attack_spike_smart;
float autocvar_g_monster_mage_attack_spike_smart_trace_min;
float autocvar_g_monster_mage_attack_spike_smart_trace_max;
float autocvar_g_monster_mage_attack_spike_smart_mindist;
float autocvar_g_monster_mage_attack_push_damage;
float autocvar_g_monster_mage_attack_push_radius;
float autocvar_g_monster_mage_attack_push_delay;
float autocvar_g_monster_mage_attack_push_force;
float autocvar_g_monster_mage_heal_self;
float autocvar_g_monster_mage_heal_allies;
float autocvar_g_monster_mage_heal_minhealth;
float autocvar_g_monster_mage_heal_range;
float autocvar_g_monster_mage_heal_delay;
float autocvar_g_monster_mage_shield_time;
float autocvar_g_monster_mage_shield_delay;
float autocvar_g_monster_mage_shield_blockpercent;
float autocvar_g_monster_mage_speed_stop;
float autocvar_g_monster_mage_speed_run;
float autocvar_g_monster_mage_speed_walk;

const float mage_anim_idle		= 0;
const float mage_anim_walk		= 1;
const float mage_anim_attack	= 2;
const float mage_anim_pain		= 3;
const float mage_anim_death		= 4;
const float mage_anim_run		= 5;

void() M_Mage_Defend_Heal;
void() M_Mage_Defend_Shield;

.entity mage_spike;
.float mage_shield_delay;
.float mage_shield_time;

float M_Mage_Defend_Heal_Check(entity e)
{
	if(e == world)
		return FALSE;
	if(e.health <= 0)
		return FALSE;
	if(DIFF_TEAM(e, self) && e != self.monster_follow)
		return FALSE;
	if(e.frozen)
		return FALSE;
	if(!IS_PLAYER(e))
		return (IS_MONSTER(e) && e.health < e.max_health);
	if(e.items & IT_INVINCIBLE)
		return FALSE;

	switch(self.skin)
	{
		case 0: return (e.health < autocvar_g_balance_health_regenstable);
		case 1: return ((e.ammo_cells && e.ammo_cells < g_pickup_cells_max) || (e.ammo_rockets && e.ammo_rockets < g_pickup_rockets_max) || (e.ammo_nails && e.ammo_nails < g_pickup_nails_max) || (e.ammo_shells && e.ammo_shells < g_pickup_shells_max));
		case 2: return (e.armorvalue < autocvar_g_balance_armor_regenstable);
		case 3: return (e.health > 0);
	}

	return FALSE;
}

void M_Mage_Attack_Spike_Explode()
{
	self.event_damage = func_null;

	sound(self, CH_SHOTS, W_Sound("grenade_impact"), VOL_BASE, ATTEN_NORM);

	self.realowner.mage_spike = world;

	pointparticles(particleeffectnum("explosion_small"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, (autocvar_g_monster_mage_attack_spike_damage), (autocvar_g_monster_mage_attack_spike_damage) * 0.5, (autocvar_g_monster_mage_attack_spike_radius), world, 0, DEATH_MONSTER_MAGE, other);

	remove (self);
}

void M_Mage_Attack_Spike_Touch()
{
	PROJECTILE_TOUCH;

	M_Mage_Attack_Spike_Explode();
}

// copied from W_Seeker_Think
void M_Mage_Attack_Spike_Think()
{
	entity e;
	vector desireddir, olddir, newdir, eorg;
	float turnrate;
	float dist;
	float spd;

	if (time > self.ltime || self.enemy.health <= 0 || self.owner.health <= 0)
	{
		self.projectiledeathtype |= HITTYPE_SPLASH;
		M_Mage_Attack_Spike_Explode();
	}

	spd = vlen(self.velocity);
	spd = bound(
		spd - (autocvar_g_monster_mage_attack_spike_decel) * frametime,
		(autocvar_g_monster_mage_attack_spike_speed_max),
		spd + (autocvar_g_monster_mage_attack_spike_accel) * frametime
	);

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if (self.enemy != world)
	{
		e				= self.enemy;
		eorg			= 0.5 * (e.absmin + e.absmax);
		turnrate		= (autocvar_g_monster_mage_attack_spike_turnrate); // how fast to turn
		desireddir		= normalize(eorg - self.origin);
		olddir			= normalize(self.velocity); // get my current direction
		dist			= vlen(eorg - self.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if ((autocvar_g_monster_mage_attack_spike_smart) && (dist > (autocvar_g_monster_mage_attack_spike_smart_mindist)))
		{
			// Is it a better idea (shorter distance) to trace to the target itself?
			if ( vlen(self.origin + olddir * self.wait) < dist)
				traceline(self.origin, self.origin + olddir * self.wait, FALSE, self);
			else
				traceline(self.origin, eorg, FALSE, self);

			// Setup adaptive tracelength
			self.wait = bound((autocvar_g_monster_mage_attack_spike_smart_trace_min), vlen(self.origin - trace_endpos), self.wait = (autocvar_g_monster_mage_attack_spike_smart_trace_max));

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}

		newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		self.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	}
	else
		dist = 0;

	///////////////

	//self.angles = vectoangles(self.velocity);			// turn model in the new flight direction
	self.nextthink = time;// + 0.05; // csqc projectiles
	UpdateCSQCProjectile(self);
}

void M_Mage_Attack_Spike()
{
	entity missile;
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	makevectors(self.angles);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.think = M_Mage_Attack_Spike_Think;
	missile.ltime = time + 7;
	missile.nextthink = time;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.flags = FL_PROJECTILE;
	setorigin(missile, self.origin + v_forward * 14 + '0 0 30' + v_right * -14);
	setsize (missile, '0 0 0', '0 0 0');
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.enemy = self.enemy;
	missile.touch = M_Mage_Attack_Spike_Touch;

	self.mage_spike = missile;

	CSQCProjectile(missile, TRUE, PROJECTILE_MAGE_SPIKE, TRUE);
}

void M_Mage_Defend_Heal()
{
	entity head;
	float washealed = FALSE;

	for(head = findradius(self.origin, (autocvar_g_monster_mage_heal_range)); head; head = head.chain) if(M_Mage_Defend_Heal_Check(head))
	{
		washealed = TRUE;
		string fx = "";
		if(IS_PLAYER(head))
		{
			switch(self.skin)
			{
				case 0:
					if(head.health < autocvar_g_balance_health_regenstable) head.health = bound(0, head.health + (autocvar_g_monster_mage_heal_allies), autocvar_g_balance_health_regenstable);
					fx = "healing_fx";
					break;
				case 1:
					if(head.ammo_cells) head.ammo_cells = bound(head.ammo_cells, head.ammo_cells + 1, g_pickup_cells_max);
					if(head.ammo_rockets) head.ammo_rockets = bound(head.ammo_rockets, head.ammo_rockets + 1, g_pickup_rockets_max);
					if(head.ammo_shells) head.ammo_shells = bound(head.ammo_shells, head.ammo_shells + 2, g_pickup_shells_max);
					if(head.ammo_nails) head.ammo_nails = bound(head.ammo_nails, head.ammo_nails + 5, g_pickup_nails_max);
					fx = "ammoregen_fx";
					break;
				case 2:
					if(head.armorvalue < autocvar_g_balance_armor_regenstable)
					{
						head.armorvalue = bound(0, head.armorvalue + (autocvar_g_monster_mage_heal_allies), autocvar_g_balance_armor_regenstable);
						fx = "armorrepair_fx";
					}
					break;
				case 3:
					head.health = bound(0, head.health - ((head == self)  ? (autocvar_g_monster_mage_heal_self) : (autocvar_g_monster_mage_heal_allies)), autocvar_g_balance_health_regenstable);
					fx = "rage";
					break;
			}

			pointparticles(particleeffectnum(fx), head.origin, '0 0 0', 1);
		}
		else
		{
			pointparticles(particleeffectnum("healing_fx"), head.origin, '0 0 0', 1);
			head.health = bound(0, head.health + (autocvar_g_monster_mage_heal_allies), head.max_health);
			if(!(head.spawnflags & MONSTERFLAG_INVINCIBLE) && head.sprite)
				WaypointSprite_UpdateHealth(head.sprite, head.health);
		}
	}

	if(washealed)
	{
		self.frame = mage_anim_attack;
		self.attack_finished_single = time + (autocvar_g_monster_mage_heal_delay);
	}
}

void M_Mage_Attack_Push()
{
	sound(self, CH_SHOTS, W_Sound("tagexp1"), 1, ATTEN_NORM);
	RadiusDamage (self, self, (autocvar_g_monster_mage_attack_push_damage), (autocvar_g_monster_mage_attack_push_damage), (autocvar_g_monster_mage_attack_push_radius), world, (autocvar_g_monster_mage_attack_push_force), DEATH_MONSTER_MAGE, self.enemy);
	pointparticles(particleeffectnum("TE_EXPLOSION"), self.origin, '0 0 0', 1);

	self.frame = mage_anim_attack;
	self.attack_finished_single = time + (autocvar_g_monster_mage_attack_push_delay);
}

void M_Mage_Attack_Teleport()
{
	if(vlen(self.enemy.origin - self.origin) >= 500)
		return;

	makevectors(self.enemy.angles);
	tracebox(self.enemy.origin + ((v_forward * -1) * 200), self.mins, self.maxs, self.origin, MOVE_NOMONSTERS, self);

	if(trace_fraction < 1)
		return;

	pointparticles(particleeffectnum("spawn_event_neutral"), self.origin, '0 0 0', 1);
	setorigin(self, self.enemy.origin + ((v_forward * -1) * 200));

	self.attack_finished_single = time + 0.2;
}

void M_Mage_Defend_Shield_Remove()
{
	self.effects &= ~(EF_ADDITIVE | EF_BLUE);
	self.armorvalue = autocvar_g_monsters_armor_blockpercent;
}

void M_Mage_Defend_Shield()
{
	self.effects |= (EF_ADDITIVE | EF_BLUE);
	self.mage_shield_delay = time + (autocvar_g_monster_mage_shield_delay);
	self.armorvalue = (autocvar_g_monster_mage_shield_blockpercent);
	self.mage_shield_time = time + (autocvar_g_monster_mage_shield_time);
	self.frame = mage_anim_attack;
	self.attack_finished_single = time + 1;
}

float M_Mage_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			if(random() <= 0.7)
			{
				M_Mage_Attack_Push();
				return TRUE;
			}

			return FALSE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(!self.mage_spike)
			{
				if(random() <= 0.4)
				{
					M_Mage_Attack_Teleport();
					return TRUE;
				}
				else
				{
					self.frame = mage_anim_attack;
					self.attack_finished_single = time + (autocvar_g_monster_mage_attack_spike_delay);
					Monster_Delay(1, 0, 0.2, M_Mage_Attack_Spike);
					return TRUE;
				}
			}

			if(self.mage_spike)
				return TRUE;
			else
				return FALSE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_mage() { Monster_Spawn(MON_MAGE); }

// extra monsters contains original shalrath
#ifndef MONSTERS_EXTRA
// compatibility with old spawns
void spawnfunc_monster_shalrath() { spawnfunc_monster_mage(); }
#endif

float M_Mage(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			entity head;
			float need_help = FALSE;

			for(head = world; (head = findfloat(head, iscreature, TRUE)); )
			if(head != self)
			if(vlen(head.origin - self.origin) <= (autocvar_g_monster_mage_heal_range))
			if(M_Mage_Defend_Heal_Check(head))
			{
				need_help = TRUE;
				break;
			}

			if(self.health < (autocvar_g_monster_mage_heal_minhealth) || need_help)
			if(time >= self.attack_finished_single)
			if(random() < 0.5)
				M_Mage_Defend_Heal();

			if(time >= self.mage_shield_time && self.armorvalue)
				M_Mage_Defend_Shield_Remove();

			if(self.enemy)
			if(self.health < self.max_health)
			if(time >= self.mage_shield_delay)
			if(random() < 0.5)
				M_Mage_Defend_Shield();

			return TRUE;
		}
		case MR_PAIN:
		{
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = mage_anim_death;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_mage_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_mage_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_mage_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_mage_speed_stop); }

			self.m_anim_walk = mage_anim_walk;
			self.m_anim_run = mage_anim_run;
			self.m_anim_idle = mage_anim_idle;

			self.monster_loot = spawnfunc_item_health_large;
			self.frame = mage_anim_walk;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_sound (W_Sound("grenade_impact"));
			precache_sound (W_Sound("tagexp1"));
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
