#include "ripper.qh"

#ifdef SVQC
PRECACHE(Ripper)
{
	precache_model("progs/blade.mdl");
	precache_model("progs/v_buzzsaw.mdl");
	precache_model("progs/g_buzzsaw.mdl");

	precache_sound("weapons/bzric.wav");
	precache_sound("weapons/bzfire.wav");
}

bool disc_shouldbehead(entity this, entity toucher)
{
	if(toucher.monsterdef)
	{
		if(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
			return false;
		if(toucher.monsterdef.spawnflags & MON_FLAG_METAL)
			return false;
	}
	if(toucher.solid == SOLID_BSP || toucher.move_movetype == MOVETYPE_PUSH)
		return false;
	return true;
}

void disc_touch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 45, toucher);
		if(this.origin_z >= toucher.origin_z + 20 && disc_shouldbehead(this, toucher))
			T_Damage(toucher, this, this.realowner, 105, this.projectiledeathtype);
		else
			T_Damage(toucher, this, this.realowner, 45, this.projectiledeathtype);
		delete(this);
		return;
	}
	
	this.owner = NULL;	// can damage the real owner
	_sound(this, CH_WEAPON_SINGLE, "weapons/bzric.wav", 1, ATTN_NORM);
	
	if(this.num_bounces < 6)
	{
		this.num_bounces += 1;
		
		vector oldvel = normalize(this.oldvelocity);

		vector start = this.origin - 16*oldvel;
		vector end = this.origin + 16*oldvel;
		traceline(start, end, false, this);

		setorigin(this, trace_endpos);
		this.velocity = oldvel + 2*trace_plane_normal;
		this.velocity = normalize(this.velocity) * 1000;
		this.oldvelocity = this.velocity;
		UNSET_ONGROUND(this);
	}
	else
	{
		te_gunshot(this.origin);
		delete(this);
	}
}

void disc_think(entity this)
{
	this.nextthink = time;
	if(this.cnt < time)
	{
		delete(this);
		return;
	}

	UNSET_ONGROUND(this);
	this.velocity = this.oldvelocity;
	this.angles = vectoangles(this.velocity);
}

void W_FireRipper(entity this, .entity weaponentity)
{
	this.punchangle_x = -2;

	W_TakeAmmo(this, ammo_shells, 2);

	_sound(this, CH_WEAPON_SINGLE, "weapons/bzfire.wav", 1, ATTN_NORM);

	entity disc = spawn();
	disc.projectiledeathtype = WEP_RIPPER.m_id;
	disc.owner = disc.realowner = this;
	set_movetype(disc, MOVETYPE_FLYMISSILE);
	disc.solid = SOLID_BBOX;
	disc.classname = "blade";

	makevectors (this.v_angle);
	disc.velocity = qc_aim(this, 1000);
	disc.velocity = disc.velocity * 1000;
	disc.oldvelocity = disc.velocity;
	disc.angles = vectoangles(disc.velocity);
	settouch(disc, disc_touch);
	disc.cnt = time + 5;
	disc.nextthink = time;
	setthink(disc, disc_think);

	_setmodel(disc, "progs/blade.mdl");
	setsize(disc, '0 0 0', '0 0 0');
	vector org = W_Shotorg(this, weaponentity); // v_forward * 8, not used because it goes through mobs!
	setorigin(disc, org);
}

METHOD(Ripper, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		W_FireRipper(actor, weaponentity);
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.66);
	}
}
METHOD(Ripper, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_shells >= 2;
	return ammo_amount;
}
METHOD(Ripper, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
