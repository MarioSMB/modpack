void skycycle_Init(entity this);
bool skycycle_enabled;

REGISTER_MUTATOR(skycycle, cvar("g_skycycle") || (cvar("g_skycycle_suggested") && cvar("g_skycycle_allow_suggested")))
{
	MUTATOR_ONADD
	{
	 	skycycle_enabled = true;
		serverflags |= SERVERFLAG_ALLOW_FULLBRIGHT;
		InitializeEntity(NULL, skycycle_Init, INITPRIO_GAMETYPE);
	}
}

AUTOCVAR_NOREF(g_skycycle, bool, false, _("Enable day-night cycles"));
AUTOCVAR(g_skycycle_time, float, 120, "");
AUTOCVAR(g_skycycle_timebetween, float, 3, "");
AUTOCVAR(g_skycycle_intensity_realmax, float, 0.75, "");
AUTOCVAR(g_skycycle_intensity_realmin, float, 0.05, "");
AUTOCVAR(g_skycycle_intensity_max, float, 1, "");
AUTOCVAR(g_skycycle_intensity_min, float, -0.25, "");
AUTOCVAR(g_skycycle_ambient_realmax, float, 20, "");
AUTOCVAR(g_skycycle_ambient_realmin, float, 0, "");
AUTOCVAR(g_skycycle_ambient_max, float, 30, "");
AUTOCVAR(g_skycycle_ambient_min, float, -10, "");
AUTOCVAR(g_skycycle_skybox, bool, true, "");
AUTOCVAR(g_skycycle_nightsky, string, "env/amethyst7/purplenebula-cmp1/purplenebula_", "");
AUTOCVAR(g_skycycle_dusksky, string, "env/exosystem/exosystem2_", "");
AUTOCVAR(g_skycycle_daysky, string, "env/exosystem/exosystem_", "");
AUTOCVAR(g_skycycle_nightsky_max, float, 0.1, "");
AUTOCVAR(g_skycycle_dusksky_max, float, 0.2, "");
AUTOCVAR(g_skycycle_startatnight, bool, false, "");
AUTOCVAR(g_skycycle_startattime, float, 0, _("Start at specific time (percentage of time [0 to 1])"));
AUTOCVAR(g_skycycle_timelock, bool, false, _("Don't advance time"));
AUTOCVAR_NOREF(g_skycycle_suggested, bool, false, "Map suggests using skycycles");
AUTOCVAR_NOREF(g_skycycle_allow_suggested, bool, true, "Allow maps to turn on skycycle");

float skycycle_time;
float skycycle_timebetween;
float skycycle_timestart;
//float skycycle_timecurrent;
//float skycycle_timenext;
float skycycle_epoch;
float skycycle_intensity_realmax; //Max (Less than Goal if you want long days/nights)
float skycycle_intensity_realmin; //Min (More than Goal if you want long days/nights)
float skycycle_intensity_max; //Goal
float skycycle_intensity_min; //Goal
float skycycle_intensity_current;
float skycycle_ambient_realmax; //Max (Less than Goal if you want long days/nights)
float skycycle_ambient_realmin; //Min (More than Goal if you want long days/nights)
float skycycle_ambient_max; //Goal
float skycycle_ambient_min; //Goal
float skycycle_ambient_current;
float skycycle_skybox;
int skycycle_skybox_number;
string skycycle_nightsky;
string skycycle_dusksky;
string skycycle_daysky;
float skycycle_nightsky_max;
float skycycle_dusksky_max;
.float skycycle_playernextthink;

void SkyCycle_Set()
{
	skycycle_time = autocvar_g_skycycle_time;
	skycycle_timebetween = autocvar_g_skycycle_timebetween;
	skycycle_intensity_max = autocvar_g_skycycle_intensity_max;
	skycycle_intensity_min = autocvar_g_skycycle_intensity_min;
	skycycle_ambient_max = autocvar_g_skycycle_ambient_max;
	skycycle_ambient_min = autocvar_g_skycycle_ambient_min;
	skycycle_intensity_realmax = autocvar_g_skycycle_intensity_realmax;
	skycycle_intensity_realmin = autocvar_g_skycycle_intensity_realmin;
	skycycle_ambient_realmax = autocvar_g_skycycle_ambient_realmax;
	skycycle_ambient_realmin = autocvar_g_skycycle_ambient_realmin;
	skycycle_nightsky = autocvar_g_skycycle_nightsky;
	skycycle_dusksky = autocvar_g_skycycle_dusksky;
	skycycle_daysky = autocvar_g_skycycle_daysky;
	skycycle_nightsky_max = autocvar_g_skycycle_nightsky_max;
	skycycle_dusksky_max = autocvar_g_skycycle_dusksky_max;
	skycycle_skybox = autocvar_g_skycycle_skybox;
	skycycle_skybox_number = 0;

	FOREACH_CLIENT(IS_REAL_CLIENT(it), LAMBDA(it.skycycle_playernextthink = time));
}

void SkyCycle_Restart()
{
	skycycle_timestart = time;
}

void SkyCycle_Lighten()
{
	//print("Lighten\n");
	float d, m;
	m = skycycle_intensity_max - skycycle_intensity_min;
	d = 
	skycycle_intensity_min +
	(m *
	((time - skycycle_timestart) / skycycle_time));
		
	skycycle_intensity_current = d;
	
	m = skycycle_ambient_max - skycycle_ambient_min;
	d = 
	skycycle_ambient_min +
	(m *
	((time - skycycle_timestart) / skycycle_time));
		
	skycycle_ambient_current = d;
}

void SkyCycle_Darken()
{
	//print("Darken\n");
	float d,  m;
	m = skycycle_intensity_max - skycycle_intensity_min;
	d = 
	skycycle_intensity_max -
	(m *
	((time - skycycle_timestart) / skycycle_time));
	
	skycycle_intensity_current = d;
	
	m = skycycle_ambient_max - skycycle_ambient_min;
	d = 
	skycycle_ambient_max -
	(m *
	((time - skycycle_timestart) / skycycle_time));
		
	skycycle_ambient_current = d;
}

void SkyCycle_Run(entity this)
{
	//print("SkyCycle Run\n");
	if (time - skycycle_timestart > skycycle_time)
	{
		//Restart
		SkyCycle_Restart();
		if (skycycle_epoch == 1)
			skycycle_epoch = 0;
		else
			skycycle_epoch = 1;
	}
	else
	{
		if (skycycle_epoch == 1)
			SkyCycle_Lighten();
		else
			SkyCycle_Darken();
	}
	if (autocvar_g_skycycle_timelock)
		//Advance start time at same pace if timelock is set
		skycycle_timestart += skycycle_timebetween;

	this.nextthink = time + skycycle_timebetween;
}

void SkyCycle_Spawn()
{
	SkyCycle_Set();
	entity e;

	e = spawn();
	setthink(e, SkyCycle_Run);
	e.nextthink = time; //Start Right Away
	skycycle_epoch = 0;
	SkyCycle_Restart();

	//print("spawning sky cycle\n");
}

void SkyCycle_SendPlayer(entity this, float checkboxnum)
{
	//print("sending sky stuff\n");
	//print(strcat("maxintensity ", ftos(skycycle_intensity_realmax), "\n"));
	//print(strcat("maxambient", ftos(skycycle_ambient_realmax), "\n"));
	//print(strcat("intensity    ", ftos(skycycle_intensity_current), "\n"));
	//print(strcat("ambient   ", ftos(skycycle_ambient_current), "\n"));
	stuffcmd(this, strcat("cl_cmd settemp r_fakelight_intensity ", ftos(skycycle_intensity_current), "\n"));
	stuffcmd(this, strcat("cl_cmd settemp r_ambient ", ftos(skycycle_ambient_current), "\n"));
	
	if (skycycle_skybox)
	{
		if (skycycle_intensity_current < skycycle_nightsky_max)
		{
			if ((skycycle_skybox_number == 2) && (checkboxnum))
			{
				//Do nothing
			}
			else
			{
				if (checkboxnum)
				{
					//Send to all players
					FOREACH_CLIENT(IS_REAL_CLIENT(it), LAMBDA(stuffcmd(it, sprintf("loadsky %s\n", skycycle_nightsky))));
				}
				else
				{
					stuffcmd(this, strcat("loadsky ", skycycle_nightsky, "\n"));
				}
				skycycle_skybox_number = 2;
			}
		}
		else if(skycycle_intensity_current < skycycle_dusksky_max)
		{
			if((skycycle_skybox_number == 1) && (checkboxnum))
			{
				//Do nothing
			}
			else
			{
				if(checkboxnum)
				{
					//Send to all players
					FOREACH_CLIENT(IS_REAL_CLIENT(it), LAMBDA(stuffcmd(it, sprintf("loadsky %s\n", skycycle_dusksky))));	
				}
				else
				{
					stuffcmd(this, strcat("loadsky ", skycycle_dusksky, "\n"));
				}
				skycycle_skybox_number = 1;
			}
		}
		else
		{
			if((skycycle_skybox_number == 0) && (checkboxnum))
			{
				//Do nothing
			}
			else
			{
				if(checkboxnum)
				{
					//Send to all players
					FOREACH_CLIENT(IS_REAL_CLIENT(it), LAMBDA(stuffcmd(it, sprintf("loadsky %s\n", skycycle_daysky))));
				}
				else
				{
					stuffcmd(this, strcat("loadsky ", skycycle_daysky, "\n"));
				}
				skycycle_skybox_number = 0;
			}
		}
	}
}


MUTATOR_HOOKFUNCTION(skycycle, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if (skycycle_enabled)
	if (time > player.skycycle_playernextthink)
	{
		SkyCycle_SendPlayer(player, 1);
		player.skycycle_playernextthink = time + 1;
	}
}

MUTATOR_HOOKFUNCTION(skycycle, PutClientInServer)
{
	entity player = M_ARGV(0, entity);

	stuffcmd(player, "cl_cmd settemp r_fakelight 2\n");
		
	SkyCycle_SendPlayer(player, 0);
}

MUTATOR_HOOKFUNCTION(skycycle, SV_StartFrame)
{
	if(skycycle_ambient_realmin > skycycle_ambient_current)
		skycycle_ambient_current = autocvar_g_skycycle_ambient_realmin;
	
	if(skycycle_intensity_realmin > skycycle_intensity_current)
		skycycle_intensity_current = autocvar_g_skycycle_intensity_realmin;
	
	if(skycycle_ambient_realmax < skycycle_ambient_current)
		skycycle_ambient_current = autocvar_g_skycycle_ambient_realmax;
	
	if(skycycle_intensity_realmax < skycycle_intensity_current)
		skycycle_intensity_current = autocvar_g_skycycle_intensity_realmax;
}

MUTATOR_HOOKFUNCTION(skycycle, reset_map_global)
{
	SkyCycle_Restart();
}

MUTATOR_HOOKFUNCTION(skycycle, BuildMutatorsString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ":skycycle");
}

MUTATOR_HOOKFUNCTION(skycycle, BuildMutatorsPrettyString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Sky Cycle");
}

void skycycle_Init(entity this)
{
	SkyCycle_Spawn();

	if(autocvar_g_skycycle_startatnight)
		skycycle_epoch = 1;

	if(autocvar_g_skycycle_startattime)
		skycycle_timestart = time - (skycycle_time * autocvar_g_skycycle_startattime);
}
