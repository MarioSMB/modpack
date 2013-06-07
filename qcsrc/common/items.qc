// WEAPON PLUGIN SYSTEM
entity weapon_info[WEP_MAXCOUNT];
entity dummy_weapon_info;

void register_weapon(float id, float(float) func, float ammotype, float i, float weapontype, float pickupbasevalue, string modelname, string shortname, string wname)
{
	entity e;
	weapon_info[id - 1] = e = spawn();
	e.classname = "weapon_info";
	e.weapon = id;
	WEPSET_COPY_EW(e, id);
	e.netname = shortname;
	e.message = wname;
	e.items = ammotype;
	e.weapon_func = func;
	e.mdl = modelname;
	e.model = strzone(strcat("models/weapons/g_", modelname, ".md3"));
	e.spawnflags = weapontype;
	e.model2 = strzone(strcat("wpn-", e.mdl));
	e.impulse = i;
	e.bot_pickupbasevalue = pickupbasevalue;
	if(ammotype & IT_SHELLS)
		e.ammo_field = ammo_shells;
	else if(ammotype & IT_NAILS)
		e.ammo_field = ammo_nails;
	else if(ammotype & IT_ROCKETS)
		e.ammo_field = ammo_rockets;
	else if(ammotype & IT_CELLS)
		e.ammo_field = ammo_cells;
	else if(ammotype & IT_FUEL)
		e.ammo_field = ammo_fuel;
	else
		e.ammo_field = ammo_batteries;
}
float w_null(float dummy)
{
	return 0;
}
void register_weapons_done()
{
	dummy_weapon_info = spawn();
	dummy_weapon_info.classname = "weapon_info";
	dummy_weapon_info.weapon = 0; // you can recognize dummies by this
	WEPSET_CLEAR_E(dummy_weapon_info);
	dummy_weapon_info.netname = "";
	dummy_weapon_info.message = "AOL CD Thrower";
	dummy_weapon_info.items = 0;
	dummy_weapon_info.weapon_func = w_null;
	dummy_weapon_info.mdl = "";
	dummy_weapon_info.model = "";
	dummy_weapon_info.spawnflags = 0;
	dummy_weapon_info.model2 = "";
	dummy_weapon_info.impulse = -1;
	dummy_weapon_info.bot_pickupbasevalue = 0;

	float i;
	weaponorder_byid = "";
	for(i = WEP_MAXCOUNT; i >= 1; --i)
		if(weapon_info[i-1])
			weaponorder_byid = strcat(weaponorder_byid, " ", ftos(i));
	weaponorder_byid = strzone(substring(weaponorder_byid, 1, strlen(weaponorder_byid) - 1));
}
entity get_weaponinfo(float id)
{
	entity w;
	if(id < WEP_FIRST || id > WEP_LAST)
		return dummy_weapon_info;
	w = weapon_info[id - 1];
	if(w)
		return w;
	return dummy_weapon_info;
}
string W_FixWeaponOrder(string order, float complete)
{
	return fixPriorityList(order, WEP_FIRST, WEP_LAST, 230 - WEP_FIRST, complete);
}
string W_NameWeaponOrder_MapFunc(string s)
{
	entity wi;
	if(s == "0" || stof(s))
	{
		wi = get_weaponinfo(stof(s));
		if(wi != dummy_weapon_info)
			return wi.netname;
	}
	return s;
}
string W_NameWeaponOrder(string order)
{
	return mapPriorityList(order, W_NameWeaponOrder_MapFunc);
}
string W_NumberWeaponOrder_MapFunc(string s)
{
	float i;
	if(s == "0" || stof(s))
		return s;
	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		if(s == get_weaponinfo(i).netname)
			return ftos(i);
	return s;
}
string W_NumberWeaponOrder(string order)
{
	return mapPriorityList(order, W_NumberWeaponOrder_MapFunc);
}

float W_FixWeaponOrder_BuildImpulseList_buf[WEP_MAXCOUNT];
string W_FixWeaponOrder_BuildImpulseList_order;
void W_FixWeaponOrder_BuildImpulseList_swap(float i, float j, entity pass)
{
	float h;
	h = W_FixWeaponOrder_BuildImpulseList_buf[i];
	W_FixWeaponOrder_BuildImpulseList_buf[i] = W_FixWeaponOrder_BuildImpulseList_buf[j];
	W_FixWeaponOrder_BuildImpulseList_buf[j] = h;
}
float W_FixWeaponOrder_BuildImpulseList_cmp(float i, float j, entity pass)
{
	entity e1, e2;
	float d;
	e1 = get_weaponinfo(W_FixWeaponOrder_BuildImpulseList_buf[i]);
	e2 = get_weaponinfo(W_FixWeaponOrder_BuildImpulseList_buf[j]);
	d = mod(e1.impulse + 9, 10) - mod(e2.impulse + 9, 10);
	if(d != 0)
		return -d; // high impulse first!
	return
		strstrofs(strcat(" ", W_FixWeaponOrder_BuildImpulseList_order, " "), sprintf(" %d ", W_FixWeaponOrder_BuildImpulseList_buf[i]), 0)
		-
		strstrofs(strcat(" ", W_FixWeaponOrder_BuildImpulseList_order, " "), sprintf(" %d ", W_FixWeaponOrder_BuildImpulseList_buf[j]), 0)
		; // low char index first!
}
string W_FixWeaponOrder_BuildImpulseList(string o)
{
	float i;
	W_FixWeaponOrder_BuildImpulseList_order = o;
	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		W_FixWeaponOrder_BuildImpulseList_buf[i - WEP_FIRST] = i;
	heapsort(WEP_LAST - WEP_FIRST + 1, W_FixWeaponOrder_BuildImpulseList_swap, W_FixWeaponOrder_BuildImpulseList_cmp, world);
	o = "";
	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		o = strcat(o, " ", ftos(W_FixWeaponOrder_BuildImpulseList_buf[i - WEP_FIRST]));
	W_FixWeaponOrder_BuildImpulseList_order = string_null;
	return substring(o, 1, -1);
}

string W_FixWeaponOrder_AllowIncomplete(string order)
{
	return W_FixWeaponOrder(order, 0);
}

string W_FixWeaponOrder_ForceComplete(string order)
{
	if(order == "")
		order = W_NumberWeaponOrder(cvar_defstring("cl_weaponpriority"));
	return W_FixWeaponOrder(order, 1);
}

void W_RandomWeapons(entity e, float n)
{
	float i, j;
	WEPSET_DECLARE_A(remaining);
	WEPSET_DECLARE_A(result);
	WEPSET_COPY_AE(remaining, e);
	WEPSET_CLEAR_A(result);
	for(i = 0; i < n; ++i)
	{
		RandomSelection_Init();
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
			if(WEPSET_CONTAINS_AW(remaining, j))
				RandomSelection_Add(world, j, string_null, 1, 1);
		WEPSET_OR_AW(result, RandomSelection_chosen_float);
		WEPSET_ANDNOT_AW(remaining, RandomSelection_chosen_float);
	}
	WEPSET_COPY_EA(e, result);
}

string W_Name(float weaponid)
{
	return (get_weaponinfo(weaponid)).message;
}

float W_AmmoItemCode(float wpn)
{
	return (get_weaponinfo(wpn)).items & IT_AMMO;
}
