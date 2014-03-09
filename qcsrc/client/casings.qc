.float silent;

void Casing_Delete()
{
    remove(self);
}

void Casing_Draw()
{
	if(self.move_flags & FL_ONGROUND)
	{
		self.move_angles_x = 0;
		self.move_angles_z = 0;
		self.flags &= ~FL_ONGROUND;
	}

	Movetype_Physics_MatchTicrate(autocvar_cl_casings_ticrate, autocvar_cl_casings_sloppy);
	if(wasfreed(self))
		return; // deleted by touch function

	self.renderflags = 0;
	self.alpha = bound(0, self.cnt - time, 1);

	if(self.alpha < ALPHA_MIN_VISIBLE)
	{
		Casing_Delete();
		self.drawmask = 0;
	}
}

void Casing_Touch()
{
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		Casing_Delete();
		return;
	}

	if(!self.silent)
	if(!trace_ent || trace_ent.solid == SOLID_BSP)
	{
		if(vlen(self.velocity) > 50)
		{
			if(time >= self.nextthink)
			{
				string s;
				float f;

				f = floor(prandom() * 3) + 1;
				switch(self.state)
				{
					case 1:
						s = strcat("weapons/casings", ftos(f), ".wav");
						break;
					default:
						s = strcat("weapons/brass", ftos(f), ".wav");
						break;
				}

				sound (self, CH_SHOTS, s, VOL_BASE, ATTEN_LARGE);
			}
		}
	}

	self.nextthink = time + 0.2;
}

void Casing_Damage(float thisdmg, float hittype, vector org, vector thisforce)
{
	if(thisforce_z < 0)
		thisforce_z = 0;
	self.move_velocity = self.move_velocity + thisforce + '0 0 100';
	self.move_flags &= ~FL_ONGROUND;
}

void Ent_Casing(float isNew)
{
	entity casing;

	casing = RubbleNew("casing");
	casing.state = ReadByte();
	casing.silent = (casing.state & 0x80);
	casing.state = (casing.state & 0x7F);
	casing.origin_x = ReadCoord();
	casing.origin_y = ReadCoord();
	casing.origin_z = ReadCoord();
	setorigin(casing, casing.origin);
	casing.velocity = decompressShortVector(ReadShort());
	casing.angles_x = ReadByte() * 360 / 256;
	casing.angles_y = ReadByte() * 360 / 256;
	casing.angles_z = ReadByte() * 360 / 256;
	casing.drawmask = MASK_NORMAL;

	if(autocvar_cl_casings && isNew) {
		casing.draw = Casing_Draw;
		casing.move_origin = casing.origin;
		casing.move_velocity = casing.velocity + 2 * prandomvec();
		casing.move_angles = casing.angles;
		casing.move_avelocity = '0 250 0' + 100 * prandomvec();
		casing.move_movetype = MOVETYPE_BOUNCE;
		casing.move_touch = Casing_Touch;
		casing.move_time = time;
		casing.event_damage = Casing_Damage;
		casing.solid = SOLID_TRIGGER;

		switch(casing.state)
		{
			case 1:
				setmodel(casing, "models/casing_shell.mdl");
				casing.cnt = time + autocvar_cl_casings_shell_time;
				break;
			default:
				setmodel(casing, "models/casing_bronze.iqm");
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
		}

		setsize(casing, '0 0 -1', '0 0 -1');

		RubbleLimit("casing", autocvar_cl_casings_maxcount, Casing_Delete);
	}
	else
	{
		entity oldself = self;
		self = casing;
		Casing_Delete(); // yes, this IS stupid, but I don't need to duplicate all the read* stuff then
		self = oldself;
	}
}

void Casings_Precache()
{
	precache_model("models/casing_shell.mdl");
	precache_model("models/casing_bronze.iqm");
	precache_sound("weapons/brass1.wav");
	precache_sound("weapons/brass2.wav");
	precache_sound("weapons/brass3.wav");
	precache_sound("weapons/casings1.wav");
	precache_sound("weapons/casings2.wav");
	precache_sound("weapons/casings3.wav");
}
