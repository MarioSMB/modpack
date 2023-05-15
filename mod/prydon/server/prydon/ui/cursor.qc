float CAMERA_SCALE = 0.5; // rotation scale down
float() cursorframe =
{
	local float s;
	
	s = self.spell & 63;
	
	if (!s)
	{
		if (friendly(self.player, self.sbarsub))
			return 16;
		if (self.altaction == SP_FIGHT_MELEE)
			return 17; // melee frame
		else if (self.altaction == SP_FIGHT_BOW)
			return 18;
		else if (self.altaction == SP_FIGHT_CBOW)
			return 18;
		else if (self.altaction && self.altaction < 16)
			return self.altaction - 1;
		else
			return 17; // generic I guess
		// TODO: Make a THROW frame
	}
	if (s < 16)
		return s - 1;
	else if (s >= SP_SPRINT && s <= SP_IDENTIFY)
		return s - SP_SPRINT + 19;	
};

void() h_cursor =
{
	local vector ang, view;
	local float len;
	//PRYDON_CLIENTCURSOR
	if (self.cursor_active)
	{
		if (self.cursor)
		{
			remove(self.cursor);
			self.cursor = world;
		}
		self.cursorpos_x = self.cursor_screen_x * 96;
		self.cursorpos_y = self.cursor_screen_y * 72;
	}
	else
	{
		
		if (!self.cursor)
		{
			self.cursor = spawn();
			self.cursor.drawonlytoclient = self;
			setmodel(self.cursor, "progs/cursor.spr"); // ugly temp model
		}
		self.cursor.frame = cursorframe();
		view = self.rotang;
		view_z = 0;
		if (self.origin != self.testorg)
		{
			ang = vectoangles(self.origin - self.testorg) - view;
			len = vlen(self.origin - self.testorg);
			ang_x = ang_z = 0;
			len = len * -1;
			makevectors(ang);
			self.cursorpos_y = self.cursorpos_y + v_forward_x * len;
			self.cursorpos_x = self.cursorpos_x + v_forward_y * len;
			//setorigin(self, self.testorg);
		}
	}
	if (self.options & OPT_NOMOUSE_CAM || self.ui_panels)
	{
		if (self.cursorpos_y > 72)
			self.cursorpos_y = 72;
		else if (self.cursorpos_y < -72)
			self.cursorpos_y = -72;
		if (self.cursorpos_x > 96)
			self.cursorpos_x = 96;
		else if (self.cursorpos_x < -96)
			self.cursorpos_x = -96;
		if (!vmfc)
			if (self.ui_panels)
				self.rotang_z = 256;
	}
	else
	{
		if (self.cursorpos_y > 72)
		{
			self.rotang_z = self.rotang_z - (self.cursorpos_y - 72);
			if (self.rotang_z < 64)
				self.rotang_z = 64;
			self.cursorpos_y = 72;
		}
		else if (self.cursorpos_y < -72)
		{
			self.rotang_z = self.rotang_z - (self.cursorpos_y + 72);
			if (self.rotang_z > 256)
				self.rotang_z = 256;
			self.cursorpos_y = -72;
		}
		if (self.cursorpos_x > 96)
		{
			self.rotang_y = self.rotang_y - (self.cursorpos_x - 96) * CAMERA_SCALE;
			self.cursorpos_x = 96;
		}
		else if (self.cursorpos_x < -96)
		{
			self.rotang_y = self.rotang_y - (self.cursorpos_x + 96) * CAMERA_SCALE;
			self.cursorpos_x = -96;
		}
	}
};


// DP hack man
.vector movement;

void() SV_PlayerPhysics =
{
	float spscl;
	spscl = 200 / (cvar("sv_maxspeed") / 320) ;
	
	setorigin(self, self.testorg);
	self.cursorpos_y = self.cursorpos_y - self.movement_x / spscl;
	self.cursorpos_x = self.cursorpos_x + self.movement_y / spscl;
	
	h_cursor();

};