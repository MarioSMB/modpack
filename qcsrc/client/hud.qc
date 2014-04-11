/*
==================
Misc HUD functions
==================
*/

// a border picture is a texture containing nine parts:
//   1/4 width: left part
//   1/2 width: middle part (stretched)
//   1/4 width: right part
// divided into
//   1/4 height: top part
//   1/2 height: middle part (stretched)
//   1/4 height: bottom part
void draw_BorderPicture(vector theOrigin, string pic, vector theSize, vector theColor, float theAlpha, vector theBorderSize)
{
    if (theBorderSize_x < 0 && theBorderSize_y < 0) // draw whole image as it is
    {
		drawpic(theOrigin, pic, theSize, theColor, theAlpha, 0);
		return;
    }
	if (theBorderSize_x == 0 && theBorderSize_y == 0) // no border
	{
		// draw only the central part
		drawsubpic(theOrigin, theSize, pic, '0.25 0.25 0', '0.5 0.5 0', theColor, theAlpha, 0);
		return;
	}

	vector dX, dY;
	vector width, height;
	vector bW, bH;
	//pic = draw_UseSkinFor(pic);
	width = eX * theSize_x;
	height = eY * theSize_y;
	if(theSize_x <= theBorderSize_x * 2)
	{
		// not wide enough... draw just left and right then
		bW = eX * (0.25 * theSize_x / (theBorderSize_x * 2));
		if(theSize_y <= theBorderSize_y * 2)
		{
			// not high enough... draw just corners
			bH = eY * (0.25 * theSize_y / (theBorderSize_y * 2));
			drawsubpic(theOrigin,                 width * 0.5 + height * 0.5, pic, '0 0 0',           bW + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width   * 0.5, width * 0.5 + height * 0.5, pic, eX - bW,           bW + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + height  * 0.5, width * 0.5 + height * 0.5, pic, eY - bH,           bW + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + theSize * 0.5, width * 0.5 + height * 0.5, pic, eX + eY - bW - bH, bW + bH, theColor, theAlpha, 0);
		}
		else
		{
			dY = theBorderSize_x * eY;
			drawsubpic(theOrigin,                             width * 0.5          +     dY, pic, '0 0    0',           '0 0.25 0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width * 0.5,               width * 0.5          +     dY, pic, '0 0    0' + eX - bW, '0 0.25 0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin                        + dY, width * 0.5 + height - 2 * dY, pic, '0 0.25 0',           '0 0.5  0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width * 0.5          + dY, width * 0.5 + height - 2 * dY, pic, '0 0.25 0' + eX - bW, '0 0.5  0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin               + height - dY, width * 0.5          +     dY, pic, '0 0.75 0',           '0 0.25 0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width * 0.5 + height - dY, width * 0.5          +     dY, pic, '0 0.75 0' + eX - bW, '0 0.25 0' + bW, theColor, theAlpha, 0);
		}
	}
	else
	{
		if(theSize_y <= theBorderSize_y * 2)
		{
			// not high enough... draw just top and bottom then
			bH = eY * (0.25 * theSize_y / (theBorderSize_y * 2));
			dX = theBorderSize_x * eX;
			drawsubpic(theOrigin,                                         dX + height * 0.5, pic, '0    0 0',           '0.25 0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + dX,                        width - 2 * dX + height * 0.5, pic, '0.25 0 0',           '0.5  0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width - dX,                            dX + height * 0.5, pic, '0.75 0 0',           '0.25 0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin              + height * 0.5,             dX + height * 0.5, pic, '0    0 0' + eY - bH, '0.25 0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + dX         + height * 0.5, width - 2 * dX + height * 0.5, pic, '0.25 0 0' + eY - bH, '0.5  0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width - dX + height * 0.5,             dX + height * 0.5, pic, '0.75 0 0' + eY - bH, '0.25 0 0' + bH, theColor, theAlpha, 0);
		}
		else
		{
			dX = theBorderSize_x * eX;
			dY = theBorderSize_x * eY;
			drawsubpic(theOrigin,                                        dX          +     dY, pic, '0    0    0', '0.25 0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin                  + dX,      width - 2 * dX          +     dY, pic, '0.25 0    0', '0.5  0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + width - dX,                  dX          +     dY, pic, '0.75 0    0', '0.25 0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + dY,                          dX + height - 2 * dY, pic, '0    0.25 0', '0.25 0.5  0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + dY         + dX, width - 2 * dX + height - 2 * dY, pic, '0.25 0.25 0', '0.5  0.5  0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + dY + width - dX,             dX + height - 2 * dY, pic, '0.75 0.25 0', '0.25 0.5  0', theColor, theAlpha, 0);
			drawsubpic(theOrigin + height - dY,                          dX          +     dY, pic, '0    0.75 0', '0.25 0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin + height - dY         + dX, width - 2 * dX          +     dY, pic, '0.25 0.75 0', '0.5  0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin + height - dY + width - dX,             dX          +     dY, pic, '0.75 0.75 0', '0.25 0.25 0', theColor, theAlpha, 0);
		}
	}
}

vector HUD_Get_Num_Color (float x, float maxvalue)
{
	float blinkingamt;
	vector color;
	if(x >= maxvalue) {
		color_x = sin(2*M_PI*time);
		color_y = 1;
		color_z = sin(2*M_PI*time);
	}
	else if(x > maxvalue * 0.75) {
		color_x = 0.4 - (x-150)*0.02 * 0.4; //red value between 0.4 -> 0
		color_y = 0.9 + (x-150)*0.02 * 0.1; // green value between 0.9 -> 1
		color_z = 0;
	}
	else if(x > maxvalue * 0.5) {
		color_x = 1 - (x-100)*0.02 * 0.6; //red value between 1 -> 0.4
		color_y = 1 - (x-100)*0.02 * 0.1; // green value between 1 -> 0.9
		color_z = 1 - (x-100)*0.02; // blue value between 1 -> 0
	}
	else if(x > maxvalue * 0.25) {
		color_x = 1;
		color_y = 1;
		color_z = 0.2 + (x-50)*0.02 * 0.8; // blue value between 0.2 -> 1
	}
	else if(x > maxvalue * 0.1) {
		color_x = 1;
		color_y = (x-20)*90/27/100; // green value between 0 -> 1
		color_z = (x-20)*90/27/100 * 0.2; // blue value between 0 -> 0.2
	}
	else {
		color_x = 1;
		color_y = 0;
		color_z = 0;
	}

	blinkingamt = (1 - x/maxvalue/0.25);
	if(blinkingamt > 0)
	{
		color_x = color_x - color_x * blinkingamt * sin(2*M_PI*time);
		color_y = color_y - color_y * blinkingamt * sin(2*M_PI*time);
		color_z = color_z - color_z * blinkingamt * sin(2*M_PI*time);
	}
	return color;
}

float stringwidth_colors(string s, vector theSize)
{
	return stringwidth(s, TRUE, theSize);
}

float stringwidth_nocolors(string s, vector theSize)
{
	return stringwidth(s, FALSE, theSize);
}

void drawstringright(vector position, string text, vector theScale, vector rgb, float theAlpha, float flag)
{
	position_x -= 2 / 3 * strlen(text) * theScale_x;
	drawstring(position, text, theScale, rgb, theAlpha, flag);
}

void drawstringcenter(vector position, string text, vector theScale, vector rgb, float theAlpha, float flag)
{
	position_x = 0.5 * (vid_conwidth - 0.6025 * strlen(text) * theScale_x);
	drawstring(position, text, theScale, rgb, theAlpha, flag);
}

// return the string of the onscreen race timer
string MakeRaceString(float cp, float mytime, float histime, float lapdelta, string hisname)
{
	string col;
	string timestr;
	string cpname;
	string lapstr;
	lapstr = "";

	if(histime == 0) // goal hit
	{
		if(mytime > 0)
		{
			timestr = strcat("+", ftos_decimals(+mytime, TIME_DECIMALS));
			col = "^1";
		}
		else if(mytime == 0)
		{
			timestr = "+0.0";
			col = "^3";
		}
		else
		{
			timestr = strcat("-", ftos_decimals(-mytime, TIME_DECIMALS));
			col = "^2";
		}

		if(lapdelta > 0)
		{
			lapstr = sprintf(_(" (-%dL)"), lapdelta);
			col = "^2";
		}
		else if(lapdelta < 0)
		{
			lapstr = sprintf(_(" (+%dL)"), -lapdelta);
			col = "^1";
		}
	}
	else if(histime > 0) // anticipation
	{
		if(mytime >= histime)
			timestr = strcat("+", ftos_decimals(mytime - histime, TIME_DECIMALS));
		else
			timestr = TIME_ENCODED_TOSTRING(TIME_ENCODE(histime));
		col = "^3";
	}
	else
	{
		col = "^7";
		timestr = "";
	}

	if(cp == 254)
		cpname = _("Start line");
	else if(cp == 255)
		cpname = _("Finish line");
	else if(cp)
		cpname = sprintf(_("Intermediate %d"), cp);
	else
		cpname = _("Finish line");

	if(histime < 0)
		return strcat(col, cpname);
	else if(hisname == "")
		return strcat(col, sprintf(_("%s (%s)"), cpname, timestr));
	else
		return strcat(col, sprintf(_("%s (%s %s)"), cpname, timestr, strcat(hisname, col, lapstr)));
}

// Check if the given name already exist in race rankings? In that case, where? (otherwise return 0)
float race_CheckName(string net_name) {
	float i;
	for (i=RANKINGS_CNT-1;i>=0;--i)
		if(grecordholder[i] == net_name)
			return i+1;
	return 0;
}

float GetPlayerColorForce(float i)
{
	if(!teamplay)
		return 0;
	else
		return stof(getplayerkeyvalue(i, "colors")) & 15;
}

float GetPlayerColor(float i)
{
	if(!playerslots[i].gotscores) // unconnected
		return NUM_SPECTATOR;
	else if(stof(getplayerkeyvalue(i, "frags")) == FRAGS_SPECTATOR)
		return NUM_SPECTATOR;
	else
		return GetPlayerColorForce(i);
}

string GetPlayerName(float i)
{
	return ColorTranslateRGB(getplayerkeyvalue(i, "name"));
}


/*
==================
HUD panels
==================
*/

// draw the background/borders
#define HUD_Panel_DrawBg(theAlpha)\
if(panel.current_panel_bg != "0" && panel.current_panel_bg != "")\
	draw_BorderPicture(panel_pos - '1 1 0' * panel_bg_border, panel.current_panel_bg, panel_size + '1 1 0' * 2 * panel_bg_border, panel_bg_color, panel_bg_alpha * theAlpha, '1 1 0' * (panel_bg_border/BORDER_MULTIPLIER))

//basically the same code of draw_ButtonPicture and draw_VertButtonPicture for the menu
void HUD_Panel_DrawProgressBar(vector theOrigin, vector theSize, string pic, float length_ratio, float vertical, float baralign, vector theColor, float theAlpha, float drawflag)
{
	if(!length_ratio || !theAlpha)
		return;
	if(length_ratio > 1)
		length_ratio = 1;
	if (baralign == 3)
	{
		if(length_ratio < -1)
			length_ratio = -1;
	}
	else if(length_ratio < 0)
		return;

	vector square;
	vector width, height;
	if(vertical) {
		pic = strcat(hud_skin_path, "/", pic, "_vertical");
		if(precache_pic(pic) == "") {
			pic = "gfx/hud/default/progressbar_vertical";
		}

        if (baralign == 1) // bottom align
			theOrigin_y += (1 - length_ratio) * theSize_y;
        else if (baralign == 2) // center align
            theOrigin_y += 0.5 * (1 - length_ratio) * theSize_y;
        else if (baralign == 3) // center align, positive values down, negative up
		{
			theSize_y *= 0.5;
			if (length_ratio > 0)
				theOrigin_y += theSize_y;
			else
			{
				theOrigin_y += (1 + length_ratio) * theSize_y;
				length_ratio = -length_ratio;
			}
		}
		theSize_y *= length_ratio;

		vector bH;
		width = eX * theSize_x;
		height = eY * theSize_y;
		if(theSize_y <= theSize_x * 2)
		{
			// button not high enough
			// draw just upper and lower part then
			square = eY * theSize_y * 0.5;
			bH = eY * (0.25 * theSize_y / (theSize_x * 2));
			drawsubpic(theOrigin,          square + width, pic, '0 0 0', eX + bH, theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + square, square + width, pic, eY - bH, eX + bH, theColor, theAlpha, drawflag);
		}
		else
		{
			square = eY * theSize_x;
			drawsubpic(theOrigin,                   width   +     square, pic, '0 0    0', '1 0.25 0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin +          square, theSize - 2 * square, pic, '0 0.25 0', '1 0.5  0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + height - square, width   +     square, pic, '0 0.75 0', '1 0.25 0', theColor, theAlpha, drawflag);
		}
	} else {
		pic = strcat(hud_skin_path, "/", pic);
		if(precache_pic(pic) == "") {
			pic = "gfx/hud/default/progressbar";
		}

		if (baralign == 1) // right align
			theOrigin_x += (1 - length_ratio) * theSize_x;
        else if (baralign == 2) // center align
            theOrigin_x += 0.5 * (1 - length_ratio) * theSize_x;
        else if (baralign == 3) // center align, positive values on the right, negative on the left
		{
			theSize_x *= 0.5;
			if (length_ratio > 0)
				theOrigin_x += theSize_x;
			else
			{
				theOrigin_x += (1 + length_ratio) * theSize_x;
				length_ratio = -length_ratio;
			}
		}
		theSize_x *= length_ratio;

		vector bW;
		width = eX * theSize_x;
		height = eY * theSize_y;
		if(theSize_x <= theSize_y * 2)
		{
			// button not wide enough
			// draw just left and right part then
			square = eX * theSize_x * 0.5;
			bW = eX * (0.25 * theSize_x / (theSize_y * 2));
			drawsubpic(theOrigin,          square + height, pic, '0 0 0', eY + bW, theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + square, square + height, pic, eX - bW, eY + bW, theColor, theAlpha, drawflag);
		}
		else
		{
			square = eX * theSize_y;
			drawsubpic(theOrigin,                  height  +     square, pic, '0    0 0', '0.25 1 0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin +         square, theSize - 2 * square, pic, '0.25 0 0', '0.5  1 0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + width - square, height  +     square, pic, '0.75 0 0', '0.25 1 0', theColor, theAlpha, drawflag);
		}
	}
}

void HUD_Panel_DrawHighlight(vector pos, vector mySize, vector color, float theAlpha, float drawflag)
{
	if(!theAlpha)
		return;

	string pic;
	pic = strcat(hud_skin_path, "/num_leading");
	if(precache_pic(pic) == "") {
		pic = "gfx/hud/default/num_leading";
	}

	drawsubpic(pos, eX * min(mySize_x * 0.5, mySize_y) + eY * mySize_y, pic, '0 0 0', '0.25 1 0', color, theAlpha, drawflag);
	if(mySize_x/mySize_y > 2)
		drawsubpic(pos + eX * mySize_y, eX * (mySize_x - 2 * mySize_y) + eY * mySize_y, pic, '0.25 0 0', '0.5 1 0', color, theAlpha, drawflag);
	drawsubpic(pos + eX * mySize_x - eX * min(mySize_x * 0.5, mySize_y), eX * min(mySize_x * 0.5, mySize_y) + eY * mySize_y, pic, '0.75 0 0', '0.25 1 0', color, theAlpha, drawflag);
}

// Weapon icons (#0)
//
entity weaponorder[WEP_MAXCOUNT];
void weaponorder_swap(float i, float j, entity pass)
{
	entity h;
	h = weaponorder[i];
	weaponorder[i] = weaponorder[j];
	weaponorder[j] = h;
}

string weaponorder_cmp_str;
float weaponorder_cmp(float i, float j, entity pass)
{
	float ai, aj;
	ai = strstrofs(weaponorder_cmp_str, sprintf(" %d ", weaponorder[i].weapon), 0);
	aj = strstrofs(weaponorder_cmp_str, sprintf(" %d ", weaponorder[j].weapon), 0);
	return aj - ai; // the string is in REVERSE order (higher prio at the right is what we want, but higher prio first is the string)
}

float GetAmmoStat(float i)
{
	switch(i)
	{
		case 0: return STAT_SHELLS;
		case 1: return STAT_NAILS;
		case 2: return STAT_ROCKETS;
		case 3: return STAT_CELLS;
		case 4: return STAT_FUEL;
		case 5: return STAT_SUPERCELLS;
		default: return -1;
	}
}

float GetAmmoTypeForWep(float i)
{
	switch(i)
	{
		case WEP_SHOTGUN: return 0;
		case WEP_UZI: return 1;
		case WEP_GRENADE_LAUNCHER: return 2;
		case WEP_MINE_LAYER: return 2;
		case WEP_ELECTRO: return 3;
		case WEP_CRYLINK: return 3;
		case WEP_HLAC: return 3;
		case WEP_MINSTANEX: return 3;
		case WEP_NEX: return 3;
		case WEP_RIFLE: return 1;
		case WEP_HAGAR: return 2;
		case WEP_ROCKET_LAUNCHER: return 2;
		case WEP_SEEKER: return 2;
		case WEP_FIREBALL: return 4;
		case WEP_HOOK: return 3;
		default: return -1;
	}
}

void HUD_Weapons(void)
{
	// declarations
	WepSet weapons_stat = WepSet_GetFromStat();
	float i, f, a;
	float screen_ar, center_x = 0, center_y;
	float weapon_count, weapon_id;
	float row, column, rows = 0, columns;
	float aspect = autocvar_hud_panel_weapons_aspect;

	float panel_weapon_accuracy;

	float timeout = autocvar_hud_panel_weapons_timeout;
	float timein_effect_length = autocvar_hud_panel_weapons_timeout_speed_in; //? 0.375 : 0);
	float timeout_effect_length = autocvar_hud_panel_weapons_timeout_speed_out; //? 0.75 : 0);

	float ammo_type, ammo_full;
	float barsize_x = 0, barsize_y = 0, baroffset_x = 0, baroffset_y = 0;
	vector ammo_color = '1 0 1';
	float ammo_alpha = 1;

	float when = max(1, autocvar_hud_panel_weapons_complainbubble_time);
	float fadetime = max(0, autocvar_hud_panel_weapons_complainbubble_fadetime);

	vector weapon_pos, weapon_size = '0 0 0';
	local noref vector old_panel_size; // fteqcc sucks
	vector color;

	// check to see if we want to continue
	if(hud != HUD_NORMAL) { return; }

	if(!autocvar__hud_configure)
	{
		if((!autocvar_hud_panel_weapons) || (spectatee_status == -1))
			return;
		if(timeout && time >= weapontime + timeout + timeout_effect_length)
		if(autocvar_hud_panel_weapons_timeout_effect == 3 || (autocvar_hud_panel_weapons_timeout_effect == 1 && !(autocvar_hud_panel_weapons_timeout_fadebgmin + autocvar_hud_panel_weapons_timeout_fadefgmin)))
		{
			weaponprevtime = time;
			return;
		}
	}

	// update generic hud functions
	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	// figure out weapon order (how the weapons are sorted) // TODO make this configurable
	if(weaponorder_bypriority != autocvar_cl_weaponpriority || !weaponorder[0])
	{
		float weapon_cnt;
		if(weaponorder_bypriority)
			strunzone(weaponorder_bypriority);
		if(weaponorder_byimpulse)
			strunzone(weaponorder_byimpulse);

		weaponorder_bypriority = strzone(autocvar_cl_weaponpriority);
		weaponorder_byimpulse = strzone(W_FixWeaponOrder_BuildImpulseList(W_FixWeaponOrder_ForceComplete(W_NumberWeaponOrder(weaponorder_bypriority))));
		weaponorder_cmp_str = strcat(" ", weaponorder_byimpulse, " ");

		weapon_cnt = 0;
		for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		{
			self = get_weaponinfo(i);
			if(self.impulse >= 0)
			{
				weaponorder[weapon_cnt] = self;
				++weapon_cnt;
			}
		}
		for(i = weapon_cnt; i < WEP_MAXCOUNT; ++i)
			weaponorder[i] = world;
		heapsort(weapon_cnt, weaponorder_swap, weaponorder_cmp, world);

		weaponorder_cmp_str = string_null;
	}

	if(!autocvar_hud_panel_weapons_complainbubble || autocvar__hud_configure || time - complain_weapon_time >= when + fadetime)
		complain_weapon = 0;

	// determine which weapons are going to be shown
	if (autocvar_hud_panel_weapons_onlyowned)
	{
		if(autocvar__hud_configure)
		{
			if (!weapons_stat)
				for(i = WEP_FIRST; i <= WEP_LAST; i += floor((WEP_LAST-WEP_FIRST)/5))
					weapons_stat |= WepSet_FromWeapon(i);

			if(menu_enabled != 2)
				HUD_Panel_DrawBg(1); // also draw the bg of the entire panel
		}

		// do we own this weapon?
		weapon_count = 0;
		for(i = 0; i <= WEP_LAST-WEP_FIRST; ++i)
			if(weapons_stat & WepSet_FromWeapon(weaponorder[i].weapon))
				++weapon_count;

		// add it anyway if weaponcomplain is shown
		if(complain_weapon)
			++weapon_count;

		// might as well commit suicide now, no reason to live ;)
		if (weapon_count == 0)
		{
			draw_endBoldFont();
			return;
		}

		old_panel_size = panel_size;
		if(panel_bg_padding)
			old_panel_size -= '2 2 0' * panel_bg_padding;

		// first find values for the standard table (with all the weapons)
		rows = old_panel_size_y/old_panel_size_x;
		rows = bound(1, floor((sqrt(4 * aspect * rows * WEP_COUNT + rows * rows) + rows + 0.5) / 2), WEP_COUNT);
		columns = ceil(WEP_COUNT/rows);
		weapon_size_x = old_panel_size_x / columns;
		weapon_size_y = old_panel_size_y / rows;

		// change table values to include only the owned weapons
		float columns_save = columns;
		if(weapon_count <= rows)
		{
			rows = weapon_count;
			columns = 1;
		}
		else
			columns = ceil(weapon_count / rows);

		// enlarge weapon_size to match desired aspect ratio in order to capitalize on panel space
		if(columns < columns_save)
			weapon_size_x = min(old_panel_size_x / columns, aspect * weapon_size_y);

		// reduce size of the panel
		panel_size_x = columns * weapon_size_x;
		panel_size_y = rows * weapon_size_y;
		panel_pos_x += (old_panel_size_x - panel_size_x) / 2;
		panel_pos_y += (old_panel_size_y - panel_size_y) / 2;
		if(panel_bg_padding)
			panel_size += '2 2 0' * panel_bg_padding;
	}
	else
		weapon_count = WEP_COUNT;

	// animation for fading in/out the panel respectively when not in use
	if(!autocvar__hud_configure)
	{
		if (timeout && time >= weapontime + timeout) // apply timeout effect if needed
		{
			f = bound(0, (time - (weapontime + timeout)) / timeout_effect_length, 1);

			// fade the panel alpha
			if(autocvar_hud_panel_weapons_timeout_effect == 1)
			{
				panel_bg_alpha *= (autocvar_hud_panel_weapons_timeout_fadebgmin * f + (1 - f));
				panel_fg_alpha *= (autocvar_hud_panel_weapons_timeout_fadefgmin * f + (1 - f));
			}
			else if(autocvar_hud_panel_weapons_timeout_effect == 3)
			{
				panel_bg_alpha *= (1 - f);
				panel_fg_alpha *= (1 - f);
			}

			// move the panel off the screen
			if (autocvar_hud_panel_weapons_timeout_effect == 2 || autocvar_hud_panel_weapons_timeout_effect == 3)
			{
				f *= f; // for a cooler movement
				center_x = panel_pos_x + panel_size_x/2;
				center_y = panel_pos_y + panel_size_y/2;
				screen_ar = vid_conwidth/vid_conheight;
				if (center_x/center_y < screen_ar) //bottom left
				{
					if ((vid_conwidth - center_x)/center_y < screen_ar) //bottom
						panel_pos_y += f * (vid_conheight - panel_pos_y);
					else //left
						panel_pos_x -= f * (panel_pos_x + panel_size_x);
				}
				else //top right
				{
					if ((vid_conwidth - center_x)/center_y < screen_ar) //right
						panel_pos_x += f * (vid_conwidth - panel_pos_x);
					else //top
						panel_pos_y -= f * (panel_pos_y + panel_size_y);
				}
				if(f == 1)
					center_x = -1; // mark the panel as off screen
			}
			weaponprevtime = time - (1 - f) * timein_effect_length;
		}
		else if (timeout && time < weaponprevtime + timein_effect_length) // apply timein effect if needed
		{
			f = bound(0, (time - weaponprevtime) / timein_effect_length, 1);

			// fade the panel alpha
			if(autocvar_hud_panel_weapons_timeout_effect == 1)
			{
				panel_bg_alpha *= (autocvar_hud_panel_weapons_timeout_fadebgmin * (1 - f) + f);
				panel_fg_alpha *= (autocvar_hud_panel_weapons_timeout_fadefgmin * (1 - f) + f);
			}
			else if(autocvar_hud_panel_weapons_timeout_effect == 3)
			{
				panel_bg_alpha *= (f);
				panel_fg_alpha *= (f);
			}

			// move the panel back on screen
			if (autocvar_hud_panel_weapons_timeout_effect == 2 || autocvar_hud_panel_weapons_timeout_effect == 3)
			{
				f *= f; // for a cooler movement
				f = 1 - f;
				center_x = panel_pos_x + panel_size_x/2;
				center_y = panel_pos_y + panel_size_y/2;
				screen_ar = vid_conwidth/vid_conheight;
				if (center_x/center_y < screen_ar) //bottom left
				{
					if ((vid_conwidth - center_x)/center_y < screen_ar) //bottom
						panel_pos_y += f * (vid_conheight - panel_pos_y);
					else //left
						panel_pos_x -= f * (panel_pos_x + panel_size_x);
				}
				else //top right
				{
					if ((vid_conwidth - center_x)/center_y < screen_ar) //right
						panel_pos_x += f * (vid_conwidth - panel_pos_x);
					else //top
						panel_pos_y -= f * (panel_pos_y + panel_size_y);
				}
			}
		}
	}

	// draw the background, then change the virtual size of it to better fit other items inside
	HUD_Panel_DrawBg(1);

	if(center_x == -1)
	{
		draw_endBoldFont();
		return;
	}

	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	// after the sizing and animations are done, update the other values

	if(!rows) // if rows is > 0 onlyowned code has already updated these vars
	{
		rows = panel_size_y/panel_size_x;
		rows = bound(1, floor((sqrt(4 * aspect * rows * weapon_count + rows * rows) + rows + 0.5) / 2), weapon_count);
		columns = ceil(weapon_count/rows);
		weapon_size = eX * panel_size_x*(1/columns) + eY * panel_size_y*(1/rows);
	}

	// calculate position/size for visual bar displaying ammount of ammo status
	if (autocvar_hud_panel_weapons_ammo)
	{
		ammo_color = stov(autocvar_hud_panel_weapons_ammo_color);
		ammo_alpha = panel_fg_alpha * autocvar_hud_panel_weapons_ammo_alpha;

		if(weapon_size_x/weapon_size_y > aspect)
		{
			barsize_x = aspect * weapon_size_y;
			barsize_y = weapon_size_y;
			baroffset_x = (weapon_size_x - barsize_x) / 2;
		}
		else
		{
			barsize_y = 1/aspect * weapon_size_x;
			barsize_x = weapon_size_x;
			baroffset_y = (weapon_size_y - barsize_y) / 2;
		}
	}
	if(autocvar_hud_panel_weapons_accuracy)
		Accuracy_LoadColors();

	row = column = 0;
	for(i = 0; i <= WEP_LAST-WEP_FIRST; ++i)
	{
		// retrieve information about the current weapon to be drawn
		self = weaponorder[i];
		weapon_id = self.impulse;

		// skip if this weapon doesn't exist
		if(!self || weapon_id < 0) { continue; }

		// skip this weapon if we don't own it (and onlyowned is enabled)-- or if weapons_complainbubble is showing for this weapon
		if(autocvar_hud_panel_weapons_onlyowned)
		if (!((weapons_stat & WepSet_FromWeapon(self.weapon)) || (self.weapon == complain_weapon)))
			continue;

		// figure out the drawing position of weapon
		weapon_pos = (panel_pos
			+ eX * column * weapon_size_x
			+ eY * row * weapon_size_y);

		// draw background behind currently selected weapon
		if(self.weapon == switchweapon)
			drawpic_aspect_skin(weapon_pos, "weapon_current_bg", weapon_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);

		// draw the weapon accuracy
		if(autocvar_hud_panel_weapons_accuracy)
		{
			panel_weapon_accuracy = weapon_accuracy[self.weapon-WEP_FIRST];
			if(panel_weapon_accuracy >= 0)
			{
				color = Accuracy_GetColor(panel_weapon_accuracy);
				drawpic_aspect_skin(weapon_pos, "weapon_accuracy", weapon_size, color, panel_fg_alpha, DRAWFLAG_NORMAL);
			}
		}

		// drawing all the weapon items
		if(weapons_stat & WepSet_FromWeapon(self.weapon))
		{
			// draw the weapon image
			drawpic_aspect_skin(weapon_pos, strcat("weapon", self.netname), weapon_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);

			// draw weapon label string
			switch(autocvar_hud_panel_weapons_label)
			{
				case 1: // weapon number
					drawstring(weapon_pos, ftos(weapon_id), '1 1 0' * 0.5 * weapon_size_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
					break;

				case 2: // bind
					drawstring(weapon_pos, getcommandkey(ftos(weapon_id), strcat("weapon_group_", ftos(weapon_id))), '1 1 0' * 0.5 * weapon_size_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
					break;

				case 3: // weapon name
					drawstring(weapon_pos, self.netname, '1 1 0' * 0.5 * weapon_size_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
					break;

				default: // nothing
					break;
			}

			// draw ammo status bar
			if(autocvar_hud_panel_weapons_ammo && self.weapon != WEP_TUBA && self.weapon != WEP_LASER && self.weapon != WEP_PORTO)
			{
				a = 0;
				ammo_type = GetAmmoTypeForWep(self.weapon);
				if(ammo_type != -1)
					a = getstati(GetAmmoStat(ammo_type)); // how much ammo do we have?

				if(a > 0)
				{
					switch(ammo_type) {
						case 0: ammo_full = autocvar_hud_panel_weapons_ammo_full_shells; break;
						case 1: ammo_full = autocvar_hud_panel_weapons_ammo_full_nails; break;
						case 2: ammo_full = autocvar_hud_panel_weapons_ammo_full_rockets; break;
						case 3: ammo_full = autocvar_hud_panel_weapons_ammo_full_cells; break;
						case 4: ammo_full = autocvar_hud_panel_weapons_ammo_full_fuel; break;
						case 5: ammo_full = autocvar_hud_panel_weapons_ammo_full_cells; break;
						default: ammo_full = 60;
					}

					drawsetcliparea(
						weapon_pos_x + baroffset_x,
						weapon_pos_y + baroffset_y,
						barsize_x * bound(0, a/ammo_full, 1),
						barsize_y);
					drawpic_aspect_skin(weapon_pos, "weapon_ammo", weapon_size, ammo_color, ammo_alpha, DRAWFLAG_NORMAL);
					drawresetcliparea();
				}
			}
		}
		else // draw a "ghost weapon icon" if you don't have the weapon
		{
			drawpic_aspect_skin(weapon_pos, strcat("weapon", self.netname), weapon_size, '0 0 0', panel_fg_alpha * 0.5, DRAWFLAG_NORMAL);
		}

		// draw the complain message
		if(self.weapon == complain_weapon)
		{
			if(fadetime)
				a = ((complain_weapon_time + when > time) ? 1 : bound(0, (complain_weapon_time + when + fadetime - time) / fadetime, 1));
			else
				a = ((complain_weapon_time + when > time) ? 1 : 0);

			string s;
			if(complain_weapon_type == 0) {
				s = _("Out of ammo");
				color = stov(autocvar_hud_panel_weapons_complainbubble_color_outofammo);
			}
			else if(complain_weapon_type == 1) {
				s = _("Don't have");
				color = stov(autocvar_hud_panel_weapons_complainbubble_color_donthave);
			}
			else {
				s = _("Unavailable");
				color = stov(autocvar_hud_panel_weapons_complainbubble_color_unavailable);
			}
			float padding = autocvar_hud_panel_weapons_complainbubble_padding;
			drawpic_aspect_skin(weapon_pos + '1 1 0' * padding, "weapon_complainbubble", weapon_size - '2 2 0' * padding, color, a * panel_fg_alpha, DRAWFLAG_NORMAL);
			drawstring_aspect(weapon_pos + '1 1 0' * padding, s, weapon_size - '2 2 0' * padding, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
		}

		// continue with new position for the next weapon
		++row;
		if(row >= rows)
		{
			row = 0;
			++column;
		}
	}

	draw_endBoldFont();
}

// Ammo (#1)
//
// TODO: macro
float GetAmmoItemCode(float i)
{
	switch(i)
	{
		case 0: return IT_SHELLS;
		case 1: return IT_NAILS;
		case 2: return IT_ROCKETS;
		case 3: return IT_CELLS;
		case 4: return IT_FUEL;
		case 5: return IT_SUPERCELLS;
		default: return -1;
	}
}

string GetAmmoPicture(float i)
{
	switch(i)
	{
		case 0: return "ammo_shells";
		case 1: return "ammo_bullets";
		case 2: return "ammo_rockets";
		case 3: return "ammo_cells";
		case 4: return "ammo_fuel";
		case 5: return "ammo_supercells";
		default: return "";
	}
}

void DrawNadeScoreBar(vector myPos, vector mySize, vector color)
{
	
	HUD_Panel_DrawProgressBar(
		myPos + eX * autocvar_hud_panel_ammo_progressbar_xoffset * mySize_x, 
		mySize - eX * autocvar_hud_panel_ammo_progressbar_xoffset * mySize_x, 
		autocvar_hud_panel_ammo_progressbar_name, 
		getstatf(STAT_NADE_BONUS_SCORE), 0, 0, color, 
		autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);

}

void DrawAmmoNades(vector myPos, vector mySize, float draw_expanding, float expand_time)
{
	float theAlpha = 1, a, b;
	vector nade_color, picpos, numpos;
	
	nade_color = Nade_Color(getstati(STAT_NADE_BONUS_TYPE));
	
	a = getstatf(STAT_NADE_BONUS);
	b = getstatf(STAT_NADE_BONUS_SCORE);
	
	if(autocvar_hud_panel_ammo_iconalign)
	{
		numpos = myPos;
		picpos = myPos + eX * 2 * mySize_y;
	}
	else
	{
		numpos = myPos + eX * mySize_y;
		picpos = myPos;
	}

	DrawNadeScoreBar(myPos, mySize, nade_color);

	if(b > 0 || a > 0)
	{
		if(autocvar_hud_panel_ammo_text)
			drawstring_aspect(numpos, ftos(a), eX * (2/3) * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
		
		if(draw_expanding)
			drawpic_aspect_skin_expanding(picpos, "nade_nbg", '1 1 0' * mySize_y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL, expand_time);
			
		drawpic_aspect_skin(picpos, "nade_bg" , '1 1 0' * mySize_y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
		drawpic_aspect_skin(picpos, "nade_nbg" , '1 1 0' * mySize_y, nade_color, panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
	}
}

void DrawAmmoItem(vector myPos, vector mySize, float itemcode, float currently_selected, float infinite_ammo)
{
	float a;
	if(autocvar__hud_configure)
	{
		currently_selected = (itemcode == 2); //rockets always selected
		a = 31 + mod(itemcode*93, 128);
	}
	else
		a = getstati(GetAmmoStat(itemcode)); // how much ammo do we have of type itemcode?

	vector color;
	if(infinite_ammo)
		color = '0 0.5 0.75';
	else if(a < 10)
		color = '0.7 0 0';
	else
		color = '1 1 1';

	float theAlpha;
	if(currently_selected)
		theAlpha = 1;
	else
		theAlpha = 0.7;

	vector picpos, numpos;
	if(autocvar_hud_panel_ammo_iconalign)
	{
		numpos = myPos;
		picpos = myPos + eX * 2 * mySize_y;
	}
	else
	{
		numpos = myPos + eX * mySize_y;
		picpos = myPos;
	}

	if (currently_selected)
		drawpic_aspect_skin(myPos, "ammo_current_bg", mySize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);

    if(a > 0 && autocvar_hud_panel_ammo_progressbar)
        HUD_Panel_DrawProgressBar(myPos + eX * autocvar_hud_panel_ammo_progressbar_xoffset * mySize_x, mySize - eX * autocvar_hud_panel_ammo_progressbar_xoffset * mySize_x, autocvar_hud_panel_ammo_progressbar_name, a/autocvar_hud_panel_ammo_maxammo, 0, 0, color, autocvar_hud_progressbar_alpha * panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);

    if(autocvar_hud_panel_ammo_text)
    {
        if(a > 0 || infinite_ammo)
            drawstring_aspect(numpos, ftos(a), eX * (2/3) * mySize_x + eY * mySize_y, color, panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
        else // "ghost" ammo count
            drawstring_aspect(numpos, ftos(a), eX * (2/3) * mySize_x + eY * mySize_y, '0 0 0', panel_fg_alpha * theAlpha * 0.5, DRAWFLAG_NORMAL);
    }
	if(a > 0 || infinite_ammo)
		drawpic_aspect_skin(picpos, GetAmmoPicture(itemcode), '1 1 0' * mySize_y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
	else // "ghost" ammo icon
		drawpic_aspect_skin(picpos, GetAmmoPicture(itemcode), '1 1 0' * mySize_y, '0 0 0', panel_fg_alpha * theAlpha * 0.5, DRAWFLAG_NORMAL);
}

float nade_prevstatus;
float nade_prevframe;
float nade_statuschange_time;
void HUD_Ammo(void)
{
	if(hud != HUD_NORMAL) return;
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_ammo) return;
		if(spectatee_status == -1) return;
	}

	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float rows = 0, columns, row, column;
	float nade_cnt = getstatf(STAT_NADE_BONUS), nade_score = getstatf(STAT_NADE_BONUS_SCORE);
	float draw_nades = (nade_cnt > 0 || nade_score > 0), nade_statuschange_elapsedtime;
	float total_ammo_count;

	vector ammo_size;
	if (autocvar_hud_panel_ammo_onlycurrent)
		total_ammo_count = 1;
	else
		total_ammo_count = AMMO_COUNT - 1; // fuel

	if(draw_nades)
	{
		++total_ammo_count;
		if (nade_cnt != nade_prevframe)
		{
			nade_statuschange_time = time;
			nade_prevstatus = nade_prevframe;
			nade_prevframe = nade_cnt;
		}
	}
	else
		nade_prevstatus = nade_prevframe = nade_statuschange_time = 0;

	rows = mySize_y/mySize_x;
	rows = bound(1, floor((sqrt(4 * (3/1) * rows * (total_ammo_count) + rows * rows) + rows + 0.5) / 2), (total_ammo_count));
	//                               ^^^ ammo item aspect goes here

	columns = ceil((total_ammo_count)/rows);

	ammo_size = eX * mySize_x*(1/columns) + eY * mySize_y*(1/rows);
	

	local vector offset = '0 0 0'; // fteqcc sucks
	float newSize;
	if(ammo_size_x/ammo_size_y > 3)
	{
		newSize = 3 * ammo_size_y;
		offset_x = ammo_size_x - newSize;
		pos_x += offset_x/2;
		ammo_size_x = newSize;
	}
	else
	{
		newSize = 1/3 * ammo_size_x;
		offset_y = ammo_size_y - newSize;
		pos_y += offset_y/2;
		ammo_size_y = newSize;
	}

	float i, stat_items, currently_selected, infinite_ammo;
	infinite_ammo = FALSE;

	row = column = 0;

	if (autocvar_hud_panel_ammo_onlycurrent)
	{
		if(autocvar__hud_configure)
		{
			DrawAmmoItem(pos, ammo_size, 2, true, FALSE); //show rockets
		}
		else
		{
			stat_items = getstati(STAT_ITEMS, 0, 24);
			if (stat_items & IT_UNLIMITED_WEAPON_AMMO)
				infinite_ammo = TRUE;
			for (i = 0; i < AMMO_COUNT; ++i) {
				if(i == 4) continue; // fuel
				currently_selected = stat_items & GetAmmoItemCode(i);
				if (currently_selected)
				{
					DrawAmmoItem(pos, ammo_size, i, true, infinite_ammo);
					break;
				}
			}
		}

		++row;
		if(row >= rows)
		{
			row = 0;
			column = column + 1;
		}
	}
	else
	{
		stat_items = getstati(STAT_ITEMS, 0, 24);
		if (stat_items & IT_UNLIMITED_WEAPON_AMMO)
			infinite_ammo = TRUE;
		for (i = 0; i < AMMO_COUNT; ++i) {
			if(i == 4) continue; // fuel
			currently_selected = stat_items & GetAmmoItemCode(i);
			DrawAmmoItem(pos + eX * column * (ammo_size_x + offset_x) + eY * row * (ammo_size_y + offset_y), ammo_size, i, currently_selected, infinite_ammo);
			++row;
			if(row >= rows)
			{
				row = 0;
				column = column + 1;
			}
		}
	}

	if (draw_nades)
	{
		nade_statuschange_elapsedtime = time - nade_statuschange_time;

		float f = bound(0, nade_statuschange_elapsedtime*2, 1);

		DrawAmmoNades(pos + eX * column * (ammo_size_x + offset_x) + eY * row * (ammo_size_y + offset_y), ammo_size, nade_prevstatus < nade_cnt && nade_cnt != 0 && f < 1, f);
	}

	draw_endBoldFont();
}

void DrawNumIcon_expanding(vector myPos, vector mySize, float x, string icon, float vertical, float icon_right_align, vector color, float theAlpha, float fadelerp)
{
	vector newPos = '0 0 0', newSize = '0 0 0';
	vector picpos, numpos;

	if (vertical)
	{
		if(mySize_y/mySize_x > 2)
		{
			newSize_y = 2 * mySize_x;
			newSize_x = mySize_x;

			newPos_y = myPos_y + (mySize_y - newSize_y) / 2;
			newPos_x = myPos_x;
		}
		else
		{
			newSize_x = 1/2 * mySize_y;
			newSize_y = mySize_y;

			newPos_x = myPos_x + (mySize_x - newSize_x) / 2;
			newPos_y = myPos_y;
		}

		if(icon_right_align)
		{
			numpos = newPos;
			picpos = newPos + eY * newSize_x;
		}
		else
		{
			picpos = newPos;
			numpos = newPos + eY * newSize_x;
		}

		newSize_y /= 2;
		drawpic_aspect_skin(picpos, icon, newSize, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
		// make number smaller than icon, it looks better
		// reduce only y to draw numbers with different number of digits with the same y size
		numpos_y += newSize_y * ((1 - 0.7) / 2);
		newSize_y *= 0.7;
		drawstring_aspect(numpos, ftos(x), newSize, color, panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
		return;
	}

	if(mySize_x/mySize_y > 3)
	{
		newSize_x = 3 * mySize_y;
		newSize_y = mySize_y;

		newPos_x = myPos_x + (mySize_x - newSize_x) / 2;
		newPos_y = myPos_y;
	}
	else
	{
		newSize_y = 1/3 * mySize_x;
		newSize_x = mySize_x;

		newPos_y = myPos_y + (mySize_y - newSize_y) / 2;
		newPos_x = myPos_x;
	}

	if(icon_right_align) // right align
	{
		numpos = newPos;
		picpos = newPos + eX * 2 * newSize_y;
	}
	else // left align
	{
		numpos = newPos + eX * newSize_y;
		picpos = newPos;
	}

	// NOTE: newSize_x is always equal to 3 * mySize_y so we can use
	// '2 1 0' * newSize_y instead of eX * (2/3) * newSize_x + eY * newSize_y
	drawstring_aspect_expanding(numpos, ftos(x), '2 1 0' * newSize_y, color, panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL, fadelerp);
	drawpic_aspect_skin_expanding(picpos, icon, '1 1 0' * newSize_y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL, fadelerp);
}

void DrawNumIcon(vector myPos, vector mySize, float x, string icon, float vertical, float icon_right_align, vector color, float theAlpha)
{
	DrawNumIcon_expanding(myPos, mySize, x, icon, vertical, icon_right_align, color, theAlpha, 0);
}

// Powerups (#2)
//
void HUD_Powerups(void)
{
	float strength_time, shield_time, superweapons_time;
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_powerups) return;
		if(spectatee_status == -1) return;
		if(!(getstati(STAT_ITEMS, 0, 24) & (IT_STRENGTH | IT_INVINCIBLE | IT_SUPERWEAPON))) return;
		if (getstati(STAT_HEALTH) <= 0) return;

		strength_time = bound(0, getstatf(STAT_STRENGTH_FINISHED) - time, 99);
		shield_time = bound(0, getstatf(STAT_INVINCIBLE_FINISHED) - time, 99);
		superweapons_time = bound(0, getstatf(STAT_SUPERWEAPONS_FINISHED) - time, 99);

		if (getstati(STAT_ITEMS, 0, 24) & IT_UNLIMITED_SUPERWEAPONS)
			superweapons_time = 99; // force max

		// prevent stuff to show up on mismatch that will be fixed next frame
		if (!(getstati(STAT_ITEMS, 0, 24) & IT_SUPERWEAPON))
			superweapons_time = 0;
	}
	else
	{
		strength_time = 15;
		shield_time = 27;
		superweapons_time = 13;
	}

	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(bound(0, max(strength_time, shield_time, superweapons_time), 1));
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float panel_ar = mySize_x/mySize_y;
	float is_vertical = (panel_ar < 1);
	vector shield_offset = '0 0 0', strength_offset = '0 0 0', superweapons_offset = '0 0 0';

	float superweapons_is = -1;

	if(superweapons_time)
	{
		if(strength_time)
		{
			if(shield_time)
				superweapons_is = 0;
			else
				superweapons_is = 2;
		}
		else
		{
			if(shield_time)
				superweapons_is = 1;
			else
				superweapons_is = 2;
		}
	}

	// FIXME handle superweapons here
	if(superweapons_is == 0)
	{
		if (panel_ar >= 4 || (panel_ar >= 1/4 && panel_ar < 1))
		{
			mySize_x *= (1.0 / 3.0);
			superweapons_offset_x = mySize_x;
			if (autocvar_hud_panel_powerups_flip)
				shield_offset_x = 2*mySize_x;
			else
				strength_offset_x = 2*mySize_x;
		}
		else
		{
			mySize_y *= (1.0 / 3.0);
			superweapons_offset_y = mySize_y;
			if (autocvar_hud_panel_powerups_flip)
				shield_offset_y = 2*mySize_y;
			else
				strength_offset_y = 2*mySize_y;
		}
	}
	else
	{
		if (panel_ar >= 4 || (panel_ar >= 1/4 && panel_ar < 1))
		{
			mySize_x *= 0.5;
			if (autocvar_hud_panel_powerups_flip)
				shield_offset_x = mySize_x;
			else
				strength_offset_x = mySize_x;
		}
		else
		{
			mySize_y *= 0.5;
			if (autocvar_hud_panel_powerups_flip)
				shield_offset_y = mySize_y;
			else
				strength_offset_y = mySize_y;
		}
	}

	float shield_baralign, strength_baralign, superweapons_baralign;
	float shield_iconalign, strength_iconalign, superweapons_iconalign;

	if (autocvar_hud_panel_powerups_flip)
	{
		strength_baralign = (autocvar_hud_panel_powerups_baralign == 2 || autocvar_hud_panel_powerups_baralign == 1);
		shield_baralign = (autocvar_hud_panel_powerups_baralign == 3 || autocvar_hud_panel_powerups_baralign == 1);
		strength_iconalign = (autocvar_hud_panel_powerups_iconalign == 2 || autocvar_hud_panel_powerups_iconalign == 1);
		shield_iconalign = (autocvar_hud_panel_powerups_iconalign == 3 || autocvar_hud_panel_powerups_iconalign == 1);
	}
	else
	{
		shield_baralign = (autocvar_hud_panel_powerups_baralign == 2 || autocvar_hud_panel_powerups_baralign == 1);
		strength_baralign = (autocvar_hud_panel_powerups_baralign == 3 || autocvar_hud_panel_powerups_baralign == 1);
		shield_iconalign = (autocvar_hud_panel_powerups_iconalign == 2 || autocvar_hud_panel_powerups_iconalign == 1);
		strength_iconalign = (autocvar_hud_panel_powerups_iconalign == 3 || autocvar_hud_panel_powerups_iconalign == 1);
	}

	if(superweapons_is == 0)
	{
		superweapons_iconalign = strength_iconalign;
		superweapons_baralign = 2;
	}
	else if(superweapons_is == 1)
	{
		superweapons_offset = strength_offset;
		superweapons_iconalign = strength_iconalign;
		superweapons_baralign = strength_baralign;
	}
	else // if(superweapons_is == 2)
	{
		superweapons_offset = shield_offset;
		superweapons_iconalign = shield_iconalign;
		superweapons_baralign = shield_baralign;
	}

	if(shield_time)
	{
		const float maxshield = 30;
		float shield = ceil(shield_time);
		if(autocvar_hud_panel_powerups_progressbar)
			HUD_Panel_DrawProgressBar(pos + shield_offset, mySize, autocvar_hud_panel_powerups_progressbar_shield, shield/maxshield, is_vertical, shield_baralign, autocvar_hud_progressbar_shield_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
		if(autocvar_hud_panel_powerups_text)
		{
			if(shield > 1)
				DrawNumIcon(pos + shield_offset, mySize, shield, "shield", is_vertical, shield_iconalign, '1 1 1', 1);
			if(shield <= 5)
				DrawNumIcon_expanding(pos + shield_offset, mySize, shield, "shield", is_vertical, shield_iconalign, '1 1 1', 1, bound(0, (shield - shield_time) / 0.5, 1));
		}
	}

	if(strength_time)
	{
		const float maxstrength = 30;
		float strength = ceil(strength_time);
		if(autocvar_hud_panel_powerups_progressbar)
			HUD_Panel_DrawProgressBar(pos + strength_offset, mySize, autocvar_hud_panel_powerups_progressbar_strength, strength/maxstrength, is_vertical, strength_baralign, autocvar_hud_progressbar_strength_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
		if(autocvar_hud_panel_powerups_text)
		{
			if(strength > 1)
				DrawNumIcon(pos + strength_offset, mySize, strength, "strength", is_vertical, strength_iconalign, '1 1 1', 1);
			if(strength <= 5)
				DrawNumIcon_expanding(pos + strength_offset, mySize, strength, "strength", is_vertical, strength_iconalign, '1 1 1', 1, bound(0, (strength - strength_time) / 0.5, 1));
		}
	}

	if(superweapons_time)
	{
		const float maxsuperweapons = 30;
		float superweapons = ceil(superweapons_time);
		if(autocvar_hud_panel_powerups_progressbar)
			HUD_Panel_DrawProgressBar(pos + superweapons_offset, mySize, autocvar_hud_panel_powerups_progressbar_superweapons, superweapons/maxsuperweapons, is_vertical, superweapons_baralign, autocvar_hud_progressbar_superweapons_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
		if(autocvar_hud_panel_powerups_text)
		{
			if(superweapons > 1)
				DrawNumIcon(pos + superweapons_offset, mySize, superweapons, "superweapons", is_vertical, superweapons_iconalign, '1 1 1', 1);
			if(superweapons <= 5)
				DrawNumIcon_expanding(pos + superweapons_offset, mySize, superweapons, "superweapons", is_vertical, superweapons_iconalign, '1 1 1', 1, bound(0, (superweapons - superweapons_time) / 0.5, 1));
		}
	}

	draw_endBoldFont();
}

// Health/armor (#3)
//

// prev_* vars contain the health/armor at the previous FRAME
// set to -1 when player is dead or was not playing
float prev_health, prev_armor;
float health_damagetime, armor_damagetime;
float health_beforedamage, armor_beforedamage;
// old_p_* vars keep track of previous values when smoothing value changes of the progressbar
float old_p_health, old_p_armor;
float old_p_healthtime, old_p_armortime;
// prev_p_* vars contain the health/armor progressbar value at the previous FRAME
// set to -1 to forcedly stop effects when we switch spectated player (e.g. from playerX: 70h to playerY: 50h)
float prev_p_health, prev_p_armor;

void HUD_HealthArmor(void)
{
	float armor, health, fuel;
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_healtharmor) return;
		if(hud != HUD_NORMAL) return;
		if(spectatee_status == -1) return;

		health = getstati(STAT_HEALTH);
		if(health <= 0)
		{
			prev_health = -1;
			return;
		}
		armor = getstati(STAT_ARMOR);

		// code to check for spectatee_status changes is in Ent_ClientData()
		// prev_p_health and prev_health can be set to -1 there

		if (prev_p_health == -1)
		{
			// no effect
			health_beforedamage = 0;
			armor_beforedamage = 0;
			health_damagetime = 0;
			armor_damagetime = 0;
			prev_health = health;
			prev_armor = armor;
			old_p_health = health;
			old_p_armor = armor;
			prev_p_health = health;
			prev_p_armor = armor;
		}
		else if (prev_health == -1)
		{
			//start the load effect
			health_damagetime = 0;
			armor_damagetime = 0;
			prev_health = 0;
			prev_armor = 0;
		}
		fuel = getstati(STAT_FUEL);
	}
	else
	{
		health = 150;
		armor = 75;
		fuel = 20;
	}

	HUD_Panel_UpdateCvars();
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float baralign = autocvar_hud_panel_healtharmor_baralign;
	float iconalign = autocvar_hud_panel_healtharmor_iconalign;

    float maxhealth = autocvar_hud_panel_healtharmor_maxhealth;
    float maxarmor = autocvar_hud_panel_healtharmor_maxarmor;
	if(autocvar_hud_panel_healtharmor == 2) // combined health and armor display
	{
		vector v;
		v = healtharmor_maxdamage(health, armor, armorblockpercent, DEATH_WEAPON);

		float x;
		x = floor(v_x + 1);

        float maxtotal = maxhealth + maxarmor;
		string biggercount;
		if(v_z) // NOT fully armored
		{
			biggercount = "health";
			if(autocvar_hud_panel_healtharmor_progressbar)
				HUD_Panel_DrawProgressBar(pos, mySize, autocvar_hud_panel_healtharmor_progressbar_health, x/maxtotal, 0, (baralign == 1 || baralign == 2), autocvar_hud_progressbar_health_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
			if(armor)
            if(autocvar_hud_panel_healtharmor_text)
				drawpic_aspect_skin(pos + eX * mySize_x - eX * 0.5 * mySize_y, "armor", '0.5 0.5 0' * mySize_y, '1 1 1', panel_fg_alpha * armor / health, DRAWFLAG_NORMAL);
		}
		else
		{
			biggercount = "armor";
			if(autocvar_hud_panel_healtharmor_progressbar)
				HUD_Panel_DrawProgressBar(pos, mySize, autocvar_hud_panel_healtharmor_progressbar_armor, x/maxtotal, 0, (baralign == 1 || baralign == 2), autocvar_hud_progressbar_armor_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
			if(health)
            if(autocvar_hud_panel_healtharmor_text)
				drawpic_aspect_skin(pos + eX * mySize_x - eX * 0.5 * mySize_y, "health", '0.5 0.5 0' * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		}
        if(autocvar_hud_panel_healtharmor_text)
			DrawNumIcon(pos, mySize, x, biggercount, 0, iconalign, HUD_Get_Num_Color(x, maxtotal), 1);

		if(fuel)
			HUD_Panel_DrawProgressBar(pos, eX * mySize_x + eY * 0.2 * mySize_y, "progressbar", fuel/100, 0, (baralign == 1 || baralign == 3), autocvar_hud_progressbar_fuel_color, panel_fg_alpha * 0.8, DRAWFLAG_NORMAL);
	}
	else
	{
		float panel_ar = mySize_x/mySize_y;
		float is_vertical = (panel_ar < 1);
		vector health_offset = '0 0 0', armor_offset = '0 0 0';
		if (panel_ar >= 4 || (panel_ar >= 1/4 && panel_ar < 1))
		{
			mySize_x *= 0.5;
			if (autocvar_hud_panel_healtharmor_flip)
				health_offset_x = mySize_x;
			else
				armor_offset_x = mySize_x;
		}
		else
		{
			mySize_y *= 0.5;
			if (autocvar_hud_panel_healtharmor_flip)
				health_offset_y = mySize_y;
			else
				armor_offset_y = mySize_y;
		}

		float health_baralign, armor_baralign, fuel_baralign;
		float health_iconalign, armor_iconalign;
		if (autocvar_hud_panel_healtharmor_flip)
		{
			armor_baralign = (autocvar_hud_panel_healtharmor_baralign == 2 || autocvar_hud_panel_healtharmor_baralign == 1);
			health_baralign = (autocvar_hud_panel_healtharmor_baralign == 3 || autocvar_hud_panel_healtharmor_baralign == 1);
			fuel_baralign = health_baralign;
			armor_iconalign = (autocvar_hud_panel_healtharmor_iconalign == 2 || autocvar_hud_panel_healtharmor_iconalign == 1);
			health_iconalign = (autocvar_hud_panel_healtharmor_iconalign == 3 || autocvar_hud_panel_healtharmor_iconalign == 1);
		}
		else
		{
			health_baralign = (autocvar_hud_panel_healtharmor_baralign == 2 || autocvar_hud_panel_healtharmor_baralign == 1);
			armor_baralign = (autocvar_hud_panel_healtharmor_baralign == 3 || autocvar_hud_panel_healtharmor_baralign == 1);
			fuel_baralign = armor_baralign;
			health_iconalign = (autocvar_hud_panel_healtharmor_iconalign == 2 || autocvar_hud_panel_healtharmor_iconalign == 1);
			armor_iconalign = (autocvar_hud_panel_healtharmor_iconalign == 3 || autocvar_hud_panel_healtharmor_iconalign == 1);
		}

		//if(health)
		{
			if(autocvar_hud_panel_healtharmor_progressbar)
			{
				float p_health, pain_health_alpha;
				p_health = health;
				pain_health_alpha = 1;
				if (autocvar_hud_panel_healtharmor_progressbar_gfx)
				{
					if (autocvar_hud_panel_healtharmor_progressbar_gfx_smooth > 0)
					{
						if (fabs(prev_health - health) >= autocvar_hud_panel_healtharmor_progressbar_gfx_smooth)
						{
							if (time - old_p_healthtime < 1)
								old_p_health = prev_p_health;
							else
								old_p_health = prev_health;
							old_p_healthtime = time;
						}
						if (time - old_p_healthtime < 1)
						{
							p_health += (old_p_health - health) * (1 - (time - old_p_healthtime));
							prev_p_health = p_health;
						}
					}
					if (autocvar_hud_panel_healtharmor_progressbar_gfx_damage > 0)
					{
						if (prev_health - health >= autocvar_hud_panel_healtharmor_progressbar_gfx_damage)
						{
							if (time - health_damagetime >= 1)
								health_beforedamage = prev_health;
							health_damagetime = time;
						}
						if (time - health_damagetime < 1)
						{
							float health_damagealpha = 1 - (time - health_damagetime)*(time - health_damagetime);
							HUD_Panel_DrawProgressBar(pos + health_offset, mySize, autocvar_hud_panel_healtharmor_progressbar_health, health_beforedamage/maxhealth, is_vertical, health_baralign, autocvar_hud_progressbar_health_color, autocvar_hud_progressbar_alpha * panel_fg_alpha * health_damagealpha, DRAWFLAG_NORMAL);
						}
					}
					prev_health = health;

					if (health <= autocvar_hud_panel_healtharmor_progressbar_gfx_lowhealth)
					{
						float BLINK_FACTOR = 0.15;
						float BLINK_BASE = 0.85;
						float BLINK_FREQ = 9;
						pain_health_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ);
					}
				}
				HUD_Panel_DrawProgressBar(pos + health_offset, mySize, autocvar_hud_panel_healtharmor_progressbar_health, p_health/maxhealth, is_vertical, health_baralign, autocvar_hud_progressbar_health_color, autocvar_hud_progressbar_alpha * panel_fg_alpha * pain_health_alpha, DRAWFLAG_NORMAL);
			}
			if(autocvar_hud_panel_healtharmor_text)
				DrawNumIcon(pos + health_offset, mySize, health, "health", is_vertical, health_iconalign, HUD_Get_Num_Color(health, maxhealth), 1);
		}

		if(armor)
		{
			if(autocvar_hud_panel_healtharmor_progressbar)
			{
				float p_armor;
				p_armor = armor;
				if (autocvar_hud_panel_healtharmor_progressbar_gfx)
				{
					if (autocvar_hud_panel_healtharmor_progressbar_gfx_smooth > 0)
					{
						if (fabs(prev_armor - armor) >= autocvar_hud_panel_healtharmor_progressbar_gfx_smooth)
						{
							if (time - old_p_armortime < 1)
								old_p_armor = prev_p_armor;
							else
								old_p_armor = prev_armor;
							old_p_armortime = time;
						}
						if (time - old_p_armortime < 1)
						{
							p_armor += (old_p_armor - armor) * (1 - (time - old_p_armortime));
							prev_p_armor = p_armor;
						}
					}
					if (autocvar_hud_panel_healtharmor_progressbar_gfx_damage > 0)
					{
						if (prev_armor - armor >= autocvar_hud_panel_healtharmor_progressbar_gfx_damage)
						{
							if (time - armor_damagetime >= 1)
								armor_beforedamage = prev_armor;
							armor_damagetime = time;
						}
						if (time - armor_damagetime < 1)
						{
							float armor_damagealpha = 1 - (time - armor_damagetime)*(time - armor_damagetime);
							HUD_Panel_DrawProgressBar(pos + armor_offset, mySize, autocvar_hud_panel_healtharmor_progressbar_armor, armor_beforedamage/maxarmor, is_vertical, armor_baralign, autocvar_hud_progressbar_armor_color, autocvar_hud_progressbar_alpha * panel_fg_alpha * armor_damagealpha, DRAWFLAG_NORMAL);
						}
					}
					prev_armor = armor;
				}
				HUD_Panel_DrawProgressBar(pos + armor_offset, mySize, autocvar_hud_panel_healtharmor_progressbar_armor, p_armor/maxarmor, is_vertical, armor_baralign, autocvar_hud_progressbar_armor_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
			}
			if(autocvar_hud_panel_healtharmor_text)
				DrawNumIcon(pos + armor_offset, mySize, armor, "armor", is_vertical, armor_iconalign, HUD_Get_Num_Color(armor, maxarmor), 1);
		}

		if(fuel)
		{
			if (is_vertical)
				mySize_x *= 0.2 / 2; //if vertical always halve x to not cover too much numbers with 3 digits
			else
				mySize_y *= 0.2;
			if (panel_ar >= 4)
				mySize_x *= 2; //restore full panel size
			else if (panel_ar < 1/4)
				mySize_y *= 2; //restore full panel size
			HUD_Panel_DrawProgressBar(pos, mySize, "progressbar", fuel/100, is_vertical, fuel_baralign, autocvar_hud_progressbar_fuel_color, panel_fg_alpha * 0.8, DRAWFLAG_NORMAL);
		}
	}
}

// Notification area (#4)
//

void HUD_Notify_Push(string icon, string attacker, string victim)
{
	if(icon != "")
	{
		--kn_index;
		if (kn_index == -1) { kn_index = KN_MAX_ENTRIES-1; }
		notify_times[kn_index] = time;

		// icon
		if(notify_icon[kn_index]) { strunzone(notify_icon[kn_index]); }
		notify_icon[kn_index] = strzone(icon);

		// attacker
		if(notify_attackers[kn_index]) { strunzone(notify_attackers[kn_index]); }
		notify_attackers[kn_index] = strzone(attacker);

		// victim
		if(notify_victims[kn_index]) { strunzone(notify_victims[kn_index]); }
		notify_victims[kn_index] = strzone(victim);
	}
}

void HUD_Notify(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_notify) return;
	}

	HUD_Panel_UpdateCvars();
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float entries, height;
	entries = bound(1, floor(KN_MAX_ENTRIES * mySize_y/mySize_x), KN_MAX_ENTRIES);
	height = mySize_y/entries;

	vector fontsize;
	float fontheight = height * autocvar_hud_panel_notify_fontsize;
	fontsize = '0.5 0.5 0' * fontheight;

	float a;
	float when;
	when = autocvar_hud_panel_notify_time;
	float fadetime;
	fadetime = autocvar_hud_panel_notify_fadetime;

	vector pos_attacker, pos_victim, pos_icon;
	float width_attacker;
	string attacker, victim, icon;

	float i, j, step, limit;
	if(autocvar_hud_panel_notify_flip) //order items from the top down
	{
		i = 0;
		step = +1;
		limit = entries;
	}
	else //order items from the bottom up
	{
		i = entries - 1;
		step = -1;
		limit = -1;
	}

	for(j = kn_index;  i != limit;  i += step, ++j)
	{
		if(autocvar__hud_configure)
		{
			if (step == +1)
				a = i;
			else // inverse order
				a = entries - 1 - i;
			attacker = textShortenToWidth(sprintf(_("Player %d"), a+1), 0.48 * mySize_x - height, fontsize, stringwidth_colors);
			victim = textShortenToWidth(sprintf(_("Player %d"), a+2), 0.48 * mySize_x - height, fontsize, stringwidth_colors);
			icon = strcat("weapon", get_weaponinfo(WEP_FIRST + mod(floor(a*2.4), WEP_LAST)).netname);
			a = bound(0, (when - a) / 4, 1);
			goto hud_config_notifyprint;
		}
		else
		{
			if (j == KN_MAX_ENTRIES)
				j = 0;

			if(notify_times[j] + when > time)
				a = 1;
			else if(fadetime)
			{
				a = bound(0, (notify_times[j] + when + fadetime - time) / fadetime, 1);
				if(!a)
				{
					break;
				}
			}
			else
			{
				break;
			}

			attacker = notify_attackers[j];
			victim = notify_victims[j];
			icon = notify_icon[j];
		}

		//type = notify_deathtype[j];
		//w = DEATH_WEAPONOF(type);

		if(icon != "")
		{
			if((attacker != "") && (victim == ""))
			{
				// Y [used by] X
				attacker = textShortenToWidth(attacker, 0.73 * mySize_x - height, fontsize, stringwidth_colors);
				pos_attacker = pos + eX * (0.27 * mySize_x + height) + eY * ((0.5 * fontsize_y + i * height) + (0.5 * (height - fontheight)));
				pos_icon = pos + eX * 0.25 * mySize_x - eX * height + eY * i * height;

				drawpic_aspect_skin(pos_icon, icon, '2 1 0' * height, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
				drawcolorcodedstring(pos_attacker, attacker, fontsize, panel_fg_alpha * a, DRAWFLAG_NORMAL);
			}
			else if((attacker != "") && (victim != ""))
			{
				// X [did action to] Y
				attacker = textShortenToWidth(attacker, 0.48 * mySize_x - height, fontsize, stringwidth_colors);
				victim = textShortenToWidth(victim, 0.48 * mySize_x - height, fontsize, stringwidth_colors);
:hud_config_notifyprint
				width_attacker = stringwidth(attacker, TRUE, fontsize);
				pos_attacker = pos + eX * (0.48 * mySize_x - height - width_attacker) + eY * ((0.5 * fontsize_y + i * height) + (0.5 * (height - fontheight)));
				pos_victim = pos + eX * (0.52 * mySize_x + height) + eY * ((0.5 * fontsize_y + i * height) + (0.5 * (height - fontheight)));
				pos_icon = pos + eX * 0.5 * mySize_x - eX * height + eY * i * height;

				drawpic_aspect_skin(pos_icon, icon, '2 1 0' * height, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
				drawcolorcodedstring(pos_attacker, attacker, fontsize, panel_fg_alpha * a, DRAWFLAG_NORMAL);
				drawcolorcodedstring(pos_victim, victim, fontsize, panel_fg_alpha * a, DRAWFLAG_NORMAL);
			}
		}
	}
}

// Timer (#5)
//
// TODO: macro
string seconds_tostring(float sec)
{
	float minutes;
	minutes = floor(sec / 60);

	sec -= minutes * 60;
	return sprintf("%d:%02d", minutes, sec);
}

void HUD_Timer(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_timer) return;
	}

	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	string timer;
	float timelimit, elapsedTime, timeleft, minutesLeft;

	timelimit = getstatf(STAT_TIMELIMIT);

	timeleft = max(0, timelimit * 60 + getstatf(STAT_GAMESTARTTIME) - time);
	timeleft = ceil(timeleft);

	minutesLeft = floor(timeleft / 60);

	vector timer_color;
	if(minutesLeft >= 5 || warmup_stage || timelimit == 0) //don't use red or yellow in warmup or when there is no timelimit
		timer_color = '1 1 1'; //white
	else if(minutesLeft >= 1)
		timer_color = '1 1 0'; //yellow
	else
		timer_color = '1 0 0'; //red

	if (autocvar_hud_panel_timer_increment || timelimit == 0 || warmup_stage) {
		if (time < getstatf(STAT_GAMESTARTTIME)) {
			//while restart is still active, show 00:00
			timer = seconds_tostring(0);
		} else {
			elapsedTime = floor(time - getstatf(STAT_GAMESTARTTIME)); //127
			timer = seconds_tostring(elapsedTime);
		}
	} else {
		timer = seconds_tostring(timeleft);
	}

	drawstring_aspect(pos, timer, mySize, timer_color, panel_fg_alpha, DRAWFLAG_NORMAL);

	draw_endBoldFont();
}

// Radar (#6)
//
void HUD_Radar(void)
{
	if (!autocvar__hud_configure)
	{
		if (hud_panel_radar_maximized)
		{
			if (!hud_draw_maximized) return;
		}
		else
		{
			if (autocvar_hud_panel_radar == 0) return;
			if (autocvar_hud_panel_radar != 2 && !teamplay) return;
			if(radar_panel_modified)
			{
				panel.update_time = time; // forces reload of panel attributes
				radar_panel_modified = false;
			}
		}
	}

	HUD_Panel_UpdateCvars();

	float f = 0;

	if (hud_panel_radar_maximized && !autocvar__hud_configure)
	{
		panel_size = autocvar_hud_panel_radar_maximized_size;
		panel_size_x = bound(0.2, panel_size_x, 1) * vid_conwidth;
		panel_size_y = bound(0.2, panel_size_y, 1) * vid_conheight;
		panel_pos_x = (vid_conwidth - panel_size_x) / 2;
		panel_pos_y = (vid_conheight - panel_size_y) / 2;

		string panel_bg;
		panel_bg = strcat(hud_skin_path, "/border_default"); // always use the default border when maximized
		if(precache_pic(panel_bg) == "")
			panel_bg = "gfx/hud/default/border_default"; // fallback
		if(!radar_panel_modified && panel_bg != panel.current_panel_bg)
			radar_panel_modified = true;
		if(panel.current_panel_bg)
			strunzone(panel.current_panel_bg);
		panel.current_panel_bg = strzone(panel_bg);

		switch(hud_panel_radar_maximized_zoommode)
		{
			default:
			case 0:
				f = current_zoomfraction;
				break;
			case 1:
				f = 1 - current_zoomfraction;
				break;
			case 2:
				f = 0;
				break;
			case 3:
				f = 1;
				break;
		}

		switch(hud_panel_radar_maximized_rotation)
		{
			case 0:
				teamradar_angle = view_angles_y - 90;
				break;
			default:
				teamradar_angle = 90 * hud_panel_radar_maximized_rotation;
				break;
		}
	}
	if (!hud_panel_radar_maximized && !autocvar__hud_configure)
	{
		switch(hud_panel_radar_zoommode)
		{
			default:
			case 0:
				f = current_zoomfraction;
				break;
			case 1:
				f = 1 - current_zoomfraction;
				break;
			case 2:
				f = 0;
				break;
			case 3:
				f = 1;
				break;
		}

		switch(hud_panel_radar_rotation)
		{
			case 0:
				teamradar_angle = view_angles_y - 90;
				break;
			default:
				teamradar_angle = 90 * hud_panel_radar_rotation;
				break;
		}
	}

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float color2;
	entity tm;
	float scale2d, normalsize, bigsize;

	teamradar_origin2d = pos + 0.5 * mySize;
	teamradar_size2d = mySize;

	if(minimapname == "")
		return;

	teamradar_loadcvars();

	scale2d = vlen_maxnorm2d(mi_picmax - mi_picmin);
	teamradar_size2d = mySize;

	teamradar_extraclip_mins = teamradar_extraclip_maxs = '0 0 0'; // we always center

	// pixels per world qu to match the teamradar_size2d_x range in the longest dimension
	if((hud_panel_radar_rotation == 0 && !hud_panel_radar_maximized) || (hud_panel_radar_maximized_rotation == 0 && hud_panel_radar_maximized))
	{
		// max-min distance must fit the radar in any rotation
		bigsize = vlen_minnorm2d(teamradar_size2d) * scale2d / (1.05 * vlen2d(mi_scale));
	}
	else
	{
		vector c0, c1, c2, c3, span;
		c0 = rotate(mi_min, teamradar_angle * DEG2RAD);
		c1 = rotate(mi_max, teamradar_angle * DEG2RAD);
		c2 = rotate('1 0 0' * mi_min_x + '0 1 0' * mi_max_y, teamradar_angle * DEG2RAD);
		c3 = rotate('1 0 0' * mi_max_x + '0 1 0' * mi_min_y, teamradar_angle * DEG2RAD);
		span = '0 0 0';
		span_x = max(c0_x, c1_x, c2_x, c3_x) - min(c0_x, c1_x, c2_x, c3_x);
		span_y = max(c0_y, c1_y, c2_y, c3_y) - min(c0_y, c1_y, c2_y, c3_y);

		// max-min distance must fit the radar in x=x, y=y
		bigsize = min(
			teamradar_size2d_x * scale2d / (1.05 * span_x),
			teamradar_size2d_y * scale2d / (1.05 * span_y)
		);
	}

	normalsize = vlen_maxnorm2d(teamradar_size2d) * scale2d / hud_panel_radar_scale;
	if(bigsize > normalsize)
		normalsize = bigsize;

	teamradar_size =
		  f * bigsize
		+ (1 - f) * normalsize;
	teamradar_origin3d_in_texcoord = teamradar_3dcoord_to_texcoord(
		  f * mi_center
		+ (1 - f) * view_origin);

	drawsetcliparea(
		pos_x,
		pos_y,
		mySize_x,
		mySize_y
	);

	draw_teamradar_background(hud_panel_radar_foreground_alpha);

	for(tm = world; (tm = find(tm, classname, "radarlink")); )
		draw_teamradar_link(tm.origin, tm.velocity, tm.team);
	for(tm = world; (tm = findflags(tm, teamradar_icon, 0xFFFFFF)); )
		draw_teamradar_icon(tm.origin, tm.teamradar_icon, tm, tm.teamradar_color, panel_fg_alpha);
	for(tm = world; (tm = find(tm, classname, "entcs_receiver")); )
	{
		color2 = GetPlayerColor(tm.sv_entnum);
		//if(color == NUM_SPECTATOR || color == color2)
			draw_teamradar_player(tm.origin, tm.angles, Team_ColorRGB(color2));
	}
	draw_teamradar_player(view_origin, view_angles, '1 1 1');

	drawresetcliparea();
}

// Score (#7)
//
void HUD_UpdatePlayerTeams();
void HUD_Score_Rankings(vector pos, vector mySize, entity me)
{
	float score;
	entity tm = world, pl;
#define SCOREPANEL_MAX_ENTRIES 6
#define SCOREPANEL_ASPECTRATIO 2
	float entries = bound(1, floor(SCOREPANEL_MAX_ENTRIES * mySize_y/mySize_x * SCOREPANEL_ASPECTRATIO), SCOREPANEL_MAX_ENTRIES);
	vector fontsize = '1 1 0' * (mySize_y/entries);

	vector rgb, score_color;
	rgb = '1 1 1';
	score_color = '1 1 1';

	float name_size = mySize_x*0.75;
	float spacing_size = mySize_x*0.04;
	const float highlight_alpha = 0.2;
	float i = 0, me_printed = 0, first_pl = 0;
	string s;
	if (autocvar__hud_configure)
	{
		float players_per_team = 0;
		if (team_count)
		{
			// show team scores in the first line
			float score_size = mySize_x / team_count;
			players_per_team = max(2, ceil((entries - 1) / team_count));
			for(i=0; i<team_count; ++i) {
				if (i == floor((entries - 2) / players_per_team) || (entries == 1 && i == 0))
					HUD_Panel_DrawHighlight(pos + eX * score_size * i, eX * score_size + eY * fontsize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
				drawstring_aspect(pos + eX * score_size * i, ftos(175 - 23*i), eX * score_size + eY * fontsize_y, Team_ColorRGB(ColorByTeam(i)) * 0.8, panel_fg_alpha, DRAWFLAG_NORMAL);
			}
			first_pl = 1;
			pos_y += fontsize_y;
		}
		score = 10 + SCOREPANEL_MAX_ENTRIES * 3;
		for (i=first_pl; i<entries; ++i)
		{
			//simulate my score is lower than all displayed players,
			//so that I don't appear at all showing pure rankings.
			//This is to better show the difference between the 2 ranking views
			if (i == entries-1 && autocvar_hud_panel_score_rankings == 1)
			{
				rgb = '1 1 0';
				drawfill(pos, eX * mySize_x + eY * fontsize_y, rgb, highlight_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
				s = GetPlayerName(player_localnum);
				score = 7;
			}
			else
			{
				s = sprintf(_("Player %d"), i + 1 - first_pl);
				score -= 3;
			}

			if (team_count)
				score_color = Team_ColorRGB(ColorByTeam(floor((i - first_pl) / players_per_team))) * 0.8;
			s = textShortenToWidth(s, name_size, fontsize, stringwidth_colors);
			drawcolorcodedstring(pos + eX * (name_size - stringwidth(s, TRUE, fontsize)), s, fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);
			drawstring(pos + eX * (name_size + spacing_size), ftos(score), fontsize, score_color, panel_fg_alpha, DRAWFLAG_NORMAL);
			pos_y += fontsize_y;
		}
		return;
	}

	if (!scoreboard_fade_alpha) // the scoreboard too calls HUD_UpdatePlayerTeams
		HUD_UpdatePlayerTeams();
	if (team_count)
	{
		// show team scores in the first line
		float score_size = mySize_x / team_count;
		for(tm = teams.sort_next; tm; tm = tm.sort_next) {
			if(tm.team == NUM_SPECTATOR)
				continue;
			if (tm.team == myteam)
				drawfill(pos + eX * score_size * i, eX * score_size + eY * fontsize_y, '1 1 1', highlight_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
			drawstring_aspect(pos + eX * score_size * i, ftos(tm.(teamscores[ts_primary])), eX * score_size + eY * fontsize_y, Team_ColorRGB(tm.team) * 0.8, panel_fg_alpha, DRAWFLAG_NORMAL);
			++i;
		}
		first_pl = 1;
		pos_y += fontsize_y;
		tm = teams.sort_next;
	}
	i = first_pl;

	do
	for (pl = players.sort_next; pl && i<entries; pl = pl.sort_next)
	{
		if ((team_count && pl.team != tm.team) || pl.team == NUM_SPECTATOR)
			continue;

		if (i == entries-1 && !me_printed && pl != me)
		if (autocvar_hud_panel_score_rankings == 1 && spectatee_status != -1)
		{
			for (pl = me.sort_next; pl; pl = pl.sort_next)
				if (pl.team != NUM_SPECTATOR)
					break;

			if (pl)
				rgb = '1 1 0'; //not last but not among the leading players: yellow
			else
				rgb = '1 0 0'; //last: red
			pl = me;
		}

		if (pl == me)
		{
			if (i == first_pl)
				rgb = '0 1 0'; //first: green
			me_printed = 1;
			drawfill(pos, eX * mySize_x + eY * fontsize_y, rgb, highlight_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
		}
		if (team_count)
			score_color = Team_ColorRGB(pl.team) * 0.8;
		s = textShortenToWidth(GetPlayerName(pl.sv_entnum), name_size, fontsize, stringwidth_colors);
		drawcolorcodedstring(pos + eX * (name_size - stringwidth(s, TRUE, fontsize)), s, fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring(pos + eX * (name_size + spacing_size), ftos(pl.(scores[ps_primary])), fontsize, score_color, panel_fg_alpha, DRAWFLAG_NORMAL);
		pos_y += fontsize_y;
		++i;
	}
	while (i<entries && team_count && (tm = tm.sort_next) && (tm.team != NUM_SPECTATOR || (tm = tm.sort_next)));
}

void HUD_Score(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_score) return;
		if(spectatee_status == -1 && (gametype == MAPINFO_TYPE_RACE || gametype == MAPINFO_TYPE_CTS)) return;
	}

	HUD_Panel_UpdateCvars();
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float score, distribution = 0;
	string sign;
	vector distribution_color;
	entity tm, pl, me;

#ifdef COMPAT_XON050_ENGINE
	me = (spectatee_status > 0) ? playerslots[spectatee_status - 1] : playerslots[player_localentnum - 1];
#else
	me = playerslots[player_localentnum - 1];
#endif

	if((scores_flags[ps_primary] & SFL_TIME) && !teamplay) { // race/cts record display on HUD
		string timer, distrtimer;

		pl = players.sort_next;
		if(pl == me)
			pl = pl.sort_next;
		if(scores_flags[ps_primary] & SFL_ZERO_IS_WORST)
			if(pl.scores[ps_primary] == 0)
				pl = world;

		score = me.(scores[ps_primary]);
		timer = TIME_ENCODED_TOSTRING(score);

		draw_beginBoldFont();
		if (pl && ((!(scores_flags[ps_primary] & SFL_ZERO_IS_WORST)) || score)) {
			// distribution display
			distribution = me.(scores[ps_primary]) - pl.(scores[ps_primary]);

			distrtimer = ftos_decimals(fabs(distribution/pow(10, TIME_DECIMALS)), TIME_DECIMALS);

			if (distribution <= 0) {
				distribution_color = '0 1 0';
				sign = "-";
			}
			else {
				distribution_color = '1 0 0';
				sign = "+";
			}
			drawstring_aspect(pos + eX * 0.75 * mySize_x, strcat(sign, distrtimer), eX * 0.25 * mySize_x + eY * (1/3) * mySize_y, distribution_color, panel_fg_alpha, DRAWFLAG_NORMAL);
		}
		// race record display
		if (distribution <= 0)
			HUD_Panel_DrawHighlight(pos, eX * 0.75 * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(pos, timer, eX * 0.75 * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		draw_endBoldFont();
	} else if (!teamplay) { // non-teamgames
		if ((spectatee_status == -1 && !autocvar__hud_configure) || autocvar_hud_panel_score_rankings)
		{
			HUD_Score_Rankings(pos, mySize, me);
			return;
		}
		// me vector := [team/connected frags id]
		pl = players.sort_next;
		if(pl == me)
			pl = pl.sort_next;

		if(autocvar__hud_configure)
			distribution = 42;
		else if(pl)
			distribution = me.(scores[ps_primary]) - pl.(scores[ps_primary]);
		else
			distribution = 0;

		score = me.(scores[ps_primary]);
		if(autocvar__hud_configure)
			score = 123;

		if(distribution >= 5)
			distribution_color = eY;
		else if(distribution >= 0)
			distribution_color = '1 1 1';
		else if(distribution >= -5)
			distribution_color = '1 1 0';
		else
			distribution_color = eX;

		string distribution_str;
		distribution_str = ftos(distribution);
		draw_beginBoldFont();
		if (distribution >= 0)
		{
			if (distribution > 0)
				distribution_str = strcat("+", distribution_str);
			HUD_Panel_DrawHighlight(pos, eX * 0.75 * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		}
		drawstring_aspect(pos, ftos(score), eX * 0.75 * mySize_x + eY * mySize_y, distribution_color, panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(pos + eX * 0.75 * mySize_x, distribution_str, eX * 0.25 * mySize_x + eY * (1/3) * mySize_y, distribution_color, panel_fg_alpha, DRAWFLAG_NORMAL);
		draw_endBoldFont();
	} else { // teamgames
		float row, column, rows = 0, columns = 0;
		local noref vector offset = '0 0 0';
		vector score_pos, score_size; //for scores other than myteam
		if(autocvar_hud_panel_score_rankings)
		{
			HUD_Score_Rankings(pos, mySize, me);
			return;
		}
		if(spectatee_status == -1)
		{
			rows = mySize_y/mySize_x;
			rows = bound(1, floor((sqrt(4 * (3/1) * rows * team_count + rows * rows) + rows + 0.5) / 2), team_count);
			//                               ^^^ ammo item aspect goes here

			columns = ceil(team_count/rows);

			score_size = eX * mySize_x*(1/columns) + eY * mySize_y*(1/rows);

			float newSize;
			if(score_size_x/score_size_y > 3)
			{
				newSize = 3 * score_size_y;
				offset_x = score_size_x - newSize;
				pos_x += offset_x/2;
				score_size_x = newSize;
			}
			else
			{
				newSize = 1/3 * score_size_x;
				offset_y = score_size_y - newSize;
				pos_y += offset_y/2;
				score_size_y = newSize;
			}
		}
		else
			score_size = eX * mySize_x*(1/4) + eY * mySize_y*(1/3);

		float max_fragcount;
		max_fragcount = -99;
		draw_beginBoldFont();
		row = column = 0;
		for(tm = teams.sort_next; tm; tm = tm.sort_next) {
			if(tm.team == NUM_SPECTATOR)
				continue;
			score = tm.(teamscores[ts_primary]);
			if(autocvar__hud_configure)
				score = 123;

			if (score > max_fragcount)
				max_fragcount = score;

			if (spectatee_status == -1)
			{
				score_pos = pos + eX * column * (score_size_x + offset_x) + eY * row * (score_size_y + offset_y);
				if (max_fragcount == score)
					HUD_Panel_DrawHighlight(score_pos, score_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
				drawstring_aspect(score_pos, ftos(score), score_size, Team_ColorRGB(tm.team) * 0.8, panel_fg_alpha, DRAWFLAG_NORMAL);
				++row;
				if(row >= rows)
				{
					row = 0;
					++column;
				}
			}
			else if(tm.team == myteam) {
				if (max_fragcount == score)
					HUD_Panel_DrawHighlight(pos, eX * 0.75 * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
				drawstring_aspect(pos, ftos(score), eX * 0.75 * mySize_x + eY * mySize_y, Team_ColorRGB(tm.team) * 0.8, panel_fg_alpha, DRAWFLAG_NORMAL);
			} else {
				if (max_fragcount == score)
					HUD_Panel_DrawHighlight(pos + eX * 0.75 * mySize_x + eY * (1/3) * rows * mySize_y, score_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
				drawstring_aspect(pos + eX * 0.75 * mySize_x + eY * (1/3) * rows * mySize_y, ftos(score), score_size, Team_ColorRGB(tm.team) * 0.8, panel_fg_alpha, DRAWFLAG_NORMAL);
				++rows;
			}
		}
		draw_endBoldFont();
	}
}

// Race timer (#8)
//
void HUD_RaceTimer (void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_racetimer) return;
		if(!(gametype == MAPINFO_TYPE_RACE || gametype == MAPINFO_TYPE_CTS)) return;
		if(spectatee_status == -1) return;
	}

	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	// always force 4:1 aspect
	vector newSize = '0 0 0';
	if(mySize_x/mySize_y > 4)
	{
		newSize_x = 4 * mySize_y;
		newSize_y = mySize_y;

		pos_x = pos_x + (mySize_x - newSize_x) / 2;
	}
	else
	{
		newSize_y = 1/4 * mySize_x;
		newSize_x = mySize_x;

		pos_y = pos_y + (mySize_y - newSize_y) / 2;
	}
	mySize = newSize;

	float a, t;
	string s, forcetime;

	if(autocvar__hud_configure)
	{
		s = "0:13:37";
		drawstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, FALSE, '0.60 0.60 0' * mySize_y), s, '0.60 0.60 0' * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		s = _("^1Intermediate 1 (+15.42)");
		drawcolorcodedstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, TRUE, '1 1 0' * 0.20 * mySize_y) + eY * 0.60 * mySize_y, s, '1 1 0' * 0.20 * mySize_y, panel_fg_alpha, DRAWFLAG_NORMAL);
		s = sprintf(_("^1PENALTY: %.1f (%s)"), 2, "missing a checkpoint");
		drawcolorcodedstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, TRUE, '1 1 0' * 0.20 * mySize_y) + eY * 0.80 * mySize_y, s, '1 1 0' * 0.20 * mySize_y, panel_fg_alpha, DRAWFLAG_NORMAL);
	}
	else if(race_checkpointtime)
	{
		a = bound(0, 2 - (time - race_checkpointtime), 1);
		s = "";
		forcetime = "";
		if(a > 0) // just hit a checkpoint?
		{
			if(race_checkpoint != 254)
			{
				if(race_time && race_previousbesttime)
					s = MakeRaceString(race_checkpoint, TIME_DECODE(race_time) - TIME_DECODE(race_previousbesttime), 0, 0, race_previousbestname);
				else
					s = MakeRaceString(race_checkpoint, 0, -1, 0, race_previousbestname);
				if(race_time)
					forcetime = TIME_ENCODED_TOSTRING(race_time);
			}
		}
		else
		{
			if(race_laptime && race_nextbesttime && race_nextcheckpoint != 254)
			{
				a = bound(0, 2 - ((race_laptime + TIME_DECODE(race_nextbesttime)) - (time + TIME_DECODE(race_penaltyaccumulator))), 1);
				if(a > 0) // next one?
				{
					s = MakeRaceString(race_nextcheckpoint, (time + TIME_DECODE(race_penaltyaccumulator)) - race_laptime, TIME_DECODE(race_nextbesttime), 0, race_nextbestname);
				}
			}
		}

		if(s != "" && a > 0)
		{
			drawcolorcodedstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, TRUE, '1 1 0' * 0.2 * mySize_y) + eY * 0.6 * mySize_y, s, '1 1 0' * 0.2 * mySize_y, panel_fg_alpha * a, DRAWFLAG_NORMAL);
		}

		if(race_penaltytime)
		{
			a = bound(0, 2 - (time - race_penaltyeventtime), 1);
			if(a > 0)
			{
				s = sprintf(_("^1PENALTY: %.1f (%s)"), race_penaltytime * 0.1, race_penaltyreason);
				drawcolorcodedstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, TRUE, '1 1 0' * 0.2 * mySize_y) + eY * 0.8 * mySize_y, s, '1 1 0' * 0.2 * mySize_y, panel_fg_alpha * a, DRAWFLAG_NORMAL);
			}
		}

		if(forcetime != "")
		{
			a = bound(0, (time - race_checkpointtime) / 0.5, 1);
			drawstring_expanding(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(forcetime, FALSE, '1 1 0' * 0.6 * mySize_y), forcetime, '1 1 0' * 0.6 * mySize_y, '1 1 1', panel_fg_alpha, 0, a);
		}
		else
			a = 1;

		if(race_laptime && race_checkpoint != 255)
		{
			s = TIME_ENCODED_TOSTRING(TIME_ENCODE(time + TIME_DECODE(race_penaltyaccumulator) - race_laptime));
			drawstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, FALSE, '0.6 0.6 0' * mySize_y), s, '0.6 0.6 0' * mySize_y, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
		}
	}
	else
	{
		if(race_mycheckpointtime)
		{
			a = bound(0, 2 - (time - race_mycheckpointtime), 1);
			s = MakeRaceString(race_mycheckpoint, TIME_DECODE(race_mycheckpointdelta), -(race_mycheckpointenemy == ""), race_mycheckpointlapsdelta, race_mycheckpointenemy);
			drawcolorcodedstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, TRUE, '1 1 0' * 0.2 * mySize_y) + eY * 0.6 * mySize_y, s, '1 1 0' * 0.2 * mySize_y, panel_fg_alpha * a, DRAWFLAG_NORMAL);
		}
		if(race_othercheckpointtime && race_othercheckpointenemy != "")
		{
			a = bound(0, 2 - (time - race_othercheckpointtime), 1);
			s = MakeRaceString(race_othercheckpoint, -TIME_DECODE(race_othercheckpointdelta), -(race_othercheckpointenemy == ""), race_othercheckpointlapsdelta, race_othercheckpointenemy);
			drawcolorcodedstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, TRUE, '1 1 0' * 0.2 * mySize_y) + eY * 0.6 * mySize_y, s, '1 1 0' * 0.2 * mySize_y, panel_fg_alpha * a, DRAWFLAG_NORMAL);
		}

		if(race_penaltytime && !race_penaltyaccumulator)
		{
			t = race_penaltytime * 0.1 + race_penaltyeventtime;
			a = bound(0, (1 + t - time), 1);
			if(a > 0)
			{
				if(time < t)
					s = sprintf(_("^1PENALTY: %.1f (%s)"), (t - time) * 0.1, race_penaltyreason);
				else
					s = sprintf(_("^2PENALTY: %.1f (%s)"), 0, race_penaltyreason);
				drawcolorcodedstring(pos + eX * 0.5 * mySize_x - '0.5 0 0' * stringwidth(s, TRUE, '1 1 0' * 0.2 * mySize_y) + eY * 0.6 * mySize_y, s, '1 1 0' * 0.2 * mySize_y, panel_fg_alpha * a, DRAWFLAG_NORMAL);
			}
		}
	}

	draw_endBoldFont();
}

// Vote window (#9)
//
float vote_yescount;
float vote_nocount;
float vote_needed;
float vote_highlighted; // currently selected vote

float vote_active; // is there an active vote?
float vote_prev; // previous state of vote_active to check for a change
float vote_alpha;
float vote_change; // "time" when vote_active changed

void HUD_Vote(void)
{
	if(autocvar_cl_allow_uid2name == -1 && (gametype == MAPINFO_TYPE_CTS || gametype == MAPINFO_TYPE_RACE || (serverflags & SERVERFLAG_PLAYERSTATS)))
	{
		vote_active = 1;
		if (autocvar__hud_configure)
		{
			vote_yescount = 0;
			vote_nocount = 0;
			print(_("^1You must answer before entering hud configure mode\n"));
			cvar_set("_hud_configure", "0");
		}
		if(vote_called_vote)
			strunzone(vote_called_vote);
		vote_called_vote = strzone(_("^2Name ^7instead of \"^1Anonymous player^7\" in stats"));
		uid2name_dialog = 1;
	}

	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_vote) return;

		panel_fg_alpha = autocvar_hud_panel_fg_alpha;
		panel_bg_alpha_str = autocvar_hud_panel_vote_bg_alpha;

		if(panel_bg_alpha_str == "") {
			panel_bg_alpha_str = ftos(autocvar_hud_panel_bg_alpha);
		}
		panel_bg_alpha = stof(panel_bg_alpha_str);
	}
	else
	{
		vote_yescount = 3;
		vote_nocount = 2;
		vote_needed = 4;
	}

	string s;
	float a;
	if(vote_active != vote_prev) {
		vote_change = time;
		vote_prev = vote_active;
	}

	if(vote_active || autocvar__hud_configure)
		vote_alpha = bound(0, (time - vote_change) * 2, 1);
	else
		vote_alpha = bound(0, 1 - (time - vote_change) * 2, 1);

	if(!vote_alpha)
		return;

	HUD_Panel_UpdateCvars();

	if(uid2name_dialog)
	{
		panel_pos = eX * 0.3 * vid_conwidth + eY * 0.1 * vid_conheight;
		panel_size = eX * 0.4 * vid_conwidth + eY * 0.3 * vid_conheight;
	}

    // these must be below above block
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	a = vote_alpha * (vote_highlighted ? autocvar_hud_panel_vote_alreadyvoted_alpha : 1);
	HUD_Panel_DrawBg(a);
	a = panel_fg_alpha * a;

	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	// always force 3:1 aspect
	vector newSize = '0 0 0';
	if(mySize_x/mySize_y > 3)
	{
		newSize_x = 3 * mySize_y;
		newSize_y = mySize_y;

		pos_x = pos_x + (mySize_x - newSize_x) / 2;
	}
	else
	{
		newSize_y = 1/3 * mySize_x;
		newSize_x = mySize_x;

		pos_y = pos_y + (mySize_y - newSize_y) / 2;
	}
	mySize = newSize;

	s = _("A vote has been called for:");
	if(uid2name_dialog)
		s = _("Allow servers to store and display your name?");
	drawstring_aspect(pos, s, eX * mySize_x + eY * (2/8) * mySize_y, '1 1 1', a, DRAWFLAG_NORMAL);
	s = textShortenToWidth(vote_called_vote, mySize_x, '1 1 0' * mySize_y * (1/8), stringwidth_colors);
	if(autocvar__hud_configure)
		s = _("^1Configure the HUD");
	drawcolorcodedstring_aspect(pos + eY * (2/8) * mySize_y, s, eX * mySize_x + eY * (1.75/8) * mySize_y, a, DRAWFLAG_NORMAL);

	// print the yes/no counts
    s = sprintf(_("Yes (%s): %d"), getcommandkey("vyes", "vyes"), vote_yescount);
	drawstring_aspect(pos + eY * (4/8) * mySize_y, s, eX * 0.5 * mySize_x + eY * (1.5/8) * mySize_y, '0 1 0', a, DRAWFLAG_NORMAL);
    s = sprintf(_("No (%s): %d"), getcommandkey("vno", "vno"), vote_nocount);
	drawstring_aspect(pos + eX * 0.5 * mySize_x + eY * (4/8) * mySize_y, s, eX * 0.5 * mySize_x + eY * (1.5/8) * mySize_y, '1 0 0', a, DRAWFLAG_NORMAL);

	// draw the progress bar backgrounds
	drawpic_skin(pos + eY * (5/8) * mySize_y, "voteprogress_back", eX * mySize_x + eY * (3/8) * mySize_y, '1 1 1', a, DRAWFLAG_NORMAL);

	// draw the highlights
	if(vote_highlighted == 1) {
		drawsetcliparea(pos_x, pos_y, mySize_x * 0.5, mySize_y);
		drawpic_skin(pos + eY * (5/8) * mySize_y, "voteprogress_voted", eX * mySize_x + eY * (3/8) * mySize_y, '1 1 1', a, DRAWFLAG_NORMAL);
	}
	else if(vote_highlighted == -1) {
		drawsetcliparea(pos_x + 0.5 * mySize_x, pos_y, mySize_x * 0.5, mySize_y);
		drawpic_skin(pos + eY * (5/8) * mySize_y, "voteprogress_voted", eX * mySize_x + eY * (3/8) * mySize_y, '1 1 1', a, DRAWFLAG_NORMAL);
	}

	// draw the progress bars
	if(vote_yescount && vote_needed)
	{
		drawsetcliparea(pos_x, pos_y, mySize_x * 0.5 * (vote_yescount/vote_needed), mySize_y);
		drawpic_skin(pos + eY * (5/8) * mySize_y, "voteprogress_prog", eX * mySize_x + eY * (3/8) * mySize_y, '1 1 1', a, DRAWFLAG_NORMAL);
	}

	if(vote_nocount && vote_needed)
	{
		drawsetcliparea(pos_x + mySize_x - mySize_x * 0.5 * (vote_nocount/vote_needed), pos_y, mySize_x * 0.5, mySize_y);
		drawpic_skin(pos + eY * (5/8) * mySize_y, "voteprogress_prog", eX * mySize_x + eY * (3/8) * mySize_y, '1 1 1', a, DRAWFLAG_NORMAL);
	}

	drawresetcliparea();
}

// Mod icons panel (#10)
//

float mod_active; // is there any active mod icon?

void DrawCAItem(vector myPos, vector mySize, float aspect_ratio, float layout, float i)
{
	float stat;
	string pic;
	vector color;
#ifdef GMQCC
	stat = -1;
	pic = "";
	color = '0 0 0';
#endif
	switch(i)
	{
		case 0:
			stat = getstati(STAT_REDALIVE);
			pic = "player_red.tga";
			color = '1 0 0';
			break;
		case 1:
			stat = getstati(STAT_BLUEALIVE);
			pic = "player_blue.tga";
			color = '0 0 1';
			break;
		case 2:
			stat = getstati(STAT_YELLOWALIVE);
			pic = "player_yellow.tga";
			color = '1 1 0';
			break;
		default:
		case 3:
			stat = getstati(STAT_PINKALIVE);
			pic = "player_pink.tga";
			color = '1 0 1';
			break;
	}

	if(mySize_x/mySize_y > aspect_ratio)
	{
		i = aspect_ratio * mySize_y;
		myPos_x = myPos_x + (mySize_x - i) / 2;
		mySize_x = i;
	}
	else
	{
		i = 1/aspect_ratio * mySize_x;
		myPos_y = myPos_y + (mySize_y - i) / 2;
		mySize_y = i;
	}

	if(layout)
	{
		drawpic_aspect_skin(myPos, pic, eX * 0.7 * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(myPos + eX * 0.7 * mySize_x, ftos(stat), eX * 0.3 * mySize_x + eY * mySize_y, color, panel_fg_alpha, DRAWFLAG_NORMAL);
	}
	else
		drawstring_aspect(myPos, ftos(stat), mySize, color, panel_fg_alpha, DRAWFLAG_NORMAL);
}

// Clan Arena and Freeze Tag HUD modicons
void HUD_Mod_CA(vector myPos, vector mySize)
{
	mod_active = 1; // required in each mod function that always shows something

	float layout;
	if(gametype == MAPINFO_TYPE_CA)
		layout = autocvar_hud_panel_modicons_ca_layout;
	else //if(gametype == MAPINFO_TYPE_FREEZETAG)
		layout = autocvar_hud_panel_modicons_freezetag_layout;
	float rows, columns, aspect_ratio;
	rows = mySize_y/mySize_x;
	aspect_ratio = (layout) ? 2 : 1;
	rows = bound(1, floor((sqrt((4 * aspect_ratio * team_count + rows) * rows) + rows + 0.5) / 2), team_count);
	columns = ceil(team_count/rows);

	int i;
	float row = 0, column = 0;
	vector pos, itemSize;
	itemSize = eX * mySize_x*(1/columns) + eY * mySize_y*(1/rows);
	for(i=0; i<team_count; ++i)
	{
		pos = myPos + eX * column * itemSize_x + eY * row * itemSize_y;

		DrawCAItem(pos, itemSize, aspect_ratio, layout, i);

		++row;
		if(row >= rows)
		{
			row = 0;
			++column;
		}
	}
}

// VIP mod icons
float redvip_prevframe, bluevip_prevframe, yellowvip_prevframe, pinkvip_prevframe; // status during previous frame
float redvip_prevstatus, bluevip_prevstatus, yellowvip_prevstatus, pinkvip_prevstatus; // last remembered status
float redvip_statuschange_time, bluevip_statuschange_time, yellowvip_statuschange_time, pinkvip_statuschange_time; // time when the status changed
void HUD_Mod_VIP_Reset(void)
{
	redvip_prevstatus = bluevip_prevstatus = yellowvip_prevstatus = pinkvip_prevstatus = redvip_prevframe = bluevip_prevframe = yellowvip_prevframe = pinkvip_prevframe = redvip_statuschange_time = bluevip_statuschange_time = yellowvip_statuschange_time = pinkvip_statuschange_time = 0;
}
void HUD_Mod_VIP(vector pos, vector mySize)
{
	vector redvip_pos, bluevip_pos, yellowvip_pos, pinkvip_pos;
	vector vip_size;
	vector e1, e2;
	float size1, size2;
	float fs, fs2, fs3;
	float f; // every function should have that

	float redvip, bluevip, yellowvip, pinkvip, is_vip; // current status
	float redvip_statuschange_elapsedtime, bluevip_statuschange_elapsedtime, yellowvip_statuschange_elapsedtime, pinkvip_statuschange_elapsedtime; // time since the status changed
	
	redvip = (getstatf(STAT_VIP_RED) != 0);
	bluevip = (getstatf(STAT_VIP_BLUE) != 0);
	yellowvip = (getstatf(STAT_VIP_YELLOW) != 0);
	pinkvip = (getstatf(STAT_VIP_PINK) != 0);
	is_vip = (getstati(STAT_VIP) != 0);
	
	if(redvip || bluevip || yellowvip || pinkvip)
		mod_active = 1;
	else
		mod_active = 0;

	// when status CHANGES, set old status into prevstatus and current status into status
	if (redvip != redvip_prevframe)
	{
		redvip_statuschange_time = time;
		redvip_prevstatus = redvip_prevframe;
		redvip_prevframe = redvip;
	}

	if (bluevip != bluevip_prevframe)
	{
		bluevip_statuschange_time = time;
		bluevip_prevstatus = bluevip_prevframe;
		bluevip_prevframe = bluevip;
	}
	
	if (yellowvip != yellowvip_prevframe)
	{
		yellowvip_statuschange_time = time;
		yellowvip_prevstatus = yellowvip_prevframe;
		yellowvip_prevframe = yellowvip;
	}
	
	if (pinkvip != pinkvip_prevframe)
	{
		pinkvip_statuschange_time = time;
		pinkvip_prevstatus = pinkvip_prevframe;
		pinkvip_prevframe = pinkvip;
	}

	redvip_statuschange_elapsedtime = time - redvip_statuschange_time;
	bluevip_statuschange_elapsedtime = time - bluevip_statuschange_time;
	yellowvip_statuschange_elapsedtime = time - yellowvip_statuschange_time;
	pinkvip_statuschange_elapsedtime = time - pinkvip_statuschange_time;
	
	switch(team_count)
	{
		default:
		case 2: fs = 0.5; fs2 = 0.5; fs3 = 0.5; break;
		case 3: fs = 1; fs2 = 0.35; fs3 = 0.35; break;
		case 4: fs = 0.75; fs2 = 0.25; fs3 = 0.5; break;
	}
	
	if(mySize_x > mySize_y)
	{
		size1 = mySize_x;
		size2 = mySize_y;
		e1 = eX;
		e2 = eY;
	}
	else
	{
		size1 = mySize_y;
		size2 = mySize_x;
		e1 = eY;
		e2 = eX;
	}
	
	switch(myteam)
	{
		default:
		case NUM_TEAM_1:
		{
			redvip_pos = pos;
			bluevip_pos = pos + eX * fs2 * size1;
			yellowvip_pos = pos - eX * fs2 * size1;
			pinkvip_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_2:
		{
			redvip_pos = pos + eX * fs2 * size1;
			bluevip_pos = pos;
			yellowvip_pos = pos - eX * fs2 * size1;
			pinkvip_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_3:
		{
			redvip_pos = pos + eX * fs3 * size1;
			bluevip_pos = pos - eX * fs2 * size1;
			yellowvip_pos = pos;
			pinkvip_pos = pos + eX * fs2 * size1;
			break;
		}
		case NUM_TEAM_4:
		{
			redvip_pos = pos - eX * fs2 * size1;
			bluevip_pos = pos + eX * fs3 * size1;
			yellowvip_pos = pos + eX * fs2 * size1;
			pinkvip_pos = pos;
			break;
		}
	}
	vip_size = e1 * fs * size1 + e2 * size2;
	
	string red_icon = "", red_icon_prevstatus = "";
	string blue_icon = "", blue_icon_prevstatus = "";
	string yellow_icon = "", yellow_icon_prevstatus = "";
	string pink_icon = "", pink_icon_prevstatus = "";
	
	if(redvip) { red_icon = "player_red"; }
	if(bluevip) { blue_icon = "player_blue"; }
	if(yellowvip) { yellow_icon = "player_yellow"; }
	if(pinkvip) { pink_icon = "player_pink"; }

	if(redvip_prevframe) { red_icon_prevstatus = "player_red"; }
	if(bluevip_prevframe) { blue_icon_prevstatus = "player_blue"; }
	if(yellowvip_prevframe) { yellow_icon_prevstatus = "player_yellow"; }
	if(pinkvip_prevframe) { pink_icon_prevstatus = "player_pink"; }

	if(is_vip)
	switch(myteam)
	{
		case NUM_TEAM_1: red_icon = "notify_balldropped"; break;
		case NUM_TEAM_2: blue_icon = "notify_balldropped"; break;
		case NUM_TEAM_3: yellow_icon = "notify_balldropped"; break;
		case NUM_TEAM_4: pink_icon = "notify_balldropped"; break;
	}

	f = bound(0, redvip_statuschange_elapsedtime*2, 1);
	if(red_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(redvip_pos, red_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(red_icon)
		drawpic_aspect_skin(redvip_pos, red_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);

	f = bound(0, bluevip_statuschange_elapsedtime*2, 1);
	if(blue_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(bluevip_pos, blue_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(blue_icon)
		drawpic_aspect_skin(bluevip_pos, blue_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);
		
	f = bound(0, yellowvip_statuschange_elapsedtime*2, 1);
	if(yellow_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(yellowvip_pos, yellow_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(yellow_icon)
		drawpic_aspect_skin(yellowvip_pos, yellow_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);
		
	f = bound(0, pinkvip_statuschange_elapsedtime*2, 1);
	if(pink_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(pinkvip_pos, pink_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(pink_icon)
		drawpic_aspect_skin(pinkvip_pos, pink_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);
}

// CTF HUD modicon section
float redflag_prevframe, blueflag_prevframe, yellowflag_prevframe, pinkflag_prevframe; // status during previous frame
float redflag_prevstatus, blueflag_prevstatus, yellowflag_prevstatus, pinkflag_prevstatus; // last remembered status
float redflag_statuschange_time, blueflag_statuschange_time, yellowflag_statuschange_time, pinkflag_statuschange_time; // time when the status changed

void HUD_Mod_CTF_Reset(void)
{
	redflag_prevstatus = blueflag_prevstatus = yellowflag_prevstatus = pinkflag_prevstatus = 0;
	redflag_prevframe = blueflag_prevframe = yellowflag_prevframe = pinkflag_prevframe = 0;
	redflag_statuschange_time = blueflag_statuschange_time = yellowflag_statuschange_time = pinkflag_statuschange_time = 0;
}

void HUD_Mod_CTF(vector pos, vector mySize)
{
	vector redflag_pos, blueflag_pos, yellowflag_pos, pinkflag_pos;
	vector flag_size;
	float f; // every function should have that

	float redflag, blueflag, yellowflag, pinkflag; // current status
	float redflag_statuschange_elapsedtime, blueflag_statuschange_elapsedtime, yellowflag_statuschange_elapsedtime, pinkflag_statuschange_elapsedtime; // time since the status changed
	float stat_items;
	float fs, fs2, fs3, size1, size2;
	vector e1, e2;

	stat_items = getstati(STAT_ITEMS, 0, 24);
	redflag = (stat_items/IT_RED_FLAG_TAKEN) & 3;
	blueflag = (stat_items/IT_BLUE_FLAG_TAKEN) & 3;
	yellowflag = (stat_items/IT_YELLOW_FLAG_TAKEN) & 3;
	pinkflag = (stat_items/IT_PINK_FLAG_TAKEN) & 3;

	if(redflag || blueflag || yellowflag || pinkflag)
		mod_active = 1;
	else
		mod_active = 0;

	if(autocvar__hud_configure)
	{
		redflag = 1;
		blueflag = 2;
		if(team_count >= 3)
			yellowflag = 2;
		if(team_count >= 4)
			pinkflag = 3;
	}

	// when status CHANGES, set old status into prevstatus and current status into status
	if (redflag != redflag_prevframe)
	{
		redflag_statuschange_time = time;
		redflag_prevstatus = redflag_prevframe;
		redflag_prevframe = redflag;
	}

	if (blueflag != blueflag_prevframe)
	{
		blueflag_statuschange_time = time;
		blueflag_prevstatus = blueflag_prevframe;
		blueflag_prevframe = blueflag;
	}

	if (yellowflag != yellowflag_prevframe)
	{
		yellowflag_statuschange_time = time;
		yellowflag_prevstatus = yellowflag_prevframe;
		yellowflag_prevframe = yellowflag;
	}

	if (pinkflag != pinkflag_prevframe)
	{
		pinkflag_statuschange_time = time;
		pinkflag_prevstatus = pinkflag_prevframe;
		pinkflag_prevframe = pinkflag;
	}

	redflag_statuschange_elapsedtime = time - redflag_statuschange_time;
	blueflag_statuschange_elapsedtime = time - blueflag_statuschange_time;
	yellowflag_statuschange_elapsedtime = time - yellowflag_statuschange_time;
	pinkflag_statuschange_elapsedtime = time - pinkflag_statuschange_time;

	float BLINK_FACTOR = 0.15;
	float BLINK_BASE = 0.85;
	// note:
	//   RMS = sqrt(BLINK_BASE^2 + 0.5 * BLINK_FACTOR^2)
	// thus
	//   BLINK_BASE = sqrt(RMS^2 - 0.5 * BLINK_FACTOR^2)
	// ensure RMS == 1
	float BLINK_FREQ = 5; // circle frequency, = 2*pi*frequency in hertz

	string red_icon, red_icon_prevstatus;
	float red_alpha, red_alpha_prevstatus;
	red_alpha = red_alpha_prevstatus = 1;
	switch(redflag) {
		case 1: red_icon = "flag_red_taken"; break;
		case 2: red_icon = "flag_red_lost"; break;
		case 3: red_icon = "flag_red_carrying"; red_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_1))
				red_icon = "flag_red_shielded";
			else
				red_icon = string_null;
			break;
	}
	switch(redflag_prevstatus) {
		case 1: red_icon_prevstatus = "flag_red_taken"; break;
		case 2: red_icon_prevstatus = "flag_red_lost"; break;
		case 3: red_icon_prevstatus = "flag_red_carrying"; red_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(redflag == 3)
				red_icon_prevstatus = "flag_red_carrying"; // make it more visible
			else if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_1))
				red_icon_prevstatus = "flag_red_shielded";
			else
				red_icon_prevstatus = string_null;
			break;
	}

	string blue_icon, blue_icon_prevstatus;
	float blue_alpha, blue_alpha_prevstatus;
	blue_alpha = blue_alpha_prevstatus = 1;
	switch(blueflag) {
		case 1: blue_icon = "flag_blue_taken"; break;
		case 2: blue_icon = "flag_blue_lost"; break;
		case 3: blue_icon = "flag_blue_carrying"; blue_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_2))
				blue_icon = "flag_blue_shielded";
			else
				blue_icon = string_null;
			break;
	}
	switch(blueflag_prevstatus) {
		case 1: blue_icon_prevstatus = "flag_blue_taken"; break;
		case 2: blue_icon_prevstatus = "flag_blue_lost"; break;
		case 3: blue_icon_prevstatus = "flag_blue_carrying"; blue_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(blueflag == 3)
				blue_icon_prevstatus = "flag_blue_carrying"; // make it more visible
			else if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_2))
				blue_icon_prevstatus = "flag_blue_shielded";
			else
				blue_icon_prevstatus = string_null;
			break;
	}

	string yellow_icon, yellow_icon_prevstatus;
	float yellow_alpha, yellow_alpha_prevstatus;
	yellow_alpha = yellow_alpha_prevstatus = 1;
	switch(yellowflag) {
		case 1: yellow_icon = "flag_yellow_taken"; break;
		case 2: yellow_icon = "flag_yellow_lost"; break;
		case 3: yellow_icon = "flag_yellow_carrying"; yellow_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_3))
				yellow_icon = "flag_yellow_shielded";
			else
				yellow_icon = string_null;
			break;
	}
	switch(yellowflag_prevstatus) {
		case 1: yellow_icon_prevstatus = "flag_yellow_taken"; break;
		case 2: yellow_icon_prevstatus = "flag_yellow_lost"; break;
		case 3: yellow_icon_prevstatus = "flag_yellow_carrying"; yellow_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(yellowflag == 3)
				yellow_icon_prevstatus = "flag_yellow_carrying"; // make it more visible
			else if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_3))
				yellow_icon_prevstatus = "flag_yellow_shielded";
			else
				yellow_icon_prevstatus = string_null;
			break;
	}
	
	string pink_icon, pink_icon_prevstatus;
	float pink_alpha, pink_alpha_prevstatus;
	pink_alpha = pink_alpha_prevstatus = 1;
	switch(pinkflag) {
		case 1: pink_icon = "flag_pink_taken"; break;
		case 2: pink_icon = "flag_pink_lost"; break;
		case 3: pink_icon = "flag_pink_carrying"; pink_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_4))
				pink_icon = "flag_pink_shielded";
			else
				pink_icon = string_null;
			break;
	}
	switch(pinkflag_prevstatus) {
		case 1: pink_icon_prevstatus = "flag_pink_taken"; break;
		case 2: pink_icon_prevstatus = "flag_pink_lost"; break;
		case 3: pink_icon_prevstatus = "flag_pink_carrying"; pink_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(pinkflag == 3)
				pink_icon_prevstatus = "flag_pink_carrying"; // make it more visible
			else if((stat_items & IT_CTF_SHIELDED) && (myteam != NUM_TEAM_4))
				pink_icon_prevstatus = "flag_pink_shielded";
			else
				pink_icon_prevstatus = string_null;
			break;
	}
	
	switch(team_count)
	{
		default:
		case 2: fs = 0.5; fs2 = 0.5; fs3 = 0.5; break;
		case 3: fs = 1; fs2 = 0.35; fs3 = 0.35; break;
		case 4: fs = 0.75; fs2 = 0.25; fs3 = 0.5; break;
	}
	
	if(mySize_x > mySize_y)
	{
		size1 = mySize_x;
		size2 = mySize_y;
		e1 = eX;
		e2 = eY;
	}
	else
	{
		size1 = mySize_y;
		size2 = mySize_x;
		e1 = eY;
		e2 = eX;
	}
	
	switch(myteam)
	{
		default:
		case NUM_TEAM_1:
		{
			redflag_pos = pos;
			blueflag_pos = pos + eX * fs2 * size1;
			yellowflag_pos = pos - eX * fs2 * size1;
			pinkflag_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_2:
		{
			redflag_pos = pos + eX * fs2 * size1;
			blueflag_pos = pos;
			yellowflag_pos = pos - eX * fs2 * size1;
			pinkflag_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_3:
		{
			redflag_pos = pos + eX * fs3 * size1;
			blueflag_pos = pos - eX * fs2 * size1;
			yellowflag_pos = pos;
			pinkflag_pos = pos + eX * fs2 * size1;
			break;
		}
		case NUM_TEAM_4:
		{
			redflag_pos = pos - eX * fs2 * size1;
			blueflag_pos = pos + eX * fs3 * size1;
			yellowflag_pos = pos + eX * fs2 * size1;
			pinkflag_pos = pos;
			break;
		}
	}
	flag_size = e1 * fs * size1 + e2 * size2;

	f = bound(0, redflag_statuschange_elapsedtime*2, 1);
	if(red_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(redflag_pos, red_icon_prevstatus, flag_size, '1 1 1', panel_fg_alpha * red_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(red_icon)
		drawpic_aspect_skin(redflag_pos, red_icon, flag_size, '1 1 1', panel_fg_alpha * red_alpha * f, DRAWFLAG_NORMAL);

	f = bound(0, blueflag_statuschange_elapsedtime*2, 1);
	if(blue_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(blueflag_pos, blue_icon_prevstatus, flag_size, '1 1 1', panel_fg_alpha * blue_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(blue_icon)
		drawpic_aspect_skin(blueflag_pos, blue_icon, flag_size, '1 1 1', panel_fg_alpha * blue_alpha * f, DRAWFLAG_NORMAL);

	f = bound(0, yellowflag_statuschange_elapsedtime*2, 1);
	if(yellow_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(yellowflag_pos, yellow_icon_prevstatus, flag_size, '1 1 1', panel_fg_alpha * yellow_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(yellow_icon)
		drawpic_aspect_skin(yellowflag_pos, yellow_icon, flag_size, '1 1 1', panel_fg_alpha * yellow_alpha * f, DRAWFLAG_NORMAL);
		
	f = bound(0, pinkflag_statuschange_elapsedtime*2, 1);
	if(pink_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(pinkflag_pos, pink_icon_prevstatus, flag_size, '1 1 1', panel_fg_alpha * pink_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(pink_icon)
		drawpic_aspect_skin(pinkflag_pos, pink_icon, flag_size, '1 1 1', panel_fg_alpha * pink_alpha * f, DRAWFLAG_NORMAL);
}

// Keyhunt HUD modicon section
float redkey_prevframe, bluekey_prevframe, yellowkey_prevframe, pinkkey_prevframe; // status during previous frame
float redkey_prevstatus, bluekey_prevstatus, yellowkey_prevstatus, pinkkey_prevstatus; // last remembered status
float redkey_statuschange_time, bluekey_statuschange_time, yellowkey_statuschange_time, pinkkey_statuschange_time; // time when the status changed

void HUD_Mod_KH_Reset(void)
{
	redkey_prevstatus = bluekey_prevstatus = yellowkey_prevstatus = pinkkey_prevstatus = 0;
	redkey_prevframe = bluekey_prevframe = yellowkey_prevframe = pinkkey_prevframe = 0;
	redkey_statuschange_time = bluekey_statuschange_time = yellowkey_statuschange_time = pinkkey_statuschange_time = 0;
}

void HUD_Mod_KH(vector pos, vector mySize)
{
	vector redkey_pos, bluekey_pos, yellowkey_pos, pinkkey_pos;
	vector key_size;
	float f; // every function should have that

	float redkey, bluekey, yellowkey, pinkkey; // current status
	float redkey_statuschange_elapsedtime, bluekey_statuschange_elapsedtime, yellowkey_statuschange_elapsedtime, pinkkey_statuschange_elapsedtime; // time since the status changed
	float stat_items;
	float fs, fs2, fs3, size1, size2;
	vector e1, e2;

	stat_items = getstati(STAT_ITEMS, 0, 24);
	redkey = (stat_items/IT_RED_FLAG_TAKEN) & 3;
	bluekey = (stat_items/IT_BLUE_FLAG_TAKEN) & 3;
	yellowkey = (stat_items/IT_YELLOW_FLAG_TAKEN) & 3;
	pinkkey = (stat_items/IT_PINK_FLAG_TAKEN) & 3;

	if(redkey || bluekey || yellowkey || pinkkey)
		mod_active = 1;
	else
		mod_active = 0;

	if(autocvar__hud_configure)
	{
		redkey = 1;
		bluekey = 2;
		if(team_count >= 3)
			yellowkey = 2;
		if(team_count >= 4)
			pinkkey = 3;
	}

	// when status CHANGES, set old status into prevstatus and current status into status
	if (redkey != redkey_prevframe)
	{
		redkey_statuschange_time = time;
		redkey_prevstatus = redkey_prevframe;
		redkey_prevframe = redkey;
	}

	if (bluekey != bluekey_prevframe)
	{
		bluekey_statuschange_time = time;
		bluekey_prevstatus = bluekey_prevframe;
		bluekey_prevframe = bluekey;
	}

	if (yellowkey != yellowkey_prevframe)
	{
		yellowkey_statuschange_time = time;
		yellowkey_prevstatus = yellowkey_prevframe;
		yellowkey_prevframe = yellowkey;
	}

	if (pinkkey != pinkkey_prevframe)
	{
		pinkkey_statuschange_time = time;
		pinkkey_prevstatus = pinkkey_prevframe;
		pinkkey_prevframe = pinkkey;
	}

	redkey_statuschange_elapsedtime = time - redkey_statuschange_time;
	bluekey_statuschange_elapsedtime = time - bluekey_statuschange_time;
	yellowkey_statuschange_elapsedtime = time - yellowkey_statuschange_time;
	pinkkey_statuschange_elapsedtime = time - pinkkey_statuschange_time;

	float BLINK_FACTOR = 0.15;
	float BLINK_BASE = 0.85;
	// note:
	//   RMS = sqrt(BLINK_BASE^2 + 0.5 * BLINK_FACTOR^2)
	// thus
	//   BLINK_BASE = sqrt(RMS^2 - 0.5 * BLINK_FACTOR^2)
	// ensure RMS == 1
	float BLINK_FREQ = 5; // circle frequency, = 2*pi*frequency in hertz

	string red_icon, red_icon_prevstatus;
	float red_alpha, red_alpha_prevstatus;
	red_alpha = red_alpha_prevstatus = 1;
	switch(redkey) {
		case 1: red_icon = "kh_red_key"; break;
		case 2: red_icon = string_null; break;
		case 3: red_icon = "kh_red_key"; red_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			red_icon = string_null;
			break;
	}
	switch(redkey_prevstatus) {
		case 1: red_icon_prevstatus = "kh_red_key"; break;
		case 2: red_icon_prevstatus = string_null; break;
		case 3: red_icon_prevstatus = "kh_red_key"; red_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(redkey == 3)
				red_icon_prevstatus = "kh_red_key"; // make it more visible
			else
				red_icon_prevstatus = string_null;
			break;
	}

	string blue_icon, blue_icon_prevstatus;
	float blue_alpha, blue_alpha_prevstatus;
	blue_alpha = blue_alpha_prevstatus = 1;
	switch(bluekey) {
		case 1: blue_icon = "kh_blue_key"; break;
		case 2: blue_icon = string_null; break;
		case 3: blue_icon = "kh_blue_key"; blue_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			blue_icon = string_null;
			break;
	}
	switch(bluekey_prevstatus) {
		case 1: blue_icon_prevstatus = "kh_blue_key"; break;
		case 2: blue_icon_prevstatus = string_null; break;
		case 3: blue_icon_prevstatus = "kh_blue_key"; blue_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(bluekey == 3)
				blue_icon_prevstatus = "kh_blue_key"; // make it more visible
			else
				blue_icon_prevstatus = string_null;
			break;
	}

	string yellow_icon, yellow_icon_prevstatus;
	float yellow_alpha, yellow_alpha_prevstatus;
	yellow_alpha = yellow_alpha_prevstatus = 1;
	switch(yellowkey) {
		case 1: yellow_icon = "kh_yellow_key"; break;
		case 2: yellow_icon = string_null; break;
		case 3: yellow_icon = "kh_yellow_key"; yellow_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			yellow_icon = string_null;
			break;
	}
	switch(yellowkey_prevstatus) {
		case 1: yellow_icon_prevstatus = "kh_yellow_key"; break;
		case 2: yellow_icon_prevstatus = string_null; break;
		case 3: yellow_icon_prevstatus = "kh_yellow_key"; yellow_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(yellowkey == 3)
				yellow_icon_prevstatus = "kh_yellow_key"; // make it more visible
			else
				yellow_icon_prevstatus = string_null;
			break;
	}
	
	string pink_icon, pink_icon_prevstatus;
	float pink_alpha, pink_alpha_prevstatus;
	pink_alpha = pink_alpha_prevstatus = 1;
	switch(pinkkey) {
		case 1: pink_icon = "kh_pink_key"; break;
		case 2: pink_icon = string_null; break;
		case 3: pink_icon = "kh_pink_key"; pink_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			pink_icon = string_null;
			break;
	}
	switch(pinkkey_prevstatus) {
		case 1: pink_icon_prevstatus = "kh_pink_key"; break;
		case 2: pink_icon_prevstatus = string_null; break;
		case 3: pink_icon_prevstatus = "kh_pink_key"; pink_alpha_prevstatus = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ); break;
		default:
			if(pinkkey == 3)
				pink_icon_prevstatus = "kh_pink_key"; // make it more visible
			else
				pink_icon_prevstatus = string_null;
			break;
	}
	
	switch(team_count)
	{
		default:
		case 2: fs = 0.5; fs2 = 0.5; fs3 = 0.5; break;
		case 3: fs = 1; fs2 = 0.35; fs3 = 0.35; break;
		case 4: fs = 0.75; fs2 = 0.25; fs3 = 0.5; break;
	}
	
	if(mySize_x > mySize_y)
	{
		size1 = mySize_x;
		size2 = mySize_y;
		e1 = eX;
		e2 = eY;
	}
	else
	{
		size1 = mySize_y;
		size2 = mySize_x;
		e1 = eY;
		e2 = eX;
	}
	
	switch(myteam)
	{
		default:
		case NUM_TEAM_1:
		{
			redkey_pos = pos;
			bluekey_pos = pos + eX * fs2 * size1;
			yellowkey_pos = pos - eX * fs2 * size1;
			pinkkey_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_2:
		{
			redkey_pos = pos + eX * fs2 * size1;
			bluekey_pos = pos;
			yellowkey_pos = pos - eX * fs2 * size1;
			pinkkey_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_3:
		{
			redkey_pos = pos + eX * fs3 * size1;
			bluekey_pos = pos - eX * fs2 * size1;
			yellowkey_pos = pos;
			pinkkey_pos = pos + eX * fs2 * size1;
			break;
		}
		case NUM_TEAM_4:
		{
			redkey_pos = pos - eX * fs2 * size1;
			bluekey_pos = pos + eX * fs3 * size1;
			yellowkey_pos = pos + eX * fs2 * size1;
			pinkkey_pos = pos;
			break;
		}
	}
	key_size = e1 * fs * size1 + e2 * size2;

	f = bound(0, redkey_statuschange_elapsedtime*2, 1);
	if(red_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(redkey_pos + '0 0.3 0' * key_size_y, red_icon_prevstatus, key_size, '1 1 1', panel_fg_alpha * red_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(red_icon)
		drawpic_aspect_skin(redkey_pos + '0 0.3 0' * key_size_y, red_icon, key_size, '1 1 1', panel_fg_alpha * red_alpha * f, DRAWFLAG_NORMAL);
		
	string carrier_icon = string_null;
	switch(getstati(STAT_KH_REDKEY_TEAM))
	{
		case 1: carrier_icon = "kh_red_arrow"; break;
		case 2: carrier_icon = "kh_blue_arrow"; break;
		case 3: carrier_icon = "kh_yellow_arrow"; break;
		case 4: carrier_icon = "kh_pink_arrow"; break;
	}
	if(carrier_icon)
		drawpic_aspect_skin(redkey_pos, carrier_icon, ('1 0 0' * key_size_x) + ('0 0.3 0' * key_size_y) + ('0 0 1' * key_size_z), '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);

	f = bound(0, bluekey_statuschange_elapsedtime*2, 1);
	if(blue_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(bluekey_pos + '0 0.3 0' * key_size_y, blue_icon_prevstatus, key_size, '1 1 1', panel_fg_alpha * blue_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(blue_icon)
		drawpic_aspect_skin(bluekey_pos + '0 0.3 0' * key_size_y, blue_icon, key_size, '1 1 1', panel_fg_alpha * blue_alpha * f, DRAWFLAG_NORMAL);
		
	carrier_icon = string_null;
	switch(getstati(STAT_KH_BLUEKEY_TEAM))
	{
		case 1: carrier_icon = "kh_red_arrow"; break;
		case 2: carrier_icon = "kh_blue_arrow"; break;
		case 3: carrier_icon = "kh_yellow_arrow"; break;
		case 4: carrier_icon = "kh_pink_arrow"; break;
	}
	if(carrier_icon)
		drawpic_aspect_skin(bluekey_pos, carrier_icon, ('1 0 0' * key_size_x) + ('0 0.3 0' * key_size_y) + ('0 0 1' * key_size_z), '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		
	f = bound(0, yellowkey_statuschange_elapsedtime*2, 1);
	if(yellow_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(yellowkey_pos + '0 0.3 0' * key_size_y, yellow_icon_prevstatus, key_size, '1 1 1', panel_fg_alpha * yellow_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(yellow_icon)
		drawpic_aspect_skin(yellowkey_pos + '0 0.3 0' * key_size_y, yellow_icon, key_size, '1 1 1', panel_fg_alpha * yellow_alpha * f, DRAWFLAG_NORMAL);
		
	carrier_icon = string_null;
	switch(getstati(STAT_KH_YELLOWKEY_TEAM))
	{
		case 1: carrier_icon = "kh_red_arrow"; break;
		case 2: carrier_icon = "kh_blue_arrow"; break;
		case 3: carrier_icon = "kh_yellow_arrow"; break;
		case 4: carrier_icon = "kh_pink_arrow"; break;
	}
	if(carrier_icon)
		drawpic_aspect_skin(yellowkey_pos, carrier_icon, ('1 0 0' * key_size_x) + ('0 0.3 0' * key_size_y) + ('0 0 1' * key_size_z), '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		
	f = bound(0, pinkkey_statuschange_elapsedtime*2, 1);
	if(pink_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(pinkkey_pos + '0 0.3 0' * key_size_y, pink_icon_prevstatus, key_size, '1 1 1', panel_fg_alpha * pink_alpha_prevstatus, DRAWFLAG_NORMAL, f);
	if(pink_icon)
		drawpic_aspect_skin(pinkkey_pos + '0 0.3 0' * key_size_y, pink_icon, key_size, '1 1 1', panel_fg_alpha * pink_alpha * f, DRAWFLAG_NORMAL);
		
	carrier_icon = string_null;
	switch(getstati(STAT_KH_PINKKEY_TEAM))
	{
		case 1: carrier_icon = "kh_red_arrow"; break;
		case 2: carrier_icon = "kh_blue_arrow"; break;
		case 3: carrier_icon = "kh_yellow_arrow"; break;
		case 4: carrier_icon = "kh_pink_arrow"; break;
	}
	if(carrier_icon)
		drawpic_aspect_skin(pinkkey_pos, carrier_icon, ('1 0 0' * key_size_x) + ('0 0.3 0' * key_size_y) + ('0 0 1' * key_size_z), '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
}

// Keepaway HUD mod icon
float kaball_prevstatus; // last remembered status
float kaball_statuschange_time; // time when the status changed

// we don't need to reset for keepaway since it immediately
// autocorrects prevstatus as to if the player has the ball or not

void HUD_Mod_Keepaway(vector pos, vector mySize)
{
	mod_active = 1; // keepaway should always show the mod HUD

	float BLINK_FACTOR = 0.15;
	float BLINK_BASE = 0.85;
	float BLINK_FREQ = 5;
	float kaball_alpha = BLINK_BASE + BLINK_FACTOR * cos(time * BLINK_FREQ);

	float stat_items = getstati(STAT_ITEMS, 0, 24);
	float kaball = (stat_items/IT_KEY1) & 1;

	if(kaball != kaball_prevstatus)
	{
		kaball_statuschange_time = time;
		kaball_prevstatus = kaball;
	}

	vector kaball_pos, kaball_size;

	if(mySize_x > mySize_y) {
		kaball_pos = pos + eX * 0.25 * mySize_x;
		kaball_size = eX * 0.5 * mySize_x + eY * mySize_y;
	} else {
		kaball_pos = pos + eY * 0.25 * mySize_y;
		kaball_size = eY * 0.5 * mySize_y + eX * mySize_x;
	}

	float kaball_statuschange_elapsedtime = time - kaball_statuschange_time;
	float f = bound(0, kaball_statuschange_elapsedtime*2, 1);

	if(kaball_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(kaball_pos, "keepawayball_carrying", kaball_size, '1 1 1', panel_fg_alpha * kaball_alpha, DRAWFLAG_NORMAL, f);

	if(kaball)
		drawpic_aspect_skin(pos, "keepawayball_carrying", eX * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha * kaball_alpha * f, DRAWFLAG_NORMAL);
}


// Nexball HUD mod icon
void HUD_Mod_NexBall(vector pos, vector mySize)
{
	float stat_items, nb_pb_starttime, dt, p;

	stat_items = getstati(STAT_ITEMS, 0, 24);
	nb_pb_starttime = getstatf(STAT_NB_METERSTART);

	if (stat_items & IT_KEY1)
		mod_active = 1;
	else
		mod_active = 0;

	//Manage the progress bar if any
	if (nb_pb_starttime > 0)
	{
		dt = mod(time - nb_pb_starttime, nb_pb_period);
		// one period of positive triangle
		p = 2 * dt / nb_pb_period;
		if (p > 1)
			p = 2 - p;

		HUD_Panel_DrawProgressBar(pos, mySize, "progressbar", p, (mySize_x <= mySize_y), 0, autocvar_hud_progressbar_nexball_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
	}

	if (stat_items & IT_KEY1)
		drawpic_aspect_skin(pos, "nexball_carrying", eX * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
}

// Race/CTS HUD mod icons
float crecordtime_prev; // last remembered crecordtime
float crecordtime_change_time; // time when crecordtime last changed
float srecordtime_prev; // last remembered srecordtime
float srecordtime_change_time; // time when srecordtime last changed

float race_status_time;
float race_status_prev;
string race_status_name_prev;
void HUD_Mod_Race(vector pos, vector mySize)
{
	mod_active = 1; // race should never hide the mod icons panel
	entity me;
	me = playerslots[player_localnum];
	float t, score;
	float f; // yet another function has this
	score = me.(scores[ps_primary]);

	if(!(scores_flags[ps_primary] & SFL_TIME) || teamplay) // race/cts record display on HUD
		return; // no records in the actual race

	// clientside personal record
	string rr;
	if(gametype == MAPINFO_TYPE_CTS)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;
	t = stof(db_get(ClientProgsDB, strcat(shortmapname, rr, "time")));

	if(score && (score < t || !t)) {
		db_put(ClientProgsDB, strcat(shortmapname, rr, "time"), ftos(score));
		if(autocvar_cl_autodemo_delete_keeprecords)
		{
			f = autocvar_cl_autodemo_delete;
			f &= ~1;
			cvar_set("cl_autodemo_delete", ftos(f)); // don't delete demo with new record!
		}
	}

	if(t != crecordtime_prev) {
		crecordtime_prev = t;
		crecordtime_change_time = time;
	}

	vector textPos, medalPos;
	float squareSize;
	if(mySize_x > mySize_y) {
		// text on left side
		squareSize = min(mySize_y, mySize_x/2);
		textPos = pos + eX * 0.5 * max(0, mySize_x/2 - squareSize) + eY * 0.5 * (mySize_y - squareSize);
		medalPos = pos + eX * 0.5 * max(0, mySize_x/2 - squareSize) + eX * 0.5 * mySize_x + eY * 0.5 * (mySize_y - squareSize);
	} else {
		// text on top
		squareSize = min(mySize_x, mySize_y/2);
		textPos = pos + eY * 0.5 * max(0, mySize_y/2 - squareSize) + eX * 0.5 * (mySize_x - squareSize);
		medalPos = pos + eY * 0.5 * max(0, mySize_y/2 - squareSize) + eY * 0.5 * mySize_y + eX * 0.5 * (mySize_x - squareSize);
	}

	f = time - crecordtime_change_time;

	if (f > 1) {
		drawstring_aspect(textPos, _("Personal best"), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(textPos + eY * 0.25 * squareSize, TIME_ENCODED_TOSTRING(t), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	} else {
		drawstring_aspect(textPos, _("Personal best"), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(textPos + eY * 0.25 * squareSize, TIME_ENCODED_TOSTRING(t), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect_expanding(pos, _("Personal best"), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL, f);
		drawstring_aspect_expanding(pos + eY * 0.25 * squareSize, TIME_ENCODED_TOSTRING(t), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL, f);
	}

	// server record
	t = race_server_record;
	if(t != srecordtime_prev) {
		srecordtime_prev = t;
		srecordtime_change_time = time;
	}
	f = time - srecordtime_change_time;

	if (f > 1) {
		drawstring_aspect(textPos + eY * 0.5 * squareSize, _("Server best"), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(textPos + eY * 0.75 * squareSize, TIME_ENCODED_TOSTRING(t), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	} else {
		drawstring_aspect(textPos + eY * 0.5 * squareSize, _("Server best"), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(textPos + eY * 0.75 * squareSize, TIME_ENCODED_TOSTRING(t), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect_expanding(textPos + eY * 0.5 * squareSize, _("Server best"), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL, f);
		drawstring_aspect_expanding(textPos + eY * 0.75 * squareSize, TIME_ENCODED_TOSTRING(t), eX * squareSize + eY * 0.25 * squareSize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL, f);
	}

	if (race_status != race_status_prev || race_status_name != race_status_name_prev) {
		race_status_time = time + 5;
		race_status_prev = race_status;
		if (race_status_name_prev)
			strunzone(race_status_name_prev);
		race_status_name_prev = strzone(race_status_name);
	}

	// race "awards"
	float a;
	a = bound(0, race_status_time - time, 1);

	string s;
	s = textShortenToWidth(race_status_name, squareSize, '1 1 0' * 0.1 * squareSize, stringwidth_colors);

	float rank;
	if(race_status > 0)
		rank = race_CheckName(race_status_name);
	else
		rank = 0;
	string rankname;
	rankname = count_ordinal(rank);

	vector namepos;
	namepos = medalPos + '0 0.8 0' * squareSize;
	vector rankpos;
	rankpos = medalPos + '0 0.15 0' * squareSize;

	if(race_status == 0)
		drawpic_aspect_skin(medalPos, "race_newfail", '1 1 0' * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
	else if(race_status == 1) {
		drawpic_aspect_skin(medalPos + '0.1 0 0' * squareSize, "race_newtime", '1 1 0' * 0.8 * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
		drawcolorcodedstring_aspect(namepos, s, '1 0.2 0' * squareSize, panel_fg_alpha * a, DRAWFLAG_NORMAL);
		drawstring_aspect(rankpos, rankname, '1 0.15 0' * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
	} else if(race_status == 2) {
		if(race_status_name == GetPlayerName(player_localnum) || !race_myrank || race_myrank < rank)
			drawpic_aspect_skin(medalPos + '0.1 0 0' * squareSize, "race_newrankgreen", '1 1 0' * 0.8 * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
		else
			drawpic_aspect_skin(medalPos + '0.1 0 0' * squareSize, "race_newrankyellow", '1 1 0' * 0.8 * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
		drawcolorcodedstring_aspect(namepos, s, '1 0.2 0' * squareSize, panel_fg_alpha * a, DRAWFLAG_NORMAL);
		drawstring_aspect(rankpos, rankname, '1 0.15 0' * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
	} else if(race_status == 3) {
		drawpic_aspect_skin(medalPos + '0.1 0 0' * squareSize, "race_newrecordserver", '1 1 0' * 0.8 * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
		drawcolorcodedstring_aspect(namepos, s, '1 0.2 0' * squareSize, panel_fg_alpha * a, DRAWFLAG_NORMAL);
		drawstring_aspect(rankpos, rankname, '1 0.15 0' * squareSize, '1 1 1', panel_fg_alpha * a, DRAWFLAG_NORMAL);
	}

	if (race_status_time - time <= 0) {
		race_status_prev = -1;
		race_status = -1;
		if(race_status_name)
			strunzone(race_status_name);
		race_status_name = string_null;
		if(race_status_name_prev)
			strunzone(race_status_name_prev);
		race_status_name_prev = string_null;
	}
}

void DrawDomItem(vector myPos, vector mySize, float aspect_ratio, float layout, float i)
{
	float stat, pps_ratio;
	string pic;
	vector color;
#ifdef GMQCC
	stat = -1;
	pic = "";
	color = '0 0 0';
#endif
	switch(i)
	{
		case 0:
			stat = getstatf(STAT_DOM_PPS_RED);
			pic = "dom_icon_red";
			color = '1 0 0';
			break;
		case 1:
			stat = getstatf(STAT_DOM_PPS_BLUE);
			pic = "dom_icon_blue";
			color = '0 0 1';
			break;
		case 2:
			stat = getstatf(STAT_DOM_PPS_YELLOW);
			pic = "dom_icon_yellow";
			color = '1 1 0';
			break;
		case 3:
			stat = getstatf(STAT_DOM_PPS_PINK);
			pic = "dom_icon_pink";
			color = '1 0 1';
			break;
	}
	pps_ratio = stat / getstatf(STAT_DOM_TOTAL_PPS);

	if(mySize_x/mySize_y > aspect_ratio)
	{
		i = aspect_ratio * mySize_y;
		myPos_x = myPos_x + (mySize_x - i) / 2;
		mySize_x = i;
	}
	else
	{
		i = 1/aspect_ratio * mySize_x;
		myPos_y = myPos_y + (mySize_y - i) / 2;
		mySize_y = i;
	}

	if (layout) // show text too
	{
		//draw the text
		color *= 0.5 + pps_ratio * (1 - 0.5); // half saturated color at min, full saturated at max
		if (layout == 2) // average pps
			drawstring_aspect(myPos + eX * mySize_y, ftos_decimals(stat, 2), eX * (2/3) * mySize_x + eY * mySize_y, color, panel_fg_alpha, DRAWFLAG_NORMAL);
		else // percentage of average pps
			drawstring_aspect(myPos + eX * mySize_y, strcat( ftos(floor(pps_ratio*100 + 0.5)), "%" ), eX * (2/3) * mySize_x + eY * mySize_y, color, panel_fg_alpha, DRAWFLAG_NORMAL);
	}

	//draw the icon
	drawpic_aspect_skin(myPos, pic, '1 1 0' * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	if (stat > 0)
	{
		drawsetcliparea(myPos_x, myPos_y + mySize_y * (1 - pps_ratio), mySize_y, mySize_y * pps_ratio);
		drawpic_aspect_skin(myPos, strcat(pic, "-highlighted"), '1 1 0' * mySize_y, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawresetcliparea();
	}
}

void HUD_Mod_Dom(vector myPos, vector mySize)
{
	mod_active = 1; // required in each mod function that always shows something

	float layout = autocvar_hud_panel_modicons_dom_layout;
	float rows, columns, aspect_ratio;
	rows = mySize_y/mySize_x;
	aspect_ratio = (layout) ? 3 : 1;
	rows = bound(1, floor((sqrt((4 * aspect_ratio * team_count + rows) * rows) + rows + 0.5) / 2), team_count);
	columns = ceil(team_count/rows);

	int i;
	float row = 0, column = 0;
	vector pos, itemSize;
	itemSize = eX * mySize_x*(1/columns) + eY * mySize_y*(1/rows);
	for(i=0; i<team_count; ++i)
	{
		pos = myPos + eX * column * itemSize_x + eY * row * itemSize_y;

		DrawDomItem(pos, itemSize, aspect_ratio, layout, i);

		++row;
		if(row >= rows)
		{
			row = 0;
			++column;
		}
	}
}

void HUD_ModIcons_SetFunc()
{
	switch(gametype)
	{
		case MAPINFO_TYPE_KEYHUNT:		HUD_ModIcons_GameType = HUD_Mod_KH; break;
		case MAPINFO_TYPE_CTF:			HUD_ModIcons_GameType = HUD_Mod_CTF; break;
		case MAPINFO_TYPE_NEXBALL:		HUD_ModIcons_GameType = HUD_Mod_NexBall; break;
		case MAPINFO_TYPE_CTS:
		case MAPINFO_TYPE_RACE:		HUD_ModIcons_GameType = HUD_Mod_Race; break;
		case MAPINFO_TYPE_CA:
		case MAPINFO_TYPE_JAILBREAK:
		case MAPINFO_TYPE_FREEZETAG:	HUD_ModIcons_GameType = HUD_Mod_CA; break;
		case MAPINFO_TYPE_DOMINATION:	HUD_ModIcons_GameType = HUD_Mod_Dom; break;
		case MAPINFO_TYPE_KEEPAWAY:	HUD_ModIcons_GameType = HUD_Mod_Keepaway; break;
		case MAPINFO_TYPE_VIP:         HUD_ModIcons_GameType = HUD_Mod_VIP; break;
	}
}

float mod_prev; // previous state of mod_active to check for a change
float mod_alpha;
float mod_change; // "time" when mod_active changed

void HUD_ModIcons(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_modicons) return;
		if(!HUD_ModIcons_GameType) return;
	}

	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	if(mod_active != mod_prev) {
		mod_change = time;
		mod_prev = mod_active;
	}

	if(mod_active || autocvar__hud_configure)
		mod_alpha = bound(0, (time - mod_change) * 2, 1);
	else
		mod_alpha = bound(0, 1 - (time - mod_change) * 2, 1);

	if(mod_alpha)
		HUD_Panel_DrawBg(mod_alpha);

	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	if(autocvar__hud_configure)
		HUD_Mod_CTF(panel_pos, panel_size);
	else
		HUD_ModIcons_GameType(panel_pos, panel_size);

	draw_endBoldFont();
}

void HUD_MorningRescue(void)
{
	// vectors for top right, bottom right, bottom and bottom left corners

	vector topright;
	vector bottom;
	vector bottomright;
	vector bottomleft;

	topright_x = vid_conwidth;
	topright_y = 0;
	topright_z = 0;

	bottom_x = vid_conwidth/2;
	bottom_y = vid_conheight;
	bottom_z = 0;

	bottomright_x = vid_conwidth;
	bottomright_y = vid_conheight;
	bottomright_z = 0;

	bottomleft_x = 0;
	bottomleft_y = vid_conheight;
	bottomleft_z = 0;

	local vector mrpos;
	local float mralpha;
	mrpos = bottomleft;
	local vector offset = '0 0 0';

	mralpha = 1 - bound(0, 1 - 2 * (time - mr_appeartime), 1);
	if(mralpha >= 1)
		mralpha = bound(0, 1 - 2 * (time - (mr_fadetime - 1)), 1);

	local vector mrcolor = '0 0 0';
	mrcolor_x = 1;
	mrcolor_y = random();
	drawfill('0 0 0', bottomright, mrcolor, mralpha * random(), DRAWFLAG_ADDITIVE);

	mrpos_y -= 200 * mralpha;
	drawpic (mrpos, "gfx/morningrescue", '57 200 0', '1 1 1', mralpha, DRAWFLAG_NORMAL);

	mrpos = topright;
	mrpos_y -= 500 * 0.5 * (1 - mralpha);
	offset_y = 3 * cos(mrpos_y + 5 * time) - 5;
	mrpos_x -= 513 * 0.5;
	offset_x = 3 * cos(mrpos_x + 5 * time) + 5;
	drawpic (mrpos + offset, "gfx/morningrescue2", '513 500 0' * 0.5, '1 1 1', mralpha, DRAWFLAG_NORMAL);

	local string mycolor = "";
	local string mychar;
	local float j;
	local string mrstring = _("^xFB0MMorning ^7Rescue");

	local float k;
	
	draw_beginBoldFont();

	for(k = 0; k < 2; ++k)
	{
		mrpos_y = vid_conheight / 2 - 12;
		mrpos_x = 0.5 * (vid_conwidth - 0.6025 * strlennocol(mrstring) * 24);
		for(j = 0; j < strlen(mrstring); ++j)
		{
			mychar = substring(mrstring, j, 1);

			if(mychar == "^")
			{
				if(substring(mrstring, j+1, 1) == "x")
				{
					mycolor = substring(mrstring, j, 5);
					j += 5;
				}
				else
				{
					mycolor = substring(mrstring, j, 2);
					++j;
				}
				continue;
			}

			offset_y = 10 * ((k*10)+1) * cos(mrpos_x + 3 * time) * (mod(j, 2)? 1 : -1) * (k? 1 : -1);
			offset_x = offset_y * (mod(j, 2)? -1 : 1);
			local string resultstr = strcat(mycolor, mychar);

			dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
			mrpos_x += stringwidth(resultstr, TRUE, '24 24 0');
			drawcolorcodedstring(mrpos + offset, resultstr, '24 24 0', mralpha * 0.8, DRAWFLAG_ADDITIVE);
		}
	}
	
	draw_endBoldFont();
}

// Draw pressed keys (#11)
//
void HUD_PressedKeys(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_pressedkeys) return;
		if(spectatee_status <= 0 && autocvar_hud_panel_pressedkeys < 2) return;
	}

	HUD_Panel_UpdateCvars();
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	// force custom aspect
	float aspect = autocvar_hud_panel_pressedkeys_aspect;
	if(aspect)
	{
		vector newSize = '0 0 0';
		if(mySize_x/mySize_y > aspect)
		{
			newSize_x = aspect * mySize_y;
			newSize_y = mySize_y;

			pos_x = pos_x + (mySize_x - newSize_x) / 2;
		}
		else
		{
			newSize_y = 1/aspect * mySize_x;
			newSize_x = mySize_x;

			pos_y = pos_y + (mySize_y - newSize_y) / 2;
		}
		mySize = newSize;
	}

	vector keysize;
	keysize = eX * mySize_x * (1/3.0) + eY * mySize_y * (1/(3.0 - !autocvar_hud_panel_pressedkeys_attack));
	float pressedkeys;
	pressedkeys = getstatf(STAT_PRESSED_KEYS);

	if(autocvar_hud_panel_pressedkeys_attack)
	{
		drawpic_aspect_skin(pos + eX * keysize_x * 0.5, ((pressedkeys & KEY_ATCK) ? "key_atck_inv.tga" : "key_atck.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		drawpic_aspect_skin(pos + eX * keysize_x * 1.5, ((pressedkeys & KEY_ATCK2) ? "key_atck_inv.tga" : "key_atck.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		pos_y += keysize_y;
	}

	drawpic_aspect_skin(pos, ((pressedkeys & KEY_CROUCH) ? "key_crouch_inv.tga" : "key_crouch.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	drawpic_aspect_skin(pos + eX * keysize_x, ((pressedkeys & KEY_FORWARD) ? "key_forward_inv.tga" : "key_forward.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	drawpic_aspect_skin(pos + eX * keysize_x * 2, ((pressedkeys & KEY_JUMP) ? "key_jump_inv.tga" : "key_jump.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	pos_y += keysize_y;
	drawpic_aspect_skin(pos, ((pressedkeys & KEY_LEFT) ? "key_left_inv.tga" : "key_left.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	drawpic_aspect_skin(pos + eX * keysize_x, ((pressedkeys & KEY_BACKWARD) ? "key_backward_inv.tga" : "key_backward.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	drawpic_aspect_skin(pos + eX * keysize_x * 2, ((pressedkeys & KEY_RIGHT) ? "key_right_inv.tga" : "key_right.tga"), keysize, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
}

// Handle chat as a panel (#12)
//
void HUD_Chat(void)
{
	if(!autocvar__hud_configure)
	{
		if (!autocvar_hud_panel_chat)
		{
			if (!autocvar_con_chatrect)
				cvar_set("con_chatrect", "0");
			return;
		}
		if(autocvar__con_chat_maximized)
		{
			if(!hud_draw_maximized) return;
		}
		else if(chat_panel_modified)
		{
			panel.update_time = time; // forces reload of panel attributes
			chat_panel_modified = false;
		}
	}

	HUD_Panel_UpdateCvars();

	if(autocvar__con_chat_maximized && !autocvar__hud_configure) // draw at full screen height if maximized
	{
		panel_pos_y = panel_bg_border;
		panel_size_y = vid_conheight - panel_bg_border * 2;
		if(panel.current_panel_bg == "0") // force a border when maximized
		{
			string panel_bg;
			panel_bg = strcat(hud_skin_path, "/border_default");
			if(precache_pic(panel_bg) == "")
				panel_bg = "gfx/hud/default/border_default";
			if(panel.current_panel_bg)
				strunzone(panel.current_panel_bg);
			panel.current_panel_bg = strzone(panel_bg);
			chat_panel_modified = true;
		}
		panel_bg_alpha = max(0.75, panel_bg_alpha); // force an theAlpha of at least 0.75
	}

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);

	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	if (!autocvar_con_chatrect)
		cvar_set("con_chatrect", "1");

	cvar_set("con_chatrect_x", ftos(pos_x/vid_conwidth));
	cvar_set("con_chatrect_y", ftos(pos_y/vid_conheight));

	cvar_set("con_chatwidth", ftos(mySize_x/vid_conwidth));
	cvar_set("con_chat", ftos(floor(mySize_y/autocvar_con_chatsize - 0.5)));

	if(autocvar__hud_configure)
	{
		vector chatsize;
		chatsize = '1 1 0' * autocvar_con_chatsize;
		cvar_set("con_chatrect_x", "9001"); // over 9000, we'll fake it instead for more control over theAlpha and such
		float i, a;
		for(i = 0; i < autocvar_con_chat; ++i)
		{
			if(i == autocvar_con_chat - 1)
				a = panel_fg_alpha;
			else
				a = panel_fg_alpha * floor(((i + 1) * 7 + autocvar_con_chattime)/45);
			drawcolorcodedstring(pos, textShortenToWidth(_("^3Player^7: This is the chat area."), mySize_x, chatsize, stringwidth_colors), chatsize, a, DRAWFLAG_NORMAL);
			pos_y += chatsize_y;
		}
	}
}

// Engine info panel (#13)
//
float prevfps;
float prevfps_time;
float framecounter;

float frametimeavg;
float frametimeavg1; // 1 frame ago
float frametimeavg2; // 2 frames ago
void HUD_EngineInfo(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_engineinfo) return;
	}

	HUD_Panel_UpdateCvars();
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float currentTime = gettime(GETTIME_REALTIME);
	if(cvar("hud_panel_engineinfo_framecounter_exponentialmovingaverage"))
	{
		float currentframetime = currentTime - prevfps_time;
		frametimeavg = (frametimeavg + frametimeavg1 + frametimeavg2 + currentframetime)/4; // average three frametimes into framecounter for slightly more stable fps readings :P
		frametimeavg2 = frametimeavg1;
		frametimeavg1 = frametimeavg;

		float weight;
		weight = cvar("hud_panel_engineinfo_framecounter_exponentialmovingaverage_new_weight");
		if(currentframetime > 0.0001) // filter out insane values which sometimes seem to occur and throw off the average? If you are getting 10,000 fps or more, then you don't need a framerate counter.
		{
			if(fabs(prevfps - (1/frametimeavg)) > prevfps * cvar("hud_panel_engineinfo_framecounter_exponentialmovingaverage_instantupdate_change_threshold")) // if there was a big jump in fps, just force prevfps at current (1/currentframetime) to make big updates instant
				prevfps = (1/currentframetime);
			prevfps = (1 - weight) * prevfps + weight * (1/frametimeavg); // framecounter just used so there's no need for a new variable, think of it as "frametime average"
		}
		prevfps_time = currentTime;
	}
	else
	{
		framecounter += 1;
		if(currentTime - prevfps_time > autocvar_hud_panel_engineinfo_framecounter_time)
		{
			prevfps = framecounter/(currentTime - prevfps_time);
			framecounter = 0;
			prevfps_time = currentTime;
		}
	}

	vector color;
	color = HUD_Get_Num_Color (prevfps, 100);
	drawstring_aspect(pos, sprintf(_("FPS: %.*f"), autocvar_hud_panel_engineinfo_framecounter_decimals, prevfps), mySize, color, panel_fg_alpha, DRAWFLAG_NORMAL);
}

// Info messages panel (#14)
//
#define drawInfoMessage(s)\
	if(autocvar_hud_panel_infomessages_flip)\
		o_x = pos_x + mySize_x - stringwidth(s, TRUE, fontsize);\
	drawcolorcodedstring(o, s, fontsize, a, DRAWFLAG_NORMAL);\
	o_y += fontsize_y;
void HUD_InfoMessages(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_infomessages) return;
	}

	HUD_Panel_UpdateCvars();
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	// always force 5:1 aspect
	vector newSize = '0 0 0';
	if(mySize_x/mySize_y > 5)
	{
		newSize_x = 5 * mySize_y;
		newSize_y = mySize_y;

		pos_x = pos_x + (mySize_x - newSize_x) / 2;
	}
	else
	{
		newSize_y = 1/5 * mySize_x;
		newSize_x = mySize_x;

		pos_y = pos_y + (mySize_y - newSize_y) / 2;
	}

	mySize = newSize;
	entity tm;
	vector o;
	o = pos;

	vector fontsize;
	fontsize = '0.20 0.20 0' * mySize_y;

	float a;
	a = panel_fg_alpha;

	string s;
	if(!autocvar__hud_configure)
	{
		if(morningrescue)
		if(time <= mr_fadetime)
			HUD_MorningRescue();
		else
			morningrescue = 0;

		if(spectatee_status && !intermission)
		{
			a = 1;
			if(spectatee_status == -1)
				s = _("^1Observing");
			else
#ifdef COMPAT_XON050_ENGINE
				s = sprintf(_("^1Spectating: ^7%s ^1(^3fov: %d^1)"), GetPlayerName(spectatee_status - 1), fovlock);
#else
				s = sprintf(_("^1Spectating: ^7%s ^1(^3fov: %d^1)"), GetPlayerName(player_localentnum - 1), fovlock);
#endif
			drawInfoMessage(s)

			if(spectatee_status == -1)
				s = sprintf(_("^1Press ^3%s^1 to spectate"), getcommandkey("primary fire", "+fire"));
			else
				s = sprintf(_("^1Press ^3%s^1 or ^3%s^1 for next or previous player"), getcommandkey("next weapon", "weapnext"), getcommandkey("previous weapon", "weapprev"));
			drawInfoMessage(s)

			if(spectatee_status == -1)
				s = sprintf(_("^1Use ^3%s^1 or ^3%s^1 to change the speed"), getcommandkey("next weapon", "weapnext"), getcommandkey("previous weapon", "weapprev"));
			else
				s = sprintf(_("^1Press ^3%s^1 to observe"), getcommandkey("secondary fire", "+fire2"));
			drawInfoMessage(s)

			s = sprintf(_("^1Press ^3%s^1 for gamemode info"), getcommandkey("server info", "+show_info"));
			drawInfoMessage(s)

			if(gametype == MAPINFO_TYPE_LMS)
			{
				entity sk;
				sk = playerslots[player_localnum];
				if(sk.(scores[ps_primary]) >= 666)
					s = _("^1Match has already begun");
				else if(sk.(scores[ps_primary]) > 0)
					s = _("^1You have no more lives left");
				else
					s = sprintf(_("^1Press ^3%s^1 to join"), getcommandkey("jump", "+jump"));
			}
			else
				s = sprintf(_("^1Press ^3%s^1 to join"), getcommandkey("jump", "+jump"));
			drawInfoMessage(s)

			//show restart countdown:
			if (time < getstatf(STAT_GAMESTARTTIME)) {
				float countdown;
				//we need to ceil, otherwise the countdown would be off by .5 when using round()
				countdown = ceil(getstatf(STAT_GAMESTARTTIME) - time);
				s = sprintf(_("^1Game starts in ^3%d^1 seconds"), countdown);
				drawcolorcodedstring(o, s, fontsize, a, DRAWFLAG_NORMAL);
				o_y += fontsize_y;
			}
		}
		if(warmup_stage && !intermission)
		{
			s = _("^2Currently in ^1warmup^2 stage!");
			drawInfoMessage(s)
		}

		if(autocvar_cl_showspectators)
		if(num_spectators)
		if(!spectatee_status)
		{
			s = _("^1Spectating you:");
			drawInfoMessage(s)
			float limit = min(num_spectators, MAX_SPECTATORS);
			float i;
			for(i = 0; i < limit; ++i)
			{
				float slot = spectatorlist[i];
				s = strcat("^3", GetPlayerName(slot));
				drawInfoMessage(s)
			}
		}

		string blinkcolor;
		if(mod(time, 1) >= 0.5)
			blinkcolor = "^1";
		else
			blinkcolor = "^3";

		if(ready_waiting && !intermission && !spectatee_status)
		{
			if(ready_waiting_for_me)
			{
				if(warmup_stage)
					s = sprintf(_("%sPress ^3%s%s to end warmup"), blinkcolor, getcommandkey("ready", "ready"), blinkcolor);
				else
					s = sprintf(_("%sPress ^3%s%s once you are ready"), blinkcolor, getcommandkey("ready", "ready"), blinkcolor);
			}
			else
			{
				if(warmup_stage)
					s = _("^2Waiting for others to ready up to end warmup...");
				else
					s = _("^2Waiting for others to ready up...");
			}
			drawInfoMessage(s)
		}
		else if(warmup_stage && !intermission && !spectatee_status)
		{
			s = sprintf(_("^2Press ^3%s^2 to end warmup"), getcommandkey("ready", "ready"));
			drawInfoMessage(s)
		}

		if(teamplay && !intermission && !spectatee_status && gametype != MAPINFO_TYPE_CA && teamnagger)
		{
			float ts_min = 0, ts_max = 0;
			tm = teams.sort_next;
			if (tm)
			{
				for(; tm.sort_next; tm = tm.sort_next)
				{
					if(!tm.team_size || tm.team == NUM_SPECTATOR)
						continue;
					if(!ts_min) ts_min = tm.team_size;
					else ts_min = min(ts_min, tm.team_size);
					if(!ts_max) ts_max = tm.team_size;
					else ts_max = max(ts_max, tm.team_size);
				}
				if ((ts_max - ts_min) > 1)
				{
					s = strcat(blinkcolor, _("Teamnumbers are unbalanced!"));
					tm = GetTeam(myteam, false);
					if (tm)
					if (tm.team != NUM_SPECTATOR)
					if (tm.team_size == ts_max)
						s = strcat(s, sprintf(_(" Press ^3%s%s to adjust"), getcommandkey("team menu", "menu_showteamselect"), blinkcolor));
					drawInfoMessage(s)
				}
			}
		}
	}
	else
	{
		s = _("^7Press ^3ESC ^7to show HUD options.");
		drawInfoMessage(s)
		s = _("^3Doubleclick ^7a panel for panel-specific options.");
		drawInfoMessage(s)
		s = _("^3CTRL ^7to disable collision testing, ^3SHIFT ^7and");
		drawInfoMessage(s)
		s = _("^3ALT ^7+ ^3ARROW KEYS ^7for fine adjustments.");
		drawInfoMessage(s)
	}
}

// Physics panel (#15)
//
vector acc_prevspeed;
float acc_prevtime, acc_avg, top_speed, top_speed_time;
void HUD_Physics(void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_physics) return;
		if(spectatee_status == -1 && (autocvar_hud_panel_physics == 1 || autocvar_hud_panel_physics == 3)) return;
		if(autocvar_hud_panel_physics == 3 && !(gametype == MAPINFO_TYPE_RACE || gametype == MAPINFO_TYPE_CTS)) return;
	}

	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	float acceleration_progressbar_scale = 0;
	if(autocvar_hud_panel_physics_progressbar && autocvar_hud_panel_physics_acceleration_progressbar_scale > 1)
		acceleration_progressbar_scale = autocvar_hud_panel_physics_acceleration_progressbar_scale;

	float text_scale;
	if (autocvar_hud_panel_physics_text_scale <= 0)
		text_scale = 1;
	else
		text_scale = min(autocvar_hud_panel_physics_text_scale, 1);

	//compute speed
	float speed, conversion_factor;
	string unit;

	switch(autocvar_hud_panel_physics_speed_unit)
	{
		default:
		case 1:
			unit = _(" qu/s");
			conversion_factor = 1.0;
			break;
		case 2:
			unit = _(" m/s");
			conversion_factor = 0.0254;
			break;
		case 3:
			unit = _(" km/h");
			conversion_factor = 0.0254 * 3.6;
			break;
		case 4:
			unit = _(" mph");
			conversion_factor = 0.0254 * 3.6 * 0.6213711922;
			break;
		case 5:
			unit = _(" knots");
			conversion_factor = 0.0254 * 1.943844492; // 1 m/s = 1.943844492 knots, because 1 knot = 1.852 km/h
			break;
	}

	vector vel = (csqcplayer ? csqcplayer.velocity : pmove_vel);

	float max_speed = floor( autocvar_hud_panel_physics_speed_max * conversion_factor + 0.5 );
	if (autocvar__hud_configure)
		speed = floor( max_speed * 0.65 + 0.5 );
	else if(autocvar_hud_panel_physics_speed_vertical)
		speed = floor( vlen(vel) * conversion_factor + 0.5 );
	else
		speed = floor( vlen(vel - vel_z * '0 0 1') * conversion_factor + 0.5 );

	//compute acceleration
	float acceleration, f;
	if (autocvar__hud_configure)
		acceleration = autocvar_hud_panel_physics_acceleration_max * 0.3;
	else
	{
		// 1 m/s = 0.0254 qu/s; 1 g = 9.80665 m/s^2
		f = time - acc_prevtime;
		if(autocvar_hud_panel_physics_acceleration_vertical)
			acceleration = (vlen(vel) - vlen(acc_prevspeed));
		else
			acceleration = (vlen(vel - '0 0 1' * vel_z) - vlen(acc_prevspeed - '0 0 1' * acc_prevspeed_z));

		acceleration = acceleration * (1 / max(0.0001, f)) * (0.0254 / 9.80665);

		acc_prevspeed = vel;
		acc_prevtime = time;

		f = bound(0, f * 10, 1);
		acc_avg = acc_avg * (1 - f) + acceleration * f;
	}

	//compute layout
	float panel_ar = panel_size_x/panel_size_y;
	vector speed_offset = '0 0 0', acceleration_offset = '0 0 0';
	if (panel_ar >= 5 && !acceleration_progressbar_scale)
	{
		panel_size_x *= 0.5;
		if (autocvar_hud_panel_physics_flip)
			speed_offset_x = panel_size_x;
		else
			acceleration_offset_x = panel_size_x;
	}
	else
	{
		panel_size_y *= 0.5;
		if (autocvar_hud_panel_physics_flip)
			speed_offset_y = panel_size_y;
		else
			acceleration_offset_y = panel_size_y;
	}
	float speed_baralign, acceleration_baralign;
	if (autocvar_hud_panel_physics_baralign == 1)
		acceleration_baralign = speed_baralign = 1;
    else if(autocvar_hud_panel_physics_baralign == 4)
		acceleration_baralign = speed_baralign = 2;
	else if (autocvar_hud_panel_physics_flip)
	{
		acceleration_baralign = (autocvar_hud_panel_physics_baralign == 2);
		speed_baralign = (autocvar_hud_panel_physics_baralign == 3);
	}
	else
	{
		speed_baralign = (autocvar_hud_panel_physics_baralign == 2);
		acceleration_baralign = (autocvar_hud_panel_physics_baralign == 3);
	}
	if (autocvar_hud_panel_physics_acceleration_progressbar_mode == 0)
		acceleration_baralign = 3; //override hud_panel_physics_baralign value for acceleration

	//draw speed
	if(speed)
	if(autocvar_hud_panel_physics_progressbar == 1 || autocvar_hud_panel_physics_progressbar == 2)
		HUD_Panel_DrawProgressBar(panel_pos + speed_offset, panel_size, "progressbar", speed/max_speed, 0, speed_baralign, autocvar_hud_progressbar_speed_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
	vector tmp_offset = '0 0 0', tmp_size = '0 0 0';
	if (autocvar_hud_panel_physics_text == 1 || autocvar_hud_panel_physics_text == 2)
	{
		tmp_size_x = panel_size_x * 0.75;
		tmp_size_y = panel_size_y * text_scale;
		if (speed_baralign)
			tmp_offset_x = panel_size_x - tmp_size_x;
		//else
			//tmp_offset_x = 0;
		tmp_offset_y = (panel_size_y - tmp_size_y) / 2;
		drawstring_aspect(panel_pos + speed_offset + tmp_offset, ftos(speed), tmp_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);

		//draw speed unit
		if (speed_baralign)
			tmp_offset_x = 0;
		else
			tmp_offset_x = tmp_size_x;
		if (autocvar_hud_panel_physics_speed_unit_show)
		{
			//tmp_offset_y = 0;
			tmp_size_x = panel_size_x * (1 - 0.75);
			tmp_size_y = panel_size_y * 0.4 * text_scale;
			tmp_offset_y = (panel_size_y * 0.4 - tmp_size_y) / 2;
			drawstring_aspect(panel_pos + speed_offset + tmp_offset, unit, tmp_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		}
	}

	//compute and draw top speed
	if (autocvar_hud_panel_physics_topspeed)
	if (autocvar_hud_panel_physics_text == 1 || autocvar_hud_panel_physics_text == 2)
	{
		if (autocvar__hud_configure)
		{
			top_speed = floor( max_speed * 0.75 + 0.5 );
			f = 1;
		}
		else
		{
			if (speed >= top_speed)
			{
				top_speed = speed;
				top_speed_time = time;
			}
			if (top_speed != 0)
			{
				f = max(1, autocvar_hud_panel_physics_topspeed_time);
				// divide by f to make it start from 1
				f = cos( ((time - top_speed_time) / f) * PI/2 );
			}
            else //hide top speed 0, it would be stupid
				f = 0;
		}
		if (f > 0)
		{
			//top speed progressbar peak
			if(speed < top_speed)
			if(autocvar_hud_panel_physics_progressbar == 1 || autocvar_hud_panel_physics_progressbar == 2)
			{
				float peak_offset_x;
				vector peak_size = '0 0 0';
				if (speed_baralign == 0)
					peak_offset_x = min(top_speed, max_speed)/max_speed * panel_size_x;
                else if (speed_baralign == 1)
					peak_offset_x = (1 - min(top_speed, max_speed)/max_speed) * panel_size_x;
                else // if (speed_baralign == 2)
                    peak_offset_x = min(top_speed, max_speed)/max_speed * panel_size_x * 0.5;
				peak_size_x = floor(panel_size_x * 0.01 + 1.5);
                peak_size_y = panel_size_y;
                if (speed_baralign == 2) // draw two peaks, on both sides
                {
                    drawfill(panel_pos + speed_offset + eX * (0.5 * panel_size_x + peak_offset_x - peak_size_x), peak_size, autocvar_hud_progressbar_speed_color, f * autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
                    drawfill(panel_pos + speed_offset + eX * (0.5 * panel_size_x - peak_offset_x + peak_size_x), peak_size, autocvar_hud_progressbar_speed_color, f * autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
                }
                else
                    drawfill(panel_pos + speed_offset + eX * (peak_offset_x - peak_size_x), peak_size, autocvar_hud_progressbar_speed_color, f * autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
			}

			//top speed
			tmp_offset_y = panel_size_y * 0.4;
			tmp_size_x = panel_size_x * (1 - 0.75);
			tmp_size_y = (panel_size_y - tmp_offset_y) * text_scale;
			tmp_offset_y += (panel_size_y - tmp_offset_y - tmp_size_y) / 2;
			drawstring_aspect(panel_pos + speed_offset + tmp_offset, ftos(top_speed), tmp_size, '1 0 0', f * panel_fg_alpha, DRAWFLAG_NORMAL);
		}
		else
			top_speed = 0;
	}

	//draw acceleration
	if(acceleration)
	if(autocvar_hud_panel_physics_progressbar == 1 || autocvar_hud_panel_physics_progressbar == 3)
	{
		vector progressbar_color;
		if(acceleration < 0)
			progressbar_color = autocvar_hud_progressbar_acceleration_neg_color;
		else
			progressbar_color = autocvar_hud_progressbar_acceleration_color;

		f = acceleration/autocvar_hud_panel_physics_acceleration_max;
		if (autocvar_hud_panel_physics_acceleration_progressbar_nonlinear)
			f = sqrt(f);

		if (acceleration_progressbar_scale) // allow progressbar to go out of panel bounds
		{
			tmp_size = acceleration_progressbar_scale * panel_size_x * eX + panel_size_y * eY;

			if (acceleration_baralign == 1)
				tmp_offset_x = panel_size_x - tmp_size_x;
			else if (acceleration_baralign == 2 || acceleration_baralign == 3)
				tmp_offset_x = (panel_size_x - tmp_size_x) / 2;
			else
				tmp_offset_x = 0;
			tmp_offset_y = 0;
		}
		else
		{
			tmp_size = panel_size;
			tmp_offset = '0 0 0';
		}

		HUD_Panel_DrawProgressBar(panel_pos + acceleration_offset + tmp_offset, tmp_size, "accelbar", f, 0, acceleration_baralign, progressbar_color, autocvar_hud_progressbar_alpha * panel_fg_alpha, DRAWFLAG_NORMAL);
	}
	tmp_size_x = panel_size_x;
	tmp_size_y = panel_size_y * text_scale;
	tmp_offset_x = 0;
	tmp_offset_y = (panel_size_y - tmp_size_y) / 2;
	if (autocvar_hud_panel_physics_text == 1 || autocvar_hud_panel_physics_text == 3)
		drawstring_aspect(panel_pos + acceleration_offset + tmp_offset, strcat(ftos_decimals(acceleration, 2), "g"), tmp_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);

	draw_endBoldFont();
}

// CenterPrint (#16)
//
#define CENTERPRINT_MAX_MSGS 10
#define CENTERPRINT_MAX_ENTRIES 50
#define CENTERPRINT_SPACING 0.7
float cpm_index;
string centerprint_messages[CENTERPRINT_MAX_MSGS];
float centerprint_msgID[CENTERPRINT_MAX_MSGS];
float centerprint_time[CENTERPRINT_MAX_MSGS];
float centerprint_expire_time[CENTERPRINT_MAX_MSGS];
float centerprint_countdown_num[CENTERPRINT_MAX_MSGS];
float centerprint_showing;

void centerprint_generic(float new_id, string strMessage, float duration, float countdown_num)
{
	//printf("centerprint_generic(%d, '%s^7', %d, %d);\n", new_id, strMessage, duration, countdown_num);
	float i, j;

	if(strMessage == "" && new_id == 0)
		return;

	// strip trailing newlines
	j = strlen(strMessage) - 1;
	while(substring(strMessage, j, 1) == "\n" && j >= 0)
		--j;
	if (j < strlen(strMessage) - 1)
		strMessage = substring(strMessage, 0, j + 1);

	if(strMessage == "" && new_id == 0)
		return;

	// strip leading newlines
	j = 0;
	while(substring(strMessage, j, 1) == "\n" && j < strlen(strMessage))
		++j;
	if (j > 0)
		strMessage = substring(strMessage, j, strlen(strMessage) - j);

	if(strMessage == "" && new_id == 0)
		return;

	if (!centerprint_showing)
		centerprint_showing = TRUE;

	for (i=0, j=cpm_index; i<CENTERPRINT_MAX_MSGS; ++i, ++j)
	{
		if (j == CENTERPRINT_MAX_MSGS)
			j = 0;
		if (new_id && new_id == centerprint_msgID[j])
		{
			if (strMessage == "" && centerprint_messages[j] != "" && centerprint_countdown_num[j] == 0)
			{
				// fade out the current msg (duration and countdown_num are ignored)
				centerprint_time[j] = min(5, autocvar_hud_panel_centerprint_fade_out);
				if (centerprint_expire_time[j] > time + min(5, autocvar_hud_panel_centerprint_fade_out) || centerprint_expire_time[j] < time)
					centerprint_expire_time[j] = time + min(5, autocvar_hud_panel_centerprint_fade_out);
				return;
			}
			break; // found a msg with the same id, at position j
		}
	}

	if (i == CENTERPRINT_MAX_MSGS)
	{
		// a msg with the same id was not found, add the msg at the next position
		--cpm_index;
		if (cpm_index == -1)
			cpm_index = CENTERPRINT_MAX_MSGS - 1;
		j = cpm_index;
	}
	if(centerprint_messages[j])
		strunzone(centerprint_messages[j]);
	centerprint_messages[j] = strzone(strMessage);
	centerprint_msgID[j] = new_id;
	if (duration < 0)
	{
		centerprint_time[j] = -1;
		centerprint_expire_time[j] = time;
	}
	else
	{
		if(duration == 0)
			duration = max(1, autocvar_hud_panel_centerprint_time);
		centerprint_time[j] = duration;
		centerprint_expire_time[j] = time + duration;
	}
	centerprint_countdown_num[j] = countdown_num;
}

void centerprint_hud(string strMessage)
{
	centerprint_generic(0, strMessage, autocvar_hud_panel_centerprint_time, 0);
}

void reset_centerprint_messages(void)
{
	float i;
	for (i=0; i<CENTERPRINT_MAX_MSGS; ++i)
	{
		centerprint_expire_time[i] = 0;
		centerprint_time[i] = 1;
		centerprint_msgID[i] = 0;
		if(centerprint_messages[i])
			strunzone(centerprint_messages[i]);
		centerprint_messages[i] = string_null;
	}
}
float hud_configure_cp_generation_time;
void HUD_CenterPrint (void)
{
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_centerprint) return;

		if (hud_configure_prev && hud_configure_prev != -1)
			reset_centerprint_messages();
	}
	else
	{
		if (!hud_configure_prev)
			reset_centerprint_messages();
		if (time > hud_configure_cp_generation_time)
		{
			float r;
			r = random();
			if (r > 0.9)
				centerprint_generic(floor(r*1000), strcat(sprintf("^3Countdown message at time %s", seconds_tostring(time)), ", seconds left: ^COUNT"), 1, 10);
			else if (r > 0.8)
				centerprint_generic(0, sprintf("^1Multiline message at time %s that\n^1lasts longer than normal", seconds_tostring(time)), 20, 0);
			else
				centerprint_hud(sprintf("Message at time %s", seconds_tostring(time)));
			hud_configure_cp_generation_time = time + 1 + random()*4;
		}
	}

	// this panel fades only when the menu does
	float hud_fade_alpha_save = 0;
	if(scoreboard_fade_alpha)
	{
		hud_fade_alpha_save = hud_fade_alpha;
		hud_fade_alpha = 1 - autocvar__menu_alpha;
	}
	HUD_Panel_UpdateCvars();

	if(scoreboard_fade_alpha)
	{
		hud_fade_alpha = hud_fade_alpha_save;

		// move the panel below the scoreboard
		if (scoreboard_bottom >= 0.96 * vid_conheight)
			return;
		vector target_pos;

		target_pos = eY * scoreboard_bottom + eX * 0.5 * (vid_conwidth - panel_size_x);

		if(target_pos_y > panel_pos_y)
		{
			panel_pos = panel_pos + (target_pos - panel_pos) * sqrt(scoreboard_fade_alpha);
			panel_size_y = min(panel_size_y, vid_conheight - scoreboard_bottom);
		}
	}

	HUD_Panel_DrawBg(1);

	if (!centerprint_showing)
		return;

	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	float entries, height;
	vector fontsize;
	// entries = bound(1, floor(CENTERPRINT_MAX_ENTRIES * 4 * panel_size_y/panel_size_x), CENTERPRINT_MAX_ENTRIES);
	// height = panel_size_y/entries;
	// fontsize = '1 1 0' * height;
	height = vid_conheight/50 * autocvar_hud_panel_centerprint_fontscale;
	fontsize = '1 1 0' * height;
	entries = bound(1, floor(panel_size_y/height), CENTERPRINT_MAX_ENTRIES);

	float i, j, k, n, g;
	float a, sz, align, current_msg_pos_y = 0, msg_size;
	vector pos;
	string ts;
	float all_messages_expired = TRUE;

	pos = panel_pos;
	if (autocvar_hud_panel_centerprint_flip)
		pos_y += panel_size_y;
	align = bound(0, autocvar_hud_panel_centerprint_align, 1);
	for (g=0, i=0, j=cpm_index; i<CENTERPRINT_MAX_MSGS; ++i, ++j)
	{
		if (j == CENTERPRINT_MAX_MSGS)
			j = 0;
		if (centerprint_expire_time[j] <= time)
		{
			if (centerprint_countdown_num[j] && centerprint_time[j] > 0)
			{
				centerprint_countdown_num[j] = centerprint_countdown_num[j] - 1;
				if (centerprint_countdown_num[j] == 0)
					continue;
				centerprint_expire_time[j] = centerprint_expire_time[j] + centerprint_time[j];
			}
			else if(centerprint_time[j] != -1)
				continue;
		}

		all_messages_expired = FALSE;

		// fade the centerprint_hud in/out
		if(centerprint_time[j] < 0)  // Expired but forced. Expire time is the fade-in time.
			a = (time - centerprint_expire_time[j]) / max(0.0001, autocvar_hud_panel_centerprint_fade_in);
		else if(centerprint_expire_time[j] - autocvar_hud_panel_centerprint_fade_out > time)  // Regularily printed. Not fading out yet.
			a = (time - (centerprint_expire_time[j] - centerprint_time[j])) / max(0.0001, autocvar_hud_panel_centerprint_fade_in);
		else // Expiring soon, so fade it out.
			a = (centerprint_expire_time[j] - time) / max(0.0001, autocvar_hud_panel_centerprint_fade_out);

		if (a <= 0.5/255.0)  // Guaranteed invisible - don't show.
			continue;
		if (a > 1)
			a = 1;

		// set the size from fading in/out before subsequent fading
		sz = autocvar_hud_panel_centerprint_fade_minfontsize + a * (1 - autocvar_hud_panel_centerprint_fade_minfontsize);

		// also fade it based on positioning
		if(autocvar_hud_panel_centerprint_fade_subsequent)
		{
			a = a * bound(autocvar_hud_panel_centerprint_fade_subsequent_passone_minalpha, (1 - (g / max(1, autocvar_hud_panel_centerprint_fade_subsequent_passone))), 1); // pass one: all messages after the first have half theAlpha
			a = a * bound(autocvar_hud_panel_centerprint_fade_subsequent_passtwo_minalpha, (1 - (g / max(1, autocvar_hud_panel_centerprint_fade_subsequent_passtwo))), 1); // pass two: after that, gradually lower theAlpha even more for each message
		}
		a *= panel_fg_alpha;

		// finally set the size based on the new theAlpha from subsequent fading
		sz = sz * (autocvar_hud_panel_centerprint_fade_subsequent_minfontsize + a * (1 - autocvar_hud_panel_centerprint_fade_subsequent_minfontsize));
		drawfontscale = sz * '1 1 0';

		if (centerprint_countdown_num[j])
			n = tokenizebyseparator(strreplace("^COUNT", count_seconds(centerprint_countdown_num[j]), centerprint_messages[j]), "\n");
		else
			n = tokenizebyseparator(centerprint_messages[j], "\n");

		if (autocvar_hud_panel_centerprint_flip)
		{
			// check if the message can be entirely shown
			for(k = 0; k < n; ++k)
			{
				getWrappedLine_remaining = argv(k);
				while(getWrappedLine_remaining)
				{
					ts = getWrappedLine(panel_size_x * sz, fontsize, stringwidth_colors);
					if (ts != "")
						pos_y -= fontsize_y;
					else
						pos_y -= fontsize_y * CENTERPRINT_SPACING/2;
				}
			}
			current_msg_pos_y = pos_y; // save starting pos (first line) of the current message
		}

		msg_size = pos_y;
		for(k = 0; k < n; ++k)
		{
			getWrappedLine_remaining = argv(k);
			while(getWrappedLine_remaining)
			{
				ts = getWrappedLine(panel_size_x * sz, fontsize, stringwidth_colors);
				if (ts != "")
				{
					if (align)
						pos_x = panel_pos_x + (panel_size_x - stringwidth(ts, TRUE, fontsize)) * align;
					if (a > 0.5/255.0)  // Otherwise guaranteed invisible - don't show. This is checked a second time after some multiplications with other factors were done so temporary changes of these cannot cause flicker.
						drawcolorcodedstring(pos + eY * 0.5 * (1 - sz) * fontsize_y, ts, fontsize, a, DRAWFLAG_NORMAL);
					pos_y += fontsize_y;
				}
				else
					pos_y += fontsize_y * CENTERPRINT_SPACING/2;
			}
		}

		++g; // move next position number up

		msg_size = pos_y - msg_size;
		if (autocvar_hud_panel_centerprint_flip)
		{
			pos_y = current_msg_pos_y - CENTERPRINT_SPACING * fontsize_y;
			if (a < 1 && centerprint_msgID[j] == 0) // messages with id can be replaced just after they are faded out, so never move over them the next messages
				pos_y += (msg_size + CENTERPRINT_SPACING * fontsize_y) * (1 - sqrt(sz));

			if (pos_y < panel_pos_y) // check if the next message can be shown
			{
				drawfontscale = '1 1 0';
				return;
			}
		}
		else
		{
			pos_y += CENTERPRINT_SPACING * fontsize_y;
			if (a < 1 && centerprint_msgID[j] == 0) // messages with id can be replaced just after they are faded out, so never move over them the next messages
				pos_y -= (msg_size + CENTERPRINT_SPACING * fontsize_y) * (1 - sqrt(sz));

			if(pos_y > panel_pos_y + panel_size_y - fontsize_y) // check if the next message can be shown
			{
				drawfontscale = '1 1 0';
				return;
			}
		}
	}
	drawfontscale = '1 1 0';
	if (all_messages_expired)
	{
		centerprint_showing = FALSE;
		reset_centerprint_messages();
	}
}

// QuickMenu (#17)
//
// QUICKMENU_MAXLINES must be <= 10
#define QUICKMENU_MAXLINES 10
#define QUICKMENU_MAXENTRIES 256
string QuickMenu_Command[QUICKMENU_MAXLINES];
string QuickMenu_Description[QUICKMENU_MAXLINES];
float QuickMenu_CurrentPage;
float QuickMenu_IsLastPage;
// each quickmenu entry (submenu or command) is composed of 2 entries in the buffer
#define QUICKMENU_BUFFER_MAXENTRIES 2*QUICKMENU_MAXENTRIES
var float QuickMenu_Buffer = -1;
float QuickMenu_Buffer_Size;
float QuickMenu_Buffer_Index;
string QuickMenu_CurrentSubMenu;
float QuickMenu_CurrentPage_FirstEntry;
var float QuickMenu_Entries;
float QuickMenu_TimeOut;
void HUD_QuickMenu_load_entry(float i, string s, string s1)
{
	//printf("^xc80 entry %d: %s, %s\n", i, s, s1);
	if (QuickMenu_Description[i])
		strunzone(QuickMenu_Description[i]);
	QuickMenu_Description[i] = strzone(s);
	if (QuickMenu_Command[i])
		strunzone(QuickMenu_Command[i]);
	QuickMenu_Command[i] = strzone(s1);
}
void HUD_QuickMenu_clear_entry(float i)
{
	if (QuickMenu_Description[i])
		strunzone(QuickMenu_Description[i]);
	QuickMenu_Description[i] = string_null;
	if (QuickMenu_Command[i])
		strunzone(QuickMenu_Command[i]);
	QuickMenu_Command[i] = string_null;
}

void HUD_QuickMenu_Load_DefaultEntries();
float HUD_QuickMenu_Buffer_Init()
{
	float fh = -1;
	string s;
	if(autocvar_hud_panel_quickmenu_file != "")
	if(autocvar_hud_panel_quickmenu_file != "0")
		fh = fopen(autocvar_hud_panel_quickmenu_file, FILE_READ);
	if(fh < 0)
	{
		QuickMenu_Buffer = buf_create();
		if(QuickMenu_Buffer < 0)
			return false;
		HUD_QuickMenu_Load_DefaultEntries();
		QuickMenu_TimeOut = time + autocvar_hud_panel_quickmenu_time;
		return true;
	}

	QuickMenu_Buffer = buf_create();
	if (QuickMenu_Buffer < 0)
	{
		fclose(fh);
		return false;
	}

	QuickMenu_Buffer_Size = 0;
	while((s = fgets(fh)) && QuickMenu_Buffer_Size < QUICKMENU_BUFFER_MAXENTRIES)
	{
		// first skip invalid entries, so we don't check them anymore
		float argc;
		argc = tokenize_console(s);
		if(argc == 0 || argc > 2)
			continue;
		if(argv(0) == "")
			continue;
		if(argc == 2 && argv(1) == "")
			continue;

		if(argc == 1)
			bufstr_set(QuickMenu_Buffer, QuickMenu_Buffer_Size, strcat("S", argv(0))); // Submenu
		else
		{
			bufstr_set(QuickMenu_Buffer, QuickMenu_Buffer_Size, strcat("T", argv(0))); // command Title
			++QuickMenu_Buffer_Size;
			bufstr_set(QuickMenu_Buffer, QuickMenu_Buffer_Size, argv(1)); // command
		}
		++QuickMenu_Buffer_Size;
		QuickMenu_TimeOut = time + autocvar_hud_panel_quickmenu_time;
	}

	if (QuickMenu_Buffer_Size <= 0)
	{
		buf_del(QuickMenu_Buffer);
		QuickMenu_Buffer = -1;
	}
	fclose(fh);
	return true;
}

void HUD_QuickMenu_Buffer_Close()
{
	if (QuickMenu_Buffer >= 0)
	{
		buf_del(QuickMenu_Buffer);
		QuickMenu_Buffer = -1;
		QuickMenu_Buffer_Size = 0;
	}
}

void HUD_QuickMenu_Close()
{
	if (QuickMenu_CurrentSubMenu)
		strunzone(QuickMenu_CurrentSubMenu);
	QuickMenu_CurrentSubMenu = string_null;
	float i;
	for (i = 0; i < QUICKMENU_MAXLINES; ++i)
		HUD_QuickMenu_clear_entry(i);
	QuickMenu_Entries = 0;
	hud_panel_quickmenu = 0;
	mouseClicked = 0;
	prevMouseClicked = 0;
	HUD_QuickMenu_Buffer_Close();

	if(autocvar_hud_cursormode)
	if(!mv_active)
		setcursormode(0);
}

// It assumes submenu open tag is already detected
void HUD_QuickMenu_skip_submenu(string submenu)
{
	string s, z_submenu;
	z_submenu = strzone(submenu);
	for(++QuickMenu_Buffer_Index ; QuickMenu_Buffer_Index < QuickMenu_Buffer_Size; ++QuickMenu_Buffer_Index)
	{
		s = bufstr_get(QuickMenu_Buffer, QuickMenu_Buffer_Index);
		if(substring(s, 0, 1) != "S")
			continue;
		if(substring(s, 1, strlen(s) - 1) == z_submenu) // submenu end
			break;
		HUD_QuickMenu_skip_submenu(substring(s, 1, strlen(s) - 1));
	}
	strunzone(z_submenu);
}

float HUD_QuickMenu_IsOpened()
{
	return (QuickMenu_Entries > 0);
}

// new_page 0 means page 0, new_page != 0 means next page
float QuickMenu_Buffer_Index_Prev;
float HUD_QuickMenu_Page(string target_submenu, float new_page)
{
	string s, z_submenu;

	if (new_page == 0)
		QuickMenu_CurrentPage = 0;
	else
		++QuickMenu_CurrentPage;
	QuickMenu_CurrentPage_FirstEntry = QuickMenu_CurrentPage * (QUICKMENU_MAXLINES - 2);

	z_submenu = strzone(target_submenu);
	if (QuickMenu_CurrentSubMenu)
		strunzone(QuickMenu_CurrentSubMenu);
	QuickMenu_CurrentSubMenu = strzone(z_submenu);

	QuickMenu_IsLastPage = TRUE;
	QuickMenu_Entries = 0;

	QuickMenu_Buffer_Index = 0;
	if (z_submenu != "")
	{
		// skip everything until the submenu open tag is found
		for( ; QuickMenu_Buffer_Index < QuickMenu_Buffer_Size; ++QuickMenu_Buffer_Index)
		{
			s = bufstr_get(QuickMenu_Buffer, QuickMenu_Buffer_Index);
			if(substring(s, 0, 1) == "S" && substring(s, 1, strlen(s) - 1) == z_submenu)
			{
				// printf("^3 beginning of %s\n", z_submenu);
				++QuickMenu_Buffer_Index;
				break;
			}
			// printf("^1 skipping %s\n", s);
		}
	}
	float total = 0;
	for( ; QuickMenu_Buffer_Index < QuickMenu_Buffer_Size; ++QuickMenu_Buffer_Index)
	{
		s = bufstr_get(QuickMenu_Buffer, QuickMenu_Buffer_Index);

		if(z_submenu != "" && substring(s, 1, strlen(s) - 1) == z_submenu)
		{
			// printf("^3 end of %s\n", z_submenu);
			break;
		}

		if (total - QuickMenu_CurrentPage_FirstEntry >= 0)
		{
			++QuickMenu_Entries;
			if(QuickMenu_Entries == QUICKMENU_MAXLINES - 2)
				QuickMenu_Buffer_Index_Prev = QuickMenu_Buffer_Index;
			else if(QuickMenu_Entries == QUICKMENU_MAXLINES)
			{
				HUD_QuickMenu_clear_entry(QUICKMENU_MAXLINES - 1);
				QuickMenu_Buffer_Index = QuickMenu_Buffer_Index_Prev;
				QuickMenu_IsLastPage = FALSE;
				break;
			}
		}

		// NOTE: entries are loaded starting from 1, not from 0
		if(substring(s, 0, 1) == "S") // submenu
		{
			if (total - QuickMenu_CurrentPage_FirstEntry >= 0)
				HUD_QuickMenu_load_entry(QuickMenu_Entries, substring(s, 1, strlen(s) - 1), "");
			HUD_QuickMenu_skip_submenu(substring(s, 1, strlen(s) - 1));
		}
		else if (total - QuickMenu_CurrentPage_FirstEntry >= 0)
		{
			++QuickMenu_Buffer_Index;
			string cmd = bufstr_get(QuickMenu_Buffer, QuickMenu_Buffer_Index);
			HUD_QuickMenu_load_entry(QuickMenu_Entries, substring(s, 1, strlen(s) - 1), cmd);
		}

		++total;
	}
	strunzone(z_submenu);
	if (QuickMenu_Entries == 0)
	{
		HUD_QuickMenu_Close();
		return 0;
	}
	QuickMenu_TimeOut = time + autocvar_hud_panel_quickmenu_time;
	return 1;
}

void HUD_QuickMenu_Open()
{
	if(!HUD_QuickMenu_Buffer_Init()) return;

	hud_panel_quickmenu = 1;
	if(autocvar_hud_cursormode)
		setcursormode(1);
	hudShiftState = 0;

	HUD_QuickMenu_Page("", 0);
}

float HUD_QuickMenu_ActionForNumber(float num)
{
	if (!QuickMenu_IsLastPage)
	{
		if (num < 0 || num >= QUICKMENU_MAXLINES)
			return 0;
		if (num == QUICKMENU_MAXLINES - 1)
			return 0;
		if (num == 0)
		{
			HUD_QuickMenu_Page(QuickMenu_CurrentSubMenu, +1);
			return 0;
		}
	} else if (num <= 0 || num > QuickMenu_Entries)
		return 0;

	if (QuickMenu_Command[num] != "")
	{
		localcmd(strcat("\n", QuickMenu_Command[num], "\n"));
		return 1;
	}
	if (QuickMenu_Description[num] != "")
		HUD_QuickMenu_Page(QuickMenu_Description[num], 0);
	return 0;
}

float HUD_QuickMenu_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	// we only care for keyboard events
	if(bInputType == 2)
		return false;

	if(!HUD_QuickMenu_IsOpened() || autocvar__hud_configure || mv_active)
		return false;

	if(bInputType == 3)
	{
		mousepos_x = nPrimary;
		mousepos_y = nSecondary;
		return true;
	}

	// allow console bind to work
	string con_keys;
	float keys;
	con_keys = findkeysforcommand("toggleconsole", 0);
	keys = tokenize(con_keys); // findkeysforcommand returns data for this

	float hit_con_bind = 0, i;
	for (i = 0; i < keys; ++i)
	{
		if(nPrimary == stof(argv(i)))
			hit_con_bind = 1;
	}

	if(bInputType == 0) {
		if(nPrimary == K_ALT) hudShiftState |= S_ALT;
		if(nPrimary == K_CTRL) hudShiftState |= S_CTRL;
		if(nPrimary == K_SHIFT) hudShiftState |= S_SHIFT;
	}
	else if(bInputType == 1) {
		if(nPrimary == K_ALT) hudShiftState -= (hudShiftState & S_ALT);
		if(nPrimary == K_CTRL) hudShiftState -= (hudShiftState & S_CTRL);
		if(nPrimary == K_SHIFT) hudShiftState -= (hudShiftState & S_SHIFT);
	}

	if(nPrimary == K_ESCAPE)
	{
		if (bInputType == 1)
			return true;
		HUD_QuickMenu_Close();
	}
	else if(nPrimary >= '0' && nPrimary <= '9')
	{
		if (bInputType == 1)
			return true;
		HUD_QuickMenu_ActionForNumber(stof(chr2str(nPrimary)));
	}
	if(nPrimary == K_MOUSE1)
	{
		if(bInputType == 0) // key pressed
			mouseClicked |= S_MOUSE1;
		else if(bInputType == 1) // key released
			mouseClicked -= (mouseClicked & S_MOUSE1);
	}
	else if(nPrimary == K_MOUSE2)
	{
		if(bInputType == 0) // key pressed
			mouseClicked |= S_MOUSE2;
		else if(bInputType == 1) // key released
			mouseClicked -= (mouseClicked & S_MOUSE2);
	}
	else if(hit_con_bind)
		return false;

	return true;
}
void HUD_QuickMenu_Mouse()
{
	if(mv_active) return;

	if(!mouseClicked)
	if(prevMouseClicked & S_MOUSE2)
	{
		HUD_QuickMenu_Close();
		return;
	}

	if(!autocvar_hud_cursormode)
	{
		mousepos = mousepos + getmousepos() * autocvar_menu_mouse_speed;

		mousepos_x = bound(0, mousepos_x, vid_conwidth);
		mousepos_y = bound(0, mousepos_y, vid_conheight);
	}

	HUD_Panel_UpdateCvars()

	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	float first_entry_pos, entries_height;
	vector fontsize;
	fontsize = '1 1 0' * (panel_size_y / QUICKMENU_MAXLINES);
	first_entry_pos = panel_pos_y + ((QUICKMENU_MAXLINES - QuickMenu_Entries) * fontsize_y) / 2;
	entries_height = panel_size_y - ((QUICKMENU_MAXLINES - QuickMenu_Entries) * fontsize_y);

	if (mousepos_x >= panel_pos_x && mousepos_y >= first_entry_pos && mousepos_x <= panel_pos_x + panel_size_x && mousepos_y <= first_entry_pos + entries_height)
	{
		float entry_num;
		entry_num = floor((mousepos_y - first_entry_pos) / fontsize_y);
		if (QuickMenu_IsLastPage || entry_num != QUICKMENU_MAXLINES - 2)
		{
			panel_pos_y = first_entry_pos + entry_num * fontsize_y;
			vector color;
			if(mouseClicked & S_MOUSE1)
				color = '0.5 1 0.5';
			else if(hudShiftState & S_CTRL)
				color = '1 1 0.3';
			else
				color = '1 1 1';
			drawfill(panel_pos, eX * panel_size_x + eY * fontsize_y, color, .2, DRAWFLAG_NORMAL);

			if(!mouseClicked && (prevMouseClicked & S_MOUSE1))
			{
				float f;
				if (entry_num < QUICKMENU_MAXLINES - 1)
					f = HUD_QuickMenu_ActionForNumber(entry_num + 1);
				else
					f = HUD_QuickMenu_ActionForNumber(0);
				if(f && !(hudShiftState & S_CTRL))
					HUD_QuickMenu_Close();
			}
		}
	}

	const vector cursorsize = '32 32 0';
	drawpic(mousepos, strcat("gfx/menu/", autocvar_menu_skin, "/cursor.tga"), cursorsize, '1 1 1', 0.8, DRAWFLAG_NORMAL);

	prevMouseClicked = mouseClicked;
}
void HUD_QuickMenu_DrawEntry(vector pos, string s, vector fontsize)
{
	string entry;
	float offset;
	entry = textShortenToWidth(s, panel_size_x, fontsize, stringwidth_colors);
	if (autocvar_hud_panel_quickmenu_align > 0)
	{
		offset = (panel_size_x - stringwidth_colors(entry, fontsize)) * min(autocvar_hud_panel_quickmenu_align, 1);
		drawcolorcodedstring(pos + eX * offset, entry, fontsize, panel_fg_alpha, DRAWFLAG_ADDITIVE);
	}
	else
		drawcolorcodedstring(pos, entry, fontsize, panel_fg_alpha, DRAWFLAG_ADDITIVE);
}
void HUD_QuickMenu(void)
{
	if(!autocvar__hud_configure)
	{
		if (hud_configure_prev && hud_configure_prev != -1)
			HUD_QuickMenu_Close();

		if(!hud_draw_maximized) return;
		if(mv_active) return;
		//if(!autocvar_hud_panel_quickmenu) return;
		if(!hud_panel_quickmenu) return;

		if(time > QuickMenu_TimeOut)
		{
			HUD_QuickMenu_Close();
			return;
		}
	}
	else
	{
		if(!HUD_QuickMenu_IsOpened())
		{
			QuickMenu_Entries = 1;
			HUD_QuickMenu_load_entry(QuickMenu_Entries, sprintf(_("Submenu%d"), QuickMenu_Entries), "");
			++QuickMenu_Entries;
			HUD_QuickMenu_load_entry(QuickMenu_Entries, sprintf(_("Submenu%d"), QuickMenu_Entries), "");
			++QuickMenu_Entries;
			// although real command doesn't matter here, it must not be empty
			// otherwise the entry is displayed like a submenu
			for (; QuickMenu_Entries < QUICKMENU_MAXLINES - 1; ++QuickMenu_Entries)
				HUD_QuickMenu_load_entry(QuickMenu_Entries, sprintf(_("Command%d"), QuickMenu_Entries), "-");
			++QuickMenu_Entries;
			HUD_QuickMenu_clear_entry(QuickMenu_Entries);
			QuickMenu_IsLastPage = FALSE;
		}
	}

	HUD_Panel_UpdateCvars();

	HUD_Panel_DrawBg(1);

	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	float i;
	vector fontsize;
	string color;
	fontsize = '1 1 0' * (panel_size_y / QUICKMENU_MAXLINES);

	if (!QuickMenu_IsLastPage)
	{
		color = "^5";
		HUD_QuickMenu_DrawEntry(panel_pos + eY * (panel_size_y - fontsize_y), sprintf("%d: %s%s", 0, color, _("Continue...")), fontsize);
	}
	else
		panel_pos_y += ((QUICKMENU_MAXLINES - QuickMenu_Entries) * fontsize_y) / 2;

	for (i = 1; i <= QuickMenu_Entries; ++i) {
		if (QuickMenu_Description[i] == "")
			break;
		if (QuickMenu_Command[i] == "")
			color = "^4";
		else
			color = "^3";
		HUD_QuickMenu_DrawEntry(panel_pos, sprintf("%d: %s%s", i, color, QuickMenu_Description[i]), fontsize);
		panel_pos_y += fontsize_y;
	}
}

#define QUICKMENU_SMENU(submenu) \
	if(QuickMenu_Buffer_Size < QUICKMENU_BUFFER_MAXENTRIES) \
		bufstr_set(QuickMenu_Buffer, QuickMenu_Buffer_Size, strcat("S", submenu)); \
	++QuickMenu_Buffer_Size;

#define QUICKMENU_ENTRY(title,command) { \
	if(QuickMenu_Buffer_Size + 1 < QUICKMENU_BUFFER_MAXENTRIES) \
	{ \
		bufstr_set(QuickMenu_Buffer, QuickMenu_Buffer_Size, strcat("T", title)); \
		++QuickMenu_Buffer_Size; \
		bufstr_set(QuickMenu_Buffer, QuickMenu_Buffer_Size, command); \
	} \
	++QuickMenu_Buffer_Size; \
}

// useful to Translate a string inside the Command
#define QUICKMENU_ENTRY_TC(title,command,text,translated_text) \
	if(cvar_string("prvm_language") == "en") \
		QUICKMENU_ENTRY(title, sprintf(command, text)) \
	else if(!autocvar_hud_panel_quickmenu_translatecommands || translated_text == text) \
		QUICKMENU_ENTRY(strcat("(en)", title), sprintf(command, text)) \
	else \
		QUICKMENU_ENTRY(strcat("(", cvar_string("prvm_language"), ")", title), sprintf(command, translated_text))

void HUD_QuickMenu_Load_DefaultEntries()
{
QUICKMENU_SMENU(CTX(_("QMCMD^Chat")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^nice one")), "say %s", ":-) / nice one", CTX(_("QMCMD^:-) / nice one")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^good game")), "say %s", "good game", CTX(_("QMCMD^good game")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^hi / good luck")), "say %s", "hi / good luck and have fun", CTX(_("QMCMD^hi / good luck and have fun")))
QUICKMENU_SMENU(CTX(_("QMCMD^Chat")))

QUICKMENU_SMENU(CTX(_("QMCMD^Team chat")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^quad soon")), "say_team %s", "quad soon", CTX(_("QMCMD^quad soon")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^free item, icon")), "say_team %s; g_waypointsprite_team_here_p", "free item %x^7 (l:%y^7)", CTX(_("QMCMD^free item %x^7 (l:%y^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^took item, icon")), "say_team %s; g_waypointsprite_team_here", "took item (l:%l^7)", CTX(_("QMCMD^took item (l:%l^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^negative")), "say_team %s", "negative", CTX(_("QMCMD^negative")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^positive")), "say_team %s", "positive", CTX(_("QMCMD^positive")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^need help, icon")), "say_team %s; g_waypointsprite_team_helpme; cmd voice needhelp", "need help (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)", CTX(_("QMCMD^need help (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^enemy seen, icon")), "say_team %s; g_waypointsprite_team_danger_p; cmd voice incoming", "enemy seen (l:%y^7)", CTX(_("QMCMD^enemy seen (l:%y^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^flag seen, icon")), "say_team %s; g_waypointsprite_team_here_p; cmd voice seenflag", "flag seen (l:%y^7)", CTX(_("QMCMD^flag seen (l:%y^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^defending, icon")), "say_team %s; g_waypointsprite_team_here", "defending (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)", CTX(_("QMCMD^defending (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^roaming, icon")), "say_team %s; g_waypointsprite_team_here", "roaming (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)", CTX(_("QMCMD^roaming (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^attacking, icon")), "say_team %s; g_waypointsprite_team_here", "attacking (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)", CTX(_("QMCMD^attacking (l:%l^7) (h:%h^7 a:%a^7 w:%w^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^killed flag, icon")), "say_team %s; g_waypointsprite_team_here_p", "killed flagcarrier (l:%y^7)", CTX(_("QMCMD^killed flagcarrier (l:%y^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^dropped flag, icon")), "say_team %s; g_waypointsprite_team_here_d", "dropped flag (l:%d^7)", CTX(_("QMCMD^dropped flag (l:%d^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^drop gun, icon")), "say_team %s; g_waypointsprite_team_here; wait; dropweapon", "dropped gun %w^7 (l:%l^7)", CTX(_("QMCMD^dropped gun %w^7 (l:%l^7)")))
	QUICKMENU_ENTRY_TC(CTX(_("QMCMD^drop flag/key, icon")), "say_team %s; g_waypointsprite_team_here; wait; +use", "dropped flag/key %w^7 (l:%l^7)", CTX(_("QMCMD^dropped flag/key %w^7 (l:%l^7)")))
QUICKMENU_SMENU(CTX(_("QMCMD^Team chat")))

QUICKMENU_SMENU(CTX(_("QMCMD^Settings")))
	QUICKMENU_SMENU(CTX(_("QMCMD^View/HUD settings")))
		QUICKMENU_ENTRY(CTX(_("QMCMD^1st/3rd person view")), "toggle chase_active")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Player models like mine on/off")), "toggle cl_forceplayermodels")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Names above players on/off")), "toggle hud_shownames")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Crosshair per weapon on/off")), "toggle crosshair_per_weapon")
		QUICKMENU_ENTRY(CTX(_("QMCMD^FPS on/off")), "toggle hud_panel_engineinfo")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Net graph on/off")), "toggle shownetgraph")
	QUICKMENU_SMENU(CTX(_("QMCMD^View/HUD settings")))

	QUICKMENU_SMENU(CTX(_("QMCMD^Sound settings")))
		QUICKMENU_ENTRY(CTX(_("QMCMD^Hit sound on/off")), "toggle cl_hitsound")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Chat sound on/off")), "toggle cl_chatsound")
	QUICKMENU_SMENU(CTX(_("QMCMD^Sound settings")))

	QUICKMENU_SMENU(CTX(_("QMCMD^Spectator camera")))
		QUICKMENU_ENTRY(CTX(_("QMCMD^1st person")), "chase_active 0; -use")
		QUICKMENU_ENTRY(CTX(_("QMCMD^3rd person free")), "chase_active 1; +use")
		QUICKMENU_ENTRY(CTX(_("QMCMD^3rd person behind")), "chase_active 1; -use")
	QUICKMENU_SMENU(CTX(_("QMCMD^Spectator camera")))

	QUICKMENU_SMENU(CTX(_("QMCMD^Observer camera")))
		QUICKMENU_ENTRY(CTX(_("QMCMD^Increase speed")), "weapnext")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Decrease speed")), "weapprev")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Wall collision off")), "-use")
		QUICKMENU_ENTRY(CTX(_("QMCMD^Wall collision on")), "+use")
	QUICKMENU_SMENU(CTX(_("QMCMD^Observer camera")))
	
	QUICKMENU_ENTRY(CTX(_("QMCMD^toggle fullscreen")), "toggle vid_fullscreen; vid_restart")
QUICKMENU_SMENU(CTX(_("QMCMD^Settings")))

QUICKMENU_SMENU(CTX(_("QMCMD^Call a vote")))
	QUICKMENU_ENTRY(CTX(_("QMCMD^Restart the map")), "vcall restart")
	QUICKMENU_ENTRY(CTX(_("QMCMD^End match")), "vcall endmatch")
	QUICKMENU_ENTRY(CTX(_("QMCMD^Reduce match time")), "vcall reducematchtime")
	QUICKMENU_ENTRY(CTX(_("QMCMD^Extend match time")), "vcall extendmatchtime")
	QUICKMENU_ENTRY(CTX(_("QMCMD^Shuffle teams")), "vcall shuffleteams")
QUICKMENU_SMENU(CTX(_("QMCMD^Call a vote")))
}
#undef QUICKMENU_SMENU
#undef QUICKMENU_ENTRY


// Status Effects (#18)
//
void DrawStatusEffectItem(vector myPos, vector mySize, float itemcode)
{
	float a, show_timer;
	show_timer = !(StatusEffectInfo(itemcode).spawnflags & STAT_TYPE_NOTIMER);
	if(autocvar__hud_configure)
	{
		a = 31 + mod(itemcode*93, 128);
	}
	else
		a = ((show_timer) ? StatusEffect(itemcode) - time : StatusEffect(itemcode));

	vector color = (StatusEffectInfo(itemcode)).colormod;

	float theAlpha = 1;

	vector picpos, numpos;
	if(autocvar_hud_panel_statuseffects_iconalign == 1)
	{
		numpos = myPos;
		picpos = myPos + eX * 2 * mySize_y;
	}
	else if(autocvar_hud_panel_statuseffects_iconalign == 2)
	{
		numpos = myPos + eY * mySize_y;
		picpos = myPos;
	}
	else
	{
		numpos = myPos + eX * mySize_y;
		picpos = myPos;
	}

	if(a > 0)
	{
		if(autocvar_hud_panel_statuseffects_progressbar)
		if(show_timer)
			HUD_Panel_DrawProgressBar(myPos + eX * autocvar_hud_panel_statuseffects_progressbar_xoffset * mySize_x, mySize - eX * autocvar_hud_panel_statuseffects_progressbar_xoffset * mySize_x, autocvar_hud_panel_statuseffects_progressbar_name, ceil(a)/10, 0, 0, color, autocvar_hud_progressbar_alpha * panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
	
		if(autocvar_hud_panel_statuseffects_text)
		{
			if(show_timer)
				drawstring_aspect(myPos + eX * autocvar_hud_panel_statuseffects_progressbar_xoffset * mySize_x, ftos(ceil(a)), mySize - eX * autocvar_hud_panel_statuseffects_progressbar_xoffset * mySize_x, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
			if(autocvar_hud_panel_statuseffects_text == 2)
				drawstring_aspect(numpos, StatusEffectInfo(itemcode).message, eX * (2/3) * mySize_x + eY * mySize_y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
		}

		drawpic_aspect_skin(picpos, strcat("effect_", StatusEffectInfo(itemcode).netname), '1 1 0' * mySize_y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
	}
}

void HUD_StatusEffects(void)
{
	if(hud != HUD_NORMAL) return;
	if(!autocvar__hud_configure)
	{
		if(!autocvar_hud_panel_statuseffects) return;
		if(spectatee_status == -1) return;
	}

	HUD_Panel_UpdateCvars();

	draw_beginBoldFont();

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	HUD_Panel_DrawBg(1);
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}

	float rows = 0, columns, row, column;
	float total_effect_count = 0;
	
	float i;
	for(i = STATUS_EFFECT_FIRST; i <= STATUS_EFFECT_LAST; ++i)
	if(StatusEffect(i))
		++total_effect_count;

	vector effect_size;

	rows = mySize_y/mySize_x;
	rows = bound(1, floor((sqrt(4 * (3/1) * rows * (total_effect_count) + rows * rows) + rows + 0.5) / 2), (total_effect_count));
	//                               ^^^ effect item aspect goes here

	columns = ceil((total_effect_count)/rows);

	effect_size = eX * mySize_x*(1/columns) + eY * mySize_y*(1/rows);
	

	local vector offset = '0 0 0'; // fteqcc sucks
	float newSize;
	if(effect_size_x/effect_size_y > 3)
	{
		newSize = 3 * effect_size_y;
		offset_x = effect_size_x - newSize;
		pos_x += offset_x/2;
		effect_size_x = newSize;
	}
	else
	{
		newSize = 1/3 * effect_size_x;
		offset_y = effect_size_y - newSize;
		pos_y += offset_y/2;
		effect_size_y = newSize;
	}

	row = column = 0;

	for(i = STATUS_EFFECT_FIRST; i <= STATUS_EFFECT_LAST; ++i)
	if(StatusEffect(i))
	{
		DrawStatusEffectItem(pos + eX * column * (effect_size_x + offset_x) + eY * row * (effect_size_y + offset_y), effect_size, i);
		++row;
		if(row >= rows)
		{
			row = 0;
			column = column + 1;
		}
	}

	draw_endBoldFont();
}


/*
==================
Main HUD system
==================
*/

void HUD_Reset (void)
{
	// reset gametype specific icons
	switch(gametype)
	{
		case MAPINFO_TYPE_KEYHUNT: HUD_Mod_KH_Reset(); break;
		case MAPINFO_TYPE_CTF: HUD_Mod_CTF_Reset(); break;
		case MAPINFO_TYPE_VIP: HUD_Mod_VIP_Reset(); break;
	}
}

void HUD_Main (void)
{
	float i;
	// global hud theAlpha fade
	if(menu_enabled == 1)
		hud_fade_alpha = 1;
	else
		hud_fade_alpha = (1 - autocvar__menu_alpha);

	if(scoreboard_fade_alpha)
		hud_fade_alpha = (1 - scoreboard_fade_alpha);

	HUD_Configure_Frame();

	if(intermission == 2) // no hud during mapvote
		hud_fade_alpha = 0;

	// panels that we want to be active together with the scoreboard
	// they must fade only when the menu does
	if(scoreboard_fade_alpha == 1)
	{
		(panel = HUD_PANEL(CENTERPRINT)).panel_draw();
		return;
	}

	if(!autocvar__hud_configure && !hud_fade_alpha)
	{
		hud_fade_alpha = 1;
		(panel = HUD_PANEL(VOTE)).panel_draw();
		hud_fade_alpha = 0;
		return;
	}

	// Drawing stuff
	if (hud_skin_prev != autocvar_hud_skin)
	{
		if (hud_skin_path)
			strunzone(hud_skin_path);
		hud_skin_path = strzone(strcat("gfx/hud/", autocvar_hud_skin));
		if (hud_skin_prev)
			strunzone(hud_skin_prev);
		hud_skin_prev = strzone(autocvar_hud_skin);
	}

#ifdef COMPAT_XON050_ENGINE
    current_player = (spectatee_status > 0) ? spectatee_status : player_localentnum;
#else
    current_player = player_localentnum;
#endif

	// draw the dock
	if(autocvar_hud_dock != "" && autocvar_hud_dock != "0")
	{
		float f;
		vector color;
		float hud_dock_color_team = autocvar_hud_dock_color_team;
		if((teamplay) && hud_dock_color_team) {
			if(autocvar__hud_configure && myteam == NUM_SPECTATOR)
				color = '1 0 0' * hud_dock_color_team;
			else
				color = myteamcolors * hud_dock_color_team;
		}
		else if(autocvar_hud_configure_teamcolorforced && autocvar__hud_configure && hud_dock_color_team) {
			color = '1 0 0' * hud_dock_color_team;
		}
		else
		{
			string hud_dock_color = autocvar_hud_dock_color;
			if(hud_dock_color == "shirt") {
				f = stof(getplayerkeyvalue(current_player - 1, "colors"));
				color = colormapPaletteColor(floor(f / 16), 0);
			}
			else if(hud_dock_color == "pants") {
				f = stof(getplayerkeyvalue(current_player - 1, "colors"));
				color = colormapPaletteColor(mod(f, 16), 1);
			}
			else
				color = stov(hud_dock_color);
		}

		string pic;
		pic = strcat(hud_skin_path, "/", autocvar_hud_dock);
		if(precache_pic(pic) == "") {
			pic = strcat(hud_skin_path, "/dock_medium");
			if(precache_pic(pic) == "") {
				pic = "gfx/hud/default/dock_medium";
			}
		}
		drawpic('0 0 0', pic, eX * vid_conwidth + eY * vid_conheight, color, autocvar_hud_dock_alpha * hud_fade_alpha, DRAWFLAG_NORMAL); // no aspect ratio forcing on dock...
	}

	// cache the panel order into the panel_order array
	if(autocvar__hud_panelorder != hud_panelorder_prev) {
		for(i = 0; i < HUD_PANEL_NUM; ++i)
			panel_order[i] = -1;
		string s = "";
		float p_num, warning = false;
		float argc = tokenize_console(autocvar__hud_panelorder);
		if (argc > HUD_PANEL_NUM)
			warning = true;
		//first detect wrong/missing panel numbers
		for(i = 0; i < HUD_PANEL_NUM; ++i) {
			p_num = stof(argv(i));
			if (p_num >= 0 && p_num < HUD_PANEL_NUM) { //correct panel number?
				if (panel_order[p_num] == -1) //found for the first time?
					s = strcat(s, ftos(p_num), " ");
				panel_order[p_num] = 1; //mark as found
			}
			else
				warning = true;
		}
		for(i = 0; i < HUD_PANEL_NUM; ++i) {
			if (panel_order[i] == -1) {
				warning = true;
				s = strcat(s, ftos(i), " "); //add missing panel number
			}
		}
		if (warning)
			print(_("Automatically fixed wrong/missing panel numbers in _hud_panelorder\n"));

		cvar_set("_hud_panelorder", s);
		if(hud_panelorder_prev)
			strunzone(hud_panelorder_prev);
		hud_panelorder_prev = strzone(s);

		//now properly set panel_order
		tokenize_console(s);
		for(i = 0; i < HUD_PANEL_NUM; ++i) {
			panel_order[i] = stof(argv(i));
		}
	}

	hud_draw_maximized = 0;
	// draw panels in order specified by panel_order array
	for(i = HUD_PANEL_NUM - 1; i >= 0; --i)
		(panel = hud_panel[panel_order[i]]).panel_draw();

	hud_draw_maximized = 1; // panels that may be maximized must check this var
	// draw maximized panels on top
	if(hud_panel_radar_maximized)
		(panel = HUD_PANEL(RADAR)).panel_draw();
	if(autocvar__con_chat_maximized)
		(panel = HUD_PANEL(CHAT)).panel_draw();
	if(hud_panel_quickmenu)
		(panel = HUD_PANEL(QUICKMENU)).panel_draw();

	HUD_Configure_PostDraw();

	hud_configure_prev = autocvar__hud_configure;
}
