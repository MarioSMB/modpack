#include "cam.qh"

#if 0
//The camera thinks...
void cam_think(entity this)
{
local vector	view_org;
local vector	start;
local vector	calc_dir;
local float		limited_angle;


	if (self.owner.cam_on == FALSE)
		return;
	
	makevectors(self.owner.v_angle);
	view_org = self.owner.origin - v_forward * 80;
	view_org = view_org - (self.owner.velocity * 0.05);		//simulate flying camera without perfect reaction
	
	limited_angle = self.owner.v_angle_x;	//limit the player's x-angle
	if (limited_angle > 10)
		limited_angle = 10;
	else if (limited_angle < -10)
		limited_angle = -10;
	view_org_z = view_org_z + (limited_angle * 1);		//makevectors doesn't include looking up or down
	
	traceline (self.owner.origin, view_org, TRUE, self.owner);	//Find the nearest spot to the wall
	if (trace_fraction == 1.0)
	{
		view_org = trace_endpos;
	}
	else
	{
		calc_dir = normalize(self.owner.origin - trace_endpos);
		view_org = trace_endpos + (calc_dir * 5);			//don't put directly at the wall (graphic bugs)
	}

	//view_org_z = view_org_z + (1- trace_fraction) * 20;		//go up a bit

	setorigin(self, view_org);

	msg_entity = self.owner;
	WriteByte (MSG_ONE, 5);
	WriteEntity (MSG_ONE, self);

	self.think = cam_think;
	self.nextthink = time + 0.01;
};

void() switch_cam =
{
	if (self.cam_on)			//already activated
	{
		self.cam_on = FALSE;		//deactivate

		msg_entity = self;                 
		WriteByte (MSG_ONE, 5);    
		WriteEntity (MSG_ONE, self);
		WriteByte (MSG_ONE, 10);  
		WriteAngle(MSG_ONE, self.v_angle_x);    
		WriteAngle(MSG_ONE, self.v_angle_y);    
		WriteAngle(MSG_ONE, self.v_angle_z);
		
		W_SetCurrentAmmo();

		setmodel(self.cam, "");

		sprint(self,"cam deactivated\n");
	}
	else
	{
		self.cam_on = TRUE;
		setorigin(self.cam, self.origin);
		self.cam.think = cam_think;
		self.cam.nextthink = time + 0.01;
		self.weaponmodel = "";
		self.cam.owner = self;

		setmodel(self.cam, "progs/s_bubble.spr");

		sprint(self, "cam activated\n");
	}
};	

#endif
