.float el_editmode;
float el_lightcount;

.float cvar_cl_editlights;

string el_port_string;

vector rintvec(vector vec)
{
	vector rinted;
	rinted_x = rint(vec_x);
	rinted_y = rint(vec_y);
	rinted_z = rint(vec_z);
	return rinted;
}

entity el_SpawnLight(float database);

float el_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_EDITLIGHT);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		WriteCoord(MSG_ENTITY, self.colormod_x);
		WriteCoord(MSG_ENTITY, self.colormod_y);
		WriteCoord(MSG_ENTITY, self.colormod_z);

		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteShort(MSG_ENTITY, self.cnt);
	}

	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}

	if(sf & 4)
	{
		WriteCoord(MSG_ENTITY, self.colormod_x);
		WriteCoord(MSG_ENTITY, self.colormod_y);
		WriteCoord(MSG_ENTITY, self.colormod_z);
	}

	if(sf & 8)
	{
		WriteShort(MSG_ENTITY, self.cnt);
	}

	return TRUE;
}

string el_LightPort_Save(entity e, float database)
{
	// save light properties, and return them as a string
	string s;
	entity head = e;

	if(head)
	{
		// ---------------- LIGHT PROPERTY STORAGE: SAVE ----------------
		// properties stored only for parent lights
		if(database) { el_port_string = strcat(el_port_string, sprintf("\"%.9v\"", rintvec(head.origin)), " "); }
		// properties stored for all lights
		el_port_string = strcat(el_port_string, sprintf("\"%.9v\"", head.colormod), " ");
		el_port_string = strcat(el_port_string, sprintf("\"%.9f\"", rint(head.cnt)), " ");
		if(database)
		{
			// properties stored only for the database
			if(head.crypto_idfp)	el_port_string = strcat(el_port_string, "\"", head.crypto_idfp, "\" ");	else	el_port_string = strcat(el_port_string, "\"\" "); // none
			el_port_string = strcat(el_port_string, "\"", e.netname, "\" ");
		}
	}

	// now apply the array to a simple string, with the ; symbol separating lights
	s = "";
	if(el_port_string) { s = strcat(s, el_port_string, "; "); el_port_string = string_null; }

	return s;
}

entity el_LightPort_Load(string s, float database)
{
	// load light properties, and spawn a new light with them
	float n;
	entity e = world;

	// separate lights between the ; symbols
	n = tokenizebyseparator(s, "; ");
	el_port_string = argv(0);

	// now separate and apply the properties of each light
	float argv_num = 0;

	tokenize_console(el_port_string);
	e = el_SpawnLight(database);

	if(database) { setorigin(e, stov(argv(argv_num))); ++ argv_num; }
	e.colormod = stov(argv(argv_num)); ++argv_num;
	e.cnt = stof(argv(argv_num)); ++argv_num;
	if(database)
	{
		if(e.crypto_idfp)	strunzone(e.crypto_idfp);	if(argv(argv_num) != "")	e.crypto_idfp = strzone(argv(argv_num));	else	e.crypto_idfp = string_null;	++argv_num;
		if(e.netname)	strunzone(e.netname);	e.netname = strzone(argv(argv_num));	++argv_num;
	}

	el_port_string = string_null; // fully clear the string

	return e;
}

void el_Database_Save()
{
	// saves all lights to the database file
	entity head;
	string file_name;
	float file_get;

	file_name = strcat("editlights/storage_", autocvar_g_editlights_storage_name, "_", GetMapname(), ".txt");
	file_get = fopen(file_name, FILE_WRITE);
	fputs(file_get, strcat("// editlights storage \"", autocvar_g_editlights_storage_name, "\" for map \"", GetMapname(), "\""));
	fputs(file_get, strcat(" containing ", ftos(el_lightcount), " lights\n"));

	for(head = world; (head = find(head, classname, "editlights")); )
	{
		// use a line of text for each light, listing all properties
		fputs(file_get, strcat(el_LightPort_Save(head, TRUE), "\n"));
	}
	fclose(file_get);
}

void el_Debug(string input)
{
	switch(autocvar_g_editlights_debug)
	{
		case 1: dprint(input); break;
		case 2: print(input); break;
	}
}

void el_Database_Load()
{
	// loads all lights from the database file
	string file_read, file_name;
	float file_get;

	file_name = strcat("editlights/storage_", autocvar_g_editlights_storage_name, "_", GetMapname(), ".txt");
	file_get = fopen(file_name, FILE_READ);
	if(file_get < 0)
	{
		el_Debug(strcat("^3EDITLIGHTS - Server: ^7could not find storage file ^3", file_name, "^7, no lights were loaded\n"));
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
			e = el_LightPort_Load(file_read, TRUE);
		}
		el_Debug(strcat("^3SANDBOX - SERVER: ^7successfully loaded storage file ^3", file_name, "\n"));
	}
	fclose(file_get);
}

.vector el_oldorig;
.vector el_oldcolor;
.float el_oldcnt;
.float el_oldeditmode;
void el_Think()
{
	self.nextthink = time;

	if(self.origin != self.el_oldorig)
	{
		self.el_oldorig = self.origin;
		self.SendFlags |= 2;
	}

	if(self.cnt != self.el_oldcnt)
	{
		self.el_oldcnt = self.cnt;
		self.SendFlags |= 8;
	}

	if(self.colormod != self.el_oldcolor)
	{
		self.el_oldcolor = self.colormod;
		self.SendFlags |= 4;
	}

	// decide if and how this light can be grabbed
	if(autocvar_g_editlights_readonly)
		self.grab = 0; // no grabbing
	else if(autocvar_g_editlights_editor_free < 2 && self.crypto_idfp)
		self.grab = 1; // owner only
	else
		self.grab = 3; // anyone

	// Light owner is stored via player UID, but we also need the owner as an entity (if the player is available on the server).
	// Therefore, scan for all players, and update the owner as long as the player is present. We must always do this,
	// since if the owning player disconnects, the light's owner should also be reset.
	entity e;
	FOR_EACH_REALPLAYER(e) // bots can't have lights
	{
		if(self.crypto_idfp == e.crypto_idfp)
		{
			self.realowner = e;
			break;
		}
		self.realowner = world;
	}
}

entity el_SpawnLight(float database)
{
	entity e = spawn();

	e.solid = SOLID_TRIGGER; // for grabbing (TODO: check if we need this)
	e.classname = "editlights";
	e.think = el_Think;
	e.alpha = 1;
	e.nextthink = time;

	if(!database)
	{

		if(self.crypto_idfp != "") { e.crypto_idfp = strzone(self.crypto_idfp); }
		else { print_to(self, "^1EDITLIGHTS - WARNING: ^7You spawned a light, but lack a player UID. ^1Your lights are not secured and can be edited by any player!"); }

		// set public light information
		e.netname = strzone(self.netname); // name of the owner

		// set origin and direction based on player position and view angle
		makevectors(self.v_angle);
		WarpZone_TraceLine(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * autocvar_g_editlights_spawn_distance, MOVE_NORMAL, self);
		setorigin(e, trace_endpos);
	}

	setsize(e, '-10 -10 -10', '10 10 10');
	Net_LinkEntity(e, FALSE, 0, el_SendEntity);

	if(IS_REAL_CLIENT(self)) { print_to(self, "Spawned new light entity"); }

	el_lightcount += 1;

	return e;
}

void el_Remove(entity e)
{
	if(e.crypto_idfp)	{	strunzone(e.crypto_idfp);	e.crypto_idfp = string_null;	}
	if(e.netname)		{	strunzone(e.netname);	e.netname = string_null;	}
	if(e.message)		{	strunzone(e.message);	e.message = string_null;	}
	if(e.message2)		{	strunzone(e.message2);	e.message2 = string_null;	}
	remove(e);
	e = world;

	el_lightcount -= 1;
}

float el_CheckLight(entity e, float permissions)
{
	if(!e || e.classname != "editlights") { return FALSE; }

	if(!permissions) { return TRUE; }
	if(e.crypto_idfp == "") { return TRUE; }
	if(!(e.realowner != self && autocvar_g_editlights_editor_free < 2)) { return TRUE; }

	return FALSE;
}

MUTATOR_HOOKFUNCTION(el_ClientCommand)
{
	if(cmd_name == "editlights")
	{
		if(argv(1) == "spawn")
		{
			if(!self.el_editmode) { sprint(self, "You cannot spawn lights\n"); return TRUE; }
			if(el_lightcount >= autocvar_g_editlights_max) { sprint(self, "Too many lights!\n"); return TRUE; }
			WarpZone_TraceLine(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 100, MOVE_NORMAL, self);
			vector cmod = ('1 0 0 ' * stof(argv(2))) + ('0 1 0' * stof(argv(3))) + ('0 0 1' * stof(argv(4)));
			entity e = el_SpawnLight(FALSE);
			setorigin(e, trace_endpos);
			e.colormod = ((cmod) ? cmod : '1 0 1');
			e.cnt = ((argv(5)) ? stof(argv(5)) : 100);
			return TRUE;
		}

		if(argv(1) == "remove")
		{
			if(!self.el_editmode) { sprint(self, "You cannot edit lights\n"); return TRUE; }

			entity e, thelight = world;
			for(e = WarpZone_FindRadius(self.origin + self.view_ofs + v_forward * 100, 50, FALSE); e; e = e.chain)
			if(e.classname == "editlights")
			{
				thelight = e;
				break;
			}

			if(el_CheckLight(thelight, TRUE))
			{
				el_Remove(thelight);
				sprint(self, "Successfully removed a light\n");
				return TRUE;
			}
			else
			{
				sprint(self, "Light not found\n");
				return TRUE;
			}
		}
		
		if(argv(1) == "edit")
		{
			if(!argv(2))
			{
				if(self.el_editmode)
					self.el_editmode = FALSE;
				else
					self.el_editmode = TRUE;
				sprint(self, "Edit mode ", ((self.el_editmode) ? "enabled" : "disabled"), "\n");
				return TRUE;
			}
			if(!self.el_editmode) { sprint(self, "You cannot edit lights\n"); return TRUE; }

			entity e, thelight = world;
			for(e = WarpZone_FindRadius(self.origin + self.view_ofs + v_forward * 100, 50, FALSE); e; e = e.chain)
			if(e.classname == "editlights")
			{
				thelight = e;
				break;
			}

			if(el_CheckLight(thelight, TRUE))
			if(argv(3))
			switch(argv(2))
			{
				case "brightness": thelight.cnt = bound(-1, stof(argv(3)), 2000); thelight.SendFlags |= 8; return TRUE;
				case "color":
				if(argv(5))
				{
					thelight.colormod_x = stof(argv(3));
					thelight.colormod_y = stof(argv(4));
					thelight.colormod_z = stof(argv(5));
					thelight.SendFlags |= 2;
					sprint(self, "Color set!\n");
					return TRUE;
				}
			}
		}

		sprint(self, "Command was not handled\n");
		return TRUE;
	}

	return FALSE;
}

float el_autosave_time;
MUTATOR_HOOKFUNCTION(el_StartFrame)
{
	if(!autocvar_g_editlights_storage_autosave)
		return FALSE;
	if(time < el_autosave_time)
		return FALSE;
	el_autosave_time = time + autocvar_g_editlights_storage_autosave;

	el_Database_Save();

	return TRUE;
}

MUTATOR_HOOKFUNCTION(el_GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_editlights, "cl_editlights");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(el_PlayerThink)
{
	self.el_editmode = self.cvar_cl_editlights;
	return FALSE;
}

void el_DelayedInit()
{
	el_Database_Load();
}

MUTATOR_DEFINITION(mutator_editlights)
{
	MUTATOR_HOOK(SV_ParseClientCommand, el_ClientCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_StartFrame, el_StartFrame, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetCvars, el_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, el_PlayerThink, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		precache_model("models/runematch/rune.mdl");
		el_autosave_time = time + autocvar_g_editlights_storage_autosave; // don't save the first server frame
		if(autocvar_g_editlights_storage_autoload)
			InitializeEntity(world, el_DelayedInit, INITPRIO_LAST);
	}

	return FALSE;
}
