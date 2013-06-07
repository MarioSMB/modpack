#ifdef INTERFACE
CLASS(Easing) EXTENDS(Animation)
	METHOD(Easing, calcValue, float(entity, float, float, float, float))
	METHOD(Easing, setMath, void(entity, float(float, float, float, float)))
	ATTRIB(Easing, math, float(float, float, float, float), easingLinear)
ENDCLASS(Easing)
entity makeHostedEasing(entity, void(entity, float), float(float, float, float, float), float, float, float);
entity makeEasing(entity, void(entity, float), float(float, float, float, float), float, float, float, float);
float easingLinear(float, float, float, float);
float easingQuadIn(float, float, float, float);
float easingQuadOut(float, float, float, float);
float easingQuadInOut(float, float, float, float);
#endif

#ifdef IMPLEMENTATION
entity makeHostedEasing(entity obj, void(entity, float) objSetter, float(float, float, float, float) func, float animDuration, float animStartValue, float animEnd)
{
	entity me;
	me = makeEasing(obj, objSetter, func, time, animDuration, animStartValue, animEnd);
	anim.addAnim(anim, me);
	return me;
}

entity makeEasing(entity obj, void(entity, float) objSetter, float(float, float, float, float) func, float animStartTime, float animDuration, float animStartValue, float animEnd)
{
	entity me;
	me = spawnEasing();
	me.configureAnimation(me, obj, objSetter, animStartTime, animDuration, animStartValue, animEnd);
	me.setMath(me, func);
	return me;
}

float Easing_calcValue(entity me, float tickTime, float animDuration, float animStart, float animDelta)
{
	return me.math(tickTime, animDuration, animStart, animDelta);
}

void Easing_setMath(entity me, float(float, float, float, float) func)
{
	me.math = func;
}

float easingLinear(float tickTime, float animDuration, float animStart, float animDelta)
{
	return (animDelta * (tickTime / animDuration)) + animStart;
}

float easingQuadIn(float tickTime, float animDuration, float animStart, float animDelta)
{
	float frac = tickTime / animDuration;
	return (animDelta * frac * frac) + animStart;
}

float easingQuadOut(float tickTime, float animDuration, float animStart, float animDelta)
{
	float frac = tickTime / animDuration;
	return (-animDelta * frac * (frac - 2)) + animStart;
}

float easingQuadInOut(float tickTime, float animDuration, float animStart, float animDelta)
{
	if (tickTime < (animDuration / 2))
	{
		return easingQuadIn(tickTime, (animDuration / 2), animStart, (animDelta / 2));
	}
	else
	{
		return easingQuadOut((tickTime - (animDuration / 2)), (animDuration / 2), (animStart + (animDelta / 2)), (animDelta / 2));
	}
}

#endif
