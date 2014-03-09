string wordwrap_buffer;

void wordwrap_buffer_put(string s)
{
	wordwrap_buffer = strcat(wordwrap_buffer, s);
}

string wordwrap(string s, float l)
{
	string r;
	wordwrap_buffer = "";
	wordwrap_cb(s, l, wordwrap_buffer_put);
	r = wordwrap_buffer;
	wordwrap_buffer = "";
	return r;
}

#ifndef MENUQC
#ifndef CSQC
void wordwrap_buffer_sprint(string s)
{
	wordwrap_buffer = strcat(wordwrap_buffer, s);
	if(s == "\n")
	{
		sprint(self, wordwrap_buffer);
		wordwrap_buffer = "";
	}
}

void wordwrap_sprint(string s, float l)
{
	wordwrap_buffer = "";
	wordwrap_cb(s, l, wordwrap_buffer_sprint);
	if(wordwrap_buffer != "")
		sprint(self, strcat(wordwrap_buffer, "\n"));
	wordwrap_buffer = "";
	return;
}
#endif
#endif

#ifndef SVQC
string draw_UseSkinFor(string pic)
{
	if(substring(pic, 0, 1) == "/")
		return substring(pic, 1, strlen(pic)-1);
	else
		return strcat(draw_currentSkin, "/", pic);
}
#endif

string unescape(string in)
{
	float i, len;
	string str, s;

	// but it doesn't seem to be necessary in my tests at least
	in = strzone(in);

	len = strlen(in);
	str = "";
	for(i = 0; i < len; ++i)
	{
		s = substring(in, i, 1);
		if(s == "\\")
		{
			s = substring(in, i+1, 1);
			if(s == "n")
				str = strcat(str, "\n");
			else if(s == "\\")
				str = strcat(str, "\\");
			else
				str = strcat(str, substring(in, i, 2));
			++i;
		} else
			str = strcat(str, s);
	}

	strunzone(in);
	return str;
}

void wordwrap_cb(string s, float l, void(string) callback)
{
	string c;
	float lleft, i, j, wlen;

	s = strzone(s);
	lleft = l;
	for (i = 0;i < strlen(s);++i)
	{
		if (substring(s, i, 2) == "\\n")
		{
			callback("\n");
			lleft = l;
			++i;
		}
		else if (substring(s, i, 1) == "\n")
		{
			callback("\n");
			lleft = l;
		}
		else if (substring(s, i, 1) == " ")
		{
			if (lleft > 0)
			{
				callback(" ");
				lleft = lleft - 1;
			}
		}
		else
		{
			for (j = i+1;j < strlen(s);++j)
				//    ^^ this skips over the first character of a word, which
				//       is ALWAYS part of the word
				//       this is safe since if i+1 == strlen(s), i will become
				//       strlen(s)-1 at the end of this block and the function
				//       will terminate. A space can't be the first character we
				//       read here, and neither can a \n be the start, since these
				//       two cases have been handled above.
			{
				c = substring(s, j, 1);
				if (c == " ")
					break;
				if (c == "\\")
					break;
				if (c == "\n")
					break;
				// we need to keep this tempstring alive even if substring is
				// called repeatedly, so call strcat even though we're not
				// doing anything
				callback("");
			}
			wlen = j - i;
			if (lleft < wlen)
			{
				callback("\n");
				lleft = l;
			}
			callback(substring(s, i, wlen));
			lleft = lleft - wlen;
			i = j - 1;
		}
	}
	strunzone(s);
}

float dist_point_line(vector p, vector l0, vector ldir)
{
	ldir = normalize(ldir);

	// remove the component in line direction
	p = p - (p * ldir) * ldir;

	// vlen of the remaining vector
	return vlen(p);
}

void depthfirst(entity start, .entity up, .entity downleft, .entity right, void(entity, entity) funcPre, void(entity, entity) funcPost, entity pass)
{
	entity e;
	e = start;
	funcPre(pass, e);
	while(e.downleft)
	{
		e = e.downleft;
		funcPre(pass, e);
	}
	funcPost(pass, e);
	while(e != start)
	{
		if(e.right)
		{
			e = e.right;
			funcPre(pass, e);
			while(e.downleft)
			{
				e = e.downleft;
				funcPre(pass, e);
			}
		}
		else
			e = e.up;
		funcPost(pass, e);
	}
}

float median(float a, float b, float c)
{
	if(a < c)
		return bound(a, b, c);
	return bound(c, b, a);
}

// converts a number to a string with the indicated number of decimals
// works for up to 10 decimals!
string ftos_decimals(float number, float decimals)
{
	// inhibit stupid negative zero
	if(number == 0)
		number = 0;
	// we have sprintf...
	return sprintf("%.*f", decimals, number);
}

vector colormapPaletteColor(float c, float isPants)
{
	switch(c)
	{
		case  0: return '1.000000 1.000000 1.000000';
		case  1: return '1.000000 0.333333 0.000000';
		case  2: return '0.000000 1.000000 0.501961';
		case  3: return '0.000000 1.000000 0.000000';
		case  4: return '1.000000 0.000000 0.000000';
		case  5: return '0.000000 0.666667 1.000000';
		case  6: return '0.000000 1.000000 1.000000';
		case  7: return '0.501961 1.000000 0.000000';
		case  8: return '0.501961 0.000000 1.000000';
		case  9: return '1.000000 0.000000 1.000000';
		case 10: return '1.000000 0.000000 0.501961';
		case 11: return '0.000000 0.000000 1.000000';
		case 12: return '1.000000 1.000000 0.000000';
		case 13: return '0.000000 0.333333 1.000000';
		case 14: return '1.000000 0.666667 0.000000';
		case 15:
			if(isPants)
				return
					  '1 0 0' * (0.502 + 0.498 * sin(time / 2.7182818285 + 0.0000000000))
					+ '0 1 0' * (0.502 + 0.498 * sin(time / 2.7182818285 + 2.0943951024))
					+ '0 0 1' * (0.502 + 0.498 * sin(time / 2.7182818285 + 4.1887902048));
			else
				return
					  '1 0 0' * (0.502 + 0.498 * sin(time / 3.1415926536 + 5.2359877560))
					+ '0 1 0' * (0.502 + 0.498 * sin(time / 3.1415926536 + 3.1415926536))
					+ '0 0 1' * (0.502 + 0.498 * sin(time / 3.1415926536 + 1.0471975512));
		default: return '0.000 0.000 0.000';
	}
}

// unzone the string, and return it as tempstring. Safe to be called on string_null
string fstrunzone(string s)
{
	string sc;
	if (!s)
		return s;
	sc = strcat(s, "");
	strunzone(s);
	return sc;
}

float fexists(string f)
{
    float fh;
    fh = fopen(f, FILE_READ);
    if (fh < 0)
        return FALSE;
    fclose(fh);
    return TRUE;
}

// Databases (hash tables)
#define DB_BUCKETS 8192
void db_save(float db, string pFilename)
{
	float fh, i, n;
	fh = fopen(pFilename, FILE_WRITE);
	if(fh < 0)
	{
		print(strcat("^1Can't write DB to ", pFilename));
		return;
	}
	n = buf_getsize(db);
	fputs(fh, strcat(ftos(DB_BUCKETS), "\n"));
	for(i = 0; i < n; ++i)
		fputs(fh, strcat(bufstr_get(db, i), "\n"));
	fclose(fh);
}

float db_create()
{
	return buf_create();
}

float db_load(string pFilename)
{
	float db, fh, i, j, n;
	string l;
	db = buf_create();
	if(db < 0)
		return -1;
	fh = fopen(pFilename, FILE_READ);
	if(fh < 0)
		return db;
	l = fgets(fh);
	if(stof(l) == DB_BUCKETS)
	{
		i = 0;
		while((l = fgets(fh)))
		{
			if(l != "")
				bufstr_set(db, i, l);
			++i;
		}
	}
	else
	{
		// different count of buckets, or a dump?
		// need to reorganize the database then (SLOW)
		//
		// note: we also parse the first line (l) in case the DB file is
		// missing the bucket count
		do
		{
			n = tokenizebyseparator(l, "\\");
			for(j = 2; j < n; j += 2)
				db_put(db, argv(j-1), uri_unescape(argv(j)));
		}
		while((l = fgets(fh)));
	}
	fclose(fh);
	return db;
}

void db_dump(float db, string pFilename)
{
	float fh, i, j, n, m;
	fh = fopen(pFilename, FILE_WRITE);
	if(fh < 0)
		error(strcat("Can't dump DB to ", pFilename));
	n = buf_getsize(db);
	fputs(fh, "0\n");
	for(i = 0; i < n; ++i)
	{
		m = tokenizebyseparator(bufstr_get(db, i), "\\");
		for(j = 2; j < m; j += 2)
			fputs(fh, strcat("\\", argv(j-1), "\\", argv(j), "\n"));
	}
	fclose(fh);
}

void db_close(float db)
{
	buf_del(db);
}

string db_get(float db, string pKey)
{
	float h;
	h = mod(crc16(FALSE, pKey), DB_BUCKETS);
	return uri_unescape(infoget(bufstr_get(db, h), pKey));
}

void db_put(float db, string pKey, string pValue)
{
	float h;
	h = mod(crc16(FALSE, pKey), DB_BUCKETS);
	bufstr_set(db, h, infoadd(bufstr_get(db, h), pKey, uri_escape(pValue)));
}

void db_test()
{
	float db, i;
	print("LOAD...\n");
	db = db_load("foo.db");
	print("LOADED. FILL...\n");
	for(i = 0; i < DB_BUCKETS; ++i)
		db_put(db, ftos(random()), "X");
	print("FILLED. SAVE...\n");
	db_save(db, "foo.db");
	print("SAVED. CLOSE...\n");
	db_close(db);
	print("CLOSED.\n");
}

// Multiline text file buffers
float buf_load(string pFilename)
{
	float buf, fh, i;
	string l;
	buf = buf_create();
	if(buf < 0)
		return -1;
	fh = fopen(pFilename, FILE_READ);
	if(fh < 0)
	{
		buf_del(buf);
		return -1;
	}
	i = 0;
	while((l = fgets(fh)))
	{
		bufstr_set(buf, i, l);
		++i;
	}
	fclose(fh);
	return buf;
}

void buf_save(float buf, string pFilename)
{
	float fh, i, n;
	fh = fopen(pFilename, FILE_WRITE);
	if(fh < 0)
		error(strcat("Can't write buf to ", pFilename));
	n = buf_getsize(buf);
	for(i = 0; i < n; ++i)
		fputs(fh, strcat(bufstr_get(buf, i), "\n"));
	fclose(fh);
}

string mmsss(float tenths)
{
	float minutes;
	string s;
	tenths = floor(tenths + 0.5);
	minutes = floor(tenths / 600);
	tenths -= minutes * 600;
	s = ftos(1000 + tenths);
	return strcat(ftos(minutes), ":", substring(s, 1, 2), ".", substring(s, 3, 1));
}

string mmssss(float hundredths)
{
	float minutes;
	string s;
	hundredths = floor(hundredths + 0.5);
	minutes = floor(hundredths / 6000);
	hundredths -= minutes * 6000;
	s = ftos(10000 + hundredths);
	return strcat(ftos(minutes), ":", substring(s, 1, 2), ".", substring(s, 3, 2));
}

string ScoreString(float pFlags, float pValue)
{
	string valstr;
	float l;

	pValue = floor(pValue + 0.5); // round

	if((pValue == 0) && (pFlags & (SFL_HIDE_ZERO | SFL_RANK | SFL_TIME)))
		valstr = "";
	else if(pFlags & SFL_RANK)
	{
		valstr = ftos(pValue);
		l = strlen(valstr);
		if((l >= 2) && (substring(valstr, l - 2, 1) == "1"))
			valstr = strcat(valstr, "th");
		else if(substring(valstr, l - 1, 1) == "1")
			valstr = strcat(valstr, "st");
		else if(substring(valstr, l - 1, 1) == "2")
			valstr = strcat(valstr, "nd");
		else if(substring(valstr, l - 1, 1) == "3")
			valstr = strcat(valstr, "rd");
		else
			valstr = strcat(valstr, "th");
	}
	else if(pFlags & SFL_TIME)
		valstr = TIME_ENCODED_TOSTRING(pValue);
	else
		valstr = ftos(pValue);

	return valstr;
}

float dotproduct(vector a, vector b)
{
	return a_x * b_x + a_y * b_y + a_z * b_z;
}

vector cross(vector a, vector b)
{
	return
		'1 0 0' * (a_y * b_z - a_z * b_y)
	+	'0 1 0' * (a_z * b_x - a_x * b_z)
	+	'0 0 1' * (a_x * b_y - a_y * b_x);
}

// compressed vector format:
// like MD3, just even shorter
//   4 bit pitch (16 angles), 0 is -90, 8 is 0, 16 would be 90
//   5 bit yaw (32 angles), 0=0, 8=90, 16=180, 24=270
//   7 bit length (logarithmic encoding), 1/8 .. about 7844
//     length = 2^(length_encoded/8) / 8
// if pitch is 90, yaw does nothing and therefore indicates the sign (yaw is then either 11111 or 11110); 11111 is pointing DOWN
// thus, valid values are from 0000.11110.0000000 to 1111.11111.1111111
// the special value 0 indicates the zero vector

float lengthLogTable[128];

float invertLengthLog(float x)
{
	float l, r, m, lerr, rerr;

	if(x >= lengthLogTable[127])
		return 127;
	if(x <= lengthLogTable[0])
		return 0;

	l = 0;
	r = 127;

	while(r - l > 1)
	{
		m = floor((l + r) / 2);
		if(lengthLogTable[m] < x)
			l = m;
		else
			r = m;
	}

	// now: r is >=, l is <
	lerr = (x - lengthLogTable[l]);
	rerr = (lengthLogTable[r] - x);
	if(lerr < rerr)
		return l;
	return r;
}

vector decompressShortVector(float data)
{
	vector out;
	float p, y, len;
	if(data == 0)
		return '0 0 0';
	p   = (data & 0xF000) / 0x1000;
	y   = (data & 0x0F80) / 0x80;
	len = (data & 0x007F);

	//print("\ndecompress: p ", ftos(p)); print("y ", ftos(y)); print("len ", ftos(len), "\n");

	if(p == 0)
	{
		out_x = 0;
		out_y = 0;
		if(y == 31)
			out_z = -1;
		else
			out_z = +1;
	}
	else
	{
		y   = .19634954084936207740 * y;
		p = .19634954084936207740 * p - 1.57079632679489661922;
		out_x = cos(y) *  cos(p);
		out_y = sin(y) *  cos(p);
		out_z =          -sin(p);
	}

	//print("decompressed: ", vtos(out), "\n");

	return out * lengthLogTable[len];
}

float compressShortVector(vector vec)
{
	vector ang;
	float p, y, len;
	if(vlen(vec) == 0)
		return 0;
	//print("compress: ", vtos(vec), "\n");
	ang = vectoangles(vec);
	ang_x = -ang_x;
	if(ang_x < -90)
		ang_x += 360;
	if(ang_x < -90 && ang_x > +90)
		error("BOGUS vectoangles");
	//print("angles: ", vtos(ang), "\n");

	p = floor(0.5 + (ang_x + 90) * 16 / 180) & 15; // -90..90 to 0..14
	if(p == 0)
	{
		if(vec_z < 0)
			y = 31;
		else
			y = 30;
	}
	else
		y = floor(0.5 + ang_y * 32 / 360)          & 31; // 0..360 to 0..32
	len = invertLengthLog(vlen(vec));

	//print("compressed: p ", ftos(p)); print("y ", ftos(y)); print("len ", ftos(len), "\n");

	return (p * 0x1000) + (y * 0x80) + len;
}

void compressShortVector_init()
{
	float l, f, i;
	l = 1;
	f = pow(2, 1/8);
	for(i = 0; i < 128; ++i)
	{
		lengthLogTable[i] = l;
		l *= f;
	}

	if(cvar("developer"))
	{
		print("Verifying vector compression table...\n");
		for(i = 0x0F00; i < 0xFFFF; ++i)
			if(i != compressShortVector(decompressShortVector(i)))
			{
				print("BROKEN vector compression: ", ftos(i));
				print(" -> ", vtos(decompressShortVector(i)));
				print(" -> ", ftos(compressShortVector(decompressShortVector(i))));
				print("\n");
				error("b0rk");
			}
		print("Done.\n");
	}
}

#ifndef MENUQC
float CheckWireframeBox(entity forent, vector v0, vector dvx, vector dvy, vector dvz)
{
	traceline(v0, v0 + dvx, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0, v0 + dvy, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0, v0 + dvz, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvx, v0 + dvx + dvy, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvx, v0 + dvx + dvz, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvy, v0 + dvy + dvx, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvy, v0 + dvy + dvz, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvz, v0 + dvz + dvx, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvz, v0 + dvz + dvy, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvx + dvy, v0 + dvx + dvy + dvz, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvx + dvz, v0 + dvx + dvy + dvz, TRUE, forent); if(trace_fraction < 1) return 0;
	traceline(v0 + dvy + dvz, v0 + dvx + dvy + dvz, TRUE, forent); if(trace_fraction < 1) return 0;
	return 1;
}
#endif

string fixPriorityList(string order, float from, float to, float subtract, float complete)
{
	string neworder;
	float i, n, w;

	n = tokenize_console(order);
	neworder = "";
	for(i = 0; i < n; ++i)
	{
		w = stof(argv(i));
		if(w == floor(w))
		{
			if(w >= from && w <= to)
				neworder = strcat(neworder, ftos(w), " ");
			else
			{
				w -= subtract;
				if(w >= from && w <= to)
					neworder = strcat(neworder, ftos(w), " ");
			}
		}
	}

	if(complete)
	{
		n = tokenize_console(neworder);
		for(w = to; w >= from; --w)
		{
			for(i = 0; i < n; ++i)
				if(stof(argv(i)) == w)
					break;
			if(i == n) // not found
				neworder = strcat(neworder, ftos(w), " ");
		}
	}

	return substring(neworder, 0, strlen(neworder) - 1);
}

string mapPriorityList(string order, string(string) mapfunc)
{
	string neworder;
	float i, n;

	n = tokenize_console(order);
	neworder = "";
	for(i = 0; i < n; ++i)
		neworder = strcat(neworder, mapfunc(argv(i)), " ");

	return substring(neworder, 0, strlen(neworder) - 1);
}

string swapInPriorityList(string order, float i, float j)
{
	string s;
	float w, n;

	n = tokenize_console(order);

	if(i >= 0 && i < n && j >= 0 && j < n && i != j)
	{
		s = "";
		for(w = 0; w < n; ++w)
		{
			if(w == i)
				s = strcat(s, argv(j), " ");
			else if(w == j)
				s = strcat(s, argv(i), " ");
			else
				s = strcat(s, argv(w), " ");
		}
		return substring(s, 0, strlen(s) - 1);
	}

	return order;
}

float cvar_value_issafe(string s)
{
	if(strstrofs(s, "\"", 0) >= 0)
		return 0;
	if(strstrofs(s, "\\", 0) >= 0)
		return 0;
	if(strstrofs(s, ";", 0) >= 0)
		return 0;
	if(strstrofs(s, "$", 0) >= 0)
		return 0;
	if(strstrofs(s, "\r", 0) >= 0)
		return 0;
	if(strstrofs(s, "\n", 0) >= 0)
		return 0;
	return 1;
}

#ifndef MENUQC
void get_mi_min_max(float mode)
{
	vector mi, ma;

	if(mi_shortname)
		strunzone(mi_shortname);
	mi_shortname = mapname;
	if(!strcasecmp(substring(mi_shortname, 0, 5), "maps/"))
		mi_shortname = substring(mi_shortname, 5, strlen(mi_shortname) - 5);
	if(!strcasecmp(substring(mi_shortname, strlen(mi_shortname) - 4, 4), ".bsp"))
		mi_shortname = substring(mi_shortname, 0, strlen(mi_shortname) - 4);
	mi_shortname = strzone(mi_shortname);

#ifdef CSQC
	mi = world.mins;
	ma = world.maxs;
#else
	mi = world.absmin;
	ma = world.absmax;
#endif

	mi_min = mi;
	mi_max = ma;
	MapInfo_Get_ByName(mi_shortname, 0, 0);
	if(MapInfo_Map_mins_x < MapInfo_Map_maxs_x)
	{
		mi_min = MapInfo_Map_mins;
		mi_max = MapInfo_Map_maxs;
	}
	else
	{
		// not specified
		if(mode)
		{
			// be clever
			tracebox('1 0 0' * mi_x,
					 '0 1 0' * mi_y + '0 0 1' * mi_z,
					 '0 1 0' * ma_y + '0 0 1' * ma_z,
					 '1 0 0' * ma_x,
					 MOVE_WORLDONLY,
					 world);
			if(!trace_startsolid)
				mi_min_x = trace_endpos_x;

			tracebox('0 1 0' * mi_y,
					 '1 0 0' * mi_x + '0 0 1' * mi_z,
					 '1 0 0' * ma_x + '0 0 1' * ma_z,
					 '0 1 0' * ma_y,
					 MOVE_WORLDONLY,
					 world);
			if(!trace_startsolid)
				mi_min_y = trace_endpos_y;

			tracebox('0 0 1' * mi_z,
					 '1 0 0' * mi_x + '0 1 0' * mi_y,
					 '1 0 0' * ma_x + '0 1 0' * ma_y,
					 '0 0 1' * ma_z,
					 MOVE_WORLDONLY,
					 world);
			if(!trace_startsolid)
				mi_min_z = trace_endpos_z;

			tracebox('1 0 0' * ma_x,
					 '0 1 0' * mi_y + '0 0 1' * mi_z,
					 '0 1 0' * ma_y + '0 0 1' * ma_z,
					 '1 0 0' * mi_x,
					 MOVE_WORLDONLY,
					 world);
			if(!trace_startsolid)
				mi_max_x = trace_endpos_x;

			tracebox('0 1 0' * ma_y,
					 '1 0 0' * mi_x + '0 0 1' * mi_z,
					 '1 0 0' * ma_x + '0 0 1' * ma_z,
					 '0 1 0' * mi_y,
					 MOVE_WORLDONLY,
					 world);
			if(!trace_startsolid)
				mi_max_y = trace_endpos_y;

			tracebox('0 0 1' * ma_z,
					 '1 0 0' * mi_x + '0 1 0' * mi_y,
					 '1 0 0' * ma_x + '0 1 0' * ma_y,
					 '0 0 1' * mi_z,
					 MOVE_WORLDONLY,
					 world);
			if(!trace_startsolid)
				mi_max_z = trace_endpos_z;
		}
	}
}

void get_mi_min_max_texcoords(float mode)
{
	vector extend;

	get_mi_min_max(mode);

	mi_picmin = mi_min;
	mi_picmax = mi_max;

	// extend mi_picmax to get a square aspect ratio
	// center the map in that area
	extend = mi_picmax - mi_picmin;
	if(extend_y > extend_x)
	{
		mi_picmin_x -= (extend_y - extend_x) * 0.5;
		mi_picmax_x += (extend_y - extend_x) * 0.5;
	}
	else
	{
		mi_picmin_y -= (extend_x - extend_y) * 0.5;
		mi_picmax_y += (extend_x - extend_y) * 0.5;
	}

	// add another some percent
	extend = (mi_picmax - mi_picmin) * (1 / 64.0);
	mi_picmin -= extend;
	mi_picmax += extend;

	// calculate the texcoords
	mi_pictexcoord0 = mi_pictexcoord1 = mi_pictexcoord2 = mi_pictexcoord3 = '0 0 0';
	// first the two corners of the origin
	mi_pictexcoord0_x = (mi_min_x - mi_picmin_x) / (mi_picmax_x - mi_picmin_x);
	mi_pictexcoord0_y = (mi_min_y - mi_picmin_y) / (mi_picmax_y - mi_picmin_y);
	mi_pictexcoord2_x = (mi_max_x - mi_picmin_x) / (mi_picmax_x - mi_picmin_x);
	mi_pictexcoord2_y = (mi_max_y - mi_picmin_y) / (mi_picmax_y - mi_picmin_y);
	// then the other corners
	mi_pictexcoord1_x = mi_pictexcoord0_x;
	mi_pictexcoord1_y = mi_pictexcoord2_y;
	mi_pictexcoord3_x = mi_pictexcoord2_x;
	mi_pictexcoord3_y = mi_pictexcoord0_y;
}
#endif

float cvar_settemp(string tmp_cvar, string tmp_value)
{
	float created_saved_value;
	entity e;

	created_saved_value = 0;

	if (!(tmp_cvar || tmp_value))
	{
		dprint("Error: Invalid usage of cvar_settemp(string, string); !\n");
		return 0;
	}

	if(!cvar_type(tmp_cvar))
	{
		printf("Error: cvar %s doesn't exist!\n", tmp_cvar);
		return 0;
	}

	for(e = world; (e = find(e, classname, "saved_cvar_value")); )
		if(e.netname == tmp_cvar)
			created_saved_value = -1; // skip creation

	if(created_saved_value != -1)
	{
		// creating a new entity to keep track of this cvar
		e = spawn();
		e.classname = "saved_cvar_value";
		e.netname = strzone(tmp_cvar);
		e.message = strzone(cvar_string(tmp_cvar));
		created_saved_value = 1;
	}

	// update the cvar to the value given
	cvar_set(tmp_cvar, tmp_value);

	return created_saved_value;
}

float cvar_settemp_restore()
{
	float i = 0;
	entity e = world;
	while((e = find(e, classname, "saved_cvar_value")))
	{
		if(cvar_type(e.netname))
		{
			cvar_set(e.netname, e.message);
			remove(e);
			++i;
		}
		else
			printf("Error: cvar %s doesn't exist anymore! It can still be restored once it's manually recreated.\n", e.netname);
	}

	return i;
}

float almost_equals(float a, float b)
{
	float eps;
	eps = (max(a, -a) + max(b, -b)) * 0.001;
	if(a - b < eps && b - a < eps)
		return TRUE;
	return FALSE;
}

float almost_in_bounds(float a, float b, float c)
{
	float eps;
	eps = (max(a, -a) + max(c, -c)) * 0.001;
	if(a > c)
		eps = -eps;
	return b == median(a - eps, b, c + eps);
}

float power2of(float e)
{
	return pow(2, e);
}
float log2of(float x)
{
	// NOTE: generated code
	if(x > 2048)
		if(x > 131072)
			if(x > 1048576)
				if(x > 4194304)
					return 23;
				else
					if(x > 2097152)
						return 22;
					else
						return 21;
			else
				if(x > 524288)
					return 20;
				else
					if(x > 262144)
						return 19;
					else
						return 18;
		else
			if(x > 16384)
				if(x > 65536)
					return 17;
				else
					if(x > 32768)
						return 16;
					else
						return 15;
			else
				if(x > 8192)
					return 14;
				else
					if(x > 4096)
						return 13;
					else
						return 12;
	else
		if(x > 32)
			if(x > 256)
				if(x > 1024)
					return 11;
				else
					if(x > 512)
						return 10;
					else
						return 9;
			else
				if(x > 128)
					return 8;
				else
					if(x > 64)
						return 7;
					else
						return 6;
		else
			if(x > 4)
				if(x > 16)
					return 5;
				else
					if(x > 8)
						return 4;
					else
						return 3;
			else
				if(x > 2)
					return 2;
				else
					if(x > 1)
						return 1;
					else
						return 0;
}

float rgb_mi_ma_to_hue(vector rgb, float mi, float ma)
{
	if(mi == ma)
		return 0;
	else if(ma == rgb_x)
	{
		if(rgb_y >= rgb_z)
			return (rgb_y - rgb_z) / (ma - mi);
		else
			return (rgb_y - rgb_z) / (ma - mi) + 6;
	}
	else if(ma == rgb_y)
		return (rgb_z - rgb_x) / (ma - mi) + 2;
	else // if(ma == rgb_z)
		return (rgb_x - rgb_y) / (ma - mi) + 4;
}

vector hue_mi_ma_to_rgb(float hue, float mi, float ma)
{
	vector rgb;

	hue -= 6 * floor(hue / 6);

	//else if(ma == rgb_x)
	//	hue = 60 * (rgb_y - rgb_z) / (ma - mi);
	if(hue <= 1)
	{
		rgb_x = ma;
		rgb_y = hue * (ma - mi) + mi;
		rgb_z = mi;
	}
	//else if(ma == rgb_y)
	//	hue = 60 * (rgb_z - rgb_x) / (ma - mi) + 120;
	else if(hue <= 2)
	{
		rgb_x = (2 - hue) * (ma - mi) + mi;
		rgb_y = ma;
		rgb_z = mi;
	}
	else if(hue <= 3)
	{
		rgb_x = mi;
		rgb_y = ma;
		rgb_z = (hue - 2) * (ma - mi) + mi;
	}
	//else // if(ma == rgb_z)
	//	hue = 60 * (rgb_x - rgb_y) / (ma - mi) + 240;
	else if(hue <= 4)
	{
		rgb_x = mi;
		rgb_y = (4 - hue) * (ma - mi) + mi;
		rgb_z = ma;
	}
	else if(hue <= 5)
	{
		rgb_x = (hue - 4) * (ma - mi) + mi;
		rgb_y = mi;
		rgb_z = ma;
	}
	//else if(ma == rgb_x)
	//	hue = 60 * (rgb_y - rgb_z) / (ma - mi);
	else // if(hue <= 6)
	{
		rgb_x = ma;
		rgb_y = mi;
		rgb_z = (6 - hue) * (ma - mi) + mi;
	}

	return rgb;
}

vector rgb_to_hsv(vector rgb)
{
	float mi, ma;
	vector hsv;

	mi = min(rgb_x, rgb_y, rgb_z);
	ma = max(rgb_x, rgb_y, rgb_z);

	hsv_x = rgb_mi_ma_to_hue(rgb, mi, ma);
	hsv_z = ma;

	if(ma == 0)
		hsv_y = 0;
	else
		hsv_y = 1 - mi/ma;

	return hsv;
}

vector hsv_to_rgb(vector hsv)
{
	return hue_mi_ma_to_rgb(hsv_x, hsv_z * (1 - hsv_y), hsv_z);
}

vector rgb_to_hsl(vector rgb)
{
	float mi, ma;
	vector hsl;

	mi = min(rgb_x, rgb_y, rgb_z);
	ma = max(rgb_x, rgb_y, rgb_z);

	hsl_x = rgb_mi_ma_to_hue(rgb, mi, ma);

	hsl_z = 0.5 * (mi + ma);
	if(mi == ma)
		hsl_y = 0;
	else if(hsl_z <= 0.5)
		hsl_y = (ma - mi) / (2*hsl_z);
	else // if(hsl_z > 0.5)
		hsl_y = (ma - mi) / (2 - 2*hsl_z);

	return hsl;
}

vector hsl_to_rgb(vector hsl)
{
	float mi, ma, maminusmi;

	if(hsl_z <= 0.5)
		maminusmi = hsl_y * 2 * hsl_z;
	else
		maminusmi = hsl_y * (2 - 2 * hsl_z);

	// hsl_z     = 0.5 * mi + 0.5 * ma
	// maminusmi =     - mi +       ma
	mi = hsl_z - 0.5 * maminusmi;
	ma = hsl_z + 0.5 * maminusmi;

	return hue_mi_ma_to_rgb(hsl_x, mi, ma);
}

string rgb_to_hexcolor(vector rgb)
{
	return
		strcat(
			"^x",
			DEC_TO_HEXDIGIT(floor(rgb_x * 15 + 0.5)),
			DEC_TO_HEXDIGIT(floor(rgb_y * 15 + 0.5)),
			DEC_TO_HEXDIGIT(floor(rgb_z * 15 + 0.5))
		);
}

// requires that m2>m1 in all coordinates, and that m4>m3
float boxesoverlap(vector m1, vector m2, vector m3, vector m4) {return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y && m2_z >= m3_z && m1_z <= m4_z;}

// requires the same, but is a stronger condition
float boxinsidebox(vector smins, vector smaxs, vector bmins, vector bmaxs) {return smins_x >= bmins_x && smaxs_x <= bmaxs_x && smins_y >= bmins_y && smaxs_y <= bmaxs_y && smins_z >= bmins_z && smaxs_z <= bmaxs_z;}

#ifndef MENUQC
#endif

float textLengthUpToWidth(string theText, float maxWidth, vector theSize, textLengthUpToWidth_widthFunction_t w)
{
	// STOP.
	// The following function is SLOW.
	// For your safety and for the protection of those around you...
	// DO NOT CALL THIS AT HOME.
	// No really, don't.
	if(w(theText, theSize) <= maxWidth)
		return strlen(theText); // yeah!

	// binary search for right place to cut string
	float ch;
	float left, right, middle; // this always works
	left = 0;
	right = strlen(theText); // this always fails
	do
	{
		middle = floor((left + right) / 2);
		if(w(substring(theText, 0, middle), theSize) <= maxWidth)
			left = middle;
		else
			right = middle;
	}
	while(left < right - 1);

	if(w("^7", theSize) == 0) // detect color codes support in the width function
	{
		// NOTE: when color codes are involved, this binary search is,
		// mathematically, BROKEN. However, it is obviously guaranteed to
		// terminate, as the range still halves each time - but nevertheless, it is
		// guaranteed that it finds ONE valid cutoff place (where "left" is in
		// range, and "right" is outside).

		// terencehill: the following code detects truncated ^xrgb tags (e.g. ^x or ^x4)
		// and decrease left on the basis of the chars detected of the truncated tag
		// Even if the ^xrgb tag is not complete/correct, left is decreased
		// (sometimes too much but with a correct result)
		// it fixes also ^[0-9]
		while(left >= 1 && substring(theText, left-1, 1) == "^")
			left-=1;

		if (left >= 2 && substring(theText, left-2, 2) == "^x") // ^x/
			left-=2;
		else if (left >= 3 && substring(theText, left-3, 2) == "^x")
			{
				ch = str2chr(theText, left-1);
				if( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') ) // ^xr/
					left-=3;
			}
		else if (left >= 4 && substring(theText, left-4, 2) == "^x")
			{
				ch = str2chr(theText, left-2);
				if ( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') )
				{
					ch = str2chr(theText, left-1);
					if ( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') ) // ^xrg/
						left-=4;
				}
			}
	}

	return left;
}

float textLengthUpToLength(string theText, float maxWidth, textLengthUpToLength_lenFunction_t w)
{
	// STOP.
	// The following function is SLOW.
	// For your safety and for the protection of those around you...
	// DO NOT CALL THIS AT HOME.
	// No really, don't.
	if(w(theText) <= maxWidth)
		return strlen(theText); // yeah!

	// binary search for right place to cut string
	float ch;
	float left, right, middle; // this always works
	left = 0;
	right = strlen(theText); // this always fails
	do
	{
		middle = floor((left + right) / 2);
		if(w(substring(theText, 0, middle)) <= maxWidth)
			left = middle;
		else
			right = middle;
	}
	while(left < right - 1);

	if(w("^7") == 0) // detect color codes support in the width function
	{
		// NOTE: when color codes are involved, this binary search is,
		// mathematically, BROKEN. However, it is obviously guaranteed to
		// terminate, as the range still halves each time - but nevertheless, it is
		// guaranteed that it finds ONE valid cutoff place (where "left" is in
		// range, and "right" is outside).

		// terencehill: the following code detects truncated ^xrgb tags (e.g. ^x or ^x4)
		// and decrease left on the basis of the chars detected of the truncated tag
		// Even if the ^xrgb tag is not complete/correct, left is decreased
		// (sometimes too much but with a correct result)
		// it fixes also ^[0-9]
		while(left >= 1 && substring(theText, left-1, 1) == "^")
			left-=1;

		if (left >= 2 && substring(theText, left-2, 2) == "^x") // ^x/
			left-=2;
		else if (left >= 3 && substring(theText, left-3, 2) == "^x")
			{
				ch = str2chr(theText, left-1);
				if( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') ) // ^xr/
					left-=3;
			}
		else if (left >= 4 && substring(theText, left-4, 2) == "^x")
			{
				ch = str2chr(theText, left-2);
				if ( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') )
				{
					ch = str2chr(theText, left-1);
					if ( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') ) // ^xrg/
						left-=4;
				}
			}
	}

	return left;
}

string find_last_color_code(string s)
{
	float start, len, i, carets;
	start = strstrofs(s, "^", 0);
	if (start == -1) // no caret found
		return "";
	len = strlen(s)-1;
	for(i = len; i >= start; --i)
	{
		if(substring(s, i, 1) != "^")
			continue;

		carets = 1;
		while (i-carets >= start && substring(s, i-carets, 1) == "^")
			++carets;

		// check if carets aren't all escaped
		if (carets & 1)
		{
			if(i+1 <= len)
			if(strstrofs("0123456789", substring(s, i+1, 1), 0) >= 0)
				return substring(s, i, 2);

			if(i+4 <= len)
			if(substring(s, i+1, 1) == "x")
			if(strstrofs("0123456789abcdefABCDEF", substring(s, i+2, 1), 0) >= 0)
			if(strstrofs("0123456789abcdefABCDEF", substring(s, i+3, 1), 0) >= 0)
			if(strstrofs("0123456789abcdefABCDEF", substring(s, i+4, 1), 0) >= 0)
				return substring(s, i, 5);
		}
		i -= carets; // this also skips one char before the carets
	}

	return "";
}

string getWrappedLine(float w, vector theFontSize, textLengthUpToWidth_widthFunction_t tw)
{
	float cantake;
	float take;
	string s;

	s = getWrappedLine_remaining;

	if(w <= 0)
	{
		getWrappedLine_remaining = string_null;
		return s; // the line has no size ANYWAY, nothing would be displayed.
	}

	cantake = textLengthUpToWidth(s, w, theFontSize, tw);
	if(cantake > 0 && cantake < strlen(s))
	{
		take = cantake - 1;
		while(take > 0 && substring(s, take, 1) != " ")
			--take;
		if(take == 0)
		{
			getWrappedLine_remaining = substring(s, cantake, strlen(s) - cantake);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7", theFontSize) == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, cantake)), getWrappedLine_remaining);
			return substring(s, 0, cantake);
		}
		else
		{
			getWrappedLine_remaining = substring(s, take + 1, strlen(s) - take);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7", theFontSize) == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, take)), getWrappedLine_remaining);
			return substring(s, 0, take);
		}
	}
	else
	{
		getWrappedLine_remaining = string_null;
		return s;
	}
}

string getWrappedLineLen(float w, textLengthUpToLength_lenFunction_t tw)
{
	float cantake;
	float take;
	string s;

	s = getWrappedLine_remaining;

	if(w <= 0)
	{
		getWrappedLine_remaining = string_null;
		return s; // the line has no size ANYWAY, nothing would be displayed.
	}

	cantake = textLengthUpToLength(s, w, tw);
	if(cantake > 0 && cantake < strlen(s))
	{
		take = cantake - 1;
		while(take > 0 && substring(s, take, 1) != " ")
			--take;
		if(take == 0)
		{
			getWrappedLine_remaining = substring(s, cantake, strlen(s) - cantake);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7") == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, cantake)), getWrappedLine_remaining);
			return substring(s, 0, cantake);
		}
		else
		{
			getWrappedLine_remaining = substring(s, take + 1, strlen(s) - take);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7") == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, take)), getWrappedLine_remaining);
			return substring(s, 0, take);
		}
	}
	else
	{
		getWrappedLine_remaining = string_null;
		return s;
	}
}

string textShortenToWidth(string theText, float maxWidth, vector theFontSize, textLengthUpToWidth_widthFunction_t tw)
{
	if(tw(theText, theFontSize) <= maxWidth)
		return theText;
	else
		return strcat(substring(theText, 0, textLengthUpToWidth(theText, maxWidth - tw("...", theFontSize), theFontSize, tw)), "...");
}

string textShortenToLength(string theText, float maxWidth, textLengthUpToLength_lenFunction_t tw)
{
	if(tw(theText) <= maxWidth)
		return theText;
	else
		return strcat(substring(theText, 0, textLengthUpToLength(theText, maxWidth - tw("..."), tw)), "...");
}

float isGametypeInFilter(float gt, float tp, float ts, string pattern)
{
	string subpattern, subpattern2, subpattern3, subpattern4;
	subpattern = strcat(",", MapInfo_Type_ToString(gt), ",");
	if(tp)
		subpattern2 = ",teams,";
	else
		subpattern2 = ",noteams,";
	if(ts)
		subpattern3 = ",teamspawns,";
	else
		subpattern3 = ",noteamspawns,";
	if(gt == MAPINFO_TYPE_RACE || gt == MAPINFO_TYPE_CTS)
		subpattern4 = ",race,";
	else
		subpattern4 = string_null;

	if(substring(pattern, 0, 1) == "-")
	{
		pattern = substring(pattern, 1, strlen(pattern) - 1);
		if(strstrofs(strcat(",", pattern, ","), subpattern, 0) >= 0)
			return 0;
		if(strstrofs(strcat(",", pattern, ","), subpattern2, 0) >= 0)
			return 0;
		if(strstrofs(strcat(",", pattern, ","), subpattern3, 0) >= 0)
			return 0;
		if(subpattern4 && strstrofs(strcat(",", pattern, ","), subpattern4, 0) >= 0)
			return 0;
	}
	else
	{
		if(substring(pattern, 0, 1) == "+")
			pattern = substring(pattern, 1, strlen(pattern) - 1);
		if(strstrofs(strcat(",", pattern, ","), subpattern, 0) < 0)
		if(strstrofs(strcat(",", pattern, ","), subpattern2, 0) < 0)
		if(strstrofs(strcat(",", pattern, ","), subpattern3, 0) < 0)
		{
			if (!subpattern4)
				return 0;
			if(strstrofs(strcat(",", pattern, ","), subpattern4, 0) < 0)
				return 0;
		}
	}
	return 1;
}

void shuffle(float n, swapfunc_t swap, entity pass)
{
	float i, j;
	for(i = 1; i < n; ++i)
	{
		// swap i-th item at a random position from 0 to i
		// proof for even distribution:
		//   n = 1: obvious
		//   n -> n+1:
		//     item n+1 gets at any position with chance 1/(n+1)
		//     all others will get their 1/n chance reduced by factor n/(n+1)
		//     to be on place n+1, their chance will be 1/(n+1)
		//     1/n * n/(n+1) = 1/(n+1)
		//     q.e.d.
		j = floor(random() * (i + 1));
		if(j != i)
			swap(j, i, pass);
	}
}

string substring_range(string s, float b, float e)
{
	return substring(s, b, e - b);
}

string swapwords(string str, float i, float j)
{
	float n;
	string s1, s2, s3, s4, s5;
	float si, ei, sj, ej, s0, en;
	n = tokenizebyseparator(str, " "); // must match g_maplist processing in ShuffleMaplist and "shuffle"
	si = argv_start_index(i);
	sj = argv_start_index(j);
	ei = argv_end_index(i);
	ej = argv_end_index(j);
	s0 = argv_start_index(0);
	en = argv_end_index(n-1);
	s1 = substring_range(str, s0, si);
	s2 = substring_range(str, si, ei);
	s3 = substring_range(str, ei, sj);
	s4 = substring_range(str, sj, ej);
	s5 = substring_range(str, ej, en);
	return strcat(s1, s4, s3, s2, s5);
}

string _shufflewords_str;
void _shufflewords_swapfunc(float i, float j, entity pass)
{
	_shufflewords_str = swapwords(_shufflewords_str, i, j);
}
string shufflewords(string str)
{
	float n;
	_shufflewords_str = str;
	n = tokenizebyseparator(str, " ");
	shuffle(n, _shufflewords_swapfunc, world);
	str = _shufflewords_str;
	_shufflewords_str = string_null;
	return str;
}

vector solve_quadratic(float a, float b, float c) // ax^2 + bx + c = 0
{
	vector v;
	float D;
	v = '0 0 0';
	if(a == 0)
	{
		if(b != 0)
		{
			v_x = v_y = -c / b;
			v_z = 1;
		}
		else
		{
			if(c == 0)
			{
				// actually, every number solves the equation!
				v_z = 1;
			}
		}
	}
	else
	{
		D = b*b - 4*a*c;
		if(D >= 0)
		{
			D = sqrt(D);
			if(a > 0) // put the smaller solution first
			{
				v_x = ((-b)-D) / (2*a);
				v_y = ((-b)+D) / (2*a);
			}
			else
			{
				v_x = (-b+D) / (2*a);
				v_y = (-b-D) / (2*a);
			}
			v_z = 1;
		}
		else
		{
			// complex solutions!
			D = sqrt(-D);
			v_x = -b / (2*a);
			if(a > 0)
				v_y =  D / (2*a);
			else
				v_y = -D / (2*a);
			v_z = 0;
		}
	}
	return v;
}

vector solve_shotdirection(vector myorg, vector myvel, vector eorg, vector evel, float spd, float newton_style)
{
	vector ret;

	// make origin and speed relative
	eorg -= myorg;
	if(newton_style)
		evel -= myvel;

	// now solve for ret, ret normalized:
	//   eorg + t * evel == t * ret * spd
	// or, rather, solve for t:
	//   |eorg + t * evel| == t * spd
	//   eorg^2 + t^2 * evel^2 + 2 * t * (eorg * evel) == t^2 * spd^2
	//   t^2 * (evel^2 - spd^2) + t * (2 * (eorg * evel)) + eorg^2 == 0
	vector solution = solve_quadratic(evel * evel - spd * spd, 2 * (eorg * evel), eorg * eorg);
	// p = 2 * (eorg * evel) / (evel * evel - spd * spd)
	// q = (eorg * eorg) / (evel * evel - spd * spd)
	if(!solution_z) // no real solution
	{
		// happens if D < 0
		// (eorg * evel)^2 < (evel^2 - spd^2) * eorg^2
		// (eorg * evel)^2 / eorg^2 < evel^2 - spd^2
		// spd^2 < ((evel^2 * eorg^2) - (eorg * evel)^2) / eorg^2
		// spd^2 < evel^2 * (1 - cos^2 angle(evel, eorg))
		// spd^2 < evel^2 * sin^2 angle(evel, eorg)
		// spd < |evel| * sin angle(evel, eorg)
		return '0 0 0';
	}
	else if(solution_x > 0)
	{
		// both solutions > 0: take the smaller one
		// happens if p < 0 and q > 0
		ret = normalize(eorg + solution_x * evel);
	}
	else if(solution_y > 0)
	{
		// one solution > 0: take the larger one
		// happens if q < 0 or q == 0 and p < 0
		ret = normalize(eorg + solution_y * evel);
	}
	else
	{
		// no solution > 0: reject
		// happens if p > 0 and q >= 0
		// 2 * (eorg * evel) / (evel * evel - spd * spd) > 0
		// (eorg * eorg) / (evel * evel - spd * spd) >= 0
		//
		// |evel| >= spd
		// eorg * evel > 0
		//
		// "Enemy is moving away from me at more than spd"
		return '0 0 0';
	}

	// NOTE: we always got a solution if spd > |evel|

	if(newton_style == 2)
		ret = normalize(ret * spd + myvel);

	return ret;
}

vector get_shotvelocity(vector myvel, vector mydir, float spd, float newton_style, float mi, float ma)
{
	if(!newton_style)
		return spd * mydir;

	if(newton_style == 2)
	{
		// true Newtonian projectiles with automatic aim adjustment
		//
		// solve: |outspeed * mydir - myvel| = spd
		// outspeed^2 - 2 * outspeed * (mydir * myvel) + myvel^2 - spd^2 = 0
		// outspeed = (mydir * myvel) +- sqrt((mydir * myvel)^2 - myvel^2 + spd^2)
		// PLUS SIGN!
		// not defined?
		// then...
		// myvel^2 - (mydir * myvel)^2 > spd^2
		// velocity without mydir component > spd
		// fire at smallest possible spd that works?
		// |(mydir * myvel) * myvel - myvel| = spd

		vector solution = solve_quadratic(1, -2 * (mydir * myvel), myvel * myvel - spd * spd);

		float outspeed;
		if(solution_z)
			outspeed = solution_y; // the larger one
		else
		{
			//outspeed = 0; // slowest possible shot
			outspeed = solution_x; // the real part (that is, the average!)
			//dprint("impossible shot, adjusting\n");
		}

		outspeed = bound(spd * mi, outspeed, spd * ma);
		return mydir * outspeed;
	}

	// real Newtonian
	return myvel + spd * mydir;
}

void check_unacceptable_compiler_bugs()
{
	if(cvar("_allow_unacceptable_compiler_bugs"))
		return;
	tokenize_console("foo bar");
	if(strcat(argv(0), substring("foo bar", 4, 7 - argv_start_index(1))) == "barbar")
		error("fteqcc bug introduced with revision 3178 detected. Please upgrade fteqcc to a later revision, downgrade fteqcc to revision 3177, or pester Spike until he fixes it. You can set _allow_unacceptable_compiler_bugs 1 to skip this check, but expect stuff to be horribly broken then.");

	string s = "";
	if (!s)
		error("The empty string counts as false. We do not want that!");
}

float compressShotOrigin(vector v)
{
	float x, y, z;
	x = rint(v_x * 2);
	y = rint(v_y * 4) + 128;
	z = rint(v_z * 4) + 128;
	if(x > 255 || x < 0)
	{
		print("shot origin ", vtos(v), " x out of bounds\n");
		x = bound(0, x, 255);
	}
	if(y > 255 || y < 0)
	{
		print("shot origin ", vtos(v), " y out of bounds\n");
		y = bound(0, y, 255);
	}
	if(z > 255 || z < 0)
	{
		print("shot origin ", vtos(v), " z out of bounds\n");
		z = bound(0, z, 255);
	}
	return x * 0x10000 + y * 0x100 + z;
}
vector decompressShotOrigin(float f)
{
	vector v;
	v_x = ((f & 0xFF0000) / 0x10000) / 2;
	v_y = ((f & 0xFF00) / 0x100 - 128) / 4;
	v_z = ((f & 0xFF) - 128) / 4;
	return v;
}

void heapsort(float n, swapfunc_t swap, comparefunc_t cmp, entity pass)
{
	float start, end, root, child;

	// heapify
	start = floor((n - 2) / 2);
	while(start >= 0)
	{
		// siftdown(start, count-1);
		root = start;
		while(root * 2 + 1 <= n-1)
		{
			child = root * 2 + 1;
			if(child < n-1)
				if(cmp(child, child+1, pass) < 0)
					++child;
			if(cmp(root, child, pass) < 0)
			{
				swap(root, child, pass);
				root = child;
			}
			else
				break;
		}
		// end of siftdown
		--start;
	}

	// extract
	end = n - 1;
	while(end > 0)
	{
		swap(0, end, pass);
		--end;
		// siftdown(0, end);
		root = 0;
		while(root * 2 + 1 <= end)
		{
			child = root * 2 + 1;
			if(child < end && cmp(child, child+1, pass) < 0)
				++child;
			if(cmp(root, child, pass) < 0)
			{
				swap(root, child, pass);
				root = child;
			}
			else
				break;
		}
		// end of siftdown
	}
}

void RandomSelection_Init()
{
	RandomSelection_totalweight = 0;
	RandomSelection_chosen_ent = world;
	RandomSelection_chosen_float = 0;
	RandomSelection_chosen_string = string_null;
	RandomSelection_best_priority = -1;
}
void RandomSelection_Add(entity e, float f, string s, float weight, float priority)
{
	if(priority > RandomSelection_best_priority)
	{
		RandomSelection_best_priority = priority;
		RandomSelection_chosen_ent = e;
		RandomSelection_chosen_float = f;
		RandomSelection_chosen_string = s;
		RandomSelection_totalweight = weight;
	}
	else if(priority == RandomSelection_best_priority)
	{
		RandomSelection_totalweight += weight;
		if(random() * RandomSelection_totalweight <= weight)
		{
			RandomSelection_chosen_ent = e;
			RandomSelection_chosen_float = f;
			RandomSelection_chosen_string = s;
		}
	}
}

#ifndef MENUQC
vector healtharmor_maxdamage(float h, float a, float armorblock, float deathtype)
{
	// NOTE: we'll always choose the SMALLER value...
	float healthdamage, armordamage, armorideal;
	if (deathtype == DEATH_DROWN || DEATH_ISSTATUSEFFECT(deathtype))  // Why should armor help here...
		armorblock = 0;
	vector v;
	healthdamage = (h - 1) / (1 - armorblock); // damage we can take if we could use more health
	armordamage = a + (h - 1); // damage we can take if we could use more armor
	armorideal = healthdamage * armorblock;
	v_y = armorideal;
	if(armordamage < healthdamage)
	{
		v_x = armordamage;
		v_z = 1;
	}
	else
	{
		v_x = healthdamage;
		v_z = 0;
	}
	return v;
}

vector healtharmor_applydamage(float a, float armorblock, float deathtype, float damage)
{
	vector v;
	if (deathtype == DEATH_DROWN || DEATH_ISSTATUSEFFECT(deathtype))  // Why should armor help here...
		armorblock = 0;
	v_y = bound(0, damage * armorblock, a); // save
	v_x = bound(0, damage - v_y, damage); // take
	v_z = 0;
	return v;
}
#endif

string getcurrentmod()
{
	float n;
	string m;
	m = cvar_string("fs_gamedir");
	n = tokenize_console(m);
	if(n == 0)
		return "data";
	else
		return argv(n - 1);
}

#ifndef MENUQC
#ifdef CSQC
float ReadInt24_t()
{
	float v;
	v = ReadShort() * 256; // note: this is signed
	v += ReadByte(); // note: this is unsigned
	return v;
}
vector ReadInt48_t()
{
	vector v;
	v_x = ReadInt24_t();
	v_y = ReadInt24_t();
	v_z = 0;
	return v;
}
vector ReadInt72_t()
{
	vector v;
	v_x = ReadInt24_t();
	v_y = ReadInt24_t();
	v_z = ReadInt24_t();
	return v;
}
#else
void WriteInt24_t(float dst, float val)
{
	float v;
	WriteShort(dst, (v = floor(val / 256)));
	WriteByte(dst, val - v * 256); // 0..255
}
void WriteInt48_t(float dst, vector val)
{
	WriteInt24_t(dst, val_x);
	WriteInt24_t(dst, val_y);
}
void WriteInt72_t(float dst, vector val)
{
	WriteInt24_t(dst, val_x);
	WriteInt24_t(dst, val_y);
	WriteInt24_t(dst, val_z);
}
#endif
#endif

float float2range11(float f)
{
	// continuous function mapping all reals into -1..1
	return f / (fabs(f) + 1);
}

float float2range01(float f)
{
	// continuous function mapping all reals into 0..1
	return 0.5 + 0.5 * float2range11(f);
}

// from the GNU Scientific Library
float gsl_ran_gaussian_lastvalue;
float gsl_ran_gaussian_lastvalue_set;
float gsl_ran_gaussian(float sigma)
{
	float a, b;
	if(gsl_ran_gaussian_lastvalue_set)
	{
		gsl_ran_gaussian_lastvalue_set = 0;
		return sigma * gsl_ran_gaussian_lastvalue;
	}
	else
	{
		a = random() * 2 * M_PI;
		b = sqrt(-2 * log(random()));
		gsl_ran_gaussian_lastvalue = cos(a) * b;
		gsl_ran_gaussian_lastvalue_set = 1;
		return sigma * sin(a) * b;
	}
}

string car(string s)
{
	float o;
	o = strstrofs(s, " ", 0);
	if(o < 0)
		return s;
	return substring(s, 0, o);
}
string cdr(string s)
{
	float o;
	o = strstrofs(s, " ", 0);
	if(o < 0)
		return string_null;
	return substring(s, o + 1, strlen(s) - (o + 1));
}
float matchacl(string acl, string str)
{
	string t, s;
	float r, d;
	r = 0;
	while(acl)
	{
		t = car(acl); acl = cdr(acl);

		d = 1;
		if(substring(t, 0, 1) == "-")
		{
			d = -1;
			t = substring(t, 1, strlen(t) - 1);
		}
		else if(substring(t, 0, 1) == "+")
			t = substring(t, 1, strlen(t) - 1);

		if(substring(t, -1, 1) == "*")
		{
			t = substring(t, 0, strlen(t) - 1);
			s = substring(str, 0, strlen(t));
		}
		else
			s = str;

		if(s == t)
		{
			r = d;
		}
	}
	return r;
}
float startsWith(string haystack, string needle)
{
	return substring(haystack, 0, strlen(needle)) == needle;
}
float startsWithNocase(string haystack, string needle)
{
	return strcasecmp(substring(haystack, 0, strlen(needle)), needle) == 0;
}

string get_model_datafilename(string m, float sk, string fil)
{
	if(m)
		m = strcat(m, "_");
	else
		m = "models/player/*_";
	if(sk >= 0)
		m = strcat(m, ftos(sk));
	else
		m = strcat(m, "*");
	return strcat(m, ".", fil);
}

float get_model_parameters(string m, float sk)
{
	string fn, s, c;
	float fh, i;

	get_model_parameters_modelname = string_null;
	get_model_parameters_modelskin = -1;
	get_model_parameters_name = string_null;
	get_model_parameters_species = -1;
	get_model_parameters_sex = string_null;
	get_model_parameters_weight = -1;
	get_model_parameters_age = -1;
	get_model_parameters_desc = string_null;
	get_model_parameters_bone_upperbody = string_null;
	get_model_parameters_bone_weapon = string_null;
	for(i = 0; i < MAX_AIM_BONES; ++i)
	{
		get_model_parameters_bone_aim[i] = string_null;
		get_model_parameters_bone_aimweight[i] = 0;
	}
	get_model_parameters_fixbone = 0;
	get_model_parameters_bone_head = string_null;
	get_model_parameters_hat_height = '0 0 0';
	get_model_parameters_hat_scale = 0;

	if (!m)
		return 1;

	if(substring(m, -9, 5) == "_lod1" || substring(m, -9, 5) == "_lod2")
		m = strcat(substring(m, 0, -10), substring(m, -4, -1));

	if(sk < 0)
	{
		if(substring(m, -4, -1) != ".txt")
			return 0;
		if(substring(m, -6, 1) != "_")
			return 0;
		sk = stof(substring(m, -5, 1));
		m = substring(m, 0, -7);
	}

	fn = get_model_datafilename(m, sk, "txt");
	fh = fopen(fn, FILE_READ);
	if(fh < 0)
	{
		sk = 0;
		fn = get_model_datafilename(m, sk, "txt");
		fh = fopen(fn, FILE_READ);
		if(fh < 0)
			return 0;
	}

	get_model_parameters_modelname = m;
	get_model_parameters_modelskin = sk;
	while((s = fgets(fh)))
	{
		if(s == "")
			break; // next lines will be description
		c = car(s);
		s = cdr(s);
		if(c == "name")
			get_model_parameters_name = s;
		if(c == "species")
			switch(s)
			{
				case "human":       get_model_parameters_species = SPECIES_HUMAN;       break;
				case "alien":       get_model_parameters_species = SPECIES_ALIEN;       break;
				case "robot_shiny": get_model_parameters_species = SPECIES_ROBOT_SHINY; break;
				case "robot_rusty": get_model_parameters_species = SPECIES_ROBOT_RUSTY; break;
				case "robot_solid": get_model_parameters_species = SPECIES_ROBOT_SOLID; break;
				case "animal":      get_model_parameters_species = SPECIES_ANIMAL;      break;
				case "reserved":    get_model_parameters_species = SPECIES_RESERVED;    break;
			}
		if(c == "sex")
			get_model_parameters_sex = s;
		if(c == "weight")
			get_model_parameters_weight = stof(s);
		if(c == "age")
			get_model_parameters_age = stof(s);
		if(c == "bone_upperbody")
			get_model_parameters_bone_upperbody = s;
		if(c == "bone_weapon")
			get_model_parameters_bone_weapon = s;
		for(i = 0; i < MAX_AIM_BONES; ++i)
			if(c == strcat("bone_aim", ftos(i)))
			{
				get_model_parameters_bone_aimweight[i] = stof(car(s));
				get_model_parameters_bone_aim[i] = cdr(s);
			}
		if(c == "fixbone")
			get_model_parameters_fixbone = stof(s);
		if(c == "bone_head")
			get_model_parameters_bone_head = s;
		if(c == "hat_height")
			get_model_parameters_hat_height = stov(s);
		if(c == "hat_scale")
			get_model_parameters_hat_scale = stof(s);
	}

	while((s = fgets(fh)))
	{
		if(get_model_parameters_desc)
			get_model_parameters_desc = strcat(get_model_parameters_desc, "\n");
		if(s != "")
			get_model_parameters_desc = strcat(get_model_parameters_desc, s);
	}

	fclose(fh);

	return 1;
}

vector vec2(vector v)
{
	v_z = 0;
	return v;
}

#ifndef MENUQC
vector NearestPointOnBox(entity box, vector org)
{
	vector m1, m2, nearest;

	m1 = box.mins + box.origin;
	m2 = box.maxs + box.origin;

	nearest_x = bound(m1_x, org_x, m2_x);
	nearest_y = bound(m1_y, org_y, m2_y);
	nearest_z = bound(m1_z, org_z, m2_z);

	return nearest;
}
#endif

float vercmp_recursive(string v1, string v2)
{
	float dot1, dot2;
	string s1, s2;
	float r;

	dot1 = strstrofs(v1, ".", 0);
	dot2 = strstrofs(v2, ".", 0);
	if(dot1 == -1)
		s1 = v1;
	else
		s1 = substring(v1, 0, dot1);
	if(dot2 == -1)
		s2 = v2;
	else
		s2 = substring(v2, 0, dot2);

	r = stof(s1) - stof(s2);
	if(r != 0)
		return r;

	r = strcasecmp(s1, s2);
	if(r != 0)
		return r;

	if(dot1 == -1)
		if(dot2 == -1)
			return 0;
		else
			return -1;
	else
		if(dot2 == -1)
			return 1;
		else
			return vercmp_recursive(substring(v1, dot1 + 1, 999), substring(v2, dot2 + 1, 999));
}

float vercmp(string v1, string v2)
{
	if(strcasecmp(v1, v2) == 0) // early out check
		return 0;

	// "git" beats all
	if(v1 == "git")
		return 1;
	if(v2 == "git")
		return -1;

	return vercmp_recursive(v1, v2);
}

float u8_strsize(string s)
{
	float l, i, c;
	l = 0;
	for(i = 0; ; ++i)
	{
		c = str2chr(s, i);
		if(c <= 0)
			break;
		++l;
		if(c >= 0x80)
			++l;
		if(c >= 0x800)
			++l;
		if(c >= 0x10000)
			++l;
	}
	return l;
}

// translation helpers
string language_filename(string s)
{
	string fn;
	float fh;
	fn = prvm_language;
	if(fn == "" || fn == "dump")
		return s;
	fn = strcat(s, ".", fn);
	if((fh = fopen(fn, FILE_READ)) >= 0)
	{
		fclose(fh);
		return fn;
	}
	return s;
}
string CTX(string s)
{
	float p = strstrofs(s, "^", 0);
	if(p < 0)
		return s;
	return substring(s, p+1, -1);
}

// x-encoding (encoding as zero length invisible string)
const string XENCODE_2  = "xX";
const string XENCODE_22 = "0123456789abcdefABCDEF";
string xencode(float f)
{
	float a, b, c, d;
	d = mod(f, 22); f = floor(f / 22);
	c = mod(f, 22); f = floor(f / 22);
	b = mod(f, 22); f = floor(f / 22);
	a = mod(f,  2); // f = floor(f /  2);
	return strcat(
		"^",
		substring(XENCODE_2,  a, 1),
		substring(XENCODE_22, b, 1),
		substring(XENCODE_22, c, 1),
		substring(XENCODE_22, d, 1)
	);
}
float xdecode(string s)
{
	float a, b, c, d;
	if(substring(s, 0, 1) != "^")
		return -1;
	if(strlen(s) < 5)
		return -1;
	a = strstrofs(XENCODE_2,  substring(s, 1, 1), 0);
	b = strstrofs(XENCODE_22, substring(s, 2, 1), 0);
	c = strstrofs(XENCODE_22, substring(s, 3, 1), 0);
	d = strstrofs(XENCODE_22, substring(s, 4, 1), 0);
	if(a < 0 || b < 0 || c < 0 || d < 0)
		return -1;
	return ((a * 22 + b) * 22 + c) * 22 + d;
}

float lowestbit(float f)
{
	f &= ~(f * 2);
	f &= ~(f * 4);
	f &= ~(f * 16);
	f &= ~(f * 256);
	f &= ~(f * 65536);
	return f;
}

/*
string strlimitedlen(string input, string truncation, float strip_colors, float limit)
{
	if(strlen((strip_colors ? strdecolorize(input) : input)) <= limit)
		return input;
	else
		return strcat(substring(input, 0, (strlen(input) - strlen(truncation))), truncation);
}*/

// escape the string to make it safe for consoles
string MakeConsoleSafe(string input)
{
	input = strreplace("\n", "", input);
	input = strreplace("\\", "\\\\", input);
	input = strreplace("$", "$$", input);
	input = strreplace("\"", "\\\"", input);
	return input;
}

#ifndef MENUQC
// get true/false value of a string with multiple different inputs
float InterpretBoolean(string input)
{
	switch(strtolower(input))
	{
		case "yes":
		case "true":
		case "on":
			return TRUE;

		case "no":
		case "false":
		case "off":
			return FALSE;

		default: return stof(input);
	}
}
#endif

#ifdef CSQC
entity ReadCSQCEntity()
{
	float f;
	f = ReadShort();
	if(f == 0)
		return world;
	return findfloat(world, entnum, f);
}
#endif

float shutdown_running;
#ifdef SVQC
void SV_Shutdown()
#endif
#ifdef CSQC
void CSQC_Shutdown()
#endif
#ifdef MENUQC
void m_shutdown()
#endif
{
	if(shutdown_running)
	{
		print("Recursive shutdown detected! Only restoring cvars...\n");
	}
	else
	{
		shutdown_running = 1;
		Shutdown();
	}
	cvar_settemp_restore(); // this must be done LAST, but in any case
}

#define APPROXPASTTIME_ACCURACY_REQUIREMENT 0.05
#define APPROXPASTTIME_MAX (16384 * APPROXPASTTIME_ACCURACY_REQUIREMENT)
#define APPROXPASTTIME_RANGE (64 * APPROXPASTTIME_ACCURACY_REQUIREMENT)
// this will use the value:
//   128
// accuracy near zero is APPROXPASTTIME_MAX/(256*255)
// accuracy at x is 1/derivative, i.e.
//   APPROXPASTTIME_MAX * (1 + 256 * (dt / APPROXPASTTIME_MAX))^2 / 65536
#ifdef SVQC
void WriteApproxPastTime(float dst, float t)
{
	float dt = time - t;

	// warning: this is approximate; do not resend when you don't have to!
	// be careful with sendflags here!
	// we want: 0 -> 0.05, 1 -> 0.1, ..., 255 -> 12.75

	// map to range...
	dt = 256 * (dt / ((APPROXPASTTIME_MAX / 256) + dt));

	// round...
	dt = rint(bound(0, dt, 255));

	WriteByte(dst, dt);
}
#endif
#ifdef CSQC
float ReadApproxPastTime()
{
	float dt = ReadByte();

	// map from range...PPROXPASTTIME_MAX / 256
	dt = (APPROXPASTTIME_MAX / 256) * (dt / (256 - dt));

	return servertime - dt;
}
#endif

#ifndef MENUQC
.float skeleton_bones_index;
void Skeleton_SetBones(entity e)
{
	// set skeleton_bones to the total number of bones on the model
	if(e.skeleton_bones_index == e.modelindex)
		return; // same model, nothing to update

	float skelindex;
	skelindex = skel_create(e.modelindex);
	e.skeleton_bones = skel_get_numbones(skelindex);
	skel_delete(skelindex);
	e.skeleton_bones_index = e.modelindex;
}
#endif

string to_execute_next_frame;
void execute_next_frame()
{
	if(to_execute_next_frame)
	{
		localcmd("\n", to_execute_next_frame, "\n");
		strunzone(to_execute_next_frame);
		to_execute_next_frame = string_null;
	}
}
void queue_to_execute_next_frame(string s)
{
	if(to_execute_next_frame)
	{
		s = strcat(s, "\n", to_execute_next_frame);
		strunzone(to_execute_next_frame);
	}
	to_execute_next_frame = strzone(s);
}

float cubic_speedfunc(float startspeedfactor, float endspeedfactor, float x)
{
	return
		(((     startspeedfactor + endspeedfactor - 2
		) * x - 2 * startspeedfactor - endspeedfactor + 3
		) * x + startspeedfactor
		) * x;
}

float cubic_speedfunc_is_sane(float startspeedfactor, float endspeedfactor)
{
	if(startspeedfactor < 0 || endspeedfactor < 0)
		return FALSE;

	/*
	// if this is the case, the possible zeros of the first derivative are outside
	// 0..1
	We can calculate this condition as condition
	if(se <= 3)
		return TRUE;
	*/

	// better, see below:
	if(startspeedfactor <= 3 && endspeedfactor <= 3)
		return TRUE;

	// if this is the case, the first derivative has no zeros at all
	float se = startspeedfactor + endspeedfactor;
	float s_e = startspeedfactor - endspeedfactor;
	if(3 * (se - 4) * (se - 4) + s_e * s_e <= 12) // an ellipse
		return TRUE;

	// Now let s <= 3, s <= 3, s+e >= 3 (triangle) then we get se <= 6 (top right corner).
	// we also get s_e <= 6 - se
	// 3 * (se - 4)^2 + (6 - se)^2
	// is quadratic, has value 12 at 3 and 6, and value < 12 in between.
	// Therefore, above "better" check works!

	return FALSE;

	// known good cases:
	// (0, [0..3])
	// (0.5, [0..3.8])
	// (1, [0..4])
	// (1.5, [0..3.9])
	// (2, [0..3.7])
	// (2.5, [0..3.4])
	// (3, [0..3])
	// (3.5, [0.2..2.3])
	// (4, 1)

	/*
	   On another note:
	   inflection point is always at (2s + e - 3) / (3s + 3e - 6).

	   s + e - 2 == 0: no inflection

	   s + e > 2:
	   0 < inflection < 1 if:
	   0 < 2s + e - 3 < 3s + 3e - 6
	   2s + e > 3 and 2e + s > 3

	   s + e < 2:
	   0 < inflection < 1 if:
	   0 > 2s + e - 3 > 3s + 3e - 6
	   2s + e < 3 and 2e + s < 3

	   Therefore: there is an inflection point iff:
	   e outside (3 - s)/2 .. 3 - s*2

	   in other words, if (s,e) in triangle (1,1)(0,3)(0,1.5) or in triangle (1,1)(3,0)(1.5,0)
	*/
}

.float FindConnectedComponent_processing;
void FindConnectedComponent(entity e, .entity fld, findNextEntityNearFunction_t nxt, isConnectedFunction_t iscon, entity pass)
{
	entity queue_start, queue_end;

	// we build a queue of to-be-processed entities.
	// queue_start is the next entity to be checked for neighbors
	// queue_end is the last entity added

	if(e.FindConnectedComponent_processing)
		error("recursion or broken cleanup");

	// start with a 1-element queue
	queue_start = queue_end = e;
	queue_end.fld = world;
	queue_end.FindConnectedComponent_processing = 1;

	// for each queued item:
	for(; queue_start; queue_start = queue_start.fld)
	{
		// find all neighbors of queue_start
		entity t;
		for(t = world; (t = nxt(t, queue_start, pass)); )
		{
			if(t.FindConnectedComponent_processing)
				continue;
			if(iscon(t, queue_start, pass))
			{
				// it is connected? ADD IT. It will look for neighbors soon too.
				queue_end.fld = t;
				queue_end = t;
				queue_end.fld = world;
				queue_end.FindConnectedComponent_processing = 1;
			}
		}
	}

	// unmark
	for(queue_start = e; queue_start; queue_start = queue_start.fld)
		queue_start.FindConnectedComponent_processing = 0;
}

#ifdef SVQC
vector combine_to_vector(float x, float y, float z)
{
	vector result; result_x = x; result_y = y; result_z = z;
	return result;
}

vector get_corner_position(entity box, float corner)
{
	switch(corner)
	{
		case 1: return combine_to_vector(box.absmin_x, box.absmin_y, box.absmin_z);
		case 2: return combine_to_vector(box.absmax_x, box.absmin_y, box.absmin_z);
		case 3: return combine_to_vector(box.absmin_x, box.absmax_y, box.absmin_z);
		case 4: return combine_to_vector(box.absmin_x, box.absmin_y, box.absmax_z);
		case 5: return combine_to_vector(box.absmax_x, box.absmax_y, box.absmin_z);
		case 6: return combine_to_vector(box.absmin_x, box.absmax_y, box.absmax_z);
		case 7: return combine_to_vector(box.absmax_x, box.absmin_y, box.absmax_z);
		case 8: return combine_to_vector(box.absmax_x, box.absmax_y, box.absmax_z);
		default: return '0 0 0';
	}
}
#endif

// todo: this sucks, lets find a better way to do backtraces?
#ifndef MENUQC
void backtrace(string msg)
{
	float dev, war;
	#ifdef SVQC
	dev = autocvar_developer;
	war = autocvar_prvm_backtraceforwarnings;
	#else
	dev = cvar("developer");
	war = cvar("prvm_backtraceforwarnings");
	#endif
	cvar_set("developer", "1");
	cvar_set("prvm_backtraceforwarnings", "1");
	print("\n");
	print("--- CUT HERE ---\nWARNING: ");
	print(msg);
	print("\n");
	remove(world); // isn't there any better way to cause a backtrace?
	print("\n--- CUT UNTIL HERE ---\n");
	cvar_set("developer", ftos(dev));
	cvar_set("prvm_backtraceforwarnings", ftos(war));
}
#endif

// color code replace, place inside of sprintf and parse the string
string CCR(string input)
{
	// See the autocvar declarations in util.qh for default values

	// foreground/normal colors
	input = strreplace("^F1", strcat("^", autocvar_hud_colorset_foreground_1), input);
	input = strreplace("^F2", strcat("^", autocvar_hud_colorset_foreground_2), input);
	input = strreplace("^F3", strcat("^", autocvar_hud_colorset_foreground_3), input);
	input = strreplace("^F4", strcat("^", autocvar_hud_colorset_foreground_4), input);

	// "kill" colors
	input = strreplace("^K1", strcat("^", autocvar_hud_colorset_kill_1), input);
	input = strreplace("^K2", strcat("^", autocvar_hud_colorset_kill_2), input);
	input = strreplace("^K3", strcat("^", autocvar_hud_colorset_kill_3), input);

	// background colors
	input = strreplace("^BG", strcat("^", autocvar_hud_colorset_background), input);
	input = strreplace("^N", "^7", input); // "none"-- reset to white...
	return input;
}

vector vec3(float x, float y, float z)
{
	vector v;
	v_x = x;
	v_y = y;
	v_z = z;
	return v;
}

#ifndef MENUQC
vector animfixfps(entity e, vector a, vector b)
{
	// multi-frame anim: keep as-is
	if(a_y == 1)
	{
		float dur;
		dur = frameduration(e.modelindex, a_x);
		if(dur <= 0 && b_y)
		{
			a = b;
			dur = frameduration(e.modelindex, a_x);
		}
		if(dur > 0)
			a_z = 1.0 / dur;
	}
	return a;
}
#endif

#ifdef SVQC
void dedicated_print(string input) // print(), but only print if the server is not local
{
	if(server_is_dedicated) { print(input); }
}
#endif

#ifndef MENUQC
float Announcer_PickNumber(float type, float num)
{
	switch(type)
	{
		case CNT_GAMESTART:
		{
			switch(num)
			{
				case 10: return ANNCE_NUM_GAMESTART_10;
				case 9:  return ANNCE_NUM_GAMESTART_9;
				case 8:  return ANNCE_NUM_GAMESTART_8;
				case 7:  return ANNCE_NUM_GAMESTART_7;
				case 6:  return ANNCE_NUM_GAMESTART_6;
				case 5:  return ANNCE_NUM_GAMESTART_5;
				case 4:  return ANNCE_NUM_GAMESTART_4;
				case 3:  return ANNCE_NUM_GAMESTART_3;
				case 2:  return ANNCE_NUM_GAMESTART_2;
				case 1:  return ANNCE_NUM_GAMESTART_1;
			}
			break;
		}
		case CNT_IDLE:
		{
			switch(num)
			{
				case 10: return ANNCE_NUM_IDLE_10;
				case 9:  return ANNCE_NUM_IDLE_9;
				case 8:  return ANNCE_NUM_IDLE_8;
				case 7:  return ANNCE_NUM_IDLE_7;
				case 6:  return ANNCE_NUM_IDLE_6;
				case 5:  return ANNCE_NUM_IDLE_5;
				case 4:  return ANNCE_NUM_IDLE_4;
				case 3:  return ANNCE_NUM_IDLE_3;
				case 2:  return ANNCE_NUM_IDLE_2;
				case 1:  return ANNCE_NUM_IDLE_1;
			}
			break;
		}
		case CNT_KILL:
		{
			switch(num)
			{
				case 10: return ANNCE_NUM_KILL_10;
				case 9:  return ANNCE_NUM_KILL_9;
				case 8:  return ANNCE_NUM_KILL_8;
				case 7:  return ANNCE_NUM_KILL_7;
				case 6:  return ANNCE_NUM_KILL_6;
				case 5:  return ANNCE_NUM_KILL_5;
				case 4:  return ANNCE_NUM_KILL_4;
				case 3:  return ANNCE_NUM_KILL_3;
				case 2:  return ANNCE_NUM_KILL_2;
				case 1:  return ANNCE_NUM_KILL_1;
			}
			break;
		}
		case CNT_RESPAWN:
		{
			switch(num)
			{
				case 10: return ANNCE_NUM_RESPAWN_10;
				case 9:  return ANNCE_NUM_RESPAWN_9;
				case 8:  return ANNCE_NUM_RESPAWN_8;
				case 7:  return ANNCE_NUM_RESPAWN_7;
				case 6:  return ANNCE_NUM_RESPAWN_6;
				case 5:  return ANNCE_NUM_RESPAWN_5;
				case 4:  return ANNCE_NUM_RESPAWN_4;
				case 3:  return ANNCE_NUM_RESPAWN_3;
				case 2:  return ANNCE_NUM_RESPAWN_2;
				case 1:  return ANNCE_NUM_RESPAWN_1;
			}
			break;
		}
		case CNT_ROUNDSTART:
		{
			switch(num)
			{
				case 10: return ANNCE_NUM_ROUNDSTART_10;
				case 9:  return ANNCE_NUM_ROUNDSTART_9;
				case 8:  return ANNCE_NUM_ROUNDSTART_8;
				case 7:  return ANNCE_NUM_ROUNDSTART_7;
				case 6:  return ANNCE_NUM_ROUNDSTART_6;
				case 5:  return ANNCE_NUM_ROUNDSTART_5;
				case 4:  return ANNCE_NUM_ROUNDSTART_4;
				case 3:  return ANNCE_NUM_ROUNDSTART_3;
				case 2:  return ANNCE_NUM_ROUNDSTART_2;
				case 1:  return ANNCE_NUM_ROUNDSTART_1;
			}
			break;
		}
		default:
		{
			switch(num)
			{
				case 10: return ANNCE_NUM_10;
				case 9:  return ANNCE_NUM_9;
				case 8:  return ANNCE_NUM_8;
				case 7:  return ANNCE_NUM_7;
				case 6:  return ANNCE_NUM_6;
				case 5:  return ANNCE_NUM_5;
				case 4:  return ANNCE_NUM_4;
				case 3:  return ANNCE_NUM_3;
				case 2:  return ANNCE_NUM_2;
				case 1:  return ANNCE_NUM_1;
			}
			break;
		}
	}
	return NOTIF_ABORT; // abort sending if none of these numbers were right
}
#endif

#ifndef MENUQC
float Mod_Q1BSP_SuperContentsFromNativeContents(float nativecontents)
{
	switch(nativecontents)
	{
		case CONTENT_EMPTY:
			return 0;
		case CONTENT_SOLID:
			return DPCONTENTS_SOLID | DPCONTENTS_OPAQUE;
		case CONTENT_WATER:
			return DPCONTENTS_WATER;
		case CONTENT_SLIME:
			return DPCONTENTS_SLIME;
		case CONTENT_LAVA:
			return DPCONTENTS_LAVA | DPCONTENTS_NODROP;
		case CONTENT_SKY:
			return DPCONTENTS_SKY | DPCONTENTS_NODROP | DPCONTENTS_OPAQUE; // to match behaviour of Q3 maps, let sky count as opaque
	}
	return 0;
}

float Mod_Q1BSP_NativeContentsFromSuperContents(float supercontents)
{
	if(supercontents & (DPCONTENTS_SOLID | DPCONTENTS_BODY))
		return CONTENT_SOLID;
	if(supercontents & DPCONTENTS_SKY)
		return CONTENT_SKY;
	if(supercontents & DPCONTENTS_LAVA)
		return CONTENT_LAVA;
	if(supercontents & DPCONTENTS_SLIME)
		return CONTENT_SLIME;
	if(supercontents & DPCONTENTS_WATER)
		return CONTENT_WATER;
	return CONTENT_EMPTY;
}
#endif
