// main file containing stuff split from the main code base

PRECACHE(Hipnotic)
{
	precache_sound ("misc/flys.wav");
	precache_sound ("misc/shortexp.wav");
	precache_sound ("misc/longexpl.wav");
	precache_sound ("misc/foot1.wav");
	precache_sound ("misc/foot2.wav");
	precache_sound ("misc/foot3.wav");
	precache_sound ("misc/foot4.wav");
	precache_sound ("misc/foot5.wav");
	precache_sound ("misc/foot6.wav");
	precache_sound ("misc/foot7.wav");


	precache_model ("progs/playham.mdl");

	precache_model ("progs/v_laserg.mdl");
	precache_model ("progs/v_hammer.mdl");
	precache_model ("progs/v_prox.mdl");
	precache_model ("progs/proxbomb.mdl");

	precache_model ("progs/lasrspik.mdl");

	footsteps = cvar("g_footsteps");
}
