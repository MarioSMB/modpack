void() dialog = 
{
	if (cache)
		if (self.voice)
			precache_sound(self.voice);

	self.use = dialog;
	self.rand_trig = 1;
	if (activator == world)
		return;
	// default.

	
	if (self.voice)
		sound(activator, CHAN_VOICE, self.voice, 1, ATTN_NORM);
	other.m_targ = self;
	openmenu(other, m_dialog, activator);
};


void() opendialog = 
{
	entity e;
	
	e = other.owner.m_targ;
	if (e)
		return;
	
	if (!RequirementsMet(self, other))
	{
		if (self.v_angle == rq_vars && rq_vars != '0 0 0')
		{
			openmenu(other, m_rqcancel, self);
			return;
		}
		else
			prompt(other.owner, "This character doesn't\nwant to talk to you", other.owner, 2);
		return;
	}

	other.owner.m_targ = self;
	if (other.owner.m_targ.voice)
		sound(self, CHAN_VOICE, other.owner.m_targ.voice, 1, ATTN_NORM);
	openmenu(other, m_dialog, self);

};
