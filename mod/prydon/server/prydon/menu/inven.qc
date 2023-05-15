void(vector it, float eq) stats_report =
{
	if (stat_it >= 127)
	{
		p8('U', 'n', 'i', 'q', 'u', 'e', ' ', 'I');
		p3('t', 'e', 'm');
		newline();
	}
	if (!stat_id)
	{
		red = RED_ON;
		p8('U', 'n', 'i', 'd', 'e', 'n', 't', 'i');
		p4('f', 'i', 'e', 'd');
		newline();
		return;
	}
	else if (stat_id != 1)
	{
		p8('W', 'i', 'l', 'l', ' ', 'r', 'e', 't');
		p3('u', 'r', 'n');
		newline();
		p6('i', 't', 'e', 'm', ' ', '#');
		pnum(it_x);
		p1(',');
		pnum(it_y);
		p1(',');
		pnum(it_z);
		
		p6(' ', 'l', 'a', 't', 'e', 'r');
		newline();
	
	}
	if (eq)
	{
		if (stat_loc & EQUIPABLE)
		{
			p8('E', 'q', 'u', 'i', 'p', 'p', 'e', 'd');
			p2(':', ' ');
			if (eq == 1)
				p2('N', 'O');
			else
				p3('Y', 'E', 'S'); 
			newline();
		}
	}
	if (stat_loc & RIGHTARM)
	{
		if (stat_action)
		{
			PrintSpellName(stat_action & 63);
			p7(' ', 'A', 't', 't', 'a', 'c', 'k');
			newline();
		}
	
	}
	if (stat_loc & DURABILITY)
	{
		if (stat_dur == 0)
			red = 128;
		p8 ('D', 'u', 'r', 'a', 'b', 'i', 'l', 'i');
		p3 ('t', 'y', ' ');

		pnum(stat_dur);
		p1('/');
		pnum(stat_max_dur);
		newline();
	}
	else if (stat_loc & STACKABLE)
	{
		if (stat_dur == 0)
			red = 128;
		p8 ('Q', 'u', 'a', 'n', 't', 'i', 't', 'y');
		p1(' ');

		pnum(stat_dur);
		p1('/');
		pnum(stat_max_dur);
		newline();
	}
	else if (stat_loc & CHARGES)
	{
		p8 ('C', 'h', 'a', 'r', 'g', 'e', 's', ' ');
		pnum(stat_dur);
		p1('/');
		pnum(stat_max_dur);
		newline();
		p5 ('M', 'a', 'n', 'a', ' ');
		pnum(mana_for_spell(stat_action & 63, stat_spell_level));
		newline();
	}
	else if (stat_spec & SPEC_INDESTRUCTIBLE)
	{
		p8('I', 'n', 'd', 'e', 's', 't', 'r', 'u');
		p6('c', 't', 'a', 'b', 'l', 'e');
		newline();
	}
	if ((stat_loc & TWO_HAND) == TWO_HAND)
	{
		p8('T', 'w', 'o', ' ', 'H', 'a', 'n', 'd');
		p2('e', 'd');
		newline();
	}

	if (stat_def)
	{
		p8('D', 'e', 'f', 'e', 'n', 's', 'e', ' ');
		pnum(stat_def);
		newline();
	}
	if (stat_daml)
	{
		pnum(stat_daml);
		if (stat_dama)
		{
			p4(' ', 't', 'o', ' ');
			pnum(stat_daml+stat_dama);
		}
		p7(' ', 'D', 'a', 'm', 'a', 'g', 'e');
		newline();
	}
	if (stat_tohit)
	{
		pnum(stat_tohit);
		p8('%', ' ', 'T', 'o', ' ', 'h', 'i', 't');
		newline();
	}
	if (stat_dodge)
	{
		pnum(stat_dodge);
		p7('%', ' ', 'D', 'o', 'd', 'g', 'e');
		newline();
	}
	if (stat_block)
	{
		pnum(stat_block);
		p7('%', ' ', 'B', 'l' , 'o', 'c', 'k');
		newline();

	}
	if (stat_critical)
	{
		pnum(stat_critical);
		p8('%', ' ', 'C', 'r', 'i', 't', 'i', 'c');
		p6('a', 'l', ' ', 'H', 'i', 't');
		newline();
	}
	if (stat_piercing)
	{
		pnum(stat_piercing);
		p8('%', ' ', 'P', 'i', 'e', 'r', 'c', 'i');
		p6('n', 'g', ' ', 'H', 'i', 't');
		newline();
	}
	if (stat_visibility)
	{

		if (stat_visibility > 0)
		{
			pnum(stat_visibility);
			p8('%', ' ', 'I', 'n', 'c', 'r', 'e', 'a');
		}
		else
		{
			pnum(0-stat_visibility);
			p8('%', ' ', 'D', 'e', 'c', 'r', 'e', 'a');
		}
		p8('s', 'e', 'd', ' ', 'V', 'i', 's', 'i');
		p6('b', 'i', 'l', 'i', 't', 'y');
		newline();
	}
	if (stat_toall)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_toall);
		p8(' ', 't', 'o', ' ', 'a', 'l', 'l', ' ');
		p8('a', 't', 't', 'r', 'i', 'b', 'u', 't');
		p2('e', 's');
		newline();
	}
	if (stat_str)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_str);
		p8(' ', 'S', 't', 'r', 'e', 'n', 'g', 't');
		p1('h');
		newline();
	}
	if (stat_dex)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_dex);
		p8(' ', 'D', 'e', 'x', 't', 'e', 'r', 'i');
		p2('t', 'y');
		newline();
	}
	if (stat_mag)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_mag);
		p8(' ', 'I', 'n', 't', 'e', 'l', 'l', 'i');
		p5('g', 'e', 'n', 'c', 'e');
		newline();
	}
	if (stat_vit)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_vit);
		p8(' ', 'V', 'i', 't', 'a', 'l', 'i', 't');
		p1('y');
		newline();
	}
	if (stat_luck)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_luck);
		p5(' ', 'L', 'u', 'c', 'k');
		newline();
	}
	if (stat_agil)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_agil);
		p8(' ', 'A', 'g', 'i', 'l', 'i', 't', 'y');
		newline();
	}
	if (stat_mana)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_mana);
		p8(' ', 't', 'o', ' ', 'm', 'a', 'n', 'a');
		newline();
	}
	if (stat_health)
	{
		p5('A', 'd', 'd', 's', ' ');
		pnum(stat_health);
		p8(' ', 't', 'o', ' ', 'h', 'e', 'a', 'l');
		p2('t', 'h');
		newline();
	}
	if (stat_fire)
	{
		p7('H', 'i', 't', ' ', 'a', 'd', 'd');
		p2('s', ' ');
		pnum(stat_fire/2);
		p1('-');
		pnum(stat_fire);
		
		p8(' ', 'f', 'i', 'r', 'e', ' ', 'd', 'a');
		p4('m', 'a', 'g', 'e');
		newline();
	
	}
	if (stat_poison)
	{
		p7('H', 'i', 't', ' ', 'a', 'd', 'd');
		p2('s', ' ');
		pnum(stat_poison);
		p8(' ', 'p', 'o', 'i', 's', 'o', 'n', ' ');
		p6('d', 'a', 'm', 'a', 'g', 'e');
		newline();
	}
	if (stat_lit)
	{
		p7('H', 'i', 't', ' ', 'a', 'd', 'd');
		p4('s', ' ', '1', '-');
		pnum(stat_lit);
		p8(' ', 'l', 'i', 'g', 'h', 't', 'n', 'i');
		p8('n', 'g', ' ', 'd', 'a', 'm', 'a', 'g');
		p1('e');
		newline();
	}
	if (stat_cold)
	{
		p7('H', 'i', 't', ' ', 'a', 'd', 'd');
		p2('s', ' ');
		pnum(stat_cold/2);
		p1('-');
		pnum(stat_cold);
		
		p8(' ', 'c', 'o', 'l', 'd', ' ', 'd', 'a');
		p4('m', 'a', 'g', 'e');
		newline();
	
	}
	if (stat_magic)
	{
		p7('H', 'i', 't', ' ', 'a', 'd', 'd');
		p2('s', ' ');
		pnum(stat_magic);
		p8(' ', 'm', 'a', 'g', 'i', 'c', ' ', 'd');
		p5('a', 'm', 'a', 'g', 'e');	
		newline();
	}
	if (stat_spell)
	{
		if (GetSpellLevel(self, stat_spell) >= 7)
			red = RED_ON;
		if (stat_loc & SPELL)
		{
			p8('C', 'a', 's', 't', 's', ' ', 'l', 'e');
			p4('v', 'e', 'l', ' ');
			pnum(stat_spell_level);
			p1(' ');
		}
		else
		{
			p5('A', 'd', 'd', 's', ' ');
			pnum(stat_spell_level);
			p4(' ', 't', 'o', ' ');
		}
		PrintSpellName(stat_spell & 63);
		newline();
	}
	if (stat_resist_all)
	{
		p8('R', 'e', 's', 'i', 's', 't', ' ', 'A');
		p2('l', 'l');
		pnum(stat_resist_all);
		p1('%');
		newline();
	}
	if (stat_resist_fire)
	{
		p8('R', 'e', 's', 'i', 's', 't', ' ', 'F');
		p4('i', 'r', 'e', ' ');
		pnum(stat_resist_fire);
		p1('%');
		newline();
	}
	if (stat_resist_lit)
	{
		p8('R', 'e', 's', 'i', 's', 't', ' ', 'L');
		p8('i', 'g', 'h', 't', 'n', 'i', 'n', 'g');
		p1(' ');
		pnum(stat_resist_lit);
		p1('%');
		newline();	
	}
	if (stat_resist_poison)
	{
		p8('R', 'e', 's', 'i', 's', 't', ' ', 'P');
		p6('o', 'i', 's', 'o', 'n', ' ');
		pnum(stat_resist_poison);
		p1('%');
		newline();	
	}
	if (stat_resist_cold)
	{
		p8('R', 'e', 's', 'i', 's', 't', ' ', 'C');
		p4('o', 'l', 'd', ' ');
		pnum(stat_resist_cold);
		p1('%');
		newline();
	}
	if (stat_resist_magic)
	{
		p8('R', 'e', 's', 'i', 's', 't', ' ', 'M');
		p5('a', 'g', 'i', 'c', ' ');
		pnum(stat_resist_magic);
		p1('%');
		newline();	
	}
	if (stat_attacker_dam)
	{
		pnum(stat_attacker_dam);
		p8('%', ' ', 'D', 'a', 'm', 'a', 'g', 'e');
		p8(' ', 'R', 'e', 't', 'u', 'r', 'n', 'e');
		p1('d');
		newline();
	}
	if (stat_attacker_fire)
	{
		p8('A', 't', 't', 'a', 'c', 'k', 'e', 'r');
		p7(' ', 't', 'a', 'k', 'e', 's', ' ');
		pnum(ceil(stat_attacker_fire/2));
		p1('-');
		pnum(stat_attacker_fire);
		p8(' ', 'F', 'i', 'r', 'e', ' ', 'D', 'a');
		p4('m', 'a', 'g', 'e');
		newline();
	}
	if (stat_attacker_lit)
	{
		p8('A', 't', 't', 'a', 'c', 'k', 'e', 'r');
		p8(' ', 't', 'a', 'k', 'e', 's', ' ', '1');
		p1('-');
		pnum(stat_attacker_lit);
		p8(' ', 'L', 'i', 'g', 'h', 't', 'n', 'i');
		p8('n', 'g', ' ', 'D', 'a', 'm', 'a', 'g');
		p1('e');
		newline();
	}
	if (stat_attacker_cold)
	{
		p8('A', 't', 't', 'a', 'c', 'k', 'e', 'r');
		p7(' ', 't', 'a', 'k', 'e', 's', ' ');
		pnum(ceil(stat_attacker_cold/2));
		p1('-');
		pnum(stat_attacker_cold);
		p8(' ', 'C', 'o', 'l', 'd', ' ', 'D', 'a');
		p4('m', 'a', 'g', 'e');
		newline();
	}
	if (stat_attacker_poison)
	{
		p8('A', 't', 't', 'a', 'c', 'k', 'e', 'r');
		p7(' ', 't', 'a', 'k', 'e', 's', ' ');
		pnum(stat_attacker_poison);
		p8(' ', 'P', 'o', 'i', 's', 'o', 'n', ' ');
		p6('D', 'a', 'm', 'a', 'g', 'e');
		newline();
	}
	if (stat_magic_reduced)
	{
		p8('M', 'a', 'g', 'i', 'c', ' ', 'D', 'a');
		p8('m', 'a', 'g', 'e', ' ', 'R', 'e', 'd');
		p8('u', 'c', 'e', 'd', ' ', 'b', 'y', ' ');
		pnum(stat_magic_reduced);
		newline();
	}
	if (stat_damage_reduced)
	{
		p2('D', 'a');
		p8('m', 'a', 'g', 'e', ' ', 'R', 'e', 'd');
		p8('u', 'c', 'e', 'd', ' ', 'b', 'y', ' ');
		pnum(stat_damage_reduced);
		newline();
	}
	if (stat_spec)
	{
		if (stat_spec & SPEC_STEAL_LIFE)
		{
			p8('H', 'i', 't', ' ', 's', 't', 'e', 'a');
			p7('l', 's', ' ', 'l', 'i', 'f', 'e');
			newline();
		}
		if (stat_spec & SPEC_KNOCKBACK)
		{
			p8('H', 'i', 't', ' ', 'k', 'n', 'o', 'c');
			p8('k', 's', ' ', 't', 'a', 'r', 'g', 'e');
			p6('t', ' ', 'b', 'a', 'c', 'k');
			newline();
		}

		if (stat_spec & SPEC_STEAL_MANA)
		{
			p8('H', 'i', 't', ' ', 's', 't', 'e', 'a');
			p7('l', 's', ' ', 'm', 'a', 'n', 'a');
			newline();
		}
		if (stat_spec & SPEC_REPLENISH)
		{
			if (stat_loc & DURABILITY)
			{
				p8('S', 'e', 'l', 'f', ' ', 'R', 'e', 'p');
				p4('a', 'i', 'r', 's');
			}
			else if (stat_loc & CHARGES)
			{
				p8('R', 'e', 'p', 'l', 'e', 'n', 'i', 's');
				p8('h', 'e', 's', ' ', 'C', 'h', 'a', 'r');
				p2('g', 'e');
			}
			else
			{
				p8('R', 'e', 'p', 'l', 'e', 'n', 'i', 's');
				p8('h', 'e', 's', ' ', 'Q', 'u', 'a', 'n');
				p4('t', 'i', 't', 'y');
			}
			newline();
		}
		if (stat_spec & SPEC_DAZE)
		{
			p8('H', 'i', 't', ' ', 'c', 'a', 'u', 's');
			p7('e', 's', ' ', 'd', 'a', 'z', 'e');
			newline();
		}
		if (stat_spec & SPEC_MORTAL_WOUND)
		{
			p8('3', '0', '%', ' ', 'c', 'h', 'a', 'n');
			p8('c', 'e', ' ', 'o', 'f', ' ', 'M', 'o');
			p8('r', 't', 'a', 'l', ' ', 'W', 'o', 'u');
			p2('n', 'd');
			newline();
		}
		if (stat_spec & SPEC_TWO_HITS)
		{
			p8('H', 'i', 't', 's', ' ', 'T', 'w', 'i');
			p2('c', 'e');
			newline();
		}
		if (stat_spec & SPEC_MAIM)
		{
			p8('3', '0', '%', ' ', 'c', 'h', 'a', 'n');
			p8('c', 'e', ' ', 'o', 'f', ' ', 'M', 'a');
			p5('i', 'm', 'i', 'n', 'g');
			newline();
		}
		if (stat_spec & SPEC_MELEE_IMMUNE)
		{
			p8('I', 'm', 'm', 'u', 'n', 'e', ' ', 't');
			p8('o', ' ', 'M', 'e', 'l', 'e', 'e', ' ');
			p4('H', 'i', 't', 's');
		}
		if (stat_spec & SPEC_MISSILE_IMMUNE)
		{
			p8('I', 'm', 'm', 'u', 'n', 'e', ' ', 't');
			p8('o', ' ', 'M', 'i', 's', 's', 'l', 'e');
			p5(' ', 'H', 'i', 't', 's');
		}
	}
	if (stat_skill)
	{
		if (stat_skill & SKILL_EXPERIENCE)
		{
			p8('I', 'n', 'c', 'r', 'e', 'a', 's', 'e');
			p8('d', ' ', 'E', 'x', 'p', 'e', 'r', 'i');
			p4('e', 'n', 'c', 'e');
			newline();
		}
		if (stat_skill & SKILL_MELEE)
		{
			p8('I', 'n', 'c', 'r', 'e', 'a', 's', 'e');
			p8('d', ' ', 'M', 'e', 'l', 'e', 'e', ' ');
			p6('D', 'a', 'm', 'a', 'g', 'e');
			newline();
		}
		if (stat_skill & SKILL_BOW)
		{
			p8('I', 'n', 'c', 'r', 'e', 'a', 's', 'e');
			p8('d', ' ', 'A', 'r', 'r', 'o', 'w', ' ');
			p6('D', 'a', 'm', 'a', 'g', 'e');
			newline();
		}
		if (stat_skill & SKILL_THROW)
		{
			p8('I', 'n', 'c', 'r', 'e', 'a', 's', 'e');
			p8('d', ' ', 'T', 'h', 'r', 'o', 'w', ' ');
			p6('D', 'a', 'm', 'a', 'g', 'e');
			newline();
		}
		if (stat_skill & SKILL_SPELLS)
		{
			p8('I', 'n', 'c', 'r', 'e', 'a', 's', 'e');
			p8('d', ' ', 'S', 'p', 'e', 'l', 'l', ' ');
			p6('D', 'a', 'm', 'a', 'g', 'e');
			newline();
		}
		if (stat_skill & SKILL_REPAIR)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('R', 'e', 'p', 'a', 'i', 'r', ' ', 'S');
			p4('k', 'i', 'l', 'l');
			newline();
		}
		if (stat_skill & SKILL_IDENTIFY)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('I', 'd', 'e', 'n', 't', 'i', 'f', 'y');
			p6(' ', 'S', 'k', 'i', 'l', 'l');
			newline();
		}
		if (stat_skill & SKILL_SPRINT)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('S', 'p', 'r', 'i', 'n', 't', ' ', 'S');
			p4('k', 'i', 'l', 'l');
			newline();
		}
		if (stat_skill & SKILL_BRAWL)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('B', 'r', 'a', 'w', 'l', ' ', 'S', 'k');
			p3('i', 'l', 'l');
			newline();
		}
		if (stat_skill & SKILL_RELOAD)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('R', 'e', 'l', 'o', 'a', 'd', ' ', 'S');
			p4('k', 'i', 'l', 'l');
			newline();
		}
		if (stat_skill & SKILL_FLAME_ARROW)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('F', 'i', 'r', 'e', ' ', 'A', 'r', 'r');
			p8('o', 'w', ' ', 'S', 'k', 'i', 'l', 'l');
			newline();
		}
		if (stat_skill & SKILL_DISCOUNT)
		{
			p8('S', 'h', 'o', 'p', ' ', 'D', 'i', 's');
			p5('c', 'o', 'u', 'n', 't');
			newline();
		}
		if (stat_skill & SKILL_BRIBE)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('B', 'r', 'i', 'b', 'e', ' ', 'S', 'k');
			p3('i', 'l', 'l');
			newline();
		}
		if (stat_skill & SKILL_POTION)
		{
			p8('P', 'o', 't', 'i', 'o', 'n', ' ', 'T');
			p8('r', 'a', 'n', 's', 'm', 'u', 't', 'a');
			p4('t', 'i', 'o', 'n');	
			newline();
		}
		if (stat_skill & SKILL_JUMP)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('L', 'e', 'a', 'p', ' ', 'S', 'k', 'i');
			p2('l', 'l');
			newline();
		}
		if (stat_skill & SKILL_FRENZY)
		{
			if (it)
				p7('G', 'r', 'a', 'n', 't', 's', ' ');
			p8('F', 'r', 'e', 'n', 'z', 'y', ' ', 'S');
			p4('k', 'i', 'l', 'l');
			newline();
		}
	}
	if (stat_health_regen)
	{
		p1('+');
		pnum(stat_health_regen);
		p8(' ', 'H', 'e', 'a', 'l', 't', 'h', ' ');
		p8('R', 'e', 'g', 'e', 'n', 'e', 'r', 'a');
		p4('t', 'i', 'o', 'n');
		newline();
	}
	if (stat_mana_regen)
	{
		p1('+');
		pnum(stat_mana_regen);
		p8(' ', 'M', 'a', 'n', 'a', ' ', 'R', 'e');
		p8('g', 'e', 'n', 'e', 'r', 'a', 't', 'i');
		p2('o', 'n');
		newline();
	}
	if (stat_aspeed)
	{
		if (stat_aspeed > 0)
		{
			pnum(stat_aspeed);
			p8('%', ' ', 'I', 'n', 'c', 'r', 'e', 'a');
			p8('s', 'e', 'd', ' ', 'A', 't', 't', 'a');
			p8('c', 'k', ' ', 'S', 'p', 'e', 'e', 'd');
			newline();
		}
		else
		{
			pnum(0-stat_aspeed);
			p8('%', ' ', 'D', 'e', 'c', 'r', 'e', 'a');
			p8('s', 'e', 'd', ' ', 'A', 't', 't', 'a');
			p8('c', 'k', ' ', 'S', 'p', 'e', 'e', 'd');
			newline();
		}
	}

	
	if (stat_req_str)
	{

		if (self.str < stat_req_str)
			red = RED_ON;
		p8('R', 'e', 'q', 'u', 'i', 'r', 'e', 's');
		p1(' ');
		pnum(stat_req_str);
		p8(' ', 'S', 't', 'r', 'e', 'n', 'g', 't');
		p1('h');
		newline();
	}

	if (stat_req_dex)
	{
		if (self.dex < stat_req_dex)
			red = RED_ON;
		p8('R', 'e', 'q', 'u', 'i', 'r', 'e', 's');
		p1(' ');
		pnum(stat_req_dex);
		p8(' ', 'D', 'e', 'x', 't', 'e', 'r', 'i');
		p2('t', 'y');
		newline();
	}
	if (stat_req_mag)
	{
		if (self.mag < stat_req_mag)
			red = RED_ON;
		p8('R', 'e', 'q', 'u', 'i', 'r', 'e', 's');
		p1(' ');
		pnum(stat_req_mag);
		p8(' ', 'I', 'n', 't', 'e', 'l', 'l', 'i');
		p5('g', 'e', 'n', 'c', 'e');
		newline();
	}
	if (stat_req_vit)
	{
		if (self.vit < stat_req_vit)
			red = RED_ON;
		p8('R', 'e', 'q', 'u', 'i', 'r', 'e', 's');
		p1(' ');
		pnum(stat_req_vit);
		p8(' ', 'V', 'i', 't', 'a', 'l', 'i', 't');
		p1('y');
		newline();
	}
	if (stat_req_luck)
	{
		if (self.luck < stat_req_luck)
			red = RED_ON;
		p8('R', 'e', 'q', 'u', 'i', 'r', 'e', 's');
		p1(' ');
		pnum(stat_req_luck);
		p5(' ', 'L', 'u', 'c', 'k');
		newline();
	}
	if (stat_req_agil)
	{
		if (self.agil < stat_req_agil)
			red = RED_ON;
		p8('R', 'e', 'q', 'u', 'i', 'r', 'e', 's');
		p1(' ');
		pnum(stat_req_agil);
		p8(' ', 'A', 'g', 'i', 'l', 'i', 't', 'y');
		newline();
	}
	if (stat_req_lvl)
	{
		if (self.lvl < stat_req_lvl)
			red = RED_ON;
		p8('M', 'u', 's', 't', ' ', 'b', 'e', ' ');
		p6('L', 'e', 'v', 'e', 'l', ' ');
		pnum(stat_req_lvl);
		newline();
	}
	if (stat_req_class)
	{
		if (self.title_y != stat_req_class_y)
			red = RED_ON;
		p8('O', 'n', 'l', 'y', ' ', 'u', 's', 'a');
		p7('b', 'l', 'e', ' ', 'b', 'y', ' ');
		PrintClass(stat_req_class);
		newline();
	}
	if (stat_target)
	{
		p8('S', 'p', 'e', 'c', 'i', 'a', 'l', ' ');
		p5('P', 'o', 'w', 'e', 'r');
		newline();
	}
}


void (vector it, float eq) inven =
{
	pstart();
	it_simplestat(it);
	it_itemstat();
	PrintItemName();
	newline();
	line();
	stats_report(it, eq);
	if (vmfc)
	{
		if (!self.vmodel)
			self.vmodel = spawn();
		self.vmodel.viewmodelforclient = self;
		self.vmodel.effects = self.vmodel.effects | EF_NODEPTHTEST;
		itemapplyeffects(self.vmodel);
		self.vmodel.effects = self.vmodel.effects | EF_NODEPTHTEST;
		self.vmodel.frame = 1;
	}
	else
	{
		self.weaponmodel = itemmodel(stat_it);
		self.weaponframe = 1;
	}

	line();
};

void setitems(entity this)
{
	local float g, i;
	g = 0;
	
	for(i = 1; i< 8; i =i + 1)
	{
		if (GetSlot(self, i))
			g = g | pow2(i);
	}
	if (GetSlot(self, 8))
		g = g | QI_SLOT8;
	if (self.player)
	{
		if (self.player.poison_count > 0)
			g = g | QI_POISON;
		if (self.player.cold_time > time)
			g = g | QI_FROZEN; 
	}
		
	self.items = g;
};


void() m_inven =
{
	local float r, f;
	local vector it;
	local entity e;
	
	it = GetSlot(self.m_subject, root2(self.weapon));

	if (self.menu < 1)
		self.menu = 6;
	else if (self.menu > 6)
		self.menu = 1;

	r = self.menu;

	if (self.button1)
	{
		self.button1 = 0;
		if (r == 1)
		{
			e = self;
			self = self.m_subject;
			it_simplestat(it);
			it_itemstat();
			if (stat_loc & EQUIPABLE)
			{
				if (self.equip & e.weapon)
					Unequip(root2(e.weapon), 1);
				else if (!Equip(root2(e.weapon)))
					sprint(e, "Can't!\n");
				// fixme
				// 	go errrn!
			}
			if (stat_loc & USABLE)
				Use(root2(e.weapon));
			self = e;
			
			
		}
		else if (r == 2)
		{
			f = root2(self.weapon);
			f = f + 1;
			if (f > TOTAL_SLOTS)
				f = 1;
			self.weapon = pow2(f);
			it = GetSlot(self.m_subject, f);
		}
		else if (r == 3)
		{
			f = root2(self.weapon);
			f = f - 1;
			if (f < 1)
				f = TOTAL_SLOTS;
			self.weapon = pow2(f);
			it = GetSlot(self.m_subject, f);
		}
		else if (r == 4)
		{
			f = root2(self.weapon);
			e = self;
			self = self.m_subject;
			Unequip(f, 1); // if equipped
		
			dropitem(it);
			ClearSlot(self, f);
			self = e;
			it = IV_NULL;
		}
		else if (r == 5)
		{
			it_simplestat(it);
			it_itemstat();
			if (stat_loc & STACKABLE)
				openmenu(self, m_split, self.m_subject);
			return;
		}
		else if (r == 6)
		{
			closemenu(self);
			return;
		}
	}
	if (self.m_refresh < time)
	{
		inven(it, fabs(self.m_subject.equip & self.weapon) + 1);
		padlines(9);
		if (stat_loc & EQUIPABLE)
		{
			if (self.m_subject.equip & self.weapon)
			{
				if (self.menu == 1)
					WriteString(msg_mode, "\n\{141}\[\1\] Unequip      \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 2)
					WriteString(msg_mode, "\n \[\1\] Unequip      \n\{141}\[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 3)
					WriteString(msg_mode, "\n \[\1\] Unequip      \n \[\2\] Next Item    \n\{141}\[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 4)
					WriteString(msg_mode, "\n \[\1\] Unequip      \n \[\2\] Next Item    \n \[\3\] Previous Item\n\{141}\[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 5)
					WriteString(msg_mode, "\n \[\1\] Unequip      \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n\{141}\[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 6)
					WriteString(msg_mode, "\n \[\1\] Unequip      \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n\{141}\[\6\] Exit         \n");

			}
			else
			{
				if (self.menu == 1)
					WriteString(msg_mode, "\n\{141}\[\1\] Equip        \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 2)
					WriteString(msg_mode, "\n \[\1\] Equip        \n\{141}\[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 3)
					WriteString(msg_mode, "\n \[\1\] Equip        \n \[\2\] Next Item    \n\{141}\[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 4)
					WriteString(msg_mode, "\n \[\1\] Equip        \n \[\2\] Next Item    \n \[\3\] Previous Item\n\{141}\[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 5)
					WriteString(msg_mode, "\n \[\1\] Equip        \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n\{141}\[\5\] Split        \n \[\6\] Exit         \n");
				else if (self.menu == 6)
					WriteString(msg_mode, "\n \[\1\] Equip        \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n\{141}\[\6\] Exit         \n");

			}			
		}
		else
		{
			if (self.menu == 1)
				WriteString(msg_mode, "\n\{141}\[\1\] Use          \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
			else if (self.menu == 2)
				WriteString(msg_mode, "\n \[\1\] Use          \n\{141}\[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
			else if (self.menu == 3)
				WriteString(msg_mode, "\n \[\1\] Use          \n \[\2\] Next Item    \n\{141}\[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
			else if (self.menu == 4)
				WriteString(msg_mode, "\n \[\1\] Use          \n \[\2\] Next Item    \n \[\3\] Previous Item\n\{141}\[\4\] Drop         \n \[\5\] Split        \n \[\6\] Exit         \n");
			else if (self.menu == 5)
				WriteString(msg_mode, "\n \[\1\] Use          \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n\{141}\[\5\] Split        \n \[\6\] Exit         \n");
			else if (self.menu == 6)
				WriteString(msg_mode, "\n \[\1\] Use          \n \[\2\] Next Item    \n \[\3\] Previous Item\n \[\4\] Drop         \n \[\5\] Split        \n\{141}\[\6\] Exit         \n");

		}
	}
};
/*
 \[\1\] Equip        \n
 \[\2\] Next Item    \n
 \[\3\] Previous Item\n
 \[\4\] Drop         \n
 \[\5\] Split        \n
 \[\6\] Exit         \n
 
 
 \[\1\] Use          \n
 \[\2\] Next Item    \n
 \[\3\] Previous Item\n
 \[\4\] Drop         \n
 \[\5\] Split        \n \[\6\] Exit         \n

*/
