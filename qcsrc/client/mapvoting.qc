float mv_num_maps;

string mv_maps[MAPVOTE_COUNT];
string mv_pics[MAPVOTE_COUNT];
string mv_pk3[MAPVOTE_COUNT];
float mv_preview[MAPVOTE_COUNT];
float mv_votes[MAPVOTE_COUNT];
float mv_avail[MAPVOTE_COUNT];
float mv_avail_start[MAPVOTE_COUNT];
entity mv_pk3list;
float mv_abstain;
float mv_ownvote;
float mv_detail;
float mv_timeout;
float mv_top2_time;
float mv_top2_alpha;

vector mv_mousepos;
float mv_selection;
float mv_columns;
float mv_mouse_selection;
float mv_selection_keyboard;

float gametypevote;
string mapvote_choosenmap;
vector gtv_text_size;
vector gtv_text_size_small;

string MapVote_FormatMapItem(float id, string map, float count, float maxwidth, vector fontsize)
{
	string pre, post;
	pre = sprintf("%d. ", id+1);
	if(mv_detail)
	{
		if(count == 1)
			post = _(" (1 vote)");
		else if(count >= 0 && mv_avail[id] == GTV_AVAILABLE)
			post = sprintf(_(" (%d votes)"), count);
		else
			post = "";
	}
	else
		post = "";
	maxwidth -= stringwidth(pre, FALSE, fontsize) + stringwidth(post, FALSE, fontsize);
	map = textShortenToWidth(map, maxwidth, fontsize, stringwidth_nocolors);
	return strcat(pre, map, post);
}

string GameTypeVote_DescriptionByID(float id)
{
	return MapInfo_Type_Description(MapInfo_Type_FromString(mv_maps[id]));
}

vector MapVote_RGB(float id)
{
	if(mv_avail[id] != GTV_AVAILABLE)
		return '1 1 1';
	if(id == mv_ownvote)
		return '0 1 0';
	else if (id == mv_selection)
		return '1 1 0';
	else
		return '1 1 1';
}

void GameTypeVote_DrawGameTypeItem(vector pos, float maxh, float tsize, string gtype, string pic, float count, float id)
{
	float alpha;
	float desc_padding = gtv_text_size_x * 3;
	float rect_margin = hud_fontsize_y / 2;
	vector rect_pos = pos - '0.5 0.5 0' * rect_margin;
	vector rect_size = '1 1 0';
	rect_size_x = tsize + rect_margin;
	rect_size_y = maxh + rect_margin;
	vector rgb = MapVote_RGB(id);
	vector offset = pos;
	float nlines = 0;
	
	if(mv_avail_start[id] != GTV_AVAILABLE)
		alpha = 0.2;
	else if ( mv_avail[id] != GTV_AVAILABLE && mv_top2_alpha)
		alpha = mv_top2_alpha;
	else
		alpha = 1;
	
	if(id == mv_selection && mv_avail[id] == GTV_AVAILABLE)
	{
		drawfill(rect_pos, rect_size, '1 1 1', 0.1, DRAWFLAG_NORMAL);
	}
	if(id == mv_ownvote)
	{
		drawfill(rect_pos, rect_size, rgb, 0.1*alpha, DRAWFLAG_NORMAL);
		drawborderlines(autocvar_scoreboard_border_thickness, rect_pos, rect_size, rgb, alpha, DRAWFLAG_NORMAL);
	}
	
	entity title;
	title = spawn();
	title.message = MapVote_FormatMapItem(id, MapInfo_Type_ToText(MapInfo_Type_FromString(gtype)), 
										  count, tsize, gtv_text_size);
	title.origin = pos-offset;
	
	pos_y += gtv_text_size_small_y;
	pos_y += gtv_text_size_y/2;
	
	maxh -= gtv_text_size_y;
	
	entity picent = spawn();
	picent.origin = pos-offset;
	picent.maxs = '1 1 0 ' * min(maxh, desc_padding) * 0.8;
	
	pos_x += desc_padding;
	tsize -= desc_padding;
	
	string thelabel = GameTypeVote_DescriptionByID(id), ts;
	entity last = title;
	entity next = world;
	if( thelabel != "") 
	{
		float i,n = tokenizebyseparator(thelabel, "\n");
		for(i = 0; i < n && maxh > (nlines+1)*gtv_text_size_small_y; ++i)
		{
			getWrappedLine_remaining = argv(i);
			while(getWrappedLine_remaining && maxh > (nlines+1)*gtv_text_size_small_y)
			{
				ts = getWrappedLine(tsize, gtv_text_size_small, stringwidth_colors);
				if (ts != "")
				{
					next = spawn();
					next.message = ts;
					next.origin = pos-offset;
					last.chain = next;
					last = next;
					pos_y += gtv_text_size_small_y;
					nlines++;
				}
			}
		}
	}
	
	maxh -= max(nlines*gtv_text_size_small_y,picent.maxs_y);
	if ( maxh > 0 )
		offset_y += maxh/2;
	drawstring(title.origin+offset, title.message, gtv_text_size, rgb, alpha, DRAWFLAG_NORMAL); 
	
	if(pic != "")
		drawpic(picent.origin+offset, pic, picent.maxs, '1 1 1', alpha, DRAWFLAG_NORMAL);
	
	for ( last = title.chain; last ; )
	{
		drawstring(last.origin+offset, last.message, gtv_text_size_small, '1 1 1', alpha, DRAWFLAG_NORMAL);
		next = last;
		last = last.chain;
		remove(next);
	}
	
	remove(picent);
	remove(title);
}

void MapVote_DrawMapItem(vector pos, float isize, float tsize, string map, string pic, float count, float id)
{
	vector img_size = '0 0 0';
	vector rgb;
	string label;
	float text_size;

	isize -= hud_fontsize_y; // respect the text when calculating the image size

	rgb = MapVote_RGB(id);

	img_size_y = isize;
	img_size_x = isize / 0.75; // 4:3 x can be stretched easily, height is defined in isize

	pos_y = pos_y + img_size_y;

	label = MapVote_FormatMapItem(id, map, count, tsize, hud_fontsize);

	text_size = stringwidth(label, false, hud_fontsize);

	float theAlpha;
	if (mv_avail[id] != GTV_AVAILABLE && mv_top2_alpha)
		theAlpha = mv_top2_alpha;
	else
		theAlpha = 1;

	pos_x -= text_size*0.5;
	drawstring(pos, label, hud_fontsize, rgb, theAlpha, DRAWFLAG_NORMAL);

	pos_x = pos_x + text_size*0.5 - img_size_x*0.5;
	pos_y = pos_y - img_size_y;

	pos += autocvar_scoreboard_border_thickness * '1 1 0';
	img_size -= (autocvar_scoreboard_border_thickness * 2) * '1 1 0';
	if(pic == "")
	{
		drawfill(pos, img_size, '.5 .5 .5', .7 * theAlpha, DRAWFLAG_NORMAL);
	}
	else
	{
		if(drawgetimagesize(pic) == '0 0 0')
			//drawpic_rotated(pos, draw_UseSkinFor("nopreview_map"), img_size, '1 1 1', M_PI, theAlpha, DRAWFLAG_NORMAL);
			drawpic(pos, draw_UseSkinFor("nopreview_map"), img_size, '1 1 1', theAlpha, DRAWFLAG_NORMAL);
		else
			drawpic(pos, pic, img_size, '1 1 1', theAlpha, DRAWFLAG_NORMAL);
            //drawpic_rotated(pos, pic, img_size, '1 1 1', M_PI, theAlpha, DRAWFLAG_NORMAL);
	}

	if(id == mv_ownvote)
		drawborderlines(autocvar_scoreboard_border_thickness, pos, img_size, rgb, theAlpha, DRAWFLAG_NORMAL);
	else
		drawborderlines(autocvar_scoreboard_border_thickness, pos, img_size, '0 0 0', theAlpha, DRAWFLAG_NORMAL);

	if(id == mv_selection && mv_avail[id] == GTV_AVAILABLE)
		drawfill(pos, img_size, '1 1 1', 0.1, DRAWFLAG_NORMAL);
}

void MapVote_DrawAbstain(vector pos, float isize, float tsize, float count, float id)
{
	vector rgb;
	float text_size;
	string label;

	rgb = MapVote_RGB(id);

	pos_y = pos_y + hud_fontsize_y;

	label = MapVote_FormatMapItem(id, _("Don't care"), count, tsize, hud_fontsize);

	text_size = stringwidth(label, false, hud_fontsize);

	pos_x -= text_size*0.5;
	drawstring(pos, label, hud_fontsize, rgb, 1, DRAWFLAG_NORMAL);
}

vector MapVote_GridVec(vector gridspec, float i, float m)
{
	float r;
	r = mod(i, m);
	return
		'1 0 0' * (gridspec_x * r)
		+
		'0 1 0' * (gridspec_y * (i - r) / m);
}

float MapVote_Selection(vector topleft, vector cellsize, float rows, float columns)
{

	float c, r;

	mv_mouse_selection = -1;

	for (r = 0; r < rows; ++r)
		for (c = 0; c < columns; ++c)
		{
			if (mv_mousepos_x >= topleft_x + cellsize_x *  c &&
				mv_mousepos_x <= topleft_x + cellsize_x * (c + 1) &&
				mv_mousepos_y >= topleft_y + cellsize_y *  r &&
				mv_mousepos_y <= topleft_y + cellsize_y * (r + 1))
			{
				mv_mouse_selection = r * columns + c;
				break;
			}
		}

	if (mv_mouse_selection >= mv_num_maps)
		mv_mouse_selection = -1;

	if (mv_abstain && mv_mouse_selection < 0)
		mv_mouse_selection = mv_num_maps;

	if ( mv_selection_keyboard )
		return mv_selection;
	
	return mv_mouse_selection;
}

void MapVote_Draw()
{
	string map;
	float i, tmp;
	vector pos;
	float isize;
	float center;
	float rows;
	float tsize;
	vector dist = '0 0 0';

	if(!mv_active)
		return;

	if (!autocvar_hud_cursormode)
	{
		vector mpos = mv_mousepos + getmousepos();
		mpos_x = bound(0, mpos_x, vid_conwidth);
		mpos_y = bound(0, mpos_y, vid_conheight);
		
		if ( mpos_x != mv_mousepos_x || mpos_y != mv_mousepos_y )
			mv_selection_keyboard = 0;
		mv_mousepos = mpos;

	}

	center = (vid_conwidth - 1)/2;
	xmin = vid_conwidth*0.05; // 5% border must suffice
	xmax = vid_conwidth - xmin;
	ymin = 20;
	i = autocvar_con_chatpos; //*autocvar_con_chatsize;
	if(i < 0)
		ymax = vid_conheight + (i - autocvar_con_chat) * autocvar_con_chatsize;
	if(i >= 0 || ymax < (vid_conheight*0.5))
		ymax = vid_conheight - ymin;

	hud_fontsize = HUD_GetFontsize("hud_fontsize");

	pos_y = ymin;
	pos_z = 0;

	draw_beginBoldFont();
	map = ((gametypevote) ? _("Decide the gametype") : _("Vote for a map"));
	pos_x = center - stringwidth(map, false, '12 0 0');
	drawstring(pos, map, '24 24 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_y += 26;

	if( mapvote_choosenmap != "" )
	{
		pos_x = center - stringwidth(mapvote_choosenmap, false, hud_fontsize);
		drawstring(pos, mapvote_choosenmap, hud_fontsize*2, '1 1 1', 1, DRAWFLAG_NORMAL);
		pos_y += hud_fontsize_y*2;
	}

	i = ceil(max(0, mv_timeout - time));
	map = sprintf(_("%d seconds left"), i);
	pos_x = center - stringwidth(map, false, '8 0 0');
	drawstring(pos, map, '16 16 0', '0 1 0', 1, DRAWFLAG_NORMAL);
	pos_y += 22;
	pos_x = xmin;
	draw_endBoldFont();

	// base for multi-column stuff...
	ymin = pos_y;
	if(mv_abstain)
		mv_num_maps -= 1;

	rows = ceil(mv_num_maps / mv_columns);

	dist_x = (xmax - xmin) / mv_columns;
	dist_y = (ymax - pos_y) / rows;

	if ( gametypevote )
	{
		tsize = dist_x - hud_fontsize_y;
		isize = dist_y;
		float maxheight = (ymax - pos_y) / 3;
		if ( isize > maxheight )
		{
			pos_x += (isize - maxheight)/2;
			isize = maxheight;
		}
		else
			dist_y += hud_fontsize_y;
		pos_x = ( vid_conwidth - dist_x * mv_columns ) / 2;
	}
	else
	{
		tsize = dist_x - 10;
		isize = min(dist_y - 10, 0.75 * tsize);
	}

	mv_selection = MapVote_Selection(pos, dist, rows, mv_columns);

	if ( !gametypevote )
		pos_x += dist_x / 2;
	pos_y += (dist_y - isize) / 2;
	ymax -= isize;

	if (mv_top2_time)
		mv_top2_alpha = max(0.2, 1 - (time - mv_top2_time)*(time - mv_top2_time));

	void (vector, float, float, string, string, float, float) DrawItem;

	if(gametypevote)
		DrawItem = GameTypeVote_DrawGameTypeItem;
	else
		DrawItem = MapVote_DrawMapItem;

	for(i = 0; i < mv_num_maps; ++i)
	{
		tmp = mv_votes[i]; // FTEQCC bug: too many array accesses in the function call screw it up
		map = mv_maps[i];
		if(mv_preview[i])
			DrawItem(pos + MapVote_GridVec(dist, i, mv_columns), isize, tsize, map, mv_pics[i], tmp, i);
		else
			DrawItem(pos + MapVote_GridVec(dist, i, mv_columns), isize, tsize, map, "", tmp, i);
	}

	if(mv_abstain)
		++mv_num_maps;

	if(mv_abstain && i < mv_num_maps) {
		tmp = mv_votes[i];
		pos_y = ymax + isize - hud_fontsize_y;
		pos_x = (xmax+xmin)*0.5;
		MapVote_DrawAbstain(pos, isize, xmax - xmin, tmp, i);
	}

	drawpic(mv_mousepos, strcat("gfx/menu/", autocvar_menu_skin, "/cursor.tga"), '32 32 0', '1 1 1', 1 - autocvar__menu_alpha, DRAWFLAG_NORMAL);
}

void Cmd_MapVote_MapDownload(float argc)
{
	float id;
	entity pak;

	if(argc != 2 || !mv_pk3list)
	{
		print(_("mv_mapdownload: ^3You're not supposed to use this command on your own!\n"));
		return;
	}

	id = stof(argv(1));
	for(pak = mv_pk3list; pak; pak = pak.chain)
		if(pak.sv_entnum == id)
			break;

	if(!pak || pak.sv_entnum != id) {
		print(_("^1Error:^7 Couldn't find pak index.\n"));
		return;
	}

	if(PreviewExists(pak.message))
	{
		mv_preview[id] = true;
		return;
	} else {
		print(_("Requesting preview...\n"));
		localcmd(strcat("\ncmd mv_getpicture ", ftos(id), "\n"));
	}
}

void MapVote_CheckPK3(string pic, string pk3, float id)
{
	entity pak;
	pak = spawn();
	pak.netname = pk3;
	pak.message = pic;
	pak.sv_entnum = id;

	pak.chain = mv_pk3list;
	mv_pk3list = pak;

	if(pk3 != "")
	{
		localcmd(strcat("\ncurl --pak ", pk3, "; wait; cl_cmd mv_download ", ftos(id), "\n"));
	}
	else
	{
		Cmd_MapVote_MapDownload(tokenize_console(strcat("mv_download ", ftos(id))));
	}
}

void MapVote_CheckPic(string pic, string pk3, float id)
{
	// never try to retrieve a pic for the "don't care" 'map'
	if(mv_abstain && id == mv_num_maps - 1)
		return;

	if(PreviewExists(pic))
	{
		mv_preview[id] = true;
		return;
	}
	MapVote_CheckPK3(pic, pk3, id);
}

void MapVote_ReadMask()
{
	float i;
	if ( mv_num_maps < 24 )
	{
		float mask, power;
		if(mv_num_maps < 8)
			mask = ReadByte();
		else if(mv_num_maps < 16)
			mask = ReadShort();
		else
			mask = ReadLong();
		
		for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
			mv_avail[i] = (mask & power) ? GTV_AVAILABLE : GTV_FORBIDDEN;
	}
	else
	{
		for(i = 0; i < mv_num_maps; ++i )
			mv_avail[i] = ReadByte();
	}
}

#define NUM_SSDIRS 4
string ssdirs[NUM_SSDIRS];
float n_ssdirs;
void MapVote_Init()
{
	float i, j;
	string map, pk3, s;

	precache_sound ("misc/invshot.wav");

	mv_active = 1;
	if(autocvar_hud_cursormode) { setcursormode(1); }
	else { mv_mousepos = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight; }
	mv_selection = -1;
	mv_selection_keyboard = 0;

	for(n_ssdirs = 0; ; ++n_ssdirs)
	{
		s = ReadString();
		if(s == "")
			break;
		if(n_ssdirs < NUM_SSDIRS)
			ssdirs[n_ssdirs] = s;
	}
	n_ssdirs = min(n_ssdirs, NUM_SSDIRS);

	mv_num_maps = min(MAPVOTE_COUNT, ReadByte());
	mv_abstain = ReadByte();
	if(mv_abstain)
		mv_abstain = 1; // must be 1 for bool-true, makes stuff easier
	mv_detail = ReadByte();

	mv_ownvote = -1;
	mv_timeout = ReadCoord();

	gametypevote = ReadByte();
	
	float mv_real_num_maps = mv_num_maps - mv_abstain;
	
	if ( gametypevote )
	{
		mapvote_choosenmap = strzone(ReadString());
		if ( gametypevote == 2 )
			gametypevote = 0;
	}

	if(gametypevote)
	{
		gtv_text_size = hud_fontsize*1.4;
		gtv_text_size_small = hud_fontsize*1.1;
		
		if (mv_real_num_maps > 8 )
			mv_columns = 3;
		else
			mv_columns = min(2, mv_real_num_maps);
    }
    else
	{
		if (mv_real_num_maps > 16)
			mv_columns = 5;
		else if (mv_real_num_maps > 9)
			mv_columns = 4;
		else if(mv_real_num_maps > 3)
			mv_columns = 3;
		else
			mv_columns = mv_real_num_maps;
	}

	MapVote_ReadMask();
	for(i = 0; i < mv_num_maps; ++i )
		mv_avail_start[i] = mv_avail[i];

	// Assume mv_pk3list is world, there should only be 1 mapvote per round
	mv_pk3list = world; // I'm still paranoid!

	for(i = 0; i < mv_num_maps; ++i)
	{
		mv_votes[i] = 0;

		map = strzone(ReadString());
		pk3 = strzone(ReadString());
		j = bound(0, ReadByte(), n_ssdirs - 1);

		mv_maps[i] = map;
		mv_pk3[i] = pk3;
		mv_avail[i] = ReadByte();

		if(gametypevote)
		{
			//map = strzone(strcat("gfx/menu/default/gametype_", map));
			//map = strzone(sprintf("gfx/menu/%s/gametype_%s", autocvar_menu_skin, map));
			string mv_picpath = sprintf("gfx/menu/%s/gametype_%s", autocvar_menu_skin, map);
			if(precache_pic(mv_picpath) == "")
				mv_picpath = strcat("gfx/menu/default/gametype_", map);
			map = strzone(mv_picpath);
			mv_pics[i] = map;
			mv_preview[i] = PreviewExists(map);
		}
		else
		{
			map = strzone(strcat(ssdirs[j], "/", map));
			mv_pics[i] = map;
			mv_preview[i] = false;
			MapVote_CheckPic(map, pk3, i);
		}
	}

	for(i = 0; i < n_ssdirs; ++i)
		ssdirs[n_ssdirs] = string_null;
	n_ssdirs = 0;
}

void MapVote_SendChoice(float index)
{
	localcmd(strcat("\nimpulse ", ftos(index+1), "\n"));
}

float MapVote_MoveLeft(float pos)
{
	float imp;
	if ( pos < 0 ) 
		imp = mv_num_maps - 1;
	else
		imp = pos < 1 ? mv_num_maps - 1 : pos - 1;
	if ( mv_avail[imp] != GTV_AVAILABLE && imp != mv_ownvote )
		imp = MapVote_MoveLeft(imp);
	return imp;
}
float MapVote_MoveRight(float pos)
{
	float imp;
	if ( pos < 0 ) 
		imp = 0;
	else
		imp = pos >= mv_num_maps - 1 ? 0 : pos + 1;
	if ( mv_avail[imp] != GTV_AVAILABLE && imp != mv_ownvote )
		imp = MapVote_MoveRight(imp);
	return imp;
}
float MapVote_MoveUp(float pos)
{
	float imp;
	if ( pos < 0 ) 
		imp = mv_num_maps - 1;
	else
	{
		imp = pos - mv_columns;
		if ( imp < 0 )
		{
			imp = floor(mv_num_maps/mv_columns)*mv_columns + pos % mv_columns;
			if ( imp >= mv_num_maps )
				imp -= mv_columns;
		}
	}
	if ( mv_avail[imp] != GTV_AVAILABLE && imp != mv_ownvote )
		imp = MapVote_MoveUp(imp);
	return imp;
}
float MapVote_MoveDown(float pos)
{
	float imp;
	if ( pos < 0 ) 
		imp = 0;
	else
	{
		imp = pos + mv_columns;
		if ( imp >= mv_num_maps )
			imp = imp % mv_columns;
	}
	if ( mv_avail[imp] != GTV_AVAILABLE && imp != mv_ownvote )
		imp = MapVote_MoveDown(imp);
	return imp;
}

float MapVote_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	float imp;

	if (!mv_active)
		return false;

	if(bInputType == 3)
	{
		mv_mousepos_x = nPrimary;
		mv_mousepos_y = nSecondary;
		mv_selection_keyboard = 0;
		return true;
	}

	if (bInputType != 0)
		return false;

	if ('0' <= nPrimary && nPrimary <= '9')
	{
		imp = nPrimary - '0';
		if (imp == 0) imp = 10;
		localcmd(strcat("\nimpulse ", ftos(imp), "\n"));
		return true;
	}
	switch(nPrimary)
	{
		case K_KP_1: localcmd("\nimpulse 1\n"); return true;
		case K_KP_2: localcmd("\nimpulse 2\n"); return true;
		case K_KP_3: localcmd("\nimpulse 3\n"); return true;
		case K_KP_4: localcmd("\nimpulse 4\n"); return true;
		case K_KP_5: localcmd("\nimpulse 5\n"); return true;
		case K_KP_6: localcmd("\nimpulse 6\n"); return true;
		case K_KP_7: localcmd("\nimpulse 7\n"); return true;
		case K_KP_8: localcmd("\nimpulse 8\n"); return true;
		case K_KP_9: localcmd("\nimpulse 9\n"); return true;
		case K_KP_0: localcmd("\nimpulse 10\n"); return true;

		case K_RIGHTARROW:
			mv_selection_keyboard = 1;
			mv_selection = MapVote_MoveRight(mv_selection);
			return true;
		case K_LEFTARROW:
			mv_selection_keyboard = 1;
			mv_selection = MapVote_MoveLeft(mv_selection);
			return true;
		case K_DOWNARROW:
			mv_selection_keyboard = 1;
			mv_selection = MapVote_MoveDown(mv_selection);
			return true;
		case K_UPARROW:
			mv_selection_keyboard = 1;
			mv_selection = MapVote_MoveUp(mv_selection);
			return true;
		case K_KP_ENTER:
		case K_ENTER:
		case K_SPACE:
			if ( mv_selection_keyboard )
				MapVote_SendChoice(mv_selection);
			return true;
	}

	if (nPrimary == K_MOUSE1)
	{
		mv_selection_keyboard = 0;
		mv_selection = mv_mouse_selection;
		if (mv_selection >= 0)
		{
			imp = min(mv_selection + 1, mv_num_maps);
			localcmd(strcat("\nimpulse ", ftos(imp), "\n"));
			return true;
		}
	}

	return false;
}

void MapVote_UpdateMask()
{
	MapVote_ReadMask();
	mv_top2_time = time;
}

void MapVote_UpdateVotes()
{
	float i;
	for(i = 0; i < mv_num_maps; ++i)
	{
		if(mv_avail[i] == GTV_AVAILABLE)
		{
			if(mv_detail)
				mv_votes[i] = ReadByte();
			else
				mv_votes[i] = 0;
		}
		else
			mv_votes[i] = -1;
	}

	mv_ownvote = ReadByte()-1;
}

void Ent_MapVote()
{
	float sf;

	sf = ReadByte();

	if(sf & 1)
		MapVote_Init();

	if(sf & 2)
		MapVote_UpdateMask();

	if(sf & 4)
		MapVote_UpdateVotes();
}

void Net_MapVote_Picture()
{
	float type;
	type = ReadByte();
	mv_preview[type] = true;
	mv_pics[type] = strzone(ReadPicture());
}
