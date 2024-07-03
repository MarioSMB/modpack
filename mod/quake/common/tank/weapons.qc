#include "weapons.qh"

#include "tank.qh"

#ifdef SVQC

void TankAim(entity this)
{
	if(PHYS_INPUT_BUTTON_ATCK2(this))
	{
		makevectors(this.v_angle);
		if(v_forward.z < 0)
			v_forward.z *= 0.1;
	}
	else
	{
		makevectors(this.tank.angles);
		v_forward.z = 0 - v_forward.z;
	}
}

/*******************************\
* Tank (normal) rockets systems *
\*******************************/

void T_TRocketTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.health)
		T_Damage(toucher, this, this.owner, (50 + random() * 20), DEATH_CRUSH.m_id);

	T_RadiusDamage(this, this.owner, 100, DEATH_CRUSH.m_id, toucher);

	setorigin(this, this.origin - 8 * normalize(this.velocity));

	te_explosion(this.origin);

	BecomeExplosion(this);
}

void W_FireTRocket(entity this)
{
	this.tank.effects |= EF_MUZZLEFLASH;

	_sound(this.tank, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "trocket";
		
	TankAim(this);

	missile.velocity = v_forward * 1500;
	missile.angles = vectoangles(missile.velocity);

	settouch(missile, T_TRocketTouch);
 
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');            

	setorigin(missile, this.tank.origin);

	PushBack(this, 150);
}

/********************\
* Big rocket systems *
\********************/

void BRDam(entity this, float dam)
{
	T_RadiusDamage(this, this.owner, dam, DEATH_CRUSH.m_id, NULL);
}

//Sphere model explosion
void SE_Exp6(entity this) { set_anim(this, 0, SUB_Remove); }
void SE_Exp5(entity this) { set_anim(this, 1, SE_Exp6); BRDam(this, 150); }
void SE_Exp4(entity this) { set_anim(this, 2, SE_Exp5); BRDam(this, 200); }
void SE_Exp3(entity this) { set_anim(this, 4, SE_Exp4); BRDam(this, 200); }
void SE_Exp2(entity this) { set_anim(this, 5, SE_Exp3); BRDam(this, 250); }
void SE_Exp1(entity this) { set_anim(this, 4, SE_Exp2); BRDam(this, 300); }

void S_Explode(entity this)
{
	this.solid = SOLID_NOT;
	this.frame = 0;
	_setmodel(this, "progs/tsphere.mdl");
	this.scale = 0.2;
	setsize(this, '0 0 0', '0 0 0');
	UNSET_ONGROUND(this);
	this.avelocity_x = crandom()*360;
	this.avelocity_y = crandom()*360;
	this.avelocity_z = crandom()*360;

	setthink(this, SE_Exp1);
	this.nextthink = time;
	settouch(this, func_null);
}

void T_BRocketTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.health)
		T_Damage(toucher, this, this.owner, (100 + random() * 60), DEATH_CRUSH.m_id);

	T_RadiusDamage(this, this.owner, 150, DEATH_CRUSH.m_id, toucher);

	setorigin(this, this.origin - 8 * normalize(this.velocity));

	te_explosion(this.origin);

	particle(this.origin, '0 0 0', 0, 255);

	this.velocity = '0 0 0';

	this.effects |= EF_BRIGHTLIGHT;

	S_Explode(this);
}

void W_FireBRocket(entity this)
{
	this.tank.effects |= EF_MUZZLEFLASH;

	_sound(this.tank, CH_WEAPON_SINGLE, "tank/megarock.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "brocket";
	missile.colormap = this.colormap;
		
	TankAim(this);

	missile.velocity = missile.velocity + v_forward * 900;
	missile.angles = vectoangles(missile.velocity);

	settouch(missile, T_BRocketTouch);
	
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/brocket.mdl");
	setsize(missile, '0 0 0', '0 0 0');            

	setorigin(missile, this.tank.origin);

	PushBack(this, 500);
}

/***********************\
* Guided rocket systems *
\***********************/

void T_GMissileTouch(entity this, entity toucher)
{
	if(toucher == this.realowner.tank || toucher == this.realowner)
		return;

	entity player = this.realowner;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	//variable distance damage
	float damg = this.count + random() * 60 + 1;
	this.owner = this.realowner;

	if(toucher.takedamage && toucher.health > 0)
		T_Damage(toucher, this, player, damg, DEATH_CRUSH.m_id);
	T_RadiusDamage(this, player, damg, DEATH_CRUSH.m_id, toucher);

	setorigin(this, this.origin - 8 * normalize(this.velocity));

	te_explosion(this.origin);

	BecomeExplosion(this);
}

void T_GMissileExplode(entity this)
{
	T_GMissileTouch(this, NULL);
}

void GuideThink(entity this)
{
	if(!this.realowner || !this.realowner.tank || this.realowner.health < 1 || this.realowner.tank.tankweapon != TW_GROCKS)
	{
		delete(this);
		return;
	}

	if(PHYS_INPUT_BUTTON_ATCK2(this.realowner))
		this.angles = this.realowner.v_angle;
	else
		this.angles = this.realowner.tank.angles;
	makevectors(this.angles);
	this.velocity = normalize(v_forward) * 1200;
	this.angles_x = 0 - this.angles_x;
	makevectors(this.angles);

	if(this.wait < time)
	{
		this.wait = time + 1.0;
		_sound(this, CHAN_BODY, "tank/radar.wav", 1, ATTN_NORM);
		if(this.count > 10)
		{
			this.count -= 10;
			if(this.count < 10)
				this.count = 10;
		}
	}
		  
	this.nextthink = time;

	if(IS_JUMP_HELD(this.realowner))
		return;

	if(this.realowner.button2)
	{
		SET_JUMP_HELD(this.realowner);
		T_GMissileTouch(this, NULL);
	}
}

void W_FireGRocket(entity this)
{
	if(!IS_ONGROUND(this))
		return;
	
	this.tank.effects |= EF_MUZZLEFLASH;

	_sound(this.tank, CH_WEAPON_SINGLE, "tank/guided.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.realowner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;

	makevectors(this.tank.angles);
	v_forward.z = 0 - v_forward.z;

	missile.angles = vectoangles(missile.velocity);
	missile.velocity = v_forward * 1200;
	settouch(missile, T_GMissileTouch);
	
	missile.nextthink = time;
	setthink(missile, GuideThink);

	missile.count = 100;

	_setmodel(missile, "progs/grocket.mdl");
	setsize(missile, '0 0 0', '0 0 0');     

	setorigin(missile, this.tank.origin);

	missile.classname = "grocket";

	this.tank.velocity = '0 0 0';
}

/*******************\
* Land mine systems *
\*******************/

void MineExplode(entity this)
{
	float damg;

	if(this.skin == 0)
		damg = 100;
	else
		damg = 80;

	T_RadiusDamage(this, this.owner, damg, DEATH_CRUSH.m_id, NULL);

	te_explosion(this.origin);

	settouch(this, func_null);

	_sound(this, CHAN_BODY, "tank/minedet.wav", 1, ATTN_NORM);

	particle(this.origin, '0 0 0', 0, 255);

	BecomeExplosion(this);
}

void MineExplodeTouch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner || toucher == this.owner.tank || (IS_PLAYER(toucher) && autocvar_g_friendlyfire_virtual))
		return;
	setthink(this, MineExplode);
	this.nextthink = time;
	settouch(this, func_null);
}

void MineArmedThink(entity this)
{
	if(!this.owner || !this.owner.tank || this.owner.tank.tankweapon != TW_MINES || time > this.wait)
	{
		MineExplode(this);
		return;
	}
	this.nextthink = time + 0.1;
}

void MineArm(entity this)
{
	settouch(this, MineExplodeTouch);
	this.wait = time + 5;
	this.nextthink = time + 0.1;
	setthink(this, MineArmedThink);
	_sound(this, CH_WEAPON_SINGLE, "tank/gg_clik2.wav", 0.5, ATTN_NORM);
	setsize(this, '-32 -32 -32', '32 32 32');

//Why the FUCK doesn't findradius get stuff like info ents?!?!?!?!
	// because they're non solid silly old dev

	entity head = findradius(this.origin, 100);
	while(head)
	{
		if(head.classname == "cmine" ||
			(head.classname == "mine" && head != this) ||
			head.classname == "info_player_deathmatch" ||
			head.classname == "info_teleport_destination")
		{
			this.wait = time;
			return;
		}
		head = head.chain;
	}
}

void MineLand(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;

	if(toucher && toucher.takedamage && toucher.health > 0 && (!IS_PLAYER(toucher) || !autocvar_g_friendlyfire_virtual))
	{
		setthink(this, MineExplode);
		this.nextthink = time;
		settouch(this, func_null);
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "tank/_minehit.wav", 1, ATTN_NORM);

//make the mines flat against the ground.
	traceline(this.origin, this.origin - '0 0 5', false, this);
	this.angles = vectoangles(trace_plane_normal);

	this.angles_z = random()*360;

	this.avelocity = '0 0 0';
	this.avelocity_z = 360;

	this.nextthink = time + 1;
	setthink(this, MineArm);

	if(this.count < 1)
	{
		MineExplode(this);
		return;
	}

	this.count -= 1;
}

void W_FireMine(entity this)
{
	_sound(this.tank, CH_WEAPON_SINGLE, "tank/minelay.wav", 1, ATTN_NORM);
			
	entity mine = spawn();
	mine.owner = this;
	set_movetype(mine, MOVETYPE_BOUNCE);
	mine.solid = SOLID_TRIGGER;
	mine.projectiledeathtype = DEATH_CRUSH.m_id;
	mine.effects = EF_FULLBRIGHT;

	if(this.minetype > 0)
		mine.classname = "cmine";
	else
		mine.classname = "mine";

	makevectors(this.tank.angles);

	mine.velocity = v_up * 100 + crandom() * v_up * 10 + v_forward * 500;

	mine.avelocity = '300 300 300';

	mine.angles_x = crandom() * 360;
	mine.angles_y = crandom() * 360;
	mine.angles_z = crandom() * 360;

//count is for mines that would keep bouncing forever. For example, if
//they're sitting on func_trains. 
	mine.count = 20;

	settouch(mine, MineLand);
	
	_setmodel(mine, "progs/mine.mdl");
	setsize(mine, '0 0 0', '0 0 0');            
	setorigin(mine, this.tank.origin);

	mine.skin = this.minetype;
}

/*****************\
* Big gun systems *
\*****************/

void W_FireBGun(entity this)
{
	this.tank.effects |= EF_MUZZLEFLASH;

	_sound(this.tank, CH_WEAPON_SINGLE, "tank/bgun.wav", 1, ATTN_NORM);

	TankAim(this);

	FireBullets(this, 25, this.origin, v_forward, '0.03 0.03 0', DEATH_CRUSH.m_id);

	TankAim(this);
	traceline(this.tank.origin, this.tank.origin + v_forward * 50, false, NULL);
	int n = 0;
	while(n < 5)
	{
//      particle(this.tank.origin + v_up*12 + v_forward*3*random()*trace_fraction*50, '0 0 0', 0, 10);

		vector dir = this.tank.origin + v_up * 12 + v_forward * 3 * random() * trace_fraction * 50;
		te_gunshot(dir);

		n += 1;
	}

	PushBack(this, 70);
}

/********************\
* Autocannon systems *
\********************/

void bignail_touch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.takedamage && toucher.solid != SOLID_BSP)
	{
		//Tanks don't bleed!
		if(toucher.tank)
			spawn_touchsparks(this, 30);
		else
			spawn_touchblood(this, 30, toucher);

		T_Damage(toucher, this, this.owner, 30, DEATH_CRUSH.m_id);
	}
	else
		te_superspike(this.origin);

	delete(this);
}

void W_FireACannon2(entity this)
{
	this.tank.effects |= EF_MUZZLEFLASH;

	_sound(this.tank, CH_WEAPON_SINGLE, "tank/gg_bang.wav", 1, ATTN_NORM);

	TankAim(this);

//To give a bit of randomness
	v_forward.x = v_forward.x + crandom()*0.02;
	v_forward.y = v_forward.y + crandom()*0.02;
	v_forward.z = v_forward.z + crandom()*0.02;

//Uncalibrated Autocannon
	if(this.tank.cannontype == 1)
	{
		v_forward.x = v_forward.x + crandom()*0.13;
		v_forward.y = v_forward.y + crandom()*0.13;
		v_forward.z = v_forward.z + crandom()*0.13;
	}

	FireBullets(this, 4, this.origin, v_forward, '0.01 0.01 0', DEATH_CRUSH.m_id);

	PushBack(this, 18);
}

/****************\
* Plasma systems *
\****************/

void TankPlasmaTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	if(toucher.health > 0 && toucher.takedamage)
	{
		float mydmg = (this.dmg) ? this.dmg : 70;
		T_Damage(toucher, this, this.owner, (mydmg + random() * 20), DEATH_CRUSH.m_id);
	}

	_sound(this, CH_WEAPON_SINGLE, "tank/pwall2.wav", 1, ATTN_NORM);

	setorigin(this, this.origin - 8 * normalize(this.velocity));

	//te_teleport(this.origin);
	te_explosion2(this.origin, 244, 3);

	delete(this);
}

//********** Normal Plasma **********

void NormalPlasma(entity this)
{
	this.tank.effects |= EF_MUZZLEFLASH;

	_sound(this.tank, CH_WEAPON_SINGLE, "tank/pd_plsm1.wav", 1, ATTN_NORM);

	entity plasma = spawn ();
	plasma.owner = this;
	set_movetype(plasma, MOVETYPE_FLYMISSILE);
	plasma.solid = SOLID_BBOX;
	plasma.classname = "plasma";
	plasma.effects |= EF_DIMLIGHT;

	TankAim(this);
	plasma.velocity = qc_aim(this.tank, 10000);

	plasma.velocity = plasma.velocity * 1000;
	plasma.angles = vectoangles(plasma.velocity);

	if(random() > 0.5)
		plasma.avelocity = '0 0 360';
	else
		plasma.avelocity = '0 0 -360';

	settouch(plasma, TankPlasmaTouch);

	plasma.nextthink = time + 10;
	setthink(plasma, SUB_Remove);

	_setmodel(plasma, "progs/plasma.mdl");
	setsize(plasma, '0 0 0', '0 0 0');
	plasma.skin = 0;

	setorigin(plasma, this.tank.origin);
}

//********** Bounce Plasma **********

void NotBounce(entity this)
{
	set_movetype(this, MOVETYPE_FLYMISSILE);
	UNSET_ONGROUND(this);
	this.nextthink = time + 3;
	setthink(this, SUB_Remove);
	this.velocity = normalize(this.velocity);
	this.velocity *= vlen(this.oldvelocity);
}

void BPlasmaTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.health > 0 && toucher.takedamage)
		T_Damage(toucher, this, this.owner, (100 + random() * 20), DEATH_CRUSH.m_id);

	if(toucher.health || this.count < 1)
	{
		_sound(this, CH_WEAPON_SINGLE, "tank/pwall2.wav", 1, ATTN_NORM);

		setorigin(this, this.origin - 8 * normalize(this.velocity));

		//te_teleport(this.origin);
		te_explosion2(this.origin, 244, 3);

		delete(this);
		return;
	}
	_sound(this, CH_WEAPON_SINGLE, "tank/pd_pbnc.wav", 1, ATTN_NORM);

//count is for number of times it will bounce until going away.
	this.count -= 1;

	this.oldvelocity = this.velocity;
	set_movetype(this, MOVETYPE_BOUNCE);
	setthink(this, NotBounce);
	this.nextthink = time + 0.1;
}

void BouncePlasma(entity this)
{
	this.tank.attack_finished += 0.3;

	this.tank.effects |= EF_MUZZLEFLASH;

//REPLACE with firing bounce plasma sound
	_sound(this.tank, CH_WEAPON_SINGLE, "tank/pd_plsm1.wav", 1, ATTN_NORM);

	entity plasma = spawn ();
	plasma.owner = this;
	set_movetype(plasma, MOVETYPE_FLYMISSILE);
	plasma.solid = SOLID_BBOX;
	plasma.classname = "bplasma";
	plasma.effects |= EF_DIMLIGHT;

	plasma.count = 5;

	TankAim(this);
	plasma.velocity = qc_aim(this.tank, 10000);

	plasma.velocity = plasma.velocity * 1000;

	plasma.avelocity_x = crandom()*360;
	plasma.avelocity_y = crandom()*360;
	plasma.avelocity_z = crandom()*360;

	settouch(plasma, BPlasmaTouch);
	plasma.nextthink = time + 3;
	setthink(plasma, SUB_Remove);

	_setmodel(plasma, "progs/plasma.mdl");
	setsize(plasma, '0 0 0', '0 0 0');
	plasma.skin = 1;

	setorigin(plasma, this.tank.origin + v_forward*3 + v_up*12);

	plasma.oldvelocity = plasma.velocity;
}

//********** Spread Plasma **********

void SpreadPlasma(entity this)
{
	this.tank.effects |= EF_MUZZLEFLASH;

	this.tank.attack_finished += 0.4;

	_sound(this.tank, CH_WEAPON_SINGLE, "tank/spread2.wav", 1, ATTN_NORM);

	int num = 0;
	int maxshots = 5;
	float shotoffset = floor(maxshots * 0.5) + 1;

	TankAim(this);

	while(num < maxshots)
	{
		num += 1;
		entity plasma = spawn();
		plasma.owner = this;
		set_movetype(plasma, MOVETYPE_FLYMISSILE);
		plasma.solid = SOLID_BBOX;
		plasma.classname = "splasma";

		plasma.scale = 0.5;
		plasma.velocity = qc_aim(this.tank, 1000);
		plasma.velocity = plasma.velocity * 1000;
		plasma.dmg = 20;

		plasma.velocity = plasma.velocity + (num - shotoffset) * v_right * 150 + v_forward * 150;

		plasma.angles = vectoangles(plasma.velocity);

		if(random() > 0.5)
			plasma.avelocity = '0 0 360';
		else
			plasma.avelocity = '0 0 -360';

		settouch(plasma, TankPlasmaTouch);

		plasma.nextthink = time + 10;
		setthink(plasma, SUB_Remove);

		_setmodel(plasma, "progs/plasma.mdl");
		plasma.skin = 3;
		setsize(plasma, '0 0 0', '0 0 0');

		setorigin(plasma, this.tank.origin);
	}

//   PlasmaParticle (232);
}

//********** Homing Plasma **********

//Note: The homing code for the homing plasma here
//      was cut out of Vhold's WONDERFUL homing missile patch.

entity HomeFindTarget(entity this)
{
	entity selected = W_PickNearbyTarget(this, 500, false, false);

	if(selected)
	{
		_sound(this, CH_WEAPON_SINGLE, "tank/ioncanno.wav", 1, ATTN_NORM);
		if(IS_PLAYER(selected))
			Send_Notification(NOTIF_ONE, selected, MSG_CENTER, CENTER_TANK_LOCKON, this.owner.netname);
	}
	return selected;
}

void HomeThink(entity this)
{
	if(this.wait < time)
	{
		PlasmaTouch(this, NULL);
		return;
	}

	if(!this.enemy || this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET))
		this.enemy = HomeFindTarget(this);

	if(this.enemy) // Arr.. don't be taken on da World!
	{
		vector vtemp = this.enemy.origin + '0 0 10';
		vector dir = normalize(vtemp - this.origin);
		this.velocity = dir * 500;
		this.angles = vectoangles(this.velocity);
		this.avelocity = '0 0 0';
	}

	this.nextthink = time + 0.2;
	setthink(this, HomeThink);
}

void HomePlasma(entity this)
{
	this.tank.attack_finished += 0.6;

	this.tank.effects |= EF_MUZZLEFLASH;

//REPLACE with firing homing plasma sound
	_sound(this.tank, CH_WEAPON_SINGLE, "tank/pd_plsm1.wav", 1, ATTN_NORM);

	entity plasma = spawn();
	plasma.owner = this;
	set_movetype(plasma, MOVETYPE_FLYMISSILE);
	plasma.solid = SOLID_BBOX;
	plasma.classname = "hplasma";
	plasma.effects |= EF_DIMLIGHT;
	plasma.dmg = 50;

	TankAim(this);
	plasma.velocity = qc_aim(this.tank, 10000);

	plasma.velocity = v_forward*1000;
	plasma.angles = vectoangles(plasma.velocity);

	if(random() > 0.5)
		plasma.avelocity = '0 0 360';
	else
		plasma.avelocity = '0 0 -360';

	settouch(plasma, TankPlasmaTouch);
	plasma.nextthink = time + 0.2;
	setthink(plasma, HomeThink);
	plasma.enemy = NULL;

//wait is for how long the plasma goes before it goes byebye.
	plasma.wait = time + 7;

	_setmodel(plasma, "progs/plasma.mdl");
	setsize(plasma, '0 0 0', '0 0 0');
	plasma.skin = 2;

	setorigin(plasma, this.tank.origin);
}

//********** Charge Plasma **********

void CPlasmaTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
	{
		makevectors(this.owner.tank.angles);
		this.velocity = v_forward * 1000;
		return;
	}

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	if(pointcontents(this.origin) == SOLID_BSP)
		return;

	if(toucher.health > 0 && toucher.takedamage)
		T_Damage(toucher, this, this.owner, (650 + random() * 100), DEATH_CRUSH.m_id);

	_sound(this, CH_WEAPON_SINGLE, "tank/chrgehit.wav", 1, ATTN_NORM);

	setorigin(this, this.origin - 8 * normalize(this.velocity));

	//te_teleport(this.origin);
	te_explosion2(this.origin, 244, 3);

	delete(this);
}

//I can't cheat by using grouped skins for the charge plasma model anymnore
//The new GLQuake is CRAP and barfs at all auto-cyclic skins, so I have to
//write this crappy think function to get the same effect of the flashing
//plasma. But at least QTank wil work in GLQuake now.
void ChargePlasmaThink(entity this)
{
	if(this.wait < time)
	{
		delete(this);
		return;
	}

	if(this.skin > 2)
		this.skin = 0;
	else
		this.skin += 1;

	this.nextthink = time + 0.1;
}

void ChargePlasma(entity this)
{
	this.tank.effects |= EF_MUZZLEFLASH;

	this.tank.attack_finished += 0.6;

	_sound(this.tank, CH_WEAPON_SINGLE, "tank/pd_plsm4.wav", 1, ATTN_NORM);

	entity plasma = spawn();
	plasma.owner = this;
	set_movetype(plasma, MOVETYPE_FLYMISSILE);
	plasma.solid = SOLID_BBOX;
	plasma.classname = "cplasma";
	plasma.effects |= EF_BRIGHTLIGHT;

	TankAim(this);
	plasma.velocity = qc_aim(this.tank, 10000);

	plasma.velocity = plasma.velocity * 1000;
	plasma.angles = vectoangles(plasma.velocity);

	if(random() > 0.5)
		plasma.avelocity = '0 0 360';
	else
		plasma.avelocity = '0 0 -360';

	settouch(plasma, CPlasmaTouch);

//   plasma.nextthink = time + 10;
//   plasma.think = SUB_Remove;

	plasma.wait = time + 10;
	setthink(plasma, ChargePlasmaThink);
	plasma.nextthink = time;

//   setmodel (plasma, "progs/plasma2.mdl");

	_setmodel(plasma, "progs/plasma.mdl");
	setsize(plasma, '0 0 0', '0 0 0');

	setorigin(plasma, this.tank.origin);

	particle(this.tank.origin + v_forward * 24 + v_up * 12, '0 0 0', 0, 255);
}

void W_Tank_FirePlasma(entity this)
{
	switch(this.tank.plasmatype)
	{
		default:
		case 0: NormalPlasma(this); break;
		case 1: BouncePlasma(this); break;
		case 2: SpreadPlasma(this); break;
		case 3: HomePlasma(this); break;
		case 4: ChargePlasma(this); break;
	}
}

void Tank_WeaponFrame(entity this)
{
	if(this.button0 && time > this.tank.attack_finished)
	{
		makevectors(this.v_angle); // calculate forward angle for velocity
		this.show_hostile = time + 1;

		switch(this.tank.tankweapon)
		{
			default:
			case TW_BGUN:
			{
				this.tank.attack_finished = time + 0.7;
				W_FireBGun(this);
				break;
			}
			case TW_TROCKS:
			{
				this.tank.attack_finished = time + 0.5;
				W_FireTRocket(this);
				break;
			}
			case TW_BROCKS:
			{
				this.tank.attack_finished = time + 1.0;
				W_FireBRocket(this);
				break;
			}
			case TW_GROCKS:
			{
				this.tank.attack_finished = time + 0.8;
				W_FireGRocket(this);
				break;
			}
			case TW_ACANNON:
			{
				this.tank.attack_finished = time + 0.1;
				W_FireACannon2(this);
				break;
			}
			case TW_MINES:
			{
				this.tank.attack_finished = time + 0.3;
				W_FireMine(this);
				break;
			}
			case TW_PLASMA:
			{
				this.tank.attack_finished = time + 0.4;
				W_Tank_FirePlasma(this);
				break;
			}
		}
	}
}

void Tank_ImpulseCommands(entity this, int imp)
{
	// dummy function, weapon swapping was disabled in favour of random weapons
}
#endif
