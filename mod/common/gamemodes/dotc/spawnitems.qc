// ============
//  DotC Items
// ============


IntrusiveList g_dotc_itemgivers;
STATIC_INIT(g_dotc_itemgivers) { g_dotc_itemgivers = IL_NEW(); }


// ===========
// Item giving
// ===========

// save these as autocvars to reduce load
float autocvar_g_pickup_shells_weapon;
float autocvar_g_pickup_nails_weapon;
float autocvar_g_pickup_rockets_weapon;
float autocvar_g_pickup_cells_weapon;
float autocvar_g_pickup_plasma_weapon;
float autocvar_g_pickup_fuel_weapon;

void dotc_ItemSpawn_Give(entity player)
{
	entity core = dotc_GetCore(player.team);

	IL_EACH(g_dotc_itemgivers, it.cnt <= core.dotc_corelevel && it.count >= core.dotc_corelevel,
	{
		GiveItems(player, 0, tokenize_console(it.netname));
	});

	if(player.items & ITEM_Jetpack.m_itemid)
		SetResourceAmount(player, RESOURCE_FUEL, max(GetResourceAmount(player, RESOURCE_FUEL), g_pickup_fuel_jetpack));

	FOREACH(Weapons, it != WEP_Null && (STAT(WEAPONS, player) & it.m_wepset),
	{
		switch (it.ammo_type)
		{
			case RESOURCE_SHELLS:  SetResourceAmount(player, RESOURCE_SHELLS, max(GetResourceAmount(player, RESOURCE_SHELLS), autocvar_g_pickup_shells_weapon)); break;
			case RESOURCE_BULLETS: SetResourceAmount(player, RESOURCE_BULLETS, max(GetResourceAmount(player, RESOURCE_BULLETS), autocvar_g_pickup_nails_weapon)); break;
			case RESOURCE_ROCKETS: SetResourceAmount(player, RESOURCE_ROCKETS, max(GetResourceAmount(player, RESOURCE_ROCKETS), autocvar_g_pickup_rockets_weapon)); break;
			case RESOURCE_CELLS:   SetResourceAmount(player, RESOURCE_CELLS, max(GetResourceAmount(player, RESOURCE_CELLS), autocvar_g_pickup_cells_weapon)); break;
			case RESOURCE_PLASMA:  SetResourceAmount(player, RESOURCE_PLASMA, max(GetResourceAmount(player, RESOURCE_PLASMA), autocvar_g_pickup_plasma_weapon)); break;
			case RESOURCE_FUEL:    SetResourceAmount(player, RESOURCE_FUEL, max(GetResourceAmount(player, RESOURCE_FUEL), autocvar_g_pickup_fuel_weapon)); break;
		}
	});
}


// ============
// Item spawner
// ============

/*
netname: All items to give to players between core levels cnt and count
cnt: 	 What core level to start giving targeted items
count: 	 What core level to stop giving targeted items
*/
spawnfunc(dotc_spawnitems)
{
	if(!g_dotc) { delete(this); return; }
	if(this.target && this.target != "")
	{
		LOG_DEBUG("Warning: dotc_spawnitems no longer supports .target, update your map!\n");
		return;
	}

	this.classname = "dotc_itemspawn";

	IL_PUSH(g_dotc_itemgivers, this);

	if(this.netname == "")
		LOG_DEBUG("Warning: dotc_spawnitems spawning without .netname, fix your map!\n");

	if(!this.cnt) { this.cnt = 1; }
	if(!this.count) { this.count = 10; }

	spawnfunc_target_items(this);
}


// ===========
// Item supply
// ===========

MODEL(DOTC_ITEMSUPPLY, "models/teleporters/teleport.md3");

AUTOCVAR(g_dotc_itemsupply_delay, float, 10, "Delay between resupplies from the item cabinets");

// acts like spawning, resetting player's items to the current level
.float dotc_touchdelay;

void dotc_ItemSupply_TriggerTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;

	if(time < toucher.dotc_touchdelay)
		return;

	if(DIFF_TEAM(this.owner, toucher))
		return;

	toucher.dotc_touchdelay = time + autocvar_g_dotc_itemsupply_delay;

	if (warmup_stage)
	{
		SetResourceAmount(this, RESOURCE_SHELLS, warmup_start_ammo_shells);
		SetResourceAmount(this, RESOURCE_BULLETS, warmup_start_ammo_nails);
		SetResourceAmount(this, RESOURCE_ROCKETS, warmup_start_ammo_rockets);
		SetResourceAmount(this, RESOURCE_CELLS, warmup_start_ammo_cells);
		SetResourceAmount(this, RESOURCE_PLASMA, warmup_start_ammo_plasma);
		SetResourceAmount(this, RESOURCE_FUEL, warmup_start_ammo_fuel);
		SetResourceAmount(this, RESOURCE_HEALTH, warmup_start_health);
		SetResourceAmount(this, RESOURCE_ARMOR, warmup_start_armorvalue);
		STAT(WEAPONS, toucher) = WARMUP_START_WEAPONS;
	}
	else
	{
		SetResourceAmount(this, RESOURCE_SHELLS, start_ammo_shells);
		SetResourceAmount(this, RESOURCE_BULLETS, start_ammo_nails);
		SetResourceAmount(this, RESOURCE_ROCKETS, start_ammo_rockets);
		SetResourceAmount(this, RESOURCE_CELLS, start_ammo_cells);
		SetResourceAmount(this, RESOURCE_PLASMA, start_ammo_plasma);
		SetResourceAmount(this, RESOURCE_FUEL, start_ammo_fuel);
		SetResourceAmount(this, RESOURCE_HEALTH, start_health);
		SetResourceAmount(this, RESOURCE_ARMOR, start_armorvalue);
		STAT(WEAPONS, toucher) = start_weapons;
	}

	dotc_ItemSpawn_Give(toucher);
}

void dotc_ItemSupply_SpawnTrigger(entity this, vector fmins, vector fmaxs)
{
	entity trigger = new(itemsupplytrigger);
	set_movetype(trigger, MOVETYPE_NONE);
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = this;
	settouch(trigger, dotc_ItemSupply_TriggerTouch);
	setsize(trigger, fmins - '60 60 8', fmaxs + '60 60 8');
}

void dotc_ItemSupply_Think(entity this)
{
	this.nextthink = time + 0.5; // really don't need this often
	CSQCMODEL_AUTOUPDATE(this);
}

void dotc_ItemSupply_Init(entity this, int teamnumber)
{
	this.classname = "dotc_itemsupply";
	this.netname = strzone((this.netname == "") ? strcat(dotc_TeamColoredName(teamnumber), " item cabinet") : this.netname);
	this.solid = SOLID_BSP;
	this.team = teamnumber;
	this.colormap = 1024 + (teamnumber - 1) * 17;
	this.glowmod = (teamnumber) ? Team_ColorRGB(teamnumber) : '1 1 1';

	this.angles_x = -this.angles.x; // ported from misc_gamemodel
	set_movetype(this, MOVETYPE_NONE);
	setmodel(this, MDL_DOTC_ITEMSUPPLY);
	SetBrushEntityModelNoLOD(this);

	setthink(this, dotc_ItemSupply_Think);
	this.nextthink = time + 0.5;

	// cabinet placement
	if((this.spawnflags & 1) || this.noalign) // don't drop to floor, just stay at fixed location
		this.noalign = true;
	else // drop to floor, automatically find a platform and set that as spawn origin
	{
		this.noalign = false;
		droptofloor(this);
	}

	CSQCMODEL_AUTOINIT(this);

	dotc_ItemSupply_SpawnTrigger(this, this.absmin, this.absmax);
}

spawnfunc(dotc_itemsupply_red) { dotc_ItemSupply_Init(this, NUM_TEAM_1); }
spawnfunc(dotc_itemsupply_blue) { dotc_ItemSupply_Init(this, NUM_TEAM_2); }
spawnfunc(dotc_itemsupply_yellow) { dotc_ItemSupply_Init(this, NUM_TEAM_3); }
spawnfunc(dotc_itemsupply_pink) { dotc_ItemSupply_Init(this, NUM_TEAM_4); }
