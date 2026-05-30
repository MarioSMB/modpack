#include "cl_td.qh"

#include "td.qh"

void td_UpdateView(entity this)
{
	// always reset at the first draw call, so we don't get lingering data
	buildtool_targ = NULL;

	if(!td_ent || !STAT(TD_BUILDMODE) || STAT(TD_PHASE) == TD_PHASE_WIN || intermission || STAT(HEALTH) < 1)
		return;
	
	buildtool_frame(this);
}

void HUD_TD(entity this)
{
	if(!td_ent || !STAT(TD_BUILDMODE) || STAT(TD_PHASE) == TD_PHASE_WIN || intermission || STAT(HEALTH) < 1)
		return;

	buildtool_draw2d(this);
}

.int worldtype; // TODO?
.float td_chest_frametick;
void td_chest_draw(entity this)
{
	if(time > this.td_chest_frametick)
	{
		if((this.state && this.frame < 2) || (!this.state && this.frame > 0))
		{
			CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
			int dir = (this.state) ? 1 : -1;
			if(this.state && this.frame == 0 && this.noise && this.noise != "")
				_sound(this, CH_TRIGGER_SINGLE, this.noise, VOL_BASE, ATTEN_NORM);
			this.frame += dir;
			CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
		}

		this.td_chest_frametick = time + 0.1; // roughly match quake animations
	}

	CSQCModel_InterpolateAnimation_Do(this);
}

void td_chest_remove(entity this)
{
	strfree(this.mdl);
	strfree(this.noise);
}

NET_HANDLE(ENT_CLIENT_TD_CHEST, bool isnew)
{
	this.origin = ReadVector();
	setorigin(this, this.origin);
	float ang = ReadAngle();
	this.angles = '0 1 0' * ang;
	int sf = ReadByte();
	this.worldtype = ReadByte();

	if(sf & SF_TD_CHEST_MDL)
		strcpy(this.mdl, ReadString());

	if(sf & SF_TD_CHEST_NOISE)
		strcpy(this.noise, ReadString());

	this.classname = "td_chest"; // for identification

	this.state = (sf & SF_TD_CHEST_OPEN);

	this.effects = EF_FULLBRIGHT;
	this.solid = SOLID_BBOX;
	string fallbackmdl = string_null;
	string fallbacknoise = string_null;
	switch(this.worldtype)
	{
		default:
		case WORLDTYPE_MEDIEVAL: fallbackmdl = "progs/td_chest_medieval.mdl"; fallbacknoise = "td/chest_medieval_open.wav"; break;
		case WORLDTYPE_METAL: fallbackmdl = "progs/td_chest_metal.mdl"; fallbacknoise = "td/chest_metal_open.wav"; break;
		case WORLDTYPE_BASE: fallbackmdl = "progs/td_chest_base.mdl"; fallbacknoise = "misc/menu2.wav"; break;
	}
	if(!this.mdl && fallbackmdl)
		strcpy(this.mdl, fallbackmdl);
	if(!this.noise && fallbacknoise)
		strcpy(this.noise, fallbacknoise);

	precache_sound(this.noise);
	precache_model(this.mdl);
	_setmodel(this, this.mdl);
	setsize(this, '-24 -24 0', '24 24 32');

	set_movetype(this, MOVETYPE_NONE);
	//this.td_chest_frametick = 0;
	if(isnew)
	{
		this.frame = 0;
		CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
		CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
		this.lerpfrac = 0; // reset frames
	}

	this.entremove = td_chest_remove;
	this.draw = td_chest_draw;
	if(isnew && !IL_CONTAINS(g_drawables, this))
		IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	return = true;
}

void td_tower_remove(entity this)
{
	strfree(this.mdl);
}

NET_HANDLE(ENT_CLIENT_TD_TOWER, bool isnew)
{
	this.origin = ReadVector();
	setorigin(this, this.origin);
	float ang = ReadAngle();
	this.angles = '0 1 0' * ang;
	int sf = ReadByte();
	this.worldtype = ReadByte();

	if(sf & SF_TD_TOWER_MDL)
		strcpy(this.mdl, ReadString());

	this.classname = "td_tower"; // for identification

	this.solid = SOLID_BBOX;
	string fallbackmdl = string_null;
	switch(this.worldtype)
	{
		case WORLDTYPE_MEDIEVAL: fallbackmdl = "progs/chaosorb.mdl"; break;
		default:
		case WORLDTYPE_METAL: fallbackmdl = "progs/floyd.mdl"; break;
		case WORLDTYPE_BASE: fallbackmdl = "progs/reactor.mdl"; break;
	}
	if(!this.mdl && fallbackmdl)
		strcpy(this.mdl, fallbackmdl);

	precache_model(this.mdl);
	_setmodel(this, this.mdl);
	setsize(this, '-32 -32 -24', '32 32 64');

	set_movetype(this, MOVETYPE_NONE);

	this.entremove = td_tower_remove;
	this.drawmask = MASK_NORMAL;

	return = true;
}

NET_HANDLE(ENT_CLIENT_TD_SPAWNPOINT, bool isnew)
{
	this.origin = ReadVector();
	setorigin(this, this.origin);

	this.classname = "td_spawnpoint"; // for identification
	this.solid = SOLID_TRIGGER;
	setsize(this, '-150 -150 -150', '150 150 150');
	set_movetype(this, MOVETYPE_NONE);

	return = true;
}

void TDMusic_Advance()
{
	if(!td_ent)
		return;
	if(!td_ent.active)
		return; // easy check for music activation
	if(STAT(TD_PHASE) != TD_PHASE_COMBAT)
		return;

	music_trigger = td_ent;
}

void td_ent_remove(entity this)
{
	if(td_ent == this)
		td_ent = NULL;

	strfree(this.noise);
}

NET_HANDLE(ENT_CLIENT_TD_ENT, bool isnew)
{
	int sf = ReadByte();

	if(sf & SF_TD_ENT_COUNTS)
	{
		this.wave = ReadByte();
		this.tur_units = ReadShort();
	}

	if(sf & SF_TD_ENT_LIMITS)
	{
		this.count = ReadByte();
		this.currentammo = ReadShort();
	}

	if(sf & SF_TD_ENT_MUSIC)
	{
		string s = engine_fixsound(ReadString());
		if(fexists(s))
		{
			precache_sound(s);
			strcpy(this.noise, s);
			this.volume = 1;
			this.fade_time = 1;
			this.fade_rate = 1;
			this.active = ACTIVE_ACTIVE;

			IL_PUSH(TargetMusic_list, this);
		}
	}

	td_ent = this;

	return = true;
}

PRECACHE(Fuel)
{
	precache_model("progs/td_fuel_1.mdl");
	precache_model("progs/td_fuel_2.mdl");
	precache_model("progs/td_fuel_3.mdl");
	precache_model("progs/td_fuel_4.mdl");
	precache_model("progs/td_fuel_5.mdl");
	precache_model("progs/s_sun.spr");
}

void td_fuel_remove(entity this)
{
	//__pointparticles(_particleeffectnum("TE_WIZSPIKE"), this.origin + ((this.mins + this.maxs) * 0.5), '0 0 0', 1);
	pointparticles(EFFECT_TE_FUEL, this.origin + ((this.mins + this.maxs) * 0.5), '0 0 0', 1);
}

void td_fuel_draw(entity this)
{
	Movetype_Physics_NoMatchTicrate(this, frametime, true);

	int mytype = (this.cnt) ? this.cnt : 1;
	float spin = -120 / mytype;

	this.angles += vec3(0, spin, 0) * frametime; // MOVETYPE_TOSS does this while it's moving
}

NET_HANDLE(ENT_CLIENT_TD_FUEL, bool isnew)
{
	int sf = ReadByte();

	if(sf & SF_TD_FUEL_TYPE)
	{
		this.cnt = ReadByte();
		this.solid = SOLID_TRIGGER;
		this.effects = EF_FULLBRIGHT;
		this.flags = FL_ITEM;
		//this.avelocity = '0 -90 0';
		this.gravity = 1;
		set_movetype(this, MOVETYPE_TOSS);
		this.drawmask = MASK_NORMAL;
		if(!IL_CONTAINS(g_drawables, this))
			IL_PUSH(g_drawables, this);
		this.draw = td_fuel_draw;
		this.entremove = td_fuel_remove;
		switch(this.cnt)
		{
			default:
			case TD_FUEL_TINY: _setmodel(this, "progs/td_fuel_1.mdl"); break;
			case TD_FUEL_SMALL: _setmodel(this, "progs/td_fuel_2.mdl"); break;
			case TD_FUEL_MEDIUM: _setmodel(this, "progs/td_fuel_3.mdl"); break;
			case TD_FUEL_LARGE: _setmodel(this, "progs/td_fuel_4.mdl"); break;
			case TD_FUEL_MEGA: _setmodel(this, "progs/td_fuel_5.mdl"); break;
			case TD_FUEL_SUN: _setmodel(this, "progs/s_sun.spr"); break;
		}
		if(this.cnt == TD_FUEL_SUN)
			setsize(this, '-16 -16 -16', '16 16 16');
		else
			setsize(this, '-16 -16 -8', '16 16 24');
	}

	if(sf & SF_TD_FUEL_ORIGIN)
	{
		vector org = ReadVector();
		setorigin(this, org);
	}

	if(sf & SF_TD_FUEL_VELOCITY)
	{
		this.velocity = ReadVector();
	}

	return = true;
}

void td_rankings_remove(entity this)
{
	if(td_rankings == this)
		td_rankings = NULL;

	strfree(this.netname);
}

NET_HANDLE(ENT_CLIENT_TD_RANKINGS, bool isnew)
{
	int sf = ReadByte();

	if(sf & TD_RANKINGS_KILLED)
	{
		this.cnt = ReadInt24_t();
	}

	if(sf & TD_RANKINGS_MVP)
	{
		this.scale = ReadFloat();
		string mvp = ReadString();
		strcpy(this.netname, mvp);

		// show their scores too!
		// TODO: clean up this mess...
		int mvpsf = ReadByte();

		this.score_playerkills = (mvpsf & BIT(0)) ? ReadInt24_t() : 0;
		this.score_turretkills = (mvpsf & BIT(1)) ? ReadInt24_t() : 0;
		this.score_repaired = (mvpsf & BIT(2)) ? ReadFloat() : 0;
		this.score_upgrades = (mvpsf & BIT(3)) ? ReadShort() : 0;
		this.score_bosskilled = (mvpsf & BIT(4)) ? true : false;
	}

	if(sf & TD_RANKINGS_TIME)
	{
		this.wait = TIME_DECODE(ReadInt24_t());
	}

	if(sf & TD_RANKINGS_TOPSCORE)
	{
		this.lip = ReadFloat();
		string bestmvp = ReadString();
		strcpy(this.mdl, bestmvp);
	}

	td_rankings = this;

	return = true;
}
