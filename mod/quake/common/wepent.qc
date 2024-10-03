#include "wepent.qh"

#ifdef SVQC
.int sv_entnum;
#endif

#ifdef CSQC
void CSQCModel_InterpolateAnimation_1To2_Note(entity this, int sf, bool set_times);
//void CSQCModel_InterpolateAnimation_Do(entity this);
void CSQCModel_InterpolateAnimation_1To2_PreNote(entity this, int sf);

void wepent_CSQCModel_InterpolateAnimation_Do(entity this, float delta)
{
	if(!delta)
		delta = 0.1; // quake weapons use 10 fps
	//if(autocvar_cl_nolerp || (delta == 0))
	//{
		//this.lerpfrac = 0;
	//}
	//else
	//{
		if(this.frame2time == 0) // if frame2 was not previously displayed, only frame1 can make sense
			this.lerpfrac = 0;
		else
			this.lerpfrac = 1 - bound(0, (time - this.frame1time) / delta, 1);
	//}
}
#endif

#define WEPENT_SET_NORMAL(var, x) MACRO_BEGIN \
	var = x; \
MACRO_END

// #define PROP(public, fld, set, sv, cl)
#define WEPENT_NETPROPS(PROP) PROP(false, sv_entnum, WEPENT_SET_NORMAL, {}, {}) /* sentinel */ \
    PROP(false, m_weapon, WEPENT_SET_NORMAL, \
	{ WriteByte(chan, this.m_weapon.m_id); }, \
	{ (viewmodels[this.m_wepent_slot]).activeweapon = REGISTRY_GET(Weapons, ReadByte()); }) \
    \
    PROP(false, m_frame, WEPENT_SET_NORMAL, \
	{ WriteByte(chan, this.m_frame); }, \
	{ CSQCModel_InterpolateAnimation_1To2_PreNote((viewmodels[this.m_wepent_slot]), BIT(23)); (viewmodels[this.m_wepent_slot]).frame = ReadByte(); CSQCModel_InterpolateAnimation_1To2_Note((viewmodels[this.m_wepent_slot]), BIT(23), true); wepent_CSQCModel_InterpolateAnimation_Do((viewmodels[this.m_wepent_slot]), (viewmodels[this.m_wepent_slot]).activeweapon.m_delta); }) \
    \
    PROP(false, skin, WEPENT_SET_NORMAL, \
	{ WriteShort(chan, this.skin); }, \
	{ (viewmodels[this.m_wepent_slot]).m_skin = ReadShort(); }) \
    \
    PROP(false, m_gunalign, WEPENT_SET_NORMAL, \
	{ WriteByte(chan, this.m_gunalign); }, \
	{ (viewmodels[this.m_wepent_slot]).m_gunalign = ReadByte(); }) \
    \
    PROP(false, hammer_skin, WEPENT_SET_NORMAL, \
	{ WriteByte(chan, this.hammer_skin); }, \
	{ (viewmodels[this.m_wepent_slot]).hammer_skin = ReadByte(); }) \
    \
	/**/

#ifdef SVQC

	int WEPENT_PUBLICMASK = 0;
	STATIC_INIT(WEPENT_PUBLICMASK)
	{
		int i = 0;
		#define X(public, fld, set, sv, cl) { \
			if (public) { \
				WEPENT_PUBLICMASK |= BIT(i); \
			} \
			i += 1; \
		}
		WEPENT_NETPROPS(X);
	#undef X
		if (i >= BITS(24 - 1)) LOG_FATAL("Exceeded WEPENT_NETPROPS limit");
	}

	bool _wepent_send(entity this, entity to, int sf, int chan)
	{
		sf |= this.m_forceupdate;
		this.m_forceupdate = 0;
		if (chan == MSG_ENTITY)
			WriteHeader(chan, ENT_CLIENT_WEPENT);
		else
			WriteHeader(chan, CLIENT_WEPENT);
		.entity weaponentity = this.owner.weaponentity_fld;
		WriteByte(chan, weaponslot(weaponentity));
		WriteInt24_t(chan, sf);
		int i = 0;
		#define X(public, fld, set, sv, cl) { \
			if (sf & BIT(i)) { \
				sv; \
			} \
			i += 1; \
		}
		WEPENT_NETPROPS(X);
	#undef X
		return true;
	}

	bool wepent_send(entity this, entity to, int sf)
	{
		return _wepent_send(this, to, sf, MSG_ENTITY);
	}

	void wepent_think(entity this)
	{
		if(wasfreed(this.owner) || !this.owner)
		{
			delete(this);
			return;
		}

		this.nextthink = time;

		entity o = this.owner;

		int i = 0;
		#define X(public, fld, set, sv, cl) { \
			if (this.fld != o.fld) { \
				set(this.fld, o.fld); \
				this.SendFlags |= BIT(i); \
			} \
			i += 1; \
		}
		WEPENT_NETPROPS(X);
	#undef X
	}

	bool wepent_customize(entity this, entity client)
	{
		entity e = client;
		.entity weaponentity = this.owner.weaponentity_fld;
		return e.(weaponentity) == this.owner;
	}

	void wepent_link(entity wep)
	{
		entity e = new_pure(wepent_sender);
		e.owner = wep;
		setthink(e, wepent_think);
		e.nextthink = time;
		//e.drawonlytoclient = wep.owner;
		setcefc(e, wepent_customize);
		Net_LinkEntity(e, false, 0, wepent_send);
	}

#endif

#ifdef CSQC

	bool ReadWepent(entity this)
	{
		int slot = ReadByte();
		this.m_wepent_slot = slot;
		viewmodels[slot].m_wepent_slot = slot;
		int sf = ReadInt24_t();
		int i = 0;
		#define X(public, fld, set, sv, cl) { \
			if (sf & BIT(i)) { \
				cl; \
			} \
			i += 1; \
		}
		WEPENT_NETPROPS(X);
	#undef X
		return true;
	}

	NET_HANDLE(ENT_CLIENT_WEPENT, bool isnew)
	{
		return ReadWepent(this);
	}

	NET_HANDLE(CLIENT_WEPENT, bool isnew)
	{
		return ReadWepent(NULL);
	}

#endif
