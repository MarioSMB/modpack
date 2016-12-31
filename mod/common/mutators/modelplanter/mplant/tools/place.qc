bool mplant_tool_place_com(float _msg, float _f1, float _f2)
{
    return true;
}

bool mplant_tool_place(entity this)
{
    float  s, bs = max_shot_distance, i, y;
    vector vO = '0 0 0';

    this.mplant_cursorobject.effects &= ~EF_NODRAW;
    //crosshair_trace(this); // mplant_cursor_select calls this
    noref entity _targ = mplant_cursor_select(this);
    if (_MPLANT_SELECTABLE(trace_ent) && (this.mplant_snaptions & MPS_BLOCKS)) {
        this.mplant_cursorobject.angles = this.mplant_cursorobject.pos1;

        if (this.mplant_snaptions & MPS_SRCANGLE)
            if (trace_ent.angles != this.mplant_cursorobject.angles)
                this.mplant_cursorobject.angles +=  trace_ent.angles;

        if (this.mplant_snaptions & MPS_NORMANGLE)
            this.mplant_cursorobject.angles += vectoangles(trace_plane_normal);

        // Figure out is use is poiting somewhat at a side-center
        mplant_btf(trace_ent, trace_ent.angles, trace_ent.mplant_org_mins, trace_ent.mplant_org_maxs, true, trace_ent.origin, trace_ent.mplant_object_anglefix);
        for (i = 14; i < 28; ++i) {
            s = vlen(trace_endpos - mplant_btf_points[i]);
            if (s < bs) {
                bs = s;
                vtmp1 = mplant_btf_points[i];
                vtmp2 = normalize(vtmp1 - trace_ent.origin);
                vtmp2 *= vlen(vtmp1 - trace_ent.origin);
                vtmp2 += vtmp1;
                vO = vtmp1;
            }
        }

        if (bs < 8) {
            te_lightning1(trace_ent, vO, vtmp2);
            setorigin(this.mplant_cursorobject, vtmp2);
        } else {
            setorigin(this.mplant_cursorobject, trace_endpos - (normalize(trace_endpos - this.origin) * 48) + trace_plane_normal * 96);
            bs = max_shot_distance;

            float _start1 = 0;
            float _stop1  = 8;
            float _start2 = 14;
            float _stop2  = 22;

            if (!(this.mplant_snaptions & MPS_CORNER)) {
                _start1 = 8;
                _start2 = 22;
            }

            if (this.mplant_snaptions & MPS_CENTER) {
                _stop1 = 14;
                _stop2 = 27;
            }

            //dprint(sprintf("^3range1:^2%d^7-^1%d    ^3range1:^2%d^7-^1%d\n", _start1, _stop1, _start2, _stop2));

            mplant_btf(this.mplant_cursorobject, this.mplant_cursorobject.angles, this.mplant_cursorobject.mplant_org_mins, this.mplant_cursorobject.mplant_org_maxs, false, this.mplant_cursorobject.origin, this.mplant_cursorobject.mplant_object_anglefix);
            for (i = _start1; i < _stop1; ++i)
                for (y = _start2; y < _stop2; ++y) {
                    vtmp1 = mplant_btf_points[i];
                    vtmp2 = mplant_btf_points[y];
                    s = vlen(vtmp1 - vtmp2);
                    if (s < bs) {
                        vO = vtmp1 - vtmp2;
                        bs = s;
                    }
                }
            setorigin(this.mplant_cursorobject, this.mplant_cursorobject.origin -  vO);
        }
    } else {
        if (vdist(trace_endpos - this.origin, >, this.mplant_cursor_placedist))
            trace_endpos = this.origin + this.view_ofs + (v_forward * this.mplant_cursor_placedist);
        else {
            float _pb = 0;
            if (this.mplant_cursor_pushback == -1) // Try to figure out pushback?
                _pb = 0.25 * vlen(this.mplant_cursorobject.mins - this.mplant_cursorobject.maxs) * this.mplant_cursorobject.scale;
            else if (this.mplant_cursor_pushback != 0)
                _pb = this.mplant_cursor_pushback * this.mplant_cursorobject.scale;

            trace_endpos += trace_plane_normal * _pb;
        }


        if (this.mplant_snaptions & MPS_GRID)
            trace_endpos = vsnap(trace_endpos, this.mplant_grid);

        setorigin(this.mplant_cursorobject, trace_endpos);
        this.mplant_cursorobject.angles = this.mplant_cursorobject.pos1;

        /*
            if (this.mplant_snaptions & MPS_GRID)
            {
                makevectors(this.v_angle);
                setorigin(this.mplant_cursorobject, vsnap(this.origin + this.view_ofs + (v_forward * this.mplant_cursor_placedist), this.mplant_grid));
            }
            else
                setorigin(this.mplant_cursorobject, trace_endpos + trace_plane_normal * 32);
        */
    }


    if (PHYS_INPUT_BUTTON_ATCK(this) && this.create_refire <= time) {
        entity m = mplant_block_create(this, "");
        m.mplant_object_setprop(m, "model", this.mplant_cursorobject.model);
        m.mplant_object_setprop(m, "origin", vtos(this.mplant_cursorobject.origin));
        m.mplant_object_setprop(m, "angles", vtos(this.mplant_cursorobject.angles));

        this.create_refire = time + 0.25;
    }

    if (PHYS_INPUT_BUTTON_ATCK2(this) && this.create_refire <= time)
        if (_MPLANT_SELECTABLE(trace_ent)) {
            //mplant_block_delete(trace_ent);
            trace_ent.mplant_object_delete(trace_ent);
            this.create_refire = time + 0.25;
        }

    PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = false;
    return true;
}
