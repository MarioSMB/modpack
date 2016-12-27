#ifdef SVQC
float mplant_toolindex(string _name)
{
    for (entity t = mplant_root.mplant_tool_chain; t; t = t.mplant_tool_chain) {
        if (t.mplant_tool_name == _name)
            return t.mplant_tool_index;
    }
    return 0;
}

string mplant_toolname(float _toolidx)
{
    for (entity t = mplant_root.mplant_tool_chain; t; t = t.mplant_tool_chain) {
        if (t.mplant_tool_index == _toolidx)
            return t.mplant_tool_name;
    }
    return "Unknown tool";
}

float mplant_tool_register(string _name, float _index, float(entity) _func, float(float, float, float) _com)
{
    entity l = mplant_root.mplant_tool_chain;
    mplant_root.mplant_tool_chain					= spawn();
    mplant_root.mplant_tool_chain.classname			= "mplant tool object";
    mplant_root.mplant_tool_chain.mplant_tool_name	= _name;
    mplant_root.mplant_tool_chain.mplant_tool_index	= _index;
    mplant_root.mplant_tool_chain.mplant_toolfunc	= _func;
    mplant_root.mplant_tool_chain.mplant_tool_com	= _com;
    mplant_root.mplant_tool_chain.owner				= mplant_root;
    mplant_root.mplant_tool_chain.mplant_tool_chain	= l;

    dprint("^1Registerd ^2tool ", _name, " as ", etos(mplant_root.mplant_tool_chain), " prev is ", etos(l), "\n");
    return true;
}

void mplant_selecttool(entity this, float _toolidx)
{
    if (this.mplant_tool.mplant_tool_index == _toolidx)
        return;

    if (_toolidx > MPT_LAST)
        _toolidx = MPT_FIRST;

    if (_toolidx < MPT_FIRST)
        _toolidx = MPT_LAST;

    this.mplant_player_info.SendFlags |= MPPI_TOOL;

    for (entity t = mplant_root.mplant_tool_chain; t; t = t.mplant_tool_chain) {
        if (t.mplant_tool_index == _toolidx) {
            if (this.mplant_tool)
                this.mplant_tool.mplant_tool_com(MPTC_SWITCHFROM, 0, 0);

            this.mplant_tool = t;
            this.mplant_tool.mplant_tool_com(MPTC_SWITCHTO, 0, 0);
            return;
        }
    }
}

entity mplant_gettool(entity this, float _toolidx)
{
    if (_toolidx > MPT_LAST)
        return NULL;

    if (_toolidx < MPT_FIRST)
        return NULL;

    this.mplant_player_info.SendFlags |= MPPI_TOOL;

    for (entity t = mplant_root.mplant_tool_chain; t; t = t.mplant_tool_chain) {
        if (t.mplant_tool_index == _toolidx)
            return t;
    }

    return NULL;
}

#define _mp_select(pl,_e) \
    _e.mdlplant_object_flags |= MPOF_SELECTED; \
    if (pl.mplant_snaptions & MPS_CORNER) \
        _e.mdlplant_object_flags |= MPOF_SHOWCORNERS;\
    if (pl.mplant_snaptions & MPS_CENTER) \
        _e.mdlplant_object_flags |= MPOF_SHOWSIDES;\
    _e.SendFlags |= MPSF_FLAGS

#define _mp_deselect(_e) \
    _e.mdlplant_object_flags &= ~MPOF_SELECTED; \
    _e.mdlplant_object_flags &= ~MPOF_SHOWCORNERS; \
    _e.mdlplant_object_flags &= ~MPOF_SHOWSIDES; \
    _e.SendFlags |= MPSF_FLAGS

/**
    Returns the mplant object pointed at, or NULL if none / to far away (mplant_cursor_select_maxdistance)
**/
entity mplant_cursor_select(entity this)
{
    crosshair_trace(this);
    if (_MPLANT_SELECTABLE(trace_ent))
        if (vdist(trace_ent.origin - this.origin, <=, this.mplant_cursor_select_maxdistance))
        {
            if (this.mplant_cursorobject.enemy)
            {
                _mp_deselect(this.mplant_cursorobject.enemy);
            }

            this.mplant_cursorobject.enemy = trace_ent;
            _mp_select(this, this.mplant_cursorobject.enemy);

            this.mplant_cursorobject.wait = time + 0.1;
        }

    if (this.mplant_cursorobject.enemy)
        if (this.mplant_cursorobject.wait < time) {
            _mp_deselect(this.mplant_cursorobject.enemy);
            this.mplant_cursorobject.enemy = NULL;
        }

    return this.mplant_cursorobject.enemy;
}

void mplant_tools_init()
{

}

// Unpolute
#undef _mp_select
#undef _mp_deselect
#endif
