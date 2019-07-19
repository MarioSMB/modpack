#ifndef GOOMBA_H
#define GOOMBA_H

#ifdef GAMEQC
MODEL(MON_GOOMBA, M_Model("goomba.dpm"));
MODEL(MON_GOOMBA_DEAD, M_Model("goomba_dead.md3"));

MSG_INFO_NOTIF(DEATH_SELF_MON_GOOMBA,             			1, 2, 1, "s1 s2loc spree_lost", "s1",    	"notify_death",         			"^BG%s^K1 was devoured by a Goomba%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_GOOMBA,                		1,  NULL,           						INFO_DEATH_SELF_MON_GOOMBA,   		CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_GOOMBA,            				DEATH_SELF_MON_GOOMBA,            			DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Goomba, Monster)
    ATTRIB(Goomba, spawnflags, int, MON_FLAG_CRUSH | MON_FLAG_HIDDEN);
    ATTRIB(Goomba, m_mins, vector, '-15 -15 -32');
    ATTRIB(Goomba, m_maxs, vector, '15 15 10');
#ifdef GAMEQC
    ATTRIB(Goomba, m_model, Model, MDL_MON_GOOMBA);
#endif
    ATTRIB(Goomba, netname, string, "goomba");
    ATTRIB(Goomba, monster_name, string, "Goomba");
ENDCLASS(Goomba)

REGISTER_MONSTER(GOOMBA, NEW(Goomba));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_goomba_health, float, 50, "");
AUTOCVAR(g_monster_goomba_damageforcescale, float, 0.35, "");
AUTOCVAR(g_monster_goomba_attack_melee_damage, float, 50, "");
AUTOCVAR(g_monster_goomba_attack_melee_delay, float, 0.55, "");
AUTOCVAR(g_monster_goomba_speed_stop, float, 100, "");
//AUTOCVAR(g_monster_goomba_speed_run, float, 220, "");
AUTOCVAR(g_monster_goomba_speed_walk, float, 70, "");
AUTOCVAR(g_monster_goomba_allow_jumpoff, bool, false, "");

/*
const float goomba_anim_idle = 0;
const float goomba_anim_walk = 1;
*/

void M_Goomba_Touch(entity this, entity toucher)
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
			//this.frame = goomba_anim_death;
		}
		return;
	}
#endif
	
	if(toucher.items & ITEM_Shield.m_itemid)
		return; // FIXME this assumes starman, which is incorrect
	if(toucher.takedamage == DAMAGE_NO || !toucher.iscreature || toucher.monsterid == this.monsterid)
		return;
	if(time < this.attack_finished_single[0])
		return;
		
	vector vdir = normalize(toucher.origin - this.origin);
	if(vdir.z <= 0.7)
	{
		Damage(toucher, this, this, autocvar_g_monster_goomba_attack_melee_damage, DEATH_MONSTER_GOOMBA.m_id, DMG_NOWEP, toucher.origin, '0 0 0');
		//this.frame = goomba_anim_hit;
		this.attack_finished_single[0] = time + autocvar_g_monster_goomba_attack_melee_delay;
	}
}

spawnfunc(monster_goomba) { Monster_Spawn(this, true, MON_GOOMBA.monsterid); }

#endif // SVQC

#ifdef SVQC
METHOD(Goomba, mr_think, bool(Monster thismon, entity actor))
{
	Monster_Move_2D(actor, autocvar_g_monster_goomba_speed_walk, autocvar_g_monster_goomba_allow_jumpoff);
	return false; // false means don't run regular move logic
}
METHOD(Goomba, mr_pain, float(Monster thismon, entity actor, float damage_take, entity attacker, float deathtype))
{
	actor.pain_finished = time + 0.5;
	//setanim(actor, actor.anim_pain1, true, true, false);
	return damage_take;
}
METHOD(Goomba, mr_death, bool(Monster thismon, entity actor))
{
	//setanim(actor, actor.anim_die1, false, true, true);
	setmodel(actor, MDL_MON_GOOMBA_DEAD);
	return true;
}
#endif
#ifdef GAMEQC
METHOD(Goomba, mr_anim, bool(Monster thismon, entity actor))
{
	vector none = '0 0 0';
	actor.anim_walk = animfixfps(actor, '1 1 1', none);
	actor.anim_idle = animfixfps(actor, '0 1 1', none);

	return true;
}
#endif
#ifdef SVQC
.float speed;
METHOD(Goomba, mr_setup, bool(Monster thismon, entity actor))
{
	if(!GetResource(actor, RES_HEALTH)) SetResourceExplicit(actor, RES_HEALTH, autocvar_g_monster_goomba_health);
	if(!actor.speed) { actor.speed = (autocvar_g_monster_goomba_speed_walk); }
	if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_goomba_speed_walk); }
	if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_goomba_speed_stop); }
	if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_goomba_damageforcescale); }

	actor.ticrate = sys_frametime; // accuracy required
	//actor.monster_loot = ITEM_HealthBig;
	actor.monster_attackfunc = func_null;
	actor.spawn_time = time + 0.25;
	actor.spawnshieldtime = actor.spawn_time;

	settouch(actor, M_Goomba_Touch);

	return true;
}
#endif

#endif
