#ifdef IMPLEMENTATION

void DrawDotCItem(vector myPos, vector mySize, float aspect_ratio, int i)
{
    TC(int, i);
	float stat = -1;
	float maxstat = -1;
	float curlevel = -1;
	string pic = "";
	vector color = '0 0 0';
	switch(i)
	{
		case 0:
		{
			curlevel = STAT(DOTC_CORE_LEVEL_RED);
			maxstat = STAT(DOTC_CORE_CREDITS_RED_MAX);
			stat = STAT(DOTC_CORE_CREDITS_RED);
			pic = "dom_icon_red";
			color = '1 0 0';
			break;
		}
		case 1:
		{
			curlevel = STAT(DOTC_CORE_LEVEL_BLUE);
			maxstat = STAT(DOTC_CORE_CREDITS_BLUE_MAX);
			stat = STAT(DOTC_CORE_CREDITS_BLUE);
			pic = "dom_icon_blue";
			color = '0 0 1';
			break;
		}
		case 2:
		{
			curlevel = STAT(DOTC_CORE_LEVEL_YELLOW);
			maxstat = STAT(DOTC_CORE_CREDITS_YELLOW_MAX);
			stat = STAT(DOTC_CORE_CREDITS_YELLOW);
			pic = "dom_icon_yellow";
			color = '1 1 0';
			break;
		}
		default:
		case 3: 
		{
			curlevel = STAT(DOTC_CORE_LEVEL_PINK);
			maxstat = STAT(DOTC_CORE_CREDITS_PINK_MAX);
			stat = STAT(DOTC_CORE_CREDITS_PINK);
			pic = "dom_icon_pink";
			color = '1 0 1';
			break;
		}
	}

	float ratio = stat / maxstat;

	if(mySize.x/mySize.y > aspect_ratio)
	{
		i = aspect_ratio * mySize.y;
		myPos.x = myPos.x + (mySize.x - i) / 2;
		mySize.x = i;
	}
	else
	{
		i = 1/aspect_ratio * mySize.x;
		myPos.y = myPos.y + (mySize.y - i) / 2;
		mySize.y = i;
	}

	//draw the text
	color *= 0.5 + ratio * (1 - 0.5); // half saturated color at min, full saturated at max
	drawstring_aspect(myPos + eX * mySize.y, ftos(curlevel), eX * (2/3) * mySize.x + eY * mySize.y, color, panel_fg_alpha, DRAWFLAG_NORMAL);

	//draw the icon
	drawpic_aspect_skin(myPos, pic, '1 1 0' * mySize.y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	if (stat > 0)
	{
		drawsetcliparea(myPos.x, myPos.y + mySize.y * (1 - ratio), mySize.y, mySize.y * ratio);
		drawpic_aspect_skin(myPos, strcat(pic, "-highlighted"), '1 1 0' * mySize.y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawresetcliparea();
	}
}

void HUD_Mod_DotC(vector myPos, vector mySize)
{
	mod_active = 1; // required in each mod function that always shows something

	int rows, columns;
	rows = HUD_GetRowCount(team_count, mySize, 1);
	columns = ceil(team_count/rows);

	int i;
	float row = 0, column = 0;
	vector pos, itemSize;
	itemSize = eX * mySize.x*(1/columns) + eY * mySize.y*(1/rows);
	for(i=0; i<team_count; ++i)
	{
		pos = myPos + eX * column * itemSize.x + eY * row * itemSize.y;

		DrawDotCItem(pos, itemSize, 1, i);

		++row;
		if(row >= rows)
		{
			row = 0;
			++column;
		}
	}
}

#endif
