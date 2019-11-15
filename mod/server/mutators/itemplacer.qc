#include "itemplacer.qh"

string autocvar_g_itemplacer = "0";
int autocvar_g_itemplacer_info = 0;
bool autocvar_g_itemplacer_readonly = false;
string autocvar_g_itemplacer_storage_name = "default";
float autocvar_g_itemplacer_storage_autosave = 5;
//float autocvar_g_itemplacer_storage_autoexport = 20; // don't do this often, it's heavy!
bool autocvar_g_itemplacer_storage_autoload = true;
bool autocvar_g_itemplacer_storage_autoimport = false;
float autocvar_g_itemplacer_editor_flood = 0.5;
int autocvar_g_itemplacer_editor_maxobjects = 1000;
float autocvar_g_itemplacer_editor_distance_spawn = 200;
float autocvar_g_itemplacer_editor_distance_edit = 300;
bool autocvar_g_itemplacer_waypoint = true;
float autocvar_g_itemplacer_waypoint_distance = 600;
bool autocvar_g_itemplacer_spawnitems = true;

float itemplacer_autosave_time;
void itemplacer_Database_Load();

REGISTER_MUTATOR(itemplacer, expr_evaluate(autocvar_g_itemplacer))
{
	MUTATOR_ONADD
	{
		itemplacer_autosave_time = time + autocvar_g_itemplacer_storage_autosave; // don't save the first server frame
		if(autocvar_g_itemplacer_storage_autoload)
			itemplacer_Database_Load();
	}
}

.bool canplace;
float item_count;
.float item_flood;
.string itemplacer_extrafields;
.entity wps_placeditem;
.entity itemplacer_item;

.float itemplacer_oldsolid;
void crosshair_trace_noitems(entity pl)
{
	IL_EACH(g_items, it.owner.classname == "itemplacer_item",
	{
		it.itemplacer_oldsolid = it.solid;
		it.solid = SOLID_NOT;
	});

	crosshair_trace_plusvisibletriggers__is_wz(pl, false);

	IL_EACH(g_items, it.owner.classname == "itemplacer_item",
	{
		it.solid = it.itemplacer_oldsolid;
		it.itemplacer_oldsolid = 0;
	});
}

STATIC_INIT(itemplacer_hack)
{
	crosshair_trace_plusvisibletriggers = crosshair_trace_noitems;
}

entity itemplacer_ObjectEdit_Get(entity this)
{
	// Returns the traced entity if the player can edit it, and NULL if not.

	crosshair_trace_noitems(this);
	if(vdist(this.origin - trace_ent.origin, >, autocvar_g_itemplacer_editor_distance_edit))
		return NULL; // out of trace range
	if(trace_ent.classname != "itemplacer_object")
		return NULL; // entity is not an object
	return trace_ent;
}

bool itemplacer_ObjectCustomize(entity this, entity client)
{
	return (client.canplace);
}

void delayed_weaponstart(entity this)
{
	weapon_defaultspawnfunc(this, this.itemdef);
}

void delayed_itemstat(entity this)
{
	StartItem(this, this.itemdef);
}

entity itemplacer_SpawnItem(entity itemdata)
{
	entity wp = itemdata.owner;
	string itemname = wp.m_name;
	if(!itemname || itemname == "")
		return NULL;

	if(startsWith(itemname, "weapon_"))
	{
		string thewep = W_UndeprecateName(substring(itemname, 7, strlen(itemname)));
		FOREACH(Weapons, it.netname == thewep || it.m_canonical_spawnfunc == itemname,
		{
			entity newitem = spawn();
			newitem.spawnfunc_checked = true;
			//newitem.classname = itemname;
			setorigin(newitem, wp.origin);
			//newitem.angles = wp.angles;
			newitem.itemdef = it;
			setthink(newitem, delayed_weaponstart);
			newitem.nextthink = time + 0.5;
			return newitem;
		});
		return NULL; // it's a weapon, don't try anything else
	}

	string theitem = substring(itemname, 5, strlen(itemname));
	FOREACH(Items, it.netname == theitem || it.m_canonical_spawnfunc == itemname,
	{
		entity newitem = spawn();
		newitem.spawnfunc_checked = true;
		//newitem.classname = itemname;
		setorigin(newitem, wp.origin);
		//newitem.angles = wp.angles;
		newitem.itemdef = it;
		setthink(newitem, delayed_itemstat);
		newitem.nextthink = time + 0.5;
		return newitem;
	});

	return NULL;
}

void itemplacer_ObjectUpdate(entity this, bool update_name)
{
	if(this.wps_placeditem)
	{
		entity wp = this.wps_placeditem;
		wp.colormod = WPCOLOR_DROPPEDFLAG(this.team);
		wp.SendFlags |= 32;
		wp.model1 = this.m_name;
		wp.SendFlags |= 2;
	}

	this.colormod = WPCOLOR_DROPPEDFLAG(this.team);

	if(this.itemplacer_item && update_name)
	{
		// here's where things get fun... we basically need to destroy the existing item and recreate it
		if(this.itemplacer_item.enemy)
		{
			RemoveItem(this.itemplacer_item.enemy);
			this.itemplacer_item.enemy = NULL;
		}
		entity newitem = itemplacer_SpawnItem(this.itemplacer_item);
		if(newitem)
			newitem.owner = this.itemplacer_item; // so the item can be identified for traces
		this.itemplacer_item.enemy = newitem;
	}
}

void itemplacer_ItemControllerThink(entity this)
{
	// item was removed without telling us
	if(!this.owner || this.owner.itemplacer_item != this)
	{
		if(this.enemy)
			RemoveItem(this.enemy);
		delete(this);
		return;
	}

	this.nextthink = time + 0.33333;

	if(!this.enemy)
		return;

	if(this.origin != this.owner.origin && !this.owner.draggedby)
	{
		// update both our and our target's positions, BUT only when they're no longer dragged!
		setorigin(this, this.owner.origin);
		setorigin(this.enemy, this.owner.origin);
	}
}

entity itemplacer_SpawnItemController(entity item)
{
	// spawn a controller that will position the item and spawn it in when needed
	entity e = new(itemplacer_item);
	e.owner = item;
	setorigin(e, item.origin);
	setthink(e, itemplacer_ItemControllerThink);
	e.nextthink = time + 1;
	return e;
}

entity itemplacer_ObjectSpawn(entity this, float database)
{
	// spawn a new object with default properties

	entity e = new(itemplacer_object);
	IL_PUSH(g_itemplacer_objects, e);
	e.solid = SOLID_TRIGGER; // SOLID_TRIGGER so the player can still grab it
	set_movetype(e, MOVETYPE_NONE);
	e.itemplacer_extrafields = string_null;
	e.colormod = WPCOLOR_DROPPEDFLAG(e.team);
	e.grab = 3;
	e.draggable = itemplacer_ObjectCustomize;
	//e.effects |= EF_SELECTABLE; // don't do this all the time, maybe just when editing objects?

	setmodel(e, MDL_WAYPOINT);
	setsize(e, '-16 -16 -16', '16 16 16');
	e.effects = EF_LOWPRECISION;
	setcefc(e, itemplacer_ObjectCustomize);

	if(autocvar_g_itemplacer_waypoint)
	{
		entity wp = WaypointSprite_Spawn(WP_Waypoint, 0, autocvar_g_itemplacer_waypoint_distance, e, '0 0 32', NULL, 0, e, wps_placeditem, true, RADARICON_NONE);
		wp.colormod = WPCOLOR_DROPPEDFLAG(e.team);
		setcefc(wp, itemplacer_ObjectCustomize);
	}

	if(!database)
	{
		// set public object information
		e.message2 = strzone(strftime(true, "%d-%m-%Y %H:%M:%S")); // last editing time

		// set origin and direction based on player position and view angle
		vector forward, right, up;
		MAKE_VECTORS(this.v_angle, forward, right, up);
		WarpZone_TraceLine(this.origin + this.view_ofs, this.origin + this.view_ofs + forward * autocvar_g_itemplacer_editor_distance_spawn, MOVE_NORMAL, this);
		setorigin(e, trace_endpos);
		e.angles_y = this.v_angle.y;
	}

	if(autocvar_g_itemplacer_spawnitems)
		e.itemplacer_item = itemplacer_SpawnItemController(e);

	item_count += 1;
	return e;
}

void itemplacer_ObjectRemove(entity e)
{
	if(e.itemplacer_item)
	{
		if(e.itemplacer_item.enemy)
			RemoveItem(e.itemplacer_item.enemy);
		delete(e.itemplacer_item);
	}

	WaypointSprite_Kill(e.wps_placeditem);
	strfree(e.itemplacer_extrafields);
	strfree(e.m_name);
	strfree(e.message2);
	delete(e);
	e = NULL;

	object_count -= 1;
}

void itemplacer_ObjectPort_Export(float file_handle, entity e)
{
	float fh = file_handle;
	fputs(fh, "{\n");
	fputs(fh, strcat("\"classname\" \"", e.m_name, "\"\n"));
	fputs(fh, strcat("\"origin\" \"", strcat(ftos(e.origin_x), " ", ftos(e.origin_y), " ", ftos(e.origin_z)), "\"\n"));
	fputs(fh, strcat("\"angles\" \"", strcat(ftos(e.angles_x), " ", ftos(e.angles_y), " ", ftos(e.angles_z)), "\"\n"));
	fputs(fh, strcat("\"team\" \"", ftos(e.team), "\"\n"));
	if(e.itemplacer_extrafields && e.itemplacer_extrafields != "")
	{
		for(string thelist = e.itemplacer_extrafields; thelist != ""; thelist = cdr(thelist))
		{
			string word = car(thelist);
			if(word == "") continue;
			int p = strstrofs(word, "=", 0);
			if(p < 0)
			{
				// invalid field, it has no value!
				continue;
			}
			string item_field = substring(word, 0, p);
			string item_value = substring(word, p + 1, -1);
			//LOG_INFO("Item: '", item_field, "', probability: '", ftos(prob), "'");
			fputs(fh, strcat("\"", item_field, "\" \"", item_value, "\"\n"));
		}
	}
	fputs(fh, "}\n");
}

string itemplacer_ObjectPort_Save(entity e, bool database)
{
	// order doesn't really matter, as we're writing the file fresh
	// ---------------- OBJECT PROPERTY STORAGE: SAVE ----------------
	string port_string = "";
	// properties stored only for parent objects
	if(database)
	{
		port_string = cons(port_string, sprintf("\"%.9v\"", e.origin));
		port_string = cons(port_string, sprintf("\"%.9v\"", e.angles));
	}
	// properties stored for all objects
	port_string = cons(port_string, strcat("\"", e.m_name, "\""));
	port_string = cons(port_string, ftos(e.team));
	if(e.itemplacer_extrafields)
		port_string = cons(port_string, strcat("\"", e.itemplacer_extrafields, "\""));
	else
		port_string = cons(port_string, "\"\""); // none
	if(database)
	{
		// properties stored only for the database
		port_string = cons(port_string, strcat("\"", e.message2, "\""));
	}

	return port_string;
}

entity itemplacer_ObjectPort_Load(entity this, string s, float database)
{
	// load object properties, and spawn a new object with them
	string arg = string_null;

	// now separate and apply the properties of each object
	#define ITEMPLACER_GETARG arg = argv(++argv_num);
	int argv_num = -1; // starts at -1 so I don't need postincrement
	tokenize_console(s);

	entity e = itemplacer_ObjectSpawn(this, database);

	// ---------------- OBJECT PROPERTY STORAGE: LOAD ----------------
	if(database)
	{
		ITEMPLACER_GETARG; setorigin(e, stov(arg));
		ITEMPLACER_GETARG; e.angles = stov(arg);
	}
	// properties stored for all objects
	ITEMPLACER_GETARG; strcpy(e.m_name, arg);
	ITEMPLACER_GETARG; e.team = stof(arg);
	strfree(e.itemplacer_extrafields);
	ITEMPLACER_GETARG; e.itemplacer_extrafields = (arg != "") ? strzone(arg) : string_null;
	if(database)
	{
		// properties stored only for the database
		ITEMPLACER_GETARG; strcpy(e.message2, arg);
	}
	#undef ITEMPLACER_GETARG

	itemplacer_ObjectUpdate(e, true);

	return e;
}

void itemplacer_Database_Export()
{
	// exports the objects for use in map entity files
	string file_name = strcat("itemplacer/exported_", autocvar_g_itemplacer_storage_name, "_", GetMapname(), ".txt");
	float file_get = fopen(file_name, FILE_WRITE);
	if(file_get < 0)
	{
		LOG_INFO("ITEMPLACER: Unable to save export file, this is bad!");
		return;
	}

	IL_EACH(g_itemplacer_objects, true,
	{
		// use a line of text for each object, listing all properties
		itemplacer_ObjectPort_Export(file_get, it);
	});
	fclose(file_get);
}

void itemplacer_Database_Save()
{
	// saves all objects to the database file
	string file_name = strcat("itemplacer/storage_", autocvar_g_itemplacer_storage_name, "_", GetMapname(), ".txt");
	float file_get = fopen(file_name, FILE_WRITE);
	if(file_get < 0)
	{
		LOG_INFO("ITEMPLACER: Unable to save storage file, this is bad!");
		return;
	}
	fputs(file_get, strcat("// itemplacer storage \"", autocvar_g_itemplacer_storage_name, "\" for map \"", GetMapname(), "\" last updated ", strftime(true, "%d-%m-%Y %H:%M:%S")));
	fputs(file_get, strcat(" containing ", ftos(item_count), " objects\n"));

	IL_EACH(g_itemplacer_objects, true,
	{
		// use a line of text for each object, listing all properties
		fputs(file_get, strcat(itemplacer_ObjectPort_Save(it, true), "\n"));
	});
	fclose(file_get);
}

void itemplacer_Database_Load()
{
	// loads all objects from the database file
	string file_read, file_name;
	float file_get, i;

	file_name = strcat("itemplacer/storage_", autocvar_g_itemplacer_storage_name, "_", GetMapname(), ".txt");
	file_get = fopen(file_name, FILE_READ);
	if(file_get < 0)
	{
		if(autocvar_g_itemplacer_info > 0)
			LOG_INFO("^3ITEMPLACER - SERVER: ^7could not find storage file ^3", file_name, "^7, no objects were loaded");
	}
	else
	{
		for (;;)
		{
			file_read = fgets(file_get);
			if(file_read == "")
				break;
			if(substring(file_read, 0, 2) == "//")
				continue;
			if(substring(file_read, 0, 1) == "#")
				continue;

			itemplacer_ObjectPort_Load(NULL, file_read, true);
		}
		if(autocvar_g_itemplacer_info > 0)
			LOG_INFO("^3ITEMPLACER - SERVER: ^7successfully loaded storage file ^3", file_name);
	}
	fclose(file_get);
}

MUTATOR_HOOKFUNCTION(itemplacer, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	entity player = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);
	int cmd_argc = M_ARGV(2, int);

	if(cmd_name == "placeitem")
	{
		if(!player.canplace)
		{
			print_to(player, "You're not allowed to place items!");
			return true;
		}
		if(autocvar_g_itemplacer_readonly)
		{
			print_to(player, "Item placer is active, but in read-only mode. Item placer commands cannot be used");
			return true;
		}
		if(cmd_argc < 2)
		{
			print_to(player, "Item placer is active. For usage information, type 'itemplace help'");
			return true;
		}

		switch(argv(1))
		{
			entity e;
			string s;

			// ---------------- COMMAND: OBJECT, SPAWN ----------------
			case "spawn":
				if(time < player.item_flood)
				{
					print_to(player, strcat("Flood protection active. Please wait ^3", ftos(player.item_flood - time), " ^7seconds beofore spawning another object"));
					return true;
				}
				player.item_flood = time + autocvar_g_itemplacer_editor_flood;
				if(item_count >= autocvar_g_itemplacer_editor_maxobjects)
				{
					print_to(player, strcat("Cannot spawn any more objects. Up to ^3", ftos(autocvar_g_itemplacer_editor_maxobjects), " ^7objects may exist at a time"));
					return true;
				}
				if(cmd_argc < 3)
				{
					print_to(player, "Attempted to spawn an object without specifying a name. Please specify the classname of your object after the 'spawn' command");
					return true;
				}

				e = itemplacer_ObjectSpawn(player, false);
				strfree(e.m_name);
				e.m_name = strzone(argv(2));
				string arg3 = (argv(3) != "") ? argv(3) : "auto";
				int teamnum = Team_ColorToTeam(arg3);
				if(teamnum == -1)
					teamnum = 0;
				e.team = teamnum;
				itemplacer_ObjectUpdate(e, true);

				if(autocvar_g_itemplacer_info > 0)
					LOG_INFO("^3ITEMPLACER - SERVER: ^7", player.netname, " spawned an object at origin ^3", vtos(e.origin));
				return true;

			// ---------------- COMMAND: OBJECT, REMOVE ----------------
			case "remove":
				e = itemplacer_ObjectEdit_Get(player);
				if(e)
				{
					if(autocvar_g_itemplacer_info > 0)
						LOG_INFO("^3ITEMPLACER - SERVER: ^7", player.netname, " removed an object at origin ^3", vtos(e.origin));
					itemplacer_ObjectRemove(e);
					return true;
				}

				print_to(player, "Object could not be removed. Make sure you are facing an object");
				return true;

			// ---------------- COMMAND: OBJECT, DUPLICATE ----------------
			case "duplicate":
				switch(argv(2))
				{
					case "copy":
						// copies customizable properties of the selected object to the clipboard cvar
						e = itemplacer_ObjectEdit_Get(player); // can we copy objects we can't edit?
						if(e)
						{
							s = itemplacer_ObjectPort_Save(e, false);
							s = strreplace("\"", "\\\"", s);
							stuffcmd(player, strcat("set ", argv(3), " \"", s, "\""));

							print_to(player, "Object copied to clipboard");
							return true;
						}
						print_to(player, "Object could not be copied. Make sure you are facing an object that you have copy rights over");
						return true;

					case "paste":
						// spawns a new object using the properties in the player's clipboard cvar
						if(time < player.item_flood)
						{
							print_to(player, strcat("Flood protection active. Please wait ^3", ftos(player.item_flood - time), " ^7seconds beofore spawning another object"));
							return true;
						}
						player.item_flood = time + autocvar_g_itemplacer_editor_flood;
						if(argv(3) == "") // no object in clipboard
						{
							print_to(player, "No object in clipboard. You must copy an object before you can paste it");
							return true;
						}
						if(item_count >= autocvar_g_itemplacer_editor_maxobjects)
						{
							print_to(player, strcat("Cannot spawn any more objects. Up to ^3", ftos(autocvar_g_itemplacer_editor_maxobjects), " ^7objects may exist at a time"));
							return true;
						}
						e = itemplacer_ObjectPort_Load(player, argv(3), false);

						print_to(player, "Object pasted successfully");
						if(autocvar_g_itemplacer_info > 0)
							LOG_INFO("^3ITEMPLACER - SERVER: ^7", player.netname, " pasted an object at origin ^3", vtos(e.origin));
						return true;
				}
				return true;

			// ---------------- COMMAND: OBJECT, EDIT ----------------
			case "edit":
				if(argv(2) == "")
				{
					print_to(player, "Too few parameters. You must specify a property to edit");
					return true;
				}

				e = itemplacer_ObjectEdit_Get(player);
				if(e)
				{
					switch(argv(2))
					{
						case "classname":
						case "name":
						{
							strfree(e.m_name);
							e.m_name = strzone(argv(3));
							itemplacer_ObjectUpdate(e, true);
						}
						case "team":
						{
							string arg3 = (argv(3) != "") ? argv(3) : "auto";
							int teamnum = Team_ColorToTeam(arg3);
							if(teamnum == -1)
								teamnum = 0;
							e.team = teamnum;
							itemplacer_ObjectUpdate(e, false);
							break;
						}
						default:
						{
							string oldlist = strcat1(e.itemplacer_extrafields);
							strfree(e.itemplacer_extrafields);
							e.itemplacer_extrafields = strzone(cons(oldlist, strcat(argv(2), "=", argv(3))));
							break;
						}
					}

					// update last editing time
					strcpy(e.message2, strftime(true, "%d-%m-%Y %H:%M:%S"));

					if(autocvar_g_itemplacer_info > 1)
						LOG_INFO("^3ITEMPLACER - SERVER: ^7", player.netname, " edited property ^3", argv(2), " ^7of an object at origin ^3", vtos(e.origin));
					return true;
				}

				print_to(player, "Object could not be edited. Make sure you are facing an object");
				return true;

			case "addflag":
				if(argv(2) == "" || argv(3) == "")
				{
					print_to(player, "Too few parameters. You must specify a property to add to, and the flag to add to it");
					return true;
				}

				e = itemplacer_ObjectEdit_Get(player);
				if(e)
				{
					string newlist = "";
					string oldlist = strcat1(e.itemplacer_extrafields);
					string arg = argv(2);
					if(strstrofs(oldlist, arg, 0) >= 0)
					{
						for(string thelist = oldlist; thelist != ""; thelist = cdr(thelist))
						{
							string word = car(thelist);
							if(word == "") continue;
							int p = strstrofs(word, "=", 0);
							if(p < 0)
							{
								// invalid field, it has no value!
								// this effectively culls it from the list, a nice side effect!
								continue;
							}
							string item_field = substring(word, 0, p);
							string item_value = substring(word, p + 1, -1);
							//LOG_INFO("Item: '", item_field, "', probability: '", ftos(prob), "'");
							if(item_field == arg)
							{
								int tempflag = stoi(item_value);
								tempflag |= stoi(argv(3));
								item_value = itos(tempflag);
							}
							newlist = cons(newlist, strcat(item_field, "=", item_value));
						}
					}
					else
						newlist = cons(oldlist, strcat(arg, "=", argv(3))); // set it like normal
					strfree(e.itemplacer_extrafields);
					e.itemplacer_extrafields = strzone(newlist);
					return true;
				}

				print_to(player, "Object could not be edited. Make sure you are facing an object");
				return true;

			case "removeflag":
				if(argv(2) == "" || argv(3) == "")
				{
					print_to(player, "Too few parameters. You must specify a property to remove from, and the desired flag");
					return true;
				}

				e = itemplacer_ObjectEdit_Get(player);
				if(e)
				{
					string newlist = "";
					string oldlist = strcat1(e.itemplacer_extrafields);
					string arg = argv(2);
					if(strstrofs(oldlist, arg, 0) >= 0)
					{
						for(string thelist = oldlist; thelist != ""; thelist = cdr(thelist))
						{
							string word = car(thelist);
							if(word == "") continue;
							int p = strstrofs(word, "=", 0);
							if(p < 0)
							{
								// invalid field, it has no value!
								// this effectively culls it from the list, a nice side effect!
								continue;
							}
							string item_field = substring(word, 0, p);
							string item_value = substring(word, p + 1, -1);
							//LOG_INFO("Item: '", item_field, "', probability: '", ftos(prob), "'");
							if(item_field == arg)
							{
								int tempflag = stoi(item_value);
								tempflag &= ~stoi(argv(3));
								item_value = itos(tempflag);
							}
							newlist = cons(newlist, strcat(item_field, "=", item_value));
						}

						strfree(e.itemplacer_extrafields);
						e.itemplacer_extrafields = strzone(newlist);
					}
					// no removal part to this, if the doesn't exist yet, nothing to remove flags from!
					return true;
				}

				print_to(player, "Object could not be edited. Make sure you are facing an object");
				return true;

			case "removefield":
				if(argv(2) == "")
				{
					print_to(player, "Too few parameters. You must specify a property to remove");
					return true;
				}

				e = itemplacer_ObjectEdit_Get(player);
				if(e)
				{
					string newlist = "";
					string oldlist = strcat1(e.itemplacer_extrafields);
					string arg = argv(2);
					FOREACH_WORD(oldlist, !startsWith(it, arg),
					{
						newlist = cons(newlist, it);
					});
					strfree(e.itemplacer_extrafields);
					e.itemplacer_extrafields = strzone(newlist);
					return true;
				}

				print_to(player, "Object could not be edited. Make sure you are facing an object");
				return true;

			case "drop":
				e = itemplacer_ObjectEdit_Get(player);
				if(e)
				{
					droptofloor(e);
					return true;
				}

				print_to(player, "Object could not be edited. Make sure you are facing an object");
				return true;

			// ---------------- COMMAND: OBJECT, INFO ----------------
			case "info":
				// prints public information about the object to the player
				e = itemplacer_ObjectEdit_Get(player);
				if(e)
				{
					print_to(player, strcat("Object is \"", e.m_name, "\", last edited \"^3", e.message2, "^7\""));
					print_to(player, "Object properties:");
					print_to(player, strcat("    origin: ", strcat(ftos(e.origin_x), " ", ftos(e.origin_y), " ", ftos(e.origin_z))));
					print_to(player, strcat("    angles: ", strcat(ftos(e.angles_x), " ", ftos(e.angles_y), " ", ftos(e.angles_z))));
					print_to(player, strcat("    team: ", Team_ColoredFullName(e.team)));
					for(string thelist = e.itemplacer_extrafields; thelist != ""; thelist = cdr(thelist))
					{
						string word = car(thelist);
						if(word == "") continue;
						int p = strstrofs(word, "=", 0);
						if(p < 0)
						{
							// invalid field, it has no value!
							continue;
						}
						string item_field = substring(word, 0, p);
						string item_value = substring(word, p + 1, -1);
						print_to(player, strcat("    ", item_field, ": ", item_value));
					}
					return true;
				}
				print_to(player, "No information could be found. Make sure you are facing an object");
				return true;

			// ---------------- COMMAND: DEFAULT ----------------
			default:
				print_to(player, "Invalid command. For usage information, type 'placeitem help'");
				return true;
		}
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
			LOG_INFO(playername(player, false), " has been granted item placement abilities.");
		}
		else
			LOG_INFO("Invalid player.");
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
			LOG_INFO(playername(player, false), " has been revoked of item placement abilities.");
		}
		else
			LOG_INFO("Invalid player.");
		return true;
	}

	if(cmd_name == "toggle_placeitems")
	{
		entity player = GetFilteredEntity(argv(1));
		int accepted = VerifyClientEntity(player, true, false);
		if(accepted > 0)
		{
			if(player.canplace)
			{
				player.canplace = false;
				print_to(player, "You're no longer allowed to place items.");
				LOG_INFO(playername(player, false), " has been revoked of item placement abilities.");
			}
			else
			{
				player.canplace = true;
				print_to(player, "You're now allowed to place items!");
				LOG_INFO(playername(player, false), " has been granted item placement abilities.");
			}
		}
		else
			LOG_INFO("Invalid player.");
		return true;
	}
}

MUTATOR_HOOKFUNCTION(itemplacer, SV_StartFrame)
{
	if(!autocvar_g_itemplacer_storage_autosave || time < itemplacer_autosave_time)
		return;
	itemplacer_autosave_time = time + autocvar_g_itemplacer_storage_autosave;

	itemplacer_Database_Save();
	itemplacer_Database_Export();

	return true;
}

STATIC_INIT_LATE(itemplacer_importitems)
{
	// TODO: this is unable to tell when an pickup item is placed, so it ends up making duplicates!
	// we can't simply use a global here, since the engine's prespawn function is disabled
	// in the meantime, this will only function when item placer or spawnitems is off
	if(autocvar_g_itemplacer_storage_autoimport && (!autocvar_g_itemplacer_spawnitems || !expr_evaluate(autocvar_g_itemplacer)))
	{
		string filename = strcat("data/itemplacer/exported_", autocvar_g_itemplacer_storage_name, "_", mapname, ".txt");
		if(fexists(filename))
			loadfromfile(filename);
	}
}

STATIC_INIT_LATE(itemplacer_setvars)
{
	localcmd("\nalias allow_placeitems \"sv_cmd allow_placeitems ${* ?}\"\n");
	localcmd("\nalias deny_placeitems \"sv_cmd deny_placeitems ${* ?}\"\n");
	localcmd("\nalias toggle_placeitems \"sv_cmd toggle_placeitems ${* ?}\"\n");
}
