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

void CSQC_BUMBLE_GUN_HUD();

const float MAX_AXH = 4;
entity AuxiliaryXhair[MAX_AXH];

.string axh_image;
.float  axh_fadetime;
.float  axh_drawflag;
.float  axh_scale;

#define bumb_ico  "gfx/vehicles/bumb.tga"
#define bumb_lgun  "gfx/vehicles/bumb_lgun.tga"
#define bumb_rgun  "gfx/vehicles/bumb_rgun.tga"

#define bumb_gun_ico  "gfx/vehicles/bumb_side.tga"
#define bumb_gun_gun  "gfx/vehicles/bumb_side_gun.tga"

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

	VEH_ACTION(hud_id, VR_SETUP);

	if(hud_id == HUD_BUMBLEBEE_GUN)
	{
		// Plasma cannons
		AuxiliaryXhair[0].axh_image   = "gfx/vehicles/axh-bracket.tga";
		AuxiliaryXhair[0].axh_scale   = 0.25;
		// Raygun
		AuxiliaryXhair[1].axh_image   = "gfx/vehicles/axh-bracket.tga";
		AuxiliaryXhair[1].axh_scale   = 0.25;
	}
}

void CSQC_BUMBLE_GUN_HUD()
{

	if(autocvar_r_letterbox)
		return;

	vector picsize, hudloc = '0 0 0', pic2size, picloc;

	// Fetch health & ammo stats
	HUD_GETVEHICLESTATS

	picsize = draw_getimagesize(hud_bg) * autocvar_cl_vehicles_hudscale;
	hudloc_y = vid_conheight - picsize_y;
	hudloc_x = vid_conwidth * 0.5 - picsize_x * 0.5;

	drawpic(hudloc, hud_bg, picsize, '1 1 1', autocvar_cl_vehicles_hudalpha, DRAWFLAG_NORMAL);

	shield  *= 0.01;
	vh_health  *= 0.01;
	energy  *= 0.01;
	reload1 *= 0.01;

	pic2size = draw_getimagesize(bumb_gun_ico) * (autocvar_cl_vehicles_hudscale * 0.8);
	picloc = picsize * 0.5 - pic2size * 0.5;

	if(vh_health < 0.25)
		drawpic(hudloc + picloc, bumb_gun_ico, pic2size,  '1 0 0' + '0 1 1' * sin(time * 8),  1, DRAWFLAG_NORMAL);
	else
		drawpic(hudloc + picloc, bumb_gun_ico, pic2size,  '1 1 1' * vh_health  + '1 0 0' * (1 - vh_health),  1, DRAWFLAG_NORMAL);

	drawpic(hudloc + picloc, bumb_gun_gun, pic2size, '1 1 1' * energy   + '1 0 0' * (1 - energy),   1, DRAWFLAG_NORMAL);
	drawpic(hudloc + picloc, hud_sh, pic2size,  '1 1 1', shield, DRAWFLAG_NORMAL);

// Health bar
	picsize = draw_getimagesize(hud_hp_bar) * autocvar_cl_vehicles_hudscale;
	picloc = '69 69 0' * autocvar_cl_vehicles_hudscale;
	drawsetcliparea(hudloc_x + picloc_x + (picsize_x * (1 - vh_health)), 0, vid_conwidth, vid_conheight);
	drawpic(hudloc + picloc, hud_hp_bar, picsize, '1 1 1', 1 , DRAWFLAG_NORMAL);
	drawresetcliparea();
// ..  and icon
	picsize = draw_getimagesize(hud_hp_ico) * autocvar_cl_vehicles_hudscale;
	picloc = '37 65 0' * autocvar_cl_vehicles_hudscale;
	if(vh_health < 0.25)
	{
		if(alarm1time < time)
		{
			alarm1time = time + 2;
			vehicle_alarm(self, CH_PAIN_SINGLE, "vehicles/alarm.wav");
		}

		drawpic(hudloc + picloc, hud_hp_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
	}
	else
	{
		drawpic(hudloc + picloc, hud_hp_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
		if(alarm1time)
		{
			vehicle_alarm(self, CH_PAIN_SINGLE, "misc/null.wav");
			alarm1time = 0;
		}
	}

// Shield bar
	picsize = draw_getimagesize(hud_sh_bar) * autocvar_cl_vehicles_hudscale;
	picloc = '69 140 0' * autocvar_cl_vehicles_hudscale;
	drawsetcliparea(hudloc_x + picloc_x + (picsize_x * (1 - shield)), 0, vid_conwidth, vid_conheight);
	drawpic(hudloc + picloc, hud_sh_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawresetcliparea();
// ..  and icon
	picloc = '40 136 0' * autocvar_cl_vehicles_hudscale;
	picsize = draw_getimagesize(hud_sh_ico) * autocvar_cl_vehicles_hudscale;
	if(shield < 0.25)
	{
		if(alarm2time < time)
		{
			alarm2time = time + 1;
			vehicle_alarm(self, CH_TRIGGER_SINGLE, "vehicles/alarm_shield.wav");
		}
		drawpic(hudloc + picloc, hud_sh_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
	}
	else
	{
		drawpic(hudloc + picloc, hud_sh_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
		if(alarm2time)
		{
			vehicle_alarm(self, CH_TRIGGER_SINGLE, "misc/null.wav");
			alarm2time = 0;
		}
	}

// Gun bar
	picsize = draw_getimagesize(hud_ammo1_bar) * autocvar_cl_vehicles_hudscale;
	picloc = '450 69 0' * autocvar_cl_vehicles_hudscale;
	drawsetcliparea(hudloc_x + picloc_x, picloc_y, picsize_x * energy, vid_conheight);
	drawpic(hudloc + picloc, hud_ammo1_bar, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawresetcliparea();

// ..  and icon
	picsize = 1.5 * draw_getimagesize(hud_energy) * autocvar_cl_vehicles_hudscale;
	picloc = '664 60 0' * autocvar_cl_vehicles_hudscale;
	if(energy < 0.2)
		drawpic(hudloc + picloc, hud_energy, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
	else
		drawpic(hudloc + picloc, hud_energy, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);

	if (scoreboard_showscores)
		HUD_DrawScoreboard();
	/*
	else
	{
		picsize = draw_getimagesize(waki_xhair);
		picsize_x *= 0.5;
		picsize_y *= 0.5;


		drawpic('0.5 0 0' * (vid_conwidth - picsize_x) + '0 0.5 0' * (vid_conheight - picsize_y), waki_xhair, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);
	}
	*/
}

void RaptorCBShellfragDraw()
{
	if(wasfreed(self))
		return;

	Movetype_Physics_MatchTicrate(autocvar_cl_gibs_ticrate, autocvar_cl_gibs_sloppy);
	self.move_avelocity += randomvec() * 15;
	self.renderflags = 0;

	if(self.cnt < time)
		self.alpha = bound(0, self.nextthink - time, 1);

	if(self.alpha < ALPHA_MIN_VISIBLE)
		remove(self);
}

void RaptorCBShellfragToss(vector _org, vector _vel, vector _ang)
{
	entity sfrag;

	sfrag = spawn();
	setmodel(sfrag, "models/vehicles/clusterbomb_fragment.md3");
	setorigin(sfrag, _org);

	sfrag.move_movetype = MOVETYPE_BOUNCE;
	sfrag.gravity = 0.15;
	sfrag.solid = SOLID_CORPSE;

	sfrag.draw = RaptorCBShellfragDraw;

	sfrag.move_origin = sfrag.origin = _org;
	sfrag.move_velocity = _vel;
	sfrag.move_avelocity = prandomvec() * vlen(sfrag.move_velocity);
	sfrag.angles = self.move_angles = _ang;

	sfrag.move_time = time;
	sfrag.damageforcescale = 4;

	sfrag.nextthink = time + 3;
	sfrag.cnt = time + 2;
	sfrag.alpha = 1;
	sfrag.drawmask = MASK_NORMAL;
}
