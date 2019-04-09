SOUND(VWEP_HMG2_FIRE, W_Sound("campingrifle_fire3_bass"));

#ifdef SVQC

void vwep_hmg2_attack(
	string tagname,
	entity gunmount,
	entity player,
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
	 //   v += v_forward * 50;
	fireBullet(player, weaponentity, v, v_forward, atk_spread, atk_solidpenetration,
									 atk_damage, atk_force, atk_deathtype, EFFECT_BULLET);

	v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
	v_forward = normalize(v_forward);
	v += v_forward * 5;
		 
	Send_Effect(EFFECT_SPIDERBOT_MINIGUN_MUZZLEFLASH, v, v_forward, 1);

		 
	W_MachineGun_MuzzleFlash(player, weaponentity);
	vwep_AttachToShotorg(player, player.(weaponentity).muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	sound (gunmount, CH_WEAPON_SINGLE, SND_VWEP_HMG2_FIRE, VOL_BASE, ATTN_NORM);

	if(atk_dropcasings)
	{
		vwep_SpawnCasing(((random () * 50 + 50) * v_right) - 
							(v_forward * (random () * 25 + 25)) - 
							((random () * 5 - 70) * v_up), 2, 
							vectoangles(v_forward),'0 250 0', 100, 107, gunmount, "tag_casings");
	}
}

#endif
