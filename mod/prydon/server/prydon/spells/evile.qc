
void() evile_5 = [4, SUB_Remove] {};
void() evile_4 = [3, evile_5] {};
void() evile_3 = [2, evile_4] {};
void() evile_2 = [1, evile_3] {};
void() evile_1 = [0, evile_2] {};

void() evile_go =
{
	local entity e;
	local vector v, org;
	v_y = random() * 360;
	makevectors(v);
	
	org = self.origin + v_forward * random() * self.summon_count;
	traceline(self.origin, org, TRUE, self);

	e = findradius(trace_endpos, 30);
	while(e)
	{
		if (e.takedamage )
			if (!friendly(e, self))
				T_Damage(self.owner, e, self.dama, 3);
		e = e.chain;
	}
	e = spawn();
	setmodel(e, "progs/evile.spr");
	setorigin(e, trace_endpos);
	e.think = evile_1;
	e.nextthink = time;
	if (time > self.ltime)
	{
		sound(self, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
		remove(self);
	}
	else
		self.nextthink = time + 0.08;
	
};

