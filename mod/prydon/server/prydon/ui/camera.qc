#include "camera.qh"

const int SVC_SETVIEW = 5; // TODO: move to dpdefs where this belongs!
void h_camera(entity this)
{
	vector view = '0 0 0', org = '0 0 0';
	float dist = 0, len = 0, len2 = 0;
	if(this.button4)
		this.rotang_y = this.rotang_y + 120 * frametime;
	if(this.button5)
		this.rotang_y = this.rotang_y - 120 * frametime;
	if(this.button6)
	{
		this.rotang_z = this.rotang_z + 80 * frametime;
		if(this.rotang_z > 256)
			this.rotang_z = 256;
	}
	if(this.button7)
	{
		this.rotang_z = this.rotang_z - 80 * frametime;
		if(this.rotang_z < 64)
			this.rotang_z = 64;
	}
	if(!this.camera)
	{	
		this.camera = spawn();
		this.camera.drawonlytoclient = this;
		this.drawonlytoclient = this;
		this.camera.solid = SOLID_NOT;
		set_movetype(this.camera, MOVETYPE_NOCLIP);
		_setmodel(this.camera, "progs/null.spr");
		msg_entity = this;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, this.camera);
	}
	if(this.camera.enemy)
	{
		org = this.camera.enemy.origin + '0 64 0';
		view.y = 0;
		this.rotang_y = view.y;
		view.x = 0;	
	}
	else if(this.camera.goalentity)
	{
		org = this.camera.goalentity.origin;
		view = vectoangles(this.player.origin - org);
		this.rotang_y = view.y;
		view.x = view.x * -1;
	}
	else
	{
		view = this.rotang;
		view.z = 0;
		dist = this.rotang_z;
	}
	makevectors(view);
	if(this.camera.enemy)
	{
		setorigin(this, org);
		setorigin(this.camera, org);
		
	}
	else if(this.camera.goalentity)
	{
		setorigin(this.camera, org);
		setorigin(this, org);
	}	
	else if(this.player)
	{
		
		if(this.ui_panels)
			org = this.player.origin + v_forward * (0 - dist) - v_right * (dist/2);
		else
			org = this.player.origin + v_forward * (0 - dist);
		if(pointcontents(org) != CONTENT_EMPTY)
		{
			traceline(this.player.origin, org, true, this);
			org = trace_endpos + v_forward + trace_plane_normal;
		}
		else
		{
			dist = vlen(org - this.player.origin);
			traceline(org, this.player.origin, true, this);
			if(trace_fraction!= 1)
			{
				len = trace_fraction * dist;
				traceline(this.player.origin, org, true, this);
				len2 = trace_fraction * dist;
				
				if(len < 64)
				{
					if(len2 >= 64)
						org = trace_endpos + v_forward + trace_plane_normal;
				}
			}
		}
		setorigin(this.camera, org);
		setorigin(this, org);
	}

	this.testorg = this.origin;
	msg_entity = this;
	WriteByte(MSG_ONE,10);
	WriteAngle(MSG_ONE,view.x);
	WriteAngle(MSG_ONE,view.y);
	WriteAngle(MSG_ONE,0);
	this.camera.angles = view;
	this.camera.angles_z = 0;
}
