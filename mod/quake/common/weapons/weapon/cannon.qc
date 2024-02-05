#include "cannon.qh"

#ifdef SVQC
PRECACHE(Cannon)
{
	precache_model("progs/v_cannon.mdl");
	precache_model("progs/g_cannon.mdl");

	precache_sound("goatling/idle6.wav");
}

void cannon_PlayerTouch(entity this, entity toucher)
{
	if(!toucher || !toucher.takedamage || toucher.health < 0 || !this.cannonball || !this.cannon_prev)
		return;
	if(IS_PLAYER(toucher) && autocvar_g_friendlyfire_virtual)
		return;
	if(vdist(this.velocity, <, this.cannon_prev.speed * 0.5))
		return;

	T_Damage(toucher, this, this, this.cannon_prev.dmg, DEATH_CRUSH.m_id);
}

void cannon_PlayerPreThink(entity this)
{
	if(this.cannonball && IS_ONGROUND(this))
		this.cannonball = false;
}

bool cannon_land(entity this)
{
	if(!IS_ONGROUND(this))
		return false;
	if(this.m_champion && this.m_champion.m_cannon_land)
		return this.m_champion.m_cannon_land(this.m_champion, this);
	return false;
}

void cannon_clear(entity this)
{
	if(this.cannon_targ)
	{
		this.cannon_targ.nodrawtoclient = NULL;
		this.cannon_targ.realowner = NULL;
	}
	STAT(CANNON, this) = false;
	this.cannon_targ = NULL;
	if(!this.tank)
		this.effects &= ~EF_NODRAW;
}

void cannon_launch(entity this, entity cannon)
{
	if(this.m_champion && this.m_champion.m_cannon_launch)
		this.m_champion.m_cannon_launch(this.m_champion, this, cannon);

	makevectors(this.v_angle);
	this.velocity = v_forward * cannon.speed + '0 0 1';
	UNSET_ONGROUND(this);
	this.cannonball = true;
	cannon.attack_finished = time + 1; // brief period where the user can't re-enter
	// maybe not? too fast for monsters to see you coming!
	//this.show_hostile = time + 1;

	soundat(NULL, cannon.origin, CH_TRIGGER, SND(ROCKET_EXPLOSION), 1, ATTEN_NORM);
	Send_Effect(EFFECT_EXPLOSION, cannon.origin + v_forward * 64 + v_up * 24, '0 0 0', 1);

	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		ATTACK_FINISHED(this, weaponentity) = time + 1.1;
	}

	cannon_clear(this);

	// NOTE: must be done last as it reactivates triggers!
	// TODO: wouldn't be necessary if we weren't using SOLID_TRIGGER...
	setorigin(this, cannon.origin + '0 0 16');

	//delete(cannon);
}

void cannon_enter(entity this, entity cannon)
{
	cannon.realowner = this;
	STAT(CANNON, this) = true;
	this.cannon_targ = cannon;
	this.cannon_prev = cannon;
	this.effects |= EF_NODRAW;
	cannon.nodrawtoclient = this;
	this.angles = this.v_angle = cannon.angles;
	this.fixangle = true;
	setorigin(this, cannon.origin + '0 0 8');
	UNSET_ONGROUND(this);
	this.velocity = '0 0 0';
}

void cannon_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) || toucher.health < 0 || STAT(CANNON, toucher))
		return;
	if((toucher.cannonball || time < this.attack_finished) && toucher.cannon_prev == this)
		return;
	if(toucher == this.cannon_targ && time < this.attack_finished)
		return;
	if(this.realowner)
		return;
	if(toucher != this.cannon_targ && !coop)
		return;
	//if(toucher.move_movetype != MOVETYPE_WALK)
		//return;
	if(STAT(SLIDE_ON, toucher) || STAT(SKATING, toucher) || toucher.tank)
		return;

	sound(this, CH_TRIGGER_SINGLE, SND_CANNON_ENTER, 1, ATTN_NORM);
	cannon_enter(toucher, this);
}

void cannon_think(entity this)
{
	setthink(this, cannon_think);
	this.nextthink = time;
	entity player = this.realowner;
	if(player.cannon_targ == this)
	{
		vector vang = player.v_angle;
		if(!player.fixangle)
			this.angles = '0 1 0' * vang.y;
		if(this.wait)
			this.wait += serverframetime;
		.entity weaponentity = weaponentities[0];
		if(PHYS_INPUT_BUTTON_ATCK(player) && time > ATTACK_FINISHED(player, weaponentity))
			cannon_launch(player, this);
		return;
	}
	else
		this.angles = this.pos2;

	if(this.wait && time > this.wait)
	{
		Send_Effect(EFFECT_EXPLOSION, this.origin + '0 0 16', '0 0 0', 1);
		delete(this);
		return;
	}
}

void cannon_setup(entity this)
{
	//set_movetype(this, MOVETYPE_NONE);
	this.cannon_targ = this.owner; // backup so we can safely clear realowner
	this.owner = NULL; // to allow collisions
	setthink(this, cannon_think);
	this.nextthink = time + 0.1;
	this.solid = SOLID_TRIGGER;
	settouch(this, cannon_touch);
	setsize(this, '-32 -32 -16', '32 32 32');
}

spawnfunc(cannon)
{
	if(!this.speed)
		this.speed = 2000;
	if(!this.dmg)
		this.dmg = 2000;
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);
	setmodel(this, MDL_CANNON);
	setsize(this, '-32 -32 -16', '32 32 32');
	this.pos2 = this.angles;
	if(!this.noalign)
		droptofloor(this);
	cannon_setup(this);
}

void cannon_projectile_touch(entity this, entity toucher)
{
	if(toucher && toucher.solid != SOLID_BSP)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	// TODO: bumping sound?
}

void cannon_projectile_think(entity this)
{
	this.nextthink = time;
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	if(!IS_ONGROUND(this))
		return;

	sound(this, CH_WEAPON_B, SND_CANNON_LAND, 1, ATTN_NORM);
	cannon_setup(this);
	this.attack_finished = time + 0.5;
	this.dmg = 2000;
	this.speed = 2000;
	this.wait = time + 20;
}

void W_DropCannon(entity this, .entity weaponentity)
{
	if(!StatusEffects_active(STATUSEFFECT_SharpShooter, this))
	{
		STAT(WEAPONS, this) &= ~WEP_CANNON.m_wepset;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
	}

	sound(this, CH_WEAPON_B, SND_CANNON_DROP, 1, ATTN_NORM);

	entity cannon = new(cannon_projectile);
	cannon.owner = this;
	set_movetype(cannon, MOVETYPE_TOSS);
	cannon.solid = SOLID_BBOX;
	setmodel(cannon, MDL_CANNON);
	setsize(cannon, '-8 -8 -16', '8 8 8');
	settouch(cannon, cannon_projectile_touch);
	setthink(cannon, cannon_projectile_think);
	cannon.wait = time + 3;
	cannon.nextthink = time;

	vector org = this.origin + (this.view_ofs * 0.75);
	setorigin(cannon, org);
	cannon.angles = this.angles;
	cannon.pos2 = cannon.angles;
	makevectors(this.angles);
	cannon.velocity = v_forward * 200 + v_up * 20;
}

METHOD(Cannon, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_DropCannon(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.5);
	}
}
METHOD(Cannon, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // no ammo
}
METHOD(Cannon, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
