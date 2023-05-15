void() cast_frames =
{
	local float b, f, n;
	self.think = cast_frames;
	self.nextthink = time + 0.1;
	self.frame = self.frame + 1;
	
	b = (self.castframes - self.poseframes) / self.castscenes;
	f = (self.frame - self.poseframes) - 1;
	f = (f - (floor(f / b) * b)) + 1;
	n = f - (b - 5);
	
	if (f >= b)
	{
		self.think = AnimatePlayer;
		self.nextthink = time + 0.1;
	}
	if (n > 0)
	{
		if (n == 1)
		{
			if (range_check(self.gotstuff, self.enemy))
				spell_fire(self.gotstuff);
		}
		create_fx(n, self.gotstuff);
	}
	face(1);
};

void() cast_selectscene =
{
	local float b;
	b = (self.castframes - self.poseframes) / self.castscenes;
	self.frame = self.castframes - ((ceil(random() * self.castscenes) * b));
};

void() cast1 = 
{
	cast_selectscene();
	cast_frames();
};