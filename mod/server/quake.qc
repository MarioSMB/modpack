REGISTER_MUTATOR(pinventory, cvar("sv_persistent_inventory"));

AUTOCVAR(sv_persistent_inventory, bool, false, _("Enable persistent item saving"));

float tmparm2, tmparm3, tmparm4, tmparm5, tmparm6, tmparm7, tmparm8, tmparm9, tmparm10, tmparm11, tmparm12;

MUTATOR_HOOKFUNCTION(pinventory, PlayerSpawn)
{
	self.items = tmparm2;
	self.health = ((parm3 > 0) ? parm3 : 100);
	self.armorvalue = tmparm4;
	self.ammo_shells = tmparm5;
	self.ammo_nails = tmparm6;
	self.ammo_rockets = tmparm7;
	self.ammo_cells = tmparm8;
	self.weapons_x = tmparm9;
	self.weapons_y = tmparm10;
	self.weapons_z = tmparm11;
	self.switchweapon = tmparm12;
	return false;
}

MUTATOR_HOOKFUNCTION(pinventory, DecodeLevelParms)
{
	self.items = tmparm2 = parm2;
	self.health = tmparm3 = ((parm3 > 0) ? parm3 : 100);
	self.armorvalue = tmparm4 = parm4;
	self.ammo_shells = tmparm5 = parm5;
	self.ammo_nails = tmparm6 = parm6;
	self.ammo_rockets = tmparm7 = parm7;
	self.ammo_cells = tmparm8 = parm8;
	self.weapons_x = tmparm9 = parm9;
	self.weapons_y = tmparm10 = parm10;
	self.weapons_z = tmparm11 = parm11;
	self.switchweapon = tmparm12 = parm12;
	return false;
}

MUTATOR_HOOKFUNCTION(pinventory, SetNewParms)
{
	vector sweps = (WEPSET(SHOTGUN));

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
	return false;
}

MUTATOR_HOOKFUNCTION(pinventory, SetChangeParms)
{
	if(self.health <= 0)
	{
		SetNewParms();
		return false;
	}

	self.items &= ~(IT_KEY1 | IT_INVISIBILITY | IT_STRENGTH | IT_INVULNERABILITY | IT_INVINCIBLE | IT_SUIT | IT_QUAD);
	self.health = bound(50, self.health, 100);

	parm2 = self.items;
	parm3 = self.health;
	parm4 = self.armorvalue;
	parm5 = ((self.ammo_shells < 25) ? 25 : self.ammo_shells);
	parm6 = self.ammo_nails;
	parm7 = self.ammo_rockets;
	parm8 = self.ammo_cells;
	parm9 = self.weapons.x;
	parm10 = self.weapons.y;
	parm11 = self.weapons.z;
	parm12 = self.switchweapon;
	return false;
}
