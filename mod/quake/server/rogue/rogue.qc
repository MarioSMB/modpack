#include "rogue.qh"

// main file for the rogue mission pack

STATIC_INIT(rogue_fixguardian)
{
	cvar_settemp("sv_gameplayfix_q1bsptracelinereportstexture", "0"); // fixes a collision bug in Xonotic

	// copied fix from darkplaces, which disables this setting when rogue game is detected
	if(IsRogueMap())
		cvar_settemp("sv_gameplayfix_findradiusdistancetobox", "0");
	else
		cvar_settemp("sv_gameplayfix_findradiusdistancetobox", "1");
}

PRECACHE(Rogue)
{
	precache_sound("enforcer/enfstop.wav");    // shield impact
	precache_sound("plasma/explode.wav");
	precache_sound("plasma/flight.wav");			
	precache_sound("plasma/fire.wav");
	precache_sound("shield/hit.wav");
	precache_sound("belt/use.wav");
	precache_sound("items/damage2.wav");

	// Lava Gun models - pgm change
	precache_model("progs/v_lava.mdl");
	precache_model("progs/v_lava2.mdl");
	precache_model("progs/v_multi.mdl");
	precache_model("progs/v_multi2.mdl");

	// PGM addition
	precache_model("progs/mervup.mdl");
	precache_model("progs/rockup.mdl");
	precache_model("progs/rockup_d.mdl");
	precache_model("progs/lspike.mdl");
	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");

	precache_model("progs/plasma.mdl");
	precache_model("progs/v_plasma.mdl");

	// hook for CTF
	precache_model("progs/hook.mdl");
	precache_model("progs/v_grpple.mdl");


	// weapons
	// grapple
	//precache_sound("weapons/chain1.wav");
//	precache_sound("weapons/chain2.wav");
//	precache_sound("weapons/chain3.wav");
//	precache_sound("weapons/bounce2.wav");
//	precache_sound("blob/land1.wav");
	precache_sound("pendulum/hit.wav");

	precache_sound ("lavagun/snail.wav");		// lava nail gun cooldown
}
