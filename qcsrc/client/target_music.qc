float music_disabled;
entity music_default;
entity music_target;
entity music_trigger;

.float state;
.float lastvol;

void TargetMusic_Advance()
{
	// run AFTER all the thinks!
	entity best, e;
	float vol, vol0;
	best = music_default;
	if(music_target && time < music_target.lifetime)
		best = music_target;
	if(music_trigger)
		best = music_trigger;
	for(e = world; (e = findfloat(e, enttype, ENT_CLIENT_TRIGGER_MUSIC)); ) if(e.noise)
	{
		vol0 = e.lastvol;
		if(getsoundtime(e, CH_BGM_SINGLE) < 0)
		{
			vol0 = -1;
		}
		if(e == best)
		{
			// increase volume
			if(e.fade_time > 0)
				e.state = bound(0, e.state + frametime / e.fade_time, 1);
			else
				e.state = 1;
		}
		else
		{
			// decrease volume
			if(e.fade_rate > 0)
				e.state = bound(0, e.state - frametime / e.fade_rate, 1);
			else
				e.state = 0;
		}
		vol = e.state * e.volume * autocvar_bgmvolume;
		if(vol != vol0)
		{
			if(vol0 < 0)
				sound(e, CH_BGM_SINGLE, e.noise, vol, ATTN_NONE); // restart
			else
				sound(e, CH_BGM_SINGLE, "", vol, ATTN_NONE);
			e.lastvol = vol;
		}
	}
	music_trigger = world;

	if(best)
		bgmtime = getsoundtime(best, CH_BGM_SINGLE);
	else
		bgmtime = gettime(GETTIME_CDTRACK);
}

void Net_TargetMusic()
{
	float vol, fai, fao, tim, id;
	string noi;
	entity e;

	id = ReadShort();
	vol = ReadByte() / 255.0;
	fai = ReadByte() / 16.0;
	fao = ReadByte() / 16.0;
	tim = ReadByte();
	noi = ReadString();

	for(e = world; (e = findfloat(e, enttype, ENT_CLIENT_TRIGGER_MUSIC)); )
	{
		if(e.count == id)
			break;
	}
	if(!e)
	{
		e = spawn();
		e.enttype = ENT_CLIENT_TRIGGER_MUSIC;
		e.count = id;
	}
	if(e.noise != noi)
	{
		if(e.noise)
			strunzone(e.noise);
		e.noise = strzone(noi);
		precache_sound(e.noise);
		sound(e, CH_BGM_SINGLE, e.noise, 0, ATTN_NONE);
		if(getsoundtime(e, CH_BGM_SINGLE) < 0)
		{
			print(sprintf(_("Cannot initialize sound %s\n"), e.noise));
			strunzone(e.noise);
			e.noise = string_null;
		}
	}
	e.volume = vol;
	e.fade_time = fai;
	e.fade_rate = fao;
	if(vol > 0)
	{
		if(tim == 0)
		{
			music_default = e;
			if(!music_disabled)
			{
				e.state = 2;
				cvar_settemp("music_playlist_index", "-1"); // don't use playlists
				localcmd("cd stop\n"); // just in case
				music_disabled = 1;
			}
		}
		else
		{
			music_target = e;
			e.lifetime = time + tim;
		}
	}
}

void Ent_TriggerMusic_Think()
{
	if(WarpZoneLib_BoxTouchesBrush(view_origin, view_origin, self, world))
	{
		music_trigger = self;
	}
	self.nextthink = time;
}

void Ent_TriggerMusic_Remove()
{
	if(self.noise)
		strunzone(self.noise);
	self.noise = string_null;
}

void Ent_ReadTriggerMusic()
{
	float f;
	string s;
	f = ReadByte();
	if(f & 4)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}
	if(f & 1)
	{
		self.modelindex = ReadShort();
		if(self.modelindex)
		{
			self.mins_x = ReadCoord();
			self.mins_y = ReadCoord();
			self.mins_z = ReadCoord();
			self.maxs_x = ReadCoord();
			self.maxs_y = ReadCoord();
			self.maxs_z = ReadCoord();
		}
		else
		{
			self.mins    = '0 0 0';
			self.maxs_x = ReadCoord();
			self.maxs_y = ReadCoord();
			self.maxs_z = ReadCoord();
		}

		self.volume = ReadByte() / 255.0;
		self.fade_time = ReadByte() / 16.0;
		self.fade_rate = ReadByte() / 16.0;
		s = self.noise;
		if(self.noise)
			strunzone(self.noise);
		self.noise = strzone(ReadString());
		if(self.noise != s)
		{
			precache_sound(self.noise);
			sound(self, CH_BGM_SINGLE, self.noise, 0, ATTN_NONE);
			if(getsoundtime(self, CH_BGM_SINGLE) < 0)
			{
				print(sprintf(_("Cannot initialize sound %s\n"), self.noise));
				strunzone(self.noise);
				self.noise = string_null;
			}
		}
	}

	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.cnt = 1;
	self.think = Ent_TriggerMusic_Think;
	self.nextthink = time;
}
