#include "banjo.qh"

#ifdef SVQC
PRECACHE(Banjo)
{
	precache_model("progs/v_banjo.mdl");
	precache_model("progs/g_banjo.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float banjo_smoketime;
void MusicNoteTouch(entity this, entity toucher);

void banjo_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 10;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health)
	{
		if(toucher.resist_shells != 0)
		{
			damg = Resist_Damage(toucher, IT_SHELLS, damg);
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

	BecomeCartoonExplosion(this);
}

void W_FireBanjo(entity this, .entity weaponentity)
{
	this.punchangle_x = -2;
	W_TakeMana(this, 5);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).banjo_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).banjo_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float banjo_count = 6;
	bool doleft = (random() > 0.5);
	for(int j = 0; j < banjo_count; ++j)
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
		musicnote.projectiledeathtype = WEP_BANJO.m_id;
		musicnote.clipgroup = this.clipgroup;
		musicnote.effects = EF_FULLBRIGHT;

		musicnote.angles = '0 1 0' * this.angles_y;
		settouch(musicnote, MusicNoteTouch);

		musicnote.nextthink = time + 5; // Remove/Explode Time
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, BecomeCartoonExplosion);
		//_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = (random() < 0.1) ? '0.8 0.35 0' : '0.9 0.22 0.24';
		setsize(musicnote, '0 0 0', '0 0 0');
		musicnote.avelocity = '0 90 90'; // Roll

		setorigin(musicnote, neworg + randomvec() * 10);
		settouch(musicnote, banjo_note_touch);

		vector spread = '0.05 0.05 0';
		float spread_side = (j * spread.x);
		float spread_up = (j * spread.y);
		vector right = (doleft) ? v_right * -1 : v_right;
		vector spread_dir = dir + (spread_side - ((banjo_count * spread.x) * 0.5)) * right + (spread_up - ((banjo_count * spread.y) * 0.5)) * v_up;
		musicnote.velocity = spread_dir * 600;

		IL_PUSH(g_projectiles, musicnote);

		CSQCProjectile(musicnote, true, PROJECTILE_BANJO_MUSIC, true);
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 1; // TODO: per-instrument offsets
	sound7(this, CH_WEAPON_SINGLE, SND(BANJO_FIRE), 1, ATTN_NORM, r, 0);
}

METHOD(Banjo, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 5)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireBanjo(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.4);
	}
}
METHOD(Banjo, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Banjo, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Banjo, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
