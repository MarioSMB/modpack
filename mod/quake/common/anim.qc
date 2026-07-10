#include "anim.qh"

/**
 * @param anim x = startframe, y = numframes, z = framerate
 */
void anim_set(entity e, vector anim, bool looping, bool override, bool restart)
{
	if (!anim) return;  // no animation was given to us! We can't use this.

	if (anim.x == e.animstate_startframe)
	{
		if (anim.y == e.animstate_numframes)
		{
			if (anim.z == e.animstate_framerate)
			{
				if (!restart) return;
				if (anim.y == 1)  // ZYM animation
					BITXOR_ASSIGN(e.effects, EF_RESTARTANIM_BIT);
			}
		}
	}
	e.animstate_startframe = anim.x;
	e.animstate_numframes = anim.y;
	e.animstate_framerate = anim.z;
	e.animstate_starttime = time - 0.1 * frametime;  // shift it a little bit into the past to prevent float inaccuracy hiccups
	e.animstate_endtime = e.animstate_starttime + e.animstate_numframes / e.animstate_framerate;
	e.animstate_looping = looping;
	e.animstate_override = override;
	e.frame = e.animstate_startframe;
	e.frame1time = time;
}

/**
 * Update e.frame based on its animstate relative to time
 */
void anim_update(entity e)
{
	if (time >= e.animstate_endtime)
	{
		if (e.animstate_looping)
		{
			e.animstate_starttime = e.animstate_endtime;
			e.animstate_endtime = e.animstate_starttime + e.animstate_numframes / e.animstate_framerate;
		}
		e.animstate_override = false;
	}
	float frameofs = bound(0, (time - e.animstate_starttime) * e.animstate_framerate, e.animstate_numframes - 1);
	e.frame = e.animstate_startframe + frameofs;
}
