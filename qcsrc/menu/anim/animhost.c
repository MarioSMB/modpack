#ifdef INTERFACE
CLASS(AnimHost) EXTENDS(Object)
	METHOD(AnimHost, addAnim, void(entity, entity))
	METHOD(AnimHost, removeAnim, void(entity, entity))
	METHOD(AnimHost, removeAllAnim, void(entity))
	METHOD(AnimHost, removeObjAnim, void(entity, entity))
	METHOD(AnimHost, stopAllAnim, void(entity))
	METHOD(AnimHost, stopObjAnim, void(entity, entity))
	METHOD(AnimHost, resumeAllAnim, void(entity))
	METHOD(AnimHost, resumeObjAnim, void(entity, entity))
	METHOD(AnimHost, finishAllAnim, void(entity))
	METHOD(AnimHost, finishObjAnim, void(entity, entity))
	METHOD(AnimHost, tickAll, void(entity))
	ATTRIB(AnimHost, firstChild, entity, NULL)
	ATTRIB(AnimHost, lastChild, entity, NULL)
ENDCLASS(AnimHost)
.entity nextSibling;
.entity prevSibling;
#endif

#ifdef IMPLEMENTATION
void AnimHost_addAnim(entity me, entity other)
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
		me.firstChild = other;

	other.prevSibling = l;
	other.nextSibling = NULL;
	me.lastChild = other;
}

void AnimHost_removeAnim(entity me, entity other)
{
	if(other.parent != me)
		error("Can't remove from wrong AnimHost!");

	other.parent = NULL;

	entity n, p;
	n = other.nextSibling;
	p = other.prevSibling;

	if(p)
		p.nextSibling = n;
	else
		me.firstChild = n;

	if(n)
		n.prevSibling = p;
	else
		me.lastChild = p;
	remove(other);
}

void AnimHost_removeAllAnim(entity me)
{
	entity e, tmp;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		tmp = e;
		e = tmp.prevSibling;
		me.removeAnim(me, tmp);
	}
}

void AnimHost_removeObjAnim(entity me, entity obj)
{
	entity e, tmp;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if (e.object == obj)
		{
			tmp = e;
			e = tmp.prevSibling;
			me.removeAnim(me, tmp);
		}
	}
}

void AnimHost_stopAllAnim(entity me)
{
	entity e;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		e.stopAnim(e);
	}
}

void AnimHost_stopObjAnim(entity me, entity obj)
{
	entity e;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if (e.object == obj)
		{
			e.stopAnim(e);
		}
	}
}

void AnimHost_resumeAllAnim(entity me)
{
	entity e;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		e.resumeAnim(e);
	}
}

void AnimHost_resumeObjAnim(entity me, entity obj)
{
	entity e;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if (e.object == obj)
		{
			e.resumeAnim(e);
		}
	}
}

void AnimHost_finishAllAnim(entity me)
{
	entity e, tmp;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		tmp = e;
		e = tmp.prevSibling;
		tmp.finishAnim(tmp);
	}
}

void AnimHost_finishObjAnim(entity me, entity obj)
{
	entity e, tmp;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if (e.object == obj)
		{
			tmp = e;
			e = tmp.prevSibling;
			tmp.finishAnim(tmp);
		}
	}
}

void AnimHost_tickAll(entity me)
{
	entity e, tmp;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		e.tick(e, time);
		if (e.isFinished(e))
		{
			tmp = e;
			e = tmp.prevSibling;
			me.removeAnim(me, tmp);
		}
	}
}
#endif
