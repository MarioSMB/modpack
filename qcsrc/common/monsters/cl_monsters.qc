// =========================
//  CSQC Monster Properties
// =========================


.vector glowmod;
void monster_changeteam()
{
	self.glowmod = Team_ColorRGB(self.team - 1);
	self.teamradar_color = Team_ColorRGB(self.team - 1);
	
	if(self.team)
		self.colormap = 1024 + (self.team - 1) * 17;
	else
		self.colormap = 1024;
}

void monster_die()
{
	MON_ACTION(self.monsterid, MR_DEATH);
		
	self.solid = SOLID_CORPSE;
}

void monster_draw()
{        
	float dt;
            
	dt = time - self.move_time;
	self.move_time = time;
	if(dt <= 0)
		return;
    
	fixedmakevectors(self.angles);
	//movelib_groundalign4point(50, 25, 0.25, 45);
	setorigin(self, self.origin + self.velocity * dt);
	self.angles_y = self.move_angles_y;
}

void monster_construct()
{
	vector min_s, max_s;
	entity mon = get_monsterinfo(self.monsterid);
	
	min_s = mon.mins;
	max_s = mon.maxs;
	
	if(mon.spawnflags & MONSTER_SIZE_BROKEN)
		self.scale = 1.3;
	
	self.netname = M_NAME(self.monsterid);

	setorigin(self, self.origin);
	setmodel(self, mon.model);
	setsize(self, min_s, max_s);
	
	self.move_movetype	= MOVETYPE_BOUNCE;
	self.health			= 255;
	self.solid			= SOLID_BBOX;
	self.movetype		= MOVETYPE_BOUNCE; 
	self.move_origin	= self.origin;
	self.move_time		= time;
	self.drawmask		= MASK_NORMAL;  
	self.alpha			= 1;
	self.draw			= monster_draw;
}

void ent_monster()
{
	float sf;
	sf = ReadByte();

	if(sf & MSF_SETUP)
	{
		self.monsterid = ReadByte();
				
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
		
		self.angles_x = ReadAngle();
		self.angles_y = ReadAngle();
		
		self.skin = ReadByte();
		self.team = ReadByte();
		
		monster_construct();
		monster_changeteam();
	}
	
	if(sf & MSF_ANG)
	{
		self.move_angles_x = ReadShort();
		self.move_angles_y = ReadShort();
		self.angles = self.move_angles;
	}
	
	if(sf & MSF_MOVE)
	{
		self.origin_x = ReadShort();
		self.origin_y = ReadShort();
		self.origin_z = ReadShort();
		setorigin(self, self.origin);
		
		self.velocity_x = ReadShort();
		self.velocity_y = ReadShort();
		self.velocity_z = ReadShort();
		
		self.move_angles_y = ReadShort();
			
		self.move_time	 = time;
		self.move_velocity = self.velocity;
		self.move_origin   = self.origin;
	}
	
	if(sf & MSF_ANIM)
	{
		self.frame1time = ReadCoord();
		self.frame	  = ReadByte();
	}

	if(sf & MSF_STATUS)
	{
		self.skin = ReadByte();
	
		float _tmp;
		_tmp = ReadByte();
		if(_tmp != self.team)
		{			
			self.team = _tmp;				
			monster_changeteam();
		}
		
		_tmp = ReadByte();
		if(_tmp == 4) // respawning
			setmodel(self, "null");
		
		_tmp = ReadByte();
		
		if(_tmp == 0 && self.health != 0)
			monster_die();

		self.health = _tmp;
	}
}
