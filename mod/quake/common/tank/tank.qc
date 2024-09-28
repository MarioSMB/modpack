#include "tank.qh"

#include "weapons.qh"

#ifdef SVQC
PRECACHE(Tank)
{
	precache_sound("tank/pd_pbnc.wav");  //Plasma bounce sound
	precache_sound("tank/gg_clik2.wav"); //No ammo click and mine arming
	precache_sound("tank/gg_bang.wav");  //Autocannon fire!
	precache_sound("tank/gg_bleep.wav"); //Tank's alert bleep thing
	precache_sound("tank/pd_plsm1.wav"); //Plasma shot
	precache_sound("tank/pd_plsm4.wav"); //Charged plasma shot
	precache_sound("tank/gg_land.wav");  //Tank lands
	precache_sound("tank/pwall2.wav");   //Plasma hits a wall
	precache_sound("tank/gg_jump.wav");  //Danger! Eject!
	precache_sound("tank/horn1.wav");    //The tank's horn!
	precache_sound("tank/horn2.wav");    //Funny bonus horn
	precache_sound("tank/explosin.wav"); //Tank's breakin up
	precache_sound("tank/ioncanno.wav"); //Homing plasma swerves
	precache_sound("tank/spread2.wav");  //Spread plasma
	precache_sound("tank/_minehit.wav"); //Mine's hitting the ground
	precache_sound("tank/radar.wav");    //Homing missile idle
	precache_sound("tank/bgun.wav");     //Big Gun firing sound
	precache_sound("tank/retreat.wav");  //Tank ammo pickup
	precache_sound("tank/tankexpl.wav"); //Tank exploding
	precache_sound("tank/tankexp2.wav"); //Tank exploding2
	precache_sound("tank/tankpick.wav"); //You got a tank! sound
	precache_sound("tank/guided.wav");   //Fire POV Rocket
	precache_sound("tank/minelay.wav");  //Launch mines
	precache_sound("tank/chrgehit.wav"); //Charged plasma hit wall
	precache_sound("tank/woohoo.wav");   //Player killed tank
	precache_sound("tank/tindude.wav"); //tank-hit-tank
	precache_sound("tank/tondude.wav"); //player-hit-tank
	precache_sound("tank/tontank.wav"); //player-crushed by tank
	precache_sound("tank/plasout.wav"); //out of plasma
	precache_sound("tank/megarock.wav"); //fire megarocket
	precache_sound("tank/minedet.wav"); //mine detonation

	precache_sound("tank/borker2.wav");  //?

//        precache_model("progs/plasma2.mdl"); //Super plasma (4 rotating skins)

	precache_model("progs/plasma.mdl");  //Plasma shot (4 skins)
	precache_model("progs/bignail.mdl"); //Autocannon nails (pointy!)
	precache_model("progs/mine.mdl");    //Land mine (skin + camo skins)
	precache_model("progs/brocket.mdl"); //Big rocket model
	precache_model("progs/grocket.mdl"); //Guided rocket model
	precache_model("progs/tsphere.mdl");  //Cool explosion for Brockets.
	precache_model("progs/tankpack.mdl");//Tank pack holding ammo.

	precache_model("progs/tank.mdl");    //The Default Tank!
	precache_model("progs/tbase.mdl");   //Default Tank blown base
	precache_model("progs/tgib1.mdl");   //Default Tank gun gib
	precache_model("progs/tgib2.mdl");   //Default Tank turret gib
	precache_model("progs/tgib3.mdl");   //Default Tank left wing gib
	precache_model("progs/tgib4.mdl");   //Default Tank right wing gib

	precache_model("progs/tank2.mdl");    //Tank2 Tank
	precache_model("progs/t2base.mdl");   //Tank2 blown base
	precache_model("progs/t2gib1.mdl");   //Tank2 gun gib
	precache_model("progs/t2gib2.mdl");   //Tank2 turret gib
	precache_model("progs/t2gib3.mdl");   //Tank2 left wing gib
	precache_model("progs/t2gib4.mdl");   //Tank2 right wing gib

	precache_model("progs/tank3.mdl");    //Falcon Grey Tank
	precache_model("progs/t3base.mdl");   //Falcon Grey blown base
	precache_model("progs/t3gib1.mdl");   //Falcon Grey gun gib
	precache_model("progs/t3gib2.mdl");   //Falcon Grey turret gib
	precache_model("progs/t3gib3.mdl");   //Falcon Grey left wing gib
	precache_model("progs/t3gib4.mdl");   //Falcon Grey right wing gib
}

void Tank_UpdateStats(entity this)
{
	if(!this.tank)
		return;

	STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = TANK_MIN;
	STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = TANK_MAX;
}

void tank_cleanup(entity this)
{
	this.tank = NULL; // tank will clean itself up
	this.items &= ~IT_TANK;
	this.effects &= ~EF_NODRAW;
}

.float tank_rot;
void Tank_PlayerPostThink(entity this)
{
	if(this.tank.jump_flag < -300 && IS_ONGROUND(this))
	{
		_sound(this.tank, CH_VOICE, "tank/gg_land.wav", 1, ATTN_NORM);
		this.tank.jump_flag = 0;
		makevectors(this.tank.angles);
		float r = 5;
		while(r > 0)
		{
			particle(this.tank.origin + '0 0 -10' + v_forward * crandom() * 20 + v_right * crandom() * 20, v_forward * crandom() * 20 + v_right * crandom() * 20, 16, 100);
			r -= 1;
		}
	}
	if(!IS_ONGROUND(this))
		this.tank.jump_flag = this.tank.velocity_z;

	if(time > this.tank.tank_rot)
	{
		this.tank.tank_rot = time + 0.5;
		T_Damage(this, NULL, NULL, 1, DEATH_CRUSH.m_id);
	}

	if(PHYS_INPUT_BUTTON_CROUCH(this) && time > this.tank_horn_delay)
	{
		this.tank_horn_delay = time + 1;
		this.show_hostile = time + 1;
		T_RadiusDamage(this, this, 100, DEATH_CRUSH.m_id, this);
		if(random() < 0.2)
			_sound(this.tank, CH_VOICE, "tank/horn2.wav", 1, ATTN_NORM);
		else
			_sound(this.tank, CH_VOICE, "tank/horn1.wav", 1, ATTN_NORM);
	}
}

void Tank_PlayerDie(entity this)
{
	tank_cleanup(this);
}

float Tank_Damage(entity targ, entity inflictor, entity attacker, float damage, int deathtype)
{
	if(IS_PLAYER(attacker) && !attacker.tank)
	{
		damage *= 0.25;
		if(StatusEffects_active(STATUSEFFECT_Quad, attacker))
		{
			if(DEATH_ISWEAPON(deathtype, WEP_ROCKET_LAUNCHER) || DEATH_ISWEAPON(deathtype, WEP_GRENADE_LAUNCHER))
				damage *= 4;
		}

		if(DEATH_ISWEAPON(deathtype, WEP_LIGHTNING))
		{
			damage = 3;
			if(!autocvar_g_friendlyfire_virtual)
			{
				targ.angles_y += random() * 20;
				targ.fixangle = 1;
			}
		}
	}
	return damage;
}

void Tank_Touch(entity this, entity toucher)
{
	if(!toucher || toucher.solid == SOLID_BSP)
		return;
	if(time < this.tank.tank_touch_delay)
		return;

	this.tank.tank_touch_delay = time + 0.1;

	if(IS_PLAYER(toucher) && !toucher.tank && autocvar_g_friendlyfire_virtual)
		return; // no friendly bouncing sorry!
	if(toucher.takedamage != DAMAGE_AIM)
		return;

	if((toucher.origin_z - this.origin_z) > 32)
		return;

	UNSET_ONGROUND(toucher);
	UNSET_ONGROUND(this);

	if(toucher.tank)
	{
		if((this.origin_z - toucher.origin_z) < 17)
		{
			if(vlen2(this.velocity) > vlen2(toucher.velocity))
			{
				vector vtemp = toucher.velocity;
				toucher.velocity = this.velocity * 2 + '0 0 1';
				this.velocity = vtemp * 2 + '0 0 1';
				if(vdist(this.velocity - toucher.velocity, >, 250))
					_sound(this, CH_VOICE, "tank/tontank.wav", 1, ATTN_NORM);
			}
		}
	}
	else
	{
		float damg = 0; // setting it only when we need to avoid unnecessary vlen() calls
		if((this.origin_z - toucher.origin_z) > 17 && !IS_ONGROUND(this))
		{
			damg = vlen(this.velocity - toucher.velocity);
			if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
				damg = 120;
			T_Damage(toucher, this, this, 1.5 * damg, DEATH_CRUSH.m_id);
			T_Damage(this, toucher, toucher, 1, DEATH_CRUSH.m_id);
		}
		else
		{
			if(vdist(this.velocity, >, 100))
			{
				damg = vlen(this.velocity - toucher.velocity);
				if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
					damg = 1200;
				_sound(this, CH_VOICE, "tank/tindude.wav", 1, ATTN_NORM);
				T_Damage(toucher, this, this, damg * 0.05, DEATH_CRUSH.m_id);
				T_Damage(this, toucher, toucher, 2, DEATH_CRUSH.m_id);
			}
			float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

			toucher.velocity = this.velocity * pushforce + '0 0 50';
		}
	}
}

void PushBack(entity this, float amount)
{
	UNSET_ONGROUND(this);
	makevectors(this.tank.angles);
	v_forward.z = 0 - v_forward.z;

	this.velocity += v_forward * amount * -1 + '0 0 1';
}

void Smoke(vector org)
{
	// expects makevectors to be called first
	float smoke_forward = crandom() * 20;
	float smoke_right = crandom() * 20;
	particle(org + v_right * smoke_right + v_forward * smoke_forward, '0 0 100', 0, 50);
}

float tank_anglemod(float v)
{
	while(v >= 360)
		v -= 360;
	while(v < 0)
		v += 360;
	return v;
}

void tank_tilt(entity tiltee)
{
	vector v1, v2, v3, v4;
	float l1, l2, l3, l4;
	float r1, r2;

	v1 = tiltee.angles;
	v1.x = 0;
	v1.z = 0;
	makevectors(v1);

	// Get four points around the origin.
	v1 = tiltee.origin + (16 * v_forward) - (16 * v_right);
	v2 = tiltee.origin + (16 * v_forward) + (16 * v_right);
	v3 = tiltee.origin - (16 * v_forward) - (16 * v_right);
	v4 = tiltee.origin - (16 * v_forward) + (16 * v_right);

	// Check how far below the floor is. (It starts the tracelines actually
	// from ABOVE the tiltee origin, to make it more accurate on steeper
	// ramps.)
	traceline(v1 + (64 * v_up), v1 - (64 * v_up), true, tiltee);
	l1 = trace_fraction;
	traceline(v2 + (64 * v_up), v2 - (64 * v_up), true, tiltee);
	l2 = trace_fraction;
	traceline(v3 + (64 * v_up), v3 - (64 * v_up), true, tiltee);
	l3 = trace_fraction;
	traceline(v4 + (64 * v_up), v4 - (64 * v_up), true, tiltee);
	l4 = trace_fraction;

	// If there's no floor near enough, the tiltee maintains its angles
	if(l1 == 1 && l2 == 1 && l3 == 1 && l4 == 1)
		return;

	r1 = l1 - l2 + l3 - l4;
	r2 = l1 - l3 + l2 - l4;

// Debug info that shows how much and where it should rotate...
//dprint(ftos(r1));
//dprint(" ");
//dprint(ftos(r2));
//dprint("\n");

// v1 is an approximation of "normal vector" of the surface.
	v1 = '0 0.75 0';
	v1_x = r1;
	v1_z = r2;
	v1 = normalize(v1);
// Calculate angles
	v2 = vectoangles(v1);
	v3 = '0 2 0';
	v3_x = tank_anglemod(0 - v2_x);
	v3_y = tiltee.angles_y;
	v3_z = tank_anglemod(v2_y - 90);  // I know it looks strange ;)

// Don't want it to tilt instantly, it looked ridiculous when it did.
	v4 = v3 - tiltee.angles;
	l1 = tank_anglemod(v4_x);
	if(l1 > 180)
		l1 = l1 - 360;
	l2 = tank_anglemod(v4_z);
	if(l2 > 180)
		l2 = l2 - 360;

// But if the tilting is used for the tiltee item, DO tilt it instantly.
// I used this 'cause the tiltee item had the same model as the tiltee...
	if(tiltee.owner != tiltee)
	{
		l1 = l1 * 0.2;
		l2 = l2 * 0.2;
	}

// Don't touch the angles_y (yaw).
	tiltee.angles_x = tank_anglemod(tiltee.angles_x + l1);
	tiltee.angles_z = tank_anglemod(tiltee.angles_z + l2);
}

void Tank_Think(entity this)
{
	if(!this.owner || this.owner.health < 1 || this.owner.tank != this)
	{
		delete(this);
		return;
	}

	entity player = this.owner;

	this.angles_y = player.angles_y;
	tank_tilt(this);

	this.velocity = player.velocity;
	setorigin(this, player.origin);

	this.effects = player.effects;
	this.effects &= ~EF_NODRAW;

	this.SendFlags |= BIT(1);

	if(player.health < 100 && random() < 0.2)
		Smoke(this.origin);

	this.nextthink = time;
}

void ThrowTGib(string gibname, float dm, entity master)
{
	entity gib = new(gib);
	setorigin(gib, master.origin);
	_setmodel(gib, gibname);
	setsize(gib, '-10 -10 -10', '10 10 10');
	gib.velocity = VelocityForDamage(master, master, dm);
	set_movetype(gib, MOVETYPE_BOUNCE);
	gib.solid = SOLID_NOT;
	gib.avelocity_x = random()*600;
	gib.avelocity_y = random()*600;
	gib.avelocity_z = random()*600;
	setthink(gib, SUB_Remove);
	gib.nextthink = time + 5 + random()*5;
	gib.ltime = time;
	gib.frame = 0;
	gib.flags = 0;
	gib.colormap = master.colormap;
}

void Tank_Die(entity this)
{
	setthink(this, SUB_Remove);
	this.nextthink = time + 1 + (random() * 4);
	this.classname = "deadtank";
	this.velocity = '0 0 0';

	switch(this.tanktype)
	{
		default:
		case 1:
		{
			ThrowTGib("progs/tgib1.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/tgib2.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/tgib3.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/tgib4.mdl", -40 - (random() * 70), this);
			_setmodel(this, "progs/tbase.mdl");
			break;
		}
		case 2:
		{
			ThrowTGib("progs/t2gib1.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/t2gib2.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/t2gib3.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/t2gib4.mdl", -40 - (random() * 70), this);
			_setmodel(this, "progs/t2base.mdl");
		}
		case 3:
		{
			ThrowTGib("progs/t3gib1.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/t3gib2.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/t3gib3.mdl", -40 - (random() * 70), this);
			ThrowTGib("progs/t3gib4.mdl", -40 - (random() * 70), this);
			_setmodel(this, "progs/t3base.mdl");
		}
	}

	if(random() > 0.5)
		_sound(this, CHAN_BODY, "tank/tankexpl.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_BODY, "tank/tankexp2.wav", 1, ATTN_NORM);

	T_RadiusDamage(this, this.owner, 100, DEATH_TRAP.m_id, NULL);

	te_explosion(this.origin);

	set_movetype(this, MOVETYPE_BOUNCE);
	UNSET_ONGROUND(this);
}

void Tank_Pain(entity this, entity attacker, float damage, int deathtype)
{
	// empty?
}

void Tank_Dying(entity this, entity inflictor, entity attacker, int deathtype)
{
	Tank_Eject(this, true);
}

void Tank_Eject(entity this, bool dying)
{
	if(!this.tank)
		return;

	entity mytank = this.tank;

	tank_cleanup(this);

	this.air_finished = time + 12;

	this.th_pain = player_pain;
	this.th_die = PlayerDie;

	if(dying)
	{
		this.pain_finished = time + 1;
		this.health = min(20, mytank.tank_store_health);
	}
	else
		this.health = mytank.tank_store_health;

	this.armortype = mytank.tank_store_armortype;
	this.armorvalue = mytank.tank_store_armorvalue;
	this.items |= mytank.tank_store_items;

	settouch(this, player_touch);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	QCC_UpdatePlayer(this);

	Net_UnlinkEntity(mytank);

	makevectors(mytank.angles);
	set_movetype(mytank, MOVETYPE_BOUNCE);
	mytank.solid = SOLID_NOT;
	mytank.velocity = this.velocity;

	UNSET_ONGROUND(mytank);
	mytank.velocity_z += 1;

	tracebox(this.origin, this.mins, this.maxs, this.origin + v_forward * 3 + v_up * 12, MOVE_NOMONSTERS, this);
	setorigin(this, trace_endpos);
	this.angles = mytank.angles;

	this.velocity = '0 0 300';
	this.velocity += v_forward * 500;

	mytank.nextthink = time + 3;
	setthink(mytank, Tank_Die);
	mytank.classname = "doomedtank";

	if(dying)
		_sound(mytank, CHAN_BODY, "tank/gg_jump.wav", 1, ATTN_NORM);
	else
		_sound(mytank, CH_VOICE, "tank/explosin.wav", 1, ATTN_NORM);
}

void Tank_Spawn(entity this)
{
	if(this.tank)
		return;

	this.items |= IT_TANK;
	this.effects |= EF_MUZZLEFLASH;
	this.effects |= EF_NODRAW; // hide the player!

	if(IS_REAL_CLIENT(this))
		Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_TANK_ENTER);

	clear_powerups(this); // TODO?
	W_Spellbook_ClearSpells(this);
	music_RemovePlayer(this);

	entity newtank = new(tank);
	newtank.owner = this;
	newtank.realowner = this;
	set_movetype(newtank, MOVETYPE_FLYMISSILE);

	newtank.solid = SOLID_NOT;
	newtank.takedamage = DAMAGE_NO;
	newtank.deadflag = DEAD_NO;

	newtank.colormap = this.colormap;

	//newtank.skin = rint(random() * 4);
	newtank.skin = 0; // TODO?

	newtank.tankweapon = bound(TW_NONE + 1, floor(random() * TW_LAST), TW_LAST - 1);
	newtank.cannontype = (random() > 0.5) ? 0 : 1;
	newtank.plasmatype = floor(random() * 5);
	newtank.minetype = (random() > 0.5) ? 0 : 1;

	this.th_pain = Tank_Pain;
	this.th_die = Tank_Dying;

	settouch(this, Tank_Touch);

	this.show_hostile = time + 1;

	Tank_Link(newtank);

	newtank.tank_store_health = this.health;
	newtank.tank_store_armortype = this.armortype;
	newtank.tank_store_armorvalue = this.armorvalue;
	newtank.tank_store_items = this.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
	this.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);

	this.health = 250;
	this.armortype = 0;
	this.armorvalue = this.health;

	newtank.tanktype = ceil(random() * 3);

	newtank.velocity = '0 0 0';
	newtank.angles_y = this.angles_y;

	newtank.tank_rot = time + 3;

	setthink(newtank, Tank_Think);
	newtank.nextthink = time + 0.1;

	setorigin(newtank, this.origin);

	switch(newtank.tanktype)
	{
		default:
		case 1: _setmodel(newtank, "progs/tank.mdl"); break;
		case 2: _setmodel(newtank, "progs/tank2.mdl"); break;
		case 3: _setmodel(newtank, "progs/tank3.mdl"); break;
	}

	setsize(this, TANK_MIN, TANK_MAX);
	setsize(newtank, this.mins, this.maxs);

	this.tank = newtank;
	this.solid = SOLID_SLIDEBOX; // ???

	_sound(newtank, CHAN_BODY, "tank/tankpick.wav", 1, ATTN_NORM);
}

void SpawnSparks(vector org, vector vel, float damage)
{
	particle(org, vel * 0.1, 8, damage * 2);
}

void spawn_touchsparks(entity this, float damage)
{
	vector vel = wall_velocity(this) * 0.2;

	SpawnSparks(this.origin + vel * 0.01, vel, damage);
}
#endif

void Tank_PlayerJump(entity this, float dt)
{
	if(!IS_ONGROUND(this))
		return;

	makevectors(this.angles_y * '0 1 0');

	// modified version of PM_Accelerate
	float wishspeed = 1000;
	float accelrate = 200;
	vector wishdir = v_forward;
	float currentspeed = (this.velocity * v_forward);
	float addspeed = wishspeed - currentspeed;
	if(addspeed <= 0)
		return;
	float accelspeed = accelrate * dt * wishspeed;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

#ifdef SVQC
bool Tank_Send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TANK);
	if(this.owner == to)
		sf |= BIT(0);
	else
		sf &= ~BIT(0);
	WriteByte(MSG_ENTITY, sf);

	if(sf & BIT(1))
	{
		WriteVector(MSG_ENTITY, this.origin);
		WriteVector(MSG_ENTITY, this.velocity);
		WriteAngleVector(MSG_ENTITY, this.angles);
		WriteInt24_t(MSG_ENTITY, this.effects);
	}

	if(sf & BIT(2))
	{
		WriteString(MSG_ENTITY, this.model);
		WriteShort(MSG_ENTITY, this.colormap);
	}

	return true;
}

void Tank_Link(entity this)
{
	Net_LinkEntity(this, true, 0, Tank_Send);
}
#endif
#ifdef CSQC
void tank_draw(entity this)
{
	InterpolateOrigin_Do(this);
	//Movetype_Physics_MatchTicrate(this, TICRATE, false);
	if(this.count && csqcplayer)
	{
		setorigin(this, csqcplayer.origin);
		this.angles_y = csqcplayer.angles_y;
	}
}

void Ent_RemoveTank(entity this)
{
    strfree(this.mdl);
}

NET_HANDLE(ENT_CLIENT_TANK, bool isnew)
{
	int sf = ReadByte();
	if(sf & BIT(0))
		this.count = true;
	else
		this.count = false;
	this.draw = tank_draw;
	if (isnew) IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	InterpolateOrigin_Undo(this);
	this.iflags |= IFLAG_ORIGIN; // interpolate origin too
	this.iflags |= IFLAG_ANGLES; // interpolate angles too
	this.iflags |= IFLAG_VELOCITY; // let's calculate velocity automatically

	if(sf & BIT(1))
	{
		if(isnew)
			set_movetype(this, MOVETYPE_FLYMISSILE);
		this.origin = ReadVector();
		setorigin(this, this.origin);
		this.velocity = ReadVector();
		this.angles = ReadAngleVector();
		this.effects = ReadInt24_t();
	}

	if(sf & BIT(2))
	{
		strcpy(this.mdl, ReadString());
		_setmodel(this, this.mdl);
		setsize(this, TANK_MIN, TANK_MAX);
		this.colormap = ReadShort();
	}

	InterpolateOrigin_Note(this);

	this.entremove = Ent_RemoveTank;

	return true;
}
#endif
