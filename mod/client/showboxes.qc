#include "showboxes.qh"

void DrawSurface(string thetexture, vector forwardright, vector forwardleft, vector backleft, vector backright, vector thecolor, float thealpha)
{
	R_BeginPolygon(thetexture, DRAWFLAG_NORMAL, false);
	R_PolygonVertex(forwardright, '0 0 0', thecolor, thealpha);
	R_PolygonVertex(forwardleft,  '0 1 0', thecolor, thealpha);
	R_PolygonVertex(backleft,  '1 1 0', thecolor, thealpha);
	R_PolygonVertex(backright, '0 1 0', thecolor, thealpha);
	R_EndPolygon();
}

void DrawBox(vector org, vector themin, vector themax, string toptex, string bottomtex, string backtex, string righttex, string lefttex, string fronttex, vector thecolor, float thealpha)
{
	vector forward = '1 0 0', up = '0 0 1', right = '0 1 0';

	vector bbox_point_topfwdleft  = org + (forward * themax.x + right  * (-themax.y) + up * themax.z);
	vector bbox_point_topfwdright = org + (forward * themax.x + right  * (-themin.y) + up * themax.z);
	vector bbox_point_topbckleft  = org + (forward * themin.x + right  * (-themax.y) + up * themax.z);
	vector bbox_point_topbckright = org + (forward * themin.x + right  * (-themin.y) + up * themax.z);
	vector bbox_point_btmfwdleft  = org + (forward * themax.x + right  * (-themax.y) + up * themin.z);
	vector bbox_point_btmfwdright = org + (forward * themax.x + right  * (-themin.y) + up * themin.z);
	vector bbox_point_btmbckleft  = org + (forward * themin.x + right  * (-themax.y) + up * themin.z);
	vector bbox_point_btmbckright = org + (forward * themin.x + right  * (-themin.y) + up * themin.z);

	// Top face
	DrawSurface(toptex, bbox_point_topfwdright, bbox_point_topfwdleft, bbox_point_topbckleft, bbox_point_topbckright, thecolor, thealpha);

	// Botton face
	DrawSurface(bottomtex, bbox_point_btmfwdright, bbox_point_btmfwdleft, bbox_point_btmbckleft, bbox_point_btmbckright, thecolor, thealpha);

	// Back face
	DrawSurface(backtex, bbox_point_topbckright, bbox_point_topbckleft, bbox_point_btmbckleft, bbox_point_btmbckright, thecolor, thealpha);

	// Right face
	DrawSurface(righttex, bbox_point_topbckright, bbox_point_topfwdright, bbox_point_btmfwdright, bbox_point_btmbckright, thecolor, thealpha);

	// Left face
	DrawSurface(lefttex, bbox_point_topbckleft, bbox_point_topfwdleft, bbox_point_btmfwdleft, bbox_point_btmbckleft, thecolor, thealpha);

	// Front face
	DrawSurface(fronttex, bbox_point_topfwdright, bbox_point_topfwdleft, bbox_point_btmfwdleft, bbox_point_btmfwdright, thecolor, thealpha);
}

void draw_bbox(entity this)
{
	vector rgb = '0 0 0';
	float alph = 0.50;
	switch(this.solid)
	{
		case SOLID_NOT: 		rgb = '1 1 1'; alph = 0.05; break;
		case SOLID_TRIGGER: 	rgb = '1 0 1'; alph = 0.10; break;
		case SOLID_BBOX: 		rgb = '0 1 0'; alph = 0.10; break;
		case SOLID_SLIDEBOX: 	rgb = '1 0 0'; alph = 0.10; break;
		case SOLID_BSP: 		rgb = '0 0 1'; alph = 0.05; break;
		case SOLID_CORPSE: 		rgb = '1 0.5 0'; alph = 0.05; break;
	}

	alph *= autocvar_cl_showbboxes;

	DrawBox(this.origin, this.mins, this.maxs, "", "", "", "", "", "", rgb, alph);
}

ACCUMULATE
void CSQCModel_Effects_Apply(entity this)
{
	if(autocvar_cl_showbboxes_players > 0 && !this.csqcmodel_isdead && (this.isplayermodel & ISPLAYER_MODEL) && !(this.isplayermodel & ISPLAYER_LOCAL))
	{
		float alph = (this.alpha) ? this.alpha : 1;
		vector rgb = colormapPaletteColor(((this.colormap >= 1024) ? this.colormap : entcs_GetClientColors(this.colormap - 1)) & 0x0F, true);

		alph = min(alph, alph * autocvar_cl_showbboxes_players);

		DrawBox(this.origin, this.mins, this.maxs, "", "", "", "", "", "", rgb, alph);
	}
}

MUTATOR_HOOKFUNCTION(mutator_mod, DrawWorld)
{
	if(autocvar_cl_showbboxes <= 0)
		return;
	// NOTE: does not include CSQC entities without a draw() function!
	//IL_EACH(g_drawables, it.origin != '0 0 0' && (autocvar_cl_showbboxes_maxdistance <= 0 || vdist(it.origin - view_origin, <=, autocvar_cl_showbboxes_maxdistance)), draw_bbox(it));
	FOREACH_ENTITY_ORDERED(!is_pure(it),
	{
		if(it.origin == '0 0 0')
			continue; // TODO: platform hitboxes
		if(it.isplayermodel & ISPLAYER_MODEL)
			continue; // player drawing handled elsewhere to avoid prediction issues
		if(autocvar_cl_showbboxes_maxdistance > 0 && vdist(it.origin - view_origin, >, autocvar_cl_showbboxes_maxdistance))
			continue;
		draw_bbox(it);
	});
}
