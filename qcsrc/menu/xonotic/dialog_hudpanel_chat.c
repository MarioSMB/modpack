#ifdef INTERFACE
CLASS(XonoticHUDChatDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDChatDialog, fill, void(entity))
	ATTRIB(XonoticHUDChatDialog, title, string, _("Chat Panel"))
	ATTRIB(XonoticHUDChatDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDChatDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDChatDialog, rows, float, 15)
	ATTRIB(XonoticHUDChatDialog, columns, float, 4)
	ATTRIB(XonoticHUDChatDialog, name, string, "HUDchat")
ENDCLASS(XonoticHUDChatDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDChatDialog_fill(entity me)
{
	entity e;
	string panelname = "chat";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("Chat entries:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Chat size:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(6, 20, 1, "con_chatsize"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Chat lifetime:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(5, 60, 5, "con_chattime"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "con_chatsound", _("Chat beep sound")));
}
#endif
