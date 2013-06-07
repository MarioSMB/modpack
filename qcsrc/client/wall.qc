.float lip;
.float bgmscriptangular;
.float lodmodelindex0, lodmodelindex1, lodmodelindex2;
.float loddistance1, loddistance2;
.vector saved;

void Ent_Wall_Draw()
{
	float f;
	var .vector fld;

	if(self.bgmscriptangular)
		fld = angles;
	else
		fld = origin;
	self.fld = self.saved;

	if(self.lodmodelindex1)
	{
		if(autocvar_cl_modeldetailreduction <= 0)
		{
			if(self.lodmodelindex2 && autocvar_cl_modeldetailreduction <= -2)
				self.modelindex = self.lodmodelindex2;
			else if(autocvar_cl_modeldetailreduction <= -1)
				self.modelindex = self.lodmodelindex1;
			else
				self.modelindex = self.lodmodelindex0;
		}
		else
		{
			float distance = vlen(NearestPointOnBox(self, view_origin) - view_origin);
			f = (distance * current_viewzoom + 100.0) * autocvar_cl_modeldetailreduction;
			f *= 1.0 / bound(0.01, view_quality, 1);
			if(self.lodmodelindex2 && f > self.loddistance2)
				self.modelindex = self.lodmodelindex2;
			else if(f > self.loddistance1)
				self.modelindex = self.lodmodelindex1;
			else
				self.modelindex = self.lodmodelindex0;
		}
	}

	InterpolateOrigin_Do();

	self.saved = self.fld;

	f = BGMScript(self);
	if(f >= 0)
	{
		if(self.lip < 0) // < 0: alpha goes from 1 to 1-|lip| when toggled (toggling subtracts lip)
			self.alpha = 1 + self.lip * f;
		else // > 0: alpha goes from 1-|lip| to 1 when toggled (toggling adds lip)
			self.alpha = 1 - self.lip * (1 - f);
		self.fld = self.fld + self.movedir * f;
	}
	else
		self.alpha = 1;

	if(self.alpha >= ALPHA_MIN_VISIBLE)
		self.drawmask = MASK_NORMAL;
	else
		self.drawmask = 0;
}

void Ent_Wall_Remove()
{
	if(self.bgmscript)
		strunzone(self.bgmscript);
	self.bgmscript = string_null;
}

void Ent_Wall()
{
	float f;
	var .vector fld;

	InterpolateOrigin_Undo();
	self.iflags = IFLAG_ANGLES | IFLAG_ORIGIN;

	if(self.bgmscriptangular)
		fld = angles;
	else
		fld = origin;
	self.fld = self.saved;

	f = ReadByte();

	if(f & 1)
	{
		if(f & 0x40)
			self.colormap = ReadShort();
		else
			self.colormap = 0;
	}

	if(f & 2)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}

	if(f & 4)
	{
		if(f & 0x10)
		{
			self.angles_x = ReadAngle();
			self.angles_y = ReadAngle();
			self.angles_z = ReadAngle();
		}
		else
			self.angles = '0 0 0';
	}

	if(f & 8)
	{
		if(f & 0x80)
		{
			self.lodmodelindex0 = ReadShort();
			self.loddistance1 = ReadShort();
			self.lodmodelindex1 = ReadShort();
			self.loddistance2 = ReadShort();
			self.lodmodelindex2 = ReadShort();
		}
		else
		{
			self.modelindex = ReadShort();
			self.loddistance1 = 0;
			self.loddistance2 = 0;
		}
		self.solid = ReadByte();
		self.scale = ReadShort() / 256.0;
		if(f & 0x20)
		{
			self.mins_x = ReadCoord();
			self.mins_y = ReadCoord();
			self.mins_z = ReadCoord();
			self.maxs_x = ReadCoord();
			self.maxs_y = ReadCoord();
			self.maxs_z = ReadCoord();
		}
		else
			self.mins = self.maxs = '0 0 0';
		setsize(self, self.mins, self.maxs);

		if(self.bgmscript)
			strunzone(self.bgmscript);
		self.bgmscript = ReadString();
		if(substring(self.bgmscript, 0, 1) == "<")
		{
			self.bgmscript = strzone(substring(self.bgmscript, 1, -1));
			self.bgmscriptangular = 1;
		}
		else
		{
			self.bgmscript = strzone(self.bgmscript);
			self.bgmscriptangular = 0;
		}
		if(self.bgmscript != "")
		{
			self.bgmscriptattack = ReadByte() / 64.0;
			self.bgmscriptdecay = ReadByte() / 64.0;
			self.bgmscriptsustain = ReadByte() / 255.0;
			self.bgmscriptrelease = ReadByte() / 64.0;
			self.movedir_x = ReadCoord();
			self.movedir_y = ReadCoord();
			self.movedir_z = ReadCoord();
			self.lip = ReadByte() / 255.0;
		}
		BGMScript_InitEntity(self);
	}

	InterpolateOrigin_Note();

	self.saved = self.fld;

	self.entremove = Ent_Wall_Remove;
	self.draw = Ent_Wall_Draw;
}
