#include "super_shotgun.qh"

#ifdef SVQC
PRECACHE(SuperShotgun)
{
	if(IsQBJMap())
	{
		precache_sound("flak/shotgun3.wav");
		precache_sound("flak/volley_fire1.wav");
		precache_sound("flak/volley_fire2.wav");
		precache_sound("flak/volley_fire3.wav");
		precache_sound("flak/pump_reload.wav");

		WEP_SUPER_SHOTGUN.spawnflags |= WEP_FLAG_TWOHANDED; // sorry galena
	}
}

void wep_supershotgun_anim(entity this)
{
	entity actor = this.owner;

	if(intermission_running)
		return;

	if(this.m_frame == 18)
		_sound(actor, CH_WEAPON_B, "flak/pump_reload.wav", 0.7, ATTN_NORM);

	if(this.m_frame >= 35)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	this.m_frame += 1;
	wep_set_anim(this, this.m_frame, wep_supershotgun_anim);
	this.weapon_nextthink = time + 0.05;
}

void W_FireSuperShotgun(entity this, .entity weaponentity)
{
	if(this.ammo_shells == 1)
	{
		W_FireShotgun(this, weaponentity);
		return;
	}

	if(IsQBJMap())
	{
		_sound(this, CH_WEAPON_SINGLE, "flak/shotgun3.wav", 1, ATTN_NORM);
		float r = random();
		if(r < 0.33)
			_sound(this, CH_WEAPON_A, "flak/volley_fire1.wav", 1, ATTN_NORM);
		else if(r < 0.66)
			_sound(this, CH_WEAPON_A, "flak/volley_fire2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_A, "flak/volley_fire3.wav", 1, ATTN_NORM);
	}
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	this.punchangle_x = -4 * autocvar_sv_quake_recoil;

	W_TakeAmmo(this, IT_SHELLS, 2);
	vector dir = qc_aim(this, 100000);
	FireBullets(this, 14, 4, W_Shotorg(this, weaponentity), dir, '0.14 0.08 0', WEP_SUPER_SHOTGUN.m_id);
}

METHOD(SuperShotgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		if(IsQBJMap())
		{
			actor.(weaponentity).m_frame = 10;
			wep_supershotgun_anim(actor.(weaponentity));
		}
		else
			wep_generic_shot1(actor.(weaponentity));
		W_FireSuperShotgun(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.7);
	}
}
METHOD(SuperShotgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_shells >= 2;
	return ammo_amount;
}
METHOD(SuperShotgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(SuperShotgun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
PRECACHE(SuperShotgun)
{
	if(IsQBJMap())
	{
		WEP_SUPER_SHOTGUN.m_delta = 0.05;
		precache_model("progs/v_flakshotgun.mdl");
	}
}

METHOD(SuperShotgun, wr_viewmodel, string(entity this, entity wep))
{
	if(IsQBJMap())
		return "flakshotgun";
	return this.mdl;
}
#endif
