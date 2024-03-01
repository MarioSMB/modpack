#include "music.qh"

#ifdef SVQC
PRECACHE(Music)
{
	precache_model("progs/piano_musicnote_white.mdl");
}

void music_reset(entity this)
{
	.entity weaponentity = weaponentities[0];
	if(!this.(weaponentity))
		return;
	this.(weaponentity).music_pos = 0;
	this.(weaponentity).music_speed = 0;
	this.(weaponentity).music_nextnote = 0;
	this.(weaponentity).music_repeatstart = 0;
	this.(weaponentity).music_repeatend = 0;
	this.(weaponentity).music_starttime = 0;
	strfree(this.(weaponentity).music_song);
}

void music_RemovePlayer(entity this)
{
	music_reset(this);
}

int note_from_char(int input)
{
	switch(input)
	{
		case 'c': return 0;
		case 'd': return 1;
		case 'e': return 2;
		case 'f': return 3;
		case 'g': return 4;
		case 'a': return 5;
		case 'b': return 6;
	}
	return 0; // C as a default?
}

void CreatureFrame_Music(entity this)
{
	.entity weaponentity = weaponentities[0]; // TODO?
	string mymusic = this.(weaponentity).music_song;
	if(!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_MUSIC))
	{
		if(mymusic && mymusic != "")
			music_reset(this);
		return;
	}
	if(!mymusic || mymusic == "")
		return;

	if(time < this.(weaponentity).music_nextnote)
		return;

	float mspeed = this.(weaponentity).music_speed;

	int mypos = this.(weaponentity).music_pos;
	int argc = tokenize_console(mymusic);

	int playnote = 0;
	int playoctave = 0;
	int playsharp = 0;

#define SKIP_NOTE \
	this.(weaponentity).music_pos += 1; \
	mypos = this.(weaponentity).music_pos; \
	note = argv(mypos)

	string note = argv(mypos);
	if(note == "1|" || note == "|1") // so i don't have to remember which side to put it
	{
		if(mypos < this.(weaponentity).music_repeatend) // already repeated, skip ahead to the end of the repeat
		{
			mypos = this.(weaponentity).music_pos = this.(weaponentity).music_repeatend;
			note = argv(mypos);
		}
		else
		{
			SKIP_NOTE;
		}
	}
	if(note == "2|" || note == "|2") // just skip it, the repeat marker is the "end" of the first time section
	{
		SKIP_NOTE;
	}
	if(note == ":|")
	{
		if(mypos == this.(weaponentity).music_repeatend)
		{
			SKIP_NOTE;
		}
		else
		{
			this.(weaponentity).music_repeatend = mypos;
			mypos = this.(weaponentity).music_pos = (this.(weaponentity).music_repeatstart);
			note = argv(mypos);
		}
	}
	if(note == "|:")
	{
		this.(weaponentity).music_repeatstart = mypos;
		SKIP_NOTE;
	}

#undef SKIP_NOTE

	int slen = strlen(note);
	for(int j = 0; j < slen; ++j)
	{
		string curpos = substring(note, j, 1);
		int newchar = str2chr(curpos, 0);
		if(newchar >= 'a' && newchar <= 'g')
			playnote = newchar;
		else if(newchar == '+') // sharp
			playsharp += 0.5;
		else if(newchar == '-') // flat
			playsharp -= 0.5;
		else if(IS_DIGIT(curpos)) // octave
		{
			playoctave = stof(curpos);
			if(!playoctave)
				playoctave = -1; // TODO: actually handle lower octaves
		}
		else if(newchar == '<') // slower
			mspeed /= 2;
		else if(newchar == '>') // faster
			mspeed *= 2;
		else if(newchar == '.') // dotted
			mspeed -= (mspeed * 0.5);
		else if(newchar == '*') // triola
			mspeed *= 1.333;
	}

	// if there's no note just treat it like a space
	if(playnote)
	{
		// now for the uglies
		// TODO: doesn't actually work, the resulting pitches are off!
		if(playnote == 'f')
			playsharp -= 0.5;
		else if(playnote == 'a')
			playsharp += 0.5;
		else if(playnote == 'b')
			playsharp += 1;

		int note_index = note_from_char(playnote);
		int pitchnote = (note_index + playsharp);
		float r = 100 + (12.5 * pitchnote);
		if(playoctave)
			r *= (2 ** playoctave);
		Sound msound = this.(weaponentity).m_weapon.m_musicnote;
		if(msound && msound != SND_Null)
			sound7(this, CH_AMBIENT_SINGLE, Sound_fixpath(msound), 1, ATTN_NORM, r, 0);

		//if(random() <= 0.7)
		//{
			entity musicnote = new(musicnote);
			makevectors(this.v_angle);
			setorigin(musicnote, this.origin + v_forward * 45);
			_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
			vector mycolor;
			mycolor.x = max(0.25, random() * 5);
			mycolor.y = max(0.25, random() * 5);
			mycolor.z = max(0.25, random() * 5);
			musicnote.colormod = mycolor;
			musicnote.scale = 0.75;
			setsize(musicnote, '0 0 0', '0 0 0');
			musicnote.angles = '0 1 0' * this.angles_y;
			set_movetype(musicnote, MOVETYPE_NOCLIP);
			SUB_SetFade(musicnote, time + 0.1, 0.5);
			musicnote.velocity = '0 0 200';
		//}
	}

	this.(weaponentity).music_nextnote = time + (60 / mspeed);
	this.(weaponentity).music_pos += 1;

	if(this.(weaponentity).music_pos >= argc)
	{
		music_reset(this);
		return;
	}
}

void Music_Process(entity this, string input)
{
	.entity weaponentity = weaponentities[0]; // TODO?
	if(!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_MUSIC))
	{
		sprint(this, "You need to be holding an instrument to play music!\n");
		return;
	}
	int mspeed = stof(car(input));
	if(mspeed <= 0)
		mspeed = 60;
	mspeed = min(240, mspeed); // max 240 speed?
	string mymusic = cdr(input);

	// TODO: repeats? possibly with |: and :| to denote?
	this.(weaponentity).music_pos = 0;
	this.(weaponentity).music_speed = mspeed;
	this.(weaponentity).music_nextnote = time;
	this.(weaponentity).music_repeatstart = 0;
	this.(weaponentity).music_repeatend = 0;
	this.(weaponentity).music_starttime = time;
	strcpy(this.(weaponentity).music_song, mymusic);


	// attempt to copy the music playing position from a nearby player to keep songs in sync
	FOREACH_ENTITY_RADIUS(this.origin, 1024, IS_PLAYER(it) && it != this,
	{
		// TODO: compare length of music instead of music directly to allow different instrumentals for the same song?
		// TODO: song names?!
		if(it.(weaponentity).music_song == mymusic && it.(weaponentity).music_starttime > time)
		{
			this.(weaponentity).music_pos = it.(weaponentity).music_pos;
			this.(weaponentity).music_nextnote = it.(weaponentity).music_nextnote;
			this.(weaponentity).music_repeatstart = it.(weaponentity).music_repeatstart;
			this.(weaponentity).music_repeatend = it.(weaponentity).music_repeatend;
			break;
		}
	});
}

void Music_Copy(entity this)
{
	.entity weaponentity = weaponentities[0]; // TODO?
	if(!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_MUSIC))
	{
		sprint(this, "You need to be holding an instrument to play music!\n");
		return;
	}

	// copy the music of a nearby player
	FOREACH_ENTITY_RADIUS(this.origin, 1024, IS_PLAYER(it) && it != this,
	{
		if(!it.(weaponentity).music_pos)
			continue; // cheap escape
		this.(weaponentity).music_pos = it.(weaponentity).music_pos;
		this.(weaponentity).music_speed = it.(weaponentity).music_speed;
		this.(weaponentity).music_nextnote = it.(weaponentity).music_nextnote;
		this.(weaponentity).music_repeatstart = it.(weaponentity).music_repeatstart;
		this.(weaponentity).music_repeatend = it.(weaponentity).music_repeatend;
		this.(weaponentity).music_starttime = time;
		strcpy(this.(weaponentity).music_song, it.(weaponentity).music_song);
		break; // one song at a time thank you very much
	});
}

// This must be called in SV_ParseClientCommand
// input entity this
// input string cmd: same as in SV_ParseClientCommand
// output bool: true if command was handled, false if not
bool sv_music_command(entity this, string cmd, float argc)
{
	switch(cmd)
	{
		case "music":
		{
			string mymusic = strtolower(argv(1));
			if(mymusic == "")
			{
				Music_Copy(this);
				return true;
			}
			if(strlen(mymusic) > 16384)
			{
				sprint(this, "Song is too long!\n");
				return true;
			}
			Music_Process(this, mymusic);
			return true;
		}
	}
	return false;
}
#endif

#ifdef CSQC
STATIC_INIT_LATE(music_init)
{
	registercommand("music");
}

// This must be called in CSQC_ConsoleCommand
// input entity self
// input string cmd: same as in CSQC_ConsoleCommand
// output float: true if command was handled, false if not
bool cl_music_command(string cmd, string command)
{
	// cmd is actually argv(1)
	if(cmd == "music")
	{
		string mymusic = "";
		if(argv(1) == "help")
		{
			LOG_INFO("Usage: music 60 c d+ e< f g1");
			LOG_INFO("Music must always start with the speed it is to be played at, ranging from 1 to 240");
			LOG_INFO("Each note must be separated by a space to work properly");
			LOG_INFO("\nPossible options:");
			LOG_INFO("+ and - added to the note will make it sharp or flat respectively, e.g. b- will play B flat");
			LOG_INFO("< and > will make the note play longer or shorter respectively, e.g. with a song speed of 60 b> will play B at 120");
			LOG_INFO("_ can be used to denote a rest in the music, it will also support speed changes");
			LOG_INFO("|: and :| denote the start and end of a repeated section");
			LOG_INFO("Most signs can be stacked and will work in order they are used, e.g. b++<> will play a dotted minim B double sharp");
			return true;
		}
		else if(argv(1) != "")
			mymusic = substring(command, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)); // TODO: processing?
		else
		{
			LOG_INFO("Copying nearby players' music (if any)\nIf you were looking for instructions, do \"music help\"");
			localcmd("cmd music \"\"");
			return true;
		}
		if(strlen(mymusic) > 16384) // TODO: safer limit?!
		{
			LOG_INFO("Song is too long!");
			return true;
		}
		localcmd(strcat("cmd music \"", mymusic, "\"\n"));
		return true;
	}
	return false;
}
#endif
