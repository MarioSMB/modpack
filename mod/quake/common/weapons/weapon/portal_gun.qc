#include "portal_gun.qh"

#ifdef SVQC
PRECACHE(PortalGun)
{
	precache_model("progs/v_portal.mdl");
	precache_model("progs/g_portal.mdl");

	precache_model("progs/portal1.bsp");
	precache_model("progs/portal2.bsp");

	precache_sound("portal/fire.wav");
	precache_sound("portal/close.wav");
	precache_sound("portal/use.wav");
}

.entity portal1;
.entity portal2;
..entity portal_fld;

// NOTE: expects trace_plane_normal to be set
vector portal_face(vector org)
{
	// Returns facing for the portal
	vector v = trace_plane_normal;
	v.z = v.z * -1;
	return vectoangles(v);
}

vector portal_clip_player(entity portal)
{
	// Returns coordinates where the teleported object appears
	vector org = portal.origin;
	makevectors(portal.angles);
	org += v_forward * 48;
	return org;
}

void PortalErase(entity portal)
{
	if(!portal)
		return; // why?
	.entity fld = portal.portal_fld;
	if(portal.realowner.(fld) == portal)
		portal.realowner.(fld) = NULL;

	soundat(NULL, portal.origin, CH_TRIGGER, "portal/close.wav", 1, ATTEN_NORM);
	//te_teleport(org);
	delete(portal);
}

void PortalUpdate(entity this)
{
	if(time > this.cnt)
	{
		PortalErase(this);
		return;
	}
	// TODO: why are we ticking this?
	this.nextthink = time + 0.1;
}

void PortalTouch(entity this, entity toucher)
{
	bool isprimary = (this.realowner.portal1 == this);
	entity alt = (isprimary) ? this.realowner.portal2 : this.realowner.portal1;

	if(!alt)
		return;
	if(!toucher.takedamage || toucher.size_x > 32)
		return;
	Monster mon = toucher.monsterdef;
	if(mon && ((mon.spawnflags & MON_FLAG_STATIONARY) || (mon.spawnflags & MONSTER_TYPE_BOSS)))
		return;
	if(this.frags > time)
		return;

	float vel = vlen(toucher.velocity) + 120;

	vector org = portal_clip_player(alt);

	// NOTE: the original says setorigin can't be used from touch functions TODO: make sure this isn't the case in DP?!
	setorigin(toucher, org);

	// effect at my location
	soundat(NULL, this.origin, CH_TRIGGER, "portal/use.wav", 1, ATTEN_NORM);
	te_teleport(this.origin);

	// and at target location
	soundat(NULL, alt.origin, CH_TRIGGER, "portal/use.wav", 1, ATTEN_NORM);
	te_teleport(alt.origin);

	this.cnt = time + 120; // reset cooldown wheneverp ortal is used
	this.frags = time + 0.2;
	alt.frags = time + 0.2;

	toucher.teleport_time = time + 0.7;
	toucher.fixangle = 1;
	toucher.velocity = vel * normalize(alt.punchangle) * 0.9;
	if(toucher.velocity_x == 0 && toucher.velocity_y == 0)
		toucher.fixangle = 0;
	toucher.angles = '0 0 0';
	toucher.angles_y = vectoyaw(toucher.velocity);
	toucher.v_angle_z = 0;
	UNSET_ONGROUND(toucher);
}

void T_PortalSpawn(entity this, int fire, entity hit, vector org)
{
	// changed to make portals only placed on world geometry
	bool hit_allowed = (hit.solid == SOLID_BSP && hit.move_movetype == MOVETYPE_NONE); // allow stationary bspmodels
	if(hit && !hit_allowed)//if(hit.classname == "portalproof" || hit.classname == "door" || hit.move_movetype == MOVETYPE_PUSH || hit.classname == "hardlight2" || hit.classname == "pellet")
	{
		soundat(NULL, org, CH_TRIGGER, "portal/close.wav", 1, ATTEN_NORM);
		te_teleport(org);
		return;
	}

	entity portal = spawn();
	portal.owner = this;
	portal.realowner = this;
	set_movetype(portal, MOVETYPE_NONE);
	portal.solid = SOLID_TRIGGER;
	portal.classname = "portal";
	portal.fixangle = 1;
	portal.cnt = time + 120;
	portal.angles = portal_face(org);
	portal.punchangle = trace_plane_normal;
	settouch(portal, PortalTouch);
	if(fire & 1)
	{
		portal.portal_fld = portal1;
		this.portal1 = portal;
		_setmodel(portal, "progs/portal1.bsp");
	}
	else
	{
		portal.portal_fld = portal2;
		this.portal2 = portal;
		_setmodel(portal, "progs/portal2.bsp");
	}
	portal.frags = time - 0.1;
	portal.nextthink = time + 0.1;
	setthink(portal, PortalUpdate);
	portal.movetarget = hit;
	portal.oldorigin = hit.origin;
	portal.frame = 4;
	setorigin(portal, org);

	force_retouch = 2;
}

void PortalFire(entity this, int fire, .entity weaponentity)
{
	entity portal = (fire & 1) ? this.portal1 : this.portal2;
	if(portal)
	{
		PortalErase(portal);
		_sound(this, CH_WEAPON_SINGLE, "portal/close.wav", 1, ATTN_NORM);
		// enable to allow attacks to cancel portals instead of casting new ones
	#if 0
		// reset attack delay so we can fire another portal quickly
		if(fire & 1)
			this.attack_finished = time + 0.2;
		else
			this.attack2_finished = time + 0.2;
		return;
	#endif
	}

	_sound(this, CH_WEAPON_SINGLE, "portal/fire.wav", 1, ATTN_NORM);

	vector myorg = W_Shotorg(this, weaponentity);
	vector src = myorg + v_forward * 10; // TODO: stuck in wall?
	vector dir = myorg + v_forward * 100000;

	traceline(src, src + dir, false, this);
	if(trace_fraction != 1 && !(trace_dphitcontents & DPCONTENTS_PLAYERCLIP) && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY) && pointcontents(trace_endpos) != CONTENT_SKY)
	{
		if(trace_ent.classname == "hardlight")
		{
			traceline(trace_endpos, dir, true, trace_ent);
			if(trace_fraction != 1)
				T_PortalSpawn(this, fire, trace_ent, trace_endpos);
		}
		else
			T_PortalSpawn(this, fire, trace_ent, trace_endpos);
	}
}

METHOD(PortalGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8); // before PortalFire so it can be overridden!
		PortalFire(actor, 1, weaponentity);
	}

	if(fire & 2)
	if(!(time < actor.attack2_finished))
	{
		actor.attack2_finished = time + 0.8;
		PortalFire(actor, 2, weaponentity);
	}
}
METHOD(PortalGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(PortalGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
