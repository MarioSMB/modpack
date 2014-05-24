float waypointsprite_initialized;
float waypointsprite_fadedistance;
float waypointsprite_normdistance;
float waypointsprite_minscale;
float waypointsprite_minalpha;
float waypointsprite_distancealphaexponent;
float waypointsprite_timealphaexponent;
float waypointsprite_scale;
float waypointsprite_fontsize;
float waypointsprite_edgefadealpha;
float waypointsprite_edgefadescale;
float waypointsprite_edgefadedistance;
float waypointsprite_edgeoffset_bottom;
float waypointsprite_edgeoffset_left;
float waypointsprite_edgeoffset_right;
float waypointsprite_edgeoffset_top;
float waypointsprite_crosshairfadealpha;
float waypointsprite_crosshairfadescale;
float waypointsprite_crosshairfadedistance;
float waypointsprite_distancefadealpha;
float waypointsprite_distancefadescale;
float waypointsprite_distancefadedistance;
float waypointsprite_alpha;

.float helpme;
.float rule;
.string netname; // primary picture
.string netname2; // secondary picture
.string netname3; // tertiary picture
.float team; // team that gets netname2
.float lifetime;
.float fadetime;
.float maxdistance;
.float hideflags;
.float spawntime;
.float build_started;
.float build_starthealth;
.float build_finished;

const float SPRITE_HEALTHBAR_WIDTH = 144;
const float SPRITE_HEALTHBAR_HEIGHT = 9;
const float SPRITE_HEALTHBAR_MARGIN = 6;
const float SPRITE_HEALTHBAR_BORDER = 2;
const float SPRITE_HEALTHBAR_BORDERALPHA = 1;
const float SPRITE_HEALTHBAR_HEALTHALPHA = 0.5;
const float SPRITE_ARROW_SCALE = 1.0;
const float SPRITE_HELPME_BLINK = 2;

void drawrotpic(vector org, float rot, string pic, vector sz, vector hotspot, vector rgb, float a, float f)
{
	vector v1, v2, v3, v4;

	hotspot = -1 * hotspot;

	// hotspot-relative coordinates of the corners
	v1 = hotspot;
	v2 = hotspot + '1 0 0' * sz_x;
	v3 = hotspot + '1 0 0' * sz_x + '0 1 0' * sz_y;
	v4 = hotspot                  + '0 1 0' * sz_y;

	// rotate them, and make them absolute
	rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
	v1 = rotate(v1, rot) + org;
	v2 = rotate(v2, rot) + org;
	v3 = rotate(v3, rot) + org;
	v4 = rotate(v4, rot) + org;

	// draw them
	R_BeginPolygon(pic, f);
	R_PolygonVertex(v1, '0 0 0', rgb, a);
	R_PolygonVertex(v2, '1 0 0', rgb, a);
	R_PolygonVertex(v3, '1 1 0', rgb, a);
	R_PolygonVertex(v4, '0 1 0', rgb, a);
	R_EndPolygon();
}

void drawquad(vector o, vector ri, vector up, string pic, vector rgb, float a, float f)
{
	R_BeginPolygon(pic, f);
	R_PolygonVertex(o, '0 0 0', rgb, a);
	R_PolygonVertex(o + ri, '1 0 0', rgb, a);
	R_PolygonVertex(o + up + ri, '1 1 0', rgb, a);
	R_PolygonVertex(o + up, '0 1 0', rgb, a);
	R_EndPolygon();
}

void drawhealthbar(vector org, float rot, float h, vector sz, vector hotspot, float width, float height, float margin, float border, float align, vector rgb, float a, vector hrgb, float ha, float f)
{
	vector o, ri, up;
	float owidth; // outer width

	hotspot = -1 * hotspot;

	// hotspot-relative coordinates of the healthbar corners
	o = hotspot;
	ri = '1 0 0';
	up = '0 1 0';

	rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
	o = rotate(o, rot) + org;
	ri = rotate(ri, rot);
	up = rotate(up, rot);

	owidth = width + 2 * border;
	o = o - up * (margin + border + height) + ri * (sz_x - owidth) * 0.5;

	drawquad(o - up * border,                               ri * owidth,    up * border, "", rgb,  a,  f);
	drawquad(o + up * height,                               ri * owidth,    up * border, "", rgb,  a,  f);
	drawquad(o,                                             ri * border,    up * height, "", rgb,  a,  f);
	drawquad(o + ri * (owidth - border),                    ri * border,    up * height, "", rgb,  a,  f);
	drawquad(o + ri * (border + align * ((1 - h) * width)), ri * width * h, up * height, "", hrgb, ha, f);
}

// returns location of sprite text
vector drawspritearrow(vector o, float ang, vector rgb, float a, float t)
{
	float size   = 9.0 * t;
	float border = 1.5 * t;
	float margin = 4.0 * t;

	float borderDiag = border * 1.414;
	vector arrowX  = eX * size;
	vector arrowY  = eY * (size+borderDiag);
	vector borderX = eX * (size+borderDiag);
	vector borderY = eY * (size+borderDiag+border);

	R_BeginPolygon("", DRAWFLAG_NORMAL);
	R_PolygonVertex(o,                                  '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(arrowY  - borderX, ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(borderY - borderX, ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(borderY + borderX, ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(arrowY  + borderX, ang), '0 0 0', '0 0 0', a);
	R_EndPolygon();

	R_BeginPolygon("", DRAWFLAG_ADDITIVE);
	R_PolygonVertex(o + rotate(eY * borderDiag, ang), '0 0 0', rgb, a);
	R_PolygonVertex(o + rotate(arrowY - arrowX, ang), '0 0 0', rgb, a);
	R_PolygonVertex(o + rotate(arrowY + arrowX, ang), '0 0 0', rgb, a);
	R_EndPolygon();

	return o + rotate(eY * (borderDiag+size+margin), ang);
}

// returns location of sprite healthbar
vector drawspritetext(vector o, float ang, float minwidth, vector rgb, float a, vector fontsize, string s)
{
	float algnx, algny;
	float sw, w, h;
	float aspect, sa, ca;

	sw = stringwidth(s, FALSE, fontsize);
	if(sw > minwidth)
		w = sw;
	else
		w = minwidth;
	h = fontsize_y;

	// how do corners work?
	aspect = vid_conwidth / vid_conheight;
	sa = sin(ang);
	ca = cos(ang) * aspect;
	if(fabs(sa) > fabs(ca))
	{
		algnx = (sa < 0);
		algny = 0.5 - 0.5 * ca / fabs(sa);
	}
	else
	{
		algnx = 0.5 - 0.5 * sa / fabs(ca);
		algny = (ca < 0);
	}

	// align
	o_x -= w * algnx;
	o_y -= h * algny;

	// we want to be onscreen
	if(o_x < 0)
		o_x = 0;
	if(o_y < 0)
		o_y = 0;
	if(o_x > vid_conwidth - w)
		o_x = vid_conwidth - w;
	if(o_y > vid_conheight - h)
		o_x = vid_conheight - h;

	o_x += 0.5 * (w - sw);

	drawstring(o, s, fontsize, rgb, a, DRAWFLAG_NORMAL);

	o_x += 0.5 * sw;
	o_y += 0.5 * h;

	return o;
}

float spritelookupblinkvalue(string s)
{
	switch(s)
	{
		case "ons-cp-atck":      return 2;
		case "ons-cp-dfnd":      return 0.5;
		case "item-invis":       return 2;
		case "item-extralife":   return 2;
		case "item-speed":       return 2;
		case "item-strength":    return 2;
		case "item-shield":      return 2;
		case "item-fuelregen":   return 2;
		case "item-jetpack":     return 2;
		case "tagged-target":    return 2;
		default:                 return 1;
	}
}
vector spritelookupcolor(string s, vector def)
{
	switch(s)
	{
		case "keycarrier-friend": return '0 1 0';
		case "wpn-laser":         return '1 0.5 0.5';
		case "wpn-shotgun":       return '0.5 0.25 0';
		case "wpn-shotguncannon": return '0.5 0.25 0';
		case "wpn-uzi":           return '1 1 0';
		case "wpn-gl":            return '1 0 0';
		case "wpn-electro":       return '0 0.5 1';
		case "wpn-crylink":       return '1 0.5 1';
		case "wpn-nex":           return '0.5 1 1';
		case "wpn-hagar":         return '1 1 0.5';
		case "wpn-rl":            return '1 1 0';
		case "wpn-porto":         return '0.5 0.5 0.5';
		case "wpn-seeker":        return '1 1 0.5';
		case "wpn-minstanex":     return '0.5 1 1';
		case "wpn-hookgun":       return '0 0.5 0';
		case "wpn-fireball":      return '1 0.5 0';
		case "wpn-hlac":          return '0 1 0';
		case "wpn-campingrifle":  return '0.5 1 0';
		case "wpn-sniperrifle":   return '0.5 1 0';
		case "wpn-minelayer":     return '0.75 1 0';
		default:                  return def;
	}
}
string spritelookuptext(string s)
{
	switch(s)
	{
		case "as-push": return _("Push");
		case "as-destroy": return _("Destroy");
		case "as-defend": return _("Defend");
		case "bluebase": return _("Blue base");
		case "danger": return _("DANGER");
		case "enemyflagcarrier": return _("Enemy carrier");
		case "flagcarrier": return _("Flag carrier");
		case "flagdropped": return _("Dropped flag");
		case "keycarrier": return _("Key carrier");
		case "keydropped": return _("Dropped key");
		case "helpme": return _("Help me!");
		case "here": return _("Here");
		case "key-dropped": return _("Dropped key");
		case "keycarrier-blue": return _("Key carrier");
		case "keycarrier-finish": return _("Run here");
		case "keycarrier-friend": return _("Key carrier");
		case "keycarrier-pink": return _("Key carrier");
		case "keycarrier-red": return _("Key carrier");
		case "keycarrier-yellow": return _("Key carrier");
		case "redbase": return _("Red base");
		case "yellowbase": return _("Yellow base");
		case "neutralbase": return _("White base");
		case "pinkbase": return _("Pink base");
		case "waypoint": return _("Waypoint");
		case "ons-gen": return _("Generator");
		case "ons-gen-shielded": return _("Generator");
		case "ons-cp": return _("Control point");
		case "ons-cp-atck": return _("Control point");
		case "ons-cp-dfnd": return _("Control point");
		case "race-checkpoint": return _("Checkpoint");
		case "race-finish": return _("Finish");
		case "race-start": return _("Start");
		case "race-start-finish": return (race_checkpointtime || race_mycheckpointtime) ? _("Finish") : _("Start");
		case "goal": return _("Goal");
		case "nb-ball": return _("Ball");
		case "ka-ball": return _("Ball");
		case "ka-ballcarrier": return _("Ball carrier");
		case "wpn-laser": return _("Laser");
		case "wpn-shotgun": return _("Shotgun");
		case "wpn-shotguncannon": return _("Shotgun");
		case "wpn-uzi": return _("Machine Gun");
		case "wpn-gl": return _("Mortar");
		case "wpn-electro": return _("Electro");
		case "wpn-crylink": return _("Crylink");
		case "wpn-nex": return _("Nex");
		case "wpn-hagar": return _("Hagar");
		case "wpn-rl": return _("Rocket Launcher");
		case "wpn-porto": return _("Port-O-Launch");
		case "wpn-minstanex": return _("Minstanex");
		case "wpn-hookgun": return _("Hook");
		case "wpn-seeker": return _("T.A.G. Seeker");
		case "wpn-fireball": return _("Fireball");
		case "wpn-hlac": return _("HLAC");
		case "wpn-campingrifle": return _("Rifle");
		case "wpn-sniperrifle": return _("Rifle");
		case "wpn-minelayer": return _("Mine Layer");
		case "wpn-ok_hmg": return _("Heavy Machine Gun");
		case "wpn-ok_rl": return _("Rocket-Propelled Chainsaw");
		case "dom-neut": return _("Control point");
		case "dom-red": return _("Control point");
		case "dom-blue": return _("Control point");
		case "dom-yellow": return _("Control point");
		case "dom-pink": return _("Control point");
		case "item-invis": return _("Invisibility");
		case "item-extralife": return _("Extra life");
		case "item-speed": return _("Speed");
		case "item-strength": return _("Strength");
		case "item-shield": return _("Shield");
		case "item-fuelregen": return _("Fuel regen");
		case "item-jetpack": return _("Jet Pack");
		case "frozen": return _("Frozen!");
		case "enemy": return _("Enemy");
		case "tagged-target": return _("Tagged");
		case "vehicle": return _("Vehicle");
		case "survivals": return _("Survivals");
		case "vipkills": return _("VIP kills");
		case "vip": return _("VIP");
		case "intruder": return _("Intruder!");
		default: return s;
	}
}

vector fixrgbexcess_move(vector rgb, vector src, vector dst)
{
	vector yvec = '0.299 0.587 0.114';
	return rgb + dst * ((src * yvec) / (dst * yvec)) * ((rgb - '1 1 1') * src);
}
vector fixrgbexcess(vector rgb)
{
	if(rgb_x > 1)
	{
		rgb = fixrgbexcess_move(rgb, '1 0 0', '0 1 1');
		if(rgb_y > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 1 0', '0 0 1');
			if(rgb_z > 1)
				rgb_z = 1;
		}
		else if(rgb_z > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 0 1', '0 1 0');
			if(rgb_y > 1)
				rgb_y = 1;
		}
	}
	else if(rgb_y > 1)
	{
		rgb = fixrgbexcess_move(rgb, '0 1 0', '1 0 1');
		if(rgb_x > 1)
		{
			rgb = fixrgbexcess_move(rgb, '1 0 0', '0 0 1');
			if(rgb_z > 1)
				rgb_z = 1;
		}
		else if(rgb_z > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 0 1', '1 0 0');
			if(rgb_x > 1)
				rgb_x = 1;
		}
	}
	else if(rgb_z > 1)
	{
		rgb = fixrgbexcess_move(rgb, '0 0 1', '1 1 0');
		if(rgb_x > 1)
		{
			rgb = fixrgbexcess_move(rgb, '1 0 0', '0 1 0');
			if(rgb_y > 1)
				rgb_y = 1;
		}
		else if(rgb_y > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 1 0', '1 0 0');
			if(rgb_x > 1)
				rgb_x = 1;
		}
	}
	return rgb;
}

float waypointsprite_count, waypointsprite_newcount;
void Draw_WaypointSprite()
{
	string spriteimage;
	float t;

	if(self.lifetime)
		self.alpha = pow(bound(0, (self.fadetime - time) / self.lifetime, 1), waypointsprite_timealphaexponent);
	else
		self.alpha = 1;

	if(self.hideflags & 2)
		return; // radar only

	if(autocvar_cl_hidewaypoints >= 2)
		return;

	if(self.hideflags & 1)
		if(autocvar_cl_hidewaypoints)
			return; // fixed waypoint

	InterpolateOrigin_Do();

	t = GetPlayerColor(player_localnum) + 1;

	spriteimage = "";

	// choose the sprite
	switch(self.rule)
	{
		case SPRITERULE_DEFAULT:
			if(self.team)
			{
				if(self.team == t)
					spriteimage = self.netname;
				else
					spriteimage = "";
			}
			else
				spriteimage = self.netname;
			break;
		case SPRITERULE_TEAMPLAY:
			if(t == NUM_SPECTATOR + 1)
				spriteimage = self.netname3;
			else if(self.team == t)
				spriteimage = self.netname2;
			else
				spriteimage = self.netname;
			break;
		default:
			error("Invalid waypointsprite rule!");
			break;
	}

	if(spriteimage == "")
		return;

	++waypointsprite_newcount;

	float dist;
	dist = vlen(self.origin - view_origin);

	float a;
	a = self.alpha * autocvar_hud_panel_fg_alpha;

	if(self.maxdistance > waypointsprite_normdistance)
		a *= pow(bound(0, (self.maxdistance - dist) / (self.maxdistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent);
	else if(self.maxdistance > 0)
		a *= pow(bound(0, (waypointsprite_fadedistance - dist) / (waypointsprite_fadedistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent) * (1 - waypointsprite_minalpha) + waypointsprite_minalpha;

	vector rgb;
	rgb = self.teamradar_color;
	rgb = spritelookupcolor(spriteimage, rgb);
	if(rgb == '0 0 0')
	{
		self.teamradar_color = '1 0 1';
		printf("WARNING: sprite of name %s has no color, using pink so you notice it\n", spriteimage);
	}

	if(time - floor(time) > 0.5)
	{
		if(self.helpme && time < self.helpme)
			a *= SPRITE_HELPME_BLINK;
		else
			a *= spritelookupblinkvalue(spriteimage);
	}

	if(a > 1)
	{
		rgb *= a;
		a = 1;
	}

	if(a <= 0)
		return;

	rgb = fixrgbexcess(rgb);

	vector o;
	float ang;

	o = project_3d_to_2d(self.origin);
	if(o_z < 0
	|| o_x < (vid_conwidth * waypointsprite_edgeoffset_left)
	|| o_y < (vid_conheight * waypointsprite_edgeoffset_top)
	|| o_x > (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right))
	|| o_y > (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)))
	{
		// scale it to be just in view
		vector d;
		float f1, f2;

		d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;
		ang = atan2(-d_x, -d_y);
		if(o_z < 0)
			ang += M_PI;

		f1 = d_x / vid_conwidth;
		f2 = d_y / vid_conheight;

		if(max(f1, -f1) > max(f2, -f2))
		{
			if(d_z * f1 > 0)
			{
				// RIGHT edge
				d = d * ((0.5 - waypointsprite_edgeoffset_right) / f1);
			}
			else
			{
				// LEFT edge
				d = d * (-(0.5 - waypointsprite_edgeoffset_left) / f1);
			}
		}
		else
		{
			if(d_z * f2 > 0)
			{
				// BOTTOM edge
				d = d * ((0.5 - waypointsprite_edgeoffset_bottom) / f2);
			}
			else
			{
				// TOP edge
				d = d * (-(0.5 - waypointsprite_edgeoffset_top) / f2);
			}
		}

		o = d + '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
	}
	else
	{
#if 1
		ang = M_PI;
#else
		vector d;
		d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;
		ang = atan2(-d_x, -d_y);
#endif
	}
	o_z = 0;

	float edgedistance_min, crosshairdistance;
		edgedistance_min = min((o_y - (vid_conheight * waypointsprite_edgeoffset_top)),
	(o_x - (vid_conwidth * waypointsprite_edgeoffset_left)),
	(vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right)) - o_x,
	(vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)) - o_y);

	float vidscale;
	vidscale = max(vid_conwidth / vid_width, vid_conheight / vid_height);

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

	if(self.build_finished)
	{
		if(time < self.build_finished + 0.25)
		{
			if(time < self.build_started)
				self.health = self.build_starthealth;
			else if(time < self.build_finished)
				self.health = (time - self.build_started) / (self.build_finished - self.build_started) * (1 - self.build_starthealth) + self.build_starthealth;
			else
				self.health = 1;
		}
		else
			self.health = -1;
	}

	o = drawspritearrow(o, ang, rgb, a, SPRITE_ARROW_SCALE * t);

	string txt;
	if(autocvar_g_waypointsprite_spam && waypointsprite_count >= autocvar_g_waypointsprite_spam)
		txt = _("Spam");
	else
		txt = spritelookuptext(spriteimage);
	if(self.helpme && time < self.helpme)
		txt = sprintf(_("%s needing help!"), txt);
	if(autocvar_g_waypointsprite_uppercase)
		txt = strtoupper(txt);

	draw_beginBoldFont();
	if(self.health >= 0)
	{
		o = drawspritetext(o, ang, (SPRITE_HEALTHBAR_WIDTH + 2 * SPRITE_HEALTHBAR_BORDER) * t, rgb, a, waypointsprite_fontsize * '1 1 0', txt);

		float align, marg;
		if(self.build_finished)
			align = 0.5;
		else
			align = 0;
		if(cos(ang) > 0)
			marg = -(SPRITE_HEALTHBAR_MARGIN + SPRITE_HEALTHBAR_HEIGHT + 2 * SPRITE_HEALTHBAR_BORDER) * t - 0.5 * waypointsprite_fontsize;
		else
			marg = SPRITE_HEALTHBAR_MARGIN * t + 0.5 * waypointsprite_fontsize;
		drawhealthbar(
				o,
				0,
				self.health,
				'0 0 0',
				'0 0 0',
				SPRITE_HEALTHBAR_WIDTH * t,
				SPRITE_HEALTHBAR_HEIGHT * t,
				marg,
				SPRITE_HEALTHBAR_BORDER * t,
				align,
				rgb,
				a * SPRITE_HEALTHBAR_BORDERALPHA,
				rgb,
				a * SPRITE_HEALTHBAR_HEALTHALPHA,
				DRAWFLAG_NORMAL
			     );
	}
	else
	{
		o = drawspritetext(o, ang, 0, rgb, a, waypointsprite_fontsize * '1 1 0', txt);
	}
	draw_endBoldFont();
}

void Ent_RemoveWaypointSprite()
{
	if(self.netname)
		strunzone(self.netname);
	if(self.netname2)
		strunzone(self.netname2);
	if(self.netname3)
		strunzone(self.netname3);
}

void Ent_WaypointSprite()
{
	float sendflags, f, t;
	sendflags = ReadByte();

	if(!self.spawntime)
		self.spawntime = time;

	self.draw2d = Draw_WaypointSprite;

	InterpolateOrigin_Undo();
	self.iflags |= IFLAG_ORIGIN;

	if(sendflags & 0x80)
	{
		t = ReadByte();
		if(t < 192)
		{
			self.health = t / 191.0;
			self.build_finished = 0;
		}
		else
		{
			t = (t - 192) * 256 + ReadByte();
			self.build_started = servertime;
			if(self.build_finished)
				self.build_starthealth = bound(0, self.health, 1);
			else
				self.build_starthealth = 0;
			self.build_finished = servertime + t / 32;
		}
	}
	else
	{
		self.health = -1;
		self.build_finished = 0;
	}

	if(sendflags & 64)
	{
		// unfortunately, this needs to be exact (for the 3D display)
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}

	if(sendflags & 1)
	{
		self.team = ReadByte();
		self.rule = ReadByte();
	}

	if(sendflags & 2)
	{
		if(self.netname)
			strunzone(self.netname);
		self.netname = strzone(ReadString());
	}

	if(sendflags & 4)
	{
		if(self.netname2)
			strunzone(self.netname2);
		self.netname2 = strzone(ReadString());
	}

	if(sendflags & 8)
	{
		if(self.netname3)
			strunzone(self.netname3);
		self.netname3 = strzone(ReadString());
	}

	if(sendflags & 16)
	{
		self.lifetime = ReadCoord();
		self.fadetime = ReadCoord();
		self.maxdistance = ReadShort();
		self.hideflags = ReadByte();
	}

	if(sendflags & 32)
	{
		f = ReadByte();
		self.teamradar_icon = (f & 0x7F);
		if(f & 0x80)
		{
			self.(teamradar_times[self.teamradar_time_index]) = time;
			self.teamradar_time_index = mod(self.teamradar_time_index + 1, MAX_TEAMRADAR_TIMES);
		}
		self.teamradar_color_x = ReadByte() / 255.0;
		self.teamradar_color_y = ReadByte() / 255.0;
		self.teamradar_color_z = ReadByte() / 255.0;
		self.helpme = ReadByte() * 0.1;
		if(self.helpme > 0)
			self.helpme += servertime;
	}

	InterpolateOrigin_Note();

	self.entremove = Ent_RemoveWaypointSprite;
}

void WaypointSprite_Load_Frames(string ext)
{
	float dh, n, i, o, f;
	string s, sname, sframes;
	dh = search_begin(strcat("models/sprites/*_frame*", ext), FALSE, FALSE);
	if (dh < 0)
		 return;
	float ext_len = strlen(ext);
	n = search_getsize(dh);
	for(i = 0; i < n; ++i)
	{
		s = search_getfilename(dh, i);
		s = substring(s, 15, strlen(s) - 15 - ext_len); // strip models/sprites/ and extension

		o = strstrofs(s, "_frame", 0);
		sname = strcat("/spriteframes/", substring(s, 0, o));
		sframes = substring(s, o + 6, strlen(s) - o - 6);
		f = stof(sframes) + 1;
		db_put(tempdb, sname, ftos(max(f, stof(db_get(tempdb, sname)))));
	}
	search_end(dh);
}

void WaypointSprite_Load()
{
	waypointsprite_fadedistance = vlen(mi_scale);
	waypointsprite_normdistance = autocvar_g_waypointsprite_normdistance;
	waypointsprite_minscale = autocvar_g_waypointsprite_minscale;
	waypointsprite_minalpha = autocvar_g_waypointsprite_minalpha;
	waypointsprite_distancealphaexponent = autocvar_g_waypointsprite_distancealphaexponent;
	waypointsprite_timealphaexponent = autocvar_g_waypointsprite_timealphaexponent;
	waypointsprite_scale = autocvar_g_waypointsprite_scale;
	waypointsprite_fontsize = autocvar_g_waypointsprite_fontsize;
	waypointsprite_edgefadealpha = autocvar_g_waypointsprite_edgefadealpha;
	waypointsprite_edgefadescale = autocvar_g_waypointsprite_edgefadescale;
	waypointsprite_edgefadedistance = autocvar_g_waypointsprite_edgefadedistance;
	waypointsprite_edgeoffset_bottom = autocvar_g_waypointsprite_edgeoffset_bottom;
	waypointsprite_edgeoffset_left = autocvar_g_waypointsprite_edgeoffset_left;
	waypointsprite_edgeoffset_right = autocvar_g_waypointsprite_edgeoffset_right;
	waypointsprite_edgeoffset_top = autocvar_g_waypointsprite_edgeoffset_top;
	waypointsprite_crosshairfadealpha = autocvar_g_waypointsprite_crosshairfadealpha;
	waypointsprite_crosshairfadescale = autocvar_g_waypointsprite_crosshairfadescale;
	waypointsprite_crosshairfadedistance = autocvar_g_waypointsprite_crosshairfadedistance;
	waypointsprite_distancefadealpha = autocvar_g_waypointsprite_distancefadealpha;
	waypointsprite_distancefadescale = autocvar_g_waypointsprite_distancefadescale;
	waypointsprite_distancefadedistance = waypointsprite_fadedistance * autocvar_g_waypointsprite_distancefadedistancemultiplier;
	waypointsprite_alpha = autocvar_g_waypointsprite_alpha * (1 - autocvar__menu_alpha);

	if(!waypointsprite_initialized)
	{
		WaypointSprite_Load_Frames(".tga");
		WaypointSprite_Load_Frames(".jpg");
		waypointsprite_initialized = true;
	}

	waypointsprite_count = waypointsprite_newcount;
	waypointsprite_newcount = 0;
}
