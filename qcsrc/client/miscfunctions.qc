entity players;
entity teams;
var float team_count; // real teams

void AuditLists()
{
	entity e;
	entity prev;

	prev = players;
	for(e = prev.sort_next; e; prev = e, e = e.sort_next)
	{
		if(prev != e.sort_prev)
			error(strcat("sort list chain error\nplease submit the output of 'prvm_edicts client' to the developers"));
	}

	prev = teams;
	for(e = prev.sort_next; e; prev = e, e = e.sort_next)
	{
		if(prev != e.sort_prev)
			error(strcat("sort list chain error\nplease submit the output of 'prvm_edicts client' to the developers"));
	}
}


float RegisterPlayer(entity player)
{
	entity pl;
	AuditLists();
	for(pl = players.sort_next; pl; pl = pl.sort_next)
		if(pl == player)
			error("Player already registered!");
	player.sort_next = players.sort_next;
	player.sort_prev = players;
	if(players.sort_next)
		players.sort_next.sort_prev = player;
	players.sort_next = player;
	AuditLists();
	return true;
}

void RemovePlayer(entity player)
{
	entity pl, parent;
	AuditLists();
	parent = players;
	for(pl = players.sort_next; pl && pl != player; pl = pl.sort_next)
		parent = pl;

	if(!pl)
	{
		error("Trying to remove a player which is not in the playerlist!");
		return;
	}
	parent.sort_next = player.sort_next;
	if(player.sort_next)
		player.sort_next.sort_prev = parent;
	AuditLists();
}

void MoveToLast(entity e)
{
	AuditLists();
	other = e.sort_next;
	while(other)
	{
		SORT_SWAP(other, e);
		other = e.sort_next;
	}
	AuditLists();
}

float RegisterTeam(entity Team)
{
	entity tm;
	AuditLists();
	for(tm = teams.sort_next; tm; tm = tm.sort_next)
		if(tm == Team)
			error("Team already registered!");
	Team.sort_next = teams.sort_next;
	Team.sort_prev = teams;
	if(teams.sort_next)
		teams.sort_next.sort_prev = Team;
	teams.sort_next = Team;
	if(Team.team && Team.team != NUM_SPECTATOR)
		++team_count;
	AuditLists();
	return true;
}

void RemoveTeam(entity Team)
{
	entity tm, parent;
	AuditLists();
	parent = teams;
	for(tm = teams.sort_next; tm && tm != Team; tm = tm.sort_next)
		parent = tm;

	if(!tm)
	{
		print(_("Trying to remove a team which is not in the teamlist!"));
		return;
	}
	parent.sort_next = Team.sort_next;
	if(Team.sort_next)
		Team.sort_next.sort_prev = parent;
	if(Team.team && Team.team != NUM_SPECTATOR)
		--team_count;
	AuditLists();
}

entity GetTeam(float Team, float add)
{
	float num;
	entity tm;
	num = (Team == NUM_SPECTATOR) ? 16 : Team;
	if(teamslots[num])
		return teamslots[num];
	if (!add)
		return world;
	tm = spawn();
	tm.team = Team;
	teamslots[num] = tm;
	RegisterTeam(tm);
	return tm;
}

vector HUD_GetFontsize(string cvarname)
{
	vector v;
	v = stov(cvar_string(cvarname));
	if(v_x == 0)
		v = '8 8 0';
	if(v_y == 0)
		v_y = v_x;
	v_z = 0;
	return v;
}

float PreviewExists(string name)
{
	if(autocvar_cl_readpicture_force)
		return false;

	if (fexists(strcat(name, ".tga"))) return true;
	if (fexists(strcat(name, ".png"))) return true;
	if (fexists(strcat(name, ".jpg"))) return true;
	if (fexists(strcat(name, ".pcx"))) return true;

	return false;
}

vector rotate(vector v, float a)
{
	vector w = '0 0 0';
	// FTEQCC SUCKS AGAIN
	w_x =      v_x * cos(a) + v_y * sin(a);
	w_y = -1 * v_x * sin(a) + v_y * cos(a);
	return w;
}

float ColorTranslateMode;

string ColorTranslateRGB(string s)
{
	if(ColorTranslateMode & 1)
		return strdecolorize(s);
	else
		return s;
}

// decolorizes and team colors the player name when needed
string playername(string thename, float teamid)
{
    string t;
    if (teamplay)
    {
        t = Team_ColorCode(teamid);
        return strcat(t, strdecolorize(thename));
    }
    else
        return strdecolorize(thename);
}

float cvar_or(string cv, float v)
{
	string s;
	s = cvar_string(cv);
	if(s == "")
		return v;
	else
		return stof(s);
}

vector project_3d_to_2d(vector vec)
{
	vec = cs_project(vec);
	if(cs_project_is_b0rked > 0)
	{
		vec_x *= vid_conwidth / vid_width;
		vec_y *= vid_conheight / vid_height;
	}
	return vec;
}

void dummyfunction(float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8)
{
}

float expandingbox_sizefactor_from_fadelerp(float fadelerp)
{
	return 1.2 / (1.2 - fadelerp);
}

vector expandingbox_resize_centered_box_offset(float sz, vector boxsize, float boxxsizefactor)
{
	boxsize_x *= boxxsizefactor; // easier interface for text
	return boxsize * (0.5 * (1 - sz));
}

void drawborderlines(float thickness, vector pos, vector dim, vector color, float theAlpha, float drawflag)
{
	vector line_dim = '0 0 0';

	// left and right lines
	pos_x -= thickness;
	line_dim_x = thickness;
	line_dim_y = dim_y;
	drawfill(pos, line_dim, color, theAlpha, drawflag);
	drawfill(pos + (dim_x + thickness) * '1 0 0', line_dim, color, theAlpha, drawflag);

	// upper and lower lines
	pos_y -= thickness;
	line_dim_x = dim_x + thickness * 2; // make upper and lower lines longer
	line_dim_y = thickness;
	drawfill(pos, line_dim, color, theAlpha, drawflag);
	drawfill(pos + (dim_y + thickness) * '0 1 0', line_dim, color, theAlpha, drawflag);
}

void drawpic_tiled(vector pos, string pic, vector sz, vector area, vector color, float theAlpha, float drawflag)
{
	vector current_pos = '0 0 0', end_pos, new_size = '0 0 0', ratio = '0 0 0';
	end_pos = pos + area;

	current_pos_y = pos_y;
	while (current_pos_y < end_pos_y)
	{
		current_pos_x = pos_x;
		while (current_pos_x < end_pos_x)
		{
			new_size_x = min(sz_x, end_pos_x - current_pos_x);
			new_size_y = min(sz_y, end_pos_y - current_pos_y);
			ratio_x = new_size_x / sz_x;
			ratio_y = new_size_y / sz_y;
			drawsubpic(current_pos, new_size, pic, '0 0 0', ratio, color, theAlpha, drawflag);
			current_pos_x += sz_x;
		}
		current_pos_y += sz_y;
	}
}

// drawpic wrapper to draw an image as large as possible with preserved aspect ratio into a box
var float _drawpic_imgaspect;
var vector _drawpic_imgsize;
var vector _drawpic_sz;
var float _drawpic_oldsz;
var string _drawpic_picpath;
#define drawpic_aspect(pos,pic,mySize,color,theAlpha,drawflag)\
	do {\
		_drawpic_imgsize = draw_getimagesize(pic);\
		if(_drawpic_imgsize != '0 0 0') {\
			_drawpic_imgaspect = _drawpic_imgsize_x/_drawpic_imgsize_y;\
			_drawpic_sz = mySize;\
			if(_drawpic_sz_x/_drawpic_sz_y > _drawpic_imgaspect) {\
				_drawpic_oldsz = _drawpic_sz_x;\
				_drawpic_sz_x = _drawpic_sz_y * _drawpic_imgaspect;\
				if(_drawpic_sz_x)\
					drawpic(pos + eX * (_drawpic_oldsz - _drawpic_sz_x) * 0.5, pic, _drawpic_sz, color, theAlpha, drawflag);\
			} else {\
				_drawpic_oldsz = _drawpic_sz_y;\
				_drawpic_sz_y = _drawpic_sz_x / _drawpic_imgaspect;\
				if(_drawpic_sz_y)\
					drawpic(pos + eY * (_drawpic_oldsz - _drawpic_sz_y) * 0.5, pic, _drawpic_sz, color, theAlpha, drawflag);\
			}\
		}\
	} while(0)

// draw HUD element with image from gfx/hud/hud_skin/foo.tga if it exists, otherwise gfx/hud/default/foo.tga
#define drawpic_aspect_skin(pos,pic,sz,color,theAlpha,drawflag)\
	do{\
		_drawpic_picpath = strcat(hud_skin_path, "/", pic);\
		if(precache_pic(_drawpic_picpath) == "") {\
			_drawpic_picpath = strcat("gfx/hud/default/", pic);\
		}\
		drawpic_aspect(pos, _drawpic_picpath, sz, color, theAlpha, drawflag);\
		_drawpic_picpath = string_null;\
	} while(0)

// draw HUD element with image from gfx/hud/hud_skin/foo.tga if it exists, otherwise gfx/hud/default/foo.tga
#define drawpic_skin(pos,pic,sz,color,theAlpha,drawflag)\
	do{\
		_drawpic_picpath = strcat(hud_skin_path, "/", pic);\
		if(precache_pic(_drawpic_picpath) == "") {\
			_drawpic_picpath = strcat("gfx/hud/default/", pic);\
		}\
		drawpic(pos, _drawpic_picpath, sz, color, theAlpha, drawflag);\
		_drawpic_picpath = string_null;\
	} while(0)

void drawpic_aspect_skin_expanding(vector position, string pic, vector theScale, vector rgb, float theAlpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	drawpic_aspect_skin(position + expandingbox_resize_centered_box_offset(sz, theScale, 1), pic, theScale * sz, rgb, theAlpha * (1 - fadelerp), flag);
}

void drawpic_aspect_skin_expanding_two(vector position, string pic, vector theScale, vector rgb, float theAlpha, float flag, float fadelerp)
{
	drawpic_aspect_skin_expanding(position, pic, theScale, rgb, theAlpha, flag, fadelerp);
	drawpic_skin(position, pic, theScale, rgb, theAlpha * fadelerp, flag);
}
#define SET_POS_AND_SZ_Y_ASPECT(allow_colors)\
	float textaspect, oldsz;\
	textaspect = stringwidth(text, allow_colors, '1 1 1' * sz_y) / sz_y;\
	if(sz_x/sz_y > textaspect) {\
		oldsz = sz_x;\
		sz_x = sz_y * textaspect;\
		pos_x += (oldsz - sz_x) * 0.5;\
	} else {\
		oldsz = sz_y;\
		sz_y = sz_x / textaspect; \
		pos_y += (oldsz - sz_y) * 0.5;\
	}

// drawstring wrapper to draw a string as large as possible with preserved aspect ratio into a box
void drawstring_aspect(vector pos, string text, vector sz, vector color, float theAlpha, float drawflag) {
	SET_POS_AND_SZ_Y_ASPECT(FALSE)
	drawstring(pos, text, '1 1 0' * sz_y, color, theAlpha, drawflag);
}

// drawstring wrapper to draw a colorcodedstring as large as possible with preserved aspect ratio into a box
void drawcolorcodedstring_aspect(vector pos, string text, vector sz, float theAlpha, float drawflag) {
	SET_POS_AND_SZ_Y_ASPECT(TRUE)
	drawcolorcodedstring(pos, text, '1 1 0' * sz_y, theAlpha, drawflag);
}

vector drawfontscale;
void drawstring_expanding(vector position, string text, vector theScale, vector rgb, float theAlpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	drawfontscale = sz * '1 1 0';
	dummyfunction(0, 0, 0, 0, 0, 0, 0, 0);
	drawstring(position + expandingbox_resize_centered_box_offset(sz, theScale, stringwidth(text, FALSE, theScale * (sz / drawfontscale_x)) / (theScale_x * sz)), text, theScale * (sz / drawfontscale_x), rgb, theAlpha * (1 - fadelerp), flag);
	// width parameter:
	//    (scale_x * sz / drawfontscale_x) * drawfontscale_x * SIZE1 / (scale_x * sz)
	//    SIZE1
	drawfontscale = '1 1 0';
}

// drawstring wrapper to draw a string as large as possible with preserved aspect ratio into a box
void drawstring_aspect_expanding(vector pos, string text, vector sz, vector color, float theAlpha, float drawflag, float fadelerp) {
	SET_POS_AND_SZ_Y_ASPECT(FALSE)
	drawstring_expanding(pos, text, '1 1 0' * sz_y, color, theAlpha, drawflag, fadelerp);
}

void drawcolorcodedstring_expanding(vector position, string text, vector theScale, float theAlpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	drawfontscale = sz * '1 1 0';
	dummyfunction(0, 0, 0, 0, 0, 0, 0, 0);
	drawcolorcodedstring(position + expandingbox_resize_centered_box_offset(sz, theScale, stringwidth(text, TRUE, theScale * (sz / drawfontscale_x)) / (theScale_x * sz)), text, theScale * (sz / drawfontscale_x), theAlpha * (1 - fadelerp), flag);
	drawfontscale = '1 1 0';
}

void drawcolorcodedstring_aspect_expanding(vector pos, string text, vector sz, float theAlpha, float drawflag, float fadelerp) {
	SET_POS_AND_SZ_Y_ASPECT(TRUE)
	drawcolorcodedstring_expanding(pos, text, '1 1 0' * sz_y, theAlpha, drawflag, fadelerp);
}

// this draws the triangles of a model DIRECTLY. Don't expect high performance, really...
float PolyDrawModelSurface(entity e, float i_s)
{
	float i_t;
	float n_t;
	vector tri;
	string tex;
	tex = getsurfacetexture(e, i_s);
	if (!tex)
		return 0; // this is beyond the last one
	n_t = getsurfacenumtriangles(e, i_s);
	for(i_t = 0; i_t < n_t; ++i_t)
	{
		tri = getsurfacetriangle(e, i_s, i_t);
		R_BeginPolygon(tex, 0);
		R_PolygonVertex(getsurfacepoint(e, i_s, tri_x), getsurfacepointattribute(e, i_s, tri_x, SPA_TEXCOORDS0), '1 1 1', 1);
		R_PolygonVertex(getsurfacepoint(e, i_s, tri_y), getsurfacepointattribute(e, i_s, tri_y, SPA_TEXCOORDS0), '1 1 1', 1);
		R_PolygonVertex(getsurfacepoint(e, i_s, tri_z), getsurfacepointattribute(e, i_s, tri_z, SPA_TEXCOORDS0), '1 1 1', 1);
		R_EndPolygon();
	}
	return 1;
}
void PolyDrawModel(entity e)
{
	float i_s;
	for(i_s = 0; ; ++i_s)
		if(!PolyDrawModelSurface(e, i_s))
			break;
}

void DrawCircleClippedPic(vector centre, float radius, string pic, float f, vector rgb, float a, float drawflag)
{
	float x, y, q, d;
	vector ringsize, v, t;
	ringsize = radius * '1 1 0';

	x = cos(f * 2 * M_PI);
	y = sin(f * 2 * M_PI);
	q = fabs(x) + fabs(y);
	x /= q;
	y /= q;

	if(f >= 1)
	{
		// draw full rectangle
		R_BeginPolygon(pic, drawflag);
			v = centre;			t = '0.5 0.5 0';
			v_x += 0.5 * ringsize_x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_y += 0.5 * ringsize_y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_x -= 0.5 * ringsize_x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_y -= 0.5 * ringsize_y;	t -= '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);
		R_EndPolygon();

		d = q - 1;
		if(d > 0)
		{
			R_BeginPolygon(pic, drawflag);
				v = centre;			t = '0.5 0.5 0';
				R_PolygonVertex(v, t, rgb, a);

				v = centre;			t = '0.5 0.5 0';
				v_x += 0.5 * ringsize_x;	t += '0.5 0.5 0';
				R_PolygonVertex(v, t, rgb, a);
		}
	}
	else if(f > 0.75)
	{
		// draw upper and first triangle
		R_BeginPolygon(pic, drawflag);
			v = centre;			t = '0.5 0.5 0';
			v_x += 0.5 * ringsize_x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_y += 0.5 * ringsize_y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_x -= 0.5 * ringsize_x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);
		R_EndPolygon();
		R_BeginPolygon(pic, drawflag);
			v = centre;			t = '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_x -= 0.5 * ringsize_x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_y -= 0.5 * ringsize_y;	t -= '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

		d = q - 0.75;
		if(d <= 0)
			R_EndPolygon();
	}
	else if(f > 0.5)
	{
		// draw upper triangle
		R_BeginPolygon(pic, drawflag);
			v = centre;			t = '0.5 0.5 0';
			v_x += 0.5 * ringsize_x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_y += 0.5 * ringsize_y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_x -= 0.5 * ringsize_x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);
		R_EndPolygon();

		d = q - 0.5;
		if(d > 0)
		{
			R_BeginPolygon(pic, drawflag);
				v = centre;			t = '0.5 0.5 0';
				R_PolygonVertex(v, t, rgb, a);

				v = centre;			t = '0.5 0.5 0';
				v_x -= 0.5 * ringsize_x;	t -= '0.5 0.5 0';
				R_PolygonVertex(v, t, rgb, a);
		}
	}
	else if(f > 0.25)
	{
		// draw first triangle
		R_BeginPolygon(pic, drawflag);
			v = centre;			t = '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_x += 0.5 * ringsize_x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v_y += 0.5 * ringsize_y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

		d = q - 0.25;
		if(d <= 0)
			R_EndPolygon();
	}
	else
	{
		d = q;
		if(d > 0)
		{
			R_BeginPolygon(pic, drawflag);
				v = centre;			t = '0.5 0.5 0';
				R_PolygonVertex(v, t, rgb, a);

				v = centre;			t = '0.5 0.5 0';
				v_x += 0.5 * ringsize_x;	t += '0.5 0.5 0';
				R_PolygonVertex(v, t, rgb, a);
		}
	}

	if(d > 0)
	{
			v = centre;			t = '0.5 0.5 0';
			v_x += x * 0.5 * ringsize_x;	t += x * '0.5 0.5 0';
			v_y += y * 0.5 * ringsize_y;	t += y * '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);
		R_EndPolygon();
	}
}

const vector GETPLAYERORIGIN_ERROR = '1123581321 2357111317 3141592653'; // way out of bounds for anything on the map
vector getplayerorigin(float pl)
{
	entity e;

	e = CSQCModel_server2csqc(pl + 1);
	if(e)
		return e.origin;

	e = entcs_receiver[pl];
	if(e)
		return e.origin;

	return GETPLAYERORIGIN_ERROR;
}

float getplayeralpha(float pl)
{
	entity e;

	e = CSQCModel_server2csqc(pl + 1);
	if(e)
		return e.alpha;

	return 1;
}

vector getcsqcplayercolor(float pl)
{
	entity e;

	e = CSQCModel_server2csqc(pl);
	if(e)
	{
		if(e.colormap > 0)
			return colormapPaletteColor(((e.colormap >= 1024) ? e.colormap : stof(getplayerkeyvalue(e.colormap - 1, "colors"))) & 0x0F, TRUE);
	}

	return '1 1 1';
}

float getplayerisdead(float pl)
{
	entity e;

	e = CSQCModel_server2csqc(pl + 1);
	if(e)
		return e.csqcmodel_isdead;

	return FALSE;
}

void URI_Get_Callback(float id, float status, string data)
{
	if(url_URI_Get_Callback(id, status, data))
	{
		// handled
	}
	else if (id == URI_GET_DISCARD)
	{
		// discard
	}
	else if (id >= URI_GET_CURL && id <= URI_GET_CURL_END)
	{
		// sv_cmd curl
		Curl_URI_Get_Callback(id, status, data);
	}
	else
	{
		printf("Received HTTP request data for an invalid id %d.\n", id);
	}
}

void draw_beginBoldFont()
{
	drawfont = FONT_USER+2;
}

void draw_endBoldFont()
{
	drawfont = FONT_USER+1;
}


#define MAX_ACCURACY_LEVELS 10
float acc_lev[MAX_ACCURACY_LEVELS];
vector acc_col[MAX_ACCURACY_LEVELS];
float acc_col_loadtime;
float acc_levels;
string acc_color_levels;
void Accuracy_LoadLevels()
{
	float i;
	if(autocvar_accuracy_color_levels != acc_color_levels)
	{
		if(acc_color_levels)
			strunzone(acc_color_levels);
		acc_color_levels = strzone(autocvar_accuracy_color_levels);
		acc_levels = tokenize_console(acc_color_levels);
		if(acc_levels > MAX_ACCURACY_LEVELS)
			acc_levels = MAX_ACCURACY_LEVELS;
		if(acc_levels < 2)
			print("Warning: accuracy_color_levels must contain at least 2 values\n");

		for(i = 0; i < acc_levels; ++i)
			acc_lev[i] = stof(argv(i)) / 100.0;
	}
}

void Accuracy_LoadColors()
{
	float i;
	if(time > acc_col_loadtime)
	if(acc_levels >= 2)
	{
		for(i = 0; i < acc_levels; ++i)
			acc_col[i] = stov(cvar_string(strcat("accuracy_color", ftos(i))));
		acc_col_loadtime = time + 2;
	}
}

vector Accuracy_GetColor(float accuracy)
{
	float j, factor;
	vector color;
	if(acc_levels < 2)
		return '0 0 0'; // return black, can't determine the right color

	// find the max level lower than acc
	j = acc_levels-1;
	while(j && accuracy < acc_lev[j])
		--j;

	// inject color j+1 in color j, how much depending on how much accuracy is higher than level j
	factor = (accuracy - acc_lev[j]) / (acc_lev[j+1] - acc_lev[j]);
	color = acc_col[j];
	color = color + factor * (acc_col[j+1] - color);
	return color;
}

