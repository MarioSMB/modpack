#ifdef INTERFACE
CLASS(XonoticSlider) EXTENDS(Slider)
	METHOD(XonoticSlider, configureXonoticSlider, void(entity, float, float, float, string))
	METHOD(XonoticSlider, setValue, void(entity, float))
	ATTRIB(XonoticSlider, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticSlider, valueSpace, float, SKINWIDTH_SLIDERTEXT)
	ATTRIB(XonoticSlider, image, string, SKINGFX_SLIDER)
	ATTRIB(XonoticSlider, tolerance, vector, SKINTOLERANCE_SLIDER)
	ATTRIB(XonoticSlider, align, float, 0.5)
	ATTRIB(XonoticSlider, color, vector, SKINCOLOR_SLIDER_N)
	ATTRIB(XonoticSlider, colorC, vector, SKINCOLOR_SLIDER_C)
	ATTRIB(XonoticSlider, colorF, vector, SKINCOLOR_SLIDER_F)
	ATTRIB(XonoticSlider, colorD, vector, SKINCOLOR_SLIDER_D)
	ATTRIB(XonoticSlider, color2, vector, SKINCOLOR_SLIDER_S)

	ATTRIB(XonoticSlider, cvarName, string, string_null)
	METHOD(XonoticSlider, loadCvars, void(entity))
	METHOD(XonoticSlider, saveCvars, void(entity))

	ATTRIB(XonoticSlider, alpha, float, SKINALPHA_TEXT)
	ATTRIB(XonoticSlider, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(XonoticSlider)
entity makeXonoticSlider(float, float, float, string);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticSlider(float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	entity me;
	me = spawnXonoticSlider();
	me.configureXonoticSlider(me, theValueMin, theValueMax, theValueStep, theCvar);
	return me;
}
void XonoticSlider_configureXonoticSlider(entity me, float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	float v, vk, vp;
	v = theValueMin;
	vk = theValueStep;
	vp = theValueStep * 10;
	while(fabs(vp) < fabs(theValueMax - theValueMin) / 40)
		vp *= 10;
	me.configureSliderVisuals(me, me.fontSize, me.align, me.valueSpace, me.image);
	me.configureSliderValues(me, theValueMin, v, theValueMax, theValueStep, vk, vp);
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.loadCvars(me);
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
	}
}
void XonoticSlider_setValue(entity me, float val)
{
	if(val != me.value)
	{
		SUPER(XonoticSlider).setValue( me, val );
		me.saveCvars(me);
	}
}
void XonoticSlider_loadCvars(entity me)
{
	if not(me.cvarName)
		return;

	me.setValue( me, cvar(me.cvarName) );
}
void XonoticSlider_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	cvar_set(me.cvarName, ftos(me.value));
}
#endif
