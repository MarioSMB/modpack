.float noise_baccum;
.float noise_paccum;
.float noise_paccum2;
.float noise_paccum3;
.float noise_bstate;
float Noise_Brown(entity e, float dt)
{
	e.noise_baccum += random() * sqrt(dt); // same stddev for all dt
	return e.noise_baccum;
}
float Noise_Pink(entity e, float dt)
{
	float f;
	f = dt * 60;
	// http://home.earthlink.net/~ltrammell/tech/pinkalg.htm
	if(random() > pow(0.3190, f))
		e.noise_paccum = 0.34848 * (2 * random() - 1);
	if(random() > pow(0.7756, f))
		e.noise_paccum2 = 0.28768 * (2 * random() - 1);
	if(random() > pow(0.9613, f))
		e.noise_paccum3 = 0.43488 * (2 * random() - 1);
	return e.noise_paccum + e.noise_paccum2 + e.noise_paccum3;
}
float Noise_White(entity e, float dt)
{
	return random() * 2 - 1;
}
float Noise_Burst(entity e, float dt, float p)
{
	if(random() > pow(p, dt))
		e.noise_bstate = !e.noise_bstate;
	return 2 * e.noise_bstate - 1;
}
