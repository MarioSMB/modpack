#include "eow.qh"

#ifdef SVQC
const float ATTN_EOW = 0.5;

const int CLIPGROUP_EOW = 21; // randomly picked! search for CLIPGROUP_ to find others used

.entity eow_next;
.entity eow_prev;

.float idle_finished;

.float eow_lastthink; // head ticks at a slower rate!

/*================
	MOVEMENT
==================*/
void eow_setangle(entity this, entity targ, float angspeed)
{
	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(targ);
	vector ideal = vectoangles(normalize(targorg - myorg));
	if(this.angles == ideal)
		return;

	//float angspeed = this.yaw_speed;
	ideal -= this.angles;

	this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

void eow_movetogoal(entity this, float movespeed)
{
	eow_setangle(this, this.goalentity, 8);

	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	this.velocity = v_forward * movespeed + v_up * (sin(time) * (movespeed * 0.5));
}

void eow_FindTarget(entity this)
{
	if(this.enemy.health <= 0 || (coop && random() < 0.02))
		this.enemy = NULL;

	if(!this.enemy)
	{
		RandomSelection_Init();
		if(this.charmed)
		{
			FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
			{
				if(it != this && this.enemy != it && it.health > 0 && !(it.flags & FL_NOTARGET) && !it.charmed)
				{
					// enable for line of sight
					//traceline(CENTER_OR_VIEWOFS(this), it.origin, true, this);
					//if(trace_fraction != 1)
						//continue;
					RandomSelection_AddEnt(it, 1, 1);
				}
			});
		}
		else
		{
			FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET),
			{
				// enable for line of sight
				//traceline(this.origin + '0 0 16', it.origin, true, this);
				//if(trace_fraction != 1)
					//continue;
				RandomSelection_AddEnt(it, 1, 1);
			});
		}
			
		this.enemy = RandomSelection_chosen_ent;
	}
}

void eow_head_frame(entity this)
{
	// go for another player if multi player
	eow_FindTarget(this);

	// now pick a movement target (if we're not a body part!)
	if(this.enemy)
		this.goalentity = this.enemy;
	else if(this.charmer)
		this.goalentity = this.charmer;
	else if(!boxesoverlap(this.absmin, this.absmax, world.mins, world.maxs))
		this.goalentity = world; // try to move towards the world origin?
	else
		this.goalentity = this.eow_prev; // TODO: make sure it doesn't just fly out of the world!

	for(entity ent = this.eow_next; ent; ent = ent.eow_next)
	{
		ent.enemy = this.enemy;
	}

	// only the head decides movement!
	float movespeed = (this.enemy) ? 500 : 400; // TODO: speed up near enemy
	eow_movetogoal(this, movespeed);

	if(time > this.idle_finished)
	{
		_sound(this, CH_SHOTS, "eow/dig.wav", 1, ATTN_EOW);

		// faster digging when near enemy
		if(this.enemy)
		{
			// NOTE: vdist decompressed slightly here to reduce vlen2 calls!
			float digrate = 0.8;
			float mydist = vlen2(this.enemy.origin - this.origin);
			if(mydist >= 1000000) // 1000 ** 2
				digrate = 0.6;
			else if(mydist >= 250000) // 500 ** 2
				digrate = 0.4;
			else
				digrate = 0.2;
			this.idle_finished = time + digrate;
		}
		else
			this.idle_finished = time + 1;
	}
}

// always needs to be moving, so pick a target
// if there's no enemies, just chase our own tail!
void eow_hitbox_proc(entity this);
void eow_move_loop(entity this)
{
	if(!IS_MONSTER(this))
		return;

	setthink(this, eow_move_loop);
	this.nextthink = time;

	if(!this.eow_prev && time >= this.eow_lastthink)
	{
		float dt = FRAME_TIME;
		int segments = 1;
		for(entity ent = this.eow_next; ent; ent = ent.eow_next)
		{
			segments += 1;
		}
		if(segments < 10)
			dt *= 0.5; // faster if we're low!
		this.eow_lastthink = time + dt;
		eow_head_frame(this);
	}

	eow_hitbox_proc(this);
}

void eow_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	_sound(this, CH_VOICE, "eow/pain.wav", 1, ATTN_NORM);
	this.pain_finished = time + 0.2;
}

.float eow_hurttime;
void eow_hitbox_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.eow_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this || toucher.owner == this)
		return;

	toucher.eow_hurttime = time + 0.2; // no spam please

	float damage = 15;
	// must be the head!
	if(!this.eow_prev)
		damage = 20;
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_EOW.m_id);
}

void eow_spit_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.solid == SOLID_TRIGGER)
		return;
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 10, this.projectiledeathtype);
		_sound(this, CH_WEAPON_SINGLE, "zombie/z_hit.wav", 1, ATTN_NORM);
		delete(this);
		return;
	}
	_sound(this, CH_WEAPON_SINGLE, "zombie/z_miss.wav", 1, ATTN_NORM);	// bounce sound
	this.velocity = '0 0 0';
	this.avelocity = '0 0 0';
	setthink(this, SUB_Remove);
	this.nextthink = time;
	settouch(this, func_null);
}

void eow_spit(entity this, entity targ)
{
	vector org = this.origin;
	//vector dir = normalize(ai_shotlead(org, targ.origin, targ.velocity, 300) - org);
	vector dir = normalize(targ.origin - org);

	_sound(this, CH_WEAPON_SINGLE, "eow/spit.wav", 1, ATTN_NORM);

	entity newmis = spawn();
	newmis.classname = "eow_spit";
	newmis.flags = FL_PROJECTILE;
	newmis.owner = this;
	newmis.realowner = this;
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;
	newmis.projectiledeathtype = DEATH_MONSTER_EOW.m_id;
	newmis.clipgroup = this.clipgroup;

	newmis.velocity = dir * 500;
	//newmis.avelocity = '3000 1000 2000';

	settouch(newmis, eow_spit_touch);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);

	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);

	IL_PUSH(g_projectiles, newmis);

	CSQCProjectile(newmis, true, PROJECTILE_EOW_SPIT, true);
}

// called by hitboxes
void eow_hitbox_proc(entity this)
{
	entity targ = this.eow_prev;

	if(targ)
	{
		vector aimangle = aim_vec(this.origin, targ.origin);

		makevectors(aimangle);

		setorigin(this, targ.origin + v_forward * -this.maxs_z);

		//this.yaw_speed = 1;
		//this.goalentity = targ;
		eow_setangle(this, targ, 1);
	}

	// on hard, spit at nearby targets
	// tail doesn't spit!
	if(autocvar_skill >= 2 && !this.charmed && time >= this.attack_finished && this.enemy && this.eow_next)
	{
		entity targ = t_checkclient(this);
		if(targ && random() < 0.04 && vdist(this.origin - targ.origin, <=, 2000))
		{
			eow_spit(this, targ);
			this.attack_finished = time + 3 + random() * 3;
		}
		else
			this.attack_finished = time + 0.5; // only try every so often
	}

	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this && it.clipgroup != this.clipgroup,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			eow_hitbox_touch(this, it);
	});
}

entity eow_gethead(entity this)
{
	entity head = this;
	for(entity ent = this.eow_prev; ent; ent = ent.eow_prev)
	{
		head = ent;
	}
	return head;
}

entity eow_gettail(entity this)
{
	entity tail = this;
	for(entity ent = this.eow_next; ent; ent = ent.eow_next)
	{
		tail = ent;
	}
	return tail;
}

void eow_part_setup(entity this)
{
	// figure out if we're the head or the tail, or something in between
	entity head = eow_gethead(this);
	entity tail = eow_gettail(this);

	vector oldmin = this.mins;
	vector oldmax = this.maxs;

	if(tail == this)
		_setmodel(this, "progs/eow_tail.mdl");
	else if(head == this)
		_setmodel(this, "progs/eow_head.mdl");
	else
		_setmodel(this, "progs/eow_body.mdl");
	setsize(this, oldmin, oldmax);
}

void eow_splitup(entity this)
{
	if(this.eow_prev)
	{
		entity prev = this.eow_prev;
		prev.eow_next = NULL;
		// if our head doesn't have anything above it, also kill it!
		if(prev.eow_prev)
			eow_part_setup(prev);
		else
		{
			prev.health = 0;
			Killed(prev, prev, prev, DEATH_GENERIC.m_id); // call any triggers as needed
		}
	}

	if(this.eow_next)
	{
		entity next = this.eow_next;
		next.eow_prev = NULL;
		// if our tail doesn't have anything below it, also kill it!
		if(next.eow_next)
			eow_part_setup(next);
		else
		{
			next.health = 0;
			Killed(next, next, next, DEATH_GENERIC.m_id); // call any triggers as needed
		}
	}
}

void eow_death(entity this, entity inflictor, entity attacker, int deathtype)
{
	// attempt to split up at our current position
	eow_splitup(this);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED: break; // gets gibbed anyway
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	te_blood(this.origin, this.velocity, 10);
	_sound(this, CH_VOICE, "eow/death.wav", 1, ATTN_NORM);

	setthink(this, SUB_Remove);
	this.nextthink = time;
}

// spawning handled by controller

#endif // SVQC

#ifdef SVQC
METHOD(EaterPart, mr_setup, bool(EaterPart this, entity actor))
{
    TC(EaterPart, this);

	precache_model("progs/eow_body.mdl");
	precache_model("progs/eow_tail.mdl");

	precache_sound("eow/dig.wav");
	precache_sound("eow/death.wav");
	precache_sound("eow/pain.wav");
	precache_sound("eow/spit.wav");

	precache_sound("zombie/z_hit.wav");
	precache_sound("zombie/z_miss.wav");

	if(!actor.scale)
		actor.scale = 1;

	actor.health = 100;
    set_movetype(actor, MOVETYPE_NOCLIP);

    // give it a unique clipgroup to prevent intersecting with projectiles and such
    if(!actor.clipgroup)
    	actor.clipgroup = CLIPGROUP_EOW;

    //settouch(actor, eow_hitbox_touch);

    actor.th_stand = eow_move_loop;
	actor.th_walk = eow_move_loop;
	actor.th_run = eow_move_loop;
	actor.th_die = eow_death;
	actor.th_pain = eow_pain;
	//actor.th_melee = eow_stomp;
	//actor.th_missile = eow_attack;

	actor.yaw_speed = 5;

    return true;
}
#endif

#ifdef SVQC
/*QUAKED monster_eow(1 0 0)(-32 -32 -24)(32 32 48) Ambush
*/
spawnfunc(monster_eow)
{
	monster_start(this, true, MON_EOW);
}
#endif // SVQC

#ifdef SVQC
METHOD(EaterOfWorlds, mr_setup, bool(EaterOfWorlds this, entity actor))
{
	TC(EaterOfWorlds, this);

	if(actor.charmed)
		actor.scale = 0.5;

	Monster mon = MON_EOW_PART;
	entity prev = NULL;
	int segments = rint(72 * ((actor.scale) ? actor.scale : 1));
	for(int j = 0; j <= segments; ++j)
	{
		entity part = controller_create(actor, spawn(), mon);

		if(j == segments)
			_setmodel(part, "progs/eow_tail.mdl");
		else if(j == 0)
			_setmodel(part, "progs/eow_head.mdl");
		else
			_setmodel(part, "progs/eow_body.mdl");

		setsize(part, mon.m_mins * part.scale, mon.m_maxs * part.scale);
		vector org = (prev) ? prev.origin - ('0 0 1' * mon.m_maxs_z) : actor.origin;
		setorigin(part, org);

		part.eow_prev = prev;
		if(prev)
			prev.eow_next = part;
		prev = part;
	}

	return true;
}
#endif
