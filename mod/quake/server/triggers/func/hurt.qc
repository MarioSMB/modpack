#ifdef SVQC

const int FUNC_HURT_START_ON = BIT(0);

void func_hurt_touch(entity this, entity toucher)
{
	if(!this.state) return;
	if(toucher.health <= 0) return;
	if(!toucher.takedamage) return;
	if(!IS_MONSTER(toucher) && !IS_PLAYER(toucher)) return;
	if(this.attack_finished > time) return;
	
	T_Damage(toucher, this, NULL, this.dmg, DEATH_VOID.m_id);
	this.attack_finished = time + this.wait;
}

void func_hurt_use(entity this, entity actor, entity trigger)
{
	this.state = 1 - this.state;
	this.attack_finished = 0;
}

/*QUAKED func_hurt (0 .5 .8) ?
Hurts alive things when they touch it
*/
spawnfunc(func_hurt)
{
	if(!MP_MG) { delete(this); return; }
	_setmodel(this, this.model);
	setorigin(this, this.origin);
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	settouch(this, func_hurt_touch);
	this.use = func_hurt_use;

	if(!this.dmg) this.dmg = 10;
	if(!this.wait) this.wait = 0.2;

	if(this.spawnflags & FUNC_HURT_START_ON)
		this.state = 1;
}

#endif
