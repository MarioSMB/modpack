#ifdef INTERFACE
CLASS(XonoticTab) EXTENDS(Tab)
	// still to be customized by user
	/*
	ATTRIB(XonoticTab, intendedWidth, float, 0)
	ATTRIB(XonoticTab, rows, float, 3)
	ATTRIB(XonoticTab, columns, float, 2)
	*/
	METHOD(XonoticTab, showNotify, void(entity))

	ATTRIB(XonoticTab, marginTop, float, 0) // pixels
	ATTRIB(XonoticTab, marginBottom, float, 0) // pixels
	ATTRIB(XonoticTab, marginLeft, float, 0) // pixels
	ATTRIB(XonoticTab, marginRight, float, 0) // pixels
	ATTRIB(XonoticTab, columnSpacing, float, SKINMARGIN_COLUMNS) // pixels
	ATTRIB(XonoticTab, rowSpacing, float, SKINMARGIN_ROWS) // pixels
	ATTRIB(XonoticTab, rowHeight, float, SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL) // pixels
	ATTRIB(XonoticTab, titleHeight, float, SKINFONTSIZE_TITLE * SKINHEIGHT_TITLE) // pixels

	ATTRIB(XonoticTab, backgroundImage, string, string_null)
ENDCLASS(XonoticTab)
#endif

#ifdef IMPLEMENTATION
void XonoticTab_showNotify(entity me)
{
	loadAllCvars(me);
	SUPER(XonoticTab).showNotify(me);
}
#endif
