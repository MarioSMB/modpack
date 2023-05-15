
void() jump_frames = [0, jump_frames]
{
	self.frame = self.castframes + self.walkframe;
	updatevwep();
	if (self.flags & FL_ONGROUND)
	{
		self.walkframe = 0;
	
		self.think = AnimatePlayer;
		self.nextthink = time + 0.1;
		return;
	}
	else if (self.walkframe < 4)
		self.walkframe = self.walkframe + 1;
	else if (self.velocity_z < 0)
	{
		if (self.frame < self.jumpframes)
			self.walkframe = self.walkframe + 1;
	}
}

void() jump1 = 
{
	face(0);
	self.walkframe = 1;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);
	self.velocity = '0 0 350' + v_forward * 300;
	jump_frames();
};