#include "all.qh"

#ifdef CSQC
#include "../../client/view.qh"
#endif

// WEAPON PLUGIN SYSTEM

WepSet _WepSet_FromWeapon(int a)
{
	a -= WEP_FIRST;
	if (REGISTRY_MAX(Weapons) > 24)
		if (a >= 24)
		{
			a -= 24;
			if (REGISTRY_MAX(Weapons) > 48)
				if (a >= 24)
				{
					a -= 24;
					return '0 0 1' * BIT(a);
				}
			return '0 1 0' * BIT(a);
		}
	return '1 0 0' * BIT(a);
}
#ifdef SVQC
	void WriteWepSet(float dst, WepSet w)
	{
		if (REGISTRY_MAX(Weapons) > 48) WriteInt72_t(dst, w);
		else if (REGISTRY_MAX(Weapons) > 24) WriteInt48_t(dst, w);
		else WriteInt24_t(dst, w.x);
	}
#endif
#ifdef CSQC
	WepSet WepSet_GetFromStat()
	{
		return STAT(WEAPONS);
	}
	WepSet ReadWepSet()
	{
		if (REGISTRY_MAX(Weapons) > 48) return ReadInt72_t();
		if (REGISTRY_MAX(Weapons) > 24) return ReadInt48_t();
		return ReadInt24_t() * '1 0 0';
	}
#endif

string W_FixWeaponOrder(string order, float complete)
{
	return fixPriorityList(order, WEP_FIRST, WEP_LAST, WEP_IMPULSE_BEGIN - WEP_FIRST, complete);
}
string W_NameWeaponOrder_MapFunc(string s)
{
	int i = stof(s);
	if (s == "0" || i)
	{
		entity wi = REGISTRY_GET(Weapons, i);
		if (wi != WEP_Null) return wi.netname;
	}
	return s;
}

string W_NameWeaponOrder(string order)
{
	return mapPriorityList(order, W_NameWeaponOrder_MapFunc);
}
string W_NumberWeaponOrder_MapFunc(string s)
{
	if (s == "0" || stof(s)) return s;
	FOREACH(Weapons, it != WEP_Null && it.netname == s, return ftos(i));
	return s;
}
string W_NumberWeaponOrder(string order)
{
	return mapPriorityList(order, W_NumberWeaponOrder_MapFunc);
}

float W_FixWeaponOrder_BuildImpulseList_buf[REGISTRY_MAX(Weapons)];
string W_FixWeaponOrder_BuildImpulseList_order;
void W_FixWeaponOrder_BuildImpulseList_swap(int i, int j, entity pass)
{
	float h;
	h = W_FixWeaponOrder_BuildImpulseList_buf[i];
	W_FixWeaponOrder_BuildImpulseList_buf[i] = W_FixWeaponOrder_BuildImpulseList_buf[j];
	W_FixWeaponOrder_BuildImpulseList_buf[j] = h;
}
float W_FixWeaponOrder_BuildImpulseList_cmp(int i, int j, entity pass)
{
	int si = W_FixWeaponOrder_BuildImpulseList_buf[i];
	Weapon e1 = REGISTRY_GET(Weapons, si);
	int sj = W_FixWeaponOrder_BuildImpulseList_buf[j];
	Weapon e2 = REGISTRY_GET(Weapons, sj);
	int d = (e1.impulse + 9) % 10 - (e2.impulse + 9) % 10;
	if (d != 0) return -d;  // high impulse first!
	string s = strcat(" ", W_FixWeaponOrder_BuildImpulseList_order, " ");
	return strstrofs(s, sprintf(" %d ", si), 0)
		- strstrofs(s, sprintf(" %d ", sj), 0); // low char index first!
}
string W_FixWeaponOrder_BuildImpulseList(string o)
{
	int i;
	W_FixWeaponOrder_BuildImpulseList_order = o;
	for (i = WEP_FIRST; i <= WEP_LAST; ++i)
		W_FixWeaponOrder_BuildImpulseList_buf[i - WEP_FIRST] = i;
	heapsort(WEP_LAST - WEP_FIRST + 1, W_FixWeaponOrder_BuildImpulseList_swap, W_FixWeaponOrder_BuildImpulseList_cmp,
		NULL);
	o = "";
	for (i = WEP_FIRST; i <= WEP_LAST; ++i)
		o = strcat(o, " ", ftos(W_FixWeaponOrder_BuildImpulseList_buf[i - WEP_FIRST]));
	W_FixWeaponOrder_BuildImpulseList_order = string_null;
	return substring(o, 1, -1);
}

string W_FixWeaponOrder_AllowIncomplete(entity this, string order)
{
	return W_FixWeaponOrder(order, 0);
}

string W_FixWeaponOrder_ForceComplete(string order)
{
	if (order == "") order = W_NumberWeaponOrder(cvar_defstring("cl_quake_weaponpriority"));
	return W_FixWeaponOrder(order, 1);
}
	

#ifdef GAMEQC
vector shotorg_adjustfromclient(vector vecs)
{
	// center aligned
	vecs.y = 0;
	vecs.z -= 2;
	return vecs;
}

vector shotorg_adjust_values(vector vecs)
{
	// center aligned
	vecs.y = 0;
	vecs.z -= 2;
	return vecs;
}

#define shotorg_adjust shotorg_adjust_values

void CL_WeaponEntity_SetModel(entity this, string name)
{
	if (name == "")
	{
		vector oldmin = this.mins, oldmax = this.maxs;
		setmodel(this, MDL_Null);
		setsize(this, oldmin, oldmax);
		this.movedir = '0 0 0';
		this.oldorigin = '0 0 0';
	}
	else
	{
		_setmodel(this, strcat("progs/v_", name, ".mdl"));

		setsize(this, '0 0 0', '0 0 0');
		setorigin(this, '0 0 0');
		this.angles = '0 0 0';
		//this.frame = 0;
#ifdef SVQC
		this.viewmodelforclient = NULL;
#else
		this.renderflags &= ~RF_VIEWMODEL;
#endif
		this.movedir = '0 0 0';
		this.oldorigin = '0 0 0';  // use regular attachment

#ifdef SVQC
		this.viewmodelforclient = this.owner;
#else
		this.renderflags |= RF_VIEWMODEL;
#endif
	}

	this.view_ofs = '0 0 0';
	this.movedir_aligned = this.movedir;

	if (this.movedir.x >= 0)
	{
		vector v = this.movedir;
		this.movedir = shotorg_adjust(v);
		this.movedir_aligned = shotorg_adjust(v);
		this.view_ofs = this.movedir_aligned - v;
	}
	int compressed_shotorg = compressShotOrigin(this.movedir);
	// make them match perfectly
	this.movedir = decompressShotOrigin(compressed_shotorg);

	// check if an instant weapon switch occurred
	setorigin(this, this.view_ofs);
}
#endif

#ifdef GAMEQC

REGISTER_NET_TEMP(wframe)
#ifdef CSQC
NET_HANDLE(wframe, bool isNew)
{
	int fr = ReadByte();
	entity wepent = viewmodels;

	wepent.frame = fr;
	return true;
}
#endif

#endif

#ifdef SVQC
string W_FixWeaponOrder_ForceComplete_AndBuildImpulseList(entity this, string wo)
{
	string o = W_FixWeaponOrder_ForceComplete(wo);
	strcpy(this.weaponorder_byimpulse, W_FixWeaponOrder_BuildImpulseList(o));
	return o;
}
#endif

#ifdef GAMEQC
REPLICATE(cvar_cl_weapon_switch_fallback_to_impulse, bool, "cl_quake_weapon_switch_fallback_to_impulse");
REPLICATE(cvar_cl_weaponimpulsemode, int, "cl_quake_weaponimpulsemode");
REPLICATE(cvar_cl_weaponpriority, string, "cl_quake_weaponpriority", W_FixWeaponOrder_ForceComplete_AndBuildImpulseList);
REPLICATE(cvar_cl_weaponpriorities[0], string, "cl_quake_weaponpriority0", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[1], string, "cl_quake_weaponpriority1", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[2], string, "cl_quake_weaponpriority2", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[3], string, "cl_quake_weaponpriority3", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[4], string, "cl_quake_weaponpriority4", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[5], string, "cl_quake_weaponpriority5", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[6], string, "cl_quake_weaponpriority6", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[7], string, "cl_quake_weaponpriority7", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[8], string, "cl_quake_weaponpriority8", W_FixWeaponOrder_AllowIncomplete);
REPLICATE(cvar_cl_weaponpriorities[9], string, "cl_quake_weaponpriority9", W_FixWeaponOrder_AllowIncomplete);
#endif