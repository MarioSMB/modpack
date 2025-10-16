#include "tether.qh"

#ifdef SVQC
bool tether_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TETHER);
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
	{
		WriteByte(MSG_ENTITY, this.cnt);
		WriteByte(MSG_ENTITY, this.count);
	}
	if(sf & 2)
	{
		WriteVector(MSG_ENTITY, this.tether_start);
	}
	if(sf & 4)
	{
		WriteVector(MSG_ENTITY, this.tether_end);
	}
	return true;
}

void tether_remove(entity this)
{
	if(this.enemy.tether_ent == this)
		this.enemy.tether_ent = NULL;
	if(this.goalentity.tether_ent == this)
		this.goalentity.tether_ent = NULL;
	delete(this);
}

void tether_think(entity this)
{
	if(!this.enemy || this.enemy.tether_ent != this || this.enemy.health <= 0 || !this.goalentity || this.goalentity.tether_ent != this || this.goalentity.health <= 0)
	{
		tether_remove(this);
		return;
	}

	this.nextthink = time;

	if(this.enemy.origin != this.tether_start)
	{
		this.SendFlags |= 2;
		this.tether_start = this.enemy.origin;
	}
	if(this.goalentity.origin != this.tether_end)
	{
		this.SendFlags |= 4;
		this.tether_end = this.goalentity.origin;
	}
}

void tether_setup(entity from, entity to, int tethertype, int tetherwidth)
{
	entity tether = new_pure(tether);

	tether.enemy = from;
	tether.goalentity = to;
	tether.cnt = tethertype;
	tether.count = tetherwidth;
	setthink(tether, tether_think);
	tether.nextthink = time;
	from.tether_ent = tether;
	to.tether_ent = tether;

	Net_LinkEntity(tether, false, 0, tether_send);
}
#endif

#ifdef CSQC
#include <lib/csqcmodel/interpolate.qh>

void Draw_CylindricLine(vector from, vector to, float thickness, string texture, float aspect, float shift, vector rgb, float theAlpha, float drawflag, vector vieworg);

entityclass(Tether);
classfield(Tether) .int TetherType;
classfield(Tether) .int TetherWidth;
classfield(Tether) .vector origin;
classfield(Tether) .vector velocity;

classfield(Tether) .float teleport_time;
void Draw_Tether(entity this)
{
	vector a = this.velocity, b = this.origin;
	string tex;

	InterpolateOrigin_Do(this);

	vector rgb = '1 1 1';
	float thickness = (this.TetherWidth) ? this.TetherWidth : 8;

	switch(this.TetherType)
	{
		default:
		case TETHER_VINE_SMALL: tex = "particles/tether_vine_small"; break;
		case TETHER_VINE_BIG: tex = "particles/tether_vine_big"; break;
		case TETHER_FLESH: tex = "particles/tether_flesh"; break;
	}

	Draw_CylindricLine(a, b, thickness, tex, 0.25, 0, rgb, 1, DRAWFLAG_NORMAL, view_origin);
}

NET_HANDLE(ENT_CLIENT_TETHER, bool bIsNew)
{
	int sf = ReadByte();

	this.iflags = IFLAG_VELOCITY | IFLAG_ORIGIN;

	InterpolateOrigin_Undo(this);

	if(sf & 1)
	{
		this.TetherType = ReadByte();
		this.TetherWidth = ReadByte();
	}
	if(sf & 2)
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);
	}
	if(sf & 4)
	{
		this.velocity = ReadVector();
	}

	InterpolateOrigin_Note(this);

	if(bIsNew || !this.teleport_time)
	{
		this.draw = Draw_Tether;
		IL_PUSH(g_drawables, this);

		//this.drawmask = MASK_NORMAL;
	}

	this.teleport_time = time + 10;
	return true;
}
#endif