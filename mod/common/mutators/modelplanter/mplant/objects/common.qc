void mplant_rotate(entity _what, vector _how_much, float _absolute)
{
    _what.angles = ((_absolute) ? _how_much : _what.angles + _how_much);

    _what.angles_x = anglemods(_what.angles_x);
    _what.angles_y = anglemods(_what.angles_y);
    _what.angles_z = anglemods(_what.angles_z);

    mplant_btf(_what, _what.angles, _what.mplant_org_mins, _what.mplant_org_maxs, false, '0 0 0', _what.mplant_object_anglefix);
    _what.mins = '1 1 1' * max_shot_distance;
    _what.maxs = '-1 -1 -1' * max_shot_distance;
    for (int i = 0; i < 9; ++i) {
        vtmp1 = (mplant_btf_points[i]);

        if (vtmp1_x < _what.mins_x) _what.mins_x = vtmp1_x;
        if (vtmp1_y < _what.mins_y) _what.mins_y = vtmp1_y;
        if (vtmp1_z < _what.mins_z) _what.mins_z = vtmp1_z;

        if (vtmp1_x > _what.maxs_x) _what.maxs_x = vtmp1_x;
        if (vtmp1_y > _what.maxs_y) _what.maxs_y = vtmp1_y;
        if (vtmp1_z > _what.maxs_z) _what.maxs_z = vtmp1_z;
    }

    setsize(_what, _what.mins, _what.maxs);
}
