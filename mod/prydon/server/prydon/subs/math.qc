#include "math.qh"

float fixbyte(float f)
{
	f = rint(f);
	if(f > 255)
		f = 255;
	else if(f < 0)
		f = 0;
	return f & 255;
}

// no bit 24!! FIXME! For now use low values for 1st parm :)
float encode(float s1, float s2, float s3)
{
	return fixbyte(s1) * 65536 + fixbyte(s2) * 256 + fixbyte(s3);
}

float decode(float parm, float which)
{
	if(which == 1)
		return (parm / 65536) & 255;
	else if(which == 2)
		return (parm / 256) & 255;
	else
		return parm & 255;
}

float recode(float parm, float which, float set)
{
	set = fixbyte(set);
	if(which == 1)
		return parm & 65535 | (set * 65536);
	else if(which == 2)
		return parm & 16711935 | (set * 256);
	else if(which == 3)
		return parm & 16776960 | set;
	return set;
}

// TODO: there's a cleaner xonotic function for this, can't recall its name!!
float root2(float f)
{
	if(f == 1)
		return 1;
	else if(f == 2)
		return 2;
	else if(f == 4)
		return 3;
	else if(f == 8)
		return 4;
	else if(f == 16)
		return 5;
	else if(f == 32)
		return 6;
	else if(f == 64)
		return 7;
	else if(f == 128)
		return 8;
	else if(f == 256)
		return 9;
	else if(f == 512)
		return 10;
	else if(f == 1024)
		return 11;
	else if(f == 2048)
		return 12;
	else if(f == 4096)
		return 13;
	else if(f == 8192)
		return 14;
	else if(f == 16384)
		return 15;
	else if(f == 32768)
		return 16;
	return 0;
}
