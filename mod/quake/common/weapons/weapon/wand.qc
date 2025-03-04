#include "wand.qh"

#ifdef SVQC
PRECACHE(Wand)
{
	precache_model("progs/v_wand.mdl");
	precache_model("progs/g_wand.mdl");

	precache_model("progs/v_spike.mdl");
	precache_sound("shalrath/attack2.wav");
}

void W_FireWand(entity this, .entity weaponentity);
void wep_wand_shot6(entity this) { wep_set_anim(this, 6, w_ready); }
void wep_wand_shot5(entity this) { wep_set_anim(this, 5, wep_wand_shot6); }
void wep_wand_shot4(entity this) { wep_set_anim(this, 4, wep_wand_shot5); W_FireWand(this.owner, this.weaponentity_fld); }
void wep_wand_shot3(entity this) { wep_set_anim(this, 3, wep_wand_shot4); this.owner.effects |= EF_MUZZLEFLASH; }
void wep_wand_shot2(entity this) { wep_set_anim(this, 2, wep_wand_shot3); _sound(this.owner, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM); }
void wep_wand_shot1(entity this) { wep_set_anim(this, 1, wep_wand_shot2); }

void WandHome(entity this)
{
	if(this.enemy && (this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET)))
		this.enemy = NULL;
	if(time > this.count)
	{
		delete(this);
		return;
	}

	if(!this.enemy && time > this.cnt)
	{
		this.enemy = W_PickNearbyTarget(this, this.owner, 500, false, false);
		this.cnt = time + 0.33; // don't spam it!
	}

	if(this.enemy)
	{
		vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
		this.velocity = dir * 250;
	}

	this.nextthink = time + 0.2;
	setthink(this, WandHome);
}

void WandMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this, 110, this.projectiledeathtype);
	T_RadiusDamage(this, this.owner, 80, this.projectiledeathtype, NULL);
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	this.velocity = '0 0 0';
	settouch(this, func_null);
	setmodel(this, MDL_EXPLOSION);
	this.solid = SOLID_NOT;
	setsize(this, '0 0 0', '0 0 0');
	s_explode1(this);
}

void W_FireWand(entity this, .entity weaponentity)
{
	W_TakeMana(this, 10);
	vector dir = qc_aim(this, 500);
	
	entity missile = spawn();
	missile.classname = "vore_ball";
	missile.owner = missile.realowner = this;
	missile.projectiledeathtype = WEP_WAND.m_id;
	missile.clipgroup = this.clipgroup;

	missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	_setmodel(missile, "progs/v_spike.mdl");
	setsize(missile, '0 0 0', '0 0 0');

	setorigin(missile, this.origin + this.view_ofs);

	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = time;
	missile.count = time + 10;
	missile.cnt = time + 0.33;
	setthink(missile, WandHome);
	settouch(missile, WandMissileTouch);
}

METHOD(Wand, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 10)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_wand_shot1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.75);
	}
}
METHOD(Wand, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true;
}
METHOD(Wand, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Wand, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
