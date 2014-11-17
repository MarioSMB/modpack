.float cnt;
.vector colormod;
.float rainbow;

vector rgb2color( float r, float g, float b)
{
	return eX*r + eY*g + eZ*b;
}

vector hsv2color(float h, float s, float v)
{
	h *= 6;
	float c = v*s;
	float m = v-c;
		
	float h1 = floor(h);
	float f = h - h1;
		
	float n = v - c * f;
	float k = v - c * (1 - f);
		
	if ( h1 == 0 )
		return rgb2color(v,k,m);
	if ( h1 == 1 )
		return rgb2color(n,v,m);
	if ( h1 == 2 )
		return rgb2color(m,v,k);
	if ( h1 == 3 )
		return rgb2color(m,n,v);
	if ( h1 == 4 )
		return rgb2color(k,m,v);
	return rgb2color(v,m,n);
}

float Ent_EditLight_Hue()
{
	if ( autocvar_cl_editlights_rainbowtime <= 0 )
		return random();
	return (time+self.rainbow) % autocvar_cl_editlights_rainbowtime / autocvar_cl_editlights_rainbowtime;
}

void Ent_EditLight_Draw()
{
	self.alpha = ((autocvar_cl_editlights > 0) ? 1 : -1);
	if(autocvar_cl_editlights >= 0)
		adddynamiclight(self.origin, self.cnt, self.colormod);

	if ( self.rainbow )
		self.colormod = hsv2color(Ent_EditLight_Hue(),0.75,1);
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
		if ( self.colormod == '-2 -2 -2' )
			self.rainbow = random() * autocvar_cl_editlights_rainbowtime;
		else
			self.rainbow = 0;
	}

	if(sf & 8)
	{
		self.cnt = ReadShort();
	}
}
