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

void x_cartoonburst4(entity this) { this.frame = 6; this.nextthink = time + 0.025; setthink(this, SUB_Remove); }
void x_cartoonburst3(entity this) { this.frame = 4; this.nextthink = time + 0.025; setthink(this, x_cartoonburst4); }
void x_cartoonburst2(entity this) { this.frame = 2; this.nextthink = time + 0.025; setthink(this, x_cartoonburst3); }
void x_cartoonburst1(entity this) { this.frame = 0; this.nextthink = time + 0.025; setthink(this, x_cartoonburst2); }

void BecomeCartoonExplosion(entity this)
{
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/x9_burst_6sided_brightyellow.mdl"); // TODO: white version for easy coloring
	setsize(newmis, '0 0 0', '0 0 0');
	//setorigin(newmis, findbetterlocation(this.origin, 8));
	setorigin(newmis, this.origin); // most calls to this already adjust position
	newmis.angles = this.angles;
	newmis.colormod = this.colormod;
	x_cartoonburst1(newmis);

	delete(this);
}

void MusicNoteBounceTouch(entity this, entity toucher) // MUSIC NOTE TOUCH ENEMY / WORLD ------------------------------------------------------------------------------
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}   
	
	if(toucher.takedamage) // if it bleeds...
	{
		//spawn_touchblood (1);
		float damg = (this.dmg) ? this.dmg : 27;
		T_Damage(toucher, this, this.owner, damg * 0.5, WEP_PIANO.m_id); // DIRECT Damage

		this.angles = vectoangles(this.velocity);
		BecomeCartoonExplosion(this);
		
		return;         
	}
	
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0'; // Bounce?
}

void MusicNoteTouch(entity this, entity toucher) // MUSIC NOTE TOUCH ENEMY / WORLD ------------------------------------------------------------------------------
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}   
	
	if(toucher.takedamage) // if it bleeds...
	{
		//spawn_touchblood (1);
		float damg = (this.dmg) ? this.dmg : 27;
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype); // DIRECT Damage

		this.angles = vectoangles(this.velocity);
		BecomeCartoonExplosion(this);
		return;         
	}
	
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0'; // Bounce?
	else
	{
		//_setmodel(this, "progs/piano_musicnote_brown.mdl");
		//setsize(this, '0 0 0', '0 0 0');
		vector col = this.colormod;
		this.colormod.x = col.z;
		this.colormod.y = col.y;
		this.colormod.z = col.z;
		settouch(this, MusicNoteBounceTouch);	
	}
}
