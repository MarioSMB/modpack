#include "editor.qh"

#include "triggers/misc/barrel.qh"
#include "monsters/monster/spirit.qh"
#include "items.qh"

.vector edent_origin;
.vector edent_angles;
.vector edent_mins;
.vector edent_maxs;
.vector edent_colormod;
.float edent_scale;
.float edent_solid;
.float edent_alpha;
.string edent_model;
.string edent_classname;
.string edent_target;
.string edent_targetname;
.float edent_spawnflags;

// two-way connection, client knows what entity they are editing, and entity knows who is editing it
.entity editor_selection;

// entity properties
.bool is_edent;
.entity edent;

void editor_send_selection(entity e);

void editor_reset_ent(entity e)
{
	setorigin(e, e.edent.edent_origin);
	e.angles = e.edent.edent_angles;
	e.scale = e.edent.edent_scale;
	e.solid = e.edent.edent_solid;
	e.velocity = '0 0 0';
	e.avelocity = '0 0 0';
	e.movetype = MOVETYPE_NONE;
	_setmodel(e, e.edent.edent_model);
	setsize(e, e.edent.edent_mins,  e.edent.edent_maxs);
	e.classname = e.edent.edent_classname;
	e.alpha = e.edent.edent_alpha;
	e.target = e.edent.edent_target;
	e.targetname = e.edent.edent_targetname;
	e.spawnflags = e.edent.edent_spawnflags;
	e.nextthink = 0;
	e.flags = 0;
	settouch(e, func_null);
	e.frame = 0;
}

void editor_delete_ent(entity e)
{
	if(!e.is_edent)
	{
		LOG_INFO("Tried to delete a non-ed-ent");
		return;
	}
	if(e.editor_selection)
		e.editor_selection.editor_selection = NULL;
	delete(e.edent);
	delete(e);
}


void editor_copy_to_edent(entity e, entity ed_ent)
{
	ed_ent.edent_origin = e.origin;
	ed_ent.edent_angles = e.angles;
	ed_ent.edent_mins = e.mins;
	ed_ent.edent_maxs = e.maxs;
	ed_ent.edent_colormod = e.colormod;
	ed_ent.edent_scale = e.scale;
	ed_ent.edent_solid = e.solid;
	ed_ent.edent_alpha = e.alpha;
	ed_ent.edent_model = e.model;
	ed_ent.edent_classname = e.classname;
	ed_ent.edent_target = e.target;
	ed_ent.edent_targetname = e.targetname;
	ed_ent.edent_spawnflags = e.spawnflags;
}

void editor_write_ent(float filehandle, entity e)
{
	fputs(filehandle, "ent_begin\n");
	fputs(filehandle, sprintf("class %s\n", e.edent.edent_classname));
	fputs(filehandle, sprintf("organg %v %v\n", e.edent.edent_origin, e.edent.edent_angles));
	if(e.edent.edent_target != "")
		fputs(filehandle, sprintf("target %s\n", e.edent.edent_target));
	if(e.edent.edent_targetname != "")
		fputs(filehandle, sprintf("targetname %s\n", e.edent.edent_targetname));
	if(e.edent.edent_spawnflags)
		fputs(filehandle, sprintf("spawnflags %.0f\n", e.edent.edent_spawnflags));
		
	fputs(filehandle, "end\n");
}

float editor_set_ent_type(entity e, string type);
float editor_init_edent(entity e);

void editor_read_ent(float filehandle)
{
	string line = fgets(filehandle);
	entity e = spawn();
	while(line && line != "end")
	{
		tokenize_console(line);
		switch (argv(0))
		{
			case "class":
				e.classname = strcat1(argv(1));
				break;
			case "organg":
				setorigin(e, vec3(stof(argv(1)), stof(argv(2)), stof(argv(3))));
				e.angles = vec3(stof(argv(4)), stof(argv(5)), stof(argv(6)));
				break;
			case "target":
				strcpy(e.target, argv(1));
				break;
			case "targetname":
				strcpy(e.targetname, argv(1));
				break;
			case "spawnflags":
				e.spawnflags = stof(argv(1));
				break;
			case "ent_begin":
				LOG_INFO("!!!!! BROKEN FILE !!!!!\n! ent_begin before end !");
				break;
			default:
				LOG_INFO("Unknown parm ", argv(0));
				break;
		}
		line = fgets(filehandle);
	}
	
	bool success = editor_set_ent_type(e, e.classname);
	if(!success)
	{
		LOG_INFO("Invalid entity spawned");
		delete(e);
		return;
	}
	editor_init_edent(e);
}

bool editor_set_ent_type(entity e, string type)
{
	switch(type)
	{
		case "misc_barrel":
			e.classname = "misc_barrel";
			setmodel(e, MDL_BARREL);
			e.scale = 1;
			e.solid = SOLID_BBOX;
			setsize(e, '-12 -12 0', '12 12 36');
			break;
		case "item_coin":
			e.classname = "item_coin";
			setmodel(e, MDL_COIN);
			e.scale = 1;
			e.solid = SOLID_BBOX;
			setsize(e, '-16 -16 -16', '16 16 42');
			break;
		case "monster_spirit":
			e.classname = "monster_spirit";
			setmodel(e, MDL_GHOST);
			e.scale = 1;
			e.solid = SOLID_BBOX;
			setsize(e, '-16 -16 -16', '16 16 16');
			break;
		case "item_ring":
			e.classname = "item_ring";
			setmodel(e, MDL_RING);
			e.scale = 1;
			e.solid = SOLID_BBOX;
			setsize(e, '-20 -20 -16', '20 20 64');
			break;
		default:
			return false;
	}
	
	return true;
}

void editor_spawn_ent_type(entity e, string type)
{
	switch(type)
	{
		case "misc_barrel":
			e.spawnfunc_checked = true;
			spawnfunc_misc_barrel(e);
			break;
		case "item_coin":
			e.spawnfunc_checked = true;
			spawnfunc_item_coin(e);
			break;
		case "monster_spirit":
			e.spawnfunc_checked = true;
			spawnfunc_monster_spirit(e);
			break;
		case "item_ring":
			e.spawnfunc_checked = true;
			spawnfunc_item_ring(e);
			break;
		default:
			LOG_INFO("Attempted to load invalid editor entity ", type);
			break;
	}
}

bool editor_init_edent(entity e)
{
	e.is_edent = true;
	e.edent = new_pure(editor_ent);
	if(!e.edent) {
		e.is_edent = false;
		return false;
	}
	
	editor_copy_to_edent(e, e.edent);
	return true;
}

vector editor_snap_to_grid(vector coord)
{
	float size = 16;
	return vec3(rint(coord_x/size)*size, rint(coord_y/size)*size, rint(coord_z/size)*size);
}

void editor_set_select(entity selector, entity selectee)
{	
	// Unselect first
	if(selector.editor_selection)
	{
		if(selector.editor_selection.editor_selection)
			selector.editor_selection.editor_selection = NULL;
		//selector.editor_selection.effects -= selector.editor_selection.effects & EF_FULLBRIGHT;
		selector.editor_selection.colormod = '1 1 1';
		selector.editor_selection = NULL;
	}
	
	if(!selectee.is_edent) return;
	
	selector.editor_selection = selectee;
	selectee.editor_selection = selector;
	//selectee.effects |= EF_FULLBRIGHT;
	selectee.colormod = '1 0.2 0.2';
}

void editor_select_ent(entity this)
{
	if(!edit_mode)
		return;

	makevectors(this.v_angle);
	traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 8096, MOVE_NORMAL, this);
	
	editor_set_select(this, trace_ent);
	
	editor_send_selection(trace_ent);
}

void editor_set_origin(entity e, vector org)
{
	if(!e.is_edent)
		return;
	setorigin(e, org);
	e.edent.edent_origin = org;
	
	editor_send_selection(e);
}

void editor_move_selection(entity this, float dir)
{
	if(!this.editor_selection) return;
	entity e = this.editor_selection;
	
	makevectors(vec3(0, rint(this.v_angle_y/90)*90, 0));
	
	float amount = (STAT(ED_GRID, this) > 0) ? STAT(ED_GRID, this) : 16;

	switch(dir)
	{
		case 0: editor_set_origin(e, e.origin + v_forward * amount); break;
		case 1: editor_set_origin(e, e.origin - v_forward * amount); break;
		case 2: editor_set_origin(e, e.origin - v_right * amount); break;
		case 3: editor_set_origin(e, e.origin + v_right * amount); break;
		case 4: editor_set_origin(e, e.origin + v_up * amount); break;
		case 5: editor_set_origin(e, e.origin - v_up * amount); break;
	}
}

void editor_rotate_selection(entity this, float angle)
{
	if(!this.editor_selection)
		return;
	entity e = this.editor_selection;
	if(!e.is_edent)
		return;
	
	e.angles_y += angle;
	e.edent.edent_angles.y = e.angles_y;
	
	editor_send_selection(e);
}

void editor_add_ent(entity this, string type)
{
	if(!edit_mode)
		return;
	
	entity new_ent = spawn();
	
	vector pos;
	makevectors(this.v_angle);
	traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 8096, 0, this);
	if(trace_fraction == 1) 
		pos = this.origin + this.view_ofs + v_forward * 512;
	else
		pos = trace_endpos;
		
	setorigin(new_ent, editor_snap_to_grid(pos));
	
	new_ent.angles = vec3(0, rint(this.angles_y / 90) * 90, 0);
	
	float success = editor_set_ent_type(new_ent, type);
	
	if(!success)
	{
		LOG_INFO("Unknown entity type ", type);
		delete(new_ent);
		return;
	}
	
	success = editor_init_edent(new_ent);
	
	if(!success)
	{
		LOG_INFO("Could not spawn editor entity ", type);
		delete(new_ent);
		return;
	}
	
	editor_set_select(this, new_ent);
	
	editor_send_selection(new_ent);
}

void editor_save_ents(string filename)
{
	if(filename == "default")
		filename = getworldbasename();
	if(filename == "")
	{
		LOG_INFO("edit_save: will not save without filename");
		LOG_INFO("edit_save: use 'edit_save default' for map default ents");
	}
	
	filename = strcat(filename, ".ef");
	LOG_INFO("Saving into ", filename);
	
	float filehandle = fopen(filename, FILE_WRITE);
	entity ed_ent = findfloat(NULL, is_edent, true);
	while(ed_ent)
	{
		editor_write_ent(filehandle, ed_ent);
		ed_ent = findfloat(ed_ent, is_edent, true);
		fputs(filehandle, "\n");
	}
	
	fclose(filehandle);
}

void editor_load_ents(string filename)
{
	if(filename == "default")
		filename = getworldbasename();
	
	filename = strcat(filename, ".ef");
	// LOG_INFO("Loading from ", filename);
	
	float filehandle = fopen(filename, FILE_READ);
	if(filehandle < 0)
	{
		LOG_INFO("Could not load world entities");
		return;
	}
	
	string line = fgets(filehandle);
	
	while (line)
	{
		tokenize_console(line);

		switch (argv(0))
		{
			case "ent_begin":
				editor_read_ent(filehandle);
				break;
			default:
				if(argv(0) == "")
					break;
				if(substring(argv(0), 0, 1) == "#")
					break;
				LOG_INFOF("Unknown line %s in %s", line, filename);
				break;
		}
		
		line = fgets(filehandle);
	}
	
	fclose(filehandle);
}

#if 0
bool entcustomize(entity this, entity client)
{
	if(this.origin_z > -100 && client.origin.z < -100)
		return false;
	if(this.origin_z < -100 && client.origin.z > -100)
		return false;
	return true;
}
#endif

void editor_play()
{
	entity ed_ent = findfloat(NULL, is_edent, true);
	
	combo_max = 0;

	while(ed_ent)
	{
		// ed_ent.customizeentityforclient = entcustomize;
		editor_spawn_ent_type(ed_ent, ed_ent.classname);
		ed_ent = findfloat(ed_ent, is_edent, true);
	}

	gold_goal = min(combo_max - 4, floor(combo_max * 0.75));
}

void editor_reset()
{
	entity ed_ent = findfloat(NULL, is_edent, true);
	while(ed_ent)
	{
		editor_reset_ent(ed_ent);
		ed_ent = findfloat(ed_ent, is_edent, true);
	}
}

void editor_send_selection(entity e)
{
	if(!e.editor_selection)
		return;

	msg_entity = e.editor_selection;
	WriteHeader(MSG_ONE, ed_update);
	WriteVector(MSG_ONE, e.origin);
	WriteVector(MSG_ONE, e.angles);
	WriteFloat(MSG_ONE, e.spawnflags);
	WriteString(MSG_ONE, e.target);
	WriteString(MSG_ONE, e.targetname);
}

void editor_set_property(entity this, float argc)
{
	if(!this.editor_selection)
		return;
	entity e = this.editor_selection;
	switch(argv(1))
	{
		case "origin":
			vector org = vec3(stof(argv(2)), stof(argv(3)), stof(argv(4)));
			editor_set_origin(e, org);
			break;
		
		case "angles":
			vector ang = vec3(stof(argv(2)), stof(argv(3)), stof(argv(4)));
			e.angles = ang;
			e.edent.edent_angles = ang;
			break;
		
		case "target":
			strcpy(e.target, argv(2));
			strcpy(e.edent.edent_target, argv(2));
			break;
		
		case "targetname":
			strcpy(e.targetname, argv(2));
			strcpy(e.edent.edent_targetname, argv(2));
			break;
			
		case "spawnflags":
			e.spawnflags = stof(argv(2));
			e.edent.edent_spawnflags = e.spawnflags;
			break;
	}
	
	editor_send_selection(e);
}

// This must be called in SV_ParseClientCommand
// input entity this
// input string cmd: same as in SV_ParseClientCommand
// output bool: true if command was handled, false if not
bool sv_editor_command(entity this, string cmd, float argc)
{
	switch(argv(0))
	{
		case "toggleeditmode":
			edit_mode = !edit_mode;
			if(edit_mode)
				editor_reset();
			else
				editor_play();
			return true;
			
		case "edit_add":
			if(argc >= 2) 
				editor_add_ent(this, argv(1));
			return true;
		
		case "edit_select":
			editor_select_ent(this);
			return true;

		case "edit_delete":
			if(edit_mode && this.editor_selection)
				editor_delete_ent(this.editor_selection);
			return true;
			
		case "edit_save":
			if(edit_mode && argc >= 2)
				editor_save_ents(argv(1));
			return true;
			
		case "edit_load":
			if(edit_mode && argc >= 2)
				editor_load_ents(argv(1));
			return true;
			
		case "edit_move":
			if(edit_mode && argc >= 2)
				editor_move_selection(this, stof(argv(1)));
			return true;
			
		case "edit_grid":
			if(edit_mode && argc >= 2)
				STAT(ED_GRID, this) = stof(argv(1));
			return true;
			
		case "edit_rotate":
			if(edit_mode && argc >= 2)
				editor_rotate_selection(this, stof(argv(1)));
			return true;
			
		case "edit_setprop":
			if(edit_mode && argc >= 3)
				editor_set_property(this, argc);
			return true;
	}
	return false;
}

PRECACHE(editor_init)
{
	string map_name = getworldbasename();
	editor_load_ents(sprintf("%s_%.0f", map_name, cvar("skill")));
	editor_play();
}
