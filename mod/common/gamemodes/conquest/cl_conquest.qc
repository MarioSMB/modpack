#ifndef IMPLEMENTATION
#include "cl_conquest.qh"
#endif

#ifdef IMPLEMENTATION
#include <client/teamradar.qh>
#include <common/ent_cs.qh>

.float scale;

.float cq_factor;
.float cq_rate;
void conquest_controlpoint_predraw(entity this)
{
	this.enemy.angles_y += 32 * frametime;
	float step = this.cq_rate * frametime;
	if ( this.cq_factor < GetResource(this, RES_HEALTH) - step/2 )
		this.cq_factor += step;
	else if ( this.cq_factor > GetResource(this, RES_HEALTH) + step/2 )
		this.cq_factor -= step;
	setorigin(this.enemy, this.origin + '0 0 1' * (50 + (this.cq_factor * 140)));
}

void conquest_controlpoint_remove(entity this)
{
	if(this.enemy)
		delete(this.enemy);

	if(this.netname)
		strunzone(this.netname);
}

NET_HANDLE(ENT_CLIENT_CONQUEST_CONTROLPOINT, bool is_new)
{
	int sf = ReadByte();

	if(sf & CQSF_SETUP)
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);
		this.drawmask = MASK_NORMAL;

		this.angles_y = ReadCoord();
		
		this.cq_capdistance = ReadLong();

		setmodel(this, MDL_CQ_STAND);
		setsize(this, CP_MIN, CP_MAX);
		setpredraw(this, conquest_controlpoint_predraw);
		if(is_new) IL_PUSH(g_drawables_2d, this);
		this.cq_rate = 0.2;

		this.teamradar_icon = RADARICON_CONTROLPOINT.m_radaricon;
		if(is_new)
			IL_PUSH(g_radaricons, this);

		if(!this.enemy)
			this.enemy = spawn();

		setmodel(this.enemy, MDL_CQ_FLAG);
		this.enemy.drawmask = MASK_NORMAL;
		this.enemy.scale = 1.5;
		this.entremove = conquest_controlpoint_remove;
	}

	if(sf & CQSF_STATE)
	{
		this.cq_status = ReadByte();
	}

	if(sf & CQSF_TEAM)
	{
		this.team = ReadByte();
		this.teamradar_color = Team_ColorRGB(this.team - 1);

		if(this.cq_status == CP_CAPTURED)
			this.enemy.colormap = this.colormap = 1024 + (this.team - 1) * 17;
		else
			this.enemy.colormap = this.colormap = 1024 * 17;
	}

	if(sf & CQSF_HEALTH)
	{
		float newhealth = ReadByte();
		if(newhealth != 0) { newhealth /= 255; }
		SetResourceExplicit(this, RES_HEALTH, newhealth);
		this.cq_rate = ReadCoord() / 100 * 0.2;
		this.teamradar_color = Team_ColorRGB(this.team - 1) * GetResource(this, RES_HEALTH) + '1 1 1' * (1-GetResource(this, RES_HEALTH));
	}

	if(sf & CQSF_NAME)
	{
		if(this.netname)
			strunzone(this.netname);

		this.netname = strzone(ReadString());
	}

	return true;
}

#endif
