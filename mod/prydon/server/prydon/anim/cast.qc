#include "cast.qh"

#include "common.qh"
#include "../spells/cast.qh"
#include "../spells/spfx.qh"

void cast_frames(entity this)
{
	setthink(this, cast_frames);
	this.nextthink = time + 0.1;
	this.frame = this.frame + 1;
	
	float b = (this.castframes - this.poseframes) / this.castscenes;
	float f = (this.frame - this.poseframes) - 1;
	f = (f - (floor(f / b) * b)) + 1;
	float n = f - (b - 5);
	
	if(f >= b)
	{
		setthink(this, AnimatePlayer);
		this.nextthink = time + 0.1;
	}
	if(n > 0)
	{
		if(n == 1)
		{
			if(range_check(this, this.gotstuff, this.enemy))
				spell_fire(this, this.gotstuff);
		}
		create_fx(this, n, this.gotstuff);
	}
	face(this, 1);
}

void cast_selectscene(entity this)
{
	float b = (this.castframes - this.poseframes) / this.castscenes;
	this.frame = this.castframes - ((ceil(random() * this.castscenes) * b));
}

void cast1(entity this)
{
	cast_selectscene(this);
	cast_frames(this);
}