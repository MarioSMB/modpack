#include "music.qh"

REGISTER_NET_TEMP(TE_CSQC_TARGET_MUSIC)
REGISTER_NET_LINKED(ENT_CLIENT_TRIGGER_MUSIC)

#ifdef SVQC

IntrusiveList g_targetmusic_list;
STATIC_INIT(g_targetmusic_list)
{
	g_targetmusic_list = IL_NEW();
}

// values:
//   volume
//   noise
//   targetname
//   lifetime
//   fade_time
//   fade_rate
// when triggered, the music is overridden for activator until lifetime (or forever, if lifetime is 0)
// when targetname is not set, THIS ONE is default
void target_music_sendto(entity this, int to, bool is)
{
	WriteHeader(to, TE_CSQC_TARGET_MUSIC);
	WriteShort(to, etof(this));
	WriteByte(to, this.volume * 255.0 * is);
	WriteByte(to, this.fade_time * 16.0);
	WriteByte(to, this.fade_rate * 16.0);
	WriteByte(to, this.lifetime);
	WriteString(to, this.noise);
}
void target_music_kill()
{
	IL_EACH(g_targetmusic_list, true,
	{
		it.volume = 0;
        if (it.targetname == "")
            target_music_sendto(it, MSG_ALL, true);
        else
            target_music_sendto(it, MSG_ALL, false);
	});
}
void target_music_use(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;
	if(IS_REAL_CLIENT(actor))
	{
		msg_entity = actor;
		target_music_sendto(this, MSG_ONE, true);
	}
	FOREACH_CLIENT(it != actor && IS_OBSERVER(it) && it.clientcamera == actor, {
		msg_entity = it;
		target_music_sendto(this, MSG_ONE, true);
	});
}
spawnfunc(target_music)
{
	this.use = target_music_use;
	if(!this.volume)
		this.volume = 1;
	IL_PUSH(g_targetmusic_list, this);
	if(this.targetname == "")
		target_music_sendto(this, MSG_INIT, true);
	else
		target_music_sendto(this, MSG_INIT, false);
}
void TargetMusic_RestoreGame()
{
	IL_EACH(g_targetmusic_list, true,
	{
		if(it.targetname == "")
			target_music_sendto(it, MSG_INIT, true);
		else
			target_music_sendto(it, MSG_INIT, false);
	});
}
// values:
//   volume
//   noise
//   targetname
//   fade_time
// spawnflags:
//   START_DISABLED
// can be disabled/enabled for everyone with relays
bool trigger_music_SendEntity(entity this, entity to, int sendflags)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_TRIGGER_MUSIC);
	WriteByte(MSG_ENTITY, sendflags);
	if(sendflags & SF_MUSIC_ORIGIN)
	{
		WriteVector(MSG_ENTITY, this.origin);
	}
	if(sendflags & SF_TRIGGER_INIT)
	{
		if(this.model != "null")
		{
			WriteShort(MSG_ENTITY, this.modelindex);
			WriteVector(MSG_ENTITY, this.mins);
			WriteVector(MSG_ENTITY, this.maxs);
		}
		else
		{
			WriteShort(MSG_ENTITY, 0);
			WriteVector(MSG_ENTITY, this.maxs);
		}
		WriteByte(MSG_ENTITY, this.volume * 255.0);
		WriteByte(MSG_ENTITY, this.fade_time * 16.0);
		WriteByte(MSG_ENTITY, this.fade_rate * 16.0);
		WriteString(MSG_ENTITY, this.noise);
	}
	if(sendflags & SF_TRIGGER_UPDATE)
	{
		WriteByte(MSG_ENTITY, this.active);
	}
	return true;
}

void trigger_music_reset(entity this)
{
	if(this.spawnflags & START_DISABLED)
	{
		generic_netlinked_setactive(this, ACTIVE_NOT);
	}
	else
	{
		generic_netlinked_setactive(this, ACTIVE_ACTIVE);
	}
}

spawnfunc(trigger_music)
{
	if(this.model != "")
	{
		_setmodel(this, this.model);
	}
	if(!this.volume)
	{
		this.volume = 1;
	}
	if(!this.modelindex)
	{
		setorigin(this, this.origin + this.mins);
		setsize(this, '0 0 0', this.maxs - this.mins);
	}

	this.use = generic_netlinked_legacy_use; // backwards compatibility
	trigger_music_reset(this);

	Net_LinkEntity(this, false, 0, trigger_music_SendEntity);
}
#elif defined(CSQC)

entity TargetMusic_list;
STATIC_INIT(TargetMusic_list)
{
	TargetMusic_list = LL_NEW();
}

void TargetMusic_Advance()
{
	// run AFTER all the thinks!
	entity best = music_default;
	if (music_target && time < music_target.lifetime)
	{
		best = music_target;
	}
	if (music_trigger)
	{
		best = music_trigger;
	}
	LL_EACH(TargetMusic_list, it.noise, {
		const float vol0 = (getsoundtime(it, CH_BGM_SINGLE) >= 0) ? it.lastvol : -1;
		if (it == best)
		{
			// increase volume
			it.state = (it.fade_time > 0) ? bound(0, it.state + frametime / it.fade_time, 1) : 1;
		}
		else
		{
			// decrease volume
			it.state = (it.fade_rate > 0) ? bound(0, it.state - frametime / it.fade_rate, 1) : 0;
		}
		const float vol = it.state * it.volume * autocvar_bgmvolume;
		if (vol != vol0)
		{
			if(vol0 < 0)
				sound7(it, CH_BGM_SINGLE, it.noise, vol, ATTEN_NONE, 0, BIT(4)); // restart
			else
				sound7(it, CH_BGM_SINGLE, "", vol, ATTEN_NONE, 0, BIT(4));
			it.lastvol = vol;
		}
	});
	music_trigger = NULL;
	//bgmtime = (best) ? getsoundtime(best, CH_BGM_SINGLE) : gettime(GETTIME_CDTRACK);
}

NET_HANDLE(TE_CSQC_TARGET_MUSIC, bool isNew)
{
	Net_TargetMusic();
	return true;
}

void Net_TargetMusic()
{
	const int id = ReadShort();
	const float vol = ReadByte() / 255.0;
	const float fai = ReadByte() / 16.0;
	const float fao = ReadByte() / 16.0;
	const float tim = ReadByte();
	const string noi = ReadString();

	entity e = NULL;
	LL_EACH(TargetMusic_list, it.count == id, { e = it; break; });
	if (!e)
	{
		LL_PUSH(TargetMusic_list, e = new_pure(TargetMusic));
		e.count = id;
	}
	if(e.noise != noi)
	{
		strcpy(e.noise, noi);
		precache_sound(e.noise);
		_sound(e, CH_BGM_SINGLE, e.noise, 0, ATTEN_NONE);
		if(getsoundtime(e, CH_BGM_SINGLE) < 0)
		{
			LOG_TRACEF("Cannot initialize sound %s", e.noise);
			strfree(e.noise);
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

void Ent_TriggerMusic_Think(entity this)
{
	if(this.active == ACTIVE_NOT || intermission)
	{
		return;
	}
	vector org = (csqcplayer) ? csqcplayer.origin : view_origin;
	if(boxesoverlap(org + STAT(PL_MIN), org + STAT(PL_MAX), this.absmin, this.absmax))
	{
		music_trigger = this;
	}
}

void Ent_TriggerMusic_Remove(entity this)
{
    strfree(this.noise);
}

NET_HANDLE(ENT_CLIENT_TRIGGER_MUSIC, bool isnew)
{
	int sendflags = ReadByte();
	if(sendflags & SF_MUSIC_ORIGIN)
	{
		this.origin = ReadVector();
	}
	if(sendflags & SF_TRIGGER_INIT)
	{
		this.modelindex = ReadShort();
		if(this.modelindex)
		{
			this.mins = ReadVector();
			this.maxs = ReadVector();
		}
		else
		{
			this.mins    = '0 0 0';
			this.maxs = ReadVector();
		}

		this.volume = ReadByte() / 255.0;
		this.fade_time = ReadByte() / 16.0;
		this.fade_rate = ReadByte() / 16.0;
		string s = this.noise;
		strcpy(this.noise, ReadString());
		if(this.noise != s)
		{
			precache_sound(this.noise);
			sound7(this, CH_BGM_SINGLE, this.noise, 0, ATTEN_NONE, 0, BIT(4));
			if(getsoundtime(this, CH_BGM_SINGLE) < 0)
			{
				LOG_WARNF("Cannot initialize sound %s", this.noise);
				strfree(this.noise);
			}
		}
	}
	if(sendflags & SF_TRIGGER_UPDATE)
	{
		this.active = ReadByte();
	}

	setorigin(this, this.origin);
	setsize(this, this.mins, this.maxs);
	this.draw = Ent_TriggerMusic_Think;
	if(isnew)
	{
		LL_PUSH(TargetMusic_list, this);
		IL_PUSH(g_drawables, this);
	}
	return true;
}

#endif
