#include "draw.qh"

void drawborderlines(float thickness, vector pos, vector dim, vector color, float theAlpha, float drawflag)
{
	vector line_dim = '0 0 0';

	// left and right lines
	pos.x -= thickness;
	line_dim.x = thickness;
	line_dim.y = dim.y;
	drawfill(pos, line_dim, color, theAlpha, drawflag);
	drawfill(pos + (dim.x + thickness) * '1 0 0', line_dim, color, theAlpha, drawflag);

	// upper and lower lines
	pos.y -= thickness;
	line_dim.x = dim.x + thickness * 2; // make upper and lower lines longer
	line_dim.y = thickness;
	drawfill(pos, line_dim, color, theAlpha, drawflag);
	drawfill(pos + (dim.y + thickness) * '0 1 0', line_dim, color, theAlpha, drawflag);
}

void drawpic_tiled(vector pos, string pic, vector sz, vector area, vector color, float theAlpha, float drawflag)
{
	vector current_pos = '0 0 0', end_pos, new_size = '0 0 0', ratio = '0 0 0';
	end_pos = pos + area;

	current_pos.y = pos.y;
	while (current_pos.y < end_pos.y)
	{
		current_pos.x = pos.x;
		while (current_pos.x < end_pos.x)
		{
			new_size.x = min(sz.x, end_pos.x - current_pos.x);
			new_size.y = min(sz.y, end_pos.y - current_pos.y);
			ratio.x = new_size.x / sz.x;
			ratio.y = new_size.y / sz.y;
			drawsubpic(current_pos, new_size, pic, '0 0 0', ratio, color, theAlpha, drawflag);
			current_pos.x += sz.x;
		}
		current_pos.y += sz.y;
	}
}

float expandingbox_sizefactor_from_fadelerp(float fadelerp)
{
	return 1.2 / (1.2 - fadelerp);
}

vector expandingbox_resize_centered_box_offset(float sz, vector boxsize, float boxxsizefactor)
{
	boxsize.x *= boxxsizefactor; // easier interface for text
	return boxsize * (0.5 * (1 - sz));
}

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

float stringwidth(string text, float handleColors, vector sz)
{
	vector dfs = drawfontscale;
	drawfontscale = '1 1 0';
	float r = stringwidth_builtin(text, handleColors, sz);
	drawfontscale = dfs;
	return r;
}

// it scales text up to box width
// NOTE it doesn't work perfectly because r_font_size_snapping 4 (default value)
// may render text with a slightly different size making text bigger or smaller
// NOTE this is implemented as a macro to reduce number of function calls per frame
#define DRAWSTRING_ASPECT_SCALE(pos, text, sz, allow_colors) MACRO_BEGIN \
	float textaspect, oldsz; \
	vector dfs = drawfontscale; \
	drawfontscale = '1 1 0'; \
	textaspect = stringwidth(text, allow_colors, '1 1 1' * sz.y) / sz.y; \
	if(sz.x/sz.y > textaspect) { \
		oldsz = sz.x; \
		sz.x = sz.y * textaspect; \
		pos.x += (oldsz - sz.x) * 0.5; \
	} else { \
		oldsz = sz.y; \
		sz.y = sz.x / textaspect; \
		pos.y += (oldsz - sz.y) * 0.5; \
		/* in case text is rendered with a different size, at least recenter it horizontally */ \
		/* unfortunately there is no way to correctly recenter it vertically */ \
		float new_textwidth = stringwidth(text, allow_colors, '1 1 1' * sz.y); \
		pos.x += (sz.x - new_textwidth) * 0.5; \
	} \
	drawfontscale = dfs; \
MACRO_END

// drawstring wrapper to draw a string as large as possible with preserved aspect ratio into a box
void drawstring_aspect(vector pos, string text, vector sz, vector color, float theAlpha, float drawflag) {
	DRAWSTRING_ASPECT_SCALE(pos, text, sz, false);
	drawstring(pos, text, '1 1 0' * sz.y, color, theAlpha, drawflag);
}

// drawstring wrapper to draw a colorcodedstring as large as possible with preserved aspect ratio into a box
void drawcolorcodedstring_aspect(vector pos, string text, vector sz, float theAlpha, float drawflag) {
	DRAWSTRING_ASPECT_SCALE(pos, text, sz, true);
	drawcolorcodedstring(pos, text, '1 1 0' * sz.y, theAlpha, drawflag);
}

void drawstring_expanding(vector position, string text, vector theScale, vector rgb, float theAlpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	drawfontscale = '1 1 0' * sz;
	vector dfs = drawfontscale;
	drawfontscale = sz * '1 1 0';
	float textaspect = stringwidth_builtin(text, false, theScale * (sz / drawfontscale.x)) / (theScale.x * sz);
	drawfontscale = dfs;
	drawstring(position + expandingbox_resize_centered_box_offset(sz, theScale, textaspect), text, theScale * (sz / drawfontscale.x), rgb, theAlpha * (1 - fadelerp), flag);
	// width parameter:
	//    (scale_x * sz / drawfontscale.x) * drawfontscale.x * SIZE1 / (scale_x * sz)
	//    SIZE1
	drawfontscale = '1 1 0';
}

// drawstring wrapper to draw a string as large as possible with preserved aspect ratio into a box
void drawstring_aspect_expanding(vector pos, string text, vector sz, vector color, float theAlpha, float drawflag, float fadelerp) {
	DRAWSTRING_ASPECT_SCALE(pos, text, sz, false);
	drawstring_expanding(pos, text, '1 1 0' * sz.y, color, theAlpha, drawflag, fadelerp);
}

void drawcolorcodedstring_expanding(vector position, string text, vector theScale, float theAlpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	drawfontscale = '1 1 0' * sz;
	// eventually replace with drawcolorcodedstring
	drawcolorcodedstring(position + expandingbox_resize_centered_box_offset(sz, theScale, stringwidth_builtin(text, true, theScale * (sz / drawfontscale.x)) / (theScale.x * sz)), text, theScale * (sz / drawfontscale.x), theAlpha * (1 - fadelerp), flag);
	drawfontscale = '1 1 0';
}

void drawcolorcodedstring_aspect_expanding(vector pos, string text, vector sz, float theAlpha, float drawflag, float fadelerp) {
	DRAWSTRING_ASPECT_SCALE(pos, text, sz, true);
	drawcolorcodedstring_expanding(pos, text, '1 1 0' * sz.y, theAlpha, drawflag, fadelerp);
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
		R_BeginPolygon(tex, 0, false);
		R_PolygonVertex(getsurfacepoint(e, i_s, tri.x), getsurfacepointattribute(e, i_s, tri.x, SPA_TEXCOORDS0), '1 1 1', 1);
		R_PolygonVertex(getsurfacepoint(e, i_s, tri.y), getsurfacepointattribute(e, i_s, tri.y, SPA_TEXCOORDS0), '1 1 1', 1);
		R_PolygonVertex(getsurfacepoint(e, i_s, tri.z), getsurfacepointattribute(e, i_s, tri.z, SPA_TEXCOORDS0), '1 1 1', 1);
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

void DrawCircleClippedPic(vector centre, float radi, string pic, float f, vector rgb, float a, float drawflag)
{
	vector ringsize, v, t;
	ringsize = radi * '1 1 0';

	if(f >= 1)
	{
		// draw full rectangle
		R_BeginPolygon(pic, drawflag, true);
			v = centre;			t = '0.5 0.5 0';
			v.x += 0.5 * ringsize.x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.y += 0.5 * ringsize.y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.x -= 0.5 * ringsize.x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.y -= 0.5 * ringsize.y;	t -= '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);
		R_EndPolygon();
		return;  // Complete rectangle, nothing more needed.
	}

	float co = cos(f * (2 * M_PI));
	float si = sin(f * (2 * M_PI));
	float q = fabs(co) + fabs(si);
	co /= q;
	si /= q;

	if(f > 0.75)
	{
		// draw upper half in full
		R_BeginPolygon(pic, drawflag, true);
			v = centre;			t = '0.5 0.5 0';
			v.x += 0.5 * ringsize.x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.y += 0.5 * ringsize.y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.x -= 0.5 * ringsize.x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);
		R_EndPolygon();
		// draw clipped lower half as a quad
		R_BeginPolygon(pic, drawflag, true);
			v = centre;			t = '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.x -= 0.5 * ringsize.x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.y -= 0.5 * ringsize.y;	t -= '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);
	}
	else if(f > 0.5)
	{
		// draw upper half in full
		R_BeginPolygon(pic, drawflag, true);
			v = centre;			t = '0.5 0.5 0';
			v.x += 0.5 * ringsize.x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.y += 0.5 * ringsize.y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.x -= 0.5 * ringsize.x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);
		R_EndPolygon();
		// draw clipped lower half as a triangle
		R_BeginPolygon(pic, drawflag, true);
			v = centre;			t = '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.x -= 0.5 * ringsize.x;	t -= '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);
	}
	else if(f > 0.25)
	{
		// draw clipped lower half as a quad
		R_BeginPolygon(pic, drawflag, true);
			v = centre;			t = '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.x += 0.5 * ringsize.x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.y += 0.5 * ringsize.y;	t += '0.5 -0.5 0';
			R_PolygonVertex(v, t, rgb, a);
	}
	else if (f > 0)
	{
		// draw clipped lower half as a triangle
		R_BeginPolygon(pic, drawflag, true);
			v = centre;			t = '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);

			v = centre;			t = '0.5 0.5 0';
			v.x += 0.5 * ringsize.x;	t += '0.5 0.5 0';
			R_PolygonVertex(v, t, rgb, a);
	}
	else
	{
		// Nothing to draw.
		return;
	}

	// The last, moving vertex.
		v = centre;			t = '0.5 0.5 0';
		v.x += co * 0.5 * ringsize.x;	t += co * '0.5 0.5 0';
		v.y += si * 0.5 * ringsize.y;	t += si * '0.5 -0.5 0';
		R_PolygonVertex(v, t, rgb, a);
	R_EndPolygon();
}
