void PrintItemName()
{
	if(stat_pref && stat_id)
	{
		if(stat_pref == PF_BROKEN)
			p7('B', 'r', 'o', 'k', 'e', 'n', ' ');
		else if(stat_pref == PF_DAMAGED)
			p8('D', 'a', 'm', 'a', 'g', 'e', 'd', ' ');
		else if(stat_pref == PF_CURSED)
			p7('C', 'u', 'r', 's', 'e', 'd', ' ');
		else if(stat_pref == PF_FLAMMABLE)
		{
			p8('F', 'l', 'a', 'm', 'm', 'a', 'b', 'l');
			p2('e', ' ');
		}
		else if(stat_pref == PF_RUSTED)
			p7('R', 'u', 's', 't', 'e', 'd', ' ');
		else if(stat_pref == PF_BRITTLE)
			p8('B', 'r', 'i', 't', 't', 'l', 'e', ' ');
		else if(stat_pref == PF_CHEAP)
			p6('C', 'h', 'e', 'a', 'p', ' ');
		else if(stat_pref == PF_UNWIELDY)
		{
			p8('U', 'n', 'w', 'i', 'e', 'l', 'd', 'y');
			p1(' ');
		}
		else if(stat_pref == PF_RUGGED)
			p7('R', 'u', 'g', 'g', 'e', 'd', ' ');
		else if(stat_pref == PF_SHARP)
			p6('S', 'h', 'a', 'r', 'p', ' ');
		else if(stat_pref == PF_QUALITY)
			p8('Q', 'u', 'a', 'l', 'i', 't', 'y', ' ');
		else if(stat_pref == PF_LUCKY)
			p6('L', 'u', 'c', 'k', 'y', ' ');
		else if(stat_pref == PF_SUPERIOR)
		{
			p8('S', 'u', 'p', 'e', 'r', 'i', 'o', 'r');
			p1(' ');
		}
		else if(stat_pref == PF_WIZARDS)
		{
			p8('W', 'i', 'z', 'a', 'r', 'd', '`', 's');
			p1(' ');
		}
		else if(stat_pref == PF_ACCURATE)
		{
			p8('A', 'c', 'c', 'u', 'r', 'a', 't', 'e');
			p1(' ');
		}
		else if(stat_pref == PF_DEADLY)
			p7('D', 'e', 'a', 'd', 'l', 'y', ' ');
		else if(stat_pref == PF_WARRIORS)
		{
			p8('W', 'a', 'r', 'r', 'i', 'o', 'r', '`');
			p2('s', ' ');
		}
		else if(stat_pref == PF_ULTIMATE)
		{
			p8('U', 'l', 't', 'i', 'm', 'a', 't', 'e');
			p1(' ');
		}
		else if(stat_pref == PF_SILVER)
			p7('S', 'i', 'l', 'v', 'e', 'r', ' ');
		else if(stat_pref == PF_VIGOROUS)
		{
			p8('V', 'i', 'g', 'o', 'r', 'o', 'u', 's');
			p1(' ');
		}
		else if(stat_pref == PF_HEAVY)
			p6('H', 'e', 'a', 'v', 'y', ' ');
		else if(stat_pref == PF_THIEFS)
			p8('T', 'h', 'i', 'e', 'f', '`', 's', ' ');
		else if(stat_pref == PF_BRUTAL)
			p7('B', 'r', 'u', 't', 'a', 'l', ' ');
		else if(stat_pref == PF_FIERY)
			p6('F', 'i', 'e', 'r', 'y', ' ');
		else if(stat_pref == PF_LIGHT)
			p6('L', 'i', 'g', 'h', 't', ' ');
		else if(stat_pref == PF_RAPID)
			p6('R', 'a', 'p', 'i', 'd', ' ');
		else if(stat_pref == PF_KOR)
			p6('K', 'o', 'r', '`', 's', ' ');
		else if(stat_pref == PF_GOLDEN)
			p7('G', 'o', 'l', 'd', 'e', 'n', ' ');
		else if(stat_pref == PF_THINKERS)
		{
			p8('T', 'h', 'i', 'n', 'k', 'e', 'r', '`');
			p2('s', ' ');
		}
		else if(stat_pref == PF_TITANS)
			p8('T', 'i', 't', 'a', 'n', '`', 's', ' ');
		else if(stat_pref == PF_GROUNDED)
		{
			p8('G', 'r', 'o', 'u', 'n', 'd', 'e', 'd');
			p1(' ');
		}
		else if(stat_pref == PF_TYRS)
			p6('T', 'y', 'r', '`', 's', ' ');
		else if(stat_pref == PF_ORSHAS)
			p8('O', 'r', 's', 'h', 'a', '`', 's', ' ');
		else if(stat_pref == PF_IVES)
			p6('I', 'v', 'e', '`', 's', ' ');
		else if(stat_pref == PF_NIYALS)
			p8('N', 'i', 'y', 'a', 'l', '`', 's', ' ');
	}
	else if(!stat_id)
	{
		p8('U', 'n', 'i', 'd', 'e', 'n', 't', 'i');
		p5('f', 'i', 'e', 'd', ' ');
	}
//==========================================================================
	if(stat_it < IT_ROBE)
	{
		if(stat_it == 0)
			p5('E', 'm', 'p', 't', 'y');
		else if(stat_it == IT_CLOTH)
			p5('C', 'l', 'o', 't', 'h');
		else if(stat_it == IT_LAMMELLAR)
		{
			p8('L', 'a', 'm', 'm', 'e', 'l', 'l', 'a');
			p1('r');
		}
		else if(stat_it == IT_CHAIN_MAIL)
		{
			p8('C', 'h', 'a', 'i', 'n', ' ', 'M', 'a');
			p2('i', 'l');
		}
		else if(stat_it == IT_BREAST_PLATE)
		{
			p8('P', 'l', 'a', 't', 'e', ' ', 'M', 'a');
			p2('i', 'l');
		}
		else if(stat_it == IT_KNIFE)
			p4('D', 'i', 'r', 'k');
		else if(stat_it == IT_DAGGER)
			p6('D', 'a', 'g', 'g', 'e', 'r');
		else if(stat_it == IT_SABRE)
			p5('S', 'a', 'b', 'r', 'e');
		else if(stat_it == IT_RAPIER)
			p6('R', 'a', 'p', 'i', 'e', 'r');
		else if(stat_it == IT_BROADSWORD)
		{
			p8('B', 'r', 'o', 'a', 'd', 's', 'w', 'o');
			p2('r', 'd');
		}
		else if(stat_it == IT_CLUB)
			p4('C', 'l', 'u', 'b');	
		else if(stat_it == IT_MACE)
			p4('M', 'a', 'c', 'e');
		else if(stat_it == IT_STAFF)
			p5('S', 't', 'a', 'f', 'f');
		else if(stat_it == IT_SCEPTER)
			p7('S', 'c', 'e', 'p', 't', 'e', 'r');
		else if(stat_it == IT_HATCHET)
			p7('H', 'a', 't', 'c', 'h', 'e', 't');
		else if(stat_it == IT_AXE)
			p3('A', 'x', 'e');
		else if(stat_it == IT_WAR_AXE)
			p7('W', 'a', 'r', ' ', 'A', 'x', 'e');
		else if(stat_it == IT_SHORT_BOW)
		{
			p8('S', 'h', 'o', 'r', 't', ' ', 'B', 'o');
			p1('w');
		}
		else if(stat_it == IT_LONG_BOW)
			p8('L', 'o', 'n', 'g', ' ', 'B', 'o', 'w');
		else if(stat_it == IT_WAR_BOW)
			p7('W', 'a', 'r', ' ', 'B', 'o', 'w');
		else if(stat_it == IT_THROWKNIFE)
			p6('K', 'n', 'i', 'v', 'e', 's');
		else if(stat_it == IT_BUCKLER)
			p7('B', 'u', 'c', 'k', 'l', 'e', 'r');
		else if(stat_it == IT_SHIELD)
			p6('S', 'h', 'i', 'e', 'l', 'd');
		else if(stat_it == IT_AEGIS)
			p5('A', 'e', 'g', 'i', 's');
		else if(stat_it == IT_SKULL_CAP)
			p8('S', 'k', 'u', 'l', 'l', 'c', 'a', 'p');
		else if(stat_it == IT_HELM)
			p4('H', 'e', 'l', 'm');
		else if(stat_it == IT_GREAT_HELM)
		{
			p8('G', 'r', 'e', 'a', 't', ' ', 'H', 'e');
			p2('l', 'm');
		}
		else if(stat_it == IT_BOOTS)
			p5('B', 'o', 'o', 't', 's');
		else if(stat_it == IT_GREAVES)
			p7('G', 'r', 'e', 'a', 'v', 'e', 's');
		else if(stat_it == IT_AMULET)
			p6('A', 'm', 'u', 'l', 'e', 't');
		else if(stat_it == IT_SPEARS)
			p6('S', 'p', 'e', 'a', 'r', 's');
		else if(stat_it == IT_ARROWS)
			p6('A', 'r', 'r', 'o', 'w', 's');
	}
	else if(stat_it < IT_GOLD)
	{
		if(stat_it == IT_ROBE)
			p4('R', 'o', 'b', 'e');
		else if(stat_it == IT_LEATHER)
			p7('L', 'e', 'a', 't', 'h', 'e', 'r');
		else if(stat_it == IT_RING_MAIL)
		{
			p8('R', 'i', 'n', 'g', ' ', 'M', 'a', 'i');
			p1('l');
		}
		else if(stat_it == IT_SCALE_MAIL)
		{
			p8('S', 'c', 'a', 'l', 'e', ' ', 'M', 'a');
			p2('i', 'l');
		}
		else if(stat_it == IT_ARMET)
			p5('A', 'r', 'm', 'e', 't');
		else if(stat_it == IT_SALLET)
			p6('S', 'a', 'l', 'l', 'e', 't');
		else if(stat_it == IT_RONDACHE)
			p8('R', 'o', 'n', 'd', 'a', 'c', 'h', 'e');
		else if(stat_it == IT_KITE_SHIELD)
		{
			p8('K', 'i', 't', 'e', ' ', 'S', 'h', 'i');
			p3('e', 'l', 'd');
		}
		else if(stat_it == IT_SCUTUM)
			p6('S', 'c', 'u', 't', 'u', 'm');
		else if(stat_it == IT_MATTOCK)
			p7('M', 'a', 't', 't', 'o', 'c', 'k');
		else if(stat_it == IT_HAMMER)
			p6('H', 'a', 'm', 'm', 'e', 'r');
		else if(stat_it == IT_FLAIL)
			p5('F', 'l', 'a', 'i', 'l');
		else if(stat_it == IT_FALCHION)
			p8('F', 'a', 'l', 'c', 'h', 'i', 'o', 'n');
		else if(stat_it == IT_KRIS)
			p4('K', 'r', 'i', 's');
		else if(stat_it == IT_CROSSBOW)
			p8('C', 'r', 'o', 's', 's', 'b', 'o', 'w');
		else if(stat_it == IT_TRIDENT)
			p7('T', 'r', 'i', 'd', 'e', 'n', 't');
		else if(stat_it == IT_LANCE)
			p5('L', 'a', 'n', 'c', 'e');
		else if(stat_it == IT_HALBERD)
			p7('H', 'a', 'l', 'b', 'e', 'r', 'd');
		else if(stat_it == IT_SCYTHE)
			p6('S', 'c', 'y', 't', 'h', 'e');
		else if(stat_it == IT_CLAW)
			p4('C', 'l', 'a', 'w');
		else if(stat_it == IT_SLING)
			p5('S', 'l', 'i', 'n', 'g');
		else if(stat_it == IT_ROD)
			p3('R', 'o', 'd');
		else if(stat_it == IT_WAND)
			p4('W', 'a', 'n', 'd');
		else if(stat_it == IT_CHAKRAM)
			p7('C', 'h', 'a', 'k', 'r', 'a', 'm');
		else if(stat_it == IT_THROW_AXE)
		{
			p8('T', 'h', 'r', 'o', 'w', ' ', 'A', 'x');
			p1('e');
		}
		else if(stat_it == IT_DART)
			p4('D', 'a', 'r', 't');
		else if(stat_it == IT_JAVELIN)
			p7('J', 'a', 'v', 'e', 'l', 'i', 'n');
		else if(stat_it == IT_NAGINATA)
			p8('N', 'a', 'g', 'i', 'n', 'a', 't', 'a');
		else if(stat_it == IT_KATANA)
			p6('K', 'a', 't', 'a', 'n', 'a');
		else if(stat_it == IT_SAI)
			p3('S', 'a', 'i');
		else if(stat_it == IT_NUNCHAKU)
			p8('N', 'u', 'n', 'c', 'h', 'a', 'k', 'u');
		else if(stat_it == IT_SHIRUKEN)
			p8('S', 'h', 'i', 'r', 'u', 'k', 'e', 'n');
	}
	else
	{
		if(stat_it == IT_GOLD)
		{
			pnum(stat_dur);
			p5(' ', 'G', 'o', 'l', 'd');
		}
		else if(stat_it == IT_LESSER_HEAL)
		{
			p7('L', 'e', 's', 's', 'e', 'r', ' ');
			p8('H', 'e', 'a', 'l', ' ', 'P', 'o', 't');
			p3('i', 'o', 'n');
		}
		else if(stat_it == IT_HEAL_POTION)
		{
			p8('H', 'e', 'a', 'l', ' ', 'P', 'o', 't');
			p3('i', 'o', 'n');
		}
		else if(stat_it == IT_GREATER_HEAL)
		{
			p8('G', 'r', 'e', 'a', 't', 'e', 'r', ' ');
			p8('H', 'e', 'a', 'l', ' ', 'P', 'o', 't');
			p3('i', 'o', 'n');
		}
		else if(stat_it == IT_LESSER_MANA)
		{
			p7('L', 'e', 's', 's', 'e', 'r', ' ');
			p8('M', 'a', 'n', 'a', ' ', 'P', 'o', 't');
			p3('i', 'o', 'n');
		}
		else if(stat_it == IT_MANA_POTION)
		{
			p8('M', 'a', 'n', 'a', ' ', 'P', 'o', 't');
			p3('i', 'o', 'n');
		}
		else if(stat_it == IT_GREATER_MANA)
		{
			p8('G', 'r', 'e', 'a', 't', 'e', 'r', ' ');
			p8('M', 'a', 'n', 'a', ' ', 'P', 'o', 't');
			p3('i', 'o', 'n');
		}
		else if(stat_it == IT_ELIXIR)
			p6('E', 'l', 'i', 'x', 'i', 'r');
		else if(stat_it == IT_BOOK)
			p4('B', 'o', 'o', 'k');
		else if(stat_it == IT_SCROLL)
			p6('S', 'c', 'r', 'o', 'l', 'l');
		else if(stat_it == IT_IDSCROLL)
		{
			p8('S', 'c', 'r', 'o', 'l', 'l', ' ', 'o');
			p8('f', ' ', 'I', 'd', 'e', 'n', 't', 'i');
			p2('f', 'y');
		}
		else if(stat_it == IT_OIL_OF_REPAIR)
		{
			p8('O', 'i', 'l', ' ', 'o', 'f', ' ', 'R');
			p5('e', 'p', 'a', 'i', 'r');
		}
		else if(stat_it == IT_OIL)
			p3('O', 'i', 'l');
		else if(stat_it == IT_OIL2)
			p3('O', 'i', 'l');
		else if(stat_it == IT_GOLD_ELIXIR)
		{
			p8('G', 'o', 'l', 'd', ' ', 'E', 'l', 'i');
			p3('x', 'i', 'r');
		}
		else if(stat_it == IT_CURE)
		{
			p8('C', 'u', 'r', 'e', ' ', 'P', 'o', 't');
			p3('i', 'o', 'n');
		}
		else if(stat_it == IT_ALE)
		{
			p3('A', 'l' ,'e');
		}
		else
		{
			PrintUnique();
			return;
		}

	}
//=================================================================
	if(stat_suf && stat_id)
	{
		p4(' ', 'o', 'f', ' ');
		if(stat_suf == SF_FOOL)
			p8('t', 'h', 'e', ' ', 'F', 'o', 'o', 'l');
		else if(stat_suf == SF_WEAK)
			p8('t', 'h', 'e', ' ', 'W', 'e', 'a', 'k');
		else if(stat_suf == SF_CLUMSY)
		{
			p8('t', 'h', 'e', ' ', 'C', 'l', 'u', 'm');
			p2('s', 'y');
		}
		else if(stat_suf == SF_SLOW)
			p8('t', 'h', 'e', ' ', 's', 'l', 'o', 'w');
		else if(stat_suf == SF_MISFORTUNE)
		{
			p8('M', 'i', 's', 'f', 'o', 'r', 't', 'u');
			p2('n', 'e');
		}
		else if(stat_suf == SF_FRAGILITY)
		{
			p8('F', 'r', 'a', 'g', 'i', 'l', 'i', 't');
			p1('y');
		}
		else if(stat_suf == SF_CORRUPTION)
		{
			p8('C', 'o', 'r', 'r', 'u', 'p', 't', 'i');
			p2('o', 'n');
		}
		else if(stat_suf == SF_PIT)
			p7('t', 'h', 'e', ' ', 'P', 'i', 't');
		else if(stat_suf == SF_FROST)
			p5('F', 'r', 'o', 's', 't');
		else if(stat_suf == SF_VITALITY)
			p8('V', 'i', 't', 'a', 'l', 'i', 't', 'y');
		else if(stat_suf == SF_VAMPIRE)
		{
			p8('t', 'h', 'e', ' ', 'V', 'a', 'm', 'p');
			p3('i', 'r', 'e');
		}
		else if(stat_suf == SF_LUCK)
			p4('L', 'u', 'c', 'k');
		else if(stat_suf == SF_STRENGTH)
			p8('S', 't', 'r', 'e', 'n', 'g', 't', 'h');
		else if(stat_suf == SF_INTELLIGENCE)
		{
			p8('I', 'n', 't', 'e', 'l', 'l', 'e', 'c');
			p1('t');
		}
		else if(stat_suf == SF_AGILITY)
			p7('A', 'g', 'i', 'l', 'i', 't', 'y');
		else if(stat_suf == SF_REGEN)
		{
			p6('G', 'r', 'o', 'w', 't', 'h');
		}
		else if(stat_suf == SF_DEXTERITY)
		{
			p8('D', 'e', 'x', 't', 'e', 'r', 'i', 't');
			p1('y');
		}
		else if(stat_suf == SF_POISON)
			p6('P', 'o', 'i', 's', 'o', 'n');
		else if(stat_suf == SF_LEECH)
		{
			p8('t', 'h', 'e', ' ', 'L', 'e' ,'e', 'c');
			p1('h');
		}
		else if(stat_suf == SF_PROTECTION)
		{
			p8('P', 'r', 'o', 't', 'e', 'c', 't', 'i');
			p2('o', 'n');
		}
		else if(stat_suf == SF_HEALTH)
			p6('H', 'e', 'a', 'l', 't', 'h');
		else if(stat_suf == SF_GIANTS)
			p6('G', 'i', 'a', 'n', 't', 's');
		else if(stat_suf == SF_HEAVENS)
		{
			p8('t', 'h', 'e', ' ', 'H', 'e', 'a', 'v');
			p3('e', 'n', 's');
		}
		else if(stat_suf == SF_STARS)
		{
			p8('t', 'h', 'e', ' ', 'S', 't', 'a', 'r');
			p1('s');
		}
		else if(stat_suf == SF_MANA)
			p4('M', 'a', 'n', 'a');
		else if(stat_suf == SF_HERETIC)
			p6('H', 'e', 'r', 'e', 's', 'y');
		else if(stat_suf == SF_FLAME)
			p5('F', 'l', 'a', 'm', 'e');
		else if(stat_suf == SF_QUALITY)
			p7('Q', 'u', 'a', 'l', 'i', 't', 'y');
		else if(stat_suf == SF_BEAR)
			p8('t', 'h', 'e', ' ', 'B', 'e', 'a', 'r');
		else if(stat_suf == SF_WIZARDRY)
			p8('W', 'i', 'z', 'a', 'r', 'd', 'r', 'y');
		else if(stat_suf == SF_BASHING)
			p7('B', 'a', 's', 'h', 'i', 'n', 'g');
		else if(stat_suf == SF_HASTE)
			p5('H', 'a', 's', 't', 'e');
		else if(stat_suf == SF_FIGHTING)
			p8('F', 'i', 'g', 'h', 't', 'i', 'n', 'g');
		else if(stat_suf == SF_SLAUGHTER)
		{
			p8('S', 'l', 'a', 'u', 'g', 'h', 't', 'e');
			p1('r');
		}
		else if(stat_suf == SF_VIM)
			p3('V', 'i', 'm');
		else if(stat_suf == SF_ACCURACY)
			p8('A', 'c', 'c', 'u', 'r', 'a', 'c', 'y');
		else if(stat_suf == SF_MAGI)
			p8('t', 'h', 'e', ' ', 'M', 'a', 'g', 'i');
		else if(stat_suf == SF_AGES)
			p8('t', 'h', 'e', ' ', 'A', 'g', 'e', 's');
		else if(stat_suf == SF_MEDICINE)
			p8('M', 'e', 'd', 'i', 'c', 'i', 'n', 'e');
		else if(stat_suf == SF_SPIKES)
			p6('S', 'p', 'i', 'k', 'e', 's');
		else if(stat_suf == SF_FIRE)
			p4('F', 'i', 'r', 'e');
		else if(stat_suf == SF_SHOCK)
			p5('S', 'h', 'o', 'c', 'k');
		else if(stat_suf == SF_BOUNTY)
			p6('B', 'o', 'u', 'n', 't', 'y');
		else if(stat_suf == SF_MIND)
			p8('t', 'h', 'e', ' ', 'M', 'i', 'n', 'd');
		else if(stat_suf == SF_POWER)
			p5('P', 'o', 'w', 'e', 'r');
		else if(stat_suf == SF_KINGS)
			p5('K', 'i', 'n', 'g', 's');
		else if(stat_suf == SF_EASE)
			p4('E', 'a', 's', 'e');
		else if(stat_suf == SF_BLIGHT)
			p6('B', 'l', 'i', 'g', 'h', 't');
		else if(stat_suf > SF_SPELL)
			PrintSpellName(stat_suf - SF_SPELL);

	}
}
