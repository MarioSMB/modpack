.float cq_factor;
void conquest_controlpoint_draw2d()
{
	float dist = vlen(self.origin - view_origin);

	if(self.cq_capdistance > 0)
		if(dist > self.cq_capdistance)
			return;

	string img = "gfx/crosshair_ring.tga";
	vector psize = draw_getimagesize(img);
	vector loc = project_3d_to_2d(self.origin + '0 0 128'); // - 0.5 * psize;
	vector textloc = loc;
	if(!(loc_z < 0 || loc_x < 0 || loc_y < 0 || loc_x > vid_conwidth || loc_y > vid_conheight) || autocvar_cl_conquest_capture_ring_hud)
	{
		loc_z = psize_z = textloc_z = 0;
		float imgsize = autocvar_cl_conquest_capture_ring_size_min;
		vector textsize;
		if(autocvar_cl_conquest_capture_ring_hud)
		{
			loc = eX * 0.5 * vid_conwidth + eY * 0.6 * vid_conheight;
			textloc = eY * 0.64 * vid_conheight;
			textsize = eX * vid_conwidth + eY * 0.025 * vid_conheight;
			imgsize = 0.1 * vid_conheight;
		}
		else
		{
			imgsize = max(autocvar_cl_conquest_capture_ring_size_min, (1 - dist / self.cq_capdistance) * autocvar_cl_conquest_capture_ring_size_max);
			textsize = '4 2 0' * autocvar_cl_conquest_capture_ring_size_min;
			if(autocvar_cl_conquest_capture_text_align == 1)
				textloc_x -= textsize_x / 2;
			else if(autocvar_cl_conquest_capture_text_align == 2)
				textloc_x -= textsize_x;
		}

		//drawstring_aspect(eY * 0.64 * vid_conheight, _("Capture progress"), eX * vid_conwidth + eY * 0.025 * vid_conheight, '1 1 1', 1, DRAWFLAG_NORMAL);
		float player_team = (GetPlayerColor(player_localnum) + 1);
		string msg = "";
		if(self.team == player_team)
		{
			switch(self.cq_status)
			{
				default:
				case CP_NEUTRAL: msg = sprintf(_("Capturing %s"), self.netname); break;
				case CP_CAPTURED: msg = sprintf(_("Defending %s"), self.netname); break;
			}
		}
		else if(spectatee_status)
			msg = sprintf(_("Observing %s"), self.netname);
		else if(self.team && self.cq_status == CP_CAPTURED)
			msg = sprintf(_("Liberating %s"), self.netname);

		if(msg != "")
		{
			drawstring_aspect(textloc, msg, textsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			DrawCircleClippedPic(loc, imgsize, img, self.cq_factor, self.teamradar_color, 1, DRAWFLAG_ADDITIVE);
		}
	}
}

.float cq_rate;
void conquest_controlpoint_predraw()
{
	self.enemy.angles_y += 32 * frametime;
	float step = self.cq_rate * frametime;
	if ( self.cq_factor < self.health - step/2 )
		self.cq_factor += step;
	else if ( self.cq_factor > self.health + step/2 )
		self.cq_factor -= step;
	setorigin(self.enemy, self.origin + '0 0 1' * (50 + (self.cq_factor * 140)));
}

void conquest_controlpoint_remove()
{
	if(self.enemy)
		remove(self.enemy);

	if(self.netname)
		strunzone(self.netname);
}

void conquest_controlpoint_read(float bIsNew)
{
	float sf = ReadByte();

	if(sf & CQSF_SETUP)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
		self.drawmask = MASK_NORMAL;

		self.angles_y = ReadCoord();
		
		self.cq_capdistance = ReadLong();

		precache_model("models/conquest/stand.md3");
		setmodel(self, "models/conquest/stand.md3");
		setsize(self, CQ_CP_MIN, CQ_CP_MAX);
		self.predraw = conquest_controlpoint_predraw;
		self.draw2d = conquest_controlpoint_draw2d;
		self.cq_rate = 0.2;

		self.teamradar_icon = RADARICON_CONTROLPOINT;

		if(!self.enemy)
			self.enemy = spawn();

		precache_model("models/conquest/flag.md3");
		setmodel(self.enemy, "models/conquest/flag.md3");
		self.enemy.drawmask = MASK_NORMAL;
		self.enemy.scale = 1.5;
		self.entremove = conquest_controlpoint_remove;
	}

	if(sf & CQSF_STATE)
	{
		self.cq_status = ReadByte();
	}

	if(sf & CQSF_TEAM)
	{
		self.team = ReadByte();
		self.teamradar_color = Team_ColorRGB(self.team - 1);

		if(self.cq_status == CP_CAPTURED)
			self.enemy.colormap = self.colormap = 1024 + (self.team - 1) * 17;
		else
			self.enemy.colormap = self.colormap = 1024 * 17;
	}

	if(sf & CQSF_HEALTH)
	{
		float newhealth = ReadByte();
		if(newhealth != 0) { newhealth /= 255; }
		self.health = newhealth;
		self.cq_rate = ReadLong() / 100 * 0.2;
		self.teamradar_color = Team_ColorRGB(self.team - 1) * self.health + '1 1 1' * (1-self.health);
	}

	if(sf & CQSF_NAME)
	{
		if(self.netname)
			strunzone(self.netname);

		self.netname = strzone(ReadString());
	}
}
