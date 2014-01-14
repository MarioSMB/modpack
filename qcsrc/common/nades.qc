.float healer_lifetime;
.float healer_radius;

#ifdef SVQC
float healer_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_HEALING_ORB);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteByte(MSG_ENTITY, self.healer_lifetime);
		//WriteByte(MSG_ENTITY, self.ltime - time + 1);
		WriteShort(MSG_ENTITY, self.healer_radius);
		// round time delta to a 1/10th of a second
		WriteByte(MSG_ENTITY, (self.ltime - time)*10.0+0.5);
	}

	return TRUE;
}
#endif // SVQC

#ifdef CSQC
.float ltime;
void healer_draw()
{
	float dt = time - self.move_time;
	self.move_time = time;
	if(dt <= 0)
		return;

	self.alpha = (self.ltime - time) / self.healer_lifetime;
	self.scale = min((1 - self.alpha)*self.healer_lifetime*4,1)*self.healer_radius;

}

void healer_setup()
{
	setmodel(self, "models/ctf/shield.md3");

	setorigin(self, self.origin);
	
	float model_radius = self.maxs_x;
	vector size = '1 1 1' * self.healer_radius / 2;
	setsize(self,-size,size);
	self.healer_radius = self.healer_radius/model_radius*0.6;

	self.draw = healer_draw;
	self.health = 255;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.drawmask = MASK_NORMAL;
	self.scale = 0.01;
	self.avelocity = self.move_avelocity = '7 0 11';
	self.colormod = '1 0 0';
	self.renderflags |= RF_ADDITIVE;
}

void ent_healer()
{
	float sf = ReadByte();

	if(sf & TNSF_SETUP)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);

		self.healer_lifetime = ReadByte();
		self.healer_radius = ReadShort();
		self.ltime = time + ReadByte()/10.0;
		//self.ltime = time + self.healer_lifetime;

		healer_setup();
	}
}
#endif // CSQC