.float dphitcontentsmask;

.float cnt; // effect number
.vector velocity; // particle velocity
.float waterlevel; // direction jitter
.float count; // count multiplier
.float impulse; // density
.string noise; // sound
.float atten;
.float volume;
.float absolute; // 1 = count per second is absolute, 2 = only spawn at toggle
.vector movedir; // trace direction

void Draw_PointParticles()
{
	float n, i, fail;
	vector p;
	vector sz;
	vector o;
	o = self.origin;
	sz = self.maxs - self.mins;
	n = BGMScript(self);
	if(self.absolute == 2)
	{
		if(n >= 0)
			n = self.just_toggled ? self.impulse : 0;
		else
			n = self.impulse * drawframetime;
	}
	else
	{
		n *= self.impulse * drawframetime;
		if(self.just_toggled)
			if(n < 1)
				n = 1;
	}
	if(n == 0)
		return;
	fail = 0;
	for(i = random(); i <= n && fail <= 64*n; ++i)
	{
		p = o + self.mins;
		p_x += random() * sz_x;
		p_y += random() * sz_y;
		p_z += random() * sz_z;
		if(WarpZoneLib_BoxTouchesBrush(p, p, self, world))
		{
			if(self.movedir != '0 0 0')
			{
				traceline(p, p + normalize(self.movedir) * 4096, 0, world);
				p = trace_endpos;
				pointparticles(self.cnt, p, trace_plane_normal * vlen(self.movedir) + self.velocity + randomvec() * self.waterlevel, self.count);
			}
			else
			{
				pointparticles(self.cnt, p, self.velocity + randomvec() * self.waterlevel, self.count);
			}
			if(self.noise != "")
			{
				setorigin(self, p);
				sound(self, CH_AMBIENT, self.noise, VOL_BASE * self.volume, self.atten);
			}
			self.just_toggled = 0;
		}
		else if(self.absolute)
		{
			++fail;
			--i;
		}
	}
	setorigin(self, o);
}

void Ent_PointParticles_Remove()
{
	if(self.noise)
		strunzone(self.noise);
	self.noise = string_null;
	if(self.bgmscript)
		strunzone(self.bgmscript);
	self.bgmscript = string_null;
}

void Ent_PointParticles()
{
	float f, i;
	vector v;
	f = ReadByte();
	if(f & 2)
	{
		i = ReadCoord(); // density (<0: point, >0: volume)
		if(i && !self.impulse && self.cnt) // self.cnt check is so it only happens if the ent already existed
			self.just_toggled = 1;
		self.impulse = i;
	}
	if(f & 4)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}
	if(f & 1)
	{
		self.modelindex = ReadShort();
		if(f & 0x80)
		{
			if(self.modelindex)
			{
				self.mins_x = ReadCoord();
				self.mins_y = ReadCoord();
				self.mins_z = ReadCoord();
				self.maxs_x = ReadCoord();
				self.maxs_y = ReadCoord();
				self.maxs_z = ReadCoord();
			}
			else
			{
				self.mins    = '0 0 0';
				self.maxs_x = ReadCoord();
				self.maxs_y = ReadCoord();
				self.maxs_z = ReadCoord();
			}
		}
		else
		{
			self.mins = self.maxs = '0 0 0';
		}

		self.cnt = ReadShort(); // effect number

		if(f & 0x20)
		{
			self.velocity = decompressShortVector(ReadShort());
			self.movedir = decompressShortVector(ReadShort());
		}
		else
		{
			self.velocity = self.movedir = '0 0 0';
		}
		if(f & 0x40)
		{
			self.waterlevel = ReadShort() / 16.0;
			self.count = ReadByte() / 16.0;
		}
		else
		{
			self.waterlevel = 0;
			self.count = 1;
		}
		if(self.noise)
			strunzone(self.noise);
		if(self.bgmscript)
			strunzone(self.bgmscript);
		self.noise = strzone(ReadString());
		if(self.noise != "")
		{
			self.atten = ReadByte() / 64.0;
			self.volume = ReadByte() / 255.0;
		}
		self.bgmscript = strzone(ReadString());
		if(self.bgmscript != "")
		{
			self.bgmscriptattack = ReadByte() / 64.0;
			self.bgmscriptdecay = ReadByte() / 64.0;
			self.bgmscriptsustain = ReadByte() / 255.0;
			self.bgmscriptrelease = ReadByte() / 64.0;
		}
		BGMScript_InitEntity(self);
	}

	if(f & 2)
	{
		self.absolute = (self.impulse >= 0);
		if(!self.absolute)
		{
			v = self.maxs - self.mins;
			self.impulse *= -v_x * v_y * v_z / 262144; // relative: particles per 64^3 cube
		}
	}

	if(f & 0x10)
		self.absolute = 2;

	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.solid = SOLID_NOT;
	self.draw = Draw_PointParticles;
	self.entremove = Ent_PointParticles_Remove;
}

.float glow_color; // palette index
void Draw_Rain()
{
    te_particlerain(self.origin + self.mins, self.origin + self.maxs, self.velocity, floor(self.count * drawframetime + random()), self.glow_color);
}

void Draw_Snow()
{
    te_particlesnow(self.origin + self.mins, self.origin + self.maxs, self.velocity, floor(self.count * drawframetime + random()), self.glow_color);
}

void Ent_RainOrSnow()
{
	self.impulse = ReadByte(); // Rain, Snow, or Whatever
	self.origin_x = ReadCoord();
	self.origin_y = ReadCoord();
	self.origin_z = ReadCoord();
	self.maxs_x = ReadCoord();
	self.maxs_y = ReadCoord();
	self.maxs_z = ReadCoord();
	self.velocity = decompressShortVector(ReadShort());
	self.count = ReadShort() * 10;
	self.glow_color = ReadByte(); // color

	self.mins    = -0.5 * self.maxs;
	self.maxs    =  0.5 * self.maxs;
	self.origin  = self.origin - self.mins;

	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.solid = SOLID_NOT;
	if(self.impulse)
		self.draw = Draw_Rain;
	else
		self.draw = Draw_Snow;
}

entity zcurve;
void zcurveparticles(float effectnum, vector start, vector end, float end_dz, float speed, float depth)
{
	// end_dz:
	//   IF IT WERE A STRAIGHT LINE, it'd end end_dz above end

	vector mid;
	mid = (start + end) * 0.5;

	end_dz *= 0.25;
	mid_z += end_dz;

	--depth;
	if(depth < 0 || normalize(mid - start) * normalize(end - start) > 0.999999)
	// TODO make this a variable threshold
	// currently: 0.081 degrees
	// 0.99999 would be 0.256 degrees and is visible
	{
		zcurve.velocity = speed * normalize(end - start);
		trailparticles(zcurve, effectnum, start, end);
	}
	else
	{
		zcurveparticles(effectnum, start, mid, end_dz, speed, depth);
		zcurveparticles(effectnum, mid, end, end_dz, speed, depth);
	}
}

void Net_ReadZCurveParticles()
{
	vector start, end;
	float end_dz;
	float effectnum, speed;

	if(!zcurve)
	{
		zcurve = spawn();
		zcurve.classname = "zcurve";
	}

	effectnum = ReadShort();

	start_x = ReadCoord();
	start_y = ReadCoord();
	start_z = ReadCoord();

	do
	{
		end_x = ReadCoord();
		end_y = ReadCoord();
		end_z = ReadCoord();
		end_dz = ReadCoord();
		speed = ReadShort();
		zcurveparticles(effectnum, start, end, end_dz, 16 * (speed & 0x7FFF), 5); // at most 32 segments
	}
	while(!(speed & 0x8000));
}

void Net_ReadNexgunBeamParticle()
{
	vector shotorg, endpos;
	float charge;
	shotorg_x = ReadCoord(); shotorg_y = ReadCoord(); shotorg_z = ReadCoord();
	endpos_x = ReadCoord(); endpos_y = ReadCoord(); endpos_z = ReadCoord();
	charge = ReadByte() / 255.0;
	
	pointparticles(particleeffectnum("nex_muzzleflash"), shotorg, normalize(endpos - shotorg) * 1000, 1);
	
	//draw either the old v2.3 beam or the new beam
	charge = sqrt(charge); // divide evenly among trail spacing and alpha
	particles_alphamin = particles_alphamax = charge;
	if (autocvar_cl_particles_oldnexbeam && (getstati(STAT_ALLOW_OLDNEXBEAM) || isdemo()))
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum("TE_TEI_G3"), shotorg, endpos, charge, 1);
	else
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum("nex_beam"), shotorg, endpos, charge, 1);
}
