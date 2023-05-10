#ifdef SVQC

void hurt_setdamage(entity ent, float amount)
{
	ent.dmg = amount;
	if ( !amount )
		ent.solid = SOLID_NOT;
	else
		ent.solid = SOLID_TRIGGER;

   ent.nextthink = -1;
}

void hurt_on(entity this)
{
	this.solid = SOLID_TRIGGER;
	this.nextthink = -1;
}

void hurt_use(entity this, entity actor, entity trigger)
{
	this.state = 1 - this.state;
}

void hurt_touch(entity this, entity toucher)
{
	if(MP_MG && this.state)
		return;
	if(toucher.takedamage)
	{
		// Yoder Sept24 2021 Horde merge
		// allows for monster-only hurt volumes
		if(MP_MG && (this.spawnflags & MONSTER_ONLY) && !IS_MONSTER(toucher))
			return;
		this.solid = SOLID_NOT;
		T_Damage(toucher, this, this, this.dmg, DEATH_VOID.m_id);
		setthink(this, hurt_on);
		if(MP_MG)
			this.nextthink = time + this.wait;
		else
			this.nextthink = time + 1;

		//MED 12/01/96 added count stuff
		if(this.cnt > 0)
		{
			this.cnt = this.cnt - 1;
			if(this.cnt == 0)
			{
				settouch(this, func_null);
				this.nextthink = time + 0.1;
				setthink(this, SUB_Remove);
			}
		}
	}
}

/*QUAKED trigger_hurt(.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
"cnt" default infinite, how many times to trigger
*/
spawnfunc(trigger_hurt)
{
	InitTrigger(this);
	settouch(this, hurt_touch);
	if(!this.dmg)
		this.dmg = 5;
	if(MP_MG)
	{
		if(!this.wait)
			this.wait = 1;
		if(this.spawnflags & START_OFF)
			this.state = 1;
		this.use = hurt_use;
	}

	if(!this.message || this.message == "")
		this.message = "was in the wrong place";

	if(!this.cnt)
		this.cnt = -1;
}

#endif
