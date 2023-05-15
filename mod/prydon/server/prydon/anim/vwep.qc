
void() updatevwep =
{
	local float f;
	
	if (self.player)
		self = self.player;
		
	if (!self.modelindex)
	{
		if (self.wayp)
		{
			remove(self.wayp);
			self.wayp = world;
		}
		if (self.camera)
		{
			remove(self.camera);
			self.camera = world;
		}
		if (self.spellprop)
		{
			remove(self.spellprop);
			self.spellprop = world;
		}
	}
	else
	{
		if (self.owner.rightarm)
		{
			if (!self.wayp)
			{
				self.wayp = spawn();
				self.wayp.owner = self;
			}
			it_simplestat(self.owner.rightarm);
			itemapplyeffects(self.wayp);
			setorigin(self.wayp, self.origin);
			self.wayp.frame = self.frame + 2;
			self.wayp.angles = self.angles;
			
		}
		else
		{
			if (self.wayp)
			{
				remove(self.wayp);
				self.wayp = world;
			}
		}
		if (self.owner.leftarm)
		{
			if (!self.camera)
			{
				self.camera = spawn();
				self.camera.owner = self;
			}
			it_simplestat(self.owner.leftarm);
			itemapplyeffects(self.camera);
			setorigin(self.camera, self.origin);
			self.camera.frame = self.frame + 2;
			self.camera.angles = self.angles;
		}
		else
		{
			if (self.camera)
			{
				remove(self.camera);
				self.camera = world;
			}
		}
		if (self.bkup_model)
		{
			if (!self.spellprop)
				self.spellprop = spawn();		
			setmodel(self.spellprop, self.bkup_model);
			setorigin(self.spellprop, self.origin);
			self.spellprop.frame = self.frame + 2;
			self.spellprop.angles = self.angles;
		}
		else if (self.owner.shield_time > time)
		{
			if (!self.spellprop)
				self.spellprop = spawn();
			setmodel(self.spellprop, "progs/mshield.mdl");
			setorigin(self.spellprop, self.origin);
			self.spellprop.alpha = 0.2;
		}
		else
		{
			if (self.spellprop)
			{
				remove(self.spellprop);
				self.spellprop = world;
			}
		}
	}
	if (self.owner.visibility < 0)
	{
		self.alpha = 1 - ((0 - self.owner.visibility) / 100);
		if (self.alpha < 0.1)
			self.alpha = 0.1;
		if (self.camera)
			self.camera.alpha = self.alpha;
		if (self.wayp)
			self.wayp.alpha = self.alpha;
		self.effects = self.effects - (self.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT));
	}
	else
	{
		self.effects = self.effects - (self.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT));
		if (self.owner.visibility > 50)
			self.effects = self.effects | EF_BRIGHTLIGHT;
		else if (self.owner.visibility > 25)
			self.effects = self.effects | EF_DIMLIGHT;
	}
		
	if (self.regen_time < time)
	{
		if (self.owner.misc & MISC_UPDATE_BLINK)
			self.owner.misc = self.owner.misc - MISC_UPDATE_BLINK;
		else
			self.owner.misc = self.owner.misc | MISC_UPDATE_BLINK;
			
		self.regen_time = time + 1;
		if (self.owner.spec & SPEC_REPLENISH)
			replenish_dur();
		if (self.poison_count > 0)
		{
			T_Damage(self.poison_inflictor, self, self.poison_factor, 2);
			self.poison_count = self.poison_count - self.poison_factor;
		}
		if (self.misc & MISC_MORTAL_WOUND)
		{
			self.mortal_factor = self.mortal_factor / 10;
			if (random() < self.mortal_factor)
			{
				T_Damage(self.poison_inflictor, self, ceil(self.mortal_factor), 5);
				spawngib("progs/blod.mdl");
			}
		}
		if (self.owner.mana_regen)
		{
			f = (self.owner.mana_regen / 1000);
			self.owner.mana = self.owner.mana + ceil(self.owner.max_mana * f);
			boundstats(self.owner);
		}
		if (self.owner.health_regen)
		{
			f = (self.owner.health_regen / 1000);
			self.owner.health = self.owner.health + ceil(self.owner.max_health * f);
			boundstats(self.owner);
		}
	}
};
