#include "devourer.qh"

#ifdef GAMEQC
REGISTER_NET_TEMP(TE_CSQC_DOG_GRID)

const int DOG_GRID_TWIST = 0; // hourglass pinch
const int DOG_GRID_HELIX = 1; // DNA helix - unused
const int DOG_GRID_SQUARE = 2; // kind of a grid, can be slanted
const int DOG_GRID_SINGLE = 3; // big single strike, currently unused

const int DOG_GRID_STRIKE = BIT(4);
const int DOG_GRID_BITS = (DOG_GRID_STRIKE);
#endif

#ifdef SVQC
float autocvar_sv_quake_devourer_faderate = 15;
#endif

#ifdef GAMEQC
float dog_aligntogrid(float point, float grid_size)
{
	point = floor((point / grid_size) + 0.5) * grid_size;
	//point.y = floor((point.y / grid_size) + 0.5) * grid_size;
	//point.z = floor((point.z / grid_size) + 0.5) * grid_size;
	return point;
}

void dog_grid_fire(entity this, int pattern, vector from, vector to)
{
#ifdef SVQC
	float hitsize = 3;
	if((pattern & DOG_GRID_SINGLE) || (pattern & DOG_GRID_TWIST))
		hitsize = 14;

	tracebox(from, '-1 -1 -1' * hitsize, '1 1 1' * hitsize, to, MOVE_NORMAL, this);

	if(trace_ent.takedamage && time >= trace_ent.hurt_antispam)
	{
		trace_ent.hurt_antispam = time + 0.2;
		float damage = 40; // TODO
		if(pattern & DOG_GRID_SINGLE)
			damage *= 2; // kaboom
		T_Damage(trace_ent, this, this, damage, DEATH_MONSTER_DEVOURER.m_id);
	}
#endif
#ifdef CSQC
	// not caching the picture though, zoning strings ain't pretty
	string pic = "";
	if(pattern & DOG_GRID_STRIKE)
		pic = "particles/lgbeam";
	Draw_CylindricLine(from, to, this.lip, pic, 0.25, 0, this.colormod, this.alpha, DRAWFLAG_NORMAL, view_origin);
#endif
}

void dog_grid_single(entity this, int pattern, vector org, float grid_size, vector slant)
{
	float vertical_height = 1500;

	float bottom_z_offset = -(vertical_height * 0.5);
	float top_z_offset = vertical_height * 0.5;

	vector bottom_slant = slant * bottom_z_offset;
	vector top_slant = slant * top_z_offset;

	vector top = org + top_slant;
	top.z += top_z_offset;

	vector bottom = org + bottom_slant;
	bottom.z += bottom_z_offset;

	dog_grid_fire(this, pattern, top, bottom);
}

void dog_grid_twist(entity this, int pattern, vector org, float grid_size, vector slant)
{
	int rings = 2;
	int pillars_per_ring = 10; 

	float vertical_height = 1500; 
	float twist_intensity = 1.8;   

	float pinch_factor = 0.02;

	for(int r = 1; r <= rings; ++r)
	{
		float current_radius = r * grid_size; 

		for(int p = 0; p < pillars_per_ring; ++p)
		{
			float base_angle = (p / pillars_per_ring) * 6.28318; // M_PI * 2

			float bottom_z_offset = -(vertical_height * 0.5);
			float top_z_offset = vertical_height * 0.5;
			float mid_z_offset = 0; 

			vector bottom_slant = slant * bottom_z_offset;
			vector top_slant = slant * top_z_offset;
			vector mid_slant = slant * mid_z_offset;

			vector bottom_pt;
			bottom_pt.x = org.x + (cos(base_angle) * current_radius) + bottom_slant_x;
			bottom_pt.y = org.y + (sin(base_angle) * current_radius) + bottom_slant_y;
			bottom_pt.z = org.z + bottom_z_offset + bottom_slant_z;

			float top_angle = base_angle + (r * twist_intensity);
			vector top_pt;
			top_pt_x = org.x + (cos(top_angle) * current_radius) + top_slant_x;
			top_pt_y = org.y + (sin(top_angle) * current_radius) + top_slant_y;
			top_pt_z = org.z + top_z_offset + top_slant_z;

			float mid_angle = base_angle + (r * twist_intensity * 0.5);
			float mid_radius = current_radius * pinch_factor;
			vector mid_pt;
			mid_pt_x = org.x + (cos(mid_angle) * mid_radius) + mid_slant_x;
			mid_pt_y = org.y + (sin(mid_angle) * mid_radius) + mid_slant_y;
			mid_pt_z = org.z + mid_z_offset + mid_slant_z; 

			dog_grid_fire(this, pattern, bottom_pt, mid_pt);
			dog_grid_fire(this, pattern, mid_pt, top_pt);
		}
	}
}

void dog_grid_helix(entity this, int pattern, vector org, int segments, float grid_size)
{
	float helix_radius = 64; // helix width
	float height_step = 8; // vertical distance
	float twist_speed = 0.25; // how tightly wound the helixes are

	// adjust start height so the helix is centered vertically on the origin
	float total_height = segments * height_step;
	vector helix_start = org - ('0 0 1' * (total_height * 0.5));

	for(int i = 0; i < segments; ++i)
	{
		float angle = i * twist_speed;
		float current_height = helix_start.z + (i * height_step);

		// math for strand A position
		vector strand_a;
		strand_a.x = org.x + (cos(angle) * helix_radius);
		strand_a.y = org.y + (sin(angle) * helix_radius);
		strand_a.z = current_height;

		// math for strand B position (exactly opposite/180 degrees away)
		vector strand_b;
		strand_b.x = org.x - (cos(angle) * helix_radius);
		strand_b.y = org.y - (sin(angle) * helix_radius);
		strand_b.z = current_height;

		if((i % 2) == 0)
			dog_grid_fire(this, pattern, strand_a, strand_b);

		if(i < (segments - 1))
		{
			float next_angle = (i + 1) * twist_speed;
			float next_height = helix_start.z + ((i + 1) * height_step);

			vector next_strand_a;
			next_strand_a.x = org.x + (cos(next_angle) * helix_radius);
			next_strand_a.y = org.y + (sin(next_angle) * helix_radius);
			next_strand_a.z = next_height;

			vector next_strand_b;
			next_strand_b.x = org.x - (cos(next_angle) * helix_radius);
			next_strand_b.y = org.y - (sin(next_angle) * helix_radius);
			next_strand_b.z = next_height;

			dog_grid_fire(this, pattern, strand_a, next_strand_a);
			dog_grid_fire(this, pattern, strand_b, next_strand_b);
		}
	}
}

void dog_grid_square(entity this, int pattern, vector org, int segments, float grid_size, vector grid_slant, vector offset)
{
	float half_grid_width = (segments * grid_size) * 0.5;
	float grid_total_length = segments * grid_size;

	vector total_slant_offset = grid_slant * grid_total_length;

	vector grid_start;
	grid_start.x = dog_aligntogrid(org.x - half_grid_width, grid_size) - (total_slant_offset_x * 0.5);
	grid_start.y = dog_aligntogrid(org.y - half_grid_width, grid_size) - (total_slant_offset_y * 0.5);
	grid_start.z = dog_aligntogrid(org.z - half_grid_width, grid_size) - (total_slant_offset_z * 0.5);

	grid_start.x += grid_size * offset.x;
	grid_start.y += grid_size * offset.y;

	for (int i = 0; i <= segments; ++i)
	{
		for (int j = 0; j <= segments; ++j)
		{
			float offset_a = i * grid_size;
			float offset_b = j * grid_size;

#if 0
			vector layer_slant = grid_slant * offset_b;

			vector fromx = grid_start + ('0 1 0' * offset_a) + ('0 0 1' * offset_b) + layer_slant;
			vector tox = fromx + ('1 0 0' * grid_total_length);
			dog_grid_fire(this, pattern, fromx, tox);

			vector fromy = grid_start + ('1 0 0' * offset_a) + ('0 0 1' * offset_b) + layer_slant;
			vector toy = fromy + ('0 1 0' * grid_total_length);
			dog_grid_fire(this, pattern, fromy, toy);
#endif

			vector fromz = grid_start + ('1 0 0' * offset_a) + ('0 1 0' * offset_b);
			vector toz = fromz + ('0 0 1' * grid_total_length) + (grid_slant * grid_total_length);
			dog_grid_fire(this, pattern, fromz, toz);
		}
	}
}

void dog_grid_pickpattern(entity this, vector org, int pattern, int randomness)
{
	// strip bitflags so we can switch it
	int pattern_grid = pattern;
	pattern_grid &= ~DOG_GRID_BITS;

	switch(pattern_grid)
	{
		default:
		case DOG_GRID_TWIST:
		{
			vector slant = '0.25 0 0';
			if(randomness)
				slant = '0.75 0.75 0';

			// no need to perform a dozen wasteful traces server side
#ifdef SVQC
			dog_grid_single(this, pattern, org, 150, slant);
#else
			dog_grid_twist(this, pattern, org, 150, slant);
#endif
			break;
		}
		case DOG_GRID_HELIX: dog_grid_helix(this, pattern, org, 32, 6); break;
		case DOG_GRID_SQUARE:
		{
			// lean vector, '0.5 0 0' means it tilts forward on the x axis by half a unit for every 1 unit it goes up
			vector offset = '0 0 0';
			vector slant = '0 0 0';
			if(randomness == 1)
			{
				offset = '-0.25 -0.25 0';
				slant = '-1 0 0';
			}
			else if(randomness == 2)
			{
				offset = '0.5 0.5 0';
				slant = '1 1 0';
			}
			dog_grid_square(this, pattern, org, 26, 180, slant, offset);
			break;
		}
	}
}
#endif

#ifdef CSQC
void dog_grid_draw(entity this)
{
	float fail = this.nextthink - time;
	float maxfail = (this.cnt & DOG_GRID_STRIKE) ? 1 : 0.3;
	this.alpha = bound(0, fail, maxfail);
	dog_grid_pickpattern(this, this.origin, this.cnt, this.count);
}

NET_HANDLE(TE_CSQC_DOG_GRID, bool isNew)
{
	Net_Accept(devourer_grid);
	setthink(this, SUB_Remove);
	this.nextthink = time + 1;
	vector org = ReadVector();
	int pattern = ReadByte();
	float randomness = ReadByte();

	this.draw = dog_grid_draw;
	if(isNew)
		IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	this.alpha = 1;
	this.origin = org;
	this.cnt = pattern;
	this.count = randomness;

	// for effect drawing
	this.lip = 8;
	this.colormod = '0.1 0.8 1';
	if(pattern & DOG_GRID_STRIKE)
	{
		this.nextthink = time + 0.7;
		this.lip = 24;
		this.colormod = '0.6 0 0.9';
	}

	return true;
}
#endif

#ifdef SVQC
const float ATTN_DEVOURER = 0.015625; // same as ATTEN_MIN

const int CLIPGROUP_DEVOURER = 31; // randomly picked! search for CLIPGROUP_ to find others used

const int AS_DOG_NORMAL = 1; // move towards target in a curving style
const int AS_DOG_STRAIGHT = 2; // move straight towards the target
const int AS_DOG_GRID = 3; // spin around (blast grid)
const int AS_DOG_PORTALDASH = 4; // dash through a portal at high speeds

const int DOG_STATE_NORMAL = 0;
const int DOG_STATE_PORTAL = 1;
const int DOG_STATE_HIDDEN = 2;

.entity devourer_next;
.entity devourer_prev;

.float idle_finished;

.entity portal_in; // the one we're aiming for
//.entity portal_out; // the one we're coming out of

.float devourer_chargetime;
.int devourer_fading; // 0: not fading, 1: fading, -1: un-fading

entity devourer_portal_create(entity this, vector org);

/*================
	MOVEMENT
==================*/
float devourer_shortangle(float ang1, float ang2)
{
	return shortangle_f(anglemods(ang1), anglemods(ang2));
}

void devourer_setangle(entity this, vector ideal, float angspeed)
{
	if(this.angles == ideal)
		return;

	ideal -= this.angles;

	this.angles_x += bound(-angspeed, devourer_shortangle(ideal.x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, devourer_shortangle(ideal.y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, devourer_shortangle(ideal.z, this.angles_z), angspeed);
}

vector devourer_get_ideal(entity this, vector myorg, vector targorg)
{
	vector ideal = aim_vec(myorg, targorg);
	ideal.x = -ideal.x;
	ideal.z = ideal.x * 1.5; // un-inverted

#if 0
	makevectors(ideal);
	return fixedvectoangles2(v_forward, v_up);
#else
	return ideal;
#endif
}

void devourer_move(entity this, entity targ, float velmax, float turnrate)
{
	float vel = vlen(this.velocity);
	if(vel == 0)
		vel = 1; // hack to make sure avelocity never divs by 0

	// gently home in
	if(targ)
	{
		vector newdir = ai_steerto(this, CENTER_OR_VIEWOFS(targ), turnrate);
		this.velocity = newdir * vel;
	}

	ai_accelerate(this, PHYS_INPUT_TIMELENGTH, normalize(this.velocity), vel, velmax, 0.25);
}

void devourer_movetogoal(entity this, vector goal)
{
	vector myorg = CENTER_OR_VIEWOFS(this);

	float angspeed = 8;
	float movespeed = (this.enemy) ? 700 : 400;
	if(this.bosswave > 2)
		movespeed *= 1.25;
	if(time < this.devourer_chargetime)
		movespeed = 1500;
	switch(this.attack_state)
	{
		// by default, just aim at the enemy
		default:
		case AS_DOG_NORMAL:
		{
			angspeed = 1 + ((1 + sin(time * 2)) * 5);
			if(vdist(myorg - goal, <=, 128))
				angspeed = 3; // minimal turning when close, let's be nice!
			break;
		}
		case AS_DOG_STRAIGHT: angspeed = 3; movespeed = 1000; break;
		case AS_DOG_GRID:
		{
			// circle the target
			vector offset = vec2(this.origin - goal);
			if(vdist(offset, <=, 0))
				offset.x = 1;

			float current_angle = atan2(offset.y, offset.x);
			float next_angle = current_angle + 0.15;

			float orbit_radius = 600;

			goal.x += (cos(next_angle) * orbit_radius);
			goal.y += (sin(next_angle) * orbit_radius);
			goal.z += 512;

			movespeed = 500; // TODO: speed up to get into position?
			break;
		}
	}

	if(this.state == DOG_STATE_PORTAL)
	{
		movespeed = 1200;
		angspeed = 45; // go for your life
	}

	if(this.state != DOG_STATE_HIDDEN)
	{
		//vector ideal = devourer_get_ideal(this, myorg, goal);
		if(angspeed)
			angspeed /= 180;
		vector newdir = ai_steerto(this, goal, angspeed);
		this.velocity = newdir * movespeed;

		//devourer_setangle(this, ideal, angspeed);
	}

	if(vdist(this.velocity, >, 0))
		this.angles = vectoangles(this.velocity);
}

void devourer_grid_send(entity this)
{
	WriteHeader(MSG_BROADCAST, TE_CSQC_DOG_GRID);
	WriteVector(MSG_BROADCAST, this.origin);
	WriteByte(MSG_BROADCAST, this.cnt);
	WriteByte(MSG_BROADCAST, this.count);
}

void devourer_grid_strike(entity this)
{
	this.cnt |= DOG_GRID_STRIKE; // fire time!
	devourer_grid_send(this);

	// TODO: big fire too!
	_sound(this, CH_WEAPON_B, "devourer/laserwall_fire.wav", 1, ATTN_DEVOURER);

	// temporarily let strikes blast through walls
	int oldsolid = this.realowner.dphitcontentsmask;
	this.realowner.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	dog_grid_pickpattern(this.realowner, this.origin, this.cnt, this.count);
	this.realowner.dphitcontentsmask = oldsolid;

	delete(this);
}

void devourer_grid_prestrike(entity this)
{
	setthink(this, devourer_grid_strike);
	this.nextthink = time + 1.5;

	_sound(this, CH_WEAPON_B, "devourer/laserwall_spawn.wav", 1, ATTN_DEVOURER);

	devourer_grid_send(this);
}

void devourer_grid_sendstrike(entity this, vector org, int pattern, float initial_delay)
{
	entity grid = spawn();
	grid.classname = "devourer_grid";
	grid.origin = org;
	grid.realowner = this;
	grid.owner = this;
	grid.cnt = pattern;
	grid.clipgroup = this.clipgroup;
	grid.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE; // ignore world
	grid.count = 0; // NOTE: only square uses this TODO: reduce bandwidth, don't send it?

	if(pattern == DOG_GRID_SQUARE)
	{
		grid.count = this.misc_bulletcounter;

		// every time we do a square, cycle the "randomness" so it's not the exact same attack
		this.misc_bulletcounter += 1;
		if(this.misc_bulletcounter > 2)
			this.misc_bulletcounter = 0;
	}
	else if(pattern == DOG_GRID_TWIST)
	{
		grid.count = this.reversed;
		this.reversed = (this.reversed) ? false : true;
	}

	setthink(grid, devourer_grid_prestrike);
	grid.nextthink = time + initial_delay;
}

void faith_fireball_fire(entity this, vector org, vector dir)
{
	vector spread = '0.1 0.1 0';
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;

	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_MONSTER_DEVOURER.m_id | HITTYPE_MAGIC;
	newmis.classname = "faith_fireball";
	newmis.owner = this;
	newmis.dmg = 60;
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = dir * 400;
	settouch(newmis, T_MissileTouch); // rocket explosion

	CSQCProjectile(newmis, true, PROJECTILE_FAITH_FIREBALL, true);
}

void devourer_faith_fireball(entity this, entity targ)
{
	int projcnt = max(1, rint(random() * 4));
	vector org = this.origin;
	vector targ_org = ai_shotlead(org, targ.origin, targ.velocity, 400);
	vector dir = normalize(targ_org - org);
	for(int j = 0; j < projcnt; ++j)
	{
		faith_fireball_fire(this, this.origin, dir);
	}
}

void devourer_portaldash(entity this, entity targ)
{
	vector dir = normalize(targ.origin - this.origin);
	float dist = vlen(targ.origin - this.origin) * 2;
	vector org = dir * dist;
	entity portal = devourer_portal_create(this, org);
	this.portal_in = portal;
}

void devourer_attackframe(entity this)
{
	if(time < this.attack_finished)
		return;

	// TODO: cancel attack state?
	entity targ = this.enemy;
	if(!targ)
		return;

	switch(this.attack_state)
	{
		case AS_DOG_NORMAL:
		{
			if(time >= this.attack2_finished)
			{
				this.attack_finished = time + 5; // give us a moment to get into the right place
				this.attack_state = AS_DOG_GRID;
				this.attack2_finished = time + 15; // how long grid phase lasts
				break;
			}
			if(time >= this.attack_finished && this.bosswave >= 1)
			{
				if(coop && autocvar_skill >= 1)
				{
					FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET),
					{
						if(checkpvs(this.origin, it))
							devourer_faith_fireball(this, it);
					});
				}
				else
					devourer_faith_fireball(this, targ);
				this.attack_finished = time + 10 + (random() * 5);
			}
			if(time > this.idle_finished && time > this.devourer_chargetime)
			{
				this.idle_finished = time + 1; // only check sometimes
				// TODO: prefer doing it while facing target
				if(random() < 0.1 && infront(this, targ) && vdist(targ.origin - this.origin, >, 1000))
					this.devourer_chargetime = time + 1 + random();
			}
			break;
		}
		case AS_DOG_GRID:
		{
			if(time >= this.attack2_finished)
			{
				this.attack_state = AS_DOG_NORMAL;
				this.attack2_finished = time + 30 + random() * 5;
				break;
			}

			if(this.bosswave < 3)
				devourer_grid_sendstrike(this, targ.origin, DOG_GRID_TWIST, 0);
			else
				devourer_grid_sendstrike(this, targ.origin, DOG_GRID_SINGLE, 0);

			if(this.bosswave < 1)
				devourer_grid_sendstrike(this, this.origin, DOG_GRID_SQUARE, 0);
			else if(this.bosswave < 2)
			{
				devourer_grid_sendstrike(this, this.origin, DOG_GRID_SQUARE, 0.25);
				devourer_grid_sendstrike(this, this.origin, DOG_GRID_SQUARE, 0.5);
			}
			else
			{
				this.misc_bulletcounter = 1; // force a double grid
				devourer_grid_sendstrike(this, this.origin, DOG_GRID_SQUARE, 0);
				devourer_grid_sendstrike(this, this.origin, DOG_GRID_SQUARE, 0);
			}

			this.attack_finished = time + 4;
			break;
		}
		case AS_DOG_PORTALDASH:
		{
			if(time >= this.attack2_finished)
			{
				this.attack_state = AS_DOG_NORMAL;
				this.attack2_finished = time + 30 + random() * 5;
				break;
			}

			if(!this.portal_in)
			{
				this.attack_finished = time + 5; // give us a moment to get into the right place
				devourer_portaldash(this, targ);
			}

			break;
		}
	}
}

void devourer_resummon(entity this, vector org)
{
	Monster mon = MON_TRUE_DEVOURER;

	entity monster = new(monster);
	monster.scale = (this.scale) ? this.scale : 1;
	monster.scale *= 1.25;
	monster.skin = 1;
	monster.bosswave = 3;
	minion_spawn(this, org, monster, mon);
	//monster.nextthink = time;
	monster.max_health = this.max_health;
	monster.health = this.health;

	monster.flags &= ~FL_CLONE; // we DO want it to count as a kill!

	if(monster.sprite)
		WaypointSprite_UpdateHealth(monster.sprite, monster.health);

	// dispose of the old monster
	// TODO: this is a mess
	for(entity ent = this; ent; ent = ent.devourer_next)
	{
		setthink(ent, SUB_Remove);
		ent.nextthink = time;
	}
}

void devourer_fade(entity this)
{
	float myscale = (this.scale) ? this.scale : 1;
	if(this.devourer_fading == 1)
	{
		this.alpha -= (autocvar_sv_quake_devourer_faderate * PHYS_INPUT_FRAMETIME) / myscale;
		if(this.alpha <= 0.01)
		{
			this.devourer_fading = 0;
			this.state = DOG_STATE_HIDDEN;
			this.solid = SOLID_NOT;
			this.alpha = -1;
			this.portal_in = NULL;
			setorigin(this, this.origin); // relink

			if(this.devourer_next)
				this.devourer_next.devourer_fading = 1;

			// tail, all parts have presumably gone through
			if(!this.devourer_next && this.realowner)
			{
				if(this.realowner.monsterdef == MON_DEVOURER)
					devourer_resummon(this.realowner, this.origin + randomvec() * 64);
				else
					devourer_portaldash(this.realowner, this.realowner.enemy);
			}
		}
	}
	else if(this.devourer_fading == -1)
	{
		this.alpha += (autocvar_sv_quake_devourer_faderate * PHYS_INPUT_FRAMETIME) / myscale;
		if(this.alpha >= 1)
		{
			this.devourer_fading = 0;
			this.solid = SOLID_BBOX;
			this.takedamage = DAMAGE_AIM;
			this.attack_state = AS_DOG_NORMAL;
			this.alpha = 1;
			setorigin(this, this.origin); // relink

			// tell next part to begin unfading
			if(this.devourer_next)
			{
				this.devourer_next.alpha = 0.01;
				this.devourer_next.state = DOG_STATE_NORMAL;
			}
		}
	}
}

void vortex_fade(entity this); // defined by zerstorer
void devourer_portal_think(entity this)
{
	this.nextthink = time + 0.1;
	if(this.cnt > 0 && time >= this.cnt)
	{
		if(this.realowner.portal_in == this)
			this.realowner.portal_in = NULL;
		vortex_fade(this);
		return;
	}

	this.frame += 1;
	if(this.frame > 23)
		this.frame = 0;
}

entity devourer_portal_create(entity this, vector org)
{
	entity portal = spawn();
	portal.classname = "devourer_portal";
	portal.realowner = this;
	set_movetype(portal, MOVETYPE_NONE);
	_setmodel(portal, "progs/vortex.mdl");
	setsize(portal, '-32 -32 -24', '32 32 32');
	setorigin(portal, org);
	setthink(portal, devourer_portal_think);
	portal.nextthink = time + 0.1;
	portal.frame = 0;
	portal.cnt = time + 10; // just incase
	portal.scale = 3;

	_sound(portal, CH_TRIGGER_SINGLE, "devourer/rift_open.wav", 1, ATTN_DEVOURER);

	return portal;
}

entity devourer_pickmovegoal(entity this)
{
	if(this.portal_in)
		return this.portal_in;
	else if(this.enemy)
		return this.enemy;
	else if(this.charmer)
		return this.charmer;
	else if(!boxesoverlap(this.absmin, this.absmax, world.mins, world.maxs))
		return world; // try to move towards the world origin?
	return this.devourer_prev; // TODO: make sure it doesn't just fly out of the world!
}

void devourer_checkwave(entity this)
{
	if(this.charmed)
		return; // pets don't do boss phases

	if(this.bosswave < 1 && this.health <= (this.max_health * 0.75))
		this.bosswave = 1;

	if(this.bosswave < 2 && this.health <= (this.max_health * 0.65))
	{
		this.bosswave = 2;
		this.health = this.max_health * 0.65;
		if(this.sprite)
			WaypointSprite_UpdateHealth(this.sprite, this.health);
		this.attack_state = AS_DOG_STRAIGHT;
		for(entity ent = this; ent; ent = ent.devourer_next)
		{
			ent.state = DOG_STATE_PORTAL;
			ent.solid = SOLID_NOT;
			ent.takedamage = DAMAGE_NO;
		}
		this.attack_finished = time + 5; // prevent attacks
		this.attack2_finished = time + 5; // prevent attacks
		entity portal = devourer_portal_create(this, this.origin + randomvec() * 512);
		portal.cnt = time + 30; // please don't get rid of our lifeline
		this.portal_in = portal;
		return;
	}

	// NOTE: wave 3 is considered when the boss emerges from the portal

	if(this.bosswave < 4 && this.health <= (this.max_health * 0.25))
	{
		this.bosswave = 4;
		// instantly enters laser phase
		this.attack_state = AS_DOG_GRID;
		this.attack_finished = time + 5; // give us a moment to get into the right place
		this.attack2_finished = time + 15; // how long grid phase lasts
		return;
	}
}

// always needs to be moving, so pick a target
// if there's no enemies, just chase our own tail!
void boss_FindTarget(entity this);
void devourer_think(entity this)
{
	if(!IS_MONSTER(this))
		return;

	setthink(this, devourer_think);
	this.nextthink = time;

	// always run so we get accurate health readings
	devourer_checkwave(this);

	if(!this.devourer_fading && this.portal_in && vdist(this.portal_in.origin - this.origin, <, 96))
		this.devourer_fading = 1;

	if(this.devourer_fading && this.state != DOG_STATE_HIDDEN)
		devourer_fade(this);

	if(this.state == DOG_STATE_NORMAL)
		boss_FindTarget(this);

	if(this.state != DOG_STATE_HIDDEN)
		this.goalentity = devourer_pickmovegoal(this);

	devourer_movetogoal(this, CENTER_OR_VIEWOFS(this.goalentity));

	// only trigger attacks in "passive" mode?
	if(this.state == DOG_STATE_NORMAL && !this.charmed)
		devourer_attackframe(this);
}

void devourer_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.state != DOG_STATE_NORMAL)
		return; // not visible
	spamsound(this, CH_VOICE, SND_MECHBOSS_HIT, 1, ATTN_NORM);
}

void devourer_hitbox_touch(entity this, entity toucher)
{
	entity own = (this.classname == "monster_hitbox") ? this.realowner : this;

	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.hurt_antispam)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, own))
		return;
	
	if(toucher == own || toucher.owner == own)
		return;

	toucher.hurt_antispam = time + 1; // no spam please

	float damage = 30;
	// must be the head!
	if(this.classname != "monster_hitbox")
		damage = 120;
	
	T_Damage(toucher, this, own, damage, DEATH_MONSTER_DEVOURER.m_id);
}

// called by hitboxes
void devourer_part_think(entity this)
{
	if(this.realowner.health < 1 || !this.realowner || wasfreed(this.realowner))
	{
		delete(this);
		return;
	}

	setthink(this, devourer_part_think);
	this.nextthink = time;

	if(this.devourer_fading && this.state != DOG_STATE_HIDDEN)
		devourer_fade(this);

	entity targ = this.devourer_prev;
	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(targ);
	vector aimangle = aim_vec(myorg, targorg);

	makevectors(aimangle);

	// instead of attaching, we brute force it so we have collision
	// TODO: while this allows collision, it kinda doesn't work well at all...
	float myscale = (this.scale) ? this.scale : 1;
	setorigin(this, targ.origin + v_forward * (-this.maxs_z * (myscale * 2)));

	this.goalentity = targ;
	vector ideal = devourer_get_ideal(this, myorg, targorg);
	devourer_setangle(this, ideal, 3);

	if(this.solid == SOLID_NOT)
		return;

	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			devourer_hitbox_touch(this, it);
	});
}

entity devourer_spawn_part(entity this, entity prev, string partmdl)
{
	Monster mon = this.monsterdef;

	// body
	entity ent = spawn();
	ent.classname = "monster_hitbox";
	ent.owner = this;
	ent.realowner = this;
	ent.devourer_prev = prev;
	ent.clipgroup = this.clipgroup;
	//ent.takedamage = DAMAGE_AIM;
	//ent.solid = SOLID_BBOX;
	//ent.alpha = 1;
	// starts non solid so it can come out of the portal
	ent.takedamage = DAMAGE_NO;
	ent.solid = SOLID_NOT;
	ent.alpha = -1;
	ent.devourer_fading = -1;
	ent.state = DOG_STATE_HIDDEN;
	ent.scale = this.scale;
	ent.skin = this.skin;
	//ent.effects = EF_NODEPTHTEST;
	ent.th_pain = devourer_pain;
	ent.colormod = this.colormod;
	_setmodel(ent, partmdl);
	setsize(ent, mon.m_mins * ent.scale, mon.m_maxs * ent.scale);
	ent.angles = this.angles;
	//setorigin(ent, prev.origin - ('0 0 2' * mon.m_maxs_z));
	setorigin(ent, prev.origin);
	//settouch(ent, devourer_hitbox_touch);
	setthink(ent, devourer_part_think);
	ent.nextthink = time;

	prev.devourer_next = ent;

	return ent;
}

void devourer_spawn_body(entity this)
{
	entity ent = this;

	int segments = rint(82 * ((this.scale) ? this.scale : 1));
	for(int j = 0; j <= segments; ++j)
	{
		ent = devourer_spawn_part(this, ent, "progs/devourer_body.mdl");
	}

	// tail, easy to tell by not having a next part
	ent = devourer_spawn_part(this, ent, "progs/devourer_tail.mdl");
	ent.devourer_next = NULL;

	// mark our prev as the tail to get easy access to it
	this.devourer_prev = ent;

	//this.effects |= EF_NODEPTHTEST;

	// will be triggered by move logic
	//setthink(this, devourer_move_loop);
	//this.nextthink = time + 0.1;
}

void devourer_head_explode(entity this)
{
	this.nextthink = time + 1;

	this.cnt += 1;

	if(this.cnt > 3)
	{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, this.origin, '0 0 0', '0 0 0', '0 0 0', 0, 600, 0.2, 0.1, 1.5);

		_sound(this, CH_VOICE, "devourer/death.wav", 1, ATTN_DEVOURER);
		delete(this);
		return;
	}

	float r = random();
	if(r < 0.25)
		_sound(this, CH_VOICE, "devourer/segment_break1.wav", 1, ATTN_DEVOURER);
	else if(r < 0.50)
		_sound(this, CH_VOICE, "devourer/segment_break2.wav", 1, ATTN_DEVOURER);
	else if(r < 0.75)
		_sound(this, CH_VOICE, "devourer/segment_break3.wav", 1, ATTN_DEVOURER);
	else
		_sound(this, CH_VOICE, "devourer/segment_break4.wav", 1, ATTN_DEVOURER);
}

void devourer_part_explode(entity this)
{
	entity gib = ThrowGib(this, this, this.model, -70);
	gib.scale = 0.5;

	delete(this);
}

void devourer_death(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);

	switch(killed_type)
	{
		case KILLED_INVOKED:
		{
			for(entity ent = this; ent; ent = ent.devourer_next)
			{
				FX_Invoked(ent);
				setthink(ent, SUB_Remove);
				ent.nextthink = time;
				ent.solid = SOLID_NOT;
				ent.takedamage = DAMAGE_NO;
				ent.velocity = '0 0 0';
			}
			return; // handled
		}
	}

	// unique death cutscene (slowly kills all parts)
	// no special death effects apply here! (yet)

	int segments = 1;
	for(entity ent = this; ent; ent = ent.devourer_next)
	{
		ent.velocity = '0 0 0';
		float stime = 2;
		if(segments % 2)
			stime = 3;
		else if(segments % 3)
			stime = 4;
		setthink(ent, devourer_part_explode);
		ent.nextthink = time + stime;
		settouch(ent, func_null);
		ent.takedamage = DAMAGE_NO;
		ent.solid = SOLID_NOT;
		segments += 1;
	}

	// for the head, we do something else
	setthink(this, devourer_head_explode);
	this.nextthink = time + 1;
	this.cnt = 0;
}

void devourer_appear(entity this)
{
	this.devourer_fading = -1;
	this.state = DOG_STATE_NORMAL;
	this.attack_finished = time + 5;
	this.attack2_finished = time + 30; // TODO: variation
	setthink(this, devourer_think);
	this.nextthink = time;
	this.alpha = 0.01;

	soundat(NULL, this.origin, CH_TRIGGER, "devourer/spawn.wav", 1, ATTN_DEVOURER);
}

/*QUAKED monster_devourer(1 0 0)(-32 -32 -24)(32 32 48) Ambush
*/
spawnfunc(monster_devourer) { monster_start(this, true, MON_DEVOURER); }

#endif // SVQC

#ifdef SVQC
void devourer_setup(entity actor)
{
	if(!actor.scale)
		actor.scale = (actor.charmed) ? 0.5 : 1;

	actor.health = 30000;
	actor.gibhealth = 0; // no gibbing
	set_movetype(actor, MOVETYPE_NOCLIP);

	// give it a unique clipgroup to prevent intersecting with projectiles and such
	if(!actor.clipgroup)
		actor.clipgroup = CLIPGROUP_DEVOURER;

	actor.attack_state = AS_DOG_STRAIGHT;
	actor.state = DOG_STATE_HIDDEN;
	actor.had_enemy = true; // force aggro, we never don't move

	//settouch(actor, devourer_hitbox_touch);

	actor.th_stand = devourer_think;
	actor.th_walk = devourer_think;
	actor.th_run = devourer_think;
	actor.th_die = devourer_death;
	actor.th_pain = devourer_pain;
	//actor.th_melee = devourer_stomp;
	//actor.th_missile = devourer_attack;

	actor.yaw_speed = 5;

	// just make a portal at our location, it'll expire on its own
	devourer_portal_create(actor, actor.origin);

	devourer_spawn_body(actor);

	actor.solid = SOLID_NOT;
	actor.takedamage = DAMAGE_NO;
	actor.alpha = -1;

	setthink(actor, devourer_appear);
	actor.nextthink = time + 5;
}

METHOD(Devourer, mr_setup, bool(Devourer this, entity actor))
{
	TC(Devourer, this);

	precache_model("progs/devourer_body.mdl");
	precache_model("progs/devourer_tail.mdl");
	precache_model("progs/vortex.mdl");
	
	precache_sound("destroyer/hit.wav");
	precache_sound("devourer/laserwall_spawn.wav");
	precache_sound("devourer/laserwall_fire.wav");
	precache_sound("devourer/laserwall_fire2.wav");
	precache_sound("devourer/death.wav");
	precache_sound("devourer/segment_break1.wav");
	precache_sound("devourer/segment_break2.wav");
	precache_sound("devourer/segment_break3.wav");
	precache_sound("devourer/segment_break4.wav");
	precache_sound("devourer/spawn.wav");
	precache_sound("devourer/rift_open.wav");

	actor.bosswave = 0;

	devourer_setup(actor);

	return true;
}

METHOD(TrueDevourer, mr_setup, bool(TrueDevourer this, entity actor))
{
	TC(TrueDevourer, this);

	devourer_setup(actor);

	return true;
}
#endif
