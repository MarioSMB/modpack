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

void W_FireTuba(entity this)
{
	this.punchangle_x = -2;
	this.ammo_rockets -= 1;

	T_RadiusDamage(this, this, 110, WEP_TUBA.m_id, this);

	vector org = gettaginfo(this.weaponentity, 0);
	vector offset = org + v_up * 10 + v_right * 5 + v_forward * 14;
	if(time > this.weaponentity.tuba_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_up * 100, 1);
		this.weaponentity.tuba_smoketime = time + 0.25;
	}

#if 0
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
	setthink(musicnote, Become_Burst_6Sided_Brown_Explosion);
	_setmodel(musicnote, "progs/piano_musicnote_yellow.mdl");
	setsize(musicnote, '-3 -3 -3', '3 3 3');
	musicnote.avelocity = '0 90 0'; // Roll

	tracebox(this.origin, musicnote.mins, musicnote.maxs, offset, MOVE_NORMAL, this);

	setorigin(musicnote, trace_endpos);
	settouch(musicnote, T_MissileTouch);

	musicnote.velocity = v_forward * 200 + v_up * 600;
#endif

	// create a special entity for the sound so we can remove it
	// otherwise the sound will loop forever!
	entity tubasnd = new(tuba_note);
	setorigin(tubasnd, this.origin);
	setthink(tubasnd, tubasound_remove);
	tubasnd.nextthink = time + 0.5;

	sound(tubasnd, CH_TUBA_SINGLE, SND_TUBA_RANDOM(), 1, ATTN_NORM);
}

METHOD(Tuba, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor))
	{
		player_shot1(actor);
		W_FireTuba(actor);
		actor.attack_finished = time + 0.5;
	}
}
METHOD(Tuba, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(Tuba, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
