float g_nix_with_laser;

float nix_weapon;
float nix_weapon_ammo;
float nix_nextchange;
float nix_nextweapon;
float nix_nextweapon_ammo;
.float nix_lastchange_id;
.float nix_lastinfotime;
.float nix_nextincr;

float NIX_CanChooseWeapon(float wpn)
{
	entity e;
	e = get_weaponinfo(wpn);
	if(!e.weapon) // skip dummies
		return FALSE;
	if(g_weaponarena)
	{
		if(!(g_weaponarena_weapons & WepSet_FromWeapon(wpn)))
			return FALSE;
	}
	else
	{
		if(wpn == WEP_LASER && g_nix_with_laser)
			return FALSE;
		if(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
			return FALSE;
		if not(e.spawnflags & WEP_FLAG_NORMAL)
			return FALSE;
	}
	return TRUE;
}
void NIX_ChooseNextWeapon()
{
	float j;
	RandomSelection_Init();
	for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		if(NIX_CanChooseWeapon(j))
			RandomSelection_Add(world, j, string_null, 1, (j != nix_weapon));
	nix_nextweapon = RandomSelection_chosen_float;
	nix_nextweapon_ammo = W_AmmoItemCode(nix_nextweapon);
}

void NIX_GiveCurrentWeapon()
{
	float dt;

	if(!nix_nextweapon)
		NIX_ChooseNextWeapon();

	dt = ceil(nix_nextchange - time);

	if(dt <= 0)
	{
		nix_weapon = nix_nextweapon;
		nix_weapon_ammo = nix_nextweapon_ammo;
		nix_nextweapon = 0;
		if (!nix_nextchange) // no round played yet?
			nix_nextchange = time; // start the first round now!
		else
			nix_nextchange = time + autocvar_g_balance_nix_roundtime;
		//weapon_action(nix_weapon, WR_PRECACHE); // forget it, too slow
	}

	if(nix_nextchange != self.nix_lastchange_id) // this shall only be called once per round!
	{
		self.nix_lastchange_id = nix_nextchange;
		if (self.items & IT_UNLIMITED_WEAPON_AMMO)
		{
			self.ammo_shells = (nix_weapon_ammo & IT_SHELLS) ?
				autocvar_g_pickup_shells_max : 0;
			self.ammo_nails = (nix_weapon_ammo & IT_NAILS) ?
				autocvar_g_pickup_nails_max : 0;
			self.ammo_rockets = (nix_weapon_ammo & IT_ROCKETS) ?
				autocvar_g_pickup_rockets_max : 0;
			self.ammo_cells = (nix_weapon_ammo & IT_CELLS) ?
				autocvar_g_pickup_cells_max : 0;
			self.ammo_fuel = (nix_weapon_ammo & IT_FUEL) ?
				autocvar_g_pickup_fuel_max : 0;
		}
		else
		{
			self.ammo_shells = (nix_weapon_ammo & IT_SHELLS) ?
				autocvar_g_balance_nix_ammo_shells : 0;
			self.ammo_nails = (nix_weapon_ammo & IT_NAILS) ?
				autocvar_g_balance_nix_ammo_nails : 0;
			self.ammo_rockets = (nix_weapon_ammo & IT_ROCKETS) ?
				autocvar_g_balance_nix_ammo_rockets : 0;
			self.ammo_cells = (nix_weapon_ammo & IT_CELLS) ?
				autocvar_g_balance_nix_ammo_cells : 0;
			self.ammo_fuel = (nix_weapon_ammo & IT_FUEL) ?
				autocvar_g_balance_nix_ammo_fuel : 0;
		}
		self.nix_nextincr = time + autocvar_g_balance_nix_incrtime;
		if(dt >= 1 && dt <= 5)
			self.nix_lastinfotime = -42;
		else
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_NIX_NEWWEAPON, nix_weapon);

		weapon_action(nix_weapon, WR_RESETPLAYER);

		// all weapons must be fully loaded when we spawn
		entity e;
		e = get_weaponinfo(nix_weapon);
		if(e.spawnflags & WEP_FLAG_RELOADABLE) // prevent accessing undefined cvars
			self.(weapon_load[nix_weapon]) = cvar(strcat("g_balance_", e.netname, "_reload_ammo"));

		// nex too
		if(autocvar_g_balance_nex_charge)
		{
			if(autocvar_g_balance_nex_secondary_chargepool)
				self.nex_chargepool_ammo = 1;
			self.nex_charge = autocvar_g_balance_nex_charge_start;
		}
	}
	if(self.nix_lastinfotime != dt)
	{
		self.nix_lastinfotime = dt; // initial value 0 should count as "not seen"
		if(dt >= 1 && dt <= 5)
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_NIX_COUNTDOWN, nix_nextweapon, dt);
	}

	if(!(self.items & IT_UNLIMITED_WEAPON_AMMO) && time > self.nix_nextincr)
	{
		if (nix_weapon_ammo & IT_SHELLS)
			self.ammo_shells = self.ammo_shells + autocvar_g_balance_nix_ammoincr_shells;
		else if (nix_weapon_ammo & IT_NAILS)
			self.ammo_nails = self.ammo_nails + autocvar_g_balance_nix_ammoincr_nails;
		else if (nix_weapon_ammo & IT_ROCKETS)
			self.ammo_rockets = self.ammo_rockets + autocvar_g_balance_nix_ammoincr_rockets;
		else if (nix_weapon_ammo & IT_CELLS)
			self.ammo_cells = self.ammo_cells + autocvar_g_balance_nix_ammoincr_cells;
		if (nix_weapon_ammo & IT_FUEL) // hook uses cells and fuel
			self.ammo_fuel = self.ammo_fuel + autocvar_g_balance_nix_ammoincr_fuel;
		self.nix_nextincr = time + autocvar_g_balance_nix_incrtime;
	}

	self.weapons = '0 0 0';
	if(g_nix_with_laser)
		self.weapons &= ~WEPSET_LASER;
	self.weapons |= WepSet_FromWeapon(nix_weapon);

	if(self.switchweapon != nix_weapon)
		if(!client_hasweapon(self, self.switchweapon, TRUE, FALSE))
			if(client_hasweapon(self, nix_weapon, TRUE, FALSE))
				W_SwitchWeapon(nix_weapon);
}

void NIX_precache()
{
	float i;
	for (i = WEP_FIRST; i <= WEP_LAST; ++i)
		if (NIX_CanChooseWeapon(i))
			weapon_action(i, WR_PRECACHE);
}

MUTATOR_HOOKFUNCTION(nix_ForbidThrowCurrentWeapon)
{
	return 1; // no throwing in NIX
}

MUTATOR_HOOKFUNCTION(nix_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":NIX");
	return 0;
}

MUTATOR_HOOKFUNCTION(nix_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", NIX");
	return 0;
}

MUTATOR_HOOKFUNCTION(nix_FilterItem)
{
	switch (self.items)
	{
		case IT_HEALTH:
		case IT_5HP:
		case IT_25HP:
		case IT_ARMOR:
		case IT_ARMOR_SHARD:
			if (autocvar_g_nix_with_healtharmor)
				return 0;
			break;
		case IT_STRENGTH:
		case IT_INVINCIBLE:
			if (autocvar_g_nix_with_powerups)
				return 0;
			break;
	}

	return 1; // delete all other items
}

MUTATOR_HOOKFUNCTION(nix_OnEntityPreSpawn)
{
	if(self.classname == "target_items") // items triggers cannot work in nix (as they change weapons/ammo)
		return 1;
	return 0;
}

MUTATOR_HOOKFUNCTION(nix_PlayerPreThink)
{
	if(!intermission_running)
	if(self.deadflag == DEAD_NO)
	if(IS_PLAYER(self))
		NIX_GiveCurrentWeapon();
	return 0;
}

MUTATOR_HOOKFUNCTION(nix_PlayerSpawn)
{
	self.nix_lastchange_id = -1;
	NIX_GiveCurrentWeapon(); // overrides the weapons you got when spawning
	self.items |= IT_UNLIMITED_SUPERWEAPONS;
	return 0;
}

MUTATOR_HOOKFUNCTION(nix_SetModname)
{
	modname = "NIX";
	return 0;
}

MUTATOR_DEFINITION(mutator_nix)
{
	entity e;

	MUTATOR_HOOK(ForbidThrowCurrentWeapon, nix_ForbidThrowCurrentWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, nix_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, nix_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, nix_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, nix_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, nix_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, nix_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, nix_SetModname, CBC_ORDER_LAST);

	MUTATOR_ONADD
	{
		g_nix_with_laser = autocvar_g_nix_with_laser;

		nix_nextchange = 0;
		nix_nextweapon = 0;

		NIX_precache();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// nothing to roll back
	}

	MUTATOR_ONREMOVE
	{
		// as the PlayerSpawn hook will no longer run, NIX is turned off by this!

		FOR_EACH_PLAYER(e) if(e.deadflag == DEAD_NO)
		{
			e.ammo_cells = start_ammo_cells;
			e.ammo_shells = start_ammo_shells;
			e.ammo_nails = start_ammo_nails;
			e.ammo_rockets = start_ammo_rockets;
			e.ammo_fuel = start_ammo_fuel;
			e.weapons = start_weapons;
			if(!client_hasweapon(e, e.weapon, TRUE, FALSE))
				e.switchweapon = w_getbestweapon(self);
		}
	}

	return 0;
}
