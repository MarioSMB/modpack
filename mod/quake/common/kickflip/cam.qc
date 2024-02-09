#include "cam.qh"

#if 0
//The camera thinks...
void cam_think(entity this)
{
local vector	view_org;
local vector	start;
local vector	calc_dir;
local float		limited_angle;


	if (this.owner.cam_on == FALSE)
		return;
	
	makevectors(this.owner.v_angle);
	view_org = this.owner.origin - v_forward * 80;
	view_org = view_org - (this.owner.velocity * 0.05);		//simulate flying camera without perfect reaction
	
	limited_angle = this.owner.v_angle_x;	//limit the player's x-angle
	if (limited_angle > 10)
		limited_angle = 10;
	else if (limited_angle < -10)
		limited_angle = -10;
	view_org_z = view_org_z + (limited_angle * 1);		//makevectors doesn't include looking up or down
	
	traceline (this.owner.origin, view_org, TRUE, this.owner);	//Find the nearest spot to the wall
	if (trace_fraction == 1.0)
	{
		view_org = trace_endpos;
	}
	else
	{
		calc_dir = normalize(this.owner.origin - trace_endpos);
		view_org = trace_endpos + (calc_dir * 5);			//don't put directly at the wall (graphic bugs)
	}

	//view_org_z = view_org_z + (1- trace_fraction) * 20;		//go up a bit

	setorigin(this, view_org);

	msg_entity = this.owner;
	WriteByte (MSG_ONE, 5);
	WriteEntity (MSG_ONE, this);

	this.think = cam_think;
	this.nextthink = time + 0.01;
};

void() switch_cam =
{
	if (this.cam_on)			//already activated
	{
		this.cam_on = FALSE;		//deactivate

		msg_entity = this;                 
		WriteByte (MSG_ONE, 5);    
		WriteEntity (MSG_ONE, this);
		WriteByte (MSG_ONE, 10);  
		WriteAngle(MSG_ONE, this.v_angle_x);    
		WriteAngle(MSG_ONE, this.v_angle_y);    
		WriteAngle(MSG_ONE, this.v_angle_z);
		
		W_SetCurrentAmmo();

		setmodel(this.cam, "");

		sprint(this,"cam deactivated\n");
	}
	else
	{
		this.cam_on = TRUE;
		setorigin(this.cam, this.origin);
		this.cam.think = cam_think;
		this.cam.nextthink = time + 0.01;
		this.weaponmodel = "";
		this.cam.owner = this;

		setmodel(this.cam, "progs/s_bubble.spr");

		sprint(this, "cam activated\n");
	}
};	

#endif
