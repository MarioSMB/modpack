#ifndef KOOPA_H
#define KOOPA_H

#ifndef MENUQC
MODEL(MON_KOOPA, M_Model("koopa.dpm"));
MODEL(MON_KOOPA_DEAD, M_Model("koopa_shell.md3"));

MSG_INFO_NOTIF(DEATH_SELF_MON_KOOPA,             			1, 2, 1, "s1 s2loc spree_lost", "s1",    	"notify_death",         			"^BG%s^K1 was bitten by a Koopa Troopa%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_KOOPA,                		1,  NULL,           						INFO_DEATH_SELF_MON_KOOPA,   		CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_KOOPA,            				DEATH_SELF_MON_KOOPA,            			DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Koopa, Monster)
    ATTRIB(Koopa, spawnflags, int, MONSTER_TYPE_PASSIVE | MON_FLAG_CRUSH | MON_FLAG_HIDDEN);
    ATTRIB(Koopa, m_mins, vector, '-15 -15 -32');
    ATTRIB(Koopa, m_maxs, vector, '15 15 10');
#ifndef MENUQC
    ATTRIB(Koopa, m_model, Model, MDL_MON_KOOPA);
#endif
    ATTRIB(Koopa, netname, string, "koopa");
    ATTRIB(Koopa, monster_name, string, "Koopa");
ENDCLASS(Koopa)

REGISTER_MONSTER(KOOPA, NEW(Koopa)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_koopa_health, float, 50, "");
AUTOCVAR(g_monster_koopa_damageforcescale, float, 0.35, "");
AUTOCVAR(g_monster_koopa_attack_melee_damage, float, 50, "");
AUTOCVAR(g_monster_koopa_attack_melee_delay, float, 0.55, "");
AUTOCVAR(g_monster_koopa_speed_stop, float, 100, "");
//AUTOCVAR(g_monster_koopa_speed_run, float, 220, "");
AUTOCVAR(g_monster_koopa_speed_walk, float, 70, "");
AUTOCVAR(g_monster_koopa_allow_jumpoff, bool, false, "");

/*
const float koopa_anim_idle = 0;
const float koopa_anim_walk = 1;
*/

void M_Koopa_Touch(entity this, entity toucher)
{
#if 0
	if(toucher.items & ITEM_Metal.m_itemid)
	{
		if(vdist(toucher.velocity, >=, 50))
		if(time >= this.pain_finished)
		{
			Damage(this, toucher, toucher, 5, DEATH_CHEAT, this.origin, '0 0 0'); // only 5 damage, but this is increased by strength
			UNSET_ONGROUND(this);
			this.velocity = randomvec() * 300;
			if(random() > 0.5)
				this.velocity *= -1;
			this.velocity_z = 400;
			this.pain_finished = time + 1;
			//this.frame = koopa_anim_death;
		}
		return;
	}
#endif
	
	if(toucher.items & ITEM_Shield.m_itemid)
		return;
	if(toucher.takedamage == DAMAGE_NO)
		return;
	if(!toucher.iscreature)
		return;
	if(time < this.attack_finished_single[0])
		return;
	if(toucher.monsterid == this.monsterid)
		return; // friendly
		
	vector vdir = normalize(toucher.origin - this.origin);
	if(vdir.z <= 0.7)
	{
		Damage(toucher, this, this, autocvar_g_monster_koopa_attack_melee_damage, DEATH_MONSTER_KOOPA.m_id, toucher.origin, '0 0 0');
		//this.frame = koopa_anim_hit;
		this.attack_finished_single[0] = time + autocvar_g_monster_koopa_attack_melee_delay;
	}
}

spawnfunc(monster_koopa) { Monster_Spawn(this, true, MON_KOOPA.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Koopa, mr_think, bool(Monster thismon, entity actor))
		{
			Monster_Move_2D(actor, autocvar_g_monster_koopa_speed_walk, autocvar_g_monster_koopa_allow_jumpoff);
			return false; // false means don't run regular move logic
		}
		METHOD(Koopa, mr_pain, float(Monster thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			actor.pain_finished = time + 0.5;
			//setanim(actor, actor.anim_pain1, true, true, false);
			return damage_take;
		}
		METHOD(Koopa, mr_death, bool(Monster thismon, entity actor))
		{
			//setanim(actor, actor.anim_die1, false, true, true);
			setmodel(actor, MDL_MON_KOOPA_DEAD);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Koopa, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_walk = animfixfps(actor, '1 1 1', none);
			actor.anim_idle = animfixfps(actor, '0 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		METHOD(Koopa, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_koopa_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_koopa_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_koopa_speed_walk); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_koopa_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_koopa_damageforcescale); }

			actor.ticrate = sys_frametime; // accuracy required
			//actor.monster_loot = ITEM_HealthBig;
			actor.monster_attackfunc = func_null;
			actor.spawn_time = time + 0.55;
			actor.spawnshieldtime = actor.spawn_time;

			settouch(actor, M_Koopa_Touch);

			return true;
		}
		METHOD(Koopa, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
