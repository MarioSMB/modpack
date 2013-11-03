const float MAX_STORAGE_ATTACHMENTS = 16;
float object_count;
.float object_flood;
.entity object_attach;
.string material;

.float touch_timer;
void sandbox_ObjectFunction_Touch()
{
	// apply material impact effects

	if(!self.material)
		return;
	if(self.touch_timer > time)
		return; // don't execute each frame
	self.touch_timer = time + 0.1;

	// make particle count and sound volume depend on impact speed
	float intensity;
	intensity = vlen(self.velocity) + vlen(other.velocity);
	if(intensity) // avoid divisions by 0
		intensity /= 2; // average the two velocities
	if (!(intensity >= autocvar_g_sandbox_object_material_velocity_min))
		return; // impact not strong enough to do anything
	// now offset intensity and apply it to the effects
	intensity -= autocvar_g_sandbox_object_material_velocity_min; // start from minimum velocity, not actual velocity
	intensity = bound(0, intensity * autocvar_g_sandbox_object_material_velocity_factor, 1);

	sound(self, CH_TRIGGER, strcat("object/impact_", self.material, "_", ftos(ceil(random() * 5)) , ".wav"), VOL_BASE * intensity, ATTEN_NORM);
	pointparticles(particleeffectnum(strcat("impact_", self.material)), self.origin, '0 0 0', ceil(intensity * 10)); // allow a count from 1 to 10
}

void sandbox_ObjectFunction_Think()
{
	entity e;

	// decide if and how this object can be grabbed
	if(autocvar_g_sandbox_readonly)
		self.grab = 0; // no grabbing
	else if(autocvar_g_sandbox_editor_free < 2 && self.crypto_idfp)
		self.grab = 1; // owner only
	else
		self.grab = 3; // anyone

	// Object owner is stored via player UID, but we also need the owner as an entity (if the player is available on the server).
	// Therefore, scan for all players, and update the owner as long as the player is present. We must always do this,
	// since if the owning player disconnects, the object's owner should also be reset.
	FOR_EACH_REALPLAYER(e) // bots can't have objects
	{
		if(self.crypto_idfp == e.crypto_idfp)
		{
			self.realowner = e;
			break;
		}
		self.realowner = world;
	}

	self.nextthink = time;
	
	CSQCMODEL_AUTOUPDATE();
}

.float old_solid, old_movetype;
entity sandbox_ObjectEdit_Get(float permissions)
{
	// Returns the traced entity if the player can edit it, and world if not.
	// If permissions if FALSE, the object is returned regardless of editing rights.
	// Attached objects are SOLID_NOT and do not get traced.

	crosshair_trace_plusvisibletriggers(self);
	if(vlen(self.origin - trace_ent.origin) > autocvar_g_sandbox_editor_distance_edit)
		return world; // out of trace range
	if(trace_ent.classname != "object")
		return world; // entity is not an object
	if(!permissions)
		return trace_ent; // don't check permissions, anyone can edit this object
	if(trace_ent.crypto_idfp == "")
		return trace_ent; // the player who spawned this object did not have an UID, so anyone can edit it
	if (!(trace_ent.realowner != self && autocvar_g_sandbox_editor_free < 2))
		return trace_ent; // object does not belong to the player, and players can only edit their own objects on this server
	return world;
}

void sandbox_ObjectEdit_Scale(entity e, float f)
{
	e.scale = f;
	if(e.scale)
	{
		e.scale = bound(autocvar_g_sandbox_object_scale_min, e.scale, autocvar_g_sandbox_object_scale_max);
		setmodel(e, e.model); // reset mins and maxs based on mesh
		setsize(e, e.mins * e.scale, e.maxs * e.scale); // adapt bounding box size to model size
	}
}

void sandbox_ObjectAttach_Remove(entity e);
void sandbox_ObjectAttach_Set(entity e, entity parent, string s)
{
	// attaches e to parent on string s

	// we can't attach to an attachment, for obvious reasons
	sandbox_ObjectAttach_Remove(e);

	e.old_solid = e.solid; // persist solidity
	e.old_movetype = e.movetype; // persist physics
	e.movetype = MOVETYPE_FOLLOW;
	e.solid = SOLID_NOT;
	e.takedamage = DAMAGE_NO;

	setattachment(e, parent, s);
	e.owner = parent;
}

void sandbox_ObjectAttach_Remove(entity e)
{
	// detaches any object attached to e

	entity head;
	for(head = world; (head = find(head, classname, "object")); )
	{
		if(head.owner == e)
		{
			vector org;
			org = gettaginfo(head, 0);
			setattachment(head, world, "");
			head.owner = world;

			// objects change origin and angles when detached, so apply previous position
			setorigin(head, org);
			head.angles = e.angles; // don't allow detached objects to spin or roll

			head.solid = head.old_solid; // restore persisted solidity
			head.movetype = head.old_movetype; // restore persisted physics
			head.takedamage = DAMAGE_AIM;
		}
	}
}

entity sandbox_ObjectSpawn(float database)
{
	// spawn a new object with default properties

	entity e, oldself;
	e = spawn();
	e.classname = "object";
	e.takedamage = DAMAGE_AIM;
	e.damageforcescale = 1;
	e.solid = SOLID_BBOX; // SOLID_BSP would be best, but can lag the server badly
	e.movetype = MOVETYPE_TOSS;
	e.frame = 0;
	e.skin = 0;
	e.material = string_null;
	e.touch = sandbox_ObjectFunction_Touch;
	e.think = sandbox_ObjectFunction_Think;
	e.nextthink = time;
	//e.effects |= EF_SELECTABLE; // don't do this all the time, maybe just when editing objects?

	if(!database)
	{
		// set the object's owner via player UID
		// if the player does not have an UID, the owner cannot be stored and his objects may be edited by anyone
		if(self.crypto_idfp != "")
			e.crypto_idfp = strzone(self.crypto_idfp);
		else
			print_to(self, "^1SANDBOX - WARNING: ^7You spawned an object, but lack a player UID. ^1Your objects are not secured and can be edited by any player!");

		// set public object information
		e.netname = strzone(self.netname); // name of the owner
		e.message = strzone(strftime(TRUE, "%d-%m-%Y %H:%M:%S")); // creation time
		e.message2 = strzone(strftime(TRUE, "%d-%m-%Y %H:%M:%S")); // last editing time

		// set origin and direction based on player position and view angle
		makevectors(self.v_angle);
		WarpZone_TraceLine(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * autocvar_g_sandbox_editor_distance_spawn, MOVE_NORMAL, self);
		setorigin(e, trace_endpos);
		e.angles_y = self.v_angle_y;
	}
	
	oldself = self;
	self = e;
	CSQCMODEL_AUTOINIT();
	self = oldself;

	object_count += 1;
	return e;
}

void sandbox_ObjectRemove(entity e)
{
	sandbox_ObjectAttach_Remove(e); // detach child objects

	// if the object being removed has been selected for attachment by a player, unset it
	entity head;
	FOR_EACH_REALPLAYER(head) // bots can't have objects
	{
		if(head.object_attach == e)
			head.object_attach = world;
	}

	if(e.material)	{	strunzone(e.material);	e.material = string_null;	}
	if(e.crypto_idfp)	{	strunzone(e.crypto_idfp);	e.crypto_idfp = string_null;	}
	if(e.netname)	{	strunzone(e.netname);	e.netname = string_null;	}
	if(e.message)	{	strunzone(e.message);	e.message = string_null;	}
	if(e.message2)	{	strunzone(e.message2);	e.message2 = string_null;	}
	remove(e);
	e = world;

	object_count -= 1;
}

string port_string[MAX_STORAGE_ATTACHMENTS]; // fteqcc crashes if this isn't defined as a global

string sandbox_ObjectPort_Save(entity e, float database)
{
	// save object properties, and return them as a string
	float i = 0;
	string s;
	entity head;

	for(head = world; (head = find(head, classname, "object")); )
	{
		// the main object needs to be first in the array [0] with attached objects following
		float slot, physics, solidity;
		if(head == e) // this is the main object, place it first
		{
			slot = 0;
			solidity = head.solid; // applied solidity is normal solidity for children
			physics = head.movetype; // applied physics are normal physics for parents
		}
		else if(head.owner == e) // child object, list them in order
		{
			i += 1; // children start from 1
			slot = i;
			solidity = head.old_solid; // persisted solidity is normal solidity for children
			physics = head.old_movetype; // persisted physics are normal physics for children
			gettaginfo(head.owner, head.tag_index); // get the name of the tag our object is attached to, used further below
		}
		else
			continue;

		// ---------------- OBJECT PROPERTY STORAGE: SAVE ----------------
		if(slot)
		{
			// properties stored only for child objects
			if(gettaginfo_name)	port_string[slot] = strcat(port_string[slot], "\"", gettaginfo_name, "\" ");	else	port_string[slot] = strcat(port_string[slot], "\"\" "); // none
		}
		else
		{
			// properties stored only for parent objects
			if(database)
			{
				port_string[slot] = strcat(port_string[slot], sprintf("\"%.9v\"", head.origin), " ");
				port_string[slot] = strcat(port_string[slot], sprintf("\"%.9v\"", head.angles), " ");
			}
		}
		// properties stored for all objects
		port_string[slot] = strcat(port_string[slot], "\"", head.model, "\" ");
		port_string[slot] = strcat(port_string[slot], ftos(head.skin), " ");
		port_string[slot] = strcat(port_string[slot], ftos(head.alpha), " ");
		port_string[slot] = strcat(port_string[slot], sprintf("\"%.9v\"", head.colormod), " ");
		port_string[slot] = strcat(port_string[slot], sprintf("\"%.9v\"", head.glowmod), " ");
		port_string[slot] = strcat(port_string[slot], ftos(head.frame), " ");
		port_string[slot] = strcat(port_string[slot], ftos(head.scale), " ");
		port_string[slot] = strcat(port_string[slot], ftos(solidity), " ");
		port_string[slot] = strcat(port_string[slot], ftos(physics), " ");
		port_string[slot] = strcat(port_string[slot], ftos(head.damageforcescale), " ");
		if(head.material)	port_string[slot] = strcat(port_string[slot], "\"", head.material, "\" ");	else	port_string[slot] = strcat(port_string[slot], "\"\" "); // none
		if(database)
		{
			// properties stored only for the database
			if(head.crypto_idfp)	port_string[slot] = strcat(port_string[slot], "\"", head.crypto_idfp, "\" ");	else	port_string[slot] = strcat(port_string[slot], "\"\" "); // none
			port_string[slot] = strcat(port_string[slot], "\"", e.netname, "\" ");
			port_string[slot] = strcat(port_string[slot], "\"", e.message, "\" ");
			port_string[slot] = strcat(port_string[slot], "\"", e.message2, "\" ");
		}
	}

	// now apply the array to a simple string, with the ; symbol separating objects
	s = "";
	for(i = 0; i <= MAX_STORAGE_ATTACHMENTS; ++i)
	{
		if(port_string[i])
			s = strcat(s, port_string[i], "; ");
		port_string[i] = string_null; // fully clear the string
	}

	return s;
}

entity sandbox_ObjectPort_Load(string s, float database)
{
	// load object properties, and spawn a new object with them
	float n, i;
	entity e = world, parent = world;

	// separate objects between the ; symbols
	n = tokenizebyseparator(s, "; ");
	for(i = 0; i < n; ++i)
		port_string[i] = argv(i);

	// now separate and apply the properties of each object
	for(i = 0; i < n; ++i)
	{
		float argv_num;
		string tagname = string_null;
		argv_num = 0;
		tokenize_console(port_string[i]);
		e = sandbox_ObjectSpawn(database);

		// ---------------- OBJECT PROPERTY STORAGE: LOAD ----------------
		if(i)
		{
			// properties stored only for child objects
			if(argv(argv_num) != "")	tagname = argv(argv_num);	else tagname = string_null;	++argv_num;
		}
		else
		{
			// properties stored only for parent objects
			if(database)
			{
				setorigin(e, stov(argv(argv_num)));	++argv_num;
				e.angles = stov(argv(argv_num));	++argv_num;
			}
			parent = e; // mark parent objects as such
		}
		// properties stored for all objects
		setmodel(e, argv(argv_num));	++argv_num;
		e.skin = stof(argv(argv_num));	++argv_num;
		e.alpha = stof(argv(argv_num));	++argv_num;
		e.colormod = stov(argv(argv_num));	++argv_num;
		e.glowmod = stov(argv(argv_num));	++argv_num;
		e.frame = stof(argv(argv_num));	++argv_num;
		sandbox_ObjectEdit_Scale(e, stof(argv(argv_num)));	++argv_num;
		e.solid = e.old_solid = stof(argv(argv_num));	++argv_num;
		e.movetype = e.old_movetype = stof(argv(argv_num));	++argv_num;
		e.damageforcescale = stof(argv(argv_num));	++argv_num;
		if(e.material)	strunzone(e.material);	if(argv(argv_num) != "")	e.material = strzone(argv(argv_num));	else	e.material = string_null;	++argv_num;
		if(database)
		{
			// properties stored only for the database
			if(e.crypto_idfp)	strunzone(e.crypto_idfp);	if(argv(argv_num) != "")	e.crypto_idfp = strzone(argv(argv_num));	else	e.crypto_idfp = string_null;	++argv_num;
			if(e.netname)	strunzone(e.netname);	e.netname = strzone(argv(argv_num));	++argv_num;
			if(e.message)	strunzone(e.message);	e.message = strzone(argv(argv_num));	++argv_num;
			if(e.message2)	strunzone(e.message2);	e.message2 = strzone(argv(argv_num));	++argv_num;
		}

		// attach last
		if(i)
			sandbox_ObjectAttach_Set(e, parent, tagname);
	}

	for(i = 0; i <= MAX_STORAGE_ATTACHMENTS; ++i)
		port_string[i] = string_null; // fully clear the string

	return e;
}

void sandbox_Database_Save()
{
	// saves all objects to the database file
	entity head;
	string file_name;
	float file_get;

	file_name = strcat("sandbox/storage_", autocvar_g_sandbox_storage_name, "_", GetMapname(), ".txt");
	file_get = fopen(file_name, FILE_WRITE);
	fputs(file_get, strcat("// sandbox storage \"", autocvar_g_sandbox_storage_name, "\" for map \"", GetMapname(), "\" last updated ", strftime(TRUE, "%d-%m-%Y %H:%M:%S")));
	fputs(file_get, strcat(" containing ", ftos(object_count), " objects\n"));

	for(head = world; (head = find(head, classname, "object")); )
	{
		// attached objects are persisted separately, ignore them here
		if(head.owner != world)
			continue;

		// use a line of text for each object, listing all properties
		fputs(file_get, strcat(sandbox_ObjectPort_Save(head, TRUE), "\n"));
	}
	fclose(file_get);
}

void sandbox_Database_Load()
{
	// loads all objects from the database file
	string file_read, file_name;
	float file_get, i;

	file_name = strcat("sandbox/storage_", autocvar_g_sandbox_storage_name, "_", GetMapname(), ".txt");
	file_get = fopen(file_name, FILE_READ);
	if(file_get < 0)
	{
		if(autocvar_g_sandbox_info > 0)
			print(strcat("^3SANDBOX - SERVER: ^7could not find storage file ^3", file_name, "^7, no objects were loaded\n"));
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
			e = sandbox_ObjectPort_Load(file_read, TRUE);

			if(e.material)
			{
				// since objects are being loaded for the first time, precache material sounds for each
				for (i = 1; i <= 5; i++) // 5 sounds in total
					precache_sound(strcat("object/impact_", e.material, "_", ftos(i), ".wav"));
			}
		}
		if(autocvar_g_sandbox_info > 0)
			print(strcat("^3SANDBOX - SERVER: ^7successfully loaded storage file ^3", file_name, "\n"));
	}
	fclose(file_get);
}

MUTATOR_HOOKFUNCTION(sandbox_PlayerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return FALSE;
	if(cmd_name == "g_sandbox")
	{
		if(autocvar_g_sandbox_readonly)
		{
			print_to(self, "^2SANDBOX - INFO: ^7Sandbox mode is active, but in read-only mode. Sandbox commands cannot be used");
			return TRUE;
		}
		if(cmd_argc < 2)
		{
			print_to(self, "^2SANDBOX - INFO: ^7Sandbox mode is active. For usage information, type 'sandbox help'");
			return TRUE;
		}

		switch(argv(1))
		{
			entity e;
			float i;
			string s;

			// ---------------- COMMAND: HELP ----------------
			case "help":
				print_to(self, "You can use the following sandbox commands:");
				print_to(self, "^7\"^2object_spawn ^3models/foo/bar.md3^7\" spawns a new object in front of the player, and gives it the specified model");
				print_to(self, "^7\"^2object_remove^7\" removes the object the player is looking at. Players can only remove their own objects");
				print_to(self, "^7\"^2object_duplicate ^3value^7\" duplicates the object, if the player has copying rights over the original");
				print_to(self, "^3copy value ^7- copies the properties of the object to the specified client cvar");
				print_to(self, "^3paste value ^7- spawns an object with the given properties. Properties or cvars must be specified as follows; eg1: \"0 1 2 ...\", eg2: \"$cl_cvar\"");
				print_to(self, "^7\"^2object_attach ^3property value^7\" attaches one object to another. Players can only attach their own objects");
				print_to(self, "^3get ^7- selects the object you are facing as the object to be attached");
				print_to(self, "^3set value ^7- attaches the previously selected object to the object you are facing, on the specified bone");
				print_to(self, "^3remove ^7- detaches all objects from the object you are facing");
				print_to(self, "^7\"^2object_edit ^3property value^7\" edits the given property of the object. Players can only edit their own objects");
				print_to(self, "^3skin value ^7- changes the skin of the object");
				print_to(self, "^3alpha value ^7- sets object transparency");
				print_to(self, "^3colormod \"value_x value_y value_z\" ^7- main object color");
				print_to(self, "^3glowmod \"value_x value_y value_z\" ^7- glow object color");
				print_to(self, "^3frame value ^7- object animation frame, for self-animated models");
				print_to(self, "^3scale value ^7- changes object scale. 0.5 is half size and 2 is double size");
				print_to(self, "^3solidity value ^7- object collisions, 0 = non-solid, 1 = solid");
				print_to(self, "^3physics value ^7- object physics, 0 = static, 1 = movable, 2 = physical");
				print_to(self, "^3force value ^7- amount of force applied to objects that are shot");
				print_to(self, "^3material value ^7- sets the material of the object. Default materials are: metal, stone, wood, flesh");
				print_to(self, "^7\"^2object_claim^7\" sets the player as the owner of the object, if he has the right to edit it");
				print_to(self, "^7\"^2object_info ^3value^7\" shows public information about the object");
				print_to(self, "^3object ^7- prints general information about the object, such as owner and creation / editing date");
				print_to(self, "^3mesh ^7- prints information about the object's mesh, including skeletal bones");
				print_to(self, "^3attachments ^7- prints information about the object's attachments");
				print_to(self, "^7The ^1drag object ^7key can be used to grab and carry objects. Players can only grab their own objects");
				return TRUE;

			// ---------------- COMMAND: OBJECT, SPAWN ----------------
			case "object_spawn":
				if(time < self.object_flood)
				{
					print_to(self, strcat("^1SANDBOX - WARNING: ^7Flood protection active. Please wait ^3", ftos(self.object_flood - time), " ^7seconds beofore spawning another object"));
					return TRUE;
				}
				self.object_flood = time + autocvar_g_sandbox_editor_flood;
				if(object_count >= autocvar_g_sandbox_editor_maxobjects)
				{
					print_to(self, strcat("^1SANDBOX - WARNING: ^7Cannot spawn any more objects. Up to ^3", ftos(autocvar_g_sandbox_editor_maxobjects), " ^7objects may exist at a time"));
					return TRUE;
				}
				if(cmd_argc < 3)
				{
					print_to(self, "^1SANDBOX - WARNING: ^7Attempted to spawn an object without specifying a model. Please specify the path to your model file after the 'object_spawn' command");
					return TRUE;
				}
				if (!(fexists(argv(2))))
				{
					print_to(self, "^1SANDBOX - WARNING: ^7Attempted to spawn an object with a non-existent model. Make sure the path to your model file is correct");
					return TRUE;
				}

				e = sandbox_ObjectSpawn(FALSE);
				setmodel(e, argv(2));

				if(autocvar_g_sandbox_info > 0)
					print(strcat("^3SANDBOX - SERVER: ^7", self.netname, " spawned an object at origin ^3", vtos(e.origin), "\n"));
				return TRUE;

			// ---------------- COMMAND: OBJECT, REMOVE ----------------
			case "object_remove":
				e = sandbox_ObjectEdit_Get(TRUE);
				if(e != world)
				{
					if(autocvar_g_sandbox_info > 0)
						print(strcat("^3SANDBOX - SERVER: ^7", self.netname, " removed an object at origin ^3", vtos(e.origin), "\n"));
					sandbox_ObjectRemove(e);
					return TRUE;
				}

				print_to(self, "^1SANDBOX - WARNING: ^7Object could not be removed. Make sure you are facing an object that you have edit rights over");
				return TRUE;

			// ---------------- COMMAND: OBJECT, DUPLICATE ----------------
			case "object_duplicate":
				switch(argv(2))
				{
					case "copy":
						// copies customizable properties of the selected object to the clipboard cvar
						e = sandbox_ObjectEdit_Get(autocvar_g_sandbox_editor_free); // can we copy objects we can't edit?
						if(e != world)
						{
							s = sandbox_ObjectPort_Save(e, FALSE);
							s = strreplace("\"", "\\\"", s);
							stuffcmd(self, strcat("set ", argv(3), " \"", s, "\""));

							print_to(self, "^2SANDBOX - INFO: ^7Object copied to clipboard");
							return TRUE;
						}
						print_to(self, "^1SANDBOX - WARNING: ^7Object could not be copied. Make sure you are facing an object that you have copy rights over");
						return TRUE;

					case "paste":
						// spawns a new object using the properties in the player's clipboard cvar
						if(time < self.object_flood)
						{
							print_to(self, strcat("^1SANDBOX - WARNING: ^7Flood protection active. Please wait ^3", ftos(self.object_flood - time), " ^7seconds beofore spawning another object"));
							return TRUE;
						}
						self.object_flood = time + autocvar_g_sandbox_editor_flood;
						if(argv(3) == "") // no object in clipboard
						{
							print_to(self, "^1SANDBOX - WARNING: ^7No object in clipboard. You must copy an object before you can paste it");
							return TRUE;
						}
						if(object_count >= autocvar_g_sandbox_editor_maxobjects)
						{
							print_to(self, strcat("^1SANDBOX - WARNING: ^7Cannot spawn any more objects. Up to ^3", ftos(autocvar_g_sandbox_editor_maxobjects), " ^7objects may exist at a time"));
							return TRUE;
						}
						e = sandbox_ObjectPort_Load(argv(3), FALSE);

						print_to(self, "^2SANDBOX - INFO: ^7Object pasted successfully");
						if(autocvar_g_sandbox_info > 0)
							print(strcat("^3SANDBOX - SERVER: ^7", self.netname, " pasted an object at origin ^3", vtos(e.origin), "\n"));
						return TRUE;
				}
				return TRUE;

			// ---------------- COMMAND: OBJECT, ATTACH ----------------
			case "object_attach":
				switch(argv(2))
				{
					case "get":
						// select e as the object as meant to be attached
						e = sandbox_ObjectEdit_Get(TRUE);
						if(e != world)
						{
							self.object_attach = e;
							print_to(self, "^2SANDBOX - INFO: ^7Object selected for attachment");
							return TRUE;
						}
						print_to(self, "^1SANDBOX - WARNING: ^7Object could not be selected for attachment. Make sure you are facing an object that you have edit rights over");
						return TRUE;
					case "set":
						if(self.object_attach == world)
						{
							print_to(self, "^1SANDBOX - WARNING: ^7No object selected for attachment. Please select an object to be attached first.");
							return TRUE;
						}

						// attaches the previously selected object to e
						e = sandbox_ObjectEdit_Get(TRUE);
						if(e != world)
						{
							sandbox_ObjectAttach_Set(self.object_attach, e, argv(3));
							self.object_attach = world; // object was attached, no longer keep it scheduled for attachment
							print_to(self, "^2SANDBOX - INFO: ^7Object attached successfully");
							if(autocvar_g_sandbox_info > 1)
								print(strcat("^3SANDBOX - SERVER: ^7", self.netname, " attached objects at origin ^3", vtos(e.origin), "\n"));
							return TRUE;
						}
						print_to(self, "^1SANDBOX - WARNING: ^7Object could not be attached to the parent. Make sure you are facing an object that you have edit rights over");
						return TRUE;
					case "remove":
						// removes e if it was attached
						e = sandbox_ObjectEdit_Get(TRUE);
						if(e != world)
						{
							sandbox_ObjectAttach_Remove(e);
							print_to(self, "^2SANDBOX - INFO: ^7Child objects detached successfully");
							if(autocvar_g_sandbox_info > 1)
								print(strcat("^3SANDBOX - SERVER: ^7", self.netname, " detached objects at origin ^3", vtos(e.origin), "\n"));
							return TRUE;
						}
						print_to(self, "^1SANDBOX - WARNING: ^7Child objects could not be detached. Make sure you are facing an object that you have edit rights over");
						return TRUE;
				}
				return TRUE;

			// ---------------- COMMAND: OBJECT, EDIT ----------------
			case "object_edit":
				if(argv(2) == "")
				{
					print_to(self, "^1SANDBOX - WARNING: ^7Too few parameters. You must specify a property to edit");
					return TRUE;
				}

				e = sandbox_ObjectEdit_Get(TRUE);
				if(e != world)
				{
					switch(argv(2))
					{
						case "skin":
							e.skin = stof(argv(3));
							break;
						case "alpha":
							e.alpha = stof(argv(3));
							break;
						case "color_main":
							e.colormod = stov(argv(3));
							break;
						case "color_glow":
							e.glowmod = stov(argv(3));
							break;
						case "frame":
							e.frame = stof(argv(3));
							break;
						case "scale":
							sandbox_ObjectEdit_Scale(e, stof(argv(3)));
							break;
						case "solidity":
							switch(argv(3))
							{
								case "0": // non-solid
									e.solid = SOLID_TRIGGER;
									break;
								case "1": // solid
									e.solid = SOLID_BBOX;
									break;
								default:
									break;
							}
						case "physics":
							switch(argv(3))
							{
								case "0": // static
									e.movetype = MOVETYPE_NONE;
									break;
								case "1": // movable
									e.movetype = MOVETYPE_TOSS;
									break;
								case "2": // physical
									e.movetype = MOVETYPE_PHYSICS;
									break;
								default:
									break;
							}
							break;
						case "force":
							e.damageforcescale = stof(argv(3));
							break;
						case "material":
							if(e.material)	strunzone(e.material);
							if(argv(3))
							{
								for (i = 1; i <= 5; i++) // precache material sounds, 5 in total
									precache_sound(strcat("object/impact_", argv(3), "_", ftos(i), ".wav"));
								e.material = strzone(argv(3));
							}
							else
								e.material = string_null; // no material
							break;
						default:
							print_to(self, "^1SANDBOX - WARNING: ^7Invalid object property. For usage information, type 'sandbox help'");
							return TRUE;
					}

					// update last editing time
					if(e.message2)	strunzone(e.message2);
					e.message2 = strzone(strftime(TRUE, "%d-%m-%Y %H:%M:%S"));

					if(autocvar_g_sandbox_info > 1)
						print(strcat("^3SANDBOX - SERVER: ^7", self.netname, " edited property ^3", argv(2), " ^7of an object at origin ^3", vtos(e.origin), "\n"));
					return TRUE;
				}

				print_to(self, "^1SANDBOX - WARNING: ^7Object could not be edited. Make sure you are facing an object that you have edit rights over");
				return TRUE;

			// ---------------- COMMAND: OBJECT, CLAIM ----------------
			case "object_claim":
				// if the player can edit an object but is not its owner, this can be used to claim that object
				if(self.crypto_idfp == "")
				{
					print_to(self, "^1SANDBOX - WARNING: ^7You do not have a player UID, and cannot claim objects");
					return TRUE;
				}
				e = sandbox_ObjectEdit_Get(TRUE);
				if(e != world)
				{
					// update the owner's name
					// Do this before checking if you're already the owner and skipping if such, so we
					// also update the player's nickname if he changed it (but has the same player UID)
					if(e.netname != self.netname)
					{
						if(e.netname)	strunzone(e.netname);
						e.netname = strzone(self.netname);
						print_to(self, "^2SANDBOX - INFO: ^7Object owner name updated");
					}

					if(e.crypto_idfp == self.crypto_idfp)
					{
						print_to(self, "^2SANDBOX - INFO: ^7Object is already yours, nothing to claim");
						return TRUE;
					}

					if(e.crypto_idfp)	strunzone(e.crypto_idfp);
					e.crypto_idfp = strzone(self.crypto_idfp);

					print_to(self, "^2SANDBOX - INFO: ^7Object claimed successfully");
				}
				print_to(self, "^1SANDBOX - WARNING: ^7Object could not be claimed. Make sure you are facing an object that you have edit rights over");
				return TRUE;

			// ---------------- COMMAND: OBJECT, INFO ----------------
			case "object_info":
				// prints public information about the object to the player
				e = sandbox_ObjectEdit_Get(FALSE);
				if(e != world)
				{
					switch(argv(2))
					{
						case "object":
							print_to(self, strcat("^2SANDBOX - INFO: ^7Object is owned by \"^7", e.netname, "^7\", created \"^3", e.message, "^7\", last edited \"^3", e.message2, "^7\""));
							return TRUE;
						case "mesh":
							s = "";
							FOR_EACH_TAG(e)
								s = strcat(s, "^7\"^5", gettaginfo_name, "^7\", ");
							print_to(self, strcat("^2SANDBOX - INFO: ^7Object mesh is \"^3", e.model, "^7\" at animation frame ^3", ftos(e.frame), " ^7containing the following tags: ", s));
							return TRUE;
						case "attachments":
							// this should show the same info as 'mesh' but for attachments
							s = "";
							entity head;
							i = 0;
							for(head = world; (head = find(head, classname, "object")); )
							{
								if(head.owner == e)
								{
									++i; // start from 1
									gettaginfo(e, head.tag_index);
									s = strcat(s, "^1attachment ", ftos(i), "^7 has mesh \"^3", head.model, "^7\" at animation frame ^3", ftos(head.frame));
									s = strcat(s, "^7 and is attached to bone \"^5", gettaginfo_name, "^7\", ");
								}
							}
							if(i) // object contains attachments
								print_to(self, strcat("^2SANDBOX - INFO: ^7Object contains the following ^1", ftos(i), "^7 attachment(s): ", s));
							else
								print_to(self, "^2SANDBOX - INFO: ^7Object contains no attachments");
							return TRUE;
					}
				}
				print_to(self, "^1SANDBOX - WARNING: ^7No information could be found. Make sure you are facing an object");
				return TRUE;

			// ---------------- COMMAND: DEFAULT ----------------
			default:
				print_to(self, "Invalid command. For usage information, type 'sandbox help'");
				return TRUE;
		}
	}
	return FALSE;
}

float autosave_time;
MUTATOR_HOOKFUNCTION(sandbox_StartFrame)
{
	if(!autocvar_g_sandbox_storage_autosave)
		return FALSE;
	if(time < autosave_time)
		return FALSE;
	autosave_time = time + autocvar_g_sandbox_storage_autosave;

	sandbox_Database_Save();

	return TRUE;
}

MUTATOR_HOOKFUNCTION(sandbox_SetModname)
{
	modname = "Sandbox";
	return TRUE;
}

MUTATOR_DEFINITION(sandbox)
{
	MUTATOR_HOOK(SV_ParseClientCommand, sandbox_PlayerCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_StartFrame, sandbox_StartFrame, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, sandbox_SetModname, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		autosave_time = time + autocvar_g_sandbox_storage_autosave; // don't save the first server frame
		if(autocvar_g_sandbox_storage_autoload)
			sandbox_Database_Load();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// nothing to roll back
	}

	MUTATOR_ONREMOVE
	{
		// nothing to remove
	}

	return FALSE;
}

