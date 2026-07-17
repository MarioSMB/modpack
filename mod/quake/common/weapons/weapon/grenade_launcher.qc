#include "grenade_launcher.qh"

#ifdef SVQC
PRECACHE(GrenadeLauncher)
{
	if(IsQBJMap())
	{
		precache_sound("grenade/grenade_reload.wav");
		precache_sound("grenade/grenade_fire1.wav");
		precache_sound("grenade/grenade_fire2.wav");
		precache_sound("grenade/grenade_fire3.wav");

		WEP_GRENADE_LAUNCHER.spawnflags |= WEP_FLAG_TWOHANDED; // sorry galena
	}
}

void wep_grenade_anim(entity this)
{
	if(this.m_frame >= 30)
	{
		this.m_frame = 10;
		w_ready(this);
		return;
	}

	this.m_frame += 1;
	wep_set_anim(this, this.m_frame, wep_grenade_anim);
	this.weapon_nextthink = time + 0.05;
}

void GrenadeExplode(entity this)
{
	T_RadiusDamage(this, this.owner, 120, this.projectiledeathtype, NULL);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	BecomeExplosion(this);
}

void GrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode(this);
		return;
	}
	if(this.attack_finished < time)
		_sound(this, CH_WEAPON_SINGLE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	this.attack_finished = time + 0.1;
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

void W_FireGrenade(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, IT_ROCKETS, 1);

	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);
	if(IsQBJMap())
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_WEAPON_A, "grenade/grenade_fire1.wav", 0.6, ATTN_NORM);
		else if(r < 0.66)
			_sound(this, CH_WEAPON_A, "grenade/grenade_fire2.wav", 0.6, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_A, "grenade/grenade_fire3.wav", 0.6, ATTN_NORM);
		_sound(this, CH_WEAPON_B, "grenade/grenade_reload.wav", 0.5, ATTN_NORM);
	}

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;

	entity missile = new(grenade);
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_GRENADE_LAUNCHER.m_id;
	missile.clipgroup = this.clipgroup;
// set missile speed	

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, GrenadeTouch);
	
// set missile duration
	missile.nextthink = time + 2.5;
	setthink(missile, GrenadeExplode);

	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, W_Shotorg(this, weaponentity));

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, true, PROJECTILE_GRENADE, true);
}

METHOD(GrenadeLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		if(IsQBJMap())
		{
			actor.(weaponentity).m_frame = 10;
			wep_grenade_anim(actor.(weaponentity));
		}
		else
			wep_generic_rocket1(actor.(weaponentity));
		W_FireGrenade(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.6);
	}
}
METHOD(GrenadeLauncher, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(GrenadeLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(GrenadeLauncher, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
PRECACHE(GrenadeLauncher)
{
	if(IsQBJMap())
	{
		WEP_GRENADE_LAUNCHER.m_delta = 0.05;
		precache_model("progs/v_grenlauncher.mdl");
	}
}

METHOD(GrenadeLauncher, wr_viewmodel, string(entity this, entity wep))
{
	if(IsQBJMap())
		return "grenlauncher";
	return this.mdl;
}
#endif
