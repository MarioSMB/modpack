float cpicon_precached;
.float count;
.float pain_finished;

.float iscaptured;

.vector cp_origin, cp_bob_origin;
.float cp_bob_spd;

.vector cp_bob_dmg;

.vector punchangle;

.float max_health;

.entity icon_realmodel;

void cpicon_precache()
{
	if(cpicon_precached)
		return; // already precached

	precache_model("models/onslaught/controlpoint_icon_dmg3.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg2.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg1.md3");
	precache_model("models/onslaught/controlpoint_icon.md3");

	cpicon_precached = TRUE;
}

void cpicon_draw()
{
	if(time < self.move_time) { return; }

	if(self.cp_bob_dmg_z > 0)
		self.cp_bob_dmg_z = self.cp_bob_dmg_z - 3 * frametime;
	else
		self.cp_bob_dmg_z = 0;
	self.cp_bob_origin_z = 4 * PI * (1 - cos(self.cp_bob_spd));
	self.cp_bob_spd = self.cp_bob_spd + 1.875 * frametime;
	self.colormod = '1 1 1' * (2 - bound(0, (self.pain_finished - time) / 10, 1));
	
	if(!self.iscaptured) self.alpha = self.health / self.max_health;
	
	if(self.iscaptured)
	{
		if (self.punchangle_x > 0)
		{
			self.punchangle_x = self.punchangle_x - 60 * frametime;
			if (self.punchangle_x < 0)
				self.punchangle_x = 0;
		}
		else if (self.punchangle_x < 0)
		{
			self.punchangle_x = self.punchangle_x + 60 * frametime;
			if (self.punchangle_x > 0)
				self.punchangle_x = 0;
		}

		if (self.punchangle_y > 0)
		{
			self.punchangle_y = self.punchangle_y - 60 * frametime;
			if (self.punchangle_y < 0)
				self.punchangle_y = 0;
		}
		else if (self.punchangle_y < 0)
		{
			self.punchangle_y = self.punchangle_y + 60 * frametime;
			if (self.punchangle_y > 0)
				self.punchangle_y = 0;
		}

		if (self.punchangle_z > 0)
		{
			self.punchangle_z = self.punchangle_z - 60 * frametime;
			if (self.punchangle_z < 0)
				self.punchangle_z = 0;
		}
		else if (self.punchangle_z < 0)
		{
			self.punchangle_z = self.punchangle_z + 60 * frametime;
			if (self.punchangle_z > 0)
				self.punchangle_z = 0;
		}

		self.angles_x = self.punchangle_x;
		self.angles_y = self.punchangle_y + self.move_angles_y;
		self.angles_z = self.punchangle_z;
		self.move_angles_y = self.move_angles_y + 45 * frametime;
	}
	
	setorigin(self, self.cp_origin + self.cp_bob_origin + self.cp_bob_dmg);
}

void cpicon_damage(float hp)
{
	if(!self.iscaptured) { return; }

	if(hp < self.max_health * 0.25)
		setmodel(self, "models/onslaught/controlpoint_icon_dmg3.md3");
	else if(hp < self.max_health * 0.50)
		setmodel(self, "models/onslaught/controlpoint_icon_dmg2.md3");
	else if(hp < self.max_health * 0.75)
		setmodel(self, "models/onslaught/controlpoint_icon_dmg1.md3");
	else if(hp <= self.max_health || hp >= self.max_health)
		setmodel(self, "models/onslaught/controlpoint_icon.md3");
		
	self.punchangle = (2 * randomvec() - '1 1 1') * 45;

	self.cp_bob_dmg_z = (2 * random() - 1) * 15;
	self.pain_finished = time + 1;
	self.colormod = '2 2 2';

	setsize(self, CPICON_MIN, CPICON_MAX);
}

void cpicon_construct()
{
	self.netname = "Control Point Icon";

	setmodel(self, "models/onslaught/controlpoint_icon.md3");
	setsize(self, CPICON_MIN, CPICON_MAX);
	
	if(self.icon_realmodel == world)
	{
		self.icon_realmodel = spawn();
		setmodel(self.icon_realmodel, "null");
		setorigin(self.icon_realmodel, self.origin);
		setsize(self.icon_realmodel, CPICON_MIN, CPICON_MAX);
		self.icon_realmodel.movetype = MOVETYPE_NOCLIP;
		self.icon_realmodel.solid = SOLID_CORPSE;
		self.icon_realmodel.move_origin = self.icon_realmodel.origin;
	}
	
	if(self.iscaptured) { self.icon_realmodel.solid = SOLID_CORPSE; }

	self.move_movetype	= MOVETYPE_NOCLIP;
	self.solid			= SOLID_NOT;
	self.movetype		= MOVETYPE_NOCLIP;
	self.move_origin	= self.origin;
	self.move_time		= time;
	self.drawmask		= MASK_NORMAL;
	self.alpha			= 1;
	self.draw			= cpicon_draw;
	self.cp_origin		= self.origin;
	self.cp_bob_origin 	= '0 0 0.1';
	self.cp_bob_spd 	= 0;
}

.vector glowmod;
void cpicon_changeteam()
{
	if(self.team)
	{
		self.glowmod = Team_ColorRGB(self.team - 1);
		self.teamradar_color = Team_ColorRGB(self.team - 1);
		self.colormap = 1024 + (self.team - 1) * 17;
	}
	else
	{
		self.colormap = 1024;
		self.glowmod = '1 1 0';
		self.teamradar_color = '1 1 0';
	}
}

void ent_cpicon()
{
	float sf;
	sf = ReadByte();

	if(sf & CPSF_SETUP)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);

		self.health = ReadByte();
		self.max_health = ReadByte();
		self.count = ReadByte();
		self.team = ReadByte();
		self.iscaptured = ReadByte();

		if(!self.count)
			self.count = (self.health - self.max_health) * frametime;

		cpicon_changeteam();
		cpicon_precache();
		cpicon_construct();
	}

	if(sf & CPSF_STATUS)
	{
		float _tmp;
		_tmp = ReadByte();
		if(_tmp != self.team)
		{
			self.team = _tmp;
			cpicon_changeteam();
		}

		_tmp = ReadByte();

		if(_tmp != self.health)
			cpicon_damage(_tmp);

		self.health = _tmp;
	}
}
