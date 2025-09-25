#include "powerups.qh"

#include "draw.qh"
#include "../common/util.qh"

// Powerups (#2)
// copied from Xonotic

// Powerup item fields (reusing existing fields)
.string message;  // Human readable name
.string netname;  // Icon name
.vector colormod; // Color
.float count;     // Time left
.float lifetime;  // Maximum time
.float cnt;       // Infinite timer

entity powerupItems;
int powerupItemsCount;

void resetPowerupItems()
{
	entity item;
	for(item = powerupItems; item; item = item.chain)
		item.count = 0;

	powerupItemsCount = 0;
}

void addPowerupItem(string name, string icon, vector color, float currentTime, float lifeTime, bool isInfinite)
{
	if(!powerupItems)
		powerupItems = spawn();

	entity item;
	for(item = powerupItems; item.count; item = item.chain)
		if(!item.chain)
			item.chain = spawn();

	item.message  = name;
	item.netname  = icon;
	item.colormod = color;
	item.count    = currentTime;
	item.lifetime = lifeTime;
	item.cnt      = isInfinite;

	++powerupItemsCount;
}

int getPowerupItemAlign(int align, int column, int row, int columns, int rows, bool isVertical)
{
	TC(int, align); TC(int, column); TC(int, row); TC(int, columns); TC(int, rows); TC(bool, isVertical);
	if(align < 2)
		return align;

	bool isTop    =  isVertical && rows > 1 && row == 0;
	bool isBottom =  isVertical && rows > 1 && row == rows-1;
	bool isLeft   = !isVertical && columns > 1 && column == 0;
	bool isRight  = !isVertical && columns > 1 && column == columns-1;

	if(isTop    || isLeft)  return (align == 2) ? 1 : 0;
	if(isBottom || isRight) return (align == 2) ? 0 : 1;

	return 2;
}

STATIC_INIT(Powerups)
{
	registercvar("sbar_powerups_pos", "0.4 0.9");
	registercvar("sbar_powerups_size", "0.2 0.035");
}

void HUD_Powerups()
{
	// Initialize items
	if((player_localnum + 1) != player_localentnum)
		return;
	if(STAT(ITEMS) & IT_TANK)
		return;
	if(STAT(HEALTH) <= 0)
		return;

	// Add items to linked list
	resetPowerupItems();

	status_effects_HUD_Powerups_add();

	if(!powerupItemsCount)
		return;

	int oldfont = drawfont;
	drawfont = 8 + 2;

	vector panel_pos = stov(cvar_string("sbar_powerups_pos"));
	vector panel_size = stov(cvar_string("sbar_powerups_size"));

	HUD_Panel_ScalePosSize();

	// Set drawing area
	vector pos = panel_pos;
	vector size = panel_size;
	bool isVertical = size.y > size.x;

	float panel_bg_padding = 2;
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		size -= '2 2 0' * panel_bg_padding;
	}

	// Find best partitioning of the drawing area
	const float DESIRED_ASPECT = 6;
	float aspect = 0, a;
	int columns = 0, c;
	int rows = 0, r;
	int i = 1;

	do
	{
		c = floor(powerupItemsCount / i);
		r = ceil(powerupItemsCount / c);
		a = isVertical ? (size.y/r) / (size.x/c) : (size.x/c) / (size.y/r);

		if(i == 1 || fabs(DESIRED_ASPECT - a) < fabs(DESIRED_ASPECT - aspect))
		{
			aspect = a;
			columns = c;
			rows = r;
		}
	}
	while(++i <= powerupItemsCount);

	// Prevent single items from getting too wide
	if(powerupItemsCount == 1 && aspect > DESIRED_ASPECT)
	{
		if(isVertical)
		{
			size.y *= 0.5;
			pos.y += size.y * 0.5;
		}
		else
		{
			size.x *= 0.5;
			pos.x += size.x * 0.5;
		}
	}

	// Draw items from linked list
	vector itemPos = pos;
	vector itemSize = vec2(size.x / columns, size.y / rows);
	vector textColor = '0.6 0.2 0'; // quake colors, yay!

	int fullSeconds = 0;
	int align = 0;
	int column = 0;
	int row = 0;

	for(entity item = powerupItems; item.count; item = item.chain)
	{
		itemPos = vec2(pos.x + column * itemSize.x, pos.y + row * itemSize.y);

		// Draw icon and text
			align = getPowerupItemAlign(0, column, row, columns, rows, isVertical);
			fullSeconds = ceil(item.count);
			//textColor = '0.6 0.6 0.6' + (item.colormod * 0.4);

			if(item.cnt)
				DrawNumIcon(itemPos, itemSize, fullSeconds, item.netname, isVertical, true, align, textColor, 1);
			else
			{
				//if(item.count > 1)
					DrawNumIcon(itemPos, itemSize, fullSeconds, item.netname, isVertical, false, align, textColor, 1);
				//if(item.count <= 5)
					//DrawNumIcon_expanding(itemPos, itemSize, fullSeconds, item.netname, isVertical, false, align, textColor, 1, bound(0, (fullSeconds - item.count) / 0.5, 1));
			}

		// Determine next section
		if(isVertical)
		{
			if(++column >= columns)
			{
				column = 0;
				++row;
			}
		}
		else
		{
			if(++row >= rows)
			{
				row = 0;
				++column;
			}
		}
	}
	drawfont = oldfont;
}
