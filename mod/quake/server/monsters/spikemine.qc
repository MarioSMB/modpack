/*
==============================================================================

spike mine

==============================================================================
*/

$cd id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

#if 0
const int spike_anim_stand1 = 0;
const int spike_anim_stand2 = 1;
const int spike_anim_stand3 = 2;
const int spike_anim_stand4 = 3;
const int spike_anim_stand5 = 4;
const int spike_anim_stand6 = 5;
const int spike_anim_stand7 = 6;
const int spike_anim_stand8 = 7;
const int spike_anim_stand9 = 8;
const int spike_anim_stand10 = 9;
const int spike_anim_stand11 = 10;
const int spike_anim_stand12 = 11;
const int spike_anim_stand13 = 12;

const int spike_anim_walk1 = 13;
const int spike_anim_walk2 = 14;
const int spike_anim_walk3 = 15;
const int spike_anim_walk4 = 16;
const int spike_anim_walk5 = 17;
const int spike_anim_walk6 = 18;
const int spike_anim_walk7 = 19;
const int spike_anim_walk8 = 20;

const int spike_anim_run1 = 21;
const int spike_anim_run2 = 22;
const int spike_anim_run3 = 23;
const int spike_anim_run4 = 24;
const int spike_anim_run5 = 25;
const int spike_anim_run6 = 26;

const int spike_anim_leap1 = 27;
const int spike_anim_leap2 = 28;
const int spike_anim_leap3 = 29;
const int spike_anim_leap4 = 30;
const int spike_anim_leap5 = 31;
const int spike_anim_leap6 = 32;
const int spike_anim_leap7 = 33;
const int spike_anim_leap8 = 34;
const int spike_anim_leap9 = 35;
const int spike_anim_leap10 = 36;
const int spike_anim_leap11 = 37;
const int spike_anim_leap12 = 38;

const int spike_anim_pain1 = 39;
const int spike_anim_pain2 = 40;
const int spike_anim_pain3 = 41;
const int spike_anim_pain4 = 42;
const int spike_anim_pain5 = 43;
const int spike_anim_pain6 = 44;

const int spike_anim_death1 = 45;
const int spike_anim_death2 = 46;
const int spike_anim_death3 = 47;
const int spike_anim_death4 = 48;
const int spike_anim_death5 = 49;
const int spike_anim_death6 = 50;
const int spike_anim_death7 = 51;
const int spike_anim_death8 = 52;
const int spike_anim_death9 = 53;

const int spike_anim_attacka1 = 54;
const int spike_anim_attacka2 = 55;
const int spike_anim_attacka3 = 56;
const int spike_anim_attacka4 = 57;
const int spike_anim_attacka5 = 58;
const int spike_anim_attacka6 = 59;
const int spike_anim_attacka7 = 60;
const int spike_anim_attacka8 = 61;
const int spike_anim_attacka9 = 62;
const int spike_anim_attacka10 = 63;
const int spike_anim_attacka11 = 64;
const int spike_anim_attacka12 = 65;
const int spike_anim_attacka13 = 66;
const int spike_anim_attacka14 = 67;
const int spike_anim_attacka15 = 68;
#endif

// apparently, the animations were unused anyway
#if 0
const int spike_anim_stand = 0; //'0 12 0';
const int spike_anim_walk = 13; //'13 20 0';
const int spike_anim_run = 21; //'21 26 0';
const int spike_anim_leap = 27; //'27 38 0';
const int spike_anim_pain = 39; //'39 44 0';
const int spike_anim_death = 45; //'45 53 0';
const int spike_anim_attacka = 54; //'54 68 0';
#endif

spawnfunc(monster_spikemine)
{
	if(deathmatch) { delete(this); return; }

	precache_model("progs/demon.mdl");
	precache_model("progs/h_demon.mdl");

	precache_sound("demon/ddeath.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("demon/djump.wav");
	precache_sound("demon/dpain1.wav");
	precache_sound("demon/idle1.wav");
	precache_sound("demon/sight2.wav");

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/demon.mdl");

	setsize(this, '-32 -32 -24', '32 32 64');
}
