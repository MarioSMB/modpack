void opensign(entity this, entity targ)
{
	opendialog(this, targ);
	generictrigger(this, targ);
}

void donothing(entity this, entity targ)
{
}

void sign_use(entity this, entity actor, entity trigger)
{
	openmenu(activator.owner, m_dialog, this);
}

spawnfunc(sign)
{
	if(CheckStory(this))
	{
		remove(this);
		return;
	}

	if(!this.netname)
		this.netname = "A Sign";
	datacheck(this);
	_setmodel(this, this.model);
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BBOX;
	this.use = sign_use;
	setorigin(this, this.origin);
	if(this.message)
		this.action = opensign;
	else
		this.action = donothing;
	this.effects = EF_SELECTABLE;
}

void() close_book =
{
	if(!this.m_subject)
	{
		sound(this, CHAN_AUTO, "items/scroll.wav", 1, ATTN_NORM);
		this.frame = 0;
	}
	else
		this.nextthink = time + 1;
}

void openbook(entity this, entity targ)
{
	if(this.attack_finished > time)
		return;
	_sound(this, CHAN_AUTO, "items/scroll.wav", 1, ATTN_NORM);
	this.attack_finished = time + 1;
	this.frame = this.hitframe;
	setthink(this, close_book);
	this.nextthink = time + 1;
	opendialog(this, targ);
	
	generictrigger(this, targ);
}

spawnfunc(storybook)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}

	if(!this.netname)
		this.netname = "A Book";
	this.effects = EF_SELECTABLE;
	datacheck(this);
	if(!this.model)
	{
		this.model = "progs/book.mdl";
		this.hitframe = 3;	
	}
	_setmodel(this, this.model);
	this.frame = 0;
	setsize(this, '-16 -16 0', '16 16 5');
	this.flags = FL_ITEM;		// make extra wide
	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_TOSS);
	this.action = openbook;
	this.use = openbook;
}
