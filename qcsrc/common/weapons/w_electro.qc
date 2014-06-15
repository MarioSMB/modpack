#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ ELECTRO,
/* function  */ W_Electro,
/* ammotype  */ ammo_cells,
/* impulse   */ 5,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '0 0.5 1',
/* modelname */ "electro",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairelectro 0.5",
/* wepimg    */ "weaponelectro",
/* refname   */ "electro",
/* wepname   */ _("Electro")
);

#define ELECTRO_SETTINGS(w_cvar,w_prop) ELECTRO_SETTINGS_LIST(w_cvar, w_prop, ELECTRO, electro)
#define ELECTRO_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, ammo) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, edgedamage) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, BOTH, radius) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, speed) \
	w_cvar(id, sn, BOTH, spread) \
	w_cvar(id, sn, BOTH, lifetime) \
	w_cvar(id, sn, PRI,  comboradius) \
	w_cvar(id, sn, PRI,  midaircombo_explode) \
	w_cvar(id, sn, PRI,  midaircombo_interval) \
	w_cvar(id, sn, PRI,  midaircombo_radius) \
	w_cvar(id, sn, SEC,  bouncefactor) \
	w_cvar(id, sn, SEC,  bouncestop) \
	w_cvar(id, sn, SEC,  count) \
	w_cvar(id, sn, SEC,  damageforcescale) \
	w_cvar(id, sn, SEC,  damagedbycontents) \
	w_cvar(id, sn, SEC,  health) \
	w_cvar(id, sn, SEC,  refire2) \
	w_cvar(id, sn, SEC,  speed_up) \
	w_cvar(id, sn, SEC,  speed_z) \
	w_cvar(id, sn, SEC,  touchexplode) \
	w_cvar(id, sn, NONE, combo_comboradius) \
	w_cvar(id, sn, NONE, combo_comboradius_thruwall) \
	w_cvar(id, sn, NONE, combo_damage) \
	w_cvar(id, sn, NONE, combo_edgedamage) \
	w_cvar(id, sn, NONE, combo_force) \
	w_cvar(id, sn, NONE, combo_radius) \
	w_cvar(id, sn, NONE, combo_simple) \
	w_cvar(id, sn, NONE, combo_speed) \
	w_cvar(id, sn, NONE, combo_safeammocheck) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
ELECTRO_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.float electro_count;
.float electro_secondarytime;
void W_Electro_ExplodeCombo(void);
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_electro(void) { weapon_defaultspawnfunc(WEP_ELECTRO); }

void W_Electro_TriggerCombo_Simple(vector org, float rad, entity own)
{
	entity e;
	for(e = world; (e = find(e, classname, "electro_orb")); )
	{
		if(vlen(e.origin - org) <= rad)
		{
			// do we allow thruwall triggering?
			if(WEP_CVAR(electro, combo_comboradius_thruwall))
			{
				WarpZone_TraceLine(org, e.origin, MOVE_NOMONSTERS, e);
				if(trace_fraction != 1)
				{
					if(vlen(e.origin - org) >= WEP_CVAR(electro, combo_comboradius_thruwall))
					{
						// trigger is through a wall and outside of thruwall range, abort
						continue;
					}
				}
			}
			
			// change owner to whoever caused the combo explosion
			e.realowner = own;
			e.takedamage = DAMAGE_NO;
			e.classname = "electro_orb_chain";
			
			// now set the next one to trigger as well
			e.think = W_Electro_ExplodeCombo;
			
			// delay combo chains, looks cooler
			e.nextthink =
				(
					time
					+
					(WEP_CVAR(electro, combo_speed) ?
						(vlen(e.origin - org) / WEP_CVAR(electro, combo_speed))
						:
						0
					)
				);
		}
	}
}

void W_Electro_TriggerCombo_WarpZone(vector org, float rad, entity own)
{
	entity e = WarpZone_FindRadius(org, rad, !WEP_CVAR(electro, combo_comboradius_thruwall));
	while(e)
	{
		if(e.classname == "electro_orb")
		{
			// do we allow thruwall triggering?
			if(WEP_CVAR(electro, combo_comboradius_thruwall))
			{
				// if distance is greater than thruwall distance, check to make sure it's not through a wall
				if(vlen(e.WarpZone_findradius_dist) > WEP_CVAR(electro, combo_comboradius_thruwall))
				{
					WarpZone_TraceLine(org, e.origin, MOVE_NOMONSTERS, e);
					if(trace_fraction != 1)
					{
						// trigger is through a wall and outside of thruwall range, abort
						e = e.chain;
						continue;
					}
				}
			}
			
			// change owner to whoever caused the combo explosion
			e.realowner = own;
			e.takedamage = DAMAGE_NO;
			e.classname = "electro_orb_chain";
			
			// now set the next one to trigger as well
			e.think = W_Electro_ExplodeCombo;
			
			// delay combo chains, looks cooler
			e.nextthink =
				(
					time
					+
					(WEP_CVAR(electro, combo_speed) ?
						(vlen(e.WarpZone_findradius_dist) / WEP_CVAR(electro, combo_speed))
						:
						0
					)
				);
		}
		e = e.chain;
	}
}

void W_Electro_TriggerCombo(vector org, float rad, entity own)
{
	// TODO: remove when we have unlagged findradius!

	if(WEP_CVAR(electro, combo_simple))
		W_Electro_TriggerCombo_Simple(org, rad, own);
	else
		W_Electro_TriggerCombo_WarpZone(org, rad, own);
}

void W_Electro_ExplodeCombo(void)
{
	W_Electro_TriggerCombo(self.origin, WEP_CVAR(electro, combo_comboradius), self.realowner);

	self.event_damage = func_null;
	
	RadiusDamage(
		self,
		self.realowner,
		WEP_CVAR(electro, combo_damage),
		WEP_CVAR(electro, combo_edgedamage),
		WEP_CVAR(electro, combo_radius),
		world,
		world,
		WEP_CVAR(electro, combo_force),
		WEP_ELECTRO | HITTYPE_BOUNCE, // use THIS type for a combo because primary can't bounce
		world
	);

	remove(self);
}

void W_Electro_Explode(void)
{
	if(other.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(other))
			if(DIFF_TEAM(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						Send_Notification(NOTIF_ONE, self.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_ELECTROBITCH);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	
	if(self.movetype == MOVETYPE_BOUNCE)
	{
		RadiusDamage(
			self,
			self.realowner,
			WEP_CVAR_SEC(electro, damage),
			WEP_CVAR_SEC(electro, edgedamage),
			WEP_CVAR_SEC(electro, radius),
			world,
			world,
			WEP_CVAR_SEC(electro, force),
			self.projectiledeathtype,
			other
		);
	}
	else
	{
		W_Electro_TriggerCombo(self.origin, WEP_CVAR_PRI(electro, comboradius), self.realowner);
		RadiusDamage(
			self,
			self.realowner,
			WEP_CVAR_PRI(electro, damage),
			WEP_CVAR_PRI(electro, edgedamage),
			WEP_CVAR_PRI(electro, radius),
			world,
			world,
			WEP_CVAR_PRI(electro, force),
			self.projectiledeathtype,
			other
		);
	}

	remove(self);
}

void W_Electro_TouchExplode(void)
{
	PROJECTILE_TOUCH;
	W_Electro_Explode();
}

void W_Electro_Bolt_Think(void)
{
	if(time >= self.ltime)
	{
		self.use();
		return;
	}

	if(WEP_CVAR_PRI(electro, midaircombo_radius))
	{
		float found = 0;
		entity e = WarpZone_FindRadius(self.origin, WEP_CVAR_PRI(electro, midaircombo_radius), TRUE);

		// loop through nearby orbs and trigger them
		while(e)
		{
			if(e.classname == "electro_orb")
			{
				// change owner to whoever caused the combo explosion
				e.realowner = self.realowner;
				e.takedamage = DAMAGE_NO;
				e.classname = "electro_orb_chain";

				// now set the next one to trigger as well
				e.think = W_Electro_ExplodeCombo;
				
				// delay combo chains, looks cooler
				e.nextthink =
					(
						time
						+
						(WEP_CVAR(electro, combo_speed) ?
							(vlen(e.WarpZone_findradius_dist) / WEP_CVAR(electro, combo_speed))
							:
							0
						)
					);

				++found;
			}
			e = e.chain;
		}

		// if we triggered an orb, should we explode? if not, lets try again next time
		if(found && WEP_CVAR_PRI(electro, midaircombo_explode))
			{ self.use(); }
		else
			{ self.nextthink = min(time + WEP_CVAR_PRI(electro, midaircombo_interval), self.ltime); }
	}
	else { self.nextthink = self.ltime; }
}

void W_Electro_Attack_Bolt(void)
{
	entity proj;

	W_DecreaseAmmo(WEP_CVAR_PRI(electro, ammo));

	W_SetupShot_ProjectileSize(
		self,
		'0 0 -3',
		'0 0 -3',
		FALSE,
		2,
		"weapons/electro_fire.wav",
		CH_WEAPON_A,
		WEP_CVAR_PRI(electro, damage)
	);

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn();
	proj.classname = "electro_bolt";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = WEP_CVAR_PRI(electro, damage);
	proj.use = W_Electro_Explode;
	proj.think = W_Electro_Bolt_Think;
	proj.nextthink = time;
	proj.ltime = time + WEP_CVAR_PRI(electro, lifetime);
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SetupProjVelocity_PRI(proj, electro);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Electro_TouchExplode;
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO_BEAM, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Electro_Orb_Touch(void)
{
	PROJECTILE_TOUCH;
	if(other.takedamage == DAMAGE_AIM)
		{ if(WEP_CVAR_SEC(electro, touchexplode)) { W_Electro_Explode(); } }
	else
	{
		//UpdateCSQCProjectile(self);
		spamsound(self, CH_SHOTS, "weapons/electro_bounce.wav", VOL_BASE, ATTEN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
	}
}

void W_Electro_Orb_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;

	// note: combos are usually triggered by W_Electro_TriggerCombo, not damage
	float is_combo = (inflictor.classname == "electro_orb_chain" || inflictor.classname == "electro_bolt");

	if(!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, (is_combo ? 1 : -1)))
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;
	if(self.health <= 0)
	{
		self.takedamage = DAMAGE_NO;
		self.nextthink = time;
		if(is_combo)
		{
			// change owner to whoever caused the combo explosion
			self.realowner = inflictor.realowner;
			self.classname = "electro_orb_chain";
			self.think = W_Electro_ExplodeCombo;
			self.nextthink = time +
				(
					// bound the length, inflictor may be in a galaxy far far away (warpzones)
					min(
						WEP_CVAR(electro, combo_radius),
						vlen(self.origin - inflictor.origin)
					)
					/
					// delay combo chains, looks cooler
					WEP_CVAR(electro, combo_speed)
				);
		}
		else
		{
			self.use = W_Electro_Explode;
			self.think = adaptor_think2use; // not _hittype_splash, as this runs "immediately"
		}
	}
}

void W_Electro_Attack_Orb(void)
{
	W_DecreaseAmmo(WEP_CVAR_SEC(electro, ammo));

	W_SetupShot_ProjectileSize(
		self,
		'0 0 -4',
		'0 0 -4',
		FALSE,
		2,
		"weapons/electro_fire2.wav",
		CH_WEAPON_A,
		WEP_CVAR_SEC(electro, damage)
	);

	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	entity proj = spawn();
	proj.classname = "electro_orb";
	proj.owner = proj.realowner = self;
	proj.use = W_Electro_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = WEP_CVAR_SEC(electro, damage);
	proj.nextthink = time + WEP_CVAR_SEC(electro, lifetime);
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO | HITTYPE_SECONDARY;
	setorigin(proj, w_shotorg);

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	W_SetupProjVelocity_UP_SEC(proj, electro);
	proj.touch = W_Electro_Orb_Touch;
	setsize(proj, '0 0 -4', '0 0 -4');
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = WEP_CVAR_SEC(electro, damageforcescale);
	proj.health = WEP_CVAR_SEC(electro, health);
	proj.event_damage = W_Electro_Orb_Damage;
	proj.flags = FL_PROJECTILE;
	proj.damagedbycontents = (WEP_CVAR_SEC(electro, damagedbycontents));

	proj.bouncefactor = WEP_CVAR_SEC(electro, bouncefactor);
	proj.bouncestop = WEP_CVAR_SEC(electro, bouncestop);
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

#if 0
	entity p2;
	p2 = spawn();
	copyentity(proj, p2);
	setmodel(p2, "models/ebomb.mdl");
	setsize(p2, proj.mins, proj.maxs);
#endif

	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO, FALSE); // no culling, it has sound

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Electro_CheckAttack(void)
{
	if(self.electro_count > 1)
	if(self.BUTTON_ATCK2)
	if(weapon_prepareattack(1, -1))
	{
		W_Electro_Attack_Orb();
		self.electro_count -= 1;
		weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(electro, animtime), W_Electro_CheckAttack);
		return;
	}
	// WEAPONTODO: when the player releases the button, cut down the length of refire2? 
	w_ready();
}

.float bot_secondary_electromooth;
float W_Electro(float req)
{
	float ammo_amount;
	switch(req)
	{
		case WR_AIM:
		{
			self.BUTTON_ATCK = self.BUTTON_ATCK2 = FALSE;
			if(vlen(self.origin-self.enemy.origin) > 1000) { self.bot_secondary_electromooth = 0; }
			if(self.bot_secondary_electromooth == 0)
			{
				float shoot;

				if(WEP_CVAR_PRI(electro, speed))
					shoot = bot_aim(WEP_CVAR_PRI(electro, speed), 0, WEP_CVAR_PRI(electro, lifetime), FALSE);
				else
					shoot = bot_aim(1000000, 0, 0.001, FALSE);

				if(shoot)
				{
					self.BUTTON_ATCK = TRUE;
					if(random() < 0.01) self.bot_secondary_electromooth = 1;
				}
			}
			else
			{
				if(bot_aim(WEP_CVAR_SEC(electro, speed), WEP_CVAR_SEC(electro, speed_up), WEP_CVAR_SEC(electro, lifetime), TRUE))
				{
					self.BUTTON_ATCK2 = TRUE;
					if(random() < 0.03) self.bot_secondary_electromooth = 0;
				}
			}
			
			return TRUE;
		}
		case WR_THINK:
		{
			if(autocvar_g_balance_electro_reload_ammo) // forced reload // WEAPONTODO
			{
				ammo_amount = 0;
				if(self.clip_load >= WEP_CVAR_PRI(electro, ammo))
					ammo_amount = 1;
				if(self.clip_load >= WEP_CVAR_SEC(electro, ammo))
					ammo_amount += 1;

				if(!ammo_amount)
				{
					WEP_ACTION(self.weapon, WR_RELOAD);
					return FALSE;
				}
				
				return TRUE;
			}
			
			if(self.BUTTON_ATCK)
			{
				if(weapon_prepareattack(0, WEP_CVAR_PRI(electro, refire)))
				{
						W_Electro_Attack_Bolt();
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(electro, animtime), w_ready);
				}
			}
			else if(self.BUTTON_ATCK2)
			{
				if(time >= self.electro_secondarytime)
				if(weapon_prepareattack(1, WEP_CVAR_SEC(electro, refire)))
				{
					W_Electro_Attack_Orb();
					self.electro_count = WEP_CVAR_SEC(electro, count);
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(electro, animtime), W_Electro_CheckAttack);
					self.electro_secondarytime = time + WEP_CVAR_SEC(electro, refire2) * W_WeaponRateFactor();
				}
			}

			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_electro.md3");
			precache_model("models/weapons/v_electro.md3");
			precache_model("models/weapons/h_electro.iqm");
			precache_sound("weapons/electro_bounce.wav");
			precache_sound("weapons/electro_fire.wav");
			precache_sound("weapons/electro_fire2.wav");
			precache_sound("weapons/electro_impact.wav");
			precache_sound("weapons/electro_impact_combo.wav");
			ELECTRO_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			ammo_amount = self.WEP_AMMO(ELECTRO) >= WEP_CVAR_PRI(electro, ammo);
			ammo_amount += self.(weapon_load[WEP_ELECTRO]) >= WEP_CVAR_PRI(electro, ammo);
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			if(WEP_CVAR(electro, combo_safeammocheck)) // true if you can fire at least one secondary blob AND one primary shot after it, otherwise false.
			{
				ammo_amount = self.WEP_AMMO(ELECTRO) >= WEP_CVAR_SEC(electro, ammo) + WEP_CVAR_PRI(electro, ammo);
				ammo_amount += self.(weapon_load[WEP_ELECTRO]) >= WEP_CVAR_SEC(electro, ammo) + WEP_CVAR_PRI(electro, ammo);
			}
			else
			{
				ammo_amount = self.WEP_AMMO(ELECTRO) >= WEP_CVAR_SEC(electro, ammo);
				ammo_amount += self.(weapon_load[WEP_ELECTRO]) >= WEP_CVAR_SEC(electro, ammo);
			}
			return ammo_amount;
		}
		case WR_CONFIG:
		{
			ELECTRO_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RESETPLAYER:
		{
			self.electro_secondarytime = time;
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(min(WEP_CVAR_PRI(electro, ammo), WEP_CVAR_SEC(electro, ammo)), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_ELECTRO_SUICIDE_ORBS;
			else
				return WEAPON_ELECTRO_SUICIDE_BOLT;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
			{
				return WEAPON_ELECTRO_MURDER_ORBS;
			}
			else
			{
				if(w_deathtype & HITTYPE_BOUNCE)
					return WEAPON_ELECTRO_MURDER_COMBO;
				else
					return WEAPON_ELECTRO_MURDER_BOLT;
			}
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Electro(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 6;
			if(w_deathtype & HITTYPE_SECONDARY)
			{
				pointparticles(particleeffectnum("electro_ballexplode"), org2, '0 0 0', 1);
				if(!w_issilent)
					sound(self, CH_SHOTS, "weapons/electro_impact.wav", VOL_BASE, ATTEN_NORM);
			}
			else
			{
				if(w_deathtype & HITTYPE_BOUNCE)
				{
					// this is sent as "primary (w_deathtype & HITTYPE_BOUNCE)" to distinguish it from (w_deathtype & HITTYPE_SECONDARY) bounced balls
					pointparticles(particleeffectnum("electro_combo"), org2, '0 0 0', 1);
					if(!w_issilent)
						sound(self, CH_SHOTS, "weapons/electro_impact_combo.wav", VOL_BASE, ATTEN_NORM);
				}
				else
				{
					pointparticles(particleeffectnum("electro_impact"), org2, '0 0 0', 1);
					if(!w_issilent)
						sound(self, CH_SHOTS, "weapons/electro_impact.wav", VOL_BASE, ATTEN_NORM);
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/electro_impact.wav");
			precache_sound("weapons/electro_impact_combo.wav");
			return TRUE;
		}
		case WR_ZOOMRETICLE:
		{
			// no weapon specific image for this weapon
			return FALSE;
		}
	}
	return FALSE;
}
#endif
#endif
