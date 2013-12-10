.float HookType; // ENT_CLIENT_*
.vector origin;
.vector velocity;
.float HookSilent;
.float HookRange;

void Draw_CylindricLine(vector from, vector to, float thickness, string texture, float aspect, float shift, vector rgb, float theAlpha, float drawflag, vector vieworg)
{
	// I want to draw a quad...
	// from and to are MIDPOINTS.

	vector axis, thickdir, A, B, C, D;
	float length_tex;

	axis = normalize(to - from);
	length_tex = aspect * vlen(to - from) / thickness;

	// direction is perpendicular to the view normal, and perpendicular to the axis
	thickdir = normalize(cross(axis, vieworg - from));

	A = from - thickdir * (thickness / 2);
	B = from + thickdir * (thickness / 2);
	C = to + thickdir * (thickness / 2);
	D = to - thickdir * (thickness / 2);

	R_BeginPolygon(texture, drawflag);
	R_PolygonVertex(A, '0 0 0' + shift * '1 0 0', rgb, theAlpha);
	R_PolygonVertex(B, '0 1 0' + shift * '1 0 0', rgb, theAlpha);
	R_PolygonVertex(C, '0 1 0' + (shift + length_tex) * '1 0 0', rgb, theAlpha);
	R_PolygonVertex(D, '0 0 0' + (shift + length_tex) * '1 0 0', rgb, theAlpha);
	R_EndPolygon();
}

string Draw_GrapplingHook_trace_callback_tex;
float Draw_GrapplingHook_trace_callback_rnd;
vector Draw_GrapplingHook_trace_callback_rgb;
float Draw_GrapplingHook_trace_callback_a;
void Draw_GrapplingHook_trace_callback(vector start, vector hit, vector end)
{
	float i;
	vector vorg;
	vorg = WarpZone_TransformOrigin(WarpZone_trace_transform, view_origin);
	for(i = 0; i < Draw_GrapplingHook_trace_callback_a; ++i)
		Draw_CylindricLine(hit, start, 8, Draw_GrapplingHook_trace_callback_tex, 0.25, Draw_GrapplingHook_trace_callback_rnd, Draw_GrapplingHook_trace_callback_rgb, min(1, Draw_GrapplingHook_trace_callback_a - i), DRAWFLAG_NORMAL, vorg);
	Draw_GrapplingHook_trace_callback_rnd += 0.25 * vlen(hit - start) / 8;
}

.float teleport_time;
void Draw_GrapplingHook()
{
	vector a, b, atrans;
	string tex;
	vector rgb;
	float t;
	float s;
	vector vs;
	float intensity, offset;

	if(self.teleport_time)
	if(time > self.teleport_time)
	{
		sound (self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTEN_NORM); // safeguard
		self.teleport_time = 0;
	}

	InterpolateOrigin_Do();

	s = autocvar_cl_gunalign;
	if(s != 1 && s != 2 && s != 4)
		s = 3; // default value
	--s;
	switch(self.HookType)
	{
		default:
		case ENT_CLIENT_HOOK:
			vs = hook_shotorigin[s];
			break;
		case ENT_CLIENT_LGBEAM:
			vs = electro_shotorigin[s];
			break;
		case ENT_CLIENT_GAUNTLET:
			vs = gauntlet_shotorigin[s];
			break;
	}

	if((self.owner.sv_entnum == player_localentnum - 1))
	{
		switch(self.HookType)
		{
			default:
			case ENT_CLIENT_HOOK:
				a = view_origin + view_forward * vs_x + view_right * -vs_y + view_up * vs_z;
				b = self.origin;
				break;
			case ENT_CLIENT_LGBEAM:
			case ENT_CLIENT_GAUNTLET:
				if(self.HookRange)
					b = view_origin + view_forward * self.HookRange;
				else
					b = view_origin + view_forward * vlen(self.velocity - self.origin); // honor original length of beam!
				WarpZone_TraceLine(view_origin, b, MOVE_NORMAL, world);
				b = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
				a = view_origin + view_forward * vs_x + view_right * -vs_y + view_up * vs_z;
				break;
		}
	}
	else
	{
		switch(self.HookType)
		{
			default:
			case ENT_CLIENT_HOOK:
				a = self.velocity;
				b = self.origin;
				break;
			case ENT_CLIENT_LGBEAM:
			case ENT_CLIENT_GAUNTLET:
				a = self.origin;
				b = self.velocity;
				break;
		}
	}

	t = GetPlayerColorForce(self.owner.sv_entnum);

	switch(self.HookType)
	{
		default:
		case ENT_CLIENT_HOOK:
			string suffix = "";
			if(autocvar_cl_nexuiz_hook)
				suffix = "_nexuiz";
			intensity = 1;
			offset = 0;
			if(t == NUM_TEAM_1)
			{
				tex = "particles/hook_red";
				rgb = '1 .3 .3';
			}
			else if(t == NUM_TEAM_2)
			{
				tex = "particles/hook_blue";
				rgb = '.3 .3 1';
			}
			else if(t == NUM_TEAM_3)
			{
				tex = "particles/hook_yellow";
				rgb = '1 1 .3';
			}
			else if(t == NUM_TEAM_4)
			{
				tex = "particles/hook_pink";
				rgb = '1 .3 1';
			}
			else
			{
				tex = "particles/hook_green";
				rgb = '.3 1 .3';
			}
			tex = strcat(tex, suffix);
			break;
		case ENT_CLIENT_LGBEAM:
			intensity = bound(0.2, 1 + Noise_Pink(self, frametime) * 1 + Noise_Burst(self, frametime, 0.03) * 0.3, 2);
			offset = Noise_Brown(self, frametime) * 10;
			tex = "particles/lgbeam";
			rgb = '1 1 1';
			break;
		case ENT_CLIENT_GAUNTLET:
			intensity = 1;
			offset = Noise_White(self, frametime);
			tex = "particles/gauntletbeam";
			rgb = '1 1 1';
			break;
	}

	Draw_GrapplingHook_trace_callback_tex = tex;
	Draw_GrapplingHook_trace_callback_rnd = offset;
	Draw_GrapplingHook_trace_callback_rgb = rgb;
	Draw_GrapplingHook_trace_callback_a = intensity;
	WarpZone_TraceBox_ThroughZone(a, '0 0 0', '0 0 0', b, ((self.HookType == ENT_CLIENT_HOOK) ? MOVE_NOTHING : MOVE_NORMAL), world, world, Draw_GrapplingHook_trace_callback);
	Draw_GrapplingHook_trace_callback_tex = string_null;

	atrans = WarpZone_TransformOrigin(WarpZone_trace_transform, a);

	switch(self.HookType)
	{
		default:
		case ENT_CLIENT_HOOK:
			if(vlen(trace_endpos - atrans) > 0.5)
			{
				setorigin(self, trace_endpos); // hook endpoint!
				self.angles = vectoangles(trace_endpos - atrans);
				self.drawmask = MASK_NORMAL;
			}
			else
			{
				self.drawmask = 0;
			}
			break;
		case ENT_CLIENT_LGBEAM:
		case ENT_CLIENT_GAUNTLET:
			setorigin(self, a); // beam origin!
			break;
	}

	switch(self.HookType)
	{
		default:
		case ENT_CLIENT_HOOK:
			break;
		case ENT_CLIENT_LGBEAM:
			pointparticles(particleeffectnum("electro_lightning"), trace_endpos, normalize(atrans - trace_endpos), frametime * intensity);
			break;
		case ENT_CLIENT_GAUNTLET:
			pointparticles(particleeffectnum("gauntlet_lightning"), b, normalize(a - b), frametime * intensity);
			break;
	}
}

void Remove_GrapplingHook()
{
	sound (self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTEN_NORM);
}

void Ent_ReadHook(float bIsNew, float type)
{
	self.HookType = type;

	float sf;
	sf = ReadByte();

	self.HookSilent = (sf & 0x80);
	self.iflags = IFLAG_VELOCITY | IFLAG_ORIGIN;

	InterpolateOrigin_Undo();

	if(sf & 1)
	{
		self.owner = playerslots[ReadByte() - 1];
		switch(self.HookType)
		{
			default:
			case ENT_CLIENT_HOOK:
			case ENT_CLIENT_GAUNTLET:
				self.HookRange = 0;
				break;
			case ENT_CLIENT_LGBEAM:
				self.HookRange = ReadCoord();
				break;
		}
	}
	if(sf & 2)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}
	if(sf & 4)
	{
		self.velocity_x = ReadCoord();
		self.velocity_y = ReadCoord();
		self.velocity_z = ReadCoord();
	}

	InterpolateOrigin_Note();

	if(bIsNew || !self.teleport_time)
	{
		self.draw = Draw_GrapplingHook;
		self.entremove = Remove_GrapplingHook;

		switch(self.HookType)
		{
			default:
			case ENT_CLIENT_HOOK:
				// for the model
				SETMODEL(self, "models/hook.md3");
				self.drawmask = MASK_NORMAL;
				break;
			case ENT_CLIENT_LGBEAM:
				sound (self, CH_SHOTS_SINGLE, "weapons/lgbeam_fly.wav", VOL_BASE, ATTEN_NORM);
				break;
			case ENT_CLIENT_GAUNTLET:
				sound (self, CH_SHOTS_SINGLE, "weapons/gauntletbeam_fly.wav", VOL_BASE, ATTEN_NORM);
				break;
		}
	}

	self.teleport_time = time + 10;
}

void Hook_Precache()
{
	precache_sound("weapons/lgbeam_fly.wav");
	precache_sound("weapons/gauntletbeam_fly.wav");
	precache_model("models/hook.md3");
}

// TODO: hook: temporarily transform self.origin for drawing the model along warpzones!
