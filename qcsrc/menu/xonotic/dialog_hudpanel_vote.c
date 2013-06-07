#ifdef INTERFACE
CLASS(XonoticHUDVoteDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDVoteDialog, fill, void(entity))
	ATTRIB(XonoticHUDVoteDialog, title, string, _("Vote Panel"))
	ATTRIB(XonoticHUDVoteDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDVoteDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDVoteDialog, rows, float, 15)
	ATTRIB(XonoticHUDVoteDialog, columns, float, 4)
	ATTRIB(XonoticHUDVoteDialog, name, string, "HUDvote")
ENDCLASS(XonoticHUDVoteDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDVoteDialog_fill(entity me)
{
	entity e;
	string panelname = "vote";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 1.4, e = makeXonoticTextLabel(0, _("Alpha after voting:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(0.1, 1, 0.1, "hud_panel_vote_alreadyvoted_alpha"));
}
#endif
