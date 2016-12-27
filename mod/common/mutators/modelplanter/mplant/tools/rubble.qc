float mplant_tool_rubble_com(float _msg, float _f1, float _f2)
{
    return true;
}
void mplant_setmark(entity this, int _idx);
float mplant_tool_rubble(entity this)
{
    //float  s, bs = MAX_SHOT_DISTANCE, i, y;
    //vector vO;
    float _pb = 0;

    this.mplant_cursorobject.effects &= ~EF_NODRAW;
    crosshair_trace(this);

    if (this.mplant_cursor_pushback == -1) // Try to figure out pushback?
        _pb = 0.25 * vlen(this.mplant_cursorobject.mins - this.mplant_cursorobject.maxs) * this.mplant_cursorobject.scale;
    else if (this.mplant_cursor_pushback != 0)
        _pb = this.mplant_cursor_pushback * this.mplant_cursorobject.scale;

    trace_endpos += trace_plane_normal * _pb;

    if (this.mplant_snaptions & MPS_GRID)
        trace_endpos = vsnap(trace_endpos, this.mplant_grid);

    setorigin(this.mplant_cursorobject, trace_endpos);

    if (!PHYS_INPUT_BUTTON_ATCK2(this))
    if (this.mplant_cursor_privatespace) {
        for (entity _e = findradius(trace_endpos, this.mplant_cursor_privatespace); _e; _e = _e.chain) {
            if (_e.mdlplant_object_flags & MPOF_ISMPLANTOBJECT) {
                PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = false;
                this.mplant_cursorobject.colormod = '1 0 0';
                return true;
            }
        }
        this.mplant_cursorobject.colormod = '1 1 1';
    }

    float _do_rand = false;
    if (PHYS_INPUT_BUTTON_ATCK(this) && this.create_refire <= time) {
        entity m = mplant_block_create(this, "");
        m.mplant_object_setprop(m, "model",		this.mplant_cursorobject.model);
        m.mplant_object_setprop(m, "origin",	vtos(this.mplant_cursorobject.origin));
        m.mplant_object_setprop(m, "angles",	vtos(this.mplant_cursorobject.angles));
        m.mplant_object_setprop(m, "scale", 	ftos(this.mplant_cursorobject.scale));
        this.create_refire = time + 0.25;

        _do_rand = true;
    }

    if (PHYS_INPUT_BUTTON_ATCK2(this) && this.create_refire <= time)
        if (_MPLANT_SELECTABLE(trace_ent)) {
            trace_ent.mplant_object_delete(trace_ent);
            this.create_refire = time + 0.25;
        } else {
            _do_rand = true;
        }

    if (_do_rand) {
        this.mplant_tool_modelindex = bound(1, rint(random() * this.mplant_set_models_count),this.mplant_set_models_count - 1);
        mplant_setmark(this, this.mplant_tool_modelindex);

        this.mplant_cursorobject.angles = this.mplant_random_rot_min + (random() * this.mplant_random_rot_max);
        this.mplant_cursorobject.scale = this.mplant_random_scale_min + random() * (this.mplant_random_scale_max - this.mplant_random_scale_min);

    }
    PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = false;
    return true;
}
