#ifdef INTERFACE
CLASS(XonoticColorButton) EXTENDS(RadioButton)
	METHOD(XonoticColorButton, configureXonoticColorButton, void(entity, float, float, float))
	METHOD(XonoticColorButton, setChecked, void(entity, float))
	METHOD(XonoticColorButton, draw, void(entity))
	ATTRIB(XonoticColorButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticColorButton, image, string, SKINGFX_COLORBUTTON)
	ATTRIB(XonoticColorButton, image2, string, SKINGFX_COLORBUTTON_COLOR)

	ATTRIB(XonoticColorButton, useDownAsChecked, float, 1)

	ATTRIB(XonoticColorButton, cvarPart, float, 0)
	ATTRIB(XonoticColorButton, cvarName, string, string_null)
	ATTRIB(XonoticColorButton, cvarValueFloat, float, 0)
	METHOD(XonoticColorButton, loadCvars, void(entity))
	METHOD(XonoticColorButton, saveCvars, void(entity))
ENDCLASS(XonoticColorButton)
entity makeXonoticColorButton(float, float, float);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticColorButton(float theGroup, float theColor, float theValue)
{
	entity me;
	me = spawnXonoticColorButton();
	me.configureXonoticColorButton(me, theGroup, theColor, theValue);
	return me;
}
void XonoticColorButton_configureXonoticColorButton(entity me, float theGroup, float theColor, float theValue)
{
	switch(theValue)
	{
		// rearrange 1..14 for rainbow order
		case  1: theValue = 10; break;
		case  2: theValue =  4; break;
		case  3: theValue =  1; break;
		case  4: theValue = 14; break;
		case  5: theValue = 12; break;
		case  6: theValue =  7; break;
		case  7: theValue =  3; break;
		case  8: theValue =  2; break;
		case  9: theValue =  6; break;
		case 10: theValue =  5; break;
		case 11: theValue = 13; break;
		case 12: theValue = 11; break;
		case 13: theValue =  8; break;
		case 14: theValue =  9; break;
		default:
			// no change
			break;
	}
	me.cvarName = "_cl_color";
	me.cvarValueFloat = theValue;
	me.cvarPart = theColor;
	me.loadCvars(me);
	me.configureRadioButton(me, string_null, me.fontSize, me.image, theGroup, 0);
	me.srcMulti = 1;
	me.src2 = me.image2;
}
void XonoticColorButton_setChecked(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void XonoticColorButton_loadCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(cvar_string(me.cvarName) == cvar_defstring(me.cvarName))
		cvar_set(me.cvarName, ftos(16 * floor(random() * 15) + floor(random() * 15)));

	if(me.cvarPart == 1)
		me.checked = (cvar(me.cvarName) & 240) == me.cvarValueFloat * 16;
	else
		me.checked = (cvar(me.cvarName) & 15) == me.cvarValueFloat;
}
void XonoticColorButton_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
	{
		if(me.cvarPart == 1)
			cvar_set(me.cvarName, ftos(cvar(me.cvarName) & 15 + me.cvarValueFloat * 16));
		else
			cvar_set(me.cvarName, ftos(cvar(me.cvarName) & 240 + me.cvarValueFloat));
	}
	// TODO on an apply button, read _cl_color and execute the color command for it
}
void XonoticColorButton_draw(entity me)
{
	me.color2 = colormapPaletteColor(me.cvarValueFloat, me.cvarPart);
	SUPER(XonoticColorButton).draw(me);
}
#endif
