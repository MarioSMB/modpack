#ifdef SVQC

bool claw_hasowner(entity this)
{
#if 0
	FOREACH_ENTITY_CLASS("misc_pinhead", this.owner == it,
	{
		return true;
	});
#else
	entity pinhead = find(NULL, classname, "misc_pinhead");
	while(pinhead)
	{
		if(this.owner == pinhead)
			return true;
		pinhead = find(pinhead, classname, "misc_pinhead");
	}
#endif
	return false;
}

void killclaw(entity this)
{
	if(claw_hasowner(this))
		this.owner.flags = 0;
	delete(this);
}

void claw_close(entity this)
{
	if(this.frame < 5)
		this.frame = this.frame + 1;
	if(this.count < time)
	{
		killclaw(this);
		return;
	}
	this.nextthink = time + 0.03;
}

void claw_retract(entity this)
{
	_sound(this, CHAN_BODY, "enviro/pinhead/pinback.wav", 1, ATTN_NORM);
	this.velocity = normalize(this.owner.origin - this.origin) * 500;
	this.solid = SOLID_NOT;
	this.count = time + (time - this.ltime);
	setthink(this, claw_close);
	this.nextthink = time;
	this.frame = 1;
}

vector pullorg(entity e)
{
	vector org = e.origin;
	int counter2 = 1; // avoid division by 0
	FOREACH_ENTITY_CLASS("claw", it.enemy == e,
	{
		org = org + it.owner.origin;
		counter2 += 1;
	});
	org = org * (1 / counter2);
	org.x = org.x + (crandom() * 10);
	org.y = org.y + (crandom() * 10);
	org.z = org.z + (crandom() * 10);
	return org;
}

void claw_pull(entity this)
{
	_sound(this, CHAN_VOICE, "enviro/pinhead/pinpull.wav", 1, ATTN_NORM);
	setorigin(this, this.enemy.origin + this.mangle);
	if(this.frame < 5)
		this.frame = this.frame + 1;
	this.nextthink = time + (random() / 2);
	vector org = pullorg(this.enemy);
	if(IS_ONGROUND(this.enemy))
	{
		UNSET_ONGROUND(this.enemy);
		setorigin(this.enemy, this.enemy.origin + '0 0 1');
	}
	this.velocity = normalize(org - this.origin);
	if(vdist(org - this.origin, >, 20))
		this.velocity = this.velocity * 500;
	else
		this.velocity = this.velocity * 50;
	this.enemy.velocity = this.velocity;
	if(!claw_hasowner(this))
	{
		killclaw(this);
		return;
	}
	else if(this.enemy.health <= 0)
	{
		killclaw(this);
		return;
	}
	else if(this.enemy.health < 5)
	{
		_sound(this, CHAN_VOICE, "enviro/pinhead/pinsuck.wav", 1, ATTN_NORM);
		T_Damage(this.enemy, this, this.owner, 10000, DEATH_TRAP.m_id);
	}
	else if(random() < 0.1)
	{
		if(random() < 0.5)
			_sound(this, CH_WEAPON_SINGLE, "enviro/pinhead/pinrip.wav", 0.5, ATTN_NORM);
		if(this.owner.dmg > 0)
			T_Damage(this.enemy, this, this.owner, this.owner.dmg, DEATH_TRAP.m_id);
	}
}

void claw_touch(entity this, entity toucher)
{
	if(toucher.solid == SOLID_TRIGGER)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		claw_retract(this);
		return;
	}
	if(toucher.takedamage)
	{
		this.enemy = toucher;
		setorigin(this, this.origin + normalize(this.velocity) * 30);
		this.mangle = (this.origin - this.enemy.origin);
		this.mangle_x = (this.mangle_x * 0.05);
		this.mangle_y = (this.mangle_y * 0.05);
		this.mangle_z = ((this.mangle_z * 0.1) + 10);
		setthink(this, claw_pull);
		this.nextthink = time;
		_sound(this, CHAN_AUTO, "enviro/pinhead/pinhit.wav", 1, ATTN_NORM);
	}
	else
	{
		te_gunshot(this.origin);
		_sound(this, CHAN_ITEM, "enviro/pinhead/pindef.wav", 1, ATTN_NORM);
		claw_retract(this);
	}
}

void fire_claw(entity this, vector org, vector dir)
{
	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	_setmodel(newmis, "progs/claw.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	settouch(newmis, claw_touch);
	newmis.classname = "claw";
	newmis.enemy = NULL;
	setthink(newmis, claw_retract);
	newmis.nextthink = (time + (this.ltime / 10));
	newmis.ltime = time;
	this.flags = 1;
	this.enemy = newmis;
	_sound(this, CHAN_VOICE, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
}

void pinhead_use(entity this, entity actor, entity trigger)
{
	if(this.flags)
		return;
	this.enemy = NULL;
	vector dir = '0 0 0';
	float dist = (this.ltime * 100) + 100;
	if(this.goalentity)
	{
		traceline(this.origin, (this.goalentity.origin + '0 0 16'), true, this);
		if(trace_fraction >= 1 && vdist((this.goalentity.origin + '0 0 16') - this.origin, <, dist))
			this.enemy = this.goalentity;
		else
			this.enemy = NULL;
	}
	else
	{
		entity head = findradius(this.origin, dist);
		while(head)
		{
			if((IS_CLIENT(head) || IS_MONSTER(head)) && head.takedamage && vdist((head.origin + '0 0 16') - this.origin, <, dist))
			{
				traceline(this.origin, (head.origin + '0 0 16'), true, this);
				if(trace_fraction >= 1)
				{
					this.enemy = head;
					dist = vlen((head.origin + '0 0 16') - this.origin);
					dir = normalize((this.enemy.origin + '0 0 16') - this.origin);
				}
			}
			head = head.chain;
		}
	}
	if(this.enemy)
		fire_claw(this, this.origin, dir);
}

void pinhead_think(entity this)
{
	this.nextthink = time + 1;
	this.use(this, NULL, NULL);
}

spawnfunc(misc_pinhead_triggered)
{
	if(!MP_IMPEL) { delete(this); return; }

	this.classname = "misc_pinhead";
	precache_model2("progs/claw.mdl");
	precache_sound2("enviro/pinhead/pinback.wav");
	precache_sound2("enviro/pinhead/pindef.wav");
	precache_sound2("enviro/pinhead/pinfire.wav");
	precache_sound2("enviro/pinhead/pinhit.wav");
	precache_sound2("enviro/pinhead/pinpull.wav");
	precache_sound2("enviro/pinhead/pinrip.wav");
	precache_sound2("enviro/pinhead/pinsuck.wav");
	this.use = pinhead_use;
	if(this.ltime == 0)
		this.ltime = 2;
	if(this.dmg == 0)
		this.dmg = 3;
}

spawnfunc(misc_pinhead)
{
	if(!MP_IMPEL) { delete(this); return; }

	spawnfunc_misc_pinhead_triggered(this);
	this.nextthink = random();
	setthink(this, pinhead_think);
}

#endif
