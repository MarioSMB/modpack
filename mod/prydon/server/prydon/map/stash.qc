#include "stash.qh"

#include "../subs/data.qh"

void close_monitor(entity this)
{
	float f;
	if(this.m_subject)
		f = 1;
	else
		f = 0;
	if(this.frame != f)
	{
		_sound(this, CHAN_AUTO, this.noise, 1, ATTN_NORM);
		this.frame = f;
	}
	this.nextthink = time + 1;
}

spawnfunc(stash_chest)
{
	if(!fileaccess)
	{
		delete(this);
		return;
	}
	if(!this.model)
		this.model = "progs/chest.mdl";
	precache_model(this.model);
	if(!this.noise)
		this.noise = "misc/chest.wav";
	precache_sound(this.noise);
	_setmodel(this, this.model);
	setsize(this, '-16 -16 0', '16 16 16');
	this.effects = EF_SELECTABLE;

	this.classname	= "chest";
	if(!this.netname)
		this.netname = "Community Chest";
	if(!this.message)
		this.message = "This is the community chest";
	if(!this.message1)
	{
		this.message1 = "Deposit ";
		this.target1 = "m_deposit";
	}
	if(!this.message2)
	{
		this.message2 = "Withdraw";
		this.target2 = "m_withdraw";
	}
	if(!this.message3)
	{
		this.message3 = "Exit    ";
		this.target3 = "m_exit";
	}
	this.owner = this;
	set_movetype(this, MOVETYPE_TOSS);
	this.solid	= SOLID_BBOX;
	this.action = opensign;
	setthink(this, close_monitor);
	this.nextthink = time + 1;
	this.misc = MISC_SAVE_INVENTORY;
	datacheck(this);
}
