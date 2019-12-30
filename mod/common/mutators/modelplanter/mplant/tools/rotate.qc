float mplant_tool_rotate_com(float _msg, float _f1, float _f2)
{
    return true;
}

/**
    Rotates eigther the object pointed at or the cursorobject  if no mplant object is pointed at.
    Pressing both mouse button resets objects rotation to '0 0 0'
**/
float mplant_tool_rotate(entity this)
{
    entity _targ = mplant_cursor_select(this);

    if (!_targ) {
        vector forward, right, up;
        MAKE_VECTORS(this.v_angle, forward, right, up);
        setorigin(this.mplant_cursorobject, this.origin + this.view_ofs + (forward * 256));
        this.mplant_cursorobject.effects &= ~EF_NODRAW;
        _targ = this.mplant_cursorobject;
        _targ.angles = _targ.pos1;

        if (!_targ.mplant_object_rotate)
            return false;

    } else {
        if (!_targ.mplant_object_rotate)
            return false;

        this.mplant_cursorobject.effects |= EF_NODRAW;
    }

    if (PHYS_INPUT_BUTTON_ATCK(this) && PHYS_INPUT_BUTTON_ATCK2(this) && this.create_refire < time) {
        _targ.mplant_object_rotate(_targ, '0 0 0', true);
        this.create_refire = time + 0.25;
    }

    if (PHYS_INPUT_BUTTON_ATCK(this) && this.create_refire < time) {
        _targ.mplant_object_rotate(_targ, '0 45 0', false);
        this.create_refire = time + 0.25;
    }

    if (PHYS_INPUT_BUTTON_ATCK2(this) && this.create_refire < time) {
        _targ.mplant_object_rotate(_targ, '45 0 0', false);
        this.create_refire = time + 0.25;
    }

    /*
        if (!this.mplant_cursorobject.enemy)
            this.mplant_cursorobject.angles = this.mplant_cursorobject.pos1;


        if (PHYS_INPUT_BUTTON_ATCK(this))
        {
            if (!this.mplant_cursorobject.enemy)
            {
                if (_MPLANT_SELECTABLE(trace_ent))
                    this.mplant_cursorobject.enemy = trace_ent;
                else
                    this.mplant_cursorobject.enemy = this.mplant_cursorobject;

                this.mplant_cursorobject.pos2 = this.v_angle;
            }

            if (this.mplant_cursorobject.enemy == this.mplant_cursorobject)
                this.mplant_cursorobject.effects &= ~EF_NODRAW;
            else
                this.mplant_cursorobject.effects |= EF_NODRAW;

            this.mplant_cursorobject.wait = time + 0.1;

            vector _rel = (this.mplant_cursorobject.pos2 - this.v_angle);

            this.mplant_cursorobject.enemy.angles_x = this.mplant_cursorobject.enemy.angles_x + fsnap(_rel_x * this.mplant_tool_multiplier_x, this.mplant_tool_multiplier_y);
            this.mplant_cursorobject.enemy.angles_y = this.mplant_cursorobject.enemy.angles_y + fsnap(_rel_y * this.mplant_tool_multiplier_x, this.mplant_tool_multiplier_y);
            this.mplant_cursorobject.enemy.angles = AnglesTransform_Normalize(this.mplant_cursorobject.enemy.angles, false);
            this.mplant_cursorobject.pos2 = this.v_angle;

            if (this.mplant_cursorobject.enemy == this.mplant_cursorobject)
               this.mplant_cursorobject.pos1 = this.mplant_cursorobject.enemy.angles;
            else
                this.mplant_cursorobject.enemy.SendFlags |= MPSF_ANGLES;
        }
        else
        {
            //this.mplant_cursorobject.pos2 = this.v_angle;
            if (this.mplant_cursorobject.enemy && this.mplant_cursorobject.wait < time)
               this.mplant_cursorobject.enemy = NULL;
        }
    */
    PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = false;
    return true;
}
