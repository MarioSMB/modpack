#ifdef INTERFACE
CLASS(XonoticButton) EXTENDS(Button)
	METHOD(XonoticButton, configureXonoticButton, void(entity, string, vector))
	ATTRIB(XonoticButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticButton, image, string, SKINGFX_BUTTON)
	ATTRIB(XonoticButton, grayImage, string, SKINGFX_BUTTON_GRAY)
	ATTRIB(XonoticButton, color, vector, SKINCOLOR_BUTTON_N)
	ATTRIB(XonoticButton, colorC, vector, SKINCOLOR_BUTTON_C)
	ATTRIB(XonoticButton, colorF, vector, SKINCOLOR_BUTTON_F)
	ATTRIB(XonoticButton, colorD, vector, SKINCOLOR_BUTTON_D)
	ATTRIB(XonoticButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticButton, disabledAlpha, float, SKINALPHA_DISABLED)
	ATTRIB(XonoticButton, marginLeft, float, SKINMARGIN_BUTTON) // chars
	ATTRIB(XonoticButton, marginRight, float, SKINMARGIN_BUTTON) // chars
ENDCLASS(XonoticButton)
entity makeXonoticButton(string theText, vector theColor);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticButton(string theText, vector theColor)
{
	entity me;
	me = spawnXonoticButton();
	me.configureXonoticButton(me, theText, theColor);
	return me;
}

void XonoticButton_configureXonoticButton(entity me, string theText, vector theColor)
{
	if(theColor == '0 0 0')
	{
		me.configureButton(me, theText, me.fontSize, me.image);
	}
	else
	{
		me.configureButton(me, theText, me.fontSize, me.grayImage);
		me.color = theColor;
		me.colorC = theColor;
		me.colorF = theColor;
	}
	me.tooltip = getZonedTooltipForIdentifier(strcat(currentDialog.classname, "/", me.text));
}
#endif
