#ifdef INTERFACE
CLASS(XonoticPicmipSlider) EXTENDS(XonoticTextSlider)
	METHOD(XonoticPicmipSlider, configureXonoticPicmipSlider, void(entity))
	METHOD(XonoticPicmipSlider, draw, void(entity))
	METHOD(XonoticPicmipSlider, autofix, void(entity))
	ATTRIB(XonoticPicmipSlider, have_s3tc, float, 0)
ENDCLASS(XonoticPicmipSlider)
entity makeXonoticPicmipSlider(); // note: you still need to call addValue and configureXonoticTextSliderValues!
#endif

#ifdef IMPLEMENTATION
entity makeXonoticPicmipSlider()
{
	entity me;
	me = spawnXonoticPicmipSlider();
	me.configureXonoticPicmipSlider(me);
	return me;
}
void XonoticPicmipSlider_configureXonoticPicmipSlider(entity me)
{
	me.configureXonoticTextSlider(me, "gl_picmip");
	me.autofix(me);
	me.have_s3tc = GL_Have_TextureCompression();
}
float texmemsize(float s3tc)
{
	return
	(
		  2500 * pow(0.25, max(0, cvar("gl_picmip") + cvar("gl_picmip_other")))
		+ 1500 * pow(0.25, max(0, cvar("gl_picmip") + cvar("gl_picmip_world")))
	) * ((s3tc && (cvar("r_texture_dds_load") || cvar("gl_texturecompression"))) ? 0.2 : 1.0); // TC: normalmaps 50%, other 25%, few incompressible, guessing 40% as conservative average
}
void XonoticPicmipSlider_autofix(entity me)
{
	float max_hard, max_soft;
	if(cvar("menu_picmip_bypass"))
		return;
	max_hard = cvar("sys_memsize_virtual");
	max_soft = cvar("sys_memsize_physical");
	if(max_hard > 0)
	{
		while(me.value > 0 && texmemsize(me.have_s3tc) > max_hard)
			me.setValue(me, me.value - 1);
	}
	// TODO also check the soft limit!
	// TODO better handling than clamping the slider!
}
void XonoticPicmipSlider_draw(entity me)
{
	me.autofix(me);
	SUPER(XonoticPicmipSlider).draw(me);
}
#endif
