#ifndef KOOPA_H
#define KOOPA_H

#ifdef GAMEQC
MODEL(MON_KOOPA, M_Model("koopa.dpm"));
MODEL(MON_KOOPA_DEAD, M_Model("koopa_shell.md3"));

MSG_INFO_NOTIF(DEATH_SELF_MON_KOOPA,             			1, 2, 1, "s1 s2loc spree_lost", "s1",    	"notify_death",         			"^BG%s^K1 was bitten by a Koopa Troopa%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_KOOPA,                		1,  NULL,           						INFO_DEATH_SELF_MON_KOOPA,   		CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_KOOPA,            				DEATH_SELF_MON_KOOPA,            			DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Koopa, Monster)
    ATTRIB(Koopa, spawnflags, int, MONSTER_TYPE_PASSIVE | MON_FLAG_CRUSH | MON_FLAG_HIDDEN);
    ATTRIB(Koopa, m_mins, vector, '-15 -15 -15');
    ATTRIB(Koopa, m_maxs, vector, '15 15 1');
#ifdef GAMEQC
    ATTRIB(Koopa, m_model, Model, MDL_MON_KOOPA);
#endif
    ATTRIB(Koopa, netname, string, "koopa");
    ATTRIB(Koopa, monster_name, string, "Koopa");
ENDCLASS(Koopa)

REGISTER_MONSTER(KOOPA, NEW(Koopa));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_koopa_health, float, 50, "");
AUTOCVAR(g_monster_koopa_damageforcescale, float, 0.35, "");
AUTOCVAR(g_monster_koopa_attack_melee_damage, float, 50, "");
AUTOCVAR(g_monster_koopa_attack_melee_delay, float, 0.55, "");
AUTOCVAR(g_monster_koopa_speed_stop, float, 100, "");
AUTOCVAR(g_monster_koopa_speed_run, float, 350, "");
AUTOCVAR(g_monster_koopa_speed_walk, float, 70, "");
AUTOCVAR(g_monster_koopa_wakeuptime, float, 10, "");
AUTOCVAR(g_monster_koopa_jumpheight, float, 350, "");

.int fakedead;
.float fakedead_time;

/*
const float koopa_anim_idle = 0;
const float koopa_anim_walk = 1;
*/

void M_Koopa_Move_2D(entity this, float mspeed, bool allow_jumpoff)
{
	if(game_stopped || (round_handler_IsActive() && !round_handler_IsRoundStarted()) || this.draggedby != NULL || time < game_starttime || (autocvar_g_campaign && !campaign_bots_may_start) || time < this.spawn_time)
	{
		this.fakedead = 1;
		mspeed = 0;
		if(time >= this.spawn_time)
			setanim(this, this.anim_idle, true, false, false);
		movelib_brake_simple(this, 0.6);
		return;
	}

	makevectors(this.angles);
	vector a = CENTER_OR_VIEWOFS(this);
	vector b = CENTER_OR_VIEWOFS(this) + v_forward * 32;

	traceline(a, b, MOVE_NORMAL, this);

	bool reverse = false;
	if(trace_fraction != 1.0)
		reverse = true;
	if(trace_ent && trace_ent.iscreature && !(trace_ent.items & ITEM_Strength.m_itemid))
		reverse = false;

	if(reverse)
	{
		this.angles_y = anglemods(this.angles_y - 180);
		makevectors(this.angles);
	}

	movelib_move_simple_gravity(this, v_forward, mspeed, 1);

	if(time > this.pain_finished && time > this.attack_finished_single[0])
	{
		if(vdist(this.velocity, >, 10))
			setanim(this, this.anim_walk, true, false, false);
		else
			setanim(this, this.anim_idle, true, false, false);
	}
}

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

	if(this.fakedead == 1 && vdist(this.velocity, <, 100))
	{
		if(IS_PLAYER(toucher) && time >= this.pain_finished)
		{
			makevectors(this.angles);
			vector a = CENTER_OR_VIEWOFS(this) - v_forward * 100;
			vector b = CENTER_OR_VIEWOFS(this) + v_forward * 100;
			if(vlen2(a - toucher.origin) > vlen2(b - toucher.origin)) // they're infront of us, turn around!
				this.angles_y = anglemods(this.angles_y - 180);
			this.fakedead = 2;
			this.attack_finished_single[0] = time + 0.55;
		}
		return; // no hurty while dead
	}
	
	if((toucher.items & ITEM_Shield.m_itemid) && toucher.monsterid != this.monsterid)
		return; // FIXME this assumes starman, which is incorrect
	if(toucher.takedamage == DAMAGE_NO || !toucher.iscreature || (toucher.monsterid == this.monsterid && !this.fakedead))
		return;
	if(time < this.attack_finished_single[0] && (!this.fakedead || IS_PLAYER(toucher))) // hits multiple times!
		return;
		
	vector vdir = normalize(toucher.origin - this.origin);
	if(vdir.z <= 0.7)
	{
		Damage(toucher, this, this, autocvar_g_monster_koopa_attack_melee_damage, DEATH_MONSTER_KOOPA.m_id, DMG_NOWEP, toucher.origin, '0 0 0');
		//this.frame = koopa_anim_hit;
		this.attack_finished_single[0] = time + autocvar_g_monster_koopa_attack_melee_delay;
	}
}

void M_Koopa_FakeDeath(Monster thismon, entity actor)
{
	SetResourceExplicit(actor, RES_HEALTH, actor.max_health);
	setmodel(actor, MDL_MON_KOOPA_DEAD);
	setsize(actor, thismon.m_mins, thismon.m_maxs);
	actor.spawn_time = time + 0.25; // give it a slight delay before being kickable
	actor.spawnshieldtime = actor.spawn_time;
	actor.fakedead = 1;
	actor.fakedead_time = time + autocvar_g_monster_koopa_wakeuptime;
	actor.items |= ITEM_Shield.m_itemid; // a trick to make other sidescrolling monsters not hit this
}

void M_Koopa_WakeUp(Monster thismon, entity actor)
{
	SetResourceExplicit(actor, RES_HEALTH, actor.max_health);
	setmodel(actor, MDL_MON_KOOPA);
	setsize(actor, thismon.m_mins, thismon.m_maxs);
	actor.fakedead = 0;
	actor.fakedead_time = 0;
	actor.items &= ~ITEM_Shield.m_itemid;
}

spawnfunc(monster_koopa) { Monster_Spawn(this, true, MON_KOOPA.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Koopa, mr_think, bool(Monster thismon, entity actor))
		{
			if(actor.skin == -1)
				actor.skin = 0;
			if(actor.fakedead)
				M_Koopa_Move_2D(actor, ((actor.fakedead == 2) ? autocvar_g_monster_koopa_speed_run : 0), true);
			else
			{
				Monster_Move_2D(actor, autocvar_g_monster_koopa_speed_walk, actor.skin != 1);
				if(actor.skin == 2 && IS_ONGROUND(actor))
				{
					UNSET_ONGROUND(actor);
					actor.velocity_z += autocvar_g_monster_koopa_jumpheight;
				}
			}
			if(actor.fakedead_time && time >= actor.fakedead_time && actor.fakedead == 1)
				M_Koopa_WakeUp(thismon, actor);
			return false; // false means don't run regular move logic
		}
		METHOD(Koopa, mr_pain, float(Monster thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			actor.pain_finished = time + 0.5;
			//setanim(actor, actor.anim_pain1, true, true, false);
			if(actor.fakedead && deathtype == DEATH_VH_CRUSH.m_id && IS_PLAYER(attacker))
			{
				actor.fakedead = ((actor.fakedead == 2) ? 1 : 2);
				if(actor.fakedead == 1)
					actor.fakedead_time = time + autocvar_g_monster_koopa_wakeuptime; // reset the delay
				else if(actor.fakedead == 2)
				{
					makevectors(actor.angles); // turn it around too
					actor.angles_y = anglemods(actor.angles_y - 180);
				}
				return 0;
			}
			if((GetResource(actor, RES_HEALTH) - damage_take) <= 0 && deathtype != DEATH_KILL.m_id && !actor.fakedead && attacker.monsterid != actor.monsterid)
			{
				M_Koopa_FakeDeath(thismon, actor);
				return 0;
			}
			return damage_take;
		}
		METHOD(Koopa, mr_death, bool(Monster thismon, entity actor))
		{
			// TODO: this animation isn't built into the model yet!
			setanim(actor, actor.anim_idle, false, true, true);
			//setmodel(actor, MDL_MON_KOOPA_DEAD);
			actor.fakedead = 0;
			actor.fakedead_time = 0;
			actor.items &= ~ITEM_Shield.m_itemid;
			return true;
		}
		#endif
		#ifdef GAMEQC
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
			if(!GetResource(actor, RES_HEALTH)) SetResourceExplicit(actor, RES_HEALTH, autocvar_g_monster_koopa_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_koopa_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_koopa_speed_walk); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_koopa_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_koopa_damageforcescale); }

			actor.ticrate = sys_frametime; // accuracy required
			//actor.monster_loot = ITEM_HealthBig;
			actor.monster_attackfunc = func_null;
			actor.spawn_time = time + 0.25;
			actor.spawnshieldtime = actor.spawn_time;
			actor.fakedead = 0; // make sure
			actor.fakedead_time = 0;
			actor.items &= ~ITEM_Shield.m_itemid;
			if(!actor.skin)
				actor.skin = -1; // avoid random selection

			settouch(actor, M_Koopa_Touch);

			return true;
		}
		#endif

#endif
