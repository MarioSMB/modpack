#ifdef INTERFACE
CLASS(Keyframe) EXTENDS(Animation)
	METHOD(Keyframe, addEasing, entity(entity, float, float, float(float, float, float, float)))
	METHOD(Keyframe, addAnim, void(entity, entity))
	METHOD(Keyframe, calcValue, float(entity, float, float, float, float))
	ATTRIB(Keyframe, currentChild, entity, NULL)
	ATTRIB(Keyframe, firstChild, entity, NULL)
	ATTRIB(Keyframe, lastChild, entity, NULL)
ENDCLASS(Keyframe)
entity makeHostedKeyframe(entity, void(entity, float), float, float, float);
entity makeKeyframe(entity, void(entity, float), float, float, float);
float getNewChildStart(entity);
float getNewChildDuration(entity, float);
float getNewChildValue(entity);
#endif

#ifdef IMPLEMENTATION
entity makeHostedKeyframe(entity obj, void(entity, float) objSetter, float animDuration, float animStart, float animEnd)
{
	entity me;
	me = makeKeyframe(obj, objSetter, animDuration, animStart, animEnd);
	anim.addAnim(anim, me);
	return me;
}

entity makeKeyframe(entity obj, void(entity, float) objSetter, float animDuration, float animStart, float animEnd)
{
	entity me;
	me = spawnKeyframe();
	me.configureAnimation(me, obj, objSetter, time, animDuration, animStart, animEnd);
	return me;
}

entity Keyframe_addEasing(entity me, float animDurationTime, float animEnd, float(float, float, float, float) func)
{
	entity other;
	other = makeEasing(me.object, me.setter, func, getNewChildStart(me), getNewChildDuration(me, animDurationTime), getNewChildValue(me), animEnd);
	me.addAnim(me, other);
	return other;
}

float getNewChildStart(entity me)
{
	if (me.lastChild)
		return (me.lastChild.startTime + me.lastChild.duration);
	else
		return 0;
}

float getNewChildDuration(entity me, float durationTime)
{
	float dura, maxDura;
	maxDura = me.duration;
	if (me.lastChild) maxDura = maxDura - (me.lastChild.startTime + me.lastChild.duration);
	dura = durationTime;
	if (0 >= dura || dura > maxDura) dura = maxDura;
	return dura;
}

float getNewChildValue(entity me)
{
	if (me.lastChild)
		return (me.lastChild.startValue + me.lastChild.delta);
	else
		return me.startValue;
}

void Keyframe_addAnim(entity me, entity other)
{
	if(other.parent)
		error("Can't add already added anim!");

	if(other.isFinished(other))
		error("Can't add finished anim!");

	other.parent = me;

	entity l;
	l = me.lastChild;

	if(l)
		l.nextSibling = other;
	else
	{
		me.currentChild = other;
		me.firstChild = other;
	}

	other.prevSibling = l;
	other.nextSibling = NULL;
	me.lastChild = other;
}

float Keyframe_calcValue(entity me, float tickTime, float animDuration, float animStartValue, float animDelta)
{
	if (me.currentChild)
		if (me.currentChild.isFinished(me.currentChild))
			me.currentChild = me.currentChild.nextSibling;

	if (me.currentChild)
	{
		me.currentChild.tick(me.currentChild, tickTime);
		return me.currentChild.value;
	}

	return animStartValue + animDelta;
}
#endif
