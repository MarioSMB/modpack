#ifdef SVQC

void vwep_minigun_attack(
	string tagname,
	entity player,
	entity gunmount,
	entity mggun1,
	float atk_deathtype,
	float atk_damage,
	float atk_spread,
	float atk_force,
	float atk_solidpenetration,
	bool atk_dropcasings)
{ 
	gunmount.misc_bulletcounter += 1;

	.entity weaponentity = weaponentities[0];
	vector v = gettaginfo(gunmount, gettagindex(gunmount, tagname));
	v_forward = normalize(v_forward);
	 
	fireBullet(player, weaponentity, v, v_forward, atk_spread, atk_solidpenetration,
								 atk_damage, atk_force, atk_deathtype, EFFECT_BULLET);


	v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
	v_forward = normalize(v_forward);
	v += v_forward * 5;

	Send_Effect(EFFECT_SPIDERBOT_MINIGUN_MUZZLEFLASH, v, v_forward, 1);
	 
		 
	W_MachineGun_MuzzleFlash(player, weaponentity);
	vwep_AttachToShotorg(player, player.(weaponentity).muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	sound (gunmount, CH_WEAPON_A, SND_UZI_FIRE, VOL_BASE, ATTN_NORM);
		
	if (atk_dropcasings)
	{
		//Casing
		vwep_SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 104, gunmount, "tag_casings");
			
		//Casinglink
		vwep_SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 34, gunmount, "tag_casings");
	}
			
	mggun1.angles_y += 20;
	if(mggun1.angles_y >= 360)
		mggun1.angles_y = 0;
}

#endif
