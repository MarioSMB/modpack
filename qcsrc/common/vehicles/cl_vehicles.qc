#define hud_bg "gfx/vehicles/frame.tga"
#define hud_sh "gfx/vehicles/vh-shield.tga"

#define hud_hp_bar "gfx/vehicles/bar_up_left.tga"
#define hud_hp_ico "gfx/vehicles/health.tga"
#define hud_sh_bar "gfx/vehicles/bar_dwn_left.tga"
#define hud_sh_ico "gfx/vehicles/shield.tga"

#define hud_ammo1_bar "gfx/vehicles/bar_up_right.tga"
#define hud_ammo1_ico "gfx/vehicles/bullets.tga"
#define hud_ammo2_bar "gfx/vehicles/bar_dwn_right.tga"
#define hud_ammo2_ico "gfx/vehicles/rocket.tga"
#define hud_energy "gfx/vehicles/energy.tga"

entity dropmark;
var float autocvar_cl_vehicles_hudscale = 0.5;
var float autocvar_cl_vehicles_hudalpha = 0.75;

const float MAX_AXH = 4;
entity AuxiliaryXhair[MAX_AXH];

.string axh_image;
.float  axh_fadetime;
.float  axh_drawflag;
.float  axh_scale;

float alarm1time;
float alarm2time;

void vehicle_alarm(entity e, float ch, string s0und)
{
	if(!autocvar_cl_vehicles_alarm)
		return;

	sound(e, ch, s0und, VOL_BASEVOICE, ATTEN_NONE);
}

void AuxiliaryXhair_Draw2D()
{
	vector loc, psize;

	psize = self.axh_scale * draw_getimagesize(self.axh_image);
	loc = project_3d_to_2d(self.move_origin) - 0.5 * psize;
	if(!(loc_z < 0 || loc_x < 0 || loc_y < 0 || loc_x > vid_conwidth || loc_y > vid_conheight))
	{
		loc_z = 0;
		psize_z = 0;
		drawpic(loc, self.axh_image, psize, self.colormod, self.alpha, self.axh_drawflag);
	}

	if(time - self.cnt > self.axh_fadetime)
		self.draw2d = func_null;
}

void Net_AuXair2(float bIsNew)
{
	float axh_id	= bound(0, ReadByte(), MAX_AXH);
	entity axh 		= AuxiliaryXhair[axh_id];

	if(axh == world || wasfreed(axh))  // MADNESS? THIS IS QQQQCCCCCCCCC (wasfreed, why do you exsist?)
	{
		axh					= spawn();
		axh.draw2d			= func_null;
		axh.drawmask 		= MASK_NORMAL;
		axh.axh_drawflag	= DRAWFLAG_ADDITIVE;
		axh.axh_fadetime	= 0.1;
		axh.axh_image		= "gfx/vehicles/axh-ring.tga";
		axh.axh_scale		= 1;
		axh.alpha			= 1;
		AuxiliaryXhair[axh_id] = axh;
	}

	axh.move_origin_x	= ReadCoord();
	axh.move_origin_y	= ReadCoord();
	axh.move_origin_z	= ReadCoord();
	axh.colormod_x		= ReadByte() / 255;
	axh.colormod_y		= ReadByte() / 255;
	axh.colormod_z		= ReadByte() / 255;
	axh.cnt 			= time;
	axh.draw2d			= AuxiliaryXhair_Draw2D;
}

void Net_VehicleSetup()
{
	float i;

	float hud_id = ReadByte();

	// hud_id == 0 means we exited a vehicle, so stop alarm sound/s
	if(hud_id == 0)
	{
		sound(self, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_BASEVOICE, ATTEN_NONE);
		sound(self, CH_PAIN_SINGLE, "misc/null.wav", VOL_BASEVOICE, ATTEN_NONE);
		return;
	}

	// Init auxiliary crosshairs
	entity axh;
	for(i = 0; i < MAX_AXH; ++i)
	{
		axh = AuxiliaryXhair[i];
		if(axh != world && !wasfreed(axh))  // MADNESS? THIS IS QQQQCCCCCCCCC (wasfreed, why do you exsist?)
			remove(axh);

		axh					= spawn();
		axh.draw2d			= func_null;
		axh.drawmask		= MASK_NORMAL;
		axh.axh_drawflag	= DRAWFLAG_NORMAL;
		axh.axh_fadetime	= 0.1;
		axh.axh_image		= "gfx/vehicles/axh-ring.tga";
		axh.axh_scale		= 1;
		axh.alpha			= 1;
		AuxiliaryXhair[i]	= axh;
	}

	if(hud_id == HUD_BUMBLEBEE_GUN)
	{
		// Plasma cannons
		AuxiliaryXhair[0].axh_image   = "gfx/vehicles/axh-bracket.tga";
		AuxiliaryXhair[0].axh_scale   = 0.25;
		// Raygun
		AuxiliaryXhair[1].axh_image   = "gfx/vehicles/axh-bracket.tga";
		AuxiliaryXhair[1].axh_scale   = 0.25;
	}
	else { VEH_ACTION(hud_id, VR_SETUP); }
}
