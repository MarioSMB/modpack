#include "spirit.qh"

void spirit_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(edit_reset_timer.nextthink > time)
		return;
	
	toucher.velocity.z = 480;
	toucher.jumpcombo = 1;
	if(toucher.frame == 2)
		toucher.frame = 6;
	else
		toucher.frame = 2;
	increase_combo(toucher);
	
	sound7(toucher, CHAN_VOICE, SND(WAI), 0.5, 0.6 + random() * 0.3, 94 + random() * 12, 0);
	spawn_jump_ring(toucher.origin);
	
	pointparticles(EFFECT_SPIRIT_JUMP, this.origin, '0 0 1', 1);
	
	fake_remove(this);
}

spawnfunc(monster_spirit)
{
	setmodel(this, MDL_GHOST);
	setsize(this, '-20 -20 -16', '20 20 16');
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_NONE);
	settouch(this, spirit_touch);
	
	combo_max += 1;
}
