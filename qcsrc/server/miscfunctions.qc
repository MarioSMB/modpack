var void remove(entity e);
void objerror(string s);
void droptofloor();
.vector dropped_origin;

void traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag);
void crosshair_trace(entity pl)
{
	traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_NORMAL, pl, ANTILAG_LATENCY(pl));
}
void crosshair_trace_plusvisibletriggers(entity pl)
{
	entity first;
	entity e;
	first = findchainfloat(solid, SOLID_TRIGGER);

	for (e = first; e; e = e.chain)
		if (e.model != "")
			e.solid = SOLID_BSP;

	crosshair_trace(pl);

	for (e = first; e; e = e.chain)
		e.solid = SOLID_TRIGGER;
}
void WarpZone_traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag);
void WarpZone_crosshair_trace(entity pl)
{
	WarpZone_traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_NORMAL, pl, ANTILAG_LATENCY(pl));
}

void() spawnfunc_info_player_deathmatch; // needed for the other spawnpoints
void() spawnpoint_use;
string GetMapname();

string admin_name(void)
{
	if(autocvar_sv_adminnick != "")
		return autocvar_sv_adminnick;
	else
		return "SERVER ADMIN";
}

float DistributeEvenly_amount;
float DistributeEvenly_totalweight;
void DistributeEvenly_Init(float amount, float totalweight)
{
    if (DistributeEvenly_amount)
    {
        dprint("DistributeEvenly_Init: UNFINISHED DISTRIBUTION (", ftos(DistributeEvenly_amount), " for ");
        dprint(ftos(DistributeEvenly_totalweight), " left!)\n");
    }
    if (totalweight == 0)
        DistributeEvenly_amount = 0;
    else
        DistributeEvenly_amount = amount;
    DistributeEvenly_totalweight = totalweight;
}
float DistributeEvenly_Get(float weight)
{
    float f;
    if (weight <= 0)
        return 0;
    f = floor(0.5 + DistributeEvenly_amount * weight / DistributeEvenly_totalweight);
    DistributeEvenly_totalweight -= weight;
    DistributeEvenly_amount -= f;
    return f;
}
float DistributeEvenly_GetRandomized(float weight)
{
    float f;
    if (weight <= 0)
        return 0;
    f = floor(random() + DistributeEvenly_amount * weight / DistributeEvenly_totalweight);
    DistributeEvenly_totalweight -= weight;
    DistributeEvenly_amount -= f;
    return f;
}

#define move_out_of_solid(e) WarpZoneLib_MoveOutOfSolid(e)

string STR_PLAYER = "player";
string STR_SPECTATOR = "spectator";
string STR_OBSERVER = "observer";

#define IS_PLAYER(v) 			(v.classname == STR_PLAYER)
#define IS_SPEC(v) 				(v.classname == STR_SPECTATOR)
#define IS_OBSERVER(v) 			(v.classname == STR_OBSERVER)
#define IS_CLIENT(v)			(v.flags & FL_CLIENT)
#define IS_BOT_CLIENT(v) 		(clienttype(v) == CLIENTTYPE_BOT)
#define IS_REAL_CLIENT(v) 		(clienttype(v) == CLIENTTYPE_REAL)
#define IS_NOT_A_CLIENT(v) 		(clienttype(v) == CLIENTTYPE_NOTACLIENT)

#define FOR_EACH_CLIENTSLOT(v) for(v = world; (v = nextent(v)) && (num_for_edict(v) <= maxclients); )
#define FOR_EACH_CLIENT(v) FOR_EACH_CLIENTSLOT(v) if(IS_CLIENT(v))
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(IS_REAL_CLIENT(v))

#define FOR_EACH_PLAYER(v) FOR_EACH_CLIENT(v) if(IS_PLAYER(v))
#define FOR_EACH_SPEC(v) FOR_EACH_CLIENT(v) if not(IS_PLAYER(v)) // Samual: shouldn't this be IS_SPEC(v)? and rather create a separate macro to include observers too
#define FOR_EACH_REALPLAYER(v) FOR_EACH_REALCLIENT(v) if(IS_PLAYER(v))

#define FOR_EACH_MONSTER(v) for(v = world; (v = findflags(v, flags, FL_MONSTER)) != world; )

#define CENTER_OR_VIEWOFS(ent) (ent.origin + (IS_PLAYER(ent) ? ent.view_ofs : ((ent.mins + ent.maxs) * 0.5)))

// copies a string to a tempstring (so one can strunzone it)
string strcat1(string s) = #115; // FRIK_FILE

float logfile_open;
float logfile;

void GameLogEcho(string s)
{
    string fn;
    float matches;

    if (autocvar_sv_eventlog_files)
    {
        if (!logfile_open)
        {
            logfile_open = TRUE;
            matches = autocvar_sv_eventlog_files_counter + 1;
            cvar_set("sv_eventlog_files_counter", ftos(matches));
            fn = ftos(matches);
            if (strlen(fn) < 8)
                fn = strcat(substring("00000000", 0, 8 - strlen(fn)), fn);
            fn = strcat(autocvar_sv_eventlog_files_nameprefix, fn, autocvar_sv_eventlog_files_namesuffix);
            logfile = fopen(fn, FILE_APPEND);
            fputs(logfile, ":logversion:3\n");
        }
        if (logfile >= 0)
        {
            if (autocvar_sv_eventlog_files_timestamps)
                fputs(logfile, strcat(":time:", strftime(TRUE, "%Y-%m-%d %H:%M:%S", "\n", s, "\n")));
            else
                fputs(logfile, strcat(s, "\n"));
        }
    }
    if (autocvar_sv_eventlog_console)
    {
        print(s, "\n");
    }
}

void GameLogInit()
{
    logfile_open = 0;
    // will be opened later
}

void GameLogClose()
{
    if (logfile_open && logfile >= 0)
    {
        fclose(logfile);
        logfile = -1;
    }
}

#define strstr strstrofs
/*
// NOTE: DO NOT USE THIS FUNCTION TOO OFTEN.
// IT WILL MOST PROBABLY DESTROY _ALL_ OTHER TEMP
// STRINGS AND TAKE QUITE LONG. haystack and needle MUST
// BE CONSTANT OR strzoneD!
float strstr(string haystack, string needle, float offset)
{
	float len, endpos;
	string found;
	len = strlen(needle);
	endpos = strlen(haystack) - len;
	while(offset <= endpos)
	{
		found = substring(haystack, offset, len);
		if(found == needle)
			return offset;
		offset = offset + 1;
	}
	return -1;
}
*/

float NUM_NEAREST_ENTITIES = 4;
entity nearest_entity[NUM_NEAREST_ENTITIES];
float nearest_length[NUM_NEAREST_ENTITIES];
entity findnearest(vector point, .string field, string value, vector axismod)
{
    entity localhead;
    float i;
    float j;
    float len;
    vector dist;

    float num_nearest;
    num_nearest = 0;

    localhead = find(world, field, value);
    while (localhead)
    {
        if ((localhead.items == IT_KEY1 || localhead.items == IT_KEY2) && localhead.target == "###item###")
            dist = localhead.oldorigin;
        else
            dist = localhead.origin;
        dist = dist - point;
        dist = dist_x * axismod_x * '1 0 0' + dist_y * axismod_y * '0 1 0' + dist_z * axismod_z * '0 0 1';
        len = vlen(dist);

        for (i = 0; i < num_nearest; ++i)
        {
            if (len < nearest_length[i])
                break;
        }

        // now i tells us where to insert at
        //   INSERTION SORT! YOU'VE SEEN IT! RUN!
        if (i < NUM_NEAREST_ENTITIES)
        {
            for (j = NUM_NEAREST_ENTITIES - 1; j >= i; --j)
            {
                nearest_length[j + 1] = nearest_length[j];
                nearest_entity[j + 1] = nearest_entity[j];
            }
            nearest_length[i] = len;
            nearest_entity[i] = localhead;
            if (num_nearest < NUM_NEAREST_ENTITIES)
                num_nearest = num_nearest + 1;
        }

        localhead = find(localhead, field, value);
    }

    // now use the first one from our list that we can see
    for (i = 0; i < num_nearest; ++i)
    {
        traceline(point, nearest_entity[i].origin, TRUE, world);
        if (trace_fraction == 1)
        {
            if (i != 0)
            {
                dprint("Nearest point (");
                dprint(nearest_entity[0].netname);
                dprint(") is not visible, using a visible one.\n");
            }
            return nearest_entity[i];
        }
    }

    if (num_nearest == 0)
        return world;

    dprint("Not seeing any location point, using nearest as fallback.\n");
    /* DEBUGGING CODE:
    dprint("Candidates were: ");
    for(j = 0; j < num_nearest; ++j)
    {
    	if(j != 0)
    		dprint(", ");
    	dprint(nearest_entity[j].netname);
    }
    dprint("\n");
    */

    return nearest_entity[0];
}

void spawnfunc_target_location()
{
    self.classname = "target_location";
    // location name in netname
    // eventually support: count, teamgame selectors, line of sight?
}

void spawnfunc_info_location()
{
    self.classname = "target_location";
    self.message = self.netname;
}

string NearestLocation(vector p)
{
    entity loc;
    string ret;
    ret = "somewhere";
    loc = findnearest(p, classname, "target_location", '1 1 1');
    if (loc)
    {
        ret = loc.message;
    }
    else
    {
        loc = findnearest(p, target, "###item###", '1 1 4');
        if (loc)
            ret = loc.netname;
    }
    return ret;
}

string formatmessage(string msg)
{
	float p, p1, p2;
	float n;
	vector cursor;
	entity cursor_ent;
	string escape;
	string replacement;
	entity bluefc = world, redfc = world, yellowfc = world, pinkfc = world, tmp_entity; // NOTE: blue = red player
	entity tfc = world, sfc = world;
	p = 0;
	n = 7;
	
	for(tmp_entity = ctf_worldflaglist; tmp_entity; tmp_entity = tmp_entity.ctf_worldflagnext)
	{
		if(tmp_entity.owner && tmp_entity.team == NUM_TEAM_1)
			redfc = tmp_entity.owner;
		if(tmp_entity.owner && tmp_entity.team == NUM_TEAM_2)
			bluefc = tmp_entity.owner;
		if(tmp_entity.owner && tmp_entity.team == NUM_TEAM_3)
			yellowfc = tmp_entity.owner;
		if(tmp_entity.owner && tmp_entity.team == NUM_TEAM_4)
			pinkfc = tmp_entity.owner;
			
		if(tmp_entity.owner && tmp_entity.owner.team == self.team)
			tfc = tmp_entity.owner;
		if(tmp_entity.owner && tmp_entity.team == self.team)
			sfc = tmp_entity.owner;
	}
			

	WarpZone_crosshair_trace(self);
	cursor = trace_endpos;
	cursor_ent = trace_ent;

	while (1) {
		if (n < 1)
			break; // too many replacements

		n = n - 1;
		p1 = strstr(msg, "%", p); // NOTE: this destroys msg as it's a tempstring!
		p2 = strstr(msg, "\\", p); // NOTE: this destroys msg as it's a tempstring!

		if (p1 < 0)
			p1 = p2;

		if (p2 < 0)
			p2 = p1;

		p = min(p1, p2);

		if (p < 0)
			break;

		replacement = substring(msg, p, 2);
		escape = substring(msg, p + 1, 1);

		if (escape == "%")
			replacement = "%";
		else if (escape == "\\")
			replacement = "\\";
		else if (escape == "n")
			replacement = "\n";
		else if (escape == "a")
			replacement = ftos(floor(self.armorvalue));
		else if (escape == "h")
			replacement = ftos(floor(self.health));
		else if (escape == "j")
			replacement = ((self.lastkilled) ? self.lastkilled.netname : "(nobody)");
		else if (escape == "k")
			replacement = ((self.lastkiller) ? self.lastkiller.netname : "(nobody)");
		else if (escape == "l")
			replacement = NearestLocation(self.origin);
		else if (escape == "r")
			replacement = ((tfc) ? tfc.netname : "(nobody)");
		else if (escape == "R")
			replacement = ((sfc) ? sfc.netname : "(nobody)");
		else if (escape == "t")
			replacement = ((redfc) ? redfc.netname : "(nobody)");
		else if (escape == "T")
			replacement = ((bluefc) ? bluefc.netname : "(nobody)");
		else if (escape == "p")
			replacement = ((yellowfc) ? yellowfc.netname : "(nobody)");
		else if (escape == "P")
			replacement = ((pinkfc) ? pinkfc.netname : "(nobody)");
		else if (escape == "y")
			replacement = NearestLocation(cursor);
		else if (escape == "d")
			replacement = NearestLocation(self.death_origin);
		else if (escape == "w") {
			float wep;
			wep = self.weapon;
			if (!wep)
				wep = self.switchweapon;
			if (!wep)
				wep = self.cnt;
			replacement = W_Name(wep);
		} else if (escape == "W") {
			if (self.items & IT_SHELLS) replacement = "shells";
			else if (self.items & IT_NAILS) replacement = "bullets";
			else if (self.items & IT_ROCKETS) replacement = "rockets";
			else if (self.items & IT_CELLS) replacement = "cells";
			else replacement = "batteries"; // ;)
		} else if (escape == "x") {
			replacement = cursor_ent.netname;
			if (replacement == "" || !cursor_ent)
				replacement = "nothing";
		} else if (escape == "s")
			replacement = ftos(vlen(self.velocity - self.velocity_z * '0 0 1'));
		else if (escape == "S")
			replacement = ftos(vlen(self.velocity));

		msg = strcat(substring(msg, 0, p), replacement, substring(msg, p+2, strlen(msg) - (p+2)));
		p = p + strlen(replacement);
	}
	return msg;
}

float boolean(float value) { // if value is 0 return FALSE (0), otherwise return TRUE (1)
	return (value == 0) ? FALSE : TRUE;
}

/*
=============
GetCvars
=============
Called with:
  0:  sends the request
  >0: receives a cvar from name=argv(f) value=argv(f+1)
*/
void GetCvars_handleString(string thisname, float f, .string field, string name)
{
	if (f < 0)
	{
		if (self.field)
			strunzone(self.field);
		self.field = string_null;
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			if (self.field)
				strunzone(self.field);
			self.field = strzone(argv(f + 1));
		}
	}
	else
		stuffcmd(self, strcat("cl_cmd sendcvar ", name, "\n"));
}
void GetCvars_handleString_Fixup(string thisname, float f, .string field, string name, string(string) func)
{
	GetCvars_handleString(thisname, f, field, name);
	if (f >= 0) // also initialize to the fitting value for "" when sending cvars out
		if (thisname == name)
		{
			string s;
			s = func(strcat1(self.field));
			if (s != self.field)
			{
				strunzone(self.field);
				self.field = strzone(s);
			}
		}
}
void GetCvars_handleFloat(string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
			self.field = stof(argv(f + 1));
	}
	else
		stuffcmd(self, strcat("cl_cmd sendcvar ", name, "\n"));
}
void GetCvars_handleFloatOnce(string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			if(!self.field)
			{
				self.field = stof(argv(f + 1));
				if(!self.field)
					self.field = -1;
			}
		}
	}
	else
	{
		if(!self.field)
			stuffcmd(self, strcat("cl_cmd sendcvar ", name, "\n"));
	}
}
float w_getbestweapon(entity e);
string W_FixWeaponOrder_ForceComplete_AndBuildImpulseList(string wo)
{
	string o;
	o = W_FixWeaponOrder_ForceComplete(wo);
	if(self.weaponorder_byimpulse)
	{
		strunzone(self.weaponorder_byimpulse);
		self.weaponorder_byimpulse = string_null;
	}
	self.weaponorder_byimpulse = strzone(W_FixWeaponOrder_BuildImpulseList(o));
	return o;
}
void GetCvars(float f)
{
	string s = string_null;

	if (f > 0)
		s = strcat1(argv(f));

	get_cvars_f = f;
	get_cvars_s = s;

	MUTATOR_CALLHOOK(GetCvars);

	Notification_GetCvars();

	GetCvars_handleFloat(s, f, autoswitch, "cl_autoswitch");
	GetCvars_handleFloat(s, f, cvar_cl_autoscreenshot, "cl_autoscreenshot");
	GetCvars_handleString(s, f, cvar_g_xonoticversion, "g_xonoticversion");
	GetCvars_handleFloat(s, f, cvar_cl_sparkle, "cl_sparkle");
	GetCvars_handleFloat(s, f, cvar_cl_pony, "cl_pony");
	GetCvars_handleFloat(s, f, cvar_cl_pony_skin, "cl_pony_skin");
	GetCvars_handleFloat(s, f, cvar_cl_bikini, "cl_bikini");
	GetCvars_handleFloat(s, f, cvar_cl_bikini_skin, "cl_bikini_skin");
	GetCvars_handleFloat(s, f, cvar_cl_handicap, "cl_handicap");
	GetCvars_handleFloat(s, f, cvar_cl_clippedspectating, "cl_clippedspectating");
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriority, "cl_weaponpriority", W_FixWeaponOrder_ForceComplete_AndBuildImpulseList);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[0], "cl_weaponpriority0", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[1], "cl_weaponpriority1", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[2], "cl_weaponpriority2", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[3], "cl_weaponpriority3", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[4], "cl_weaponpriority4", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[5], "cl_weaponpriority5", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[6], "cl_weaponpriority6", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[7], "cl_weaponpriority7", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[8], "cl_weaponpriority8", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[9], "cl_weaponpriority9", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleFloat(s, f, cvar_cl_weaponimpulsemode, "cl_weaponimpulsemode");
	GetCvars_handleFloat(s, f, cvar_cl_autotaunt, "cl_autotaunt");
	GetCvars_handleFloat(s, f, cvar_cl_noantilag, "cl_noantilag");
	GetCvars_handleFloat(s, f, cvar_cl_voice_directional, "cl_voice_directional");
	GetCvars_handleFloat(s, f, cvar_cl_voice_directional_taunt_attenuation, "cl_voice_directional_taunt_attenuation");
	GetCvars_handleFloat(s, f, cvar_cl_accuracy_data_share, "cl_accuracy_data_share");
	GetCvars_handleFloat(s, f, cvar_cl_accuracy_data_receive, "cl_accuracy_data_receive");

	self.cvar_cl_accuracy_data_share = boolean(self.cvar_cl_accuracy_data_share);
	self.cvar_cl_accuracy_data_receive = boolean(self.cvar_cl_accuracy_data_receive);

	GetCvars_handleFloatOnce(s, f, cvar_cl_gunalign, "cl_gunalign");
	GetCvars_handleFloat(s, f, cvar_cl_allow_uid2name, "cl_allow_uid2name");
	GetCvars_handleFloat(s, f, cvar_cl_allow_uidtracking, "cl_allow_uidtracking");
	GetCvars_handleFloat(s, f, cvar_cl_movement_track_canjump, "cl_movement_track_canjump");
	GetCvars_handleFloat(s, f, cvar_cl_newusekeysupported, "cl_newusekeysupported");

	// fixup of switchweapon (needed for LMS or when spectating is disabled, as PutClientInServer comes too early)
	if (f > 0)
	{
		if (s == "cl_weaponpriority")
			self.switchweapon = w_getbestweapon(self);
		if (s == "cl_allow_uidtracking")
			PlayerStats_AddPlayer(self);
	}
}

// decolorizes and team colors the player name when needed
string playername(entity p)
{
    string t;
    if (teamplay && !intermission_running && IS_PLAYER(p))
    {
        t = Team_ColorCode(p.team);
        return strcat(t, strdecolorize(p.netname));
    }
    else
        return p.netname;
}

vector randompos(vector m1, vector m2)
{
    vector v;
    m2 = m2 - m1;
    v_x = m2_x * random() + m1_x;
    v_y = m2_y * random() + m1_y;
    v_z = m2_z * random() + m1_z;
    return  v;
}

//#NO AUTOCVARS START

float g_pickup_shells;
float g_pickup_shells_max;
float g_pickup_nails;
float g_pickup_nails_max;
float g_pickup_rockets;
float g_pickup_rockets_max;
float g_pickup_cells;
float g_pickup_cells_max;
float g_pickup_fuel;
float g_pickup_fuel_jetpack;
float g_pickup_fuel_max;
float g_pickup_armorsmall;
float g_pickup_armorsmall_max;
float g_pickup_armorsmall_anyway;
float g_pickup_armormedium;
float g_pickup_armormedium_max;
float g_pickup_armormedium_anyway;
float g_pickup_armorbig;
float g_pickup_armorbig_max;
float g_pickup_armorbig_anyway;
float g_pickup_armorlarge;
float g_pickup_armorlarge_max;
float g_pickup_armorlarge_anyway;
float g_pickup_healthsmall;
float g_pickup_healthsmall_max;
float g_pickup_healthsmall_anyway;
float g_pickup_healthmedium;
float g_pickup_healthmedium_max;
float g_pickup_healthmedium_anyway;
float g_pickup_healthlarge;
float g_pickup_healthlarge_max;
float g_pickup_healthlarge_anyway;
float g_pickup_healthmega;
float g_pickup_healthmega_max;
float g_pickup_healthmega_anyway;
float g_pickup_ammo_anyway;
float g_pickup_weapons_anyway;
float g_weaponarena;
WEPSET_DECLARE_A(g_weaponarena_weapons);
float g_weaponarena_random;
float g_weaponarena_random_with_laser;
string g_weaponarena_list;
float g_weaponspeedfactor;
float g_weaponratefactor;
float g_weapondamagefactor;
float g_weaponforcefactor;
float g_weaponspreadfactor;

WEPSET_DECLARE_A(start_weapons);
WEPSET_DECLARE_A(start_weapons_default);
WEPSET_DECLARE_A(start_weapons_defaultmask);
float start_items;
float start_ammo_shells;
float start_ammo_nails;
float start_ammo_rockets;
float start_ammo_cells;
float start_ammo_fuel;
float start_health;
float start_armorvalue;
WEPSET_DECLARE_A(warmup_start_weapons);
WEPSET_DECLARE_A(warmup_start_weapons_default);
WEPSET_DECLARE_A(warmup_start_weapons_defaultmask);
float warmup_start_ammo_shells;
float warmup_start_ammo_nails;
float warmup_start_ammo_rockets;
float warmup_start_ammo_cells;
float warmup_start_ammo_fuel;
float warmup_start_health;
float warmup_start_armorvalue;
float g_weapon_stay;

entity get_weaponinfo(float w);

float want_weapon(string cvarprefix, entity weaponinfo, float allguns)
{
	var float i = weaponinfo.weapon;
	var float d = 0;

	if (!i)
		return 0;

	if (g_lms || g_ca || allguns)
	{
		if(weaponinfo.spawnflags & WEP_FLAG_NORMAL)
			d = TRUE;
		else
			d = FALSE;
	}
	else if (g_cts)
		d = (i == WEP_SHOTGUN);
	else if (g_nexball)
		d = 0; // weapon is set a few lines later
	else
		d = (i == WEP_LASER || i == WEP_SHOTGUN);
		
	if(g_grappling_hook) // if possible, redirect off-hand hook to on-hand hook
		d |= (i == WEP_HOOK);
	if(weaponinfo.spawnflags & WEP_FLAG_MUTATORBLOCKED) // never default mutator blocked guns
		d = 0;

	var float t = cvar(strcat(cvarprefix, weaponinfo.netname));
	
	//print(strcat("want_weapon: ", weaponinfo.netname, " - d: ", ftos(d), ", t: ", ftos(t), ". \n"));
	
	// bit order in t:
	// 1: want or not
	// 2: is default?
	// 4: is set by default?
	if(t < 0)
		t = 4 | (3 * d);
	else
		t |= (2 * d);

	return t;
}

void readplayerstartcvars()
{
	entity e;
	float i, j, t;
	string s;

	// initialize starting values for players
	WEPSET_CLEAR_A(start_weapons);
	WEPSET_CLEAR_A(start_weapons_default);
	WEPSET_CLEAR_A(start_weapons_defaultmask);
	start_items = 0;
	start_ammo_shells = 0;
	start_ammo_nails = 0;
	start_ammo_rockets = 0;
	start_ammo_cells = 0;
	start_health = cvar("g_balance_health_start");
	start_armorvalue = cvar("g_balance_armor_start");

	g_weaponarena = 0;
	WEPSET_CLEAR_A(g_weaponarena_weapons);

	s = cvar_string("g_weaponarena");
	if (s == "0" || s == "")
	{
		if(g_ca)
			s = "most";
	}

	if (s == "0" || s == "")
	{
		// no arena
	}
	else if (s == "off")
	{
		// forcibly turn off weaponarena
	}
	else if (s == "all")
	{
		g_weaponarena = 1;
		g_weaponarena_list = "All Weapons";
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if not(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
				WEPSET_OR_AW(g_weaponarena_weapons, j);
		}
	}
	else if (s == "most")
	{
		g_weaponarena = 1;
		g_weaponarena_list = "Most Weapons";
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if not(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
				if (e.spawnflags & WEP_FLAG_NORMAL)
					WEPSET_OR_AW(g_weaponarena_weapons, j);
		}
	}
	else if (s == "none")
	{
		g_weaponarena = 1;
		g_weaponarena_list = "No Weapons";
	}
	else
	{
		g_weaponarena = 1;
		t = tokenize_console(s);
		g_weaponarena_list = "";
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(g_weaponarena_weapons, j);
					g_weaponarena_list = strcat(g_weaponarena_list, e.message, " & ");
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The weapon mutator list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
		g_weaponarena_list = strzone(substring(g_weaponarena_list, 0, strlen(g_weaponarena_list) - 3));
	}

	if(g_weaponarena)
		g_weaponarena_random = cvar("g_weaponarena_random");
	else
		g_weaponarena_random = 0;
	g_weaponarena_random_with_laser = cvar("g_weaponarena_random_with_laser");

	if (g_weaponarena)
	{
		g_weapon_stay = 0; // incompatible
		WEPSET_COPY_AA(start_weapons, g_weaponarena_weapons);
		start_items |= IT_UNLIMITED_AMMO;
	}
	else
	{
		for (i = WEP_FIRST; i <= WEP_LAST; ++i)
		{
			e = get_weaponinfo(i);
			float w = want_weapon("g_start_weapon_", e, FALSE);
			if(w & 1)
				WEPSET_OR_AW(start_weapons, i);
			if(w & 2)
				WEPSET_OR_AW(start_weapons_default, i);
			if(w & 4)
				WEPSET_OR_AW(start_weapons_defaultmask, i);
		}
	}

	if(!cvar("g_use_ammunition"))
		start_items |= IT_UNLIMITED_AMMO;
	
	if(start_items & IT_UNLIMITED_WEAPON_AMMO)
	{
		start_ammo_rockets = 999;
		start_ammo_shells = 999;
		start_ammo_cells = 999;
		start_ammo_nails = 999;
		start_ammo_fuel = 999;
	}
	else
	{
		start_ammo_shells = cvar("g_start_ammo_shells");
		start_ammo_nails = cvar("g_start_ammo_nails");
		start_ammo_rockets = cvar("g_start_ammo_rockets");
		start_ammo_cells = cvar("g_start_ammo_cells");
		start_ammo_fuel = cvar("g_start_ammo_fuel");
	}

	if (inWarmupStage)
	{
		warmup_start_ammo_shells = start_ammo_shells;
		warmup_start_ammo_nails = start_ammo_nails;
		warmup_start_ammo_rockets = start_ammo_rockets;
		warmup_start_ammo_cells = start_ammo_cells;
		warmup_start_ammo_fuel = start_ammo_fuel;
		warmup_start_health = start_health;
		warmup_start_armorvalue = start_armorvalue;
		WEPSET_COPY_AA(warmup_start_weapons, start_weapons);
		WEPSET_COPY_AA(warmup_start_weapons_default, start_weapons_default);
		WEPSET_COPY_AA(warmup_start_weapons_defaultmask, start_weapons_defaultmask);

		if (!g_weaponarena && !g_ca)
		{
			warmup_start_ammo_shells = cvar("g_warmup_start_ammo_shells");
			warmup_start_ammo_cells = cvar("g_warmup_start_ammo_cells");
			warmup_start_ammo_nails = cvar("g_warmup_start_ammo_nails");
			warmup_start_ammo_rockets = cvar("g_warmup_start_ammo_rockets");
			warmup_start_ammo_fuel = cvar("g_warmup_start_ammo_fuel");
			warmup_start_health = cvar("g_warmup_start_health");
			warmup_start_armorvalue = cvar("g_warmup_start_armor");
			WEPSET_CLEAR_A(warmup_start_weapons);
			WEPSET_CLEAR_A(warmup_start_weapons_default);
			WEPSET_CLEAR_A(warmup_start_weapons_defaultmask);
			for (i = WEP_FIRST; i <= WEP_LAST; ++i)
			{
				e = get_weaponinfo(i);
				float w = want_weapon("g_start_weapon_", e, cvar("g_warmup_allguns"));
				if(w & 1)
					WEPSET_OR_AW(warmup_start_weapons, i);
				if(w & 2)
					WEPSET_OR_AW(warmup_start_weapons_default, i);
				if(w & 4)
					WEPSET_OR_AW(warmup_start_weapons_defaultmask, i);
			}
		}
	}

	if (g_jetpack)
		start_items |= IT_JETPACK;

	MUTATOR_CALLHOOK(SetStartItems);

	if ((start_items & IT_JETPACK) || (g_grappling_hook && WEPSET_CONTAINS_AW(start_weapons, WEP_HOOK)))
	{
		g_grappling_hook = 0; // these two can't coexist, as they use the same button
		start_items |= IT_FUEL_REGEN;
		start_ammo_fuel = max(start_ammo_fuel, cvar("g_balance_fuel_rotstable"));
		warmup_start_ammo_fuel = max(warmup_start_ammo_fuel, cvar("g_balance_fuel_rotstable"));
	}

	for (i = WEP_FIRST; i <= WEP_LAST; ++i)
	{
		e = get_weaponinfo(i);
		if(WEPSET_CONTAINS_AW(start_weapons, i) || WEPSET_CONTAINS_AW(warmup_start_weapons, i))
			weapon_action(i, WR_PRECACHE);
	}

	start_ammo_shells = max(0, start_ammo_shells);
	start_ammo_nails = max(0, start_ammo_nails);
	start_ammo_cells = max(0, start_ammo_cells);
	start_ammo_rockets = max(0, start_ammo_rockets);
	start_ammo_fuel = max(0, start_ammo_fuel);

	warmup_start_ammo_shells = max(0, warmup_start_ammo_shells);
	warmup_start_ammo_nails = max(0, warmup_start_ammo_nails);
	warmup_start_ammo_cells = max(0, warmup_start_ammo_cells);
	warmup_start_ammo_rockets = max(0, warmup_start_ammo_rockets);
	warmup_start_ammo_fuel = max(0, warmup_start_ammo_fuel);
}

float g_bugrigs;
float g_bugrigs_planar_movement;
float g_bugrigs_planar_movement_car_jumping;
float g_bugrigs_reverse_spinning;
float g_bugrigs_reverse_speeding;
float g_bugrigs_reverse_stopping;
float g_bugrigs_air_steering;
float g_bugrigs_angle_smoothing;
float g_bugrigs_friction_floor;
float g_bugrigs_friction_brake;
float g_bugrigs_friction_air;
float g_bugrigs_accel;
float g_bugrigs_speed_ref;
float g_bugrigs_speed_pow;
float g_bugrigs_steer;

float sv_autotaunt;
float sv_taunt;

string GetGametype(); // g_world.qc
void readlevelcvars(void)
{
	// load mutators
	#define CHECK_MUTATOR_ADD(mut_cvar,mut_name,dependence) \
		{ if(cvar(mut_cvar) && dependence) { MUTATOR_ADD(mut_name); } }
		
	CHECK_MUTATOR_ADD("g_dodging", mutator_dodging, 1);
	CHECK_MUTATOR_ADD("g_spawn_near_teammate", mutator_spawn_near_teammate, 1);
	CHECK_MUTATOR_ADD("g_physical_items", mutator_physical_items, 1);
	CHECK_MUTATOR_ADD("g_touchexplode", mutator_touchexplode, 1);
	CHECK_MUTATOR_ADD("g_minstagib", mutator_minstagib, 1);
	CHECK_MUTATOR_ADD("g_invincible_projectiles", mutator_invincibleprojectiles, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_new_toys", mutator_new_toys, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_nix", mutator_nix, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_rocket_flying", mutator_rocketflying, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_vampire", mutator_vampire, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_superspectate", mutator_superspec, 1);
	CHECK_MUTATOR_ADD("g_overkill", mutator_overkill, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_freeze", mutator_freeze, !g_freezetag);
	CHECK_MUTATOR_ADD("g_pinata", mutator_pinata, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_midair", mutator_midair, 1);
	CHECK_MUTATOR_ADD("g_bloodloss", mutator_bloodloss, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_random_gravity", mutator_random_gravity, 1);
	CHECK_MUTATOR_ADD("g_norecoil", mutator_norecoil, 1);
	CHECK_MUTATOR_ADD("g_multijump", mutator_multijump, 1);
	CHECK_MUTATOR_ADD("g_jump_grunt", mutator_jump_grunt, 1);
	CHECK_MUTATOR_ADD("g_footsteps", mutator_footsteps, 1);
	CHECK_MUTATOR_ADD("g_melee_only", mutator_melee_only, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_nades", mutator_nades, 1);
	CHECK_MUTATOR_ADD("g_sandbox", sandbox, 1);
	CHECK_MUTATOR_ADD("g_riflearena", mutator_riflearena, !cvar("g_minstagib"));
	CHECK_MUTATOR_ADD("g_campcheck", mutator_campcheck, 1);
	CHECK_MUTATOR_ADD("g_hats", mutator_hats, 1);
	
	#undef CHECK_MUTATOR_ADD
	
	if(cvar("sv_allow_fullbright"))
		serverflags |= SERVERFLAG_ALLOW_FULLBRIGHT;

    g_bugrigs = cvar("g_bugrigs");
    g_bugrigs_planar_movement = cvar("g_bugrigs_planar_movement");
    g_bugrigs_planar_movement_car_jumping = cvar("g_bugrigs_planar_movement_car_jumping");
    g_bugrigs_reverse_spinning = cvar("g_bugrigs_reverse_spinning");
    g_bugrigs_reverse_speeding = cvar("g_bugrigs_reverse_speeding");
    g_bugrigs_reverse_stopping = cvar("g_bugrigs_reverse_stopping");
    g_bugrigs_air_steering = cvar("g_bugrigs_air_steering");
    g_bugrigs_angle_smoothing = cvar("g_bugrigs_angle_smoothing");
    g_bugrigs_friction_floor = cvar("g_bugrigs_friction_floor");
    g_bugrigs_friction_brake = cvar("g_bugrigs_friction_brake");
    g_bugrigs_friction_air = cvar("g_bugrigs_friction_air");
    g_bugrigs_accel = cvar("g_bugrigs_accel");
    g_bugrigs_speed_ref = cvar("g_bugrigs_speed_ref");
    g_bugrigs_speed_pow = cvar("g_bugrigs_speed_pow");
    g_bugrigs_steer = cvar("g_bugrigs_steer");
	
	monster_skill = cvar("g_monsters_skill");
	
	g_minstagib = cvar("g_minstagib");
	
	sv_showfps = cvar("sv_showfps");

	sv_clones = cvar("sv_clones");
	sv_foginterval = cvar("sv_foginterval");
	g_cloaked = cvar("g_cloaked");
    if(g_cts)
        g_cloaked = 1; // always enable cloak in CTS
	g_grappling_hook = cvar("g_grappling_hook");
	g_jetpack = cvar("g_jetpack");
	sv_maxidle = cvar("sv_maxidle");
	sv_maxidle_spectatorsareidle = cvar("sv_maxidle_spectatorsareidle");
	sv_autotaunt = cvar("sv_autotaunt");
	sv_taunt = cvar("sv_taunt");

	inWarmupStage = cvar("g_warmup");
	g_warmup_limit = cvar("g_warmup_limit");
	g_warmup_allguns = cvar("g_warmup_allguns");
	g_warmup_allow_timeout = cvar("g_warmup_allow_timeout");

	if ((g_race && g_race_qualifying == 2) || g_arena || g_assault || cvar("g_campaign"))
		inWarmupStage = 0; // these modes cannot work together, sorry

	g_pickup_respawntime_weapon = cvar("g_pickup_respawntime_weapon");
	g_pickup_respawntime_superweapon = cvar("g_pickup_respawntime_superweapon");
	g_pickup_respawntime_ammo = cvar("g_pickup_respawntime_ammo");
	g_pickup_respawntime_short = cvar("g_pickup_respawntime_short");
	g_pickup_respawntime_medium = cvar("g_pickup_respawntime_medium");
	g_pickup_respawntime_long = cvar("g_pickup_respawntime_long");
	g_pickup_respawntime_powerup = cvar("g_pickup_respawntime_powerup");
	g_pickup_respawntimejitter_weapon = cvar("g_pickup_respawntimejitter_weapon");
	g_pickup_respawntimejitter_superweapon = cvar("g_pickup_respawntimejitter_superweapon");
	g_pickup_respawntimejitter_ammo = cvar("g_pickup_respawntimejitter_ammo");
	g_pickup_respawntimejitter_short = cvar("g_pickup_respawntimejitter_short");
	g_pickup_respawntimejitter_medium = cvar("g_pickup_respawntimejitter_medium");
	g_pickup_respawntimejitter_long = cvar("g_pickup_respawntimejitter_long");
	g_pickup_respawntimejitter_powerup = cvar("g_pickup_respawntimejitter_powerup");

	g_weaponspeedfactor = cvar("g_weaponspeedfactor");
	g_weaponratefactor = cvar("g_weaponratefactor");
	g_weapondamagefactor = cvar("g_weapondamagefactor");
	g_weaponforcefactor = cvar("g_weaponforcefactor");
	g_weaponspreadfactor = cvar("g_weaponspreadfactor");

	g_pickup_shells = cvar("g_pickup_shells");
	g_pickup_shells_max = cvar("g_pickup_shells_max");
	g_pickup_nails = cvar("g_pickup_nails");
	g_pickup_nails_max = cvar("g_pickup_nails_max");
	g_pickup_rockets = cvar("g_pickup_rockets");
	g_pickup_rockets_max = cvar("g_pickup_rockets_max");
	g_pickup_cells = cvar("g_pickup_cells");
	g_pickup_cells_max = cvar("g_pickup_cells_max");
	g_pickup_fuel = cvar("g_pickup_fuel");
	g_pickup_fuel_jetpack = cvar("g_pickup_fuel_jetpack");
	g_pickup_fuel_max = cvar("g_pickup_fuel_max");
	g_pickup_armorsmall = cvar("g_pickup_armorsmall");
	g_pickup_armorsmall_max = cvar("g_pickup_armorsmall_max");
	g_pickup_armorsmall_anyway = cvar("g_pickup_armorsmall_anyway");
	g_pickup_armormedium = cvar("g_pickup_armormedium");
	g_pickup_armormedium_max = cvar("g_pickup_armormedium_max");
	g_pickup_armormedium_anyway = cvar("g_pickup_armormedium_anyway");
	g_pickup_armorbig = cvar("g_pickup_armorbig");
	g_pickup_armorbig_max = cvar("g_pickup_armorbig_max");
	g_pickup_armorbig_anyway = cvar("g_pickup_armorbig_anyway");
	g_pickup_armorlarge = cvar("g_pickup_armorlarge");
	g_pickup_armorlarge_max = cvar("g_pickup_armorlarge_max");
	g_pickup_armorlarge_anyway = cvar("g_pickup_armorlarge_anyway");
	g_pickup_healthsmall = cvar("g_pickup_healthsmall");
	g_pickup_healthsmall_max = cvar("g_pickup_healthsmall_max");
	g_pickup_healthsmall_anyway = cvar("g_pickup_healthsmall_anyway");
	g_pickup_healthmedium = cvar("g_pickup_healthmedium");
	g_pickup_healthmedium_max = cvar("g_pickup_healthmedium_max");
	g_pickup_healthmedium_anyway = cvar("g_pickup_healthmedium_anyway");
	g_pickup_healthlarge = cvar("g_pickup_healthlarge");
	g_pickup_healthlarge_max = cvar("g_pickup_healthlarge_max");
	g_pickup_healthlarge_anyway = cvar("g_pickup_healthlarge_anyway");
	g_pickup_healthmega = cvar("g_pickup_healthmega");
	g_pickup_healthmega_max = cvar("g_pickup_healthmega_max");
	g_pickup_healthmega_anyway = cvar("g_pickup_healthmega_anyway");

	g_pickup_ammo_anyway = cvar("g_pickup_ammo_anyway");
	g_pickup_weapons_anyway = cvar("g_pickup_weapons_anyway");

    g_weapon_stay = cvar(strcat("g_", GetGametype(), "_weapon_stay"));
    if(!g_weapon_stay)
        g_weapon_stay = cvar("g_weapon_stay");

	if not(inWarmupStage)
		game_starttime = time + cvar("g_start_delay");

	readplayerstartcvars();
}

//#NO AUTOCVARS END

// Sound functions
string precache_sound (string s) = #19;
float precache_sound_index (string s) = #19;

#define SND_VOLUME      1
#define SND_ATTENUATION 2
#define SND_LARGEENTITY 8
#define SND_LARGESOUND  16

float sound_allowed(float dest, entity e)
{
    // sounds from world may always pass
    for (;;)
    {
        if (e.classname == "body")
            e = e.enemy;
	else if (e.realowner && e.realowner != e)
            e = e.realowner;
	else if (e.owner && e.owner != e)
            e = e.owner;
        else
            break;
    }
    // sounds to self may always pass
    if (dest == MSG_ONE)
        if (e == msg_entity)
            return TRUE;
    // sounds by players can be removed
    if (autocvar_bot_sound_monopoly)
        if (IS_REAL_CLIENT(e))
            return FALSE;
    // anything else may pass
    return TRUE;
}

#ifdef COMPAT_XON010_CHANNELS
void(entity e, float chan, string samp, float vol, float atten) builtin_sound = #8;
void sound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;
    builtin_sound(e, chan, samp, vol, atten);
}
#else
#undef sound
void sound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;
    sound7(e, chan, samp, vol, atten, 0, 0);
}
#endif

void soundtoat(float dest, entity e, vector o, float chan, string samp, float vol, float atten)
{
    float entno, idx;

    if (!sound_allowed(dest, e))
        return;

    entno = num_for_edict(e);
    idx = precache_sound_index(samp);

    float sflags;
    sflags = 0;

    atten = floor(atten * 64);
    vol = floor(vol * 255);

    if (vol != 255)
        sflags |= SND_VOLUME;
    if (atten != 64)
        sflags |= SND_ATTENUATION;
    if (entno >= 8192 || chan < 0 || chan > 7)
        sflags |= SND_LARGEENTITY;
    if (idx >= 256)
        sflags |= SND_LARGESOUND;

    WriteByte(dest, SVC_SOUND);
    WriteByte(dest, sflags);
    if (sflags & SND_VOLUME)
        WriteByte(dest, vol);
    if (sflags & SND_ATTENUATION)
        WriteByte(dest, atten);
    if (sflags & SND_LARGEENTITY)
    {
        WriteShort(dest, entno);
        WriteByte(dest, chan);
    }
    else
    {
        WriteShort(dest, entno * 8 + chan);
    }
    if (sflags & SND_LARGESOUND)
        WriteShort(dest, idx);
    else
        WriteByte(dest, idx);

    WriteCoord(dest, o_x);
    WriteCoord(dest, o_y);
    WriteCoord(dest, o_z);
}
void soundto(float dest, entity e, float chan, string samp, float vol, float atten)
{
    vector o;

    if (!sound_allowed(dest, e))
        return;

    o = e.origin + 0.5 * (e.mins + e.maxs);
    soundtoat(dest, e, o, chan, samp, vol, atten);
}
void soundat(entity e, vector o, float chan, string samp, float vol, float atten)
{
    soundtoat(((chan & 8) ? MSG_ALL : MSG_BROADCAST), e, o, chan, samp, vol, atten);
}
void stopsoundto(float dest, entity e, float chan)
{
    float entno;

    if (!sound_allowed(dest, e))
        return;

    entno = num_for_edict(e);

    if (entno >= 8192 || chan < 0 || chan > 7)
    {
        float idx, sflags;
        idx = precache_sound_index("misc/null.wav");
        sflags = SND_LARGEENTITY;
        if (idx >= 256)
            sflags |= SND_LARGESOUND;
        WriteByte(dest, SVC_SOUND);
        WriteByte(dest, sflags);
        WriteShort(dest, entno);
        WriteByte(dest, chan);
        if (sflags & SND_LARGESOUND)
            WriteShort(dest, idx);
        else
            WriteByte(dest, idx);
        WriteCoord(dest, e.origin_x);
        WriteCoord(dest, e.origin_y);
        WriteCoord(dest, e.origin_z);
    }
    else
    {
        WriteByte(dest, SVC_STOPSOUND);
        WriteShort(dest, entno * 8 + chan);
    }
}
void stopsound(entity e, float chan)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;

    stopsoundto(MSG_BROADCAST, e, chan); // unreliable, gets there fast
    stopsoundto(MSG_ALL, e, chan); // in case of packet loss
}

void play2(entity e, string filename)
{
    //stuffcmd(e, strcat("play2 ", filename, "\n"));
    msg_entity = e;
    soundtoat(MSG_ONE, world, '0 0 0', CH_INFO, filename, VOL_BASE, ATTN_NONE);
}

// use this one if you might be causing spam (e.g. from touch functions that might get called more than once per frame)
.float spamtime;
float spamsound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return FALSE;

    if (time > e.spamtime)
    {
        e.spamtime = time;
        sound(e, chan, samp, vol, atten);
        return TRUE;
    }
    return FALSE;
}

void play2team(float t, string filename)
{
    entity head;

    if (autocvar_bot_sound_monopoly)
        return;

    FOR_EACH_REALPLAYER(head)
    {
        if (head.team == t)
            play2(head, filename);
    }
}

void play2all(string samp)
{
    if (autocvar_bot_sound_monopoly)
        return;

    sound(world, CH_INFO, samp, VOL_BASE, ATTN_NONE);
}

void PrecachePlayerSounds(string f);
void precache_playermodel(string m)
{
	float globhandle, i, n;
	string f;

	if(substring(m, -9,5) == "_lod1")
		return;
	if(substring(m, -9,5) == "_lod2")
		return;
	precache_model(m);
	f = strcat(substring(m, 0, -5), "_lod1", substring(m, -4, -1));
	if(fexists(f))
		precache_model(f);
	f = strcat(substring(m, 0, -5), "_lod2", substring(m, -4, -1));
	if(fexists(f))
		precache_model(f);

	globhandle = search_begin(strcat(m, "_*.sounds"), TRUE, FALSE);
	if (globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for (i = 0; i < n; ++i)
	{
		//print(search_getfilename(globhandle, i), "\n");
		f = search_getfilename(globhandle, i);
		PrecachePlayerSounds(f);
	}
	search_end(globhandle);
}
void precache_all_playermodels(string pattern)
{
	float globhandle, i, n;
	string f;

	globhandle = search_begin(pattern, TRUE, FALSE);
	if (globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for (i = 0; i < n; ++i)
	{
		//print(search_getfilename(globhandle, i), "\n");
		f = search_getfilename(globhandle, i);
		precache_playermodel(f);
	}
	search_end(globhandle);
}

void precache()
{
    // gamemode related things
    precache_model ("models/misc/chatbubble.spr");

#ifdef TTURRETS_ENABLED
    if (autocvar_g_turrets)
        turrets_precash();
#endif

    // Precache all player models if desired
    if (autocvar_sv_precacheplayermodels)
    {
        PrecachePlayerSounds("sound/player/default.sounds");
        precache_all_playermodels("models/player/*.zym");
        precache_all_playermodels("models/player/*.dpm");
        precache_all_playermodels("models/player/*.md3");
        precache_all_playermodels("models/player/*.psk");
        precache_all_playermodels("models/player/*.iqm");
        precache_all_playermodels("models/ok_player/*.dpm");
    }

    if (autocvar_sv_defaultcharacter)
    {
        string s;
        s = autocvar_sv_defaultplayermodel_red;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel_blue;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel_yellow;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel_pink;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel;
        if (s != "")
            precache_playermodel(s);
    }
	
	if(autocvar_sv_allow_customplayermodels)
	{
		precache_playermodel("models/player/pony.iqm");
		precache_playermodel("models/player/mario.dpm");
		precache_playermodel("models/player/abyss.zym");
	}

    // gore and miscellaneous sounds
    //precache_sound ("misc/h2ohit.wav");
    precache_model ("models/hook.md3");
    precache_sound ("misc/armorimpact.wav");
    precache_sound ("misc/bodyimpact1.wav");
    precache_sound ("misc/bodyimpact2.wav");
    precache_sound ("misc/gib.wav");
    precache_sound ("misc/gib_splat01.wav");
    precache_sound ("misc/gib_splat02.wav");
    precache_sound ("misc/gib_splat03.wav");
    precache_sound ("misc/gib_splat04.wav");
    PrecacheGlobalSound((globalsound_fall = "misc/hitground 4"));
    PrecacheGlobalSound((globalsound_metalfall = "misc/metalhitground 4"));
    precache_sound ("misc/null.wav");
    precache_sound ("misc/spawn.wav");
    precache_sound ("misc/talk.wav");
    precache_sound ("misc/teleport.wav");
    precache_sound ("misc/poweroff.wav");
    precache_sound ("player/lava.wav");
    precache_sound ("player/slime.wav");

    precache_model ("models/sprites/0.spr32");
    precache_model ("models/sprites/1.spr32");
    precache_model ("models/sprites/2.spr32");
    precache_model ("models/sprites/3.spr32");
    precache_model ("models/sprites/4.spr32");
    precache_model ("models/sprites/5.spr32");
    precache_model ("models/sprites/6.spr32");
    precache_model ("models/sprites/7.spr32");
    precache_model ("models/sprites/8.spr32");
    precache_model ("models/sprites/9.spr32");
    precache_model ("models/sprites/10.spr32");

    // common weapon precaches
	precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound here
    precache_sound ("weapons/weapon_switch.wav");
    precache_sound ("weapons/weaponpickup.wav");
    precache_sound ("weapons/unavailable.wav");
    precache_sound ("weapons/dryfire.wav");
    if (g_grappling_hook)
    {
        precache_sound ("weapons/hook_fire.wav"); // hook
        precache_sound ("weapons/hook_impact.wav"); // hook
    }

    if(autocvar_sv_precacheweapons)
    {
        //precache weapon models/sounds
        float wep;
        wep = WEP_FIRST;
        while (wep <= WEP_LAST)
        {
            weapon_action(wep, WR_PRECACHE);
            wep = wep + 1;
        }
    }

    precache_model("models/elaser.mdl");
    precache_model("models/laser.mdl");
    precache_model("models/ebomb.mdl");

#if 0
    // Disabled this code because it simply does not work (e.g. ignores bgmvolume, overlaps with "cd loop" controlled tracks).

    if (!self.noise && self.music) // quake 3 uses the music field
        self.noise = self.music;

    // plays music for the level if there is any
    if (self.noise)
    {
        precache_sound (self.noise);
        ambientsound ('0 0 0', self.noise, VOL_BASE, ATTN_NONE);
    }
#endif
}

// WARNING: this kills the trace globals
#define EXACTTRIGGER_TOUCH if(WarpZoneLib_ExactTrigger_Touch()) return
#define EXACTTRIGGER_INIT  WarpZoneLib_ExactTrigger_Init()

#define INITPRIO_FIRST              0
#define INITPRIO_GAMETYPE           0
#define INITPRIO_GAMETYPE_FALLBACK  1
#define INITPRIO_FINDTARGET        10
#define INITPRIO_DROPTOFLOOR       20
#define INITPRIO_SETLOCATION       90
#define INITPRIO_LINKDOORS         91
#define INITPRIO_LAST              99

.void(void) initialize_entity;
.float initialize_entity_order;
.entity initialize_entity_next;
entity initialize_entity_first;

void make_safe_for_remove(entity e)
{
    if (e.initialize_entity)
    {
        entity ent, prev = world;
        for (ent = initialize_entity_first; ent; )
        {
            if ((ent == e) || ((ent.classname == "initialize_entity") && (ent.enemy == e)))
            {
                //print("make_safe_for_remove: getting rid of initializer ", etos(ent), "\n");
                // skip it in linked list
                if (prev)
                {
                    prev.initialize_entity_next = ent.initialize_entity_next;
                    ent = prev.initialize_entity_next;
                }
                else
                {
                    initialize_entity_first = ent.initialize_entity_next;
                    ent = initialize_entity_first;
                }
            }
            else
            {
                prev = ent;
                ent = ent.initialize_entity_next;
            }
        }
    }
}

void objerror(string s)
{
    make_safe_for_remove(self);
    builtin_objerror(s);
}

.float remove_except_protected_forbidden;
void remove_except_protected(entity e)
{
	if(e.remove_except_protected_forbidden)
		error("not allowed to remove this at this point");
	builtin_remove(e);
}

void remove_unsafely(entity e)
{
    if(e.classname == "spike")
        error("Removing spikes is forbidden (crylink bug), please report");
    builtin_remove(e);
}

void remove_safely(entity e)
{
    make_safe_for_remove(e);
    builtin_remove(e);
}

void InitializeEntity(entity e, void(void) func, float order)
{
    entity prev, cur;

    if (!e || e.initialize_entity)
    {
        // make a proxy initializer entity
        entity e_old;
        e_old = e;
        e = spawn();
        e.classname = "initialize_entity";
        e.enemy = e_old;
    }

    e.initialize_entity = func;
    e.initialize_entity_order = order;

    cur = initialize_entity_first;
    prev = world;
    for (;;)
    {
        if (!cur || cur.initialize_entity_order > order)
        {
            // insert between prev and cur
            if (prev)
                prev.initialize_entity_next = e;
            else
                initialize_entity_first = e;
            e.initialize_entity_next = cur;
            return;
        }
        prev = cur;
        cur = cur.initialize_entity_next;
    }
}
void InitializeEntitiesRun()
{
    entity startoflist;
    startoflist = initialize_entity_first;
    initialize_entity_first = world;
    remove = remove_except_protected;
    for (self = startoflist; self; self = self.initialize_entity_next)
    {
	self.remove_except_protected_forbidden = 1;
    }
    for (self = startoflist; self; )
    {
        entity e;
        var void(void) func;
        e = self.initialize_entity_next;
        func = self.initialize_entity;
        self.initialize_entity_order = 0;
        self.initialize_entity = func_null;
        self.initialize_entity_next = world;
	self.remove_except_protected_forbidden = 0;
        if (self.classname == "initialize_entity")
        {
            entity e_old;
            e_old = self.enemy;
            builtin_remove(self);
            self = e_old;
        }
        //dprint("Delayed initialization: ", self.classname, "\n");
        if(func)
            func();
        else
        {
            eprint(self);
            backtrace(strcat("Null function in: ", self.classname, "\n"));
        }
        self = e;
    }
    remove = remove_unsafely;
}

.float uncustomizeentityforclient_set;
.void(void) uncustomizeentityforclient;
void UncustomizeEntitiesRun()
{
    entity oldself;
    oldself = self;
    for (self = world; (self = findfloat(self, uncustomizeentityforclient_set, 1)); )
        self.uncustomizeentityforclient();
    self = oldself;
}
void SetCustomizer(entity e, float(void) customizer, void(void) uncustomizer)
{
    e.customizeentityforclient = customizer;
    e.uncustomizeentityforclient = uncustomizer;
    e.uncustomizeentityforclient_set = !!uncustomizer;
}

.float nottargeted;
#define IFTARGETED if(!self.nottargeted && self.targetname != "")

void() SUB_Remove;
void Net_LinkEntity(entity e, float docull, float dt, float(entity, float) sendfunc)
{
    vector mi, ma;

    if (e.classname == "")
        e.classname = "net_linked";

    if (e.model == "" || self.modelindex == 0)
    {
        mi = e.mins;
        ma = e.maxs;
        setmodel(e, "null");
        setsize(e, mi, ma);
    }

    e.SendEntity = sendfunc;
    e.SendFlags = 0xFFFFFF;

    if (!docull)
        e.effects |= EF_NODEPTHTEST;

    if (dt)
    {
        e.nextthink = time + dt;
        e.think = SUB_Remove;
    }
}

void adaptor_think2touch()
{
    entity o;
    o = other;
    other = world;
    self.touch();
    other = o;
}

void adaptor_think2use()
{
    entity o, a;
    o = other;
    a = activator;
    activator = world;
    other = world;
    self.use();
    other = o;
    activator = a;
}

void adaptor_think2use_hittype_splash() // for timed projectile detonation
{
	if not(self.flags & FL_ONGROUND) // if onground, we ARE touching something, but HITTYPE_SPLASH is to be networked if the damage causing projectile is not touching ANYTHING
		self.projectiledeathtype |= HITTYPE_SPLASH;
	adaptor_think2use();
}

// deferred dropping
void DropToFloor_Handler()
{
    builtin_droptofloor();
    self.dropped_origin = self.origin;
}

void droptofloor()
{
    InitializeEntity(self, DropToFloor_Handler, INITPRIO_DROPTOFLOOR);
}



float trace_hits_box_a0, trace_hits_box_a1;

float trace_hits_box_1d(float end, float thmi, float thma)
{
    if (end == 0)
    {
        // just check if x is in range
        if (0 < thmi)
            return FALSE;
        if (0 > thma)
            return FALSE;
    }
    else
    {
        // do the trace with respect to x
        // 0 -> end has to stay in thmi -> thma
        trace_hits_box_a0 = max(trace_hits_box_a0, min(thmi / end, thma / end));
        trace_hits_box_a1 = min(trace_hits_box_a1, max(thmi / end, thma / end));
        if (trace_hits_box_a0 > trace_hits_box_a1)
            return FALSE;
    }
    return TRUE;
}

float trace_hits_box(vector start, vector end, vector thmi, vector thma)
{
    end -= start;
    thmi -= start;
    thma -= start;
    // now it is a trace from 0 to end

    trace_hits_box_a0 = 0;
    trace_hits_box_a1 = 1;

    if (!trace_hits_box_1d(end_x, thmi_x, thma_x))
        return FALSE;
    if (!trace_hits_box_1d(end_y, thmi_y, thma_y))
        return FALSE;
    if (!trace_hits_box_1d(end_z, thmi_z, thma_z))
        return FALSE;

    return TRUE;
}

float tracebox_hits_box(vector start, vector mi, vector ma, vector end, vector thmi, vector thma)
{
    return trace_hits_box(start, end, thmi - ma, thma - mi);
}

float SUB_NoImpactCheck()
{
	// zero hitcontents = this is not the real impact, but either the
	// mirror-impact of something hitting the projectile instead of the
	// projectile hitting the something, or a touchareagrid one. Neither of
	// these stop the projectile from moving, so...
	if(trace_dphitcontents == 0)
	{
		//dprint("A hit happened with zero hit contents... DEBUG THIS, this should never happen for projectiles! Projectile will self-destruct.\n");
		dprint(sprintf(_("A hit from a projectile happened with no hit contents! DEBUG THIS, this should never happen for projectiles! Profectile will self-destruct. (edict: %d, classname: %s, origin: %s)\n"), num_for_edict(self), self.classname, vtos(self.origin)));
		checkclient();
	}
    if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
        return 1;
    if (other == world && self.size != '0 0 0')
    {
        vector tic;
        tic = self.velocity * sys_frametime;
        tic = tic + normalize(tic) * vlen(self.maxs - self.mins);
        traceline(self.origin - tic, self.origin + tic, MOVE_NORMAL, self);
        if (trace_fraction >= 1)
        {
            dprint("Odd... did not hit...?\n");
        }
        else if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
        {
            dprint("Detected and prevented the sky-grapple bug.\n");
            return 1;
        }
    }

    return 0;
}

#define SUB_OwnerCheck() (other && (other == self.owner))

void RemoveGrapplingHook(entity pl);
void W_Crylink_Dequeue(entity e);
float WarpZone_Projectile_Touch_ImpactFilter_Callback()
{
	if(SUB_OwnerCheck())
		return TRUE;
	if(SUB_NoImpactCheck())
	{
		if(self.classname == "grapplinghook")
			RemoveGrapplingHook(self.realowner);
		else if(self.classname == "spike")
		{
			W_Crylink_Dequeue(self);
			remove(self);
		}
		else
			remove(self);
		return TRUE;
	}
	if(trace_ent && trace_ent.solid > SOLID_TRIGGER)
		UpdateCSQCProjectile(self);
	return FALSE;
}
#define PROJECTILE_TOUCH if(WarpZone_Projectile_Touch()) return

#define ITEM_TOUCH_NEEDKILL() (((trace_dpstartcontents | trace_dphitcontents) & DPCONTENTS_NODROP) || (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY))
#define ITEM_DAMAGE_NEEDKILL(dt) (((dt) == DEATH_HURTTRIGGER) || ((dt) == DEATH_SLIME) || ((dt) == DEATH_LAVA) || ((dt) == DEATH_SWAMP))

void URI_Get_Callback(float id, float status, string data)
{
	if(url_URI_Get_Callback(id, status, data))
	{
		// handled
	}
	else if (id == URI_GET_DISCARD)
	{
		// discard
	}
	else if (id >= URI_GET_CURL && id <= URI_GET_CURL_END)
	{
		// sv_cmd curl
		Curl_URI_Get_Callback(id, status, data);
	}
	else if (id >= URI_GET_IPBAN && id <= URI_GET_IPBAN_END)
	{
		// online ban list
		OnlineBanList_URI_Get_Callback(id, status, data);
	}
	else
	{
		print("Received HTTP request data for an invalid id ", ftos(id), ".\n");
	}
}

string uid2name(string myuid) {
	string s;
	s = db_get(ServerProgsDB, strcat("/uid2name/", myuid));

	// FIXME remove this later after 0.6 release
	// convert old style broken records to correct style
	if(s == "")
	{
		s = db_get(ServerProgsDB, strcat("uid2name", myuid));
		if(s != "")
		{
			db_put(ServerProgsDB, strcat("/uid2name/", myuid), s);
			db_put(ServerProgsDB, strcat("uid2name", myuid), "");
		}
	}
	
	if(s == "")
		s = "^1Unregistered Player";
	return s;
}

float race_readTime(string map, float pos)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	return stof(db_get(ServerProgsDB, strcat(map, rr, "time", ftos(pos))));
}

string race_readUID(string map, float pos)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	return db_get(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(pos)));
}

float race_readPos(string map, float t) {
	float i;
	for (i = 1; i <= RANKINGS_CNT; ++i)
		if (race_readTime(map, i) == 0 || race_readTime(map, i) > t)
			return i;

	return 0; // pos is zero if unranked
}

void race_writeTime(string map, float t, string myuid)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	float newpos;
	newpos = race_readPos(map, t);

	float i, prevpos = 0;
	for(i = 1; i <= RANKINGS_CNT; ++i)
	{
		if(race_readUID(map, i) == myuid)
			prevpos = i;
	}
	if (prevpos) { // player improved his existing record, only have to iterate on ranks between new and old recs
		for (i = prevpos; i > newpos; --i) {
			db_put(ServerProgsDB, strcat(map, rr, "time", ftos(i)), ftos(race_readTime(map, i - 1)));
			db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(i)), race_readUID(map, i - 1));
		}
	} else { // player has no ranked record yet
		for (i = RANKINGS_CNT; i > newpos; --i) {
			db_put(ServerProgsDB, strcat(map, rr, "time", ftos(i)), ftos(race_readTime(map, i - 1)));
			db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(i)), race_readUID(map, i - 1));
		}
	}

	// store new time itself
	db_put(ServerProgsDB, strcat(map, rr, "time", ftos(newpos)), ftos(t));
	db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(newpos)), myuid);
}

string race_readName(string map, float pos)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	return uid2name(db_get(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(pos))));
}

float MoveToRandomMapLocation(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance)
{
    float m, i;
    vector start, org, delta, end, enddown, mstart;
    entity sp;

    m = e.dphitcontentsmask;
    e.dphitcontentsmask = goodcontents | badcontents;

    org = world.mins;
    delta = world.maxs - world.mins;

    start = end = org;

    for (i = 0; i < attempts; ++i)
    {
        start_x = org_x + random() * delta_x;
        start_y = org_y + random() * delta_y;
        start_z = org_z + random() * delta_z;

        // rule 1: start inside world bounds, and outside
        // solid, and don't start from somewhere where you can
        // fall down to evil
        tracebox(start, e.mins, e.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        if (trace_startsolid)
            continue;
        if (trace_dphitcontents & badcontents)
            continue;
        if (trace_dphitq3surfaceflags & badsurfaceflags)
            continue;

        // rule 2: if we are too high, lower the point
        if (trace_fraction * delta_z > maxaboveground)
            start = trace_endpos + '0 0 1' * maxaboveground;
        enddown = trace_endpos;

        // rule 3: make sure we aren't outside the map. This only works
        // for somewhat well formed maps. A good rule of thumb is that
        // the map should have a convex outside hull.
        // these can be traceLINES as we already verified the starting box
        mstart = start + 0.5 * (e.mins + e.maxs);
        traceline(mstart, mstart + '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;

	// rule 4: we must "see" some spawnpoint
	for(sp = world; (sp = find(sp, classname, "info_player_deathmatch")); )
		if(checkpvs(mstart, sp))
			break;
	if(!sp)
	{
		for(sp = world; (sp = findflags(sp, flags, FL_ITEM)); )
			if(checkpvs(mstart, sp))
				break;
		if(!sp)
			continue;
	}

        // find a random vector to "look at"
        end_x = org_x + random() * delta_x;
        end_y = org_y + random() * delta_y;
        end_z = org_z + random() * delta_z;
        end = start + normalize(end - start) * vlen(delta);

        // rule 4: start TO end must not be too short
        tracebox(start, e.mins, e.maxs, end, MOVE_NORMAL, e);
        if (trace_startsolid)
            continue;
        if (trace_fraction < minviewdistance / vlen(delta))
            continue;

        // rule 5: don't want to look at sky
        if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
            continue;

        // rule 6: we must not end up in trigger_hurt
        if (tracebox_hits_trigger_hurt(start, e.mins, e.maxs, enddown))
            continue;

        break;
    }

    e.dphitcontentsmask = m;

    if (i < attempts)
    {
        setorigin(e, start);
        e.angles = vectoangles(end - start);
        dprint("Needed ", ftos(i + 1), " attempts\n");
        return TRUE;
    }
    else
        return FALSE;
}

float zcurveparticles_effectno;
vector zcurveparticles_start;
float zcurveparticles_spd;

void endzcurveparticles()
{
	if(zcurveparticles_effectno)
	{
		// terminator
		WriteShort(MSG_BROADCAST, zcurveparticles_spd | 0x8000);
	}
	zcurveparticles_effectno = 0;
}

void zcurveparticles(float effectno, vector start, vector end, float end_dz, float spd)
{
	spd = bound(0, floor(spd / 16), 32767);
	if(effectno != zcurveparticles_effectno || start != zcurveparticles_start)
	{
		endzcurveparticles();
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_ZCURVEPARTICLES);
		WriteShort(MSG_BROADCAST, effectno);
		WriteCoord(MSG_BROADCAST, start_x);
		WriteCoord(MSG_BROADCAST, start_y);
		WriteCoord(MSG_BROADCAST, start_z);
		zcurveparticles_effectno = effectno;
		zcurveparticles_start = start;
	}
	else
		WriteShort(MSG_BROADCAST, zcurveparticles_spd);
	WriteCoord(MSG_BROADCAST, end_x);
	WriteCoord(MSG_BROADCAST, end_y);
	WriteCoord(MSG_BROADCAST, end_z);
	WriteCoord(MSG_BROADCAST, end_dz);
	zcurveparticles_spd = spd;
}

void zcurveparticles_from_tracetoss(float effectno, vector start, vector end, vector vel)
{
	float end_dz;
	vector vecxy, velxy;

	vecxy = end - start;
	vecxy_z = 0;
	velxy = vel;
	velxy_z = 0;

	if (vlen(velxy) < 0.000001 * fabs(vel_z))
	{
		endzcurveparticles();
		trailparticles(world, effectno, start, end);
		return;
	}

	end_dz = vlen(vecxy) / vlen(velxy) * vel_z - (end_z - start_z);
	zcurveparticles(effectno, start, end, end_dz, vlen(vel));
}

void write_recordmarker(entity pl, float tstart, float dt)
{
    GameLogEcho(strcat(":recordset:", ftos(pl.playerid), ":", ftos(dt)));

    // also write a marker into demo files for demotc-race-record-extractor to find
    stuffcmd(pl,
             strcat(
                 strcat("//", strconv(2, 0, 0, GetGametype()), " RECORD SET ", TIME_ENCODED_TOSTRING(TIME_ENCODE(dt))),
                 " ", ftos(tstart), " ", ftos(dt), "\n"));
}

vector shotorg_adjustfromclient(vector vecs, float y_is_right, float allowcenter, float algn)
{
	switch(algn)
	{
		default:
		case 3: // right
			break;

		case 4: // left
			vecs_y = -vecs_y;
			break;

		case 1:
			if(allowcenter) // 2: allow center handedness
			{
				// center
				vecs_y = 0;
				vecs_z -= 2;
			}
			else
			{
				// right
			}
			break;

		case 2:
			if(allowcenter) // 2: allow center handedness
			{
				// center
				vecs_y = 0;
				vecs_z -= 2;
			}
			else
			{
				// left
				vecs_y = -vecs_y;
			}
			break;
	}
	return vecs;
}

vector shotorg_adjust_values(vector vecs, float y_is_right, float visual, float algn)
{
	string s;
	vector v;

	if (autocvar_g_shootfromeye)
	{
		if (visual)
		{
			if (autocvar_g_shootfromclient) { vecs = shotorg_adjustfromclient(vecs, y_is_right, (autocvar_g_shootfromclient >= 2), algn); }
			else { vecs_y = 0; vecs_z -= 2; }
		}
		else
		{
			vecs_y = 0;
			vecs_z = 0;
		}
	}
	else if (autocvar_g_shootfromcenter)
	{
		vecs_y = 0;
		vecs_z -= 2;
	}
	else if ((s = autocvar_g_shootfromfixedorigin) != "")
	{
		v = stov(s);
		if (y_is_right)
			v_y = -v_y;
		if (v_x != 0)
			vecs_x = v_x;
		vecs_y = v_y;
		vecs_z = v_z;
	}
	else if (autocvar_g_shootfromclient)
	{
		vecs = shotorg_adjustfromclient(vecs, y_is_right, (autocvar_g_shootfromclient >= 2), algn);
	}
	return vecs;
}

vector shotorg_adjust(vector vecs, float y_is_right, float visual)
{
	return shotorg_adjust_values(vecs, y_is_right, visual, self.owner.cvar_cl_gunalign);
}


void attach_sameorigin(entity e, entity to, string tag)
{
    vector org, t_forward, t_left, t_up, e_forward, e_up;
    float tagscale;

    org = e.origin - gettaginfo(to, gettagindex(to, tag));
    tagscale = pow(vlen(v_forward), -2); // undo a scale on the tag
    t_forward = v_forward * tagscale;
    t_left = v_right * -tagscale;
    t_up = v_up * tagscale;

    e.origin_x = org * t_forward;
    e.origin_y = org * t_left;
    e.origin_z = org * t_up;

    // current forward and up directions
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_FromVAngles(e.angles);
	else
		e.angles = AnglesTransform_FromAngles(e.angles);
    fixedmakevectors(e.angles);

    // untransform forward, up!
    e_forward_x = v_forward * t_forward;
    e_forward_y = v_forward * t_left;
    e_forward_z = v_forward * t_up;
    e_up_x = v_up * t_forward;
    e_up_y = v_up * t_left;
    e_up_z = v_up * t_up;

    e.angles = fixedvectoangles2(e_forward, e_up);
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_ToVAngles(e.angles);
	else
		e.angles = AnglesTransform_ToAngles(e.angles);

    setattachment(e, to, tag);
    setorigin(e, e.origin);
}

void detach_sameorigin(entity e)
{
    vector org;
    org = gettaginfo(e, 0);
    e.angles = fixedvectoangles2(v_forward, v_up);
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_ToVAngles(e.angles);
	else
		e.angles = AnglesTransform_ToAngles(e.angles);
    setorigin(e, org);
    setattachment(e, world, "");
    setorigin(e, e.origin);
}

void follow_sameorigin(entity e, entity to)
{
    e.movetype = MOVETYPE_FOLLOW; // make the hole follow
    e.aiment = to; // make the hole follow bmodel
    e.punchangle = to.angles; // the original angles of bmodel
    e.view_ofs = e.origin - to.origin; // relative origin
    e.v_angle = e.angles - to.angles; // relative angles
}

void unfollow_sameorigin(entity e)
{
    e.movetype = MOVETYPE_NONE;
}

entity gettaginfo_relative_ent;
vector gettaginfo_relative(entity e, float tag)
{
    if (!gettaginfo_relative_ent)
    {
        gettaginfo_relative_ent = spawn();
        gettaginfo_relative_ent.effects = EF_NODRAW;
    }
    gettaginfo_relative_ent.model = e.model;
    gettaginfo_relative_ent.modelindex = e.modelindex;
    gettaginfo_relative_ent.frame = e.frame;
    return gettaginfo(gettaginfo_relative_ent, tag);
}

.float scale2;

float modeleffect_SendEntity(entity to, float sf)
{
	float f;
	WriteByte(MSG_ENTITY, ENT_CLIENT_MODELEFFECT);

	f = 0;
	if(self.velocity != '0 0 0')
		f |= 1;
	if(self.angles != '0 0 0')
		f |= 2;
	if(self.avelocity != '0 0 0')
		f |= 4;

	WriteByte(MSG_ENTITY, f);
	WriteShort(MSG_ENTITY, self.modelindex);
	WriteByte(MSG_ENTITY, self.skin);
	WriteByte(MSG_ENTITY, self.frame);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	if(f & 1)
	{
		WriteCoord(MSG_ENTITY, self.velocity_x);
		WriteCoord(MSG_ENTITY, self.velocity_y);
		WriteCoord(MSG_ENTITY, self.velocity_z);
	}
	if(f & 2)
	{
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
		WriteCoord(MSG_ENTITY, self.angles_z);
	}
	if(f & 4)
	{
		WriteCoord(MSG_ENTITY, self.avelocity_x);
		WriteCoord(MSG_ENTITY, self.avelocity_y);
		WriteCoord(MSG_ENTITY, self.avelocity_z);
	}
	WriteShort(MSG_ENTITY, self.scale * 256.0);
	WriteShort(MSG_ENTITY, self.scale2 * 256.0);
	WriteByte(MSG_ENTITY, self.teleport_time * 100.0);
	WriteByte(MSG_ENTITY, self.fade_time * 100.0);
	WriteByte(MSG_ENTITY, self.alpha * 255.0);

	return TRUE;
}

void modeleffect_spawn(string m, float s, float f, vector o, vector v, vector ang, vector angv, float s0, float s2, float a, float t1, float t2)
{
	entity e;
	float sz;
	e = spawn();
	e.classname = "modeleffect";
	setmodel(e, m);
	e.frame = f;
	setorigin(e, o);
	e.velocity = v;
	e.angles = ang;
	e.avelocity = angv;
	e.alpha = a;
	e.teleport_time = t1;
	e.fade_time = t2;
	e.skin = s;
	if(s0 >= 0)
		e.scale = s0 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale = -s0;
	if(s2 >= 0)
		e.scale2 = s2 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale2 = -s2;
	sz = max(e.scale, e.scale2);
	setsize(e, e.mins * sz, e.maxs * sz);
	Net_LinkEntity(e, FALSE, 0.1, modeleffect_SendEntity);
}

void shockwave_spawn(string m, vector org, float sz, float t1, float t2)
{
	return modeleffect_spawn(m, 0, 0, org, '0 0 0', '0 0 0', '0 0 0', 0, sz, 1, t1, t2);
}

float randombit(float bits)
{
	if not(bits & (bits-1)) // this ONLY holds for powers of two!
		return bits;

	float n, f, b, r;

	r = random();
	b = 0;
	n = 0;

	for(f = 1; f <= bits; f *= 2)
	{
		if(bits & f)
		{
			++n;
			r *= n;
			if(r <= 1)
				b = f;
			else
				r = (r - 1) / (n - 1);
		}
	}

	return b;
}

float randombits(float bits, float k, float error_return)
{
	float r;
	r = 0;
	while(k > 0 && bits != r)
	{
		r += randombit(bits - r);
		--k;
	}
	if(error_return)
		if(k > 0)
			return -1; // all
	return r;
}

void randombit_test(float bits, float iter)
{
	while(iter > 0)
	{
		print(ftos(randombit(bits)), "\n");
		--iter;
	}
}

float ExponentialFalloff(float mindist, float maxdist, float halflifedist, float d)
{
	if(halflifedist > 0)
		return pow(0.5, (bound(mindist, d, maxdist) - mindist) / halflifedist);
	else if(halflifedist < 0)
		return pow(0.5, (bound(mindist, d, maxdist) - maxdist) / halflifedist);
	else
		return 1;
}




#ifdef RELEASE
#define cvar_string_normal builtin_cvar_string
#define cvar_normal builtin_cvar
#else
string cvar_string_normal(string n)
{
	if not(cvar_type(n) & 1)
		backtrace(strcat("Attempt to access undefined cvar: ", n));
	return builtin_cvar_string(n);
}

float cvar_normal(string n)
{
	return stof(cvar_string_normal(n));
}
#endif
#define cvar_set_normal builtin_cvar_set

void defer_think()
{
    entity oself;

    oself           = self;
    self            = self.owner;
    oself.think     = SUB_Remove;
    oself.nextthink = time;

    oself.use();
}

/*
    Execute func() after time + fdelay.
    self when func is executed = self when defer is called
*/
void defer(float fdelay, void() func)
{
    entity e;

    e           = spawn();
    e.owner     = self;
    e.use       = func;
    e.think     = defer_think;
    e.nextthink = time + fdelay;
}

.string aiment_classname;
.float aiment_deadflag;
void SetMovetypeFollow(entity ent, entity e)
{
	// FIXME this may not be warpzone aware
	ent.movetype = MOVETYPE_FOLLOW; // make the hole follow
	ent.solid = SOLID_NOT; // MOVETYPE_FOLLOW is always non-solid - this means this cannot be teleported by warpzones any more! Instead, we must notice when our owner gets teleported.
	ent.aiment = e; // make the hole follow bmodel
	ent.punchangle = e.angles; // the original angles of bmodel
	ent.view_ofs = ent.origin - e.origin; // relative origin
	ent.v_angle = ent.angles - e.angles; // relative angles
	ent.aiment_classname = strzone(e.classname);
	ent.aiment_deadflag = e.deadflag;
}
void UnsetMovetypeFollow(entity ent)
{
	ent.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(ent);
	ent.aiment = world;
}
float LostMovetypeFollow(entity ent)
{
/*
	if(ent.movetype != MOVETYPE_FOLLOW)
		if(ent.aiment)
			error("???");
*/
	if(ent.aiment)
	{
		if(ent.aiment.classname != ent.aiment_classname)
			return 1;
		if(ent.aiment.deadflag != ent.aiment_deadflag)
			return 1;
	}
	return 0;
}

float isPushable(entity e)
{
	if(e.iscreature)
		return TRUE;
	if(e.pushable)
		return TRUE;
	switch(e.classname)
	{
		case "body":
		case "droppedweapon":
		case "keepawayball":
		case "nexball_basketball":
		case "nexball_football":
			return TRUE;
		case "bullet": // antilagged bullets can't hit this either
			return FALSE;
	}
	if (e.projectiledeathtype)
		return TRUE;
	return FALSE;
}
