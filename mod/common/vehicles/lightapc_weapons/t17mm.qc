#ifndef MENUQC
SOUND(LIGHTAPC_T17MM_FIRE, W_Sound("uzi_fire_slow_bass"));
#endif

#ifdef SVQC

AUTOCVAR(g_vehicle_lightapc_t17mm_expelbulletcasings, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_damage, float, 12, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_force, float, 9, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_spread, float, 0.015, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_refire, float, 0.15, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_ammo_cost, int, 2, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_ammo_max, int, 100, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_ammo_regen, int, 20, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_ammo_regen_pause, float, 2, "");
AUTOCVAR(g_vehicle_lightapc_t17mm_solidpenetration, float, 32, "");

.entity muzzle_flash2;

void lightapc_t17mm_muzzleflash_think(entity this)
{
	this.frame += 2;
	this.scale *= 0.5;
	this.alpha -= 0.25;
	this.nextthink = time + 0.05;

	if(this.alpha <= 0)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		if(this.realowner.muzzle_flash == this)
			this.realowner.muzzle_flash = NULL;
		if(this.realowner.muzzle_flash2 == this)
			this.realowner.muzzle_flash2 = NULL;
		return;
	}
}

void lightapc_t17mm_muzzleflash(entity actor, entity flash)
{
	// muzzle flash for 1st person view
	setmodel(flash, MDL_MACHINEGUN_MUZZLEFLASH); // precision set below

	flash.scale = 0.75;
	setthink(flash, lightapc_t17mm_muzzleflash_think);
	flash.nextthink = time + 0.02;
	flash.frame = 2;
	flash.alpha = 0.75;
	flash.angles_z = random() * 180;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	flash.owner = flash.realowner = actor;
}

void lightapc_t17mm(entity player, entity gunmount) 
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_t17mm_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		gunmount.cnt = time;
		gunmount.misc_bulletcounter += 1;

		vector v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
		v_forward = normalize(v_forward);
		//   v += v_forward * 50;
	 	// Start Ballistic bullet
	 
		//fireBallisticBullet(v, v_forward, autocvar_g_vehicle_lightapc_t17mm_spread, autocvar_g_vehicle_lightapc_t17mm_speed, 5,
		//		autocvar_g_vehicle_lightapc_t17mm_damage, autocvar_g_vehicle_lightapc_t17mm_headshotaddeddamage, autocvar_g_vehicle_lightapc_t17mm_force, DEATH_SPORTSTERGUNHV.m_id,
		//		1, 1, autocvar_g_vehicle_lightapc_t17mm_bulletconstant, autocvar_g_vehicle_lightapc_t17mm_coreshotaddeddamage);
		//endFireBallisticBullet();
		fireBullet(player, v, v_forward, autocvar_g_vehicle_lightapc_t17mm_spread, autocvar_g_vehicle_lightapc_t17mm_solidpenetration,
								 autocvar_g_vehicle_lightapc_t17mm_damage, autocvar_g_vehicle_lightapc_t17mm_force, DEATH_VH_SPID_MINIGUN.m_id, 0);
		// End Ballistic bullet

	 
		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash1"));
		v_forward = normalize(v_forward);
		v += v_forward * 5;
	 
		Send_Effect(EFFECT_SPIDERBOT_MINIGUN_MUZZLEFLASH, v, v_forward, 1);

		if(player.muzzle_flash == NULL)
			player.muzzle_flash = spawn();
		lightapc_t17mm_muzzleflash(player, player.muzzle_flash);
		lightapc_AttachToShotorg(player, player.muzzle_flash, '5 0 0', "tag_flash1", gunmount);
	 
		sound (gunmount, CH_WEAPON_A, SND_LIGHTAPC_T17MM_FIRE, VOL_BASE, ATTN_NORM);
		
		if (autocvar_g_vehicle_lightapc_t17mm_expelbulletcasings == 1)
		{
			if (autocvar_g_casings >= 2)
			{
				lightapc_SpawnCasing (((random () * 50 + 50) * v_right) - 
						(v_forward * (random () * 25 + 25)) - 
						((random () * 12 + 20) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 29, gunmount, "tag_casings");
				//Not rifle style casings, those look too big for this gun
			}
		}

		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun2"));
		v_forward = normalize(v_forward);
		//   v += v_forward * 50;
		// Start Ballistic bullet
	 
		//fireBallisticBullet(v, v_forward, autocvar_g_vehicle_lightapc_t17mm_spread, autocvar_g_vehicle_lightapc_t17mm_speed, 5,
		//		autocvar_g_vehicle_lightapc_t17mm_damage, autocvar_g_vehicle_lightapc_t17mm_headshotaddeddamage, autocvar_g_vehicle_lightapc_t17mm_force, DEATH_SPORTSTERGUNHV.m_id,
		//		1, 1, autocvar_g_vehicle_lightapc_t17mm_bulletconstant, autocvar_g_vehicle_lightapc_t17mm_coreshotaddeddamage);
		//endFireBallisticBullet();
		fireBullet(player, v, v_forward, autocvar_g_vehicle_lightapc_t17mm_spread, autocvar_g_vehicle_lightapc_t17mm_solidpenetration,
								 autocvar_g_vehicle_lightapc_t17mm_damage, autocvar_g_vehicle_lightapc_t17mm_force, DEATH_VH_SPID_MINIGUN.m_id, 0);
		// End Ballistic bullet

	 
		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash2"));
		v_forward = normalize(v_forward);
		v += v_forward * 5;
	 
		Send_Effect(EFFECT_SPIDERBOT_MINIGUN_MUZZLEFLASH, v, v_forward, 1);
	 
		if(player.muzzle_flash2 == NULL)
			player.muzzle_flash2 = spawn();
		lightapc_t17mm_muzzleflash(player, player.muzzle_flash2);
		lightapc_AttachToShotorg(player, player.muzzle_flash2, '5 0 0', "tag_flash2", gunmount);
	 
		sound (gunmount, CH_WEAPON_A, SND_LIGHTAPC_T17MM_FIRE, VOL_BASE, ATTN_NORM);
		sound (gunmount, CH_WEAPON_A, SND_HOOK_IMPACT, VOL_BASE, ATTN_NORM);

		if (autocvar_g_vehicle_lightapc_t17mm_expelbulletcasings == 1)
		{
			if (autocvar_g_casings >= 2)
			{
				lightapc_SpawnCasing (((random () * 50 + 50) * v_right) - 
						(v_forward * (random () * 25 + 25)) - 
						((random () * 12 + 20) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 29, gunmount, "tag_casings");
			}
		}

		gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_t17mm_ammo_cost;
		gunmount.attack_finished_single[0] = time + autocvar_g_vehicle_lightapc_t17mm_refire;
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_t17mm_ammo_max,
										   autocvar_g_vehicle_lightapc_t17mm_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_t17mm_ammo_regen, frametime, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_t17mm_ammo_max) * 100;
}

#endif
