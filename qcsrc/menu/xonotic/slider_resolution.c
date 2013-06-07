#ifdef INTERFACE
CLASS(XonoticResolutionSlider) EXTENDS(XonoticTextSlider)
	METHOD(XonoticResolutionSlider, configureXonoticResolutionSlider, void(entity))
	METHOD(XonoticResolutionSlider, addResolution, void(entity, float, float, float))
	METHOD(XonoticResolutionSlider, loadCvars, void(entity))
	METHOD(XonoticResolutionSlider, saveCvars, void(entity))
ENDCLASS(XonoticResolutionSlider)
entity makeXonoticResolutionSlider();
void initConwidths();
void updateConwidths();
#endif

#ifdef IMPLEMENTATION
void initConwidths()
{
	cvar_set("_menu_vid_width", cvar_string("vid_width"));
	cvar_set("_menu_vid_height", cvar_string("vid_height"));
	cvar_set("_menu_vid_pixelheight", cvar_string("vid_pixelheight"));
}
void updateConwidths()
{
	vector r, c;
	float minfactor, maxfactor;
	float sz, f;
	r_x = cvar("_menu_vid_width");
	r_y = cvar("_menu_vid_height");
	r_z = cvar("_menu_vid_pixelheight");
	sz = cvar("menu_vid_scale");

	// calculate the base resolution
	c_z = 0;
	c_x = 800;
	c_y = c_x * r_y * r_z / r_x;
	if(c_y < 600)
	{
		c_y = 600;
		c_x = c_y * r_x / (r_y * r_z);
	}

	f = min(r_x / c_x, r_y / c_y);
	if(f < 1)
		c = c * f; // ensures that c_x <= r_x and c_y <= r_y

	minfactor = min(1, 640 / c_x);            // can be > 1 only if c_x is <640
	maxfactor = max(1, r_x / c_x, r_y / c_y); // can be < 1 only if r_x < c_x and r_y < c_y
	dprint("min factor: ", ftos(minfactor), "\n");
	dprint("max factor: ", ftos(maxfactor), "\n");

	if(sz < 0)
		f = 1 - (maxfactor - 1) * sz;
	else if(sz > 0)
		f = 1 + (minfactor - 1) * sz;
	else
		f = 1;
	c = c * f; // fteqcc fail

	cvar_set("vid_width", ftos(rint(r_x)));
	cvar_set("vid_height", ftos(rint(r_y)));
	cvar_set("vid_pixelheight", ftos(rint(r_z)));
	cvar_set("vid_conwidth", ftos(rint(c_x)));
	cvar_set("vid_conheight", ftos(rint(c_y)));
}
entity makeXonoticResolutionSlider()
{
	entity me;
	me = spawnXonoticResolutionSlider();
	me.configureXonoticResolutionSlider(me);
	return me;
}
void XonoticResolutionSlider_addResolution(entity me, float w, float h, float pixelheight)
{
	me.addValue(me, strzone(sprintf(_("%dx%d"), w, h)), strzone(strcat(ftos(w), " ", ftos(h), " ", ftos(pixelheight))));
	// FIXME (in case you ever want to dynamically instantiate this): THIS IS NEVER FREED
}
void XonoticResolutionSlider_configureXonoticResolutionSlider(entity me)
{
	float i;
	vector r0, r;

	me.configureXonoticTextSlider(me, "_menu_vid_width");

	r0 = '0 0 0';
	for(i = 0;; ++i)
	{
		r = getresolution(i);
		if(r_x == 0 && r_y == 0)
			break;
		if(r_z == 0)
			r_z = 1; // compat
		if(r == r0)
			continue;
		r0 = r;
		if(r_x < 640 || r_y < 480)
			continue;
		if(r_x > 2 * r_y) // likely dualscreen resolution, skip this one
			continue;
		me.addResolution(me, r_x, r_y, r_z);
	}

	if(me.nValues == 0)
	{
		me.addResolution(me, 640, 480, 1);
		me.addResolution(me, 800, 600, 1);
		me.addResolution(me, 1024, 768, 1);
		me.addResolution(me, 1280, 960, 1);
		me.addResolution(me, 1280, 1024, 1);
		me.addResolution(me, 1650, 1080, 1);
		me.addResolution(me, 1920, 1080, 1);
	}

	me.configureXonoticTextSliderValues(me);
}
void XonoticResolutionSlider_loadCvars(entity me)
{
	me.setValueFromIdentifier(me, strcat(cvar_string("_menu_vid_width"), " ", cvar_string("_menu_vid_height"), " ", cvar_string("_menu_vid_pixelheight")));
}
void XonoticResolutionSlider_saveCvars(entity me)
{
	if(me.value >= 0 || me.value < me.nValues)
	{
		tokenize_console(me.getIdentifier(me));
		cvar_set("_menu_vid_width", argv(0));
		cvar_set("_menu_vid_height", argv(1));
		cvar_set("_menu_vid_pixelheight", argv(2));
	}
}
#endif
