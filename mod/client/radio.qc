AUTOCVAR_SAVE(cl_radio, bool, true, "Enable radio (random music from server)");

REGISTER_MUTATOR(radio, true);

.float radio_starttime;

void Radio_Stopper_Think(void)
{
    if(self.cnt < -2)
    {
        remove(self);
        return;
    }

    float t = gettime(GETTIME_CDTRACK);
    //print(ftos(t), "\n");

    if(self.cnt > t)
    {
        localcmd("\ncd stop\n");
        remove(self);
        return; // don't continue, we just removed this thing...
    }

    self.cnt = t;
    self.nextthink = time;
}

void Radio_Think(void)
{
	if(self.cnt < 0 || time - self.cnt > 300)
	{
		if(self.netname) { strunzone(self.netname); }
		remove(self);
		return;
	}

	if(!fexists(self.netname))
	{
		self.nextthink = time + 1;
		return;
	}

	// wtf? don't auto turn on music
	//if(autocvar_bgmvolume < 0.1)
		//cvar_clientsettemp("bgmvolume", "0.1");

	float start = ((self.flags) ? 0 : servertime - self.radio_starttime);
	localcmd(sprintf("\ncd loop %s %d\n", self.netname, start));
	strunzone(self.netname);

	if(self.flags)
	{
		// loop
		remove(self);
	}
	else
	{
		// play once - we can't just use "cd play" here becase it's apparently broken
		// instead, detect when the track starts to loop and stop it
		self.cnt = -2;
		self.think = Radio_Stopper_Think;
		self.nextthink = time + 1;
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

	if(!autocvar_cl_radio)
		return true;

	localcmd("\ncurl --pak ", url, "\n");

	entity e;
	for(e = world; (e = find(e, classname, "radio"));)
		remove(e);

	e = new(radio);
	e.netname = fname;
	e.think = Radio_Think;
	e.nextthink = time;
	e.cnt = time;
	e.flags = loop;
	e.radio_starttime = start;
	return true;
}

MUTATOR_HOOKFUNCTION(radio, Ent_Init)
{
	localcmd("\nalias radio \"cmd radio ${* ?}\"\n");

	localcmd("\ncmd radio ", ftos(autocvar_cl_radio), "\n");
}

MUTATOR_HOOKFUNCTION(radio, CSQC_ConsoleCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	if(cmd_name == "radio")
	{
		if(!stof(argv(1)))
		if(find(world, classname, "radio"))
			localcmd("\ncd pause\n");

		cvar_set("cl_radio", argv(1));
		localcmd("\ncmd radio ", ftos(autocvar_cl_radio), "\n");
		return true;
	}

	return false;
}
