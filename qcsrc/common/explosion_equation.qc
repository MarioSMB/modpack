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
	print(sprintf("MASS: %f\nv: %v -> %v\nENERGY BEFORE == %f + %f = %f\nENERGY AFTER >= %f\n",
		m,
		target_v, target_v + v,
		target_v * target_v, m * explosion_f * speedfactor * explosion_f * speedfactor, target_v * target_v + m * explosion_f * speedfactor * explosion_f * speedfactor,
		(target_v + v) * (target_v + v)));
	return v;
#endif
	return explosion_f * explosion_calcpush_getmultiplier(explosion_f * speedfactor, target_v);
}
