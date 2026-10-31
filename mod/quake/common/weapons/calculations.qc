#include "calculations.qh"

// =============================
//  Explosion Force Calculation
// =============================

float explosion_calcpush_getmultiplier(vector explosion_v, vector target_v)
{
	float a = explosion_v * (explosion_v - target_v);

	if (a <= 0)
		// target is too fast to be hittable by this
		return 0;

	a /= explosion_v * explosion_v;
		// we know we can divide by this, or above a would be == 0
	return a;
}

#if 0
vector explosion_calcpush(vector explosion_v, float explosion_m, vector target_v, float target_m, float elasticity)
{
	// solution of the equations:
	//    v'                = v + a vp             // central hit
	//    m*v'   + mp*vp'   = m*v + mp*vp          // conservation of momentum
	//    m*v'^2 + mp*vp'^2 = m*v^2 + mp*vp^2      // conservation of energy (ELASTIC hit)
	// -> a = 0                                    // case 1: did not hit
	// -> a = 2*mp*(vp^2 - vp.v) / ((m+mp) * vp^2) // case 2: did hit
	//                                             // non-elastic hits are somewhere between these two

	// this would be physically correct, but we don't do that
	return explosion_v * explosion_calcpush_getmultiplier(explosion_v, target_v) * (
		(1 + elasticity) * (explosion_m) / (target_m + explosion_m)
	); // note: this factor is at least 0, at most 2
}
#endif

// simplified formula, tuned so that if the target has velocity 0, we get exactly the original force
vector damage_explosion_calcpush(vector explosion_f, vector target_v, float speedfactor)
{
	// if below 1, the formulas make no sense (and would cause superjumps)
	if (speedfactor < 1)
		return explosion_f;

#if 0
	float m;
	// find m so that
	//   speedfactor * (1 + e) * m / (1 + m) == 1
	m = 1 / ((1 + 0) * speedfactor - 1);
	vector v = explosion_calcpush(explosion_f * speedfactor, m, target_v, 1, 0);
	// the factor we then get is:
	//   1
	LOG_INFOF("MASS: %f\nv: %v -> %v\nENERGY BEFORE == %f + %f = %f\nENERGY AFTER >= %f",
		m,
		target_v, target_v + v,
		target_v * target_v, m * explosion_f * speedfactor * explosion_f * speedfactor, target_v * target_v + m * explosion_f * speedfactor * explosion_f * speedfactor,
		(target_v + v) * (target_v + v));
	return v;
#endif
	return explosion_f * explosion_calcpush_getmultiplier(explosion_f * speedfactor, target_v);
}


// =========================
//  Shot Spread Calculation
// =========================

vector cliptoplane(vector v, vector p)
{
	return v - (v * p) * p;
}

vector solve_cubic_pq(float p, float q)
{
	float D, u, v, a;
	D = q*q/4.0 + p*p*p/27.0;
	if (D < 0)
	{
		// irreducibilis
		a = 1.0/3.0 * acos(-q/2.0 * sqrt(-27.0/(p*p*p)));
		u = sqrt(-4.0/3.0 * p);
		// a in range 0..pi/3
		// cos(a)
		// cos(a + 2pi/3)
		// cos(a + 4pi/3)
		return u * vec3(
			cos(a + 2.0/3.0*M_PI),
			cos(a + 4.0/3.0*M_PI),
			cos(a)
		);
	}
	else if (D == 0)
	{
		// simple
		if (p == 0)
			return '0 0 0';
		u = 3*q/p;
		v = -u/2;
		return (u >= v) ? vec3(v, v, u) : vec3(u, v, v);
	}
	else
	{
		// cardano
		//u = cbrt(-q/2.0 + sqrt(D));
		//v = cbrt(-q/2.0 - sqrt(D));
		a = cbrt(-q/2.0 + sqrt(D)) + cbrt(-q/2.0 - sqrt(D));
		return vec3(a, a, a);
	}
}
vector solve_cubic_abcd(float a, float b, float c, float d)
{
	// y = 3*a*x + b
	// x = (y - b) / 3a
	float p, q;
	vector v;
	p = (9*a*c - 3*b*b);
	q = (27*a*a*d - 9*a*b*c + 2*b*b*b);
	v = solve_cubic_pq(p, q);
	v = (v - b * '1 1 1') * (1.0 / (3.0 * a));
	if (a < 0)
		v += '1 0 -1' * (v.z - v.x); // swap x, z
	return v;
}

vector findperpendicular(vector v)
{
	return normalize(cliptoplane(vec3(v.z, -v.x, v.y), v));
}

#ifdef SVQC
int W_GunAlign(entity this, int preferred_align)
{
	if (this.m_gunalign)
		return this.m_gunalign; // no adjustment needed

	entity own = this.owner;

	if (preferred_align < 1 || preferred_align > 4)
		preferred_align = 1; // default NOTE: Quake weapons are middle aligned

	for (int j = 4; j > 1; --j) // > 1 as 1 is just center again
	{
		int taken = 0;
		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			if (own.(weaponentity).m_gunalign == j) // we know it can't be ours thanks to the above check
				taken |= BIT(j);
			if (own.(weaponentity).m_gunalign == preferred_align)
				taken |= BIT(preferred_align);
		}

		if (!(taken & BIT(preferred_align)))
			return preferred_align; // prefer the recommended
		if (!(taken & BIT(j)))
			return j; // or fall back if it's not available
	}

	return preferred_align; // return it anyway
}
#else
int W_GunAlign(entity this, int preferred_align)
{
	return this.m_gunalign > 0 ? this.m_gunalign : preferred_align;
}
#endif

#if 0
int W_GetGunAlignment(entity player)
{
	int gunalign = STAT(GUNALIGN, player);
	if (gunalign < 1 || gunalign > 4)
		gunalign = 3; // default value
	--gunalign;

	return gunalign;
}
#endif

vector W_CalculateSpreadPattern(int pattern, float bias, int counter, int total)
{
	vector s = '0 0 0';

	switch (pattern)
	{
		default:
		case 1:
			// first is always centered
			if (counter == 0)
				return '0 0 0';

			makevectors('0 360 0' * (0.75 + (counter - 0.5) / (total - 1)));
			s.y = v_forward.x;
			s.z = v_forward.y;
			// move outer projectiles randomly towards the center by max <bias> percent radius
			if (bias)
				s *= (1 - bias) + random() * bias;
			return s;

		case 2:
			// first is always centered
			if (counter == 0)
				return '0 0 0';

			// points form a round circle with even distribution
			// this could be simplified to '0 360 0' * (counter / total)
			// but it would lose ALL the specific placements
			// for example with this 2 pellets is center + directly up
			// while 3 pellets is a horizontal sweep and and 4 is an upside
			// down Y shape, 5 is a star instead of a pentagram,
			// 9 is a 3x3 grid and 13 is a circle with center + 3 per quadrant
			makevectors('0 360 0' * ((0.25 * ((total + 1) % 2)) + (counter / (total - 1))));

			// return transform vector
			s.y = v_forward.x;
			s.z = v_forward.y;
			if (bias)
				s *= (1 - bias) + random() * bias;

			//else // return original result normal vector
			//s = v_forward;
			return s;
		case 3:
			if (total <= 1)
				return '0 0 0';

			s.y = (counter / (total - 1)) - 0.5;

			if (bias)
				s *= (1 - bias) + random() * bias;

			return s;
	}
}

vector W_CalculateSpread(vector dir, float spread, int spread_style, bool must_normalize)
{
	//spread *= autocvar_g_weaponspreadfactor;
	if (spread <= 0)
		return (must_normalize ? normalize(dir) : dir);

	vector v1 = '0 0 0', v2;
	float sigma;
	float dx, dy, r;
	switch (spread_style)
	{
		default:
		case 0:
			// this is the baseline for the spread value!
			// standard deviation: sqrt(2/5)
			// density function: sqrt(1-r^2)
			v1 = dir + randomvec() * spread;
			return (must_normalize ? normalize(v1) : v1);
		case 1:
			// same thing, basically
			return normalize(dir + cliptoplane(randomvec() * spread, dir));
		case 2:
			// circle spread... has at sigma=1 a standard deviation of sqrt(1/2)
			sigma = spread * 0.89442719099991587855; // match baseline stddev
			v1 = findperpendicular(dir);
			v2 = cross(dir, v1);
			// random point on unit circle
			dx = random() * 2 * M_PI;
			dy = sin(dx);
			dx = cos(dx);
			// radius in our dist function
			r = random();
			r = sqrt(r);
			return normalize(dir + (v1 * dx + v2 * dy) * r * sigma);
		case 3: // gauss 3d
			sigma = spread * 0.44721359549996; // match baseline stddev
			// note: 2D gaussian has sqrt(2) times the stddev of 1D, so this factor is right
			v1.x = gsl_ran_ugaussian() * sigma;
			v1.y = gsl_ran_ugaussian() * sigma;
			v1.z = gsl_ran_ugaussian() * sigma;
			if (vdist(v1, >, W_SPREAD_GAUSS_MAX_STDEV))
				v1 = normalize(v1) * W_SPREAD_GAUSS_MAX_STDEV;
			v2 = dir + v1;
			return (must_normalize ? normalize(v2) : v2);
		case 4: // gauss 2d
			sigma = spread * 0.44721359549996; // match baseline stddev
			// note: 2D gaussian has sqrt(2) times the stddev of 1D, so this factor is right
			v1.x = gsl_ran_ugaussian() * sigma;
			v1.y = gsl_ran_ugaussian() * sigma;
			v1.z = gsl_ran_ugaussian() * sigma;
			if (vdist(v1, >, W_SPREAD_GAUSS_MAX_STDEV))
				v1 = normalize(v1) * W_SPREAD_GAUSS_MAX_STDEV;
			return normalize(dir + cliptoplane(v1, dir));
		case 5: // 1-r
			sigma = spread * 1.154700538379252; // match baseline stddev
			v1 = findperpendicular(dir);
			v2 = cross(dir, v1);
			// random point on unit circle
			dx = random() * 2 * M_PI;
			dy = sin(dx);
			dx = cos(dx);
			// radius in our dist function
			r = random();
			r = solve_cubic_abcd(-2, 3, 0, -r) * '0 1 0';
			return normalize(dir + (v1 * dx + v2 * dy) * r * sigma);
		case 6: // 1-r^2
			sigma = spread * 1.095445115010332; // match baseline stddev
			v1 = findperpendicular(dir);
			v2 = cross(dir, v1);
			// random point on unit circle
			dx = random() * 2 * M_PI;
			dy = sin(dx);
			dx = cos(dx);
			// radius in our dist function
			r = random();
			r = sqrt(1 - r);
			r = sqrt(1 - r);
			return normalize(dir + (v1 * dx + v2 * dy) * r * sigma);
		case 7: // (1-r) (2-r)
			sigma = spread * 1.224744871391589; // match baseline stddev
			v1 = findperpendicular(dir);
			v2 = cross(dir, v1);
			// random point on unit circle
			dx = random() * 2 * M_PI;
			dy = sin(dx);
			dx = cos(dx);
			// radius in our dist function
			r = random();
			r = 1 - sqrt(r);
			r = 1 - sqrt(r);
			return normalize(dir + (v1 * dx + v2 * dy) * r * sigma);
		//default:
			//error("g_projectiles_spread_style must be 0 (sphere), 1 (flattened sphere), 2 (circle), 3 (gauss 3D), 4 (gauss plane), 5 (linear falloff), 6 (quadratic falloff), 7 (stronger falloff)!");
	}

	return '0 0 0';
	/*
	 * how to derive falloff functions: Maxima:
	 * rho(r) := (2-r) * (1-r);
	 * a : 0;
	 * b : 1;
	 * rhor(r) := r * rho(r);
	 * cr(t) := integrate(rhor(r), r, a, t);
	 * scr(t) := integrate(rhor(r) * r^2, r, a, t);
	 * variance : scr(b) / cr(b);
	 * solve(cr(r) = rand * cr(b), r), programmmode:false;
	 * sqrt(0.4 / variance), numer;
	 */
}
