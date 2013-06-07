#ifdef INTERFACE
CLASS(XonoticTabController) EXTENDS(ModalController)
	METHOD(XonoticTabController, configureXonoticTabController, void(entity, float))
	METHOD(XonoticTabController, makeTabButton, entity(entity, string, entity))
	ATTRIB(XonoticTabController, rows, float, 0)
	ATTRIB(XonoticTabController, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticTabController, image, string, SKINGFX_BUTTON)
ENDCLASS(XonoticTabController)
entity makeXonoticTabController(float theRows);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticTabController(float theRows)
{
	entity me;
	me = spawnXonoticTabController();
	me.configureXonoticTabController(me, theRows);
	return me;
}
void XonoticTabController_configureXonoticTabController(entity me, float theRows)
{
	me.rows = theRows;
}
entity XonoticTabController_makeTabButton(entity me, string theTitle, entity tab)
{
	entity b;
	if(me.rows != tab.rows)
		error("Tab dialog height mismatch!");
	b = makeXonoticButton(theTitle, '0 0 0');
		me.addTab(me, tab, b);
	// TODO make this real tab buttons (with color parameters, and different gfx)
	return b;
}
#endif
