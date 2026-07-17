#include "nailgun.qh"

#ifdef SVQC
PRECACHE(Nailgun)
{
	if(IsQBJMap())
	{
		precache_sound("nail/airpuff.wav");
		precache_sound("nail/nailgun1.wav");
		precache_sound("nail/nailgun2.wav");
		precache_sound("nail/nailgun3.wav");
		precache_sound("nail/nailgun4.wav");
		precache_sound("nail/nailgun5.wav");

		WEP_NAILGUN.spawnflags |= WEP_FLAG_TWOHANDED; // sorry galena
	}
}

void wep_nailgun_anim_end(entity this)
{
	if(this.m_frame == 14 || this.m_frame >= 18)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	this.m_frame += 1;
	wep_set_anim(this, this.m_frame, wep_nailgun_anim_end);
	this.weapon_nextthink = time + 0.02;
}

void W_Nailgun_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(actor.ammo_nails < 1)
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		W_SwitchWeapon(actor, w_getbestweapon(actor, weaponentity), weaponentity);
		return;
	}
	if(!actor.button0)
	{
		if(IsQBJMap())
			wep_nailgun_anim_end(this);
		else
			w_ready(this);
		return;
	}

	if(IsQBJMap())
	{
		if(this.m_frame >= 18)
			this.m_frame = 11;
		else
			this.m_frame += 1;
	}
	else
	{
		this.m_frame += 1;
		if(this.m_frame >= 9)
			this.m_frame = 1;
	}
	wep_set_anim(this, this.m_frame, W_Nailgun_Attack);
	if(IsQBJMap())
		this.weapon_nextthink = time + 0.02;
	if(!IsQBJMap() || ((this.m_frame == 11 || this.m_frame == 15)))
	{
		if(IS_PLAYER(actor))
			player_nail1(actor);

		actor.effects |= EF_MUZZLEFLASH;

		this.misc_bulletcounter += 1;

		SuperDamageSound(actor);
		float offset = (IsQBJMap()) ? 4 : 3;
		W_FireSpikes(actor, ((this.misc_bulletcounter % 2) ? offset : -offset), weaponentity);
	}
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void W_FireSpikes(entity this, float ox, .entity weaponentity)
{
	makevectors(this.v_angle);

	float vol = (this.silencer) ? 0.2 : 1;
	if(IsQBJMap())
	{
		vol = (this.silencer) ? 0.2 : 0.8;
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", vol, ATTN_NORM);
		_sound(this, CH_WEAPON_B, "nail/airpuff.wav", 0.3, ATTN_NORM);
		float r = floor(random() * 5);
		switch(r)
		{
			case 0: _sound(this, CH_WEAPON_A, "nail/nailgun1.wav", 0.45, ATTN_NORM); break;
			case 1: _sound(this, CH_WEAPON_A, "nail/nailgun2.wav", 0.45, ATTN_NORM); break;
			case 2: _sound(this, CH_WEAPON_A, "nail/nailgun3.wav", 0.45, ATTN_NORM); break;
			case 3: _sound(this, CH_WEAPON_A, "nail/nailgun4.wav", 0.45, ATTN_NORM); break;
			default: _sound(this, CH_WEAPON_A, "nail/nailgun5.wav", 0.45, ATTN_NORM); break;
		}
	}
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", vol, ATTN_NORM);

	ATTACK_FINISHED(this, weaponentity) = time + 0.2;
	W_TakeAmmo(this, IT_NAILS, 1);
	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, W_Shotorg(this, weaponentity) + v_right * ox, dir);
	missile.projectiledeathtype = WEP_NAILGUN.m_id;

	CSQCProjectile(missile, true, PROJECTILE_BULLET, true);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
}

METHOD(Nailgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		actor.(weaponentity).misc_bulletcounter = 0;
		if(IsQBJMap())
			actor.(weaponentity).m_frame = 10;
		W_Nailgun_Attack(actor.(weaponentity));
	}
}
METHOD(Nailgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 1;
	return ammo_amount;
}
METHOD(Nailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Nailgun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
PRECACHE(Nailgun)
{
	if(IsQBJMap())
	{
		WEP_NAILGUN.m_delta = 0.02;
		precache_model("progs/v_tnailgun.mdl");
	}
}

METHOD(Nailgun, wr_viewmodel, string(entity this, entity wep))
{
	if(IsQBJMap())
		return "tnailgun";
	return this.mdl;
}
#endif
