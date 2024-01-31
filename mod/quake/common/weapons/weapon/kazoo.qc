#include "tuba.qh"

#ifdef SVQC
PRECACHE(Kazoo)
{
	precache_model("progs/v_kazoo.mdl");
	precache_model("progs/g_kazoo.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float kazoo_smoketime;
void Become_Burst_6Sided_BrightYellow_Explosion(entity this);

void kazoo_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 12;
	float damg = mydmg + random() * mydmg;
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
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

void kazoo_note_spreadout(entity this)
{
	if(time > this.count)
	{
		Become_Burst_6Sided_BrightYellow_Explosion(this);
		return;
	}
	entity selected = W_PickNearbyTarget(this, false);
	if(selected)
	{
		vector dir = normalize(selected.origin - this.origin);
		this.velocity = dir * 800;
		this.avelocity = '0 0 0';
		setthink(this, Become_Burst_6Sided_BrightYellow_Explosion);
		this.nextthink = time + 5;
	}
	else
		this.nextthink = time + 0.15;
}

void kazoo_note_think(entity this)
{
	if(time > this.wait)
	{
		kazoo_note_spreadout(this);
		return;
	}

	if(random() < 0.5)
		this.avelocity = '0 45 45';
	else
		this.avelocity = '0 -45 -45';

	// Randomly drift upwards and slow down forward movement
	if(vdist(this.velocity, >, 50))
	{
		//this.velocity_z += 2 + (random() * 10);
		this.velocity -= (this.movedir * 0.125);
	}
	this.nextthink = time + 0.1;
}

void W_FireKazoo(entity this, .entity weaponentity)
{
	this.punchangle_x = -1;
	W_TakeMana(this, 5);

	vector org = gettaginfo(this.(weaponentity), 0);
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).kazoo_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		//Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		particle(offset, v_forward * 450 + v_up * 100, 240, 1);
		this.(weaponentity).kazoo_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float kazoo_count = 1;
	for(int j = 0; j < kazoo_count; ++j)
	{
		// copied from piano
		entity musicnote = spawn();
		musicnote.owner = this;
		set_movetype(musicnote, MOVETYPE_FLYMISSILE);
		//musicnote.solid = SOLID_BBOX;
		musicnote.effects = EF_FULLBRIGHT;
		musicnote.solid = SOLID_CORPSE;
		musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		musicnote.classname = "tubanote";
		musicnote.projectiledeathtype = WEP_KAZOO.m_id;

		musicnote.scale = 0.4;
		musicnote.angles = '0 1 0' * this.angles_y;

		musicnote.count = time + 3; // lifetime of the floating projectile
		musicnote.wait = time + 1.75; // Spreadout time
		musicnote.nextthink = time + 0.1;
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, kazoo_note_think);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '1 0.6 0';
		setsize(musicnote, '0 0 0', '0 0 0');

		setorigin(musicnote, neworg);
		settouch(musicnote, kazoo_note_touch);

		vector spread = '0.15 0.15 0';
		vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
		musicnote.movedir = spread_dir * 150 + v_up * 20;
		musicnote.velocity = musicnote.movedir;
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 1.2; // TODO: per-instrument offsets
	sound7(this, CH_WEAPON_SINGLE, SND(KAZOO_FIRE), 1, ATTN_NORM, r, 0);
}

METHOD(Kazoo, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 5)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireKazoo(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.25);
	}
}
METHOD(Kazoo, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Kazoo, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
