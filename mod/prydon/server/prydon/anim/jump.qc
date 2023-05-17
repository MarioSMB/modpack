#include "jump.qh"

#include "common.qh"

void jump_frames(entity this)
{
	set_anim(this, 0, jump_frames);
	this.frame = this.castframes + this.walkframe;
	updatevwep(this);
	if(IS_ONGROUND(this))
	{
		this.walkframe = 0;

		setthink(this, AnimatePlayer);
		this.nextthink = time + 0.1;
		return;
	}
	else if(this.walkframe < 4)
		this.walkframe = this.walkframe + 1;
	else if(this.velocity_z < 0)
	{
		if(this.frame < this.jumpframes)
			this.walkframe = this.walkframe + 1;
	}
}

void jump1(entity this)
{
	face(this, 0);
	this.walkframe = 1;
	UNSET_ONGROUND(this);
	makevectors(this.angles);
	this.velocity = '0 0 350' + v_forward * 300;
	jump_frames(this);
}
