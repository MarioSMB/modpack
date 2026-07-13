#include "bagpipes.qh"

#ifdef SVQC
PRECACHE(Bagpipes)
{
	precache_model("progs/v_bagpipes.mdl");
	precache_model("progs/g_bagpipes.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float bagpipes_smoketime;
void MusicNoteTouch(entity this, entity toucher);

void W_FireBagpipes(entity this, int boffset, .entity weaponentity);

void wep_bagpipes_shot6(entity this) { wep_set_anim(this, 6, w_ready); }
void wep_bagpipes_shot5(entity this) { wep_set_anim(this, 5, wep_bagpipes_shot6); W_FireBagpipes(this.owner, 3, this.weaponentity_fld); }
void wep_bagpipes_shot4(entity this) { wep_set_anim(this, 4, wep_bagpipes_shot5); }
void wep_bagpipes_shot3(entity this) { wep_set_anim(this, 3, wep_bagpipes_shot4); W_FireBagpipes(this.owner, 2, this.weaponentity_fld); }
void wep_bagpipes_shot2(entity this) { wep_set_anim(this, 2, wep_bagpipes_shot3); }
void wep_bagpipes_shot1(entity this) { wep_set_anim(this, 1, wep_bagpipes_shot2); W_FireBagpipes(this.owner, 1, this.weaponentity_fld); }

void bagpipes_note_touch(entity this, entity toucher)
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
		if(toucher.resist_nails != 0)
		{
			damg = Resist_Damage(toucher, IT_NAILS, damg);
			Resist_Shells(toucher, this.origin, this.velocity, damg);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	//sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	//this.origin = this.origin - 8 * normalize(this.velocity);
	this.origin = findbetterlocation(this.origin, 8);
	this.angles = vectoangles(this.velocity);

	BecomeCartoonExplosion(this);
}

void bagpipes_note_think(entity this)
{
	if(time > this.wait)
	{
		BecomeCartoonExplosion(this);
		return;
	}

	if(time > this.delay)
	{
		this.delay = time + 0.2;
		entity targ = W_PickNearbyTarget(this, this.owner, 200, false, true);
		if(targ)
		{
			vector targ_pos = (targ.absmin + targ.absmax) * 0.5;
			vector dir = normalize(targ_pos - this.origin);
			this.velocity = dir * this.speed;
			this.avelocity = '0 0 0';
			setthink(this, BecomeCartoonExplosion);
			this.nextthink = time + 5;
			return;
		}
	}

	// taken from item code
	float bobheight = 0.15 * sin((time - this.spawn_time) * 8);
	fixedmakevectors(this.pos2);
	//vector oldorg = this.pos1 + this.pos2;
	vector dir = this.pos2 + v_right * bobheight;
	this.velocity = dir * this.speed;

	this.nextthink = time;
}

void W_FireBagpipes(entity this, int boffset, .entity weaponentity)
{
	makevectors(this.v_angle);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).bagpipes_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).bagpipes_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float bagpipes_count = 1; // 1 per frame
	for(int j = 0; j < bagpipes_count; ++j)
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
		musicnote.projectiledeathtype = WEP_BAGPIPES.m_id;
		musicnote.clipgroup = this.clipgroup;
		musicnote.effects = EF_FULLBRIGHT;

		musicnote.angles = '0 1 0' * this.angles_y;
		settouch(musicnote, MusicNoteTouch);

		musicnote.delay = time + 0.1; // short delay before attacking anything
		musicnote.wait = time + 5; // lifetime of the projectile
		musicnote.nextthink = time;
		setthink(musicnote, bagpipes_note_think);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '0.66 0.44 0.31';
		setsize(musicnote, '0 0 0', '0 0 0');
		//musicnote.avelocity = '0 90 90'; // Roll

		setorigin(musicnote, neworg + randomvec() * 10);
		settouch(musicnote, bagpipes_note_touch);

		vector spread = '0.01 0.01 0';
		float spread_side = (j * spread.x);
		float spread_up = (j * spread.y);
		vector right = v_right * boffset * -4;
		vector spread_dir = dir + (spread_side - ((bagpipes_count * spread.x) * 0.5)) * right + (spread_up - ((bagpipes_count * spread.y) * 0.5)) * v_up;

		// for bobbing
		musicnote.pos1 = neworg;
		musicnote.pos2 = spread_dir;
		musicnote.spawn_time = time;

		musicnote.speed = 700;

		musicnote.velocity = spread_dir * musicnote.speed;

		IL_PUSH(g_projectiles, musicnote);

		//CSQCProjectile(musicnote, true, PROJECTILE_BAGPIPES_MUSIC, true);
	}
}

void W_Bagpipes_Prefire(entity this, .entity weaponentity)
{
	W_TakeMana(this, 8);
	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 1; // TODO: per-instrument offsets
	qc_sound7(this, CH_WEAPON_SINGLE, SND_BAGPIPES_FIRE, 1, ATTN_NORM, r, 0);
}

METHOD(Bagpipes, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 8)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_bagpipes_shot1(actor.(weaponentity));
		W_Bagpipes_Prefire(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(Bagpipes, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Bagpipes, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Bagpipes, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
