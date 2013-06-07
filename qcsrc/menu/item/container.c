#ifdef INTERFACE
CLASS(Container) EXTENDS(Item)
	METHOD(Container, draw, void(entity))
	METHOD(Container, keyUp, float(entity, float, float, float))
	METHOD(Container, keyDown, float(entity, float, float, float))
	METHOD(Container, mouseMove, float(entity, vector))
	METHOD(Container, mousePress, float(entity, vector))
	METHOD(Container, mouseDrag, float(entity, vector))
	METHOD(Container, mouseRelease, float(entity, vector))
	METHOD(Container, focusLeave, void(entity))
	METHOD(Container, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Container, resizeNotifyLie, void(entity, vector, vector, vector, vector, .vector, .vector, .vector))
	METHOD(Container, addItem, void(entity, entity, vector, vector, float))
	METHOD(Container, addItemCentered, void(entity, entity, vector, float))
	METHOD(Container, moveItemAfter, void(entity, entity, entity))
	METHOD(Container, removeItem, void(entity, entity))
	METHOD(Container, setFocus, void(entity, entity))
	METHOD(Container, setAlphaOf, void(entity, entity, float))
	METHOD(Container, itemFromPoint, entity(entity, vector))
	METHOD(Container, showNotify, void(entity))
	METHOD(Container, hideNotify, void(entity))
	METHOD(Container, preferredFocusedGrandChild, entity(entity))
	ATTRIB(Container, focusable, float, 0)
	ATTRIB(Container, firstChild, entity, NULL)
	ATTRIB(Container, lastChild, entity, NULL)
	ATTRIB(Container, focusedChild, entity, NULL)
	ATTRIB(Container, shown, float, 0)

	METHOD(Container, enterSubitem, void(entity, entity))
	METHOD(Container, enterLieSubitem, void(entity, vector, vector, vector, float))
	METHOD(Container, leaveSubitem, void(entity))
ENDCLASS(Container)
.entity nextSibling;
.entity prevSibling;
.float resized;
.vector Container_origin;
.vector Container_size;
.vector Container_fontscale;
.float Container_alpha;
.vector Container_save_shift;
.vector Container_save_scale;
.vector Container_save_fontscale;
.float Container_save_alpha;
#endif

#ifdef IMPLEMENTATION
void Container_enterSubitem(entity me, entity sub)
{
	me.enterLieSubitem(me, sub.Container_origin, sub.Container_size, sub.Container_fontscale, sub.Container_alpha);
}

void Container_enterLieSubitem(entity me, vector o, vector s, vector f, float a)
{
	me.Container_save_shift = draw_shift;
	me.Container_save_scale = draw_scale;
	me.Container_save_alpha = draw_alpha;
	me.Container_save_fontscale = draw_fontscale;

	draw_shift = boxToGlobal(o, draw_shift, draw_scale);
	draw_scale = boxToGlobalSize(s, draw_scale);
	if(f != '0 0 0')
		draw_fontscale = boxToGlobalSize(f, draw_fontscale);
	draw_alpha *= a;
}

void Container_leaveSubitem(entity me)
{
	draw_shift = me.Container_save_shift;
	draw_scale = me.Container_save_scale;
	draw_alpha = me.Container_save_alpha;
	draw_fontscale = me.Container_save_fontscale;
}

void Container_showNotify(entity me)
{
	entity e;
	if(me.shown)
		return;
	me.shown = 1;
	for(e = me.firstChild; e; e = e.nextSibling)
		if(e.Container_alpha > 0)
			e.showNotify(e);
}

void Container_hideNotify(entity me)
{
	entity e;
	if not(me.shown)
		return;
	me.shown = 0;
	for(e = me.firstChild; e; e = e.nextSibling)
		if(e.Container_alpha > 0)
			e.hideNotify(e);
}

void Container_setAlphaOf(entity me, entity other, float theAlpha)
{
	if(theAlpha <= 0)
	{
		if(other.Container_alpha > 0)
			other.hideNotify(other);
	}
	else // value > 0
	{
		if(other.Container_alpha <= 0)
			other.showNotify(other);
	}
	other.Container_alpha = theAlpha;
}

void Container_resizeNotifyLie(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize, .vector originField, .vector sizeField, .vector fontScaleField)
{
	entity e;
	vector o, s;
	float d;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		o = e.originField;
		s = e.sizeField;
		me.enterLieSubitem(me, o, s, e.fontScaleField, e.Container_alpha);
		e.resizeNotify(e, o, s, boxToGlobal(o, absOrigin, absSize), boxToGlobalSize(s, absSize));
		me.leaveSubitem(me);
	}
	do
	{
		d = 0;
		for(e = me.firstChild; e; e = e.nextSibling)
			if(e.resized)
			{
				e.resized = 0;
				d = 1;
				o = e.originField;
				s = e.sizeField;
				me.enterLieSubitem(me, o, s, e.fontScaleField, e.Container_alpha);
				e.resizeNotify(e, o, s, boxToGlobal(o, absOrigin, absSize), boxToGlobalSize(s, absSize));
				me.leaveSubitem(me);
			}
	}
	while(d);
	SUPER(Container).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);
}

void Container_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.resizeNotifyLie(me, relOrigin, relSize, absOrigin, absSize, Container_origin, Container_size, Container_fontscale);
}

entity Container_itemFromPoint(entity me, vector pos)
{
	entity e;
	vector o, s;
	for(e = me.lastChild; e; e = e.prevSibling)
	{
		o = e.Container_origin;
		s = e.Container_size;
		if(pos_x < o_x) continue;
		if(pos_y < o_y) continue;
		if(pos_x >= o_x + s_x) continue;
		if(pos_y >= o_y + s_y) continue;
		return e;
	}
	return NULL;
}

void Container_draw(entity me)
{
	entity e;

	me.focusable = 0;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if(e.focusable)
			me.focusable += 1;
		if(e.Container_alpha < 0.003) // can't change color values anyway
			continue;
		me.enterSubitem(me, e);
		e.draw(e);
		me.leaveSubitem(me);
	}

	SUPER(Container).draw(me);
}

void Container_focusLeave(entity me)
{
	me.setFocus(me, NULL);
}

float Container_keyUp(entity me, float scan, float ascii, float shift)
{
	entity f;
	float r;
	f = me.focusedChild;
	if(f)
	{
		me.enterSubitem(me, f);
		r = f.keyUp(f, scan, ascii, shift);
		me.leaveSubitem(me);
		return r;
	}
	return 0;
}

float Container_keyDown(entity me, float scan, float ascii, float shift)
{
	entity f;
	float r;
	f = me.focusedChild;
	if(f)
	{
		me.enterSubitem(me, f);
		r = f.keyDown(f, scan, ascii, shift);
		me.leaveSubitem(me);
		return r;
	}
	return 0;
}

float Container_mouseMove(entity me, vector pos)
{
	entity f;
	float r;
	f = me.focusedChild;
	if(f)
	{
		me.enterSubitem(me, f);
		r = f.mouseMove(f, globalToBox(pos, f.Container_origin, f.Container_size));
		me.leaveSubitem(me);
		return r;
	}
	return 0;
}
float Container_mousePress(entity me, vector pos)
{
	entity f;
	float r;
	f = me.focusedChild;
	if(f)
	{
		me.enterSubitem(me, f);
		r = f.mousePress(f, globalToBox(pos, f.Container_origin, f.Container_size));
		me.leaveSubitem(me);
		return r;
	}
	return 0;
}
float Container_mouseDrag(entity me, vector pos)
{
	entity f;
	float r;
	f = me.focusedChild;
	if(f)
	{
		me.enterSubitem(me, f);
		r = f.mouseDrag(f, globalToBox(pos, f.Container_origin, f.Container_size));
		me.leaveSubitem(me);
		return r;
	}
	return 0;
}
float Container_mouseRelease(entity me, vector pos)
{
	entity f;
	float r;
	f = me.focusedChild;
	if(f)
	{
		me.enterSubitem(me, f);
		r = f.mouseRelease(f, globalToBox(pos, f.Container_origin, f.Container_size));
		me.leaveSubitem(me);
		return r;
	}
	return 0;
}

void Container_addItemCentered(entity me, entity other, vector theSize, float theAlpha)
{
	me.addItem(me, other, '0.5 0.5 0' - 0.5 * theSize, theSize, theAlpha);
}

void Container_addItem(entity me, entity other, vector theOrigin, vector theSize, float theAlpha)
{
	if(other.parent)
		error("Can't add already added item!");

	if(other.focusable)
		me.focusable += 1;

	if(theSize_x > 1)
	{
		theOrigin_x -= 0.5 * (theSize_x - 1);
		theSize_x = 1;
	}
	if(theSize_y > 1)
	{
		theOrigin_y -= 0.5 * (theSize_y - 1);
		theSize_y = 1;
	}
	theOrigin_x = bound(0, theOrigin_x, 1 - theSize_x);
	theOrigin_y = bound(0, theOrigin_y, 1 - theSize_y);

	other.parent = me;
	other.Container_origin = theOrigin;
	other.Container_size = theSize;
	me.setAlphaOf(me, other, theAlpha);

	entity l;
	l = me.lastChild;

	if(l)
		l.nextSibling = other;
	else
		me.firstChild = other;

	other.prevSibling = l;
	other.nextSibling = NULL;
	me.lastChild = other;

	draw_NeedResizeNotify = 1;
}

void Container_removeItem(entity me, entity other)
{
	if(other.parent != me)
		error("Can't remove from wrong container!");

	if(other.focusable)
		me.focusable -= 1;

	other.parent = NULL;

	entity n, p;
	n = other.nextSibling;
	p = other.prevSibling;

	if(p)
		p.nextSibling = n;
	else
		me.firstChild = n;

	if(n)
		n.prevSibling = p;
	else
		me.lastChild = p;
}

void Container_setFocus(entity me, entity other)
{
	if(other)
		if not(me.focused)
			error("Trying to set focus in a non-focused control!");
	if(me.focusedChild == other)
		return;
	//print(etos(me), ": focus changes from ", etos(me.focusedChild), " to ", etos(other), "\n");
	if(me.focusedChild)
	{
		me.focusedChild.focused = 0;
		me.focusedChild.focusLeave(me.focusedChild);
	}
	if(other)
	{
		other.focused = 1;
		other.focusEnter(other);
	}
	me.focusedChild = other;
}

void Container_moveItemAfter(entity me, entity other, entity dest)
{
	// first: remove other from the chain
	entity n, p;

	if(other.parent != me)
		error("Can't move in wrong container!");

	n = other.nextSibling;
	p = other.prevSibling;

	if(p)
		p.nextSibling = n;
	else
		me.firstChild = n;

	if(n)
		n.prevSibling = p;
	else
		me.lastChild = p;
	
	// now other got removed. Insert it behind dest now.
	other.prevSibling = dest;
	if(dest)
		other.nextSibling = dest.nextSibling;
	else
		other.nextSibling = me.firstChild;

	if(dest)
		dest.nextSibling = other;
	else
		me.firstChild = other;

	if(other.nextSibling)
		other.nextSibling.prevSibling = other;
	else
		me.lastChild = other;
}

entity Container_preferredFocusedGrandChild(entity me)
{
	entity e, e2;
	entity best;

	best = NULL;

	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if(e.instanceOfContainer)
		{
			e2 = e.preferredFocusedGrandChild(e);
			if(e2)
				if(!best || best.preferredFocusPriority < e2.preferredFocusPriority)
					best = e2;
		}
		if(e)
			if(!best || best.preferredFocusPriority < e.preferredFocusPriority)
				best = e;
	}

	return best;
}
#endif
