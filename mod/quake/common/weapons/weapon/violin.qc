#include "violin.qh"

#ifdef SVQC
PRECACHE(Violin)
{
	precache_model("progs/v_violin.mdl");
	precache_model("progs/g_violin.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float violin_smoketime;
void MusicNoteTouch(entity this, entity toucher);

void violin_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 18;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.takedamage)
	{
		float efftime = 5;
		float curtime = StatusEffects_gettime(STATUSEFFECT_Levitation, toucher);
		if(IS_ONGROUND(toucher) && (time + efftime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Levitation, toucher, time + efftime, 0);

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

void W_FireViolin(entity this, .entity weaponentity)
{
	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
	W_TakeMana(this, 8);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).violin_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).violin_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float violin_count = 10;
	for(int j = 0; j < violin_count; ++j)
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
		musicnote.projectiledeathtype = WEP_VIOLIN.m_id;
		musicnote.clipgroup = this.clipgroup;
		musicnote.effects = EF_FULLBRIGHT;
		musicnote.gravity = -1;

		musicnote.angles = '0 1 0' * this.angles_y;
		settouch(musicnote, MusicNoteTouch);

		musicnote.nextthink = time + 5; // Remove/Explode Time
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, BecomeCartoonExplosion);
		//_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '0.95 0.92 0.89';
		setsize(musicnote, '0 0 0', '0 0 0');
		//musicnote.avelocity = '0 90 90'; // Roll

		setorigin(musicnote, neworg + randomvec() * 10 + v_right * -4);
		settouch(musicnote, violin_note_touch);

		vector spread = '0.1 0.1 0';
		//float spread_side = (j * spread.x);
		//float spread_up = (j * spread.y);
		vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
		musicnote.velocity = spread_dir * 500;

		IL_PUSH(g_projectiles, musicnote);

		CSQCProjectile(musicnote, true, PROJECTILE_VIOLIN_MUSIC, true);
	}

	if(random() < 0.2)
	{
		sound(this, CH_WEAPON_SINGLE, SND_VIOLIN_MISFIRE, 1, ATTN_NORM);
		return;
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.85, random() * 2, 1.15));
	r *= 1; // TODO: per-instrument offsets
	qc_sound7(this, CH_WEAPON_SINGLE, SND_VIOLIN_FIRE, 1, ATTN_NORM, r, 0);
}

METHOD(Violin, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 8)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireViolin(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.2);
	}
}
METHOD(Violin, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Violin, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Violin, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
