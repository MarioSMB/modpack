void WeaponStats_Init()
{
	weaponstats_buffer = ((autocvar_sv_weaponstats_file != "") ? buf_create() : -1);
}

void WeaponStats_ready(entity fh, entity pass, float status)
{
	float i, j, n, ibot, jbot, idx;
	vector v;
	string prefix, s;
	switch(status)
	{
		case URL_READY_CANWRITE:
			// we can write
			prefix = strcat(autocvar_hostname, "\t", GetGametype(), "_", GetMapname(), "\t");
			url_fputs(fh, "#begin statsfile\n");
			url_fputs(fh, strcat("#date ", strftime(TRUE, "%a %b %e %H:%M:%S %Z %Y"), "\n"));
#ifdef WATERMARK
			url_fputs(fh, strcat("#version ", WATERMARK, "\n"));
#endif
			url_fputs(fh, strcat("#config ", ftos(crc16(FALSE, cvar_purechanges)), "\n"));
			url_fputs(fh, strcat("#cvar_purechanges ", ftos(cvar_purechanges_count), "\n"));
			n = tokenizebyseparator(cvar_purechanges, "\n");
			for(i = 0; i < n; ++i)
				url_fputs(fh, strcat("#cvar_purechange ", argv(i), "\n"));
			for(i = WEP_FIRST; i <= WEP_LAST; ++i) for(ibot = 0; ibot <= 1; ++ibot)
				for(j = WEP_FIRST; j <= WEP_LAST; ++j) for(jbot = 0; jbot <= 1; ++jbot)
				{
					idx = WEAPONSTATS_GETINDEX(i, ibot, j, jbot);
					v = stov(bufstr_get(weaponstats_buffer, idx));
					if(v != '0 0 0')
					{
						//vector is: kills hits damage
						url_fputs(fh, sprintf("%s%d %d\t%d %d\t", prefix, i, ibot, j, jbot));
						url_fputs(fh, sprintf("%d %d %g\n", v_x, v_y, v_z));
					}
				}
			url_fputs(fh, "#end\n\n");
			url_fclose(fh);
			break;
		case URL_READY_CANREAD:
			// url_fclose is processing, we got a response for writing the data
			// this must come from HTTP
			print("Got response from weapon stats server:\n");
			while((s = url_fgets(fh)))
				print("  ", s, "\n");
			print("End of response.\n");
			url_fclose(fh);
			break;
		case URL_READY_CLOSED:
			// url_fclose has finished
			print("Weapon stats written\n");
			buf_del(weaponstats_buffer);
			weaponstats_buffer = -1;
			break;
		case URL_READY_ERROR:
		default:
			print("Weapon stats writing failed: ", ftos(status), "\n");
			buf_del(weaponstats_buffer);
			weaponstats_buffer = -1;
			break;
	}
}

void WeaponStats_Shutdown()
{
	if(weaponstats_buffer < 0)
		return;
	if(autocvar_sv_weaponstats_file != "")
	{
		url_multi_fopen(autocvar_sv_weaponstats_file, FILE_APPEND, WeaponStats_ready, world);
	}
	else
	{
		buf_del(weaponstats_buffer);
		weaponstats_buffer = -1;
	}
}

void WeaponStats_LogItem(float awep, float abot, float vwep, float vbot, vector item)
{
	float idx;
	if(weaponstats_buffer < 0)
		return;
	if(awep < WEP_FIRST || vwep < WEP_FIRST)
		return;
	if(awep > WEP_LAST || vwep > WEP_LAST)
		return;
	idx = WEAPONSTATS_GETINDEX(awep,abot,vwep,vbot);
	bufstr_set(weaponstats_buffer, idx, vtos(stov(bufstr_get(weaponstats_buffer, idx)) + item));
}

void WeaponStats_LogDamage(float awep, float abot, float vwep, float vbot, float damage)
{
	if(damage < 0)
		error("negative damage?");
	WeaponStats_LogItem(awep, abot, vwep, vbot, '0 0 1' * damage + '0 1 0');
}

void WeaponStats_LogKill(float awep, float abot, float vwep, float vbot)
{
	WeaponStats_LogItem(awep, abot, vwep, vbot, '1 0 0');
}
