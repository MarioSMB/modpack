float ie_itemcount;
.string ie_itemname;

float ie_enabled;

float ie_database_loaded;

string ie_port_string;

vector rintvec(vector vec)
{
	vector rinted;
	rinted_x = rint(vec_x);
	rinted_y = rint(vec_y);
	rinted_z = rint(vec_z);
	return rinted;
}

void ie_Debug(string input)
{
	switch(autocvar_g_itemeditor_debug)
	{
		case 1: dprint(input); break;
		case 2: print(input); break;
	}
}

entity ie_SpawnItem(float database);
string ie_ItemPort_Save(entity e, float database)
{
	// save item properties, and return them as a string
	string s;
	entity head = e;

	if(head)
	{
		// ---------------- ITEM PROPERTY STORAGE: SAVE ----------------
		if(database) { ie_port_string = strcat(ie_port_string, sprintf("\"%.9v\"", rintvec(head.origin)), " "); }
		ie_port_string = strcat(ie_port_string, sprintf("\"%.9f\"", head.team), " ");
		ie_port_string = strcat(ie_port_string, sprintf("\"%.9f\"", head.cnt), " ");
		ie_port_string = strcat(ie_port_string, sprintf("\"%.9f\"", head.noalign), " ");
		ie_port_string = strcat(ie_port_string, sprintf("\"%s\"", head.ie_itemname), " ");
	}

	// now apply the array to a simple string, with the ; symbol separating items
	s = "";
	if(ie_port_string) { s = strcat(s, ie_port_string, "; "); ie_port_string = string_null; }

	return s;
}

// this will be removed when we have ID based item handling
string ie_FixItemName(string itname)
{
	switch(itname)
	{
		case "item_armor_small": case "smallarmor": case "armor_small": case "armorshard":
			return "item_armor_small";
		case "item_armor_medium": case "mediumarmor": case "armor_medium":
			return "item_armor_medium";
		case "item_armor_big": case "bigarmor": case "armor_big":
			return "item_armor_big";
		case "item_armor_large": case "largearmor": case "armor_large": case "megaarmor": case "ma":
			return "item_armor_large";
		case "item_health_small": case "smallhealth": case "health_small":
			return "item_health_small";
		case "item_health_medium": case "mediumhealth": case "health_medium":
			return "item_health_medium";
		case "item_health_large": case "largehealth": case "health_large":
			return "item_health_large";
		case "item_health_mega": case "megahealth": case "health_mega": case "mh": case "megahealth":
			return "item_health_mega";
		case "cells": case "item_cells": case "ammo_cells":
			return "item_cells";
		case "bullets": case "nails": case "item_bullets": case "item_nails": case "ammo_bullets": case "ammo_nails":
			return "item_bullets";
		case "rockets": case "explosives": case "item_rockets": case "item_explosives": case "ammo_rockets": case "ammo_explosives":
			return "item_rockets";
		case "strength": case "item_strength": case "powerup_strength":
			return "item_strength";
		case "invincible": case "item_invincible": case "powerup_invincible":
			return "item_strength";
		default:
		{
			float i;
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
				if((get_weaponinfo(i)).netname == itname || (get_weaponinfo(i)).netname == substring(itname, 7, strlen(itname)))
					return ((get_weaponinfo(i)).netname == substring(itname, 7, strlen(itname)) ? strcat("weapon_", itname) : itname);
			return "";
		}
	}
}

void ie_SetItemType(entity e)
{
	string fixed_name = ie_FixItemName(e.ie_itemname);
	if(fixed_name == "") { return; }
	print("Attempting to spawn ", fixed_name, "\n");
	initialize_field_db();
	target_spawn_edit_entity(e, strcat("$ spawnfunc_", fixed_name), world, world, world, world, world);

	e.classname = "itemeditor_item";
}

entity ie_ItemPort_Load(string s, float database)
{
	// load item properties, and spawn a new item with them
	float n;
	entity e = world;

	// separate items between the ; symbols
	n = tokenizebyseparator(s, "; ");
	ie_port_string = argv(0);

	// now separate and apply the properties of each item
	float argv_num = 0;

	tokenize_console(ie_port_string);
	e = ie_SpawnItem(database);

	if(database) { setorigin(e, stov(argv(argv_num))); ++argv_num; }
	e.team = stof(argv(argv_num)); ++argv_num;
	e.cnt = stof(argv(argv_num)); ++argv_num;
	e.noalign = stof(argv(argv_num)); ++argv_num;
	e.ie_itemname = strzone(argv(argv_num)); ++argv_num;

	print(e.ie_itemname, "\n");
	ie_SetItemType(e);

	ie_port_string = string_null; // fully clear the string

	return e;
}

void ie_Database_Save()
{
	// saves all items to the database file
	entity head;
	string file_name;
	float file_get;

	file_name = strcat("itemeditor/storage_", autocvar_g_itemeditor_storage_name, "_", GetMapname(), ".txt");
	file_get = fopen(file_name, FILE_WRITE);
	fputs(file_get, strcat("// itemeditor storage \"", autocvar_g_itemeditor_storage_name, "\" for map \"", GetMapname(), "\""));
	fputs(file_get, strcat(" containing ", ftos(ie_itemcount), " items\n"));

	for(head = world; (head = find(head, classname, "itemeditor_item")); )
	{
		// use a line of text for each item, listing all properties
		fputs(file_get, strcat(ie_ItemPort_Save(head, TRUE), "\n"));
	}
	fclose(file_get);
}

void ie_Database_Load()
{
	// loads all items from the database file
	string file_read, file_name;
	float file_get;

	file_name = strcat("itemeditor/storage_", autocvar_g_itemeditor_storage_name, "_", GetMapname(), ".txt");
	file_get = fopen(file_name, FILE_READ);
	if(file_get < 0)
	{
		ie_Debug(strcat("^3ITEMEDITOR - Server: ^7could not find storage file ^3", file_name, "^7, no items were loaded\n"));
	}
	else
	{
		for(;;)
		{
			file_read = fgets(file_get);
			if(file_read == "")
				break;
			if(substring(file_read, 0, 2) == "//")
				continue;
			if(substring(file_read, 0, 1) == "#")
				continue;

			entity e;
			e = ie_ItemPort_Load(file_read, TRUE);
		}
		ie_Debug(strcat("^3ITEMEDITOR - SERVER: ^7successfully loaded storage file ^3", file_name, "\n"));
	}
	fclose(file_get);

	ie_database_loaded = TRUE;
}

void ie_Remove(entity e);
void ie_Database_Unload()
{
	entity head;
	for(head = world; (head = find(head, classname, "itemeditor_item")); )
		ie_Remove(head);
	ie_database_loaded = FALSE;
}

void ie_Think()
{
	self.nextthink = time;

	// decide if and how this item can be grabbed
	if(autocvar_g_itemeditor_readonly)
		self.grab = 0; // no grabbing
	else
		self.grab = 3; // anyone
}

entity ie_SpawnItem(float database)
{
	entity e = spawn();
	e.classname = "itemeditor_item";

	if(!database)
	{
		// set origin and direction based on player position and view angle
		makevectors(self.v_angle);
		WarpZone_TraceLine(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * autocvar_g_itemeditor_spawn_distance, MOVE_NORMAL, self);
		setorigin(e, trace_endpos);
	}

	if(IS_REAL_CLIENT(self)) { print_to(self, "Spawned new item entity"); }

	ie_itemcount += 1;

	return e;
}

void ie_Remove(entity e)
{
	if(e.ie_itemname) { strunzone(e.ie_itemname); e.ie_itemname = string_null; }
	RemoveItem(e);
	e = world;

	ie_itemcount -= 1;
}

float ie_CheckItem(entity e)
{
	if(!e || e.classname != "itemeditor_item") { return FALSE; }
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ie_ClientCommand)
{
	if(cmd_name == "itemeditor")
	{
		if(!ie_enabled || autocvar_g_itemeditor_readonly) { sprint(self, "Item editing is currently disabled\n"); return TRUE; }

		if(argv(1) == "spawn")
		{
			if(!argv(2) || argv(2) == "") { sprint(self, "You must specify an item name\n"); return TRUE; }
			if(ie_itemcount >= autocvar_g_itemeditor_max) { sprint(self, "Too many items!\n"); return TRUE; }
			
			string item_name = strzone(argv(2));
			if(ie_FixItemName(item_name) == "") { sprint(self, "Invalid item\n"); strunzone(item_name); return TRUE; }

			WarpZone_TraceLine(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 100, MOVE_NORMAL, self);
			entity e = ie_SpawnItem(FALSE);
			setorigin(e, trace_endpos);
			e.ie_itemname = item_name;
			ie_SetItemType(e);
			return TRUE;
		}

		if(argv(1) == "remove")
		{
			entity e, theitem = world;
			for(e = WarpZone_FindRadius(self.origin + self.view_ofs + v_forward * 50, 50, FALSE); e; e = e.chain)
				if(e.classname == "itemeditor_item")
				{
					print("Got one\n");
					theitem = e;
					break;
				}
			

			if(ie_CheckItem(theitem))
			{
				ie_Remove(theitem);
				sprint(self, "Successfully removed an item\n");
				return TRUE;
			}
			else
			{
				sprint(self, "Item not found\n");
				return TRUE;
			}
		}
		
		if(argv(1) == "edit")
		{
			if(!argv(2)) { sprint(self, "You must specify a property edit\n"); return TRUE; }
			if(!ie_enabled) { sprint(self, "Editing is not enabled\n"); return TRUE; }

			entity e, theitem = world;
			for(e = WarpZone_FindRadius(self.origin + self.view_ofs + v_forward * 50, 50, FALSE); e; e = e.chain)
			if(e.classname == "itemeditor_item")
			{
				theitem = e;
				break;
			}

			if(ie_CheckItem(theitem))
			if(argv(3))
			switch(argv(2))
			{
				case "cnt": theitem.cnt = stof(argv(3)); return TRUE;
				case "team": theitem.team = stof(argv(3)); return TRUE;
				case "noalign": case "float": theitem.noalign = stof(argv(3)); return TRUE;
				default: print_to(self, "Unknown option"); return TRUE;
			}
		}

		sprint(self, "Command was not handled\n");
		return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ie_ServerCommand)
{
	if(cmd_name == "itemeditor")
	{
		switch(argv(1))
		{
			case "enable":
			case "start":
			{
				if(!ie_database_loaded) { print("Enabling editing while database is unloaded could cause chaos, stopping\n"); return TRUE; }
				ie_enabled = TRUE;
				bprint("Item editing has been enabled!\n");
				return TRUE;
			}
			case "disable":
			case "stop":
			{
				ie_enabled = FALSE;
				bprint("Item editing has been disabled!\n");
				return TRUE;
			}
			case "load":
			{
				if(ie_itemcount > 0 || ie_database_loaded) { print("Item database has already been loaded\n"); return TRUE; }

				ie_Database_Load();
				bprint("Item database has been loaded!\n");
				return TRUE;
			}
			case "unload":
			{
				if(ie_itemcount <= 0 || !ie_database_loaded) { print("Item database has already been unloaded\n"); return TRUE; }

				ie_enabled = FALSE; // we must disable this, so as to not break stuff
				ie_Database_Unload();
				bprint("Item database has been unloaded!\n");
				return TRUE;
			}
			case "removeitems":
			{
				entity head;
				for(head = world; (head = findflags(head, flags, FL_ITEM)); )
				if(head.items || head.weapon)
				if((head.classname != "itemeditor_item" && head.classname != "droppedweapon") || argv(2) == "all")
					RemoveItem(head);

				bprint("Regular items removed!\n");
				return TRUE;
			}
		}
		print("Command was not handled\n");
		return TRUE;
	}
	return FALSE;
}

float ie_autosave_time;
MUTATOR_HOOKFUNCTION(ie_StartFrame)
{
	entity head;
	for(head = world; (head = find(head, classname, "itemeditor_item")); )
		head.grab = (autocvar_g_itemeditor_readonly || !ie_enabled) ? 0 : 3;

	if(!ie_enabled)
		return FALSE;
	if(!ie_database_loaded)
		return FALSE;
	if(!autocvar_g_itemeditor_storage_autosave)
		return FALSE;
	if(time < ie_autosave_time)
		return FALSE;
	ie_autosave_time = time + autocvar_g_itemeditor_storage_autosave;

	ie_Database_Save();

	return TRUE;
}

void ie_DelayedInit()
{
	ie_Database_Load();
}

MUTATOR_DEFINITION(mutator_itemeditor)
{
	MUTATOR_HOOK(SV_ParseClientCommand, ie_ClientCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_ParseServerCommand, ie_ServerCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_StartFrame, ie_StartFrame, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		ie_autosave_time = time + autocvar_g_itemeditor_storage_autosave; // don't save the first server frame
		if(autocvar_g_itemeditor_storage_autoload)
			InitializeEntity(world, ie_DelayedInit, INITPRIO_LAST);
	}

	return FALSE;
}
