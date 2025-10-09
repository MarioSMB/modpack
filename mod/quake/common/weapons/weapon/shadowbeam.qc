#include "shadowbeam.qh"

#ifdef SVQC
void wep_shadowbeam_shot2(entity this) { wep_set_anim(this, 2, w_ready); }
void wep_shadowbeam_shot1(entity this) { wep_set_anim(this, 1, wep_shadowbeam_shot2); this.owner.effects |= EF_MUZZLEFLASH; }

PRECACHE(Shadowbeam)
{
	precache_model("progs/v_shadowbeam.mdl");
	precache_model("progs/g_shadowbeam.mdl");

	precache_sound("weapons/shadowbeam_fire.wav");
}

void SendCSQCShadowbeam(vector v1, vector v2)
{
	WriteHeader(MSG_BROADCAST, TE_CSQC_SHADOWBEAM);
	WriteVector(MSG_BROADCAST, v1);
	WriteVector(MSG_BROADCAST, v2);
}

void W_Shadowbeam_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	if(IS_PLAYER(actor))
		player_nail1(actor);

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame > 5)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_Shadowbeam_Attack);
	SuperDamageSound(actor);
	W_FireShadowbeam(actor, weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

.float shadowbeamhit;
float ShadowbeamDamage(entity this, float damage, float arange, vector org, vector dir)
{
	traceline(org, org + dir * arange, false, this);
	vector endpoint = trace_endpos;
	vector endplane = trace_plane_normal;
	entity tgt = trace_ent;

	while(tgt && tgt.takedamage && tgt.health > 0 && time > tgt.shadowbeamhit && damage > 0)
	{
		damage = floor(damage * 0.9); // 10% reduction every target hit

		//ImpactSpawn(endpoint, '0 0 100', damage, tgt.bloodtype);
		SpawnBlood(endpoint, '0 0 100', damage, tgt);
		T_Damage(tgt, this, this, damage, WEP_SHADOWBEAM.m_id);
		tgt.shadowbeamhit = time; // prevent multiple hits in the same frame

		if(tgt.solid == SOLID_BSP)
			break;

		traceline(endpoint, endpoint + dir*arange, false, tgt);
		if(trace_ent == this) // workaround in case the new trace hits the player
			traceline(endpoint + dir * 8, endpoint + dir * arange, false, tgt);

		endpoint = trace_endpos;
		endplane = trace_plane_normal;
		tgt = trace_ent;
	}

	trace_endpos = endpoint;
	trace_plane_normal = endplane;

	return damage;
}

void W_FireShadowbeam(entity this, .entity weaponentity)
{
	W_TakeMana(this, 7);
	_sound(this, CH_WEAPON_SINGLE, "weapons/shadowbeam_fire.wav", 1, ATTN_NORM);

	makevectors(this.v_angle);

	float lag = antilag_getlag(this);
	if(lag)
		antilag_takeback_all(this, lag);

	vector org = W_Shotorg(this, weaponentity);
	vector dir = qc_aim(this, 4000);
	float blength = 1225; // max length of the beam, bounces included
	float damage = 60;

	// limit the max bounces regardless
	for(int j = 0; j < 64; ++j)
	{
		vector oldorg = org;
		damage = ShadowbeamDamage(this, damage, blength, org, dir);
		org = trace_endpos;
		SendCSQCShadowbeam(oldorg, org);

		if((trace_dphitcontents & DPCONTENTS_SKY) || pointcontents(org) == CONTENT_SKY)
			break;

		blength -= vlen(org - oldorg);
		if(blength <= 0)
			break;
		vector vel = normalize(org - oldorg) * 1000;
		dir = normalize(_Movetype_ClipVelocity(vel, trace_plane_normal, 2));
	}

	if(lag)
		antilag_restore_all(this);
}

METHOD(Shadowbeam, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	if(STAT(MANA, actor) >= 7)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_shadowbeam_shot1(actor.(weaponentity));
		W_FireShadowbeam(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Shadowbeam, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // uses mana
}
METHOD(Shadowbeam, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Shadowbeam, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
NET_HANDLE(TE_CSQC_SHADOWBEAM, bool isNew)
{
	vector shotorg = ReadVector();
	vector endpos = ReadVector();

	entity eff = EFFECT_TR_SHADOWBEAM;

	int eff_flags = PARTICLES_DRAWASTRAIL;

	vector rgb = '0.7 0.23 0.53';
	particles_colormin = particles_colormax = rgb;
	eff_flags |= PARTICLES_USECOLOR;

	if(!SpawnParticles_list_full(strcat("cl_particle_", eff.eent_eff_name), shotorg, endpos, '0 0 0', '0 0 0', 1, true, PARTICLES_DRAWASTRAIL))
		boxparticles(particleeffectnum(EFFECT_GUARDIAN_BEAM), NULL, shotorg, endpos, '0 0 0', '0 0 0', 1, eff_flags);

	return true;
}
#endif
