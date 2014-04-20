#ifdef INTERFACE
CLASS(XonoticRootDialog) EXTENDS(XonoticDialog)
	// still to be customized by user
	/*
	ATTRIB(XonoticDialog, closable, float, 1)
	ATTRIB(XonoticDialog, title, string, _("Form1")) // ;)
	ATTRIB(XonoticDialog, color, vector, '1 0.5 1')
	ATTRIB(XonoticDialog, intendedWidth, float, 0)
	ATTRIB(XonoticDialog, rows, float, 3)
	ATTRIB(XonoticDialog, columns, float, 2)
	*/
	METHOD(XonoticRootDialog, close, void(entity))
ENDCLASS(XonoticRootDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticRootDialog_close(entity me)
{
	m_goto(string_null);
}
#endif
