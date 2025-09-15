#include "ocarina.qh"

#ifdef SVQC
PRECACHE(Ocarina)
{
	precache_model("progs/v_ocarina.mdl");
	precache_model("progs/g_ocarina.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float ocarina_smoketime;
.float thaw_time;
void MusicNoteTouch(entity this, entity toucher);

void ocarina_unfreeze(entity this)
{
	SUB_Unfreeze(this);
	this.thaw_time = time + 2;
}

void ocarina_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 20;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		if(toucher.resist_cells != 0)
		{
			damg = Resist_Damage(toucher, IT_CELLS, damg);
			Resist_Plasma(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		if(!toucher.is_frozen && time > toucher.thaw_time && toucher.health > 0 && toucher.takedamage && IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
		{
			SUB_Freeze(toucher);
			setthink(toucher, ocarina_unfreeze);
			float freeze_time = 3;
			if(StatusEffects_active(STATUSEFFECT_Slowness, toucher))
				freeze_time = 10;

			toucher.nextthink = time + freeze_time;
		}
	}

	if(toucher.classname == "rotate_object_continuously" && time > toucher.thaw_time)
		rotate_object_freeze(toucher);

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	//sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	//this.origin = this.origin - 8 * normalize(this.velocity);
	this.origin = findbetterlocation(this.origin, 8);

	BecomeCartoonExplosion(this);
}

void W_FireOcarina(entity this, .entity weaponentity)
{
	this.punchangle_x = -2;
	W_TakeMana(this, 5);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).ocarina_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).ocarina_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float ocarina_count = 1;
	for(int j = 0; j < ocarina_count; ++j)
	{
		// copied from piano
		entity musicnote = spawn();
		musicnote.flags = FL_PROJECTILE;
		musicnote.owner = this;
		set_movetype(musicnote, MOVETYPE_FLYMISSILE);
		//musicnote.solid = SOLID_BBOX;
		musicnote.solid = SOLID_CORPSE;
		musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		musicnote.classname = "tubanote";
		musicnote.projectiledeathtype = WEP_OCARINA.m_id;
		musicnote.clipgroup = this.clipgroup;
		musicnote.effects = EF_FULLBRIGHT;

		musicnote.angles = '0 1 0' * this.angles_y;
		settouch(musicnote, MusicNoteTouch);

		musicnote.nextthink = time + 3; // Remove/Explode Time
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, BecomeCartoonExplosion);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '0.1 0.1 1';
		setsize(musicnote, '0 0 0', '0 0 0');
		musicnote.avelocity = '0 90 90'; // Roll

		setorigin(musicnote, neworg + randomvec() * 10);
		settouch(musicnote, ocarina_note_touch);

		vector spread = '0.1 0.1 0';
		vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
		musicnote.velocity = spread_dir * 450;
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 0.8; // TODO: per-instrument offsets
	sound7(this, CH_WEAPON_SINGLE, SND(OCARINA_MUSICNOTE), 1, ATTN_NORM, r, 0);
}

METHOD(Ocarina, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 5)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireOcarina(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.33);
	}
}
METHOD(Ocarina, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Ocarina, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Ocarina, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
