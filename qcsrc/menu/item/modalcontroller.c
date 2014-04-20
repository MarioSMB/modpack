#ifdef INTERFACE
CLASS(ModalController) EXTENDS(Container)
	METHOD(ModalController, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(ModalController, draw, void(entity))
	METHOD(ModalController, addItem, void(entity, entity, vector, vector, float))
	METHOD(ModalController, showChild, void(entity, entity, vector, vector, float))
	METHOD(ModalController, hideChild, void(entity, entity, float))
	METHOD(ModalController, hideAll, void(entity, float))
	METHOD(ModalController, addItem, void(entity, entity, vector, vector, float))
	METHOD(ModalController, addTab, void(entity, entity, entity))

	METHOD(ModalController, initializeDialog, void(entity, entity))

	METHOD(ModalController, switchState, void(entity, entity, float, float))
	ATTRIB(ModalController, origin, vector, '0 0 0')
	ATTRIB(ModalController, size, vector, '0 0 0')
	ATTRIB(ModalController, previousButton, entity, NULL)
	ATTRIB(ModalController, fadedAlpha, float, 0.3)
ENDCLASS(ModalController)

.entity tabSelectingButton;
.vector origin;
.vector size;
void TabButton_Click(entity button, entity tab); // assumes a button has set the above fields to its own absolute origin, its size, and the tab to activate
void DialogOpenButton_Click(entity button, entity tab); // assumes a button has set the above fields to its own absolute origin, its size, and the tab to activate
void DialogOpenButton_Click_withCoords(entity button, entity tab, vector theOrigin, vector theSize);
void DialogCloseButton_Click(entity button, entity tab); // assumes a button has set the above fields to the tab to close
#endif

#ifdef IMPLEMENTATION

// modal dialog controller
// handles a stack of dialog elements
// each element can have one of the following states:
//   0: hidden (fading out)
//   1: visible (zooming in)
//   2: greyed out (inactive)
// While an animation is running, no item has focus. When an animation is done,
// the topmost item gets focus.
// The items are assumed to be added in overlapping order, that is, the lowest
// window must get added first.
//
// Possible uses:
// - to control a modal dialog:
//   - show modal dialog: me.showChild(me, childItem, buttonAbsOrigin, buttonAbsSize, 0) // childItem also gets focus
//   - dismiss modal dialog: me.hideChild(me, childItem, 0) // childItem fades out and relinquishes focus
//   - show first screen in m_show: me.hideAll(me, 1); me.showChild(me, me.firstChild, '0 0 0', '0 0 0', 1);
// - to show a temporary dialog instead of the menu (teamselect): me.hideAll(me, 1); me.showChild(me, teamSelectDialog, '0 0 0', '0 0 0', 1);
// - as a tabbed dialog control:
//   - to initialize: me.hideAll(me, 1); me.showChild(me, me.firstChild, '0 0 0', '0 0 0', 1);
//   - to show a tab: me.hideChild(me, currentTab, 0); me.showChild(me, newTab, buttonAbsOrigin, buttonAbsSize, 0);

.vector ModalController_initialSize;
.vector ModalController_initialOrigin;
.vector ModalController_initialFontScale;
.float ModalController_initialAlpha;
.vector ModalController_buttonSize;
.vector ModalController_buttonOrigin;
.float ModalController_state;
.float ModalController_factor;
.entity ModalController_controllingButton;

void ModalController_initializeDialog(entity me, entity root)
{
	me.hideAll(me, 1);
	me.showChild(me, root, '0 0 0', '0 0 0', 1); // someone else animates for us
}

void TabButton_Click(entity button, entity tab)
{
	if(tab.ModalController_state == 1)
		return;
	tab.parent.hideAll(tab.parent, 0);
	button.forcePressed = 1;
	tab.ModalController_controllingButton = button;
	tab.parent.showChild(tab.parent, tab, button.origin, button.size, 0);
}

void DialogOpenButton_Click(entity button, entity tab)
{
	DialogOpenButton_Click_withCoords(button, tab, button.origin, button.size);
}

void DialogOpenButton_Click_withCoords(entity button, entity tab, vector theOrigin, vector theSize)
{
	if(tab.ModalController_state)
		return;
	if(button)
		button.forcePressed = 1;
	tab.ModalController_controllingButton = button;
	tab.parent.showChild(tab.parent, tab, theOrigin, theSize, 0);
}

void DialogCloseButton_Click(entity button, entity tab)
{
	tab.parent.hideChild(tab.parent, tab, 0);
}

void ModalController_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.resizeNotifyLie(me, relOrigin, relSize, absOrigin, absSize, ModalController_initialOrigin, ModalController_initialSize, ModalController_initialFontScale);
}

void ModalController_switchState(entity me, entity other, float state, float skipAnimation)
{
	float previousState;
	previousState = other.ModalController_state;
	if(state == previousState && !skipAnimation)
		return;
	other.ModalController_state = state;
	switch(state)
	{
		case 0:
			other.ModalController_factor = 1 - other.Container_alpha / other.ModalController_initialAlpha;
			// fading out
			break;
		case 1:
			other.ModalController_factor = other.Container_alpha / other.ModalController_initialAlpha;
			if(previousState == 0 && !skipAnimation)
			{
				other.Container_origin = other.ModalController_buttonOrigin;
				other.Container_size = other.ModalController_buttonSize;
			}
			// zooming in
			break;
		case 2:
			other.ModalController_factor = bound(0, (1 - other.Container_alpha / other.ModalController_initialAlpha) / me.fadedAlpha, 1);
			// fading out halfway
			break;
	}
	if(skipAnimation)
		other.ModalController_factor = 1;
}

void ModalController_draw(entity me)
{
	entity e;
	entity front;
	float animating;
	float f; // animation factor
	float df; // animation step size
	float prevFactor, targetFactor;
	vector targetOrigin, targetSize; float targetAlpha;
	vector fs;
	animating = 0;

	front = world;
	for(e = me.firstChild; e; e = e.nextSibling)
		if(e.ModalController_state)
		{
			if(front)
				me.switchState(me, front, 2, 0);
			front = e;
		}
	if(front)
		me.switchState(me, front, 1, 0);

	df = frametime * 3; // animation speed

	for(e = me.firstChild; e; e = e.nextSibling)
	{
		f = (e.ModalController_factor = min(1, e.ModalController_factor + df));
		if(e.ModalController_state)
			if(f < 1)
				animating = 1;

		if(f < 1)
		{
			prevFactor   = (1 - f) / (1 - f + df);
			targetFactor =     df  / (1 - f + df);
		}
		else
		{
			prevFactor = 0;
			targetFactor = 1;
		}

		if(e.ModalController_state == 2)
		{
			// fading out partially
			targetOrigin = e.Container_origin; // stay as is
			targetSize = e.Container_size; // stay as is
			targetAlpha = me.fadedAlpha * e.ModalController_initialAlpha;
		}
		else if(e.ModalController_state == 1)
		{
			// zooming in
			targetOrigin = e.ModalController_initialOrigin;
			targetSize = e.ModalController_initialSize;
			targetAlpha = e.ModalController_initialAlpha;
		}
		else
		{
			// fading out
			if(f < 1)
				animating = 1;
			targetOrigin = e.Container_origin; // stay as is
			targetSize = e.Container_size; // stay as is
			targetAlpha = 0;
		}

		if(f == 1)
		{
			e.Container_origin = targetOrigin;
			e.Container_size = targetSize;
			me.setAlphaOf(me, e, targetAlpha);
		}
		else
		{
			e.Container_origin = e.Container_origin * prevFactor + targetOrigin * targetFactor;
			e.Container_size   = e.Container_size   * prevFactor + targetSize   * targetFactor;
			me.setAlphaOf(me, e, e.Container_alpha  * prevFactor + targetAlpha  * targetFactor);
		}
		// assume: o == to * f_prev + X * (1 - f_prev)
		// make:   o' = to * f  + X * (1 - f)
		// -->
		// X == (o - to * f_prev) / (1 - f_prev)
		// o' = to * f + (o - to * f_prev) / (1 - f_prev) * (1 - f)
		// --> (maxima)
		// o' = (to * (f - f_prev) + o * (1 - f)) / (1 - f_prev)

		fs = globalToBoxSize(e.Container_size, e.ModalController_initialSize);
		e.Container_fontscale_x = fs_x * e.ModalController_initialFontScale_x;
		e.Container_fontscale_y = fs_y * e.ModalController_initialFontScale_y;
	}
	if(animating || !me.focused)
		me.setFocus(me, NULL);
	else
		me.setFocus(me, front);
	SUPER(ModalController).draw(me);
}

void ModalController_addTab(entity me, entity other, entity tabButton)
{
	me.addItem(me, other, '0 0 0', '1 1 1', 1);
	tabButton.onClick = TabButton_Click;
	tabButton.onClickEntity = other;
	other.tabSelectingButton = tabButton;
	if(other == me.firstChild)
	{
		tabButton.forcePressed = 1;
		other.ModalController_controllingButton = tabButton;
		me.showChild(me, other, '0 0 0', '0 0 0', 1);
	}
}

void ModalController_addItem(entity me, entity other, vector theOrigin, vector theSize, float theAlpha)
{
	SUPER(ModalController).addItem(me, other, theOrigin, theSize, (other == me.firstChild) ? theAlpha : 0);
	other.ModalController_initialFontScale = other.Container_fontscale;
	other.ModalController_initialSize = other.Container_size;
	other.ModalController_initialOrigin = other.Container_origin;
	other.ModalController_initialAlpha = theAlpha; // hope Container never modifies this
	if(other.ModalController_initialFontScale == '0 0 0')
		other.ModalController_initialFontScale = '1 1 0';
}

void ModalController_showChild(entity me, entity other, vector theOrigin, vector theSize, float skipAnimation)
{
	if(other.ModalController_state == 0 || skipAnimation)
	{
		me.setFocus(me, NULL);
		if(!skipAnimation)
		{
			other.ModalController_buttonOrigin = globalToBox(theOrigin, me.origin, me.size);
			other.ModalController_buttonSize = globalToBoxSize(theSize, me.size);
		}
		me.switchState(me, other, 1, skipAnimation);
	} // zoom in from button (factor increases)
}

void ModalController_hideAll(entity me, float skipAnimation)
{
	entity e;
	for(e = me.firstChild; e; e = e.nextSibling)
		me.hideChild(me, e, skipAnimation);
}

void ModalController_hideChild(entity me, entity other, float skipAnimation)
{
	if(other.ModalController_state || skipAnimation)
	{
		me.setFocus(me, NULL);
		me.switchState(me, other, 0, skipAnimation);
		if(other.ModalController_controllingButton)
		{
			other.ModalController_controllingButton.forcePressed = 0;
			other.ModalController_controllingButton = NULL;
		}
	} // just alpha fade out (factor increases and decreases alpha)
}
#endif
