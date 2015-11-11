#ifdef SVQC

void mg_m134_fire(entity mg_m134, entity player, entity gunmount, entity mggun1) 
{
		mg_m134.cnt = time;
		if(mg_m134.vehicle_ammo1 >= autocvar_g_mountedgun_m134_machinegun_ammo_cost && gunmount.attack_finished_single[0] <= time)
		{
			vector v;
			mg_m134.misc_bulletcounter += 1;

			self = player;

			v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
			v_forward = normalize(v_forward);
		 //   v += v_forward * 50;
	 // Start Ballistic bullet
	 
	  //fireBallisticBullet(v, v_forward, autocvar_g_mountedgun_m134_machinegun_spread, autocvar_g_mountedgun_m134_machinegun_speed, 5, autocvar_g_mountedgun_m134_machinegun_damage, autocvar_g_mountedgun_m134_machinegun_headshotaddeddamage, autocvar_g_mountedgun_m134_machinegun_force, DEATH_SPORTSTERGUNLT, 1, 1, autocvar_g_mountedgun_m134_machinegun_bulletconstant, autocvar_g_mountedgun_m134_machinegun_coreshotaddeddamage);
		 //endFireBallisticBullet();
	fireBullet(v, v_forward, autocvar_g_mountedgun_m134_machinegun_spread, autocvar_g_mountedgun_m134_machinegun_solidpenetration,
							 autocvar_g_mountedgun_m134_machinegun_damage, autocvar_g_mountedgun_m134_machinegun_force, DEATH_VH_SPID_MINIGUN.m_id, 0);
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
		 v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	Send_Effect(EFFECT_SPIDERBOT_MINIGUN_MUZZLEFLASH, v, v_forward, 1);
	 
	W_MachineGun_MuzzleFlash();
		mg_common_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	_sound (gunmount, CH_WEAPON_A, W_Sound("uzi_fire"), VOL_BASE, ATTN_NORM);

		
	if (autocvar_g_mountedgun_m134_machinegun_expelbulletcasings == 1) {
		if (autocvar_g_casings >= 2) {
			//Casing
			mg_common_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 104, gunmount, "tag_casings");
		
			//Casinglink
			mg_common_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 34, gunmount, "tag_casings");
		}
	 }	

			self = mg_m134;

			mg_m134.vehicle_ammo1 -= autocvar_g_mountedgun_m134_machinegun_ammo_cost;
			
		gunmount.attack_finished_single[0] = time + autocvar_g_mountedgun_m134_machinegun_refire; //Next refire
					
		player.vehicle_ammo1 = (mg_m134.vehicle_ammo1 / autocvar_g_mountedgun_m134_machinegun_ammo_max) * 100;
		
		
			mggun1.angles_y += 20;
			if(mggun1.angles_y >= 360)
			{
				mggun1.angles_y = 0;
			}
	//Smooth animations. Also gun can spin via elec power even if no ammo
	} else if(mg_m134.vehicle_ammo1 < autocvar_g_mountedgun_m134_machinegun_ammo_cost && gunmount.attack_finished_single[0] <= time)
		{
		gunmount.attack_finished_single[0] = time + autocvar_g_mountedgun_m134_machinegun_refire; //Next refire

			mggun1.angles_y += 20;
			if(mggun1.angles_y >= 360)
			{
				mggun1.angles_y = 0;
			}
		} else if(mggun1.attack_finished_single[0] <= time)
	{
		mggun1.attack_finished_single[0] = time + (autocvar_g_mountedgun_m134_machinegun_refire*0.3333333); // 1/3 time
		mggun1.angles_y += 20;
			if(mggun1.angles_y >= 360)
			{
				mggun1.angles_y = 0;
			}
		} else if(mggun1.cnt <= time)
	{
		mggun1.cnt = time + (autocvar_g_mountedgun_m134_machinegun_refire*0.6666666); // 2/3 time

		mggun1.angles_y += 20;
			if(mggun1.angles_y >= 360)
			{
				mggun1.angles_y = 0;
			}
		}
}

#endif
