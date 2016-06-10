AUTOCVAR_SAVE(cl_radio, bool, true, "Enable radio (random music from server)");

REGISTER_MUTATOR(radio, true);

.float radio_starttime;

void Radio_Stopper_Think(entity this)
{
    if(this.cnt < -2 || intermission)
    {
        remove(this);
        return;
    }

    float t = gettime(GETTIME_CDTRACK);
    //print(ftos(t), "\n");

    if(this.cnt > t)
    {
        localcmd("\ncd stop\n");
        remove(this);
        return; // don't continue, we just removed this thing...
    }

    this.cnt = t;
    this.nextthink = time;
}

void Radio_Think(entity this)
{
	if(this.cnt < 0 || time - this.cnt > 300)
	{
		if(this.netname) { strunzone(this.netname); }
		remove(this);
		return;
	}

	if(!fexists(this.netname))
	{
		this.nextthink = time + 1;
		return;
	}

	// wtf? don't auto turn on music
	//if(autocvar_bgmvolume < 0.1)
		//cvar_clientsettemp("bgmvolume", "0.1");

	float start = ((this.flags) ? 0 : servertime - this.radio_starttime);
	localcmd(sprintf("\ncd loop %s %d\n", this.netname, start));
	strunzone(this.netname);

	if(this.flags)
	{
		// loop
		remove(this);
	}
	else
	{
		// play once - we can't just use "cd play" here becase it's apparently broken
		// instead, detect when the track starts to loop and stop it
		this.cnt = -2;
		setthink(this, Radio_Stopper_Think);
		this.nextthink = time + 1;
	}
}

NET_HANDLE(TE_CSQC_RADIO, bool isNew)
{
	bool preload = ReadByte();
	string url = ReadString();

	if(preload)
	{
		if(autocvar_cl_radio)
			localcmd("\ncurl --pak ", url, "\n");
		return true;
	}

	string fname = strzone(ReadString());
	bool loop = ReadByte();
	float start = 0;
	
	if(!loop)
		start = ReadCoord();

	if(!autocvar_cl_radio || intermission)
		return true;

	localcmd("\ncurl --pak ", url, "\n");

	entity e;
	for(e = world; (e = find(e, classname, "radio"));)
		remove(e);

	e = new(radio);
	e.netname = fname;
	setthink(e, Radio_Think);
	e.nextthink = time;
	e.cnt = time;
	e.flags = loop;
	e.radio_starttime = start;
	return true;
}

MUTATOR_HOOKFUNCTION(radio, Ent_Init)
{
	localcmd("\nalias radio \"cl_cmd radio ${* ?}\"\n");

	localcmd("\ncmd radio ", ftos(autocvar_cl_radio), "\n");
}

.bool paused;
MUTATOR_HOOKFUNCTION(radio, CSQC_ConsoleCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	string cmd_name = M_ARGV(0, string);

	if(cmd_name == "radio")
	{
		if(!stof(argv(1)))
		{
			entity e = find(world, classname, "radio");

			if(e)
			{
				if(e.paused)
				{
					e.paused = false;
					localcmd("\ncd resume\n");
				}
				else
				{
					e.paused = true;
					localcmd("\ncd pause\n");
				}
			}

			return true;
		}

		string onoff = (argv(1) == "on" || argv(1) == "1") ? "1" : "0";

		cvar_set("cl_radio", onoff);
		localcmd("\ncmd radio ", cvar_string("cl_radio"), "\n");
		return true;
	}
}
