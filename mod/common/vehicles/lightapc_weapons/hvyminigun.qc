#ifndef MENUQC
SOUND(LIGHTAPC_HVYMINIGUN_FIRE, W_Sound("campingrifle_fire_bass"));
#endif

#ifdef SVQC

AUTOCVAR(g_vehicle_lightapc_hvyminigun_expelbulletcasings, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_damage, float, 12, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_force, float, 9, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_spread, float, 0.015, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_refire, float, 0.1, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_ammo_cost, int, 1, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_ammo_max, int, 97, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_ammo_regen, int, 47, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_ammo_regen_pause, float, 1, "");
AUTOCVAR(g_vehicle_lightapc_hvyminigun_solidpenetration, float, 32, "");

void lightapc_hvyminigun(entity player, entity gunmount, entity mggun1) 
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_hvyminigun_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		gunmount.cnt = time;
		gunmount.misc_bulletcounter += 1;

		vector v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
		v_forward = normalize(v_forward);
		//   v += v_forward * 50;
		// Start Ballistic bullet
	 
		//fireBallisticBullet(v, v_forward, autocvar_g_vehicle_lightapc_hvyminigun_spread, autocvar_g_vehicle_lightapc_hvyminigun_speed, 5,
		//	autocvar_g_vehicle_lightapc_hvyminigun_damage, autocvar_g_vehicle_lightapc_hvyminigun_headshotaddeddamage, autocvar_g_vehicle_lightapc_hvyminigun_force,
		//	DEATH_SPORTSTERGUN.m_id, 1, 1, autocvar_g_vehicle_lightapc_hvyminigun_bulletconstant, autocvar_g_vehicle_lightapc_hvyminigun_coreshotaddeddamage);
		//endFireBallisticBullet();
		fireBullet(player, v, v_forward, autocvar_g_vehicle_lightapc_hvyminigun_spread, autocvar_g_vehicle_lightapc_hvyminigun_solidpenetration,
								 autocvar_g_vehicle_lightapc_hvyminigun_damage, autocvar_g_vehicle_lightapc_hvyminigun_force, DEATH_VH_SPID_MINIGUN.m_id, 0);
		// End Ballistic bullet

	 
		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
		v_forward = normalize(v_forward);
		v += v_forward * 5;
	 
		Send_Effect(EFFECT_SPIDERBOT_MINIGUN_MUZZLEFLASH, v, v_forward, 1);
	 
		.entity weaponentity = weaponentities[0];
		 
		W_MachineGun_MuzzleFlash(player, weaponentity);
		lightapc_AttachToShotorg(player, player.(weaponentity).muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
		sound (gunmount, CH_WEAPON_A, SND_LIGHTAPC_HVYMINIGUN_FIRE, VOL_BASE, ATTN_NORM);

		if (autocvar_g_vehicle_lightapc_hvyminigun_expelbulletcasings == 1)
		{
			//Casing
			if (autocvar_g_casings >= 2)
			{
				lightapc_SpawnCasing (((random () * 50 + 50) * v_right) - 
						(v_forward * (random () * 5 - 25)) - 
						((random () * 5 + 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 107, gunmount, "tag_casings");
			}
		
			//CasingLink
			if (autocvar_g_casings >= 2)
			{
				lightapc_SpawnCasing (((random () * 50 + 50) * v_right) - 
						(v_forward * (random () * 5 - 25)) - 
						((random () * 5 + 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 37, gunmount, "tag_casings");
			}
		}

		gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_hvyminigun_ammo_cost;
			
		gunmount.attack_finished_single[0] = time + mggun1.count; //Next refire

		mggun1.angles_y += 40;
		if(mggun1.angles_y >= 360)
			mggun1.angles_y = 0;
		//Smooth animations. Also gun can spin via elec power even if no ammo
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_hvyminigun_ammo_max,
										   autocvar_g_vehicle_lightapc_hvyminigun_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_hvyminigun_ammo_regen, frametime, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_hvyminigun_ammo_max) * 100;
}

#endif
