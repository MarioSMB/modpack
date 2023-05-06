#include "gremlin.qh"

#include "ogre.qh"

#ifdef SVQC
const int anim_gremlin_stand = 0; //'0 16 0';
const int anim_gremlin_walk = 17; //'17 28 0';
const int anim_gremlin_run = 29; //'29 43 0';
const int anim_gremlin_jump = 44; //'44 59 0';
const int anim_gremlin_attk = 60; //'60 70 0';
const int anim_gremlin_maul = 71; //'71 83 0';
const int anim_gremlin_spawn = 84; //'84 89 0';
const int anim_gremlin_look = 90; //'90 99 0';
const int anim_gremlin_pain = 100; //'100 103 0';
const int anim_gremlin_death = 104; //'104 115 0';
const int anim_gremlin_flip = 116; //'116 123 0';
const int anim_gremlin_lunge = 124; //'124 134 0';
const int anim_gremlin_gfire = 135; //'135 140 0';
const int anim_gremlin_glook = 141; //'141 160 0';
const int anim_gremlin_gpain = 161; //'161 163 0';
const int anim_gremlin_grun = 164; //'164 178 0';

//============================================================================

int NumGremlins;
int NumSpawnGremlins;

/*
===========
GremlinAttemptWeaponSteal

see if we can steal enemy's weapon

============
*/
entity GremlinFindVictim(entity this);
bool GremlinFindTarget(entity this);

bool GremlinAttemptWeaponSteal(entity this)
{
	if(this.stoleweapon)
	{
		LOG_DEBUG("gremlin trying to steal a weapon again\n");
		return false;
	}
	if(!IS_PLAYER(this.enemy))
		return false;

	int amount;

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return false;
	if(random() < 0.5)
		return false;
	//
	// we are within range so lets go for it
	//
	entity victim = this.enemy;
	Weapon best = victim.weaponentity.m_weapon;
	if(best.spawnflags & WEP_FLAG_NOSTEAL)
		return false;
	Weapon wep = best;
	// take that weapon from the entity
	STAT(WEAPONS, victim) &= ~wep.m_wepset;
	// give it to our gremlin
	this.weaponentity.m_weapon = best;
	// take some ammo while we are at it
	this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	if(best != WEP_Null)
		Send_Notification(NOTIF_ONE, victim, MSG_MULTI, ITEM_WEAPON_STOLE, best.m_name);

	this.items |= best.ammo_type;
	switch(best.ammo_type)
	{
		case IT_SHELLS:
		{
			amount = min(victim.ammo_shells, 20);
			victim.ammo_shells -= amount;
			this.ammo_shells += amount;
			this.currentammo = this.ammo_shells;
			break;
		}
		case IT_NAILS:
		{
			amount = min(victim.ammo_nails, 40);
			victim.ammo_nails -= amount;
			this.ammo_nails += amount;
			this.currentammo = this.ammo_nails;
			break;
		}
		case IT_ROCKETS:
		{
			amount = min(victim.ammo_rockets, 5);
			victim.ammo_rockets -= amount;
			this.ammo_rockets += amount;
			this.currentammo = this.ammo_rockets;
			break;
		}
		case IT_CELLS:
		{
			amount = min(victim.ammo_cells, 40);
			victim.ammo_cells -= amount;
			this.ammo_cells += amount;
			this.currentammo = this.ammo_cells;
			break;
		}
		case IT_LAVA_NAILS:
		{
			amount = min(victim.ammo_lava_nails, 40);
			victim.ammo_lava_nails -= amount;
			this.ammo_lava_nails += amount;
			this.currentammo = this.ammo_lava_nails;
			break;
		}
		case IT_MULTI_ROCKETS:
		{
			amount = min(victim.ammo_multi_rockets, 40);
			victim.ammo_multi_rockets -= amount;
			this.ammo_multi_rockets += amount;
			this.currentammo = this.ammo_multi_rockets;
			break;
		}
		case IT_PLASMA_AMMO:
		{
			amount = min(victim.ammo_plasma, 40);
			victim.ammo_plasma -= amount;
			this.ammo_plasma += amount;
			this.currentammo = this.ammo_plasma;
			break;
		}
	}
	victim.weaponentity.m_weapon = REGISTRY_GET(Weapons, W_BestWeapon(victim, 0));
	W_SetCurrentAmmo(victim);

	// tag the gremlin as having stolen a weapon
	this.stoleweapon = true;
	this.attack_finished = time;
	// don't fire the first shot at the person we stole the weapon from
	// all the time
	if(random() > 0.65)
		this.lastvictim = victim;
	else
		this.lastvictim = this;
//   this.attack_state = AS_STRAIGHT;
	// find a recipient
	victim = GremlinFindVictim(this);
	if(victim != NULL)
	{
		this.enemy = victim;
		FoundTarget(this);
		this.attack_finished = time;
		this.search_time = time + 1.0;
	}

	return true;
}
//============================================================================

/*
===========
GremlinFindTarget

gremlin is currently not attacking anything, so try to find a target

============
*/
bool GremlinFindTarget(entity this)
{
	if((this.stoleweapon == 0) && time > this.wait)
	{
		this.wait = time + 1.0;
		float dist = 2000;
		entity gorge = NULL;

		FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
		{
			if(it.health < 1)
			{
				float res = fabs(it.origin_z - this.origin_z);
				if(visible(this, it) && res < 80 && !it.gorging)
				{
					if(visible_distance < dist)
					{
						dist = visible_distance;
						gorge = it;
					}
				}
			}
		});
		if(!gorge)
		{
			FOREACH_CLIENT(it.health < 1,
			{
				float res = fabs(it.origin_z - this.origin_z);
				if(visible(this, it) && res < 80 && !it.gorging)
				{
					if(visible_distance < dist)
					{
						dist = visible_distance;
						gorge = it;
					}
				}
			});
		}
		// TODO: make sure the gremlin logic wouldn't crash when messing with clones!
#if 0
		if(!gorge)
		{
			IL_EACH(g_clones, true,
			{
				float res = fabs(it.origin_z - this.origin_z);
				if(visible(this, it) && res < 80 && !it.gorging)
				{
					if(visible_distance < dist)
					{
						dist = visible_distance;
						gorge = it;
					}
				}
			});
		}
#endif

		if(gorge && (dist < (700 * random())))
		{
//         dprint("starting to gorge on ");
//         dprint(gorge.classname);
//         dprint("\n");
			this.oldenemy = this.enemy;
			this.gorging = true;
			this.enemy = gorge;
			this.search_time = time + 4.0;
			FoundTarget(this);
			return true;
		}
	}
	else if(this.stoleweapon)
	{
		entity head = GremlinFindVictim(this);
		if(head)
		{
			this.enemy = head;
			FoundTarget(this);
			this.attack_finished = time;
			this.search_time = time + 2.0;
			return true;
		}
	}
	bool result = FindTarget(this);
	this.search_time = time + 2.0;
	return result;
}

//============================================================================
/*
=============
gremlin_walk

The monster is walking it's beat
=============
*/
void gremlin_walk(entity this, float dist)
{
	this.move_dist = dist;

	// check for noticing a player
	if(GremlinFindTarget(this))
		return;

	t_movetogoal(this, dist);
}

//============================================================================

/*
=============
gremlin_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void gremlin_stand(entity this)
{
	if(FindTarget(this))
		return;

	if(time > this.pausetime)
	{
		this.th_walk(this);
		return;
	}
}

//============================================================================
bool GremlinCheckNoAmmo(entity this);
void gremlin_glook1(entity this);
/*
=============
gremlin_run

The monster has an enemy it is trying to kill
=============
*/
void gremlin_run(entity this, float dist)
{
	if(this.watertype == CONTENT_LAVA) // do damage
		T_Damage(this, NULL, NULL, 2000, DEATH_LAVA.m_id);

	this.move_dist = dist;

	if(this.stoleweapon)
		this.frame = this.frame + anim_gremlin_grun - anim_gremlin_run;

	if(this.gorging)
	{
		traceline(this.origin, this.enemy.origin, true, this);
		if(trace_fraction != 1.0)
		{
			this.gorging = false;
			return;
		}
		if(this.enemy.health > 0)
		{
			this.gorging = false;
			return;
		}
		if(!visible(this, this.enemy))
		{
			this.gorging = false;
			return;
		}
		if(vdist(this.enemy.origin - this.origin, <, 130))
		{
			ai_face(this);
			if(vdist(this.enemy.origin - this.origin, <, 45))
			{
				this.th_melee(this);
				this.attack_state = AS_STRAIGHT;
				return;
			}
			else if(t_walkmove(this, this.angles_y, dist) == false)
			{
				this.gorging = false;
				return;
			}
			return;
		}
		t_movetogoal(this, dist);      // done in C code...
	}
	else
	{
		if(random() > 0.97)
		{
			if(GremlinFindTarget(this))
				return;
		}
		// get away from player if we stole a weapon
		if(this.stoleweapon)
		{
			if(this.enemy.health < 0 && IS_PLAYER(this.enemy))
			{
				gremlin_glook1(this);
				return;
			}
			if(!GremlinCheckNoAmmo(this))
			{
				if(this.t_length == 1)
				{
					delete(this.trigger_field);
					this.goalentity = this.enemy;
					this.t_length = 0;
				}
				return;
			}
			vector d = normalize(this.origin-this.enemy.origin);
			if(this.t_length == 0)
			{
				if(vdist(this.enemy.origin - this.origin, <, 150))
				{
					this.trigger_field = spawn();
					setsize(this.trigger_field,'-1 -1 -1','1 1 1');
					this.t_length = 1;
				}
			}
			if(this.t_length==1)
			{
				if(vdist(this.enemy.origin - this.origin, >, 250))
				{
					delete(this.trigger_field);
					this.goalentity = this.enemy;
					this.t_length = 0;
//               this.attack_state = AS_SLIDING;
				}
				else
				{
					if(vdist(this.enemy.origin - this.origin, <, 160))
					{
						vector ang = vectoangles(d);
						bool done = false;
						int c = 0;
						vector end = '0 0 0';
						while(done == false)
						{
							makevectors(ang);
							end = this.enemy.origin + v_forward * 350;
							traceline(this.enemy.origin,end,false,this);
							if(trace_fraction == 1.0)
							{
								traceline(this.origin,end,false,this);
								if(trace_fraction == 1.0)
									done = true;
							}
							ang.y = anglemods(ang.y + 36);
							c = c + 1;
							if(c == 10)
								done = true;
						}
						setorigin(this.trigger_field, end);
					}
					this.goalentity = this.trigger_field;
					this.ideal_yaw = vectoyaw(normalize(this.goalentity.origin-this.origin));
					changeyaw(this);
					t_movetogoal(this, dist);      // done in C code...
					this.nextthink = time + 0.1;
					return;
				}
			}
		}
		ai_run(this, dist);
		this.nextthink = time + 0.1;
	}
}

//============================================================================

void Gremlin_JumpTouch(entity this, entity toucher);
void Gremlin_FlipTouch(entity this, entity toucher);
void Gremlin_Melee(entity this, float side);
void Gremlin_Gorge(entity this, float side);

void gremlin_stand1(entity this);
void gremlin_stand17(entity this) { set_animofs(this, anim_gremlin_stand, 17, gremlin_stand1); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand16(entity this) { set_animofs(this, anim_gremlin_stand, 16, gremlin_stand17); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand15(entity this) { set_animofs(this, anim_gremlin_stand, 15, gremlin_stand16); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand14(entity this) { set_animofs(this, anim_gremlin_stand, 14, gremlin_stand15); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand13(entity this) { set_animofs(this, anim_gremlin_stand, 13, gremlin_stand14); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand12(entity this) { set_animofs(this, anim_gremlin_stand, 12, gremlin_stand13); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand11(entity this) { set_animofs(this, anim_gremlin_stand, 11, gremlin_stand12); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand10(entity this) { set_animofs(this, anim_gremlin_stand, 10, gremlin_stand11); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand9(entity this) { set_animofs(this, anim_gremlin_stand, 9, gremlin_stand10); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand8(entity this) { set_animofs(this, anim_gremlin_stand, 8, gremlin_stand9); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand7(entity this) { set_animofs(this, anim_gremlin_stand, 7, gremlin_stand8); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand6(entity this) { set_animofs(this, anim_gremlin_stand, 6, gremlin_stand7); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand5(entity this) { set_animofs(this, anim_gremlin_stand, 5, gremlin_stand6); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand4(entity this) { set_animofs(this, anim_gremlin_stand, 4, gremlin_stand5); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand3(entity this) { set_animofs(this, anim_gremlin_stand, 3, gremlin_stand4); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand2(entity this) { set_animofs(this, anim_gremlin_stand, 2, gremlin_stand3); gremlin_stand(this); this.nextthink = time + 0.2; }
void gremlin_stand1(entity this) { set_animofs(this, anim_gremlin_stand, 1, gremlin_stand2); gremlin_stand(this); this.nextthink = time + 0.2; }

void gremlin_walk1(entity this);
void gremlin_walk12(entity this) { set_animofs(this, anim_gremlin_walk, 12, gremlin_walk1); gremlin_walk(this, 8); }
void gremlin_walk11(entity this) { set_animofs(this, anim_gremlin_walk, 11, gremlin_walk12); gremlin_walk(this, 8); }
void gremlin_walk10(entity this) { set_animofs(this, anim_gremlin_walk, 10, gremlin_walk11); gremlin_walk(this, 8); }
void gremlin_walk9(entity this) { set_animofs(this, anim_gremlin_walk, 9, gremlin_walk10); gremlin_walk(this, 8); }
void gremlin_walk8(entity this) { set_animofs(this, anim_gremlin_walk, 8, gremlin_walk9); gremlin_walk(this, 8); }
void gremlin_walk7(entity this) { set_animofs(this, anim_gremlin_walk, 7, gremlin_walk8); gremlin_walk(this, 8); }
void gremlin_walk6(entity this) { set_animofs(this, anim_gremlin_walk, 6, gremlin_walk7); gremlin_walk(this, 8); }
void gremlin_walk5(entity this) { set_animofs(this, anim_gremlin_walk, 5, gremlin_walk6); gremlin_walk(this, 8); }
void gremlin_walk4(entity this) { set_animofs(this, anim_gremlin_walk, 4, gremlin_walk5); gremlin_walk(this, 8); }
void gremlin_walk3(entity this) { set_animofs(this, anim_gremlin_walk, 3, gremlin_walk4); gremlin_walk(this, 8); }
void gremlin_walk2(entity this) { set_animofs(this, anim_gremlin_walk, 2, gremlin_walk3); gremlin_walk(this, 8); }
void gremlin_walk1(entity this)
{
	set_animofs(this, anim_gremlin_walk, 1, gremlin_walk2);
	if(random() < 0.1)
		_sound(this, CH_VOICE, "grem/idle.wav", 1, ATTN_IDLE);
	gremlin_walk(this, 8);
}

void gremlin_run1(entity this);
void gremlin_run15(entity this) { set_animofs(this, anim_gremlin_run, 15, gremlin_run1); gremlin_run(this, 0); }
void gremlin_run14(entity this) { set_animofs(this, anim_gremlin_run, 14, gremlin_run15); gremlin_run(this, 8); }
void gremlin_run13(entity this) { set_animofs(this, anim_gremlin_run, 13, gremlin_run14); gremlin_run(this, 12); }
void gremlin_run12(entity this) { set_animofs(this, anim_gremlin_run, 12, gremlin_run1); gremlin_run(this, 16); }
void gremlin_run11(entity this) { set_animofs(this, anim_gremlin_run, 11, gremlin_run12); gremlin_run(this, 16); }
void gremlin_run10(entity this) { set_animofs(this, anim_gremlin_run, 10, gremlin_run11); gremlin_run(this, 12); }
void gremlin_run9(entity this) { set_animofs(this, anim_gremlin_run, 9, gremlin_run10); gremlin_run(this, 8); }
void gremlin_run8(entity this) { set_animofs(this, anim_gremlin_run, 8, gremlin_run9); gremlin_run(this, 0); }
void gremlin_run7(entity this) { set_animofs(this, anim_gremlin_run, 7, gremlin_run8); gremlin_run(this, 8); }
void gremlin_run6(entity this) { set_animofs(this, anim_gremlin_run, 6, gremlin_run7); gremlin_run(this, 12); }
void gremlin_run5(entity this) { set_animofs(this, anim_gremlin_run, 5, gremlin_run6); gremlin_run(this, 16); }
void gremlin_run4(entity this) { set_animofs(this, anim_gremlin_run, 4, gremlin_run5); gremlin_run(this, 16); }
void gremlin_run3(entity this) { set_animofs(this, anim_gremlin_run, 3, gremlin_run4); gremlin_run(this, 12); }
void gremlin_run2(entity this) { set_animofs(this, anim_gremlin_run, 2, gremlin_run3); gremlin_run(this, 8); }
void gremlin_run1(entity this)
{
	set_animofs(this, anim_gremlin_run, 1, gremlin_run2);
	if(random() < 0.1)
		_sound(this, CH_VOICE, "grem/idle.wav", 1, ATTN_IDLE);
	gremlin_run(this, 0);
}

void gremlin_jump1(entity this);
void gremlin_jump16(entity this) { set_animofs(this, anim_gremlin_jump, 16, gremlin_run1); }
void gremlin_jump15(entity this) { set_animofs(this, anim_gremlin_jump, 15, gremlin_jump16); }
void gremlin_jump14(entity this) { set_animofs(this, anim_gremlin_jump, 14, gremlin_jump15); }
void gremlin_jump13(entity this) { set_animofs(this, anim_gremlin_jump, 13, gremlin_jump14); }
void gremlin_jump12(entity this) { set_animofs(this, anim_gremlin_jump, 12, gremlin_jump13); }
void gremlin_jump11(entity this)
{
	set_animofs(this, anim_gremlin_jump, 11, gremlin_jump11);
	if(IS_ONGROUND(this))
	{
		setthink(this, gremlin_jump13);
		settouch(this, func_null);
	}
}
void gremlin_jump10(entity this) { set_animofs(this, anim_gremlin_jump, 10, gremlin_jump11); }
void gremlin_jump9(entity this) { set_animofs(this, anim_gremlin_jump, 9, gremlin_jump10); }
void gremlin_jump8(entity this) { set_animofs(this, anim_gremlin_jump, 8, gremlin_jump9); }
void gremlin_jump7(entity this) { set_animofs(this, anim_gremlin_jump, 7, gremlin_jump8); }
void gremlin_jump6(entity this) { set_animofs(this, anim_gremlin_jump, 6, gremlin_jump7); }
void gremlin_jump5(entity this)
{
	set_animofs(this, anim_gremlin_jump, 5, gremlin_jump6);
	ai_face(this);

	if(IS_ONGROUND(this))
	{
		settouch(this, Gremlin_JumpTouch);
		fixedmakevectors(this.angles);
		setorigin(this, this.origin + '0 0 1');
		this.velocity = v_forward * 300 + '0 0 300';
		UNSET_ONGROUND(this);
	}
	else
		gremlin_run1(this);
}
void gremlin_jump4(entity this) { set_animofs(this, anim_gremlin_jump, 4, gremlin_jump5); ai_face(this); }
void gremlin_jump3(entity this) { set_animofs(this, anim_gremlin_jump, 3, gremlin_jump4); ai_face(this); }
void gremlin_jump2(entity this) { set_animofs(this, anim_gremlin_jump, 2, gremlin_jump3); ai_face(this); }
void gremlin_jump1(entity this) { set_animofs(this, anim_gremlin_jump, 1, gremlin_jump2); ai_face(this); }

void gremlin_shot6(entity this) { set_animofs(this, anim_gremlin_gfire, 6, gremlin_run1); }
void gremlin_shot5(entity this) { set_animofs(this, anim_gremlin_gfire, 5, gremlin_shot6); }
void gremlin_shot4(entity this) { set_animofs(this, anim_gremlin_gfire, 4, gremlin_shot5); }
void gremlin_shot3(entity this) { set_animofs(this, anim_gremlin_gfire, 3, gremlin_shot4); }
void gremlin_shot2(entity this) { set_animofs(this, anim_gremlin_gfire, 2, gremlin_shot3); }
void gremlin_shot1(entity this) { set_animofs(this, anim_gremlin_gfire, 1, gremlin_shot2); this.effects |= EF_MUZZLEFLASH; }


//============================================================================
void Gremlin_FireNailGun(entity this, float ox);

void gremlin_nail7(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_run1); }
void gremlin_nail6(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_nail7); this.effects |= EF_MUZZLEFLASH; Gremlin_FireNailGun(this, 4); }
void gremlin_nail5(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_nail6); this.effects |= EF_MUZZLEFLASH; Gremlin_FireNailGun(this, 4); }
void gremlin_nail4(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_nail5); this.effects |= EF_MUZZLEFLASH; Gremlin_FireNailGun(this, 4); }
void gremlin_nail3(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_nail4); this.effects |= EF_MUZZLEFLASH; Gremlin_FireNailGun(this, 4); }
void gremlin_nail2(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_nail3); this.effects |= EF_MUZZLEFLASH; Gremlin_FireNailGun(this, 4); }
void gremlin_nail1(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_nail2); this.effects |= EF_MUZZLEFLASH; Gremlin_FireNailGun(this, 4); }


void Gremlin_FireLaserGun(entity this, float ox);

void gremlin_laser7(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_run1); }
void gremlin_laser6(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_laser7); this.effects |= EF_MUZZLEFLASH; Gremlin_FireLaserGun(this, 4); }
void gremlin_laser5(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_laser6); this.effects |= EF_MUZZLEFLASH; Gremlin_FireLaserGun(this, 4); }
void gremlin_laser4(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_laser5); this.effects |= EF_MUZZLEFLASH; Gremlin_FireLaserGun(this, 4); }
void gremlin_laser3(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_laser4); this.effects |= EF_MUZZLEFLASH; Gremlin_FireLaserGun(this, 4); }
void gremlin_laser2(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_laser3); this.effects |= EF_MUZZLEFLASH; Gremlin_FireLaserGun(this, 4); }
void gremlin_laser1(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_laser2); this.effects |= EF_MUZZLEFLASH; Gremlin_FireLaserGun(this, 4); }

//============================================================================

void Gremlin_FireLightningGun(entity this);
void gremlin_light5(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_run1); }
void gremlin_light4(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_light5); Gremlin_FireLightningGun(this); }
void gremlin_light3(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_light4); Gremlin_FireLightningGun(this); }
void gremlin_light2(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_light3); Gremlin_FireLightningGun(this); }
void gremlin_light1(entity this) { set_anim(this, anim_gremlin_gfire, gremlin_light2); Gremlin_FireLightningGun(this); }

//============================================================================

void gremlin_rocket6(entity this) { set_animofs(this, anim_gremlin_gfire, 6, gremlin_run1); }
void gremlin_rocket5(entity this) { set_animofs(this, anim_gremlin_gfire, 5, gremlin_rocket6); }
void gremlin_rocket4(entity this) { set_animofs(this, anim_gremlin_gfire, 4, gremlin_rocket5); }
void gremlin_rocket3(entity this) { set_animofs(this, anim_gremlin_gfire, 3, gremlin_rocket4); }
void gremlin_rocket2(entity this) { set_animofs(this, anim_gremlin_gfire, 2, gremlin_rocket3); }
void gremlin_rocket1(entity this) { set_animofs(this, anim_gremlin_gfire, 1, gremlin_rocket2); this.effects |= EF_MUZZLEFLASH; }

void gremlin_lunge11(entity this) { set_animofs(this, anim_gremlin_lunge, 11, gremlin_run1); ai_charge(this, 0); }
void gremlin_lunge10(entity this) { set_animofs(this, anim_gremlin_lunge, 10, gremlin_lunge11); ai_charge(this, 0); }
void gremlin_lunge9(entity this) { set_animofs(this, anim_gremlin_lunge, 9, gremlin_lunge10); ai_charge(this, 0); }
void gremlin_lunge8(entity this) { set_animofs(this, anim_gremlin_lunge, 8, gremlin_lunge9); ai_charge(this, 0); Gremlin_Melee(this, 0); }
void gremlin_lunge7(entity this) { set_animofs(this, anim_gremlin_lunge, 7, gremlin_lunge8); ai_charge(this, 15); }
void gremlin_lunge6(entity this) { set_animofs(this, anim_gremlin_lunge, 6, gremlin_lunge7); ai_charge(this, 0); }
void gremlin_lunge5(entity this) { set_animofs(this, anim_gremlin_lunge, 5, gremlin_lunge6); ai_charge(this, 0); }
void gremlin_lunge4(entity this) { set_animofs(this, anim_gremlin_lunge, 4, gremlin_lunge5); ai_charge(this, 0); }
void gremlin_lunge3(entity this) { set_animofs(this, anim_gremlin_lunge, 3, gremlin_lunge4); ai_charge(this, 0); }
void gremlin_lunge2(entity this) { set_animofs(this, anim_gremlin_lunge, 2, gremlin_lunge3); ai_charge(this, 0); }
void gremlin_lunge1(entity this) { set_animofs(this, anim_gremlin_lunge, 1, gremlin_lunge2); ai_charge(this, 0); }

void gremlin_claw11(entity this) { set_animofs(this, anim_gremlin_attk, 11, gremlin_run1); ai_charge(this, 0); }
void gremlin_claw10(entity this) { set_animofs(this, anim_gremlin_attk, 10, gremlin_claw11); ai_charge(this, 0); }
void gremlin_claw9(entity this) { set_animofs(this, anim_gremlin_attk, 9, gremlin_claw10); ai_charge(this, 0); }
void gremlin_claw8(entity this) { set_animofs(this, anim_gremlin_attk, 8, gremlin_claw9); ai_charge(this, 0); }
void gremlin_claw7(entity this) { set_animofs(this, anim_gremlin_attk, 7, gremlin_claw8); ai_charge(this, 15); }
void gremlin_claw6(entity this) { set_animofs(this, anim_gremlin_attk, 6, gremlin_claw7); ai_charge(this, 0); Gremlin_Melee(this, 200); }
void gremlin_claw5(entity this) { set_animofs(this, anim_gremlin_attk, 5, gremlin_claw6); ai_charge(this, 0); }
void gremlin_claw4(entity this) { set_animofs(this, anim_gremlin_attk, 4, gremlin_claw5); ai_charge(this, 0); }
void gremlin_claw3(entity this) { set_animofs(this, anim_gremlin_attk, 3, gremlin_claw4); ai_charge(this, 0); }
void gremlin_claw2(entity this) { set_animofs(this, anim_gremlin_attk, 2, gremlin_claw3); ai_charge(this, 0); }
void gremlin_claw1(entity this) { set_animofs(this, anim_gremlin_attk, 1, gremlin_claw2); ai_charge(this, 0); }

void gremlin_gorge1(entity this);
void gremlin_gorge13(entity this) { set_animofs(this, anim_gremlin_maul, 13, gremlin_gorge1); ai_charge(this, 0); }
void gremlin_gorge12(entity this) { set_animofs(this, anim_gremlin_maul, 12, gremlin_gorge13); ai_charge(this, 0); }
void gremlin_gorge11(entity this) { set_animofs(this, anim_gremlin_maul, 11, gremlin_gorge12); ai_charge(this, 0); }
void gremlin_gorge10(entity this) { set_animofs(this, anim_gremlin_maul, 10, gremlin_gorge11); ai_charge(this, 0); }
void gremlin_gorge9(entity this) { set_animofs(this, anim_gremlin_maul, 9, gremlin_gorge10); ai_charge(this, 0); }
void gremlin_gorge8(entity this) { set_animofs(this, anim_gremlin_maul, 8, gremlin_gorge9); ai_charge(this, 0); Gremlin_Gorge(this, -200); }
void gremlin_gorge7(entity this) { set_animofs(this, anim_gremlin_maul, 7, gremlin_gorge8); ai_charge(this, 0); }
void gremlin_gorge6(entity this) { set_animofs(this, anim_gremlin_maul, 6, gremlin_gorge7); ai_charge(this, 0); Gremlin_Gorge(this, 200); }
void gremlin_gorge5(entity this) { set_animofs(this, anim_gremlin_maul, 5, gremlin_gorge6); ai_charge(this, 0); }
void gremlin_gorge4(entity this) { set_animofs(this, anim_gremlin_maul, 4, gremlin_gorge5); ai_charge(this, 0); }
void gremlin_gorge3(entity this) { set_animofs(this, anim_gremlin_maul, 3, gremlin_gorge4); ai_charge(this, 2); }
void gremlin_gorge2(entity this) { set_animofs(this, anim_gremlin_maul, 2, gremlin_gorge3); ai_charge(this, 1); }
void gremlin_gorge1(entity this) { set_animofs(this, anim_gremlin_maul, 1, gremlin_gorge2); ai_charge(this, 1); }

void gremlin_look9(entity this)
{
	set_animofs(this, anim_gremlin_look, 9, gremlin_run1);
	if(this.oldenemy.health > 0)
	{
		this.enemy = this.oldenemy;
		HuntTarget(this);
	}
	else
	{
		if(this.movetarget)
			this.th_walk(this);
		else
			this.th_stand(this);
	}
}
void gremlin_look8(entity this) { set_animofs(this, anim_gremlin_look, 8, gremlin_look9); this.nextthink = time + 0.2; }
void gremlin_look7(entity this) { set_animofs(this, anim_gremlin_look, 7, gremlin_look8); this.nextthink = time + 0.2; }
void gremlin_look6(entity this) { set_animofs(this, anim_gremlin_look, 6, gremlin_look7); this.nextthink = time + 0.2; }
void gremlin_look5(entity this) { set_animofs(this, anim_gremlin_look, 5, gremlin_look6); this.nextthink = time + 0.2; }
void gremlin_look4(entity this) { set_animofs(this, anim_gremlin_look, 4, gremlin_look5); this.nextthink = time + 0.2; }
void gremlin_look3(entity this) { set_animofs(this, anim_gremlin_look, 3, gremlin_look4); this.nextthink = time + 0.2; }
void gremlin_look2(entity this) { set_animofs(this, anim_gremlin_look, 2, gremlin_look3); this.nextthink = time + 0.2; }
void gremlin_look1(entity this) { set_animofs(this, anim_gremlin_look, 1, gremlin_look2); this.nextthink = time + 0.2; }

void GremlinDropBackpack(entity this);
void gremlin_glook20(entity this)
{
	set_animofs(this, anim_gremlin_glook, 20, gremlin_glook20);
	GremlinDropBackpack(this);
	this.stoleweapon = false;
	if(this.oldenemy.health > 0)
	{
		this.enemy = this.oldenemy;
		HuntTarget(this);
	}
	else
	{
		if(this.movetarget)
			this.th_walk(this);
		else
			this.th_stand(this);
	}
}
void gremlin_glook19(entity this) { set_animofs(this, anim_gremlin_glook, 19, gremlin_glook20); }
void gremlin_glook18(entity this) { set_animofs(this, anim_gremlin_glook, 18, gremlin_glook19); }
void gremlin_glook17(entity this) { set_animofs(this, anim_gremlin_glook, 17, gremlin_glook18); }
void gremlin_glook16(entity this) { set_animofs(this, anim_gremlin_glook, 16, gremlin_glook17); }
void gremlin_glook15(entity this) { set_animofs(this, anim_gremlin_glook, 15, gremlin_glook16); }
void gremlin_glook14(entity this) { set_animofs(this, anim_gremlin_glook, 14, gremlin_glook15); }
void gremlin_glook13(entity this) { set_animofs(this, anim_gremlin_glook, 13, gremlin_glook14); }
void gremlin_glook12(entity this) { set_animofs(this, anim_gremlin_glook, 12, gremlin_glook13); }
void gremlin_glook11(entity this) { set_animofs(this, anim_gremlin_glook, 11, gremlin_glook12); }
void gremlin_glook10(entity this) { set_animofs(this, anim_gremlin_glook, 10, gremlin_glook11); }
void gremlin_glook9(entity this) { set_animofs(this, anim_gremlin_glook, 9, gremlin_glook10); }
void gremlin_glook8(entity this) { set_animofs(this, anim_gremlin_glook, 8, gremlin_glook9); }
void gremlin_glook7(entity this) { set_animofs(this, anim_gremlin_glook, 7, gremlin_glook8); }
void gremlin_glook6(entity this) { set_animofs(this, anim_gremlin_glook, 6, gremlin_glook7); }
void gremlin_glook5(entity this) { set_animofs(this, anim_gremlin_glook, 5, gremlin_glook6); }
void gremlin_glook4(entity this) { set_animofs(this, anim_gremlin_glook, 4, gremlin_glook5); }
void gremlin_glook3(entity this) { set_animofs(this, anim_gremlin_glook, 3, gremlin_glook4); }
void gremlin_glook2(entity this) { set_animofs(this, anim_gremlin_glook, 2, gremlin_glook3); }
void gremlin_glook1(entity this) { set_animofs(this, anim_gremlin_glook, 1, gremlin_glook2); }

void gremlin_pain4(entity this) { set_animofs(this, anim_gremlin_pain, 4, gremlin_run1); }
void gremlin_pain3(entity this) { set_animofs(this, anim_gremlin_pain, 3, gremlin_pain4); ai_back(this, 2); }
void gremlin_pain2(entity this) { set_animofs(this, anim_gremlin_pain, 2, gremlin_pain3); ai_back(this, 4); }
void gremlin_pain1(entity this) { set_animofs(this, anim_gremlin_pain, 1, gremlin_pain2); ai_back(this, 4); }

void gremlin_gunpain3(entity this) { set_animofs(this, anim_gremlin_gpain, 3, gremlin_run1); }
void gremlin_gunpain2(entity this) { set_animofs(this, anim_gremlin_gpain, 2, gremlin_gunpain3); ai_back(this, 2); }
void gremlin_gunpain1(entity this) { set_animofs(this, anim_gremlin_gpain, 1, gremlin_gunpain2); ai_back(this, 4); }

void gremlin_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(random() < 0.8)
	{
		this.gorging = false;
		this.enemy = attacker;
		FoundTarget(this);
	}
	if(gettouch(this) == Gremlin_JumpTouch)
		return;

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 1;
//   if(random()<0.5)
//      _sound(this, CH_VOICE, "grem/pain2.wav", 1, ATTN_NORM);
//   else
	float r = random();
	if(r < 0.33)
		_sound(this, CH_VOICE, "grem/pain1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_VOICE, "grem/pain2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "grem/pain3.wav", 1, ATTN_NORM);

	if(this.stoleweapon)
		gremlin_gunpain1(this);
	else
		gremlin_pain1(this);
}

void gremlin_spawn6(entity this) { set_animofs(this, anim_gremlin_spawn, 6, gremlin_run1); this.th_pain = gremlin_pain; }
void gremlin_spawn5(entity this) { set_animofs(this, anim_gremlin_spawn, 5, gremlin_spawn6); this.nextthink = time + 0.3; }
void gremlin_spawn4(entity this) { set_animofs(this, anim_gremlin_spawn, 4, gremlin_spawn5); this.nextthink = time + 0.3; }
void gremlin_spawn3(entity this) { set_animofs(this, anim_gremlin_spawn, 3, gremlin_spawn4); this.nextthink = time + 0.3; }
void gremlin_spawn2(entity this) { set_animofs(this, anim_gremlin_spawn, 2, gremlin_spawn3); this.nextthink = time + 0.3; }
void gremlin_spawn1(entity this) { set_animofs(this, anim_gremlin_spawn, 1, gremlin_spawn2); this.nextthink = time + 0.3; this.th_pain = func_null; }

void gremlin_die12(entity this) { set_animofs(this, anim_gremlin_death, 12, gremlin_die12); }
void gremlin_die11(entity this) { set_animofs(this, anim_gremlin_death, 11, gremlin_die12); ai_forward(this, 2); }
void gremlin_die10(entity this) { set_animofs(this, anim_gremlin_death, 10, gremlin_die11); ai_forward(this, 1); }
void gremlin_die9(entity this) { set_animofs(this, anim_gremlin_death, 9, gremlin_die10); ai_forward(this, 2); }
void gremlin_die8(entity this) { set_animofs(this, anim_gremlin_death, 8, gremlin_die9); ai_forward(this, 1); }
void gremlin_die7(entity this) { set_animofs(this, anim_gremlin_death, 7, gremlin_die8); ai_forward(this, 2); }
void gremlin_die6(entity this) { set_animofs(this, anim_gremlin_death, 6, gremlin_die7); this.solid = SOLID_NOT; }
void gremlin_die5(entity this) { set_animofs(this, anim_gremlin_death, 5, gremlin_die6); ai_forward(this, 1); }
void gremlin_die4(entity this) { set_animofs(this, anim_gremlin_death, 4, gremlin_die5); ai_forward(this, 2); }
void gremlin_die3(entity this) { set_animofs(this, anim_gremlin_death, 3, gremlin_die4); ai_forward(this, 1); }
void gremlin_die2(entity this) { set_animofs(this, anim_gremlin_death, 2, gremlin_die3); ai_forward(this, 2); }
void gremlin_die1(entity this) { set_animofs(this, anim_gremlin_death, 1, gremlin_die2); _sound(this, CH_VOICE, "grem/death.wav", 1, ATTN_NORM); }

void gremlin_flip8(entity this) { set_animofs(this, anim_gremlin_flip, 8, gremlin_flip8); this.solid = SOLID_NOT; }
void gremlin_flip7(entity this)
{
	set_animofs(this, anim_gremlin_flip, 7, gremlin_flip7);
	if(IS_ONGROUND(this))
	{
		setthink(this, gremlin_flip8);
		settouch(this, func_null);
	}
}
void gremlin_flip6(entity this) { set_animofs(this, anim_gremlin_flip, 6, gremlin_flip7); settouch(this, Gremlin_FlipTouch); }
void gremlin_flip5(entity this) { set_animofs(this, anim_gremlin_flip, 5, gremlin_flip6); }
void gremlin_flip4(entity this) { set_animofs(this, anim_gremlin_flip, 4, gremlin_flip5); }
void gremlin_flip3(entity this) { set_animofs(this, anim_gremlin_flip, 3, gremlin_flip4); }
void gremlin_flip2(entity this) { set_animofs(this, anim_gremlin_flip, 2, gremlin_flip3); ai_face(this); }
void gremlin_flip1(entity this)
{
	set_animofs(this, anim_gremlin_flip, 1, gremlin_flip2);
	ai_face(this);
	makevectors (this.angles);
	setorigin(this, this.origin + '0 0 1');
	this.velocity = '0 0 350' - (v_forward * 200);
	UNSET_ONGROUND(this);
	_sound(this, CH_VOICE, "grem/death.wav", 1, ATTN_NORM);
}

/*
===============
GremlinDropBackpack
===============
*/
void GremlinDropBackpack(entity this)
{
	entity item = spawn();
	item.origin = this.origin - '0 0 24';

	this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	item.items = this.items;
	item.powerups = this.powerups;

	Weapon wep = this.weaponentity.m_weapon;
	item.netname = wep.m_name;
	item.weapon = wep.m_id;

	item.ammo_shells = max(0, this.ammo_shells);
	item.ammo_nails = max(0, this.ammo_nails);
	item.ammo_rockets = max(0, this.ammo_rockets);
	item.ammo_cells = max(0, this.ammo_cells);

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);

	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_TOSS);
	_setmodel(item, "progs/backpack.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	settouch(item, BackpackTouch);

	item.nextthink = time + 120; // remove after 2 minutes
	setthink(item, SUB_Remove);
}

void gremlin_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.weaponentity.m_weapon != WEP_Null)
	{
		GremlinDropBackpack(this);
		this.stoleweapon = false;
	}

	makevectors(this.angles);
	vector vec = normalize(attacker.origin - this.origin);
	float dot = vec * v_forward;

	if(this.health < -35)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_grem.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		return;
	}
	else if(dot > 0.7 && (random() < 0.5) && IS_ONGROUND(this))
	{
		gremlin_flip1(this);
		return;
	}
// regular death
	gremlin_die1(this);
}


bool GremlinWeaponAttack(entity this);
void Gremlin_MeleeAttack(entity this)
{
	if(this.gorging)
		gremlin_gorge1(this);
	else
	{
		if(this.stoleweapon == 1)
			objerror(this, "gremlin meleeing with stolen weapon");
		else if(IS_CLIENT(this.enemy) && random() < 0.4)
		{
			if(GremlinAttemptWeaponSteal(this))
				return;
		}
		float num = random();
		if(num < 0.3)
			gremlin_claw1(this);
		else if(num < 0.6)
			gremlin_lunge1(this);
		else
			gremlin_claw1(this);
	}
}


/*
============
GremlinCheckNoAmmo

attack with a weapon
============
*/
bool GremlinCheckNoAmmo(entity this)
{
	if(this.currentammo > 0)
		return true;
	else
	{
		this.stoleweapon = false;
		return false;
	}
}

/*
============
GremlinFindVictim

find a victim to shoot at
============
*/
entity GremlinFindVictim(entity this)
{
	this.search_time = time + 1.0;
// look in our immediate vicinity

	entity selected = NULL;
	float dist = 1000;
	entity head = findradius(this.origin, 1000);
	while(head)
	{
		if(!(head.flags & FL_NOTARGET) && (IS_MONSTER(head) || IS_CLIENT(head)))
		{
			if(visible(this, head) && (head.health > 0) && (head !=this))
			{
				float head_dist = vlen(head.origin - this.origin);
				if(head == this.lastvictim)
					head_dist = head_dist * 2;
				if(head.flags & FL_CLIENT)
					head_dist = head_dist / 1.5;
				if(head.classname == this.classname)
					head_dist = head_dist * 1.5;
				if(head_dist < dist)
				{
					selected = head;
					dist = head_dist;
				}
			}
		}
		head = head.chain;
	}
	this.lastvictim = selected;

	return selected;
}

/*
============
Gremlin_FireRocket

fire a rocket
============
*/
void Gremlin_FireRocket(entity this)
{
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
	this.effects |= EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(missile);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_ROCKET_LAUNCHER.m_id;

// set missile speed

	vector dir = normalize(this.enemy.origin - this.origin);
	this.v_angle = vectoangles(dir);
	makevectors(this.v_angle);
	dir = dir + crandom()* 0.1 * v_right + crandom()* 0.1 * v_up;
	missile.velocity = normalize(dir);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);

	settouch(missile, T_MissileTouch);

// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin + v_forward * 8 + '0 0 16');
//   GremlinRecoil(dir,-1000);
}

/*
============
Gremlin_FireNailGun

fire a nailgun
============
*/
void Gremlin_FireNailGun(entity this, float ox)
{
	this.currentammo = this.ammo_nails = this.ammo_nails - 1;
	this.effects |= EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	vector dir = normalize(this.enemy.origin - this.origin);
	this.v_angle = vectoangles(dir);
	makevectors(this.v_angle);
	dir = dir + crandom() * 0.1 * v_right + crandom() * 0.1 *v_up;
	dir = normalize(dir);
	entity missile = launch_spike(this, this.origin + '0 0 16', dir);
	missile.projectiledeathtype = WEP_NAILGUN.m_id;
}

/*
============
Gremlin_FireLaserGun

fire a laser cannon
============
*/
void Gremlin_FireLaserGun(entity this, float ox)
{
	this.currentammo = this.ammo_cells = this.ammo_cells - 1;
	this.effects |= EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	vector dir = normalize(this.enemy.origin - this.origin);
	this.v_angle = vectoangles(dir);
	makevectors(this.v_angle);
	dir = dir + crandom()* 0.1 * v_right + crandom()* 0.1 *v_up;
	dir = normalize(dir);
	HIP_LaunchLaser(this, this.origin + '0 0 16', dir, 0);
}

/*
============
Gremlin_FireShotgun

fire a shotgun
============
*/
void Gremlin_FireShotgun(entity this)
{
	this.currentammo = this.ammo_shells = this.ammo_shells - 1;
	this.effects |= EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "weapons/guncock.wav", 1, ATTN_NORM);
	vector dir = normalize(this.enemy.origin - this.origin);
	this.v_angle = vectoangles(dir);
	makevectors(this.v_angle);
	dir = dir + crandom()* 0.1 *v_right + crandom()* 0.1 *v_up;
	dir = normalize(dir);
	this.v_angle = vectoangles(dir);
	FireBullets(this, 6, dir, '0.04 0.04 0', WEP_SHOTGUN.m_id);
}

/*
============
Gremlin_FireSuperShotgun

fire a shotgun
============
*/
void Gremlin_FireSuperShotgun(entity this)
{
	this.currentammo = this.ammo_shells = this.ammo_shells - 2;
	this.effects |= EF_MUZZLEFLASH;

	_sound(this ,CH_WEAPON_SINGLE, "weapons/shotgn2.wav", 1, ATTN_NORM);
	vector dir = normalize(this.enemy.origin - this.origin);
	this.v_angle = vectoangles(dir);
	makevectors(this.v_angle);
	dir = dir + crandom() * 0.3 * v_right + crandom() * 0.3 *v_up;
	dir = normalize(dir);
	this.v_angle = vectoangles(dir);
	FireBullets(this, 14, dir, '0.14 0.08 0', WEP_SUPER_SHOTGUN.m_id);
}

/*
============
Gremlin_FireLightningGun

fire lightning gun
============
*/
void Gremlin_FireLightningGun(entity this)
{
// explode if under water
	if(this.watertype <= CONTENT_WATER)
	{
		int cells = this.ammo_cells;
		this.ammo_cells = 0;
		discharged = true;
		T_RadiusDamage(this, this, 35 * cells, DEATH_DISCHARGE.m_id, NULL);
		discharged = false;
//      W_SetCurrentAmmo ();
		return;
	}

	this.effects |= EF_MUZZLEFLASH;

	ai_face(this);

	this.currentammo = this.ammo_cells = this.ammo_cells - 2;
	vector org = this.origin + '0 0 16';

	vector dir = this.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);
	dir = normalize(this.enemy.origin - this.origin);
	this.v_angle = vectoangles(dir);
	makevectors(this.v_angle);
	dir = dir + crandom()* 0.1 *v_right + crandom()* 0.1 *v_up;
	dir = normalize(dir);

	traceline(org, this.origin + dir*600, true, this);

	//te_lightning2(NULL, org, trace_endpos); // should be this
	SendCSQCLightningBeam(org, trace_endpos);

	LightningDamage(org, trace_endpos + (dir * 4), this, 30, WEP_LIGHTNING.m_id);
}

/*
================
GremlinFireProximityGrenade
================
*/
void GremlinFireProximityGrenade(entity this)
{
	this.NumProximityGrenades = this.NumProximityGrenades + 1;
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;

	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	entity missile = new(proximity_grenade);
	missile.owner = this;
	missile.lastvictim = this;
	set_movetype(missile, MOVETYPE_TOSS);
	missile.solid = SOLID_BBOX;
	missile.takedamage = DAMAGE_NO;
	missile.health = 5;
	missile.state = 0;

// set missile speed

	vector dir = normalize(this.enemy.origin - this.origin);
	this.v_angle = vectoangles(dir);
	makevectors(this.v_angle);
	dir = dir + crandom() * 0.1 * v_right + crandom() * 0.1 * v_up;
	dir = normalize(dir);
	missile.velocity = dir * 600;
	missile.velocity_z = 200;

	missile.avelocity = '100 600 100';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, ProximityGrenadeTouch);

// set missile duration
	missile.nextthink = time + 2;
	missile.delay = time + 15 + (10 * random());
	setthink(missile, ProximityBomb);
	missile.th_die = ProximityGrenadeExplode;

	_setmodel(missile, "progs/proxbomb.mdl");
	setorigin(missile, this.origin);
	setsize(missile, '-1 -1 -1', '1 1 1');
}

/*
============
GremlinWeaponAttack

attack with a weapon
============
*/
void gremlin_shot1(entity this);
void gremlin_nail1(entity this);
void gremlin_light1(entity this);
void gremlin_rocket1(entity this);

bool GremlinWeaponAttack(entity this)
{
	if(!GremlinCheckNoAmmo(this))
		return false;

	this.show_hostile = time + 1; // wake monsters up

	if(this.weaponentity.m_weapon == WEP_SHOTGUN)
	{
		gremlin_shot1(this);
		Gremlin_FireShotgun(this);
		SUB_AttackFinished(this, 1);
	}
	else if(this.weaponentity.m_weapon == WEP_SUPER_SHOTGUN)
	{
		gremlin_shot1(this);
		Gremlin_FireSuperShotgun(this);
		SUB_AttackFinished(this, 1);
	}
	else if(this.weaponentity.m_weapon == WEP_NAILGUN)
	{
		gremlin_nail3(this);
		SUB_AttackFinished(this, 1);
	}
	else if(this.weaponentity.m_weapon == WEP_SUPER_NAILGUN)
	{
		gremlin_nail3(this);
		SUB_AttackFinished(this, 1);
	}
	else if(this.weaponentity.m_weapon == WEP_GRENADE_LAUNCHER)
	{
		gremlin_rocket1(this);
		OgreFireGrenade(this);
		this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
		SUB_AttackFinished(this, 1);
	}
	else if(this.weaponentity.m_weapon == WEP_ROCKET_LAUNCHER)
	{
		gremlin_rocket1(this);
		Gremlin_FireRocket(this);
		SUB_AttackFinished(this, 1);
	}
	else if(this.weaponentity.m_weapon == WEP_LIGHTNING)
	{
		gremlin_light1(this);
		SUB_AttackFinished(this, 1);
		_sound(this, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
	else if(this.weaponentity.m_weapon == WEP_LASER_CANNON)
	{
		gremlin_laser3(this);
		SUB_AttackFinished(this, 1);
	}
	else if(this.weaponentity.m_weapon == WEP_PROXIMITY_GUN)
	{
		gremlin_rocket1(this);
		GremlinFireProximityGrenade(this);
		SUB_AttackFinished(this, 1);
	}
	return true;
}

void Gremlin_MissileAttack(entity this)
{
	if(this.stoleweapon)
	{
		if(GremlinWeaponAttack(this))
			return;
		else if((random() < 0.1) && IS_ONGROUND(this))
		{
			gremlin_jump1(this);
			return;
		}
	}
	if(IS_ONGROUND(this))
		gremlin_jump1(this);
}

bool GremlinCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;

	entity targ = this.enemy;

// see if any entities are in the way of the shot
	vector spot1 = this.origin;// + this.view_ofs;
	vector spot2 = targ.origin;// + targ.view_ofs;

	if((vdist(spot2 - spot1, <=, 90)) && (this.stoleweapon == 0))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
// missile attack
	float chance = 0.03 + this.stoleweapon;
	if(random() < chance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}
	return false;
}


//===========================================================================

void Gremlin_Melee(entity this, float side)
{
	ai_face(this);

//   t_walkmove (this.ideal_yaw, 12);   // allow a little closing


	vector delta = this.enemy.origin - this.origin;

	if(vdist(delta, >, 100))
		return;
	if(!CanDamage (this.enemy, this))
		return;

	_sound(this, CH_WEAPON_SINGLE, "grem/attack.wav", 1, ATTN_NORM);
	float ldmg = 10 + 5*random();
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_GREMLIN.m_id);

	makevectors(this.angles);
	SpawnMeatSpray(this, this.origin + v_forward * 16, side * v_right);
}

//===========================================================================
void Gremlin_ThrowHead(entity this, float dm)
{
	string gibname = "progs/h_player.mdl";
	Monster mon = this.monsterdef;
	if(mon.m_model_head)
		gibname = mon.m_model_head.model_str();
	ThrowHead(this, gibname, dm);
}

/*
============
Gremlin_Damage

The damage is coming from inflictor, but get mad at attacker
============
*/
void Gremlin_Damage(entity targ, entity inflictor, entity attacker, float damage)
{
// check for godmode or invincibility
	if(targ.flags & FL_GODMODE)
		return;
	if(targ.invincible_finished >= time)
	{
		if(targ.invincible_sound < time)
		{
			_sound(targ, CH_TRIGGER_SINGLE, "items/protect3.wav", 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
	if((teamplay == 1) && (targ.team > 0) && (targ.team == attacker.team) )
		return;

// do the damage
	targ.health -= damage;
}

void Gremlin_Split(entity this)
{
	if(NumSpawnGremlins >= (NumGremlins*2))
		return;
	vector pos = '0 0 0';
	bool done = false;
	bool proceed = false;
	int c = 0;
	vector ang = this.angles;
	while(done == false)
	{
		makevectors(ang);
		pos = this.origin + (80 * v_forward);
		entity head = findradius(pos, 35);
		proceed = true;
		while (head)
		{
			if(head.health > 0 && (IS_MONSTER(head) || IS_CLIENT(head)))
				proceed = false;
			head = head.chain;
		}
		traceline(this.origin,pos,false,this);
		if(trace_fraction == 1 && (proceed == true))
		{
			traceline(this.origin, (pos-'40 40 0'), false, this);
			if(trace_fraction == 1)
			{
				traceline(this.origin, (pos+'40 40 0'), false, this);
				if(trace_fraction == 1)
				{
					traceline(this.origin, (pos + '0 0 64'), false, this);
					if(trace_fraction == 1)
					{
						traceline(this.origin, (pos - '0 0 64'), false, this);
						if(trace_fraction != 1)
						{
							done = true;
						}
					}
				}
			}
		}
		if(done == false)
		{
			ang.y = ang.y + 36;
			c = c + 1;
			if(c == 10)
				return;
		}
	}
	NumSpawnGremlins = NumSpawnGremlins + 1;
	entity grem = spawn();
	SUB_CopyEntity(this,grem);
	grem.solid = SOLID_SLIDEBOX;
	set_movetype(grem, MOVETYPE_STEP);
	_setmodel(grem, "progs/grem.mdl");
	setsize(grem, VEC_HULL_MIN, VEC_HULL_MAX);
	if(this.health < 100) this.health = 100;
	grem.health = this.health / 2;
	this.health = this.health / 2;
//   grem.max_health = 101;
//   grem.gorging = false;
	grem.stoleweapon = false;
	grem.items = 0;
	grem.powerups = 0;
	monsters_total += 1;
	setorigin(grem, pos);
	gremlin_spawn1(grem);
	grem.enemy = NULL;
	grem.gorging = false;
}

void Gremlin_Gorge(entity this, float side)
{
	//vector delta = this.enemy.origin - this.origin;

	_sound(this, CH_WEAPON_SINGLE, "demon/dhit2.wav", 1, ATTN_NORM);
	float ldmg = 7 + 5 * random();
	Gremlin_Damage(this.enemy, this, this, ldmg);

	makevectors(this.angles);
	SpawnMeatSpray(this, this.origin + v_forward * 16, side * v_right);
	if(this.enemy.health < -200.0)
	{
		if(this.enemy.gorging==false)
		{
			this.enemy.gorging = true;
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			Gremlin_ThrowHead(this.enemy, -15);
			ldmg = 150 + 100 * random();
			T_Heal(this, ldmg, false);
//         if(this.health >= this.max_health)
				Gremlin_Split(this);
		}
		this.enemy = NULL;
		this.gorging = false;

		gremlin_look1(this);
	}
}


void Gremlin_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0)
		return;

	if(!checkbottom(this))
	{
		if(IS_ONGROUND(this))
		{
			settouch(this, func_null);
			setthink(this, gremlin_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	setthink(this, gremlin_jump12);
	this.nextthink = time + 0.1;
}

void Gremlin_FlipTouch(entity this, entity toucher)
{
	if(!checkbottom(this))
	{
		if(IS_ONGROUND(this))
		{
			settouch(this, func_null);
			setthink(this, gremlin_flip1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	setthink(this, gremlin_flip8);
	this.nextthink = time + 0.1;
}

string gremlin_sight(entity this) { return "grem/sight1.wav"; }

bool GremlinCheckAttack(entity this);

/*QUAKED monster_gremlin (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
spawnfunc(monster_gremlin)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	monster_start(this, MON_GREMLIN);
}
#endif // SVQC

#ifdef SVQC
METHOD(Gremlin, mr_setup, bool(Gremlin this, entity actor))
{
    TC(Gremlin, this);

	precache_sound("grem/death.wav");
	precache_sound("grem/attack.wav");
	precache_sound("demon/djump.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("grem/pain1.wav");
	precache_sound("grem/pain2.wav");
	precache_sound("grem/pain3.wav");
	precache_sound("grem/idle.wav");
	precache_sound("grem/sight1.wav");

	actor.weaponentity = actor; // hack to allow weapon system to work

    actor.health = 100;
    actor.yaw_speed = 40;
    actor.th_stand = gremlin_stand1;
	actor.th_walk = gremlin_walk1;
	actor.th_run = gremlin_run1;
	actor.th_die = gremlin_die;
	actor.th_melee = Gremlin_MeleeAttack;     // one of two attacks
	actor.th_missile = Gremlin_MissileAttack; // check for random jump or firing of weapon
	actor.th_pain = gremlin_pain;

	actor.checkattack = GremlinCheckAttack;
	actor.sightsound = gremlin_sight;

    return true;
}
#endif
