

void() nova_9 = [8, SUB_Remove] {self.nextthink = time + 0.05;};
void() nova_8 = [7, nova_9] {self.nextthink = time + 0.05;};
void() nova_7 = [6, nova_8] {self.nextthink = time + 0.05;};
void() nova_6 = [5, nova_7] {self.nextthink = time + 0.05;};
void() nova_5 = [4, nova_6] {self.nextthink = time + 0.05;};
void() nova_4 = [3, nova_5] {self.nextthink = time + 0.05;};
void() nova_3 = [2, nova_4] {self.nextthink = time + 0.05;};
void() nova_2 = [1, nova_3] {self.nextthink = time + 0.05;};
void() nova_1 = [0, nova_2] {self.nextthink = time + 0.05;};

void(float lev) nova_go =
{
	local entity e, m;
	
	sound(self, CHAN_AUTO, "spells/nova.wav", 1, ATTN_NORM);
	m = spawn();
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	setmodel(m, "progs/nova.mdl");
	setorigin(m, self.origin + '0 0 -20');
	m.think = nova_1;
	m.nextthink = time;
	e = findradius(self.origin, 128);
	while (e)
	{
		if (!friendly(e, self))
			if (e.takedamage)
				LightningDamage(self, e, 12 + ceil(lev * lev * 2.5));
		e = e.chain;
	}
};