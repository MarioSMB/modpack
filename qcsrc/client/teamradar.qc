float teamradar_angle; // player yaw angle
vector teamradar_origin3d_in_texcoord; // player origin
vector teamradar_origin2d; // 2D origin
vector teamradar_size2d; // 2D size
vector teamradar_extraclip_mins, teamradar_extraclip_maxs; // for non-centered radar display
float teamradar_size; // 2D scale factor
float hud_panel_radar_scale; // window size = ...qu
float v_flipped;

float vlen2d(vector v)
{
	return sqrt(v_x * v_x + v_y * v_y);
}

float vlen_maxnorm2d(vector v)
{
	return max(v_x, v_y, -v_x, -v_y);
}

float vlen_minnorm2d(vector v)
{
	return min(max(v_x, -v_x), max(v_y, -v_y));
}

vector teamradar_3dcoord_to_texcoord(vector in)
{
	vector out;
	out_x = (in_x - mi_picmin_x) / (mi_picmax_x - mi_picmin_x);
	out_y = (in_y - mi_picmin_y) / (mi_picmax_y - mi_picmin_y);
	out_z = 0;
	return out;
}

vector teamradar_texcoord_to_2dcoord(vector in)
{
	vector out;
	in -= teamradar_origin3d_in_texcoord;

	out = rotate(in, teamradar_angle * DEG2RAD);
	out_y = - out_y; // screen space is reversed

	out = out * teamradar_size;
	if(v_flipped)
		out_x = -out_x;
	out += teamradar_origin2d;
	return out;
}

vector yinvert(vector v)
{
	v_y = 1 - v_y;
	return v;
}

void draw_teamradar_background(float fg)
{
	float fga;
	vector fgc;

	if(fg > 0 && minimapname != "")
	{
		fga = 1;
		fgc = '1 1 1' * fg;
		R_BeginPolygon(minimapname, DRAWFLAG_SCREEN | DRAWFLAG_MIPMAP);
		if(v_flipped)
		{
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord3), yinvert(mi_pictexcoord3), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord2), yinvert(mi_pictexcoord2), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord1), yinvert(mi_pictexcoord1), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord0), yinvert(mi_pictexcoord0), fgc, fga);
		}
		else
		{
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord0), yinvert(mi_pictexcoord0), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord1), yinvert(mi_pictexcoord1), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord2), yinvert(mi_pictexcoord2), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord3), yinvert(mi_pictexcoord3), fgc, fga);
		}
		R_EndPolygon();
	}
}

void draw_teamradar_player(vector coord3d, vector pangles, vector rgb)
{
	vector coord, rgb2;

	coord = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(coord3d));

	makevectors(pangles - '0 1 0' * teamradar_angle);
	if(v_flipped)
	{
		v_forward_x = -v_forward_x;
		v_right_x = -v_right_x;
		v_up_x = -v_up_x;
	}
	v_forward_z = 0;
	v_forward = normalize(v_forward);
	v_forward_y *= -1.0;
	v_right_x = -v_forward_y;
	v_right_y = v_forward_x;

	if(rgb == '1 1 1')
		rgb2 = '0 0 0';
	else
		rgb2 = '1 1 1';

	R_BeginPolygon("", 0);
	R_PolygonVertex(coord+v_forward*3, '0 0 0', rgb2, panel_fg_alpha);
	R_PolygonVertex(coord+v_right*4-v_forward*2.5, '0 1 0', rgb2, panel_fg_alpha);
	R_PolygonVertex(coord-v_forward*2, '1 0 0', rgb2, panel_fg_alpha);
	R_PolygonVertex(coord-v_right*4-v_forward*2.5, '1 1 0', rgb2, panel_fg_alpha);
	R_EndPolygon();

	R_BeginPolygon("", 0);
	R_PolygonVertex(coord+v_forward*2, '0 0 0', rgb, panel_fg_alpha);
	R_PolygonVertex(coord+v_right*3-v_forward*2, '0 1 0', rgb, panel_fg_alpha);
	R_PolygonVertex(coord-v_forward, '1 0 0', rgb, panel_fg_alpha);
	R_PolygonVertex(coord-v_right*3-v_forward*2, '1 1 0', rgb, panel_fg_alpha);
	R_EndPolygon();
}

void draw_teamradar_icon(vector coord, float icon, entity pingdata, vector rgb, float a)
{
	float dt;
	vector v;
	float i;

	coord = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(coord));
	drawpic(coord - '4 4 0', strcat("gfx/teamradar_icon_", ftos(icon)), '8 8 0', rgb, a, 0);

	if(pingdata)
	{
		for(i = 0; i < MAX_TEAMRADAR_TIMES; ++i)
		{
			dt = pingdata.(teamradar_times[i]);
			if(dt == 0)
				continue;
			dt = time - dt;
			if(dt >= 1 || dt <= 0)
				continue;
			v = '2 2 0' * teamradar_size * dt;
			drawpic(coord - 0.5 * v, "gfx/teamradar_ping", v, '1 1 1', (1 - dt) * a, DRAWFLAG_ADDITIVE);
		}
	}
}

void draw_teamradar_link(vector start, vector end, float colors)
{
	vector c0, c1, norm;

	start = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(start));
	end = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(end));
	norm = normalize(start - end);
	norm_z = norm_x;
	norm_x = -norm_y;
	norm_y = norm_z;
	norm_z = 0;

	c0 = colormapPaletteColor(colors & 0x0F, FALSE);
	c1 = colormapPaletteColor((colors & 0xF0) / 0x10, FALSE);

	R_BeginPolygon("", 0);
	R_PolygonVertex(start - norm, '0 0 0', c0, panel_fg_alpha);
	R_PolygonVertex(start + norm, '0 1 0', c0, panel_fg_alpha);
	R_PolygonVertex(end + norm, '1 1 0', c1, panel_fg_alpha);
	R_PolygonVertex(end - norm, '1 0 0', c1, panel_fg_alpha);
	R_EndPolygon();
}

float hud_panel_radar_scale;
float hud_panel_radar_foreground_alpha;
float hud_panel_radar_rotation;
noref vector hud_panel_radar_size; // fteqcc sucks
float hud_panel_radar_zoommode;
float hud_panel_radar_maximized_zoommode;
float hud_panel_radar_maximized_rotation;

void teamradar_loadcvars()
{
	v_flipped = autocvar_v_flipped;
	hud_panel_radar_scale = autocvar_hud_panel_radar_scale;
	if (hud_panel_radar_maximized && !autocvar__hud_configure)
	{
		if (autocvar_hud_panel_radar_maximized_scale > 0)
			hud_panel_radar_scale = autocvar_hud_panel_radar_maximized_scale;
	}
	hud_panel_radar_foreground_alpha = autocvar_hud_panel_radar_foreground_alpha * panel_fg_alpha;
	hud_panel_radar_rotation = autocvar_hud_panel_radar_rotation;
	hud_panel_radar_zoommode = autocvar_hud_panel_radar_zoommode;
	hud_panel_radar_maximized_rotation = autocvar_hud_panel_radar_maximized_rotation;
	hud_panel_radar_maximized_zoommode = autocvar_hud_panel_radar_maximized_zoommode;

	// others default to 0
	// match this to defaultXonotic.cfg!
	if(!hud_panel_radar_scale) hud_panel_radar_scale = 4096;
	if(!hud_panel_radar_foreground_alpha) hud_panel_radar_foreground_alpha = 0.8 * panel_fg_alpha;
	if(!hud_panel_radar_size_x) hud_panel_radar_size_x = 128;
	if(!hud_panel_radar_size_y) hud_panel_radar_size_y = hud_panel_radar_size_x;
}

// radar links

void Ent_RadarLink()
{
	float sendflags;
	sendflags = ReadByte();

	InterpolateOrigin_Undo();

	self.iflags = IFLAG_VELOCITY | IFLAG_ORIGIN;
	self.classname = "radarlink";

	if(sendflags & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}

	if(sendflags & 2)
	{
		self.velocity_x = ReadCoord();
		self.velocity_y = ReadCoord();
		self.velocity_z = ReadCoord();
	}

	if(sendflags & 4)
	{
		self.team = ReadByte();
	}

	InterpolateOrigin_Note();
}
