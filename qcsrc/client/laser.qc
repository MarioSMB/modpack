// a laser goes from origin in direction angles
// it has color 'colormod'
// and stops when something is in the way
.float cnt; // end effect
.vector colormod;
.float state; // on-off
.float count; // flags for the laser
.vector velocity;
.float alpha;
.float scale; // scaling factor of the thickness
.float modelscale; // scaling factor of the dlight

void Draw_Laser()
{
	if(!self.state)
		return;
	InterpolateOrigin_Do();
	if(self.count & 0x80)
	{
		if(self.count & 0x10)
		{
			trace_endpos = self.velocity,
			trace_dphitq3surfaceflags = 0;
		}
		else
			traceline(self.origin, self.velocity, 0, self);
	}
	else
	{
		if(self.count & 0x10)
		{
			makevectors(self.angles);
			trace_endpos = self.origin + v_forward * 1048576;
			trace_dphitq3surfaceflags = Q3SURFACEFLAG_SKY;
		}
		else
		{
			makevectors(self.angles);
			traceline(self.origin, self.origin + v_forward * 32768, 0, self);
			if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
				trace_endpos = self.origin + v_forward * 1048576;
		}
	}
	if(self.scale != 0)
	{
		if(self.alpha)
		{
			Draw_CylindricLine(self.origin, trace_endpos, self.scale, "particles/laserbeam", 0, time * 3, self.colormod, self.alpha, DRAWFLAG_NORMAL, view_origin);
		}
		else
		{
			Draw_CylindricLine(self.origin, trace_endpos, self.scale, "particles/laserbeam", 0, time * 3, self.colormod, 0.5, DRAWFLAG_ADDITIVE, view_origin);
		}
	}
	if (!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
	{
		if(self.cnt >= 0)
			pointparticles(self.cnt, trace_endpos, trace_plane_normal, drawframetime * 1000);
		if(self.colormod != '0 0 0' && self.modelscale != 0)
			adddynamiclight(trace_endpos + trace_plane_normal * 1, self.modelscale, self.colormod * 5);
	}
}

void Ent_Laser()
{
	float f;
	InterpolateOrigin_Undo();

	// 30 bytes, or 13 bytes for just moving
	f = ReadByte();
	self.count = (f & 0xF0);

	if(self.count & 0x80)
		self.iflags = IFLAG_VELOCITY | IFLAG_ORIGIN;
	else
		self.iflags = IFLAG_ANGLES | IFLAG_ORIGIN;

	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}
	if(f & 8)
	{
		self.colormod_x = ReadByte() / 255.0;
		self.colormod_y = ReadByte() / 255.0;
		self.colormod_z = ReadByte() / 255.0;
		if(f & 0x40)
			self.alpha = ReadByte() / 255.0;
		else
			self.alpha = 0;
		self.scale = 2;
		self.modelscale = 50;
		if(f & 0x20)
		{
			self.scale *= ReadByte() / 16.0; // beam radius
			self.modelscale *= ReadByte() / 16.0; // dlight radius
		}
		if((f & 0x80) || !(f & 0x10))
			self.cnt = ReadShort() - 1; // effect number
		else
			self.cnt = 0;
	}
	if(f & 2)
	{
		if(f & 0x80)
		{
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
		}
		else
		{
			self.angles_x = ReadAngle();
			self.angles_y = ReadAngle();
		}
	}
	if(f & 4)
		self.state = ReadByte();
	InterpolateOrigin_Note();
	self.draw = Draw_Laser;
}
