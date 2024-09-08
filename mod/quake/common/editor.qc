#include "editor.qh"

#ifdef SVQC

void editor_write(entity this, int fh)
{
	fputs(fh, "{\n");
	fputs(fh, strcat("\"classname\" \"", this.classname, "\"\n"));
	fputs(fh, strcat("\"origin\" \"", strcat(ftos(this.origin_x), " ", ftos(this.origin_y), " ", ftos(this.origin_z)), "\"\n"));
	fputs(fh, strcat("\"angles\" \"", strcat(ftos(this.angles_x), " ", ftos(this.angles_y), " ", ftos(this.angles_z)), "\"\n"));
	if(this.spawnflags) fputs(fh, strcat("\"spawnflags\" \"", ftos(this.spawnflags), "\"\n"));
	if(this.target && this.target != "") fputs(fh, strcat("\"target\" \"", this.target, "\"\n"));
	if(this.target2 && this.target2 != "") fputs(fh, strcat("\"target2\" \"", this.target2, "\"\n"));
	if(this.target3 && this.target3 != "") fputs(fh, strcat("\"target3\" \"", this.target3, "\"\n"));
	if(this.target4 && this.target4 != "") fputs(fh, strcat("\"target4\" \"", this.target4, "\"\n"));
	if(this.targetname && this.targetname != "") fputs(fh, strcat("\"targetname\" \"", this.targetname, "\"\n"));
	if(this.killtarget && this.killtarget != "") fputs(fh, strcat("\"killtarget\" \"", this.killtarget, "\"\n"));
	if(this.count) if(this.count) fputs(fh, strcat("\"count\" \"", ftos(this.count), "\"\n"));
	fputs(fh, "}\n");
}

void editor_save()
{
	int fh = fopen(strcat("maps/", mapname, ".ent"), FILE_WRITE);
	if(fh < 0)
		return;

	IL_EACH(g_editor, true,
	{
		editor_write(it, fh);
	});

	fclose(fh);
}

void editor_StartFrame()
{
	if(time < editor_lastcheck)
		return;
	editor_lastcheck = time + 1.5;
	IL_EACH(g_editor, true,
	{
		if(!it.target && !it.target2 && !it.target3 && !it.target4 && !it.killtarget)
			continue;
		entity me = it;
		IL_EACH(g_editor, it != me && it.targetname,
		{
			if(it.targetname == me.target)
				Send_Effect(EFFECT_EDITOR_TARGET, me.origin, it.origin, 1);
			else if(it.targetname == me.target2)
				Send_Effect(EFFECT_EDITOR_TARGET2, me.origin, it.origin, 1);
			else if(it.targetname == me.target3)
				Send_Effect(EFFECT_EDITOR_TARGET3, me.origin, it.origin, 1);
			else if(it.targetname == me.target4)
				Send_Effect(EFFECT_EDITOR_TARGET4, me.origin, it.origin, 1);
			else if(it.targetname == me.killtarget)
				Send_Effect(EFFECT_EDITOR_KILLTARGET, me.origin, it.origin, 1);
		});
	});
}

bool editor_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_EDITOR);
	WriteVector(MSG_ENTITY, this.origin);
	WriteAngle(MSG_ENTITY, this.angles_y);

	return true;
}

entity editor_create(string thetype, vector position, float theang)
{
	entity ent = spawn();
	set_movetype(ent, MOVETYPE_NONE);
	IL_PUSH(g_editor, ent);
	ent.classname = strzone(thetype);
	setorigin(ent, position);
	ent.angles_y = theang;
	_setmodel(ent, "null");
	ent.solid = SOLID_CORPSE;
	setsize(ent, VEC_HULL_MIN, VEC_HULL_MAX);
	Net_LinkEntity(ent, true, 0, editor_send);

	entity e = WaypointSprite_Spawn(WP_Entity, 0, 1024, ent, '0 0 64', NULL, 0, ent, waypointsprite_editor, false, NULL);
	e.wp_extra = num_for_edict(ent);
	return ent;
}

void editor_delete(entity ent)
{
	if(!ent || wasfreed(ent))
		return;
	WaypointSprite_Kill(ent.waypointsprite_editor);
	delete(ent);
}

entity editor_validate(string cmd)
{
	int thenum = stoi(cmd);
	if(thenum > 65535 || thenum < 256)
		return NULL;
	entity e = edict_num(thenum);
	if(!e || !IL_CONTAINS(g_editor, e))
		return NULL;
	return e;
}

// This must be called in SV_ParseClientCommand
// input entity this
// input string cmd: same as in SV_ParseClientCommand
// output bool: true if command was handled, false if not
bool sv_editor_command(entity this, string cmd, float argc)
{
	if(cmd == "editor")
	{
		switch(argv(1))
		{
			case "info":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				sprint(this, sprintf("Entity %s is at %v with target %s and targetname %s, for more information use the PRVM commands\n", e.classname, e.origin, e.target, e.targetname));
				return true;
			}
			case "spawn":
			{
				if(argv(2) == "")
				{
					sprint(this, "You must provide a classname\n");
					return true;
				}
				entity ent = editor_create(argv(2), this.origin, this.angles_y);
				if(!ent)
				{
					sprint(this, "You somehow did something wrong, try again!\n");
					return true;
				}
				sprint(this, sprintf("Spawning %s (%d) at your current position and angles\n", ent.classname, num_for_edict(ent)));
				return true;
			}
			case "remove":
			case "delete":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				sprint(this, sprintf("Deleting %s\n", e.classname));
				editor_delete(e);
				return true;
			}
			case "classname":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				if(argv(3) == "")
				{
					sprint(this, "Invalid classname\n");
					return true;
				}
				e.classname = strzone(argv(3));
				sprint(this, sprintf("Classname updated to %s\n", e.classname));
				return true;
			}
			case "origin":
			case "pos":
			case "position":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				setorigin(e, this.origin);
				e.SendFlags |= 1;
				sprint(this, sprintf("Position of %s updated to your current location\n", e.classname));
				return true;
			}
			case "spawnflags":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				if(argv(3) == "add")
					e.spawnflags |= stoi(argv(4));
				else if(argv(3) == "remove")
					e.spawnflags &= ~stoi(argv(4));
				else
					e.spawnflags = stoi(argv(3));
				sprint(this, sprintf("Spawn flags of %s set to %d\n", e.classname, e.spawnflags));
				return true;
			}
			case "count":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.count = stoi(argv(3));
				sprint(this, sprintf("Count field of %s set to %d\n", e.classname, e.count));
				return true;
			}
			case "angle":
			case "angles":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.angles = '0 0 0';
				e.angles_y = this.angles_y;
				e.SendFlags |= 1;
				sprint(this, sprintf("Angles of %s updated to your current yaw angle\n", e.classname));
				return true;
			}
			case "target":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.target = strzone(argv(3));
				sprint(this, sprintf("Entity %s target set to %s\n", e.classname, e.target));
				return true;
			}
			case "target2":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.target2 = strzone(argv(3));
				sprint(this, sprintf("Entity %s target2 set to %s\n", e.classname, e.target2));
				return true;
			}
			case "target3":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.target3 = strzone(argv(3));
				sprint(this, sprintf("Entity %s target3 set to %s\n", e.classname, e.target3));
				return true;
			}
			case "target4":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.target4 = strzone(argv(3));
				sprint(this, sprintf("Entity %s target4 set to %s\n", e.classname, e.target4));
				return true;
			}
			case "targetname":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.targetname = strzone(argv(3));
				sprint(this, sprintf("Entity %s targetname set to %s\n", e.classname, e.targetname));
				return true;
			}
			case "killtarget":
			{
				entity e = editor_validate(argv(2));
				if(!e)
				{
					sprint(this, "Invalid entity\n");
					return true;
				}
				e.killtarget = strzone(argv(3));
				sprint(this, sprintf("Entity %s killtarget set to %s\n", e.classname, e.killtarget));
				return true;
			}
			case "save":
			{
				sprint(this, sprintf("File saved to data/maps/%s.ent, overwriting any existing data!\n", mapname));
				editor_save();
				return true;
			}
			case "list":
			{
				sprint(this, "Listing all entities currently in the map:\n");
				IL_EACH(g_editor, true,
				{
					sprint(this, strcat(it.classname, " at ", vtos(it.origin)));
				});
				sprint(this, "For a complete list of spawn options, search the code for spawnfunc(\n");
				return true;
			}
		}
		sprint(this, "Possible commands: spawn remove origin angles target targetname killtarget save list\n");
		return true;
	}
	return false;
}
#endif

#ifdef CSQC

void DrawSurface(string thetexture, vector forwardright, vector forwardleft, vector backleft, vector backright, vector thecolor, float thealpha)
{
	R_BeginPolygon(thetexture, DRAWFLAG_NORMAL, false);
	R_PolygonVertex(forwardright, '0 0 0', thecolor, thealpha);
	R_PolygonVertex(forwardleft,  '0 1 0', thecolor, thealpha);
	R_PolygonVertex(backleft,  '1 1 0', thecolor, thealpha);
	R_PolygonVertex(backright, '0 1 0', thecolor, thealpha);
	R_EndPolygon();
}

void DrawBox(vector org, vector themin, vector themax, string toptex, string bottomtex, string backtex, string righttex, string lefttex, string fronttex, vector thecolor, float thealpha)
{
	vector forward = '1 0 0', up = '0 0 1', right = '0 1 0';

	vector bbox_point_topfwdleft  = org + (forward * themax.x + right  * (-themax.y) + up * themax.z);
	vector bbox_point_topfwdright = org + (forward * themax.x + right  * (-themin.y) + up * themax.z);
	vector bbox_point_topbckleft  = org + (forward * themin.x + right  * (-themax.y) + up * themax.z);
	vector bbox_point_topbckright = org + (forward * themin.x + right  * (-themin.y) + up * themax.z);
	vector bbox_point_btmfwdleft  = org + (forward * themax.x + right  * (-themax.y) + up * themin.z);
	vector bbox_point_btmfwdright = org + (forward * themax.x + right  * (-themin.y) + up * themin.z);
	vector bbox_point_btmbckleft  = org + (forward * themin.x + right  * (-themax.y) + up * themin.z);
	vector bbox_point_btmbckright = org + (forward * themin.x + right  * (-themin.y) + up * themin.z);

	// Top face
	DrawSurface(toptex, bbox_point_topfwdright, bbox_point_topfwdleft, bbox_point_topbckleft, bbox_point_topbckright, thecolor, thealpha);

	// Botton face
	DrawSurface(bottomtex, bbox_point_btmfwdright, bbox_point_btmfwdleft, bbox_point_btmbckleft, bbox_point_btmbckright, thecolor, thealpha);

	// Back face
	DrawSurface(backtex, bbox_point_topbckright, bbox_point_topbckleft, bbox_point_btmbckleft, bbox_point_btmbckright, thecolor, thealpha);

	// Right face
	DrawSurface(righttex, bbox_point_topbckright, bbox_point_topfwdright, bbox_point_btmfwdright, bbox_point_btmbckright, thecolor, thealpha);

	// Left face
	DrawSurface(lefttex, bbox_point_topbckleft, bbox_point_topfwdleft, bbox_point_btmfwdleft, bbox_point_btmbckleft, thecolor, thealpha);

	// Front face
	DrawSurface(fronttex, bbox_point_topfwdright, bbox_point_topfwdleft, bbox_point_btmfwdleft, bbox_point_btmfwdright, thecolor, thealpha);
}

void draw_bbox(entity this)
{
	vector rgb = '0 0 0';
	float alph = 0.50;
	switch(this.solid)
	{
		case SOLID_NOT: 		rgb = '1 1 1'; alph = 0.05; break;
		case SOLID_TRIGGER: 	rgb = '1 0 1'; alph = 0.10; break;
		case SOLID_BBOX: 		rgb = '0 1 0'; alph = 0.10; break;
		case SOLID_SLIDEBOX: 	rgb = '1 0 0'; alph = 0.10; break;
		case SOLID_BSP: 		rgb = '0 0 1'; alph = 0.05; break;
		case SOLID_CORPSE: 		rgb = '1 0.5 0'; alph = 0.05; break;
	}

	alph *= 5;

	DrawBox(this.origin, this.mins, this.maxs, "", "", "", "", "", "", rgb, alph);
}

void editor_draw(entity this)
{
	if(vdist(this.origin - view_origin, >, 2048))
		return;
	draw_bbox(this);
}

NET_HANDLE(ENT_CLIENT_EDITOR, bool isnew)
{
	this.origin = ReadVector();
	setorigin(this, this.origin);
	this.angles = '0 0 0';
	this.angles_y = ReadAngle();

	_setmodel(this, "null");
	this.solid = SOLID_CORPSE;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	set_movetype(this, MOVETYPE_NONE);

	this.draw = editor_draw;
	if(isnew)
		IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	return = true;
}

STATIC_INIT_LATE(editor_init)
{
	localcmd("\nalias editor \"cmd editor ${* ?}\"\n");
}
#endif
