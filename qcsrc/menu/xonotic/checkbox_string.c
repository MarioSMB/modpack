#ifdef INTERFACE
CLASS(XonoticCheckBoxString) EXTENDS(CheckBox)
	METHOD(XonoticCheckBoxString, configureXonoticCheckBoxString, void(entity, string, string, string, string))
	METHOD(XonoticCheckBoxString, setChecked, void(entity, float))
	ATTRIB(XonoticCheckBoxString, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticCheckBoxString, image, string, SKINGFX_CHECKBOX)
	ATTRIB(XonoticCheckBoxString, yesString, string, string_null)
	ATTRIB(XonoticCheckBoxString, noString, string, string_null)

	ATTRIB(XonoticCheckBoxString, color, vector, SKINCOLOR_CHECKBOX_N)
	ATTRIB(XonoticCheckBoxString, colorC, vector, SKINCOLOR_CHECKBOX_C)
	ATTRIB(XonoticCheckBoxString, colorF, vector, SKINCOLOR_CHECKBOX_F)
	ATTRIB(XonoticCheckBoxString, colorD, vector, SKINCOLOR_CHECKBOX_D)

	ATTRIB(XonoticCheckBoxString, cvarName, string, string_null)
	METHOD(XonoticCheckBoxString, loadCvars, void(entity))
	METHOD(XonoticCheckBoxString, saveCvars, void(entity))

	ATTRIB(XonoticCheckBoxString, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticCheckBoxString, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(XonoticCheckBoxString)
entity makeXonoticCheckBoxString(string, string, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticCheckBoxString(string theYesValue, string theNoValue, string theCvar, string theText)
{
	entity me;
	me = spawnXonoticCheckBoxString();
	me.configureXonoticCheckBoxString(me, theYesValue, theNoValue, theCvar, theText);
	return me;
}
void XonoticCheckBoxString_configureXonoticCheckBoxString(entity me, string theYesValue, string theNoValue, string theCvar, string theText)
{
	me.yesString = theYesValue;
	me.noString = theNoValue;
	me.checked = 0;
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureCheckBox(me, theText, me.fontSize, me.image);
}
void XonoticCheckBoxString_setChecked(entity me, float foo)
{
	me.checked = !me.checked;
	me.saveCvars(me);
}
void XonoticCheckBoxString_loadCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(cvar_string(me.cvarName) == me.yesString)
		me.checked = 1;
}
void XonoticCheckBoxString_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
		cvar_set(me.cvarName, me.yesString);
	else
		cvar_set(me.cvarName, me.noString);
}
#endif
