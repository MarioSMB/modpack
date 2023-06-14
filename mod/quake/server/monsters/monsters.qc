#include "monsters.qh"

#include "ai.qh"
#include "../combat.qh"
#include "../horde.qh"
#include "../player.qh"
#include "../triggers/subs.qh"
#include "../triggers/teleporters.qh"
#include "../triggers/triggers.qh"
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

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void monster_use(entity this, entity actor, entity trigger)
{
	if(this.enemy || this.health <= 0 || (actor.powerups & POWERUP_INVISIBILITY) || (actor.flags & FL_NOTARGET) || !IS_PLAYER(actor))
		return;
	
	// delay reaction so if the monster is teleported, its sound is still heard
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
void monster_start_go(entity this)
{
	bool is_walker = !((this.flags & FL_SWIM) || (this.flags & FL_FLY)); // special check needed here as there isn't a walk flag

	if(!this.yaw_speed)
		this.yaw_speed = ((is_walker) ? 20 : 10);
	if(is_walker)
	{
		this.origin_z = this.origin_z + 1;	// raise off floor a bit
		droptofloor(this);
	}

	this.view_ofs = ((this.flags & FL_SWIM) ? '0 0 10' : '0 0 25');
	this.takedamage = DAMAGE_AIM;
	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.use)
		this.use = monster_use;

	if(!(this.flags & FL_SWIM) && !(this.flags & FL_DECOY) && !(this.spawnflags & SPAWNFLAG_NO_CONTENTS_DAMAGE) && !(this.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
	{
		if(!this.damagedbycontents)
			IL_PUSH(g_damagedbycontents, this);
		this.damagedbycontents	= true;
	}

	if(!(this.flags & FL_SWIM))
	{
		tracebox(this.origin, this.mins, this.maxs, this.origin, MOVE_NOMONSTERS, this);
		if(trace_startsolid)
			LOG_DEBUG("Monster in wall at ", vtos(this.origin), "\n");
	}

	if(this.health <= 0)
		return;

	if(MP_MG && monster_checkspawnedflag(this))
	{
		spawn_tdeath(this.origin, this);
		if(this.spawnflags & MONSTER_SPAWNED_TFOG)
			spawn_tfog(this.origin);
	}

	if(this.target && this.target != "")
	{
		if(MP_MG && (this.spawnflags & MONSTER_ATTACK_FRIEND))
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
		this.goalentity = this.movetarget = find(NULL, targetname, this.target);
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
			if(MP_MG && (this.spawnflags & MONSTER_WAITWALK))
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

	if(MP_MG && monster_checkspawnedflag(this))
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
	return (substring(world.model, 0, 7) == "maps/mg" || substring(world.model, 0, 5) == "horde");
}

// interpolation for monsters only applies when .movetype is set to MOVETYPE_STEP
// this hack ensures that while allowing us to use QC physics for movement
// .movetype is reset by physics
bool monster_customize(entity this, entity client)
{
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

void Monster_Appear(entity this, entity actor, entity trigger)
{
	float timer = (this.delay) ? this.delay : 0;
	setthink(this, Monster_Appear_Delayed);
	this.nextthink = time + timer;
}

bool Monster_Appear_Check(entity this, Monster monster_id)
{
	if(!(monster_id.spawnflags & MON_FLAG_APPEAR))
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

void monster_start(entity this, bool check_appear, Monster mon)
{
	if(!mon || mon == MON_Null) { return; } // invalid monster
	if(deathmatch) { delete(this); return; }
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
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
	if(this.flags & FL_FLY)
		set_movetype(this, MOVETYPE_NONE);
	else
		set_movetype(this, MOVETYPE_STEP);

	// allow maps to define custom models
	if(!this.model || this.model == "")
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
	if(MP_MG && autocvar_horde)
	{
		if(!monster_checkspawnedflag(this) && !(this.flags & FL_DECOY) && !(this.flags & FL_CLONE))
			monsters_total += 1;
	}
	else if(!(this.flags & FL_DECOY) && !(this.flags & FL_CLONE))
		monsters_total += 1;

	this.max_health = this.health;

	if(MP_MG && monster_checkspawnedflag(this))
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
