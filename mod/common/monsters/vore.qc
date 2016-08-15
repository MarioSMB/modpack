
#ifndef VORE_H
#define VORE_H

#ifndef MENUQC
MODEL(MON_VORE, M_Model("shalrath.mdl"));

SOUND(VORE_FIRESPIKE, W_Sound("electro_fire"));
#endif

CLASS(Vore, Monster)
    ATTRIB(Vore, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Vore, mins, vector, '-32 -32 -24');
    ATTRIB(Vore, maxs, vector, '32 32 64');
#ifndef MENUQC
    ATTRIB(Vore, m_model, Model, MDL_MON_VORE);
#endif
    ATTRIB(Vore, netname, string, "vore");
    ATTRIB(Vore, monster_name, string, "Vore");
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
/* wepname   */ ATTRIB(VoreSpike, message, string, "Vore spike");
ENDCLASS(VoreSpike)
REGISTER_WEAPON(VORE_SPIKE, NEW(VoreSpike));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

void M_Vore_Attack_Spike(entity actor, vector dir);
METHOD(VoreSpike, wr_think, void(VoreSpike thiswep, entity actor, .entity weaponentity, int fire)) {
    //if (fire & 1)
    if (!IS_PLAYER(actor) || weapon_prepareattack(thiswep, actor, weaponentity, false, 0.2)) {
        if (!actor.target_range) actor.target_range = autocvar_g_monsters_target_range;
        actor.enemy = Monster_FindTarget(actor);
        W_SetupShot_Dir(actor, weaponentity, v_forward, false, 0, SND_VORE_FIRESPIKE, CH_WEAPON_B, 0);
    	if (!IS_PLAYER(actor)) w_shotdir = normalize((actor.enemy.origin + '0 0 10') - actor.origin);
        M_Vore_Attack_Spike(actor, w_shotdir);
        weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, w_ready);
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

void M_Vore_Attack_Spike_Explode(entity this, entity directhitentity)
{
	this.event_damage = func_null;

	sound(this, CH_SHOTS, SND_GRENADE_IMPACT, VOL_BASE, ATTEN_NORM);

	this.realowner.vore_spike = world;

	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	RadiusDamage (this, this.realowner, (autocvar_g_monster_vore_attack_spike_damage), (autocvar_g_monster_vore_attack_spike_damage) * 0.5, (autocvar_g_monster_vore_attack_spike_radius), world, world, 0, DEATH_MONSTER_MAGE.m_id, directhitentity);

	remove (this);
}

void M_Vore_Attack_Spike_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	M_Vore_Attack_Spike_Explode(this, toucher);
}

.float wait;

// copied from W_Seeker_Think
void M_Vore_Attack_Spike_Think(entity this)
{
	if (time > this.ltime || (this.enemy && this.enemy.health <= 0) || this.owner.health <= 0) {
		this.projectiledeathtype |= HITTYPE_SPLASH;
		M_Vore_Attack_Spike_Explode(this, NULL);
	}

	float spd = vlen(this.velocity);
	spd = bound(
		spd - (autocvar_g_monster_vore_attack_spike_decel) * frametime,
		(autocvar_g_monster_vore_attack_spike_speed_max),
		spd + (autocvar_g_monster_vore_attack_spike_accel) * frametime
	);

	if (this.enemy != world)
		if (this.enemy.takedamage != DAMAGE_AIM || IS_DEAD(this.enemy))
			this.enemy = world;

	if (this.enemy != world)
	{
		entity e = this.enemy;
		vector eorg = 0.5 * (e.absmin + e.absmax);
		float turnrate = (autocvar_g_monster_vore_attack_spike_turnrate); // how fast to turn
		vector desireddir = normalize(eorg - this.origin);
		vector olddir = normalize(this.velocity); // get my current direction
		float dist = vlen(eorg - this.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if ((autocvar_g_monster_vore_attack_spike_smart) && (dist > (autocvar_g_monster_vore_attack_spike_smart_mindist)))
		{
			// Is it a better idea (shorter distance) to trace to the target itthis?
			if(vdist(this.origin + olddir * this.wait, <, dist))
				traceline(this.origin, this.origin + olddir * this.wait, false, this);
			else
				traceline(this.origin, eorg, false, this);

			// Setup adaptive tracelength
			this.wait = bound((autocvar_g_monster_vore_attack_spike_smart_trace_min), vlen(this.origin - trace_endpos), this.wait = (autocvar_g_monster_vore_attack_spike_smart_trace_max));

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}

		vector newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		this.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	}

	///////////////

	//this.angles = vectoangles(this.velocity);			// turn model in the new flight direction
	this.nextthink = time;// + 0.05; // csqc projectiles
	UpdateCSQCProjectile(this);
}

void M_Vore_Attack_Spike(entity this, vector dir)
{
	makevectors(this.angles);

	entity missile = spawn();
	missile.owner = missile.realowner = this;
	setthink(missile, M_Vore_Attack_Spike_Think);
	missile.ltime = time + 7;
	missile.nextthink = time;
	missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, missile);
	setorigin(missile, this.origin + v_forward * 14 + '0 0 30' + v_right * -14);
	setsize(missile, '0 0 0', '0 0 0');
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.enemy = this.enemy;
	settouch(missile, M_Vore_Attack_Spike_Touch);

	this.vore_spike = missile;

	CSQCProjectile(missile, true, PROJECTILE_MAGE_SPIKE, true);
}

bool M_Vore_Attack(int attack_type, entity actor, entity targ)
{
	.entity weaponentity = weaponentities[0];
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			if(!actor.vore_spike)
			{
				setanim(actor, actor.anim_shoot, true, true, true);
				actor.attack_finished_single[0] = time + (autocvar_g_monster_vore_attack_spike_delay);
				actor.anim_finished = time + 1;
				Weapon wep = WEP_VORE_SPIKE;
				wep.wr_think(wep, actor, weaponentity, 1);
				return true;
			}

			if(actor.vore_spike)
				return true;
			else
				return false;
		}
	}

	return false;
}

spawnfunc(monster_shalrath) { Monster_Spawn(this, MON_VORE.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Vore, mr_think, bool(Monster thismon, entity actor))
		{
			return true;
		}
		METHOD(Vore, mr_death, bool(Monster thismon, entity actor))
		{
			setanim(actor, actor.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Vore, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '2 1 1', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '3 1.2 1', none);
			actor.anim_idle = animfixfps(actor, '3 1.2 1', none);
			actor.anim_pain1 = animfixfps(actor, '1 0.4 1', none); // 0.5 seconds
			actor.anim_shoot = animfixfps(actor, '0 1 1', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '3 1.2 1.3', none);
			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		//spawnfunc(item_health_large);
		METHOD(Vore, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_vore_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_vore_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_vore_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_vore_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_vore_damageforcescale); }

			//actor.monster_loot = spawnfunc_item_health_large;
			actor.monster_attackfunc = M_Vore_Attack;

			return true;
		}
		METHOD(Vore, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
