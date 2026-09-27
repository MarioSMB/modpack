#include "twins.qh"

// NOTE: this is a "fake" monster and a massive hack!
// unfortunately it's the only way currently to create a multi-boss...

#include "retinazer.qh"
#include "spazmatism.qh"

#ifdef SVQC
vector twins_arrive(entity this, vector point, float maximal_distance)
{
	float distance = bound(0.001, vlen(this.origin - point), maximal_distance);
	vector direction = normalize(point - this.origin);
	return  direction * (distance / maximal_distance);
}

vector twins_repel(entity this, vector point, float maximal_distance)
{
	float distance = bound(0.001, vlen(this.origin - point), maximal_distance);
	vector direction = normalize(this.origin - point);

	return direction * (1 - (distance / maximal_distance));
}

vector twins_flock(entity this, float _radius, float standoff, float separation_force, float flock_force)
{
	vector push = '0 0 0', pull = '0 0 0';
	int ccount = 0;

	if(this.buddy && vdist(this.origin - this.buddy.origin, <=, _radius))
	{
		ccount += 1;
		push += twins_repel(this, this.buddy.origin,standoff) * separation_force;
		pull += twins_arrive(this, this.buddy.origin + this.buddy.velocity, _radius) * flock_force;
	}

	float pullscale = (ccount) ? (1 / ccount) : 0;

	return push + (pull * pullscale);
}

void twins_anim(entity this)
{
	if(time < this.anim_finished)
		return;
	this.anim_finished = time + FRAME_TIME;

	// FIXME: the old model was cooler...
	int framecount = 19;
	if(this.bosswave >= 1)
		framecount = 3;

	this.walkframe += 1;
	if(this.walkframe > framecount)
		this.walkframe = 0;
	this.frame = this.walkframe;
}

float autocvar_sv_quake_twins_flock_radius = 1200;
float autocvar_sv_quake_twins_flock_standoff = 600;
float autocvar_sv_quake_twins_flock_separation_force = 25;
float autocvar_sv_quake_twins_flock_force = 15;

void twins_move(entity this, vector goal, float velmax, float turnrate)
{
	float vel = vlen(this.velocity);
	if(vel == 0)
		vel = 1; // hack to make sure avelocity never divs by 0

	// gently home in
	vector newdir = ai_steerto(this, goal, turnrate);
	this.velocity = newdir * vel;

	if(this.buddy)
		this.velocity += twins_flock(this, autocvar_sv_quake_twins_flock_radius, autocvar_sv_quake_twins_flock_standoff, autocvar_sv_quake_twins_flock_separation_force, autocvar_sv_quake_twins_flock_force);

	ai_accelerate(this, PHYS_INPUT_TIMELENGTH, normalize(this.velocity), vel, velmax, 0.25);
}

void twins_brake(entity this, float brakespeed)
{
	vector dir = normalize(this.velocity);

	brakespeed = max(0, vlen(this.velocity) - brakespeed);

	this.velocity = dir * brakespeed;
}

void twins_setangle(entity this, vector goal)
{
	vector myorg = CENTER_OR_VIEWOFS(this);
	vector ideal = vectoangles(normalize(goal - myorg));
	if(this.angles == ideal)
		return;

	float angspeed = this.yaw_speed;
	ideal -= this.angles;

	this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

entity twins_pickmovegoal(entity this)
{
	if(this.enemy)
		return this.enemy;
	else if(this.charmer)
		return this.charmer;
	else if(this.movetarget)
		return this.movetarget;
	else if(this.goalentity.classname != "path_corner")
		return NULL;
	return this.goalentity;
}

spawnfunc(monster_twins)
{
	monster_start(this, true, MON_TWINS);
}
#endif // SVQC

#ifdef SVQC
METHOD(Twins, mr_setup, bool(Twins this, entity actor))
{
	TC(Twins, this);

	entity spaz = controller_create(actor, spawn(), MON_SPAZMATISM);
	entity ret = controller_create(actor, spawn(), MON_RETINAZER);

	// for access to the tether
	spaz.buddy = ret;
	ret.buddy = spaz;

	tether_setup(spaz, ret, TETHER_FLESH, 9);

	return true;
}
#endif
