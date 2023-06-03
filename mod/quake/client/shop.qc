#include "shop.qh"

#include "../common/shop.qh"
#include "../common/sounds/all.qh"

STATIC_INIT_LATE(shop_init)
{
	registercommand("shop");
}

void shop_close();

.float shopkeep_delay;

float selected_entity_index;

const int EXTRA_ITEMS = 4;

// plus 1 so we can add heal as a first option
string weplist[REGISTRY_MAX(Weapons) + EXTRA_ITEMS];
int wepcost[REGISTRY_MAX(Weapons) + EXTRA_ITEMS];
int wepcount;

vector entity_menu_scroll;

string Weapon_PrettyName(string wepname)
{
	if(wepname == "heal")
		return "Health";
	if(wepname == "armor")
		return "Armor";
	if(wepname == "ammo")
		return "Ammunition";
	if(wepname == "rifle")
		return "Pulse Rifle Sidearm";
	Weapon wep = Weapon_from_name(wepname);
	return wep.m_name;
}

void shop_buyselected()
{
	LOG_DEBUG("Buying ", weplist[selected_entity_index]);
	localcmd(sprintf("cmd shop %s\n", weplist[selected_entity_index]));
	if(csqcplayer) // just play it from the player so we don't have to look for the gremlin!
		_sound(csqcplayer, CH_TRIGGER_SINGLE, "grem/sight1.wav", VOL_BASE, ATTEN_NORM);
	shop_close();
}

void entity_list(string id, vector pos, vector size)
{
	for(int j = 0; j < REGISTRY_MAX(Weapons) + EXTRA_ITEMS; ++j)
	{
		weplist[j] = string_null;
		wepcost[j] = 0;
	}
	wepcount = 0;
	// initialize the other items first
	weplist[wepcount] = "heal";
	wepcost[wepcount] = SHOP_COST_HEAL;
	wepcount += 1;
	weplist[wepcount] = "armor";
	wepcost[wepcount] = SHOP_COST_ARMOR;
	wepcount += 1;
	weplist[wepcount] = "ammo";
	wepcost[wepcount] = SHOP_COST_AMMO;
	wepcount += 1;
	if(!(STAT(ITEMS) & IT_PULSERIFLE))
	{
		weplist[wepcount] = "rifle";
		wepcost[wepcount] = SHOP_COST_RIFLE;
		wepcount += 1;
	}
	FOREACH(Weapons, it != WEP_Null,
	{
		if(STAT(WEAPONS) & it.m_wepset)
			continue;
		if(!(STAT(SHOP_WEAPONS) & it.m_wepset))
			continue;
		if(it.spawnflags & WEP_FLAG_NOSTEAL)
			continue; // exclude some weapons!
		if(!MP_HIPNOTIC && (it.spawnflags & WEP_FLAG_HIPNOTIC))
			continue;
		if(!MP_ROGUE && (it.spawnflags & WEP_FLAG_ROGUE))
			continue;
		if(!MP_HIPNOTIC && (it.spawnflags & WEP_FLAG_HIPNOTIC))
			continue;
		weplist[wepcount] = it.netname;
		wepcost[wepcount] = ((it.m_cost) ? it.m_cost : SHOP_COST_WEAPON);
		wepcount += 1;
	});

	sui_fill(pos, size, '0.2 0.2 0.2', 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, vec2(size.x - 6, 16), wepcount, '0 6 0');
	sui_pos = '0 0 0';
	for(float index = sui_list_item(); index > -1; index = sui_list_item())
	{
		sui_push_frame(sui_pos, vec2(size.x - 6, 16));
		string iid = strcat(id, ftos(index));
		sui_action_element('0 0 0', vec2(size.x -6, 16), iid);
		if(sui_is_hovered(iid))
		{
			sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.1, 0);
			if(sui_is_clicked(iid))
			{
				selected_entity_index = index;
				shop_buyselected();
				break;
			}
		}
		sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_CENTER));
		if(selected_entity_index == index)
			sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.2, 0);
		sui_drawtext('0 0 0', '8 8 0', strcat("$", ftos(wepcost[index]), " ", Weapon_PrettyName(weplist[index])), '1 1 1', 1, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
}

void cl_shop_draw()
{
	if(!cursor_active)
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
		if(vdist(it.origin - myorigin, <, 100))
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
	sui_drawtext('0 160 0', '16 16 0', sprintf("Score: %s", getplayerkeyvalue(player_localnum, "frags")), '1 1 1', 1, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_fill('0 0 0', '4 4 0', '0 0 0', 0.5, 0);
	sui_fill('0 0 0', '2 2 0', '1 1 1', 0.75, 0);
	
	vector ent_menu_size = '280 140 0';
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
	selected_entity_index = 0;
	cursor_active = true;
	setcursormode(cursor_active);
}

void shop_close()
{
	selected_entity_index = 0;
	cursor_active = false;
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
	if(!cursor_active)
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
				return true;
			}
			if(scanx == K_DOWNARROW)
			{
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

	if(vdist(this.origin - player.origin, >, 50))
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
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.solid = SOLID_NOT;
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
