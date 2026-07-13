#include "qcsound.qh"

#include "all.qh"

#ifdef SVQC
void qc_startsound(int to, entity e, vector o, int chan, Sound samp, float vol, float attenu, float _pitch)
{
	if (!sound_allowed(to, e)) return;

	if (!autocvar_sv_quake_newsounds)
	{
		// fall back to engine support
		sound7(e, chan, Sound_fixpath(samp), vol, attenu, _pitch, 0);
		return;
	}

	int entno = etof(e);
	//int idx = precache_sound_index(samp);
	attenu = floor(attenu * 64);
	vol = floor(vol * 255);
	int sflags = 0;
	int speed4000 = floor((_pitch * 0.01) * 4000 + 0.5);
	if (vol != 255) sflags |= SND_VOLUME;
	if (attenu != 64) sflags |= SND_ATTENUATION;
	if (entno >= 8192 || chan < 0 || chan > 7) sflags |= SND_LARGEENTITY;
	//if (idx >= 256) sflags |= SND_LARGESOUND;
	if (speed4000 && speed4000 != 4000) sflags |= SND_SPEEDUSHORT4000;
	WriteHeader(to, QC_SOUND);
	WriteByte(to, sflags);
	if (sflags & SND_VOLUME) WriteByte(to, vol);
	if (sflags & SND_ATTENUATION) WriteByte(to, attenu);
	if (sflags & SND_SPEEDUSHORT4000) WriteShort(to, speed4000);
	if (sflags & SND_LARGEENTITY)
	{
		WriteShort(to, entno);
		WriteChar(to, chan);
	}
	else
	{
		WriteShort(to, (entno << 3) | chan);
	}
	//if (sflags & SND_LARGESOUND) WriteShort(to, idx);
	//else WriteByte(to, idx);
	// TODO: using WriteRegistered seems to break?
	WriteShort(to, samp.m_id);
	WriteVector(to, o);
}
#endif

#ifdef GAMEQC
void qc_sound7(entity e, int chan, Sound samp, float vol, float atten, float pitchchange, int sndflags)
{
#ifdef SVQC
	//int dest = (sndflags & CHANNELFLAG_RELIABLE) ? MSG_ALL : MSG_BROADCAST;
	int dest = MSG_ALL; // TODO?
	vector o = e.origin + 0.5 * (e.mins + e.maxs);

	qc_startsound(dest, e, o, chan, samp, vol, atten, pitchchange);
#else
	sound7(e, chan, Sound_fixpath(samp), vol, atten, pitchchange, sndflags);
#endif
}

void qc_sound(entity e, int chan, Sound samp, float vol, float atten)
{
	qc_sound7(e, chan, samp, vol, atten, 0, 0);
}
#endif

#ifdef CSQC
NET_HANDLE(QC_SOUND, bool isnew)
{
	float nvolume;
	float thespeed;
	float attenuation;
	int ent;
	int channel;

	int sf = ReadByte();

	if(sf & SND_VOLUME)
		nvolume = ReadByte();
	else
		nvolume = 255;

	if(sf & SND_ATTENUATION)
		attenuation = ReadByte() / 64;
	else
		attenuation = 1;

	if(sf & SND_SPEEDUSHORT4000)
		thespeed = ReadShort() / 4000;
	else
		thespeed = 0;

	if(sf & SND_LARGEENTITY)
	{
		ent = ReadShort();
		channel = ReadChar();
	}
	else
	{
		channel = ReadShort();
		ent = channel >> 3;
		channel &= 7;
	}

	Sound thesound = REGISTRY_GET(Sounds, ReadShort());
	string samp = Sound_fixpath(thesound);

	vector pos = ReadVector();
	entity e = findfloat(NULL, entnum, ent);

	// FIXME? pointsound doesn't support channels
	// sounds played using it will not respect any specific channel volume settings
	// we COULD work around this by scaling volume by the channel's volume cvar
	if(e)
		sound7(e, channel, samp, nvolume / 255, attenuation, thespeed * 100, 0);
	else
		pointsound(pos, samp, nvolume / 255, attenuation);

	return true;
}
#endif
