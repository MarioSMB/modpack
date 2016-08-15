float mplant_tool_extrude_com(float _msg, float _f1, float _f2)
{
    return true;
}

float mplant_tool_extrude(entity this)
{
    // Hide cursor object
    this.mplant_cursorobject.effects |= EF_NODRAW;

    if (!PHYS_INPUT_BUTTON_ATCK(this))
        mplant_cursor_select(this);
    else {
        if (!this.mplant_cursorobject.enemy)
            return false;

        //if (!this.mplant_cursorobject.pos1)

        crosshair_trace(this);

        noref vector _start = this.mplant_cursorobject.enemy.origin;
        noref vector _end   = trace_endpos;
    }


    PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = false;
    return true;
}
