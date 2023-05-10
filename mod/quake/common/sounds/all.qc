#include "all.qh"
#ifdef SVQC

bool autocvar_bot_sound_monopoly;

.entity realowner;
bool sound_allowed(int to, entity e)
{
	for ( ; ; )
	{
		if (e.classname == "body") e = e.enemy;
		else if (e.realowner && e.realowner != e) e = e.realowner;
		else if (e.owner && e.owner != e) e = e.owner;
		else break;
	}
	// sounds to self may always pass
	if (to == MSG_ONE && e == msg_entity) return true;
	// sounds by players can be removed
	if (autocvar_bot_sound_monopoly && IS_REAL_CLIENT(e)) return false;
	// anything else may pass
	return true;
}

/** hack: string precache_sound(string s) = #19; */
int precache_sound_index(string s) = #19;

const int SVC_SOUND = 6;
const int SVC_STOPSOUND = 16;

const int SND_VOLUME = BIT(0);
const int SND_ATTENUATION = BIT(1);
const int SND_LARGEENTITY = BIT(3);
const int SND_LARGESOUND = BIT(4);

void soundtoat(int to, entity e, vector o, int chan, string samp, float vol, float attenu)
{
	if (!sound_allowed(to, e)) return;
	int entno = etof(e);
	int idx = precache_sound_index(samp);
	attenu = floor(attenu * 64);
	vol = floor(vol * 255);
	int sflags = 0;
	if (vol != 255) sflags |= SND_VOLUME;
	if (attenu != 64) sflags |= SND_ATTENUATION;
	if (entno >= 8192 || chan < 0 || chan > 7) sflags |= SND_LARGEENTITY;
	if (idx >= 256) sflags |= SND_LARGESOUND;
	WriteByte(to, SVC_SOUND);
	WriteByte(to, sflags);
	if (sflags & SND_VOLUME) WriteByte(to, vol);
	if (sflags & SND_ATTENUATION) WriteByte(to, attenu);
	if (sflags & SND_LARGEENTITY)
	{
		WriteShort(to, entno);
		WriteByte(to, chan);
	}
	else
	{
		WriteShort(to, (entno << 3) | chan);
	}
	if (sflags & SND_LARGESOUND) WriteShort(to, idx);
	else WriteByte(to, idx);
	WriteCoord(to, o.x);
	WriteCoord(to, o.y);
	WriteCoord(to, o.z);
}

void soundto(int _dest, entity e, int chan, string samp, float vol, float _atten)
{
	if (!sound_allowed(_dest, e)) return;
	vector o = e.origin + 0.5 * (e.mins + e.maxs);
	soundtoat(_dest, e, o, chan, samp, vol, _atten);
}
void soundat(entity e, vector o, int chan, string samp, float vol, float _atten)
{
	soundtoat(((chan & 8) ? MSG_ALL : MSG_BROADCAST), e, o, chan, samp, vol, _atten);
}
void stopsoundto(int _dest, entity e, int chan)
{
	if (!sound_allowed(_dest, e)) return;
	int entno = etof(e);
	if (entno >= 8192 || chan < 0 || chan > 7)
	{
		int idx = precache_sound_index(SND(Null));
		int sflags = SND_LARGEENTITY;
		if (idx >= 256) sflags |= SND_LARGESOUND;
		WriteByte(_dest, SVC_SOUND);
		WriteByte(_dest, sflags);
		WriteShort(_dest, entno);
		WriteByte(_dest, chan);
		if (sflags & SND_LARGESOUND) WriteShort(_dest, idx);
		else WriteByte(_dest, idx);
		WriteCoord(_dest, e.origin.x);
		WriteCoord(_dest, e.origin.y);
		WriteCoord(_dest, e.origin.z);
	}
	else
	{
		WriteByte(_dest, SVC_STOPSOUND);
		WriteShort(_dest, entno * 8 + chan);
	}
}
void stopsound(entity e, int chan)
{
	if (!sound_allowed(MSG_BROADCAST, e)) return;
	stopsoundto(MSG_BROADCAST, e, chan); // unreliable, gets there fast
	stopsoundto(MSG_ALL, e, chan);       // in case of packet loss
}

void play2(entity e, string filename)
{
	msg_entity = e;
	soundtoat(MSG_ONE, NULL, '0 0 0', CH_INFO, filename, VOL_BASE, ATTEN_NONE);
}

.float spamtime;
/** use this one if you might be causing spam (e.g. from touch functions that might get called more than once per frame) */
float spamsound(entity e, int chan, string samp, float vol, float _atten)
{
	if (!sound_allowed(MSG_BROADCAST, e)) return false;
	if (time > e.spamtime)
	{
		e.spamtime = time;
		_sound(e, chan, samp, vol, _atten);
		return true;
	}
	return false;
}

void play2all(string samp)
{
	if (autocvar_bot_sound_monopoly) return;
	_sound(NULL, CH_INFO, samp, VOL_BASE, ATTEN_NONE);
}

#endif
