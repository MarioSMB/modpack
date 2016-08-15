/**
	Returns the filetitle part of a pathspec.
		eg "file.ext" of "/home/foo/bar.file.ext"
	@_filename pathspec
**/
string getfiletitle(string _filename)
{
	int sl = strlen(_filename);
	for (int i = sl; i != 0; --i)
		if (strstrofs(_filename, "/", i) != -1)
			return substring(_filename, i + 1, sl - i - 5);

	return _filename;
}

/**
	Returns the file extention of a pathspec
		eg "ext" of "/home/foo/bar.file.ext"
	@_filename pathspec
**/
string getfileext(string _filename)
{
	int _len = strlen(_filename);
	for (int i = _len; i != 0; --i)
		if (strstrofs(_filename, ".", i) != -1)
			return substring(_filename, i + 1, _len);

	return _filename;
}
#ifdef SVQC
/**
	Transforms a bbox by angles result written to the global mplant_btf_points[] array
	@_angles angles to transform by
	@_mins untransformed mins
	@_maxs untransformed maxs
	@_secondary results in secondary buffer
	@_ofs offset (this.origin for world coordinates, '0 0 0' for local transform)
**/
void mplant_btf(entity _obj, vector _angles, vector _mins, vector _maxs, float _secondary, vector _ofs, float _anglefix)
{
	if (_anglefix)
		_angles_x *= -1;

	if (_secondary)
		_secondary = 14;

	fixedmakevectors(_angles);
	_mins *= _obj.scale;
	_maxs *= _obj.scale;

	mplant_btf_points[btf_primary_topfwdleft  + _secondary] = _ofs + (v_forward * _maxs_x + v_right  * (-_maxs_y) + v_up * _maxs_z);
	mplant_btf_points[btf_primary_topfwdright + _secondary] = _ofs + (v_forward * _maxs_x + v_right  * (-_mins_y) + v_up * _maxs_z);
	mplant_btf_points[btf_primary_topbckleft  + _secondary] = _ofs + (v_forward * _mins_x + v_right  * (-_maxs_y) + v_up * _maxs_z);
	mplant_btf_points[btf_primary_topbckright + _secondary] = _ofs + (v_forward * _mins_x + v_right  * (-_mins_y) + v_up * _maxs_z);
	mplant_btf_points[btf_primary_btmfwdleft  + _secondary] = _ofs + (v_forward * _maxs_x + v_right  * (-_maxs_y) + v_up * _mins_z);
	mplant_btf_points[btf_primary_btmfwdright + _secondary] = _ofs + (v_forward * _maxs_x + v_right  * (-_mins_y) + v_up * _mins_z);
	mplant_btf_points[btf_primary_btmbckleft  + _secondary] = _ofs + (v_forward * _mins_x + v_right  * (-_maxs_y) + v_up * _mins_z);
	mplant_btf_points[btf_primary_btmbckright + _secondary] = _ofs + (v_forward * _mins_x + v_right  * (-_mins_y) + v_up * _mins_z);

	mplant_btf_points[btf_primary_left    + _secondary] = _ofs + (v_right * (-_maxs_y));
	mplant_btf_points[btf_primary_right   + _secondary] = _ofs + (v_right * (-_mins_y));
	mplant_btf_points[btf_primary_forward + _secondary] = _ofs + (v_forward * _maxs_x);
	mplant_btf_points[btf_primary_back    + _secondary] = _ofs + (v_forward * _mins_x);
	mplant_btf_points[btf_primary_up      + _secondary] = _ofs + (v_up * _maxs_z);
	mplant_btf_points[btf_primary_down    + _secondary] = _ofs + (v_up * _mins_z);
}

void mplant_cursorobject_rotate(entity _what, vector _how_much, float _absolute)
{
	if (_absolute)
		_what.angles = _how_much;
	else
		_what.angles += _how_much;

	_what.angles_x = anglemods(_what.angles_x);
	_what.angles_y = anglemods(_what.angles_y);
	_what.angles_z = anglemods(_what.angles_z);

	mplant_btf(_what, _what.angles, _what.mplant_org_mins, _what.mplant_org_maxs, false, '0 0 0', _what.mplant_object_anglefix);
	_what.mins = _what.maxs = '0 0 0';
	for (int i = 0; i < 9; ++i) {
		vtmp1 = mplant_btf_points[i];
		if (vtmp1_x < _what.mins_x) _what.mins_x = vtmp1_x;
		if (vtmp1_y < _what.mins_y) _what.mins_y = vtmp1_y;
		if (vtmp1_z < _what.mins_z) _what.mins_z = vtmp1_z;
		if (vtmp1_z < _what.mins_z) _what.mins_z = vtmp1_z;
		if (vtmp1_x > _what.maxs_x) _what.maxs_x = vtmp1_x;
		if (vtmp1_y > _what.maxs_y) _what.maxs_y = vtmp1_y;
		if (vtmp1_z > _what.maxs_z) _what.maxs_z = vtmp1_z;
	}
	setsize(_what, _what.mins, _what.maxs);

	_what.pos1 = _what.angles;
}

void mplant_setmark(entity this, int _idx)
{
	if (!this.mplant_cursorobject) {
		LOG_DEBUG("^1ERROR:^7 mplant_setmark called with no mplant_cursorobject spawned");
		return;
	}

	_SETMODEL(this.mplant_cursorobject, bufstr_get(this.mplant_set_models, _idx));
	this.mplant_cursorobject.mplant_org_mins = this.mplant_cursorobject.mins;
	this.mplant_cursorobject.mplant_org_maxs = this.mplant_cursorobject.maxs;
	this.mplant_cursorobject.mplant_object_rotate = mplant_cursorobject_rotate;
	this.mplant_cursorobject.mplant_object_rotate(this.mplant_cursorobject, '0 0 0', true);

	string _msg = sprintf("^3Block name: ^2%s.%s\n ^3Size: ^2%v",
						  getfiletitle(bufstr_get(this.mplant_set_models, _idx)),
						  getfileext(bufstr_get(this.mplant_set_models, _idx)),
						  this.mplant_cursorobject.maxs - this.mplant_cursorobject.mins);
	centerprint(this, _msg);
}

float _mplant_load_dir_models(entity this, string _ptrn)
{
	float sh = search_begin(_ptrn, true, true);
	if (sh == -1)
		return false;

	float _num_models = search_getsize(sh);

	LOG_DEBUG("^3Loading models matching ", _ptrn);
	for (int i = 0; i < _num_models; ++i) {
		string fn = search_getfilename(sh, i);
		bufstr_set(this.mplant_set_models, i + this.mplant_set_models_count, fn);
		precache_model(fn);
		LOG_DEBUG("  ^2> Loaded model ", fn);
	}
	search_end(sh);

	this.mplant_set_models_count += _num_models;

	return true;
}

float mplant_load_dir_models(entity this, string _dir)
{
	if (this.mplant_set_models)
		buf_del(this.mplant_set_models);

	this.mplant_set_models       = 0;
	this.mplant_set_models_count = 0;
	this.mplant_set_models       = buf_create();

	float _bsp = _mplant_load_dir_models(this, sprintf("%s/*.bsp", _dir));
	float _obj = _mplant_load_dir_models(this, sprintf("%s/*.obj", _dir));
	float _md3 = _mplant_load_dir_models(this, sprintf("%s/*.md3", _dir));

	//_mplant_load_dir_models(sprintf("%s/*.bsp"), _dir);

	if (!_md3 && !_bsp && !_obj)
		return false;

	return true;
}

bool mplant_load_dirs()
{
	float fh = fopen("models/modelplant/mplant.txt", FILE_READ);
	float sh = 0, i, sz, _has_models;
	string fn, s, ext;

	if (fh < 0)
		return false;

	if (mplant_sets) {
		buf_del(mplant_sets);
		mplant_set_count = 0;
	}

	while ((s = fgets(fh))) {
		_has_models = false;
		sh = search_begin(sprintf("models/modelplant/%s/*", s), true, true);
		if (sh != -1) {
			sz = search_getsize(sh);
			LOG_DEBUG(" ^3> Loading dir: ^2", s);
			for (i = 0; i < sz; ++i) {
				fn = search_getfilename(sh, i);
				ext = getfileext(fn);
				if (ext == "md3" || ext == "bsp" || ext == "obj") {
					LOG_DEBUG("  ^3> Loading model ^2", fn);
					precache_model(fn);
					_has_models = true;
				} else
					LOG_DEBUG("  ^3> Model ^3", fn, ": format not supported.");
			}

			if (_has_models) {
				bufstr_set(mplant_sets, mplant_set_count, s);
				++mplant_set_count;
			}
		}
	}

	fclose(fh);
	search_end(sh);

	return true;
}

void mplant_clear()
{
	for (entity mplant = findchainflags(mdlplant_object_flags, MPOF_ISMPLANTOBJECT); mplant; mplant = mplant.chain) {
		setthink(mplant, SUB_Remove);
		mplant.nextthink = time;
	}
}

void mplant_distclean(entity this)
{
	float keep = false;
	for (entity n = findradius(this.origin, this.cnt); n; n = n.chain) {
		if (n.mdlplant_object_flags & MPOF_ISMPLANTOBJECT && n != this)
			if(vdist(n.origin - this.origin, >, 8))
				keep = true;
	}

	if (keep)
		return;

	setthink(this, SUB_Remove);
	this.nextthink = time;
}

void mplant_clean(float _rad)
{
	for (entity mplant = findchainflags(mdlplant_object_flags, MPOF_ISMPLANTOBJECT); mplant; mplant = mplant.chain) {
		setthink(mplant, mplant_distclean);
		mplant.nextthink = time;
		mplant.cnt = _rad;
	}
}

void mplant_switch_block(entity this, float _down)
{
	this.create_refire = time + 0.25;
	if (_down) {
		this.mplant_tool_modelindex -= 1;
		if (this.mplant_tool_modelindex <= 0)
			this.mplant_tool_modelindex = this.mplant_set_models_count;
	} else {
		this.mplant_tool_modelindex += 1;
		if (this.mplant_tool_modelindex >= this.mplant_set_models_count)
			this.mplant_tool_modelindex = 0;
	}

	mplant_setmark(this, this.mplant_tool_modelindex);
	this.mplant_cursorobject.angles = this.mplant_cursorobject.pos1 = '0 0 0';
}

entity mplant_object_create_by_type(entity this, string _type, string _uid)
{
	_type = strtolower(_type);

	if (_type == "block")
		return mplant_block_create(this, _uid);

	return NULL;
}

void mplant_set_buildmode(entity this, bool _on)
{
	if (_on && !this.mplant_active) {
		/*
		this.weapons = 0;
		this.weapons = W_WeaponBit(WEP_BLASTER) | W_WeaponBit(WEP_SHOTGUN) | W_WeaponBit(WEP_GRENADE_LAUNCHER)| W_WeaponBit(WEP_UZI) | W_WeaponBit(WEP_NEX);
		*/
		this.movetype = MOVETYPE_NOCLIP;
		this.mplant_active = true;
		this.mplant_tool_multiplier = '2 10 0'; // TODO: interface with cmd. Only used by rotate tool atm. rotate: x = acceleration, y = snapangle, z = unused
		centerprint(this, "Editor ^2Enabled");
	} else if (!_on && this.mplant_active) {
		this.mplant_active = false;
		centerprint(this, "Editor ^3Disabled");
		PutClientInServer(this);
		//PutObserverInServer();
	}

	this.mplant_player_info.SendFlags |= MPPI_ENABLE;

}

#define _MPSF_MAGIC1 "MPLANTOPTIONS-V1"
void mplant_save_settings(entity this)
{
	//string mplant_toolname(float _toolidx)
	string fn;
	float fh, i;
	entity _tool;

	if (edict_num(1) == this)
		fn = "mplant-local.options";
	else {
		if (this.crypto_idfp == "") {
			centerprint(this, "Your client has no crypto id, settings will not be saved.");
			return;
		}
		fn = sprintf("mplant-%s.options", this.crypto_idfp);
	}

	if ((fh = fopen(fn, FILE_WRITE)) < 0) {
		LOG_DEBUG("^1ERROR: ^7 mplant can not open ", fn, " for witing.");
		return;
	}
	fputs(fh, sprintf("%s\n", _MPSF_MAGIC1));
	fputs(fh, sprintf("%d\n", MPT_FIRST));
	fputs(fh, sprintf("%d\n", MPT_LAST));
	for (i = MPT_FIRST; i <= MPT_LAST; ++i) {
		_tool = mplant_gettool(this, i);
		if (_tool) {
			fputs(fh, sprintf("<TOOL %s>\n"), mplant_toolname(i));
			_tool.mplant_tool_com(MPTC_SAVE, fh, 0);
			fputs(fh, "</TOOL>");
		} else
			LOG_DEBUG("^3WARNING:^7 failed to fetch tool object!");

	}
	//this.mplant_tool_bufs[i]
}

float mplant_player_info_send(entity this, entity to, float sf);
void mplant_selecttool(entity this, float _toolidx);
void mplant_client_init(entity this)
{
	// Allocate buffers for tool settings. TODO: Load from disc for registerd clients.
	for (int j = MPT_FIRST; j <= MPT_LAST; ++j)
		this.mplant_tool_bufs[j] = buf_create();

	this.mplant_snaptions   = MPS_CORNER | MPS_SRCANGLE | MPS_TOOLANGLE | MPS_BLOCKS | MPS_GRID;
	this.mplant_set_index   = 0;
	this.mplant_grid        = 32;
	this.mplant_cursor_select_maxdistance = 2048;
	this.mplant_cursor_pushback = 64;
	this.mplant_cursor_privatespace = 0;
	this.mplant_random_scale_min = 0.25;
	this.mplant_random_scale_max = 3;
	this.mplant_random_rot_min = '-32 -180 0';
	this.mplant_random_rot_max = '32 180 0';
	this.mplant_cursor_placedist = 300;

	this.mplant_player_info = spawn();
	this.mplant_player_info.owner = this;
	this.mplant_player_info.drawonlytoclient = this;
	Net_LinkEntity(this.mplant_player_info, false, 0, mplant_player_info_send);

//#define MTBO_SNAP 0
//#define MTBO_MUL  1

	mplant_setmark(this, 0);
	mplant_selecttool(this, MPT_FIRST);
	string getter = bufstr_get(mplant_sets, this.mplant_set_index);
	if(getter != "" && getter)
		getter = strcat("/", getter);
	mplant_load_dir_models(this, sprintf("models/modelplant%s", getter));

}

void mplant_client_shutdown(entity this)
{
	// Free buffers for tool settings. TODO: Save settings to disc for registered clients.
	// for (int i = MPT_FIRST; i <= MPT_LAST; ++i)
	//     buf_del(this.mplant_tool_bufs[i]); // FIXME: call me maybe

	if (this.mplant_cursorobject) {

	}

}
#endif
