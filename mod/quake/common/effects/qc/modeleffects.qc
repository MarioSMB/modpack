#include "modeleffects.qh"

REGISTER_NET_LINKED(ENT_CLIENT_MODELEFFECT)

#ifdef SVQC

.float scale2;

bool modeleffect_SendEntity(entity this, entity to, int sf)
{
	float f;
	WriteHeader(MSG_ENTITY, ENT_CLIENT_MODELEFFECT);

	f = 0;
	if(this.velocity != '0 0 0')
		f |= 1;
	if(this.angles != '0 0 0')
		f |= 2;
	if(this.avelocity != '0 0 0')
		f |= 4;

	WriteByte(MSG_ENTITY, f);
	WriteShort(MSG_ENTITY, this.modelindex);
	WriteByte(MSG_ENTITY, this.skin);
	WriteByte(MSG_ENTITY, this.frame);
	WriteVector(MSG_ENTITY, this.origin);
	if(f & 1)
	{
		WriteVector(MSG_ENTITY, this.velocity);
	}
	if(f & 2)
	{
		WriteAngleVector(MSG_ENTITY, this.angles);
	}
	if(f & 4)
	{
		WriteAngleVector(MSG_ENTITY, this.avelocity);
	}
	WriteShort(MSG_ENTITY, this.scale * 256.0);
	WriteShort(MSG_ENTITY, this.scale2 * 256.0);
	WriteByte(MSG_ENTITY, this.teleport_time * 100.0);
	WriteByte(MSG_ENTITY, this.fade_time * 100.0);
	WriteByte(MSG_ENTITY, this.alpha * 255.0);

	return true;
}

void modeleffect_spawn(string m, float s, float f, vector o, vector v, vector ang, vector angv, float s0, float s2, float a, float t1, float t2)
{
	entity e = new(modeleffect);
	_setmodel(e, m);
	e.frame = f;
	setorigin(e, o);
	e.velocity = v;
	e.angles = ang;
	e.avelocity = angv;
	e.alpha = a;
	e.teleport_time = t1;
	e.fade_time = t2;
	e.skin = s;
	if(s0 >= 0)
		e.scale = s0 / max6(-e.mins.x, -e.mins.y, -e.mins.z, e.maxs.x, e.maxs.y, e.maxs.z);
	else
		e.scale = -s0;
	if(s2 >= 0)
		e.scale2 = s2 / max6(-e.mins.x, -e.mins.y, -e.mins.z, e.maxs.x, e.maxs.y, e.maxs.z);
	else
		e.scale2 = -s2;
	float sz = max(e.scale, e.scale2);
	setsize(e, e.mins * sz, e.maxs * sz);
	Net_LinkEntity(e, false, 0.1, modeleffect_SendEntity);
}

#endif

#ifdef CSQC

entityclass(ModelEffect);
classfield(ModelEffect) .float frame1time;
classfield(ModelEffect) .float lifetime, fadetime;
classfield(ModelEffect) .float teleport_time;
classfield(ModelEffect) .float scale1, scale2;

.float cnt;
.float scale;
.float alpha;

void ModelEffect_Draw(entity this)
{
	this.angles = this.angles + frametime * this.avelocity;
	setorigin(this, this.origin + frametime * this.velocity);
	this.scale = this.scale1 + (this.scale2 - this.scale1) * (time - this.teleport_time) / (this.lifetime + this.fadetime - this.teleport_time);
	this.alpha = this.cnt * bound(0, 1 - (time - this.lifetime) / this.fadetime, 1);
	if(this.alpha < 0.003)
	{
		delete(this);
		return;
	}
	this.drawmask = MASK_NORMAL;
	if(this.scale <= 0)
	{
		this.drawmask = 0;
		return;
	}
}

NET_HANDLE(ENT_CLIENT_MODELEFFECT, bool isnew)
{
	make_pure(this);

	int f = ReadByte();

	entity e = new(modeleffect);
	e.model = "from network";
	e.modelindex = ReadShort();
	e.skin = ReadByte();
	e.frame = ReadByte();
	e.frame1time = time;
	e.origin = ReadVector();
	setorigin(e, e.origin);
	if(f & 1)
	{
		e.velocity = ReadVector();
	}
	if(f & 2)
	{
		e.angles = ReadAngleVector();
	}
	if(f & 4)
	{
		e.avelocity = ReadAngleVector();
	}
	e.scale1 = ReadShort() / 256.0;
	e.scale2 = ReadShort() / 256.0;
	e.lifetime = time + ReadByte() * 0.01;
	e.fadetime = ReadByte() * 0.01;
	e.teleport_time = time;
	e.cnt = ReadByte() / 255.0; // actually alpha

	e.draw = ModelEffect_Draw;
	if (isnew) IL_PUSH(g_drawables, e);

	if (!isnew) delete(e); // yes, this IS stupid, but I don't need to duplicate all the read* stuff then
	return true;
}
#endif
