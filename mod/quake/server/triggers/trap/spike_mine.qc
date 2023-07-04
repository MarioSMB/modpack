#ifdef SVQC

void spikemine_Home(entity this)
{
	this.frame = this.frame + 1;
	if(this.frame == 9) this.frame = 0;
	this.nextthink = time + 0.2;
	setthink(this, spikemine_Home);

// look in our immediate vicinity

	if(this.search_time < time)
	{
		entity selected = NULL;
		float cur_dist = 2000;
		entity head = findradius(this.origin, 2000);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && IS_CLIENT(head))
			{
				if(visible(this, head) && (head.health > 0))
				{
					float head_dist = vlen(head.origin-this.origin);
					if(head_dist < cur_dist)
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}
//      if(selected != NULL && selected != this.enemy)
		if(selected != NULL)
			_sound(this, CH_TRIGGER_SINGLE, "hipitems/spikmine.wav", 1, ATTN_NORM);
		this.enemy = selected;
		this.search_time = time + 1.3;
	}
	if(this.enemy == NULL)
	{
		sound(this, CH_TRIGGER_SINGLE, SND_Null, 1, ATTN_NORM);
		this.velocity = '0 0 0';
		return;
	}
	vector vtemp = this.enemy.origin + '0 0 10';
	vector dir = normalize(vtemp - this.origin);
	if(infront(this, this.enemy))
		this.velocity = dir * ((autocvar_skill*50) + 50);
	else
		this.velocity = dir * ((autocvar_skill*50) + 150);
}

void spikemine_Touch(entity this, entity toucher)
{
	if(this.health > 0)
	{
		if(toucher.classname == "trap_spike_mine")
			return;
		if(toucher.classname == "missile" || toucher.classname == "vore_ball")
			return;
		if(toucher.classname == "grenade" || toucher.classname == "ogre_grenade")
			return;
		if(toucher.classname == "hiplaser")
			return;
		if(toucher.classname == "proximity_grenade")
			return;

		T_Damage(this, this, this, this.health + 10, DEATH_TRAP.m_id);
	}
//   this.effects = this.effects | EF_MUZZLEFLASH;

	T_RadiusDamage(this, this, 110, DEATH_TRAP.m_id, NULL);
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	sound(this, CH_TRIGGER_SINGLE, SND_Null, 1, ATTN_NORM);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	setmodel(this, MDL_EXPLOSION);
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	s_explode1(this);
}

void spikemine_explode(entity this)
{
	spikemine_Touch(this, this.enemy);
}

void spikemine_Die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.takedamage = DAMAGE_NO;
	this.enemy = attacker;
	setthink(this, spikemine_explode);
	this.nextthink = time;
}

/*
spike_mine_first_think
*/

void spike_mine_first_think(entity this)
{
	setthink(this, spikemine_Home);
	this.nextthink = time + 0.1;
	this.search_time = 0;
	this.takedamage = DAMAGE_AIM;
	this.use = monster_use;
}

/*QUAKED trap_spike_mine (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(trap_spike_mine)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	if(deathmatch) { delete(this); return; }

	precache_model ("progs/spikmine.mdl");
	precache_sound("hipitems/spikmine.wav");
	_setmodel(this, "progs/spikmine.mdl");
//   _setmodel(this, "progs/spike.mdl");
	setsize(this, this.mins, this.maxs);
	this.classname = "trap_spike_mine";
	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_FLYMISSILE);
//   setsize(this, '0 0 0', '0 0 0');
//   this.avelocity = '-100 100 -100';
	this.avelocity = '-50 100 150';
	if(autocvar_skill <= 1)
		this.health = 200;
	else
		this.health = 400;
	this.frame = 0;
	setthink(this, spike_mine_first_think);
	settouch(this, spikemine_Touch);
	this.th_die = spikemine_Die;
	this.th_stand = spikemine_Home;
	this.th_walk = spikemine_Home;
	this.th_run = spikemine_Home;
	this.th_melee = spikemine_Home;
	this.th_missile = spikemine_Home;
	this.nextthink = time + 0.2;
	monsters_total += 1;
	this.flags |= FL_MONSTER; // TODO

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;
}

#endif
