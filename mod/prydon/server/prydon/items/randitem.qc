#include "randitem.qh"

vector randitem(entity this, float base, float val, float shop)
{
	val = ceil(val + (random() * (val/2)) - (val/4));
	int runawayloop = 0;

	:newitem
	runawayloop = runawayloop + 1;
	if(runawayloop > 10)
		return IV_NULL;
		
	// base item type first
	stat_pref = stat_suf = stat_it = 0;
	float r = ceil(random() * BASEITEMS);
        if(random() < 0.1)
		if(random() < 0.1)
			r = floor(random() * 35) + IT_ITHAELS_ROBE; // unique drops
	if(base)
		stat_it = fabs(base);
	else
	{
		// simplify this crud
		if(shop == 1)
		{
			stat_it = ceil(random() * 57);
			if(stat_it >= IT_STAFF)
				stat_it = stat_it + 2; // skip the 2 staves
			if(stat_it >= IT_AMULET)
				stat_it = stat_it + 1; // skip amulet
			if(stat_it >= IT_ROBE)
				stat_it = stat_it + 1; // skip robe
			if(stat_it >= IT_ROD)
				stat_it = stat_it + 2; // skip rod/wand
			val = 1.5 * val;
		}
		else if(shop == 2)
		{
			stat_it = floor(random() * 15) + IT_STAFF;
			if(stat_it > IT_SCEPTER) // skip the weapons
				stat_it = stat_it + 15;
			if(stat_it >= IT_ARROWS)
				stat_it = stat_it + 2; // skip spears + arrows
			if(stat_it >= IT_LEATHER)
				stat_it = stat_it + 20;
			if(stat_it >= IT_CHAKRAM)
				stat_it = stat_it + 16;
			val = 1.5 * val;
		}
		else if(random() < 0.3) // these items are more common
		{
			r = ceil(random() * 4);
			if(r == 1)
				stat_it = IT_GOLD;
			else if(r == 2)
				stat_it = IT_LESSER_HEAL;
			else if(r == 3)
				stat_it = IT_LESSER_MANA;
			else if(r == 4)
				stat_it = IT_ARROWS;
		}
		else
			stat_it = r;
	}

	if(!stat_it)
		goto newitem;
	stat_dur = 1;
	it_clearstats();
	it_itemstat(this);
	if(stat_id == 2)
		goto newitem;
	// reject the item if it's too good
	if((stat_price / 2) > val)
	{
		if(random() > 0.1)
			if(!base)
				if(runawayloop < 10)
					goto newitem;
	}
	if(!stat_it)
		goto newitem;
	:newprefsuf
	runawayloop = runawayloop + 1;
	if(runawayloop > 10)
		return IV_NULL;
	if(random() > 0.8)
	{
		if(stat_price > val && !shop)
			stat_pref = ceil(random() * PF_BAD); 
		else 
			stat_pref = ceil(random() * PF_GOOD) + PF_BAD; // NUMBER OF GOOD + NUMBER OF BAD
		it_itemstat(this);
		
	}
	if(random() > 0.8)
	{
		if(stat_price > val && !shop)
			stat_suf = ceil(random() * SF_BAD);
		else
			stat_suf = ceil(random() * SF_GOOD) + SF_BAD; // NUMBER OF GOOD + NUMBER OF BAD
		if(stat_suf > 48)
			stat_suf = stat_suf + 63;
		it_itemstat(this);
	}	
	// next check if these prefixes/suffixes are valid

	stat_dur = stat_max_dur;
	if(stat_it == IT_GOLD)
	{
		stat_pref = stat_suf = 0;
		stat_dur = rint(val);
		if(stat_dur <= 0)
			stat_dur = 1;
		else if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	else if((stat_it >= IT_LESSER_HEAL) && (stat_it <= IT_GREATER_MANA))
	{
		stat_pref = stat_suf = 0;
		if(shop)
			stat_dur = 1;
		else
			stat_dur = ceil((val / stat_price) * random());
		it_itemstat(this);
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	else if(stat_it == IT_ELIXIR)
	{
		if(random() > 0.2)
			if(runawayloop < 10)
				goto newitem;
		r = ceil(random() * 7);
		stat_pref = 0;
		if(r == 1)
			stat_suf = SF_VITALITY; // vitality
		else if(r == 2)
			stat_suf = SF_LUCK; // luck
		else if(r == 3)
			stat_suf = SF_STRENGTH; // strength
		else if(r == 4)
			stat_suf = SF_AGILITY; // agil
		else if(r == 5)
			stat_suf = SF_DEXTERITY; // dex
		else if(r == 6)
			stat_suf = SF_INTELLIGENCE; // intelligence
		else if(r == 7)
			stat_suf = SF_HEALTH; // health
	}
	else if(stat_it == IT_GOLD_ELIXIR)
	{
		if(random() > 0.1)
			goto newitem;
		if(random() > 0.1)
			goto newitem;
		stat_pref = stat_suf = 0;
	}
	else if(stat_it == IT_CURE)
	{
		stat_pref = stat_suf = 0;
		stat_dur = ceil((val / stat_price) * random());
		it_itemstat(this);
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	else if(stat_it == IT_ALE)
	{
		stat_pref = stat_suf = 0;
		stat_dur = ceil((val / stat_price) * random());
		it_itemstat(this);
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	else if(stat_it == IT_AMULET)
	{
		// amulet
		if(!(stat_suf || stat_pref))
			goto newitem;
		if(stat_pref == PF_BROKEN)
			goto newitem;
		else if(stat_pref == PF_DAMAGED)
			goto newitem;
		else if((stat_pref > PF_FLAMMABLE) && (stat_pref <= PF_QUALITY))
			goto newitem;
		else if(stat_pref == PF_SUPERIOR)
			goto newitem;
		else if(stat_pref == PF_HEAVY)
			goto newitem;
		else if(stat_suf == SF_FRAGILITY)
			goto newitem;
		else if(stat_suf == SF_QUALITY)
			goto newitem;
		else if(stat_suf == SF_EASE)
			goto newitem;	
	}
	else if(stat_it == IT_ROD)
	{
		stat_spell = ceil((random() * 4) * (random() * 4));
		stat_suf = SF_SPELL + stat_spell;
		stat_dur = ceil(val / stat_price * random() + 5 + random() * stat_max_dur);
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	else if(stat_it == IT_WAND)
	{
		stat_spell = ceil((random() * 4) * (random() * 4));
		stat_suf = SF_SPELL + stat_spell;
		stat_dur = ceil(val / stat_price * random() + 5 + random() * stat_max_dur);
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	} 
	else if(stat_it == IT_SCROLL)
	{

		stat_spell = ceil((random() * 4) * (random() * 4));
		stat_dur = floor( val / (7 + 5 * stat_spell)) + 1;
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
		stat_pref = 0;
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
		stat_suf = SF_SPELL + stat_spell;
	}
	else if(stat_it == IT_BOOK)
	{
		if(random() < 0.4)
			if(runawayloop < 5)
				goto newitem;
		stat_pref = 0;
		stat_spell = ceil((random() * 4) * (random() * 4));
		stat_suf = SF_SPELL + stat_spell;
		if(stat_suf < 48)
			stat_suf = 48;
	}
	else if(stat_it == IT_IDSCROLL)
	{
		stat_pref = stat_suf =  0;
		stat_dur = ceil ( val / 50 );
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	else if(stat_it == IT_OIL_OF_REPAIR)
	{
		stat_pref = stat_suf =  0;
		stat_dur = ceil ( val / 55 );
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	else if(stat_it == IT_OIL)
	{
		if(random() > 0.2)
			if(runawayloop < 10)
				goto newitem;
		stat_pref =  0;
		stat_suf = ceil(random() * SF_GOOD) + SF_BAD; 
		if(stat_suf > 47)
			stat_suf = stat_suf + 64;

	}
	else if(stat_it == IT_OIL2)
	{
		if(random() > 0.2)
			if(runawayloop < 10)
				goto newitem;
		stat_suf =  0;
		stat_pref = ceil(random() * PF_GOOD) + PF_BAD;
	}
	else if((stat_it == IT_ARROWS) || (stat_it == IT_SPEARS) || (stat_it == IT_THROWKNIFE))
	{
		// arrows
		// usually arrows are plain
		if(random() < 0.9)
			stat_pref = stat_suf = 0;
		it_itemstat(this);
		stat_dur = ceil(val / stat_price * random() + 5 + random() * stat_max_dur);
		if(stat_dur > stat_max_dur)
			stat_dur = stat_max_dur;
	}
	if(stat_def)
	{
		if(stat_pref == PF_SHARP) // sharp
			goto newprefsuf;
	}
	if(stat_loc & STACKABLE)
	{
		if(stat_suf == SF_AGES)
			goto newprefsuf;
	}
	stat_id = 1;
	if(!shop)
		if(stat_pref || stat_suf)
			if(stat_it < IT_GOLD)
				if(random () < 0.8)
					stat_id = 0;
	return it_setstat();
}
