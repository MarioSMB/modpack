// =========================
//  CSQC Monster Properties
// =========================


.vector glowmod;
void monster_changeteam()
{
	self.glowmod = Team_ColorRGB(self.team - 1);

	if(self.team)
	{
		self.teamradar_color = Team_ColorRGB(self.team - 1);
		self.colormap = 1024 + (self.team - 1) * 17;
	}
	else
	{
		self.teamradar_color = '1 0 0';
		self.colormap = 1024;
	}
}

void monster_die()
{
	MON_ACTION(self.monsterid, MR_DEATH);

	self.solid = SOLID_CORPSE;
}

void monster_draw2d()
{
	if(self.netname == "")
		return;
	
	if(!autocvar_g_waypointsprite_monsters)
		return;

	if(autocvar_cl_hidewaypoints)
		return;
		
	if(self.solid == SOLID_CORPSE)
		return; // re-spawning

	if(self.health <= 0)
		return;

	float dist = vlen(self.origin - view_origin);
	float t = (GetPlayerColor(player_localnum) + 1);

	vector o;
	string txt;

	if(autocvar_cl_vehicles_hud_tactical)
	if(dist < 10240 && t != self.team)
	{
		// TODO: Vehicle tactical hud
		o = project_3d_to_2d(self.origin + '0 0 1' * ((self.maxs_z + self.mins_z) * 0.5));
		if(o_z < 0
		|| o_x < (vid_conwidth * waypointsprite_edgeoffset_left)
		|| o_y < (vid_conheight * waypointsprite_edgeoffset_top)
		|| o_x > (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right))
		|| o_y > (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)))
			return; // Dont draw wp's for monsters out of view
		o_z = 0;
		if(hud != HUD_NORMAL)
		{
			switch(hud)
			{
				case HUD_SPIDERBOT:
				case HUD_WAKIZASHI:
				case HUD_RAPTOR:
				case HUD_BUMBLEBEE:
					vector pz = drawgetimagesize("gfx/vehicles/vth-mover.tga") * 0.25;
					drawpic(o - pz * 0.5, "gfx/vehicles/vth-mover.tga", pz , '1 1 1', 0.75, DRAWFLAG_NORMAL);
					break;
			}
		}
	}

	if(dist > self.maxdistance)
		return;

	string spriteimage = self.netname;
	float a = self.alpha * autocvar_hud_panel_fg_alpha;
	vector rgb = spritelookupcolor(spriteimage, self.teamradar_color);


	if(self.maxdistance > waypointsprite_normdistance)
		a *= pow(bound(0, (self.maxdistance - dist) / (self.maxdistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent);
	else if(self.maxdistance > 0)
		a *= pow(bound(0, (waypointsprite_fadedistance - dist) / (waypointsprite_fadedistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent) * (1 - waypointsprite_minalpha) + waypointsprite_minalpha;

	if(rgb == '0 0 0')
	{
		self.teamradar_color = '1 0 0';
		print(sprintf("WARNING: sprite of name %s has no color, using red so you notice it\n", spriteimage));
	}

	txt = self.netname;
	if(autocvar_g_waypointsprite_spam && waypointsprite_count >= autocvar_g_waypointsprite_spam)
		txt = _("Spam");
	else
		txt = spritelookuptext(spriteimage);

	if(autocvar_g_waypointsprite_uppercase)
		txt = strtoupper(txt);

	if(a > 1)
	{
		rgb *= a;
		a = 1;
	}

	if(a <= 0)
		return;

	rgb = fixrgbexcess(rgb);

	o = project_3d_to_2d(self.origin + '0 0 1' * (self.maxs_z + 15));
	if(o_z < 0
	|| o_x < (vid_conwidth * waypointsprite_edgeoffset_left)
	|| o_y < (vid_conheight * waypointsprite_edgeoffset_top)
	|| o_x > (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right))
	|| o_y > (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)))
		return; // Dont draw wp's for monsters out of view

	o_z = 0;

	float edgedistance_min, crosshairdistance;
		edgedistance_min = min((o_y - (vid_conheight * waypointsprite_edgeoffset_top)),
	(o_x - (vid_conwidth * waypointsprite_edgeoffset_left)),
	(vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right)) - o_x,
	(vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)) - o_y);

	float vidscale = max(vid_conwidth / vid_width, vid_conheight / vid_height);

	crosshairdistance = sqrt( pow(o_x - vid_conwidth/2, 2) + pow(o_y - vid_conheight/2, 2) );

	t = waypointsprite_scale * vidscale;
	a *= waypointsprite_alpha;

	{
		a = a * (1 - (1 - waypointsprite_distancefadealpha) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_distancefadescale) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
	}
	if (edgedistance_min < waypointsprite_edgefadedistance) {
		a = a * (1 - (1 - waypointsprite_edgefadealpha) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_edgefadescale) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
	}
	if(crosshairdistance < waypointsprite_crosshairfadedistance) {
		a = a * (1 - (1 - waypointsprite_crosshairfadealpha) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_crosshairfadescale) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
	}

	draw_beginBoldFont();
	o = drawspritearrow(o, M_PI, rgb, a, SPRITE_ARROW_SCALE * t);
	o = drawspritetext(o, M_PI, (SPRITE_HEALTHBAR_WIDTH + 2 * SPRITE_HEALTHBAR_BORDER) * t, rgb, a, waypointsprite_fontsize * '1 1 0', txt);
	drawhealthbar(
			o,
			0,
			self.health / 255,
			'0 0 0',
			'0 0 0',
			0.5 * SPRITE_HEALTHBAR_WIDTH * t,
			0.5 * SPRITE_HEALTHBAR_HEIGHT * t,
			SPRITE_HEALTHBAR_MARGIN * t + 0.5 * waypointsprite_fontsize,
			SPRITE_HEALTHBAR_BORDER * t,
			0,
			rgb,
			a * SPRITE_HEALTHBAR_BORDERALPHA,
			rgb,
			a * SPRITE_HEALTHBAR_HEALTHALPHA,
			DRAWFLAG_NORMAL
			);
	draw_endBoldFont();
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
	entity mon = get_monsterinfo(self.monsterid);

	if(mon.spawnflags & MONSTER_SIZE_BROKEN)
		self.scale = 1.3;

	self.netname = M_NAME(self.monsterid);

	setorigin(self, self.origin);
	setmodel(self, mon.model);
	setsize(self, mon.mins, mon.maxs);

	self.move_movetype	= MOVETYPE_BOUNCE;
	self.health			= 255;
	self.solid			= SOLID_BBOX;
	self.movetype		= MOVETYPE_BOUNCE;
	self.move_origin	= self.origin;
	self.move_time		= time;
	self.drawmask		= MASK_NORMAL;
	self.alpha			= 1;
	self.gravity		= 1;
	self.draw			= monster_draw;
	self.draw2d			= monster_draw2d;
	self.maxdistance	= autocvar_g_waypointsprite_monsters_maxdist;
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

		self.move_time = time;
		self.move_velocity = self.velocity;
		self.move_origin = self.origin;
	}

	if(sf & MSF_ANIM)
	{
		self.frame1time = ReadCoord();
		self.frame = ReadByte();
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
