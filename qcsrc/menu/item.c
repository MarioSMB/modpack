#ifdef INTERFACE
CLASS(Item) EXTENDS(Object)
	METHOD(Item, draw, void(entity))
	METHOD(Item, keyDown, float(entity, float, float, float))
	METHOD(Item, keyUp, float(entity, float, float, float))
	METHOD(Item, mouseMove, float(entity, vector))
	METHOD(Item, mousePress, float(entity, vector))
	METHOD(Item, mouseDrag, float(entity, vector))
	METHOD(Item, mouseRelease, float(entity, vector))
	METHOD(Item, focusEnter, void(entity))
	METHOD(Item, focusLeave, void(entity))
	METHOD(Item, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Item, relinquishFocus, void(entity))
	METHOD(Item, showNotify, void(entity))
	METHOD(Item, hideNotify, void(entity))
	METHOD(Item, toString, string(entity))
	METHOD(Item, destroy, void(entity))
	ATTRIB(Item, focused, float, 0)
	ATTRIB(Item, focusable, float, 0)
	ATTRIB(Item, parent, entity, NULL)
	ATTRIB(Item, preferredFocusPriority, float, 0)
	ATTRIB(Item, origin, vector, '0 0 0')
	ATTRIB(Item, size, vector, '0 0 0')
	ATTRIB(Item, tooltip, string, string_null)
ENDCLASS(Item)
#endif

#ifdef IMPLEMENTATION
void Item_destroy(entity me)
{
	// free memory associated with me
}

void Item_relinquishFocus(entity me)
{
	if(me.parent)
		if(me.parent.instanceOfContainer)
			me.parent.setFocus(me.parent, NULL);
}

void Item_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.origin = absOrigin;
	me.size = absSize;
}

float autocvar_menu_showboxes;
void Item_draw(entity me)
{
	if(autocvar_menu_showboxes)
	{
		vector rgb = '1 0 1';
		float a = fabs(autocvar_menu_showboxes);

		// don't draw containers and border images
		if(me.instanceOfContainer || me.instanceOfBorderImage)
		{
			rgb = '0 0 0';
			a = 0;
		}

#if 0
		// hack to detect multi drawing
		float r = random() * 3;
		if(r >= 2)
			rgb = '1 0 0';
		else if(r >= 1)
			rgb = '0 1 0';
		else
			rgb = '0 0 1';
#endif
		if(autocvar_menu_showboxes < 0)
		{
			draw_Fill('0 0 0', '0.5 0.5 0', rgb, a);
			draw_Fill('0.5 0.5 0', '0.5 0.5 0', rgb, a);
		}
		if(autocvar_menu_showboxes > 0)
		{
			draw_Fill('0 0 0', '1 1 0', rgb, a);
		}
	}
}

void Item_showNotify(entity me)
{
}

void Item_hideNotify(entity me)
{
}

float Item_keyDown(entity me, float scan, float ascii, float shift)
{
	return 0; // unhandled
}

float Item_keyUp(entity me, float scan, float ascii, float shift)
{
	return 0; // unhandled
}

float Item_mouseMove(entity me, vector pos)
{
	return 0; // unhandled
}

float Item_mousePress(entity me, vector pos)
{
	return 0; // unhandled
}

float Item_mouseDrag(entity me, vector pos)
{
	return 0; // unhandled
}

float Item_mouseRelease(entity me, vector pos)
{
	return 0; // unhandled
}

void Item_focusEnter(entity me)
{
}

void Item_focusLeave(entity me)
{
}

string Item_toString(entity me)
{
	return string_null;
}
#endif
