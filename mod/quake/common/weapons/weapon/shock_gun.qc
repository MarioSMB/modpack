#include "shock_gun.qh"

#ifdef SVQC
PRECACHE(Shock_PreCache)
{
	precache_sound2("enforcer/enfstop.wav");   // electric zap (for water hit)
	precache_sound("weapons/dsfirxpl.wav");   // for plasma hit
	precache_sound("weapons/dsplasma.wav");    // plasma firing
	precache_model("progs/pbullet.mdl");      // Plasma bullet model
	precache_model("progs/g_shock.mdl");     // Plasma gun item
	precache_model("progs/v_shock.mdl");     // Plasma being used
	precache_model("progs/s_plasma.spr");     // Plasma explosion sprite
}

void s_pexplode5(entity this) { set_anim(this, 5, SUB_Remove); }
void s_pexplode4(entity this) { set_anim(this, 4, s_pexplode5); }
void s_pexplode3(entity this) { set_anim(this, 3, s_pexplode4); }
void s_pexplode2(entity this) { set_anim(this, 2, s_pexplode3); }
void s_pexplode1(entity this) { set_anim(this, 1, s_pexplode2); }

void ShockExplosion(entity this)
{
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/s_plasma.spr");
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	s_pexplode1(this);
}

void Shock_Watercheck(entity this)
{
	// The routine modified from BLAZE.QC included in the killer87 package.
	// Basically, plasma bullets explode when hitting liquids.
	// In this explosion, the electic charge of the plasma bullet is spread
	// into the said liquid...

	int pc = pointcontents(this.origin);
	if((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
	{
		_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_NORM);

		T_RadiusDamage(this, this.owner, 60, DEATH_DISCHARGE.m_id, NULL);   // Damage
		ShockExplosion(this);                         // Explosion sprite
		return;
	}

	setthink(this, Shock_Watercheck);
	this.nextthink = time;
}

void T_ShockTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;   // don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float damg = 10+random()*50;   // Possibility of gibbing small enemies :)

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		if(random() < 0.5)        // 50% change of gibbing a zombie...
			damg = 1000;             // Otherwise you could never kill them.
	
	if(toucher.health)
		T_Damage(toucher, this, this.owner, damg, WEP_SHOCK_GUN.m_id);

	// Moves the plasma bullet backwards after hitting.. Otherwise the 
	// explosion sprite would often be inside a wall or something. 
	this.origin = this.origin - 8*normalize(this.velocity);

	// Sound from Doom...
	_sound(this, CH_WEAPON_SINGLE, "weapons/dsfirxpl.wav", 1, ATTN_NORM);
	ShockExplosion(this);
}

void W_FireShock(entity this, .entity weaponentity)
{
	if(this.ammo_cells < 1)
	{
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}
	W_TakeAmmo(this, ammo_cells, 1);

	// Taken from Doom...
	_sound(this, CH_WEAPON_SINGLE, "weapons/dsplasma.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);    // Like a rocket
	missile.solid = SOLID_BBOX;
	missile.classname = "plasma";
		
	// set plasma bullet speed. (Basically AIM with some random)  

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.velocity = missile.velocity + ( crandom() * 50 * v_right );
	missile.velocity = missile.velocity + ( crandom() * 50 * v_up );
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = '300 300 300';  

	missile.nextthink = time;
	setthink(missile, Shock_Watercheck);        // If shot underwater -> razzp!
	settouch(missile, T_ShockTouch);
	
	missile.effects = EF_DIMLIGHT;           // Plasma bullets emit light...

	_setmodel(missile, "progs/pbullet.mdl");   // Plasma bullet model
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, W_Shotorg(this, weaponentity) + v_forward * 8);
}

METHOD(ShockGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		wep_generic_shot1(actor.(weaponentity));
		W_FireShock(actor, weaponentity);
		ATTACK_FINISHED(actor, weaponentity) = time + 0.15;
	}
}
METHOD(ShockGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_cells >= 1;
	return ammo_amount;
}
METHOD(ShockGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
