#ifdef CSQC
float generator_precached;
.float count;

vector randompos(vector m1, vector m2)
{
    vector v;
    m2 = m2 - m1;
    v_x = m2_x * random() + m1_x;
    v_y = m2_y * random() + m1_y;
    v_z = m2_z * random() + m1_z;
    return  v;
}

void generator_precache()
{
	if(generator_precached)
		return; // already precached
		
	precache_model("models/onslaught/generator.md3");
	precache_model("models/onslaught/generator_dead.md3");
	precache_model("models/onslaught/generator_dmg1.md3");
	precache_model("models/onslaught/generator_dmg2.md3");
	precache_model("models/onslaught/generator_dmg3.md3");
	precache_model("models/onslaught/generator_dmg4.md3");
	precache_model("models/onslaught/generator_dmg5.md3");
	precache_model("models/onslaught/generator_dmg6.md3");
	precache_model("models/onslaught/generator_dmg7.md3");
	precache_model("models/onslaught/generator_dmg8.md3");
	precache_model("models/onslaught/generator_dmg9.md3");
	precache_model("models/onslaught/generator_dead.md3");
	
	precache_model("models/onslaught/ons_ray.md3");
	precache_sound("onslaught/shockwave.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("weapons/rocket_impact.wav");
	
	precache_model("models/onslaught/gen_gib1.md3");
	precache_model("models/onslaught/gen_gib2.md3");
	precache_model("models/onslaught/gen_gib3.md3");
	
	generator_precached = TRUE;
}

void ons_gib_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
	self.velocity = self.velocity + vforce;
}

.float giblifetime;

void gib_draw_noburn()
{
	if(time >= self.giblifetime)
		remove(self);
}

void gib_draw()
{
	if(time >= self.move_time)
		return;

	self.move_time = time + 0.05;

	if(time > self.giblifetime)
	{
		remove(self);
		return;
	}
	
	self.alpha -= 0.05;
	
	if(self.alpha < 0.1)
	{
		remove(self);
		return;
	}

	if(random()<0.6)
		pointparticles(particleeffectnum("onslaught_generator_gib_flame"), self.origin, '0 0 0', 1);
}

void ons_throwgib(vector v_from, vector v_to, string smodel, float f_lifetime, float b_burn)
{
	entity gib;

	gib = spawn();

	setmodel(gib, smodel);
	setorigin(gib, v_from);
	gib.solid = SOLID_CORPSE;
	gib.move_movetype = MOVETYPE_BOUNCE;
	gib.movetype = MOVETYPE_BOUNCE;
	gib.health = 255;
	gib.move_velocity = v_to;
	gib.move_origin = v_from;
	gib.velocity = v_to;
	gib.alpha = 1;
	gib.move_time = time;
	gib.drawmask = MASK_NORMAL;
	gib.giblifetime	= time + f_lifetime;
	
	if(b_burn)
		gib.draw = gib_draw;
	else
		gib.draw = gib_draw_noburn;	
}

void onslaught_generator_ray_think()
{
	self.nextthink = time + 0.05;
	if(self.count > 10)
	{
		self.think = SUB_Remove;
		return;
	}

	if(self.count > 5)
		self.alpha -= 0.1;
	else
		self.alpha += 0.1;

	self.scale += 0.2;
	self.count +=1;
}

void onslaught_generator_ray_spawn(vector org)
{
	entity e;
	e = spawn();
	setmodel(e, "models/onslaught/ons_ray.md3");
	setorigin(e, org);
	e.angles = randomvec() * 360;
	e.alpha = 0;
	e.scale = random() * 5 + 8;
	e.think = onslaught_generator_ray_think;
	e.nextthink = time + 0.05;
}

void generator_draw()
{
	if(self.health > 0)
		return;
	  
	if(time < self.move_time)
		return;
	if(self.count <= 0)
		return;
    
    vector org;
	float i;

	// White shockwave
	if(self.count==40||self.count==20)
	{
		sound(self, CH_TRIGGER, "onslaught/shockwave.wav", VOL_BASE, ATTEN_NORM);
		pointparticles(particleeffectnum("electro_combo"), self.origin, '0 0 0', 6);
	}

	// Throw some gibs
	if(random() < 0.3)
	{
		i = random();
		if(i < 0.3)
			ons_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 11 + '0 0 20', "models/onslaught/gen_gib1.md3", 6, TRUE);
		else if(i > 0.7)
			ons_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 12 + '0 0 20', "models/onslaught/gen_gib2.md3", 6, TRUE);
		else
			ons_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 13 + '0 0 20', "models/onslaught/gen_gib3.md3", 6, TRUE);
	}

	// Spawn fire balls
	for(i=0;i < 10;++i)
	{
		org = self.origin + randompos('-30 -30 -30' * i + '0 0 -20', '30 30 30' * i + '0 0 20');
		pointparticles(particleeffectnum("onslaught_generator_gib_explode"), org, '0 0 0', 1);
	}

	// Short explosion sound + small explosion
	if(random() < 0.25)
	{
		te_explosion(self.origin);
		sound(self, CH_TRIGGER, "weapons/grenade_impact.wav", VOL_BASE, ATTEN_NORM);
	}

	// Particles
	org = self.origin + randompos(self.mins + '8 8 8', self.maxs + '-8 -8 -8');
	pointparticles(particleeffectnum("onslaught_generator_smallexplosion"), org, '0 0 0', 1);

	// rays
	if(random() > 0.25 )
	{
		onslaught_generator_ray_spawn(self.origin);
	}

	// Final explosion
	if(self.count==1)
	{
		org = self.origin;
		te_explosion(org);
		pointparticles(particleeffectnum("onslaught_generator_finalexplosion"), org, '0 0 0', 1);
		sound(self, CH_TRIGGER, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	}
	
	self.move_time = time + 0.05;

	self.count -= 1;
}

.float max_health;
void generator_damage(float hp)
{
	if(hp <= 0)
		setmodel(self, "models/onslaught/generator_dead.md3");
	else if(hp < self.max_health * 0.10)
		setmodel(self, "models/onslaught/generator_dmg9.md3");
	else if(hp < self.max_health * 0.20)
		setmodel(self, "models/onslaught/generator_dmg8.md3");
	else if(hp < self.max_health * 0.30)
		setmodel(self, "models/onslaught/generator_dmg7.md3");
	else if(hp < self.max_health * 0.40)
		setmodel(self, "models/onslaught/generator_dmg6.md3");
	else if(hp < self.max_health * 0.50)
		setmodel(self, "models/onslaught/generator_dmg5.md3");
	else if(hp < self.max_health * 0.60)
		setmodel(self, "models/onslaught/generator_dmg4.md3");
	else if(hp < self.max_health * 0.70)
		setmodel(self, "models/onslaught/generator_dmg3.md3");
	else if(hp < self.max_health * 0.80)
		setmodel(self, "models/onslaught/generator_dmg2.md3");
	else if(hp < self.max_health * 0.90)
		setmodel(self, "models/onslaught/generator_dmg1.md3");
	else if(hp <= self.max_health || hp >= self.max_health)
		setmodel(self, "models/onslaught/generator.md3");
		
	setsize(self, GENERATOR_MIN, GENERATOR_MAX);
}

void generator_construct()
{
	self.netname = "Generator";

	setorigin(self, self.origin);
	setmodel(self, "models/onslaught/generator.md3");
	setsize(self, GENERATOR_MIN, GENERATOR_MAX);
	
	self.move_movetype	= MOVETYPE_NOCLIP;
	self.solid			= SOLID_BBOX;
	self.movetype		= MOVETYPE_NOCLIP; 
	self.move_origin	= self.origin;
	self.move_time		= time;
	self.drawmask		= MASK_NORMAL;  
	self.alpha			= 1;
	self.draw			= generator_draw;
}

.vector glowmod;
void generator_changeteam()
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

void ent_generator()
{
	float sf;
	sf = ReadByte();

	if(sf & GSF_SETUP)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
		
		self.health = ReadByte();
		self.max_health = ReadByte();
		self.count = ReadByte();
		self.team = ReadByte();
		
		if(!self.count)
			self.count = 40;
		
		generator_changeteam();
		generator_precache();
		generator_construct();
	}

	if(sf & GSF_STATUS)
	{
		float _tmp;
		_tmp = ReadByte();
		if(_tmp != self.team)
		{			
			self.team = _tmp;				
			generator_changeteam();
		}
		
		_tmp = ReadByte();
		
		if(_tmp != self.health)
			generator_damage(_tmp);

		self.health = _tmp;
	}
}
#endif // CSQC

#ifdef SVQC
float generator_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_GENERATOR);    
	WriteByte(MSG_ENTITY, sf);
	if(sf & GSF_SETUP)
	{
	    WriteCoord(MSG_ENTITY, self.origin_x);
	    WriteCoord(MSG_ENTITY, self.origin_y);
	    WriteCoord(MSG_ENTITY, self.origin_z);
		
		WriteByte(MSG_ENTITY, self.health);
		WriteByte(MSG_ENTITY, self.max_health);
		WriteByte(MSG_ENTITY, self.count);
		WriteByte(MSG_ENTITY, self.team);
    }
    
    if(sf & GSF_STATUS)
    {
		WriteByte(MSG_ENTITY, self.team);
	
        if(self.health <= 0)
            WriteByte(MSG_ENTITY, 0);
        else
            WriteByte(MSG_ENTITY, ceil((self.health / self.max_health) * 255));
    }
    
	return TRUE;
}

void generator_link(void() spawnproc)
{
    Net_LinkEntity(self, TRUE, 0, generator_send);
    self.think      = spawnproc;
    self.nextthink  = time;
}
#endif // SVQC
