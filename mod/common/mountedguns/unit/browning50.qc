#ifdef SVQC

void mg_browning50_fire(entity mg, entity player, entity gunmount)
{
	mg.cnt = time;
	if(mg.vehicle_ammo1 >= autocvar_g_mountedgun_browning50_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
	{
		vector v;
		mg.misc_bulletcounter += 1;

		self = player;

		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
		v_forward = normalize(v_forward);
		 //   v += v_forward * 50;
		fireBullet(v, v_forward, autocvar_g_mountedgun_browning50_machinegun_spread, autocvar_g_mountedgun_browning50_machinegun_solidpenetration,
								 autocvar_g_mountedgun_browning50_machinegun_damage, autocvar_g_mountedgun_browning50_machinegun_force, DEATH_VH_SPID_MINIGUN, 0);

	 
		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
		v_forward = normalize(v_forward);
		v += v_forward * 5;
		 
		pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
		 
		W_MachineGun_MuzzleFlash();
		mg_common_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
		sound (gunmount, CH_WEAPON_A, W_Sound("campingrifle_fire3_bass"), VOL_BASE, ATTN_NORM);

		if(autocvar_g_casings >= 2)
		if(autocvar_g_mountedgun_browning50_machinegun_expelbulletcasings == 1)
		{
			mg_common_SpawnCasing (((random () * 50 + 50) * v_right) - 
									(v_forward * (random () * 25 + 25)) - 
									((random () * 5 - 70) * v_up), 2, 
									vectoangles(v_forward),'0 250 0', 100, 107, gunmount, "tag_casings");
		}	

		self = mg;

		mg.vehicle_ammo1 -= autocvar_g_mountedgun_browning50_machinegun_ammo_cost;
		gunmount.attack_finished_single = time + autocvar_g_mountedgun_browning50_machinegun_refire;
		player.vehicle_ammo1 = (mg.vehicle_ammo1 / autocvar_g_mountedgun_browning50_machinegun_ammo_max) * 100;
	}
}

#endif
