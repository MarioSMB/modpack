#include "bean.qh"

#ifdef SVQC
void teddy_think(entity this)
{
	setthink(this, teddy_think);
	this.nextthink = time + 0.1;

	if(time >= this.wait)
	{
		delete(this);
		return;
	}
}

void teddy_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	spawn_touchblood(this, 30, inflictor);
	delete(this);
}

void teddy_setup(entity this)
{
	//set_movetype(this, MOVETYPE_NONE);
	setthink(this, teddy_think);
	this.nextthink = time + 0.1;
	this.solid = SOLID_TRIGGER;
	this.health = 30;
	this.takedamage = DAMAGE_AIM;
	this.angles = this.pos2;
	this.monster_attack = true;
	this.th_die = teddy_die;
}

void teddy_projectile_think(entity this)
{
	this.nextthink = time;
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	if(!IS_ONGROUND(this))
		return;

	teddy_setup(this);
	this.wait = time + 10;
}

void ThrowTeddy(entity this)
{
	entity teddy = new(teddy);
	teddy.realowner = this;
	teddy.dphitcontentsmask = DPCONTENTS_SOLID;
	set_movetype(teddy, MOVETYPE_TOSS);
	teddy.solid = SOLID_TRIGGER;
	teddy.healamount = 10;
	teddy.healtype = 0;
	teddy.cnt = time + 0.33;
	setmodel(teddy, MDL_TEDDY);
	//setsize(teddy, '-4 -4 -4', '4 4 4');
	vector cmin = this.mins, cmax = this.maxs;
	// some basic sanity, but otherwise use player's hitbox to avoid exploits
	cmin.z = -4;
	cmax.z = 24;
	setsize(teddy, cmin, cmax);
	//settouch(teddy, teddy_touch);
	setthink(teddy, teddy_projectile_think);
	teddy.wait = time + 3;
	teddy.nextthink = time;

	vector org = this.origin + (this.view_ofs * 0.75);
	setorigin(teddy, org);
	teddy.angles = this.angles;
	teddy.angles_y = this.v_angle_y;
	teddy.pos2 = teddy.angles;
	makevectors(this.v_angle);
	teddy.velocity = v_forward * 400 + v_up * 64;
}

METHOD(Bean, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_PLAYER_SINGLE, "teddy.wav", ATTN_NORM);
		ThrowTeddy(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 10;
	}
}

METHOD(Bean, m_activate, void(Champions this, entity actor))
{
	float r = random();
	if(r < 0.25)
		player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
	else if(r < 0.50)
		player_sound(actor, CH_VOICE, "start2.wav", ATTN_NORM);
	else if(r < 0.75)
		player_sound(actor, CH_VOICE, "start3.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "start4.wav", ATTN_NORM);
}

METHOD(Bean, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death1.wav", ATTN_NORM);
	actor.bean_cannon = true;
}

METHOD(Bean, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.bean_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.bean_cannon = false;
	return false;
}
#endif
