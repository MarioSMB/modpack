#ifdef SVQC

AUTOCVAR(g_vehicle_lightapc_shlac_refire, float, 0.15, "");
AUTOCVAR(g_vehicle_lightapc_shlac_ammo_cost, int, 1, "");
AUTOCVAR(g_vehicle_lightapc_shlac_ammo_max, int, 100, "");
AUTOCVAR(g_vehicle_lightapc_shlac_ammo_regen, int, 20, "");
AUTOCVAR(g_vehicle_lightapc_shlac_ammo_regen_pause, float, 1, "");

void lightapc_shlac_touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	this.event_damage = func_null;

	bool isprimary = !(this.projectiledeathtype & HITTYPE_SECONDARY);

	RadiusDamage(this, this.realowner, WEP_CVAR_BOTH(hlac, isprimary, damage), WEP_CVAR_BOTH(hlac, isprimary, edgedamage), WEP_CVAR_BOTH(hlac, isprimary, radius), 
					   this.realowner.vehicle, world, WEP_CVAR_BOTH(hlac, isprimary, force), this.projectiledeathtype, toucher);

	remove(this);
}

void lightapc_shlac_attack(entity actor, string tagname, entity fireentity)
{
	vector v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	
	entity missile;
	float spread;

	spread = WEP_CVAR_PRI(hlac, spread_min) * 0.1;

	W_SetupShot (actor, false, 3, SND_LASERGUN_FIRE, CH_WEAPON_A, WEP_CVAR_PRI(hlac, damage));
	Send_Effect(EFFECT_BLASTER_MUZZLEFLASH, v, v_forward * 1000, 1);
	if (!autocvar_g_norecoil)
	{
		actor.punchangle_x = random () - 0.5;
		actor.punchangle_y = random () - 0.5;
	}

	missile = new (hlacbolt);
	//missile.owner = missile.realowner = actor;
	missile.owner = fireentity;
	missile.realowner = actor;
	missile.bot_dodge = true;

	missile.bot_dodgerating = WEP_CVAR_PRI(hlac, damage);

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, v);
	setsize(missile, '0 0 0', '0 0 0');

	//W_SetupProjectileVelocity(missile, WEP_CVAR_PRI(hlac, speed), spread);
	missile.velocity = w_shotdir * WEP_CVAR_PRI(hlac, speed);
	missile.velocity = W_CalculateProjectileVelocity(missile.realowner, missile.realowner.velocity, missile.velocity, true);
	//missile.angles = vectoangles (missile.velocity); // csqc

	settouch(missile, lightapc_shlac_touch);
	setthink(missile, SUB_Remove);

	missile.nextthink = time + WEP_CVAR_PRI(hlac, lifetime);

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = WEP_HLAC.m_id;

	CSQCProjectile(missile, true, PROJECTILE_HLAC, true);

	MUTATOR_CALLHOOK(EditProjectile, actor, missile);
}

void lightapc_shlac(entity player, entity gunmount) 
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_shlac_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		gunmount.cnt = time;
		gunmount.misc_bulletcounter += 1;

		makevectors(gunmount.angles);
		//vector v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
		v_forward = normalize(v_forward);

		lightapc_shlac_attack(player, "tag_mgun1", gunmount);
		//lightapc_shlac_attack(player, "tag_mgun2", gunmount);
		//lightapc_shlac_attack(player, "tag_mgun3", gunmount);
		//lightapc_shlac_attack(player, "tag_mgun4", gunmount);
		//lightapc_shlac_attack(player, "tag_mgun5", gunmount);

		gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_shlac_ammo_cost;
		gunmount.attack_finished_single[0] = time + autocvar_g_vehicle_lightapc_shlac_refire;
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_shlac_ammo_max,
										   autocvar_g_vehicle_lightapc_shlac_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_shlac_ammo_regen, frametime, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_shlac_ammo_max) * 100;
}

#endif
