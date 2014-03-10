#ifdef REGISTER_VEHICLE
REGISTER_VEHICLE(
/* VEH_##id   */ YUGO,
/* function   */ v_yugo,
/* spawnflags */ 0,
/* mins,maxs  */ '-50 -50 -50', '50 50 50',
/* model	  */ "models/vehicles/yugo.dpm",
/* head_model */ "null",
/* hud_model  */ "null",
/* tags	   	  */ "", "", "tag_viewport",
/* netname	  */ "yugo",
/* fullname   */ _("Yugo")
);
#else
#ifdef SVQC
float autocvar_g_vehicle_yugo;

float autocvar_g_vehicle_yugo_speed_afterburn;
float autocvar_g_vehicle_yugo_afterburn_cost;

var float autocvar_g_vehicle_yugo_cloak_cost = 20;
var float autocvar_g_vehicle_yugo_supercloak_cost = 1000;

float autocvar_g_vehicle_yugo_anglestabilizer;
float autocvar_g_vehicle_yugo_downforce;

float autocvar_g_vehicle_yugo_speed_forward;
float autocvar_g_vehicle_yugo_speed_strafe;
float autocvar_g_vehicle_yugo_springlength;
float autocvar_g_vehicle_yugo_upforcedamper;
float autocvar_g_vehicle_yugo_friction;

float autocvar_g_vehicle_yugo_hovertype;
float autocvar_g_vehicle_yugo_hoverpower;
float autocvar_g_vehicle_yugo_hoverpower_idle;

float autocvar_g_vehicle_yugo_turnroll;
float autocvar_g_vehicle_yugo_turnspeed;
float autocvar_g_vehicle_yugo_pitchspeed;

float autocvar_g_vehicle_yugo_energy;
float autocvar_g_vehicle_yugo_energy_regen;
float autocvar_g_vehicle_yugo_energy_regen_pause;

float autocvar_g_vehicle_yugo_health;
float autocvar_g_vehicle_yugo_health_regen;
float autocvar_g_vehicle_yugo_health_regen_pause;

float autocvar_g_vehicle_yugo_shield;
float autocvar_g_vehicle_yugo_shield_regen;
float autocvar_g_vehicle_yugo_shield_regen_pause;

float autocvar_g_vehicle_yugo_respawntime;

float autocvar_g_vehicle_yugo_blowup_radius;
float autocvar_g_vehicle_yugo_blowup_coredamage;
float autocvar_g_vehicle_yugo_blowup_edgedamage;
float autocvar_g_vehicle_yugo_blowup_forceintensity;

float autocvar_g_vehicle_yugo_bouncefactor;
float autocvar_g_vehicle_yugo_bouncestop;
vector autocvar_g_vehicle_yugo_bouncepain;

var vector yugo_force_from_tag(string tag_name, float spring_length, float max_power);

void yugo_align4point(float _delta)
{
	vector push_vector;
	float fl_push, fr_push, bl_push, br_push;
	float hoverpower = ((self.owner) ? autocvar_g_vehicle_yugo_hoverpower : autocvar_g_vehicle_yugo_hoverpower_idle);

	push_vector  = yugo_force_from_tag("tag_engine_fr", autocvar_g_vehicle_yugo_springlength, hoverpower);
	fr_push	  = force_fromtag_normpower;
	//vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_yugo_collision_multiplier);

	push_vector += yugo_force_from_tag("tag_engine_fl", autocvar_g_vehicle_yugo_springlength, hoverpower);
	fl_push	  = force_fromtag_normpower;
	//vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_yugo_collision_multiplier);

	push_vector += yugo_force_from_tag("tag_engine_br", autocvar_g_vehicle_yugo_springlength, hoverpower);
	br_push	  = force_fromtag_normpower;
	//vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_yugo_collision_multiplier);

	push_vector += yugo_force_from_tag("tag_engine_bl", autocvar_g_vehicle_yugo_springlength, hoverpower);
	bl_push	  = force_fromtag_normpower;
	//vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_yugo_collision_multiplier);

   self.velocity += push_vector * _delta;
   
   if(pointcontents(self.origin - '0 0 64') == CONTENT_WATER)
		self.velocity_z += 200;

	// Anti ocilation
	if(self.velocity_z > 0)
		self.velocity_z *= 1 - autocvar_g_vehicle_yugo_upforcedamper * _delta;

	push_vector_x =  (fl_push - bl_push);
	push_vector_x += (fr_push - br_push);
	push_vector_x *= 360;

	push_vector_z = (fr_push - fl_push);
	push_vector_z += (br_push - bl_push);
	push_vector_z *= 360;

	// Apply angle diffrance
	self.angles_z += push_vector_z * _delta;
	self.angles_x += push_vector_x * _delta;

	// Apply stabilizer
	self.angles_x *= 1 - (autocvar_g_vehicle_yugo_anglestabilizer * _delta);
	self.angles_z *= 1 - (autocvar_g_vehicle_yugo_anglestabilizer * _delta);
}

float yugo_frame()
{
	entity player, yugo;
	vector df;
	float ftmp;

	if(intermission_running)
	{
		self.vehicle.velocity = '0 0 0';
		return 1;
	}

	player  = self;
	yugo   = self.vehicle;
	self	= yugo;

	player.BUTTON_ZOOM = player.BUTTON_CROUCH = 0;

	vehicles_painframe();

	if(yugo.deadflag != DEAD_NO)
	{
		self = player;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
		return 1;
	}

	yugo_align4point(frametime);

	crosshair_trace(player);

	yugo.angles_x *= -1;

	// Yaw
	ftmp = autocvar_g_vehicle_yugo_turnspeed * frametime;
	ftmp = bound(-ftmp, shortangle_f(player.v_angle_y - yugo.angles_y, yugo.angles_y), ftmp);
	yugo.angles_y = anglemods(yugo.angles_y + ftmp);

	// Roll
	yugo.angles_z += -ftmp * autocvar_g_vehicle_yugo_turnroll * frametime;

	// Pitch
	ftmp = autocvar_g_vehicle_yugo_pitchspeed  * frametime;
	ftmp = bound(-ftmp, shortangle_f(player.v_angle_x - yugo.angles_x, yugo.angles_x), ftmp);
	yugo.angles_x = bound(-30, anglemods(yugo.angles_x + ftmp), 30);

	makevectors(yugo.angles);
	yugo.angles_x *= -1;

	//ftmp = yugo.velocity_z;
	df = yugo.velocity * -autocvar_g_vehicle_yugo_friction;
	//yugo.velocity_z = ftmp;

	if(vlen(player.movement) != 0)
	{
		if(player.movement_x)
			df += v_forward * ((player.movement_x > 0) ? autocvar_g_vehicle_yugo_speed_forward : -autocvar_g_vehicle_yugo_speed_forward);

		if(player.movement_y)
			df += v_right * ((player.movement_y > 0) ? autocvar_g_vehicle_yugo_speed_strafe : -autocvar_g_vehicle_yugo_speed_strafe);

		if(self.sound_nexttime < time || self.sounds != 1)
		{
			self.sounds = 1;
			self.sound_nexttime = time + 10.922667; //soundlength("vehicles/yugo_move.wav");
			sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_move.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
		}
	}
	else
	{
		if(self.sound_nexttime < time || self.sounds != 0)
		{
			self.sounds = 0;
			self.sound_nexttime = time + 11.888604; //soundlength("vehicles/yugo_idle.wav");
			sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_idle.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
		}
	}

	// Afterburn
	if (player.BUTTON_JUMP && yugo.vehicle_energy >= (autocvar_g_vehicle_yugo_afterburn_cost * frametime))
	{
		if(time - yugo.wait > 0.2)
			pointparticles(particleeffectnum("yugo_booster_smoke"), self.origin - v_forward * 32, v_forward  * vlen(self.velocity), 1);

		yugo.wait = time;
		yugo.vehicle_energy -= autocvar_g_vehicle_yugo_afterburn_cost * frametime;
		df += (v_forward * autocvar_g_vehicle_yugo_speed_afterburn);

		if(yugo.invincible_finished < time)
		{
			traceline(yugo.origin, yugo.origin - '0 0 256', MOVE_NORMAL, self);
			if(trace_fraction != 1.0)
				pointparticles(particleeffectnum("smoke_small"), trace_endpos, '0 0 0', 1);

			yugo.invincible_finished = time + 0.1 + (random() * 0.1);
		}

		if(yugo.strength_finished < time)
		{
			yugo.strength_finished = time + 10.922667; //soundlength("vehicles/yugo_boost.wav");
			sound (yugo.tur_head, CH_TRIGGER_SINGLE, "vehicles/racer_boost.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
		}
	}
	else
	{
		yugo.strength_finished = 0;
		sound (yugo.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
	}
	
	if(player.BUTTON_ATCK && time - yugo.pain_finished >= 0.5 && yugo.vehicle_energy >= (autocvar_g_vehicle_yugo_cloak_cost * frametime))
	{
		yugo.wait = time;
		yugo.vehicle_energy -= autocvar_g_vehicle_yugo_cloak_cost * frametime;

		if(yugo.vehicle_energy <= 50)
			yugo.alpha = 0.5;
		else if(yugo.vehicle_energy <= 100)
			yugo.alpha = 0.3;
		else
			yugo.alpha = 0.1;
	}
	else if(player.BUTTON_ATCK2 && time - yugo.pain_finished >= 0.5 && yugo.vehicle_energy >= (autocvar_g_vehicle_yugo_supercloak_cost * frametime))
	{
		yugo.wait = time;
		yugo.vehicle_energy -= autocvar_g_vehicle_yugo_supercloak_cost * frametime;

		yugo.alpha = -1;
	}
	else
		yugo.alpha = 1;

	df -= v_up * (vlen(yugo.velocity) * autocvar_g_vehicle_yugo_downforce);
	player.movement = yugo.velocity += df * frametime;

	player.vehicle_reload1 = bound(0, 100 * ((time - yugo.lip) / (yugo.delay - yugo.lip)), 100);

	if(yugo.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(yugo.dmg_time, vehicle_shield, autocvar_g_vehicle_yugo_shield, autocvar_g_vehicle_yugo_shield_regen_pause, autocvar_g_vehicle_yugo_shield_regen, frametime, TRUE);

	if(yugo.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(yugo.dmg_time, vehicle_health, autocvar_g_vehicle_yugo_health, autocvar_g_vehicle_yugo_health_regen_pause, autocvar_g_vehicle_yugo_health_regen, frametime, FALSE);

	if(yugo.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(yugo.wait, vehicle_energy, autocvar_g_vehicle_yugo_energy, autocvar_g_vehicle_yugo_energy_regen_pause, autocvar_g_vehicle_yugo_energy_regen, frametime, FALSE);


	VEHICLE_UPDATE_PLAYER(player, health, yugo);
	VEHICLE_UPDATE_PLAYER(player, energy, yugo);

	if(yugo.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(player, shield, yugo);

	player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
	setorigin(player,yugo.origin + '0 0 32');
	player.velocity = yugo.velocity;

	self = player;
	return 1;
}

void yugo_think()
{
	self.nextthink = time;

	float pushdeltatime = time - self.lastpushtime;
	if (pushdeltatime > 0.15) pushdeltatime = 0;
	self.lastpushtime = time;
	if(!pushdeltatime) return;

	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_yugo_springlength), MOVE_NOMONSTERS, self);

	vector df = self.velocity * -autocvar_g_vehicle_yugo_friction;
	df_z += (1 - trace_fraction) * ((self.owner) ? autocvar_g_vehicle_yugo_hoverpower : autocvar_g_vehicle_yugo_hoverpower_idle) + sin(time * 2) * (autocvar_g_vehicle_yugo_springlength * 2);

	if(pointcontents(self.origin - '0 0 64') == CONTENT_WATER)
		self.velocity_z += 200;

	self.velocity += df * pushdeltatime;
	if(self.velocity_z > 0)
		self.velocity_z *= 1 - autocvar_g_vehicle_yugo_upforcedamper * pushdeltatime;

	self.angles_x *= 1 - (autocvar_g_vehicle_yugo_anglestabilizer * pushdeltatime);
	self.angles_z *= 1 - (autocvar_g_vehicle_yugo_anglestabilizer * pushdeltatime);
	
	CSQCMODEL_AUTOUPDATE();
}

void yugo_exit(float eject)
{
	vector spot;

	self.think	  = yugo_think;
	self.nextthink  = time;
	self.movetype   = MOVETYPE_BOUNCE;
	self.alpha = 1;
	sound (self.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTEN_NORM);

	if(!self.owner)
		return;

	makevectors(self.angles);
	if(eject)
	{
		spot = self.origin + v_forward * 100 + '0 0 64';
		spot = vehicles_findgoodexit(spot);
		setorigin(self.owner , spot);
		self.owner.velocity = (v_up + v_forward * 0.25) * 750;
		self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > 2 * autocvar_sv_maxairspeed)
		{
			self.owner.velocity = normalize(self.velocity) * autocvar_sv_maxairspeed * 2;
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 32 + '0 0 32';
			spot = vehicles_findgoodexit(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin - v_forward * 200 + '0 0 32';
			spot = vehicles_findgoodexit(spot);
		}
		self.owner.oldvelocity = self.owner.velocity;
		setorigin(self.owner , spot);
	}
	antilag_clear(self.owner);
	self.owner = world;
}

void yugo_blowup()
{
	self.deadflag	= DEAD_DEAD;
	self.vehicle_exit(VHEF_NORMAL);

	RadiusDamage (self, self.enemy, autocvar_g_vehicle_yugo_blowup_coredamage,
					autocvar_g_vehicle_yugo_blowup_edgedamage,
					autocvar_g_vehicle_yugo_blowup_radius, world,
					autocvar_g_vehicle_yugo_blowup_forceintensity,
					DEATH_VH_WAKI_DEATH, world);

	self.nextthink  = time + autocvar_g_vehicle_yugo_respawntime;
	self.think	  = vehicles_spawn;
	self.movetype   = MOVETYPE_NONE;
	self.effects	= EF_NODRAW;

	self.colormod  = '0 0 0';
	self.avelocity = '0 0 0';
	self.velocity  = '0 0 0';

	setorigin(self, self.pos1);
}

void yugo_blowup_think()
{
	self.nextthink = time;
	
	if(time >= self.delay)
		yugo_blowup();
	
	CSQCMODEL_AUTOUPDATE();
}

void yugo_deadtouch()
{
	self.avelocity_x *= 0.7;
	self.cnt -= 1;
	if(self.cnt <= 0)
		yugo_blowup();
}

void spawnfunc_vehicle_yugo()
{
	if(!autocvar_g_vehicles_extra) { remove(self); return; }
	if(!autocvar_g_vehicle_yugo) { remove(self); return; }
	if(!vehicle_initialize(VEH_YUGO, FALSE)) { remove(self); return; }
}

float v_yugo(float req)
{
	switch(req)
	{
		case VR_IMPACT:
		{
			if(autocvar_g_vehicle_yugo_bouncepain)
				vehicles_impact(autocvar_g_vehicle_yugo_bouncepain_x, autocvar_g_vehicle_yugo_bouncepain_y, autocvar_g_vehicle_yugo_bouncepain_z);
			return TRUE;
		}
		case VR_ENTER:
		{
			self.movetype = MOVETYPE_WALK;
			self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_yugo_health)  * 100;
			self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_yugo_shield)  * 100;

			if(self.owner.flagcarried)
			   setorigin(self.owner.flagcarried, '-190 0 96');
			   
			return TRUE;
		}
		case VR_THINK:
		{

			return TRUE;
		}
		case VR_DEATH:
		{
			self.health			= 0;
			self.event_damage	= func_null;
			self.solid			= SOLID_CORPSE;
			self.takedamage		= DAMAGE_NO;
			self.deadflag		= DEAD_DYING;
			self.movetype		= MOVETYPE_BOUNCE;
			self.wait			= time;
			self.delay			= 2 + time + random() * 3;
			self.cnt			= 1 + random() * 2;
			self.touch			= yugo_deadtouch;

			pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

			if(random() < 0.5)
				self.avelocity_z = 32;
			else
				self.avelocity_z = -32;

			self.avelocity_x = -vlen(self.velocity) * 0.2;
			self.velocity += '0 0 700';
			self.colormod = '-0.5 -0.5 -0.5';

			self.think = yugo_blowup_think;
			self.nextthink = time;
	
			return TRUE;
		}
		case VR_SPAWN:
		{
			if(self.scale != 0.5)
			{
				if(autocvar_g_vehicle_yugo_hovertype)
					yugo_force_from_tag = vehicles_force_fromtag_maglev;
				else
					yugo_force_from_tag = vehicles_force_fromtag_hover;

				// FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
				self.scale = 0.5;
				setattachment(self.vehicle_hudmodel, self, "");
				setattachment(self.vehicle_viewport, self, "tag_viewport");

				self.mass			   = 900;
			}

			self.think		  = yugo_think;
			self.nextthink	  = time;
			self.vehicle_health = autocvar_g_vehicle_yugo_health;
			self.vehicle_shield = autocvar_g_vehicle_yugo_shield;

			self.movetype	  = MOVETYPE_TOSS;
			self.solid		  = SOLID_SLIDEBOX;
			self.delay		  = time;
			self.scale		  = 0.5;
			self.alpha = 1;
			
			self.PlayerPhysplug = yugo_frame;
			
			self.bouncefactor = autocvar_g_vehicle_yugo_bouncefactor;
			self.bouncestop = autocvar_g_vehicle_yugo_bouncestop;
			self.damageforcescale = 0.5;
			self.vehicle_health = autocvar_g_vehicle_yugo_health;
			self.vehicle_shield = autocvar_g_vehicle_yugo_shield;
			
			return TRUE;
		}
		case VR_SETUP:
		{
			if(autocvar_g_vehicle_yugo_energy)
			if(autocvar_g_vehicle_yugo_energy_regen)
				self.vehicle_flags |= VHF_ENERGYREGEN;

			if(autocvar_g_vehicle_yugo_shield)
				self.vehicle_flags |= VHF_HASSHIELD;

			if(autocvar_g_vehicle_yugo_shield_regen)
				self.vehicle_flags |= VHF_SHIELDREGEN;

			if(autocvar_g_vehicle_yugo_health_regen)
				self.vehicle_flags |= VHF_HEALTHREGEN;
				
			self.vehicle_exit = yugo_exit;
			self.respawntime = autocvar_g_vehicle_yugo_respawntime;
			self.vehicle_health = autocvar_g_vehicle_yugo_health;
			self.vehicle_shield = autocvar_g_vehicle_yugo_shield;
			self.max_health = self.vehicle_health;
				
			return TRUE;
		}
		case VR_PRECACHE:
		{
			precache_sound ("weapons/lasergun_fire.wav");
			precache_sound ("weapons/rocket_fire.wav");

			precache_sound ("vehicles/racer_idle.wav");
			precache_sound ("vehicles/racer_move.wav");
			precache_sound ("vehicles/racer_boost.wav");

			precache_model ("models/vhshield.md3");
			precache_model ("models/vehicles/yugo.dpm");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC

#define yugo_ico "gfx/vehicles/yugo.tga"

float v_yugo(float req)
{
	switch(req)
	{
		case VR_HUD:
		{
			if(autocvar_r_letterbox)
				return TRUE;

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

			pic2size = draw_getimagesize(yugo_ico) * (autocvar_cl_vehicles_hudscale * 0.8);
			picloc = picsize * 0.5 - pic2size * 0.5;
			if(vh_health < 0.25)
				drawpic(hudloc + picloc, yugo_ico, pic2size,  '1 0 0' + '0 1 1' * sin(time * 8),  1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, yugo_ico, pic2size,  '1 1 1' * vh_health  + '1 0 0' * (1 - vh_health),  1, DRAWFLAG_NORMAL);
			//drawpic(hudloc + picloc, yugo_eng, pic2size, '1 1 1' * energy   + '1 0 0' * (1 - energy),   1, DRAWFLAG_NORMAL);
			//drawpic(hudloc + picloc, yugo_gun, pic2size, '1 1 1' * energy   + '1 0 0' * (1 - energy),   1, DRAWFLAG_NORMAL);
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
			picsize = draw_getimagesize(hud_ammo1_ico) * autocvar_cl_vehicles_hudscale;
			picloc = '664 60 0' * autocvar_cl_vehicles_hudscale;
			if(energy < 0.2)
				drawpic(hudloc + picloc, hud_ammo1_ico, picsize, '1 0 0' + '0 1 1' * sin(time * 8), 1, DRAWFLAG_NORMAL);
			else
				drawpic(hudloc + picloc, hud_ammo1_ico, picsize, '1 1 1', 1, DRAWFLAG_NORMAL);

			if (scoreboard_showscores)
				HUD_DrawScoreboard();
			return TRUE;
		}
		case VR_SETUP:
		{
			AuxiliaryXhair[0].axh_image = "gfx/vehicles/axh-bracket.tga";
			AuxiliaryXhair[0].axh_scale = 0.25;
			return TRUE;
		}
		case VR_PRECACHE:
		{
			precache_model ("models/vhshield.md3");
			precache_model ("models/vehicles/yugo.dpm");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_VEHICLE
