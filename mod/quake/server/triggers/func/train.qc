#ifdef SVQC

void train_next(entity this);
void func_train_find(entity this);

void train_blocked(entity this, entity blocker)
{
	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 0.5;
	T_Damage(blocker, this, this, this.dmg);
}
void train_use(entity this, entity actor, entity trigger)
{
	if(getthink(this) != func_train_find)
		return;		// already activated
	train_next(this);
}

void train_wait(entity this)
{
	if(this.wait)
	{
		this.nextthink = this.ltime + this.wait;
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	}
	else
		this.nextthink = this.ltime + 0.1;
	
	setthink(this, train_next);
}

void train_next(entity this)
{
	entity	targ;

	targ = find(NULL, targetname, this.target);
	this.target = targ.target;
	if(!this.target || this.target == "")
		objerror(this, "train_next: no next target");
	if(targ.wait)
		this.wait = targ.wait;
	else
		this.wait = 0;
	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);
	SUB_CalcMove(this, targ.origin - this.mins, this.speed, train_wait);
}

void func_train_find(entity this)
{
	entity	targ;

	targ = find(NULL, targetname, this.target);
	this.target = targ.target;
	setorigin(this, targ.origin - this.mins);
	if(!this.targetname || this.targetname == "")
	{	// not triggered, so start immediately
		this.nextthink = this.ltime + 0.1;
		setthink(this, train_next);
	}
}

/*QUAKED func_train(0 .5 .8) ?
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
spawnfunc(func_train)
{	
	if(!this.speed)
		this.speed = 100;
	if(!this.target || this.target == "")
		objerror(this, "func_train without a target");
	if(!this.dmg)
		this.dmg = 2;

	if (!InitMovingBrushTrigger(this))
		return;
	this.effects |= EF_LOWPRECISION;

	if(this.sounds == 0)
	{
		this.noise =("misc/null.wav");
		precache_sound("misc/null.wav");
		this.noise1 =("misc/null.wav");
		precache_sound("misc/null.wav");
	}

	if(this.sounds == 1)
	{
		this.noise =("plats/train2.wav");
		precache_sound("plats/train2.wav");
		this.noise1 =("plats/train1.wav");
		precache_sound("plats/train1.wav");
	}

	this.cnt = 1;
	setblocked(this, train_blocked);
	this.use = train_use;
	this.classname = "train";

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	this.nextthink = this.ltime + 0.1;
	setthink(this, func_train_find);
}

/*QUAKED misc_teleporttrain(0 .5 .8)(-8 -8 -8)(8 8 8)
This is used for the final bos
*/
spawnfunc(misc_teleporttrain)
{	
	if(!this.speed)
		this.speed = 100;
	if(!this.target || this.target == "")
		objerror(this, "func_train without a target");

	this.cnt = 1;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_PUSH);
	setblocked(this, train_blocked);
	this.use = train_use;
	this.avelocity = '100 200 300';

	this.noise =("misc/null.wav");
	precache_sound("misc/null.wav");
	this.noise1 =("misc/null.wav");
	precache_sound("misc/null.wav");

	precache_model2("progs/teleport.mdl");
	_setmodel(this, "progs/teleport.mdl");
	setsize(this, this.mins , this.maxs);
	setorigin(this, this.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	this.nextthink = this.ltime + 0.1;
	setthink(this, func_train_find);
}

#endif
