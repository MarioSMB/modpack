// ============
//  DotC Items
// ============


// ===========
// Item giving
// ===========

int dotc_Item_Give(entity item, entity player)
{
	int success = Item_GiveTo(item, player);
	if(success && item.items)
		player.items |= item.items; // this isn't done automatically
	return success;
}

void dotc_ItemSpawn_Give(entity player)
{
	entity spawner, item, core;

	core = dotc_GetCore(player.team);

	for(spawner = world; (spawner = find(spawner, classname, "dotc_itemspawn")); )
	{
		if(spawner.cnt <= core.dotc_corelevel)
		if(spawner.count >= core.dotc_corelevel)
		{
			for(item = world; (item = find(item, targetname, spawner.target)); )
			{
				dotc_Item_Give(item, player);
			}
		}
	}
}


// ============
// Item spawner
// ============

/*
target: All items to give to players between core levels cnt and count
cnt: 	What core level to start giving targeted items
count: 	What core level to stop giving targeted items
*/
spawnfunc(dotc_spawnitems)
{
	if(!g_dotc) { remove(this); return; }

	this.classname = "dotc_itemspawn";

	if(this.target == "")
		LOG_DEBUG("Warning: dotc_spawnitems spawning without .target, fix your map!\n");

	if(!this.cnt) { this.cnt = 1; }
	if(!this.count) { this.count = 10; }
}


// ===================
// Item setup handling
// ===================

void dotc_ItemCheck(entity this)
{
	// check to make sure this item is valid
	entity item_owner = find(world, target, this.targetname);

	if(item_owner.classname != "dotc_itemspawn")
	{
		remove(this);
		return;
	}
}

entity dotc_ItemSpawn(entity olditem)
{
	entity item = spawn();
	item.classname = "dotc_item";
	item.targetname = olditem.targetname;
	item.target = olditem.target;
	item.weapon = olditem.weapon;
	item.weapons = olditem.weapons;
	item.strength_finished = olditem.strength_finished;
	item.invincible_finished = olditem.invincible_finished;
	item.ammo_shells = olditem.ammo_shells;
	item.ammo_cells = olditem.ammo_cells;
	item.ammo_plasma = olditem.ammo_plasma;
	item.ammo_rockets = olditem.ammo_rockets;
	item.ammo_nails = olditem.ammo_nails;
	item.ammo_fuel = olditem.ammo_fuel;
	item.buffs = olditem.buffs;
	item.health = olditem.health;
	item.max_health = olditem.max_health;
	item.armorvalue = olditem.armorvalue;
	item.max_armorvalue = olditem.max_armorvalue;
	item.items = olditem.items;
	item.spawnshieldtime = 1;
	item.pickup_anyway = 1;
	item.itemdef = olditem.itemdef;

	if(olditem.flags & FL_WEAPON)
		item.flags |= FL_WEAPON;
	item.items &= ~IT_PICKUPMASK; // no messages

	InitializeEntity(item, dotc_ItemCheck, INITPRIO_FINDTARGET);

	return item;
}