#ifndef SCRAG_H
#define SCRAG_H

#ifndef MENUQC
MODEL(MON_SCRAG, M_Model("scrag.mdl"));

SOUND(SCRAG_FIRESPIKE, W_Sound("electro_fire"));
#endif

CLASS(Scrag, Monster)
    ATTRIB(Scrag, spawnflags, int, MONSTER_SIZE_QUAKE | MONSTER_TYPE_FLY | MON_FLAG_RANGED);
    ATTRIB(Scrag, mins, vector, '-16 -16 -24');
    ATTRIB(Scrag, maxs, vector, '16 16 40');
#ifndef MENUQC
    ATTRIB(Scrag, m_model, Model, MDL_MON_SCRAG);
#endif
    ATTRIB(Scrag, netname, string, "scrag");
    ATTRIB(Scrag, monster_name, string, _("Scrag"));
ENDCLASS(Scrag)

REGISTER_MONSTER(SCRAG, NEW(Scrag)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

CLASS(ScragAttack, PortoLaunch)
/* flags     */ ATTRIB(ScragAttack, spawnflags, int, WEP_TYPE_OTHER | WEP_FLAG_HIDDEN | WEP_FLAG_MUTATORBLOCKED);
/* impulse   */ ATTRIB(ScragAttack, impulse, int, 9);
/* refname   */ ATTRIB(ScragAttack, netname, string, "scrag");
/* wepname   */ ATTRIB(ScragAttack, message, string, _("Scrag attack"));
ENDCLASS(ScragAttack)
REGISTER_WEAPON(SCRAG_ATTACK, NEW(ScragAttack));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_scrag_attack_spike_damage = 10;
float autocvar_g_monster_scrag_attack_spike_edgedamage = 4;
float autocvar_g_monster_scrag_attack_spike_force = 10;
float autocvar_g_monster_scrag_attack_spike_radius = 10;
float autocvar_g_monster_scrag_attack_spike_speed = 600;

void M_Scrag_Attack_Spike_Explode(entity this);
void M_Scrag_Attack_Spike_Touch(entity this);

METHOD(ScragAttack, wr_think, void(ScragAttack thiswep, entity actor, .entity weaponentity, int fire)) {
    if (fire & 1)
    if (time > actor.attack_finished_single[0] || weapon_prepareattack(thiswep, actor, weaponentity, false, 1.2)) {
        if (IS_PLAYER(actor)) W_SetupShot_Dir(actor, v_forward, false, 0, SND_SCRAG_FIRESPIKE, CH_WEAPON_B, 0);
		if (IS_MONSTER(actor)) {
			actor.attack_finished_single[0] = time + 1.2;
			actor.anim_finished = time + 1.2;
			monster_makevectors(actor, actor.enemy);
		}

		entity missile = spawn();
		missile.owner = missile.realowner = actor;
		missile.solid = SOLID_TRIGGER;
		missile.movetype = MOVETYPE_FLYMISSILE;
		missile.projectiledeathtype = DEATH_MONSTER_WYVERN.m_id;
		setsize(missile, '-6 -6 -6', '6 6 6');
		setorigin(missile, actor.origin + actor.view_ofs + v_forward * 14);
		missile.flags = FL_PROJECTILE;
		missile.velocity = w_shotdir * (autocvar_g_monster_scrag_attack_spike_speed);
		missile.avelocity = '300 300 300';
		missile.nextthink = time + 5;
		setthink(missile, M_Scrag_Attack_Spike_Explode);
		settouch(missile, M_Scrag_Attack_Spike_Touch);
		CSQCProjectile(missile, true, PROJECTILE_CRYLINK, true);

        weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, w_ready);
    }
}

METHOD(ScragAttack, wr_checkammo1, bool(ScragAttack thiswep, entity actor)) {
	return true;
}

float autocvar_g_monster_scrag_health = 110;
float autocvar_g_monster_scrag_damageforcescale = 0.55;
float autocvar_g_monster_scrag_speed_stop = 50;
float autocvar_g_monster_scrag_speed_run = 120;
float autocvar_g_monster_scrag_speed_walk = 80;

/*
const float scrag_anim_hover	= 0;
const float scrag_anim_fly		= 1;
const float scrag_anim_magic	= 2;
const float scrag_anim_pain	= 3;
const float scrag_anim_death	= 4;
*/

void M_Scrag_Attack_Spike_Explode(entity this)
{
	//Send_Effect(EFFECT_FIREBALL_EXPLODE, this.origin, '0 0 0', 1);
	__pointparticles(_particleeffectnum("TE_WIZSPIKE"), this.origin, '0 0 0', 1);

	entity own = this.realowner;

	RadiusDamage(this, own, autocvar_g_monster_scrag_attack_spike_damage, autocvar_g_monster_scrag_attack_spike_edgedamage, autocvar_g_monster_scrag_attack_spike_force, 
		world, world, autocvar_g_monster_scrag_attack_spike_radius, this.projectiledeathtype, world);

	remove(this);
}

void M_Scrag_Attack_Spike_Touch(entity this)
{
	PROJECTILE_TOUCH(this);
	if(other == this.owner) { return; }

	M_Scrag_Attack_Spike_Explode(this);
}

bool M_Scrag_Attack(int attack_type, entity actor, entity targ)
{
	.entity weaponentity = weaponentities[0];
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			w_shotdir = normalize((actor.enemy.origin + '0 0 10') - actor.origin);
			Weapon wep = WEP_SCRAG_ATTACK;
			wep.wr_think(wep, actor, weaponentity, 1);

			if(random() <= 0.1 || actor.monster_moveto)
			{
				makevectors(actor.angles);
				actor.monster_moveto = actor.origin + '1 1 0' * (random() >= 0.5) ? (v_right * 300) : (v_right * -300);
				actor.monster_face = actor.enemy.origin; // but still look at enemy
				if(random() <= 0.4)
					actor.monster_moveto = actor.monster_face = '0 0 0';
			}
			return true;
		}
	}

	return false;
}

spawnfunc(monster_scrag) { Monster_Spawn(this, MON_SCRAG.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Scrag, mr_think, bool(Scrag thismon, entity actor))
		{
			return true;
		}
		METHOD(Scrag, mr_pain, bool(Scrag thismon, entity actor))
		{
			actor.pain_finished = time + 0.5;
			setanim(actor, actor.anim_pain1, true, true, false);
			return true;
		}
		METHOD(Scrag, mr_death, bool(Scrag thismon, entity actor))
		{
			setanim(actor, actor.anim_die1, false, true, true);
			actor.velocity_x = -200 + 400 * random();
			actor.velocity_y = -200 + 400 * random();
			actor.velocity_z = 100 + 100 * random();
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Scrag, mr_anim, bool(Scrag thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '4 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '1 1 1', none);
			actor.anim_idle = animfixfps(actor, '0 1 1', none);
			actor.anim_pain1 = animfixfps(actor, '3 1 2', none); // 0.5 seconds
			actor.anim_shoot = animfixfps(actor, '2 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '1 1 1', none);
			return true;
		}
		#endif
		#ifdef SVQC
		spawnfunc(item_cells);
		METHOD(Scrag, mr_setup, bool(Scrag thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_scrag_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_scrag_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_scrag_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_scrag_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_scrag_damageforcescale); }

			//actor.monster_loot = spawnfunc_item_cells;
			actor.monster_attackfunc = M_Scrag_Attack;

			return true;
		}
		METHOD(Scrag, mr_precache, bool(Scrag thismon))
		{
			return true;
		}
		#endif

#endif
