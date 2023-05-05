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