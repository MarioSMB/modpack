#ifdef CSQC
#include "tools/common.qc"
#include "system.qc"

AUTOCVAR(cl_mplant_drawdistance, float, 0, "");
AUTOCVAR(cl_mplant_fadedistance, float, 0, "");
AUTOCVAR(cl_mplant_boxdistance, float, 0, "");

/**
    Optimized for csqc.
    Redoing the transformation each server frame for the edit object is ok
    Redoing the transformation each render frame for every bbox object is not.

    This means trading a little more memory (.vectors) for alot less cpu
    by only redoing transformation when origin or angles change.
**/
.vector mtu_point_topfwdright;
.vector mtu_point_topfwdleft;
.vector mtu_point_topbckright;
.vector mtu_point_topbckleft;
.vector mtu_point_btmfwdright;
.vector mtu_point_btmfwdleft;
.vector mtu_point_btmbckright;
.vector mtu_point_btmbckleft;
.vector mtu_point_right;
.vector mtu_point_left;
.vector mtu_point_forward;
.vector mtu_point_back;
.vector mtu_point_up;
.vector mtu_point_down;

void cl_mplant_transform_update(entity this)
{
    if (getfileext(this.model) != "bsp")
        this.angles_x *= -1;

    fixedmakevectors(this.angles);

    this.mtu_point_topfwdleft  = this.origin + (v_forward * this.mplant_org_maxs_x + v_right  * (-this.mplant_org_maxs_y) + v_up * this.mplant_org_maxs_z);
    this.mtu_point_topfwdright = this.origin + (v_forward * this.mplant_org_maxs_x + v_right  * (-this.mplant_org_mins_y) + v_up * this.mplant_org_maxs_z);
    this.mtu_point_topbckleft  = this.origin + (v_forward * this.mplant_org_mins_x + v_right  * (-this.mplant_org_maxs_y) + v_up * this.mplant_org_maxs_z);
    this.mtu_point_topbckright = this.origin + (v_forward * this.mplant_org_mins_x + v_right  * (-this.mplant_org_mins_y) + v_up * this.mplant_org_maxs_z);
    this.mtu_point_btmfwdleft  = this.origin + (v_forward * this.mplant_org_maxs_x + v_right  * (-this.mplant_org_maxs_y) + v_up * this.mplant_org_mins_z);
    this.mtu_point_btmfwdright = this.origin + (v_forward * this.mplant_org_maxs_x + v_right  * (-this.mplant_org_mins_y) + v_up * this.mplant_org_mins_z);
    this.mtu_point_btmbckleft  = this.origin + (v_forward * this.mplant_org_mins_x + v_right  * (-this.mplant_org_maxs_y) + v_up * this.mplant_org_mins_z);
    this.mtu_point_btmbckright = this.origin + (v_forward * this.mplant_org_mins_x + v_right  * (-this.mplant_org_mins_y) + v_up * this.mplant_org_mins_z);

    this.mtu_point_left    = this.origin + (v_right * (-this.mplant_org_maxs_y));
    this.mtu_point_right   = this.origin + (v_right * (-this.mplant_org_mins_y));
    this.mtu_point_forward = this.origin + (v_forward * this.mplant_org_maxs_x);
    this.mtu_point_back    = this.origin + (v_forward * this.mplant_org_mins_x);
    this.mtu_point_up      = this.origin + (v_up * this.mplant_org_maxs_z);
    this.mtu_point_down    = this.origin + (v_up * this.mplant_org_mins_z);

    if (getfileext(this.model) != "bsp")
        this.angles_x *= -1;
}

void mplant_block_draw(entity this)
{
    if (!autocvar_cl_mplant_fadedistance)
    {
        if (vdist(this.origin - view_origin, <, autocvar_cl_mplant_drawdistance) || !autocvar_cl_mplant_drawdistance)
        {
            this.effects = 0;
            if (this.model != this.mdl)
                _setmodel(this, this.mdl);

            if (!autocvar_cl_mplant_drawdistance)
                return;
        }
    }

    if (vdist(this.origin - view_origin, <, autocvar_cl_mplant_drawdistance))
    {
        if (this.model != "null")
            setmodel(this, MDL_Null);

        this.effects = EF_NODRAW | EF_NOSHADOW;
        return;
    }


    //if (autocvar_cl_mplant_fadedistance && _dist > autocvar_cl_mplant_drawdistance - autocvar_cl_mplant_fadedistance)
    //{
    //this.alpha = max(0, this.alpha - 0.001);
    float _alpha0 = autocvar_cl_mplant_drawdistance;
    float _alpha1 = autocvar_cl_mplant_drawdistance - autocvar_cl_mplant_fadedistance;
    float _dist = vlen(this.origin - view_origin);
    this.alpha = 1 - (_dist - _alpha1 / _alpha0);
    //1 - (_dist / autocvar_cl_mplant_drawdistance);
    //this.effects = EF_NOSHADOW;
    //}
    //else
    //	this.alpha = 1; //min(1, this.alpha + 0.001);

    if (autocvar_cl_mplant_boxdistance)
        if (_dist > autocvar_cl_mplant_boxdistance) {
            if (this.model != "null")
                setmodel(this, MDL_Null);
#define rgb '0.4 0.4 0.6' // todo: nicer shading
            // Top face
            R_BeginPolygon("", DRAWFLAG_NORMAL);
            R_PolygonVertex(this.mtu_point_topfwdright, '0 0 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_topfwdleft,  '0 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_topbckleft,  '1 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_topbckright, '0 1 0', rgb, this.alpha);
            R_EndPolygon();

            // Botton face
            R_BeginPolygon("", DRAWFLAG_NORMAL);
            R_PolygonVertex(this.mtu_point_btmfwdright, '0 0 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmfwdleft,  '0 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmbckleft, '1 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmbckright,  '0 1 0', rgb, this.alpha);
            R_EndPolygon();

            // Back face
            R_BeginPolygon("", DRAWFLAG_NORMAL);
            R_PolygonVertex(this.mtu_point_topbckright, '0 0 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_topbckleft,  '0 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmbckleft, '1 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmbckright,  '0 1 0', rgb, this.alpha);
            R_EndPolygon();

            // Right face
            R_BeginPolygon("", DRAWFLAG_NORMAL);
            R_PolygonVertex(this.mtu_point_topbckright, '0 0 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_topfwdright,  '0 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmfwdright, '1 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmbckright,  '0 1 0', rgb, this.alpha);
            R_EndPolygon();

            // Left face
            R_BeginPolygon("", DRAWFLAG_NORMAL);
            R_PolygonVertex(this.mtu_point_topbckleft, '0 0 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_topfwdleft,  '0 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmfwdleft, '1 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmbckleft,  '0 1 0', rgb, this.alpha);
            R_EndPolygon();

            // Front face
            R_BeginPolygon("", DRAWFLAG_NORMAL);
            R_PolygonVertex(this.mtu_point_topfwdright, '0 0 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_topfwdleft,  '0 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmfwdleft, '1 1 0', rgb, this.alpha);
            R_PolygonVertex(this.mtu_point_btmfwdright,  '0 1 0', rgb, this.alpha);
            R_EndPolygon();
#undef rgb

            return;
        }
}

void mplant_block_selected_draw2d(entity this)
{
    vector _v;
#define _corner_size '5 5 0'
#define _corner_clr '0.2 0.2 0.6'
#define _center_size '5 5 0'
#define _center_clr '0.6 0.2 0.2'
#define _corner_draw DRAWFLAG_NORMAL
#define _corner_alpha 1
#define _drawhandle(vec,clr,size) \
    _v = project_3d_to_2d(vec); \
    _v -= _corner_size;\
    _v_z = 0;\
    drawfill(_v + (0.5 * size), size, clr, _corner_alpha, _corner_draw)

    if (this.mdlplant_object_flags & MPOF_SHOWCORNERS) {
        _drawhandle(this.mtu_point_topfwdright, _corner_clr, _corner_size);
        _drawhandle(this.mtu_point_topfwdleft, _corner_clr, _corner_size);
        _drawhandle(this.mtu_point_topbckleft, _corner_clr, _corner_size);
        _drawhandle(this.mtu_point_topbckright, _corner_clr, _corner_size);

        _drawhandle(this.mtu_point_btmfwdright, _corner_clr, _corner_size);
        _drawhandle(this.mtu_point_btmfwdleft, _corner_clr, _corner_size);
        _drawhandle(this.mtu_point_btmbckleft, _corner_clr, _corner_size);
        _drawhandle(this.mtu_point_btmbckright, _corner_clr, _corner_size);
    }

    if (this.mdlplant_object_flags & MPOF_SHOWSIDES) {
        _drawhandle(this.mtu_point_right, _center_clr, _center_size);
        _drawhandle(this.mtu_point_left, _center_clr, _center_size);
        _drawhandle(this.mtu_point_forward, _center_clr, _center_size);
        _drawhandle(this.mtu_point_back, _center_clr, _center_size);
        _drawhandle(this.mtu_point_up, _center_clr, _center_size);
        _drawhandle(this.mtu_point_down, _center_clr, _center_size);

    }

    /*
    switch(this.mdlplant_object_type)
    {
        case MPOT_BLOCK_SOLID:
        case MPOT_BLOCK_UNSOLID:
        case MPOT_BLOCK_SCRIPT:
        case MPOT_DETAIL_SIMPLE:
        case MPOT_DETAIL_SCRIPT:
    }

    string _info;
    vector _l = project_3d_to_2d(this.origin);
    _l_z = 0;
    _info = sprintf("^3 Model:\t ^5 %s \n^3 Size: \t ^5 %v \n^3Origin\t^5%v", this.mdl, this.maxs - this.mins, this.origin);
    drawstringcenter(_l, _info, '1 1 1', '1 1 1', 0.5, DRAWFLAG_NORMAL);
    */

    //void	drawline(float width, vector pos1, vector pos2, vector rgb, float alpha, float flags) = #315;

#undef _corner_size
#undef _corner_draw
#undef _corner_alpha
#undef _corner_clr
#undef _drawhandle
}

void mplant_block_selected_draw(entity this)
{
}

void mplant_block_remove(entity this)
{
    if (this.mdl)
        strunzone(this.mdl);
}

void cl_mplant_player_info_draw2d(entity this)
{
    if (!this.mplant_active)
        return;

    drawstring('10 10 0', "Editmode", '20 20 0', '0 1 0', 1, DRAWFLAG_NORMAL);
    drawstring('10 30 0', strcat("Current tool: ", this.mplant_tool_name), '15 15 0', '0 1 1', 1, DRAWFLAG_NORMAL);
}

void cl_mplant_player_info_init(entity this, bool isnew)
{
    this.drawmask  = MASK_NORMAL;
    this.draw2d    = cl_mplant_player_info_draw2d;

    if(isnew)
        IL_PUSH(g_drawables_2d, this);
}

#endif
