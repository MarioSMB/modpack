.float frame1time;
.float lifetime, fadetime;
.float teleport_time;
.float scale1, scale2;

void ModelEffect_Draw()
{
	self.angles = self.angles + frametime * self.avelocity;
	setorigin(self, self.origin + frametime * self.velocity);
	self.scale = self.scale1 + (self.scale2 - self.scale1) * (time - self.teleport_time) / (self.lifetime + self.fadetime - self.teleport_time);
	self.alpha = self.cnt * bound(0, 1 - (time - self.lifetime) / self.fadetime, 1);
	if(self.alpha < ALPHA_MIN_VISIBLE)
	{
		remove(self);
		return;
	}
	self.drawmask = MASK_NORMAL;
	if(self.scale <= 0)
	{
		self.drawmask = 0;
		return;
	}
}

void Ent_ModelEffect(float isNew)
{
	float f;
	entity e;

	self.classname = "modeleffect_spawner";

	f = ReadByte();

	e = spawn();
	e.classname = "modeleffect";
	e.model = "from network";
	e.modelindex = ReadShort();
	e.skin = ReadByte();
	e.frame = ReadByte();
	e.frame1time = time;
	e.origin_x = ReadCoord();
	e.origin_y = ReadCoord();
	e.origin_z = ReadCoord();
	setorigin(e, e.origin);
	if(f & 1)
	{
		e.velocity_x = ReadCoord();
		e.velocity_y = ReadCoord();
		e.velocity_z = ReadCoord();
	}
	if(f & 2)
	{
		e.angles_x = ReadAngle();
		e.angles_y = ReadAngle();
		e.angles_z = ReadAngle();
	}
	if(f & 4)
	{
		e.avelocity_x = ReadAngle();
		e.avelocity_y = ReadAngle();
		e.avelocity_z = ReadAngle();
	}
	e.scale1 = ReadShort() / 256.0;
	e.scale2 = ReadShort() / 256.0;
	e.lifetime = time + ReadByte() * 0.01;
	e.fadetime = ReadByte() * 0.01;
	e.teleport_time = time;
	e.cnt = ReadByte() / 255.0; // actually alpha

	e.draw = ModelEffect_Draw;

	if(!isNew)
		remove(e); // yes, this IS stupid, but I don't need to duplicate all the read* stuff then
}
