#ifndef IMPLEMENTATION
#ifndef MENUQC
SOUND(NAILGUN_FIRE, "quake_weapons/rocket1i.wav");

MODEL(NAILGUN_VIEW,                  W_Model("h_nailgun.iqm"));
MODEL(NAILGUN_WORLD,                 W_Model("v_nailgun.md3"));
MODEL(NAILGUN_ITEM,                  W_Model("g_nailgun.md3"));
#endif

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
/* wepname   */ ATTRIB(NailGun, message, string, _("NailGun"));
ENDCLASS(NailGun)
REGISTER_WEAPON(NAILGUN, NEW(NailGun));

#ifdef SVQC
STATIC_INIT(nailgun_cvars)
{
	localcmd("\ng_balance_nailgun_burst 3\n");
	localcmd("\ng_balance_nailgun_burst_ammo 3\n");
	localcmd("\ng_balance_nailgun_burst_animtime 0.3\n");
	localcmd("\ng_balance_nailgun_burst_refire 0.06\n");
	localcmd("\ng_balance_nailgun_burst_refire2 0.45\n");
	localcmd("\ng_balance_nailgun_burst_speed 0\n");
	localcmd("\ng_balance_nailgun_first 0\n");
	localcmd("\ng_balance_nailgun_first_ammo 1\n");
	localcmd("\ng_balance_nailgun_first_damage 5\n");
	localcmd("\ng_balance_nailgun_first_force 5\n");
	localcmd("\ng_balance_nailgun_first_refire 0.125\n");
	localcmd("\ng_balance_nailgun_first_spread 0.03\n");
	localcmd("\ng_balance_nailgun_mode 0\n");
	localcmd("\ng_balance_nailgun_reload_ammo 0\n");
	localcmd("\ng_balance_nailgun_reload_time 2\n");
	localcmd("\ng_balance_nailgun_solidpenetration 13.1\n");
	localcmd("\ng_balance_nailgun_spread_add 0.012\n");
	localcmd("\ng_balance_nailgun_spread_max 0.02\n");
	localcmd("\ng_balance_nailgun_spread_min 0.01\n");
	localcmd("\ng_balance_nailgun_sustained_ammo 1\n");
	localcmd("\ng_balance_nailgun_sustained_damage 9\n");
	localcmd("\ng_balance_nailgun_sustained_force 5\n");
	localcmd("\ng_balance_nailgun_sustained_refire 0.1\n");
	localcmd("\ng_balance_nailgun_sustained_spread 0.01\n");
	localcmd("\ng_balance_nailgun_switchdelay_drop 0.2\n");
	localcmd("\ng_balance_nailgun_switchdelay_raise 0.2\n");
	localcmd("\ng_balance_nailgun_weaponreplace \"\"\n");
	localcmd("\ng_balance_nailgun_weaponstart 0\n");
	localcmd("\ng_balance_nailgun_weaponstartoverride -1\n");
	localcmd("\ng_balance_nailgun_weaponthrowable 1\n");
}
#endif

#define NAILGUN_SETTINGS(w_cvar,w_prop) NAILGUN_SETTINGS_LIST(w_cvar, w_prop, NAILGUN, nailgun)
#define NAILGUN_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
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
NAILGUN_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#endif
#ifdef IMPLEMENTATION
#ifdef SVQC

spawnfunc(weapon_qnailgun) { weapon_defaultspawnfunc(WEP_NAILGUN.m_id); }

void W_NailGun_MuzzleFlash_Think(void)
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

void W_NailGun_MuzzleFlash(void)
{SELFPARAM();
	if(self.muzzle_flash == world)
		self.muzzle_flash = spawn();

	// muzzle flash for 1st person view
	setmodel(self.muzzle_flash, MDL_MACHINEGUN_MUZZLEFLASH); // precision set below

	self.muzzle_flash.scale = 0.75;
	self.muzzle_flash.think = W_NailGun_MuzzleFlash_Think;
	self.muzzle_flash.nextthink = time + 0.02;
	self.muzzle_flash.frame = 2;
	self.muzzle_flash.alpha = 0.75;
	self.muzzle_flash.angles_z = random() * 180;
	self.muzzle_flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	self.muzzle_flash.owner = self.muzzle_flash.realowner = self;
}

void W_NailGun_Attack(Weapon thiswep, int deathtype)
{SELFPARAM();
	W_SetupShot(self, true, 0, SND(NAILGUN_FIRE), CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? WEP_CVAR(nailgun, first_damage) : WEP_CVAR(nailgun, sustained_damage)));
	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random() - 0.5;
		self.punchangle_y = random() - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + WEP_CVAR(nailgun, first_refire) * W_WeaponRateFactor();

	vector ang = '0 0 0';
	if(self.misc_bulletcounter % 2)
		ang = v_right;
	else
		ang = v_right * -1;

	if(self.misc_bulletcounter == 1)
		fireBullet(w_shotorg + ang, w_shotdir + (ang * 0.03), WEP_CVAR(nailgun, first_spread), WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, first_damage), WEP_CVAR(nailgun, first_force), deathtype, 0);
	else
		fireBullet(w_shotorg + ang, w_shotdir + (ang * 0.03), WEP_CVAR(nailgun, sustained_spread), WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, sustained_damage), WEP_CVAR(nailgun, sustained_force), deathtype, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg + ang, (w_shotdir + (ang * 0.03)) * 1000, 1);

	W_NailGun_MuzzleFlash();

	vector vecs = '5 0 0';
	vecs.y = 4.5;
	if(self.misc_bulletcounter % 2)
		vecs.y = -4.5;
	W_AttachToShotorg(self, self.muzzle_flash, vecs);

	// casing code
	if(autocvar_g_casings >= 2)
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

	if(self.misc_bulletcounter == 1)
		W_DecreaseAmmo(thiswep, self, WEP_CVAR(nailgun, first_ammo));
	else
		W_DecreaseAmmo(thiswep, self, WEP_CVAR(nailgun, sustained_ammo));
}

// weapon frames
void W_NailGun_Attack_Frame(Weapon thiswep, entity actor, bool fire1, bool fire2)
{
	if(actor.weapon != actor.switchweapon) // abort immediately if switching
	{
		w_ready(thiswep, actor, fire1, fire2);
		return;
	}
	if(actor.BUTTON_ATCK)
	{
		Weapon w = get_weaponinfo(actor.weapon);
		if(!w.wr_checkammo2(w))
		if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
			w_ready(thiswep, actor, fire1, fire2);
			return;
		}
		actor.misc_bulletcounter = actor.misc_bulletcounter + 1;
		W_NailGun_Attack(WEP_NAILGUN, WEP_NAILGUN.m_id);
		weapon_thinkf(actor, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), W_NailGun_Attack_Frame);
	}
	else
		weapon_thinkf(actor, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), w_ready);
}


void W_NailGun_Attack_Auto(Weapon thiswep, entity actor, bool fire1, bool fire2)
{
	float nailgun_spread;

	if(!fire1)
	{
		w_ready(thiswep, actor, fire1, fire2);
		return;
	}

	Weapon w = get_weaponinfo(actor.weapon);
	if(!w.wr_checkammo1(w))
	if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
		w_ready(thiswep, actor, fire1, fire2);
		return;
	}

	W_DecreaseAmmo(WEP_NAILGUN, actor, WEP_CVAR(nailgun, sustained_ammo));

	W_SetupShot(actor, true, 0, SND(NAILGUN_FIRE), CH_WEAPON_A, WEP_CVAR(nailgun, sustained_damage));
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
	fireBullet(w_shotorg + ang, w_shotdir + (ang * 0.03), nailgun_spread, WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, sustained_damage), WEP_CVAR(nailgun, sustained_force), WEP_NAILGUN.m_id, 0);

	actor.misc_bulletcounter = actor.misc_bulletcounter + 1;

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg + ang, (w_shotdir + (ang * 0.03)) * 1000, 1);

	W_NailGun_MuzzleFlash();
	vector vecs = '5 0 0';
	vecs.y = 4.5;
	if(actor.misc_bulletcounter % 2)
		vecs.y = -4.5;
	W_AttachToShotorg(actor, actor.muzzle_flash, vecs);

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor);

	ATTACK_FINISHED(actor) = time + WEP_CVAR(nailgun, first_refire) * W_WeaponRateFactor();
	weapon_thinkf(actor, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), W_NailGun_Attack_Auto);
}

void W_NailGun_Attack_Burst(Weapon thiswep, entity actor, bool fire1, bool fire2)
{
	W_SetupShot(actor, true, 0, SND(NAILGUN_FIRE), CH_WEAPON_A, WEP_CVAR(nailgun, sustained_damage));
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

	fireBullet(w_shotorg + ang, w_shotdir + (ang * 0.03), WEP_CVAR(nailgun, burst_speed), WEP_CVAR(nailgun, solidpenetration), WEP_CVAR(nailgun, sustained_damage), WEP_CVAR(nailgun, sustained_force), WEP_NAILGUN.m_id, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg + ang, (w_shotdir + (ang * 0.03)) * 1000, 1);

	W_NailGun_MuzzleFlash();
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
		ATTACK_FINISHED(actor) = time + WEP_CVAR(nailgun, burst_refire2) * W_WeaponRateFactor();
		weapon_thinkf(actor, WFRAME_FIRE2, WEP_CVAR(nailgun, burst_animtime), w_ready);
	}
	else
	{
		weapon_thinkf(actor, WFRAME_FIRE2, WEP_CVAR(nailgun, burst_refire), W_NailGun_Attack_Burst);
	}

}

		METHOD(NailGun, wr_aim, void(entity thiswep))
		{
			if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, false);
			else
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, false);
		}
		METHOD(NailGun, wr_think, void(entity thiswep, entity actor, bool fire1, bool fire2))
		{
			if(WEP_CVAR(nailgun, reload_ammo) && actor.clip_load < min(max(WEP_CVAR(nailgun, sustained_ammo), WEP_CVAR(nailgun, first_ammo)), WEP_CVAR(nailgun, burst_ammo))) { // forced reload
				Weapon w = get_weaponinfo(actor.weapon);
				w.wr_reload(w);
			} else
			if(WEP_CVAR(nailgun, mode) == 1)
			{
				if(fire1)
				if(weapon_prepareattack(thiswep, actor, false, 0))
				{
					actor.misc_bulletcounter = 0;
					W_NailGun_Attack_Auto(thiswep, actor, fire1, fire2);
				}

				if(fire2)
				if(weapon_prepareattack(thiswep, actor, true, 0))
				{
					Weapon w = get_weaponinfo(actor.weapon);
					if(!w.wr_checkammo2(w))
					if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
					{
						W_SwitchWeapon_Force(actor, w_getbestweapon(actor));
						w_ready(thiswep, actor, fire1, fire2);
						return;
					}

					W_DecreaseAmmo(thiswep, actor, WEP_CVAR(nailgun, burst_ammo));

					actor.misc_bulletcounter = WEP_CVAR(nailgun, burst) * -1;
					W_NailGun_Attack_Burst(thiswep, actor, fire1, fire2);
				}
			}
			else
			{

				if(fire1)
				if(weapon_prepareattack(thiswep, actor, false, 0))
				{
					actor.misc_bulletcounter = 1;
					W_NailGun_Attack(WEP_NAILGUN, WEP_NAILGUN.m_id); // sets attack_finished
					weapon_thinkf(actor, WFRAME_FIRE1, WEP_CVAR(nailgun, sustained_refire), W_NailGun_Attack_Frame);
				}

				if(fire2 && WEP_CVAR(nailgun, first))
				if(weapon_prepareattack(thiswep, actor, true, 0))
				{
					actor.misc_bulletcounter = 1;
					W_NailGun_Attack(WEP_NAILGUN, WEP_NAILGUN.m_id | HITTYPE_SECONDARY); // sets attack_finished
					weapon_thinkf(actor, WFRAME_FIRE2, WEP_CVAR(nailgun, first_refire), w_ready);
				}
			}
		}
		METHOD(NailGun, wr_init, void(entity thiswep))
		{
			NAILGUN_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP);
		}
		METHOD(NailGun, wr_checkammo1, bool(entity thiswep))
		{
			float ammo_amount;
			if(WEP_CVAR(nailgun, mode) == 1)
				ammo_amount = self.WEP_AMMO(NAILGUN) >= WEP_CVAR(nailgun, sustained_ammo);
			else
				ammo_amount = self.WEP_AMMO(NAILGUN) >= WEP_CVAR(nailgun, first_ammo);

			if(WEP_CVAR(nailgun, reload_ammo))
			{
				if(WEP_CVAR(nailgun, mode) == 1)
					ammo_amount += self.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, sustained_ammo);
				else
					ammo_amount += self.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(NailGun, wr_checkammo2, bool(entity thiswep))
		{
			float ammo_amount;
			if(WEP_CVAR(nailgun, mode) == 1)
				ammo_amount = self.WEP_AMMO(NAILGUN) >= WEP_CVAR(nailgun, burst_ammo);
			else
				ammo_amount = self.WEP_AMMO(NAILGUN) >= WEP_CVAR(nailgun, first_ammo);

			if(WEP_CVAR(nailgun, reload_ammo))
			{
				if(WEP_CVAR(nailgun, mode) == 1)
					ammo_amount += self.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, burst_ammo);
				else
					ammo_amount += self.(weapon_load[WEP_NAILGUN.m_id]) >= WEP_CVAR(nailgun, first_ammo);
			}
			return ammo_amount;
		}
		METHOD(NailGun, wr_config, void(entity thiswep))
		{
			NAILGUN_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS);
		}
		METHOD(NailGun, wr_reload, void(entity thiswep))
		{
			W_Reload(self, min(max(WEP_CVAR(nailgun, sustained_ammo), WEP_CVAR(nailgun, first_ammo)), WEP_CVAR(nailgun, burst_ammo)), SND(RELOAD));
		}
		METHOD(NailGun, wr_suicidemessage, int(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(NailGun, wr_killmessage, int(entity thiswep))
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_MACHINEGUN_MURDER_SNIPE;
			else
				return WEAPON_MACHINEGUN_MURDER_SPRAY;
		}

#endif
#ifdef CSQC

		METHOD(NailGun, wr_impacteffect, void(entity thiswep))
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			pointparticles(particleeffectnum(EFFECT_MACHINEGUN_IMPACT), org2, w_backoff * 1000, 1);
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
