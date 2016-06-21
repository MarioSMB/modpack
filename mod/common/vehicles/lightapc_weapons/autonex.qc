#ifdef SVQC

AUTOCVAR(g_vehicle_lightapc_autonex_damage, float, 70, "");
AUTOCVAR(g_vehicle_lightapc_autonex_force, float, 300, "");
AUTOCVAR(g_vehicle_lightapc_autonex_damagefalloff_mindist, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_autonex_damagefalloff_maxdist, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_autonex_damagefalloff_halflife, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_autonex_damagefalloff_forcehalflife, float, 0, "");

AUTOCVAR(g_vehicle_lightapc_autonex_refire, float, 0.6, "");
AUTOCVAR(g_vehicle_lightapc_autonex_ammo_cost, float, 4, "");
AUTOCVAR(g_vehicle_lightapc_autonex_ammo_max, float, 70, "");
AUTOCVAR(g_vehicle_lightapc_autonex_ammo_regen, float, 30, "");
AUTOCVAR(g_vehicle_lightapc_autonex_ammo_regen_pause, float, 1, "");

void lightapc_autonex_attack(string tagname, entity fireentity, entity player)
{
	vector v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	v_forward = normalize(v_forward);
	
	float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife;
	mydmg = autocvar_g_vehicle_lightapc_autonex_damage;
	myforce = autocvar_g_vehicle_lightapc_autonex_force;
	mymindist = autocvar_g_vehicle_lightapc_autonex_damagefalloff_mindist;
	mymaxdist = autocvar_g_vehicle_lightapc_autonex_damagefalloff_maxdist;
	myhalflife = autocvar_g_vehicle_lightapc_autonex_damagefalloff_halflife;
	myforcehalflife = autocvar_g_vehicle_lightapc_autonex_damagefalloff_forcehalflife;

	W_SetupShot (player, true, 5, SND_NEXFIRE, CH_WEAPON_A, mydmg);

	FireRailgunBullet (player, v, v + w_shotdir * MAX_SHOT_DISTANCE,
						mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, DEATH_TURRET_PLASMA.m_id);

	vector u = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	WriteHeader(MSG_BROADCAST, TE_CSQC_VORTEXBEAMPARTICLE);
	WriteCoord(MSG_BROADCAST, v.x);
	WriteCoord(MSG_BROADCAST, v.y);
	WriteCoord(MSG_BROADCAST, v.z);
	WriteCoord(MSG_BROADCAST, u.x);
	WriteCoord(MSG_BROADCAST, u.y);
	WriteCoord(MSG_BROADCAST, u.z);
	WriteByte(MSG_BROADCAST, 255);

	Send_Effect(EFFECT_ELECTRO_MUZZLEFLASH, v, v_forward, 1);
}

void lightapc_autonex(entity player, entity gunmount)
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_autonex_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		gunmount.cnt = time;
		lightapc_autonex_attack("tag_mgun", gunmount, player);
		gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_autonex_ammo_cost;
		gunmount.attack_finished_single[0] = time + autocvar_g_vehicle_lightapc_autonex_refire;
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_autonex_ammo_max,
										   autocvar_g_vehicle_lightapc_autonex_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_autonex_ammo_regen, frametime, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_autonex_ammo_max) * 100;
}

#endif
