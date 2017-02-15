AUTOCVAR(g_itemplacer, bool, false, _("Item placement tool to spawn in some entities"));
AUTOCVAR(g_itemplacer_spawnitems, bool, false, _("Also attempt to spawn in the items as they're placed"));

.bool canplace;
bool map_has_entfile;

REGISTER_MUTATOR(itemplacer, autocvar_g_itemplacer);

void try_itemspawn(entity caller, string item)
{
	if(startsWith(item, "vehicle_"))
	{
		string theveh = substring(item, 8, strlen(item));
		FOREACH(Vehicles, it.netname == theveh,
		{
			entity veh = new(placed_item);
			veh.spawnfunc_checked = true;
			//veh.classname = item;
			setorigin(veh, caller.origin);
			veh.angles = caller.angles;
			veh.team = caller.team;
			if(!vehicle_initialize(veh, it, false))
				delete(veh);
			return; // got our vehicle!
		});
		return; // it's a vehicle, don't try anything else
	}

	if(startsWith(item, "weapon_"))
	{
		string thewep = substring(item, 7, strlen(item));
		FOREACH(Weapons, it.netname == thewep,
		{
			entity wep = new(placed_item);
			wep.spawnfunc_checked = true;
			//wep.classname = item;
			setorigin(wep, caller.origin);
			//wep.angles = caller.angles;
			weapon_defaultspawnfunc(wep, it);
			return;
		});
		return; // it's a weapon, don't try anything else
	}

	if(startsWith(item, "monster_"))
	{
		string themon = substring(item, 8, strlen(item));
		FOREACH(Monsters, it.netname == themon,
		{
			entity mon = new(placed_item);
			mon.spawnfunc_checked = true;
			//mon.classname = item;
			setorigin(mon, caller.origin);
			mon.angles = caller.angles;
			Monster_Spawn(mon, true, it.monsterid);
			return;
		});
		return; // it's a monster, don't try anything else
	}

	string theitem = substring(item, 5, strlen(item));
	FOREACH(Items, it.netname == theitem,
	{
		entity itm = new(placed_item);
		itm.spawnfunc_checked = true;
		//itm.classname = item;
		setorigin(itm, caller.origin);
		//itm.angles = caller.angles;
		StartItem(itm, it);
	});
}

void place_item(entity caller, string item)
{
	string filename = strcat(mapname, "_item_ent.txt");
	int fh = fopen(filename, FILE_APPEND);

	if (fh >= 0)
	{
		fputs(fh, "{\n");
		fputs(fh, strcat("\"classname\" \"", item, "\"\n"));
		fputs(fh, strcat("\"origin\" \"", strcat(ftos(caller.origin_x), " ", ftos(caller.origin_y), " ", ftos(caller.origin_z)), "\"\n"));
		fputs(fh, strcat("\"angles\" \"", strcat(ftos(caller.angles_x), " ", ftos(caller.angles_y), " ", ftos(caller.angles_z)), "\"\n"));
		if(startsWith(item, "vehicle_"))
			fputs(fh, strcat("\"team\" \"", ftos(caller.team), "\"\n"));
		fputs(fh, "}\n");

		LOG_INFO("Completed item entity dump in ^2data/data/", mapname, "_item_ent.txt^7.\n");
		print_to(caller, "Successfully placed item!");

		fclose(fh);
	}
	else
	{
		LOG_INFO("^1Error: ^7Could not dump to file!\n");
		print_to(caller, "^1Error: ^7Could not open the entity file, item couldn't be placed.");
	}
}

MUTATOR_HOOKFUNCTION(itemplacer, SetStartItems)
{
	map_has_entfile = fexists(strcat(mapname, "_item_ent.txt"));
}

MUTATOR_HOOKFUNCTION(itemplacer, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	entity caller = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);

	if(cmd_name == "create_item" || cmd_name == "place_item")
	{
		if(!caller.canplace)
		{
			print_to(caller, "You're not allowed to place items.");
			return true;
		}

		string item = argv(1);
		if(autocvar_g_itemplacer_spawnitems && !map_has_entfile)
			try_itemspawn(caller, item);
		place_item(caller, item);
		return true;
	}
}

MUTATOR_HOOKFUNCTION(itemplacer, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);

	if(cmd_name == "allow_placeitems")
	{
		entity player = GetFilteredEntity(argv(1));
		int accepted = VerifyClientEntity(player, true, false);
		if(accepted > 0)
		{
			player.canplace = true;
			print_to(player, "You're now allowed to place items!");
			LOG_INFO(playername(player, false), " has been granted item placement abilities.\n");
		}
		else
			LOG_INFO("Invalid player.\n");
		return true;
	}

	if(cmd_name == "deny_placeitems")
	{
		entity player = GetFilteredEntity(argv(1));
		int accepted = VerifyClientEntity(player, true, false);
		if(accepted > 0)
		{
			player.canplace = false;
			print_to(player, "You're no longer allowed to place items.");
			LOG_INFO(playername(player, false), " has been revoked of item placement abilities.\n");
		}
		else
			LOG_INFO("Invalid player.\n");
		return true;
	}
}
