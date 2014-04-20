// ==========================
//  Balance Config Generator
// ==========================

void W_Config_Queue_Swap(float root, float child, entity pass)
{
	string oldroot = wep_config_queue[root];
	wep_config_queue[root] = wep_config_queue[child];
	wep_config_queue[child] = oldroot;
}

float W_Config_Queue_Compare(float root, float child, entity pass)
{
	return strcmp(wep_config_queue[root], wep_config_queue[child]);
}

void Dump_Weapon_Settings(void)
{
	float i, x, totalsettings = 0;
	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
	{
		// step 1: clear the queue
		WEP_CONFIG_COUNT = 0;
		for(x = 0; x <= MAX_WEP_CONFIG; ++x)
			{ wep_config_queue[x] = string_null; }

		// step 2: build new queue
		WEP_ACTION(i, WR_CONFIG);

		// step 3: sort queue
		heapsort(WEP_CONFIG_COUNT, W_Config_Queue_Swap, W_Config_Queue_Compare, world);
		
		// step 4: write queue
		WEP_CONFIG_WRITETOFILE(sprintf(
			"// {{{ #%d: %s%s\n",
			i,
			WEP_NAME(i),
			(((get_weaponinfo(i)).spawnflags & WEP_FLAG_MUTATORBLOCKED) ? " (MUTATOR WEAPON)" : "")
		))
		for(x = 0; x <= WEP_CONFIG_COUNT; ++x) { WEP_CONFIG_WRITETOFILE(wep_config_queue[x]) }
		WEP_CONFIG_WRITETOFILE("// }}}\n")

		// step 5: debug info
		print(sprintf("#%d: %s: %d settings...\n", i, WEP_NAME(i), WEP_CONFIG_COUNT));
		totalsettings += WEP_CONFIG_COUNT;
	}

	// clear queue now that we're finished
	WEP_CONFIG_COUNT = 0;
	for(x = 0; x <= MAX_WEP_CONFIG; ++x)
		{ wep_config_queue[x] = string_null; }

	// extra information
	print(sprintf("Totals: %d weapons, %d settings\n", (i - 1), totalsettings));
}
