void(float sp) PrintSpellName =
{
	if (sp & SP_SCROLL_OF)
	{
		p8('S', 'c', 'r', 'o', 'l', 'l', ' ', 'o');
		p2('f', ' ');

	}
	sp = sp & 63;
	if (sp == SP_FIREBALL)
		p8('F', 'i', 'r', 'e', 'b', 'a', 'l', 'l');
	else if (sp == SP_ZAP)
		p3('Z', 'a', 'p');
	else if (sp == SP_ICEBLAST)
		p8('I', 'c', 'e', 'b', 'l', 'a', 's', 't');
	else if (sp == SP_WARP)
		p4('W', 'a', 'r', 'p');
	else if (sp == SP_POISONBALL)
	{
		p8('P', 'o', 'i', 's', 'o', 'n', 'b', 'a');
		p2('l', 'l');
	}
	else if (sp == SP_LEECH)
	{
		p8('L', 'e', 'e', 'c', 'h', ' ', 'L', 'i');
		p2('f', 'e');
	}
	else if (sp == SP_HEAL)
		p4('H', 'e', 'a', 'l');
	else if (sp == SP_SHIELD)
		p6('S', 'h', 'i', 'e', 'l', 'd');
	else if (sp == SP_TRANSMUTE)
	{
		p8('T', 'r', 'a', 'n', 's', 'm', 'u', 't');
		p1('e');
	}	
	else if (sp == SP_REPEL)
		p5('R', 'e', 'p', 'e', 'l');	
	else if (sp == SP_NOVA)
		p4('N', 'o', 'v', 'a');
	else if (sp == SP_TWISTER)
		p7('T', 'w', 'i', 's', 't', 'e', 'r');
	else if (sp == SP_TELEPORT)
		p8('T', 'e', 'l', 'e', 'p', 'o', 'r', 't');
	else if (sp == SP_SUMMON)
		p6('S', 'u', 'm', 'm', 'o', 'n');
	else if (sp == SP_METEOR)
		p6('M', 'e', 't', 'e', 'o', 'r');
	else if (sp == SP_EVILE)
		p5('E', 'v', 'i', 'l', 'e');
	else if (sp == SP_GOTO)
		p4('G', 'o', 't', 'o');
	else if (sp == SP_ACTIVATE)
		p8('A', 'c', 't', 'i', 'v', 'a', 't', 'e');
	else if (sp == SP_FIGHT_MELEE)
		p5('M', 'e', 'l', 'e', 'e');
	else if (sp == SP_FIGHT_BOW)
		p5('A', 'r', 'r', 'o', 'w');
	else if (sp == SP_THROW)
		p5('T', 'h', 'r', 'o', 'w');
	else if (sp == SP_FOLLOW)
		p6('F', 'o', 'l', 'l', 'o', 'w');
	else if (sp == SP_HEALOTHER)
	{
		p8('H', 'e', 'a', 'l', ' ', 'O', 't', 'h');
		p2('e', 'r');
	}
	else if (sp == SP_SPRINT)
		p6('S', 'p', 'r', 'i', 'n', 't');
	else if (sp == SP_BRAWL)
		p5('B', 'r', 'a', 'w', 'l');
	else if (sp == SP_FLAME_ARROW)
	{
		p8('F', 'l', 'a', 'm', 'e', ' ', 'A', 'r');
		p3('r', 'o', 'w');
	}
	else if (sp == SP_BRIBE)
		p5('B', 'r', 'i', 'b', 'e');
	else if (sp == SP_JUMP)
		p4('L', 'e', 'a', 'p');
	else if (sp == SP_FRENZY)
		p6('F', 'r', 'e', 'n', 'z', 'y');
	else if (sp == SP_IDENTIFY)
		p8('I', 'd', 'e', 'n', 't', 'i', 'f', 'y');
	else if (sp == SP_FREEZE)
		p6('F', 'r', 'e', 'e', 'z', 'e');
	else if (sp == SP_FIGHT_CBOW)
		p5('A', 'r', 'r', 'o', 'w');
	else if (sp == SP_THROW_CHAKRAM)
		p5('T', 'h', 'r', 'o', 'w');
};