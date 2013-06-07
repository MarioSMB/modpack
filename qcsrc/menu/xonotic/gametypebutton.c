#ifdef INTERFACE
CLASS(XonoticGametypeButton) EXTENDS(RadioButton)
	METHOD(XonoticGametypeButton, configureXonoticGametypeButton, void(entity, float, string, string))
	METHOD(XonoticGametypeButton, setChecked, void(entity, float))
	ATTRIB(XonoticGametypeButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticGametypeButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(XonoticGametypeButton, color, vector, SKINCOLOR_BUTTON_N)
	ATTRIB(XonoticGametypeButton, colorC, vector, SKINCOLOR_BUTTON_C)
	ATTRIB(XonoticGametypeButton, colorF, vector, SKINCOLOR_BUTTON_F)
	ATTRIB(XonoticGametypeButton, colorD, vector, SKINCOLOR_BUTTON_D)
	ATTRIB(XonoticGametypeButton, srcMulti, float, 1)
	ATTRIB(XonoticGametypeButton, useDownAsChecked, float, 1)

	ATTRIB(XonoticGametypeButton, cvarName, string, string_null)
	METHOD(XonoticGametypeButton, loadCvars, void(entity))
	METHOD(XonoticGametypeButton, saveCvars, void(entity))

	ATTRIB(XonoticGametypeButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticGametypeButton, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(XonoticGametypeButton)
entity makeXonoticGametypeButton(float, string, string);
#endif

#ifdef IMPLEMENTATION
void GameTypeButton_Click(entity me, entity other);
entity makeXonoticGametypeButton(float theGroup, string theCvar, string theText)
{
	entity me;
	me = spawnXonoticGametypeButton();
	me.configureXonoticGametypeButton(me, theGroup, theCvar, theText);
	return me;
}
void XonoticGametypeButton_configureXonoticGametypeButton(entity me, float theGroup, string theCvar, string theText)
{
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureRadioButton(me, theText, me.fontSize, me.image, theGroup, 0);
	me.align = 0.5;
	me.onClick = GameTypeButton_Click;
	me.onClickEntity = NULL;
}
void XonoticGametypeButton_setChecked(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void XonoticGametypeButton_loadCvars(entity me)
{
	if not(me.cvarName)
		return;

	me.checked = cvar(me.cvarName);
}
void XonoticGametypeButton_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	cvar_set(me.cvarName, ftos(me.checked));
}
void GameTypeButton_Click(entity me, entity other)
{
	RadioButton_Click(me, other);
	me.parent.gameTypeChangeNotify(me.parent);
}
#endif
