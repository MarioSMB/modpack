/**
FOLIAGE FILE FORMANT 0.1
magic
    object uid
        prop name
        prop name
        ...
    object uid
        ...
    ...
REQUIERD PROPS
    models "model1|model2|..." random selection models.


**/

void mplant_foliage_rotate(entity _what, vector _how_much, float _absolute)
{
    mplant_rotate(_what, _how_much, _absolute);
    /*
    if (_absolute)
        _what.angles = _how_much;
    else
        _what.angles += _how_much;

    _what.angles_x = anglemods(_what.angles_x);
    _what.angles_y = anglemods(_what.angles_y);
    _what.angles_z = anglemods(_what.angles_z);

    mplant_btf(_what.angles, _what.mplant_org_mins, _what.mplant_org_maxs, false, '0 0 0');
    float i;
    _what.mins = _what.maxs = '0 0 0';
    for (i = 0; i < 9; ++i)
    {
        vtmp1 = mplant_btf_points[i];
        if (vtmp1_x < _what.mins_x) _what.mins_x = vtmp1_x;
        if (vtmp1_y < _what.mins_y) _what.mins_y = vtmp1_y;
        if (vtmp1_z < _what.mins_z) _what.mins_z = vtmp1_z;
        if (vtmp1_x > _what.maxs_x) _what.maxs_x = vtmp1_x;
        if (vtmp1_y > _what.maxs_y) _what.maxs_y = vtmp1_y;
        if (vtmp1_z > _what.maxs_z) _what.maxs_z = vtmp1_z;
    }
    setsize(_what, _what.mins, _what.maxs);
    */
    _what.SendFlags |= MPSF_ANGLES;
    _what.SendFlags |= MPSF_SIZE;
}

void mplant_foliage_delete(entity _block)
{
    if (_block.mdl)
        if (_block.mdl != "")
            strunzone(_block.mdl);

    _block.mdl = "";

    delete(_block);
}

float mplant_foliage_setprop(entity _e, string _prop_name, string _prop_val)
{
    _prop_name = strtolower(_prop_name);

    if (_prop_name == "origin") {
        setorigin(_e, stov(_prop_val));
        mplant_foliage_rotate(_e, _e.angles, true);
        _e.SendFlags |= MPSF_ORIGIN;
        return true;
    }

    if (_prop_name == "model") {
        _SETMODEL(_e, _prop_val);
        _e.solid			= SOLID_BSP;
        _e.mplant_org_mins	= _e.mins;
        _e.mplant_org_maxs	= _e.maxs;
        _e.SendFlags |= MPSF_MODEL;
        return true;
    }

    if (_prop_name == "angles") {
        vh // FIXME: wtf
        _e.angles = stov(_prop_val);
        mplant_foliage_rotate(_e, _e.angles, true);
        _e.SendFlags |= MPSF_ANGLES;
        return true;
    }

    return false;
}

float mplant_foliage_write(entity _e, float _fh)
{
    fputs(_fh, sprintf("create %s\n", _e.mplant_object_type));
    if (_e.model) fputs(_fh, sprintf("\tmodel \"%s\"\n", _e.model));
    if (_e.mplant_object_uid != "") fputs(_fh, sprintf("\tuid \"%s\"\n", _e.mplant_object_uid));
    fputs(_fh, sprintf("\tangles \"%v\"\n", _e.angles));
    fputs(_fh, sprintf("\torigin \"%v\"\n", _e.origin));

    return true;
}

#define _MPLANT_CSQCOBJECTS
entity mplant_foliage_create(entity this, string _uid)
{
    entity _block = spawn();
    _block.angles					= this.mplant_cursorobject.angles;
    _block.mdlplant_object_flags	= MPOF_ISMPLANTOBJECT | MPOF_SAVEABLE | MPOF_SELECTABLE;
    _block.mplant_object_create		= mplant_foliage_create;
    _block.mplant_object_setprop	= mplant_foliage_setprop;
    _block.mplant_object_rotate		= mplant_foliage_rotate;
    _block.mplant_object_write		= mplant_foliage_write;
    _block.mplant_object_type		= "block";
    _block.mplant_object_uid		= _uid;
    _block.mplant_object_delete	= mplant_foliage_delete;
    //SetResourceExplicit(_block, RES_HEALTH, 1);
    //_block.takedamage     = DAMAGE_YES;
    //_block.event_damage   = mplant_foliage_damage;

#ifdef _MPLANT_CSQCOBJECTS
    Net_LinkEntity(_block, true, 0, mplant_foliage_send);
#else
    _block.effects					= EF_SELECTABLE;
#endif
    return _block;
}
