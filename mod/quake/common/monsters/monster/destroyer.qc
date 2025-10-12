#include "destroyer.qh"

#ifdef SVQC
const float ATTN_DESTROYER = 0.2;

const int CLIPGROUP_DESTROYER = 20; // randomly picked!

.entity des_next;
.entity des_prev;

.float idle_finished;

/*================
	MOVEMENT
==================*/
void des_setangle(entity this)
{
	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(this.goalentity);
	vector ideal = vectoangles(normalize(targorg - myorg));
	if(this.angles == ideal)
		return;

	float angspeed = this.yaw_speed;
	ideal -= this.angles;

	this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

void des_movetogoal(entity this, float movespeed)
{
	des_setangle(this);

	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	this.velocity = v_forward * movespeed + v_up * (sin(time) * movespeed);
}


// always needs to be moving, so pick a target
// if there's no enemies, just chase our own tail!
void des_move_loop(entity this)
{
	if(!IS_MONSTER(this))
		return;

	setthink(this, des_move_loop);
	this.nextthink = time + FRAME_TIME;

	// go for another player if multi player
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

	if(this.enemy)
		this.goalentity = this.enemy;
	else if(this.charmer)
		this.goalentity = this.charmer;
	else if(!boxesoverlap(this.absmin, this.absmax, world.mins, world.maxs))
		this.goalentity = world; // try to move towards the world origin?
	else
		this.goalentity = this.des_prev; // TODO: make sure it doesn't just fly out of the world!

	float movespeed = (this.enemy) ? 400 : 300; // TODO: speed up near enemy
	des_movetogoal(this, movespeed);

	if(time > this.idle_finished)
	{
		_sound(this, CH_SHOTS, "destroyer/dig.wav", 1, ATTN_DESTROYER);

		// faster digging when near enemy
		if(this.enemy)
		{
			// NOTE: vdist decompressed slightly here to reduce vlen2 calls!
			// TODO: also decode the powers of 2?
			float digrate = 0.8;
			float mydist = vlen2(this.enemy.origin - this.origin);
			if(mydist >= (1000 ** 2))
				digrate = 0.5;
			else if(mydist >= (500 ** 2))
				digrate = 0.2;
			else
				digrate = 0.1;
			this.idle_finished = time + digrate;
		}
		else
			this.idle_finished = time + 1;
	}
}

void des_pain(entity this, entity attacker, float damage, int deathtype)
{
	spamsound(this, CH_VOICE, SND_MECHBOSS_HIT, 1, ATTN_NORM);

	// only body parts can have drones!
	if(this.classname != "monster_hitbox" || !this.des_next)
		return;

	if(this.skin == 1 || this.realowner.charmed)
		return;

	// low chance and need to be within pvs (not out of the world!)
	if(random() < 0.1 && checkpvs(this.origin, attacker))
	{
		this.skin = 1;
		minion_spawn(this.realowner, this.origin, new(monster), MON_JIM);
	}
}

.float destroyer_hurttime;
void des_hitbox_touch(entity this, entity toucher)
{
	entity own = (this.classname == "monster_hitbox") ? this.realowner : this;

	// special exception: never hurt jim!
	// TODO: just exclude all monsters if we're not charmed?
	if(toucher.monsterdef == MON_JIM)
		return;
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.destroyer_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, own))
		return;
	
	if(toucher == own || toucher.owner == own)
		return;

	toucher.destroyer_hurttime = time + 0.2; // no spam please

	float damage = 30;
	// must be the head!
	if(this.classname != "monster_hitbox")
		damage = 120;
	
	T_Damage(toucher, this, own, damage, DEATH_MONSTER_DESTROYER.m_id);
}

// called by hitboxes
void des_hitbox_proc(entity this)
{
	if(this.realowner.health < 1 || !this.realowner || wasfreed(this.realowner))
	{
		delete(this);
		return;
	}

	setthink(this, des_hitbox_proc);
	this.nextthink = time;

	// on hard, the probes shoot when still attached
	if(autocvar_skill >= 2 && this.skin != 1 && !this.realowner.charmed && time >= this.attack_finished && this.realowner.enemy)
	{
		entity targ = t_checkclient(this);
		if(targ && random() < 0.04 && vdist(this.origin - targ.origin, <=, 2000))
		{
			entity newmis = LaunchLaser(this.realowner, this.origin, targ.origin - this.origin);
			newmis.projectiledeathtype = DEATH_MONSTER_DESTROYER.m_id;
			_sound(this, CH_WEAPON_SINGLE, "destroyer/laser_fire.wav", 1, ATTN_NORM);
			this.attack_finished = time + 1 + random() * 3;
		}
		else
			this.attack_finished = time + 0.1; // only try every so often
	}

	entity targ = this.des_prev;

	vector aimangle = aim_vec(this.origin, targ.origin);

	makevectors(aimangle);

	setorigin(this, targ.origin + v_forward * -this.maxs_z);

	this.yaw_speed = 2;
	this.goalentity = targ;
	des_setangle(this);

	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			des_hitbox_touch(this, it);
	});
}

entity des_spawn_part(entity this, entity prev, string partmdl)
{
	Monster mon = this.monsterdef;

	// body
	entity ent = spawn();
	ent.classname = "monster_hitbox";
	ent.owner = this;
	ent.realowner = this;
	ent.des_prev = prev;
	ent.clipgroup = this.clipgroup;
	ent.takedamage = DAMAGE_AIM;
	ent.solid = SOLID_BBOX;
	ent.scale = this.scale;
	//ent.effects = EF_NODEPTHTEST;
	ent.th_pain = des_pain;
	ent.colormod = this.colormod;
	_setmodel(ent, partmdl);
	setsize(ent, mon.m_mins * ent.scale, mon.m_maxs * ent.scale);
	ent.angles = this.angles;
	setorigin(ent, prev.origin - ('0 0 1' * mon.m_maxs_z));
	//settouch(ent, des_hitbox_touch);
	setthink(ent, des_hitbox_proc);
	ent.nextthink = time;

	prev.des_next = ent;

	return ent;
}

void des_spawn_body(entity this)
{
	entity ent = this;

	int segments = rint(80 * ((this.scale) ? this.scale : 1));
	for(int j = 0; j <= segments; ++j)
	{
		ent = des_spawn_part(this, ent, "progs/destroyer_body.mdl");
		//ent = des_spawn_part(this, ent, "progs/h_shams.mdl");
	}

	ent = des_spawn_part(this, ent, "progs/destroyer_tail.mdl");
	//ent = des_spawn_part(this, ent, "progs/h_shams.mdl");
	ent.des_next = NULL;

	// mark our prev as the tail to get easy access to it
	this.des_prev = ent;

	//this.effects |= EF_NODEPTHTEST;

	setthink(this, des_move_loop);
	this.nextthink = time + 0.1;
}

void des_part_explode(entity this)
{
	te_explosion(this.origin);
	_sound(this, CH_VOICE, "destroyer/explode.wav", 1, ATTN_DESTROYER);
	delete(this);
}

void des_death(entity this, entity inflictor, entity attacker, int deathtype)
{
	int segments = 1;
	for(entity ent = this.des_next; ent; ent = ent.des_next)
	{
		ent.velocity = '0 0 0';
		setthink(ent, des_part_explode);
		ent.nextthink = time + (0.1 * segments);
		settouch(ent, func_null);
		ent.takedamage = DAMAGE_NO;
		ent.solid = SOLID_NOT;
		ent.skin = 1;
		segments += 1;
	}
	des_part_explode(this);
}

/*QUAKED monster_destroyer(1 0 0)(-32 -32 -24)(32 32 48) Ambush
*/
spawnfunc(monster_destroyer) { monster_start(this, true, MON_DESTROYER); }

#endif // SVQC

#ifdef SVQC
METHOD(Destroyer, mr_setup, bool(Destroyer this, entity actor))
{
    TC(Destroyer, this);

	precache_model("progs/destroyer_body.mdl");
	precache_model("progs/destroyer_tail.mdl");

	precache_model("progs/laser.mdl");
	
	precache_sound("destroyer/dig.wav");
	precache_sound("destroyer/hit.wav");
	precache_sound("destroyer/explode.wav");
	precache_sound("destroyer/laser_fire.wav");

	if(actor.charmed)
		actor.scale = 0.5;

	if(!actor.scale)
		actor.scale = 1;

    actor.health = 20000;
    set_movetype(actor, MOVETYPE_NOCLIP);

    // give it a unique clipgroup to prevent intersecting with projectiles and such
    if(!actor.clipgroup)
    	actor.clipgroup = CLIPGROUP_DESTROYER;

    //settouch(actor, des_hitbox_touch);

    actor.th_stand = des_move_loop;
	actor.th_walk = des_move_loop;
	actor.th_run = des_move_loop;
	actor.th_die = des_death;
	actor.th_pain = des_pain;
	//actor.th_melee = des_stomp;
	//actor.th_missile = des_attack;

	actor.yaw_speed = 5;

	// need to delay by a frame to ensure we have a position
	des_spawn_body(actor);

    return true;
}
#endif
