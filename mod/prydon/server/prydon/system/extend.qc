float(string name) checkextension 			= #99; 
float(string s) builtin_find = #100;

float EF_SELECTABLE = 16384; // allows cursor to highlight entity (brighten)

.float cursor_active; // true if cl_prydoncursor mode is on
.vector cursor_screen; // screen position of cursor as -1 to +1 in _x and _y (_z unused)
.vector cursor_trace_start; // position of camera
.vector cursor_trace_endpos; // position of cursor in world (as traced from camera)
.entity cursor_trace_ent; // entity the cursor is pointing at

nosave float snowtype; // 0 = QuakeC sprites, 1 = TQ flavor, 2 = DP flavor
nosave float fileaccess;
nosave float vmfc; // viewmodelforclient
nosave var float fadeinterval = 1;

float(string s)stof = #81;
float(string filename, float mode) fopen = #110;
void(float fhandle) fclose = #111;
string(float fhandle) read = #112;
void(float fhandle, string s) write = #113;
string(string s1, string s2) strcat = #115;
vector(string s) stov = #117;
string(string s) strzone = #118;
void(string s) strunzone = #119;


.float alpha;
float FILE_READ = 0;
float FILE_APPEND = 1;
float FILE_WRITE = 2;


void extend()
{
	snowtype = 0;
	if (cvar("pr_checkextension"))
	{
		localcmd("echo pr_checkextension support detected\n");
		if (checkextension("DP_TE_PARTICLESNOW"))
			snowtype = 2;
		if (checkextension("TQ_SNOW"))
			snowtype = 1;
		if (checkextension("DP_ENT_ALPHA"))
			fadeinterval = 0.02;
		if (checkextension("FRIK_FILE"))
			fileaccess = 1;
		if (checkextension("DP_ENT_VIEWMODEL"))
			vmfc = 1;
	}
	if ( cvar("pr_builtin_find") == 100)
	{
		localcmd("echo pr_builtin_find support detected\n");

		if (builtin_find("stof") == 81)
		if (builtin_find("fopen") == 110)
		if (builtin_find("fclose") == 111)
		if (builtin_find("fgets") == 112)
		if (builtin_find("fputs") == 113)
		if (builtin_find("strcat") == 115)
			fileaccess = 1;
	}
};
nosave float filehandle;
nosave var float fileerror = 0;
string qread () =
{
	string s;
	if (fileerror)
		return string_null;
	if (filehandle < 0)
	{
		fileerror = 1;
		return string_null;
	}
	s = read(filehandle);
	if (!s)
	{
		fileerror = 1;
		fclose(filehandle);
	}
	return s;
};
void(string r) qwrite =
{
	if (fileerror)
		return;
	write(filehandle, r);
	write(filehandle, "\n");
};

void (string fname) qopenread = 
{
	filehandle = fopen(fname, FILE_READ);
	if (filehandle < 0)
		fileerror = 1;
	else
		fileerror = 0;
};

void (string fname) qopenwrite =
{
	filehandle = fopen(fname, FILE_WRITE);
	if (filehandle < 0)
		fileerror = 1;
	else
		fileerror = 0;
};

void () qclose =
{
	if (fileerror)
		return;
	fclose(filehandle);
};