
#ifndef VORE_H
#define VORE_H

#ifndef MENUQC
MODEL(MON_VORE, "models/monsters/shalrath.mdl");
#endif

CLASS(Vore, Monster)
    ATTRIB(Vore, spawnflags, int, MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Vore, mins, vector, '-32 -32 -24');
    ATTRIB(Vore, maxs, vector, '32 32 64');
#ifndef MENUQC
    ATTRIB(Vore, m_model, Model, MDL_MON_VORE);
#endif
    ATTRIB(Vore, netname, string, "vore");
    ATTRIB(Vore, monster_name, string, _("Vore"));
ENDCLASS(Vore)

REGISTER_MONSTER(VORE, NEW(Vore)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

CLASS(VoreSpike, PortoLaunch)
/* flags     */ ATTRIB(VoreSpike, spawnflags, int, WEP_TYPE_OTHER | WEP_FLAG_HIDDEN | WEP_FLAG_MUTATORBLOCKED);
/* impulse   */ ATTRIB(VoreSpike, impulse, int, 9);
/* refname   */ ATTRIB(VoreSpike, netname, string, "vorespike");
/* wepname   */ ATTRIB(VoreSpike, message, string, _("Vore spike"));
ENDCLASS(VoreSpike)
REGISTER_WEAPON(VORE_SPIKE, NEW(VoreSpike));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

void M_Vore_Attack_Spike(vector dir);
METHOD(VoreSpike, wr_think, void(VoreSpike thiswep, entity actor, bool fire1, bool fire2)) {
    //if (fire1)
    if (!IS_PLAYER(actor) || weapon_prepareattack(thiswep, actor, false, 0.2)) {
        if (!actor.target_range) actor.target_range = autocvar_g_monsters_target_range;
        actor.enemy = Monster_FindTarget(actor);
        W_SetupShot_Dir(actor, v_forward, false, 0, W_Sound("electro_fire"), CH_WEAPON_B, 0);
    	if (!IS_PLAYER(actor)) w_shotdir = normalize((actor.enemy.origin + '0 0 10') - actor.origin);
        M_Vore_Attack_Spike(w_shotdir);
        weapon_thinkf(actor, WFRAME_FIRE1, 0, w_ready);
    }
}

AUTOCVAR(g_monster_vore_health, int, 400, "");
AUTOCVAR(g_monster_vore_damageforcescale, float, 0.5, "");
AUTOCVAR(g_monster_vore_attack_spike_damage, float, 40, "");
AUTOCVAR(g_monster_vore_attack_spike_radius, float, 50, "");
AUTOCVAR(g_monster_vore_attack_spike_delay, float, 2, "");
AUTOCVAR(g_monster_vore_attack_spike_accel, float, 480, "");
AUTOCVAR(g_monster_vore_attack_spike_decel, float, 480, "");
AUTOCVAR(g_monster_vore_attack_spike_turnrate, float, 0.65, "");
AUTOCVAR(g_monster_vore_attack_spike_speed_max, float, 370, "");
AUTOCVAR(g_monster_vore_attack_spike_smart, bool, true, "");
AUTOCVAR(g_monster_vore_attack_spike_smart_trace_min, float, 1000, "");
AUTOCVAR(g_monster_vore_attack_spike_smart_trace_max, float, 2500, "");
AUTOCVAR(g_monster_vore_attack_spike_smart_mindist, float, 600, "");
AUTOCVAR(g_monster_vore_speed_stop, float, 50, "");
AUTOCVAR(g_monster_vore_speed_run, float, 100, "");
AUTOCVAR(g_monster_vore_speed_walk, float, 70, "");

/*
const float vore_anim_idle		= 0;
const float vore_anim_walk		= 1;
const float vore_anim_attack	= 2;
const float vore_anim_pain		= 3;
const float vore_anim_death		= 4;
const float vore_anim_run		= 5;
*/

.entity vore_spike;

void M_Vore_Attack_Spike_Explode()
{SELFPARAM();
	self.event_damage = func_null;

	sound(self, CH_SHOTS, SND_GRENADE_IMPACT, VOL_BASE, ATTEN_NORM);

	self.realowner.vore_spike = world;

	Send_Effect(EFFECT_EXPLOSION_SMALL, self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, (autocvar_g_monster_vore_attack_spike_damage), (autocvar_g_monster_vore_attack_spike_damage) * 0.5, (autocvar_g_monster_vore_attack_spike_radius), world, world, 0, DEATH_MONSTER_MAGE.m_id, other);

	remove (self);
}

void M_Vore_Attack_Spike_Touch()
{
	PROJECTILE_TOUCH;

	M_Vore_Attack_Spike_Explode();
}

.float wait;

// copied from W_Seeker_Think
void M_Vore_Attack_Spike_Think()
{SELFPARAM();
	if (time > self.ltime || (self.enemy && self.enemy.health <= 0) || self.owner.health <= 0) {
		self.projectiledeathtype |= HITTYPE_SPLASH;
		M_Vore_Attack_Spike_Explode();
	}

	float spd = vlen(self.velocity);
	spd = bound(
		spd - (autocvar_g_monster_vore_attack_spike_decel) * frametime,
		(autocvar_g_monster_vore_attack_spike_speed_max),
		spd + (autocvar_g_monster_vore_attack_spike_accel) * frametime
	);

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if (self.enemy != world)
	{
		entity e = self.enemy;
		vector eorg = 0.5 * (e.absmin + e.absmax);
		float turnrate = (autocvar_g_monster_vore_attack_spike_turnrate); // how fast to turn
		vector desireddir = normalize(eorg - self.origin);
		vector olddir = normalize(self.velocity); // get my current direction
		float dist = vlen(eorg - self.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if ((autocvar_g_monster_vore_attack_spike_smart) && (dist > (autocvar_g_monster_vore_attack_spike_smart_mindist)))
		{
			// Is it a better idea (shorter distance) to trace to the target itself?
			if ( vlen(self.origin + olddir * self.wait) < dist)
				traceline(self.origin, self.origin + olddir * self.wait, false, self);
			else
				traceline(self.origin, eorg, false, self);

			// Setup adaptive tracelength
			self.wait = bound((autocvar_g_monster_vore_attack_spike_smart_trace_min), vlen(self.origin - trace_endpos), self.wait = (autocvar_g_monster_vore_attack_spike_smart_trace_max));

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}

		vector newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		self.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	}

	///////////////

	//self.angles = vectoangles(self.velocity);			// turn model in the new flight direction
	self.nextthink = time;// + 0.05; // csqc projectiles
	UpdateCSQCProjectile(self);
}

void M_Vore_Attack_Spike(vector dir)
{
	SELFPARAM();
	makevectors(self.angles);

	entity missile = spawn();
	missile.owner = missile.realowner = self;
	missile.think = M_Vore_Attack_Spike_Think;
	missile.ltime = time + 7;
	missile.nextthink = time;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.flags = FL_PROJECTILE;
	setorigin(missile, self.origin + v_forward * 14 + '0 0 30' + v_right * -14);
	setsize(missile, '0 0 0', '0 0 0');
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.enemy = self.enemy;
	missile.touch = M_Vore_Attack_Spike_Touch;

	self.vore_spike = missile;

	CSQCProjectile(missile, true, PROJECTILE_MAGE_SPIKE, true);
}

float M_Vore_Attack(float attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			if(!self.vore_spike)
			{
				setanim(self, self.anim_shoot, true, true, true);
				self.attack_finished_single = time + (autocvar_g_monster_vore_attack_spike_delay);
				self.anim_finished = time + 1;
				Weapon wep = WEP_VORE_SPIKE;
				wep.wr_think(wep, self, true, false);
				return true;
			}

			if(self.vore_spike)
				return true;
			else
				return false;
		}
	}

	return false;
}

spawnfunc(monster_shalrath) { Monster_Spawn(MON_VORE.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Vore, mr_think, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Vore, mr_pain, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Vore, mr_death, bool(Monster thismon))
		{
			SELFPARAM();
			setanim(self, self.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Vore, mr_anim, bool(Monster thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '2 1 1', none); // 2 seconds
			self.anim_walk = animfixfps(self, '3 1.2 1', none);
			self.anim_idle = animfixfps(self, '3 1.2 1', none);
			self.anim_pain1 = animfixfps(self, '1 0.4 1', none); // 0.5 seconds
			self.anim_shoot = animfixfps(self, '0 1 1', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '3 1.2 1.3', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		//spawnfunc(item_health_large);
		METHOD(Vore, mr_setup, bool(Monster thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_vore_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_vore_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_vore_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_vore_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_vore_damageforcescale); }

			//self.monster_loot = spawnfunc_item_health_large;
			self.monster_attackfunc = M_Vore_Attack;

			return true;
		}
		METHOD(Vore, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
