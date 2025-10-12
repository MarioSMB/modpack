#include "pointparticles.qh"
REGISTER_NET_LINKED(ENT_CLIENT_POINTPARTICLES)

#ifdef SVQC
// NOTE: also contains func_sparks

bool pointparticles_SendEntity(entity this, entity to, float sendflags)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_POINTPARTICLES);

	// optional features to save space
	sendflags = sendflags & 0x0F;
	if(this.spawnflags & PARTICLES_IMPULSE)
		sendflags |= SF_POINTPARTICLES_IMPULSE; // absolute count on toggle-on
	if(this.movedir != '0 0 0' || this.velocity != '0 0 0')
		sendflags |= SF_POINTPARTICLES_MOVING; // 4 bytes - saves CPU
	if(this.waterlevel || this.count != 1)
		sendflags |= SF_POINTPARTICLES_JITTER_AND_COUNT; // 4 bytes - obscure features almost never used
	if(this.mins != '0 0 0' || this.maxs != '0 0 0')
		sendflags |= SF_POINTPARTICLES_BOUNDS; // 14 bytes - saves lots of space

	WriteByte(MSG_ENTITY, sendflags);
	if(sendflags & SF_TRIGGER_UPDATE)
	{
		if(this.active == ACTIVE_ACTIVE)
			WriteCoord(MSG_ENTITY, this.impulse);
		else
			WriteCoord(MSG_ENTITY, 0); // off
	}
	if(sendflags & SF_TRIGGER_RESET)
	{
		WriteVector(MSG_ENTITY, this.origin);
	}
	if(sendflags & SF_TRIGGER_INIT)
	{
		if(this.model != "null")
		{
			WriteShort(MSG_ENTITY, this.modelindex);
			if(sendflags & SF_POINTPARTICLES_BOUNDS)
			{
				WriteVector(MSG_ENTITY, this.mins);
				WriteVector(MSG_ENTITY, this.maxs);
			}
		}
		else
		{
			WriteShort(MSG_ENTITY, 0);
			if(sendflags & SF_POINTPARTICLES_BOUNDS)
			{
				WriteVector(MSG_ENTITY, this.maxs);
			}
		}
		WriteShort(MSG_ENTITY, this.cnt);
		WriteString(MSG_ENTITY, this.mdl);
		if(sendflags & SF_POINTPARTICLES_MOVING)
		{
			WriteShort(MSG_ENTITY, compressShortVector(this.velocity));
			WriteShort(MSG_ENTITY, compressShortVector(this.movedir));
		}
		if(sendflags & SF_POINTPARTICLES_JITTER_AND_COUNT)
		{
			WriteShort(MSG_ENTITY, this.waterlevel * 16.0);
			WriteByte(MSG_ENTITY, this.count * 16.0);
		}
		WriteString(MSG_ENTITY, this.noise);
		if(this.noise != "")
		{
			WriteByte(MSG_ENTITY, floor(this.atten * 64));
			WriteByte(MSG_ENTITY, floor(this.volume * 255));
		}
	}
	return 1;
}

void pointparticles_think(entity this)
{
	if(this.origin != this.oldorigin)
	{
		this.SendFlags |= SF_TRIGGER_RESET;
		this.oldorigin = this.origin;
	}
	this.nextthink = time;
}

spawnfunc(func_pointparticles)
{
	if(this.model != "") { precache_model(this.model); _setmodel(this, this.model); }
	if(this.noise != "") precache_sound(this.noise);
	if(this.mdl != "") this.cnt = 0; // use a good handler

	if(!this.atten) this.atten = ATTEN_NORM;
	else if(this.atten < 0) this.atten = 0;
	if(!this.volume) this.volume = 1;
	if(!this.count) this.count = 1;
	if(!this.impulse) this.impulse = 1;

	if(!this.modelindex)
	{
		setorigin(this, this.origin + this.mins);
		setsize(this, '0 0 0', this.maxs - this.mins);
	}
	//if(!this.cnt) this.cnt = _particleeffectnum(this.mdl);
	//this.setactive = generic_netlinked_setactive;

	Net_LinkEntity(this, (this.spawnflags & PARTICLES_VISCULLING), 0, pointparticles_SendEntity);

	if(this.targetname && this.targetname != "")
	{
		// backwards compatibility
		this.use = generic_netlinked_legacy_use;
	}
	generic_netlinked_reset(this);
	setthink(this, pointparticles_think);
	this.nextthink = time;
}

spawnfunc(func_sparks)
{
	if(this.count < 1) {
		this.count = 25.0; // nice default value
	}

	if(this.impulse < 0.5) {
		this.impulse = 2.5; // nice default value
	}

	this.mins = '0 0 0';
	this.maxs = '0 0 0';
	this.velocity = '0 0 -1';
	this.mdl = "TE_SPARK";
	this.cnt = 0; // use mdl

	spawnfunc_func_pointparticles(this);
}
#elif defined(CSQC)

.int dphitcontentsmask;

entityclass(PointParticles);
classfield(PointParticles) .int cnt; // effect number
classfield(PointParticles) .vector velocity; // particle velocity
classfield(PointParticles) .float waterlevel; // direction jitter
classfield(PointParticles) .int count; // count multiplier
classfield(PointParticles) .int impulse; // density
classfield(PointParticles) .string noise; // sound
classfield(PointParticles) .float atten;
classfield(PointParticles) .float volume;
classfield(PointParticles) .float absolute; // 1 = count per second is absolute, ABSOLUTE_ONLY_SPAWN_AT_TOGGLE = only spawn at toggle
classfield(PointParticles) .vector movedir; // trace direction
classfield(PointParticles) .float glow_color; // palette index

const int ABSOLUTE_ONLY_SPAWN_AT_TOGGLE = 2;

.bool just_toggled; // we don't have bgmscript

void Draw_PointParticles(entity this)
{
	float n = 1, i, fail;
	vector p;
	vector sz;
	vector o;
	o = this.origin;
	sz = this.maxs - this.mins;
	if(this.absolute == ABSOLUTE_ONLY_SPAWN_AT_TOGGLE)
	{
		if(n >= 0)
			n = this.just_toggled ? this.impulse : 0;
		else
			n = this.impulse * drawframetime;
	}
	else
	{
		n *= this.impulse * drawframetime;
		if(this.just_toggled)
			if(n < 1)
				n = 1;
	}
	if(n == 0)
		return;
	fail = 0;
	for(i = random(); i <= n && fail <= 64*n; ++i)
	{
		p = o + this.mins;
		p.x += random() * sz.x;
		p.y += random() * sz.y;
		p.z += random() * sz.z;
		//if(boxesoverlap(p, p, this.absmin, this.absmax))
		{
			if(this.movedir != '0 0 0')
			{
				traceline(p, p + normalize(this.movedir) * 4096, 0, NULL);
				p = trace_endpos;
				int eff_num;
				if(this.cnt)
					eff_num = this.cnt;
				else
					eff_num = _particleeffectnum(this.mdl);
				__pointparticles(eff_num, p, trace_plane_normal * vlen(this.movedir) + this.velocity + randomvec() * this.waterlevel, this.count);
			}
			else
			{
				int eff_num;
				if(this.cnt)
					eff_num = this.cnt;
				else
					eff_num = _particleeffectnum(this.mdl);
				__pointparticles(eff_num, p, this.velocity + randomvec() * this.waterlevel, this.count);
			}
			if(this.noise != "")
			{
				setorigin(this, p);
				_sound(this, CH_AMBIENT, this.noise, VOL_BASE * this.volume, this.atten);
			}
			this.just_toggled = 0;
		}
		//else if(this.absolute)
		//{
			//++fail;
			//--i;
		//}
	}
	setorigin(this, o);
}

void Ent_PointParticles_Remove(entity this)
{
    strfree(this.noise);
    strfree(this.mdl);
}

NET_HANDLE(ENT_CLIENT_POINTPARTICLES, bool isnew)
{
	float i;
	vector v;
	int sendflags = ReadByte();
	if(sendflags & SF_TRIGGER_UPDATE)
	{
		i = ReadCoord(); // density (<0: point, >0: volume)
		if(i && !this.impulse && (this.cnt || this.mdl)) // this.cnt check is so it only happens if the ent already existed
			this.just_toggled = 1;
		this.impulse = i;
	}
	if(sendflags & SF_TRIGGER_RESET)
	{
		this.origin = ReadVector();
	}
	if(sendflags & SF_TRIGGER_INIT)
	{
		this.modelindex = ReadShort();
		if(sendflags & SF_POINTPARTICLES_BOUNDS)
		{
			if(this.modelindex)
			{
				this.mins = ReadVector();
				this.maxs = ReadVector();
			}
			else
			{
				this.mins    = '0 0 0';
				this.maxs = ReadVector();
			}
		}
		else
		{
			this.mins = this.maxs = '0 0 0';
		}

		this.cnt = ReadShort(); // effect number
		this.mdl = strzone(ReadString()); // effect string

		if(sendflags & SF_POINTPARTICLES_MOVING)
		{
			this.velocity = decompressShortVector(ReadShort());
			this.movedir = decompressShortVector(ReadShort());
		}
		else
		{
			this.velocity = this.movedir = '0 0 0';
		}
		if(sendflags & SF_POINTPARTICLES_JITTER_AND_COUNT)
		{
			this.waterlevel = ReadShort() / 16.0;
			this.count = ReadByte() / 16.0;
		}
		else
		{
			this.waterlevel = 0;
			this.count = 1;
		}
		strcpy(this.noise, ReadString());
		if(this.noise != "")
		{
			this.atten = ReadByte() / 64.0;
			this.volume = ReadByte() / 255.0;
		}
	}

	return = true;

	if(sendflags & SF_TRIGGER_UPDATE)
	{
		this.absolute = (this.impulse >= 0);
		if(!this.absolute)
		{
			v = this.maxs - this.mins;
			this.impulse *= -v.x * v.y * v.z / (64**3); // relative: particles per 64^3 cube
		}
	}

	if(sendflags & SF_POINTPARTICLES_IMPULSE)
		this.absolute = ABSOLUTE_ONLY_SPAWN_AT_TOGGLE;

	setorigin(this, this.origin);
	setsize(this, this.mins, this.maxs);
	this.solid = SOLID_NOT;
	this.draw = Draw_PointParticles;
	if (isnew) IL_PUSH(g_drawables, this);
	this.entremove = Ent_PointParticles_Remove;
}
#endif
