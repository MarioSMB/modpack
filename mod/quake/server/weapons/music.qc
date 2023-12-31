#include "music.qh"

float autocvar_sv_quake_music_pitch_max = 270;
float autocvar_sv_quake_music_pitch_min = 1;
float autocvar_sv_quake_music_pitch_offset = 180;
bool autocvar_sv_quake_music_random = true;

float W_Music_PitchFromAngles(float pitchang, float rndoffset)
{
	if(autocvar_sv_quake_music_random)
		return 100 / rndoffset;
	pitchang = bound(-90, pitchang, 90); // no spinners sorry!
	pitchang *= -1; // pitch angle is inversed
	float newpitch = bound(autocvar_sv_quake_music_pitch_min, pitchang + autocvar_sv_quake_music_pitch_offset, autocvar_sv_quake_music_pitch_max);
	//LOG_INFO("Pitch angle: ", ftos(pitchang), ", pitch: ", ftos(newpitch));
	return newpitch;
}
