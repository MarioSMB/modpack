#ifdef INTERFACE
CLASS(XonoticTextLabel) EXTENDS(Label)
	METHOD(XonoticTextLabel, configureXonoticTextLabel, void(entity, float, string))
	METHOD(XonoticTextLabel, draw, void(entity))
	ATTRIB(XonoticTextLabel, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticTextLabel, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticTextLabel, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(XonoticTextLabel)
entity makeXonoticTextLabel(float theAlign, string theText);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticTextLabel(float theAlign, string theText)
{
	entity me;
	me = spawnXonoticTextLabel();
	me.configureXonoticTextLabel(me, theAlign, theText);
	return me;
}
void XonoticTextLabel_configureXonoticTextLabel(entity me, float theAlign, string theText)
{
	me.configureLabel(me, theText, me.fontSize, theAlign);
}
void XonoticTextLabel_draw(entity me)
{
	SUPER(XonoticTextLabel).draw(me);
}
#endif
