// ==========================
//  Monster Config Generator
// ==========================

void M_Config_Queue_Swap(float root, float child, entity pass)
{
	string oldroot = mon_config_queue[root];
	mon_config_queue[root] = mon_config_queue[child];
	mon_config_queue[child] = oldroot;
}

float M_Config_Queue_Compare(float root, float child, entity pass)
{
	float i, r, c;

	for(i = 1; i <= 100; ++i)
	{
		r = str2chr(mon_config_queue[root], i);
		c = str2chr(mon_config_queue[child], i);
		if(r == c) { continue; }
		else if(c > r) { return -1; }
		else { return 1; }
	}
	
	return 0;
}

void Dump_Monster_Settings(void)
{
	float i, x, totalsettings = 0;
	for(i = MON_FIRST; i <= MON_LAST; ++i)
	{
		// step 1: clear the queue
		MON_CONFIG_COUNT = 0;
		for(x = 0; x <= MAX_MON_CONFIG; ++x)
			{ mon_config_queue[x] = string_null; }

		// step 2: build new queue
		MON_ACTION(i, MR_CONFIG);

		// step 3: sort queue
		heapsort(MON_CONFIG_COUNT, M_Config_Queue_Swap, M_Config_Queue_Compare, world);
		
		// step 4: write queue
		MON_CONFIG_WRITETOFILE(sprintf("// {{{ #%d: %s\n", i, M_NAME(i)))
		for(x = 0; x <= MON_CONFIG_COUNT; ++x)
			{ MON_CONFIG_WRITETOFILE(mon_config_queue[x]) }
		MON_CONFIG_WRITETOFILE("// }}}\n")

		// step 5: debug info
		print(sprintf("#%d: %s: %d settings...\n", i, M_NAME(i), MON_CONFIG_COUNT));
		totalsettings += MON_CONFIG_COUNT;
	}

	// clear queue now that we're finished
	MON_CONFIG_COUNT = 0;
	for(x = 0; x <= MAX_MON_CONFIG; ++x)
		{ mon_config_queue[x] = string_null; }

	// extra information
	print(sprintf("Totals: %d monsters, %d settings\n", (i - 1), totalsettings));
}
