#ifdef INTERFACE
CLASS(XonoticBigButton) EXTENDS(XonoticButton)
	METHOD(XonoticBigButton, configureXonoticBigButton, void(entity, string, vector))
	ATTRIB(XonoticBigButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(XonoticBigButton, grayImage, string, SKINGFX_BUTTON_BIG_GRAY)
ENDCLASS(XonoticBigButton)
entity makeXonoticButton(string theText, vector theColor);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticBigButton(string theText, vector theColor)
{
	entity me;
	me = spawnXonoticBigButton();
	me.configureXonoticBigButton(me, theText, theColor);
	return me;
}

void XonoticBigButton_configureXonoticBigButton(entity me, string theText, vector theColor)
{
	me.configureXonoticButton(me, theText, theColor);
}
#endif
