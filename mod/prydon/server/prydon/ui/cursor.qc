#include "cursor.qh"

#include "../spells/sval.qh"
#include "../subs/subs.qh"

const float CAMERA_SCALE = 0.5; // rotation scale down
float cursorframe(entity this)
{
	int s = this.spell & 63;
	
	if(!s)
	{
		if(friendly(this.player, this.sbarsub))
			return 16;
		if(this.altaction == SP_FIGHT_MELEE)
			return 17; // melee frame
		else if(this.altaction == SP_FIGHT_BOW)
			return 18;
		else if(this.altaction == SP_FIGHT_CBOW)
			return 18;
		else if(this.altaction && this.altaction < 16)
			return this.altaction - 1;
		else
			return 17; // generic I guess
		// TODO: Make a THROW frame
	}
	if(s < 16)
		return s - 1;
	else if(s >= SP_SPRINT && s <= SP_IDENTIFY)
		return s - SP_SPRINT + 19;
	return 0;
}

void h_cursor(entity this)
{
	//PRYDON_CLIENTCURSOR
	if(this.cursor_active)
	{
		if(this.cursor)
		{
			delete(this.cursor);
			this.cursor = NULL;
		}
		this.cursorpos_x = this.cursor_screen_x * 96;
		this.cursorpos_y = this.cursor_screen_y * 72;
	}
	else
	{
		
		if(!this.cursor)
		{
			this.cursor = spawn();
			this.cursor.drawonlytoclient = this;
			_setmodel(this.cursor, "progs/cursor.spr"); // ugly temp model
		}
		this.cursor.frame = cursorframe(this);
		vector view = this.rotang;
		view.z = 0;
		if(this.origin != this.testorg)
		{
			vector ang = vectoangles(this.origin - this.testorg) - view;
			float len = vlen(this.origin - this.testorg) * -1;
			ang.x = ang.z = 0;
			makevectors(ang);
			this.cursorpos_y = this.cursorpos_y + v_forward_x * len;
			this.cursorpos_x = this.cursorpos_x + v_forward_y * len;
			//setorigin(this, this.testorg);
		}
	}
	if((this.options & OPT_NOMOUSE_CAM) || this.ui_panels)
	{
		if(this.cursorpos_y > 72)
			this.cursorpos_y = 72;
		else if(this.cursorpos_y < -72)
			this.cursorpos_y = -72;
		if(this.cursorpos_x > 96)
			this.cursorpos_x = 96;
		else if(this.cursorpos_x < -96)
			this.cursorpos_x = -96;
		if(!vmfc)
			if(this.ui_panels)
				this.rotang_z = 256;
	}
	else
	{
		if(this.cursorpos_y > 72)
		{
			this.rotang_z = this.rotang_z - (this.cursorpos_y - 72);
			if(this.rotang_z < 64)
				this.rotang_z = 64;
			this.cursorpos_y = 72;
		}
		else if(this.cursorpos_y < -72)
		{
			this.rotang_z = this.rotang_z - (this.cursorpos_y + 72);
			if(this.rotang_z > 256)
				this.rotang_z = 256;
			this.cursorpos_y = -72;
		}
		if(this.cursorpos_x > 96)
		{
			this.rotang_y = this.rotang_y - (this.cursorpos_x - 96) * CAMERA_SCALE;
			this.cursorpos_x = 96;
		}
		else if(this.cursorpos_x < -96)
		{
			this.rotang_y = this.rotang_y - (this.cursorpos_x + 96) * CAMERA_SCALE;
			this.cursorpos_x = -96;
		}
	}
}

// DP hack man
.vector movement;

void prydon_SV_PlayerPhysics(entity this)
{
	float spscl = 200 / (PHYS_MAXSPEED(this) / 320);

	setorigin(this, this.testorg);
	this.cursorpos_y = this.cursorpos_y - this.movement_x / spscl;
	this.cursorpos_x = this.cursorpos_x + this.movement_y / spscl;

	h_cursor(this);
}
