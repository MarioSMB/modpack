// ==========================
//  Turret Config Generator
// ==========================

void T_Config_Queue_Swap(float root, float child, entity pass)
{
	string oldroot = tur_config_queue[root];
	tur_config_queue[root] = tur_config_queue[child];
	tur_config_queue[child] = oldroot;
}

float T_Config_Queue_Compare(float root, float child, entity pass)
{
	float i, r, c;

	for(i = 1; i <= 100; ++i)
	{
		r = str2chr(tur_config_queue[root], i);
		c = str2chr(tur_config_queue[child], i);
		if(r == c) { continue; }
		else if(c > r) { return -1; }
		else { return 1; }
	}
	
	return 0;
}

void Dump_Turret_Settings(void)
{
	float i, x, totalsettings = 0;
	for(i = TUR_FIRST; i <= TUR_LAST; ++i)
	{
		// step 1: clear the queue
		TUR_CONFIG_COUNT = 0;
		for(x = 0; x <= MAX_TUR_CONFIG; ++x)
			{ tur_config_queue[x] = string_null; }

		// step 2: build new queue
		TUR_ACTION(i, TR_CONFIG);

		// step 3: sort queue
		heapsort(TUR_CONFIG_COUNT, T_Config_Queue_Swap, T_Config_Queue_Compare, world);
		
		// step 4: write queue
		TUR_CONFIG_WRITETOFILE(sprintf("// {{{ #%d: %s\n", i, TUR_NAME(i)))
		for(x = 0; x <= TUR_CONFIG_COUNT; ++x)
			{ TUR_CONFIG_WRITETOFILE(tur_config_queue[x]) }
		TUR_CONFIG_WRITETOFILE("// }}}\n")

		// step 5: debug info
		print(sprintf("#%d: %s: %d settings...\n", i, TUR_NAME(i), TUR_CONFIG_COUNT));
		totalsettings += TUR_CONFIG_COUNT;
	}

	// clear queue now that we're finished
	TUR_CONFIG_COUNT = 0;
	for(x = 0; x <= MAX_TUR_CONFIG; ++x)
		{ tur_config_queue[x] = string_null; }

	// extra information
	print(sprintf("Totals: %d turrets, %d settings\n", (i - 1), totalsettings));
}
