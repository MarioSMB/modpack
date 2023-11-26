#include "tuba.qh"

#ifdef SVQC
PRECACHE(Tuba)
{
	precache_model("progs/v_tuba.mdl");
	precache_model("progs/g_tuba.mdl");
}

.float tuba_smoketime;

void tubasound_remove(entity this)
{
	sound(this, CH_TUBA_SINGLE, SND_Null, 0, 0);
	delete(this);
}

void tuba_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 30;
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
	this.origin = findbetterlocation(this.origin, 32);

	Become_Burst_6Sided_BrightYellow_Explosion(this);
}

void W_FireTuba(entity this, .entity weaponentity)
{
	this.punchangle_x = -2;
	this.ammo_rockets -= 1;

	T_RadiusDamage(this, this, 110, WEP_TUBA.m_id, this);

	vector org = gettaginfo(this.(weaponentity), 0);
	vector offset = org + v_up * 10 + v_right * 5 + v_forward * 14;
	if(time > this.(weaponentity).tuba_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_up * 100, 1);
		this.(weaponentity).tuba_smoketime = time + 0.25;
	}

	// copied from piano
	entity musicnote = spawn();
	musicnote.owner = this;
	set_movetype(musicnote, MOVETYPE_TOSS);
	//musicnote.solid = SOLID_BBOX;
	musicnote.solid = SOLID_CORPSE;
	musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	musicnote.classname = "tubanote";
	musicnote.projectiledeathtype = WEP_TUBA.m_id;

	musicnote.angles = vectoangles(musicnote.velocity);
	settouch(musicnote, MusicNoteTouch);

	musicnote.nextthink = time + 2.5; // Remove/Explode Time
	//musicnote.think = SUB_Remove; 
	setthink(musicnote, Become_Burst_6Sided_BrightYellow_Explosion);
	_setmodel(musicnote, "progs/piano_musicnote_yellow.mdl");
	setsize(musicnote, '-3 -3 -3', '3 3 3');
	musicnote.avelocity = '0 90 0'; // Roll

	tracebox(this.origin, musicnote.mins, musicnote.maxs, offset, MOVE_NORMAL, this);

	setorigin(musicnote, trace_endpos);
	settouch(musicnote, tuba_note_touch);

	musicnote.velocity = v_forward * 200 + v_up * 600;

	// create a special entity for the sound so we can remove it
	// otherwise the sound will loop forever!
	entity tubasnd = new(tuba_note);
	setorigin(tubasnd, this.origin);
	setthink(tubasnd, tubasound_remove);
	tubasnd.nextthink = time + 0.5;

	sound(tubasnd, CH_TUBA_SINGLE, SND_TUBA_RANDOM(), 1, ATTN_NORM);
}

METHOD(Tuba, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		wep_generic_shot1(actor.(weaponentity));
		W_FireTuba(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Tuba, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(Tuba, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
