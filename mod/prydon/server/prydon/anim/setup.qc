#include "setup.qh"

void set_frames(entity e)
{
	if(e.model == "progs/human.mdl")
	{
		// Chillo Model defaults
		e.player.attackscenes = 4;
		e.player.doubleattack = 7;
		e.player.cbowframes = 7;
		e.player.deathscenes = 3;
		e.player.dblattkscenes = 2;
		e.player.castscenes = 2;
		e.misc |= MISC_NO_SKINS;
	}
	if(!e.attackscenes)
		e.attackscenes = 1;
	if(!e.castscenes)
		e.castscenes = 1;
	if(!e.deathscenes)
		e.deathscenes = 1;
	if(!e.dblattkscenes)
		e.dblattkscenes = 1;
		
	if(!e.walkframes)
		e.walkframes = 6;
	if(!e.runframes)
		e.runframes = 6;
	if(!e.deathframes)
		e.deathframes = 6;
	if(!e.attackframes)
		e.attackframes = 7;
	if(!e.poseframes)
		e.poseframes = 6;
	if(!e.castframes)
		e.castframes = 8;
	if(!e.jumpframes)
		e.jumpframes = 6;
	if(!e.bowframes)
		e.bowframes = 7;
	if(!e.throwframes)
		e.throwframes = 4;
	// convert to a more usable form
	if(!e.hitframe)
		e.hitframe = e.attackframes - 2;
	e.attackframes *= e.attackscenes;
	e.deathframes *= e.deathscenes;
	e.castframes *= e.castscenes;
	e.doubleattack *= e.dblattkscenes;
	
	float w = e.walkframes;
	float r = w + e.runframes;
	float d = r + e.deathframes;
	float a = d + e.attackframes;
	float p = a + e.poseframes;
	float c = p + e.castframes;
	float j = c + e.jumpframes;
	float b = j + e.bowframes;
	float t = b + e.throwframes;
	float da = t + e.doubleattack;
	float cb = da + e.cbowframes;
	
	e.walkframes = w;
	e.runframes = r;
	e.deathframes = d;
	e.attackframes = a;
	e.poseframes = p;
	e.castframes = c;
	e.jumpframes = j;
	e.bowframes = b;
	e.throwframes = t;
	e.doubleattack = da;
	e.cbowframes = cb;
	
	if(!e.finddist)
		e.finddist = 256;
}
