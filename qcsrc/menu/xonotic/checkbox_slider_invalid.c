#ifdef INTERFACE
CLASS(XonoticSliderCheckBox) EXTENDS(CheckBox)
	METHOD(XonoticSliderCheckBox, configureXonoticSliderCheckBox, void(entity, float, float, entity, string))
	METHOD(XonoticSliderCheckBox, setChecked, void(entity, float))
	METHOD(XonoticSliderCheckBox, draw, void(entity))
	ATTRIB(XonoticSliderCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticSliderCheckBox, image, string, SKINGFX_CHECKBOX)

	ATTRIB(XonoticSliderCheckBox, color, vector, SKINCOLOR_CHECKBOX_N)
	ATTRIB(XonoticSliderCheckBox, colorC, vector, SKINCOLOR_CHECKBOX_C)
	ATTRIB(XonoticSliderCheckBox, colorF, vector, SKINCOLOR_CHECKBOX_F)
	ATTRIB(XonoticSliderCheckBox, colorD, vector, SKINCOLOR_CHECKBOX_D)

	ATTRIB(XonoticSliderCheckBox, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticSliderCheckBox, disabledAlpha, float, SKINALPHA_DISABLED)

	ATTRIB(XonoticSliderCheckBox, controlledSlider, entity, NULL)
	ATTRIB(XonoticSliderCheckBox, offValue, float, -1)
	ATTRIB(XonoticSliderCheckBox, inverted, float, 0)
	ATTRIB(XonoticSliderCheckBox, savedValue, float, -1)
ENDCLASS(XonoticSliderCheckBox)
entity makeXonoticSliderCheckBox(float, float, entity, string);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticSliderCheckBox(float theOffValue, float isInverted, entity theControlledSlider, string theText)
{
	entity me;
	me = spawnXonoticSliderCheckBox();
	me.configureXonoticSliderCheckBox(me, theOffValue, isInverted, theControlledSlider, theText);
	return me;
}
void XonoticSliderCheckBox_configureXonoticSliderCheckBox(entity me, float theOffValue, float isInverted, entity theControlledSlider, string theText)
{
	me.offValue = theOffValue;
	me.inverted = isInverted;
	me.checked = (theControlledSlider.value == theOffValue);
	if(theControlledSlider.value == median(theControlledSlider.valueMin, theControlledSlider.value, theControlledSlider.valueMax))
		me.savedValue = theControlledSlider.value;
	else
		me.savedValue = theControlledSlider.valueMin; 
	me.controlledSlider = theControlledSlider;
	me.configureCheckBox(me, theText, me.fontSize, me.image);
	me.tooltip = theControlledSlider.tooltip;
	me.cvarName = theControlledSlider.cvarName; // in case we want to display the cvar in the tooltip
}
void XonoticSliderCheckBox_draw(entity me)
{
	me.checked = ((me.controlledSlider.value == me.offValue) != me.inverted);
	if(me.controlledSlider.value == median(me.controlledSlider.valueMin, me.controlledSlider.value, me.controlledSlider.valueMax))
		me.savedValue = me.controlledSlider.value;
	SUPER(XonoticSliderCheckBox).draw(me);
}
void XonoticSliderCheckBox_setChecked(entity me, float val)
{
	if(me.checked == val)
		return;
	me.checked = val;
	if(val == me.inverted)
		me.controlledSlider.setValue(me.controlledSlider, median(me.controlledSlider.valueMin, me.savedValue, me.controlledSlider.valueMax));
	else
		me.controlledSlider.setValue(me.controlledSlider, me.offValue);
}

#endif
