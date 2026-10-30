#include "bishop.qh"

#ifdef SVQC
void W_Bishop_Attack_Bolt(entity this, .entity weaponentity);

void s_pexplode1(entity this);

void wep_bishop_blast4(entity this) { wep_set_anim(this, 7, w_ready); }
void wep_bishop_blast3(entity this) { wep_set_anim(this, 6, wep_bishop_blast4); }
void wep_bishop_blast2(entity this) { wep_set_anim(this, 5, wep_bishop_blast3); }
void wep_bishop_blast1(entity this) { wep_set_anim(this, 4, wep_bishop_blast2); }

void wep_bishop_bolt3(entity this) { wep_set_anim(this, 3, w_ready); }
void wep_bishop_bolt2(entity this) { wep_set_anim(this, 2, wep_bishop_bolt3); W_Bishop_Attack_Bolt(this.owner, this.weaponentity_fld); }
void wep_bishop_bolt1(entity this) { wep_set_anim(this, 1, wep_bishop_bolt2); }

PRECACHE(Bishop)
{
	precache_model("progs/g_bishop.mdl");
	precache_model("progs/v_bishop.mdl");

	precache_model("progs/king.mdl");
	precache_model("progs/s_plasma.spr");
	precache_model("progs/proj_ringshock.mdl"); // unused but let's silence it!
	precache_model("progs/bishop_ring.mdl");
}

void bishop_bolt_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;   // don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	if(toucher.takedamage)
	{
		float damage = (this.dmg) ? this.dmg : 10;
		T_Damage(toucher, this, this.owner, damage, this.projectiledeathtype);
	}

	this.origin = this.origin - 8*normalize(this.velocity);

	sound(this, CH_SHOTS, SND_Bishop_Impact_Random(), 1, ATTN_NORM);

	Send_Effect(EFFECT_BISHOP_BOLT_EXPLODE, this.origin, '0 0 0', 1);

	delete(this);
}

void W_Bishop_Attack_Bolt(entity this, .entity weaponentity)
{
	if(STAT(MANA, this) < 10)
		return; // incase it got drained
	W_TakeMana(this, 10);

	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -6 + v_right * 4;

	tracebox(this.origin, '0 0 0', '0 0 0', offset, MOVE_NORMAL, this);
	vector neworg = trace_endpos;

	float pspeed = 500;
	float pdamage = 9;
	float ptime = 8;
	vector dir = qc_aim(this, pspeed);
	int scount = 6;

	for(int j = 0; j < scount; ++j)
	{
		entity newmis = spawn();
		newmis.flags = FL_PROJECTILE;
		newmis.owner = this;
		newmis.realowner = this;
		set_movetype(newmis, MOVETYPE_FLYMISSILE);
		newmis.solid = SOLID_CORPSE;
		newmis.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		newmis.classname = "bishop_bolt";
		newmis.projectiledeathtype = WEP_BISHOP.m_id | HITTYPE_MAGIC;
		newmis.clipgroup = this.clipgroup;

		settouch(newmis, bishop_bolt_touch);
		newmis.dmg = pdamage;

		setthink(newmis, SUB_Remove);
		newmis.nextthink = time + ptime;

		setsize(newmis, '0 0 0', '0 0 0');
		setorigin(newmis, neworg);

		vector spread = '0.025 0.025 0';
		float spread_side = (j * spread.x);
		float spread_up = (j * spread.y);
		vector right = v_right;
		vector spread_dir = dir + (spread_side - ((scount * spread.x) * 0.5)) * right + (spread_up - ((scount * spread.y) * 0.5)) * v_up;
		newmis.velocity = spread_dir * pspeed;

		IL_PUSH(g_projectiles, newmis);

		CSQCProjectile(newmis, true, PROJECTILE_BISHOP_BOLT, true);
	}
}

void king_think(entity this)
{
	this.nextthink = time + 0.1;

	this.walkframe += 1;

	if(this.walkframe >= 4)
	{
		this.walkframe = 4;
		
		entity shockwave = ai_shockwave_fromsource(this, this.realowner, '0 0 0', 110, 210, 240, 75, this.projectiledeathtype, SND(Null));
		shockwave.mdl = "progs/bishop_ring.mdl";
		_setmodel(shockwave, shockwave.mdl);
		setsize(shockwave, '0 0 0', '0 0 0');
		sound(this, CH_SHOTS, SND_Bishop_Blast_Random(), 1, ATTN_NORM);

		SUB_SetFade(this, time + 0.1, 2);
	}

	this.frame = this.walkframe;
}

void bishop_king_launch(entity this)
{
	W_TakeMana(this, 50);

	makevectors(this.angles);

	vector myorg = this.origin;
	myorg.z += this.mins_z; // ground it!

	traceline(myorg, myorg + v_forward * 64, MOVE_NORMAL, this);

	vector org = trace_endpos;

	entity king = spawn();
	king.classname = "king";
	king.owner = this;
	king.realowner = this;
	king.solid = SOLID_NOT;
	king.projectiledeathtype = WEP_BISHOP.m_id | HITTYPE_MAGIC;
	set_movetype(king, MOVETYPE_NONE);
	setorigin(king, org);
	_setmodel(king, "progs/king.mdl");
	setsize(king, '-32 -32 0', '32 32 128');
	king.colormod = '0.49 0.97 1';
	//king.avelocity = '0 270 0';
	king.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	king.frame = 0;
	king.walkframe = 0;
	setthink(king, king_think);
	king.nextthink = time + 0.1;
}

METHOD(Bishop, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(!(fire & 1))
		actor.(weaponentity).count = 0;

	// checking secondary first as a page swap prevents attacking
	if(fire & 2)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(STAT(MANA, actor) >= 50)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		bishop_king_launch(actor);
		wep_bishop_blast1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 1.5);
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	if(STAT(MANA, actor) >= 10)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		sound(actor, CH_WEAPON_A, SND_Bishop_Fire_Random(), 1, ATTN_NORM);
		wep_bishop_bolt1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.7);
	}
}
METHOD(Bishop, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Bishop, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Bishop, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
