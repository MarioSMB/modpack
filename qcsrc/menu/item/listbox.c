#ifdef INTERFACE
CLASS(ListBox) EXTENDS(Item)
	METHOD(ListBox, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(ListBox, configureListBox, void(entity, float, float))
	METHOD(ListBox, draw, void(entity))
	METHOD(ListBox, keyDown, float(entity, float, float, float))
	METHOD(ListBox, mousePress, float(entity, vector))
	METHOD(ListBox, mouseDrag, float(entity, vector))
	METHOD(ListBox, mouseRelease, float(entity, vector))
	METHOD(ListBox, focusLeave, void(entity))
	ATTRIB(ListBox, focusable, float, 1)
	ATTRIB(ListBox, selectedItem, float, 0)
	ATTRIB(ListBox, size, vector, '0 0 0')
	ATTRIB(ListBox, origin, vector, '0 0 0')
	ATTRIB(ListBox, scrollPos, float, 0) // measured in window heights, fixed when needed
	ATTRIB(ListBox, previousValue, float, 0)
	ATTRIB(ListBox, pressed, float, 0) // 0 = normal, 1 = scrollbar dragging, 2 = item dragging, 3 = released
	ATTRIB(ListBox, pressOffset, float, 0)

	METHOD(ListBox, updateControlTopBottom, void(entity))
	ATTRIB(ListBox, controlTop, float, 0)
	ATTRIB(ListBox, controlBottom, float, 0)
	ATTRIB(ListBox, controlWidth, float, 0)
	ATTRIB(ListBox, dragScrollTimer, float, 0)
	ATTRIB(ListBox, dragScrollPos, vector, '0 0 0')

	ATTRIB(ListBox, src, string, string_null) // scrollbar
	ATTRIB(ListBox, color, vector, '1 1 1')
	ATTRIB(ListBox, color2, vector, '1 1 1')
	ATTRIB(ListBox, colorC, vector, '1 1 1')
	ATTRIB(ListBox, colorF, vector, '1 1 1')
	ATTRIB(ListBox, tolerance, vector, '0 0 0') // drag tolerance
	ATTRIB(ListBox, scrollbarWidth, float, 0) // pixels
	ATTRIB(ListBox, nItems, float, 42)
	ATTRIB(ListBox, itemHeight, float, 0)
	ATTRIB(ListBox, colorBG, vector, '0 0 0')
	ATTRIB(ListBox, alphaBG, float, 0)
	METHOD(ListBox, drawListBoxItem, void(entity, float, vector, float)) // item number, width/height, selected
	METHOD(ListBox, clickListBoxItem, void(entity, float, vector)) // item number, relative clickpos
	METHOD(ListBox, setSelected, void(entity, float))
ENDCLASS(ListBox)
#endif

#ifdef IMPLEMENTATION
void ListBox_setSelected(entity me, float i)
{
	me.selectedItem = floor(0.5 + bound(0, i, me.nItems - 1));
}
void ListBox_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(ListBox).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);
	me.controlWidth = me.scrollbarWidth / absSize_x;
}
void ListBox_configureListBox(entity me, float theScrollbarWidth, float theItemHeight)
{
	me.scrollbarWidth = theScrollbarWidth;
	me.itemHeight = theItemHeight;
}
float ListBox_keyDown(entity me, float key, float ascii, float shift)
{
	me.dragScrollTimer = time;
	if(key == K_MWHEELUP)
	{
		me.scrollPos = max(me.scrollPos - 0.5, 0);
		me.setSelected(me, min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1)));
	}
	else if(key == K_MWHEELDOWN)
	{
		me.scrollPos = min(me.scrollPos + 0.5, me.nItems * me.itemHeight - 1);
		me.setSelected(me, max(me.selectedItem, ceil(me.scrollPos / me.itemHeight)));
	}
	else if(key == K_PGUP || key == K_KP_PGUP)
		me.setSelected(me, me.selectedItem - 1 / me.itemHeight);
	else if(key == K_PGDN || key == K_KP_PGDN)
		me.setSelected(me, me.selectedItem + 1 / me.itemHeight);
	else if(key == K_UPARROW || key == K_KP_UPARROW)
		me.setSelected(me, me.selectedItem - 1);
	else if(key == K_DOWNARROW || key == K_KP_DOWNARROW)
		me.setSelected(me, me.selectedItem + 1);
	else if(key == K_HOME || key == K_KP_HOME)
	{
		me.scrollPos = 0;
		me.setSelected(me, 0);
	}
	else if(key == K_END || key == K_KP_END)
	{
		me.scrollPos = max(0, me.nItems * me.itemHeight - 1);
		me.setSelected(me, me.nItems - 1);
	}
	else
		return 0;
	return 1;
}
float ListBox_mouseDrag(entity me, vector pos)
{
	float hit;
	float i;
	me.updateControlTopBottom(me);
	me.dragScrollPos = pos;
	if(me.pressed == 1)
	{
		hit = 1;
		if(pos_x < 1 - me.controlWidth - me.tolerance_y * me.controlWidth) hit = 0;
		if(pos_y < 0 - me.tolerance_x) hit = 0;
		if(pos_x >= 1 + me.tolerance_y * me.controlWidth) hit = 0;
		if(pos_y >= 1 + me.tolerance_x) hit = 0;
		if(hit)
		{
			// calculate new pos to v
			float d;
			d = (pos_y - me.pressOffset) / (1 - (me.controlBottom - me.controlTop)) * (me.nItems * me.itemHeight - 1);
			me.scrollPos = me.previousValue + d;
		}
		else
			me.scrollPos = me.previousValue;
		me.scrollPos = min(me.scrollPos, me.nItems * me.itemHeight - 1);
		me.scrollPos = max(me.scrollPos, 0);
		i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
		i = max(i, ceil(me.scrollPos / me.itemHeight));
		me.setSelected(me, i);
	}
	else if(me.pressed == 2)
	{
		me.setSelected(me, floor((me.scrollPos + pos_y) / me.itemHeight));
	}
	return 1;
}
float ListBox_mousePress(entity me, vector pos)
{
	if(pos_x < 0) return 0;
	if(pos_y < 0) return 0;
	if(pos_x >= 1) return 0;
	if(pos_y >= 1) return 0;
	me.dragScrollPos = pos;
	me.updateControlTopBottom(me);
	me.dragScrollTimer = time;
	if(pos_x >= 1 - me.controlWidth)
	{
		// if hit, set me.pressed, otherwise scroll by one page
		if(pos_y < me.controlTop)
		{
			// page up
			me.scrollPos = max(me.scrollPos - 1, 0);
			me.setSelected(me, min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1)));
		}
		else if(pos_y > me.controlBottom)
		{
			// page down
			me.scrollPos = min(me.scrollPos + 1, me.nItems * me.itemHeight - 1);
			me.setSelected(me, max(me.selectedItem, ceil(me.scrollPos / me.itemHeight)));
		}
		else
		{
			me.pressed = 1;
			me.pressOffset = pos_y;
			me.previousValue = me.scrollPos;
		}
	}
	else
	{
		// continue doing that while dragging (even when dragging outside). When releasing, forward the click to the then selected item.
		me.pressed = 2;
		// an item has been clicked. Select it, ...
		me.setSelected(me, floor((me.scrollPos + pos_y) / me.itemHeight));
	}
	return 1;
}
float ListBox_mouseRelease(entity me, vector pos)
{
	if(me.pressed == 1)
	{
		// slider dragging mode
		// in that case, nothing happens on releasing
	}
	else if(me.pressed == 2)
	{
		me.pressed = 3; // do that here, so setSelected can know the mouse has been released
		// item dragging mode
		// select current one one last time...
		me.setSelected(me, floor((me.scrollPos + pos_y) / me.itemHeight));
		// and give it a nice click event
		if(me.nItems > 0)
		{
			me.clickListBoxItem(me, me.selectedItem, globalToBox(pos, eY * (me.selectedItem * me.itemHeight - me.scrollPos), eX * (1 - me.controlWidth) + eY * me.itemHeight));
		}
	}
	me.pressed = 0;
	return 1;
}
void ListBox_focusLeave(entity me)
{
	// Reset the var pressed in case listbox loses focus
	// by a mouse click on an item of the list
	// for example showing a dialog on right click
	me.pressed = 0;
}
void ListBox_updateControlTopBottom(entity me)
{
	float f;
	// scrollPos is in 0..1 and indicates where the "page" currently shown starts.
	if(me.nItems * me.itemHeight <= 1)
	{
		// we don't need no stinkin' scrollbar, we don't need no view control...
		me.controlTop = 0;
		me.controlBottom = 1;
		me.scrollPos = 0;
	}
	else
	{
		if(frametime) // only do this in draw frames
		{
			if(me.dragScrollTimer < time)
			{
				float save;
				save = me.scrollPos;
				// if selected item is below listbox, increase scrollpos so it is in
				me.scrollPos = max(me.scrollPos, me.selectedItem * me.itemHeight - 1 + me.itemHeight);
				// if selected item is above listbox, decrease scrollpos so it is in
				me.scrollPos = min(me.scrollPos, me.selectedItem * me.itemHeight);
				if(me.scrollPos != save)
					me.dragScrollTimer = time + 0.2;
			}
		}
		// if scroll pos is below end of list, fix it
		me.scrollPos = min(me.scrollPos, me.nItems * me.itemHeight - 1);
		// if scroll pos is above beginning of list, fix it
		me.scrollPos = max(me.scrollPos, 0);
		// now that we know where the list is scrolled to, find out where to draw the control
		me.controlTop = max(0, me.scrollPos / (me.nItems * me.itemHeight));
		me.controlBottom = min((me.scrollPos + 1) / (me.nItems * me.itemHeight), 1);

		float minfactor;
		minfactor = 1 * me.controlWidth / me.size_y * me.size_x;
		f = me.controlBottom - me.controlTop;
		if(f < minfactor) // FIXME good default?
		{
			// f * X + 1 * (1-X) = minfactor
			// (f - 1) * X + 1 = minfactor
			// (f - 1) * X = minfactor - 1
			// X = (minfactor - 1) / (f - 1)
			f = (minfactor - 1) / (f - 1);
			me.controlTop = me.controlTop * f + 0 * (1 - f);
			me.controlBottom = me.controlBottom * f + 1 * (1 - f);
		}
	}
}
void ListBox_draw(entity me)
{
	float i;
	vector absSize, fillSize = '0 0 0';
	vector oldshift, oldscale;
	if(me.pressed == 2)
		me.mouseDrag(me, me.dragScrollPos); // simulate mouseDrag event
	me.updateControlTopBottom(me);
	fillSize_x = (1 - me.controlWidth);
	if(me.alphaBG)
		draw_Fill('0 0 0', '0 1 0' + fillSize, me.colorBG, me.alphaBG);
	if(me.controlWidth)
	{
		draw_VertButtonPicture(eX * (1 - me.controlWidth), strcat(me.src, "_s"), eX * me.controlWidth + eY, me.color2, 1);
		if(me.nItems * me.itemHeight > 1)
		{
			vector o, s;
			o = eX * (1 - me.controlWidth) + eY * me.controlTop;
			s = eX * me.controlWidth + eY * (me.controlBottom - me.controlTop);
			if(me.pressed == 1)
				draw_VertButtonPicture(o, strcat(me.src, "_c"), s, me.colorC, 1);
			else if(me.focused)
				draw_VertButtonPicture(o, strcat(me.src, "_f"), s, me.colorF, 1);
			else
				draw_VertButtonPicture(o, strcat(me.src, "_n"), s, me.color, 1);
		}
	}
	draw_SetClip();
	oldshift = draw_shift;
	oldscale = draw_scale;
	absSize = boxToGlobalSize(me.size, eX * (1 - me.controlWidth) + eY * me.itemHeight);
	draw_scale = boxToGlobalSize(eX * (1 - me.controlWidth) + eY * me.itemHeight, oldscale);
	for(i = floor(me.scrollPos / me.itemHeight); i < me.nItems; ++i)
	{
		float y;
		y = i * me.itemHeight - me.scrollPos;
		if(y >= 1)
			break;
		draw_shift = boxToGlobal(eY * y, oldshift, oldscale);
		me.drawListBoxItem(me, i, absSize, (me.selectedItem == i));
	}
	draw_ClearClip();

	draw_shift = oldshift;
	draw_scale = oldscale;
	SUPER(ListBox).draw(me);
}

void ListBox_clickListBoxItem(entity me, float i, vector where)
{
	// itemclick, itemclick, does whatever itemclick does
}

void ListBox_drawListBoxItem(entity me, float i, vector absSize, float selected)
{
	draw_Text('0 0 0', sprintf(_("Item %d"), i), eX * (8 / absSize_x) + eY * (8 / absSize_y), (selected ? '0 1 0' : '1 1 1'), 1, 0);
}
#endif
