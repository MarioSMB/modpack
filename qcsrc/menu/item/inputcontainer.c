#ifdef INTERFACE
CLASS(InputContainer) EXTENDS(Container)
	METHOD(InputContainer, keyDown, float(entity, float, float, float))
	METHOD(InputContainer, mouseMove, float(entity, vector))
	METHOD(InputContainer, mousePress, float(entity, vector))
	METHOD(InputContainer, mouseRelease, float(entity, vector))
	METHOD(InputContainer, mouseDrag, float(entity, vector))
	METHOD(InputContainer, focusLeave, void(entity))
	METHOD(InputContainer, resizeNotify, void(entity, vector, vector, vector, vector))

	METHOD(InputContainer, _changeFocusXY, float(entity, vector))
	ATTRIB(InputContainer, mouseFocusedChild, entity, NULL)
	ATTRIB(InputContainer, isTabRoot, float, 0)
ENDCLASS(InputContainer)
#endif

#ifdef IMPLEMENTATION
void InputContainer_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(InputContainer).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);
	/*
	if(me.parent.instanceOfInputContainer)
		me.isTabRoot = 0;
	else
		me.isTabRoot = 1;
	*/
}

void InputContainer_focusLeave(entity me)
{
	SUPER(InputContainer).focusLeave(me);
	me.mouseFocusedChild = NULL;
}

float InputContainer_keyDown(entity me, float scan, float ascii, float shift)
{
	entity f, ff;
	if(SUPER(InputContainer).keyDown(me, scan, ascii, shift))
		return 1;
	if(scan == K_ESCAPE)
	{
		f = me.focusedChild;
		if(f)
		{
			me.setFocus(me, NULL);
			return 1;
		}
		return 0;
	}
	if(scan == K_TAB)
	{
		f = me.focusedChild;
		if(shift & S_SHIFT)
		{
			if(f)
			{
				for(ff = f.prevSibling; ff; ff = ff.prevSibling)
				{
					if (!ff.focusable)
						continue;
					me.setFocus(me, ff);
					return 1;
				}
			}
			if(!f || me.isTabRoot)
			{
				for(ff = me.lastChild; ff; ff = ff.prevSibling)
				{
					if (!ff.focusable)
						continue;
					me.setFocus(me, ff);
					return 1;
				}
				return 0; // AIIIIEEEEE!
			}
		}
		else
		{
			if(f)
			{
				for(ff = f.nextSibling; ff; ff = ff.nextSibling)
				{
					if (!ff.focusable)
						continue;
					me.setFocus(me, ff);
					return 1;
				}
			}
			if(!f || me.isTabRoot)
			{
				for(ff = me.firstChild; ff; ff = ff.nextSibling)
				{
					if (!ff.focusable)
						continue;
					me.setFocus(me, ff);
					return 1;
				}
				return 0; // AIIIIEEEEE!
			}
		}
	}
	return 0;
}

float InputContainer__changeFocusXY(entity me, vector pos)
{
	entity e, ne;
	e = me.mouseFocusedChild;
	ne = me.itemFromPoint(me, pos);
	if(ne)
		if (!ne.focusable)
			ne = NULL;
	me.mouseFocusedChild = ne;
	if(ne)
		if(ne != e)
		{
			me.setFocus(me, ne);
			if(ne.instanceOfInputContainer)
			{
				ne.focusedChild = NULL;
				ne._changeFocusXY(e, globalToBox(pos, ne.Container_origin, ne.Container_size));
			}
		}
	return (ne != NULL);
}

float InputContainer_mouseDrag(entity me, vector pos)
{
	if(SUPER(InputContainer).mouseDrag(me, pos))
		return 1;
	if(pos_x >= 0 && pos_y >= 0 && pos_x < 1 && pos_y < 1)
		return 1;
	return 0;
}
float InputContainer_mouseMove(entity me, vector pos)
{
	if(me.mouseFocusedChild != me.focusedChild) // if the keyboard moved the focus away
		me.mouseFocusedChild = NULL; // force focusing
	if(me._changeFocusXY(me, pos))
		if(SUPER(InputContainer).mouseMove(me, pos))
			return 1;
	if(pos_x >= 0 && pos_y >= 0 && pos_x < 1 && pos_y < 1)
		return 1;
	return 0;
}
float InputContainer_mousePress(entity me, vector pos)
{
	me.mouseFocusedChild = NULL; // force focusing
	if(me._changeFocusXY(me, pos))
		if(SUPER(InputContainer).mousePress(me, pos))
			return 1;
	if(pos_x >= 0 && pos_y >= 0 && pos_x < 1 && pos_y < 1)
		return 1;
	return 0;
}
float InputContainer_mouseRelease(entity me, vector pos)
{
	SUPER(InputContainer).mouseRelease(me, pos); // return value?
	if(me.focused) // am I still eligible for this? (UGLY HACK, but a mouse event could have changed focus away)
		if(me._changeFocusXY(me, pos))
			return 1;
	if(pos_x >= 0 && pos_y >= 0 && pos_x < 1 && pos_y < 1)
		return 1;
	return 0;
}
#endif
