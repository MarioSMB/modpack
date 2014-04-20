#ifdef INTERFACE
CLASS(XonoticModelDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticModelDialog, toString, string(entity))
	METHOD(XonoticModelDialog, fill, void(entity))
	METHOD(XonoticModelDialog, showNotify, void(entity))
	ATTRIB(XonoticModelDialog, title, string, _("Model settings"))
	ATTRIB(XonoticModelDialog, color, vector, SKINCOLOR_DIALOG_MODEL)
	ATTRIB(XonoticModelDialog, intendedWidth, float, 0.5)
	ATTRIB(XonoticModelDialog, rows, float, 7)
	ATTRIB(XonoticModelDialog, columns, float, 3)
ENDCLASS(XonoticModelDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticModelDialog_showNotify(entity me)
{
	loadAllCvars(me);
}
string XonoticModelDialog_toString(entity me)
{
	return "hi"; // TODO: show csqc model settings like forcemyplayer and deglowing/ghosting bodies with text here
}
void XonoticModelDialog_fill(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Body fading:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(0, 2, 0.2, "cl_deathglow"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Gibs:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("cl_nogibs"));
			e.addValue(e, ZCTX(_("GIBS^None")), "1");
			e.addValue(e, ZCTX(_("GIBS^Few")), "0.75");
			e.addValue(e, ZCTX(_("GIBS^Many")), "0.5");
			e.addValue(e, ZCTX(_("GIBS^Lots")), "0");
			e.configureXonoticTextSliderValues(e);
			setDependent(e, "cl_gentle", 0, 0);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "cl_forceplayermodels", _("Force player models to mine")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "cl_forceplayercolors", _("Force player colors to mine")));
	me.TR(me);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
