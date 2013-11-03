#ifdef INTERFACE
CLASS(XonoticRadioButton) EXTENDS(RadioButton)
	METHOD(XonoticRadioButton, configureXonoticRadioButton, void(entity, float, string, string, string))
	METHOD(XonoticRadioButton, draw, void(entity))
	METHOD(XonoticRadioButton, setChecked, void(entity, float))
	ATTRIB(XonoticRadioButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticRadioButton, image, string, SKINGFX_RADIOBUTTON)
	ATTRIB(XonoticRadioButton, color, vector, SKINCOLOR_RADIOBUTTON_N)
	ATTRIB(XonoticRadioButton, colorC, vector, SKINCOLOR_RADIOBUTTON_C)
	ATTRIB(XonoticRadioButton, colorF, vector, SKINCOLOR_RADIOBUTTON_F)
	ATTRIB(XonoticRadioButton, colorD, vector, SKINCOLOR_RADIOBUTTON_D)

	ATTRIB(XonoticRadioButton, cvarName, string, string_null)
	ATTRIB(XonoticRadioButton, cvarValue, string, string_null)
	ATTRIB(XonoticRadioButton, cvarOffValue, string, string_null)
	ATTRIB(XonoticRadioButton, getCvarValueFromCvar, float, 0)
	METHOD(XonoticRadioButton, loadCvars, void(entity))
	METHOD(XonoticRadioButton, saveCvars, void(entity))

	ATTRIB(XonoticRadioButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticRadioButton, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(XonoticRadioButton)
entity makeXonoticRadioButton(float, string, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticRadioButton(float theGroup, string theCvar, string theValue, string theText)
{
	entity me;
	me = spawnXonoticRadioButton();
	me.configureXonoticRadioButton(me, theGroup, theCvar, theValue, theText);
	return me;
}
void XonoticRadioButton_configureXonoticRadioButton(entity me, float theGroup, string theCvar, string theValue, string theText)
{
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.cvarValue = theValue;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureRadioButton(me, theText, me.fontSize, me.image, theGroup, 0);
}
void XonoticRadioButton_setChecked(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void XonoticRadioButton_loadCvars(entity me)
{
	if(me.cvarValue)
	{
		if(me.cvarName)
			me.checked = (cvar_string(me.cvarName) == me.cvarValue);
	}
	else
	{
		if(me.cvarName)
		{
			me.checked = !!cvar(me.cvarName);
		}
		else
		{
			// this is difficult
			// this is the "generic" selection... but at this time, not
			// everything is constructed yet.
			// we need to set this later in draw()
			me.checked = 0;
		}
	}
}
void XonoticRadioButton_draw(entity me)
{
	if (!me.cvarValue)
		if (!me.cvarName)
		{
			// this is the "other" option
			// always select this if none other is
			entity e;
			float found;
			found = 0;
			for(e = me.parent.firstChild; e; e = e.nextSibling)
				if(e.group == me.group)
					if(e.checked)
						found = 1;
			if(!found)
				me.setChecked(me, 1);
		}
	SUPER(XonoticRadioButton).draw(me);
}
void XonoticRadioButton_saveCvars(entity me)
{
	if(me.cvarValue)
	{
		if(me.cvarName)
		{
			if(me.checked)
			{
				if(me.getCvarValueFromCvar)
					cvar_set(me.cvarName, cvar_string(me.cvarValue));
				else
					cvar_set(me.cvarName, me.cvarValue);
			}
			else if(me.cvarOffValue)
				cvar_set(me.cvarName, me.cvarOffValue);
		}
	}
	else
	{
		if(me.cvarName)
		{
			cvar_set(me.cvarName, ftos(me.checked));
		}
	}
}
#endif
