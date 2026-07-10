#include "multi_rocket.qh"

#ifdef SVQC
//================================
//================================
void MultiRocketExplode(entity this, entity directhitentity)
{
//	Stock Single Rocket Damage...
//	damg = 100 + random()*20;

	float damg = 60 + random()*15;

	if(directhitentity.health)
	{
		if(Resist_Explosions(directhitentity))
			damg *= 0.5;	// mostly immune
		if(directhitentity.monsterdef == MON_DRAGON)
			damg = damg * 0.5;	// mostly immune (special case)
		T_Damage(directhitentity, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the directhitentity, because all the damage
	// was done in the impact
//	Stock single rocket damage.
//	T_RadiusDamage(this, this.owner, 120, directhitentity);

	T_RadiusDamage(this, this.owner, 75, this.projectiledeathtype, directhitentity);

//	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	setorigin(this, this.origin - 8 * normalize(this.velocity));

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	BecomeExplosion(this);
}

void MultiRocketExplode_think(entity this)
{
	MultiRocketExplode(this, NULL);
}

void MultiRocketTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	MultiRocketExplode(this, toucher);
}

void MultiRocketLaunch(entity this, float offset, float frameNum, .entity weaponentity)
{
	entity missile = new(MultiRocket);
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "MultiRocket";
	missile.delay = time + 4;
	missile.frame = frameNum;
	missile.projectiledeathtype = WEP_MULTI_ROCKET.m_id;
	missile.clipgroup = this.clipgroup;
	settouch(missile, MultiRocketTouch);

	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, W_Shotorg(this, weaponentity) + v_forward * 8);

	// NOTE: homing variant removed
	vector aimangle = this.v_angle;
	aimangle_y = aimangle_y + (offset * 0.66);
	makevectors(aimangle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);

	setthink(missile, MultiRocketExplode_think);
	missile.nextthink = time + 4;

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, true, PROJECTILE_MULTI_ROCKET, true);
}

void W_FireMultiRocket(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, IT_MULTI_ROCKETS, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
	
	MultiRocketLaunch(this, -10, 2, weaponentity);
	MultiRocketLaunch(this, -5, 3, weaponentity);
	MultiRocketLaunch(this, 5, 0, weaponentity);
	MultiRocketLaunch(this, 10, 1, weaponentity);
}

METHOD(MultiRocketLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireMultiRocket(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8);
	}
}
METHOD(MultiRocketLauncher, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_multi_rockets >= 1;
	return ammo_amount;
}
METHOD(MultiRocketLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(MultiRocketLauncher, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
