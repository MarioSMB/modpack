#include "vwep.qh"

#include "../stats/stats.qh"
#include "../subs/combat.qh"

void updatevwep(entity this)
{
	float f;

	if(this.player)
		this = this.player;
		
	if(!this.modelindex)
	{
		if(this.wayp)
		{
			delete(this.wayp);
			this.wayp = NULL;
		}
		if(this.camera)
		{
			delete(this.camera);
			this.camera = NULL;
		}
		if(this.spellprop)
		{
			delete(this.spellprop);
			this.spellprop = NULL;
		}
	}
	else
	{
		if(this.owner.rightarm)
		{
			if(!this.wayp)
			{
				this.wayp = spawn();
				this.wayp.owner = this;
			}
			it_simplestat(this, this.owner.rightarm);
			itemapplyeffects(this.wayp);
			setorigin(this.wayp, this.origin);
			this.wayp.frame = this.frame + 2;
			this.wayp.angles = this.angles;
			
		}
		else
		{
			if(this.wayp)
			{
				delete(this.wayp);
				this.wayp = NULL;
			}
		}
		if(this.owner.leftarm)
		{
			if(!this.camera)
			{
				this.camera = spawn();
				this.camera.owner = this;
			}
			it_simplestat(this, this.owner.leftarm);
			itemapplyeffects(this.camera);
			setorigin(this.camera, this.origin);
			this.camera.frame = this.frame + 2;
			this.camera.angles = this.angles;
		}
		else
		{
			if(this.camera)
			{
				delete(this.camera);
				this.camera = NULL;
			}
		}
		if(this.bkup_model)
		{
			if(!this.spellprop)
				this.spellprop = spawn();		
			_setmodel(this.spellprop, this.bkup_model);
			setorigin(this.spellprop, this.origin);
			this.spellprop.frame = this.frame + 2;
			this.spellprop.angles = this.angles;
		}
		else if(this.owner.shield_time > time)
		{
			if(!this.spellprop)
				this.spellprop = spawn();
			_setmodel(this.spellprop, "progs/mshield.mdl");
			setorigin(this.spellprop, this.origin);
			this.spellprop.alpha = 0.2;
		}
		else
		{
			if(this.spellprop)
			{
				delete(this.spellprop);
				this.spellprop = NULL;
			}
		}
	}
	if(this.owner.visibility < 0)
	{
		this.alpha = 1 - ((0 - this.owner.visibility) / 100);
		if(this.alpha < 0.1)
			this.alpha = 0.1;
		if(this.camera)
			this.camera.alpha = this.alpha;
		if(this.wayp)
			this.wayp.alpha = this.alpha;
		this.effects &= ~(EF_DIMLIGHT | EF_BRIGHTLIGHT);
	}
	else
	{
		this.effects &= ~(EF_DIMLIGHT | EF_BRIGHTLIGHT);
		if(this.owner.visibility > 50)
			this.effects |= EF_BRIGHTLIGHT;
		else if(this.owner.visibility > 25)
			this.effects |= EF_DIMLIGHT;
	}
		
	if(this.regen_time < time)
	{
		if(this.owner.misc & MISC_UPDATE_BLINK)
			this.owner.misc &= ~MISC_UPDATE_BLINK;
		else
			this.owner.misc |= MISC_UPDATE_BLINK;
			
		this.regen_time = time + 1;
		if(this.owner.spec & SPEC_REPLENISH)
			replenish_dur(this);
		if(this.poison_count > 0)
		{
			T_Damage(this.poison_inflictor, this, this.poison_factor, 2);
			this.poison_count = this.poison_count - this.poison_factor;
		}
		if(this.misc & MISC_MORTAL_WOUND)
		{
			this.mortal_factor = this.mortal_factor / 10;
			if(random() < this.mortal_factor)
			{
				T_Damage(this.poison_inflictor, this, ceil(this.mortal_factor), 5);
				spawngib(this, "progs/blod.mdl");
			}
		}
		if(this.owner.mana_regen)
		{
			f = (this.owner.mana_regen / 1000);
			this.owner.mana = this.owner.mana + ceil(this.owner.max_mana * f);
			boundstats(this.owner);
		}
		if(this.owner.health_regen)
		{
			f = (this.owner.health_regen / 1000);
			this.owner.health = this.owner.health + ceil(this.owner.max_health * f);
			boundstats(this.owner);
		}
	}
}
