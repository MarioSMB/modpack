int fpclassify(float x)
{
	if(isnan(x))
		return FP_NAN;
	if(isinf(x))
		return FP_INFINITE;
	if(x == 0)
		return FP_ZERO;
	return FP_NORMAL;
}
int isfinite(float x)
{
	return !(isnan(x) || isinf(x));
}
int isinf(float x)
{
	return (x != 0) && (x + x == x);
}
int isnan(float x)
{
	float y;
	y = x;
	return (x != y);
}
int isnormal(float x)
{
	return isfinite(x);
}
int signbit(float x)
{
	return (x < 0);
}

float acosh(float x)
{
	return log(x + sqrt(x*x - 1));
}
float asinh(float x)
{
	return log(x + sqrt(x*x + 1));
}
float atanh(float x)
{
	return 0.5 * log((1+x) / (1-x));
}
float cosh(float x)
{
	return 0.5 * (exp(x) + exp(-x));
}
float sinh(float x)
{
	return 0.5 * (exp(x) - exp(-x));
}
float tanh(float x)
{
	return sinh(x) / cosh(x);
}

float exp(float x)
{
	return pow(M_E, x);
}
float exp2(float x)
{
	return pow(2, x);
}
float expm1(float x)
{
	return exp(x) - 1;
}

vector frexp(float x)
{
	vector v;
	v_z = 0;
	v_y = ilogb(x) + 1;
	v_x = x / exp2(v_y);
	return v;
}
int ilogb(float x)
{
	return floor(log2(fabs(x)));
}
float ldexp(float x, int e)
{
	return x * pow(2, e);
}
float log10(float x)
{
	return log(x) * M_LOG10E;
}
float log1p(float x)
{
	return log(x + 1);
}
float log2(float x)
{
	return log(x) * M_LOG2E;
}
float logb(float x)
{
	return floor(log2(fabs(x)));
}
vector modf(float f)
{
	return '1 0 0' * (f - trunc(f)) + '0 1 0' * trunc(f);
}

float scalbn(float x, int n)
{
	return x * pow(2, n);
}

float cbrt(float x)
{
	return copysign(pow(fabs(x), 1.0/3.0), x);
}
float hypot(float x, float y)
{
	return sqrt(x*x + y*y);
}

float erf(float x)
{
	// approximation taken from wikipedia
	float y;
	y = x*x;
	return copysign(sqrt(1 - exp(-y * (1.273239544735163 + 0.14001228868667 * y) / (1 + 0.14001228868667 * y))), x);
}
float erfc(float x)
{
	return 1.0 - erf(x);
}
vector lgamma(float x)
{
	// TODO improve accuracy
	if(!isfinite(x))
		return fabs(x) * '1 0 0' + copysign(1, x) * '0 1 0';
	if(x < 1 && x == floor(x))
		return nan("gamma") * '1 1 1';
	if(x < 0.1)
	{
		vector v;
		v = lgamma(1.0 - x);
		// reflection formula:
		// gamma(1-z) * gamma(z) = pi / sin(pi*z)
		// lgamma(1-z) + lgamma(z) = log(pi) - log(sin(pi*z))
		// sign of gamma(1-z) = sign of gamma(z) * sign of sin(pi*z)
		v_z = sin(M_PI * x);
		v_x = log(M_PI) - log(fabs(v_z)) - v_x;
		if(v_z < 0)
			v_y = -v_y;
		v_z = 0;
		return v;
	}
	if(x < 1.1)
		return lgamma(x + 1) - log(x) * '1 0 0';
	x -= 1;
	return (0.5 * log(2 * M_PI * x) + x * (log(x) - 1)) * '1 0 0' + '0 1 0';
}
float tgamma(float x)
{
	vector v;
	v = lgamma(x);
	return exp(v_x) * v_y;
}

float nearbyint(float x)
{
	return rint(x);
}
float trunc(float x)
{
	return (x>=0) ? floor(x) : ceil(x);
}

float fmod(float x, float y)
{
	return x - y * trunc(x / y);
}
float remainder(float x, float y)
{
	return x - y * rint(x / y);
}
vector remquo(float x, float y)
{
	vector v;
	v_z = 0;
	v_y = rint(x / y);
	v_x = x - y * v_y;
	return v;
}

float copysign(float x, float y)
{
	return fabs(x) * ((y>0) ? 1 : -1);
}
float nan(string tag)
{
	return sqrt(-1);
}
float nextafter(float x, float y)
{
	// TODO very crude
	if(x == y)
		return nan("nextafter");
	if(x > y)
		return -nextafter(-x, -y);
	// now we know that x < y
	// so we need the next number > x
	float d, a, b;
	d = max(fabs(x), 0.00000000000000000000001);
	a = x + d;
	do
	{
		d *= 0.5;
		b = a;
		a = x + d;
	}
	while(a != x);
	return b;
}
float nexttoward(float x, float y)
{
	return nextafter(x, y);
}

float fdim(float x, float y)
{
	return max(x-y, 0);
}
float fmax(float x, float y)
{
	return max(x, y);
}
float fmin(float x, float y)
{
	return min(x, y);
}
float fma(float x, float y, float z)
{
	return x * y + z;
}

int isgreater(float x, float y)
{
	return x > y;
}
int isgreaterequal(float x, float y)
{
	return x >= y;
}
int isless(float x, float y)
{
	return x < y;
}
int islessequal(float x, float y)
{
	return x <= y;
}
int islessgreater(float x, float y)
{
	return x < y || x > y;
}
int isunordered(float x, float y)
{
	return !(x < y || x == y || x > y);
}
