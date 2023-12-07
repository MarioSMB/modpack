#include "tuba.qh"

#ifdef SVQC
PRECACHE(Doot)
{
	precache_model("progs/v_doot.mdl");
	precache_model("progs/g_doot.mdl");

	precache_model("progs/piano_musicnote_yellow.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float doot_smoketime;
void Become_Burst_6Sided_BrightYellow_Explosion(entity this);
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

	float mydmg = 15;
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

	Become_Burst_6Sided_BrightYellow_Explosion(this);
}

void W_FireDoot(entity this, .entity weaponentity)
{
	this.punchangle_x = -2;
	W_TakeAmmo(this, ammo_rockets, 1);

	vector org = gettaginfo(this.(weaponentity), 0);
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).doot_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).doot_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float doot_count = max(1, rint(random() * 8));
	for(int j = 0; j < doot_count; ++j)
	{
		// copied from piano
		entity musicnote = spawn();
		musicnote.owner = this;
		set_movetype(musicnote, MOVETYPE_TOSS);
		//musicnote.solid = SOLID_BBOX;
		musicnote.solid = SOLID_CORPSE;
		musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		musicnote.classname = "tubanote";
		musicnote.projectiledeathtype = WEP_DOOT.m_id;

		musicnote.angles = '0 0 0';
		settouch(musicnote, MusicNoteTouch);

		musicnote.nextthink = time + 2.5; // Remove/Explode Time
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, Become_Burst_6Sided_BrightYellow_Explosion);
		_setmodel(musicnote, "progs/piano_musicnote_yellow.mdl");
		setsize(musicnote, '0 0 0', '0 0 0');
		musicnote.avelocity = '0 90 180'; // Roll

		setorigin(musicnote, neworg + randomvec() * 10);
		settouch(musicnote, doot_note_touch);

		vector spread = '0.15 0.15 0';
		vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
		musicnote.velocity = spread_dir * 500;
	}

	float r = bound(0.8, random() * 2, 1.3);
	sound7(this, CH_WEAPON_SINGLE, SND(DOOT_FIRE), 1, ATTN_NORM, 100 / r, 0);
}

METHOD(Doot, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
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
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(Doot, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
