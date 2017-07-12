// timemach.qc
// pmack
// jan97

// ------------------------------------------------
// time machine and related parts
// ------------------------------------------------
void time_chunk(entity this)
{
	entity timeChunk = spawn();
	_setmodel(timeChunk, "progs/timegib.mdl");
	timeChunk.solid = SOLID_NOT;
	set_movetype(timeChunk, MOVETYPE_TOSS);
	makevectors(this.owner.angles);
	setorigin(timeChunk, this.owner.origin + v_forward*84 - v_up * 136);
	timeChunk.velocity = v_up * -50;
	timeChunk.avelocity = '300 300 300';
	timeChunk.angles = this.owner.angles;
	
	_sound(this, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NONE);
	te_explosion(timeChunk.origin);

	this.owner.frame = 1;

	setthink(timeChunk, SUB_Remove);
	timeChunk.nextthink = time + 5;
}

void time_stop_shake(entity this)
{
	SUB_UseTargets(this, NULL, NULL);
	delete(this);
}

void time_boom(entity this)
{
	SUB_UseTargets(this, NULL, NULL);

	if(this.owner.health < 1250 && this.owner.frame > 0)
	{
		if(this.owner.skin < 2)
		{
			this.owner.frame = 2;
			this.owner.skin = 2;
		}
	}
	else if(this.owner.health < 1500)
	{
		if(this.owner.frame == 0)
		{
			time_chunk(this);
			this.owner.frame = 1;
			this.owner.skin = 1;
		}
	}
		
	_sound(this, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NONE);

	if(random() < 0.5)
		te_explosion(this.origin);
	else
		te_explosion2(this.origin, 244, 3);
	
	BecomeExplosion(this);
	entity stopShakeEnt = spawn();
	stopShakeEnt.target = this.target;
	setthink(stopShakeEnt, time_stop_shake);
	stopShakeEnt.nextthink = time + 0.7;
}

void time_fall(entity this)
{
	if(!this.pain_finished)
	{
		if(this.origin_z < -20)
		{
			te_lavasplash(this.origin - vec3(0, 0, 80));
			this.pain_finished = 1;
		}
		else if(random() < 0.3)
			te_explosion(this.origin);
	}
	
	this.velocity_z = this.velocity_z - 5;
	this.nextthink = time + 0.1;
	setthink(this, time_fall);
}

void time_crash(entity this)
{
	this.takedamage = DAMAGE_NO;
	set_movetype(this, MOVETYPE_FLY);
	this.solid = SOLID_NOT;
	this.velocity = '0 0 -50';
	this.avelocity = '15 0 5';
	setsize(this, '0 0 0', '0 0 0');
	setthink(this, time_fall);
	this.nextthink = time + 0.1;

	this.target = "timeramp";
	SUB_UseTargets(this, NULL, NULL);
}

void time_crash_die(entity this, entity attacker)
{
	time_crash(this);
}
void time_crash_pain(entity this, entity attacker, float damage)
{
	time_crash(this);
}

void time_pain(entity this, entity attacker, float take)
{
	if(this.health > 1100 && this.pain_finished > time)
		return;

	float painRnd = random();
	if(painRnd < 0.4)
	{
		this.pain_finished = time + 2;
		painRnd = random();
		makevectors(this.angles);
		entity painEnt = spawn();
		if ( painRnd < 0.33 )
			painEnt.origin = this.origin + v_forward*80 - v_up*64;
		else if (painRnd < 0.66)
			painEnt.origin = this.origin + v_right*80 - v_up*24;
		else 
			painEnt.origin = this.origin + v_forward*64 - v_up*48 - v_right*48;
		painEnt.target = this.target;
		painEnt.owner = this;
		setthink(painEnt, time_boom);
		painEnt.nextthink = time + 0.2 + random() * 0.3;
	}
	if(this.health < 1000)
	{
		this.pain_finished = 0;
		this.th_pain = func_null;
		this.th_die = func_null;
		cutscene_running = true;
		return;
	}
}

void time_die(entity this, entity attacker)
{
	time_pain(this, attacker, 0);
}

//(-16 -16 -32) (16 16 0)
/*QUAKED item_time_machine (1 1 0) (-64 -64 -144) (64 64 0)
*/
spawnfunc(item_time_machine)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(deathmatch) { delete(this); return; }

	precache_model("progs/timemach.mdl");
	precache_model("progs/timegib.mdl");
	_setmodel(this, "progs/timemach.mdl");
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.health = 1600;
	this.takedamage = DAMAGE_YES;
	this.view_ofs = '0 0 25';
	set_movetype(this, MOVETYPE_FLY); 
	setsize(this, '-64 -64 -144', '64 64 0');
	this.avelocity = '0 60 0';
	//this.flags |= FL_MONSTER; // why in the hell

	this.th_stand = func_null;
	this.th_walk = func_null;
	this.th_run = func_null;
	this.th_die = time_die;
	this.th_missile = func_null;
	this.th_pain = time_pain;
	
	theMachine = this;
}

/*QUAKED item_time_core (1 0 0) (-8 -8 -8) (8 8 8)
*/
spawnfunc(item_time_core)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(deathmatch) { delete(this); return; }

	precache_model ("progs/timecore.mdl");
	_setmodel(this, "progs/timecore.mdl");
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_FLY); 
	this.avelocity = '60 60 60';
}