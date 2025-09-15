#include "doot.qh"

#ifdef SVQC
PRECACHE(Doot)
{
	precache_model("progs/v_doot.mdl");
	precache_model("progs/g_doot.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");

	precache_model("progs/sonic_boom.spr");
}

.float doot_smoketime;
void MusicNoteTouch(entity this, entity toucher);

void doot_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = ((this.scale > 1) ? 30 : 15);
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	//sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	//this.origin = this.origin - 8 * normalize(this.velocity);
	this.origin = findbetterlocation(this.origin, 8);

	BecomeCartoonExplosion(this);
}

void doot_ring_push(entity this, entity toucher)
{
	FOREACH_ENTITY_RADIUS(this.origin, 50, IS_PLAYER(it) && it == this.owner,
	{
		float pushforce = 100 / vlen(it.maxs - it.mins);

		it.velocity_z = (400 * pushforce);
	});
}

void doot_ring_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner || toucher.solid == SOLID_TRIGGER)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	doot_ring_push(this, toucher);
	
	setthink(this, SUB_Remove);
	settouch(this, func_null);
	this.nextthink = time;
}

void doot_ring_think(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		return;
	}

	entity newmis = spawn();
	newmis.classname = "sonic_boom";
	newmis.owner = this;
	newmis.solid = SOLID_NOT;
	set_movetype(newmis, MOVETYPE_NONE);
	// Roll the sonic boom from side to side towards the target
	//float roll = 350 + random() * 20;
	newmis.angles = this.angles;
	//newmis.angles_z = ANGLEMOD(roll);
	newmis.effects |= EF_NOSHADOW;
	_setmodel(newmis, "progs/sonic_boom.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, this.origin);
	SUB_SetFade(newmis, time, 0.33);
	newmis.scale = this.scale;

	this.scale += 0.1;
	setsize(this, -this.pos1 * this.scale, this.pos1 * this.scale);

	this.nextthink = time + 0.05;
}

void doot_ring(entity this, vector org, vector dir)
{
	entity newmis = spawn();
	newmis.classname = "sonic_shriek";
	newmis.owner = this;

	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.dphitcontentsmask = DPCONTENTS_SOLID;
	newmis.solid = SOLID_CORPSE;
	newmis.pos1 = '32 32 32';
	newmis.projectiledeathtype = WEP_DOOT.m_id;
	newmis.clipgroup = this.clipgroup;
	newmis.cnt = time + 0.3;
	newmis.scale = 0.2;
	setsize(newmis, -newmis.pos1 * newmis.scale, newmis.pos1 * newmis.scale);
	setorigin(newmis, org);

	float aspeed = 400;
	newmis.velocity = dir * aspeed;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 0.1;
	setthink(newmis, doot_ring_think);
	settouch(newmis, doot_ring_touch);
}

void W_FireDoot(entity this, .entity weaponentity)
{
	bool docolors = (random() < 0.07);
	bool dobrown = (!docolors && random() < 0.1);

	this.punchangle_x = -2;
	W_TakeMana(this, 5);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).doot_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		if(dobrown)
			Send_Effect(EFFECT_BROWN_NOTE, offset, v_forward * 50, 1);
		else
			Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).doot_smoketime = time + 0.25;
	}

	doot_ring(this, offset, v_forward);

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float doot_count = max(1, rint(random() * 8));
	if(dobrown)
		doot_count = 1;
	for(int j = 0; j < doot_count; ++j)
	{
		// copied from piano
		entity musicnote = spawn();
		musicnote.flags = FL_PROJECTILE;
		musicnote.owner = this;
		set_movetype(musicnote, MOVETYPE_TOSS);
		//musicnote.solid = SOLID_BBOX;
		musicnote.solid = SOLID_CORPSE;
		musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		musicnote.classname = "tubanote";
		musicnote.projectiledeathtype = WEP_DOOT.m_id;
		musicnote.clipgroup = this.clipgroup;
		musicnote.effects = EF_FULLBRIGHT;

		musicnote.angles = '0 1 0' * this.angles_y;
		settouch(musicnote, MusicNoteTouch);

		musicnote.nextthink = time + 2.5; // Remove/Explode Time
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, BecomeCartoonExplosion);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		if(docolors)
		{
			vector mycolor;
			mycolor.x = max(0.25, random() * 5);
			mycolor.y = max(0.25, random() * 5);
			mycolor.z = max(0.25, random() * 5);
			musicnote.colormod = mycolor;
		}
		else if(dobrown)
		{
			musicnote.scale = 4;
			musicnote.colormod = '0.5 0.25 0';
		}
		else
			musicnote.colormod = '1 0.85 0';
		setsize(musicnote, '0 0 0', '0 0 0');
		musicnote.avelocity = '0 90 90'; // Roll

		setorigin(musicnote, neworg + randomvec() * 10);
		settouch(musicnote, doot_note_touch);

		vector spread = '0.15 0.15 0';
		vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
		musicnote.velocity = spread_dir * 450 + v_up * 100;

		IL_PUSH(g_projectiles, musicnote);
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	if(dobrown)
		r = 35;
	else
		r *= 0.75; // TODO: per-instrument offsets
	sound7(this, CH_WEAPON_SINGLE, SND(DOOT_FIRE), 1, ATTN_NORM, r, 0);
}

METHOD(Doot, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 5)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireDoot(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.4);
	}
}
METHOD(Doot, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Doot, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Doot, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
