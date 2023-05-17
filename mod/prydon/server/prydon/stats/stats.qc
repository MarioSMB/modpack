#include "stats.qh"

#include "../spells/spells.qh"
#include "rank.qh"

void boundstats(entity e)
{
	if(e.health > e.max_health)
		e.health = e.max_health;
	else if(e.health < 0)
		e.health = 0;
	if(e.mana > e.max_mana)
		e.mana = e.max_mana;
	else if(e.mana < 0)
		e.mana = 0;
	if(IS_PLAYER(e))
	{
		if(GetSpellLevel(e, e.spell) < 1)
		{
			SelectSpell(e, 0);
		}
	}
}

void GenStat(entity this, float sign)
{
	if(IS_PLAYER(this))
		if(this.max_health < 25)
			this.max_health = 25;// prevent erosion from bugs
	this.max_health = this.max_health + (this.vit + ceil(this.lvl * 0.5)) * sign;
	this.max_mana = this.max_mana + (this.mag + ceil(this.lvl * 0.5)) * sign;
	this.tohit = this.tohit + (50 + rint(this.dex / 3) + rint(this.luck / 3)) * sign;
	this.dodge = this.dodge + (50 + rint(this.agil/2)) * sign;
	this.ac = this.ac + (this.lvl * 2) * sign;
	this.daml = this.daml + (ceil(this.str * 0.2) + 1) * sign;
	this.dama = this.dama + 1 * sign;
	this.aspeed = this.aspeed + floor(this.agil * 0.2) * sign;
}

void Restat(entity this)
{
	titleupdate(this);

	GenStat(this, 1);
	
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if(this.equip & (2 ** i))
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			UseItem(this, 1);
		}
	}

	boundstats(this);
}

void Unstat(entity this)
{
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if(this.equip & (2 ** i))
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			UseItem(this, -1);
		}
	}

	GenStat(this, -1);
}
