#include "die.qh"

#include "../stats/stats.qh"
#include "../subs/subs.qh"
#include "../subs/trigger.qh"

void death_fade(entity this)
{
	if(this.alpha <= 0.06)
	{
		this.model = "";
		delete(this);
	}
	else
	{
		this.alpha = this.alpha - 0.03;
		this.nextthink = time + 0.02;
	}
}
void death_frames(entity this)
{
	setthink(this, death_frames);
	this.nextthink = time + 0.1;
	
	this.frame = this.frame + 1;
	float b = (this.deathframes - this.runframes) / this.deathscenes;
	float f = (this.frame - this.runframes) - 1;
	f = (f - (floor(f / b) * b)) + 1;

	if(f >= b)
	{
		if(this.classname == "body")
		{
			setthink(this, func_null);
			this.nextthink = 0;
			return;
		}
		setthink(this, death_fade);
		this.alpha = 1;
		this.nextthink = time + 8;
	}
}
void death_selectscene(entity this)
{
	float b = (this.deathframes - this.runframes) / this.deathscenes;
	this.frame = this.deathframes - ((ceil(random() * this.deathscenes) * b));
}

void death1(entity this) 
{
	death_selectscene(this);
	death_frames(this);
}

void PlayerDie(entity this, bool bodydeath)
{
	int i;
	if(this.player)
		this = this.player;
		
	if(this.camera)
	{
		delete(this.camera);
		this.camera = NULL;
	}
	if(this.wayp)
	{
		delete(this.wayp);
		this.wayp = NULL;
	}
	if(this.spellprop)
	{
		delete(this.spellprop);
		this.spellprop = NULL;
	}
	if(this.owner.classname == "player")
		openmenu(this.owner, m_dead, this.owner);
	if(this.classname == "helper")
		if(this.sbarsub)
			this.sbarsub.summon_count = this.sbarsub.summon_count - 1;
	if(this.ai & AI_FOLLOW)
		if(this.sbarsub)
			this.sbarsub.follow_npcs = this.sbarsub.follow_npcs - 1;
	this.owner.health = 0;
	this.health = 0;
	this.takedamage = DAMAGE_NO;
	this.owner.takedamage = DAMAGE_NO;
	this.effects = 0;
	
	if(this.theme)
		setdmusic(world.noise2);
	if(this.killtarget)
		this.target = this.killtarget;
		
	if(this.target)
	{
		generictrigger(this, NULL, this.enemy);
	}
	if(bodydeath)
	{
		if(!drop_body(this))
		{
			dropallitems(this);
			if(this.cold_time > time)
			{
				for(i = 0; i < 3; i = i + 1)
					spawngib(this, "progs/frozen.mdl");
				for(i = 0; i < 3; i = i + 1)
					spawngib(this, "progs/frozen2.mdl");
				for(i = 0; i < 3; i = i + 1)
					spawngib(this, "progs/frozen3.mdl");
				_sound(this, CH_VOICE, "spells/shatter.wav", 1, ATTN_NORM);
				delete(this);
				return;
			}
			this.deadflag = 1;
	
			this.flags = 0;
			this.solid = SOLID_NOT;
			set_movetype(this, MOVETYPE_TOSS);
		}
		Unstat(this.owner);
		this.owner.equip = 0;
		this.owner.gp = 0;
		for(i = 1; i <= TOTAL_SLOTS; i = i +1)
			ClearSlot(this.owner, i);
		Restat(this.owner);
	}
	death1(this);
	this.owner.player = NULL;
	this.player = this;

	if(this.noise4)
		_sound(this, CH_VOICE, this.noise4, 1, ATTN_NORM);

	this.owner = this;	
}