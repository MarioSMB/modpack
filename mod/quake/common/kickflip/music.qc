#include "music.qh"

#ifdef SVQC
#if 0
PRECACHE(music)
{
	precache_sound("track1.wav");
	precache_sound("track2.wav");
}

void music_repeat(entity this)
{
	//damn ambientsound doesn't work !
	//ambientsound (this.origin, "track1.wav", 1, ATTN_IDLE);
	
	if(cvar("temp1") && 1)	//music is disabled, return
		return;

	current_track = current_track + 1;	
	if(current_track > 2)
		current_track = 1;

	if(current_track == 1)			//Track: Undead's smooth drum'n bass track
	{
		_sound(this, CH_BGM_SINGLE, "track1.wav", 1, ATTN_NONE);
		this.nextthink = time + 29.99;		//that's the length of the track
	}
	else if(current_track == 2)		//Track: hit the road jack
	{
		_sound(this, CH_BGM_SINGLE, "track2.wav", 1, ATTN_NONE);
		this.nextthink = time + 30;		//that's the length of the track
	}
	
	setthink(this, music_repeat);
}

STATIC_INIT_LATE(create_music)
{
	current_track = floor(random() * 2);

	entity music = spawn();
	music.origin = '0 0 0';
	set_movetype(music, MOVETYPE_NONE);
	music.solid = SOLID_NOT;
	music.classname = "music";
	setthink(music, music_repeat);
	music.nextthink = time + 1;			//start music in 1 second
}
#endif

#endif
