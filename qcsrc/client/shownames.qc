// self.isactive = player is in range and coordinates/status (health and armor) are up to date
// self.origin = player origin TODO: should maybe move this so it's the origin of the shownames tag already in SSQC for culling?
// self.healthvalue
// self.armorvalue
// self.sameteam = player is on same team as local client
// self.fadedelay = time to wait before name tag starts fading in for enemies
// self.pointtime = last time you pointed at this player
// self.csqcmodel_isdead = value of csqcmodel_isdead to know when the player is dead or not

const float SHOWNAMES_FADESPEED = 4;
const float SHOWNAMES_FADEDELAY = 0.4;
void Draw_ShowNames(entity ent)
{
	if(!autocvar_hud_shownames)
		return;

#ifdef COMPAT_XON050_ENGINE
	if((ent.sv_entnum == player_localentnum) || (ent.sv_entnum == spectatee_status)) // ent is me or person i'm spectating
#else
	if(ent.sv_entnum == player_localentnum) // ent is me or person i'm spectating
#endif
		if(!(autocvar_hud_shownames_self && autocvar_chase_active))
			return;

	if(ent.sameteam || (!ent.sameteam && autocvar_hud_shownames_enemies))
	{
		ent.origin_z += autocvar_hud_shownames_offset;

		float hit;
		if(ent.sameteam && !autocvar_hud_shownames_crosshairdistance)
		{
			hit = 1;
		}
		else
		{
			traceline(view_origin, ent.origin, MOVE_NORMAL, ent);
			if(trace_fraction < 1 && (trace_networkentity != ent.sv_entnum && trace_ent.entnum != ent.sv_entnum))
				hit = 0;
			else
				hit = 1;
		}

		// handle tag fading
		float overlap = FALSE, onscreen, crosshairdistance;
		vector o, eo;

		o = project_3d_to_2d(ent.origin);

		if(autocvar_hud_shownames_antioverlap)
		{
			// fade tag out if another tag that is closer to you overlaps
			entity e;
			for(e = world; (e = find(e, classname, "shownames_tag")); )
			{
				if(e == ent)
					continue;
				eo = project_3d_to_2d(e.origin);
				if (!(eo_z < 0 || eo_x < 0 || eo_y < 0 || eo_x > vid_conwidth || eo_y > vid_conheight))
				{
					eo_z = 0;
					if(vlen((eX * o_x + eY * o_y) - eo) < autocvar_hud_shownames_antioverlap_distance && vlen(ent.origin - view_origin) > vlen(e.origin - view_origin))
					{
						overlap = TRUE;
						break;
					}
				}
			}
		}

		onscreen = (o_z >= 0 && o_x >= 0 && o_y >= 0 && o_x <= vid_conwidth && o_y <= vid_conheight);
		crosshairdistance = sqrt( pow(o_x - vid_conwidth/2, 2) + pow(o_y - vid_conheight/2, 2) );

		if(autocvar_hud_shownames_crosshairdistance)
		{
			if(autocvar_hud_shownames_crosshairdistance > crosshairdistance)
				ent.pointtime = time;

			if (!(ent.pointtime + autocvar_hud_shownames_crosshairdistance_time > time))
				overlap = TRUE;
			else
				overlap = (autocvar_hud_shownames_crosshairdistance_antioverlap ? overlap : FALSE); // override what antioverlap says unless allowed by cvar.
		}

		if(!ent.fadedelay)
			ent.fadedelay = time + SHOWNAMES_FADEDELAY;

		if(!ent.sameteam && (!onscreen || !hit)) // out of view, fade out
		{
			ent.alpha = max(0, ent.alpha - SHOWNAMES_FADESPEED * frametime);
			ent.fadedelay = 0; // reset fade in delay, enemy has left the view
		}
		else if(ent.csqcmodel_isdead) // dead player, fade out slowly
			ent.alpha = max(0, ent.alpha - SHOWNAMES_FADESPEED * 0.25 * frametime);
		else if(overlap) // tag overlap detected, fade out
			ent.alpha = max(0, ent.alpha - SHOWNAMES_FADESPEED * frametime);
		else if(ent.sameteam) // fade in for team mates
			ent.alpha = min(1, ent.alpha + SHOWNAMES_FADESPEED * frametime);
		else if(time > ent.fadedelay) // fade in for enemies
			ent.alpha = min(1, ent.alpha + SHOWNAMES_FADESPEED * frametime);

		// multiply by player alpha
		if(!ent.sameteam || (ent.sv_entnum == player_localentnum))
			ent.alpha *= getplayeralpha(ent.sv_entnum-1);

		if(ent.alpha < ALPHA_MIN_VISIBLE && gametype != MAPINFO_TYPE_CTS)
			return;

		float dist;
		dist = vlen(ent.origin - view_origin);

		float a;
		a = autocvar_hud_shownames_alpha;
		a *= ent.alpha;
		if(autocvar_hud_shownames_maxdistance)
		{
			if(dist >= autocvar_hud_shownames_maxdistance)
				return;
			a *= ((autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance) - max(0, dist - autocvar_hud_shownames_mindistance)) / (autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance);
		}

		if(!a)
			return;

		float resize;
		resize = 1;
		if(autocvar_hud_shownames_resize) // limit resize so its never smaller than 0.5... gets unreadable
			resize = 0.5 + 0.5 * ((autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance) - max(0, dist - autocvar_hud_shownames_mindistance)) / (autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance);

		// draw the sprite image
		if(o_z >= 0)
		{
			o_z = 0;

			vector myPos, mySize;
			mySize = (eX * autocvar_hud_shownames_aspect + eY) * autocvar_hud_shownames_fontsize;
			myPos = o - '0.5 0 0' * mySize_x - '0 1 0' * mySize_y;

			// size scaling
			mySize_x *= resize;
			mySize_y *= resize;

			myPos_x += 0.5 * (mySize_x / resize - mySize_x);
			myPos_y += (mySize_y / resize - mySize_y);

			vector namepos; // this is where the origin of the string
			float namewidth;

			namepos = myPos;
			namewidth = mySize_x;

			if(autocvar_hud_shownames_status && teamplay)
			{
				if(ent.sameteam)
				{
					if(ent.healthvalue > 0)
					{
						HUD_Panel_DrawProgressBar(namepos + '0 1 0' * autocvar_hud_shownames_fontsize * resize, eX * 0.5 * mySize_x + eY * resize * autocvar_hud_shownames_statusbar_height, "nametag_statusbar", ent.healthvalue/autocvar_hud_panel_healtharmor_maxhealth, 0, 1, '1 0 0', a, DRAWFLAG_NORMAL);

						if(ent.armorvalue > 0)
							HUD_Panel_DrawProgressBar(namepos + '0 1 0' * autocvar_hud_shownames_fontsize * resize + eX * 0.5 * mySize_x, eX * 0.5 * mySize_x + eY * resize * autocvar_hud_shownames_statusbar_height, "nametag_statusbar", ent.armorvalue/autocvar_hud_panel_healtharmor_maxarmor, 0, 0, '0 1 0', a, DRAWFLAG_NORMAL);
					}
				}
			}

			string s;
			s = GetPlayerName(ent.sv_entnum-1);
			if((autocvar_hud_shownames_decolorize == 1 && teamplay) || autocvar_hud_shownames_decolorize == 2)
				s = playername(s, GetPlayerColor(ent.sv_entnum-1));

			drawfontscale = '1 1 0' * resize;
			s = textShortenToWidth(s, namewidth, '1 1 0' * autocvar_hud_shownames_fontsize, stringwidth_colors);

			float width;
			width = stringwidth(s, TRUE, '1 1 0' * autocvar_hud_shownames_fontsize);

			if (width != namewidth)
				namepos_x += (namewidth - width) / 2;
			drawcolorcodedstring(namepos, s, '1 1 0' * autocvar_hud_shownames_fontsize, a, DRAWFLAG_NORMAL);
			drawfontscale = '1 1 0';
		}
	}
}

entity shownames_ent[255];
void Draw_ShowNames_All()
{
	float i;
	for(i = 0; i < maxclients; ++i)
	{
		float t;
		t = GetPlayerColor(i);
		if(t == NUM_SPECTATOR)
			continue;

		entity e;
		e = shownames_ent[i];
		if(!e)
		{
			e = spawn();
			e.classname = "shownames_tag";
			e.sv_entnum = i+1;
			shownames_ent[i] = e;
		}

		entity entcs;
		entcs = entcs_receiver[i];
		if(entcs)
		{
			e.healthvalue = entcs.healthvalue;
			e.armorvalue = entcs.armorvalue;
			e.sameteam = 1; /* (teamplay && (t == myteam)); */
		}
		else
		{
			e.healthvalue = 2342;
			e.armorvalue = 0;
			e.sameteam = 0;
		}

		setorigin(e, getplayerorigin(i));
		if(e.origin == GETPLAYERORIGIN_ERROR)
			continue;

		e.csqcmodel_isdead = getplayerisdead(i);

		Draw_ShowNames(e);
	}
}
