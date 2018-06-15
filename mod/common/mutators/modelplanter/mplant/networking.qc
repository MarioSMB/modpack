REGISTER_NET_LINKED(ENT_CLIENT_MPLANTBLOCK)
REGISTER_NET_LINKED(ENT_CLIENT_MPLANTPINFO)

#ifdef SVQC
bool mplant_block_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_MPLANTBLOCK);
	WriteByte(MSG_ENTITY, sf);

	if (sf & MPSF_ORIGIN) {
		WriteVector(MSG_ENTITY, this.origin);
	}

	if (sf & MPSF_MODEL) {
		WriteString(MSG_ENTITY, this.model);
	}

	if (sf & MPSF_ANGLES) {
		WriteAngle(MSG_ENTITY, this.angles_x);
		WriteAngle(MSG_ENTITY, this.angles_y);
		WriteAngle(MSG_ENTITY, this.angles_z);
	}

	if (sf & MPSF_FLAGS) {
		WriteByte(MSG_ENTITY, this.mdlplant_object_flags);
	}

	if (sf & MPSF_SIZE) {
		WriteVector(MSG_ENTITY, this.mplant_org_mins);

		WriteVector(MSG_ENTITY, this.mplant_org_maxs);

		WriteVector(MSG_ENTITY, this.mins);

		WriteVector(MSG_ENTITY, this.maxs);
	}

	if (sf & MPSF_SCALE) {
		WriteCoord(MSG_ENTITY, this.scale);
	}
	return true;
}

bool mplant_player_info_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_MPLANTPINFO);
	WriteByte(MSG_ENTITY, sf);

	if (sf & MPPI_ENABLE)
		WriteByte(MSG_ENTITY, this.owner.mplant_active);

	if (sf & MPPI_TOOL) {
		WriteVector(MSG_ENTITY, this.owner.mplant_tool_multiplier);
		WriteString(MSG_ENTITY, this.owner.mplant_tool.mplant_tool_name);
		WriteByte(MSG_ENTITY, this.owner.mplant_tool.mplant_tool_index);
	}

	if (sf & MPPI_SNAP)
		WriteByte(MSG_ENTITY, this.owner.mplant_snaptions);

	//if (sf & MPPI_OBJECT)
	//    WriteByte(MSG_ENTITY, this.mplant_active);

	if (sf & MPPI_GRID)
		WriteCoord(MSG_ENTITY, this.owner.mplant_grid);

	return true;
}
#endif

#ifdef CSQC
NET_HANDLE(ENT_CLIENT_MPLANTPINFO, bool isnew)
{
	int sf = ReadByte();

	if (sf & MPPI_INIT)
		cl_mplant_player_info_init(this, isnew);

	if (sf & MPPI_ENABLE)
		this.mplant_active = ReadByte();

	if (sf & MPPI_TOOL) {
		this.mplant_tool_multiplier = ReadVector();
		if (this.mplant_tool_name)
			strunzone(this.mplant_tool_name);

		this.mplant_tool_name = strzone(ReadString());
		this.mplant_tool_index = ReadByte();
	}

	if (sf & MPPI_SNAP)
		this.mplant_snaptions = ReadByte();

	//if (sf & MPPI_OBJECT)
	//    WriteByte(MSG_ENTITY, this.mplant_active);

	if (sf & MPPI_GRID)
		this.mplant_grid = ReadCoord();

	return = true;
}

NET_HANDLE(ENT_CLIENT_MPLANTBLOCK, bool isnew)
{
	float sf = ReadByte();
	float _retransform = false;

	if (sf & MPSF_NEW) {
		this.entremove = mplant_block_remove;
		this.drawmask  = MASK_NORMAL;
		this.movetype  = MOVETYPE_NONE;
		this.draw      = mplant_block_draw;
	}

	if (sf & MPSF_ORIGIN) {
		this.origin = ReadVector();
		setorigin(this, this.origin);
		_retransform = true;
	}

	if (sf & MPSF_MODEL) {
		if(this.mdl) { strunzone(this.mdl); }
		this.mdl = strzone(ReadString());
		precache_model(this.mdl);
		_setmodel(this, this.mdl);
		this.solid     = SOLID_BSP;
		_retransform = true;
	}


	if (sf & MPSF_ANGLES) {
		this.angles_x = ReadAngle();
		this.angles_y = ReadAngle();
		this.angles_z = ReadAngle();
		_retransform = true;
	}

	if (sf & MPSF_FLAGS) {
		this.mdlplant_object_flags = ReadByte();
		if (this.mdlplant_object_flags & MPOF_SELECTED) {
			this.effects    = EF_FULLBRIGHT; // | EF_NODEPTHTEST;
			this.alpha      = 1;
			this.colormod   = '0.7 1.6 0.7';
			if(isnew) // if draw isn't set, we probably unset this before
			{
				IL_PUSH(g_drawables, this);
				IL_PUSH(g_drawables_2d, this);
			}
			this.draw = mplant_block_selected_draw;
			this.draw2d  = mplant_block_selected_draw2d;
		} else {
			this.effects    = 0;
			this.alpha      = 1;
			this.colormod   = '1 1 1';
			if(isnew) // if draw isn't set, we probably unset this before
				IL_PUSH(g_drawables, this);
			this.draw = mplant_block_draw;
			this.draw2d  = func_null;
		}
	}

	if (sf & MPSF_SIZE) {
		dprint("^1---------------^2Read size\n");
		this.mplant_org_mins = ReadVector();

		this.mplant_org_maxs = ReadVector();

		this.mins = ReadVector();

		this.maxs = ReadVector();
		setsize(this, this.mins, this.maxs);
		_retransform = true;
	}

	if (sf & MPSF_SCALE) {
		this.scale = ReadCoord();
		_retransform = true;
	}

	if (_retransform)
		cl_mplant_transform_update(this);

	return = true;
}
#endif
