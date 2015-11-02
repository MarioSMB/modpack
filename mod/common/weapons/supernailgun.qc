#ifndef IMPLEMENTATION
#ifndef MENUQC
SOUND(SUPERNAILGUN_FIRE, "quake_weapons/rocket1i.wav");

MODEL(SUPERNAILGUN_VIEW,                  W_Model("h_supernailgun.iqm"));
MODEL(SUPERNAILGUN_WORLD,                 W_Model("v_supernailgun.md3"));
MODEL(SUPERNAILGUN_ITEM,                  W_Model("g_supernailgun.md3"));
#endif

CLASS(SuperNailGun, Weapon)
/* ammotype  */ ATTRIB(SuperNailGun, ammo_field, .int, ammo_nails)
/* impulse   */ ATTRIB(SuperNailGun, impulse, int, 5)
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
/* wepname   */ ATTRIB(SuperNailGun, m_name, string, _("Super NailGun"));
ENDCLASS(SuperNailGun)
REGISTER_WEAPON(SUPERNAILGUN, NEW(SuperNailGun));

#ifdef SVQC
STATIC_INIT(supernailgun_cvars)
{
	localcmd("\ng_balance_supernailgun_burst 3\n");
	localcmd("\ng_balance_supernailgun_burst_ammo 3\n");
	localcmd("\ng_balance_supernailgun_burst_animtime 0.3\n");
	localcmd("\ng_balance_supernailgun_burst_refire 0.06\n");
	localcmd("\ng_balance_supernailgun_burst_refire2 0.45\n");
	localcmd("\ng_balance_supernailgun_burst_speed 0\n");
	localcmd("\ng_balance_supernailgun_first 0\n");
	localcmd("\ng_balance_supernailgun_first_ammo 1\n");
	localcmd("\ng_balance_supernailgun_first_damage 5\n");
	localcmd("\ng_balance_supernailgun_first_force 5\n");
	localcmd("\ng_balance_supernailgun_first_refire 0.125\n");
	localcmd("\ng_balance_supernailgun_first_spread 0.03\n");
	localcmd("\ng_balance_supernailgun_mode 0\n");
	localcmd("\ng_balance_supernailgun_reload_ammo 0\n");
	localcmd("\ng_balance_supernailgun_reload_time 2\n");
	localcmd("\ng_balance_supernailgun_solidpenetration 13.1\n");
	localcmd("\ng_balance_supernailgun_spread_add 0.012\n");
	localcmd("\ng_balance_supernailgun_spread_max 0.02\n");
	localcmd("\ng_balance_supernailgun_spread_min 0.01\n");
	localcmd("\ng_balance_supernailgun_sustained_ammo 2\n");
	localcmd("\ng_balance_supernailgun_sustained_damage 18\n");
	localcmd("\ng_balance_supernailgun_sustained_force 5\n");
	localcmd("\ng_balance_supernailgun_sustained_refire 0.14\n");
	localcmd("\ng_balance_supernailgun_sustained_spread 0.01\n");
	localcmd("\ng_balance_supernailgun_switchdelay_drop 0.2\n");
	localcmd("\ng_balance_supernailgun_switchdelay_raise 0.2\n");
	localcmd("\ng_balance_supernailgun_weaponreplace \"\"\n");
	localcmd("\ng_balance_supernailgun_weaponstart 0\n");
	localcmd("\ng_balance_supernailgun_weaponstartoverride -1\n");
	localcmd("\ng_balance_supernailgun_weaponthrowable 1\n");
}
#endif

#define SUPERNAILGUN_SETTINGS(w_cvar,w_prop) SUPERNAILGUN_SETTINGS_LIST(w_cvar, w_prop, SUPERNAILGUN, supernailgun)
#define SUPERNAILGUN_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, spread_min) \
	w_cvar(id, sn, NONE, spread_max) \
	w_cvar(id, sn, NONE, spread_add) \
	w_cvar(id, sn, NONE, mode) \
	w_cvar(id, sn, NONE, first) \
	w_cvar(id, sn, NONE, first_damage) \
	w_cvar(id, sn, NONE, first_force) \
	w_cvar(id, sn, NONE, first_refire) \
	w_cvar(id, sn, NONE, first_spread) \
	w_cvar(id, sn, NONE, first_ammo) \
	w_cvar(id, sn, NONE, solidpenetration) \
	w_cvar(id, sn, NONE, sustained_damage) \
	w_cvar(id, sn, NONE, sustained_force) \
	w_cvar(id, sn, NONE, sustained_refire) \
	w_cvar(id, sn, NONE, sustained_spread) \
	w_cvar(id, sn, NONE, sustained_ammo) \
	w_cvar(id, sn, NONE, burst) \
	w_cvar(id, sn, NONE, burst_refire) \
	w_cvar(id, sn, NONE, burst_refire2) \
	w_cvar(id, sn, NONE, burst_animtime) \
	w_cvar(id, sn, NONE, burst_speed) \
	w_cvar(id, sn, NONE, burst_ammo) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
SUPERNAILGUN_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#endif
#ifdef IMPLEMENTATION
#ifdef SVQC

spawnfunc(weapon_qsupernailgun) { weapon_defaultspawnfunc(this, WEP_SUPERNAILGUN); }

void W_SuperNailGun_MuzzleFlash_Think(void)
{SELFPARAM();
	self.frame = self.frame + 2;
	self.scale = self.scale * 0.5;
	self.alpha = self.alpha - 0.25;
	self.nextthink = time + 0.05;

	if(self.alpha <= 0)
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		self.realowner.muzzle_flash = world;
		return;
	}

}

void W_SuperNailGun_MuzzleFlash(void)
{SELFPARAM();
	if(self.muzzle_flash == world)
		self.muzzle_flash = spawn();

	// muzzle flash for 1st person view
	setmodel(self.muzzle_flash, MDL_MACHINEGUN_MUZZLEFLASH); // precision set below

	self.muzzle_flash.scale = 0.75;
	self.muzzle_flash.think = W_SuperNailGun_MuzzleFlash_Think;
	self.muzzle_flash.nextthink = time + 0.02;
	self.muzzle_flash.frame = 2;
	self.muzzle_flash.alpha = 0.75;
	self.muzzle_flash.angles_z = random() * 180;
	self.muzzle_flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	self.muzzle_flash.owner = self.muzzle_flash.realowner = self;
}

void W_SuperNailGun_Attack(Weapon thiswep, int deathtype)
{SELFPARAM();
	W_SetupShot(self, true, 0, SND(SUPERNAILGUN_FIRE), CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? WEP_CVAR(supernailgun, first_damage) : WEP_CVAR(supernailgun, sustained_damage)));
	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random() - 0.5;
		self.punchangle_y = random() - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	int slot = 0;
	ATTACK_FINISHED(self, slot) = time + WEP_CVAR(supernailgun, first_refire) * W_WeaponRateFactor();

	if(self.misc_bulletcounter == 1)
		fireBullet(w_shotorg, w_shotdir, WEP_CVAR(supernailgun, first_spread), WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, first_damage), WEP_CVAR(supernailgun, first_force), deathtype, 0);
	else
		fireBullet(w_shotorg, w_shotdir, WEP_CVAR(supernailgun, sustained_spread), WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, sustained_damage), WEP_CVAR(supernailgun, sustained_force), deathtype, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, (w_shotdir) * 1000, 1);

	W_SuperNailGun_MuzzleFlash();

	W_AttachToShotorg(self, self.muzzle_flash, '5 0 0');

	// casing code
	if(autocvar_g_casings >= 2)
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

	if(self.misc_bulletcounter == 1)
		W_DecreaseAmmo(thiswep, self, WEP_CVAR(supernailgun, first_ammo));
	else
		W_DecreaseAmmo(thiswep, self, WEP_CVAR(supernailgun, sustained_ammo));
}

// weapon frames
void W_SuperNailGun_Attack_Frame(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	if(actor.weapon != actor.switchweapon) // abort immediately if switching
	{
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}
	if(actor.BUTTON_ATCK)
	{
		Weapon w = get_weaponinfo(actor.weapon);
		if(!w.wr_checkammo2(w))
		if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
			w_ready(thiswep, actor, weaponentity, fire);
			return;
		}
		actor.misc_bulletcounter = actor.misc_bulletcounter + 1;
		W_SuperNailGun_Attack(WEP_SUPERNAILGUN, WEP_SUPERNAILGUN.m_id);
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

	Weapon w = get_weaponinfo(actor.weapon);
	if(!w.wr_checkammo1(w))
	if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}

	W_DecreaseAmmo(WEP_SUPERNAILGUN, actor, WEP_CVAR(supernailgun, sustained_ammo));

	W_SetupShot(actor, true, 0, SND(SUPERNAILGUN_FIRE), CH_WEAPON_A, WEP_CVAR(supernailgun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	supernailgun_spread = bound(WEP_CVAR(supernailgun, spread_min), WEP_CVAR(supernailgun, spread_min) + (WEP_CVAR(supernailgun, spread_add) * actor.misc_bulletcounter), WEP_CVAR(supernailgun, spread_max));
	fireBullet(w_shotorg, w_shotdir, supernailgun_spread, WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, sustained_damage), WEP_CVAR(supernailgun, sustained_force), WEP_SUPERNAILGUN.m_id, 0);

	actor.misc_bulletcounter = actor.misc_bulletcounter + 1;

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, (w_shotdir) * 1000, 1);

	W_SuperNailGun_MuzzleFlash();
	W_AttachToShotorg(actor, actor.muzzle_flash, '5 0 0');

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor);

	ATTACK_FINISHED(actor, 0) = time + WEP_CVAR(supernailgun, first_refire) * W_WeaponRateFactor();
	weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(supernailgun, sustained_refire), W_SuperNailGun_Attack_Auto);
}

void W_SuperNailGun_Attack_Burst(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	W_SetupShot(actor, true, 0, SND(SUPERNAILGUN_FIRE), CH_WEAPON_A, WEP_CVAR(supernailgun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	fireBullet(w_shotorg, w_shotdir, WEP_CVAR(supernailgun, burst_speed), WEP_CVAR(supernailgun, solidpenetration), WEP_CVAR(supernailgun, sustained_damage), WEP_CVAR(supernailgun, sustained_force), WEP_SUPERNAILGUN.m_id, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, (w_shotdir) * 1000, 1);

	W_SuperNailGun_MuzzleFlash();
	W_AttachToShotorg(actor, actor.muzzle_flash, '5 0 0');

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor);

	actor.misc_bulletcounter = actor.misc_bulletcounter + 1;
	if(actor.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(actor, 0) = time + WEP_CVAR(supernailgun, burst_refire2) * W_WeaponRateFactor();
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(supernailgun, burst_animtime), w_ready);
	}
	else
	{
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(supernailgun, burst_refire), W_SuperNailGun_Attack_Burst);
	}

}

		METHOD(SuperNailGun, wr_aim, void(entity thiswep))
		{
			if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, false);
			else
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, false);
		}
		METHOD(SuperNailGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if(WEP_CVAR(supernailgun, reload_ammo) && actor.clip_load < min(max(WEP_CVAR(supernailgun, sustained_ammo), WEP_CVAR(supernailgun, first_ammo)), WEP_CVAR(supernailgun, burst_ammo))) { // forced reload
				Weapon w = get_weaponinfo(actor.weapon);
				w.wr_reload(w);
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
					Weapon w = get_weaponinfo(actor.weapon);
					if(!w.wr_checkammo2(w))
					if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
					{
						W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
						w_ready(thiswep, actor, weaponentity, fire);
						return;
					}

					W_DecreaseAmmo(thiswep, actor, WEP_CVAR(supernailgun, burst_ammo));

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
					W_SuperNailGun_Attack(WEP_SUPERNAILGUN, WEP_SUPERNAILGUN.m_id); // sets attack_finished
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(supernailgun, sustained_refire), W_SuperNailGun_Attack_Frame);
				}

				if(fire & 2 && WEP_CVAR(supernailgun, first))
				if(weapon_prepareattack(thiswep, actor, weaponentity, true, 0))
				{
					actor.misc_bulletcounter = 1;
					W_SuperNailGun_Attack(WEP_SUPERNAILGUN, WEP_SUPERNAILGUN.m_id | HITTYPE_SECONDARY); // sets attack_finished
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(supernailgun, first_refire), w_ready);
				}
			}
		}
		METHOD(SuperNailGun, wr_init, void(entity thiswep))
		{
			SUPERNAILGUN_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP);
		}
		METHOD(SuperNailGun, wr_checkammo1, bool(entity thiswep))
		{
			float ammo_amount;
			if(WEP_CVAR(supernailgun, mode) == 1)
				ammo_amount = self.WEP_AMMO(SUPERNAILGUN) >= WEP_CVAR(supernailgun, sustained_ammo);
			else
				ammo_amount = self.WEP_AMMO(SUPERNAILGUN) >= WEP_CVAR(supernailgun, first_ammo);

			if(WEP_CVAR(supernailgun, reload_ammo))
			{
				if(WEP_CVAR(supernailgun, mode) == 1)
					ammo_amount += self.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, sustained_ammo);
				else
					ammo_amount += self.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(SuperNailGun, wr_checkammo2, bool(entity thiswep))
		{
			float ammo_amount;
			if(WEP_CVAR(supernailgun, mode) == 1)
				ammo_amount = self.WEP_AMMO(SUPERNAILGUN) >= WEP_CVAR(supernailgun, burst_ammo);
			else
				ammo_amount = self.WEP_AMMO(SUPERNAILGUN) >= WEP_CVAR(supernailgun, first_ammo);

			if(WEP_CVAR(supernailgun, reload_ammo))
			{
				if(WEP_CVAR(supernailgun, mode) == 1)
					ammo_amount += self.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, burst_ammo);
				else
					ammo_amount += self.(weapon_load[WEP_SUPERNAILGUN.m_id]) >= WEP_CVAR(supernailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(SuperNailGun, wr_config, void(entity thiswep))
		{
			SUPERNAILGUN_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS);
		}
		METHOD(SuperNailGun, wr_reload, void(entity thiswep))
		{
			W_Reload(self, min(max(WEP_CVAR(supernailgun, sustained_ammo), WEP_CVAR(supernailgun, first_ammo)), WEP_CVAR(supernailgun, burst_ammo)), SND(RELOAD));
		}
		METHOD(SuperNailGun, wr_suicidemessage, int(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(SuperNailGun, wr_killmessage, int(entity thiswep))
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_MACHINEGUN_MURDER_SNIPE;
			else
				return WEAPON_MACHINEGUN_MURDER_SPRAY;
		}

#endif
#ifdef CSQC

		METHOD(SuperNailGun, wr_impacteffect, void(entity thiswep))
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			__pointparticles(particleeffectnum(EFFECT_MACHINEGUN_IMPACT), org2, w_backoff * 1000, 1);
			if(!w_issilent)
				if(w_random < 0.05)
					sound(self, CH_SHOTS, SND_RIC1, VOL_BASE, ATTN_NORM);
				else if(w_random < 0.1)
					sound(self, CH_SHOTS, SND_RIC2, VOL_BASE, ATTN_NORM);
				else if(w_random < 0.2)
					sound(self, CH_SHOTS, SND_RIC3, VOL_BASE, ATTN_NORM);
		}

#endif
#endif
