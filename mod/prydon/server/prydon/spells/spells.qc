#include "spells.qh"

// definitely not the most efficient methodology in the world!

int GetSpellLevel(entity e, float espell)
{
	if(espell & SP_ITEM_CAST)
	{
		return floor(espell/256);
	}
	else if(espell == 1)
		return e.spells1;
	else if(espell == 2)
		return e.spells2;
	else if(espell == 3)
		return e.spells3;
	else if(espell == 4)
		return e.spells4;
	else if(espell == 5)
		return e.spells5;
	else if(espell == 6)
		return e.spells6;
	else if(espell == 7)
		return e.spells7;
	else if(espell == 8)
		return e.spells8;
	else if(espell == 9)
		return e.spells9;
	else if(espell == 10)
		return e.spells10;
	else if(espell == 11)
		return e.spells11;
	else if(espell == 12)
		return e.spells12;
	else if(espell == 13)
		return e.spells13;
	else if(espell == 14)
		return e.spells14;
	else if(espell == 15)
		return e.spells15;
	else if(espell == 16)
		return e.spells16;
	// UGLY NASTY GARBAGE
	else if(espell == SP_SPRINT)
	{
		if(e.skill & SKILL_SPRINT)
			return e.title_x + 1;
		else
			return 0;
	}
	else if(espell == SP_FLAME_ARROW)
	{
		if(e.skill & SKILL_FLAME_ARROW)
			return e.title_x + 1;
		else
			return 0;	
	}
	else if(espell == SP_BRIBE)
	{
		if(e.skill & SKILL_BRIBE)
			return e.title_x + 1;
		else
			return 0;	
	}
	else if(espell == SP_BRAWL)
	{
		if(e.skill & SKILL_BRAWL)
			return e.title_x + 1;
		else
			return 0;	
	}
	else if(espell == SP_FRENZY)
	{
		if(e.skill & SKILL_FRENZY)
			return e.title_x + 1;
		else
			return 0;	
	}
	else if(espell == SP_IDENTIFY)
	{
		if(e.skill & SKILL_IDENTIFY)
			return e.title_x + 1;
		else
			return 0;	
	}
	return 1;
}

void SetSpellLevel(entity e, float espell, float l)
{
	espell &= 63;
	
	if(espell == 1)
	{
		e.spells1 = l;
		return;
	}
	else if(espell == 2)
	{
		e.spells2 = l;
		return;
	}
	else if(espell == 3)
	{
		e.spells3 = l;
		return;
	}
	else if(espell == 4)
	{
		e.spells4 = l;
		return;
	}
	else if(espell == 5)
	{
		e.spells5 = l;
		return;
	}
	else if(espell == 6)
	{
		e.spells6 = l;
		return;
	}
	else if(espell == 7)
	{
		e.spells7 = l;
		return;
	}
	else if(espell == 8)
	{
		e.spells8 = l;
		return;
	}
	else if(espell == 9)
	{
		e.spells9 = l;
		return;
	}
	else if(espell == 10)
	{
		e.spells10 = l;
		return;
	}
	else if(espell == 11)
	{
		e.spells11 = l;
		return;
	}
	else if(espell == 12)
	{
		e.spells12 = l;
		return;
	}
	else if(espell == 13)
	{
		e.spells13 = l;
		return;
	}
	else if(espell == 14)
	{
		e.spells14 = l;
		return;
	}
	else if(espell == 15)
	{
		e.spells15 = l;
		return;
	}
	else if(espell == 16)
	{
		e.spells16 = l;
		return;
	}
}

void AddSpellLevel(entity e, float espell, float level)
{
	float l = GetSpellLevel(e, espell);
	l += level;
	if(l < 0)
		l = 0;
	SetSpellLevel(e, espell, l);
}

bool SelectSpell(entity this, float sp)
{
	if(GetSpellLevel(this, sp))
	{
		for(int i=1; i <= TOTAL_SLOTS; i = i + 1)
		{
			it_simplestat(this,GetSlot(this, i));
			it_itemstat(this);
			
			if(SPELL & stat_loc)
				Unequip(this, i, 1);
		}
		this.spell = sp;
		return true;
	}
	return false;
}
