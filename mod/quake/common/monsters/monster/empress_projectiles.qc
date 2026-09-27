#include "empress_projectiles.qh"

#include "empress.qh"

#ifdef SVQC
const int PROJ_FRIENDLY = BIT(0);
const int PROJ_HOSTILE = BIT(1);

.float timeleft;

vector vec_smoothstep(vector v1, vector v2, float amount)
{
	amount = bound(0, amount, 1);

	float smooth_t = (amount * amount) * (3 - (2 * amount));

	vector result;
	result.x = v1.x + smooth_t * (v2.x - v1.x);
	result.y = v1.y + smooth_t * (v2.y - v1.y);
	result.z = v1.z + smooth_t * (v2.z - v1.z);

	return result;
}

void empress_projectile_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(this.clipgroup && this.clipgroup == toucher.clipgroup)
		return;
	if(time < toucher.hurt_antispam)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this.owner || toucher.owner == this)
		return;

	toucher.hurt_antispam = time + 0.25; // no spam please

	float damage = (this.dmg) ? this.dmg : 50;
	
	T_Damage(toucher, this, this.owner, damage, DEATH_MONSTER_EMPRESS.m_id);
}

void empress_projectile_touchframe(entity this)
{
	vector emin = this.origin - this.size, emax = this.origin + this.size;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			empress_projectile_touch(this, it);
	});
}

void empress_rainbowstreak_think(entity this)
{
	this.nextthink = time + PHYS_TICKRATE;

	float num = 140;
	float num2 = 20;
	float home_speed = 30 * PHYS_SCALE;
	bool dospin = false;
	bool dohome = false;
	float maxrange = 800;
	float lerpval = 0.05;
	float lerpscale = 0.1;

	if(this.timeleft > num)
		dospin = true;
	else if(this.timeleft > num2)
		dohome = true;

	if(dospin)
	{
		int whoami = num_for_edict(this);
		float val_div = whoami / 6;
		float fraction = val_div - floor(val_div);

		float radians = fraction + (this.origin_x / 320) + (this.origin_z / 160);
		float degrees = radians * 57.29578;

		float wave = cos(degrees);

		vector dir = normalize(this.velocity);
		float bspeed = vlen(this.velocity);
		vector wave_vel = dir * (bspeed * wave);

		float rotation = wave * 1.5;

		this.velocity = rotated_by(wave_vel, rotation, '0 0 0');
	}

	if(this.state & PROJ_FRIENDLY)
	{
		if(this.enemy && (this.enemy.health < 1 || this.enemy.flags & FL_NOTARGET))
			this.enemy = NULL;

		if(!this.enemy)
			this.enemy = W_PickNearbyTarget(this, this.owner, maxrange, false, false);
	}

	if(dohome)
	{
		vector vel = this.velocity;
		if((this.state & PROJ_HOSTILE) && this.enemy)
			vel = direction_to(this.origin, CENTER_OR_VIEWOFS(this.enemy)) * home_speed;

		if(this.state & PROJ_FRIENDLY)
		{
			if(this.enemy)
			{
				if(this.timeleft < 10)
					this.timeleft = 10;

				vel = direction_to(this.origin, CENTER_OR_VIEWOFS(this.enemy)) * home_speed;
			}
			else
				this.timeleft--;
		}

		float amount = empress_lerpf(lerpval, lerpscale, empress_lerp_clamped(num, 30 * PHYS_SCALE, this.timeleft, true));
		this.velocity = vec_smoothstep(this.velocity, vel, amount);
	}

	this.fade_time = time + (empress_lerp_clamped(240, 220, this.timeleft, true) / 60);
	this.fade_rate = 1;

	this.timeleft -= 1;

	if(this.timeleft <= 0)
	{
		delete(this);
		return;
	}

	empress_projectile_touchframe(this);

	UpdateCSQCProjectile(this);
}

void empress_rainbowstreak_create(entity this, vector org, vector vel, entity targ, float damage)
{
	entity newmis = launch_spike(this, org, vel);
	newmis.projectiledeathtype = DEATH_MONSTER_EMPRESS.m_id;
	newmis.dmg = damage;
	newmis.velocity = vel;
	settouch(newmis, func_null);
	setthink(newmis, empress_rainbowstreak_think);
	newmis.nextthink = time + PHYS_TICKRATE;
	newmis.timeleft = 200;
	newmis.solid = SOLID_CORPSE;
	//setsize(newmis, '-30 -30 -30', '30 30 30');
	newmis.state = PROJ_HOSTILE;
	newmis.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	newmis.enemy = targ;
	newmis.size = '30 30 30';

	CSQCProjectile(newmis, false, PROJECTILE_EMPRESS_STREAK, true);
}

void empress_lance_think(entity this)
{
	this.nextthink = time;

	if(time >= this.cnt)
	{
		delete(this);
		return;
	}

	empress_projectile_touchframe(this);
}

void empress_lance_launch(entity this)
{
	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);
	vector org = this.origin;
	vector dir = v_forward;
	entity newmis = launch_spike(this.owner, org, dir);
	newmis.projectiledeathtype = DEATH_MONSTER_EMPRESS.m_id;
	settouch(newmis, func_null);
	set_movetype(newmis, MOVETYPE_NOCLIP);
	newmis.dmg = this.dmg;
	newmis.velocity = dir * (40 * PHYS_SCALE);
	newmis.cnt = time + 2.5;
	setthink(newmis, empress_lance_think);
	newmis.nextthink = time;
	newmis.size = '30 30 30';

	CSQCProjectile(newmis, true, PROJECTILE_EMPRESS_LANCE, false);

	delete(this);
}

void empress_lance_create(entity this, vector org, bool enraged, vector dir, float damage, float timer)
{
	entity newmis = spawn();
	newmis.classname = "lance_pre";
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_NONE);
	_setmodel(newmis, "progs/proj_terraprisma.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setthink(newmis, empress_lance_launch);
	newmis.nextthink = time + 1;
	newmis.dmg = damage;
	setorigin(newmis, org);
	newmis.velocity = '0 0 0';
	newmis.angles = vectoangles(dir);

	vector end = org + dir * 800;

	WriteHeader(MSG_BROADCAST, TE_CSQC_EMPRESS_LANCE_TELEGRAPH);
	WriteVector(MSG_BROADCAST, org);
	WriteVector(MSG_BROADCAST, end);
	WriteByte(MSG_BROADCAST, floor(timer * 255));
	WriteByte(MSG_BROADCAST, enraged);
}

bool aurora_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_EMPRESS_AURORA);
	WriteVector(MSG_ENTITY, this.origin);

	return true;
}

// not actually a projectile
void empress_aurora_create(entity this, vector org)
{
	entity newmis = spawn();
	newmis.classname = "aurora";
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.owner = this;
	newmis.realowner = this;
	newmis.origin = org;
	newmis.velocity = '0 0 0';
	float eff_time = 3.5; // 210 / 60

	Net_LinkEntity(newmis, false, eff_time, aurora_send);
}

void empress_everlasting_think(entity this)
{
	this.nextthink = time + PHYS_TICKRATE;

	this.timeleft -= 1;
	if(this.timeleft <= 0)
	{
		delete(this);
		return;
	}

	float turn_decay = 0.94;
	float speed_accel = 25;
	float vert_lift = 150;

	this.speed += (speed_accel * 0.015625);
	this.lip *= turn_decay;

	vector cur_ang = vectoangles(this.velocity);
	cur_ang.y += this.lip;

	makevectors(cur_ang);
	vector horizontal_vel = v_forward * this.speed;

	this.velocity_x = horizontal_vel.x;
	this.velocity_y = horizontal_vel.y;
	this.velocity_z = sin(time * 2) * vert_lift;

	empress_projectile_touchframe(this);

	UpdateCSQCProjectile(this);
}

void empress_everlasting_create(entity this, vector org, vector vel, entity targ, float damage, float timer)
{
	entity newmis = launch_spike(this, org, vel);
	newmis.projectiledeathtype = DEATH_MONSTER_EMPRESS.m_id;
	newmis.dmg = damage;
	newmis.velocity = vel;
	settouch(newmis, func_null); // we handle it manually
	setthink(newmis, empress_everlasting_think);
	newmis.nextthink = time + PHYS_TICKRATE;
	newmis.timeleft = 660;
	newmis.solid = SOLID_CORPSE;
	//setsize(newmis, '-30 -30 -30', '30 30 30');
	newmis.state = PROJ_HOSTILE;
	newmis.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	newmis.enemy = targ;
	newmis.count = timer;
	newmis.lip = 6; // turn speed
	newmis.speed = vlen(vel); // forward speed
	newmis.size = '30 30 30';

	CSQCProjectile(newmis, false, PROJECTILE_EMPRESS_EVERLASTING, true);
}

bool sundance_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_EMPRESS_SUNDANCE);
	if(this.state)
		sf |= BIT(6);
	else
		sf &= ~BIT(6);

	WriteByte(MSG_ENTITY, sf);

	if(sf & BIT(0))
		WriteByte(MSG_ENTITY, floor(this.lip * 255));
	if(sf & BIT(1))
		WriteVector(MSG_ENTITY, this.origin);
	if(sf & BIT(2))
		WriteAngleVector(MSG_ENTITY, this.angles);

	return true;
}

vector sundance_rotate(entity this)
{
	float age = time - this.spawntime;
	float total_lifetime = this.cnt - this.spawntime;
	float tick_age = age * 60;

	float fade_in = bound(0, tick_age / 20, 1);

	float frames_remaining = (total_lifetime - age) * 60;
	float fade_out = bound(0, frames_remaining / 60, 1);

	float current_scale = fade_in * fade_out;
	this.scale = current_scale;

	float rotation_speed_per_frame = 35 * 0.015625;
	float rad_turn = rotation_speed_per_frame * 0.01745329;

	vector old_dir = this.movedir;
	vector new_dir;
	new_dir.x = old_dir.x * cos(rad_turn) - old_dir.y * sin(rad_turn);
	new_dir.y = old_dir.x * sin(rad_turn) + old_dir.y * cos(rad_turn);
	new_dir.z = old_dir.z;

	return new_dir;
}

void empress_sundance_think(entity this)
{
	this.nextthink = time + PHYS_TICKRATE;

	if(time >= this.cnt)
	{
		delete(this);
		return;
	}
	
	vector oldang = this.angles;
	vector dir = sundance_rotate(this); // sets scale too!
	this.movedir = normalize(dir);
	this.angles = vectoangles(dir);
	if(this.angles != oldang)
		this.SendFlags |= BIT(2);

	if(this.owner)
	{
		vector org = CENTER_OR_VIEWOFS(this.owner);
		if(org != this.origin)
		{
			setorigin(this, org);
			this.SendFlags |= BIT(1);
		}
	}

	float age = time - this.spawntime;
	float fade_in = bound(0, age * 0.33, 1);

	float arange = 500 * fade_in;
	vector endpoint = this.origin + (this.movedir * arange);
	float mysize = 112 * this.scale;

	//te_lightning2(NULL, this.origin, endpoint);

	tracebox(this.origin, '-1 -1 -1' * mysize, '1 1 1' * mysize, endpoint, MOVE_NORMAL, this.owner);

	if(trace_ent.takedamage && time >= trace_ent.hurt_antispam)
	{
		trace_ent.hurt_antispam = time + 0.5;
		T_Damage(trace_ent, this, this.owner, this.dmg, this.projectiledeathtype);
	}
}

void empress_sundance_create(entity this, vector org, vector dir, float damage, float timer, bool enraged)
{
	entity newmis = spawn();
	newmis.classname = "sundance";
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.owner = this;
	newmis.realowner = this;
	newmis.origin = org;
	newmis.velocity = '0 0 0';
	newmis.dmg = damage;
	newmis.lip = timer;
	newmis.cnt = time + 3;
	newmis.spawntime = time;
	newmis.state = enraged;
	setthink(newmis, empress_sundance_think);
	newmis.nextthink = time + PHYS_TICKRATE;
	newmis.movedir = dir;
	newmis.projectiledeathtype = DEATH_MONSTER_EMPRESS.m_id;

	Net_LinkEntity(newmis, false, 0, sundance_send);

	_sound(newmis, CH_SHOTS, "empress/star.wav", 1, ATTN_BOSS);
}
#endif

#ifdef CSQC
PRECACHE(Empress_Projectiles)
{
	precache_pic("particles/empress_aurora");
}
.vector vorg1, vorg2;

void lance_telegraph_draw(entity this)
{
	vector start_pos = this.vorg1;
	vector end_pos = this.vorg2;
	float spawn_timestamp = this.spawntime;
	float server_hue_seed = this.count;

	float telegraph_time = 1;
	float age = time - spawn_timestamp;

	if(age < 0 || age >= telegraph_time)
		return;

	float current_alpha = 1;
	if(age < 0.1) 
		current_alpha = age / 0.1;

	vector laser_rgb;

	if(this.cnt)
	{
		float lerp_value = bound(0, age / 1, 1); 

		vector col_white = '1 1 1';
		vector fav_col = '1 0.905 0.27';

		laser_rgb = col_white + (lerp_value * (fav_col - col_white));
	}
	else
	{
		float dynamic_time_scroll = time * 0.02;
		float final_hue = server_hue_seed + dynamic_time_scroll;
		final_hue = final_hue - floor(final_hue);

		laser_rgb = hsl_to_rgb(vec3(final_hue * 360, 1, 0.5));
	}

	float beam_pulse = sin(time * 60 * 57.29578) * 3 + 6;
#if 0
	vector beam_right = view_right * beam_pulse;

	R_BeginPolygon("", DRAWFLAG_ADDITIVE);
	R_PolygonVertex(start_pos - beam_right, '0 1 0', laser_rgb, 0.4 * current_alpha);
	R_PolygonVertex(end_pos - beam_right, '0 0 0', laser_rgb, 0.4 * current_alpha);
	R_PolygonVertex(end_pos + beam_right, '1 0 0', laser_rgb, 0.4 * current_alpha);
	R_PolygonVertex(start_pos + beam_right, '1 1 0', laser_rgb, 0.4 * current_alpha);
	R_EndPolygon();
#endif

	Draw_CylindricLine(start_pos, end_pos, beam_pulse, "", 0.25, 0, laser_rgb, 0.4 * current_alpha, DRAWFLAG_NORMAL, view_origin);
}

NET_HANDLE(TE_CSQC_EMPRESS_LANCE_TELEGRAPH, bool isNew)
{
	Net_Accept(lance_telegraph);
	setthink(this, SUB_Remove);
	this.nextthink = time + 1;
	vector start = ReadVector();
	vector end = ReadVector();
	float timer = ReadByte() / 255;
	bool should_enrage = ReadByte();

	this.count = timer;
	this.spawntime = time;
	this.vorg1 = start;
	this.vorg2 = end;
	this.cnt = should_enrage;
	this.draw = lance_telegraph_draw;
	if(isNew && !IL_CONTAINS(g_drawables, this))
		IL_PUSH(g_drawables, this);
	return true;
}

void DrawAurora(vector org, float angle_offset, float cur_time, vector rgb)
{
	float eff_time = 3.5;
	float fade_time = 1;

	float elapsed_time = time - cur_time;
	float seconds_left = eff_time - elapsed_time;

	if(elapsed_time < 0 || seconds_left < 0)
		return;

	float fade_in = elapsed_time / fade_time;
	if(fade_in > 1)
		fade_in = 1;

	float fade_out = seconds_left / fade_time;
	if(fade_out > 1)
		fade_out = 1;

	float dynamic_alpha = fade_in * fade_out;

	float rad = 170;       
	float swirl_speed = 45;   
	float width = 256;  
	float height = 1200;

	float current_angle = (time * swirl_speed) + angle_offset;
	float rad_angle = current_angle * 0.01745329; 

	vector spawn_pos = org;
	spawn_pos.x = spawn_pos.x + (cos(rad_angle) * rad);
	spawn_pos.y = spawn_pos.y + (sin(rad_angle) * rad);

	vector tangent_dir = '0 0 0';
	tangent_dir.x = -sin(rad_angle);
	tangent_dir.y = cos(rad_angle);

	vector slanted_up = ('0 0 1' * 0.866025) + (tangent_dir * 0.5);
	vector up_step = slanted_up * height;

	vector right_step = view_right * (width * 0.5);

	R_BeginPolygon("particles/empress_aurora", DRAWFLAG_ADDITIVE);

	vector pos_bl = spawn_pos - right_step;
	R_PolygonVertex(pos_bl, '0 1 0', rgb, 1 * dynamic_alpha); 

	vector pos_tl = pos_bl + up_step;
	R_PolygonVertex(pos_tl, '0 0 0', rgb, 0);

	vector pos_tr = (spawn_pos + right_step) + up_step;
	R_PolygonVertex(pos_tr, '1 0 0', rgb, 0);

	vector pos_br = spawn_pos + right_step;
	R_PolygonVertex(pos_br, '1 1 0', rgb, 1 * dynamic_alpha);

	R_EndPolygon();
}

void aurora_draw(entity this)
{
	int max_strips = 14;

	for(int j = 0; j < max_strips; ++j)
	{
		float angle_offset = (j / max_strips) * 360;

		float hue_step = (j / max_strips) + (time * 0.01);
		hue_step = hue_step - floor(hue_step);
		vector strip_color = hsl_to_rgb(vec3(hue_step * 360, 1, 0.5));

		// Draw the slanted orbiting strip
		DrawAurora(this.origin, angle_offset, this.spawntime, strip_color);
	}
}

NET_HANDLE(ENT_CLIENT_EMPRESS_AURORA, bool isNew)
{
	vector org = ReadVector();

	//this.cnt = time + 3.5; // 210 / 60
	this.spawntime = time;
	this.origin = org;
	this.draw = aurora_draw;
	if(isNew && !IL_CONTAINS(g_drawables, this))
		IL_PUSH(g_drawables, this);
	return true;
}

void sundance_light(entity this, float thescale)
{
	float seed_fraction = (this.count) ? this.count / 360 : 0;
	float time_scroll = time * 0.05; 

	float final_hue = seed_fraction + time_scroll;
	final_hue = final_hue - floor(final_hue);

	vector light_rgb = hsl_to_rgb(vec3(final_hue * 360, 1, 0.85));

	float dynamic_radius = (sin(time * 300) * 50 + 350) * thescale;

	adddynamiclight(this.origin, dynamic_radius, light_rgb);
}

void draw_spike(vector base_origin, vector len_step, vector r_vec, vector u_vec, vector rgb, float alpha_mod)
{
	float secure_alpha = alpha_mod * 0.45; 

	R_BeginPolygon("", DRAWFLAG_ADDITIVE);
	R_PolygonVertex(base_origin - r_vec, '0 1 0', rgb, secure_alpha);
	R_PolygonVertex(base_origin + len_step, '0.5 0 0', rgb, 0.0);
	R_PolygonVertex(base_origin + len_step, '0.5 0 0', rgb, 0.0);
	R_PolygonVertex(base_origin + r_vec, '1 1 0', rgb, secure_alpha);
	R_EndPolygon();
}

void sundance_draw(entity this)
{
	float total_time = 3;
	float age = time - this.spawntime; 

	float fade_window = 0.5;
	float drift_start = 0.666;
	float drift_end = 1;

	float fade_in = bound(0, age / fade_window, 1);

	float seconds_remaining = total_time - age;
	float fade_out = bound(0, seconds_remaining / fade_window, 1);

	float global_alpha_scale = fade_in * fade_out;

	float hue_scroll = (this.count) + (age * PHYS_INPUT_FRAMETIME * 0.02);

	float lerp_progress = bound(0, (age - drift_start) / (drift_end - drift_start), 1);
	float scale_width_multiplier = 0.25 + (lerp_progress * (0.7 - 0.25));

	float hue_core = hue_scroll - floor(hue_scroll);
	vector color6 = hsl_to_rgb(vec3(hue_core * 360, 1, 0.45)) * global_alpha_scale;

	float hue_v4 = (hue_scroll + 0.3) - floor(hue_scroll + 0.3);
	float value_v4_light = 0.15 + (lerp_progress * (0.3 - 0.15));
	vector value4 = hsl_to_rgb(vec3(hue_v4 * 360, 1, value_v4_light)) * global_alpha_scale;

	float hue_v5 = (hue_scroll + 0.15) - floor(hue_scroll + 0.15);
	float value_v5_light = 0.15 + (lerp_progress * (0.25 - 0.15));
	vector value5 = hsl_to_rgb(vec3(hue_v5 * 360, 1, value_v5_light)) * global_alpha_scale;

	if(this.state) 
	{
		vector deep_amber = '0.85 0.52 0.05'; 
		value4 = deep_amber * global_alpha_scale;
		value5 = deep_amber * global_alpha_scale;
		color6 = deep_amber * global_alpha_scale;
	}

	makevectors(this.angles);
	vector spike_forward = v_forward;
	vector spike_right = v_right;
	vector spike_up = v_up;

	float base_length = 500 * scale_width_multiplier; 
	float base_width = 132 * scale_width_multiplier;

	vector len_step = spike_forward * base_length;
	vector right_step = spike_right * (base_width * 0.5);
	vector up_step = spike_up * (base_width * 0.5);

	vector base_origin = this.origin - (spike_forward * 16);

	draw_spike(base_origin, len_step, right_step * 1.2, up_step * 1.2, value4, 0.3); 
	draw_spike(base_origin, len_step, up_step * 1.2, right_step * 1.2, value4, 0.3); 

	draw_spike(base_origin, len_step, right_step * 1.1, up_step * 1.1, value5, 0.2);
	draw_spike(base_origin, len_step, up_step * 1.1, right_step * 1.1, value5, 0.2);

	draw_spike(base_origin, len_step, right_step, up_step, color6, 0.4);
	draw_spike(base_origin, len_step, up_step, right_step, color6, 0.4);

	draw_spike(base_origin, len_step, right_step, up_step, color6, lerp_progress * 0.4);
	draw_spike(base_origin, len_step, up_step, right_step, color6, lerp_progress * 0.4);

	sundance_light(this, scale_width_multiplier);
}

NET_HANDLE(ENT_CLIENT_EMPRESS_SUNDANCE, bool isNew)
{
	int sf = ReadByte();

	if(sf & BIT(0))
		this.count = ReadByte() / 255;

	if(sf & BIT(1))
	{
		vector org = ReadVector();
		setorigin(this, org);
	}

	if(sf & BIT(2))
		this.angles = ReadAngleVector();

	this.state = (sf & BIT(6)); // enraged

	this.draw = sundance_draw;
	if(isNew && !IL_CONTAINS(g_drawables, this))
	{
		this.spawntime = time;
		IL_PUSH(g_drawables, this);
	}
	return true;
}
#endif
