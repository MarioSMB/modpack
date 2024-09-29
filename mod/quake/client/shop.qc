#include "shop.qh"

#include "../common/shop.qh"
#include "../common/sounds/all.qh"

STATIC_INIT_LATE(shop_init)
{
	registercommand("shop");
}

void shop_close();

.float shopkeep_delay;

int shop_hovered_index;
int shop_item_count;

enum
{
	SHOP_ITEM_HEAL,
	SHOP_ITEM_ARMOR,
	SHOP_ITEM_AMMO,
	SHOP_ITEM_PASSIVE,
	SHOP_ITEM_WEAPON
};

int shoplist[SHOP_ITEM_MAX];
int shopdata[SHOP_ITEM_MAX];

vector entity_menu_scroll;

string Shop_Passive_PrettyName(int itemid)
{
	switch(itemid)
	{
		case PASSIVE_PULSERIFLE: return "Pulse Rifle Sidearm";
		case PASSIVE_FIREBALL: return "Fireball Launcher";
		case PASSIVE_AMMOPOUCH: return "Ammo Pouch";
		case PASSIVE_ADRENALIN: return "Adrenalin";
		case PASSIVE_BOOMER: return "Boomer";
		case PASSIVE_LOOTER: return "Looter";
		case PASSIVE_AURA: return "Aura of Pain";
		case PASSIVE_ELECTRIFYING: return "Electrifying";
		case PASSIVE_BUNNYBOOTS: return "Bunny Boots";
		case PASSIVE_DOUBLEJUMP: return "Double Jump";
	}
	return "";
}

string Shop_Passive_Name(int itemid)
{
	switch(itemid)
	{
		case PASSIVE_PULSERIFLE: return "rifle";
		case PASSIVE_FIREBALL: return "fireball";
		case PASSIVE_AMMOPOUCH: return "ammopouch";
		case PASSIVE_ADRENALIN: return "adrenalin";
		case PASSIVE_BOOMER: return "boomer";
		case PASSIVE_LOOTER: return "looter";
		case PASSIVE_AURA: return "aura";
		case PASSIVE_ELECTRIFYING: return "electrifying";
		case PASSIVE_BUNNYBOOTS: return "bunnyboots";
		case PASSIVE_DOUBLEJUMP: return "doublejump";
	}
	return "";
}

string ShopItem_PrettyName(int index)
{
	int sname = shoplist[index];
	int sdata = shopdata[index];
	switch(sname)
	{
		case SHOP_ITEM_HEAL: return "Health";
		case SHOP_ITEM_ARMOR: return "Armor";
		case SHOP_ITEM_AMMO: return "Ammunition";
		case SHOP_ITEM_PASSIVE: return Shop_Passive_PrettyName(sdata);
		case SHOP_ITEM_WEAPON: return REGISTRY_GET(Weapons, sdata).m_name;
	}
	return "";
}

string ShopItem_Name(int index)
{
	int sname = shoplist[index];
	int sdata = shopdata[index];
	switch(sname)
	{
		case SHOP_ITEM_HEAL: return "heal";
		case SHOP_ITEM_ARMOR: return "armor";
		case SHOP_ITEM_AMMO: return "ammo";
		case SHOP_ITEM_PASSIVE: return Shop_Passive_Name(sdata);
		case SHOP_ITEM_WEAPON: return REGISTRY_GET(Weapons, sdata).netname;
	}
	return "";
}

vector ShopItem_Color(int index)
{
	int sname = shoplist[index];
	//int sdata = shopdata[index];
	switch(sname)
	{
		case SHOP_ITEM_HEAL: return '1 0.25 0.25';
		case SHOP_ITEM_ARMOR: return '0.25 1 0.25';
		case SHOP_ITEM_AMMO: return '0.45 0.35 1';
		case SHOP_ITEM_PASSIVE: return '1 1 0.25';
		case SHOP_ITEM_WEAPON: return '1 1 1';
	}
	return '1 1 1';
}

int ShopItem_Cost(int index)
{
	int sname = shoplist[index];
	//int sdata = shopdata[index];
	switch(sname)
	{
		case SHOP_ITEM_HEAL: return SHOP_COST_HEAL;
		case SHOP_ITEM_ARMOR: return SHOP_COST_ARMOR;
		case SHOP_ITEM_AMMO: return SHOP_COST_AMMO;
		case SHOP_ITEM_PASSIVE: return SHOP_COST_PASSIVE;
		case SHOP_ITEM_WEAPON: return SHOP_COST_WEAPON;
	}
	return 0;
}

bool ShopItem_Owned(int index)
{
	int sname = shoplist[index];
	int sdata = shopdata[index];
	switch(sname)
	{
		// always available
		case SHOP_ITEM_HEAL: return false;
		case SHOP_ITEM_ARMOR: return false;
		case SHOP_ITEM_AMMO: return false;
		case SHOP_ITEM_PASSIVE: return (STAT(PASSIVES) & sdata);
		case SHOP_ITEM_WEAPON:
		{
			Weapon wep = REGISTRY_GET(Weapons, sdata);
			if((STAT(WEAPONS) & wep.m_wepset) && ((STAT(DUAL_WEAPONS) & wep.m_wepset) || (wep.spawnflags & WEP_FLAG_NODUAL)))
				return true;
			else
				return false;
		}
	}
	return false;
}

void shop_buyselected()
{
	if(shop_hovered_index == -1)
	{
		shop_close();
		return;
	}

	LOG_DEBUG("Buying ", ShopItem_Name(shop_hovered_index));
	localcmd(sprintf("cmd shop %s\n", ShopItem_Name(shop_hovered_index)));
	if(csqcplayer) // just play it from the player so we don't have to look for the gremlin!
		_sound(csqcplayer, CH_TRIGGER_SINGLE, "grem/sight1.wav", VOL_BASE, ATTEN_NORM);
	shop_close();
}

void entity_list(string id, vector pos, vector size)
{
	for(int j = 0; j < SHOP_ITEM_MAX; ++j)
	{
		shoplist[j] = 0;
		shopdata[j] = 0;
	}
	int itemcount = 0;
	// initialize the other items first
	shoplist[itemcount] = SHOP_ITEM_HEAL;
	itemcount += 1;
	shoplist[itemcount] = SHOP_ITEM_ARMOR;
	itemcount += 1;
	shoplist[itemcount] = SHOP_ITEM_AMMO;
	itemcount += 1;
	for(int j = 0; j < PASSIVE_COUNT; ++j)
	{
		int passive = BIT(j);
		if(!(STAT(SHOP_PASSIVES & passive)))
			continue;
		shoplist[itemcount] = SHOP_ITEM_PASSIVE;
		shopdata[itemcount] = passive;
		itemcount += 1;
	}
	FOREACH(Weapons, it != WEP_Null,
	{
		if(!(STAT(SHOP_WEAPONS) & it.m_wepset))
			continue;
		if((it.spawnflags & WEP_FLAG_NOSTEAL) || (it.spawnflags & WEP_FLAG_CHAMPION))
			continue; // exclude some weapons!
		shoplist[itemcount] = SHOP_ITEM_WEAPON;
		shopdata[itemcount] = it.m_id;
		itemcount += 1;
	});

	shop_item_count = itemcount;

	sui_fill(pos, size, '0.2 0.2 0.2', 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, vec2(size.x - 6, 16), itemcount, '0 6 0');
	sui_pos = '0 0 0';
	for(float index = sui_list_item(); index > -1; index = sui_list_item())
	{
		sui_push_frame(sui_pos, vec2(size.x - 6, 16));
		string iid = strcat(id, ftos(index));
		sui_action_element('0 0 0', vec2(size.x -6, 16), iid);
		if(!ShopItem_Owned(index) && sui_is_hovered(iid))
		{
			shop_hovered_index = index;
			sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.1, 0);
			if(sui_is_clicked(iid))
			{
				shop_buyselected();
				break;
			}
		}
		sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_CENTER));
		if(shop_hovered_index == index)
			sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.2, 0);
		bool owned = ShopItem_Owned(index);
		string coststr = (owned) ? "(Owned) " : strcat("$", ftos(ShopItem_Cost(index)), " ");
		bool can_afford = (owned || entcs_GetClientFrags(player_localnum) >= ShopItem_Cost(index));
		if((STAT(ITEMS) & IT_TANK) && (shoplist[index] == SHOP_ITEM_HEAL || shoplist[index] == SHOP_ITEM_ARMOR))
			can_afford = false;
		vector textcolor = ((can_afford) ? ShopItem_Color(index) : '0.75 0.75 0.75');
		float textalpha = ((can_afford) ? 1 : 0.25);
		sui_drawtext('0 0 0', '8 8 0', strcat(coststr, ShopItem_PrettyName(index)), textcolor, textalpha, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
}

void cl_shop_draw()
{
	if(!(cursor_active & GUI_OPEN_SHOP))
		return;

	if(STAT(SHOP_OPEN) < time)
	{
		shop_close();
		return;
	}

	bool closetoshop = false;
	vector myorigin = (csqcplayer) ? csqcplayer.origin : view_origin;
	IL_EACH(g_drawables, it.classname == "ENT_CLIENT_SHOPKEEP",
	{
		if(vdist(it.origin - myorigin, <, 200))
		{
			closetoshop = true;
			break;
		}
	});

	if(!closetoshop)
	{
		shop_close();
		return;
	}
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext('0 140 0', '16 16 0', "SHOP", '0.3 1 0.3', 1, 0);
	sui_drawtext('0 160 0', '16 16 0', sprintf("Score: %d", entcs_GetClientFrags(player_localnum)), '1 1 1', 1, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_fill('0 0 0', '4 4 0', '0 0 0', 0.5, 0);
	sui_fill('0 0 0', '2 2 0', '1 1 1', 0.75, 0);
	
	vector ent_menu_size = '280 180 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_push_frame('0 0 0', ent_menu_size);
	
	sui_fill('0 0 0', ent_menu_size, '0 0 0', 0.5, 0);
	sui_offset = entity_menu_scroll;
	entity_list("entlist", '0 0 0', ent_menu_size - '2 2 0');
	entity_menu_scroll = sui_offset;
	
	sui_pop_frame();
}

void shop_open()
{
	shop_hovered_index = -1;
	shop_item_count = 0;
	cursor_active |= GUI_OPEN_SHOP;
	setcursormode(cursor_active);
}

void shop_close()
{
	shop_hovered_index = -1;
	shop_item_count = 0;
	cursor_active &= ~GUI_OPEN_SHOP;
	setcursormode(cursor_active);

	IL_EACH(g_drawables, it.classname == "ENT_CLIENT_SHOPKEEP",
	{
		it.shopkeep_delay = time + 1.5; // don't retrigger immediately
	});
}

// This must be called in CSQC_ConsoleCommand
// input entity self
// input string cmd: same as in CSQC_ConsoleCommand
// output float: true if command was handled, false if not
bool cl_shop_command(string cmd)
{
	// cmd is actually argv(1)
	if(cmd == "shop")
	{
		if(argv(1) != "")
		{
			localcmd(strcat("cmd shop ", argv(1), "\n"));
			return true;
		}
		shop_open();
		return true;
	}
	return false;
}

bool cl_shop_input_event(float evtype, float scanx, float chary, float devid)
{
	if(!(cursor_active & GUI_OPEN_SHOP))
		return false;
	
	switch(evtype)
	{
		case IE_KEYDOWN:
			if(substring(sui_get_last_clicked(), 0, 3) == "in_")
				return true;
	
			if(scanx == K_MOUSE1)
			{ 
				// handle regardless
				return true;
			}
			if(scanx == K_UPARROW)
			{
				if(shop_item_count <= 0)
					return true;
				shop_hovered_index -= 1;
				if(shop_hovered_index < 0)
					shop_hovered_index = shop_item_count - 1;
				return true;
			}
			if(scanx == K_DOWNARROW)
			{
				if(shop_item_count <= 0)
					return true;
				shop_hovered_index += 1;
				if(shop_hovered_index >= shop_item_count)
					shop_hovered_index = 0;
				return true;
			}
			if(scanx == K_LEFTARROW)
			{
				return true;
			}
			if(scanx == K_RIGHTARROW)
			{
				return true;
			}
			if(scanx == K_PGUP)
			{
				return true;
			}
			if(scanx == K_PGDN)
			{
				return true;
			}
			if(scanx == K_DEL)
			{
				return true;
			}

			if(scanx == K_ENTER)
				return true;

			if(scanx == K_MOUSE2 || scanx == K_ESCAPE)
			{
				shop_close();
				return true;
			}

			if(scanx == K_MWHEELUP || scanx == K_MWHEELDOWN)
				return true; // don't handle on server
			break;
		case IE_KEYUP:
			if(scanx == K_ENTER)
			{
				if(shop_hovered_index == -1)
					return true;
				shop_buyselected();
				return true;
			}

			if(scanx == K_MWHEELUP || scanx == K_MWHEELDOWN)
				return true; // don't handle on server
			break;
		case IE_MOUSEDELTA:
			break;
		case IE_MOUSEABS:
			break;
	}
	
	return false;
}

.float shopkeep_frametick;
.vector colormod;
void shopkeep_draw(entity this)
{
	if(time > this.shopkeep_frametick)
	{
		CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
		this.frame += 1;
		if(STAT(SHOP_OPEN) > time)
		{
			if(this.frame < 44 || this.frame > 59)
				this.frame = 44;
		}
		else if(this.frame > 16)
			this.frame = 0;
		CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
		this.shopkeep_frametick = time + 0.1; // roughly match quake animations
	}

	CSQCModel_InterpolateAnimation_Do(this);

	if(!csqcplayer)
		return; // dunno how, but we kinda need a player to work with!
	entity player = csqcplayer;

	// face the player if they're nearby!
	if(vdist(this.origin - player.origin, <, 400))
		this.angles_y = vectoyaw(player.origin - this.origin);

	if(cursor_active)
		return; // already started TODO: better indicator that we're inside the menu
	if(!STAT(HORDE) || STAT(SHOP_OPEN) < time)
		return; // not active yet TODO: message about this fact?
	if(this.shopkeep_delay > time)
		return;

	if(vdist(this.origin - player.origin, >, 150))
		return;

	this.shopkeep_delay = 0;
	_sound(this, CH_TRIGGER_SINGLE, "grem/idle.wav", VOL_BASE, ATTEN_NORM);
	shop_open();
}

NET_HANDLE(ENT_CLIENT_SHOPKEEP, bool isnew)
{
	this.origin = ReadVector();
	setorigin(this, this.origin);

	_setmodel(this, "progs/grem.mdl");
	this.solid = SOLID_NOT;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	set_movetype(this, MOVETYPE_NONE);
	this.shopkeep_frametick = 0;
	this.frame = 0;
	this.colormod = '0 1 0'; // make sure people know he's friendly!
	CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
	CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
	this.lerpfrac = 0; // reset frames

	this.draw = shopkeep_draw;
	if(isnew)
		IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	return = true;
}
