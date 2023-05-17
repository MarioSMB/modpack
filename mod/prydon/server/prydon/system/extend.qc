#include "extend.qh"

STATIC_INIT_EARLY(extend)
{
	// dp defaults
	snowtype = 2;
	fileaccess = true;
	vmfc = true;
}

string qread()
{
	if(fileerror)
		return string_null;
	if(filehandle < 0)
	{
		fileerror = 1;
		return string_null;
	}
	string s = fgets(filehandle);
	if(!s)
	{
		fileerror = 1;
		fclose(filehandle);
	}
	return s;
}

void qwrite(string r)
{
	if(fileerror)
		return;
	fputs(filehandle, r);
	fputs(filehandle, "\n");
}

void qopenread(string fname)
{
	filehandle = fopen(fname, FILE_READ);
	if(filehandle < 0)
		fileerror = 1;
	else
		fileerror = 0;
}

void qopenwrite(string fname)
{
	filehandle = fopen(fname, FILE_WRITE);
	if(filehandle < 0)
		fileerror = 1;
	else
		fileerror = 0;
}

void qclose()
{
	if(fileerror)
		return;
	fclose(filehandle);
}
