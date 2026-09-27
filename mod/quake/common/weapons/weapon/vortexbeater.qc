#include "vortexbeater.qh"

#ifdef SVQC
PRECACHE(VortexBeater)
{
	precache_model("progs/v_vortexbeater.mdl");
	precache_model("progs/g_vortexbeater.mdl");

	precache_sound("weapons/vortexbeater_fire.wav");
	precache_sound("weapons/vortexbeater_explode.wav");
}

void W_VortexBeater_Attack(entity this)
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
	if(this.m_frame > 6)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_VortexBeater_Attack);
	this.weapon_nextthink = time + 0.1;
	SuperDamageSound(actor);
	vector org = W_Shotorg(actor, weaponentity) + v_right * 8;
	W_FireVortexBeater(actor, weaponentity, org);

	// check for a weapon swap
	if(this.m_weapon == WEP_VORTEXBEATER && time >= this.attack2_finished)
	{
		this.attack2_finished = time + 0.5;
		W_FireVortexBeaterRocket(actor, weaponentity, org);
	}
}

void vortexbeater_bullet_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		spawn_touchblood(this, 18, toucher);
		float damg = 18;
		if(toucher.resist_nails != 0)
			damg = Resist_Damage(toucher, IT_NAILS, damg);
		Resist_Nails(toucher, this.origin);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
	else
		te_superspike(this.origin);

	delete(this);
}

void W_FireVortexBeater(entity this, .entity weaponentity, vector org)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 1)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/vortexbeater_fire.wav", 1, ATTN_NORM);
	ATTACK_FINISHED(this, weaponentity) = time + 0.2;
	if(random() > 0.6667)
		W_TakeAmmo(this, IT_NAILS, 1);
	vector dir = qc_aim_fromorg(this, org, 1500);
	// crazy spread on this thing!
	vector spread = '0.1 0.1 0';
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;

	entity newmis = launch_spike(this, org, dir);
	newmis.velocity = dir * 1500;
	newmis.projectiledeathtype = WEP_VORTEXBEATER.m_id;
	newmis.classname = "vortexbeater_bullet";
	settouch(newmis, vortexbeater_bullet_touch);
	//_setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	CSQCProjectile(newmis, true, PROJECTILE_SUPER_SPIKE, true);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
}

void vortexbeater_rocket_think(entity this)
{
	if(this.enemy && (this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET)))
		this.enemy = NULL;
	if(time > this.count)
	{
		delete(this);
		return;
	}

	if(!this.enemy && time > this.cnt && !deathmatch)
	{
		this.enemy = W_PickNearbyTarget(this, this.owner, 500, false, false);
		this.cnt = time + 0.1; // don't spam it!
	}

	if(this.enemy)
	{
		vector dir = normalize(CENTER_OR_VIEWOFS(this.enemy) - this.origin);
		this.velocity = dir * 800;
	}

	this.nextthink = time;
	UpdateCSQCProjectile(this);
}

void vortexbeater_rocket_touch(entity this, entity toucher)
{
	//if(toucher.solid == SOLID_TRIGGER)
		//return;
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this, 110, this.projectiledeathtype);
	T_RadiusDamage(this, this.owner, 80, this.projectiledeathtype, NULL);
	_sound(this, CH_SHOTS, "weapons/vortexbeater_explode.wav", 1, ATTN_NORM);

	Send_Effect(EFFECT_VORTEX_EXPLOSION, findbetterlocation(this.origin, 8), '0 0 0', 1);

	delete(this);
}

void W_FireVortexBeaterRocket(entity this, .entity weaponentity, vector org)
{
	vector dir = qc_aim_fromorg(this, org, 1000);
	
	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "vortexbeater_rocket";
	missile.owner = missile.realowner = this;
	missile.projectiledeathtype = WEP_VORTEXBEATER.m_id;
	missile.clipgroup = this.clipgroup;

	missile.solid = SOLID_CORPSE;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	//_setmodel(missile, "progs/v_spike.mdl");
	setsize(missile, '0 0 0', '0 0 0');

	setorigin(missile, org);

	missile.velocity = dir * 1000;
	missile.nextthink = time;
	missile.count = time + 10;
	missile.cnt = time + 0.1;
	setthink(missile, vortexbeater_rocket_think);
	settouch(missile, vortexbeater_rocket_touch);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, false, PROJECTILE_VORTEX_ROCKET, true);
}

METHOD(VortexBeater, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
		W_VortexBeater_Attack(actor.(weaponentity));
}
METHOD(VortexBeater, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 1;
	return ammo_amount;
}
METHOD(VortexBeater, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(VortexBeater, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
