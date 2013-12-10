void turret_remove()
{
	remove(self.tur_head);
	//remove(self.enemy);
	self.tur_head = world;
}

.vector glowmod;
void turret_changeteam()
{
	switch(self.team - 1)
	{
		case NUM_TEAM_1: // Red
			self.glowmod = '2 0 0';
			self.teamradar_color = '1 0 0';
			break;

		case NUM_TEAM_2: // Blue
			self.glowmod = '0 0 2';
			self.teamradar_color = '0 0 1';
			break;

		case NUM_TEAM_3: // Yellow
			self.glowmod = '1 1 0';
			self.teamradar_color = '1 1 0';
			break;

		case NUM_TEAM_4: // Pink
			self.glowmod = '1 0 1';
			self.teamradar_color = '1 0 1';
			break;
	}

	if(self.team)
		self.colormap = 1024 + (self.team - 1) * 17;

	self.tur_head.colormap = self.colormap;
	self.tur_head.glowmod = self.glowmod;

}

void turret_head_draw()
{
	self.drawmask = MASK_NORMAL;
}

void turret_draw()
{
	float dt;

	dt = time - self.move_time;
	self.move_time = time;
	if(dt <= 0)
		return;

	self.tur_head.angles += dt * self.tur_head.move_avelocity;

	if (self.health < 127)
	{
		dt = random();

		if(dt < 0.03)
			te_spark(self.origin + '0 0 40', randomvec() * 256 + '0 0 256', 16);
	}

	if(self.health < 85)
	if(dt < 0.01)
		pointparticles(particleeffectnum("smoke_large"), (self.origin + (randomvec() * 80)), '0 0 0', 1);

	if(self.health < 32)
	if(dt < 0.015)
		pointparticles(particleeffectnum("smoke_small"), (self.origin + (randomvec() * 80)), '0 0 0', 1);

}

void turret_draw2d()
{
	if(self.netname == "")
		return;

	if(!autocvar_g_waypointsprite_turrets)
		return;

	if(autocvar_cl_hidewaypoints)
		return;

	float dist = vlen(self.origin - view_origin);
	float t = (GetPlayerColor(player_localnum) + 1);

	vector o;
	string txt;

	if(autocvar_cl_vehicles_hud_tactical)
	if(dist < 10240 && t != self.team)
	{
		// TODO: Vehicle tactical hud
		o = project_3d_to_2d(self.origin + '0 0 32');
		if(o_z < 0
		|| o_x < (vid_conwidth * waypointsprite_edgeoffset_left)
		|| o_y < (vid_conheight * waypointsprite_edgeoffset_top)
		|| o_x > (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right))
		|| o_y > (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)))
			return; // Dont draw wp's for turrets out of view
		o_z = 0;
		if(hud != HUD_NORMAL)
		{
			if((get_turretinfo(self.turretid)).spawnflags & TUR_FLAG_MOVE)
				txt = "gfx/vehicles/vth-mover.tga";
			else
				txt = "gfx/vehicles/vth-stationary.tga";

			vector pz = drawgetimagesize(txt) * 0.25;
			drawpic(o - pz * 0.5, txt, pz , '1 1 1', 0.75, DRAWFLAG_NORMAL);
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
		self.teamradar_color = '1 0 1';
		print(sprintf("WARNING: sprite of name %s has no color, using pink so you notice it\n", spriteimage));
	}

	txt = self.netname;
	if(autocvar_g_waypointsprite_spam && waypointsprite_count >= autocvar_g_waypointsprite_spam)
		txt = _("Spam");
	else
		txt = spritelookuptext(spriteimage);

	if(time - floor(time) > 0.5 && t == self.team)
	{
		if(self.helpme && time < self.helpme)
		{
			a *= SPRITE_HELPME_BLINK;
			txt = sprintf(_("%s under attack!"), txt);
		}
		else
			a *= spritelookupblinkvalue(spriteimage);
	}

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

	o = project_3d_to_2d(self.origin + '0 0 64');
	if(o_z < 0
	|| o_x < (vid_conwidth * waypointsprite_edgeoffset_left)
	|| o_y < (vid_conheight * waypointsprite_edgeoffset_top)
	|| o_x > (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right))
	|| o_y > (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)))
		return; // Dont draw wp's for turrets out of view

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
}

void(entity e, entity tagentity, string tagname) setattachment = #443;
void turret_construct()
{
	entity tur = get_turretinfo(self.turretid);

	if(self.tur_head == world)
		self.tur_head = spawn();

	self.netname = TUR_NAME(self.turretid);

	setorigin(self, self.origin);
	SETMODEL(self, tur.model);
	SETMODEL(self.tur_head, tur.head_model);
	setsize(self, tur.mins, tur.maxs);
	setsize(self.tur_head, '0 0 0', '0 0 0');

	if(self.turretid == TUR_EWHEEL)
		setattachment(self.tur_head, self, "");
	else
		setattachment(self.tur_head, self, "tag_head");

	self.tur_head.classname			= "turret_head";
	self.tur_head.owner				= self;
	self.tur_head.move_movetype		= MOVETYPE_NOCLIP;
	self.move_movetype				= MOVETYPE_NOCLIP;
	self.tur_head.angles			= self.angles;
	self.health						= 255;
	self.solid						= SOLID_BBOX;
	self.tur_head.solid				= SOLID_NOT;
	self.movetype					= MOVETYPE_NOCLIP;
	self.tur_head.movetype			= MOVETYPE_NOCLIP;
	self.draw						= turret_draw;
	self.entremove					= turret_remove;
	self.drawmask					= MASK_NORMAL;
	self.tur_head.drawmask			= MASK_NORMAL;
	self.anim_start_time			= 0;
	self.draw2d = turret_draw2d;
	self.maxdistance = autocvar_g_waypointsprite_turrets_maxdist;
	self.teamradar_color = '1 0 0';
	self.alpha = 1;
	
	TUR_ACTION(self.turretid, TR_SETUP);
}

entity turret_gibtoss(string _model, vector _from, vector _to, vector _cmod, float _explode);
void turret_gibboom();
void turret_gib_draw()
{
	Movetype_Physics_MatchTicrate(autocvar_cl_gibs_ticrate, autocvar_cl_gibs_sloppy);

	self.drawmask = MASK_NORMAL;

	if(self.cnt)
	{
		if(time >= self.nextthink)
		{
			turret_gibboom();
			remove(self);
		}
	}
	else
	{
		self.alpha = bound(0, self.nextthink - time, 1);
		if(self.alpha < ALPHA_MIN_VISIBLE)
			remove(self);
	}
}

void turret_gibboom()
{
	float i;

	sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);

	for (i = 1; i < 5; i = i + 1)
		turret_gibtoss(strcat("models/turrets/head-gib", ftos(i), ".md3"), self.origin + '0 0 2', self.velocity + randomvec() * 700, '0 0 0', FALSE);
}

entity turret_gibtoss(string _model, vector _from, vector _to, vector _cmod, float _explode)
{
	entity gib;

	traceline(_from, _to, MOVE_NOMONSTERS, world);
	if(trace_startsolid)
		return world;

	gib = spawn();
	setorigin(gib, _from);
	SETMODEL(gib, _model);
	gib.colormod	= _cmod;
	gib.solid	   = SOLID_CORPSE;
	gib.draw		= turret_gib_draw;
	gib.cnt		 = _explode;
	setsize(gib, '-1 -1 -1', '1 1 1');
	if(_explode)
	{
		gib.nextthink = time + 0.2 * (autocvar_cl_gibs_lifetime * (1 + prandom() * 0.15));
		gib.effects = EF_FLAME;
	}
	else
		gib.nextthink = time + autocvar_cl_gibs_lifetime * (1 + prandom() * 0.15);

	gib.gravity		 = 1;
	gib.move_movetype   = MOVETYPE_BOUNCE;
	gib.move_origin	 = _from;
	setorigin(gib,		_from);
	gib.move_velocity   = _to;
	gib.move_avelocity  = prandomvec() * 32;
	gib.move_time	   = time;
	gib.damageforcescale = 1;
	gib.classname = "turret_gib";

	return gib;
}

void turret_die()
{
	sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);
	if (!autocvar_cl_nogibs)
	{
		// Base
		if(self.turretid == TUR_EWHEEL)
			turret_gibtoss((get_turretinfo(self.turretid)).model, self.origin + '0 0 18', self.velocity + '0 0 400' + '0.1 0.1 1' * (random() * 400), '-1 -1 -1', TRUE);
		else if (self.turretid == TUR_WALKER)
			turret_gibtoss((get_turretinfo(self.turretid)).model, self.origin + '0 0 18', self.velocity + '0 0 300' + '0.1 0.1 1' * (random() * 200), '-1 -1 -1', TRUE);
		else if (self.turretid == TUR_TESLA)
			turret_gibtoss((get_turretinfo(self.turretid)).model, self.origin + '0 0 18', '0 0 200', '-1 -1 -1', FALSE);
		else
		{
			if (random() > 0.5)
			{
				turret_gibtoss("models/turrets/base-gib2.md3", self.origin + '0 0 8', '0 0 50' + randomvec() * 150, '0 0 0', FALSE);
				turret_gibtoss("models/turrets/base-gib3.md3", self.origin + '0 0 8', '0 0 50' + randomvec() * 150, '0 0 0', FALSE);
				turret_gibtoss("models/turrets/base-gib4.md3", self.origin + '0 0 8', '0 0 50' + randomvec() * 150, '0 0 0', FALSE);
			}
			else
				turret_gibtoss("models/turrets/base-gib1.md3", self.origin + '0 0 8', '0 0 0', '0 0 0', TRUE);

			entity headgib = turret_gibtoss((get_turretinfo(self.turretid)).head_model, self.origin + '0 0 32', '0 0 200' + randomvec() * 200, '-1 -1 -1', TRUE);
			if(headgib)
			{
				headgib.angles = headgib.move_angles = self.tur_head.angles;
				headgib.avelocity = headgib.move_avelocity = self.tur_head.move_avelocity + randomvec() * 45;
				headgib.avelocity_y = headgib.move_avelocity_y = headgib.move_avelocity_y * 5;
				headgib.gravity = 0.5;
			}
		}
	}

	SETMODEL(self, "null");
	SETMODEL(self.tur_head, "null");
}

void ent_turret()
{
	float sf;
	sf = ReadByte();

	if(sf & TNSF_SETUP)
	{
		self.turretid = ReadByte();

		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);

		self.angles_x = ReadAngle();
		self.angles_y = ReadAngle();
		
		turret_construct();
		self.colormap = 1024;
		self.glowmod = '0 1 1';
		self.tur_head.colormap = self.colormap;
		self.tur_head.glowmod = self.glowmod;
	}

	if(sf & TNSF_ANG)
	{
		if(self.tur_head == world) // aparenly this can happpen before TNSF_SETUP. great.
			self.tur_head = spawn();

		self.tur_head.move_angles_x = ReadShort();
		self.tur_head.move_angles_y = ReadShort();
		//self.tur_head.angles = self.angles + self.tur_head.move_angles;
		self.tur_head.angles = self.tur_head.move_angles;
	}

	if(sf & TNSF_AVEL)
	{
		if(self.tur_head == world) // aparenly this can happpen before TNSF_SETUP. great.
			self.tur_head = spawn();

		self.tur_head.move_avelocity_x = ReadShort();
		self.tur_head.move_avelocity_y = ReadShort();
	}

	if(sf & TNSF_MOVE)
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

	if(sf & TNSF_ANIM)
	{
		self.frame1time = ReadCoord();
		self.frame	  = ReadByte();
	}

	if(sf & TNSF_STATUS)
	{
		float _tmp;
		_tmp = ReadByte();
		if(_tmp != self.team)
		{
			self.team = _tmp;
			turret_changeteam();
		}

		_tmp = ReadByte();
		if(_tmp == 0 && self.health != 0)
			turret_die();
		else if(self.health && self.health != _tmp)
			self.helpme = servertime + 10;

		self.health = _tmp;
	}
	//self.enemy.health = self.health / 255;
}
