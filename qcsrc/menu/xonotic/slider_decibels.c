#ifdef INTERFACE
CLASS(XonoticDecibelsSlider) EXTENDS(XonoticSlider)
	METHOD(XonoticDecibelsSlider, loadCvars, void(entity))
	METHOD(XonoticDecibelsSlider, saveCvars, void(entity))
	METHOD(XonoticDecibelsSlider, valueToText, string(entity, float))
ENDCLASS(XonoticDecibelsSlider)
entity makeXonoticDecibelsSlider(float, float, float, string);
#endif

#ifdef IMPLEMENTATION

float toDecibelOfSquare(float f, float mi)
{
	float A = log(10) / 20; // note: about 0.115; inverse: about 8.686
	if(mi != 0)
	{
		// linear scale part
		float t = 1 / A + mi;
		float y = exp(1 + A * mi);
		if(f <= y)
			return mi + (t - mi) * (f / y);
	}
	return log(f) / A;
}

float fromDecibelOfSquare(float f, float mi)
{
	float A = log(10) / 20; // note: about 0.115; inverse: about 8.686
	if(mi != 0)
	{
		// linear scale part
		float t = 1 / A + mi;
		float y = exp(1 + A * mi);
		if(f <= t)
			return y * ((f - mi) / (t - mi));
	}
	return exp(A * f);
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
	if(v > fromDecibelOfSquare(me.valueMax - 0.5 * me.valueStep, me.valueMin))
		Slider_setValue(me, me.valueMax);
	else
		Slider_setValue(me, me.valueStep * floor(0.5 + toDecibelOfSquare(v, me.valueMin) / me.valueStep) );
}
void XonoticDecibelsSlider_saveCvars(entity me)
{
	if not(me.cvarName)
		return;

	if(me.value > me.valueMax - 0.5 * me.valueStep)
		cvar_set(me.cvarName, ftos(fromDecibelOfSquare(me.valueMax, me.valueMin)));
	else
		cvar_set(me.cvarName, ftos(fromDecibelOfSquare(me.value, me.valueMin)));
}

float autocvar_menu_snd_sliderscale;
string XonoticDecibelsSlider_valueToText(entity me, float v)
{
	if(v > me.valueMax - 0.5 * me.valueStep)
		return CTX(_("VOL^MAX"));
	else if(v <= me.valueMin)
		return CTX(_("VOL^OFF"));
	else if(autocvar_menu_snd_sliderscale == 3) // fake percent scale
		return sprintf(_("%d %%"), (v - me.valueMin) / (me.valueMax - me.valueMin) * 100);
	else if(autocvar_menu_snd_sliderscale == 2) // 0..10 scale
		return sprintf(_("%.1f"), (v - me.valueMin) / (me.valueMax - me.valueMin) * 10);
	else if(autocvar_menu_snd_sliderscale == 1) // real percent scale
		return sprintf(_("%.2f %%"), fromDecibelOfSquare(v, me.valueMin) * 100);
	else // decibel scale
		return sprintf(_("%s dB"), ftos_decimals(toDecibelOfSquare(fromDecibelOfSquare(v, me.valueMin), 0), me.valueDigits));
}

void _TEST_XonoticDecibelsSlider()
{
	float i;
	for(i = -400; i < 0; ++i)
	{
		float db = i * 0.1;
		float v = fromDecibelOfSquare(db, -40);
		float dbv = toDecibelOfSquare(v, -40);
		float d = dbv - db;
		print(sprintf("%f -> %f -> %f (diff: %f)\n", db, v, dbv, d));
		TEST_Check(fabs(d) > 0.02);
	}
	TEST_OK();
}

#endif
