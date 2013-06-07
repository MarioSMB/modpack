#ifdef INTERFACE
CLASS(Tab) EXTENDS(Dialog)
	ATTRIB(Tab, isTabRoot, float, 0)
	ATTRIB(Tab, closable, float, 0)
	ATTRIB(Tab, rootDialog, float, 0)
	ATTRIB(Tab, title, string, string_null)
	ATTRIB(Tab, titleFontSize, float, 0) // pixels
	
	// still to be customized
	ATTRIB(Tab, intendedWidth, float, 0)
	ATTRIB(Tab, rows, float, 3)
	ATTRIB(Tab, columns, float, 2)

	ATTRIB(Tab, marginTop, float, 0) // pixels
	ATTRIB(Tab, marginBottom, float, 0) // pixels
	ATTRIB(Tab, marginLeft, float, 0) // pixels
	ATTRIB(Tab, marginRight, float, 0) // pixels
	ATTRIB(Tab, columnSpacing, float, 0) // pixels
	ATTRIB(Tab, rowSpacing, float, 0) // pixels
	ATTRIB(Tab, rowHeight, float, 0) // pixels
	ATTRIB(Tab, titleHeight, float, 0) // pixels

	ATTRIB(Tab, backgroundImage, string, string_null)
ENDCLASS(Tab)
#endif

#ifdef IMPLEMENTATION
#endif
