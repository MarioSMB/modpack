#include "music.qh"

#ifdef SVQC
PRECACHE(Music)
{
	precache_model("progs/piano_musicnote_white.mdl");
}

#define MIDI_SUPPORT
#ifdef MIDI_SUPPORT
void midi_reset(entity this);
#endif
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

#ifdef MIDI_SUPPORT
	midi_reset(this);
#endif
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

void music_makenote(entity this)
{
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

	// also play the instrument if we can
	if(IS_PLAYER(this))
	{
		.entity weaponentity = weaponentities[0]; // TODO?
		if(this.(weaponentity) && time > this.(weaponentity).weapon_nextthink)
			wep_generic_rocket1(this.(weaponentity));
	}
}

#ifdef MIDI_SUPPORT
const int MIDI_TRACKS = 17; // must be up by 1 since MIDI isn't zero-indexed
.int midi_buffer[MIDI_TRACKS];
.int midi_buffersize[MIDI_TRACKS];
void midi_frame(entity this);
#endif

void CreatureFrame_Music(entity this)
{
#ifdef MIDI_SUPPORT
	// MIDIs always have a 0 track (TODO: safer method of checking?)
	if(this.midi_buffersize[0] > 0)
	{
		midi_frame(this);
		return;
	}
#endif

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
		if(this.(weaponentity).m_weapon.m_nopitch)
			r = 100 / bound(0.8, random() * 2, 1.3);
		Sound msound = this.(weaponentity).m_weapon.m_musicnote;
		if(msound && msound != SND_Null)
			sound7(this, CH_AMBIENT_SINGLE, Sound_fixpath(msound), 1, ATTN_NORM, r, 0);

		//if(random() <= 0.7)
		//{
			music_makenote(this);
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

#ifdef MIDI_SUPPORT
bool midi_copy(entity this, entity from);
#endif
void Music_Copy(entity this)
{
	.entity weaponentity = weaponentities[0]; // TODO?
	if(!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_MUSIC))
	{
		sprint(this, "You need to be holding an instrument to play music!\n");
		return;
	}

	// copy the music of a nearby player
	FOREACH_CLIENT(IS_PLAYER(it) && it != this,
	{
#ifdef MIDI_SUPPORT
		if(midi_copy(this, it))
			break;
#endif

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

#ifdef MIDI_SUPPORT
// midi_buffer defined above
// midi_buffersize defined above
.int midi_division;
.int midi_tempo;
.int midi_tracks;
.int midi_time; // current Time, increments by 1 each frame
.float midi_tictime; // internal timer between midi frames
.int midi_pos[MIDI_TRACKS]; // current buffer position
.int midi_nexttime[MIDI_TRACKS]; // storage of the upcoming timer to save needing to check it every frame
.int midi_volume[MIDI_TRACKS]; // the rough volume set by Control_c, may be unset

.float midi_lastnote; // prevent spamming too many note models!

void midi_reset(entity this)
{
	this.midi_division = 0;
	this.midi_tempo = 0;
	this.midi_tracks = 0;
	this.midi_tictime = 0;
	this.midi_time = 0;
	for(int track = 0; track < MIDI_TRACKS; ++track)
	{
		if(this.midi_buffersize[track] > 0)
			buf_del(this.midi_buffer[track]);
		this.midi_buffer[track] = -1;
		this.midi_buffersize[track] = 0;
		this.midi_pos[track] = 0;
		this.midi_nexttime[track] = 0;
	}
	//LOG_INFO("RESET");
}

// TODO: buf_copy is broken?
void midi_buffer_copy(int src, int dst)
{
	int bsize = buf_getsize(src);

	for(int j = 0; j < bsize; ++j)
	{
		string s = bufstr_get(src, j);
		bufstr_set(dst, j, s);
	}
}

bool midi_copy(entity this, entity from)
{
	if(from.midi_buffersize[0] <= 0)
		return false;

	midi_reset(this);

	this.midi_division = from.midi_division;
	this.midi_tempo = from.midi_tempo;
	this.midi_tracks = from.midi_tracks;
	this.midi_tictime = from.midi_tictime;
	this.midi_time = from.midi_time;

	for(int track = 0; track <= from.midi_tracks; ++track)
	{
		int buf = buf_create();
		midi_buffer_copy(from.midi_buffer[track], buf);
		this.midi_buffer[track] = buf;
		this.midi_buffersize[track] = from.midi_buffersize[track];

		this.midi_nexttime[track] = from.midi_nexttime[track];
		this.midi_pos[track] = from.midi_pos[track];
	}

	return true;
}

// written by YuxiUx
// https://gist.github.com/YuxiUx/ef84328d95b10d0fcbf537de77b936cd
float noteToFreq(int note)
{
	float a = 100; //frequency of A (coomon value is 440Hz)
	return (a / 32) * pow(2, ((note - 9) / 12.0));
}

void midi_track_frame(entity this, int track)
{
	if(this.midi_buffersize[track] <= 0)
		return;
	if(this.midi_pos[track] >= this.midi_buffersize[track])
		return;

	// hack to save looping every frame
	// wait until time has caught up if we find a frame higher than time
	if(this.midi_nexttime[track] && this.midi_time < this.midi_nexttime[track])
		return;

	this.midi_nexttime[track] = 0;

	.entity weaponentity = weaponentities[0]; // TODO?

	for(int j = this.midi_pos[track]; j < this.midi_buffersize[track]; ++j)
	{
		string s = bufstr_get(this.midi_buffer[track], j);

		tokenizebyseparator(s, ", ");
		//int Track = stoi(argv(0));
		int Time = stoi(argv(1));
		string Type = argv(2);

		if(Time)
			Time = floor(Time * PHYS_INPUT_FRAMETIME * 16 * (120 / this.midi_division));

		if(this.midi_time < Time)
		{
			this.midi_nexttime[track] = Time;
			break;
		}

		// keep pos updated to last valid entry
		this.midi_pos[track] = j + 1;

		switch(Type)
		{
			// File Structure Records TODO: move to a structure handler?
			case "End_of_file": // not handled this way TODO?
			case "Header": // WTF
			// End_of_file handled above
			case "Start_track": // TODO: tracks?
			case "End_track":
			// File Meta-Events
			case "Title_t":
			case "Copyright_t":
			case "Instrument_name_t": // TODO? we could guess instruments
			case "Marker_t":
			case "Cue_point_t":
			case "Lyric_t":
			case "Text_t":
			case "Sequence_number": // TODO? not sure what this actually is
			case "MIDI_port":
			case "Channel_prefix":
			case "Time_signature": // TODO?
			case "Key_signature": // TODO?
			// Tempo handled below
			case "SMPTE_offset":
			case "Sequencer_specific":
			case "Unknown_meta_event":
			// Channel Events
			case "Pitch_bend_c": // TODO
			// Control_c handled below
			case "Program_c":
			case "Channel_aftertouch_c":
			case "Poly_aftertouch_c":
			// System Exclusive Events
			case "Poly_aftertouch_c":
				break;
			case "Control_c":
			{
				// 1 (modulation), 7 (volume), 10 (pan), 11 (expression), and 64 (sustain)
				// 91 (reverberation), 93 (chorus)
				int Control_num = stoi(argv(4));
				int Value = stoi(argv(5));
				if(Control_num == 7)
					this.midi_volume[track] = Value;
				break;
			}
			case "Tempo":
			{
				this.midi_tempo = stoi(argv(3));
				break;
			}
			case "Note_on_c":
			{
				//LOG_INFO("Note: ", s);
				//int Channel = stoi(argv(3));
				int Note = stoi(argv(4));
				int Velocity = stoi(argv(5));

				// A Note_on_c event with Velocity zero is equivalent to a Note_off_c
				if(Velocity == 0)
					continue; // TODO: actually stop the sound, if we get looped sounds
				if(this.(weaponentity).m_weapon.m_nopitch)
					Note = 100 / bound(0.8, random() * 2, 1.3);
				else
				{
					Note = noteToFreq(Note);
					//LOG_INFO("Pitch: ", ftos(Note));
				}

				Sound msound = this.(weaponentity).m_weapon.m_musicnote;
				if(msound && msound != SND_Null)
				{
					// volume is scaled by 127 to keep the maximum within the 0-1 limit of DarkPlaces
					int midivolume = bound(0, this.midi_volume[track], 127);
					// default to volume 1 otherwise
					float vol = (midivolume > 0) ? (midivolume / 127) : 1;
					sound7(this, CH_AMBIENT, Sound_fixpath(msound), vol, ATTN_NORM, Note, 0);
				}
				if(time >= this.midi_lastnote)
				{
					this.midi_lastnote = time + 0.1;
					music_makenote(this);
				}
				break;
			}
			case "Note_off_c":
				break; // TODO: loop sounds, cancel track's channel when stopping sound?
		}
	}
}

void midi_frame(entity this)
{
	if(time < this.midi_tictime)
		return;

	.entity weaponentity = weaponentities[0]; // TODO?
	if(!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_MUSIC))
	{
		music_reset(this);
		return;
	}

	float ticks = this.midi_tempo / this.midi_division;
	ticks /= 1000000;
	this.midi_tictime = time + ticks;

	//LOG_INFOF("%d %d", this.midi_tictime, this.midi_time);

	int completed = 0;
	for(int track = 0; track <= this.midi_tracks; ++track)
	{
		midi_track_frame(this, track);
		if(this.midi_pos[track] >= this.midi_buffersize[track])
			completed += 1;
	}

	// must be above since we count 0
	if(completed > this.midi_tracks)
	{
		music_reset(this);
		return;
	}

	this.midi_time += 1;
}

void midi_process(entity this, string input)
{
	.entity weaponentity = weaponentities[0]; // TODO?
	if(!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_MUSIC))
	{
		sprint(this, "You need to be holding an instrument to play music!\n");
		return;
	}

	int fh = fopen(input, FILE_READ);
	if(fh < 0)
	{
		sprint(this, "File does not exist on the server, sorry!\n");
		return;
	}

	music_reset(this);

	bool header_done = false;

	string s;
	while((s = fgets(fh)))
	{
		// first word (minus ,) is the track number
		int tracknum = stoi(substring(car(s), 0, -2));

		// Header
		// cheaper to check this way, but may be inaccurate for broken MIDIs
		if(!header_done)
		{
			header_done = true;
			//LOG_INFO("Doing setup");
			tokenizebyseparator(s, ", ");
			//int Track = stoi(argv(0));
			//int Time = stoi(argv(1));
			//string Type = argv(2);
			//int format = stoi(argv(3));
			int nTracks = stoi(argv(4));
			int division = stoi(argv(5));

			this.midi_division = division;
			this.midi_tracks = nTracks;

			for(int track = 0; track <= this.midi_tracks; ++track)
			{
				this.midi_buffer[track] = buf_create();
			}
		}

		// currently EOF is handled by reaching it rather than counting indexes
		if(s == "0, 0, End_of_file")
			continue;

		bufstr_set(this.midi_buffer[tracknum], this.midi_buffersize[tracknum], s);
		this.midi_buffersize[tracknum] += 1;
	}

	fclose(fh);

	// default division is 120
	if(!this.midi_division)
		this.midi_division = 120;
	// default tempo is 500000
	this.midi_tempo = 500000;

	this.midi_tictime = time;
}
// NOTE: disabled until bigger files can be opened
#if 0
void midi_process_url(entity this, entity fh)
{
	music_reset(this);

	bool header_done = false;

	string s;
	while((s = url_fgets(fh)))
	{
		// first word (minus ,) is the track number
		int tracknum = stoi(substring(car(s), 0, -2));

		// Header
		// cheaper to check this way, but may be inaccurate for broken MIDIs
		if(!header_done)
		{
			header_done = true;
			if(substring(s, 0, 12) != "0, 0, Header")
			{
				header_done = false;
				break;
			}
			//LOG_INFO("Doing setup");
			tokenizebyseparator(s, ", ");
			//int Track = stoi(argv(0));
			//int Time = stoi(argv(1));
			//string Type = argv(2);
			//int format = stoi(argv(3));
			int nTracks = stoi(argv(4));
			int division = stoi(argv(5));

			this.midi_division = division;
			this.midi_tracks = nTracks;

			for(int track = 0; track <= this.midi_tracks; ++track)
			{
				this.midi_buffer[track] = buf_create();
			}
		}

		// currently EOF is handled by reaching it rather than counting indexes
		if(s == "0, 0, End_of_file")
			continue;

		bufstr_set(this.midi_buffer[tracknum], this.midi_buffersize[tracknum], s);
		this.midi_buffersize[tracknum] += 1;
	}

	url_fclose(fh);

	// aborted early or didn't even find a header
	if(!header_done)
	{
		sprint(this, "Not a valid MIDI text!\n");
		return;
	}

	// default division is 120
	if(!this.midi_division)
		this.midi_division = 120;
	// default tempo is 500000
	this.midi_tempo = 500000;

	this.midi_tictime = time;
}
void midi_url_onget(entity fh, entity this, int status)
{
	switch(status)
	{
		case URL_READY_CLOSED:
		{
			break;
		}
		case URL_READY_ERROR:
		{
			sprint(this, "Could not read a MIDI text from the given URL\n");
			break;
		}
		case URL_READY_CANREAD:
		{
			midi_process_url(this, fh);
			break;
		}
		default:
		{
			break;
		}
	}
}

void midi_openurl(entity this, string url)
{
	.entity weaponentity = weaponentities[0]; // TODO?
	if(!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_MUSIC))
	{
		sprint(this, "You need to be holding an instrument to play music!\n");
		return;
	}

	sprint(this, "Attempting to load MIDI text, please wait...\n");

	url_single_fopen(url, FILE_READ, midi_url_onget, this);
}
#endif
#endif

#ifdef MIDI_SUPPORT
.float last_midicheck;
#endif

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
#ifdef MIDI_SUPPORT
			if(mymusic == "list")
			{
				if(time < this.last_midicheck)
				{
					sprint(this, "Hey you - no spamming!\n");
					return true;
				}
				this.last_midicheck = time + 3;
				int dh = search_begin("midis/*.txt", false, true);
				if(dh < 0)
					return true;
				string output = "";
				int n = search_getsize(dh);
    			for (int i = 0; i < n; ++i)
    			{
    				string s = search_getfilename(dh, i);
    				s = substring(s, 6, -5); // no extension
    				output = cons(output, strcat(s, "\n"));
    			}
    			sprint(this, strcat("List of MIDIs:\n ", output));
				return true;
			}
#if 0
			if(strstrofs(mymusic, "://", 0) >= 0)
			{
				midi_openurl(this, argv(1));
				return true;
			}
#endif
			string midi_test = strcat("midis/", MakeConsoleSafe(argv(1)), ".txt");
			if(fexists(midi_test))
			{
				midi_process(this, midi_test);
				return true;
			}
#endif
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
