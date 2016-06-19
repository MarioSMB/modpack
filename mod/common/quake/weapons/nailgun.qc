#ifndef IMPLEMENTATION
#ifndef MENUQC
SOUND(NAILGUN_FIRE, "quake_weapons/rocket1i");

MODEL(NAILGUN_VIEW,                  W_Model("h_nailgun.iqm"));
MODEL(NAILGUN_WORLD,                 W_Model("v_nailgun.md3"));
MODEL(NAILGUN_ITEM,                  W_Model("g_nailgun.md3"));
#endif

float autocvar_g_balance_nailgun_burst = 3;
float autocvar_g_balance_nailgun_burst_ammo = 3;
float autocvar_g_balance_nailgun_burst_animtime = 0.3;
float autocvar_g_balance_nailgun_burst_refire = 0.06;
float autocvar_g_balance_nailgun_burst_refire2 = 0.45;
float autocvar_g_balance_nailgun_burst_speed = 0;
float autocvar_g_balance_nailgun_first = 0;
float autocvar_g_balance_nailgun_first_ammo = 1;
float autocvar_g_balance_nailgun_first_damage = 5;
float autocvar_g_balance_nailgun_first_force = 5;
float autocvar_g_balance_nailgun_first_refire = 0.125;
float autocvar_g_balance_nailgun_first_spread = 0.03;
float autocvar_g_balance_nailgun_mode = 0;
float autocvar_g_balance_nailgun_reload_ammo = 0;
float autocvar_g_balance_nailgun_reload_time = 2;
float autocvar_g_balance_nailgun_solidpenetration = 13.1;
float autocvar_g_balance_nailgun_spread_add = 0.012;
float autocvar_g_balance_nailgun_spread_max = 0.02;
float autocvar_g_balance_nailgun_spread_min = 0.01;
float autocvar_g_balance_nailgun_sustained_ammo = 1;
float autocvar_g_balance_nailgun_sustained_damage = 9;
float autocvar_g_balance_nailgun_sustained_force = 5;
float autocvar_g_balance_nailgun_sustained_refire = 0.1;
float autocvar_g_balance_nailgun_sustained_spread = 0.01;
float autocvar_g_balance_nailgun_switchdelay_drop = 0.2;
float autocvar_g_balance_nailgun_switchdelay_raise = 0.2;
string autocvar_g_balance_nailgun_weaponreplace = "";
float autocvar_g_balance_nailgun_weaponstart = 0;
float autocvar_g_balance_nailgun_weaponstartoverride = -1;
float autocvar_g_balance_nailgun_weaponthrowable = 1;

CLASS(NailGun, Weapon)
/* ammotype  */ ATTRIB(NailGun, ammo_field, .int, ammo_nails)
/* impulse   */ ATTRIB(NailGun, impulse, int, 4)
/* flags     */ ATTRIB(NailGun, spawnflags, int, WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN);
/* rating    */ ATTRIB(NailGun, bot_pickupbasevalue, float, BOT_PICKUP_RATING_MID);
/* color     */ ATTRIB(NailGun, wpcolor, vector, '1 1 0');
/* modelname */ ATTRIB(NailGun, mdl, string, "nailgun");
#ifndef MENUQC
/* model     */ ATTRIB(NailGun, m_model, Model, MDL_NAILGUN_ITEM);
#endif
/* crosshair */ ATTRIB(NailGun, w_crosshair, string, "gfx/crosshairuzi");
/* crosshair */ ATTRIB(NailGun, w_crosshair_size, float, 0.6);
/* wepimg    */ ATTRIB(NailGun, model2, string, "weaponuzi");
/* refname   */ ATTRIB(NailGun, netname, string, "nailgun");
/* wepname   */ ATTRIB(NailGun, m_name, string, _("NailGun"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, spread_min, float, NONE) \
		P(class, prefix, spread_max, float, NONE) \
		P(class, prefix, spread_add, float, NONE) \
		P(class, prefix, mode, float, NONE) \
		P(class, prefix, first, float, NONE) \
		P(class, prefix, first_ammo, float, NONE) \
		P(class, prefix, first_damage, float, NONE) \
		P(class, prefix, first_force, float, NONE) \
		P(class, prefix, first_refire, float, NONE) \
		P(class, prefix, first_spread, float, NONE) \
		P(class, prefix, solidpenetration, float, NONE) \
		P(class, prefix, sustained_damage, float, NONE) \
		P(class, prefix, sustained_force, float, NONE) \
		P(class, prefix, sustained_refire, float, NONE) \
		P(class, prefix, sustained_spread, float, NONE) \
		P(class, prefix, sustained_ammo, float, NONE) \
		P(class, prefix, burst, float, NONE) \
		P(class, prefix, burst_refire, float, NONE) \
		P(class, prefix, burst_refire2, float, NONE) \
		P(class, prefix, burst_animtime, float, NONE) \
		P(class, prefix, burst_speed, float, NONE) \
		P(class, prefix, burst_ammo, float, NONE) \
		P(class, prefix, reload_ammo, float, NONE) \
        P(class, prefix, reload_time, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, weaponreplace, string, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_MOD_PROPS(X, NailGun, nailgun)
#undef X

ENDCLASS(NailGun)
REGISTER_WEAPON(NAILGUN, nailgun, NEW(NailGun));

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC

spawnfunc(weapon_qnailgun) { weapon_defaultspawnfunc(this, WEP_NAILGUN); }

void W_NailGun_MuzzleFlash_Think(entity this)
{
	this.frame = this.frame + 2;
	this.scale = this.scale * 0.5;
	this.alpha = this.alpha - 0.25;
	this.nextthink = time + 0.05;

	if(this.alpha <= 0)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		this.realowner.muzzle_flash = world;
		return;
	}

}

void W_NailGun_MuzzleFlash(entity this)
{
	if(this.muzzle_flash == world)
		this.muzzle_flash = spawn();

	// muzzle flash for 1st person view
	setmodel(this.muzzle_flash, MDL_MACHINEGUN_MUZZLEFLASH); // precision set below

	this.muzzle_flash.scale = 0.75;
	setthink(this.muzzle_flash, W_NailGun_MuzzleFlash_Think);
	this.muzzle_flash.nextthink = time + 0.02;
	this.muzzle_flash.frame = 2;
	this.muzzle_flash.alpha = 0.75;
	this.muzzle_flash.angles_z = random() * 180;
	this.muzzle_flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	this.muzzle_flash.owner = this.muzzle_flash.realowner = this;
}

void W_NailGun_Attack(Weapon thiswep, entity actor, int deathtype)
{
	W_SetupShot(actor, true, 0, SND_NAILGUN_FIRE, CH_WEAPON_A, ((actor.misc_bulletcounter == 1) ? WEP_CVAR(nailgun, first_damage) : WEP_CVAR(nailgun, sustained_damage)));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	int slot = 0;
	ATTACK_FINISHED(actor, slot) = time + WEP_CVAR(nailgun, first_refire) * W_WeaponRateFactor(actor);

	vector ang = '0 0 0';
	if(actor.misc_bulletcounter % 2)
		ang = v_right;
	else
		ang = v_right * -1;

	if(actor.misc_bulletcounter == 1)
		fireBullet(actor, w_shotorg + ang, w_shotdir + (ang * 0.03), WEP_CVAR(nailgun, first_spread), WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, first_damage), WEP_CVAR(nailgun, first_force), deathtype, 0);
	else
		fireBullet(actor, w_shotorg + ang, w_shotdir + (ang * 0.03), WEP_CVAR(nailgun, sustained_spread), WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, sustained_damage), WEP_CVAR(nailgun, sustained_force), deathtype, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg + ang, (w_shotdir + (ang * 0.03)) * 1000, 1);

	W_NailGun_MuzzleFlash(actor);

	vector vecs = '5 0 0';
	vecs.y = 4.5;
	if(actor.misc_bulletcounter % 2)
		vecs.y = -4.5;
	W_AttachToShotorg(actor, actor.muzzle_flash, vecs);

	// casing code
	if(autocvar_g_casings >= 2)
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor);

	if(actor.misc_bulletcounter == 1)
		W_DecreaseAmmo(thiswep, actor, WEP_CVAR(nailgun, first_ammo));
	else
		W_DecreaseAmmo(thiswep, actor, WEP_CVAR(nailgun, sustained_ammo));
}

// weapon frames
void W_NailGun_Attack_Frame(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	if(PS(actor).m_switchweapon != PS(actor).m_weapon) // abort immediately if switching
	{
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}
	if(PHYS_INPUT_BUTTON_ATCK(actor))
	{
		Weapon w = Weapons_from(PS(actor).m_weapon.m_id);
		if(!w.wr_checkammo2(w, actor))
		if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
			w_ready(thiswep, actor, weaponentity, fire);
			return;
		}
		actor.misc_bulletcounter = actor.misc_bulletcounter + 1;
		W_NailGun_Attack(WEP_NAILGUN, actor, WEP_NAILGUN.m_id);
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), W_NailGun_Attack_Frame);
	}
	else
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), w_ready);
}


void W_NailGun_Attack_Auto(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	float nailgun_spread;

	if(!fire & 1)
	{
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}

	Weapon w = Weapons_from(PS(actor).m_weapon.m_id);
	if(!w.wr_checkammo1(w, actor))
	if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}

	W_DecreaseAmmo(WEP_NAILGUN, actor, WEP_CVAR(nailgun, sustained_ammo));

	W_SetupShot(actor, true, 0, SND_NAILGUN_FIRE, CH_WEAPON_A, WEP_CVAR(nailgun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	vector ang = '0 0 0';
	if(actor.misc_bulletcounter % 2)
		ang = v_right;
	else
		ang = v_right * -1;

	nailgun_spread = bound(WEP_CVAR(nailgun, spread_min), WEP_CVAR(nailgun, spread_min) + (WEP_CVAR(nailgun, spread_add) * actor.misc_bulletcounter), WEP_CVAR(nailgun, spread_max));
	fireBullet(actor, w_shotorg + ang, w_shotdir + (ang * 0.03), nailgun_spread, WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, sustained_damage), WEP_CVAR(nailgun, sustained_force), WEP_NAILGUN.m_id, 0);

	actor.misc_bulletcounter = actor.misc_bulletcounter + 1;

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg + ang, (w_shotdir + (ang * 0.03)) * 1000, 1);

	W_NailGun_MuzzleFlash(actor);
	vector vecs = '5 0 0';
	vecs.y = 4.5;
	if(actor.misc_bulletcounter % 2)
		vecs.y = -4.5;
	W_AttachToShotorg(actor, actor.muzzle_flash, vecs);

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor);

	ATTACK_FINISHED(actor, 0) = time + WEP_CVAR(nailgun, first_refire) * W_WeaponRateFactor(actor);
	weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), W_NailGun_Attack_Auto);
}

void W_NailGun_Attack_Burst(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	W_SetupShot(actor, true, 0, SND_NAILGUN_FIRE, CH_WEAPON_A, WEP_CVAR(nailgun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	vector ang = '0 0 0';
	if(actor.misc_bulletcounter % 2)
		ang = v_right;
	else
		ang = v_right * -1;

	fireBullet(actor, w_shotorg + ang, w_shotdir + (ang * 0.03), WEP_CVAR(nailgun, burst_speed), WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, sustained_damage), WEP_CVAR(nailgun, sustained_force), WEP_NAILGUN.m_id, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg + ang, (w_shotdir + (ang * 0.03)) * 1000, 1);

	W_NailGun_MuzzleFlash(actor);
	vector vecs = '5 0 0';
	vecs.y = 4.5;
	if(actor.misc_bulletcounter % 2)
		vecs.y = -4.5;
	W_AttachToShotorg(actor, actor.muzzle_flash, vecs);

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor);

	actor.misc_bulletcounter = actor.misc_bulletcounter + 1;
	if(actor.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(actor, 0) = time + WEP_CVAR(nailgun, burst_refire2) * W_WeaponRateFactor(actor);
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(nailgun, burst_animtime), w_ready);
	}
	else
	{
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(nailgun, burst_refire), W_NailGun_Attack_Burst);
	}

}

		METHOD(NailGun, wr_aim, void(entity thiswep, entity actor))
		{
			if(vdist(actor.origin - actor.enemy.origin, <, 3000 - bound(0, skill, 10) * 200))
				PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, 1000000, 0, 0.001, false);
			else
				PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, 1000000, 0, 0.001, false);
		}
		METHOD(NailGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if(WEP_CVAR(nailgun, reload_ammo) && actor.clip_load < min(max(WEP_CVAR(nailgun, sustained_ammo), WEP_CVAR(nailgun, first_ammo)), WEP_CVAR(nailgun, burst_ammo))) { // forced reload
				Weapon w = Weapons_from(actor.weapon);
				w.wr_reload(w, actor, weaponentity);
			} else
			if(WEP_CVAR(nailgun, mode) == 1)
			{
				if(fire & 1)
				if(weapon_prepareattack(thiswep, actor, weaponentity, false, 0))
				{
					actor.misc_bulletcounter = 0;
					W_NailGun_Attack_Auto(thiswep, actor, weaponentity, fire);
				}

				if(fire & 2)
				if(weapon_prepareattack(thiswep, actor, weaponentity, true, 0))
				{
					Weapon w = Weapons_from(actor.weapon);
					if(!w.wr_checkammo2(w, actor))
					if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
					{
						W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
						w_ready(thiswep, actor, weaponentity, fire);
						return;
					}

					W_DecreaseAmmo(thiswep, actor, WEP_CVAR(nailgun, burst_ammo));

					actor.misc_bulletcounter = WEP_CVAR(nailgun, burst) * -1;
					W_NailGun_Attack_Burst(thiswep, actor, weaponentity, fire);
				}
			}
			else
			{

				if(fire & 1)
				if(weapon_prepareattack(thiswep, actor, weaponentity, false, 0))
				{
					actor.misc_bulletcounter = 1;
					W_NailGun_Attack(WEP_NAILGUN, actor, WEP_NAILGUN.m_id); // sets attack_finished
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), W_NailGun_Attack_Frame);
				}

				if((fire & 2) && WEP_CVAR(nailgun, first))
				if(weapon_prepareattack(thiswep, actor, weaponentity, true, 0))
				{
					actor.misc_bulletcounter = 1;
					W_NailGun_Attack(WEP_NAILGUN, actor, WEP_NAILGUN.m_id | HITTYPE_SECONDARY); // sets attack_finished
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(nailgun, first_refire), w_ready);
				}
			}
		}
		METHOD(NailGun, wr_checkammo1, bool(entity thiswep, entity actor))
		{
			float ammo_amount;
			if(WEP_CVAR(nailgun, mode) == 1)
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(nailgun, sustained_ammo);
			else
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(nailgun, first_ammo);

			if(WEP_CVAR(nailgun, reload_ammo))
			{
				if(WEP_CVAR(nailgun, mode) == 1)
					ammo_amount += actor.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, sustained_ammo);
				else
					ammo_amount += actor.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(NailGun, wr_checkammo2, bool(entity thiswep, entity actor))
		{
			float ammo_amount;
			if(WEP_CVAR(nailgun, mode) == 1)
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(nailgun, burst_ammo);
			else
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(nailgun, first_ammo);

			if(WEP_CVAR(nailgun, reload_ammo))
			{
				if(WEP_CVAR(nailgun, mode) == 1)
					ammo_amount += actor.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, burst_ammo);
				else
					ammo_amount += actor.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(NailGun, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
		{
			W_Reload(actor, min(max(WEP_CVAR(nailgun, sustained_ammo), WEP_CVAR(nailgun, first_ammo)), WEP_CVAR(nailgun, burst_ammo)), SND_RELOAD);
		}
		METHOD(NailGun, wr_suicidemessage, Notification(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(NailGun, wr_killmessage, Notification(entity thiswep))
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_MACHINEGUN_MURDER_SNIPE;
			else
				return WEAPON_MACHINEGUN_MURDER_SPRAY;
		}

#endif
#ifdef CSQC

		METHOD(NailGun, wr_impacteffect, void(entity thiswep, entity actor))
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			__pointparticles(particleeffectnum(EFFECT_MACHINEGUN_IMPACT), org2, w_backoff * 1000, 1);
			if(!w_issilent)
				if(w_random < 0.05)
					sound(actor, CH_SHOTS, SND_RIC1, VOL_BASE, ATTN_NORM);
				else if(w_random < 0.1)
					sound(actor, CH_SHOTS, SND_RIC2, VOL_BASE, ATTN_NORM);
				else if(w_random < 0.2)
					sound(actor, CH_SHOTS, SND_RIC3, VOL_BASE, ATTN_NORM);
		}

#endif
#endif
