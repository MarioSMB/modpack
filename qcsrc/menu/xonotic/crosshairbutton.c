#ifdef INTERFACE
CLASS(XonoticCrosshairButton) EXTENDS(RadioButton)
	METHOD(XonoticCrosshairButton, configureXonoticCrosshairButton, void(entity, float, float))
	METHOD(XonoticCrosshairButton, setChecked, void(entity, float))
	METHOD(XonoticCrosshairButton, draw, void(entity))
	ATTRIB(XonoticCrosshairButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticCrosshairButton, image, string, SKINGFX_CROSSHAIRBUTTON)

	ATTRIB(XonoticCrosshairButton, useDownAsChecked, float, 1)
	ATTRIB(XonoticCrosshairButton, src3, string, string_null)
	ATTRIB(XonoticCrosshairButton, src4, string, string_null)

	ATTRIB(XonoticCrosshairButton, cvarName, string, string_null)
	ATTRIB(XonoticCrosshairButton, cvarValueFloat, float, 0)
	METHOD(XonoticCrosshairButton, loadCvars, void(entity))
	METHOD(XonoticCrosshairButton, saveCvars, void(entity))
ENDCLASS(XonoticCrosshairButton)
entity makeXonoticCrosshairButton(float, float);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticCrosshairButton(float theGroup, float theCrosshair)
{
	entity me;
	me = spawnXonoticCrosshairButton();
	me.configureXonoticCrosshairButton(me, theGroup, theCrosshair);
	return me;
}
void XonoticCrosshairButton_configureXonoticCrosshairButton(entity me, float theGroup, float theCrosshair)
{
	me.cvarName = "crosshair";
	me.cvarValueFloat = theCrosshair;
	me.loadCvars(me);
	me.configureRadioButton(me, string_null, me.fontSize, me.image, theGroup, 0);
	me.srcMulti = 1;
	if(me.cvarValueFloat == -1)
		me.src3 = strzone(strcat("/gfx/crosshair", cvar_string("crosshair")));
	else
		me.src3 = strzone(strcat("/gfx/crosshair", ftos(me.cvarValueFloat)));
	me.src4 = "/gfx/crosshairdot";
}
void XonoticCrosshairButton_setChecked(entity me, float val)
{
	if(me.cvarValueFloat != -1) // preview shouldn't work as a button
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void XonoticCrosshairButton_loadCvars(entity me)
{
	if not(me.cvarName)
		return;

	me.checked = (cvar(me.cvarName) == me.cvarValueFloat);
}
void XonoticCrosshairButton_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
		cvar_set(me.cvarName, ftos(me.cvarValueFloat));
	// TODO on an apply button, read _cl_color and execute the color command for it
}
void XonoticCrosshairButton_draw(entity me)
{
	vector sz, rgb;
	float a;


	if(me.cvarValueFloat == -1)
	{
		rgb = stov(cvar_string("crosshair_color"));
		a = cvar("crosshair_alpha");
	}
	else if(me.checked || me.focused)
	{
		a = 1;
		rgb = '1 1 1';
	}
	else
	{
		a = me.disabledAlpha;
		rgb = '1 1 1';
	}

	if(me.cvarValueFloat == -1) // update the preview if this is the preview button
	{
		if(me.src3)
			strunzone(me.src3);
		me.src3 = strzone(strcat("/gfx/crosshair", cvar_string("crosshair")));
		me.focused = 1;
		me.checked = 0;
	}

	SUPER(XonoticCrosshairButton).draw(me);

	sz = draw_PictureSize(me.src3);
	sz = globalToBoxSize(sz, me.size);
	if(me.cvarValueFloat == -1)
	{
		sz = sz * cvar("crosshair_size"); // (6 * '1 1 0' + ...) * 0.08 here to make visible size changes happen also at bigger sizes
		/*
		if(sz_x > 0.95)
			sz = sz * (0.95 / sz_x);
		if(sz_y > 0.95)
			sz = sz * (0.95 / sz_y);
		*/
	}
	else // show the crosshair picker at full size
	{
		sz = sz * (0.95 / sz_x);
		if(sz_y > 0.95)
			sz = sz * (0.95 / sz_y);
	}

	draw_Picture('0.5 0.5 0' - 0.5 * sz, me.src3, sz, rgb, a);
	if(cvar("crosshair_dot"))
	{
		if(cvar("crosshair_dot_color_custom") && (cvar_string("crosshair_dot_color") != "0"))
			rgb = stov(cvar_string("crosshair_dot_color"));
			
		draw_Picture('0.5 0.5 0' - 0.5 * sz * cvar("crosshair_dot_size"), me.src4, sz * cvar("crosshair_dot_size"), rgb, a * cvar("crosshair_dot_alpha"));
	}
}
#endif
