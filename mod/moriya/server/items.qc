#include "items.qh"

#include "player.qh"
#include "scores.qh"
#include "triggers/subs.qh"

void item_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(edit_reset_timer.nextthink > time)
		return;
	
	pointparticles(EFFECT_COIN_PICKUP, this.origin + '0 0 16', '0 0 1', 1);
	increase_combo(toucher);
	fake_remove(this);
}

spawnfunc(item_coin)
{
	setmodel(this, MDL_COIN);
	setsize(this, '-20 -20 -16', '20 20 64');
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_NONE);
	settouch(this, item_touch);
	this.modelflags = MF_ROTATE;
	this.scale = 0.8;

	combo_max += 1;
}

void ring_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	
	game_over = true;

	int score = 0;
	if(STAT(COMBO_COUNT, toucher) >= combo_max)
		score = 4;
	else if(STAT(COMBO_COUNT, toucher) >= gold_goal)
		score = 3;
	else if(STAT(COMBO_COUNT, toucher) >= silver_goal)
		score = 2;
	else
		score = 1;
		
	write_scores(((getworldbasename() == "moriya") ? 0 : 1), cvar("skill") - 1, score);
	
	edit_reset_timer.nextthink = time + 3;
	setthink(edit_reset_timer, open_mission_select);
	
	// FIXME
	sound7(toucher, CHAN_VOICE, SND(YATTA_RANDOM()), 0.8, 0.5, 95 + random() * 10, 0);

	WriteHeader(MSG_BROADCAST, win);
	WriteByte(MSG_BROADCAST, score);
	
	fake_remove(this);
}

spawnfunc(item_ring)
{
	setmodel(this, MDL_RING);
	setsize(this, '-20 -20 -16', '20 20 64');
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_NONE);
	settouch(this, ring_touch);
	this.modelflags = MF_ROTATE;

	silver_goal = stof(this.target);
}
