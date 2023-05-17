#include "parms.qh"

/*
LordHavoc's float coder notes
SEEE EEEE EMMM MMMM MMMM MMMM MMMM MMMM
bits[8], bits[23]
float code1; // to be encoded as exponent, 0-250 (stored at +1)
float code2; // to be encoded as mantissa, 0-8388607 (stored at +8388608)
*/

int lhfp_code0; // sign part, true/false allowed
int lhfp_code1; // exponent part, 0-252 range allowed
int lhfp_code2; // mantissa part, 0-8388607 range allowed

float sixteenth = 0.0625; // (1 / 16)

int lhfp_code1toscale(float n)
{
	int f = 1;
	n = n - 126;
	// the n +- 4 cases are just optimizations to process faster
	while(n <= -4)
	{
		n += 4;
		f *= sixteenth;
	}
	while(n < 0)
	{
		n += 1;
		f *= 0.5;
	}
	while(n >= 4)
	{
		n = n - 4;
		f *= 16;
	}
	while(n > 0)
	{
		n = n - 1;
		f *= 2;
	}
	return f;
}

int lhfp_scaletocode1(int f)
{
	int n = 126;
	// the n +- 4 cases are just optimizations to process faster
	// the < n and > checks are to prevent runaway loops
	while(f >= 16 && n < 254)
	{
		n += 4;
		f *= sixteenth;
	}
	while(f >= 2 && n < 254)
	{
		n += 1;
		f *= 0.5;
	}
	while(f < sixteenth && n > 0)
	{
		n = n - 4;
		f *= 16;
	}
	while(f < 1 && n > 0)
	{
		n = n - 1;
		f *= 2;
	}
	return n;
}

int lhfp_encode(int code0, int code1, int code2)
{
	int code;
	if(code1 != floor(code1) || code1 < 0 || code1 >= 254)
		error("lhfp_encode: invalid code1, must be an integer in the range 0-253.\n");
	if(code2 != floor(code2) || code2 < 0 || code2 >= 8388608)
		error("lhfp_encode: invalid code2, must be an integer in the range 0-8388607.\n");
	code = (1 + (code2 / 8388608)) * lhfp_code1toscale(code1);
	if(code0)
		code = 0 - code;
	return code;
}

bool lhfp_decode(int code)
{
	// code == 0 never occurs on a valid encoded value, we'll just assume it's garbage here.
	if(code == 0)
	{
		// invalid code
		lhfp_code0 = false;
		lhfp_code1 = 0;
		lhfp_code2 = 0;
		return false;
	}
	if(code < 0)
	{
		code = 0 - code;
		lhfp_code0 = true;
	}
	else
		lhfp_code0 = false;
	lhfp_code1 = lhfp_scaletocode1(code);
	if(lhfp_code1 < 0 || lhfp_code1 >= 254)
	{
		// invalid exponent
		lhfp_code0 = false;
		lhfp_code1 = 0;
		lhfp_code2 = 0;
		return false;
	}
	lhfp_code2 = ((code / lhfp_code1toscale(lhfp_code1)) - 1) * 8388608;
	return true;
}

int lhbitparms_index;
int lhbitparms_endindex;
vector lhbitparms_code, lhbitparms_scale;

vector lhbitparms_codesize(int index)
{
	if(index < 16)
		return '2 128 8388608';
	else
		return '2 64 8388608';
}

void lhbitparms_storeparm(int index, vector v)
{
	int code;
	if(index >= 16)
		v += '0 140 0';
	code = lhfp_encode(v_x, v_y, v_z);
		 if(index <  1) parm1 = code;
	else if(index <  2) parm2 = code;
	else if(index <  3) parm3 = code;
	else if(index <  4) parm4 = code;
	else if(index <  5) parm5 = code;
	else if(index <  6) parm6 = code;
	else if(index <  7) parm7 = code;
	else if(index <  8) parm8 = code;
	else if(index <  9) parm9 = code;
	else if(index < 10) parm10 = code;
	else if(index < 11) parm11 = code;
	else if(index < 12) parm12 = code;
	else if(index < 13) parm13 = code;
	else if(index < 14) parm14 = code;
	else if(index < 15) parm15 = code;
	else if(index < 16) parm16 = code;
	else if(index < 17) cvar_set("scratch1", ftos(code));
	else if(index < 18) cvar_set("scratch2", ftos(code));
	else if(index < 19) cvar_set("scratch3", ftos(code));
	else if(index < 20) cvar_set("scratch4", ftos(code));
	else if(index < 21) cvar_set("saved1", ftos(code));
	else if(index < 22) cvar_set("saved2", ftos(code));
	else if(index < 23) cvar_set("saved3", ftos(code));
	else if(index < 24) cvar_set("saved4", ftos(code));
}

vector lhbitparms_loadparm(int index)
{
	int code = 0;
	     if(index <  1) code = parm1;
	else if(index <  2) code = parm2;
	else if(index <  3) code = parm3;
	else if(index <  4) code = parm4;
	else if(index <  5) code = parm5;
	else if(index <  6) code = parm6;
	else if(index <  7) code = parm7;
	else if(index <  8) code = parm8;
	else if(index <  9) code = parm9;
	else if(index < 10) code = parm10;
	else if(index < 11) code = parm11;
	else if(index < 12) code = parm12;
	else if(index < 13) code = parm13;
	else if(index < 14) code = parm14;
	else if(index < 15) code = parm15;
	else if(index < 16) code = parm16;
	else if(index < 17) code = cvar("scratch1");
	else if(index < 18) code = cvar("scratch2");
	else if(index < 19) code = cvar("scratch3");
	else if(index < 20) code = cvar("scratch4");
	else if(index < 21) code = cvar("saved1");
	else if(index < 22) code = cvar("saved2");
	else if(index < 23) code = cvar("saved3");
	else if(index < 24) code = cvar("saved4");
	lhfp_decode(code);
	vector v;
	v.x = lhfp_code0;
	v.y = lhfp_code1;
	v.z = lhfp_code2;
	if(index >= 16)
		v.y -= 140;
	return v;
}

void lhbitparms_encode_begin(int startindex, int endindex)
{
	lhbitparms_index = startindex;
	lhbitparms_endindex = endindex;
	lhbitparms_code = '0 0 0';
	lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
}

void lhbitparms_encode_finish()
{
	lhbitparms_storeparm(lhbitparms_index, lhbitparms_code);
}

void lhbitparms_decode_begin(int startindex, int endindex)
{
	lhbitparms_index = startindex;
	lhbitparms_endindex = endindex;
	lhbitparms_code = lhbitparms_loadparm(lhbitparms_index);
	lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
}

// returns how many bits of space are left, when encoding
int lhbitparms_totalspace(float index, float endindex)
{
	int total = 0;
	while(index < endindex)
	{
		vector s = lhbitparms_codesize(index);
		while(s.x >= 2)
		{
			total = total + 1;
			s.x *= 0.5;
		}
		while(s.y >= 2)
		{
			total = total + 1;
			s.y *= 0.5;
		}
		while(s.z >= 2)
		{
			total = total + 1;
			s.z *= 0.5;
		}
		index *= 1;
	}
	return total;
}

float lhbitparms_usedspace(float index, float endindex)
{
	int current = 0;
	while(index < endindex)
	{
		vector s = lhbitparms_codesize(index);
		if(index < lhbitparms_index)
		{
			while(s.x >= 2)
			{
				current = current + 1; 
				s.x *= 0.5;
			}
			while(s.y >= 2)
			{
				current = current + 1; 
				s.y *= 0.5;
			}
			while(s.z >= 2)
			{
				current = current + 1; 
				s.z *= 0.5;
			}
		}
		else if(index == lhbitparms_index)
		{
			while(s.x > lhbitparms_scale_x)
			{
				current = current + 1; 
				s.x *= 0.5;
			}
			while(s.y > lhbitparms_scale_y)
			{
				current = current + 1; 
				s.y *= 0.5;
			}
			while(s.z > lhbitparms_scale_z)
			{
				current = current + 1; 
				s.z *= 0.5;
			}
		}
		else
			break;
		index *= 1;
	}
	return current;
}

float lhbitparms_remainingspace(float startindex, float endindex)
{
	int total = lhbitparms_totalspace(startindex, endindex);
	int current = lhbitparms_usedspace(startindex, endindex);
	int remaining = total - current;
	return remaining;
}

void dprint_lhbitparms_space(float startindex, float endindex)
{
	int total = lhbitparms_totalspace(startindex, endindex);
	int current = lhbitparms_usedspace(startindex, endindex);
	int remaining = total - current;
	dprint(ftos(current));
	dprint(" of ");dprint(ftos(total));
	dprint(" bits used, ");dprint(ftos(remaining));
	dprint(" remaining\n");
}

// returns true if the number fit into the buffer, false if it did not
float lhbitparms_encodebits(float n, float radix)
{
	if(lhbitparms_index >= lhbitparms_endindex)
		return false;
	if(n < 0)
		n = 0;
	else if(n >= radix)
		n = radix - 1;
		
	// make sure radix is a power of 2
	while(radix & (radix - 1))
		radix = radix + 1;
	// write bits (in msb to lsb order)
	radix = radix * 0.5;
	while(radix >= 1)
	{
		if(lhbitparms_scale_x >= 2)
		{
			lhbitparms_scale_x = lhbitparms_scale_x * 0.5;
			if(n >= radix)
			{
				lhbitparms_code_x = lhbitparms_code_x + lhbitparms_scale_x;
				n = n - radix;
			}
			radix = radix * 0.5;
		}
		else if(lhbitparms_scale_y >= 2)
		{
			lhbitparms_scale_y = lhbitparms_scale_y * 0.5;
			if(n >= radix)
			{
				lhbitparms_code_y = lhbitparms_code_y + lhbitparms_scale_y;
				n = n - radix;
			}
			radix = radix * 0.5;
		}
		else if(lhbitparms_scale_z >= 2)
		{
			lhbitparms_scale_z = lhbitparms_scale_z * 0.5;
			if(n >= radix)
			{
				lhbitparms_code_z = lhbitparms_code_z + lhbitparms_scale_z;
				n = n - radix;
			}
			radix = radix * 0.5;
		}
		else
		{
			lhbitparms_storeparm(lhbitparms_index, lhbitparms_code);
			lhbitparms_index = lhbitparms_index + 1;
			if(lhbitparms_index >= lhbitparms_endindex)
				return false;
			lhbitparms_code = '0 0 0';
			lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
		}
	}
	return true;
}

// reads a number
float lhbitparms_decodebits(float radix)
{
	float n;
	if(lhbitparms_index >= lhbitparms_endindex)
		return 0;
	// make sure radix is a power of 2
	while(radix & (radix - 1))
		radix = radix + 1;
	// read bits (in msb to lsb order)
	radix = radix * 0.5;
	n = 0;
	while(radix >= 1)
	{
		if(lhbitparms_scale_x >= 2)
		{
			lhbitparms_scale_x = lhbitparms_scale_x * 0.5;
			if(lhbitparms_code_x >= lhbitparms_scale_x)
			{
				lhbitparms_code_x = lhbitparms_code_x - lhbitparms_scale_x;
				n += radix;
			}
			radix = radix * 0.5;
		}
		else if(lhbitparms_scale_y >= 2)
		{
			lhbitparms_scale_y = lhbitparms_scale_y * 0.5;
			if(lhbitparms_code_y >= lhbitparms_scale_y)
			{
				lhbitparms_code_y = lhbitparms_code_y - lhbitparms_scale_y;
				n += radix;
			}
			radix = radix * 0.5;
		}
		else if(lhbitparms_scale_z >= 2)
		{
			lhbitparms_scale_z = lhbitparms_scale_z * 0.5;
			if(lhbitparms_code_z >= lhbitparms_scale_z)
			{
				lhbitparms_code_z = lhbitparms_code_z - lhbitparms_scale_z;
				n += radix;
			}
			radix = radix * 0.5;
		}
		else
		{
			lhbitparms_index = lhbitparms_index + 1;
			if(lhbitparms_index >= lhbitparms_endindex)
				return 0;
			lhbitparms_code = lhbitparms_loadparm(lhbitparms_index);
			lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
		}
	}
	return n;
}

void parm_save_begin(entity this)
{
	string fname;
	
	if(fileaccess)
	{
		if(mplayer)
		{
			fname = this.username;
			fname = strcat(fname, ".pgf");
		}
		else
			fname = "singleplayer.pgg";
		qopenwrite(fname);
		qwrite(ftos(SAVE_VERSION));
		parm1 = 1;
	}
	else
	{
		lhbitparms_encode_begin(0, 23);
	}
}

void parm_save(float val, float radix)
{
	if(fileaccess)
		qwrite(ftos(val));
	else
		lhbitparms_encodebits(val, radix);
}

void parm_save_end()
{
	if(fileaccess)
		qclose();
	else
		lhbitparms_encode_finish();
}

bool parm_load_begin(entity this)
{
	string fname;
	
	if(fileaccess)
	{
		if(mplayer)
		{
			fname = this.username;
			fname = strcat(fname, ".pgf");
		}
		else
			fname = "singleplayer.pgg";
		qopenread(fname);
		if(fileerror)
			return false;
		string s = qread();
		if(stof(s) != SAVE_VERSION)
		{
			qclose();
			return false;
		}
		return true;
	}
	else
	{
		lhbitparms_decode_begin(0, 23);
		//localcmd("echo bitparms\n");
		return true;
	}
}

float parm_load(float radix)
{
	if(fileaccess)
		return stof(qread());
	else
		return lhbitparms_decodebits(radix);	
}

void parm_load_end()
{
	if(fileaccess)
	{
		qclose();
	}
}
