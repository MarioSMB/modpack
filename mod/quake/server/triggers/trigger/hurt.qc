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

void hurt_touch(entity this, entity toucher)
{
	if(toucher.takedamage)
	{
		this.solid = SOLID_NOT;
		T_Damage(toucher, this, this, this.dmg);
		setthink(this, hurt_on);
		this.nextthink = time + 1;

		//MED 12/01/96 added count stuff
		if(MP_HIPNOTIC && this.cnt > 0)
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

	return;
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

	if(MP_HIPNOTIC && !this.cnt)
		this.cnt = -1;
}

#endif
