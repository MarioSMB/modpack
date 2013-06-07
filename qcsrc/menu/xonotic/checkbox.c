#ifdef INTERFACE
CLASS(XonoticCheckBox) EXTENDS(CheckBox)
	METHOD(XonoticCheckBox, configureXonoticCheckBox, void(entity, float, float, string, string))
	METHOD(XonoticCheckBox, setChecked, void(entity, float))
	ATTRIB(XonoticCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticCheckBox, image, string, SKINGFX_CHECKBOX)
	ATTRIB(XonoticCheckBox, yesValue, float, 1)
	ATTRIB(XonoticCheckBox, noValue, float, 0)

	ATTRIB(XonoticCheckBox, color, vector, SKINCOLOR_CHECKBOX_N)
	ATTRIB(XonoticCheckBox, colorC, vector, SKINCOLOR_CHECKBOX_C)
	ATTRIB(XonoticCheckBox, colorF, vector, SKINCOLOR_CHECKBOX_F)
	ATTRIB(XonoticCheckBox, colorD, vector, SKINCOLOR_CHECKBOX_D)

	ATTRIB(XonoticCheckBox, cvarName, string, string_null)
	METHOD(XonoticCheckBox, loadCvars, void(entity))
	METHOD(XonoticCheckBox, saveCvars, void(entity))

	ATTRIB(XonoticCheckBox, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticCheckBox, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(XonoticCheckBox)
entity makeXonoticCheckBox(float, string, string);
entity makeXonoticCheckBoxEx(float, float, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticCheckBox(float isInverted, string theCvar, string theText)
{
	float y, n;
	if(isInverted > 1)
	{
		n = isInverted - 1;
		y = -n;
	}
	else if(isInverted < -1)
	{
		n = isInverted + 1;
		y = -n;
	}
	else if(isInverted == 1)
	{
		n = 1;
		y = 0;
	}
	else
	{
		n = 0;
		y = 1;
	}
	return makeXonoticCheckBoxEx(y, n, theCvar, theText);
}
entity makeXonoticCheckBoxEx(float theYesValue, float theNoValue, string theCvar, string theText)
{
	entity me;
	me = spawnXonoticCheckBox();
	me.configureXonoticCheckBox(me, theYesValue, theNoValue, theCvar, theText);
	return me;
}
void XonoticCheckBox_configureXonoticCheckBox(entity me, float theYesValue, float theNoValue, string theCvar, string theText)
{
	me.yesValue = theYesValue;
	me.noValue = theNoValue;
	me.checked = 0;
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureCheckBox(me, theText, me.fontSize, me.image);
}
void XonoticCheckBox_setChecked(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void XonoticCheckBox_loadCvars(entity me)
{
	float m, d;

	if not(me.cvarName)
		return;

	m = (me.yesValue + me.noValue) * 0.5;
	d = (cvar(me.cvarName) - m) / (me.yesValue - m);
	me.checked = (d > 0);
}
void XonoticCheckBox_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
		cvar_set(me.cvarName, ftos(me.yesValue));
	else
		cvar_set(me.cvarName, ftos(me.noValue));
}
#endif
