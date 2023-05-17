#include "dialog.qh"

#include "../subs/reqs.qh"

void dialog(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;

	if(this.voice)
		_sound(actor, CH_VOICE, this.voice, 1, ATTN_NORM);
	trigger.m_targ = this;
	openmenu(trigger, m_dialog, actor);
}

spawnfunc(dialog)
{
	if(cache && this.voice)
		precache_sound(this.voice);

	this.use = dialog;
	this.rand_trig = 1;
}

void opendialog(entity this, entity targ)
{
	entity e = targ.owner.m_targ;
	if(e)
		return;
	
	if(!RequirementsMet(this, targ))
	{
		if(this.v_angle == rq_vars && rq_vars != '0 0 0')
		{
			openmenu(targ, m_rqcancel, this);
			return;
		}
		else
			prompt(targ.owner, "This character doesn't\nwant to talk to you", targ.owner, 2);
		return;
	}

	targ.owner.m_targ = this;
	if(targ.owner.m_targ.voice)
		_sound(this, CH_VOICE, targ.owner.m_targ.voice, 1, ATTN_NORM);
	openmenu(targ, m_dialog, this);
}
