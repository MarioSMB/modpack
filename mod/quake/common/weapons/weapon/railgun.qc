#include "railgun.qh"

#ifdef SVQC
PRECACHE(Railgun)
{
	precache_model("progs/v_railgun.mdl");
	precache_model("progs/g_railgun.mdl");

	precache_model("progs/bolt2.mdl");

	precache_sound("weapons/railwhirl1.wav");
	precache_sound("weapons/railwhirl2.wav");
	precache_sound("weapons/rail2.wav");
}

// even more smooth:
float lerpCosine(float a, float b, float mix)
{
	if(mix <= 0) return a;
	if(mix >= 1) return b;

	float cmx = (1 - cos(mix * 180)) / 2;

	return (b * cmx + a * (1 - cmx));
}

void wep_railgun_rail40(entity this) { wep_set_anim(this, 40, w_ready); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail39(entity this) { wep_set_anim(this, 39, wep_railgun_rail40); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail38(entity this) { wep_set_anim(this, 38, wep_railgun_rail39); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail37(entity this) { wep_set_anim(this, 37, wep_railgun_rail38); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail36(entity this) { wep_set_anim(this, 36, wep_railgun_rail37); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail35(entity this) { wep_set_anim(this, 35, wep_railgun_rail36); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail34(entity this) { wep_set_anim(this, 34, wep_railgun_rail35); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail33(entity this) { wep_set_anim(this, 33, wep_railgun_rail34); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail32(entity this) { wep_set_anim(this, 32, wep_railgun_rail33); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail31(entity this) { wep_set_anim(this, 31, wep_railgun_rail32); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail30(entity this) { wep_set_anim(this, 30, wep_railgun_rail31); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail29(entity this) { wep_set_anim(this, 29, wep_railgun_rail30); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail28(entity this) { wep_set_anim(this, 28, wep_railgun_rail29); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail27(entity this) { wep_set_anim(this, 27, wep_railgun_rail28); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail26(entity this) { wep_set_anim(this, 26, wep_railgun_rail27); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail25(entity this) { wep_set_anim(this, 25, wep_railgun_rail26); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail24(entity this) { wep_set_anim(this, 24, wep_railgun_rail25); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail23(entity this) { wep_set_anim(this, 23, wep_railgun_rail24); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail22(entity this) { wep_set_anim(this, 22, wep_railgun_rail23); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail21(entity this) { wep_set_anim(this, 21, wep_railgun_rail22); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail20(entity this) { wep_set_anim(this, 20, wep_railgun_rail21); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail19(entity this) { wep_set_anim(this, 19, wep_railgun_rail20); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail18(entity this) { wep_set_anim(this, 18, wep_railgun_rail19); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail17(entity this) { wep_set_anim(this, 17, wep_railgun_rail18); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail16(entity this) { wep_set_anim(this, 16, wep_railgun_rail17); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail15(entity this) { wep_set_anim(this, 15, wep_railgun_rail16); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail14(entity this) { wep_set_anim(this, 14, wep_railgun_rail15); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail13(entity this) { wep_set_anim(this, 13, wep_railgun_rail14); this.weapon_nextthink = time + 0.05; _sound(this.owner, CH_WEAPON_SINGLE, "weapons/railwhirl2.wav", 0.5, ATTN_NORM); }
void wep_railgun_rail12(entity this) { wep_set_anim(this, 12, wep_railgun_rail13); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail11(entity this) { wep_set_anim(this, 11, wep_railgun_rail12); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail10(entity this) { wep_set_anim(this, 10, wep_railgun_rail11); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail9(entity this) { wep_set_anim(this, 9, wep_railgun_rail10); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail8(entity this) { wep_set_anim(this, 8, wep_railgun_rail9); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail7(entity this) { wep_set_anim(this, 7, wep_railgun_rail8); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail6(entity this) { wep_set_anim(this, 6, wep_railgun_rail7); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail5(entity this) { wep_set_anim(this, 5, wep_railgun_rail6); this.weapon_nextthink = time + 0.05; _sound(this.owner, CH_WEAPON_A, "weapons/railwhirl1.wav", 0.5, ATTN_NORM); }
void wep_railgun_rail4(entity this) { wep_set_anim(this, 4, wep_railgun_rail5); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail3(entity this) { wep_set_anim(this, 3, wep_railgun_rail4); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail2(entity this) { wep_set_anim(this, 2, wep_railgun_rail3); this.weapon_nextthink = time + 0.05; }
void wep_railgun_rail1(entity this) { wep_set_anim(this, 1, wep_railgun_rail2); this.weapon_nextthink = time + 0.05; }

void W_FireSniperLightning(entity this)
{
	if(this.t_width < time)
	{
		_sound(this, CH_WEAPON_A, "weapons/rail2.wav", 1, ATTN_NORM);
		this.t_width = time + 0.6;
	}
	this.punchangle_x = -4;
	W_TakeAmmo(this, ammo_cells, 10);
	this.effects |= EF_MUZZLEFLASH;

	makevectors(this.v_angle);

	vector org = this.origin + this.view_ofs - v_up*12 + v_right*8;
	traceline(org, org + v_forward * 32, false, this);
	org += v_forward * 32 * trace_fraction;

	vector dir = qc_aim(this, 4000);

	float lag = antilag_getlag(this);
	if(lag)
		antilag_takeback_all(this, lag);

	vector endpos = SniperLightningDamage(this, org, dir);
	DrawSniperLightning(this, org, endpos, 0);

	if(lag)
		antilag_restore_all(this);
}

vector SniperLightningDamage(entity this, vector org, vector dir)
{
	traceline(org, org + dir * 4000, false, this);
	vector endpoint = trace_endpos;
	entity tgt = trace_ent;

	int hits = 0;
	while(tgt && tgt.takedamage && tgt.health > 0 && hits < 5)
	{
		float dmg = floor(200 * (1 - hits / 6));	//grep_ee_const
		hits += 1;

		//ImpactSpawn(endpoint, '0 0 100', dmg, tgt.bloodtype);
		SpawnBlood(endpoint, '0 0 100', dmg, tgt);
		T_Damage(tgt, this, this, dmg, WEP_RAILGUN.m_id);
		if(IS_PLAYER(tgt))
			tgt.velocity_z += dmg * 2;

		if(tgt.solid == SOLID_BSP)
			break;

		traceline(endpoint, endpoint + dir*4000, false, tgt);
		if(trace_ent == this) // workaround in case the new trace hits the player
			traceline(endpoint + dir * 8, endpoint + dir * 4000, false, tgt);

		endpoint = trace_endpos;
		tgt = trace_ent;
	}

	return endpoint;
}

void SniperLightningSegmentThink(entity this)
{
	this.alpha = bound(0.0001, lerpCosine(1, 0, 1 - (this.attack_finished - time) / 0.5), 1);

	if(time > this.attack_finished)
		delete(this);
	else
		this.nextthink = time + 0.025;
}

void DrawSniperLightning(entity this, vector org, vector dest, float hit)
{
	float len = vlen(dest - org);
	vector dir = normalize(dest - org);
	vector ang = vectoangles(dest - org);

	entity sg = NULL;
	float ct = (len) ? floor(len / 30) : 0;
	for(int i = 0; i < ct; i++)
	{
		sg = spawn();

		_setmodel(sg, "progs/bolt2.mdl");
		setsize(sg, '0 0 0', '0 0 0');
		setorigin(sg, org + dir * 30 * i);

		//sg.flags = FL_PROJECTILE;
		sg.classname = "lgsegment";
		sg.effects = EF_FULLBRIGHT | EF_LOWPRECISION;
		sg.angles = ang;
		sg.angles_z = random()*360;
		sg.owner = this;
		sg.realowner = this;
		setthink(sg, SniperLightningSegmentThink);
		sg.attack_finished = time + 0.5 + 0.005 * i;
		sg.nextthink = time + 0.02;
		sg.alpha = 0.9;
		sg.state = hit;
		sg.cnt = i;
	}
	// add an effect to the impact site
	if(sg)
		sg.effects |= EF_MUZZLEFLASH;
}

METHOD(Railgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_railgun_rail1(actor.(weaponentity));
		W_FireSniperLightning(actor);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.5);
	}
}
METHOD(Railgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_cells >= 10;
	return ammo_amount;
}
METHOD(Railgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Railgun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
