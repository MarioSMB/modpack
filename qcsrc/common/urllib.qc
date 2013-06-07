// files
.float url_fh;
#define URL_FH_CURL   -1
#define URL_FH_STDOUT -2

// URLs
.string url_url;
.float url_wbuf;
.float url_wbufpos;
.float url_rbuf;
.float url_rbufpos;
.float url_id;
.url_ready_func url_ready;
.entity url_ready_pass;

// for multi handles
.float url_attempt;
.float url_mode;

entity url_fromid[NUM_URL_ID];
float autocvar__urllib_nextslot;

float url_URI_Get_Callback(float id, float status, string data)
{
	if(id < MIN_URL_ID)
		return 0;
	id -= MIN_URL_ID;
	if(id >= NUM_URL_ID)
		return 0;
	entity e;
	e = url_fromid[id];
	if(!e)
		return 0;
	if(e.url_rbuf >= 0 || e.url_wbuf >= 0)
	{
		print(sprintf("WARNING: handle %d (%s) has already received data?!?\n", id + NUM_URL_ID, e.url_url));
		return 0;
	}

	// whatever happens, we will remove the URL from the list of IDs
	url_fromid[id] = world;

	// if we get here, we MUST have both buffers cleared
	if(e.url_rbuf != -1 || e.url_wbuf != -1 || e.url_fh != URL_FH_CURL)
		error("url_URI_Get_Callback: not a request waiting for data");

	if(status == 0)
	{
		// WE GOT DATA!
		float n, i;
		n = tokenizebyseparator(data, "\n");
		e.url_rbuf = buf_create();
		if(e.url_rbuf < 0)
		{
			print("url_URI_Get_Callback: out of memory in buf_create\n");
			e.url_ready(e, e.url_ready_pass, URL_READY_ERROR);
			strunzone(e.url_url);
			remove(e);
			return 1;
		}
		e.url_rbufpos = 0;
		if(e.url_rbuf < 0)
		{
			print("url_URI_Get_Callback: out of memory in buf_create\n");
			e.url_ready(e, e.url_ready_pass, URL_READY_ERROR);
			strunzone(e.url_url);
			remove(e);
			return 1;
		}
		for(i = 0; i < n; ++i)
			bufstr_set(e.url_rbuf, i, argv(i));
		e.url_ready(e, e.url_ready_pass, URL_READY_CANREAD);
		return 1;
	}
	else
	{
		// an ERROR
		e.url_ready(e, e.url_ready_pass, -fabs(status));
		strunzone(e.url_url);
		remove(e);
		return 1;
	}
}

void url_single_fopen(string url, float mode, url_ready_func rdy, entity pass)
{
	entity e;
	float i;
	if(strstrofs(url, "://", 0) >= 0)
	{
		switch(mode)
		{
			case FILE_WRITE:
			case FILE_APPEND:
				// collect data to a stringbuffer for a POST request
				// attempts to close will result in a reading handle

				// create a writing end that does nothing yet
				e = spawn();
				e.classname = "url_single_fopen_file";
				e.url_url = strzone(url);
				e.url_fh = URL_FH_CURL;
				e.url_wbuf = buf_create();
				if(e.url_wbuf < 0)
				{
					print("url_single_fopen: out of memory in buf_create\n");
					rdy(e, pass, URL_READY_ERROR);
					strunzone(e.url_url);
					remove(e);
					return;
				}
				e.url_wbufpos = 0;
				e.url_rbuf = -1;
				e.url_ready = rdy;
				e.url_ready_pass = pass;
				rdy(e, pass, URL_READY_CANWRITE);
				break;

			case FILE_READ:
				// read data only

				// get slot for HTTP request
				for(i = autocvar__urllib_nextslot; i < NUM_URL_ID; ++i)
					if(url_fromid[i] == world)
						break;
				if(i >= NUM_URL_ID)
				{
					for(i = 0; i < autocvar__urllib_nextslot; ++i)
						if(url_fromid[i] == world)
							break;
					if(i >= autocvar__urllib_nextslot)
					{
						print("url_single_fopen: too many concurrent requests\n");
						rdy(world, pass, URL_READY_ERROR);
						return;
					}
				}

				// GET the data
				if(!crypto_uri_postbuf(url, i + MIN_URL_ID, string_null, string_null, -1, 0))
				{
					print("url_single_fopen: failure in crypto_uri_postbuf\n");
					rdy(world, pass, URL_READY_ERROR);
					return;
				}

				// Make a dummy handle object (no buffers at
				// all). Wait for data to come from the
				// server, then call the callback
				e = spawn();
				e.classname = "url_single_fopen_file";
				e.url_url = strzone(url);
				e.url_fh = URL_FH_CURL;
				e.url_rbuf = -1;
				e.url_wbuf = -1;
				e.url_ready = rdy;
				e.url_ready_pass = pass;
				e.url_id = i;
				url_fromid[i] = e;

				// make sure this slot won't be reused quickly even on map change
				cvar_set("_urllib_nextslot", ftos(mod(i + 1, NUM_URL_ID)));
				break;
		}
	}
	else if(url == "-")
	{
		switch(mode)
		{
			case FILE_WRITE:
			case FILE_APPEND:
				e = spawn();
				e.classname = "url_single_fopen_stdout";
				e.url_fh = URL_FH_STDOUT;
				e.url_ready = rdy;
				e.url_ready_pass = pass;
				rdy(e, pass, URL_READY_CANWRITE);
				break;
			case FILE_READ:
				print("url_single_fopen: cannot open '-' for reading\n");
				rdy(world, pass, URL_READY_ERROR);
				break;
		}
	}
	else
	{
		float fh;
		fh = fopen(url, mode);
		if(fh < 0)
		{
			rdy(world, pass, URL_READY_ERROR);
			return;
		}
		else
		{
			e = spawn();
			e.classname = "url_single_fopen_file";
			e.url_fh = fh;
			e.url_ready = rdy;
			e.url_ready_pass = pass;
			if(mode == FILE_READ)
				rdy(e, pass, URL_READY_CANREAD);
			else
				rdy(e, pass, URL_READY_CANWRITE);
		}
	}
}

// close a file
void url_fclose(entity e)
{
	float i;

	if(e.url_fh == URL_FH_CURL)
	{
		if(e.url_rbuf == -1 || e.url_wbuf != -1) // not(post GET/POST request)
		if(e.url_rbuf != -1 || e.url_wbuf == -1) // not(pre POST request)
			error("url_fclose: not closable in current state");

		// closing an URL!
		if(e.url_wbuf >= 0)
		{
			// we are closing the write end (HTTP POST request)

			// get slot for HTTP request
			for(i = autocvar__urllib_nextslot; i < NUM_URL_ID; ++i)
				if(url_fromid[i] == world)
					break;
			if(i >= NUM_URL_ID)
			{
				for(i = 0; i < autocvar__urllib_nextslot; ++i)
					if(url_fromid[i] == world)
						break;
				if(i >= autocvar__urllib_nextslot)
				{
					print("url_fclose: too many concurrent requests\n");
					e.url_ready(e,e.url_ready_pass, URL_READY_ERROR);
					buf_del(e.url_wbuf);
					strunzone(e.url_url);
					remove(e);
					return;
				}
			}

			// POST the data
			if(!crypto_uri_postbuf(e.url_url, i + MIN_URL_ID, "text/plain", "", e.url_wbuf, 0))
			{
				print("url_fclose: failure in crypto_uri_postbuf\n");
				e.url_ready(e, e.url_ready_pass, URL_READY_ERROR);
				buf_del(e.url_wbuf);
				strunzone(e.url_url);
				remove(e);
				return;
			}

			// delete write end. File handle is now in unusable
			// state. Wait for data to come from the server, then
			// call the callback
			buf_del(e.url_wbuf);
			e.url_wbuf = -1;
			e.url_id = i;
			url_fromid[i] = e;

			// make sure this slot won't be reused quickly even on map change
			cvar_set("_urllib_nextslot", ftos(mod(i + 1, NUM_URL_ID)));
		}
		else
		{
			// we have READ all data, just close
			e.url_ready(e, e.url_ready_pass, URL_READY_CLOSED);
			buf_del(e.url_rbuf);
			strunzone(e.url_url);
			remove(e);
		}
	}
	else if(e.url_fh == URL_FH_STDOUT)
	{
		e.url_ready(e, e.url_ready_pass, URL_READY_CLOSED); // closing creates no reading handle
		remove(e);
	}
	else
	{
		// file
		fclose(e.url_fh);
		e.url_ready(e, e.url_ready_pass, URL_READY_CLOSED); // closing creates no reading handle
		remove(e);
	}
}

// with \n (blame FRIK_FILE)
string url_fgets(entity e)
{
	if(e.url_fh == URL_FH_CURL)
	{
		if(e.url_rbuf == -1)
			error("url_fgets: not readable in current state");
		// curl
		string s;
		s = bufstr_get(e.url_rbuf, e.url_rbufpos);
		e.url_rbufpos += 1;
		return s;
	}
	else if(e.url_fh == URL_FH_STDOUT)
	{
		// stdout
		return string_null;
	}
	else
	{
		// file
		return fgets(e.url_fh);
	}
}

// without \n (blame FRIK_FILE)
void url_fputs(entity e, string s)
{
	if(e.url_fh == URL_FH_CURL)
	{
		if(e.url_wbuf == -1)
			error("url_fputs: not writable in current state");
		// curl
		bufstr_set(e.url_wbuf, e.url_wbufpos, s);
		e.url_wbufpos += 1;
	}
	else if(e.url_fh == URL_FH_STDOUT)
	{
		// stdout
		print(s);
	}
	else
	{
		// file
		fputs(e.url_fh, s);
	}
}

// multi URL object, tries URLs separated by space in sequence
void url_multi_ready(entity fh, entity me, float status)
{
	float n;
	if(status == URL_READY_ERROR || status < 0)
	{
		if(status == -422) // Unprocessable Entity
		{
			print("uri_multi_ready: got HTTP error 422, data is in unusable format - not continuing\n");
			me.url_ready(fh, me.url_ready_pass, status);
			strunzone(me.url_url);
			remove(me);
			return;
		}
		me.url_attempt += 1;
		n = tokenize_console(me.url_url);
		if(n <= me.url_attempt)
		{
			me.url_ready(fh, me.url_ready_pass, status);
			strunzone(me.url_url);
			remove(me);
			return;
		}
		url_single_fopen(argv(me.url_attempt), me.url_mode, url_multi_ready, me);
		return;
	}
	me.url_ready(fh, me.url_ready_pass, status);
}
void url_multi_fopen(string url, float mode, url_ready_func rdy, entity pass)
{
	float n;
	n = tokenize_console(url);
	if(n <= 0)
	{
		print("url_multi_fopen: need at least one URL\n");
		rdy(world, pass, URL_READY_ERROR);
		return;
	}

	entity me;
	me = spawn();
	me.classname = "url_multi";
	me.url_url = strzone(url);
	me.url_attempt = 0;
	me.url_mode = mode;
	me.url_ready = rdy;
	me.url_ready_pass = pass;
	url_single_fopen(argv(0), mode, url_multi_ready, me);
}
