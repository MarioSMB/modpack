#include "goldy.qh"

REGISTER_NET_TEMP(goofy_gibsplash)

#ifdef SVQC
PRECACHE(Goldy)
{
	precache_model("progs/v_goldy.mdl");
	precache_model("progs/g_goldy.mdl");

	precache_sound("weapons/goldy_impact1.wav");
	precache_sound("weapons/goldy_impact2.wav");
	precache_sound("weapons/goldy_impact3.wav");
}

void Goldy_ThrowGibs(entity this)
{
	int channel = MSG_ALL;
	WriteHeader(channel, goofy_gibsplash);
	WriteVector(channel, findbetterlocation(this.origin, 8));
}

void Goldy_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = (this.dmg) ? this.dmg : 100;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.takedamage)
	{
		if(Resist_Explosions(toucher))
			damg *= 0.5;	// mostly immune
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	this.origin = this.origin - 8 * normalize(this.velocity);

	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);

	if(this.noise && this.noise != "")
		_sound(this, CH_WEAPON_SINGLE, this.noise, 1, ATTN_NORM);

	Goldy_ThrowGibs(this);

	delete(this);
}

entity W_FireGoldy(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, IT_ROCKETS, 1);

	sound(this, CH_WEAPON_SINGLE, SND_GOLDY_FIRE_RANDOM(), 1, ATTN_NORM);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	set_movetype(missile, MOVETYPE_TOSS);
	missile.solid = SOLID_BBOX;
	missile.classname = "goldy_bag";
	missile.projectiledeathtype = WEP_GOLDY.m_id;
	missile.clipgroup = this.clipgroup;
	missile.gravity = 1;
	missile.confusing = true;

	float r = random();
	if(r < 0.33)
		missile.noise = "weapons/goldy_impact1.wav";
	else if(r < 0.66)
		missile.noise = "weapons/goldy_impact2.wav";
	else
		missile.noise = "weapons/goldy_impact3.wav";

	// set missile speed	

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward*1000 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 1000;
		missile.velocity_z = 200;
	}

	settouch(missile, Goldy_Touch);

	// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	//_setmodel(missile, "progs/missile.mdl");
	setsize(missile, '-8 -8 -8', '8 8 8');
	setorigin(missile, W_Shotorg(this, weaponentity));

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, true, PROJECTILE_GOLDY, true);

	return missile;
}

METHOD(Goldy, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireGoldy(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.7);
	}
}
METHOD(Goldy, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(Goldy, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Goldy, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
string Goldy_GoofyGibs(int number)
{
	switch(number)
	{
		case 0: return "progs/goofygib_balloon.mdl";
		case 1: return "progs/goofygib_bolt.mdl";
		case 2: return "progs/goofygib_boot.mdl";
		case 3: return "progs/goofygib_burger.mdl";
		case 4: return "progs/goofygib_can.mdl";
		case 5: return "progs/goofygib_clock.mdl";
		case 6: return "progs/goofygib_duck.mdl";
		case 7: return "progs/goofygib_fish.mdl";
		case 8: return "progs/goofygib_gear1.mdl";
		case 9: return "progs/goofygib_gear2.mdl";
		case 10: return "progs/goofygib_gear3.mdl";
		case 11: return "progs/goofygib_gear4.mdl";
		case 12: return "progs/goofygib_gear5.mdl";
		case 13: return "progs/goofygib_hubcap.mdl";
		case 14: return "progs/goofygib_licenseplate.mdl";
		case 15: return "progs/goofygib_spring1.mdl";
		case 16: return "progs/goofygib_spring2.mdl";
		case 17: return "progs/goofygib_teeth.mdl";
		case 18: return "progs/goofygib_tire.mdl";
	}
	return "progs/null.mdl";
}

PRECACHE(GoofyGibs)
{
	// gibs for explosion
	for(int j = 0; j <= 18; ++j)
	{
		precache_model(Goldy_GoofyGibs(j));
	}
}

NET_HANDLE(goofy_gibsplash, bool isnew)
{
	vector org = ReadVector();

	return = true;

	int gibcount = max(4, rint(random() * 12));
	for(int j = 0; j < gibcount; ++j)
	{
		int r = floor(random() * (18 + 1)); // goofy gib count + 1
		string gibname = Goldy_GoofyGibs(r);
		vector targvel = randomvec() * 300 + '0 0 150';
		TossGib (gibname, org, org, targvel, '0 0 0', 0, false, true);
	}
}
#endif
