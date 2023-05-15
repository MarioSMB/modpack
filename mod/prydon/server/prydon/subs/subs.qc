
void() SUB_Null = {};
void() SUB_Null2 = {};

void() SUB_Remove = {remove(self);};

void(string modelname) Precache_Set =
{
	precache_model(modelname);
	setmodel(self, modelname);
};

void(void() func, entity e) call =
{
	local entity oself;
	oself = self;
	self = e;
	func();
	self = oself;
};

float (entity e1, entity e2) friendly =
{
	if (e1.team & 256 & e2.team)
		return FALSE;
	if ((e1.team & 224) == (e2.team & 224))
		if ((e1.team & 31) != (e2.team & 31))
			return FALSE;
	return TRUE;
};


void(float a, float z) CycleFrames = 
{
	self.frame = self.frame + 1;
	if (self.frame < a || self.frame > z)
		self.frame = a;
};

float(entity targ) infront =
{
	local vector	vec;
	local float		dot;
	
	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;
	
	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
};


float(entity e) visible =
{
	traceline(self.origin, (e.absmin + e.absmax) * 0.5, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	else if (trace_ent == e)
		return TRUE;
	else
		return FALSE;
};
void() fix_velocity = { self.velocity = self.dest1; self.think = SUB_Remove; self.nextthink = self.ltime; };

entity(float ofs, float sped, float range, string mdel) launch_projectile =
{
	local entity e;
	makevectors(self.angles);
	e = spawn();
	e.owner = self;
	e.velocity = normalize(self.enemy.origin - self.origin) * sped;

	e.angles = vectoangles(e.velocity);
	if (ofs)
	{
		e.angles_y = e.angles_y + ofs;
		makevectors(e.angles_x * '-1 0 0' + e.angles_y * '0 1 0'); // LordHavoc: 20040420 fixed inverted pitch problem
		e.velocity = v_forward * sped;
	}
	e.dest1 = e.velocity;
	e.movetype = MOVETYPE_FLY;
	e.solid = SOLID_BBOX;
	setmodel(e, mdel);
	setorigin(e, self.origin + v_up * 16 + v_forward * 8);
	e.enemy = self;
	e.think = SUB_Remove;
	e.nextthink = time + range / sped;
	setsize(e, '0 0 0', '0 0 0');
	return e;

};



entity() find_spot =
{
	local vector org;
	local float dist, dir, runaway;
	local entity e, oself;
	
	oself = self;
	self = spawn();
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.movetype = MOVETYPE_STEP;
	dist = 34;
	makevectors(self.angles);
	if (oself.enemy)
		org = oself.enemy.origin;
	else
		org = oself.origin;
	org = org + '0 0 48';
	//self.flags = FL_FLY;
	self.solid = SOLID_BBOX;
	do 
	{
		if (dir == 0)
			setorigin(self, org + v_forward * dist);
		else if (dir == 1)
			setorigin(self, org + v_forward * -1 * dist);
		else if (dir == 2)
			setorigin(self, org + v_right * dist);
		else if (dir == 3)
		{
			setorigin(self, org + v_right * -1 * dist);
			dir = -1;
			dist = dist + 8;
		}
		droptofloor();
		dir = dir + 1;
		if (self != findradius(self.origin, 32))
			continue;
		traceline(org, self.origin, FALSE, self);
		if (trace_fraction != 1)
			continue;
		
		if (runaway > 80)
		{
			self.flags = 0;
			e = self;
			self = oself;
			return e;
		}
		runaway = runaway + 1;			
	}
	while(!walkmove(0, 0));
	self.flags = 0;
	e = self;
	self = oself;
	return e;
};

void(entity e, string snd) sound2 =
{
	/*
	stuffcmd(e, "play ");
	stuffcmd(e, snd);
	stuffcmd(e, "\n");
	*/
	if (e.owner)
		e = e.owner;
		
	e.voice = snd; // hold it off
};

void(string msc) setdmusic =
{

	if (!music)
		return;
	if (music == msc)
		return;
		
	music = msc;
	sound(world, CHAN_VOICE, music, 1, ATTN_NONE);
};
