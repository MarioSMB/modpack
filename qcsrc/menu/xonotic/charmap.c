#ifdef INTERFACE
CLASS(XonoticCharmap) EXTENDS(Image)
	METHOD(XonoticCharmap, configureXonoticCharmap, void(entity, entity))
	METHOD(XonoticCharmap, mousePress, float(entity, vector))
	METHOD(XonoticCharmap, mouseRelease, float(entity, vector))
	METHOD(XonoticCharmap, mouseMove, float(entity, vector))
	METHOD(XonoticCharmap, mouseDrag, float(entity, vector))
	METHOD(XonoticCharmap, keyDown, float(entity, float, float, float))
	METHOD(XonoticCharmap, focusLeave, void(entity))
	METHOD(XonoticCharmap, draw, void(entity))
	ATTRIB(XonoticCharmap, controlledTextbox, entity, NULL)
	ATTRIB(XonoticCharmap, image, string, SKINGFX_CHARMAP)
	ATTRIB(XonoticCharmap, image2, string, SKINGFX_CHARMAP_SELECTED)
	ATTRIB(XonoticCharmap, focusable, float, 1)
	ATTRIB(XonoticCharmap, previouslySelectedCharacterCell, float, -1)
	ATTRIB(XonoticCharmap, selectedCharacterCell, float, 0)
	ATTRIB(XonoticCharmap, mouseSelectedCharacterCell, float, -1)
ENDCLASS(XonoticCharmap)
entity makeXonoticCharmap(entity theTextbox);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticCharmap(entity theTextbox)
{
	entity me;
	me = spawnXonoticCharmap();
	me.configureXonoticCharmap(me, theTextbox);
	return me;
}

string CharMap_CellToChar(float c)
{
	if (cvar("utf8_enable")) {
		if(c == 13)
			return chr(0xE000 + 127);
		else if(c < 32)
			return chr(0xE000 + c);
		else
			return chr(0xE000 + c + 96);
	} else {
		if(c == 13)
			return chr(127);
		else if(c < 32)
			return chr(c);
		else
			return chr(c + 96);
	}
}

void XonoticCharmap_configureXonoticCharmap(entity me, entity theTextbox)
{
	me.controlledTextbox = theTextbox;
	me.configureImage(me, me.image);
}

float XonoticCharmap_mouseMove(entity me, vector coords)
{
	float x, y, c;
	x = floor(coords_x * 16);
	y = floor(coords_y * 10);
	if(x < 0 || y < 0 || x >= 16 || y >= 10)
	{
		me.mouseSelectedCharacterCell = -1;
		return 0;
	}
	c = y * 16 + x;
	if(c != me.mouseSelectedCharacterCell || me.mouseSelectedCharacterCell != me.selectedCharacterCell)
		me.mouseSelectedCharacterCell = me.selectedCharacterCell = c;
	return 1;
}
float XonoticCharmap_mouseDrag(entity me, vector coords)
{
	return me.mouseMove(me, coords);
}
float XonoticCharmap_mousePress(entity me, vector coords)
{
	me.mouseMove(me, coords);
	if(me.mouseSelectedCharacterCell >= 0)
	{
		me.pressed = 1;
		me.previouslySelectedCharacterCell = me.selectedCharacterCell;
	}
	return 1;
}
float XonoticCharmap_mouseRelease(entity me, vector coords)
{
	if(!me.pressed)
		return 0;
	me.mouseMove(me, coords);
	if(me.selectedCharacterCell == me.previouslySelectedCharacterCell)
		me.controlledTextbox.enterText(me.controlledTextbox, CharMap_CellToChar(me.selectedCharacterCell));
	me.pressed = 0;
	return 1;
}
float XonoticCharmap_keyDown(entity me, float key, float ascii, float shift)
{
	switch(key)
	{
		case K_LEFTARROW:
		case K_KP_LEFTARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 159, 160);
			return 1;
		case K_RIGHTARROW:
		case K_KP_RIGHTARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 1, 160);
			return 1;
		case K_UPARROW:
		case K_KP_UPARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 144, 160);
			return 1;
		case K_DOWNARROW:
		case K_KP_DOWNARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 16, 160);
			return 1;
		case K_HOME:
		case K_KP_HOME:
			me.selectedCharacterCell = 0;
			return 1;
		case K_END:
		case K_KP_END:
			me.selectedCharacterCell = 159;
			return 1;
		case K_SPACE:
		case K_ENTER:
		case K_KP_ENTER:
		case K_INS:
		case K_KP_INS:
			me.controlledTextbox.enterText(me.controlledTextbox, CharMap_CellToChar(me.selectedCharacterCell));
			return 1;
		default:
			return me.controlledTextbox.keyDown(me.controlledTextbox, key, ascii, shift);
	}
}
void XonoticCharmap_focusLeave(entity me)
{
	me.controlledTextbox.saveCvars(me.controlledTextbox);
}
void XonoticCharmap_draw(entity me)
{
	if(me.focused)
	{
		if(!me.pressed || (me.selectedCharacterCell == me.previouslySelectedCharacterCell))
		{
			vector c;
			c = eX * (mod(me.selectedCharacterCell, 16) / 16.0);
			c += eY * (floor(me.selectedCharacterCell / 16.0) / 10.0);
			draw_Picture(c, me.image2, '0.0625 0.1 0', '1 1 1', 1);
		}
	}
	SUPER(XonoticCharmap).draw(me);
}
#endif
