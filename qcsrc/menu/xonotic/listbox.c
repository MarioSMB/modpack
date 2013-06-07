#ifdef INTERFACE
CLASS(XonoticListBox) EXTENDS(ListBox)
	METHOD(XonoticListBox, configureXonoticListBox, void(entity))
	ATTRIB(XonoticListBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticListBox, scrollbarWidth, float, SKINWIDTH_SCROLLBAR)
	ATTRIB(XonoticListBox, src, string, SKINGFX_SCROLLBAR)
	ATTRIB(XonoticListBox, tolerance, vector, SKINTOLERANCE_SLIDER)
	ATTRIB(XonoticListBox, rowsPerItem, float, 1)
	METHOD(XonoticListBox, resizeNotify, void(entity, vector, vector, vector, vector))
	ATTRIB(XonoticListBox, color, vector, SKINCOLOR_SCROLLBAR_N)
	ATTRIB(XonoticListBox, colorF, vector, SKINCOLOR_SCROLLBAR_F)
	ATTRIB(XonoticListBox, color2, vector, SKINCOLOR_SCROLLBAR_S)
	ATTRIB(XonoticListBox, colorC, vector, SKINCOLOR_SCROLLBAR_C)
	ATTRIB(XonoticListBox, colorBG, vector, SKINCOLOR_LISTBOX_BACKGROUND)
	ATTRIB(XonoticListBox, alphaBG, float, SKINALPHA_LISTBOX_BACKGROUND)
ENDCLASS(XonoticListBox)
entity makeXonoticListBox();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticListBox()
{
	entity me;
	me = spawnXonoticListBox();
	me.configureXonoticListBox(me);
	return me;
}
void XonoticListBox_configureXonoticListBox(entity me)
{
	me.configureListBox(me, me.scrollbarWidth, 1); // item height gets set up later
}
void XonoticListBox_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.itemHeight = me.rowsPerItem * me.fontSize / absSize_y;
	SUPER(XonoticListBox).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);
}
#endif
