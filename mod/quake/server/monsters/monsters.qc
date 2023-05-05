#include "monsters.qh"

#include "ai.qh"
#include "../combat.qh"
#include "../horde.qh"
#include "../hipnotic/defs.qh"
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

	if(!(this.flags & FL_SWIM) && !(this.flags & FL_DECOY) && !(this.spawnflags & SPAWNFLAG_NO_CONTENTS_DAMAGE))
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

	if(MP_MG && (this.spawnflags & MONSTER_SPAWNED))
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

	if(MP_MG && (this.spawnflags & MONSTER_SPAWNED))
	{
		// Yoder, Sept29, horde fix so that preplaced monsters are counted on spawn_tdeath
		if(horde_ent)
			monsters_total += 1;
		// end Yoder chunk, back to normal
		
		if(this.spawnflags & MONSTER_SPAWNED_ANGRY)
			monster_use(this, NULL, NULL); //Make monster angry!
	}
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

void monster_start(entity this, Monster mon)
{
	if(!mon || mon == MON_Null) { return; } // invalid monster
	if(deathmatch) { delete(this); return; }
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}

	this.flags |= FL_MONSTER;
	this.monsterdef = mon;
	this.max_health = this.health;
	if(mon.spawnflags & MONSTER_TYPE_SWIM) { this.flags |= FL_SWIM; }
	if(mon.spawnflags & MONSTER_TYPE_FLY) { this.flags |= FL_FLY; }
	// hipnotic
	if(mon.spawnflags & MONSTER_TYPE_DECOY) { this.flags |= FL_DECOY; }

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	setmodel(this, mon.m_model);
	setsize(this, mon.m_mins, mon.m_maxs);
	setcefc(this, monster_customize);

	// Yoder, Sept29, fix for preplaced monsters in horde_ent
	// in horde, mosnters shouldn't increase total count until spawned
	if(MP_MG && autocvar_horde)
	{
		if(!(this.spawnflags & MONSTER_SPAWNED))
			monsters_total += 1;
	}
	else if(!(this.flags & FL_DECOY) && (!MP_IMPEL || !(this.flags & FL_SWIM)))
		monsters_total += 1;

	if(!mon.mr_setup(mon, this))
	{
		delete(this);
		return;
	}

	if(this.spawnflags & MONSTER_SPAWNED)
	{
		this.use = StartMonster;
		this.oldsolid = this.solid;
		this.effects |= EF_NODRAW;
		this.solid = SOLID_NOT;
		return;
	}

	this.nextthink = this.nextthink + random() * 0.5;
	setthink(this, monster_start_go);
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
