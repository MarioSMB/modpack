// =============================
//  Explosion Force Calculation
// =============================

float explosion_calcpush_getmultiplier(vector explosion_v, vector target_v)
{
	float a;
	a  = explosion_v * (explosion_v - target_v);

	if(a <= 0)
		// target is too fast to be hittable by this
		return 0;

	a /= (explosion_v * explosion_v);
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
		(1 + elasticity) * (
			explosion_m
		) / (
			target_m + explosion_m
		)
	); // note: this factor is at least 0, at most 2
}
#endif

// simplified formula, tuned so that if the target has velocity 0, we get exactly the original force
vector damage_explosion_calcpush(vector explosion_f, vector target_v, float speedfactor)
{
	// if below 1, the formulas make no sense (and would cause superjumps)
	if(speedfactor < 1)
		return explosion_f;

#if 0
	float m;
	// find m so that
	//   speedfactor * (1 + e) * m / (1 + m) == 1
	m = 1 / ((1 + 0) * speedfactor - 1);
	vector v;
	v = explosion_calcpush(explosion_f * speedfactor, m, target_v, 1, 0);
	// the factor we then get is:
	//   1
	printf("MASS: %f\nv: %v -> %v\nENERGY BEFORE == %f + %f = %f\nENERGY AFTER >= %f\n",
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
	if(D < 0)
	{
		// irreducibilis
		a = 1.0/3.0 * acos(-q/2.0 * sqrt(-27.0/(p*p*p)));
		u = sqrt(-4.0/3.0 * p);
		// a in range 0..pi/3
		// cos(a)
		// cos(a + 2pi/3)
		// cos(a + 4pi/3)
		return
			u *
			(
				'1 0 0' * cos(a + 2.0/3.0*M_PI)
				+
				'0 1 0' * cos(a + 4.0/3.0*M_PI)
				+
				'0 0 1' * cos(a)
			);
	}
	else if(D == 0)
	{
		// simple
		if(p == 0)
			return '0 0 0';
		u = 3*q/p;
		v = -u/2;
		if(u >= v)
			return '1 1 0' * v + '0 0 1' * u;
		else
			return '0 1 1' * v + '1 0 0' * u;
	}
	else
	{
		// cardano
		u = cbrt(-q/2.0 + sqrt(D));
		v = cbrt(-q/2.0 - sqrt(D));
		return '1 1 1' * (u + v);
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
	v = (v -  b * '1 1 1') * (1.0 / (3.0 * a));
	if(a < 0)
		v += '1 0 -1' * (v_z - v_x); // swap x, z
	return v;
}

vector findperpendicular(vector v)
{
	vector p;
	p_x = v_z;
	p_y = -v_x;
	p_z = v_y;
	return normalize(cliptoplane(p, v));
}

vector W_CalculateSpread(vector forward, float spread, float spreadfactor, float spreadstyle)
{
	float sigma;
	vector v1 = '0 0 0', v2;
	float dx, dy, r;
	float sstyle;
	spread *= spreadfactor; //g_weaponspreadfactor;
	if(spread <= 0)
		return forward;
	sstyle = spreadstyle; //autocvar_g_projectiles_spread_style;
	
	if(sstyle == 0)
	{
		// this is the baseline for the spread value!
		// standard deviation: sqrt(2/5)
		// density function: sqrt(1-r^2)
		return forward + randomvec() * spread;
	}
	else if(sstyle == 1)
	{
		// same thing, basically
		return normalize(forward + cliptoplane(randomvec() * spread, forward));
	}
	else if(sstyle == 2)
	{
		// circle spread... has at sigma=1 a standard deviation of sqrt(1/2)
		sigma = spread * 0.89442719099991587855; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = sqrt(r);
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else if(sstyle == 3) // gauss 3d
	{
		sigma = spread * 0.44721359549996; // match baseline stddev
		// note: 2D gaussian has sqrt(2) times the stddev of 1D, so this factor is right
		v1 = forward;
		v1_x += gsl_ran_gaussian(sigma);
		v1_y += gsl_ran_gaussian(sigma);
		v1_z += gsl_ran_gaussian(sigma);
		return v1;
	}
	else if(sstyle == 4) // gauss 2d
	{
		sigma = spread * 0.44721359549996; // match baseline stddev
		// note: 2D gaussian has sqrt(2) times the stddev of 1D, so this factor is right
		v1_x = gsl_ran_gaussian(sigma);
		v1_y = gsl_ran_gaussian(sigma);
		v1_z = gsl_ran_gaussian(sigma);
		return normalize(forward + cliptoplane(v1, forward));
	}
	else if(sstyle == 5) // 1-r
	{
		sigma = spread * 1.154700538379252; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = solve_cubic_abcd(-2, 3, 0, -r) * '0 1 0';
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else if(sstyle == 6) // 1-r^2
	{
		sigma = spread * 1.095445115010332; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = sqrt(1 - r);
		r = sqrt(1 - r);
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else if(sstyle == 7) // (1-r) (2-r)
	{
		sigma = spread * 1.224744871391589; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = 1 - sqrt(r);
		r = 1 - sqrt(r);
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else
		error("g_projectiles_spread_style must be 0 (sphere), 1 (flattened sphere), 2 (circle), 3 (gauss 3D), 4 (gauss plane), 5 (linear falloff), 6 (quadratic falloff), 7 (stronger falloff)!");
	return '0 0 0';
	/*
	 * how to derive falloff functions:
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
