void spawnfunc_item_minst_cells (void)
{
	if (!g_instagib) { remove(self); return; }
	if (!self.ammo_cells)
		self.ammo_cells = autocvar_g_instagib_ammo_drop;

	StartItem ("models/items/a_cells.md3",
			   "misc/itempickup.wav", 45, 0,
			   "Vaporizer Ammo", IT_CELLS, 0, 0, generic_pickupevalfunc, 100);
}

void spawnfunc_item_minst_rockets (void)
{
	if (!g_instagib) { remove(self); return; }
	if(!cvar("g_instagib_withmines")) { remove(self); return; }
	if (!self.ammo_rockets)
		self.ammo_rockets = autocvar_g_instagib_ammo_rockets;

	StartItem ("models/items/a_rockets.md3",
			   "misc/itempickup.wav", 45, 0,
			   "Vaporizer Ammo", IT_ROCKETS, 0, 0, generic_pickupevalfunc, 100);
}

void instagib_item_supercells() 
{
	if(!g_instagib) { remove(self); return; }
	if(!self.ammo_supercells)
		self.ammo_supercells = 2;

	StartItem ("models/items/a_supercells.md3",
			   "misc/itempickup.wav", 45, 0,
			   "supercells", IT_SUPERCELLS, 0, 0, generic_pickupevalfunc, 100);
}

void instagib_health_mega()
{
	self.max_health = 1;
	StartItem ("models/items/g_h100.md3",
			   "misc/megahealth.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			   "Extralife", IT_NAILS, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
}

.float instagib_nextthink;
.float instagib_needammo;
void instagib_stop_countdown(entity e)
{
	if (!e.instagib_needammo)
		return;
	Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_INSTAGIB_FINDAMMO);
	e.instagib_needammo = FALSE;
}
void instagib_ammocheck()
{
	if(time < self.instagib_nextthink)
		return;
	if(!IS_PLAYER(self))
		return; // not a player

	if(self.deadflag || gameover)
		instagib_stop_countdown(self);
	else if (self.ammo_cells > 0 || (self.items & IT_UNLIMITED_WEAPON_AMMO) || (self.flags & FL_GODMODE))
		instagib_stop_countdown(self);
	else if(autocvar_g_rm)
	{
		if(!self.instagib_needammo)
		{
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_INSTAGIB_DOWNGRADE);
			self.instagib_needammo = TRUE;
		}
	}
	else
	{
		self.instagib_needammo = TRUE;
		if (self.health <= 5)
		{
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_INSTAGIB_TERMINATED);
		}
		else if (self.health <= 10)
		{
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_1);
		}
		else if (self.health <= 20)
		{
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_2);
		}
		else if (self.health <= 30)
		{
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_3);
		}
		else if (self.health <= 40)
		{
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_4);
		}
		else if (self.health <= 50)
		{
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_5);
		}
		else if (self.health <= 60)
		{
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_6);
		}
		else if (self.health <= 70)
		{
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_7);
		}
		else if (self.health <= 80)
		{
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_8);
		}
		else if (self.health <= 90)
		{
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_INSTAGIB_FINDAMMO);
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_9);
		}
		else
		{
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_MULTI, MULTI_INSTAGIB_FINDAMMO);
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
		}
	}
	self.instagib_nextthink = time + 1;
}

MUTATOR_HOOKFUNCTION(instagib_MatchEnd)
{
	entity head;
	FOR_EACH_PLAYER(head)
		instagib_stop_countdown(head);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_MonsterLoot)
{
	other.monster_loot = ((random() > 0.5 && autocvar_g_instagib_use_normal_ammo && cvar("g_instagib_withmines")) ? spawnfunc_item_minst_rockets : spawnfunc_item_minst_cells);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_MonsterSpawn)
{
	// always refill ammo
	if(self.monsterid == MON_MAGE)
		self.skin = 1;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_MakePlayerObserver)
{
	instagib_stop_countdown(self);
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_PlayerSpawn)
{
	self.effects |= EF_FULLBRIGHT;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_PlayerPreThink)
{
	instagib_ammocheck();
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_PlayerRegen)
{
	// no regeneration in instagib
	return TRUE;
}

MUTATOR_HOOKFUNCTION(instagib_PlayerPowerups)
{
	if (!(self.effects & EF_FULLBRIGHT))
		self.effects |= EF_FULLBRIGHT;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_SplitHealthArmor)
{
	damage_save = 0;
	damage_take = frag_damage;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_ForbidThrowing)
{
	// weapon dropping on death handled by FilterItem

	return TRUE;
}

MUTATOR_HOOKFUNCTION(instagib_PlayerDamage)
{
	if(frag_deathtype == DEATH_NOAMMO)
		return FALSE;

	if(autocvar_g_rm)
	if(DEATH_ISWEAPON(frag_deathtype, WEP_DEVASTATOR))
	if(frag_attacker == frag_target || frag_target.classname == "nade")
		frag_damage = 0;

	if((autocvar_g_rm && autocvar_g_rm_laser == 1) || autocvar_g_rm_laser == 2)
	if(DEATH_ISWEAPON(frag_deathtype, WEP_ELECTRO))
	if(frag_attacker == frag_target || forbidWeaponUse(frag_attacker) == 2)
		frag_damage = 0;

	if(IS_PLAYER(frag_target))
	{
		if(frag_deathtype == DEATH_FALL)
			frag_damage = 0; // never count fall damage

		if(!autocvar_g_instagib_damagedbycontents)
		switch(frag_deathtype)
		{
			case DEATH_DROWN:
			case DEATH_SLIME:
			case DEATH_LAVA:
				frag_damage = 0;
				break;
		}

		if(IS_PLAYER(frag_attacker))
		if(DEATH_ISWEAPON(frag_deathtype, WEP_VAPORIZER))
		{
			if(frag_deathtype & HITTYPE_SECONDARY)
			{
				frag_damage = frag_mirrordamage = 0;
				
				if(frag_target != frag_attacker)
				{
					if(frag_target.health > 0) { Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_SECONDARY_NODAMAGE); }
					frag_force = '0 0 0';
				}
			}
			else if(frag_target.armorvalue)
			{
				frag_target.armorvalue -= 1;
				frag_damage = 0;
				frag_target.damage_dealt += 1;
				frag_attacker.damage_dealt += 1; // TODO: change this to a specific hitsound for armor hit
				Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, CENTER_INSTAGIB_LIVES_REMAINING, frag_target.armorvalue);
			}
		}
	}

	if(IS_PLAYER(frag_attacker))
	if(frag_mirrordamage > 0)
	{
		// just lose extra LIVES, don't kill the player for mirror damage
		if(frag_attacker.armorvalue > 0)
		{
			frag_attacker.armorvalue -= 1;
			Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_INSTAGIB_LIVES_REMAINING, frag_attacker.armorvalue);
			frag_attacker.damage_dealt += frag_mirrordamage;
		}
		frag_mirrordamage = 0;
	}

	if(frag_target.buffs & BUFF_INVISIBLE)
		yoda = 1;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_SetStartItems)
{
	start_ammo_cells = warmup_start_ammo_cells = cvar("g_instagib_ammo_start");
	start_ammo_rockets = warmup_start_ammo_rockets = cvar("g_instagib_withmines_ammo_start");

	start_health = warmup_start_health = 100;
	start_armorvalue = warmup_start_armorvalue = 0;
	start_weapons = warmup_start_weapons = ((cvar("g_instagib_withmines")) ? (WEPSET_VAPORIZER | WEPSET_MINE_LAYER) : WEPSET_VAPORIZER);
	start_items |= IT_UNLIMITED_SUPERWEAPONS;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_FilterItem)
{
	if(self.classname == "item_cells")
	if(!autocvar_g_instagib_use_normal_ammo)
		return TRUE;
		
	if(self.classname == "item_rockets")
	if(!autocvar_g_instagib_use_normal_ammo || !cvar("g_instagib_withmines"))
		return TRUE;

	if(self.weapon == WEP_VAPORIZER && self.classname == "droppedweapon")
	{
		self.ammo_cells = autocvar_g_instagib_ammo_drop;
		return FALSE;
	}

	if(self.weapon == WEP_DEVASTATOR || self.weapon == WEP_VORTEX)
	{
		entity e = spawn(), oldself;
		
		setorigin(e, self.origin);
		oldself = self;
		self = e;
		self.noalign = oldself.noalign;
		self.cnt = oldself.cnt;
		self.team = oldself.team;
		spawnfunc_item_minst_cells();
		self = oldself;
		return TRUE;
	}

	if(self.flags & FL_POWERUP)
		return FALSE;

	if(self.ammo_cells > autocvar_g_instagib_ammo_drop && self.classname != "item_minst_cells")
		self.ammo_cells = autocvar_g_instagib_ammo_drop;

	if(self.classname != "item_minst_rockets")
		self.ammo_rockets = bound(0, self.ammo_rockets, autocvar_g_instagib_ammo_rockets);

	if((self.ammo_cells || self.ammo_supercells) && !self.weapon)
		return FALSE;

	if(self.ammo_rockets && !self.weapon)
		return FALSE;

	return TRUE;
}

MUTATOR_HOOKFUNCTION(instagib_ItemCountdown)
{
	switch(self.items)
	{
		case IT_NAILS:      item_name = "item-extralife"; item_color = '1 0 0'; break;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_PlayerDies)
{	
	if(	(DEATH_ISWEAPON(frag_deathtype, WEP_VAPORIZER))
	||	(autocvar_g_rm && DEATH_ISWEAPON(frag_deathtype, WEP_DEVASTATOR))
	|| 	(((autocvar_g_rm && autocvar_g_rm_laser == 1) || autocvar_g_rm_laser == 2) && DEATH_ISWEAPON(frag_deathtype, WEP_ELECTRO))
	)
		frag_damage = 1000; // always gib if it was a vaporizer death

	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_ItemTouch)
{
	if(self.ammo_cells || self.ammo_supercells)
	{
		// play some cool sounds ;)
		if (IS_CLIENT(other))
		{
			if(other.health <= 5)
				Send_Notification(NOTIF_ONE, other, MSG_ANNCE, ANNCE_INSTAGIB_LASTSECOND);
			else if(other.health < 50)
				Send_Notification(NOTIF_ONE, other, MSG_ANNCE, ANNCE_INSTAGIB_NARROWLY);
		}

		if(other.health < 100)
			other.health = 100;

		return MUT_ITEMTOUCH_CONTINUE;
	}

	if(self.max_health)
	{
		other.armorvalue = bound(other.armorvalue, 999, other.armorvalue + autocvar_g_instagib_extralives);
		Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_EXTRALIVES);
		return MUT_ITEMTOUCH_PICKUP;
	}

	return MUT_ITEMTOUCH_CONTINUE;
}

MUTATOR_HOOKFUNCTION(instagib_OnEntityPreSpawn)
{
	if(WEP_CVAR_PRI(vaporizer, charge))
	if(self.classname == "item_cells" || self.classname == "item_minst_cells")
	if(random() <= 0.5)
		instagib_item_supercells();

	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":instagib");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", instagib");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(instagib_SetModname)
{
	modname = "instagib";
	return TRUE;
}

MUTATOR_DEFINITION(mutator_instagib)
{
	MUTATOR_HOOK(MatchEnd, instagib_MatchEnd, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterDropItem, instagib_MonsterLoot, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterSpawn, instagib_MonsterSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, instagib_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, instagib_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, instagib_MakePlayerObserver, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, instagib_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(ItemTouch, instagib_ItemTouch, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, instagib_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(Item_RespawnCountdown, instagib_ItemCountdown, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, instagib_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_SplitHealthArmor, instagib_SplitHealthArmor, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPowerups, instagib_PlayerPowerups, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, instagib_ForbidThrowing, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, instagib_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, instagib_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, instagib_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, instagib_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, instagib_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, instagib_SetModname, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		precache_sound(W_Sound("rocket_impact"));
		
		if(cvar("g_instagib_withmines"))
			(get_weaponinfo(WEP_MINE_LAYER)).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;

            g_instagib = cvar("g_instagib");
	}
	
	MUTATOR_ONREMOVE
	{
		if(cvar("g_instagib_withmines"))
			(get_weaponinfo(WEP_MINE_LAYER)).spawnflags |= WEP_FLAG_MUTATORBLOCKED;

             g_instagib = 0;
	}

	return FALSE;
}
