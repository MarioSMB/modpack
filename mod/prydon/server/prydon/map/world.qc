STATIC_INIT_EARLY(worldspawn)
{
	extend();
	if(mapname == "start")
	{
		changelevel("curig2"); // DEMO CHANGE
	}
	else
	{
		localcmd("host_framerate 0\n");
		lastmap = decode(serverflags, 3);

	}
	
	if(nextent(nextent(NULL)) != NULL)
		mplayer = 1;
	else
		mplayer = 0;
	if(cvar("temp1") & 1)
		netplay = 1;
	if(mplayer && !fileaccess)
		error("Multiplayer Prydon Gate now requires file access (FRIK_FILE)\n");
		
	// for future tweaking
	monsvalue = decode(serverflags, 2);
	itemvalue = decode(serverflags, 2) * 0.8 + 0.5;

	serverflags = recode(serverflags, 3, world.impulse);
	nomusic = cvar("temp1") & 2;
	secure = (cvar("temp1") & 12) / 4;

	if(!nomusic)
	{
		if(world.noise)
		{
       		precache_sound(world.noise);
       		ambientsound('-4095 -4095 -4095', world.noise, 1.00, ATTN_NONE);
			ambientsound('4095 4095 4095', world.noise, 1.00, ATTN_NONE);
       	}
       	if(world.noise2)
       	{
			precache_sound(world.noise2);
			music = world.noise2;
		}
	}

	if(!world.map)
		LightStyles_setup();
	if(lastmap != 0)
		loaddata();
	skillm = rint(cvar("skill"));
	if(skillm < 1)
		skillm = 1;
	skillm = (10 ** skillm - 1);
}
