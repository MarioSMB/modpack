SOUND(RIFLE_FIRE3_BASS, W_Sound("campingrifle_fire3_bass"));

#ifdef SVQC

AUTOCVAR(g_vehicle_lightapc_hmg2_expelbulletcasings, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_damage, float, 30, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_refire, float, 0.07, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_spread, float, 0.015, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_ammo_cost, int, 1, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_ammo_max, int, 100, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_ammo_regen, int, 30, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_ammo_regen_pause, float, 2, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_force, float, 9, "");
AUTOCVAR(g_vehicle_lightapc_hmg2_solidpenetration, float, 16, "");

void lightapc_hmg2(entity player, entity gunmount)
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_hmg2_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		gunmount.cnt = time;
		gunmount.misc_bulletcounter += 1;

		vector v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
		v_forward = normalize(v_forward);
		 //   v += v_forward * 50;
		fireBullet(player, v, v_forward, autocvar_g_vehicle_lightapc_hmg2_spread, autocvar_g_vehicle_lightapc_hmg2_solidpenetration,
								 autocvar_g_vehicle_lightapc_hmg2_damage, autocvar_g_vehicle_lightapc_hmg2_force, DEATH_VH_SPID_MINIGUN.m_id, 0);

		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
		v_forward = normalize(v_forward);
		v += v_forward * 5;
		 
		Send_Effect(EFFECT_SPIDERBOT_MINIGUN_MUZZLEFLASH, v, v_forward, 1);
		 
		W_MachineGun_MuzzleFlash(player);
		lightapc_AttachToShotorg(player, player.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
		sound (gunmount, CH_WEAPON_SINGLE, SND_RIFLE_FIRE3_BASS, VOL_BASE, ATTN_NORM);

		if(autocvar_g_casings >= 2)
		if(autocvar_g_vehicle_lightapc_hmg2_expelbulletcasings == 1)
		{
			lightapc_SpawnCasing (((random () * 50 + 50) * v_right) - 
									(v_forward * (random () * 25 + 25)) - 
									((random () * 5 - 70) * v_up), 2, 
									vectoangles(v_forward),'0 250 0', 100, 107, gunmount, "tag_casings");
		}	

		gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_hmg2_ammo_cost;
		gunmount.attack_finished_single[0] = time + autocvar_g_vehicle_lightapc_hmg2_refire;
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_hmg2_ammo_max,
										   autocvar_g_vehicle_lightapc_hmg2_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_hmg2_ammo_regen, frametime, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_hmg2_ammo_max) * 100;
}

#endif
