#include "empress.qh"

REGISTER_NET_TEMP(empress_gibsplash)

#ifdef GAMEQC
float empress_lerpf(float start, float end, float t)
{
	t = bound(0, t, 1);

	return start + (end - start) * t;
}

vector empress_lerpv(vector from, vector to, float amount)
{
	return vec3(
		empress_lerpf(from.x, to.x, amount),
		empress_lerpf(from.y, to.y, amount),
		empress_lerpf(from.z, to.z, amount));
}

float empress_lerp_clamped(float from, float to, float t, bool clamped)
{
	if(clamped)
	{
		if(from < 2)
		{
			if(to < from)
				return 0;
			if(t > to)
				return 1;
		}
		else
		{
			if(t < to)
				return 1;
			if(t > from)
				return 0;
		}
	}

	return (t - from) / (to - from);
}
#endif

#ifdef SVQC
.int bosswave;
.float anim_finished;

void empress_anim(entity this)
{
	if(time < this.anim_finished)
		return;
	this.anim_finished = time + FRAME_TIME;

	this.walkframe += 1;
	if(this.walkframe > 5)
		this.walkframe = 0;
	this.frame = this.walkframe;
}

void empress_touch(entity this, entity toucher)
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

	toucher.hurt_antispam = time + 0.5; // no spam please

	float damage = 20 + (random() * 4) + (random() * 2);
	if(this.bosswave >= 1)
		damage *= 2;
	if(empress_shouldenrage(this))
		damage = 9999;
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_EMPRESS.m_id);
}

void empress_touchframe(entity this)
{
	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			empress_touch(this, it);
	});
}

// NOTE: requires makevectors
vector vec2_3d(vector input)
{
	// in 2 dimensional space, the coordinates are as such:
	// Y -1: up
	// Y 1: down
	// X -1: left
	// X 1: right

	// since 3d space doesn't have a left and right (relatively)
	// we assume forward is right
	// and flip the vertical axis

	vector output = v_forward * -input.x + v_up * -input.y;
	return output;
}

vector rotated_by(vector point, float radians, vector center)
{
	vector diff = point - center;
	float xscale = cos(radians);
	float yscale = sin(radians);
	vector result;
	result.x = center.x + (diff.x * xscale - diff.y * yscale);
	result.y = center.y + (diff.x * yscale + diff.y * xscale);
	result.z = center.z + diff.z;
	return result;
}

int to_direction(bool is_forward)
{
	return (is_forward) ? 1 : -1;
}

vector direction_to(vector org, vector to)
{
	return normalize(to - org);
}

vector direction_from(vector org, vector to)
{
	return normalize(org - to);
}

void empress_dash(entity this, vector targ_org)
{
	targ_org += vec2_3d('0 -300 0');
	if(vdist(this.origin - targ_org, >, 200 * PHYS_SCALE))
		targ_org -= direction_to(this.origin, targ_org) * (100 * PHYS_SCALE);

	vector to_target = targ_org - CENTER_OR_VIEWOFS(this);
	float len = vlen(to_target);
	float lerpval = empress_lerp_clamped(100 * PHYS_SCALE, 600 * PHYS_SCALE, len, true);
	float speed_cap = 18 * PHYS_SCALE;
	if(len > speed_cap)
		len = speed_cap;

	vector norm_dir = normalize(to_target);
	vector near_velocity = norm_dir * len;
	vector far_velocity = to_target * (1 / 6);

	this.velocity = empress_lerpv(near_velocity, far_velocity, lerpval);
}

.int empress_ai[4];

int empress_pickstate_phase1(entity this, int current_state, int next_state)
{
	int counter = 0;

	int c1 = counter++;
	int c2 = counter++;
	int c3 = counter++;
	int c4 = counter++;
	int c5 = counter++;
	int c6 = counter++;
	int c7 = counter++;
	int c8 = counter++;
	int c9 = counter++;
	int c10 = counter++;

	int remainder = (current_state % counter);

	if(remainder == c1)
		next_state = 2;
	else if(remainder == c2)
		next_state = 8;
	else if(remainder == c3)
		next_state = 6;
	else if(remainder == c4)
		next_state = 8;
	else if(remainder == c5)
		next_state = 5;
	else if(remainder == c6)
		next_state = 2;
	else if(remainder == c7)
		next_state = 8;
	else if(remainder == c8)
		next_state = 4;
	else if(remainder == c9)
		next_state = 8;
	else if(remainder == c10)
		next_state = 5;

	if(this.health <= (this.max_health * 0.5))
		next_state = 10;

	return next_state;
}

int empress_pickstate_phase2(entity this, int current_state, int next_state)
{
	int counter = 0;

	int c1 = counter++;
	int c2 = counter++;
	int c3 = counter++;
	int c4 = -1;
	if(autocvar_skill >= 2)
		c4 = counter++;
	int c5 = counter++;
	int c6 = counter++;
	int c7 = counter++;
	int c8 = counter++;
	int c9 = counter++;
	int c10 = counter++;

	int remainder = (current_state % counter);

	if(remainder == c1)
		next_state = 7;
	else if(remainder == c2)
		next_state = 2;
	else if(remainder == c3)
		next_state = 8;
	else if(remainder == c4)
		next_state = 5;
	else if(remainder == c5)
		next_state = 2;
	else if(remainder == c6)
		next_state = 6;
	else if(remainder == c7)
		next_state = 4;
	else if(remainder == c8)
		next_state = 8;
	else if(remainder == c9)
		next_state = 11;
	else if(remainder == c10)
		next_state = 12;

	return next_state;
}

float empress_accelerate(float vel, float desired, float movespeed)
{
	if(vel < desired)
	{
		vel += movespeed;
		if(vel < 0 && desired > 0)
			vel += movespeed;
	}
	else if(vel > desired)
	{
		vel -= movespeed;
		if(vel > 0 && desired < 0)
			vel -= movespeed;
	}
	return vel;
}

void empress_face(entity this)
{
	if(!this.enemy)
		return;

	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(this.enemy);
	vector ideal = vectoangles(normalize(targorg - myorg));

	this.angles_y = anglemods(ideal.y);
	this.angles_x = anglemods(ideal.x);
}

void empress_fly(entity this, vector desired, float movespeed)
{
	//movespeed *= PHYS_INPUT_TIMELENGTH;

	this.velocity_x = empress_accelerate(this.velocity_x, desired.x, movespeed);
	this.velocity_y = empress_accelerate(this.velocity_y, desired.y, movespeed);
	this.velocity_z = empress_accelerate(this.velocity_z, desired.z, movespeed);
}

vector empress_crossvel(int j, float progress)
{
	float angle_degrees = (360 * (j / 4)) + 45;

	// 2. Setup the angle vector for the engine's rotation matrix
	vector angle_vector = '0 0 0';
	angle_vector.y = angle_degrees; // Assign to Yaw axis for horizontal expansion

	vector forward = v_forward;
	vector right = v_right;
	vector up = v_up;

	// 3. Terraria: .ToRotationVector2()
	// Generates a safe normalized unit vector in that direction
	makevectors(angle_vector);
	vector dir_vector = v_forward;

	v_forward = forward;
	right = v_right;
	up = v_up;

	float speed_decay = 1 - progress;
	if(speed_decay < 0)
		speed_decay = 0;
	if(speed_decay > 1)
		speed_decay = 1;

	float current_speed = 240 * speed_decay;

	return dir_vector * current_speed;
}

vector vec_circular_edge(float halfwidth, float halfheight)
{
	float rang = prandom() * 360;

	vector angle_vector = '0 0 0';
	angle_vector.y = rang;

	vector forward = v_forward;
	vector right = v_right;
	vector up = v_up;

	// 3. Terraria: .ToRotationVector2()
	// Generates a safe normalized unit vector in that direction
	makevectors(angle_vector);
	vector unit = v_forward;

	v_forward = forward;
	right = v_right;
	up = v_up;

	vector final;
	final.x = unit.x * halfwidth;
	final.y = unit.y * halfheight;
	final.z = 0;
	return final;
}

vector vec_circular(float halfwidth, float halfheight)
{
	float random_angle = prandom() * 360.0;

	vector angle_vector = '0 0 0';
	angle_vector.y = random_angle;

	vector forward = v_forward;
	vector right = v_right;
	vector up = v_up;

	makevectors(angle_vector);
	vector unit_vector = v_forward;

	v_forward = forward;
	right = v_right;
	up = v_up;

	float rscale = prandom();

	vector final;
	final.x = unit_vector.x * halfwidth * rscale;
	final.y = unit_vector.y * halfheight * rscale;
	final.z = 0;

	return final;
}

void empress_magic(entity this, vector spot, int etype, float progress)
{
	float rscale = 4;
	float velscale = 1;
	float rpos = 0.5;
	float dcount = 2;

	switch(etype)
	{
		case 1:
		{
			velscale = 0.5;
			rpos = 0;
			break;
		}
		case 2:
		case 4:
		{
			rscale = 50;
			velscale = 0.5;
			rpos = 0;
			dcount = 4;
			break;
		}
		case 3:
		{
			rscale = 30;
			velscale = 0.1;
			rpos = 0;
			break;
		}
		case 5:
		{
			if(progress == 0)
				dcount = 0;
			else
			{
				dcount = 5;
			}
			if(progress >= 1)
				dcount = 0;
			break;
		}
	}

	for(int j = 0; j < dcount; ++j)
	{
		vector org = spot + v_forward * (prandom() * (5 - 4) + 4) + v_up * (prandom() * (5 - 4) + 4);
		vector vel = vec_circular_edge(rscale, rscale) * (prandom() * (1 - rpos) + rpos);
		float amount = (prandom() * 2 + 2) * velscale;

		switch(etype)
		{
			case 2:
			case 4:
			{
				vel *= 0.005;
				vel = empress_crossvel(j, progress) * PHYS_SCALE;
				vel += this.velocity * 0.3;
				break;
			}
			case 5:
			{
				if(progress == 0)
				{
					vel = vec2_3d('0 -1 0') + vec_circular(1, 1);
					vel *= PHYS_SCALE;
				}
				else
				{
					vel *= 3;
					vel.x *= 0.1;
					vel.y *= 0.1;
					vel += this.velocity * 1;
				}
			}
		}

		particle(org, vel, 133, amount);
	}
}

vector vec_matrix(int index, float amount)
{
	float rotx = ((amount - 0.3) + (index * 0.1)) * 0.7 * 360.0;
	float roty = ((amount - 0.8) + (index * 0.3)) * 0.7 * 360.0;
	float rotz = (amount + (index * 0.5)) * 0.1 * 360.0;

	vector combined_angles;
	combined_angles.x = rotx;
	combined_angles.y = roty;
	combined_angles.z = rotz;

	vector forward = v_forward;
	vector right = v_right;
	vector up = v_up;

	makevectors(combined_angles);
	vector result = v_forward;

	v_forward = forward;
	right = v_right;
	up = v_up;

	return result;
}

void empress_clone(entity this, vector org, vector col, float alph)
{
	entity clone = spawn();
	clone.classname = "empress_clone";
	set_movetype(clone, MOVETYPE_NONE);
	clone.model = this.model;
	clone.modelindex = this.modelindex;
	clone.frame = this.frame;
	clone.alpha = alph;
	clone.solid = SOLID_NOT;
	clone.effects |= EF_ADDITIVE;
	clone.effects |= EF_FULLBRIGHT;
	clone.colormod = col;
	clone.angles = this.angles;
	clone.skin = this.skin;
	clone.colormap = this.colormap;
	SUB_SetFade(clone, time, 0.5);

	setorigin(clone, org);
	setsize(clone, this.mins, this.maxs);
}

// server side drawing... TODO!!
void empress_draw(entity this)
{
	// throttled so we don't overload the server TODO: client side
	if(time < this.idle_finished)
		return;
	this.idle_finished = time + FRAME_TIME;

	vector my_center = CENTER_OR_VIEWOFS(this);
	int current_state = this.empress_ai[0];

	float colorscale = 1;
	int clones_max = 0;
	int clone_count = 0;
	float off1 = 0;
	float off2 = 0;
	float off3 = 0;

	if(current_state == 8 || current_state == 9)
	{
		off1 = empress_lerp_clamped(0, 30, this.empress_ai[1], true) * empress_lerp_clamped(90, 30, this.empress_ai[1], true);
		off2 = empress_lerp_clamped(0, 30, this.empress_ai[1], true) * empress_lerp_clamped(90, 70, this.empress_ai[1], true);
		off3 = empress_lerp_clamped(0, 15, this.empress_ai[1], true) * empress_lerp_clamped(45, 30, this.empress_ai[1], true);
		colorscale *= 1 - off3;
		clones_max = 4;
		clone_count = 3;
	}
	else if(current_state == 10)
	{
		off1 = empress_lerp_clamped(30, 90, this.empress_ai[1], true) * empress_lerp_clamped(165, 90, this.empress_ai[1], true);
		off2 = empress_lerp_clamped(0, 60, this.empress_ai[1], true) * empress_lerp_clamped(180, 120, this.empress_ai[1], true);
		off3 = empress_lerp_clamped(0, 60, this.empress_ai[1], true) * empress_lerp_clamped(180, 120, this.empress_ai[1], true);
		colorscale *= 1 - off3;
		clone_count = 4;
	}

	if(clones_max + clone_count > 0)
	{
		for(int j = -clones_max; j <= clones_max + clone_count; ++j)
		{
			if(j == 0)
				continue;
			vector col = '1 1 1';
			float alph = 1;
			vector position = my_center;
			if(current_state == 8 || current_state == 9)
			{
				float hue = (j + 5) / 10;
				float amount = 200;
				vector rot = vec_matrix(j, time);
				amount += empress_lerp_clamped(90, 0, this.empress_ai[1], true);
				vector spinningpoint = rot * amount * off1;
				float lerpval = empress_lerp_clamped(90, 0, this.empress_ai[1], true);
				col = hsl_to_rgb(vec3(hue, 1, empress_lerpf(0.5, 1, lerpval))) * 0.8 * off2;
				alph /= 3;
				position += rotated_by(spinningpoint, this.empress_ai[1] / 180 * (M_PI * 2), '0 0 0');
			}
			else if(current_state == 10)
			{
				if(this.empress_ai[1] >= 90)
				{
					int counter = j;
					if(counter < 0)
						counter++;

					float angle_degrees = ((counter + 0.5) * 45) + (360 * time);
					vector angle_vector = '0 0 0';
					angle_vector.y = angle_degrees;

					vector forward = v_forward;
					vector right = v_right;
					vector up = v_up;

					// 3. Terraria: .ToRotationVector2()
					// Generates a safe normalized unit vector in that direction
					makevectors(angle_vector);
					vector dir_vector = v_forward;

					v_forward = forward;
					right = v_right;
					up = v_up;

					vector vec = dir_vector;
					vector offset = vec2_3d(vec2(600 * off1, 150 * off1));
					vec.x *= offset.x;
					vec.y *= offset.y;
					vec.z *= offset.z;
					position += vec;
				}
				else
					position += 200 * vec2_3d('1 0 0' * j) * off1;

				col = '1 1 1' * 0.8 * off2 * colorscale;
				alph /= 3;
			}

			if(j > clones_max)
			{
				float lerpval2 = empress_lerp_clamped(30, 70, this.empress_ai[1], true);
				if(lerpval2 == 0)
					continue;

				position = my_center + this.velocity * -3 * (j - 4) * lerpval2;
				col *= 1 - off3;
			}

			empress_clone(this, position, col, alph);
		}
	}
}

bool empress_isphase2(entity this)
{
	if(this.bosswave != 1)
		return (this.bosswave == 3);
	return true;
}

bool empress_isenraged(entity this)
{
	if(this.bosswave != 2)
		return (this.bosswave == 3);
	return true;
}

bool autocvar_sv_quake_empress_enraged;
bool empress_shouldenrage(entity this)
{
	return (autocvar_sv_quake_empress_enraged);
}

void empress_ai_think(entity this)
{
	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	vector my_center = CENTER_OR_VIEWOFS(this);

	float base_speed = 12 * PHYS_SCALE;
	float min_dist = 40;
	float speed_scale = 0.5 * PHYS_SCALE;

	float pstreak_damage = 45;
	float pstrike_damage = 50;
	float psundance_damage = 50;
	float peverlasting_damage = 40;

	float maxrange = 6400;

	bool is_phase2 = empress_isphase2(this);
	bool is_expert = (autocvar_skill >= 2);
	bool is_expert_phase2 = (is_phase2 && is_expert);
	bool should_enrage = empress_shouldenrage(this);

	if(this.health >= this.max_health && should_enrage && !empress_isenraged(this))
		this.bosswave += 2;

	float skillscale = 0;
	if(is_phase2)
	{
		skillscale += 15;
		pstreak_damage = 50;
		psundance_damage = 60;
		peverlasting_damage = 50;
	}
	if(is_expert)
		skillscale += 5;

	if(should_enrage)
	{
		pstreak_damage = 9999;
		pstrike_damage = 9999;
		psundance_damage = 9999;
		peverlasting_damage = 9999;
	}

	//if(this.empress_ai[1] == 0)
		//LOG_INFO("Current state: ", ftos(this.empress_ai[0]));

	switch(this.empress_ai[0])
	{
		case 0: // appear
		{
			if(this.empress_ai[1] == 0)
			{
				this.velocity = vec2_3d('0 5 0') * PHYS_SCALE;
				empress_aurora_create(this, my_center + vec2_3d('0 -80 0'));
			}
			else if(this.empress_ai[1] == 10)
				_sound(this, CH_VOICE, "empress/appear.wav", 1, ATTN_BOSS);
			this.velocity *= 0.95;
			if(this.empress_ai[1] > 10 && this.empress_ai[1] < 150)
			{
				for(int j = 0; j < 2; ++j)
				{
					vector offset = vec_circular((30 * 3) * PHYS_SCALE, (30 * 3) * PHYS_SCALE) + vec2_3d('0 -150 0');
					offset.x *= crandom();
					offset.y *= crandom();
					offset.z *= crandom();
					vector org = my_center + offset;
					vector vel = randomvec() * 0.8;
					vel.z -= 3;
					vel *= PHYS_SCALE;

					particle(org, vel, 133, 4);
				}
			}
			this.empress_ai[1] += 1;
			this.alpha = bound(0, this.empress_ai[1] / 180, 1);
			if(this.empress_ai[1] >= 180)
			{
				if(should_enrage && !empress_isenraged(this))
					this.bosswave += 2;

				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
				boss_FindTarget(this);
			}
			break;
		}
		case 1: // main loop, picks next attack
		{
			float aframe = (this.bosswave > 0) ? 20 : 45;

			if(this.empress_ai[1] <= 10)
			{
				// check for targets at the start of each move
				if(this.empress_ai[1] == 0)
				{
					boss_FindTarget(this);
					empress_face(this);
				}

				if(!this.enemy || this.enemy.health < 1)
				{
					// return to target search frame
					this.empress_ai[0] = 13;
					this.empress_ai[1] = 0;
					this.empress_ai[2] += 1;
					this.velocity *= 0.25; // divide by 4
					break;
				}

				vector center = CENTER_OR_VIEWOFS(this.enemy);
				empress_dash(this, center);
			}

			if(vdist(this.velocity, >, 16 * PHYS_SCALE) && this.empress_ai[1] > 10)
				this.velocity *= 0.5; // divide by 2

			this.velocity *= 0.92;
			this.empress_ai[1] += 1;
			if(!(this.empress_ai[1] >= aframe))
				break;

			int current_state = this.empress_ai[2];
			int next_state = 2;
			if(this.bosswave == 0)
				next_state = empress_pickstate_phase1(this, current_state, next_state);
			else
				next_state = empress_pickstate_phase2(this, current_state, next_state);

			boss_FindTarget(this);

			// NOTE: there's an enraged check here, it's just a despawn check!

			if(!this.enemy || this.enemy.health < 1 || vdist(this.enemy.origin - this.origin, >, maxrange))
				next_state = 13; // return to searching for a target

			// NOTE: the original does a direction check, but we're always facing anyway
			if(next_state == 8)
				next_state = 9;

			if(is_expert && next_state != 5 && next_state != 12)
			{
				vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
				vector raw_dir = this.origin - targ_org;
				vector norm_dir = normalize(raw_dir);
				vector to_target = targ_org - this.origin;
				float current_distance = vlen(raw_dir);

				float dir_mult = 1;
				if((to_target * v_right) < 0)
					dir_mult = -1;

				float final_radians = 1.570796 * dir_mult;

				vector rotated_dir = rotated_by(norm_dir, final_radians, '0 0 0');

				vector corrected = '0 0 0';
				if(current_distance > 400)
					corrected = norm_dir * -10;
				else if(current_distance < (400 - 50))
					corrected = norm_dir;

				vector final = (rotated_dir * 0.8) + (corrected * 0.4);

				if(vdist(final, <=, 0))
					final = rotated_dir;
				final = normalize(final);

				this.velocity = final * (20 * PHYS_SCALE);
			}

			this.empress_ai[0] = next_state;
			this.empress_ai[1] = 0;
			this.empress_ai[2] += 1;
			break;
		}
		case 2: // dodges and fires homing rainbow shots
		{
			if(this.empress_ai[1] == 0)
				_sound(this, CH_VOICE, "empress/rapidfire.wav", 1, ATTN_BOSS);
			
			float sscale = 90 - skillscale;
			vector offset = vec2_3d('-55 -30 0');
			vector offset2 = vec2_3d('-150 -250 0');
			vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);

			empress_face(this);

			vector destination = targ_org + offset2;
			if(vdist(this.origin - destination, >, min_dist))
				empress_fly(this, direction_to(this.origin, destination) * base_speed, speed_scale);

			if(this.empress_ai[1] < 60)
				empress_magic(this, my_center + offset, 1, empress_lerp_clamped(0, 60, this.empress_ai[1], true));

			float next_shot = 3;
			if(is_expert)
				next_shot = 2;

			if((this.empress_ai[1] % next_shot) == 0 && this.empress_ai[1] < 60)
			{
				//float ai3 = this.empress_ai[1] / 60;
				vector shotvel = rotated_by(vec2_3d('0 -6 0'), M_PI / 2 * (prandom() * 2 - 1), '0 0 0') * PHYS_SCALE;
				if(is_expert_phase2)
					shotvel = rotated_by(vec2_3d('0 -10 0'), M_PI * 2 * prandom(), '0 0 0') * PHYS_SCALE;

				empress_rainbowstreak_create(this, my_center + offset, shotvel, this.enemy, pstreak_damage, should_enrage);
			}
			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 60 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 3: // secondary spawn? not sure!
		{
			this.empress_ai[1] += 1;
			vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
			vector offset = vec2_3d('150 -250 0');
			empress_face(this);
			vector destination = targ_org + offset;
			if(vdist(this.origin - destination, >, min_dist))
				empress_fly(this, direction_to(this.origin, destination) * base_speed, speed_scale);

			if((this.empress_ai[1] % 180) == 0)
			{
				vector org = targ_org + vec2_3d('0 -100 0');

				empress_aurora_create(this, org);
			}

			if(this.empress_ai[1] >= 120)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 4: // horizontal lance
		{
			float sscale = 20 - skillscale;

			if(this.empress_ai[1] == 0)
				_sound(this, CH_VOICE, "empress/bigblast.wav", 1, ATTN_BOSS);

			if(this.empress_ai[1] >= 6 && this.empress_ai[1] < 54)
			{
				empress_magic(this, my_center + vec2_3d('-55 -20 0'), 2, empress_lerp_clamped(0, 100, this.empress_ai[1], true));
				empress_magic(this, my_center + vec2_3d('55 -20 0'), 4, empress_lerp_clamped(0, 100, this.empress_ai[1], true));
			}

			vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
			vector offset = vec2_3d('0 -350 0');
			empress_face(this);
			vector destination = targ_org + offset;
			if(vdist(this.origin - destination, >, min_dist))
				empress_fly(this, direction_to(this.origin, destination) * base_speed, speed_scale);

			int next_state = 4;
			if(is_expert)
				next_state = 5;

			if((this.empress_ai[1] % 4) == 0 && this.empress_ai[1] < 100)
			{
				for(int j = 0; j < 1; ++j)
				{
					float rotamount = floor(this.empress_ai[1] / 4);

					if(vdist(this.origin - targ_org, >, 2400 * PHYS_SCALE))
						continue;

					float lance_deg = 22.5 + (rotamount * 45);

					vector ang = '0 0 0';
					ang.y = lance_deg;

					vector forward = v_forward;
					vector right = v_right;
					vector up = v_up;

					makevectors(ang);
					vector dir_vector = v_forward;

					v_forward = forward;
					right = v_right;
					up = v_up;

					if(!is_expert)
					{
						if(dir_vector.x > 0)
							dir_vector.x += 0.5;
						else
							dir_vector.x -= 0.5;
					}
					dir_vector = normalize(dir_vector);

					float rad = 300;
					if(is_expert)
						rad = 450;

					vector targ_vel = this.enemy.velocity;

					vector norm_vel = normalize(targ_vel);
					if((norm_vel * dir_vector) > 0)
						dir_vector *= -1;

					float lead = 1.5;
					vector dir_lead = targ_org + (targ_vel * lead);
					vector stagger = targ_org + (dir_vector * rad) - (targ_vel * 0.5);

					if(vdist(stagger - targ_org, <, rad))
					{
						vector newdir = targ_org - stagger;
						if(newdir == '0 0 0')
							newdir = dir_vector;

						stagger = targ_org - (normalize(newdir) * rad);
					}

					vector v4 = normalize(dir_lead - stagger);

					empress_lance_create(this, stagger, should_enrage, v4, pstrike_damage, this.empress_ai[1] / 100);
					// TODO: also shoots multiple players!
				}
			}

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 100 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 5:
		{
			if(this.empress_ai[1] == 0)
				_sound(this, CH_VOICE, "empress/rainbow.wav", 1, ATTN_BOSS);

			float sscale = 30;
			sscale -= skillscale;

			vector shot_offset = vec2_3d('55 -30 0');
			if(this.empress_ai[1] < 42)
				empress_magic(this, my_center + shot_offset, 3, empress_lerp_clamped(0, 42, this.empress_ai[1], true));

			vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
			empress_face(this);
			vector offset = vec2_3d('0 -350 0');
			vector destination = targ_org + offset;
			if(vdist(this.origin - destination, >, min_dist))
				empress_fly(this, direction_to(this.origin, destination) * base_speed, speed_scale);

			if((this.empress_ai[1] % 42) == 0 && this.empress_ai[1] < 42)
			{
				float start_deg = prandom() * 360;

				int total = 13;
				float step = 1 / total;

				for(int j = 0; j < 1; j += step)
				{
					float angle_degrees = 90 + (360 * j) + start_deg;

					vector ang = '0 0 0';
					ang.y = angle_degrees;

					vector forward = v_forward;
					vector right = v_right;
					vector up = v_up;

					// 3. Terraria: .ToRotationVector2()
					// Generates a safe normalized unit vector in that direction
					makevectors(ang);
					vector launch_dir = v_forward;

					vector tangent = '0 0 0';
					tangent.y = angle_degrees - 90;

					makevectors(tangent);
					vector side_step = v_forward * 30;

					v_forward = forward;
					right = v_right;
					up = v_up;

					vector org = my_center + side_step;
					org.z = my_center.z;

					vector vel = launch_dir * (15 * PHYS_SCALE);

					empress_everlasting_create(this, org, vel, this.enemy, peverlasting_damage, j, should_enrage);
				}
			}

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 42 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 6:
		{
			float sscale = 120 - skillscale;
			vector poffset = vec2_3d('0 -100 0');
			vector porg = my_center + poffset;

			vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
			empress_face(this);
			vector offset = vec2_3d('-80 -500 0');
			vector destination = targ_org + offset;
			if(vdist(this.origin - destination, >, min_dist))
				empress_fly(this, direction_to(this.origin, destination) * base_speed * 0.3, speed_scale * 0.7);

			if((this.empress_ai[1] % 60) == 0 && this.empress_ai[1] < 180)
			{
				float cycle = floor(this.empress_ai[1] / 60);
				float rot_stagger = cycle * 15;

				int scount = 6;
				if(is_expert)
					scount = 8;

				float step = 360 / scount;

				for(int j = 0; j < scount; ++j)
				{
					float ray_deg = (j * step) + rot_stagger;
					float rad = ray_deg * 0.01745329;

					vector ray_dir = (v_right * cos(rad)) + (v_up * sin(rad));
					ray_dir = normalize(ray_dir);

					empress_sundance_create(this, porg, ray_dir, psundance_damage, j / scount, should_enrage);
				}
			}

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 180 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 7: // rainbow lance charges
		{
			float sscale = 20;
			float sscale2 = 60;
			float slimit = sscale2 * 4;
			if(is_expert)
			{
				sscale = 40;
				sscale2 = 40;
				slimit = sscale2 * 6;
			}

			sscale -= skillscale;

			vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
			empress_face(this);
			vector offset = vec2_3d('0 -350 0');
			vector destination = targ_org + offset;
			if(vdist(this.origin - destination, >, min_dist))
				empress_fly(this, direction_to(this.origin, destination) * base_speed, speed_scale);

			if((this.empress_ai[1] % sscale2) == 0 && this.empress_ai[1] < slimit)
			{
				_sound(this, CH_WEAPON_SINGLE, "empress/bigblast.wav", 1, ATTN_BOSS);

				int cur_pattern = floor(this.empress_ai[1] / sscale2);
				float offs1 = 13;
				float offs2 = 150;
				float totaldist = offs1 * offs2;

				vector center = targ_org;
				if(vdist(this.origin - center, <=, 3200 * PHYS_SCALE))
				{
					vector offset = '0 0 0';
					vector dir = '0 0 0';
					float targ_offs1 = 0.4;
					float targ_offs2 = 1.4;
					float speedscale = 1;
					if(is_expert)
					{
						offs1 += 5;
						offs2 += 50;
						speedscale *= 1;
						totaldist *= 0.5;
					}

					switch(cur_pattern)
					{
						case 0:
							center.x = center.x + (((0 - totaldist) / 2) * speedscale);
							offset.y = totaldist;
							dir.x = 1;
							break;
						case 1:
							center.x = center.x + ((totaldist / 2) * speedscale);
							center.y = center.y + ((offs2 / 2) * speedscale);
							offset.y = totaldist; 
							dir.x = -1;      
							break;
						case 2:
							center.x = center.x + ((0 - totaldist) * targ_offs1 * speedscale);
							center.y = center.y + ((0 - totaldist) * targ_offs1 * speedscale);
							offset.x = totaldist * targ_offs2; 
							dir.x = 1;
							dir.y = 1;
							break;
						case 3:
							center.x = center.x + ((totaldist * targ_offs1 + offs2 / 2) * speedscale);
							center.y = center.y + (((0 - totaldist) * targ_offs1) * speedscale);
							offset.y = (0 - totaldist) * targ_offs2;
							dir.x = -1;
							dir.y = 1;
							break;
						case 4:
							center.x = center.x + ((0 - totaldist) * targ_offs1 * speedscale);
							center.y = center.y + (totaldist * targ_offs1 * speedscale);
							offset.x = totaldist * targ_offs2;
							dir = targ_org - center;
							break;
						case 5:
							center.x = center.x + ((totaldist * targ_offs1 + offs2 / 2) * speedscale);
							center.y = center.y + (totaldist * targ_offs1 * speedscale);
							offset.y = (0 - totaldist) * targ_offs2;
							dir = targ_org - center; 
							break;
					}

					if(vdist(dir, >, 0))
						dir = normalize(dir);
					else
						dir = '1 0 0';

					for(int j = 0; j <= 1; j += 1 / offs1)
					{
						vector org = center + offset * (j - 0.5);
						org.z = targ_org.z;
						vector v3 = dir;
						if(is_expert)
						{
							vector targ_vel = this.enemy.velocity * 20 * j;
							vector lead = direction_to(this.origin, targ_org + targ_vel);
							vector dir_norm = (vdist(lead, >, 0)) ? normalize(lead) : dir;
							v3 = (dir * 0.25) + (dir_norm * 0.75);
						}

						if(vdist(v3, >, 0))
							v3 = normalize(v3);
						else
							v3 = '1 0 0';

						empress_lance_create(this, org, should_enrage, v3, pstrike_damage, j);
					}
				}
			}

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= slimit + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 8:
		case 9: // charge
		{
			// not in the original, but making it face its goal helps...
			if(this.empress_ai[1] == 0)
				empress_face(this);

			float sscale = 20 - skillscale;

			empress_magic(this, my_center, 5, empress_lerp_clamped(40, 90, this.empress_ai[1], true));

			//vector destination = my_center + '0 0 -100';
			// TODO: damage immunity?
			float dir = (this.empress_ai[0] != 8) ? 1 : -1;
			dir *= -1; // FIXME
			if(this.empress_ai[1] <= 40)
			{
				if(this.empress_ai[1] == 20)
					_sound(this, CH_VOICE, "empress/charge.wav", 1, ATTN_BOSS);

				vector destination = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
				destination += vec2_3d(vec2(dir * -550, 0));

				empress_fly(this, direction_to(this.origin, destination) * base_speed, speed_scale * 2);
				if(this.empress_ai[1] == 40)
					this.velocity *= 0.3;
			}
			else if(this.empress_ai[1] <= 90)
			{
				this.velocity = empress_lerpv(this.velocity, vec2_3d(vec2(dir * 50, 0)) * PHYS_SCALE, 0.05);
				if(this.empress_ai[1] == 90)
					this.velocity *= 0.7;

				// TODO: damage scale?
			}
			else
				this.velocity *= 0.92;

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 90 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 10: // begin phase 2
		{
			float sscale = 20 - skillscale;
			if(this.empress_ai[1] == 0)
				_sound(this, CH_VOICE, "empress/appear.wav", 1, ATTN_BOSS);

			// TODO: damage immunity?

			this.velocity *= 0.95;
			if(this.empress_ai[1] == 90)
			{
				if(this.bosswave == 0)
					this.bosswave = 1;
				else if(this.bosswave == 2)
					this.bosswave = 3;

				vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
				setorigin(this, targ_org + vec2_3d('0 -250 0'));
				empress_face(this);
				this.angles_x = 0; // straighten so they know we mean business
			}

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 180 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
				this.empress_ai[2] = 0;
			}
			break;
		}
		case 11: // vertical lance volley
		{
			if(this.empress_ai[1] == 0)
				_sound(this, CH_VOICE, "empress/bigblast.wav", 1, ATTN_BOSS);

			float sscale = 20 - skillscale;

			if(this.empress_ai[1] >= 6 && this.empress_ai[1] < 54)
			{
				empress_magic(this, my_center + vec2_3d('-55 -20 0'), 2, empress_lerp_clamped(0, 100, this.empress_ai[1], true));
				empress_magic(this, my_center + vec2_3d('55 -20 0'), 4, empress_lerp_clamped(0, 100, this.empress_ai[1], true));
			}

			vector targ_org = (!this.enemy) ? my_center : CENTER_OR_VIEWOFS(this.enemy);
			vector destination = targ_org + vec2_3d('0 -350 0');

			if(vdist(this.origin - destination, >, min_dist))
				empress_fly(this, direction_to(this.origin, destination) * base_speed, speed_scale);

			if((this.empress_ai[1] % 3) == 0 && this.empress_ai[1] < 100)
			{
				for(int j = 0; j < 1; ++j)
				{
					if(vdist(this.origin - targ_org, >, 2400 * PHYS_SCALE))
						continue;

					vector vdir = this.enemy.velocity * -1;

					vector vert_bias = '0 0 1';
					vector v;
					if(vdist(vdir, <=, 0))
						v = vert_bias;
					else
						v = normalize(vdir);

					float rad = 800; // 100

					float lead = 1.5;
					vector dir_lead = targ_org + (this.enemy.velocity * lead);

					vector stagger = targ_org + (v * rad);

					if(vdist(stagger - targ_org, <, rad))
					{
						vector newdir = targ_org - stagger;
						if(newdir == '0 0 0')
							newdir = v;
						vector norm_dir = v;
						if(vdist(newdir, >, 0))
							norm_dir = normalize(newdir);
						stagger = targ_org - (norm_dir * rad);
					}

					vector v2 = normalize(dir_lead - stagger);

					empress_lance_create(this, stagger, should_enrage, v2, pstrike_damage, this.empress_ai[1] / 100);
				}
			}

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 100 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 12:
		{
			float sscale = 90 - skillscale;
			vector offset = vec2_3d('-55 -30 0');
			if(this.empress_ai[1] == 0)
			{
				_sound(this, CH_VOICE, "empress/wave.wav", 1, ATTN_BOSS);
				this.velocity = vec2_3d('0 -12 0') * PHYS_SCALE;
			}

			this.velocity *= 0.95;

			bool do_fire = (this.empress_ai[1] < 60 && this.empress_ai[1] >= 10);

			if(do_fire)
				empress_magic(this, my_center + offset, 1, empress_lerp_clamped(0, 60, this.empress_ai[1], true));

			int fireframe = 6;
			if(is_expert)
				fireframe = 4; // faster!

			float pspeed = (this.empress_ai[1] - 10) / 50;
			pspeed *= PHYS_SCALE;
			if((this.empress_ai[1] % fireframe) == 0 && do_fire)
			{
				vector shotvel = rotated_by(vec2_3d('0 -20 0'), M_PI * 2 * pspeed, '0 0 0');
				empress_rainbowstreak_create(this, my_center + offset, shotvel, this.enemy, pstreak_damage, should_enrage);
			}

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 60 + sscale)
			{
				this.empress_ai[0] = 1;
				this.empress_ai[1] = 0;
			}
			break;
		}
		case 13: // idle, look for an enemy
		{
			// this is normally where the boss would fade out and despawn
			// instead we just loop back and keep trying to find a target!
			if(this.empress_ai[1] == 0)
			{
				if(random() < 0.15)
					_sound(this, CH_VOICE, "empress/wave.wav", 1, ATTN_BOSS);
				//this.velocity = '0 0 -7' * PHYS_SCALE;
				this.angles_x = 0; // undo rotation
			}

			this.velocity *= 0.95;

			boss_FindTarget(this);

			// TODO: rainbows
			// maybe not, the dust spam could be laggy

			this.empress_ai[1] += 1;
			if(this.empress_ai[1] >= 20)
				this.empress_ai[1] = 0;
			if(!this.enemy)
				break;

			// yay target!
			this.empress_ai[0] = 1;
			this.empress_ai[1] = 0;
			break;
		}
	}
}

void empress_think(entity this)
{
	this.nextthink = time + PHYS_TICKRATE;
	setthink(this, empress_think);

	empress_anim(this);
	empress_touchframe(this);

	empress_ai_think(this);

	empress_draw(this);
}

void empress_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	_sound(this, CH_VOICE, "empress/pain.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.2;
}

void gib_empress(entity this)
{
	_sound(this, CH_VOICE, "empress/death.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

	int channel = MSG_ALL;
	WriteHeader(channel, empress_gibsplash);
	WriteVector(channel, this.origin);
	WriteFloat(channel, this.health);

	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
}

void empress_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			gib_empress(this);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	gib_empress(this);
	delete(this);
}

spawnfunc(monster_empress) { monster_start(this, true, MON_EMPRESS); }
#endif // SVQC

#ifdef SVQC
METHOD(Empress, mr_setup, bool(Empress this, entity actor))
{
	TC(Empress, this);

	precache_model("progs/gib1.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/rawbone.mdl");
	precache_model("progs/s_smoke.spr");
	precache_model("progs/proj_terraprisma.mdl");
	precache_sound("empress/death.wav");
	precache_sound("empress/pain.wav");
	precache_sound("empress/appear.wav");
	precache_sound("empress/bigblast.wav");
	precache_sound("empress/charge.wav");
	precache_sound("empress/rainbow.wav");
	precache_sound("empress/rapidfire.wav");
	precache_sound("empress/wave.wav");
	precache_sound("empress/star.wav");

	actor.bosswave = 0;

	actor.yaw_speed = 10;
	actor.effects |= EF_FULLBRIGHT;
	actor.effects |= EF_DIMLIGHT;

	actor.pos1 = actor.origin;

	set_movetype(actor, MOVETYPE_NOCLIP);

	actor.health = 6000;
	actor.th_stand = empress_think;
	actor.th_walk = empress_think;
	actor.th_run = empress_think;
	actor.th_pain = empress_pain;
	actor.th_die = empress_die;

	return true;
}
METHOD(Empress, mr_sight, bool(Empress this, entity actor))
{
	TC(Empress, this);

	// no sight sound handled here

	return true;
}
#endif

#ifdef CSQC
PRECACHE(EMPRESS)
{
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone.mdl");
}

NET_HANDLE(empress_gibsplash, bool isnew)
{
	vector org = ReadVector();
	float mhealth = ReadFloat();
	//float myscale = ReadFloat();
	//vector targorg = ReadVector();
	//vector targnorm = decompressShortVector(ReadShort());
	//vector targvel = decompressShortVector(ReadShort());
	vector targvel = '0 0 0';

	return = true;

	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib1.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/bone.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/bone2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib1.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/rawbone.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib3.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
}
#endif
