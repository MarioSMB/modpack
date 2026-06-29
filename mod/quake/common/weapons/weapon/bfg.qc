#include "bfg.qh"

#ifdef CSQC
.vector vorg1, vorg2;
void BFGZap_Draw(entity this)
{
	string tex;
	tex = "particles/lgbeam";
	//tex = "particles/gauntletbeam";

	float remaining = this.nextthink - time;

	Draw_CylindricLine(this.vorg1, this.vorg2, 6, tex, 0.25, -time * 3, '0 1 0', bound(0, remaining, 1), DRAWFLAG_NORMAL, view_origin);
}

NET_HANDLE(TE_CSQC_BFGZAP, bool isNew)
{
	Net_Accept(lightning);
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.2;
	this.draw = BFGZap_Draw;
	if (isNew) IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	this.vorg1 = ReadVector();
	this.vorg2 = ReadVector();

	return true;
}
#elif defined(SVQC)
void SendCSQCBFGZap(vector v1, vector v2)
{
	WriteHeader(MSG_BROADCAST, TE_CSQC_BFGZAP);
	WriteVector(MSG_BROADCAST, v1);
	WriteVector(MSG_BROADCAST, v2);
}
#endif

#ifdef SVQC
PRECACHE(BFG)
{
	precache_model("progs/v_bfg.mdl");
	precache_model("progs/g_bfg.mdl");

	precache_model("progs/s_bfg.spr");
	precache_model("progs/proj_bfg_shock.mdl");

	precache_sound("weapons/bfgcharge.wav");
	precache_sound("weapons/bfgexplode.wav");
	precache_sound("weapons/bfgfire.wav");

	precache_sound("weapons/plasma_hit.wav");
}

void W_FireBFG(entity this, .entity weaponentity);

void wep_bfg_fire10(entity this) { wep_set_anim(this, 10, w_ready); }
void wep_bfg_fire9(entity this) { wep_set_anim(this, 9, wep_bfg_fire10); }
void wep_bfg_fire8(entity this) { wep_set_anim(this, 8, wep_bfg_fire9); }
void wep_bfg_fire7(entity this) { wep_set_anim(this, 7, wep_bfg_fire8); }
void wep_bfg_fire6(entity this) { wep_set_anim(this, 6, wep_bfg_fire7); W_FireBFG(this.owner, this.weaponentity_fld); }
void wep_bfg_fire5(entity this) { wep_set_anim(this, 5, wep_bfg_fire6); }
void wep_bfg_fire4(entity this) { wep_set_anim(this, 4, wep_bfg_fire5); }
void wep_bfg_fire3(entity this) { wep_set_anim(this, 3, wep_bfg_fire4); }
void wep_bfg_fire2(entity this) { wep_set_anim(this, 2, wep_bfg_fire3); }
void wep_bfg_fire1(entity this) { wep_set_anim(this, 1, wep_bfg_fire2); _sound(this.owner, CH_WEAPON_SINGLE, "weapons/bfgcharge.wav", 1, ATTN_NORM); }

void s_bfgexplode(entity this)
{
	setthink(this, s_bfgexplode);
	this.nextthink = time + 0.1;
	this.frame += 1;

	if(this.frame > 12)
		delete(this);
}

void BFGExplosion(vector org)
{
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/proj_bfg_shock.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
	newmis.frame = 0;
	newmis.effects = EF_FULLBRIGHT;
	newmis.alpha = 0.5;
	s_bfgexplode(newmis);
}

void s_bfgzap3(entity this) { set_anim(this, 3, SUB_Remove); }
void s_bfgzap2(entity this) { set_anim(this, 2, s_bfgzap3); }
void s_bfgzap1(entity this) { set_anim(this, 1, s_bfgzap2); }

void BFGZapSprite(vector org)
{
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/s_bfg.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
	newmis.effects = EF_FULLBRIGHT;
	s_bfgzap1(newmis);
}

void BFG_ZapTarget(entity this, entity targ)
{
	BFGZapSprite(targ.origin);

	float damage = 50;
	T_Damage(targ, this, this.owner, damage, this.projectiledeathtype);
}

void BFG_GroundOut(entity this)
{
	FOREACH_ENTITY_RADIUS(this.origin, 500, it.takedamage && it != this.owner && Damage_ValidTarget(it, this.owner),
	{
		// need line of sight
		if(!checkpvs(this.origin, it))
			continue;

		vector targ_org = (it.absmin + it.absmax) * 0.5;
		SendCSQCBFGZap(this.origin, targ_org);
		BFG_ZapTarget(this, it);
	});
}

void BFGTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	_sound(this, CH_SHOTS, "weapons/bfgexplode.wav", 1, ATTN_NORM);
	
	if(toucher.takedamage)
	{
		float damg = 250 + random()*20;
		if(IS_MONSTER(this.owner))
			damg = 60;
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	float rdmg = 320;
	if(IS_MONSTER(this.owner))
		rdmg = 50; // lower base damage for monsters
	T_RadiusDamage(this, this.owner, rdmg, this.projectiledeathtype, toucher);

	// Moves the plasma bullet backwards after hitting.. Otherwise the 
	// explosion sprite would often be inside a wall or something. 
	this.origin = this.origin - 8*normalize(this.velocity);

	BFGExplosion(this.origin);

	if(IS_PLAYER(this.owner))
		BFG_GroundOut(this);

	delete(this);
}

void bfg_zapnearby(entity this)
{
	int cont = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(this.origin));
	if(cont & DPCONTENTS_LIQUIDSMASK)
	{
		T_RadiusDamage(this, this.owner, 120, this.projectiledeathtype, NULL);
		setthink(this, SUB_Remove);
		return;
	}

	int hitenemy = 0;
	FOREACH_ENTITY_RADIUS(this.origin, 300, hitenemy < 3,
	{
		if(!it.takedamage || it == this.owner || !Damage_ValidTarget(it, this.owner))
			continue;

		vector targ_org = (it.absmin + it.absmax) * 0.5;
		SendCSQCBFGZap(this.origin, targ_org);
		T_Damage(it, this, this.owner, 25, this.projectiledeathtype);
		hitenemy += 1;
	});
}

void bfg_think(entity this)
{
	this.nextthink = time + 0.1;

	if(time >= this.cnt)
	{
		delete(this);
		return;
	}

	if(time > this.delay)
	{
		this.delay = time + 0.2;
		bfg_zapnearby(this);
	}
}

entity launch_plasma(entity this, vector org, vector dir);
void W_FireBFG(entity this, .entity weaponentity)
{
	if(this.ammo_cells < 2)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	this.effects |= EF_MUZZLEFLASH;

	W_TakeAmmo(this, IT_CELLS, 10);
	_sound(this, CH_WEAPON_SINGLE, "weapons/bfgfire.wav", 1, ATTN_NORM);
	this.punchangle_x = -4 * autocvar_sv_quake_recoil;

	makevectors(this.v_angle);
	vector org = W_Shotorg(this, weaponentity);
	vector dir = qc_aim_fromorg(this, org, 500);

	entity plasma = launch_plasma(this, org, dir);
	plasma.projectiledeathtype = WEP_BFG.m_id;
	setthink(plasma, bfg_think);
	plasma.nextthink = time;
	plasma.cnt = time + 16;
	plasma.velocity = dir * 500;
	settouch(plasma, BFGTouch);

	CSQCProjectile(plasma, true, PROJECTILE_BFG, true);
}

METHOD(BFG, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_bfg_fire1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 2);
	}
}
METHOD(BFG, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_cells >= 10;
	return ammo_amount;
}
METHOD(BFG, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(BFG, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
