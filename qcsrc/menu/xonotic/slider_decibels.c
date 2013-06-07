#ifdef INTERFACE
CLASS(XonoticDecibelsSlider) EXTENDS(XonoticSlider)
	METHOD(XonoticDecibelsSlider, loadCvars, void(entity))
	METHOD(XonoticDecibelsSlider, saveCvars, void(entity))
	METHOD(XonoticDecibelsSlider, valueToText, string(entity, float))
ENDCLASS(XonoticDecibelsSlider)
entity makeXonoticDecibelsSlider(float, float, float, string);
#endif

#ifdef IMPLEMENTATION

float toDecibelOfSquare(float f)
{
	return 20.0 * log10(f);
}

float fromDecibelOfSquare(float f)
{
	return pow(10, f / 20.0);
}

entity makeXonoticDecibelsSlider(float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	entity me;
	me = spawnXonoticDecibelsSlider();
	me.configureXonoticSlider(me, theValueMin, theValueMax, theValueStep, theCvar);
	return me;
}
void XonoticDecibelsSlider_loadCvars(entity me)
{
	float v;

	if not(me.cvarName)
		return;

	v = cvar(me.cvarName);

	// snapping
	if(v > fromDecibelOfSquare(me.valueMax - 0.5 * me.valueStep))
		Slider_setValue(me, me.valueMax);
	else if(v < fromDecibelOfSquare(me.valueMin - 0.5 * me.valueStep))
		Slider_setValue(me, -1000000); // virtually infinite
	else
		Slider_setValue(me, me.valueStep * floor(0.5 + toDecibelOfSquare(v) / me.valueStep) );
}
void XonoticDecibelsSlider_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(me.value > me.valueMax - 0.5 * me.valueStep)
		cvar_set(me.cvarName, ftos(fromDecibelOfSquare(me.valueMax)));
	else if(me.value < me.valueMin - 0.5 * me.valueStep)
		cvar_set(me.cvarName, "0");
	else
		cvar_set(me.cvarName, ftos(fromDecibelOfSquare(me.value)));
}

string XonoticDecibelsSlider_valueToText(entity me, float v)
{
	if(v > me.valueMax - 0.5 * me.valueStep)
		return CTX(_("VOL^MAX"));
	else if(v < me.valueMin - 0.5 * me.valueStep)
		return CTX(_("VOL^OFF"));
	return sprintf(_("%s dB"), SUPER(XonoticDecibelsSlider).valueToText(me, v));
}

#endif
