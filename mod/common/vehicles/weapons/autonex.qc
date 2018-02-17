#ifdef SVQC

void vwep_autonex_attack(
	string tagname,
	entity fireentity,
	entity player,
	float atk_deathtype,
	float atk_damage,
	float atk_force,
	float atk_mindist,
	float atk_maxdist,
	float atk_halflife,
	float atk_forcehalflife)
{
	vector v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	v_forward = normalize(v_forward);

	W_SetupShot (player, weaponentities[0], true, 5, SND_NEXFIRE, CH_WEAPON_A, atk_damage, atk_deathtype);

	FireRailgunBullet (player, weaponentities[0], v, v + w_shotdir * max_shot_distance,
						atk_damage, atk_force, atk_mindist, atk_maxdist, atk_halflife, atk_forcehalflife, atk_deathtype);

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

#endif
