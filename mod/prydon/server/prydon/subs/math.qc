
float(float n) sqrt =
{
	local float bit, guess, f;
	guess = 0;
	bit = 65536;
	
	do
	{
		f = guess | bit;
		if ((f * f) == n)
			return f; // quick out
		else if ((f * f) < n)
			guess = f;
		bit = bit * 0.5;
	}
	while (bit >= 1);
	return guess;
};


float(float n, float exponent) pow =
{
	local float r;
	r = 1;
	if (exponent < 0)
	{
		while(exponent)
		{
			exponent = exponent + 1;
			r = r / n;
		}
	}
	else
	{
		while(exponent)
		{
			exponent = exponent - 1;
			r = r  * n;
		}
	}
	return r;
};

float(float f) fixbyte =
{
	f = rint(f);
	if (f > 255)
		f = 255;
	else if (f < 0)
		f = 0;
	return f & 255;
};

// no bit 24!! FIXME! For now use low values for 1st parm :)
float(float s1, float s2, float s3) encode =
{
	return fixbyte(s1) * 65536 + fixbyte(s2) * 256 + fixbyte(s3);
};
float(float parm, float which) decode =
{
	if (which == 1)
		return (parm / 65536) & 255;
	else if (which == 2)
		return (parm / 256) & 255;
	else
		return parm & 255;
};
float (float parm, float which, float set) recode =
{
	set = fixbyte(set);
	if (which == 1)
		return parm & 65535 | (set * 65536);
	else if (which == 2)
		return parm & 16711935 | (set * 256);
	else if (which == 3)
		return parm & 16776960 | set;
};

float(float f) root2=
{
	if (f == 1)
		return 1;
	else if (f == 2)
		return 2;
	else if (f == 4)
		return 3;
	else if (f == 8)
		return 4;
	else if (f == 16)
		return 5;
	else if (f == 32)
		return 6;
	else if (f == 64)
		return 7;
	else if (f == 128)
		return 8;
	else if (f == 256)
		return 9;
	else if (f == 512)
		return 10;
	else if (f == 1024)
		return 11;
	else if (f == 2048)
		return 12;
	else if (f == 4096)
		return 13;
	else if (f == 8192)
		return 14;
	else if (f == 16384)
		return 15;
	else if (f == 32768)
		return 16;
	return 0;
};

// handles powers of 2 from -127 to 127
float(float f) pow2_fast =
{
	local float over1, m;
	
	if (f < 0)
	{
		f = 0 - f;
		over1 = 1;
	}
	
	m = 1;
	if (f & 1)
		m = 2;
	if (f & 2)
		m = m * 4;
	if (f & 4)
		m = m * 16;
	if (f & 8)
		m = m * 256;
	if (f & 16)
		m = m * 65536;
	if (f & 32)
		m = m * 4294967296;
	if (f & 64)
		m = m * 18446744073709552640;
	if (over1)
		return 1/m;
	else
		return m;
};


// handles powers of 2 from 0 to 7 (biased by +1)
// used for my bitflag functions (equip, randomdrops, etc)
// TODO: remove the +1 bias some day to make this more elegant
float(float f) pow2=
{
	return pow2_fast(f - 1);
};

/*
-----------------------------------------
Modulus

C's % operator
-----------------------------------------
*/

float(float a, float b) mod =
{
	return a - (floor(a / b) * b);
};



/*
-----------------------------------------
Psuedo Random Number Generator
-----------------------------------------
*/
nosave float random_seed;

float RANDOM_PRIME1 = 17;
float RANDOM_PRIME2 = 29;
float RANDOM_PRIME3 = 569;
float(float range) psuedo_random =
{
	random_seed = mod(random_seed * RANDOM_PRIME1 + RANDOM_PRIME2, RANDOM_PRIME3);
	return mod(random_seed, range);
	
	//newseed = (oldseed * value1 + value2) % value3;return newseed % scale;
};
