// main file containing stuff split from the main code base

PRECACHE(Hipnotic)
{
	if(!MP_HIPNOTIC)
		return;

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

	// weapons
	precache_sound("enforcer/enfstop.wav");   // laser cannon
	precache_sound("knight/sword1.wav");   // laser cannon
	precache_sound("hipweap/laserg.wav");   // laser cannon
	precache_sound("hipweap/laserric.wav");   // laser cannon ricochet
	precache_sound("hipweap/proxwarn.wav");   // proximity bomb
	precache_sound("hipweap/proxbomb.wav");   // proximity bomb
	precache_sound("hipweap/mjolhit.wav");   // mjolnir
	precache_sound("hipweap/mjolslap.wav");   // mjolnir
	precache_sound("hipweap/mjoltink.wav");   // mjolnir
}
