#ifdef INTERFACE
CLASS(Nexposee) EXTENDS(Container)
	METHOD(Nexposee, draw, void(entity))
	METHOD(Nexposee, keyDown, float(entity, float, float, float))
	METHOD(Nexposee, keyUp, float(entity, float, float, float))
	METHOD(Nexposee, mousePress, float(entity, vector))
	METHOD(Nexposee, mouseMove, float(entity, vector))
	METHOD(Nexposee, mouseRelease, float(entity, vector))
	METHOD(Nexposee, mouseDrag, float(entity, vector))
	METHOD(Nexposee, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Nexposee, focusEnter, void(entity))
	METHOD(Nexposee, close, void(entity))

	ATTRIB(Nexposee, animationState, float, -1)
	ATTRIB(Nexposee, animationFactor, float, 0)
	ATTRIB(Nexposee, selectedChild, entity, NULL)
	ATTRIB(Nexposee, mouseFocusedChild, entity, NULL)
	METHOD(Nexposee, addItem, void(entity, entity, vector, vector, float))
	METHOD(Nexposee, calc, void(entity))
	METHOD(Nexposee, setNexposee, void(entity, entity, vector, float, float))
	ATTRIB(Nexposee, mousePosition, vector, '0 0 0')
	METHOD(Nexposee, pullNexposee, void(entity, entity, vector))
ENDCLASS(Nexposee)

void ExposeeCloseButton_Click(entity button, entity other); // un-exposees the current state
#endif

// animation states:
//   0 = thumbnails seen
//   1 = zooming in
//   2 = zoomed in
//   3 = zooming out
// animation factor: 0 = minimum theSize, 1 = maximum theSize

#ifdef IMPLEMENTATION

.vector Nexposee_initialSize;
.vector Nexposee_initialFontScale;
.vector Nexposee_initialOrigin;
.float Nexposee_initialAlpha;

.vector Nexposee_smallSize;
.vector Nexposee_smallOrigin;
.float Nexposee_smallAlpha;
.float Nexposee_mediumAlpha;
.vector Nexposee_scaleCenter;
.vector Nexposee_align;
.float Nexposee_animationFactor;

void Nexposee_close(entity me)
{
	// user must override this
}

void ExposeeCloseButton_Click(entity button, entity other)
{
	other.selectedChild = other.focusedChild;
	other.setFocus(other, NULL);
	other.animationState = 3;
}

void Nexposee_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.calc(me);
	me.resizeNotifyLie(me, relOrigin, relSize, absOrigin, absSize, Nexposee_initialOrigin, Nexposee_initialSize, Nexposee_initialFontScale);
}

void Nexposee_Calc_Scale(entity me, float scale)
{
	entity e;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		e.Nexposee_smallOrigin = (e.Nexposee_initialOrigin - e.Nexposee_scaleCenter) * scale + e.Nexposee_scaleCenter;
		e.Nexposee_smallSize = e.Nexposee_initialSize * scale;
		if(e.Nexposee_align_x > 0)
			e.Nexposee_smallOrigin_x = 1 - e.Nexposee_align_x * scale;
		if(e.Nexposee_align_x < 0)
			e.Nexposee_smallOrigin_x = -e.Nexposee_smallSize_x + e.Nexposee_align_x * scale;
		if(e.Nexposee_align_y > 0)
			e.Nexposee_smallOrigin_y = 1 - e.Nexposee_align_y * scale;
		if(e.Nexposee_align_y < 0)
			e.Nexposee_smallOrigin_y = -e.Nexposee_smallSize_y + e.Nexposee_align_y * scale;
	}
}

void Nexposee_calc(entity me)
{
	/*
	 * patented by Apple
	 * can't put that here ;)
	 */
	float scale;
	entity e, e2;
	vector emins, emaxs, e2mins, e2maxs;

	for(scale = 0.7;; scale *= 0.99)
	{
		Nexposee_Calc_Scale(me, scale);

		for(e = me.firstChild; e; e = e.nextSibling)
		{
			emins = e.Nexposee_smallOrigin;
			emaxs = emins + e.Nexposee_smallSize;
			for(e2 = e.nextSibling; e2; e2 = e2.nextSibling)
			{
				e2mins = e2.Nexposee_smallOrigin;
				e2maxs = e2mins + e2.Nexposee_smallSize;

				// two intervals [amins, amaxs] and [bmins, bmaxs] overlap if:
				//   amins < bmins < amaxs < bmaxs
				// for which suffices
				//   bmins < amaxs
				//   amins < bmaxs
				if((e2mins_x - emaxs_x) * (emins_x - e2maxs_x) > 0) // x overlap
					if((e2mins_y - emaxs_y) * (emins_y - e2maxs_y) > 0) // y overlap
					{
						goto have_overlap;
					}
			}
		}

		break;
:have_overlap
	}

	scale *= 0.95;

	Nexposee_Calc_Scale(me, scale);
}

void Nexposee_setNexposee(entity me, entity other, vector scalecenter, float a0, float a1)
{
	other.Nexposee_scaleCenter = scalecenter;
	other.Nexposee_smallAlpha = a0;
	me.setAlphaOf(me, other, a0);
	other.Nexposee_mediumAlpha = a1;
}

void Nexposee_draw(entity me)
{
	float a;
	float a0;
	entity e;
	float f;
	vector fs;

	if(me.animationState == -1)
	{
		me.animationState = 0;
	}

	f = min(1, frametime * 5);
	switch(me.animationState)
	{
		case 0:
			me.animationFactor = 0;
			break;
		case 1:
			me.animationFactor += f;
			if(me.animationFactor >= 1)
			{
				me.animationFactor = 1;
				me.animationState = 2;
				SUPER(Nexposee).setFocus(me, me.selectedChild);
			}
			break;
		case 2:
			me.animationFactor = 1;
			break;
		case 3:
			me.animationFactor -= f;
			me.mouseFocusedChild = me.itemFromPoint(me, me.mousePosition);
			if(me.animationFactor <= 0)
			{
				me.animationFactor = 0;
				me.animationState = 0;
				me.selectedChild = me.mouseFocusedChild;
			}
			break;
	}

	f = min(1, frametime * 10);
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if(e == me.selectedChild)
		{
			e.Container_origin = e.Nexposee_smallOrigin * (1 - me.animationFactor) + e.Nexposee_initialOrigin * me.animationFactor;
			e.Container_size = e.Nexposee_smallSize * (1 - me.animationFactor) + e.Nexposee_initialSize * me.animationFactor;
			e.Nexposee_animationFactor = me.animationFactor;
			a0 = e.Nexposee_mediumAlpha;
			if(me.animationState == 3)
				if(e != me.mouseFocusedChild)
					a0 = e.Nexposee_smallAlpha;
			a = a0 * (1 - me.animationFactor) + me.animationFactor;
		}
		else
		{
			// minimum theSize counts
			e.Container_origin = e.Nexposee_smallOrigin;
			e.Container_size = e.Nexposee_smallSize;
			e.Nexposee_animationFactor = 0;
			a = e.Nexposee_smallAlpha * (1 - me.animationFactor);
		}
		me.setAlphaOf(me, e, e.Container_alpha * (1 - f) + a * f);

		fs = globalToBoxSize(e.Container_size, e.Nexposee_initialSize);
		e.Container_fontscale_x = fs_x * e.Nexposee_initialFontScale_x;
		e.Container_fontscale_y = fs_y * e.Nexposee_initialFontScale_y;
	}

	SUPER(Nexposee).draw(me);
}

float Nexposee_mousePress(entity me, vector pos)
{
	if(me.animationState == 0)
	{
		me.mouseFocusedChild = NULL;
		Nexposee_mouseMove(me, pos);
		if(me.mouseFocusedChild)
		{
			me.animationState = 1;
			SUPER(Nexposee).setFocus(me, NULL);
		}
		else
			me.close(me);
		return 1;
	}
	else if(me.animationState == 2)
	{
		if (!(SUPER(Nexposee).mousePress(me, pos)))
		{
			me.animationState = 3;
			SUPER(Nexposee).setFocus(me, NULL);
		}
		return 1;
	}
	return 0;
}

float Nexposee_mouseRelease(entity me, vector pos)
{
	if(me.animationState == 2)
		return SUPER(Nexposee).mouseRelease(me, pos);
	return 0;
}

float Nexposee_mouseDrag(entity me, vector pos)
{
	if(me.animationState == 2)
		return SUPER(Nexposee).mouseDrag(me, pos);
	return 0;
}

float Nexposee_mouseMove(entity me, vector pos)
{
	entity e;
	me.mousePosition = pos;
	e = me.mouseFocusedChild;
	me.mouseFocusedChild = me.itemFromPoint(me, pos);
	if(me.animationState == 2)
		return SUPER(Nexposee).mouseMove(me, pos);
	if(me.animationState == 0)
	{
		if(me.mouseFocusedChild)
			if(me.mouseFocusedChild != e || me.mouseFocusedChild != me.selectedChild)
				me.selectedChild = me.mouseFocusedChild;
		return 1;
	}
	return 0;
}

float Nexposee_keyUp(entity me, float scan, float ascii, float shift)
{
	if(me.animationState == 2)
		return SUPER(Nexposee).keyUp(me, scan, ascii, shift);
	return 0;
}

float Nexposee_keyDown(entity me, float scan, float ascii, float shift)
{
	float nexposeeKey = 0;
	if(me.animationState == 2)
		if(SUPER(Nexposee).keyDown(me, scan, ascii, shift))
			return 1;
	if(scan == K_TAB)
	{
		if(me.animationState == 0)
		{
			if(shift & S_SHIFT)
			{
				if(me.selectedChild)
					me.selectedChild = me.selectedChild.prevSibling;
				if (!me.selectedChild)
					me.selectedChild = me.lastChild;
			}
			else
			{
				if(me.selectedChild)
					me.selectedChild = me.selectedChild.nextSibling;
				if (!me.selectedChild)
					me.selectedChild = me.firstChild;
			}
		}
	}
	switch(me.animationState)
	{
		default:
		case 0:
		case 3:
			nexposeeKey = ((scan == K_SPACE) || (scan == K_ENTER) || (scan == K_KP_ENTER));
			break;
		case 1:
		case 2:
			nexposeeKey = (scan == K_ESCAPE);
			break;
	}
	if(nexposeeKey)
	{
		switch(me.animationState)
		{
			default:
			case 0:
			case 3:
				me.animationState = 1;
				break;
			case 1:
			case 2:
				me.animationState = 3;
				break;
		}
		if(me.focusedChild)
			me.selectedChild = me.focusedChild;
		if (!me.selectedChild)
			me.animationState = 0;
		SUPER(Nexposee).setFocus(me, NULL);
		return 1;
	}
	return 0;
}

void Nexposee_addItem(entity me, entity other, vector theOrigin, vector theSize, float theAlpha)
{
	SUPER(Nexposee).addItem(me, other, theOrigin, theSize, theAlpha);
	other.Nexposee_initialFontScale = other.Container_fontscale;
	other.Nexposee_initialSize = other.Container_size;
	other.Nexposee_initialOrigin = other.Container_origin;
	other.Nexposee_initialAlpha = other.Container_alpha;
	if(other.Nexposee_initialFontScale == '0 0 0')
		other.Nexposee_initialFontScale = '1 1 0';
}

void Nexposee_focusEnter(entity me)
{
	if(me.animationState == 2)
		SUPER(Nexposee).setFocus(me, me.selectedChild);
}

void Nexposee_pullNexposee(entity me, entity other, vector theAlign)
{
	other.Nexposee_align = theAlign;
}
#endif
