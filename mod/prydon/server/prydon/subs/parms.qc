

/*
LordHavoc's float coder notes
SEEE EEEE EMMM MMMM MMMM MMMM MMMM MMMM
bits[8], bits[23]
float code1; // to be encoded as exponent, 0-250 (stored at +1)
float code2; // to be encoded as mantissa, 0-8388607 (stored at +8388608)
*/

nosave float lhfp_code0; // sign part, TRUE/FALSE allowed
nosave float lhfp_code1; // exponent part, 0-252 range allowed
nosave float lhfp_code2; // mantissa part, 0-8388607 range allowed

float sixteenth = 0.0625; // (1 / 16)

float(float n) lhfp_code1toscale =
{
	local float f;
	f = 1;
	n = n - 126;
	// the n +- 4 cases are just optimizations to process faster
	while (n <= -4)
	{
		n = n + 4;
		f = f * sixteenth;
	}
	while (n < 0)
	{
		n = n + 1;
		f = f * 0.5;
	}
	while (n >= 4)
	{
		n = n - 4;
		f = f * 16;
	}
	while (n > 0)
	{
		n = n - 1;
		f = f * 2;
	}
	return f;
};

float(float f) lhfp_scaletocode1 =
{
	local float n;
	n = 126;
	// the n +- 4 cases are just optimizations to process faster
	// the < n and > checks are to prevent runaway loops
	while (f >= 16 && n < 254)
	{
		n = n + 4;
		f = f * sixteenth;
	}
	while (f >= 2 && n < 254)
	{
		n = n + 1;
		f = f * 0.5;
	}
	while (f < sixteenth && n > 0)
	{
		n = n - 4;
		f = f * 16;
	}
	while (f < 1 && n > 0)
	{
		n = n - 1;
		f = f * 2;
	}
	return n;
};

float(float code0, float code1, float code2) lhfp_encode =
{
	local float code;
	if (code1 != floor(code1) || code1 < 0 || code1 >= 254)
		error("lhfp_encode: invalid code1, must be an integer in the range 0-253.\n");
	if (code2 != floor(code2) || code2 < 0 || code2 >= 8388608)
		error("lhfp_encode: invalid code2, must be an integer in the range 0-8388607.\n");
	code = (1 + (code2 / 8388608)) * lhfp_code1toscale(code1);
	if (code0)
		code = 0 - code;
	return code;
};

float(float code) lhfp_decode =
{
	// code == 0 never occurs on a valid encoded value, we'll just assume it's garbage here.
	if (code == 0)
	{
		// invalid code
		lhfp_code0 = FALSE;
		lhfp_code1 = 0;
		lhfp_code2 = 0;
		return FALSE;
	}
	if (code < 0)
	{
		code = 0 - code;
		lhfp_code0 = TRUE;
	}
	else
		lhfp_code0 = FALSE;
	lhfp_code1 = lhfp_scaletocode1(code);
	if (lhfp_code1 < 0 || lhfp_code1 >= 254)
	{
		// invalid exponent
		lhfp_code0 = FALSE;
		lhfp_code1 = 0;
		lhfp_code2 = 0;
		return FALSE;
	}
	lhfp_code2 = ((code / lhfp_code1toscale(lhfp_code1)) - 1) * 8388608;
	return TRUE;
};

nosave float lhbitparms_index;
nosave float lhbitparms_endindex;
nosave vector lhbitparms_code, lhbitparms_scale;

vector(float index) lhbitparms_codesize =
{
	if (index < 16)
		return '2 128 8388608';
	else
		return '2 64 8388608';
};

void(float index, vector v) lhbitparms_storeparm =
{
	local float code;
	if (index >= 16)
		v = v + '0 140 0';
	code = lhfp_encode(v_x, v_y, v_z);
		 if (index <  1) parm1 = code;
	else if (index <  2) parm2 = code;
	else if (index <  3) parm3 = code;
	else if (index <  4) parm4 = code;
	else if (index <  5) parm5 = code;
	else if (index <  6) parm6 = code;
	else if (index <  7) parm7 = code;
	else if (index <  8) parm8 = code;
	else if (index <  9) parm9 = code;
	else if (index < 10) parm10 = code;
	else if (index < 11) parm11 = code;
	else if (index < 12) parm12 = code;
	else if (index < 13) parm13 = code;
	else if (index < 14) parm14 = code;
	else if (index < 15) parm15 = code;
	else if (index < 16) parm16 = code;
	else if (index < 17) cvar_set("scratch1", ftos(code));
	else if (index < 18) cvar_set("scratch2", ftos(code));
	else if (index < 19) cvar_set("scratch3", ftos(code));
	else if (index < 20) cvar_set("scratch4", ftos(code));
	else if (index < 21) cvar_set("saved1", ftos(code));
	else if (index < 22) cvar_set("saved2", ftos(code));
	else if (index < 23) cvar_set("saved3", ftos(code));
	else if (index < 24) cvar_set("saved4", ftos(code));
};

vector(float index) lhbitparms_loadparm =
{
	local float code;
	local vector v;
	     if (index <  1) code = parm1;
	else if (index <  2) code = parm2;
	else if (index <  3) code = parm3;
	else if (index <  4) code = parm4;
	else if (index <  5) code = parm5;
	else if (index <  6) code = parm6;
	else if (index <  7) code = parm7;
	else if (index <  8) code = parm8;
	else if (index <  9) code = parm9;
	else if (index < 10) code = parm10;
	else if (index < 11) code = parm11;
	else if (index < 12) code = parm12;
	else if (index < 13) code = parm13;
	else if (index < 14) code = parm14;
	else if (index < 15) code = parm15;
	else if (index < 16) code = parm16;
	else if (index < 17) code = cvar("scratch1");
	else if (index < 18) code = cvar("scratch2");
	else if (index < 19) code = cvar("scratch3");
	else if (index < 20) code = cvar("scratch4");
	else if (index < 21) code = cvar("saved1");
	else if (index < 22) code = cvar("saved2");
	else if (index < 23) code = cvar("saved3");
	else if (index < 24) code = cvar("saved4");
	lhfp_decode(code);
	v_x = lhfp_code0;
	v_y = lhfp_code1;
	v_z = lhfp_code2;
	if (index >= 16)
		v_y = v_y - 140;
	return v;
};

void(float startindex, float endindex) lhbitparms_encode_begin =
{
	lhbitparms_index = startindex;
	lhbitparms_endindex = endindex;
	lhbitparms_code = '0 0 0';
	lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
};

void() lhbitparms_encode_finish =
{
	lhbitparms_storeparm(lhbitparms_index, lhbitparms_code);
};

void(float startindex, float endindex) lhbitparms_decode_begin =
{
	lhbitparms_index = startindex;
	lhbitparms_endindex = endindex;
	lhbitparms_code = lhbitparms_loadparm(lhbitparms_index);
	lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
};



// returns how many bits of space are left, when encoding
float(float index, float endindex) lhbitparms_totalspace =
{
	local float total;
	local vector s;
	total = 0;
	while (index < endindex)
	{
		s = lhbitparms_codesize(index);
		while (s_x >= 2)
		{
			total = total + 1;
			s_x = s_x * 0.5;
		}
		while (s_y >= 2)
		{
			total = total + 1;
			s_y = s_y * 0.5;
		}
		while (s_z >= 2)
		{
			total = total + 1;
			s_z = s_z * 0.5;
		}
		index = index + 1;
	}
	return total;
};

float(float index, float endindex) lhbitparms_usedspace =
{
	local float current;
	local vector s;
	current = 0;
	while (index < endindex)
	{
		s = lhbitparms_codesize(index);
		if (index < lhbitparms_index)
		{
			while (s_x >= 2)
			{
				current = current + 1; 
				s_x = s_x * 0.5;
			}
			while (s_y >= 2)
			{
				current = current + 1; 
				s_y = s_y * 0.5;
			}
			while (s_z >= 2)
			{
				current = current + 1; 
				s_z = s_z * 0.5;
			}
		}
		else if (index == lhbitparms_index)
		{
			while (s_x > lhbitparms_scale_x)
			{
				current = current + 1; 
				s_x = s_x * 0.5;
			}
			while (s_y > lhbitparms_scale_y)
			{
				current = current + 1; 
				s_y = s_y * 0.5;
			}
			while (s_z > lhbitparms_scale_z)
			{
				current = current + 1; 
				s_z = s_z * 0.5;
			}
		}
		else
			break;
		index = index + 1;
	}
	return current;
}

float(float startindex, float endindex) lhbitparms_remainingspace =
{
	local float remaining, current, total;
	total = lhbitparms_totalspace(startindex, endindex);
	current = lhbitparms_usedspace(startindex, endindex);
	remaining = total - current;
	return remaining;
}

void(float startindex, float endindex) dprint_lhbitparms_space =
{
	local float remaining, current, total;
	total = lhbitparms_totalspace(startindex, endindex);
	current = lhbitparms_usedspace(startindex, endindex);
	remaining = total - current;
	dprint(ftos(current));
	dprint(" of ");dprint(ftos(total));
	dprint(" bits used, ");dprint(ftos(remaining));
	dprint(" remaining\n");
};

// returns TRUE if the number fit into the buffer, FALSE if it did not
float(float n, float radix) lhbitparms_encodebits =
{
	if (lhbitparms_index >= lhbitparms_endindex)
		return FALSE;
	if (n < 0)
		n = 0;
	else if (n >= radix)
		n = radix - 1;
		
	// make sure radix is a power of 2
	while (radix & (radix - 1))
		radix = radix + 1;
	// write bits (in msb to lsb order)
	radix = radix * 0.5;
	while (radix >= 1)
	{
		if (lhbitparms_scale_x >= 2)
		{
			lhbitparms_scale_x = lhbitparms_scale_x * 0.5;
			if (n >= radix)
			{
				lhbitparms_code_x = lhbitparms_code_x + lhbitparms_scale_x;
				n = n - radix;
			}
			radix = radix * 0.5;
		}
		else if (lhbitparms_scale_y >= 2)
		{
			lhbitparms_scale_y = lhbitparms_scale_y * 0.5;
			if (n >= radix)
			{
				lhbitparms_code_y = lhbitparms_code_y + lhbitparms_scale_y;
				n = n - radix;
			}
			radix = radix * 0.5;
		}
		else if (lhbitparms_scale_z >= 2)
		{
			lhbitparms_scale_z = lhbitparms_scale_z * 0.5;
			if (n >= radix)
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
			if (lhbitparms_index >= lhbitparms_endindex)
				return FALSE;
			lhbitparms_code = '0 0 0';
			lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
		}
	}
	return TRUE;
};

// reads a number
float(float radix) lhbitparms_decodebits =
{
	local float n;
	if (lhbitparms_index >= lhbitparms_endindex)
		return 0;
	// make sure radix is a power of 2
	while (radix & (radix - 1))
		radix = radix + 1;
	// read bits (in msb to lsb order)
	radix = radix * 0.5;
	n = 0;
	while (radix >= 1)
	{
		if (lhbitparms_scale_x >= 2)
		{
			lhbitparms_scale_x = lhbitparms_scale_x * 0.5;
			if (lhbitparms_code_x >= lhbitparms_scale_x)
			{
				lhbitparms_code_x = lhbitparms_code_x - lhbitparms_scale_x;
				n = n + radix;
			}
			radix = radix * 0.5;
		}
		else if (lhbitparms_scale_y >= 2)
		{
			lhbitparms_scale_y = lhbitparms_scale_y * 0.5;
			if (lhbitparms_code_y >= lhbitparms_scale_y)
			{
				lhbitparms_code_y = lhbitparms_code_y - lhbitparms_scale_y;
				n = n + radix;
			}
			radix = radix * 0.5;
		}
		else if (lhbitparms_scale_z >= 2)
		{
			lhbitparms_scale_z = lhbitparms_scale_z * 0.5;
			if (lhbitparms_code_z >= lhbitparms_scale_z)
			{
				lhbitparms_code_z = lhbitparms_code_z - lhbitparms_scale_z;
				n = n + radix;
			}
			radix = radix * 0.5;
		}
		else
		{
			lhbitparms_index = lhbitparms_index + 1;
			if (lhbitparms_index >= lhbitparms_endindex)
				return 0;
			lhbitparms_code = lhbitparms_loadparm(lhbitparms_index);
			lhbitparms_scale = lhbitparms_codesize(lhbitparms_index);
		}
	}
	return n;
};

void() parm_save_begin =
{
	string fname;
	
	if (fileaccess)
	{
		if (mplayer)
		{
			fname = self.username;
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
};

void(float val, float radix) parm_save =
{
	if (fileaccess)
		qwrite(ftos(val));
	else
		lhbitparms_encodebits(val, radix);
};

void() parm_save_end =
{
	if (fileaccess)
		qclose();
	else
		lhbitparms_encode_finish();
};

float() parm_load_begin =
{

	string fname;
	local string s;
	
	if (fileaccess)
	{
		if (mplayer)
		{
			fname = self.username;
			fname = strcat(fname, ".pgf");
		}
		else
			fname = "singleplayer.pgg";
		qopenread(fname);
		if (fileerror)
			return 0;
		s = qread();
		if (stof(s) != SAVE_VERSION)
		{
			qclose();
			return 0;
		}
		return 1;
	}
	else
	{
		lhbitparms_decode_begin(0, 23);
		//localcmd("echo bitparms\n");
		return 1;
	}
};

float(float radix) parm_load =
{
	if (fileaccess)
		return stof(qread());
	else
		return lhbitparms_decodebits(radix);	
};

void() parm_load_end =
{
	if (fileaccess)
	{
		qclose();
	}
};