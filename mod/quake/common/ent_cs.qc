#include "ent_cs.qh"

REGISTRY(EntCSProps, BITS(16) - 1)
REGISTER_REGISTRY(EntCSProps)
REGISTRY_SORT(EntCSProps)
REGISTRY_CHECK(EntCSProps)

REGISTRY_DEFINE_GET(EntCSProps, NULL)
STATIC_INIT(EntCSProps_renumber) { FOREACH(EntCSProps, true, it.m_id = i); }

// these entcs_props ids need to be referenced directly
int ENTCS_PROP_ENTNUM_id = 0;
int ENTCS_PROP_ORIGIN_id = 0;
int ENTCS_PROP_HEALTH_id = 0;
STATIC_INIT(EntCSProps_setglobalids)
{
	FOREACH(EntCSProps, true, {
		if (it.registered_id == "ENTCS_PROP_ENTNUM") ENTCS_PROP_ENTNUM_id = it.m_id;
		if (it.registered_id == "ENTCS_PROP_ORIGIN") ENTCS_PROP_ORIGIN_id = it.m_id;
		if (it.registered_id == "ENTCS_PROP_HEALTH") ENTCS_PROP_HEALTH_id = it.m_id;
	});
}

#ifdef SVQC
// Force an origin update, for player sounds
void entcs_force_origin(entity player)
{
	player.entcs.m_forceupdate = BIT(ENTCS_PROP_ORIGIN_id);
}
#endif

.bool m_public;
.bool(entity ent, entity player) m_check;
.void(entity ent, entity player) m_set;
.void(int chan, entity ent) m_send;
.void(entity ent) m_receive;

#ifdef SVQC
#define _ENTCS_PROP(id, ispublic, checkprop, checkprop_pl, setprop, svsend, clreceive) \
	void id##_set(entity ent, entity player) { setprop(ent.(checkprop), player.(checkprop_pl)); } \
	void id##_send(int chan, entity ent) { LAMBDA(svsend); } \
	REGISTER(EntCSProps, ENTCS_PROP, id, m_id, new_pure(entcs_prop)) { \
		this.m_public = ispublic; \
		this.m_check = id##_check; \
		this.m_set = id##_set; \
		this.m_send = id##_send; \
	}

#define ENTCS_PROP(id, ispublic, checkprop, checkprop_pl, setprop, svsend, clreceive) \
	bool id##_check(entity ent, entity player) { return (ent.(checkprop) != player.(checkprop_pl)); } \
	_ENTCS_PROP(id, ispublic, checkprop, checkprop_pl, setprop, svsend, clreceive)

#define ENTCS_PROP_CODED(id, ispublic, checkprop, checkprop_pl, setprop, decfactor, svsend, clreceive) \
	bool id##_check(entity ent, entity player) { \
		return (floor(ent.(checkprop)) / decfactor != floor(player.(checkprop_pl)) / decfactor); \
	} \
	_ENTCS_PROP(id, ispublic, checkprop, checkprop_pl, setprop, svsend, clreceive)

#elif defined(CSQC)
#define ENTCS_PROP(id, ispublic, checkprop, checkprop_pl, setprop, svsend, clreceive) \
	void id##_receive(entity ent) { LAMBDA(clreceive); } \
	REGISTER(EntCSProps, ENTCS_PROP, id, m_id, new_pure(entcs_prop)) { \
		this.m_public = ispublic; \
		this.m_receive = id##_receive; \
	}

#define ENTCS_PROP_CODED(id, ispublic, checkprop, checkprop_pl, setprop, decfactor, svsend, clreceive) \
	ENTCS_PROP(id, ispublic, checkprop, checkprop_pl, setprop, svsend, clreceive)
#endif

#define ENTCS_SET_NORMAL(var, x) MACRO_BEGIN \
	var = x; \
MACRO_END

/** the engine player name strings are mutable! */
#define ENTCS_SET_MUTABLE_STRING(var, x) MACRO_BEGIN \
	strcpy(var, x); \
MACRO_END

#ifdef SVQC
.int sv_entnum;
#endif
ENTCS_PROP(ENTNUM, false, sv_entnum, sv_entnum, ENTCS_SET_NORMAL, {}, {}) /* sentinel */

ENTCS_PROP(ORIGIN, false, origin, origin, ENTCS_SET_NORMAL,
	{ WriteVector(chan, ent.origin); },
	{ ent.has_sv_origin = true; vector v = ReadVector(); setorigin(ent, v); })

#define DEC_FACTOR (360 / 64)
ENTCS_PROP_CODED(ANGLES, false, angles_y, angles_y, ENTCS_SET_NORMAL, DEC_FACTOR,
	{ WriteByte(chan, ent.angles.y / DEC_FACTOR); },
	{ vector v = '0 0 0'; v.y = ReadByte() * DEC_FACTOR; ent.angles = v; })
#undef DEC_FACTOR

// FIXME: use a better scale?
.float healthvalue;
#define DEC_FACTOR 10
ENTCS_PROP_CODED(HEALTH, false, health, health, ENTCS_SET_NORMAL, DEC_FACTOR,
	{ WriteByte(chan, bound(0, ent.health / DEC_FACTOR, 255)); },
	{ ent.healthvalue = ReadByte() * DEC_FACTOR; })

.float armorvalue;
ENTCS_PROP_CODED(ARMOR, false, armorvalue, armorvalue, ENTCS_SET_NORMAL, DEC_FACTOR,
	{ WriteByte(chan, bound(0, ent.armorvalue / DEC_FACTOR, 255)); },
	{ ent.armorvalue = ReadByte() * DEC_FACTOR; })
#undef DEC_FACTOR

ENTCS_PROP(NAME, true, netname, netname, ENTCS_SET_MUTABLE_STRING,
	{ WriteString(chan, ent.netname); },
	{ strcpy(ent.netname, ReadString()); })

ENTCS_PROP(MODEL, true, model, model, ENTCS_SET_NORMAL,
	{ WriteString(chan, ent.model); },
	{ strcpy(ent.model, ReadString()); })

ENTCS_PROP(SKIN, true, skin, skin, ENTCS_SET_NORMAL,
	{ WriteByte(chan, ent.skin); },
	{ ent.skin = ReadByte(); })

ENTCS_PROP(CLIENTCOLORS, true, clientcolors, clientcolors, ENTCS_SET_NORMAL,
	{ WriteByte(chan, ent.clientcolors); },
	{ ent.colormap = ReadByte(); })

.int frags;
ENTCS_PROP(FRAGS, true, frags, frags, ENTCS_SET_NORMAL,
	{ WriteShort(chan, ent.frags); },
	{ ent.frags = ReadShort(); })

// use sv_solid to avoid changing solidity state of entcs entities
ENTCS_PROP(SOLID, true, sv_solid, solid, ENTCS_SET_NORMAL,
	{ WriteByte(chan, ent.sv_solid); },
	{ ent.sv_solid = ReadByte(); })

#ifdef SVQC

	int ENTCS_PUBLICMASK = 0, ENTCS_PRIVATEMASK = 0;
	STATIC_INIT(ENTCS_PUBLICMASK)
	{
		FOREACH(EntCSProps, true,
		{
			if (it.m_public)
				ENTCS_PUBLICMASK |= BIT(it.m_id);
			else
				ENTCS_PRIVATEMASK |= BIT(it.m_id);
		});
	}

	void entcs_update_players(entity player)
	{
		FOREACH_CLIENT(it != player && IS_PLAYER(it),
		{
			it.entcs.SendFlags |= ENTCS_PRIVATEMASK;
		});
	}

	bool _entcs_send(entity this, entity to, int sf, int chan)
	{
		entity player = this.owner;
		sf |= BIT(ENTCS_PROP_ENTNUM_id); // assume private
		do {
			if (IS_PLAYER(player))
			{
				if (IS_PLAYER(to)) break;
			}
			sf &= ENTCS_PUBLICMASK; // no private updates
		} while (0);

		sf |= this.m_forceupdate;
		this.m_forceupdate = 0;
		if (chan == MSG_ENTITY)
			WriteHeader(chan, ENT_CLIENT_ENTCS);
		else
			WriteHeader(chan, CLIENT_ENTCS);
		WriteByte(chan, etof(player) - 1);
		WriteShort(chan, sf);
		FOREACH(EntCSProps, sf & BIT(it.m_id),
		{
			it.m_send(chan, this);
		});
		return true;
	}

	bool entcs_send(entity this, entity to, int sf)
	{
		return _entcs_send(this, to, sf, MSG_ENTITY);
	}

	void entcs_think(entity this)
	{
		this.nextthink = time + 0.033333333333;  // TODO: increase this to like 0.15 once the client can do smoothing
		entity player = this.owner;
		FOREACH(EntCSProps, it.m_check(this, player),
		{
			it.m_set(this, player);
			this.SendFlags |= BIT(it.m_id);
		});

		if (intermission_running)
		{
			// health is set to special values after the game ends, ignore any change
			this.SendFlags &= ~BIT(ENTCS_PROP_HEALTH_id);
		}

		// always send origin of players even if they stand still otherwise
		// if a teammate isn't in my pvs and their health (or view angle or name
		// etc...) changes then their tag disappears
		if (IS_PLAYER(this.owner))
			this.SendFlags |= BIT(ENTCS_PROP_ORIGIN_id);

		// not needed, origin is just data to be sent
		//setorigin(this, this.origin); // relink
	}

	void entcs_attach(entity player)
	{
		entity e = player.entcs = new_pure(entcs_sender);
		e.owner = player;
		setthink(e, entcs_think);
		e.nextthink = time;
		Net_LinkEntity(e, false, 0, entcs_send);
		// NOTE: the following code block has been disabled as a workaround for https://gitlab.com/xonotic/xonotic-data.pk3dir/-/issues/1824
#if 0
		if (!IS_REAL_CLIENT(player)) return;
		FOREACH_CLIENT(true, {
			assert(it.entcs);
			_entcs_send(it.entcs, msg_entity = player, BITS(23), MSG_ONE);
		});
#endif
	}

	void entcs_detach(entity player)
	{
		if (!player.entcs) return;
		delete(player.entcs);
		player.entcs = NULL;
	}

#endif

#ifdef CSQC

	void Ent_RemoveEntCS(entity this)
	{
		int n = this.sv_entnum;
		entity e = entcs_receiver(n);
		entcs_receiver(n, NULL);
		strfree(e.netname);
		strfree(e.model);
		if (e != this) delete(e);
	}

	void entcs_think(entity this)
	{
		entity e = CSQCModel_server2csqc(this.sv_entnum);
		if (e == NULL)
		{
			// player model is NOT in client's PVS
			InterpolateOrigin_Do(this);
			this.has_origin = this.has_sv_origin;
			return;
		}
		this.has_origin = true;
		// when a player model is in client's PVS we use its origin directly
		// (entcs networked origin is overriden)
		this.origin = e.origin;
		InterpolateOrigin_Reset(this);
		setorigin(this, this.origin);
		// `cl_forceplayermodels 1` sounds will be wrong until the player has been in the PVS, but so be it
		if (this.model != e.model)
		{
			strcpy(this.model, e.model);
		}
	}

	bool ReadEntcs(entity this)
	{
		int n = ReadByte();
		entity e = entcs_receiver(n);
		if (e == NULL)
		{
			if (!this)
				// initial = temp
				e = new_pure(ENT_CLIENT_ENTCS);
			else
				// initial = linked
				e = this;
			setthink(e, entcs_think);
			entcs_receiver(n, e);
		}
		else if (e != this && this)
		{
			// upgrade to linked
			delete(e);
			e = this;
			setthink(e, entcs_think);
			entcs_receiver(n, e);
		}

		InterpolateOrigin_Undo(e);
		e.sv_entnum = n;
		int sf = ReadShort();
		e.has_sv_origin = false;
		e.m_entcs_private = boolean(sf & BIT(ENTCS_PROP_ENTNUM_id));
		FOREACH(EntCSProps, sf & BIT(it.m_id),
		{
			it.m_receive(e);
		});
		e.iflags |= IFLAG_ORIGIN;
		InterpolateOrigin_Note(e);
		getthink(e)(e);
		return true;
	}

	NET_HANDLE(ENT_CLIENT_ENTCS, bool isnew)
	{
		if (isnew)
		{
			make_pure(this);
			this.entremove = Ent_RemoveEntCS;
		}
		return ReadEntcs(this);
	}

	NET_HANDLE(CLIENT_ENTCS, bool isnew)
	{
		return ReadEntcs(NULL);
	}

#endif
