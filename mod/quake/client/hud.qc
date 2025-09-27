#include "hud.qh"

void HUD_Panel_DrawProgressBar(vector theOrigin, vector theSize, string pic, float length_ratio, bool vertical, float baralign, vector theColor, float theAlpha, int drawflag)
{
	TC(bool, vertical); TC(int, drawflag);
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
		pic = strcat("gfx/quake/", pic, "_vertical");
		if(precache_pic(pic) == "") {
			pic = "gfx/hud/default/progressbar_vertical";
		}

		if (baralign == 1) // bottom align
			theOrigin.y += (1 - length_ratio) * theSize.y;
		else if (baralign == 2) // center align
			theOrigin.y += 0.5 * (1 - length_ratio) * theSize.y;
		else if (baralign == 3) // center align, positive values down, negative up
		{
			theSize.y *= 0.5;
			if (length_ratio > 0)
				theOrigin.y += theSize.y;
			else
			{
				theOrigin.y += (1 + length_ratio) * theSize.y;
				length_ratio = -length_ratio;
			}
		}
		theSize.y *= length_ratio;

		vector bH;
		width = eX * theSize.x;
		height = eY * theSize.y;
		if(theSize.y <= theSize.x * 2)
		{
			// button not high enough
			// draw just upper and lower part then
			square = eY * theSize.y * 0.5;
			bH = eY * (0.25 * theSize.y / (theSize.x * 2));
			drawsubpic(theOrigin,          square + width, pic, '0 0 0', eX + bH, theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + square, square + width, pic, eY - bH, eX + bH, theColor, theAlpha, drawflag);
		}
		else
		{
			square = eY * theSize.x;
			drawsubpic(theOrigin,                   width   +     square, pic, '0 0    0', '1 0.25 0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin +          square, theSize - 2 * square, pic, '0 0.25 0', '1 0.5  0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + height - square, width   +     square, pic, '0 0.75 0', '1 0.25 0', theColor, theAlpha, drawflag);
		}
	} else {
		pic = strcat("gfx/quake/", pic);
		if(precache_pic(pic) == "") {
			pic = "gfx/hud/default/progressbar";
		}

		if (baralign == 1) // right align
			theOrigin.x += (1 - length_ratio) * theSize.x;
		else if (baralign == 2) // center align
			theOrigin.x += 0.5 * (1 - length_ratio) * theSize.x;
		else if (baralign == 3) // center align, positive values on the right, negative on the left
		{
			theSize.x *= 0.5;
			if (length_ratio > 0)
				theOrigin.x += theSize.x;
			else
			{
				theOrigin.x += (1 + length_ratio) * theSize.x;
				length_ratio = -length_ratio;
			}
		}
		theSize.x *= length_ratio;

		vector bW;
		width = eX * theSize.x;
		height = eY * theSize.y;
		if(theSize.x <= theSize.y * 2)
		{
			// button not wide enough
			// draw just left and right part then
			square = eX * theSize.x * 0.5;
			bW = eX * (0.25 * theSize.x / (theSize.y * 2));
			drawsubpic(theOrigin,          square + height, pic, '0 0 0', eY + bW, theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + square, square + height, pic, eX - bW, eY + bW, theColor, theAlpha, drawflag);
		}
		else
		{
			square = eX * theSize.y;
			drawsubpic(theOrigin,                  height  +     square, pic, '0    0 0', '0.25 1 0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin +         square, theSize - 2 * square, pic, '0.25 0 0', '0.5  1 0', theColor, theAlpha, drawflag);
			drawsubpic(theOrigin + width - square, height  +     square, pic, '0.75 0 0', '0.25 1 0', theColor, theAlpha, drawflag);
		}
	}
}

void DrawNumIcon_expanding(vector myPos, vector mySize, float theTime, string icon, bool vertical, bool isInfinite, int icon_right_align, vector color, float theAlpha, float fadelerp)
{
	int oldfont = drawfont;
	drawfont = 8;

	TC(bool, vertical); TC(int, icon_right_align);
	vector newPos = '0 0 0', newSize = '0 0 0';
	vector picpos, numpos;
	string text = isInfinite ? "\xE2\x88\x9E" : ftos(theTime); // Use infinity symbol (U+221E)

	float panel_fg_alpha = autocvar_sbar_alpha_fg;

	if (vertical)
	{
		if(mySize.y/mySize.x > 2)
		{
			newSize.y = 2 * mySize.x;
			newSize.x = mySize.x;

			newPos.y = myPos.y + (mySize.y - newSize.y) / 2;
			newPos.x = myPos.x;
		}
		else
		{
			newSize.x = 1/2 * mySize.y;
			newSize.y = mySize.y;

			newPos.x = myPos.x + (mySize.x - newSize.x) / 2;
			newPos.y = myPos.y;
		}

		if(icon_right_align)
		{
			numpos = newPos;
			picpos = newPos + eY * newSize.x;
		}
		else
		{
			picpos = newPos;
			numpos = newPos + eY * newSize.x;
		}

		newSize.y /= 2;
		drawpic_aspect_skin(picpos, icon, newSize, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);
		// make number smaller than icon, it looks better
		// reduce only y to draw numbers with different number of digits with the same y size
		numpos.y += newSize.y * ((1 - 0.7) / 2);
		newSize.y *= 0.7;
		drawstring_aspect(numpos, text, newSize, color, panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL);

		drawfont = oldfont;
		return;
	}

	if(mySize.x/mySize.y > 3)
	{
		newSize.x = 3 * mySize.y;
		newSize.y = mySize.y;

		newPos.x = myPos.x + (mySize.x - newSize.x) / 2;
		newPos.y = myPos.y;
	}
	else
	{
		newSize.y = 1/3 * mySize.x;
		newSize.x = mySize.x;

		newPos.y = myPos.y + (mySize.y - newSize.y) / 2;
		newPos.x = myPos.x;
	}

	if(icon_right_align) // right align
	{
		numpos = newPos;
		picpos = newPos + eX * 2 * newSize.y;
	}
	else // left align
	{
		numpos = newPos + eX * newSize.y;
		picpos = newPos;
	}

	// NOTE: newSize_x is always equal to 3 * mySize_y so we can use
	// '2 1 0' * newSize_y instead of eX * (2/3) * newSize_x + eY * newSize_y
	drawstring_aspect_expanding(numpos, text, '2 1 0' * newSize.y, color, panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL, fadelerp);
	drawpic_aspect_skin_expanding(picpos, icon, '1 1 0' * newSize.y, '1 1 1', panel_fg_alpha * theAlpha, DRAWFLAG_NORMAL, fadelerp);

	drawfont = oldfont;
}

void DrawNumIcon(vector myPos, vector mySize, float theTime, string icon, bool vertical, bool isInfinite, int icon_right_align, vector color, float theAlpha)
{
	TC(bool, vertical); TC(int, icon_right_align);
	DrawNumIcon_expanding(myPos, mySize, theTime, icon, vertical, isInfinite, icon_right_align, color, theAlpha, 0);
}
