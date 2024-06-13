#ifdef SVQC

const int UNDERWATER = BIT(1);

void trap_gravity_touch(entity this, entity toucher)
{
	if(this.attack_finished > time)
		return;

	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this, this.dmg, DEATH_TRAP.m_id);
		this.attack_finished = time + 0.2;
	}
}

void trap_gravity_think(entity this)
{
	this.ltime = time;

	int hit_targets = 0;
	FOREACH_ENTITY_RADIUS(this.origin, this.distance, !(it.flags & FL_NOTARGET) && (it.flags & this.cnt),
	{
		if(it.health > 0 && !it.struck_by_mjolnir && visible(this, it))
		{
			vector dir = normalize(this.origin - it.origin);
			vector vel = dir * this.speed;
			if(StatusEffects_active(STATUSEFFECT_Wetsuit, it) && (this.spawnflags & UNDERWATER))
				vel = vel * 0.6;

			it.velocity = it.velocity + vel;

			hit_targets += 1;
			if(hit_targets >= this.count)
				break;
		}
	});

	this.nextthink = time + 0.1;
}

/*QUAKED trap_gravity_well (.8 .5 0) (-8 -8 -8) (8 8 8) targetenemies UNDERWATER
targets enemies in vicinity and draws them near, gibbing them on contact.

UNDERWATER cuts the pull in half for players wearing the wetsuit

"distance" how far the gravity well should reach (600 default)
"count" number of people to target (2 default)
"speed" is how strong the pull is. (210 default)
"dmg" is how much damage to do each touch. (10000 default)
*/
spawnfunc(trap_gravity_well)
{
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_NONE);
	setsize( this, '-16 -16 -16','16 16 16');
	if( this.dmg == 0 )
		this.dmg = 10000;
	if( this.speed == 0 )
		this.speed = 210;
	if(this.distance == 0)
		this.distance = 600;
	if(this.spawnflags & BIT(0))
		this.cnt = FL_CLIENT | FL_MONSTER;
	else
		this.cnt = FL_CLIENT;

	this.attack_finished = 0;
	setthink(this, trap_gravity_think);
	settouch(this, trap_gravity_touch);
	this.lastvictim = NULL;
	this.nextthink = time + 0.1;
	this.ltime = time;
}

#endif
