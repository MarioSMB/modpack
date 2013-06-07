string mid2info_model;
string mid2info_name;
vector mid2info_min;
vector mid2info_max;

float monster_precached[MONSTER_LAST];
void monster_mid2info(float _mid);

void monster_precache(float _mid)
{    
    monster_mid2info(_mid);
    if(monster_precached[_mid])
        return;

    switch(_mid)
    {
        case MONSTER_ZOMBIE:
		{
			precache_model(ZOMBIE_MODEL);
			break;
		}
		case MONSTER_BRUTE:
		{
			precache_model(BRUTE_MODEL);
			break;
		}
		case MONSTER_ANIMUS:
		{
			precache_model(ANIMUS_MODEL);
			break;
		}
		case MONSTER_SHAMBLER:
		{
			precache_model(SHAMBLER_MODEL);
			break;
		}
		case MONSTER_BRUISER:
		{
			precache_model(BRUISER_MODEL);
			break;
		}
		case MONSTER_WYVERN:
		{
			precache_model(WYVERN_MODEL);
			break;
		}
		case MONSTER_CERBERUS:
		{
			precache_model(CERBERUS_MODEL);
			break;
		}
		case MONSTER_SLIME:
		{
			precache_model(SLIME_MODEL);
			precache_sound("weapons/rocket_impact.wav");
			break;
		}
		case MONSTER_KNIGHT:
		{
			precache_model(KNIGHT_MODEL);
			break;
		}
		case MONSTER_STINGRAY:
		{
			precache_model(STINGRAY_MODEL);
			break;
		}
		case MONSTER_MAGE:
		{
			precache_model(MAGE_MODEL);
			break;
		}
		case MONSTER_SPIDER:
		{
			precache_model(SPIDER_MODEL);
			break;
		}
		case MONSTER_GRUNT:
		{
			precache_model(GRUNT_MODEL);
			precache_model("models/monsters/grunt_torso.md3");
			precache_model("models/monsters/grunt_legs.md3");
			precache_model("models/monsters/grunt_arm.md3");
			break;
		}
    }
	
    monster_precached[_mid] = TRUE;
}

void Monsters_Precache()
{
	float i;
	for(i = MONSTER_FIRST + 1; i < MONSTER_LAST; ++i)
		monster_precache(i);
}

void monster_mid2info(float _mid)
{
	switch(_mid)
	{
		case MONSTER_ZOMBIE:
		{
			mid2info_model = ZOMBIE_MODEL;
			mid2info_name = "Zombie";
			mid2info_min = ZOMBIE_MIN;
			mid2info_max = ZOMBIE_MAX;
			break;
		}
		case MONSTER_BRUTE:
		{
			mid2info_model = BRUTE_MODEL;
			mid2info_name = "Brute";
			mid2info_min = BRUTE_MIN;
			mid2info_max = BRUTE_MAX;
			break;
		}
		case MONSTER_ANIMUS:
		{
			mid2info_model = ANIMUS_MODEL;
			mid2info_name = "Animus";
			mid2info_min = ANIMUS_MIN;
			mid2info_max = ANIMUS_MAX;
			if(self) self.scale = 1.3;
			break;
		}
		case MONSTER_SHAMBLER:
		{
			mid2info_model = SHAMBLER_MODEL;
			mid2info_name = "Shambler";
			mid2info_min = SHAMBLER_MIN;
			mid2info_max = SHAMBLER_MAX;
			if(self) self.scale = 1.3;
			break;
		}
		case MONSTER_BRUISER:
		{
			mid2info_model = BRUISER_MODEL;
			mid2info_name = "Bruiser";
			mid2info_min = BRUISER_MIN;
			mid2info_max = BRUISER_MAX;
			if(self) self.scale = 1.3;
			break;
		}
		case MONSTER_WYVERN:
		{
			mid2info_model = WYVERN_MODEL;
			mid2info_name = "Wyvern";
			mid2info_min = WYVERN_MIN;
			mid2info_max = WYVERN_MAX;
			if(self) self.scale = 1.3;
			break;
		}
		case MONSTER_CERBERUS:
		{
			mid2info_model = CERBERUS_MODEL;
			mid2info_name = "Cerberus";
			mid2info_min = CERBERUS_MIN;
			mid2info_max = CERBERUS_MAX;
			break;
		}
		case MONSTER_SLIME:
		{
			mid2info_model = SLIME_MODEL;
			mid2info_name = "Slime";
			mid2info_min = SLIME_MIN;
			mid2info_max = SLIME_MAX;
			break;
		}
		case MONSTER_KNIGHT:
		{
			mid2info_model = KNIGHT_MODEL;
			mid2info_name = "Knight";
			mid2info_min = KNIGHT_MIN;
			mid2info_max = KNIGHT_MAX;
			if(self) self.scale = 1.3;
			break;
		}
		case MONSTER_STINGRAY:
		{
			mid2info_model = STINGRAY_MODEL;
			mid2info_name = "Stingray";
			mid2info_min = STINGRAY_MIN;
			mid2info_max = STINGRAY_MAX;
			if(self) self.scale = 1.3;
			break;
		}
		case MONSTER_MAGE:
		{
			mid2info_model = MAGE_MODEL;
			mid2info_name = "Mage";
			mid2info_min = MAGE_MIN;
			mid2info_max = MAGE_MAX;
			break;
		}
		case MONSTER_SPIDER:
		{
			mid2info_model = SPIDER_MODEL;
			mid2info_name = "Spider";
			mid2info_min = SPIDER_MIN;
			mid2info_max = SPIDER_MAX;
			break;
		}
		case MONSTER_GRUNT:
		{
			mid2info_model = GRUNT_MODEL;
			mid2info_name = "Grun";
			mid2info_min = GRUNT_MIN;
			mid2info_max = GRUNT_MAX;
			break;
		}
		default:
		{
			dprint("WARNING: Unknown monster in CSQC\n");
			break;
		}
	}
}

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
	if(self.monsterid == MONSTER_SPIDER)
		self.angles += '180 0 0';
	if(self.monsterid == MONSTER_GRUNT)
		setmodel(self, "null");
		
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
	monster_mid2info(self.monsterid);
	self.netname = mid2info_name;

	setorigin(self, self.origin);
	setmodel(self, mid2info_model);
	setsize(self, mid2info_min, mid2info_max);
	
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
		
		monster_precache(self.monsterid);
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
