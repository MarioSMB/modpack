#include "monsters.qh"

#include "ai.qh"
#include "../combat.qh"
#include "../horde.qh"
#include "../player.qh"
#include "../../common/triggers/subs.qh"
#include "../../common/triggers/teleporters.qh"
#include "../../common/triggers/triggers.qh"
#include "../weapons.qh"

/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name()
// {
//		this.frame=framenum;
//		this.nextthink = time + nexttime;
//		this.think = nextthink
//		<code>
// }

bool Monsters_SeasonLocked()
{
	float month = stof(strftime(true, "%m"));
	if(month == 12)
		return false;
	return true;
}

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void monster_use(entity this, entity actor, entity trigger)
{
	if(this.enemy || this.health <= 0 || StatusEffects_active(STATUSEFFECT_Invisibility, actor) || (actor.flags & FL_NOTARGET) || (!IS_PLAYER(actor) && !IS_MONSTER(actor)))
		return;
	
	// delay reaction so if the monster is teleported, its sound is still heard
	if(IS_MONSTER(actor))
	{
		this.enemy = actor.enemy;
		this.oldenemy = actor.oldenemy;
	}
	else
		this.enemy = actor;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);
}

float orig_random(entity this)
{
	float len = vlen(this.origin);
	return len - floor(len);
}

void monster_begin_walking(entity this, entity actor, entity trigger)
{
	this.use = monster_use;
	this.pausetime = 0;
	if(this.th_walk)
	{
		setthink(this, this.th_walk);
		this.nextthink = time;
	}
}

//============================================================================

.float oldsolid;
.vector rmovedir;
void monster_start_go(entity this)
{
	Monster mon = this.monsterdef;
	bool is_walker = (!(mon.spawnflags & MONSTER_TYPE_SWIM) && !(mon.spawnflags & MONSTER_TYPE_FLY)); // special check needed here as there isn't a walk flag

	if(this.rmovedir != '0 0 0')
	{
		makevectors(this.angles);
		this.movedir = v_forward * this.rmovedir_x + v_right * this.rmovedir_y + v_up * this.rmovedir_z;
		this.rmovedir = '0 0 0';
	}

	if(!this.yaw_speed)
		this.yaw_speed = ((is_walker) ? 20 : 10);
	if(is_walker && this.movedir == '0 0 0' && !(this.spawnflags & SPAWN_TRIGGERED))
	{
		this.origin_z = this.origin_z + 1;	// raise off floor a bit
		DropToFloor_QC_DelayedInit(this);
	}

	if((this.spawnflags & SPAWN_TRIGGERED) && this.movedir != '0 0 0')
	{
		this.velocity = this.movedir;
		this.movedir = '0 0 0';
	}

	this.view_ofs = ((mon.spawnflags & MONSTER_TYPE_SWIM) ? '0 0 10' : '0 0 25');
	this.takedamage = DAMAGE_AIM;
	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.use)
		this.use = monster_use;

	if(!(mon.spawnflags & MONSTER_TYPE_SWIM) && !(this.flags & FL_DECOY) && !(this.spawnflags & SPAWNFLAG_NO_CONTENTS_DAMAGE) && !(mon.spawnflags & MONSTER_TYPE_BOSS))
	{
		if(!this.damagedbycontents)
			IL_PUSH(g_damagedbycontents, this);
		this.damagedbycontents	= true;
	}

	if(!(mon.spawnflags & MONSTER_TYPE_SWIM))
	{
		tracebox(this.origin, this.mins, this.maxs, this.origin, MOVE_NOMONSTERS, this);
		if(trace_startsolid)
			LOG_DEBUG("Monster in wall at ", vtos(this.origin), "\n");
	}

	if(this.health <= 0)
		return;

	if(monster_checkspawnedflag(this))
	{
		spawn_tdeath(this.origin, this);
		if(this.spawnflags & MONSTER_SPAWNED_TFOG)
			spawn_tfog(this.origin);
	}

	if(this.enemy)
	{
		if(this.th_stand)
			this.th_stand(this);
		setthink(this, FoundTarget);
		this.nextthink = time;
	}
	else if(this.target && this.target != "")
	{
		if(this.spawnflags & MONSTER_ATTACK_FRIEND)
		{
			RandomSelection_Init();
			for(entity targ = findchain(targetname, this.target); targ; targ = targ.chain)
			{
				if(!targ.takedamage)
					continue;
				RandomSelection_AddEnt(targ, 1, 1);
			}

			entity f = RandomSelection_chosen_ent;
			if(f)
			{
				this.enemy = f;
				FoundTarget(this);
				return;
			}
		}
		//this.goalentity = this.movetarget = find(NULL, targetname, this.target);
		entity targ = find(NULL, targetname, this.target);
		if(targ && targ.classname == "path_corner")
			this.goalentity = this.movetarget = targ;
		if(!this.movetarget || this.movetarget.classname != "path_corner")
		{
			//LOG_DEBUG("Monster can't find target at ", vtos(this.origin), "\n");
			this.pausetime = -1;
			if(this.th_stand)
			{
				setthink(this, this.th_stand);
				this.nextthink = time;
			}
		}
		else
		{
			if(this.spawnflags & MONSTER_WAITWALK)
			{
				this.pausetime = -1;
				if(this.th_stand)
				{
					setthink(this, this.th_stand);
					this.nextthink = time;
				}
				this.use = monster_begin_walking;
			}
			else
			{
				this.ideal_yaw = vectoyaw(this.goalentity.origin - this.origin);
				if(this.th_walk)
				{
					setthink(this, this.th_walk);
					this.nextthink = time;
				}
			}
		}
	}
	else
	{
		this.pausetime = -1;
		if(this.th_stand)
		{
			setthink(this, this.th_stand);
			this.nextthink = time;
		}
	}

	if(monster_checkspawnedflag(this))
	{
		// Yoder, Sept29, horde fix so that preplaced monsters are counted on spawn_tdeath
		if(horde_ent)
			monsters_total += 1;
		// end Yoder chunk, back to normal
		
		if(this.spawnflags & MONSTER_SPAWNED_ANGRY)
			monster_use(this, NULL, NULL); //Make monster angry!
	}
}

// horrible hack needed because spawnflags 4 is used so commonly!
bool monster_checkspawnedflag(entity this)
{
	if(!(this.spawnflags & MONSTER_SPAWNED))
		return false;
	return IsMGMap();
}

// interpolation for monsters only applies when .movetype is set to MOVETYPE_STEP
// this hack ensures that while allowing us to use QC physics for movement
// .movetype is reset by physics
bool monster_customize(entity this, entity client)
{
	if(time < this.enemy_reveal_time)
		this.effects |= (EF_ADDITIVE | EF_NODEPTHTEST);
	else
		this.effects &= ~(EF_ADDITIVE | EF_NODEPTHTEST);
	if(!autocvar_sv_quake_monsterfix)
		this.movetype = MOVETYPE_STEP; // RENDER_STEP
	return true;
}

void StartMonster(entity this, entity actor, entity trigger)
{
	this.solid = this.oldsolid;
	this.oldsolid = 0;
	this.effects &= ~EF_NODRAW;
	this.use = monster_use;
	monster_start_go(this);
}

void Monster_Appear_Delayed(entity this)
{
	monster_start(this, false, this.monsterdef);
}

const int SPAWN_INSTAWAKE = 128;
void Monster_Appear(entity this, entity actor, entity trigger)
{
	float timer = (this.delay) ? this.delay : 0;
	setthink(this, Monster_Appear_Delayed);
	this.nextthink = time + timer;
	this.use = func_null; // will be set to a normal value upon spawning
	if((this.spawnflags & SPAWN_INSTAWAKE) && (IS_MONSTER(actor) || IS_PLAYER(actor)))
	{
		if(IS_MONSTER(actor))
		{
			this.enemy = actor.enemy;
			this.oldenemy = actor.oldenemy;
		}
		else
			this.enemy = actor;
	}
}

bool Monster_Appear_Check(entity this, Monster monster_id)
{
	bool check_triggered = (this.spawnflags & SPAWN_TRIGGERED);
	if(IsMGMap())
		check_triggered = false;
	if(!(monster_id.spawnflags & MON_FLAG_APPEAR) && !check_triggered)
		return false;
	if(this.targetname == "" || !this.targetname)
		return false;

	setthink(this, func_null);
	this.monsterdef = monster_id; // set so this monster is properly registered (otherwise, normal initialization is used)
	this.nextthink = 0;
	this.use = Monster_Appear;
	this.flags = FL_MONSTER; // set so this monster can get butchered

	return true;
}

Monster monster_randomize(entity this, Monster mon)
{
	this.nightmare_checked = true;
	if((mon.spawnflags & MONSTER_TYPE_DECOY) || world.model == "maps/eod7.bsp" || world.model == "maps/zigisp1.bsp" || world.model == "maps/markiesm1.bsp" || world.model == "maps/r2m1.bsp")
		return mon; // map is broken currently with random mobs TODO

	if(substring(world.model, 0, 9) == "maps/ffj_")
		return MON_FLOYD;

	bool seasonlocked = Monsters_SeasonLocked();

	RandomSelection_Init();
	FOREACH(Monsters, it != MON_Null,
	{
		if(it.spawnflags & MONSTER_TYPE_DECOY)
			continue;
		if(it.spawnflags & MON_FLAG_HIDDEN)
			continue;
		if(it.spawnflags & MONSTER_TYPE_UNDEAD)
			continue;
		if(it.spawnflags & MONSTER_TYPE_BOSS)
			continue;
		if(it.spawnflags & MONSTER_TYPE_SWIM)
			continue;
		if((it.spawnflags & MONSTER_TYPE_FLY) && !(mon.spawnflags & MONSTER_TYPE_FLY))
			continue;
		if((mon.spawnflags & MONSTER_TYPE_FLY) && !(it.spawnflags & MONSTER_TYPE_FLY))
			continue;
		if((it.spawnflags & MON_FLAG_XMAS) && seasonlocked)
			continue;
		tracebox(this.origin, it.m_mins, it.m_maxs, this.origin, MOVE_WORLDONLY, this);
		if(trace_startsolid)
			continue;
		RandomSelection_AddEnt(it, 1, 1);
	});

	if(!RandomSelection_chosen_ent)
	{
		LOG_DEBUG("Spawning the same monster again, no space for anything else?!");
		RandomSelection_chosen_ent = mon; // emergency fallback in the case of something not being found, strips unique spawnflags but oh well
	}

	return RandomSelection_chosen_ent;
}

void monster_start(entity this, bool check_appear, Monster mon)
{
	if(!autocvar_horde && autocvar_skill == 3 && !this.nightmare_checked && !(mon.spawnflags & MONSTER_TYPE_BOSS) && !(mon.spawnflags & MONSTER_TYPE_SWIM) && !(mon.spawnflags & MONSTER_TYPE_UNDEAD))
		mon = monster_randomize(this, mon);

	if(check_appear && qonquer_monstercompat(this, mon))
	{
		delete(this);
		return;
	}

	if(!mon || mon == MON_Null) { return; } // invalid monster
	if(deathmatch) { delete(this); return; }
	if(Inhibit_Coop(this) || RemovedOutsideCoop(this))
	{
		delete(this);
		return;
	}

	if(check_appear && Monster_Appear_Check(this, mon))
		return;

	if(this.statuseffects && this.statuseffects.owner == this)
	{
		StatusEffects_clearall(this.statuseffects);
		StatusEffects_update(this);
	}
	else
		this.statuseffects = NULL;

	this.flags |= FL_MONSTER;
	this.monsterdef = mon;
	if(mon.spawnflags & MONSTER_TYPE_SWIM) { this.flags |= FL_SWIM; }
	if(mon.spawnflags & MONSTER_TYPE_FLY) { this.flags |= FL_FLY; }
	// hipnotic
	if(mon.spawnflags & MONSTER_TYPE_DECOY) { this.flags |= FL_DECOY; }

	this.solid = SOLID_SLIDEBOX;
	if((mon.spawnflags & MONSTER_TYPE_FLY) || (mon.spawnflags & MONSTER_TYPE_SWIM))
		set_movetype(this, MOVETYPE_QCENTITY);
	else
		set_movetype(this, MOVETYPE_STEP);

	// allow maps to define custom models
	// but need to check * for brush models set by hipnotic maps for some reason
	if(!this.model || this.model == "" || substring(this.model, 0, 1) == "*")
		setmodel(this, mon.m_model);
	setsize(this, mon.m_mins, mon.m_maxs);
	setcefc(this, monster_customize);

	this.nextthink = this.nextthink + random() * 0.5;
	setthink(this, monster_start_go);

	this.resist_shells = 0;
	this.resist_nails = 0;
	this.resist_rockets = 0;
	this.resist_cells = 0;

	mon.mr_setup(mon, this);

	setup_minionsupport(this);

	// Yoder, Sept29, fix for preplaced monsters in horde_ent
	// in horde, mosnters shouldn't increase total count until spawned
	if(autocvar_horde)
	{
		if(!monster_checkspawnedflag(this) && !(this.flags & FL_DECOY) && !(this.flags & FL_CLONE))
			monsters_total += 1;
	}
	else if(!(this.flags & FL_DECOY) && !(this.flags & FL_CLONE))
		monsters_total += 1;

	this.max_health = this.health;

	if(monster_checkspawnedflag(this))
	{
		this.use = StartMonster;
		this.oldsolid = this.solid;
		this.effects |= EF_NODRAW;
		this.solid = SOLID_NOT;
		setthink(this, func_null);
		this.nextthink = 0;
		return;
	}
}

// Yoder Sept24 2021, Horde Merge
// Monster fade, used to fade out the model a few seconds after deathmatch
void MonsterFade2(entity this)
{
	if(this.alpha > 0)
	{
		this.alpha = this.alpha - 1 * frametime;
		//this.think = MonsterFade;
		this.nextthink = time; // think next frame
	}
	else
		delete(this);
}
void MonsterFade(entity this)
{
	if(!autocvar_horde)
	{
		setthink(this, func_null);
		return;
	}
	if(!this.alpha)
		this.alpha = 1;
	setthink(this, MonsterFade2);
	this.nextthink = time + 10 + random() * 5; // wait a bit before fading
}
