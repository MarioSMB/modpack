void mplant_export(string _filename)
{
#define _PUTKEY(handle,key,value) \
fputs(handle, "\""); \
fputs(handle, key); \
fputs(handle, "\" "); \
fputs(handle, "\""); \
fputs(handle, strreplace("'", "", value)); \
fputs(handle, "\"\n")

    string s;

    if (_filename == "")
        s = strcat("maps/", mapname, ".map");
    else
        s = _filename;

    float fh = fopen(s, FILE_WRITE);

    if (fh < 0)
        return;

    fputs(fh, "{\n\"classname\" \"worldspawn\"\n}\n");

    for (entity mplant = findchainflags(mdlplant_object_flags, MPOF_ISMPLANTOBJECT); mplant; mplant = mplant.chain) {
        fputs(fh, "{\n");
        _PUTKEY(fh, "origin", vtos(mplant.origin));
        _PUTKEY(fh, "angles", vtos(mplant.angles));
        _PUTKEY(fh, "modelscale", ftos(mplant.scale));
        _PUTKEY(fh, "classname", "misc_model");
        _PUTKEY(fh, "model", strreplace(".bsp", ".ase", mplant.model));
        _PUTKEY(fh, "spawnflags", "6");
        fputs(fh, "}\n");
    }
#undef _PUTKEY
}

void _mplant_load_oldformant(entity this, string _filename)
{
    string s;
    float mdlcount = 0, filterd = 0;
    entity m;
    mplant_clear();

    float fh = fopen(_filename, FILE_READ);

    if (fh < 0)
        return;

    while ((s = fgets(fh))) {
        if (s == "<MDL>") {
            m = mplant_block_create(this, "");
            m.mplant_object_setprop(m, "origin", fgets(fh));
            m.mplant_object_setprop(m, "angles", fgets(fh));
            m.mplant_object_setprop(m, "model", fgets(fh));
            ++mdlcount;
        }
    }
    dprint("^3Loaded ", ftos(mdlcount), " blocks\n");
    dprint("^2Filterd (removed) ", ftos(filterd), " blocks\n");
    dprint("^4+/- = ", ftos(filterd - mdlcount), " blocks\n");
    fclose(fh);
}

/**
magic
create <object_type>
    param1 value1
    param2 value2

example
mplantformat:1
create block
    model "models/media/crazyape.md3"
    origin "256 512 128"
    angles "0 45 0"
    colormod "0.5 2 0.5"

create item
    classname info_player_deathmatch
    origin "300 500 200"
    angles "0 -45 0"
...

    NOTE:
        sofar only objects of type "block" is supported.
        Anything else will be ignored AND REMOVED by re-save
**/

#define _MPLANT_F1ID "mplantformat:1"
void _mplant_formant1_load(entity this, string _filename, float _append, vector _rel)
{
    string s;
    float _obj_cnt = 0, _filter_cnt = 0, r;

    if (!_append)
        mplant_clear();

    float fh = fopen(_filename, FILE_READ);

    if (fh < 0) {
        dprint("^1ERROR:^7 cannot open file ", _filename, "\n");
        return;
    }

    if (fgets(fh) != _MPLANT_F1ID) {
        dprint("^1ERROR:^7 File ^3", _filename, "^7 is NOT a mplant format 1 file!\n");
        fclose(fh);
        return;
    }

    dprint("Loading ", _filename, " as mplant format1 file...\n");
    while ((s = fgets(fh))) {
        r = tokenize_console(s);
        if (r) {
            entity m = NULL;
            string _object_type = "<unknown object>";
            if (argv(0) == "create") {
                ++_obj_cnt;
                _object_type = argv(1);
                m = mplant_object_create_by_type(this, _object_type, "");
                if (!m)
                {
                    ++_filter_cnt;
                    dprint("Object type ", _object_type, " not supported (ignored)\n");
                }
            } else {
                if (m) {
                    if (m.mplant_object_setprop(m, argv(0), argv(1)))
                        dprint("Property ", argv(0), " set to ", argv(1), " successfully\n");
                    else
                        dprint("Object ", _object_type, " does not handle property ", argv(0), "(ignored)\n");
                } else
                    dprint("Object type ", _object_type, " not supported, property ", argv(0), " ignored\n");
            }
        }
    }
    fclose(fh);

    dprint("^3Loaded ", ftos(_obj_cnt), " objects\n");
    dprint("^2Filterd (removed) ", ftos(_filter_cnt), " objects\n");
    dprint("^4+/- = ", ftos(_filter_cnt - _obj_cnt), " objects\n");
}

void mplant_load(entity this, string _filename)
{
    if (!_filename || _filename == "")
        _filename = strcat("maps/", mapname, ".mplant");

    string _ext = getfileext(_filename);
    if (_ext == "mdls")
        _mplant_load_oldformant(this, _filename);
    else if (_ext == "mplant")
        _mplant_formant1_load(this, _filename, false, '0 0 0');
    else
        centerprint(this, sprintf("Unknown filetype: ^3%s", _ext));
}

void mplant_save(string _filename)
{
    if (_filename == "")
        _filename = strcat("maps/", mapname, ".mplant");

    string _ext = getfileext(_filename);
    if (_ext == _filename || _ext != "mplant") {
        _filename = strcat(_filename, ".mplant");
        dprint("^3NOTICE: appnding .mplant to filename\n");
    }


    float fh = fopen(_filename, FILE_WRITE);

    if (fh < 0) {
        dprint("^1WARNING ^7 saving as ", _filename, " has failed!\n");
        return;
    }

    fputs(fh, "mplantformat:1\n");
    float _cnt = 0, _fail = 0;
    for (entity mplant = findchainflags(mdlplant_object_flags, MPOF_ISMPLANTOBJECT); mplant; mplant = mplant.chain) {
        ++_cnt;
        if (mplant.mplant_object_write) {
            if (!mplant.mplant_object_write(mplant, fh))
                ++_fail;
        } else {
            dprint("^1WARNING:^7 object ^3", etos(mplant), " ^7has no mplant_object_write fucntion (will not be saved)!");
            ++_fail;
        }
    }
    fclose(fh);
    dprint("^3File ", _filename, " ^2saved\n");
    dprint("^3Objects parsed: ", ftos(_cnt), "\n");
    if (_fail)
        dprint("^3WARNING:^1 ", ftos(_fail), "^7 objects failed to save!\n");
}
