

void() h_camera =
{
	local vector view, org;
	local float dist, len, len2;
	if (self.button4)
		self.rotang_y = self.rotang_y + 120 * frametime;
	if (self.button5)
		self.rotang_y = self.rotang_y - 120 * frametime;
	if (self.button6)
	{
		self.rotang_z = self.rotang_z + 80 * frametime;
		if (self.rotang_z > 256)
			self.rotang_z = 256;
	}
	if (self.button7)
	{
		self.rotang_z = self.rotang_z - 80 * frametime;
		if (self.rotang_z < 64)
			self.rotang_z = 64;
	}
	if (!self.camera)
	{	
		self.camera = spawn();
		self.camera.drawonlytoclient = self;
		self.drawonlytoclient = self;
		self.camera.solid = SOLID_NOT;
		self.camera.movetype = MOVETYPE_NOCLIP;
		setmodel(self.camera, "progs/null.spr");
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self.camera);
	}
	if (self.camera.enemy)
	{
		org = self.camera.enemy.origin + '0 64 0';
		view_y = 0;
		self.rotang_y = view_y;
		view_x = 0;	
	}
	else if (self.camera.goalentity)
	{
		org = self.camera.goalentity.origin;
		view = vectoangles(self.player.origin - org);
		self.rotang_y = view_y;
		view_x = view_x * -1;
	}
	else
	{
		view = self.rotang;
		view_z = 0;
		dist = self.rotang_z;
	}
	makevectors(view);
	if (self.camera.enemy)
	{
		setorigin(self, org);
		setorigin(self.camera, org);
		
	}
	else if (self.camera.goalentity)
	{
		setorigin(self.camera, org);
		setorigin(self, org);
	}	
	else if (self.player)
	{
		
		if (self.ui_panels)
			org = self.player.origin + v_forward * (0 - dist) - v_right * (dist/2);
		else
			org = self.player.origin + v_forward * (0 - dist);
		if (pointcontents(org) != CONTENT_EMPTY)
		{
			traceline(self.player.origin, org, TRUE, self);
			org = trace_endpos + v_forward + trace_plane_normal;
		}
		else
		{
			dist = vlen(org - self.player.origin);
			traceline(org, self.player.origin, TRUE, self);
			if (trace_fraction!= 1)
			{
				len = trace_fraction * dist;
				traceline(self.player.origin, org, TRUE, self);
				len2 = trace_fraction * dist;
				
				if (len < 64)
				{
					if (len2 >= 64)
						org = trace_endpos + v_forward + trace_plane_normal;
				}
			}
		}
		setorigin(self.camera, org);
		setorigin(self, org);
	}
	

	self.testorg = self.origin;
	msg_entity = self;
	WriteByte (MSG_ONE,10);
	WriteAngle (MSG_ONE,view_x);
	WriteAngle (MSG_ONE,view_y);
	WriteAngle (MSG_ONE,0);
	self.camera.angles = view;
	self.camera.angles_z = 0;
};