#ifndef IMPLEMENTATION
.entity hitboxft, hitboxbk;
.entity hitboxmf, hitboxmb;
#endif

#ifdef IMPLEMENTATION
#ifdef SVQC

void vehicles_hitbox_touch(entity this, entity toucher)
{
	if(gettouch(this.owner))
		gettouch(this.owner)(this.owner, toucher);
}

void vehicles_hitbox_damage(entity this, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(this.owner.event_damage)
		this.owner.event_damage(this.owner, inflictor, attacker, damage, deathtype, hitloc, force);
}

void vehicles_hitbox_kill(entity this)
{
	this.health = 0;
	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;
	setthink(this, func_null);
	settouch(this, func_null);
	this.deadflag = DEAD_DEAD;
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
}

void vehicles_hitbox_spawn(entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float side_s)
{
	hitbox.owner = vehic;
	settouch(hitbox, vehicles_hitbox_touch);

	hitbox.event_damage = vehicles_hitbox_damage;

	if(!hitbox.bot_attack)
		IL_PUSH(g_bot_targets, hitbox);
	hitbox.bot_attack = true;
	hitbox.iscreature = vehic.iscreature;
	hitbox.teleportable = vehic.teleportable;
	if(!hitbox.damagedbycontents)
		IL_PUSH(g_damagedbycontents, hitbox);
	hitbox.damagedbycontents = vehic.damagedbycontents;
	//set_movetype(hitbox, vehic.move_movetype); // shouldn't do this
	hitbox.solid = SOLID_SLIDEBOX;
	hitbox.takedamage = vehic.takedamage;
	hitbox.deadflag = vehic.deadflag;
	hitbox.flags = FL_NOTARGET; // let bots and vehicles only target the main hitbox
	setthink(hitbox, func_null);
	hitbox.vehicle_health = vehic.vehicle_health;
	hitbox.netname = vehic.netname;
	setsize(hitbox, min_s, max_s);
	makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); // Inverted pitch on models
	setorigin(hitbox, (vehic.origin + v_forward * fwd_s + v_right * side_s)); // Forward X qunits
	follow_sameorigin(hitbox, vehic); // Follow vehic
	
	hitbox.damageforcescale = vehic.damageforcescale;
	hitbox.ballistics_density = vehic.ballistics_density;
}

#endif
#endif