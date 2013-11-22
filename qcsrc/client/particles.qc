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

void Net_ReadNexgunBeamParticle()
{
	vector shotorg, endpos;
	float charge;
	string s;
	shotorg_x = ReadCoord(); shotorg_y = ReadCoord(); shotorg_z = ReadCoord();
	endpos_x = ReadCoord(); endpos_y = ReadCoord(); endpos_z = ReadCoord();
	charge = ReadByte() / 255.0;

	pointparticles(particleeffectnum("nex_muzzleflash"), shotorg, normalize(endpos - shotorg) * 1000, 1);

	//draw either the old v2.3 beam or the new beam
	charge = sqrt(charge); // divide evenly among trail spacing and alpha
	particles_alphamin = particles_alphamax = particles_fade = charge;

	s = ((charge >= 0.95) ? "nex_beam_charged" : "nex_beam");

	if (autocvar_cl_particles_oldnexbeam && (getstati(STAT_ALLOW_OLDNEXBEAM) || isdemo()))
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum("TE_TEI_G3NEUTRAL"), shotorg, endpos, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);
	else
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum(s), shotorg, endpos, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);
}

.vector sw_shotorg;
.vector sw_endpos;
.float sw_spread_max;
.float sw_spread_min;
.float sw_time;

void Draw_Shockwave()
{
	float a = bound(0, (0.5 - ((time - self.sw_time) / 0.4)), 0.5);

	if(!a) { remove(self); }
	
	vector deviation, angle;

	vector sw_color = getcsqcplayercolor(self.sv_entnum); // GetTeamRGB(GetPlayerColor(self.sv_entnum));

	vector first_min_end = '0 0 0', prev_min_end = '0 0 0', new_min_end = '0 0 0';
	vector first_max_end = '0 0 0', prev_max_end = '0 0 0', new_max_end = '0 0 0';

	float new_max_dist, new_min_dist;
	
	vector shotdir = normalize(self.sw_endpos - self.sw_shotorg);
	vectorvectors(shotdir);
	vector right = v_right;
	vector up = v_up;
	
	float counter, dist_before_normal = 200, shots = 20;
	
	vector min_end = ((self.sw_shotorg + (shotdir * dist_before_normal)) + (up * self.sw_spread_min));
	vector max_end = (self.sw_endpos + (up * self.sw_spread_max));
	
	float spread_to_min = vlen(normalize(min_end - self.sw_shotorg) - shotdir);
	float spread_to_max = vlen(normalize(max_end - min_end) - shotdir);
	
	for(counter = 0; counter < shots; ++counter)
	{
		// perfect circle effect lines
		angle = '0 0 0';
		makevectors('0 360 0' * (0.75 + (counter - 0.5) / shots));
		angle_y = v_forward_x;
		angle_z = v_forward_y;

		// first do the spread_to_min effect
		deviation = angle * spread_to_min;
		deviation = ((shotdir + (right * deviation_y) + (up * deviation_z)));
		new_min_dist = dist_before_normal;
		new_min_end = (self.sw_shotorg + (deviation * new_min_dist));
		//te_lightning2(world, new_min_end, self.sw_shotorg);

		// then calculate spread_to_max effect
		deviation = angle * spread_to_max;
		deviation = ((shotdir + (right * deviation_y) + (up * deviation_z)));
		new_max_dist = vlen(new_min_end - self.sw_endpos);
		new_max_end = (new_min_end + (deviation * new_max_dist));
		//te_lightning2(world, new_end, prev_min_end);
		

		if(counter == 0)
		{
			first_min_end = new_min_end;
			first_max_end = new_max_end;
		}

		if(counter >= 1)
		{
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(new_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(self.sw_shotorg, '0 0 0', sw_color, a);
			R_EndPolygon();

			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(new_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_max_end, '0 0 0', sw_color, a);
			R_PolygonVertex(new_max_end, '0 0 0', sw_color, a);
			R_EndPolygon();
		}

		prev_min_end = new_min_end;
		prev_max_end = new_max_end;

		if((counter + 1) == shots)
		{
			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(first_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(self.sw_shotorg, '0 0 0', sw_color, a);
			R_EndPolygon();

			R_BeginPolygon("", DRAWFLAG_NORMAL);
			R_PolygonVertex(first_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_min_end, '0 0 0', sw_color, a);
			R_PolygonVertex(prev_max_end, '0 0 0', sw_color, a);
			R_PolygonVertex(first_max_end, '0 0 0', sw_color, a);
			R_EndPolygon();
		}
	}
}

void Net_ReadShockwaveParticle()
{
	entity shockwave;
	shockwave = spawn();
	shockwave.draw = Draw_Shockwave;
	
	shockwave.sw_shotorg_x = ReadCoord(); shockwave.sw_shotorg_y = ReadCoord(); shockwave.sw_shotorg_z = ReadCoord();
	shockwave.sw_endpos_x  = ReadCoord(); shockwave.sw_endpos_y  = ReadCoord(); shockwave.sw_endpos_z  = ReadCoord();
	
	shockwave.sw_spread_max = ReadByte();
	shockwave.sw_spread_min = ReadByte();

	shockwave.sv_entnum = ReadByte();

	shockwave.sw_time = time;
}
