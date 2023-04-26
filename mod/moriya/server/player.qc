#include "player.qh"

void increase_combo_time(entity this, float amount)
{
	if(STAT(COMBO_COUNT, this) <= 0)
		return;
	if(time > STAT(COMBO_TIMER, this))
		STAT(COMBO_TIMER, this) = time + amount + 0.2;
	else
		STAT(COMBO_TIMER, this) += amount + 0.2;
	if(STAT(COMBO_TIMER, this) > (time + combo_timer_max))
		STAT(COMBO_TIMER, this) = time + combo_timer_max;
}

void increase_combo(entity this)
{
	STAT(COMBO_COUNT, this) += 1;
	increase_combo_time(this, 2);
	if(STAT(COMBO_COUNT, this) <= 10)
		sound7(this, CHAN_AUTO, SND(BONK), 0.5, 0.5, 80 + STAT(COMBO_COUNT, this) * 2, 0);
	else
		sound7(this, CHAN_AUTO, SND(BONK), 0.5, 0.5, 100 + STAT(COMBO_COUNT, this) * 1, 0);
}

void reset_combo(entity this)
{
	STAT(COMBO_COUNT, this) = 0;
	STAT(COMBO_TIMER, this) = 0;
}

void reset_combo_ents()
{
	editor_reset();
	editor_play();
}

STATIC_INIT_LATE(edit_reset_timer)
{
	edit_reset_timer = new_pure(edit_reset_timer);
}
