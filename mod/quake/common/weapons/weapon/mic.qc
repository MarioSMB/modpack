#include "mic.qh"

#ifdef SVQC
PRECACHE(Mic)
{
	precache_model("progs/v_mic.mdl");
	precache_model("progs/g_mic.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float mic_smoketime;
void MusicNoteTouch(entity this, entity toucher);

void mic_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 50;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		if(toucher.resist_cells != 0)
		{
			damg = Resist_Damage(toucher, IT_CELLS, damg);
			Resist_Lightning(toucher, this.origin);
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

void mic_fire_note(entity this, entity targ)
{
	entity musicnote = spawn();
	musicnote.owner = this.owner;
	set_movetype(musicnote, MOVETYPE_FLYMISSILE);
	musicnote.solid = SOLID_CORPSE;
	musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	musicnote.classname = "tubanote";
	musicnote.projectiledeathtype = WEP_MIC.m_id;
	musicnote.clipgroup = this.clipgroup;
	musicnote.effects = EF_FULLBRIGHT;

	musicnote.angles = '0 1 0' * this.owner.angles_y;
	settouch(musicnote, MusicNoteTouch);

	musicnote.nextthink = time + 2.5; // Remove/Explode Time
	//musicnote.think = SUB_Remove; 
	setthink(musicnote, BecomeCartoonExplosion);
	_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
	vector mycolor;
	mycolor.x = max(0.25, random() * 5);
	mycolor.y = max(0.25, random() * 5);
	mycolor.z = max(0.25, random() * 5);
	musicnote.colormod = mycolor;
	setsize(musicnote, '0 0 0', '0 0 0');
	musicnote.avelocity = '0 90 90';

	vector targ_pos = (targ.absmin + targ.absmax) * 0.5;
	vector dir = normalize(targ_pos - this.origin);
	musicnote.velocity = dir * 500;

	setorigin(musicnote, this.origin);
	settouch(musicnote, mic_note_touch);
}

void mic_note_explode(entity this, entity ignore)
{
	Weapon mywep = DEATH_WEAPONOF(this.projectiledeathtype);

	bool hitany = true; // might as well?
	FOREACH_ENTITY_RADIUS(this.origin, 600, it != ignore && !(it.flags & FL_NOTARGET) && it.takedamage && it.health > 0 && it != this.owner && Damage_ValidTarget(it, this.owner) && ((IS_PLAYER(it) || IS_MONSTER(it)) || (hitany && it.classname != "door")),
	{
		if((!(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD) || mywep.spawnflags & WEP_FLAG_HITUNDEAD))
		{
			vector targ_pos = (it.absmin + it.absmax) * 0.5;
			traceline(this.origin, targ_pos, MOVE_NOMONSTERS, this);
			if(trace_inopen && trace_inwater)
				continue;
			if(trace_fraction != 1.0 && trace_ent != it)
				continue;
			mic_fire_note(this, it);
		}
	});

	BecomeCartoonExplosion(this);
}

void mic_bignote_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 70;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		if(toucher.resist_cells != 0)
		{
			damg = Resist_Damage(toucher, IT_CELLS, damg);
			Resist_Lightning(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	mic_note_explode(this, toucher);
}

void mic_note_explodethink(entity this)
{
	mic_note_explode(this, NULL);
}

void W_FireMic(entity this, .entity weaponentity)
{
	bool dobrown = (random() < 0.1);

	this.punchangle_x = -2;
	W_TakeMana(this, 10);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).mic_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).mic_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 300);
	float mic_count = 1;
	for(int j = 0; j < mic_count; ++j)
	{
		// copied from piano
		entity musicnote = spawn();
		musicnote.owner = this;
		set_movetype(musicnote, MOVETYPE_FLY);
		//musicnote.solid = SOLID_BBOX;
		musicnote.solid = SOLID_CORPSE;
		musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		musicnote.classname = "tubanote";
		musicnote.projectiledeathtype = WEP_MIC.m_id;
		musicnote.clipgroup = this.clipgroup;
		musicnote.effects = EF_FULLBRIGHT;

		musicnote.angles = '0 1 0' * this.angles_y;
		settouch(musicnote, MusicNoteTouch);

		musicnote.nextthink = time + 0.5; // Remove/Explode Time
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, mic_note_explodethink);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '1 1 1';
		setsize(musicnote, '0 0 0', '0 0 0');
		musicnote.avelocity = '0 0 0';
		musicnote.scale = 3;

		setorigin(musicnote, neworg);
		settouch(musicnote, mic_bignote_touch);

		vector spread = '0 0 0';
		vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
		musicnote.velocity = spread_dir * 450 + v_up * 20;
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 0.9; // TODO: per-instrument offsets
	string snd = get_deathsound(this, rint((random() * 4) + 1));
	if(dobrown)
		snd = "player_goat/death2.wav";
	sound7(this, CH_WEAPON_SINGLE, snd, 1, ATTN_NORM, r, 0);
}

METHOD(Mic, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 10)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireMic(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.2);
	}
}
METHOD(Mic, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Mic, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Mic, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
