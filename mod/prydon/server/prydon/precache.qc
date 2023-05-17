#include "precache.qh"

#include "items/itemstat.qh"

PRECACHE(precaches)
{
	precache_model("progs/player.mdl");
	precache_model("progs/human.mdl");
	precache_model("progs/null.spr");
	precache_model("progs/s_explod.spr");
	precache_model("progs/arrow.mdl"); 
	
	// cursor test
	precache_model("progs/cursor.spr");
	//precache_model("gfx/cursor.spr");
	//precache_model("gfx/inv.spr");
	// precache all items
	for (int i = 1; i <= BASEITEMS; i = i + 1) // number of base items
		precache_model(itemmodel(i));
//	for (int i = 1; i <= BASEITEMS; i = i + 1) // number of base items
//		precache_model(it_itemicon(i));
	for (int i = 1; i <= BASEITEMS; i = i + 1) // number of base items
		precache_sound(itemsound(i));

	precache_sound("items/flip.wav");
	precache_sound("demon/dland2.wav");
	precache_sound("misc/h2ohit1.wav");
	precache_sound("misc/r_tele1.wav");
	precache_sound("misc/r_tele2.wav");
	precache_sound("misc/r_tele3.wav");
	precache_sound("misc/r_tele4.wav");
	precache_sound("misc/r_tele5.wav");
	precache_sound("player/step1.wav");
	precache_sound("player/step2.wav");
	precache_sound("player/wstep1.wav");
	precache_sound("player/wstep2.wav");
	precache_sound("player/axhit1.wav");
	precache_sound("player/death1.wav");
	precache_sound("player/swing.wav");
	precache_sound("player/arrowhit.wav");
	precache_sound("player/arrowuse.wav");
	precache_sound("player/levelup.wav");
	precache_sound("player/break.wav");
	precache_sound("player/hit.wav");
	precache_sound("misc/null.wav");
	precache_model("progs/w_spike.mdl");
	precache_model("progs/fball.mdl");
	precache_model("progs/fire.spr");
	precache_model("progs/mshield.mdl");
	precache_model("progs/critical.spr");
	precache_model("progs/cresent.spr");
	precache_sound("spells/fball.wav");
	precache_sound("spells/heal.wav");
	precache_sound("spells/fhit.wav");
	precache_sound("spells/lhit.wav");
	precache_sound("spells/lit.wav");
	precache_sound("spells/freeze.wav");
	precache_sound("spells/shatter.wav");
	precache_sound("spells/launch.wav");
	precache_sound("spells/leech.wav");
	precache_sound("spells/warp.wav");
	precache_sound("spells/shield.wav");
	precache_sound("spells/pfire.wav");
	precache_sound("wizard/hit.wav");
	precache_sound("spells/tranmute.wav");
	precache_sound("spells/evile.wav");
	precache_sound("spells/repel.wav");
	precache_sound("spells/nova.wav");
	precache_sound("spells/freeze.wav");
	precache_sound("spells/shatter.wav");
	precache_model("progs/icicle.mdl");
	precache_model("progs/frozen.mdl");
	precache_model("progs/frozen2.mdl");
	precache_model("progs/frozen3.mdl");
	precache_model("progs/blod.mdl");	
	precache_model("progs/evile.spr");
	precache_model("progs/poison.spr");
	precache_model("progs/nova.mdl");
	precache_model("progs/twister.mdl");
	precache_sound("spells/twist.wav");
	precache_model("progs/meteor.mdl");
	precache_sound("spells/meteor1.wav");
	// summon:
	precache_model("progs/skuttler.mdl");
	precache_sound("skuttler/attack.wav");
	precache_sound("skuttler/hit.wav");
	precache_sound("skuttler/die.wav");
	precache_model("progs/horror.mdl");
	precache_sound("horror/attack.wav");
	precache_sound("horror/hit.wav");
	precache_sound("horror/die.wav");
	precache_sound("player/block.wav");
}
