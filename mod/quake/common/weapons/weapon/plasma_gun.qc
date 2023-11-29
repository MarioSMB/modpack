#include "plasma_gun.qh"

#ifdef SVQC
void wep_plasmagun_plasma6(entity this) { wep_set_anim(this, 5, w_ready); } //ooppee uses the rocket fire animation for thirdperson, it's 6 frames though, not 5 so had to dupe it.
void wep_plasmagun_plasma5(entity this) { wep_set_anim(this, 5, wep_plasmagun_plasma6); }
void wep_plasmagun_plasma4(entity this) { wep_set_anim(this, 4, wep_plasmagun_plasma5); }
void wep_plasmagun_plasma3(entity this) { wep_set_anim(this, 3, wep_plasmagun_plasma4); }
void wep_plasmagun_plasma2(entity this) { wep_set_anim(this, 2, wep_plasmagun_plasma3); }
void wep_plasmagun_plasma1(entity this) { wep_set_anim(this, 1, wep_plasmagun_plasma2); player_rocket1(this.owner); this.owner.effects |= EF_MUZZLEFLASH; }

void PlasmaDamage(vector p1, vector p2, entity from, float damage)
{
	vector f = p2 - p1;
	normalize(f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	entity e1 = NULL, e2 = NULL;

	traceline(p1, p2, false, from);
	if(trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from.owner, damage, from.projectiledeathtype);
		if(IS_PLAYER(from))
		{
			if(IS_PLAYER(trace_ent))
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline(p1 + f, p2 + f, false, from);
	if(trace_ent != e1 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from.owner, damage, from.projectiledeathtype);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from.owner, damage, from.projectiledeathtype);
	}
}

void PlasmaDischarge(entity this, entity current, float doDamage)
{
	//te_lightning2(NULL, current.origin, this.origin); // should be for current
	SendCSQCLightningBeam(current.origin, this.origin);

	_sound(this, CH_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);
	if(doDamage == 1)
        PlasmaDamage(this.origin, current.origin, this, 50);
}

void PlasmaGroundOut(entity this)
{
	int monstersHit = 0;
	entity current = findradius(this.origin, 320);
	entity start = current;
	while(monstersHit < 5)
	{
		if((current.flags & FL_MONSTER) || IS_PLAYER(current))
		{
			if(current != this.owner && current.takedamage) // only take alive targets?
			{
				traceline(this.origin, current.origin, true, NULL);
				if(trace_fraction == 1)
				{
					monstersHit = monstersHit + 1;
					PlasmaDischarge(this, current, 1);
				}
			}
		}
		current = current.chain;
		if(start == current || !current)
			return;
	}
}

void PlasmaTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "plasma/explode.wav", 1, ATTN_NORM);
	
	if(toucher.takedamage)
	{
		float damg = 80 + random()*20;
		if(IS_MONSTER(this.realowner))
			damg = 30;
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg *= 0.5;	// mostly immune
		if(toucher.resist_cells != 0)
		{
			damg = Resist_Damage(toucher, IT_CELLS, damg);
			Resist_Plasma(toucher, this.origin);
		}
		if(damg > 0)
			T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	float rdmg = 70;
	if(IS_MONSTER(this.realowner))
		rdmg = 20; // lower base damage for monsters
	T_RadiusDamage(this, this.owner, rdmg, this.projectiledeathtype, toucher);

	te_explosion2(this.origin, 244, 3);

	// Check for any plasma reflection? (player only function)
	if(IS_PLAYER(this.owner) && toucher.reflectplasma)
	{
		vector org = this.origin;
		vector dir;
		// Random chance that plasma will reflect straight back
		if(random() < 0.2 && this.owner) 
			dir = normalize(this.owner.origin - org);
		else
		{
			// Pick random location instead
			vector vec = org + randomvec() * 1000;
			dir = normalize(vec - org);
		}
		// Switch around this to make sure reflection happens once
		entity newmis = launch_plasma(toucher, org, dir);
		newmis.projectiledeathtype = DEATH_TRAP.m_id; // TODO: reflection deathtype
	}
	else if(IS_PLAYER(this.realowner)) // only do an area explosion if it wasn't reflected?
		PlasmaGroundOut(this);
	delete(this);
}

void PlasmaLaunch(entity this)
{
	this.velocity = normalize(this.velocity);
	this.velocity = this.velocity * 1250;

	this.nextthink = time + 5;
	setthink(this, SUB_Remove);
}

entity launch_plasma(entity this, vector org, vector dir)
{
	entity missile = new(plasma);
	missile.owner = this;
	missile.realowner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_PLASMA_GUN.m_id;
	
// set missile speed
//ooppee new code... it was that damn 0.01. I changed it to 600 to match the
//enforecers laser speed (as they are basically the same speed) and it worked?	
	missile.velocity = dir * 600;
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
//ooppee old code below	
	//missile.velocity = dir * 0.01;
	//missile.avelocity = '300 300 300';
	//missile.angles = vectoangles(missile.velocity);
	settouch(missile, PlasmaTouch);
	
	_setmodel(missile, "progs/plasma.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, org);

	_sound(missile, CH_WEAPON_SINGLE, "plasma/flight.wav", 1, ATTN_NORM);
	if(!deathmatch && !coop)
		missile.effects = EF_BRIGHTLIGHT;
	
// set missile duration
	setthink(missile, PlasmaLaunch);
	missile.nextthink = time + 0.1;

	return missile;
}

void W_FirePlasma(entity this, .entity weaponentity)
{
	if(this.ammo_plasma < 1)
	{
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_plasma;
		this.ammo_plasma = 0;
		W_SetCurrentAmmo(this);
		T_RadiusDamage(this, this, 35*cells, DEATH_DISCHARGE.m_id, NULL);
		return;
	}
	if(!(this.powerups & POWERUP_SHARPSHOOTER))
		this.ammo_plasma -= 1;
	_sound(this, CH_WEAPON_SINGLE, "plasma/fire.wav", 0.5, ATTN_NORM);
	this.punchangle_x = -2;

	makevectors(this.v_angle);
	vector dir = qc_aim(this, 1000);
	//launch_plasma(this, this.origin + v_forward*24 + '0 0 16', dir);//seven's postion fix -ooppee edit out
	entity plasma = launch_plasma(this, this.origin + v_forward * 24 + this.view_ofs + v_up * -10, dir); //seven's fix applied
	setorigin(plasma, W_Shotorg(this, weaponentity) + v_forward * 24 + v_up * -10);
}

METHOD(PlasmaGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		// player_light1 determines choice of W_FireLightning 
		//      or W_FirePlasma, but same lighting and frames...
		//ATTACK_FINISHED(actor, weaponentity) = time + 1.0;//ooppee edited line out
		//player_light1(actor);//ooppee edited line out
		wep_plasmagun_plasma1(actor.(weaponentity)); //ooppee added
		W_FirePlasma(actor, weaponentity); //ooppee added
		weapon_prepareattack(thiswep, actor, weaponentity, 1); //ooppee added (same as above code but needs to be executed AFTER)
	}
}
METHOD(PlasmaGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_plasma >= 1;
	return ammo_amount;
}
METHOD(PlasmaGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
