#include "nuke.qh"

#ifdef SVQC
PRECACHE(Nuke)
{
	precache_model("progs/v_nuke.mdl");
	precache_model("progs/g_nuke.mdl");

	precache_model("progs/nuke.mdl");
	precache_model("models/sphere/sphere.md3");

	precache_sound("equake/rumble.wav");
}

void nuke_explode_think(entity this)
{
	this.nextthink = time + 0.1;

	if(time >= this.attack_finished)
	{
		earthquake_active = false;
		stopsound(this, CH_TRIGGER_SINGLE);
		delete(this);
		return;
	}

	if(time >= this.wait)
	{
		this.wait = time + 1;
		_sound(this, CH_TRIGGER_SINGLE, "equake/rumble.wav", 1, ATTN_NONE);
	}

	if(time >= this.dmgtime)
	{
		T_RadiusDamage(this, this.realowner, 250 * this.scale2, WEP_NUKE.m_id, NULL);
		this.dmgtime = time + 0.25;
	}

	this.scale2 += 0.1;
}

void nuke_think(entity this)
{
	setthink(this, nuke_think);
	this.nextthink = time;

	if(this.wait && time > this.wait)
	{
		this.classname = "nuke_explosion";
		earthquake_active = true;
		earthquake_intensity = 20;
		this.attack_finished = time + 3.5;
		sound(this, CH_WEAPON_SINGLE, SND_NUKE_EXPLODE_RANDOM(), 1, 0.1);
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, this.origin, '0 0 0', '0 0 0', '0 0 0', 0, 800, 0.2, 1, 5);
		Send_Effect(EFFECT_NUKE_EXPLODE, this.origin + '0 0 16', '0 0 0', 1);
		set_movetype(this, MOVETYPE_NONE);
		setthink(this, nuke_explode_think);
		this.nextthink = time;
		setmodel(this, MDL_Null);
		setsize(this, '0 0 0', '0 0 0');
		return;
	}
}

void nuke_setup(entity this)
{
	this.classname = "nuke";
	//set_movetype(this, MOVETYPE_NONE);
	this.owner = NULL; // to allow collisions
	setthink(this, nuke_think);
	this.nextthink = time + 0.1;
	this.solid = SOLID_TRIGGER;
	settouch(this, func_null);
}

void nuke_projectile_touch(entity this, entity toucher)
{
	if(toucher && toucher.solid != SOLID_BSP)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	// TODO: bumping sound?
}

void nuke_projectile_think(entity this)
{
	this.nextthink = time;
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	if(!IS_ONGROUND(this))
		return;

	sound(this, CH_WEAPON_B, SND_NUKE_LAND, 1, ATTN_NORM);
	nuke_setup(this);
	this.attack_finished = time + 0.5;
	this.dmg = 2000;
	this.speed = 2000;
	this.wait = time + 7;
}

void W_DropNuke(entity this, .entity weaponentity)
{
	if(!StatusEffects_active(STATUSEFFECT_SharpShooter, this))
	{
		// add a delay to every weapon slot when dropping a nuke to prevent instant fires
		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity w_ent = weaponentities[slot];
			if(this.(w_ent) && slot != weaponslot(weaponentity))
				ATTACK_FINISHED(this, w_ent) = time + 0.5;
		}
		STAT(WEAPONS, this) &= ~WEP_NUKE.m_wepset;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
	}

	sound(this, CH_WEAPON_B, SND_NUKE_DROP, 1, ATTN_NORM);

	entity nuke = spawn();
	nuke.classname = "nuke_projectile";
	nuke.owner = this;
	nuke.realowner = this;
	set_movetype(nuke, MOVETYPE_TOSS);
	nuke.solid = SOLID_BBOX;
	setmodel(nuke, MDL_NUKE);
	//setsize(nuke, '-8 -8 -16', '8 8 8');
	vector cmin = this.mins, cmax = this.maxs;
	// some basic sanity, but otherwise use player's hitbox to avoid exploits
	cmin.z = -16;
	cmax.z = 32;
	setsize(nuke, cmin, cmax);
	settouch(nuke, nuke_projectile_touch);
	setthink(nuke, nuke_projectile_think);
	nuke.wait = time + 3;
	nuke.nextthink = time;

	vector org = this.origin + (this.view_ofs * 0.75);
	setorigin(nuke, org);
	nuke.angles = this.angles;
	nuke.pos2 = nuke.angles;
	makevectors(this.angles);
	nuke.velocity = v_forward * 200 + v_up * 20;
}

METHOD(Nuke, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_DropNuke(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.5);
	}
}
METHOD(Nuke, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // no ammo
}
METHOD(Nuke, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_NUKE_SUICIDE;
}
METHOD(Nuke, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
