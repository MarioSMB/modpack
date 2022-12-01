void player_hurt(entity this)
{
	// print("hurt\n");
	// this.frame = 5;
	sound(this, CHAN_AUTO, SND_PLAYER_HURT, 1, ATTEN_NORM);
}

void player_die(entity this)
{
	this.dead_time = time + 3;
	this.solid = SOLID_NOT;
	this.takes_damage = false;
	set_movetype(this, MOVETYPE_NONE);
}

void player_touch(entity this, entity toucher)
{
	if(autocvar_g_friendlyfire_virtual)
		return;
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.origin_z > this.origin_z + this.view_ofs.z)
	{
		STAT(NO_CONTROL_TIME, toucher) = time + 0.25;
		toucher.velocity = randomvec() * 100 + '0 0 250';
		damage(toucher, this, rint(2 * autocvar_g_friendlyfire));
	}
}
