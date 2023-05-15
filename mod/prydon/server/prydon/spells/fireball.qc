void ball_hit(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(MagicHit(this, this.enemy, toucher))
	{
		if(this.noise)
			sound(this, CHAN_AUTO, this.noise, 1, ATTN_NORM);
		delete(this);
	}
	else if(!toucher)
	{
		delete(this);
	}
	else
	{
		this.owner = toucher;
		this.velocity = this.dest1;
		this.ltime = this.nextthink;
		this.think = fix_velocity;
		this.nextthink = time;
	}
};



void(float lev) fireball_go =
{
	local entity e;
	local float f, b, ofs, n;

	sound(this, CHAN_WEAPON, "spells/fball.wav", 1, ATTN_NORM);

	if(lev >= 6)
	{
		b = 5;
		ofs = -20;
		n = 10;
	}
	else if(lev > 4)
	{
		b = 3;
		ofs = -15;
		n = 15;
	}
	else
		b = 1;
	if(lev == 0)
		f = 4;
	else
		f = (ceil(lev * lev * 1.5) + 7) / b;
	while(b > 0)
	{
		e = launch_projectile(ofs, 90 + lev * 10, spell_range(SP_FIREBALL), "progs/fball.mdl");
		e.effects =  EF_ADDITIVE;
		e.touch = ball_hit;
		e.fire = f;
		e.enemy = this;
		e.owner = this;
		ofs = ofs + n;
		b = b - 1;
	}
};