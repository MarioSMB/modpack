#include "super_lightning.qh"

#ifdef SVQC
void W_SuperLightning_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(actor.ammo_cells < 1)
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		_sound(actor, CHAN_WEAPON, "misc/power.wav", 1, ATTN_NORM);
		actor.ammo_cells = 0;
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		W_SetCurrentAmmo(actor);
		W_SwitchWeapon(actor, w_getbestweapon(actor, weaponentity), weaponentity);
		return;
	}
	ATTACK_FINISHED(actor, weaponentity) = time + 0.1;

	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	this.misc_bulletcounter += 1;

	if((this.misc_bulletcounter % 2) == 0)
		_sound(actor, CHAN_AUTO, "weapons/light2/lgstart1.wav", 1, ATTN_NORM);

	if(IS_PLAYER(actor))
		player_light1(actor);

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 5)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_SuperLightning_Attack);
	SuperDamageSound(actor);
	W_FireSuperLightning(actor, weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.1;
}

void superlightning_rebound(entity this)
{
	//this.owner = this.owner;
	_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lghit.wav", 1, ATTN_NORM);
	this.velocity = normalize(this.velocity);
	this.velocity = this.velocity * 1000;
	set_movetype(this, MOVETYPE_FLYMISSILE);
	this.angles = vectoangles(this.velocity);
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.4;
	spawn_touchspark(this, 1);
	this.bounced = this.bounced + 1;
	if(this.bounced == 5)
	{
		delete(this);
		return;
	}
	if(!(this.flags & FL_INWATER))
	{
		if(this.watertype == CONTENT_WATER)
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis1.wav", 1, ATTN_NORM);
			SpawnDischarge(this, 200);
			SpawnDischarge(this, 200);
			SpawnDischarge(this, 200);
			T_RadiusDamage(this, this.owner, 200, this.projectiledeathtype, NULL);
			delete(this);
			return;
		}
		if(this.watertype == CONTENT_SLIME)
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis2.wav", 1, ATTN_NORM);
			SpawnDischarge(this, 150);
			SpawnDischarge(this, 150);
			T_RadiusDamage(this, this.owner, 150, this.projectiledeathtype, NULL);
			delete(this);
			return;
		}
		if(this.watertype == CONTENT_LAVA)
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis3.wav", 1, ATTN_NORM);
			SpawnDischarge(this, 100);
			SpawnDischarge(this, 100);
			T_RadiusDamage(this, this.owner, 100, this.projectiledeathtype, NULL);
			delete(this);
			return;
		}
	}
	this.owner = NULL;
}

void LightningTouch(entity this, entity toucher)
{
	if(toucher.solid == SOLID_TRIGGER)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	if(IS_PLAYER(this.realowner) && IS_PLAYER(toucher) && toucher != this.realowner && (!Damage_ValidTarget(toucher, this.realowner) || toucher.tank))
	{
		set_movetype(this, MOVETYPE_BOUNCE);
		setthink(this, superlightning_rebound);
		this.ltime = this.nextthink;
		this.nextthink = time + 0.1;
		return;
	}
	if(toucher.takedamage && !(toucher.monsterdef.spawnflags & MON_FLAG_METAL) && !toucher.tank)
	{
		if(toucher.takedamage == DAMAGE_AIM)
			spawn_extrablood(this, toucher, 1000); // TODO: toucher?
		float damg = 16;
		if(StatusEffects_active(STATUSEFFECT_Quad, this.owner) && toucher.health <= (damg * 4))
		{
			if(toucher.move_movetype == MOVETYPE_PUSH)
			{
				T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
				return;
			}
			if(toucher.classname == "door")
			{
				T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
				return;
			}
			if(toucher.move_movetype == MOVETYPE_NONE)
			{
				T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
				return;
			}
			if(!IS_PLAYER(toucher))
				toucher.owner = this.owner;
			else
				toucher.enemy = this.owner;
			delete(this);
			toucher.takedamage = DAMAGE_NO;
			setthink(toucher, gibhim);
			toucher.nextthink = time;
			return;
		}
		if(toucher.health <= damg)
		{
			if(toucher.move_movetype == MOVETYPE_PUSH)
			{
				T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
				return;
			}
			if(toucher.classname == "door")
			{
				T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
				return;
			}
			if(toucher.move_movetype == MOVETYPE_NONE)
			{
				T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
				return;
			}
			// TODO: generic way of telling if a target can actually be hurt
			if(toucher.charmed && (IS_PLAYER(this.owner) || this.owner == toucher.charmer || this.owner.charmer == toucher.charmer))
				return; // no hurting our pets!

			if(this.owner.charmed && (IS_PLAYER(toucher) || toucher == this.owner.charmer || toucher.charmer == this.owner.charmer))
				return; // no hurting us either!

			if(!IS_PLAYER(toucher))
				toucher.owner = this.owner;
			else
				toucher.enemy = this.owner;
			delete(this);
			toucher.takedamage = DAMAGE_NO;
			setthink(toucher, gibhim);
			toucher.nextthink = time;
			return;
		}
		else
		{
			T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
			if(toucher.takedamage == DAMAGE_AIM)
				SpawnMeatBounce(this, toucher, damg);
			delete(this);
		}
	}
	else
	{
		// if we're already rebounding, abort to avoid doubling back!
		if(time < this.nextthink && getthink(this) == superlightning_rebound)
			return;
		set_movetype(this, MOVETYPE_BOUNCE);
		setthink(this, superlightning_rebound);
		this.ltime = this.nextthink;
		this.nextthink = time + 0.1;
		return;
	}
}

void W_FireSuperLightning(entity this, .entity weaponentity)
{
	float r = random();
	if(this.waterlevel > 1)
	{
		float cells = this.ammo_cells;
		this.ammo_cells = 0;
		W_SetCurrentAmmo(this);
		T_RadiusDamage(this, this, 35 * cells, DEATH_DISCHARGE.m_id, NULL);
		return;
	}
	W_TakeAmmo(this, ammo_cells, 1);
	this.punchangle_x = -2;
	entity missile = new(lightme);
	missile.owner = missile.realowner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 2000);
	missile.velocity = missile.velocity * 2000;
	missile.angles = vectoangles(missile.velocity);
	missile.projectiledeathtype = WEP_LIGHTME.m_id;
	settouch(missile, LightningTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	if(this.lightningmodel == 1)
	{
		if(r <= 0.3)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgstart2.wav", 1, ATTN_NORM);
		else if(r <= 0.6)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgstart3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgstart1.wav", 1, ATTN_NORM);
		_setmodel(missile, "progs/bolt2.mdl");
		this.lightningmodel = 0;
	}
	else if(this.lightningmodel == 0)
	{
		_setmodel(missile, "progs/bolt.mdl");
		this.lightningmodel = 1;
	}
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, W_Shotorg(this, weaponentity)); // lol what
}

METHOD(SuperLightning, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		actor.(weaponentity).misc_bulletcounter = 0;
		W_SuperLightning_Attack(actor.(weaponentity));
		if(actor.ammo_cells < 1)
		{
			actor.ammo_cells = 0;
			W_SetCurrentAmmo(actor);
		}
	}
}
METHOD(SuperLightning, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_cells >= 1;
	return ammo_amount;
}
METHOD(SuperLightning, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
