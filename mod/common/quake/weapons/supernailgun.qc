#ifndef IMPLEMENTATION
#ifndef MENUQC
SOUND(SUPERNAILGUN_FIRE, "quake_weapons/rocket1i");

MODEL(SUPERNAILGUN_VIEW,                  W_Model("h_supernailgun.iqm"));
MODEL(SUPERNAILGUN_WORLD,                 W_Model("v_supernailgun.md3"));
MODEL(SUPERNAILGUN_ITEM,                  W_Model("g_supernailgun.md3"));
#endif

float autocvar_g_balance_supernailgun_burst = 3;
float autocvar_g_balance_supernailgun_burst_ammo = 3;
float autocvar_g_balance_supernailgun_burst_animtime = 0.3;
float autocvar_g_balance_supernailgun_burst_refire = 0.06;
float autocvar_g_balance_supernailgun_burst_refire2 = 0.45;
float autocvar_g_balance_supernailgun_burst_speed = 0;
float autocvar_g_balance_supernailgun_first = 0;
float autocvar_g_balance_supernailgun_first_ammo = 1;
float autocvar_g_balance_supernailgun_first_damage = 5;
float autocvar_g_balance_supernailgun_first_force = 5;
float autocvar_g_balance_supernailgun_first_refire = 0.125;
float autocvar_g_balance_supernailgun_first_spread = 0.03;
float autocvar_g_balance_supernailgun_mode = 0;
float autocvar_g_balance_supernailgun_reload_ammo = 0;
float autocvar_g_balance_supernailgun_reload_time = 2;
float autocvar_g_balance_supernailgun_solidpenetration = 13.1;
float autocvar_g_balance_supernailgun_spread_add = 0.012;
float autocvar_g_balance_supernailgun_spread_max = 0.02;
float autocvar_g_balance_supernailgun_spread_min = 0.01;
float autocvar_g_balance_supernailgun_sustained_ammo = 2;
float autocvar_g_balance_supernailgun_sustained_damage = 18;
float autocvar_g_balance_supernailgun_sustained_force = 5;
float autocvar_g_balance_supernailgun_sustained_refire = 0.14;
float autocvar_g_balance_supernailgun_sustained_spread = 0.01;
float autocvar_g_balance_supernailgun_switchdelay_drop = 0.2;
float autocvar_g_balance_supernailgun_switchdelay_raise = 0.2;
string autocvar_g_balance_supernailgun_weaponreplace = "";
float autocvar_g_balance_supernailgun_weaponstart = 0;
float autocvar_g_balance_supernailgun_weaponstartoverride = -1;
float autocvar_g_balance_supernailgun_weaponthrowable = 1;

CLASS(SuperNailGun, Weapon)
/* ammotype  */ ATTRIB(SuperNailGun, ammo_field, .int, ammo_nails);
/* impulse   */ ATTRIB(SuperNailGun, impulse, int, 5);
/* flags     */ ATTRIB(SuperNailGun, spawnflags, int, WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN);
/* rating    */ ATTRIB(SuperNailGun, bot_pickupbasevalue, float, BOT_PICKUP_RATING_MID);
/* color     */ ATTRIB(SuperNailGun, wpcolor, vector, '1 1 0');
/* modelname */ ATTRIB(SuperNailGun, mdl, string, "supernailgun");
#ifndef MENUQC
/* model     */ ATTRIB(SuperNailGun, m_model, Model, MDL_SUPERNAILGUN_ITEM);
#endif
/* crosshair */ ATTRIB(SuperNailGun, w_crosshair, string, "gfx/crosshairuzi");
/* crosshair */ ATTRIB(SuperNailGun, w_crosshair_size, float, 0.6);
/* wepimg    */ ATTRIB(SuperNailGun, model2, string, "weaponhmg");
/* refname   */ ATTRIB(SuperNailGun, netname, string, "supernailgun");
/* wepname   */ ATTRIB(SuperNailGun, m_name, string, "Super NailGun");

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
    W_MOD_PROPS(X, SuperNailGun, supernailgun)
#undef X

ENDCLASS(SuperNailGun)
REGISTER_WEAPON(SUPERNAILGUN, supernailgun, NEW(SuperNailGun));

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC

spawnfunc(weapon_qsupernailgun) { weapon_defaultspawnfunc(this, WEP_SUPERNAILGUN); }

void W_SuperNailGun_Attack(Weapon thiswep, entity actor, .entity weaponentity, int deathtype)
{
	W_SetupShot(actor, weaponentity, true, 0, SND_SUPERNAILGUN_FIRE, CH_WEAPON_A, ((actor.misc_bulletcounter == 1) ? WEP_CVAR(supernailgun, first_damage) : WEP_CVAR(supernailgun, sustained_damage)));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	int slot = 0;
	ATTACK_FINISHED(actor, slot) = time + WEP_CVAR(supernailgun, first_refire) * W_WeaponRateFactor(actor);

	if(actor.misc_bulletcounter == 1)
		fireBullet(actor, weaponentity, w_shotorg, w_shotdir, WEP_CVAR(supernailgun, first_spread), WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, first_damage), WEP_CVAR(supernailgun, first_force), deathtype, 0);
	else
		fireBullet(actor, weaponentity, w_shotorg, w_shotdir, WEP_CVAR(supernailgun, sustained_spread), WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, sustained_damage), WEP_CVAR(supernailgun, sustained_force), deathtype, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, (w_shotdir) * 1000, 1);

	W_MachineGun_MuzzleFlash(actor, weaponentity);

	W_AttachToShotorg(actor, weaponentity, actor.(weaponentity).muzzle_flash, '5 0 0');

	// casing code
	if(autocvar_g_casings >= 2)
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor, weaponentity);

	if(actor.misc_bulletcounter == 1)
		W_DecreaseAmmo(thiswep, actor, WEP_CVAR(supernailgun, first_ammo), weaponentity);
	else
		W_DecreaseAmmo(thiswep, actor, WEP_CVAR(supernailgun, sustained_ammo), weaponentity);
}

// weapon frames
void W_SuperNailGun_Attack_Frame(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	if(actor.(weaponentity).m_switchweapon != actor.(weaponentity).m_weapon) // abort immediately if switching
	{
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}
	if(PHYS_INPUT_BUTTON_ATCK(actor))
	{
		Weapon w = Weapons_from(actor.(weaponentity).m_weapon.m_id);
		if(!w.wr_checkammo2(w, actor, weaponentity))
		if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
			w_ready(thiswep, actor, weaponentity, fire);
			return;
		}
		actor.misc_bulletcounter = actor.misc_bulletcounter + 1;
		W_SuperNailGun_Attack(WEP_SUPERNAILGUN, actor, weaponentity, WEP_SUPERNAILGUN.m_id);
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(supernailgun, sustained_refire), W_SuperNailGun_Attack_Frame);
	}
	else
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(supernailgun, sustained_refire), w_ready);
}


void W_SuperNailGun_Attack_Auto(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	float supernailgun_spread;

	if(!fire & 1)
	{
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}

	Weapon w = Weapons_from(actor.(weaponentity).m_weapon.m_id);
	if(!w.wr_checkammo1(w, actor, weaponentity))
	if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}

	W_DecreaseAmmo(WEP_SUPERNAILGUN, actor, WEP_CVAR(supernailgun, sustained_ammo), weaponentity);

	W_SetupShot(actor, weaponentity, true, 0, SND_SUPERNAILGUN_FIRE, CH_WEAPON_A, WEP_CVAR(supernailgun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	supernailgun_spread = bound(WEP_CVAR(supernailgun, spread_min), WEP_CVAR(supernailgun, spread_min) + (WEP_CVAR(supernailgun, spread_add) * actor.misc_bulletcounter), WEP_CVAR(supernailgun, spread_max));
	fireBullet(actor, weaponentity, w_shotorg, w_shotdir, supernailgun_spread, WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, sustained_damage), WEP_CVAR(supernailgun, sustained_force), WEP_SUPERNAILGUN.m_id, 0);

	actor.misc_bulletcounter = actor.misc_bulletcounter + 1;

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, (w_shotdir) * 1000, 1);

	W_MachineGun_MuzzleFlash(actor, weaponentity);
	W_AttachToShotorg(actor, weaponentity, actor.(weaponentity).muzzle_flash, '5 0 0');

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor, weaponentity);

	ATTACK_FINISHED(actor, 0) = time + WEP_CVAR(supernailgun, first_refire) * W_WeaponRateFactor(actor);
	weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(supernailgun, sustained_refire), W_SuperNailGun_Attack_Auto);
}

void W_SuperNailGun_Attack_Burst(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	W_SetupShot(actor, weaponentity, true, 0, SND_SUPERNAILGUN_FIRE, CH_WEAPON_A, WEP_CVAR(supernailgun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	fireBullet(actor, weaponentity, w_shotorg, w_shotdir, WEP_CVAR(supernailgun, burst_speed), WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, sustained_damage), WEP_CVAR(supernailgun, sustained_force), WEP_SUPERNAILGUN.m_id, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, (w_shotdir) * 1000, 1);

	W_MachineGun_MuzzleFlash(actor, weaponentity);
	W_AttachToShotorg(actor, weaponentity, actor.(weaponentity).muzzle_flash, '5 0 0');

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor, weaponentity);

	actor.misc_bulletcounter = actor.misc_bulletcounter + 1;
	if(actor.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(actor, 0) = time + WEP_CVAR(supernailgun, burst_refire2) * W_WeaponRateFactor(actor);
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(supernailgun, burst_animtime), w_ready);
	}
	else
	{
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(supernailgun, burst_refire), W_SuperNailGun_Attack_Burst);
	}

}

		METHOD(SuperNailGun, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
		{
			if(vdist(actor.origin - actor.enemy.origin, <, 3000 - bound(0, skill, 10) * 200))
				PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
			else
				PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
		}
		METHOD(SuperNailGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if(WEP_CVAR(supernailgun, reload_ammo) && actor.clip_load < min(max(WEP_CVAR(supernailgun, sustained_ammo), WEP_CVAR(supernailgun, first_ammo)), WEP_CVAR(supernailgun, burst_ammo))) { // forced reload
				Weapon w = Weapons_from(actor.weapon);
				w.wr_reload(w, actor, weaponentity);
			} else
			if(WEP_CVAR(supernailgun, mode) == 1)
			{
				if(fire & 1)
				if(weapon_prepareattack(thiswep, actor, weaponentity, false, 0))
				{
					actor.misc_bulletcounter = 0;
					W_SuperNailGun_Attack_Auto(thiswep, actor, weaponentity, fire);
				}

				if(fire & 2)
				if(weapon_prepareattack(thiswep, actor, weaponentity, true, 0))
				{
					Weapon w = Weapons_from(actor.weapon);
					if(!w.wr_checkammo2(w, actor, weaponentity))
					if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
					{
						W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
						w_ready(thiswep, actor, weaponentity, fire);
						return;
					}

					W_DecreaseAmmo(thiswep, actor, WEP_CVAR(supernailgun, burst_ammo), weaponentity);

					actor.misc_bulletcounter = WEP_CVAR(supernailgun, burst) * -1;
					W_SuperNailGun_Attack_Burst(thiswep, actor, weaponentity, fire);
				}
			}
			else
			{

				if(fire & 1)
				if(weapon_prepareattack(thiswep, actor, weaponentity, false, 0))
				{
					actor.misc_bulletcounter = 1;
					W_SuperNailGun_Attack(WEP_SUPERNAILGUN, actor, weaponentity, WEP_SUPERNAILGUN.m_id); // sets attack_finished
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(supernailgun, sustained_refire), W_SuperNailGun_Attack_Frame);
				}

				if(fire & 2 && WEP_CVAR(supernailgun, first))
				if(weapon_prepareattack(thiswep, actor, weaponentity, true, 0))
				{
					actor.misc_bulletcounter = 1;
					W_SuperNailGun_Attack(WEP_SUPERNAILGUN, actor, weaponentity, WEP_SUPERNAILGUN.m_id | HITTYPE_SECONDARY); // sets attack_finished
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(supernailgun, first_refire), w_ready);
				}
			}
		}
		METHOD(SuperNailGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			float ammo_amount;
			if(WEP_CVAR(supernailgun, mode) == 1)
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(supernailgun, sustained_ammo);
			else
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(supernailgun, first_ammo);

			if(WEP_CVAR(supernailgun, reload_ammo))
			{
				if(WEP_CVAR(supernailgun, mode) == 1)
					ammo_amount += actor.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, sustained_ammo);
				else
					ammo_amount += actor.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(SuperNailGun, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			float ammo_amount;
			if(WEP_CVAR(supernailgun, mode) == 1)
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(supernailgun, burst_ammo);
			else
				ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(supernailgun, first_ammo);

			if(WEP_CVAR(supernailgun, reload_ammo))
			{
				if(WEP_CVAR(supernailgun, mode) == 1)
					ammo_amount += actor.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, burst_ammo);
				else
					ammo_amount += actor.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(SuperNailGun, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
		{
			W_Reload(actor, weaponentity, min(max(WEP_CVAR(supernailgun, sustained_ammo), WEP_CVAR(supernailgun, first_ammo)), WEP_CVAR(supernailgun, burst_ammo)), SND_RELOAD);
		}
		METHOD(SuperNailGun, wr_suicidemessage, Notification(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(SuperNailGun, wr_killmessage, Notification(entity thiswep))
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_MACHINEGUN_MURDER_SNIPE;
			else
				return WEAPON_MACHINEGUN_MURDER_SPRAY;
		}

#endif
#ifdef CSQC

		METHOD(SuperNailGun, wr_impacteffect, void(entity thiswep, entity actor))
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
