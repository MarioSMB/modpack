

float() attack_animation =
{
	local float b, f;
	
	self.frame = self.frame + 1;
	if (self.misc & MISC_DOUBLEATTACK)
	{
		b = (self.doubleattack - self.throwframes) / self.dblattkscenes;
		f = (self.frame - self.throwframes) - 1;
		f = (f - (floor(f / b) * b)) + 1;
	}
	else
	{
		b = (self.attackframes - self.deathframes) / self.attackscenes;
		f = (self.frame - self.deathframes) - 1;
		f = (f - (floor(f / b) * b)) + 1;
	}
	if (f == 1)
		if (self.noise)
			sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);


	if (f >= b)
	{
		self.think = AnimatePlayer;
		self.nextthink = time + 0.1;
	}

	face(1);
	if (f == self.hitframe)
		if (range_check(SP_FIGHT_MELEE, self.enemy))
			return TRUE;
	if (self.owner.spec & SPEC_TWO_HITS)
	{
		if (f == (self.hitframe + 1))
			if (range_check(SP_FIGHT_MELEE, self.enemy))
				return TRUE;
	}
	return 0;
};
void() attack_selectscene =
{
	local float b;
	if (self.misc & MISC_DOUBLEATTACK)
	{
		b = (self.doubleattack - self.throwframes) / self.dblattkscenes;
		self.frame = self.doubleattack - ((ceil(random() * self.dblattkscenes) * b));
	}
	else
	{
		b = (self.attackframes - self.deathframes) / self.attackscenes;
		self.frame = self.attackframes - ((ceil(random() * self.attackscenes) * b));
	}
};


void() attack_frames = 
{
	self.think = attack_frames;
	self.nextthink = time + 0.1;
	
	if (attack_animation())
		if(Hit(self, self.enemy, SKILL_MELEE))
			sound(self, CHAN_AUTO, "player/hit.wav", 1, ATTN_NORM);
};

void() attack1 = 
{
	attack_selectscene();
	attack_frames();
	self.dbltime = 1;
};

void() frenzy_frames =
{
	self.think = frenzy_frames;
	self.nextthink = time + 0.1;
	
	if(attack_animation())
	{
		if(Hit(self, self.enemy, SKILL_MELEE))
		{
			sound(self, CHAN_AUTO, "player/hit.wav", 1, ATTN_NORM);
			self.frenzy_factor = self.frenzy_factor + self.owner.title_x + 1;
			self.frenzy_time = time + 5;
		}
	}
};

void() frenzy1 = 
{
	attack_selectscene();
	frenzy_frames();
	self.dbltime = 1;
};



void() brawl_frames =
{
	self.think = brawl_frames;
	self.nextthink = time + 0.1;
	
	local entity e;
	if (attack_animation())
	{
		e = findradius(self.origin, 68);
		while(e)
		{
			if (e.takedamage)
			{
				if (infront(e))
				{
					if (!friendly(e, self))
					{
						if(Hit(self, e, SKILL_BRAWL))
						{
							sound(self, CHAN_WEAPON, "player/hit.wav", 1, ATTN_NORM);
						}
					}
				}
			}
			e = e.chain;
		}
		// ugly slash sprite
		e = spawn();
		setmodel(e, "progs/cresent.spr");
		makevectors(self.angles);
		setorigin(e, self.origin + v_forward * 32);
		e.alpha = 0.2;
		e.angles_x = 90;
		e.angles_y = self.angles_y;
		e.angles_z = 0;
		e.think = SUB_Remove;
		e.nextthink = time + 0.1;
	}
};

void() brawl1 = 
{
	attack_selectscene();
	brawl_frames();
	self.dbltime = 1;
};