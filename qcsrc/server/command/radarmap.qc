// ===============================================
//	Generates radar map images for use in the HUD
// ===============================================

float FullTraceFraction(vector a, vector mi, vector ma, vector b)
{
	vector c;
	float white, black;

	white = 0.001;
	black = 0.001;

	c = a;

	float n, m;
	n = m = 0;

	while(vlen(c - b) > 1)
	{
		++m;

		tracebox(c, mi, ma, b, MOVE_WORLDONLY, world);
		++n;

		if(!trace_startsolid)
		{
			black += vlen(trace_endpos - c);
			c = trace_endpos;
		}

		n += tracebox_inverted(c, mi, ma, b, MOVE_WORLDONLY, world, FALSE);

		white += vlen(trace_endpos - c);
		c = trace_endpos;
	}

	if(n > 200)
		dprint("HOLY SHIT! FullTraceFraction: ", ftos(n), " total traces, ", ftos(m), " iterations\n");

	return white / (black + white);
}
float RadarMapAtPoint_Trace(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector a, b, mi, ma;

	mi = '0 0 0';
	ma = '1 0 0' * w + '0 1 0' * h;
	a = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;
	b = '1 0 0' * x + '0 1 0' * y + '0 0 1' * (zsize + zmin);

	return FullTraceFraction(a, mi, ma, b);
}
float RadarMapAtPoint_LineBlock(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector o, mi, ma;
	float i, r;
	vector dz;

	q = 256 * q - 1;
	// 256q-1 is the ideal sample count to map equal amount of sample values to one pixel value

	mi = '0 0 0';
	dz = (zsize / q) * '0 0 1';
	ma = '1 0 0' * w + '0 1 0' * h + dz;
	o = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;

	if(x < world.absmin_x - w)
		return 0;
	if(y < world.absmin_y - h)
		return 0;
	if(x > world.absmax_x)
		return 0;
	if(y > world.absmax_y)
		return 0;

	r = 0;
	for(i = 0; i < q; ++i)
	{
		vector v1, v2;
		v1 = v2 = o + dz * i + mi;
		v1_x += random() * (ma_x - mi_x);
		v1_y += random() * (ma_y - mi_y);
		v1_z += random() * (ma_z - mi_z);
		v2_x += random() * (ma_x - mi_x);
		v2_y += random() * (ma_y - mi_y);
		v2_z += random() * (ma_z - mi_z);
		traceline(v1, v2, MOVE_WORLDONLY, world);
		if(trace_startsolid || trace_fraction < 1)
			++r;
	}
	return r / q;
}
float RadarMapAtPoint_Block(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector o, mi, ma;
	float i, r;
	vector dz;

	q = 256 * q - 1;
	// 256q-1 is the ideal sample count to map equal amount of sample values to one pixel value

	mi = '0 0 0';
	dz = (zsize / q) * '0 0 1';
	ma = '1 0 0' * w + '0 1 0' * h + dz;
	o = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;

	if(x < world.absmin_x - w)
		return 0;
	if(y < world.absmin_y - h)
		return 0;
	if(x > world.absmax_x)
		return 0;
	if(y > world.absmax_y)
		return 0;

	r = 0;
	for(i = 0; i < q; ++i)
	{
		tracebox(o + dz * i, mi, ma, o + dz * i, MOVE_WORLDONLY, world);
		if(trace_startsolid)
			++r;
	}
	return r / q;
}
float RadarMapAtPoint_Sample(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector a, b, mi, ma;

	q *= 4; // choose q so it matches the regular algorithm in speed

	q = 256 * q - 1;
	// 256q-1 is the ideal sample count to map equal amount of sample values to one pixel value

	mi = '0 0 0';
	ma = '1 0 0' * w + '0 1 0' * h;
	a = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;
	b = '1 0 0' * w + '0 1 0' * h + '0 0 1' * zsize;

	float c, i;
	c = 0;

	for(i = 0; i < q; ++i)
	{
		vector v;
		v_x = a_x + random() * b_x;
		v_y = a_y + random() * b_y;
		v_z = a_z + random() * b_z;
		traceline(v, v, MOVE_WORLDONLY, world);
		if(trace_startsolid)
			++c;
	}

	return c / q;
}
void sharpen_set(float x, float v)
{
	sharpen_buffer[x + 2 * RADAR_WIDTH_MAX] = v;
}
float sharpen_getpixel(float x, float y)
{
	if(x < 0)
		return 0;
	if(x >= RADAR_WIDTH_MAX)
		return 0;
	if(y < 0)
		return 0;
	if(y > 2)
		return 0;
	return sharpen_buffer[x + y * RADAR_WIDTH_MAX];
}
float sharpen_get(float x, float a)
{
	float sum;
	sum = sharpen_getpixel(x, 1);
	if(a == 0)
		return sum;
	sum *= (8 + 1/a);
	sum -= sharpen_getpixel(x - 1, 0);
	sum -= sharpen_getpixel(x - 1, 1);
	sum -= sharpen_getpixel(x - 1, 2);
	sum -= sharpen_getpixel(x + 1, 0);
	sum -= sharpen_getpixel(x + 1, 1);
	sum -= sharpen_getpixel(x + 1, 2);
	sum -= sharpen_getpixel(x, 0);
	sum -= sharpen_getpixel(x, 2);
	return bound(0, sum * a, 1);
}
void sharpen_shift(float w)
{
	float i;
	for(i = 0; i < w; ++i)
	{
		sharpen_buffer[i] = sharpen_buffer[i + RADAR_WIDTH_MAX];
		sharpen_buffer[i + RADAR_WIDTH_MAX] = sharpen_buffer[i + 2 * RADAR_WIDTH_MAX];
		sharpen_buffer[i + 2 * RADAR_WIDTH_MAX] = 0;
	}
}
void sharpen_init(float w)
{
	float i;
	for(i = 0; i < w; ++i)
	{
		sharpen_buffer[i] = 0;
		sharpen_buffer[i + RADAR_WIDTH_MAX] = 0;
		sharpen_buffer[i + 2 * RADAR_WIDTH_MAX] = 0;
	}
}
void RadarMap_Next()
{
	if(radarmapper.count & 4)
	{
		localcmd("quit\n");
	}
	else if(radarmapper.count & 2)
	{
		localcmd(strcat("defer 1 \"sv_cmd radarmap --flags ", ftos(radarmapper.count), strcat(" --res ", ftos(radarmapper.size_x), " ", ftos(radarmapper.size_y), " --sharpen ", ftos(radarmapper.ltime), " --qual ", ftos(radarmapper.size_z)), "\"\n"));
		GotoNextMap(0);
	}
	remove(radarmapper);
	radarmapper = world;
}
void RadarMap_Think()
{
	// rough map entity
	//   cnt: current line
	//   size: pixel width/height
	//   maxs: cell width/height
	//   frame: counter
	
	float i, x, l;
	string si;

	if(self.frame == 0)
	{
		// initialize
		get_mi_min_max_texcoords(1);
		self.mins = mi_picmin;
		self.maxs_x = (mi_picmax_x - mi_picmin_x) / self.size_x;
		self.maxs_y = (mi_picmax_y - mi_picmin_y) / self.size_y;
		self.maxs_z = mi_max_z - mi_min_z;
		print("Picture mins/maxs: ", ftos(self.maxs_x), " and ", ftos(self.maxs_y), " should match\n");
		self.netname = strzone(strcat("gfx/", mi_shortname, "_radar.xpm"));
		if(!(self.count & 1))
		{
			self.cnt = fopen(self.netname, FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_radar.tga"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_radar.png"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_radar.jpg"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_mini.tga"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_mini.png"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_mini.jpg"), FILE_READ);
			if(self.cnt >= 0)
			{
				fclose(self.cnt);

				print(self.netname, " already exists, aborting (you may want to specify --force)\n");
				RadarMap_Next();
				return;
			}
		}
		self.cnt = fopen(self.netname, FILE_WRITE);
		if(self.cnt < 0)
		{
			print("Error writing ", self.netname, "\n");
			remove(self);
			radarmapper = world;
			return;
		}
		print("Writing to ", self.netname, "...\n");
		fputs(self.cnt, "/* XPM */\n");
		fputs(self.cnt, "static char *RadarMap[] = {\n");
		fputs(self.cnt, "/* columns rows colors chars-per-pixel */\n");
		fputs(self.cnt, strcat("\"", ftos(self.size_x), " ", ftos(self.size_y), " 256 2\",\n"));
		for(i = 0; i < 256; ++i)
		{
			si = substring(doublehex, i*2, 2);
			fputs(self.cnt, strcat("\"", si, " c #", si, si, si, "\",\n"));
		}
		self.frame += 1;
		self.nextthink = time;
		sharpen_init(self.size_x);
	}
	else if(self.frame <= self.size_y)
	{
		// fill the sharpen buffer with this line
		sharpen_shift(self.size_x);
		i = self.count & 24;

		switch(i)
		{
			case 0:
			default:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_Block(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
			case 8:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_Trace(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
			case 16:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_Sample(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
			case 24:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_LineBlock(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
		}

		// do we have enough lines?
		if(self.frame >= 2)
		{
			// write a pixel line
			fputs(self.cnt, "\"");
			for(x = 0; x < self.size_x; ++x)
			{
				l = sharpen_get(x, self.ltime);
				fputs(self.cnt, substring(doublehex, 2 * floor(l * 256.0), 2));
			}
			if(self.frame == self.size_y)
				fputs(self.cnt, "\"\n");
			else
			{
				fputs(self.cnt, "\",\n");
				print(ftos(self.size_y - self.frame), " lines left\n");
			}
		}

		// is this the last line? then write back the missing line
		if(self.frame == self.size_y)
		{
			sharpen_shift(self.size_x);
			// write a pixel line
			fputs(self.cnt, "\"");
			for(x = 0; x < self.size_x; ++x)
			{
				l = sharpen_get(x, self.ltime);
				fputs(self.cnt, substring(doublehex, 2 * floor(l * 256.0), 2));
			}
			if(self.frame == self.size_y)
				fputs(self.cnt, "\"\n");
			else
			{
				fputs(self.cnt, "\",\n");
				print(ftos(self.size_y - self.frame), " lines left\n");
			}
		}

		self.frame += 1;
		self.nextthink = time;
	}
	else
	{
		// close the file
		fputs(self.cnt, "};\n");
		fclose(self.cnt);
		print("Finished. Please edit data/", self.netname, " with an image editing application and place it in the TGA format in the gfx folder.\n");
		RadarMap_Next();
	}
}

float RadarMap_Make(float argc)
{
	float i;
	
	if(!radarmapper)
	{
		radarmapper = spawn();
		radarmapper.classname = "radarmapper";
		radarmapper.think = RadarMap_Think;
		radarmapper.nextthink = time;
		radarmapper.count = 8; // default to the --trace method, as it is faster now
		radarmapper.ltime = 1;
		radarmapper.size = '512 512 1';
		for(i = 1; i < argc; ++i)
		{
			switch(argv(i))
			{
				case "--force": { radarmapper.count |= 1; break; }
				case "--loop": { radarmapper.count |= 2; break; }
				case "--quit": { radarmapper.count |= 4; break; }
				case "--block": { radarmapper.count &~= 24; break; }
				case "--trace": { radarmapper.count &~= 24; radarmapper.count |= 8; break; }
				case "--sample": { radarmapper.count &~= 24; radarmapper.count |= 16; break; }
				case "--lineblock": { radarmapper.count |= 24; break; }
				case "--flags": { ++i; radarmapper.count = stof(argv(i)); break; } // for the recursive call
				case "--sharpen": { ++i; radarmapper.ltime = stof(argv(i)); break; } // for the recursive call
				case "--res": // minor alias
				case "--resolution": { ++i; radarmapper.size_x = stof(argv(i)); ++i; radarmapper.size_y = stof(argv(i)); break; }
				case "--qual": // minor alias
				case "--quality": { ++i; radarmapper.size_z = stof(argv(i)); break; }
				
				default: 
					i = argc; 
					remove(radarmapper);
					radarmapper = world;
					break;
			}
		}
				
		if(radarmapper) // after doing the arguments, see if we successfully went forward. 
		{
			print("Radarmap entity spawned.\n");
			return TRUE; // if so, don't print usage.
		}
	}
	
	return FALSE;
}
