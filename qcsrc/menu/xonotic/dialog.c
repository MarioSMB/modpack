#ifdef INTERFACE
CLASS(XonoticDialog) EXTENDS(Dialog)
	// still to be customized by user
	/*
	ATTRIB(XonoticDialog, closable, float, 1)
	ATTRIB(XonoticDialog, title, string, _("Form1")) // ;)
	ATTRIB(XonoticDialog, color, vector, '1 0.5 1')
	ATTRIB(XonoticDialog, intendedWidth, float, 0)
	ATTRIB(XonoticDialog, rows, float, 3)
	ATTRIB(XonoticDialog, columns, float, 2)
	*/
	ATTRIB(XonoticDialog, marginTop, float, SKINMARGIN_TOP) // pixels
	ATTRIB(XonoticDialog, marginBottom, float, SKINMARGIN_BOTTOM) // pixels
	ATTRIB(XonoticDialog, marginLeft, float, SKINMARGIN_LEFT) // pixels
	ATTRIB(XonoticDialog, marginRight, float, SKINMARGIN_RIGHT) // pixels
	ATTRIB(XonoticDialog, columnSpacing, float, SKINMARGIN_COLUMNS) // pixels
	ATTRIB(XonoticDialog, rowSpacing, float, SKINMARGIN_ROWS) // pixels
	ATTRIB(XonoticDialog, rowHeight, float, SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL) // pixels
	ATTRIB(XonoticDialog, titleHeight, float, SKINFONTSIZE_TITLE * SKINHEIGHT_TITLE) // pixels
	ATTRIB(XonoticDialog, titleFontSize, float, SKINFONTSIZE_TITLE) // pixels

	ATTRIB(XonoticDialog, backgroundImage, string, SKINGFX_DIALOGBORDER)
	ATTRIB(XonoticDialog, borderLines, float, SKINHEIGHT_DIALOGBORDER)
	ATTRIB(XonoticDialog, closeButtonImage, string, SKINGFX_CLOSEBUTTON)
	ATTRIB(XonoticDialog, zoomedOutTitleBarPosition, float, SKINHEIGHT_ZOOMEDTITLE * 0.5 - 0.5)
	ATTRIB(XonoticDialog, zoomedOutTitleBar, float, SKINHEIGHT_ZOOMEDTITLE != 0)

	ATTRIB(XonoticDialog, alpha, float, SKINALPHA_TEXT)

	METHOD(XonoticDialog, configureDialog, void(entity))
ENDCLASS(XonoticDialog)
entity currentDialog;
#endif

#ifdef IMPLEMENTATION
void XonoticDialog_configureDialog(entity me)
{
	currentDialog = me;
	SUPER(XonoticDialog).configureDialog(me);
	me.tooltip = getZonedTooltipForIdentifier(me.classname);
}
#endif
