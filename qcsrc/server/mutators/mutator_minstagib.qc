void spawnfunc_item_minst_cells (void)
{
	if (!g_minstagib) { remove(self); return; }
	if (!self.ammo_cells)
		self.ammo_cells = autocvar_g_minstagib_ammo_drop;

	StartItem ("models/items/a_cells.md3",
			   "misc/itempickup.wav", 45, 0,
			   "MinstaNex Ammo", IT_CELLS, 0, 0, generic_pickupevalfunc, 100);
}

void minstagib_item_supercells() 
{
	if(!g_minstagib) { remove(self); return; }
	if(!self.ammo_supercells)
		self.ammo_supercells = 2;

	StartItem ("models/items/a_supercells.md3",
			   "misc/itempickup.wav", 45, 0,
			   "supercells", IT_SUPERCELLS, 0, 0, generic_pickupevalfunc, 100);
}

void minstagib_health_mega()
{
	self.max_health = 1;
	StartItem ("models/items/g_h100.md3",
			   "misc/megahealth.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			   "Extralife", IT_NAILS, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
}

.float minstagib_nextthink;
.float minstagib_needammo;
void minstagib_stop_countdown(entity e)
{
	if (!e.minstagib_needammo)
		return;
	Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_MINSTA_FINDAMMO);
	e.minstagib_needammo = FALSE;
}
void minstagib_ammocheck()
{
	if (!IS_PLAYER(self))
		return; // not a player
	if (time < self.minstagib_nextthink)
		return;

	if (self.deadflag || gameover)
		minstagib_stop_countdown(self);
	else if (self.ammo_cells > 0 || (self.items & IT_UNLIMITED_WEAPON_AMMO))
		minstagib_stop_countdown(self);
	else if(autocvar_g_rm)
	{
		if(!self.minstagib_needammo)
		{
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_MINSTA_DOWNGRADE);
			self.minstagib_needammo = TRUE;
		}
	}
	else
	{
		self.minstagib_needammo = TRUE;
		if (self.health <= 5)
		{
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_MINSTAGIB_TERMINATED);
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
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_MINSTA_FINDAMMO);
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_NUM_9);
		}
		else if (self.health >= 100 || self.health <= 100)
		{
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_MULTI, MULTI_MINSTA_FINDAMMO);
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
		}
	}
	self.minstagib_nextthink = time + 1;
}

MUTATOR_HOOKFUNCTION(minstagib_MatchEnd)
{
	entity head;
	FOR_EACH_PLAYER(head)
		minstagib_stop_countdown(head);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_MonsterLoot)
{
	other.monster_loot = spawnfunc_item_minst_cells;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_MonsterSpawn)
{
	// always refill ammo
	if(self.monsterid == MON_MAGE)
		self.skin = 1;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_BotShouldAttack)
{
	if(checkentity.items & IT_STRENGTH)
		return TRUE;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_MakePlayerObserver)
{
	minstagib_stop_countdown(self);
	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_PlayerSpawn)
{
	self.effects |= EF_FULLBRIGHT;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_PlayerPreThink)
{
	minstagib_ammocheck();
	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_PlayerRegen)
{
	// no regeneration in minstagib
	return TRUE;
}

MUTATOR_HOOKFUNCTION(minstagib_PlayerPowerups)
{
	if (!(self.effects & EF_FULLBRIGHT))
		self.effects |= EF_FULLBRIGHT;

	if (self.items & IT_STRENGTH)
	{
		play_countdown(self.strength_finished, "misc/poweroff.wav");
		if (time > self.strength_finished)
		{
			self.alpha = default_player_alpha;
			self.exteriorweaponentity.alpha = default_weapon_alpha;
			self.items &= ~IT_STRENGTH;
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERDOWN_INVISIBILITY);
		}
	}
	else
	{
		if (time < self.strength_finished)
		{
			self.alpha = autocvar_g_minstagib_invis_alpha;
			self.exteriorweaponentity.alpha = autocvar_g_minstagib_invis_alpha;
			self.items |= IT_STRENGTH;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_INVISIBILITY, self.netname);
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERUP_INVISIBILITY);
		}
	}

	if (self.items & IT_INVINCIBLE)
	{
		play_countdown(self.invincible_finished, "misc/poweroff.wav");
		if (time > self.invincible_finished)
		{
			self.items &= ~IT_INVINCIBLE;
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERDOWN_SPEED);
		}
	}
	else
	{
		if (time < self.invincible_finished)
		{
			self.items |= IT_INVINCIBLE;
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_SPEED, self.netname);
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERUP_SPEED);
		}
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_PlayerPhysics)
{
	if(self.items & IT_INVINCIBLE)
	{
		self.stat_sv_maxspeed *= autocvar_g_minstagib_speed_highspeed;
		self.stat_sv_airspeedlimit_nonqw *= autocvar_g_minstagib_speed_highspeed;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_SplitHealthArmor)
{
	damage_save = 0;
	damage_take = frag_damage;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_ForbidThrowing)
{
	// weapon dropping on death handled by FilterItem

	return TRUE;
}

MUTATOR_HOOKFUNCTION(minstagib_PlayerDamage)
{
	if(frag_deathtype == DEATH_NOAMMO)
		return FALSE;

	if((autocvar_g_rm || autocvar_g_rm_laser == 2) && (DEATH_ISWEAPON(frag_deathtype, WEP_ROCKET_LAUNCHER) || DEATH_ISWEAPON(frag_deathtype, WEP_ELECTRO)) && (frag_target == frag_attacker || frag_target.classname == "nade"))
		frag_damage = 0; // no self/nade damage?
		
	if((autocvar_g_rm || autocvar_g_rm_laser == 2) && (DEATH_ISWEAPON(frag_deathtype, WEP_ELECTRO)) && forbidWeaponUse(frag_attacker) == 2)
		frag_damage = 0; // no laser damage before round starts

	if(IS_PLAYER(frag_target))
	{
		if(frag_deathtype == DEATH_FALL)
			frag_damage = 0; // never count fall damage

		if(!autocvar_g_minstagib_damagedbycontents)
		switch(frag_deathtype)
		{
			case DEATH_DROWN:
			case DEATH_SLIME:
			case DEATH_LAVA:
				frag_damage = 0;
				break;
		}

		if(IS_PLAYER(frag_attacker))
		{
			if(DEATH_ISWEAPON(frag_deathtype, WEP_MINSTANEX))
			if(frag_target.armorvalue)
			{
				frag_target.armorvalue -= 1;
				Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, CENTER_MINSTA_LIVES_REMAINING, frag_target.armorvalue);
				frag_damage = 0;
				frag_target.hitsound += 1;
				frag_attacker.hitsound += 1; // TODO change this to a future specific hitsound for armor hit
			}

			if(DEATH_ISWEAPON(frag_deathtype, WEP_LASER))
			{
				frag_damage = 0;
				frag_mirrordamage = 0;
				if (frag_target != frag_attacker)
				{
					if (frag_target.health >= 1 && !frag_target.frozen && frag_target.deadflag == DEAD_NO)
						Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_SECONDARY_NODAMAGE);
					frag_force = '0 0 0';
					// keep mirrorfrag_force
					//frag_attacker = frag_target;
				}
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
			Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_MINSTA_LIVES_REMAINING, frag_attacker.armorvalue);
			frag_attacker.hitsound += 1;
		}
		frag_mirrordamage = 0;
	}

	if(frag_target.items & IT_STRENGTH)
		yoda = 1;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_SetStartItems)
{
	start_ammo_cells = warmup_start_ammo_cells = cvar("g_minstagib_ammo_start");
	start_ammo_rockets = warmup_start_ammo_rockets = cvar("g_minstagib_withmines_ammo_start");

	start_health = warmup_start_health = 100;
	start_armorvalue = warmup_start_armorvalue = 0;
	start_weapons = warmup_start_weapons = ((cvar("g_minstagib_withmines")) ? (WEPSET_MINSTANEX | WEPSET_MINE_LAYER) : WEPSET_MINSTANEX);
	start_items |= IT_UNLIMITED_SUPERWEAPONS;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_FilterItem)
{
	if(self.weapon == WEP_MINSTANEX && self.classname == "droppedweapon")
	{
		self.ammo_cells = autocvar_g_minstagib_ammo_drop;
		return FALSE;
	}

	if(self.weapon == WEP_ROCKET_LAUNCHER || self.weapon == WEP_NEX)
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

	if(self.ammo_cells > autocvar_g_minstagib_ammo_drop && self.classname != "item_minst_cells")
		self.ammo_cells = autocvar_g_minstagib_ammo_drop;

	if((self.ammo_cells || self.ammo_supercells) && !self.weapon)
		return FALSE;

	return TRUE;
}

MUTATOR_HOOKFUNCTION(minstagib_CustomizeWaypoint)
{
	entity e = WaypointSprite_getviewentity(other);

	// if you have the invisibility powerup, sprites ALWAYS are restricted to your team
	// but only apply this to real players, not to spectators
	if((self.owner.flags & FL_CLIENT) && (self.owner.items & IT_STRENGTH) && (e == other))
	if(DIFF_TEAM(self.owner, e))
		return TRUE;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_ItemCountdown)
{
	switch(self.items)
	{
		case IT_STRENGTH:   item_name = "item-invis"; item_color = '0 0 1'; break;
		case IT_NAILS:      item_name = "item-extralife"; item_color = '1 0 0'; break;
		case IT_INVINCIBLE: item_name = "item-speed"; item_color = '1 0 1'; break;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_PlayerDies)
{	
	if(DEATH_ISWEAPON(frag_deathtype, WEP_MINSTANEX) || (autocvar_g_rm && DEATH_ISWEAPON(frag_deathtype, WEP_ROCKET_LAUNCHER)) || (((autocvar_g_rm && autocvar_g_rm_laser == 1) || autocvar_g_rm_laser == 2) && DEATH_ISWEAPON(frag_deathtype, WEP_ELECTRO)))
		frag_damage = 1000; // always gib if it was a minstanex death

	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_ItemTouch)
{
	if(self.ammo_cells || self.ammo_supercells)
	{
		// play some cool sounds ;)
		if (IS_CLIENT(other))
		{
			if(other.health <= 5)
				Send_Notification(NOTIF_ONE, other, MSG_ANNCE, ANNCE_MINSTAGIB_LASTSECOND);
			else if(other.health < 50)
				Send_Notification(NOTIF_ONE, other, MSG_ANNCE, ANNCE_MINSTAGIB_NARROWLY);
		}

		if(other.health < 100)
			other.health = 100;

		return MUT_ITEMTOUCH_CONTINUE;
	}

	if(self.max_health)
	{
		other.armorvalue = bound(other.armorvalue, 999, other.armorvalue + autocvar_g_minstagib_extralives);
		Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_EXTRALIVES);
		return MUT_ITEMTOUCH_PICKUP;
	}

	return MUT_ITEMTOUCH_CONTINUE;
}

MUTATOR_HOOKFUNCTION(minstagib_OnEntityPreSpawn)
{
	if(autocvar_g_balance_minstanex_superblast)
	if(self.classname == "item_cells" || self.classname == "item_minst_cells")
	if(random() <= 0.5)
		minstagib_item_supercells();

	if(!autocvar_g_powerups) { return FALSE; }
	if(!(self.classname == "item_strength" || self.classname == "item_invincible" || self.classname == "item_health_mega"))
		return FALSE;

	entity e = spawn();

	if(random() < 0.3)
		e.think = spawnfunc_item_strength;
	else if(random() < 0.6)
		e.think = minstagib_health_mega;
	else
		e.think = spawnfunc_item_invincible;

	e.nextthink = time + 0.1;
	e.spawnflags = self.spawnflags;
	e.noalign = self.noalign;
	setorigin(e, self.origin);

	return TRUE;
}

MUTATOR_HOOKFUNCTION(minstagib_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":MinstaGib");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", MinstaGib");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(minstagib_SetModname)
{
	modname = "MinstaGib";
	return TRUE;
}

MUTATOR_DEFINITION(mutator_minstagib)
{
	MUTATOR_HOOK(MatchEnd, minstagib_MatchEnd, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterDropItem, minstagib_MonsterLoot, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterSpawn, minstagib_MonsterSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(BotShouldAttack, minstagib_BotShouldAttack, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPhysics, minstagib_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, minstagib_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, minstagib_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, minstagib_MakePlayerObserver, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, minstagib_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(ItemTouch, minstagib_ItemTouch, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, minstagib_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(CustomizeWaypoint, minstagib_CustomizeWaypoint, CBC_ORDER_ANY);
	MUTATOR_HOOK(Item_RespawnCountdown, minstagib_ItemCountdown, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, minstagib_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_SplitHealthArmor, minstagib_SplitHealthArmor, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPowerups, minstagib_PlayerPowerups, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, minstagib_ForbidThrowing, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, minstagib_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, minstagib_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, minstagib_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, minstagib_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, minstagib_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, minstagib_SetModname, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		precache_sound("weapons/rocket_impact.wav");
		
		if(cvar("g_minstagib_withmines"))
			(get_weaponinfo(WEP_MINE_LAYER)).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
	}
	
	MUTATOR_ONREMOVE
	{
		if(cvar("g_minstagib_withmines"))
			(get_weaponinfo(WEP_MINE_LAYER)).spawnflags |= WEP_FLAG_MUTATORBLOCKED;
	}

	return FALSE;
}
