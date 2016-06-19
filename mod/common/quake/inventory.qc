#ifdef SVQC

REGISTER_MUTATOR(pinventory, true);

AUTOCVAR(sv_persistent_inventory, bool, false, _("Enable persistent item saving"));

float tmparm2, tmparm3, tmparm4, tmparm5, tmparm6, tmparm7, tmparm8, tmparm9, tmparm10, tmparm11, tmparm12;

MUTATOR_HOOKFUNCTION(pinventory, PlayerSpawn)
{
	if(!autocvar_sv_persistent_inventory)
		return;

	entity player = M_ARGV(0, entity);

	player.items = tmparm2;
	player.health = ((parm3 > 0) ? parm3 : 100);
	player.armorvalue = tmparm4;
	player.ammo_shells = tmparm5;
	player.ammo_nails = tmparm6;
	player.ammo_rockets = tmparm7;
	player.ammo_cells = tmparm8;
	player.weapons_x = tmparm9;
	player.weapons_y = tmparm10;
	player.weapons_z = tmparm11;
	PS(player).m_switchweapon = Weapons_from(tmparm12);
}

MUTATOR_HOOKFUNCTION(pinventory, DecodeLevelParms)
{
	if(!autocvar_sv_persistent_inventory)
		return;

	entity player = M_ARGV(0, entity);

	player.items = tmparm2 = parm2;
	player.health = tmparm3 = ((parm3 > 0) ? parm3 : 100);
	player.armorvalue = tmparm4 = parm4;
	player.ammo_shells = tmparm5 = parm5;
	player.ammo_nails = tmparm6 = parm6;
	player.ammo_rockets = tmparm7 = parm7;
	player.ammo_cells = tmparm8 = parm8;
	player.weapons_x = tmparm9 = parm9;
	player.weapons_y = tmparm10 = parm10;
	player.weapons_z = tmparm11 = parm11;
	PS(player).m_switchweapon = Weapons_from(tmparm12 = parm12);
}

MUTATOR_HOOKFUNCTION(pinventory, SetNewParms)
{
	if(!autocvar_sv_persistent_inventory)
		return;

	WepSet sweps = (WEPSET(AXE) | WEPSET(SHOTGUN));

	parm2 = 0;
	parm3 = 100;
	parm4 = 0;
	parm5 = 25;
	parm6 = 0;
	parm7 = 0;
	parm8 = 0;
	parm9 = sweps.x;
	parm10 = sweps.y;
	parm11 = sweps.z;
	parm12 = WEP_SHOTGUN.m_id;
}

MUTATOR_HOOKFUNCTION(pinventory, SetChangeParms)
{
	if(!autocvar_sv_persistent_inventory)
		return;

	entity player = M_ARGV(0, entity);

	if(player.health <= 0)
	{
		SetNewParms();
		return;
	}

	// | IT_INVULNERABILITY | IT_SUIT | IT_QUAD
	player.items &= ~(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_STRENGTH | IT_INVINCIBLE);
	player.health = bound(50, player.health, 100);

	parm2 = player.items;
	parm3 = player.health;
	parm4 = player.armorvalue;
	parm5 = ((player.ammo_shells < 25) ? 25 : player.ammo_shells);
	parm6 = player.ammo_nails;
	parm7 = player.ammo_rockets;
	parm8 = player.ammo_cells;
	parm9 = player.weapons.x;
	parm10 = player.weapons.y;
	parm11 = player.weapons.z;
	parm12 = PS(player).m_switchweapon.m_id;
}

#endif
