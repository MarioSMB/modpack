#ifdef SVQC

void checkpoint_touch(entity this, entity toucher)
{
	if (toucher.cp != this)
	{
		msg_entity = toucher;
		WriteHeader(MSG_ONE, TE_CSQC_ITEMPICKUP);
		WriteByte(MSG_ONE, 4);
	}
	toucher.cp = this;
}

bool checkpoint_customize(entity this, entity client)
{
    this.frame = ((client.cp == this) ? 1 : 0);
    return true;
}

spawnfunc(misc_checkpoint)
{
	settouch(this, checkpoint_touch);
	setmodel(this, MDL_CHECKPOINT);
	this.solid = SOLID_TRIGGER;
	setsize(this, '-32 -32 0', '32 32 48');
	setcefc(this, checkpoint_customize);
}

#endif
