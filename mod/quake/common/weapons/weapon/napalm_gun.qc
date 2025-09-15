#include "napalm_gun.qh"

#ifdef SVQC
bool inside_nradius;

void NapalmFlameThink(entity this)
{
	if(!(this.flags & FL_INWATER) && this.cnt == 0)
	{
		if(this.watertype == CONTENT_WATER || this.watertype == CONTENT_SLIME || this.watertype == CONTENT_LAVA)
		{
			BecomeExplosion(this);
			return;
		}
	}
	if(inside_nradius)
	{
		error("NapalmFlameThink: recursive");
		return;
	}
	inside_nradius = true;
	entity head = findradius(this.origin, 55);
	while(head)
	{
		if(head.takedamage)
			T_Damage(head, this, this.owner, 2 + (random() * 4), this.projectiledeathtype);
		head = head.chain;
	}
	inside_nradius = false;
	this.nextthink = time + 0.35;
	this.cnt += 1;
	if(this.cnt >= 10 + random() * 5)
	{
		this.cnt = 0;
		BecomeExplosion(this);
		return;
	}
	setthink(this, NapalmFlameThink);
}

void napalmrebound(entity this)
{
	if(!(this.flags & FL_INWATER))
	{
		if(this.watertype == CONTENT_WATER || this.watertype == CONTENT_SLIME || this.watertype == CONTENT_LAVA)
		{
			sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
			BecomeExplosion(this);
			return;
		}
	}
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	SpawnFireSpark(this);
	SpawnFireSpark(this);
	SpawnFireSpark(this);
	BecomeExplosion(this);
}

void NapalmTouch(entity this, entity toucher)
{
	if(toucher.takedamage && toucher.takedamage == DAMAGE_AIM && !(toucher.monsterdef.spawnflags & MON_FLAG_METAL) && !(toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
			T_Damage(toucher, this, this.owner, 110, this.projectiledeathtype);
		else
		{
			entity missile = SpawnInternalFire(this, toucher);
			missile.projectiledeathtype = WEP_NAPALM.m_id;
		}
	}
	setorigin(this, this.origin - 8 * normalize(this.velocity));
	setthink(this, napalmrebound);
	this.ltime = this.nextthink;
	this.nextthink = time;
}

void W_FireNapalm(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, ammo_rockets, 1);
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);
	this.punchangle_x = -2;
	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_NAPALM.m_id;
	missile.clipgroup = this.clipgroup;
	missile.classname = "flame";
	missile.takedamage = DAMAGE_NO;
	makevectors(this.v_angle);
	if(this.v_angle_x)
		missile.velocity = v_forward * 800 + v_up * 250 + crandom() * v_right * 10 + crandom() * v_up * 10;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, NapalmTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/nbomb.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, W_Shotorg(this, weaponentity));

	IL_PUSH(g_projectiles, missile);
}

METHOD(NapalmGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(actor.(weaponentity).misc_bulletcounter < 3)
		{
			if(IS_PLAYER(actor))
				player_rocket1(actor);
			wep_generic_rocket1(actor.(weaponentity));
			W_FireNapalm(actor, weaponentity);
			weapon_prepareattack(thiswep, actor, weaponentity, 0.6);
			actor.(weaponentity).misc_bulletcounter += 1;
		}
		else
		{
			_sound(actor, CH_WEAPON_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
			weapon_prepareattack(thiswep, actor, weaponentity, 0.9);
			actor.(weaponentity).misc_bulletcounter = 0;
		}
	}
}
METHOD(NapalmGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(NapalmGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(NapalmGun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
