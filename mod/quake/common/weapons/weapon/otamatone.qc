#include "otamatone.qh"

#ifdef SVQC
PRECACHE(Otamatone)
{
	precache_model("progs/v_otamatone.mdl");
	precache_model("progs/g_otamatone.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

const float OTAMATONE_WEPANIMTIME = 0.015;

void wep_otamatone_shot6(entity this) { wep_set_anim(this, 6, w_ready); this.weapon_nextthink = time + OTAMATONE_WEPANIMTIME; }
void wep_otamatone_shot5(entity this) { wep_set_anim(this, 5, wep_otamatone_shot6); this.weapon_nextthink = time + OTAMATONE_WEPANIMTIME; }
void wep_otamatone_shot4(entity this) { wep_set_anim(this, 4, wep_otamatone_shot5); this.weapon_nextthink = time + OTAMATONE_WEPANIMTIME; }
void wep_otamatone_shot3(entity this) { wep_set_anim(this, 3, wep_otamatone_shot4); this.weapon_nextthink = time + OTAMATONE_WEPANIMTIME; }
void wep_otamatone_shot2(entity this) { wep_set_anim(this, 2, wep_otamatone_shot3); this.weapon_nextthink = time + OTAMATONE_WEPANIMTIME; }
void wep_otamatone_shot1(entity this) { wep_set_anim(this, 1, wep_otamatone_shot2); this.weapon_nextthink = time + OTAMATONE_WEPANIMTIME; this.owner.effects |= EF_MUZZLEFLASH; }

.float otamatone_smoketime;

void otamatone_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner || (toucher && toucher.solid != SOLID_BSP))
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 30;
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

	BecomeCartoonExplosion(this);
}

void otamatone_zapnearby(entity this)
{
	bool hitenemy = false;
	FOREACH_ENTITY_RADIUS(this.origin, 200, IS_MONSTER(it) || (IS_PLAYER(it) && !autocvar_g_friendlyfire_virtual),
	{
		if(it.health <= 0 || !it.takedamage || it == this.owner)
			continue;
		SendCSQCLightningBeam(this.origin, it.origin);
		// may cause heavy lag when fired near water!
		//LightningDamage(this.origin, it.origin, this, 15, WEP_OTAMATONE.m_id);
		T_Damage(it, this, this.owner, 15, this.projectiledeathtype);
		hitenemy = true;
	});

	if(!hitenemy) //&& random() < 0.8)
		SendCSQCLightningBeam(this.origin, this.origin + randomvec() * (random() * 80));
}

void otamatone_note_think(entity this)
{
	if(time > this.wait)
	{
		BecomeCartoonExplosion(this);
		return;
	}

	// taken from item code
	float bobheight = 12 + 32 * sin((time - this.spawn_time) * 4);
	vector oldorg = this.pos1 + this.pos2;
	this.origin_z = oldorg.z + bobheight;

	if(time > this.delay)
	{
		this.delay = time + 0.2;
		otamatone_zapnearby(this);
	}

	this.nextthink = time;
}

void W_FireOtamatone(entity this, .entity weaponentity)
{
	this.punchangle_x = -1;
	W_TakeMana(this, 8);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).otamatone_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_OTAMATONE_FIRE, offset, v_forward * 450 + v_up * 16 + v_right * -100, 1);
		//particle(offset, v_forward * 450 + v_up * 120, 225, 12);
		this.(weaponentity).otamatone_smoketime = time + 0.25;
	}

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	vector dir = qc_aim(this, 500);
	float otamatone_count = 1;
	for(int j = 0; j < otamatone_count; ++j)
	{
		// copied from piano
		entity musicnote = spawn();
		musicnote.owner = this;
		set_movetype(musicnote, MOVETYPE_FLYMISSILE);
		//musicnote.solid = SOLID_BBOX;
		musicnote.effects = EF_FULLBRIGHT;
		musicnote.solid = SOLID_CORPSE;
		musicnote.dphitcontentsmask = DPCONTENTS_SOLID;
		musicnote.classname = "tubanote";
		musicnote.projectiledeathtype = WEP_OTAMATONE.m_id;

		//musicnote.scale = 0.4;
		musicnote.angles = '0 1 0' * this.angles_y;

		musicnote.delay = time + 0.1; // short delay before attacking anything
		musicnote.wait = time + 5; // lifetime of the projectile
		musicnote.nextthink = time;
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, otamatone_note_think);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '0.73 0.15 1';
		setsize(musicnote, '0 0 0', '0 0 0');

		// for bobbing
		musicnote.pos1 = neworg;
		musicnote.pos2 = dir;
		musicnote.spawn_time = time;

		setorigin(musicnote, neworg);
		settouch(musicnote, otamatone_note_touch);

		musicnote.velocity = dir * 500;
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 1.2; // TODO: per-instrument offsets
	sound7(this, CH_WEAPON_SINGLE, SND(OTAMATONE_FIRE), 1, ATTN_NORM, r, 0);
}

METHOD(Otamatone, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 8)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_otamatone_shot1(actor.(weaponentity));
		W_FireOtamatone(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(Otamatone, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Otamatone, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
