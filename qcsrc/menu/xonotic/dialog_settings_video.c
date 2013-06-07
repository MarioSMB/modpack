#ifdef INTERFACE
CLASS(XonoticVideoSettingsTab) EXTENDS(XonoticTab)
	METHOD(XonoticVideoSettingsTab, fill, void(entity))
	ATTRIB(XonoticVideoSettingsTab, title, string, _("Video"))
	ATTRIB(XonoticVideoSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticVideoSettingsTab, rows, float, 17)
	ATTRIB(XonoticVideoSettingsTab, columns, float, 6.2) // added extra .2 for center space 
	ATTRIB(XonoticVideoSettingsTab, name, string, "videosettings")
ENDCLASS(XonoticVideoSettingsTab)
entity makeXonoticVideoSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticVideoSettingsTab()
{
	entity me;
	me = spawnXonoticVideoSettingsTab();
	me.configureDialog(me);
	return me;
}
void XonoticVideoSettingsTab_fill(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Resolution:")));
		me.TD(me, 1, 2, e = makeXonoticResolutionSlider());
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Font/UI size:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("menu_vid_scale"));
			e.addValue(e, ZCTX(_("SZ^Unreadable")), "-1");
			e.addValue(e, ZCTX(_("SZ^Tiny")), "-0.75");
			e.addValue(e, ZCTX(_("SZ^Little")), "-0.5");
			e.addValue(e, ZCTX(_("SZ^Small")), "-0.25");
			e.addValue(e, ZCTX(_("SZ^Medium")), "0");
			e.addValue(e, ZCTX(_("SZ^Large")), "0.25");
			e.addValue(e, ZCTX(_("SZ^Huge")), "0.5");
			e.addValue(e, ZCTX(_("SZ^Gigantic")), "0.75");
			e.addValue(e, ZCTX(_("SZ^Colossal")), "1");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Color depth:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("vid_bitsperpixel"));
			e.addValue(e, _("16bit"), "16");
			e.addValue(e, _("32bit"), "32");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox(0, "vid_fullscreen", _("Full screen")));
		me.TD(me, 1, 2, e = makeXonoticCheckBox(0, "vid_vsync", _("Vertical Synchronization")));
		
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Anisotropy:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("gl_texture_anisotropy"));
			e.addValue(e, ZCTX(_("ANISO^Disabled")), "1");
			e.addValue(e, _("2x"), "2");
			e.addValue(e, _("4x"), "4");
			e.addValue(e, _("8x"), "8");
			e.addValue(e, _("16x"), "16");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Antialiasing:")));
			setDependent(e, "r_viewfbo", 0, 0);
		me.TD(me, 1, 2, e = makeXonoticTextSlider("vid_samples"));
			e.addValue(e, ZCTX(_("AA^Disabled")), "1");
			e.addValue(e, _("2x"), "2");
			e.addValue(e, _("4x"), "4");
			e.configureXonoticTextSliderValues(e);
			setDependent(e, "r_viewfbo", 0, 0);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBoxEx(2, 0, "r_viewfbo", _("High-quality frame buffer")));
			setDependent(e, "vid_samples", 1, 1);
		
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Depth first:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("r_depthfirst"));
			e.addValue(e, ZCTX(_("DF^Disabled")), "0");
			e.addValue(e, ZCTX(_("DF^World")), "1");
			e.addValue(e, ZCTX(_("DF^All")), "2");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Vertex Buffer Objects (VBOs)")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticRadioButton(1, "gl_vbo", "0", ZCTX(_("VBO^Off"))));
		me.TD(me, 1, 1.9, e = makeXonoticRadioButton(1, "gl_vbo", "3", _("Vertices, some Tris (compatible)")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticRadioButton(1, "gl_vbo", "2", _("Vertices")));
		me.TD(me, 1, 1.9, e = makeXonoticRadioButton(1, "gl_vbo", "1", _("Vertices and Triangles")));

	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Brightness:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(0.0, 0.5, 0.02, "v_brightness"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Contrast:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(1.0, 3.0, 0.05, "v_contrast"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Gamma:")));
			setDependentAND(e, "vid_gl20", 1, 1, "v_glslgamma", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.5, 2.0, 0.05, "v_gamma"));
			setDependentAND(e, "vid_gl20", 1, 1, "v_glslgamma", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Contrast boost:")));
			setDependentAND(e, "vid_gl20", 1, 1, "v_glslgamma", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticSlider(1.0, 5.0, 0.1, "v_contrastboost"));
			setDependentAND(e, "vid_gl20", 1, 1, "v_glslgamma", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Saturation:")));
			setDependent(e, "vid_gl20", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.5, 2.0, 0.05, "r_glsl_saturation"));
			setDependent(e, "vid_gl20", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, ZCTX(_("LIT^Ambient:"))));
		me.TD(me, 1, 2, e = makeXonoticSlider(0, 20.0, 0.25, "r_ambient"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Intensity:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(0.5, 2.0, 0.05, "r_hdr_scenebrightness"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "gl_finish", _("Wait for GPU to finish each frame")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "vid_gl20", _("Use OpenGL 2.0 shaders (GLSL)")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "v_glslgamma", _("Use GLSL to handle color control")));
			setDependent(e, "vid_gl20", 1, 1);
	if(cvar("developer"))
	{
		me.TR(me);
			me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "v_psycho", _("Psycho coloring (easter egg)")));
				setDependent(e, "vid_gl20", 1, 1);
		me.TR(me);
			me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "r_trippy", _("Trippy vertices (easter egg)")));
				setDependent(e, "vid_gl20", 1, 1);
		me.TR(me);
			me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "v_flipped", _("Flip view horizontally")));
	}

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeXonoticCommandButton(_("Apply immediately"), '0 0 0', "menu_cmd sync; vid_restart; menu_restart; menu_cmd videosettings", COMMANDBUTTON_APPLY));
}
#endif
