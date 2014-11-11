.float cnt;
.vector colormod;

void Ent_EditLight_Draw()
{
	adddynamiclight(self.origin, self.cnt, self.colormod);
}

void Ent_EditLight()
{
	float sf = ReadByte();

	if(sf & 1)
	{
		self.colormod_x = ReadCoord();
		self.colormod_y = ReadCoord();
		self.colormod_z = ReadCoord();

		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();

		self.cnt = ReadShort();

		setmodel(self, "models/runematch/rune.mdl");
		setsize(self, '-10 -10 -10', '10 10 10');

		self.draw = Ent_EditLight_Draw;
		self.solid = SOLID_TRIGGER;
		self.move_origin = self.origin;
		self.move_time = time;
		self.drawmask = MASK_NORMAL;
		self.alpha = 1;
	}

	if(sf & 2)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}

	if(sf & 4)
	{
		self.colormod_x = ReadCoord();
		self.colormod_y = ReadCoord();
		self.colormod_z = ReadCoord();
	}

	if(sf & 8)
	{
		self.cnt = ReadShort();
	}
}
